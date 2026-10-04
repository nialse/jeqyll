%IV = type { i32, i32, double, i64, i64, ptr, ptr }
%Input = type { ptr, i64, i32, i32, ptr, ptr, i64, i64, i64, i64, i64, i32, i1, i1, i1, i1, i1, i1, i1, i8, ptr, i64, i64, i32, ptr }
%InputFrame = type { i32, i32, i64, ptr, ptr }
%InputBuffer = type { ptr, i64, i64 }

@j_error = external global ptr
@j_parse_error_offset = external global i64
@j_parse_error_eof = external global i1
@j_parse_error_message = external global ptr
@j_parse_error_path = external global ptr
@mtrt_errno_EINTR = external constant i32
@in_dash = private constant [2 x i8] c"-\00"
@in_stdin = private constant [8 x i8] c"<stdin>\00"
@in_io = private constant [16 x i8] c"Input I/O error\00"
@in_bom = private constant [14 x i8] c"Malformed BOM\00"
@in_unfinished = private constant [22 x i8] c"Unfinished JSON term\00\00"
@in_unfinished_seq = private constant [28 x i8] c"Unfinished JSON term at EOF\00"
@in_abandoned = private constant [33 x i8] c"Unfinished abandoned text at EOF\00"
@in_truncated = private constant [16 x i8] c"Truncated value\00"
@in_warning = private constant [27 x i8] c"jq: ignoring parse error: \00"
@in_eof = private constant [8 x i8] c" at EOF\00"
@in_at = private constant [10 x i8] c" at line \00"
@in_column = private constant [10 x i8] c", column \00"
@in_nl = private constant [2 x i8] c"\0A\00"
@in_literal = private constant [16 x i8] c"Invalid literal\00"
@in_number = private constant [24 x i8] c"Invalid numeric literal\00"
@in_array_element = private constant [32 x i8] c"Expected another array element\00\00"
@in_object_pair = private constant [33 x i8] c"Expected another key-value pair\00\00"
@in_separator = private constant [35 x i8] c"Expected separator between values\00\00"
@in_parts = private constant [41 x i8] c"Objects must consist of key:value pairs\00\00"
@in_keys = private constant [29 x i8] c"Object keys must be strings\00\00"
@in_object_object = private constant [39 x i8] c"Expected string key after '{', not '{'\00"
@in_object_array = private constant [39 x i8] c"Expected string key after '{', not '['\00"
@in_comma_object = private constant [49 x i8] c"Expected string key after ',' in object, not '{'\00"
@in_comma_array = private constant [49 x i8] c"Expected string key after ',' in object, not '['\00"
@in_unmatched_array = private constant [15 x i8] c"Unmatched ']'\00\00"
@in_unmatched_object = private constant [15 x i8] c"Unmatched '}'\00\00"
@in_top_array = private constant [31 x i8] c"Unmatched ']' at the top-level\00"
@in_top_object = private constant [31 x i8] c"Unmatched '}' at the top-level\00"
@in_depth = private constant [33 x i8] c"Exceeds depth limit for parsing\00\00"

declare ptr @j_alloc_permanent(i64)
declare ptr @j_null()
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
declare ptr @j_parse(ptr, i64, ptr)
declare ptr @j_dump(ptr, i32)
declare void @j_fail(ptr)
declare void @j_copy(ptr, ptr, i64)
declare ptr @j_gc_value(ptr)
declare ptr @j_gc_copy(ptr, i64, ptr)
declare ptr @j_buffer_new()
declare void @j_buffer_append(ptr, ptr, i64)
declare void @j_buffer_byte(ptr, i8)
declare ptr @j_buffer_value(ptr)
declare i64 @read(i32, ptr, i64)
declare i64 @write(i32, ptr, i64)
declare i32 @open(ptr, i32, i32)
declare i32 @close(i32)

define internal i64 @in_len(ptr %value) {
  %p = getelementptr %IV, ptr %value, i32 0, i32 3
  %n = load i64, ptr %p
  ret i64 %n
}

define internal ptr @in_data(ptr %value) {
  %p = getelementptr %IV, ptr %value, i32 0, i32 5
  %data = load ptr, ptr %p
  ret ptr %data
}

define internal i1 @in_flag(ptr %reader, i32 %mask) {
  %p = getelementptr %Input, ptr %reader, i32 0, i32 2
  %flags = load i32, ptr %p
  %bits = and i32 %flags, %mask
  %set = icmp ne i32 %bits, 0
  ret i1 %set
}

define ptr @j_input_new(ptr %files, i32 %flags) {
  %reader = call ptr @j_alloc_permanent(i64 192)
  store ptr %files, ptr %reader
  %flagp = getelementptr %Input, ptr %reader, i32 0, i32 2
  store i32 %flags, ptr %flagp
  %fdp = getelementptr %Input, ptr %reader, i32 0, i32 3
  store i32 -1, ptr %fdp
  %name = call ptr @j_alloc_permanent(i64 48)
  store i32 4, ptr %name
  %namelen = getelementptr %IV, ptr %name, i32 0, i32 3
  store i64 7, ptr %namelen
  %namedata = getelementptr %IV, ptr %name, i32 0, i32 5
  store ptr @in_stdin, ptr %namedata
  %namep = getelementptr %Input, ptr %reader, i32 0, i32 4
  store ptr %name, ptr %namep
  %buffer = call ptr @j_alloc_permanent(i64 65536)
  %bufferp = getelementptr %Input, ptr %reader, i32 0, i32 5
  store ptr %buffer, ptr %bufferp
  %linep = getelementptr %Input, ptr %reader, i32 0, i32 8
  store i64 1, ptr %linep
  %lastp = getelementptr %Input, ptr %reader, i32 0, i32 10
  store i64 1, ptr %lastp
  ret ptr %reader
}

define ptr @j_input_name(ptr %reader) {
  %p = getelementptr %Input, ptr %reader, i32 0, i32 4
  %value = load ptr, ptr %p
  ret ptr %value
}

define i64 @j_input_line(ptr %reader) {
  %p = getelementptr %Input, ptr %reader, i32 0, i32 10
  %value = load i64, ptr %p
  ret i64 %value
}

define i32 @j_input_status(ptr %reader) {
  %p = getelementptr %Input, ptr %reader, i32 0, i32 11
  %value = load i32, ptr %p
  ret i32 %value
}

define internal void @in_io_error(ptr %reader) {
  %p = getelementptr %Input, ptr %reader, i32 0, i32 11
  store i32 2, ptr %p
  call void @j_fail(ptr @in_io)
  ret void
}

define void @j_input_close(ptr %reader) {
entry:
  %fdp = getelementptr %Input, ptr %reader, i32 0, i32 3
  %fd = load i32, ptr %fdp
  store i32 -1, ptr %fdp
  %ownedp = getelementptr %Input, ptr %reader, i32 0, i32 18
  %owned = load i1, ptr %ownedp
  store i1 false, ptr %ownedp
  %valid = icmp sge i32 %fd, 0
  %ordinary = and i1 %owned, %valid
  br i1 %ordinary, label %close, label %done
close:
  %result = call i32 @close(i32 %fd)
  %bad = icmp slt i32 %result, 0
  br i1 %bad, label %error, label %done
error:
  %existing = call i32 @j_input_status(ptr %reader)
  %clean = icmp eq i32 %existing, 0
  br i1 %clean, label %report, label %done
report:
  call void @in_io_error(ptr %reader)
  br label %done
done:
  ret void
}

