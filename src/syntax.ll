%SL = type { ptr, i64, i64, i64, i64, ptr, i32 }
%SS = type { i32, i64, i64 }
%SV = type { i32, i32, double, i64, i64, ptr, ptr }

@sy_yypact = external constant [312 x i32]
@sy_yydefact = external constant [312 x i32]
@sy_yypgoto = external constant [30 x i32]
@sy_yydefgoto = external constant [30 x i32]
@sy_yytable = external constant [1227 x i32]
@sy_yycheck = external constant [1227 x i32]
@sy_yyr1 = external constant [169 x i32]
@sy_yyr2 = external constant [169 x i32]
@sy_yytranslate = external constant [304 x i32]
@sy_names = external constant [70 x ptr]
@j_error = external global ptr
@j_compile_errors = external global ptr
@j_compile_error_start = external global i64
@j_compile_error_end = external global i64
@j_compile_error_raw = external global i1
@sy_prefix = private constant [26 x i8] c"syntax error, unexpected \00"
@sy_expecting = private constant [13 x i8] c", expecting \00"
@sy_or = private constant [5 x i8] c" or \00"
@sy_field = private constant [60 x i8] c"try .[\22field\22] instead of .field for unusually named fields\00"
@sy_if = private constant [37 x i8] c"Possibly unterminated 'if' statement\00"
@sy_try = private constant [38 x i8] c"Possibly unterminated 'try' statement\00"
@sy_key = private constant [50 x i8] c"May need parentheses around object key expression\00"
@sy_break = private constant [35 x i8] c"break requires a label to break to\00"

declare ptr @j_alloc(i64)
declare ptr @j_array()
declare ptr @j_cstr(ptr)
declare ptr @j_str(ptr, i64)
declare i1 @j_is(ptr, ptr)
declare i64 @j_strlen(ptr)
declare ptr @j_buffer_new()
declare void @j_buffer_append(ptr, ptr, i64)
declare ptr @j_buffer_value(ptr)
declare void @j_buffer_byte(ptr, i8)
declare ptr @j_parse(ptr, i64, ptr)
declare void @ev_recorderror(ptr, i64, i64, i1)

define internal i32 @sy_byte(ptr %data, i64 %length, i64 %index) {
entry:
  %more = icmp ult i64 %index, %length
  br i1 %more, label %read, label %end
read:
  %p = getelementptr i8, ptr %data, i64 %index
  %b = load i8, ptr %p
  %c = zext i8 %b to i32
  ret i32 %c
end:
  ret i32 -1
}

define internal i1 @sy_ident(i32 %c, i1 %first) {
  %fold = or i32 %c, 32
  %a = sub i32 %fold, 97
  %letter = icmp ult i32 %a, 26
  %under = icmp eq i32 %c, 95
  %name = or i1 %letter, %under
  %d = sub i32 %c, 48
  %digit = icmp ult i32 %d, 10
  %later = xor i1 %first, true
  %number = and i1 %later, %digit
  %result = or i1 %name, %number
  ret i1 %result
}

define internal i64 @sy_digits(ptr %data, i64 %length, i64 %start) {
entry:
  br label %loop
loop:
  %i = phi i64 [%start, %entry], [%next, %loop]
  %c = call i32 @sy_byte(ptr %data, i64 %length, i64 %i)
  %d = sub i32 %c, 48
  %digit = icmp ult i32 %d, 10
  %next = add i64 %i, 1
  br i1 %digit, label %loop, label %done
done:
  ret i64 %i
}

define internal void @sy_push(ptr %lexer, i32 %closer, i32 %mode) {
  %sp = getelementptr %SL, ptr %lexer, i32 0, i32 5
  %old = load ptr, ptr %sp
  %item = call ptr @j_alloc(i64 16)
  store ptr %old, ptr %item
  %cp = getelementptr i8, ptr %item, i64 8
  %mp = getelementptr i8, ptr %item, i64 12
  store i32 %closer, ptr %cp
  store i32 %mode, ptr %mp
  store ptr %item, ptr %sp
  ret void
}

