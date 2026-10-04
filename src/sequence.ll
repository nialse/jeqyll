%SV = type { i32, i32, double, i64, i64, ptr, ptr }

@j_error = external global ptr
@j_deferred_input_error = external global ptr
@seq_warning = private constant [27 x i8] c"jq: ignoring parse error: \00"
@seq_truncated = private constant [16 x i8] c"Truncated value\00"
@seq_abandoned = private constant [33 x i8] c"Unfinished abandoned text at EOF\00"
@seq_unfinished = private constant [28 x i8] c"Unfinished JSON term at EOF\00"
@seq_line = private constant [10 x i8] c" at line \00"
@seq_column = private constant [10 x i8] c", column \00"
@seq_nl = private constant [2 x i8] c"\0A\00"

declare ptr @j_array()
declare void @j_push(ptr, ptr)
declare ptr @j_num(double)
declare ptr @j_cstr(ptr)
declare ptr @j_parse(ptr, i64, ptr)
declare ptr @j_dump(ptr, i32)
declare ptr @j_buffer_new()
declare void @j_buffer_append(ptr, ptr, i64)
declare ptr @j_buffer_value(ptr)
declare i64 @j_strlen(ptr)
declare i64 @b_len(ptr)
declare ptr @b_data(ptr)
declare void @cli_string(i32, ptr)
declare void @cli_record_position(ptr, i64)

define internal void @seq_append(ptr %buffer, ptr %text) {
  %n = call i64 @j_strlen(ptr %text)
  call void @j_buffer_append(ptr %buffer, ptr %text, i64 %n)
  ret void
}

define internal void @seq_number(ptr %buffer, i64 %n) {
  %d = uitofp i64 %n to double
  %v = call ptr @j_num(double %d)
  %s = call ptr @j_dump(ptr %v, i32 0)
  %data = call ptr @b_data(ptr %s)
  %len = call i64 @b_len(ptr %s)
  call void @j_buffer_append(ptr %buffer, ptr %data, i64 %len)
  ret void
}

define internal void @seq_error(ptr %data, i64 %position, ptr %reason, i1 %defer) {
entry:
  %buffer = call ptr @j_buffer_new()
  call void @seq_append(ptr %buffer, ptr %reason)
  br label %loop
loop:
  %i = phi i64 [ 0, %entry ], [ %next, %body ]
  %line = phi i64 [ 1, %entry ], [ %newlineno, %body ]
  %column = phi i64 [ 0, %entry ], [ %newcolumn, %body ]
  %done = icmp uge i64 %i, %position
  br i1 %done, label %render, label %body
body:
  %p = getelementptr i8, ptr %data, i64 %i
  %c = load i8, ptr %p
  %lf = icmp eq i8 %c, 10
  %inc = zext i1 %lf to i64
  %newlineno = add i64 %line, %inc
  %colnext = add i64 %column, 1
  %newcolumn = select i1 %lf, i64 0, i64 %colnext
  %next = add i64 %i, 1
  br label %loop
render:
  call void @seq_append(ptr %buffer, ptr @seq_line)
  call void @seq_number(ptr %buffer, i64 %line)
  call void @seq_append(ptr %buffer, ptr @seq_column)
  call void @seq_number(ptr %buffer, i64 %column)
  %message = call ptr @j_buffer_value(ptr %buffer)
  store ptr null, ptr @j_error
  br i1 %defer, label %pending, label %print
pending:
  store ptr %message, ptr @j_deferred_input_error
  ret void
print:
  %prefix = call ptr @j_cstr(ptr @seq_warning)
  %nl = call ptr @j_cstr(ptr @seq_nl)
  call void @cli_string(i32 2, ptr %prefix)
  call void @cli_string(i32 2, ptr %message)
  call void @cli_string(i32 2, ptr %nl)
  ret void
}

