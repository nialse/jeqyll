%RP = type { ptr, i64, i64, i32, i32, ptr }
%RS = type { i32, i32, i32, ptr, ptr }

@rp_bad = private constant [31 x i8] c"Regex failure: invalid pattern\00"
@rp_classend = private constant [43 x i8] c"Regex failure: premature end of char-class\00"
@rp_escapeend = private constant [37 x i8] c"Regex failure: end pattern at escape\00"
@rp_emptyclass = private constant [32 x i8] c"Regex failure: empty char-class\00"
@rp_emptyrange = private constant [41 x i8] c"Regex failure: empty range in char class\00"
@rp_propertybad = private constant [47 x i8] c"Regex failure: invalid character property name\00"

declare ptr @j_alloc(i64)
declare ptr @j_str(ptr, i64)
declare void @j_fail(ptr)
declare void @rx_fail(ptr)
declare i32 @j_utf8_next(ptr, i64, ptr)
declare i32 @rx_unicode_property(ptr, i64)
declare i1 @rx_unicode_has(i32, i32)
declare i1 @rx_unicode_case_range(i32, i32, i32)

define internal i32 @rp_peek(ptr %parser) {
entry:
  %data = load ptr, ptr %parser
  %np = getelementptr %RP, ptr %parser, i32 0, i32 1
  %n = load i64, ptr %np
  %ip = getelementptr %RP, ptr %parser, i32 0, i32 2
  %i = load i64, ptr %ip
  %more = icmp ult i64 %i, %n
  br i1 %more, label %read, label %eof
read:
  %p = getelementptr i8, ptr %data, i64 %i
  %c = load i8, ptr %p
  %result = zext i8 %c to i32
  ret i32 %result
eof:
  ret i32 -1
}

define internal i32 @rp_take(ptr %parser) {
  %data = load ptr, ptr %parser
  %np = getelementptr %RP, ptr %parser, i32 0, i32 1
  %n = load i64, ptr %np
  %ip = getelementptr %RP, ptr %parser, i32 0, i32 2
  %value = call i32 @j_utf8_next(ptr %data, i64 %n, ptr %ip)
  ret i32 %value
}

define internal i32 @rp_number(ptr %parser, i32 %base, i32 %maximum, i32 %initial) {
entry:
  br label %loop
loop:
  %i = phi i32 [0, %entry], [%next, %digit]
  %value = phi i32 [%initial, %entry], [%result, %digit]
  %room = icmp ult i32 %i, %maximum
  br i1 %room, label %read, label %done
read:
  %c = call i32 @rp_peek(ptr %parser)
  %decimal = sub i32 %c, 48
  %fold = or i32 %c, 32
  %alpha = sub i32 %fold, 87
  %isdecimal = icmp ult i32 %decimal, 10
  %d = select i1 %isdecimal, i32 %decimal, i32 %alpha
  %valid = icmp ult i32 %d, %base
  br i1 %valid, label %digit, label %done
digit:
  %unused = call i32 @rp_take(ptr %parser)
  %times = mul i32 %value, %base
  %result = add i32 %times, %d
  %next = add i32 %i, 1
  br label %loop
done:
  ret i32 %value
}

