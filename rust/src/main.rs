use std::hint::black_box;
use std::time::Instant;

// source: https://nukadeti.ru/skazki/kasha_iz_topora
const TEXT_RU: &str = r#"
Старый солдат шёл на побывку. Притомился в пути, есть хочется. Дошёл до деревни, постучал в крайнюю избу:
- Пустите отдохнуть дорожного человека! Дверь отворила старуха.
- Заходи, служивый.
- А нет ли у тебя, хозяюшка, перекусить чего? У старухи всего вдоволь, а солдата поскупилась накормить, прикинулась сиротой.
- Ох, добрый человек, и сама сегодня ещё ничего не ела: нечего.
- Ну, нет так нет,- солдат говорит. Тут он приметил под лавкой топор.
- Коли нет ничего иного, можно сварить кашу и из топора.

Хозяйка руками всплеснула:
- Как так из топора кашу сварить?
- А вот как, дай-ка котёл.
Старуха принесла котёл, солдат вымыл топор, опустил в котёл, налил воды и поставил на огонь.
Старуха на солдата глядит, глаз не сводит.

Достал солдат ложку, помешивает варево. Попробовал.
- Ну, как? - спрашивает старуха.
- Скоро будет готова, - солдат отвечает, - жаль вот только, что посолить нечем.
- Соль-то у меня есть, посоли.
Солдат посолил, снова попробовал.
- Хороша! Ежели бы сюда да горсточку крупы! Старуха засуетилась, принесла откуда-то мешочек крупы.
- Бери, заправь как надобно. Заправил варево крупой. Варил, варил, помешивал, попробовал. Глядит старуха на солдата во все глаза, оторваться не может.
- Ох, и каша хороша! - облизнулся солдат.- Как бы сюда да чуток масла - было бы и вовсе объедение.
Нашлось у старухи и масло.

Сдобрили кашу.
- Ну, старуха, теперь подавай хлеба да принимайся за ложку: станем кашу есть!
- Вот уж не думала, что из топора эдакую добрую кашу можно сварить, - дивится старуха.
Поели вдвоем кашу. Старуха спрашивает:
- Служивый! Когда ж топор будем есть?
- Да, вишь, он не уварился,- отвечал солдат,- где-нибудь на дороге доварю да позавтракаю!
Тотчас припрятал топор в ранец, распростился с хозяйкою и пошёл в иную деревню.

Вот так-то солдат и каши поел и топор унёс!
"#;

// source: http://maerchen-welt.eu/deutschland/grimm/der_wolf_und_die_sieben_geisslein.htm
const TEXT_DE: &str = r#"
Wolf und die 7 Geißlen - Märchen
Der Wolf und die sieben Geißlein

Der Wolf und die sieben GeißleinEine Geiß hatte sieben junge Geißlein, die sie recht mütterlich liebte und sorgfältig vor dem Wolf hütete. Eines Tags, als sie ausgehen musste, Futter zu holen, rief sie alle zusammen und sagte: „Liebe Kinder, ich muss ausgehen und Futter holen, wahrt euch vor dem Wolf und lasst ihn nicht herein; gebt auch Acht, denn er verstellt sich oft, aber an seiner rauen Stimme und an seinen schwarzen Pfoten könnt ihr ihn erkennen; ist er erst einmal im Hause, so frisst er euch alle mit Haut und Haar." Nicht lange darauf als sie weggegangen war, kam auch schon der Wolf vor die Haustüre und rief mit seiner rauen Stimme: „Liebe Kinder, macht mir auf, ich bin eure Mutter und hab' euch schöne Sachen mitgebracht." Die sieben Geiserchen aber sprachen: „Unsere Mutter bist du nicht, die hat eine feine liebliche Stimme, deine Stimme aber ist rau, du bist der Wolf und wir machen dir nicht auf." Der Wolf aber besann sich auf eine List, ging fort zu einem Krämer und kaufte sich ein groß Stück Kreide, die aß er und machte seine Stimme fein damit. Darnach ging er wieder zu der sieben Geißlein Haustüre und rief mit feiner Stimme: „Liebe Kinder, lasst mich ein, ich bin eure Mutter, jedes von euch soll etwas haben." Er hatte aber seine Pfote in das Fenster gelegt, das sahen die sieben Geiserchen und sprachen: „Unsere Mutter bist du nicht, die hat keinen schwarzen Fuß, wie du; du bist der Wolf und wir machen dir nicht auf." Der Wolf ging fort zu einem Bäcker und sprach: „Bäcker, bestreich mir meine Pfote mit frischem Teig", und als das getan war, ging er zum Müller und sprach: „Müller, streu mir fein weißes Mehl auf meine Pfote."
Der Müller wollte nicht. „Wenn du es nicht tust, sprach der Wolf, so fresse ich dich." Da tat es der Müller aus Furcht.
Nun ging der Wolf wieder vor der sieben Geiserchen Haustüre und sagte: „Liebe Kinder, lasst mich ein, ich bin eure Mutter, jedes von euch soll etwas geschenkt kriegen." Die sieben Geiserchen wollten erst die Pfote sehen, und wie sie sahen, dass sie schneeweiß war und weil sie den Wolf so fein sprechen hörten, glaubten sie, es wäre ihre Mutter und machten die Türe auf, und der Wolf kam herein. Wie sie aber sahen, wer es war, wie erschraken sie da und versteckten sich geschwind, so gut es ging, das eine unter den Tisch, das zweite ins Bett, das dritte in den Ofen, das vierte in die Küche, das fünfte in den Schrank, das sechste unter eine große Schüssel, das siebente in die Wanduhr.