define internal i32 @sy_lex(ptr %lexer) {
entry:
  %data = load ptr, ptr %lexer
  %np = getelementptr %SL, ptr %lexer, i32 0, i32 1
  %pp = getelementptr %SL, ptr %lexer, i32 0, i32 2
  %sp = getelementptr %SL, ptr %lexer, i32 0, i32 3
  %ep = getelementptr %SL, ptr %lexer, i32 0, i32 4
  %modep = getelementptr %SL, ptr %lexer, i32 0, i32 6
  %length = load i64, ptr %np
  br label %again
again:
  %i = load i64, ptr %pp
  %c = call i32 @sy_byte(ptr %data, i64 %length, i64 %i)
  %eof = icmp slt i32 %c, 0
  br i1 %eof, label %end, label %begin
end:
  ret i32 0
begin:
  store i64 %i, ptr %sp
  %next = add i64 %i, 1
  store i64 %next, ptr %pp
  store i64 %next, ptr %ep
  %mode = load i32, ptr %modep
  %string = icmp eq i32 %mode, 1
  br i1 %string, label %stringtoken, label %normal
normal:
  switch i32 %c, label %classify [i32 32, label %whitespace i32 9, label %whitespace i32 10, label %whitespace i32 13, label %whitespace i32 35, label %comment i32 34, label %quote i32 40, label %open i32 91, label %open i32 123, label %open i32 41, label %close i32 93, label %close i32 125, label %close]
whitespace:
  br label %whiteloop
whiteloop:
  %wi = phi i64 [%next, %whitespace], [%wn, %whitebyte]
  %wc = call i32 @sy_byte(ptr %data, i64 %length, i64 %wi)
  switch i32 %wc, label %whitedone [i32 32, label %whitebyte i32 9, label %whitebyte i32 10, label %whitebyte i32 13, label %whitebyte]
whitebyte:
  %wn = add i64 %wi, 1
  br label %whiteloop
whitedone:
  store i64 %wi, ptr %pp
  store i64 %wi, ptr %ep
  br label %again
comment:
  br label %commentloop
commentloop:
  %ci = phi i64 [%next, %comment], [%cn, %commentbyte]
  %cc = call i32 @sy_byte(ptr %data, i64 %length, i64 %ci)
  %ce = icmp slt i32 %cc, 0
  %cl = icmp eq i32 %cc, 10
  %cd = or i1 %ce, %cl
  br i1 %cd, label %commentdone, label %commentbyte
commentbyte:
  %cn = add i64 %ci, 1
  br label %commentloop
commentdone:
  store i64 %ci, ptr %pp
  store i64 %ci, ptr %ep
  br label %again
quote:
  call void @sy_push(ptr %lexer, i32 34, i32 %mode)
  store i32 1, ptr %modep
  ret i32 42
open:
  %paren = icmp eq i32 %c, 40
  %gap = select i1 %paren, i32 1, i32 2
  %closer = add i32 %c, %gap
  call void @sy_push(ptr %lexer, i32 %closer, i32 0)
  br label %punctuation
close:
  %stackp = getelementptr %SL, ptr %lexer, i32 0, i32 5
  %stack = load ptr, ptr %stackp
  %present = icmp ne ptr %stack, null
  br i1 %present, label %matchclose, label %invalid
matchclose:
  %closerp = getelementptr i8, ptr %stack, i64 8
  %expected = load i32, ptr %closerp
  %matches = icmp eq i32 %c, %expected
  br i1 %matches, label %pop, label %invalid
pop:
  %parent = load ptr, ptr %stack
  %returnmodep = getelementptr i8, ptr %stack, i64 12
  %returnmode = load i32, ptr %returnmodep
  store ptr %parent, ptr %stackp
  store i32 %returnmode, ptr %modep
  %wasinterpolation = icmp eq i32 %returnmode, 1
  br i1 %wasinterpolation, label %interpolationend, label %punctuation
interpolationend:
  ret i32 45
classify:
  %ident = call i1 @sy_ident(i32 %c, i1 true)
  %prefix = icmp eq i32 %c, 36
  %field = icmp eq i32 %c, 46
  %format = icmp eq i32 %c, 64
  %named1 = or i1 %prefix, %field
  %named2 = or i1 %named1, %format
  %nc = call i32 @sy_byte(ptr %data, i64 %length, i64 %next)
  %namefirst = xor i1 %format, true
  %nextident = call i1 @sy_ident(i32 %nc, i1 %namefirst)
  %prefixed = and i1 %named2, %nextident
  %name = or i1 %ident, %prefixed
  br i1 %name, label %namestart, label %numbercheck
namestart:
  %namebegin = select i1 %prefixed, i64 %next, i64 %i
  br label %nameloop
nameloop:
  %ni = phi i64 [%namebegin, %namestart], [%nn, %namebyte], [%namespaceend, %namespacevalid]
  %ch = call i32 @sy_byte(ptr %data, i64 %length, i64 %ni)
  %isname = call i1 @sy_ident(i32 %ch, i1 false)
  br i1 %isname, label %namebyte, label %namespacecheck
namebyte:
  %nn = add i64 %ni, 1
  br label %nameloop
namespacecheck:
  %colon = icmp eq i32 %ch, 58
  %notfield = xor i1 %field, true
  %possible = and i1 %colon, %notfield
  br i1 %possible, label %namespace, label %namedone
namespace:
  %nsi = add i64 %ni, 1
  %nsj = add i64 %ni, 2
  %nscolon = call i32 @sy_byte(ptr %data, i64 %length, i64 %nsi)
  %nsfirst = call i32 @sy_byte(ptr %data, i64 %length, i64 %nsj)
  %iscolon = icmp eq i32 %nscolon, 58
  %isfirst = call i1 @sy_ident(i32 %nsfirst, i1 true)
  %nsvalid = and i1 %iscolon, %isfirst
  br i1 %nsvalid, label %namespacevalid, label %namedone
namespacevalid:
  %namespaceend = add i64 %ni, 3
  br label %nameloop
namedone:
  store i64 %ni, ptr %pp
  store i64 %ni, ptr %ep
  %namelen = sub i64 %ni, %i
  %namep = getelementptr i8, ptr %data, i64 %i
  %namevalue = call ptr @j_str(ptr %namep, i64 %namelen)
  br i1 %prefixed, label %prefixedname, label %keywordstart
prefixedname:
  %locp = getelementptr ptr, ptr @sy_names, i64 32
  %locname = load ptr, ptr %locp
  %location = call i1 @j_is(ptr %namevalue, ptr %locname)
  %fieldtype = select i1 %field, i32 5, i32 8
  %prefixtype = select i1 %prefix, i32 6, i32 %fieldtype
  %nametype = select i1 %location, i32 32, i32 %prefixtype
  ret i32 %nametype
keywordstart:
  br label %keywordloop
keywordloop:
  %ki = phi i64 [14, %keywordstart], [%kn, %keywordnext]
  %kp = getelementptr ptr, ptr @sy_names, i64 %ki
  %keyword = load ptr, ptr %kp
  %same = call i1 @j_is(ptr %namevalue, ptr %keyword)
  br i1 %same, label %keywordfound, label %keywordnext
keywordnext:
  %kn = add i64 %ki, 1
  %morekeywords = icmp ule i64 %kn, 31
  br i1 %morekeywords, label %keywordloop, label %identifier
keywordfound:
  %kt = trunc i64 %ki to i32
  ret i32 %kt
identifier:
  ret i32 4
numbercheck:
  %digit0 = sub i32 %c, 48
  %digit = icmp ult i32 %digit0, 10
  %digit1 = sub i32 %nc, 48
  %nextdigit = icmp ult i32 %digit1, 10
  %dotnumber = and i1 %field, %nextdigit
  %number = or i1 %digit, %dotnumber
  br i1 %number, label %integer, label %operatorstart
integer:
  %intstart = select i1 %dotnumber, i64 %next, i64 %i
  %intstop = call i64 @sy_digits(ptr %data, i64 %length, i64 %intstart)
  %ic = call i32 @sy_byte(ptr %data, i64 %length, i64 %intstop)
  %dot = icmp eq i32 %ic, 46
  %notdotnumber = xor i1 %dotnumber, true
  %fractional = and i1 %dot, %notdotnumber
  br i1 %fractional, label %fraction, label %exponentcheck
fraction:
  %fractionstart = add i64 %intstop, 1
  %fractionstop = call i64 @sy_digits(ptr %data, i64 %length, i64 %fractionstart)
  br label %exponentcheck
exponentcheck:
  %mantissaend = phi i64 [%intstop, %integer], [%fractionstop, %fraction]
  %ec = call i32 @sy_byte(ptr %data, i64 %length, i64 %mantissaend)
  %folded = or i32 %ec, 32
  %hasexp = icmp eq i32 %folded, 101
  br i1 %hasexp, label %exponent, label %numberdone
exponent:
  %expi = add i64 %mantissaend, 1
  %signc = call i32 @sy_byte(ptr %data, i64 %length, i64 %expi)
  %plus = icmp eq i32 %signc, 43
  %minus = icmp eq i32 %signc, 45
  %signed = or i1 %plus, %minus
  %skip = zext i1 %signed to i64
  %expstart = add i64 %expi, %skip
  %expstop = call i64 @sy_digits(ptr %data, i64 %length, i64 %expstart)
  %expvalid = icmp ugt i64 %expstop, %expstart
  %numberend = select i1 %expvalid, i64 %expstop, i64 %mantissaend
  br label %numberdone
numberdone:
  %stop = phi i64 [%mantissaend, %exponentcheck], [%numberend, %exponent]
  store i64 %stop, ptr %pp
  store i64 %stop, ptr %ep
  ret i32 7
operatorstart:
  %opfirst = shl i32 %c, 8
  %op = or i32 %opfirst, %nc
  switch i32 %op, label %punctuation [i32 11822, label %rec i32 15677, label %eq i32 8509, label %ne i32 15421, label %le i32 15933, label %ge i32 31805, label %setpipe i32 11069, label %setplus i32 11581, label %setminus i32 10813, label %setmult i32 12093, label %setdiv i32 9533, label %setmod i32 12079, label %definedor i32 16175, label %alternation]
rec:
  br label %two
eq:
  br label %two
ne:
  br label %two
le:
  br label %two
ge:
  br label %two
setpipe:
  br label %two
setplus:
  br label %two
setminus:
  br label %two
setmult:
  br label %two
setdiv:
  br label %two
setmod:
  br label %two
definedor:
  %thirdi = add i64 %i, 2
  %thirdc = call i32 @sy_byte(ptr %data, i64 %length, i64 %thirdi)
  %assignment = icmp eq i32 %thirdc, 61
  br i1 %assignment, label %setdefinedor, label %two
setdefinedor:
  br label %three
alternation:
  %alti = add i64 %i, 2
  %altc = call i32 @sy_byte(ptr %data, i64 %length, i64 %alti)
  %altslash = icmp eq i32 %altc, 47
  br i1 %altslash, label %three, label %punctuation
three:
  %threetoken = phi i32 [38, %setdefinedor], [41, %alternation]
  %threeend = add i64 %i, 3
  store i64 %threeend, ptr %pp
  store i64 %threeend, ptr %ep
  ret i32 %threetoken
two:
  %twotoken = phi i32 [9, %rec], [11, %eq], [12, %ne], [39, %le], [40, %ge], [33, %setpipe], [34, %setplus], [35, %setminus], [36, %setmult], [37, %setdiv], [10, %setmod], [13, %definedor]
  %twoend = add i64 %i, 2
  store i64 %twoend, ptr %pp
  store i64 %twoend, ptr %ep
  ret i32 %twotoken
punctuation:
  %ascii = icmp ult i32 %c, 128
  br i1 %ascii, label %translate, label %invalid
translate:
  %tp = getelementptr i32, ptr @sy_yytranslate, i32 %c
  %token = load i32, ptr %tp
  %undefined = icmp eq i32 %token, 2
  %translated = select i1 %undefined, i32 3, i32 %token
  ret i32 %translated
invalid:
  ret i32 3
stringtoken:
  switch i32 %c, label %textstart [i32 34, label %stringclose i32 92, label %escape]
stringclose:
  %qstackp = getelementptr %SL, ptr %lexer, i32 0, i32 5
  %qstack = load ptr, ptr %qstackp
  %qparent = load ptr, ptr %qstack
  %qmodep = getelementptr i8, ptr %qstack, i64 12
  %qmode = load i32, ptr %qmodep
  store ptr %qparent, ptr %qstackp
  store i32 %qmode, ptr %modep
  ret i32 46
escape:
  %esc = call i32 @sy_byte(ptr %data, i64 %length, i64 %next)
  %interp = icmp eq i32 %esc, 40
  br i1 %interp, label %interpolation, label %escapecheck
interpolation:
  call void @sy_push(ptr %lexer, i32 41, i32 1)
  store i32 0, ptr %modep
  %interpend = add i64 %i, 2
  store i64 %interpend, ptr %pp
  store i64 %interpend, ptr %ep
  ret i32 44
escapecheck:
  %escend = icmp slt i32 %esc, 0
  br i1 %escend, label %invalid, label %escapeloop
escapeloop:
  %ei = phi i64 [%i, %escapecheck], [%unicodeend, %escapenext]
  %escpos = add i64 %ei, 1
  %escapechar = call i32 @sy_byte(ptr %data, i64 %length, i64 %escpos)
  %afterescape = add i64 %ei, 2
  %unicode = icmp eq i32 %escapechar, 117
  br i1 %unicode, label %unicodeloop, label %escapedone
unicodeloop:
  %ui = phi i64 [%afterescape, %escapeloop], [%un, %unicodebyte]
  %ud = sub i64 %ui, %afterescape
  %uroom = icmp ult i64 %ud, 4
  %uc = call i32 @sy_byte(ptr %data, i64 %length, i64 %ui)
  %uf = or i32 %uc, 32
  %ua = sub i32 %uf, 97
  %ualpha = icmp ult i32 %ua, 26
  %unum = sub i32 %uc, 48
  %udigit = icmp ult i32 %unum, 10
  %ualnum = or i1 %ualpha, %udigit
  %umore = and i1 %uroom, %ualnum
  br i1 %umore, label %unicodebyte, label %escapedone
unicodebyte:
  %un = add i64 %ui, 1
  br label %unicodeloop
escapedone:
  %unicodeend = phi i64 [%afterescape, %escapeloop], [%ui, %unicodeloop]
  %nextescape = call i32 @sy_byte(ptr %data, i64 %length, i64 %unicodeend)
  %nextescpos = add i64 %unicodeend, 1
  %nextescchar = call i32 @sy_byte(ptr %data, i64 %length, i64 %nextescpos)
  %nextslash = icmp eq i32 %nextescape, 92
  %nextnotinterp = icmp ne i32 %nextescchar, 40
  %nextnotend = icmp sge i32 %nextescchar, 0
  %nextvalid = and i1 %nextnotinterp, %nextnotend
  %escmore = and i1 %nextslash, %nextvalid
  br i1 %escmore, label %escapenext, label %escapereturn
escapenext:
  br label %escapeloop
escapereturn:
  store i64 %unicodeend, ptr %pp
  store i64 %unicodeend, ptr %ep
  call void @sy_escape(ptr %data, i64 %i, i64 %unicodeend)
  ret i32 43
textstart:
  br label %textloop
textloop:
  %ti = phi i64 [%next, %textstart], [%tn, %textbyte]
  %tc = call i32 @sy_byte(ptr %data, i64 %length, i64 %ti)
  %te = icmp slt i32 %tc, 0
  %tq = icmp eq i32 %tc, 34
  %ts = icmp eq i32 %tc, 92
  %td = or i1 %tq, %ts
  %tdone = or i1 %te, %td
  br i1 %tdone, label %textdone, label %textbyte
textbyte:
  %tn = add i64 %ti, 1
  br label %textloop
textdone:
  store i64 %ti, ptr %pp
  store i64 %ti, ptr %ep
  ret i32 43
}

