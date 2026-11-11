## devlog: 11 Nov 2026 G | tabelline in eight languages | Nim compiles to C, so tabelline can be a C library, and every language that calls C can draw a tabelline table. Proofs of concept for C, Zig, Rust, Julia, Java, Erlang, Gleam and Elixir: a C ABI in two layers, every verb generated from tabelline's own signatures, one binding per language in its own style, and a check that all of them print the same HTML as Nim, byte for byte.
## A dated post: the proofs of concept (now in tabelline-polyglot, a docs dependency in deps/), and is not updated afterwards.
import std/[os, json, strutils]
import nimib
import tabelline, tabelline/nimib
import ../blocks
import capi/[spec, verbs_json]  # from tabelline-polyglot (the docs feature, in deps/)

let docs = currentSourcePath().parentDir.parentDir
let poc = docs.parentDir / "deps" / "tabelline_polyglot"

template fold(file: string, start = "", stop = "", title = "") =
  ## a file of tabelline-polyglot, folded under its path there (or `title`)
  nb.foldCode(poc / file, start, stop, if title.len > 0: title else: file)

nbInit
nb.doc.filename = docs / "devlog" / "polyglot" / "index.html"
nb.useTabelline(title = "tabelline in eight languages", homeHref = "../", backLabel = "Devlog", wordmarkHref = "../../")

nbTitle "11 November 2026", "tabelline in eight languages", """
Nim compiles to C, so tabelline can be a C library, and every language that calls C can draw a
tabelline table. Proofs of concept for C, Zig, Rust, Julia, Java, Erlang, Gleam and Elixir, and a
check that all of them print the same HTML as Nim, byte for byte.
"""

nbText: """
[Great tables in every language](../polyglot-survey/) found that outside R and Python almost no
language has gt's grammar: Rust, Zig, Gleam, Ruby and the JVM have table printers, not display
tables. This post is the other half: tabelline, called from eight of those languages. Not ports
yet; proofs that a port can start from a working table.

From the simplest to the most complex: one table to draw, a Nim library seen from C, the two
layers of the C API, how every verb gets there without being written twice, the eight
languages, the check, and what a real repository would add. The code is in
[tabelline-polyglot](https://github.com/pietroppeter/tabelline-polyglot), a repository of its
own since the afternoon this was written.

## One table to draw

Every language draws the same table: the eight planets, grouped by type, with a header, a
spanner, labels, three number formats, a colour scale, a bold cell, a footnote and a source
note. Small, but it touches every part of a table. This is it, drawn on this page by the same
code the C library runs.
"""

nbTable tabellaFromSpec(parseJson(readFile(poc / "spec" / "planets.json")))

nbNote """
Green cards are about the code. This table is not written in Nim on this page: it is
`spec/planets.json` read by `tabellaFromSpec`, the function behind the C call
`tbl_render_spec`, so the page shows what every port gets.
""", nkCode

nbText: """
In tabelline it is ten verbs, one per line:
"""

fold "nim/planets.nim", start = "let t = tabella", stop = "stdout.write",
  title = "nim/planets.nim, the reference"

nbText: """
## A Nim library is a C library

Nim compiles to C, then a C compiler makes the program. With `--app:lib` it makes a shared
library instead (`.so` on Linux, `.dylib` on macOS, `.dll` on Windows), and a proc marked
`exportc` keeps its name in it, so C can find it:

```nim
proc tbl_version(): cstring {.exportc, dynlib, cdecl.} = "0.0.1"
```

`exportc` keeps the name `tbl_version`, `dynlib` puts it in the library's table of exported
names, `cdecl` uses C's calling convention. Then a C header declares it, and any C program can
call it:

```c
const char *tbl_version(void);
```

Four things make a real library out of that.

1. **Nim starts itself.** A Nim library runs its module-level code (tabelline's palettes and
   locales) when it is loaded, before the first call: no `NimMain()` to call by hand.
2. **Who frees what.** A string the library returns is copied into memory from C's `malloc`, and
   the caller gives it back with `tbl_free`. Strings the caller passes are only read.
3. **Errors without exceptions.** C has no exceptions, so a call that fails returns `NULL` (or
   `-1`), and `tbl_error()` says why. The message is per thread.
4. **Foreign threads.** The JVM and the BEAM call from threads Nim did not start. With
   `-d:useMalloc` Nim allocates with C's allocator, which any thread may use.

## Layer 1: one call

The simplest C API a table library can have is one function: the table in, the table out. The
table is JSON, as in lt's spec: the data, the stub, and the verbs in order, each an object with
one key, its name, and its arguments as the value: an array for positional ones, an object for
named ones.
"""

