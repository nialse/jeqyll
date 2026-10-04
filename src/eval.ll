%V = type { i32, i32, double, i64, i64, ptr, ptr }
%N = type { i32, i32, ptr, ptr, ptr, ptr, ptr, i64, i64 }
%P = type { ptr, i64, i64, i32, ptr, i32, i64, i64 }
%E = type { ptr, ptr, ptr, i32, ptr, ptr }

@j_error = external global ptr
@j_compile_env = global ptr null
@j_compile_error_start = global i64 0
@j_compile_error_end = global i64 1
@j_compile_error_raw = global i1 false
@j_compile_errors = global ptr null
@ev_compile_depth = internal global i64 0
@ev_syntax = private constant [14 x i8] c"syntax error\00\00"
@ev_undefined = private constant [25 x i8] c"Unknown function or name\00"
@ev_iteration = private constant [26 x i8] c"Cannot iterate over value\00"
@ev_variable = private constant [19 x i8] c"Undefined variable\00"
@ev_patherror = private constant [24 x i8] c"Invalid path expression\00"
@ev_keyerror = private constant [34 x i8] c"Cannot use non-string object key\00\00"
@ev_true = private constant [5 x i8] c"true\00"
@ev_false = private constant [6 x i8] c"false\00"
@ev_null = private constant [5 x i8] c"null\00"
@ev_as = private constant [3 x i8] c"as\00"
@ev_if = private constant [3 x i8] c"if\00"
@ev_then = private constant [5 x i8] c"then\00"
@ev_else = private constant [5 x i8] c"else\00"
@ev_elif = private constant [5 x i8] c"elif\00"
@ev_end = private constant [4 x i8] c"end\00"
@ev_def = private constant [4 x i8] c"def\00"
@ev_reduce = private constant [7 x i8] c"reduce\00"
@ev_foreach = private constant [8 x i8] c"foreach\00"
@ev_try = private constant [4 x i8] c"try\00"
@ev_catch = private constant [6 x i8] c"catch\00"
@ev_and = private constant [4 x i8] c"and\00"
@ev_or = private constant [3 x i8] c"or\00"
@ev_label = private constant [6 x i8] c"label\00"
@ev_break = private constant [6 x i8] c"break\00"
@ev_import = private constant [7 x i8] c"import\00"
@ev_include = private constant [8 x i8] c"include\00"
@ev_tostring = private constant [9 x i8] c"tostring\00"
@ev_path = private constant [5 x i8] c"path\00"
@ev_pick = private constant [5 x i8] c"pick\00"
@ev_del = private constant [4 x i8] c"del\00"
@ev_select = private constant [7 x i8] c"select\00"
@ev_first = private constant [6 x i8] c"first\00"
@ev_last = private constant [5 x i8] c"last\00"
@ev_getpath = private constant [8 x i8] c"getpath\00"
@ev_empty = private constant [6 x i8] c"empty\00"
@ev_module = private constant [7 x i8] c"module\00"
@ev_modulemeta = private constant [11 x i8] c"modulemeta\00"
@ev_locname = private constant [8 x i8] c"__loc__\00"
@ev_filekey = private constant [5 x i8] c"file\00"
@ev_linekey = private constant [5 x i8] c"line\00"
@ev_topfile = private constant [12 x i8] c"<top-level>\00"
@j_library_paths = external global ptr
declare ptr @j_read_file(ptr)

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
declare i32 @j_cmp(ptr, ptr)
declare i1 @j_truth(ptr)
declare ptr @j_parse(ptr, i64, ptr)
declare ptr @j_lex_number(ptr, i64, ptr)
declare ptr @j_dump(ptr, i32)
declare ptr @j_binary(i32, ptr, ptr)
declare ptr @j_negate(ptr)
declare void @j_fail(ptr)
declare ptr @j_builtin(ptr, ptr, ptr, ptr)
declare ptr @j_pick(ptr, ptr, ptr)
declare ptr @b_delete_many(ptr, ptr)
declare ptr @j_builtin_take(ptr, ptr, ptr, ptr, i64)
declare i1 @b_known(ptr, i64)

define internal ptr @ev_node(i32 %kind, i32 %op, ptr %a, ptr %b, ptr %c, ptr %d) {
entry:
  %n = call ptr @j_alloc(i64 64)
  store i32 %kind, ptr %n
  %op.p = getelementptr %N, ptr %n, i32 0, i32 1
  store i32 %op, ptr %op.p
  %a.p = getelementptr %N, ptr %n, i32 0, i32 2
  store ptr %a, ptr %a.p
  %b.p = getelementptr %N, ptr %n, i32 0, i32 3
  store ptr %b, ptr %b.p
  %c.p = getelementptr %N, ptr %n, i32 0, i32 4
  store ptr %c, ptr %c.p
  %d.p = getelementptr %N, ptr %n, i32 0, i32 5
  store ptr %d, ptr %d.p
  ret ptr %n
}

define internal i64 @ev_len(ptr %v) {
entry:
  %p = getelementptr %V, ptr %v, i32 0, i32 3
  %n = load i64, ptr %p
  ret i64 %n
}

define internal void @ev_nodespan(ptr %node, i64 %start, i64 %end) {
entry:
  %sp = getelementptr %N, ptr %node, i32 0, i32 7
  %ep = getelementptr %N, ptr %node, i32 0, i32 8
  %existing = load i64, ptr %ep
  %unset = icmp eq i64 %existing, 0
  br i1 %unset, label %set, label %done
set:
  store i64 %start, ptr %sp
  store i64 %end, ptr %ep
  br label %done
done:
  ret void
}

define internal ptr @ev_one(ptr %v) {
entry:
  %r = call ptr @j_array()
  call void @j_push(ptr %r, ptr %v)
  ret ptr %r
}

define internal void @ev_extend(ptr %dst, ptr %src) {
entry:
  %n = call i64 @ev_len(ptr %src)
  br label %loop
loop:
  %i = phi i64 [0, %entry], [%next, %body]
  %ok = icmp ult i64 %i, %n
  br i1 %ok, label %body, label %done
body:
  %v = call ptr @j_at(ptr %src, i64 %i)
  call void @j_push(ptr %dst, ptr %v)
  %next = add i64 %i, 1
  br label %loop
done:
  ret void
}

define internal i1 @ev_ident(i8 %c) {
entry:
  %a = icmp uge i8 %c, 97
  %b = icmp ule i8 %c, 122
  %lower = and i1 %a, %b
  %d = icmp uge i8 %c, 65
  %e = icmp ule i8 %c, 90
  %upper = and i1 %d, %e
  %us = icmp eq i8 %c, 95
  %alpha = or i1 %lower, %upper
  %r = or i1 %alpha, %us
  ret i1 %r
}

define internal i1 @ev_digit(i8 %c) {
entry:
  %a = icmp uge i8 %c, 48
  %b = icmp ule i8 %c, 57
  %r = and i1 %a, %b
  ret i1 %r
}

define internal i64 @ev_quoteend(ptr %s, i64 %len, i64 %start) {
entry:
  %first = add i64 %start, 1
  br label %loop
loop:
  %i = phi i64 [%first, %entry], [%next, %plain], [%escnext, %escape], [%pend, %interpolate]
  %inside = icmp ult i64 %i, %len
  br i1 %inside, label %read, label %done
read:
  %p = getelementptr i8, ptr %s, i64 %i
  %ch = load i8, ptr %p
  %close = icmp eq i8 %ch, 34
  br i1 %close, label %found, label %slashcheck
slashcheck:
  %slash = icmp eq i8 %ch, 92
  br i1 %slash, label %escaperead, label %plain
escaperead:
  %after = add i64 %i, 1
  %has = icmp ult i64 %after, %len
  br i1 %has, label %escapetest, label %done
escapetest:
  %ep = getelementptr i8, ptr %s, i64 %after
  %ec = load i8, ptr %ep
  %interp = icmp eq i8 %ec, 40
  br i1 %interp, label %interpolate, label %escape
interpolate:
  %istart = add i64 %i, 2
  %pend = call i64 @ev_parenend(ptr %s, i64 %len, i64 %istart)
  br label %loop
escape:
  %escnext = add i64 %i, 2
  br label %loop
plain:
  %next = add i64 %i, 1
  br label %loop
found:
  %end = add i64 %i, 1
  ret i64 %end
done:
  ret i64 %len
}

define internal i64 @ev_parenend(ptr %s, i64 %len, i64 %start) {
entry:
  br label %loop
loop:
  %i = phi i64 [%start, %entry], [%next, %plain], [%qend, %quote]
  %depth = phi i64 [1, %entry], [%nd, %plain], [%depth, %quote]
  %inside = icmp ult i64 %i, %len
  br i1 %inside, label %read, label %done
read:
  %p = getelementptr i8, ptr %s, i64 %i
  %ch = load i8, ptr %p
  %isquote = icmp eq i8 %ch, 34
  br i1 %isquote, label %quote, label %test
quote:
  %qend = call i64 @ev_quoteend(ptr %s, i64 %len, i64 %i)
  br label %loop
test:
  %open = icmp eq i8 %ch, 40
  %close = icmp eq i8 %ch, 41
  %inc = zext i1 %open to i64
  %dec = zext i1 %close to i64
  %plus = add i64 %depth, %inc
  %nd = sub i64 %plus, %dec
  %end = icmp eq i64 %nd, 0
  br i1 %end, label %found, label %plain
plain:
  %next = add i64 %i, 1
  br label %loop
found:
  %result = add i64 %i, 1
  ret i64 %result
done:
  ret i64 %len
}

define internal i32 @ev_keyword(ptr %s) {
entry:
  %as = call i1 @j_is(ptr %s, ptr @ev_as)
  br i1 %as, label %r272, label %cif
cif:
  %if = call i1 @j_is(ptr %s, ptr @ev_if)
  br i1 %if, label %r273, label %cthen
cthen:
  %then = call i1 @j_is(ptr %s, ptr @ev_then)
  br i1 %then, label %r274, label %celse
celse:
  %else = call i1 @j_is(ptr %s, ptr @ev_else)
  br i1 %else, label %r275, label %celif
celif:
  %elif = call i1 @j_is(ptr %s, ptr @ev_elif)
  br i1 %elif, label %r276, label %cend
cend:
  %end = call i1 @j_is(ptr %s, ptr @ev_end)
  br i1 %end, label %r277, label %cdef
cdef:
  %def = call i1 @j_is(ptr %s, ptr @ev_def)
  br i1 %def, label %r278, label %cred
cred:
  %red = call i1 @j_is(ptr %s, ptr @ev_reduce)
  br i1 %red, label %r279, label %cforeach
cforeach:
  %fe = call i1 @j_is(ptr %s, ptr @ev_foreach)
  br i1 %fe, label %r280, label %ctry
ctry:
  %tr = call i1 @j_is(ptr %s, ptr @ev_try)
  br i1 %tr, label %r281, label %ccatch
ccatch:
  %ca = call i1 @j_is(ptr %s, ptr @ev_catch)
  br i1 %ca, label %r282, label %cand
cand:
  %an = call i1 @j_is(ptr %s, ptr @ev_and)
  br i1 %an, label %r283, label %cor
cor:
  %or = call i1 @j_is(ptr %s, ptr @ev_or)
  br i1 %or, label %r284, label %clabel
clabel:
  %la = call i1 @j_is(ptr %s, ptr @ev_label)
  br i1 %la, label %r285, label %cbreak
cbreak:
  %br = call i1 @j_is(ptr %s, ptr @ev_break)
  br i1 %br, label %r286, label %cinclude
cinclude:
  %in = call i1 @j_is(ptr %s, ptr @ev_include)
  br i1 %in, label %r287, label %cimport
cimport:
  %im = call i1 @j_is(ptr %s, ptr @ev_import)
  br i1 %im, label %r288, label %cmodule
cmodule:
  %mo = call i1 @j_is(ptr %s, ptr @ev_module)
  br i1 %mo, label %r291, label %normal
normal:
  ret i32 256
r272:
  ret i32 272
r273:
  ret i32 273
r274:
  ret i32 274
r275:
  ret i32 275
r276:
  ret i32 276
r277:
  ret i32 277
r278:
  ret i32 278
r279:
  ret i32 279
r280:
  ret i32 280
r281:
  ret i32 281
r282:
  ret i32 282
r283:
  ret i32 283
r284:
  ret i32 284
r285:
  ret i32 285
r286:
  ret i32 286
r287:
  ret i32 287
r288:
  ret i32 288
r291:
  ret i32 291
}

define internal void @ev_next(ptr %p) {
entry:
  %src = load ptr, ptr %p
  %len.p = getelementptr %P, ptr %p, i32 0, i32 1
  %len = load i64, ptr %len.p
  %pos.p = getelementptr %P, ptr %p, i32 0, i32 2
  %pos = load i64, ptr %pos.p
  %lastend.p = getelementptr %P, ptr %p, i32 0, i32 7
  store i64 %pos, ptr %lastend.p
  %tok.p = getelementptr %P, ptr %p, i32 0, i32 3
  %val.p = getelementptr %P, ptr %p, i32 0, i32 4
  store ptr null, ptr %val.p
  br label %skip
skip:
  %i = phi i64 [%pos, %entry], [%nextspace, %space], [%commentend, %commentdone]
  %more = icmp ult i64 %i, %len
  br i1 %more, label %read, label %eof
read:
  %at = getelementptr i8, ptr %src, i64 %i
  %ch = load i8, ptr %at
  %white = icmp ule i8 %ch, 32
  br i1 %white, label %space, label %hashcheck
space:
  %nextspace = add i64 %i, 1
  br label %skip
hashcheck:
  %hash = icmp eq i8 %ch, 35
  br i1 %hash, label %comment, label %classify
comment:
  %ci = phi i64 [%i, %hashcheck], [%cn, %commentread], [%cn, %commentcontinued]
  %cmore = icmp ult i64 %ci, %len
  br i1 %cmore, label %commentread, label %commentdone
commentread:
  %cp = getelementptr i8, ptr %src, i64 %ci
  %cc = load i8, ptr %cp
  %cn = add i64 %ci, 1
  %newline = icmp eq i8 %cc, 10
  br i1 %newline, label %commentnewline, label %comment
commentnewline:
  %continuation = call i1 @ev_commentcontinuation(ptr %src, i64 %i, i64 %ci)
  br i1 %continuation, label %commentcontinued, label %commentdone
commentcontinued:
  br label %comment
commentdone:
  %commentend = phi i64 [%ci, %comment], [%cn, %commentnewline]
  br label %skip
classify:
  %start.p = getelementptr %P, ptr %p, i32 0, i32 6
  store i64 %i, ptr %start.p
  %one = add i64 %i, 1
  store i64 %one, ptr %pos.p
  %id = call i1 @ev_ident(i8 %ch)
  %dollar = icmp eq i8 %ch, 36
  %atname = icmp eq i8 %ch, 64
  %named1 = or i1 %id, %dollar
  %named = or i1 %named1, %atname
  br i1 %named, label %namebegin, label %numbercheck
namebegin:
  %start = select i1 %dollar, i64 %one, i64 %i
  br label %nameloop
nameloop:
  %ni = phi i64 [%one, %namebegin], [%nn, %nameadvance]
  %nmore = icmp ult i64 %ni, %len
  br i1 %nmore, label %nameread, label %namedone
nameread:
  %np = getelementptr i8, ptr %src, i64 %ni
  %nc = load i8, ptr %np
  %na = call i1 @ev_ident(i8 %nc)
  %nd = call i1 @ev_digit(i8 %nc)
  %nvalid = or i1 %na, %nd
  br i1 %nvalid, label %nameadvance, label %namespacecheck
namespacecheck:
  %colon = icmp eq i8 %nc, 58
  %nsnext = add i64 %ni, 1
  %nshas = icmp ult i64 %nsnext, %len
  %nspossible = and i1 %colon, %nshas
  br i1 %nspossible, label %namespaceread, label %namedone
namespaceread:
  %nsp = getelementptr i8, ptr %src, i64 %nsnext
  %nsc = load i8, ptr %nsp
  %nscolon = icmp eq i8 %nsc, 58
  br i1 %nscolon, label %nameadvance, label %namedone
nameadvance:
  %step = phi i64 [1, %nameread], [2, %namespaceread]
  %nn = add i64 %ni, %step
  br label %nameloop
namedone:
  %nb = getelementptr i8, ptr %src, i64 %start
  %nl = sub i64 %ni, %start
  %name = call ptr @j_str(ptr %nb, i64 %nl)
  store i64 %ni, ptr %pos.p
  store ptr %name, ptr %val.p
  br i1 %dollar, label %variable, label %namekeyword
variable:
  store i32 258, ptr %tok.p
  ret void
namekeyword:
  %ist = call i1 @j_is(ptr %name, ptr @ev_true)
  %isf = call i1 @j_is(ptr %name, ptr @ev_false)
  %isn = call i1 @j_is(ptr %name, ptr @ev_null)
  %boolean = or i1 %ist, %isf
  %islit = or i1 %boolean, %isn
  br i1 %islit, label %nameliteral, label %keyword
nameliteral:
  %bv = call ptr @j_bool(i1 %ist)
  %nv = call ptr @j_null()
  %lv = select i1 %isn, ptr %nv, ptr %bv
  store ptr %lv, ptr %val.p
  store i32 257, ptr %tok.p
  ret void
keyword:
  %kt = call i32 @ev_keyword(ptr %name)
  store i32 %kt, ptr %tok.p
  ret void
numbercheck:
  %dig = call i1 @ev_digit(i8 %ch)
  br i1 %dig, label %numberbegin, label %decimalcheck
decimalcheck:
  %decimaldot = icmp eq i8 %ch, 46
  %decimalhas = icmp ult i64 %one, %len
  %decimalpossible = and i1 %decimaldot, %decimalhas
  br i1 %decimalpossible, label %decimalread, label %quotecheck
decimalread:
  %decimalp = getelementptr i8, ptr %src, i64 %one
  %decimalc = load i8, ptr %decimalp
  %decimaldigit = call i1 @ev_digit(i8 %decimalc)
  br i1 %decimaldigit, label %numberbegin, label %quotecheck
numberbegin:
  %offset = alloca i64
  store i64 %i, ptr %offset
  %number = call ptr @j_lex_number(ptr %src, i64 %len, ptr %offset)
  %numberend = load i64, ptr %offset
  store i64 %numberend, ptr %pos.p
  store ptr %number, ptr %val.p
  store i32 257, ptr %tok.p
  ret void
quotecheck:
  %isquote = icmp eq i8 %ch, 34
  br i1 %isquote, label %quoted, label %operator
quoted:
  %qend = call i64 @ev_quoteend(ptr %src, i64 %len, i64 %i)
  %qlen = sub i64 %qend, %i
  %qlast = sub i64 %qend, 1
  %qlp = getelementptr i8, ptr %src, i64 %qlast
  %qlc = load i8, ptr %qlp
  %qclosed = icmp eq i8 %qlc, 34
  %qwide = icmp uge i64 %qlen, 2
  %qvalid = and i1 %qclosed, %qwide
  br i1 %qvalid, label %quotestore, label %quoteerror
quoteerror:
  %qerrp = getelementptr %P, ptr %p, i32 0, i32 5
  store i32 1, ptr %qerrp
  call void @j_fail(ptr @ev_syntax)
  br label %quotestore
quotestore:
  call void @ev_validateescapes(ptr %src, i64 %i, i64 %qend)
  %raw = call ptr @j_str(ptr %at, i64 %qlen)
  store i64 %qend, ptr %pos.p
  store i32 290, ptr %tok.p
  store ptr %raw, ptr %val.p
  ret void
operator:
  %has2 = icmp ult i64 %one, %len
  br i1 %has2, label %operatorread, label %single
operatorread:
  %p2 = getelementptr i8, ptr %src, i64 %one
  %c2 = load i8, ptr %p2
  %question = icmp eq i8 %ch, 63
  %slashsecond = icmp eq i8 %c2, 47
  %patternpossible = and i1 %question, %slashsecond
  br i1 %patternpossible, label %patterncheck, label %equalscheck
patterncheck:
  %patternthird = add i64 %i, 2
  %patternhas = icmp ult i64 %patternthird, %len
  br i1 %patternhas, label %patternread, label %single
patternread:
  %patternp = getelementptr i8, ptr %src, i64 %patternthird
  %patternc = load i8, ptr %patternp
  %patternslash = icmp eq i8 %patternc, 47
  br i1 %patternslash, label %patternop, label %single
patternop:
  %patternend = add i64 %i, 3
  store i64 %patternend, ptr %pos.p
  store i32 289, ptr %tok.p
  ret void
equalscheck:
  %eq = icmp eq i8 %c2, 61
  br i1 %eq, label %equals, label %repeat
equals:
  switch i8 %ch, label %single [i8 61, label %eq260 i8 33, label %eq261 i8 60, label %eq262 i8 62, label %eq263 i8 124, label %eq265 i8 43, label %eq266 i8 45, label %eq267 i8 42, label %eq268 i8 47, label %eq269 i8 37, label %eq270]
eq260:
  br label %double
eq261:
  br label %double
eq262:
  br label %double
eq263:
  br label %double
eq265:
  br label %double
eq266:
  br label %double
eq267:
  br label %double
eq268:
  br label %double
eq269:
  br label %double
eq270:
  br label %double
repeat:
  %same = icmp eq i8 %ch, %c2
  %slash = icmp eq i8 %ch, 47
  %dot = icmp eq i8 %ch, 46
  %repok = or i1 %slash, %dot
  %repeated = and i1 %same, %repok
  br i1 %repeated, label %repeatedop, label %single
repeatedop:
  br i1 %dot, label %dotdot, label %altcheck
dotdot:
  br label %double
altcheck:
  %two = add i64 %i, 2
  %has3 = icmp ult i64 %two, %len
  br i1 %has3, label %altread, label %alt
altread:
  %p3 = getelementptr i8, ptr %src, i64 %two
  %c3 = load i8, ptr %p3
  %alteq = icmp eq i8 %c3, 61
  br i1 %alteq, label %alassign, label %alt
alassign:
  %three = add i64 %i, 3
  store i64 %three, ptr %pos.p
  store i32 271, ptr %tok.p
  ret void
alt:
  br label %double
double:
  %dt = phi i32 [260, %eq260], [261, %eq261], [262, %eq262], [263, %eq263], [265, %eq265], [266, %eq266], [267, %eq267], [268, %eq268], [269, %eq269], [270, %eq270], [264, %dotdot], [259, %alt]
  %dend = add i64 %i, 2
  store i64 %dend, ptr %pos.p
  store i32 %dt, ptr %tok.p
  ret void
single:
  %st = zext i8 %ch to i32
  store i32 %st, ptr %tok.p
  ret void
eof:
  %eofstart.p = getelementptr %P, ptr %p, i32 0, i32 6
  store i64 %len, ptr %eofstart.p
  store i64 %len, ptr %pos.p
  store i32 0, ptr %tok.p
  ret void
}

define internal i32 @ev_tok(ptr %p) {
entry:
  %tp = getelementptr %P, ptr %p, i32 0, i32 3
  %t = load i32, ptr %tp
  ret i32 %t
}

define internal ptr @ev_val(ptr %p) {
entry:
  %vp = getelementptr %P, ptr %p, i32 0, i32 4
  %v = load ptr, ptr %vp
  ret ptr %v
}

define internal i64 @ev_start(ptr %p) {
entry:
  %sp = getelementptr %P, ptr %p, i32 0, i32 6
  %start = load i64, ptr %sp
  ret i64 %start
}

define internal void @ev_compileerror(i64 %start, i64 %end, ptr %message) {
entry:
  %error = load ptr, ptr @j_error
  %clear = icmp eq ptr %error, null
  br i1 %clear, label %raise, label %done
raise:
  store i64 %start, ptr @j_compile_error_start
  store i64 %end, ptr @j_compile_error_end
  call void @j_fail(ptr %message)
  %errorvalue = load ptr, ptr @j_error
  call void @ev_recorderror(ptr %errorvalue, i64 %start, i64 %end, i1 false)
  br label %done
done:
  ret void
}

define internal i64 @ev_consumedend(ptr %p) {
entry:
  %ep = getelementptr %P, ptr %p, i32 0, i32 7
  %end = load i64, ptr %ep
  ret i64 %end
}

define internal void @ev_recorderror(ptr %message, i64 %start, i64 %end, i1 %raw) {
entry:
  %existing = load ptr, ptr @j_compile_errors
  %has = icmp ne ptr %existing, null
  br i1 %has, label %ready, label %create
create:
  %fresh = call ptr @j_array()
  store ptr %fresh, ptr @j_compile_errors
  br label %ready
ready:
  %errors = phi ptr [%existing, %entry], [%fresh, %create]
  %record = call ptr @j_array()
  %sd = uitofp i64 %start to double
  %ed = uitofp i64 %end to double
  %sv = call ptr @j_num(double %sd)
  %ev = call ptr @j_num(double %ed)
  %rv = call ptr @j_bool(i1 %raw)
  call void @j_push(ptr %record, ptr %message)
  call void @j_push(ptr %record, ptr %sv)
  call void @j_push(ptr %record, ptr %ev)
  call void @j_push(ptr %record, ptr %rv)
  call void @j_push(ptr %errors, ptr %record)
  ret void
}