define internal void @sy_escape(ptr %source, i64 %start, i64 %end) {
entry:
  %buffer = call ptr @j_buffer_new()
  call void @j_buffer_byte(ptr %buffer, i8 34)
  %bytes = getelementptr i8, ptr %source, i64 %start
  %length = sub i64 %end, %start
  call void @j_buffer_append(ptr %buffer, ptr %bytes, i64 %length)
  call void @j_buffer_byte(ptr %buffer, i8 34)
  %text = call ptr @j_buffer_value(ptr %buffer)
  %datap = getelementptr %SV, ptr %text, i32 0, i32 5
  %data = load ptr, ptr %datap
  %total = add i64 %length, 2
  %offset = alloca i64
  store i64 0, ptr %offset
  %old = load ptr, ptr @j_error
  store ptr null, ptr @j_error
  %parsed = call ptr @j_parse(ptr %data, i64 %total, ptr %offset)
  %failed = icmp eq ptr %parsed, null
  br i1 %failed, label %error, label %restore
error:
  %message = load ptr, ptr @j_error
  call void @sy_record(ptr %message, i64 %start, i64 %end)
  ret void
restore:
  store ptr %old, ptr @j_error
  ret void
}

define internal i32 @sy_action(i32 %state, i32 %token) {
entry:
  %pp = getelementptr i32, ptr @sy_yypact, i32 %state
  %pact = load i32, ptr %pp
  %default = icmp eq i32 %pact, -146
  br i1 %default, label %fallback, label %lookup
lookup:
  %index = add i32 %pact, %token
  %valid = icmp ult i32 %index, 1227
  br i1 %valid, label %check, label %fallback
check:
  %cp = getelementptr i32, ptr @sy_yycheck, i32 %index
  %entrytoken = load i32, ptr %cp
  %matches = icmp eq i32 %entrytoken, %token
  br i1 %matches, label %found, label %fallback
found:
  %tp = getelementptr i32, ptr @sy_yytable, i32 %index
  %value = load i32, ptr %tp
  %error = icmp eq i32 %value, -154
  %action = select i1 %error, i32 0, i32 %value
  ret i32 %action
fallback:
  %dp = getelementptr i32, ptr @sy_yydefact, i32 %state
  %def = load i32, ptr %dp
  %reduction = sub i32 0, %def
  ret i32 %reduction
}