define internal i1 @in_open(ptr %reader) {
entry:
  %fdp = getelementptr %Input, ptr %reader, i32 0, i32 3
  %current = load i32, ptr %fdp
  %active = icmp sge i32 %current, 0
  br i1 %active, label %yes, label %begin
begin:
  %files = load ptr, ptr %reader
  %count = call i64 @in_len(ptr %files)
  %indexp = getelementptr %Input, ptr %reader, i32 0, i32 1
  %seenp = getelementptr %Input, ptr %reader, i32 0, i32 12
  br label %loop
loop:
  %index = load i64, ptr %indexp
  %empty = icmp eq i64 %count, 0
  %limit = select i1 %empty, i64 1, i64 %count
  %done = icmp uge i64 %index, %limit
  br i1 %done, label %no, label %file
file:
  %next = add i64 %index, 1
  store i64 %next, ptr %indexp
  br i1 %empty, label %stdin, label %named
named:
  %name = call ptr @j_at(ptr %files, i64 %index)
  %dash = call i1 @j_is(ptr %name, ptr @in_dash)
  br i1 %dash, label %stdin, label %path
stdin:
  %seen = load i1, ptr %seenp
  br i1 %seen, label %loop, label %stdinopen
stdinopen:
  store i1 true, ptr %seenp
  %stdname = call ptr @j_alloc_permanent(i64 48)
  store i32 4, ptr %stdname
  %sn = getelementptr %IV, ptr %stdname, i32 0, i32 3
  store i64 7, ptr %sn
  %sd = getelementptr %IV, ptr %stdname, i32 0, i32 5
  store ptr @in_stdin, ptr %sd
  br label %opened
path:
  %data = call ptr @in_data(ptr %name)
  %interrupted = load i32, ptr @mtrt_errno_EINTR
  %negative = sub i32 0, %interrupted
  br label %retry
retry:
  %fd = call i32 @open(ptr %data, i32 0, i32 0)
  %again = icmp eq i32 %fd, %negative
  br i1 %again, label %retry, label %check
check:
  %bad = icmp slt i32 %fd, 0
  br i1 %bad, label %error, label %opened
opened:
  %descriptor = phi i32 [ 0, %stdinopen ], [ %fd, %check ]
  %display = phi ptr [ %stdname, %stdinopen ], [ %name, %check ]
  %owned = phi i1 [ false, %stdinopen ], [ true, %check ]
  store i32 %descriptor, ptr %fdp
  %ownedp = getelementptr %Input, ptr %reader, i32 0, i32 18
  store i1 %owned, ptr %ownedp
  %np = getelementptr %Input, ptr %reader, i32 0, i32 4
  store ptr %display, ptr %np
  %posp = getelementptr %Input, ptr %reader, i32 0, i32 6
  store i64 0, ptr %posp
  %endp = getelementptr %Input, ptr %reader, i32 0, i32 7
  store i64 0, ptr %endp
  %linep = getelementptr %Input, ptr %reader, i32 0, i32 8
  store i64 1, ptr %linep
  %colp = getelementptr %Input, ptr %reader, i32 0, i32 9
  store i64 0, ptr %colp
  %lastp = getelementptr %Input, ptr %reader, i32 0, i32 10
  store i64 1, ptr %lastp
  %eofp = getelementptr %Input, ptr %reader, i32 0, i32 13
  store i1 false, ptr %eofp
  %seqp = getelementptr %Input, ptr %reader, i32 0, i32 16
  store i1 false, ptr %seqp
  %dirtyp = getelementptr %Input, ptr %reader, i32 0, i32 17
  store i1 false, ptr %dirtyp
  %bomp = getelementptr %Input, ptr %reader, i32 0, i32 19
  store i8 0, ptr %bomp
  br label %yes
error:
  %enp = getelementptr %Input, ptr %reader, i32 0, i32 4
  store ptr %name, ptr %enp
  call void @in_io_error(ptr %reader)
  br label %no
yes:
  ret i1 true
no:
  ret i1 false
}

; Peeking never crosses a file boundary. Negative results distinguish EOF and I/O.
define internal i32 @in_peek(ptr %reader) {
entry:
  %posp = getelementptr %Input, ptr %reader, i32 0, i32 6
  %endp = getelementptr %Input, ptr %reader, i32 0, i32 7
  %position = load i64, ptr %posp
  %end = load i64, ptr %endp
  %bufferp = getelementptr %Input, ptr %reader, i32 0, i32 5
  %buffer = load ptr, ptr %bufferp
  %available = icmp ult i64 %position, %end
  br i1 %available, label %byte, label %refill
byte:
  %p = getelementptr i8, ptr %buffer, i64 %position
  %c = load i8, ptr %p
  %wide = zext i8 %c to i32
  ret i32 %wide
refill:
  %eofp = getelementptr %Input, ptr %reader, i32 0, i32 13
  %eof = load i1, ptr %eofp
  br i1 %eof, label %endfile, label %beginread
beginread:
  %fdp = getelementptr %Input, ptr %reader, i32 0, i32 3
  %fd = load i32, ptr %fdp
  %interrupted = load i32, ptr @mtrt_errno_EINTR
  %negative32 = sub i32 0, %interrupted
  %negative = sext i32 %negative32 to i64
  br label %retry
retry:
  %count = call i64 @read(i32 %fd, ptr %buffer, i64 65536)
  %again = icmp eq i64 %count, %negative
  br i1 %again, label %retry, label %result
result:
  %bad = icmp slt i64 %count, 0
  br i1 %bad, label %error, label %emptycheck
emptycheck:
  %empty = icmp eq i64 %count, 0
  br i1 %empty, label %seteof, label %first
first:
  store i64 0, ptr %posp
  store i64 %count, ptr %endp
  %firstbyte = load i8, ptr %buffer
  %firstwide = zext i8 %firstbyte to i32
  ret i32 %firstwide
seteof:
  store i1 true, ptr %eofp
  br label %endfile
endfile:
  ret i32 -1
error:
  call void @in_io_error(ptr %reader)
  ret i32 -2
}

define internal void @in_take(ptr %reader, i32 %character) {
  %posp = getelementptr %Input, ptr %reader, i32 0, i32 6
  %position = load i64, ptr %posp
  %next = add i64 %position, 1
  store i64 %next, ptr %posp
  %linep = getelementptr %Input, ptr %reader, i32 0, i32 8
  %colp = getelementptr %Input, ptr %reader, i32 0, i32 9
  %line = load i64, ptr %linep
  %column = load i64, ptr %colp
  %newline = icmp eq i32 %character, 10
  %inc = zext i1 %newline to i64
  %nextline = add i64 %line, %inc
  %colinc = add i64 %column, 1
  %nextcolumn = select i1 %newline, i64 0, i64 %colinc
  store i64 %nextline, ptr %linep
  store i64 %nextcolumn, ptr %colp
  ret void
}

