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
Result streams are resumable iterators. Helpers that explicitly collect a
finite stream return arrays. A null pointer is not JSON null.

Runtime module exports:

```
ptr @j_alloc(i64 bytes)                         ; zeroed, arena allocated
ptr @j_alloc_permanent(i64 bytes)               ; nonmoving storage, separate arena
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
double @j_decimal_to_double(ptr literal)        ; validated, NUL-terminated decimal
void @j_fail(ptr nul_terminated_message)
```

`@j_error = global ptr null` is defined by runtime and holds a JSON error value
when raised. Evaluation propagates it; try/catch clears it. `j_parse` sets it on
parse errors. Binary operators: 0 add, 1 subtract, 2 multiply, 3 divide,
4 remainder, 5 ==, 6 !=, 7 <, 8 <=, 9 >, 10 >=, 11 and, 12 or.

## Arena and collection

An arena checkpoint is 24 bytes: block pointer, cursor pointer and remaining
capacity. `j_arena_mark(mark)` records it; `j_arena_rewind(mark)` invalidates
all subsequent allocations. Before rewind, every live post-mark pointer must
be relocated. Static, permanent and pre-mark objects stay in place and their
children are not traversed, so they must not acquire movable child pointers.

```
void @j_gc_begin(ptr mark)
ptr @j_gc_copy(ptr old, i64 bytes, ptr isnew)    ; isnew points to an i1
ptr @j_gc_value(ptr value)                      ; traces JSON graphs iteratively
void @j_gc_end(ptr mark)
void @j_collect_start()                        ; establishes the evaluator base mark
void @j_collect(ptr iterator)                  ; traces typed execution roots
```

`j_gc_copy` installs forwarding before callers enqueue children. Typed tracing
in `collect.ll` handles AST nodes, environments, jobs, continuations, handlers,
call-argument state, child iterators, trackers and module-cache records.
`cli_trace` adds reader state and pending diagnostics. Collection occurs at
outer `j_next` work-queue boundaries after 8 MiB of allocation pressure, not
inside nested helper invocations. Explicit array collection and remaining
eager helper paths can still require unbounded memory.

## Parser and evaluator

Evaluator owns all AST and binding layouts and exports:

```
ptr @j_compile(ptr source, i64 length)          ; null pointer on compile error
ptr @j_iter(ptr node, ptr input, ptr env)       ; allocates an eight-byte iterator
void @j_iter_into(ptr iterator, ptr node, ptr input, ptr env)
ptr @j_next(ptr iterator)                      ; next JSON value, null pointer at end/error
ptr @j_eval(ptr node, ptr input, ptr env)       ; drains a finite iterator into an array
ptr @j_eval_take(ptr node, ptr input, ptr env, i64 count)
ptr @j_bind(ptr env, ptr name, ptr value)       ; name is JSON string
```

Top-level env may be null. The CLI's outer iterator is in stable stack storage.
Returned values must be consumed before the next collection unless retained
through a traced execution root. `j_eval` and `j_eval_take` are collecting
helpers used within evaluator calls, where nested collection is disabled.

AST nodes have layout `{i32 kind, i32 op, ptr a, ptr b, ptr c, ptr d, ptr extra,
i64 source_start, i64 source_end}` (64 bytes). Source spans are zero-based byte
offsets. Ordinary node kinds 0 through 27 and their field types are recorded
in `collect_nodes`. Synthetic kinds 100, 101 and 102 hold repeat/recurse/loop
ASTs; kind 103 holds three JSON values for a numeric range.

Lexical bindings use `{ptr next, ptr name, ptr value_or_body, i32 type,
ptr parameters, ptr capture}` (48 bytes). Types are value 0, definition 1,
filter closure 2 and label 3. Definition captures include their own binding
for recursion. Compile-time reachability metadata is temporary and discarded
after validation; called definitions are checked once per canonical closure.

Iterator jobs, continuations, handlers and partially bound calls are 80, 72,
48 and 64 bytes respectively. Their canonical layouts and dispatch tags are
in `iterate.ll`; `collect_sizes` and `collect_conts` must be updated together
with any layout or pointer-field change.

Builtin argument lists are `j_array` containers whose entries are opaque AST
node pointers, not JSON values. They require typed AST-array tracing.