define internal void @sy_text(ptr %buffer, ptr %text) {
  %length = call i64 @j_strlen(ptr %text)
  call void @j_buffer_append(ptr %buffer, ptr %text, i64 %length)
  ret void
}

define internal void @sy_record(ptr %message, i64 %start, i64 %end) {
  store ptr %message, ptr @j_error
  store i64 %start, ptr @j_compile_error_start
  store i64 %end, ptr @j_compile_error_end
  call void @ev_recorderror(ptr %message, i64 %start, i64 %end, i1 false)
  ret void
}

define internal void @sy_error(ptr %lexer, i32 %state, i32 %token) {
entry:
  %buffer = call ptr @j_buffer_new()
  call void @sy_text(ptr %buffer, ptr @sy_prefix)
  %namep = getelementptr ptr, ptr @sy_names, i32 %token
  %name = load ptr, ptr %namep
  call void @sy_text(ptr %buffer, ptr %name)
  %expected = alloca [4 x i32]
  %pp = getelementptr i32, ptr @sy_yypact, i32 %state
  %pact = load i32, ptr %pp
  %default = icmp eq i32 %pact, -146
  br i1 %default, label %finish, label %scan
scan:
  %i = phi i32 [0, %entry], [%next, %advance]
  %n = phi i32 [0, %entry], [%count, %advance]
  %more = icmp ult i32 %i, 70
  br i1 %more, label %candidate, label %list
candidate:
  %idx = add i32 %pact, %i
  %valid = icmp ult i32 %idx, 1227
  %noterror = icmp ne i32 %i, 1
  %possible = and i1 %valid, %noterror
  br i1 %possible, label %check, label %advance
check:
  %cp = getelementptr i32, ptr @sy_yycheck, i32 %idx
  %tp = getelementptr i32, ptr @sy_yytable, i32 %idx
  %ct = load i32, ptr %cp
  %action = load i32, ptr %tp
  %match = icmp eq i32 %ct, %i
  %accepted = icmp ne i32 %action, -154
  %isexpected = and i1 %match, %accepted
  br i1 %isexpected, label %add, label %advance
add:
  %room = icmp ult i32 %n, 4
  br i1 %room, label %store, label %finish
store:
  %slot = getelementptr i32, ptr %expected, i32 %n
  store i32 %i, ptr %slot
  %inc = add i32 %n, 1
  br label %advance
advance:
  %count = phi i32 [%n, %candidate], [%n, %check], [%inc, %store]
  %next = add i32 %i, 1
  br label %scan
list:
  br label %emitloop
emitloop:
  %j = phi i32 [0, %list], [%jn, %emit]
  %remaining = icmp ult i32 %j, %n
  br i1 %remaining, label %emit, label %finish
emit:
  %first = icmp eq i32 %j, 0
  %separator = select i1 %first, ptr @sy_expecting, ptr @sy_or
  call void @sy_text(ptr %buffer, ptr %separator)
  %jp = getelementptr i32, ptr %expected, i32 %j
  %symbol = load i32, ptr %jp
  %np = getelementptr ptr, ptr @sy_names, i32 %symbol
  %text = load ptr, ptr %np
  call void @sy_text(ptr %buffer, ptr %text)
  %jn = add i32 %j, 1
  br label %emitloop
finish:
  %message = call ptr @j_buffer_value(ptr %buffer)
  %sp = getelementptr %SL, ptr %lexer, i32 0, i32 3
  %ep = getelementptr %SL, ptr %lexer, i32 0, i32 4
  %start = load i64, ptr %sp
  %end = load i64, ptr %ep
  call void @sy_record(ptr %message, i64 %start, i64 %end)
  ret void
}

