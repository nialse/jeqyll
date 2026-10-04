%V = type { i32, i32, double, i64, i64, ptr, ptr }

@j_inputs = global ptr null
@j_input_pos = global i64 0
@j_environ = global ptr null
@j_program_args = global ptr null
@j_deferred_input_error = global ptr null
@j_library_paths = global ptr null
@j_error = external global ptr
@j_indent = external global i32
@j_compile_error_start = external global i64
@j_compile_error_end = external global i64
@j_compile_env = external global ptr
@j_compile_errors = external global ptr
@j_compile_error_raw = external global i1
@j_parse_error_offset = external global i64
@j_parse_error_message = external global ptr
@j_parse_error_path = external global ptr
@cli_flags = internal global i32 0
@cli_filename = internal global ptr null
@cli_line = internal global i64 0
@cli_names = internal global ptr null
@cli_lines = internal global ptr null
@cli_source_lines = internal global ptr null
@cli_source_position = internal global i64 0
@cli_source_line = internal global i64 1
@cli_halted = internal global i1 false
@cli_halt_code = internal global i32 0
@cli_exit_code = internal global i32 0
@cli_last = internal global i32 4
@cli_stdin_seen = internal global i1 false
@cli_write_failed = internal global i1 false

@c_dot = private constant [2 x i8] c".\00"
@c_dash = private constant [2 x i8] c"-\00"
@c_nl = private constant [2 x i8] c"\0A\00"
@c_zero = private constant [1 x i8] zeroinitializer
@c_rs = private constant [1 x i8] c"\1E"
@c_stdin = private constant [8 x i8] c"<stdin>\00"
@c_args_name = private constant [5 x i8] c"ARGS\00"
@c_ENV_name = private constant [4 x i8] c"ENV\00"
@c_named = private constant [6 x i8] c"named\00"
@c_positional = private constant [11 x i8] c"positional\00"
@c_version = private constant [10 x i8] c"jeqy-0.1\0A\00"
@c_help = private constant [157 x i8] c"Usage: jeqy [options] FILTER [FILE...]\0A  -n null input  -R raw input  -s slurp  -c compact\0A  -r raw output  -j join output  -e exit status  -f program file\0A\00"
@c_io_error = private constant [16 x i8] c"Input I/O error\00"
@c_write_error = private constant [17 x i8] c"Output I/O error\00"
@c_option_error = private constant [38 x i8] c"Unknown or unsupported command option\00"
@c_missing_arg = private constant [24 x i8] c"Missing option argument\00"
@c_raw_zero = private constant [62 x i8] c"Cannot dump a string containing NUL with --raw-output0 option\00"
@c_jq_error = private constant [12 x i8] c"jq: error: \00"
@c_compile_end = private constant [21 x i8] c"jq: 1 compile error\0A\00"
@c_compile_prefix = private constant [5 x i8] c"jq: \00"
@c_compile_suffix = private constant [15 x i8] c" compile error\00"
@c_plural = private constant [2 x i8] c"s\00"
@c_input_error = private constant [18 x i8] c"jq: parse error: \00"
@c_runtime_error = private constant [14 x i8] c"jq: error: \00\00\00"
@c_runtime_at = private constant [15 x i8] c"jq: error (at \00"
@c_colon = private constant [2 x i8] c":\00"
@c_runtime_close = private constant [4 x i8] c"): \00"
@c_arg = private constant [6 x i8] c"--arg\00"
@c_argjson = private constant [10 x i8] c"--argjson\00"
@c_slurpfile = private constant [12 x i8] c"--slurpfile\00"
@c_rawfile = private constant [10 x i8] c"--rawfile\00"
@c_args = private constant [7 x i8] c"--args\00"
@c_jsonargs = private constant [11 x i8] c"--jsonargs\00"
@c_endopts = private constant [3 x i8] c"--\00"
@c_indent = private constant [9 x i8] c"--indent\00"
@c_tab = private constant [6 x i8] c"--tab\00"
@c_null_input = private constant [13 x i8] c"--null-input\00"
@c_raw_input = private constant [12 x i8] c"--raw-input\00"
@c_slurp = private constant [8 x i8] c"--slurp\00"
@c_compact = private constant [17 x i8] c"--compact-output\00"
@c_raw_output = private constant [13 x i8] c"--raw-output\00"
@c_raw_output0 = private constant [14 x i8] c"--raw-output0\00"
@c_join_output = private constant [14 x i8] c"--join-output\00"
@c_ascii = private constant [15 x i8] c"--ascii-output\00"
@c_sort = private constant [12 x i8] c"--sort-keys\00"
@c_exit = private constant [14 x i8] c"--exit-status\00"
@c_from_file = private constant [12 x i8] c"--from-file\00"
@c_library = private constant [15 x i8] c"--library-path\00"
@c_unbuffered = private constant [13 x i8] c"--unbuffered\00"
@c_seq = private constant [6 x i8] c"--seq\00"
@c_stream = private constant [9 x i8] c"--stream\00"
@c_stream_errors = private constant [16 x i8] c"--stream-errors\00"
@c_version_opt = private constant [10 x i8] c"--version\00"
@c_help_opt = private constant [7 x i8] c"--help\00"
@c_mono = private constant [20 x i8] c"--monochrome-output\00"
@c_color = private constant [15 x i8] c"--color-output\00"
@c_NO_COLOR = private constant [9 x i8] c"NO_COLOR\00"
@c_disasm = private constant [20 x i8] c"--debug-dump-disasm\00"
@c_env = private constant [4 x i8] c"env\00"
@c_input = private constant [6 x i8] c"input\00"
@c_inputs = private constant [7 x i8] c"inputs\00"
@c_debug = private constant [6 x i8] c"debug\00"
@c_stderr = private constant [7 x i8] c"stderr\00"
@c_halt = private constant [5 x i8] c"halt\00"
@c_halt_error = private constant [11 x i8] c"halt_error\00"
@c_filename = private constant [15 x i8] c"input_filename\00"
@c_line = private constant [18 x i8] c"input_line_number\00"
@c_eof = private constant [6 x i8] c"break\00"
@c_DEBUG = private constant [7 x i8] c"DEBUG:\00"
@cli_builtin_names = private constant [80 x i8] c"env\00input\00inputs\00debug\00stderr\00halt\00halt_error\00input_filename\00input_line_number\00\00"

declare ptr @j_alloc(i64)
declare ptr @j_null()
declare ptr @j_bool(i1)
declare ptr @j_num(double)
declare ptr @j_str(ptr, i64)
declare ptr @j_cstr(ptr)
declare i64 @j_strlen(ptr)
declare i1 @j_is(ptr, ptr)
declare ptr @j_array()
declare void @j_push(ptr, ptr)
declare ptr @j_at(ptr, i64)
declare ptr @j_object()
declare void @j_put(ptr, ptr, ptr)
declare ptr @j_get(ptr, ptr)
declare ptr @j_clone(ptr)
declare i1 @j_truth(ptr)
declare ptr @j_parse(ptr, i64, ptr)
declare ptr @j_parse_stream(ptr, i64, ptr)
declare ptr @j_dump(ptr, i32)
declare void @j_fail(ptr)
declare ptr @j_compile(ptr, i64)
declare ptr @j_compile_diagnostic(ptr, i64, i64, i64, ptr)
declare ptr @j_input_diagnostic(ptr, i64, i64, ptr)
declare ptr @j_colorize(ptr)
declare void @j_color_init()
declare ptr @j_home_source(ptr)
declare ptr @j_disassemble(ptr)
declare ptr @j_fold_constants(ptr)
declare ptr @j_seq_parse(ptr, i1)
declare ptr @j_buffer_new()
declare void @j_buffer_append(ptr, ptr, i64)
declare void @j_buffer_byte(ptr, i8)
declare ptr @j_buffer_value(ptr)
declare ptr @j_eval(ptr, ptr, ptr)
declare ptr @j_bind(ptr, ptr, ptr)
declare ptr @j_binary(i32, ptr, ptr)
declare i32 @b_find(ptr, ptr)
declare void @_exit(i32) noreturn
declare i64 @read(i32, ptr, i64)
declare i64 @write(i32, ptr, i64)
declare i32 @open(ptr, i32, i32)
declare i32 @close(i32)
declare i32 @isatty(i32)
declare void @llvm.memcpy.p0.p0.i64(ptr, ptr, i64, i1)

