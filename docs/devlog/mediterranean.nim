## devlog: 11 Nov 2026 D | Designing a Mediterranean look | The islands story gets a look of its own, in place of the quaderno: a Mediterranean one. Designed in rounds, in this post. Fourteen sources to learn from, from Minoan frescoes to the houses of Djerba, each with who they are, what they made, why they fit and what a page could take; rules for turning a source into six colours, checked on every palette; a gallery of the discarded; three directions, and a tournament.
## A dated post: it tells how the Mediterranean look was designed, round by round, and is not rewritten afterwards.
import std/[os, strutils]
import nimib
import tabelline, tabelline/nimib
import ../blocks

let docs = currentSourcePath().parentDir.parentDir
nbInit
nb.doc.filename = docs / "devlog" / "mediterranean" / "index.html"
nb.useTabelline(title = "Designing a Mediterranean look", homeHref = "../", backLabel = "Devlog", wordmarkHref = "../../")

nbTitle "11 November 2026", "Designing a Mediterranean look", """
The islands story gets a look of its own, in place of the quaderno: a Mediterranean one. It is
designed in rounds, in this post. Round 1: nine sources to learn from, what a page could take from
each, and three directions to choose from. Round 4: eighteen sources looked at, fourteen still in, and
a tournament to choose among them.
"""

nbText: """
Every page of tabelline has two looks: Munari, the default, and the quaderno, an Italian school
exercise book, one switch away in the header. The story
[Islands of the Mediterranean](../../stories/isole/) asks for something else. Pietro: "we should
also have a custom style that replaces Quaderno style and should be a Mediterranean style", and its
design "should be its own article", like the islands' data has
[its own](../../stories/isole-data/). This is that article.

Munari stays the default; on the islands page the switch will offer the Mediterranean look instead
of the quaderno. The story is written with tokens and blocks only, so the new look changes the page
without changing the story's code.

## What a look gives

A look is three things, from the simplest:

1. **Six colours**, named by role: paper, ink, primary (sections, links), secondary (notes and
   cards to go to), warning (never text) and success. Every other colour of the page is mixed from
   them, so a palette is six values (see [the design review](../design-review/)).
2. **Typefaces**: one for text, maybe one for headings, and a monospace for code.
3. **Motifs**: how the shapes are drawn. The circle is a place (sections, the indice), the
   triangle a warning, the square a sheet set apart (notes, cards). A look can draw them its own
   way, but not change what they mean, and nothing that only decorates may look like something to
   press.

One more need came from the story itself: its names. Croatian, Turkish, Maltese and Sicilian
islands need letters that the site's Jost does not have. Here they are in it, and the ć of
Matvejević, the writer of the *Mediterranean Breviary* quoted in the story, comes from another
font:

> Matvejević · Korčula · Brač · Šipan · Iž · Gökçeada · İmralı · Paşalimanı · Għawdex · Ħal Saflieni · Pantiḍḍirìa

So the Mediterranean look's typefaces must cover at least Latin Extended-A (ć č š ž ğ ş ı İ ħ ġ),
and the ḍ of Sicilian too.

## From a source to six colours

A source gives a look its colours by rules, written down in round 2 after a red came out as the
colour of success (in Scianna's card: red says "stop", not "done"). Every palette below follows
them, and the table after the rules checks each colour when the page is built.

**Picking the colours from a source:**

1. **Paper** is the ground the work is made on (plaster, vellum, a glaze, a print): its lightest
   large surface, never pure white.
2. **Ink** is its darkest mark, never pure black, and at least 10:1 on the paper.
3. **Every colour is named after a material** of the source: a pigment, a glaze, a paint, a
   stone. When the source has none for a role (a black-and-white photograph has no green), the
   colour comes from the place the source shows, and its swatch says so: *from the place*.

**Giving each colour its role:**

4. **Primary** is the colour the source is known for. It draws the section circles, link
   underlines, kickers and third-level headings, and code keywords, so it needs 3:1 on the paper,
   as a shape does (as text the page mixes it with ink).
5. **Secondary** is its second colour: notes and cards to go to, bars in tables. At least 60° of
   hue away from the primary, so the two are never confused, and 3:1 on the paper.
6. **Warning** is a yellow (hue 35° to 60°), because readers already know yellow as "careful".
   It fills the warning triangle and is never text, so it has no contrast rule.
7. **Success** is a green (hue 80° to 170°), because readers already know green as "done": the
   notes on code and on what works. At least 3:1 on the paper.

A source whose own colours break a rule gives up that role to the place, or is discarded.
"""