@ev_nomain = private constant [40 x i8] c"Top-level program not given (try \22.\22)\00\00\00"
@ev_functionlimitmessage = private constant [78 x i8] c"too many function parameters or local function definitions (max 4095)\00\00\00\00\00\00\00\00\00"

define internal void @ev_rawerror(ptr %message) {
entry:
  %old = load ptr, ptr @j_error
  %clear = icmp eq ptr %old, null
  br i1 %clear, label %raise, label %done
raise:
  call void @j_fail(ptr %message)
  store i1 true, ptr @j_compile_error_raw
  %error = load ptr, ptr @j_error
  call void @ev_recorderror(ptr %error, i64 0, i64 1, i1 true)
  br label %done
done:
  ret void
}

define internal void @ev_functionlimit(i64 %count) {
entry:
  %over = icmp ugt i64 %count, 4095
  br i1 %over, label %error, label %done
error:
  call void @ev_rawerror(ptr @ev_functionlimitmessage)
  br label %done
done:
  ret void
}

define internal i64 @ev_functioncount(ptr %env) {
entry:
  br label %loop
loop:
  %e = phi ptr [%env, %entry], [%next, %body]
  %count = phi i64 [0, %entry], [%newcount, %body]
  %none = icmp eq ptr %e, null
  br i1 %none, label %done, label %body
body:
  %tp = getelementptr %E, ptr %e, i32 0, i32 3
  %type = load i32, ptr %tp
  %function = icmp eq i32 %type, 1
  %inc = zext i1 %function to i64
  %newcount = add i64 %count, %inc
  %next = load ptr, ptr %e
  br label %loop
done:
  ret i64 %count
}

define internal ptr @ev_rest(ptr %p) {
entry:
  %token = call i32 @ev_tok(ptr %p)
  %missing = icmp eq i32 %token, 0
  br i1 %missing, label %error, label %parse
error:
  call void @ev_rawerror(ptr @ev_nomain)
  %null = call ptr @j_null()
  %node = call ptr @ev_node(i32 0, i32 0, ptr %null, ptr null, ptr null, ptr null)
  ret ptr %node
parse:
  %body = call ptr @ev_expr(ptr %p, i32 1)
  ret ptr %body
}

define ptr @j_debug_import_env(ptr %node, ptr %env) {
entry:
  %result = call ptr @ev_importenv(ptr %node, ptr %env, ptr null)
  ret ptr %result
}

@ev_unexpectedcatch = private constant [75 x i8] c"syntax error, unexpected catch, expecting end or '|' or ','\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
@ev_unterminatedif = private constant [37 x i8] c"Possibly unterminated 'if' statement\00"
@ev_unterminatedtry = private constant [38 x i8] c"Possibly unterminated 'try' statement\00"

define internal void @ev_expectend(ptr %p, i64 %start, i64 %headerend) {
entry:
  %t = call i32 @ev_tok(ptr %p)
  %matched = icmp eq i32 %t, 277
  br i1 %matched, label %good, label %bad
good:
  call void @ev_next(ptr %p)
  ret void
bad:
  %existing = load ptr, ptr @j_error
  %clear = icmp eq ptr %existing, null
  br i1 %clear, label %error, label %done
error:
  %at = call i64 @ev_start(ptr %p)
  %endp = getelementptr %P, ptr %p, i32 0, i32 2
  %end = load i64, ptr %endp
  %catch = icmp eq i32 %t, 282
  br i1 %catch, label %catcherror, label %othererror
catcherror:
  call void @ev_compileerror(i64 %at, i64 %end, ptr @ev_unexpectedcatch)
  br label %context
othererror:
  call void @ev_syntaxerror(i32 %t, i64 %at, i64 %end, i1 false)
  br label %context
context:
  %ep = getelementptr %P, ptr %p, i32 0, i32 5
  store i32 1, ptr %ep
  %message = call ptr @j_cstr(ptr @ev_unterminatedif)
  call void @ev_recorderror(ptr %message, i64 %start, i64 %headerend, i1 false)
  br label %done
done:
  ret void
}

define internal void @ev_trycontext(ptr %p, i64 %start, i1 %hascatch) {
entry:
  %error = load ptr, ptr @j_error
  %failed = icmp ne ptr %error, null
  br i1 %failed, label %count, label %done
count:
  %records = load ptr, ptr @j_compile_errors
  %present = icmp ne ptr %records, null
  br i1 %present, label %recordcount, label %done
recordcount:
  %n = call i64 @ev_len(ptr %records)
  %nested = icmp uge i64 %n, 2
  %contextual = or i1 %nested, %hascatch
  br i1 %contextual, label %line, label %done
line:
  %source = load ptr, ptr %p
  %lp = getelementptr %P, ptr %p, i32 0, i32 1
  %len = load i64, ptr %lp
  br label %loop
loop:
  %i = phi i64 [%start, %line], [%next, %advance]
  %inside = icmp ult i64 %i, %len
  br i1 %inside, label %read, label %emit
read:
  %cp = getelementptr i8, ptr %source, i64 %i
  %ch = load i8, ptr %cp
  %newline = icmp eq i8 %ch, 10
  br i1 %newline, label %emit, label %advance
advance:
  %next = add i64 %i, 1
  br label %loop
emit:
  %message = call ptr @j_cstr(ptr @ev_unterminatedtry)
  call void @ev_recorderror(ptr %message, i64 %start, i64 %i, i1 false)
  br label %done
done:
  ret void
}

define internal void @ev_expect(ptr %p, i32 %expected) {
entry:
  %t = call i32 @ev_tok(ptr %p)
  %ok = icmp eq i32 %t, %expected
  br i1 %ok, label %yes, label %no
yes:
  call void @ev_next(ptr %p)
  ret void
no:
  %ep = getelementptr %P, ptr %p, i32 0, i32 5
  store i32 1, ptr %ep
  %start = call i64 @ev_start(ptr %p)
  %posp = getelementptr %P, ptr %p, i32 0, i32 2
  %end = load i64, ptr %posp
  call void @ev_compileerror(i64 %start, i64 %end, ptr @ev_syntax)
  ret void
}

define internal ptr @ev_segment(ptr %src, i64 %start, i64 %end) {
entry:
  %n = sub i64 %end, %start
  %size = add i64 %n, 2
  %buf = call ptr @j_alloc(i64 %size)
  store i8 34, ptr %buf
  br label %loop
loop:
  %i = phi i64 [0, %entry], [%next, %body]
  %ok = icmp ult i64 %i, %n
  br i1 %ok, label %body, label %done
body:
  %off = add i64 %start, %i
  %sp = getelementptr i8, ptr %src, i64 %off
  %ch = load i8, ptr %sp
  %di = add i64 %i, 1
  %dp = getelementptr i8, ptr %buf, i64 %di
  store i8 %ch, ptr %dp
  %next = add i64 %i, 1
  br label %loop
done:
  %last = add i64 %n, 1
  %lp = getelementptr i8, ptr %buf, i64 %last
  store i8 34, ptr %lp
  %offset = alloca i64
  store i64 0, ptr %offset
  %value = call ptr @j_parse(ptr %buf, i64 %size, ptr %offset)
  %isnull = icmp eq ptr %value, null
  br i1 %isnull, label %bad, label %good
bad:
  %empty = call ptr @j_str(ptr %buf, i64 0)
  ret ptr %empty
good:
  ret ptr %value
}

define internal ptr @ev_string(ptr %raw, ptr %format) {
entry:
  %existing = load ptr, ptr @j_error
  %clear = icmp eq ptr %existing, null
  br i1 %clear, label %begin, label %failed
failed:
  %emptyfailed = call ptr @j_str(ptr null, i64 0)
  %failednode = call ptr @ev_node(i32 0, i32 0, ptr %emptyfailed, ptr null, ptr null, ptr null)
  ret ptr %failednode
begin:
  %dp = getelementptr %V, ptr %raw, i32 0, i32 5
  %src = load ptr, ptr %dp
  %len = call i64 @ev_len(ptr %raw)
  %end = sub i64 %len, 1
  %empty = call ptr @j_str(ptr %src, i64 0)
  %initial = call ptr @ev_node(i32 0, i32 0, ptr %empty, ptr null, ptr null, ptr null)
  br label %loop
loop:
  %i = phi i64 [1, %begin], [%next, %plain], [%escnext, %escape], [%iend, %interpolate]
  %seg = phi i64 [1, %begin], [%seg, %plain], [%seg, %escape], [%iend, %interpolate]
  %ast = phi ptr [%initial, %begin], [%ast, %plain], [%ast, %escape], [%joined, %interpolate]
  %more = icmp ult i64 %i, %end
  br i1 %more, label %read, label %done
read:
  %cp = getelementptr i8, ptr %src, i64 %i
  %ch = load i8, ptr %cp
  %slash = icmp eq i8 %ch, 92
  br i1 %slash, label %escaperead, label %plain
escaperead:
  %ei = add i64 %i, 1
  %ep = getelementptr i8, ptr %src, i64 %ei
  %ec = load i8, ptr %ep
  %interp = icmp eq i8 %ec, 40
  br i1 %interp, label %interpolate, label %escape
escape:
  %escnext = add i64 %i, 2
  br label %loop
plain:
  %next = add i64 %i, 1
  br label %loop
interpolate:
  %prefix = call ptr @ev_segment(ptr %src, i64 %seg, i64 %i)
  %prefixnode = call ptr @ev_node(i32 0, i32 0, ptr %prefix, ptr null, ptr null, ptr null)
  %prefixed = call ptr @ev_node(i32 4, i32 0, ptr %ast, ptr %prefixnode, ptr null, ptr null)
  %istart = add i64 %i, 2
  %iend = call i64 @ev_parenend(ptr %src, i64 %len, i64 %istart)
  %span = sub i64 %iend, %istart
  %ilen = sub i64 %span, 1
  %isrc = getelementptr i8, ptr %src, i64 %istart
  %expr = call ptr @j_compile(ptr %isrc, i64 %ilen)
  %plainname = call ptr @j_cstr(ptr @ev_tostring)
  %nofmt = icmp eq ptr %format, null
  %name = select i1 %nofmt, ptr %plainname, ptr %format
  %args = call ptr @j_array()
  %convert = call ptr @ev_node(i32 7, i32 0, ptr %name, ptr %args, ptr null, ptr null)
  %converted = call ptr @ev_node(i32 2, i32 0, ptr %expr, ptr %convert, ptr null, ptr null)
  %joined = call ptr @ev_node(i32 4, i32 0, ptr %prefixed, ptr %converted, ptr null, ptr null)
  br label %loop
done:
  %suffix = call ptr @ev_segment(ptr %src, i64 %seg, i64 %end)
  %suffixnode = call ptr @ev_node(i32 0, i32 0, ptr %suffix, ptr null, ptr null, ptr null)
  %result = call ptr @ev_node(i32 4, i32 0, ptr %ast, ptr %suffixnode, ptr null, ptr null)
  ret ptr %result
}

define internal i32 @ev_prec(i32 %t) {
entry:
  switch i32 %t, label %none [i32 124, label %p1 i32 44, label %p2 i32 272, label %p3 i32 61, label %p5 i32 265, label %p5 i32 266, label %p5 i32 267, label %p5 i32 268, label %p5 i32 269, label %p5 i32 270, label %p5 i32 271, label %p5 i32 259, label %p4 i32 284, label %p6 i32 283, label %p7 i32 260, label %p8 i32 261, label %p8 i32 262, label %p8 i32 263, label %p8 i32 60, label %p8 i32 62, label %p8 i32 43, label %p9 i32 45, label %p9 i32 42, label %p10 i32 47, label %p10 i32 37, label %p10]
none:
  ret i32 0
p1:
  ret i32 1
p2:
  ret i32 2
p3:
  ret i32 3
p4:
  ret i32 4
p5:
  ret i32 5
p6:
  ret i32 6
p7:
  ret i32 7
p8:
  ret i32 8
p9:
  ret i32 9
p10:
  ret i32 10
}

define internal i32 @ev_binop(i32 %t) {
entry:
  switch i32 %t, label %add [i32 45, label %sub i32 42, label %mul i32 47, label %div i32 37, label %mod i32 260, label %eq i32 261, label %ne i32 60, label %lt i32 262, label %le i32 62, label %gt i32 263, label %ge i32 283, label %and i32 284, label %or]
add:
  ret i32 0
sub:
  ret i32 1
mul:
  ret i32 2
div:
  ret i32 3
mod:
  ret i32 4
eq:
  ret i32 5
ne:
  ret i32 6
lt:
  ret i32 7
le:
  ret i32 8
gt:
  ret i32 9
ge:
  ret i32 10
and:
  ret i32 11
or:
  ret i32 12
}

define internal ptr @ev_expr(ptr %p, i32 %min) {
entry:
  %result = call ptr @ev_expression(ptr %p, i32 %min, i1 false)
  ret ptr %result
}

define internal ptr @ev_expression(ptr %p, i32 %min, i1 %stopcomma) {
entry:
  %first = call ptr @ev_primary(ptr %p)
  br label %loop
loop:
  %left = phi ptr [%first, %entry], [%joined, %infixdone], [%bound, %binding]
  %ep = getelementptr %P, ptr %p, i32 0, i32 5
  %err = load i32, ptr %ep
  %bad = icmp ne i32 %err, 0
  br i1 %bad, label %done, label %check
check:
  %t = call i32 @ev_tok(ptr %p)
  %prec = call i32 @ev_prec(i32 %t)
  %enough = icmp uge i32 %prec, %min
  %nonzero = icmp ne i32 %prec, 0
  %take0 = and i1 %enough, %nonzero
  %iscomma = icmp eq i32 %t, 44
  %blockedcomma = and i1 %iscomma, %stopcomma
  %allowedcomma = xor i1 %blockedcomma, true
  %take = and i1 %take0, %allowedcomma
  br i1 %take, label %infix, label %done
infix:
  call void @ev_next(ptr %p)
  %as = icmp eq i32 %t, 272
  br i1 %as, label %binding, label %right
binding:
  %pattern = call ptr @ev_patternparse(ptr %p)
  call void @ev_expect(ptr %p, i32 124)
  %rest = call ptr @ev_expression(ptr %p, i32 1, i1 %stopcomma)
  %bound = call ptr @ev_node(i32 11, i32 0, ptr %left, ptr %pattern, ptr %rest, ptr null)
  br label %loop
right:
  %assignment = icmp eq i32 %prec, 5
  %rightpipe = icmp eq i32 %t, 124
  %rightalt = icmp eq i32 %t, 259
  %right0 = or i1 %assignment, %rightpipe
  %rightassoc = or i1 %right0, %rightalt
  %normalmin = add i32 %prec, 1
  %rightmin = select i1 %rightassoc, i32 %prec, i32 %normalmin
  %rhs = call ptr @ev_expression(ptr %p, i32 %rightmin, i1 %stopcomma)
  switch i32 %t, label %binary [i32 124, label %pipe i32 44, label %comma i32 259, label %alternative i32 61, label %assign i32 265, label %assign i32 266, label %assign i32 267, label %assign i32 268, label %assign i32 269, label %assign i32 270, label %assign i32 271, label %assign]
pipe:
  %pipe.n = call ptr @ev_node(i32 2, i32 0, ptr %left, ptr %rhs, ptr null, ptr null)
  br label %infixdone
comma:
  %comma.n = call ptr @ev_node(i32 3, i32 0, ptr %left, ptr %rhs, ptr null, ptr null)
  br label %infixdone
alternative:
  %alt.n = call ptr @ev_node(i32 21, i32 0, ptr %left, ptr %rhs, ptr null, ptr null)
  br label %infixdone
assign:
  %assign.n = call ptr @ev_node(i32 19, i32 %t, ptr %left, ptr %rhs, ptr null, ptr null)
  br label %infixdone
binary:
  %op = call i32 @ev_binop(i32 %t)
  %binary.n = call ptr @ev_node(i32 4, i32 %op, ptr %left, ptr %rhs, ptr null, ptr null)
  br label %infixdone
infixdone:
  %joined = phi ptr [%pipe.n, %pipe], [%comma.n, %comma], [%alt.n, %alternative], [%assign.n, %assign], [%binary.n, %binary]
  br label %loop
done:
  ret ptr %left
}

define internal ptr @ev_ifparse(ptr %p, i64 %start) {
entry:
  %cond = call ptr @ev_expr(ptr %p, i32 1)
  %conditionend = call i64 @ev_consumedend(ptr %p)
  call void @ev_expect(ptr %p, i32 274)
  %yes = call ptr @ev_expr(ptr %p, i32 1)
  %t = call i32 @ev_tok(ptr %p)
  switch i32 %t, label %noelse [i32 275, label %else i32 276, label %elif]
else:
  call void @ev_next(ptr %p)
  %no = call ptr @ev_expr(ptr %p, i32 1)
  call void @ev_expectend(ptr %p, i64 %start, i64 %conditionend)
  br label %done
elif:
  %elifstart = call i64 @ev_start(ptr %p)
  call void @ev_next(ptr %p)
  %nested = call ptr @ev_ifparse(ptr %p, i64 %elifstart)
  br label %done
noelse:
  call void @ev_expectend(ptr %p, i64 %start, i64 %conditionend)
  %identity = call ptr @ev_node(i32 1, i32 0, ptr null, ptr null, ptr null, ptr null)
  br label %done
done:
  %otherwise = phi ptr [%no, %else], [%nested, %elif], [%identity, %noelse]
  %result = call ptr @ev_node(i32 13, i32 0, ptr %cond, ptr %yes, ptr %otherwise, ptr null)
  ret ptr %result
}

