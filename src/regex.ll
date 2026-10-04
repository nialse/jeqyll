%RP = type { ptr, i64, i64, i32, i32, ptr }
%RX = type { i32, i32, i32, i32, ptr, ptr, ptr }
%RC = type { ptr, ptr, ptr, i64, i32, i32, ptr, i64, i64, i64, ptr, ptr, ptr, ptr, i64 }
%RM = type { i64, i64, ptr }
%RS = type { i32, i32, i32, ptr, ptr }

@j_error = external global ptr
@rx_names = private constant [47 x i8] c"match\00test\00capture\00scan\00sub\00gsub\00splits\00split\00\00"
@rx_bad = private constant [31 x i8] c"Regex failure: invalid pattern\00"
@rx_groupend = private constant [36 x i8] c"Regex failure: end pattern in group\00"
@rx_groupname = private constant [36 x i8] c"Regex failure: invalid group name <\00"
@rx_groupnameend = private constant [2 x i8] c">\00"
@rx_unmatched = private constant [54 x i8] c"Regex failure: end pattern with unmatched parenthesis\00"
@rx_closeparen = private constant [43 x i8] c"Regex failure: unmatched close parenthesis\00"
@rx_repeatmissing = private constant [58 x i8] c"Regex failure: target of repeat operator is not specified\00"
@rx_repeatrange = private constant [59 x i8] c"Regex failure: upper is smaller than lower in repeat range\00"
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
@rx_propertybad = private constant [47 x i8] c"Regex failure: invalid character property name\00"
@rx_refbad = private constant [35 x i8] c"Regex failure: undefined reference\00"
@rx_zero = private constant [2 x i8] c"0\00"

declare ptr @j_alloc(i64)
declare void @j_copy(ptr, ptr, i64)
declare i64 @rx_capture_bytes(ptr)
declare i64 @rx_max_width(ptr, i64, i32)
declare ptr @rx_choice(ptr, ptr, i64, ptr, ptr)
declare void @rx_restore_choice(ptr, ptr, ptr)
declare i1 @rx_guard(ptr, ptr, i64)
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
declare i32 @j_cmp(ptr, ptr)
declare i32 @rx_unicode_property(ptr, i64)
declare i1 @rx_unicode_has(i32, i32)
declare i32 @rx_unicode_fold(i32)
declare i32 @rx_unicode_expand(i32, ptr)
declare i1 @rx_unicode_case_range(i32, i32, i32)
declare ptr @rx_parse_class(ptr)
declare i32 @rx_read_escape(ptr, i32)
declare i32 @rx_parse_property(ptr, i32)
declare ptr @rx_parse_named(ptr)
declare ptr @rx_parse_until(ptr, i32)
declare i1 @rx_property_test(i32, i32)
declare i1 @rx_set_test(ptr, i32, i32)
declare i64 @rx_assert(ptr, ptr, i64, ptr, i64)
declare i32 @rx_reference_id(ptr, i32, ptr, ptr)
declare {ptr, i64} @rx_literal_fold(ptr, ptr, i64)
declare i64 @rx_backref_fold(ptr, i64, i64, i64)
declare i64 @rx_grapheme_end(ptr, i64, i64)
declare i1 @rx_grapheme_boundary(ptr, i64, i64)
declare ptr @rx_call(ptr, ptr, i64)
declare ptr @rx_return(ptr)
declare i64 @rx_absent(ptr, ptr, i64, ptr, i64)
declare {ptr, i64} @rx_conditional(ptr, ptr, i64, ptr, i64)
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

define internal i1 @rx_search_bound_safe(ptr %ast) {
entry:
  %empty = icmp eq ptr %ast, null
  br i1 %empty, label %yes, label %read
read:
  %op = load i32, ptr %ast
  switch i32 %op, label %children [i32 15, label %no i32 16, label %no i32 28, label %no]
children:
  %ap = getelementptr %RX, ptr %ast, i32 0, i32 4
  %bp = getelementptr %RX, ptr %ast, i32 0, i32 5
  %a = load ptr, ptr %ap
  %b = load ptr, ptr %bp
  %left = call i1 @rx_search_bound_safe(ptr %a)
  br i1 %left, label %right, label %no
right:
  %result = call i1 @rx_search_bound_safe(ptr %b)
  ret i1 %result
yes:
  ret i1 true
no:
  ret i1 false
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
    i32 42, label %repeatmissing i32 43, label %repeatmissing i32 63, label %repeatmissing
  ]
repeatmissing:
  call void @rx_fail(ptr @rx_repeatmissing)
  br label %invalid
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
    i32 104, label %category i32 72, label %category
    i32 98, label %boundary i32 66, label %boundary
    i32 65, label %absolute_start i32 122, label %absolute_end i32 90, label %absolute_end
    i32 110, label %lf i32 114, label %cr i32 116, label %tab
    i32 102, label %ff i32 118, label %vt i32 112, label %property i32 80, label %property
    i32 107, label %namedref i32 71, label %searchstart i32 75, label %keep
    i32 82, label %newline i32 78, label %nondotall i32 79, label %alldot
    i32 81, label %quotechars
    i32 88, label %grapheme i32 121, label %graphemeboundary i32 89, label %graphemeboundary
    i32 103, label %subcall
  ]
property:
  %prop = call i32 @rx_parse_property(ptr %p, i32 %esc)
  %propnode = call ptr @rx_node(i32 19, i32 %prop, ptr null, ptr null, ptr null)
  ret ptr %propnode
namedref:
  %reference.name = call ptr @rx_parse_named(ptr %p)
  %referencecountp = getelementptr %RP, ptr %p, i32 0, i32 4
  %referencebase = load i32, ptr %referencecountp
  %namednode = call ptr @rx_node(i32 14, i32 %referencebase, ptr null, ptr null, ptr %reference.name)
  ret ptr %namednode
subcall:
  %callname = call ptr @rx_parse_named(ptr %p)
  %callcountp = getelementptr %RP, ptr %p, i32 0, i32 4
  %callbase = load i32, ptr %callcountp
  %callnode = call ptr @rx_node(i32 25, i32 %callbase, ptr null, ptr null, ptr %callname)
  ret ptr %callnode
searchstart:
  %searchnode = call ptr @rx_node(i32 21, i32 0, ptr null, ptr null, ptr null)
  ret ptr %searchnode
keep:
  %keepnode = call ptr @rx_node(i32 22, i32 0, ptr null, ptr null, ptr null)
  ret ptr %keepnode
newline:
  %newlinenode = call ptr @rx_node(i32 20, i32 0, ptr null, ptr null, ptr null)
  ret ptr %newlinenode
grapheme:
  %graphemenode = call ptr @rx_node(i32 23, i32 0, ptr null, ptr null, ptr null)
  ret ptr %graphemenode
graphemeboundary:
  %gbnode = call ptr @rx_node(i32 24, i32 %esc, ptr null, ptr null, ptr null)
  ret ptr %gbnode
nondotall:
  %notdotnode = call ptr @rx_node(i32 2, i32 1, ptr null, ptr null, ptr null)
  ret ptr %notdotnode