define internal i1 @in_white(i32 %c) {
  switch i32 %c, label %no [ i32 32, label %yes i32 9, label %yes i32 10, label %yes i32 13, label %yes ]
yes:
  ret i1 true
no:
  ret i1 false
}

define internal i1 @in_boundary(i32 %c) {
  switch i32 %c, label %no [ i32 -1, label %yes i32 -2, label %yes i32 32, label %yes i32 9, label %yes i32 10, label %yes i32 13, label %yes i32 91, label %yes i32 93, label %yes i32 123, label %yes i32 125, label %yes i32 44, label %yes i32 58, label %yes i32 34, label %yes ]
yes:
  ret i1 true
no:
  ret i1 false
}

define internal ptr @in_frame(ptr %reader, i64 %index) {
  %p = getelementptr %Input, ptr %reader, i32 0, i32 20
  %frames = load ptr, ptr %p
  %frame = getelementptr %InputFrame, ptr %frames, i64 %index
  ret ptr %frame
}

define internal ptr @in_path(ptr %reader) {
entry:
  %path = call ptr @j_array()
  %depthp = getelementptr %Input, ptr %reader, i32 0, i32 21
  %depth = load i64, ptr %depthp
  br label %loop
loop:
  %i = phi i64 [ 0, %entry ], [ %next, %append ]
  %done = icmp uge i64 %i, %depth
  br i1 %done, label %finish, label %frame
frame:
  %f = call ptr @in_frame(ptr %reader, i64 %i)
  %kind = load i32, ptr %f
  %statep = getelementptr %InputFrame, ptr %f, i32 0, i32 1
  %state = load i32, ptr %statep
  %array = icmp eq i32 %kind, 5
  br i1 %array, label %index, label %key
index:
  %countp = getelementptr %InputFrame, ptr %f, i32 0, i32 2
  %count = load i64, ptr %countp
  %after = icmp eq i32 %state, 1
  %previous = sub i64 %count, 1
  %current = select i1 %after, i64 %previous, i64 %count
  %d = uitofp i64 %current to double
  %number = call ptr @j_num(double %d)
  br label %append
key:
  %keyp = getelementptr %InputFrame, ptr %f, i32 0, i32 3
  %oldkey = load ptr, ptr %keyp
  %valuephase = icmp uge i32 %state, 5
  %beforecomma = icmp ule i32 %state, 6
  %havekey = and i1 %valuephase, %beforecomma
  %null = call ptr @j_null()
  %keyvalue = select i1 %havekey, ptr %oldkey, ptr %null
  br label %append
append:
  %part = phi ptr [ %number, %index ], [ %keyvalue, %key ]
  call void @j_push(ptr %path, ptr %part)
  %next = add i64 %i, 1
  br label %loop
finish:
  ret ptr %path
}

define internal void @in_text(ptr %buffer, ptr %text) {
  %n = call i64 @j_strlen(ptr %text)
  call void @j_buffer_append(ptr %buffer, ptr %text, i64 %n)
  ret void
}

define internal void @in_integer(ptr %buffer, i64 %n) {
  %d = uitofp i64 %n to double
  %v = call ptr @j_num(double %d)
  %s = call ptr @j_dump(ptr %v, i32 0)
  %data = call ptr @in_data(ptr %s)
  %length = call i64 @in_len(ptr %s)
  call void @j_buffer_append(ptr %buffer, ptr %data, i64 %length)
  ret void
}

define internal void @in_error(ptr %reader, ptr %reason, i1 %eof, i64 %line, i64 %column) {
entry:
  %b = call ptr @j_buffer_new()
  call void @in_text(ptr %b, ptr %reason)
  br i1 %eof, label %eoftext, label %location
eoftext:
  call void @in_text(ptr %b, ptr @in_eof)
  br label %location
location:
  call void @in_text(ptr %b, ptr @in_at)
  call void @in_integer(ptr %b, i64 %line)
  call void @in_text(ptr %b, ptr @in_column)
  call void @in_integer(ptr %b, i64 %column)
  %error = call ptr @j_buffer_value(ptr %b)
  store ptr %error, ptr @j_error
  store ptr %reason, ptr @j_parse_error_message
  store i1 %eof, ptr @j_parse_error_eof
  %path = call ptr @in_path(ptr %reader)
  store ptr %path, ptr @j_parse_error_path
  %statusp = getelementptr %Input, ptr %reader, i32 0, i32 11
  store i32 5, ptr %statusp
  %lastp = getelementptr %Input, ptr %reader, i32 0, i32 10
  %zerocol = icmp eq i64 %column, 0
  %notfirst = icmp ugt i64 %line, 1
  %previous = and i1 %zerocol, %notfirst
  %dec = zext i1 %previous to i64
  %contextline = sub i64 %line, %dec
  store i64 %contextline, ptr %lastp
  ret void
}

define internal void @in_error_here(ptr %reader, ptr %reason, i1 %eof) {
  %lp = getelementptr %Input, ptr %reader, i32 0, i32 8
  %cp = getelementptr %Input, ptr %reader, i32 0, i32 9
  %line = load i64, ptr %lp
  %column = load i64, ptr %cp
  call void @in_error(ptr %reader, ptr %reason, i1 %eof, i64 %line, i64 %column)
  ret void
}