define i32 @rx_read_escape(ptr %parser, i32 %escape) {
entry:
  switch i32 %escape, label %literal [
    i32 97, label %bell i32 98, label %backspace i32 101, label %esc
    i32 102, label %ff i32 110, label %lf i32 114, label %cr
    i32 116, label %tab i32 118, label %vt i32 120, label %hex
    i32 117, label %unicode i32 111, label %octalbrace i32 48, label %octal
    i32 99, label %control i32 67, label %controlminus i32 77, label %meta
    i32 -1, label %escapeend
  ]
escapeend:
  call void @j_fail(ptr @rp_escapeend)
  ret i32 -1
bell:
  ret i32 7
backspace:
  ret i32 8
esc:
  ret i32 27
ff:
  ret i32 12
lf:
  ret i32 10
cr:
  ret i32 13
tab:
  ret i32 9
vt:
  ret i32 11
hex:
  %head = call i32 @rp_peek(ptr %parser)
  %brace = icmp eq i32 %head, 123
  br i1 %brace, label %hexbrace, label %hexbyte
hexbyte:
  %byte = call i32 @rp_number(ptr %parser, i32 16, i32 2, i32 0)
  ret i32 %byte
hexbrace:
  %open = call i32 @rp_take(ptr %parser)
  %hexpoint = call i32 @rp_number(ptr %parser, i32 16, i32 8, i32 0)
  br label %braceend
unicode:
  %unicodepoint = call i32 @rp_number(ptr %parser, i32 16, i32 4, i32 0)
  ret i32 %unicodepoint
octalbrace:
  %oc = call i32 @rp_take(ptr %parser)
  %hasbrace = icmp eq i32 %oc, 123
  br i1 %hasbrace, label %octalnumber, label %invalid
octalnumber:
  %octalpoint = call i32 @rp_number(ptr %parser, i32 8, i32 11, i32 0)
  br label %braceend
braceend:
  %point = phi i32 [%hexpoint, %hexbrace], [%octalpoint, %octalnumber]
  %close = call i32 @rp_take(ptr %parser)
  %closed = icmp eq i32 %close, 125
  %range = icmp ule i32 %point, 1114111
  %valid = and i1 %closed, %range
  br i1 %valid, label %bracedone, label %invalid
bracedone:
  ret i32 %point
octal:
  %oct = call i32 @rp_number(ptr %parser, i32 8, i32 2, i32 0)
  ret i32 %oct
controlminus:
  %minus = call i32 @rp_take(ptr %parser)
  %dash = icmp eq i32 %minus, 45
  br i1 %dash, label %control, label %invalid
control:
  %cc = call i32 @rp_take(ptr %parser)
  %ctrl = and i32 %cc, 31
  %question = icmp eq i32 %cc, 63
  %controlvalue = select i1 %question, i32 127, i32 %ctrl
  ret i32 %controlvalue
meta:
  %md = call i32 @rp_take(ptr %parser)
  %metaok = icmp eq i32 %md, 45
  br i1 %metaok, label %metachar, label %invalid
metachar:
  %mc = call i32 @rp_take(ptr %parser)
  %slash = icmp eq i32 %mc, 92
  br i1 %slash, label %metaescape, label %metadone
metaescape:
  %me = call i32 @rp_take(ptr %parser)
  %mv = call i32 @rx_read_escape(ptr %parser, i32 %me)
  br label %metadone
metadone:
  %base = phi i32 [%mc, %metachar], [%mv, %metaescape]
  %metavalue = or i32 %base, 128
  ret i32 %metavalue
literal:
  ret i32 %escape
invalid:
  call void @j_fail(ptr @rp_bad)
  ret i32 0
}

define i32 @rx_parse_property(ptr %parser, i32 %escape) {
entry:
  %open = call i32 @rp_take(ptr %parser)
  %brace = icmp eq i32 %open, 123
  br i1 %brace, label %begin, label %invalid
begin:
  %head = call i32 @rp_peek(ptr %parser)
  %caret = icmp eq i32 %head, 94
  br i1 %caret, label %negative, label %start
negative:
  %unused = call i32 @rp_take(ptr %parser)
  br label %start
start:
  %ip = getelementptr %RP, ptr %parser, i32 0, i32 2
  %first = load i64, ptr %ip
  br label %loop
loop:
  %c = call i32 @rp_peek(ptr %parser)
  %end = icmp eq i32 %c, 125
  br i1 %end, label %lookup, label %advance
advance:
  %eof = icmp slt i32 %c, 0
  br i1 %eof, label %invalid, label %next
next:
  %ignored = call i32 @rp_take(ptr %parser)
  br label %loop
lookup:
  %last = load i64, ptr %ip
  %data = load ptr, ptr %parser
  %name = getelementptr i8, ptr %data, i64 %first
  %length = sub i64 %last, %first
  %property = call i32 @rx_unicode_property(ptr %name, i64 %length)
  %close = call i32 @rp_take(ptr %parser)
  %valid = icmp sge i32 %property, 0
  br i1 %valid, label %done, label %invalid
done:
  %capital = icmp eq i32 %escape, 80
  %negate = xor i1 %capital, %caret
  %complement = xor i32 %property, -1
  %result = select i1 %negate, i32 %complement, i32 %property
  ret i32 %result
invalid:
  call void @j_fail(ptr @rp_propertybad)
  ret i32 -1
}

