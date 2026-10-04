# Known deficiencies

## Validation status

The source revision represented by this repository produced a static Linux
x86-64 executable with SHA-256
`c97f51fe4f27bab08757831ab242ad979fc5f1edcc93016ae2282ed321c56f24`.
That executable passed all 881 cases in the project's pinned compatibility
suite against jq 1.8.2-4-g579e6f7. The suite is not distributed in this
source-only repository.

The passing result is limited to that inventory. The following jq
compatibility and implementation deficiencies remain in the committed source.

## Parser crashes

Some invalid programs reach evaluator paths instead of producing a compile
error. With input `1`, the program `length .` terminates with SIGSEGV. A string
literal ending in an invalid interpolation escape, such as `"a\(b\t"`, also
terminates with SIGSEGV. jq reports compile errors for both programs.

## Raw string crashes

In raw-input mode, `first` and `reverse` can dereference invalid state when the
input is a string. For example, piping the line `[]` to `jeqy -R first` or
`jeqy -R reverse` terminates with SIGSEGV. jq reports a string-indexing runtime
error.

## Reducer and foreach stream state

A multi-valued reducer update is drained incorrectly. This program emits
`1`, `2`, `1`, `2`; jq emits only `2`:

```jq
reduce range(2) as $x (0; (1, 2))
```

The implicit extract form of `foreach` also emits extra values. This program
emits six values instead of four:

```jq
null | foreach range(0; 2) as $x (0; (1, 2))
```

Nested `foreach` updates have the same state-draining defect. Deep composition
can amplify the excess output substantially.

## Object iteration order

Object value iteration can diverge from jq for sufficiently large objects.
Order-sensitive expressions such as `values | add` can therefore combine a
different pair first and report a different runtime error. This is observable
with mixed-type objects around 100 keys and affects any fold that depends on
object value order.

## Format filters

Unsupported `@name` forms are rejected as undefined filters during compilation.
jq parses them as format filters and reports an invalid-format error only if
the expression is evaluated. Consequently, `empty | @base64u` succeeds under
jq but is a compile error in JEQY. The jq 1.8 format filters `@base64u`,
`@csvr`, and `@tsvr` are not implemented.

## Output options

`--tab` is ignored. In particular, `-c --tab` produces compact output, while
jq gives `--tab` precedence and emits tab-indented output.

`--sort-keys` is not applied to `debug` output. For input
`{"b":1,"a":2}`, `debug(.)` writes the keys to stderr as `b`, `a`; jq
writes them as `a`, `b` when `-S` is active. Normal JSON output is sorted.

## Command-line argument consumption

Incomplete `--arg` and `--argjson` sequences consume following arguments
differently from jq. For example, in the sequence
`--arg v --argjson null -f program.jq`, jq treats `null` as an input file,
while JEQY can continue into program evaluation. Well-formed name and value
pairs are unaffected.

## Date parsing

`strptime("%s")` requires a different match shape and overflow behavior from
jq. With `-s -R`, the raw input `18446744073709551616\nnull\n` followed by
`strptime("%s") | mktime` produces a date-format error in JEQY; jq accepts the
epoch prefix and emits `0`.

## Numeric edge behavior

`pow` has incorrect NaN and very small exponent behavior. Representative
results are:

| Expression | JEQY | jq |
| --- | ---: | ---: |
| `pow(-2; 0.5)` | `1.7976931348623157e+308` | `null` |
| `pow(0; 1e-300)` | `1` | `0` |

Several transcendental functions are not correctly rounded for every input.
For example, `[0.2,2] | map(log1p)` differs from jq in the final digits of both
results. No all-input error bound has been established for the transcendental
or special-function implementations.

## Regular expressions

Empty-match advancement on non-ASCII text differs from jq's UTF-8 behavior.
For example, `"中中" | [scan("")] | length` returns `3`; jq returns `7`.
The difference also affects `match`, `sub`, `gsub`, and patterns that admit an
empty match under the `g` or `l` flags. For example,
`gsub("(?<x>a)?"; "\uFFFF"; "l")` on `"\uFFFF"` emits three replacement
characters instead of five.

Regex syntax and recursion boundaries are not fully compatible. JEQY accepts
`^(?:(?(?=x)x|y))+$`, which jq rejects. The recursive pattern
`^(?<r>x\g<r>?)$` also differs at a 21-character input boundary. Callouts,
recursion-level-qualified backreferences, and non-default text segmentation
modes are not implemented. Nested assertion and absent-expression helpers
retain a depth guard, and ambiguous backtracking can require excessive time
and memory.

Error behavior also differs for some patterns and operand types. For example,
`capture("a{")` is accepted by jq but rejected as an invalid pattern by JEQY,
and the non-string operand diagnostic does not match jq.

## Memory scaling

Under a 512 MiB process limit, `sort`, `unique`, `sort_by`, `group_by`,
`min_by`, `max_by`, and `unique_by` can report `jeqy: out of memory` on a
10,000-element array that jq processes successfully. Their current
implementations allocate far more memory than the input size.

`gsub("[a-z]+"; "z"; "l")` can exhaust the same limit on a roughly
4,000-character input made from repeated `a ba`, while jq completes. Ordinary
regex matching succeeds through roughly two million repeated characters under
that limit but reports out of memory at roughly four million.

Path capture, parts of path mutation, and some higher-order builtin internals
collect filter results eagerly. These paths do not guarantee bounded memory
for finite consumers of arbitrary infinite streams. Garbage collection is
also disabled inside nested eager helper calls. Some long-running compositions
therefore cannot reclaim memory at evaluator safe points.

## Diagnostics

Some errors have different text, source locations, or selection order. Known
examples include multiple `not/1` compile errors selecting a different
occurrence, an empty program reporting a different message, `strptime` date
text truncation, first-value line attribution, and EOF parse-error columns.
These cases generally agree on success or failure but are not byte-compatible
with jq diagnostics.

## Locale, disassembly, and targets

Locale loading supports glibc's serialized Linux formats. Alias resolution
beyond exact names and normalized codesets is incomplete, as is conversion
from legacy non-UTF-8 codesets.

Disassembly describes JEQY's AST and reachable lexical functions. It does not
reproduce jq VM bytecode or every detail of jq's disassembler output.

Linux x86-64 is the only natively built and validated JEQY target. The
libmuffintop submodule contains Linux AArch64 and macOS ARM64 host layers, but
JEQY does not yet provide top-level builds or compatibility validation for
those targets.