; Only one scalar token is buffered. Container state is independent of byte chunks.
define internal ptr @in_token(ptr %reader) {
entry:
  %b = call ptr @j_buffer_new()
  %lp = getelementptr %Input, ptr %reader, i32 0, i32 8
  %cp = getelementptr %Input, ptr %reader, i32 0, i32 9
  %startline = load i64, ptr %lp
  %startcolumn = load i64, ptr %cp
  %first = call i32 @in_peek(ptr %reader)
  %quoted = icmp eq i32 %first, 34
  %sequence = call i1 @in_flag(ptr %reader, i32 512)
  br i1 %quoted, label %quoteopen, label %plain
quoteopen:
  call void @in_take(ptr %reader, i32 34)
  call void @j_buffer_byte(ptr %b, i8 34)
  br label %string
string:
  %escaped = phi i1 [ false, %quoteopen ], [ %nextescaped, %stringbyte ]
  %sc = call i32 @in_peek(ptr %reader)
  %snegative = icmp slt i32 %sc, 0
  %srs = icmp eq i32 %sc, 30
  %sseparator = and i1 %sequence, %srs
  %sstop = or i1 %snegative, %sseparator
  br i1 %sstop, label %stringend, label %stringbyte
stringbyte:
  call void @in_take(ptr %reader, i32 %sc)
  %sbyte = trunc i32 %sc to i8
  call void @j_buffer_byte(ptr %b, i8 %sbyte)
  %slash = icmp eq i32 %sc, 92
  %unescaped = xor i1 %escaped, true
  %nextescaped = and i1 %slash, %unescaped
  %quote = icmp eq i32 %sc, 34
  %closed = and i1 %quote, %unescaped
  br i1 %closed, label %stringclosed, label %string
stringclosed:
  br label %parse
stringend:
  %sio = icmp eq i32 %sc, -2
  br i1 %sio, label %failure, label %parse
plain:
  %pc = call i32 @in_peek(ptr %reader)
  %boundary = call i1 @in_boundary(i32 %pc)
  %prs = icmp eq i32 %pc, 30
  %pseparator = and i1 %sequence, %prs
  %pstop = or i1 %boundary, %pseparator
  br i1 %pstop, label %plainend, label %plainbyte
plainbyte:
  call void @in_take(ptr %reader, i32 %pc)
  %pbyte = trunc i32 %pc to i8
  call void @j_buffer_byte(ptr %b, i8 %pbyte)
  br label %plain
plainend:
  %pio = icmp eq i32 %pc, -2
  br i1 %pio, label %failure, label %parse
parse:
  %terminator = phi i32 [ -3, %stringclosed ], [ %sc, %stringend ], [ %pc, %plainend ]
  %token = call ptr @j_buffer_value(ptr %b)
  %length = call i64 @in_len(ptr %token)
  %realend = icmp sge i32 %terminator, 0
  %notrs = icmp ne i32 %terminator, 30
  %appendend = and i1 %realend, %notrs
  br i1 %appendend, label %delimiter, label %parsevalue
delimiter:
  %delimiterbyte = trunc i32 %terminator to i8
  call void @j_buffer_byte(ptr %b, i8 %delimiterbyte)
  br label %parsevalue
parsevalue:
  %fulltoken = call ptr @j_buffer_value(ptr %b)
  %data = call ptr @in_data(ptr %fulltoken)
  %total = call i64 @in_len(ptr %fulltoken)
  %offset = alloca i64
  store i64 0, ptr %offset
  %value = call ptr @j_parse(ptr %data, i64 %total, ptr %offset)
  %valid = icmp ne ptr %value, null
  br i1 %valid, label %complete, label %error
complete:
  %used = load i64, ptr %offset
  %allused = icmp eq i64 %used, %length
  br i1 %allused, label %ambiguouscheck, label %trailing
trailing:
  %tag = load i32, ptr %value
  %numeric = icmp eq i32 %tag, 3
  %reason = select i1 %numeric, ptr @in_number, ptr @in_literal
  store ptr %reason, ptr @j_parse_error_message
  store i64 %total, ptr @j_parse_error_offset
  %trailingeof = icmp eq i32 %terminator, -1
  store i1 %trailingeof, ptr @j_parse_error_eof
  br label %error
ambiguouscheck:
  %valuetag = load i32, ptr %value
  %isnumber = icmp eq i32 %valuetag, 3
  %recordend = icmp eq i32 %terminator, 30
  %fileend = icmp eq i32 %terminator, -1
  %undelimited = or i1 %recordend, %fileend
  %ambiguous0 = and i1 %isnumber, %undelimited
  %ambiguous = and i1 %sequence, %ambiguous0
  br i1 %ambiguous, label %numbererror, label %success
numbererror:
  %causep = getelementptr %Input, ptr %reader, i32 0, i32 23
  %numberdepthp = getelementptr %Input, ptr %reader, i32 0, i32 21
  %numberdepth = load i64, ptr %numberdepthp
  %topnumber = icmp eq i64 %numberdepth, 0
  %numbercause = zext i1 %topnumber to i32
  store i32 %numbercause, ptr %causep
  call void @in_error_here(ptr %reader, ptr @in_abandoned, i1 false)
  ret ptr null
success:
  ret ptr %value
error:
  %message = load ptr, ptr @j_parse_error_message
  %errorpos = load i64, ptr @j_parse_error_offset
  %eof = load i1, ptr @j_parse_error_eof
  %past = icmp ugt i64 %errorpos, %total
  %bound = select i1 %past, i64 %total, i64 %errorpos
  br label %locate
locate:
  %i = phi i64 [ 0, %error ], [ %next, %locatebyte ]
  %line = phi i64 [ %startline, %error ], [ %nextline, %locatebyte ]
  %column = phi i64 [ %startcolumn, %error ], [ %nextcolumn, %locatebyte ]
  %done = icmp uge i64 %i, %bound
  br i1 %done, label %report, label %locatebyte
locatebyte:
  %p = getelementptr i8, ptr %data, i64 %i
  %c = load i8, ptr %p
  %lf = icmp eq i8 %c, 10
  %inc = zext i1 %lf to i64
  %nextline = add i64 %line, %inc
  %colinc = add i64 %column, 1
  %nextcolumn = select i1 %lf, i64 0, i64 %colinc
  %next = add i64 %i, 1
  br label %locate
report:
  call void @in_error(ptr %reader, ptr %message, i1 %eof, i64 %line, i64 %column)
  ret ptr null
failure:
  ret ptr null
}

define internal void @in_push_frame(ptr %reader, i32 %kind) {
entry:
  %depthp = getelementptr %Input, ptr %reader, i32 0, i32 21
  %capp = getelementptr %Input, ptr %reader, i32 0, i32 22
  %framesp = getelementptr %Input, ptr %reader, i32 0, i32 20
  %depth = load i64, ptr %depthp
  %capacity = load i64, ptr %capp
  %full = icmp uge i64 %depth, %capacity
  br i1 %full, label %grow, label %frame
grow:
  %twice = mul i64 %capacity, 2
  %small = icmp ult i64 %twice, 32
  %newcapacity = select i1 %small, i64 32, i64 %twice
  %bytes = mul i64 %newcapacity, 32
  %newframes = call ptr @j_alloc_permanent(i64 %bytes)
  %oldframes = load ptr, ptr %framesp
  %used = mul i64 %depth, 32
  call void @j_copy(ptr %newframes, ptr %oldframes, i64 %used)
  store ptr %newframes, ptr %framesp
  store i64 %newcapacity, ptr %capp
  br label %frame
frame:
  %f = call ptr @in_frame(ptr %reader, i64 %depth)
  store i32 %kind, ptr %f
  %array = icmp eq i32 %kind, 5
  %state = select i1 %array, i32 0, i32 3
  %sp = getelementptr %InputFrame, ptr %f, i32 0, i32 1
  store i32 %state, ptr %sp
  %np = getelementptr %InputFrame, ptr %f, i32 0, i32 2
  store i64 0, ptr %np
  %kp = getelementptr %InputFrame, ptr %f, i32 0, i32 3
  store ptr null, ptr %kp
  %vp = getelementptr %InputFrame, ptr %f, i32 0, i32 4
  %stream = call i1 @in_flag(ptr %reader, i32 1024)
  br i1 %stream, label %empty, label %newvalue
newvalue:
  br i1 %array, label %arrayvalue, label %objectvalue
arrayvalue:
  %av = call ptr @j_array()
  br label %storevalue
objectvalue:
  %ov = call ptr @j_object()
  br label %storevalue
empty:
  br label %storevalue
storevalue:
  %v = phi ptr [ %av, %arrayvalue ], [ %ov, %objectvalue ], [ null, %empty ]
  store ptr %v, ptr %vp
  %next = add i64 %depth, 1
  store i64 %next, ptr %depthp
  ret void
}

