%RP = type { ptr, i64, i64, i32, i32, ptr }
%RX = type { i32, i32, i32, i32, ptr, ptr, ptr }
%RC = type { ptr, ptr, ptr, i64, i32, i32, ptr }
%RM = type { i64, i64, ptr }

@j_error = external global ptr
@rx_names = private constant [47 x i8] c"match\00test\00capture\00scan\00sub\00gsub\00splits\00split\00\00"
@rx_bad = private constant [31 x i8] c"Regex failure: invalid pattern\00"
@rx_unsupported = private constant [46 x i8] c"Regex failure: unsupported regular expression\00"
@rx_flagsbad = private constant [38 x i8] c"Regex failure: invalid modifier flags\00"
@rx_stringbad = private constant [36 x i8] c"Regular expressions require strings\00"
@rx_offset = private constant [7 x i8] c"offset\00"
@rx_length = private constant [7 x i8] c"length\00"
@rx_string = private constant [7 x i8] c"string\00"
@rx_captures = private constant [9 x i8] c"captures\00"
@rx_name = private constant [5 x i8] c"name\00"
@rx_empty = private constant [1 x i8] zeroinitializer
@rx_limit = private constant [44 x i8] c"Regex failure: matching depth limit reached\00"

declare ptr @j_alloc(i64)
declare ptr @j_null()
declare ptr @j_bool(i1)
declare ptr @j_num(double)
declare ptr @j_str(ptr, i64)
declare ptr @j_cstr(ptr)
declare ptr @j_array()
declare void @j_push(ptr, ptr)
declare ptr @j_at(ptr, i64)
declare ptr @j_object()
declare void @j_put(ptr, ptr, ptr)
declare ptr @j_get(ptr, ptr)
declare ptr @j_binary(i32, ptr, ptr)
declare void @j_fail(ptr)
declare i32 @j_utf8_next(ptr, i64, ptr)
declare ptr @j_eval(ptr, ptr, ptr)
declare i32 @b_tag(ptr)
declare i64 @b_len(ptr)
declare ptr @b_data(ptr)
declare double @b_number(ptr)
declare ptr @b_one(ptr)
declare ptr @b_arg(ptr, i64, ptr, ptr)
declare i32 @b_find(ptr, ptr)
declare void @b_extend(ptr, ptr)
declare void @llvm.memcpy.p0.p0.i64(ptr, ptr, i64, i1)

define ptr @j_regex_names() {
  ret ptr @rx_names
}

define i1 @j_regex_known(ptr %name, i64 %arity) {
entry:
  %id = call i32 @b_find(ptr %name, ptr @rx_names)
  %known = icmp sge i32 %id, 0
  %sub = icmp eq i32 %id, 4
  %gsub = icmp eq i32 %id, 5
  %replace = or i1 %sub, %gsub
  %min = select i1 %replace, i64 2, i64 1
  %max = select i1 %replace, i64 3, i64 2
  %lower = icmp uge i64 %arity, %min
  %upper = icmp ule i64 %arity, %max
  %bounds = and i1 %lower, %upper
  %valid = and i1 %known, %bounds
  ret i1 %valid
}

define internal ptr @rx_node(i32 %op, i32 %value, ptr %a, ptr %b, ptr %data) {
  %n = call ptr @j_alloc(i64 40)
  store i32 %op, ptr %n
  %vp = getelementptr %RX, ptr %n, i32 0, i32 1
  store i32 %value, ptr %vp
  %ap = getelementptr %RX, ptr %n, i32 0, i32 4
  store ptr %a, ptr %ap
  %bp = getelementptr %RX, ptr %n, i32 0, i32 5
  store ptr %b, ptr %bp
  %dp = getelementptr %RX, ptr %n, i32 0, i32 6
  store ptr %data, ptr %dp
  ret ptr %n
}

define internal i32 @rx_peek(ptr %p) {
entry:
  %dp = getelementptr %RP, ptr %p, i32 0, i32 0
  %data = load ptr, ptr %dp
  %np = getelementptr %RP, ptr %p, i32 0, i32 1
  %n = load i64, ptr %np
  %ip = getelementptr %RP, ptr %p, i32 0, i32 2
  %fp = getelementptr %RP, ptr %p, i32 0, i32 3
  %flags = load i32, ptr %fp
  %xb = and i32 %flags, 4
  %extended = icmp ne i32 %xb, 0
  br label %loop
loop:
  %i = load i64, ptr %ip
  %end = icmp uge i64 %i, %n
  br i1 %end, label %eof, label %byte
byte:
  %cp = getelementptr i8, ptr %data, i64 %i
  %c = load i8, ptr %cp
  %ci = zext i8 %c to i32
  br i1 %extended, label %ext, label %done
ext:
  %space = icmp eq i8 %c, 32
  %low = icmp uge i8 %c, 9
  %high = icmp ule i8 %c, 13
  %ws = and i1 %low, %high
  %white = or i1 %space, %ws
  br i1 %white, label %advance, label %commentcheck
advance:
  %next = add i64 %i, 1
  store i64 %next, ptr %ip
  br label %loop
commentcheck:
  %hash = icmp eq i8 %c, 35
  br i1 %hash, label %comment, label %done
comment:
  %j = phi i64 [ %i, %commentcheck ], [ %jn, %commentnext ]
  %je = icmp uge i64 %j, %n
  br i1 %je, label %commentend, label %commentbyte
commentbyte:
  %jp = getelementptr i8, ptr %data, i64 %j
  %jc = load i8, ptr %jp
  %lf = icmp eq i8 %jc, 10
  br i1 %lf, label %commentend, label %commentnext
commentnext:
  %jn = add i64 %j, 1
  br label %comment
commentend:
  store i64 %j, ptr %ip
  br label %loop
done:
  ret i32 %ci
eof:
  ret i32 -1
}

define internal void @rx_advance(ptr %p) {
  %ip = getelementptr %RP, ptr %p, i32 0, i32 2
  %i = load i64, ptr %ip
  %next = add i64 %i, 1
  store i64 %next, ptr %ip
  ret void
}

define internal i32 @rx_take(ptr %p) {
  %data = load ptr, ptr %p
  %np = getelementptr %RP, ptr %p, i32 0, i32 1
  %n = load i64, ptr %np
  %ip = getelementptr %RP, ptr %p, i32 0, i32 2
  %c = call i32 @j_utf8_next(ptr %data, i64 %n, ptr %ip)
  ret i32 %c
}

define internal i32 @rx_integer(ptr %p) {
entry:
  br label %loop
loop:
  %n = phi i32 [ 0, %entry ], [ %next, %digit ]
  %c = call i32 @rx_peek(ptr %p)
  %d = sub i32 %c, 48
  %valid = icmp ult i32 %d, 10
  br i1 %valid, label %digit, label %done
digit:
  call void @rx_advance(ptr %p)
  %times = mul i32 %n, 10
  %next = add i32 %times, %d
  br label %loop
done:
  ret i32 %n
}

