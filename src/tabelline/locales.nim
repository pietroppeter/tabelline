## Number, currency, date and time conventions of every locale of CLDR.
## Written by `tools/cldr.nim` from Unicode CLDR 49.0.0: do not edit.
## CLDR is under the Unicode License v3 (`licenses/unicode-cldr-LICENSE.txt`).
##
## `localeFields` names the fields of a record. A locale keeps only the fields that differ
## from its parent (`localeParents`, or the tag without its last subtag); `und` is the root,
## written in full. Each value is written once, in `localeValues` (joined by '\x1F'; '\x1E'
## is an empty value). `localeTable` gives each locale's first cell: a cell is a field
## (`localeCellField`) and the number of its value (`localeCellValue`).

const localeFields* = ["decimal", "group", "percentSign", "percentPattern", "currencyPattern", "accountingPattern", "month1", "month2", "month3", "month4", "month5", "month6", "month7", "month8", "month9", "month10", "month11", "month12", "monthAbbr1", "monthAbbr2", "monthAbbr3", "monthAbbr4", "monthAbbr5", "monthAbbr6", "monthAbbr7", "monthAbbr8", "monthAbbr9", "monthAbbr10", "monthAbbr11", "monthAbbr12", "monthAlone1", "monthAlone2", "monthAlone3", "monthAlone4", "monthAlone5", "monthAlone6", "monthAlone7", "monthAlone8", "monthAlone9", "monthAlone10", "monthAlone11", "monthAlone12", "monthAloneAbbr1", "monthAloneAbbr2", "monthAloneAbbr3", "monthAloneAbbr4", "monthAloneAbbr5", "monthAloneAbbr6", "monthAloneAbbr7", "monthAloneAbbr8", "monthAloneAbbr9", "monthAloneAbbr10", "monthAloneAbbr11", "monthAloneAbbr12", "day-sun", "day-mon", "day-tue", "day-wed", "day-thu", "day-fri", "day-sat", "dayAbbr-sun", "dayAbbr-mon", "dayAbbr-tue", "dayAbbr-wed", "dayAbbr-thu", "dayAbbr-fri", "dayAbbr-sat", "quarter1", "quarter2", "quarter3", "quarter4", "quarterAbbr1", "quarterAbbr2", "quarterAbbr3", "quarterAbbr4", "am", "pm", "eraBC", "eraAD", "date-full", "date-long", "date-medium", "date-short", "time-full", "time-long", "time-medium", "time-short", "dateTime", "skeleton-yMd", "skeleton-yMEd", "skeleton-yMMM", "skeleton-yMMMM", "skeleton-yMMMd", "skeleton-yMMMEd", "skeleton-GyMd", "skeleton-GyMMMd", "skeleton-GyMMMEd", "skeleton-yM", "skeleton-Md", "skeleton-MEd", "skeleton-MMMd", "skeleton-MMMEd", "skeleton-MMMMd", "skeleton-GyMMM", "skeleton-yQQQ", "skeleton-yQQQQ", "skeleton-Gy", "skeleton-y", "skeleton-M", "skeleton-MMM", "skeleton-d", "skeleton-Ed", "skeleton-Hms", "skeleton-Hm", "skeleton-H", "skeleton-hms", "skeleton-hm", "skeleton-h", "skeleton-ms"]

const localeParents* = [
  ("az-Cyrl", "und"),
  ("bal-Latn", "und"),
  ("bs-Cyrl", "und"),
  ("en-150", "en-001"),
  ("en-AG", "en-001"),
  ("en-AI", "en-001"),
  ("en-AT", "en-150"),
  ("en-AU", "en-001"),
  ("en-BB", "en-001"),
  ("en-BE", "en-150"),
  ("en-BM", "en-001"),
  ("en-BS", "en-001"),
  ("en-BW", "en-001"),
  ("en-BZ", "en-001"),
  ("en-CC", "en-001"),
  ("en-CH", "en-150"),
  ("en-CK", "en-001"),
  ("en-CM", "en-001"),
  ("en-CX", "en-001"),
  ("en-CY", "en-001"),
  ("en-CZ", "en-150"),
  ("en-DE", "en-150"),
  ("en-DG", "en-001"),
  ("en-DK", "en-150"),
  ("en-DM", "en-001"),
  ("en-EE", "en-150"),
  ("en-ER", "en-001"),
  ("en-ES", "en-150"),
  ("en-FI", "en-150"),
  ("en-FJ", "en-001"),
  ("en-FK", "en-001"),
  ("en-FM", "en-001"),
  ("en-FR", "en-150"),
  ("en-GB", "en-001"),
  ("en-GD", "en-001"),
  ("en-GE", "en-150"),
  ("en-GG", "en-001"),
  ("en-GH", "en-001"),
  ("en-GI", "en-001"),
  ("en-GM", "en-001"),
  ("en-GS", "en-001"),
  ("en-GY", "en-001"),
  ("en-HK", "en-001"),
  ("en-HU", "en-150"),
  ("en-ID", "en-001"),
  ("en-IE", "en-001"),
  ("en-IL", "en-001"),
  ("en-IM", "en-001"),
  ("en-IN", "en-001"),
  ("en-IO", "en-001"),
  ("en-IT", "en-150"),
  ("en-JE", "en-001"),
  ("en-JM", "en-001"),
  ("en-KE", "en-001"),
  ("en-KI", "en-001"),
  ("en-KN", "en-001"),
  ("en-KY", "en-001"),
  ("en-LC", "en-001"),
  ("en-LR", "en-001"),
  ("en-LS", "en-001"),
  ("en-LT", "en-150"),
  ("en-LV", "en-150"),
  ("en-MG", "en-001"),
  ("en-MO", "en-001"),
  ("en-MS", "en-001"),
  ("en-MT", "en-001"),
  ("en-MU", "en-001"),
  ("en-MV", "en-001"),
  ("en-MW", "en-001"),
  ("en-MY", "en-001"),
  ("en-NA", "en-001"),
  ("en-NF", "en-001"),
  ("en-NG", "en-001"),
  ("en-NL", "en-150"),
  ("en-NO", "en-150"),
  ("en-NR", "en-001"),
  ("en-NU", "en-001"),
  ("en-NZ", "en-001"),
  ("en-PG", "en-001"),
  ("en-PK", "en-001"),
  ("en-PL", "en-150"),
  ("en-PN", "en-001"),
  ("en-PT", "en-150"),
  ("en-PW", "en-001"),
  ("en-RO", "en-150"),
  ("en-RW", "en-001"),
  ("en-SB", "en-001"),
  ("en-SC", "en-001"),
  ("en-SD", "en-001"),
  ("en-SE", "en-150"),
  ("en-SG", "en-001"),
  ("en-SH", "en-001"),
  ("en-SI", "en-150"),
  ("en-SK", "en-150"),
  ("en-SL", "en-001"),
  ("en-SS", "en-001"),
  ("en-SX", "en-001"),
  ("en-SZ", "en-001"),
  ("en-TC", "en-001"),
  ("en-TK", "en-001"),
  ("en-TO", "en-001"),
  ("en-TT", "en-001"),
  ("en-TV", "en-001"),
  ("en-TZ", "en-001"),
  ("en-UA", "en-150"),
  ("en-UG", "en-001"),
  ("en-VC", "en-001"),
  ("en-VG", "en-001"),
  ("en-VU", "en-001"),
  ("en-WS", "en-001"),
  ("en-ZA", "en-001"),
  ("en-ZM", "en-001"),
  ("en-ZW", "en-001"),
  ("es-AR", "es-419"),
  ("es-BO", "es-419"),
  ("es-BR", "es-419"),
  ("es-BZ", "es-419"),
  ("es-CL", "es-419"),
  ("es-CO", "es-419"),
  ("es-CR", "es-419"),
  ("es-CU", "es-419"),
  ("es-DO", "es-419"),
  ("es-EC", "es-419"),
  ("es-GT", "es-419"),
  ("es-HN", "es-419"),
  ("es-MX", "es-419"),
  ("es-NI", "es-419"),
  ("es-PA", "es-419"),
  ("es-PE", "es-419"),
  ("es-PR", "es-419"),
  ("es-PY", "es-419"),
  ("es-SV", "es-419"),
  ("es-US", "es-419"),
  ("es-UY", "es-419"),
  ("es-VE", "es-419"),
  ("ff-Adlm", "und"),
  ("hi-Latn", "en-IN"),
  ("kk-Arab", "und"),
  ("kok-Latn", "und"),
  ("ks-Deva", "und"),
  ("kxv-Deva", "und"),
  ("kxv-Orya", "und"),
  ("kxv-Telu", "und"),
  ("nb", "no"),
  ("nn", "no"),
  ("pa-Arab", "und"),
  ("pt-AO", "pt-PT"),
  ("pt-CH", "pt-PT"),
  ("pt-CV", "pt-PT"),
  ("pt-GQ", "pt-PT"),
  ("pt-GW", "pt-PT"),
  ("pt-LU", "pt-PT"),
  ("pt-MO", "pt-PT"),
  ("pt-MZ", "pt-PT"),
  ("pt-ST", "pt-PT"),
  ("pt-TL", "pt-PT"),
  ("sd-Deva", "und"),
  ("shi-Latn", "und"),
  ("sr-Latn", "und"),
  ("suz-Sunu", "und"),
  ("uz-Arab", "und"),
  ("uz-Cyrl", "und"),
  ("vai-Latn", "und"),
  ("yue-Hans", "und"),
  ("zh-Hant", "und"),
  ("zh-Hant-MO", "zh-Hant-HK"),
]

const localeValues* =
  ",\x1F \x1Fщылэмазэм\x1Fмэзаем\x1Fгъэтхапэм\x1Fмэлылъфэгъум\x1F" &
  "жъоныгъуакӏэм\x1Fмэкъуогъум\x1Fбэдзэогъум\x1Fшышъхьэӏум\x1F" &
  "ӏоныгъум\x1Fчъэпыогъум\x1Fшэкӏогъум\x1Fтыгъэгъазэм\x1Fщылэмаз\x1F" &
  "мэзай\x1Fгъэтхапэ\x1Fмэлылъфэгъу\x1Fжъоныгъуакӏ\x1Fмэкъуогъу\x1F" &
  "бэдзэогъу\x1Fшышъхьэӏу\x1Fӏоныгъу\x1Fчъэпыогъу\x1Fшэкӏогъу\x1F" &
  "тыгъэгъаз\x1Fтхьаумаф\x1Fблыпэ\x1Fгъубдж\x1Fбэрэскэжъый\x1F" &
  "мэфэкъу\x1Fбэрэскэшху\x1Fшэмбэт\x1Fdd.MM.y\x1FMMM y\x1FMMM 'и' d, y 'гъэ'\x1F" &
  "мэфэзакъу\x1F¤#,##0.00\x1F¤#,##0.00;(¤#,##0.00)\x1FJanuarie\x1FFebruarie\x1FMaart\x1FApril\x1F" &
  "Mei\x1FJunie\x1FJulie\x1FAugustus\x1FSeptember\x1FOktober\x1FNovember\x1FDesember\x1FJan.\x1FFeb.\x1FMrt.\x1FApr.\x1F" &
  "Jun.\x1FJul.\x1FAug.\x1FSep.\x1FOkt.\x1FNov.\x1FDes.\x1FSondag\x1FMaandag\x1FDinsdag\x1FWoensdag\x1FDonderdag\x1FVrydag\x1F" &
  "Saterdag\x1FSo.\x1FMa.\x1FDi.\x1FWo.\x1FDo.\x1FVr.\x1FSa.\x1F1ste kwartaal\x1F2de kwartaal\x1F3de kwartaal\x1F4de kwartaal\x1F" &
  "K1\x1FK2\x1FK3\x1FK4\x1Fvm.\x1Fnm.\x1Fv.C.\x1Fn.C.\x1FEEEE dd MMMM y\x1Fdd MMMM y\x1Fdd MMM y\x1FE y-MM-dd\x1FMMMM y\x1F" &
  "d MMM y\x1FE d MMM y\x1Fy-MM-dd G\x1Fdd MMM y G\x1FE dd MMM y G\x1FMM-y\x1Fdd-MM\x1FE d/M\x1Fd MMM\x1FE d MMM\x1F" &
  "d MMMM\x1FMMM y G\x1FQQQ y\x1FQQQQ y\x1Fy G\x1FE d\x1Fh:mm:ss a\x1Fh:mm a\x1Fh:mm:ss a zzzz\x1Fh:mm:ss a z\x1F" &
  "#,##0.00¤\x1Fndzɔ̀ŋɔ̀nùm\x1Fndzɔ̀ŋɔ̀kƗ̀zùʔ\x1Fndzɔ̀ŋɔ̀tƗ̀dʉ̀ghà\x1F" &
  "ndzɔ̀ŋɔ̀tǎafʉ̄ghā\x1Fndzɔ̀ŋèsèe\x1Fndzɔ̀ŋɔ̀nzùghò\x1Fndzɔ̀ŋɔ̀dùmlo\x1F" &
  "ndzɔ̀ŋɔ̀kwîfɔ̀e\x1Fndzɔ̀ŋɔ̀tƗ̀fʉ̀ghàdzughù\x1Fndzɔ̀ŋɔ̀ghǔuwelɔ̀m\x1F" &
  "ndzɔ̀ŋɔ̀chwaʔàkaa wo\x1Fndzɔ̀ŋèfwòo\x1Fnùm\x1Fkɨz\x1Ftɨd\x1Ftaa\x1Fsee\x1Fnzu\x1Fdum\x1Ffɔe\x1F" &
  "dzu\x1Flɔm\x1Fkaa\x1Ffwo\x1Ftsuʔntsɨ\x1Ftsuʔukpà\x1Ftsuʔughɔe\x1Ftsuʔutɔ̀mlò\x1Ftsuʔumè\x1Ftsuʔughɨ̂m\x1F" &
  "tsuʔndzɨkɔʔɔ\x1Fnts\x1Fkpa\x1Fghɔ\x1Ftɔm\x1Fume\x1Fghɨ\x1Fdzk\x1Fkɨbâ kɨ 1\x1Fugbâ u 2\x1Fugbâ u 3\x1F" &
  "ugbâ u 4\x1Fa.g\x1Fa.k\x1FSK\x1FBK\x1FEEEE d MMMM y\x1Fd MMMM y\x1Fd MMM, y\x1Fd/M/y\x1FE d/M/y\x1FM/y\x1Fd/M\x1Fd E\x1F" &
  "m:ss\x1FƆpɛpɔn\x1FƆgyefoɔ\x1FƆbɛnem\x1FOforisuo\x1FKɔtɔnimma\x1FAyɛwohomumu\x1FKutawonsa\x1FƆsanaa\x1F" &
  "Ɛbɔ\x1FAhinime\x1FObubuo\x1FƆpɛnimma\x1FDwoada\x1FBenada\x1FWukuada\x1FYawoada\x1FFiada\x1FMemeneda\x1FKwa\x1F" &
  "Dwo\x1FBen\x1FWuk\x1FYaw\x1FFia\x1FMem\x1FKɔta a ɛdi kan\x1Fkɔta a ɛtɔ so mmienu\x1FKɔta a ɛtɔ so mmiɛnsa\x1F" &
  "Kɔta a ɛtɔ so nnan\x1FKɔta1\x1FKɔta2\x1FKɔta3\x1FKɔta4\x1FAN\x1FANW\x1FAK\x1FKE\x1FEEE, d, MMMM, y\x1Fd, MMMM, y\x1F" &
  "d, MMM, y\x1Fd/M/yy\x1F{1}, {0}\x1Fy/M/d\x1FE, M/d/y\x1FMMM d, y\x1FE, MMM d, y\x1FM/d\x1FE, M/d\x1FE, MMM d\x1F" &
  "ጃንዋሪ\x1Fፌብሩዋሪ\x1Fማርች\x1Fኤፕሪል\x1Fሜይ\x1Fጁን\x1Fጁላይ\x1Fኦገስት\x1F" &
  "ሴፕቴምበር\x1Fኦክቶበር\x1Fኖቬምበር\x1Fዲሴምበር\x1Fጃን\x1Fፌብ\x1F" &
  "ኤፕሪ\x1Fኦገስ\x1Fሴፕቴ\x1Fኦክቶ\x1Fኖቬም\x1Fዲሴም\x1Fእሑድ\x1Fሰኞ\x1Fማክሰኞ\x1F" &
  "ረቡዕ\x1Fሐሙስ\x1Fዓርብ\x1Fቅዳሜ\x1Fማክሰ\x1F1ኛው ሩብ\x1F2ኛው ሩብ\x1F3ኛው ሩብ\x1F" &
  "4ኛው ሩብ\x1Fሩብ1\x1Fሩብ2\x1Fሩብ3\x1Fሩብ4\x1Fጥዋት\x1Fከሰዓት\x1Fዓ/ዓ\x1Fዓ/ም\x1F" &
  "dd/MM/y\x1Fh:mm:ss a zzzz\x1Fh:mm:ss a z\x1Fh:mm:ss a\x1Fh:mm a\x1FE፣ d/M/y\x1FMMM d y\x1FE፣ MMM d y\x1F" &
  "d/M/y GGGGG\x1FMMM d y G\x1FE MMM d y G\x1FE፣ d/M\x1FE፣ MMM d\x1FH\x1Fa h:mm:ss\x1Fa h:mm\x1Fa h\x1F‎%‎\x1F" &
  "‏#,##0.00 ¤;‏-#,##0.00 ¤\x1F؜#,##0.00¤;(؜#,##0.00¤)\x1Fيناير\x1Fفبراير\x1F" &
  "مارس\x1Fأبريل\x1Fمايو\x1Fيونيو\x1Fيوليو\x1Fأغسطس\x1Fسبتمبر\x1Fأكتوبر\x1F" &
  "نوفمبر\x1Fديسمبر\x1Fالأحد\x1Fالاثنين\x1Fالثلاثاء\x1Fالأربعاء\x1F" &
  "الخميس\x1Fالجمعة\x1Fالسبت\x1Fالربع الأول\x1Fالربع الثاني\x1F" &
  "الربع الثالث\x1Fالربع الرابع\x1Fص\x1Fم\x1Fق.م\x1FEEEE، d MMMM y\x1Fdd‏/MM‏/y\x1F" &
  "d‏/M‏/y\x1F{1}، {0}\x1FE، d‏/M‏/y\x1FE، d MMM y\x1Fdd-MM-y GGGGG\x1Fd MMM y G\x1FE، d MMM y G\x1F" &
  "M‏/y\x1Fd‏/M\x1FE، d‏/M\x1FE، d MMM\x1FE، d\x1F.\x1Fجانفي\x1Fفيفري\x1Fأفريل\x1Fماي\x1F" &
  "جوان\x1Fجويلية\x1Fأوت\x1FH:mm:ss zzzz\x1FH:mm:ss z\x1FH:mm:ss\x1FH:mm\x1Fكانون الثاني\x1F" &
  "شباط\x1Fآذار\x1Fنيسان\x1Fأيار\x1Fحزيران\x1Fتموز\x1Fآب\x1Fأيلول\x1Fتشرين الأول\x1F" &
  "تشرين الثاني\x1Fكانون الأول\x1Fتشرين الأول\x1FHH:mm:ss zzzz\x1F" &
  "HH:mm:ss z\x1FHH:mm:ss\x1FHH:mm\x1Fيوليوز\x1Fغشت\x1Fشتنبر\x1Fنونبر\x1Fدجنبر\x1Fإبريل\x1F" &
  "أغشت\x1Fشتمبر\x1Fدجمبر\x1F٪\x1F#,##,##0%\x1F¤ #,##,##0.00\x1Fজানুৱাৰী\x1F" &
  "ফেব্ৰুৱাৰী\x1Fমাৰ্চ\x1Fএপ্ৰিল\x1Fমে’\x1Fজুন\x1F" &
  "জুলাই\x1Fআগষ্ট\x1Fছেপ্তেম্বৰ\x1Fঅক্টোবৰ\x1F" &
  "নৱেম্বৰ\x1Fডিচেম্বৰ\x1Fজানু\x1Fফেব্ৰু\x1Fআগ\x1F" &
  "ছেপ্তে\x1Fঅক্টো\x1Fনৱে\x1Fডিচে\x1Fদেওবাৰ\x1Fসোমবাৰ\x1F" &
  "মঙ্গলবাৰ\x1Fবুধবাৰ\x1Fবৃহস্পতিবাৰ\x1Fশুক্ৰবাৰ\x1F" &
  "শনিবাৰ\x1Fদেও\x1Fসোম\x1Fমঙ্গল\x1Fবুধ\x1Fবৃহ\x1Fশুক্ৰ\x1F" &
  "শনি\x1Fপ্ৰথম তিনিমাহ\x1Fদ্বিতীয় তিনিমাহ\x1F" &
  "তৃতীয় তিনিমাহ\x1Fচতুৰ্থ তিনিমাহ\x1F" &
  "পূৰ্বাহ্ন\x1Fঅপৰাহ্ন\x1Fখ্ৰীঃ পূঃ\x1Fখ্ৰীঃ\x1F" &
  "d MMMM, y\x1Fd-M-y\x1Fa h.mm.ss zzzz\x1Fa h.mm.ss z\x1Fa h.mm.ss\x1Fa h.mm\x1Fdd-MM-y\x1FE, dd-MM-y\x1F#,##0.00 ¤\x1F" &
  "Januari\x1FFebruari\x1FMachi\x1FAprili\x1FJuni\x1FJulai\x1FAgosti\x1FSeptemba\x1FOktoba\x1FNovemba\x1FDesemba\x1FJan\x1F" &
  "Feb\x1FMac\x1FApr\x1FJun\x1FJul\x1FAgo\x1FSep\x1FOkt\x1FNov\x1FDec\x1FJumapili\x1FJumatatu\x1FJumanne\x1FJumatano\x1FAlhamisi\x1F" &
  "Ijumaa\x1FJumamosi\x1FJpi\x1FJtt\x1FJnn\x1FJtn\x1FAlh\x1FIjm\x1FJmo\x1FRobo 1\x1FRobo 2\x1FRobo 3\x1FRobo 4\x1FR1\x1FR2\x1FR3\x1F" &
  "R4\x1Ficheheavo\x1Fichamthi\x1FKM\x1FBM\x1FEEEE, d MMMM y\x1Fde xineru\x1Fde febreru\x1Fde marzu\x1Fd’abril\x1F" &
  "de mayu\x1Fde xunu\x1Fde xunetu\x1Fd’agostu\x1Fde setiembre\x1Fd’ochobre\x1Fde payares\x1Fd’avientu\x1F" &
  "xin\x1Ffeb\x1Fmar\x1Fabr\x1Fmay\x1Fxun\x1Fxnt\x1Fago\x1Fset\x1Foch\x1Fpay\x1Favi\x1Fxineru\x1Ffebreru\x1Fmarzu\x1Fabril\x1Fmayu\x1Fxunu\x1F" &
  "xunetu\x1Fagostu\x1Fsetiembre\x1Fochobre\x1Fpayares\x1Favientu\x1FXin\x1FMar\x1FAbr\x1FMay\x1FXun\x1FXnt\x1FSet\x1FOch\x1FPay\x1F" &
  "Avi\x1Fdomingu\x1Fllunes\x1Fmartes\x1Fmiércoles\x1Fxueves\x1Fvienres\x1Fsábadu\x1Fdom\x1Fllu\x1Fmié\x1Fxue\x1Fvie\x1F" &
  "sáb\x1F1er trimestre\x1F2u trimestre\x1F3er trimestre\x1F4u trimestre\x1F1T\x1F2T\x1F3T\x1F4T\x1Fe.C.\x1Fd.C.\x1F" &
  "EEEE, d MMMM 'de' y\x1Fd MMMM 'de' y\x1FE, d/M/y\x1FLLLL 'de' y\x1FE, d MMM y\x1FE, d MMM y G\x1FE, d/M\x1F" &
  "E, d MMM\x1FQQQQ 'de' y\x1Fyanvar\x1Ffevral\x1Fmart\x1Faprel\x1Fiyun\x1Fiyul\x1Favqust\x1Fsentyabr\x1Foktyabr\x1Fnoyabr\x1F" &
  "dekabr\x1Fyan\x1Ffev\x1Fapr\x1Fiyn\x1Fiyl\x1Favq\x1Fsen\x1Fokt\x1Fnoy\x1Fdek\x1FBazar\x1FBazar ertəsi\x1FÇərşənbə axşamı\x1F" &
  "Çərşənbə\x1FCümə axşamı\x1FCümə\x1FŞənbə\x1FB.\x1FB.e.\x1FÇ.a.\x1FÇ.\x1FC.a.\x1FC.\x1FŞ.\x1F1-ci rüb\x1F" &
  "2-ci rüb\x1F3-cü rüb\x1F4-cü rüb\x1F1-ci kv.\x1F2-ci kv.\x1F3-cü kv.\x1F4-cü kv.\x1Fe.ə.\x1Fb.e.\x1F" &
  "dd.MM.yy\x1Fdd.MM.y, E\x1FG d M y\x1FG d MMM y\x1FG E, d MMM y\x1FMM.y\x1Fdd.MM\x1FE, dd.MM\x1FG MMM y\x1Fјанвар\x1F" &
  "феврал\x1Fмарт\x1Fапрел\x1Fмай\x1Fијун\x1Fијул\x1Fавгуст\x1Fсентјабр\x1F" &
  "октјабр\x1Fнојабр\x1Fдекабр\x1Fјан\x1Fфев\x1Fмар\x1Fапр\x1Fијн\x1Fијл\x1F" &
  "авг\x1Fсен\x1Fокт\x1Fној\x1Fдек\x1FЈанвар\x1FФеврал\x1FМарт\x1FАпрел\x1F" &
  "Май\x1FИјун\x1FИјул\x1FАвгуст\x1FСентјабр\x1FОктјабр\x1FНојабр\x1F" &
  "Декабр\x1Fбазар\x1Fбазар ертәси\x1Fчәршәнбә ахшамы\x1Fчәршәнбә\x1F" &
  "ҹүмә ахшамы\x1Fҹүмә\x1Fшәнбә\x1FБ.\x1FБ.Е.\x1FЧ.А.\x1FЧ.\x1FҸ.А.\x1FҸ.\x1FШ.\x1F1-ҹи квартал\x1F" &
  "2-ҹи квартал\x1F3-ҹү квартал\x1F4-ҹү квартал\x1F1-ҹи кв.\x1F2-ҹи кв.\x1F" &
  "3-ҹү кв.\x1F4-ҹү кв.\x1FАМ\x1FПМ\x1Fе.ә.\x1Fј.е.\x1Fd MMMM y, EEEE\x1FMMM, y\x1Fd MMM y, E\x1F" &
  "G d MMM y, E\x1Fdd.MM, E\x1Fd MMM, E\x1Fғинуар\x1Fфевраль\x1Fапрель\x1Fиюнь\x1F" &
  "июль\x1Fсентябрь\x1Fоктябрь\x1Fноябрь\x1Fдекабрь\x1Fғин.\x1Fфев.\x1F" &
  "мар.\x1Fапр.\x1Fиюн.\x1Fиюл.\x1Fавг.\x1Fсент.\x1Fокт.\x1Fнояб.\x1Fдек.\x1Fйәкшәмбе\x1F" &
  "дүшәмбе\x1Fшишәмбе\x1Fшаршамбы\x1Fкесаҙна\x1Fйома\x1Fшәмбе\x1F" &
  "йәк.\x1Fдүш.\x1Fшиш.\x1Fшар.\x1Fкес.\x1Fйом.\x1Fшәм.\x1F1-се квартал\x1F2-се квартал\x1F" &
  "3-сө квартал\x1F4-се квартал\x1F1-се кв.\x1F2-се кв.\x1F3-сө кв.\x1F" &
  "4-се кв.\x1Fб.э.т.\x1Fб.э.\x1FEEEE, d MMMM y 'й'.\x1Fd MMMM, y 'й'.\x1Fd MMM, y 'й'.\x1F" &
  "MMM, y 'й'.\x1FMMMM, y 'й'.\x1Fd MMM, E, y 'й'.\x1FG dd.MM.y\x1Fd MMM, G y 'й'.\x1Fd MMM, E, G y 'й'.\x1F" &
  "MMM, G y 'й'.\x1FQQQ, y 'й'.\x1FQQQQ, y 'й'.\x1FG y 'й'.\x1FHH 'сәғ'.\x1FJanwari\x1FParwari\x1F" &
  "Márch\x1FAprél\x1FMai\x1FJólái\x1FAgast\x1FSatambar\x1FAktubar\x1FNawambar\x1FDasambar\x1FPar\x1FMár\x1FJól\x1F" &
  "Aga\x1FSat\x1FAkt\x1FNaw\x1FDas\x1FYakshambeh\x1FDoshambeh\x1FSayshambeh\x1FChárshambeh\x1FPanchshambeh\x1FJomah\x1F" &
  "Shambeh\x1FYak\x1FDo\x1FSay\x1FChá\x1FPan\x1FJom\x1FSha\x1Fawali chárek\x1Fdomi chárek\x1Fsayomi chárek\x1Fcháromi chárek\x1F" &
  "1/4\x1F2/4\x1F3/4\x1F4/4\x1Fam\x1Fpm\x1FPM\x1FAD\x1Fdd,MM,y\x1Fhh:mm:ss a zzzz\x1Fhh:mm:ss a zzz\x1Fhh:mm:ss a\x1F" &
  "hh:mm a\x1FMM,dd,y\x1Fh:mm\x1F#,##0 %\x1FKɔndɔŋ\x1FMàcɛ̂l\x1FMàtùmb\x1FMàtop\x1FM̀puyɛ\x1FHìlòndɛ̀\x1F" &
  "Njèbà\x1FHìkaŋ\x1FDìpɔ̀s\x1FBìòôm\x1FMàyɛsèp\x1FLìbuy li ńyèe\x1Fkɔn\x1Fmac\x1Fmat\x1Fmto\x1Fmpu\x1F" &
  "hil\x1Fnje\x1Fhik\x1Fdip\x1Fbio\x1Fliɓ\x1Fŋgwà nɔ̂y\x1Fŋgwà njaŋgumba\x1Fŋgwà ûm\x1Fŋgwà ŋgê\x1F" &
  "ŋgwà mbɔk\x1Fŋgwà kɔɔ\x1Fŋgwà jôn\x1Fnɔy\x1Fnja\x1Fuum\x1Fŋge\x1Fmbɔ\x1Fkɔɔ\x1Fjon\x1FKèk bisu i soŋ iaâ\x1F" &
  "Kèk i ńyonos biɓaà i soŋ iaâ\x1FKèk i ńyonos biaâ i soŋ iaâ\x1FKèk i ńyonos binâ i soŋ iaâ\x1F" &
  "K1s3\x1FK2s3\x1FK3s3\x1FK4s3\x1FI bikɛ̂glà\x1FI ɓugajɔp\x1Fb.Y.K\x1Fm.Y.K\x1Fстудзеня\x1Fлютага\x1F" &
  "сакавіка\x1Fкрасавіка\x1Fмая\x1Fчэрвеня\x1Fліпеня\x1Fжніўня\x1F" &
  "верасня\x1Fкастрычніка\x1Fлістапада\x1Fснежня\x1Fсту\x1Fлют\x1F" &
  "сак\x1Fкра\x1Fчэр\x1Fліп\x1Fжні\x1Fвер\x1Fкас\x1Fліс\x1Fсне\x1Fстудзень\x1Fлюты\x1F" &
  "сакавік\x1Fкрасавік\x1Fчэрвень\x1Fліпень\x1Fжнівень\x1Fверасень\x1F" &
  "кастрычнік\x1Fлістапад\x1Fснежань\x1Fнядзеля\x1Fпанядзелак\x1F" &
  "аўторак\x1Fсерада\x1Fчацвер\x1Fпятніца\x1Fсубота\x1Fнд\x1Fпн\x1Fаў\x1F" &
  "ср\x1Fчц\x1Fпт\x1Fсб\x1F1-шы квартал\x1F2-гі квартал\x1F3-ці квартал\x1F" &
  "4-ты квартал\x1F1-шы кв.\x1F2-гі кв.\x1F3-ці кв.\x1F4-ты кв.\x1Fда н.э.\x1F" &
  "н.э.\x1FEEEE, d MMMM y 'г'.\x1Fd MMMM y 'г'.\x1Fd MMM y 'г'.\x1Fd.MM.yy\x1FHH:mm:ss, zzzz\x1F" &
  "d.M.y\x1FE, d.M.y\x1FLLL y\x1FLLLL y\x1Fdd.MM.y GGGGG\x1Fd MMM y 'г'. G\x1FE, d MMM y 'г'. G\x1F" &
  "M.y\x1Fd.M\x1FE, d.M\x1FLLL y 'г'. G\x1Fy 'г'. G\x1Fhh a\x1Fmm.ss\x1FEpreo\x1FOgasti\x1FDisemba\x1FEpr\x1F" &
  "Oga\x1FDis\x1FPa Mulungu\x1FPalichimo\x1FPalichibuli\x1FPalichitatu\x1FPalichine\x1FPalichisano\x1FPachibelushi\x1F" &
  "uluchelo\x1Fakasuba\x1FBC\x1Fpa mwedzi gwa hutala\x1Fpa mwedzi gwa wuvili\x1Fpa mwedzi gwa wudatu\x1F" &
  "pa mwedzi gwa wutai\x1Fpa mwedzi gwa wuhanu\x1Fpa mwedzi gwa sita\x1Fpa mwedzi gwa saba\x1Fpa mwedzi gwa nane\x1F" &
  "pa mwedzi gwa tisa\x1Fpa mwedzi gwa kumi\x1Fpa mwedzi gwa kumi na moja\x1Fpa mwedzi gwa kumi na mbili\x1F" &
  "Hut\x1FVil\x1FDat\x1FTai\x1FHan\x1FSit\x1FSab\x1FNan\x1FTis\x1FKum\x1FKmj\x1FKmb\x1Fpa mulungu\x1Fpa shahuviluha\x1Fpa hivili\x1F" &
  "pa hidatu\x1Fpa hitayi\x1Fpa hihanu\x1Fpa shahulembela\x1FMul\x1FHiv\x1FHid\x1FHit\x1FHih\x1FLem\x1FLobo 1\x1FLobo 2\x1F" &
  "Lobo 3\x1FLobo 4\x1FL1\x1FL2\x1FL3\x1FL4\x1Fpamilau\x1Fpamunyi\x1F#,##0.00 ¤;(#,##0.00 ¤)\x1Fянуари\x1F" &
  "февруари\x1Fаприл\x1Fюни\x1Fюли\x1Fсептември\x1Fоктомври\x1Fноември\x1F" &
  "декември\x1Fяну\x1Fсеп\x1Fное\x1Fнеделя\x1Fпонеделник\x1Fвторник\x1F" &
  "сряда\x1Fчетвъртък\x1Fпетък\x1Fсъбота\x1Fвт\x1Fчт\x1F1. тримесечие\x1F" &
  "2. тримесечие\x1F3. тримесечие\x1F4. тримесечие\x1F1. трим.\x1F" &
  "2. трим.\x1F3. трим.\x1F4. трим.\x1Fпр.Хр.\x1Fсл.Хр.\x1Fd.MM.y 'г'.\x1Fd.MM.yy 'г'.\x1F" &
  "H:mm:ss 'ч'. zzzz\x1FH:mm:ss 'ч'. z\x1FE, d.MM.y 'г'.\x1FMM.y 'г'.\x1FMMMM y 'г'.\x1F" &
  "dd.MM.y 'г'. GGGGG\x1Fd.MM.y 'г'. G\x1FE, d.MM.y 'г'. G\x1Fd.MM.\x1FE, d.MM.\x1FMM.y 'г'. G\x1F" &
  "QQQ y 'г'.\x1FQQQQ y 'г'.\x1Fy 'г'.\x1FMM.\x1FE, d\x1FHH:mm:ss 'ч'.\x1FHH:mm 'ч'.\x1FHH 'ч'.\x1F" &
  "h:mm:ss 'ч'. a\x1Fh:mm 'ч'. a\x1Fh 'ч'. a\x1Fजनवरी\x1Fफरवरी\x1Fमार्च\x1F" &
  "अप्रैल\x1Fमई\x1Fजून\x1Fजुलाई\x1Fअगस्त\x1Fसितम्बर\x1F" &
  "अक्टूबर\x1Fनवम्बर\x1Fदिसंबर\x1Fऐतवार\x1Fसोमवार\x1F" &
  "मंगलवार\x1Fबुधवार\x1Fबृहस्पतवार\x1Fशुक्रवार\x1F" &
  "शनिवार\x1Fनवंबर\x1Fरबीबार\x1Fसोमबार\x1Fमंगलबार\x1F" &
  "बुधबार\x1Fबृहस्पतिबार\x1Fशुक्रबार\x1Fसनीचर\x1F" &
  " \x1F% #,#0;% -#,#0\x1F¤ #,##0.00;¤ -#,##0.00\x1Fɩjikawǝrka kaŋɔrɔ\x1Fɩjikpaka kaŋɔrɔ\x1F" &
  "arɛ́cika kaŋɔrɔ\x1Fnjɩbɔ nɖʊka kaŋɔrɔ\x1Facafʊnɖuka kaŋɔrɔ\x1Fanɔɔɖuka kaŋɔrɔ\x1F" &
  "alàlaka kaŋɔrɔ\x1Fɩjikǝuka kaŋɔrɔ\x1Fabofʊmka kaŋɔrɔ\x1Fɩjicimka kaŋɔrɔ\x1Facapomka kaŋɔrɔ\x1F" &
  "anɔɔbʊnka kaŋɔrɔ\x1Fkaw\x1Fci\x1Fɖʊ\x1Fɖu5\x1Fɖu6\x1Fla\x1Fkǝu\x1Ffʊm\x1Fcim\x1Fpom\x1Fbʊn\x1Falahaɖɩ\x1F" &
  "aɖɩtɛnɛɛ\x1Fatalaata\x1Falaarba\x1Falaamɩshɩ\x1Farɩsǝma\x1Fasiibi\x1Falah\x1Faɖɩt\x1Fatal\x1Falar\x1F" &
  "alam\x1Farɩs\x1Fasib\x1Fɩŋɔrɩriu ɩsǝbaka\x1Fɩŋɔrɩriu ɩnyɩʊtaja\x1Fɩŋɔrɩriu ɩriutaja\x1F" &
  "ɩŋɔrɩriu ɩnantaja\x1Fɩ1\x1Fɩ2\x1Fɩ3\x1Fɩ4\x1F1ka\x1F2ja\x1FnaaBYŊAƖ\x1FAƖAK\x1FEEEE, MMMM d/y\x1FMMMM d/y\x1F" &
  "MMM d/y\x1FM/d/y\x1FE, MMM d/y\x1FM/d/y G\x1FMMM d/y G\x1FE, MMM d/y G\x1Fzanwuye\x1Ffeburuye\x1Fmarisi\x1Fawirili\x1F" &
  "mɛ\x1Fzuwɛn\x1Fzuluye\x1Futi\x1Fsɛtanburu\x1Fɔkutɔburu\x1Fnowanburu\x1Fdesanburu\x1Fzan\x1Fawi\x1Fzuw\x1Fzul\x1F" &
  "sɛt\x1Fɔku\x1Fnow\x1Fdes\x1Fkari\x1Fntɛnɛ\x1Ftarata\x1Faraba\x1Falamisa\x1Fjuma\x1Fsibiri\x1Fkar\x1Fntɛ\x1Ftar\x1Fara\x1F" &
  "ala\x1Fjum\x1Fsib\x1Fkalo saba fɔlɔ\x1Fkalo saba filanan\x1Fkalo saba sabanan\x1Fkalo saba naaninan\x1F" &
  "KS1\x1FKS2\x1FKS3\x1FKS4\x1FJ.-C. ɲɛ\x1Fni J.-C.\x1FM\x1FMMM\x1F#,##,##0.00¤\x1F#,##,##0.00¤;(#,##,##0.00¤)\x1F" &
  "জানুয়ারি\x1Fফেব্রুয়ারি\x1Fমার্চ\x1Fএপ্রিল\x1F" &
  "মে\x1Fআগস্ট\x1Fসেপ্টেম্বর\x1Fঅক্টোবর\x1Fনভেম্বর\x1F" &
  "ডিসেম্বর\x1Fফেব\x1Fএপ্রি\x1Fজুল\x1Fসেপ\x1Fনভে\x1F" &
  "ডিসে\x1Fসেপ্ট\x1Fরবিবার\x1Fসোমবার\x1Fমঙ্গলবার\x1F" &
  "বুধবার\x1Fবৃহস্পতিবার\x1Fশুক্রবার\x1Fশনিবার\x1F" &
  "রবি\x1Fবৃহস্পতি\x1Fশুক্র\x1F১ম ত্রৈমাসিক\x1F" &
  "২য় ত্রৈমাসিক\x1F৩য় ত্রৈমাসিক\x1F৪র্থ ত্রৈমাসিক\x1F" &
  "খ্রিস্টপূর্ব\x1Fখ্রি.\x1FEEEE, d MMMM, y\x1FE, d MMM, y\x1Fd MMM, y G\x1F" &
  "E, d MMM, y G\x1F¤#,##,##0.00\x1F¤#,##,##0.00;(¤#,##,##0.00)\x1Fসেপ্টেঃ\x1Fঅক্টোঃ\x1F" &
  "নভেঃ\x1Fডিসেঃ\x1Fখ্রিঃপূঃ\x1Fখ্রিঃ\x1Fཟླ་བ་དང་པོ\x1F" &
  "ཟླ་བ་གཉིས་པ\x1Fཟླ་བ་གསུམ་པ\x1Fཟླ་བ་བཞི་པ\x1F" &
  "ཟླ་བ་ལྔ་པ\x1Fཟླ་བ་དྲུག་པ\x1Fཟླ་བ་བདུན་པ\x1F" &
  "ཟླ་བ་བརྒྱད་པ\x1Fཟླ་བ་དགུ་པ\x1Fཟླ་བ་བཅུ་པ\x1F" &
  "ཟླ་བ་བཅུ་གཅིག་པ\x1Fཟླ་བ་བཅུ་གཉིས་པ\x1F" &
  "ཟླ་༡\x1Fཟླ་༢\x1Fཟླ་༣\x1Fཟླ་༤\x1Fཟླ་༥\x1Fཟླ་༦\x1Fཟླ་༧\x1F" &
  "ཟླ་༨\x1Fཟླ་༩\x1Fཟླ་༡༠\x1Fཟླ་༡༡\x1Fཟླ་༡༢\x1Fཟླ་བ་དང་པོ་\x1F" &
  "ཟླ་བ་གཉིས་པ་\x1Fཟླ་བ་གསུམ་པ་\x1Fཟླ་བ་བཞི་པ་\x1F" &
  "ཟླ་བ་ལྔ་པ་\x1Fཟླ་བ་དྲུག་པ་\x1Fཟླ་བ་བདུན་པ་\x1F" &
  "ཟླ་བ་བརྒྱད་པ་\x1Fཟླ་བ་དགུ་པ་\x1Fཟླ་བ་བཅུ་པ་\x1F" &
  "ཟླ་བ་བཅུ་གཅིག་པ་\x1Fཟླ་བ་བཅུ་གཉིས་པ་\x1F" &
  "གཟའ་ཉི་མ་\x1Fགཟའ་ཟླ་བ་\x1Fགཟའ་མིག་དམར་\x1F" &
  "གཟའ་ལྷག་པ་\x1Fགཟའ་ཕུར་བུ་\x1Fགཟའ་པ་སངས་\x1F" &
  "གཟའ་སྤེན་པ་\x1Fཉི་མ་\x1Fཟླ་བ་\x1Fམིག་དམར་\x1F" &
  "ལྷག་པ་\x1Fཕུར་བུ་\x1Fཔ་སངས་\x1Fསྤེན་པ་\x1F" &
  "དུས་ཚིགས་དང་པོ།\x1Fདུས་ཚིགས་གཉིས་པ།\x1F" &
  "དུས་ཚིགས་གསུམ་པ།\x1Fདུས་ཚིགས་བཞི་པ།\x1F" &
  "སྔ་དྲོ་\x1Fཕྱི་དྲོ་\x1Fསྤྱི་ལོ་སྔོན་\x1F" &
  "སྤྱི་ལོ་\x1Fy MMMMའི་ཚེས་d, EEEE\x1Fསྤྱི་ལོ་y MMMMའི་ཚེས་d\x1F" &
  "y ལོའི་MMMཚེས་d\x1Fy LLL\x1FMMMཚེས་d\x1FMMMཚེས་d, E\x1FMMMMའི་ཚེས་d\x1F" &
  "G y LLLL\x1FGenver\x1FCʼhwevrer\x1FMeurzh\x1FEbrel\x1FMae\x1FMezheven\x1FGouere\x1FEost\x1FGwengolo\x1FHere\x1FDu\x1F" &
  "Kerzu\x1FGen.\x1FCʼhwe.\x1FMeur.\x1FEbr.\x1FMezh.\x1FGoue.\x1FGwen.\x1FKzu.\x1FSul\x1FLun\x1FMercʼher\x1FYaou\x1FGwener\x1F" &
  "Sadorn\x1FMeu.\x1FMer.\x1FGwe.\x1FSad.\x1F1añ trimiziad\x1F2l trimiziad\x1F3e trimiziad\x1F4e trimiziad\x1F" &
  "1añ trim.\x1F2l trim.\x1F3e trim.\x1F4e trim.\x1FA.M.\x1FG.M.\x1Fa-raok J.K.\x1Fgoude J.K.\x1FE dd/MM/y\x1F" &
  "dd/MM/y G\x1FE d MMM y G\x1FMM/y\x1Fdd/MM\x1FE dd/MM\x1FMM\x1Fजानुवारी\x1Fफेब्रूवारी\x1F" &
  "एप्रिल\x1Fमे\x1Fजुन\x1Fआगष्ट\x1Fसेप्थेम्बर\x1F" &
  "अक्ट’बर\x1Fनवेम्बर\x1Fडिसेम्बर\x1Fजान\x1Fफेब\x1F" &
  "एप्रि\x1Fजुल\x1Fआग\x1Fसेप\x1Fअक्ट’\x1Fनवे\x1Fडिसे\x1F" &
  "रबिबार\x1Fसमबार\x1Fबिस्थिबार\x1Fसुखुरबार\x1F" &
  "सनिबार\x1Fरबि\x1Fसम\x1Fमंगल\x1Fबुध\x1Fबिस्थि\x1Fसुखुर\x1F" &
  "सनि\x1Fब्रै बाहागोनि सेथि खोन्दो\x1Fब्रै बाहागोनि नैथि खोन्दो\x1F" &
  "ब्रै बाहागोनि थामथि खोन्दो\x1Fब्रै बाहागोनि ब्रैथि खोन्दो\x1F" &
  "किउ 1\x1Fकिउ 2\x1Fकिउ 3\x1Fकिउ 4\x1Fफुं\x1Fबेलासे\x1Fबि.सि.\x1F" &
  "ए.दि\x1Fa h:mm:ss zzzz\x1Fa h:mm:ss z\x1Fa नि h:mm\x1FGGGGG dd-MM-y\x1FG y MMM E d\x1Fd-MMM\x1F" &
  "Gy\x1Fa नि h\x1Fjanuar\x1Ffebruar\x1Fapril\x1Fmaj\x1Fjuni\x1Fjuli\x1Faugust\x1Fseptembar\x1Foktobar\x1Fnovembar\x1F" &
  "decembar\x1Fjan\x1Fjun\x1Fjul\x1Faug\x1Fsep\x1Fnov\x1Fdec\x1Fnedjelja\x1Fponedjeljak\x1Futorak\x1Fsrijeda\x1Fčetvrtak\x1F" &
  "petak\x1Fsubota\x1Fned\x1Fpon\x1Futo\x1Fsri\x1Fčet\x1Fpet\x1Fsub\x1FPrvi kvartal\x1FDrugi kvartal\x1FTreći kvartal\x1F" &
  "Četvrti kvartal\x1FKV1\x1FKV2\x1FKV3\x1FKV4\x1Fa. m.\x1Fp. m.\x1Fp. n. e.\x1Fn. e.\x1FEEEE, d. MMMM y.\x1F" &
  "d. MMMM y.\x1Fd. MMM y.\x1Fd. M. y.\x1FE, d. M. y.\x1FMMM y.\x1FLLLL y.\x1FE, d. MMM y.\x1Fd. M. y. G\x1F" &
  "d. MMM y. G\x1FE, d. MMM y. G\x1FMM. y.\x1Fd. M.\x1FE, d. M.\x1Fd. MMM\x1FE, d. MMM\x1Fd. MMMM\x1FMMM y. G\x1F" &
  "QQQ y.\x1FQQQQ y.\x1Fy. G\x1Fy.\x1Fd.\x1FE, d.\x1Fјануар\x1Fфебруар\x1Fмај\x1Fјуни\x1Fјули\x1F" &
  "аугуст\x1Fсептембар\x1Fоктобар\x1Fновембар\x1Fдецембар\x1F" &
  "феб\x1Fјун\x1Fјул\x1Fауг\x1Fнов\x1Fдец\x1Fнедјеља\x1Fпонедјељак\x1Fуторак\x1F" &
  "сриједа\x1Fчетвртак\x1Fпетак\x1Fнед\x1Fпон\x1Fуто\x1Fсри\x1Fчет\x1Fпет\x1F" &
  "суб\x1FПрво тромесечје\x1FДруго тромесечје\x1FТреће тромесечје\x1F" &
  "Четврто тромесечје\x1FК1\x1FК2\x1FК3\x1FК4\x1Fпре подне\x1Fпоподне\x1F" &
  "п. н. е.\x1Fн. е.\x1FEEEE, dd. MMMM y.\x1Fdd. MMMM y.\x1Fdd.MM.y.\x1Fd.M.yy.\x1FE, dd.MM.y.\x1FMMMM y.\x1F" &
  "dd. MMM y.\x1FE, dd. MMM y.\x1Fdd. MMM y. G\x1FE, dd. MMM y. G\x1FMM.y.\x1Fdd.MM.\x1FE, dd.MM.\x1Fdd. MMM\x1F" &
  "E, dd. MMM\x1Fнэгэдүгээр һара\x1Fхоёрдугаар һара\x1Fгурбадугаар һара\x1F" &
  "дүрбэдүгээр һара\x1Fтабадугаар һара\x1Fзургадугаар һара\x1F" &
  "долодугаар һара\x1Fнаймадугаар һара\x1Fюһэдүгээр һара\x1F" &
  "арбадугаар һара\x1Fарбан нэгэдүгээр һара\x1Fарбан хоёрдугаар һара\x1F" &
  "нима\x1Fдабаа\x1Fмигмар\x1Fһарба\x1Fпүрбэ\x1Fбаасан\x1Fбимба\x1Fy 'оной' MMMM\x1F" &
  "y 'оной' MM 'һарын' d\x1Fy 'оной' MM 'һарын' d, E\x1FG y MM 'һарын' d\x1F" &
  "G y MM 'һарын' d, E\x1FMM 'һарын' d\x1FE, MM 'һарын' d\x1Fde gener\x1Fde febrer\x1F" &
  "de març\x1Fde maig\x1Fde juny\x1Fde juliol\x1Fd’agost\x1Fde setembre\x1Fd’octubre\x1Fde novembre\x1F" &
  "de desembre\x1Fde gen.\x1Fde febr.\x1Fd’abr.\x1Fde jul.\x1Fd’ag.\x1Fde set.\x1Fd’oct.\x1Fde nov.\x1Fde des.\x1F" &
  "gener\x1Ffebrer\x1Fmarç\x1Fmaig\x1Fjuny\x1Fjuliol\x1Fagost\x1Fsetembre\x1Foctubre\x1Fnovembre\x1Fdesembre\x1Fgen.\x1F" &
  "febr.\x1Fabr.\x1Fjul.\x1Fag.\x1Fset.\x1Foct.\x1Fnov.\x1Fdes.\x1Fdiumenge\x1Fdilluns\x1Fdimarts\x1Fdimecres\x1Fdijous\x1F" &
  "divendres\x1Fdissabte\x1Fdg.\x1Fdl.\x1Fdt.\x1Fdc.\x1Fdj.\x1Fdv.\x1Fds.\x1F1r trimestre\x1F2n trimestre\x1F3r trimestre\x1F" &
  "4t trimestre\x1FaC\x1FdC\x1FEEEE, d MMMM 'del' y\x1Fd MMMM 'del' y\x1FH:mm:ss (zzzz)\x1FLLL 'del' y\x1F" &
  "LLLL 'del' y\x1Fd MMM 'del' y\x1Fd MMM 'del' y G\x1FE, d MMM 'del' y G\x1FLLL y G\x1FQQQQ 'del' y\x1F" &
  "𑄎𑄚𑄪𑄠𑄢𑄨\x1F𑄜𑄬𑄛𑄴𑄝𑄳𑄢𑄪𑄠𑄢𑄨\x1F𑄟𑄢𑄴𑄌𑄧\x1F" &
  "𑄃𑄬𑄛𑄳𑄢𑄨𑄣𑄴\x1F𑄟𑄬\x1F𑄎𑄪𑄚𑄴\x1F𑄎𑄪𑄣𑄭\x1F𑄃𑄉𑄧𑄌𑄴𑄑𑄴\x1F" &
  "𑄥𑄬𑄛𑄴𑄑𑄬𑄟𑄴𑄝𑄧𑄢𑄴\x1F𑄃𑄧𑄇𑄴𑄑𑄬𑄝𑄧𑄢𑄴\x1F" &
  "𑄚𑄧𑄞𑄬𑄟𑄴𑄝𑄧𑄢𑄴\x1F𑄓𑄨𑄥𑄬𑄟𑄴𑄝𑄧𑄢𑄴\x1F" &
  "𑄎𑄚𑄪\x1F𑄜𑄬𑄛𑄴\x1F𑄃𑄧𑄇𑄴𑄑𑄮𑄝𑄧𑄢𑄴\x1F𑄓𑄨𑄥𑄬𑄟𑄴𑄝𑄢𑄴\x1F" &
  "𑄢𑄧𑄝𑄨𑄝𑄢𑄴\x1F𑄥𑄧𑄟𑄴𑄝𑄢𑄴\x1F𑄟𑄧𑄁𑄉𑄧𑄣𑄴𑄝𑄢𑄴\x1F" &
  "𑄝𑄪𑄖𑄴𑄝𑄢𑄴\x1F𑄝𑄳𑄢𑄨𑄥𑄪𑄛𑄴𑄝𑄢𑄴\x1F𑄥𑄪𑄇𑄴𑄇𑄮𑄢𑄴𑄝𑄢𑄴\x1F" &
  "𑄥𑄧𑄚𑄨𑄝𑄢𑄴\x1F𑄢𑄧𑄝𑄨\x1F𑄥𑄧𑄟𑄴\x1F𑄟𑄧𑄁𑄉𑄧𑄣𑄴\x1F" &
  "𑄝𑄪𑄖𑄴\x1F𑄝𑄳𑄢𑄨𑄥𑄪𑄛𑄴\x1F𑄥𑄪𑄇𑄴𑄇𑄮𑄢𑄴\x1F" &
  "𑄥𑄧𑄚𑄨\x1F𑄖𑄨𑄚𑄴𑄟𑄎𑄧𑄢𑄴\x1F𑄘𑄨 𑄛𑄳𑄆𑄘𑄳𑄠𑄬 𑄖𑄨𑄚𑄴𑄟𑄎𑄧𑄢𑄴\x1F" &
  "𑄖𑄨𑄚𑄴 𑄛𑄳𑄆𑄘𑄳𑄠𑄬 𑄖𑄨𑄚𑄴𑄟𑄎𑄧𑄢𑄴\x1F" &
  "𑄌𑄳𑄆𑄬𑄢𑄴 𑄛𑄳𑄆𑄘𑄳𑄠𑄬 𑄖𑄨𑄚𑄴𑄟𑄎𑄧𑄢𑄴\x1F" &
  "𑄈𑄳𑄢𑄨𑄌𑄴𑄑𑄴𑄛𑄫𑄢𑄴𑄝𑄧\x1F𑄈𑄳𑄢𑄨𑄌𑄴𑄑𑄛𑄴𑄘𑄧\x1F" &
  "E, d-M\x1Fянварь\x1Fянв\x1Fиюн\x1Fиюл\x1Fноя\x1FкӀира\x1Fоршот\x1Fшинара\x1F" &
  "кхаара\x1Fеара\x1FпӀераска\x1Fшуот\x1FкӀи\x1Fор\x1Fши\x1Fкха\x1Fеа\x1FпӀе\x1F" &
  "шуо\x1F1-гӀа квартал\x1F2-гӀа квартал\x1F3-гӀа квартал\x1F4-гӀа квартал\x1F" &
  "1-гӀа кв.\x1F2-гӀа кв.\x1F3-гӀа кв.\x1F4-гӀа кв.\x1Fв. э. тӀ. я\x1Fв. э\x1F" &
  "Enero\x1FPebrero\x1FMarso\x1FAbril\x1FMayo\x1FHunyo\x1FHulyo\x1FAgosto\x1FSeptiyembre\x1FOktubre\x1FNobyembre\x1FDisyembre\x1F" &
  "Ene\x1FPeb\x1FHun\x1FHul\x1FNob\x1FDomingo\x1FLunes\x1FMartes\x1FMiyerkules\x1FHuwebes\x1FBiyernes\x1FSabado\x1FDom\x1FMiy\x1F" &
  "Huw\x1FBiy\x1Fika-1 nga quarter\x1Fika-2 nga quarter\x1Fika-3 nga quarter\x1Fika-4 nga quarter\x1FEEEE, MMMM d, y\x1F" &
  "MMMM d, y\x1FM/d/yy\x1FMMM d, y G\x1FE, MMM d, y G\x1FOkwokubanza\x1FOkwakabiri\x1FOkwakashatu\x1FOkwakana\x1F" &
  "Okwakataana\x1FOkwamukaaga\x1FOkwamushanju\x1FOkwamunaana\x1FOkwamwenda\x1FOkwaikumi\x1FOkwaikumi na kumwe\x1F" &
  "Okwaikumi na ibiri\x1FKBZ\x1FKBR\x1FKST\x1FKKN\x1FKTN\x1FKMK\x1FKMS\x1FKMN\x1FKMW\x1FKKM\x1FKNK\x1FKNB\x1FSande\x1FOrwokubanza\x1F" &
  "Orwakabiri\x1FOrwakashatu\x1FOrwakana\x1FOrwakataano\x1FOrwamukaaga\x1FSAN\x1FORK\x1FOKB\x1FOKS\x1FOKN\x1FOKT\x1FOMK\x1F" &
  "KWOTA 1\x1FKWOTA 2\x1FKWOTA 3\x1FKWOTA 4\x1FᎤᏃᎸᏔᏅ\x1FᎧᎦᎵ\x1FᎠᏅᏱ\x1FᎧᏬᏂ\x1FᎠᏂᏍᎬᏘ\x1F" &
  "ᏕᎭᎷᏱ\x1FᎫᏰᏉᏂ\x1FᎦᎶᏂ\x1FᏚᎵᏍᏗ\x1FᏚᏂᏅᏗ\x1FᏅᏓᏕᏆ\x1FᎥᏍᎩᏱ\x1F" &
  "ᎤᏃ\x1FᎧᎦ\x1FᎠᏅ\x1FᎧᏬ\x1FᎠᏂ\x1FᏕᎭ\x1FᎫᏰ\x1FᎦᎶ\x1FᏚᎵ\x1FᏚᏂ\x1FᏅᏓ\x1FᎥᏍ\x1F" &
  "ᎤᎾᏙᏓᏆᏍᎬ\x1FᎤᎾᏙᏓᏉᏅᎯ\x1FᏔᎵᏁᎢᎦ\x1FᏦᎢᏁᎢᎦ\x1FᏅᎩᏁᎢᎦ\x1F" &
  "ᏧᎾᎩᎶᏍᏗ\x1FᎤᎾᏙᏓᏈᏕᎾ\x1FᏆᏍᎬ\x1FᏉᏅᎯ\x1FᏔᎵᏁ\x1FᏦᎢᏁ\x1F" &
  "ᏅᎩᏁ\x1FᏧᎾᎩ\x1FᏈᏕᎾ\x1F1st ᎩᏄᏙᏗ\x1F2nd ᎩᏄᏙᏗ\x1F3rd ᎩᏄᏙᏗ\x1F" &
  "4th ᎩᏄᏙᏗ\x1FᏌᎾᎴ\x1FᏒᎯᏱᎢ\x1Fکانوونی دووەم\x1Fشوبات\x1Fئازار\x1F" &
  "نیسان\x1Fئایار\x1Fحوزەیران\x1Fتەمووز\x1Fئاب\x1Fئەیلوول\x1Fتشرینی یەکەم\x1F" &
  "تشرینی دووەم\x1Fکانونی یەکەم\x1Fیەکشەممە\x1Fدووشەممە\x1F" &
  "سێشەممە\x1Fچوارشەممە\x1Fپێنجشەممە\x1Fھەینی\x1Fشەممە\x1Fچارەکی یەکەم\x1F" &
  "چارەکی دووەم\x1Fچارەکی سێەم\x1Fچارەکی چوارەم\x1Fچ١\x1Fچ٢\x1F" &
  "چ٣\x1Fچ٤\x1Fب.ن\x1Fد.ن\x1Fپێش زایین\x1Fزایینی\x1Fdی MMMMی y\x1FE، d/M/y\x1FMMMی y\x1F" &
  "dی MMMی y\x1FE، dی MMMی y\x1FE، M/d\x1Fdی MMM\x1FE، dی MMM\x1FE dھەم\x1Fhی a\x1Fⲓⲁⲛⲟⲩⲁ̀ⲣⲓⲟⲥ\x1F" &
  "ⲫⲉⲃⲣⲟⲩⲁ̀ⲣⲓⲟⲥ\x1Fⲙⲁⲣⲧⲟⲥ\x1Fⲁ̀ⲡⲣⲓⲗⲓⲟⲥ\x1F" &
  "ⲙⲁⲓⲟⲥ\x1Fⲓⲟⲩⲛⲓⲟⲥ\x1Fⲓⲟⲩⲗⲓⲟⲥ\x1Fⲁⲩⲅⲟⲩⲥⲧⲟⲥ\x1F" &
  "ⲥⲉⲡⲧⲉⲙⲃⲣⲓⲟⲥ\x1Fⲟ̀ⲕⲧⲟⲙⲃⲣⲓⲟⲥ\x1Fⲛⲟⲉⲙⲃⲣⲓⲟⲥ\x1F" &
  "ⲇⲉⲕⲉⲙⲃⲣⲓⲟⲥ\x1Fⲓ̅ⲁ̅ⲛ̅\x1Fⲫ̅ⲉ̅ⲃ̅\x1Fⲙ̅ⲁ̅ⲣ̅\x1Fⲁ̅ⲡ̅ⲣ̅\x1F" &
  "ⲙ̅ⲁ̅ⲓ̅\x1Fⲓ̅ⲩ̅ⲛ̅\x1Fⲓ̅ⲩ̅ⲗ̅\x1Fⲁ̅ⲩ̅ⲅ̅\x1Fⲥ̅ⲉ̅ⲡ̅\x1Fⲟ̅ⲕ̅ⲧ̅\x1F" &
  "ⲛ̅ⲟ̅ⲉ̅\x1Fⲇ̅ⲉ̅ⲕ̅\x1Fϯⲕⲩⲣⲓⲁ̀ⲕⲏ\x1Fⲡⲓⲥⲛⲁⲩ\x1Fⲡⲓϣⲟⲙⲧ\x1F" &
  "ⲡⲓϥⲧⲱⲟⲩ\x1Fⲡⲓⲧⲓⲟⲩ\x1Fϯⲡⲁⲣⲁⲥⲕⲉⲩⲏ̀\x1Fⲡⲓⲥⲁⲃⲃⲁⲧⲟⲛ\x1F" &
  "ⲡⲓⲁ̅\x1Fⲡⲓⲃ̅\x1Fⲡⲓⲅ̅\x1Fⲡⲓⲇ̅\x1Fⲡⲓⲉ̅\x1Fⲡⲓⲋ̅\x1Fⲡⲓⲍ̅\x1F" &
  "ⲡⲓϩⲟⲩⲓⲧ ⲛ̀ⲣⲉϥⲧⲟⲩ\x1Fⲡⲓⲙⲁϩⲥ̀ⲛⲁⲩ ⲛ̀ⲣⲉϥⲧⲟⲩ\x1F" &
  "ⲡⲓⲙⲁϩϣⲟⲙⲧ ⲛ̀ⲣⲉϥⲧⲟⲩ\x1Fⲡⲓⲙⲁϩϥ̀ⲧⲟⲩ ⲛ̀ⲣⲉϥⲧⲟⲩ\x1F" &
  "ⲡⲓⲁ̅ ⲛ̀ⲣⲉϥⲧⲟⲩ\x1Fⲡⲓⲙⲁϩⲃ︦ ⲛ̀ⲣⲉϥⲧⲟⲩ\x1Fⲡⲓⲙⲁϩⲅ︦ ⲛ̀ⲣⲉϥⲧⲟⲩ\x1F" &
  "ⲡⲓⲙⲁϩⲇ︦ ⲛ̀ⲣⲉϥⲧⲟⲩ\x1Fϧⲙ\x1Fⲙⲙ\x1Fϧⲁϫⲉⲛ ⲡⲭ︦ⲥ︦\x1F" &
  "⳪︦\x1FGGGGG y-MM-dd\x1Fledna\x1Fúnora\x1Fbřezna\x1Fdubna\x1Fkvětna\x1Fčervna\x1Fčervence\x1Fsrpna\x1Fzáří\x1F" &
  "října\x1Flistopadu\x1Fprosince\x1Fled\x1Fúno\x1Fbře\x1Fdub\x1Fkvě\x1Fčvn\x1Fčvc\x1Fsrp\x1Fzář\x1Fříj\x1Flis\x1Fpro\x1F" &
  "leden\x1Fúnor\x1Fbřezen\x1Fduben\x1Fkvěten\x1Fčerven\x1Fčervenec\x1Fsrpen\x1Fříjen\x1Flistopad\x1Fprosinec\x1F" &
  "neděle\x1Fpondělí\x1Fúterý\x1Fstředa\x1Fčtvrtek\x1Fpátek\x1Fsobota\x1Fne\x1Fpo\x1Fút\x1Fst\x1Fčt\x1Fpá\x1Fso\x1F" &
  "1. čtvrtletí\x1F2. čtvrtletí\x1F3. čtvrtletí\x1F4. čtvrtletí\x1Fdop.\x1Fodp.\x1Fpř. n. l.\x1F" &
  "n. l.\x1FEEEE d. MMMM y\x1Fd. MMMM y\x1Fd. M. y\x1FH:mm:ss, zzzz\x1FE d. M. y\x1Fd. M. y GGGGG\x1Fd. M. y G\x1F" &
  "E d. M. y G\x1FE d. M.\x1FLLLL y G\x1FE d.\x1Fᐅᒉᒥᑮᓯᑳᐏᐲᓯᒼ\x1Fᐸᐚᐦᒐᑭᓇᓰᐢ\x1F" &
  "ᒥᑭᓯᐏᐲᓯᒼ\x1Fᓂᐢᑭᐲᓯᒼ\x1Fᐊᓃᑭᐲᓯᒼ\x1Fᐚᐏᐲᓯᒼ\x1Fᐹᐢᑲᐦᐋᐏᐲᓯᒼ\x1F" &
  "ᐅᐸᐦᐅᐏᐲᓯᒼ\x1Fᓄᒌᑐᐏᐲᓯᒼ\x1Fᐱᓈᐢᑯᐏᐲᓯᒼ\x1Fᐋᕽᐘᑎᓄᐏᐲᓯᒼ\x1F" &
  "ᒪᑯᓭᑮᓭᑳᐏᐲᓯᒼ\x1Fᐊᔭᒥᐦᐁᑮᓯᑳᐤ\x1Fᐴᓂ ᐊᔭᒥᐦᐁᑮᓯᑳᐤ\x1F" &
  "ᓃᓱᑮᓯᑳᐤ\x1Fᐋᐱᐦᑕᐘᐣ\x1Fᐴᓂᐋᐱᐦᑕᐘᐣ\x1Fᑫᑳᐨ ᒫᑎᓇᐍᑮᓯᑳᐤ\x1F" &
  "ᒫᑎᓇᐍᑮᓯᑳᐤ\x1Fᐊᒼ\x1Fᐲᒼ\x1Fкӑрлач\x1Fнарӑс\x1Fпуш\x1Fака\x1Fҫу\x1F" &
  "ҫӗртме\x1Fутӑ\x1Fҫурла\x1Fавӑн\x1Fюпа\x1Fчӳк\x1Fраштав\x1Fкӑр.\x1Fнар.\x1F" &
  "ҫӗрт.\x1Fҫур.\x1Fраш.\x1Fвырсарни кун\x1Fтунти кун\x1Fытлари кун\x1F" &
  "юн кун\x1Fкӗҫнерни кун\x1Fэрне кун\x1Fшӑмат кун\x1Fвр\x1Fтн\x1Fыт\x1F" &
  "юн\x1Fкҫ\x1Fэр\x1Fшм\x1F1-мӗш чӗрӗк\x1F2-мӗш чӗрӗк\x1F3-мӗш чӗрӗк\x1F4-мӗш чӗрӗк\x1F" &
  "1-мӗш чӗр.\x1F2-мӗш чӗр.\x1F3-мӗш чӗр.\x1F4-мӗш чӗр.\x1Fк. у.\x1Fк. х.\x1F" &
  "х. с-ч.\x1Fх. с.\x1Fy, MMMM, d, EEEE\x1Fy, MMMM, d\x1Fy, MMM, d\x1Fy.MM.dd\x1FHH:mm:ss (zzzz)\x1F" &
  "HH:mm:ss (z)\x1Fy.MM.dd (ccc)\x1Fy, MMM\x1Fy, MMMM\x1Fy, MMM, d, E\x1FG y.MM.dd\x1FG y, MMM, d\x1FG y, MMM, d, E\x1F" &
  "y.MM\x1FMM.dd\x1FMM.dd (E)\x1FMMM, d\x1FMMM, d, E\x1FMMMM, d\x1FG y, MMM\x1Fy, QQQ\x1Fy, QQQQ\x1Fd, ccc\x1FHH 'сех'\x1F" &
  "a h:mm:ss\x1Fa h:mm\x1Fa h\x1FIonawr\x1FChwefror\x1FMawrth\x1FEbrill\x1FMehefin\x1FGorffennaf\x1FAwst\x1F" &
  "Medi\x1FHydref\x1FTachwedd\x1FRhagfyr\x1FIon\x1FChwef\x1FMaw\x1FEbr\x1FMeh\x1FGorff\x1FHyd\x1FTach\x1FRhag\x1FChw\x1FGor\x1FDydd Sul\x1F" &
  "Dydd Llun\x1FDydd Mawrth\x1FDydd Mercher\x1FDydd Iau\x1FDydd Gwener\x1FDydd Sadwrn\x1FLlun\x1FMer\x1FIau\x1F" &
  "Gwen\x1FSad\x1Fchwarter 1af\x1F2il chwarter\x1F3ydd chwarter\x1F4ydd chwarter\x1FCh1\x1FCh2\x1FCh3\x1FCh4\x1FCC\x1F" &
  "OC\x1Fdd/MM/yy\x1Fmarts\x1Fseptember\x1Foktober\x1Fnovember\x1Fdecember\x1Fjan.\x1Ffeb.\x1Fmar.\x1Fapr.\x1Fjun.\x1Faug.\x1F" &
  "sep.\x1Fokt.\x1Fdec.\x1Fsøndag\x1Fmandag\x1Ftirsdag\x1Fonsdag\x1Ftorsdag\x1Ffredag\x1Flørdag\x1Fsøn.\x1Fman.\x1Ftirs.\x1F" &
  "ons.\x1Ftors.\x1Ffre.\x1Flør.\x1F1. kvartal\x1F2. kvartal\x1F3. kvartal\x1F4. kvartal\x1F1. kvt.\x1F2. kvt.\x1F" &
  "3. kvt.\x1F4. kvt.\x1Ff.Kr.\x1Fe.Kr.\x1FEEEE 'den' d. MMMM y\x1Fd. MMM y\x1FHH.mm.ss zzzz\x1FHH.mm.ss z\x1F" &
  "HH.mm.ss\x1FHH.mm\x1FE d.M.y\x1FE d. MMM y\x1Fd.M.y GGGGG\x1Fd. MMM y G\x1FE d. MMM y G\x1FE d.M\x1FE d. MMM\x1F" &
  "E 'den' d.\x1Fh.mm.ss a\x1Fh.mm a\x1FMori ghwa imbiri\x1FMori ghwa kawi\x1FMori ghwa kadadu\x1F" &
  "Mori ghwa kana\x1FMori ghwa kasanu\x1FMori ghwa karandadu\x1FMori ghwa mfungade\x1FMori ghwa wunyanya\x1F" &
  "Mori ghwa ikenda\x1FMori ghwa ikumi\x1FMori ghwa ikumi na imweri\x1FMori ghwa ikumi na iwi\x1F" &
  "Imb\x1FKaw\x1FKad\x1FKan\x1FKas\x1FKar\x1FMfu\x1FWun\x1FIke\x1FIku\x1FImw\x1FIwi\x1FItuku ja jumwa\x1FKuramuka jimweri\x1FKuramuka kawi\x1F" &
  "Kuramuka kadadu\x1FKuramuka kana\x1FKuramuka kasanu\x1FKifula nguwo\x1FJum\x1FJim\x1FNgu\x1FKimu cha imbiri\x1F" &
  "Kimu cha kawi\x1FKimu cha kadadu\x1FKimu cha kana\x1FLuma lwa K\x1Fluma lwa p\x1FKK\x1FJanuar\x1F" &
  "Februar\x1FMärz\x1FJuli\x1FAugust\x1FDezember\x1FSept.\x1FDez.\x1FMär\x1FAug\x1FDez\x1FSonntag\x1FMontag\x1FDienstag\x1F" &
  "Mittwoch\x1FDonnerstag\x1FFreitag\x1FSamstag\x1FMo.\x1FMi.\x1FFr.\x1F1. Quartal\x1F2. Quartal\x1F3. Quartal\x1F" &
  "4. Quartal\x1Fv. Chr.\x1Fn. Chr.\x1FEEEE, d. MMMM y\x1FE, d. MMM y\x1Fdd.MM.y G\x1FE, d. MMM y G\x1Fd.M.\x1F" &
  "E, d.M.\x1FHH 'Uhr'\x1F¤ #,##0.00\x1FJänner\x1FJän.\x1FJän\x1F'\x1F#,##0%\x1F¤ #,##0.00;¤-#,##0.00\x1F" &
  "Žanwiye\x1FFeewiriye\x1FMarsi\x1FAwiril\x1FMe\x1FŽuweŋ\x1FŽuyye\x1FUt\x1FSektanbur\x1FOktoobur\x1FNoowanbur\x1F" &
  "Deesanbur\x1FŽan\x1FFee\x1FAwi\x1FŽuw\x1FŽuy\x1FSek\x1FNoo\x1FDee\x1FAlhadi\x1FAtinni\x1FAtalaata\x1FAlarba\x1FAlzuma\x1F" &
  "Asibti\x1FAti\x1FAta\x1FAla\x1FAlm\x1FAlz\x1FAsi\x1FArrubu 1\x1FArrubu 2\x1FArrubu 3\x1FArrubu 4\x1FA1\x1FA2\x1FA3\x1FA4\x1FSubbaahi\x1F" &
  "Zaarikay b\x1FIJ\x1FIZ\x1Fमेई\x1Fसितंबर\x1Fअक्तूबर\x1Fजन.\x1Fफर.\x1F" &
  "अग.\x1Fसित.\x1Fअक्तू.\x1Fनव.\x1Fदिस.\x1Fऐतबार\x1Fबीरबार\x1F" &
  "शनिबार\x1Fऐत\x1Fसोम\x1Fबीर\x1Fशुक्र\x1Fशनि\x1Fपैहली त्रमाही\x1F" &
  "दूई त्रमाही\x1Fत्री त्रमाही\x1Fचौथी त्रमाही\x1F" &
  "त्र.1\x1Fत्र.2\x1Fत्र.3\x1Fत्र.4\x1Fसवेर\x1Fस’ञ\x1Fई.पू.\x1F" &
  "ईसवी\x1FEEEE, d, MMMM y\x1Fd, MMMM y\x1Fd, MMM y\x1FE, d, MMM y\x1Fd, MMM G y\x1FE, d, MMM G y\x1F" &
  "januara\x1Ffebruara\x1Fměrca\x1Fapryla\x1Fmaja\x1Fjunija\x1Fjulija\x1Fawgusta\x1Fseptembra\x1Foktobra\x1Fnowembra\x1F" &
  "decembra\x1Fměr.\x1Fmaj.\x1Fawg.\x1Fnow.\x1Fměrc\x1Fapryl\x1Fjunij\x1Fjulij\x1Fawgust\x1Fnowember\x1Fměr\x1Fawg\x1Fnjeźela\x1F" &
  "pónjeźele\x1Fwałtora\x1Fsrjoda\x1Fstwórtk\x1Fpětk\x1Fpón\x1Fwał\x1Fsrj\x1Fstw\x1Fpět\x1Fsob\x1F1. kwartal\x1F" &
  "2. kwartal\x1F3. kwartal\x1F4. kwartal\x1Fkw1\x1Fkw2\x1Fkw3\x1Fkw4\x1Fwótp.\x1Fpś.Chr.n.\x1Fpó Chr.n.\x1Fd.M.yy\x1F" &
  "'zeg'. H:mm\x1F'zeg'. H\x1Fdimɔ́di\x1Fŋgɔndɛ\x1Fsɔŋɛ\x1Fdiɓáɓá\x1Femiasele\x1Fesɔpɛsɔpɛ\x1F" &
  "madiɓɛ́díɓɛ́\x1Fdiŋgindi\x1Fnyɛtɛki\x1Fmayésɛ́\x1Ftiníní\x1Feláŋgɛ́\x1Fdi\x1Fŋgɔn\x1F" &
  "sɔŋ\x1Fdiɓ\x1Femi\x1Fesɔ\x1Fmad\x1Fdiŋ\x1Fnyɛt\x1Ftin\x1Felá\x1Féti\x1Fmɔ́sú\x1Fkwasú\x1Fmukɔ́sú\x1Fŋgisú\x1F" &
  "ɗónɛsú\x1Fesaɓasú\x1Fét\x1Fmɔ́s\x1Fkwa\x1Fmuk\x1Fŋgi\x1Fɗón\x1Fesa\x1Fndúmbū nyá ɓosó\x1Fndúmbū ní lóndɛ́ íɓaá\x1F" &
  "ndúmbū ní lóndɛ́ ílálo\x1Fndúmbū ní lóndɛ́ ínɛ́y\x1Fndu1\x1Fndu2\x1Fndu3\x1Fndu4\x1F" &
  "idiɓa\x1Febyámu\x1Fɓ.Ys\x1Fmb.Ys\x1FSanvie\x1FFébirie\x1FMars\x1FAburil\x1FMee\x1FSueŋ\x1FSúuyee\x1FSettembar\x1F" &
  "Oktobar\x1FNovembar\x1FDisambar\x1FSa\x1FFe\x1FMa\x1FAb\x1FSu\x1FSú\x1FSe\x1FOk\x1FNo\x1FDe\x1FDimas\x1FTeneŋ\x1FTalata\x1FAlarbay\x1F" &
  "Aramisay\x1FArjuma\x1FSibiti\x1FDim\x1FTen\x1FTal\x1FAra\x1FArj\x1FSib\x1FArY\x1FAtY\x1F#,##,##0 %\x1Fཟླ་དངཔ་\x1F" &
  "ཟླ་གཉིས་པ་\x1Fཟླ་གསུམ་པ་\x1Fཟླ་བཞི་པ་\x1F" &
  "ཟླ་ལྔ་པ་\x1Fཟླ་དྲུག་པ\x1Fཟླ་བདུན་པ་\x1F" &
  "ཟླ་བརྒྱད་པ་\x1Fཟླ་དགུ་པ་\x1Fཟླ་བཅུ་པ་\x1F" &
  "ཟླ་བཅུ་གཅིག་པ་\x1Fཟླ་བཅུ་གཉིས་པ་\x1F" &
  "༡\x1F༢\x1F༣\x1F༤\x1F༥\x1F༦\x1F༧\x1F༨\x1F༩\x1F༡༠\x1F༡༡\x1F12\x1Fསྤྱི་ཟླ་དངཔ་\x1F" &
  "སྤྱི་ཟླ་གཉིས་པ་\x1Fསྤྱི་ཟླ་གསུམ་པ་\x1F" &
  "སྤྱི་ཟླ་བཞི་པ\x1Fསྤྱི་ཟླ་ལྔ་པ་\x1Fསྤྱི་ཟླ་དྲུག་པ\x1F" &
  "སྤྱི་ཟླ་བདུན་པ་\x1Fསྤྱི་ཟླ་བརྒྱད་པ་\x1F" &
  "སྤྱི་ཟླ་དགུ་པ་\x1Fསྤྱི་ཟླ་བཅུ་པ་\x1F" &
  "སྤྱི་ཟླ་བཅུ་གཅིག་པ་\x1Fསྤྱི་ཟླ་བཅུ་གཉིས་པ་\x1F" &
  "ཟླ་\x1Fམིར་\x1Fལྷག་\x1Fཕུར་\x1Fསངས་\x1Fསྤེན་\x1Fཉི་\x1F" &
  "བཞི་དཔྱ་དང་པ་\x1Fབཞི་དཔྱ་གཉིས་པ་\x1F" &
  "བཞི་དཔྱ་གསུམ་པ་\x1Fབཞི་དཔྱ་བཞི་པ་\x1F" &
  "བཞི་དཔྱ་༡\x1Fབཞི་དཔྱ་༢\x1Fབཞི་དཔྱ་༣\x1F" &
  "བཞི་དཔྱ་༤\x1Fསྔ་ཆ་\x1Fཕྱི་ཆ་\x1FEEEE, སྤྱི་ལོ་y MMMM ཚེས་dd\x1F" &
  "སྤྱི་ལོ་y MMMM ཚེས་ dd\x1Fསྤྱི་ལོ་y ཟླ་MMM ཚེས་dd\x1F" &
  "ཆུ་ཚོད་ h སྐར་མ་ mm:ss a zzzz\x1Fཆུ་ཚོད་ h སྐར་མ་ mm:ss a z\x1F" &
  "ཆུ་ཚོད་h:mm:ss a\x1Fཆུ་ཚོད་ h སྐར་མ་ mm a\x1Fy-M-d\x1F" &
  "E, y-M-d\x1Fy སྤྱི་ཟླ་MMM\x1Fགཟའ་E, ལོy ཟླ་MMM ཚེ་d\x1F" &
  "གཟའ་E, G ལོy ཟླ་MMM ཚེ་d\x1Fy-M\x1FM-d\x1FE, M-d\x1Fསྤྱི་LLL ཚེ་d\x1F" &
  "E, སྤྱི་LLL ཚེ་d\x1FG y སྤྱི་ཟླ་MMM\x1Fསྤྱི་LLL\x1F" &
  "ཆུ་ཚོད་HH\x1Fཆུ་ཚོད་h a\x1FMweri wa mbere\x1FMweri wa kaĩri\x1FMweri wa kathatũ\x1F" &
  "Mweri wa kana\x1FMweri wa gatano\x1FMweri wa gatantatũ\x1FMweri wa mũgwanja\x1FMweri wa kanana\x1F" &
  "Mweri wa kenda\x1FMweri wa ikũmi\x1FMweri wa ikũmi na ũmwe\x1FMweri wa ikũmi na Kaĩrĩ\x1F" &
  "Mbe\x1FKai\x1FKat\x1FGat\x1FGan\x1FMug\x1FKnn\x1FKen\x1FIgi\x1FKiumia\x1FNjumatatu\x1FNjumaine\x1FNjumatano\x1FAramithi\x1F" &
  "Njumaa\x1FNJumamothii\x1FKma\x1FTat\x1FIne\x1FTan\x1FArm\x1FMaa\x1FNMM\x1FKuota ya mbere\x1FKuota ya Kaĩrĩ\x1FKuota ya kathatu\x1F" &
  "Kuota ya kana\x1FKI\x1FUT\x1FMK\x1FTK\x1Fdzove\x1Fdzodze\x1Ftedoxe\x1Fafɔfĩe\x1Fdame\x1Fmasa\x1Fsiamlɔm\x1Fdeasiamime\x1F" &
  "anyɔnyɔ\x1Fkele\x1Fadeɛmekpɔxe\x1Fdzome\x1Fdzv\x1Fdzd\x1Fted\x1Fafɔ\x1Fdam\x1Fmas\x1Fsia\x1Fdea\x1Fany\x1Fkel\x1Fade\x1Fdzm\x1F" &
  "kɔsiɖa\x1Fdzoɖa\x1Fblaɖa\x1Fkuɖa\x1Fyawoɖa\x1Ffiɖa\x1Fmemleɖa\x1Fkɔs\x1Fdzo\x1Fbla\x1Fkuɖ\x1Fyaw\x1Ffiɖ\x1Fmem\x1F" &
  "kɔta gbãtɔ\x1Fkɔta evelia\x1Fkɔta etɔ̃lia\x1Fkɔta enelia\x1Fk1\x1Fk2\x1Fk3\x1Fk4\x1Fŋdi\x1Fɣetrɔ\x1F" &
  "HYV\x1FYŋ\x1FEEEE, MMMM d 'lia' y\x1FMMMM d 'lia' y\x1FMMM d 'lia', y\x1Fa 'ga' h:mm:ss zzzz\x1Fa 'ga' h:mm:ss z\x1F" &
  "a 'ga' h:mm:ss\x1Fa 'ga' h:mm\x1F{0} {1}\x1FMMM d 'lia', y G\x1FE, MMM d 'lia' y G\x1FMMM d 'lia'\x1F" &
  "E, MMM d 'lia'\x1FMMMM d 'lia'\x1Fa 'ga' h\x1F'aɖabaƒoƒo' mm:ss\x1FΙανουαρίου\x1FΦεβρουαρίου\x1F" &
  "Μαρτίου\x1FΑπριλίου\x1FΜαΐου\x1FΙουνίου\x1FΙουλίου\x1FΑυγούστου\x1F" &
  "Σεπτεμβρίου\x1FΟκτωβρίου\x1FΝοεμβρίου\x1FΔεκεμβρίου\x1F" &
  "Ιαν\x1FΦεβ\x1FΜαρ\x1FΑπρ\x1FΜαΐ\x1FΙουν\x1FΙουλ\x1FΑυγ\x1FΣεπ\x1FΟκτ\x1FΝοε\x1F" &
  "Δεκ\x1FΙανουάριος\x1FΦεβρουάριος\x1FΜάρτιος\x1FΑπρίλιος\x1F" &
  "Μάιος\x1FΙούνιος\x1FΙούλιος\x1FΑύγουστος\x1FΣεπτέμβριος\x1F" &
  "Οκτώβριος\x1FΝοέμβριος\x1FΔεκέμβριος\x1FΜάρ\x1FΜάι\x1FΙούν\x1F" &
  "Ιούλ\x1FΑύγ\x1FΝοέ\x1FΚυριακή\x1FΔευτέρα\x1FΤρίτη\x1FΤετάρτη\x1FΠέμπτη\x1F" &
  "Παρασκευή\x1FΣάββατο\x1FΚυρ\x1FΔευ\x1FΤρί\x1FΤετ\x1FΠέμ\x1FΠαρ\x1FΣάβ\x1F" &
  "1ο τρίμηνο\x1F2ο τρίμηνο\x1F3ο τρίμηνο\x1F4ο τρίμηνο\x1FΤ1\x1FΤ2\x1F" &
  "Τ3\x1FΤ4\x1Fπ.μ.\x1Fμ.μ.\x1Fπ.Χ.\x1Fμ.Χ.\x1FΑὐγούστου\x1FὈκτωβρίου\x1FΑὐγ\x1F" &
  "Ὀκτ\x1FΑὔγουστος\x1FὈκτώβριος\x1FJanuary\x1FFebruary\x1FMarch\x1FJune\x1FJuly\x1F" &
  "October\x1FDecember\x1FOct\x1FSunday\x1FMonday\x1FTuesday\x1FWednesday\x1FThursday\x1FFriday\x1FSaturday\x1F1st quarter\x1F" &
  "2nd quarter\x1F3rd quarter\x1F4th quarter\x1FSept\x1FE, dd/MM/y\x1FE, dd/MM\x1FEEEE, dd MMMM y\x1FE, dd MMM y\x1F" &
  "E, dd MMM y G\x1Fdd MMM\x1FE, dd MMM\x1Fdd-MMM-y\x1Fa.m.\x1Fp.m.\x1Fy-MM-dd\x1FE, y-MM-dd\x1Fy-MM\x1FMM-dd\x1FE, MM-dd\x1F" &
  "E, dd.MM.y\x1Fd.M.y G\x1FH.mm.ss zzzz\x1FH.mm.ss z\x1FH.mm.ss\x1FH.mm\x1FAM\x1Fy/MM/dd\x1FE, y/MM/dd\x1Fy/MM/dd G\x1F" &
  "d-M-yy\x1F{1} {0}\x1F¤ #,##0.00;(¤ #,##0.00)\x1Fd/MM/y\x1FMM/dd\x1FE, MM/dd\x1Fdd MMM,y\x1Fdd MMM, y\x1F" &
  "E, dd MMM, y\x1F#,##0.00 ¤\x1F#,##0.00 ¤;(#,##0.00 ¤)\x1FJanuaro\x1FFebruaro\x1FMarto\x1FAprilo\x1F" &
  "Majo\x1FJunio\x1FJulio\x1FAŭgusto\x1FSeptembro\x1FOktobro\x1FNovembro\x1FDecembro\x1FMaj\x1FAŭg\x1Fdimanĉo\x1Flundo\x1F" &
  "mardo\x1Fmerkredo\x1Fĵaŭdo\x1Fvendredo\x1Fsabato\x1Flu\x1Fma\x1Fme\x1Fĵa\x1Fve\x1Fsa\x1F1-a jarkvarono\x1F2-a jarkvarono\x1F" &
  "3-a jarkvarono\x1F4-a jarkvarono\x1F1. jk.\x1F2. jk.\x1F3. jk.\x1F4. jk.\x1Fatm\x1Fptm\x1Fa.n.e.\x1Fn.e.\x1FEEEE, 'la' d-'a' 'de' MMMM y\x1F" &
  "HH'H'\x1Fenero\x1Ffebrero\x1Fmarzo\x1Fmayo\x1Fjunio\x1Fjulio\x1Fagosto\x1Fseptiembre\x1Fnoviembre\x1Fdiciembre\x1F" &
  "ene\x1Fsept\x1Foct\x1Fdic\x1Fdomingo\x1Flunes\x1Fjueves\x1Fviernes\x1Fsábado\x1Flun\x1Fjue\x1F1.er trimestre\x1F2.º trimestre\x1F" &
  "3.er trimestre\x1F4.º trimestre\x1FT1\x1FT2\x1FT3\x1FT4\x1Fa. C.\x1Fd. C.\x1FEEEE, d 'de' MMMM 'de' y\x1Fd 'de' MMMM 'de' y\x1F" &
  "MMMM 'de' y\x1Fd/M/y G\x1Fd 'de' MMMM\x1F1.º trimestre\x1F3.º trimestre\x1Fa.C.\x1Fd 'de' MMM 'de' y G\x1F" &
  "QQQ 'de' y\x1FHH\x1Fd 'de' MMM 'de' y\x1FE, d 'de' MMM 'de' y G\x1FM-y\x1FE d-M\x1Fhh:mm:ss\x1Fd MMM 'de' y\x1F" &
  "¤#,##0.00;¤-#,##0.00\x1Fene.\x1Fmay.\x1Fago.\x1Fsept.\x1Fdic.\x1Fdd-MM-yy\x1FE dd-MM-y\x1FE, dd-MM\x1Fd/MM/yy\x1F" &
  "EEE, d/M/y\x1FMMM 'de' y\x1FE, d MMM 'de' y G\x1Fd 'de' MMM\x1FE, d 'de' MMM\x1FMMM 'de' y G\x1FQ1\x1F" &
  "Q2\x1FQ3\x1FQ4\x1FEEEE dd 'de' MMMM 'de' y\x1Fdd 'de' MMMM 'de' y\x1FEEE, d 'de' MMM 'de' y\x1FE d 'de' MMM\x1F" &
  "1er. trimestre\x1F2do. trimestre\x1F3er. trimestre\x1FMM/dd/y\x1FMM/dd/yy\x1FE MM/dd/y\x1FFebrero\x1FMarzo\x1F" &
  "Setiembre\x1FOctubre\x1FNoviembre\x1FDiciembre\x1FEne.\x1FMar.\x1FAbr.\x1FMay.\x1FAgo.\x1FSet.\x1FOct.\x1FDic.\x1F2do trimestre\x1F" &
  "4to trimestre\x1Fjaanuar\x1Fveebruar\x1Fmärts\x1Faprill\x1Fmai\x1Fjuuni\x1Fjuuli\x1Foktoober\x1Fdetsember\x1Fjaan\x1F" &
  "veebr\x1Fdets\x1Fpühapäev\x1Fesmaspäev\x1Fteisipäev\x1Fkolmapäev\x1Fneljapäev\x1Freede\x1Flaupäev\x1F" &
  "P\x1FE\x1FT\x1FK\x1FN\x1FR\x1FL\x1FeKr\x1FpKr\x1FE, d. MMMM y\x1Fd.MM.y GGGGG\x1FE, d. MMMM y G\x1F% #,##0\x1Furtarrila\x1F" &
  "otsaila\x1Fmartxoa\x1Fapirila\x1Fmaiatza\x1Fekaina\x1Fuztaila\x1Fabuztua\x1Firaila\x1Furria\x1Fazaroa\x1Fabendua\x1F" &
  "urt.\x1Fots.\x1Fapi.\x1Fmai.\x1Feka.\x1Fuzt.\x1Fabu.\x1Fira.\x1Furr.\x1Faza.\x1Fabe.\x1Figandea\x1Fastelehena\x1Fasteartea\x1F" &
  "asteazkena\x1Fosteguna\x1Fostirala\x1Flarunbata\x1Fig.\x1Fal.\x1Far.\x1Faz.\x1Fog.\x1For.\x1Flr.\x1F1. hiruhilekoa\x1F" &
  "2. hiruhilekoa\x1F3. hiruhilekoa\x1F4. hiruhilekoa\x1F1Hh\x1F2Hh\x1F3Hh\x1F4Hh\x1FK.a.\x1FK.o.\x1Fy('e')'ko' MMMM'ren' d('a'), EEEE\x1F" &
  "y('e')'ko' MMMM'ren' d('a')\x1Fy('e')'ko' MMM d('a')\x1Fyy/M/d\x1F{1} ({0})\x1Fy/M/d, E\x1Fy('e')'ko' MMMM\x1F" &
  "y MMM d('a')\x1Fy MMM d('a'), E\x1FG y/MM/dd\x1FG y. 'urteko' MMM d('a')\x1FG y. 'urteko' MMM d('a'), E\x1F" &
  "y/M\x1FM/d, E\x1FMMM d('a')\x1FMMM d('a'), E\x1FMMMM'ren' d('a')\x1FG y. 'urteko' MMM\x1Fy('e')'ko' QQQ\x1F" &
  "y('e')'ko' QQQQ\x1Fngɔn osú\x1Fngɔn bɛ̌\x1Fngɔn lála\x1Fngɔn nyina\x1Fngɔn tána\x1Fngɔn saməna\x1F" &
  "ngɔn zamgbála\x1Fngɔn mwom\x1Fngɔn ebulú\x1Fngɔn awóm\x1Fngɔn awóm ai dziá\x1Fngɔn awóm ai bɛ̌\x1F" &
  "ngo\x1Fngb\x1Fngl\x1Fngn\x1Fngt\x1Fngs\x1Fngz\x1Fngm\x1Fnge\x1Fnga\x1Fngad\x1Fngab\x1Fsɔ́ndɔ\x1Fmɔ́ndi\x1Fsɔ́ndɔ məlú mə́bɛ̌\x1F" &
  "sɔ́ndɔ məlú mə́lɛ́\x1Fsɔ́ndɔ məlú mə́nyi\x1Ffúladé\x1Fséradé\x1Fsɔ́n\x1Fmɔ́n\x1F" &
  "smb\x1Fsml\x1Fsmn\x1Ffúl\x1Fsér\x1Fnsámbá ngɔn asú\x1Fnsámbá ngɔn bɛ̌\x1Fnsámbá ngɔn lála\x1F" &
  "nsámbá ngɔn nyina\x1Fnno\x1Fnnb\x1Fnnl\x1Fnnny\x1Fkíkíríg\x1Fngəgógəle\x1Foyk\x1Fayk\x1F‎¤ #,##0.00\x1F" &
  "ژانویه\x1Fفوریه\x1Fآوریل\x1Fمه\x1Fژوئن\x1Fژوئیه\x1Fاوت\x1Fسپتامبر\x1F" &
  "اکتبر\x1Fنوامبر\x1Fدسامبر\x1Fیکشنبه\x1Fدوشنبه\x1Fسه‌شنبه\x1Fچهارشنبه\x1F" &
  "پنجشنبه\x1Fجمعه\x1Fشنبه\x1Fسه‌ماههٔ اول\x1Fسه‌ماههٔ دوم\x1F" &
  "سه‌ماههٔ سوم\x1Fسه‌ماههٔ چهارم\x1Fس‌م۱\x1Fس‌م۲\x1Fس‌م۳\x1F" &
  "س‌م۴\x1Fق.ظ.\x1Fب.ظ.\x1Fق.م.\x1Fم.\x1FH:mm:ss (z)\x1F{1}،‏ {0}\x1FE y/M/d\x1Fy/M/d GGGGG\x1FE M/d\x1F" &
  "d LLL\x1FE d LLL\x1Fd LLLL\x1F¤ #,##0.00;‎(¤ #,##0.00)\x1Fجنوری\x1Fفبروری\x1Fمارچ\x1F" &
  "اپریل\x1Fمی\x1Fجون\x1Fجولای\x1Fاگست\x1Fسپتمبر\x1Fاکتوبر\x1Fنومبر\x1Fدسمبر\x1F" &
  "جنو\x1Fجول\x1Fدسم\x1Fربع اول\x1Fربع دوم\x1Fربع سوم\x1Fربع چهارم\x1F" &
  "ر۱\x1Fر۲\x1Fر۳\x1Fر۴\x1FMMM d\x1FMMMM d\x1Fsiilo\x1Fcolte\x1Fmbooy\x1Fseeɗto\x1Fduujal\x1Fkorse\x1Fmorso\x1Fjuko\x1F" &
  "siilto\x1Fyarkomaa\x1Fjolal\x1Fbowte\x1Fsii\x1Fcol\x1Fmbo\x1Fduu\x1Fkor\x1Fmor\x1Fjuk\x1Fslt\x1Fyar\x1Fjol\x1Fbow\x1Fdewo\x1Faaɓnde\x1F" &
  "mawbaare\x1Fnjeslaare\x1Fnaasaande\x1Fmawnde\x1Fhoore-biir\x1Fdew\x1Faaɓ\x1Fmaw\x1Fnaa\x1Fmwd\x1Fhbi\x1FTermes 1\x1F" &
  "Termes 2\x1FTermes 3\x1FTermes 4\x1Fsubaka\x1Fkikiiɗe\x1FH-I\x1FC-I\x1F⹁\x1F𞤅𞤭𞥅𞤤𞤮\x1F𞤕𞤮𞤤𞤼𞤮\x1F" &
  "𞤐𞤦𞤮𞥅𞤴𞤮\x1F𞤅𞤫𞥅𞤼𞤮\x1F𞤁𞤵𞥅𞤶𞤮\x1F𞤑𞤮𞤪𞤧𞤮\x1F" &
  "𞤃𞤮𞤪𞤧𞤮\x1F𞤔𞤵𞤳𞤮\x1F𞤅𞤭𞤤𞤼𞤮\x1F𞤒𞤢𞤪𞤳𞤮\x1F𞤔𞤮𞤤𞤮\x1F" &
  "𞤄𞤮𞤱𞤼𞤮\x1F𞤅𞤭𞥅𞤤\x1F𞤕𞤮𞤤\x1F𞤐𞤦𞤮𞥅𞤴\x1F𞤅𞤫𞥅𞤼\x1F" &
  "𞤁𞤵𞥅𞤶\x1F𞤑𞤮𞤪\x1F𞤃𞤮𞤪\x1F𞤔𞤵𞤳\x1F𞤅𞤭𞤤\x1F𞤒𞤢𞤪\x1F" &
  "𞤔𞤮𞤤\x1F𞤄𞤮𞤱\x1F𞤈𞤫𞤬𞤦𞤭𞤪𞥆𞤫\x1F𞤀𞥄𞤩𞤵𞤲𞥋𞤣𞤫\x1F" &
  "𞤃𞤢𞤱𞤦𞤢𞥄𞤪𞤫\x1F𞤐𞤶𞤫𞤧𞤤𞤢𞥄𞤪𞤫\x1F𞤐𞤢𞥄𞤧𞤢𞥄𞤲𞤣𞤫\x1F" &
  "𞤃𞤢𞤱𞤲𞤣𞤫\x1F𞤖𞤮𞤪𞤦𞤭𞤪𞥆𞤫\x1F𞤈𞤫𞤬\x1F𞤀𞥄𞤩𞤵\x1F" &
  "𞤃𞤢𞤦\x1F𞤔𞤫𞤧\x1F𞤐𞤢𞥄𞤧\x1F𞤃𞤢𞤣\x1F𞤖𞤮𞤪\x1F𞤐𞥑\x1F𞤐𞥒\x1F" &
  "𞤐𞥓\x1F𞤐𞥔\x1F𞤀𞤎\x1F𞤇𞤎\x1F𞤀𞤀𞤋\x1F𞤇𞤀𞤋\x1FEEEE d MMMM⹁ y\x1Fd MMMM⹁ y\x1F" &
  "d MMM⹁ y\x1FE⹁ d-M-y\x1FE⹁ d MMM⹁ y\x1Fd-M-y GGGGG\x1Fd MMM⹁ y G\x1FE⹁ d MMM⹁ y G\x1F" &
  "d-M\x1Ftammikuuta\x1Fhelmikuuta\x1Fmaaliskuuta\x1Fhuhtikuuta\x1Ftoukokuuta\x1Fkesäkuuta\x1Fheinäkuuta\x1F" &
  "elokuuta\x1Fsyyskuuta\x1Flokakuuta\x1Fmarraskuuta\x1Fjoulukuuta\x1Ftammi\x1Fhelmi\x1Fmaalis\x1Fhuhti\x1Ftouko\x1F" &
  "kesä\x1Fheinä\x1Felo\x1Fsyys\x1Floka\x1Fmarras\x1Fjoulu\x1Ftammikuu\x1Fhelmikuu\x1Fmaaliskuu\x1Fhuhtikuu\x1Ftoukokuu\x1F" &
  "kesäkuu\x1Fheinäkuu\x1Felokuu\x1Fsyyskuu\x1Flokakuu\x1Fmarraskuu\x1Fjoulukuu\x1Fsunnuntaina\x1Fmaanantaina\x1F" &
  "tiistaina\x1Fkeskiviikkona\x1Ftorstaina\x1Fperjantaina\x1Flauantaina\x1Fsu\x1Fti\x1Fke\x1Fto\x1Fpe\x1F1. neljännes\x1F" &
  "2. neljännes\x1F3. neljännes\x1F4. neljännes\x1F1. nelj.\x1F2. nelj.\x1F3. nelj.\x1F4. nelj.\x1Fap.\x1F" &
  "ip.\x1FeKr.\x1FjKr.\x1Fcccc d. MMMM y\x1FE d.M.y G\x1FL.y\x1FE d.M.\x1Fccc d.M.\x1Fm.ss\x1FSetyembre\x1FLinggo\x1F" &
  "Lin\x1Fika-1 quarter\x1Fika-2 quarter\x1Fika-3 quarter\x1Fika-4 na quarter\x1Fmars\x1Fapríl\x1Fdesember\x1F" &
  "sunnudagur\x1Fmánadagur\x1Ftýsdagur\x1Fmikudagur\x1Fhósdagur\x1Ffríggjadagur\x1Fleygardagur\x1Fsun.\x1F" &
  "mán.\x1Ftýs.\x1Fmik.\x1Fhós.\x1Ffrí.\x1Fley.\x1F1. ársfjórðingur\x1F2. ársfjórðingur\x1F3. ársfjórðingur\x1F" &
  "4. ársfjórðingur\x1F1. ársfj.\x1F2. ársfj.\x1F3. ársfj.\x1F4. ársfj.\x1FE dd.MM.y\x1FE dd.MM\x1F" &
  "QQQ 'í' y\x1FQQQQ 'í' y\x1FLL\x1Fjanvier\x1Ffévrier\x1Favril\x1Fjuin\x1Fjuillet\x1Faoût\x1Fseptembre\x1Foctobre\x1F" &
  "décembre\x1Fjanv.\x1Ffévr.\x1Favr.\x1Fjuil.\x1Fdéc.\x1Fdimanche\x1Flundi\x1Fmardi\x1Fmercredi\x1Fjeudi\x1Fvendredi\x1F" &
  "samedi\x1Fdim.\x1Flun.\x1Fmer.\x1Fjeu.\x1Fven.\x1Fsam.\x1F2e trimestre\x1F3e trimestre\x1F4e trimestre\x1Fav. J.-C.\x1F" &
  "ap. J.-C.\x1Fdd/MM/y GGGGG\x1FH 'h' mm 'min' ss 's' zzzz\x1Fjuill.\x1FHH 'h' mm 'min' ss 's' zzzz\x1F" &
  "HH 'h' mm 'min' ss 's' z\x1FHH 'h' mm 'min' ss 's'\x1FHH 'h' mm\x1Fy-MM-dd GGGGG\x1FE MM-dd\x1Fh 'h' mm 'min' ss 's' a\x1F" &
  "h 'h' mm a\x1Fh 'h' a\x1Fmm 'min' ss 's'\x1FHH.mm:ss 'h' zzzz\x1Fmat.\x1Fsoir\x1Fh:mm:ss\x1Fh\x1Ffév.\x1F" &
  "jui.\x1Fle 1er trimestre\x1Fle 2ème trimestre\x1Fle 3ème trimestre\x1Fle 4ème trimestre\x1FZenâr\x1F" &
  "Fevrâr\x1FMarç\x1FAvrîl\x1FJugn\x1FLui\x1FAvost\x1FSetembar\x1FOtubar\x1FDicembar\x1FZen\x1FFev\x1FAvr\x1FJug\x1FAvo\x1F" &
  "Otu\x1FDic\x1Fdomenie\x1Flunis\x1Fmartars\x1Fmiercus\x1Fjoibe\x1Fvinars\x1Fsabide\x1Fmie\x1Fjoi\x1Fvin\x1Fsab\x1FPrin trimestri\x1F" &
  "Secont trimestri\x1FTierç trimestri\x1FCuart trimestri\x1Fa.\x1Fp.\x1FpdC\x1FddC\x1FEEEE d 'di' MMMM 'dal' y\x1F" &
  "d 'di' MMMM 'dal' y\x1FLLLL 'dal' y\x1Fd 'di' MMMM\x1F¤ #,##0.00;¤ #,##0.00-\x1FJannewaris\x1F" &
  "Febrewaris\x1FMaaie\x1FJuny\x1FSeptimber\x1FNovimber\x1FDesimber\x1FMrt\x1FDes\x1Fsnein\x1Fmoandei\x1Ftiisdei\x1Fwoansdei\x1F" &
  "tongersdei\x1Ffreed\x1Fsneon\x1Fsi\x1Fmo\x1Fwo\x1Ffr\x1F1e fearnsjier\x1F2e fearnsjier\x1F3e fearnsjier\x1F4e fearnsjier\x1F" &
  "n.Kr.\x1FE d-M-y\x1FEanáir\x1FFeabhra\x1FMárta\x1FAibreán\x1FBealtaine\x1FMeitheamh\x1FIúil\x1FLúnasa\x1FMeán Fómhair\x1F" &
  "Deireadh Fómhair\x1FSamhain\x1FNollaig\x1FEan\x1FFeabh\x1FAib\x1FBeal\x1FMeith\x1FLún\x1FMFómh\x1FDFómh\x1FSamh\x1F" &
  "Noll\x1FDé Domhnaigh\x1FDé Luain\x1FDé Máirt\x1FDé Céadaoin\x1FDéardaoin\x1FDé hAoine\x1FDé Sathairn\x1F" &
  "Domh\x1FLuan\x1FMáirt\x1FCéad\x1FDéar\x1FAoine\x1FSath\x1F1ú ráithe\x1F2ú ráithe\x1F3ú ráithe\x1F4ú ráithe\x1F" &
  "r.n.\x1Fi.n.\x1FRC\x1FAharabata\x1FOflɔ\x1FOtsokrikri\x1FAbɛibe\x1FAgbiɛnaa\x1FOtukwajaŋ\x1FMaawɛ\x1FManyawale\x1F" &
  "Gbo\x1FAntɔŋ\x1FAlemle\x1FAfuabe\x1FHɔgbaa\x1FJu\x1FJufɔ\x1FShɔ\x1FSoo\x1FSohaa\x1FHɔɔ\x1Fdhen Fhaoilleach\x1F" &
  "dhen Ghearran\x1Fdhen Mhàrt\x1Fdhen Ghiblean\x1Fdhen Chèitean\x1Fdhen Ògmhios\x1Fdhen Iuchar\x1F" &
  "dhen Lùnastal\x1Fdhen t-Sultain\x1Fdhen Dàmhair\x1Fdhen t-Samhain\x1Fdhen Dùbhlachd\x1FFaoi\x1FGearr\x1F" &
  "Màrt\x1FGibl\x1FCèit\x1FÒgmh\x1FIuch\x1FLùna\x1FSult\x1FDàmh\x1FDùbh\x1FAm Faoilleach\x1FAn Gearran\x1FAm Màrt\x1F" &
  "An Giblean\x1FAn Cèitean\x1FAn t-Ògmhios\x1FAn t-Iuchar\x1FAn Lùnastal\x1FAn t-Sultain\x1FAn Dàmhair\x1F" &
  "An t-Samhain\x1FAn Dùbhlachd\x1FDiDòmhnaich\x1FDiLuain\x1FDiMàirt\x1FDiCiadain\x1FDiarDaoin\x1FDihAoine\x1F" &
  "DiSathairne\x1FDiD\x1FDiL\x1FDiM\x1FDiC\x1FDia\x1FDih\x1FDiS\x1F1d chairteal\x1F2na cairteal\x1F3s cairteal\x1F4mh cairteal\x1F" &
  "C1\x1FC2\x1FC3\x1FC4\x1Fm\x1Ff\x1FEEEE, d'mh' MMMM y\x1Fd'mh' MMMM y\x1Fd'mh' MMM y\x1FLLL Y\x1FL/y\x1Fd'mh' MMMM\x1F" &
  "h:mma\x1Fha\x1Fxaneiro\x1Ffebreiro\x1Fmaio\x1Fxuño\x1Fxullo\x1Fsetembro\x1Foutubro\x1Fnovembro\x1Fdecembro\x1Fxan.\x1F" &
  "xul.\x1Fout.\x1Fluns\x1Fmércores\x1Fxoves\x1Fvenres\x1Fdom.\x1Fmér.\x1Fxov.\x1Fsáb.\x1FE, d 'de' MMM 'de' y\x1F" &
  "Auguscht\x1FSeptämber\x1FOktoober\x1FNovämber\x1FDezämber\x1FSunntig\x1FMääntig\x1FZiischtig\x1FMittwuch\x1F" &
  "Dunschtig\x1FFriitig\x1FSamschtig\x1FSu.\x1FMä.\x1FZi.\x1FDu.\x1Fvorm.\x1Fnam.\x1Fજાન્યુઆરી\x1F" &
  "ફેબ્રુઆરી\x1Fમાર્ચ\x1Fએપ્રિલ\x1Fમે\x1Fજૂન\x1Fજુલાઈ\x1F" &
  "ઑગસ્ટ\x1Fસપ્ટેમ્બર\x1Fઑક્ટોબર\x1Fનવેમ્બર\x1F" &
  "ડિસેમ્બર\x1Fજાન્યુ\x1Fફેબ્રુ\x1Fસપ્ટે\x1Fઑક્ટો\x1F" &
  "નવે\x1Fડિસે\x1Fરવિવાર\x1Fસોમવાર\x1Fમંગળવાર\x1F" &
  "બુધવાર\x1Fગુરુવાર\x1Fશુક્રવાર\x1Fશનિવાર\x1F" &
  "રવિ\x1Fસોમ\x1Fમંગળ\x1Fબુધ\x1Fગુરુ\x1Fશુક્ર\x1Fશનિ\x1F" &
  "1લો ત્રિમાસ\x1F2જો ત્રિમાસ\x1F3જો ત્રિમાસ\x1F" &
  "4થો ત્રિમાસ\x1Fઈ.સ.પૂર્વે\x1Fઈ.સ.\x1Fhh:mm:ss a zzzz\x1F" &
  "hh:mm:ss a z\x1Fhh:mm:ss a\x1Fhh:mm a\x1Fd MMM, G y\x1FE, d MMM, G y\x1FMMM, G y\x1FChanuari\x1FFeburari\x1F" &
  "Apiriri\x1FChulai\x1FOkitoba\x1FNobemba\x1FCan\x1FCul\x1FAgt\x1FChumapiri\x1FChumatato\x1FChumaine\x1FChumatano\x1F" &
  "Aramisi\x1FIchuma\x1FEsabato\x1FCpr\x1FCtt\x1FCmn\x1FCmt\x1FArs\x1FIcm\x1FEst\x1FErobo entang’ani\x1FErobo yakabere\x1F" &
  "Erobo yagatato\x1FErobo yakane\x1FE1\x1FE2\x1FE3\x1FE4\x1FMo\x1FYA\x1FYK\x1FJerrey-geuree\x1FToshiaght-arree\x1FMayrnt\x1F" &
  "Averil\x1FBoaldyn\x1FMean-souree\x1FJerrey-souree\x1FLuanistyn\x1FMean-fouyir\x1FJerrey-fouyir\x1FMee Houney\x1F" &
  "Mee ny Nollick\x1FJ-guer\x1FT-arree\x1FAvrril\x1FM-souree\x1FJ-souree\x1FM-fouyir\x1FJ-fouyir\x1FM-Houney\x1F" &
  "M-Nollick\x1FJedoonee\x1FJelhein\x1FJemayrt\x1FJercean\x1FJerdein\x1FJeheiney\x1FJesarn\x1FJed\x1FJel\x1FJem\x1FJerc\x1F" &
  "Jerd\x1FJeh\x1FJes\x1FJanairu\x1FFaburairu\x1FMaris\x1FAfirilu\x1FMayu\x1FYuni\x1FYuli\x1FAgusta\x1FSatumba\x1FNuwamba\x1F" &
  "Disamba\x1FFab\x1FAfi\x1FYun\x1FYul\x1FAgu\x1FNuw\x1FLahadi\x1FLitinin\x1FLaraba\x1FAlhamis\x1FJummaʼa\x1FAsabar\x1FLah\x1F" &
  "Lit\x1FLar\x1FAsa\x1FKwata na ɗaya\x1FKwata na biyu\x1FKwata na uku\x1FKwata na huɗu\x1FSF\x1FYM\x1FK.H\x1FBHAI\x1F" &
  "EEEE d MMMM, y\x1FIanuali\x1FPepeluali\x1FMalaki\x1FʻApelila\x1FIune\x1FIulai\x1FʻAukake\x1FKepakemapa\x1F" &
  "ʻOkakopa\x1FNowemapa\x1FKekemapa\x1FIan.\x1FPep.\x1FMal.\x1FʻAp.\x1FIun.\x1FIul.\x1FʻAu.\x1FKep.\x1FʻOk.\x1FNow.\x1F" &
  "Kek.\x1FLāpule\x1FPoʻakahi\x1FPoʻalua\x1FPoʻakolu\x1FPoʻahā\x1FPoʻalima\x1FPoʻaono\x1FLP\x1FP1\x1FP2\x1FP3\x1F" &
  "P4\x1FP5\x1FP6\x1F\x1E\x1F‏#,##0.00 ‏¤;‏-#,##0.00 ‏¤\x1Fינואר\x1Fפברואר\x1Fמרץ\x1F" &
  "אפריל\x1Fמאי\x1Fיוני\x1Fיולי\x1Fאוגוסט\x1Fספטמבר\x1Fאוקטובר\x1Fנובמבר\x1F" &
  "דצמבר\x1Fינו׳\x1Fפבר׳\x1Fאפר׳\x1Fאוג׳\x1Fספט׳\x1Fאוק׳\x1Fנוב׳\x1Fדצמ׳\x1F" &
  "יום ראשון\x1Fיום שני\x1Fיום שלישי\x1Fיום רביעי\x1Fיום חמישי\x1F" &
  "יום שישי\x1Fיום שבת\x1Fיום א׳\x1Fיום ב׳\x1Fיום ג׳\x1Fיום ד׳\x1Fיום ה׳\x1F" &
  "יום ו׳\x1Fשבת\x1Fרבעון 1\x1Fרבעון 2\x1Fרבעון 3\x1Fרבעון 4\x1Fלפנה״ס\x1F" &
  "לספירה\x1FEEEE, d בMMMM y\x1Fd בMMMM y\x1Fd בMMM y\x1FE, d בMMM y\x1Fd בMMM y G\x1FE, d בMMM y G\x1F" &
  "d בMMM\x1FE, d בMMM\x1Fd בMMMM\x1FE ה-d\x1F‏h a\x1Fफ़रवरी\x1Fजन॰\x1Fफ़र॰\x1F" &
  "जुल॰\x1Fअग॰\x1Fसित॰\x1Fअक्टू॰\x1Fनव॰\x1Fदिस॰\x1Fरविवार\x1F" &
  "गुरुवार\x1Fरवि\x1Fगुरु\x1Fपहली तिमाही\x1Fदूसरी तिमाही\x1F" &
  "तीसरी तिमाही\x1Fचौथी तिमाही\x1Fति1\x1Fति2\x1F" &
  "ति3\x1Fति4\x1Fईसा-पूर्व\x1Fईस्वी\x1FGGGGG d/M/y\x1FMMM G y\x1FRaviwaar\x1F" &
  "Somwaar\x1FMangalwaar\x1FBudhwaar\x1FGuruwaar\x1FShukrawaar\x1FShaniwaar\x1FRavi\x1FSom\x1FMangal\x1FBudh\x1FGuru\x1F" &
  "Shukra\x1FShani\x1Fsiječnja\x1Fveljače\x1Fožujka\x1Ftravnja\x1Fsvibnja\x1Flipnja\x1Fsrpnja\x1Fkolovoza\x1Frujna\x1F" &
  "listopada\x1Fstudenoga\x1Fprosinca\x1Fsij\x1Fvelj\x1Fožu\x1Ftra\x1Fsvi\x1Flip\x1Fkol\x1Fruj\x1Fstu\x1Fsiječanj\x1Fveljača\x1F" &
  "ožujak\x1Ftravanj\x1Fsvibanj\x1Flipanj\x1Fsrpanj\x1Fkolovoz\x1Frujan\x1Fstudeni\x1Fprosinac\x1F1kv\x1F2kv\x1F3kv\x1F" &
  "4kv\x1Fpr. Kr.\x1Fpo. Kr.\x1Fdd. MM. y.\x1FE, dd. MM. y.\x1FLLL y.\x1Fd. M. y. GGGGG\x1Fdd. MM.\x1FE, dd. MM.\x1F" &
  "LLL y. G\x1FL.\x1F1. kv.\x1F2. kv.\x1F3. kv.\x1F4. kv.\x1Fd. M. yy.\x1Fmeje\x1Fmej.\x1Fmeja\x1Fmej\x1Fnjedźela\x1Fpóndźela\x1F" &
  "wutora\x1Fsrjeda\x1Fštwórtk\x1Fpjatk\x1Fwut\x1Fštw\x1Fpja\x1Fpop.\x1Fpř.Chr.n.\x1Fpo Chr.n.\x1FH:mm 'hodź'.\x1F" &
  "H 'hodź'.\x1Fjanuár\x1Ffebruár\x1Fmárcius\x1Fáprilis\x1Fmájus\x1Fjúnius\x1Fjúlius\x1Faugusztus\x1Fszeptember\x1F" &
  "október\x1Fmárc.\x1Fápr.\x1Fmáj.\x1Fjún.\x1Fjúl.\x1Fszept.\x1Fvasárnap\x1Fhétfő\x1Fkedd\x1Fszerda\x1Fcsütörtök\x1F" &
  "péntek\x1Fszombat\x1FV\x1FSze\x1FCs\x1FSzo\x1FI. negyedév\x1FII. negyedév\x1FIII. negyedév\x1FIV. negyedév\x1F" &
  "I. n.év\x1FII. n.év\x1FIII. n.év\x1FIV. n.év\x1Fde.\x1Fdu.\x1Fi. e.\x1Fi. sz.\x1Fy. MMMM d., EEEE\x1Fy. MMMM d.\x1F" &
  "y. MMM d.\x1Fy. MM. dd.\x1Fy. MM. dd., E\x1Fy. MMM\x1Fy. MMMM\x1Fy. MMM d., E\x1FGGGGG y. MM. dd.\x1FG y. MMM d.\x1F" &
  "G y. MMM d., E\x1Fy. M.\x1FM. d.\x1FM. d., E\x1FMMM d.\x1FMMM d., E\x1FMMMM d.\x1FG y. MMM\x1Fy. QQQ\x1Fy. QQQQ\x1F" &
  "G y.\x1Fd., E\x1Fհունվարի\x1Fփետրվարի\x1Fմարտի\x1Fապրիլի\x1Fմայիսի\x1F" &
  "հունիսի\x1Fհուլիսի\x1Fօգոստոսի\x1Fսեպտեմբերի\x1Fհոկտեմբերի\x1F" &
  "նոյեմբերի\x1Fդեկտեմբերի\x1Fհնվ\x1Fփտվ\x1Fմրտ\x1Fապր\x1Fմյս\x1Fհնս\x1F" &
  "հլս\x1Fօգս\x1Fսեպ\x1Fհոկ\x1Fնոյ\x1Fդեկ\x1Fհունվար\x1Fփետրվար\x1Fմարտ\x1F" &
  "ապրիլ\x1Fմայիս\x1Fհունիս\x1Fհուլիս\x1Fօգոստոս\x1Fսեպտեմբեր\x1F" &
  "հոկտեմբեր\x1Fնոյեմբեր\x1Fդեկտեմբեր\x1Fկիրակի\x1Fերկուշաբթի\x1F" &
  "երեքշաբթի\x1Fչորեքշաբթի\x1Fհինգշաբթի\x1Fուրբաթ\x1Fշաբաթ\x1F" &
  "կիր\x1Fերկ\x1Fերք\x1Fչրք\x1Fհնգ\x1Fուր\x1Fշբթ\x1F1-ին եռամսյակ\x1F2-րդ եռամսյակ\x1F" &
  "3-րդ եռամսյակ\x1F4-րդ եռամսյակ\x1F1-ին եռմս.\x1F2-րդ եռմս.\x1F" &
  "3-րդ եռմս.\x1F4-րդ եռմս.\x1Fմ.թ.ա.\x1Fմ.թ.\x1Fy թ. MMMM d, EEEE\x1Fy թ. MMMM d\x1F" &
  "y թ. MMM d\x1Fd.MM.y, E\x1Fy թ. LLL\x1Fy թ․ LLLL\x1Fy թ. MMM d, E\x1FGGGGG dd.MM.y\x1FG y թ․ MMM d\x1F" &
  "G y թ. MMM d, E\x1FG y թ. MMM\x1Fy թ. QQQ\x1Fy թ. QQQQ\x1FG y թ.\x1Fy թ․\x1Fjanuario\x1Ffebruario\x1F" &
  "martio\x1Faugusto\x1Fdecembre\x1Fdominica\x1Flunedi\x1Fmartedi\x1Fmercuridi\x1Fjovedi\x1Fvenerdi\x1Fsabbato\x1F" &
  "mer\x1Fjov\x1Fven\x1F1me trimestre\x1F2nde trimestre\x1F3tie trimestre\x1F4te trimestre\x1Fa.Chr.\x1Fp.Chr.\x1F" &
  "EEEE 'le' d 'de' MMMM y\x1Fd 'de' MMMM y\x1Fdd-MM-y G\x1FE dd-MM\x1FMaret\x1FAgustus\x1FMinggu\x1FSenin\x1F" &
  "Selasa\x1FRabu\x1FKamis\x1FJumat\x1FSabtu\x1FMin\x1FSen\x1FSel\x1FRab\x1FKam\x1FKuartal ke-1\x1FKuartal ke-2\x1FKuartal ke-3\x1F" &
  "Kuartal ke-4\x1FSM\x1Fmarte\x1Fjulí\x1Fsoledí\x1Flunedí\x1Fmardí\x1Fmercurdí\x1Fjovedí\x1Fvenerdí\x1Fsaturdí\x1F" &
  "sol.\x1Fjov.\x1Fsat.\x1F1-m trimestre\x1F2-m trimestre\x1F3-m trimestre\x1F4-m trimestre\x1FEEEE d MMM y\x1F" &
  "H 'h'.\x1FJenụwarị\x1FFebrụwarị\x1FMaachị\x1FEpreel\x1FJulaị\x1FỌgọọst\x1FỌktoba\x1FJen\x1F" &
  "Juu\x1FỌgọ\x1FỌkt\x1FSọndee\x1FMọnde\x1FTiuzdee\x1FWenezdee\x1FTọọzdee\x1FFraịdee\x1FSatọdee\x1F" &
  "Sọn\x1FMọn\x1FTiu\x1FWen\x1FTọọ\x1FFraị\x1FỌkara 1\x1FỌkara 2\x1FỌkara 3\x1FỌkara 4\x1FN’ụtụtụ\x1F" &
  "N’abalị\x1Fꋍꆪ\x1Fꑍꆪ\x1Fꌕꆪ\x1Fꇖꆪ\x1Fꉬꆪ\x1Fꃘꆪ\x1Fꏃꆪ\x1Fꉆꆪ\x1Fꈬꆪ\x1Fꊰꆪ\x1F" &
  "ꊯꊪꆪ\x1Fꊰꑋꆪ\x1Fꑬꆏꑍ\x1Fꆏꊂꋍ\x1Fꆏꊂꑍ\x1Fꆏꊂꌕ\x1Fꆏꊂꇖ\x1Fꆏꊂꉬ\x1Fꆏꊂꃘ\x1F" &
  "ꑬꆏ\x1Fꆏꋍ\x1Fꆏꑍ\x1Fꆏꌕ\x1Fꆏꇖ\x1Fꆏꉬ\x1Fꆏꃘ\x1Fꄮꐰꋍꂷꂶꌠ\x1Fꄮꐰꑍꂷꂶꌠ\x1F" &
  "ꄮꐰꌕꂷꂶꌠ\x1Fꄮꐰꇖꂷꂶꌠ\x1F1ꄮꐰ\x1F2ꄮꐰ\x1F3ꄮꐰ\x1F4ꄮꐰ\x1Fꎸꄑ\x1Fꁯꋒ\x1F" &
  "ꃅꋊꂿ\x1Fꃅꋊꊂ\x1FyꈎMꆪdꑍ\x1Fy MMM dꑍ,E\x1FG y MMM dꑍ\x1FG y MMM dꑍ,E\x1FMMꆪ-ddꑍ\x1F" &
  "MMꆪ-ddꑍ，E\x1FMMM dꑍ\x1FMMMM dꑍ,E\x1FMMMM dꑍ\x1Fdꑍ\x1Fdꑍ, E\x1Fah:mm:ss\x1Fah:mm\x1Fjanúar\x1F" &
  "febrúar\x1Fmaí\x1Fjúní\x1Fjúlí\x1Fágúst\x1Fnóvember\x1Fágú.\x1Fnóv.\x1Fmánudagur\x1Fþriðjudagur\x1F" &
  "miðvikudagur\x1Ffimmtudagur\x1Fföstudagur\x1Flaugardagur\x1Fþri.\x1Fmið.\x1Ffim.\x1Ffös.\x1Flau.\x1F1. fjórðungur\x1F" &
  "2. fjórðungur\x1F3. fjórðungur\x1F4. fjórðungur\x1FF1\x1FF2\x1FF3\x1FF4\x1Ff.h.\x1Fe.h.\x1Fgennaio\x1Ffebbraio\x1F" &
  "aprile\x1Fmaggio\x1Fgiugno\x1Fluglio\x1Fsettembre\x1Fottobre\x1Fdicembre\x1Fgen\x1Fmag\x1Fgiu\x1Flug\x1Fott\x1Fdomenica\x1F" &
  "lunedì\x1Fmartedì\x1Fmercoledì\x1Fgiovedì\x1Fvenerdì\x1Fgio\x1F1º trimestre\x1F2º trimestre\x1F3º trimestre\x1F" &
  "4º trimestre\x1F1月\x1F2月\x1F3月\x1F4月\x1F5月\x1F6月\x1F7月\x1F8月\x1F9月\x1F10月\x1F11月\x1F12月\x1F日曜日\x1F" &
  "月曜日\x1F火曜日\x1F水曜日\x1F木曜日\x1F金曜日\x1F土曜日\x1F日\x1F月\x1F火\x1F水\x1F木\x1F金\x1F" &
  "土\x1F第1四半期\x1F第2四半期\x1F第3四半期\x1F第4四半期\x1F午前\x1F午後\x1F紀元前\x1F" &
  "西暦\x1Fy年M月d日EEEE\x1Fy年M月d日\x1FH時mm分ss秒 zzzz\x1Fy/M/d(E)\x1Fy年M月\x1Fy年M月d日(E)\x1F" &
  "Gy/M/d\x1FGy年M月d日\x1FGy年M月d日(E)\x1FM/d(E)\x1FM月d日\x1FM月d日(E)\x1FGy年M月\x1Fy/QQQ\x1F" &
  "y年QQQQ\x1FGy年\x1Fy年\x1FM月\x1Fd日\x1Fd日(E)\x1FH時\x1FaK:mm:ss\x1FaK:mm\x1FaK時\x1FNduŋmbi Saŋ\x1FPɛsaŋ Pɛ́pá\x1F" &
  "Pɛsaŋ Pɛ́tát\x1FPɛsaŋ Pɛ́nɛ́kwa\x1FPɛsaŋ Pataa\x1FPɛsaŋ Pɛ́nɛ́ntúkú\x1FPɛsaŋ Saambá\x1F" &
  "Pɛsaŋ Pɛ́nɛ́fɔm\x1FPɛsaŋ Pɛ́nɛ́pfúꞋú\x1FPɛsaŋ Nɛgɛ́m\x1FPɛsaŋ Ntsɔ̌pmɔ́\x1F" &
  "Pɛsaŋ Ntsɔ̌ppá\x1FSɔ́ndi\x1FMɔ́ndi\x1FÁpta Mɔ́ndi\x1FWɛ́nɛsɛdɛ\x1FTɔ́sɛdɛ\x1FFɛlâyɛdɛ\x1F" &
  "Sásidɛ\x1Fmbaꞌmbaꞌ\x1Fŋka mbɔ́t nji\x1FEEEE, y MMMM dd\x1FM.d.y\x1FAprilyi\x1FJunyi\x1FJulyai\x1F" &
  "Agusti\x1FJumapilyi\x1FJumatatuu\x1FJumatanu\x1FIju\x1Futuko\x1Fkyiukonyi\x1FAhad\x1Ftriwulan kaping pisan\x1F" &
  "triwulan kaping loro\x1Ftriwulan kaping telu\x1Ftriwulan kaping papat\x1FTW1\x1FTW2\x1FTW3\x1FTW4\x1Fიანვარი\x1F" &
  "თებერვალი\x1Fმარტი\x1Fაპრილი\x1Fმაისი\x1Fივნისი\x1F" &
  "ივლისი\x1Fაგვისტო\x1Fსექტემბერი\x1Fოქტომბერი\x1F" &
  "ნოემბერი\x1Fდეკემბერი\x1Fიან\x1Fთებ\x1Fმარ\x1F" &
  "აპრ\x1Fმაი\x1Fივნ\x1Fივლ\x1Fაგვ\x1Fსექ\x1Fოქტ\x1Fნოე\x1Fდეკ\x1F" &
  "კვირა\x1Fორშაბათი\x1Fსამშაბათი\x1Fოთხშაბათი\x1F" &
  "ხუთშაბათი\x1Fპარასკევი\x1Fშაბათი\x1Fკვი\x1F" &
  "ორშ\x1Fსამ\x1Fოთხ\x1Fხუთ\x1Fპარ\x1Fშაბ\x1FI კვარტალი\x1F" &
  "II კვარტალი\x1FIII კვარტალი\x1FIV კვარტალი\x1F" &
  "I კვ.\x1FII კვ.\x1FIII კვ.\x1FIV კვ.\x1Fძვ. წ.\x1Fახ. წ.\x1FEEEE, dd MMMM, y\x1F" &
  "d MMM. y\x1FMMM. y\x1FMMMM, y\x1FE, d MMM. y\x1FG d MMM. y\x1FG E, d MMM. y\x1FG MMM. y\x1FQQQ, y\x1FQQQQ, y\x1F" &
  "Yennayer\x1FFuṛar\x1FMeɣres\x1FYebrir\x1FMayyu\x1FYunyu\x1FYulyu\x1FƔuct\x1FCtembeṛ\x1FTubeṛ\x1FNunembeṛ\x1F" &
  "Duǧembeṛ\x1FYen\x1FFur\x1FMeɣ\x1FYeb\x1FƔuc\x1FCte\x1FTub\x1FNun\x1FDuǧ\x1FAcer\x1FArim\x1FAram\x1FAmhad\x1FSem\x1FSed\x1Fakraḍaggur amenzu\x1F" &
  "akraḍaggur wis-sin\x1Fakraḍaggur wis-kraḍ\x1Fakraḍaggur wis-kuẓ\x1FKḍg1\x1FKḍg2\x1F" &
  "Kḍg3\x1FKḍg4\x1Fn tufat\x1Fn tmeddit\x1Fsnd. T.Ɛ\x1Fsld. T.Ɛ\x1FMwai wa mbee\x1FMwai wa kelĩ\x1F" &
  "Mwai wa katatũ\x1FMwai wa kana\x1FMwai wa katano\x1FMwai wa thanthatũ\x1FMwai wa muonza\x1FMwai wa nyaanya\x1F" &
  "Mwai wa kenda\x1FMwai wa ĩkumi\x1FMwai wa ĩkumi na ĩmwe\x1FMwai wa ĩkumi na ilĩ\x1FKel\x1FKtũ\x1F" &
  "Ktn\x1FTha\x1FMoo\x1FNya\x1FKnd\x1FĨku\x1FĨkm\x1FĨkl\x1FWa kyumwa\x1FWa kwambĩlĩlya\x1FWa kelĩ\x1FWa katatũ\x1F" &
  "Wa kana\x1FWa katano\x1FWa thanthatũ\x1FWky\x1FWkw\x1FWkl\x1FWtũ\x1FWkn\x1FWtn\x1FWth\x1FLovo ya mbee\x1FLovo ya kelĩ\x1F" &
  "Lovo ya katatũ\x1FLovo ya kana\x1FĨyakwakya\x1FĨyawĩoo\x1FMY\x1FIY\x1Fщӏышылэм\x1Fмазаем\x1F" &
  "гъатхэпэм\x1Fмэлыжьыхьэм\x1Fнакъыгъэм\x1Fмэкъуауэгъуэм\x1F" &
  "бадзэуэгъуэм\x1Fшыщхьэӏум\x1Fфокӏадэм\x1Fжэпуэгъуэм\x1F" &
  "щакӏуэгъуэм\x1Fдыгъэгъазэм\x1Fщӏышылэ\x1Fмазае\x1Fгъатхэпэ\x1F" &
  "мэлыжьыхь\x1Fнакъыгъэ\x1Fмэкъуауэгъуэ\x1Fбадзэуэгъуэ\x1F" &
  "шыщхьэӏу\x1Fфокӏадэ\x1Fжэпуэгъуэ\x1Fщакӏуэгъуэ\x1Fдыгъэгъазэ\x1F" &
  "тхьэмахуэ\x1Fблыщхьэ\x1Fгъубж\x1Fбэрэжей\x1Fмахуэку\x1Fмэрем\x1F" &
  "щэбэт\x1FMwedi Ntandi\x1FMwedi wa Pili\x1FMwedi wa Tatu\x1FMwedi wa Nchechi\x1FMwedi wa Nnyano\x1F" &
  "Mwedi wa Nnyano na Umo\x1FMwedi wa Nnyano na Mivili\x1FMwedi wa Nnyano na Mitatu\x1FMwedi wa Nnyano na Nchechi\x1F" &
  "Mwedi wa Nnyano na Nnyano\x1FMwedi wa Nnyano na Nnyano na U\x1FMwedi wa Nnyano na Nnyano na M\x1F" &
  "Liduva lyapili\x1FLiduva lyatatu\x1FLiduva lyanchechi\x1FLiduva lyannyano\x1FLiduva lyannyano na linji\x1F" &
  "Liduva lyannyano na mavili\x1FLiduva litandi\x1FLl2\x1FLl3\x1FLl4\x1FLl5\x1FLl6\x1FLl7\x1FLl1\x1FMuhi\x1FChilo\x1F" &
  "AY\x1FNY\x1FJaneru\x1FFebreru\x1FMarsu\x1FMaiu\x1FJunhu\x1FJulhu\x1FAgostu\x1FSetenbru\x1FOtubru\x1FNuvenbru\x1FDizenbru\x1F" &
  "Nuv\x1FDiz\x1Fdumingu\x1Fsigunda-fera\x1Ftersa-fera\x1Fkuarta-fera\x1Fkinta-fera\x1Fsesta-fera\x1Fsig\x1Fter\x1F" &
  "kua\x1Fkin\x1Fses\x1F1º trimestri\x1F2º trimestri\x1F3º trimestri\x1F4º trimestri\x1FDK\x1FEEEE, d 'di' MMMM 'di' y\x1F" &
  "d 'di' MMMM 'di' y\x1FLLLL 'di' y\x1FLL/y\x1FQQQQ 'di' y\x1FXbʼeen Po\x1FXkabʼ Po\x1FRox Po\x1FXkaa Po\x1F" &
  "Roʼ Po\x1FXwaq Po\x1FXwuuq Po\x1FXwaqxaq Po\x1FXbʼelee Po\x1FXlajee Po\x1FXjunlaj Po\x1FXkabʼlaj Po\x1F" &
  "Doʼkutan\x1FLuʼkutan\x1FMarkutan\x1FMerkutan\x1FJueʼKutan\x1FVierkutan\x1FSabʼkutan\x1FXBʼ\x1FLU\x1FMA\x1F" &
  "MR\x1FROʼ\x1FXWA\x1FXWU\x1FXbʼeen Raqalil li Chihabʼ\x1FXkabʼ Raqalil li Chihabʼ\x1FRox Raqalil li Chihabʼ\x1F" &
  "Xkaa Raqalil li Chihabʼ\x1FEQʼ\x1FEW\x1FMYQ\x1FYQJ\x1FEEEE, d, MMMM, y\x1FMMM-y\x1FE, d, MMM, y\x1Fd, MMM, y G\x1F" &
  "E, d, MMM, y G\x1F1-Kysã\x1F2-Kysã\x1F3-Kysã\x1F4-Kysã\x1F5-Kysã\x1F6-Kysã\x1F7-Kysã\x1F8-Kysã\x1F9-Kysã\x1F" &
  "10-Kysã\x1F11-Kysã\x1F12-Kysã\x1F1Ky.\x1F2Ky.\x1F3Ky.\x1F4Ky.\x1F5Ky.\x1F6Ky.\x1F7Ky.\x1F8Ky.\x1F9Ky.\x1F10Ky.\x1F11Ky.\x1F" &
  "12Ky.\x1Fnumĩggu\x1Fpir-kurã-há\x1Frégre-kurã-há\x1Ftẽgtũ-kurã-há\x1Fvẽnhkãgra-kurã-há\x1F" &
  "pénkar-kurã-há\x1Fsavnu\x1Fnum.\x1Fpir.\x1Frég.\x1Ftẽg.\x1Fvẽn.\x1Fpén.\x1Fsav.\x1F1ⁿ kysã-tẽgtũ\x1F" &
  "2ᵍᵉ kysã-tẽgtũ\x1F3ⁿʰ kysã-tẽgtũ\x1F4ⁿ kysã-tẽgtũ\x1FC.j.\x1FC.kk.\x1FEEEE, d 'ne' MMMM, y\x1F" &
  "d 'ne' MMMM, y\x1Fd 'ne' MMM, y\x1FE, d 'ne' MMM, y\x1Fd 'ne' MMM, y G\x1FE, d 'ne' MMM, y G\x1F" &
  "d 'ne' MMM\x1FE, d 'ne' MMM\x1Fd 'ne' MMMM\x1FMMM, y G\x1FAtini\x1FAtalata\x1FAlhamiisa\x1FAljuma\x1FAssabdu\x1F" &
  "Alj\x1FAss\x1FAdduha\x1FAluula\x1FMũgaa\x1FMũgetho\x1FKĩhu\x1FMũthatũ\x1FMũgiranjara\x1FGathathanwa\x1FGathano\x1F" &
  "Mworia Nyoni\x1FMũgaa wa Kerĩ\x1FMwania Thenge\x1FKanyua Hũngũ\x1FGatumu\x1FMGA\x1FMGE\x1FKH\x1FMŨTH\x1F" &
  "MGNJ\x1FGATH\x1FGATHN\x1FMWNY\x1FMŨGK\x1FMWTH\x1FKNY\x1FGAT\x1FMũgĩranjara\x1FMwambĩrĩrio\x1FWaĩrĩ\x1FWetatũ\x1F" &
  "Wena\x1FWetano\x1FNjuuma\x1FKMA\x1FMWA\x1FWAĨ\x1FWETŨ\x1FWEN\x1FWETO\x1FNJU\x1FRobo ya mbere\x1FRobo ya kerĩ\x1FRobo ya gatatũ\x1F" &
  "Robo ya kana\x1FKiroko\x1FHwaĩ-inĩ\x1Fdd-MM-YYYY\x1Fh:mm:ss a\x1Fқаңтар\x1Fақпан\x1Fнаурыз\x1F" &
  "сәуір\x1Fмамыр\x1Fмаусым\x1Fшілде\x1Fтамыз\x1Fқыркүйек\x1Fқазан\x1F" &
  "қараша\x1Fжелтоқсан\x1Fқаң.\x1Fақп.\x1Fнау.\x1Fсәу.\x1Fмам.\x1Fмау.\x1Fшіл.\x1F" &
  "там.\x1Fқыр.\x1Fқаз.\x1Fқар.\x1Fжел.\x1FҚаңтар\x1FАқпан\x1FНаурыз\x1FСәуір\x1F" &
  "Мамыр\x1FМаусым\x1FШілде\x1FТамыз\x1FҚыркүйек\x1FҚазан\x1FҚараша\x1F" &
  "Желтоқсан\x1Fжексенбі\x1Fдүйсенбі\x1Fсейсенбі\x1Fсәрсенбі\x1F" &
  "бейсенбі\x1Fжұма\x1Fсенбі\x1Fжс\x1Fдс\x1Fсс\x1Fбс\x1Fжм\x1FІ тоқсан\x1FІІ тоқсан\x1F" &
  "ІІІ тоқсан\x1FIV тоқсан\x1FІ тқс.\x1FІІ тқс.\x1FІІІ тқс.\x1FIV тқс.\x1F" &
  "б.з.д.\x1Fб.з.\x1Fy 'ж'. d MMMM, EEEE\x1Fy 'ж'. d MMMM\x1Fy 'ж'. dd MMM\x1Fy 'ж'. MMM\x1F" &
  "y 'ж'. MMMM\x1Fy 'ж'. d MMM\x1Fy 'ж'. d MMM, E\x1Fdd-MM-GGGGG y\x1FG y 'ж'. d MMM\x1F" &
  "G y 'ж'. d MMM, E\x1FG y 'ж'. MMM\x1Fy 'ж'. QQQ\x1Fy 'ж'. QQQQ\x1FG y 'ж'.\x1F#,##0.00¤;(#,##0.00¤)\x1F" &
  "قاڭتار\x1Fاقپان\x1Fناۋرىز\x1Fءساۋىر\x1Fمامىر\x1Fماۋسىم\x1Fشىلدە\x1F" &
  "تامىز\x1Fقىركۇيەك\x1Fقازان\x1Fقاراشا\x1Fجەلتوقسان\x1Fجەكسەنبى\x1F" &
  "دۇيسەنبى\x1Fسەيسەنبى\x1Fسارسەنبى\x1Fبەيسەنبى\x1Fجۇما\x1Fسەنبى\x1F" &
  "جەك\x1Fدۇي\x1Fسەي\x1Fسار\x1Fبەي\x1Fجۇم\x1Fسەن\x1Fءبىرىنشى توقسان\x1Fەكىنشى توقسان\x1F" &
  "ءۇشىنشى توقسان\x1Fءتورتىنشى توقسان\x1F1-توقسان\x1F2-توقسان\x1F" &
  "3-توقسان\x1F4-توقسان\x1Fت د\x1Fت ك\x1Fب ز د\x1Fب ز\x1Fy، d-MMMM، EEEE\x1Fy، d-MMMM\x1F" &
  "y، d-MMM\x1Fy-d-M\x1Fy-d-M، E\x1Fy d- MMM\x1Fy d- MMM، E\x1FG d-M-y\x1FG y، d-MMM\x1FG y، d-MMM، E\x1F" &
  "d-M، E\x1Fd-MMM، E\x1Fd-MMMM\x1Fpamba\x1Fwanja\x1Fmbiyɔ mɛndoŋgɔ\x1FNyɔlɔmbɔŋgɔ\x1FMɔnɔ ŋgbanja\x1F" &
  "Nyaŋgwɛ ŋgbanja\x1Fkuŋgwɛ\x1Ffɛ\x1Fnjapi\x1Fnyukul\x1Fɓulɓusɛ\x1Fsɔndi\x1Fmɛrkɛrɛdi\x1Fyedi\x1F" &
  "vaŋdɛrɛdi\x1Fmɔnɔ sɔndi\x1Fdd/MM y\x1FE dd/MM y\x1FMM y\x1Fjanuaarip\x1Ffebruaarip\x1Fmarsip\x1Fapriilip\x1F" &
  "maajip\x1Fjuunip\x1Fjuulip\x1Faggustip\x1Fseptembarip\x1Foktobarip\x1Fnovembarip\x1Fdecembarip\x1Ffebr\x1Fjanuaari\x1F" &
  "februaari\x1Fmarsi\x1Fapriili\x1Fmaaji\x1Faggusti\x1Fseptembari\x1Foktobari\x1Fnovembari\x1Fdecembari\x1Fsapaat\x1F" &
  "ataasinngorneq\x1Fmarlunngorneq\x1Fpingasunngorneq\x1Fsisamanngorneq\x1Ftallimanngorneq\x1Farfininngorneq\x1F" &
  "sap\x1Fata\x1Fpin\x1Fsis\x1Ftal\x1Farf\x1FMulgul\x1FNg’atyaato\x1FKiptaamo\x1FIwootkuut\x1FMamuut\x1FPaagi\x1FNg’eiyeet\x1F" &
  "Rooptui\x1FBureet\x1FEpeeso\x1FKipsuunde ne taai\x1FKipsuunde nebo aeng’\x1FNgat\x1FTaa\x1FIwo\x1FMam\x1FPaa\x1F" &
  "Nge\x1FRoo\x1FBur\x1FEpe\x1FKpt\x1FKpa\x1FKotisap\x1FKotaai\x1FKoaeng’\x1FKosomok\x1FKoang’wan\x1FKomuut\x1FKolo\x1F" &
  "Kts\x1FKot\x1FKoo\x1FKos\x1FKoa\x1FKom\x1FKol\x1FRobo netai\x1FRobo nebo aeng’\x1FRobo nebo somok\x1FRobo nebo ang’wan\x1F" &
  "krn\x1Fkoosk\x1FKO\x1Fមករា\x1Fកុម្ភៈ\x1Fមីនា\x1Fមេសា\x1Fឧសភា\x1F" &
  "មិថុនា\x1Fកក្កដា\x1Fសីហា\x1Fកញ្ញា\x1Fតុលា\x1Fវិច្ឆិកា\x1F" &
  "ធ្នូ\x1Fអាទិត្យ\x1Fច័ន្ទ\x1Fអង្គារ\x1Fពុធ\x1Fព្រហស្បតិ៍\x1F" &
  "សុក្រ\x1Fសៅរ៍\x1Fចន្ទ\x1Fព្រហ\x1Fត្រីមាសទី 1\x1F" &
  "ត្រីមាសទី 2\x1Fត្រីមាសទី 3\x1Fត្រីមាសទី 4\x1F" &
  "មុន គ.ស.\x1Fគ.ស.\x1Fಜನವರಿ\x1Fಫೆಬ್ರವರಿ\x1Fಮಾರ್ಚ್\x1F" &
  "ಏಪ್ರಿಲ್\x1Fಮೇ\x1Fಜೂನ್\x1Fಜುಲೈ\x1Fಆಗಸ್ಟ್\x1Fಸೆಪ್ಟೆಂಬರ್\x1F" &
  "ಅಕ್ಟೋಬರ್\x1Fನವೆಂಬರ್\x1Fಡಿಸೆಂಬರ್\x1Fಜನ\x1Fಫೆಬ್ರ\x1F" &
  "ಏಪ್ರಿ\x1Fಆಗ\x1Fಸೆಪ್ಟೆಂ\x1Fಅಕ್ಟೋ\x1Fನವೆಂ\x1Fಡಿಸೆಂ\x1F" &
  "ಭಾನುವಾರ\x1Fಸೋಮವಾರ\x1Fಮಂಗಳವಾರ\x1Fಬುಧವಾರ\x1F" &
  "ಗುರುವಾರ\x1Fಶುಕ್ರವಾರ\x1Fಶನಿವಾರ\x1Fಭಾನು\x1Fಸೋಮ\x1F" &
  "ಮಂಗಳ\x1Fಬುಧ\x1Fಗುರು\x1Fಶುಕ್ರ\x1Fಶನಿ\x1F1ನೇ ತ್ರೈಮಾಸಿಕ\x1F" &
  "2ನೇ ತ್ರೈಮಾಸಿಕ\x1F3ನೇ ತ್ರೈಮಾಸಿಕ\x1F4ನೇ ತ್ರೈಮಾಸಿಕ\x1F" &
  "ತ್ರೈ 1\x1Fತ್ರೈ 2\x1Fತ್ರೈ 3\x1Fತ್ರೈ 4\x1Fಕ್ರಿ.ಪೂ\x1Fಕ್ರಿ.ಶ\x1F" &
  "d/M, E\x1F1월\x1F2월\x1F3월\x1F4월\x1F5월\x1F6월\x1F7월\x1F8월\x1F9월\x1F10월\x1F11월\x1F12월\x1F일요일\x1F월요일\x1F" &
  "화요일\x1F수요일\x1F목요일\x1F금요일\x1F토요일\x1F일\x1F월\x1F화\x1F수\x1F목\x1F금\x1F토\x1F제 1/4분기\x1F" &
  "제 2/4분기\x1F제 3/4분기\x1F제 4/4분기\x1F1분기\x1F2분기\x1F3분기\x1F4분기\x1F오전\x1F" &
  "오후\x1Fy년 MMMM d일 EEEE\x1Fy년 MMMM d일\x1Fy. M. d.\x1Fyy. M. d.\x1Fa h시 m분 s초 zzzz\x1F" &
  "a h시 m분 s초 z\x1Fy/M/d E\x1Fy년 MMM\x1Fy년 MMMM\x1Fy년 MMM d일\x1Fy년 MMM d일 (E)\x1FGGGGG y/M/d\x1F" &
  "G y년 MMM d일\x1FG y년 MMM d일 (E)\x1FM. d. (E)\x1FMMM d일\x1FMMM d일 (E)\x1FMMMM d일\x1FG y년 MMM\x1F" &
  "y년 QQQ\x1Fy년 QQQQ\x1FG y년\x1Fy년\x1FM월\x1Fd일\x1Fd일 (E)\x1FH시\x1Fa h시\x1Fzzzz HH:mm:ss\x1Fz HH:mm:ss\x1F" &
  "जानेवारी\x1Fफेब्रुवारी\x1Fएप्रील\x1Fजुलय\x1F" &
  "ऑगस्ट\x1Fसप्टेंबर\x1Fऑक्टोबर\x1Fनोव्हेंबर\x1F" &
  "डिसेंबर\x1Fजाने\x1Fफेब्रु\x1Fएप्री\x1Fऑग\x1Fसप्टें\x1F" &
  "ऑक्टो\x1Fनोव्हें\x1Fडिसें\x1Fआयतार\x1Fसोमार\x1F" &
  "मंगळार\x1Fबिरेस्तार\x1Fशुक्रार\x1Fशेनवार\x1F" &
  "1लें त्रैमासीक\x1F2रें त्रैमासीक\x1F3रें त्रैमासीक\x1F" &
  "4थें त्रैमासीक\x1Fक्रिस्तपूर्व\x1Fक्रि.श.\x1F" &
  "d-MMM-y\x1Fd-M-y, E\x1Fd-M, E\x1FJaner\x1FFebrer\x1FAgost\x1FSetembr\x1FOtubr\x1FNovembr\x1FDezembr\x1FAitar\x1FSomar\x1F" &
  "Mongllar\x1FBudhvar\x1FBirestar\x1FSukrar\x1FSonvar\x1FAit\x1FMon\x1FBud\x1FBre\x1FSuk\x1FSon\x1F1lem timhoinallem\x1F" &
  "2rem timhoinallem\x1F3rem timhoinallem\x1F4them timhoinallem\x1FTimh1\x1FTimh2\x1FTimh3\x1FTimh4\x1FKA\x1F" &
  "a h:mm:ss zzzz\x1Fa h:mm:ss z\x1FE, d-M-y\x1Fd-M-y G\x1Fdd-MM, E\x1FHH'v'\x1Fa h 'vaztam'\x1F،\x1F" &
  "فروری\x1Fمئی\x1Fجوٗن\x1Fجُلایی\x1Fستمبر\x1Fاکتوٗبر\x1Fجوٗلایی\x1F" &
  "آتھوار\x1Fژٔندرٕروار\x1Fبۆموار\x1Fبودوار\x1Fبرؠسوار\x1Fجُمہ\x1F" &
  "بٹوار\x1Fژٔندٕروار\x1Fگۄڑنیُک ژۄباگ\x1Fدۆیِم ژۄباگ\x1Fتریِم ژۄباگ\x1F" &
  "ژوٗرِم ژۄباگ\x1Fکیو 1\x1Fکیو 2\x1Fکیو 3\x1Fکیو 4\x1Fبی سی\x1Fاے ڈی\x1FM/d/y GGGGG\x1F" &
  "सतमबर\x1Fनवमबर\x1Fदसमबर\x1Fसतुंबर\x1Fनवूमबर\x1F" &
  "अकतुम्बर\x1Fदसूमबर\x1Fआथवार\x1Fच़ंदिरवार\x1F" &
  "बोमवार\x1Fबोदवार\x1Fब्रेसवार\x1Fजुमा\x1Fबटवार\x1F" &
  "चंदिरवार\x1Fबुवार\x1F1st सह माह\x1F2nd सह माह\x1F" &
  "3rd सह माह\x1F4th सह माह\x1FJanuali\x1FFebluali\x1FAplili\x1FJumaapii\x1FJumaatatu\x1F" &
  "Jumaane\x1FJumaatano\x1FJumaamosi\x1FJmn\x1FLobo ya bosi\x1FLobo ya mbii\x1FLobo ya nnd’atu\x1FLobo ya nne\x1F" &
  "makeo\x1Fnyiaghuo\x1Fŋwíí a ntɔ́ntɔ\x1Fŋwíí akǝ bɛ́ɛ\x1Fŋwíí akǝ ráá\x1Fŋwíí akǝ nin\x1F" &
  "ŋwíí akǝ táan\x1Fŋwíí akǝ táafɔk\x1Fŋwíí akǝ táabɛɛ\x1Fŋwíí akǝ táaraa\x1F" &
  "ŋwíí akǝ táanin\x1Fŋwíí akǝ ntɛk\x1Fŋwíí akǝ ntɛk di bɔ́k\x1Fŋwíí akǝ ntɛk di bɛ́ɛ\x1F" &
  "ŋ1\x1Fŋ2\x1Fŋ3\x1Fŋ4\x1Fŋ5\x1Fŋ6\x1Fŋ7\x1Fŋ8\x1Fŋ9\x1Fŋ10\x1Fŋ11\x1Fŋ12\x1Fsɔ́ndǝ\x1Flǝndí\x1Fmaadí\x1Fmɛkrɛdí\x1F" &
  "jǝǝdí\x1Fjúmbá\x1Fsamdí\x1Flǝn\x1Fmaa\x1Fmɛk\x1Fjǝǝ\x1Fjúm\x1Fsam\x1Fid́ɛ́n kǝbǝk kǝ ntɔ́ntɔ́\x1F" &
  "idɛ́n kǝbǝk kǝ kǝbɛ́ɛ\x1Fidɛ́n kǝbǝk kǝ kǝráá\x1Fidɛ́n kǝbǝk kǝ kǝnin\x1F" &
  "i1\x1Fi2\x1Fi3\x1Fi4\x1Fsárúwá\x1Fcɛɛ́nko\x1Fd.Y.\x1Fk.Y.\x1FJannewa\x1FFäbrowa\x1FMääz\x1FAprell\x1FJuuni\x1FJuuli\x1F" &
  "Oujoß\x1FOktohber\x1FFäb\x1FMäz\x1FOuj\x1FSäp\x1FFäb.\x1FMäz.\x1FOuj.\x1FSäp.\x1FSunndaach\x1FMohndaach\x1FDinnsdaach\x1F" &
  "Metwoch\x1FDunnersdaach\x1FFriidaach\x1FSamsdaach\x1FMe.\x1F1. Quattahl\x1F2. Quattahl\x1F3. Quattahl\x1F" &
  "4. Quattahl\x1F1.Q.\x1F2.Q.\x1F3.Q.\x1F4.Q.\x1Fv.M.\x1Fn.M.\x1FEEEE, 'dä' d. MMMM y\x1Fd. MMM. y\x1FE d. MMM. y\x1F" &
  "Y-MM\x1FQQQy\x1FE 'dä' d.\x1F%#,##0\x1Frêbendan\x1Fsibat\x1Fadar\x1Fnîsan\x1Fgulan\x1Fhezîran\x1Ftîrmeh\x1Ftebax\x1F" &
  "îlon\x1Fcotmeh\x1Fmijdar\x1Fberfanbar\x1Frbn\x1Fsbt\x1Fadr\x1Fnsn\x1Fgln\x1Fhzr\x1Ftrm\x1Ftbx\x1Fîln\x1Fcot\x1Fmjd\x1Fbrf\x1Fyekşem\x1F" &
  "duşem\x1Fsêşem\x1Fçarşem\x1Fpêncşem\x1Fînî\x1Fşemî\x1Fyşm\x1Fdşm\x1Fsşm\x1Fçşm\x1Fpşm\x1Fşem\x1Fçaryeka 1ê\x1F" &
  "çaryeka 2an\x1Fçaryeka 3an\x1Fçaryeka 4an\x1FÇ1\x1FÇ2\x1FÇ3\x1FÇ4\x1FBN\x1FPN\x1FEEEE, d'ê' MMMM'a' y'an'\x1F" &
  "d'ê' MMMM'a' y'an'\x1FMMMM'a' y'an'\x1FG d/M/y\x1FG d MMM, y\x1Fd'ê' MMMM'ê'\x1FQQQQ 'ya' y'an'\x1F" &
  "mis Genver\x1Fmis Hwevrer\x1Fmis Meurth\x1Fmis Ebrel\x1Fmis Me\x1Fmis Metheven\x1Fmis Gortheren\x1Fmis Est\x1F" &
  "mis Gwynngala\x1Fmis Hedra\x1Fmis Du\x1Fmis Kevardhu\x1FGen\x1FHwe\x1FMeu\x1FMet\x1FGwn\x1FHed\x1FKev\x1Fdy Sul\x1Fdy Lun\x1F" &
  "dy Meurth\x1Fdy Merher\x1Fdy Yow\x1Fdy Gwener\x1Fdy Sadorn\x1FMth\x1FMhr\x1FYow\x1FGwe\x1Fpusu lenju\x1Fmaha lenju\x1F" &
  "pagu lenju\x1Fhire lenju\x1Fbese lenju\x1Fjaṭṭa lenju\x1Faasaḍi lenju\x1Fsrabĩ lenju\x1Fbado lenju\x1F" &
  "dasara lenju\x1Fdivi lenju\x1Fpande lenju\x1Fpusu\x1Fmaha\x1Fpagu\x1Fhire\x1Fbese\x1Fjaṭṭa\x1Faasaḍi\x1Fsrabĩ\x1F" &
  "bado\x1Fdasara\x1Fdivi\x1Fpande\x1Faadi vara\x1Fsmbara\x1Fmangaḍa\x1Fpudara\x1Flaki vara\x1Fsukru vara\x1Fsani vara\x1F" &
  "aadi\x1Fsmba\x1Fmanga\x1Fpuda\x1Flaki\x1Fsukru\x1Fsani\x1F1sṭ kuarṭr\x1F2nḍ kuarṭr\x1F3rḍ kuarṭr\x1F" &
  "4th kuarṭr\x1Fbc\x1Fad\x1Fपुसु लेञ्जु\x1Fमाहाका लेञ्जु\x1F" &
  "पागुणी लेञ्जु\x1Fहिरे लेञ्जु\x1Fबेसे लेञ्जु\x1F" &
  "जाटा लेञ्जु\x1Fआसाड़ी लेञ्जु\x1Fस्राबाँ लेञ्जु\x1F" &
  "बोदो लेञ्जु\x1Fदसारा लेञ्जु\x1Fदिवी लेञ्जु\x1F" &
  "पान्डे लेञ्जु\x1Fपुसु\x1Fमाहा\x1Fपागु\x1Fहिर्रे\x1F" &
  "बेसे\x1Fजाट्टा\x1Fआसाड़ी\x1Fस्राबाँ\x1Fबाॅदो\x1F" &
  "दासारा\x1Fदिवी\x1Fपान्डे\x1Fआदि वारा\x1Fसाॅम्वारा\x1F" &
  "मंगाड़ा\x1Fपुद्दारा\x1Fलाक्कि वारा\x1Fसुकुरु वारा\x1F" &
  "सान्नि वारा\x1Fआदि\x1Fसाॅम्मा\x1Fमान्गा\x1F" &
  "पूदा\x1Fलाक्की\x1Fसुकुरु\x1Fसान्नि\x1F१स्ट क्वाटर\x1F" &
  "२ क्वाटर\x1F३र्ड क्वाटर\x1F४थ क्वाटर\x1F" &
  "क १\x1Fक २\x1Fक ३\x1Fक ४\x1Fए एम\x1Fपी एम\x1Fबिसि\x1Fए-डि\x1F" &
  "ପୁସୁ ଲେଞ୍ଜୁ\x1Fମାହାକା ଲେଞ୍ଜୁ\x1Fପାଗୁଣି ଲେଞ୍ଜୁ\x1F" &
  "ହିରେ ଲେଞ୍ଜୁ\x1Fବେସେ ଲେଞ୍ଜୁ\x1Fଜାଟା ଲେଞ୍ଜୁ\x1F" &
  "ଆସାଡ଼ି ଲେଞ୍ଜୁ\x1Fସ୍ରାବାଁ ଲେଞ୍ଜୁ\x1Fବଦ ଲେଞ୍ଜୁ\x1F" &
  "ଦାସାରା ଲେଞ୍ଜୁ\x1Fଦିୱିଡ଼ି ଲେଞ୍ଜୁ\x1Fପାଣ୍ଡେ ଲେଞ୍ଜୁ\x1F" &
  "ପୁସୁ\x1Fମାହା\x1Fପାଗୁ\x1Fହିରେ\x1Fବେସେ\x1Fଜାଟା\x1Fଆସାଡ଼ି\x1F" &
  "ସ୍ରାବାଁ\x1Fବଦ\x1Fଦାସାରା\x1Fଦିୱି\x1Fପାଣ୍ଡେ\x1Fଆଦି ୱାରା\x1F" &
  "ସମ୍ବାରା\x1Fମାଙ୍ଗାଡ଼ା\x1Fପୁଦାରା\x1Fଲାକି ୱାରା\x1F" &
  "ସୁକ୍ରୁ ୱାରା\x1Fସାନି ୱାରା\x1Fଆଦି\x1Fସମ୍ବା\x1F" &
  "ମାଙ୍ଗା\x1Fପୁଦା\x1Fଲାକି\x1Fସୁକ୍ରୁ\x1Fସାନି\x1F୧ମ କ୍ୱାଟର\x1F" &
  "୨ୟ କ୍ୱାଟର\x1F୩ୟ କ୍ୱାଟର\x1F୪ର୍ଥ କ୍ୱାଟର\x1F" &
  "କ ୧\x1Fକ ୨\x1Fକ ୩\x1Fକ ୪\x1Fଏ ଏମ\x1Fପି ଏମ\x1Fବିସି\x1Fଏଡି\x1F" &
  "మాగ\x1Fగుండు\x1Fహిరెఇ\x1Fబెసెకి\x1Fలండి\x1Fరాత\x1F" &
  "బాన్దపాణా\x1Fబార్సి\x1Fఅస్ర\x1Fదివెడి\x1Fపాండు\x1F" &
  "పుసు\x1Fవారమి\x1Fనమారా\x1Fమాంగాడా\x1Fవుదారా\x1F" &
  "లాకివరా\x1Fనుక్ వరా\x1Fసానివరా\x1F౧వ త్రైమాసికం\x1F" &
  "౨వ త్రైమాసికర\x1F౩వ త్రైమాసికర\x1F౪వ త్రైమాసికర\x1F" &
  "త్రై౧\x1Fత్రై౨\x1Fత్రై౩\x1Fత్రై౪\x1Fఎ ఎమ్\x1Fపి ఎమ్\x1F" &
  "క్రీపూ\x1Fక్రీశ\x1Fянв.\x1Fсен.\x1Fноя.\x1FЯнварь\x1FФевраль\x1F" &
  "Апрель\x1FИюнь\x1FИюль\x1FСентябрь\x1FОктябрь\x1FНоябрь\x1FДекабрь\x1F" &
  "Янв\x1FФев\x1FМар\x1FАпр\x1FИюн\x1FИюл\x1FАвг\x1FСен\x1FОкт\x1FНоя\x1FДек\x1Fжекшемби\x1F" &
  "дүйшөмбү\x1Fшейшемби\x1Fшаршемби\x1Fбейшемби\x1Fжума\x1Fишемби\x1F" &
  "жек.\x1Fдүй.\x1Fшейш.\x1Fшарш.\x1Fбейш.\x1Fишм.\x1F1-чейрек\x1F2-чейрек\x1F" &
  "3-чейрек\x1F4-чейрек\x1F1-чей.\x1F2-чей.\x1F3-чей.\x1F4-чей.\x1Fтң\x1Fтк\x1Fб.з.ч.\x1F" &
  "y-'ж'., d-MMMM, EEEE\x1Fy-'ж'., d-MMMM\x1Fy-'ж'., d-MMM\x1Fy-'ж'. MMM\x1Fy-'ж'., MMMM\x1Fy-'ж'. d-MMM\x1F" &
  "y-'ж'. d-MMM, E\x1FG y-'ж'. d-MMM\x1FG y-'ж'. d-MMM, E\x1Fd-MMM, E\x1FG y-'ж'. MMM\x1Fy-'ж'., QQQ\x1F" &
  "y-'ж'., QQQQ\x1FG y-'ж'.\x1FKʉfúngatɨ\x1FKʉnaanɨ\x1FKʉkeenda\x1FKwiikumi\x1FKwiinyambála\x1FKwiidwaata\x1F" &
  "Kʉmʉʉnchɨ\x1FKʉvɨɨrɨ\x1FKʉsaatʉ\x1FKwiinyi\x1FKʉsaano\x1FKʉsasatʉ\x1FFúngatɨ\x1FNaanɨ\x1F" &
  "Keenda\x1FIkúmi\x1FInyambala\x1FIdwaata\x1FMʉʉnchɨ\x1FVɨɨrɨ\x1FSaatʉ\x1FInyi\x1FSaano\x1FSasatʉ\x1FJumapíiri\x1F" &
  "Jumatátu\x1FJumaíne\x1FJumatáano\x1FAlamíisi\x1FIjumáa\x1FJumamóosi\x1FPíili\x1FTáatu\x1FÍne\x1FTáano\x1F" &
  "Móosi\x1FNcholo ya 1\x1FNcholo ya 2\x1FNcholo ya 3\x1FNcholo ya 4\x1FNcho 1\x1FNcho 2\x1FNcho 3\x1FNcho 4\x1F" &
  "TOO\x1FMUU\x1FKSA\x1FMäerz\x1FAbrëll\x1FMäe.\x1FMäe\x1FSonndeg\x1FMéindeg\x1FDënschdeg\x1FMëttwoch\x1FDonneschdeg\x1F" &
  "Freideg\x1FSamschdeg\x1FSon.\x1FMéi.\x1FDën.\x1FMët.\x1FDon.\x1FFre.\x1FSam.\x1Fmoies\x1Fnomëttes\x1FHH 'Auer'\x1F" &
  "Janwaliyo\x1FFebwaliyo\x1FMarisi\x1FApuli\x1FMaayi\x1FJulaayi\x1FAgusito\x1FSebuttemba\x1FOkitobba\x1FApu\x1FSeb\x1F" &
  "Oki\x1FSabbiiti\x1FBalaza\x1FLwakubiri\x1FLwakusatu\x1FLwakuna\x1FLwakutaano\x1FLwamukaaga\x1FBal\x1FLw2\x1FLw3\x1F" &
  "Lw4\x1FLw5\x1FLw6\x1FKyakuna 1\x1FKyakuna 2\x1FKyakuna 3\x1FKyakuna 4\x1FKya1\x1FKya2\x1FKya3\x1FKya4\x1Fde zenâ\x1F" &
  "de frevâ\x1Fde marso\x1Fd’arvî\x1Fde mazzo\x1Fde zugno\x1Fde luggio\x1Fd’agosto\x1Fde settembre\x1F" &
  "d’ottobre\x1Fde dexembre\x1Fde zen.\x1Fde fre.\x1Fde mar.\x1Fd’arv.\x1Fde maz.\x1Fde zug.\x1Fde lug.\x1F" &
  "d’ago.\x1Fd’ott.\x1Fde dex.\x1Fzenâ\x1Ffrevâ\x1Fmarso\x1Farvî\x1Fmazzo\x1Fzugno\x1Fluggio\x1Fdexembre\x1Fzen.\x1F" &
  "arv.\x1Fmaz.\x1Fzug.\x1Flug.\x1Fott.\x1Fdex.\x1Fdomenega\x1Flunesdì\x1Fmätesdì\x1Fmäcordì\x1Fzeuggia\x1Fvenardì\x1F" &
  "sabbo\x1Fmät.\x1Fmäc.\x1Fzeu.\x1Fsab.\x1F1º quadrimestre\x1F2º quadrimestre\x1F3º quadrimestre\x1F4º quadrimestre\x1F" &
  "EEEE d MMMM 'do' y\x1Fd MMMM 'do' y\x1Fd MMM 'do' y\x1FLLL 'do' y\x1FLLLL 'do' y\x1FE d MMM 'do' y\x1F" &
  "d MMM 'do' y G\x1FE d MMM 'do' y G\x1FQQQQ 'do' y\x1FWiótheȟika Wí\x1FThiyóȟeyuŋka Wí\x1F" &
  "Ištáwičhayazaŋ Wí\x1FPȟežítȟo Wí\x1FČhaŋwápetȟo Wí\x1FWípazukȟa-wašté Wí\x1F" &
  "Čhaŋpȟásapa Wí\x1FWasútȟuŋ Wí\x1FČhaŋwápeǧi Wí\x1FČhaŋwápe-kasná Wí\x1FWaníyetu Wí\x1F" &
  "Tȟahékapšuŋ Wí\x1FAŋpétuwakȟaŋ\x1FAŋpétuwaŋži\x1FAŋpétunuŋpa\x1FAŋpétuyamni\x1F" &
  "Aŋpétutopa\x1FAŋpétuzaptaŋ\x1FOwáŋgyužažapi\x1Fde jená\x1Fde forá\x1Fde merz\x1Fd’aurí\x1F" &
  "de ma\x1Fde jügn\x1Fde messé\x1Fd’aost\x1Fde setëmber\x1Fd’otober\x1Fde novëmber\x1Fde dezëmber\x1F" &
  "jená\x1Fforá\x1Fmerz\x1Faurí\x1Fjügn\x1Fmessé\x1Faost\x1Fsetëmber\x1Fotober\x1Fnovëmber\x1Fdezëmber\x1Foto\x1F" &
  "dez\x1Fdomënia\x1Flönesc\x1Fmertesc\x1Fmercui\x1Fjöbia\x1Fvëndres\x1Fsabeda\x1Flön\x1Fmert\x1Fmerc\x1Fjöb\x1Fvën\x1F" &
  "pröm trimester\x1Fsecundo trimester\x1Fterzo trimester\x1Fcuarto trimester\x1Fdan G.C.\x1FEEEE, d MMMM 'dl' y\x1F" &
  "sginer\x1Ffevrer\x1Fmarz\x1Fmasg\x1Fsgiugn\x1Fluj\x1Favost\x1Fsetember\x1Fotover\x1Fdicember\x1Flundì\x1Fmardì\x1Fmercoldì\x1F" &
  "sgiovedì\x1Fsabet\x1Fsánzá ya yambo\x1Fsánzá ya míbalé\x1Fsánzá ya mísáto\x1Fsánzá ya mínei\x1F" &
  "sánzá ya mítáno\x1Fsánzá ya motóbá\x1Fsánzá ya nsambo\x1Fsánzá ya mwambe\x1Fsánzá ya libwa\x1F" &
  "sánzá ya zómi\x1Fsánzá ya zómi na mɔ̌kɔ́\x1Fsánzá ya zómi na míbalé\x1Ffbl\x1F" &
  "msi\x1Fapl\x1Fyun\x1Fyul\x1Fagt\x1Fstb\x1Fɔtb\x1Fnvb\x1Fdsb\x1Feyenga\x1Fmokɔlɔ mwa yambo\x1Fmokɔlɔ mwa míbalé\x1F" &
  "mokɔlɔ mwa mísáto\x1Fmokɔlɔ ya mínéi\x1Fmokɔlɔ ya mítáno\x1Fmpɔ́sɔ\x1Feye\x1Fybo\x1F" &
  "mbl\x1Fmst\x1Fmin\x1Fmtn\x1Fmps\x1Fsánzá mísáto ya yambo\x1Fsánzá mísáto ya míbalé\x1Fsánzá mísáto ya mísáto\x1F" &
  "sánzá mísáto ya mínei\x1FSM1\x1FSM2\x1FSM3\x1FSM4\x1Fntɔ́ngɔ́\x1Fmpókwa\x1Flibóso ya\x1Fnsima ya Y\x1F" &
  "ມັງກອນ\x1Fກຸມພາ\x1Fມີນາ\x1Fເມສາ\x1Fພຶດສະພາ\x1F" &
  "ມິຖຸນາ\x1Fກໍລະກົດ\x1Fສິງຫາ\x1Fກັນຍາ\x1Fຕຸລາ\x1F" &
  "ພະຈິກ\x1Fທັນວາ\x1Fມ.ກ.\x1Fກ.ພ.\x1Fມ.ນ.\x1Fມ.ສ.\x1Fພ.ພ.\x1Fມິ.ຖ.\x1F" &
  "ກ.ລ.\x1Fສ.ຫ.\x1Fກ.ຍ.\x1Fຕ.ລ.\x1Fພ.ຈ.\x1Fທ.ວ.\x1Fວັນອາທິດ\x1Fວັນຈັນ\x1F" &
  "ວັນອັງຄານ\x1Fວັນພຸດ\x1Fວັນພະຫັດ\x1Fວັນສຸກ\x1F" &
  "ວັນເສົາ\x1Fອາທິດ\x1Fຈັນ\x1Fອັງຄານ\x1Fພຸດ\x1Fພະຫັດ\x1F" &
  "ສຸກ\x1Fເສົາ\x1Fໄຕຣມາດ 1\x1Fໄຕຣມາດ 2\x1Fໄຕຣມາດ 3\x1F" &
  "ໄຕຣມາດ 4\x1Fຕມ1\x1Fຕມ2\x1Fຕມ3\x1Fຕມ4\x1Fກ່ອນທ່ຽງ\x1Fຫຼັງທ່ຽງ\x1F" &
  "ກ່ອນ ຄ.ສ.\x1Fຄ.ສ.\x1FH ໂມງ m ນາທີ ss ວິນາທີ zzzz\x1F" &
  "H ໂມງ m ນາທີ ss ວິນາທີ z\x1Fd/M/GGGGG y\x1Fd MMMM, G y\x1FE d MMMM, G y\x1F" &
  "h ໂມງa\x1Fجانڤیە\x1Fفئڤریە\x1Fآڤریل\x1Fجوٙأن\x1Fجوٙلا\x1Fآگوست\x1F" &
  "سئپتامر\x1Fئوکتوڤر\x1Fنوڤامر\x1Fدئسامر\x1Fsausio\x1Fvasario\x1Fkovo\x1Fbalandžio\x1F" &
  "gegužės\x1Fbirželio\x1Fliepos\x1Frugpjūčio\x1Frugsėjo\x1Fspalio\x1Flapkričio\x1Fgruodžio\x1Fsaus.\x1F" &
  "vas.\x1Fkov.\x1Fbal.\x1Fgeg.\x1Fbirž.\x1Fliep.\x1Frugp.\x1Frugs.\x1Fspal.\x1Flapkr.\x1Fgruod.\x1Fsausis\x1Fvasaris\x1Fkovas\x1F" &
  "balandis\x1Fgegužė\x1Fbirželis\x1Fliepa\x1Frugpjūtis\x1Frugsėjis\x1Fspalis\x1Flapkritis\x1Fgruodis\x1Fsekmadienis\x1F" &
  "pirmadienis\x1Fantradienis\x1Ftrečiadienis\x1Fketvirtadienis\x1Fpenktadienis\x1Fšeštadienis\x1Fsk\x1F" &
  "pr\x1Fan\x1Ftr\x1Fkt\x1Fpn\x1Fšt\x1FI ketvirtis\x1FII ketvirtis\x1FIII ketvirtis\x1FIV ketvirtis\x1FI k.\x1FII k.\x1F" &
  "III k.\x1FIV k.\x1Fpriešpiet\x1Fpopiet\x1Fpo Kr.\x1Fy 'm'. MMMM d 'd'., EEEE\x1Fy 'm'. MMMM d 'd'.\x1F" &
  "y 'm'. LLLL\x1Fy-MM-dd, E\x1Fy-MM-dd G, E\x1FMM-d\x1FMM-dd, E\x1FMMMM d 'd'.\x1Fy-MM G\x1Fy 'm'. G\x1Fdd\x1F" &
  "Ciongo\x1FLùishi\x1FLusòlo\x1FMùuyà\x1FLumùngùlù\x1FLufuimi\x1FKabàlàshìpù\x1FLùshìkà\x1FLutongolo\x1F" &
  "Lungùdi\x1FKaswèkèsè\x1FCiswà\x1FCio\x1FLus\x1FMuu\x1FLum\x1FLuf\x1FKab\x1FLush\x1FLut\x1FCis\x1FLumingu\x1FNkodya\x1F" &
  "Ndàayà\x1FNdangù\x1FNjòwa\x1FNgòvya\x1FLubingu\x1FNko\x1FNdy\x1FNdg\x1FNjw\x1FNgv\x1FLub\x1FMueji 1\x1FMueji 2\x1FMueji 3\x1F" &
  "Mueji 4\x1FM1\x1FM2\x1FM3\x1FM4\x1FDinda\x1FDilolo\x1Fkmp. Y.K.\x1Fkny. Y. K.\x1FDwe mar Achiel\x1FDwe mar Ariyo\x1F" &
  "Dwe mar Adek\x1FDwe mar Ang’wen\x1FDwe mar Abich\x1FDwe mar Auchiel\x1FDwe mar Abiriyo\x1FDwe mar Aboro\x1F" &
  "Dwe mar Ochiko\x1FDwe mar Apar\x1FDwe mar gi achiel\x1FDwe mar Apar gi ariyo\x1FDAC\x1FDAR\x1FDAD\x1FDAN\x1F" &
  "DAH\x1FDAU\x1FDAO\x1FDAB\x1FDOC\x1FDAP\x1FDGI\x1FDAG\x1FJumapil\x1FWuok Tich\x1FTich Ariyo\x1FTich Adek\x1FTich Ang’wen\x1F" &
  "Tich Abich\x1FNgeso\x1FJMP\x1FWUT\x1FTAR\x1FTAD\x1FTAN\x1FTAB\x1FNGS\x1Fnus mar nus 1\x1Fnus mar nus 2\x1Fnus mar nus 3\x1F" &
  "nus mar nus 4\x1FNMN1\x1FNMN2\x1FNMN3\x1FNMN4\x1FOD\x1FOT\x1F¤#,##0.00;¤- #,##0.00\x1FJumapiri\x1FMurwa wa Kanne\x1F" &
  "Murwa wa Katano\x1FJ2\x1FJ3\x1FJ4\x1FJ5\x1FAl\x1FIj\x1FJ1\x1FRobo ya Kala\x1FRobo ya Kaviri\x1FRobo ya Kavaga\x1FRobo ya Kanne\x1F" &
  "janvāris\x1Ffebruāris\x1Faprīlis\x1Fmaijs\x1Fjūnijs\x1Fjūlijs\x1Faugusts\x1Fseptembris\x1Foktobris\x1Fnovembris\x1F" &
  "decembris\x1Fjūn.\x1Fjūl.\x1Fsvētdiena\x1Fpirmdiena\x1Fotrdiena\x1Ftrešdiena\x1Fceturtdiena\x1Fpiektdiena\x1F" &
  "sestdiena\x1Fsvētd.\x1Fpirmd.\x1Fotrd.\x1Ftrešd.\x1Fceturtd.\x1Fpiektd.\x1Fsestd.\x1F1. ceturksnis\x1F2. ceturksnis\x1F" &
  "3. ceturksnis\x1F4. ceturksnis\x1F1. cet.\x1F2. cet.\x1F3. cet.\x1F4. cet.\x1Fpriekšp.\x1Fpēcp.\x1F" &
  "p.m.ē.\x1Fm.ē.\x1FEEEE, y. 'gada' d. MMMM\x1Fy. 'gada' d. MMMM\x1Fy. 'gada' d. MMM\x1Fd.MM.y.\x1F" &
  "E, d.MM.y.\x1Fy. 'g'. MMM\x1Fy. 'gada'. MMMM\x1Fy. 'g'. d. MMM\x1FE, y. 'g'. d. MMM\x1Fd.M.y. G\x1F" &
  "G y. 'g'. d. MMM\x1FE, y. 'g'. d. MMM, G\x1FG y. 'g'. MMM\x1Fy. 'g'. QQQ\x1Fy. 'g'. QQQQ\x1FG y. 'g'.\x1F" &
  "y. 'g'.\x1Fअक्तू॰\x1Fफर॰\x1Fरवि दिन\x1Fसोम दिन\x1Fमंगल दिन\x1F" &
  "बुध दिन\x1Fबृहस्पति दिन\x1Fशुक्र दिन\x1F" &
  "शनि दिन\x1Fपहिल तिमाही\x1Fदोसर तिमाही\x1F" &
  "तेसर तिमाही\x1Fचारिम तिमाही\x1Fभोर\x1Fसांझ\x1F" &
  "Oladalʉ́\x1FArát\x1FƆɛnɨ́ɔɨŋɔk\x1FOlodoyíóríê inkókúâ\x1FOloilépūnyīē inkókúâ\x1F" &
  "Kújúɔrɔk\x1FMórusásin\x1FƆlɔ́ɨ́bɔ́rárɛ\x1FKúshîn\x1FOlgísan\x1FPʉshʉ́ka\x1FNtʉ́ŋʉ́s\x1F" &
  "Dal\x1FArá\x1FƆɛn\x1FDoy\x1FLép\x1FRok\x1FSás\x1FBɔ́r\x1FKús\x1FGís\x1FShʉ́\x1FNtʉ́\x1FJumapílí\x1FJumane\x1F" &
  "Jumatánɔ\x1FAlaámisi\x1FJumáa\x1FJumamósi\x1FErobo 1\x1FErobo 2\x1FErobo 3\x1FErobo 4\x1FƐnkakɛnyá\x1F" &
  "Ɛndámâ\x1FEY\x1FJanuarĩ\x1FFeburuarĩ\x1FĨpurũ\x1FMĩĩ\x1FNjuni\x1FNjuraĩ\x1FAgasti\x1FOktũba\x1FDicemba\x1F" &
  "JAN\x1FFEB\x1FMAC\x1FĨPU\x1FMĨĨ\x1FNJR\x1FAGA\x1FSPT\x1FNOV\x1FDEC\x1FMuramuko\x1FWairi\x1FWethatu\x1FKIU\x1FMRA\x1FWAI\x1FWET\x1F" &
  "WTN\x1FJUM\x1FĨmwe kĩrĩ inya\x1FIjĩrĩ kĩrĩ inya\x1FIthatũ kĩrĩ inya\x1FInya kĩrĩ inya\x1F" &
  "RŨ\x1FŨG\x1FNK\x1Fzanvie\x1Ffevriye\x1Fzin\x1Fzilye\x1Fout\x1Fseptam\x1Foktob\x1Fnovam\x1Fdesam\x1Favr\x1Fzil\x1Fdimans\x1Flindi\x1F" &
  "merkredi\x1Fzedi\x1Fvandredi\x1Fsamdi\x1Fdim\x1Flin\x1Fze\x1Fvan\x1F1e trimes\x1F2em trimes\x1F3em trimes\x1F4em trimes\x1F" &
  "av. Z-K\x1Fap. Z-K\x1FJanoary\x1FFebroary\x1FMartsa\x1FAprily\x1FMey\x1FJona\x1FJolay\x1FAogositra\x1FSeptambra\x1F" &
  "Oktobra\x1FNovambra\x1FDesambra\x1FJon\x1FJol\x1FAog\x1FAlahady\x1FAlatsinainy\x1FAlarobia\x1FAlakamisy\x1FZoma\x1F" &
  "Asabotsy\x1FAlah\x1FAlats\x1FAlar\x1FAlak\x1FZom\x1FAsab\x1FTelovolana voalohany\x1FTelovolana faharoa\x1FTelovolana fahatelo\x1F" &
  "Telovolana fahefatra\x1FMweri wo kwanza\x1FMweri wo unayeli\x1FMweri wo uneraru\x1FMweri wo unecheshe\x1F" &
  "Mweri wo unethanu\x1FMweri wo thanu na mocha\x1FMweri wo saba\x1FMweri wo nane\x1FMweri wo tisa\x1F" &
  "Mweri wo kumi\x1FMweri wo kumi na moja\x1FMweri wo kumi na yel’li\x1FUna\x1FRar\x1FChe\x1FMoc\x1FMoj\x1F" &
  "Yel\x1FSabato\x1FArahamisi\x1Fwichishu\x1Fmchochil’l\x1FHY\x1FYY\x1Fiməg mbegtug\x1Fimeg àbùbì\x1Fimeg mbəŋchubi\x1F" &
  "iməg ngwə̀t\x1Fiməg fog\x1Fiməg ichiibɔd\x1Fiməg àdùmbə̀ŋ\x1Fiməg ichika\x1Fiməg kud\x1F" &
  "iməg tèsiʼe\x1Fiməg zò\x1Fiməg krizmed\x1Fmbegtug\x1FAneg 1\x1FAneg 2\x1FAneg 3\x1FAneg 4\x1FAneg 5\x1F" &
  "Aneg 6\x1FAneg 7\x1FHānuere\x1FPēpuere\x1FMāehe\x1FĀperira\x1FHune\x1FHūrae\x1FĀkuhata\x1FHepetema\x1FOketopa\x1F" &
  "Noema\x1FTīhema\x1FHān\x1FPēp\x1FMāe\x1FĀpe\x1FHūr\x1FĀku\x1FHep\x1FOke\x1FNoe\x1FTīh\x1FRātapu\x1FMane\x1FTūrei\x1F" &
  "Wenerei\x1FTāite\x1FParaire\x1FRāhoroi\x1FRāt\x1FMan\x1FTūr\x1FTāi\x1FRāh\x1FHauwhā tuatahi\x1FHauwhā tuarua\x1F" &
  "Hauwhā tuatoru\x1FHauwhā tuawhā\x1FHW1\x1FHW2\x1FHW3\x1FHW4\x1Fјануари\x1Fјан.\x1Fјун.\x1Fјул.\x1F" &
  "сеп.\x1Fное.\x1Fнедела\x1Fсреда\x1Fчетврток\x1Fпеток\x1Fсабота\x1F" &
  "нед.\x1Fпон.\x1Fвто.\x1Fсре.\x1Fчет.\x1Fпет.\x1Fсаб.\x1Fпрво тримесечје\x1F" &
  "второ тримесечје\x1Fтрето тримесечје\x1Fчетврто тримесечје\x1F" &
  "јан. – мар.\x1Fапр. – јун.\x1Fјул. – сеп.\x1Fокт. – дек.\x1Fпретпл.\x1F" &
  "попл.\x1Fпр. н. е.\x1Fd.M.y 'г'.\x1FE, d.M.y 'г'.\x1FMMM y 'г'.\x1FE, d MMM y 'г'.\x1F" &
  "d.M.y 'г'. G\x1FM.y 'г'.\x1FMMM y 'г'. G\x1Fജനുവരി\x1Fഫെബ്രുവരി\x1F" &
  "മാർച്ച്\x1Fഏപ്രിൽ\x1Fമേയ്\x1Fജൂൺ\x1Fജൂലൈ\x1Fഓഗസ്റ്റ്\x1F" &
  "സെപ്റ്റംബർ\x1Fഒക്‌ടോബർ\x1Fനവംബർ\x1Fഡിസംബർ\x1F" &
  "ജനു\x1Fഫെബ്രു\x1Fമാർ\x1Fഏപ്രി\x1Fഓഗ\x1Fസെപ്റ്റം\x1F" &
  "ഒക്ടോ\x1Fനവം\x1Fഡിസം\x1Fഞായറാഴ്‌ച\x1Fതിങ്കളാഴ്‌ച\x1F" &
  "ചൊവ്വാഴ്ച\x1Fബുധനാഴ്‌ച\x1Fവ്യാഴാഴ്‌ച\x1F" &
  "വെള്ളിയാഴ്‌ച\x1Fശനിയാഴ്‌ച\x1Fഞായർ\x1Fതിങ്കൾ\x1F" &
  "ചൊവ്വ\x1Fബുധൻ\x1Fവ്യാഴം\x1Fവെള്ളി\x1Fശനി\x1Fഒന്നാം പാദം\x1F" &
  "രണ്ടാം പാദം\x1Fമൂന്നാം പാദം\x1Fനാലാം പാദം\x1F" &
  "ബിസി\x1Fഎഡി\x1Fzzzz h:mm:ss a\x1Fz h:mm:ss a\x1Fd/M/y, E\x1FG y/M/d\x1Fнэгдүгээр сар\x1F" &
  "хоёрдугаар сар\x1Fгуравдугаар сар\x1Fдөрөвдүгээр сар\x1F" &
  "тавдугаар сар\x1Fзургаадугаар сар\x1Fдолоодугаар сар\x1F" &
  "наймдугаар сар\x1Fесдүгээр сар\x1Fаравдугаар сар\x1Fарван нэгдүгээр сар\x1F" &
  "арван хоёрдугаар сар\x1F1-р сар\x1F2-р сар\x1F3-р сар\x1F4-р сар\x1F" &
  "5-р сар\x1F6-р сар\x1F7-р сар\x1F8-р сар\x1F9-р сар\x1F10-р сар\x1F11-р сар\x1F" &
  "12-р сар\x1FНэгдүгээр сар\x1FХоёрдугаар сар\x1FГуравдугаар сар\x1F" &
  "Дөрөвдүгээр сар\x1FТавдугаар сар\x1FЗургаадугаар сар\x1F" &
  "Долоодугаар сар\x1FНаймдугаар сар\x1FЕсдүгээр сар\x1F" &
  "Аравдугаар сар\x1FАрван нэгдүгээр сар\x1FАрван хоёрдугаар сар\x1F" &
  "ням\x1Fдаваа\x1Fмягмар\x1Fлхагва\x1Fпүрэв\x1Fбямба\x1FНя\x1FДа\x1FМя\x1F" &
  "Лх\x1FПү\x1FБа\x1FБя\x1F1-р улирал\x1F2-р улирал\x1F3-р улирал\x1F4-р улирал\x1F" &
  "I улирал\x1FII улирал\x1FIII улирал\x1FIV улирал\x1Fү.ө.\x1Fү.х.\x1FМЭӨ\x1F" &
  "МЭ\x1Fy 'оны' MMMM'ын' d, EEEE 'гараг'\x1Fy 'оны' MMMM'ын' d\x1Fy 'оны' MMM'ын' d\x1F" &
  "y.MM.dd. E\x1Fy 'оны' MMM\x1Fy 'оны' MMMM\x1Fy 'оны' MMM'ын' d. E\x1FG y 'оны' MMM'ын' d\x1F" &
  "G y 'оны' MMM'ын' d. E\x1Fy MMMMM\x1FMMMMM/dd\x1FMMMMM/dd. E\x1FMMM'ын' d\x1FMMM'ын' d. E\x1F" &
  "MMMM'ын' d\x1FG y 'оны' MMM\x1Fy 'оны' QQQ\x1Fy 'оны' QQQQ\x1FLLLLL\x1Fdd. E\x1FHH 'ц'\x1F" &
  "h 'ц' a\x1Fজনুৱারী\x1Fফেব্রুৱারি\x1F‌ওগষ্ট\x1F" &
  "ওক্টোবর\x1Fজন\x1Fওগ\x1Fজানুৱারি\x1Fওগষ্ট\x1Fনবেম্বর\x1F" &
  "ফেব্রু\x1Fমার\x1Fজুলা\x1Fওক্টো\x1Fনোংমাইজিং\x1F" &
  "নিংথৌকাবা\x1Fলৈবাকপোকপা\x1Fয়ুমশকৈশা\x1F" &
  "শগোলশেন\x1Fইরাই\x1Fথাংজ\x1Fঅহানবা মসুং\x1Fঅনীশুবা মসুং\x1F" &
  "অহুমশুবা মসুং\x1Fমরীশুবা মসুং\x1Fনুমাং\x1F" &
  "খৃ: মমাং\x1Fখৃ: মতুং\x1FMMMM d, y, EEEE\x1FMMM d, y, E\x1Fजुलै\x1F" &
  "मंगळवार\x1Fमंगळ\x1Fप्रथम तिमाही\x1Fद्वितीय तिमाही\x1F" &
  "तृतीय तिमाही\x1Fचतुर्थ तिमाही\x1Fति१\x1F" &
  "ति२\x1Fति३\x1Fति४\x1Fई. स. पू.\x1Fइ. स.\x1FOgos\x1FDisember\x1FOgo\x1FIsnin\x1F" &
  "Khamis\x1FJumaat\x1FAhd\x1FIsn\x1FKha\x1FSuku pertama\x1FSuku Ke-2\x1FSuku Ke-3\x1FSuku Ke-4\x1FS1\x1FS2\x1FS3\x1FS4\x1F" &
  "PG\x1FPTG\x1FS.M.\x1FTM\x1FJannar\x1FFrar\x1FMarzu\x1FMejju\x1FĠunju\x1FLulju\x1FAwwissu\x1FSettembru\x1FOttubru\x1FNovembru\x1F" &
  "Diċembru\x1FFra\x1FMej\x1FĠun\x1FLul\x1FAww\x1FOtt\x1FDiċ\x1FIl-Ħadd\x1FIt-Tnejn\x1FIt-Tlieta\x1FL-Erbgħa\x1FIl-Ħamis\x1F" &
  "Il-Ġimgħa\x1FIs-Sibt\x1FĦad\x1FTne\x1FTli\x1FErb\x1FĦam\x1FĠim\x1F1el kwart\x1F2ni kwart\x1F3et kwart\x1F4ba’ kwart\x1F" &
  "QK\x1FWK\x1FEEEE, d 'ta'’ MMMM y\x1Fd 'ta'’ MMMM y\x1Fd 'ta'’ MMM, y\x1FE, d 'ta'’ MMM, y\x1F" &
  "E, d 'ta'’ MMM, y G\x1FE, d 'ta'’ MMM\x1Fd 'ta'’ MMMM\x1FQQQ - y\x1FQQQQ - y\x1FFĩi Loo\x1FCokcwaklaŋne\x1F" &
  "Cokcwaklii\x1FFĩi Marfoo\x1FMadǝǝuutǝbijaŋ\x1FMamǝŋgwãafahbii\x1FMamǝŋgwãalii\x1FMadǝmbii\x1F" &
  "Fĩi Dǝɓlii\x1FFĩi Mundaŋ\x1FFĩi Gwahlle\x1FFĩi Yuru\x1FFLO\x1FCLA\x1FCKI\x1FFMF\x1FMAD\x1FMBI\x1FMLI\x1FMAM\x1F" &
  "FDE\x1FFMU\x1FFGW\x1FFYU\x1FCom’yakke\x1FComlaaɗii\x1FComzyiiɗii\x1FComkolle\x1FComkaldǝɓlii\x1FComgaisuu\x1F" &
  "Comzyeɓsuu\x1FCya\x1FCla\x1FCzi\x1FCko\x1FCka\x1FCga\x1FCze\x1FTai fĩi sai ma tǝn kee zah\x1FTai fĩi sai zah lǝn gwa ma kee\x1F" &
  "Tai fĩi sai zah lǝn sai ma kee\x1FTai fĩi sai ma coo kee zah ‘na\x1Fcomme\x1Flilli\x1FPK\x1F" &
  "ဇန်နဝါရီ\x1Fဖေဖော်ဝါရီ\x1Fမတ်\x1Fဧပြီ\x1Fမေ\x1F" &
  "ဇွန်\x1Fဇူလိုင်\x1Fဩဂုတ်\x1Fစက်တင်ဘာ\x1Fအောက်တိုဘာ\x1F" &
  "နိုဝင်ဘာ\x1Fဒီဇင်ဘာ\x1Fဇန်\x1Fဖေ\x1Fဧ\x1Fဇူ\x1Fဩ\x1Fစက်\x1F" &
  "အောက်\x1Fနို\x1Fဒီ\x1Fတနင်္ဂနွေ\x1Fတနင်္လာ\x1F" &
  "အင်္ဂါ\x1Fဗုဒ္ဓဟူး\x1Fကြာသပတေး\x1Fသောကြာ\x1F" &
  "စနေ\x1Fပထမ သုံးလပတ်\x1Fဒုတိယ သုံးလပတ်\x1F" &
  "တတိယ သုံးလပတ်\x1Fစတုတ္ထ သုံးလပတ်\x1F" &
  "နံနက်\x1Fညနေ\x1Fဘီစီ\x1Fအေဒီ\x1Fy MMMM d၊ EEEE\x1Fd/M/y E\x1Fy MMM d၊ E\x1F" &
  "G y MMM d၊ E\x1Fy/MM\x1Fd/M E\x1FMMM d၊ E\x1Fd ရက် E\x1Fپ.م\x1FǃKhanni\x1FǃKhanǀgôab\x1FǀKhuuǁkhâb\x1F" &
  "ǃHôaǂkhaib\x1FǃKhaitsâb\x1FGamaǀaeb\x1FǂKhoesaob\x1FAoǁkhuumûǁkhâb\x1FTaraǀkhuumûǁkhâb\x1F" &
  "ǂNûǁnâiseb\x1FǀHooǂgaeb\x1FHôasoreǁkhâb\x1FSontaxtsees\x1FMantaxtsees\x1FDenstaxtsees\x1FWunstaxtsees\x1F" &
  "Dondertaxtsees\x1FFraitaxtsees\x1FSatertaxtsees\x1FWu\x1FFr\x1F1ro kwartals\x1F2ǁî kwartals\x1F3ǁî kwartals\x1F" &
  "4ǁî kwartals\x1FKW1\x1FKW2\x1FKW3\x1FKW4\x1Fǁgoagas\x1Fǃuias\x1FZibandlela\x1FNhlolanja\x1FMbimbitho\x1FMabasa\x1F" &
  "Nkwenkwezi\x1FNhlangula\x1FNtulikazi\x1FNcwabakazi\x1FMpandula\x1FMfumfu\x1FLwezi\x1FMpalakazi\x1FZib\x1FNhlo\x1F" &
  "Mbi\x1FMab\x1FNkw\x1FNhla\x1FNtu\x1FNcw\x1FMpan\x1FLwe\x1FMpal\x1FSonto\x1FMvulo\x1FSibili\x1FSithathu\x1FSine\x1FSihlanu\x1FMgqibelo\x1F" &
  "Mvu\x1FSin\x1FSih\x1FMgq\x1FKota 1\x1FKota 2\x1FKota 3\x1FKota 4\x1FJanuaar\x1FFebruaar\x1FOktover\x1FSünndag\x1FDingsdag\x1F" &
  "Middeweken\x1FDunnersdag\x1FFreedag\x1FSünnavend\x1F'Klock' H.mm:ss\x1F'Kl'. H.mm\x1F'Klock' h.mm:ss a\x1F" &
  "'Kl'. h.mm a\x1Fफेब्रुअरी\x1Fअप्रिल\x1Fअगस्ट\x1Fसेप्टेम्बर\x1F" &
  "अक्टोबर\x1Fनोभेम्बर\x1Fआइतबार\x1Fमङ्गलबार\x1F" &
  "बिहिबार\x1Fआइत\x1Fमङ्गल\x1Fबिहि\x1Fपहिलो त्रैमासिक\x1F" &
  "दोस्रो त्रैमासिक\x1Fतेस्रो त्रैमासिक\x1F" &
  "चौथो त्रैमासिक\x1Fपूर्वाह्न\x1Fअपराह्न\x1F" &
  "ईसा पूर्व\x1Fसन्\x1Fjanuari\x1Ffebruari\x1Fmaart\x1Fmei\x1Faugustus\x1Fmrt\x1Fzondag\x1F" &
  "maandag\x1Fdinsdag\x1Fwoensdag\x1Fdonderdag\x1Fvrijdag\x1Fzaterdag\x1Fzo\x1Fdo\x1Fvr\x1Fza\x1F1e kwartaal\x1F2e kwartaal\x1F" &
  "3e kwartaal\x1F4e kwartaal\x1Fv.Chr.\x1Fn.Chr.\x1Fngwɛn matáhra\x1Fngwɛn ńmba\x1Fngwɛn ńlal\x1Fngwɛn ńna\x1F" &
  "ngwɛn ńtan\x1Fngwɛn ńtuó\x1Fngwɛn hɛmbuɛrí\x1Fngwɛn lɔmbi\x1Fngwɛn rɛbvuâ\x1Fngwɛn wum\x1F" &
  "ngwɛn wum navǔr\x1Fkrísimin\x1Fng1\x1Fng2\x1Fng3\x1Fng4\x1Fng5\x1Fng6\x1Fng7\x1Fng8\x1Fng9\x1Fng10\x1Fng11\x1Fkris\x1Fmɔ́ndɔ\x1F" &
  "sɔ́ndɔ mafú mába\x1Fsɔ́ndɔ mafú málal\x1Fsɔ́ndɔ mafú mána\x1Fmabágá má sukul\x1F" &
  "sásadi\x1Fmbs\x1Fsas\x1FTindɛ nvúr\x1FTindɛ ńmba\x1FTindɛ ńlal\x1FTindɛ ńna\x1Fmaná\x1Fkugú\x1FBL\x1F" &
  "PB\x1Fmåndag\x1Ftysdag\x1Flaurdag\x1Fsø.\x1Fmå.\x1Fty.\x1Fon.\x1Fto.\x1Ffr.\x1Fla.\x1Ff.m.\x1Fe.m.\x1Fsaŋ tsetsɛ̀ɛ lùm\x1F" &
  "saŋ kàg ngwóŋ\x1Fsaŋ lepyè shúm\x1Fsaŋ cÿó\x1Fsaŋ tsɛ̀ɛ cÿó\x1Fsaŋ njÿoláʼ\x1F" &
  "saŋ tyɛ̀b tyɛ̀b mbʉ̀ŋ\x1Fsaŋ mbʉ̀ŋ\x1Fsaŋ ngwɔ̀ʼ mbÿɛ\x1Fsaŋ tàŋa tsetsáʼ\x1F" &
  "saŋ mejwoŋó\x1Fsaŋ lùm\x1Flyɛʼɛ́ sẅíŋtè\x1Fmvfò lyɛ̌ʼ\x1Fmbɔ́ɔntè mvfò lyɛ̌ʼ\x1F" &
  "tsètsɛ̀ɛ lyɛ̌ʼ\x1Fmbɔ́ɔntè tsetsɛ̀ɛ lyɛ̌ʼ\x1Fmvfò màga lyɛ̌ʼ\x1Fmàga lyɛ̌ʼ\x1F" &
  "mbaʼámbaʼ\x1Fncwònzém\x1Fm.z.Y.\x1Fm.g.n.Y.\x1FEEEE , 'lyɛ'̌ʼ d 'na' MMMM, y\x1F'lyɛ'̌ʼ d 'na' MMMM, y\x1F" &
  "E , 'lyɛ'̌ʼ d 'na' M, y\x1FE , 'lyɛ'̌ʼ d 'na' MMM, y\x1Ftir.\x1Ftor.\x1Fߓߌ߲ߠߊߥߎߟߋ߲\x1F" &
  "ߞߏ߲ߞߏߜߍ\x1Fߕߙߊߓߊ\x1Fߞߏ߲ߞߏߘߌ߬ߓߌ\x1Fߘߓߊ߬ߕߊ\x1Fߥߊ߬ߛߌ߬ߥߙߊ\x1Fߞߊ߬ߙߌߝߐ߭\x1F" &
  "ߘߓߊ߬ߓߌߟߊ\x1Fߕߎߟߊߝߌ߲\x1Fߞߏ߲ߓߌߕߌ߮\x1Fߣߍߣߍߓߊ\x1Fߞߏߟߌ߲ߞߏߟߌ߲\x1F" &
  "ߓߌ߲ߠ\x1Fߞߏ߲ߞ\x1Fߕߙߊ\x1Fߞߏ߲ߘ\x1Fߘߓߊ߬ߕ\x1Fߥߊ߬ߛ\x1Fߞߊ߬ߙ\x1Fߘߓߊ߬ߓ\x1Fߞߏ߲ߓ\x1F" &
  "ߣߍߣ\x1Fߞߏߟ\x1Fߞߊ߯ߙߌߟߏ߲\x1Fߞߐ߬ߓߊ߬ߟߏ߲\x1Fߞߐ߬ߟߏ߲\x1Fߞߎߣߎ߲ߟߏ߲\x1Fߓߌߟߏ߲\x1F" &
  "ߛߌ߬ߣߌ߲߬ߟߏ߲\x1Fߞߍ߲ߘߍߟߏ߲\x1Fߞߊ߯ߙ\x1Fߞߐ߬ߓ\x1Fߞߎߣ\x1Fߓߌߟ\x1Fߛߌ߬ߣ\x1Fߞߍ߲ߘ\x1F" &
  "ߞߊߙߏߛߓߊ߫ ߁߭\x1Fߞߊߙߏߛߓߊ߫ ߂߲\x1Fߞߊߙߏߛߓߊ߫ ߃߲\x1Fߞߊߙߏߛߓߊ߫ ߄߲\x1F" &
  "ߞߛ߁\x1Fߞߛ߂\x1Fߞߛ߃\x1Fߞߛ߄\x1Fߛ\x1Fߥ\x1Fߌߛ. ߡ. ߢߍ߫\x1Fߌߛ. ߡ. ߞߐ߫\x1Fy / dd / MM\x1Fy / dd MMM\x1F" &
  "Janeware\x1FFebereware\x1FMatšhe\x1FAporele\x1FJulae\x1FAgosetose\x1FSetemere\x1FOktobore\x1FNofemere\x1FDisemere\x1F" &
  "Mat\x1FApo\x1FNof\x1FLamorena\x1FMošupologo\x1FLabobedi\x1FLaboraro\x1FLabone\x1FLabohlano\x1FMokibelo\x1FLam\x1F" &
  "Mos\x1FBed\x1FNe\x1FHla\x1FMok\x1F1st Kotara\x1F2nd Kotara\x1F3rd Kotara\x1F4th Kotara\x1FKotara 1\x1FKotara 2\x1F" &
  "Kotara 3\x1FKotara 4\x1FTiop thar pɛt\x1FPɛt\x1FDuɔ̱ɔ̱ŋ\x1FGuak\x1FDuät\x1FKornyoot\x1FPay yie̱tni\x1F" &
  "Tho̱o̱r\x1FTɛɛr\x1FLaath\x1FKur\x1FTio̱p in di̱i̱t\x1FTiop\x1FDuɔ̱ɔ̱\x1FDuä\x1FKor\x1FThoo\x1FTɛɛ\x1F" &
  "Laa\x1FTid\x1FCäŋ kuɔth\x1FJiec la̱t\x1FRɛw lätni\x1FDiɔ̱k lätni\x1FŊuaan lätni\x1FDhieec lätni\x1F" &
  "Bäkɛl lätni\x1FCäŋ\x1FJiec\x1FRɛw\x1FDiɔ̱k\x1FŊuaan\x1FDhieec\x1FBäkɛl\x1FPäth diɔk tin nhiam\x1F" &
  "Päth diɔk tin guurɛ\x1FPäth diɔk tin wä kɔɔriɛn\x1FPäth diɔk tin jiɔakdiɛn\x1F" &
  "RW\x1FTŊ\x1FƐY\x1Fzzzz h:mm:ss a\x1Fz h:mm:ss a\x1FE، d-M\x1F#,##0 %\x1Fde genièr\x1Fde febrièr\x1F" &
  "de mai\x1Fde junh\x1Fde julhet\x1Fd’octòbre\x1Fde decembre\x1Fdimenge\x1Fdiluns\x1Fdimars\x1Fdimècres\x1F" &
  "dijòus\x1FHH'h'mm ss 'seg'.\x1FHH'h'mm\x1Fh'h'mm:ss a\x1Fh'h'mm a\x1FAmajjii\x1FGuraandhala\x1FBitootessa\x1F" &
  "Eebila\x1FCaamsaa\x1FWaxabajjii\x1FAdoolessa\x1FHagayya\x1FFulbaana\x1FOnkoloolessa\x1FSadaasa\x1FMudde\x1FAma\x1F" &
  "Gur\x1FElb\x1FCam\x1FWax\x1FAdo\x1FHag\x1FFul\x1FOnk\x1FMud\x1FDilbata\x1FWiixata\x1FKibxata\x1FRoobii\x1FKamisa\x1FJimaata\x1F" &
  "Sanbata\x1FDil\x1FWix\x1FKib\x1FRob\x1FSan\x1FKurmaana 1ffaa\x1FKurmaana 2ffaa\x1FKurmaana 3ffaa\x1FKurmaana 4ffaa\x1F" &
  "WD\x1FWB\x1FDhKD\x1FBA\x1FKD\x1Fଜାନୁଆରୀ\x1Fଫେବୃଆରୀ\x1Fମାର୍ଚ୍ଚ\x1F" &
  "ଅପ୍ରେଲ\x1Fମଇ\x1Fଜୁନ\x1Fଜୁଲାଇ\x1Fଅଗଷ୍ଟ\x1Fସେପ୍ଟେମ୍ବର\x1F" &
  "ଅକ୍ଟୋବର\x1Fନଭେମ୍ବର\x1Fଡିସେମ୍ବର\x1Fରବିବାର\x1F" &
  "ସୋମବାର\x1Fମଙ୍ଗଳବାର\x1Fବୁଧବାର\x1Fଗୁରୁବାର\x1F" &
  "ଶୁକ୍ରବାର\x1Fଶନିବାର\x1Fରବି\x1Fସୋମ\x1Fମଙ୍ଗଳ\x1Fବୁଧ\x1F" &
  "ଗୁରୁ\x1Fଶୁକ୍ର\x1Fଶନି\x1F1ମ ତ୍ରୟମାସ\x1F2ୟ ତ୍ରୟମାସ\x1F" &
  "3ୟ ତ୍ରୟମାସ\x1F4ର୍ଥ ତ୍ରୟମାସ\x1Fянвары\x1Fфевралы\x1F" &
  "мартъийы\x1Fапрелы\x1Fмайы\x1Fиюны\x1Fиюлы\x1Fавгусты\x1Fсентябры\x1F" &
  "октябры\x1Fноябры\x1Fдекабры\x1FМартъи\x1FЯнв.\x1FФевр.\x1FМарт.\x1F" &
  "Апр.\x1FАвг.\x1FСент.\x1FОкт.\x1FНояб.\x1FДек.\x1Fхуыцаубон\x1Fкъуырисӕр\x1F" &
  "дыццӕг\x1Fӕртыццӕг\x1Fцыппӕрӕм\x1Fмайрӕмбон\x1Fсабат\x1Fхцб\x1F" &
  "крс\x1Fдцг\x1Fӕрт\x1Fцпр\x1Fмрб\x1Fсбт\x1F1-аг квартал\x1F2-аг квартал\x1F" &
  "3-аг квартал\x1F4-ӕм квартал\x1F1-аг кв.\x1F2-аг кв.\x1F3-аг кв.\x1F" &
  "4-ӕм кв.\x1Fн.д.а.\x1Fн.д.\x1FEEEE, d MMMM, y 'аз'\x1Fd MMMM, y 'аз'\x1Fdd MMM y 'аз'\x1F" &
  "ccc, d MMM\x1Fy-'ӕм' 'азы' QQQ\x1Fy-'ӕм' 'азы' QQQQ\x1Fਜਨਵਰੀ\x1Fਫ਼ਰਵਰੀ\x1F" &
  "ਮਾਰਚ\x1Fਅਪ੍ਰੈਲ\x1Fਮਈ\x1Fਜੂਨ\x1Fਜੁਲਾਈ\x1Fਅਗਸਤ\x1Fਸਤੰਬਰ\x1F" &
  "ਅਕਤੂਬਰ\x1Fਨਵੰਬਰ\x1Fਦਸੰਬਰ\x1Fਜਨ\x1Fਫ਼ਰ\x1Fਅਪ੍ਰੈ\x1F" &
  "ਜੁਲਾ\x1Fਅਗ\x1Fਸਤੰ\x1Fਅਕਤੂ\x1Fਨਵੰ\x1Fਦਸੰ\x1Fਐਤਵਾਰ\x1Fਸੋਮਵਾਰ\x1F" &
  "ਮੰਗਲਵਾਰ\x1Fਬੁੱਧਵਾਰ\x1Fਵੀਰਵਾਰ\x1Fਸ਼ੁੱਕਰਵਾਰ\x1F" &
  "ਸ਼ਨੀਵਾਰ\x1Fਐਤ\x1Fਸੋਮ\x1Fਮੰਗਲ\x1Fਬੁੱਧ\x1Fਵੀਰ\x1Fਸ਼ੁੱਕਰ\x1F" &
  "ਸ਼ਨੀ\x1Fਪਹਿਲੀ ਤਿਮਾਹੀ\x1Fਦੂਜੀ ਤਿਮਾਹੀ\x1Fਤੀਜੀ ਤਿਮਾਹੀ\x1F" &
  "ਚੌਥੀ ਤਿਮਾਹੀ\x1Fਤਿਮਾਹੀ1\x1Fਤਿਮਾਹੀ2\x1Fਤਿਮਾਹੀ3\x1F" &
  "ਤਿਮਾਹੀ4\x1Fਈ. ਪੂ.\x1Fਸੰਨ\x1FE d MMM, G y\x1FE, dd-MM.\x1Fمئ\x1Fجولائی\x1F" &
  "اتوار\x1Fپیر\x1Fمنگل\x1Fبُدھ\x1Fجمعرات\x1Fجمعہ\x1Fہفتہ\x1Fچوتھاي پہلاں\x1F" &
  "چوتھاي دوجا\x1Fچوتھاي تيجا\x1Fچوتھاي چوتھا\x1Fايساپورو\x1F" &
  "سں\x1FJénúári\x1FFẹ́búári\x1FMach\x1FÉprel\x1FỌgọst\x1FSẹptẹ́mba\x1FỌktóba\x1FNọvẹ́mba\x1F" &
  "Disẹ́mba\x1FJén\x1FFẹ́b\x1FÉpr\x1FSẹp\x1FNọv\x1FỌ́gọ\x1FSọ́ndè\x1FMọ́ndè\x1FTiúzdè\x1F" &
  "Wẹ́nẹ́zdè\x1FTọ́zdè\x1FFraídè\x1FSátọdè\x1FSọ́n\x1FMọ́n\x1FTiú\x1FWẹ́n\x1FTọ́z\x1F" &
  "Fraí\x1FSát\x1FFẹ́st Kwọ́ta\x1FSẹ́kọ́n Kwọ́ta\x1FTọ́d Kwọ́ta\x1FFọ́t Kwọ́ta\x1F" &
  "FM\x1FFI\x1FKIY\x1Fd /M\x1Fstycznia\x1Flutego\x1Fmarca\x1Fkwietnia\x1Fczerwca\x1Flipca\x1Fsierpnia\x1Fwrześnia\x1Fpaździernika\x1F" &
  "grudnia\x1Fsty\x1Flut\x1Fkwi\x1Fcze\x1Fsie\x1Fwrz\x1Fpaź\x1Fgru\x1Fstyczeń\x1Fluty\x1Fmarzec\x1Fkwiecień\x1Fczerwiec\x1F" &
  "lipiec\x1Fsierpień\x1Fwrzesień\x1Fpaździernik\x1Fgrudzień\x1Fniedziela\x1Fponiedziałek\x1Fwtorek\x1F" &
  "środa\x1Fczwartek\x1Fpiątek\x1Fniedz.\x1Fpon.\x1Fwt.\x1Fśr.\x1Fczw.\x1Fpt.\x1Fsob.\x1FI kwartał\x1FII kwartał\x1F" &
  "III kwartał\x1FIV kwartał\x1FI kw.\x1FII kw.\x1FIII kw.\x1FIV kw.\x1Fp.n.e.\x1Fd.MM.y\x1FE, d.MM.y\x1Fd.MM\x1F" &
  "E, d.MM\x1Fgené\x1Ffërvé\x1Fmagg\x1Fgiugn\x1Flugn\x1Fstèmber\x1Futuber\x1Fnovèmber\x1Fdzèmber\x1Fdumìnica\x1F" &
  "lun-es\x1Fmàrtes\x1Fmerco\x1Fgiòbia\x1Fvënner\x1Fsaba\x1Frags\x1Fwassarins\x1Fpūlis\x1Fsakkis\x1Fzallaws\x1Fsīmenis\x1F" &
  "līpa\x1Fdaggis\x1Fsillins\x1Fspallins\x1Flapkrūtis\x1Fsallaws\x1Fnadīli\x1Fpanadīli\x1Fwisasīdis\x1Fpussisawaiti\x1F" &
  "ketwirtiks\x1Fpēntniks\x1Fsabattika\x1Fdd.MM 'st'. y\x1Fجنوري\x1Fفبروري\x1Fمۍ\x1Fاګست\x1F" &
  "سېپتمبر\x1Fفېبروري\x1Fسه شنبه\x1Fپنج شنبه\x1Fاونۍ\x1Fلومړۍ ربعه\x1F" &
  "۲مه ربعه\x1F۳مه ربعه\x1F۴مه ربعه\x1Fغ.م\x1Fغ.و.\x1Fله میلاد وړاندې\x1F" &
  "EEEE d, MMMM, y\x1Fy/MM/dd, E\x1Fy/M/d G\x1FMM/dd, E\x1Fjaneiro\x1Ffevereiro\x1Fmarço\x1Fjunho\x1Fjulho\x1F" &
  "dezembro\x1Ffev.\x1Fdez.\x1Fsegunda-feira\x1Fterça-feira\x1Fquarta-feira\x1Fquinta-feira\x1Fsexta-feira\x1F" &
  "seg.\x1Fter.\x1Fqua.\x1Fqui.\x1Fsex.\x1Fsegunda\x1Fterça\x1Fquarta\x1Fquinta\x1Fsexta\x1FE, d/MM/y\x1FE, d/MM\x1FMiércoles\x1F" &
  "Jueves\x1FViernes\x1FSábado\x1FMié\x1FJue\x1FVie\x1Fa.d.\x1FNabʼe ikʼ\x1FUkabʼ ikʼ\x1FUrox ikʼ\x1FUkaj ikʼ\x1F" &
  "Uroʼ ikʼ\x1FUwaq ikʼ\x1FUwuq ikʼ\x1FUwajxaq ikʼ\x1FUbʼelej ikʼ\x1FUlajuj ikʼ\x1FRujulaʼj ikʼ\x1F" &
  "Rukabʼlaʼj ikʼ\x1FNabʼe qʼij\x1FUkabʼ qʼij\x1FUrox qʼij\x1FUkaj qʼij\x1FRoʼ qʼij\x1FUwaq qʼij\x1F" &
  "Wuq qʼij\x1FRCH1\x1FRCH2\x1FRCH3\x1FRCH4\x1FMYQJ\x1Fda schaner\x1Fda favrer\x1Fda mars\x1Fd’avrigl\x1Fda matg\x1F" &
  "da zercladur\x1Fda fanadur\x1Fd’avust\x1Fda settember\x1Fd’october\x1Fda november\x1Fda december\x1F" &
  "schan.\x1Ffavr.\x1Fmatg\x1Fzercl.\x1Ffan.\x1Favust\x1Fsett.\x1Fschaner\x1Ffavrer\x1Favrigl\x1Fzercladur\x1Ffanadur\x1F" &
  "settember\x1Foctober\x1Fdumengia\x1Fglindesdi\x1Fmesemna\x1Fgievgia\x1Fvenderdi\x1Fsonda\x1Fdu\x1Fgli\x1Fgie\x1F1. quartal\x1F" &
  "2. quartal\x1F3. quartal\x1F4. quartal\x1Fa.Cr.\x1Fs.C.\x1FEEEE, 'ils' d MMMM y\x1FLL-y\x1FNzero\x1FRuhuhuma\x1F" &
  "Ntwarante\x1FNdamukiza\x1FRusama\x1FRuheshi\x1FMukakaro\x1FNyandagaro\x1FNyakanga\x1FGitugutu\x1FMunyonyo\x1F" &
  "Kigarama\x1FMut.\x1FGas.\x1FWer.\x1FMat.\x1FGic.\x1FKam.\x1FNya.\x1FKan.\x1FNze.\x1FUkw.\x1FUgu.\x1FUku.\x1FKu w’indwi\x1F" &
  "Ku wa mbere\x1FKu wa kabiri\x1FKu wa gatatu\x1FKu wa kane\x1FKu wa gatanu\x1FKu wa gatandatu\x1Fcu.\x1F" &
  "mbe.\x1Fkab.\x1Fgtu.\x1Fkan.\x1Fgnu.\x1Fgnd.\x1FIgice ca mbere c’umwaka\x1FIgice ca kabiri c’umwaka\x1F" &
  "Igice ca gatatu c’umwaka\x1FIgice ca kane c’umwaka\x1FI1\x1FI2\x1FI3\x1FI4\x1FZ.MU.\x1FZ.MW.\x1FMb.Y.\x1F" &
  "Ny.Y\x1Fianuarie\x1Ffebruarie\x1Fmartie\x1Faprilie\x1Fiunie\x1Fiulie\x1Fseptembrie\x1Foctombrie\x1Fnoiembrie\x1F" &
  "decembrie\x1Fian.\x1Fiun.\x1Fiul.\x1Fduminică\x1Fluni\x1Fmarți\x1Fmiercuri\x1Fvineri\x1Fsâmbătă\x1Fdum.\x1Fmie.\x1F" &
  "vin.\x1Fsâm.\x1Ftrimestrul I\x1Ftrimestrul al II-lea\x1Ftrimestrul al III-lea\x1Ftrimestrul al IV-lea\x1F" &
  "trim. I\x1Ftrim. II\x1Ftrim. III\x1Ftrim. IV\x1Fî.Hr.\x1Fd.Hr.\x1FDum\x1FMie\x1FJoi\x1FVin\x1FSâm\x1Ftrimestrul 1\x1F" &
  "trimestrul 2\x1Ftrimestrul 3\x1Ftrimestrul 4\x1Ftrim. 1\x1Ftrim. 2\x1Ftrim. 3\x1Ftrim. 4\x1FMweri wa kwanza\x1F" &
  "Mweri wa kaili\x1FMweri wa katatu\x1FMweri wa kaana\x1FMweri wa tanu\x1FMweri wa sita\x1FMweri wa saba\x1F" &
  "Mweri wa nane\x1FMweri wa tisa\x1FMweri wa ikumi\x1FMweri wa ikumi na moja\x1FMweri wa ikumi na mbili\x1F" &
  "M5\x1FM6\x1FM7\x1FM8\x1FM9\x1FIjumapili\x1FIjumatatu\x1FIjumanne\x1FIjumatano\x1FIjumamosi\x1FIjp\x1FIjt\x1FIjn\x1FIjtn\x1F" &
  "Robo ya kwanza\x1FRobo ya kaili\x1FRobo ya katatu\x1FRobo ya kaana\x1Fkang’ama\x1Fkingoto\x1Fянваря\x1F" &
  "февраля\x1Fмарта\x1Fапреля\x1Fиюня\x1Fиюля\x1Fавгуста\x1Fсентября\x1F" &
  "октября\x1Fноября\x1Fдекабря\x1Fфевр.\x1Fвоскресенье\x1Fпонедельник\x1F" &
  "четверг\x1Fпятница\x1Fсуббота\x1Fвс\x1F1-й квартал\x1F2-й квартал\x1F" &
  "3-й квартал\x1F4-й квартал\x1F1-й кв.\x1F2-й кв.\x1F3-й кв.\x1F4-й кв.\x1F" &
  "до н. э.\x1Fн. э.\x1Fccc, dd.MM.y\x1FLLL y 'г'.\x1FLLLL y 'г'.\x1Fccc, d\x1Fccc, d.MM.y\x1F" &
  "Mutarama\x1FGashyantare\x1FWerurwe\x1FMata\x1FGicurasi\x1FKamena\x1FKanama\x1FNzeri\x1FUkwakira\x1FUgushyingo\x1F" &
  "Ukuboza\x1FKu cyumweru\x1FKuwa mbere\x1FKuwa kabiri\x1FKuwa gatatu\x1FKuwa kane\x1FKuwa gatanu\x1FKuwa gatandatu\x1F" &
  "Cyu.\x1FMbe.\x1FKab.\x1FGtu.\x1FGnu.\x1FGnd.\x1Figihembwe cya mbere\x1Figihembwe cya kabiri\x1Figihembwe cya gatatu\x1F" &
  "igihembwe cya kane\x1Fजनवरीमासः\x1Fफरवरीमासः\x1Fमार्चमासः\x1F" &
  "अप्रैलमासः\x1Fमईमासः\x1Fजूनमासः\x1Fजुलाईमासः\x1F" &
  "अगस्तमासः\x1Fसितंबरमासः\x1Fअक्तूबरमासः\x1F" &
  "नवंबरमासः\x1Fदिसंबरमासः\x1Fजनवरी:\x1Fफरवरी:\x1F" &
  "मार्च:\x1Fअप्रैल:\x1Fजून:\x1Fजुलाई:\x1Fअगस्त:\x1F" &
  "सितंबर:\x1Fअक्तूबर:\x1Fनवंबर:\x1Fदिसंबर:\x1Fरविवासरः\x1F" &
  "सोमवासरः\x1Fमंगलवासरः\x1Fबुधवासरः\x1Fगुरुवासर:\x1F" &
  "शुक्रवासरः\x1Fशनिवासरः\x1Fप्रथम त्रैमासिक\x1F" &
  "द्वितीय त्रैमासिक\x1Fतृतीय त्रैमासिक\x1F" &
  "चतुर्थ त्रैमासिक\x1Fत्रैमासिक1\x1Fत्रैमासिक2\x1F" &
  "त्रैमासिक3\x1Fत्रैमासिक4\x1FТохсунньу\x1FОлунньу\x1F" &
  "Кулун тутар\x1FМуус устар\x1FЫам ыйын\x1FБэс ыйын\x1FОт ыйын\x1F" &
  "Атырдьых ыйын\x1FБалаҕан ыйын\x1FАлтынньы\x1FСэтинньи\x1F" &
  "ахсынньы\x1FТохс\x1FОлун\x1FКлн\x1FМсу\x1FЫам\x1FБэс\x1FОтй\x1FАтр\x1FБлҕ\x1F" &
  "Алт\x1FСэт\x1FАхс\x1Fтохсунньу\x1Fолунньу\x1Fкулун тутар\x1Fмуус устар\x1F" &
  "ыам ыйа\x1Fбэс ыйа\x1Fот ыйа\x1Fатырдьых ыйа\x1Fбалаҕан ыйа\x1F" &
  "алтынньы\x1Fсэтинньи\x1Fбаскыһыанньа\x1Fбэнидиэнньик\x1F" &
  "оптуорунньук\x1Fсэрэдэ\x1Fчэппиэр\x1FБээтиҥсэ\x1Fсубуота\x1F" &
  "бн\x1Fоп\x1Fсэ\x1Fчп\x1Fбэ\x1F1-кы кыбаартал\x1F2-с кыбаартал\x1F3-с кыбаартал\x1F" &
  "4-с кыбаартал\x1F1-кы кб\x1F2-с кб\x1F3-с кб\x1F4-с кб\x1FЭИ\x1FЭК\x1Fб. э. и.\x1F" &
  "б. э\x1Fy 'сыл' MMMM d 'күнэ', EEEE\x1Fy, MMMM d\x1Fy, MMM d\x1Fy 'с'. G\x1FLapa le obo\x1F" &
  "Lapa le waare\x1FLapa le okuni\x1FLapa le ong’wan\x1FLapa le imet\x1FLapa le ile\x1FLapa le sapa\x1F" &
  "Lapa le isiet\x1FLapa le saal\x1FLapa le tomon\x1FLapa le tomon obo\x1FLapa le tomon waare\x1FObo\x1F" &
  "Waa\x1FOku\x1FOng\x1FIme\x1FIle\x1FSap\x1FIsi\x1FSaa\x1FTom\x1FTob\x1FTow\x1FMderot ee are\x1FMderot ee kuni\x1FMderot ee ong’wan\x1F" &
  "Mderot ee inet\x1FMderot ee ile\x1FMderot ee sapa\x1FMderot ee kwe\x1FAre\x1FKun\x1FKwe\x1FTesiran\x1FTeipa\x1F" &
  "ᱡᱟᱱᱣᱟᱨᱤ\x1Fᱯᱷᱟᱨᱣᱟᱨᱤ\x1Fᱢᱟᱨᱪ\x1Fᱟᱯᱨᱮᱞ\x1Fᱢᱮ\x1F" &
  "ᱡᱩᱱ\x1Fᱡᱩᱞᱟᱭ\x1Fᱟᱜᱟᱥᱛ\x1Fᱥᱮᱯᱴᱮᱢᱵᱟᱨ\x1Fᱚᱠᱴᱚᱵᱟᱨ\x1F" &
  "ᱱᱟᱣᱟᱢᱵᱟᱨ\x1Fᱫᱤᱥᱟᱢᱵᱟᱨ\x1Fᱡᱟᱱ\x1Fᱯᱷᱟ\x1Fᱢᱟᱨ\x1Fᱟᱯᱨ\x1F" &
  "ᱡᱩᱞ\x1Fᱟᱜᱟ\x1Fᱥᱮᱯ\x1Fᱚᱠᱴ\x1Fᱱᱟᱣ\x1Fᱫᱤᱥ\x1Fᱥᱤᱸᱜᱮ\x1Fᱚᱛᱮ\x1F" &
  "ᱵᱟᱞᱮ\x1Fᱥᱟᱹᱜᱩᱱ\x1Fᱥᱟᱹᱨᱫᱤ\x1Fᱡᱟᱹᱨᱩᱢ\x1Fᱧᱩᱦᱩᱢ\x1F" &
  "ᱥᱤᱸ\x1Fᱚᱛ\x1Fᱵᱟ\x1Fᱥᱟᱹ\x1Fᱥᱟᱹᱨ\x1Fᱡᱟᱹ\x1Fᱧᱩ\x1F᱑ᱟᱜ ᱯᱮ ᱪᱟᱸᱫᱚᱠᱤᱭᱟᱹ\x1F" &
  "᱒ᱟᱜ ᱯᱮ ᱪᱟᱸᱫᱚᱠᱤᱭᱟᱹ\x1F᱓ᱭᱟᱜ ᱯᱮ ᱪᱟᱸᱫᱚᱠᱤᱭᱟᱹ\x1F" &
  "᱔ᱟᱜ ᱯᱮ ᱪᱟᱸᱫᱚᱠᱤᱭᱟᱹ\x1Fᱵᱤ ᱥᱤ\x1Fᱤᱥᱣᱤ\x1FMupalangulwa\x1F" &
  "Mwitope\x1FMushende\x1FMunyi\x1FMushende Magali\x1FMujimbi\x1FMushipepo\x1FMupuguto\x1FMunyense\x1FMokhu\x1F" &
  "Musongandembwe\x1FMuhaano\x1FMup\x1FMwi\x1FMsh\x1FMun\x1FMag\x1FMuj\x1FMsp\x1FMpg\x1FMye\x1FMus\x1FMuh\x1FMulungu\x1FAlahamisi\x1F" &
  "Lwamilawu\x1FPashamihe\x1Fghennàrgiu\x1Ffreàrgiu\x1Fmartzu\x1Fabrile\x1Fmaju\x1Flàmpadas\x1Ftrìulas\x1Faustu\x1F" &
  "cabudanni\x1Fsantugaine\x1Fsantandria\x1Fnadale\x1Fghe\x1Ffre\x1Flàm\x1Ftrì\x1Faus\x1Fcab\x1FstG\x1FstA\x1Fnad\x1Fdomìniga\x1F" &
  "martis\x1Fmèrcuris\x1Fchenàbura\x1Fsàbadu\x1Fmèr\x1Fgiò\x1Fche\x1Fsàb\x1F1u trimestre\x1F3u trimestre\x1F" &
  "p.C.\x1FEEEE d 'de' MMMM 'de' 'su' y\x1Fd 'de' MMMM 'de' 'su' y\x1Fd 'de' MMM y\x1FMMMM 'de' 'su' y\x1F" &
  "E d 'de' MMM y\x1Fd 'de' MMM 'de' 'su' y G\x1FE d 'de' MMM 'de' 'su' y G\x1FMM/Y\x1FQQQQ 'de' 'su' y\x1F" &
  "jinnaru\x1Ffrivaru\x1Faprili\x1Fgiugnu\x1Fgiugnettu\x1Fagustu\x1Fsittèmmiru\x1Futtùviru\x1Fnuvèmmiru\x1Fdicèmmiru\x1F" &
  "jin\x1Ffri\x1Fgnt\x1Fagu\x1Fsit\x1Futt\x1Fnuv\x1Flunnidìa\x1Fmartidìa\x1Fmercuridìa\x1Fjovidìa\x1Fvenniridìa\x1F" &
  "sàbbatu\x1F1ᵘ trimestri\x1F2ᵘ trimestri\x1F3ᵘ trimestri\x1F4ᵘ trimestri\x1FQQQQ 'dû' y\x1F" &
  "فيبروري\x1Fاپريل\x1Fمئي\x1Fجولاءِ\x1Fآگسٽ\x1Fسيپٽمبر\x1Fآڪٽوبر\x1F" &
  "ڊسمبر\x1Fآچر\x1Fسومر\x1Fاڱارو\x1Fاربع\x1Fخميس\x1Fجمعو\x1Fڇنڇر\x1Fپهرين ٽي ماهي\x1F" &
  "ٻين ٽي ماهي\x1Fٽين ٽي ماهي\x1Fچوٿين ٽي ماهي\x1Fپهرين ٽماهي\x1F" &
  "ٻين ٽماهي\x1Fٽين ٽماهي\x1Fچوٿين ٽماهي\x1Fصبح\x1Fشام\x1Fق م\x1Fع\x1F" &
  "फेबरवरी\x1Fमार्चु\x1Fअप्रेल\x1Fआगस्ट\x1Fआक्टोबर\x1F" &
  "डिसंबर\x1Fजन\x1Fफर\x1Fअप्रै\x1Fजु\x1Fअग\x1Fसप्टे\x1Fनवं\x1F" &
  "डिसं\x1Fजुला\x1Fआर्तवार\x1Fसूमर\x1Fमंगलु\x1Fॿुधर\x1F" &
  "विस्पत\x1Fजुमो\x1Fछंछर\x1Fआर्त\x1Fसू\x1Fमंग\x1Fॿुध\x1F" &
  "विस\x1Fजुम\x1Fछंछ\x1Fपहिंरी टिमाही\x1Fबीं॒ टिमाही\x1F" &
  "टीं टिमाही\x1Fचोथीं टिमाही\x1Fबीसी\x1Fएडी\x1F" &
  "ođđajagemánnu\x1Fguovvamánnu\x1Fnjukčamánnu\x1Fcuoŋománnu\x1Fmiessemánnu\x1Fgeassemánnu\x1F" &
  "suoidnemánnu\x1Fborgemánnu\x1Fčakčamánnu\x1Fgolggotmánnu\x1Fskábmamánnu\x1Fjuovlamánnu\x1F" &
  "ođđj\x1Fguov\x1Fnjuk\x1Fcuo\x1Fmies\x1Fgeas\x1Fsuoi\x1Fborg\x1Fčakč\x1Fgolg\x1Fskáb\x1Fjuov\x1Fsotnabeaivi\x1Fvuossárga\x1F" &
  "maŋŋebárga\x1Fgaskavahkku\x1Fduorasdat\x1Fbearjadat\x1Flávvardat\x1Fsotn\x1Fvuos\x1Fmaŋ\x1Fgask\x1Fduor\x1F" &
  "bear\x1Fláv\x1Fi.b.\x1Fe.b.\x1Fo.Kr.\x1Fm.Kr.\x1Fcuoŋ\x1Fmánnodat\x1Fdisdat\x1Fduorastat\x1Flávvordat\x1Fmá\x1Fga\x1F" &
  "be\x1Flá\x1F1. njealjádas\x1F2. njealjádas\x1F3. njealjádas\x1F4. njealjádas\x1F1Q\x1F2Q\x1F3Q\x1F4Q\x1Fib\x1F" &
  "eb\x1FoKr.\x1FmKr.\x1FJaneiro\x1FFevreiro\x1FMarco\x1FMaio\x1FJunho\x1FJulho\x1FAugusto\x1FSetembro\x1FOtubro\x1FDimingu\x1F" &
  "Chiposi\x1FChipiri\x1FChitatu\x1FChinai\x1FChishanu\x1FSabudu\x1FPos\x1FPir\x1FNai\x1FAC\x1FNyenye\x1FFulundïgi\x1FMbängü\x1F" &
  "Ngubùe\x1FBêläwü\x1FFöndo\x1FLengua\x1FKükürü\x1FMvuka\x1FNgberere\x1FNabändüru\x1FKakauka\x1FNye\x1F" &
  "Mbä\x1FBêl\x1FFön\x1FLen\x1FKük\x1FNgb\x1FNab\x1FKak\x1FBikua-ôko\x1FBïkua-ûse\x1FBïkua-ptâ\x1FBïkua-usïö\x1F" &
  "Bïkua-okü\x1FLâpôsö\x1FLâyenga\x1FBk1\x1FBk2\x1FBk3\x1FBk4\x1FBk5\x1FLâp\x1FLây\x1FFângbisïö ôko\x1FFângbisïö ûse\x1F" &
  "Fângbisïö otâ\x1FFângbisïö usïö\x1FF4–1\x1FF4–2\x1FF4–3\x1FF4–4\x1FND\x1FLK\x1FKnK\x1FNpK\x1Fⵉⵏⵏⴰⵢⵔ\x1F" &
  "ⴱⵕⴰⵢⵕ\x1Fⵎⴰⵕⵚ\x1Fⵉⴱⵔⵉⵔ\x1Fⵎⴰⵢⵢⵓ\x1Fⵢⵓⵏⵢⵓ\x1Fⵢⵓⵍⵢⵓⵣ\x1F" &
  "ⵖⵓⵛⵜ\x1Fⵛⵓⵜⴰⵏⴱⵉⵔ\x1Fⴽⵜⵓⴱⵔ\x1Fⵏⵓⵡⴰⵏⴱⵉⵔ\x1Fⴷⵓⵊⴰⵏⴱⵉⵔ\x1F" &
  "ⵉⵏⵏ\x1Fⴱⵕⴰ\x1Fⵎⴰⵕ\x1Fⵉⴱⵔ\x1Fⵎⴰⵢ\x1Fⵢⵓⵏ\x1Fⵢⵓⵍ\x1Fⵖⵓⵛ\x1Fⵛⵓⵜ\x1F" &
  "ⴽⵜⵓ\x1Fⵏⵓⵡ\x1Fⴷⵓⵊ\x1Fⴰⵙⴰⵎⴰⵙ\x1Fⴰⵢⵏⴰⵙ\x1Fⴰⵙⵉⵏⴰⵙ\x1F" &
  "ⴰⴽⵕⴰⵙ\x1Fⴰⴽⵡⴰⵙ\x1Fⵙⵉⵎⵡⴰⵙ\x1Fⴰⵙⵉⴹⵢⴰⵙ\x1Fⴰⵙⴰ\x1F" &
  "ⴰⵢⵏ\x1Fⴰⵙⵉ\x1Fⴰⴽⵕ\x1Fⴰⴽⵡ\x1Fⴰⵙⵉⵎ\x1Fⴰⵙⵉⴹ\x1Fⴰⴽⵕⴰⴹⵢⵓⵔ 1\x1F" &
  "ⴰⴽⵕⴰⴹⵢⵓⵔ 2\x1Fⴰⴽⵕⴰⴹⵢⵓⵔ 3\x1Fⴰⴽⵕⴰⴹⵢⵓⵔ 4\x1F" &
  "ⴰⴽ 1\x1Fⴰⴽ 2\x1Fⴰⴽ 3\x1Fⴰⴽ 4\x1Fⵜⵉⴼⴰⵡⵜ\x1Fⵜⴰⴷⴳⴳⵯⴰⵜ\x1Fⴷⴰⵄ\x1F" &
  "ⴷⴼⵄ\x1Finnayr\x1Fbṛayṛ\x1Fmaṛṣ\x1Fibrir\x1Fmayyu\x1Fyunyu\x1Fyulyuz\x1Fɣuct\x1Fcutanbir\x1Fktubr\x1F" &
  "nuwanbir\x1Fdujanbir\x1Finn\x1Fbṛa\x1Fmaṛ\x1Fibr\x1Fɣuc\x1Fcut\x1Fktu\x1Fnuw\x1Fduj\x1Fasamas\x1Faynas\x1Fasinas\x1Fakṛas\x1F" &
  "akwas\x1Fasimwas\x1Fasiḍyas\x1Fasa\x1Fayn\x1Fasi\x1Fakṛ\x1Fakw\x1Fasim\x1Fasiḍ\x1Fakṛaḍyur 1\x1Fakṛaḍyur 2\x1F" &
  "akṛaḍyur 3\x1Fakṛaḍyur 4\x1Fak 1\x1Fak 2\x1Fak 3\x1Fak 4\x1Ftifawt\x1Ftadggʷat\x1Fdaɛ\x1Fdfɛ\x1Fၸၼ်ႇဝႃႇရီႇ\x1F" &
  "ၾႅပ်ႇဝႃႇရီႇ\x1Fမၢတ်ႉၶျ်\x1Fဢေႇပရႄႇ\x1F" &
  "မေႇ\x1Fၸုၼ်ႇ\x1Fၸူႇလၢႆႇ\x1Fဢေႃးၵၢတ်ႉ\x1Fသႅပ်ႇထႅမ်ႇပႃႇ\x1F" &
  "ဢွၵ်ႇထူဝ်ႇပႃႇ\x1Fၼူဝ်ႇဝႅမ်ႇပႃႇ\x1Fတီႇသႅမ်ႇပႃႇ\x1F" &
  "ၸၼ်ႇ\x1Fၾႅပ်ႇ\x1Fဢေႇ\x1Fၸူႇ\x1Fဢေႃး\x1Fသႅပ်ႇ\x1Fဢွၵ်ႇ\x1F" &
  "ၼူဝ်ႇ\x1Fတီႇ\x1Fဝၼ်းဢႃးတိတ်ႉ\x1Fဝၼ်းၸၼ်\x1F" &
  "ဝၼ်းဢင်းၵၢၼ်း\x1Fဝၼ်းပုတ်ႉ\x1Fဝၼ်းၽတ်း\x1F" &
  "ဝၼ်းသုၵ်း\x1Fဝၼ်းသဝ်\x1Fတိတ်ႉ\x1Fၸၼ်\x1Fၵၢၼ်း\x1F" &
  "ပုတ်ႉ\x1Fၽတ်း\x1Fသုၵ်း\x1Fသဝ်\x1Fသၢမ်လိူၼ်ႁွပ်ႈ 1\x1F" &
  "သၢမ်လိူၼ်ႁွပ်ႈ 2\x1Fသၢမ်လိူၼ်ႁွပ်ႈ 3\x1F" &
  "သၢမ်လိူၼ်ႁွပ်ႈ 4\x1Fတၸ.\x1Fတလ.\x1Fပီႇၸီႇ\x1Fဢေႇတီႇ\x1F" &
  "y MMMM d - EEEE\x1Fy-MM-dd - E\x1Fy MMM d - E\x1FG y MMM d - E\x1FMM-dd - E\x1FMMM d - E\x1Fd - E\x1Fදුරුතු\x1F" &
  "නවම්\x1Fමැදින්\x1Fබක්\x1Fවෙසක්\x1Fපොසොන්\x1Fඇසළ\x1F" &
  "නිකිණි\x1Fබිනර\x1Fවප්\x1Fඉල්\x1Fඋඳුවප්\x1Fඉරිදා\x1F" &
  "සඳුදා\x1Fඅඟහරුවාදා\x1Fබදාදා\x1Fබ්‍රහස්පතින්දා\x1F" &
  "සිකුරාදා\x1Fසෙනසුරාදා\x1Fඅඟහ\x1Fබ්‍රහස්\x1F" &
  "සිකු\x1Fසෙන\x1F1 වන කාර්තුව\x1F2 වන කාර්තුව\x1F" &
  "3 වන කාර්තුව\x1F4 වන කාර්තුව\x1Fකාර්:1\x1Fකාර්:2\x1F" &
  "කාර්:3\x1Fකාර්:4\x1Fපෙ.ව.\x1Fප.ව.\x1Fක්‍රි.පූ.\x1Fක්‍රි.ව.\x1F" &
  "y-M-d, E\x1FM-d, E\x1FMMM d E\x1Fjanuára\x1Ffebruára\x1Fapríla\x1Fmája\x1Fjúna\x1Fjúla\x1Faugusta\x1Foktóbra\x1F" &
  "novembra\x1Fmáj\x1Fjún\x1Fjúl\x1Fmarec\x1Fnedeľa\x1Fpondelok\x1Futorok\x1Fstreda\x1Fštvrtok\x1Fpiatok\x1Fut\x1Fpi\x1F" &
  "1. štvrťrok\x1F2. štvrťrok\x1F3. štvrťrok\x1F4. štvrťrok\x1Fpred Kr.\x1Favgust\x1Favg.\x1Fnedelja\x1F" &
  "ponedeljek\x1Ftorek\x1Fsreda\x1Fčetrtek\x1Fpetek\x1Fned.\x1Fsre.\x1Fčet.\x1Fpet.\x1F1. četrtletje\x1F2. četrtletje\x1F" &
  "3. četrtletje\x1F4. četrtletje\x1F1. čet.\x1F2. čet.\x1F3. čet.\x1F4. čet.\x1FE, d. M. y\x1Fuđđâivemáánu\x1F" &
  "kuovâmáánu\x1Fnjuhčâmáánu\x1Fcuáŋuimáánu\x1Fvyesimáánu\x1Fkesimáánu\x1Fsyeinimáánu\x1F" &
  "porgemáánu\x1Fčohčâmáánu\x1Froovvâdmáánu\x1Fskammâmáánu\x1Fjuovlâmáánu\x1Fuđiv\x1F" &
  "kuovâ\x1Fnjuhčâ\x1Fcuáŋui\x1Fvyesi\x1Fkesi\x1Fsyeini\x1Fporge\x1Fčohčâ\x1Froovvâd\x1Fskammâ\x1Fjuovlâ\x1F" &
  "pasepeeivi\x1Fvuossaargâ\x1Fmajebaargâ\x1Fkoskoho\x1Ftuorâstuv\x1Fvástuppeeivi\x1Flávurduv\x1Fpas\x1F" &
  "vuo\x1Fkos\x1Ftuo\x1Fvás\x1F1. niäljádâs\x1F2. niäljádâs\x1F3. niäljádâs\x1F4. niäljádâs\x1F" &
  "1. niälj.\x1F2. niälj.\x1F3. niälj.\x1F4. niälj.\x1Fep.\x1Fcccc, MMMM d. y\x1FMMMM d. y\x1FMMM d. y\x1F" &
  "ccc, MMM d. y\x1FMMM d. y G\x1FE, MMM d. y G\x1FE, MMM d.\x1Fm.ss.\x1FNdira\x1FKukadzi\x1FKurume\x1FKubvumbi\x1F" &
  "Chivabvu\x1FChikumi\x1FChikunguru\x1FNyamavhuvhu\x1FGunyana\x1FGumiguru\x1FMbudzi\x1FZvita\x1FNdi\x1FKuk\x1FKub\x1F" &
  "Chv\x1FChk\x1FChg\x1FGun\x1FGum\x1FMbu\x1FZvi\x1FSvondo\x1FMuvhuro\x1FChina\x1FMugovera\x1FSvo\x1FMuv\x1FChp\x1FCht\x1FChn\x1FChs\x1F" &
  "Janaayo\x1FFebraayo\x1FMaarso\x1FAbriil\x1FMaayo\x1FJuun\x1FLuulyo\x1FSebtembar\x1FOktoobar\x1FNoofeembar\x1FDiseembar\x1F" &
  "Ogs\x1FJannaayo\x1FOgosto\x1FSebteembar\x1FAxad\x1FIsniin\x1FTalaado\x1FArbaco\x1FKhamiis\x1FJimco\x1FSabti\x1FAxd\x1F" &
  "Tldo\x1FArbc\x1FKhms\x1FJmc\x1FSbti\x1FRubaca 1aad\x1FRubaca 2aad\x1FRubaca 3aad\x1FRubaca 4aad\x1FGH\x1FGD\x1Fjanar\x1F" &
  "shkurt\x1Fprill\x1Fqershor\x1Fkorrik\x1Fgusht\x1Fshtator\x1Ftetor\x1Fnëntor\x1Fdhjetor\x1Fshk\x1Fpri\x1Fqer\x1Fkorr\x1F" &
  "gush\x1Fsht\x1Ftet\x1Fnën\x1Fdhj\x1Fe diel\x1Fe hënë\x1Fe martë\x1Fe mërkurë\x1Fe enjte\x1Fe premte\x1Fe shtunë\x1F" &
  "die\x1Fhën\x1Fmër\x1Fenj\x1Fpre\x1Ftremujori i parë\x1Ftremujori i dytë\x1Ftremujori i tretë\x1Ftremujori i katërt\x1F" &
  "tremujori I\x1Ftremujori II\x1Ftremujori III\x1Ftremujori IV\x1Fp.d.\x1Fm.d.\x1Fp.K.\x1Fmb.K.\x1Fh:mm:ss a, zzzz\x1F" &
  "h:mm:ss a, z\x1Fd.M.y GGGG\x1Fнедеља\x1Fпонедељак\x1Fсре\x1Fпрви квартал\x1F" &
  "други квартал\x1Fтрећи квартал\x1Fчетврти квартал\x1F" &
  "1. кв.\x1F2. кв.\x1F3. кв.\x1F4. кв.\x1Fd.M.y. GGGGG\x1FE d. MMM y. G\x1FM. y.\x1Fприје подне\x1F" &
  "по подне\x1Fсепт\x1Favg\x1Fponedeljak\x1Fsre\x1Fprvi kvartal\x1Fdrugi kvartal\x1Ftreći kvartal\x1F" &
  "četvrti kvartal\x1Fprije podne\x1Fpo podne\x1FPherekgong\x1FHlakola\x1FHlakubele\x1FMmesa\x1FMotsheanong\x1F" &
  "Phupjane\x1FPhupu\x1FPhato\x1FLwetse\x1FMphalane\x1FPudungwana\x1FTshitwe\x1FPhe\x1FHlb\x1FMme\x1FMot\x1FUpu\x1FPha\x1FLeo\x1F" &
  "Mph\x1FPun\x1FTsh\x1FSontaha\x1FMantaha\x1FMoqebelo\x1FMma\x1FMoq\x1FPébruari\x1FMéi\x1FSéptémber\x1FNopémber\x1F" &
  "Désémber\x1FPéb\x1FAgs\x1FSép\x1FNop\x1FDés\x1FSenén\x1FSalasa\x1FRebo\x1FKemis\x1FJumaah\x1FSaptu\x1FMng\x1FSal\x1FReb\x1F" &
  "Kem\x1Fkuartal ka-1\x1Fkuartal ka-2\x1Fkuartal ka-3\x1Fkuartal ka-4\x1F𑯏𑯈𑯍𑯈𑯅𑯄𑯃\x1F" &
  "𑯙𑯂𑯎𑯅𑯄𑯈𑯄𑯃\x1F𑯇𑯖𑯄𑯌\x1F𑯈𑯉𑯄𑯃𑯐\x1F𑯇𑯂\x1F𑯏𑯅𑯍\x1F" &
  "𑯏𑯅𑯐𑯖𑯃\x1F𑯈𑯊𑯈𑯒𑯞\x1F𑯒𑯂𑯉𑯞𑯃𑯇𑯎𑯈𑯄\x1F𑯈𑯆𑯞𑯅𑯎𑯈𑯄\x1F" &
  "𑯍𑯑𑯎𑯂𑯇𑯎𑯈𑯄\x1F𑯀𑯃𑯒𑯂𑯇𑯎𑯈𑯄\x1F𑯌𑯂𑯄𑯂𑯍𑯖̍𑯠𑯁𑯃\x1F" &
  "𑯁𑯖̍𑯒𑯍𑯖̍𑯠𑯁𑯃\x1F𑯄𑯃𑯇𑯒𑯃𑯍𑯖̍𑯠𑯁𑯃\x1F𑯀𑯅𑯇𑯒𑯃𑯍𑯖̍𑯠𑯁𑯃\x1F" &
  "𑯋𑯑𑯐𑯙𑯖𑯍𑯖̍𑯠𑯁𑯃\x1F𑯊𑯃𑯐𑯙𑯖𑯍𑯖̍𑯠𑯁𑯃\x1F" &
  "𑯄𑯂𑯐𑯙𑯖𑯍𑯖̍𑯠𑯁𑯃\x1Faugusti\x1Fsöndag\x1Ftisdag\x1Flördag\x1Fsön\x1Fmån\x1F" &
  "tis\x1Fons\x1Ftors\x1Flör\x1F1:a kvartalet\x1F2:a kvartalet\x1F3:e kvartalet\x1F4:e kvartalet\x1Ffm\x1Fem\x1Ffm.\x1F" &
  "em.\x1FRobo ya 1\x1FRobo ya 2\x1FRobo ya 3\x1FRobo ya 4\x1Fܟܢܘܢ ܐܚܪܝܐ\x1Fܫܒܛ\x1Fܐܕܪ\x1Fܢܝܣܢ\x1F" &
  "ܐܝܪ\x1Fܚܙܝܪܢ\x1Fܬܡܘܙ\x1Fܐܒ\x1Fܐܝܠܘܠ\x1Fܬܫܪܝܢ ܩܕܡܝܐ\x1Fܬܫܪܝܢ ܐܚܪܝܐ\x1F" &
  "ܟܢܘܢ ܩܕܡܝܐ\x1Fܟܢܘܢ ܒ\x1Fܬܫܪܝܢ ܐ\x1Fܬܫܪܝܢ ܒ\x1Fܟܢܘܢ ܐ\x1Fܚܕܒܫܒܐ\x1F" &
  "ܬܪܝܢܒܫܒܐ\x1Fܬܠܬܒܫܒܐ\x1Fܐܪܒܥܒܫܒܐ\x1Fܚܡܫܒܫܒܐ\x1Fܥܪܘܒܬܐ\x1Fܫܒܬܐ\x1F" &
  "ܚܕ\x1Fܬܪܝܢ\x1Fܬܠܬ\x1Fܐܪܒܥ\x1Fܚܡܫ\x1Fܥܪܘ\x1Fܪܘܒܥܐ ܩܕܡܝܐ\x1Fܪܘܒܥܐ ܬܪܝܢܐ\x1F" &
  "ܪܘܒܥܐ ܬܠܝܬܝܐ\x1Fܪܘܒܥܐ ܪܒܝܥܝܐ\x1F܏ܪ ܐ\x1F܏ܪ ܒ\x1F܏ܪ ܓ\x1F܏ܪ ܕ\x1F܏ܩܛ‌\x1F" &
  "܏ܒܛ‌\x1F܏ܩܡ‌\x1F܏ܫܡ‌\x1FEEEE، d ܒMMMM y\x1Fd ܒMMMM y\x1Fd ܒMMM y\x1Fd-MM-y\x1FE، d ܒMMM y\x1F" &
  "d ܒMMM y G\x1FEEEE، d ܒMMM y G\x1FEEEE، dd/MM\x1Fd ܒMMM\x1FE، d ܒMMM\x1Fd ܒMMMM\x1Fmoja\x1Fczyrwca\x1F" &
  "siyrpnia\x1Fniydziela\x1Fpyńdziałek\x1Fstrzoda\x1Fsztwortek\x1Fpiōntek\x1Fdo połedniŏ\x1Fpo połedniu\x1F" &
  "ஜனவரி\x1Fபிப்ரவரி\x1Fமார்ச்\x1Fஏப்ரல்\x1Fமே\x1F" &
  "ஜூன்\x1Fஜூலை\x1Fஆகஸ்ட்\x1Fசெப்டம்பர்\x1Fஅக்டோபர்\x1F" &
  "நவம்பர்\x1Fடிசம்பர்\x1Fஜன.\x1Fபிப்.\x1Fமார்.\x1F" &
  "ஏப்.\x1Fஆக.\x1Fசெப்.\x1Fஅக்.\x1Fநவ.\x1Fடிச.\x1Fஞாயிறு\x1F" &
  "திங்கள்\x1Fசெவ்வாய்\x1Fபுதன்\x1Fவியாழன்\x1F" &
  "வெள்ளி\x1Fசனி\x1Fஞாயி.\x1Fதிங்.\x1Fசெவ்.\x1Fபுத.\x1F" &
  "வியா.\x1Fவெள்.\x1Fமுதல் காலாண்டு\x1Fஇரண்டாம் காலாண்டு\x1F" &
  "மூன்றாம் காலாண்டு\x1Fநான்காம் காலாண்டு\x1F" &
  "கா.1\x1Fகா.2\x1Fகா.3\x1Fகா.4\x1Fகி.மு.\x1Fகி.பி.\x1Fజనవరి\x1F" &
  "ఫిబ్రవరి\x1Fమార్చి\x1Fఏప్రిల్\x1Fమే\x1Fజూన్\x1F" &
  "జులై\x1Fఆగస్టు\x1Fసెప్టెంబర్\x1Fఅక్టోబర్\x1F" &
  "నవంబర్\x1Fడిసెంబర్\x1Fజన\x1Fఫిబ్ర\x1Fఏప్రి\x1F" &
  "ఆగ\x1Fసెప్టెం\x1Fఅక్టో\x1Fనవం\x1Fడిసెం\x1Fఆదివారం\x1F" &
  "సోమవారం\x1Fమంగళవారం\x1Fబుధవారం\x1Fగురువారం\x1F" &
  "శుక్రవారం\x1Fశనివారం\x1Fఆది\x1Fసోమ\x1Fమంగళ\x1F" &
  "బుధ\x1Fగురు\x1Fశుక్ర\x1Fశని\x1F1వ త్రైమాసికం\x1F" &
  "2వ త్రైమాసికం\x1F3వ త్రైమాసికం\x1F4వ త్రైమాసికం\x1F" &
  "త్రై1\x1Fత్రై2\x1Fత్రై3\x1Fత్రై4\x1Fd, MMMM y, EEEE\x1Fd MMM, y, E\x1F" &
  "G d, MMM y\x1FG, d MMM, y, E\x1FOrara\x1FOmuk\x1FOkwamg’\x1FOdung’el\x1FOmaruk\x1FOmodok’king’ol\x1F" &
  "Ojola\x1FOpedel\x1FOsokosokoma\x1FOtibar\x1FOlabor\x1FOpoo\x1FMuk\x1FDun\x1FMod\x1FPed\x1FSok\x1FTib\x1FLab\x1FPoo\x1FNakaejuma\x1F" &
  "Nakaebarasa\x1FNakaare\x1FNakauni\x1FNakaung’on\x1FNakakany\x1FNakasabiti\x1FBar\x1FAar\x1FUni\x1FUng\x1FAkwota abe\x1F" &
  "Akwota Aane\x1FAkwota auni\x1FAkwota Aung’on\x1FTaparachu\x1FEbongi\x1FЯнвар\x1FСентябр\x1F" &
  "Октябр\x1FНоябр\x1FЯкшанбе\x1FДушанбе\x1FСешанбе\x1FЧоршанбе\x1F" &
  "Панҷшанбе\x1FҶумъа\x1FШанбе\x1FЯшб\x1FДшб\x1FСшб\x1FЧшб\x1FПшб\x1FҶмъ\x1F" &
  "Шнб\x1FЧ1\x1FЧ2\x1FЧ3\x1FЧ4\x1FПеМ\x1FПаМ\x1Fมกราคม\x1Fกุมภาพันธ์\x1F" &
  "มีนาคม\x1Fเมษายน\x1Fพฤษภาคม\x1Fมิถุนายน\x1F" &
  "กรกฎาคม\x1Fสิงหาคม\x1Fกันยายน\x1Fตุลาคม\x1F" &
  "พฤศจิกายน\x1Fธันวาคม\x1Fม.ค.\x1Fก.พ.\x1Fมี.ค.\x1Fเม.ย.\x1F" &
  "พ.ค.\x1Fมิ.ย.\x1Fก.ค.\x1Fส.ค.\x1Fก.ย.\x1Fต.ค.\x1Fพ.ย.\x1Fธ.ค.\x1Fวันอาทิตย์\x1F" &
  "วันจันทร์\x1Fวันอังคาร\x1Fวันพุธ\x1Fวันพฤหัสบดี\x1F" &
  "วันศุกร์\x1Fวันเสาร์\x1Fอาทิตย์\x1Fจันทร์\x1F" &
  "อังคาร\x1Fพุธ\x1Fพฤหัส\x1Fศุกร์\x1Fเสาร์\x1Fไตรมาส 1\x1F" &
  "ไตรมาส 2\x1Fไตรมาส 3\x1Fไตรมาส 4\x1Fก่อน ค.ศ.\x1F" &
  "ค.ศ.\x1FEEEEที่ d MMMM G y\x1Fd MMMM G y\x1FH นาฬิกา mm นาที ss วินาที zzzz\x1F" &
  "H นาฬิกา mm นาที ss วินาที z\x1FHH:mm น.\x1Fd MMM G y\x1F" &
  "E d MMM G y\x1FQQQQ G y\x1Fጥሪ\x1Fለካቲት\x1Fመጋቢት\x1Fሚያዝያ\x1Fጉንበት\x1Fሰነ\x1F" &
  "ሓምለ\x1Fነሓሰ\x1Fመስከረም\x1Fጥቅምቲ\x1Fሕዳር\x1Fታሕሳስ\x1Fለካ\x1Fመጋ\x1F" &
  "ሚያ\x1Fግን\x1Fሓም\x1Fነሓ\x1Fመስ\x1Fጥቅ\x1Fሕዳ\x1Fታሕ\x1Fሰንበት\x1Fሰኑይ\x1Fሰሉስ\x1F" &
  "ሓሙስ\x1Fዓርቢ\x1Fቀዳም\x1Fሰን\x1Fሰኑ\x1Fሰሉ\x1Fረቡ\x1Fሓሙ\x1Fዓር\x1Fቀዳ\x1F1ይ ርብዒ\x1F" &
  "2ይ ርብዒ\x1F3ይ ርብዒ\x1F4ይ ርብዒ\x1Fር1\x1Fር2\x1Fር3\x1Fር4\x1Fቅ.ቀ.\x1Fድ.ቀ.\x1F" &
  "EEEE፣ d MMMM y\x1FE፣ d MMM y G\x1FE፣ d MMM\x1Fýanwar\x1Ffewral\x1Fmaý\x1Fiýun\x1Fiýul\x1Fsentýabr\x1F" &
  "oktýabr\x1Fnoýabr\x1Fýan\x1Ffew\x1Fnoý\x1FÝanwar\x1FFewral\x1FMart\x1FAprel\x1FMaý\x1FIýun\x1FIýul\x1FAwgust\x1F" &
  "Sentýabr\x1FOktýabr\x1FNoýabr\x1FDekabr\x1FÝan\x1FFew\x1FAwg\x1FNoý\x1FDek\x1Fýekşenbe\x1Fduşenbe\x1Fsişenbe\x1F" &
  "çarşenbe\x1Fpenşenbe\x1Fanna\x1Fşenbe\x1Fýek\x1Fduş\x1Fsiş\x1Fçar\x1Fpen\x1Fann\x1Fşen\x1F1-nji çärýek\x1F" &
  "2-nji çärýek\x1F3-nji çärýek\x1F4-nji çärýek\x1F1Ç\x1F2Ç\x1F3Ç\x1F4Ç\x1Fgo.öň\x1Fgo.soň\x1FB.e.öň\x1F" &
  "Ferikgong\x1FTlhakole\x1FMopitlo\x1FMoranang\x1FMotsheganong\x1FSeetebosigo\x1FPhukwi\x1FPhatwe\x1FDiphalane\x1F" &
  "Ngwanatsele\x1FSedimonthole\x1FFer\x1FTlh\x1FMop\x1FMor\x1FSee\x1FPhu\x1FDip\x1FNgw\x1FTshipi\x1FMosupologo\x1FLabotlhano\x1F" &
  "Matlhatso\x1FLabb\x1FLabr\x1FLabn\x1FLabt\x1FSephatlho sa ntlha sa ngwaga\x1FSephatlho sa bobedi\x1FSephatlho sa boraro\x1F" &
  "Sephatlho sa bone\x1FSānuali\x1FFēpueli\x1FMaʻasi\x1FʻEpeleli\x1FMē\x1FSune\x1FSiulai\x1FʻAokosi\x1FSēpitema\x1F" &
  "ʻOkatopa\x1FNōvema\x1FTīsema\x1FSān\x1FFēp\x1FMaʻa\x1FʻEpe\x1FSun\x1FSiu\x1FʻAok\x1FSēp\x1FʻOka\x1FNōv\x1FTīs\x1F" &
  "Sāpate\x1FMōnite\x1FTūsite\x1FPulelulu\x1FTuʻapulelulu\x1FFalaite\x1FTokonaki\x1FSāp\x1FMōn\x1FTūs\x1FPul\x1F" &
  "Tuʻa\x1FFal\x1FTok\x1Fkuata ʻuluaki\x1Fkuata ua\x1Fkuata tolu\x1Fkuata fā\x1FEA\x1FTS\x1Fdd MM y GGGGG\x1F¤#,#0.00\x1F" &
  "tenpo mun #1\x1Ftenpo mun #2\x1Ftenpo mun #3\x1Ftenpo mun #4\x1Ftenpo mun #5\x1Ftenpo mun #6\x1Ftenpo mun #7\x1F" &
  "tenpo mun #8\x1Ftenpo mun #9\x1Ftenpo mun #10\x1Ftenpo mun #11\x1Ftenpo mun #12\x1Fsuno esun #7\x1F" &
  "suno esun #1\x1Fsuno esun #2\x1Fsuno esun #3\x1Fsuno esun #4\x1Fsuno esun #5\x1Fsuno esun #6\x1F'sike' #y 'la' MMM 'la' 'suno' #d\x1F" &
  "'tenpo' 'sike' #y 'la' 'tenpo' MMMM 'la' 'tenpo' 'suno' #d\x1Fzzzz 'la' HH:mm:ss\x1Fz 'la' HH:mm:ss\x1F" &
  "#y)#M)#d\x1F#y 'la' MMMM\x1F'sike' #y ) #M ) #d\x1F#y 'la' QQQ\x1F#y 'la' QQQQ\x1F#y\x1F#d\x1F#HH:mm:ss\x1F" &
  "#HH:mm\x1F#h:mm:ss a\x1F#h:mm a\x1F'tenpo' 'ilo' #h a\x1FOcak\x1FŞubat\x1FNisan\x1FMayıs\x1FHaziran\x1F" &
  "Temmuz\x1FAğustos\x1FEylül\x1FEkim\x1FKasım\x1FAralık\x1FOca\x1FŞub\x1FNis\x1FHaz\x1FTem\x1FAğu\x1FEyl\x1FEki\x1FPazar\x1F" &
  "Pazartesi\x1FSalı\x1FÇarşamba\x1FPerşembe\x1FCuma\x1FCumartesi\x1FPaz\x1FPzt\x1FÇar\x1FPer\x1FCum\x1F1. çeyrek\x1F" &
  "2. çeyrek\x1F3. çeyrek\x1F4. çeyrek\x1FÖÖ\x1FÖS\x1FMÖ\x1FMS\x1Fd MMMM y EEEE\x1Fd.M.y E\x1Fd MMM y E\x1F" &
  "G d.M.y\x1FG d MMM y E\x1Fd MMM E\x1Fгыйнвар\x1Fгыйн.\x1Fякшәмбе\x1Fсишәмбе\x1F" &
  "чәршәмбе\x1Fпәнҗешәмбе\x1Fҗомга\x1Fшимбә\x1Fякш.\x1Fсиш.\x1Fчәр.\x1F" &
  "пәнҗ.\x1Fҗом.\x1Fшим.\x1F1 нче квартал\x1F2 нче квартал\x1F3 нче квартал\x1F" &
  "4 нче квартал\x1F1 нче кв.\x1F2 нче кв.\x1F3 нче кв.\x1F4 нче кв.\x1F" &
  "б.э.к.\x1Fмилади\x1Fd MMMM, y 'ел', EEEE\x1Fd MMMM, y 'ел'\x1Fd MMM, y 'ел'\x1F" &
  "y 'ел', MMM\x1Fy 'ел', MMMM\x1Fy 'ел', d MMM\x1Fy 'ел', d MMM, E\x1FG y 'ел', d MMM\x1F" &
  "G y 'ел', d MMM, E\x1Fy 'ел', QQQ\x1Fy 'ел', QQQQ\x1FG y 'ел'\x1FМар.\x1FИюн.\x1F" &
  "Июл.\x1FУлуг-хүн\x1FПонедельник\x1FВторник\x1FСреда\x1FЧетверг\x1F" &
  "Пятница\x1FСуббота\x1FУХ\x1FПН\x1FВТ\x1FСР\x1FЧТ\x1FПТ\x1FСБ\x1F1ги квартал\x1F" &
  "2ги квартал\x1F3кү квартал\x1F4кү квартал\x1F1ги кв.\x1F2ги кв.\x1F" &
  "3кү кв.\x1F4кү кв.\x1FБЭЧ\x1FБЭ\x1Fy'ч' MMMM d, EEEE\x1Fy'ч' MMMM d\x1Fy'ч' MMM d\x1Fy'ч' MMM\x1F" &
  "y'ч' MMMM\x1Fy'ч' MMM d, E\x1Fy'ч' QQQ\x1Fy'ч' QQQQ\x1FHH'ш'\x1FYebrayer\x1FIbrir\x1FYulyuz\x1FCutanbir\x1F" &
  "Kṭuber\x1FNwanbir\x1FDujanbir\x1FIbr\x1FCut\x1FKṭu\x1FNwa\x1FDuj\x1FAsamas\x1FAynas\x1FAsinas\x1FAkras\x1FAkwas\x1FAsimwas\x1F" &
  "Asiḍyas\x1FAyn\x1FAsn\x1FAkr\x1FAkw\x1FAsm\x1FAsḍ\x1FImir adamsan 1\x1FImir adamsan 2\x1FImir adamsan 3\x1F" &
  "Imir adamsan 4\x1FIA1\x1FIA2\x1FIA3\x1FIA4\x1FZdat azal\x1FḌeffir aza\x1FZƐ\x1FḌƐ\x1Fيانۋار\x1F" &
  "فېۋرال\x1Fمارت\x1Fئاپرېل\x1Fئىيۇن\x1Fئىيۇل\x1Fئاۋغۇست\x1Fسېنتەبىر\x1F" &
  "ئۆكتەبىر\x1Fنويابىر\x1Fدېكابىر\x1Fيەكشەنبە\x1Fدۈشەنبە\x1Fسەيشەنبە\x1F" &
  "چارشەنبە\x1Fپەيشەنبە\x1Fجۈمە\x1Fشەنبە\x1Fيە\x1Fدۈ\x1Fسە\x1Fچا\x1Fپە\x1Fجۈ\x1F" &
  "شە\x1Fبىرىنچى پەسىل\x1Fئىككىنچى پەسىل\x1Fئۈچىنچى پەسىل\x1F" &
  "تۆتىنچى پەسىل\x1F1-پەسىل\x1F2-پەسىل\x1F3-پەسىل\x1F4-پەسىل\x1Fچ.ب\x1F" &
  "چ.ك\x1Fمىلادىيە\x1Fy d-MMMM، EEEE\x1Fd-MMMM، y\x1Fd-MMM، y\x1Fy d-MMM\x1Fy d-MMM، E\x1Fy d-MMM G\x1F" &
  "y d-MMM، E G\x1Fy MMM G\x1Fсічня\x1Fлютого\x1Fберезня\x1Fквітня\x1Fтравня\x1F" &
  "червня\x1Fлипня\x1Fсерпня\x1Fвересня\x1Fжовтня\x1Fлистопада\x1F" &
  "грудня\x1Fсіч.\x1Fлют.\x1Fбер.\x1Fквіт.\x1Fтрав.\x1Fчерв.\x1Fлип.\x1Fсерп.\x1F" &
  "вер.\x1Fжовт.\x1Fлист.\x1Fгруд.\x1Fсічень\x1Fлютий\x1Fберезень\x1Fквітень\x1F" &
  "травень\x1Fчервень\x1Fлипень\x1Fсерпень\x1Fвересень\x1Fжовтень\x1F" &
  "листопад\x1Fгрудень\x1Fнеділя\x1Fпонеділок\x1Fвівторок\x1F" &
  "середа\x1Fчетвер\x1Fпʼятниця\x1Fдп\x1Fпп\x1Fдо н. е.\x1FEEEE, d MMMM y 'р'.\x1F" &
  "d MMMM y 'р'.\x1Fd MMM y 'р'.\x1FLLL y 'р'.\x1FLLLL y 'р'.\x1FE, d MMM y 'р'.\x1F" &
  "d MMM y 'р'. G\x1FE, d MMM y 'р'. G\x1FLLL y 'р'. G\x1FQQQQ y 'р'.\x1F%\x1FM01\x1FM02\x1FM03\x1F" &
  "M04\x1FM05\x1FM06\x1FM07\x1FM08\x1FM09\x1FM10\x1FM11\x1FM12\x1FTue\x1FWed\x1FThu\x1FFri\x1FBCE\x1FCE\x1Fy MMMM d, EEEE\x1Fy MMMM d\x1F" &
  "y MMM d\x1Fy MMM\x1Fy MMMM\x1Fy MMM d, E\x1FG y-MM-dd\x1FG y MMM d\x1FG y MMM d, E\x1FMMM d, E\x1FG y MMM\x1F" &
  "y QQQ\x1Fy QQQQ\x1FG y\x1Fy\x1FLLL\x1Fd\x1Fd, E\x1Fh a\x1Fmm:ss\x1Fبدھ\x1Fپہلی سہ ماہی\x1Fدوسری سہ ماہی\x1F" &
  "تیسری سہ ماہی\x1Fچوتهی سہ ماہی\x1Fقبل مسیح\x1Fعیسوی\x1FEEEE، d MMMM، y\x1F" &
  "d MMMM، y\x1Fd MMM، y\x1FE، d MMM، y\x1Fd MMM، y G\x1FE، d MMM، y G\x1FE، d/M\x1Fsentabr\x1Foktabr\x1F" &
  "Yanvar\x1FFevral\x1FIyun\x1FIyul\x1FAvgust\x1FSentabr\x1FOktabr\x1FNoyabr\x1FYan\x1FIyn\x1FIyl\x1FAvg\x1FNoy\x1Fyakshanba\x1F" &
  "dushanba\x1Fseshanba\x1Fchorshanba\x1Fpayshanba\x1Fshanba\x1FDush\x1FSesh\x1FChor\x1FShan\x1F1-chorak\x1F2-chorak\x1F" &
  "3-chorak\x1F4-chorak\x1F1-ch\x1F2-ch\x1F3-ch\x1F4-ch\x1FTO\x1Fm.a.\x1Fmilodiy\x1FEEEE, d-MMMM, y\x1Fd-MMMM, y\x1Fd-MMM, y\x1F" &
  "E, d-MMM, y\x1Fd-MMM, G y\x1FE, d-MMM, G y\x1FE, d-MMM\x1Fفبر\x1Fمار\x1Fاپر\x1Fاگس\x1Fسپت\x1F" &
  "اکت\x1Fنوم\x1Fی.\x1Fد.\x1Fس.\x1Fچ.\x1Fپ.\x1Fج.\x1Fش.\x1Fянвар\x1Fсентябр\x1Fоктябр\x1F" &
  "ноябр\x1Fякшанба\x1Fдушанба\x1Fсешанба\x1Fчоршанба\x1Fпайшанба\x1F" &
  "шанба\x1Fякш\x1Fдуш\x1Fсеш\x1Fчор\x1Fпай\x1Fжум\x1Fшан\x1F1-чорак\x1F2-чорак\x1F" &
  "3-чорак\x1F4-чорак\x1F1-ч\x1F2-ч\x1F3-ч\x1F4-ч\x1FТО\x1FТК\x1Fм.а.\x1Fмилодий\x1Fꖨꖕ ꕪꕴ ꔞꔀꕮꕊ\x1F" &
  "ꕒꕡꖝꖕ\x1Fꕾꖺ\x1Fꖢꖕ\x1Fꖑꕱ\x1Fꖱꘋ\x1Fꖱꕞꔤ\x1Fꗛꔕ\x1Fꕢꕌ\x1Fꕭꖃ\x1Fꔞꘋꕔꕿ ꕸꖃꗏ\x1F" &
  "ꖨꖕ ꕪꕴ ꗏꖺꕮꕊ\x1Fꖨꖕꔞ\x1Fꕒꕡ\x1Fꖱꕞ\x1Fꔞꘋ\x1Fꖨꖕꗏ\x1Fꕞꕌꔵ\x1Fꗳꗡꘉ\x1F" &
  "ꕚꕞꕚ\x1Fꕉꕞꕒ\x1Fꕉꔤꕆꕢ\x1Fꕉꔤꕀꕮ\x1Fꔻꔬꔳ\x1Flahadi\x1Ftɛɛnɛɛ\x1Ftalata\x1F" &
  "alaba\x1Faimisa\x1Faijima\x1Fsiɓiti\x1Fjenaro\x1Ffebraro\x1Fmajo\x1Fjugno\x1Flujo\x1Fsetenbre\x1Fotobre\x1Fnovenbre\x1F" &
  "dezenbre\x1Fjen\x1Fjug\x1Fdoménega\x1Fmarti\x1Fmèrcore\x1Fzoba\x1Fvènare\x1Fsabo\x1Fzob\x1Fvèn\x1Ftháng 1\x1Ftháng 2\x1F" &
  "tháng 3\x1Ftháng 4\x1Ftháng 5\x1Ftháng 6\x1Ftháng 7\x1Ftháng 8\x1Ftháng 9\x1Ftháng 10\x1Ftháng 11\x1F" &
  "tháng 12\x1Fthg 1\x1Fthg 2\x1Fthg 3\x1Fthg 4\x1Fthg 5\x1Fthg 6\x1Fthg 7\x1Fthg 8\x1Fthg 9\x1Fthg 10\x1Fthg 11\x1Fthg 12\x1F" &
  "Tháng 1\x1FTháng 2\x1FTháng 3\x1FTháng 4\x1FTháng 5\x1FTháng 6\x1FTháng 7\x1FTháng 8\x1FTháng 9\x1F" &
  "Tháng 10\x1FTháng 11\x1FTháng 12\x1FChủ Nhật\x1FThứ Hai\x1FThứ Ba\x1FThứ Tư\x1FThứ Năm\x1F" &
  "Thứ Sáu\x1FThứ Bảy\x1FCN\x1FThứ 2\x1FThứ 3\x1FThứ 4\x1FThứ 5\x1FThứ 6\x1FThứ 7\x1FQuý 1\x1F" &
  "Quý 2\x1FQuý 3\x1FQuý 4\x1FSA\x1FCH\x1FTCN\x1FSCN\x1FMMMM 'năm' y\x1FQQQQ 'năm' y\x1FE, 'ngày' d\x1FHH 'giờ'\x1F" &
  "janeiru\x1Ffevereiru\x1Fmarsu\x1Fmaiu\x1Fjunyu\x1Fjulyu\x1Fsetembru\x1Foutubru\x1Fnovembru\x1Fdezembru\x1Fettiminku\x1F" &
  "nihiku noolempwa\x1Fnamaanli\x1Fnamararu\x1Fnamaxexe\x1Fnamathanu\x1Fesaabadu\x1FJenner\x1FHornig\x1FMärze\x1F" &
  "Abrille\x1FMeije\x1FBráčet\x1FHeiwet\x1FÖigšte\x1FHerbštmánet\x1FWímánet\x1FWintermánet\x1FChrištmánet\x1F" &
  "Hor\x1FBrá\x1FHei\x1FÖig\x1FHer\x1FWím\x1FWin\x1FChr\x1FSunntag\x1FMäntag\x1FZištag\x1FMittwuč\x1FFróntag\x1FFritag\x1F" &
  "Samštag\x1FMän\x1FZiš\x1FMit\x1FFró\x1FSam\x1Fn. Chr\x1FSamwiyee\x1FFewriyee\x1FAwril\x1FSuwe\x1FSulet\x1FSàttumbar\x1F" &
  "Nowàmbar\x1FDesàmbar\x1FAwr\x1FSuw\x1FSàt\x1FNow\x1FDibéer\x1FAltine\x1FTalaata\x1FÀlarba\x1FAlxamis\x1FÀjjuma\x1F" &
  "Aseer\x1FDib\x1FAlt\x1FÀla\x1FAlx\x1FÀjj\x1FAse\x1F1er Trimestar\x1F2e Trimestar\x1F3e Trimestar\x1F4e Trimestar\x1F" &
  "1er Tri\x1F2e Tri\x1F3e Tri\x1F4e Tri\x1FSub\x1FNgo\x1FJC\x1FEEEE, d MMM, y\x1F{1} - {0}\x1FJanyuwari\x1FFebruwari\x1F" &
  "Matshi\x1FEpreli\x1FMeyi\x1FJulayi\x1FOkthobha\x1FOkthoba\x1FCawe\x1FLwesibini\x1FLwesithathu\x1FLwesine\x1FLwesihlanu\x1F" &
  "Caw\x1FLwesb\x1Fikota yoku-1\x1Fikota yesi-2\x1Fikota yesi-3\x1Fikota yesi-4\x1Fतोआर\x1Fसोआर\x1F" &
  "वीरवार\x1Fशुक्करवार\x1Fशनिच्चरवार\x1Fवीर\x1F" &
  "शुक्कर\x1Fपैले तिन मीन्ने\x1Fदूजे तिन मीन्ने\x1F" &
  "तीजे तिन मीन्ने\x1Fचौथे तिन मीन्ने\x1F" &
  "भ्यागा\x1Fदपेहरा/संजा\x1Fईसा-पैले\x1FSabiiti\x1F" &
  "Owokubili\x1FOwokusatu\x1FOlokuna\x1FOlokutaanu\x1FOlomukaaga\x1FSabi\x1FBala\x1FKubi\x1FKusa\x1FKuna\x1FKuta\x1FMuka\x1F" &
  "Ebisera ebyomwaka ebisoka\x1FEbisera ebyomwaka ebyokubiri\x1FEbisera ebyomwaka ebyokusatu\x1F" &
  "Ebisera ebyomwaka ebyokuna\x1FMunkyo\x1FEigulo\x1FAZ\x1FAF\x1Fpikítíkítie, oólí ú kutúan\x1F" &
  "siɛyɛ́, oóli ú kándíɛ\x1Fɔnsúmbɔl, oóli ú kátátúɛ\x1Fmesiŋ, oóli ú kénie\x1F" &
  "ensil, oóli ú kátánuɛ\x1Fɔsɔn\x1Fefute\x1Fpisuyú\x1Fimɛŋ i puɔs\x1Fimɛŋ i putúk,oóli ú kátíɛ\x1F" &
  "makandikɛ\x1Fpilɔndɔ́\x1Fo.1\x1Fo.2\x1Fo.3\x1Fo.4\x1Fo.5\x1Fo.6\x1Fo.7\x1Fo.8\x1Fo.9\x1Fo.10\x1Fo.11\x1Fo.12\x1Fsɔ́ndiɛ\x1F" &
  "móndie\x1Fmuányáŋmóndie\x1Fmetúkpíápɛ\x1Fkúpélimetúkpiapɛ\x1Ffeléte\x1Fséselé\x1Fsd\x1F" &
  "md\x1Fmw\x1Fet\x1Fkl\x1Ffl\x1Fss\x1Fndátúɛ 1\x1Fndátúɛ 2\x1Fndátúɛ 3\x1Fndátúɛ 4\x1Fkiɛmɛ́ɛm\x1Fkisɛ́ndɛ\x1F" &
  "+J.C.\x1Fיאַנואַר\x1Fפֿעברואַר\x1Fמערץ\x1Fאַפּריל\x1Fמיי\x1Fאויגוסט\x1F" &
  "סעפּטעמבער\x1Fאקטאבער\x1Fנאוועמבער\x1Fדעצעמבער\x1Fיאַנ\x1F" &
  "פֿעב\x1Fאַפּר\x1Fאויג\x1Fסעפּ\x1Fאקט\x1Fנאוו\x1Fדעצ\x1Fזונטיק\x1Fמאָנטיק\x1F" &
  "דינסטיק\x1Fמיטוואך\x1Fדאנערשטיק\x1Fפֿרײַטיק\x1Fפֿאַרמיטאָג\x1F" &
  "נאָכמיטאָג\x1FEEEE, dטן MMMM y\x1Fdטן MMMM y\x1Fdטן MMM y\x1FE, dטן MMM y\x1Fdטן MMM y G\x1F" &
  "E דעם dטן MMM yG\x1FE דעם dטן\x1FOṣù Ṣẹ́rẹ́\x1FOṣù Èrèlè\x1FOṣù Ẹrẹ̀nà\x1F" &
  "Oṣù Ìgbé\x1FOṣù Ẹ̀bibi\x1FOṣù Òkúdu\x1FOṣù Agẹmọ\x1FOṣù Ògún\x1FOṣù Owewe\x1F" &
  "Oṣù Ọ̀wàrà\x1FOṣù Bélú\x1FOṣù Ọ̀pẹ̀\x1FỌjọ́ Àìkú\x1FỌjọ́ Ajé\x1F" &
  "Ọjọ́ Ìsẹ́gun\x1FỌjọ́rú\x1FỌjọ́bọ\x1FỌjọ́ Ẹtì\x1FỌjọ́ Àbámẹ́ta\x1F" &
  "Àìkú\x1FAjé\x1FÌsẹ́gun\x1FẸtì\x1FÀbámẹ́ta\x1FÌdámẹ́rin kíní\x1FÌdámẹ́rin Kejì\x1F" &
  "Ìdámẹ́rin Kẹta\x1FÌdámẹ́rin Kẹrin\x1FÀárọ̀\x1FỌ̀sán\x1FEEEE, d MMM y\x1Fd MM y\x1F" &
  "H:m:s\x1FH:m\x1FE, d MMM , y\x1FOshù Shɛ́rɛ́\x1FOshù Èrèlè\x1FOshù Ɛrɛ̀nà\x1FOshù Ìgbé\x1F" &
  "Oshù Ɛ̀bibi\x1FOshù Òkúdu\x1FOshù Agɛmɔ\x1FOshù Ògún\x1FOshù Owewe\x1FOshù Ɔ̀wàrà\x1F" &
  "Oshù Bélú\x1FOshù Ɔ̀pɛ̀\x1FƆjɔ́ Àìkú\x1FƆjɔ́ Ajé\x1FƆjɔ́ Ìsɛ́gun\x1FƆjɔ́rú\x1F" &
  "Ɔjɔ́bɔ\x1FƆjɔ́ Ɛtì\x1FƆjɔ́ Àbámɛ́ta\x1FÌsɛ́gun\x1FƐtì\x1FÀbámɛ́ta\x1FÌdámɛ́rin kíní\x1F" &
  "Ìdámɛ́rin Kejì\x1FÌdámɛ́rin Kɛta\x1FÌdámɛ́rin Kɛrin\x1FÀárɔ̀\x1FƆ̀sán\x1Fyepé\x1F" &
  "mukũi\x1Fmusapíri\x1Firũdí\x1Fpú\x1Fpú-yepé\x1Fpú-mukũi\x1Fpú-musapíri\x1Fpú-irũdí\x1Fyepé-putimaã\x1F" &
  "yepé-yepé\x1Fyepé-mukũi\x1Fye\x1Fmk\x1Fms\x1Fid\x1Fpu\x1Fpy\x1Fps\x1Fyp\x1Fyy\x1Fym\x1Fmituú\x1Fmurakipí\x1Fmurakí-mukũi\x1F" &
  "murakí-musapíri\x1Fsupapá\x1Fyukuakú\x1Fsaurú\x1Fmit\x1Fmur\x1Fmmk\x1Fmms\x1Fsup\x1Fyuk\x1Fsau\x1Fyepésáwa musapíri-yasí\x1F" &
  "mukũisawa musapíri-yasí\x1Fmusapírisawa musapíri-yasí\x1Firũdisawa musapíri-yasí\x1F" &
  "K.s.\x1F星期日\x1F星期一\x1F星期二\x1F星期三\x1F星期四\x1F星期五\x1F星期六\x1F第1季\x1F" &
  "第2季\x1F第3季\x1F第4季\x1F上晝\x1F下晝\x1F西元前\x1F西元\x1Fy年M月d日 EEEE\x1Fah:mm:ss [zzzz]\x1F" &
  "ah:mm:ss [z]\x1Fy/M/d（E）\x1Fy年M月d日 E\x1FGd/M/y\x1FGy年M月d日 E\x1FM/d（E）\x1FM月d日 E\x1F" &
  "y年QQQ\x1FH點\x1Fah時\x1F上昼\x1F下昼\x1FHH:mm:ss [zzzz]\x1FHH:mm:ss [z]\x1FH点\x1Fah时\x1F上午\x1F下午\x1F" &
  "ndwenit\x1Fndwenngeih\x1Fndwensam\x1Fndwenseiq\x1Fndwenngux\x1Fndwenloeg\x1Fndwencaet\x1Fndwenbet\x1Fndwengouj\x1F" &
  "ndwencib\x1Fndwencib’it\x1Fndwencibngeih\x1Fngoenzsinghgiz\x1Fsinghgizit\x1Fsinghgizngeih\x1Fsinghgizsam\x1F" &
  "singhgizseiq\x1Fsinghgizhaj\x1Fsinghgizroek\x1F'bi' y 'ndwen' M 'ngoenz' d\x1Fⴰⵙⵉⵎⵡⴰⵙ\x1F" &
  "一月\x1F二月\x1F三月\x1F四月\x1F五月\x1F六月\x1F七月\x1F八月\x1F九月\x1F十月\x1F十一月\x1F十二月\x1F" &
  "周日\x1F周一\x1F周二\x1F周三\x1F周四\x1F周五\x1F周六\x1F第一季度\x1F第二季度\x1F第三季度\x1F" &
  "第四季度\x1F1季度\x1F2季度\x1F3季度\x1F4季度\x1F公元前\x1F公元\x1Fy/M/dE\x1Fy年M月d日E\x1F" &
  "Gy-MM-dd\x1FGy年M月d日E\x1FM/dE\x1FM月d日E\x1Fy年第Q季度\x1Fd日E\x1FH时\x1Fzzzz ah:mm:ss\x1Fz ah:mm:ss\x1F" &
  "d/M/y（E）\x1Fy年M月d日，E\x1FM-dE\x1F週日\x1F週一\x1F週二\x1F週三\x1F週四\x1F週五\x1F週六\x1F" &
  "Bh:mm:ss [zzzz]\x1FBh:mm:ss [z]\x1FBh:mm:ss\x1FBh:mm\x1FBh時\x1Fd/M（E）\x1FJanuwari\x1FMashi\x1FEphreli\x1F" &
  "Septhemba\x1FMas\x1FEph\x1FISonto\x1FUMsombuluko\x1FULwesibili\x1FULwesithathu\x1FULwesine\x1FULwesihlanu\x1F" &
  "UMgqibelo\x1FMso\x1FBil\x1Fikota yesi-1"

const localeTable* = [
  ("ady", 0),
  ("ady-JO", 67),
  ("ady-TR", 67),
  ("af", 69),
  ("af-NA", 171),
  ("agq", 175),
  ("ak", 273),
  ("am", 370),
  ("ar", 474),
  ("ar-AE", 580),
  ("ar-BH", 580),
  ("ar-DJ", 580),
  ("ar-DZ", 580),
  ("ar-EG", 610),
  ("ar-EH", 610),
  ("ar-ER", 610),
  ("ar-IL", 610),
  ("ar-IQ", 614),
  ("ar-JO", 662),
  ("ar-KM", 710),
  ("ar-KW", 714),
  ("ar-LB", 714),
  ("ar-LY", 764),
  ("ar-MA", 766),
  ("ar-MR", 796),
  ("ar-OM", 814),
  ("ar-PS", 814),
  ("ar-QA", 862),
  ("ar-SA", 862),
  ("ar-SD", 863),
  ("ar-SO", 863),
  ("ar-SS", 864),
  ("ar-SY", 864),
  ("ar-TD", 912),
  ("ar-TN", 912),
  ("ar-YE", 942),
  ("as", 942),
  ("asa", 1039),
  ("ast", 1132),
  ("az", 1234),
  ("az-Cyrl", 1333),
  ("az-Latn", 1429),
  ("ba", 1429),
  ("bal-Latn", 1531),
  ("bas", 1617),
  ("be", 1716),
  ("be-tarask", 1823),
  ("bem", 1823),
  ("bez", 1912),
  ("bg", 2005),
  ("bgc", 2121),
  ("bho", 2187),
  ("blo", 2255),
  ("bm", 2359),
  ("bn", 2453),
  ("bn-IN", 2556),
  ("bo", 2568),
  ("bo-IN", 2651),
  ("br", 2655),
  ("brx", 2762),
  ("bs", 2865),
  ("bs-Cyrl", 2969),
  ("bs-Latn", 3069),
  ("bua", 3069),
  ("ca", 3145),
  ("ca-AD", 3258),
  ("ca-ES-valencia", 3258),
  ("ca-FR", 3258),
  ("ca-IT", 3258),
  ("ccp", 3258),
  ("ccp-IN", 3356),
  ("ce", 3356),
  ("ceb", 3431),
  ("cgg", 3530),
  ("chr", 3621),
  ("ckb", 3720),
  ("ckb-IR", 3810),
  ("cop", 3814),
  ("cs", 3900),
  ("csw", 4009),
  ("cv", 4077),
  ("cy", 4186),
  ("da", 4285),
  ("da-GL", 4398),
  ("dav", 4398),
  ("de", 4491),
  ("de-AT", 4592),
  ("de-BE", 4600),
  ("de-CH", 4600),
  ("de-IT", 4606),
  ("de-LI", 4611),
  ("de-LU", 4616),
  ("dje", 4616),
  ("doi", 4713),
  ("dsb", 4815),
  ("dua", 4928),
  ("dyo", 5027),
  ("dz", 5115),
  ("ebu", 5212),
  ("ee", 5305),
  ("ee-TG", 5413),
  ("el", 5417),
  ("el-CY", 5527),
  ("el-polyton", 5527),
  ("en", 5533),
  ("en-001", 5625),
  ("en-150", 5647),
  ("en-AE", 5653),
  ("en-AG", 5670),
  ("en-AI", 5670),
  ("en-AS", 5674),
  ("en-AT", 5674),
  ("en-AU", 5679),
  ("en-BB", 5685),
  ("en-BE", 5685),
  ("en-BI", 5693),
  ("en-BM", 5697),
  ("en-BS", 5697),
  ("en-BW", 5697),
  ("en-BZ", 5711),
  ("en-CA", 5723),
  ("en-CC", 5732),
  ("en-CH", 5736),
  ("en-CK", 5746),
  ("en-CM", 5750),
  ("en-CX", 5754),
  ("en-CY", 5758),
  ("en-CZ", 5758),
  ("en-DE", 5760),
  ("en-DG", 5763),
  ("en-DK", 5767),
  ("en-DM", 5779),
  ("en-EE", 5779),
  ("en-ER", 5781),
  ("en-ES", 5781),
  ("en-FI", 5783),
  ("en-FJ", 5795),
  ("en-FK", 5795),
  ("en-FM", 5799),
  ("en-FR", 5799),
  ("en-GB", 5801),
  ("en-GD", 5807),
  ("en-GE", 5807),
  ("en-GG", 5809),
  ("en-GH", 5813),
  ("en-GI", 5813),
  ("en-GM", 5817),
  ("en-GS", 5817),
  ("en-GU", 5821),
  ("en-GY", 5821),
  ("en-HK", 5821),
  ("en-HU", 5823),
  ("en-ID", 5825),
  ("en-IE", 5836),
  ("en-IL", 5846),
  ("en-IM", 5853),
  ("en-IN", 5857),
  ("en-IO", 5866),
  ("en-IT", 5870),
  ("en-JE", 5872),
  ("en-JM", 5876),
  ("en-JP", 5876),
  ("en-KE", 5888),
  ("en-KI", 5892),
  ("en-KN", 5892),
  ("en-KY", 5892),
  ("en-LC", 5892),
  ("en-LR", 5892),
  ("en-LS", 5892),
  ("en-LT", 5892),
  ("en-LV", 5894),
  ("en-MG", 5896),
  ("en-MH", 5900),
  ("en-MO", 5900),
  ("en-MP", 5900),
  ("en-MS", 5900),
  ("en-MT", 5904),
  ("en-MU", 5913),
  ("en-MV", 5917),
  ("en-MW", 5927),
  ("en-MY", 5927),
  ("en-NA", 5927),
  ("en-NF", 5927),
  ("en-NG", 5931),
  ("en-NL", 5935),
  ("en-NO", 5939),
  ("en-NR", 5942),
  ("en-NU", 5946),
  ("en-NZ", 5950),
  ("en-PG", 5952),
  ("en-PH", 5952),
  ("en-PK", 5952),
  ("en-PL", 5953),
  ("en-PN", 5956),
  ("en-PR", 5960),
  ("en-PT", 5960),
  ("en-PW", 5963),
  ("en-RO", 5963),
  ("en-RW", 5966),
  ("en-SB", 5970),
  ("en-SC", 5970),
  ("en-SD", 5974),
  ("en-SE", 5974),
  ("en-SG", 5981),
  ("en-SH", 5982),
  ("en-SI", 5986),
  ("en-SK", 5989),
  ("en-SL", 5992),
  ("en-SS", 5992),
  ("en-SX", 5992),
  ("en-SZ", 5996),
  ("en-TC", 5996),
  ("en-TK", 5996),
  ("en-TO", 6000),
  ("en-TT", 6000),
  ("en-TV", 6000),
  ("en-TZ", 6004),
  ("en-UA", 6008),
  ("en-UG", 6010),
  ("en-UM", 6014),
  ("en-VC", 6014),
  ("en-VG", 6014),
  ("en-VI", 6014),
  ("en-VU", 6014),
  ("en-WS", 6014),
  ("en-ZA", 6014),
  ("en-ZM", 6032),
  ("en-ZW", 6036),
  ("eo", 6052),
  ("es", 6154),
  ("es-419", 6267),
  ("es-AR", 6290),
  ("es-BO", 6309),
  ("es-BR", 6314),
  ("es-BZ", 6318),
  ("es-CL", 6322),
  ("es-CO", 6352),
  ("es-CR", 6382),
  ("es-CU", 6386),
  ("es-DO", 6386),
  ("es-EA", 6394),
  ("es-EC", 6394),
  ("es-GQ", 6400),
  ("es-GT", 6402),
  ("es-HN", 6406),
  ("es-IC", 6410),
  ("es-MX", 6410),
  ("es-NI", 6416),
  ("es-PA", 6418),
  ("es-PE", 6430),
  ("es-PH", 6472),
  ("es-PR", 6476),
  ("es-PY", 6485),
  ("es-SV", 6507),
  ("es-US", 6509),
  ("es-UY", 6517),
  ("es-VE", 6564),
  ("et", 6586),
  ("eu", 6690),
  ("ewo", 6793),
  ("fa", 6891),
  ("fa-AF", 7000),
  ("ff", 7074),
  ("ff-Adlm", 7171),
  ("ff-Adlm-BF", 7270),
  ("ff-Adlm-CM", 7270),
  ("ff-Adlm-GH", 7270),
  ("ff-Adlm-GM", 7274),
  ("ff-Adlm-GW", 7278),
  ("ff-Adlm-LR", 7278),
  ("ff-Adlm-MR", 7282),
  ("ff-Adlm-NE", 7286),
  ("ff-Adlm-NG", 7286),
  ("ff-Adlm-SL", 7286),
  ("ff-Adlm-SN", 7290),
  ("ff-Latn", 7290),
  ("ff-Latn-BF", 7290),
  ("ff-Latn-CM", 7290),
  ("ff-Latn-GH", 7290),
  ("ff-Latn-GM", 7294),
  ("ff-Latn-GN", 7298),
  ("ff-Latn-GW", 7298),
  ("ff-Latn-LR", 7298),
  ("ff-Latn-MR", 7302),
  ("ff-Latn-NE", 7306),
  ("ff-Latn-NG", 7306),
  ("ff-Latn-SL", 7306),
  ("fi", 7310),
  ("fil", 7423),
  ("fo", 7522),
  ("fo-DK", 7628),
  ("fr", 7628),
  ("fr-BE", 7732),
  ("fr-BF", 7734),
  ("fr-BI", 7734),
  ("fr-BJ", 7734),
  ("fr-BL", 7734),
  ("fr-CA", 7734),
  ("fr-CD", 7756),
  ("fr-CF", 7756),
  ("fr-CG", 7756),
  ("fr-CH", 7756),
  ("fr-CI", 7766),
  ("fr-CM", 7766),
  ("fr-DJ", 7771),
  ("fr-DZ", 7775),
  ("fr-GA", 7779),
  ("fr-GF", 7779),
  ("fr-GN", 7779),
  ("fr-GP", 7779),
  ("fr-GQ", 7779),
  ("fr-HT", 7779),
  ("fr-KM", 7779),
  ("fr-LU", 7779),
  ("fr-MA", 7780),
  ("fr-MC", 7789),
  ("fr-MF", 7789),
  ("fr-MG", 7789),
  ("fr-ML", 7789),
  ("fr-MQ", 7793),
  ("fr-MR", 7793),
  ("fr-MU", 7797),
  ("fr-NC", 7797),
  ("fr-NE", 7797),
  ("fr-PF", 7797),
  ("fr-PM", 7797),
  ("fr-RE", 7797),
  ("fr-RW", 7797),
  ("fr-SC", 7799),
  ("fr-SN", 7799),
  ("fr-SY", 7799),
  ("fr-TD", 7803),
  ("fr-TG", 7807),
  ("fr-TN", 7807),
  ("fr-VU", 7811),
  ("fr-WF", 7815),
  ("fr-YT", 7815),
  ("fur", 7815),
  ("fy", 7909),
  ("ga", 8008),
  ("ga-GB", 8111),
  ("gaa", 8111),
  ("gd", 8179),
  ("gl", 8282),
  ("gsw", 8388),
  ("gsw-FR", 8480),
  ("gsw-LI", 8480),
  ("gu", 8480),
  ("guz", 8575),
  ("gv", 8666),
  ("ha", 8734),
  ("ha-GH", 8827),
  ("ha-NE", 8831),
  ("haw", 8831),
  ("he", 8920),
  ("hi", 9023),
  ("hi-Latn", 9129),
  ("hr", 9150),
  ("hr-BA", 9257),
  ("hsb", 9262),
  ("hu", 9375),
  ("hy", 9488),
  ("ia", 9591),
  ("id", 9693),
  ("ie", 9802),
  ("ig", 9906),
  ("ii", 9999),
  ("is", 10086),
  ("it", 10191),
  ("it-CH", 10294),
  ("it-SM", 10300),
  ("it-VA", 10300),
  ("ja", 10300),
  ("jgo", 10410),
  ("jmc", 10481),
  ("jv", 10572),
  ("ka", 10673),
  ("kab", 10774),
  ("kam", 10875),
  ("kbd", 10966),
  ("kbd-TR", 11032),
  ("kde", 11044),
  ("kea", 11135),
  ("kek", 11240),
  ("kgp", 11338),
  ("khq", 11437),
  ("ki", 11533),
  ("kk", 11627),
  ("kk-Arab", 11729),
  ("kk-Cyrl", 11825),
  ("kk-KZ", 11825),
  ("kkj", 11825),
  ("kl", 11904),
  ("kln", 11975),
  ("km", 12066),
  ("kn", 12169),
  ("ko", 12266),
  ("ko-CN", 12377),
  ("ko-KP", 12381),
  ("kok", 12381),
  ("kok-Deva", 12475),
  ("kok-Latn", 12475),
  ("ks", 12580),
  ("ks-Arab", 12679),
  ("ks-Deva", 12679),
  ("ksb", 12760),
  ("ksf", 12851),
  ("ksh", 12949),
  ("ku", 13049),
  ("ku-Latn", 13152),
  ("ku-Latn-IQ", 13152),
  ("ku-Latn-SY", 13152),
  ("ku-TR", 13152),
  ("kw", 13152),
  ("kxv", 13220),
  ("kxv-Deva", 13321),
  ("kxv-Latn", 13425),
  ("kxv-Orya", 13425),
  ("kxv-Telu", 13529),
  ("ky", 13633),
  ("lag", 13734),
  ("lb", 13823),
  ("lg", 13924),
  ("lij", 14013),
  ("lkt", 14111),
  ("lld", 14181),
  ("lmo", 14281),
  ("ln", 14345),
  ("ln-AO", 14443),
  ("ln-CF", 14443),
  ("ln-CG", 14443),
  ("lo", 14443),
  ("lrc", 14550),
  ("lrc-IQ", 14598),
  ("lt", 14602),
  ("lu", 14703),
  ("luo", 14801),
  ("luy", 14892),
  ("lv", 14979),
  ("mai", 15084),
  ("mas", 15187),
  ("mas-TZ", 15278),
  ("mer", 15278),
  ("mfe", 15369),
  ("mg", 15461),
  ("mgh", 15554),
  ("mgo", 15641),
  ("mi", 15704),
  ("mk", 15803),
  ("ml", 15911),
  ("mn", 15997),
  ("mni", 16100),
  ("mni-Beng", 16192),
  ("mr", 16192),
  ("ms", 16296),
  ("ms-BN", 16402),
  ("ms-ID", 16406),
  ("ms-SG", 16419),
  ("mt", 16419),
  ("mua", 16513),
  ("my", 16611),
  ("mzn", 16701),
  ("naq", 16751),
  ("nb", 16845),
  ("nb-SJ", 16845),
  ("nd", 16845),
  ("nds", 16934),
  ("nds-NL", 17007),
  ("ne", 17007),
  ("ne-IN", 17086),
  ("nl", 17090),
  ("nl-AW", 17193),
  ("nl-BE", 17193),
  ("nl-BQ", 17199),
  ("nl-CW", 17199),
  ("nl-SR", 17199),
  ("nl-SX", 17199),
  ("nmg", 17199),
  ("nn", 17297),
  ("nnh", 17309),
  ("no", 17386),
  ("nqo", 17494),
  ("nso", 17571),
  ("nus", 17649),
  ("nyn", 17749),
  ("oc", 17838),
  ("oc-ES", 17911),
  ("om", 17911),
  ("om-KE", 18012),
  ("or", 18017),
  ("os", 18114),
  ("os-RU", 18205),
  ("pa", 18205),
  ("pa-Arab", 18305),
  ("pa-Guru", 18388),
  ("pcm", 18388),
  ("pl", 18487),
  ("pms", 18590),
  ("prg", 18660),
  ("ps", 18730),
  ("ps-PK", 18824),
  ("pt", 18828),
  ("pt-AO", 18928),
  ("pt-CH", 18928),
  ("pt-CV", 18928),
  ("pt-GQ", 18928),
  ("pt-GW", 18928),
  ("pt-LU", 18928),
  ("pt-MO", 18928),
  ("pt-MZ", 18932),
  ("pt-PT", 18932),
  ("pt-ST", 18957),
  ("pt-TL", 18957),
  ("qu", 18957),
  ("qu-BO", 19050),
  ("qu-EC", 19052),
  ("quc", 19052),
  ("raj", 19127),
  ("rm", 19193),
  ("rn", 19292),
  ("ro", 19391),
  ("ro-MD", 19497),
  ("rof", 19512),
  ("ru", 19597),
  ("ru-BY", 19702),
  ("ru-KG", 19702),
  ("ru-KZ", 19702),
  ("ru-MD", 19702),
  ("ru-UA", 19702),
  ("rw", 19703),
  ("rwk", 19793),
  ("sa", 19884),
  ("sah", 19984),
  ("saq", 20069),
  ("sat", 20160),
  ("sat-Olck", 20240),
  ("sbp", 20240),
  ("sc", 20335),
  ("scn", 20436),
  ("sd", 20536),
  ("sd-Arab", 20617),
  ("sd-Deva", 20617),
  ("se", 20716),
  ("se-FI", 20789),
  ("se-SE", 20837),
  ("seh", 20837),
  ("ses", 20921),
  ("sg", 21017),
  ("shi", 21113),
  ("shi-Latn", 21209),
  ("shi-Tfng", 21305),
  ("shn", 21305),
  ("shn-TH", 21386),
  ("si", 21386),
  ("sk", 21472),
  ("sl", 21581),
  ("smn", 21688),
  ("sn", 21800),
  ("so", 21876),
  ("so-DJ", 21977),
  ("so-ET", 21977),
  ("so-KE", 21977),
  ("sq", 21981),
  ("sq-MK", 22090),
  ("sq-XK", 22094),
  ("sr", 22098),
  ("sr-Cyrl", 22202),
  ("sr-Cyrl-BA", 22202),
  ("sr-Cyrl-ME", 22208),
  ("sr-Cyrl-XK", 22216),
  ("sr-Latn", 22220),
  ("sr-Latn-BA", 22324),
  ("sr-Latn-ME", 22330),
  ("sr-Latn-XK", 22338),
  ("st", 22342),
  ("st-LS", 22408),
  ("su", 22412),
  ("su-Latn", 22522),
  ("suz-Sunu", 22522),
  ("sv", 22584),
  ("sv-AX", 22686),
  ("sv-FI", 22689),
  ("sw", 22708),
  ("sw-CD", 22806),
  ("sw-KE", 22808),
  ("sw-UG", 22809),
  ("syr", 22809),
  ("syr-SY", 22912),
  ("szl", 22912),
  ("ta", 22982),
  ("ta-LK", 23079),
  ("ta-MY", 23083),
  ("ta-SG", 23084),
  ("te", 23085),
  ("teo", 23184),
  ("teo-KE", 23275),
  ("tg", 23275),
  ("th", 23376),
  ("ti", 23477),
  ("ti-ER", 23581),
  ("tk", 23581),
  ("tn", 23683),
  ("tn-BW", 23756),
  ("to", 23756),
  ("tok", 23862),
  ("tr", 23945),
  ("tr-CY", 24048),
  ("tt", 24052),
  ("twq", 24158),
  ("tyv", 24255),
  ("tzm", 24341),
  ("ug", 24434),
  ("uk", 24528),
  ("und", 24634),
  ("ur", 24754),
  ("ur-IN", 24857),
  ("uz", 24857),
  ("uz-Arab", 24963),
  ("uz-Cyrl", 25027),
  ("uz-Latn", 25131),
  ("vai", 25131),
  ("vai-Latn", 25213),
  ("vai-Vaii", 25252),
  ("vec", 25252),
  ("vi", 25353),
  ("vmw", 25456),
  ("vun", 25524),
  ("wae", 25615),
  ("wo", 25697),
  ("xh", 25800),
  ("xnr", 25890),
  ("xog", 25996),
  ("yav", 26083),
  ("yi", 26177),
  ("yo", 26255),
  ("yo-BJ", 26358),
  ("yrl", 26428),
  ("yrl-CO", 26527),
  ("yrl-VE", 26533),
  ("yue", 26539),
  ("yue-Hans", 26650),
  ("yue-Hant", 26759),
  ("yue-Hant-CN", 26759),
  ("yue-Hant-MO", 26765),
  ("za", 26765),
  ("zgh", 26831),
  ("zh", 26926),
  ("zh-Hans", 27035),
  ("zh-Hans-HK", 27035),
  ("zh-Hans-MO", 27045),
  ("zh-Hans-MY", 27054),
  ("zh-Hans-SG", 27058),
  ("zh-Hant", 27068),
  ("zh-Hant-HK", 27179),
  ("zh-Hant-MO", 27200),
  ("zh-Hant-MY", 27200),
  ("zu", 27204),
]

const localeCellField*: array[27287, uint8] = [
  0, 1, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 
  28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 
  52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 89, 92, 93, 60, 67, 0, 1, 4, 
  5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 
  29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 
  53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 
  77, 78, 79, 80, 81, 82, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 
  112, 116, 117, 84, 85, 86, 87, 0, 1, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 
  19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 
  43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 
  67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 89, 90, 91, 93, 94, 98, 99, 
  100, 101, 102, 105, 106, 112, 116, 117, 119, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 
  19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 
  43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 
  68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 
  92, 93, 94, 98, 99, 100, 102, 105, 106, 117, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 
  18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 
  42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 
  66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 89, 90, 
  91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 102, 104, 107, 112, 115, 116, 117, 118, 2, 4, 5, 6, 7, 8, 
  9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 
  33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 
  57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 
  81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 
  105, 106, 107, 112, 0, 1, 6, 7, 9, 10, 11, 12, 13, 18, 19, 21, 22, 23, 24, 25, 30, 31, 33, 34, 
  35, 36, 37, 42, 43, 45, 46, 47, 48, 49, 84, 85, 86, 87, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 
  16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 
  40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 
  16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 
  40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 84, 85, 86, 87, 0, 1, 6, 7, 8, 9, 
  10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 
  34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 0, 1, 0, 1, 
  10, 12, 13, 14, 16, 17, 22, 24, 25, 26, 28, 29, 34, 36, 37, 38, 40, 41, 46, 48, 49, 50, 52, 53, 
  84, 85, 86, 87, 0, 1, 9, 13, 14, 17, 21, 25, 26, 29, 33, 37, 38, 41, 45, 49, 50, 53, 6, 7, 
  8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 
  32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 2, 2, 
  6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 
  30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 
  0, 1, 6, 7, 9, 10, 11, 12, 13, 18, 19, 21, 22, 23, 24, 25, 30, 31, 33, 34, 35, 36, 37, 42, 
  43, 45, 46, 47, 48, 49, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 
  21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 
  45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 
  69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 81, 83, 84, 85, 86, 87, 89, 90, 91, 92, 93, 98, 99, 
  103, 105, 106, 112, 116, 117, 118, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 
  21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 
  45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 
  69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 89, 90, 91, 92, 93, 94, 98, 99, 100, 
  102, 105, 106, 117, 0, 1, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 
  22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 
  46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 
  70, 71, 72, 73, 74, 75, 78, 79, 80, 81, 82, 83, 88, 89, 90, 91, 92, 93, 94, 96, 97, 98, 99, 100, 
  101, 102, 103, 104, 105, 106, 107, 112, 116, 117, 0, 1, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 
  16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 
  40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 
  64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 78, 79, 80, 81, 82, 83, 89, 90, 91, 92, 93, 94, 
  95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 112, 116, 117, 0, 1, 4, 5, 6, 7, 8, 9, 10, 11, 12, 
  13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 
  37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 
  61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 89, 
  90, 91, 93, 94, 96, 97, 98, 99, 100, 101, 102, 104, 112, 0, 1, 4, 5, 6, 7, 8, 9, 10, 11, 12, 
  13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 
  37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 
  61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 78, 79, 80, 81, 82, 83, 88, 89, 90, 
  91, 92, 93, 94, 95, 96, 97, 99, 100, 101, 102, 103, 104, 105, 106, 107, 115, 116, 117, 6, 7, 8, 9, 10, 
  11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 
  35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 
  59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 
  83, 84, 85, 86, 87, 89, 93, 116, 117, 0, 1, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 
  16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 
  40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 
  64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 89, 90, 91, 93, 
  94, 98, 99, 100, 101, 102, 105, 106, 112, 116, 117, 119, 0, 1, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 
  13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 
  37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 
  61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 78, 79, 80, 81, 82, 83, 84, 88, 89, 
  90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 115, 116, 117, 118, 119, 4, 
  5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 
  29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 
  53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 76, 77, 78, 79, 80, 81, 82, 83, 84, 
  85, 86, 87, 89, 90, 91, 92, 93, 94, 98, 99, 100, 102, 105, 106, 117, 4, 5, 6, 7, 8, 9, 10, 11, 
  12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 
  36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 
  60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 
  89, 90, 91, 92, 93, 94, 98, 99, 100, 102, 105, 106, 117, 0, 1, 4, 5, 6, 7, 8, 9, 10, 11, 12, 
  13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 
  37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 
  61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 
  85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 
  110, 112, 113, 114, 115, 116, 117, 118, 119, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 
  21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 
  45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 84, 
  85, 86, 87, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 
  25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 
  49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 84, 85, 86, 87, 0, 
  1, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 
  26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 
  50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 
  74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 102, 
  104, 105, 106, 107, 112, 116, 117, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 
  21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 
  45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 
  69, 70, 71, 72, 73, 74, 75, 78, 79, 80, 81, 82, 83, 89, 90, 91, 92, 93, 94, 98, 99, 101, 102, 103, 
  105, 106, 109, 110, 119, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 
  22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 
  46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 
  70, 71, 72, 73, 74, 75, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 89, 90, 91, 92, 93, 94, 95, 96, 
  97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 112, 4, 5, 26, 27, 28, 29, 50, 51, 52, 53, 78, 79, 
  6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 
  30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 
  54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 
  78, 79, 80, 81, 82, 91, 93, 101, 102, 103, 104, 84, 85, 86, 87, 0, 1, 3, 4, 5, 6, 7, 8, 9, 
  10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 
  34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 
  58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 
  82, 83, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 109, 112, 
  116, 117, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 
  25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 
  49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 
  73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 97, 
  98, 99, 100, 101, 102, 105, 106, 107, 118, 0, 1, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 
  17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 
  41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 
  65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 89, 90, 91, 92, 93, 
  94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 111, 112, 0, 1, 4, 5, 6, 7, 8, 
  9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 
  33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 
  57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 
  81, 82, 83, 89, 90, 91, 92, 93, 94, 96, 97, 98, 99, 100, 101, 102, 103, 104, 107, 108, 112, 0, 1, 3, 
  4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 
  28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 
  52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 89, 92, 93, 94, 96, 97, 101, 102, 
  103, 0, 1, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 
  24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 
  48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 
  72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 
  96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 112, 113, 114, 115, 116, 117, 3, 4, 5, 6, 7, 8, 
  9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 
  33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 
  57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 78, 79, 80, 81, 82, 83, 84, 85, 86, 
  87, 89, 90, 91, 92, 93, 94, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 112, 3, 4, 5, 6, 
  7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 
  31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 
  55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 78, 79, 4, 
  5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 
  29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 
  53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 78, 79, 80, 81, 82, 
  83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 102, 104, 105, 106, 107, 112, 
  116, 117, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 
  26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 
  50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 
  74, 75, 78, 79, 80, 81, 82, 83, 89, 90, 91, 92, 93, 94, 98, 99, 100, 102, 105, 106, 117, 4, 5, 6, 
  7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 
  31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 
  55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 76, 77, 78, 79, 80, 81, 82, 
  83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 102, 104, 105, 106, 107, 112, 
  6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 
  30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 
  54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 
  78, 79, 81, 84, 85, 86, 87, 89, 90, 91, 93, 94, 98, 100, 101, 102, 112, 118, 84, 85, 86, 87, 4, 5, 
  6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 
  30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 
  54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 
  78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 95, 0, 1, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 
  13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 
  37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 
  61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 89, 
  90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 111, 112, 113, 114, 115, 116, 
  117, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 
  29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 
  53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 76, 77, 84, 85, 86, 87, 0, 1, 3, 
  4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 
  28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 
  52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 
  76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 
  102, 103, 104, 105, 106, 112, 115, 116, 117, 118, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 
  18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 
  42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 
  66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 78, 79, 80, 81, 82, 83, 89, 90, 91, 92, 93, 94, 95, 96, 
  97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 116, 117, 0, 1, 3, 4, 5, 6, 7, 8, 9, 10, 11, 
  12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 
  36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 
  60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 78, 79, 80, 81, 82, 83, 84, 85, 
  86, 87, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 109, 110, 111, 
  112, 113, 114, 116, 117, 119, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 
  22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 
  46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 
  70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 89, 90, 91, 92, 93, 94, 98, 99, 100, 102, 
  105, 106, 117, 0, 1, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 
  22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 
  46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 
  70, 71, 78, 79, 80, 81, 82, 83, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 
  104, 105, 106, 107, 112, 115, 116, 117, 1, 4, 5, 6, 18, 26, 30, 42, 0, 1, 3, 4, 5, 95, 6, 18, 
  26, 30, 42, 0, 1, 3, 4, 5, 1, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 
  19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 
  43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 
  67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 89, 90, 91, 93, 94, 98, 99, 
  100, 101, 102, 105, 106, 112, 116, 117, 119, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 
  19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 
  43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 
  67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 
  91, 92, 93, 94, 96, 97, 98, 99, 100, 101, 102, 103, 105, 106, 112, 0, 1, 3, 4, 5, 6, 7, 8, 9, 
  10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 
  34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 
  58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 
  82, 83, 84, 85, 86, 87, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 
  107, 111, 112, 113, 114, 115, 116, 117, 0, 1, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 
  17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 
  41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 
  65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 89, 90, 91, 93, 94, 
  98, 99, 100, 101, 102, 105, 106, 112, 116, 117, 119, 0, 1, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 
  15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 
  39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 
  63, 64, 65, 66, 67, 78, 79, 80, 81, 82, 83, 89, 90, 91, 93, 94, 98, 99, 100, 101, 102, 105, 106, 112, 
  116, 117, 119, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 
  24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 
  48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 
  72, 73, 74, 75, 76, 77, 80, 81, 82, 84, 85, 86, 87, 89, 90, 91, 94, 97, 98, 99, 100, 101, 102, 104, 
  110, 112, 115, 118, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 
  24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 
  48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 
  72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 89, 90, 91, 92, 93, 94, 98, 99, 100, 102, 105, 106, 
  117, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 
  27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 
  51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 
  75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 96, 97, 98, 99, 
  100, 101, 102, 103, 104, 105, 106, 107, 112, 116, 117, 118, 119, 84, 85, 86, 87, 0, 1, 4, 5, 6, 7, 8, 
  9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 
  33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 
  57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 
  81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 
  105, 106, 107, 110, 112, 116, 117, 13, 15, 25, 27, 37, 39, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 
  15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 
  39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 68, 69, 
  70, 71, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 
  100, 102, 104, 105, 106, 107, 112, 116, 117, 26, 50, 76, 77, 80, 81, 82, 83, 89, 90, 93, 94, 95, 96, 97, 
  98, 99, 100, 101, 102, 103, 112, 4, 5, 84, 85, 86, 87, 80, 81, 82, 83, 89, 90, 93, 94, 96, 97, 98, 
  99, 100, 101, 102, 103, 112, 84, 85, 86, 87, 0, 1, 3, 4, 5, 83, 90, 94, 99, 100, 102, 0, 1, 82, 
  83, 89, 90, 99, 100, 84, 85, 86, 87, 80, 81, 82, 83, 84, 85, 86, 87, 93, 94, 96, 97, 101, 102, 80, 
  81, 82, 83, 84, 85, 86, 87, 93, 94, 101, 102, 76, 77, 83, 89, 90, 98, 99, 100, 112, 84, 85, 86, 87, 
  1, 4, 5, 83, 89, 90, 95, 98, 99, 100, 84, 85, 86, 87, 84, 85, 86, 87, 84, 85, 86, 87, 0, 1, 
  0, 1, 3, 84, 85, 86, 87, 0, 1, 3, 84, 85, 86, 87, 113, 114, 116, 117, 119, 0, 1, 0, 1, 0, 
  1, 3, 84, 85, 86, 87, 113, 114, 116, 117, 119, 84, 85, 86, 87, 0, 1, 84, 85, 86, 87, 100, 102, 0, 
  1, 84, 85, 86, 87, 84, 85, 86, 87, 84, 85, 86, 87, 83, 89, 0, 1, 0, 1, 84, 85, 86, 87, 113, 
  114, 116, 117, 119, 80, 84, 85, 86, 87, 89, 90, 94, 99, 100, 84, 85, 86, 87, 113, 114, 115, 84, 85, 86, 
  87, 3, 4, 76, 77, 83, 89, 90, 99, 100, 84, 85, 86, 87, 0, 1, 84, 85, 86, 87, 83, 84, 85, 86, 
  87, 89, 90, 95, 98, 113, 114, 115, 84, 85, 86, 87, 0, 1, 0, 1, 84, 85, 86, 87, 84, 85, 86, 87, 
  81, 82, 84, 85, 86, 87, 93, 94, 101, 84, 85, 86, 87, 4, 5, 80, 82, 83, 84, 85, 86, 87, 88, 84, 
  85, 86, 87, 84, 85, 86, 87, 0, 1, 4, 5, 0, 1, 3, 84, 85, 86, 87, 84, 85, 86, 87, 89, 99, 
  82, 0, 1, 5, 84, 85, 86, 87, 0, 1, 5, 0, 1, 5, 84, 85, 86, 87, 84, 85, 86, 87, 0, 1, 
  3, 83, 89, 90, 98, 83, 84, 85, 86, 87, 0, 1, 5, 0, 1, 5, 84, 85, 86, 87, 84, 85, 86, 87, 
  84, 85, 86, 87, 84, 85, 86, 87, 0, 1, 84, 85, 86, 87, 0, 1, 80, 81, 82, 83, 84, 85, 86, 87, 
  89, 90, 93, 94, 99, 100, 101, 102, 84, 85, 86, 87, 80, 81, 82, 83, 84, 85, 86, 87, 89, 90, 93, 94, 
  99, 100, 101, 102, 0, 1, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 
  22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 
  46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 
  70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 88, 90, 91, 92, 93, 94, 95, 96, 97, 100, 101, 
  102, 103, 104, 105, 106, 107, 110, 115, 116, 117, 0, 1, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 
  15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 
  39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 
  63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 
  87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 112, 113, 114, 
  115, 116, 117, 0, 1, 3, 4, 5, 26, 50, 68, 70, 76, 77, 78, 79, 84, 85, 86, 87, 90, 96, 105, 113, 
  114, 115, 0, 1, 4, 5, 68, 70, 76, 77, 84, 85, 86, 87, 90, 93, 96, 97, 98, 100, 116, 0, 1, 76, 
  77, 82, 84, 85, 86, 87, 84, 85, 86, 87, 0, 1, 4, 5, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 
  52, 53, 76, 77, 82, 83, 84, 85, 86, 87, 89, 90, 96, 98, 99, 100, 0, 1, 4, 5, 42, 43, 44, 45, 
  46, 47, 48, 49, 50, 51, 52, 53, 76, 77, 82, 83, 90, 91, 93, 97, 101, 102, 104, 113, 114, 115, 0, 1, 
  76, 77, 5, 72, 73, 74, 75, 76, 77, 93, 0, 1, 4, 5, 76, 77, 4, 5, 76, 77, 82, 83, 76, 77, 
  80, 81, 83, 90, 94, 96, 102, 105, 76, 77, 68, 69, 70, 76, 77, 82, 83, 89, 90, 98, 99, 100, 4, 5, 
  14, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 
  41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 76, 77, 83, 84, 85, 86, 87, 76, 77, 82, 83, 
  89, 90, 98, 99, 100, 0, 1, 4, 5, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 76, 77, 84, 
  85, 86, 87, 76, 77, 68, 70, 83, 90, 94, 96, 102, 105, 0, 1, 4, 5, 14, 18, 19, 20, 21, 22, 23, 
  24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 
  48, 49, 50, 51, 52, 53, 76, 77, 84, 85, 86, 87, 0, 1, 4, 5, 18, 19, 20, 21, 22, 23, 24, 25, 
  26, 27, 28, 29, 68, 69, 70, 71, 76, 77, 0, 1, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 
  16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 
  40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 
  64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 78, 79, 80, 81, 82, 83, 89, 90, 91, 92, 93, 94, 
  95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 109, 110, 112, 116, 117, 0, 1, 3, 4, 5, 6, 
  7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 
  31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 
  55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 78, 79, 80, 
  81, 82, 83, 84, 85, 88, 89, 90, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 116, 
  117, 0, 1, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 
  25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 
  49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 
  73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 89, 90, 91, 93, 94, 98, 99, 100, 101, 102, 105, 106, 112, 
  116, 117, 119, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 
  25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 
  49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 
  73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 
  97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 112, 113, 114, 115, 119, 4, 5, 6, 7, 8, 9, 10, 11, 
  12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 
  36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 68, 69, 70, 71, 72, 73, 
  74, 75, 89, 90, 93, 94, 96, 97, 98, 100, 101, 102, 103, 105, 112, 113, 114, 115, 0, 1, 4, 5, 6, 7, 
  8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 
  32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 
  56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 
  80, 81, 82, 83, 90, 91, 92, 93, 94, 98, 99, 101, 102, 103, 105, 106, 109, 110, 119, 1, 6, 7, 8, 9, 
  10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 
  34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 
  58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 
  82, 83, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 112, 84, 85, 
  86, 87, 84, 85, 86, 87, 84, 85, 86, 87, 84, 85, 86, 87, 84, 85, 86, 87, 84, 85, 86, 87, 84, 85, 
  86, 87, 84, 85, 86, 87, 84, 85, 86, 87, 84, 85, 86, 87, 0, 1, 3, 4, 5, 6, 7, 8, 9, 10, 
  11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 
  35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 
  59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 
  83, 84, 85, 86, 87, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 
  112, 113, 114, 115, 116, 117, 119, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 
  21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 
  45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 
  69, 70, 71, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 
  99, 100, 102, 104, 105, 106, 107, 112, 116, 117, 0, 1, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 
  15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 
  39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 
  63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 78, 79, 80, 81, 82, 83, 88, 89, 90, 91, 92, 
  93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 109, 111, 112, 116, 117, 0, 1, 3, 4, 
  5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 
  29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 
  53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 78, 
  79, 80, 81, 82, 83, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 
  107, 112, 116, 117, 83, 84, 1, 24, 48, 76, 77, 83, 84, 85, 86, 87, 89, 90, 95, 98, 99, 100, 113, 114, 
  116, 117, 118, 119, 1, 3, 80, 83, 84, 89, 90, 98, 99, 100, 76, 77, 116, 117, 118, 84, 85, 86, 87, 84, 
  85, 86, 87, 1, 1, 18, 19, 20, 23, 42, 43, 44, 47, 68, 69, 70, 71, 84, 85, 86, 87, 0, 1, 84, 
  85, 86, 87, 84, 85, 86, 87, 84, 85, 86, 87, 84, 85, 86, 87, 0, 1, 6, 7, 8, 9, 10, 11, 12, 
  13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 
  37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 
  61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 90, 
  91, 92, 94, 98, 99, 100, 101, 102, 103, 105, 106, 112, 114, 0, 1, 4, 5, 6, 7, 8, 9, 10, 11, 12, 
  13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 
  37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 
  61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 78, 79, 80, 81, 82, 83, 89, 90, 91, 
  92, 93, 94, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 116, 117, 4, 5, 6, 7, 8, 9, 10, 11, 
  12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 
  36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 
  60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 
  89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 109, 112, 116, 117, 6, 
  7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 
  31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 
  55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 84, 85, 86, 87, 89, 93, 4, 5, 6, 7, 8, 
  9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 
  33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 
  57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 
  81, 82, 83, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 112, 116, 
  117, 118, 0, 1, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 
  23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 
  47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 
  71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 
  99, 100, 101, 102, 103, 104, 105, 106, 107, 112, 116, 117, 1, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 
  14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 
  38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 
  62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 76, 77, 78, 79, 80, 81, 82, 83, 90, 91, 92, 94, 98, 99, 
  100, 101, 102, 103, 105, 106, 112, 115, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 
  19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 
  43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 
  67, 68, 69, 70, 71, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 89, 90, 91, 92, 93, 94, 96, 97, 98, 
  99, 100, 101, 102, 103, 104, 112, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 
  21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 
  45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 
  69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 90, 91, 92, 94, 98, 99, 100, 102, 105, 
  106, 117, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 
  26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 
  50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 76, 77, 78, 79, 6, 7, 
  8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 
  32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 
  56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 
  80, 81, 82, 83, 88, 90, 91, 92, 93, 95, 98, 99, 100, 102, 105, 106, 112, 116, 117, 84, 85, 86, 87, 4, 
  5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 
  29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 
  53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 80, 81, 82, 83, 84, 85, 86, 87, 89, 
  90, 91, 93, 94, 96, 97, 98, 99, 100, 101, 102, 104, 107, 112, 116, 117, 4, 5, 6, 7, 8, 9, 10, 11, 
  12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 
  36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 
  60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 
  90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 112, 113, 114, 115, 118, 3, 
  4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 
  28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 
  52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 
  76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 
  100, 101, 102, 103, 104, 105, 106, 107, 112, 5, 26, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 
  67, 81, 82, 83, 88, 93, 0, 1, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 
  19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 
  43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 
  67, 68, 69, 70, 71, 72, 73, 74, 75, 78, 79, 80, 81, 82, 83, 84, 89, 90, 91, 92, 93, 94, 95, 96, 
  97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 111, 112, 116, 117, 72, 73, 74, 75, 83, 0, 1, 
  3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 
  27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 
  51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 
  75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 
  100, 101, 102, 103, 104, 105, 106, 107, 111, 112, 113, 114, 115, 116, 117, 0, 1, 4, 5, 6, 7, 8, 9, 10, 
  11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 
  35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 
  59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 
  83, 84, 85, 86, 87, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 
  108, 112, 113, 114, 115, 116, 117, 118, 0, 1, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 
  18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 
  42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 
  66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 78, 79, 80, 81, 82, 83, 88, 89, 90, 91, 92, 93, 94, 95, 
  96, 97, 98, 99, 100, 101, 104, 105, 106, 107, 108, 112, 113, 114, 115, 0, 1, 5, 6, 7, 8, 9, 10, 11, 
  12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 
  36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 
  60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 78, 79, 80, 81, 82, 83, 88, 89, 
  90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 112, 116, 117, 0, 1, 4, 
  5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 
  29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 
  53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 78, 
  79, 80, 81, 82, 83, 84, 85, 86, 87, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 
  104, 105, 106, 107, 112, 113, 114, 116, 117, 119, 0, 1, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 
  16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 
  40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 
  64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 89, 90, 91, 92, 
  93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 111, 112, 115, 4, 5, 6, 7, 8, 9, 
  10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 
  34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 
  58, 59, 60, 61, 62, 63, 64, 65, 66, 68, 69, 70, 71, 76, 77, 78, 79, 80, 81, 82, 83, 88, 89, 90, 
  91, 92, 93, 94, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 6, 7, 8, 9, 10, 11, 12, 13, 14, 
  15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 
  39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 
  63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 93, 94, 96, 97, 99, 100, 101, 
  102, 103, 111, 112, 116, 117, 0, 1, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 
  20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 
  44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 
  68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 88, 89, 90, 91, 92, 93, 94, 95, 
  96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 112, 116, 117, 0, 1, 4, 5, 6, 7, 8, 9, 10, 
  11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 
  35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 
  59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 78, 79, 80, 81, 82, 83, 88, 
  89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 112, 116, 117, 0, 1, 
  4, 5, 80, 83, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 
  24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 
  48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 
  76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 
  101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 0, 1, 6, 7, 8, 9, 
  10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 
  34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 
  58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 76, 77, 80, 89, 99, 100, 112, 4, 5, 6, 7, 8, 9, 10, 
  11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 
  35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 
  59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 
  83, 90, 91, 92, 94, 98, 99, 100, 102, 105, 106, 117, 0, 1, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 
  16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 
  40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 
  64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 78, 79, 80, 81, 82, 83, 88, 89, 90, 91, 92, 93, 
  94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 112, 116, 117, 0, 1, 4, 5, 6, 7, 8, 
  9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 
  33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 
  57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 78, 79, 80, 81, 82, 
  83, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 112, 0, 1, 
  4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 
  28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 
  52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 
  76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 90, 91, 92, 93, 94, 98, 99, 101, 102, 103, 105, 106, 
  109, 110, 119, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 
  25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 
  49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 
  73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 90, 91, 92, 94, 98, 99, 100, 102, 105, 106, 117, 0, 1, 
  6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 
  30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 
  54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 89, 93, 30, 31, 32, 33, 34, 35, 36, 37, 
  38, 39, 40, 41, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 
  24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 
  48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 
  72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 90, 91, 92, 94, 98, 99, 100, 102, 105, 106, 117, 0, 
  1, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 
  27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 
  51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 
  75, 76, 77, 78, 79, 80, 81, 82, 83, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 
  103, 104, 105, 106, 107, 112, 116, 117, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 
  22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 
  46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 
  70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 
  99, 100, 101, 102, 103, 104, 105, 106, 107, 112, 0, 1, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 
  18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 
  42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 
  66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 78, 79, 80, 81, 82, 83, 89, 90, 91, 92, 93, 94, 96, 97, 
  98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 112, 116, 117, 1, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 
  14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 
  38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 
  62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 90, 91, 
  92, 93, 94, 98, 99, 101, 102, 103, 105, 106, 109, 110, 119, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 
  15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 
  39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 
  63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 89, 90, 91, 
  92, 93, 94, 98, 99, 100, 102, 105, 106, 116, 117, 0, 1, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 
  15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 
  39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 
  63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 78, 79, 80, 81, 82, 83, 88, 89, 90, 91, 92, 
  93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 116, 117, 1, 4, 5, 6, 7, 8, 9, 
  10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 
  34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 
  58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 
  82, 83, 88, 89, 90, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 112, 0, 1, 6, 7, 8, 9, 10, 
  11, 12, 13, 14, 15, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 29, 30, 31, 32, 33, 34, 35, 36, 
  37, 38, 39, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 
  63, 64, 65, 66, 67, 80, 81, 82, 83, 89, 90, 91, 93, 94, 96, 97, 98, 99, 100, 101, 102, 104, 107, 112, 
  0, 1, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 
  25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 
  49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 84, 85, 86, 87, 4, 
  5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 
  29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 
  53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 
  77, 78, 79, 80, 81, 82, 83, 90, 91, 92, 94, 98, 99, 100, 102, 105, 106, 117, 4, 5, 6, 7, 8, 9, 
  10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 
  34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 
  58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 78, 79, 80, 81, 82, 83, 
  84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 
  112, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 
  27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 
  51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 
  75, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 89, 90, 91, 92, 93, 94, 98, 99, 100, 101, 102, 103, 105, 
  106, 112, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 
  26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 
  50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 
  74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 
  99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 111, 112, 115, 116, 117, 118, 84, 85, 86, 87, 4, 5, 6, 
  7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 
  31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 
  55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 78, 79, 80, 81, 82, 83, 84, 
  85, 86, 87, 89, 90, 91, 92, 93, 96, 97, 98, 99, 100, 101, 102, 103, 104, 116, 117, 4, 5, 6, 7, 8, 
  9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 
  33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 
  57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 78, 79, 80, 81, 82, 
  83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 
  115, 116, 117, 118, 1, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 
  23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 
  47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 64, 65, 66, 67, 68, 69, 70, 71, 
  72, 73, 74, 75, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 90, 91, 92, 94, 95, 96, 97, 98, 99, 
  100, 102, 104, 105, 106, 107, 112, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 
  23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 
  47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 
  71, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 93, 116, 117, 4, 5, 6, 7, 8, 9, 10, 11, 
  12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 
  36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 
  60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 
  90, 91, 92, 94, 98, 99, 100, 102, 105, 106, 117, 0, 1, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 
  15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 
  39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 
  63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 89, 90, 91, 
  93, 94, 98, 99, 100, 101, 102, 105, 106, 112, 116, 117, 119, 0, 1, 3, 4, 5, 6, 7, 8, 9, 10, 11, 
  12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 
  36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 
  60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 
  90, 91, 92, 93, 94, 98, 100, 101, 102, 103, 105, 106, 112, 113, 114, 116, 117, 0, 1, 3, 4, 5, 6, 7, 
  8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 
  32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 
  56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 
  80, 81, 82, 83, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 116, 117, 
  4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 
  28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 
  52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 76, 77, 78, 79, 4, 5, 6, 7, 
  8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 
  32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 
  56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 76, 77, 78, 79, 80, 81, 82, 83, 
  84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 
  112, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 
  27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 
  51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 
  75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 96, 97, 98, 99, 
  100, 101, 102, 103, 104, 105, 106, 107, 112, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 
  19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 
  43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 
  67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 
  91, 92, 93, 94, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 112, 4, 5, 6, 7, 8, 9, 10, 
  11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 
  35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 
  59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 
  83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 
  112, 0, 1, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 
  25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 
  49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 
  73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 89, 90, 91, 92, 93, 94, 96, 97, 99, 100, 101, 102, 103, 
  104, 105, 106, 107, 116, 117, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 
  24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 
  48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 
  72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 90, 91, 92, 94, 98, 99, 100, 102, 105, 106, 117, 0, 
  1, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 
  26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 
  50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 76, 77, 
  78, 79, 80, 81, 82, 83, 89, 90, 91, 92, 93, 94, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 
  112, 115, 116, 117, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 
  24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 
  48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 
  72, 73, 74, 75, 78, 79, 80, 81, 82, 83, 90, 91, 92, 94, 98, 99, 100, 102, 105, 106, 117, 0, 1, 4, 
  5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 
  29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 
  53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 78, 79, 80, 81, 82, 
  83, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 112, 116, 6, 
  7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 
  31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 
  55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 80, 81, 82, 83, 84, 85, 86, 87, 0, 1, 4, 
  5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 
  29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 
  53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 78, 
  79, 80, 81, 82, 83, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 
  112, 0, 1, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 
  27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 
  51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 0, 1, 4, 5, 6, 7, 8, 
  9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 
  33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 
  57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 
  81, 82, 83, 89, 90, 91, 93, 94, 98, 99, 100, 101, 102, 105, 106, 112, 116, 117, 119, 0, 1, 4, 5, 6, 
  7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 
  31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 
  55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 
  79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 
  103, 104, 105, 106, 112, 118, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 
  24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 
  48, 49, 50, 51, 52, 53, 84, 85, 86, 87, 0, 1, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 
  15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 
  39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 
  63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 91, 92, 93, 94, 
  95, 96, 97, 99, 101, 102, 103, 104, 107, 109, 110, 111, 116, 117, 118, 0, 1, 4, 5, 6, 7, 8, 9, 10, 
  11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 
  35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 
  59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 
  83, 89, 90, 91, 93, 94, 98, 99, 100, 101, 102, 105, 106, 112, 116, 117, 119, 4, 5, 6, 7, 8, 9, 10, 
  11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 
  35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 
  59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 
  83, 90, 91, 92, 94, 98, 99, 100, 102, 105, 106, 117, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 
  16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 
  40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 
  64, 65, 66, 67, 68, 69, 70, 71, 76, 77, 78, 79, 80, 81, 82, 83, 90, 91, 92, 94, 98, 99, 100, 102, 
  105, 106, 117, 0, 1, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 
  23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 
  47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 
  71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 
  100, 101, 102, 103, 104, 105, 106, 107, 108, 112, 116, 117, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 
  18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 
  42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 
  66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 
  90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 112, 4, 5, 6, 7, 8, 
  9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 
  33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 
  57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 
  81, 82, 83, 90, 91, 92, 94, 98, 99, 100, 102, 105, 106, 117, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 
  14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 
  38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 
  62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 90, 91, 
  92, 94, 98, 99, 100, 102, 105, 106, 117, 1, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 
  20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 
  44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 
  68, 69, 70, 71, 72, 73, 74, 75, 78, 79, 80, 81, 82, 83, 90, 91, 92, 93, 94, 98, 99, 101, 102, 103, 
  105, 106, 109, 110, 119, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 
  24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 
  48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 
  72, 73, 74, 75, 78, 79, 80, 81, 90, 91, 92, 93, 94, 98, 99, 100, 101, 102, 103, 105, 106, 109, 110, 116, 
  117, 119, 0, 1, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 
  26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 
  50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 76, 77, 78, 79, 80, 81, 
  82, 83, 89, 90, 91, 93, 94, 98, 99, 100, 102, 105, 106, 112, 116, 117, 119, 6, 7, 8, 9, 10, 11, 12, 
  13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 
  37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 
  61, 62, 63, 64, 65, 66, 67, 80, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 
  22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 
  46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 
  70, 71, 72, 73, 74, 75, 80, 81, 82, 83, 84, 85, 86, 87, 89, 90, 91, 92, 93, 94, 96, 97, 98, 99, 
  100, 101, 102, 103, 104, 105, 106, 107, 112, 116, 117, 0, 1, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 
  14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 
  38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 
  62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 88, 89, 
  90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 112, 115, 116, 117, 4, 
  5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 
  29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 
  53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 78, 
  79, 83, 84, 85, 86, 87, 88, 89, 90, 95, 98, 99, 100, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 
  17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 
  41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 
  65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 89, 90, 91, 
  92, 93, 94, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 109, 112, 115, 116, 117, 118, 6, 7, 8, 9, 
  10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 
  34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 
  58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 78, 79, 80, 81, 82, 
  83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 98, 99, 100, 4, 5, 6, 7, 8, 9, 10, 11, 
  12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 
  36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 
  60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 78, 79, 80, 81, 82, 83, 84, 85, 
  86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 112, 113, 114, 
  4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 
  28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 
  52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 
  76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 96, 97, 98, 99, 100, 
  101, 102, 103, 104, 105, 106, 107, 112, 116, 117, 0, 1, 4, 80, 0, 1, 5, 80, 83, 84, 85, 86, 87, 113, 
  114, 116, 117, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 
  25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 
  49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 
  73, 74, 75, 78, 79, 80, 81, 82, 83, 89, 90, 91, 92, 93, 94, 96, 97, 100, 102, 103, 104, 105, 106, 116, 
  117, 0, 1, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 
  25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 
  49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 
  73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 89, 90, 91, 93, 94, 98, 99, 100, 101, 102, 105, 106, 112, 
  116, 117, 119, 4, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 
  26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 
  50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 76, 77, 
  78, 79, 80, 83, 84, 85, 86, 87, 89, 90, 94, 95, 97, 98, 99, 100, 102, 112, 116, 117, 118, 6, 7, 8, 
  9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 
  33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 78, 79, 4, 
  5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 
  29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 
  53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 
  78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 90, 91, 92, 94, 98, 99, 100, 102, 105, 106, 117, 4, 5, 6, 
  7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 
  31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 
  55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 78, 79, 80, 
  81, 82, 83, 90, 91, 92, 94, 98, 99, 100, 102, 105, 106, 117, 0, 1, 3, 4, 5, 6, 7, 8, 9, 10, 
  11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 
  35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 
  59, 60, 61, 62, 63, 64, 65, 66, 67, 89, 93, 113, 114, 116, 117, 4, 5, 6, 7, 8, 9, 10, 11, 12, 
  13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 
  37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 
  61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 83, 88, 112, 84, 85, 
  86, 87, 0, 1, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 
  24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 
  48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 
  72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 
  100, 101, 102, 103, 104, 105, 106, 107, 112, 83, 89, 90, 98, 99, 100, 0, 1, 4, 5, 6, 7, 8, 9, 10, 
  11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 
  35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 
  59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 
  83, 89, 90, 91, 93, 94, 98, 99, 100, 101, 102, 105, 106, 112, 116, 117, 119, 55, 56, 60, 61, 62, 63, 64, 
  65, 66, 67, 76, 77, 0, 1, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 
  23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 
  47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 76, 77, 78, 
  79, 80, 81, 82, 83, 89, 90, 91, 93, 94, 0, 1, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 
  15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 
  39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 
  63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 88, 89, 90, 
  91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 109, 111, 112, 116, 117, 1, 6, 
  7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 
  31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 
  55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 
  79, 89, 93, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 
  26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 
  50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 
  74, 75, 78, 79, 88, 89, 93, 116, 117, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 
  19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 
  43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 
  67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 89, 90, 91, 
  93, 94, 98, 99, 100, 101, 102, 105, 106, 112, 116, 117, 119, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 
  15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 
  39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 
  63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 78, 79, 80, 81, 82, 83, 90, 91, 92, 94, 98, 
  99, 100, 102, 105, 106, 117, 0, 1, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 
  19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 
  43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 
  67, 89, 93, 113, 114, 116, 117, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 
  21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 
  45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 
  69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 
  93, 94, 96, 97, 98, 100, 102, 104, 105, 106, 116, 117, 78, 84, 85, 86, 87, 4, 5, 6, 7, 8, 9, 10, 
  11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 
  35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 
  59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 
  89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 102, 104, 105, 106, 107, 112, 0, 1, 6, 7, 8, 9, 
  10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 
  34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 
  58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 78, 79, 80, 81, 82, 83, 
  88, 90, 91, 94, 98, 99, 100, 101, 102, 105, 106, 116, 117, 3, 4, 6, 7, 8, 9, 10, 11, 12, 13, 14, 
  15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 
  39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 
  63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 
  89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 104, 105, 106, 6, 7, 8, 9, 10, 11, 12, 
  13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 
  37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 
  61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 78, 79, 80, 81, 82, 83, 84, 85, 86, 
  87, 91, 99, 105, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 
  24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 
  48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 
  72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 85, 88, 89, 90, 91, 92, 93, 94, 98, 99, 100, 101, 
  102, 103, 105, 106, 112, 116, 117, 0, 1, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 
  19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 
  43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 
  67, 68, 69, 70, 71, 72, 73, 74, 75, 78, 79, 80, 81, 82, 83, 88, 89, 90, 91, 92, 93, 94, 95, 96, 
  97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 112, 116, 117, 0, 1, 4, 5, 6, 7, 8, 9, 10, 11, 
  12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 
  36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 
  60, 61, 62, 63, 64, 65, 66, 67, 89, 93, 116, 117, 0, 1, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 
  14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 
  38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 
  62, 63, 64, 65, 66, 67, 89, 93, 116, 117, 0, 1, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 
  17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 
  41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 
  65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 89, 
  90, 95, 98, 99, 100, 102, 105, 106, 84, 85, 86, 87, 0, 1, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 
  16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 
  40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 
  64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 78, 79, 80, 81, 82, 83, 89, 90, 91, 92, 93, 94, 
  95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 112, 116, 117, 84, 85, 86, 87, 1, 4, 5, 61, 
  62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 76, 77, 82, 83, 88, 93, 94, 95, 102, 105, 109, 3, 6, 7, 
  8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 
  32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 
  56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 
  89, 90, 91, 92, 93, 94, 95, 96, 97, 99, 100, 101, 102, 103, 104, 107, 116, 117, 0, 1, 6, 7, 8, 9, 
  10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 
  34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 
  58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 78, 79, 83, 89, 93, 6, 
  7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 
  31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 
  55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 84, 85, 86, 87, 0, 1, 4, 5, 6, 7, 8, 
  9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 
  33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 
  57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 78, 79, 80, 81, 82, 83, 88, 89, 90, 
  91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 112, 116, 117, 0, 1, 3, 4, 
  5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 
  29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 
  53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 
  77, 78, 79, 80, 81, 82, 83, 89, 90, 91, 93, 94, 98, 99, 100, 101, 102, 105, 106, 112, 116, 117, 119, 0, 
  1, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 
  26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 
  50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 
  74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 
  102, 103, 104, 105, 106, 107, 112, 116, 117, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 
  4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 30, 
  31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 54, 55, 56, 57, 
  58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 
  82, 83, 90, 91, 92, 94, 98, 99, 100, 102, 105, 106, 117, 0, 1, 3, 4, 5, 6, 7, 8, 9, 10, 11, 
  12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 
  36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 
  60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 78, 79, 80, 81, 82, 83, 88, 89, 
  90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 112, 115, 116, 117, 90, 0, 
  1, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 
  29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 
  53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 90, 
  91, 92, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 112, 4, 5, 6, 7, 8, 9, 10, 
  11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 
  35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 
  59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 
  83, 90, 91, 92, 94, 98, 99, 100, 102, 105, 106, 117, 3, 4, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 
  16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 
  40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 
  64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 
  92, 93, 94, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 112, 0, 1, 4, 5, 6, 7, 8, 9, 
  10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 
  34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 
  58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 
  82, 83, 107, 116, 117, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 
  23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 
  47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 
  71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 90, 91, 92, 94, 98, 99, 100, 102, 105, 106, 117, 
  6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 
  30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 
  54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 78, 79, 
  80, 81, 82, 83, 84, 85, 86, 87, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 
  20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 
  44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 
  68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 89, 90, 91, 93, 94, 98, 99, 100, 
  102, 105, 106, 112, 116, 117, 119, 0, 1, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 
  19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 
  43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 
  67, 68, 69, 70, 71, 72, 73, 74, 75, 78, 79, 80, 81, 82, 83, 88, 89, 90, 91, 92, 93, 94, 95, 96, 
  97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 112, 0, 1, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 
  16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 
  40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 
  64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 78, 79, 80, 81, 82, 83, 89, 90, 91, 92, 93, 94, 
  95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 112, 116, 117, 5, 6, 7, 8, 9, 10, 11, 12, 
  13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 
  37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 
  61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 84, 85, 86, 87, 
  95, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 
  29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 
  53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 78, 
  79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 102, 104, 
  105, 106, 107, 112, 0, 1, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 
  21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 
  45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 76, 
  77, 78, 79, 116, 117, 21, 45, 55, 56, 58, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 
  74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 89, 90, 91, 92, 93, 94, 96, 97, 98, 99, 100, 101, 102, 103, 
  104, 105, 106, 107, 112, 0, 1, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 
  21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 
  45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 78, 
  79, 80, 81, 82, 83, 90, 91, 92, 93, 94, 98, 99, 100, 101, 102, 103, 114, 1, 4, 5, 6, 7, 8, 9, 
  10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 
  34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 
  58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 
  82, 83, 90, 91, 92, 93, 94, 98, 99, 101, 102, 103, 105, 106, 109, 110, 119, 0, 1, 4, 5, 6, 7, 8, 
  9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 
  33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 
  57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 
  81, 82, 83, 90, 91, 92, 94, 98, 99, 101, 102, 103, 105, 106, 109, 110, 119, 0, 1, 4, 5, 6, 7, 8, 
  9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 
  33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 
  57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 
  81, 82, 83, 90, 91, 92, 94, 98, 99, 101, 102, 103, 105, 106, 109, 110, 119, 0, 1, 4, 5, 6, 7, 8, 
  9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 
  33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 
  57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 
  81, 82, 83, 90, 91, 92, 94, 98, 99, 101, 102, 103, 105, 106, 109, 110, 119, 6, 7, 8, 9, 10, 11, 12, 
  13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 
  37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 
  61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 90, 94, 97, 100, 
  102, 112, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 
  26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 
  50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 
  74, 75, 76, 77, 78, 79, 89, 90, 98, 99, 100, 102, 112, 116, 117, 118, 0, 1, 3, 4, 5, 6, 7, 8, 
  9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 
  33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 
  57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 78, 79, 80, 81, 82, 83, 84, 85, 86, 
  87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 109, 111, 112, 
  113, 114, 115, 116, 117, 0, 1, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 
  20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 
  44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 
  68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 88, 89, 90, 91, 92, 93, 94, 95, 
  96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 111, 112, 116, 117, 0, 1, 3, 4, 5, 6, 7, 8, 
  9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 
  33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 
  57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 
  81, 82, 83, 84, 85, 86, 87, 89, 90, 91, 92, 93, 94, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 
  107, 112, 113, 114, 115, 116, 117, 119, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 
  20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 
  44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 
  68, 69, 70, 71, 72, 73, 74, 75, 78, 79, 116, 117, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 
  16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 
  40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 
  64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 
  89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 102, 104, 105, 106, 107, 84, 85, 86, 87, 0, 1, 4, 
  5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 
  29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 
  53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 
  77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 
  101, 102, 103, 104, 105, 106, 107, 112, 116, 117, 84, 85, 86, 87, 84, 85, 86, 87, 0, 1, 4, 5, 6, 7, 
  8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 
  32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 
  56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 78, 79, 80, 81, 
  82, 83, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 112, 
  116, 117, 54, 55, 57, 64, 76, 77, 20, 26, 44, 50, 54, 57, 76, 77, 20, 26, 44, 50, 0, 1, 4, 5, 
  6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 
  30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 
  54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 78, 79, 
  80, 81, 82, 83, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 
  109, 112, 116, 117, 54, 55, 57, 64, 76, 77, 20, 26, 44, 50, 54, 57, 76, 77, 20, 26, 44, 50, 4, 5, 
  6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 
  30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 
  54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 116, 117, 84, 85, 86, 87, 0, 1, 4, 5, 
  6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 
  30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 
  54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 78, 79, 
  80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 
  104, 105, 106, 107, 112, 113, 114, 116, 117, 119, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 
  20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 
  44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 
  0, 1, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 
  25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 
  49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 
  73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 90, 91, 92, 93, 94, 95, 96, 97, 99, 100, 101, 102, 103, 104, 
  105, 106, 107, 112, 116, 117, 82, 83, 95, 76, 77, 83, 84, 85, 86, 87, 89, 90, 95, 98, 99, 100, 113, 114, 
  115, 116, 117, 119, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 
  26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 
  50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 
  74, 75, 78, 79, 80, 81, 82, 83, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 
  105, 106, 107, 112, 116, 117, 0, 1, 95, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 
  21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 
  45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 
  69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 
  93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 112, 0, 1, 4, 5, 6, 7, 8, 9, 
  10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 
  34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 
  58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 76, 77, 89, 93, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 
  14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 
  38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 
  62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 
  88, 89, 90, 91, 92, 93, 94, 95, 98, 99, 100, 103, 105, 106, 112, 84, 85, 86, 87, 3, 3, 4, 5, 6, 
  7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 
  31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 
  55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 78, 79, 80, 
  81, 82, 83, 84, 85, 86, 87, 89, 90, 91, 92, 93, 94, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 
  4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 
  28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 
  52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 
  76, 77, 78, 79, 80, 81, 82, 83, 90, 91, 92, 94, 98, 99, 100, 102, 105, 106, 117, 0, 1, 4, 5, 6, 
  7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 
  31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 
  55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 78, 79, 80, 
  81, 82, 83, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 116, 117, 
  4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 
  28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 
  52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 
  78, 79, 80, 81, 82, 83, 84, 85, 87, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 
  104, 105, 106, 112, 114, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 
  23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 
  47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 
  71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 89, 90, 91, 92, 93, 94, 95, 
  96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 112, 0, 1, 3, 4, 5, 6, 7, 8, 9, 10, 11, 
  12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 
  36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 
  60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 
  89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 112, 116, 117, 4, 5, 6, 7, 8, 
  9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 
  33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 
  57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 78, 79, 88, 116, 117, 1, 6, 7, 8, 
  9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 
  33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 
  57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 
  81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 
  105, 106, 107, 112, 116, 117, 0, 1, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 
  20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 
  44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 
  80, 81, 82, 84, 85, 89, 92, 93, 105, 106, 108, 111, 113, 114, 116, 117, 118, 0, 1, 3, 4, 5, 6, 7, 
  8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 
  32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 
  56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 
  80, 81, 82, 83, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 112, 116, 117, 118, 
  84, 85, 86, 87, 0, 1, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 
  21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 
  45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 
  69, 70, 71, 72, 73, 74, 75, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 
  96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 116, 117, 1, 4, 5, 6, 7, 8, 9, 10, 11, 12, 
  13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 
  37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 
  61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 89, 
  90, 91, 93, 94, 98, 99, 100, 101, 102, 105, 106, 112, 116, 117, 119, 1, 4, 5, 6, 7, 8, 9, 10, 11, 
  12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 
  36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 
  60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 78, 79, 80, 81, 82, 88, 91, 92, 
  93, 94, 105, 106, 115, 0, 1, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 
  21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 
  45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 
  69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 90, 91, 92, 94, 98, 99, 100, 102, 105, 
  106, 117, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 
  26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 
  50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 
  74, 75, 76, 77, 79, 80, 81, 82, 88, 89, 90, 93, 94, 96, 97, 98, 99, 100, 101, 102, 103, 104, 107, 112, 
  0, 1, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 
  26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 
  50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 
  74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 
  102, 103, 104, 105, 106, 107, 109, 112, 116, 117, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 
  14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 
  38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 
  62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 
  86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 
  110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 2, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 
  17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 
  41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 
  65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 89, 90, 91, 
  92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 112, 0, 1, 4, 5, 6, 7, 8, 
  9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 
  33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 
  57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 
  81, 82, 83, 84, 85, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 
  109, 116, 117, 0, 1, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 
  25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 
  49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 0, 1, 4, 5, 6, 
  7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 
  31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 
  55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 
  79, 80, 81, 82, 83, 84, 85, 89, 90, 91, 92, 93, 94, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 
  109, 116, 117, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 
  25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 
  49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 80, 81, 82, 83, 84, 
  85, 86, 87, 90, 91, 92, 94, 98, 99, 100, 102, 105, 106, 4, 5, 54, 55, 56, 57, 58, 59, 60, 61, 62, 
  63, 64, 65, 66, 67, 80, 81, 82, 83, 84, 85, 86, 87, 89, 90, 91, 93, 94, 98, 99, 100, 102, 105, 106, 
  112, 116, 117, 119, 0, 1, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 
  22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 
  46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 
  70, 71, 72, 73, 74, 75, 78, 79, 80, 81, 82, 83, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 
  100, 101, 102, 103, 104, 105, 106, 107, 112, 0, 1, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 
  17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 
  41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 
  65, 66, 67, 68, 69, 70, 71, 76, 77, 78, 79, 80, 81, 82, 83, 88, 89, 90, 91, 92, 93, 94, 95, 96, 
  97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 112, 114, 115, 116, 117, 0, 1, 4, 5, 6, 7, 8, 9, 
  10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 
  34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 
  58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 89, 93, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 
  16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 
  40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 
  64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 90, 91, 92, 94, 
  98, 99, 100, 102, 105, 106, 117, 0, 1, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 
  21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 
  45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 62, 63, 64, 65, 67, 68, 69, 70, 
  71, 78, 79, 80, 81, 82, 91, 93, 94, 99, 100, 101, 102, 109, 112, 116, 117, 0, 1, 6, 7, 8, 9, 10, 
  11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 
  35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 
  59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 
  83, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 112, 116, 117, 
  1, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 
  27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 
  51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 
  75, 78, 79, 80, 81, 82, 83, 89, 90, 91, 92, 93, 94, 98, 105, 106, 116, 117, 3, 4, 5, 6, 7, 8, 
  9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 
  33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 
  57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 
  81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 
  105, 106, 107, 112, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 
  24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 
  48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 
  76, 77, 78, 79, 80, 81, 82, 83, 90, 91, 92, 94, 98, 99, 100, 102, 105, 106, 117, 0, 1, 4, 5, 6, 
  7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 
  31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 
  55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 76, 77, 78, 79, 80, 81, 82, 
  83, 89, 90, 91, 93, 94, 98, 99, 100, 101, 102, 105, 106, 112, 116, 117, 119, 6, 7, 8, 9, 10, 11, 12, 
  13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 
  37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 
  61, 62, 63, 64, 65, 66, 67, 76, 77, 80, 81, 82, 83, 88, 89, 90, 91, 93, 94, 96, 97, 100, 112, 4, 
  5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 
  29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 
  53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 
  77, 79, 80, 81, 82, 83, 85, 86, 87, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 
  104, 105, 106, 112, 116, 117, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 
  24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 
  48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 
  74, 75, 76, 77, 0, 1, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 
  24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 
  48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 
  72, 73, 74, 75, 78, 79, 80, 81, 82, 83, 89, 90, 91, 92, 93, 94, 96, 97, 98, 99, 100, 101, 102, 103, 
  104, 105, 106, 107, 112, 116, 117, 76, 77, 84, 85, 86, 87, 76, 77, 84, 85, 86, 87, 4, 5, 6, 7, 8, 
  9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 
  33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 
  57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 
  81, 82, 83, 84, 85, 86, 87, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 
  106, 107, 108, 109, 111, 112, 115, 116, 117, 118, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 
  18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 
  42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 
  66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 89, 90, 91, 92, 
  93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 111, 112, 115, 116, 117, 118, 76, 
  77, 84, 85, 86, 87, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 
  25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 
  49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 89, 93, 116, 117, 0, 
  1, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 
  26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 
  50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 
  74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 90, 91, 94, 98, 99, 101, 102, 105, 106, 109, 110, 119, 4, 5, 
  6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 
  30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 
  54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 
  78, 79, 80, 81, 82, 83, 84, 85, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 
  105, 106, 107, 108, 109, 111, 112, 115, 116, 117, 118, 83, 84, 85, 86, 87, 89, 90, 98, 99, 100, 83, 84, 85, 
  86, 87, 89, 90, 99, 100, 84, 85, 86, 87, 83, 84, 85, 86, 87, 89, 90, 99, 100, 110, 4, 5, 6, 7, 
  8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 
  32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 
  56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 
  80, 81, 82, 83, 84, 85, 86, 87, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 
  105, 106, 107, 108, 109, 111, 112, 115, 116, 117, 118, 72, 73, 74, 75, 78, 79, 80, 83, 84, 85, 86, 87, 89, 
  90, 97, 98, 99, 100, 116, 117, 118, 84, 85, 86, 87, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 
  16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 
  40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 
  64, 65, 66, 67, 68, 69, 70, 71, 78, 79, 80, 81, 82, 91, 92, 93, 94, 102, 105, 106, 112, 116, 117, ]

const localeCellValue*: array[27287, uint16] = [
  0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 
  12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 
  12, 13, 26, 27, 28, 29, 30, 31, 32, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 36, 0, 1, 37, 
  38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 43, 55, 56, 57, 58, 59, 60, 
  61, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 43, 55, 56, 57, 58, 59, 60, 
  61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 
  85, 86, 87, 88, 89, 90, 91, 34, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 
  108, 109, 110, 111, 112, 109, 110, 0, 1, 113, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 
  127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 
  127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 
  151, 152, 153, 154, 155, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 163, 164, 34, 93, 94, 165, 166, 
  100, 101, 102, 105, 106, 167, 109, 110, 168, 37, 38, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 169, 
  170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 169, 
  170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 
  194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 111, 112, 109, 110, 210, 211, 212, 34, 
  92, 213, 214, 165, 215, 216, 217, 105, 106, 110, 37, 38, 218, 219, 220, 221, 222, 223, 224, 225, 226, 227, 228, 229, 
  230, 231, 220, 232, 222, 223, 224, 233, 234, 235, 236, 237, 218, 219, 220, 221, 222, 223, 224, 225, 226, 227, 228, 229, 
  230, 231, 220, 232, 222, 223, 224, 233, 234, 235, 236, 237, 238, 239, 240, 241, 242, 243, 244, 238, 239, 245, 241, 242, 
  243, 244, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255, 256, 257, 160, 161, 93, 258, 259, 260, 261, 262, 163, 263, 
  34, 92, 264, 265, 266, 267, 268, 165, 166, 269, 270, 104, 107, 108, 271, 272, 273, 274, 275, 276, 277, 278, 279, 280, 
  281, 282, 283, 284, 285, 286, 287, 288, 289, 278, 279, 280, 281, 282, 283, 284, 285, 286, 287, 288, 289, 278, 279, 280, 
  281, 282, 283, 284, 285, 286, 287, 288, 289, 278, 279, 280, 281, 282, 283, 284, 285, 286, 287, 288, 289, 290, 291, 292, 
  293, 294, 295, 296, 290, 291, 292, 293, 294, 295, 296, 297, 298, 299, 300, 297, 298, 299, 300, 301, 302, 303, 302, 304, 
  161, 305, 306, 259, 260, 261, 262, 307, 306, 308, 34, 92, 93, 309, 310, 311, 312, 313, 314, 315, 101, 316, 103, 104, 
  105, 106, 107, 317, 0, 318, 319, 320, 321, 322, 323, 324, 325, 319, 320, 321, 322, 323, 324, 325, 319, 320, 321, 322, 
  323, 324, 325, 319, 320, 321, 322, 323, 324, 325, 326, 327, 328, 329, 330, 331, 332, 333, 334, 335, 336, 337, 338, 339, 
  340, 341, 330, 331, 332, 333, 334, 335, 336, 337, 338, 342, 340, 341, 330, 331, 332, 333, 334, 335, 336, 337, 338, 339, 
  340, 341, 330, 331, 332, 333, 334, 335, 336, 337, 338, 339, 340, 341, 330, 331, 332, 333, 334, 335, 336, 337, 338, 339, 
  340, 341, 330, 331, 332, 333, 334, 335, 336, 337, 338, 339, 340, 341, 330, 331, 332, 333, 334, 335, 336, 337, 338, 339, 
  340, 341, 330, 331, 332, 333, 334, 335, 336, 337, 338, 339, 340, 341, 343, 344, 345, 346, 0, 318, 330, 331, 332, 333, 
  334, 335, 336, 337, 338, 339, 340, 341, 330, 331, 332, 333, 334, 335, 336, 337, 338, 339, 340, 341, 330, 331, 332, 333, 
  334, 335, 336, 337, 338, 339, 340, 341, 330, 331, 332, 333, 334, 335, 336, 337, 338, 339, 340, 341, 0, 318, 0, 318, 
  322, 347, 348, 349, 350, 351, 322, 347, 348, 349, 350, 351, 322, 347, 348, 349, 350, 351, 322, 347, 348, 349, 350, 351, 
  343, 344, 345, 346, 0, 318, 352, 353, 354, 355, 352, 353, 354, 355, 352, 353, 354, 355, 352, 353, 354, 355, 330, 331, 
  332, 333, 334, 335, 336, 337, 338, 339, 340, 341, 330, 331, 332, 333, 334, 335, 336, 337, 338, 339, 340, 341, 330, 331, 
  332, 333, 334, 335, 336, 337, 338, 339, 340, 341, 330, 331, 332, 333, 334, 335, 336, 337, 338, 339, 340, 341, 356, 356, 
  330, 331, 332, 333, 334, 335, 336, 337, 338, 339, 340, 341, 330, 331, 332, 333, 334, 335, 336, 337, 338, 339, 340, 341, 
  330, 331, 332, 333, 334, 335, 336, 337, 338, 339, 340, 341, 330, 331, 332, 333, 334, 335, 336, 337, 338, 339, 340, 341, 
  0, 318, 319, 320, 321, 322, 323, 324, 325, 319, 320, 321, 322, 323, 324, 325, 319, 320, 321, 322, 323, 324, 325, 319, 
  320, 321, 322, 323, 324, 325, 357, 358, 38, 359, 360, 361, 362, 363, 364, 365, 366, 367, 368, 369, 370, 371, 372, 361, 
  362, 363, 364, 365, 373, 374, 375, 376, 377, 359, 360, 361, 362, 363, 364, 365, 366, 367, 368, 369, 370, 371, 372, 361, 
  362, 363, 364, 365, 373, 374, 375, 376, 377, 378, 379, 380, 381, 382, 383, 384, 385, 386, 387, 388, 389, 390, 391, 392, 
  393, 394, 395, 392, 393, 394, 395, 396, 397, 398, 399, 400, 401, 402, 403, 404, 405, 406, 407, 34, 92, 93, 98, 99, 
  103, 105, 106, 108, 272, 273, 274, 408, 408, 409, 410, 411, 412, 43, 413, 414, 415, 416, 417, 418, 419, 420, 421, 422, 
  423, 43, 424, 425, 426, 427, 428, 429, 430, 409, 410, 411, 412, 43, 413, 414, 415, 416, 417, 418, 419, 420, 421, 422, 
  423, 43, 424, 425, 426, 427, 428, 429, 430, 431, 432, 433, 434, 435, 436, 437, 438, 439, 440, 441, 442, 443, 444, 445, 
  446, 447, 448, 449, 450, 451, 452, 453, 454, 455, 456, 457, 161, 93, 258, 163, 212, 34, 92, 93, 214, 165, 215, 216, 
  217, 105, 106, 110, 0, 318, 408, 408, 458, 459, 460, 461, 462, 463, 464, 465, 466, 467, 468, 469, 470, 471, 472, 473, 
  474, 475, 476, 477, 478, 479, 480, 481, 482, 483, 484, 485, 486, 487, 488, 489, 490, 491, 492, 493, 494, 421, 495, 496, 
  497, 498, 499, 426, 500, 501, 502, 503, 504, 505, 506, 507, 508, 509, 510, 511, 512, 472, 513, 514, 515, 516, 517, 518, 
  519, 520, 521, 522, 523, 524, 525, 526, 527, 528, 93, 209, 210, 163, 529, 34, 530, 93, 531, 311, 532, 165, 166, 533, 
  101, 534, 103, 104, 105, 535, 107, 108, 109, 110, 0, 318, 408, 408, 536, 537, 538, 539, 474, 540, 541, 542, 543, 544, 
  545, 546, 547, 548, 472, 549, 474, 550, 551, 552, 553, 554, 555, 556, 536, 537, 538, 539, 474, 540, 541, 542, 543, 544, 
  545, 546, 547, 548, 472, 549, 474, 550, 551, 552, 553, 554, 555, 556, 557, 558, 559, 560, 561, 562, 563, 564, 565, 566, 
  567, 568, 569, 570, 571, 572, 573, 574, 575, 576, 577, 578, 579, 580, 457, 161, 93, 581, 33, 582, 34, 92, 93, 531, 
  583, 584, 585, 586, 587, 588, 101, 534, 103, 589, 167, 109, 110, 0, 318, 408, 408, 590, 591, 592, 593, 594, 595, 596, 
  597, 598, 599, 600, 601, 602, 603, 604, 605, 594, 606, 607, 608, 609, 610, 611, 612, 613, 614, 615, 616, 617, 618, 619, 
  620, 621, 622, 623, 624, 602, 603, 604, 605, 594, 606, 607, 608, 609, 610, 611, 612, 625, 626, 627, 628, 629, 630, 631, 
  632, 633, 634, 635, 636, 637, 638, 639, 640, 641, 642, 643, 644, 645, 646, 647, 648, 649, 650, 651, 161, 93, 581, 33, 
  582, 652, 93, 653, 584, 654, 586, 587, 655, 101, 656, 589, 167, 0, 1, 408, 408, 657, 658, 592, 659, 594, 660, 661, 
  597, 662, 663, 664, 665, 666, 667, 668, 669, 594, 670, 671, 672, 673, 674, 675, 676, 657, 658, 592, 659, 594, 660, 661, 
  597, 662, 663, 664, 665, 666, 667, 668, 669, 594, 670, 671, 672, 673, 674, 675, 676, 677, 678, 679, 680, 681, 682, 683, 
  684, 685, 686, 687, 688, 689, 690, 691, 692, 693, 694, 695, 696, 697, 698, 699, 700, 701, 702, 703, 33, 210, 33, 582, 
  704, 705, 703, 706, 707, 708, 709, 587, 655, 101, 656, 103, 710, 711, 712, 713, 714, 109, 110, 715, 716, 717, 718, 719, 
  424, 720, 721, 722, 723, 724, 725, 420, 726, 727, 423, 719, 424, 728, 729, 730, 731, 732, 733, 715, 716, 717, 718, 719, 
  424, 720, 721, 722, 723, 724, 725, 420, 726, 727, 423, 719, 424, 728, 729, 730, 731, 732, 733, 734, 735, 736, 737, 738, 
  739, 740, 741, 742, 743, 744, 745, 746, 747, 748, 749, 750, 751, 752, 753, 754, 755, 756, 757, 758, 759, 760, 400, 162, 
  209, 761, 762, 763, 764, 163, 765, 109, 766, 0, 1, 767, 408, 408, 768, 769, 770, 771, 772, 773, 774, 775, 776, 777, 
  778, 779, 780, 781, 782, 783, 784, 785, 786, 787, 788, 789, 474, 790, 768, 769, 770, 771, 772, 773, 774, 775, 776, 777, 
  778, 779, 780, 781, 782, 783, 784, 785, 786, 787, 788, 789, 474, 790, 791, 792, 793, 794, 795, 796, 797, 798, 799, 800, 
  801, 802, 803, 804, 805, 806, 807, 808, 809, 810, 811, 812, 813, 814, 815, 816, 160, 161, 162, 163, 163, 164, 34, 93, 
  94, 165, 166, 100, 101, 102, 105, 106, 108, 109, 110, 168, 0, 1, 767, 408, 408, 817, 818, 819, 820, 821, 822, 823, 
  824, 825, 826, 827, 828, 829, 830, 831, 832, 821, 833, 834, 835, 836, 837, 838, 839, 840, 841, 842, 843, 594, 844, 845, 
  846, 847, 848, 849, 850, 829, 830, 831, 832, 594, 833, 834, 835, 836, 837, 838, 839, 851, 852, 853, 854, 855, 856, 857, 
  858, 859, 860, 861, 862, 863, 864, 865, 866, 867, 868, 869, 870, 871, 872, 873, 874, 875, 876, 877, 878, 879, 210, 880, 
  881, 882, 883, 93, 531, 884, 885, 886, 887, 888, 889, 101, 534, 103, 890, 105, 106, 891, 271, 109, 110, 892, 893, 37, 
  38, 409, 410, 411, 894, 43, 413, 414, 895, 416, 417, 418, 896, 420, 421, 422, 897, 43, 424, 425, 898, 427, 428, 429, 
  899, 409, 410, 411, 894, 43, 413, 414, 895, 416, 417, 418, 896, 420, 421, 422, 897, 43, 424, 425, 898, 427, 428, 429, 
  899, 900, 901, 902, 903, 904, 905, 906, 900, 901, 902, 903, 904, 905, 906, 907, 908, 909, 759, 457, 161, 93, 258, 326, 
  327, 328, 329, 163, 212, 34, 92, 93, 214, 165, 215, 216, 217, 105, 106, 110, 113, 113, 910, 911, 912, 913, 914, 915, 
  916, 917, 918, 919, 920, 921, 922, 923, 924, 925, 926, 927, 928, 929, 930, 931, 932, 933, 910, 911, 912, 913, 914, 915, 
  916, 917, 918, 919, 920, 921, 922, 923, 924, 925, 926, 927, 928, 929, 930, 931, 932, 933, 934, 935, 936, 937, 938, 939, 
  940, 941, 923, 942, 943, 944, 945, 946, 947, 948, 949, 950, 951, 952, 953, 954, 955, 956, 455, 456, 457, 161, 93, 258, 
  163, 212, 34, 92, 93, 214, 165, 215, 216, 217, 105, 106, 110, 0, 1, 408, 957, 958, 959, 592, 960, 594, 961, 962, 
  597, 963, 964, 965, 966, 967, 603, 592, 605, 594, 961, 962, 608, 968, 610, 969, 612, 958, 959, 592, 960, 594, 961, 962, 
  597, 963, 964, 965, 966, 967, 603, 592, 605, 594, 961, 962, 608, 968, 610, 969, 612, 970, 971, 972, 973, 974, 975, 976, 
  858, 859, 977, 861, 978, 863, 864, 979, 980, 981, 982, 983, 984, 985, 986, 756, 757, 987, 988, 875, 876, 989, 990, 991, 
  992, 328, 329, 210, 989, 993, 994, 995, 989, 993, 996, 997, 998, 994, 999, 1000, 999, 1000, 103, 1001, 1002, 1003, 891, 1004, 
  1005, 1006, 1007, 1008, 1009, 1010, 1011, 1012, 168, 1013, 1014, 1015, 1016, 1017, 1018, 1019, 1020, 1021, 1022, 1023, 1024, 1013, 1014, 1015, 
  1016, 1017, 1018, 1019, 1020, 1021, 1022, 1023, 1024, 1013, 1014, 1015, 1016, 1017, 1018, 1019, 1020, 1021, 1022, 1023, 1024, 1013, 1014, 1015, 
  1016, 1017, 1018, 1019, 1020, 1021, 1022, 1023, 1024, 1025, 1026, 1027, 1028, 1029, 1030, 1031, 1025, 1026, 1027, 1028, 1029, 1030, 1031, 259, 
  260, 261, 262, 37, 37, 1013, 1014, 1015, 1016, 1017, 1018, 1019, 1020, 1021, 1022, 1032, 1024, 1013, 1014, 1015, 1016, 1017, 1018, 1019, 
  1020, 1021, 1022, 1032, 1024, 1013, 1014, 1015, 1016, 1017, 1018, 1019, 1020, 1021, 1022, 1032, 1024, 1013, 1014, 1015, 1016, 1017, 1018, 1019, 
  1020, 1021, 1022, 1032, 1024, 1033, 1034, 1035, 1036, 1037, 1038, 1039, 1033, 1034, 1035, 1036, 1037, 1038, 1039, 259, 260, 261, 262, 0, 
  1040, 1041, 1042, 1042, 1043, 1044, 1045, 1046, 1047, 1048, 1049, 1050, 1051, 1052, 1053, 1054, 1055, 146, 1056, 1057, 1058, 1059, 1060, 1061, 
  1062, 1063, 1064, 1065, 1043, 1044, 1045, 1046, 1047, 1048, 1049, 1050, 1051, 1052, 1053, 1054, 1055, 146, 1056, 1057, 1058, 1059, 1060, 1061, 
  1062, 1063, 1064, 1065, 1066, 1067, 1068, 1069, 1070, 1071, 1072, 1073, 1074, 1075, 1076, 1077, 1078, 1079, 1080, 1081, 1082, 1083, 1084, 1085, 
  1086, 1087, 1088, 1089, 1090, 1091, 1092, 1093, 1094, 1095, 210, 1095, 212, 34, 92, 1094, 1096, 1097, 1098, 1099, 165, 215, 216, 217, 
  104, 105, 106, 107, 108, 109, 110, 37, 38, 1100, 1101, 1102, 1103, 1104, 1105, 1106, 1107, 1108, 1109, 1110, 1111, 1112, 471, 472, 
  1113, 1104, 1114, 1115, 1107, 1116, 1117, 1118, 1119, 1100, 1101, 1102, 1103, 1104, 1105, 1106, 1107, 1108, 1109, 1110, 1111, 1112, 471, 472, 
  1113, 1104, 1114, 1115, 1107, 1116, 1117, 1118, 1119, 1120, 1121, 1122, 1123, 1124, 1125, 1126, 1127, 1128, 1129, 1130, 1131, 1132, 1133, 1134, 
  1135, 1136, 1137, 1138, 1139, 1140, 1141, 1142, 1143, 160, 161, 162, 163, 163, 164, 34, 92, 93, 94, 165, 166, 101, 102, 103, 
  105, 106, 1144, 1145, 168, 357, 1146, 1147, 1148, 1149, 1150, 1151, 1152, 364, 365, 1153, 1154, 1155, 1156, 1157, 371, 1158, 1150, 1159, 
  1152, 364, 1160, 373, 1161, 375, 1162, 1163, 1148, 1149, 1150, 1151, 1152, 364, 365, 1153, 1154, 1155, 1156, 1157, 371, 1158, 1150, 1151, 
  1152, 364, 365, 1153, 1164, 375, 1162, 1163, 1165, 1166, 1167, 1168, 1169, 1170, 1171, 1172, 386, 387, 388, 1173, 1174, 391, 1175, 1176, 
  1177, 1178, 1175, 1176, 1177, 1178, 1179, 1180, 1181, 400, 162, 209, 259, 260, 261, 262, 163, 529, 34, 92, 162, 1182, 310, 1183, 
  1184, 165, 166, 533, 101, 102, 103, 104, 105, 106, 107, 167, 1185, 1186, 1187, 1188, 1189, 1190, 1187, 1188, 1189, 1190, 1191, 1192, 
  1193, 1194, 1195, 1196, 1197, 1198, 1199, 1200, 1201, 1202, 1203, 1204, 1205, 1206, 1207, 1208, 1209, 1210, 1211, 1212, 1213, 1214, 1215, 1216, 
  1217, 1218, 1219, 1220, 1221, 1222, 1223, 1224, 1225, 1226, 1227, 1228, 1205, 1206, 1207, 1208, 1209, 1210, 1211, 1212, 1213, 1214, 1215, 1216, 
  1229, 1230, 1231, 1232, 1233, 1234, 1235, 1236, 1237, 1238, 1239, 1240, 1241, 1242, 1243, 1244, 1245, 1246, 1243, 1244, 1245, 1246, 1247, 1248, 
  1249, 1250, 1251, 1252, 1253, 1254, 1253, 1255, 1256, 1257, 1258, 259, 260, 261, 262, 0, 1, 767, 408, 957, 1259, 1260, 1261, 1262, 
  1263, 1264, 1265, 1266, 1267, 1268, 1269, 1270, 1271, 1272, 1273, 1274, 1263, 1275, 1276, 1266, 1277, 1268, 1269, 1278, 1259, 1260, 1261, 1262, 
  1263, 1264, 1265, 1266, 1267, 1268, 1269, 1270, 1271, 1272, 1273, 1274, 1263, 1275, 1276, 1266, 1277, 1268, 1269, 1278, 1279, 1280, 1261, 1281, 
  1282, 1283, 1284, 1279, 1280, 1285, 1286, 1282, 1287, 1288, 1289, 1290, 1291, 1292, 1293, 1294, 1295, 1296, 1297, 1298, 1299, 1300, 160, 161, 
  93, 258, 210, 258, 1301, 34, 92, 93, 94, 1302, 311, 1303, 1304, 1305, 1306, 101, 102, 103, 104, 105, 106, 107, 1307, 108, 
  109, 110, 357, 358, 38, 1308, 1309, 1015, 1310, 1311, 1312, 1019, 1313, 1314, 1315, 1316, 1317, 1318, 1319, 1015, 1320, 1311, 1312, 1321, 
  1322, 1323, 1324, 1325, 1326, 1308, 1309, 1015, 1310, 1311, 1312, 1019, 1313, 1314, 1315, 1316, 1317, 1318, 1319, 1015, 1320, 1311, 1312, 1321, 
  1322, 1323, 1324, 1325, 1326, 1327, 1328, 1035, 1036, 1329, 1330, 1331, 1332, 1333, 1334, 1335, 1336, 1337, 1338, 1339, 1340, 1341, 1342, 1343, 
  1344, 1345, 1346, 1347, 1348, 1349, 1350, 651, 400, 162, 406, 1351, 1352, 272, 1353, 210, 406, 212, 34, 92, 93, 214, 1354, 1355, 
  165, 215, 216, 1356, 217, 105, 106, 1357, 1358, 0, 318, 408, 408, 1359, 1360, 538, 1361, 1362, 1363, 1364, 1365, 1366, 1367, 1368, 
  1369, 1370, 471, 472, 549, 1362, 1371, 1372, 1373, 1374, 554, 1375, 1376, 1359, 1360, 538, 1361, 1362, 1363, 1364, 1365, 1366, 1367, 1368, 
  1369, 1370, 471, 472, 549, 1362, 1371, 1372, 1373, 1374, 554, 1375, 1376, 1377, 1378, 1379, 1380, 1381, 1382, 1383, 1384, 1385, 1386, 1387, 
  1388, 1389, 1390, 1391, 1392, 1393, 1394, 1395, 1396, 1397, 1398, 1399, 1400, 1401, 1402, 1403, 1404, 1405, 1406, 1406, 1407, 1408, 1409, 1405, 
  1410, 1411, 1412, 1413, 1414, 1415, 1416, 1417, 1418, 1419, 1420, 1421, 1422, 1423, 1424, 1425, 1426, 0, 318, 408, 408, 1427, 1428, 592, 
  960, 1429, 1430, 1431, 1432, 1433, 1434, 1435, 1436, 602, 1437, 604, 605, 1429, 1438, 1439, 1440, 968, 610, 1441, 1442, 1427, 1428, 592, 
  960, 1429, 1430, 1431, 1432, 1433, 1434, 1435, 1436, 602, 1437, 604, 605, 1429, 1438, 1439, 1440, 968, 610, 1441, 1442, 1443, 1444, 1445, 
  1446, 1447, 1448, 857, 1449, 1450, 1451, 1452, 1453, 1454, 1455, 1456, 1457, 1458, 1459, 1460, 1461, 1462, 1463, 1464, 1465, 1466, 1467, 1468, 
  1469, 1470, 1471, 1470, 1472, 1408, 1473, 1474, 1475, 1476, 1477, 1478, 1479, 1480, 1481, 1482, 1419, 1420, 1423, 1424, 1426, 0, 1, 767, 
  408, 408, 1483, 1484, 1485, 1486, 1487, 1488, 1489, 1490, 1491, 1492, 1493, 1494, 1483, 1484, 1485, 1486, 1487, 1488, 1489, 1490, 1491, 1492, 
  1493, 1494, 1483, 1484, 1485, 1486, 1487, 1488, 1489, 1490, 1491, 1492, 1493, 1494, 1483, 1484, 1485, 1486, 1487, 1488, 1489, 1490, 1491, 1492, 
  1493, 1494, 1495, 1496, 1497, 1498, 1499, 1500, 1501, 1495, 1496, 1497, 1498, 1499, 1500, 1501, 33, 1502, 1503, 1504, 1505, 1506, 1507, 1508, 
  1507, 0, 318, 767, 408, 957, 1509, 1510, 1511, 461, 1512, 1513, 1514, 1515, 1516, 1517, 1518, 1519, 1520, 1521, 1511, 1522, 1512, 1513, 
  1523, 1524, 1525, 1526, 1527, 1528, 1529, 1530, 1531, 485, 1532, 1533, 1534, 1535, 1536, 1537, 1538, 1539, 1540, 1541, 1531, 1542, 1532, 1533, 
  1543, 1544, 1545, 1546, 1547, 1548, 1549, 1550, 1551, 1552, 1553, 1554, 1555, 1556, 1557, 1558, 1559, 1560, 1561, 1562, 1563, 1564, 1565, 1566, 
  521, 522, 523, 524, 1399, 1400, 1567, 1568, 1569, 1570, 93, 209, 1571, 327, 328, 329, 210, 163, 529, 1572, 1573, 1574, 531, 310, 
  1575, 1576, 165, 166, 100, 101, 534, 103, 1577, 105, 1578, 107, 108, 328, 329, 271, 109, 110, 357, 1146, 1147, 1579, 1580, 1581, 
  1582, 1583, 1584, 1585, 1586, 1587, 1588, 1589, 1590, 1591, 1592, 1581, 1582, 1583, 1584, 1585, 1586, 1587, 1593, 1589, 1594, 1579, 1580, 1581, 
  1582, 1583, 1584, 1585, 1586, 1587, 1593, 1589, 1590, 1579, 1580, 1581, 1582, 1583, 1584, 1585, 1586, 1587, 1593, 1589, 1590, 1595, 1596, 1597, 
  1598, 1599, 1600, 1601, 1602, 1603, 1604, 1605, 1606, 1607, 1608, 1609, 1610, 1611, 1612, 1613, 1614, 1181, 400, 162, 209, 259, 260, 261, 
  262, 163, 529, 34, 92, 162, 1182, 1183, 1184, 165, 166, 1615, 101, 102, 103, 104, 105, 106, 107, 167, 767, 408, 408, 1616, 
  658, 592, 659, 594, 660, 661, 597, 662, 663, 664, 665, 1617, 603, 604, 605, 594, 1618, 1619, 608, 609, 610, 1620, 612, 1616, 
  658, 592, 659, 594, 660, 661, 597, 662, 663, 664, 665, 1617, 603, 604, 605, 594, 1618, 1619, 608, 609, 610, 1620, 612, 1621, 
  1622, 1623, 1624, 1625, 1626, 1627, 1628, 1629, 1630, 1631, 1632, 1633, 1634, 1635, 1636, 1637, 1638, 1639, 1640, 1641, 1642, 1643, 1644, 37, 
  38, 1645, 1646, 1647, 1648, 1649, 1650, 1651, 1652, 1653, 1654, 1655, 1656, 1657, 1658, 495, 496, 497, 1659, 1660, 426, 427, 428, 1661, 
  899, 1645, 1646, 1647, 1648, 1649, 1650, 1651, 1652, 1653, 1654, 1655, 1656, 1657, 1658, 495, 496, 497, 1659, 1660, 426, 427, 428, 1661, 
  899, 1662, 1663, 1664, 1665, 1666, 1667, 1668, 1669, 1280, 495, 1670, 1671, 1672, 928, 1673, 1674, 1675, 1676, 909, 759, 1677, 1678, 213, 
  1679, 111, 112, 109, 110, 210, 1095, 212, 34, 92, 213, 214, 1097, 1680, 1681, 165, 215, 216, 217, 104, 105, 106, 107, 167, 
  109, 110, 37, 37, 1682, 1683, 1684, 1685, 1686, 1687, 1688, 1689, 1690, 1691, 1692, 1693, 1694, 1695, 1696, 1697, 1698, 1699, 1700, 1701, 
  1702, 1703, 1704, 1705, 1682, 1683, 1684, 1685, 1686, 1687, 1688, 1689, 1690, 1691, 1692, 1693, 1694, 1695, 1696, 1697, 1698, 1699, 1700, 1701, 
  1702, 1703, 1704, 1705, 1706, 1707, 1708, 1709, 1710, 1711, 1712, 1713, 1714, 1715, 1716, 1717, 1718, 1719, 1720, 1721, 1722, 1723, 80, 81, 
  82, 83, 909, 759, 457, 161, 93, 258, 163, 212, 34, 92, 93, 214, 165, 215, 216, 217, 105, 106, 110, 37, 38, 1724, 
  1725, 1726, 1727, 1728, 1729, 1730, 1731, 1732, 1733, 1734, 1735, 1736, 1737, 1738, 1739, 1740, 1741, 1742, 1743, 1744, 1745, 1746, 1747, 1724, 
  1725, 1726, 1727, 1728, 1729, 1730, 1731, 1732, 1733, 1734, 1735, 1736, 1737, 1738, 1739, 1740, 1741, 1742, 1743, 1744, 1745, 1746, 1747, 1748, 
  1749, 1750, 1751, 1752, 1753, 1754, 1755, 1756, 1757, 1758, 1759, 1760, 1761, 1762, 1763, 1764, 1765, 1766, 1767, 909, 759, 1677, 1678, 213, 
  1679, 259, 260, 261, 262, 210, 1095, 212, 34, 92, 213, 214, 1097, 1680, 1681, 165, 215, 216, 217, 104, 105, 106, 107, 167, 
  1768, 1769, 1770, 1771, 1772, 1773, 1774, 1775, 1776, 1777, 1778, 1779, 1768, 1769, 1770, 1771, 1772, 1773, 1774, 1775, 1776, 1777, 1778, 1779, 
  1768, 1769, 1770, 1771, 1772, 1773, 1774, 1775, 1776, 1777, 1778, 1779, 1768, 1769, 1770, 1771, 1772, 1773, 1774, 1775, 1776, 1777, 1778, 1779, 
  1780, 1781, 1782, 1783, 1784, 1785, 1786, 1780, 1781, 1782, 1783, 1784, 1785, 1786, 1787, 1788, 1789, 1790, 1791, 1792, 1793, 1794, 1795, 1796, 
  1797, 1798, 1799, 259, 260, 261, 262, 163, 1800, 1801, 1802, 1803, 165, 1804, 1805, 1806, 1807, 1808, 343, 344, 345, 346, 37, 38, 
  1809, 1810, 1811, 1812, 1813, 1814, 1815, 1816, 1817, 1818, 1819, 1820, 1821, 1822, 1823, 1824, 1825, 1826, 1827, 1828, 1829, 1830, 1831, 1832, 
  1809, 1810, 1811, 1812, 1813, 1814, 1815, 1816, 1817, 1818, 1819, 1820, 1821, 1822, 1823, 1824, 1825, 1826, 1827, 1828, 1829, 1830, 1831, 1832, 
  1833, 1834, 1835, 1836, 1837, 1838, 1839, 1840, 1841, 1842, 1843, 1844, 1845, 1846, 1847, 1848, 1849, 1850, 1851, 1852, 1853, 1854, 1855, 1856, 
  1857, 1858, 1677, 1678, 213, 1679, 111, 112, 109, 110, 210, 1859, 0, 1, 767, 408, 408, 1860, 1861, 1862, 1863, 1864, 1865, 1866, 
  1867, 1868, 1869, 1870, 1871, 1872, 1873, 1874, 1875, 1876, 1877, 1878, 1879, 1880, 1881, 1882, 1883, 1884, 1885, 1886, 1887, 1888, 1889, 1890, 
  1891, 1868, 1892, 1893, 1894, 1872, 1873, 1874, 1875, 1876, 1877, 1878, 1879, 1880, 1881, 1882, 1883, 1895, 1896, 1897, 1898, 1899, 1900, 1901, 
  1902, 1903, 1904, 1905, 1906, 1907, 1908, 1909, 1910, 1911, 1912, 1913, 1914, 1915, 1916, 1917, 1918, 1919, 581, 1920, 327, 328, 329, 1919, 
  1921, 883, 883, 1919, 1921, 1922, 1923, 1924, 165, 1415, 1925, 1415, 1925, 1419, 1926, 105, 106, 107, 1425, 1927, 328, 329, 271, 109, 
  110, 1928, 1929, 1930, 1931, 1932, 1933, 1934, 1935, 1936, 1937, 1938, 1939, 1928, 1929, 1930, 1931, 1932, 1933, 1934, 1935, 1936, 1937, 1938, 
  1939, 1928, 1929, 1930, 1931, 1932, 1933, 1934, 1935, 1936, 1937, 1938, 1939, 1928, 1929, 1930, 1931, 1932, 1933, 1934, 1935, 1936, 1937, 1938, 
  1939, 1940, 1941, 1942, 1943, 1944, 1945, 1946, 1940, 1941, 1942, 1943, 1944, 1945, 1946, 1947, 1948, 111, 112, 109, 110, 0, 1, 767, 
  408, 957, 1949, 1950, 1951, 1952, 1953, 1954, 1955, 1956, 1957, 1958, 1959, 1960, 1961, 1962, 1951, 1952, 1953, 1963, 1955, 1964, 1957, 1958, 
  1959, 1965, 1949, 1950, 1951, 1952, 1953, 1954, 1955, 1956, 1957, 1958, 1959, 1960, 1961, 1962, 1951, 1952, 1953, 1963, 1955, 1964, 1957, 1958, 
  1959, 1965, 1966, 1967, 1968, 1969, 1970, 1971, 1972, 1973, 1974, 1975, 1976, 1977, 1978, 1979, 1980, 1981, 1982, 1983, 1984, 1985, 1986, 1987, 
  1988, 1989, 1990, 1991, 1992, 1993, 1994, 1995, 1996, 1997, 210, 1995, 1998, 1999, 2000, 1994, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 
  2009, 2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 37, 38, 2019, 2020, 2021, 2022, 719, 2023, 2024, 2025, 2026, 2027, 2028, 2029, 
  2030, 2031, 2032, 2033, 719, 2034, 2035, 2025, 2026, 2036, 2037, 2038, 2019, 2020, 2021, 2022, 719, 2023, 2024, 2025, 2026, 2027, 2028, 2029, 
  2030, 2039, 2032, 2033, 719, 2034, 2040, 2025, 2026, 2036, 2037, 2038, 2041, 2042, 2043, 2044, 2045, 2046, 2047, 1279, 2048, 2032, 2049, 2050, 
  2051, 2052, 2053, 2054, 2055, 2056, 2057, 2058, 2059, 2060, 2061, 2062, 457, 161, 93, 2063, 163, 529, 34, 92, 93, 531, 266, 311, 
  532, 165, 166, 533, 101, 534, 103, 104, 105, 106, 107, 109, 110, 0, 318, 767, 408, 408, 1359, 1360, 2064, 1361, 1362, 1363, 
  1364, 1365, 2065, 2066, 2067, 2068, 2069, 2070, 2071, 2072, 1362, 2073, 1543, 2074, 2075, 2076, 1547, 2077, 1359, 1360, 2064, 1361, 1362, 1363, 
  1364, 1365, 2065, 2066, 2067, 2068, 2069, 2070, 2071, 2072, 1362, 2073, 1543, 2074, 2075, 2076, 1547, 2077, 2078, 2079, 2080, 2081, 2082, 2083, 
  2084, 2085, 2086, 2087, 2088, 2089, 2090, 2091, 2092, 2093, 2094, 2095, 2096, 2097, 2098, 2099, 2100, 2101, 2102, 1918, 2103, 33, 2104, 2105, 
  2106, 2107, 880, 2108, 34, 92, 2103, 2109, 2110, 2111, 2112, 887, 888, 2113, 1417, 2114, 1419, 104, 105, 106, 107, 1144, 1145, 1425, 
  2115, 2106, 2107, 2116, 2117, 893, 37, 38, 2118, 2119, 2120, 2121, 2122, 2123, 2124, 2125, 2126, 2127, 2128, 2129, 2130, 2131, 2132, 2133, 
  2134, 2135, 2136, 2137, 2138, 2139, 2140, 2141, 2118, 2119, 2120, 2121, 2122, 2123, 2124, 2125, 2126, 2127, 2128, 2129, 2130, 2131, 2132, 2133, 
  2134, 2135, 2136, 2137, 2138, 2139, 2140, 2141, 2142, 2143, 2144, 2145, 2146, 2147, 2148, 2149, 2150, 2131, 2132, 2133, 2134, 2151, 2152, 2153, 
  2154, 2155, 80, 81, 82, 83, 2156, 2157, 2158, 159, 457, 161, 93, 258, 163, 212, 34, 92, 93, 214, 165, 215, 216, 217, 
  105, 106, 110, 0, 318, 767, 408, 408, 2159, 2160, 2161, 42, 719, 413, 2162, 2163, 47, 48, 49, 2164, 51, 52, 2161, 54, 
  719, 413, 2162, 57, 2165, 59, 60, 2166, 2159, 2160, 2161, 42, 719, 413, 2162, 2163, 47, 48, 49, 2164, 420, 421, 2167, 423, 
  719, 424, 425, 2168, 427, 428, 429, 2169, 2170, 2171, 2172, 2173, 2174, 2175, 2176, 69, 2177, 71, 2178, 73, 2179, 75, 2180, 2181, 
  2182, 2183, 2184, 2185, 2186, 1918, 33, 581, 210, 880, 881, 34, 92, 2103, 2187, 2188, 2111, 2189, 165, 2190, 2191, 1417, 1418, 1419, 
  104, 105, 106, 107, 1426, 2192, 109, 110, 1, 2193, 2193, 2194, 2195, 58, 2194, 2196, 318, 2197, 2198, 2199, 2199, 884, 2194, 2195, 
  58, 2194, 2196, 318, 2197, 2198, 2193, 2193, 1, 113, 113, 2200, 2201, 2202, 2203, 2204, 2205, 2206, 2207, 2208, 2209, 2210, 2211, 2212, 
  2213, 495, 2214, 2204, 2215, 2216, 2207, 2217, 428, 2218, 2219, 2200, 2201, 2202, 2203, 2204, 2205, 2206, 2207, 2208, 2209, 2210, 2211, 2212, 
  2213, 495, 2214, 2204, 2215, 2216, 2207, 2217, 428, 2218, 2219, 2220, 2221, 2222, 2223, 435, 2224, 2225, 442, 2226, 2227, 2228, 2229, 2230, 
  2231, 2232, 2233, 2234, 2235, 2236, 2237, 2238, 2239, 2240, 2241, 2242, 2243, 160, 161, 162, 163, 163, 164, 34, 93, 94, 165, 166, 
  100, 101, 102, 105, 106, 108, 109, 110, 168, 37, 37, 1013, 1014, 1015, 1016, 2244, 1018, 1019, 1020, 2245, 2246, 1032, 1024, 2247, 
  2248, 1015, 1016, 2244, 1018, 1019, 2249, 2250, 2251, 2252, 2253, 1013, 1014, 1015, 1016, 2244, 1018, 1019, 1020, 2245, 2246, 1032, 1024, 2247, 
  2248, 1015, 1016, 2244, 1018, 1019, 2249, 2250, 2251, 2252, 2253, 2254, 1034, 1035, 1036, 2255, 1038, 2256, 2257, 2258, 1334, 1335, 2259, 2260, 
  2261, 2262, 2263, 2264, 2265, 2266, 2267, 2268, 2269, 2270, 2271, 2272, 2273, 2274, 2275, 2276, 209, 259, 260, 261, 262, 210, 163, 529, 
  34, 92, 2276, 2277, 2278, 2279, 165, 166, 533, 101, 534, 103, 105, 106, 108, 0, 318, 767, 408, 408, 2280, 2281, 2282, 2283, 
  2284, 2285, 2286, 2287, 2288, 2289, 2290, 2291, 2069, 2070, 2292, 2072, 2293, 2073, 1543, 2294, 2075, 2076, 2295, 2077, 1359, 1360, 2296, 2297, 
  1362, 2298, 2299, 2300, 2065, 2066, 2301, 2068, 1370, 471, 2302, 549, 1362, 1371, 1372, 2303, 1374, 554, 1118, 1376, 2304, 2305, 2306, 2307, 
  2308, 2309, 1901, 786, 2310, 2311, 2312, 2313, 2314, 2315, 2316, 2317, 2318, 2319, 2320, 2321, 2322, 2323, 1913, 2324, 2325, 2326, 2186, 1918, 
  880, 2327, 326, 327, 328, 329, 880, 881, 34, 883, 2103, 2187, 2110, 2111, 2189, 887, 2190, 2191, 1417, 1418, 1419, 104, 105, 106, 
  107, 1425, 1426, 328, 2328, 2329, 109, 110, 0, 1, 767, 408, 408, 2330, 2331, 2332, 2333, 2334, 2335, 2336, 2337, 2338, 2339, 2340, 
  2341, 2342, 2343, 2344, 2345, 2346, 2347, 2348, 2349, 2350, 474, 2351, 2352, 2330, 2331, 2332, 2333, 2334, 2335, 2336, 2337, 2338, 2339, 2340, 
  2341, 2342, 2343, 2344, 2345, 2346, 2347, 2348, 2349, 2350, 474, 2351, 2352, 2353, 2354, 2355, 2356, 2357, 2358, 2359, 2360, 2361, 2362, 2363, 
  2364, 2365, 2366, 2367, 2368, 2369, 2370, 2371, 2372, 2373, 2374, 2375, 2376, 2377, 2378, 160, 161, 93, 163, 163, 164, 34, 93, 94, 
  165, 166, 100, 101, 102, 105, 106, 108, 109, 110, 168, 0, 1, 408, 408, 2379, 2380, 2381, 2382, 2383, 2384, 2385, 2207, 2386, 
  2387, 2388, 2389, 2390, 2391, 2392, 2393, 2204, 2394, 2395, 2207, 2396, 2397, 2398, 2399, 2379, 2380, 2381, 2382, 2383, 2384, 2385, 2207, 2386, 
  2387, 2388, 2389, 2390, 2391, 2392, 2393, 2204, 2394, 2395, 2207, 2396, 2397, 2398, 2399, 2400, 2401, 2402, 2403, 2404, 2405, 2406, 2407, 2408, 
  2409, 2228, 2410, 2411, 2412, 2413, 2414, 160, 161, 93, 163, 163, 164, 34, 93, 94, 165, 166, 100, 101, 102, 105, 106, 108, 
  109, 110, 168, 2415, 1185, 1185, 2416, 2417, 2418, 2419, 2420, 2421, 2422, 2423, 2424, 2425, 2426, 2427, 2428, 2429, 2430, 2431, 2432, 2433, 
  2434, 2435, 2436, 2437, 2438, 2439, 2440, 2441, 2442, 2443, 2444, 2445, 2446, 2447, 2448, 2449, 2450, 2451, 1205, 1206, 1207, 1208, 1209, 1210, 
  1211, 1212, 1213, 1214, 1215, 1216, 1230, 1231, 1232, 1233, 1234, 1235, 1229, 2452, 2453, 2454, 2455, 2456, 2457, 2458, 2459, 2460, 2461, 2462, 
  2463, 2464, 2465, 2466, 2467, 2468, 2469, 2470, 2471, 2472, 2473, 2474, 2475, 2476, 2477, 2478, 2479, 2480, 2481, 2482, 2483, 2484, 2485, 2486, 
  2487, 167, 2488, 2489, 37, 38, 2490, 2491, 2492, 2493, 2494, 2495, 2496, 2497, 2498, 2499, 2500, 2501, 2502, 2503, 2504, 2133, 2505, 2506, 
  2507, 2508, 2509, 2139, 2140, 2510, 2490, 2491, 2492, 2493, 2494, 2495, 2496, 2497, 2498, 2499, 2500, 2501, 2502, 2503, 2504, 2133, 2505, 2506, 
  2507, 2508, 2509, 2139, 2140, 2510, 2511, 2512, 2513, 2514, 2515, 2516, 2517, 2518, 2519, 2520, 2521, 2522, 2523, 2524, 2525, 2526, 2527, 2528, 
  80, 81, 82, 83, 2529, 2530, 2531, 2532, 457, 161, 93, 258, 163, 212, 34, 92, 93, 214, 165, 215, 216, 217, 105, 106, 
  110, 37, 38, 2533, 2534, 2535, 2536, 2537, 2538, 2539, 2540, 2541, 2542, 2543, 2544, 2545, 2546, 2547, 2548, 2549, 2550, 2551, 2552, 2553, 
  2554, 2555, 2556, 2533, 2534, 2535, 2536, 2537, 2538, 2539, 2540, 2541, 2542, 2543, 2544, 2545, 2546, 2547, 2548, 2549, 2550, 2551, 2552, 2553, 
  2554, 2555, 2556, 2557, 2558, 2559, 2560, 2561, 2562, 2563, 2564, 2565, 2566, 2567, 2568, 2569, 2570, 2571, 2572, 2573, 2574, 2575, 2576, 2577, 
  2578, 2579, 2580, 2581, 2582, 2583, 2584, 2585, 1679, 2586, 2587, 2588, 2589, 2590, 1095, 212, 34, 92, 2585, 214, 2591, 2592, 165, 215, 
  216, 2593, 2594, 2595, 104, 105, 106, 107, 108, 2588, 2589, 2596, 2597, 343, 344, 345, 346, 0, 318, 408, 408, 2598, 2599, 2600, 
  2601, 2602, 2603, 2604, 2605, 2606, 2607, 2608, 2609, 2610, 2611, 2612, 2613, 2614, 2615, 2616, 2617, 2618, 2619, 2620, 2621, 2622, 2623, 2624, 
  2625, 2626, 2627, 2628, 2629, 2630, 2631, 2632, 2633, 2610, 2611, 2634, 2613, 2635, 2636, 2637, 2638, 2618, 2619, 2639, 2621, 2640, 2641, 2642, 
  2643, 2644, 2645, 2646, 2647, 2648, 2649, 2650, 2651, 2652, 2653, 2654, 2655, 2656, 2657, 2658, 2659, 2660, 2661, 2662, 2663, 2664, 2665, 160, 
  161, 93, 209, 111, 112, 109, 110, 210, 163, 164, 34, 883, 93, 94, 266, 311, 1303, 165, 166, 100, 101, 102, 103, 1577, 
  105, 106, 107, 1145, 108, 109, 110, 2666, 2667, 2668, 2669, 2670, 2671, 37, 38, 2672, 2673, 2674, 42, 497, 2675, 2676, 2163, 47, 
  2677, 49, 2678, 420, 421, 495, 423, 497, 424, 425, 2168, 427, 2679, 429, 430, 2672, 2673, 2674, 42, 497, 2675, 2676, 2163, 47, 
  2677, 49, 2678, 420, 421, 495, 423, 497, 424, 425, 2168, 427, 2679, 429, 430, 2680, 2681, 2682, 2683, 2684, 2685, 2686, 2687, 2688, 
  2689, 2690, 909, 759, 1677, 1678, 213, 1679, 111, 112, 109, 110, 210, 1095, 212, 34, 92, 213, 214, 1097, 1680, 1681, 165, 215, 
  216, 217, 104, 105, 106, 107, 167, 109, 110, 2691, 2691, 756, 757, 457, 161, 93, 258, 258, 2692, 93, 531, 1302, 311, 532, 
  1304, 1305, 2693, 101, 534, 103, 108, 408, 408, 343, 344, 345, 346, 457, 161, 93, 258, 258, 2692, 93, 531, 311, 532, 1304, 
  1305, 2693, 101, 534, 103, 108, 343, 344, 345, 346, 0, 318, 767, 2193, 2193, 209, 1301, 94, 166, 1306, 102, 0, 318, 90, 
  2063, 163, 529, 166, 533, 343, 344, 345, 346, 2694, 89, 90, 2063, 343, 344, 345, 346, 90, 2695, 96, 2696, 2697, 2698, 2694, 
  89, 2699, 2063, 343, 344, 345, 346, 90, 2695, 2697, 2698, 2700, 2701, 2702, 2702, 2703, 2704, 2705, 2706, 108, 343, 344, 345, 346, 
  2197, 2199, 2199, 33, 33, 2707, 2708, 586, 587, 588, 343, 344, 345, 346, 343, 344, 345, 346, 343, 344, 345, 346, 0, 1, 
  0, 318, 767, 343, 344, 345, 346, 0, 318, 767, 2104, 2105, 2106, 2107, 2106, 2107, 2116, 2117, 893, 0, 1, 0, 318, 0, 
  1, 767, 2709, 2710, 2711, 2712, 2711, 2712, 2116, 2117, 893, 343, 344, 345, 346, 0, 1040, 343, 344, 345, 346, 1306, 102, 0, 
  1040, 343, 344, 345, 346, 343, 344, 345, 346, 343, 344, 345, 346, 163, 163, 0, 1, 0, 318, 2104, 2105, 2106, 2107, 2106, 
  2107, 2116, 2117, 893, 160, 343, 344, 345, 346, 163, 529, 94, 166, 533, 326, 327, 328, 329, 328, 329, 271, 343, 344, 345, 
  346, 357, 1185, 2713, 758, 2063, 163, 529, 166, 533, 343, 344, 345, 346, 0, 318, 343, 344, 345, 346, 2714, 326, 327, 328, 
  329, 2714, 2715, 2716, 1304, 328, 329, 271, 343, 344, 345, 346, 0, 1, 0, 1, 343, 344, 345, 346, 343, 344, 345, 346, 
  89, 90, 343, 344, 345, 346, 90, 2695, 2697, 343, 344, 345, 346, 2193, 2193, 160, 406, 2717, 343, 344, 345, 346, 2718, 343, 
  344, 345, 346, 343, 344, 345, 346, 0, 318, 1042, 2719, 0, 1, 767, 343, 344, 345, 346, 343, 344, 345, 346, 2720, 166, 
  2699, 0, 318, 957, 343, 344, 345, 346, 0, 1, 957, 0, 318, 957, 343, 344, 345, 346, 343, 344, 345, 346, 0, 1, 
  767, 2702, 2702, 2703, 2704, 209, 343, 344, 345, 346, 0, 318, 957, 0, 1, 957, 343, 344, 345, 346, 343, 344, 345, 346, 
  343, 344, 345, 346, 343, 344, 345, 346, 0, 1, 343, 344, 345, 346, 0, 1, 2694, 89, 90, 2714, 343, 344, 345, 346, 
  2714, 2715, 90, 2695, 2721, 2722, 2697, 2698, 343, 344, 345, 346, 2694, 89, 2723, 163, 343, 344, 345, 346, 163, 529, 2724, 2725, 
  166, 533, 2697, 2698, 0, 1040, 2726, 2727, 2728, 2729, 2730, 2731, 2732, 2733, 2734, 2735, 2736, 2737, 2738, 2739, 420, 421, 495, 423, 
  2740, 424, 425, 2741, 427, 428, 429, 430, 2728, 2729, 2730, 2731, 2732, 2733, 2734, 2735, 2736, 2737, 2738, 2739, 420, 421, 495, 423, 
  2740, 424, 425, 2741, 427, 428, 429, 430, 2742, 2743, 2744, 2745, 2746, 2747, 2748, 2342, 2749, 2750, 2751, 2752, 2753, 2754, 2755, 2756, 
  2757, 2758, 2759, 2760, 2761, 2762, 2763, 2764, 2765, 2766, 2767, 161, 93, 210, 2703, 34, 92, 93, 531, 95, 311, 532, 2706, 101, 
  534, 103, 104, 105, 535, 107, 1145, 2768, 109, 110, 0, 318, 767, 408, 408, 2769, 2770, 2771, 485, 2772, 2773, 2774, 2775, 2776, 
  1537, 2777, 2778, 2779, 471, 472, 473, 474, 1371, 1372, 477, 2780, 2781, 1375, 2782, 2769, 2770, 2771, 485, 2772, 2773, 2774, 2775, 2776, 
  1537, 2777, 2778, 2779, 471, 472, 473, 474, 1371, 1372, 477, 2780, 2781, 1375, 2782, 2783, 2784, 506, 507, 2785, 2786, 2787, 511, 2788, 
  472, 513, 2789, 515, 516, 2790, 2791, 2792, 2793, 2794, 2795, 2796, 2797, 1399, 1400, 2798, 2799, 2800, 2801, 93, 209, 1571, 327, 328, 
  329, 210, 163, 529, 34, 2802, 93, 531, 2803, 311, 532, 165, 166, 533, 101, 534, 2804, 104, 105, 535, 107, 108, 328, 329, 
  271, 109, 110, 318, 0, 2198, 37, 37, 1374, 1374, 2805, 2806, 2700, 2701, 2807, 526, 111, 112, 109, 110, 164, 2808, 2809, 345, 
  346, 2810, 0, 318, 2193, 2719, 2790, 2792, 1399, 1400, 343, 344, 345, 346, 529, 2811, 311, 2812, 2813, 2814, 2815, 0, 318, 1399, 
  1400, 2816, 343, 344, 345, 346, 343, 344, 345, 346, 0, 318, 2817, 2817, 2818, 2070, 2071, 1542, 2819, 2073, 1543, 2820, 2821, 1546, 
  1547, 2822, 1399, 1400, 406, 2823, 343, 344, 345, 346, 406, 2824, 311, 98, 99, 2825, 0, 318, 2193, 2193, 2818, 2070, 2071, 1542, 
  2819, 2073, 1543, 2820, 2821, 1546, 1547, 2822, 1399, 1400, 2720, 2826, 2827, 2828, 2811, 2829, 2830, 2831, 2832, 328, 329, 271, 0, 1, 
  1399, 1400, 38, 2833, 2834, 2835, 2836, 1399, 1400, 2816, 0, 318, 2817, 2817, 1399, 1400, 37, 37, 1399, 1400, 2720, 2826, 1399, 1400, 
  2837, 2838, 2063, 529, 2839, 311, 2840, 105, 1399, 1400, 2841, 2842, 2843, 1399, 1400, 2844, 2845, 2844, 2846, 1304, 2721, 2722, 2193, 2193, 
  490, 2818, 2070, 2071, 1542, 2819, 2073, 1543, 2820, 1545, 1546, 1547, 2822, 1645, 2847, 2848, 1648, 1649, 2733, 2734, 1652, 2849, 2850, 2851, 
  2852, 2853, 52, 2854, 2855, 2856, 55, 56, 2857, 2858, 2859, 60, 2860, 1399, 1400, 2826, 111, 112, 109, 110, 1399, 1400, 2844, 2845, 
  2844, 2846, 1304, 2721, 2722, 0, 318, 1042, 1042, 2818, 2070, 2071, 1542, 2819, 2073, 1543, 2820, 2821, 1546, 1547, 2822, 1399, 1400, 343, 
  344, 345, 346, 1399, 1400, 517, 519, 163, 529, 2839, 311, 2831, 105, 0, 318, 2193, 2719, 490, 2818, 2070, 2071, 1542, 2819, 2073, 
  1543, 2820, 1545, 1546, 1547, 2822, 1645, 2847, 2848, 1648, 1649, 2733, 2734, 1652, 2849, 2850, 2851, 2852, 2853, 52, 2854, 2855, 2856, 55, 
  56, 2857, 2858, 2859, 60, 2860, 1399, 1400, 343, 344, 345, 346, 0, 318, 2817, 2817, 2818, 2070, 2071, 1542, 2819, 2073, 1543, 2820, 
  2821, 1546, 1547, 2822, 517, 2861, 519, 2862, 1399, 1400, 0, 1, 408, 957, 2863, 2864, 2865, 2866, 2867, 2868, 2869, 1365, 2065, 2870, 
  2067, 2871, 2872, 2873, 2865, 549, 2867, 2868, 2869, 1373, 2780, 554, 1375, 2874, 2863, 2864, 2865, 2866, 2867, 2868, 2869, 1365, 2065, 2870, 
  2067, 2871, 2872, 2873, 2865, 549, 2867, 2868, 2869, 1373, 2780, 554, 1375, 2874, 2875, 2876, 2877, 2878, 2879, 2880, 2881, 2882, 2883, 2884, 
  2885, 2886, 2887, 2888, 2092, 2093, 2094, 2095, 80, 81, 82, 83, 2889, 2890, 2186, 1918, 2103, 581, 880, 881, 34, 92, 2103, 2891, 
  2892, 2111, 2893, 887, 888, 889, 1417, 1418, 1419, 104, 105, 106, 107, 1144, 1145, 1006, 109, 110, 0, 318, 2894, 408, 957, 2895, 
  2896, 2897, 2898, 2899, 2900, 2901, 2902, 2903, 2904, 2905, 2906, 2907, 2908, 2071, 2909, 2910, 2911, 2912, 2913, 2914, 2915, 2916, 2917, 2895, 
  2896, 2897, 2898, 2899, 2900, 2901, 2902, 2903, 2904, 2905, 2906, 2907, 2908, 2071, 2909, 2910, 2911, 2912, 2913, 2914, 2915, 2916, 2917, 2918, 
  2919, 2920, 2921, 2922, 2923, 2924, 2925, 2926, 2927, 2928, 2929, 2930, 2931, 2932, 2933, 2934, 2935, 2936, 2937, 2938, 2939, 2940, 2941, 2942, 
  2943, 2944, 2945, 1996, 1997, 2946, 211, 2947, 2948, 2949, 2950, 2951, 2952, 2953, 2954, 215, 2955, 2956, 2957, 2958, 2959, 2960, 2961, 109, 
  110, 0, 1, 408, 408, 2962, 2963, 2964, 2965, 2966, 2967, 2968, 2969, 2970, 2971, 2972, 2973, 2974, 2975, 2976, 2977, 2978, 2979, 2980, 
  2981, 2982, 2983, 2984, 2985, 2962, 2963, 2964, 2965, 2966, 2967, 2968, 2969, 2970, 2971, 2972, 2973, 2974, 2975, 2976, 2977, 2978, 2979, 2980, 
  2981, 2982, 2983, 2984, 2985, 2986, 2987, 2988, 2989, 2990, 2991, 2992, 2993, 2994, 2995, 2996, 2997, 2998, 2999, 3000, 3001, 3002, 3003, 3004, 
  3005, 3006, 3007, 3008, 3009, 3010, 3011, 160, 161, 93, 163, 163, 164, 34, 93, 94, 165, 166, 100, 101, 102, 105, 106, 167, 
  109, 110, 168, 3012, 957, 3013, 3014, 280, 3015, 3016, 3017, 3018, 3019, 3020, 3021, 3022, 3023, 3013, 3014, 280, 3015, 3016, 3017, 3018, 
  3019, 3020, 3021, 3022, 3023, 3013, 3014, 280, 3015, 3016, 3017, 3018, 3019, 3020, 3021, 3022, 3023, 3013, 3014, 280, 3015, 3016, 3017, 3018, 
  3019, 3020, 3021, 3022, 3023, 3024, 3025, 3026, 3027, 3028, 3029, 3030, 3024, 3025, 3026, 3027, 3028, 3029, 3030, 3031, 3032, 3033, 3034, 3035, 
  3036, 3037, 3038, 3039, 3040, 3041, 3042, 160, 161, 93, 211, 1571, 3043, 328, 329, 3044, 211, 3045, 34, 92, 93, 94, 3046, 311, 
  1303, 2954, 215, 3047, 3048, 3049, 3050, 104, 106, 106, 107, 108, 328, 329, 271, 168, 2193, 3051, 3052, 3053, 3054, 3055, 3056, 3057, 
  3058, 3059, 3060, 3061, 3062, 3063, 3064, 3053, 3054, 3055, 3056, 3057, 3065, 3059, 3060, 3061, 3062, 3066, 3052, 3053, 3054, 3055, 3056, 3057, 
  3058, 3059, 3060, 3061, 3062, 3063, 3052, 3053, 3054, 3055, 3056, 3057, 3058, 3059, 3060, 3061, 3062, 3063, 3067, 3068, 3069, 3070, 3071, 3072, 
  3073, 3074, 1095, 212, 213, 214, 1680, 1681, 165, 216, 3075, 217, 3076, 105, 167, 345, 346, 2810, 0, 1, 408, 408, 3077, 3078, 
  3079, 3080, 3081, 3082, 3083, 3084, 3085, 3086, 3087, 3088, 3089, 3090, 3091, 130, 3092, 3093, 3094, 3095, 3096, 3097, 3098, 3099, 3077, 3078, 
  3079, 3080, 3081, 3082, 3083, 3084, 3085, 3086, 3087, 3088, 3089, 3090, 3091, 130, 3092, 3093, 3094, 3095, 3096, 3097, 3098, 3099, 3100, 3101, 
  3102, 3103, 3104, 3105, 3106, 3107, 3108, 3109, 786, 3110, 3111, 3112, 3113, 3114, 3115, 3116, 2794, 2795, 2796, 2797, 3117, 3118, 3119, 3120, 
  160, 161, 162, 163, 164, 34, 92, 93, 94, 165, 166, 101, 102, 103, 105, 106, 1144, 1145, 168, 3121, 3122, 3123, 3124, 3125, 
  3126, 3127, 3128, 3129, 3130, 3131, 3132, 3133, 3122, 3123, 3124, 3125, 3126, 3127, 3128, 3129, 3130, 3131, 3132, 3133, 3122, 3123, 3124, 3125, 
  3126, 3127, 3128, 3129, 3130, 3131, 3132, 3133, 3134, 3135, 3136, 3137, 3138, 3139, 3140, 3141, 3142, 3143, 3144, 3145, 3146, 3147, 3148, 3149, 
  3150, 3151, 3152, 3153, 3154, 3155, 3156, 3157, 3158, 3159, 3160, 3161, 3162, 3163, 3160, 3161, 3162, 3163, 3164, 3165, 3166, 3167, 3168, 3169, 
  3170, 401, 401, 3171, 34, 92, 3170, 3172, 3173, 3174, 3175, 2813, 3176, 2814, 101, 102, 103, 104, 105, 106, 107, 108, 259, 260, 
  261, 262, 259, 260, 261, 262, 259, 260, 261, 262, 259, 260, 261, 262, 259, 260, 261, 262, 111, 112, 109, 110, 111, 112, 
  109, 110, 111, 112, 109, 110, 111, 112, 109, 110, 111, 112, 109, 110, 0, 1, 767, 408, 408, 3177, 3178, 3179, 3180, 3181, 
  3182, 3183, 3184, 3185, 3186, 3187, 3188, 3189, 3190, 3191, 3192, 3193, 3194, 3195, 3196, 3197, 3198, 3199, 3200, 3201, 3202, 3203, 3204, 3205, 
  3206, 3207, 3208, 3209, 3210, 3211, 3212, 3189, 3190, 3191, 3192, 3193, 3194, 3195, 3196, 3197, 3198, 3199, 3200, 3213, 3214, 3215, 3216, 3217, 
  3218, 3219, 3220, 2750, 3221, 3222, 3223, 3224, 1060, 3225, 3226, 3227, 3228, 3229, 3230, 3231, 3232, 3233, 3234, 3235, 3236, 3237, 1918, 880, 
  880, 2709, 2710, 2711, 2712, 880, 2108, 882, 883, 880, 2108, 2708, 2708, 3238, 3239, 2190, 3240, 2190, 3241, 1419, 1577, 105, 106, 107, 
  1927, 2711, 2712, 271, 2116, 2117, 3242, 37, 38, 1645, 1646, 1647, 1648, 1649, 1650, 1651, 1652, 3243, 1654, 1655, 1656, 1657, 1658, 495, 
  496, 497, 1659, 1660, 426, 500, 428, 1661, 899, 1645, 1646, 1647, 1648, 1649, 1650, 1651, 1652, 3243, 1654, 1655, 1656, 1657, 1658, 495, 
  496, 497, 1659, 1660, 426, 500, 428, 1661, 899, 3244, 1663, 1664, 1665, 1666, 1667, 1668, 3245, 1280, 495, 1670, 1671, 1672, 928, 3246, 
  3247, 3248, 3249, 909, 759, 1677, 1678, 213, 1679, 111, 112, 109, 110, 210, 1095, 212, 34, 92, 213, 214, 1097, 1680, 1681, 165, 
  215, 216, 217, 104, 105, 106, 107, 167, 109, 110, 0, 318, 767, 408, 957, 1359, 1360, 3250, 3251, 2867, 1363, 1364, 1365, 2065, 
  2066, 2067, 3252, 2069, 2070, 2071, 2072, 2867, 2073, 1543, 2074, 2075, 2076, 1547, 1548, 1359, 1360, 3250, 3251, 2867, 1363, 1364, 1365, 2065, 
  2066, 2067, 3252, 1370, 471, 472, 549, 2867, 1371, 1372, 1373, 1374, 554, 1375, 1119, 3253, 3254, 3255, 3256, 3257, 3258, 3259, 3260, 3261, 
  3262, 3263, 3264, 3265, 3266, 3267, 3268, 3269, 3270, 3271, 3272, 3273, 3274, 2100, 2101, 2186, 1918, 33, 581, 210, 33, 3275, 34, 92, 
  2103, 2109, 2188, 2111, 2112, 586, 587, 3276, 1417, 2114, 1419, 104, 3277, 3278, 107, 3279, 1425, 1927, 109, 110, 0, 1040, 767, 408, 
  957, 3280, 3281, 3250, 3282, 2867, 3283, 3284, 3285, 3286, 3287, 1538, 3288, 3289, 3290, 3250, 3291, 2867, 3283, 3292, 3285, 2821, 1546, 1547, 
  3293, 3280, 3281, 3250, 3282, 2867, 3283, 3284, 3285, 3286, 3287, 1538, 3288, 3289, 3290, 3250, 3291, 2867, 3283, 3292, 3285, 2821, 1546, 1547, 
  3293, 3294, 3295, 3296, 3297, 3298, 3299, 3300, 3301, 3302, 2071, 3303, 3304, 3305, 3306, 517, 3307, 3308, 3309, 2794, 2795, 2796, 2797, 3310, 
  3311, 160, 161, 93, 258, 210, 258, 1301, 34, 92, 93, 94, 3312, 311, 1303, 1304, 1305, 1306, 101, 102, 103, 104, 105, 106, 
  107, 108, 109, 110, 2826, 3313, 1, 3314, 3314, 2700, 2701, 2702, 3315, 3316, 3317, 3318, 2702, 91, 3319, 2704, 2705, 3320, 3317, 3318, 
  3321, 3322, 3323, 3324, 2197, 2198, 457, 581, 3325, 33, 2707, 586, 1479, 1480, 3326, 3327, 3328, 766, 3329, 111, 112, 109, 110, 111, 
  112, 109, 110, 318, 318, 2069, 3330, 2071, 3331, 2069, 3330, 2071, 3331, 3332, 3333, 3334, 3335, 111, 112, 109, 110, 318, 0, 111, 
  112, 109, 110, 111, 112, 109, 110, 111, 112, 109, 110, 111, 112, 109, 110, 0, 318, 3336, 3337, 3338, 3339, 719, 3340, 3341, 
  3342, 3343, 3344, 2388, 3345, 3346, 3347, 495, 3348, 719, 3349, 3341, 3350, 500, 3351, 429, 3352, 3336, 3337, 3338, 3339, 719, 3340, 3341, 
  3342, 3343, 3344, 2388, 3345, 3346, 3347, 495, 3348, 719, 3349, 3341, 3350, 500, 3351, 429, 3352, 3353, 3354, 3355, 3356, 3357, 3358, 3359, 
  511, 2788, 472, 3360, 3361, 3362, 3363, 3364, 3365, 3366, 3367, 2794, 2795, 2796, 2797, 3368, 3369, 3370, 3371, 3372, 3373, 258, 2063, 529, 
  34, 3374, 94, 165, 166, 100, 101, 102, 3375, 105, 106, 167, 329, 0, 318, 3376, 2719, 3377, 3378, 41, 42, 3379, 3380, 2676, 
  46, 3381, 48, 3382, 3383, 420, 421, 3384, 423, 719, 424, 425, 2168, 427, 428, 429, 3385, 3377, 3378, 41, 42, 3379, 3380, 2676, 
  46, 3381, 48, 3382, 3383, 420, 421, 3384, 423, 719, 424, 425, 2168, 427, 428, 429, 3385, 3386, 3387, 3388, 3389, 3390, 3391, 3392, 
  3393, 3394, 3221, 3395, 3223, 3396, 1908, 3397, 3398, 3399, 3400, 80, 81, 82, 83, 2100, 3401, 160, 161, 93, 2823, 401, 3402, 34, 
  92, 93, 94, 311, 1303, 2813, 3176, 2814, 101, 102, 103, 104, 105, 106, 109, 110, 37, 38, 3403, 3404, 3405, 3406, 3407, 3408, 
  3409, 3410, 3411, 3412, 3413, 3414, 3415, 3416, 3405, 3417, 3418, 3419, 3409, 3420, 3421, 3422, 3423, 3424, 3403, 3404, 3405, 3406, 3407, 3408, 
  3409, 3410, 3411, 3412, 3413, 3414, 3415, 3416, 3405, 3417, 3418, 3419, 3409, 3420, 3421, 3422, 3423, 3424, 3425, 3426, 3427, 3428, 3429, 3430, 
  3431, 3432, 3433, 3434, 3435, 3436, 3437, 3438, 3439, 3440, 3441, 3442, 449, 450, 451, 452, 3443, 3444, 3445, 759, 160, 161, 93, 209, 
  258, 1301, 34, 92, 93, 94, 3312, 311, 1303, 1304, 1305, 1306, 101, 102, 103, 104, 105, 106, 107, 3279, 108, 109, 110, 3446, 
  3447, 3448, 3449, 3450, 3451, 3452, 3453, 3454, 3455, 3456, 3457, 3446, 3447, 3448, 3449, 3450, 3451, 3452, 3453, 3454, 3455, 3456, 3457, 3446, 
  3447, 3448, 3449, 3450, 3451, 3452, 3453, 3454, 3455, 3456, 3457, 3446, 3447, 3448, 3449, 3450, 3451, 3452, 3453, 3454, 3455, 3456, 3457, 3458, 
  3459, 3460, 3461, 3462, 3463, 3464, 3458, 3459, 3460, 3461, 3462, 3463, 3464, 111, 112, 109, 110, 1095, 213, 37, 38, 3465, 3466, 3467, 
  3468, 3469, 3470, 3471, 3472, 3473, 3474, 3475, 3476, 3477, 3478, 3479, 3480, 3481, 3482, 3483, 3484, 3485, 3486, 3423, 3487, 3488, 3489, 3490, 
  3491, 3492, 3493, 3494, 3495, 3496, 3497, 3498, 3499, 3477, 3478, 3479, 3480, 3481, 3482, 3483, 3484, 3485, 3486, 3423, 3487, 3500, 3501, 3502, 
  3503, 3504, 3505, 3506, 3507, 3508, 3509, 3510, 3511, 3512, 3513, 3514, 3515, 3516, 3517, 3518, 3519, 3520, 3521, 3522, 3523, 3445, 759, 3524, 
  3525, 3526, 258, 163, 529, 3527, 883, 93, 531, 2803, 311, 532, 3528, 166, 533, 101, 534, 3529, 1577, 105, 106, 107, 1006, 109, 
  3530, 3531, 0, 1, 767, 408, 957, 3532, 3533, 2771, 485, 3534, 3535, 3536, 2775, 3537, 3538, 3539, 3540, 3541, 2070, 2071, 1542, 3534, 
  3535, 3542, 2820, 1545, 3543, 1547, 2077, 3532, 3533, 2771, 485, 3534, 3535, 3536, 2775, 3537, 3538, 3539, 3540, 3541, 2070, 2071, 1542, 3534, 
  3535, 3542, 2820, 1545, 3543, 1547, 2077, 2783, 3544, 506, 3545, 3546, 3547, 2787, 3548, 3544, 2071, 3549, 3550, 3305, 3551, 2805, 2791, 2806, 
  2793, 2794, 2795, 2796, 2797, 2700, 2701, 2807, 526, 2800, 2801, 2811, 2063, 210, 163, 529, 2828, 2802, 2811, 3552, 266, 2808, 2812, 165, 
  166, 533, 2830, 2831, 2804, 2832, 105, 535, 107, 108, 109, 110, 2197, 767, 408, 408, 2159, 2160, 2161, 42, 719, 413, 2162, 3553, 
  3554, 3555, 3556, 3557, 420, 421, 2167, 423, 719, 424, 425, 2168, 427, 428, 429, 2169, 2159, 2160, 2161, 42, 719, 413, 2162, 3553, 
  3554, 3555, 3556, 3557, 420, 421, 2167, 423, 719, 424, 425, 2168, 427, 428, 429, 2169, 3558, 3559, 3560, 3561, 3562, 3563, 3564, 3565, 
  3566, 3567, 2178, 3568, 2179, 75, 2180, 2181, 2182, 2183, 3569, 3570, 2184, 2185, 2186, 1918, 33, 581, 2477, 34, 92, 2187, 2481, 2190, 
  2191, 1417, 2114, 1419, 105, 106, 1927, 271, 357, 1185, 1186, 3571, 3572, 3573, 3574, 3575, 3576, 3577, 3578, 3579, 3580, 3581, 3582, 3583, 
  3584, 3573, 3574, 3575, 3576, 3577, 3578, 3585, 3586, 3587, 3588, 3571, 3572, 3573, 3574, 3575, 3576, 3577, 3578, 3579, 3580, 3581, 3582, 3583, 
  3584, 3573, 3574, 3575, 3576, 3577, 3578, 3585, 3586, 3587, 3588, 3589, 3590, 3591, 3592, 3593, 3594, 3595, 3596, 3597, 3598, 3599, 3600, 3601, 
  3602, 3603, 3604, 3605, 3606, 3607, 3608, 1181, 400, 162, 209, 3609, 3610, 3611, 3612, 163, 529, 34, 92, 162, 1182, 3613, 3614, 165, 
  166, 533, 101, 534, 103, 3615, 108, 37, 38, 3616, 3617, 411, 3618, 43, 413, 3619, 415, 416, 3620, 3621, 896, 3622, 421, 422, 
  423, 43, 424, 3623, 3624, 427, 428, 1661, 899, 3616, 3617, 411, 3618, 43, 413, 3619, 415, 416, 3620, 3621, 896, 3622, 421, 422, 
  423, 43, 424, 3623, 3624, 427, 428, 1661, 899, 3625, 3626, 3627, 3628, 3629, 3630, 3631, 3632, 3633, 3634, 3635, 3636, 3637, 3638, 3639, 
  3640, 3641, 3642, 3643, 3644, 3645, 3646, 2392, 3647, 3648, 3649, 457, 161, 93, 258, 212, 34, 92, 214, 165, 215, 216, 217, 105, 
  106, 110, 37, 37, 3650, 3651, 3652, 3653, 3654, 3655, 3656, 3657, 3658, 3659, 3660, 3661, 3662, 3663, 3652, 3664, 3654, 3665, 3666, 3657, 
  3667, 3668, 3669, 3670, 3650, 3651, 3652, 3653, 3654, 3655, 3656, 3657, 3658, 3659, 3660, 3661, 3662, 3663, 3652, 3664, 3654, 3665, 3666, 3657, 
  3667, 3668, 3669, 3670, 3671, 3672, 3673, 3674, 3675, 3676, 3677, 3678, 3679, 3680, 3681, 3682, 3683, 3684, 2700, 2701, 3445, 759, 3685, 3686, 
  3687, 3688, 3689, 3690, 3691, 3692, 3693, 417, 3694, 3695, 420, 3696, 495, 3697, 497, 3698, 3699, 3700, 730, 428, 3701, 899, 3685, 3686, 
  3687, 3688, 3689, 3690, 3691, 3692, 3693, 417, 3694, 3695, 420, 3696, 495, 3697, 497, 3698, 3699, 3700, 730, 428, 3701, 899, 3702, 3703, 
  2402, 3704, 3705, 3706, 3707, 3708, 3709, 2409, 3710, 442, 2149, 3711, 3712, 3713, 3714, 3715, 80, 81, 82, 83, 3716, 3717, 3718, 3719, 
  3720, 400, 162, 209, 210, 212, 34, 92, 162, 2803, 165, 215, 216, 217, 105, 106, 1006, 109, 110, 111, 112, 109, 110, 37, 
  38, 3721, 3722, 3723, 3724, 43, 3725, 3726, 3727, 3728, 3729, 3730, 3731, 3732, 3733, 3734, 3735, 43, 3736, 3737, 3738, 3739, 3740, 3741, 
  3742, 3721, 3722, 3723, 3724, 43, 3725, 3726, 3727, 3728, 3729, 3730, 3731, 3732, 3733, 3734, 3735, 43, 3736, 3737, 3738, 3739, 3740, 3741, 
  3742, 3743, 3744, 3745, 3746, 3747, 3748, 3749, 3750, 3751, 3752, 3753, 3754, 3755, 3756, 457, 161, 93, 3757, 111, 112, 109, 110, 163, 
  529, 34, 93, 531, 311, 532, 165, 166, 533, 101, 534, 104, 107, 108, 109, 110, 3758, 3758, 3759, 3760, 3761, 3762, 3763, 3764, 
  3765, 3766, 3767, 3768, 3769, 3770, 3771, 3772, 3761, 3773, 3763, 3764, 3765, 3774, 3775, 3776, 3777, 3778, 3759, 3760, 3761, 3762, 3763, 3764, 
  3765, 3766, 3767, 3768, 3769, 3770, 3771, 3772, 3761, 3773, 3763, 3764, 3765, 3774, 3775, 3776, 3777, 3778, 3779, 3780, 3781, 3782, 3783, 3784, 
  3785, 3786, 3787, 3788, 3789, 3790, 3791, 3792, 3793, 3794, 3795, 3796, 3797, 3798, 3799, 3800, 3801, 880, 326, 327, 328, 329, 210, 880, 
  881, 34, 92, 3801, 3802, 2803, 3803, 3804, 887, 888, 889, 3805, 3806, 3807, 104, 105, 106, 107, 3808, 328, 329, 271, 3809, 357, 
  1185, 1185, 1013, 3810, 1015, 1016, 1017, 1018, 1019, 1020, 2245, 1022, 1032, 1024, 3811, 3812, 1015, 1016, 1017, 1018, 3813, 3814, 3815, 3816, 
  3817, 3818, 1013, 3810, 1015, 1016, 1017, 1018, 1019, 1020, 2245, 1022, 1032, 1024, 3811, 3812, 1015, 1016, 1017, 1018, 3813, 3814, 3815, 3816, 
  3817, 3818, 3819, 1026, 1027, 1028, 3820, 1030, 1031, 3821, 2258, 1334, 1335, 3822, 2260, 2261, 3823, 3824, 3825, 3826, 3827, 3828, 3829, 3830, 
  756, 757, 3831, 3832, 457, 161, 93, 209, 259, 260, 261, 262, 210, 163, 529, 34, 92, 93, 531, 3833, 311, 532, 165, 166, 
  533, 101, 534, 103, 3834, 105, 106, 107, 108, 1185, 427, 3835, 3836, 3837, 3838, 3839, 3840, 3841, 3842, 3843, 3844, 3845, 3846, 3847, 
  3848, 400, 2724, 258, 2718, 162, 0, 318, 767, 408, 408, 3849, 3850, 3851, 3852, 3853, 3854, 3855, 3856, 3857, 3858, 3859, 3860, 3861, 
  3862, 3863, 3864, 3865, 3866, 1879, 3867, 3868, 1882, 3869, 1883, 3870, 3871, 3872, 3873, 3874, 3875, 3876, 3877, 3878, 1893, 3879, 3880, 3861, 
  3862, 3863, 3864, 3865, 3866, 1879, 3867, 3868, 1882, 3869, 1883, 1377, 1378, 1379, 1380, 1381, 1382, 1383, 1384, 1385, 1386, 1387, 1388, 1389, 
  1390, 2092, 2093, 2094, 2095, 3881, 3882, 3883, 3884, 3885, 3886, 1403, 1404, 1405, 3887, 1996, 3887, 3888, 3889, 1409, 1405, 1410, 3890, 1412, 
  1413, 1414, 3891, 3892, 1417, 1418, 1419, 3893, 1421, 1422, 1423, 1424, 3894, 1425, 1426, 763, 764, 3895, 3896, 3897, 3898, 3899, 0, 318, 
  767, 408, 408, 2280, 2281, 2282, 2283, 3900, 2285, 2286, 2287, 2288, 2289, 2290, 2291, 2069, 2070, 2292, 2072, 3901, 2073, 1543, 2294, 2075, 
  2076, 2295, 2077, 1359, 1360, 2296, 2297, 3902, 2298, 2299, 2300, 2065, 2066, 2301, 2068, 1370, 471, 2302, 549, 3903, 1371, 1372, 2303, 1374, 
  554, 1118, 1376, 3904, 3905, 3906, 3907, 3908, 3909, 1901, 786, 2310, 3910, 2312, 3911, 3912, 2315, 2316, 2317, 2318, 2319, 2320, 2321, 2322, 
  2323, 1913, 3913, 3914, 3915, 2186, 1918, 880, 2327, 326, 327, 328, 3916, 880, 881, 34, 883, 2103, 2187, 2110, 2111, 2189, 887, 2190, 
  2191, 1417, 1418, 1419, 104, 105, 106, 107, 1425, 1426, 328, 3916, 3917, 109, 110, 0, 1, 408, 408, 3918, 3919, 3920, 3921, 3922, 
  3923, 3924, 3925, 3926, 3927, 2067, 2068, 2069, 1541, 3928, 3929, 3930, 3931, 3932, 2074, 3933, 2076, 1547, 2077, 3918, 3919, 3920, 3921, 3922, 
  3923, 3924, 3925, 3926, 3927, 2067, 2068, 2069, 1541, 3928, 3929, 3930, 3931, 3932, 2074, 3933, 2076, 1547, 2077, 3934, 3935, 3936, 3937, 3938, 
  3939, 3940, 3941, 271, 2885, 3942, 3943, 2882, 3944, 3945, 3946, 3947, 3948, 3949, 3950, 3951, 3952, 3953, 3954, 3955, 3956, 3957, 3958, 3959, 
  3960, 326, 327, 328, 329, 3960, 3961, 3962, 3963, 3959, 3964, 3965, 3966, 3967, 3968, 3969, 3970, 3971, 3972, 3973, 3974, 3975, 3976, 3977, 
  1424, 3978, 328, 329, 271, 2016, 2017, 2018, 0, 1, 408, 408, 3979, 3980, 3981, 3982, 3983, 3984, 3985, 3986, 3987, 3988, 3989, 3990, 
  3991, 3992, 3993, 3994, 3995, 3996, 3997, 3998, 3999, 4000, 4001, 4002, 4003, 4004, 4005, 4006, 4007, 4008, 4009, 4010, 4011, 4012, 4013, 4014, 
  3991, 3992, 3993, 3994, 3995, 3996, 3997, 3998, 3999, 4000, 4001, 4002, 4015, 4016, 4017, 4018, 4019, 4020, 4021, 4022, 4023, 4024, 4025, 4026, 
  4027, 4028, 4029, 4030, 4031, 4032, 4033, 4034, 4035, 4036, 4037, 4038, 4039, 4040, 4041, 581, 210, 33, 4042, 4043, 4044, 4041, 4045, 4046, 
  4047, 4048, 586, 587, 655, 101, 4049, 4050, 4051, 4052, 4053, 2014, 328, 329, 271, 0, 318, 2719, 4054, 4055, 4056, 1361, 3534, 2773, 
  2774, 4057, 3286, 3287, 1538, 4058, 1370, 471, 472, 549, 2867, 1371, 1372, 1373, 1374, 2781, 1375, 1376, 4054, 4055, 4056, 1361, 3534, 2773, 
  2774, 4057, 3286, 3287, 1538, 4058, 1370, 471, 472, 549, 2867, 1371, 1372, 1373, 1374, 2781, 1375, 1376, 4059, 4060, 4061, 4062, 4063, 4064, 
  4065, 511, 2788, 472, 4066, 4067, 4068, 3363, 4069, 4070, 4071, 4072, 2794, 2795, 2796, 2797, 4073, 4074, 4075, 4076, 93, 406, 210, 406, 
  2824, 34, 92, 93, 94, 4077, 311, 1303, 98, 99, 4078, 101, 102, 2804, 104, 105, 535, 107, 108, 109, 110, 0, 318, 37, 
  37, 409, 410, 4079, 42, 43, 413, 2162, 4080, 47, 48, 49, 50, 420, 421, 495, 423, 43, 424, 425, 3700, 427, 428, 429, 
  3385, 409, 410, 4079, 42, 43, 413, 2162, 4080, 47, 48, 49, 50, 420, 421, 495, 423, 43, 424, 425, 3700, 427, 428, 429, 
  3385, 4081, 4082, 4083, 4084, 4085, 4086, 4087, 4088, 4089, 4090, 4091, 4092, 2149, 928, 4093, 4094, 4095, 4096, 80, 81, 82, 83, 4097, 
  1144, 2694, 161, 93, 209, 2104, 2105, 2106, 2107, 163, 529, 34, 92, 93, 531, 266, 311, 532, 165, 166, 533, 101, 534, 103, 
  104, 105, 106, 107, 1006, 2106, 2107, 2116, 2117, 893, 0, 1, 1042, 1042, 1359, 1360, 4098, 1361, 474, 2773, 4099, 1365, 3286, 3287, 
  1538, 4058, 2069, 1541, 2071, 2072, 474, 2073, 4099, 2074, 2821, 1546, 1547, 2077, 1359, 1360, 4098, 1361, 474, 2773, 4099, 1365, 3286, 3287, 
  1538, 4058, 2069, 1541, 2071, 2072, 474, 2073, 4099, 2074, 2821, 1546, 1547, 2077, 4100, 4101, 4102, 4103, 4104, 4105, 4106, 4107, 3302, 2071, 
  3303, 4108, 3305, 4109, 4110, 4111, 4112, 4113, 4110, 4111, 4112, 4113, 2700, 2701, 2807, 525, 160, 161, 93, 2327, 880, 2108, 34, 883, 
  93, 4114, 2708, 311, 1303, 887, 888, 2113, 101, 102, 103, 1577, 105, 106, 107, 1425, 108, 4115, 37, 38, 4116, 4117, 4118, 4119, 
  2383, 424, 4120, 4121, 416, 4122, 418, 896, 4123, 421, 2523, 897, 2383, 4124, 425, 4125, 427, 4126, 429, 899, 4116, 4117, 4118, 4119, 
  2383, 424, 4120, 4121, 416, 4122, 418, 896, 4123, 421, 2523, 897, 2383, 4124, 425, 4125, 427, 4126, 429, 899, 4127, 4128, 4129, 4130, 
  4131, 4132, 4133, 4134, 4135, 4136, 4137, 4138, 4139, 4140, 4141, 4142, 4143, 4144, 4145, 909, 759, 457, 161, 93, 209, 210, 163, 529, 
  34, 92, 93, 531, 3613, 3614, 165, 166, 533, 101, 534, 103, 3834, 105, 106, 4146, 4147, 4148, 4149, 4150, 4151, 4152, 4153, 4154, 
  4155, 4156, 4157, 4146, 4147, 4148, 4149, 4150, 4151, 4152, 4153, 4154, 4155, 4156, 4157, 4146, 4147, 4148, 4149, 4150, 4151, 4152, 4153, 4154, 
  4155, 4156, 4157, 4146, 4147, 4148, 4149, 4150, 4151, 4152, 4153, 4154, 4155, 4156, 4157, 4158, 4159, 4160, 4161, 4162, 4163, 4164, 4165, 4166, 
  4167, 4168, 4169, 4170, 4171, 4172, 4173, 4174, 4175, 4176, 4177, 4178, 4179, 4180, 4181, 4182, 4183, 4184, 4185, 4186, 4187, 4188, 4189, 4190, 
  4191, 4192, 4193, 4194, 4195, 4196, 0, 318, 408, 408, 4197, 4198, 3250, 3251, 4199, 4200, 4201, 4202, 2065, 3927, 4203, 3252, 2069, 2070, 
  2071, 2072, 4199, 3931, 3932, 4204, 2075, 2076, 4205, 1548, 4197, 4198, 3250, 3251, 4199, 4200, 4201, 4202, 2065, 3927, 4203, 3252, 2069, 2070, 
  2071, 2072, 4199, 3931, 3932, 4204, 2075, 2076, 4205, 1548, 3253, 4206, 4207, 4208, 4209, 4210, 4211, 3260, 3261, 4212, 4213, 4214, 4215, 4216, 
  4217, 4218, 4219, 4220, 4221, 4222, 4223, 4224, 4225, 4226, 2100, 2101, 2186, 1918, 2103, 880, 210, 880, 881, 34, 92, 2103, 2187, 2708, 
  2111, 2189, 887, 2190, 2191, 1417, 1418, 1419, 104, 105, 106, 107, 1927, 109, 110, 0, 318, 408, 408, 4227, 4228, 2771, 4229, 4230, 
  4231, 4232, 2775, 4233, 4234, 1538, 4235, 4236, 471, 472, 549, 4237, 4238, 4239, 477, 478, 4240, 1375, 2782, 4227, 4228, 2771, 4229, 4230, 
  4231, 4232, 2775, 4233, 4234, 1538, 4235, 4236, 471, 472, 549, 4237, 4238, 4239, 477, 478, 4240, 1375, 2782, 4241, 4242, 4243, 4244, 4245, 
  4246, 2748, 511, 2788, 472, 4066, 4247, 4068, 3363, 4248, 4249, 4250, 4251, 2794, 2795, 2796, 2797, 2807, 526, 160, 161, 93, 2063, 210, 
  258, 1301, 34, 92, 93, 94, 1302, 311, 1303, 1304, 1305, 1306, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 318, 2197, 
  2199, 2199, 457, 581, 37, 38, 4252, 4253, 4254, 4255, 4256, 4257, 4258, 4259, 4260, 4261, 4262, 4263, 4252, 4253, 4254, 4255, 4256, 4257, 
  4258, 4259, 4260, 4261, 4262, 4263, 4252, 4253, 4254, 4255, 4256, 4257, 4258, 4259, 4260, 4261, 4262, 4263, 4252, 4253, 4254, 4255, 4256, 4257, 
  4258, 4259, 4260, 4261, 4262, 4263, 4264, 4265, 4266, 4267, 4268, 4269, 4270, 4271, 4272, 4273, 4274, 4275, 4276, 4277, 4278, 4279, 4280, 4281, 
  4282, 4283, 4284, 4285, 4286, 4287, 2714, 2714, 4288, 327, 328, 329, 211, 4289, 4290, 4290, 4287, 4291, 4292, 4293, 4294, 2954, 215, 4295, 
  4296, 4297, 4296, 4298, 4299, 4300, 4301, 4302, 4303, 4303, 4304, 4305, 328, 329, 4306, 4307, 4308, 4309, 0, 318, 4310, 4311, 4312, 4313, 
  4314, 4315, 4316, 4317, 4318, 4319, 4320, 4321, 4310, 4311, 4312, 4313, 4314, 4315, 4316, 4317, 4318, 4319, 4320, 4321, 4310, 4311, 4312, 4313, 
  4314, 4315, 4316, 4317, 4318, 4319, 4320, 4321, 4310, 4311, 4312, 4313, 4314, 4315, 4316, 4317, 4318, 4319, 4320, 4321, 4322, 4323, 4324, 4325, 
  4326, 4327, 4328, 4322, 4323, 4324, 4325, 4326, 4327, 4328, 4329, 4330, 4331, 4332, 888, 889, 108, 37, 37, 409, 410, 411, 4333, 43, 
  4334, 4335, 4336, 416, 417, 418, 419, 420, 421, 422, 423, 43, 424, 425, 426, 427, 428, 429, 3385, 409, 410, 411, 4333, 43, 
  4334, 4335, 4336, 416, 417, 418, 419, 420, 421, 422, 423, 43, 424, 425, 426, 427, 428, 429, 3385, 4337, 4338, 433, 4339, 435, 
  436, 437, 438, 439, 440, 441, 442, 4340, 444, 445, 446, 447, 448, 449, 450, 451, 452, 4341, 4342, 2158, 159, 457, 161, 93, 
  258, 212, 34, 92, 214, 165, 215, 216, 217, 105, 106, 110, 0, 318, 409, 410, 4079, 42, 43, 413, 2162, 4080, 47, 48, 
  49, 50, 420, 421, 495, 423, 43, 424, 425, 3624, 427, 428, 429, 3385, 409, 410, 4079, 42, 43, 413, 2162, 4080, 47, 48, 
  49, 50, 420, 421, 495, 423, 43, 424, 425, 3624, 427, 428, 429, 3385, 4343, 4082, 4083, 4084, 4085, 4086, 4087, 4343, 4089, 4090, 
  4091, 4092, 2149, 928, 4344, 4345, 4346, 4347, 4348, 4349, 4350, 4351, 4097, 1144, 457, 161, 93, 406, 210, 406, 407, 34, 92, 93, 
  531, 4077, 311, 532, 98, 3176, 1615, 101, 534, 103, 104, 105, 106, 107, 1006, 109, 110, 0, 1, 408, 408, 4352, 4353, 4354, 
  4355, 4356, 4357, 4358, 4359, 4360, 4361, 4362, 4363, 4364, 4365, 4366, 4367, 4368, 4369, 4370, 4371, 4372, 4373, 4374, 4375, 4352, 4353, 4354, 
  4355, 4356, 4357, 4358, 4359, 4360, 4361, 4362, 4363, 4364, 4365, 4366, 4367, 4368, 4369, 4370, 4371, 4372, 4373, 4374, 4375, 4376, 4377, 4378, 
  4379, 4380, 4381, 4382, 4383, 4384, 4385, 4386, 4387, 4388, 4389, 4390, 4391, 4392, 4393, 4394, 4395, 4396, 4397, 4398, 4399, 4400, 400, 4401, 
  581, 210, 880, 881, 4402, 4403, 4401, 4404, 2110, 4405, 4406, 887, 888, 889, 101, 534, 103, 4407, 4408, 4409, 107, 167, 0, 1, 
  113, 113, 4410, 4411, 4412, 4413, 4414, 4415, 4416, 4417, 4418, 4419, 4420, 4421, 4422, 4423, 4424, 4425, 497, 3698, 3699, 4426, 4427, 4428, 
  4429, 4430, 4410, 4411, 4412, 4413, 4414, 4415, 4416, 4417, 4418, 4419, 4420, 4421, 4422, 4423, 4424, 4425, 497, 3698, 3699, 4426, 4427, 4428, 
  4429, 4430, 4431, 4432, 4433, 4343, 4434, 4435, 4436, 4431, 4432, 4433, 4343, 4434, 4435, 4436, 4437, 4438, 4439, 4440, 4441, 4442, 4443, 4444, 
  4445, 4446, 4447, 4448, 160, 161, 162, 163, 111, 112, 109, 110, 164, 34, 92, 93, 94, 165, 166, 101, 102, 103, 105, 106, 
  1144, 1145, 168, 37, 38, 4449, 4450, 4451, 4452, 4453, 4454, 4455, 4456, 4457, 4458, 4459, 4460, 2502, 4461, 4462, 2133, 4463, 4464, 4465, 
  4466, 4467, 4468, 4469, 4470, 4449, 4450, 4451, 4452, 4453, 4454, 4455, 4456, 4457, 4458, 4459, 4460, 2502, 4461, 4462, 2133, 4463, 4464, 4465, 
  4466, 4467, 4468, 4469, 4470, 4471, 4472, 4473, 4474, 4475, 4476, 4477, 4478, 4479, 4480, 4481, 4482, 4483, 4484, 4485, 4486, 4487, 4488, 951, 
  952, 953, 954, 4489, 4490, 4491, 4492, 457, 161, 93, 258, 212, 34, 92, 214, 165, 215, 216, 217, 105, 106, 110, 0, 1, 
  4493, 4494, 4495, 4496, 4497, 4498, 4499, 4500, 4501, 4502, 4503, 4504, 4493, 4494, 4495, 4496, 4497, 4498, 4499, 4500, 4501, 4502, 4503, 4504, 
  4505, 4506, 4507, 4508, 4509, 4510, 4511, 4512, 4513, 4514, 4515, 4516, 4493, 4494, 4495, 4496, 4497, 4498, 4499, 4500, 4501, 4502, 4503, 4504, 
  4517, 4518, 4519, 4520, 4521, 4522, 4523, 4517, 4518, 4519, 4520, 4521, 4522, 4523, 33, 35, 4493, 4494, 4495, 4496, 4497, 4498, 4499, 4500, 
  4501, 4502, 4503, 4504, 37, 38, 4524, 4525, 4526, 4527, 4528, 4529, 4530, 4531, 4532, 4533, 4534, 4535, 420, 421, 422, 423, 43, 424, 
  425, 426, 427, 428, 429, 3385, 4524, 4525, 4526, 4527, 4528, 4529, 4530, 4531, 4532, 4533, 4534, 4535, 420, 421, 422, 423, 43, 424, 
  425, 426, 427, 428, 429, 3385, 4536, 4537, 4538, 4539, 4540, 4541, 4542, 4543, 4544, 4545, 4546, 4547, 4548, 4549, 947, 948, 949, 950, 
  951, 952, 953, 954, 4550, 4551, 4552, 4553, 457, 161, 93, 258, 212, 34, 92, 214, 165, 215, 216, 217, 105, 106, 110, 0, 
  1, 408, 957, 4554, 4555, 4556, 1648, 4557, 4558, 4559, 4560, 4561, 4562, 4563, 4564, 420, 421, 495, 496, 719, 424, 425, 426, 500, 
  3351, 4565, 4566, 4554, 4555, 4556, 1648, 4557, 4558, 4559, 4560, 4561, 4562, 4563, 4564, 420, 421, 495, 496, 719, 424, 425, 426, 500, 
  3351, 4565, 4566, 4567, 4568, 4569, 4570, 4571, 4572, 510, 132, 4573, 4574, 4575, 4576, 4577, 3363, 4578, 4579, 4580, 4581, 2794, 2795, 2796, 
  2797, 756, 757, 204, 4582, 4583, 4584, 93, 258, 210, 258, 2692, 882, 4585, 93, 531, 3312, 311, 532, 4586, 1305, 2693, 101, 534, 
  3375, 1577, 105, 4587, 107, 1006, 109, 110, 4588, 4589, 4590, 4591, 4592, 4593, 4594, 4595, 4596, 4597, 4598, 4599, 4588, 4589, 4590, 4591, 
  4592, 4593, 4594, 4595, 4596, 4597, 4598, 4599, 4588, 4589, 4590, 4591, 4592, 4593, 4594, 4595, 4596, 4597, 4598, 4599, 4588, 4589, 4590, 4591, 
  4592, 4593, 4594, 4595, 4596, 4597, 4598, 4599, 4600, 4601, 4602, 4603, 4604, 4605, 4606, 4607, 4608, 4609, 4610, 4611, 4612, 4613, 4614, 4615, 
  4616, 4617, 449, 450, 451, 452, 4618, 4619, 4620, 4621, 4622, 207, 208, 209, 163, 529, 4623, 34, 208, 4624, 2803, 4625, 4626, 98, 
  99, 533, 101, 656, 103, 104, 105, 106, 107, 1006, 0, 318, 4627, 4628, 4629, 4630, 4631, 4632, 4633, 4634, 4635, 4636, 4637, 4638, 
  4639, 4640, 4641, 4642, 4643, 4644, 4645, 4646, 4647, 4648, 4649, 4650, 4627, 4628, 4629, 4630, 4631, 4632, 4633, 4634, 4635, 4636, 4637, 4638, 
  4639, 4640, 4641, 4642, 4643, 4644, 4645, 4646, 4647, 4648, 4649, 4650, 4651, 4652, 4653, 4654, 4655, 4656, 4657, 4658, 4659, 4660, 4661, 4662, 
  4663, 4664, 4665, 4666, 4667, 4668, 2794, 2795, 2796, 2797, 4669, 4670, 4671, 4672, 4673, 258, 258, 2692, 652, 4403, 4673, 4674, 4675, 4676, 
  1304, 166, 2693, 4677, 4678, 4679, 4680, 4408, 4409, 107, 1006, 109, 110, 1, 113, 113, 2200, 2201, 2202, 2203, 2204, 2205, 2206, 2207, 
  2208, 2209, 2210, 2211, 2212, 2213, 495, 2214, 2204, 2215, 2216, 2207, 2217, 428, 2218, 2219, 2200, 2201, 2202, 2203, 2204, 2205, 2206, 2207, 
  2208, 2209, 2210, 2211, 2212, 2213, 495, 2214, 2204, 2215, 2216, 2207, 2217, 428, 2218, 2219, 2220, 4681, 4682, 2223, 4683, 4684, 4685, 442, 
  2226, 2227, 2228, 2229, 4686, 4687, 2232, 2233, 2234, 2235, 2236, 2237, 2238, 2239, 4688, 4689, 2242, 2243, 160, 161, 162, 163, 164, 34, 
  92, 93, 94, 165, 166, 101, 102, 103, 105, 106, 1144, 1145, 168, 37, 38, 4690, 4691, 4692, 4693, 4694, 4695, 4696, 4697, 4698, 
  4699, 4700, 4701, 4702, 4703, 4704, 4705, 4706, 4707, 4708, 4709, 4710, 4711, 4712, 4713, 4690, 4691, 4692, 4693, 4714, 4695, 4696, 4697, 4698, 
  4699, 4700, 4701, 4702, 4703, 4704, 4705, 4706, 4707, 4708, 4709, 4710, 4711, 4712, 4713, 2511, 4715, 4716, 4717, 4718, 4719, 4720, 4721, 4722, 
  4723, 4724, 4725, 4726, 4727, 4728, 4729, 4730, 4731, 449, 450, 451, 452, 4732, 4733, 2531, 2532, 457, 161, 93, 258, 406, 212, 34, 
  92, 4734, 214, 165, 215, 216, 217, 105, 106, 4735, 110, 0, 1, 408, 408, 4736, 4737, 4738, 4739, 4740, 4741, 4742, 4743, 4744, 
  4745, 4746, 4747, 4748, 4749, 4750, 4751, 4752, 4753, 4754, 4755, 4756, 4757, 4758, 4759, 4760, 4761, 4762, 4763, 4764, 4765, 4766, 4767, 4768, 
  4769, 4770, 4771, 4748, 4749, 4750, 4751, 4752, 4753, 4754, 4755, 4756, 4757, 4758, 4759, 4772, 4773, 4774, 4775, 4776, 4777, 4778, 4779, 4780, 
  4781, 861, 4782, 4783, 864, 4784, 4785, 4786, 4787, 4788, 4789, 4790, 4791, 4792, 4793, 4794, 4795, 4796, 581, 210, 33, 582, 4797, 4798, 
  4799, 4800, 4801, 4802, 4803, 586, 587, 655, 101, 656, 103, 4804, 4805, 4806, 4807, 109, 110, 1, 113, 4808, 4809, 4810, 4811, 4812, 
  4813, 4814, 4815, 4816, 4817, 4818, 4819, 4820, 4809, 4810, 4811, 4812, 4813, 4814, 4815, 4816, 4817, 4818, 4819, 4820, 4809, 4810, 4811, 4812, 
  4813, 4814, 4815, 4816, 4817, 4818, 4819, 4820, 4809, 4810, 4811, 4812, 4813, 4814, 4815, 4816, 4817, 4818, 4819, 4820, 4821, 4822, 4823, 4824, 
  4825, 4826, 4827, 4828, 4829, 4830, 4831, 4832, 4833, 4834, 4835, 4836, 4837, 4838, 4839, 4840, 4841, 4842, 4843, 4844, 4845, 4846, 4847, 4848, 
  4849, 406, 210, 4850, 4851, 4852, 4853, 4854, 4855, 4856, 2813, 3176, 4857, 1356, 4858, 4859, 167, 0, 318, 4860, 4861, 4862, 4863, 4864, 
  4865, 4866, 4867, 4868, 4869, 4870, 4860, 4861, 4862, 4863, 4864, 4865, 4866, 4867, 4868, 4869, 4870, 4860, 4861, 4862, 4863, 4864, 4865, 4866, 
  4867, 4868, 4869, 4870, 4860, 4861, 4862, 4863, 4864, 4865, 4866, 4867, 4868, 4869, 4870, 4871, 3295, 3296, 4872, 4873, 4874, 4875, 4871, 3295, 
  3296, 4872, 4873, 4874, 4875, 88, 161, 93, 4876, 4876, 4877, 34, 93, 94, 311, 1303, 4878, 1305, 1306, 101, 102, 104, 107, 108, 
  0, 318, 767, 2817, 2817, 4879, 4880, 4881, 4882, 4883, 4884, 4885, 4886, 4887, 4888, 4889, 4890, 1370, 4891, 472, 549, 1362, 1371, 1372, 
  1373, 2780, 554, 1375, 1376, 4892, 4893, 4894, 4895, 4896, 2868, 2869, 4897, 4898, 4899, 4900, 4901, 1370, 4891, 472, 549, 1362, 1371, 1372, 
  1373, 2780, 554, 1375, 1376, 4902, 4903, 4904, 4905, 4906, 4907, 4908, 4909, 4910, 472, 4911, 4912, 4913, 4914, 2104, 2105, 2106, 2107, 37, 
  38, 4915, 4916, 4917, 4918, 4919, 4920, 4921, 4922, 4923, 4924, 4925, 4926, 941, 4927, 4928, 4929, 4930, 4931, 4932, 4933, 4934, 4935, 4936, 
  4937, 4915, 4916, 4917, 4918, 4919, 4920, 4921, 4922, 4923, 4924, 4925, 4926, 941, 4927, 4928, 4929, 4930, 4931, 4932, 4933, 4934, 4935, 4936, 
  4937, 4938, 4939, 4940, 4941, 4942, 4943, 4944, 4945, 4946, 4947, 4948, 4949, 4950, 4951, 4952, 4953, 4954, 4955, 449, 450, 451, 452, 4956, 
  4957, 2713, 4958, 457, 161, 93, 258, 212, 34, 92, 214, 165, 215, 216, 217, 105, 106, 110, 113, 4808, 4959, 4960, 4961, 4962, 
  4963, 4964, 4965, 4966, 4967, 4968, 4969, 4970, 4959, 4960, 4961, 4962, 4963, 4964, 4965, 4966, 4967, 4968, 4969, 4970, 4959, 4960, 4961, 4962, 
  4963, 4964, 4965, 4966, 4967, 4968, 4969, 4970, 4959, 4960, 4961, 4962, 4963, 4964, 4965, 4966, 4967, 4968, 4969, 4970, 4971, 4972, 4973, 4974, 
  4975, 4976, 4977, 4971, 4978, 4973, 4974, 4979, 4976, 4977, 4980, 4981, 4982, 4983, 4980, 4981, 4982, 4983, 4984, 4985, 160, 161, 93, 209, 
  259, 260, 261, 262, 210, 163, 164, 34, 92, 93, 94, 2803, 311, 1303, 165, 166, 100, 101, 102, 103, 104, 105, 106, 107, 
  167, 37, 38, 4986, 4987, 4988, 4989, 4990, 4991, 4992, 4993, 4994, 4995, 4996, 4997, 4998, 4999, 4988, 5000, 4990, 4991, 4992, 5001, 5002, 
  5003, 5004, 5005, 4986, 4987, 4988, 4989, 4990, 4991, 4992, 4993, 4994, 4995, 4996, 4997, 4998, 4999, 4988, 5000, 4990, 4991, 4992, 5001, 5002, 
  5003, 5004, 5005, 5006, 5007, 5008, 5009, 5010, 5011, 5012, 5013, 5014, 5015, 5016, 5017, 5018, 5019, 5020, 5021, 5022, 5023, 5024, 5025, 5026, 
  5027, 5028, 5029, 1677, 1678, 213, 209, 3609, 3610, 3611, 3612, 163, 212, 34, 92, 93, 214, 165, 166, 5030, 101, 534, 103, 105, 
  106, 167, 37, 38, 5031, 5032, 5033, 5034, 5035, 5036, 5037, 5038, 5039, 5040, 5041, 5042, 5031, 5032, 5033, 5034, 5035, 5036, 5037, 5038, 
  5039, 5040, 5041, 5042, 5031, 5032, 5033, 5034, 5035, 5036, 5037, 5038, 5039, 5040, 5041, 5042, 5031, 5032, 5033, 5034, 5035, 5036, 5037, 5038, 
  5039, 5040, 5041, 5042, 5043, 5044, 5045, 5046, 5047, 5048, 5049, 5050, 5051, 5052, 5053, 5054, 5055, 5056, 5057, 5058, 5059, 5060, 5061, 5062, 
  5063, 5064, 5065, 5066, 909, 759, 5067, 5068, 5069, 5070, 5071, 5072, 272, 273, 211, 5073, 5074, 5075, 5076, 5077, 5078, 5079, 5080, 2954, 
  3969, 5081, 5082, 5083, 5084, 5085, 5086, 5087, 5088, 5089, 5090, 5091, 5092, 5093, 272, 273, 5094, 5095, 5096, 345, 346, 1185, 1185, 5097, 
  5098, 1015, 5099, 1311, 1018, 5100, 5101, 5102, 5103, 5104, 5105, 5106, 5107, 1015, 5108, 1311, 1018, 1321, 5109, 5110, 5111, 5112, 5113, 5097, 
  5098, 1015, 5099, 1311, 1018, 5100, 5101, 5102, 5103, 5104, 5105, 5106, 5107, 1015, 5108, 1311, 1018, 1321, 5109, 5110, 5111, 5112, 1326, 5114, 
  5115, 5116, 1028, 5117, 5118, 5119, 5114, 5115, 5116, 1028, 5117, 5118, 5119, 5120, 5121, 5122, 5123, 5124, 5125, 160, 161, 5126, 2717, 259, 
  260, 261, 262, 401, 5127, 34, 4403, 162, 1183, 1184, 2813, 166, 5128, 101, 534, 103, 104, 2016, 2017, 1185, 1185, 5129, 5130, 2381, 
  1648, 719, 424, 414, 5131, 5132, 5133, 5134, 5135, 420, 421, 495, 496, 719, 424, 425, 426, 500, 3351, 429, 2169, 5129, 5130, 2381, 
  1648, 719, 424, 414, 5131, 5132, 5133, 5134, 5135, 420, 421, 495, 496, 719, 424, 425, 426, 500, 3351, 429, 2169, 5136, 5137, 5138, 
  5139, 5140, 5141, 5142, 5143, 3843, 5144, 5145, 5146, 5147, 5148, 5149, 5150, 5151, 5152, 5153, 5154, 5155, 5156, 5157, 759, 1181, 400, 162, 
  2717, 5158, 5159, 2016, 2017, 210, 401, 5160, 34, 92, 162, 1182, 5161, 1183, 1184, 165, 166, 5162, 101, 534, 103, 104, 105, 106, 
  5163, 2016, 2017, 5164, 5165, 37, 37, 3052, 5166, 3054, 3055, 5167, 5168, 5169, 3059, 5170, 5171, 3062, 3063, 3052, 5166, 3054, 3055, 5167, 
  5168, 5169, 3059, 5170, 5171, 3062, 3063, 3052, 5166, 3054, 3055, 5167, 5168, 5172, 3059, 5170, 5171, 3062, 3063, 3052, 5166, 3054, 3055, 5167, 
  5168, 5172, 3059, 5170, 5171, 3062, 3063, 5173, 5174, 5175, 5176, 5177, 5178, 5179, 5173, 5180, 5176, 5177, 5178, 5179, 5181, 5182, 5183, 5184, 
  5185, 5186, 5187, 5188, 5189, 5190, 1677, 1678, 213, 1679, 259, 260, 261, 262, 210, 212, 34, 92, 214, 5191, 1680, 1681, 165, 215, 
  216, 217, 104, 105, 106, 107, 167, 1013, 3810, 1015, 1016, 1017, 1018, 1019, 1020, 5192, 2246, 5193, 5194, 1013, 3810, 1015, 1016, 1017, 
  1018, 1019, 1020, 5195, 2246, 5196, 5194, 1013, 3810, 1015, 1016, 1017, 1018, 1019, 1020, 5195, 5197, 5196, 5198, 1013, 3810, 1015, 1016, 1017, 
  1018, 1019, 1020, 5195, 5197, 5196, 5194, 5199, 5200, 5201, 5202, 5203, 5204, 5205, 5199, 5206, 5207, 5202, 5203, 5204, 5205, 5208, 5209, 5210, 
  5211, 909, 759, 457, 161, 93, 209, 1351, 1352, 272, 273, 210, 1095, 213, 109, 110, 113, 113, 5212, 5213, 411, 5214, 43, 413, 
  414, 415, 416, 417, 418, 419, 420, 421, 422, 423, 43, 424, 425, 426, 427, 428, 429, 3385, 5212, 5213, 411, 5214, 43, 413, 
  414, 415, 416, 417, 418, 419, 420, 421, 422, 423, 43, 424, 425, 426, 427, 428, 429, 3385, 5215, 5216, 5217, 5218, 435, 436, 
  5219, 438, 439, 5220, 441, 442, 4340, 444, 5221, 5222, 5223, 5224, 951, 952, 953, 954, 5225, 5226, 2158, 159, 457, 161, 93, 258, 
  212, 34, 92, 214, 165, 215, 216, 217, 105, 106, 110, 0, 1, 408, 408, 5227, 5228, 5229, 5230, 5231, 5232, 5233, 5234, 5235, 
  5236, 5237, 5238, 5239, 5240, 5241, 5242, 5243, 5244, 5245, 5246, 5247, 5248, 5249, 5250, 5227, 5228, 5229, 5230, 5231, 5232, 5233, 5234, 5235, 
  5236, 5237, 5238, 5239, 5240, 5241, 5242, 5243, 5244, 5245, 5246, 5247, 5248, 5249, 5250, 5251, 5252, 5253, 5254, 5255, 5256, 5257, 2993, 5258, 
  5259, 5260, 5261, 5262, 5263, 5264, 5265, 5266, 5267, 5268, 5269, 5270, 5271, 5272, 5273, 5274, 5275, 160, 161, 93, 163, 163, 164, 34, 
  93, 94, 165, 166, 100, 101, 102, 105, 106, 108, 109, 110, 168, 0, 1, 767, 408, 408, 5276, 5277, 5278, 5279, 719, 5280, 
  5281, 5282, 3554, 5283, 3556, 3557, 420, 5284, 5285, 423, 719, 424, 425, 5286, 5287, 428, 429, 2169, 5276, 5277, 5278, 5279, 719, 5280, 
  5281, 5282, 3554, 5283, 3556, 3557, 51, 5288, 5289, 54, 719, 55, 56, 5290, 5291, 59, 60, 2166, 5292, 5293, 5294, 5295, 5296, 5297, 
  5298, 3565, 2177, 71, 5299, 3568, 2179, 75, 5300, 5301, 5302, 5303, 5304, 5305, 5306, 5307, 5308, 5309, 2184, 2185, 5310, 1918, 5311, 1919, 
  91, 34, 92, 5311, 5312, 5313, 1925, 1417, 2114, 1419, 5314, 106, 5315, 328, 329, 109, 110, 0, 318, 5316, 408, 957, 5317, 5318, 
  5319, 5320, 5321, 5322, 5323, 5324, 5325, 5326, 5327, 5328, 5329, 5330, 5331, 5332, 5333, 5334, 5335, 5336, 5337, 5338, 5339, 5340, 5317, 5318, 
  5319, 5320, 5321, 5322, 5323, 5324, 5325, 5326, 5327, 5328, 5329, 5330, 5331, 5332, 5333, 5334, 5335, 5336, 5337, 5338, 5339, 5340, 5341, 5342, 
  5343, 5344, 5345, 5346, 5347, 5348, 5349, 5350, 5351, 5352, 5346, 5353, 5354, 5355, 5356, 5357, 5358, 5359, 5360, 5361, 5362, 5363, 456, 758, 
  5364, 5365, 162, 33, 33, 582, 652, 5366, 162, 653, 5367, 5368, 654, 586, 587, 5030, 101, 656, 5369, 589, 4408, 5370, 109, 110, 
  37, 37, 5371, 5372, 5373, 5374, 5375, 5376, 5377, 5378, 5379, 5380, 5381, 5382, 5383, 5384, 5385, 2033, 2204, 5386, 2040, 3638, 5387, 5388, 
  1269, 5389, 5371, 5372, 5373, 5374, 5375, 5376, 5377, 5378, 5379, 5380, 5381, 5382, 5383, 5384, 5385, 2033, 2204, 5386, 2040, 3638, 5387, 5388, 
  1269, 5389, 5390, 5391, 5392, 5393, 5394, 5395, 5396, 1279, 1280, 5397, 5398, 5399, 5400, 2052, 2700, 2701, 3445, 759, 1185, 38, 5401, 5402, 
  5403, 5404, 5405, 5406, 5407, 5408, 5409, 5410, 5411, 5412, 5413, 5414, 5415, 5416, 5417, 5418, 5419, 5420, 5421, 5422, 5423, 5424, 5401, 5402, 
  5403, 5404, 5405, 5406, 5407, 5408, 5409, 5410, 5411, 5412, 5413, 5414, 5415, 5416, 5417, 5418, 5419, 5420, 5421, 5422, 5423, 5424, 5425, 5426, 
  5427, 5428, 5429, 5430, 5431, 5432, 5433, 5434, 5435, 5436, 5437, 5438, 5439, 5440, 5441, 5442, 756, 757, 5443, 5444, 457, 161, 93, 209, 
  111, 112, 109, 110, 210, 163, 529, 34, 92, 93, 531, 3833, 311, 532, 165, 166, 533, 101, 534, 103, 3834, 105, 106, 107, 
  108, 1185, 1185, 5445, 5446, 5447, 5448, 5449, 5450, 5451, 5452, 5453, 5454, 5455, 5456, 5457, 5458, 5459, 5460, 5461, 5462, 5463, 5464, 5465, 
  5466, 5467, 5468, 5445, 5446, 5447, 5448, 5449, 5450, 5451, 5452, 5453, 5454, 5455, 5456, 5457, 5458, 5459, 5460, 5461, 5462, 5463, 5464, 5465, 
  5466, 5467, 5468, 5469, 5470, 5471, 5472, 5473, 5474, 5475, 5476, 5477, 5478, 5479, 5480, 5481, 5482, 5483, 5484, 5485, 5486, 5487, 5488, 5489, 
  5490, 5491, 5492, 5493, 5494, 457, 161, 93, 209, 111, 112, 109, 110, 210, 163, 529, 34, 92, 93, 531, 311, 532, 165, 166, 
  533, 101, 534, 103, 3834, 105, 106, 107, 108, 1185, 1185, 5495, 5496, 5497, 5498, 5499, 5500, 5501, 5502, 5503, 5504, 5505, 5506, 5507, 
  5508, 5509, 5510, 5511, 5512, 5513, 5514, 5515, 5516, 5517, 5518, 5495, 5496, 5497, 5498, 5499, 5500, 5501, 5502, 5503, 5504, 5505, 5506, 5507, 
  5508, 5509, 5510, 5511, 5512, 5513, 5514, 5515, 5516, 5517, 5518, 5519, 5520, 5521, 5522, 5523, 5524, 5525, 5526, 5527, 5528, 5529, 5530, 5531, 
  5532, 5533, 5534, 5535, 5536, 5537, 5538, 5539, 5540, 5541, 5542, 5543, 5544, 457, 161, 93, 209, 111, 112, 109, 110, 210, 163, 529, 
  34, 92, 93, 531, 311, 532, 165, 166, 533, 101, 534, 103, 3834, 105, 106, 107, 108, 1185, 1185, 5545, 5546, 5547, 5548, 5549, 
  5550, 5551, 5552, 5553, 5554, 5555, 5556, 5545, 5546, 5547, 5548, 5549, 5550, 5551, 5552, 5553, 5554, 5555, 5556, 5545, 5546, 5547, 5548, 5549, 
  5550, 5551, 5552, 5553, 5554, 5555, 5556, 5545, 5546, 5547, 5548, 5549, 5550, 5551, 5552, 5553, 5554, 5555, 5556, 5557, 5558, 5559, 5560, 5561, 
  5562, 5563, 5557, 5558, 5559, 5560, 5561, 5562, 5563, 5564, 5565, 5566, 5567, 5568, 5569, 5570, 5571, 5572, 5573, 5574, 5575, 457, 161, 93, 
  209, 111, 112, 109, 110, 210, 163, 529, 34, 92, 93, 531, 311, 532, 165, 166, 533, 101, 534, 103, 3834, 105, 106, 107, 
  108, 0, 1, 408, 408, 1616, 658, 592, 659, 594, 660, 661, 597, 662, 663, 664, 665, 5576, 667, 668, 669, 594, 670, 671, 
  672, 5577, 674, 5578, 676, 5579, 5580, 615, 5581, 617, 5582, 5583, 620, 5584, 5585, 5586, 5587, 5588, 5589, 5590, 5591, 617, 5592, 5593, 
  5594, 5595, 5596, 5597, 5598, 5599, 5600, 5601, 5602, 5603, 5604, 5605, 5606, 5607, 5608, 5609, 5610, 5604, 5611, 5612, 5613, 5614, 5615, 5616, 
  5617, 5618, 5619, 5620, 5621, 5622, 4793, 5623, 5624, 5625, 581, 33, 2707, 5626, 5627, 5628, 5629, 5630, 5631, 99, 5162, 1356, 5632, 4859, 
  5633, 5634, 5635, 5636, 109, 110, 5637, 5638, 5639, 5640, 5641, 5642, 5643, 5644, 5645, 5646, 5647, 5648, 5649, 5650, 5651, 5652, 5653, 5654, 
  5655, 5656, 5657, 5658, 5659, 5660, 5637, 5638, 5639, 5640, 5641, 5642, 5643, 5644, 5645, 5646, 5647, 5648, 5649, 5650, 5651, 5652, 5653, 5654, 
  5655, 5656, 5657, 5658, 5659, 5660, 5661, 5662, 5663, 5664, 5665, 5666, 5667, 5668, 5669, 5670, 5671, 442, 443, 5672, 5673, 5674, 5675, 5676, 
  5677, 5678, 5679, 5680, 5681, 5682, 5683, 5157, 457, 161, 93, 258, 212, 34, 92, 214, 165, 215, 216, 217, 105, 106, 110, 0, 
  318, 767, 408, 408, 2159, 2160, 5684, 5685, 2383, 413, 2162, 2163, 47, 48, 49, 2164, 51, 52, 5686, 2855, 2383, 413, 2162, 57, 
  58, 59, 60, 2166, 2159, 2160, 5684, 5685, 2383, 413, 2162, 2163, 47, 48, 49, 2164, 420, 421, 5687, 496, 2383, 424, 425, 2168, 
  427, 428, 429, 2169, 5688, 5689, 5690, 5691, 5692, 5693, 5694, 5695, 5696, 5697, 5698, 5699, 5700, 5701, 2180, 2181, 2182, 2183, 5702, 5703, 
  2184, 2185, 2186, 1918, 2103, 581, 880, 881, 34, 92, 2103, 2187, 2111, 2189, 887, 2190, 2191, 1417, 1418, 1419, 104, 105, 106, 107, 
  1426, 5704, 109, 110, 113, 113, 5705, 5706, 5707, 5708, 5709, 5280, 5710, 5711, 5712, 5713, 418, 419, 420, 421, 495, 5714, 2523, 4124, 
  425, 3700, 5715, 5716, 429, 3385, 5705, 5706, 5707, 5708, 5709, 5280, 5710, 5711, 5712, 5713, 418, 419, 420, 421, 495, 5714, 2523, 4124, 
  425, 3700, 5715, 5716, 429, 3385, 5717, 5718, 5719, 5720, 5721, 5722, 5723, 928, 5724, 5725, 5726, 5727, 5728, 5729, 5730, 5731, 5732, 5733, 
  5734, 5735, 5736, 5737, 909, 759, 457, 161, 93, 258, 212, 34, 92, 214, 165, 215, 216, 217, 105, 106, 110, 0, 318, 408, 
  957, 5738, 5739, 5740, 5741, 5742, 5743, 5744, 5745, 5746, 5747, 1518, 5748, 5749, 5750, 5751, 5752, 5753, 5754, 5755, 5756, 1525, 5757, 1527, 
  5758, 5759, 5760, 5761, 5762, 5763, 5764, 5765, 2775, 4233, 4234, 1538, 5766, 5767, 2090, 2071, 5768, 5769, 5770, 5771, 2820, 1545, 5772, 1547, 
  5773, 5774, 5775, 5776, 5777, 5778, 5779, 5780, 3548, 3302, 5781, 5782, 5783, 3305, 5784, 5785, 5786, 5787, 5788, 1567, 1568, 5789, 5790, 5791, 
  2063, 210, 163, 164, 5792, 5793, 5791, 5794, 2803, 5795, 5796, 165, 166, 100, 101, 102, 103, 1577, 105, 5797, 107, 108, 109, 5798, 
  5799, 5800, 5801, 5802, 5803, 5804, 5805, 5806, 5807, 5808, 5809, 5798, 5799, 5800, 5801, 5802, 5803, 5804, 5805, 5806, 5807, 5808, 5809, 5798, 
  5799, 5800, 5801, 5802, 5803, 5804, 5805, 5806, 5807, 5808, 5809, 5798, 5799, 5800, 5801, 5802, 5803, 5804, 5805, 5806, 5807, 5808, 5809, 5810, 
  5811, 5812, 5813, 5814, 5815, 5816, 5810, 5811, 5812, 5813, 5814, 5815, 5816, 1677, 1678, 213, 1679, 111, 112, 109, 110, 0, 318, 408, 
  408, 5817, 5818, 5819, 5820, 5821, 5822, 5823, 5824, 5825, 5826, 5827, 5828, 5817, 5818, 5819, 5820, 5821, 5822, 5823, 5824, 5825, 5826, 5827, 
  5828, 5829, 5830, 5831, 5832, 2750, 5833, 5834, 5835, 5836, 5837, 5838, 5839, 5829, 5830, 5831, 5832, 2750, 5833, 5834, 5835, 478, 5840, 1375, 
  5841, 5842, 5843, 5844, 5845, 5846, 5847, 5848, 511, 5849, 5850, 5851, 5852, 5853, 3363, 5854, 5855, 5856, 5857, 5854, 5855, 5856, 5857, 5858, 
  759, 5859, 161, 93, 581, 210, 880, 881, 882, 883, 93, 531, 2110, 311, 532, 586, 2190, 2191, 101, 534, 103, 1577, 105, 106, 
  1006, 0, 2197, 5860, 5861, 5862, 3282, 5863, 5864, 5865, 5866, 5867, 5868, 2067, 5869, 5860, 5861, 5862, 3282, 5863, 5864, 5865, 5866, 5867, 
  5868, 2067, 5869, 5860, 5861, 5862, 3282, 5863, 5864, 5865, 5866, 5867, 5868, 2067, 5869, 5860, 5861, 5862, 3282, 5863, 5864, 5865, 5866, 5867, 
  5868, 2067, 5869, 5774, 5870, 5871, 5872, 5873, 4246, 5874, 5774, 5870, 5871, 5872, 5873, 4246, 5874, 0, 318, 408, 408, 5875, 5876, 5877, 
  5878, 5879, 5880, 5881, 5882, 5883, 5884, 5885, 5886, 547, 5887, 5888, 5889, 2867, 5890, 5891, 5892, 5893, 5894, 5895, 5896, 5875, 5876, 5877, 
  5878, 5879, 5880, 5881, 5882, 5883, 5884, 5885, 5886, 547, 5887, 5888, 5889, 2867, 5890, 5891, 5892, 5893, 5894, 5895, 5896, 5897, 5898, 5899, 
  5900, 5901, 5902, 5903, 5904, 5905, 5906, 5907, 5908, 5909, 5910, 5911, 5912, 5913, 5914, 5915, 5916, 5917, 5918, 5919, 5920, 5921, 5922, 160, 
  161, 93, 163, 163, 164, 34, 93, 94, 165, 166, 100, 101, 102, 105, 106, 108, 109, 110, 168, 0, 318, 2817, 2817, 5923, 
  5924, 5925, 5926, 5927, 5928, 5929, 5930, 5931, 5932, 5933, 5934, 5935, 5936, 5937, 5938, 5939, 5940, 5941, 5942, 5943, 5944, 5945, 5946, 5923, 
  5924, 5925, 5926, 5927, 5928, 5929, 5930, 5931, 5932, 5933, 5934, 5935, 5936, 5937, 5938, 5939, 5940, 5941, 5942, 5943, 5944, 5945, 5946, 5947, 
  5948, 5949, 5950, 5951, 5952, 5953, 5954, 5955, 5956, 5957, 5958, 5959, 5960, 5961, 5962, 5963, 5964, 5965, 5966, 5967, 5968, 5969, 5970, 5971, 
  5972, 457, 161, 93, 163, 5973, 5974, 328, 329, 210, 163, 529, 34, 92, 93, 531, 5975, 5976, 5977, 165, 166, 533, 101, 102, 
  103, 3615, 105, 106, 1006, 5978, 5979, 5980, 280, 5981, 5167, 5982, 5983, 5984, 5985, 5986, 5987, 5988, 5979, 5980, 280, 5981, 5167, 5982, 
  5983, 5984, 5985, 5986, 5987, 5988, 5979, 5980, 280, 5981, 5167, 5982, 5983, 5984, 5985, 5986, 5987, 5988, 5979, 5980, 280, 5981, 5167, 5982, 
  5983, 5984, 5985, 5986, 5987, 5988, 259, 260, 261, 262, 0, 1, 767, 408, 408, 5989, 5990, 5991, 5992, 5993, 5994, 5995, 5996, 5997, 
  5998, 5999, 6000, 6001, 6002, 6003, 6004, 6005, 6006, 6007, 6008, 6009, 6010, 6011, 6012, 6013, 6014, 6015, 6016, 6017, 6018, 6019, 6020, 6021, 
  6022, 6023, 6024, 6001, 6002, 6003, 6004, 6005, 6006, 6007, 6008, 6009, 6010, 6011, 6012, 6025, 6026, 6027, 6028, 6029, 6030, 6031, 6032, 6033, 
  6034, 6035, 6036, 6037, 6038, 6039, 6040, 6041, 6042, 6043, 6044, 6045, 6046, 6047, 6048, 3885, 6049, 6050, 6051, 2702, 2704, 6052, 2702, 6053, 
  95, 95, 6054, 6055, 2705, 6056, 6057, 6058, 6059, 1307, 1307, 6060, 763, 764, 892, 0, 318, 113, 113, 6061, 6062, 6063, 6064, 6065, 
  6066, 6067, 6068, 6069, 6070, 6071, 6072, 6073, 3341, 6074, 6075, 6076, 6077, 6078, 6079, 6080, 1280, 2134, 6081, 6061, 6062, 6063, 6064, 6065, 
  6066, 6067, 6068, 6069, 6070, 6071, 6072, 6073, 3341, 6074, 6075, 6076, 6077, 6078, 6079, 6080, 1280, 2134, 6081, 6082, 6083, 6084, 6085, 6086, 
  6087, 6088, 6076, 6089, 6090, 6091, 6092, 6093, 6094, 6095, 6096, 6097, 6098, 6099, 6100, 6101, 6102, 6103, 6104, 6105, 6106, 160, 161, 93, 
  163, 163, 164, 34, 93, 94, 165, 166, 100, 101, 102, 105, 106, 108, 109, 110, 168, 113, 113, 6107, 6108, 6109, 6110, 6111, 
  6112, 6113, 6114, 6115, 6116, 6117, 6118, 6119, 6120, 6121, 6122, 6123, 6124, 6125, 6126, 6127, 6128, 6129, 6130, 6107, 6108, 6109, 6110, 6111, 
  6112, 6113, 6114, 6115, 6116, 6117, 6118, 6119, 6120, 6121, 6122, 6123, 6124, 6125, 6126, 6127, 6128, 6129, 6130, 6131, 6132, 6133, 6134, 6135, 
  6136, 6137, 6138, 6139, 6140, 6141, 6142, 6143, 6144, 6145, 6146, 6147, 6148, 6149, 6150, 6151, 6152, 6153, 6154, 909, 759, 457, 161, 93, 
  258, 212, 34, 92, 214, 165, 215, 216, 217, 105, 106, 110, 6155, 6155, 409, 410, 411, 412, 43, 413, 414, 415, 416, 417, 
  418, 419, 420, 421, 495, 423, 43, 424, 425, 426, 427, 428, 429, 3385, 409, 410, 411, 412, 43, 413, 414, 415, 416, 417, 
  418, 419, 420, 421, 495, 423, 43, 424, 425, 426, 427, 428, 429, 3385, 6156, 432, 433, 434, 6157, 6158, 437, 6159, 6160, 6161, 
  6162, 6163, 6164, 6165, 6166, 6167, 6168, 6169, 2700, 2701, 909, 759, 457, 161, 93, 258, 212, 34, 92, 214, 165, 215, 216, 217, 
  105, 106, 110, 0, 1, 408, 408, 6170, 6171, 2064, 6172, 6173, 6174, 6175, 6176, 6177, 6178, 6179, 6180, 3289, 1541, 2064, 2072, 6173, 
  6181, 6182, 2074, 2821, 2076, 1547, 2077, 6170, 6171, 2064, 6172, 6173, 6174, 6175, 6176, 6177, 6178, 6179, 6180, 3289, 1541, 2064, 2072, 6173, 
  6181, 6182, 2074, 2821, 2076, 1547, 2077, 6183, 6184, 6185, 6186, 6187, 6188, 6189, 6190, 6191, 6192, 6193, 6194, 6195, 6196, 6197, 6198, 6199, 
  6200, 6201, 6202, 6203, 6204, 6205, 6206, 6207, 6208, 6209, 6210, 6211, 581, 6212, 6213, 6214, 6215, 6216, 6217, 6218, 6219, 6220, 1478, 1479, 
  1480, 1417, 1418, 1419, 6221, 6222, 6223, 6224, 6225, 1426, 109, 110, 1013, 1014, 1015, 1016, 1017, 1018, 1019, 1020, 2245, 2246, 1032, 1024, 
  3811, 3812, 1015, 1016, 1017, 1018, 3813, 3814, 3815, 6226, 3817, 3818, 1013, 1014, 1015, 1016, 1017, 1018, 1019, 1020, 2245, 2246, 1032, 1024, 
  3811, 6227, 1015, 1016, 1017, 1018, 3813, 3814, 3815, 6226, 3817, 3818, 6228, 6229, 6230, 6231, 6232, 6233, 6234, 3821, 2258, 1334, 1335, 3822, 
  2260, 2261, 6235, 6236, 6237, 6238, 3827, 3828, 3829, 3830, 6239, 6240, 3831, 2273, 457, 161, 93, 209, 259, 260, 261, 262, 210, 163, 
  529, 34, 92, 93, 531, 4077, 311, 1681, 165, 166, 533, 101, 534, 103, 3834, 105, 106, 107, 108, 37, 38, 6241, 6242, 6243, 
  6244, 6245, 6246, 6247, 6248, 6249, 6250, 6251, 6252, 6253, 6254, 6255, 6256, 6257, 6258, 6259, 6260, 6261, 6262, 6263, 6264, 6241, 6242, 6243, 
  6244, 6245, 6246, 6247, 6248, 6249, 6250, 6251, 6252, 6253, 6254, 6255, 6256, 6257, 6258, 6259, 6260, 6261, 6262, 6263, 6264, 6265, 5662, 6266, 
  6267, 6268, 6269, 6270, 438, 439, 440, 441, 442, 4340, 444, 6271, 6272, 6273, 6274, 3643, 3644, 3645, 3646, 6275, 6276, 4491, 6277, 457, 
  161, 93, 258, 212, 34, 92, 214, 165, 215, 216, 217, 105, 106, 110, 37, 38, 6278, 6279, 411, 6280, 6281, 6282, 6283, 6284, 
  416, 6285, 418, 6286, 6287, 6288, 6289, 6290, 6291, 4727, 6292, 6293, 6294, 1718, 6295, 6296, 6278, 6279, 411, 6280, 6281, 6282, 6283, 6284, 
  416, 6285, 418, 6286, 6287, 6288, 6289, 6290, 6291, 4727, 6292, 6293, 6294, 1718, 6295, 6296, 2511, 6297, 6298, 6299, 4718, 4719, 437, 6300, 
  6301, 6302, 6303, 4725, 6304, 6305, 6306, 6307, 6308, 6309, 6306, 6307, 6308, 6309, 6310, 6311, 2531, 6312, 457, 161, 93, 258, 212, 34, 
  92, 214, 165, 215, 216, 217, 105, 106, 110, 1, 6313, 6314, 3250, 3282, 2751, 6315, 6316, 6317, 6318, 6319, 6320, 6321, 1112, 548, 
  472, 6322, 2751, 6315, 6323, 6317, 1374, 554, 1375, 1119, 6313, 6314, 3250, 3282, 2751, 6315, 6316, 6317, 6318, 6319, 6320, 6321, 1112, 548, 
  472, 6322, 2751, 6315, 6323, 6317, 1374, 554, 1375, 1119, 6324, 6325, 3296, 6326, 6327, 6328, 6329, 6330, 6331, 472, 4066, 6332, 6333, 5263, 
  6334, 6335, 6336, 6337, 2794, 2795, 2796, 2797, 6338, 6339, 160, 161, 162, 163, 164, 34, 92, 93, 94, 165, 166, 101, 102, 103, 
  105, 106, 1144, 1145, 168, 37, 6340, 6341, 6342, 6343, 6344, 6345, 6346, 6347, 6348, 6349, 6350, 6351, 420, 421, 495, 423, 6344, 6352, 
  6353, 6354, 427, 428, 429, 3385, 6340, 6341, 6342, 6343, 6344, 6345, 6346, 6347, 6348, 6349, 6350, 6351, 420, 421, 495, 423, 6344, 6352, 
  6353, 6354, 427, 428, 429, 3385, 6355, 6356, 2402, 6357, 6358, 6359, 6360, 6361, 6362, 2409, 6363, 6364, 6365, 6366, 6367, 6368, 6369, 6370, 
  2794, 2795, 2796, 2797, 909, 759, 160, 161, 164, 34, 92, 93, 94, 165, 166, 100, 101, 102, 103, 105, 106, 1144, 1145, 109, 
  110, 168, 0, 318, 6371, 6372, 6373, 6374, 6375, 6376, 6377, 6378, 6379, 6380, 6381, 6382, 187, 6383, 6384, 6385, 4464, 6386, 928, 929, 
  930, 931, 6387, 6388, 6371, 6372, 6373, 6374, 6375, 6376, 6377, 6378, 6379, 6380, 6381, 6382, 187, 6383, 6384, 6385, 4464, 6386, 928, 929, 
  930, 931, 6387, 6388, 6389, 432, 433, 434, 6390, 436, 437, 928, 439, 440, 441, 2410, 4340, 444, 6391, 6392, 6393, 6394, 457, 161, 
  93, 258, 163, 212, 34, 213, 214, 165, 166, 216, 217, 105, 106, 108, 109, 110, 168, 6395, 6396, 6397, 6398, 6399, 6400, 6401, 
  6402, 6403, 6404, 6405, 6406, 6407, 6396, 6397, 6398, 6399, 6400, 6401, 6402, 6403, 6404, 6405, 6406, 6395, 6396, 6397, 6398, 6399, 6400, 6401, 
  6402, 6403, 6404, 6405, 6406, 6407, 6396, 6397, 6398, 6399, 6400, 6401, 6402, 6403, 6404, 6405, 6406, 6408, 6409, 6410, 6411, 6412, 6413, 6414, 
  6408, 6409, 6410, 6411, 6412, 6413, 6414, 4331, 6415, 6416, 6417, 6418, 43, 6419, 6420, 6421, 6422, 6423, 6424, 6425, 6426, 6427, 6428, 6429, 
  43, 1659, 6430, 6431, 6432, 6433, 6434, 6435, 6415, 6416, 6417, 6418, 43, 6419, 6420, 6421, 6422, 6423, 6424, 6425, 6426, 6427, 6428, 6429, 
  43, 1659, 6430, 6431, 6432, 6433, 6434, 6435, 6436, 6437, 6438, 6439, 6440, 6441, 6442, 6443, 6444, 6445, 4137, 6446, 726, 6447, 6448, 6449, 
  6450, 6451, 6452, 6453, 6454, 6455, 457, 161, 93, 406, 111, 112, 109, 110, 406, 407, 34, 92, 93, 531, 311, 532, 98, 99, 
  2825, 101, 534, 103, 104, 105, 106, 107, 1006, 109, 110, 0, 318, 767, 408, 408, 6456, 959, 592, 960, 1429, 1430, 1431, 597, 
  963, 964, 965, 966, 6457, 667, 668, 669, 1429, 6458, 6459, 672, 6460, 674, 6461, 676, 6456, 959, 592, 960, 1429, 1430, 1431, 597, 
  963, 964, 965, 966, 6457, 667, 668, 669, 1429, 6458, 6459, 672, 6460, 674, 6461, 676, 6462, 971, 972, 6463, 6464, 6465, 6466, 6467, 
  6468, 6469, 6470, 6471, 6472, 6473, 6474, 6475, 6476, 6477, 6478, 6479, 6480, 6481, 6482, 6483, 6484, 1467, 875, 876, 877, 6485, 210, 6485, 
  6486, 6487, 995, 877, 6488, 6489, 885, 886, 6490, 888, 889, 101, 534, 103, 6491, 1002, 1003, 891, 1004, 1006, 271, 109, 110, 37, 
  38, 6492, 6493, 6494, 6495, 6496, 6497, 6498, 6499, 6500, 6501, 6502, 6503, 6504, 6505, 6506, 6507, 6496, 6497, 6498, 6508, 6509, 6510, 6511, 
  6512, 6492, 6493, 6494, 6495, 6496, 6497, 6498, 6499, 6500, 6501, 6502, 6503, 6504, 6505, 6506, 6507, 6496, 6497, 6498, 6508, 6509, 6510, 6511, 
  6512, 6513, 6514, 6515, 6516, 6517, 6518, 6519, 6520, 6521, 6522, 6523, 6524, 6525, 6526, 6527, 6528, 6529, 6530, 6527, 6528, 6529, 6530, 6531, 
  6532, 209, 6533, 6534, 261, 262, 210, 163, 6535, 6536, 165, 166, 5030, 6537, 6538, 6539, 6540, 6541, 6542, 6543, 6544, 6545, 6546, 6547, 
  6548, 6549, 6550, 6551, 6552, 6553, 6554, 6555, 6556, 6557, 6558, 6559, 6560, 6561, 6562, 6563, 6564, 6565, 6566, 6567, 6568, 6569, 6570, 6571, 
  6572, 6549, 6550, 6551, 6552, 6553, 6554, 6555, 6556, 6557, 6558, 6559, 6560, 6573, 6574, 6575, 6576, 6577, 1500, 6578, 6579, 6580, 6581, 6582, 
  6583, 6584, 6585, 6586, 6587, 6588, 6589, 6590, 6591, 6592, 6593, 6594, 6595, 6596, 6597, 6598, 6599, 6600, 1995, 1996, 1997, 1995, 6601, 6602, 
  6603, 6600, 6604, 6605, 6606, 6607, 6608, 6609, 6610, 6611, 6612, 6613, 6614, 6615, 6616, 6617, 6618, 109, 110, 6619, 6620, 6621, 1150, 1151, 
  1152, 364, 365, 6622, 1154, 6623, 1156, 1157, 6624, 6621, 1150, 1151, 1152, 364, 365, 6625, 1154, 6623, 1156, 1157, 6626, 6621, 1150, 1151, 
  1152, 364, 365, 6627, 1154, 6623, 6628, 1157, 371, 6629, 6630, 1159, 1152, 364, 6631, 373, 1164, 6632, 1162, 1163, 6633, 6634, 6635, 6636, 
  6637, 6638, 6639, 6633, 6634, 6635, 6636, 6637, 6638, 6639, 6640, 6641, 6642, 6643, 6640, 6641, 6642, 6643, 6644, 6645, 6646, 6647, 1678, 213, 
  209, 259, 260, 261, 262, 210, 163, 6535, 34, 92, 213, 6648, 1354, 165, 166, 5030, 37, 38, 5097, 5098, 1015, 1310, 1311, 1018, 
  6649, 5101, 5102, 5103, 5104, 5105, 5106, 5107, 1015, 1320, 1311, 1018, 6649, 5109, 5110, 5111, 5112, 5113, 5097, 5098, 1015, 1310, 1311, 1018, 
  6649, 5101, 5102, 5103, 5104, 5105, 5106, 5107, 1015, 1320, 1311, 1018, 6649, 5109, 5110, 5111, 5112, 5113, 3819, 1026, 6650, 1028, 3820, 1030, 
  1031, 3821, 2258, 6651, 1335, 3822, 2260, 2261, 6652, 6653, 6654, 6655, 6656, 6657, 6658, 6659, 6660, 6661, 1181, 400, 162, 209, 259, 260, 
  261, 262, 210, 163, 529, 34, 92, 162, 2277, 3833, 3613, 3614, 165, 166, 533, 101, 534, 103, 3834, 105, 106, 167, 328, 329, 
  37, 38, 409, 410, 422, 42, 43, 424, 414, 6662, 47, 48, 49, 6663, 420, 421, 422, 423, 43, 424, 425, 6664, 427, 428, 
  429, 899, 409, 410, 422, 42, 43, 424, 414, 6662, 47, 48, 49, 6663, 420, 421, 422, 423, 43, 424, 425, 6664, 427, 428, 
  429, 899, 4343, 6665, 4083, 4084, 6666, 6667, 4087, 6668, 6669, 4090, 4091, 6670, 2149, 928, 6671, 6672, 6673, 6674, 6675, 6676, 6677, 6678, 
  6679, 6680, 6681, 6682, 457, 161, 93, 2826, 111, 112, 109, 110, 210, 163, 529, 34, 92, 93, 531, 311, 532, 2813, 3176, 1615, 
  101, 534, 103, 104, 105, 106, 107, 167, 109, 110, 0, 318, 2193, 89, 0, 318, 37, 2694, 2063, 2104, 2105, 2106, 2107, 2106, 
  2107, 2116, 2117, 37, 37, 6683, 6684, 6685, 42, 6686, 6687, 6688, 6689, 6690, 6691, 6692, 6693, 420, 6694, 495, 423, 6695, 6696, 6697, 
  6698, 500, 6699, 429, 6700, 6683, 6684, 6685, 42, 6686, 6687, 6688, 6689, 6690, 6691, 6692, 6693, 420, 6694, 495, 423, 6695, 6696, 6697, 
  6698, 500, 6699, 429, 6700, 6701, 6702, 6703, 6704, 6705, 6706, 6707, 6708, 6709, 6710, 6711, 6712, 6713, 2412, 6714, 6715, 6716, 6717, 80, 
  81, 82, 83, 6718, 6719, 6720, 6721, 90, 258, 1095, 529, 34, 92, 6722, 6723, 1183, 6724, 2483, 6725, 6726, 104, 6727, 6728, 109, 
  110, 0, 318, 37, 38, 6729, 6730, 6731, 6732, 6733, 6734, 6735, 6736, 6737, 6738, 6739, 6740, 6741, 6742, 6743, 6744, 6745, 6746, 6747, 
  6748, 6749, 6750, 6751, 6752, 6729, 6730, 6731, 6732, 6733, 6734, 6735, 6736, 6737, 6738, 6739, 6740, 6741, 6742, 6743, 6744, 6745, 6746, 6747, 
  6748, 6749, 6750, 6751, 6752, 6753, 6754, 6755, 6756, 6757, 6758, 6759, 6760, 6761, 6762, 6763, 6764, 6765, 6766, 6767, 6768, 6769, 6770, 4221, 
  4222, 4223, 4224, 6771, 6772, 2158, 6773, 160, 161, 93, 163, 163, 164, 34, 93, 94, 165, 166, 100, 101, 102, 105, 106, 108, 
  109, 110, 168, 408, 6774, 6775, 6776, 6777, 6778, 6779, 6780, 6781, 6782, 6783, 6784, 6785, 6786, 6787, 6776, 6788, 6778, 6779, 6789, 6790, 
  6791, 6792, 6793, 6794, 6774, 6775, 6776, 6777, 6778, 6779, 6780, 6781, 6782, 6783, 6784, 6785, 6786, 6787, 6776, 6788, 6778, 6779, 6789, 6790, 
  6791, 6792, 6793, 6794, 6795, 6796, 6797, 6798, 6799, 6800, 6801, 6795, 6796, 6797, 6798, 6799, 6800, 6801, 6802, 6803, 6804, 6805, 6806, 6807, 
  6808, 6809, 6810, 209, 5095, 5096, 328, 329, 163, 6811, 6812, 6536, 6813, 6814, 166, 6815, 6816, 6817, 272, 273, 274, 3013, 3014, 280, 
  3015, 3016, 3017, 3018, 3019, 3020, 3021, 3022, 3023, 3013, 3014, 280, 3015, 3016, 3017, 3018, 3019, 3020, 3021, 3022, 3023, 3013, 3014, 280, 
  3015, 3016, 3017, 3018, 3019, 3020, 3021, 3022, 3023, 3013, 3014, 280, 3015, 3016, 3017, 3018, 3019, 3020, 3021, 3022, 3023, 6818, 3042, 37, 
  37, 6819, 6820, 6821, 6822, 6823, 6824, 6825, 6826, 6827, 6828, 6829, 6830, 420, 421, 495, 423, 497, 424, 425, 2168, 427, 2679, 429, 
  430, 6819, 6820, 6821, 6822, 6823, 6824, 6825, 6826, 6827, 6828, 6829, 6830, 420, 421, 495, 423, 497, 424, 425, 2168, 427, 2679, 429, 
  430, 6831, 6832, 6833, 6834, 6835, 6836, 6837, 5148, 2392, 2399, 6838, 742, 6839, 6840, 6841, 6842, 6843, 6844, 6845, 6846, 6847, 6848, 6849, 
  909, 759, 457, 161, 93, 258, 111, 112, 109, 110, 212, 34, 92, 214, 165, 215, 216, 217, 105, 106, 110, 37, 38, 6850, 
  6851, 6852, 6853, 6854, 6855, 6856, 6857, 6858, 6859, 6860, 6861, 6862, 6863, 6864, 6865, 6866, 6867, 6868, 6869, 6870, 2136, 6871, 6872, 6850, 
  6851, 6852, 6853, 6854, 6855, 6856, 6857, 6858, 6859, 6860, 6861, 6862, 6863, 6864, 6865, 6866, 6867, 6868, 6869, 6870, 2136, 6871, 6872, 6873, 
  6874, 6875, 6876, 6877, 6878, 6879, 5148, 6880, 2412, 927, 6881, 6882, 6883, 6884, 6885, 6886, 6887, 80, 81, 82, 83, 909, 759, 457, 
  161, 93, 258, 212, 34, 92, 214, 165, 215, 216, 217, 105, 106, 110, 0, 318, 767, 408, 408, 6888, 6889, 2161, 42, 719, 
  413, 2162, 2163, 47, 6890, 49, 2164, 6888, 6889, 2161, 42, 719, 413, 2162, 2163, 47, 6890, 49, 2164, 6888, 6889, 2161, 42, 719, 
  413, 2162, 2163, 47, 6890, 49, 2164, 6888, 6889, 2161, 42, 719, 413, 2162, 2163, 47, 6890, 49, 2164, 6891, 63, 6892, 6893, 6894, 
  6895, 6896, 6891, 63, 6892, 6893, 6894, 6895, 6896, 880, 2103, 6897, 6898, 6899, 6900, 358, 358, 1013, 6901, 1015, 6902, 1311, 1312, 1019, 
  6903, 6904, 6905, 6906, 1317, 1013, 6901, 1015, 6902, 1311, 1312, 1019, 6903, 6904, 6905, 6906, 1317, 1013, 6901, 1015, 6902, 1311, 1312, 1019, 
  6903, 6904, 6905, 6906, 1317, 1013, 6901, 1015, 6902, 1311, 1312, 1019, 6903, 6904, 6905, 6906, 1317, 6907, 1034, 6908, 1036, 6909, 1038, 2256, 
  6910, 2258, 6911, 1335, 6912, 2260, 2261, 6913, 6914, 6915, 6916, 6913, 6914, 6915, 6916, 6917, 6918, 6919, 6920, 2945, 210, 167, 259, 260, 
  261, 262, 0, 318, 1042, 2719, 6921, 6922, 6923, 1361, 6924, 1363, 1364, 6925, 2065, 2066, 2067, 2068, 1370, 471, 6926, 549, 6924, 1371, 
  1372, 1373, 1374, 554, 1375, 1376, 6921, 6922, 6923, 1361, 6924, 1363, 1364, 6925, 2065, 2066, 2067, 2068, 1370, 471, 6926, 549, 6924, 1371, 
  1372, 1373, 1374, 554, 1375, 1376, 6927, 6928, 6929, 6930, 6931, 6932, 6933, 6934, 2750, 2342, 3395, 6935, 6936, 6937, 6938, 6939, 6940, 6941, 
  80, 81, 82, 83, 2700, 2701, 6942, 6943, 160, 161, 93, 406, 210, 401, 3402, 34, 92, 93, 94, 5161, 311, 1303, 2813, 3176, 
  2814, 101, 102, 103, 104, 105, 106, 107, 108, 2720, 163, 164, 165, 166, 100, 0, 1, 408, 408, 6944, 6945, 6946, 6947, 6948, 
  6949, 6950, 6951, 6952, 6953, 6954, 6955, 6956, 6957, 6958, 6959, 6960, 6961, 6962, 6963, 6964, 6965, 6966, 6967, 6944, 6945, 6946, 6947, 6948, 
  6949, 6950, 6951, 6952, 6953, 6954, 6955, 6956, 6957, 6958, 6959, 6960, 6961, 6962, 6963, 6964, 6965, 6966, 6967, 2986, 6968, 6969, 6970, 6971, 
  6972, 6973, 2993, 2994, 2995, 2996, 2997, 6974, 6975, 6976, 6977, 6978, 6979, 2794, 2795, 2796, 2797, 6980, 6981, 6982, 6983, 160, 161, 93, 
  163, 163, 164, 34, 93, 94, 165, 166, 100, 101, 102, 105, 106, 108, 109, 110, 168, 6984, 6985, 6986, 6987, 6988, 6989, 6990, 
  6991, 6992, 6993, 6994, 6995, 0, 318, 6996, 6997, 6998, 6999, 7000, 7001, 7002, 7003, 7004, 7005, 7006, 7007, 6996, 6997, 6998, 6999, 7000, 
  7001, 7002, 7003, 7004, 7005, 7006, 7007, 6996, 6997, 6998, 6999, 7000, 7001, 7002, 7003, 7004, 7005, 7006, 7007, 6996, 6997, 6998, 6999, 7000, 
  7001, 7002, 7003, 7004, 7005, 7006, 7007, 7008, 7009, 7010, 7011, 7012, 7013, 7014, 7008, 7009, 7010, 7011, 7012, 7013, 7014, 7015, 7016, 7017, 
  7018, 7019, 7020, 162, 2063, 163, 7021, 34, 7020, 7022, 0, 1, 767, 408, 2719, 1359, 1360, 3250, 1361, 2867, 1363, 1364, 1365, 2065, 
  2066, 2067, 3252, 2069, 2070, 3250, 2072, 2867, 1363, 1364, 2074, 2075, 2076, 1547, 1548, 1359, 1360, 3250, 1361, 2867, 1363, 1364, 1365, 2065, 
  2066, 2067, 3252, 1370, 471, 472, 549, 2867, 1371, 1372, 1373, 1374, 554, 1375, 1119, 2078, 2079, 2080, 2081, 2082, 2083, 2084, 2085, 2086, 
  7023, 2088, 7024, 2090, 2091, 2092, 2093, 2094, 2095, 80, 81, 82, 83, 2700, 2701, 2100, 2101, 1917, 1918, 2103, 33, 210, 880, 2108, 
  34, 92, 2103, 2109, 2708, 2111, 2112, 887, 2190, 3240, 1417, 2114, 1419, 104, 105, 106, 107, 3894, 1425, 1927, 109, 110, 5165, 7025, 
  7026, 7027, 7028, 7029, 7030, 7031, 7032, 7033, 7034, 7035, 7036, 7037, 7038, 7039, 7040, 7041, 7042, 7043, 7044, 7033, 7045, 7046, 7047, 7025, 
  7026, 7027, 7028, 7029, 7030, 7031, 7032, 7033, 7034, 7035, 7036, 7037, 7038, 7039, 7040, 7041, 7042, 7043, 7044, 7033, 7045, 7046, 7047, 7048, 
  7049, 7050, 7051, 7052, 7053, 7054, 7055, 7056, 7050, 7057, 7058, 7059, 7060, 7061, 7062, 7063, 7064, 7065, 7066, 7067, 7068, 7069, 7070, 7071, 
  7072, 7073, 7074, 37, 7075, 7076, 7077, 7078, 43, 2675, 7079, 7080, 7081, 7082, 7083, 7084, 420, 421, 7085, 7086, 43, 424, 425, 426, 
  427, 428, 7087, 899, 7075, 7076, 7077, 7078, 43, 2675, 7079, 7080, 7081, 7082, 7083, 7084, 420, 421, 7085, 7086, 43, 424, 425, 426, 
  427, 428, 7087, 899, 7088, 7089, 7090, 7091, 7092, 7093, 7094, 7095, 7096, 7097, 6384, 7098, 7099, 7100, 7101, 7102, 7103, 7104, 7105, 7106, 
  7107, 7108, 909, 759, 210, 406, 93, 109, 110, 37, 38, 7109, 7110, 7111, 7112, 7113, 7114, 7115, 7116, 7117, 7118, 7119, 7120, 7121, 
  7110, 7122, 7112, 7123, 7124, 502, 7125, 7126, 7127, 7119, 7128, 7109, 7110, 7111, 7112, 7113, 7114, 7115, 7116, 7117, 7118, 7119, 7120, 7121, 
  7110, 7122, 7112, 7123, 7124, 502, 7125, 7126, 7127, 7119, 7128, 7129, 7130, 7131, 7132, 7133, 7134, 7135, 7136, 7137, 7138, 7139, 7140, 7141, 
  7142, 7143, 7144, 7145, 7146, 3751, 3752, 3753, 3754, 7147, 7148, 4552, 7149, 160, 161, 93, 2720, 7150, 7151, 109, 110, 163, 1800, 34, 
  93, 309, 165, 166, 7152, 101, 102, 105, 106, 108, 109, 110, 168, 37, 37, 1682, 1683, 1684, 1685, 1686, 1687, 1688, 1689, 1690, 
  1691, 1692, 1693, 1694, 1695, 1696, 1697, 1698, 1699, 1700, 1701, 1702, 1703, 1704, 1705, 1682, 1683, 1684, 1685, 1686, 1687, 1688, 1689, 1690, 
  1691, 1692, 1693, 1694, 1695, 1696, 1697, 1698, 1699, 1700, 1701, 1702, 1703, 1704, 1705, 1706, 1707, 1708, 1709, 1710, 1711, 1712, 1713, 1714, 
  1715, 1716, 1717, 1718, 1719, 1720, 1721, 1722, 1723, 80, 81, 82, 83, 909, 759, 457, 161, 93, 258, 212, 34, 92, 214, 165, 
  215, 216, 217, 105, 106, 110, 0, 1, 7153, 113, 113, 7154, 7155, 1511, 461, 7156, 7157, 7158, 1515, 1516, 7159, 1518, 7160, 7154, 
  7155, 1511, 461, 7156, 7157, 7158, 1515, 1516, 7159, 1518, 7160, 7154, 7155, 1511, 461, 7156, 7157, 7158, 1515, 1516, 7159, 1518, 7160, 7154, 
  7155, 1511, 461, 7156, 7157, 7158, 1515, 1516, 7159, 1518, 7160, 7161, 7162, 7163, 7164, 7165, 1554, 1555, 7161, 7162, 7163, 7164, 7165, 1554, 
  1555, 258, 93, 7166, 7167, 7168, 7169, 37, 37, 7170, 7171, 7172, 7173, 7174, 7175, 7176, 7177, 7178, 7179, 7180, 7181, 7182, 7183, 7172, 
  7184, 7185, 7186, 7187, 7188, 7189, 7190, 7180, 7191, 7170, 7171, 7172, 7173, 7174, 7175, 7176, 7177, 7178, 7179, 7180, 7181, 7182, 7183, 7172, 
  7184, 7185, 7186, 7187, 7188, 7189, 7190, 7180, 7191, 7192, 7193, 7194, 7195, 7196, 7197, 7198, 7199, 7200, 7201, 7202, 4092, 2150, 7203, 7204, 
  7205, 7206, 7207, 80, 81, 82, 83, 7208, 7209, 7210, 7211, 1677, 1678, 213, 1679, 111, 112, 109, 110, 210, 163, 212, 34, 92, 
  213, 214, 1680, 1681, 165, 216, 217, 104, 105, 106, 109, 110, 7212, 343, 344, 345, 346, 37, 38, 7213, 7214, 7215, 7216, 7217, 
  7218, 7219, 7220, 7221, 7222, 7223, 7224, 7213, 7214, 7215, 7216, 7217, 7218, 7219, 7220, 7221, 7222, 7223, 7224, 7213, 7214, 7215, 7216, 7217, 
  7218, 7219, 7220, 7221, 7222, 7223, 7224, 7213, 7214, 7215, 7216, 7217, 7218, 7219, 7220, 7221, 7222, 7223, 7224, 7225, 7226, 7227, 7228, 7229, 
  7230, 7231, 7232, 7233, 7234, 7235, 7236, 7237, 7238, 7239, 7240, 7241, 7242, 909, 759, 1677, 1678, 213, 1679, 259, 260, 261, 262, 210, 
  1095, 212, 34, 92, 213, 214, 1097, 1680, 1681, 165, 215, 216, 217, 104, 105, 106, 107, 167, 0, 1, 7243, 7244, 7245, 7246, 
  7247, 7248, 7249, 7250, 7251, 7252, 7253, 7254, 5576, 667, 668, 669, 7247, 7248, 7249, 672, 5577, 674, 5578, 676, 5579, 5580, 7255, 5581, 
  617, 5582, 5583, 620, 5584, 5585, 5586, 5587, 7256, 7257, 7258, 7259, 617, 5582, 5583, 7260, 7261, 7262, 7263, 7264, 7265, 7266, 7267, 7268, 
  7269, 7270, 7271, 7272, 7273, 7274, 7275, 7276, 7277, 7278, 7279, 7280, 7281, 7282, 7283, 7284, 7285, 7286, 7287, 7288, 7289, 7290, 7291, 581, 
  210, 2707, 882, 531, 586, 587, 588, 101, 7292, 7293, 7294, 109, 110, 357, 1185, 7295, 7296, 7297, 7298, 7299, 7300, 7301, 7302, 7303, 
  7304, 7305, 7306, 7307, 7308, 7297, 7309, 7299, 7300, 7310, 7311, 7312, 7313, 7314, 7315, 7295, 7296, 7297, 7298, 7299, 7300, 7301, 7302, 7303, 
  7304, 7305, 7306, 7307, 7308, 7297, 7309, 7299, 7300, 7310, 7311, 7312, 7313, 7314, 7315, 7316, 7317, 7318, 7319, 7320, 7321, 7322, 7323, 7324, 
  7325, 7326, 7327, 7328, 7329, 7330, 7331, 7332, 7333, 7334, 7335, 7336, 7337, 7338, 7339, 457, 161, 93, 209, 259, 260, 261, 262, 210, 
  163, 529, 34, 92, 93, 531, 5975, 3613, 7340, 165, 166, 7341, 101, 534, 3615, 105, 106, 3052, 5166, 3054, 3055, 7342, 3057, 7343, 
  3059, 5170, 3061, 3062, 3063, 3052, 5166, 3054, 3055, 7342, 3057, 7343, 3059, 5170, 3061, 3062, 3063, 3052, 5166, 3054, 3055, 7342, 3057, 7343, 
  3059, 5170, 3061, 3062, 3063, 3052, 5166, 3054, 3055, 7342, 3057, 7343, 3059, 5170, 3061, 3062, 3063, 7344, 7345, 7346, 7347, 7348, 7349, 7350, 
  7344, 7345, 7346, 7347, 7348, 7349, 7350, 7351, 7352, 7353, 7354, 7351, 7352, 7353, 7354, 7355, 7356, 2694, 161, 93, 258, 259, 260, 261, 
  262, 34, 166, 105, 37, 37, 7357, 7358, 7359, 7360, 2383, 424, 414, 7361, 7362, 7363, 7364, 7365, 7366, 7367, 7359, 7368, 2383, 424, 
  425, 4125, 7369, 4126, 7370, 899, 7357, 7358, 7359, 7360, 2383, 424, 414, 7361, 7362, 7363, 7364, 7365, 7366, 7367, 7359, 7368, 2383, 424, 
  425, 7371, 7369, 4126, 7370, 899, 7372, 7373, 7374, 7375, 7376, 7377, 7378, 7379, 7380, 7381, 7382, 7383, 7384, 7385, 7386, 7387, 7388, 7389, 
  80, 81, 82, 83, 7390, 7391, 159, 7392, 457, 161, 93, 258, 327, 210, 163, 529, 34, 92, 93, 531, 165, 7393, 216, 101, 
  534, 103, 105, 106, 167, 109, 110, 0, 1, 408, 957, 7394, 7395, 7396, 7397, 2284, 7398, 7399, 7400, 7401, 7402, 3858, 7403, 7404, 
  7405, 472, 7406, 1362, 7407, 3866, 7408, 7409, 7410, 1882, 7411, 7412, 7413, 7414, 7415, 1362, 7416, 7417, 7418, 7419, 7420, 1893, 7421, 7404, 
  7405, 472, 7406, 1362, 7407, 3866, 7408, 7409, 7410, 1882, 7411, 7422, 7423, 7424, 7425, 7426, 7427, 1901, 7428, 7429, 7430, 7431, 7432, 7433, 
  7434, 7435, 7436, 7437, 7438, 7439, 7440, 7441, 7442, 7443, 2766, 457, 161, 93, 7444, 210, 7444, 7445, 882, 883, 93, 531, 2892, 311, 
  532, 586, 7446, 7447, 101, 534, 103, 104, 105, 106, 107, 1006, 109, 110, 0, 318, 408, 408, 7448, 7449, 3250, 3282, 7450, 7451, 
  7452, 1535, 7453, 7454, 7455, 7456, 7448, 7449, 3250, 3282, 7450, 7451, 7452, 1535, 7453, 7454, 7455, 7456, 7448, 7449, 3250, 3282, 7450, 7451, 
  7452, 1535, 7453, 7454, 7455, 7456, 7448, 7449, 3250, 3282, 7450, 7451, 7452, 1535, 7453, 7454, 7455, 7456, 7457, 7458, 7459, 7460, 7461, 7462, 
  7463, 7457, 7458, 7459, 7460, 7461, 7462, 7463, 258, 93, 109, 110, 0, 1, 408, 408, 7464, 7465, 7466, 7467, 7468, 7469, 7470, 7471, 
  7472, 7473, 7474, 7475, 7464, 7465, 7466, 7467, 7468, 7469, 7470, 7471, 7472, 7473, 7474, 7475, 7464, 7465, 7466, 7467, 7468, 7469, 7470, 7471, 
  7472, 7473, 7474, 7475, 7464, 7465, 7466, 7467, 7468, 7469, 7470, 7471, 7472, 7473, 7474, 7475, 7476, 7477, 7478, 7479, 7480, 7481, 7482, 7476, 
  7477, 7478, 7479, 7480, 7481, 7482, 880, 7483, 109, 110, 0, 318, 38, 7484, 7485, 3054, 3055, 7486, 3057, 3058, 7487, 7488, 3061, 3062, 
  3063, 7484, 7485, 3054, 3055, 7486, 3057, 3058, 7487, 7488, 3061, 3062, 3063, 7484, 7489, 3054, 3055, 7486, 3057, 3058, 7487, 3060, 3061, 3062, 
  3063, 7484, 7485, 3054, 3055, 7486, 3057, 3058, 7487, 3060, 3061, 3062, 3063, 3024, 3025, 7490, 3027, 7491, 3029, 7492, 3024, 3025, 7490, 3027, 
  7491, 3029, 3030, 7493, 7494, 7495, 7496, 7493, 7494, 7495, 7496, 7497, 7498, 7499, 3042, 7500, 161, 93, 211, 1571, 3043, 328, 329, 2714, 
  7501, 7502, 6814, 2721, 7503, 217, 105, 106, 259, 260, 261, 262, 0, 318, 7504, 7505, 7506, 485, 3534, 7507, 7508, 2775, 3537, 3538, 
  3539, 7509, 2069, 7510, 2071, 1542, 2910, 2073, 1543, 2820, 1545, 3543, 1547, 7511, 7504, 7505, 7506, 485, 3534, 7507, 7508, 2775, 3537, 3538, 
  3539, 7509, 2069, 7510, 2071, 1542, 2910, 2073, 1543, 2820, 1545, 3543, 1547, 7511, 2783, 7512, 7513, 7514, 7515, 7516, 2787, 3548, 7517, 7518, 
  7519, 7520, 7521, 3551, 4248, 4249, 4250, 4251, 2794, 2795, 2796, 2797, 2807, 526, 2800, 2801, 2811, 258, 258, 2692, 2828, 2802, 2811, 3552, 
  3312, 2808, 2812, 1304, 1305, 2693, 2830, 2831, 2804, 2832, 2809, 535, 107, 1006, 109, 110, 111, 112, 109, 110, 1, 408, 957, 2783, 
  7522, 7523, 7524, 7525, 7526, 2787, 2805, 2791, 2806, 2793, 2700, 2701, 258, 2063, 210, 2720, 7527, 1302, 7528, 535, 1307, 767, 1645, 2847, 
  2848, 1648, 1649, 2733, 2734, 1652, 2849, 2850, 2851, 2852, 1657, 421, 495, 496, 497, 424, 425, 426, 500, 2679, 429, 3352, 1645, 2847, 
  2848, 1648, 1649, 2733, 2734, 1652, 2849, 2850, 2851, 2852, 1657, 421, 495, 496, 497, 424, 425, 426, 500, 2679, 429, 3352, 1662, 1663, 
  1664, 7529, 7530, 7531, 7532, 1669, 1280, 495, 7533, 7534, 7535, 928, 2700, 2701, 7536, 526, 1181, 161, 93, 209, 111, 112, 109, 110, 
  163, 529, 34, 92, 93, 1182, 2803, 1183, 1184, 166, 533, 101, 534, 103, 104, 107, 109, 110, 0, 318, 7537, 7538, 7539, 7540, 
  7541, 7542, 7543, 7544, 7545, 7546, 7547, 7548, 7537, 7538, 7539, 7540, 7541, 7542, 7543, 7544, 7545, 7546, 7547, 7548, 7537, 7538, 7539, 7540, 
  7541, 7542, 7543, 7544, 7545, 7546, 7547, 7548, 7537, 7538, 7539, 7540, 7541, 7542, 7543, 7544, 7545, 7546, 7547, 7548, 7549, 7550, 7551, 7552, 
  7553, 7554, 7555, 7549, 7550, 7551, 7552, 7553, 7554, 7555, 7556, 7557, 7558, 7559, 449, 450, 451, 452, 7560, 6718, 209, 1095, 5126, 1013, 
  1014, 1015, 1016, 1017, 1018, 1019, 1020, 1021, 1022, 1032, 1024, 1013, 1014, 1015, 1016, 1017, 1018, 1019, 1020, 1021, 1022, 1032, 1024, 1013, 
  1014, 1015, 1016, 1017, 1018, 1019, 1020, 1021, 1022, 1032, 1024, 1013, 1014, 1015, 1016, 1017, 1018, 1019, 1020, 1021, 1022, 1032, 1024, 3819, 
  1026, 1027, 1028, 3820, 1030, 1031, 3819, 1026, 1027, 1028, 3820, 1030, 1031, 259, 260, 261, 262, 0, 1040, 37, 38, 7561, 7562, 7563, 
  7564, 7565, 7566, 7567, 7568, 7569, 7570, 7571, 7572, 7573, 7574, 3250, 3291, 7575, 7576, 7577, 7578, 7579, 1546, 1547, 2077, 7580, 7581, 3250, 
  7582, 7575, 7583, 7584, 7578, 7585, 7586, 2067, 2068, 7573, 7574, 3250, 3291, 7575, 7576, 7577, 7578, 7579, 1546, 1547, 2077, 7587, 7588, 3296, 
  7589, 7590, 7591, 7592, 7593, 7594, 2750, 2751, 7595, 2753, 1908, 7596, 7597, 7598, 7599, 7600, 7601, 7602, 161, 406, 2823, 210, 401, 5160, 
  34, 883, 93, 531, 4077, 4077, 532, 7603, 99, 2825, 101, 534, 103, 1577, 105, 106, 107, 108, 109, 110, 0, 318, 767, 113, 
  113, 7604, 7605, 7606, 7607, 7608, 7609, 7610, 7611, 7612, 7613, 7614, 7615, 7616, 7617, 7618, 7619, 7620, 7621, 7622, 7623, 7624, 7625, 7626, 
  7627, 7604, 7605, 7606, 7607, 7608, 7609, 7610, 7611, 7612, 7613, 7614, 7615, 7616, 7617, 7618, 7619, 7620, 7621, 7622, 7623, 7624, 7625, 7626, 
  7627, 7628, 7629, 7630, 7631, 7632, 7633, 7634, 7635, 7636, 7637, 7638, 7639, 7640, 7641, 7642, 7643, 7644, 7645, 7646, 7647, 7648, 7649, 7650, 
  7651, 7652, 7653, 160, 161, 93, 163, 163, 164, 34, 93, 94, 165, 166, 100, 101, 102, 105, 106, 108, 109, 110, 168, 0, 
  318, 767, 408, 957, 7654, 7655, 7656, 7657, 2867, 7658, 7659, 1365, 7660, 7661, 7662, 7663, 7664, 2070, 2071, 2072, 2867, 7665, 7666, 2074, 
  2821, 1546, 1547, 2077, 7654, 7655, 7656, 7657, 2867, 7658, 7659, 1365, 7660, 7661, 7662, 7663, 7664, 2070, 2071, 2072, 2867, 7665, 7666, 2074, 
  2821, 1546, 1547, 2077, 7667, 7668, 7669, 7670, 3361, 7671, 7672, 7673, 3302, 2071, 7674, 3361, 7675, 7676, 7677, 7678, 7679, 7680, 7681, 7682, 
  7683, 7684, 2700, 2701, 7685, 7686, 457, 161, 93, 33, 210, 33, 2707, 34, 92, 93, 531, 2188, 311, 532, 586, 587, 588, 101, 
  534, 103, 104, 105, 106, 107, 108, 109, 110, 7687, 1280, 495, 7688, 7689, 7690, 7691, 7692, 7693, 7694, 7695, 7696, 7697, 7698, 7699, 
  37, 37, 7700, 7701, 7702, 7703, 7704, 7705, 7706, 7707, 7708, 7709, 7710, 7711, 6099, 6100, 6101, 6102, 7712, 7713, 7714, 7715, 7716, 7700, 
  7701, 7702, 7703, 7704, 7705, 7706, 7707, 7708, 7709, 7710, 7711, 6099, 6100, 6101, 6102, 7712, 7713, 7714, 7715, 7716, 7717, 7718, 7719, 7720, 
  435, 436, 7721, 7722, 7723, 7724, 7725, 442, 4340, 443, 7726, 7727, 7728, 7729, 449, 450, 451, 452, 7730, 7731, 455, 456, 457, 161, 
  93, 258, 212, 34, 92, 214, 165, 215, 216, 217, 105, 106, 110, 0, 1, 767, 408, 408, 7732, 7733, 7734, 7735, 821, 7736, 
  7737, 7738, 7739, 7740, 7741, 7742, 5576, 7743, 668, 669, 821, 670, 671, 672, 673, 674, 675, 676, 1616, 658, 592, 659, 594, 660, 
  661, 597, 662, 663, 664, 665, 5576, 7743, 592, 669, 594, 660, 661, 672, 673, 674, 675, 676, 7744, 7745, 972, 6463, 7746, 7747, 
  7748, 7749, 859, 977, 861, 978, 863, 864, 7750, 7751, 7752, 7753, 7754, 7755, 7756, 7757, 7758, 7759, 875, 876, 877, 33, 210, 33, 
  7760, 7761, 7762, 877, 6488, 884, 885, 886, 586, 587, 588, 101, 7292, 103, 890, 1002, 1003, 891, 7763, 271, 109, 110, 7764, 0, 
  318, 7765, 7766, 7767, 7768, 7769, 7770, 7612, 7771, 7772, 7773, 7774, 7775, 7616, 7617, 7618, 7619, 7620, 7621, 7622, 7623, 7624, 7625, 7626, 
  7627, 7765, 7766, 7767, 7768, 7769, 7770, 7612, 7771, 7772, 7773, 7774, 7775, 7616, 7617, 7618, 7619, 7620, 7621, 7622, 7623, 7624, 7625, 7626, 
  7627, 7776, 7777, 7778, 7779, 7780, 7781, 7782, 7783, 7784, 7785, 7786, 7623, 7787, 7788, 7789, 7790, 7791, 7792, 7646, 7647, 7648, 7649, 2692, 
  34, 92, 531, 1302, 311, 532, 1304, 1305, 2693, 101, 534, 103, 104, 105, 106, 107, 1006, 113, 113, 409, 410, 411, 4333, 43, 
  4334, 4335, 4336, 416, 417, 418, 419, 420, 421, 422, 423, 43, 424, 425, 426, 427, 428, 429, 3385, 409, 410, 411, 4333, 43, 
  4334, 4335, 4336, 416, 417, 418, 419, 420, 421, 422, 423, 43, 424, 425, 426, 427, 428, 429, 3385, 4337, 4338, 433, 4339, 435, 
  436, 437, 438, 439, 440, 441, 442, 4340, 444, 445, 446, 447, 448, 449, 450, 451, 452, 4341, 4342, 2158, 159, 457, 161, 93, 
  258, 212, 34, 92, 214, 165, 215, 216, 217, 105, 106, 110, 357, 1185, 7793, 7794, 7795, 7796, 7797, 7798, 7799, 7800, 7801, 7802, 
  7803, 7804, 7805, 7806, 7807, 7808, 1017, 7809, 7810, 7811, 7812, 7813, 7814, 7815, 7793, 7794, 7795, 7796, 7797, 7798, 7799, 7800, 7801, 7802, 
  7803, 7804, 7805, 7806, 7807, 7808, 1017, 7809, 7810, 7811, 7812, 7813, 7814, 7815, 7816, 7817, 7818, 7819, 7820, 7821, 7822, 3821, 2258, 1334, 
  1335, 3822, 2260, 2261, 7823, 7824, 7825, 7826, 7827, 7828, 7829, 7830, 457, 161, 93, 209, 259, 260, 261, 262, 210, 163, 529, 34, 
  92, 93, 531, 311, 532, 165, 166, 533, 101, 534, 103, 3834, 105, 106, 107, 108, 0, 1, 408, 408, 7831, 7832, 7833, 7834, 
  7835, 7836, 7837, 7838, 7839, 7840, 7841, 7842, 7843, 7844, 7845, 7846, 7847, 7848, 7849, 7850, 7851, 7852, 7853, 7854, 7855, 7856, 7857, 7858, 
  7859, 7860, 7861, 7862, 7863, 7864, 7865, 7842, 7843, 7844, 7845, 7846, 7847, 7848, 7849, 7850, 7851, 7852, 7853, 7854, 7866, 7867, 7868, 7869, 
  7870, 7871, 7872, 4782, 7873, 7874, 7875, 7876, 7877, 864, 7878, 7879, 7880, 7881, 7882, 7883, 7884, 7885, 7886, 7887, 7888, 7889, 7890, 7891, 
  7892, 2945, 7893, 109, 110, 37, 38, 7894, 7895, 7896, 7897, 7898, 7899, 7900, 7901, 7902, 7903, 7904, 7905, 7906, 7907, 7908, 7909, 7910, 
  7911, 7912, 7913, 7914, 7915, 7916, 7917, 7894, 7895, 7896, 7897, 7898, 7899, 7900, 7901, 7902, 7903, 7904, 7905, 7906, 7907, 7908, 7909, 7910, 
  7911, 7912, 7913, 7914, 7915, 7916, 7917, 7918, 7919, 7920, 7921, 7922, 7923, 7924, 7925, 7926, 7909, 2520, 7911, 7912, 7927, 445, 446, 447, 
  448, 449, 450, 451, 452, 7928, 7929, 2158, 159, 457, 161, 93, 258, 212, 34, 92, 214, 165, 215, 216, 217, 105, 106, 110, 
  7930, 7931, 7932, 7933, 7934, 7935, 7936, 7937, 7938, 7939, 7940, 7941, 7942, 7943, 7944, 7945, 7934, 7935, 7946, 7947, 7948, 7949, 7950, 7951, 
  7930, 7931, 7932, 7933, 7934, 7935, 7936, 7937, 7938, 7939, 7940, 7941, 7942, 7943, 7944, 7945, 7934, 7935, 7946, 7947, 7948, 7949, 7950, 7951, 
  7952, 7953, 7954, 7955, 7956, 7957, 7958, 7959, 7960, 7961, 7962, 7963, 7964, 7965, 7966, 7967, 7968, 7969, 7966, 7967, 7968, 7969, 7970, 7971, 
  457, 161, 93, 209, 259, 260, 261, 262, 113, 113, 7972, 7973, 7974, 7975, 7976, 7977, 7978, 7979, 7980, 7981, 7982, 7983, 7984, 7985, 
  7986, 7987, 7988, 7989, 7990, 7991, 7992, 7100, 7993, 7994, 7972, 7973, 7974, 7975, 7976, 7977, 7978, 7979, 7980, 7981, 7982, 7983, 7984, 7985, 
  7986, 7987, 7988, 7989, 7990, 7991, 7992, 7100, 7993, 7994, 7995, 432, 433, 434, 7996, 436, 437, 941, 439, 440, 441, 442, 4340, 444, 
  947, 948, 949, 950, 951, 952, 953, 954, 7997, 7998, 204, 6773, 457, 161, 93, 258, 1095, 212, 34, 264, 214, 165, 215, 216, 
  217, 105, 106, 108, 109, 110, 168, 0, 318, 408, 957, 7999, 8000, 8001, 8002, 8003, 8004, 8005, 8006, 8007, 8008, 8009, 8010, 8011, 
  8012, 472, 473, 1362, 8013, 8014, 8015, 8016, 8017, 8018, 8019, 7999, 8000, 8001, 8002, 8003, 8004, 8005, 8006, 8007, 8008, 8009, 8010, 8011, 
  8012, 472, 473, 1362, 8013, 8014, 8015, 8016, 8017, 8018, 8019, 8020, 3354, 8021, 8022, 7461, 8023, 8024, 511, 2788, 472, 8025, 8026, 8027, 
  8028, 8029, 518, 8030, 520, 2794, 2795, 2796, 2797, 2807, 8031, 8032, 8033, 8034, 258, 210, 258, 1301, 34, 8035, 8034, 8036, 3312, 8037, 
  8038, 8039, 1305, 1306, 2830, 2840, 2804, 104, 105, 8040, 107, 108, 0, 318, 8041, 8042, 484, 8043, 8003, 8044, 8045, 8046, 8047, 8048, 
  8049, 8050, 8051, 8052, 472, 549, 1362, 4238, 8053, 8054, 8055, 8056, 8057, 2782, 8041, 8042, 484, 8043, 8003, 8044, 8045, 8046, 8047, 8048, 
  8049, 8050, 8051, 8052, 472, 549, 1362, 4238, 8053, 8054, 8055, 8056, 8057, 2782, 7457, 8058, 8059, 8060, 8061, 8062, 8063, 132, 2788, 472, 
  4066, 4067, 4068, 3363, 8064, 8065, 8066, 8067, 521, 522, 523, 524, 8031, 526, 160, 161, 93, 209, 163, 164, 34, 92, 93, 94, 
  2803, 311, 1303, 165, 166, 100, 101, 102, 103, 104, 105, 8068, 107, 108, 109, 110, 38, 7484, 8069, 3054, 8070, 8071, 3057, 8072, 
  8073, 8074, 8075, 3062, 8076, 7484, 8069, 3054, 8070, 8071, 3057, 8072, 8073, 8074, 8075, 3062, 8076, 7484, 8069, 3054, 8070, 8071, 3057, 8072, 
  8073, 8074, 8075, 3062, 8076, 7484, 8069, 3054, 8070, 8071, 3057, 8072, 8073, 8074, 8075, 3062, 8076, 8077, 8078, 8079, 8080, 8081, 8082, 8083, 
  8077, 8078, 8079, 8080, 8081, 8082, 8083, 8084, 8085, 8086, 8087, 8088, 8089, 8090, 8091, 8092, 8093, 8094, 8095, 1677, 259, 260, 261, 262, 
  1097, 1013, 8096, 8097, 8098, 1017, 1018, 1019, 8099, 5102, 8100, 1032, 8101, 8102, 8103, 1015, 8104, 1017, 1018, 8105, 8106, 8107, 5111, 8108, 
  8109, 1013, 8096, 8097, 8098, 1017, 1018, 1019, 8099, 5102, 5103, 1032, 8101, 8102, 8103, 1015, 8104, 1017, 1018, 8110, 8106, 8107, 5111, 8108, 
  8109, 8111, 8112, 8113, 8114, 8115, 8116, 8117, 8118, 8119, 8120, 8121, 8122, 8123, 8124, 8125, 8126, 8127, 8128, 8125, 8126, 8127, 8128, 8129, 
  8130, 1677, 1678, 213, 1679, 259, 260, 261, 262, 210, 1095, 212, 34, 92, 213, 214, 5191, 1680, 1681, 165, 215, 216, 217, 104, 
  105, 106, 107, 167, 0, 1, 767, 408, 408, 8131, 8132, 8133, 8134, 8135, 8136, 8137, 8138, 8139, 8140, 8141, 8142, 8143, 8144, 8145, 
  8146, 8147, 8148, 8149, 8150, 8151, 8152, 8153, 8154, 8131, 8132, 8133, 8134, 8135, 8136, 8137, 8138, 8139, 8140, 8141, 8142, 8143, 8144, 8145, 
  8146, 8147, 8148, 8149, 8150, 8151, 8152, 8153, 8154, 8155, 8156, 8157, 8158, 8159, 8160, 8161, 8162, 8163, 8164, 8165, 8166, 8167, 8168, 8169, 
  8170, 8171, 8172, 109, 110, 8173, 8173, 8174, 8175, 8176, 8177, 1908, 8178, 2342, 8179, 7593, 8180, 8181, 8182, 8183, 8184, 8185, 8186, 8187, 
  8188, 8189, 8190, 8191, 8192, 8193, 160, 161, 93, 33, 33, 3275, 34, 92, 93, 94, 311, 1303, 586, 166, 2113, 101, 102, 103, 
  104, 105, 106, 107, 167, 0, 318, 113, 113, 8194, 8195, 8196, 1648, 8197, 8198, 8199, 8200, 8201, 8202, 2738, 2739, 420, 3347, 495, 
  496, 719, 424, 425, 2168, 500, 3351, 429, 430, 8194, 8195, 8196, 1648, 8197, 8198, 8199, 8200, 8201, 8202, 2738, 2739, 420, 3347, 495, 
  496, 719, 424, 425, 2168, 500, 3351, 429, 430, 8203, 8204, 8205, 8206, 8207, 8208, 8209, 2407, 8210, 8211, 2519, 8212, 747, 928, 8213, 
  759, 2800, 2801, 2811, 163, 2692, 2828, 2802, 2811, 3552, 1304, 166, 2693, 101, 534, 103, 329, 1, 113, 113, 2200, 2201, 2202, 2203, 
  2204, 2205, 2206, 2207, 2208, 2209, 2210, 2211, 2212, 2213, 495, 2214, 2204, 2215, 2216, 2207, 2217, 428, 2218, 2219, 2200, 2201, 2202, 2203, 
  2204, 2205, 2206, 2207, 2208, 2209, 2210, 2211, 2212, 2213, 495, 2214, 2204, 2215, 2216, 2207, 2217, 428, 2218, 2219, 2220, 2221, 2222, 2223, 
  4683, 2224, 2225, 442, 2226, 2227, 2228, 2229, 2230, 2231, 2232, 2233, 2234, 2235, 2236, 2237, 2238, 2239, 4688, 4689, 2242, 2243, 160, 161, 
  162, 163, 164, 34, 92, 93, 94, 165, 166, 101, 102, 103, 105, 106, 1144, 1145, 168, 0, 318, 2817, 2817, 8214, 8215, 8216, 
  8217, 8218, 8219, 8220, 8221, 8222, 8223, 8224, 8225, 8226, 7189, 8227, 2151, 8228, 8229, 8230, 8231, 6880, 8232, 8233, 8234, 8214, 8215, 8216, 
  8217, 8218, 8219, 8220, 8221, 8222, 8223, 8224, 8225, 8226, 7189, 8227, 2151, 8228, 8229, 8230, 8231, 6880, 8232, 8233, 8234, 8235, 8236, 8237, 
  8238, 8239, 8240, 8241, 8242, 8243, 8244, 8245, 8246, 8247, 8248, 8249, 8250, 8251, 8252, 8253, 8254, 8255, 8256, 8257, 8258, 8259, 8260, 160, 
  161, 162, 163, 164, 34, 92, 94, 165, 166, 101, 102, 103, 105, 106, 1144, 1145, 168, 0, 1, 113, 113, 8261, 8262, 8263, 
  8264, 8265, 8266, 8267, 8268, 8269, 8270, 8271, 8272, 8273, 8274, 8275, 8276, 8277, 8278, 8279, 8280, 8281, 8282, 8283, 8284, 8261, 8262, 8263, 
  8264, 8265, 8266, 8267, 8268, 8269, 8270, 8271, 8272, 8273, 8274, 8275, 8276, 8277, 8278, 8279, 8280, 8281, 8282, 8283, 8284, 8285, 8286, 8287, 
  8288, 8289, 8290, 8291, 8292, 8293, 8294, 8295, 8296, 8297, 8298, 8299, 8300, 8301, 8302, 8303, 8304, 8305, 8306, 8307, 8308, 8309, 8310, 160, 
  161, 162, 163, 164, 34, 92, 94, 165, 166, 101, 102, 103, 105, 106, 1144, 1145, 168, 0, 1, 113, 113, 8311, 8312, 8313, 
  8314, 8315, 8316, 8317, 8318, 8319, 8320, 8321, 8322, 8323, 8324, 8325, 8326, 474, 5890, 5891, 8327, 8328, 8329, 8330, 8331, 8311, 8312, 8313, 
  8314, 8315, 8316, 8317, 8318, 8319, 8320, 8321, 8322, 8323, 8324, 8325, 8326, 474, 5890, 5891, 8327, 8328, 8329, 8330, 8331, 8332, 8333, 8334, 
  8335, 8336, 8337, 8338, 8339, 8340, 8341, 8342, 8343, 8344, 8345, 8346, 8347, 8348, 8349, 8350, 8351, 8352, 8353, 8354, 8355, 8356, 8357, 160, 
  161, 162, 163, 164, 34, 92, 94, 165, 166, 101, 102, 103, 105, 106, 1144, 1145, 168, 8358, 8359, 8360, 8361, 8362, 8363, 8364, 
  8365, 8366, 8367, 8368, 8369, 8370, 8371, 8360, 8372, 8362, 8363, 8373, 8374, 8375, 8376, 8377, 8378, 8358, 8359, 8360, 8361, 8362, 8363, 8364, 
  8365, 8366, 8367, 8368, 8369, 8370, 8371, 8360, 8372, 8362, 8363, 8373, 8374, 8375, 8376, 8377, 8378, 8379, 8380, 8381, 8382, 8383, 8384, 8385, 
  8386, 8387, 8388, 8389, 8390, 8391, 8392, 8393, 8394, 8395, 8396, 8393, 8394, 8395, 8396, 8397, 8398, 8399, 8400, 8401, 8402, 8403, 8404, 8405, 
  8406, 8407, 37, 38, 8408, 8409, 8410, 8411, 8412, 8413, 8414, 8415, 8416, 8417, 8418, 8419, 8408, 8409, 8410, 8411, 8412, 8413, 8414, 8415, 
  8416, 8417, 8418, 8419, 8408, 8409, 8410, 8411, 8412, 8413, 8414, 8415, 8416, 8417, 8418, 8419, 8408, 8409, 8410, 8411, 8412, 8413, 8414, 8415, 
  8416, 8417, 8418, 8419, 8420, 8421, 8422, 8423, 8424, 8425, 8426, 8420, 8421, 8427, 8423, 8428, 8429, 8430, 8431, 8432, 8433, 8434, 8435, 8436, 
  8437, 8438, 8439, 8440, 8441, 8442, 2476, 8443, 2481, 2482, 8444, 8445, 167, 272, 273, 274, 0, 1, 767, 408, 957, 8446, 8447, 7396, 
  8448, 8449, 8450, 8451, 8452, 2288, 8453, 8454, 2291, 1370, 471, 472, 549, 8455, 8456, 8457, 1373, 1374, 554, 1375, 1376, 3918, 3919, 8458, 
  3251, 8455, 8456, 8457, 1365, 2065, 3927, 2067, 2068, 1370, 471, 472, 549, 8455, 8456, 8457, 1373, 1374, 554, 1375, 1376, 8459, 8460, 8461, 
  8462, 8463, 8464, 1901, 1902, 1903, 8465, 1905, 6038, 8466, 1908, 8467, 8468, 8469, 8470, 8471, 6049, 1917, 1918, 1919, 1919, 326, 327, 328, 
  329, 210, 1919, 1921, 165, 883, 1919, 1921, 1922, 1923, 1924, 165, 1415, 1925, 1415, 1925, 1419, 1926, 105, 106, 107, 3894, 1425, 1927, 
  328, 329, 271, 109, 110, 0, 318, 767, 408, 957, 1359, 1360, 8458, 1361, 1362, 2298, 2299, 8472, 2065, 2066, 2067, 2068, 2069, 2070, 
  2071, 2072, 1362, 2073, 1543, 8473, 2075, 2076, 1547, 2077, 1359, 1360, 8458, 1361, 1362, 2298, 2299, 8472, 2065, 2066, 2067, 2068, 2069, 2070, 
  2071, 2072, 1362, 2073, 1543, 8473, 2075, 2076, 1547, 2077, 8474, 8475, 8476, 8477, 8478, 8479, 1901, 8480, 7429, 7024, 8481, 8482, 8483, 7434, 
  8484, 8485, 8486, 8487, 8488, 8489, 8490, 8491, 1913, 3913, 3885, 6049, 2186, 1918, 2103, 1919, 210, 1919, 8492, 34, 92, 2103, 2187, 1922, 
  2111, 2189, 165, 1415, 1416, 1417, 1418, 1419, 104, 105, 106, 107, 1425, 1426, 109, 110, 0, 1, 767, 408, 408, 8493, 8494, 8495, 
  8496, 8497, 8498, 8499, 8500, 8501, 8502, 8503, 8504, 8505, 8506, 8507, 8508, 8509, 8510, 8511, 8512, 8513, 8514, 8515, 8516, 8493, 8494, 8495, 
  8496, 8497, 8498, 8499, 8500, 8501, 8502, 8503, 8504, 8505, 8506, 8507, 8508, 8509, 8510, 8511, 8512, 8513, 8514, 8515, 8516, 8517, 8518, 8519, 
  8520, 8521, 8522, 8523, 8524, 8525, 1362, 8526, 8527, 8528, 8168, 8529, 8530, 8531, 8532, 8533, 8534, 8535, 8536, 3234, 8537, 8192, 8193, 8538, 
  8539, 8540, 880, 2709, 2710, 2711, 2712, 880, 2108, 882, 883, 8540, 8541, 8542, 8543, 3239, 2190, 3240, 3971, 8544, 3973, 1577, 105, 106, 
  107, 1927, 2711, 2712, 271, 2116, 2117, 8545, 37, 38, 8546, 8547, 8548, 8549, 8550, 8551, 8552, 8553, 8554, 8555, 8556, 8557, 8558, 8559, 
  7119, 8560, 8561, 8562, 8563, 4466, 8564, 8565, 8566, 8567, 8546, 8547, 8548, 8549, 8550, 8551, 8552, 8553, 8554, 8555, 8556, 8557, 8558, 8559, 
  7119, 8560, 8561, 8562, 8563, 4466, 8564, 8565, 8566, 8567, 8568, 8569, 8205, 8206, 8570, 8208, 8571, 8572, 8573, 8574, 8575, 8576, 8577, 2507, 
  6884, 6885, 6886, 6887, 80, 81, 82, 83, 909, 759, 109, 110, 37, 38, 8578, 8579, 8580, 8581, 8582, 8583, 8584, 1652, 8585, 8586, 
  8587, 8588, 420, 421, 495, 496, 497, 424, 6697, 8589, 5715, 428, 7087, 899, 8590, 8579, 8580, 8581, 8582, 8583, 8584, 8591, 8592, 8586, 
  8587, 8588, 420, 421, 495, 496, 497, 424, 6697, 8589, 5715, 428, 7087, 899, 8593, 8594, 8595, 8596, 8597, 8598, 8599, 8600, 6669, 8601, 
  8602, 8603, 8604, 8605, 8606, 8607, 8608, 8609, 449, 450, 451, 452, 8610, 8611, 909, 759, 1677, 1678, 2699, 2063, 111, 112, 109, 110, 
  1095, 212, 34, 92, 213, 214, 5191, 1680, 1681, 165, 215, 216, 217, 104, 105, 106, 107, 343, 344, 345, 346, 0, 1, 408, 
  957, 8612, 8613, 3250, 8614, 1362, 8615, 8616, 8617, 8618, 8619, 8620, 8621, 1370, 8622, 472, 8623, 1362, 8624, 8625, 8626, 8627, 8628, 8629, 
  8630, 8612, 8613, 3250, 8614, 1362, 8615, 8616, 8617, 8618, 8619, 8620, 8621, 1370, 8622, 472, 8623, 1362, 8624, 8625, 8626, 8627, 8628, 8629, 
  8630, 8631, 8632, 8633, 8634, 8635, 8636, 8637, 8638, 8639, 472, 8640, 8641, 8642, 8627, 8643, 8644, 8645, 8646, 8647, 8648, 8649, 8650, 8651, 
  8652, 8653, 8654, 457, 161, 93, 2327, 8655, 8656, 109, 110, 210, 880, 881, 34, 92, 93, 531, 8657, 311, 532, 887, 888, 889, 
  101, 534, 103, 104, 4408, 4409, 107, 1006, 109, 110, 343, 344, 345, 346, 343, 344, 345, 346, 0, 318, 408, 957, 1427, 1428, 
  592, 960, 1429, 1438, 1439, 597, 1433, 1434, 1435, 1436, 602, 1437, 604, 605, 1429, 1438, 1439, 608, 968, 610, 1441, 1442, 1427, 1428, 
  592, 960, 1429, 1438, 1439, 597, 1433, 1434, 1435, 1436, 602, 1437, 604, 605, 1429, 1438, 1439, 608, 968, 610, 1441, 1442, 8658, 8659, 
  1445, 6463, 1447, 1448, 857, 1449, 1450, 1451, 8660, 1453, 1454, 1455, 8661, 8662, 8663, 8664, 8665, 8666, 8667, 8668, 1466, 1467, 1403, 1404, 
  1406, 1406, 1406, 1407, 1408, 1473, 1405, 1410, 8669, 1412, 8670, 8671, 1415, 1925, 1417, 2114, 1419, 1420, 1421, 1422, 1423, 1424, 3894, 1927, 
  109, 110, 1443, 1444, 1446, 1452, 8672, 8673, 592, 8674, 592, 8674, 1443, 1446, 8672, 8673, 592, 8674, 592, 8674, 0, 318, 408, 957, 
  1359, 1360, 538, 1361, 1362, 1371, 1372, 8472, 1366, 1367, 1368, 1369, 1370, 471, 472, 549, 1362, 1371, 1372, 8675, 1374, 554, 1375, 1376, 
  1359, 1360, 538, 1361, 1362, 1371, 1372, 8472, 1366, 1367, 1368, 1369, 1370, 471, 472, 549, 1362, 1371, 1372, 8675, 1374, 554, 1375, 1376, 
  8474, 8676, 1379, 8477, 1381, 1382, 1383, 1384, 1385, 1386, 8677, 1388, 1389, 1390, 8678, 8679, 8680, 8681, 3895, 3896, 3897, 3898, 1401, 1402, 
  1403, 1404, 1406, 1406, 1406, 1407, 1408, 1473, 1405, 1410, 8669, 1412, 8670, 8671, 1415, 1925, 1417, 2114, 1419, 1420, 1421, 1422, 1423, 1424, 
  3894, 1927, 109, 110, 1377, 1378, 1380, 1387, 8682, 8683, 538, 2780, 538, 2780, 1377, 1380, 8682, 8683, 538, 2780, 538, 2780, 37, 37, 
  8684, 8685, 8686, 8687, 8688, 8689, 8690, 8691, 8692, 8693, 8694, 8695, 8696, 4951, 8697, 8698, 8699, 420, 8700, 8701, 8702, 8703, 8704, 8705, 
  8684, 8685, 8686, 8687, 8688, 8689, 8690, 8691, 8692, 8693, 8694, 8695, 8696, 4951, 8697, 8698, 8699, 420, 8700, 8701, 8702, 8703, 8704, 8705, 
  8706, 8707, 7090, 7091, 7092, 7093, 8708, 5148, 8709, 7097, 6384, 7098, 7099, 8710, 109, 110, 111, 112, 109, 110, 0, 318, 37, 37, 
  409, 8711, 4079, 42, 8712, 413, 2162, 4080, 8713, 48, 8714, 8715, 420, 8716, 495, 423, 8712, 424, 425, 8717, 8718, 428, 8719, 8720, 
  409, 8711, 4079, 42, 8712, 413, 2162, 4080, 8713, 48, 8714, 8715, 420, 8716, 495, 423, 8712, 424, 425, 8717, 8718, 428, 8719, 8720, 
  4081, 8721, 8722, 8723, 8724, 8725, 8726, 8727, 4089, 8728, 8729, 8730, 2149, 7912, 8731, 8732, 8733, 8734, 80, 81, 82, 83, 4097, 1144, 
  457, 161, 93, 209, 2709, 2710, 2711, 2712, 210, 163, 529, 34, 92, 162, 531, 266, 311, 532, 165, 166, 533, 101, 534, 103, 
  104, 105, 106, 107, 108, 2106, 2107, 2116, 2117, 893, 8735, 8736, 8737, 8738, 8739, 8740, 8741, 8742, 8743, 8744, 8745, 8746, 8735, 8736, 
  8737, 8738, 8739, 8740, 8741, 8742, 8743, 8744, 8745, 8746, 8735, 8736, 8737, 8738, 8739, 8740, 8741, 8742, 8743, 8744, 8745, 8746, 8735, 8736, 
  8737, 8738, 8739, 8740, 8741, 8742, 8743, 8744, 8745, 8746, 8747, 8748, 8749, 8750, 8751, 8752, 8753, 8747, 8748, 8749, 8750, 8751, 8752, 8753, 
  0, 1, 767, 408, 408, 6921, 6922, 3250, 1361, 1362, 1363, 1364, 8754, 2065, 2066, 2067, 2068, 2069, 2070, 3250, 2072, 1362, 1363, 1364, 
  2074, 2075, 2076, 1547, 2077, 6921, 6922, 3250, 1361, 1362, 1363, 1364, 8754, 2065, 2066, 2067, 2068, 2069, 2070, 3250, 2072, 1362, 1363, 1364, 
  2074, 2075, 2076, 1547, 2077, 8755, 6984, 8756, 2081, 2082, 2083, 8757, 8758, 8759, 8760, 8761, 8762, 8012, 8763, 8764, 8765, 8766, 8767, 80, 
  81, 82, 83, 8768, 8769, 2100, 2101, 160, 161, 93, 2703, 34, 92, 93, 94, 3319, 311, 1303, 166, 100, 101, 102, 103, 104, 
  105, 106, 107, 108, 109, 110, 880, 880, 2110, 8770, 8771, 880, 2104, 2710, 2711, 2712, 880, 2108, 2708, 3239, 888, 2113, 2106, 2107, 
  271, 2116, 2117, 893, 409, 410, 411, 412, 43, 413, 414, 415, 416, 417, 418, 419, 420, 421, 422, 423, 43, 424, 425, 426, 
  427, 428, 429, 3385, 409, 410, 411, 412, 43, 413, 414, 415, 416, 417, 418, 419, 420, 421, 422, 423, 43, 424, 425, 426, 
  427, 428, 429, 3385, 431, 432, 433, 434, 435, 436, 437, 431, 432, 433, 434, 435, 436, 437, 8772, 8773, 8774, 8775, 8772, 8773, 
  8774, 8775, 2158, 159, 457, 161, 93, 258, 163, 529, 34, 92, 93, 531, 266, 311, 532, 165, 166, 533, 101, 534, 103, 104, 
  105, 106, 107, 108, 109, 110, 0, 318, 2803, 8776, 8777, 8778, 8779, 8780, 8781, 8782, 8783, 8784, 8785, 8786, 8787, 8788, 8777, 8778, 
  8779, 8780, 8781, 8782, 8783, 8784, 8789, 8790, 8791, 8776, 8777, 8778, 8779, 8780, 8781, 8782, 8783, 8784, 8785, 8786, 8787, 8788, 8777, 8778, 
  8779, 8780, 8781, 8782, 8783, 8784, 8789, 8790, 8791, 8792, 8793, 8794, 8795, 8796, 8797, 8798, 8799, 8800, 8801, 8802, 8803, 8804, 8798, 8805, 
  8806, 8807, 8808, 8809, 8810, 8811, 8812, 8813, 8814, 8815, 8816, 8817, 8818, 8819, 8820, 259, 260, 261, 262, 307, 163, 1800, 34, 92, 
  8819, 8821, 1302, 8822, 8823, 1304, 1305, 8824, 8825, 8826, 8827, 104, 105, 106, 107, 317, 0, 1, 408, 408, 7394, 7395, 7396, 7397, 
  8828, 8829, 7399, 8830, 7401, 7402, 3858, 7403, 7394, 7395, 7396, 7397, 8828, 8829, 7399, 8830, 7401, 7402, 3858, 7403, 7394, 7395, 7396, 7397, 
  8828, 8829, 7399, 8830, 7401, 7402, 3858, 7403, 7394, 7395, 7396, 7397, 8828, 8829, 7399, 8830, 7401, 7402, 3858, 7403, 8831, 8832, 7424, 8833, 
  8834, 8835, 1901, 8831, 8832, 7424, 8833, 8834, 8835, 1901, 8836, 8837, 33, 93, 357, 38, 8838, 8839, 8840, 8841, 8842, 8843, 8844, 8845, 
  8846, 8847, 8848, 8849, 8850, 8851, 8852, 8853, 8842, 8843, 8844, 8854, 8855, 8856, 8857, 8858, 8838, 8839, 8840, 8841, 8842, 8843, 8844, 8845, 
  8846, 8847, 8848, 8849, 8850, 8851, 8852, 8853, 8842, 8843, 8844, 8854, 8855, 8856, 8857, 8858, 8859, 8860, 8861, 8862, 8863, 8864, 8865, 8866, 
  8867, 8868, 8869, 8870, 8871, 8865, 8872, 8873, 8874, 8875, 8876, 8877, 8878, 8879, 8880, 8881, 1181, 400, 162, 209, 259, 260, 261, 262, 
  210, 163, 529, 34, 92, 162, 1182, 2803, 165, 166, 5162, 103, 105, 106, 167, 343, 344, 345, 346, 2198, 2198, 1185, 38, 8882, 
  8883, 8884, 8885, 8886, 8887, 8888, 8889, 8890, 8891, 8892, 8893, 8894, 8895, 8884, 8896, 8886, 8887, 8888, 8897, 8898, 8899, 8900, 8901, 8882, 
  8883, 8884, 8885, 8886, 8887, 8888, 8889, 8890, 8891, 8892, 8893, 8894, 8895, 8884, 8896, 8886, 8887, 8888, 8897, 8898, 8899, 8900, 8901, 8902, 
  8903, 8904, 8905, 8906, 8907, 8908, 8909, 8910, 8911, 8912, 8913, 8914, 8915, 8916, 8917, 8918, 8919, 8920, 8921, 8922, 8923, 5574, 5575, 8924, 
  400, 162, 209, 259, 260, 261, 262, 163, 6535, 34, 92, 2276, 8925, 8926, 8927, 165, 166, 5030, 101, 656, 103, 589, 105, 106, 
  37, 38, 8928, 8929, 8930, 8931, 8932, 8933, 8934, 8935, 8936, 8937, 8938, 8939, 6384, 8940, 187, 8941, 495, 8942, 6353, 8943, 8944, 8945, 
  8946, 8947, 8928, 8929, 8930, 8931, 8932, 8933, 8934, 8935, 8936, 8937, 8938, 8939, 6384, 8940, 187, 8941, 495, 8942, 6353, 8943, 8944, 8945, 
  8946, 8947, 8948, 8949, 8950, 8951, 8952, 8953, 8954, 2149, 8955, 8956, 8957, 8958, 2133, 928, 8959, 8960, 8961, 8962, 80, 81, 82, 83, 
  8963, 8964, 2158, 159, 457, 161, 93, 258, 212, 34, 92, 214, 165, 215, 216, 217, 105, 106, 110, 0, 1, 408, 408, 8965, 
  614, 615, 616, 617, 5592, 5593, 620, 8966, 8967, 8968, 624, 5588, 5589, 5590, 5591, 617, 5592, 5593, 5594, 5595, 5596, 5597, 5598, 8965, 
  614, 615, 616, 617, 5592, 5593, 620, 8966, 8967, 8968, 624, 5588, 5589, 5590, 5591, 617, 5592, 5593, 5594, 5595, 5596, 5597, 5598, 8969, 
  8970, 8971, 8972, 8973, 8974, 8975, 8976, 8977, 8978, 8979, 8980, 8981, 8982, 8983, 8984, 8985, 8986, 8983, 8984, 8985, 8986, 8987, 8988, 2694, 
  89, 90, 2063, 880, 529, 34, 92, 93, 1182, 95, 1183, 1184, 98, 99, 2825, 101, 534, 103, 104, 105, 106, 107, 109, 110, 
  37, 38, 8989, 8990, 8991, 8992, 8993, 8994, 8995, 8996, 8997, 8998, 8999, 9000, 9001, 9002, 9003, 9004, 9005, 9006, 9007, 9008, 9009, 9010, 
  9011, 9012, 8989, 8990, 8991, 8992, 8993, 8994, 8995, 8996, 8997, 8998, 8999, 9000, 9001, 9002, 9003, 9004, 9005, 9006, 9007, 9008, 9009, 9010, 
  9011, 9012, 9013, 9014, 9015, 9016, 9017, 9018, 9019, 9020, 9021, 9022, 9023, 9024, 9025, 9026, 9027, 9028, 9029, 9030, 9027, 9028, 9029, 9030, 
  9031, 9032, 9033, 9034, 93, 209, 9035, 9036, 9037, 163, 164, 34, 92, 93, 94, 5975, 9038, 9039, 165, 166, 100, 101, 102, 103, 
  3834, 105, 9040, 108, 9037, 37, 37, 9041, 9042, 9043, 9044, 9045, 9046, 9047, 9048, 9049, 9050, 9051, 9052, 9041, 9053, 9054, 9055, 9056, 
  9046, 9057, 9058, 9059, 9060, 9061, 9062, 9041, 9042, 9043, 9044, 9045, 9046, 9047, 9048, 9049, 9050, 9051, 9052, 9041, 9053, 9054, 9055, 9056, 
  9046, 9057, 9058, 9059, 9060, 9061, 9062, 9063, 9064, 9065, 241, 9066, 9067, 9068, 9069, 9070, 9071, 9072, 9073, 9074, 9075, 9076, 9077, 9078, 
  9079, 9080, 9081, 9082, 9083, 9084, 9085, 256, 257, 9086, 1678, 213, 1679, 259, 260, 261, 262, 1095, 263, 34, 92, 93, 214, 1097, 
  1680, 9087, 165, 166, 269, 101, 9088, 103, 104, 105, 106, 107, 167, 0, 1, 767, 408, 408, 9089, 9090, 538, 539, 9091, 9092, 
  9093, 2300, 9094, 9095, 9096, 546, 9097, 9098, 538, 549, 9091, 9092, 9093, 2303, 553, 554, 9099, 556, 9100, 9101, 9102, 9103, 9104, 9105, 
  9106, 9107, 9108, 9109, 9110, 9111, 9112, 9113, 495, 423, 9104, 9105, 9106, 9114, 4089, 428, 9115, 9116, 9117, 9118, 9119, 9120, 9121, 9122, 
  9123, 9124, 9125, 9126, 9127, 9128, 9129, 9130, 9131, 9132, 9133, 9134, 9135, 9136, 9137, 9138, 9139, 9140, 9141, 565, 651, 161, 93, 33, 
  33, 582, 34, 92, 93, 653, 707, 584, 654, 586, 587, 655, 101, 656, 103, 589, 167, 109, 110, 37, 37, 9142, 9143, 9144, 
  9145, 9146, 9147, 9148, 9149, 8692, 9150, 9151, 9152, 9153, 9154, 9155, 9156, 8699, 9157, 9158, 8701, 6871, 9159, 9160, 4436, 9142, 9143, 9144, 
  9145, 9146, 9147, 9148, 9149, 8692, 9150, 9151, 9152, 9153, 9154, 9155, 9156, 8699, 9157, 9158, 8701, 6871, 9159, 9160, 4436, 9161, 9162, 7090, 
  7091, 7092, 9163, 9164, 8705, 7096, 9165, 9166, 9167, 9168, 7085, 9169, 9170, 9171, 9172, 909, 759, 210, 109, 110, 1, 9173, 9174, 9175, 
  9176, 9177, 9178, 9179, 9180, 9181, 9182, 9183, 9184, 9185, 9186, 9187, 9188, 9177, 9189, 9190, 9191, 9192, 9193, 9194, 9195, 9173, 9174, 9175, 
  9176, 9177, 9178, 9179, 9180, 9181, 9182, 9183, 9184, 9185, 9186, 9187, 9188, 9177, 9189, 9190, 9191, 9192, 9193, 9194, 9195, 9196, 9197, 9198, 
  9199, 9200, 9201, 9202, 9203, 9204, 9205, 9206, 9207, 9208, 9209, 9210, 9211, 9212, 9213, 80, 81, 82, 83, 2810, 9214, 455, 9215, 160, 
  161, 93, 209, 111, 112, 109, 110, 210, 163, 164, 34, 92, 93, 94, 9216, 311, 1303, 165, 166, 100, 101, 102, 103, 104, 
  105, 106, 107, 108, 109, 110, 0, 1, 9217, 9217, 9218, 9219, 9220, 9221, 9222, 9223, 9224, 9225, 9226, 9227, 9228, 9229, 9218, 9219, 
  9220, 9221, 9222, 9223, 9224, 9225, 9226, 9227, 9228, 9229, 9218, 9219, 9220, 9221, 9222, 9223, 9224, 9225, 9226, 9227, 9228, 9229, 9218, 9219, 
  9220, 9221, 9222, 9223, 9224, 9225, 9226, 9227, 9228, 9229, 9230, 9231, 9232, 9233, 9234, 9235, 9236, 9230, 9231, 9232, 9233, 9234, 9235, 9236, 
  9237, 9238, 9237, 9239, 9240, 9241, 9242, 9243, 9244, 9245, 9246, 9247, 9248, 9249, 9250, 9251, 9252, 0, 318, 5316, 37, 38, 9253, 9254, 
  9102, 9255, 9256, 9257, 9258, 9259, 9260, 9261, 9262, 9263, 9264, 9265, 495, 9266, 497, 9267, 9268, 9269, 9270, 9271, 2134, 2410, 9253, 9254, 
  9102, 9255, 9256, 9257, 9258, 9259, 9260, 9261, 9262, 9263, 9264, 9265, 495, 9266, 497, 9267, 9268, 9269, 9270, 9271, 2134, 2410, 9272, 9273, 
  9274, 9275, 9276, 9277, 9278, 9279, 9280, 8728, 9281, 9282, 9283, 3635, 9284, 9285, 9286, 9287, 5358, 5359, 5360, 5361, 9288, 9289, 9290, 9291, 
  9292, 161, 93, 7444, 880, 9293, 34, 92, 93, 9294, 9295, 584, 9296, 1304, 166, 6815, 101, 9297, 103, 589, 167, 2016, 2017, 2018, 
  111, 112, 109, 110, 0, 1, 767, 408, 408, 9298, 658, 592, 659, 594, 660, 661, 597, 662, 663, 664, 665, 9299, 667, 668, 
  669, 594, 660, 661, 672, 673, 674, 675, 676, 9298, 658, 592, 659, 594, 660, 661, 597, 662, 663, 664, 665, 9299, 667, 668, 
  669, 594, 660, 661, 672, 673, 674, 675, 676, 9300, 678, 9301, 9302, 9303, 9304, 9305, 9306, 685, 9307, 9308, 9309, 9310, 9311, 9312, 
  9313, 9314, 9315, 9316, 9317, 9318, 9319, 9320, 9321, 9322, 9323, 9324, 33, 326, 327, 328, 329, 210, 33, 582, 9325, 9326, 9327, 9328, 
  9329, 9330, 586, 587, 655, 101, 656, 103, 104, 9331, 9332, 9333, 109, 110, 1, 113, 113, 2200, 2201, 2202, 2203, 2204, 2205, 2206, 
  2207, 2208, 2209, 2210, 2211, 2212, 2213, 495, 2214, 2204, 2215, 2216, 2207, 2217, 428, 2218, 2219, 2200, 2201, 2202, 2203, 2204, 2205, 2206, 
  2207, 2208, 2209, 2210, 2211, 2212, 2213, 495, 2214, 2204, 2215, 2216, 2207, 2217, 428, 2218, 2219, 2220, 2221, 2222, 2223, 4683, 2224, 2225, 
  442, 2226, 2227, 2228, 2229, 2230, 2231, 2232, 2233, 2234, 2235, 2236, 2237, 2238, 2239, 2240, 2241, 2242, 2243, 160, 161, 93, 163, 163, 
  164, 34, 93, 94, 165, 166, 100, 101, 102, 105, 106, 108, 109, 110, 168, 1, 408, 408, 5579, 5580, 615, 5581, 617, 5582, 
  5583, 620, 5584, 5585, 5586, 5587, 7256, 7257, 9334, 7259, 617, 9335, 9336, 7260, 7261, 7262, 7263, 7264, 5579, 5580, 615, 5581, 617, 5582, 
  5583, 620, 5584, 5585, 5586, 5587, 7256, 7257, 9334, 7259, 617, 9335, 9336, 7260, 7261, 7262, 7263, 7264, 9337, 9338, 9339, 9340, 9341, 9342, 
  9343, 9344, 9345, 9346, 9347, 9348, 9349, 9350, 9351, 9352, 9353, 9354, 9355, 9356, 9357, 9358, 9359, 9360, 9361, 9362, 9363, 210, 9364, 9365, 
  9363, 9366, 9367, 9368, 9369, 0, 1, 408, 408, 4410, 9370, 2381, 9371, 4414, 4415, 9372, 4417, 9373, 9374, 9375, 9376, 4422, 4425, 495, 
  9377, 497, 3698, 3699, 4426, 9378, 9379, 9380, 9381, 4410, 9370, 2381, 9371, 4414, 4415, 9372, 4417, 9373, 9374, 9375, 9376, 4422, 4425, 495, 
  9377, 497, 3698, 3699, 4426, 9378, 9379, 9380, 9381, 9382, 9383, 9384, 9385, 9386, 9387, 9388, 3711, 9389, 9390, 9391, 9392, 9393, 9394, 9395, 
  9396, 9397, 9398, 9399, 9400, 9401, 9402, 9403, 9404, 9405, 9406, 457, 161, 93, 258, 212, 34, 92, 214, 165, 215, 216, 217, 105, 
  106, 110, 37, 38, 9407, 9408, 9409, 9410, 322, 9411, 9412, 9413, 9414, 9415, 9416, 9417, 9407, 9408, 9409, 9410, 322, 9411, 9412, 9413, 
  9414, 9415, 9416, 9417, 9407, 9408, 9409, 9410, 322, 9411, 9412, 9413, 9414, 9415, 9416, 9417, 9407, 9408, 9409, 9410, 322, 9411, 9412, 9413, 
  9414, 9415, 9416, 9417, 9418, 9419, 9420, 9421, 9422, 9423, 9424, 9425, 9426, 9427, 9428, 9429, 9430, 9431, 9432, 9433, 9434, 9435, 9436, 9437, 
  9438, 9439, 9440, 9441, 9442, 9443, 9444, 9445, 307, 4850, 4851, 9446, 9447, 9448, 9449, 2813, 3176, 4857, 1356, 4858, 4859, 9450, 107, 167, 
  0, 1, 408, 408, 9451, 9452, 9453, 9454, 9455, 9456, 9457, 9458, 9459, 9460, 9461, 9462, 9463, 9464, 9465, 9466, 9467, 9468, 9469, 9470, 
  9471, 9472, 9473, 9474, 9475, 9476, 9477, 9478, 9479, 9480, 9481, 9482, 9483, 9484, 9485, 9486, 9463, 9464, 9465, 9466, 9467, 9468, 9469, 9470, 
  9471, 9472, 9473, 9474, 9487, 9488, 9489, 9490, 9491, 9492, 857, 858, 859, 977, 861, 978, 863, 864, 7750, 7751, 7752, 7753, 7754, 7755, 
  7756, 7757, 9493, 9494, 9495, 1467, 9496, 9497, 9498, 581, 210, 33, 2707, 9499, 9500, 9498, 9501, 884, 9502, 9503, 586, 587, 588, 101, 
  534, 103, 9504, 105, 9505, 107, 3279, 1006, 109, 110, 318, 0, 9506, 2198, 2193, 2193, 9507, 9508, 9509, 9510, 9511, 9512, 9513, 9514, 
  9515, 9516, 9517, 9518, 9507, 9508, 9509, 9510, 9511, 9512, 9513, 9514, 9515, 9516, 9517, 9518, 9507, 9508, 9509, 9510, 9511, 9512, 9513, 9514, 
  9515, 9516, 9517, 9518, 9507, 9508, 9509, 9510, 9511, 9512, 9513, 9514, 9515, 9516, 9517, 9518, 9189, 5144, 9519, 9520, 9521, 9522, 730, 9189, 
  5144, 9519, 9520, 9521, 9522, 730, 2833, 2834, 2835, 2836, 2833, 2834, 2835, 2836, 2713, 758, 9523, 9524, 9525, 9526, 9527, 2702, 343, 344, 
  345, 346, 2718, 2702, 6053, 9528, 9529, 9527, 9530, 9531, 9532, 9533, 2704, 2705, 6056, 3075, 9534, 3076, 9535, 9536, 9537, 9538, 9539, 2888, 
  9540, 9541, 9542, 345, 346, 2810, 261, 262, 9543, 9544, 356, 37, 38, 3052, 5166, 3054, 3055, 5167, 3057, 7343, 3059, 5170, 3061, 3062, 
  3063, 3052, 5166, 3054, 3055, 5167, 3057, 7343, 3059, 5170, 3061, 3062, 3063, 3052, 5166, 3054, 3055, 5167, 3057, 7343, 3059, 5170, 3061, 3062, 
  3063, 3052, 5166, 3054, 3055, 5167, 3057, 7343, 3059, 5170, 3061, 3062, 3063, 7344, 7345, 7346, 9545, 7348, 7349, 7350, 7344, 7345, 7346, 9545, 
  7348, 7349, 7350, 9546, 9547, 9548, 9549, 9546, 9547, 9548, 9549, 9550, 9551, 9552, 9553, 9554, 209, 259, 260, 261, 262, 163, 1800, 34, 
  92, 9554, 9555, 266, 9556, 9557, 165, 166, 9558, 101, 316, 103, 104, 105, 106, 107, 167, 0, 1, 408, 4808, 536, 537, 538, 
  539, 474, 540, 541, 8472, 9559, 9560, 545, 546, 547, 548, 472, 549, 474, 550, 551, 8675, 553, 554, 555, 556, 9561, 9562, 9102, 
  9103, 497, 9563, 9564, 9565, 9566, 9567, 9568, 9111, 9569, 3347, 495, 423, 497, 9570, 9571, 9572, 4089, 428, 9573, 9116, 9574, 9575, 9576, 
  9577, 9578, 1125, 9579, 741, 9580, 9581, 9582, 502, 2149, 9583, 9584, 9585, 9586, 9587, 9588, 9589, 9590, 9591, 9592, 2532, 9593, 9594, 9595, 
  9596, 9597, 2063, 1571, 3043, 210, 258, 2692, 652, 4403, 9597, 9598, 884, 9599, 9600, 586, 1305, 2693, 1356, 9601, 4859, 3615, 2012, 2013, 
  3279, 109, 110, 0, 318, 3052, 3053, 3054, 3055, 3056, 3057, 3058, 3059, 3060, 3061, 3062, 3063, 3064, 9602, 9603, 9604, 3056, 3057, 3065, 
  9605, 9606, 9607, 9608, 3066, 3052, 3053, 3054, 3055, 3056, 3057, 3058, 3059, 3060, 3061, 3062, 3063, 3064, 9602, 9603, 9604, 3056, 3057, 3065, 
  9605, 9606, 9607, 9608, 3066, 3024, 3025, 3026, 3027, 3028, 3029, 3030, 9609, 9610, 9611, 9612, 9613, 9614, 9615, 0, 1, 408, 408, 9616, 
  591, 592, 593, 594, 1618, 1619, 597, 9617, 9618, 9619, 601, 1617, 603, 604, 605, 594, 1618, 1619, 608, 609, 610, 1620, 612, 9616, 
  591, 592, 593, 594, 1618, 1619, 597, 9617, 9618, 9619, 601, 1617, 603, 604, 605, 594, 1618, 1619, 608, 609, 610, 1620, 612, 9620, 
  9621, 9622, 9623, 9624, 5604, 9625, 9626, 9627, 9628, 9629, 9630, 9631, 9632, 9633, 9634, 9635, 9636, 9637, 9638, 9639, 9640, 9641, 9642, 9643, 
  9644, 4400, 400, 162, 2063, 1996, 1997, 258, 2692, 652, 4403, 162, 9598, 3613, 9600, 1304, 1305, 2693, 101, 534, 103, 3615, 2012, 2013, 
  3279, 109, 110, 37, 38, 9645, 9646, 9647, 9648, 9649, 9650, 9651, 9652, 9653, 9654, 9655, 9656, 9657, 9658, 9647, 9648, 9649, 9650, 9659, 
  9652, 9653, 9654, 9660, 9661, 9645, 9646, 9647, 9648, 9649, 9650, 9651, 9652, 9653, 9654, 9655, 9656, 9657, 9658, 9647, 9648, 9649, 9650, 9659, 
  9652, 9653, 9654, 9660, 9661, 9662, 9663, 9664, 9665, 9666, 9667, 9668, 9662, 9663, 9664, 9665, 9666, 9667, 9668, 457, 161, 93, 258, 259, 
  260, 261, 262, 212, 34, 92, 214, 165, 215, 216, 217, 105, 106, 37, 38, 9669, 9670, 9671, 9672, 9673, 9674, 9675, 9669, 9670, 
  9671, 9672, 9673, 9674, 9675, 457, 161, 93, 258, 111, 112, 109, 110, 1095, 212, 34, 264, 214, 165, 215, 216, 217, 105, 106, 
  108, 109, 110, 168, 0, 1040, 2726, 2726, 9676, 9677, 5761, 4229, 9678, 9679, 9680, 2775, 9681, 9682, 9683, 9684, 9685, 471, 472, 549, 
  1362, 9686, 5865, 477, 478, 5840, 1375, 5841, 9676, 9677, 5761, 4229, 9678, 9679, 9680, 2775, 9681, 9682, 9683, 9684, 9685, 471, 472, 549, 
  1362, 9686, 5865, 477, 478, 5840, 1375, 5841, 9687, 7668, 9688, 9689, 9690, 9691, 9692, 511, 2788, 472, 4066, 9693, 9694, 3363, 4248, 4249, 
  4250, 4251, 2794, 2795, 2796, 2797, 86, 526, 160, 161, 93, 2063, 210, 258, 1301, 34, 92, 93, 94, 1302, 311, 1303, 1304, 1305, 
  1306, 101, 102, 103, 104, 105, 106, 107, 108, 0, 318, 408, 408, 9695, 9696, 9697, 9698, 9699, 9700, 9701, 9702, 9703, 9704, 9705, 
  9706, 9707, 9708, 9709, 9710, 9711, 9712, 9713, 9714, 9715, 9716, 9717, 9718, 9719, 9720, 9721, 9722, 9723, 9724, 9725, 9726, 9727, 9728, 9729, 
  9730, 9719, 9720, 9721, 9722, 9723, 9724, 9725, 9726, 9727, 9728, 9729, 9730, 9731, 9732, 9733, 9734, 9735, 9736, 9737, 9738, 9739, 9740, 9741, 
  9742, 9743, 9744, 9745, 9746, 9747, 9748, 9749, 9750, 9751, 9752, 1181, 400, 162, 209, 2590, 163, 529, 34, 9753, 162, 1182, 2803, 1183, 
  1184, 165, 166, 533, 101, 534, 103, 104, 105, 9754, 107, 9755, 329, 9756, 109, 110, 0, 318, 408, 408, 9757, 9758, 9759, 485, 
  9760, 9761, 9762, 489, 9763, 9764, 9765, 9766, 9757, 9758, 9759, 485, 9760, 9761, 9762, 489, 9763, 9764, 9765, 9766, 9757, 9758, 9759, 485, 
  9760, 9761, 9762, 489, 9763, 9764, 9765, 9766, 9757, 9758, 9759, 485, 9760, 9761, 9762, 489, 9763, 9764, 9765, 9766, 9767, 9768, 9769, 9770, 
  9771, 9772, 9773, 9767, 9768, 9769, 9770, 9771, 9772, 9773, 163, 93, 37, 37, 409, 410, 411, 4333, 43, 4334, 4335, 4336, 416, 417, 
  418, 419, 420, 421, 422, 423, 43, 424, 425, 426, 427, 428, 429, 3385, 409, 410, 411, 4333, 43, 4334, 4335, 4336, 416, 417, 
  418, 419, 420, 421, 422, 423, 43, 424, 425, 426, 427, 428, 429, 3385, 4337, 4338, 433, 4339, 435, 436, 437, 438, 439, 440, 
  441, 442, 4340, 444, 445, 446, 447, 448, 449, 450, 451, 452, 4341, 4342, 2158, 159, 457, 161, 93, 258, 212, 34, 92, 214, 
  165, 215, 216, 217, 105, 106, 110, 0, 2197, 9774, 9775, 9776, 9777, 9778, 9779, 9780, 9781, 9782, 9783, 9784, 9785, 4123, 9786, 2167, 
  496, 43, 9787, 9788, 9789, 9790, 9791, 9792, 9793, 9774, 9775, 9776, 9777, 9778, 9779, 9780, 9781, 9782, 9783, 9784, 9785, 4123, 9786, 2167, 
  496, 43, 9787, 9788, 9789, 9790, 9791, 9792, 9793, 9794, 9795, 9796, 9797, 9798, 9799, 9800, 9801, 9802, 9803, 9804, 9805, 7596, 7597, 7598, 
  7599, 2184, 9806, 2186, 1918, 2103, 34, 2103, 2187, 1417, 1418, 1417, 1418, 9540, 1927, 109, 110, 0, 318, 9807, 9808, 2381, 9809, 2383, 
  9810, 9811, 2207, 9812, 8586, 9813, 9814, 9805, 9113, 495, 9815, 2383, 9816, 1279, 2207, 9817, 428, 9818, 3385, 9807, 9808, 2381, 9809, 2383, 
  9810, 9811, 2207, 9812, 8586, 9813, 9814, 9805, 9113, 495, 9815, 2383, 9816, 1279, 2207, 9817, 428, 9818, 3385, 9819, 9820, 9821, 9822, 9823, 
  9824, 9825, 9826, 9827, 2409, 9828, 9829, 9830, 9831, 9832, 9833, 9834, 9835, 9836, 9837, 9838, 9839, 9840, 9841, 9842, 759, 9843, 400, 162, 
  406, 9844, 406, 407, 34, 92, 93, 531, 310, 1183, 1184, 98, 99, 2825, 101, 534, 103, 4680, 105, 106, 107, 1006, 109, 110, 
  1, 37, 37, 9845, 9846, 9847, 9848, 9849, 413, 9850, 6284, 416, 9851, 418, 896, 420, 421, 7085, 897, 6344, 424, 425, 729, 2691, 
  428, 429, 899, 9845, 9846, 9847, 9848, 9849, 413, 9850, 6284, 416, 9852, 418, 896, 420, 421, 7085, 897, 6344, 424, 425, 729, 427, 
  428, 429, 899, 9853, 6874, 9854, 9855, 9856, 9857, 6879, 9858, 6880, 9859, 4464, 6881, 7099, 6883, 9860, 9861, 9862, 9863, 6884, 6885, 6886, 
  6887, 909, 759, 1677, 1678, 213, 1679, 1095, 212, 34, 92, 213, 214, 165, 105, 106, 109, 110, 357, 1185, 1185, 1013, 3810, 1015, 
  1016, 1017, 1018, 1019, 1020, 2245, 2246, 1032, 1024, 3811, 3812, 1015, 1016, 1017, 1018, 3813, 3814, 3815, 6226, 3817, 3818, 1013, 3810, 1015, 
  1016, 1017, 1018, 1019, 1020, 2245, 2246, 1032, 1024, 3811, 3812, 1015, 1016, 1017, 1018, 3813, 3814, 3815, 6226, 3817, 3818, 9864, 9865, 1027, 
  1028, 9866, 9867, 9868, 9864, 9865, 1334, 1335, 9869, 9870, 2261, 9871, 9872, 9873, 9874, 3827, 3828, 3829, 3830, 9875, 9876, 9877, 3832, 457, 
  161, 93, 209, 259, 260, 261, 262, 210, 163, 529, 34, 92, 93, 531, 2803, 311, 532, 165, 166, 533, 101, 534, 103, 3834, 
  105, 106, 107, 108, 408, 408, 5705, 5706, 5707, 5708, 5709, 5280, 5710, 5711, 5712, 5713, 418, 419, 420, 421, 495, 5714, 2523, 4124, 
  425, 3700, 5715, 5716, 429, 3385, 5705, 5706, 5707, 5708, 5709, 5280, 5710, 5711, 5712, 5713, 418, 419, 420, 421, 495, 5714, 2523, 4124, 
  425, 3700, 5715, 5716, 429, 3385, 9878, 5718, 9879, 9880, 9881, 9882, 9883, 9884, 9885, 9886, 9887, 9888, 9889, 9890, 9891, 9892, 9893, 9894, 
  9895, 9896, 9897, 9898, 457, 161, 93, 258, 212, 34, 92, 214, 165, 215, 216, 217, 105, 106, 110, 0, 1, 408, 957, 9899, 
  9900, 9901, 9902, 9903, 9904, 9905, 9906, 9907, 9908, 9909, 9910, 9911, 9912, 9913, 9914, 9915, 9916, 9917, 9918, 9919, 9920, 9921, 9922, 9899, 
  9900, 9901, 9902, 9903, 9904, 9905, 9906, 9907, 9908, 9909, 9910, 9911, 9912, 9913, 9914, 9915, 9916, 9917, 9918, 9919, 9920, 9921, 9922, 9923, 
  9924, 9925, 9926, 9927, 9928, 9929, 9930, 9931, 9932, 9933, 9934, 9935, 9936, 9937, 9938, 9939, 9940, 9941, 9942, 5275, 9943, 160, 161, 93, 
  163, 163, 164, 34, 93, 94, 165, 166, 100, 101, 102, 105, 106, 108, 109, 110, 168, 9944, 9945, 9946, 9947, 9948, 3764, 3765, 
  9949, 9950, 9951, 9952, 9953, 9944, 9945, 9946, 9947, 9948, 3764, 3765, 9949, 9950, 9951, 9952, 9953, 9944, 9945, 9946, 9947, 9948, 3764, 3765, 
  9949, 9950, 9951, 9952, 9953, 9954, 9955, 9946, 9956, 9948, 3764, 3765, 9957, 9958, 9959, 9960, 9961, 9962, 9963, 9964, 9965, 9966, 9967, 3792, 
  9962, 9963, 9964, 9965, 9966, 9967, 3792, 9968, 9969, 9970, 9971, 9972, 2063, 210, 401, 529, 34, 9972, 9973, 9974, 9975, 533, 9976, 37, 
  38, 9977, 9978, 9979, 9980, 9981, 9982, 9983, 9984, 9985, 9986, 9987, 9988, 9977, 9978, 9979, 9980, 9981, 9982, 9983, 9984, 9985, 9986, 9987, 
  9988, 9977, 9978, 9979, 9980, 9981, 9982, 9983, 9984, 9985, 9986, 9987, 9988, 9977, 9978, 9979, 9980, 9981, 9982, 9983, 9984, 9985, 9986, 9987, 
  9988, 9989, 9990, 9991, 9992, 9993, 9994, 9995, 9996, 9997, 9998, 9992, 9993, 9999, 10000, 10001, 10002, 10003, 10004, 10001, 10002, 10003, 10004, 10005, 
  10006, 759, 10007, 93, 10008, 163, 327, 10009, 10010, 163, 6535, 34, 92, 93, 10011, 266, 1183, 1184, 165, 166, 533, 101, 656, 103, 
  104, 105, 106, 1006, 109, 110, 10012, 10013, 10014, 10015, 10016, 10017, 10018, 10019, 10020, 10021, 10022, 10023, 10012, 10013, 10014, 10015, 10016, 10017, 
  10018, 10019, 10020, 10021, 10022, 10023, 10012, 10013, 10014, 10015, 10016, 10017, 10018, 10019, 10020, 10021, 10022, 10023, 10012, 10013, 10014, 10015, 10016, 10017, 
  10018, 10019, 10020, 10021, 10022, 10023, 10024, 10025, 10026, 10027, 10028, 10029, 10030, 10031, 10027, 10028, 10032, 10033, 10034, 10035, 10036, 10037, 10034, 10035, 
  10036, 10037, 10038, 10039, 0, 318, 10040, 10041, 10042, 10043, 10044, 10045, 10046, 10047, 10048, 10049, 10050, 10051, 10052, 10053, 10054, 10055, 10056, 10057, 
  757, 10058, 8466, 10059, 10060, 10061, 10040, 10041, 10042, 10043, 10044, 10045, 10046, 10047, 10048, 10049, 10050, 10051, 10052, 10053, 10054, 10055, 10056, 10057, 
  757, 10058, 8466, 10059, 10060, 10061, 10062, 10063, 10064, 10065, 10066, 10067, 10068, 10069, 10070, 10071, 10072, 10073, 10074, 10075, 10076, 10077, 10078, 10079, 
  6099, 6100, 6101, 6102, 10080, 2940, 457, 161, 93, 258, 258, 2692, 34, 92, 93, 531, 311, 532, 1304, 166, 2693, 101, 534, 103, 
  104, 105, 106, 107, 1006, 109, 110, 1399, 1400, 111, 112, 109, 110, 1399, 1400, 111, 112, 109, 110, 37, 38, 4252, 4253, 4254, 
  4255, 4256, 4257, 4258, 4259, 4260, 4261, 4262, 4263, 4252, 4253, 4254, 4255, 4256, 4257, 4258, 4259, 4260, 4261, 4262, 4263, 4252, 4253, 4254, 
  4255, 4256, 4257, 4258, 4259, 4260, 4261, 4262, 4263, 4252, 4253, 4254, 4255, 4256, 4257, 4258, 4259, 4260, 4261, 4262, 4263, 10081, 10082, 10083, 
  10084, 10085, 10086, 10087, 10081, 10082, 10083, 10084, 10085, 10086, 10087, 10088, 10089, 10090, 10091, 10088, 10089, 10090, 10091, 10092, 10093, 10094, 10095, 10096, 
  4287, 4287, 211, 10097, 10098, 4195, 4196, 211, 10099, 4290, 4290, 4287, 10100, 10101, 4293, 10102, 2954, 215, 10103, 4296, 10104, 4296, 4298, 10105, 
  4300, 4301, 4302, 4303, 4304, 167, 10106, 4195, 4196, 10107, 37, 38, 4252, 4253, 4254, 4255, 4256, 4257, 4258, 4259, 4260, 4261, 4262, 4263, 
  4252, 4253, 4254, 4255, 4256, 4257, 4258, 4259, 4260, 4261, 4262, 4263, 4252, 4253, 4254, 4255, 4256, 4257, 4258, 4259, 4260, 4261, 4262, 4263, 
  4252, 4253, 4254, 4255, 4256, 4257, 4258, 4259, 4260, 4261, 4262, 4263, 10081, 10082, 10083, 10084, 10085, 10086, 10087, 10081, 10082, 10083, 10084, 10085, 
  10086, 10087, 10088, 10089, 10090, 10091, 10088, 10089, 10090, 10091, 10108, 10109, 10094, 10095, 10096, 4287, 4287, 211, 10110, 10111, 211, 10099, 4290, 4290, 
  4287, 10100, 10101, 4293, 10102, 2954, 215, 10103, 4296, 10104, 4296, 4298, 10105, 4300, 4301, 4302, 4303, 4304, 167, 10112, 4195, 4196, 10113, 10114, 
  10115, 10110, 10111, 345, 346, 10116, 10117, 10118, 10119, 10120, 10121, 10122, 10123, 10124, 10125, 10126, 10127, 10116, 10117, 10118, 10119, 10120, 10121, 10122, 
  10123, 10124, 10125, 10126, 10127, 10116, 10117, 10118, 10119, 10120, 10121, 10122, 10123, 10124, 10125, 10126, 10127, 10116, 10117, 10118, 10119, 10120, 10121, 10122, 
  10123, 10124, 10125, 10126, 10127, 10128, 10129, 10130, 10131, 10132, 10133, 10134, 10128, 10129, 10130, 10131, 10132, 10133, 10134, 211, 10135, 2016, 2017, 0, 
  1, 767, 113, 113, 8261, 8262, 8263, 8264, 8265, 8266, 8267, 8268, 8269, 8270, 8271, 8272, 8273, 8274, 8275, 8276, 8277, 8278, 8279, 8280, 
  8281, 8282, 8283, 8284, 8261, 8262, 8263, 8264, 8265, 8266, 8267, 8268, 8269, 8270, 8271, 8272, 8273, 8274, 8275, 8276, 8277, 8278, 8279, 8280, 
  8281, 8282, 8283, 8284, 8285, 8286, 8287, 8288, 8289, 10136, 8291, 8292, 8293, 8294, 8295, 8296, 8297, 8298, 8299, 8300, 8301, 8302, 8303, 8304, 
  8305, 8306, 8307, 8308, 8309, 8310, 160, 161, 162, 163, 164, 34, 94, 165, 166, 101, 102, 105, 106, 1144, 1145, 168, 37, 38, 
  10137, 10138, 10139, 10140, 10141, 10142, 10143, 10144, 10145, 10146, 10147, 10148, 4252, 4253, 4254, 4255, 4256, 4257, 4258, 4259, 4260, 4261, 4262, 4263, 
  10137, 10138, 10139, 10140, 10141, 10142, 10143, 10144, 10145, 10146, 10147, 10148, 4252, 4253, 4254, 4255, 4256, 4257, 4258, 4259, 4260, 4261, 4262, 4263, 
  10081, 10082, 10083, 10084, 10085, 10086, 10087, 10149, 10150, 10151, 10152, 10153, 10154, 10155, 10156, 10157, 10158, 10159, 10160, 10161, 10162, 10163, 10114, 10115, 
  10164, 10165, 4286, 4287, 4287, 211, 5095, 5096, 211, 10166, 4290, 4290, 4287, 10167, 10168, 4293, 10169, 2954, 215, 10170, 4296, 10171, 4296, 4298, 
  10172, 10172, 4301, 4302, 4303, 4304, 10173, 10174, 4195, 4196, 10113, 209, 10175, 10176, 4195, 4196, 163, 10177, 165, 166, 533, 209, 10175, 10176, 
  4195, 4196, 4287, 10178, 166, 533, 10175, 10176, 4195, 4196, 2063, 10175, 10176, 4195, 4196, 4287, 10178, 2482, 10179, 4303, 37, 38, 4252, 4253, 
  4254, 4255, 4256, 4257, 4258, 4259, 4260, 4261, 4262, 4263, 4252, 4253, 4254, 4255, 4256, 4257, 4258, 4259, 4260, 4261, 4262, 4263, 4252, 4253, 
  4254, 4255, 4256, 4257, 4258, 4259, 4260, 4261, 4262, 4263, 4252, 4253, 4254, 4255, 4256, 4257, 4258, 4259, 4260, 4261, 4262, 4263, 10081, 10082, 
  10083, 10084, 10085, 10086, 10087, 10180, 10181, 10182, 10183, 10184, 10185, 10186, 10088, 10089, 10090, 10091, 10088, 10089, 10090, 10091, 10114, 10115, 10094, 10095, 
  10096, 4287, 4287, 211, 10187, 10188, 10189, 10190, 211, 10099, 4290, 4290, 4287, 10167, 6536, 4293, 10102, 2954, 215, 10103, 4296, 10171, 4296, 4298, 
  10105, 4300, 4301, 4302, 4303, 4304, 167, 4306, 10189, 10190, 10191, 2833, 2834, 2835, 2836, 10164, 10165, 4286, 163, 10097, 10098, 4195, 4196, 163, 
  10177, 10169, 165, 166, 10192, 4195, 4196, 10107, 10175, 10176, 4195, 4196, 37, 38, 10193, 9846, 10194, 10195, 9849, 413, 9850, 6284, 10196, 9852, 
  418, 896, 420, 421, 10197, 10198, 6344, 424, 425, 729, 427, 428, 429, 899, 10193, 9846, 10194, 10195, 9849, 413, 9850, 6284, 10196, 9852, 
  418, 896, 420, 421, 10197, 10198, 6344, 424, 425, 729, 427, 428, 429, 899, 10199, 10200, 10201, 10202, 10203, 10204, 10205, 5148, 10206, 10207, 
  4464, 6881, 7099, 6883, 10208, 9861, 9862, 9863, 909, 759, 1677, 1678, 213, 34, 92, 213, 214, 217, 105, 106, 167, 109, 110, ]