define internal i64 @cli_len(ptr %v) {
  %p = getelementptr %V, ptr %v, i32 0, i32 3
  %n = load i64, ptr %p
  ret i64 %n
}

define ptr @j_cli_names() {
  ret ptr @cli_builtin_names
}

define i1 @j_cli_known(ptr %name, i64 %arity) {
  %id = call i32 @b_find(ptr %name, ptr @cli_builtin_names)
  %known = icmp sge i32 %id, 0
  %debug = icmp eq i32 %id, 3
  %halterror = icmp eq i32 %id, 6
  %optional = or i1 %debug, %halterror
  %max = zext i1 %optional to i64
  %bounds = icmp ule i64 %arity, %max
  %valid = and i1 %known, %bounds
  ret i1 %valid
}

define internal ptr @cli_data(ptr %v) {
  %p = getelementptr %V, ptr %v, i32 0, i32 5
  %s = load ptr, ptr %p
  ret ptr %s
}

define internal void @cli_write(i32 %fd, ptr %p, i64 %n) {
entry:
  br label %loop
loop:
  %pos = phi i64 [ 0, %entry ], [ %next, %advance ]
  %done = icmp uge i64 %pos, %n
  br i1 %done, label %end, label %body
body:
  %at = getelementptr i8, ptr %p, i64 %pos
  %left = sub i64 %n, %pos
  %w = call i64 @write(i32 %fd, ptr %at, i64 %left)
  %ok = icmp sgt i64 %w, 0
  br i1 %ok, label %advance, label %bad
advance:
  %next = add i64 %pos, %w
  br label %loop
bad:
  store i32 2, ptr @cli_exit_code
  %stdout = icmp eq i32 %fd, 1
  store i1 %stdout, ptr @cli_write_failed
  br label %end
end:
  ret void
}

define internal void @cli_text(i32 %fd, ptr %s) {
  %n = call i64 @j_strlen(ptr %s)
  call void @cli_write(i32 %fd, ptr %s, i64 %n)
  ret void
}

define void @cli_string(i32 %fd, ptr %v) {
  %n = call i64 @cli_len(ptr %v)
  %p = call ptr @cli_data(ptr %v)
  call void @cli_write(i32 %fd, ptr %p, i64 %n)
  ret void
}

define internal void @cli_error(i32 %status, ptr %prefix) {
entry:
  %err = load ptr, ptr @j_error
  %has = icmp ne ptr %err, null
  br i1 %has, label %print, label %end
print:
  call void @cli_text(i32 2, ptr %prefix)
  %tag = load i32, ptr %err
  %str = icmp eq i32 %tag, 4
  br i1 %str, label %raw, label %json
raw:
  call void @cli_string(i32 2, ptr %err)
  br label %newline
json:
  %dump = call ptr @j_dump(ptr %err, i32 0)
  call void @cli_string(i32 2, ptr %dump)
  br label %newline
newline:
  call void @cli_write(i32 2, ptr @c_nl, i64 1)
  store ptr null, ptr @j_error
  br label %end
end:
  store i32 %status, ptr @cli_exit_code
  ret void
}

define internal void @cli_runtime_error() {
entry:
  %error = load ptr, ptr @j_error
  %haserror = icmp ne ptr %error, null
  br i1 %haserror, label %begin, label %done
begin:
  call void @cli_text(i32 2, ptr @c_runtime_at)
  %filename = load ptr, ptr @cli_filename
  %hasname = icmp ne ptr %filename, null
  br i1 %hasname, label %nametype, label %stdin
nametype:
  %ft = load i32, ptr %filename
  %string = icmp eq i32 %ft, 4
  br i1 %string, label %named, label %stdin
named:
  call void @cli_string(i32 2, ptr %filename)
  br label %line
stdin:
  call void @cli_text(i32 2, ptr @c_stdin)
  br label %line
line:
  call void @cli_text(i32 2, ptr @c_colon)
  %lineno = load i64, ptr @cli_line
  %positive = icmp sgt i64 %lineno, 0
  %number = select i1 %positive, i64 %lineno, i64 1
  %d = uitofp i64 %number to double
  %v = call ptr @j_num(double %d)
  %s = call ptr @j_dump(ptr %v, i32 0)
  call void @cli_string(i32 2, ptr %s)
  call void @cli_text(i32 2, ptr @c_runtime_close)
  %tag = load i32, ptr %error
  %str = icmp eq i32 %tag, 4
  br i1 %str, label %raw, label %json
raw:
  call void @cli_string(i32 2, ptr %error)
  br label %newline
json:
  %dump = call ptr @j_dump(ptr %error, i32 0)
  call void @cli_string(i32 2, ptr %dump)
  br label %newline
newline:
  call void @cli_write(i32 2, ptr @c_nl, i64 1)
  store ptr null, ptr @j_error
  br label %done
done:
  store i32 5, ptr @cli_exit_code
  ret void
}

define internal void @cli_compile_errors(ptr %source, i64 %length, ptr %message) {
entry:
  %errors = load ptr, ptr @j_compile_errors
  %has = icmp ne ptr %errors, null
  br i1 %has, label %count, label %single
count:
  %n = call i64 @cli_len(ptr %errors)
  %nonempty = icmp ne i64 %n, 0
  br i1 %nonempty, label %loop, label %single
single:
  %raw = load i1, ptr @j_compile_error_raw
  br i1 %raw, label %singleraw, label %singleformat
singleraw:
  store ptr %message, ptr @j_error
  br label %singleprint
singleformat:
  %start = load i64, ptr @j_compile_error_start
  %end = load i64, ptr @j_compile_error_end
  %formatted = call ptr @j_compile_diagnostic(ptr %source, i64 %length, i64 %start, i64 %end, ptr %message)
  store ptr %formatted, ptr @j_error
  br label %singleprint
singleprint:
  call void @cli_error(i32 3, ptr @c_jq_error)
  call void @cli_text(i32 2, ptr @c_compile_end)
  ret void
loop:
  %i = phi i64 [ 0, %count ], [ %next, %print ]
  %done = icmp uge i64 %i, %n
  br i1 %done, label %summary, label %record
record:
  %row = call ptr @j_at(ptr %errors, i64 %i)
  %msg = call ptr @j_at(ptr %row, i64 0)
  %sv = call ptr @j_at(ptr %row, i64 1)
  %ev = call ptr @j_at(ptr %row, i64 2)
  %rv = call ptr @j_at(ptr %row, i64 3)
  %rowraw = call i1 @j_truth(ptr %rv)
  br i1 %rowraw, label %rawrecord, label %formatrecord
rawrecord:
  store ptr %msg, ptr @j_error
  br label %print
formatrecord:
  %sp = getelementptr %V, ptr %sv, i32 0, i32 2
  %ep = getelementptr %V, ptr %ev, i32 0, i32 2
  %sd = load double, ptr %sp
  %ed = load double, ptr %ep
  %s = fptosi double %sd to i64
  %e = fptosi double %ed to i64
  %diag = call ptr @j_compile_diagnostic(ptr %source, i64 %length, i64 %s, i64 %e, ptr %msg)
  store ptr %diag, ptr @j_error
  br label %print
print:
  call void @cli_error(i32 3, ptr @c_jq_error)
  %next = add i64 %i, 1
  br label %loop
summary:
  call void @cli_text(i32 2, ptr @c_compile_prefix)
  %countd = uitofp i64 %n to double
  %countv = call ptr @j_num(double %countd)
  %counts = call ptr @j_dump(ptr %countv, i32 0)
  call void @cli_string(i32 2, ptr %counts)
  call void @cli_text(i32 2, ptr @c_compile_suffix)
  %plural = icmp ne i64 %n, 1
  br i1 %plural, label %pluralsuffix, label %newline
pluralsuffix:
  call void @cli_text(i32 2, ptr @c_plural)
  br label %newline
newline:
  call void @cli_text(i32 2, ptr @c_nl)
  ret void
}