define internal ptr @rx_atom(ptr %p) {
entry:
  %c = call i32 @rx_peek(ptr %p)
  switch i32 %c, label %literal [
    i32 40, label %group i32 91, label %class i32 46, label %dot
    i32 94, label %start i32 36, label %end i32 92, label %escape
    i32 42, label %invalid i32 43, label %invalid i32 63, label %invalid
  ]
literal:
  %char = call i32 @rx_take(ptr %p)
  %lit = call ptr @rx_node(i32 1, i32 %char, ptr null, ptr null, ptr null)
  ret ptr %lit
dot:
  call void @rx_advance(ptr %p)
  %dotnode = call ptr @rx_node(i32 2, i32 0, ptr null, ptr null, ptr null)
  ret ptr %dotnode
start:
  call void @rx_advance(ptr %p)
  %startnode = call ptr @rx_node(i32 8, i32 0, ptr null, ptr null, ptr null)
  ret ptr %startnode
end:
  call void @rx_advance(ptr %p)
  %endnode = call ptr @rx_node(i32 9, i32 0, ptr null, ptr null, ptr null)
  ret ptr %endnode
escape:
  call void @rx_advance(ptr %p)
  %esc = call i32 @rx_take(ptr %p)
  switch i32 %esc, label %escapedliteral [
    i32 100, label %category i32 68, label %category i32 119, label %category
    i32 87, label %category i32 115, label %category i32 83, label %category
    i32 98, label %boundary i32 66, label %boundary
    i32 65, label %absolute_start i32 122, label %absolute_end i32 90, label %absolute_end
    i32 110, label %lf i32 114, label %cr i32 116, label %tab
    i32 102, label %ff i32 118, label %vt i32 112, label %unsupported i32 80, label %unsupported
  ]
category:
  %catnode = call ptr @rx_node(i32 13, i32 %esc, ptr null, ptr null, ptr null)
  ret ptr %catnode
boundary:
  %boundnode = call ptr @rx_node(i32 10, i32 %esc, ptr null, ptr null, ptr null)
  ret ptr %boundnode
absolute_start:
  %as = call ptr @rx_node(i32 8, i32 1, ptr null, ptr null, ptr null)
  ret ptr %as
absolute_end:
  %ae = call ptr @rx_node(i32 9, i32 1, ptr null, ptr null, ptr null)
  ret ptr %ae
lf:
  br label %esclit
cr:
  br label %esclit
tab:
  br label %esclit
ff:
  br label %esclit
vt:
  br label %esclit
escapedliteral:
  %backref = icmp uge i32 %esc, 49
  %backrefmax = icmp ule i32 %esc, 57
  %isref = and i1 %backref, %backrefmax
  br i1 %isref, label %reference, label %esclit
reference:
  %ref = sub i32 %esc, 49
  %refnode = call ptr @rx_node(i32 14, i32 %ref, ptr null, ptr null, ptr null)
  ret ptr %refnode
esclit:
  %ec = phi i32 [ 10, %lf ], [ 13, %cr ], [ 9, %tab ], [ 12, %ff ], [ 11, %vt ], [ %esc, %escapedliteral ]
  %en = call ptr @rx_node(i32 1, i32 %ec, ptr null, ptr null, ptr null)
  ret ptr %en
class:
  call void @rx_advance(ptr %p)
  %ip = getelementptr %RP, ptr %p, i32 0, i32 2
  %begin = load i64, ptr %ip
  %data = load ptr, ptr %p
  %np = getelementptr %RP, ptr %p, i32 0, i32 1
  %len = load i64, ptr %np
  br label %classloop
classloop:
  %i = phi i64 [ %begin, %class ], [ %next, %classnext ]
  %escaped = phi i1 [ false, %class ], [ %nescaped, %classnext ]
  %ceof = icmp uge i64 %i, %len
  br i1 %ceof, label %invalid, label %classchar
classchar:
  %cp = getelementptr i8, ptr %data, i64 %i
  %cb = load i8, ptr %cp
  %closing = icmp eq i8 %cb, 93
  %notesc = xor i1 %escaped, true
  %close = and i1 %closing, %notesc
  br i1 %close, label %classdone, label %classnext
classnext:
  %slash = icmp eq i8 %cb, 92
  %nescaped = and i1 %slash, %notesc
  %next = add i64 %i, 1
  br label %classloop
classdone:
  %after = add i64 %i, 1
  store i64 %after, ptr %ip
  %base = getelementptr i8, ptr %data, i64 %begin
  %clen = sub i64 %i, %begin
  %classstr = call ptr @j_str(ptr %base, i64 %clen)
  %classnode = call ptr @rx_node(i32 3, i32 0, ptr null, ptr null, ptr %classstr)
  ret ptr %classnode
group:
  call void @rx_advance(ptr %p)
  %q = call i32 @rx_peek(ptr %p)
  %special = icmp eq i32 %q, 63
  br i1 %special, label %groupmod, label %capture
groupmod:
  call void @rx_advance(ptr %p)
  %mod = call i32 @rx_peek(ptr %p)
  call void @rx_advance(ptr %p)
  switch i32 %mod, label %unsupported [ i32 58, label %noncapture i32 60, label %namedcapture i32 61, label %ahead i32 33, label %notahead ]
namedcapture:
  %nip = getelementptr %RP, ptr %p, i32 0, i32 2
  %ns = load i64, ptr %nip
  br label %nameloop
nameloop:
  %nc = call i32 @rx_peek(ptr %p)
  %ne = icmp eq i32 %nc, 62
  br i1 %ne, label %nameend, label %namenext
namenext:
  %nmissing = icmp slt i32 %nc, 0
  br i1 %nmissing, label %invalid, label %nameadvance
nameadvance:
  call void @rx_advance(ptr %p)
  br label %nameloop
nameend:
  %nepos = load i64, ptr %nip
  %nd = load ptr, ptr %p
  %nb = getelementptr i8, ptr %nd, i64 %ns
  %nn = sub i64 %nepos, %ns
  %name = call ptr @j_str(ptr %nb, i64 %nn)
  call void @rx_advance(ptr %p)
  br label %register
capture:
  %nullname = call ptr @j_null()
  br label %register
register:
  %capname = phi ptr [ %name, %nameend ], [ %nullname, %capture ]
  %countp = getelementptr %RP, ptr %p, i32 0, i32 4
  %count = load i32, ptr %countp
  %countnext = add i32 %count, 1
  store i32 %countnext, ptr %countp
  %namesp = getelementptr %RP, ptr %p, i32 0, i32 5
  %names = load ptr, ptr %namesp
  call void @j_push(ptr %names, ptr %capname)
  br label %groupbody
noncapture:
  br label %groupbody
ahead:
  br label %groupbody
notahead:
  br label %groupbody
groupbody:
  %groupkind = phi i32 [ 7, %register ], [ 0, %noncapture ], [ 11, %ahead ], [ 12, %notahead ]
  %groupindex = phi i32 [ %count, %register ], [ 0, %noncapture ], [ 0, %ahead ], [ 0, %notahead ]
  %body = call ptr @rx_expr(ptr %p)
  %closer = call i32 @rx_peek(ptr %p)
  %closed = icmp eq i32 %closer, 41
  br i1 %closed, label %groupdone, label %invalid
groupdone:
  call void @rx_advance(ptr %p)
  %plain = icmp eq i32 %groupkind, 0
  br i1 %plain, label %plaindone, label %wrapgroup
plaindone:
  ret ptr %body
wrapgroup:
  %gn = call ptr @rx_node(i32 %groupkind, i32 %groupindex, ptr %body, ptr null, ptr null)
  ret ptr %gn
unsupported:
  call void @j_fail(ptr @rx_unsupported)
  %un = call ptr @rx_node(i32 0, i32 0, ptr null, ptr null, ptr null)
  ret ptr %un
invalid:
  call void @j_fail(ptr @rx_bad)
  %badn = call ptr @rx_node(i32 0, i32 0, ptr null, ptr null, ptr null)
  ret ptr %badn
}