define internal ptr @ev_primary(ptr %p) {
entry:
  %t = call i32 @ev_tok(ptr %p)
  %v = call ptr @ev_val(ptr %p)
  %currentpp = getelementptr %P, ptr %p, i32 0, i32 2
  %currentend = load i64, ptr %currentpp
  %currentstart = call i64 @ev_start(ptr %p)
  call void @ev_next(ptr %p)
  switch i32 %t, label %bad [i32 257, label %literal i32 290, label %string i32 46, label %dot i32 264, label %recursive i32 258, label %variable i32 256, label %named i32 40, label %paren i32 91, label %array i32 123, label %object i32 45, label %negative i32 273, label %conditional i32 281, label %try i32 278, label %definition i32 279, label %reducer i32 280, label %reducer i32 285, label %label i32 286, label %break i32 287, label %import i32 288, label %import i32 291, label %module]
literal:
  %literal.n = call ptr @ev_node(i32 0, i32 0, ptr %v, ptr null, ptr null, ptr null)
  br label %postfix
string:
  %string.n = call ptr @ev_string(ptr %v, ptr null)
  br label %postfix
dot:
  %identity.n = call ptr @ev_node(i32 1, i32 0, ptr null, ptr null, ptr null, ptr null)
  %dt = call i32 @ev_tok(ptr %p)
  %dn = icmp eq i32 %dt, 256
  %ds = icmp eq i32 %dt, 290
  %dklo = icmp uge i32 %dt, 272
  %dkhi = icmp ule i32 %dt, 291
  %dkeyword = and i1 %dklo, %dkhi
  %dnamed = or i1 %dn, %dkeyword
  %fieldcandidate = or i1 %dnamed, %ds
  %adjacent = call i1 @ev_fieldadjacent(ptr %p, i64 %currentend)
  %field = and i1 %fieldcandidate, %adjacent
  br i1 %field, label %dotfield, label %dotdone
dotfield:
  %key = call ptr @ev_val(ptr %p)
  call void @ev_next(ptr %p)
  br i1 %ds, label %dotstring, label %dotname
dotstring:
  %stringkey = call ptr @ev_string(ptr %key, ptr null)
  br label %dotkey
dotname:
  %namekey = call ptr @ev_node(i32 0, i32 0, ptr %key, ptr null, ptr null, ptr null)
  br label %dotkey
dotkey:
  %keynode = phi ptr [%stringkey, %dotstring], [%namekey, %dotname]
  %fieldnode = call ptr @ev_node(i32 5, i32 0, ptr %identity.n, ptr %keynode, ptr null, ptr null)
  br label %postfix
dotdone:
  br label %postfix
recursive:
  %recursive.n = call ptr @ev_node(i32 17, i32 0, ptr null, ptr null, ptr null, ptr null)
  br label %postfix
variable:
  %location = call ptr @ev_location(ptr %p)
  %variable.n = call ptr @ev_node(i32 10, i32 0, ptr %v, ptr %location, ptr null, ptr null)
  call void @ev_nodespan(ptr %variable.n, i64 %currentstart, i64 %currentend)
  br label %postfix
named:
  %args = call ptr @j_array()
  %nt = call i32 @ev_tok(ptr %p)
  %hasargs = icmp eq i32 %nt, 40
  br i1 %hasargs, label %argstart, label %namedone
argstart:
  call void @ev_next(ptr %p)
  %at0 = call i32 @ev_tok(ptr %p)
  %noargs = icmp eq i32 %at0, 41
  br i1 %noargs, label %argclose, label %argloop
argloop:
  %arg = call ptr @ev_expr(ptr %p, i32 1)
  call void @j_push(ptr %args, ptr %arg)
  %at = call i32 @ev_tok(ptr %p)
  %sep = icmp eq i32 %at, 59
  br i1 %sep, label %argnext, label %argclose
argnext:
  call void @ev_next(ptr %p)
  br label %argloop
argclose:
  call void @ev_expect(ptr %p, i32 41)
  br label %namedone
namedone:
  %name.dp = getelementptr %V, ptr %v, i32 0, i32 5
  %name.data = load ptr, ptr %name.dp
  %name.first = load i8, ptr %name.data
  %format = icmp eq i8 %name.first, 64
  %fmt.t = call i32 @ev_tok(ptr %p)
  %fmt.string = icmp eq i32 %fmt.t, 290
  %formatted = and i1 %format, %fmt.string
  br i1 %formatted, label %formatstring, label %namecall
formatstring:
  %fmt.raw = call ptr @ev_val(ptr %p)
  call void @ev_next(ptr %p)
  %format.n = call ptr @ev_string(ptr %fmt.raw, ptr %v)
  br label %postfix
namecall:
  %call.n = call ptr @ev_node(i32 7, i32 0, ptr %v, ptr %args, ptr null, ptr null)
  call void @ev_nodespan(ptr %call.n, i64 %currentstart, i64 %currentend)
  br label %postfix
paren:
  %paren.n = call ptr @ev_expr(ptr %p, i32 1)
  call void @ev_expect(ptr %p, i32 41)
  br label %postfix
array:
  %art = call i32 @ev_tok(ptr %p)
  %ar.empty = icmp eq i32 %art, 93
  br i1 %ar.empty, label %emptyarray, label %arraycontent
emptyarray:
  call void @ev_next(ptr %p)
  %ar.value = call ptr @j_array()
  %emptyarray.n = call ptr @ev_node(i32 0, i32 0, ptr %ar.value, ptr null, ptr null, ptr null)
  br label %postfix
arraycontent:
  %ar.body = call ptr @ev_expr(ptr %p, i32 1)
  call void @ev_expect(ptr %p, i32 93)
  %array.n = call ptr @ev_node(i32 8, i32 0, ptr %ar.body, ptr null, ptr null, ptr null)
  br label %postfix
object:
  %pairs = call ptr @j_array()
  %ot = call i32 @ev_tok(ptr %p)
  %oempty = icmp eq i32 %ot, 125
  br i1 %oempty, label %objectdone, label %objectloop
objectloop:
  %okt = call i32 @ev_tok(ptr %p)
  %okv = call ptr @ev_val(ptr %p)
  switch i32 %okt, label %objectkeyclassify [i32 256, label %objectname i32 290, label %objectstring i32 258, label %objectvar]
objectkeyclassify:
  %okkeywordlow = icmp uge i32 %okt, 272
  %okkeywordhigh = icmp ule i32 %okt, 291
  %okkeyword = and i1 %okkeywordlow, %okkeywordhigh
  br i1 %okkeyword, label %objectname, label %objectexprkey
objectname:
  call void @ev_next(ptr %p)
  %ok.name = call ptr @ev_node(i32 0, i32 0, ptr %okv, ptr null, ptr null, ptr null)
  br label %objectvalue
objectstring:
  call void @ev_next(ptr %p)
  %ok.string = call ptr @ev_string(ptr %okv, ptr null)
  br label %objectvalue
objectvar:
  call void @ev_next(ptr %p)
  %ok.var = call ptr @ev_node(i32 0, i32 0, ptr %okv, ptr null, ptr null, ptr null)
  br label %objectvalue
objectexprkey:
  %parenthesizedkey = icmp eq i32 %okt, 40
  br i1 %parenthesizedkey, label %objectparenkey, label %objectbadkey
objectparenkey:
  call void @ev_expect(ptr %p, i32 40)
  %objectkeystart = call i64 @ev_start(ptr %p)
  %ok.expr = call ptr @ev_expr(ptr %p, i32 1)
  %objectkeyend = call i64 @ev_consumedend(ptr %p)
  call void @ev_expect(ptr %p, i32 41)
  call void @ev_checkconstkey(ptr %ok.expr, i64 %objectkeystart, i64 %objectkeyend)
  br label %objectvalue
objectbadkey:
  %badkeystart = call i64 @ev_start(ptr %p)
  %ok.badexpr = call ptr @ev_expr(ptr %p, i32 3)
  %badkeyend = call i64 @ev_consumedend(ptr %p)
  call void @ev_compileerror(i64 %badkeystart, i64 %badkeyend, ptr @ev_keyparentheses)
  %badkeyerrorp = getelementptr %P, ptr %p, i32 0, i32 5
  store i32 1, ptr %badkeyerrorp
  br label %objectvalue
objectvalue:
  %ok.node = phi ptr [%ok.name, %objectname], [%ok.string, %objectstring], [%ok.var, %objectvar], [%ok.expr, %objectparenkey], [%ok.badexpr, %objectbadkey]
  %colon.t = call i32 @ev_tok(ptr %p)
  %colon = icmp eq i32 %colon.t, 58
  br i1 %colon, label %objectexplicit, label %objectimplicit
objectexplicit:
  call void @ev_next(ptr %p)
  %ov.expr = call ptr @ev_expression(ptr %p, i32 1, i1 true)
  %ok.explicitvar = icmp eq i32 %okt, 258
  %ok.varkey = call ptr @ev_node(i32 10, i32 0, ptr %okv, ptr null, ptr null, ptr null)
  %ok.explicit = select i1 %ok.explicitvar, ptr %ok.varkey, ptr %ok.node
  br label %objectpair
objectimplicit:
  %isvar = icmp eq i32 %okt, 258
  br i1 %isvar, label %objectvarvalue, label %objectlookup
objectvarvalue:
  %ov.var = call ptr @ev_node(i32 10, i32 0, ptr %okv, ptr null, ptr null, ptr null)
  br label %objectpair
objectlookup:
  %ov.id = call ptr @ev_node(i32 1, i32 0, ptr null, ptr null, ptr null, ptr null)
  %ov.get = call ptr @ev_node(i32 5, i32 0, ptr %ov.id, ptr %ok.node, ptr null, ptr null)
  br label %objectpair
objectpair:
  %ov.node = phi ptr [%ov.expr, %objectexplicit], [%ov.var, %objectvarvalue], [%ov.get, %objectlookup]
  %pairkey = phi ptr [%ok.explicit, %objectexplicit], [%ok.node, %objectvarvalue], [%ok.node, %objectlookup]
  call void @j_push(ptr %pairs, ptr %pairkey)
  call void @j_push(ptr %pairs, ptr %ov.node)
  %osep.t = call i32 @ev_tok(ptr %p)
  %osep = icmp eq i32 %osep.t, 44
  br i1 %osep, label %objectnext, label %objectdone
objectnext:
  call void @ev_next(ptr %p)
  %ont = call i32 @ev_tok(ptr %p)
  %trailing = icmp eq i32 %ont, 125
  br i1 %trailing, label %objectdone, label %objectloop
objectdone:
  call void @ev_expect(ptr %p, i32 125)
  %object.n = call ptr @ev_node(i32 9, i32 0, ptr %pairs, ptr null, ptr null, ptr null)
  br label %postfix
negative:
  %neg.body = call ptr @ev_expr(ptr %p, i32 11)
  %negative.n = call ptr @ev_node(i32 15, i32 0, ptr %neg.body, ptr null, ptr null, ptr null)
  br label %postfix
conditional:
  %if.n = call ptr @ev_ifparse(ptr %p, i64 %currentstart)
  br label %postfix
try:
  %try.body = call ptr @ev_expr(ptr %p, i32 11)
  %try.t = call i32 @ev_tok(ptr %p)
  %hascatch = icmp eq i32 %try.t, 282
  br i1 %hascatch, label %catch, label %nocatch
catch:
  call void @ev_next(ptr %p)
  %catch.body = call ptr @ev_expr(ptr %p, i32 11)
  br label %trydone
nocatch:
  br label %trydone
trydone:
  %handler = phi ptr [%catch.body, %catch], [null, %nocatch]
  call void @ev_trycontext(ptr %p, i64 %currentstart, i1 %hascatch)
  %try.n = call ptr @ev_node(i32 14, i32 0, ptr %try.body, ptr %handler, ptr null, ptr null)
  br label %postfix
definition:
  %def.name = call ptr @ev_val(ptr %p)
  call void @ev_expect(ptr %p, i32 256)
  %def.params = call ptr @j_array()
  %dpt = call i32 @ev_tok(ptr %p)
  %def.hasparams = icmp eq i32 %dpt, 40
  br i1 %def.hasparams, label %defparamsstart, label %defbody
defparamsstart:
  call void @ev_next(ptr %p)
  br label %defparams
defparams:
  %param.t = call i32 @ev_tok(ptr %p)
  %param.v = call ptr @ev_val(ptr %p)
  %param.isvar = icmp eq i32 %param.t, 258
  %param.kind = select i1 %param.isvar, i32 10, i32 7
  %param.n = call ptr @ev_node(i32 %param.kind, i32 0, ptr %param.v, ptr null, ptr null, ptr null)
  call void @j_push(ptr %def.params, ptr %param.n)
  call void @ev_next(ptr %p)
  %param.sep.t = call i32 @ev_tok(ptr %p)
  %param.sep = icmp eq i32 %param.sep.t, 59
  br i1 %param.sep, label %defparamnext, label %defparamclose
defparamnext:
  call void @ev_next(ptr %p)
  br label %defparams
defparamclose:
  call void @ev_expect(ptr %p, i32 41)
  %def.parametercount = call i64 @ev_len(ptr %def.params)
  call void @ev_functionlimit(i64 %def.parametercount)
  br label %defbody
defbody:
  call void @ev_expect(ptr %p, i32 58)
  %def.body = call ptr @ev_expr(ptr %p, i32 1)
  call void @ev_expect(ptr %p, i32 59)
  %def.rest = call ptr @ev_rest(ptr %p)
  %definition.n = call ptr @ev_node(i32 12, i32 0, ptr %def.name, ptr %def.params, ptr %def.body, ptr %def.rest)
  br label %postfix
reducer:
  %red.gen = call ptr @ev_expr(ptr %p, i32 4)
  call void @ev_expect(ptr %p, i32 272)
  %red.pattern = call ptr @ev_primary(ptr %p)
  call void @ev_expect(ptr %p, i32 40)
  %red.init = call ptr @ev_expr(ptr %p, i32 1)
  call void @ev_expect(ptr %p, i32 59)
  %red.update = call ptr @ev_expr(ptr %p, i32 1)
  %red.et = call i32 @ev_tok(ptr %p)
  %red.hasextract = icmp eq i32 %red.et, 59
  br i1 %red.hasextract, label %redextract, label %rednoextract
redextract:
  call void @ev_next(ptr %p)
  %red.extract = call ptr @ev_expr(ptr %p, i32 1)
  br label %reddone
rednoextract:
  br label %reddone
reddone:
  %red.ex = phi ptr [%red.extract, %redextract], [null, %rednoextract]
  call void @ev_expect(ptr %p, i32 41)
  %reducer.n = call ptr @ev_node(i32 18, i32 %t, ptr %red.gen, ptr %red.pattern, ptr %red.init, ptr %red.update)
  %red.exp = getelementptr %N, ptr %reducer.n, i32 0, i32 6
  store ptr %red.ex, ptr %red.exp
  br label %postfix
label:
  %label.name = call ptr @ev_val(ptr %p)
  call void @ev_expect(ptr %p, i32 258)
  call void @ev_expect(ptr %p, i32 124)
  %label.body = call ptr @ev_expr(ptr %p, i32 1)
  %label.n = call ptr @ev_node(i32 22, i32 0, ptr %label.name, ptr %label.body, ptr null, ptr null)
  br label %postfix
break:
  %break.name = call ptr @ev_val(ptr %p)
  call void @ev_expect(ptr %p, i32 258)
  %break.n = call ptr @ev_node(i32 23, i32 0, ptr %break.name, ptr null, ptr null, ptr null)
  br label %postfix
import:
  %importstart = call i64 @ev_start(ptr %p)
  %import.raw = call ptr @ev_val(ptr %p)
  call void @ev_expect(ptr %p, i32 290)
  %import.expr = call ptr @ev_string(ptr %import.raw, ptr null)
  %importwidth = call i64 @ev_len(ptr %import.raw)
  %importend = add i64 %importstart, %importwidth
  %import.path = call ptr @ev_importconstant(ptr %import.expr)
  call void @ev_marksemantic(i64 %importstart, i64 %importend)
  %isimport = icmp eq i32 %t, 288
  br i1 %isimport, label %importalias, label %includealias
importalias:
  call void @ev_expect(ptr %p, i32 272)
  %alias.t = call i32 @ev_tok(ptr %p)
  %alias.v = call ptr @ev_val(ptr %p)
  %alias.data = icmp eq i32 %alias.t, 258
  call void @ev_next(ptr %p)
  br label %importmetadata
includealias:
  br label %importmetadata
importmetadata:
  %import.alias = phi ptr [%alias.v, %importalias], [null, %includealias]
  %import.data = phi i1 [%alias.data, %importalias], [false, %includealias]
  %metadata.t = call i32 @ev_tok(ptr %p)
  %metadata.none = icmp eq i32 %metadata.t, 59
  br i1 %metadata.none, label %importnometa, label %importmeta
importnometa:
  %empty.meta = call ptr @j_object()
  br label %importdone
importmeta:
  %metastart = call i64 @ev_start(ptr %p)
  %meta.expr = call ptr @ev_expr(ptr %p, i32 1)
  %metaend = call i64 @ev_consumedend(ptr %p)
  %meta.value = call ptr @ev_constvalue(ptr %meta.expr)
  call void @ev_checkmetadata(ptr %meta.value)
  call void @ev_marksemantic(i64 %metastart, i64 %metaend)
  br label %importdone
importdone:
  %import.meta = phi ptr [%empty.meta, %importnometa], [%meta.value, %importmeta]
  call void @ev_checkmetadata(ptr %import.meta)
  call void @ev_expect(ptr %p, i32 59)
  %import.rest = call ptr @ev_rest(ptr %p)
  %import.op = zext i1 %import.data to i32
  %import.n = call ptr @ev_node(i32 24, i32 %import.op, ptr %import.path, ptr %import.alias, ptr %import.rest, ptr %import.meta)
  br label %postfix
module:
  %modulestart = call i64 @ev_start(ptr %p)
  %module.expr = call ptr @ev_expr(ptr %p, i32 1)
  %moduleend = call i64 @ev_consumedend(ptr %p)
  %module.meta = call ptr @ev_constvalue(ptr %module.expr)
  call void @ev_checkmetadata(ptr %module.meta)
  call void @ev_marksemantic(i64 %modulestart, i64 %moduleend)
  call void @ev_expect(ptr %p, i32 59)
  %module.rest = call ptr @ev_rest(ptr %p)
  %module.n = call ptr @ev_node(i32 25, i32 0, ptr %module.meta, ptr %module.rest, ptr null, ptr null)
  br label %postfix
bad:
  %errp = getelementptr %P, ptr %p, i32 0, i32 5
  store i32 1, ptr %errp
  call void @ev_syntaxerror(i32 %t, i64 %currentstart, i64 %currentend, i1 true)
  %badval = call ptr @j_null()
  %bad.n = call ptr @ev_node(i32 0, i32 0, ptr %badval, ptr null, ptr null, ptr null)
  ret ptr %bad.n
postfix:
  %base = phi ptr [%literal.n, %literal], [%string.n, %string], [%fieldnode, %dotkey], [%identity.n, %dotdone], [%recursive.n, %recursive], [%variable.n, %variable], [%format.n, %formatstring], [%call.n, %namecall], [%paren.n, %paren], [%emptyarray.n, %emptyarray], [%array.n, %arraycontent], [%object.n, %objectdone], [%negative.n, %negative], [%if.n, %conditional], [%try.n, %trydone], [%definition.n, %defbody], [%reducer.n, %reddone], [%label.n, %label], [%break.n, %break], [%import.n, %importdone], [%module.n, %module], [%optional.n, %optional], [%suffixfield.n, %suffixfielddone], [%index.n, %indexdone], [%iter.n, %iterate], [%slice.n, %slicedone], [%base, %suffixdot]
  %pt = call i32 @ev_tok(ptr %p)
  switch i32 %pt, label %done [i32 63, label %optional i32 46, label %suffixdot i32 91, label %bracket]
optional:
  call void @ev_next(ptr %p)
  %optional.n = call ptr @ev_node(i32 16, i32 0, ptr %base, ptr null, ptr null, ptr null)
  br label %postfix
suffixdot:
  call void @ev_next(ptr %p)
  %sdt = call i32 @ev_tok(ptr %p)
  %sdbracket = icmp eq i32 %sdt, 91
  br i1 %sdbracket, label %postfix, label %suffixfield
suffixfield:
  %sdk = call ptr @ev_val(ptr %p)
  %sdstring = icmp eq i32 %sdt, 290
  call void @ev_next(ptr %p)
  br i1 %sdstring, label %suffixstring, label %suffixname
suffixstring:
  %sdstr.n = call ptr @ev_string(ptr %sdk, ptr null)
  br label %suffixfielddone
suffixname:
  %sdname.n = call ptr @ev_node(i32 0, i32 0, ptr %sdk, ptr null, ptr null, ptr null)
  br label %suffixfielddone
suffixfielddone:
  %sdkey.n = phi ptr [%sdstr.n, %suffixstring], [%sdname.n, %suffixname]
  %suffixfield.n = call ptr @ev_node(i32 5, i32 0, ptr %base, ptr %sdkey.n, ptr null, ptr null)
  br label %postfix
bracket:
  call void @ev_next(ptr %p)
  %bt = call i32 @ev_tok(ptr %p)
  switch i32 %bt, label %index [i32 93, label %iterate i32 58, label %slicestartempty]
iterate:
  call void @ev_next(ptr %p)
  %iter.n = call ptr @ev_node(i32 6, i32 0, ptr %base, ptr null, ptr null, ptr null)
  br label %postfix
index:
  %idx = call ptr @ev_expr(ptr %p, i32 1)
  %it = call i32 @ev_tok(ptr %p)
  %isslice = icmp eq i32 %it, 58
  br i1 %isslice, label %slicestart, label %indexdone
indexdone:
  call void @ev_expect(ptr %p, i32 93)
  %index.n = call ptr @ev_node(i32 5, i32 0, ptr %base, ptr %idx, ptr null, ptr null)
  br label %postfix
slicestartempty:
  br label %slicestart
slicestart:
  %slice.start = phi ptr [%idx, %index], [null, %slicestartempty]
  call void @ev_next(ptr %p)
  %set = call i32 @ev_tok(ptr %p)
  %seempty = icmp eq i32 %set, 93
  br i1 %seempty, label %sliceendempty, label %sliceend
sliceendempty:
  br label %slicedone
sliceend:
  %slice.end.expr = call ptr @ev_expr(ptr %p, i32 1)
  br label %slicedone
slicedone:
  %slice.end = phi ptr [null, %sliceendempty], [%slice.end.expr, %sliceend]
  call void @ev_expect(ptr %p, i32 93)
  %slice.n = call ptr @ev_node(i32 20, i32 0, ptr %base, ptr %slice.start, ptr %slice.end, ptr null)
  br label %postfix
done:
  %expressionend = call i64 @ev_consumedend(ptr %p)
  call void @ev_nodespan(ptr %base, i64 %currentstart, i64 %expressionend)
  ret ptr %base
}

define ptr @j_compile(ptr %source, i64 %length) {
entry:
  %depth = load i64, ptr @ev_compile_depth
  %nesteddepth = add i64 %depth, 1
  store i64 %nesteddepth, ptr @ev_compile_depth
  %rootparse = icmp eq i64 %depth, 0
  br i1 %rootparse, label %reset, label %begin
reset:
  %errors = call ptr @j_array()
  store ptr %errors, ptr @j_compile_errors
  store i1 false, ptr @j_compile_error_raw
  store i64 0, ptr @j_compile_error_start
  store i64 1, ptr @j_compile_error_end
  br label %begin
begin:
  br label %nulscan
nulscan:
  %si = phi i64 [0, %begin], [%snext, %nulread]
  %smore = icmp ult i64 %si, %length
  br i1 %smore, label %nulread, label %parse
nulread:
  %sp = getelementptr i8, ptr %source, i64 %si
  %sc = load i8, ptr %sp
  %nul = icmp eq i8 %sc, 0
  %snext = add i64 %si, 1
  br i1 %nul, label %nulerror, label %nulscan
nulerror:
  call void @j_fail(ptr @ev_syntax)
  store i64 %depth, ptr @ev_compile_depth
  ret ptr null
parse:
  %p = call ptr @j_alloc(i64 64)
  store ptr %source, ptr %p
  %lp = getelementptr %P, ptr %p, i32 0, i32 1
  store i64 %length, ptr %lp
  call void @ev_next(ptr %p)
  %ast = call ptr @ev_expr(ptr %p, i32 1)
  %t = call i32 @ev_tok(ptr %p)
  %end = icmp eq i32 %t, 0
  %errp = getelementptr %P, ptr %p, i32 0, i32 5
  %err = load i32, ptr %errp
  %errfree = icmp eq i32 %err, 0
  %global = load ptr, ptr @j_error
  %globalfree = icmp eq ptr %global, null
  %ok1 = and i1 %end, %errfree
  %ok = and i1 %ok1, %globalfree
  br i1 %ok, label %good, label %bad
good:
  %toplevel = icmp eq i64 %depth, 0
  br i1 %toplevel, label %validate, label %returngood
validate:
  %environment = load ptr, ptr @j_compile_env
  call void @ev_validate(ptr %ast, ptr %environment)
  %validationerror = load ptr, ptr @j_error
  %valid = icmp eq ptr %validationerror, null
  br i1 %valid, label %returngood, label %returnerror
returngood:
  store i64 %depth, ptr @ev_compile_depth
  ret ptr %ast
bad:
  br i1 %globalfree, label %seterror, label %returnerror
seterror:
  %unexpectedstart = call i64 @ev_start(ptr %p)
  %unexpectedendp = getelementptr %P, ptr %p, i32 0, i32 2
  %unexpectedend = load i64, ptr %unexpectedendp
  call void @ev_syntaxerror(i32 %t, i64 %unexpectedstart, i64 %unexpectedend, i1 true)
  br label %returnerror
returnerror:
  store i64 %depth, ptr @ev_compile_depth
  ret ptr null
}

define ptr @j_bind(ptr %env, ptr %name, ptr %value) {
entry:
  %e = call ptr @j_alloc(i64 48)
  store ptr %env, ptr %e
  %np = getelementptr %E, ptr %e, i32 0, i32 1
  store ptr %name, ptr %np
  %vp = getelementptr %E, ptr %e, i32 0, i32 2
  store ptr %value, ptr %vp
  ret ptr %e
}

define internal ptr @ev_lookup(ptr %env, ptr %name, i32 %type, i64 %arity) {
entry:
  br label %loop
loop:
  %e = phi ptr [%env, %entry], [%next, %advance]
  %done = icmp eq ptr %e, null
  br i1 %done, label %missing, label %check
check:
  %np = getelementptr %E, ptr %e, i32 0, i32 1
  %n = load ptr, ptr %np
  %cmp = call i32 @j_cmp(ptr %name, ptr %n)
  %same = icmp eq i32 %cmp, 0
  %tp = getelementptr %E, ptr %e, i32 0, i32 3
  %t = load i32, ptr %tp
  %samekind = icmp eq i32 %t, %type
  %both = and i1 %same, %samekind
  br i1 %both, label %aritycheck, label %advance
aritycheck:
  %function = icmp eq i32 %t, 1
  br i1 %function, label %countparams, label %found
countparams:
  %pp = getelementptr %E, ptr %e, i32 0, i32 4
  %params = load ptr, ptr %pp
  %count = call i64 @ev_len(ptr %params)
  %samearity = icmp eq i64 %count, %arity
  br i1 %samearity, label %found, label %advance
advance:
  %next = load ptr, ptr %e
  br label %loop
found:
  ret ptr %e
missing:
  ret ptr null
}

define internal ptr @ev_bindpattern(ptr %env, ptr %pattern, ptr %value, ptr %input) {
entry:
  %kind = load i32, ptr %pattern
  %ap = getelementptr %N, ptr %pattern, i32 0, i32 2
  %a = load ptr, ptr %ap
  switch i32 %kind, label %unchanged [i32 10, label %variable i32 8, label %array i32 9, label %object]
variable:
  %bound = call ptr @j_bind(ptr %env, ptr %a, ptr %value)
  ret ptr %bound
array:
  %items = call ptr @j_array()
  call void @ev_unpackcomma(ptr %a, ptr %items)
  %n = call i64 @ev_len(ptr %items)
  br label %arrayloop
arrayloop:
  %i = phi i64 [0, %array], [%next, %arraybody]
  %ae = phi ptr [%env, %array], [%ab, %arraybody]
  %more = icmp ult i64 %i, %n
  br i1 %more, label %arraybody, label %arraydone
arraybody:
  %pat = call ptr @j_at(ptr %items, i64 %i)
  %keynum = uitofp i64 %i to double
  %keyindex = call ptr @j_num(double %keynum)
  %part = call ptr @j_get(ptr %value, ptr %keyindex)
  %ab = call ptr @ev_bindpattern(ptr %ae, ptr %pat, ptr %part, ptr %input)
  %next = add i64 %i, 1
  br label %arrayloop
arraydone:
  ret ptr %ae
object:
  %on = call i64 @ev_len(ptr %a)
  br label %objectloop
objectloop:
  %oi = phi i64 [0, %object], [%onext, %objectbind]
  %oe = phi ptr [%env, %object], [%ob, %objectbind]
  %omore = icmp ult i64 %oi, %on
  br i1 %omore, label %objectbody, label %objectdone
objectbody:
  %keyast = call ptr @j_at(ptr %a, i64 %oi)
  %vi = add i64 %oi, 1
  %valast = call ptr @j_at(ptr %a, i64 %vi)
  %keykind = load i32, ptr %keyast
  %keyvariable = icmp eq i32 %keykind, 10
  br i1 %keyvariable, label %objectvarkey, label %objectevalkey
objectvarkey:
  %keynamep = getelementptr %N, ptr %keyast, i32 0, i32 2
  %keyname = load ptr, ptr %keynamep
  %varkeyval = call ptr @j_get(ptr %value, ptr %keyname)
  %varkeyenv = call ptr @j_bind(ptr %oe, ptr %keyname, ptr %varkeyval)
  br label %objectbind
objectevalkey:
  %keys = call ptr @j_eval(ptr %keyast, ptr %input, ptr %oe)
  %key = call ptr @j_at(ptr %keys, i64 0)
  %partv = call ptr @j_get(ptr %value, ptr %key)
  br label %objectbind
objectbind:
  %partvalue = phi ptr [%varkeyval, %objectvarkey], [%partv, %objectevalkey]
  %partenv = phi ptr [%varkeyenv, %objectvarkey], [%oe, %objectevalkey]
  %ob = call ptr @ev_bindpattern(ptr %partenv, ptr %valast, ptr %partvalue, ptr %input)
  %onext = add i64 %oi, 2
  br label %objectloop
objectdone:
  ret ptr %oe
unchanged:
  ret ptr %env
}

define internal void @ev_unpackcomma(ptr %node, ptr %dst) {
entry:
  %kind = load i32, ptr %node
  %comma = icmp eq i32 %kind, 3
  br i1 %comma, label %pair, label %one
pair:
  %ap = getelementptr %N, ptr %node, i32 0, i32 2
  %a = load ptr, ptr %ap
  %bp = getelementptr %N, ptr %node, i32 0, i32 3
  %b = load ptr, ptr %bp
  call void @ev_unpackcomma(ptr %a, ptr %dst)
  call void @ev_unpackcomma(ptr %b, ptr %dst)
  ret void
one:
  call void @j_push(ptr %dst, ptr %node)
  ret void
}

define internal ptr @ev_patternparse(ptr %p) {
entry:
  %first = call ptr @ev_primary(ptr %p)
  %t = call i32 @ev_tok(ptr %p)
  %alternative = icmp eq i32 %t, 289
  br i1 %alternative, label %start, label %single
single:
  ret ptr %first
start:
  %patterns = call ptr @j_array()
  call void @j_push(ptr %patterns, ptr %first)
  br label %loop
loop:
  call void @ev_next(ptr %p)
  %pattern = call ptr @ev_primary(ptr %p)
  call void @j_push(ptr %patterns, ptr %pattern)
  %nexttok = call i32 @ev_tok(ptr %p)
  %more = icmp eq i32 %nexttok, 289
  br i1 %more, label %loop, label %done
done:
  %node = call ptr @ev_node(i32 27, i32 0, ptr %patterns, ptr null, ptr null, ptr null)
  ret ptr %node
}