Aber der Wolf fand sie alle und verschluckte sie, außer das jüngste in der Wanduhr, das blieb am Leben. Darauf, als er seine Lust gebüßt, ging er fort.


Bald darauf kam die Mutter nach Haus. Die Haustüre stand offen, Tisch, Stuhl und Bänke waren umgeworfen, die Schüsseln in der Küche zerbrochen, die Decke und die Kissen aus dem Bett gezogen: was für ein Jammer! Der Wolf war da gewesen und hatte ihre lieben Kinder gefressen. „Ach! meine sieben Geiserchen sind tot!" rief sie in ihrer Traurigkeit, da sprang das jüngste aus der Wanduhr und sagte: „Eins lebt noch, liebe Mutter", und erzählte ihr, wie das Unglück gekommen war.

Der Wolf aber, nachdem er sich also wohlgetan, satt und müde war, hatte sich auf eine grüne Wiese in den Sonnenschein gelegt und war in einen tiefen Schlaf gefallen. Die alte Geiß aber war klug und listig, dachte hin und her; sind denn meine Kindlein nicht zu retten! endlich sagte sie ganz vergnügt zu dem jüngsten Geißlein: „Nimm Zwirn, Nadel und Schere und folg' mir nach." Nun gingen die beiden hinaus und fanden den Wolf schnarchend auf der Wiese liegen: „Da liegt der garstige Wolf", sagte die Mutter und betrachtete ihn von allen Seiten, „nachdem er zum Vieruhrenbrot meine sechs Kindlein hinunter gefressen hat, hat er nicht weiter laufen können; gib mir einmal die Schere her! ach! wenn sie noch lebendig in seinem Leibe waren!" Damit schnitt sie ihm den Bauch auf, und die sechs Geiserchen, die er in der Gier und Hast ganz verschluckt hatte, sprangen unversehrt heraus.

Ach, was herzten sie ihre Mutter, und waren froh, dass sie aus dem dunkeln Gefängnis befreit waren. Sie aber hieß sie hingehen und große und schwere Wackersteine herbeitragen, damit mussten sie dem Wolf den Leib füllen, und sie nähte ihn wieder zu. Dann liefen sie alle fort, und versteckten sich hinter eine Hecke.

Als der Wolf ausgeschlafen hatte, so fühlt' er es so schwer im Leib und sprach: „Es rumpelt und pumpelt mir im Leib herum! was ist das? ich habe nur sechs Geiserchen gegessen." Er dachte, ein frischer Trunk wird mir schon helfen machte sich auf und suchte einen Brunnen; aber wie er sich darüber bückte, konnte er sich vor der Schwere der Steine nicht mehr halten, und stürzte ins Wasser und ertrank. Wie das die sieben Geiserchen sahen, kamen sie herzu gelaufen, und tanzten vor Freude um den Brunnen.
"#;

// Generated by ChatGPT
const TEXT_EN: &str = r#"
Once upon a time, in a small village by a clear blue river, there lived a little girl named Hope. Hope had big, curious eyes and loved exploring everything around her. Every day she wondered what might be hiding beyond the hill, deep in the forest, or beneath the flowing water.

One morning, as the sun painted the rooftops gold, Hope decided to do something different. She took her small backpack, packed a piece of bread, an apple, and her favorite red scarf, and set off toward the forest.

The forest was full of sounds and scents. Birds sang cheerfully, leaves whispered as the wind brushed past them, and somewhere nearby a small stream gently trickled. Hope walked carefully, looking around in wonder.

Suddenly, she heard a strange sound. It was like a soft cry. She stopped and looked around. Behind a bush, she found a small fox cub. It was alone and looked frightened.

\"Don't be afraid,\" Hope said gently. \"I won't hurt you.\"

The little fox looked at her hesitantly. Hope took out her apple and gave it a small piece. Slowly, the cub stepped closer and took it.

\"Are you lost?\" Hope asked.

The fox couldn't speak, but its eyes clearly said yes. Hope thought for a moment and then said:

\"I will help you find your mother.\"

So they began a small journey together through the forest. As they walked, they met a wise old owl sitting on a branch.

\"Good morning,\" said the owl. \"Where are you going?\"

\"We are looking for her mother,\" Hope replied.

The owl closed its eyes for a moment, as if thinking deeply.

\"Her mother is near the great tree with the hollow trunk,\" it finally said. \"But the path is not easy. You must cross the stream and avoid the path of shadows.\"

Hope thanked the owl and continued on her way. The little fox walked beside her, a bit calmer now.

Soon they reached the stream. The water was flowing quickly, and there was no bridge. Hope looked around and found some large stones.

\"We'll cross by stepping on these,\" she said.

Carefully, she stepped from one stone to another. The fox followed her. At one point, it almost slipped, but Hope caught it.

\"Well done!\" she said with a smile.

After crossing the stream, they came to two paths. One was bright and full of flowers. The other was dark, filled with strange shadows.

Hope remembered the owl's words.

\"We must avoid the shadowy path,\" she said. \"Let's go this way.\"

As they walked along the bright path, they felt happier and lighter. Butterflies fluttered around them, and the air smelled of honey and herbs.

After a while, they saw the great tree with the hollow trunk. It was enormous and old, with roots that looked like arms hugging the earth.

Suddenly, a loud call echoed through the forest.