define internal ptr @rx_sequence(ptr %p) {
entry:
  br label %loop
loop:
  %seq = phi ptr [ null, %entry ], [ %joined, %append ]
  %c = call i32 @rx_peek(ptr %p)
  %eof = icmp slt i32 %c, 0
  %close = icmp eq i32 %c, 41
  %alt = icmp eq i32 %c, 124
  %stop0 = or i1 %eof, %close
  %stop = or i1 %stop0, %alt
  %error = load ptr, ptr @j_error
  %err = icmp ne ptr %error, null
  %done = or i1 %stop, %err
  br i1 %done, label %end, label %atom
atom:
  %an = call ptr @rx_atom(ptr %p)
  %q = call i32 @rx_peek(ptr %p)
  switch i32 %q, label %unquantified [ i32 42, label %star i32 43, label %plus i32 63, label %optional i32 123, label %bounded ]
star:
  call void @rx_advance(ptr %p)
  br label %repeat
plus:
  call void @rx_advance(ptr %p)
  br label %repeat
optional:
  call void @rx_advance(ptr %p)
  br label %repeat
bounded:
  call void @rx_advance(ptr %p)
  %min = call i32 @rx_integer(ptr %p)
  %sep = call i32 @rx_peek(ptr %p)
  %comma = icmp eq i32 %sep, 44
  br i1 %comma, label %boundmax, label %boundsame
boundmax:
  call void @rx_advance(ptr %p)
  %maxchar = call i32 @rx_peek(ptr %p)
  %openbound = icmp eq i32 %maxchar, 125
  br i1 %openbound, label %boundopen, label %boundnumber
boundnumber:
  %maxnumber = call i32 @rx_integer(ptr %p)
  br label %boundend
boundopen:
  br label %boundend
boundsame:
  br label %boundend
boundend:
  %max = phi i32 [ %maxnumber, %boundnumber ], [ -1, %boundopen ], [ %min, %boundsame ]
  %bc = call i32 @rx_peek(ptr %p)
  %brace = icmp eq i32 %bc, 125
  br i1 %brace, label %bounddone, label %invalid
bounddone:
  call void @rx_advance(ptr %p)
  br label %repeat
repeat:
  %lo = phi i32 [ 0, %star ], [ 1, %plus ], [ 0, %optional ], [ %min, %bounddone ]
  %hi = phi i32 [ -1, %star ], [ -1, %plus ], [ 1, %optional ], [ %max, %bounddone ]
  %lazychar = call i32 @rx_peek(ptr %p)
  %lazy = icmp eq i32 %lazychar, 63
  br i1 %lazy, label %lazynext, label %repeatnode
lazynext:
  call void @rx_advance(ptr %p)
  br label %repeatnode
repeatnode:
  %lazyflag = zext i1 %lazy to i32
  %rn = call ptr @rx_node(i32 6, i32 %lazyflag, ptr %an, ptr null, ptr null)
  %lop = getelementptr %RX, ptr %rn, i32 0, i32 2
  %hip = getelementptr %RX, ptr %rn, i32 0, i32 3
  store i32 %lo, ptr %lop
  store i32 %hi, ptr %hip
  br label %append
unquantified:
  br label %append
append:
  %item = phi ptr [ %an, %unquantified ], [ %rn, %repeatnode ]
  %joined = call ptr @rx_node(i32 4, i32 0, ptr %seq, ptr %item, ptr null)
  br label %loop
invalid:
  call void @j_fail(ptr @rx_bad)
  br label %end
end:
  ret ptr %seq
}

define internal ptr @rx_expr(ptr %p) {
entry:
  %left = call ptr @rx_sequence(ptr %p)
  %c = call i32 @rx_peek(ptr %p)
  %alt = icmp eq i32 %c, 124
  br i1 %alt, label %alternation, label %done
alternation:
  call void @rx_advance(ptr %p)
  %right = call ptr @rx_expr(ptr %p)
  %node = call ptr @rx_node(i32 5, i32 0, ptr %left, ptr %right, ptr null)
  ret ptr %node
done:
  ret ptr %left
}

define internal ptr @rx_compile(ptr %ast, ptr %next) {
entry:
  %empty = icmp eq ptr %ast, null
  br i1 %empty, label %same, label %read
read:
  %op = load i32, ptr %ast
  %vp = getelementptr %RX, ptr %ast, i32 0, i32 1
  %val = load i32, ptr %vp
  %ap = getelementptr %RX, ptr %ast, i32 0, i32 4
  %a = load ptr, ptr %ap
  %bp = getelementptr %RX, ptr %ast, i32 0, i32 5
  %b = load ptr, ptr %bp
  %dp = getelementptr %RX, ptr %ast, i32 0, i32 6
  %data = load ptr, ptr %dp
  switch i32 %op, label %simple [ i32 0, label %same i32 4, label %concat i32 5, label %alternate i32 6, label %repeat i32 7, label %group i32 11, label %ahead i32 12, label %ahead ]
same:
  ret ptr %next
simple:
  %simplenode = call ptr @rx_node(i32 %op, i32 %val, ptr %next, ptr null, ptr %data)
  ret ptr %simplenode
concat:
  %right = call ptr @rx_compile(ptr %b, ptr %next)
  %left = call ptr @rx_compile(ptr %a, ptr %right)
  ret ptr %left
alternate:
  %al = call ptr @rx_compile(ptr %a, ptr %next)
  %ar = call ptr @rx_compile(ptr %b, ptr %next)
  %alt = call ptr @rx_node(i32 4, i32 0, ptr %al, ptr %ar, ptr null)
  ret ptr %alt
group:
  %end = call ptr @rx_node(i32 6, i32 %val, ptr %next, ptr null, ptr null)
  %inside = call ptr @rx_compile(ptr %a, ptr %end)
  %start = call ptr @rx_node(i32 5, i32 %val, ptr %inside, ptr null, ptr null)
  ret ptr %start
ahead:
  %inner = call ptr @rx_compile(ptr %a, ptr null)
  %look = call ptr @rx_node(i32 %op, i32 %val, ptr %next, ptr %inner, ptr null)
  ret ptr %look
repeat:
  %lop = getelementptr %RX, ptr %ast, i32 0, i32 2
  %hip = getelementptr %RX, ptr %ast, i32 0, i32 3
  %lo = load i32, ptr %lop
  %hi = load i32, ptr %hip
  %lazy = icmp ne i32 %val, 0
  %unlimited = icmp slt i32 %hi, 0
  br i1 %unlimited, label %unbounded, label %bounded
unbounded:
  %split = call ptr @rx_node(i32 4, i32 0, ptr null, ptr null, ptr null)
  %body = call ptr @rx_compile(ptr %a, ptr %split)
  %first = select i1 %lazy, ptr %next, ptr %body
  %second = select i1 %lazy, ptr %body, ptr %next
  %sap = getelementptr %RX, ptr %split, i32 0, i32 4
  %sbp = getelementptr %RX, ptr %split, i32 0, i32 5
  store ptr %first, ptr %sap
  store ptr %second, ptr %sbp
  br label %mandatorybegin
bounded:
  %optionaln = sub i32 %hi, %lo
  br label %optionalloop
optionalloop:
  %oi = phi i32 [ 0, %bounded ], [ %onext, %optionalbody ]
  %tail = phi ptr [ %next, %bounded ], [ %osplit, %optionalbody ]
  %odone = icmp sge i32 %oi, %optionaln
  br i1 %odone, label %mandatorybegin, label %optionalbody
optionalbody:
  %ob = call ptr @rx_compile(ptr %a, ptr %tail)
  %ofirst = select i1 %lazy, ptr %tail, ptr %ob
  %osecond = select i1 %lazy, ptr %ob, ptr %tail
  %osplit = call ptr @rx_node(i32 4, i32 0, ptr %ofirst, ptr %osecond, ptr null)
  %onext = add i32 %oi, 1
  br label %optionalloop
mandatorybegin:
  %base = phi ptr [ %split, %unbounded ], [ %tail, %optionalloop ]
  br label %mandatory
mandatory:
  %mi = phi i32 [ 0, %mandatorybegin ], [ %mn, %mandatorybody ]
  %result = phi ptr [ %base, %mandatorybegin ], [ %mb, %mandatorybody ]
  %mdone = icmp sge i32 %mi, %lo
  br i1 %mdone, label %done, label %mandatorybody
mandatorybody:
  %mb = call ptr @rx_compile(ptr %a, ptr %result)
  %mn = add i32 %mi, 1
  br label %mandatory
done:
  ret ptr %result
}