block:  # every colour of every source, checked against the rules
  type Check = object
    source, role, colour, swatch: string
    contrast, hue: float
    verdict: string
  func hueOf(c: Rgb): float =
    let (r, g, b) = (c.r / 255, c.g / 255, c.b / 255)
    let (hi, lo) = (max(r, max(g, b)), min(r, min(g, b)))
    if hi == lo: return 0.0
    let d = hi - lo
    result = (if hi == r: (g - b) / d elif hi == g: (b - r) / d + 2 else: (r - g) / d + 4) * 60
    if result < 0: result += 360
  func hueGap(a, b: float): float = min(abs(a - b), 360 - abs(a - b))
  var rows: seq[Check]
  for (key, colours) in mediterraneanSources:
    let paper = parseColor(colours[0].hex)
    for k in 1 .. 5:
      let x = colours[k]
      let c = parseColor(x.hex)
      let (ratio, h) = (contrast(c, paper), hueOf(c))
      var why: seq[string]
      case x.role
      of "ink":
        if ratio < 10: why.add "under 10:1"
      of "primary", "secondary", "success":
        if ratio < 3: why.add "under 3:1"
      else: discard
      if x.role == "secondary" and hueGap(h, hueOf(parseColor(colours[2].hex))) < 60: why.add "too close to primary"
      if x.role == "warning" and (h < 35 or h > 60): why.add "not a yellow"
      if x.role == "success" and (h < 80 or h > 170): why.add "not a green"
      rows.add Check(source: key, role: x.role, colour: x.name & (if x.fromPlace: " (place)" else: ""),
                     swatch: "", contrast: ratio, hue: h,
                     verdict: (if why.len == 0: "✓" else: why.join(", ")))
  var t = tabella(rows, groupnameCol = "source"):
    tabHeader "Every colour, checked", "the rules above, on the five colours of each source"
    colsLabel:
      role: ""
      swatch: ""
      contrast: "on paper"
      hue: "hue"
      verdict: "rules"
    fmtNumber "contrast", decimals = 1, pattern = "{x}:1"
    fmtNumber "hue", decimals = 0, pattern = "{x}°"
    colsWidth:
      swatch: "1.6em"
    tabSourceNote "Contrast after WCAG 2 (3:1 for shapes, 4.5:1 for small text); hue in degrees, red at 0°, yellow at 60°, green at 120°, blue at 240°. The discarded sources are checked too."
    optCssTheme()
  for i, r in rows:
    t = t.tabStyle(style.fill(sourceColours(r.source)[["ink", "primary", "secondary", "warning", "success"].find(r.role) + 1].hex),
                   loc.body(cols = "swatch", rows = [i]))
  nbFold "Every colour of every source, checked":
    nbTable t

nbText: """
## Fourteen sources

People and traditions to learn from, oldest first, in a gallery to swipe. For each: who they are, what they made, why they
fit the islands, and what a page could take. The six colours under each follow the rules above,
picked by eye, not sampled from a picture; the references are where the facts come from.
"""