define internal ptr @ev_patternnull(ptr %node, ptr %env) {
entry:
  %kind = load i32, ptr %node
  %ap = getelementptr %N, ptr %node, i32 0, i32 2
  %a = load ptr, ptr %ap
  %bp = getelementptr %N, ptr %node, i32 0, i32 3
  %b = load ptr, ptr %bp
  switch i32 %kind, label %done [i32 10, label %variable i32 8, label %array i32 3, label %comma i32 9, label %items i32 27, label %items]
variable:
  %null = call ptr @j_null()
  %bound = call ptr @j_bind(ptr %env, ptr %a, ptr %null)
  ret ptr %bound
array:
  %arrayenv = call ptr @ev_patternnull(ptr %a, ptr %env)
  ret ptr %arrayenv
comma:
  %left = call ptr @ev_patternnull(ptr %a, ptr %env)
  %right = call ptr @ev_patternnull(ptr %b, ptr %left)
  ret ptr %right
items:
  %n = call i64 @ev_len(ptr %a)
  br label %loop
loop:
  %i = phi i64 [0, %items], [%next, %body]
  %current = phi ptr [%env, %items], [%newenv, %body]
  %more = icmp ult i64 %i, %n
  br i1 %more, label %body, label %itemdone
body:
  %part = call ptr @j_at(ptr %a, i64 %i)
  %newenv = call ptr @ev_patternnull(ptr %part, ptr %current)
  %next = add i64 %i, 1
  br label %loop
itemdone:
  ret ptr %current
done:
  ret ptr %env
}

define internal ptr @ev_bind_eval(ptr %env, ptr %pattern, ptr %value, ptr %input, ptr %body) {
entry:
  %kind = load i32, ptr %pattern
  %alternative = icmp eq i32 %kind, 27
  br i1 %alternative, label %alternatives, label %single
single:
  %bound = call ptr @ev_bindpattern(ptr %env, ptr %pattern, ptr %value, ptr %input)
  %result = call ptr @j_eval(ptr %body, ptr %input, ptr %bound)
  ret ptr %result
alternatives:
  %ap = getelementptr %N, ptr %pattern, i32 0, i32 2
  %patterns = load ptr, ptr %ap
  %n = call i64 @ev_len(ptr %patterns)
  %initialized = call ptr @ev_patternnull(ptr %pattern, ptr %env)
  br label %loop
loop:
  %i = phi i64 [0, %alternatives], [%next, %again]
  %part = call ptr @j_at(ptr %patterns, i64 %i)
  %boundenv = call ptr @ev_bindpattern(ptr %initialized, ptr %part, ptr %value, ptr %input)
  %values = call ptr @j_eval(ptr %body, ptr %input, ptr %boundenv)
  %error = load ptr, ptr @j_error
  %failed = icmp ne ptr %error, null
  %next = add i64 %i, 1
  %more = icmp ult i64 %next, %n
  %retry = and i1 %failed, %more
  br i1 %retry, label %again, label %done
again:
  store ptr null, ptr @j_error
  br label %loop
done:
  ret ptr %values
}

define internal ptr @ev_callargs(ptr %body, ptr %params, ptr %args, i64 %index, ptr %input, ptr %calling, ptr %bound) {
entry:
  %n = call i64 @ev_len(ptr %params)
  %done = icmp uge i64 %index, %n
  br i1 %done, label %evaluate, label %argument
evaluate:
  %result = call ptr @j_eval(ptr %body, ptr %input, ptr %bound)
  ret ptr %result
argument:
  %formal = call ptr @j_at(ptr %params, i64 %index)
  %actual = call ptr @j_at(ptr %args, i64 %index)
  %kind = load i32, ptr %formal
  %np = getelementptr %N, ptr %formal, i32 0, i32 2
  %name = load ptr, ptr %np
  %next = add i64 %index, 1
  %variable = icmp eq i32 %kind, 10
  br i1 %variable, label %valuearg, label %filterarg
filterarg:
  %closure = call ptr @j_bind(ptr %bound, ptr %name, ptr %actual)
  %tp = getelementptr %E, ptr %closure, i32 0, i32 3
  store i32 2, ptr %tp
  %ep = getelementptr %E, ptr %closure, i32 0, i32 5
  store ptr %calling, ptr %ep
  %filtered = call ptr @ev_callargs(ptr %body, ptr %params, ptr %args, i64 %next, ptr %input, ptr %calling, ptr %closure)
  ret ptr %filtered
valuearg:
  %values = call ptr @j_eval(ptr %actual, ptr %input, ptr %calling)
  %count = call i64 @ev_len(ptr %values)
  %out = call ptr @j_array()
  br label %loop
loop:
  %i = phi i64 [0, %valuearg], [%inext, %loopbody]
  %more = icmp ult i64 %i, %count
  br i1 %more, label %loopbody, label %valuedone
loopbody:
  %v = call ptr @j_at(ptr %values, i64 %i)
  %env = call ptr @j_bind(ptr %bound, ptr %name, ptr %v)
  %r = call ptr @ev_callargs(ptr %body, ptr %params, ptr %args, i64 %next, ptr %input, ptr %calling, ptr %env)
  call void @ev_extend(ptr %out, ptr %r)
  %inext = add i64 %i, 1
  br label %loop
valuedone:
  ret ptr %out
}

define internal ptr @ev_pathcallargs(ptr %body, ptr %params, ptr %args, i64 %index, ptr %input, ptr %calling, ptr %bound) {
entry:
  %n = call i64 @ev_len(ptr %params)
  %done = icmp uge i64 %index, %n
  br i1 %done, label %evaluate, label %argument
evaluate:
  %result = call ptr @ev_paths(ptr %body, ptr %input, ptr %bound)
  ret ptr %result
argument:
  %formal = call ptr @j_at(ptr %params, i64 %index)
  %actual = call ptr @j_at(ptr %args, i64 %index)
  %kind = load i32, ptr %formal
  %np = getelementptr %N, ptr %formal, i32 0, i32 2
  %name = load ptr, ptr %np
  %next = add i64 %index, 1
  %variable = icmp eq i32 %kind, 10
  br i1 %variable, label %valuearg, label %filterarg
filterarg:
  %closure = call ptr @j_bind(ptr %bound, ptr %name, ptr %actual)
  %tp = getelementptr %E, ptr %closure, i32 0, i32 3
  store i32 2, ptr %tp
  %ep = getelementptr %E, ptr %closure, i32 0, i32 5
  store ptr %calling, ptr %ep
  %filtered = call ptr @ev_pathcallargs(ptr %body, ptr %params, ptr %args, i64 %next, ptr %input, ptr %calling, ptr %closure)
  ret ptr %filtered
valuearg:
  %values = call ptr @j_eval(ptr %actual, ptr %input, ptr %calling)
  %count = call i64 @ev_len(ptr %values)
  %out = call ptr @j_array()
  br label %loop
loop:
  %i = phi i64 [0, %valuearg], [%inext, %loopbody]
  %more = icmp ult i64 %i, %count
  br i1 %more, label %loopbody, label %valuedone
loopbody:
  %v = call ptr @j_at(ptr %values, i64 %i)
  %env = call ptr @j_bind(ptr %bound, ptr %name, ptr %v)
  %r = call ptr @ev_pathcallargs(ptr %body, ptr %params, ptr %args, i64 %next, ptr %input, ptr %calling, ptr %env)
  call void @ev_extend(ptr %out, ptr %r)
  %inext = add i64 %i, 1
  br label %loop
valuedone:
  ret ptr %out
}

define internal ptr @ev_objectbuild(ptr %pairs, i64 %index, ptr %object, ptr %input, ptr %env) {
entry:
  %n = call i64 @ev_len(ptr %pairs)
  %complete = icmp uge i64 %index, %n
  br i1 %complete, label %finish, label %pair
finish:
  %finished = call ptr @ev_one(ptr %object)
  ret ptr %finished
pair:
  %keyast = call ptr @j_at(ptr %pairs, i64 %index)
  %vi = add i64 %index, 1
  %valast = call ptr @j_at(ptr %pairs, i64 %vi)
  %keys = call ptr @j_eval(ptr %keyast, ptr %input, ptr %env)
  %vals = call ptr @j_eval(ptr %valast, ptr %input, ptr %env)
  %nk = call i64 @ev_len(ptr %keys)
  %nv = call i64 @ev_len(ptr %vals)
  %out = call ptr @j_array()
  %next = add i64 %index, 2
  br label %keyloop
keyloop:
  %ki = phi i64 [0, %pair], [%knext, %keyadvance]
  %kmore = icmp ult i64 %ki, %nk
  br i1 %kmore, label %keyread, label %done
keyread:
  %key = call ptr @j_at(ptr %keys, i64 %ki)
  %tag = load i32, ptr %key
  %string = icmp eq i32 %tag, 4
  br i1 %string, label %valloop, label %badkey
badkey:
  call void @j_fail(ptr @ev_keyerror)
  br label %done
valloop:
  %vj = phi i64 [0, %keyread], [%vnext, %valbody]
  %vmore = icmp ult i64 %vj, %nv
  br i1 %vmore, label %valbody, label %keyadvance
valbody:
  %value = call ptr @j_at(ptr %vals, i64 %vj)
  %copy = call ptr @j_clone(ptr %object)
  call void @j_put(ptr %copy, ptr %key, ptr %value)
  %r = call ptr @ev_objectbuild(ptr %pairs, i64 %next, ptr %copy, ptr %input, ptr %env)
  call void @ev_extend(ptr %out, ptr %r)
  %vnext = add i64 %vj, 1
  br label %valloop
keyadvance:
  %knext = add i64 %ki, 1
  br label %keyloop
done:
  ret ptr %out
}

define internal void @ev_recursive(ptr %value, ptr %out) {
entry:
  call void @j_push(ptr %out, ptr %value)
  %tag = load i32, ptr %value
  %array = icmp eq i32 %tag, 5
  %object = icmp eq i32 %tag, 6
  %container = or i1 %array, %object
  br i1 %container, label %start, label %done
start:
  %len = call i64 @ev_len(ptr %value)
  %dp = getelementptr %V, ptr %value, i32 0, i32 5
  %data = load ptr, ptr %dp
  br label %loop
loop:
  %i = phi i64 [0, %start], [%next, %body]
  %more = icmp ult i64 %i, %len
  br i1 %more, label %body, label %done
body:
  %twice = mul i64 %i, 2
  %objidx = add i64 %twice, 1
  %idx = select i1 %object, i64 %objidx, i64 %i
  %vp = getelementptr ptr, ptr %data, i64 %idx
  %v = load ptr, ptr %vp
  call void @ev_recursive(ptr %v, ptr %out)
  %next = add i64 %i, 1
  br label %loop
done:
  ret void
}

define internal i64 @ev_indexnum(ptr %v, i64 %fallback) {
entry:
  %isnull = icmp eq ptr %v, null
  br i1 %isnull, label %none, label %tagcheck
tagcheck:
  %tag = load i32, ptr %v
  %isnumber = icmp eq i32 %tag, 3
  br i1 %isnumber, label %number, label %none
number:
  %np = getelementptr %V, ptr %v, i32 0, i32 2
  %num = load double, ptr %np
  %hi = fcmp oge double %num, 0x43E0000000000000
  %lo = fcmp ole double %num, 0xC3E0000000000000
  %nan = fcmp uno double %num, %num
  %bad1 = or i1 %hi, %lo
  %bad = or i1 %bad1, %nan
  br i1 %bad, label %none, label %convert
convert:
  %truncated = fptosi double %num to i64
  %truncatednum = sitofp i64 %truncated to double
  %below = fcmp olt double %num, %truncatednum
  %adjust = zext i1 %below to i64
  %idx = sub i64 %truncated, %adjust
  ret i64 %idx
none:
  ret i64 %fallback
}

define internal i64 @ev_utf8count(ptr %data, i64 %len) {
entry:
  br label %loop
loop:
  %i = phi i64 [0, %entry], [%next, %body]
  %count = phi i64 [0, %entry], [%newcount, %body]
  %more = icmp ult i64 %i, %len
  br i1 %more, label %body, label %done
body:
  %p = getelementptr i8, ptr %data, i64 %i
  %c = load i8, ptr %p
  %masked = and i8 %c, -64
  %cont = icmp eq i8 %masked, -128
  %start = xor i1 %cont, true
  %inc = zext i1 %start to i64
  %newcount = add i64 %count, %inc
  %next = add i64 %i, 1
  br label %loop
done:
  ret i64 %count
}

define internal i64 @ev_utf8offset(ptr %data, i64 %len, i64 %index) {
entry:
  br label %loop
loop:
  %i = phi i64 [0, %entry], [%next, %body]
  %count = phi i64 [0, %entry], [%newcount, %body]
  %more = icmp ult i64 %i, %len
  br i1 %more, label %read, label %done
read:
  %p = getelementptr i8, ptr %data, i64 %i
  %c = load i8, ptr %p
  %masked = and i8 %c, -64
  %cont = icmp eq i8 %masked, -128
  %start = xor i1 %cont, true
  %at = icmp eq i64 %count, %index
  %found = and i1 %start, %at
  br i1 %found, label %done, label %body
body:
  %inc = zext i1 %start to i64
  %newcount = add i64 %count, %inc
  %next = add i64 %i, 1
  br label %loop
done:
  ret i64 %i
}

define internal ptr @ev_slice(ptr %value, ptr %startval, ptr %endval) {
entry:
  %tag = load i32, ptr %value
  %isnull = icmp eq i32 %tag, 0
  br i1 %isnull, label %null, label %typecheck
null:
  ret ptr %value
typecheck:
  %array = icmp eq i32 %tag, 5
  %string = icmp eq i32 %tag, 4
  %valid = or i1 %array, %string
  br i1 %valid, label %length, label %bad
bad:
  call void @j_fail(ptr @ev_patherror)
  %badvalue = call ptr @j_null()
  ret ptr %badvalue
length:
  %bytes = call i64 @ev_len(ptr %value)
  %dp = getelementptr %V, ptr %value, i32 0, i32 5
  %data = load ptr, ptr %dp
  br i1 %string, label %stringlength, label %arraylength
stringlength:
  %chars = call i64 @ev_utf8count(ptr %data, i64 %bytes)
  br label %bounds
arraylength:
  br label %bounds
bounds:
  %len = phi i64 [%chars, %stringlength], [%bytes, %arraylength]
  %start0 = call i64 @ev_indexnum(ptr %startval, i64 0)
  %end0 = call i64 @ev_endnum(ptr %endval, i64 %len)
  %startneg = icmp slt i64 %start0, 0
  %endneg = icmp slt i64 %end0, 0
  %startplus = add i64 %start0, %len
  %endplus = add i64 %end0, %len
  %start1 = select i1 %startneg, i64 %startplus, i64 %start0
  %end1 = select i1 %endneg, i64 %endplus, i64 %end0
  %startunder = icmp slt i64 %start1, 0
  %start2 = select i1 %startunder, i64 0, i64 %start1
  %startover = icmp sgt i64 %start2, %len
  %start = select i1 %startover, i64 %len, i64 %start2
  %endunder = icmp slt i64 %end1, %start
  %end2 = select i1 %endunder, i64 %start, i64 %end1
  %endover = icmp sgt i64 %end2, %len
  %end = select i1 %endover, i64 %len, i64 %end2
  br i1 %string, label %substring, label %subarray
substring:
  %sbyte = call i64 @ev_utf8offset(ptr %data, i64 %bytes, i64 %start)
  %ebyte = call i64 @ev_utf8offset(ptr %data, i64 %bytes, i64 %end)
  %blen = sub i64 %ebyte, %sbyte
  %subdata = getelementptr i8, ptr %data, i64 %sbyte
  %slicedstring = call ptr @j_str(ptr %subdata, i64 %blen)
  ret ptr %slicedstring
subarray:
  %out = call ptr @j_array()
  br label %loop
loop:
  %i = phi i64 [%start, %subarray], [%next, %body]
  %more = icmp slt i64 %i, %end
  br i1 %more, label %body, label %done
body:
  %v = call ptr @j_at(ptr %value, i64 %i)
  call void @j_push(ptr %out, ptr %v)
  %next = add i64 %i, 1
  br label %loop
done:
  ret ptr %out
}

@ev_break_name = internal global ptr null
@ev_invalid_path_value = internal global ptr null
@ev_invalid_path_detailed = internal global i1 false