define internal i32 @rx_fold(i32 %c, i32 %flags) {
  %bit = and i32 %flags, 1
  %enabled = icmp ne i32 %bit, 0
  %lo = icmp uge i32 %c, 65
  %hi = icmp ule i32 %c, 90
  %letter = and i1 %lo, %hi
  %fold = and i1 %enabled, %letter
  %lower = add i32 %c, 32
  %result = select i1 %fold, i32 %lower, i32 %c
  ret i32 %result
}

define internal i1 @rx_category(i32 %code, i32 %c) {
entry:
  %kind = or i32 %code, 32
  switch i32 %kind, label %word [ i32 100, label %digit i32 115, label %space ]
digit:
  %dl = icmp uge i32 %c, 48
  %dh = icmp ule i32 %c, 57
  %d = and i1 %dl, %dh
  br label %done
space:
  %s = icmp eq i32 %c, 32
  %sl = icmp uge i32 %c, 9
  %sh = icmp ule i32 %c, 13
  %sr = and i1 %sl, %sh
  %sw = or i1 %s, %sr
  br label %done
word:
  %fold = or i32 %c, 32
  %wl = icmp uge i32 %fold, 97
  %wh = icmp ule i32 %fold, 122
  %wa = and i1 %wl, %wh
  %wnl = icmp uge i32 %c, 48
  %wnh = icmp ule i32 %c, 57
  %wn = and i1 %wnl, %wnh
  %wu = icmp eq i32 %c, 95
  %wnonascii = icmp uge i32 %c, 128
  %w0 = or i1 %wa, %wn
  %w1 = or i1 %wu, %wnonascii
  %w = or i1 %w0, %w1
  br label %done
done:
  %test = phi i1 [ %d, %digit ], [ %sw, %space ], [ %w, %word ]
  %upper = icmp ult i32 %code, 97
  %result = xor i1 %test, %upper
  ret i1 %result
}

define internal i1 @rx_class(ptr %value, i32 %c, i32 %flags) {
entry:
  %data = call ptr @b_data(ptr %value)
  %n = call i64 @b_len(ptr %value)
  %ip = alloca i64
  %head = load i8, ptr %data
  %negated = icmp eq i8 %head, 94
  %start = zext i1 %negated to i64
  store i64 %start, ptr %ip
  %folded = call i32 @rx_fold(i32 %c, i32 %flags)
  br label %loop
loop:
  %i = load i64, ptr %ip
  %end = icmp uge i64 %i, %n
  br i1 %end, label %miss, label %char
char:
  %ch = call i32 @j_utf8_next(ptr %data, i64 %n, ptr %ip)
  %slash = icmp eq i32 %ch, 92
  br i1 %slash, label %escape, label %literal
escape:
  %ec = call i32 @j_utf8_next(ptr %data, i64 %n, ptr %ip)
  switch i32 %ec, label %escapedliteral [ i32 100, label %category i32 68, label %category i32 119, label %category i32 87, label %category i32 115, label %category i32 83, label %category ]
category:
  %cat = call i1 @rx_category(i32 %ec, i32 %c)
  br i1 %cat, label %hit, label %loop
escapedliteral:
  %nl = icmp eq i32 %ec, 110
  %tab = icmp eq i32 %ec, 116
  %cr = icmp eq i32 %ec, 114
  %ec0 = select i1 %nl, i32 10, i32 %ec
  %ec1 = select i1 %tab, i32 9, i32 %ec0
  %ec2 = select i1 %cr, i32 13, i32 %ec1
  br label %literal
literal:
  %lo = phi i32 [ %ch, %char ], [ %ec2, %escapedliteral ]
  %after = load i64, ptr %ip
  %remain = sub i64 %n, %after
  %couldrange = icmp uge i64 %remain, 2
  br i1 %couldrange, label %rangecheck, label %single
rangecheck:
  %rp = getelementptr i8, ptr %data, i64 %after
  %rc = load i8, ptr %rp
  %dash = icmp eq i8 %rc, 45
  br i1 %dash, label %range, label %single
range:
  %next = add i64 %after, 1
  store i64 %next, ptr %ip
  %hi = call i32 @j_utf8_next(ptr %data, i64 %n, ptr %ip)
  %flo = call i32 @rx_fold(i32 %lo, i32 %flags)
  %fhi = call i32 @rx_fold(i32 %hi, i32 %flags)
  %rl = icmp uge i32 %folded, %flo
  %rh = icmp ule i32 %folded, %fhi
  %matched = and i1 %rl, %rh
  br i1 %matched, label %hit, label %loop
single:
  %fch = call i32 @rx_fold(i32 %lo, i32 %flags)
  %eq = icmp eq i32 %folded, %fch
  br i1 %eq, label %hit, label %loop
hit:
  %yes = xor i1 %negated, true
  ret i1 %yes
miss:
  ret i1 %negated
}