alldot:
  %alldotnode = call ptr @rx_node(i32 2, i32 2, ptr null, ptr null, ptr null)
  ret ptr %alldotnode
quotechars:
  br label %quoteloop
quoteloop:
  %quotedseq = phi ptr [null, %quotechars], [%quotednext, %quoteappend]
  %quotechar = call i32 @rx_take(ptr %p)
  %quoteeof = icmp slt i32 %quotechar, 0
  br i1 %quoteeof, label %quotedone, label %quotecheck
quotecheck:
  %quoteslash = icmp eq i32 %quotechar, 92
  br i1 %quoteslash, label %quoteescape, label %quoteappend
quoteescape:
  %qip = getelementptr %RP, ptr %p, i32 0, i32 2
  %qpos = load i64, ptr %qip
  %qescaped = call i32 @rx_take(ptr %p)
  %quoteend = icmp eq i32 %qescaped, 69
  br i1 %quoteend, label %quotedone, label %quoterestore
quoterestore:
  store i64 %qpos, ptr %qip
  br label %quoteappend
quoteappend:
  %quotedchar = call ptr @rx_node(i32 1, i32 %quotechar, ptr null, ptr null, ptr null)
  %quotednext = call ptr @rx_node(i32 4, i32 0, ptr %quotedseq, ptr %quotedchar, ptr null)
  br label %quoteloop
quotedone:
  ret ptr %quotedseq
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
  %softend = icmp eq i32 %esc, 90
  %endkind = select i1 %softend, i32 2, i32 1
  %ae = call ptr @rx_node(i32 9, i32 %endkind, ptr null, ptr null, ptr null)
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
  %decoded = call i32 @rx_read_escape(ptr %p, i32 %ec)
  %en = call ptr @rx_node(i32 1, i32 %decoded, ptr null, ptr null, ptr null)
  ret ptr %en
class:
  %classset = call ptr @rx_parse_class(ptr %p)
  %classnode = call ptr @rx_node(i32 3, i32 0, ptr null, ptr null, ptr %classset)
  ret ptr %classnode
group:
  %groupflagp = getelementptr %RP, ptr %p, i32 0, i32 3
  %groupflags = load i32, ptr %groupflagp
  call void @rx_advance(ptr %p)
  %q = call i32 @rx_peek(ptr %p)
  %special = icmp eq i32 %q, 63
  br i1 %special, label %groupmod, label %capture
groupmod:
  call void @rx_advance(ptr %p)
  %mod = call i32 @rx_peek(ptr %p)
  call void @rx_advance(ptr %p)
  switch i32 %mod, label %unsupported [ i32 58, label %noncapture i32 60, label %groupangle i32 39, label %namedquote i32 61, label %ahead i32 33, label %notahead i32 62, label %atomic i32 35, label %comment
    i32 -1, label %groupend
    i32 105, label %options i32 109, label %options i32 115, label %options i32 120, label %options i32 45, label %minusgroup
    i32 38, label %callnamed i32 82, label %callroot i32 40, label %conditional
    i32 126, label %absent
    i32 48, label %callnumber i32 49, label %callnumber i32 50, label %callnumber i32 51, label %callnumber i32 52, label %callnumber i32 53, label %callnumber i32 54, label %callnumber i32 55, label %callnumber i32 56, label %callnumber i32 57, label %callnumber ]
groupend:
  call void @rx_fail(ptr @rx_groupend)
  br label %invalid
minusgroup:
  %minusc = call i32 @rx_peek(ptr %p)
  %minusd = sub i32 %minusc, 48
  %minusnumber = icmp ult i32 %minusd, 10
  br i1 %minusnumber, label %callnumber, label %options
callnumber:
  %cnip = getelementptr %RP, ptr %p, i32 0, i32 2
  %cni = load i64, ptr %cnip
  %cnback = sub i64 %cni, 1
  store i64 %cnback, ptr %cnip
  br label %callnamed
callnamed:
  %groupcallname = call ptr @rx_parse_until(ptr %p, i32 41)
  br label %callgroup
callroot:
  %rootclose = call i32 @rx_peek(ptr %p)
  %rootclosed = icmp eq i32 %rootclose, 41
  br i1 %rootclosed, label %callrootdone, label %invalid
callrootdone:
  call void @rx_advance(ptr %p)
  %rootname = call ptr @j_cstr(ptr @rx_zero)
  br label %callgroup
callgroup:
  %subname = phi ptr [%groupcallname, %callnamed], [%rootname, %callrootdone]
  %subcountp = getelementptr %RP, ptr %p, i32 0, i32 4
  %subbase = load i32, ptr %subcountp
  %subnode = call ptr @rx_node(i32 25, i32 %subbase, ptr null, ptr null, ptr %subname)
  ret ptr %subnode
conditional:
  %conditionhead = call i32 @rx_peek(ptr %p)
  %conditionangle = icmp eq i32 %conditionhead, 60
  %conditionquote = icmp eq i32 %conditionhead, 39
  %conditionwrapped = or i1 %conditionangle, %conditionquote
  br i1 %conditionwrapped, label %conditionnamed, label %conditiondispatch
conditiondispatch:
  %conditiondigit = sub i32 %conditionhead, 48
  %conditionnumber = icmp ult i32 %conditiondigit, 10
  %conditionminus = icmp eq i32 %conditionhead, 45
  %conditionplus = icmp eq i32 %conditionhead, 43
  %conditionsign = or i1 %conditionminus, %conditionplus
  %conditionref = or i1 %conditionnumber, %conditionsign
  br i1 %conditionref, label %conditionplain, label %conditionpattern
conditionpattern:
  %conditionquestion = icmp eq i32 %conditionhead, 63
  br i1 %conditionquestion, label %conditionassert, label %conditionregex
conditionassert:
  %conditionip = getelementptr %RP, ptr %p, i32 0, i32 2
  %conditionpos = load i64, ptr %conditionip
  %conditionback = sub i64 %conditionpos, 1
  store i64 %conditionback, ptr %conditionip
  %conditionassertion = call ptr @rx_atom(ptr %p)
  br label %conditionbody
conditionregex:
  %conditionexpression = call ptr @rx_expr(ptr %p)
  %conditionregexclose = call i32 @rx_peek(ptr %p)
  %conditionregexclosed = icmp eq i32 %conditionregexclose, 41
  br i1 %conditionregexclosed, label %conditionregexdone, label %invalid
conditionregexdone:
  call void @rx_advance(ptr %p)
  br label %conditionbody
conditionnamed:
  %wrappedcondition = call ptr @rx_parse_named(ptr %p)
  %conditionclose = call i32 @rx_peek(ptr %p)
  %conditionclosed = icmp eq i32 %conditionclose, 41
  br i1 %conditionclosed, label %conditionadvance, label %invalid
conditionadvance:
  call void @rx_advance(ptr %p)
  br label %conditionbody
conditionplain:
  %plaincondition = call ptr @rx_parse_until(ptr %p, i32 41)
  br label %conditionbody