define ptr @rx_parse_named(ptr %parser) {
entry:
  %open = call i32 @rp_take(ptr %parser)
  %angle = icmp eq i32 %open, 60
  %brace = icmp eq i32 %open, 123
  %quote = icmp eq i32 %open, 39
  %valid0 = or i1 %angle, %brace
  %valid = or i1 %valid0, %quote
  %end0 = select i1 %angle, i32 62, i32 39
  %end = select i1 %brace, i32 125, i32 %end0
  %ip = getelementptr %RP, ptr %parser, i32 0, i32 2
  %first = load i64, ptr %ip
  br i1 %valid, label %loop, label %invalid
loop:
  %c = call i32 @rp_peek(ptr %parser)
  %close = icmp eq i32 %c, %end
  br i1 %close, label %done, label %advance
advance:
  %eof = icmp slt i32 %c, 0
  br i1 %eof, label %invalid, label %next
next:
  %unused = call i32 @rp_take(ptr %parser)
  br label %loop
done:
  %last = load i64, ptr %ip
  %data = load ptr, ptr %parser
  %name = getelementptr i8, ptr %data, i64 %first
  %length = sub i64 %last, %first
  %value = call ptr @j_str(ptr %name, i64 %length)
  %closer = call i32 @rp_take(ptr %parser)
  ret ptr %value
invalid:
  call void @j_fail(ptr @rp_bad)
  %empty = call ptr @j_str(ptr null, i64 0)
  ret ptr %empty
}

define ptr @rx_parse_until(ptr %parser, i32 %closer) {
entry:
  %ip = getelementptr %RP, ptr %parser, i32 0, i32 2
  %first = load i64, ptr %ip
  br label %loop
loop:
  %c = call i32 @rp_peek(ptr %parser)
  %closed = icmp eq i32 %c, %closer
  br i1 %closed, label %done, label %advance
advance:
  %eof = icmp slt i32 %c, 0
  br i1 %eof, label %invalid, label %next
next:
  %unused = call i32 @rp_take(ptr %parser)
  br label %loop
done:
  %last = load i64, ptr %ip
  %data = load ptr, ptr %parser
  %name = getelementptr i8, ptr %data, i64 %first
  %length = sub i64 %last, %first
  %value = call ptr @j_str(ptr %name, i64 %length)
  %end = call i32 @rp_take(ptr %parser)
  ret ptr %value
invalid:
  call void @j_fail(ptr @rp_bad)
  %empty = call ptr @j_str(ptr null, i64 0)
  ret ptr %empty
}

define internal ptr @rp_set(i32 %kind, i32 %lo, i32 %hi, ptr %a, ptr %b) {
  %node = call ptr @j_alloc(i64 32)
  store i32 %kind, ptr %node
  %lp = getelementptr %RS, ptr %node, i32 0, i32 1
  %hp = getelementptr %RS, ptr %node, i32 0, i32 2
  %ap = getelementptr %RS, ptr %node, i32 0, i32 3
  %bp = getelementptr %RS, ptr %node, i32 0, i32 4
  store i32 %lo, ptr %lp
  store i32 %hi, ptr %hp
  store ptr %a, ptr %ap
  store ptr %b, ptr %bp
  ret ptr %node
}