fold "spec/planets.json", title = "spec/planets.json"

nbText: """
The arguments are written as JSON writes them, and read back as tabelline's types: a column
selection is a name, a list of names, or a rule (`{"numeric": true}`, `{"startsWith": "x"}`);
rows are indices or `{"where": ["moons", ">", 50]}`; a text is a string, `{"md": ...}` or
`{"html": ...}`; a location is `"title"` or `{"body": {"columns": ..., "rows": ...}}`; a style
is `{"fill": ...}` or `{"text": {"weight": "bold"}}`; a palette is a name or a list of colours.

From C that is all it takes:

```c
char *html = tbl_render_spec(spec_json, "html");   /* or "page", "text", "markdown" */
if (!html) fprintf(stderr, "%s\n", tbl_error());
tbl_free(html);
```
"""

fold "c/spec.c", title = "c/spec.c: any spec file, rendered"

nbText: """
## Layer 2: a table you build

JSON is fine for verbs, not for data: a million numbers should not be written as text and read
back. So the second layer keeps a table on the library's side, behind a handle (`tbl_table *`),
and the caller fills it with typed arrays: `tbl_add_doubles`, `tbl_add_ints`, `tbl_add_bools`,
`tbl_add_strings` (with `NaN` and `NULL` for missing values), or `tbl_add_json` for lists and
records. Settings (`rownameCol`, `groupnameCol`, `id`, `locale`) come next, then the verbs, one
call each, with their arguments in JSON, and last the rendering.
"""

fold "capi/tabelline.h", start = "typedef struct", stop = "#ifdef __cplusplus",
  title = "capi/tabelline.h, the whole API"

fold "c/planets.c", start = "  tbl_table *t", stop = "  return 0;",
  title = "c/planets.c, the planets in C"

nbText: """
On the Nim side, a handle is a `ref object` kept alive with `GC_ref` and released with
`GC_unref` in `tbl_drop`. The table is made at the first verb, when the columns and the settings
are known.

## Every verb, without writing it twice

The library takes 92 of tabelline's verbs, 99 forms of them counting overloads, each with its
own parameters and defaults. Writing a C function or a JSON reader for each would be a second tabelline to keep in
step with the first. So there is none: a macro reads the signatures.

`verbsFromSignatures(tabHeader, tabSpanner, fmtNumber, ...)` gets, for each overload, its
parameters, their types (`getTypeImpl`) and their defaults (`getImpl`), and writes a branch of
`applyVerb(t, name, args)`: when `args` fits the form (no unknown names, the required ones
given), convert each argument with `conv(json, T)` (or take the default), and call the verb.
A form whose types have no `conv` is left out at compile time (`when compiles`). 93 of the 99
forms are in; the six left out take a Nim proc (`fmt`, a style function), nanoplot options or a
theme object.
"""

fold "capi/verbs_json.nim", start = "macro verbsFromSignatures", stop = "verbsFromSignatures(",
  title = "capi/verbs_json.nim: the macro"

nbText: """
Names are compared the way Nim compares identifiers: case and underscores do not count. So
`fmt_number`, `fmtNumber` and `FmtNumber` are the same verb, and `use_seps` is `useSeps`, and
each language writes them in its own style: Rust and Elixir write `fmt_number`, Java
`fmtNumber`. And `tbl_verbs()` returns the list of forms as JSON, so a binding can check its
names, or be generated.

## Eight languages

Each binding is small, in the language's own style, with no dependencies (the sandbox could not
download packages for most of them, and a proof of concept is clearer without). From the
closest to C to the furthest.
"""

