## devlog: 11 Nov 2026 D | Designing a Mediterranean look | The islands story gets a look of its own, in place of the quaderno: a Mediterranean one. Designed in rounds, in this post. Round 1: nine sources to learn from, from Minoan frescoes to Massimo Vitali's beaches, each with who they are, what they made, why they fit and what a page could take from them; three directions to choose from, and what any look must give.
## A dated post: it tells how the Mediterranean look was designed, round by round, and is not rewritten afterwards.
import std/os
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
each, and three directions to choose from.
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

## Nine sources

People and traditions to learn from, oldest first, in a gallery to swipe. For each: who they are, what they made, why they
fit the islands, and what a page could take. The six colours under each are our reading of that
kind of work, picked by eye in the roles above, not sampled from a picture; the references are
where the facts come from.
"""

nbGallery "nine sources for a Mediterranean look, oldest first: swipe or scroll sideways":

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

  nbGalleryCard("Joan Miró in Mallorca", "1929–1983"):
    nbText: """
**Who.** The Catalan painter, born in Barcelona. He married Pilar Juncosa in Palma in 1929,
painted part of the *Constellations* there in 1940–1941, and made Palma his home, in a studio
designed for him by Josep Lluís Sert; he died there in 1983.

**What.** Flat primaries and black signs: stars, birds, eyes, ladders.

**Why it fits.** An islander by choice, who drew signs rather than pictures.

**For a page.** Black signs as markers. But his red, blue and yellow are Munari's: next to our
default it would look like more of the same.
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

**For a page.** Whitewash for paper and shadow for ink, and one colour only, the blue of a door;
notes as blocks of white with a hard shadow.
"""
    nbSwatches sourceSwatches("list")
    nbText: """
[Herbert List](https://en.wikipedia.org/wiki/Herbert_List) ·
[Constantine Manos](https://en.wikipedia.org/wiki/Constantine_Manos)
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

  nbGalleryCard("Ferdinando Scianna", "1965–"):
    nbText: """
**Who.** A Sicilian photographer, born in 1943 in Bagheria, near Palermo; a member of Magnum since
1982 (full member in 1989).

**What.** *Feste religiose in Sicilia* (1965), with an essay by Leonardo Sciascia; the Prix Nadar in 1966;
then reportage, books on Bagheria, and fashion: Dolce & Gabbana's Sicily, in 1987.

**Why it fits.** Sicily, the biggest island, seen from inside, and in books where a writer's words
sit beside the pictures, as the story's quotes do.

**For a page.** Black and white with grain, captions that matter, and one red only, for feasts.
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
"""
    nbSwatches sourceSwatches("ghirri")
    nbText: """
[Luigi Ghirri](https://en.wikipedia.org/wiki/Luigi_Ghirri)
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

nbText: """
## What each could give

The nine side by side: what each would bring to the parts of a page.
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
    i("Miró", "Munari's primaries, black", "plain", "black signs, stars"),
    i("List, Manos", "black and white, one blue", "heavy black rules", "hard shadows"),
    i("Ponti, maiolica", "cobalt, yellow, green on white", "a row group as a band of tiles", "a card as a tile"),
    i("Scianna", "black and white, one red", "plain, captions first", "none"),
    i("Ghirri", "pale sky, faded pink", "almost no rules", "none: empty space"),
    i("Vitali", "bleached, turquoise, red, yellow", "dense and small", "small marks"),
  ]
  let t = tabella(ideas, rownameCol = "source"):
    tabHeader "Nine sources, part by part", "what a Mediterranean look could take from each"
    colsLabel:
      colours: "colours"
      tables: "tables"
      shapes: "shapes and motifs"
    optCssTheme()
  nbTable t

nbText: """
## Three directions

The nine fold into three looks. Each borrows its structure from one source and may take colours
from another.

1. **Isolario**: the island book. Vellum paper, brown-black ink, cinnabar red for sections and
   names; thin rhumb lines for rules; the compass rose for the circle; an Aldine roman and italic.
   The colours of the maiolica (cobalt, yellow, green) could fill the other roles.
2. **Maiolica**: the tiled kitchen. Tin-glaze white, cobalt, Vietri yellow and copper green; cards
   and notes as tiles, row groups as bands; Ponti for the patterns.
3. **Summer light**: Ghirri's pale colours with Vitali's crowds. Bleached paper, turquoise sea, umbrella
   red and yellow; almost no rules, and a lot of air.

Our pick is the first, with the maiolica's colours. It has the deepest roots in the story, the
islands drawn one at a time; it is the furthest from Munari and from the quaderno; and it is a book
of the Mediterranean, as the story is.

## Next round

Pietro picks a direction (or a mix). Round 2 then builds it on this page: the six colours, typefaces
that pass the line of names above, and the motifs, shown on a real table of the islands, in Munari
and in the new look side by side.
"""

nbSave