define ptr @j_eval(ptr %node, ptr %input, ptr %env) {
entry:
  %out = call ptr @j_array()
  %noast = icmp eq ptr %node, null
  %error = load ptr, ptr @j_error
  %haserror = icmp ne ptr %error, null
  %breaking = load ptr, ptr @ev_break_name
  %hasbreak = icmp ne ptr %breaking, null
  %stop0 = or i1 %noast, %haserror
  %stop = or i1 %stop0, %hasbreak
  br i1 %stop, label %done, label %dispatch
dispatch:
  %kind = load i32, ptr %node
  %op.p = getelementptr %N, ptr %node, i32 0, i32 1
  %op = load i32, ptr %op.p
  %ap = getelementptr %N, ptr %node, i32 0, i32 2
  %a = load ptr, ptr %ap
  %bp = getelementptr %N, ptr %node, i32 0, i32 3
  %b = load ptr, ptr %bp
  %cp = getelementptr %N, ptr %node, i32 0, i32 4
  %c = load ptr, ptr %cp
  %dp = getelementptr %N, ptr %node, i32 0, i32 5
  %d = load ptr, ptr %dp
  switch i32 %kind, label %done [i32 0, label %literal i32 1, label %identity i32 2, label %pipe i32 3, label %comma i32 4, label %binary i32 5, label %field i32 6, label %iterate i32 7, label %call i32 8, label %array i32 9, label %object i32 10, label %variable i32 11, label %binding i32 12, label %definition i32 13, label %conditional i32 14, label %try i32 15, label %negative i32 16, label %optional i32 17, label %recursive i32 18, label %reduce i32 19, label %assignment i32 20, label %slice i32 21, label %alternative i32 22, label %label i32 23, label %break i32 24, label %import i32 25, label %module]
literal:
  call void @j_push(ptr %out, ptr %a)
  br label %done
identity:
  call void @j_push(ptr %out, ptr %input)
  br label %done
pipe:
  %pipe.left = call ptr @j_eval(ptr %a, ptr %input, ptr %env)
  %pipe.pending = load ptr, ptr @j_error
  store ptr null, ptr @j_error
  %pipe.n = call i64 @ev_len(ptr %pipe.left)
  br label %pipeloop
pipeloop:
  %pi = phi i64 [0, %pipe], [%pinext, %pipebody]
  %pmore = icmp ult i64 %pi, %pipe.n
  br i1 %pmore, label %pipebody, label %pipefinish
pipebody:
  %pv = call ptr @j_at(ptr %pipe.left, i64 %pi)
  %pr = call ptr @j_eval(ptr %b, ptr %pv, ptr %env)
  call void @ev_extend(ptr %out, ptr %pr)
  %pinext = add i64 %pi, 1
  br label %pipeloop
pipefinish:
  %pipe.error = load ptr, ptr @j_error
  %pipe.clear = icmp eq ptr %pipe.error, null
  %pipe.finalerror = select i1 %pipe.clear, ptr %pipe.pending, ptr %pipe.error
  store ptr %pipe.finalerror, ptr @j_error
  br label %done
comma:
  %comma.left = call ptr @j_eval(ptr %a, ptr %input, ptr %env)
  call void @ev_extend(ptr %out, ptr %comma.left)
  %comma.right = call ptr @j_eval(ptr %b, ptr %input, ptr %env)
  call void @ev_extend(ptr %out, ptr %comma.right)
  br label %done
binary:
  %logical = icmp uge i32 %op, 11
  %outerast = select i1 %logical, ptr %a, ptr %b
  %innerast = select i1 %logical, ptr %b, ptr %a
  %bin.left = call ptr @j_eval(ptr %outerast, ptr %input, ptr %env)
  %bin.n = call i64 @ev_len(ptr %bin.left)
  br label %binleftloop
binleftloop:
  %bi = phi i64 [0, %binary], [%binext, %binleftnext]
  %bmore = icmp ult i64 %bi, %bin.n
  br i1 %bmore, label %binleftbody, label %done
binleftbody:
  %bl = call ptr @j_at(ptr %bin.left, i64 %bi)
  br i1 %logical, label %logiccheck, label %binright
logiccheck:
  %truth = call i1 @j_truth(ptr %bl)
  %isand = icmp eq i32 %op, 11
  %short = xor i1 %truth, %isand
  br i1 %short, label %logicshort, label %binright
logicshort:
  %shortval = call ptr @j_bool(i1 %truth)
  call void @j_push(ptr %out, ptr %shortval)
  br label %binleftnext
binright:
  %bin.right = call ptr @j_eval(ptr %innerast, ptr %input, ptr %env)
  %bin.m = call i64 @ev_len(ptr %bin.right)
  br label %binrightloop
binrightloop:
  %bj = phi i64 [0, %binright], [%bjnext, %binrightbody]
  %bjmore = icmp ult i64 %bj, %bin.m
  br i1 %bjmore, label %binrightbody, label %binleftnext
binrightbody:
  %br = call ptr @j_at(ptr %bin.right, i64 %bj)
  %actualleft = select i1 %logical, ptr %bl, ptr %br
  %actualright = select i1 %logical, ptr %br, ptr %bl
  %binval = call ptr @j_binary(i32 %op, ptr %actualleft, ptr %actualright)
  call void @ev_pushvalid(ptr %out, ptr %binval)
  %bjnext = add i64 %bj, 1
  br label %binrightloop
binleftnext:
  %binext = add i64 %bi, 1
  br label %binleftloop
field:
  %field.left = call ptr @j_eval(ptr %a, ptr %input, ptr %env)
  %field.keys = call ptr @j_eval(ptr %b, ptr %input, ptr %env)
  %field.n = call i64 @ev_len(ptr %field.left)
  %field.m = call i64 @ev_len(ptr %field.keys)
  br label %fieldloop
fieldloop:
  %fi = phi i64 [0, %field], [%finext, %fieldnext]
  %fmore = icmp ult i64 %fi, %field.n
  br i1 %fmore, label %fieldbody, label %done
fieldbody:
  %fv = call ptr @j_at(ptr %field.left, i64 %fi)
  br label %keyloop
keyloop:
  %ki = phi i64 [0, %fieldbody], [%kinext, %keybody]
  %kmore = icmp ult i64 %ki, %field.m
  br i1 %kmore, label %keybody, label %fieldnext
keybody:
  %fk = call ptr @j_at(ptr %field.keys, i64 %ki)
  %get = call ptr @j_get(ptr %fv, ptr %fk)
  call void @ev_pushvalid(ptr %out, ptr %get)
  %kinext = add i64 %ki, 1
  br label %keyloop
fieldnext:
  %finext = add i64 %fi, 1
  br label %fieldloop
iterate:
  %iter.values = call ptr @j_eval(ptr %a, ptr %input, ptr %env)
  %iter.n = call i64 @ev_len(ptr %iter.values)
  br label %iterloop
iterloop:
  %ii = phi i64 [0, %iterate], [%iinext, %iternext]
  %imore = icmp ult i64 %ii, %iter.n
  br i1 %imore, label %iterbody, label %done
iterbody:
  %iv = call ptr @j_at(ptr %iter.values, i64 %ii)
  %itag = load i32, ptr %iv
  %iarray = icmp eq i32 %itag, 5
  %iobject = icmp eq i32 %itag, 6
  %ivalid = or i1 %iarray, %iobject
  br i1 %ivalid, label %iterelements, label %itererror
itererror:
  call void @ev_itererror(ptr %iv)
  br label %done
iterelements:
  %ien = call i64 @ev_len(ptr %iv)
  %iedp = getelementptr %V, ptr %iv, i32 0, i32 5
  %ied = load ptr, ptr %iedp
  br label %iterelementloop
iterelementloop:
  %ij = phi i64 [0, %iterelements], [%ijnext, %iterelementbody]
  %ijmore = icmp ult i64 %ij, %ien
  br i1 %ijmore, label %iterelementbody, label %iternext
iterelementbody:
  %itwice = mul i64 %ij, 2
  %iobjidx = add i64 %itwice, 1
  %ieidx = select i1 %iobject, i64 %iobjidx, i64 %ij
  %iep = getelementptr ptr, ptr %ied, i64 %ieidx
  %iev = load ptr, ptr %iep
  call void @j_push(ptr %out, ptr %iev)
  %ijnext = add i64 %ij, 1
  br label %iterelementloop
iternext:
  %iinext = add i64 %ii, 1
  br label %iterloop
call:
  %arity = call i64 @ev_len(ptr %b)
  %function = call ptr @ev_lookup(ptr %env, ptr %a, i32 1, i64 %arity)
  %foundfunction = icmp ne ptr %function, null
  br i1 %foundfunction, label %usercall, label %filterlookup
usercall:
  %bodyp = getelementptr %E, ptr %function, i32 0, i32 2
  %body = load ptr, ptr %bodyp
  %paramsp = getelementptr %E, ptr %function, i32 0, i32 4
  %params = load ptr, ptr %paramsp
  %defenvp = getelementptr %E, ptr %function, i32 0, i32 5
  %defenv = load ptr, ptr %defenvp
  %userresult = call ptr @ev_callargs(ptr %body, ptr %params, ptr %b, i64 0, ptr %input, ptr %env, ptr %defenv)
  ret ptr %userresult
filterlookup:
  %filter = call ptr @ev_lookup(ptr %env, ptr %a, i32 2, i64 0)
  %foundfilter = icmp ne ptr %filter, null
  br i1 %foundfilter, label %filtercall, label %specialcheck
filtercall:
  %filterp = getelementptr %E, ptr %filter, i32 0, i32 2
  %filterast = load ptr, ptr %filterp
  %filterenvp = getelementptr %E, ptr %filter, i32 0, i32 5
  %filterenv = load ptr, ptr %filterenvp
  %filterresult = call ptr @j_eval(ptr %filterast, ptr %input, ptr %filterenv)
  ret ptr %filterresult
specialcheck:
  %ismeta = call i1 @j_is(ptr %a, ptr @ev_modulemeta)
  br i1 %ismeta, label %metacall, label %pathcheck
metacall:
  %metavalue = call ptr @ev_modulemetadata(ptr %input)
  call void @j_push(ptr %out, ptr %metavalue)
  br label %done
pathcheck:
  %ispick = call i1 @j_is(ptr %a, ptr @ev_pick)
  br i1 %ispick, label %pickcall, label %pathcheck2
pickcall:
  store ptr null, ptr @ev_invalid_path_value
  store i1 false, ptr @ev_invalid_path_detailed
  %picked = call ptr @j_pick(ptr %b, ptr %input, ptr %env)
  ret ptr %picked
pathcheck2:
  %ispath = call i1 @j_is(ptr %a, ptr @ev_path)
  %isdel = call i1 @j_is(ptr %a, ptr @ev_del)
  %special = or i1 %ispath, %isdel
  br i1 %special, label %specialcall, label %builtincall
specialcall:
  store ptr null, ptr @ev_invalid_path_value
  store i1 false, ptr @ev_invalid_path_detailed
  %patharg = call ptr @j_at(ptr %b, i64 0)
  %paths = call ptr @ev_paths(ptr %patharg, ptr %input, ptr %env)
  br i1 %ispath, label %pathdone, label %delcall
pathdone:
  ret ptr %paths
delcall:
  %deleted = call ptr @ev_deletepaths(ptr %input, ptr %paths)
  call void @ev_pushvalid(ptr %out, ptr %deleted)
  br label %done
builtincall:
  %builtinresult = call ptr @j_builtin(ptr %a, ptr %b, ptr %input, ptr %env)
  %known = icmp ne ptr %builtinresult, null
  br i1 %known, label %builtindone, label %unknown
builtindone:
  ret ptr %builtinresult
unknown:
  call void @j_fail(ptr @ev_undefined)
  br label %done
array:
  %elements = call ptr @j_eval(ptr %a, ptr %input, ptr %env)
  call void @ev_pushvalid(ptr %out, ptr %elements)
  br label %done
object:
  %newobject = call ptr @j_object()
  %objects = call ptr @ev_objectbuild(ptr %a, i64 0, ptr %newobject, ptr %input, ptr %env)
  ret ptr %objects
variable:
  %var = call ptr @ev_lookup(ptr %env, ptr %a, i32 0, i64 0)
  %hasvar = icmp ne ptr %var, null
  br i1 %hasvar, label %varvalue, label %varerror
varvalue:
  %varp = getelementptr %E, ptr %var, i32 0, i32 2
  %varval = load ptr, ptr %varp
  call void @j_push(ptr %out, ptr %varval)
  br label %done
varerror:
  %islocation = call i1 @j_is(ptr %a, ptr @ev_locname)
  br i1 %islocation, label %varlocation, label %varundefined
varlocation:
  %haslocation = icmp ne ptr %b, null
  br i1 %haslocation, label %varlocationready, label %varlocationdefault
varlocationdefault:
  %defaultlocation = call ptr @ev_location(ptr null)
  br label %varlocationready
varlocationready:
  %locationvalue = phi ptr [%b, %varlocation], [%defaultlocation, %varlocationdefault]
  call void @j_push(ptr %out, ptr %locationvalue)
  br label %done
varundefined:
  call void @j_fail(ptr @ev_variable)
  br label %done
binding:
  %bindvals = call ptr @j_eval(ptr %a, ptr %input, ptr %env)
  %bindn = call i64 @ev_len(ptr %bindvals)
  br label %bindloop
bindloop:
  %bindi = phi i64 [0, %binding], [%bindnext, %bindbody]
  %bindmore = icmp ult i64 %bindi, %bindn
  br i1 %bindmore, label %bindbody, label %done
bindbody:
  %bindval = call ptr @j_at(ptr %bindvals, i64 %bindi)
  %bindresult = call ptr @ev_bind_eval(ptr %env, ptr %b, ptr %bindval, ptr %input, ptr %c)
  call void @ev_extend(ptr %out, ptr %bindresult)
  %bindnext = add i64 %bindi, 1
  br label %bindloop
definition:
  %de = call ptr @j_bind(ptr %env, ptr %a, ptr %c)
  %dtp = getelementptr %E, ptr %de, i32 0, i32 3
  store i32 1, ptr %dtp
  %dpp = getelementptr %E, ptr %de, i32 0, i32 4
  store ptr %b, ptr %dpp
  %dep = getelementptr %E, ptr %de, i32 0, i32 5
  store ptr %de, ptr %dep
  %defined = call ptr @j_eval(ptr %d, ptr %input, ptr %de)
  ret ptr %defined
conditional:
  %conditions = call ptr @j_eval(ptr %a, ptr %input, ptr %env)
  %condn = call i64 @ev_len(ptr %conditions)
  br label %condloop
condloop:
  %ci = phi i64 [0, %conditional], [%cinext, %condbody]
  %cmore = icmp ult i64 %ci, %condn
  br i1 %cmore, label %condbody, label %done
condbody:
  %cv = call ptr @j_at(ptr %conditions, i64 %ci)
  %ct = call i1 @j_truth(ptr %cv)
  %branch = select i1 %ct, ptr %b, ptr %c
  %cr = call ptr @j_eval(ptr %branch, ptr %input, ptr %env)
  call void @ev_extend(ptr %out, ptr %cr)
  %cinext = add i64 %ci, 1
  br label %condloop
try:
  %tried = call ptr @j_eval(ptr %a, ptr %input, ptr %env)
  %caught = load ptr, ptr @j_error
  %failed = icmp ne ptr %caught, null
  br i1 %failed, label %catcherror, label %trysuccess
catcherror:
  store ptr null, ptr @j_error
  call void @ev_extend(ptr %out, ptr %tried)
  %hashandler = icmp ne ptr %b, null
  br i1 %hashandler, label %catchhandler, label %done
catchhandler:
  %handled = call ptr @j_eval(ptr %b, ptr %caught, ptr %env)
  call void @ev_extend(ptr %out, ptr %handled)
  br label %done
trysuccess:
  ret ptr %tried
optional:
  %optionalval = call ptr @j_eval(ptr %a, ptr %input, ptr %env)
  store ptr null, ptr @j_error
  ret ptr %optionalval
negative:
  %negvals = call ptr @j_eval(ptr %a, ptr %input, ptr %env)
  %negn = call i64 @ev_len(ptr %negvals)
  br label %negloop
negloop:
  %ni = phi i64 [0, %negative], [%ninext, %negbody]
  %nmore = icmp ult i64 %ni, %negn
  br i1 %nmore, label %negbody, label %done
negbody:
  %nv = call ptr @j_at(ptr %negvals, i64 %ni)
  %negated = call ptr @j_negate(ptr %nv)
  call void @ev_pushvalid(ptr %out, ptr %negated)
  %ninext = add i64 %ni, 1
  br label %negloop
recursive:
  call void @ev_recursive(ptr %input, ptr %out)
  br label %done
reduce:
  %redvalues = call ptr @j_eval(ptr %a, ptr %input, ptr %env)
  %redstates = call ptr @j_eval(ptr %c, ptr %input, ptr %env)
  %redn = call i64 @ev_len(ptr %redvalues)
  %redextractp = getelementptr %N, ptr %node, i32 0, i32 6
  %redextract = load ptr, ptr %redextractp
  %foreach = icmp eq i32 %op, 280
  %initialcount = call i64 @ev_len(ptr %redstates)
  %manyinitial = icmp ugt i64 %initialcount, 1
  br i1 %manyinitial, label %initialloop, label %reduceone
initialloop:
  %initialindex = phi i64 [0, %reduce], [%initialnext, %initialbody]
  %initialmore = icmp ult i64 %initialindex, %initialcount
  br i1 %initialmore, label %initialbody, label %done
initialbody:
  %initialvalue = call ptr @j_at(ptr %redstates, i64 %initialindex)
  %initialnode = call ptr @ev_node(i32 0, i32 0, ptr %initialvalue, ptr null, ptr null, ptr null)
  %singleloop = call ptr @ev_node(i32 18, i32 %op, ptr %a, ptr %b, ptr %initialnode, ptr %d)
  %singleextractp = getelementptr %N, ptr %singleloop, i32 0, i32 6
  store ptr %redextract, ptr %singleextractp
  %initialresults = call ptr @j_eval(ptr %singleloop, ptr %input, ptr %env)
  call void @ev_extend(ptr %out, ptr %initialresults)
  %initialnext = add i64 %initialindex, 1
  br label %initialloop
reduceone:
  br label %redloop
redloop:
  %ri = phi i64 [0, %reduceone], [%rinext, %redstepdone]
  %states = phi ptr [%redstates, %reduceone], [%newstates, %redstepdone]
  %rmore = icmp ult i64 %ri, %redn
  br i1 %rmore, label %redstep, label %redfinish
redstep:
  %rv = call ptr @j_at(ptr %redvalues, i64 %ri)
  %re = call ptr @ev_bindpattern(ptr %env, ptr %b, ptr %rv, ptr %input)
  %newstates = call ptr @j_array()
  %sn = call i64 @ev_len(ptr %states)
  br label %stateloop
stateloop:
  %si = phi i64 [0, %redstep], [%sinext, %statebody]
  %smore = icmp ult i64 %si, %sn
  br i1 %smore, label %statebody, label %redoutput
statebody:
  %sv = call ptr @j_at(ptr %states, i64 %si)
  %updatedstates = call ptr @j_eval(ptr %d, ptr %sv, ptr %re)
  call void @ev_extend(ptr %newstates, ptr %updatedstates)
  %sinext = add i64 %si, 1
  br label %stateloop
redoutput:
  br i1 %foreach, label %extractstart, label %redstepdone
extractstart:
  %extractn = call i64 @ev_len(ptr %newstates)
  %hasextract = icmp ne ptr %redextract, null
  br label %extractloop
extractloop:
  %xi = phi i64 [0, %extractstart], [%xinext, %extractdone]
  %xmore = icmp ult i64 %xi, %extractn
  br i1 %xmore, label %extractbody, label %redstepdone
extractbody:
  %xv = call ptr @j_at(ptr %newstates, i64 %xi)
  br i1 %hasextract, label %extracteval, label %extractidentity
extracteval:
  %xr = call ptr @j_eval(ptr %redextract, ptr %xv, ptr %re)
  call void @ev_extend(ptr %out, ptr %xr)
  br label %extractdone
extractidentity:
  call void @j_push(ptr %out, ptr %xv)
  br label %extractdone
extractdone:
  %xinext = add i64 %xi, 1
  br label %extractloop
redstepdone:
  %rinext = add i64 %ri, 1
  br label %redloop
redfinish:
  br i1 %foreach, label %done, label %reduceoutput
reduceoutput:
  call void @ev_extend(ptr %out, ptr %states)
  br label %done
assignment:
  %assigned = call ptr @ev_assignment(ptr %a, ptr %b, i32 %op, ptr %input, ptr %env)
  ret ptr %assigned
slice:
  %slicebases = call ptr @j_eval(ptr %a, ptr %input, ptr %env)
  %slicen = call i64 @ev_len(ptr %slicebases)
  %slicestarts = call ptr @ev_boundvals(ptr %b, ptr %input, ptr %env)
  %sliceends = call ptr @ev_boundvals(ptr %c, ptr %input, ptr %env)
  %slicens = call i64 @ev_len(ptr %slicestarts)
  %slicene = call i64 @ev_len(ptr %sliceends)
  br label %sliceloop
sliceloop:
  %sli = phi i64 [0, %slice], [%slinext, %slicenext]
  %slmore = icmp ult i64 %sli, %slicen
  br i1 %slmore, label %slicebody, label %done
slicebody:
  %slv = call ptr @j_at(ptr %slicebases, i64 %sli)
  br label %slicestartloop
slicestartloop:
  %sls = phi i64 [0, %slicebody], [%slsnext, %slicestartnext]
  %slsmore = icmp ult i64 %sls, %slicens
  br i1 %slsmore, label %slicestartbody, label %slicenext
slicestartbody:
  %slsv = call ptr @j_at(ptr %slicestarts, i64 %sls)
  br label %sliceendloop
sliceendloop:
  %sle = phi i64 [0, %slicestartbody], [%slenext, %sliceendbody]
  %slemore = icmp ult i64 %sle, %slicene
  br i1 %slemore, label %sliceendbody, label %slicestartnext
sliceendbody:
  %slev = call ptr @j_at(ptr %sliceends, i64 %sle)
  %slr = call ptr @ev_slice(ptr %slv, ptr %slsv, ptr %slev)
  call void @ev_pushvalid(ptr %out, ptr %slr)
  %slenext = add i64 %sle, 1
  br label %sliceendloop
slicestartnext:
  %slsnext = add i64 %sls, 1
  br label %slicestartloop
slicenext:
  %slinext = add i64 %sli, 1
  br label %sliceloop
alternative:
  %alternatives = call ptr @j_eval(ptr %a, ptr %input, ptr %env)
  %altn = call i64 @ev_len(ptr %alternatives)
  br label %altloop
altloop:
  %ai = phi i64 [0, %alternative], [%ainext, %altnext]
  %amore = icmp ult i64 %ai, %altn
  br i1 %amore, label %altbody, label %altfinish
altbody:
  %av = call ptr @j_at(ptr %alternatives, i64 %ai)
  %at = call i1 @j_truth(ptr %av)
  br i1 %at, label %altkeep, label %altnext
altkeep:
  call void @j_push(ptr %out, ptr %av)
  br label %altnext
altnext:
  %ainext = add i64 %ai, 1
  br label %altloop
altfinish:
  %altcount = call i64 @ev_len(ptr %out)
  %altmissing = icmp eq i64 %altcount, 0
  br i1 %altmissing, label %altfallback, label %done
altfallback:
  %fallback = call ptr @j_eval(ptr %b, ptr %input, ptr %env)
  ret ptr %fallback
label:
  %labelresult = call ptr @j_eval(ptr %b, ptr %input, ptr %env)
  %breakname = load ptr, ptr @ev_break_name
  %hasbreakname = icmp ne ptr %breakname, null
  br i1 %hasbreakname, label %labelcompare, label %labeldone
labelcompare:
  %labelcmp = call i32 @j_cmp(ptr %a, ptr %breakname)
  %labelmatch = icmp eq i32 %labelcmp, 0
  br i1 %labelmatch, label %labelclear, label %labeldone
labelclear:
  store ptr null, ptr @ev_break_name
  br label %labeldone
labeldone:
  ret ptr %labelresult
break:
  store ptr %a, ptr @ev_break_name
  br label %done
import:
  %importdir = load ptr, ptr @ev_module_directory
  %importenv = call ptr @ev_importenv(ptr %node, ptr %env, ptr %importdir)
  %importresult = call ptr @j_eval(ptr %c, ptr %input, ptr %importenv)
  ret ptr %importresult
module:
  %moduleresult = call ptr @j_eval(ptr %b, ptr %input, ptr %env)
  ret ptr %moduleresult
done:
  ret ptr %out
}

define internal ptr @ev_boundvals(ptr %node, ptr %input, ptr %env) {
entry:
  %absent = icmp eq ptr %node, null
  br i1 %absent, label %none, label %eval
none:
  %null = call ptr @j_null()
  %singleton = call ptr @ev_one(ptr %null)
  ret ptr %singleton
eval:
  %r = call ptr @j_eval(ptr %node, ptr %input, ptr %env)
  ret ptr %r
}

define internal void @ev_pushvalid(ptr %out, ptr %value) {
entry:
  %error = load ptr, ptr @j_error
  %valid = icmp eq ptr %error, null
  br i1 %valid, label %push, label %done
push:
  call void @j_push(ptr %out, ptr %value)
  br label %done
done:
  ret void
}

define ptr @j_eval_take(ptr %node, ptr %input, ptr %env, i64 %count) {
entry:
  %out = call ptr @j_array()
  %empty = icmp eq i64 %count, 0
  %none = icmp eq ptr %node, null
  %stop = or i1 %empty, %none
  br i1 %stop, label %done, label %dispatch
dispatch:
  %kind = load i32, ptr %node
  %ap = getelementptr %N, ptr %node, i32 0, i32 2
  %a = load ptr, ptr %ap
  %bp = getelementptr %N, ptr %node, i32 0, i32 3
  %b = load ptr, ptr %bp
  switch i32 %kind, label %fallback [i32 3, label %comma i32 2, label %pipe i32 7, label %boundedcall]
boundedcall:
  %arity = call i64 @ev_len(ptr %b)
  %definition = call ptr @ev_lookup(ptr %env, ptr %a, i32 1, i64 %arity)
  %filter = call ptr @ev_lookup(ptr %env, ptr %a, i32 2, i64 0)
  %hasdefinition = icmp ne ptr %definition, null
  %hasfilter = icmp ne ptr %filter, null
  %lexical = or i1 %hasdefinition, %hasfilter
  br i1 %lexical, label %fallback, label %boundedbuiltin
boundedbuiltin:
  %bounded = call ptr @j_builtin_take(ptr %a, ptr %b, ptr %input, ptr %env, i64 %count)
  %supported = icmp ne ptr %bounded, null
  br i1 %supported, label %boundeddone, label %fallback
boundeddone:
  ret ptr %bounded
comma:
  %left = call ptr @j_eval_take(ptr %a, ptr %input, ptr %env, i64 %count)
  call void @ev_extend(ptr %out, ptr %left)
  %n = call i64 @ev_len(ptr %left)
  %filled = icmp uge i64 %n, %count
  %error = load ptr, ptr @j_error
  %failed = icmp ne ptr %error, null
  %finished = or i1 %filled, %failed
  br i1 %finished, label %done, label %right
right:
  %remaining = sub i64 %count, %n
  %rhs = call ptr @j_eval_take(ptr %b, ptr %input, ptr %env, i64 %remaining)
  call void @ev_extend(ptr %out, ptr %rhs)
  br label %done
pipe:
  %sources = call ptr @j_eval(ptr %a, ptr %input, ptr %env)
  %pending = load ptr, ptr @j_error
  store ptr null, ptr @j_error
  %pn = call i64 @ev_len(ptr %sources)
  br label %pipeloop
pipeloop:
  %pi = phi i64 [0, %pipe], [%pinext, %pipebody]
  %produced = call i64 @ev_len(ptr %out)
  %full = icmp uge i64 %produced, %count
  %pipeerror = load ptr, ptr @j_error
  %pipefailed = icmp ne ptr %pipeerror, null
  %pipestop = or i1 %full, %pipefailed
  br i1 %pipestop, label %done, label %pipecheck
pipecheck:
  %pmore = icmp ult i64 %pi, %pn
  br i1 %pmore, label %pipebody, label %pipeend
pipebody:
  %value = call ptr @j_at(ptr %sources, i64 %pi)
  %need = sub i64 %count, %produced
  %part = call ptr @j_eval_take(ptr %b, ptr %value, ptr %env, i64 %need)
  call void @ev_extend(ptr %out, ptr %part)
  %pinext = add i64 %pi, 1
  br label %pipeloop
pipeend:
  store ptr %pending, ptr @j_error
  br label %done
fallback:
  %all = call ptr @j_eval(ptr %node, ptr %input, ptr %env)
  %alln = call i64 @ev_len(ptr %all)
  %enough = icmp uge i64 %alln, %count
  %take = select i1 %enough, i64 %count, i64 %alln
  br i1 %enough, label %satisfied, label %copybegin
satisfied:
  store ptr null, ptr @j_error
  br label %copybegin
copybegin:
  br label %copyloop
copyloop:
  %i = phi i64 [0, %copybegin], [%next, %copybody]
  %more = icmp ult i64 %i, %take
  br i1 %more, label %copybody, label %done
copybody:
  %v = call ptr @j_at(ptr %all, i64 %i)
  call void @j_push(ptr %out, ptr %v)
  %next = add i64 %i, 1
  br label %copyloop
done:
  ret ptr %out
}

define internal ptr @ev_location(ptr %parser) {
entry:
  %none = icmp eq ptr %parser, null
  br i1 %none, label %done, label %start
start:
  %source = load ptr, ptr %parser
  %pp = getelementptr %P, ptr %parser, i32 0, i32 2
  %pos = load i64, ptr %pp
  br label %loop
loop:
  %i = phi i64 [0, %start], [%next, %body]
  %line = phi i64 [1, %start], [%nextline, %body]
  %more = icmp ult i64 %i, %pos
  br i1 %more, label %body, label %done
body:
  %p = getelementptr i8, ptr %source, i64 %i
  %c = load i8, ptr %p
  %newline = icmp eq i8 %c, 10
  %inc = zext i1 %newline to i64
  %nextline = add i64 %line, %inc
  %next = add i64 %i, 1
  br label %loop
done:
  %number = phi i64 [1, %entry], [%line, %loop]
  %num = uitofp i64 %number to double
  %lineno = call ptr @j_num(double %num)
  %location = call ptr @j_object()
  %filename = call ptr @j_cstr(ptr @ev_topfile)
  %filekey = call ptr @j_cstr(ptr @ev_filekey)
  %linekey = call ptr @j_cstr(ptr @ev_linekey)
  call void @j_put(ptr %location, ptr %filekey, ptr %filename)
  call void @j_put(ptr %location, ptr %linekey, ptr %lineno)
  ret ptr %location
}

define internal i1 @ev_fieldadjacent(ptr %parser, i64 %position) {
entry:
  %source = load ptr, ptr %parser
  %lp = getelementptr %P, ptr %parser, i32 0, i32 1
  %length = load i64, ptr %lp
  %inside = icmp ult i64 %position, %length
  br i1 %inside, label %read, label %no
read:
  %p = getelementptr i8, ptr %source, i64 %position
  %c = load i8, ptr %p
  %name = call i1 @ev_ident(i8 %c)
  %quote = icmp eq i8 %c, 34
  %adjacent = or i1 %name, %quote
  ret i1 %adjacent
no:
  ret i1 false
}

define internal i1 @ev_commentcontinuation(ptr %source, i64 %start, i64 %newline) {
entry:
  %hasprev = icmp ugt i64 %newline, %start
  br i1 %hasprev, label %last, label %no
last:
  %prev = sub i64 %newline, 1
  %p = getelementptr i8, ptr %source, i64 %prev
  %c = load i8, ptr %p
  %cr = icmp eq i8 %c, 13
  %end = select i1 %cr, i64 %prev, i64 %newline
  br label %loop
loop:
  %i = phi i64 [%end, %last], [%next, %advance]
  %odd = phi i1 [false, %last], [%toggled, %advance]
  %more = icmp ugt i64 %i, %start
  br i1 %more, label %body, label %done
body:
  %next = sub i64 %i, 1
  %bp = getelementptr i8, ptr %source, i64 %next
  %bc = load i8, ptr %bp
  %slash = icmp eq i8 %bc, 92
  br i1 %slash, label %advance, label %done
advance:
  %toggled = xor i1 %odd, true
  br label %loop
done:
  ret i1 %odd
no:
  ret i1 false
}

@ev_iterprefix = private constant [21 x i8] c"Cannot iterate over \00"
@ev_numbertype = private constant [7 x i8] c"number\00"
@ev_stringtype = private constant [7 x i8] c"string\00"
@ev_booleantype = private constant [8 x i8] c"boolean\00"
@ev_nulltype = private constant [5 x i8] c"null\00"
@ev_openparen = private constant [3 x i8] c" (\00"
@ev_closeparen = private constant [2 x i8] c")\00"

define internal void @ev_itererror(ptr %value) {
entry:
  %tag = load i32, ptr %value
  %isnum = icmp eq i32 %tag, 3
  %isstr = icmp eq i32 %tag, 4
  %isnull = icmp eq i32 %tag, 0
  %t1 = select i1 %isnum, ptr @ev_numbertype, ptr @ev_booleantype
  %t2 = select i1 %isstr, ptr @ev_stringtype, ptr %t1
  %t3 = select i1 %isnull, ptr @ev_nulltype, ptr %t2
  %prefix = call ptr @j_cstr(ptr @ev_iterprefix)
  %typename = call ptr @j_cstr(ptr %t3)
  %start = call ptr @j_binary(i32 0, ptr %prefix, ptr %typename)
  %open = call ptr @j_cstr(ptr @ev_openparen)
  %withopen = call ptr @j_binary(i32 0, ptr %start, ptr %open)
  %dump = call ptr @j_dump(ptr %value, i32 0)
  %withvalue = call ptr @j_binary(i32 0, ptr %withopen, ptr %dump)
  %close = call ptr @j_cstr(ptr @ev_closeparen)
  %message = call ptr @j_binary(i32 0, ptr %withvalue, ptr %close)
  store ptr %message, ptr @j_error
  ret void
}