define internal ptr @cli_read_fd(i32 %fd) {
entry:
  %buf = call ptr @j_alloc(i64 65536)
  br label %loop
loop:
  %base = phi ptr [ %buf, %entry ], [ %newbase, %grow ], [ %base, %advance ]
  %cap = phi i64 [ 65536, %entry ], [ %newcap, %grow ], [ %cap, %advance ]
  %used = phi i64 [ 0, %entry ], [ %used, %grow ], [ %next, %advance ]
  %full = icmp eq i64 %used, %cap
  br i1 %full, label %grow, label %read
grow:
  %newcap = mul i64 %cap, 2
  %newbase = call ptr @j_alloc(i64 %newcap)
  call void @llvm.memcpy.p0.p0.i64(ptr %newbase, ptr %base, i64 %used, i1 false)
  br label %loop
read:
  %dest = getelementptr i8, ptr %base, i64 %used
  %remaining = sub i64 %cap, %used
  %count = call i64 @read(i32 %fd, ptr %dest, i64 %remaining)
  %bad = icmp slt i64 %count, 0
  br i1 %bad, label %error, label %eofcheck
eofcheck:
  %eof = icmp eq i64 %count, 0
  br i1 %eof, label %finish, label %advance
advance:
  %next = add i64 %used, %count
  br label %loop
finish:
  %str = call ptr @j_str(ptr %base, i64 %used)
  ret ptr %str
error:
  call void @j_fail(ptr @c_io_error)
  ret ptr null
}

define ptr @j_read_file(ptr %path) {
entry:
  %fd = call i32 @open(ptr %path, i32 0, i32 0)
  %bad = icmp slt i32 %fd, 0
  br i1 %bad, label %error, label %read
read:
  %str = call ptr @cli_read_fd(i32 %fd)
  %closed = call i32 @close(i32 %fd)
  %closebad = icmp slt i32 %closed, 0
  br i1 %closebad, label %error, label %finish
finish:
  ret ptr %str
error:
  call void @j_fail(ptr @c_io_error)
  ret ptr null
}

define internal void @cli_add_input(ptr %out, ptr %v, ptr %name, i64 %line) {
  call void @j_push(ptr %out, ptr %v)
  %names = load ptr, ptr @cli_names
  call void @j_push(ptr %names, ptr %name)
  %lines = load ptr, ptr @cli_lines
  %d = uitofp i64 %line to double
  %num = call ptr @j_num(double %d)
  call void @j_push(ptr %lines, ptr %num)
  ret void
}

define internal void @cli_record_line(i64 %line) {
  %lines = load ptr, ptr @cli_source_lines
  %d = uitofp i64 %line to double
  %value = call ptr @j_num(double %d)
  call void @j_push(ptr %lines, ptr %value)
  ret void
}

define void @cli_record_position(ptr %source, i64 %position) {
entry:
  %previous = load i64, ptr @cli_source_position
  %previousline = load i64, ptr @cli_source_line
  br label %scan
scan:
  %i = phi i64 [ %previous, %entry ], [ %next, %byte ]
  %line = phi i64 [ %previousline, %entry ], [ %nextline, %byte ]
  %done = icmp uge i64 %i, %position
  br i1 %done, label %finish, label %byte
byte:
  %p = getelementptr i8, ptr %source, i64 %i
  %c = load i8, ptr %p
  %lf = icmp eq i8 %c, 10
  %inc = zext i1 %lf to i64
  %nextline = add i64 %line, %inc
  %next = add i64 %i, 1
  br label %scan
finish:
  store i64 %position, ptr @cli_source_position
  store i64 %line, ptr @cli_source_line
  call void @cli_record_line(i64 %line)
  ret void
}

define internal ptr @cli_parse_all(ptr %str, i1 %raw, i1 %rawslurp, ptr %name, i1 %track) {
entry:
  %out = call ptr @j_array()
  %sourcelines = call ptr @j_array()
  store ptr %sourcelines, ptr @cli_source_lines
  store i64 0, ptr @cli_source_position
  store i64 1, ptr @cli_source_line
  %n = call i64 @cli_len(ptr %str)
  %data = call ptr @cli_data(ptr %str)
  %off = alloca i64
  store i64 0, ptr %off
  br i1 %rawslurp, label %whole, label %select
whole:
  call void @j_push(ptr %out, ptr %str)
  call void @cli_record_position(ptr %data, i64 %n)
  ret ptr %out
select:
  %f = load i32, ptr @cli_flags
  %seqbit = and i32 %f, 512
  %seqflag = icmp ne i32 %seqbit, 0
  %notraw = xor i1 %raw, true
  %doseq0 = and i1 %seqflag, %notraw
  %doseq = and i1 %doseq0, %track
  br i1 %doseq, label %sequence, label %inputselect
sequence:
  %nullbit = and i32 %f, 2
  %defer = icmp ne i32 %nullbit, 0
  %seqvalues = call ptr @j_seq_parse(ptr %str, i1 %defer)
  ret ptr %seqvalues
inputselect:
  br i1 %raw, label %rawloop, label %jsonloop
rawloop:
  %i = phi i64 [ 0, %inputselect ], [ %inext, %rawnext ], [ %inext, %lineend ]
  %start = phi i64 [ 0, %inputselect ], [ %start, %rawnext ], [ %inext, %lineend ]
  %line = phi i64 [ 1, %inputselect ], [ %line, %rawnext ], [ %linenext, %lineend ]
  %rend = icmp uge i64 %i, %n
  br i1 %rend, label %rawend, label %rawchar
rawchar:
  %cp = getelementptr i8, ptr %data, i64 %i
  %ch = load i8, ptr %cp
  %newline = icmp eq i8 %ch, 10
  %inext = add i64 %i, 1
  br i1 %newline, label %lineend, label %rawnext
rawnext:
  br label %rawloop
lineend:
  %lp = getelementptr i8, ptr %data, i64 %start
  %llen = sub i64 %i, %start
  %lv = call ptr @j_str(ptr %lp, i64 %llen)
  call void @j_push(ptr %out, ptr %lv)
  call void @cli_record_line(i64 %line)
  %linenext = add i64 %line, 1
  br label %rawloop
rawend:
  %tail = icmp ult i64 %start, %n
  br i1 %tail, label %rawtail, label %done
rawtail:
  %tp = getelementptr i8, ptr %data, i64 %start
  %tlen = sub i64 %n, %start
  %tv = call ptr @j_str(ptr %tp, i64 %tlen)
  call void @j_push(ptr %out, ptr %tv)
  call void @cli_record_line(i64 %line)
  br label %done
jsonloop:
  %position = load i64, ptr %off
  %end = icmp uge i64 %position, %n
  br i1 %end, label %done, label %skip
skip:
  %p = getelementptr i8, ptr %data, i64 %position
  %c = load i8, ptr %p
  %space = icmp eq i8 %c, 32
  %tab = icmp eq i8 %c, 9
  %lf = icmp eq i8 %c, 10
  %cr = icmp eq i8 %c, 13
  %s0 = or i1 %space, %tab
  %s1 = or i1 %lf, %cr
  %whitespace = or i1 %s0, %s1
  br i1 %whitespace, label %skipnext, label %parse
skipnext:
  %nextpos = add i64 %position, 1
  store i64 %nextpos, ptr %off
  br label %jsonloop
parse:
  %streambit = and i32 %f, 1024
  %streamflag = icmp ne i32 %streambit, 0
  %streamparse = and i1 %streamflag, %track
  br i1 %streamparse, label %parsestream, label %parsejson
parsestream:
  %sv = call ptr @j_parse_stream(ptr %data, i64 %n, ptr %off)
  br label %parsed
parsejson:
  %jv = call ptr @j_parse(ptr %data, i64 %n, ptr %off)
  br label %parsed
parsed:
  %v = phi ptr [ %sv, %parsestream ], [ %jv, %parsejson ]
  %valid = icmp ne ptr %v, null
  br i1 %valid, label %append, label %parseerror
parseerror:
  br i1 %track, label %inputerror, label %done
inputerror:
  %errorpos = load i64, ptr @j_parse_error_offset
  %errormsg = load ptr, ptr @j_parse_error_message
  %inputmsg = call ptr @j_input_diagnostic(ptr %data, i64 %n, i64 %errorpos, ptr %errormsg)
  store ptr %inputmsg, ptr @j_error
  br label %done
append:
  call void @j_push(ptr %out, ptr %v)
  %after = load i64, ptr %off
  call void @cli_record_position(ptr %data, i64 %after)
  %advanced = icmp ugt i64 %after, %position
  br i1 %advanced, label %jsonloop, label %done
done:
  ret ptr %out
}

