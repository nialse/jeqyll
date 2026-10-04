# Internal JEQY interfaces

All production modules are handwritten LLVM IR. The runtime library ABI is in
the libmuffintop documentation. These are internal JEQY interfaces, with opaque
pointers across modules. No implementation generation or foreign runtime calls.

## Values and collections

`%V = type { i32, i32, double, i64, i64, ptr, ptr }` (48 bytes).
Fields: tag, flags, numeric value, length, capacity, data, numeric literal.
Tags: 0 null, 1 false, 2 true, 3 number, 4 UTF-8 string, 5 array, 6 object.
Strings have byte length and a trailing NUL. Arrays hold value pointers.
Object data holds alternating key and value pointers; length counts pairs.
Values are immutable by convention, except fresh arrays/objects being built.
Streams are arrays, including the empty stream. A null pointer is not JSON null.

Runtime module exports:

```
ptr @j_alloc(i64 bytes)                         ; zeroed, arena allocated
ptr @j_null()                                  ; JSON null
ptr @j_bool(i1 b)
ptr @j_num(double n)
ptr @j_str(ptr bytes, i64 length)               ; copies bytes, adds NUL
ptr @j_cstr(ptr nul_terminated)
i64 @j_strlen(ptr nul_terminated)
i1 @j_is(ptr string_value, ptr nul_terminated)  ; name comparison
ptr @j_array()
void @j_push(ptr array, ptr value)
ptr @j_at(ptr array, i64 index)                 ; negative index, null if OOB
ptr @j_object()
void @j_put(ptr object, ptr key_string, ptr value)
ptr @j_get(ptr value, ptr key)                  ; object/array lookup, error on bad types
ptr @j_clone(ptr value)                        ; shallow clone containers
i32 @j_cmp(ptr left, ptr right)                ; total jq order, deep equality
i1 @j_truth(ptr value)
ptr @j_parse(ptr bytes, i64 length, ptr offset) ; offset is i64*, null pointer on failure
ptr @j_parse_stream(ptr bytes, i64 length, ptr offset) ; tracks stream error path
ptr @j_dump(ptr value, i32 flags)              ; string; 0 compact, 1 pretty, 2 ASCII, 4 sorted
ptr @j_binary(i32 operator, ptr left, ptr right)
void @j_fail(ptr nul_terminated_message)
```

`@j_error = global ptr null` is defined by runtime and holds a JSON error value
when raised. Evaluation propagates it; try/catch clears it. `j_parse` sets it on
parse errors. Binary operators: 0 add, 1 subtract, 2 multiply, 3 divide,
4 remainder, 5 ==, 6 !=, 7 <, 8 <=, 9 >, 10 >=, 11 and, 12 or.

## Parser and evaluator

Evaluator owns all AST and binding layouts and exports:

```
ptr @j_compile(ptr source, i64 length)          ; null pointer on compile error
ptr @j_eval(ptr node, ptr input, ptr env)       ; result stream
ptr @j_bind(ptr env, ptr name, ptr value)       ; name is JSON string
```

Top-level env may be null. Builtin argument lists are `j_array` containers
whose entries are opaque AST node pointers, only passed to `j_eval`.

## Builtins

```
ptr @j_builtin(ptr name, ptr args, ptr input, ptr env)
```

Returns a stream, or null pointer when the name is unknown (evaluator must
report undefined filter). Calls `j_eval` for filter arguments, uses `j_at` to
read them. Zero-argument builtins get an empty args array. Builtins may set
`j_error`. Evaluator implements language syntax, user definitions, variables,
path assignment/update and error/control syntax. Builtin module implements
named library filters including higher-order map/select/sort_by/range etc.

`j_eval_take(node,input,env,count)` and `j_builtin_take(name,args,input,env,count)`
provide bounded consumers for supported generator paths. Ordinary streams
remain materialized arrays. Builtin result helpers suppress placeholder values
when `j_error` is pending, while preserving actual values already yielded by
generators.

## CLI

CLI owns `__poc_program_start(i64 argc, ptr argv)` with return type `void` and
terminates via public `_exit(i32)`. CLI globals accessible to builtins:

```
@j_inputs = global ptr null       ; array of remaining parsed input values
@j_input_pos = global i64 0
@j_environ = global ptr null      ; JSON object from environment
@j_program_args = global ptr null ; JSON $ARGS value
@j_library_paths = global ptr null ; array of module search directories
```

CLI exports `ptr @j_cli_builtin(ptr name, ptr args, ptr input, ptr env)`
for input/inputs/env/debug/stderr/halt/halt_error/input_filename/input_line_number,
and `ptr @j_read_file(ptr path)` returning the complete bytes as a JSON string
or a null pointer with `j_error` set. Paths are NUL-terminated byte pointers.

## Diagnostics and source processing

AST nodes have layout `{i32 kind, i32 op, ptr a, ptr b, ptr c, ptr d, ptr extra,
i64 source_start, i64 source_end}` (64 bytes). Source spans are zero-based byte
offsets. `j_fold_constants(ast)` folds literal arithmetic in the actual AST;
`j_disassemble(ast)` returns its instruction listing as a JSON string.

`j_compile_errors` is an optional array of `[message,start,end,raw]` records.
When absent, the CLI uses `j_error`, `j_compile_error_start`,
`j_compile_error_end` and `j_compile_error_raw`. `j_compile_env` carries the
initial environment into static name validation.

JSON failures expose `j_parse_error_offset` (i64), `j_parse_error_eof` (i1),
`j_parse_error_message` (NUL-terminated bytes), and `j_parse_error_path` (JSON
array). `j_error` retains the full fromjson diagnostic; the CLI formats input
diagnostics from the separate metadata.

`j_seq_parse(input,defer)` parses record-separated input. Deferred input errors
use `j_deferred_input_error` until consumed by `input` or `inputs`.
`j_home_source(program)` prepends a regular HOME/.jq file or adds a HOME/.jq
directory to module search paths. `j_colorize(dumped_json)` adds terminal SGR
sequences according to the environment palette. These interfaces use JSON
strings rather than raw byte pointers unless explicitly stated otherwise.