define internal void @sy_parse(ptr %source, i64 %length) {
entry:
  %lexer = call ptr @j_alloc(i64 56)
  store ptr %source, ptr %lexer
  %lenp = getelementptr %SL, ptr %lexer, i32 0, i32 1
  %lexstartp = getelementptr %SL, ptr %lexer, i32 0, i32 3
  %lexendp = getelementptr %SL, ptr %lexer, i32 0, i32 4
  store i64 %length, ptr %lenp
  %twice = mul i64 %length, 2
  %capacity = add i64 %twice, 64
  %bytes = mul i64 %capacity, 24
  %stack = call ptr @j_alloc(i64 %bytes)
  %topp = alloca i64
  %lookp = alloca i32
  %recoverp = alloca i32
  %errorstartp = alloca i64
  store i64 0, ptr %topp
  store i32 -2, ptr %lookp
  store i32 0, ptr %recoverp
  br label %loop
loop:
  %top = load i64, ptr %topp
  %frame = getelementptr %SS, ptr %stack, i64 %top
  %state = load i32, ptr %frame
  %accepted = icmp eq i32 %state, 31
  br i1 %accepted, label %done, label %pact
pact:
  %pactp = getelementptr i32, ptr @sy_yypact, i32 %state
  %pactvalue = load i32, ptr %pactp
  %default = icmp eq i32 %pactvalue, -146
  %look = load i32, ptr %lookp
  %empty = icmp eq i32 %look, -2
  %notdefault = xor i1 %default, true
  %needtoken = and i1 %empty, %notdefault
  br i1 %needtoken, label %lex, label %action
lex:
  %newtoken = call i32 @sy_lex(ptr %lexer)
  store i32 %newtoken, ptr %lookp
  br label %action
action:
  %token = phi i32 [%look, %pact], [%newtoken, %lex]
  %act = call i32 @sy_action(i32 %state, i32 %token)
  %shift = icmp sgt i32 %act, 0
  br i1 %shift, label %shifttoken, label %reducecheck
shifttoken:
  %shiftstart = load i64, ptr %lexstartp
  %shiftend = load i64, ptr %lexendp
  %shiftindex = add i64 %top, 1
  %shiftframe = getelementptr %SS, ptr %stack, i64 %shiftindex
  %shiftsp = getelementptr %SS, ptr %shiftframe, i32 0, i32 1
  %shiftep = getelementptr %SS, ptr %shiftframe, i32 0, i32 2
  store i32 %act, ptr %shiftframe
  store i64 %shiftstart, ptr %shiftsp
  store i64 %shiftend, ptr %shiftep
  store i64 %shiftindex, ptr %topp
  store i32 -2, ptr %lookp
  %recover = load i32, ptr %recoverp
  %recovering = icmp sgt i32 %recover, 0
  %decrement = zext i1 %recovering to i32
  %newrecover = sub i32 %recover, %decrement
  store i32 %newrecover, ptr %recoverp
  br label %loop
reducecheck:
  %reduce = icmp slt i32 %act, 0
  br i1 %reduce, label %reduction, label %error
reduction:
  %rule = sub i32 0, %act
  %countp = getelementptr i32, ptr @sy_yyr2, i32 %rule
  %count32 = load i32, ptr %countp
  %count = zext i32 %count32 to i64
  %base = sub i64 %top, %count
  %first = add i64 %base, 1
  %emptyrule = icmp eq i64 %count, 0
  %lastendp = getelementptr %SS, ptr %frame, i32 0, i32 2
  %ruleend = load i64, ptr %lastendp
  br i1 %emptyrule, label %emptylocation, label %fullocation
emptylocation:
  br label %rulelocation
fullocation:
  %firstframe = getelementptr %SS, ptr %stack, i64 %first
  %firststartp = getelementptr %SS, ptr %firstframe, i32 0, i32 1
  %firstendp = getelementptr %SS, ptr %firstframe, i32 0, i32 2
  %firststart = load i64, ptr %firststartp
  %firstend = load i64, ptr %firstendp
  br label %rulelocation
rulelocation:
  %rulestart = phi i64 [%ruleend, %emptylocation], [%firststart, %fullocation]
  %hintend = phi i64 [%ruleend, %emptylocation], [%firstend, %fullocation]
  switch i32 %rule, label %goto [i32 63, label %breakhint i32 72, label %fieldhint i32 73, label %fieldhint i32 101, label %ifhint i32 103, label %tryhint i32 134, label %keyhint i32 166, label %keyhint]
breakhint:
  br label %hint
fieldhint:
  br label %hint
ifhint:
  br label %hint
tryhint:
  br label %hint
keyhint:
  br label %hint
hint:
  %hinttext = phi ptr [@sy_break, %breakhint], [@sy_field, %fieldhint], [@sy_if, %ifhint], [@sy_try, %tryhint], [@sy_key, %keyhint]
  %firstonly = icmp eq i32 %rule, 166
  %diagnosticend = select i1 %firstonly, i64 %hintend, i64 %ruleend
  %hintvalue = call ptr @j_cstr(ptr %hinttext)
  call void @sy_record(ptr %hintvalue, i64 %rulestart, i64 %diagnosticend)
  br label %goto
goto:
  %lhspp = getelementptr i32, ptr @sy_yyr1, i32 %rule
  %lhs0 = load i32, ptr %lhspp
  %lhs = sub i32 %lhs0, 70
  %baseframe = getelementptr %SS, ptr %stack, i64 %base
  %basestate = load i32, ptr %baseframe
  %gotop = getelementptr i32, ptr @sy_yypgoto, i32 %lhs
  %gotobase = load i32, ptr %gotop
  %gotoindex = add i32 %gotobase, %basestate
  %gotovalid = icmp ult i32 %gotoindex, 1227
  br i1 %gotovalid, label %gotocheck, label %gotodefault
gotocheck:
  %gotocp = getelementptr i32, ptr @sy_yycheck, i32 %gotoindex
  %gotostate = load i32, ptr %gotocp
  %gotomatch = icmp eq i32 %gotostate, %basestate
  br i1 %gotomatch, label %gototable, label %gotodefault
gototable:
  %gototp = getelementptr i32, ptr @sy_yytable, i32 %gotoindex
  %tablestate = load i32, ptr %gototp
  br label %reduced
gotodefault:
  %gotodp = getelementptr i32, ptr @sy_yydefgoto, i32 %lhs
  %defaultstate = load i32, ptr %gotodp
  br label %reduced
reduced:
  %newstate = phi i32 [%tablestate, %gototable], [%defaultstate, %gotodefault]
  %newframe = getelementptr %SS, ptr %stack, i64 %first
  %newsp = getelementptr %SS, ptr %newframe, i32 0, i32 1
  %newep = getelementptr %SS, ptr %newframe, i32 0, i32 2
  store i32 %newstate, ptr %newframe
  store i64 %rulestart, ptr %newsp
  store i64 %ruleend, ptr %newep
  store i64 %first, ptr %topp
  br label %loop
error:
  %errorstate = load i32, ptr %recoverp
  %fresherror = icmp eq i32 %errorstate, 0
  br i1 %fresherror, label %report, label %recovery
report:
  call void @sy_error(ptr %lexer, i32 %state, i32 %token)
  br label %recovery
recovery:
  %errorstart = load i64, ptr %lexstartp
  store i64 %errorstart, ptr %errorstartp
  %discard = icmp eq i32 %errorstate, 3
  br i1 %discard, label %discardcheck, label %recoverstart
discardcheck:
  %endeof = icmp eq i32 %token, 0
  br i1 %endeof, label %done, label %discardtoken
discardtoken:
  store i32 -2, ptr %lookp
  br label %recoverstart
recoverstart:
  store i32 3, ptr %recoverp
  br label %recoverloop
recoverloop:
  %ri = load i64, ptr %topp
  %rf = getelementptr %SS, ptr %stack, i64 %ri
  %rs = load i32, ptr %rf
  %rp = getelementptr i32, ptr @sy_yypact, i32 %rs
  %rb = load i32, ptr %rp
  %ridx = add i32 %rb, 1
  %rvalid = icmp ult i32 %ridx, 1227
  br i1 %rvalid, label %recovercheck, label %recoverpop
recovercheck:
  %rcp = getelementptr i32, ptr @sy_yycheck, i32 %ridx
  %rtp = getelementptr i32, ptr @sy_yytable, i32 %ridx
  %rt = load i32, ptr %rcp
  %ra = load i32, ptr %rtp
  %rmatch = icmp eq i32 %rt, 1
  %rshift = icmp sgt i32 %ra, 0
  %raccept = and i1 %rmatch, %rshift
  br i1 %raccept, label %recoverpush, label %recoverpop
recoverpop:
  %root = icmp eq i64 %ri, 0
  br i1 %root, label %done, label %popstate
popstate:
  %rstartp = getelementptr %SS, ptr %rf, i32 0, i32 1
  %rstart = load i64, ptr %rstartp
  store i64 %rstart, ptr %errorstartp
  %rprev = sub i64 %ri, 1
  store i64 %rprev, ptr %topp
  br label %recoverloop
recoverpush:
  %rnext = add i64 %ri, 1
  %rnew = getelementptr %SS, ptr %stack, i64 %rnext
  %rnsp = getelementptr %SS, ptr %rnew, i32 0, i32 1
  %rnep = getelementptr %SS, ptr %rnew, i32 0, i32 2
  %rsstart = load i64, ptr %errorstartp
  %rsend = load i64, ptr %lexendp
  store i32 %ra, ptr %rnew
  store i64 %rsstart, ptr %rnsp
  store i64 %rsend, ptr %rnep
  store i64 %rnext, ptr %topp
  br label %loop
done:
  ret void
}

define void @j_syntax_diagnostics(ptr %source, i64 %length) {
entry:
  %oldmessage = load ptr, ptr @j_error
  %olderrors = load ptr, ptr @j_compile_errors
  %oldstart = load i64, ptr @j_compile_error_start
  %oldend = load i64, ptr @j_compile_error_end
  %oldraw = load i1, ptr @j_compile_error_raw
  %errors = call ptr @j_array()
  store ptr %errors, ptr @j_compile_errors
  store ptr null, ptr @j_error
  store i1 false, ptr @j_compile_error_raw
  call void @sy_parse(ptr %source, i64 %length)
  %countp = getelementptr %SV, ptr %errors, i32 0, i32 3
  %count = load i64, ptr %countp
  %any = icmp ne i64 %count, 0
  br i1 %any, label %done, label %restore
restore:
  store ptr %oldmessage, ptr @j_error
  store ptr %olderrors, ptr @j_compile_errors
  store i64 %oldstart, ptr @j_compile_error_start
  store i64 %oldend, ptr @j_compile_error_end
  store i1 %oldraw, ptr @j_compile_error_raw
  br label %done
done:
  ret void
}