define internal ptr @cli_env(i64 %argc, ptr %argv) {
entry:
  %obj = call ptr @j_object()
  %start = add i64 %argc, 1
  br label %loop
loop:
  %index = phi i64 [ %start, %entry ], [ %next, %advance ]
  %slot = getelementptr ptr, ptr %argv, i64 %index
  %s = load ptr, ptr %slot
  %end = icmp eq ptr %s, null
  br i1 %end, label %done, label %scan
scan:
  %pos = phi i64 [ 0, %loop ], [ %posnext, %scannext ]
  %p = getelementptr i8, ptr %s, i64 %pos
  %c = load i8, ptr %p
  %eq = icmp eq i8 %c, 61
  br i1 %eq, label %insert, label %scannext
scannext:
  %nul = icmp eq i8 %c, 0
  %posnext = add i64 %pos, 1
  br i1 %nul, label %advance, label %scan
insert:
  %key = call ptr @j_str(ptr %s, i64 %pos)
  %vp = getelementptr i8, ptr %p, i64 1
  %value = call ptr @j_cstr(ptr %vp)
  call void @j_put(ptr %obj, ptr %key, ptr %value)
  br label %advance
advance:
  %next = add i64 %index, 1
  br label %loop
done:
  ret ptr %obj
}

define internal void @cli_emit(ptr %v) {
entry:
  %flags = load i32, ptr @cli_flags
  %rawbit = and i32 %flags, 16
  %raw = icmp ne i32 %rawbit, 0
  %tag = load i32, ptr %v
  %str = icmp eq i32 %tag, 4
  %rawstr = and i1 %raw, %str
  %seqbit = and i32 %flags, 512
  %seq = icmp ne i32 %seqbit, 0
  br i1 %seq, label %recordsep, label %dispatch
recordsep:
  call void @cli_write(i32 1, ptr @c_rs, i64 1)
  br label %dispatch
dispatch:
  br i1 %rawstr, label %rawcheck, label %json
rawcheck:
  %zbit = and i32 %flags, 2048
  %z = icmp ne i32 %zbit, 0
  br i1 %z, label %scanstart, label %rawout
scanstart:
  %s = call ptr @cli_data(ptr %v)
  %n = call i64 @cli_len(ptr %v)
  br label %scan
scan:
  %i = phi i64 [ 0, %scanstart ], [ %next, %scannext ]
  %done = icmp uge i64 %i, %n
  br i1 %done, label %rawout, label %scanbyte
scanbyte:
  %p = getelementptr i8, ptr %s, i64 %i
  %c = load i8, ptr %p
  %nul = icmp eq i8 %c, 0
  br i1 %nul, label %zeroerror, label %scannext
scannext:
  %next = add i64 %i, 1
  br label %scan
zeroerror:
  call void @j_fail(ptr @c_raw_zero)
  call void @cli_runtime_error()
  store i1 true, ptr @cli_write_failed
  ret void
rawout:
  call void @cli_string(i32 1, ptr %v)
  br label %suffix
json:
  %compact = and i32 %flags, 8
  %pretty = icmp eq i32 %compact, 0
  %pflag = zext i1 %pretty to i32
  %ab = and i32 %flags, 128
  %ab2 = lshr i32 %ab, 6
  %sb = and i32 %flags, 256
  %sb2 = lshr i32 %sb, 6
  %ff = or i32 %pflag, %ab2
  %df = or i32 %ff, %sb2
  %dump = call ptr @j_dump(ptr %v, i32 %df)
  %colorbit = and i32 %flags, 4096
  %colored = icmp ne i32 %colorbit, 0
  br i1 %colored, label %colorjson, label %writejson
colorjson:
  %colorvalue = call ptr @j_colorize(ptr %dump)
  br label %writejson
writejson:
  %rendered = phi ptr [ %dump, %json ], [ %colorvalue, %colorjson ]
  call void @cli_string(i32 1, ptr %rendered)
  br label %suffix
suffix:
  %joinbit = and i32 %flags, 32
  %join = icmp ne i32 %joinbit, 0
  br i1 %join, label %finish, label %newline
newline:
  %zb = and i32 %flags, 2048
  %iszero = icmp ne i32 %zb, 0
  %sep = select i1 %iszero, ptr @c_zero, ptr @c_nl
  call void @cli_write(i32 1, ptr %sep, i64 1)
  br label %finish
finish:
  %truth = call i1 @j_truth(ptr %v)
  %status = select i1 %truth, i32 0, i32 1
  store i32 %status, ptr @cli_last
  ret void
}

define internal ptr @cli_take_input() {
entry:
  %all = load ptr, ptr @j_inputs
  %pos = load i64, ptr @j_input_pos
  %n = call i64 @cli_len(ptr %all)
  %done = icmp uge i64 %pos, %n
  br i1 %done, label %end, label %take
take:
  %v = call ptr @j_at(ptr %all, i64 %pos)
  %next = add i64 %pos, 1
  store i64 %next, ptr @j_input_pos
  %names = load ptr, ptr @cli_names
  %name = call ptr @j_at(ptr %names, i64 %pos)
  store ptr %name, ptr @cli_filename
  %lines = load ptr, ptr @cli_lines
  %line = call ptr @j_at(ptr %lines, i64 %pos)
  %np = getelementptr %V, ptr %line, i32 0, i32 2
  %nd = load double, ptr %np
  %ni = fptosi double %nd to i64
  store i64 %ni, ptr @cli_line
  ret ptr %v
end:
  ret ptr null
}