nbCards "the eight languages":
  nbCard "C", "", "1":
    nbText: "The header and `-ltabelline`. Layer 1 and layer 2, as above."
  nbCard "Zig", "", "2":
    nbText: "`extern fn` declarations, written by hand: Zig 0.17 has no `@cImport`. A verb's arguments are any Zig value, written as JSON by `std.json`."
  nbCard "Rust", "", "3":
    nbText: "A crate with no dependencies: `extern \"C\"`, `build.rs` to link, a builder that keeps the first error, and `list!` and `args!` macros."
  nbCard "Julia", "", "4":
    nbText: "`ccall`. One Julia function per verb, made when the module loads, from `tbl_verbs()`: `fmt_number`, for `|>`."
  nbCard "Java", "", "5":
    nbText: "The foreign function and memory API, final in Java 22: no JNI, no C to compile. Lists and maps become JSON."
  nbCard "Erlang", "", "6":
    nbText: "One NIF, `render_spec`, on a dirty scheduler. The table is a map, written as JSON by OTP 27's `json`."
  nbCard "Gleam", "", "7":
    nbText: "A table is a Gleam value, built with `|>`, typed helpers and custom types for locations and styles. The same NIF renders it."
  nbCard "Elixir", "", "8":
    nbText: "Keyword lists and pipes, the same NIF. Keyword lists keep their order, so labels do too."

nbText: """
### C, Zig and Rust: the systems languages

Zig is the closest to C, and it shows: the binding is the C declarations in Zig and four
methods. Its nicest part is the arguments: `t.verb("fmtNumber", .{ .columns = "mass",
.decimals = 2 })` passes an anonymous struct, and `std.json` writes it as an object; a tuple
`.{ "Size", .{ "diameter", "mass" } }` becomes an array. No JSON library to learn, no strings to
escape.
"""

fold "zig/planets.zig", start = "    try t.verb(\"tabHeader\"", stop = "    const html",
  title = "zig/planets.zig"

nbText: """
Rust is the one Pietro asked about: "Can we make a library Rust users will use?" The binding is
a builder: every call returns the table, the first error is kept, and `render` returns a
`Result`. The arguments are a small `Arg` enum (what `serde_json::Value` would be, without the
dependency) built with two macros, `list!` for positional arguments and `args!` for named ones.
A crate on crates.io would need the library built for each platform, or `build.rs` to compile it
with Nim; both are known paths (Python's wheels do the first).
"""

fold "rust/examples/planets.rs", start = "    let t = Table::new()", stop = "    print!",
  title = "rust/examples/planets.rs"

nbText: """
### Julia and Java: two runtimes that call C on their own

Julia calls C with `ccall`, no glue at all. The binding goes one step further: when the module
loads it asks the library for its verbs (`tbl_verbs()`) and defines a Julia function for each,
in Julia's naming (`fmtNumber` becomes `fmt_number`). Called with a table it applies the verb;
called without one it returns a function, so tables read as pipelines.
"""

fold "julia/planets.jl", start = "t = tabella(", stop = "print(render",
  title = "julia/planets.jl"

nbText: """
Java 22 made the foreign function and memory API final: a `MethodHandle` per C function, an
`Arena` for the memory of one call, no JNI and no C to compile. The binding is one class; Kotlin,
Scala and Clojure can use it as it is. One surprise: `System.out` writes in the platform's
encoding, which in a bare container is ASCII, so the example writes bytes.
"""

fold "jvm/src/Planets.java", start = "            t.strings(", stop = "            System.out",
  title = "jvm/src/Planets.java"

nbText: """
### Erlang, Gleam and Elixir: one NIF for the BEAM

The BEAM calls C through NIFs: a C file compiled against `erl_nif.h`, loaded by a module. One
NIF is enough, the first layer: `render_spec(Spec, Format)`, on a dirty CPU scheduler so that a
big table does not block the schedulers that run everything else. On the BEAM a table is
naturally a value (a map, a record), so it is built in the language and only rendered by C.
"""

fold "beam/c_src/tabelline_nif.c", start = "static ERL_NIF_TERM render_spec", stop = "static ERL_NIF_TERM version",
  title = "beam/c_src/tabelline_nif.c"

nbText: """
Gleam is where a display table library could look best: typed, with labelled arguments and
pipes. The binding makes the table an opaque Gleam value, with custom types for the parts that
are not strings: `Text` (`Plain`, `Markdown`, `Html`), `Rows` (`AllRows`, `Indices`, `Where`),
`Location` (`Title`, `ColumnLabels`, `Body`, ...) and `Style` (`Fill`, `Bold`, ...). Nothing runs
until `render`, which writes the spec and calls the NIF. It has no dependencies, not even
`gleam_stdlib`, because the sandbox could not reach Hex; a real package would use `gleam_json`.
"""

