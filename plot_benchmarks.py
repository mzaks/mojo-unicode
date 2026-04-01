#!/usr/bin/env python3
"""Run Mojo, Rust, Swift, Go, Node.js, and Python benchmarks and plot the results side by side."""

from pathlib import Path
import platform
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
               cwd=Path(__file__).resolve().parent)
rust_raw = run(["cargo", "run", "--release"],
               cwd=Path(__file__).resolve().parent / "rust")
swift_raw = run(["swift", "run", "--configuration", "release"],
                cwd=Path(__file__).resolve().parent / "swift")
go_dir = Path(__file__).resolve().parent / "go"
run(["go", "build", "-o", "unicode-bench", "."], cwd=go_dir)
go_raw = run([str(go_dir / "unicode-bench")], cwd=go_dir)
node_raw = run(["node", "bench.js"],
               cwd=Path(__file__).resolve().parent / "node")
py_raw = run(["python3", "convert.py"],
             cwd=Path(__file__).resolve().parent)

mojo  = parse_output(mojo_raw)
rust  = parse_output(rust_raw)
swift = parse_output(swift_raw)
go    = parse_output(go_raw)
node  = parse_output(node_raw)
py    = parse_output(py_raw)

# ── Plot 1: Lower ──────────────────────────────────────────────────────────────
# Mojo variants: Lower, Lower v2, Lower v3  |  Rust: Lower  |  Python: Lower
lower_series = {
    "Mojo lower":     mojo.get("Lower", {}),
    "Mojo lower v2":  mojo.get("Lower v2", {}),
    "Mojo lower v3":  mojo.get("Lower v3", {}),
    "Mojo lower v4":  mojo.get("Lower v4", {}),
    "Mojo lower v5":  mojo.get("Lower v5", {}),
    # "Mojo lower std": mojo.get("Lower std", {}),
    "Rust lower":     rust.get("Lower", {}),
    "Swift lower":    swift.get("Lower", {}),
    "Go lower":       go.get("Lower", {}),
    "Node lower":     node.get("Lower", {}),
    "Python lower":   py.get("Lower", {}),
}

# ── Plot 2: Upper ──────────────────────────────────────────────────────────────
upper_series = {
    "Mojo upper":     mojo.get("Upper", {}),
    "Mojo upper v2":  mojo.get("Upper v2", {}),
    "Mojo upper v3":  mojo.get("Upper v3", {}),
    "Mojo upper v4":  mojo.get("Upper v4", {}),
    # "Mojo upper std": mojo.get("Upper std", {}),
    "Rust upper":     rust.get("Upper", {}),
    "Swift upper":    swift.get("Upper", {}),
    "Go upper":       go.get("Upper", {}),
    "Node upper":     node.get("Upper", {}),
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
        for bar, val in zip(bars, values):
            if val > 0:
                ax.text(bar.get_x() + bar.get_width() / 2, bar.get_height(),
                        f"{val:.1f}", ha="center", va="bottom", fontsize=5, rotation=90)

    ax.set_title(title)
    ax.set_ylabel("ns per byte")
    ax.set_xticks(x)
    ax.set_xticklabels(LANGS)
    ax.legend(fontsize=8)
    ax.set_ylim(bottom=0)


fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(14, 10))
bar_chart(ax1, lower_series, "to_lower — Mojo vs Rust vs Swift vs Go vs Node.js vs Python (ns per byte, lower is better)")
bar_chart(ax2, upper_series, "to_upper — Mojo vs Rust vs Swift vs Go vs Node.js vs Python (ns per byte, lower is better)")

plt.tight_layout()
file_name = f"benchmark_comparison_{platform.machine()}.png"
plt.savefig(file_name, dpi=150)
print(f"Saved {file_name}")
plt.show()