conditionbody:
  %conditionname = phi ptr [%wrappedcondition, %conditionadvance], [%plaincondition, %conditionplain], [%conditionassertion, %conditionassert], [%conditionexpression, %conditionregexdone]
  %conditionkind = phi i32 [26, %conditionadvance], [26, %conditionplain], [28, %conditionassert], [28, %conditionregexdone]
  %conditioncountp = getelementptr %RP, ptr %p, i32 0, i32 4
  %conditionbase = load i32, ptr %conditioncountp
  %then = call ptr @rx_sequence(ptr %p)
  %conditionsep = call i32 @rx_peek(ptr %p)
  %haselse = icmp eq i32 %conditionsep, 124
  br i1 %haselse, label %conditionelse, label %conditionnoelse
conditionelse:
  call void @rx_advance(ptr %p)
  %else = call ptr @rx_expr(ptr %p)
  br label %conditionend
conditionnoelse:
  br label %conditionend
conditionend:
  %elsebody = phi ptr [%else, %conditionelse], [null, %conditionnoelse]
  %conditionalclose = call i32 @rx_peek(ptr %p)
  %conditionalclosed = icmp eq i32 %conditionalclose, 41
  br i1 %conditionalclosed, label %conditiondone, label %invalid
conditiondone:
  call void @rx_advance(ptr %p)
  %conditionnode = call ptr @rx_node(i32 %conditionkind, i32 %conditionbase, ptr %then, ptr %elsebody, ptr %conditionname)
  ret ptr %conditionnode
absent:
  %absenthead = call i32 @rx_peek(ptr %p)
  %absentbar = icmp eq i32 %absenthead, 124
  br i1 %absentbar, label %absentextended, label %absentrepeat
absentrepeat:
  %absentbody = call ptr @rx_expr(ptr %p)
  br label %absentend
absentextended:
  call void @rx_advance(ptr %p)
  %absentfirst = call i32 @rx_peek(ptr %p)
  %absentclear = icmp eq i32 %absentfirst, 41
  br i1 %absentclear, label %absentclearbody, label %absentexpression
absentclearbody:
  br label %absentend
absentexpression:
  %absenttest = call ptr @rx_sequence(ptr %p)
  %absentsep = call i32 @rx_peek(ptr %p)
  %absenthasexpr = icmp eq i32 %absentsep, 124
  br i1 %absenthasexpr, label %absentexprbody, label %absentstopper
absentexprbody:
  call void @rx_advance(ptr %p)
  %absentexpr = call ptr @rx_expr(ptr %p)
  br label %absentend
absentstopper:
  br label %absentend
absentend:
  %absentmode = phi i32 [0, %absentrepeat], [3, %absentclearbody], [1, %absentexprbody], [2, %absentstopper]
  %absentpattern = phi ptr [%absentbody, %absentrepeat], [null, %absentclearbody], [%absenttest, %absentexprbody], [%absenttest, %absentstopper]
  %absentfilter = phi ptr [null, %absentrepeat], [null, %absentclearbody], [%absentexpr, %absentexprbody], [null, %absentstopper]
  %absentclose = call i32 @rx_peek(ptr %p)
  %absentclosed = icmp eq i32 %absentclose, 41
  br i1 %absentclosed, label %absentdone, label %invalid
absentdone:
  call void @rx_advance(ptr %p)
  %absentnode = call ptr @rx_node(i32 27, i32 %absentmode, ptr %absentpattern, ptr %absentfilter, ptr null)
  ret ptr %absentnode
groupangle:
  %anglechar = call i32 @rx_peek(ptr %p)
  switch i32 %anglechar, label %namedangle [i32 61, label %behind i32 33, label %notbehind]
behind:
  call void @rx_advance(ptr %p)
  br label %groupbody
notbehind:
  call void @rx_advance(ptr %p)
  br label %groupbody
namedangle:
  br label %namedcapture
namedquote:
  br label %namedcapture
namedcapture:
  %namecloser = phi i32 [62, %namedangle], [39, %namedquote]
  %nip = getelementptr %RP, ptr %p, i32 0, i32 2
  %ns = load i64, ptr %nip
  br label %nameloop
nameloop:
  %nc = call i32 @rx_peek(ptr %p)
  %ne = icmp eq i32 %nc, %namecloser
  br i1 %ne, label %nameend, label %namenext
namenext:
  %nmissing = icmp slt i32 %nc, 0
  br i1 %nmissing, label %nameinvalid, label %nameadvance
nameinvalid:
  %badnameend = load i64, ptr %nip
  %badnamedata = load ptr, ptr %p
  %badnameptr = getelementptr i8, ptr %badnamedata, i64 %ns
  %badnamelen = sub i64 %badnameend, %ns
  %badname = call ptr @j_str(ptr %badnameptr, i64 %badnamelen)
  %badnameprefix = call ptr @j_cstr(ptr @rx_groupname)
  %badnamesuffix = call ptr @j_cstr(ptr @rx_groupnameend)
  %badnamestart = call ptr @j_binary(i32 0, ptr %badnameprefix, ptr %badname)
  %badnamemessage = call ptr @j_binary(i32 0, ptr %badnamestart, ptr %badnamesuffix)
  %badmessageptr = call ptr @b_data(ptr %badnamemessage)
  call void @rx_fail(ptr %badmessageptr)
  br label %invalid
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
atomic:
  br label %groupbody
options:
  %oip = getelementptr %RP, ptr %p, i32 0, i32 2
  %oi = load i64, ptr %oip
  %beforeoption = sub i64 %oi, 1
  store i64 %beforeoption, ptr %oip
  %optiongroup = call ptr @rx_options_group(ptr %p)
  ret ptr %optiongroup
comment:
  %commentchar = call i32 @rx_take(ptr %p)
  %commentend = icmp eq i32 %commentchar, 41
  %commenteof = icmp slt i32 %commentchar, 0
  br i1 %commenteof, label %invalid, label %commentcheck
commentcheck:
  br i1 %commentend, label %commentdone, label %comment
commentdone:
  %commentnode = call ptr @rx_node(i32 0, i32 0, ptr null, ptr null, ptr null)
  ret ptr %commentnode
groupbody:
  %groupkind = phi i32 [7, %register], [0, %noncapture], [11, %ahead], [12, %notahead], [15, %behind], [16, %notbehind], [17, %atomic]
  %groupindex = phi i32 [%count, %register], [0, %noncapture], [0, %ahead], [0, %notahead], [0, %behind], [0, %notbehind], [0, %atomic]
  %body = call ptr @rx_expr(ptr %p)
  %closer = call i32 @rx_peek(ptr %p)
  %closed = icmp eq i32 %closer, 41
  br i1 %closed, label %groupdone, label %unmatchedgroup
unmatchedgroup:
  call void @rx_fail(ptr @rx_unmatched)
  br label %invalid
groupdone:
  call void @rx_advance(ptr %p)
  store i32 %groupflags, ptr %groupflagp
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
  call void @rx_fail(ptr @rx_bad)
  %badn = call ptr @rx_node(i32 0, i32 0, ptr null, ptr null, ptr null)
  ret ptr %badn
}