fold "gleam/src/planets.gleam", start = "    |> tabelline.rowname", stop = "  print(html)",
  title = "gleam/src/planets.gleam"

nbText: """
Elixir uses the same NIF, with keyword lists for named arguments (they keep their order, so
labels keep theirs) and `|>`; names are Elixir's (`:fmt_number`, `column_labels:`).
"""

fold "elixir/planets.exs", start = "|> Tabelline.set(", stop = "|> Tabelline.render!",
  title = "elixir/planets.exs"

nbText: """
## The check

`nim r tools/polyglot.nim` builds the library, builds and runs every example, and compares what
each prints with what tabelline itself prints. It writes its report as a tabelline table, and
this is it, from 11 November (Linux, Nim 2.2.4, gcc 13.3, Zig 0.17.1, Rust 1.97, Julia 1.13.3,
Java 25, Erlang/OTP 29, Gleam 1.19.1, Elixir 1.20.5).
"""

let results = readCsv(poc / "results.tsv", sep = '\t')
block:
  let t = tabella(results, rownameCol = "port"):
    colsLabel:
      how: "How"
      ms: "Run (ms)"
      result: "Result"
    fmtInteger "ms"
    optCssTheme()
  nbTable t

nbNote """
`results.tsv` is written by `tools/polyglot.nim` when it runs every port; the page only reads it
(`readCsv(sep = '\t')`), so CI does not need eight toolchains.
""", nkCode

nbText: """
Ten programs, one HTML. The times are of the whole program, start included: C, Zig and Rust are
a few milliseconds; the JVM and the BEAM pay their start; Julia compiles as it goes.

## What a real repository would add

The proof is the easy part. To be a library people use in each language, each binding needs
what its ecosystem expects:

- **The library, prebuilt.** A `.so`, a `.dylib` and a `.dll` per platform, built by CI, the way
  Python's wheels carry compiled code (diagrammari's Python package does it with a C ABI and
  ctypes): a crate that downloads it or builds it with Nim in `build.rs`; a Hex package with a
  precompiled NIF; a Julia JLL; a jar with the natives inside; a Zig package.
- **Typed bindings, generated.** `tbl_verbs()` lists every form with its parameters; with their
  types and docs added, each binding's typed functions (`fmt_number(columns:, decimals:)` in
  Gleam) can be generated rather than written, and stay in step with tabelline.
- **What cannot cross yet.** A Nim proc as an argument (a format function, a style by value)
  needs callbacks across the ABI; nanoplot options and themes need their own JSON.
- **A stable ABI.** Versioned names, and a promise about what changes.

The repository it became, the same afternoon,
[tabelline-polyglot](https://github.com/pietroppeter/tabelline-polyglot):

```text
tabelline-polyglot/
  capi/      libtabelline + tabelline.h (layer 1: the spec; layer 2: handles and verbs)
  spec/      the JSON spec: planets.json
  nim/       the reference, in tabelline itself
  c/ zig/ rust/ julia/ jvm/ beam/ gleam/ elixir/   a binding and an example each
  tools/     setup.sh; polyglot.nim: build everything, run every example, compare with Nim
```

And the hope behind it: a binding that works shows gt's grammar in a language that has never had
it. Someone who loves that language will want it written properly, in that language, and a
working table is a good place to start from.

## How it is built

In [tabelline-polyglot](https://github.com/pietroppeter/tabelline-polyglot), with tabelline as a
pinned dependency; this page imports its `capi/` (a dependency of tabelline's docs, in `deps/`).

- `capi/verbs_json.nim`: `conv(json, T)` for every type a verb takes, and the macro
  `verbsFromSignatures`, which writes `applyVerb` and `verbForms` from the verbs' signatures.
- `capi/spec.nim`: `tabellaFromSpec`, the JSON spec to a `Tabella`.
- `capi/tabelline_c.nim`: the exported procs (`tbl_*`), compiled with `nim c --app:lib
  -d:useMalloc` into `libtabelline.so`; `capi/tabelline.h` declares them.
- One folder per language: `c/`, `zig/`, `rust/`, `julia/`, `jvm/`, `beam/` (the NIF and the Erlang
  module), `gleam/`, `elixir/`; and `nim/planets.nim`, the reference.
- `tools/polyglot.nim`: builds, runs, compares, reports (`results.tsv`).
"""

nbSave
