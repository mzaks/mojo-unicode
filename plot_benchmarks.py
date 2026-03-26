#!/usr/bin/env python3
"""Run Mojo and Rust benchmarks and plot the results side by side."""

import subprocess
import re
import matplotlib.pyplot as plt
import numpy as np


def parse_output(output: str) -> dict[str, dict[str, float]]:
    """Parse benchmark output into {label: {lang: ns_per_byte}}.

    Expected line pairs:
        In: 3.14 ns per byte
        Lower RU --------------------
    """
    results: dict[str, dict[str, float]] = {}
    lines = [l.strip() for l in output.strip().splitlines() if l.strip()]
    i = 0
    while i < len(lines) - 1:
        value_line = lines[i]
        label_line = lines[i + 1]
        m_val = re.match(r"In:\s+([\d.]+)\s+ns per byte", value_line)
        m_lbl = re.match(r"(.+?)\s+(\w+)\s+-+$", label_line)
        if m_val and m_lbl:
            ns = float(m_val.group(1))
            op = m_lbl.group(1).strip()   # e.g. "Lower", "Upper std"
            lang = m_lbl.group(2).strip() # e.g. "RU", "Adlam"
            results.setdefault(op, {})[lang] = ns
            i += 2
        else:
            i += 1
    return results


def run(cmd: list[str], cwd: str | None = None) -> str:
    print(f"Running: {' '.join(cmd)}")
    result = subprocess.run(cmd, capture_output=True, text=True, cwd=cwd)
    return result.stdout


LANGS = ["RU", "DE", "EN", "LT", "GR", "Adlam", "Fulflude", "CH"]

mojo_raw = run(["pixi", "run", "mojo", "run", "convert.mojo"],
               cwd="/home/mzaks/Work/mzaks/mojo-unicode")
rust_raw = run(["cargo", "run", "--release"],
               cwd="/home/mzaks/Work/mzaks/mojo-unicode/rust")
py_raw = run(["python3", "convert.py"],
             cwd="/home/mzaks/Work/mzaks/mojo-unicode")

mojo = parse_output(mojo_raw)
rust = parse_output(rust_raw)
py   = parse_output(py_raw)

# ── Plot 1: Lower ──────────────────────────────────────────────────────────────
# Mojo variants: Lower, Lower v2, Lower v3  |  Rust: Lower  |  Python: Lower
lower_series = {
    "Mojo lower":     mojo.get("Lower", {}),
    "Mojo lower v2":  mojo.get("Lower v2", {}),
    "Mojo lower v3":  mojo.get("Lower v3", {}),
    # "Mojo lower std": mojo.get("Lower std", {}),
    "Rust lower":     rust.get("Lower", {}),
    "Python lower":   py.get("Lower", {}),
}

# ── Plot 2: Upper ──────────────────────────────────────────────────────────────
upper_series = {
    "Mojo upper":     mojo.get("Upper", {}),
    # "Mojo upper std": mojo.get("Upper std", {}),
    "Rust upper":     rust.get("Upper", {}),
    "Python upper":   py.get("Upper", {}),
}


def bar_chart(ax, series: dict[str, dict[str, float]], title: str):
    n_groups = len(LANGS)
    n_bars = len(series)
    width = 0.8 / n_bars
    x = np.arange(n_groups)

    for i, (label, data) in enumerate(series.items()):
        values = [data.get(lang, 0.0) for lang in LANGS]
        offset = (i - n_bars / 2 + 0.5) * width
        bars = ax.bar(x + offset, values, width, label=label)

    ax.set_title(title)
    ax.set_ylabel("ns per byte")
    ax.set_xticks(x)
    ax.set_xticklabels(LANGS)
    ax.legend(fontsize=8)
    ax.set_ylim(bottom=0)


fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(14, 10))
bar_chart(ax1, lower_series, "to_lower — Mojo vs Rust vs Python (ns per byte, lower is better)")
bar_chart(ax2, upper_series, "to_upper — Mojo vs Rust vs Python (ns per byte, lower is better)")

plt.tight_layout()
plt.savefig("benchmark_comparison.png", dpi=150)
print("Saved benchmark_comparison.png")
plt.show()