@ev_startkey = private constant [6 x i8] c"start\00"
@ev_endkey = private constant [4 x i8] c"end\00"
@ev_negativeindex = private constant [35 x i8] c"Out of bounds negative array index\00"
@ev_largeindex = private constant [22 x i8] c"Array index too large\00"
@ev_nanindex = private constant [38 x i8] c"Cannot set array element at NaN index\00"
@ev_stringslice = private constant [28 x i8] c"Cannot update string slices\00"

define ptr @ev_fetchpath(ptr %value, ptr %path) {
entry:
  %n = call i64 @ev_len(ptr %path)
  br label %loop
loop:
  %i = phi i64 [0, %entry], [%next, %step]
  %v = phi ptr [%value, %entry], [%child, %step]
  %more = icmp ult i64 %i, %n
  br i1 %more, label %read, label %done
read:
  %key = call ptr @j_at(ptr %path, i64 %i)
  %tag = load i32, ptr %key
  %slice = icmp eq i32 %tag, 6
  br i1 %slice, label %slicepath, label %keypath
slicepath:
  %sk = call ptr @j_cstr(ptr @ev_startkey)
  %ek = call ptr @j_cstr(ptr @ev_endkey)
  %start = call ptr @j_get(ptr %key, ptr %sk)
  %end = call ptr @j_get(ptr %key, ptr %ek)
  %sliced = call ptr @ev_slice(ptr %v, ptr %start, ptr %end)
  br label %step
keypath:
  %got = call ptr @j_get(ptr %v, ptr %key)
  br label %step
step:
  %child = phi ptr [%sliced, %slicepath], [%got, %keypath]
  %next = add i64 %i, 1
  br label %loop
done:
  ret ptr %v
}

define ptr @ev_paths(ptr %node, ptr %input, ptr %env) {
entry:
  %out = call ptr @j_array()
  %noast = icmp eq ptr %node, null
  br i1 %noast, label %done, label %dispatch
dispatch:
  %kind = load i32, ptr %node
  %ap = getelementptr %N, ptr %node, i32 0, i32 2
  %a = load ptr, ptr %ap
  %bp = getelementptr %N, ptr %node, i32 0, i32 3
  %b = load ptr, ptr %bp
  %cp = getelementptr %N, ptr %node, i32 0, i32 4
  %c = load ptr, ptr %cp
  switch i32 %kind, label %filter [i32 1, label %identity i32 2, label %pipe i32 3, label %comma i32 5, label %field i32 6, label %iterate i32 7, label %call i32 11, label %bind i32 13, label %conditional i32 14, label %optional i32 16, label %optional i32 17, label %recursive i32 20, label %slice]
identity:
  %empty = call ptr @j_array()
  call void @j_push(ptr %out, ptr %empty)
  br label %done
comma:
  %left = call ptr @ev_paths(ptr %a, ptr %input, ptr %env)
  call void @ev_extend(ptr %out, ptr %left)
  %right = call ptr @ev_paths(ptr %b, ptr %input, ptr %env)
  call void @ev_extend(ptr %out, ptr %right)
  br label %done
field:
  %bases = call ptr @ev_paths(ptr %a, ptr %input, ptr %env)
  call void @ev_pathcontext(ptr %node, ptr %env)
  %keys = call ptr @j_eval(ptr %b, ptr %input, ptr %env)
  %bn = call i64 @ev_len(ptr %bases)
  %kn = call i64 @ev_len(ptr %keys)
  br label %baseloop
baseloop:
  %bi = phi i64 [0, %field], [%bnext, %basenext]
  %bmore = icmp ult i64 %bi, %bn
  br i1 %bmore, label %basebody, label %done
basebody:
  %base = call ptr @j_at(ptr %bases, i64 %bi)
  br label %keyloop
keyloop:
  %ki = phi i64 [0, %basebody], [%knext, %keybody]
  %kmore = icmp ult i64 %ki, %kn
  br i1 %kmore, label %keybody, label %basenext
keybody:
  %key = call ptr @j_at(ptr %keys, i64 %ki)
  %path = call ptr @j_clone(ptr %base)
  call void @j_push(ptr %path, ptr %key)
  call void @j_push(ptr %out, ptr %path)
  %knext = add i64 %ki, 1
  br label %keyloop
basenext:
  %bnext = add i64 %bi, 1
  br label %baseloop
iterate:
  %ibases = call ptr @ev_paths(ptr %a, ptr %input, ptr %env)
  call void @ev_pathcontext(ptr %node, ptr %env)
  %ibn = call i64 @ev_len(ptr %ibases)
  br label %iterloop
iterloop:
  %ii = phi i64 [0, %iterate], [%inext, %iternext]
  %imore = icmp ult i64 %ii, %ibn
  br i1 %imore, label %iterbody, label %done
iterbody:
  %ibase = call ptr @j_at(ptr %ibases, i64 %ii)
  %iv = call ptr @ev_fetchpath(ptr %input, ptr %ibase)
  %itag = load i32, ptr %iv
  %isarray = icmp eq i32 %itag, 5
  %isobject = icmp eq i32 %itag, 6
  %valid = or i1 %isarray, %isobject
  br i1 %valid, label %elements, label %iterbad
iterbad:
  call void @ev_itererror(ptr %iv)
  br label %done
elements:
  %ilen = call i64 @ev_len(ptr %iv)
  %idp = getelementptr %V, ptr %iv, i32 0, i32 5
  %idata = load ptr, ptr %idp
  br label %elementloop
elementloop:
  %ij = phi i64 [0, %elements], [%ijnext, %elementdone]
  %ijmore = icmp ult i64 %ij, %ilen
  br i1 %ijmore, label %element, label %iternext
element:
  br i1 %isobject, label %objectkey, label %arraykey
objectkey:
  %oidx = mul i64 %ij, 2
  %okp = getelementptr ptr, ptr %idata, i64 %oidx
  %ok = load ptr, ptr %okp
  br label %elementdone
arraykey:
  %number = uitofp i64 %ij to double
  %ak = call ptr @j_num(double %number)
  br label %elementdone
elementdone:
  %ik = phi ptr [%ok, %objectkey], [%ak, %arraykey]
  %ipath = call ptr @j_clone(ptr %ibase)
  call void @j_push(ptr %ipath, ptr %ik)
  call void @j_push(ptr %out, ptr %ipath)
  %ijnext = add i64 %ij, 1
  br label %elementloop
iternext:
  %inext = add i64 %ii, 1
  br label %iterloop
pipe:
  %pbases = call ptr @ev_paths(ptr %a, ptr %input, ptr %env)
  call void @ev_pathcontext(ptr %b, ptr %env)
  %pbn = call i64 @ev_len(ptr %pbases)
  br label %pipeloop
pipeloop:
  %pi = phi i64 [0, %pipe], [%pinext, %pipenext]
  %pmore = icmp ult i64 %pi, %pbn
  br i1 %pmore, label %pipebody, label %done
pipebody:
  %pbase = call ptr @j_at(ptr %pbases, i64 %pi)
  %pv = call ptr @ev_fetchpath(ptr %input, ptr %pbase)
  %subpaths = call ptr @ev_paths(ptr %b, ptr %pv, ptr %env)
  %pn = call i64 @ev_len(ptr %subpaths)
  br label %subloop
subloop:
  %pj = phi i64 [0, %pipebody], [%pjnext, %subbody]
  %pjmore = icmp ult i64 %pj, %pn
  br i1 %pjmore, label %subbody, label %pipenext
subbody:
  %sub = call ptr @j_at(ptr %subpaths, i64 %pj)
  %joined = call ptr @j_clone(ptr %pbase)
  call void @ev_extend(ptr %joined, ptr %sub)
  call void @j_push(ptr %out, ptr %joined)
  %pjnext = add i64 %pj, 1
  br label %subloop
pipenext:
  %pinext = add i64 %pi, 1
  br label %pipeloop
optional:
  %optionalpaths = call ptr @ev_paths(ptr %a, ptr %input, ptr %env)
  %operr = load ptr, ptr @j_error
  %opfailed = icmp ne ptr %operr, null
  store ptr null, ptr @j_error
  br i1 %opfailed, label %done, label %optionaldone
optionaldone:
  ret ptr %optionalpaths
bind:
  %values = call ptr @j_eval(ptr %a, ptr %input, ptr %env)
  %vn = call i64 @ev_len(ptr %values)
  br label %bindloop
bindloop:
  %vi = phi i64 [0, %bind], [%vinext, %bindbody]
  %vmore = icmp ult i64 %vi, %vn
  br i1 %vmore, label %bindbody, label %done
bindbody:
  %val = call ptr @j_at(ptr %values, i64 %vi)
  %bound = call ptr @ev_bindpattern(ptr %env, ptr %b, ptr %val, ptr %input)
  %boundpaths = call ptr @ev_paths(ptr %c, ptr %input, ptr %bound)
  call void @ev_extend(ptr %out, ptr %boundpaths)
  %vinext = add i64 %vi, 1
  br label %bindloop
conditional:
  %conditions = call ptr @j_eval(ptr %a, ptr %input, ptr %env)
  %cn = call i64 @ev_len(ptr %conditions)
  br label %condloop
condloop:
  %ci = phi i64 [0, %conditional], [%cinext, %condbody]
  %cmore = icmp ult i64 %ci, %cn
  br i1 %cmore, label %condbody, label %done
condbody:
  %condval = call ptr @j_at(ptr %conditions, i64 %ci)
  %cond = call i1 @j_truth(ptr %condval)
  %branch = select i1 %cond, ptr %b, ptr %c
  %condpaths = call ptr @ev_paths(ptr %branch, ptr %input, ptr %env)
  call void @ev_extend(ptr %out, ptr %condpaths)
  %cinext = add i64 %ci, 1
  br label %condloop
recursive:
  %root = call ptr @j_array()
  call void @ev_recursivepaths(ptr %input, ptr %root, ptr %out)
  br label %done
call:
  %closure = call ptr @ev_lookup(ptr %env, ptr %a, i32 2, i64 0)
  %hasclosure = icmp ne ptr %closure, null
  br i1 %hasclosure, label %callclosure, label %calldeflookup
callclosure:
  %closureastp = getelementptr %E, ptr %closure, i32 0, i32 2
  %closureast = load ptr, ptr %closureastp
  %closureenvp = getelementptr %E, ptr %closure, i32 0, i32 5
  %closureenv = load ptr, ptr %closureenvp
  %closurepaths = call ptr @ev_paths(ptr %closureast, ptr %input, ptr %closureenv)
  ret ptr %closurepaths
calldeflookup:
  %callarity = call i64 @ev_len(ptr %b)
  %function = call ptr @ev_lookup(ptr %env, ptr %a, i32 1, i64 %callarity)
  %hasfunction = icmp ne ptr %function, null
  br i1 %hasfunction, label %calldef, label %builtinpath
builtinpath:
  %isfirst = call i1 @j_is(ptr %a, ptr @ev_first)
  %islast = call i1 @j_is(ptr %a, ptr @ev_last)
  %isgetpath = call i1 @j_is(ptr %a, ptr @ev_getpath)
  %firstlast = or i1 %isfirst, %islast
  %noargs = icmp eq i64 %callarity, 0
  %indexbuiltin = and i1 %firstlast, %noargs
  br i1 %indexbuiltin, label %indexpath, label %getpathcheck
indexpath:
  %idx = select i1 %islast, double -1.000000e+00, double 0.000000e+00
  %indexvalue = call ptr @j_num(double %idx)
  %indexarray = call ptr @j_array()
  call void @j_push(ptr %indexarray, ptr %indexvalue)
  call void @j_push(ptr %out, ptr %indexarray)
  br label %done
getpathcheck:
  br i1 %isgetpath, label %getpathcall, label %filter
getpathcall:
  %getpatharg = call ptr @j_at(ptr %b, i64 0)
  %getpaths = call ptr @j_eval(ptr %getpatharg, ptr %input, ptr %env)
  ret ptr %getpaths
calldef:
  %callbodyp = getelementptr %E, ptr %function, i32 0, i32 2
  %callbody = load ptr, ptr %callbodyp
  %callparamsp = getelementptr %E, ptr %function, i32 0, i32 4
  %callparams = load ptr, ptr %callparamsp
  %callenvp = getelementptr %E, ptr %function, i32 0, i32 5
  %callenv = load ptr, ptr %callenvp
  %callpaths = call ptr @ev_pathcallargs(ptr %callbody, ptr %callparams, ptr %b, i64 0, ptr %input, ptr %env, ptr %callenv)
  ret ptr %callpaths
slice:
  %sbases = call ptr @ev_paths(ptr %a, ptr %input, ptr %env)
  %starts = call ptr @ev_boundvals(ptr %b, ptr %input, ptr %env)
  %ends = call ptr @ev_boundvals(ptr %c, ptr %input, ptr %env)
  %sbn = call i64 @ev_len(ptr %sbases)
  %ssn = call i64 @ev_len(ptr %starts)
  %sen = call i64 @ev_len(ptr %ends)
  %startkey = call ptr @j_cstr(ptr @ev_startkey)
  %endkey = call ptr @j_cstr(ptr @ev_endkey)
  br label %sliceloop
sliceloop:
  %sbi = phi i64 [0, %slice], [%sbinext, %slicenext]
  %sbmore = icmp ult i64 %sbi, %sbn
  br i1 %sbmore, label %slicebody, label %done
slicebody:
  %sbase = call ptr @j_at(ptr %sbases, i64 %sbi)
  br label %startloop
startloop:
  %ssi = phi i64 [0, %slicebody], [%ssinext, %startnext]
  %ssmore = icmp ult i64 %ssi, %ssn
  br i1 %ssmore, label %startbody, label %slicenext
startbody:
  %sv = call ptr @j_at(ptr %starts, i64 %ssi)
  br label %endloop
endloop:
  %sei = phi i64 [0, %startbody], [%seinext, %endbody]
  %semore = icmp ult i64 %sei, %sen
  br i1 %semore, label %endbody, label %startnext
endbody:
  %ev = call ptr @j_at(ptr %ends, i64 %sei)
  %sk = call ptr @j_object()
  call void @j_put(ptr %sk, ptr %startkey, ptr %sv)
  call void @j_put(ptr %sk, ptr %endkey, ptr %ev)
  %sp = call ptr @j_clone(ptr %sbase)
  call void @j_push(ptr %sp, ptr %sk)
  call void @j_push(ptr %out, ptr %sp)
  %seinext = add i64 %sei, 1
  br label %endloop
startnext:
  %ssinext = add i64 %ssi, 1
  br label %startloop
slicenext:
  %sbinext = add i64 %sbi, 1
  br label %sliceloop
filter:
  %filtered = call ptr @j_eval(ptr %node, ptr %input, ptr %env)
  %fn = call i64 @ev_len(ptr %filtered)
  br label %filterloop
filterloop:
  %fi = phi i64 [0, %filter], [%finext, %filterbodydone]
  %fmore = icmp ult i64 %fi, %fn
  br i1 %fmore, label %filterbody, label %done
filterbody:
  %fvalue = call ptr @j_at(ptr %filtered, i64 %fi)
  %unchanged = icmp eq ptr %fvalue, %input
  br i1 %unchanged, label %filterkeep, label %filterbad
filterkeep:
  %fp = call ptr @j_array()
  call void @j_push(ptr %out, ptr %fp)
  br label %filterbodydone
filterbad:
  call void @ev_invalidpath(ptr %fvalue)
  br label %filterbodydone
filterbodydone:
  %finext = add i64 %fi, 1
  br label %filterloop
done:
  ret ptr %out
}

define internal void @ev_recursivepaths(ptr %value, ptr %path, ptr %out) {
entry:
  call void @j_push(ptr %out, ptr %path)
  %tag = load i32, ptr %value
  %array = icmp eq i32 %tag, 5
  %object = icmp eq i32 %tag, 6
  %container = or i1 %array, %object
  br i1 %container, label %start, label %done
start:
  %n = call i64 @ev_len(ptr %value)
  %dp = getelementptr %V, ptr %value, i32 0, i32 5
  %data = load ptr, ptr %dp
  br label %loop
loop:
  %i = phi i64 [0, %start], [%next, %step]
  %more = icmp ult i64 %i, %n
  br i1 %more, label %body, label %done
body:
  br i1 %object, label %objectkey, label %arraykey
objectkey:
  %oi = mul i64 %i, 2
  %kp = getelementptr ptr, ptr %data, i64 %oi
  %ok = load ptr, ptr %kp
  %ovi = add i64 %oi, 1
  %ovp = getelementptr ptr, ptr %data, i64 %ovi
  %ov = load ptr, ptr %ovp
  br label %step
arraykey:
  %num = uitofp i64 %i to double
  %ak = call ptr @j_num(double %num)
  %av = call ptr @j_at(ptr %value, i64 %i)
  br label %step
step:
  %key = phi ptr [%ok, %objectkey], [%ak, %arraykey]
  %child = phi ptr [%ov, %objectkey], [%av, %arraykey]
  %subpath = call ptr @j_clone(ptr %path)
  call void @j_push(ptr %subpath, ptr %key)
  call void @ev_recursivepaths(ptr %child, ptr %subpath, ptr %out)
  %next = add i64 %i, 1
  br label %loop
done:
  ret void
}

@ev_invalidresult = private constant [37 x i8] c"Invalid path expression with result \00"
@ev_invaliditerate = private constant [57 x i8] c"Invalid path expression near attempt to iterate through \00"
@ev_invalidelement = private constant [56 x i8] c"Invalid path expression near attempt to access element \00"
@ev_pathof = private constant [5 x i8] c" of \00"

define internal void @ev_invalidpath(ptr %value) {
entry:
  %prefix = call ptr @j_cstr(ptr @ev_invalidresult)
  %rendered = call ptr @j_dump(ptr %value, i32 0)
  %message = call ptr @j_binary(i32 0, ptr %prefix, ptr %rendered)
  store ptr %message, ptr @j_error
  store ptr %value, ptr @ev_invalid_path_value
  store i1 false, ptr @ev_invalid_path_detailed
  ret void
}

define internal void @ev_pathcontext(ptr %node, ptr %env) {
entry:
  %value = load ptr, ptr @ev_invalid_path_value
  %none = icmp eq ptr %value, null
  %detailed = load i1, ptr @ev_invalid_path_detailed
  %stop = or i1 %none, %detailed
  br i1 %stop, label %done, label %dispatch
dispatch:
  %kind = load i32, ptr %node
  %ap = getelementptr %N, ptr %node, i32 0, i32 2
  %a = load ptr, ptr %ap
  %bp = getelementptr %N, ptr %node, i32 0, i32 3
  %b = load ptr, ptr %bp
  switch i32 %kind, label %done [i32 2, label %pipe i32 5, label %field i32 6, label %iterate]
pipe:
  call void @ev_pathcontext(ptr %a, ptr %env)
  call void @ev_pathcontext(ptr %b, ptr %env)
  br label %done
field:
  call void @ev_pathcontext(ptr %a, ptr %env)
  %nowdetailed = load i1, ptr @ev_invalid_path_detailed
  br i1 %nowdetailed, label %done, label %fieldkey
fieldkey:
  %saved = load ptr, ptr @j_error
  store ptr null, ptr @j_error
  %keys = call ptr @j_eval(ptr %b, ptr %value, ptr %env)
  %key = call ptr @j_at(ptr %keys, i64 0)
  %keytext = call ptr @j_dump(ptr %key, i32 0)
  %element = call ptr @j_cstr(ptr @ev_invalidelement)
  %withkey = call ptr @j_binary(i32 0, ptr %element, ptr %keytext)
  %of = call ptr @j_cstr(ptr @ev_pathof)
  %fieldprefix = call ptr @j_binary(i32 0, ptr %withkey, ptr %of)
  br label %render
iterate:
  %iterprefix = call ptr @j_cstr(ptr @ev_invaliditerate)
  br label %render
render:
  %prefix = phi ptr [%fieldprefix, %fieldkey], [%iterprefix, %iterate]
  %text = call ptr @j_dump(ptr %value, i32 0)
  %message = call ptr @j_binary(i32 0, ptr %prefix, ptr %text)
  store ptr %message, ptr @j_error
  store i1 true, ptr @ev_invalid_path_detailed
  br label %done
done:
  ret void
}

define ptr @ev_storepath(ptr %value, ptr %path, i64 %level, ptr %replacement) {
entry:
  %n = call i64 @ev_len(ptr %path)
  %endpoint = icmp uge i64 %level, %n
  br i1 %endpoint, label %replace, label %descend
replace:
  ret ptr %replacement
descend:
  %key = call ptr @j_at(ptr %path, i64 %level)
  %kt = load i32, ptr %key
  %vt = load i32, ptr %value
  %vnull = icmp eq i32 %vt, 0
  %nextlevel = add i64 %level, 1
  switch i32 %kt, label %bad [i32 3, label %array i32 4, label %object i32 6, label %slice]
object:
  %vobject = icmp eq i32 %vt, 6
  %ovalid = or i1 %vnull, %vobject
  br i1 %ovalid, label %objectget, label %bad
objectget:
  %old = call ptr @j_get(ptr %value, ptr %key)
  %new = call ptr @ev_storepath(ptr %old, ptr %path, i64 %nextlevel, ptr %replacement)
  %deleted = icmp eq ptr %new, null
  br i1 %deleted, label %objectdelete, label %objectset
objectset:
  br i1 %vnull, label %objectcreate, label %objectcopy
objectcreate:
  %created = call ptr @j_object()
  br label %objectput
objectcopy:
  %copied = call ptr @j_clone(ptr %value)
  br label %objectput
objectput:
  %target = phi ptr [%created, %objectcreate], [%copied, %objectcopy]
  call void @j_put(ptr %target, ptr %key, ptr %new)
  ret ptr %target
objectdelete:
  %odst = call ptr @j_object()
  %on = call i64 @ev_len(ptr %value)
  %odp = getelementptr %V, ptr %value, i32 0, i32 5
  %odata = load ptr, ptr %odp
  br label %objloop
objloop:
  %oi = phi i64 [0, %objectdelete], [%onext, %objnext]
  %omore = icmp ult i64 %oi, %on
  br i1 %omore, label %objbody, label %objdone
objbody:
  %oki = mul i64 %oi, 2
  %okp = getelementptr ptr, ptr %odata, i64 %oki
  %ok = load ptr, ptr %okp
  %ovidx = add i64 %oki, 1
  %ovp = getelementptr ptr, ptr %odata, i64 %ovidx
  %ov = load ptr, ptr %ovp
  %same = call i32 @j_cmp(ptr %ok, ptr %key)
  %remove = icmp eq i32 %same, 0
  br i1 %remove, label %objnext, label %objkeep
objkeep:
  call void @j_put(ptr %odst, ptr %ok, ptr %ov)
  br label %objnext
objnext:
  %onext = add i64 %oi, 1
  br label %objloop
objdone:
  ret ptr %odst
array:
  %varray = icmp eq i32 %vt, 5
  %avalid = or i1 %vnull, %varray
  br i1 %avalid, label %arrayindex, label %bad
arrayindex:
  %an = call i64 @ev_len(ptr %value)
  %keynump = getelementptr %V, ptr %key, i32 0, i32 2
  %keynum = load double, ptr %keynump
  %isnan = fcmp uno double %keynum, %keynum
  br i1 %isnan, label %nanindex, label %arraynumber
nanindex:
  call void @j_fail(ptr @ev_nanindex)
  ret ptr %value
arraynumber:
  %idx0 = call i64 @ev_indexnum(ptr %key, i64 9223372036854775807)
  %negative = icmp slt i64 %idx0, 0
  %relative = add i64 %idx0, %an
  %idx = select i1 %negative, i64 %relative, i64 %idx0
  %under = icmp slt i64 %idx, 0
  br i1 %under, label %negativeindex, label %arraylimit
negativeindex:
  call void @j_fail(ptr @ev_negativeindex)
  ret ptr %value
arraylimit:
  %over = icmp ugt i64 %idx, 16777216
  br i1 %over, label %largeindex, label %arrayget
largeindex:
  call void @j_fail(ptr @ev_largeindex)
  ret ptr %value
arrayget:
  %aold = call ptr @j_at(ptr %value, i64 %idx)
  %anew = call ptr @ev_storepath(ptr %aold, ptr %path, i64 %nextlevel, ptr %replacement)
  %adeleted = icmp eq ptr %anew, null
  %adst = call ptr @j_array()
  %idxnext = add i64 %idx, 1
  %extend = icmp ugt i64 %idxnext, %an
  %setlen = select i1 %extend, i64 %idxnext, i64 %an
  %newlen = select i1 %adeleted, i64 %an, i64 %setlen
  br label %arrloop
arrloop:
  %ai = phi i64 [0, %arrayget], [%ainext, %arrnext]
  %amore = icmp ult i64 %ai, %newlen
  br i1 %amore, label %arrbody, label %arrdone
arrbody:
  %atindex = icmp eq i64 %ai, %idx
  br i1 %atindex, label %arrreplace, label %arrcopy
arrreplace:
  br i1 %adeleted, label %arrnext, label %arrput
arrput:
  call void @j_push(ptr %adst, ptr %anew)
  br label %arrnext
arrcopy:
  %copyval = call ptr @j_at(ptr %value, i64 %ai)
  call void @j_push(ptr %adst, ptr %copyval)
  br label %arrnext
arrnext:
  %ainext = add i64 %ai, 1
  br label %arrloop
arrdone:
  ret ptr %adst
slice:
  %sk = call ptr @j_cstr(ptr @ev_startkey)
  %ek = call ptr @j_cstr(ptr @ev_endkey)
  %slicekeylen = call i64 @ev_len(ptr %key)
  %validslicekey = icmp uge i64 %slicekeylen, 2
  br i1 %validslicekey, label %slicetype, label %bad
slicetype:
  %string = icmp eq i32 %vt, 4
  br i1 %string, label %stringerror, label %sliceread
stringerror:
  call void @j_fail(ptr @ev_stringslice)
  ret ptr %value
sliceread:
  %start = call ptr @j_get(ptr %key, ptr %sk)
  %end = call ptr @j_get(ptr %key, ptr %ek)
  %sliceold = call ptr @ev_slice(ptr %value, ptr %start, ptr %end)
  %slicenew = call ptr @ev_storepath(ptr %sliceold, ptr %path, i64 %nextlevel, ptr %replacement)
  %spliced = call ptr @ev_splice(ptr %value, ptr %start, ptr %end, ptr %slicenew)
  ret ptr %spliced
bad:
  %badlookup = call ptr @j_get(ptr %value, ptr %key)
  %baderror = load ptr, ptr @j_error
  %nogeterror = icmp eq ptr %baderror, null
  br i1 %nogeterror, label %setbaderror, label %badreturn
setbaderror:
  call void @j_fail(ptr @ev_patherror)
  br label %badreturn
badreturn:
  ret ptr %value
}