define internal void @in_commit(ptr %reader, ptr %value) {
entry:
  %depthp = getelementptr %Input, ptr %reader, i32 0, i32 21
  %depth = load i64, ptr %depthp
  %root = icmp eq i64 %depth, 0
  br i1 %root, label %done, label %parent
parent:
  %index = sub i64 %depth, 1
  %f = call ptr @in_frame(ptr %reader, i64 %index)
  %kind = load i32, ptr %f
  %array = icmp eq i32 %kind, 5
  %stream = call i1 @in_flag(ptr %reader, i32 1024)
  br i1 %stream, label %advance, label %append
append:
  %vp = getelementptr %InputFrame, ptr %f, i32 0, i32 4
  %container = load ptr, ptr %vp
  br i1 %array, label %arrayappend, label %objectappend
arrayappend:
  call void @j_push(ptr %container, ptr %value)
  br label %advance
objectappend:
  %kp = getelementptr %InputFrame, ptr %f, i32 0, i32 3
  %key = load ptr, ptr %kp
  call void @j_put(ptr %container, ptr %key, ptr %value)
  br label %advance
advance:
  %np = getelementptr %InputFrame, ptr %f, i32 0, i32 2
  %n = load i64, ptr %np
  %next = add i64 %n, 1
  store i64 %next, ptr %np
  %sp = getelementptr %InputFrame, ptr %f, i32 0, i32 1
  %state = select i1 %array, i32 1, i32 6
  store i32 %state, ptr %sp
  br label %done
done:
  ret void
}

define internal void @in_write(ptr %data, i64 %length) {
entry:
  %interrupted = load i32, ptr @mtrt_errno_EINTR
  %negative32 = sub i32 0, %interrupted
  %negative = sext i32 %negative32 to i64
  br label %loop
loop:
  %used = phi i64 [ 0, %entry ], [ %used, %retry ], [ %next, %advance ]
  %done = icmp uge i64 %used, %length
  br i1 %done, label %finish, label %send
send:
  %p = getelementptr i8, ptr %data, i64 %used
  %remaining = sub i64 %length, %used
  %n = call i64 @write(i32 2, ptr %p, i64 %remaining)
  %again = icmp eq i64 %n, %negative
  br i1 %again, label %retry, label %check
retry:
  br label %loop
check:
  %bad = icmp sle i64 %n, 0
  br i1 %bad, label %finish, label %advance
advance:
  %next = add i64 %used, %n
  br label %loop
finish:
  ret void
}

; Record separators recover damaged sequence records without retaining their bytes.
define internal i1 @in_seq_recover(ptr %reader) {
entry:
  %causep = getelementptr %Input, ptr %reader, i32 0, i32 23
  %cause = load i32, ptr %causep
  br label %scan
scan:
  %c = call i32 @in_peek(ptr %reader)
  %end = icmp slt i32 %c, 0
  br i1 %end, label %eof, label %character
character:
  call void @in_take(ptr %reader, i32 %c)
  %rs = icmp eq i32 %c, 30
  br i1 %rs, label %separator, label %scan
separator:
  %seqp = getelementptr %Input, ptr %reader, i32 0, i32 16
  store i1 true, ptr %seqp
  br label %report
eof:
  %io = icmp eq i32 %c, -2
  br i1 %io, label %ioerror, label %eofreason
eofreason:
  %abandoned = icmp ne i32 %cause, 0
  %endreason = select i1 %abandoned, ptr @in_abandoned, ptr @in_unfinished_seq
  br label %report
report:
  %reason = phi ptr [ @in_truncated, %separator ], [ %endreason, %eofreason ]
  call void @in_error_here(ptr %reader, ptr %reason, i1 false)
  %depthp = getelementptr %Input, ptr %reader, i32 0, i32 21
  store i64 0, ptr %depthp
  %defer = call i1 @in_flag(ptr %reader, i32 2)
  br i1 %defer, label %failed, label %warning
warning:
  %message = load ptr, ptr @j_error
  %data = call ptr @in_data(ptr %message)
  %length = call i64 @in_len(ptr %message)
  call void @in_write(ptr @in_warning, i64 26)
  call void @in_write(ptr %data, i64 %length)
  call void @in_write(ptr @in_nl, i64 1)
  store ptr null, ptr @j_error
  %statusp = getelementptr %Input, ptr %reader, i32 0, i32 11
  store i32 0, ptr %statusp
  ret i1 false
ioerror:
  call void @j_input_close(ptr %reader)
  br label %failed
failed:
  ret i1 true
}