The little fox leaped forward and ran toward the tree. From inside, a large fox emerged. Her eyes filled with joy when she saw her cub.

Hope smiled. Her heart felt warm and full.

The mother fox approached Hope and lowered her head, as if thanking her.

\"I think you're safe now,\" Hope said to the little fox.

The cub looked at her for a moment, then ran back to its mother.

Hope sat down for a while under the great tree. She ate her bread and rested. She thought about how wonderful it felt to help someone.

As the sun began to set, she decided to return home. The path now felt more familiar and less frightening.

As she walked, she once again heard the birds singing and the leaves whispering. Everything seemed brighter, as if the forest itself was smiling at her.

When she reached home, her mother hugged her tightly.

\"Where were you? I was worried!\" she said.

Hope told her the whole story. Her mother looked at her with pride.

\"You are very brave and kind,\" she said.

That night, Hope fell asleep with a big smile. In her dreams, she ran through the forest again, alongside the little fox and all the animals she had met.

And from that day on, everyone in the village knew that if they needed help, they could turn to Hope. Because true magic isn't only found in the forest—it lives in a kind heart.

And they all lived happily ever after. ✨
"#;

// Generated by ChatGPT
const TEXT_LT: &str = r#"
Kartą, mažame kaimelyje prie skaidrios mėlynos upės, gyveno mergaitė vardu Viltė. Viltė turėjo dideles, smalsias akis ir labai mėgo tyrinėti pasaulį aplink save. Kiekvieną dieną ji svarstydavo, kas slepiasi už kalvos, miško gilumoje ar po tekančiu vandeniu.

Vieną rytą, kai saulė auksiniais spinduliais apšvietė namų stogus, Viltė nusprendė padaryti kažką ypatingo. Ji pasiėmė savo mažą kuprinę, įsidėjo gabalėlį duonos, obuolį ir savo mėgstamą raudoną skarelę, ir iškeliavo į mišką.

Miškas buvo pilnas garsų ir kvapų. Paukščiai linksmai čiulbėjo, lapai šnarėjo vėjui juos glostant, o kažkur netoliese girdėjosi švelnus upelio čiurlenimas. Viltė ėjo atsargiai, su nuostaba dairydamasi aplink.

Staiga ji išgirdo keistą garsą. Tai buvo tarsi tylus verksmas. Ji sustojo ir apsižvalgė. Už krūmo ji rado mažą laputę. Ji buvo viena ir atrodė išsigandusi.

„Nebijok," švelniai pasakė Viltė. „Aš tau nepakenksiu."

Laputė nedrąsiai pažvelgė į ją. Viltė iš kuprinės ištraukė obuolį ir padavė mažą gabalėlį. Pamažu gyvūnėlis priėjo ir jį paėmė.

„Ar pasiklydai?" paklausė Viltė.

Laputė negalėjo kalbėti, bet jos akys sakė „taip". Viltė akimirką pagalvojo ir tarė:

„Aš tau padėsiu surasti mamą."

Taip jos kartu leidosi į mažą kelionę per mišką. Eidamos jos sutiko seną, išmintingą pelėdą, tupinčią ant šakos.

„Labas rytas," tarė pelėda. „Kur keliaujate?"

„Mes ieškome jos mamos," atsakė Viltė.

Pelėda trumpam užmerkė akis, tarsi giliai mąstytų.

„Jos mama yra prie didelio medžio su tuščiaviduriu kamienu," galiausiai pasakė ji. „Tačiau kelias nebus lengvas. Turite pereiti upelį ir vengti tako su šešėliais."

Viltė padėkojo pelėdai ir tęsė kelionę. Laputė ėjo šalia jos, jau kiek ramesnė.

Netrukus jos priėjo upelį. Vanduo tekėjo greitai, o tilto nebuvo. Viltė apsižvalgė ir pastebėjo keletą didelių akmenų.

„Pereisime per juos," pasakė ji.

Atsargiai ji pradėjo lipti nuo vieno akmens ant kito. Laputė sekė paskui. Vienu momentu ji vos nenuslydo, bet Viltė ją sulaikė.

„Šaunuolė!" nusišypsojo ji.

Perėjusios upelį jos atsidūrė prie dviejų takų. Vienas buvo šviesus ir pilnas gėlių. Kitas – tamsus, pilnas keistų šešėlių.

Viltė prisiminė pelėdos žodžius.

„Turime vengti šešėlių tako," pasakė ji. „Eime šiuo."

Eidamos šviesiu taku jos jautėsi vis laimingesnės. Aplink skraidė drugeliai, o oras kvepėjo medumi ir žolelėmis.

Po kurio laiko jos pamatė didelį medį su tuščiaviduriu kamienu. Jis buvo milžiniškas ir senas, su šaknimis, kurios atrodė kaip rankos, apkabinančios žemę.

Staiga pasigirdo garsus šauksmas.

Laputė šoko pirmyn ir nubėgo prie medžio. Iš vidaus išlindo didelė lapė. Jos akys nušvito džiaugsmu pamačius savo mažylę.

Viltė nusišypsojo. Jos širdis prisipildė šilumos.

Didžioji lapė priėjo prie Viltės ir palenkė galvą, tarsi dėkodama.

„Dabar tu saugi," tarė Viltė mažajai laputei.

Laputė dar akimirką pažvelgė į ją ir tada nubėgo pas savo mamą.

Viltė trumpam prisėdo po didžiuoju medžiu. Ji suvalgė savo duoną ir pailsėjo. Ji galvojo, kaip gera padėti kitiems.