define internal ptr @ev_splice(ptr %value, ptr %start, ptr %end, ptr %replacement) {
entry:
  %zero = call ptr @j_num(double 0.000000e+00)
  %null = call ptr @j_null()
  %n = call i64 @ev_len(ptr %value)
  %nd = uitofp i64 %n to double
  %nval = call ptr @j_num(double %nd)
  %startidx = call i64 @ev_indexnum(ptr %start, i64 0)
  %endidx = call i64 @ev_endnum(ptr %end, i64 %n)
  %startval = call ptr @j_num(double 0.000000e+00)
  %startnumber = sitofp i64 %startidx to double
  %startnp = getelementptr %V, ptr %startval, i32 0, i32 2
  store double %startnumber, ptr %startnp
  %endnumber = sitofp i64 %endidx to double
  %endval = call ptr @j_num(double %endnumber)
  %prefix = call ptr @ev_slice(ptr %value, ptr %zero, ptr %startval)
  %suffix = call ptr @ev_slice(ptr %value, ptr %endval, ptr %null)
  %deleted = icmp eq ptr %replacement, null
  br i1 %deleted, label %deletion, label %replacing
deletion:
  %joined = call ptr @j_binary(i32 0, ptr %prefix, ptr %suffix)
  ret ptr %joined
replacing:
  %withnew = call ptr @j_binary(i32 0, ptr %prefix, ptr %replacement)
  %result = call ptr @j_binary(i32 0, ptr %withnew, ptr %suffix)
  ret ptr %result
}

define internal ptr @ev_deletepaths(ptr %input, ptr %paths) {
entry:
  %value = call ptr @b_delete_many(ptr %input, ptr %paths)
  ret ptr %value
}

define internal i64 @ev_endnum(ptr %value, i64 %fallback) {
entry:
  %floor = call i64 @ev_indexnum(ptr %value, i64 %fallback)
  %tag = load i32, ptr %value
  %number = icmp eq i32 %tag, 3
  br i1 %number, label %check, label %done
check:
  %np = getelementptr %V, ptr %value, i32 0, i32 2
  %num = load double, ptr %np
  %floornum = sitofp i64 %floor to double
  %fraction = fcmp ogt double %num, %floornum
  %increment = zext i1 %fraction to i64
  %ceil = add i64 %floor, %increment
  ret i64 %ceil
done:
  ret i64 %floor
}

define internal ptr @ev_assignment(ptr %lhs, ptr %rhs, i32 %op, ptr %input, ptr %env) {
entry:
  store ptr null, ptr @ev_invalid_path_value
  store i1 false, ptr @ev_invalid_path_detailed
  %out = call ptr @j_array()
  %paths = call ptr @ev_paths(ptr %lhs, ptr %input, ptr %env)
  %n = call i64 @ev_len(ptr %paths)
  %plain = icmp eq i32 %op, 61
  br i1 %plain, label %plainassign, label %update
plainassign:
  %values = call ptr @j_eval(ptr %rhs, ptr %input, ptr %env)
  %vn = call i64 @ev_len(ptr %values)
  br label %valueloop
valueloop:
  %vi = phi i64 [0, %plainassign], [%vinext, %valuedone]
  %vmore = icmp ult i64 %vi, %vn
  br i1 %vmore, label %valuebody, label %done
valuebody:
  %replacement = call ptr @j_at(ptr %values, i64 %vi)
  br label %pathloop
pathloop:
  %pi = phi i64 [0, %valuebody], [%pinext, %pathbody]
  %value = phi ptr [%input, %valuebody], [%newvalue, %pathbody]
  %pmore = icmp ult i64 %pi, %n
  br i1 %pmore, label %pathbody, label %valuedone
pathbody:
  %path = call ptr @j_at(ptr %paths, i64 %pi)
  %newvalue = call ptr @ev_storepath(ptr %value, ptr %path, i64 0, ptr %replacement)
  %pinext = add i64 %pi, 1
  br label %pathloop
valuedone:
  call void @ev_pushvalid(ptr %out, ptr %value)
  %vinext = add i64 %vi, 1
  br label %valueloop
update:
  %deletedpaths = call ptr @j_array()
  %pureupdate = icmp eq i32 %op, 265
  %alternative = icmp eq i32 %op, 271
  br label %updateloop
updateloop:
  %ui = phi i64 [0, %update], [%uinext, %updatenext]
  %current = phi ptr [%input, %update], [%updated, %updatenext]
  %umore = icmp ult i64 %ui, %n
  br i1 %umore, label %updatebody, label %updatefinish
updatebody:
  %upath = call ptr @j_at(ptr %paths, i64 %ui)
  %old = call ptr @ev_fetchpath(ptr %current, ptr %upath)
  %fetcherror = load ptr, ptr @j_error
  %fetchfailed = icmp ne ptr %fetcherror, null
  br i1 %fetchfailed, label %done, label %updatecheck
updatecheck:
  %oldtruth = call i1 @j_truth(ptr %old)
  %skip = and i1 %alternative, %oldtruth
  br i1 %skip, label %updateskip, label %updateeval
updateskip:
  br label %updatenext
updateeval:
  %rhsinput = select i1 %pureupdate, ptr %old, ptr %input
  %updates = call ptr @j_eval(ptr %rhs, ptr %rhsinput, ptr %env)
  %un = call i64 @ev_len(ptr %updates)
  %empty = icmp eq i64 %un, 0
  br i1 %empty, label %updatedelete, label %updateset
updatedelete:
  call void @j_push(ptr %deletedpaths, ptr %upath)
  br label %updatenext
updateset:
  %first = call ptr @j_at(ptr %updates, i64 0)
  %direct = or i1 %pureupdate, %alternative
  br i1 %direct, label %updatedirect, label %updatearithmetic
updatedirect:
  br label %updateput
updatearithmetic:
  %arithop = sub i32 %op, 266
  %computed = call ptr @j_binary(i32 %arithop, ptr %old, ptr %first)
  br label %updateput
updateput:
  %replacementval = phi ptr [%first, %updatedirect], [%computed, %updatearithmetic]
  %changed = call ptr @ev_storepath(ptr %current, ptr %upath, i64 0, ptr %replacementval)
  br label %updatenext
updatenext:
  %updated = phi ptr [%current, %updateskip], [%current, %updatedelete], [%changed, %updateput]
  %uinext = add i64 %ui, 1
  br label %updateloop
updatefinish:
  %final = call ptr @ev_deletepaths(ptr %current, ptr %deletedpaths)
  call void @ev_pushvalid(ptr %out, ptr %final)
  br label %done
done:
  ret ptr %out
}

@ev_module_directory = internal global ptr null
@ev_module_depth = internal global i64 0
@ev_module_stack = internal global ptr null
@ev_circularimport = private constant [25 x i8] c"circular import detected\00"
@ev_searchkey = private constant [7 x i8] c"search\00"
@ev_slash = private constant [2 x i8] c"/\00"
@ev_namespace = private constant [3 x i8] c"::\00"
@ev_dotdir = private constant [2 x i8] c".\00"
@ev_jqextension = private constant [4 x i8] c".jq\00"
@ev_jsonextension = private constant [6 x i8] c".json\00"
@ev_module_tail = private constant [3 x i8] c"\0A.\00"
@ev_modulenotfound = private constant [18 x i8] c"module not found\00\00"
@ev_moduleconstant = private constant [33 x i8] c"Module metadata must be constant\00"
@ev_importpathconstant = private constant [29 x i8] c"Import path must be constant\00"
@ev_moduleobject = private constant [34 x i8] c"Module metadata must be an object\00"
@ev_modulecycle = private constant [28 x i8] c"Module dependency too deep\00\00"
@ev_depskey = private constant [5 x i8] c"deps\00"
@ev_defskey = private constant [5 x i8] c"defs\00"
@ev_askey = private constant [3 x i8] c"as\00"
@ev_datakey = private constant [8 x i8] c"is_data\00"
@ev_relpathkey = private constant [8 x i8] c"relpath\00"
@ev_keyparentheses = private constant [54 x i8] c"May need parentheses around object key expression\00\00\00\00\00"
@ev_cannotuse = private constant [12 x i8] c"Cannot use \00"
@ev_asobjectkey = private constant [16 x i8] c") as object key\00"
@ev_unexpected_eof = private constant [37 x i8] c"syntax error, unexpected end of file\00"
@ev_unexpected_invalid = private constant [73 x i8] c"syntax error, unexpected INVALID_CHARACTER, expecting end of file\00\00\00\00\00\00\00\00"
@ev_unexpected_prefix = private constant [28 x i8] c"syntax error, unexpected '\00\00"
@ev_quote = private constant [2 x i8] c"'\00"
@ev_expecting_eof = private constant [24 x i8] c", expecting end of file\00"
@ev_invalidescape = private constant [53 x i8] c"Invalid escape at line 1, column 4 (while parsing '\22\00"
@ev_escapeend = private constant [4 x i8] c"\22')\00"

define internal ptr @ev_importconstant(ptr %node) {
entry:
  %existing = load ptr, ptr @j_error
  %already = icmp ne ptr %existing, null
  br i1 %already, label %bad, label %check
check:
  %constant = call i1 @ev_isconstant(ptr %node)
  br i1 %constant, label %good, label %error
error:
  call void @j_fail(ptr @ev_importpathconstant)
  br label %bad
good:
  %value = call ptr @ev_constvalue(ptr %node)
  ret ptr %value
bad:
  %null = call ptr @j_null()
  ret ptr %null
}

define internal void @ev_marksemantic(i64 %start, i64 %end) {
entry:
  %error = load ptr, ptr @j_error
  %set = icmp ne ptr %error, null
  br i1 %set, label %check, label %done
check:
  %mc = call i1 @j_is(ptr %error, ptr @ev_moduleconstant)
  %mo = call i1 @j_is(ptr %error, ptr @ev_moduleobject)
  %ic = call i1 @j_is(ptr %error, ptr @ev_importpathconstant)
  %m = or i1 %mc, %mo
  %semantic = or i1 %m, %ic
  br i1 %semantic, label %mark, label %done
mark:
  store i64 %start, ptr @j_compile_error_start
  store i64 %end, ptr @j_compile_error_end
  br label %done
done:
  ret void
}

define internal void @ev_checkconstkey(ptr %node, i64 %start, i64 %end) {
entry:
  %error = load ptr, ptr @j_error
  %failed = icmp ne ptr %error, null
  br i1 %failed, label %done, label %check
check:
  %constant = call i1 @ev_isconstant(ptr %node)
  br i1 %constant, label %evaluate, label %done
evaluate:
  %value = call ptr @ev_constvalue(ptr %node)
  %tag = load i32, ptr %value
  %string = icmp eq i32 %tag, 4
  br i1 %string, label %done, label %invalid
invalid:
  %isnum = icmp eq i32 %tag, 3
  %isnull = icmp eq i32 %tag, 0
  %type1 = select i1 %isnum, ptr @ev_numbertype, ptr @ev_booleantype
  %type2 = select i1 %isnull, ptr @ev_nulltype, ptr %type1
  %prefix = call ptr @j_cstr(ptr @ev_cannotuse)
  %typename = call ptr @j_cstr(ptr %type2)
  %typed = call ptr @j_binary(i32 0, ptr %prefix, ptr %typename)
  %open = call ptr @j_cstr(ptr @ev_openparen)
  %opened = call ptr @j_binary(i32 0, ptr %typed, ptr %open)
  %rendered = call ptr @j_dump(ptr %value, i32 0)
  %withvalue = call ptr @j_binary(i32 0, ptr %opened, ptr %rendered)
  %suffix = call ptr @j_cstr(ptr @ev_asobjectkey)
  %message = call ptr @j_binary(i32 0, ptr %withvalue, ptr %suffix)
  store ptr %message, ptr @j_error
  store i64 %start, ptr @j_compile_error_start
  store i64 %end, ptr @j_compile_error_end
  br label %done
done:
  ret void
}

define internal void @ev_syntaxerror(i32 %token, i64 %start, i64 %end, i1 %expectend) {
entry:
  %existing = load ptr, ptr @j_error
  %clear = icmp eq ptr %existing, null
  br i1 %clear, label %dispatch, label %done
dispatch:
  switch i32 %token, label %character [i32 0, label %eof i32 125, label %invalid]
eof:
  %nonzero = icmp ugt i64 %start, 0
  %previous = sub i64 %start, 1
  %at = select i1 %nonzero, i64 %previous, i64 0
  %after = add i64 %at, 1
  call void @ev_compileerror(i64 %at, i64 %after, ptr @ev_unexpected_eof)
  br label %done
invalid:
  call void @ev_compileerror(i64 %start, i64 %end, ptr @ev_unexpected_invalid)
  br label %done
character:
  %prefix = call ptr @j_cstr(ptr @ev_unexpected_prefix)
  %byte = alloca i8
  %ch = trunc i32 %token to i8
  store i8 %ch, ptr %byte
  %text = call ptr @j_str(ptr %byte, i64 1)
  %withchar = call ptr @j_binary(i32 0, ptr %prefix, ptr %text)
  %quote = call ptr @j_cstr(ptr @ev_quote)
  %quoted = call ptr @j_binary(i32 0, ptr %withchar, ptr %quote)
  br i1 %expectend, label %expected, label %plain
expected:
  %suffix = call ptr @j_cstr(ptr @ev_expecting_eof)
  %full = call ptr @j_binary(i32 0, ptr %quoted, ptr %suffix)
  br label %raise
plain:
  br label %raise
raise:
  %message = phi ptr [%full, %expected], [%quoted, %plain]
  store ptr %message, ptr @j_error
  store i64 %start, ptr @j_compile_error_start
  store i64 %end, ptr @j_compile_error_end
  br label %done
done:
  ret void
}

define internal void @ev_validateescapes(ptr %source, i64 %start, i64 %end) {
entry:
  %first = add i64 %start, 1
  %last = sub i64 %end, 1
  br label %loop
loop:
  %i = phi i64 [%first, %entry], [%next, %plain], [%escnext, %escape], [%interpnext, %interpolate]
  %more = icmp ult i64 %i, %last
  br i1 %more, label %read, label %done
read:
  %p = getelementptr i8, ptr %source, i64 %i
  %ch = load i8, ptr %p
  %slash = icmp eq i8 %ch, 92
  br i1 %slash, label %escaperead, label %plain
plain:
  %next = add i64 %i, 1
  br label %loop
escaperead:
  %ei = add i64 %i, 1
  %ep = getelementptr i8, ptr %source, i64 %ei
  %ec = load i8, ptr %ep
  switch i8 %ec, label %invalid [i8 34, label %escape i8 92, label %escape i8 47, label %escape i8 98, label %escape i8 102, label %escape i8 110, label %escape i8 114, label %escape i8 116, label %escape i8 117, label %escape i8 40, label %interpolate]
escape:
  %escnext = add i64 %i, 2
  br label %loop
interpolate:
  %interpstart = add i64 %i, 2
  %interpnext = call i64 @ev_parenend(ptr %source, i64 %end, i64 %interpstart)
  br label %loop
invalid:
  %prefix = call ptr @j_cstr(ptr @ev_invalidescape)
  %escapevalue = call ptr @j_str(ptr %p, i64 2)
  %withescape = call ptr @j_binary(i32 0, ptr %prefix, ptr %escapevalue)
  %suffix = call ptr @j_cstr(ptr @ev_escapeend)
  %message = call ptr @j_binary(i32 0, ptr %withescape, ptr %suffix)
  store ptr %message, ptr @j_error
  store i64 %i, ptr @j_compile_error_start
  %after = add i64 %i, 2
  store i64 %after, ptr @j_compile_error_end
  br label %done
done:
  ret void
}

define internal void @ev_checkmetadata(ptr %value) {
entry:
  %existing = load ptr, ptr @j_error
  %clear = icmp eq ptr %existing, null
  br i1 %clear, label %check, label %done
check:
  %tag = load i32, ptr %value
  %object = icmp eq i32 %tag, 6
  br i1 %object, label %done, label %bad
bad:
  call void @j_fail(ptr @ev_moduleobject)
  br label %done
done:
  ret void
}

define internal i1 @ev_isconstant(ptr %node) {
entry:
  %kind = load i32, ptr %node
  %ap = getelementptr %N, ptr %node, i32 0, i32 2
  %a = load ptr, ptr %ap
  %bp = getelementptr %N, ptr %node, i32 0, i32 3
  %b = load ptr, ptr %bp
  switch i32 %kind, label %no [i32 0, label %yes i32 3, label %binary i32 4, label %binary i32 8, label %unary i32 9, label %object i32 15, label %unary]
binary:
  %ac = call i1 @ev_isconstant(ptr %a)
  %bc = call i1 @ev_isconstant(ptr %b)
  %both = and i1 %ac, %bc
  ret i1 %both
unary:
  %child = call i1 @ev_isconstant(ptr %a)
  ret i1 %child
object:
  %n = call i64 @ev_len(ptr %a)
  br label %loop
loop:
  %i = phi i64 [0, %object], [%next, %advance]
  %more = icmp ult i64 %i, %n
  br i1 %more, label %body, label %yes
body:
  %part = call ptr @j_at(ptr %a, i64 %i)
  %pc = call i1 @ev_isconstant(ptr %part)
  br i1 %pc, label %advance, label %no
advance:
  %next = add i64 %i, 1
  br label %loop
yes:
  ret i1 true
no:
  ret i1 false
}

define internal ptr @ev_constvalue(ptr %node) {
entry:
  %constant = call i1 @ev_isconstant(ptr %node)
  br i1 %constant, label %evaluate, label %error
evaluate:
  %null = call ptr @j_null()
  %values = call ptr @j_eval(ptr %node, ptr %null, ptr null)
  %n = call i64 @ev_len(ptr %values)
  %one = icmp eq i64 %n, 1
  br i1 %one, label %found, label %error
found:
  %value = call ptr @j_at(ptr %values, i64 0)
  ret ptr %value
error:
  call void @j_fail(ptr @ev_moduleconstant)
  %missing = call ptr @j_null()
  ret ptr %missing
}

define internal ptr @ev_dirname(ptr %path) {
entry:
  %n = call i64 @ev_len(ptr %path)
  %dp = getelementptr %V, ptr %path, i32 0, i32 5
  %data = load ptr, ptr %dp
  br label %loop
loop:
  %i = phi i64 [%n, %entry], [%prev, %body]
  %more = icmp ugt i64 %i, 0
  br i1 %more, label %body, label %dot
body:
  %prev = sub i64 %i, 1
  %p = getelementptr i8, ptr %data, i64 %prev
  %c = load i8, ptr %p
  %slash = icmp eq i8 %c, 47
  br i1 %slash, label %found, label %loop
found:
  %root = icmp eq i64 %prev, 0
  %len = select i1 %root, i64 1, i64 %prev
  %dir = call ptr @j_str(ptr %data, i64 %len)
  ret ptr %dir
dot:
  %default = call ptr @j_cstr(ptr @ev_dotdir)
  ret ptr %default
}

define internal ptr @ev_basename(ptr %path) {
entry:
  %n = call i64 @ev_len(ptr %path)
  %dp = getelementptr %V, ptr %path, i32 0, i32 5
  %data = load ptr, ptr %dp
  br label %loop
loop:
  %i = phi i64 [%n, %entry], [%prev, %body]
  %more = icmp ugt i64 %i, 0
  br i1 %more, label %body, label %all
body:
  %prev = sub i64 %i, 1
  %p = getelementptr i8, ptr %data, i64 %prev
  %c = load i8, ptr %p
  %slash = icmp eq i8 %c, 47
  br i1 %slash, label %found, label %loop
found:
  %start = getelementptr i8, ptr %data, i64 %i
  %len = sub i64 %n, %i
  %base = call ptr @j_str(ptr %start, i64 %len)
  ret ptr %base
all:
  ret ptr %path
}

define internal ptr @ev_joinpath(ptr %dir, ptr %path) {
entry:
  %slash = call ptr @j_cstr(ptr @ev_slash)
  %prefix = call ptr @j_binary(i32 0, ptr %dir, ptr %slash)
  %joined = call ptr @j_binary(i32 0, ptr %prefix, ptr %path)
  ret ptr %joined
}

define internal ptr @ev_modulefile(ptr %path, i1 %data) {
entry:
  %dp = getelementptr %V, ptr %path, i32 0, i32 5
  %filename = load ptr, ptr %dp
  %bytes = call ptr @j_read_file(ptr %filename)
  %missing = icmp eq ptr %bytes, null
  br i1 %missing, label %failed, label %found
failed:
  store ptr null, ptr @j_error
  ret ptr null
found:
  %record = call ptr @j_alloc(i64 32)
  %directory = call ptr @ev_dirname(ptr %path)
  %dirp = getelementptr ptr, ptr %record, i64 1
  store ptr %directory, ptr %dirp
  %bytesp = getelementptr ptr, ptr %record, i64 2
  store ptr %bytes, ptr %bytesp
  %pathp = getelementptr ptr, ptr %record, i64 3
  store ptr %path, ptr %pathp
  br i1 %data, label %datadone, label %compile
datadone:
  ret ptr %record
compile:
  %tail = call ptr @j_cstr(ptr @ev_module_tail)
  %program = call ptr @j_binary(i32 0, ptr %bytes, ptr %tail)
  %pd = getelementptr %V, ptr %program, i32 0, i32 5
  %source = load ptr, ptr %pd
  %length = call i64 @ev_len(ptr %program)
  %saveddepth = load i64, ptr @ev_compile_depth
  %parsedepth = add i64 %saveddepth, 1
  store i64 %parsedepth, ptr @ev_compile_depth
  %ast = call ptr @j_compile(ptr %source, i64 %length)
  store i64 %saveddepth, ptr @ev_compile_depth
  store ptr %ast, ptr %record
  ret ptr %record
}