define internal ptr @in_json(ptr %reader) {
entry:
  %stream = call i1 @in_flag(ptr %reader, i32 1024)
  %sequence = call i1 @in_flag(ptr %reader, i32 512)
  %depthp = getelementptr %Input, ptr %reader, i32 0, i32 21
  %causep = getelementptr %Input, ptr %reader, i32 0, i32 23
  br label %loop
loop:
  store i32 0, ptr %causep
  %active = call i1 @in_open(ptr %reader)
  br i1 %active, label %read, label %finish
read:
  %c = call i32 @in_peek(ptr %reader)
  %io = icmp eq i32 %c, -2
  br i1 %io, label %ioerror, label %bomcheck
bomcheck:
  %bomp = getelementptr %Input, ptr %reader, i32 0, i32 19
  %bomposition = load i8, ptr %bomp
  %bomdone = icmp uge i8 %bomposition, 3
  %bomeof = icmp eq i32 %c, -1
  %bypassbom = or i1 %bomdone, %bomeof
  br i1 %bypassbom, label %prefixcheck, label %bombyte
bombyte:
  %bomfirst = icmp eq i8 %bomposition, 0
  %bomsecond = icmp eq i8 %bomposition, 1
  %bomtail = select i1 %bomsecond, i32 187, i32 191
  %expectedbom = select i1 %bomfirst, i32 239, i32 %bomtail
  %bombmatch = icmp eq i32 %c, %expectedbom
  br i1 %bombmatch, label %bomadvance, label %bommismatch
bomadvance:
  %bomposp = getelementptr %Input, ptr %reader, i32 0, i32 6
  %byteposition = load i64, ptr %bomposp
  %nextbyte = add i64 %byteposition, 1
  store i64 %nextbyte, ptr %bomposp
  %nextbom = add i8 %bomposition, 1
  store i8 %nextbom, ptr %bomp
  br label %loop
bommismatch:
  store i8 3, ptr %bomp
  %ignorebom = or i1 %bomfirst, %sequence
  br i1 %ignorebom, label %prefixcheck, label %bomerror
bomerror:
  call void @j_fail(ptr @in_bom)
  store ptr @in_bom, ptr @j_parse_error_message
  store i1 false, ptr @j_parse_error_eof
  %bompath = call ptr @j_array()
  store ptr %bompath, ptr @j_parse_error_path
  %bomstatusp = getelementptr %Input, ptr %reader, i32 0, i32 11
  store i32 5, ptr %bomstatusp
  br label %problem
prefixcheck:
  %depth = load i64, ptr %depthp
  %seqp = getelementptr %Input, ptr %reader, i32 0, i32 16
  %started = load i1, ptr %seqp
  %notstarted = xor i1 %started, true
  %preamble = and i1 %sequence, %notstarted
  br i1 %preamble, label %prefix, label %endcheck
prefix:
  %prefixend = icmp eq i32 %c, -1
  br i1 %prefixend, label %prefixeof, label %prefixbyte
prefixbyte:
  call void @in_take(ptr %reader, i32 %c)
  %prefixrs = icmp eq i32 %c, 30
  br i1 %prefixrs, label %prefixstart, label %prefixdirty
prefixstart:
  store i1 true, ptr %seqp
  br label %loop
prefixdirty:
  %white = call i1 @in_white(i32 %c)
  %dirty = xor i1 %white, true
  %dirtyp = getelementptr %Input, ptr %reader, i32 0, i32 17
  %olddirty = load i1, ptr %dirtyp
  %newdirty = or i1 %olddirty, %dirty
  store i1 %newdirty, ptr %dirtyp
  br label %loop
prefixeof:
  %eofdirtyp = getelementptr %Input, ptr %reader, i32 0, i32 17
  %eofdirty = load i1, ptr %eofdirtyp
  br i1 %eofdirty, label %abandoned, label %nextfile
abandoned:
  store i32 2, ptr %causep
  store i1 false, ptr %eofdirtyp
  br label %problem
endcheck:
  %eof = icmp eq i32 %c, -1
  br i1 %eof, label %endfile, label %spacecheck
endfile:
  %incomplete = icmp ne i64 %depth, 0
  br i1 %incomplete, label %unfinished, label %nextfile
unfinished:
  call void @in_error_here(ptr %reader, ptr @in_unfinished, i1 true)
  br label %problem
nextfile:
  call void @j_input_close(ptr %reader)
  %closestatus = call i32 @j_input_status(ptr %reader)
  %closefailed = icmp ne i32 %closestatus, 0
  br i1 %closefailed, label %finish, label %loop
spacecheck:
  %whitespace = call i1 @in_white(i32 %c)
  br i1 %whitespace, label %skip, label %recordcheck
skip:
  call void @in_take(ptr %reader, i32 %c)
  br label %loop
recordcheck:
  %rs = icmp eq i32 %c, 30
  %recordsep = and i1 %sequence, %rs
  br i1 %recordsep, label %record, label %statecheck
record:
  %inside = icmp ne i64 %depth, 0
  br i1 %inside, label %problem, label %skip
statecheck:
  %top = icmp eq i64 %depth, 0
  br i1 %top, label %value, label %state
state:
  %fi = sub i64 %depth, 1
  %frame = call ptr @in_frame(ptr %reader, i64 %fi)
  %kind = load i32, ptr %frame
  %statep = getelementptr %InputFrame, ptr %frame, i32 0, i32 1
  %statevalue = load i32, ptr %statep
  switch i32 %statevalue, label %value [ i32 0, label %arrayfirst i32 1, label %separator i32 2, label %arraynext i32 3, label %objectfirst i32 4, label %colon i32 6, label %separator i32 7, label %objectnext ]
arrayfirst:
  %emptyarray = icmp eq i32 %c, 93
  br i1 %emptyarray, label %containerclose, label %value
arraynext:
  %badarrayclose = icmp eq i32 %c, 93
  br i1 %badarrayclose, label %arrayelementerror, label %value
arrayelementerror:
  call void @in_take(ptr %reader, i32 %c)
  call void @in_error_here(ptr %reader, ptr @in_array_element, i1 false)
  br label %problem
objectfirst:
  %emptyobject = icmp eq i32 %c, 125
  br i1 %emptyobject, label %containerclose, label %objectkey
objectnext:
  %badobjectclose = icmp eq i32 %c, 125
  br i1 %badobjectclose, label %objectpairerror, label %objectkey
objectpairerror:
  call void @in_take(ptr %reader, i32 %c)
  call void @in_error_here(ptr %reader, ptr @in_object_pair, i1 false)
  br label %problem
objectkey:
  %keyobject = icmp eq i32 %c, 123
  %keyarray = icmp eq i32 %c, 91
  %keycontainer = or i1 %keyobject, %keyarray
  br i1 %keycontainer, label %containerkeyerror, label %parsekey
containerkeyerror:
  %firstkey = icmp eq i32 %statevalue, 3
  %arrayreason = select i1 %firstkey, ptr @in_object_array, ptr @in_comma_array
  %objectreason = select i1 %firstkey, ptr @in_object_object, ptr @in_comma_object
  %streamreason = select i1 %keyarray, ptr %arrayreason, ptr %objectreason
  %keyreason = select i1 %stream, ptr %streamreason, ptr @in_keys
  call void @in_take(ptr %reader, i32 %c)
  call void @in_error_here(ptr %reader, ptr %keyreason, i1 false)
  br label %problem
parsekey:
  %key = call ptr @in_token(ptr %reader)
  %keyfailed = icmp eq ptr %key, null
  br i1 %keyfailed, label %problem, label %keytype
keytype:
  %keytag = load i32, ptr %key
  %stringkey = icmp eq i32 %keytag, 4
  br i1 %stringkey, label %storekey, label %keyerror
keyerror:
  call void @in_error_here(ptr %reader, ptr @in_keys, i1 false)
  br label %problem
storekey:
  %keyp = getelementptr %InputFrame, ptr %frame, i32 0, i32 3
  store ptr %key, ptr %keyp
  store i32 4, ptr %statep
  br label %loop
colon:
  call void @in_take(ptr %reader, i32 %c)
  %iscolon = icmp eq i32 %c, 58
  br i1 %iscolon, label %colonvalue, label %colonerror
colonvalue:
  store i32 5, ptr %statep
  br label %loop
colonerror:
  call void @in_error_here(ptr %reader, ptr @in_parts, i1 false)
  br label %problem
separator:
  %arraykind = icmp eq i32 %kind, 5
  %closechar = select i1 %arraykind, i32 93, i32 125
  %isclose = icmp eq i32 %c, %closechar
  br i1 %isclose, label %containerclose, label %commacheck
commacheck:
  %comma = icmp eq i32 %c, 44
  br i1 %comma, label %commaadvance, label %separatorerror
commaadvance:
  call void @in_take(ptr %reader, i32 %c)
  %nextstate = select i1 %arraykind, i32 2, i32 7
  store i32 %nextstate, ptr %statep
  br label %loop
separatorerror:
  call void @in_take(ptr %reader, i32 %c)
  call void @in_error_here(ptr %reader, ptr @in_separator, i1 false)
  br label %problem
containerclose:
  call void @in_take(ptr %reader, i32 %c)
  %countp = getelementptr %InputFrame, ptr %frame, i32 0, i32 2
  %count = load i64, ptr %countp
  %empty = icmp eq i64 %count, 0
  %vp = getelementptr %InputFrame, ptr %frame, i32 0, i32 4
  %container = load ptr, ptr %vp
  %nonempty = xor i1 %empty, true
  %closingevent = and i1 %stream, %nonempty
  br i1 %closingevent, label %streamclose, label %popcontainer
streamclose:
  %lastpath = call ptr @in_path(ptr %reader)
  store i64 %fi, ptr %depthp
  call void @in_commit(ptr %reader, ptr null)
  %ending = call ptr @j_array()
  call void @j_push(ptr %ending, ptr %lastpath)
  br label %returned
popcontainer:
  store i64 %fi, ptr %depthp
  br i1 %stream, label %emptyvalue, label %containerready
emptyvalue:
  %closedarray = icmp eq i32 %kind, 5
  br i1 %closedarray, label %emptyarrayvalue, label %emptyobjectvalue
emptyarrayvalue:
  %emptyav = call ptr @j_array()
  br label %containerready
emptyobjectvalue:
  %emptyov = call ptr @j_object()
  br label %containerready
containerready:
  %closedvalue = phi ptr [ %container, %popcontainer ], [ %emptyav, %emptyarrayvalue ], [ %emptyov, %emptyobjectvalue ]
  br label %accept
value:
  switch i32 %c, label %scalar [ i32 91, label %openarray i32 123, label %openobject i32 93, label %unmatchedarray i32 125, label %unmatchedobject i32 44, label %unexpected i32 58, label %unexpected ]
openarray:
  br label %opencontainer
openobject:
  br label %opencontainer
opencontainer:
  %newkind = phi i32 [ 5, %openarray ], [ 6, %openobject ]
  %toodeep = icmp uge i64 %depth, 10000
  br i1 %toodeep, label %deptherror, label %pushcontainer
pushcontainer:
  call void @in_take(ptr %reader, i32 %c)
  call void @in_push_frame(ptr %reader, i32 %newkind)
  br label %loop
deptherror:
  call void @in_error_here(ptr %reader, ptr @in_depth, i1 false)
  br label %problem
unmatchedarray:
  %atop0 = icmp eq i64 %depth, 0
  %atop = and i1 %stream, %atop0
  %areason = select i1 %atop, ptr @in_top_array, ptr @in_unmatched_array
  call void @in_take(ptr %reader, i32 %c)
  call void @in_error_here(ptr %reader, ptr %areason, i1 false)
  br label %problem
unmatchedobject:
  %otop0 = icmp eq i64 %depth, 0
  %otop = and i1 %stream, %otop0
  %oreason = select i1 %otop, ptr @in_top_object, ptr @in_unmatched_object
  call void @in_take(ptr %reader, i32 %c)
  call void @in_error_here(ptr %reader, ptr %oreason, i1 false)
  br label %problem
unexpected:
  call void @in_take(ptr %reader, i32 %c)
  call void @in_error_here(ptr %reader, ptr @in_number, i1 false)
  br label %problem
scalar:
  %atom = call ptr @in_token(ptr %reader)
  %atomfailed = icmp eq ptr %atom, null
  br i1 %atomfailed, label %problem, label %accept
accept:
  %accepted = phi ptr [ %closedvalue, %containerready ], [ %atom, %scalar ]
  br i1 %stream, label %streampair, label %commitvalue
streampair:
  %path = call ptr @in_path(ptr %reader)
  %pair = call ptr @j_array()
  call void @j_push(ptr %pair, ptr %path)
  call void @j_push(ptr %pair, ptr %accepted)
  call void @in_commit(ptr %reader, ptr %accepted)
  br label %returned
commitvalue:
  call void @in_commit(ptr %reader, ptr %accepted)
  %afterdepth = load i64, ptr %depthp
  %completedroot = icmp eq i64 %afterdepth, 0
  br i1 %completedroot, label %returned, label %loop
returned:
  %result = phi ptr [ %ending, %streamclose ], [ %pair, %streampair ], [ %accepted, %commitvalue ]
  %lineno = getelementptr %Input, ptr %reader, i32 0, i32 8
  %line = load i64, ptr %lineno
  %lastp = getelementptr %Input, ptr %reader, i32 0, i32 10
  store i64 %line, ptr %lastp
  ret ptr %result
problem:
  %problemstatus = call i32 @j_input_status(ptr %reader)
  %problemio = icmp eq i32 %problemstatus, 2
  br i1 %problemio, label %ioerror, label %problemkind
problemkind:
  br i1 %sequence, label %recover, label %ordinaryerror
recover:
  %recoverfailed = call i1 @in_seq_recover(ptr %reader)
  br i1 %recoverfailed, label %finish, label %loop
ordinaryerror:
  %errorvalue = load ptr, ptr @j_error
  %errorpath = load ptr, ptr @j_parse_error_path
  call void @j_input_close(ptr %reader)
  store i64 0, ptr %depthp
  %streamerrors = call i1 @in_flag(ptr %reader, i32 16384)
  br i1 %streamerrors, label %errorevent, label %finish
errorevent:
  %errorpair = call ptr @j_array()
  call void @j_push(ptr %errorpair, ptr %errorvalue)
  call void @j_push(ptr %errorpair, ptr %errorpath)
  store ptr null, ptr @j_error
  %clearstatus = getelementptr %Input, ptr %reader, i32 0, i32 11
  store i32 0, ptr %clearstatus
  ret ptr %errorpair
ioerror:
  call void @j_input_close(ptr %reader)
  store i64 0, ptr %depthp
  br label %finish
finish:
  ret ptr null
}