define internal ptr @rp_item(ptr %parser) {
entry:
  %c = call i32 @rp_peek(ptr %parser)
  switch i32 %c, label %ordinary [i32 91, label %bracket i32 92, label %escape]
ordinary:
  %literal = call i32 @rp_take(ptr %parser)
  br label %rangecheck
escape:
  %slash = call i32 @rp_take(ptr %parser)
  %esc = call i32 @rp_take(ptr %parser)
  switch i32 %esc, label %escaped [i32 112, label %property i32 80, label %property i32 100, label %digit i32 68, label %digit i32 115, label %space i32 83, label %space i32 119, label %word i32 87, label %word i32 104, label %hex i32 72, label %hex]
property:
  %prop = call i32 @rx_parse_property(ptr %parser, i32 %esc)
  br label %propertynode
digit:
  br label %category
space:
  br label %category
word:
  br label %category
hex:
  br label %category
category:
  %id = phi i32 [4, %digit], [9, %space], [12, %word], [11, %hex]
  %negative = icmp ult i32 %esc, 97
  %notid = xor i32 %id, -1
  %cat = select i1 %negative, i32 %notid, i32 %id
  br label %propertynode
propertynode:
  %propertyid = phi i32 [%prop, %property], [%cat, %category]
  %propertyset = call ptr @rp_set(i32 1, i32 %propertyid, i32 0, ptr null, ptr null)
  ret ptr %propertyset
escaped:
  %escapevalue = call i32 @rx_read_escape(ptr %parser, i32 %esc)
  br label %rangecheck
rangecheck:
  %lo = phi i32 [%literal, %ordinary], [%escapevalue, %escaped]
  %ip = getelementptr %RP, ptr %parser, i32 0, i32 2
  %after = load i64, ptr %ip
  %nextchar = call i32 @rp_peek(ptr %parser)
  %dash = icmp eq i32 %nextchar, 45
  br i1 %dash, label %rangeprobe, label %single
rangeprobe:
  %unused = call i32 @rp_take(ptr %parser)
  %endchar = call i32 @rp_peek(ptr %parser)
  %close = icmp eq i32 %endchar, 93
  br i1 %close, label %restore, label %rangeread
restore:
  store i64 %after, ptr %ip
  br label %single
rangeread:
  %upperchar = call i32 @rp_take(ptr %parser)
  %escapedupper = icmp eq i32 %upperchar, 92
  br i1 %escapedupper, label %rangeescape, label %rangedone
rangeescape:
  %uppere = call i32 @rp_take(ptr %parser)
  %uppervalue = call i32 @rx_read_escape(ptr %parser, i32 %uppere)
  br label %rangedone
rangedone:
  %hi = phi i32 [%upperchar, %rangeread], [%uppervalue, %rangeescape]
  %ordered = icmp ule i32 %lo, %hi
  br i1 %ordered, label %makenode, label %emptyrange
emptyrange:
  call void @rx_fail(ptr @rp_emptyrange)
  br label %invalid
single:
  br label %makenode
makenode:
  %end = phi i32 [%lo, %single], [%hi, %rangedone]
  %range = call ptr @rp_set(i32 0, i32 %lo, i32 %end, ptr null, ptr null)
  ret ptr %range
bracket:
  %bip = getelementptr %RP, ptr %parser, i32 0, i32 2
  %saved = load i64, ptr %bip
  %opening = call i32 @rp_take(ptr %parser)
  %firstchar = call i32 @rp_peek(ptr %parser)
  %colon = icmp eq i32 %firstchar, 58
  br i1 %colon, label %posix, label %nested
nested:
  store i64 %saved, ptr %bip
  %nestedset = call ptr @rx_parse_class(ptr %parser)
  ret ptr %nestedset
posix:
  %colonvalue = call i32 @rp_take(ptr %parser)
  %head = call i32 @rp_peek(ptr %parser)
  %neg = icmp eq i32 %head, 94
  br i1 %neg, label %posixneg, label %posixstart
posixneg:
  %caret = call i32 @rp_take(ptr %parser)
  br label %posixstart
posixstart:
  %start = load i64, ptr %bip
  br label %posixloop
posixloop:
  %pc = call i32 @rp_peek(ptr %parser)
  %endcolon = icmp eq i32 %pc, 58
  br i1 %endcolon, label %posixend, label %posixnext
posixnext:
  %peof = icmp slt i32 %pc, 0
  br i1 %peof, label %invalid, label %posixadvance
posixadvance:
  %ignored = call i32 @rp_take(ptr %parser)
  br label %posixloop
posixend:
  %finish = load i64, ptr %bip
  %data = load ptr, ptr %parser
  %name = getelementptr i8, ptr %data, i64 %start
  %length = sub i64 %finish, %start
  %propertycode = call i32 @rx_unicode_property(ptr %name, i64 %length)
  %colonend = call i32 @rp_take(ptr %parser)
  %bracketend = call i32 @rp_take(ptr %parser)
  %validproperty = icmp sge i32 %propertycode, 0
  %closed = icmp eq i32 %bracketend, 93
  %validposix = and i1 %validproperty, %closed
  br i1 %validposix, label %posixdone, label %invalid
posixdone:
  %complement = xor i32 %propertycode, -1
  %finalproperty = select i1 %neg, i32 %complement, i32 %propertycode
  %posixset = call ptr @rp_set(i32 1, i32 %finalproperty, i32 0, ptr null, ptr null)
  ret ptr %posixset
invalid:
  call void @rx_fail(ptr @rp_bad)
  %empty = call ptr @rp_set(i32 0, i32 1, i32 0, ptr null, ptr null)
  ret ptr %empty
}

