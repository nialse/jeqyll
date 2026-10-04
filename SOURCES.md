The default ANSI color palette in src/color.ll follows jq's public output
format. Its eight SGR values are recorded from src/jv_print.c at jq commit
579e6f76cffd7643ba4002a2c3618a5ea710589a, version jq-1.8.2-4-g579e6f7.
The jq source is distributed under the MIT license reproduced in licenses/JQ-MIT.txt.
The token renderer and palette parser are independently handwritten LLVM IR.

The whitespace ranges in src/text.ll match src/jv_unicode.c at the same pinned
jq commit and version. That source has the MIT license in licenses/JQ-MIT.txt.

The base64 alphabet, URI hexadecimal digits, JSON type names and jq builtin
names in src/text.ll, src/builtins.ll, src/math.ll and src/stream.ll are
independently transcribed protocol and language constants. The math
implementation uses arithmetic recurrences and binary64 decomposition, without
imported coefficient tables or compiled mathematical libraries.

Decimal powers and English calendar names are independently written numerical
and calendar constants. Timezone transitions are read from the host TZif files
through the public library ABI; no timezone database is bundled in JEQY.

All implementation modules are handwritten LLVM IR. Upstream jq source is
used as a behavioral reference. No upstream compiled
code, generated implementation IR, interpreter or fallback executable is
part of JEQY.
