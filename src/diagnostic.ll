%DV = type { i32, i32, double, i64, i64, ptr, ptr }

@diag_at = private constant [23 x i8] c" at <top-level>, line \00"
@diag_column = private constant [10 x i8] c", column \00"
@diag_source = private constant [7 x i8] c":\0A    \00"
@diag_carets = private constant [6 x i8] c"\0A    \00"
@diag_unknown = private constant [13 x i8] c"syntax error\00"
@diag_input_at = private constant [10 x i8] c" at line \00"
@diag_input_eof = private constant [8 x i8] c" at EOF\00"
@diag_file_at = private constant [5 x i8] c" at \00"
@diag_file_line = private constant [8 x i8] c", line \00"
@j_parse_error_eof = external global i1

declare ptr @j_num(double)
declare ptr @j_cstr(ptr)
declare ptr @j_dump(ptr, i32)
declare i64 @j_strlen(ptr)
declare ptr @j_buffer_new()
declare void @j_buffer_append(ptr, ptr, i64)
declare void @j_buffer_byte(ptr, i8)
declare ptr @j_buffer_value(ptr)

define internal void @diag_text(ptr %buffer, ptr %text) {
  %n = call i64 @j_strlen(ptr %text)
  call void @j_buffer_append(ptr %buffer, ptr %text, i64 %n)
  ret void
}

define internal void @diag_value(ptr %buffer, ptr %value) {
  %np = getelementptr %DV, ptr %value, i32 0, i32 3
  %n = load i64, ptr %np
  %dp = getelementptr %DV, ptr %value, i32 0, i32 5
  %data = load ptr, ptr %dp
  call void @j_buffer_append(ptr %buffer, ptr %data, i64 %n)
  ret void
}

define internal void @diag_integer(ptr %buffer, i64 %number) {
  %d = uitofp i64 %number to double
  %v = call ptr @j_num(double %d)
  %s = call ptr @j_dump(ptr %v, i32 0)
  call void @diag_value(ptr %buffer, ptr %s)
  ret void
}

define ptr @j_input_diagnostic(ptr %source, i64 %length, i64 %position, ptr %message) {
entry:
  %buffer = call ptr @j_buffer_new()
  call void @diag_text(ptr %buffer, ptr %message)
  %eof = load i1, ptr @j_parse_error_eof
  br i1 %eof, label %atend, label %locate
atend:
  call void @diag_text(ptr %buffer, ptr @diag_input_eof)
  br label %locate
locate:
  call void @diag_text(ptr %buffer, ptr @diag_input_at)
  %past = icmp ugt i64 %position, %length
  %bound = select i1 %past, i64 %length, i64 %position
  br label %scan
scan:
  %i = phi i64 [ 0, %locate ], [ %next, %byte ]
  %line = phi i64 [ 1, %locate ], [ %nextline, %byte ]
  %column = phi i64 [ 0, %locate ], [ %nextcolumn, %byte ]
  %done = icmp uge i64 %i, %bound
  br i1 %done, label %finish, label %byte
byte:
  %p = getelementptr i8, ptr %source, i64 %i
  %c = load i8, ptr %p
  %lf = icmp eq i8 %c, 10
  %inc = zext i1 %lf to i64
  %nextline = add i64 %line, %inc
  %colinc = add i64 %column, 1
  %nextcolumn = select i1 %lf, i64 0, i64 %colinc
  %next = add i64 %i, 1
  br label %scan
finish:
  call void @diag_integer(ptr %buffer, i64 %line)
  call void @diag_text(ptr %buffer, ptr @diag_column)
  call void @diag_integer(ptr %buffer, i64 %column)
  %result = call ptr @j_buffer_value(ptr %buffer)
  ret ptr %result
}

define ptr @j_compile_diagnostic(ptr %source, i64 %length, i64 %begin, i64 %end, ptr %message) {
  %result = call ptr @j_compile_file_diagnostic(ptr %source, i64 %length, i64 %begin, i64 %end, ptr %message, ptr null)
  ret ptr %result
}