define internal void @seq_segment(ptr %data, i64 %start, i64 %end, ptr %out, i1 %terminated, i1 %defer) {
entry:
  %offset = alloca i64
  store i64 %start, ptr %offset
  br label %loop
loop:
  %pos = load i64, ptr %offset
  %finished = icmp uge i64 %pos, %end
  br i1 %finished, label %done, label %byte
byte:
  %p = getelementptr i8, ptr %data, i64 %pos
  %c = load i8, ptr %p
  %space = icmp eq i8 %c, 32
  %tab = icmp eq i8 %c, 9
  %lf = icmp eq i8 %c, 10
  %cr = icmp eq i8 %c, 13
  %w0 = or i1 %space, %tab
  %w1 = or i1 %lf, %cr
  %white = or i1 %w0, %w1
  br i1 %white, label %skip, label %parse
skip:
  %next = add i64 %pos, 1
  store i64 %next, ptr %offset
  br label %loop
parse:
  %value = call ptr @j_parse(ptr %data, i64 %end, ptr %offset)
  %valid = icmp ne ptr %value, null
  br i1 %valid, label %checknumber, label %error
checknumber:
  %tag = load i32, ptr %value
  %number = icmp eq i32 %tag, 3
  %after = load i64, ptr %offset
  %atend = icmp eq i64 %after, %end
  %ambiguous = and i1 %number, %atend
  br i1 %ambiguous, label %numbererror, label %append
numbererror:
  %nreason = select i1 %terminated, ptr @seq_truncated, ptr @seq_abandoned
  %ninc = zext i1 %terminated to i64
  %npos = add i64 %end, %ninc
  call void @seq_error(ptr %data, i64 %npos, ptr %nreason, i1 %defer)
  ret void
append:
  call void @j_push(ptr %out, ptr %value)
  call void @cli_record_position(ptr %data, i64 %after)
  br label %loop
error:
  %reason = select i1 %terminated, ptr @seq_truncated, ptr @seq_unfinished
  %inc = zext i1 %terminated to i64
  %errorpos = add i64 %end, %inc
  call void @seq_error(ptr %data, i64 %errorpos, ptr %reason, i1 %defer)
  ret void
done:
  ret void
}

define ptr @j_seq_parse(ptr %input, i1 %defer) {
entry:
  %out = call ptr @j_array()
  %data = call ptr @b_data(ptr %input)
  %n = call i64 @b_len(ptr %input)
  br label %loop
loop:
  %i = phi i64 [ 0, %entry ], [ %next, %ordinary ], [ %next, %separatorend ]
  %start = phi i64 [ -1, %entry ], [ %start, %ordinary ], [ %next, %separatorend ]
  %dirty = phi i1 [ false, %entry ], [ %newdirty, %ordinary ], [ false, %separatorend ]
  %done = icmp uge i64 %i, %n
  br i1 %done, label %eof, label %byte
byte:
  %p = getelementptr i8, ptr %data, i64 %i
  %c = load i8, ptr %p
  %rs = icmp eq i8 %c, 30
  %next = add i64 %i, 1
  br i1 %rs, label %separator, label %ordinary
ordinary:
  %notspace = icmp ne i8 %c, 32
  %nottab = icmp ne i8 %c, 9
  %notlf = icmp ne i8 %c, 10
  %notcr = icmp ne i8 %c, 13
  %w0 = and i1 %notspace, %nottab
  %w1 = and i1 %notlf, %notcr
  %nonwhite = and i1 %w0, %w1
  %newdirty = or i1 %dirty, %nonwhite
  br label %loop
separator:
  %have = icmp sge i64 %start, 0
  br i1 %have, label %segment, label %separatorend
segment:
  call void @seq_segment(ptr %data, i64 %start, i64 %i, ptr %out, i1 true, i1 %defer)
  br label %separatorend
separatorend:
  br label %loop
eof:
  %started = icmp sge i64 %start, 0
  br i1 %started, label %lastsegment, label %abandoned
lastsegment:
  call void @seq_segment(ptr %data, i64 %start, i64 %n, ptr %out, i1 false, i1 %defer)
  ret ptr %out
abandoned:
  br i1 %dirty, label %warning, label %finish
warning:
  call void @seq_error(ptr %data, i64 %n, ptr @seq_abandoned, i1 %defer)
  br label %finish
finish:
  ret ptr %out
}
