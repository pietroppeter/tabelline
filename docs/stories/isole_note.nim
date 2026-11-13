## Translation notes for *Isole del Mediterraneo*, the Italian page of the islands story: the
## conventions, the choices with their options, and every text of `data/isole/italiano.txt` beside
## its English, read from the file itself, so the notes cannot drift from what the page shows.
## Written in Italian, for the person who reviews the Italian (in the review mode). Written to
## stories/isole-note/.
import std/[os, strutils, sequtils]
import nimib
import tabelline, tabelline/nimib
import ../blocks, ../theme

let docs = currentSourcePath().parentDir.parentDir
let data = docs / "stories" / "data" / "isole"

# --------------------------------------------------------------------------- the catalog
# The same reading as isole.nim: an `en:` block, then its `it:` block (empty: the same text).
type Message = object
  en, it: string
var catalog: seq[Message]
block:
  var (en, it, side) = ("", "", "")
  proc flush() =
    if en.strip.len > 0: catalog.add Message(en: en.strip, it: it.strip)
    (en, it) = ("", "")
  for line in lines(data / "italiano.txt"):
    if line.startsWith("en:"): (flush(); side = "en"; en = line[3 .. ^1].strip & "\n")
    elif line.startsWith("it:"): (side = "it"; it = line[3 .. ^1].strip & "\n")
    elif side == "en": en.add line & "\n"
    elif side == "it": it.add line & "\n"
  flush()
proc uncited(s: string): string =
  ## A text without its citations (`[^braudel]`), which point to the story's list of books.
  result = s
  var at = result.find("[^")
  while at >= 0:
    result.delete(at .. result.find(']', at))
    at = result.find("[^")
for m in catalog.mitems: (m.en = uncited(m.en); m.it = uncited(m.it))
let short = catalog.filterIt(it.en.splitWhitespace.len <= 5)
let long = catalog.filterIt(it.en.splitWhitespace.len > 5)

nbInit
nb.doc.filename = docs / "stories" / "isole-note" / "index.html"
nb.useTabelline(title = "Note di traduzione · Isole del Mediterraneo", homeHref = "../isole-it/index.html",
  backLabel = "Isole del Mediterraneo", wordmarkHref = "../../", looks = ["munari", "minoan"],
  firstLook = "minoan", lang = "it")

nbTitle "Note di traduzione", "Isole del Mediterraneo, in italiano",
  "Come è tradotta la storia delle isole: le convenzioni, le scelte che si potevano fare in un " &
  "altro modo, e ogni testo della pagina accanto al suo inglese."
nbToc

nbText: """
## Come si rivede

La [pagina italiana](../isole-it/index.html) è la stessa storia della
[pagina inglese](../isole/index.html), con i testi presi da `docs/stories/data/isole/italiano.txt`:
per ogni testo inglese (`en:`) la sua traduzione (`it:`), o niente quando resta uguale. Se a un
testo manca la traduzione, la pagina italiana non si costruisce. Questa pagina legge lo stesso file,
quindi mostra sempre quello che la pagina mostra.

La traduzione è una prima stesura di Claude, non ancora riletta. Per rivederla, apri **✎ Review**,
seleziona l'italiano che non va e scrivi come lo vorresti. Per una scelta basta la lettera
dell'opzione. Claude cambia `italiano.txt` e queste note, e la versione successiva lo mostra.
"""