Kai saulė pradėjo leistis, ji nusprendė grįžti namo. Kelias dabar atrodė pažįstamesnis ir nebe toks baisus.

Eidama ji vėl girdėjo paukščių giesmes ir lapų šnarėjimą. Viskas atrodė šviesiau, tarsi pats miškas jai šypsotųsi.

Kai ji grįžo namo, mama ją stipriai apkabino.

„Kur buvai? Aš labai jaudinausi!" pasakė ji.

Viltė papasakojo visą savo nuotykį. Mama pažvelgė į ją su pasididžiavimu.

„Tu labai drąsi ir gera," tarė ji.

Tą naktį Viltė užmigo su plačia šypsena. Sapnuose ji vėl bėgiojo po mišką su mažąja lapute ir visais gyvūnais, kuriuos sutiko.

Ir nuo tos dienos kiekvienas kaime žinojo, kad jei reikia pagalbos, galima kreiptis į Viltę. Nes tikroji magija slypi ne tik miške, bet ir gerumo pilnoje širdyje.

Ir jie visi gyveno laimingai, o mes – dar laimingiau. ✨
"#;

// Generated by ChatGPT
const TEXT_GR: &str = r#"
Μια φορά κι έναν καιρό, σε ένα μικρό χωριό πλάι σε ένα καταγάλανο ποτάμι, ζούσε ένα κοριτσάκι που το έλεγαν Ελπίδα. Η Ελπίδα είχε μεγάλα, περίεργα μάτια και αγαπούσε να εξερευνά τα πάντα γύρω της. Κάθε μέρα αναρωτιόταν τι μπορεί να κρύβεται πίσω από τον λόφο, μέσα στο δάσος ή κάτω από τα νερά του ποταμού.

Ένα πρωινό, καθώς ο ήλιος έλουζε τα σπίτια με χρυσαφένιο φως, η Ελπίδα αποφάσισε να κάνει κάτι διαφορετικό. Πήρε το μικρό της σακίδιο, έβαλε μέσα ένα κομμάτι ψωμί, ένα μήλο και το αγαπημένο της κόκκινο μαντήλι, και ξεκίνησε για το δάσος.

Το δάσος ήταν γεμάτο ήχους και μυρωδιές. Τα πουλιά κελαηδούσαν χαρούμενα, τα φύλλα ψιθύριζαν καθώς τα χάιδευε ο αέρας, και κάπου μακριά ακουγόταν το γάργαρο νερό μιας πηγής. Η Ελπίδα προχωρούσε προσεκτικά, κοιτώντας γύρω της με θαυμασμό.

Ξαφνικά, άκουσε ένα παράξενο ήχο. Ήταν σαν ένα μικρό κλάμα. Σταμάτησε και κοίταξε γύρω της. Πίσω από έναν θάμνο, βρήκε ένα μικρό αλεπουδάκι. Ήταν μόνο του και έμοιαζε φοβισμένο.

«Μη φοβάσαι», είπε η Ελπίδα με γλυκιά φωνή. «Δεν θα σου κάνω κακό».

Το αλεπουδάκι την κοίταξε διστακτικά. Η Ελπίδα έβγαλε από το σακίδιό της το μήλο και του έδωσε ένα μικρό κομμάτι. Σιγά σιγά, το ζώο πλησίασε και το πήρε.

«Έχεις χαθεί;» ρώτησε η Ελπίδα.

Το αλεπουδάκι δεν μπορούσε να μιλήσει, αλλά με τα μάτια του έδειχνε πως ναι. Η Ελπίδα σκέφτηκε λίγο και είπε:

«Θα σε βοηθήσω να βρεις τη μαμά σου».

Έτσι ξεκίνησαν μαζί ένα μικρό ταξίδι μέσα στο δάσος. Καθώς προχωρούσαν, συνάντησαν έναν σοφό γέρο κουκουβάγια που καθόταν πάνω σε ένα κλαδί.

«Καλημέρα σας», είπε η κουκουβάγια. «Πού πηγαίνετε;»

«Ψάχνουμε τη μαμά του», απάντησε η Ελπίδα.

Η κουκουβάγια έκλεισε τα μάτια της για λίγο, σαν να σκεφτόταν βαθιά.

«Η μαμά του βρίσκεται κοντά στο μεγάλο δέντρο με τον κοίλο κορμό», είπε τελικά. «Αλλά ο δρόμος δεν είναι εύκολος. Πρέπει να περάσετε από το ρυάκι και να αποφύγετε το μονοπάτι με τις σκιές».

Η Ελπίδα ευχαρίστησε την κουκουβάγια και συνέχισε τον δρόμο της. Το αλεπουδάκι περπατούσε δίπλα της, λίγο πιο ήρεμο τώρα.

Σύντομα έφτασαν στο ρυάκι. Το νερό έτρεχε γρήγορα και δεν υπήρχε γέφυρα. Η Ελπίδα κοίταξε γύρω της και βρήκε μερικές μεγάλες πέτρες.

«Θα περάσουμε πατώντας πάνω σε αυτές», είπε.

Με προσοχή, άρχισε να περνά από πέτρα σε πέτρα. Το αλεπουδάκι την ακολουθούσε. Μια στιγμή παραλίγο να γλιστρήσει, αλλά η Ελπίδα το κράτησε.

«Μπράβο σου!» του είπε χαμογελώντας.