define ptr @rx_parse_class(ptr %parser) {
entry:
  %open = call i32 @rp_take(ptr %parser)
  %head = call i32 @rp_peek(ptr %parser)
  %negative = icmp eq i32 %head, 94
  br i1 %negative, label %negate, label %begin
negate:
  %caret = call i32 @rp_take(ptr %parser)
  br label %begin
begin:
  br label %loop
loop:
  %segment = phi ptr [null, %begin], [%joined, %itemdone], [null, %intersection]
  %left = phi ptr [null, %begin], [%left, %itemdone], [%intersected, %intersection]
  %first = phi i1 [true, %begin], [false, %itemdone], [true, %intersection]
  %c = call i32 @rp_peek(ptr %parser)
  %eof = icmp slt i32 %c, 0
  br i1 %eof, label %invalid, label %closing
closing:
  %closechar = icmp eq i32 %c, 93
  %firstclose = and i1 %closechar, %first
  br i1 %firstclose, label %emptycheck, label %closecheck
emptycheck:
  %emptyip = getelementptr %RP, ptr %parser, i32 0, i32 2
  %emptyi = load i64, ptr %emptyip
  %emptynp = getelementptr %RP, ptr %parser, i32 0, i32 1
  %emptyn = load i64, ptr %emptynp
  %emptyafter = add i64 %emptyi, 1
  %emptyend = icmp eq i64 %emptyafter, %emptyn
  br i1 %emptyend, label %emptyclass, label %closecheck
emptyclass:
  call void @rx_fail(ptr @rp_emptyclass)
  ret ptr null
closecheck:
  %notfirst = xor i1 %first, true
  %close = and i1 %closechar, %notfirst
  br i1 %close, label %finish, label %andcheck
andcheck:
  %amp = icmp eq i32 %c, 38
  br i1 %amp, label %andprobe, label %item
andprobe:
  %ip = getelementptr %RP, ptr %parser, i32 0, i32 2
  %saved = load i64, ptr %ip
  %amp1 = call i32 @rp_take(ptr %parser)
  %nextchar = call i32 @rp_peek(ptr %parser)
  %amp2 = icmp eq i32 %nextchar, 38
  br i1 %amp2, label %intersection, label %andrestore
andrestore:
  store i64 %saved, ptr %ip
  br label %item
intersection:
  %ampsecond = call i32 @rp_take(ptr %parser)
  %combined = call ptr @rp_set(i32 3, i32 0, i32 0, ptr %left, ptr %segment)
  %initial = icmp eq ptr %left, null
  %intersected = select i1 %initial, ptr %segment, ptr %combined
  br label %loop
item:
  %nextset = call ptr @rp_item(ptr %parser)
  %union = call ptr @rp_set(i32 2, i32 0, i32 0, ptr %segment, ptr %nextset)
  br label %itemdone
itemdone:
  %joined = phi ptr [%union, %item]
  br label %loop
finish:
  %closer = call i32 @rp_take(ptr %parser)
  %both = call ptr @rp_set(i32 3, i32 0, i32 0, ptr %left, ptr %segment)
  %unintersected = icmp eq ptr %left, null
  %positive = select i1 %unintersected, ptr %segment, ptr %both
  %negated = call ptr @rp_set(i32 4, i32 0, i32 0, ptr %positive, ptr null)
  %result = select i1 %negative, ptr %negated, ptr %positive
  ret ptr %result
invalid:
  call void @rx_fail(ptr @rp_classend)
  ret ptr null
}