nbText: """
## Convenzioni

- **Il tono** è quello dell'inglese: frasi brevi, in terza persona, all'indicativo. Il lettore non è
  mai chiamato in causa.
- **I nomi delle isole** sono le etichette italiane di Wikidata, senza "isola di" ("Isola di Pantelleria"
  diventa Pantelleria; Isola Lunga resta così, perché è il nome). Dove Wikidata non ha un nome
  italiano, resta il nome inglese. La [tabella dei nomi](#i-nomi-delle-isole) li mostra tutti.
- **I nomi dei luoghi da vedere e delle spiagge** restano quelli locali (Navagio, Palombaggia, Cala
  Macarella), tranne quelli che in italiano hanno un nome comune: Cnosso, Pafo, La Valletta, la
  Valle dei Templi.
- **I cibi** restano col loro nome (arancini, culurgiones, pastizzi). Quelli descritti con una
  frase si traducono, con l'articolo: il moscato di Samo, il formaggio di Mahón.
- **Le citazioni** vengono dai testi italiani, quando ci sono. Ramondino e Anedda scrivono in
  italiano; Matvejević e Deleuze sono citati dalle edizioni italiane, come nella pagina inglese;
  Di Girolamo e Hunt dagli estratti del Post. Solo **Lawrence** è tradotto da Claude, da *Sea and
  Sardinia*: un'edizione italiana esiste (*Mare e Sardegna*), ma qui non si poteva leggere.
- **I libri** hanno il titolo dell'edizione italiana, con l'originale fra parentesi quando è
  diverso: *Breviario mediterraneo* (*Mediteranski brevijar*).
- **I numeri** seguono la locale italiana in ogni tabella (`locale = "it"`): virgola per i
  decimali, punto per le migliaia. I mesi sono abbreviati in minuscolo (gen, feb, …), come si
  scrivono in italiano.
- **Il codice** resta com'è: nomi di proc, file e opzioni in `codice` non si traducono. Nelle note
  verdi si traduce il testo intorno al codice.
- **Le pagine collegate** che esistono solo in inglese (la storia dei dati, le foto) sono segnate
  "(in inglese)", e i link a Wikipedia vanno alla voce italiana quando c'è.
"""

nbText: """
## Scelte

Le parole che si potevano tradurre in più modi. La prima opzione, **A**, è quella della pagina.

1. **North Aegean, South Aegean** (le regioni greche). **A.** Egeo del Nord, Egeo del Sud.
   **B.** Egeo Settentrionale, Egeo Meridionale, i nomi ufficiali in italiano. A perché il nome
   lungo allargava la tabella della disoccupazione oltre lo schermo di un telefono.
2. **Strait of Sicily.** **A.** Canale di Sicilia. **B.** Stretto di Sicilia. A perché è il nome
   che si usa in italiano; "stretto" in italiano è quello di Messina.
3. **I mari nella tabella del clima.** **A.** Ionio, Egeo, Adriatico, Tirreno, ma Mar Ligure, Mar
   di Levante e Mar delle Baleari. **B.** Tutti con "Mar": Mar Ionio, Mar Egeo, … A perché in
   italiano "lo Ionio" si dice da solo, "il Ligure" no; B è più regolare, ma più largo.
4. **Cres, Krk e gli altri nomi con un esonimo.** **A.** Cherso, Veglia, Brazza, Lesina, Curzola,
   Pago, Zante, Cerigo, Scarpanto, Coo, Imbro, Gerba, Nasso, come in Wikidata. **B.** I nomi di
   oggi: Cres, Krk, Brač, Hvar, Korčula, Pag, Zacinto, Citera, Karpathos, Kos, Gökçeada, Djerba,
   Naxos. A perché sono i nomi italiani dei dizionari. Per le isole croate, però, il nome veneziano
   può sembrare una presa di posizione, e Imbro oggi è turca: si può tenere A solo per le isole
   greche e tunisine. Lo stesso vale per i luoghi: Ragusa per Dubrovnik, Spalato, Zara e Fiume
   nelle fonti del clima, le isole Spalmadori (Pakleni) e la piana di Cittavecchia (Stari Grad).
5. **Britain**, fra chi ha governato Malta, Cipro e Corfù. **A.** Regno Unito. **B.** Gran Bretagna.
   **C.** gli Inglesi, come Arabi e Ottomani. A perché è lo stato; C sarebbe più vicino alle altre
   colonne, che sono popoli.
6. **country** (colonna). **A.** paese. **B.** stato. A perché è la parola delle tabelle
   statistiche; nel testo, dove si parla delle isole diventate indipendenti, si usa "stato".
7. **population** (colonna). **A.** abitanti. **B.** popolazione. A perché è più corto.
8. **highest** (colonna). **A.** vetta. **B.** altezza massima. **C.** quota. A perché è una parola
   sola; B è più esatto per le isole piatte, dove la "vetta" è di pochi metri.
9. **GDP in PPS.** **A.** PIL in SPA (standard di potere d'acquisto, la sigla italiana di Eurostat).
   **B.** PIL in PPA (parità di potere d'acquisto), più comune nei giornali, ma è un'altra cosa.
10. **jobless.** **A.** disoccupati. **B.** disoccupazione. A per la lunghezza; i numeri sono un
    tasso, quindi B è più esatto.
11. **To read more.** **A.** Letture. **B.** Per saperne di più. A perché un titolo breve tiene
    l'indice su una riga.
12. **the Baška tablet.** **A.** la lapide di Bescanuova. **B.** la lapide di Baška. Bescanuova è
    il nome italiano del paese, ma per la lapide si trova più spesso Baška.
13. **{1} since {2}**, la colonna "oggi" dei governanti. **A.** Italia dal 1861. **B.** Italia,
    dal 1861. A perché la colonna è stretta.
14. **ancient, middle ages, modern** (le tre epoche dei governanti). **A.** antichità, medioevo, età
    moderna. **B.** antico, medievale, moderno. A perché in italiano le epoche hanno un nome.
15. **Türkiye**, come la scrive `fmtCountry` (dai nomi di CLDR), e **Turkey** nel testo. **A.**
    Turchia, tutte e due. **B.** Türkiye nella tabella, come il nome ufficiale. A perché in italiano
    si dice Turchia.
16. **listed** (colonna della tabella per paese, le isole della lista delle 195). **A.** nella
    lista. **B.** iscritto, la prima stesura. A dalla revisione di Pietro: "iscritto" non si
    capiva, perché in italiano si iscrive una persona, non un'isola.
"""

