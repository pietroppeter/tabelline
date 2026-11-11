# tabelline in other languages: proofs of concept

tabelline is written in Nim, and Nim compiles to C. So tabelline can be a C library, and every
language that calls C can draw a tabelline table. This folder checks that, end to end, for C,
Zig, Rust, Julia, the JVM, Erlang, Gleam and Elixir. Each port draws the same table (the
planets), and `tools/polyglot.nim` checks that every one prints the same HTML as tabelline
itself, byte for byte.

It is here until it gets a repository of its own (`tabelline-polyglot`, proposed). The devlog
posts *Great tables in every language* and *tabelline in eight languages* tell the why and the
how.

## The C ABI, in two layers

`capi/tabelline_c.nim` is compiled with `nim c --app:lib` into `libtabelline.so`; `capi/tabelline.h`
declares it.

1. **One call.** `tbl_render_spec(spec, format)`: the whole table as JSON (the data, the stub, the
   verbs) in, the table rendered out. `spec/planets.json` is the planets table.
2. **A table you build.** `tbl_new()`, typed columns (`tbl_add_doubles`, `tbl_add_ints`,
   `tbl_add_strings`, ...), settings (`tbl_set(t, "rownameCol", "planet")`), one verb at a time
   (`tbl_verb(t, "fmtNumber", "{\"columns\": \"mass\", \"decimals\": 2}")`), `tbl_render(t, "html")`,
   `tbl_drop(t)`.

Every verb is there without being written twice: `capi/verbs_json.nim` reads tabelline's verbs'
signatures with a macro and writes, for each overload, the code that converts JSON arguments to
its parameters (93 of the 99 overloads; the rest take a Nim proc). Names ignore case and
underscores, so `fmt_number` is `fmtNumber`. `tbl_verbs()` lists them, as JSON.

## The ports

| folder | how it calls the library |
|---|---|
| `nim/` | the reference: the table in tabelline itself |
| `c/` | `planets.c` (layer 2) and `spec.c` (layer 1, any spec file) |
| `zig/` | `extern fn` declarations (Zig 0.17 has no `@cImport`); arguments are any Zig value, written by `std.json` |
| `rust/` | a crate with no dependencies: `extern "C"`, a builder, and `list!` / `args!` macros for arguments |
| `julia/` | `ccall`; one Julia function per verb (`fmt_number`), made when the module loads from `tbl_verbs()` |
| `jvm/` | Java's foreign function and memory API (Java 22+), no JNI |
| `beam/` | one NIF (`render_spec`, on a dirty scheduler) and an Erlang module writing the spec with OTP 27's `json` |
| `gleam/` | a table as a Gleam value, built with `\|>` and typed helpers; the same NIF at `render` |
| `elixir/` | keyword lists and pipes; the same NIF |

## Run it

```sh
nim r tools/polyglot.nim          # every port it finds a toolchain for
nim r tools/polyglot.nim zig rust # some of them
```

Toolchains come from the `PATH` or from `ZIG`, `JULIA`, `JAVA_HOME`, `ERL_BIN` (Erlang/OTP 27 or
later), `GLEAM`, `ELIXIR_BIN`. Checked on 11 Nov 2026 with Nim 2.2.4, gcc 13.3, Zig 0.17.1,
Rust 1.97, Julia 1.13.3, Java 25, Erlang/OTP 29, Gleam 1.19.1 and Elixir 1.20.5 (`results.tsv`).

## The repository it could become

```text
tabelline-polyglot/
  capi/      libtabelline + tabelline.h (layer 1: the spec; layer 2: handles and verbs)
  spec/      the JSON spec, documented, and planets.json
  c/ zig/ rust/ julia/ jvm/ beam/ gleam/ elixir/   a binding and an example each
  tools/     polyglot.nim: build everything, run every example, compare with Nim
```