nbGallery "fourteen sources for a Mediterranean look, oldest first: swipe or scroll sideways":

  nbGalleryCard("Minoan frescoes and Attic vases", "1600–300 BC"):
    nbText: """
**Who.** The painters of Bronze Age Crete and Thera (Santorini), and the potters of Corinth and
Athens a thousand years later.

**What.** Frescoes on lime plaster at Knossos and at Akrotiri, a town buried in volcanic ash and
so kept almost whole; sea creatures everywhere, and pots of the "Marine Style" covered in octopus
and dolphins. Then the vases: black-figure (black figures painted on the clay), and from about
520 BC red-figure, the figures left in the colour of the clay on a black ground.

**Why it fits.** The oldest Mediterranean pictures, made on islands; two colours carry a whole scene.

**For a page.** Terracotta and black as the only inks of a table; the meander (the Greek key) as
the rule above and below; dolphin blue for the sea.
"""
    nbSwatches sourceSwatches("minoan")
    nbText: """
[Minoan art](https://en.wikipedia.org/wiki/Minoan_art) ·
[Wall paintings of Thera](https://en.wikipedia.org/wiki/Wall_Paintings_of_Thera) ·
[Black-figure](https://en.wikipedia.org/wiki/Black-figure_pottery) and
[red-figure pottery](https://en.wikipedia.org/wiki/Red-figure_pottery) ·
[Meander](https://en.wikipedia.org/wiki/Meander_(art))
"""

  nbGalleryCard("The mosaics of the Villa Romana del Casale", "300s AD"):
    nbText: """
**Who.** The mosaicists, whose names are lost, who paved a great Roman villa near Piazza Armerina,
in the middle of Sicily, in the first quarter of the 4th century AD.

**What.** Some 3,500 m² of mosaic and *opus sectile* floors, kept almost whole by a landslide and
floods that covered them: for the Grove Dictionary of Art, the richest, largest and most varied
collection of Roman mosaics that remains. Hunts, among them a great one with a captive tigress. A
World Heritage Site since 1997.

**Why it fits.** The biggest island's own pictures, made of small stones set one beside the other,
as a table is made of cells.

**For a page.** A table as a floor of tesserae: cells parted by a thin line of mortar, a border of
small squares, earth colours and one glass blue.
"""
    nbSwatches sourceSwatches("casale")
    nbText: """
[Villa Romana del Casale](https://en.wikipedia.org/wiki/Villa_Romana_del_Casale) ·
[UNESCO](https://whc.unesco.org/en/list/832)
"""

  nbGalleryCard("The isolari and the portolan charts", "1200s–1528"):
    nbText: """
**Who.** Cristoforo Buondelmonti, a Florentine priest who sailed the Aegean and wrote the *Liber
insularum Archipelagi* (1420); Benedetto Bordone, a miniaturist from Padua, whose *Isolario*
(Venice, 1528) describes all the islands of the known world; and the mostly nameless makers of
portolan charts.

**What.** Island books: an island per page, its outline, its old and new names, its stories.
Portolan charts: ink on vellum, the coasts only, and networks of straight coloured lines from
compass roses (rhumb lines); on early charts black dots marked rocks, and red dots shoals.

**Why it fits.** They draw each island alone, like the story's shape nanoplots, and they are
Mediterranean and Venetian books, as a tabelline story is a book of tables. Bordone was linked to
Aldus Manutius, the Venetian printer of the italic.

**For a page.** Vellum for paper, brown-black ink, red for the names that matter; rhumb lines as
the rules of a table; the compass rose as the circle that marks a place; an Aldine roman and italic
for the text.
"""
    nbSwatches sourceSwatches("isolari")
    nbText: """
[Cristoforo Buondelmonti](https://en.wikipedia.org/wiki/Cristoforo_Buondelmonti) ·
[Benedetto Bordone](https://en.wikipedia.org/wiki/Benedetto_Bordone)
([it](https://it.wikipedia.org/wiki/Benedetto_Bordone)) ·
[Portolan chart](https://en.wikipedia.org/wiki/Portolan_chart) ·
[Compass rose](https://en.wikipedia.org/wiki/Compass_rose) ·
[Aldus Manutius](https://en.wikipedia.org/wiki/Aldus_Manutius)
"""

  nbGalleryCard("The luzzu of Malta", "1900s–today"):
    nbText: """
**Who.** The fishermen and boatbuilders of Malta and Gozo.

**What.** The luzzu, a double-ended wooden fishing boat that grew in the early 20th century from
the Italian gozzo, painted yellow, red, green and blue, with a pair of eyes on the bow, perhaps a
Phoenician custom that survived. A few hundred still work, most of them at Marsaxlokk.

**Why it fits.** Island colour with rules. A 2016 study at the University of Malta (Anthony
Aquilina) found that maroon marked the waterline, and that the colour of the *mustaċċ*, the band
above it, told where a boat was from: red for St Paul's Bay, lemon for Msida or St Julian's,
ochre for Marsaxlokk and Marsascala; black meant mourning. Colour for role, as our rules say.

**For a page.** A band of colour along a table's top rule that says what the table is about;
the waterline maroon as the rule under it; hull blue for sections.
"""
    nbSwatches sourceSwatches("luzzu")
    nbText: """
[Luzzu](https://en.wikipedia.org/wiki/Luzzu) ·
[Luzzu Truths](https://www.um.edu.mt/think/luzzu-truths/) (University of Malta, Think magazine)
"""

  nbGalleryCard("Henri Matisse and Raoul Dufy", "1905–1953"):
    nbText: """
**Who.** Matisse painted at Collioure with André Derain in 1905, the summer that led to Fauvism, and lived
in Nice from 1917; Dufy painted regattas, elegant gatherings and views of the French Riviera,
and is buried near Matisse at Cimiez, in Nice.

**What.** Flat colour and pure blues; Matisse's late cut-outs, gouache paper cut with scissors;
Dufy's quick line drawn over washes of colour that do not stay inside it.

**Why it fits.** The Riviera's light, in colour; a cut-out shape is what an island outline looks like.

**For a page.** Ultramarine as the primary; markers cut out of paper, with uneven edges; a fill
that does not quite meet its line, for highlighted cells.
"""
    nbSwatches sourceSwatches("matisse")
    nbText: """
[Henri Matisse](https://en.wikipedia.org/wiki/Henri_Matisse) ·
[Raoul Dufy](https://en.wikipedia.org/wiki/Raoul_Dufy)
"""

  nbGalleryCard("Gio Ponti and the maiolica of Vietri and Caltagirone", "1400s–1960"):
    nbText: """
**Who.** Ponti, the Milanese architect and designer; the potters of Vietri sul Mare, on the Amalfi
Coast, and of Caltagirone, in Sicily.

**What.** For the Hotel Parco dei Principi in Sorrento (1960), Ponti drew with Ceramica D'Agostino
blue and white tiles that combine into more than a hundred patterns. Vietri has made polychrome
ceramics since at least the 15th century; in Caltagirone the 142 steps of the stair of Santa Maria
del Monte are faced with maiolica.

**Why it fits.** The Mediterranean as a made thing, an everyday one: the plates the islands eat from.

**For a page.** Tin-glaze white for paper, cobalt for the primary, yellow and green; a card as a
tile, a square sheet with a painted border; a row group as a band of tiles.
"""
    nbSwatches sourceSwatches("maiolica")
    nbText: """
[Gio Ponti](https://en.wikipedia.org/wiki/Gio_Ponti) ·
[Vietri sul Mare](https://en.wikipedia.org/wiki/Vietri_sul_Mare) ·
[Caltagirone](https://it.wikipedia.org/wiki/Caltagirone) ·
[Scalinata di Santa Maria del Monte](https://it.wikipedia.org/wiki/Scalinata_di_Santa_Maria_del_Monte)
"""

  nbGalleryCard("Ferdinand Bauer and the Flora Graeca", "1786–1840"):
    nbText: """
**Who.** Ferdinand Bauer (1760–1826), an Austrian botanical illustrator, and John Sibthorp, an
Oxford professor, who met in Vienna, where Sibthorp had gone to study the *Vienna Dioscurides*.

**What.** From March 1786 to December 1787 they surveyed the plants and animals of the eastern
Mediterranean, in Greece and Asia Minor; Bauer came back with over 1,500 sketches. Unable to carry
all the colours he needed, he covered his sketches with colour numbers, by a table of colours, and
painted them later at leisure. The *Flora Graeca* came out from 1806 to 1840, ten volumes of plates
engraved by James Sowerby; only 30 sets were issued at first.

**Why it fits.** The plants of the islands drawn one at a time, as the isolari drew the islands; and
colours by number, from a table: a look made with a table.

**For a page.** Hairlines and much white; a legend as Bauer's table of colours, numbers that stand
for colours; italic Latin names. The colours here are named after plants of the region, not
sampled from his plates.
"""
    nbSwatches sourceSwatches("bauer")
    nbText: """
[Ferdinand Bauer](https://en.wikipedia.org/wiki/Ferdinand_Bauer) ·
[Flora Graeca](https://en.wikipedia.org/wiki/Flora_Graeca) ·
[Digital Flora Graeca](https://www.bodleian.ox.ac.uk/science/resources/sherardian-library/flora_graeca) (Bodleian)
"""

  nbGalleryCard("Leo Lionni", "1960s–1999"):
    nbText: """
**Who.** A writer and illustrator of children's books, born in Amsterdam in 1910, who grew up
partly in Italy, studied economics in Genoa, worked in advertising and at *Fortune* in the United
States, and came back to Italy in 1962; he died in Tuscany in 1999.

**What.** More than forty children's books, four of them Caldecott Honor books, *Swimmy* (1963)
among them: a small black fish in a school of red ones, in the sea. He was the first children's
illustrator to make collage his main medium.

**Why it fits.** The sea told to children: the look of a children's book, as Munari is, but wet.
Swimmy is also a lesson for tables: many small marks that make one shape.

**For a page.** Collage edges for the shapes; red for sections, sea blue for cards; a small black
mark among red ones for the row that matters.
"""
    nbSwatches sourceSwatches("lionni")
    nbText: """
[Leo Lionni](https://en.wikipedia.org/wiki/Leo_Lionni) ·
[Swimmy](https://en.wikipedia.org/wiki/Swimmy_(book))
"""

  nbGalleryCard("Emanuele Luzzati", "1944–2007"):
    nbText: """
**Who.** A painter, illustrator, stage designer and animator from Genoa (1921–2007), who studied in
Lausanne after the racial laws of 1938 and came back to Italy after the war.

**What.** Stage designs from 1944; with Giulio Gianini, animated films, two of them nominated for
an Oscar, *La gazza ladra* (1964) and *Pulcinella* (1973); children's books of his own
(*Tarantella di Pulcinella*, *I tre fratelli*), Italo Calvino's Italian fairy tales and Gianni
Rodari's rhymes.

**Why it fits.** A Mediterranean port city's theatre for children: Pulcinella, tarantellas, bright
flat colour on a stage.

**For a page.** A page as a little stage: headings like painted backdrops, magenta and gold, black
outlines; a table's title as the name over a stage.
"""
    nbSwatches sourceSwatches("luzzati")
    nbText: """
[Emanuele Luzzati](https://en.wikipedia.org/wiki/Emanuele_Luzzati) ·
[Gianni Rodari](https://en.wikipedia.org/wiki/Gianni_Rodari)
"""

  nbGalleryCard("Maria Lai", "1943–2013"):
    nbText: """
**Who.** An artist from Ulassai, in Sardinia (1919–2013), who studied in Venice under Arturo
Martini and worked in weaving, embroidery, writing, sculpture and drawing; she died in Cardedu, near
Ulassai, and in 2006 opened a museum of her work in the village's old railway station.

**What.** *Legarsi alla montagna* (1981): for three days, 27 km of blue ribbon tied the houses of
Ulassai to each other and to the mountain above, after a local tale of a child saved by a blue
ribbon; a knot or a loaf of bread for a friendship, a taut ribbon for a quarrel. Then works of
thread on cloth, and *sewn fables*, books made with needle and thread, such as *Tenendo per mano il
sole* (1984).

**Why it fits.** An islander who stayed on her island, less known than the others, and soft:
linen, thread, bread and one blue. Her ribbon says what the story says with Braudel: islands are
tied to each other, not alone.

**For a page.** Rules stitched rather than drawn; a ribbon of the primary blue that ties the rows
or sections that belong together; a book of tables as a sewn book.
"""
    nbSwatches sourceSwatches("lai")
    nbText: """
[Maria Lai](https://en.wikipedia.org/wiki/Maria_Lai) ·
[her CV](https://www.m77gallery.com/wp-content/uploads/2018/09/M77-CV-Maria-Lai.pdf) (M77 gallery)
"""

  nbGalleryCard("Mediterraneo, by Gabriele Salvatores", "1991"):
    nbText: """
**Who.** Gabriele Salvatores, an Italian director, and Enzo Monteleone, who wrote the film.

**What.** *Mediterraneo* (1991): in 1941 a group of misfit Italian soldiers is sent to Megisti, a
small Greek island, for four months of lookout duty, and the war forgets them there; their
lieutenant, an amateur painter, restores the murals of the church. Filmed on Kastellorizo (Megisti),
it won the Academy Award for Best Foreign Language Film in 1992, and brought tourists to the island.

**Why it fits.** A small island seen by people who came from elsewhere and stayed: what the story's
"how they live now" and "getting there" are about. The only film among the sources.

**For a page.** Whitewash and harbour water; the plaster of the harbour's houses for the other
roles; titles as a film's, a few words, widely spaced.
"""
    nbSwatches sourceSwatches("mediterraneo")
    nbText: """
[Mediterraneo](https://en.wikipedia.org/wiki/Mediterraneo) ·
[Kastellorizo](https://en.wikipedia.org/wiki/Kastellorizo)
"""

  nbGalleryCard("Massimo Vitali", "1995–"):
    nbText: """
**Who.** An Italian photographer, born in 1944 in Como and living in Lucca, once a photojournalist
and a film camera operator.

**What.** Since 1995, large-format photographs taken from a platform four or five metres high:
beaches, clubs and squares, crowded and bleached by the sun.

**Why it fits.** The Mediterranean of today's summers, the one the story's "when to go" is about:
a crowd of small bright figures, like a table of many small numbers.

**For a page.** Bleached paper, high key; dense rows of small marks; the red and yellow of the
umbrellas as status colours, and the turquoise of shallow sea.
"""
    nbSwatches sourceSwatches("vitali")
    nbText: """
[Massimo Vitali](https://en.wikipedia.org/wiki/Massimo_Vitali) ·
[massimovitali.com](https://www.massimovitali.com/)
"""

  nbGalleryCard("The houses of Corricella, Procida", "today"):
    nbText: """
**Who.** The people of Procida, one of the Phlegraean Islands off Naples (9,971 inhabitants), who
turned from farming to fishing from the 1300s; and the more than 30 films shot there, among them
*Il Postino* and *The Talented Mr. Ripley*.

**What.** Corricella, the fishing port, known for its houses, each painted in a different pastel
shade; above it Terra Murata, the walled village. Italian Capital of Culture in 2022.

**Why it fits.** Colours chosen house by house, by the people of an island, and soft: pastels
side by side, none shouting. With Djerba, the houses of two shores.

**For a page.** A table as a harbour front: each row group a house of its own pale colour, the
pink for sections, the green of the shutters for what works.
"""
    nbSwatches sourceSwatches("procida")
    nbText: """
[Procida](https://en.wikipedia.org/wiki/Procida) ·
[Corricella](https://en.wikipedia.org/wiki/Corricella)
"""

  nbGalleryCard("The menzel of Djerba", "today"):
    nbText: """
**Who.** The people of Djerba, an island off southern Tunisia, where Phoenicians from Tyre and Sidon
came in the 12th century BC and spread pottery and purple dye.

**What.** The *menzel*, a family's house and farm of two to five hectares: a few houses around a
courtyard, with no windows outside, under vaults and domes; wells and cisterns for the rain (less
than 250 mm a year), hedges of prickly pear and agave, sometimes a weaving workshop and an olive
press underground. Since 2023 the island is a World Heritage Site, "a testimony to a settlement
pattern in an island territory".

**Why it fits.** The southern shore, which no other source comes from, and an island in the
story's own table of world heritage.

**For a page.** Inward-looking cards: a plain outside, colour inside, as a courtyard; domes for
the circles; the purple of the murex for sections, and the clay of the pots.
"""
    nbSwatches sourceSwatches("djerba")
    nbText: """
[Djerba](https://en.wikipedia.org/wiki/Djerba) ·
[Menzel](https://en.wikipedia.org/wiki/Menzel_(Djerba)) ·
[UNESCO](https://whc.unesco.org/en/list/1640)
"""