Αφού πέρασαν το ρυάκι, βρέθηκαν μπροστά σε δύο μονοπάτια. Το ένα ήταν φωτεινό και γεμάτο λουλούδια. Το άλλο ήταν σκοτεινό, με παράξενες σκιές.

Η Ελπίδα θυμήθηκε τα λόγια της κουκουβάγιας.

«Πρέπει να αποφύγουμε το μονοπάτι με τις σκιές», είπε. «Άρα θα πάμε από εδώ».

Καθώς περπατούσαν στο φωτεινό μονοπάτι, ένιωθαν όλο και πιο χαρούμενοι. Πεταλούδες πετούσαν γύρω τους και ο αέρας μύριζε μέλι και θυμάρι.

Μετά από λίγο, είδαν το μεγάλο δέντρο με τον κοίλο κορμό. Ήταν τεράστιο και παλιό, με ρίζες που έμοιαζαν σαν χέρια που αγκάλιαζαν τη γη.

Ξαφνικά, ακούστηκε ένα δυνατό κάλεσμα.

Το αλεπουδάκι πετάχτηκε μπροστά και έτρεξε προς το δέντρο. Από μέσα βγήκε μια μεγάλη αλεπού. Τα μάτια της γέμισαν χαρά όταν είδε το μικρό της.

Η Ελπίδα χαμογέλασε. Ένιωσε την καρδιά της να γεμίζει ζεστασιά.

Η μεγάλη αλεπού πλησίασε την Ελπίδα και έσκυψε το κεφάλι της, σαν να την ευχαριστούσε.

«Νομίζω πως τώρα είσαι ασφαλής», είπε η Ελπίδα στο μικρό αλεπουδάκι.

Το αλεπουδάκι την κοίταξε για λίγο και μετά έτρεξε πίσω στη μαμά του.

Η Ελπίδα κάθισε λίγο κάτω από το μεγάλο δέντρο. Έφαγε το ψωμί της και ξεκουράστηκε. Σκεφτόταν πόσο όμορφο ήταν να βοηθάς κάποιον.

Όταν ο ήλιος άρχισε να δύει, αποφάσισε να επιστρέψει στο χωριό. Ο δρόμος της φαινόταν τώρα πιο γνώριμος και λιγότερο τρομακτικός.

Καθώς περπατούσε, άκουσε πάλι το κελάηδημα των πουλιών και το ψιθύρισμα των φύλλων. Όλα έμοιαζαν πιο φωτεινά, σαν το δάσος να της χαμογελούσε.

Όταν έφτασε στο σπίτι της, η μητέρα της την αγκάλιασε σφιχτά.

«Πού ήσουν; Ανησύχησα!» είπε.

Η Ελπίδα της διηγήθηκε όλη την περιπέτειά της. Η μητέρα της την κοίταξε με περηφάνια.

«Είσαι πολύ γενναία και καλή», της είπε.

Εκείνο το βράδυ, η Ελπίδα κοιμήθηκε με ένα μεγάλο χαμόγελο. Στα όνειρά της, έτρεχε ξανά μέσα στο δάσος, μαζί με το αλεπουδάκι και όλα τα ζώα που είχε γνωρίσει.

Και από εκείνη τη μέρα, κάθε φορά που κάποιος στο χωριό χρειαζόταν βοήθεια, ήξερε ότι μπορούσε να βρει την Ελπίδα. Γιατί η αληθινή μαγεία δεν βρισκόταν μόνο στο δάσος, αλλά και στην καλοσύνη της καρδιάς της.

Και έτσι, η μικρή Ελπίδα έγινε γνωστή όχι μόνο για την περιέργειά της, αλλά και για τη μεγάλη της καρδιά.

Και έζησαν όλοι καλά, κι εμείς καλύτερα. ✨
"#;

// Generated by ChatGPT
const TEXT_ADLAM: &str = r#"
𞤘𞤮𞤲𞤮𞥅 𞤫 𞤘𞤮𞤲𞤮𞥅، 𞤫 𞤱𞤵𞤪𞤮 𞤨𞤢𞤥𞤢𞤪𞤫𞤤 𞤯𞤮 𞤲𞤣𞤭𞤴𞤢𞤥 𞤱𞤫𞤤𞤱𞤫𞤤𞤮، 𞤱𞤮𞤲𞤭 𞤣𞤫𞤦𞤦𞤮 𞤨𞤢𞤥𞤢𞤪𞤫𞤤 𞤭𞤲𞥋𞤣𞤫 𞤥𞤢𞤳𞤳𞤮 𞤘𞤭𞤥𞤦𞤫. 𞤘𞤭𞤥𞤦𞤫 𞤱𞤮𞤮𞤣𞤭 𞤺𞤭𞤼𞤫 𞤥𞤢𞤱𞤯𞤫، 𞤷𞤮𞤳𞤳𞤵𞤣𞤫 𞤫 𞤢𞤲𞤲𞤣𞤵𞤣𞤫 𞤳𞤢𞤤𞤢 𞤳𞤮 𞤱𞤮𞤲𞤭 𞤫 𞤤𞤫𞤴𞤣𞤭.