define internal i64 @rx_run(ptr %node, ptr %ctx, i64 %pos, ptr %captures, i64 %depth) {
entry:
  %accept = icmp eq ptr %node, null
  br i1 %accept, label %success, label %read
read:
  %over = icmp ugt i64 %depth, 8192
  br i1 %over, label %resource, label %fields
resource:
  call void @j_fail(ptr @rx_limit)
  ret i64 -1
fields:
  %op = load i32, ptr %node
  %vp = getelementptr %RX, ptr %node, i32 0, i32 1
  %value = load i32, ptr %vp
  %ap = getelementptr %RX, ptr %node, i32 0, i32 4
  %a = load ptr, ptr %ap
  %bp = getelementptr %RX, ptr %node, i32 0, i32 5
  %b = load ptr, ptr %bp
  %dp = getelementptr %RX, ptr %node, i32 0, i32 6
  %data = load ptr, ptr %dp
  %cpsp = getelementptr %RC, ptr %ctx, i32 0, i32 1
  %cps = load ptr, ptr %cpsp
  %np = getelementptr %RC, ptr %ctx, i32 0, i32 3
  %n = load i64, ptr %np
  %fp = getelementptr %RC, ptr %ctx, i32 0, i32 4
  %flags = load i32, ptr %fp
  %nd = add i64 %depth, 1
  switch i32 %op, label %consuming [
    i32 0, label %success i32 4, label %split i32 5, label %save i32 6, label %save
    i32 8, label %start i32 9, label %end i32 10, label %boundary
    i32 11, label %lookahead i32 12, label %lookahead i32 14, label %reference
  ]
consuming:
  %available = icmp ult i64 %pos, %n
  br i1 %available, label %consumechar, label %fail
consumechar:
  %cp = getelementptr i32, ptr %cps, i64 %pos
  %c = load i32, ptr %cp
  switch i32 %op, label %fail [ i32 1, label %literal i32 2, label %dot i32 3, label %class i32 13, label %category ]
literal:
  %fc = call i32 @rx_fold(i32 %c, i32 %flags)
  %fv = call i32 @rx_fold(i32 %value, i32 %flags)
  %same = icmp eq i32 %fc, %fv
  br i1 %same, label %consume, label %fail
dot:
  %dotall = and i32 %flags, 2
  %any = icmp ne i32 %dotall, 0
  %notlf = icmp ne i32 %c, 10
  %dotok = or i1 %any, %notlf
  br i1 %dotok, label %consume, label %fail
class:
  %classok = call i1 @rx_class(ptr %data, i32 %c, i32 %flags)
  br i1 %classok, label %consume, label %fail
category:
  %catok = call i1 @rx_category(i32 %value, i32 %c)
  br i1 %catok, label %consume, label %fail
consume:
  %nextpos = add i64 %pos, 1
  %cres = call i64 @rx_run(ptr %a, ptr %ctx, i64 %nextpos, ptr %captures, i64 %nd)
  ret i64 %cres
split:
  %left = call i64 @rx_run(ptr %a, ptr %ctx, i64 %pos, ptr %captures, i64 %nd)
  %leftok = icmp sge i64 %left, 0
  br i1 %leftok, label %leftdone, label %right
leftdone:
  ret i64 %left
right:
  %rightres = call i64 @rx_run(ptr %b, ptr %ctx, i64 %pos, ptr %captures, i64 %nd)
  ret i64 %rightres
save:
  %capindex = mul i32 %value, 2
  %last = icmp eq i32 %op, 6
  %lastbit = zext i1 %last to i32
  %capi = add i32 %capindex, %lastbit
  %capi64 = zext i32 %capi to i64
  %cap = getelementptr i64, ptr %captures, i64 %capi64
  %old = load i64, ptr %cap
  store i64 %pos, ptr %cap
  %savedres = call i64 @rx_run(ptr %a, ptr %ctx, i64 %pos, ptr %captures, i64 %nd)
  %savedok = icmp sge i64 %savedres, 0
  br i1 %savedok, label %savedone, label %restore
restore:
  store i64 %old, ptr %cap
  ret i64 -1
savedone:
  ret i64 %savedres
start:
  %atstart = icmp eq i64 %pos, 0
  br i1 %atstart, label %continue, label %startline
startline:
  %sbit = and i32 %flags, 8
  %single = icmp ne i32 %sbit, 0
  %abs = icmp ne i32 %value, 0
  %absstart = or i1 %single, %abs
  br i1 %absstart, label %fail, label %prevchar
prevchar:
  %prev = sub i64 %pos, 1
  %prevp = getelementptr i32, ptr %cps, i64 %prev
  %prevc = load i32, ptr %prevp
  %prevlf = icmp eq i32 %prevc, 10
  br i1 %prevlf, label %continue, label %fail
end:
  %atend = icmp eq i64 %pos, %n
  br i1 %atend, label %continue, label %endline
endline:
  %ebit = and i32 %flags, 8
  %esingle = icmp ne i32 %ebit, 0
  %eabs = icmp ne i32 %value, 0
  %absend = or i1 %esingle, %eabs
  br i1 %absend, label %fail, label %endchar
endchar:
  %endp = getelementptr i32, ptr %cps, i64 %pos
  %endc = load i32, ptr %endp
  %endlf = icmp eq i32 %endc, 10
  br i1 %endlf, label %continue, label %fail
boundary:
  %hasprev = icmp ugt i64 %pos, 0
  br i1 %hasprev, label %boundprev, label %boundcurrent
boundprev:
  %bi = sub i64 %pos, 1
  %bpp = getelementptr i32, ptr %cps, i64 %bi
  %bpc = load i32, ptr %bpp
  %pw = call i1 @rx_category(i32 119, i32 %bpc)
  br label %boundcurrent
boundcurrent:
  %prevword = phi i1 [ %pw, %boundprev ], [ false, %boundary ]
  %hascurrent = icmp ult i64 %pos, %n
  br i1 %hascurrent, label %boundchar, label %boundcheck
boundchar:
  %bcp = getelementptr i32, ptr %cps, i64 %pos
  %bcc = load i32, ptr %bcp
  %cw = call i1 @rx_category(i32 119, i32 %bcc)
  br label %boundcheck
boundcheck:
  %currentword = phi i1 [ %cw, %boundchar ], [ false, %boundcurrent ]
  %changed = xor i1 %prevword, %currentword
  %neg = icmp eq i32 %value, 66
  %boundok = xor i1 %changed, %neg
  br i1 %boundok, label %continue, label %fail
lookahead:
  %lookres = call i64 @rx_run(ptr %b, ptr %ctx, i64 %pos, ptr %captures, i64 %nd)
  %lookmatched = icmp sge i64 %lookres, 0
  %negative = icmp eq i32 %op, 12
  %lookok = xor i1 %lookmatched, %negative
  br i1 %lookok, label %continue, label %fail
reference:
  %ccp = getelementptr %RC, ptr %ctx, i32 0, i32 5
  %cc = load i32, ptr %ccp
  %refvalid = icmp ult i32 %value, %cc
  br i1 %refvalid, label %refvalue, label %fail
refvalue:
  %refi = mul i32 %value, 2
  %refi64 = zext i32 %refi to i64
  %refp = getelementptr i64, ptr %captures, i64 %refi64
  %refstart = load i64, ptr %refp
  %refep = getelementptr i64, ptr %refp, i64 1
  %refend = load i64, ptr %refep
  %refset = icmp sge i64 %refstart, 0
  %reflen = sub i64 %refend, %refstart
  %refafter = add i64 %pos, %reflen
  %refbounds = icmp ule i64 %refafter, %n
  %refready = and i1 %refset, %refbounds
  br i1 %refready, label %refloop, label %fail
refloop:
  %r = phi i64 [ 0, %refvalue ], [ %rn, %refnext ]
  %rend = icmp uge i64 %r, %reflen
  br i1 %rend, label %refdone, label %refchar
refchar:
  %ra = add i64 %refstart, %r
  %rb = add i64 %pos, %r
  %rap = getelementptr i32, ptr %cps, i64 %ra
  %rbp = getelementptr i32, ptr %cps, i64 %rb
  %rac = load i32, ptr %rap
  %rbc = load i32, ptr %rbp
  %raf = call i32 @rx_fold(i32 %rac, i32 %flags)
  %rbf = call i32 @rx_fold(i32 %rbc, i32 %flags)
  %req = icmp eq i32 %raf, %rbf
  br i1 %req, label %refnext, label %fail
refnext:
  %rn = add i64 %r, 1
  br label %refloop
refdone:
  %refresult = call i64 @rx_run(ptr %a, ptr %ctx, i64 %refafter, ptr %captures, i64 %nd)
  ret i64 %refresult
continue:
  %result = call i64 @rx_run(ptr %a, ptr %ctx, i64 %pos, ptr %captures, i64 %nd)
  ret i64 %result
success:
  ret i64 %pos
fail:
  ret i64 -1
}