define ptr @j_compile_file_diagnostic(ptr %source, i64 %length, i64 %begin, i64 %end, ptr %message, ptr %filename) {
entry:
  %buffer = call ptr @j_buffer_new()
  %past = icmp ugt i64 %begin, %length
  %position = select i1 %past, i64 %length, i64 %begin
  %hasmessage = icmp ne ptr %message, null
  br i1 %hasmessage, label %readmessage, label %default
readmessage:
  %tag = load i32, ptr %message
  %str = icmp eq i32 %tag, 4
  br i1 %str, label %stringmessage, label %jsonmessage
stringmessage:
  call void @diag_value(ptr %buffer, ptr %message)
  br label %location
jsonmessage:
  %json = call ptr @j_dump(ptr %message, i32 0)
  call void @diag_value(ptr %buffer, ptr %json)
  br label %location
default:
  call void @diag_text(ptr %buffer, ptr @diag_unknown)
  br label %location
location:
  br label %findline
findline:
  %i = phi i64 [ 0, %location ], [ %next, %byte ]
  %line = phi i64 [ 1, %location ], [ %nextline, %byte ]
  %linestart = phi i64 [ 0, %location ], [ %nextstart, %byte ]
  %reached = icmp uge i64 %i, %position
  br i1 %reached, label %lineend, label %byte
byte:
  %p = getelementptr i8, ptr %source, i64 %i
  %c = load i8, ptr %p
  %lf = icmp eq i8 %c, 10
  %inc = zext i1 %lf to i64
  %nextline = add i64 %line, %inc
  %next = add i64 %i, 1
  %nextstart = select i1 %lf, i64 %next, i64 %linestart
  br label %findline
lineend:
  %j = phi i64 [ %linestart, %findline ], [ %jn, %linenext ]
  %eof = icmp uge i64 %j, %length
  br i1 %eof, label %render, label %linebyte
linebyte:
  %jp = getelementptr i8, ptr %source, i64 %j
  %jc = load i8, ptr %jp
  %newline = icmp eq i8 %jc, 10
  br i1 %newline, label %render, label %linenext
linenext:
  %jn = add i64 %j, 1
  br label %lineend
render:
  %offset = sub i64 %position, %linestart
  %column = add i64 %offset, 1
  %named = icmp ne ptr %filename, null
  br i1 %named, label %namedfile, label %topfile
namedfile:
  call void @diag_text(ptr %buffer, ptr @diag_file_at)
  call void @diag_value(ptr %buffer, ptr %filename)
  call void @diag_text(ptr %buffer, ptr @diag_file_line)
  br label %renderline
topfile:
  call void @diag_text(ptr %buffer, ptr @diag_at)
  br label %renderline
renderline:
  call void @diag_integer(ptr %buffer, i64 %line)
  call void @diag_text(ptr %buffer, ptr @diag_column)
  call void @diag_integer(ptr %buffer, i64 %column)
  call void @diag_text(ptr %buffer, ptr @diag_source)
  %linep = getelementptr i8, ptr %source, i64 %linestart
  %linelen = sub i64 %j, %linestart
  call void @j_buffer_append(ptr %buffer, ptr %linep, i64 %linelen)
  call void @diag_text(ptr %buffer, ptr @diag_carets)
  br label %spaces
spaces:
  %k = phi i64 [ 0, %renderline ], [ %kn, %space ]
  %aligned = icmp uge i64 %k, %offset
  br i1 %aligned, label %caretbegin, label %space
space:
  call void @j_buffer_byte(ptr %buffer, i8 32)
  %kn = add i64 %k, 1
  br label %spaces
caretbegin:
  %beyond = icmp ugt i64 %end, %j
  %clipped = select i1 %beyond, i64 %j, i64 %end
  %span = sub i64 %clipped, %position
  %validspan = icmp sgt i64 %span, 0
  %caretn = select i1 %validspan, i64 %span, i64 1
  br label %carets
carets:
  %r = phi i64 [ 0, %caretbegin ], [ %rn, %caret ]
  %done = icmp uge i64 %r, %caretn
  br i1 %done, label %finish, label %caret
caret:
  call void @j_buffer_byte(ptr %buffer, i8 94)
  %rn = add i64 %r, 1
  br label %carets
finish:
  %result = call ptr @j_buffer_value(ptr %buffer)
  ret ptr %result
}