𞤅𞤵𞤦𞤢𞤳𞤢 𞤘𞤮𞤲𞤮𞥅، 𞤲𞤣𞤫 𞤲𞤢𞤢𞤲𞤺𞤫 𞤱𞤢𞤯𞤭 𞤯𞤮 𞤲𞤣𞤭𞤴𞤢𞤥، 𞤘𞤭𞤥𞤦𞤫 𞤱𞤢𞤯𞤭 𞤢𞤲𞤲𞤣𞤵𞤣𞤫 𞤱𞤢𞤯𞤵𞤺𞤮 𞤺𞤮𞤯𞤯𞤵𞤥 𞤸𞤫𞤧𞤫𞤪𞤫. 𞤋 𞤱𞤢𞤯𞤭 𞤶𞤢𞤳𞤳𞤢 𞤥𞤢𞤳𞤳𞤮، 𞤋 𞤱𞤢𞤯𞤭 𞤫 𞤥𞤵𞤥 𞤦𞤵𞤪𞤮𞤮𞤣𞤭 𞤧𞤫𞤯𞤯𞤢، 𞤨𞤮𞤥𞤥𞤫، 𞤫 𞤤𞤫𞤨𞤨𞤭 𞤥𞤢𞤳𞤳𞤮 𞤱𞤮𞤣𞤫𞤫𞤪𞤫، 𞤋 𞤣𞤭𞤤𞤤𞤭𞤭 𞤤𞤢𞤣𞤣𞤫.

𞤂𞤢𞤣𞤣𞤫 𞤯𞤮𞤲 𞤲𞤮 𞤸𞤫𞤫𞤱𞤭 𞤫 𞤸𞤢𞤢𞤤𞤢𞤶𞤭 𞤫 𞤵𞤵𞤪𞤯𞤫. 𞤕𞤮𞤤𞤤𞤭 𞤲𞤮 𞤶𞤮𞤮𞤣𞤭، 𞤤𞤫𞤴𞤣𞤭 𞤲𞤮 𞤴𞤫𞤱𞤼𞤭𞤭، 𞤫 𞤲𞤣𞤭𞤴𞤢𞤥 𞤧𞤫𞤯𞤯𞤢 𞤲𞤮 𞤪𞤭𞤭𞤱𞤭. 𞤘𞤭𞤥𞤦𞤫 𞤲𞤮 𞤴𞤢𞤢𞤧𞤭 𞤫 𞤸𞤢𞤳𞤳𞤵𞤲𞤣𞤫.

𞤐𞤣𞤫𞤲، 𞤋 𞤲𞤢𞤲𞤭 𞤱𞤮𞤲𞤭 𞤧𞤢𞤱𞤪𞤵 𞤧𞤫𞤯𞤯𞤢—𞤲𞤮 𞤱𞤢𞤯𞤭 𞤸𞤮𞤲𞤮 𞤺𞤮𞤯𞤯𞤮 𞤲𞤮 𞤱𞤮𞤴𞤭. 𞤋 𞤣𞤢𞤪𞤼𞤭، 𞤋 𞤴𞤭𞤴𞤭 𞤷𞤢𞤺𞤺𞤢𞤤 𞤤𞤫𞤳𞤳𞤭: 𞤨𞤭𞤲𞤢𞤤 𞤳𞤮𞤴𞤯𞤫. 𞤋 𞤱𞤮𞤲𞤭 𞤺𞤮𞤮𞤼𞤮، 𞤋 𞤸𞤵𞤤𞤭𞤭.

\"𞤀𞤤𞤥𞤢 𞤸𞤵𞤤,\" 𞤘𞤭𞤥𞤦𞤫 𞤱𞤭𞤭𞤭. \"𞤃𞤭 𞤱𞤢𞤯𞤢𞤼𞤢𞤢 𞤥𞤢 𞤳𞤮 𞤦𞤮𞤲𞤭.\"

𞤨𞤭𞤲𞤢𞤤 𞤲𞤺𞤢𞤤 𞤴𞤭𞤴𞤭 𞤥𞤮. 𞤘𞤭𞤥𞤦𞤫 𞤱𞤢𞤯𞤭 𞤨𞤮𞤥𞤥𞤫 𞤥𞤵𞤥، 𞤋 𞤸𞤮𞤳𞤳𞤢 𞤲𞤺𞤢𞤤 𞤧𞤫𞤯𞤯𞤢.

\"𞤀𞤯𞤢 𞤥𞤢𞤶𞤶𞤭?\" 𞤘𞤭𞤥𞤦𞤫 𞤱𞤭𞤭𞤭.

𞤨𞤭𞤲𞤢𞤤 𞤲𞤺𞤢𞤤 𞤱𞤢𞤱𞤭 𞤸𞤢𞤢𞤤𞤵𞤣𞤫 𞤲𞤢𞤢، 𞤳𞤮𞤲𞤮 𞤺𞤭𞤼𞤫 𞤥𞤵𞤥 𞤱𞤭𞤭𞤭 \"𞤫𞤫\". 𞤘𞤭𞤥𞤦𞤫 𞤱𞤢𞤯𞤭 𞤥𞤭𞤶𞤮𞤮𞤶𞤭، 𞤲𞤣𞤫𞤲 𞤱𞤭𞤭𞤭:

\"𞤃𞤭 𞤱𞤢𞤤𞤤𞤢𞤴 𞤥𞤢𞤢 𞤴𞤭𞤭𞤺𞤮 𞤴𞤵𞤥𞤥𞤢 𞤥𞤢𞤢.\"
"#;

// Generated by ChatGPT
const TEXT_FULFULDE: &str = r#"
Goɗɗo e goɗɗo, e wuro pamarel ɗo ndiyam welwelo, woni debbo pamarel innde makko Yimɓe. Yimɓe woodi gite mawɗe, cokkude e anndude kala ko woni e leydi. Koo nde, o waɗi miijo dow ko woni caggal hoore, e ladde, walla e ley ndiyam.