define internal ptr @rx_options_group(ptr %p) {
entry:
  %fp = getelementptr %RP, ptr %p, i32 0, i32 3
  %old = load i32, ptr %fp
  br label %loop
loop:
  %flags = phi i32 [%old, %entry], [%updated, %apply], [%flags, %minus]
  %enable = phi i1 [true, %entry], [%enable, %apply], [false, %minus]
  %c = call i32 @rx_take(ptr %p)
  switch i32 %c, label %invalid [i32 105, label %ignorecase i32 109, label %multiline i32 115, label %dotall i32 120, label %extended i32 45, label %minus i32 58, label %scoped i32 41, label %isolated]
minus:
  br label %loop
ignorecase:
  br label %apply
multiline:
  br label %apply
dotall:
  br label %apply
extended:
  br label %apply
apply:
  %bit = phi i32 [1, %ignorecase], [8, %multiline], [2, %dotall], [4, %extended]
  %inverted = icmp eq i32 %c, 109
  %set = xor i1 %enable, %inverted
  %mask = xor i32 %bit, -1
  %cleared = and i32 %flags, %mask
  %added = or i32 %flags, %bit
  %updated = select i1 %set, i32 %added, i32 %cleared
  br label %loop
scoped:
  br label %body
isolated:
  br label %body
body:
  %scopedmode = phi i1 [true, %scoped], [false, %isolated]
  store i32 %flags, ptr %fp
  %inside = call ptr @rx_expr(ptr %p)
  store i32 %old, ptr %fp
  br i1 %scopedmode, label %close, label %done
close:
  %closer = call i32 @rx_peek(ptr %p)
  %closed = icmp eq i32 %closer, 41
  br i1 %closed, label %advance, label %invalid
advance:
  call void @rx_advance(ptr %p)
  br label %done
done:
  %node = call ptr @rx_node(i32 18, i32 %flags, ptr %inside, ptr null, ptr null)
  %oldp = getelementptr %RX, ptr %node, i32 0, i32 2
  store i32 %old, ptr %oldp
  ret ptr %node
invalid:
  call void @rx_fail(ptr @rx_bad)
  %empty = call ptr @rx_node(i32 0, i32 0, ptr null, ptr null, ptr null)
  ret ptr %empty
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
  %possessive = icmp eq i32 %lazychar, 43
  %modifier = or i1 %lazy, %possessive
  br i1 %modifier, label %lazynext, label %repeatnode
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
  %atomicrepeat = call ptr @rx_node(i32 17, i32 0, ptr %rn, ptr null, ptr null)
  %repeated = select i1 %possessive, ptr %atomicrepeat, ptr %rn
  br label %append
unquantified:
  br label %append
append:
  %item = phi ptr [ %an, %unquantified ], [ %repeated, %repeatnode ]
  %joined = call ptr @rx_node(i32 4, i32 0, ptr %seq, ptr %item, ptr null)
  br label %loop
invalid:
  call void @rx_fail(ptr @rx_bad)
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
  switch i32 %op, label %simple [i32 0, label %same i32 4, label %concat i32 5, label %alternate i32 6, label %repeat i32 7, label %group i32 11, label %ahead i32 12, label %ahead i32 15, label %behind i32 16, label %behind i32 17, label %ahead i32 18, label %options i32 26, label %conditional i32 28, label %conditionalexpression i32 27, label %absent]
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
conditional:
  %yes = call ptr @rx_compile(ptr %a, ptr %next)
  %no = call ptr @rx_compile(ptr %b, ptr %next)
  %condition = call ptr @rx_node(i32 26, i32 %val, ptr %yes, ptr %no, ptr %data)
  ret ptr %condition
conditionalexpression:
  %conditionyes = call ptr @rx_compile(ptr %a, ptr %next)
  %conditionno = call ptr @rx_compile(ptr %b, ptr %next)
  %conditiontest = call ptr @rx_compile(ptr %data, ptr null)
  %conditionexpr = call ptr @rx_node(i32 28, i32 0, ptr %conditionyes, ptr %conditionno, ptr %conditiontest)
  ret ptr %conditionexpr
absent:
  %absenttest = call ptr @rx_compile(ptr %a, ptr null)
  %absentreturn = call ptr @rx_node(i32 31, i32 0, ptr null, ptr null, ptr null)
  %absentexpr = call ptr @rx_compile(ptr %b, ptr %absentreturn)
  %absentnode = call ptr @rx_node(i32 27, i32 %val, ptr %next, ptr %absenttest, ptr %absentexpr)
  ret ptr %absentnode
group:
  %end = call ptr @rx_node(i32 6, i32 %val, ptr %next, ptr null, ptr null)
  %inside = call ptr @rx_compile(ptr %a, ptr %end)
  %start = call ptr @rx_node(i32 5, i32 %val, ptr %inside, ptr null, ptr null)
  ret ptr %start
ahead:
  %inner = call ptr @rx_compile(ptr %a, ptr null)
  %look = call ptr @rx_node(i32 %op, i32 %val, ptr %next, ptr %inner, ptr null)
  ret ptr %look
behind:
  %assertend = call ptr @rx_node(i32 30, i32 0, ptr null, ptr null, ptr null)
  %behindinner = call ptr @rx_compile(ptr %a, ptr %assertend)
  %behindnode = call ptr @rx_node(i32 %op, i32 0, ptr %next, ptr %behindinner, ptr null)
  ret ptr %behindnode
options:
  %oldp = getelementptr %RX, ptr %ast, i32 0, i32 2
  %oldflags = load i32, ptr %oldp
  %restore = call ptr @rx_node(i32 18, i32 %oldflags, ptr %next, ptr null, ptr null)
  %optionbody = call ptr @rx_compile(ptr %a, ptr %restore)
  %optionstart = call ptr @rx_node(i32 18, i32 %val, ptr %optionbody, ptr null, ptr null)
  ret ptr %optionstart
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
entry:
  %bit = and i32 %flags, 1
  %enabled = icmp ne i32 %bit, 0
  br i1 %enabled, label %fold, label %same
fold:
  %result = call i32 @rx_unicode_fold(i32 %c)
  ret i32 %result
same:
  ret i32 %c
}