nbText: """
## I nomi delle isole

Le isole il cui nome italiano non è quello inglese. Vengono da Wikidata (`fetch.nim`), senza "isola
di" (`extract.nim`), e la pagina li mostra in ogni tabella e sulle due carte.
"""

block:
  type Row = object
    english, italiano, paese: string
  var rows: seq[Row]
  let all = readCsv(data / "islands.csv", comment = "#")
  for i in 0 ..< all.nrows:
    let (en, it) = ($all["island", i], $all["italian", i])
    if it.len > 0 and it != en: rows.add Row(english: en, italiano: it, paese: $all["country", i])
  let t = tabella(rows):
    tabHeader "Nomi italiani", $rows.len & " isole su " & $all.nrows
    colsLabel:
      english: "inglese"
      italiano: "italiano"
    optCssTheme()
  nbTable t

nbText: """
## Le parole brevi

Etichette, titoli, nomi: i testi di cinque parole o meno, nell'ordine in cui la pagina li incontra.
"=" vuol dire che il testo resta uguale.
"""

block:
  type Row = object
    n: int
    english, italiano: string
  var rows: seq[Row]
  for i, m in short: rows.add Row(n: i + 1, english: m.en, italiano: (if m.it == "": "=" else: m.it))
  let t = tabella(rows, rownameCol = "n"):
    tabHeader "Le parole brevi", $short.len & " testi"
    colsLabel:
      english: "inglese"
      italiano: "italiano"
    optCssTheme()
  nbTable t

nbText: """
## I testi

Tutti gli altri, i paragrafi e le note, ognuno con il suo inglese sopra e l'italiano sotto.
"""

block:
  type Row = object
    n, lingua, testo: string
  var rows: seq[Row]
  for i, m in long:
    # a heading inside a text is a line of it here, not a heading of these notes
    # and a link to a part of the story goes to that part of the story
    let shown = proc (s, page: string): string =
      s.splitLines.mapIt(if it.startsWith("#"): it.strip(trailing = false, chars = {'#', ' '}) else: it)
       .join("\n").replace("](#", "](../" & page & "/index.html#")
    rows.add Row(n: $(i + 1), lingua: "en", testo: shown(m.en, "isole"))
    rows.add Row(n: $(i + 1), lingua: "it", testo: (if m.it == "": "=" else: shown(m.it, "isole-it")))
  let t = tabella(rows, rownameCol = "lingua", groupnameCol = "n"):
    tabHeader "I testi", $long.len & " paragrafi e note"
    fmtMarkdown "testo"
    colsLabel:
      testo: ""
    optCssTheme()
  nbTable t

nbNote("""Questa pagina è `docs/stories/isole_note.nim`: legge `italiano.txt` come la pagina
italiana (un blocco `en:`, poi il suo `it:`) e lo mostra in due tabelle, i testi brevi in una riga
ciascuno e i paragrafi in un gruppo ciascuno (`groupnameCol = "n"`, `fmtMarkdown`). Le convenzioni e
le scelte sono scritte a mano, da Claude.""", nkCode)

nbSave