nbText: """
## Discarded

A source that is discarded moves here, and a new one takes its place, found by looking in another
direction and with what the discarded one taught. Eighteen sources at most are looked at in all:
once nine new ones have come in, a discard only makes the gallery shorter. All 18 are in now: from
here on, the gallery only shrinks.

1. **Luigi Ghirri**, round 2: the softest light, but not of the islands. In his place came the
   **luzzu of Malta**: made on an island, in colours with rules, the lesson his card taught.
2. **Herbert List and Constantine Manos**, and **Ferdinando Scianna**, round 3: four photographers
   were too many, and black and white gives a look no colours of its own. In their place came two
   artists of children's books, **Leo Lionni** and **Emanuele Luzzati**: the look of a children's
   book is what Munari has, and they bring the sea and the theatre of a port.
3. **Joan Miró**, round 4: he fits, but he is too well known and his palette too sharp. In his
   place came **Maria Lai**, a Sardinian artist less known abroad, whose colours are linen, thread,
   bread and one blue ribbon. Then five more, to reach eighteen, each from a direction not yet
   looked at: mosaics (the **Villa Romana del Casale**), botanical illustration (**Ferdinand Bauer**),
   a film (**Mediterraneo**), and the houses of two shores (**Procida** and **Djerba**), the first
   source from the south.
"""