define ptr @j_cli_builtin(ptr %name, ptr %args, ptr %input, ptr %env) {
entry:
  %a = call i1 @j_is(ptr %name, ptr @c_env)
  br i1 %a, label %environment, label %checkinput
environment:
  %e = load ptr, ptr @j_environ
  br label %one
checkinput:
  %b = call i1 @j_is(ptr %name, ptr @c_input)
  br i1 %b, label %takeinput, label %checkinputs
takeinput:
  %iv = call ptr @cli_take_input()
  %eof = icmp eq ptr %iv, null
  br i1 %eof, label %inputeof, label %one
inputeof:
  %inputpending = load ptr, ptr @j_deferred_input_error
  %inputhaspending = icmp ne ptr %inputpending, null
  br i1 %inputhaspending, label %inputdeferred, label %inputbreak
inputdeferred:
  store ptr %inputpending, ptr @j_error
  store ptr null, ptr @j_deferred_input_error
  br label %inputempty
inputbreak:
  call void @j_fail(ptr @c_eof)
  br label %inputempty
inputempty:
  %empty0 = call ptr @j_array()
  ret ptr %empty0
checkinputs:
  %c = call i1 @j_is(ptr %name, ptr @c_inputs)
  br i1 %c, label %inputsbegin, label %checkfilename
inputsbegin:
  %stream = call ptr @j_array()
  br label %inputsloop
inputsloop:
  %nv = call ptr @cli_take_input()
  %neof = icmp eq ptr %nv, null
  br i1 %neof, label %inputsdone, label %inputsappend
inputsappend:
  call void @j_push(ptr %stream, ptr %nv)
  br label %inputsloop
inputsdone:
  %inputspending = load ptr, ptr @j_deferred_input_error
  %inputshaspending = icmp ne ptr %inputspending, null
  br i1 %inputshaspending, label %inputsdeferred, label %inputsreturn
inputsdeferred:
  store ptr %inputspending, ptr @j_error
  store ptr null, ptr @j_deferred_input_error
  br label %inputsreturn
inputsreturn:
  ret ptr %stream
checkfilename:
  %d = call i1 @j_is(ptr %name, ptr @c_filename)
  br i1 %d, label %filename, label %checkline
filename:
  %file = load ptr, ptr @cli_filename
  %have = icmp ne ptr %file, null
  br i1 %have, label %one, label %filenull
filenull:
  %fileempty = call ptr @j_null()
  br label %one
checkline:
  %f = call i1 @j_is(ptr %name, ptr @c_line)
  br i1 %f, label %linenumber, label %checkdebug
linenumber:
  %line = load i64, ptr @cli_line
  %ld = uitofp i64 %line to double
  %ln = call ptr @j_num(double %ld)
  br label %one
checkdebug:
  %g = call i1 @j_is(ptr %name, ptr @c_debug)
  br i1 %g, label %debugbegin, label %checkstderr
debugbegin:
  %na = call i64 @cli_len(ptr %args)
  %hasarg = icmp ne i64 %na, 0
  br i1 %hasarg, label %debugarg, label %debuginput
debuginput:
  %msg = call ptr @j_array()
  call void @j_push(ptr %msg, ptr %input)
  br label %debugloopstart
debugarg:
  %filter = call ptr @j_at(ptr %args, i64 0)
  %messages = call ptr @j_eval(ptr %filter, ptr %input, ptr %env)
  br label %debugloopstart
debugloopstart:
  %ds = phi ptr [ %msg, %debuginput ], [ %messages, %debugarg ]
  %dn = call i64 @cli_len(ptr %ds)
  br label %debugloop
debugloop:
  %di = phi i64 [ 0, %debugloopstart ], [ %dnext, %debugwrite ]
  %dend = icmp uge i64 %di, %dn
  br i1 %dend, label %passthrough, label %debugwrite
debugwrite:
  %dv = call ptr @j_at(ptr %ds, i64 %di)
  %pair = call ptr @j_array()
  %label = call ptr @j_cstr(ptr @c_DEBUG)
  call void @j_push(ptr %pair, ptr %label)
  call void @j_push(ptr %pair, ptr %dv)
  %dd = call ptr @j_dump(ptr %pair, i32 0)
  call void @cli_string(i32 2, ptr %dd)
  call void @cli_write(i32 2, ptr @c_nl, i64 1)
  %dnext = add i64 %di, 1
  br label %debugloop
checkstderr:
  %h = call i1 @j_is(ptr %name, ptr @c_stderr)
  br i1 %h, label %stderr, label %checkhalt
stderr:
  %tag = load i32, ptr %input
  %str = icmp eq i32 %tag, 4
  br i1 %str, label %stderrraw, label %stderrjson
stderrraw:
  call void @cli_string(i32 2, ptr %input)
  br label %passthrough
stderrjson:
  %sd = call ptr @j_dump(ptr %input, i32 0)
  call void @cli_string(i32 2, ptr %sd)
  br label %passthrough
checkhalt:
  %hh = call i1 @j_is(ptr %name, ptr @c_halt)
  br i1 %hh, label %halt, label %checkhalterr
halt:
  store i1 true, ptr @cli_halted
  store i32 0, ptr @cli_halt_code
  %he = call ptr @j_array()
  ret ptr %he
checkhalterr:
  %heq = call i1 @j_is(ptr %name, ptr @c_halt_error)
  br i1 %heq, label %halterr, label %unknown
halterr:
  %hn = call i64 @cli_len(ptr %args)
  %ha = icmp ne i64 %hn, 0
  br i1 %ha, label %haltarg, label %haltdefault
haltarg:
  %hf = call ptr @j_at(ptr %args, i64 0)
  %hs = call ptr @j_eval(ptr %hf, ptr %input, ptr %env)
  %hv = call ptr @j_at(ptr %hs, i64 0)
  %hdp = getelementptr %V, ptr %hv, i32 0, i32 2
  %hd = load double, ptr %hdp
  %hc = fptosi double %hd to i32
  br label %halterrorwrite
haltdefault:
  br label %halterrorwrite
halterrorwrite:
  %code = phi i32 [ %hc, %haltarg ], [ 5, %haltdefault ]
  store i1 true, ptr @cli_halted
  store i32 %code, ptr @cli_halt_code
  %ht = load i32, ptr %input
  switch i32 %ht, label %haltjson [ i32 0, label %haltfinish i32 4, label %haltraw ]
haltraw:
  call void @cli_string(i32 2, ptr %input)
  br label %haltfinish
haltjson:
  %hjson = call ptr @j_dump(ptr %input, i32 0)
  call void @cli_string(i32 2, ptr %hjson)
  call void @cli_write(i32 2, ptr @c_nl, i64 1)
  br label %haltfinish
haltfinish:
  %hempty = call ptr @j_array()
  ret ptr %hempty
unknown:
  ret ptr null
passthrough:
  br label %one
one:
  %v = phi ptr [ %e, %environment ], [ %iv, %takeinput ], [ %file, %filename ], [ %fileempty, %filenull ], [ %ln, %linenumber ], [ %input, %passthrough ]
  %out = call ptr @j_array()
  call void @j_push(ptr %out, ptr %v)
  ret ptr %out
}

%Option = type { ptr, i32, i32 }
@cli_options = private constant [30 x %Option] [
  %Option { ptr @c_null_input, i32 1, i32 2 },
  %Option { ptr @c_raw_input, i32 1, i32 1 },
  %Option { ptr @c_slurp, i32 1, i32 4 },
  %Option { ptr @c_compact, i32 1, i32 8 },
  %Option { ptr @c_raw_output, i32 1, i32 16 },
  %Option { ptr @c_raw_output0, i32 1, i32 2064 },
  %Option { ptr @c_join_output, i32 1, i32 48 },
  %Option { ptr @c_ascii, i32 1, i32 128 },
  %Option { ptr @c_sort, i32 1, i32 256 },
  %Option { ptr @c_exit, i32 1, i32 64 },
  %Option { ptr @c_seq, i32 1, i32 512 },
  %Option { ptr @c_stream, i32 1, i32 1024 },
  %Option { ptr @c_stream_errors, i32 1, i32 17408 },
  %Option { ptr @c_disasm, i32 1, i32 32768 },
  %Option { ptr @c_mono, i32 1, i32 8192 },
  %Option { ptr @c_color, i32 1, i32 4096 },
  %Option { ptr @c_unbuffered, i32 1, i32 0 },
  %Option { ptr @c_help_opt, i32 2, i32 0 },
  %Option { ptr @c_version_opt, i32 3, i32 0 },
  %Option { ptr @c_from_file, i32 4, i32 0 },
  %Option { ptr @c_library, i32 5, i32 0 },
  %Option { ptr @c_indent, i32 6, i32 0 },
  %Option { ptr @c_arg, i32 7, i32 0 },
  %Option { ptr @c_argjson, i32 8, i32 0 },
  %Option { ptr @c_slurpfile, i32 9, i32 0 },
  %Option { ptr @c_rawfile, i32 10, i32 0 },
  %Option { ptr @c_args, i32 11, i32 0 },
  %Option { ptr @c_jsonargs, i32 12, i32 0 },
  %Option { ptr @c_endopts, i32 13, i32 0 },
  %Option { ptr @c_tab, i32 14, i32 0 }
]

define internal void @cli_stream(ptr %v, ptr %path, ptr %out) {
entry:
  %tag = load i32, ptr %v
  %arr = icmp eq i32 %tag, 5
  %obj = icmp eq i32 %tag, 6
  %container = or i1 %arr, %obj
  br i1 %container, label %length, label %scalar
length:
  %n = call i64 @cli_len(ptr %v)
  %empty = icmp eq i64 %n, 0
  br i1 %empty, label %scalar, label %begin
scalar:
  %pair = call ptr @j_array()
  call void @j_push(ptr %pair, ptr %path)
  call void @j_push(ptr %pair, ptr %v)
  call void @j_push(ptr %out, ptr %pair)
  ret void
begin:
  %data = call ptr @cli_data(ptr %v)
  br label %loop
loop:
  %i = phi i64 [ 0, %begin ], [ %next, %recurse ]
  %last = phi ptr [ %path, %begin ], [ %childpath, %recurse ]
  %done = icmp uge i64 %i, %n
  br i1 %done, label %close, label %key
key:
  br i1 %arr, label %arraykey, label %objectkey
arraykey:
  %d = uitofp i64 %i to double
  %ak = call ptr @j_num(double %d)
  %av = call ptr @j_at(ptr %v, i64 %i)
  br label %recurse
objectkey:
  %ki = mul i64 %i, 2
  %kp = getelementptr ptr, ptr %data, i64 %ki
  %ok = load ptr, ptr %kp
  %vp = getelementptr ptr, ptr %kp, i64 1
  %ov = load ptr, ptr %vp
  br label %recurse
recurse:
  %k = phi ptr [ %ak, %arraykey ], [ %ok, %objectkey ]
  %child = phi ptr [ %av, %arraykey ], [ %ov, %objectkey ]
  %childpath = call ptr @j_clone(ptr %path)
  call void @j_push(ptr %childpath, ptr %k)
  call void @cli_stream(ptr %child, ptr %childpath, ptr %out)
  %next = add i64 %i, 1
  br label %loop
close:
  %ending = call ptr @j_array()
  call void @j_push(ptr %ending, ptr %last)
  call void @j_push(ptr %out, ptr %ending)
  ret void
}

