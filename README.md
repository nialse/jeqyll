# JEQY

JEQY is an independent implementation of jq written by hand in human-readable
LLVM IR. It builds a standalone command-line JSON processor named `jeqy`.

The implementation includes its own JSON parser and printer, filter compiler,
resumable evaluator, builtin library, module loader, Unicode-aware regular
expression engine, decimal and mathematical routines, time and locale support,
and command-line interface. It does not embed or invoke jq, and it does not
link libc, libjq, libm, a regular-expression library, or another language
runtime.

## Build

The supported build currently targets static Linux x86-64 ELF executables. It
requires `llvm-as`, `llvm-link`, `opt`, `llc`, GNU `ld`, `nm`, `readelf`,
`sha256sum`, and `rg`.

### Ubuntu packages

On Ubuntu 24.04 LTS and 26.04 LTS, install every build dependency with:

```sh
sudo apt update
sudo apt install --yes ca-certificates git llvm binutils coreutils ripgrep
```

The commands used by the build come from these Ubuntu packages:

| Commands or facility | Ubuntu package |
| --- | --- |
| `git` and `git submodule` | `git` |
| HTTPS certificate store used by `git clone` | `ca-certificates` |
| `llvm-as`, `llvm-link`, `opt`, `llc` | `llvm` |
| `ld`, `nm`, `readelf` | `binutils` |
| `basename`, `dirname`, `mkdir`, `cp`, `mv`, `sha256sum` | `coreutils` |
| `rg` | `ripgrep` |

Clone with the runtime submodule and build:

```sh
git clone --recurse-submodules https://github.com/nialse/jeqyll.git
cd jeqyll
./build.sh
```

For an existing checkout:

```sh
git submodule update --init
./build.sh
```

The build assembles and verifies the JEQY modules, links them with the selected
libmuffintop modules, optimizes and verifies the combined bitcode, emits a
static executable, and checks that the result has no undefined symbols, ELF
interpreter, or dynamic dependency.

The executable is written to `./jeqy`. Intermediate bitcode, the linked object,
ELF inspection, and source and binary hashes are written under `build/`. Pass a
different directory as the first argument to `build.sh` to change that location.

## Use

JEQY accepts jq-style filters and JSON from standard input or files:

```sh
printf '%s\n' '{"items":[1,2,3]}' | ./jeqy '.items | map(. * 2)'
./jeqy -n --arg name Ada '{hello: $name}'
```

The command-line interface includes null, raw, slurp, stream, sequence,
compact, sorted-key, ASCII, color, module-path, argument, program-file, and
exit-status modes. Run `./jeqy --help` for the concise option summary.

## Architecture

| Path | Role |
| --- | --- |
| `src/runtime.ll` | Immutable JSON values, parsing, printing, comparison, and allocation |
| `src/syntax.ll`, `src/eval.ll`, `src/iterate.ll` | Filter parsing, compilation, and resumable evaluation |
| `src/builtins.ll`, `src/pathops.ll`, `src/expand.ll` | Builtins, paths, updates, generators, and control filters |
| `src/regex*.ll` | Regular-expression parsing, Unicode data, matching, and replacement |
| `src/math*.ll`, `src/time*.ll` | Software numerical operations, calendars, locales, and time zones |
| `src/cli.ll`, `src/input.ll`, `src/filesystem.ll` | Command-line behavior, streaming input, files, and modules |
| `libmuffintop/` | Git submodule providing the public host and kernel ABI |
| `build.sh` | Assembly, linkage, static executable generation, and binary inspection |

Production behavior lives in the LLVM IR sources. The shell build script only
orchestrates LLVM and native linker tools.

Internal value layouts, iterator state, garbage collection roots, CLI state,
and module-cache contracts are documented in [`ABI.md`](ABI.md). Source and
data provenance is recorded in [`SOURCES.md`](SOURCES.md).

## Compatibility and scope

JEQY targets jq language and command-line compatibility for general programs.
Its implementation is independent; jq source is used only as the behavioral
and data provenance reference identified in `SOURCES.md`.

The top-level build is currently wired for Linux x86-64. Libmuffintop also
contains Linux AArch64 and macOS ARM64 host layers, but JEQY does not yet ship
top-level build recipes for those targets.

This publication repository contains implementation source and required
provenance material.

## License

JEQY is MIT licensed; see [`LICENSE`](LICENSE). The libmuffintop submodule has
its own MIT license. Static data notices and their exact source versions are in
[`NOTICE.md`](NOTICE.md), [`SOURCES.md`](SOURCES.md), and [`licenses/`](licenses/).