nbGallery "discarded sources, newest first: swipe or scroll sideways":

  nbGalleryCard("Joan Miró in Mallorca", "1929–1983"):
    nbText: """
**Who.** The Catalan painter, born in Barcelona. He married Pilar Juncosa in Palma in 1929,
painted part of the *Constellations* there in 1940–1941, and made Palma his home, in a studio
designed for him by Josep Lluís Sert; he died there in 1983.

**What.** Flat primaries and black signs: stars, birds, eyes, ladders.

**Why it fits.** An islander by choice, who drew signs rather than pictures.

**For a page.** Black signs as markers. But his red, blue and yellow are Munari's: next to our
default it would look like more of the same.

**Why discarded** (round 4). It fits, but Miró is too well known, and his palette too sharp: a
famous palette brings its painter along, and flat primaries are Munari's already.
"""
    nbSwatches sourceSwatches("miro")
    nbText: """
[Joan Miró](https://en.wikipedia.org/wiki/Joan_Mir%C3%B3) ·
[Fundació Pilar i Joan Miró](https://en.wikipedia.org/wiki/Fundaci%C3%B3_Pilar_i_Joan_Mir%C3%B3_in_Mallorca)
"""

  nbGalleryCard("Herbert List and Constantine Manos", "1937–1964"):
    nbText: """
**Who.** List, a German photographer, travelled Greece from 1937 to 1939 for *Licht über Hellas*
(1953), staged with a surrealist, metaphysical eye. Manos, born in South Carolina to Greek
parents, lived in Greece from 1961 to 1964 for *A Greek Portfolio* (1972), and joined Magnum in 1963.

**What.** Black and white: hard sun, whitewash, deep shadow; temples and statues for List, people and landscapes for Manos.

**Why it fits.** The Greek islands in two values: the most readable look there can be.

**For a page.** Whitewash for paper and shadow for ink, and the other colours from the islands
themselves (a blue door, bougainvillea, broom, capers); notes as blocks of white with a hard shadow.

**Why discarded** (round 3). Four photographers were too many, and these two are black and white:
every colour but paper and ink had to come from the place, so the look would not be theirs.
"""
    nbSwatches sourceSwatches("list")
    nbText: """
[Herbert List](https://en.wikipedia.org/wiki/Herbert_List) ·
[Constantine Manos](https://en.wikipedia.org/wiki/Constantine_Manos)
"""

  nbGalleryCard("Ferdinando Scianna", "1965–"):
    nbText: """
**Who.** A Sicilian photographer, born in 1943 in Bagheria, near Palermo; a member of Magnum since
1982 (full member in 1989).

**What.** *Feste religiose in Sicilia* (1965), with an essay by Leonardo Sciascia; the Prix Nadar in 1966;
then reportage, books on Bagheria, and fashion: Dolce & Gabbana's Sicily, in 1987.

**Why it fits.** Sicily, the biggest island, seen from inside, and in books where a writer's words
sit beside the pictures, as the story's quotes do.

**For a page.** Black and white with grain, captions that matter, and one red, for feasts, as the
primary; the other colours from Sicily's painted carts and lemon groves.

**Why discarded** (round 3). One photographer too many, and black and white: three of his five
colours came from the place.
"""
    nbSwatches sourceSwatches("scianna")
    nbText: """
[Ferdinando Scianna](https://en.wikipedia.org/wiki/Ferdinando_Scianna)
"""

  nbGalleryCard("Luigi Ghirri", "1973–1992"):
    nbText: """
**Who.** An Italian photographer, born in 1943 near Reggio Emilia, who died in 1992.

**What.** Colour photographs of ordinary places looked at with care: *Atlante* (1973), *Kodachrome*
(1978), and *Viaggio in Italia*, the photographers' journey he led in 1984.

**Why it fits.** Not an island photographer: his Italy is mostly Emilia. He is here for his light,
the softest of the nine, pale colours and a lot of empty sky.

**For a page.** Pale paper and pastels, much white space, small captions, tables with almost no rules.

**Why discarded** (round 2). Not of the islands; and his pale colours fail the rules: the pale
sky reaches 2.0:1 on his paper, the faded pink 1.6:1, too faint for a section circle or a card,
and even his soft black stays under 10:1.
"""
    nbSwatches sourceSwatches("ghirri")
    nbText: """
[Luigi Ghirri](https://en.wikipedia.org/wiki/Luigi_Ghirri)
"""