define i1 @rx_property_test(i32 %property, i32 %codepoint) {
  %negative = icmp slt i32 %property, 0
  %complement = xor i32 %property, -1
  %id = select i1 %negative, i32 %complement, i32 %property
  %member = call i1 @rx_unicode_has(i32 %id, i32 %codepoint)
  %result = xor i1 %member, %negative
  ret i1 %result
}

define i1 @rx_set_test(ptr %set, i32 %codepoint, i32 %flags) {
entry:
  %empty = icmp eq ptr %set, null
  br i1 %empty, label %no, label %read
read:
  %kind = load i32, ptr %set
  %lp = getelementptr %RS, ptr %set, i32 0, i32 1
  %hp = getelementptr %RS, ptr %set, i32 0, i32 2
  %ap = getelementptr %RS, ptr %set, i32 0, i32 3
  %bp = getelementptr %RS, ptr %set, i32 0, i32 4
  %lo = load i32, ptr %lp
  %hi = load i32, ptr %hp
  %a = load ptr, ptr %ap
  %b = load ptr, ptr %bp
  switch i32 %kind, label %no [i32 0, label %range i32 1, label %property i32 2, label %union i32 3, label %intersection i32 4, label %complement]
range:
  %bit = and i32 %flags, 1
  %insensitive = icmp ne i32 %bit, 0
  br i1 %insensitive, label %foldrange, label %exactrange
foldrange:
  %folded = call i1 @rx_unicode_case_range(i32 %codepoint, i32 %lo, i32 %hi)
  ret i1 %folded
exactrange:
  %lower = icmp uge i32 %codepoint, %lo
  %upper = icmp ule i32 %codepoint, %hi
  %between = and i1 %lower, %upper
  ret i1 %between
property:
  %propertyok = call i1 @rx_property_test(i32 %lo, i32 %codepoint)
  ret i1 %propertyok
union:
  %left = call i1 @rx_set_test(ptr %a, i32 %codepoint, i32 %flags)
  br i1 %left, label %yes, label %right
right:
  %rightvalue = call i1 @rx_set_test(ptr %b, i32 %codepoint, i32 %flags)
  ret i1 %rightvalue
intersection:
  %first = call i1 @rx_set_test(ptr %a, i32 %codepoint, i32 %flags)
  br i1 %first, label %right, label %no
complement:
  %positive = call i1 @rx_set_test(ptr %a, i32 %codepoint, i32 %flags)
  %negative = xor i1 %positive, true
  ret i1 %negative
yes:
  ret i1 true
no:
  ret i1 false
}