define internal i32 @rx_flags(ptr %value) {
entry:
  %tag = call i32 @b_tag(ptr %value)
  switch i32 %tag, label %invalid [ i32 0, label %empty i32 4, label %begin ]
empty:
  ret i32 0
begin:
  %data = call ptr @b_data(ptr %value)
  %n = call i64 @b_len(ptr %value)
  br label %loop
loop:
  %i = phi i64 [ 0, %begin ], [ %next, %add ]
  %flags = phi i32 [ 0, %begin ], [ %newflags, %add ]
  %end = icmp uge i64 %i, %n
  br i1 %end, label %done, label %char
char:
  %p = getelementptr i8, ptr %data, i64 %i
  %c = load i8, ptr %p
  switch i8 %c, label %invalid [
    i8 105, label %insensitive i8 109, label %multiline i8 120, label %extended
    i8 115, label %singleline i8 112, label %both i8 103, label %global i8 110, label %noempty
  ]
insensitive:
  br label %add
multiline:
  br label %add
extended:
  br label %add
singleline:
  br label %add
both:
  br label %add
global:
  br label %add
noempty:
  br label %add
add:
  %bit = phi i32 [ 1, %insensitive ], [ 2, %multiline ], [ 4, %extended ], [ 8, %singleline ], [ 10, %both ], [ 16, %global ], [ 32, %noempty ]
  %newflags = or i32 %flags, %bit
  %next = add i64 %i, 1
  br label %loop
done:
  ret i32 %flags
invalid:
  call void @j_fail(ptr @rx_flagsbad)
  ret i32 0
}

define internal ptr @rx_context(ptr %input, i32 %flags) {
entry:
  %n = call i64 @b_len(ptr %input)
  %data = call ptr @b_data(ptr %input)
  %cap = add i64 %n, 1
  %cpbytes = mul i64 %cap, 4
  %offsetbytes = mul i64 %cap, 8
  %cps = call ptr @j_alloc(i64 %cpbytes)
  %offsets = call ptr @j_alloc(i64 %offsetbytes)
  %pos = alloca i64
  store i64 0, ptr %pos
  br label %loop
loop:
  %i = phi i64 [ 0, %entry ], [ %next, %char ]
  %off = load i64, ptr %pos
  %op = getelementptr i64, ptr %offsets, i64 %i
  store i64 %off, ptr %op
  %end = icmp uge i64 %off, %n
  br i1 %end, label %done, label %char
char:
  %c = call i32 @j_utf8_next(ptr %data, i64 %n, ptr %pos)
  %cp = getelementptr i32, ptr %cps, i64 %i
  store i32 %c, ptr %cp
  %next = add i64 %i, 1
  br label %loop
done:
  %ctx = call ptr @j_alloc(i64 48)
  store ptr %input, ptr %ctx
  %cpp = getelementptr %RC, ptr %ctx, i32 0, i32 1
  store ptr %cps, ptr %cpp
  %opp = getelementptr %RC, ptr %ctx, i32 0, i32 2
  store ptr %offsets, ptr %opp
  %np = getelementptr %RC, ptr %ctx, i32 0, i32 3
  store i64 %i, ptr %np
  %fp = getelementptr %RC, ptr %ctx, i32 0, i32 4
  store i32 %flags, ptr %fp
  ret ptr %ctx
}

define internal ptr @rx_substring(ptr %ctx, i64 %start, i64 %end) {
entry:
  %unset = icmp slt i64 %start, 0
  br i1 %unset, label %null, label %string
null:
  %nv = call ptr @j_null()
  ret ptr %nv
string:
  %input = load ptr, ptr %ctx
  %data = call ptr @b_data(ptr %input)
  %op = getelementptr %RC, ptr %ctx, i32 0, i32 2
  %offsets = load ptr, ptr %op
  %sp = getelementptr i64, ptr %offsets, i64 %start
  %ep = getelementptr i64, ptr %offsets, i64 %end
  %s = load i64, ptr %sp
  %e = load i64, ptr %ep
  %p = getelementptr i8, ptr %data, i64 %s
  %n = sub i64 %e, %s
  %v = call ptr @j_str(ptr %p, i64 %n)
  ret ptr %v
}

define internal ptr @rx_matches(ptr %pattern, ptr %ctx) {
entry:
  %out = call ptr @j_array()
  %tag = call i32 @b_tag(ptr %pattern)
  %string = icmp eq i32 %tag, 4
  br i1 %string, label %compile, label %badtype
badtype:
  call void @j_fail(ptr @rx_stringbad)
  ret ptr %out
compile:
  %pd = call ptr @b_data(ptr %pattern)
  %pn = call i64 @b_len(ptr %pattern)
  %p = call ptr @j_alloc(i64 40)
  store ptr %pd, ptr %p
  %pnp = getelementptr %RP, ptr %p, i32 0, i32 1
  store i64 %pn, ptr %pnp
  %cfp = getelementptr %RC, ptr %ctx, i32 0, i32 4
  %flags = load i32, ptr %cfp
  %pfp = getelementptr %RP, ptr %p, i32 0, i32 3
  store i32 %flags, ptr %pfp
  %names = call ptr @j_array()
  %pnamesp = getelementptr %RP, ptr %p, i32 0, i32 5
  store ptr %names, ptr %pnamesp
  %tree = call ptr @rx_expr(ptr %p)
  %tail = call i32 @rx_peek(ptr %p)
  %tailend = icmp slt i32 %tail, 0
  br i1 %tailend, label %compiled, label %badpattern
badpattern:
  call void @j_fail(ptr @rx_bad)
  ret ptr %out
compiled:
  %err = load ptr, ptr @j_error
  %haserr = icmp ne ptr %err, null
  br i1 %haserr, label %done, label %ready
ready:
  %graph = call ptr @rx_compile(ptr %tree, ptr null)
  %countp = getelementptr %RP, ptr %p, i32 0, i32 4
  %count = load i32, ptr %countp
  %ccp = getelementptr %RC, ptr %ctx, i32 0, i32 5
  store i32 %count, ptr %ccp
  %cnp = getelementptr %RC, ptr %ctx, i32 0, i32 6
  store ptr %names, ptr %cnp
  %count64 = zext i32 %count to i64
  %slots = mul i64 %count64, 2
  %capbytes = mul i64 %slots, 8
  %gbit = and i32 %flags, 16
  %global = icmp ne i32 %gbit, 0
  %nbit = and i32 %flags, 32
  %noempty = icmp ne i32 %nbit, 0
  %np = getelementptr %RC, ptr %ctx, i32 0, i32 3
  %n = load i64, ptr %np
  br label %search
search:
  %pos = phi i64 [ 0, %ready ], [ %nextpos, %advance ], [ %aftermatch, %matchednext ]
  %finished = icmp ugt i64 %pos, %n
  br i1 %finished, label %done, label %newcaps
newcaps:
  %caps = call ptr @j_alloc(i64 %capbytes)
  br label %init
init:
  %ci = phi i64 [ 0, %newcaps ], [ %cn, %initone ]
  %cend = icmp uge i64 %ci, %slots
  br i1 %cend, label %match, label %initone
initone:
  %cp = getelementptr i64, ptr %caps, i64 %ci
  store i64 -1, ptr %cp
  %cn = add i64 %ci, 1
  br label %init
match:
  %end = call i64 @rx_run(ptr %graph, ptr %ctx, i64 %pos, ptr %caps, i64 0)
  %ok = icmp sge i64 %end, 0
  %empty = icmp eq i64 %end, %pos
  %denyempty = and i1 %empty, %noempty
  %nonemptyok = xor i1 %denyempty, true
  %valid = and i1 %ok, %nonemptyok
  br i1 %valid, label %matched, label %advance
advance:
  %nextpos = add i64 %pos, 1
  br label %search
matched:
  %m = call ptr @j_alloc(i64 24)
  store i64 %pos, ptr %m
  %mep = getelementptr %RM, ptr %m, i32 0, i32 1
  store i64 %end, ptr %mep
  %mcp = getelementptr %RM, ptr %m, i32 0, i32 2
  store ptr %caps, ptr %mcp
  call void @j_push(ptr %out, ptr %m)
  br i1 %global, label %matchednext, label %done
matchednext:
  %stepped = add i64 %pos, 1
  %aftermatch = select i1 %empty, i64 %stepped, i64 %end
  br label %search
done:
  ret ptr %out
}