nbText: """
## How sources are chosen

Every source, kept or discarded, by kind. The process, as it stands after four rounds:

1. **Look wide first.** Painters, photographers, map makers, potters, boatbuilders, illustrators:
   no more than two of a kind among the candidates, so one kind of picture does not decide the look
   (four photographers were too many).
2. **Of the Mediterranean, and best of its islands.** A source that only lends its light is
   discarded (Ghirri).
3. **Less known over famous, soft over sharp.** A famous palette brings its painter along, and a
   sharp one shouts over the tables (Miró).
4. **Colours of its own.** A source must give at least four of the six colours from its own
   materials, by the rules above; black and white sources borrow too much from the place.
5. **Something for a page.** Each card ends with what a page could take: a rule, a motif, a way to
   draw a table. A source with nothing to give there is not a source for a look.
6. **Facts with references.** Every fact on a card comes from a page that is linked on it.
7. **A fixed budget.** Pietro discards; each discard brings a new source from another direction,
   until eighteen have been looked at; after that the gallery only shrinks, and a tournament
   (below) helps to choose.
"""

block:  # every source, by kind
  type Source = object
    source, kind, place, period, status: string
    round: int
  func src(source, kind, place, period, status: string, round: int): Source =
    Source(source: source, kind: kind, place: place, period: period, status: status, round: round)
  let sources = @[
    src("Minoan frescoes and Attic vases", "painters, potters", "Crete, Thera, Athens", "1600–300 BC", "candidates", 1),
    src("Isolari and portolan charts", "map makers", "Florence, Venice", "1200s–1528", "candidates", 1),
    src("Luzzu of Malta", "boatbuilders", "Malta, Gozo", "1900s–today", "candidates", 2),
    src("Matisse and Dufy", "painters", "Collioure, Nice", "1905–1953", "candidates", 1),
    src("Gio Ponti and the maiolica", "designer, potters", "Sorrento, Vietri, Caltagirone", "1400s–1960", "candidates", 1),
    src("Leo Lionni", "children's books", "Genoa, Tuscany", "1960s–1999", "candidates", 3),
    src("Emanuele Luzzati", "children's books, theatre", "Genoa", "1944–2007", "candidates", 3),
    src("Maria Lai", "weaving, sewn books", "Sardinia", "1943–2013", "candidates", 4),
    src("Massimo Vitali", "photographer", "Italian beaches", "1995–", "candidates", 1),
    src("Villa Romana del Casale", "mosaicists", "Sicily", "300s AD", "candidates", 4),
    src("Ferdinand Bauer, Flora Graeca", "botanical illustrator", "Greece, Asia Minor", "1786–1840", "candidates", 4),
    src("Mediterraneo", "film", "Kastellorizo", "1991", "candidates", 4),
    src("Houses of Corricella", "houses", "Procida", "today", "candidates", 4),
    src("Menzel of Djerba", "houses", "Djerba", "today", "candidates", 4),
    src("Joan Miró", "painter", "Mallorca", "1929–1983", "discarded", 4),
    src("Herbert List and Constantine Manos", "photographers", "Greece", "1937–1964", "discarded", 3),
    src("Ferdinando Scianna", "photographer", "Sicily", "1965–", "discarded", 3),
    src("Luigi Ghirri", "photographer", "Emilia", "1973–1992", "discarded", 2),
  ]
  let t = tabella(sources, rownameCol = "source", groupnameCol = "status"):
    tabHeader "Eighteen sources of eighteen", "fourteen candidates, four discarded"
    colsLabel:
      round: "round"
    colsHide "period"
    tabSourceNote "Round: when a candidate came in, or when a source was discarded. Round 1 proposed the first nine; each discard brought one new source, and round 4 five more, to reach eighteen."
    optCssTheme()
  nbTable t