define internal i1 @rx_category(i32 %code, i32 %c) {
entry:
  %kind = or i32 %code, 32
  switch i32 %kind, label %word [ i32 100, label %digit i32 115, label %space i32 104, label %hex ]
digit:
  %d = call i1 @rx_unicode_has(i32 4, i32 %c)
  br label %done
space:
  %sw = call i1 @rx_unicode_has(i32 9, i32 %c)
  br label %done
word:
  %w = call i1 @rx_unicode_has(i32 12, i32 %c)
  br label %done
hex:
  %h = call i1 @rx_unicode_has(i32 11, i32 %c)
  br label %done
done:
  %test = phi i1 [ %d, %digit ], [ %sw, %space ], [ %w, %word ], [%h, %hex]
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

define i64 @rx_run(ptr %initialnode, ptr %ctx, i64 %initialpos, ptr %captures, i64 %depth) {
entry:
  %over = icmp ugt i64 %depth, 8192
  br i1 %over, label %resource, label %initialize
initialize:
  %cursor = alloca ptr
  %position = alloca i64
  %choices = alloca ptr
  %bestendp = alloca i64
  %bestkeepp = alloca i64
  %originalctx = alloca %RC
  call void @j_copy(ptr %originalctx, ptr %ctx, i64 112)
  %capturebytes = call i64 @rx_capture_bytes(ptr %ctx)
  %originalcaps = call ptr @j_alloc(i64 %capturebytes)
  %bestcaps = call ptr @j_alloc(i64 %capturebytes)
  call void @j_copy(ptr %originalcaps, ptr %captures, i64 %capturebytes)
  %initialflagp = getelementptr %RC, ptr %ctx, i32 0, i32 4
  %initialflags = load i32, ptr %initialflagp
  %longestbit = and i32 %initialflags, 64
  %longest = icmp ne i32 %longestbit, 0
  store ptr %initialnode, ptr %cursor
  store i64 %initialpos, ptr %position
  store ptr null, ptr %choices
  store i64 -1, ptr %bestendp
  store i64 -1, ptr %bestkeepp
  %nd = add i64 %depth, 1
  br label %dispatch
dispatch:
  %node = load ptr, ptr %cursor
  %pos = load i64, ptr %position
  %accept = icmp eq ptr %node, null
  br i1 %accept, label %success, label %fields
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
  %limitp = getelementptr %RC, ptr %ctx, i32 0, i32 14
  %limit = load i64, ptr %limitp
  %fp = getelementptr %RC, ptr %ctx, i32 0, i32 4
  %flags = load i32, ptr %fp
  switch i32 %op, label %consuming [
    i32 0, label %success i32 4, label %split i32 5, label %save i32 6, label %save
    i32 8, label %start i32 9, label %end i32 10, label %boundary
    i32 11, label %lookahead i32 12, label %lookahead i32 14, label %reference
    i32 15, label %lookahead i32 16, label %lookahead i32 17, label %lookahead
    i32 18, label %options i32 21, label %searchstart i32 22, label %keep i32 30, label %assertend
    i32 24, label %graphemeboundary
    i32 25, label %subcall i32 26, label %conditional i32 31, label %return
    i32 27, label %absent
    i32 28, label %conditionalexpression
  ]
consuming:
  %available = icmp ult i64 %pos, %limit
  br i1 %available, label %consumechar, label %fail
consumechar:
  %cp = getelementptr i32, ptr %cps, i64 %pos
  %c = load i32, ptr %cp
  switch i32 %op, label %fail [i32 1, label %literal i32 2, label %dot i32 3, label %class i32 13, label %category i32 19, label %property i32 20, label %newline i32 23, label %grapheme]
literal:
  %icbit = and i32 %flags, 1
  %insensitive = icmp ne i32 %icbit, 0
  br i1 %insensitive, label %literalfold, label %literalexact
literalfold:
  %literalresult = call {ptr, i64} @rx_literal_fold(ptr %node, ptr %ctx, i64 %pos)
  %literaltail = extractvalue {ptr, i64} %literalresult, 0
  %literalend = extractvalue {ptr, i64} %literalresult, 1
  %literalfound = icmp sge i64 %literalend, 0
  br i1 %literalfound, label %literaladvance, label %fail
literaladvance:
  store ptr %literaltail, ptr %cursor
  store i64 %literalend, ptr %position
  br label %dispatch
literalexact:
  %same = icmp eq i32 %c, %value
  br i1 %same, label %consume, label %fail
grapheme:
  %graphemeend = call i64 @rx_grapheme_end(ptr %cps, i64 %n, i64 %pos)
  %graphemewithin = icmp ule i64 %graphemeend, %limit
  br i1 %graphemewithin, label %graphemedone, label %fail
graphemedone:
  store i64 %graphemeend, ptr %position
  br label %continue
graphemeboundary:
  %gbound = call i1 @rx_grapheme_boundary(ptr %cps, i64 %n, i64 %pos)
  %gnegative = icmp eq i32 %value, 89
  %gboundok = xor i1 %gbound, %gnegative
  br i1 %gboundok, label %continue, label %fail
dot:
  %dotall = and i32 %flags, 2
  %any = icmp ne i32 %dotall, 0
  %notlf = icmp ne i32 %c, 10
  %forcedall = icmp eq i32 %value, 2
  %forcednot = icmp eq i32 %value, 1
  %normaldot = or i1 %any, %notlf
  %selecteddot = select i1 %forcednot, i1 %notlf, i1 %normaldot
  %dotok = or i1 %selecteddot, %forcedall
  br i1 %dotok, label %consume, label %fail
class:
  %classok = call i1 @rx_set_test(ptr %data, i32 %c, i32 %flags)
  br i1 %classok, label %consume, label %fail
category:
  %catok = call i1 @rx_category(i32 %value, i32 %c)
  br i1 %catok, label %consume, label %fail
property:
  %propertyok = call i1 @rx_property_test(i32 %value, i32 %c)
  br i1 %propertyok, label %consume, label %fail
newline:
  %cr = icmp eq i32 %c, 13
  br i1 %cr, label %newlinecr, label %newlinetest
newlinecr:
  %crnext = add i64 %pos, 1
  %crmore = icmp ult i64 %crnext, %limit
  br i1 %crmore, label %newlinepair, label %consume
newlinepair:
  %crnp = getelementptr i32, ptr %cps, i64 %crnext
  %crnc = load i32, ptr %crnp
  %crlf = icmp eq i32 %crnc, 10
  br i1 %crlf, label %newlineboth, label %consume
newlineboth:
  %crend = add i64 %pos, 2
  store i64 %crend, ptr %position
  br label %continue
newlinetest:
  %nlstart = icmp uge i32 %c, 10
  %nlend = icmp ule i32 %c, 13
  %ascii_nl = and i1 %nlstart, %nlend
  %nel = icmp eq i32 %c, 133
  %ls = icmp eq i32 %c, 8232
  %ps = icmp eq i32 %c, 8233
  %nl0 = or i1 %ascii_nl, %nel
  %nl1 = or i1 %ls, %ps
  %newlineok = or i1 %nl0, %nl1
  br i1 %newlineok, label %consume, label %fail
consume:
  %nextpos = add i64 %pos, 1
  store i64 %nextpos, ptr %position
  br label %continue
split:
  %splitallowed = call i1 @rx_guard(ptr %node, ptr %ctx, i64 %pos)
  br i1 %splitallowed, label %choice, label %fail
choice:
  %previouschoice = load ptr, ptr %choices
  %choiceframe = call ptr @rx_choice(ptr %previouschoice, ptr %b, i64 %pos, ptr %ctx, ptr %captures)
  store ptr %choiceframe, ptr %choices
  br label %continue
save:
  %capindex = mul i32 %value, 2
  %last = icmp eq i32 %op, 6
  %lastbit = zext i1 %last to i32
  %capi = add i32 %capindex, %lastbit
  %capi64 = zext i32 %capi to i64
  %cap = getelementptr i64, ptr %captures, i64 %capi64
  store i64 %pos, ptr %cap
  br label %continue
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
  %eabs = icmp eq i32 %value, 1
  %esoft = icmp eq i32 %value, 2
  %absend = or i1 %esingle, %eabs
  %eallowed = xor i1 %absend, true
  %endallowed = or i1 %eallowed, %esoft
  br i1 %endallowed, label %endchar, label %fail
endchar:
  %endp = getelementptr i32, ptr %cps, i64 %pos
  %endc = load i32, ptr %endp
  %endlf = icmp eq i32 %endc, 10
  %endnext = add i64 %pos, 1
  %endlast = icmp eq i64 %endnext, %n
  %softok = select i1 %esoft, i1 %endlast, i1 true
  %endok = and i1 %endlf, %softok
  br i1 %endok, label %continue, label %fail
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
  %assertion = call i64 @rx_assert(ptr %node, ptr %ctx, i64 %pos, ptr %captures, i64 %nd)
  %asserted = icmp sge i64 %assertion, 0
  br i1 %asserted, label %assertionadvance, label %fail
assertionadvance:
  store i64 %assertion, ptr %position
  br label %continue
options:
  store i32 %value, ptr %fp
  br label %continue
searchstart:
  %originp = getelementptr %RC, ptr %ctx, i32 0, i32 7
  %origin = load i64, ptr %originp
  %atsearch = icmp eq i64 %pos, %origin
  br i1 %atsearch, label %continue, label %fail
keep:
  %keepp = getelementptr %RC, ptr %ctx, i32 0, i32 8
  store i64 %pos, ptr %keepp
  br label %continue
assertend:
  %targetp = getelementptr %RC, ptr %ctx, i32 0, i32 9
  %target = load i64, ptr %targetp
  %attarget = icmp eq i64 %pos, %target
  br i1 %attarget, label %success, label %fail
reference:
  %ccp = getelementptr %RC, ptr %ctx, i32 0, i32 5
  %cc = load i32, ptr %ccp
  %refid = call i32 @rx_reference_id(ptr %data, i32 %value, ptr %ctx, ptr %captures)
  %refvalid = icmp ult i32 %refid, %cc
  br i1 %refvalid, label %refvalue, label %fail
subcall:
  %subbody = call ptr @rx_call(ptr %node, ptr %ctx, i64 %pos)
  %subvalid = icmp ne ptr %subbody, null
  br i1 %subvalid, label %subenter, label %fail
subenter:
  store ptr %subbody, ptr %cursor
  br label %dispatch
absent:
  %absentresult = call i64 @rx_absent(ptr %node, ptr %ctx, i64 %pos, ptr %captures, i64 %nd)
  br label %helperresult
return:
  %returnnode = call ptr @rx_return(ptr %ctx)
  store ptr %returnnode, ptr %cursor
  br label %dispatch
conditional:
  %conditionid = call i32 @rx_reference_id(ptr %data, i32 %value, ptr %ctx, ptr %captures)
  %conditionccp = getelementptr %RC, ptr %ctx, i32 0, i32 5
  %conditioncount = load i32, ptr %conditionccp
  %conditionvalid = icmp ult i32 %conditionid, %conditioncount
  br i1 %conditionvalid, label %conditioncapture, label %conditionfalse
conditionalexpression:
  %conditionresult = call {ptr, i64} @rx_conditional(ptr %node, ptr %ctx, i64 %pos, ptr %captures, i64 %nd)
  %conditionnode = extractvalue {ptr, i64} %conditionresult, 0
  %conditionpos = extractvalue {ptr, i64} %conditionresult, 1
  store ptr %conditionnode, ptr %cursor
  store i64 %conditionpos, ptr %position
  br label %dispatch
helperresult:
  %helperend = phi i64 [%absentresult, %absent]
  %helperfound = icmp sge i64 %helperend, 0
  br i1 %helperfound, label %accepted, label %fail
conditioncapture:
  %conditioni = sext i32 %conditionid to i64
  %conditionslot = mul i64 %conditioni, 2
  %conditionp = getelementptr i64, ptr %captures, i64 %conditionslot
  %conditionstart = load i64, ptr %conditionp
  %conditiontrue = icmp sge i64 %conditionstart, 0
  br i1 %conditiontrue, label %conditionyes, label %conditionfalse
conditionyes:
  br label %continue
conditionfalse:
  store ptr %b, ptr %cursor
  br label %dispatch
refvalue:
  %refi = mul i32 %refid, 2
  %refi64 = zext i32 %refi to i64
  %refp = getelementptr i64, ptr %captures, i64 %refi64
  %refstart = load i64, ptr %refp
  %refep = getelementptr i64, ptr %refp, i64 1
  %refend = load i64, ptr %refep
  %refset = icmp sge i64 %refstart, 0
  %refclosed = icmp sge i64 %refend, %refstart
  %refcomplete = and i1 %refset, %refclosed
  %reflen = sub i64 %refend, %refstart
  %refafter = add i64 %pos, %reflen
  %refbounds = icmp ule i64 %refafter, %limit
  %refibit = and i32 %flags, 1
  %refinsensitive = icmp ne i32 %refibit, 0
  %refboundsok = or i1 %refbounds, %refinsensitive
  %refready = and i1 %refcomplete, %refboundsok
  br i1 %refready, label %refmode, label %fail
refmode:
  br i1 %refinsensitive, label %reffold, label %refloop
reffold:
  %reffoldend = call i64 @rx_backref_fold(ptr %ctx, i64 %refstart, i64 %refend, i64 %pos)
  %reffoldok = icmp sge i64 %reffoldend, 0
  br i1 %reffoldok, label %reffolddone, label %fail
reffolddone:
  store i64 %reffoldend, ptr %position
  br label %continue
refloop:
  %r = phi i64 [ 0, %refmode ], [ %rn, %refnext ]
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
  store i64 %refafter, ptr %position
  br label %continue
continue:
  store ptr %a, ptr %cursor
  br label %dispatch
success:
  %successfp = getelementptr %RC, ptr %ctx, i32 0, i32 4
  %successflags = load i32, ptr %successfp
  %nbit = and i32 %successflags, 32
  %notempty = icmp ne i32 %nbit, 0
  %successkp = getelementptr %RC, ptr %ctx, i32 0, i32 8
  %successkeep = load i64, ptr %successkp
  %isempty = icmp eq i64 %pos, %successkeep
  %denyempty = and i1 %notempty, %isempty
  br i1 %denyempty, label %fail, label %accepted
accepted:
  %matchend = phi i64 [%pos, %success], [%helperend, %helperresult]
  %previousbest = load i64, ptr %bestendp
  %better = icmp sgt i64 %matchend, %previousbest
  br i1 %better, label %savebest, label %nextmatch
savebest:
  store i64 %matchend, ptr %bestendp
  %bestkp = getelementptr %RC, ptr %ctx, i32 0, i32 8
  %bestkeep = load i64, ptr %bestkp
  store i64 %bestkeep, ptr %bestkeepp
  call void @j_copy(ptr %bestcaps, ptr %captures, i64 %capturebytes)
  br label %nextmatch
nextmatch:
  %endlimitp = getelementptr %RC, ptr %ctx, i32 0, i32 3
  %endlimit = load i64, ptr %endlimitp
  %room = icmp ult i64 %matchend, %endlimit
  %searchmore = and i1 %longest, %room
  br i1 %searchmore, label %fail, label %finish
fail:
  %pendingerror = load ptr, ptr @j_error
  %errored = icmp ne ptr %pendingerror, null
  br i1 %errored, label %abort, label %backtrack
backtrack:
  %retryframe = load ptr, ptr %choices
  %haschoice = icmp ne ptr %retryframe, null
  br i1 %haschoice, label %retry, label %finish
retry:
  %remaining = load ptr, ptr %retryframe
  %retrynodep = getelementptr ptr, ptr %retryframe, i64 1
  %retryposp = getelementptr i64, ptr %retryframe, i64 2
  %retrynode = load ptr, ptr %retrynodep
  %retrypos = load i64, ptr %retryposp
  call void @rx_restore_choice(ptr %retryframe, ptr %ctx, ptr %captures)
  store ptr %remaining, ptr %choices
  store ptr %retrynode, ptr %cursor
  store i64 %retrypos, ptr %position
  br label %dispatch
abort:
  store i64 -1, ptr %bestendp
  br label %finish
finish:
  %finalend = load i64, ptr %bestendp
  %matched = icmp sge i64 %finalend, 0
  %finalcaps = select i1 %matched, ptr %bestcaps, ptr %originalcaps
  call void @j_copy(ptr %ctx, ptr %originalctx, i64 112)
  call void @j_copy(ptr %captures, ptr %finalcaps, i64 %capturebytes)
  br i1 %matched, label %finishkeep, label %done
finishkeep:
  %finalkeep = load i64, ptr %bestkeepp
  %finalkeepp = getelementptr %RC, ptr %ctx, i32 0, i32 8
  store i64 %finalkeep, ptr %finalkeepp
  br label %done
done:
  ret i64 %finalend
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
    i8 115, label %singleline i8 112, label %both i8 103, label %global i8 110, label %noempty i8 108, label %longest
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
longest:
  br label %add
add:
  %bit = phi i32 [ 1, %insensitive ], [ 2, %multiline ], [ 4, %extended ], [ 8, %singleline ], [ 10, %both ], [ 16, %global ], [ 32, %noempty ], [64, %longest]
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
  %ctx = call ptr @j_alloc(i64 112)
  store ptr %input, ptr %ctx
  %cpp = getelementptr %RC, ptr %ctx, i32 0, i32 1
  store ptr %cps, ptr %cpp
  %opp = getelementptr %RC, ptr %ctx, i32 0, i32 2
  store ptr %offsets, ptr %opp
  %np = getelementptr %RC, ptr %ctx, i32 0, i32 3
  store i64 %i, ptr %np
  %limitp = getelementptr %RC, ptr %ctx, i32 0, i32 14
  store i64 %i, ptr %limitp
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

define internal void @rx_collect_groups(ptr %node, ptr %groups) {
entry:
  %empty = icmp eq ptr %node, null
  br i1 %empty, label %done, label %read
read:
  %op = load i32, ptr %node
  %ap = getelementptr %RX, ptr %node, i32 0, i32 4
  %bp = getelementptr %RX, ptr %node, i32 0, i32 5
  %a = load ptr, ptr %ap
  %b = load ptr, ptr %bp
  switch i32 %op, label %done [i32 7, label %group i32 4, label %both i32 5, label %both i32 26, label %both i32 27, label %both i32 28, label %three i32 6, label %one i32 11, label %one i32 12, label %one i32 15, label %one i32 16, label %one i32 17, label %one i32 18, label %one]
three:
  %dp = getelementptr %RX, ptr %node, i32 0, i32 6
  %condition = load ptr, ptr %dp
  call void @rx_collect_groups(ptr %condition, ptr %groups)
  br label %both
group:
  call void @j_push(ptr %groups, ptr %node)
  br label %one
both:
  call void @rx_collect_groups(ptr %a, ptr %groups)
  call void @rx_collect_groups(ptr %b, ptr %groups)
  br label %done
one:
  call void @rx_collect_groups(ptr %a, ptr %groups)
  br label %done
done:
  ret void
}

define internal void @rx_validate(ptr %node, ptr %ctx) {
entry:
  %empty = icmp eq ptr %node, null
  br i1 %empty, label %done, label %read
read:
  %op = load i32, ptr %node
  %vp = getelementptr %RX, ptr %node, i32 0, i32 1
  %value = load i32, ptr %vp
  %ap = getelementptr %RX, ptr %node, i32 0, i32 4
  %bp = getelementptr %RX, ptr %node, i32 0, i32 5
  %dp = getelementptr %RX, ptr %node, i32 0, i32 6
  %a = load ptr, ptr %ap
  %b = load ptr, ptr %bp
  %data = load ptr, ptr %dp
  switch i32 %op, label %done [i32 14, label %reference i32 25, label %reference i32 26, label %reference i32 4, label %both i32 5, label %both i32 27, label %both i32 28, label %three i32 6, label %repeat i32 7, label %one i32 11, label %one i32 12, label %one i32 15, label %one i32 16, label %one i32 17, label %one i32 18, label %one]
reference:
  %id = call i32 @rx_reference_id(ptr %data, i32 %value, ptr %ctx, ptr null)
  %cp = getelementptr %RC, ptr %ctx, i32 0, i32 5
  %count = load i32, ptr %cp
  %valid = icmp ult i32 %id, %count
  br i1 %valid, label %referencegood, label %rootcheck
rootcheck:
  %call = icmp eq i32 %op, 25
  %named = icmp ne ptr %data, null
  %rootpossible = and i1 %call, %named
  br i1 %rootpossible, label %rootname, label %badreference
rootname:
  %len = call i64 @b_len(ptr %data)
  %single = icmp eq i64 %len, 1
  %bytes = call ptr @b_data(ptr %data)
  %char = load i8, ptr %bytes
  %zero = icmp eq i8 %char, 48
  %root = and i1 %single, %zero
  br i1 %root, label %done, label %badreference
badreference:
  call void @j_fail(ptr @rx_refbad)
  br label %done
referencegood:
  %condition = icmp eq i32 %op, 26
  br i1 %condition, label %both, label %done
repeat:
  %minp = getelementptr %RX, ptr %node, i32 0, i32 2
  %maxp = getelementptr %RX, ptr %node, i32 0, i32 3
  %min = load i32, ptr %minp
  %max = load i32, ptr %maxp
  %bounded = icmp sge i32 %max, 0
  %reversed = icmp slt i32 %max, %min
  %invalid = and i1 %bounded, %reversed
  br i1 %invalid, label %badrepeat, label %one
badrepeat:
  call void @rx_fail(ptr @rx_repeatrange)
  br label %done
three:
  call void @rx_validate(ptr %data, ptr %ctx)
  br label %both
both:
  call void @rx_validate(ptr %a, ptr %ctx)
  call void @rx_validate(ptr %b, ptr %ctx)
  br label %done
one:
  call void @rx_validate(ptr %a, ptr %ctx)
  br label %done
done:
  ret void
}

define internal void @rx_compile_calls(ptr %tree, ptr %ctx) {
entry:
  %groups = call ptr @j_array()
  call void @rx_collect_groups(ptr %tree, ptr %groups)
  %graphs = call ptr @j_array()
  %return = call ptr @rx_node(i32 31, i32 0, ptr null, ptr null, ptr null)
  %root = call ptr @rx_compile(ptr %tree, ptr %return)
  call void @j_push(ptr %graphs, ptr %root)
  %n = call i64 @b_len(ptr %groups)
  br label %loop
loop:
  %i = phi i64 [0, %entry], [%next, %body]
  %more = icmp ult i64 %i, %n
  br i1 %more, label %body, label %done
body:
  %group = call ptr @j_at(ptr %groups, i64 %i)
  %graph = call ptr @rx_compile(ptr %group, ptr %return)
  call void @j_push(ptr %graphs, ptr %graph)
  %next = add i64 %i, 1
  br label %loop
done:
  %gp = getelementptr %RC, ptr %ctx, i32 0, i32 12
  store ptr %graphs, ptr %gp
  ret void
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
  %closeparenthesis = icmp eq i32 %tail, 41
  %tailreason = select i1 %closeparenthesis, ptr @rx_closeparen, ptr @rx_bad
  call void @rx_fail(ptr %tailreason)
  ret ptr %out
compiled:
  %err = load ptr, ptr @j_error
  %haserr = icmp ne ptr %err, null
  br i1 %haserr, label %done, label %ready
ready:
  %countp = getelementptr %RP, ptr %p, i32 0, i32 4
  %count = load i32, ptr %countp
  %ccp = getelementptr %RC, ptr %ctx, i32 0, i32 5
  store i32 %count, ptr %ccp
  %cnp = getelementptr %RC, ptr %ctx, i32 0, i32 6
  store ptr %names, ptr %cnp
  call void @rx_validate(ptr %tree, ptr %ctx)
  %validationerror = load ptr, ptr @j_error
  %compilevalid = icmp eq ptr %validationerror, null
  br i1 %compilevalid, label %programready, label %done
programready:
  %boundsafe = call i1 @rx_search_bound_safe(ptr %tree)
  %graph = call ptr @rx_compile(ptr %tree, ptr null)
  call void @rx_compile_calls(ptr %tree, ptr %ctx)
  %count64 = zext i32 %count to i64
  %slots = mul i64 %count64, 2
  %capbytes = mul i64 %slots, 8
  %gbit = and i32 %flags, 16
  %global = icmp ne i32 %gbit, 0
  %lbit = and i32 %flags, 64
  %longest = icmp ne i32 %lbit, 0
  %np = getelementptr %RC, ptr %ctx, i32 0, i32 3
  %n = load i64, ptr %np
  %originp = getelementptr %RC, ptr %ctx, i32 0, i32 7
  %maximumwidth = call i64 @rx_max_width(ptr %tree, i64 %n, i32 %flags)
  %keepp = getelementptr %RC, ptr %ctx, i32 0, i32 8
  %visitedp = getelementptr %RC, ptr %ctx, i32 0, i32 10
  %graphp = getelementptr %RC, ptr %ctx, i32 0, i32 11
  store ptr %graph, ptr %graphp
  %beststartp = alloca i64
  %bestendp = alloca i64
  %bestcapsp = alloca ptr
  br label %segment
segment:
  %origin = phi i64 [0, %programready], [%aftermatch, %matchednext]
  store i64 %origin, ptr %originp
  store i64 0, ptr %beststartp
  store i64 -1, ptr %bestendp
  store ptr null, ptr %bestcapsp
  br label %search
search:
  %pos = phi i64 [%origin, %segment], [%nextpos, %advance]
  %finished = icmp ugt i64 %pos, %n
  br i1 %finished, label %searchdone, label %newcaps
newcaps:
  %caps = call ptr @j_alloc(i64 %capbytes)
  br label %init
init:
  %ci = phi i64 [0, %newcaps], [%cn, %initone]
  %cend = icmp uge i64 %ci, %slots
  br i1 %cend, label %match, label %initone
initone:
  %cp = getelementptr i64, ptr %caps, i64 %ci
  store i64 -1, ptr %cp
  %cn = add i64 %ci, 1
  br label %init
match:
  store i64 %pos, ptr %keepp
  store ptr null, ptr %visitedp
  %end = call i64 @rx_run(ptr %graph, ptr %ctx, i64 %pos, ptr %caps, i64 0)
  %keep = load i64, ptr %keepp
  %pending = load ptr, ptr @j_error
  %failed = icmp ne ptr %pending, null
  br i1 %failed, label %done, label %matchcheck
matchcheck:
  %valid = icmp sge i64 %end, 0
  br i1 %valid, label %selectmatch, label %advance
selectmatch:
  br i1 %longest, label %comparebest, label %matched
comparebest:
  %beststart = load i64, ptr %beststartp
  %bestend = load i64, ptr %bestendp
  %bestlength = sub i64 %bestend, %beststart
  %matchlength = sub i64 %end, %keep
  %better = icmp sgt i64 %matchlength, %bestlength
  br i1 %better, label %savebest, label %advance
savebest:
  store i64 %keep, ptr %beststartp
  store i64 %end, ptr %bestendp
  store ptr %caps, ptr %bestcapsp
  br label %advance
advance:
  %nextpos = add i64 %pos, 1
  %boundend = load i64, ptr %bestendp
  %boundstart = load i64, ptr %beststartp
  %boundlength = sub i64 %boundend, %boundstart
  %remaininglength = sub i64 %n, %nextpos
  %hasbound = icmp sge i64 %boundend, 0
  %cannotimprove = icmp sle i64 %remaininglength, %boundlength
  %maximumfound = icmp uge i64 %boundlength, %maximumwidth
  %completebound = or i1 %cannotimprove, %maximumfound
  %bounded = and i1 %hasbound, %completebound
  %safeend = and i1 %bounded, %boundsafe
  br i1 %safeend, label %searchdone, label %search
searchdone:
  %winningstart = load i64, ptr %beststartp
  %winningend = load i64, ptr %bestendp
  %winningcaps = load ptr, ptr %bestcapsp
  %hasbest = icmp sge i64 %winningend, 0
  br i1 %hasbest, label %matched, label %done
matched:
  %matchstart = phi i64 [%keep, %selectmatch], [%winningstart, %searchdone]
  %matchend = phi i64 [%end, %selectmatch], [%winningend, %searchdone]
  %matchcaps = phi ptr [%caps, %selectmatch], [%winningcaps, %searchdone]
  %m = call ptr @j_alloc(i64 24)
  store i64 %matchstart, ptr %m
  %mep = getelementptr %RM, ptr %m, i32 0, i32 1
  store i64 %matchend, ptr %mep
  %mcp = getelementptr %RM, ptr %m, i32 0, i32 2
  store ptr %matchcaps, ptr %mcp
  call void @j_push(ptr %out, ptr %m)
  br i1 %global, label %matchednext, label %done
matchednext:
  %empty = icmp eq i64 %matchstart, %matchend
  %stepped = add i64 %matchend, 1
  %aftermatch = select i1 %empty, i64 %stepped, i64 %matchend
  br label %segment
done:
  ret ptr %out
}

define void @rx_fail(ptr %message) {
entry:
  %old = load ptr, ptr @j_error
  %clear = icmp eq ptr %old, null
  br i1 %clear, label %raise, label %done
raise:
  call void @j_fail(ptr %message)
  br label %done
done:
  ret void
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