define internal ptr @rx_capture_record(ptr %ctx, i64 %start, i64 %end) {
  %out = call ptr @j_object()
  %okey = call ptr @j_cstr(ptr @rx_offset)
  %lkey = call ptr @j_cstr(ptr @rx_length)
  %skey = call ptr @j_cstr(ptr @rx_string)
  %offset = sitofp i64 %start to double
  %ov = call ptr @j_num(double %offset)
  %unset = icmp slt i64 %start, 0
  %length = sub i64 %end, %start
  %length2 = select i1 %unset, i64 0, i64 %length
  %ld = sitofp i64 %length2 to double
  %lv = call ptr @j_num(double %ld)
  %sv = call ptr @rx_substring(ptr %ctx, i64 %start, i64 %end)
  call void @j_put(ptr %out, ptr %okey, ptr %ov)
  call void @j_put(ptr %out, ptr %lkey, ptr %lv)
  call void @j_put(ptr %out, ptr %skey, ptr %sv)
  ret ptr %out
}

define internal ptr @rx_capture_values(ptr %ctx, ptr %match, i32 %mode) {
entry:
  %np = getelementptr %RC, ptr %ctx, i32 0, i32 5
  %n32 = load i32, ptr %np
  %n = zext i32 %n32 to i64
  %namesp = getelementptr %RC, ptr %ctx, i32 0, i32 6
  %names = load ptr, ptr %namesp
  %cp = getelementptr %RM, ptr %match, i32 0, i32 2
  %caps = load ptr, ptr %cp
  %obj = call ptr @j_object()
  %arr = call ptr @j_array()
  %isobject = icmp eq i32 %mode, 1
  %out = select i1 %isobject, ptr %obj, ptr %arr
  br label %loop
loop:
  %i = phi i64 [ 0, %entry ], [ %next, %advance ]
  %done = icmp uge i64 %i, %n
  br i1 %done, label %end, label %capture
capture:
  %ci = mul i64 %i, 2
  %sp = getelementptr i64, ptr %caps, i64 %ci
  %ep = getelementptr i64, ptr %sp, i64 1
  %s = load i64, ptr %sp
  %e = load i64, ptr %ep
  %name = call ptr @j_at(ptr %names, i64 %i)
  %str = call ptr @rx_substring(ptr %ctx, i64 %s, i64 %e)
  switch i32 %mode, label %record [ i32 1, label %named i32 2, label %string ]
named:
  %tag = call i32 @b_tag(ptr %name)
  %hasname = icmp eq i32 %tag, 4
  br i1 %hasname, label %putname, label %advance
putname:
  call void @j_put(ptr %out, ptr %name, ptr %str)
  br label %advance
string:
  call void @j_push(ptr %out, ptr %str)
  br label %advance
record:
  %r = call ptr @rx_capture_record(ptr %ctx, i64 %s, i64 %e)
  %namekey = call ptr @j_cstr(ptr @rx_name)
  call void @j_put(ptr %r, ptr %namekey, ptr %name)
  call void @j_push(ptr %out, ptr %r)
  br label %advance
advance:
  %next = add i64 %i, 1
  br label %loop
end:
  ret ptr %out
}

define internal ptr @rx_output(ptr %ctx, ptr %matches, i32 %id, ptr %args, ptr %env) {
entry:
  %out = call ptr @j_array()
  %n = call i64 @b_len(ptr %matches)
  %input = load ptr, ptr %ctx
  %ncp = getelementptr %RC, ptr %ctx, i32 0, i32 3
  %len = load i64, ptr %ncp
  switch i32 %id, label %matchbegin [ i32 1, label %test i32 4, label %subbegin i32 5, label %subbegin i32 6, label %splitbegin i32 7, label %splitbegin ]
test:
  %has = icmp ne i64 %n, 0
  %bool = call ptr @j_bool(i1 %has)
  call void @j_push(ptr %out, ptr %bool)
  ret ptr %out
matchbegin:
  br label %matchloop
matchloop:
  %i = phi i64 [ 0, %matchbegin ], [ %next, %matchnext ]
  %done = icmp uge i64 %i, %n
  br i1 %done, label %finish, label %matchone
matchone:
  %m = call ptr @j_at(ptr %matches, i64 %i)
  %s = load i64, ptr %m
  %ep = getelementptr %RM, ptr %m, i32 0, i32 1
  %e = load i64, ptr %ep
  switch i32 %id, label %record [ i32 2, label %capture i32 3, label %scan ]
capture:
  %named = call ptr @rx_capture_values(ptr %ctx, ptr %m, i32 1)
  br label %matchnext
scan:
  %ccp = getelementptr %RC, ptr %ctx, i32 0, i32 5
  %cc = load i32, ptr %ccp
  %hascaps = icmp ne i32 %cc, 0
  br i1 %hascaps, label %scanarray, label %scanstring
scanarray:
  %sa = call ptr @rx_capture_values(ptr %ctx, ptr %m, i32 2)
  br label %matchnext
scanstring:
  %ss = call ptr @rx_substring(ptr %ctx, i64 %s, i64 %e)
  br label %matchnext
record:
  %rec = call ptr @rx_capture_record(ptr %ctx, i64 %s, i64 %e)
  %caps = call ptr @rx_capture_values(ptr %ctx, ptr %m, i32 0)
  %ck = call ptr @j_cstr(ptr @rx_captures)
  call void @j_put(ptr %rec, ptr %ck, ptr %caps)
  br label %matchnext
matchnext:
  %value = phi ptr [ %rec, %record ], [ %named, %capture ], [ %sa, %scanarray ], [ %ss, %scanstring ]
  call void @j_push(ptr %out, ptr %value)
  %next = add i64 %i, 1
  br label %matchloop
splitbegin:
  br label %splitloop
splitloop:
  %si = phi i64 [ 0, %splitbegin ], [ %sn, %splitone ]
  %prev = phi i64 [ 0, %splitbegin ], [ %se, %splitone ]
  %sdone = icmp uge i64 %si, %n
  br i1 %sdone, label %splittail, label %splitone
splitone:
  %sm = call ptr @j_at(ptr %matches, i64 %si)
  %start = load i64, ptr %sm
  %sep = getelementptr %RM, ptr %sm, i32 0, i32 1
  %se = load i64, ptr %sep
  %piece = call ptr @rx_substring(ptr %ctx, i64 %prev, i64 %start)
  call void @j_push(ptr %out, ptr %piece)
  %sn = add i64 %si, 1
  br label %splitloop
splittail:
  %tail = call ptr @rx_substring(ptr %ctx, i64 %prev, i64 %len)
  call void @j_push(ptr %out, ptr %tail)
  %wrap = icmp eq i32 %id, 7
  br i1 %wrap, label %splitwrap, label %finish
splitwrap:
  %splitout = call ptr @b_one(ptr %out)
  ret ptr %splitout
subbegin:
  %no = icmp eq i64 %n, 0
  br i1 %no, label %unchanged, label %substart
unchanged:
  call void @j_push(ptr %out, ptr %input)
  ret ptr %out
substart:
  %ast = call ptr @j_at(ptr %args, i64 1)
  %empty = call ptr @j_cstr(ptr @rx_empty)
  %initial = call ptr @b_one(ptr %empty)
  br label %subloop
subloop:
  %mi = phi i64 [ 0, %substart ], [ %mn, %subnext ]
  %previous = phi i64 [ 0, %substart ], [ %me, %subnext ]
  %variants = phi ptr [ %initial, %substart ], [ %nextvariants, %subnext ]
  %mdone = icmp uge i64 %mi, %n
  br i1 %mdone, label %subtail, label %subone
subone:
  %mm = call ptr @j_at(ptr %matches, i64 %mi)
  %ms = load i64, ptr %mm
  %mep = getelementptr %RM, ptr %mm, i32 0, i32 1
  %me = load i64, ptr %mep
  %gap = call ptr @rx_substring(ptr %ctx, i64 %previous, i64 %ms)
  %captures = call ptr @rx_capture_values(ptr %ctx, ptr %mm, i32 1)
  %replacements = call ptr @j_eval(ptr %ast, ptr %captures, ptr %env)
  %repln = call i64 @b_len(ptr %replacements)
  %variantn = call i64 @b_len(ptr %variants)
  %nextvariants = call ptr @j_array()
  br label %variantloop
variantloop:
  %v = phi i64 [ 0, %subone ], [ %vn, %variantnext ]
  %vend = icmp uge i64 %v, %variantn
  br i1 %vend, label %subnext, label %variantone
variantone:
  %old = call ptr @j_at(ptr %variants, i64 %v)
  %prefix = call ptr @j_binary(i32 0, ptr %old, ptr %gap)
  %firstmatch = icmp eq i64 %mi, 0
  br i1 %firstmatch, label %replloop, label %aligned
aligned:
  %onevalue = icmp eq i64 %repln, 1
  %which = select i1 %onevalue, i64 0, i64 %v
  %exists = icmp ult i64 %which, %repln
  br i1 %exists, label %alignedone, label %variantnext
alignedone:
  %repl = call ptr @j_at(ptr %replacements, i64 %which)
  %combined = call ptr @j_binary(i32 0, ptr %prefix, ptr %repl)
  call void @j_push(ptr %nextvariants, ptr %combined)
  br label %variantnext
replloop:
  %r = phi i64 [ 0, %variantone ], [ %rn, %replone ]
  %rend = icmp uge i64 %r, %repln
  br i1 %rend, label %variantnext, label %replone
replone:
  %rv = call ptr @j_at(ptr %replacements, i64 %r)
  %new = call ptr @j_binary(i32 0, ptr %prefix, ptr %rv)
  call void @j_push(ptr %nextvariants, ptr %new)
  %rn = add i64 %r, 1
  br label %replloop
variantnext:
  %vn = add i64 %v, 1
  br label %variantloop
subnext:
  %mn = add i64 %mi, 1
  br label %subloop
subtail:
  %suffix = call ptr @rx_substring(ptr %ctx, i64 %previous, i64 %len)
  %total = call i64 @b_len(ptr %variants)
  br label %tailloop
tailloop:
  %ti = phi i64 [ 0, %subtail ], [ %tn, %tailone ]
  %tdone = icmp uge i64 %ti, %total
  br i1 %tdone, label %finish, label %tailone
tailone:
  %tv = call ptr @j_at(ptr %variants, i64 %ti)
  %final = call ptr @j_binary(i32 0, ptr %tv, ptr %suffix)
  call void @j_push(ptr %out, ptr %final)
  %tn = add i64 %ti, 1
  br label %tailloop
finish:
  ret ptr %out
}