define void @__poc_program_start(i64 %argc, ptr %argv) {
entry:
  %index = alloca i64
  %program = alloca ptr
  %envslot = alloca ptr
  %fromfile = alloca i1
  %ended = alloca i1
  %argmode = alloca i32
  store i64 1, ptr %index
  store ptr null, ptr %program
  store ptr null, ptr %envslot
  store i1 false, ptr %fromfile
  store i1 false, ptr %ended
  store i32 0, ptr %argmode
  %files = call ptr @j_array()
  %positional = call ptr @j_array()
  %named = call ptr @j_object()
  %paths = call ptr @j_array()
  store ptr %paths, ptr @j_library_paths
  %environment = call ptr @cli_env(i64 %argc, ptr %argv)
  store ptr %environment, ptr @j_environ
  %envname = call ptr @j_cstr(ptr @c_ENV_name)
  %environmentbinding = call ptr @j_bind(ptr null, ptr %envname, ptr %environment)
  store ptr %environmentbinding, ptr %envslot
  %names = call ptr @j_array()
  %lines = call ptr @j_array()
  store ptr %names, ptr @cli_names
  store ptr %lines, ptr @cli_lines
  %stdinname = call ptr @j_cstr(ptr @c_stdin)
  br label %argloop
argloop:
  %i = load i64, ptr %index
  %allargs = icmp uge i64 %i, %argc
  br i1 %allargs, label %argsdone, label %argbytes
argbytes:
  %slot = getelementptr ptr, ptr %argv, i64 %i
  %bytes = load ptr, ptr %slot
  %argument = call ptr @j_cstr(ptr %bytes)
  %first = load i8, ptr %bytes
  %dash = icmp eq i8 %first, 45
  %secondp = getelementptr i8, ptr %bytes, i64 1
  %second = load i8, ptr %secondp
  %islong = icmp eq i8 %second, 45
  %alone = icmp eq i8 %second, 0
  %notalone = xor i1 %alone, true
  %maybeopt = and i1 %dash, %notalone
  %alreadyended = load i1, ptr %ended
  %canopt = xor i1 %alreadyended, true
  %isopt = and i1 %maybeopt, %canopt
  br i1 %isopt, label %option, label %operand
operand:
  %given = load ptr, ptr %program
  %missing = icmp eq ptr %given, null
  br i1 %missing, label %setprogram, label %operandvalue
setprogram:
  store ptr %argument, ptr %program
  br label %nextarg
operandvalue:
  %mode = load i32, ptr %argmode
  switch i32 %mode, label %addfile [ i32 1, label %addstring i32 2, label %addjson ]
addfile:
  call void @j_push(ptr %files, ptr %argument)
  br label %nextarg
addstring:
  call void @j_push(ptr %positional, ptr %argument)
  br label %nextarg
addjson:
  %pv = call ptr @cli_parse_all(ptr %argument, i1 false, i1 false, ptr %stdinname, i1 false)
  %pvn = call i64 @cli_len(ptr %pv)
  %onepv = icmp eq i64 %pvn, 1
  %pverr = load ptr, ptr @j_error
  %pvok = icmp eq ptr %pverr, null
  %validpv = and i1 %onepv, %pvok
  br i1 %validpv, label %addjsonvalue, label %argerror
addjsonvalue:
  %pv0 = call ptr @j_at(ptr %pv, i64 0)
  call void @j_push(ptr %positional, ptr %pv0)
  br label %nextarg
option:
  br i1 %islong, label %longloop, label %shortloop
longloop:
  %oi = phi i64 [ 0, %option ], [ %onext, %longnext ]
  %oend = icmp eq i64 %oi, 30
  br i1 %oend, label %unknownoption, label %longcheck
longcheck:
  %op = getelementptr [30 x %Option], ptr @cli_options, i64 0, i64 %oi
  %oname = load ptr, ptr %op
  %matches = call i1 @j_is(ptr %argument, ptr %oname)
  br i1 %matches, label %longmatched, label %longnext
longnext:
  %onext = add i64 %oi, 1
  br label %longloop
longmatched:
  %oap = getelementptr %Option, ptr %op, i32 0, i32 1
  %oaction = load i32, ptr %oap
  %ovp = getelementptr %Option, ptr %op, i32 0, i32 2
  %oval = load i32, ptr %ovp
  switch i32 %oaction, label %longparam [
    i32 1, label %longflag i32 2, label %help i32 3, label %version
    i32 11, label %stringmode i32 12, label %jsonmode i32 13, label %endoptions
    i32 14, label %tabindent
  ]
longflag:
  %oldlf = load i32, ptr @cli_flags
  %newlf = or i32 %oldlf, %oval
  store i32 %newlf, ptr @cli_flags
  br label %nextarg
stringmode:
  store i32 1, ptr %argmode
  br label %nextarg
jsonmode:
  store i32 2, ptr %argmode
  br label %nextarg
endoptions:
  store i1 true, ptr %ended
  br label %nextarg
tabindent:
  store i32 -1, ptr @j_indent
  br label %nextarg
shortloop:
  %si = phi i64 [ 1, %option ], [ %snext, %shortflag ]
  %sp = getelementptr i8, ptr %bytes, i64 %si
  %sc = load i8, ptr %sp
  %snext = add i64 %si, 1
  switch i8 %sc, label %unknownoption [
    i8 0, label %nextarg
    i8 110, label %fn i8 82, label %fR i8 115, label %fs i8 99, label %fc
    i8 114, label %fr i8 106, label %fj i8 101, label %fe i8 97, label %fa
    i8 83, label %fS i8 98, label %fb i8 77, label %fM i8 67, label %fC
    i8 104, label %help i8 86, label %version
    i8 102, label %shortfile i8 76, label %shortlib
  ]
fn:
  br label %shortflag
fR:
  br label %shortflag
fs:
  br label %shortflag
fc:
  br label %shortflag
fr:
  br label %shortflag
fj:
  br label %shortflag
fe:
  br label %shortflag
fa:
  br label %shortflag
fS:
  br label %shortflag
fb:
  br label %shortflag
fM:
  br label %shortflag
fC:
  br label %shortflag
shortflag:
  %bit = phi i32 [ 2, %fn ], [ 1, %fR ], [ 4, %fs ], [ 8, %fc ], [ 16, %fr ], [ 48, %fj ], [ 64, %fe ], [ 128, %fa ], [ 256, %fS ], [ 0, %fb ], [ 8192, %fM ], [ 4096, %fC ]
  %oldsf = load i32, ptr @cli_flags
  %newsf = or i32 %oldsf, %bit
  store i32 %newsf, ptr @cli_flags
  br label %shortloop
shortfile:
  br label %shortparam
shortlib:
  br label %shortparam
shortparam:
  %saction = phi i32 [ 4, %shortfile ], [ 5, %shortlib ]
  %tail = getelementptr i8, ptr %sp, i64 1
  %tailc = load i8, ptr %tail
  %hastail = icmp ne i8 %tailc, 0
  br i1 %hastail, label %shortvalue, label %nextparam
shortvalue:
  %tailval = call ptr @j_cstr(ptr %tail)
  br label %paramvalue
longparam:
  br label %nextparam
nextparam:
  %action = phi i32 [ %saction, %shortparam ], [ %oaction, %longparam ]
  %pi = add i64 %i, 1
  %hasparam = icmp ult i64 %pi, %argc
  br i1 %hasparam, label %readparam, label %missingarg
readparam:
  %pslot = getelementptr ptr, ptr %argv, i64 %pi
  %parambytes = load ptr, ptr %pslot
  %param = call ptr @j_cstr(ptr %parambytes)
  store i64 %pi, ptr %index
  br label %paramvalue
paramvalue:
  %paramaction = phi i32 [ %saction, %shortvalue ], [ %action, %readparam ]
  %paramval = phi ptr [ %tailval, %shortvalue ], [ %param, %readparam ]
  switch i32 %paramaction, label %namedarg [ i32 4, label %programfile i32 5, label %librarypath i32 6, label %indentvalue ]
programfile:
  store ptr %paramval, ptr %program
  store i1 true, ptr %fromfile
  br label %nextarg
librarypath:
  call void @j_push(ptr %paths, ptr %paramval)
  br label %nextarg
indentvalue:
  %idata = call ptr @cli_data(ptr %paramval)
  %ilen = call i64 @cli_len(ptr %paramval)
  %ic = load i8, ptr %idata
  %validlen = icmp eq i64 %ilen, 1
  %ival = sub i8 %ic, 48
  %validval = icmp ule i8 %ival, 7
  %validindent = and i1 %validlen, %validval
  br i1 %validindent, label %setindent, label %argerror
setindent:
  %ii = zext i8 %ival to i32
  store i32 %ii, ptr @j_indent
  br label %nextarg
namedarg:
  %ni = load i64, ptr %index
  %vi = add i64 %ni, 1
  %hasvalue = icmp ult i64 %vi, %argc
  br i1 %hasvalue, label %namedvalue, label %missingarg
namedvalue:
  %vslot = getelementptr ptr, ptr %argv, i64 %vi
  %vbytes = load ptr, ptr %vslot
  %value = call ptr @j_cstr(ptr %vbytes)
  store i64 %vi, ptr %index
  switch i32 %paramaction, label %namedstring [ i32 8, label %namedjson i32 9, label %namedslurp i32 10, label %namedraw ]
namedstring:
  br label %bindnamed
namedjson:
  %jsonarray = call ptr @cli_parse_all(ptr %value, i1 false, i1 false, ptr %stdinname, i1 false)
  %jn = call i64 @cli_len(ptr %jsonarray)
  %jone = icmp eq i64 %jn, 1
  %jerr = load ptr, ptr @j_error
  %jok = icmp eq ptr %jerr, null
  %jvalid = and i1 %jone, %jok
  br i1 %jvalid, label %namedjsonvalue, label %argerror
namedjsonvalue:
  %jv = call ptr @j_at(ptr %jsonarray, i64 0)
  br label %bindnamed
namedslurp:
  %slurpbytes = call ptr @j_read_file(ptr %vbytes)
  %slurpread = icmp ne ptr %slurpbytes, null
  br i1 %slurpread, label %namedslurpvalue, label %argerror
namedslurpvalue:
  %slurpv = call ptr @cli_parse_all(ptr %slurpbytes, i1 false, i1 false, ptr %value, i1 false)
  br label %bindnamed
namedraw:
  %rawbytes = call ptr @j_read_file(ptr %vbytes)
  %rawread = icmp ne ptr %rawbytes, null
  br i1 %rawread, label %bindnamed, label %argerror
bindnamed:
  %namedval = phi ptr [ %value, %namedstring ], [ %jv, %namedjsonvalue ], [ %slurpv, %namedslurpvalue ], [ %rawbytes, %namedraw ]
  call void @j_put(ptr %named, ptr %paramval, ptr %namedval)
  %oldenv = load ptr, ptr %envslot
  %newenv = call ptr @j_bind(ptr %oldenv, ptr %paramval, ptr %namedval)
  store ptr %newenv, ptr %envslot
  br label %nextarg
nextarg:
  %curi = load i64, ptr %index
  %nexti = add i64 %curi, 1
  store i64 %nexti, ptr %index
  br label %argloop
help:
  call void @cli_text(i32 1, ptr @c_help)
  call void @_exit(i32 0)
  unreachable
version:
  call void @cli_text(i32 1, ptr @c_version)
  call void @_exit(i32 0)
  unreachable
unknownoption:
  call void @j_fail(ptr @c_option_error)
  br label %argerror
missingarg:
  call void @j_fail(ptr @c_missing_arg)
  br label %argerror
argerror:
  call void @cli_error(i32 2, ptr @c_jq_error)
  call void @_exit(i32 2)
  unreachable
argsdone:
  call void @j_color_init()
  %colorflags = load i32, ptr @cli_flags
  %explicitcolor = and i32 %colorflags, 4096
  %monobit = and i32 %colorflags, 8192
  %forcecolor = icmp ne i32 %explicitcolor, 0
  %mono = icmp ne i32 %monobit, 0
  %tty = call i32 @isatty(i32 1)
  %terminal = icmp eq i32 %tty, 1
  %nocolorkey = call ptr @j_cstr(ptr @c_NO_COLOR)
  %nocolor = call ptr @j_get(ptr %environment, ptr %nocolorkey)
  %nocolortag = load i32, ptr %nocolor
  %nocolorstr = icmp eq i32 %nocolortag, 4
  %nocolorlen = call i64 @cli_len(ptr %nocolor)
  %nocolornonempty = icmp ne i64 %nocolorlen, 0
  %nocolorset = and i1 %nocolorstr, %nocolornonempty
  %allowcolor = xor i1 %nocolorset, true
  %autocolor = and i1 %terminal, %allowcolor
  %wantcolor = or i1 %forcecolor, %autocolor
  %notmono = xor i1 %mono, true
  %enablecolor = and i1 %wantcolor, %notmono
  %clearcolor = and i32 %colorflags, -4097
  %colorvalue = select i1 %enablecolor, i32 4096, i32 0
  %finalcolorflags = or i32 %clearcolor, %colorvalue
  store i32 %finalcolorflags, ptr @cli_flags
  %argsobject = call ptr @j_object()
  %namedkey = call ptr @j_cstr(ptr @c_named)
  %poskey = call ptr @j_cstr(ptr @c_positional)
  call void @j_put(ptr %argsobject, ptr %namedkey, ptr %named)
  call void @j_put(ptr %argsobject, ptr %poskey, ptr %positional)
  store ptr %argsobject, ptr @j_program_args
  %argskey = call ptr @j_cstr(ptr @c_args_name)
  %initialenv = load ptr, ptr %envslot
  %env = call ptr @j_bind(ptr %initialenv, ptr %argskey, ptr %argsobject)
  %prog = load ptr, ptr %program
  %noprog = icmp eq ptr %prog, null
  br i1 %noprog, label %defaultprogram, label %hasprogram
defaultprogram:
  %identity = call ptr @j_cstr(ptr @c_dot)
  br label %compile
hasprogram:
  %pf = load i1, ptr %fromfile
  br i1 %pf, label %readprogram, label %compile
readprogram:
  %progpath = call ptr @cli_data(ptr %prog)
  %progtext = call ptr @j_read_file(ptr %progpath)
  %progreaddone = icmp ne ptr %progtext, null
  br i1 %progreaddone, label %compile, label %argerror
compile:
  %text = phi ptr [ %identity, %defaultprogram ], [ %prog, %hasprogram ], [ %progtext, %readprogram ]
  %withhome = call ptr @j_home_source(ptr %text)
  %source = call ptr @cli_data(ptr %withhome)
  %sourcelen = call i64 @cli_len(ptr %withhome)
  store ptr %env, ptr @j_compile_env
  %compiledast = call ptr @j_compile(ptr %source, i64 %sourcelen)
  %compiled = icmp ne ptr %compiledast, null
  %compileerr = load ptr, ptr @j_error
  %compileok = icmp eq ptr %compileerr, null
  %allcompiled = and i1 %compiled, %compileok
  br i1 %allcompiled, label %foldprogram, label %compileerror
foldprogram:
  %ast = call ptr @j_fold_constants(ptr %compiledast)
  %debugflags = load i32, ptr @cli_flags
  %debugbit = and i32 %debugflags, 32768
  %disassemble = icmp ne i32 %debugbit, 0
  br i1 %disassemble, label %debugprogram, label %readinputs
debugprogram:
  %assembly = call ptr @j_disassemble(ptr %ast)
  call void @cli_string(i32 1, ptr %assembly)
  br label %readinputs
compileerror:
  call void @cli_compile_errors(ptr %source, i64 %sourcelen, ptr %compileerr)
  call void @_exit(i32 3)
  unreachable
readinputs:
  %flags = load i32, ptr @cli_flags
  %rawbit = and i32 %flags, 1
  %raw = icmp ne i32 %rawbit, 0
  %slurpbit = and i32 %flags, 4
  %slurp = icmp ne i32 %slurpbit, 0
  %rawslurp = and i1 %raw, %slurp
  %nullbit = and i32 %flags, 2
  %nullinput = icmp ne i32 %nullbit, 0
  %streambit = and i32 %flags, 1024
  %streamflag = icmp ne i32 %streambit, 0
  %notraw = xor i1 %raw, true
  %streaming = and i1 %streamflag, %notraw
  %streamerrbit = and i32 %flags, 16384
  %streamerrors = icmp ne i32 %streamerrbit, 0
  %allvalues = call ptr @j_array()
  %filecount = call i64 @cli_len(ptr %files)
  %nofiles = icmp eq i64 %filecount, 0
  br i1 %nofiles, label %defaultstdin, label %filebegin
defaultstdin:
  %dashval = call ptr @j_cstr(ptr @c_dash)
  call void @j_push(ptr %files, ptr %dashval)
  br label %filebegin
filebegin:
  %nfiles = call i64 @cli_len(ptr %files)
  br label %fileloop
fileloop:
  %fi = phi i64 [ 0, %filebegin ], [ %finext, %nextfile ]
  %fdone = icmp uge i64 %fi, %nfiles
  br i1 %fdone, label %inputsdone, label %readone
readone:
  %filename = call ptr @j_at(ptr %files, i64 %fi)
  %isstdin = call i1 @j_is(ptr %filename, ptr @c_dash)
  br i1 %isstdin, label %readstdin, label %readpath
readstdin:
  %seen = load i1, ptr @cli_stdin_seen
  br i1 %seen, label %nextfile, label %stdinbytes
stdinbytes:
  store i1 true, ptr @cli_stdin_seen
  %stdindata = call ptr @cli_read_fd(i32 0)
  br label %filedata
readpath:
  %filep = call ptr @cli_data(ptr %filename)
  %filebytes = call ptr @j_read_file(ptr %filep)
  br label %filedata
filedata:
  %content = phi ptr [ %stdindata, %stdinbytes ], [ %filebytes, %readpath ]
  %displayname = phi ptr [ %stdinname, %stdinbytes ], [ %filename, %readpath ]
  %hascontent = icmp ne ptr %content, null
  br i1 %hascontent, label %parsefile, label %fileerror
fileerror:
  call void @cli_error(i32 2, ptr @c_jq_error)
  br label %nextfile
parsefile:
  %filevalues = call ptr @cli_parse_all(ptr %content, i1 %raw, i1 %rawslurp, ptr %displayname, i1 true)
  %filelines = load ptr, ptr @cli_source_lines
  %parseerr = load ptr, ptr @j_error
  %parseerrpath = load ptr, ptr @j_parse_error_path
  %invalidfile = icmp ne ptr %parseerr, null
  br i1 %invalidfile, label %reportparse, label %valuesbegin
reportparse:
  br i1 %streamerrors, label %streamerrorclear, label %inputerrorprint
streamerrorclear:
  store ptr null, ptr @j_error
  br label %valuesbegin
inputerrorprint:
  call void @cli_error(i32 5, ptr @c_input_error)
  br label %valuesbegin
valuesbegin:
  %valuen = call i64 @cli_len(ptr %filevalues)
  br label %valuesloop
valuesloop:
  %vi2 = phi i64 [ 0, %valuesbegin ], [ %vinext, %appendvalue ], [ %vinext, %streamdone ]
  %vend = icmp uge i64 %vi2, %valuen
  br i1 %vend, label %filevaluesdone, label %valueone
valueone:
  %vv = call ptr @j_at(ptr %filevalues, i64 %vi2)
  %linev = call ptr @j_at(ptr %filelines, i64 %vi2)
  %linetag = load i32, ptr %linev
  %hasline = icmp eq i32 %linetag, 3
  %linep = getelementptr %V, ptr %linev, i32 0, i32 2
  %lined = load double, ptr %linep
  %linei = fptosi double %lined to i64
  %defaultline = add i64 %vi2, 1
  %lineno = select i1 %hasline, i64 %linei, i64 %defaultline
  %vinext = add i64 %vi2, 1
  br i1 %streaming, label %streamvalue, label %appendvalue
appendvalue:
  call void @cli_add_input(ptr %allvalues, ptr %vv, ptr %displayname, i64 %lineno)
  br label %valuesloop
streamvalue:
  %events = call ptr @j_array()
  %rootpath = call ptr @j_array()
  call void @cli_stream(ptr %vv, ptr %rootpath, ptr %events)
  %eventn = call i64 @cli_len(ptr %events)
  br label %streamloop
streamloop:
  %ei = phi i64 [ 0, %streamvalue ], [ %enext, %streamappend ]
  %eend = icmp uge i64 %ei, %eventn
  br i1 %eend, label %streamdone, label %streamappend
streamappend:
  %ev = call ptr @j_at(ptr %events, i64 %ei)
  call void @cli_add_input(ptr %allvalues, ptr %ev, ptr %displayname, i64 %lineno)
  %enext = add i64 %ei, 1
  br label %streamloop
streamdone:
  br label %valuesloop
filevaluesdone:
  %errorstream = and i1 %invalidfile, %streamerrors
  br i1 %errorstream, label %streamerrorappend, label %nextfile
streamerrorappend:
  %errpair = call ptr @j_array()
  call void @j_push(ptr %errpair, ptr %parseerr)
  %emptypath = call ptr @j_array()
  %haspath = icmp ne ptr %parseerrpath, null
  %errpath = select i1 %haspath, ptr %parseerrpath, ptr %emptypath
  call void @j_push(ptr %errpair, ptr %errpath)
  call void @cli_add_input(ptr %allvalues, ptr %errpair, ptr %displayname, i64 1)
  br label %nextfile
nextfile:
  %finext = add i64 %fi, 1
  br label %fileloop
inputsdone:
  br i1 %slurp, label %slurpinput, label %setinputs
slurpinput:
  br i1 %raw, label %rawslurpbegin, label %jsonslurp
jsonslurp:
  br label %slurpwrap
rawslurpbegin:
  %emptystring = call ptr @j_cstr(ptr @c_zero)
  %rsn = call i64 @cli_len(ptr %allvalues)
  br label %rawslurploop
rawslurploop:
  %rsi = phi i64 [ 0, %rawslurpbegin ], [ %rsnext, %rawslurpappend ]
  %joined = phi ptr [ %emptystring, %rawslurpbegin ], [ %rsjoined, %rawslurpappend ]
  %rsdone = icmp uge i64 %rsi, %rsn
  br i1 %rsdone, label %slurpwrap, label %rawslurpappend
rawslurpappend:
  %rsv = call ptr @j_at(ptr %allvalues, i64 %rsi)
  %rsjoined = call ptr @j_binary(i32 0, ptr %joined, ptr %rsv)
  %rsnext = add i64 %rsi, 1
  br label %rawslurploop
slurpwrap:
  %slurped = phi ptr [ %allvalues, %jsonslurp ], [ %joined, %rawslurploop ]
  %wrapped = call ptr @j_array()
  call void @j_push(ptr %wrapped, ptr %slurped)
  br label %setinputs
setinputs:
  %inputs = phi ptr [ %allvalues, %inputsdone ], [ %wrapped, %slurpwrap ]
  store ptr %inputs, ptr @j_inputs
  br i1 %nullinput, label %nullvalue, label %runloop
nullvalue:
  %nullval = call ptr @j_null()
  br label %evaluate
runloop:
  %halted = load i1, ptr @cli_halted
  %outputfailed = load i1, ptr @cli_write_failed
  %stop = or i1 %halted, %outputfailed
  br i1 %stop, label %finish, label %runnext
runnext:
  %in = call ptr @cli_take_input()
  %eof = icmp eq ptr %in, null
  br i1 %eof, label %finish, label %evaluate
evaluate:
  %inputval = phi ptr [ %nullval, %nullvalue ], [ %in, %runnext ]
  %results = call ptr @j_eval(ptr %ast, ptr %inputval, ptr %env)
  %resultn = call i64 @cli_len(ptr %results)
  br label %resultloop
resultloop:
  %ri = phi i64 [ 0, %evaluate ], [ %rinext, %resultone ]
  %rend = icmp uge i64 %ri, %resultn
  %writefailed = load i1, ptr @cli_write_failed
  %resultstop = or i1 %rend, %writefailed
  br i1 %resultstop, label %resultdone, label %resultone
resultone:
  %result = call ptr @j_at(ptr %results, i64 %ri)
  call void @cli_emit(ptr %result)
  %rinext = add i64 %ri, 1
  br label %resultloop
resultdone:
  %error = load ptr, ptr @j_error
  %failed = icmp ne ptr %error, null
  br i1 %failed, label %runtimeerror, label %continue
runtimeerror:
  call void @cli_runtime_error()
  br label %continue
continue:
  br i1 %nullinput, label %finish, label %runloop
finish:
  %halt = load i1, ptr @cli_halted
  %hc = load i32, ptr @cli_halt_code
  %rc = load i32, ptr @cli_exit_code
  %last = load i32, ptr @cli_last
  %ef = and i32 %flags, 64
  %exitflag = icmp ne i32 %ef, 0
  %normalrc = select i1 %exitflag, i32 %last, i32 0
  %haderror = icmp ne i32 %rc, 0
  %finalrc = select i1 %haderror, i32 %rc, i32 %normalrc
  %final = select i1 %halt, i32 %hc, i32 %finalrc
  call void @_exit(i32 %final)
  unreachable
}