nbText: """
## What each could give

The fourteen side by side: what each would bring to the parts of a page.
"""

block:
  type Idea = object
    source, colours, tables, shapes: string
  func i(source, colours, tables, shapes: string): Idea =
    Idea(source: source, colours: colours, tables: tables, shapes: shapes)
  let ideas = @[
    i("Minoan and Attic", "terracotta and black, dolphin blue", "a meander as the top rule", "dolphins and octopus, sparingly"),
    i("Isolari, portolans", "vellum, brown ink, cinnabar", "thin rhumb lines", "the compass rose as the circle"),
    i("Matisse, Dufy", "ultramarine, pink, lemon", "colour that misses its line", "cut-out paper shapes"),
    i("Ponti, maiolica", "cobalt, terracotta, yellow, green", "a row group as a band of tiles", "a card as a tile"),
    i("Lionni", "red fish, sea blue, black", "many small marks, one shape", "collage edges"),
    i("Luzzati", "magenta, gold, blue, black outlines", "the title as a stage's name", "painted backdrops"),
    i("Luzzu", "hull blue, maroon, lemon, green", "a coloured band on the top rule", "a band whose colour says what"),
    i("Lai", "linen, black thread, ribbon blue, bread", "stitched rules", "a ribbon that ties rows together"),
    i("Vitali", "bleached, turquoise, red, yellow", "dense and small", "small marks"),
    i("Casale", "limestone, red and yellow ochre, glass blue", "cells parted by mortar", "a border of small squares"),
    i("Bauer", "white, iron-gall ink, plant colours", "a legend as a table of colours", "hairlines, italic Latin"),
    i("Mediterraneo", "whitewash, harbour water, plaster", "titles as a film's", "few words, widely spaced"),
    i("Procida", "pastels, pink, shutter green", "row groups as houses", "a harbour front"),
    i("Djerba", "plaster, murex purple, clay", "plain outside, colour inside", "domes for circles"),
  ]
  let t = tabella(ideas, rownameCol = "source"):
    tabHeader "Fourteen sources, part by part", "what a Mediterranean look could take from each"
    colsLabel:
      colours: "colours"
      tables: "tables"
      shapes: "shapes and motifs"
    optCssTheme()
  nbTable t