Subaka goɗɗo, nde naange waɗi ɗo wuro e nder jeyaaɗe mum, Yimɓe anniyaki waɗugo goɗɗum hesere. O hocci jakka makko pamarel, o waɗi e mum buroodi seɗɗa, pomme, e leppi makko wodeere, o dillii ladde.

Ladde ɗon no heewi e haalaaji e uurɗe. Colli no njooɗi, leydi no yewtii e henndu, e ndiyam seɗɗa no riiwi haade. Yimɓe no yaasi e hakkunde ladde, no yiɗi anndude kala ko o yi'i.

Nden, o nani sawru seɗɗa—no nandi hono goɗɗo no woyi. O dartii, o yiyi caggal lekki pamarel: pinal koyɗe pamarel. O woni gooto, o hulii.

\"Almaa hul,\" Yimɓe wi'i e ndemngal. \"Mi waɗataa ma ko boni.\"

Pinal ngal yiyi mo e ndun. Yimɓe hocci pomme mum, o hokka ngal seɗɗa. Ngal waɗi seɗɗa, nden ngal ɓadi mo.

\"Aɗa majji?\" Yimɓe wi'i.

Pinal ngal waawi haalude naa, kono gite mum wi'i \"ee\". Yimɓe waɗi miijo seɗɗa, nden wi'i:

\"Mi wallay maa yi'ugo yumma maa.\"

Nden ɓe ɗonɗi e laawol ladde. E dow laawol, ɓe tawi cawru mawɗo, jeyaaɗo e hakkiilo, no jooɗii e dow lekki.

\"Jam waali,\" o wi'i. \"Hol ko on ɗo yaasi?\"

\"Min ɗo ɗaɓɓita yumma makko,\" Yimɓe wi'i.

Cawru on maɓɓi gite mum, no waɗi miijo.

\"Yumma mum woni haade lekki mawɗo e nde hole,\" o wi'i. \"Kono laawol ngal ɗo woodi caɗeele. On njahi dow ndiyam, tee on nattataa laawol ɗum e mbeewaaji.\"

Yimɓe yetti mo, nden o soodi.

Ɓe tawi ndiyam. Ndiyam ɗon no yaha jaasi, walaa gaɗol. Yimɓe yiyi kaaɗe mawɗe.

\"En njahata e dow ɗe,\" o wi'i.

O waɗi e dow kaaɗe gooto-gooto. Pinal ngal ɗonndii caggal makko. E goɗɗe nde, ngal faali, kono Yimɓe jogii ngal.

\"On jaɓii!\" o wi'i e weltaare.

Caggal ɗon, ɓe tawi laawol ɗiɗi. Gooto no woodi naange e fuɗɗe, gooto no woodi ndukkum e mbeewaaji.

Yimɓe siftori haala cawru.

\"En nattataa laawol mbeewaaji,\" o wi'i. \"En njahata e laawol naange.\"

Ɓe ɗonɗi e laawol ngal, e weltaare no ɓeydi. Njiddi no ndilliri e ɓe, e henndu no waɗi uurɗe welɗe.

Caggal seɗɗa, ɓe tawi lekki mawɗo e hole. O mawɗo, o nder, e ɗaɓɓe mum no nandi e juuɗe ɗe huggi leydi.

Nden, sawru mawɗo nani.

Pinal ngal doggi, ngal dillii haade lekki. E nder, koyɗo mawɗo wurtii. Gite mum no heewi e weltaare nde o yiyi ɓiiko.

Yimɓe yewti, ɓernde mum no heewi e weltaare.

Koyɗo mawɗo ndilli haade mum, o woni hono o yettii mo.

\"Jooni a woodi jam,\" Yimɓe wi'i.

Pinal ngal yiyi mo seɗɗa, nden ngal soodi haa yumma mum.

Yimɓe jooɗii seɗɗa e ley lekki. O nyaami buroodi mum, o fotii. O miijii dow weltaare wallude goɗɗo.

Nde naange jippii, o soodi wuro. Laawol ngal nandi e anndude jooni, tee walaa hulnde.

O nani colli, e leydi no yewtii. Fof nandi e weltaare—hono ladde no njiiɗi mo.

Nde o waɗi wuro, yumma mum jogii mo sembe.

\"Hol no waɗi? Mi hulii!\" o wi'i.

Yimɓe haalani mo kala ko waɗi. Yumma mum yiyi mo e weltaare.

\"Aɗa woodi semteende e ɓernde welnde,\" o wi'i.

Nde ɗon, Yimɓe waali e weltaare mawnde. E koyɗe mum, o yahi ladde, e pinal ngal e waɗɓe kala.

E ndeen, kala e wuro anndi: so a yiɗi walla, aɗa heɓa Yimɓe. Sababu sihiru goonga woni e ɓernde welnde.

E ɓe fow ngoodi e jam.
"#;

// Generated by ChatGPT (note: also contains some Cyrillic)
const TEXT_CH: &str = r#"
从前，在一条清澈蔚蓝的小河边，有一个小村庄。村庄里住着一个小女孩，名字叫"希望"。希望有一双大大的、充满好奇的眼睛，她非常喜欢探索周围的一切。每天，她都会想：山的那一边是什么？森林深处藏着什么？水底又有什么秘密呢？

一天早晨，阳光把屋顶染成了金色，希望决定做一件特别的事情。她背上小小的背包，装进一块面包、一个苹果，还有她最喜欢的红色围巾，然后出发走向森林。