define internal ptr @in_raw_line(ptr %reader) {
entry:
  br label %file
file:
  %active = call i1 @in_open(ptr %reader)
  br i1 %active, label %begin, label %finish
begin:
  %b = call ptr @j_buffer_new()
  %linep = getelementptr %Input, ptr %reader, i32 0, i32 8
  %line = load i64, ptr %linep
  br label %loop
loop:
  %used = phi i64 [ 0, %begin ], [ %next, %byte ]
  %c = call i32 @in_peek(ptr %reader)
  %eof = icmp eq i32 %c, -1
  br i1 %eof, label %endfile, label %check
check:
  %io = icmp eq i32 %c, -2
  br i1 %io, label %error, label %character
character:
  call void @in_take(ptr %reader, i32 %c)
  %lf = icmp eq i32 %c, 10
  br i1 %lf, label %value, label %byte
byte:
  %small = trunc i32 %c to i8
  call void @j_buffer_byte(ptr %b, i8 %small)
  %next = add i64 %used, 1
  br label %loop
endfile:
  call void @j_input_close(ptr %reader)
  %status = call i32 @j_input_status(ptr %reader)
  %bad = icmp ne i32 %status, 0
  br i1 %bad, label %finish, label %tailcheck
tailcheck:
  %tail = icmp ne i64 %used, 0
  br i1 %tail, label %value, label %file
value:
  %linevalue = call ptr @j_buffer_value(ptr %b)
  %lastp = getelementptr %Input, ptr %reader, i32 0, i32 10
  store i64 %line, ptr %lastp
  ret ptr %linevalue
error:
  call void @j_input_close(ptr %reader)
  br label %finish
finish:
  ret ptr null
}