nbText: """
## Three directions

The first nine fold into three looks; the five of round 4 can join them (the mosaics and Bauer an
isolario, Procida a maiolica, Djerba and Mediterraneo a harbour), or win on their own in the
tournament. Each borrows its structure from one source and may take colours
from another.

1. **Isolario**: the island book. Vellum paper, brown-black ink, cinnabar red for sections and
   names; thin rhumb lines for rules; the compass rose for the circle; an Aldine roman and italic.
   The colours of the maiolica (cobalt, yellow, green) could fill the other roles.
2. **Maiolica**: the tiled kitchen. Tin-glaze white, cobalt, Vietri yellow and copper green; cards
   and notes as tiles, row groups as bands; Ponti for the patterns.
3. **Harbour**: the luzzu, whose colours say where a boat is from, with Vitali's crowds for the
   dense tables. Limestone paper, hull blue, waterline maroon, lemon and green; a band of colour
   along the top of each table.

Our pick is the first, with the maiolica's colours. It has the deepest roots in the story, the
islands drawn one at a time; it is the furthest from Munari and from the quaderno; and it is a book
of the Mediterranean, as the story is.

"""

nbText: """
## A tournament

Eighteen are in, and discarding gets harder: so the fourteen candidates play a tournament. In each
match tap the source you would keep; the one you tap goes on to the next round, until one is left.
The two sources of our pick, the isolari and the maiolica, start a round later (a bye), at the two
ends of the draw; every first-round match is between two of a kind: two ancient floors and walls,
the houses of two shores, two harbours, two children's books, two hands at work (a brush, a needle),
two beaches. Your picks stay on this device; **Copy the result** gives them as Markdown, to paste in
the chat.
"""

block:  # the draw: the places of a 16 bracket, two of them byes
  func player(name, what, key: string): TournamentEntry =
    var colours: seq[string]
    for c in sourceColours(key): colours.add c.hex
    entry(name, what, colours)
  nbTournament "mediterranean-sources", "Tournament of the Mediterranean sources", [
    player("The isolari and the portolan charts", "map makers, 1200s–1528", "isolari"), bye(),
    player("Minoan frescoes and Attic vases", "painters, potters, 1600–300 BC", "minoan"),
    player("The mosaics of the Villa Romana del Casale", "mosaicists, 300s AD", "casale"),
    player("The houses of Corricella, Procida", "houses, today", "procida"),
    player("The menzel of Djerba", "houses, today", "djerba"),
    player("The luzzu of Malta", "boatbuilders, 1900s–today", "luzzu"),
    player("Mediterraneo, by Gabriele Salvatores", "a film, 1991", "mediterraneo"),
    player("Leo Lionni", "children's books, 1960s–1999", "lionni"),
    player("Emanuele Luzzati", "children's books, theatre, 1944–2007", "luzzati"),
    player("Ferdinand Bauer and the Flora Graeca", "botanical illustrator, 1786–1840", "bauer"),
    player("Maria Lai", "weaving, sewn books, 1943–2013", "lai"),
    player("Henri Matisse and Raoul Dufy", "painters, 1905–1953", "matisse"),
    player("Massimo Vitali", "photographer, 1995–", "vitali"),
    player("Gio Ponti and the maiolica", "designer, potters, 1400s–1960", "maiolica"), bye()]

nbText: """
## Rounds

1. **Round 1**: nine sources, each with who, what, why it fits, ideas for a page and references;
   three directions.
2. **Round 2**: the sources in a gallery; rules for picking colours and giving them roles, and every
   palette checked against them (the maiolica's terracotta became secondary and its green success;
   Scianna's red became primary; Vitali's sand gave way to a stone pine; Dufy's pink and Vitali's
   sea got darker to reach 3:1); Ghirri discarded, the luzzu in his place; a gallery of the
   discarded.

3. **Round 3**: four photographers were too many: List and Manos, and Scianna, discarded; two
   artists of children's books in their place, Leo Lionni and Emanuele Luzzati; a table of every
   source by kind and status, and how sources are chosen.
4. **Round 4**: discarding is hard, so only one: Miró, too well known and too sharp; Maria Lai in
   his place; five more sources to reach eighteen; and a tournament of the fourteen.

Next, Pietro plays the tournament (or picks a direction, or a mix), and a round builds the winner on this page: the six colours,
typefaces that pass the line of names above, and the motifs, on a real table of the islands, in
Munari and in the new look side by side.
"""

nbSave
