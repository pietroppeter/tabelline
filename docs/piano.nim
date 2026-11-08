## The plan of the releases: for each one, the three threads that make it (build, use it, port
## the references) and what each will produce. Shared by the roadmap (kept up to date) and
## the devlog post that introduced it. Change it here when a thread starts, ships or changes
## its plan.

type
  Thread* = object
    kind*: string        ## "build", "use", "port"
    title*, what*, output*, status*: string
  Release* = object
    version*, theme*: string
    threads*: seq[Thread]

func t(kind, title, what, output: string, status = "planned"): Thread =
  Thread(kind: kind, title: title, what: what, output: output, status: status)

const threadKinds* = [
  ("build", "🔨", "Build it",
   "Implements the release from the coverage map: one OpenSpec change per feature group, built in PRs. Ends with the release PR and the tag. Writes the API design post: which features and why, how they are built, R against Python against Nim, and the Nim sugar."),
  ("use", "🧭", "Use it",
   "Picks a domain, downloads real data, and writes an explainer about the domain with every new feature, as a user would, without thinking about the implementation. Starts in Python with Great Tables (and R with gt) while the release is built, then in Nim. Reports what is missing, awkward or broken to the build thread."),
  ("port", "📚", "Port the references",
   "Takes reference code from outside (the gt and Great Tables guides, their examples, Table Contest entries) and ports it to tabelline, with the original next to it, in the tabelline book: a nimibook in this repository, in the Edo palette. Every gap it finds goes to the build thread or the backlog."),
]

const releases*: seq[Release] = @[
  Release(version: "0.1", theme: "The basics", threads: @[
    t("build", "Build tabelline 0.1",
      "The 24 small groups proposed in the coverage map (formats, substitutions, caption, rm verbs, order of rows, options, locations), then the release.",
      "post Designing tabelline 0.1; tag v0.1.0"),
    t("use", "Use it: a month of building with AI, and Operetta",
      "A simple, conceptual explainer of a month of open source work on GitHub with Claude (libraries, talks, explainers in claude-artifacts), and from it the first design of Operetta: a modular way to build AI-native libraries (living documents, devlog, OpenSpec, coverage, roadmap, book, skills), each part picked by a project's kind and maturity. Includes what skills are and where they live.",
      "an article in three parts in claude-artifacts: the month, Operetta, skills; 👑 🐍 🏴‍☠️ tabs", "in review"),
    t("port", "Port the Great Tables guide, Get Started",
      "The first section of the Great Tables user guide (header and footer, stub, column labels, formats, styles, selections) and gt's Introduction to creating gt tables. Both MIT.",
      "tabelline book (nimibook, Edo), first chapters"),
  ]),
  Release(version: "0.2", theme: "Rows and merges", threads: @[
    t("build", "Build tabelline 0.2",
      "Summary rows (change add-summary-rows), merged columns, rows added and hidden, stub indent, decimal alignment, more options.",
      "post Designing tabelline 0.2; tag v0.2.0"),
    t("use", "Use it: the FOSDEM devrooms",
      "The history of FOSDEM's devrooms, year by year: names, renames, splits, and the dates of FOSDEM, which fall at different moments. Starts from the FOSDEM devrooms page of claude-artifacts (2024 to 2027) and goes back as far as the schedules go.",
      "explainer post"),
    t("port", "Port the gt case studies",
      "gt's gtcars and sza case studies and the Great Tables examples gallery: groups, summaries, merges.",
      "tabelline book"),
  ]),
  Release(version: "0.3", theme: "Every format, every locale", threads: @[
    t("build", "Build tabelline 0.3",
      "Units, fractions, chemistry, bins, country names, dates and currencies in many languages (CLDR), tables from nanuq and datamancer data frames.",
      "post Designing tabelline 0.3; tag v0.3.0"),
    t("use", "Use it: the climate of Italian cities",
      "Climate normals of Italian cities, in Italian, English and Japanese: units, months, decimal marks. The data read with nanuq.",
      "explainer post"),
    t("port", "Port the formats and the Table Contest",
      "The format examples of gt's reference (fmt_units, fmt_fraction, ...) and Posit Table Contest entries whose licence allows a port.",
      "tabelline book"),
  ]),
  Release(version: "0.4", theme: "Pictures in cells", threads: @[
    t("build", "Build tabelline 0.4",
      "Images inlined as data URLs, a small set of SVG icons, nanoplots (lines, bars, boxes), fmtBar layouts.",
      "post Designing tabelline 0.4; tag v0.4.0"),
    t("use", "Use it: the moons of the Solar System",
      "The planets' moons with NASA images (public domain), icons for their kind, and nanoplots of their orbits and sizes.",
      "explainer post"),
    t("port", "Port nanoplots and images",
      "The Great Tables nanoplots guide and blog posts, gt's image and icon examples.",
      "tabelline book"),
  ]),
  Release(version: "0.5", theme: "Out of the browser", threads: @[
    t("build", "Build tabelline 0.5",
      "LaTeX, RTF and Word, images and PDF of a table, groups of tables and split tables, extract.",
      "post Designing tabelline 0.5; tag v0.5.0"),
    t("use", "Use it: a clinical table",
      "The demographic and adverse event tables of a clinical study report, from the public CDISC pilot data, in Word, RTF and PDF.",
      "explainer post"),
    t("port", "Port the pharma tables",
      "Tables from the pharmaverse examples and gt's LaTeX and RTF articles, where licences allow.",
      "tabelline book"),
  ]),
]

const leftAside* = [
  ("Interactive tables", "opt_interactive(): sorting, filtering, paging. The parked Tabellone idea, a small grid for a few thousand rows."),
  ("R and Python machinery", "Shiny (gt_output, render_gt), grid graphics (as_gtable), ggplot_image, tab_info."),
  ("Remote fonts", "google_font(): pages stay standalone, so fonts are inlined instead."),
]