## Builtins

```
ptr @j_builtin(ptr name, ptr args, ptr input, ptr env)
```

Returns a collected finite stream, or null pointer when the name is unknown (evaluator must
report undefined filter). Calls `j_eval` for filter arguments, uses `j_at` to
read them. Zero-argument builtins get an empty args array. Builtins may set
`j_error`. Evaluator implements language syntax, user definitions, variables,
path assignment/update and error/control syntax. Builtin module implements
named library filters including higher-order map/select/sort_by/range etc.

`iterate.ll` handles generators and controls evaluation of native value
arguments before invoking atom helpers. Higher-order filter arguments remain
ASTs. Call op 0 uses ordinary lexical lookup, -1 marks bound native value
arguments, -2 bypasses user definitions for an intrinsic, and -3 combines
intrinsic lookup with bound arguments. Internal generator expansion uses
private NUL-prefixed identifiers to avoid capturing user names.

`j_eval_atom` supplies remaining eager operations, including path mutation.
Its actual result prefix is scheduled before a pending error or label break.
Builtin result helpers suppress placeholder values when `j_error` is pending.

## CLI

CLI owns `__poc_program_start(i64 argc, ptr argv)` with return type `void` and
terminates via public `_exit(i32)`. CLI globals accessible to builtins:

```
@j_environ = global ptr null      ; JSON object from environment
@j_program_args = global ptr null ; JSON $ARGS value
@j_library_paths = global ptr null ; array of module search directories
```

CLI exports `ptr @j_cli_builtin(ptr name, ptr args, ptr input, ptr env)`
for input/inputs/env/debug/stderr/halt/halt_error/input_filename/input_line_number,
and `ptr @j_read_file(ptr path)` returning the complete bytes as a JSON string
or a null pointer with `j_error` set. Paths are NUL-terminated byte pointers.

```
ptr @j_input_new(ptr files, i32 flags)           ; permanent cursor, no input I/O yet
ptr @j_input_next(ptr reader)                   ; JSON value, raw line or stream event
i32 @j_input_status(ptr reader)                 ; 0 normal/EOF, 2 I/O error, 5 parse error
ptr @j_input_name(ptr reader)                   ; JSON filename string
i64 @j_input_line(ptr reader)
void @j_input_trace(ptr reader)
void @j_input_close(ptr reader)
ptr @cli_take_input()
```

The reader owns a 64 KiB buffer and an iterative container-frame stack. It
shares the CLI flag word, tracks descriptor ownership separately from the
descriptor number, and traces active values, keys, slurp accumulators and
partial raw buffers. `cli_take_input` updates filename/line/status metadata
and moves an input failure into `j_deferred_input_error` until consumed.

## Diagnostics and source processing

`j_fold_constants(ast)` folds literal arithmetic in the actual AST;
`j_disassemble(ast)` returns its instruction listing as a JSON string.

`j_compile_errors` is an optional array of `[message,start,end,raw]` records.
When absent, the CLI uses `j_error`, `j_compile_error_start`,
`j_compile_error_end` and `j_compile_error_raw`. `j_compile_env` carries the
initial environment into static name validation.

JSON failures expose `j_parse_error_offset` (i64), `j_parse_error_eof` (i1),
`j_parse_error_message` (NUL-terminated bytes), and `j_parse_error_path` (JSON
array). `j_error` retains the full fromjson diagnostic; the CLI formats input
diagnostics from the separate metadata.

`j_compile_file_diagnostic(source,length,start,end,message,filename)` formats
a diagnostic using its owning module's filename and source. A null filename
selects the top-level format. `j_home_ast(program)` wraps the program in an
optional HOME module import instead of concatenating source text.
`j_colorize(dumped_json)` adds terminal SGR sequences according to the
environment palette. These interfaces use JSON strings rather than raw byte
pointers unless explicitly stated otherwise.

`j_fs_init(argv0,programfile)` establishes executable/program origins and
search paths. Module cache entries are 32-byte records containing AST,
directory, source bytes and canonical filename pointers. `ev_module_cache`
is an opaque-record array, not a JSON array for `j_gc_value`. Appending a
module clones the cache container to preserve the pre-mark immutability rule.