define internal ptr @in_one(ptr %reader) {
entry:
  %raw = call i1 @in_flag(ptr %reader, i32 1)
  br i1 %raw, label %line, label %json
line:
  %r = call ptr @in_raw_line(ptr %reader)
  ret ptr %r
json:
  %j = call ptr @in_json(ptr %reader)
  ret ptr %j
}

define ptr @j_input_next(ptr %reader) {
entry:
  %statusp = getelementptr %Input, ptr %reader, i32 0, i32 11
  store i32 0, ptr %statusp
  %slurp = call i1 @in_flag(ptr %reader, i32 4)
  br i1 %slurp, label %slurpcheck, label %one
one:
  %value = call ptr @in_one(ptr %reader)
  ret ptr %value
slurpcheck:
  %slurpedp = getelementptr %Input, ptr %reader, i32 0, i32 15
  %slurped = load i1, ptr %slurpedp
  br i1 %slurped, label %finish, label %slurpbegin
slurpbegin:
  %accp = getelementptr %Input, ptr %reader, i32 0, i32 24
  %oldacc = load ptr, ptr %accp
  %haveacc = icmp ne ptr %oldacc, null
  %raw = call i1 @in_flag(ptr %reader, i32 1)
  br i1 %raw, label %rawbegin, label %jsonbegin
jsonbegin:
  br i1 %haveacc, label %jsonresume, label %jsonnew
jsonnew:
  %newall = call ptr @j_array()
  store ptr %newall, ptr %accp
  br label %jsonresume
jsonresume:
  %all = phi ptr [ %oldacc, %jsonbegin ], [ %newall, %jsonnew ]
  br label %jsonloop
jsonloop:
  %item = call ptr @in_one(ptr %reader)
  %end = icmp eq ptr %item, null
  br i1 %end, label %jsondone, label %jsonappend
jsonappend:
  call void @j_push(ptr %all, ptr %item)
  br label %jsonloop
jsondone:
  %jsonstatus = load i32, ptr %statusp
  %jsonbad = icmp ne i32 %jsonstatus, 0
  br i1 %jsonbad, label %finish, label %jsonresult
jsonresult:
  store i1 true, ptr %slurpedp
  store ptr null, ptr %accp
  ret ptr %all
rawbegin:
  br i1 %haveacc, label %rawresume, label %rawnew
rawnew:
  %newb = call ptr @j_buffer_new()
  store ptr %newb, ptr %accp
  br label %rawresume
rawresume:
  %b = phi ptr [ %oldacc, %rawbegin ], [ %newb, %rawnew ]
  br label %rawfile
rawfile:
  %active = call i1 @in_open(ptr %reader)
  br i1 %active, label %rawloop, label %rawdone
rawloop:
  %c = call i32 @in_peek(ptr %reader)
  %raweof = icmp eq i32 %c, -1
  br i1 %raweof, label %rawclose, label %rawcheck
rawcheck:
  %rawio = icmp eq i32 %c, -2
  br i1 %rawio, label %rawerror, label %rawbyte
rawbyte:
  call void @in_take(ptr %reader, i32 %c)
  %byte = trunc i32 %c to i8
  call void @j_buffer_byte(ptr %b, i8 %byte)
  br label %rawloop
rawclose:
  call void @j_input_close(ptr %reader)
  %closestatus = load i32, ptr %statusp
  %closebad = icmp ne i32 %closestatus, 0
  br i1 %closebad, label %finish, label %rawfile
rawdone:
  %rawstatus = load i32, ptr %statusp
  %rawbad = icmp ne i32 %rawstatus, 0
  br i1 %rawbad, label %finish, label %rawresult
rawresult:
  store i1 true, ptr %slurpedp
  store ptr null, ptr %accp
  %rawvalue = call ptr @j_buffer_value(ptr %b)
  %lp = getelementptr %Input, ptr %reader, i32 0, i32 8
  %lastline = load i64, ptr %lp
  %lastp = getelementptr %Input, ptr %reader, i32 0, i32 10
  store i64 %lastline, ptr %lastp
  ret ptr %rawvalue
rawerror:
  call void @j_input_close(ptr %reader)
  br label %finish
finish:
  ret ptr null
}

; The cursor, byte buffer and frame storage are permanent. Only JSON edges move.
define void @j_input_trace(ptr %reader) {
entry:
  %files = load ptr, ptr %reader
  %newfiles = call ptr @j_gc_value(ptr %files)
  store ptr %newfiles, ptr %reader
  %namep = getelementptr %Input, ptr %reader, i32 0, i32 4
  %name = load ptr, ptr %namep
  %newname = call ptr @j_gc_value(ptr %name)
  store ptr %newname, ptr %namep
  %depthp = getelementptr %Input, ptr %reader, i32 0, i32 21
  %depth = load i64, ptr %depthp
  %accp = getelementptr %Input, ptr %reader, i32 0, i32 24
  %acc = load ptr, ptr %accp
  %hasacc = icmp ne ptr %acc, null
  br i1 %hasacc, label %accumulator, label %frames
accumulator:
  %raw = call i1 @in_flag(ptr %reader, i32 1)
  br i1 %raw, label %rawbuffer, label %jsonacc
jsonacc:
  %newacc = call ptr @j_gc_value(ptr %acc)
  store ptr %newacc, ptr %accp
  br label %frames
rawbuffer:
  %isnew = alloca i1
  %newbuffer = call ptr @j_gc_copy(ptr %acc, i64 24, ptr %isnew)
  store ptr %newbuffer, ptr %accp
  %fresh = load i1, ptr %isnew
  br i1 %fresh, label %rawdata, label %frames
rawdata:
  %bytes = load ptr, ptr %newbuffer
  %capacityp = getelementptr %InputBuffer, ptr %newbuffer, i32 0, i32 2
  %capacity = load i64, ptr %capacityp
  %newbytes = call ptr @j_gc_copy(ptr %bytes, i64 %capacity, ptr %isnew)
  store ptr %newbytes, ptr %newbuffer
  br label %frames
frames:
  br label %loop
loop:
  %i = phi i64 [ 0, %frames ], [ %next, %frame ]
  %done = icmp uge i64 %i, %depth
  br i1 %done, label %finish, label %frame
frame:
  %f = call ptr @in_frame(ptr %reader, i64 %i)
  %kp = getelementptr %InputFrame, ptr %f, i32 0, i32 3
  %key = load ptr, ptr %kp
  %newkey = call ptr @j_gc_value(ptr %key)
  store ptr %newkey, ptr %kp
  %vp = getelementptr %InputFrame, ptr %f, i32 0, i32 4
  %value = load ptr, ptr %vp
  %newvalue = call ptr @j_gc_value(ptr %value)
  store ptr %newvalue, ptr %vp
  %next = add i64 %i, 1
  br label %loop
finish:
  ret void
}