define ptr @j_regex_builtin(ptr %name, ptr %args, ptr %input, ptr %env) {
entry:
  %id = call i32 @b_find(ptr %name, ptr @rx_names)
  %known = icmp sge i32 %id, 0
  br i1 %known, label %begin, label %unknown
unknown:
  ret ptr null
begin:
  %out = call ptr @j_array()
  %tag = call i32 @b_tag(ptr %input)
  %str = icmp eq i32 %tag, 4
  br i1 %str, label %arguments, label %invalid
arguments:
  %argc = call i64 @b_len(ptr %args)
  %haspattern = icmp ne i64 %argc, 0
  br i1 %haspattern, label %readpatterns, label %invalid
readpatterns:
  %patterns = call ptr @b_arg(ptr %args, i64 0, ptr %input, ptr %env)
  %pn = call i64 @b_len(ptr %patterns)
  %issub = icmp eq i32 %id, 4
  %isgsub = icmp eq i32 %id, 5
  %sub = or i1 %issub, %isgsub
  %flagarg = select i1 %sub, i64 2, i64 1
  %haveflags = icmp ugt i64 %argc, %flagarg
  br i1 %haveflags, label %flagsarg, label %defaultflags
flagsarg:
  %flagvalues = call ptr @b_arg(ptr %args, i64 %flagarg, ptr %input, ptr %env)
  br label %flagbegin
defaultflags:
  %null = call ptr @j_null()
  %default = call ptr @b_one(ptr %null)
  br label %flagbegin
flagbegin:
  %flagstream = phi ptr [ %flagvalues, %flagsarg ], [ %default, %defaultflags ]
  %fn = call i64 @b_len(ptr %flagstream)
  br label %patternloop
patternloop:
  %pi = phi i64 [ 0, %flagbegin ], [ %pnext, %patternnext ]
  %pdone = icmp uge i64 %pi, %pn
  br i1 %pdone, label %done, label %patternone
patternone:
  %pv = call ptr @j_at(ptr %patterns, i64 %pi)
  %pt = call i32 @b_tag(ptr %pv)
  %pair = icmp eq i32 %pt, 5
  br i1 %pair, label %patternpair, label %patternplain
patternpair:
  %pp = call ptr @j_at(ptr %pv, i64 0)
  %pf = call ptr @j_at(ptr %pv, i64 1)
  br label %flagloop
patternplain:
  br label %flagloop
flagloop:
  %pattern = phi ptr [ %pp, %patternpair ], [ %pv, %patternplain ], [ %pattern, %execute ]
  %pairflags = phi ptr [ %pf, %patternpair ], [ null, %patternplain ], [ %pairflags, %execute ]
  %fi = phi i64 [ 0, %patternpair ], [ 0, %patternplain ], [ %fnext, %execute ]
  %fdone = icmp uge i64 %fi, %fn
  br i1 %fdone, label %patternnext, label %flagone
flagone:
  %fv = call ptr @j_at(ptr %flagstream, i64 %fi)
  %pairflagset = icmp ne ptr %pairflags, null
  %flagvalue = select i1 %pairflagset, ptr %pairflags, ptr %fv
  %baseflags = call i32 @rx_flags(ptr %flagvalue)
  %scan = icmp eq i32 %id, 3
  %split = icmp uge i32 %id, 6
  %global0 = or i1 %scan, %split
  %global = or i1 %global0, %isgsub
  %gbit = select i1 %global, i32 16, i32 0
  %flags = or i32 %baseflags, %gbit
  %ctx = call ptr @rx_context(ptr %input, i32 %flags)
  %matches = call ptr @rx_matches(ptr %pattern, ptr %ctx)
  %err = load ptr, ptr @j_error
  %ok = icmp eq ptr %err, null
  br i1 %ok, label %execute, label %done
execute:
  %results = call ptr @rx_output(ptr %ctx, ptr %matches, i32 %id, ptr %args, ptr %env)
  call void @b_extend(ptr %out, ptr %results)
  %fnext = add i64 %fi, 1
  br label %flagloop
patternnext:
  %pnext = add i64 %pi, 1
  br label %patternloop
invalid:
  call void @j_fail(ptr @rx_stringbad)
  br label %done
done:
  ret ptr %out
}