森林里充满了各种声音和气味。小鸟欢快地歌唱，树叶在微风中轻轻沙沙作响，不远处还有小溪潺潺流动。希望小心地走着，好奇地观察着周围的一切。

突然，她听到一个奇怪的声音，像是轻轻的哭泣。她停下脚步，四处寻找。在一丛灌木后面，她发现了一只小狐狸。它孤零零的，看起来非常害怕。

"别害怕，"希望温柔地说，"我不会伤害你的。"

小狐狸犹豫地看着她。希望从背包里拿出苹果，掰下一小块递给它。慢慢地，小狐狸走近，把苹果接了过去。

"你迷路了吗？"希望问。

小狐狸不会说话，但它的眼睛仿佛在说"是的"。希望想了想，说：

"我来帮你找到妈妈。"

于是，她们一起踏上了一段小小的旅程。在森林里，她们遇到了一只聪明的老猫头鹰，正栖息在树枝上。

"早上好，"猫头鹰说，"你们要去哪里？"

"我们在找它的妈妈，"希望回答。

猫头鹰闭上眼睛，好像在认真思考。

"它的妈妈在一棵中空的大树附近，"猫头鹰终于说道，"不过路并不容易。你们必须穿过小溪，还要避开那条有阴影的小路。"

希望向猫头鹰道谢，然后继续前进。小狐狸跟在她身边，已经不那么害怕了。

不久，她们来到了小溪边。水流很急，而且没有桥。希望四处看了看，发现几块大石头。

"我们踩着这些石头过去吧，"她说。

她小心翼翼地从一块石头跳到另一块，小狐狸跟在后面。有一次，小狐狸差点滑倒，但希望及时扶住了它。

"做得好！"她笑着说。

过了小溪后，她们来到两条岔路前。一条明亮，开满了花；另一条阴暗，布满了奇怪的影子。

希望想起了猫头鹰的话。

"我们要避开那条阴影的路，"她说，"走这边吧。"

她们沿着明亮的小路前进，心情越来越轻松愉快。蝴蝶在她们身边飞舞，空气中弥漫着花蜜和青草的香气。

走了一会儿，她们看见了一棵巨大的中空老树。树非常高大，根部像一双双手臂，拥抱着大地。

突然，一声响亮的呼唤传来。

小狐狸一下子冲了过去，跑向大树。从树洞里走出一只大狐狸。它看到小狐狸时，眼中充满了喜悦。

希望微笑着，心里暖暖的。

大狐狸走到希望面前，低下头，仿佛在向她表示感谢。

"现在你安全了，"希望对小狐狸说。

小狐狸看了她一眼，然后跑回了妈妈身边。

希望在大树下坐了一会儿，吃了面包，休息了一下。她想着，帮助别人是多么美好的事情。

当太阳开始落山时，她决定回家。现在的路看起来熟悉多了，也不再那么可怕。

一路上，她 снова слышала鸟儿歌唱和树叶沙沙作响，一切都显得更加明亮，仿佛森林在对她微笑。

当她回到家时，妈妈紧紧地抱住了她。

"你去哪儿了？我好担心！"妈妈说。

希望把自己的冒险经历讲给妈妈听。妈妈骄傲地看着她。

"你真勇敢，又善良，"妈妈说。

那天晚上，希望带着微笑进入梦乡。在梦里，她 снова在森林里奔跑，和小狐狸以及所有遇见的动物一起玩耍。

从那天起，村里的人都知道，如果需要帮助，就可以去找希望。因为真正的魔法，不仅存在于森林中，更存在于一颗善良的心里。

从此，他们幸福地生活在一起。✨
"#;

fn bench_lower(text: &str) -> f64 {
    let mut min_ns = u128::MAX;
    let mut result = String::new();
    for _ in 0..100 {
        let now = Instant::now();
        result = black_box(text).to_lowercase();
        min_ns = min_ns.min(now.elapsed().as_nanos());
    }
    drop(result);
    min_ns as f64 / text.len() as f64
}

fn bench_upper(text: &str) -> f64 {
    let mut min_ns = u128::MAX;
    let mut result = String::new();
    for _ in 0..100 {
        let now = Instant::now();
        result = black_box(text).to_uppercase();
        min_ns = min_ns.min(now.elapsed().as_nanos());
    }
    drop(result);
    min_ns as f64 / text.len() as f64
}

#[cfg(target_os = "macos")]
fn request_performance_cores() {
    extern "C" {
        fn pthread_set_qos_class_self_np(qos_class: u32, relative_priority: i32) -> i32;
    }
    // QOS_CLASS_USER_INTERACTIVE = 0x21 → scheduler prefers P-cores
    unsafe { pthread_set_qos_class_self_np(0x21, 0); }
}

fn main() {
    #[cfg(target_os = "macos")]
    request_performance_cores();

    let texts = [
        (TEXT_RU, "RU"),
        (TEXT_DE, "DE"),
        (TEXT_EN, "EN"),
        (TEXT_LT, "LT"),
        (TEXT_GR, "GR"),
        (TEXT_ADLAM, "Adlam"),
        (TEXT_FULFULDE, "Fulflude"),
        (TEXT_CH, "CH"),
    ];

    for (text, name) in &texts {
        let ns = bench_lower(text);
        println!("In: {} ns per byte", ns);
        println!("Lower {} --------------------", name);
        let ns = bench_upper(text);
        println!("In: {} ns per byte", ns);
        println!("Upper {} --------------------", name);
    }
}