define internal ptr @ev_loadmodule(ptr %path, i1 %data, ptr %metadata, ptr %parentdir) {
entry:
  %paths = call ptr @j_array()
  %sk = call ptr @j_cstr(ptr @ev_searchkey)
  %search = call ptr @j_get(ptr %metadata, ptr %sk)
  %st = load i32, ptr %search
  switch i32 %st, label %globalpaths [i32 4, label %searchstring i32 5, label %searcharray]
searchstring:
  call void @j_push(ptr %paths, ptr %search)
  br label %resolve
searcharray:
  call void @ev_extend(ptr %paths, ptr %search)
  br label %resolve
resolve:
  %resolven = call i64 @ev_len(ptr %paths)
  %resolved = call ptr @j_array()
  %nodir = icmp eq ptr %parentdir, null
  br label %resolveloop
resolveloop:
  %ri = phi i64 [0, %resolve], [%rinext, %resolvedone]
  %rmore = icmp ult i64 %ri, %resolven
  br i1 %rmore, label %resolvebody, label %resolvefinish
resolvebody:
  %rv = call ptr @j_at(ptr %paths, i64 %ri)
  %rdp = getelementptr %V, ptr %rv, i32 0, i32 5
  %rd = load ptr, ptr %rdp
  %rf = load i8, ptr %rd
  %relative = icmp eq i8 %rf, 46
  %hasdir = xor i1 %nodir, true
  %needsdir = and i1 %relative, %hasdir
  br i1 %needsdir, label %resolvejoin, label %resolveplain
resolvejoin:
  %joined = call ptr @ev_joinpath(ptr %parentdir, ptr %rv)
  br label %resolvedone
resolveplain:
  br label %resolvedone
resolvedone:
  %rp = phi ptr [%joined, %resolvejoin], [%rv, %resolveplain]
  call void @j_push(ptr %resolved, ptr %rp)
  %rinext = add i64 %ri, 1
  br label %resolveloop
resolvefinish:
  br label %globalpaths
globalpaths:
  %dirs = phi ptr [%paths, %entry], [%resolved, %resolvefinish]
  %global = load ptr, ptr @j_library_paths
  %hasglobal = icmp ne ptr %global, null
  br i1 %hasglobal, label %addglobal, label %default
addglobal:
  call void @ev_extend(ptr %dirs, ptr %global)
  br label %default
default:
  %dot = call ptr @j_cstr(ptr @ev_dotdir)
  call void @j_push(ptr %dirs, ptr %dot)
  %n = call i64 @ev_len(ptr %dirs)
  %exttext = select i1 %data, ptr @ev_jsonextension, ptr @ev_jqextension
  %extension = call ptr @j_cstr(ptr %exttext)
  %basename = call ptr @ev_basename(ptr %path)
  br label %loop
loop:
  %i = phi i64 [0, %default], [%next, %advance]
  %more = icmp ult i64 %i, %n
  br i1 %more, label %body, label %missing
body:
  %dir = call ptr @j_at(ptr %dirs, i64 %i)
  %base = call ptr @ev_joinpath(ptr %dir, ptr %path)
  %file = call ptr @j_binary(i32 0, ptr %base, ptr %extension)
  %record = call ptr @ev_modulefile(ptr %file, i1 %data)
  %found = icmp ne ptr %record, null
  br i1 %found, label %founddirect, label %nested
nested:
  %nestedbase = call ptr @ev_joinpath(ptr %base, ptr %basename)
  %nestedfile = call ptr @j_binary(i32 0, ptr %nestedbase, ptr %extension)
  %nestedrecord = call ptr @ev_modulefile(ptr %nestedfile, i1 %data)
  %nestedfound = icmp ne ptr %nestedrecord, null
  br i1 %nestedfound, label %foundnested, label %advance
advance:
  %next = add i64 %i, 1
  br label %loop
founddirect:
  ret ptr %record
foundnested:
  ret ptr %nestedrecord
missing:
  call void @j_fail(ptr @ev_modulenotfound)
  ret ptr null
}

define internal ptr @ev_exportenv(ptr %source, ptr %alias, ptr %destination) {
entry:
  %empty = icmp eq ptr %source, null
  br i1 %empty, label %done, label %body
done:
  ret ptr %destination
body:
  %next = load ptr, ptr %source
  %dest = call ptr @ev_exportenv(ptr %next, ptr %alias, ptr %destination)
  %np = getelementptr %E, ptr %source, i32 0, i32 1
  %name = load ptr, ptr %np
  %vp = getelementptr %E, ptr %source, i32 0, i32 2
  %value = load ptr, ptr %vp
  %tp = getelementptr %E, ptr %source, i32 0, i32 3
  %type = load i32, ptr %tp
  %pp = getelementptr %E, ptr %source, i32 0, i32 4
  %params = load ptr, ptr %pp
  %ep = getelementptr %E, ptr %source, i32 0, i32 5
  %closure = load ptr, ptr %ep
  %include = icmp eq ptr %alias, null
  br i1 %include, label %plain, label %prefix
prefix:
  %sep = call ptr @j_cstr(ptr @ev_namespace)
  %withsep = call ptr @j_binary(i32 0, ptr %alias, ptr %sep)
  %qualified = call ptr @j_binary(i32 0, ptr %withsep, ptr %name)
  br label %bind
plain:
  br label %bind
bind:
  %exportname = phi ptr [%qualified, %prefix], [%name, %plain]
  %new = call ptr @j_bind(ptr %dest, ptr %exportname, ptr %value)
  %ntp = getelementptr %E, ptr %new, i32 0, i32 3
  store i32 %type, ptr %ntp
  %npp = getelementptr %E, ptr %new, i32 0, i32 4
  store ptr %params, ptr %npp
  %nep = getelementptr %E, ptr %new, i32 0, i32 5
  store ptr %closure, ptr %nep
  ret ptr %new
}

define internal ptr @ev_importenv(ptr %node, ptr %env, ptr %directory) {
entry:
  %op.p = getelementptr %N, ptr %node, i32 0, i32 1
  %op = load i32, ptr %op.p
  %data = icmp eq i32 %op, 1
  %ap = getelementptr %N, ptr %node, i32 0, i32 2
  %path = load ptr, ptr %ap
  %bp = getelementptr %N, ptr %node, i32 0, i32 3
  %alias = load ptr, ptr %bp
  %dp = getelementptr %N, ptr %node, i32 0, i32 5
  %metadata = load ptr, ptr %dp
  %loaded = call ptr @ev_loadmodule(ptr %path, i1 %data, ptr %metadata, ptr %directory)
  %found = icmp ne ptr %loaded, null
  br i1 %found, label %dispatch, label %failed
failed:
  ret ptr %env
dispatch:
  br i1 %data, label %dataimport, label %codeimport
dataimport:
  %bytesp = getelementptr ptr, ptr %loaded, i64 2
  %bytes = load ptr, ptr %bytesp
  %bdp = getelementptr %V, ptr %bytes, i32 0, i32 5
  %buffer = load ptr, ptr %bdp
  %length = call i64 @ev_len(ptr %bytes)
  %values = call ptr @j_array()
  %offset = alloca i64
  store i64 0, ptr %offset
  br label %dataloop
dataloop:
  %value = call ptr @j_parse(ptr %buffer, i64 %length, ptr %offset)
  %hasvalue = icmp ne ptr %value, null
  br i1 %hasvalue, label %dataappend, label %datadone
dataappend:
  call void @j_push(ptr %values, ptr %value)
  br label %dataloop
datadone:
  %short = call ptr @j_bind(ptr %env, ptr %alias, ptr %values)
  %ns = call ptr @j_cstr(ptr @ev_namespace)
  %prefix = call ptr @j_binary(i32 0, ptr %alias, ptr %ns)
  %qualified = call ptr @j_binary(i32 0, ptr %prefix, ptr %alias)
  %long = call ptr @j_bind(ptr %short, ptr %qualified, ptr %values)
  ret ptr %long
codeimport:
  %pathp = getelementptr ptr, ptr %loaded, i64 3
  %filename = load ptr, ptr %pathp
  %savedstack = load ptr, ptr @ev_module_stack
  %hasstack = icmp ne ptr %savedstack, null
  br i1 %hasstack, label %stackcopy, label %stackcreate
stackcopy:
  %copystack = call ptr @j_clone(ptr %savedstack)
  br label %stackstart
stackcreate:
  %emptystack = call ptr @j_array()
  br label %stackstart
stackstart:
  %stack = phi ptr [%copystack, %stackcopy], [%emptystack, %stackcreate]
  %stackn = call i64 @ev_len(ptr %stack)
  br label %stackloop
stackloop:
  %stacki = phi i64 [0, %stackstart], [%stacknext, %stackadvance]
  %stackmore = icmp ult i64 %stacki, %stackn
  br i1 %stackmore, label %stackbody, label %stackpush
stackbody:
  %activepath = call ptr @j_at(ptr %stack, i64 %stacki)
  %pathcmp = call i32 @j_cmp(ptr %activepath, ptr %filename)
  %samepath = icmp eq i32 %pathcmp, 0
  br i1 %samepath, label %circular, label %stackadvance
stackadvance:
  %stacknext = add i64 %stacki, 1
  br label %stackloop
circular:
  call void @j_fail(ptr @ev_circularimport)
  ret ptr %env
stackpush:
  call void @j_push(ptr %stack, ptr %filename)
  store ptr %stack, ptr @ev_module_stack
  %ast = load ptr, ptr %loaded
  %dirp = getelementptr ptr, ptr %loaded, i64 1
  %dir = load ptr, ptr %dirp
  %moduleenv = call ptr @ev_moduleenv(ptr %ast, ptr null, ptr %dir)
  store ptr %savedstack, ptr @ev_module_stack
  %exported = call ptr @ev_exportenv(ptr %moduleenv, ptr %alias, ptr %env)
  ret ptr %exported
}

define internal ptr @ev_moduleenv(ptr %node, ptr %env, ptr %directory) {
entry:
  %none = icmp eq ptr %node, null
  %error = load ptr, ptr @j_error
  %failed = icmp ne ptr %error, null
  %stop = or i1 %none, %failed
  br i1 %stop, label %done, label %depthcheck
depthcheck:
  %depth = load i64, ptr @ev_module_depth
  %too = icmp ugt i64 %depth, 128
  br i1 %too, label %cycle, label %dispatch
cycle:
  call void @j_fail(ptr @ev_modulecycle)
  ret ptr %env
dispatch:
  %incr = add i64 %depth, 1
  store i64 %incr, ptr @ev_module_depth
  %kind = load i32, ptr %node
  %ap = getelementptr %N, ptr %node, i32 0, i32 2
  %a = load ptr, ptr %ap
  %bp = getelementptr %N, ptr %node, i32 0, i32 3
  %b = load ptr, ptr %bp
  %cp = getelementptr %N, ptr %node, i32 0, i32 4
  %c = load ptr, ptr %cp
  %dp = getelementptr %N, ptr %node, i32 0, i32 5
  %d = load ptr, ptr %dp
  switch i32 %kind, label %finish [i32 12, label %def i32 24, label %import i32 25, label %module]
def:
  %de = call ptr @j_bind(ptr %env, ptr %a, ptr %c)
  %dtp = getelementptr %E, ptr %de, i32 0, i32 3
  store i32 1, ptr %dtp
  %dpp = getelementptr %E, ptr %de, i32 0, i32 4
  store ptr %b, ptr %dpp
  %dep = getelementptr %E, ptr %de, i32 0, i32 5
  store ptr %de, ptr %dep
  %defined = call ptr @ev_moduleenv(ptr %d, ptr %de, ptr %directory)
  br label %finish
import:
  %ie = call ptr @ev_importenv(ptr %node, ptr %env, ptr %directory)
  %imported = call ptr @ev_moduleenv(ptr %c, ptr %ie, ptr %directory)
  br label %finish
module:
  %moduled = call ptr @ev_moduleenv(ptr %b, ptr %env, ptr %directory)
  br label %finish
finish:
  %result = phi ptr [%env, %dispatch], [%defined, %def], [%imported, %import], [%moduled, %module]
  store i64 %depth, ptr @ev_module_depth
  ret ptr %result
done:
  ret ptr %env
}

define internal ptr @ev_modulemetadata(ptr %path) {
entry:
  %empty = call ptr @j_object()
  %record = call ptr @ev_loadmodule(ptr %path, i1 false, ptr %empty, ptr null)
  %found = icmp ne ptr %record, null
  br i1 %found, label %start, label %missing
missing:
  ret ptr %empty
start:
  %ast = load ptr, ptr %record
  %deps = call ptr @j_array()
  %defs = call ptr @j_array()
  br label %loop
loop:
  %node = phi ptr [%ast, %start], [%b, %module], [%c, %import], [%d, %def]
  %meta = phi ptr [%empty, %start], [%a, %module], [%meta, %import], [%meta, %def]
  %none = icmp eq ptr %node, null
  br i1 %none, label %done, label %dispatch
dispatch:
  %kind = load i32, ptr %node
  %ap = getelementptr %N, ptr %node, i32 0, i32 2
  %a = load ptr, ptr %ap
  %bp = getelementptr %N, ptr %node, i32 0, i32 3
  %b = load ptr, ptr %bp
  %cp = getelementptr %N, ptr %node, i32 0, i32 4
  %c = load ptr, ptr %cp
  %dp = getelementptr %N, ptr %node, i32 0, i32 5
  %d = load ptr, ptr %dp
  switch i32 %kind, label %done [i32 12, label %def i32 24, label %import i32 25, label %module]
module:
  br label %loop
import:
  %op.p = getelementptr %N, ptr %node, i32 0, i32 1
  %op = load i32, ptr %op.p
  %data = icmp eq i32 %op, 1
  %isdata = call ptr @j_bool(i1 %data)
  %dep = call ptr @j_clone(ptr %d)
  %askey = call ptr @j_cstr(ptr @ev_askey)
  %datakey = call ptr @j_cstr(ptr @ev_datakey)
  %pathkey = call ptr @j_cstr(ptr @ev_relpathkey)
  %null = call ptr @j_null()
  %hasalias = icmp ne ptr %b, null
  %alias = select i1 %hasalias, ptr %b, ptr %null
  call void @j_put(ptr %dep, ptr %askey, ptr %alias)
  call void @j_put(ptr %dep, ptr %datakey, ptr %isdata)
  call void @j_put(ptr %dep, ptr %pathkey, ptr %a)
  call void @j_push(ptr %deps, ptr %dep)
  br label %loop
def:
  %slash = call ptr @j_cstr(ptr @ev_slash)
  %arity = call i64 @ev_len(ptr %b)
  %aritynum = uitofp i64 %arity to double
  %arityval = call ptr @j_num(double %aritynum)
  %aritystr = call ptr @j_dump(ptr %arityval, i32 0)
  %prefix = call ptr @j_binary(i32 0, ptr %a, ptr %slash)
  %defname = call ptr @j_binary(i32 0, ptr %prefix, ptr %aritystr)
  call void @j_push(ptr %defs, ptr %defname)
  br label %loop
done:
  %out = call ptr @j_clone(ptr %meta)
  %depskey = call ptr @j_cstr(ptr @ev_depskey)
  %defskey = call ptr @j_cstr(ptr @ev_defskey)
  call void @j_put(ptr %out, ptr %depskey, ptr %deps)
  call void @j_put(ptr %out, ptr %defskey, ptr %defs)
  ret ptr %out
}

@ev_notdefined = private constant [16 x i8] c" is not defined\00"
@ev_dollar = private constant [2 x i8] c"$\00"
@ev_labelprefix = private constant [9 x i8] c"$*label-\00"
@ev_emptypatternarray = private constant [62 x i8] c"syntax error, unexpected ']', expecting BINDING or '[' or '{'\00"
@ev_emptypatternobject = private constant [29 x i8] c"syntax error, unexpected '}'\00"

define internal void @ev_namederror(ptr %node, ptr %prefix, ptr %name, i64 %arity) {
entry:
  %hasarity = icmp sge i64 %arity, 0
  br i1 %hasarity, label %function, label %binding
function:
  %slash = call ptr @j_cstr(ptr @ev_slash)
  %num = uitofp i64 %arity to double
  %number = call ptr @j_num(double %num)
  %digits = call ptr @j_dump(ptr %number, i32 0)
  %withslash = call ptr @j_binary(i32 0, ptr %name, ptr %slash)
  %functionname = call ptr @j_binary(i32 0, ptr %withslash, ptr %digits)
  br label %done
binding:
  %pfx = call ptr @j_cstr(ptr %prefix)
  %bindingname = call ptr @j_binary(i32 0, ptr %pfx, ptr %name)
  br label %done
done:
  %text = phi ptr [%functionname, %function], [%bindingname, %binding]
  %suffix = call ptr @j_cstr(ptr @ev_notdefined)
  %message = call ptr @j_binary(i32 0, ptr %text, ptr %suffix)
  %sp = getelementptr %N, ptr %node, i32 0, i32 7
  %start = load i64, ptr %sp
  %ep = getelementptr %N, ptr %node, i32 0, i32 8
  %end = load i64, ptr %ep
  store i64 %start, ptr @j_compile_error_start
  store i64 %end, ptr @j_compile_error_end
  store ptr %message, ptr @j_error
  ret void
}

define internal ptr @ev_parameterenv(ptr %params, ptr %env) {
entry:
  %n = call i64 @ev_len(ptr %params)
  %null = call ptr @j_null()
  br label %loop
loop:
  %i = phi i64 [0, %entry], [%next, %body]
  %current = phi ptr [%env, %entry], [%new, %body]
  %more = icmp ult i64 %i, %n
  br i1 %more, label %body, label %done
body:
  %formal = call ptr @j_at(ptr %params, i64 %i)
  %kind = load i32, ptr %formal
  %np = getelementptr %N, ptr %formal, i32 0, i32 2
  %name = load ptr, ptr %np
  %new = call ptr @j_bind(ptr %current, ptr %name, ptr %null)
  %variable = icmp eq i32 %kind, 10
  %type = select i1 %variable, i32 0, i32 2
  %tp = getelementptr %E, ptr %new, i32 0, i32 3
  store i32 %type, ptr %tp
  %next = add i64 %i, 1
  br label %loop
done:
  ret ptr %current
}

define internal void @ev_validate(ptr %node, ptr %env) {
entry:
  %none = icmp eq ptr %node, null
  %error = load ptr, ptr @j_error
  %failed = icmp ne ptr %error, null
  %stop = or i1 %none, %failed
  br i1 %stop, label %done, label %dispatch
dispatch:
  %kind = load i32, ptr %node
  %ap = getelementptr %N, ptr %node, i32 0, i32 2
  %a = load ptr, ptr %ap
  %bp = getelementptr %N, ptr %node, i32 0, i32 3
  %b = load ptr, ptr %bp
  %cp = getelementptr %N, ptr %node, i32 0, i32 4
  %c = load ptr, ptr %cp
  %dp = getelementptr %N, ptr %node, i32 0, i32 5
  %d = load ptr, ptr %dp
  switch i32 %kind, label %done [i32 2, label %binary i32 3, label %binary i32 4, label %binary i32 5, label %binary i32 6, label %unary i32 7, label %call i32 8, label %unary i32 9, label %object i32 10, label %variable i32 11, label %binding i32 12, label %definition i32 13, label %ternary i32 14, label %binary i32 15, label %unary i32 16, label %unary i32 18, label %reduction i32 19, label %binary i32 20, label %ternary i32 21, label %binary i32 22, label %label i32 23, label %break i32 24, label %import i32 25, label %module]
unary:
  call void @ev_validate(ptr %a, ptr %env)
  br label %done
binary:
  call void @ev_validate(ptr %a, ptr %env)
  call void @ev_validate(ptr %b, ptr %env)
  br label %done
ternary:
  call void @ev_validate(ptr %a, ptr %env)
  call void @ev_validate(ptr %b, ptr %env)
  call void @ev_validate(ptr %c, ptr %env)
  br label %done
object:
  %on = call i64 @ev_len(ptr %a)
  br label %objloop
objloop:
  %oi = phi i64 [0, %object], [%onext, %objbody]
  %omore = icmp ult i64 %oi, %on
  br i1 %omore, label %objbody, label %done
objbody:
  %part = call ptr @j_at(ptr %a, i64 %oi)
  call void @ev_validate(ptr %part, ptr %env)
  %onext = add i64 %oi, 1
  br label %objloop
variable:
  %var = call ptr @ev_lookup(ptr %env, ptr %a, i32 0, i64 0)
  %hasvar = icmp ne ptr %var, null
  %location = call i1 @j_is(ptr %a, ptr @ev_locname)
  %validvar = or i1 %hasvar, %location
  br i1 %validvar, label %done, label %varerror
varerror:
  call void @ev_namederror(ptr %node, ptr @ev_dollar, ptr %a, i64 -1)
  br label %done
call:
  %arity = call i64 @ev_len(ptr %b)
  %def = call ptr @ev_lookup(ptr %env, ptr %a, i32 1, i64 %arity)
  %hasdef = icmp ne ptr %def, null
  %filter = call ptr @ev_lookup(ptr %env, ptr %a, i32 2, i64 0)
  %hasfilter = icmp ne ptr %filter, null
  %zeroargs = icmp eq i64 %arity, 0
  %validfilter = and i1 %hasfilter, %zeroargs
  %builtin = call i1 @b_known(ptr %a, i64 %arity)
  %ispath = call i1 @j_is(ptr %a, ptr @ev_path)
  %isdel = call i1 @j_is(ptr %a, ptr @ev_del)
  %ispick = call i1 @j_is(ptr %a, ptr @ev_pick)
  %ismeta = call i1 @j_is(ptr %a, ptr @ev_modulemeta)
  %onearg = icmp eq i64 %arity, 1
  %p1 = or i1 %ispath, %isdel
  %p2 = or i1 %p1, %ispick
  %p3 = and i1 %p2, %onearg
  %m0 = and i1 %ismeta, %zeroargs
  %s1 = or i1 %p3, %m0
  %known1 = or i1 %hasdef, %validfilter
  %known2 = or i1 %builtin, %s1
  %known = or i1 %known1, %known2
  br i1 %known, label %argstart, label %callerror
callerror:
  call void @ev_namederror(ptr %node, ptr @ev_dollar, ptr %a, i64 %arity)
  br label %done
argstart:
  br label %argloop
argloop:
  %ai = phi i64 [0, %argstart], [%anext, %argbody]
  %amore = icmp ult i64 %ai, %arity
  br i1 %amore, label %argbody, label %done
argbody:
  %arg = call ptr @j_at(ptr %b, i64 %ai)
  call void @ev_validate(ptr %arg, ptr %env)
  %anext = add i64 %ai, 1
  br label %argloop
binding:
  call void @ev_validate(ptr %a, ptr %env)
  call void @ev_validatepattern(ptr %b)
  %bound = call ptr @ev_patternnull(ptr %b, ptr %env)
  call void @ev_validate(ptr %c, ptr %bound)
  br label %done
definition:
  %de = call ptr @j_bind(ptr %env, ptr %a, ptr %c)
  %dtp = getelementptr %E, ptr %de, i32 0, i32 3
  store i32 1, ptr %dtp
  %dpp = getelementptr %E, ptr %de, i32 0, i32 4
  store ptr %b, ptr %dpp
  %denv = call ptr @ev_parameterenv(ptr %b, ptr %de)
  %localfunctions = call i64 @ev_functioncount(ptr %de)
  call void @ev_functionlimit(i64 %localfunctions)
  call void @ev_validate(ptr %c, ptr %denv)
  call void @ev_validate(ptr %d, ptr %de)
  br label %done
reduction:
  call void @ev_validate(ptr %a, ptr %env)
  call void @ev_validate(ptr %c, ptr %env)
  call void @ev_validatepattern(ptr %b)
  %redenv = call ptr @ev_patternnull(ptr %b, ptr %env)
  call void @ev_validate(ptr %d, ptr %redenv)
  %exp = getelementptr %N, ptr %node, i32 0, i32 6
  %extract = load ptr, ptr %exp
  call void @ev_validate(ptr %extract, ptr %redenv)
  br label %done
label:
  %null = call ptr @j_null()
  %labelenv = call ptr @j_bind(ptr %env, ptr %a, ptr %null)
  %ltp = getelementptr %E, ptr %labelenv, i32 0, i32 3
  store i32 3, ptr %ltp
  call void @ev_validate(ptr %b, ptr %labelenv)
  br label %done
break:
  %foundlabel = call ptr @ev_lookup(ptr %env, ptr %a, i32 3, i64 0)
  %validlabel = icmp ne ptr %foundlabel, null
  br i1 %validlabel, label %done, label %breakerror
breakerror:
  call void @ev_namederror(ptr %node, ptr @ev_labelprefix, ptr %a, i64 -1)
  br label %done
import:
  %importenv = call ptr @ev_importenv(ptr %node, ptr %env, ptr null)
  call void @ev_validate(ptr %c, ptr %importenv)
  br label %done
module:
  call void @ev_validate(ptr %b, ptr %env)
  br label %done
done:
  ret void
}

define internal void @ev_validatepattern(ptr %node) {
entry:
  %kind = load i32, ptr %node
  %ap = getelementptr %N, ptr %node, i32 0, i32 2
  %a = load ptr, ptr %ap
  switch i32 %kind, label %done [i32 0, label %literal i32 9, label %object i32 8, label %array i32 3, label %comma i32 27, label %items]
literal:
  %tag = load i32, ptr %a
  %isarray = icmp eq i32 %tag, 5
  br i1 %isarray, label %emptyarray, label %done
emptyarray:
  br label %error
object:
  %n = call i64 @ev_len(ptr %a)
  %empty = icmp eq i64 %n, 0
  br i1 %empty, label %emptyobject, label %items
emptyobject:
  br label %error
error:
  %message = phi ptr [@ev_emptypatternarray, %emptyarray], [@ev_emptypatternobject, %emptyobject]
  %sp = getelementptr %N, ptr %node, i32 0, i32 7
  %start = load i64, ptr %sp
  %close = add i64 %start, 1
  %end = add i64 %close, 1
  call void @ev_compileerror(i64 %close, i64 %end, ptr %message)
  br label %done
array:
  call void @ev_validatepattern(ptr %a)
  br label %done
comma:
  call void @ev_validatepattern(ptr %a)
  %bp = getelementptr %N, ptr %node, i32 0, i32 3
  %b = load ptr, ptr %bp
  call void @ev_validatepattern(ptr %b)
  br label %done
items:
  %count = call i64 @ev_len(ptr %a)
  br label %loop
loop:
  %i = phi i64 [0, %items], [%next, %body]
  %more = icmp ult i64 %i, %count
  br i1 %more, label %body, label %done
body:
  %child = call ptr @j_at(ptr %a, i64 %i)
  call void @ev_validatepattern(ptr %child)
  %next = add i64 %i, 1
  br label %loop
done:
  ret void
}
