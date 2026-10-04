@t.names = private constant [186 x i8] c"split\00join\00explode\00implode\00ascii_downcase\00ascii_upcase\00startswith\00endswith\00ltrimstr\00rtrimstr\00trimstr\00trim\00ltrim\00rtrim\00@text\00@json\00@html\00@uri\00@urid\00@csv\00@tsv\00@sh\00@base64\00@base64d\00format\00\00"
@t.base64 = private constant [65 x i8] c"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/\00"
@t.hex = private constant [17 x i8] c"0123456789ABCDEF\00"
@t.empty = private constant [1 x i8] zeroinitializer
@t.space = private constant [2 x i8] c" \00"
@t.quote = private constant [2 x i8] c"'\00"
@t.shquote = private constant [5 x i8] c"'\5C''\00"
@t.htmlamp = private constant [6 x i8] c"&amp;\00"
@t.htmllt = private constant [5 x i8] c"&lt;\00"
@t.htmlgt = private constant [5 x i8] c"&gt;\00"
@t.htmlquote = private constant [7 x i8] c"&quot;\00"
@t.htmlapos = private constant [7 x i8] c"&apos;\00"
@t.errimplode = private constant [31 x i8] c"implode input must be an array\00"
@t.errcodepoint = private constant [57 x i8] c"can't be imploded, unicode codepoint needs to be numeric\00"
@t.errbase64 = private constant [25 x i8] c"is not valid base64 data\00"
@t.errbasetail = private constant [27 x i8] c"trailing base64 byte found\00"
@t.erruri = private constant [28 x i8] c"is not a valid uri encoding\00"
@t.errtrim = private constant [28 x i8] c"trim input must be a string\00"
@t.errcsv = private constant [36 x i8] c"cannot be csv-formatted, only array\00"
@t.errtsv = private constant [36 x i8] c"cannot be tsv-formatted, only array\00"
@t.errstring = private constant [16 x i8] c"is not a string\00"
@t.errstrsearch = private constant [42 x i8] c"cannot be searched, as it is not a string\00"
@t.strindices = private constant [12 x i8] c"_strindices\00"
@t.errstartswith = private constant [36 x i8] c"startswith() requires string inputs\00"
@t.errendswith = private constant [34 x i8] c"endswith() requires string inputs\00"
@j_error = external global ptr

declare i32 @b_tag(ptr)
declare i64 @b_len(ptr)
declare ptr @b_data(ptr)
declare double @b_number(ptr)
declare ptr @b_one(ptr)
declare ptr @b_arg(ptr, i64, ptr, ptr)
declare i32 @b_find(ptr, ptr)
declare ptr @b_tostring(ptr)
declare void @b_type_error(ptr, ptr)
declare void @b_pushvalid(ptr, ptr)
declare ptr @b_indices(ptr, ptr)
declare i1 @b_bytes_equal(ptr, ptr, i64)
declare i64 @b_search_bytes(ptr, i64, ptr, i64, i64)
declare ptr @j_alloc(i64)
declare ptr @j_str(ptr, i64)
declare ptr @j_cstr(ptr)
declare i64 @j_strlen(ptr)
declare i1 @j_is(ptr, ptr)
declare ptr @j_num(double)
declare ptr @j_bool(i1)
declare ptr @j_null()
declare ptr @j_array()
declare void @j_push(ptr, ptr)
declare ptr @j_at(ptr, i64)
declare ptr @j_dump(ptr, i32)
declare ptr @j_binary(i32, ptr, ptr)
declare void @j_fail(ptr)
declare void @j_copy(ptr, ptr, i64)
declare i32 @j_utf8_next(ptr, i64, ptr)
declare i64 @j_utf8_put(ptr, i32)

define ptr @j_text_builtin(ptr %name, ptr %args, ptr %input, ptr %env) {
entry:
  %id = call i32 @b_find(ptr %name, ptr @t.names)
  %known = icmp sge i32 %id, 0
  br i1 %known, label %check, label %internal
internal:
  %strindices = call i1 @j_is(ptr %name, ptr @t.strindices)
  br i1 %strindices, label %strindicesargs, label %unknown
strindicesargs:
  %sts = call ptr @b_arg(ptr %args, i64 0, ptr %input, ptr %env)
  %stn = call i64 @b_len(ptr %sts)
  %sto = call ptr @j_array()
  %stt = call i32 @b_tag(ptr %input)
  %ststr = icmp eq i32 %stt, 4
  br i1 %ststr, label %stloop, label %stbadinput
stbadinput:
  call void @b_type_error(ptr %input, ptr @t.errstrsearch)
  ret ptr %sto
stloop:
  %sti = phi i64 [0, %strindicesargs], [%stnext, %stput]
  %stmore = icmp slt i64 %sti, %stn
  br i1 %stmore, label %stbody, label %stdone
stbody:
  %sta = call ptr @j_at(ptr %sts, i64 %sti)
  %stat = call i32 @b_tag(ptr %sta)
  %stastr = icmp eq i32 %stat, 4
  br i1 %stastr, label %stput, label %stbadarg
stbadarg:
  call void @b_type_error(ptr %sta, ptr @t.errstring)
  ret ptr %sto
stput:
  %stv = call ptr @b_indices(ptr %input, ptr %sta)
  call void @j_push(ptr %sto, ptr %stv)
  %stnext = add i64 %sti, 1
  br label %stloop
stdone:
  ret ptr %sto
check:
  %argc = call i64 @b_len(ptr %args)
  %split = icmp eq i32 %id, 0
  %many = icmp sgt i64 %argc, 1
  %regex = and i1 %split, %many
  br i1 %regex, label %unknown, label %arity
arity:
  %lo = icmp sle i32 %id, 1
  %midlo = icmp sge i32 %id, 6
  %midhi = icmp sle i32 %id, 10
  %mid = and i1 %midlo, %midhi
  %format = icmp eq i32 %id, 24
  %a = or i1 %lo, %mid
  %arg = or i1 %a, %format
  br i1 %arg, label %evalargs, label %zero
zero:
  %z = call ptr @t_apply(i32 %id, ptr %input, ptr null)
  %zr = call ptr @b_one(ptr %z)
  ret ptr %zr
evalargs:
  %values = call ptr @b_arg(ptr %args, i64 0, ptr %input, ptr %env)
  %n = call i64 @b_len(ptr %values)
  %out = call ptr @j_array()
  br label %loop
loop:
  %i = phi i64 [0, %evalargs], [%next, %body]
  %more = icmp slt i64 %i, %n
  br i1 %more, label %body, label %done
body:
  %v = call ptr @j_at(ptr %values, i64 %i)
  %x = call ptr @t_apply(i32 %id, ptr %input, ptr %v)
  call void @b_pushvalid(ptr %out, ptr %x)
  %next = add i64 %i, 1
  br label %loop
done:
  ret ptr %out
unknown:
  ret ptr null
}

define ptr @t_apply(i32 %id, ptr %input, ptr %arg) {
entry:
  switch i32 %id, label %format [i32 0, label %split i32 1, label %join i32 2, label %explode i32 3, label %implode i32 4, label %ascii i32 5, label %ascii i32 6, label %edge i32 7, label %edge i32 8, label %edge i32 9, label %edge i32 10, label %edge i32 11, label %trim i32 12, label %trim i32 13, label %trim i32 14, label %text i32 15, label %json i32 16, label %html i32 17, label %uri i32 18, label %urid i32 19, label %csv i32 20, label %csv i32 21, label %sh i32 22, label %base64 i32 23, label %base64d]
split:
  %sp = call ptr @j_split(ptr %input, ptr %arg)
  ret ptr %sp
join:
  %jn = call ptr @t_join(ptr %input, ptr %arg)
  ret ptr %jn
explode:
  %ex = call ptr @t_explode(ptr %input)
  ret ptr %ex
implode:
  %im = call ptr @t_implode(ptr %input)
  ret ptr %im
ascii:
  %upper = icmp eq i32 %id, 5
  %as = call ptr @t_ascii(ptr %input, i1 %upper)
  ret ptr %as
edge:
  %ed = call ptr @t_edge(i32 %id, ptr %input, ptr %arg)
  ret ptr %ed
trim:
  %tm = call ptr @t_trim(i32 %id, ptr %input)
  ret ptr %tm
text:
  %tx = call ptr @b_tostring(ptr %input)
  ret ptr %tx
json:
  %js = call ptr @j_dump(ptr %input, i32 0)
  ret ptr %js
html:
  %ht = call ptr @t_html(ptr %input)
  ret ptr %ht
uri:
  %ur = call ptr @t_uri(ptr %input, i1 false)
  ret ptr %ur
urid:
  %ud = call ptr @t_uri(ptr %input, i1 true)
  ret ptr %ud
csv:
  %tsv = icmp eq i32 %id, 20
  %cs = call ptr @t_csv(ptr %input, i1 %tsv)
  ret ptr %cs
sh:
  %shell = call ptr @t_sh(ptr %input)
  ret ptr %shell
base64:
  %b6 = call ptr @t_base64(ptr %input)
  ret ptr %b6
base64d:
  %b6d = call ptr @t_base64d(ptr %input)
  ret ptr %b6d
format:
  %at = call ptr @j_str(ptr @t.names, i64 0)
  %d = call ptr @b_data(ptr %arg)
  %n = call i64 @b_len(ptr %arg)
  %cap = add i64 %n, 2
  %buf = call ptr @j_alloc(i64 %cap)
  store i8 64, ptr %buf
  %p = getelementptr i8, ptr %buf, i64 1
  call void @j_copy(ptr %p, ptr %d, i64 %n)
  %len = add i64 %n, 1
  %name = call ptr @j_str(ptr %buf, i64 %len)
  %fid = call i32 @b_find(ptr %name, ptr @t.names)
  %valid = icmp sge i32 %fid, 14
  br i1 %valid, label %formatdo, label %formatbad
formatdo:
  %fr = call ptr @t_apply(i32 %fid, ptr %input, ptr null)
  ret ptr %fr
formatbad:
  call void @b_type_error(ptr %arg, ptr @t.errstring)
  %nil = call ptr @j_null()
  ret ptr %nil
}

define ptr @j_split(ptr %input, ptr %sep) {
entry:
  %out = call ptr @j_array()
  %s = call ptr @b_data(ptr %input)
  %n = call i64 @b_len(ptr %input)
  %d = call ptr @b_data(ptr %sep)
  %dn = call i64 @b_len(ptr %sep)
  %empty = icmp eq i64 %dn, 0
  br i1 %empty, label %chars, label %loop
chars:
  %offset = alloca i64
  store i64 0, ptr %offset
  br label %charloop
charloop:
  %pos = load i64, ptr %offset
  %morechars = icmp slt i64 %pos, %n
  br i1 %morechars, label %charbody, label %done
charbody:
  %cp = call i32 @j_utf8_next(ptr %s, i64 %n, ptr %offset)
  %end = load i64, ptr %offset
  %clen = sub i64 %end, %pos
  %cptr = getelementptr i8, ptr %s, i64 %pos
  %cv = call ptr @j_str(ptr %cptr, i64 %clen)
  call void @j_push(ptr %out, ptr %cv)
  br label %charloop
loop:
  %start = phi i64 [0, %entry], [%next, %found]
  %idx = call i64 @b_search_bytes(ptr %s, i64 %n, ptr %d, i64 %dn, i64 %start)
  %have = icmp sge i64 %idx, 0
  br i1 %have, label %found, label %tail
found:
  %len = sub i64 %idx, %start
  %ptr = getelementptr i8, ptr %s, i64 %start
  %v = call ptr @j_str(ptr %ptr, i64 %len)
  call void @j_push(ptr %out, ptr %v)
  %next = add i64 %idx, %dn
  br label %loop
tail:
  %tlen = sub i64 %n, %start
  %tptr = getelementptr i8, ptr %s, i64 %start
  %tv = call ptr @j_str(ptr %tptr, i64 %tlen)
  call void @j_push(ptr %out, ptr %tv)
  br label %done
done:
  ret ptr %out
}

define ptr @t_join(ptr %input, ptr %sep) {
entry:
  %n = call i64 @b_len(ptr %input)
  %empty = call ptr @j_cstr(ptr @t.empty)
  br label %loop
loop:
  %i = phi i64 [0, %entry], [%next, %append]
  %acc = phi ptr [%empty, %entry], [%sum, %append]
  %more = icmp slt i64 %i, %n
  br i1 %more, label %body, label %done
body:
  %v = call ptr @j_at(ptr %input, i64 %i)
  %t = call i32 @b_tag(ptr %v)
  %null = icmp eq i32 %t, 0
  br i1 %null, label %nil, label %convert
nil:
  br label %separator
convert:
  %container = icmp sge i32 %t, 5
  br i1 %container, label %containerkeep, label %stringconvert
containerkeep:
  br label %separator
stringconvert:
  %s = call ptr @b_tostring(ptr %v)
  br label %separator
separator:
  %sv = phi ptr [%empty, %nil], [%s, %stringconvert], [%v, %containerkeep]
  %first = icmp eq i64 %i, 0
  br i1 %first, label %firstitem, label %later
firstitem:
  br label %append
later:
  %withsep = call ptr @j_binary(i32 0, ptr %acc, ptr %sep)
  br label %append
append:
  %prefix = phi ptr [%acc, %firstitem], [%withsep, %later]
  %sum = call ptr @j_binary(i32 0, ptr %prefix, ptr %sv)
  %next = add i64 %i, 1
  br label %loop
done:
  ret ptr %acc
}

define ptr @t_explode(ptr %input) {
entry:
  %out = call ptr @j_array()
  %s = call ptr @b_data(ptr %input)
  %n = call i64 @b_len(ptr %input)
  %offset = alloca i64
  store i64 0, ptr %offset
  br label %loop
loop:
  %i = load i64, ptr %offset
  %more = icmp slt i64 %i, %n
  br i1 %more, label %body, label %done
body:
  %cp = call i32 @j_utf8_next(ptr %s, i64 %n, ptr %offset)
  %f = sitofp i32 %cp to double
  %v = call ptr @j_num(double %f)
  call void @j_push(ptr %out, ptr %v)
  br label %loop
done:
  ret ptr %out
}

define ptr @t_implode(ptr %input) {
entry:
  %tag = call i32 @b_tag(ptr %input)
  %array = icmp eq i32 %tag, 5
  br i1 %array, label %start, label %badarray
badarray:
  call void @j_fail(ptr @t.errimplode)
  %nil = call ptr @j_null()
  ret ptr %nil
start:
  %n = call i64 @b_len(ptr %input)
  %size0 = mul i64 %n, 4
  %size = add i64 %size0, 1
  %buf = call ptr @j_alloc(i64 %size)
  br label %loop
loop:
  %i = phi i64 [0, %start], [%next, %put]
  %pos = phi i64 [0, %start], [%pn, %put]
  %more = icmp slt i64 %i, %n
  br i1 %more, label %body, label %done
body:
  %v = call ptr @j_at(ptr %input, i64 %i)
  %t = call i32 @b_tag(ptr %v)
  %isnum = icmp eq i32 %t, 3
  %f = call double @b_number(ptr %v)
  %ordered = fcmp ord double %f, %f
  %numeric = and i1 %isnum, %ordered
  br i1 %numeric, label %convert, label %badnum
badnum:
  call void @b_type_error(ptr %v, ptr @t.errcodepoint)
  br label %done
convert:
  %lo = fcmp oge double %f, 0.000000e+00
  %hi = fcmp olt double %f, 1.114112e+06
  %range = and i1 %lo, %hi
  br i1 %range, label %inrange, label %replacement
inrange:
  %raw = fptosi double %f to i32
  %slo = icmp sge i32 %raw, 55296
  %shi = icmp sle i32 %raw, 57343
  %surrogate = and i1 %slo, %shi
  br i1 %surrogate, label %replacement, label %valid
valid:
  br label %put
replacement:
  br label %put
put:
  %cp = phi i32 [%raw, %valid], [65533, %replacement]
  %dst = getelementptr i8, ptr %buf, i64 %pos
  %bytes = call i64 @j_utf8_put(ptr %dst, i32 %cp)
  %pn = add i64 %pos, %bytes
  %next = add i64 %i, 1
  br label %loop
done:
  %out = call ptr @j_str(ptr %buf, i64 %pos)
  ret ptr %out
}

define ptr @t_ascii(ptr %input, i1 %upper) {
entry:
  %s = call ptr @b_data(ptr %input)
  %n = call i64 @b_len(ptr %input)
  %size = add i64 %n, 1
  %buf = call ptr @j_alloc(i64 %size)
  %lo = select i1 %upper, i8 97, i8 65
  %hi = select i1 %upper, i8 122, i8 90
  %delta = select i1 %upper, i8 -32, i8 32
  br label %loop
loop:
  %i = phi i64 [0, %entry], [%next, %body]
  %more = icmp slt i64 %i, %n
  br i1 %more, label %body, label %done
body:
  %src = getelementptr i8, ptr %s, i64 %i
  %dst = getelementptr i8, ptr %buf, i64 %i
  %c = load i8, ptr %src
  %ge = icmp uge i8 %c, %lo
  %le = icmp ule i8 %c, %hi
  %change = and i1 %ge, %le
  %changed = add i8 %c, %delta
  %out = select i1 %change, i8 %changed, i8 %c
  store i8 %out, ptr %dst
  %next = add i64 %i, 1
  br label %loop
done:
  %r = call ptr @j_str(ptr %buf, i64 %n)
  ret ptr %r
}

define ptr @t_edge(i32 %id, ptr %input, ptr %arg) {
entry:
  %tag = call i32 @b_tag(ptr %input)
  %argtag = call i32 @b_tag(ptr %arg)
  %str = icmp eq i32 %tag, 4
  %argstr = icmp eq i32 %argtag, 4
  %valid = and i1 %str, %argstr
  br i1 %valid, label %start, label %bad
bad:
  %endname = icmp eq i32 %id, 7
  %rightname = icmp eq i32 %id, 9
  %rightbuiltin = or i1 %endname, %rightname
  %message = select i1 %rightbuiltin, ptr @t.errendswith, ptr @t.errstartswith
  call void @j_fail(ptr %message)
  %nil = call ptr @j_null()
  ret ptr %nil
start:
  %s = call ptr @b_data(ptr %input)
  %n = call i64 @b_len(ptr %input)
  %a = call ptr @b_data(ptr %arg)
  %an = call i64 @b_len(ptr %arg)
  %enough = icmp sge i64 %n, %an
  br i1 %enough, label %compare, label %nomatch
compare:
  %startmatch = call i1 @b_bytes_equal(ptr %s, ptr %a, i64 %an)
  %endpos = sub i64 %n, %an
  %endptr = getelementptr i8, ptr %s, i64 %endpos
  %endmatch = call i1 @b_bytes_equal(ptr %endptr, ptr %a, i64 %an)
  switch i32 %id, label %both [i32 6, label %startbool i32 7, label %endbool i32 8, label %left i32 9, label %right]
startbool:
  %sb = call ptr @j_bool(i1 %startmatch)
  ret ptr %sb
endbool:
  %eb = call ptr @j_bool(i1 %endmatch)
  ret ptr %eb
left:
  %lstart = select i1 %startmatch, i64 %an, i64 0
  %llen = sub i64 %n, %lstart
  %lp = getelementptr i8, ptr %s, i64 %lstart
  %lv = call ptr @j_str(ptr %lp, i64 %llen)
  ret ptr %lv
right:
  %rlen = select i1 %endmatch, i64 %endpos, i64 %n
  %rv = call ptr @j_str(ptr %s, i64 %rlen)
  ret ptr %rv
both:
  %bstart = select i1 %startmatch, i64 %an, i64 0
  %remain = sub i64 %n, %bstart
  %still = icmp sge i64 %remain, %an
  %trimend = and i1 %still, %endmatch
  %bend = select i1 %trimend, i64 %endpos, i64 %n
  %blen = sub i64 %bend, %bstart
  %bp = getelementptr i8, ptr %s, i64 %bstart
  %bv = call ptr @j_str(ptr %bp, i64 %blen)
  ret ptr %bv
nomatch:
  %boolean = icmp sle i32 %id, 7
  br i1 %boolean, label %false, label %same
false:
  %fb = call ptr @j_bool(i1 false)
  ret ptr %fb
same:
  ret ptr %input
}

define i1 @t_whitespace(i32 %cp) {
entry:
  %lo = icmp sge i32 %cp, 9
  %hi = icmp sle i32 %cp, 13
  %ascii = and i1 %lo, %hi
  %ulo = icmp sge i32 %cp, 8192
  %uhi = icmp sle i32 %cp, 8202
  %unicode = and i1 %ulo, %uhi
  %range = or i1 %ascii, %unicode
  br i1 %range, label %yes, label %single
single:
  switch i32 %cp, label %no [i32 32, label %yes i32 133, label %yes i32 160, label %yes i32 5760, label %yes i32 8232, label %yes i32 8233, label %yes i32 8239, label %yes i32 8287, label %yes i32 12288, label %yes]
yes:
  ret i1 true
no:
  ret i1 false
}

define ptr @t_trim(i32 %id, ptr %input) {
entry:
  %tag = call i32 @b_tag(ptr %input)
  %str = icmp eq i32 %tag, 4
  br i1 %str, label %start, label %bad
bad:
  call void @j_fail(ptr @t.errtrim)
  %nil = call ptr @j_null()
  ret ptr %nil
start:
  %s = call ptr @b_data(ptr %input)
  %n = call i64 @b_len(ptr %input)
  %offset = alloca i64
  store i64 0, ptr %offset
  br label %loop
loop:
  %first = phi i64 [-1, %start], [%newfirst, %body]
  %last = phi i64 [0, %start], [%newlast, %body]
  %i = load i64, ptr %offset
  %more = icmp slt i64 %i, %n
  br i1 %more, label %body, label %done
body:
  %cp = call i32 @j_utf8_next(ptr %s, i64 %n, ptr %offset)
  %next = load i64, ptr %offset
  %space = call i1 @t_whitespace(i32 %cp)
  %unset = icmp eq i64 %first, -1
  %nonspace = xor i1 %space, true
  %set = and i1 %unset, %nonspace
  %newfirst = select i1 %set, i64 %i, i64 %first
  %newlast = select i1 %space, i64 %last, i64 %next
  br label %loop
done:
  %missing = icmp eq i64 %first, -1
  %left = select i1 %missing, i64 %n, i64 %first
  %onlyright = icmp eq i32 %id, 13
  %onlyleft = icmp eq i32 %id, 12
  %begin = select i1 %onlyright, i64 0, i64 %left
  %end0 = select i1 %onlyleft, i64 %n, i64 %last
  %invalid = icmp slt i64 %end0, %begin
  %end = select i1 %invalid, i64 %begin, i64 %end0
  %len = sub i64 %end, %begin
  %p = getelementptr i8, ptr %s, i64 %begin
  %r = call ptr @j_str(ptr %p, i64 %len)
  ret ptr %r
}

define ptr @t_html(ptr %input) {
entry:
  %text = call ptr @b_tostring(ptr %input)
  %s = call ptr @b_data(ptr %text)
  %n = call i64 @b_len(ptr %text)
  %cap0 = mul i64 %n, 6
  %cap = add i64 %cap0, 1
  %buf = call ptr @j_alloc(i64 %cap)
  br label %loop
loop:
  %i = phi i64 [0, %entry], [%next, %advance]
  %pos = phi i64 [0, %entry], [%pn, %advance]
  %more = icmp slt i64 %i, %n
  br i1 %more, label %body, label %done
body:
  %p = getelementptr i8, ptr %s, i64 %i
  %c = load i8, ptr %p
  %dst = getelementptr i8, ptr %buf, i64 %pos
  switch i8 %c, label %plain [i8 38, label %amp i8 60, label %lt i8 62, label %gt i8 34, label %quote i8 39, label %apos]
plain:
  store i8 %c, ptr %dst
  br label %advance
amp:
  br label %entity
lt:
  br label %entity
gt:
  br label %entity
quote:
  br label %entity
apos:
  br label %entity
entity:
  %replacement = phi ptr [@t.htmlamp, %amp], [@t.htmllt, %lt], [@t.htmlgt, %gt], [@t.htmlquote, %quote], [@t.htmlapos, %apos]
  %len = call i64 @j_strlen(ptr %replacement)
  call void @j_copy(ptr %dst, ptr %replacement, i64 %len)
  br label %advance
advance:
  %written = phi i64 [1, %plain], [%len, %entity]
  %pn = add i64 %pos, %written
  %next = add i64 %i, 1
  br label %loop
done:
  %r = call ptr @j_str(ptr %buf, i64 %pos)
  ret ptr %r
}

define i32 @t_hex(i8 %c) {
entry:
  %d = sub i8 %c, 48
  %digit = icmp ule i8 %d, 9
  br i1 %digit, label %num, label %alpha
num:
  %dn = zext i8 %d to i32
  ret i32 %dn
alpha:
  %lower = or i8 %c, 32
  %a = sub i8 %lower, 97
  %hex = icmp ule i8 %a, 5
  br i1 %hex, label %letter, label %invalid
letter:
  %ax = zext i8 %a to i32
  %an = add i32 %ax, 10
  ret i32 %an
invalid:
  ret i32 -1
}

define i1 @t_utf8_valid(ptr %s, i64 %n) {
entry:
  br label %loop
loop:
  %i = phi i64 [0, %entry], [%asciiend, %ascii], [%end, %chardone]
  %more = icmp slt i64 %i, %n
  br i1 %more, label %body, label %yes
body:
  %p = getelementptr i8, ptr %s, i64 %i
  %c = load i8, ptr %p
  %c32 = zext i8 %c to i32
  %isascii = icmp ult i8 %c, -128
  br i1 %isascii, label %ascii, label %multibyte
ascii:
  %asciiend = add i64 %i, 1
  br label %loop
multibyte:
  %two = icmp ult i32 %c32, 224
  %three = icmp ult i32 %c32, 240
  %fourcount = select i1 %three, i64 3, i64 4
  %count = select i1 %two, i64 2, i64 %fourcount
  %leadlo = icmp uge i32 %c32, 194
  %leadhi = icmp ule i32 %c32, 244
  %validlead = and i1 %leadlo, %leadhi
  %end = add i64 %i, %count
  %enough = icmp sle i64 %end, %n
  %valid = and i1 %validlead, %enough
  br i1 %valid, label %continuations, label %no
continuations:
  %mask0 = select i1 %three, i32 15, i32 7
  %mask = select i1 %two, i32 31, i32 %mask0
  %init = and i32 %c32, %mask
  br label %inner
inner:
  %j = phi i64 [1, %continuations], [%jn, %contbody]
  %cp = phi i32 [%init, %continuations], [%newcp, %contbody]
  %jm = icmp slt i64 %j, %count
  br i1 %jm, label %contbody, label %cpcheck
contbody:
  %idx = add i64 %i, %j
  %q = getelementptr i8, ptr %s, i64 %idx
  %cc = load i8, ptr %q
  %m = and i8 %cc, -64
  %cont = icmp eq i8 %m, -128
  %bits8 = and i8 %cc, 63
  %bits = zext i8 %bits8 to i32
  %shift = shl i32 %cp, 6
  %newcp = or i32 %shift, %bits
  %jn = add i64 %j, 1
  br i1 %cont, label %inner, label %no
cpcheck:
  %min0 = select i1 %three, i32 2048, i32 65536
  %min = select i1 %two, i32 128, i32 %min0
  %overlong = icmp ult i32 %cp, %min
  %toohigh = icmp ugt i32 %cp, 1114111
  %slo = icmp uge i32 %cp, 55296
  %shi = icmp ule i32 %cp, 57343
  %surrogate = and i1 %slo, %shi
  %bad0 = or i1 %overlong, %toohigh
  %bad = or i1 %bad0, %surrogate
  br i1 %bad, label %no, label %chardone
chardone:
  br label %loop
yes:
  ret i1 true
no:
  ret i1 false
}

define ptr @t_uri(ptr %input, i1 %decode) {
entry:
  %text = call ptr @b_tostring(ptr %input)
  %s = call ptr @b_data(ptr %text)
  %n = call i64 @b_len(ptr %text)
  %cap0 = mul i64 %n, 3
  %cap = add i64 %cap0, 1
  %buf = call ptr @j_alloc(i64 %cap)
  br label %loop
loop:
  %i = phi i64 [0, %entry], [%inext, %advance]
  %pos = phi i64 [0, %entry], [%pnext, %advance]
  %more = icmp slt i64 %i, %n
  br i1 %more, label %body, label %validate
body:
  %src = getelementptr i8, ptr %s, i64 %i
  %c = load i8, ptr %src
  %dst = getelementptr i8, ptr %buf, i64 %pos
  br i1 %decode, label %decodebyte, label %encodebyte
decodebyte:
  %percent = icmp eq i8 %c, 37
  br i1 %percent, label %percentcheck, label %plain
percentcheck:
  %after = add i64 %i, 2
  %enough = icmp slt i64 %after, %n
  br i1 %enough, label %percentbody, label %bad
percentbody:
  %h1p = getelementptr i8, ptr %src, i64 1
  %h2p = getelementptr i8, ptr %src, i64 2
  %h1c = load i8, ptr %h1p
  %h2c = load i8, ptr %h2p
  %h1 = call i32 @t_hex(i8 %h1c)
  %h2 = call i32 @t_hex(i8 %h2c)
  %bits = or i32 %h1, %h2
  %valid = icmp sge i32 %bits, 0
  br i1 %valid, label %decoded, label %bad
decoded:
  %high = shl i32 %h1, 4
  %joined = or i32 %high, %h2
  %byte = trunc i32 %joined to i8
  store i8 %byte, ptr %dst
  br label %advance
encodebyte:
  %digit = sub i8 %c, 48
  %isnum = icmp ule i8 %digit, 9
  %upper = sub i8 %c, 65
  %isupper = icmp ule i8 %upper, 25
  %lower = sub i8 %c, 97
  %islower = icmp ule i8 %lower, 25
  %a0 = or i1 %isnum, %isupper
  %alpha = or i1 %a0, %islower
  br i1 %alpha, label %plain, label %punct
punct:
  switch i8 %c, label %encoded [i8 45, label %plain i8 46, label %plain i8 95, label %plain i8 126, label %plain]
encoded:
  store i8 37, ptr %dst
  %cu = zext i8 %c to i64
  %hi = lshr i64 %cu, 4
  %lo = and i64 %cu, 15
  %hp = getelementptr i8, ptr @t.hex, i64 %hi
  %lp = getelementptr i8, ptr @t.hex, i64 %lo
  %hc = load i8, ptr %hp
  %lc = load i8, ptr %lp
  %d1 = getelementptr i8, ptr %dst, i64 1
  %d2 = getelementptr i8, ptr %dst, i64 2
  store i8 %hc, ptr %d1
  store i8 %lc, ptr %d2
  br label %advance
plain:
  store i8 %c, ptr %dst
  br label %advance
advance:
  %consumed = phi i64 [3, %decoded], [1, %encoded], [1, %plain]
  %written = phi i64 [1, %decoded], [3, %encoded], [1, %plain]
  %inext = add i64 %i, %consumed
  %pnext = add i64 %pos, %written
  br label %loop
validate:
  br i1 %decode, label %utf8check, label %done
utf8check:
  %utf8 = call i1 @t_utf8_valid(ptr %buf, i64 %pos)
  br i1 %utf8, label %done, label %bad
bad:
  call void @b_type_error(ptr %input, ptr @t.erruri)
  %nil = call ptr @j_null()
  ret ptr %nil
done:
  %out = call ptr @j_str(ptr %buf, i64 %pos)
  ret ptr %out
}

define ptr @t_base64(ptr %input) {
entry:
  %text = call ptr @b_tostring(ptr %input)
  %s = call ptr @b_data(ptr %text)
  %n = call i64 @b_len(ptr %text)
  %cap0 = mul i64 %n, 2
  %cap = add i64 %cap0, 8
  %buf = call ptr @j_alloc(i64 %cap)
  br label %loop
loop:
  %i = phi i64 [0, %entry], [%next, %write]
  %pos = phi i64 [0, %entry], [%pn, %write]
  %more = icmp slt i64 %i, %n
  br i1 %more, label %body, label %done
body:
  %p0 = getelementptr i8, ptr %s, i64 %i
  %c0 = load i8, ptr %p0
  %b0 = zext i8 %c0 to i32
  %i1 = add i64 %i, 1
  %i2 = add i64 %i, 2
  %have1 = icmp slt i64 %i1, %n
  %have2 = icmp slt i64 %i2, %n
  br i1 %have1, label %read1, label %missing1
read1:
  %p1 = getelementptr i8, ptr %s, i64 %i1
  %c1 = load i8, ptr %p1
  %b1 = zext i8 %c1 to i32
  br label %byte1
missing1:
  br label %byte1
byte1:
  %v1 = phi i32 [%b1, %read1], [0, %missing1]
  br i1 %have2, label %read2, label %missing2
read2:
  %p2 = getelementptr i8, ptr %s, i64 %i2
  %c2 = load i8, ptr %p2
  %b2 = zext i8 %c2 to i32
  br label %write
missing2:
  br label %write
write:
  %v2 = phi i32 [%b2, %read2], [0, %missing2]
  %b0shift = shl i32 %b0, 16
  %b1shift = shl i32 %v1, 8
  %w0 = or i32 %b0shift, %b1shift
  %word = or i32 %w0, %v2
  %s0 = lshr i32 %word, 18
  %s1a = lshr i32 %word, 12
  %s1 = and i32 %s1a, 63
  %s2a = lshr i32 %word, 6
  %s2 = and i32 %s2a, 63
  %s3 = and i32 %word, 63
  %tp0 = getelementptr i8, ptr @t.base64, i32 %s0
  %tp1 = getelementptr i8, ptr @t.base64, i32 %s1
  %tp2 = getelementptr i8, ptr @t.base64, i32 %s2
  %tp3 = getelementptr i8, ptr @t.base64, i32 %s3
  %tc0 = load i8, ptr %tp0
  %tc1 = load i8, ptr %tp1
  %tc2 = load i8, ptr %tp2
  %tc3 = load i8, ptr %tp3
  %oc2 = select i1 %have1, i8 %tc2, i8 61
  %oc3 = select i1 %have2, i8 %tc3, i8 61
  %dst0 = getelementptr i8, ptr %buf, i64 %pos
  %dst1 = getelementptr i8, ptr %dst0, i64 1
  %dst2 = getelementptr i8, ptr %dst0, i64 2
  %dst3 = getelementptr i8, ptr %dst0, i64 3
  store i8 %tc0, ptr %dst0
  store i8 %tc1, ptr %dst1
  store i8 %oc2, ptr %dst2
  store i8 %oc3, ptr %dst3
  %next = add i64 %i, 3
  %pn = add i64 %pos, 4
  br label %loop
done:
  %out = call ptr @j_str(ptr %buf, i64 %pos)
  ret ptr %out
}

define i32 @t_base64_digit(i8 %c) {
entry:
  %u = sub i8 %c, 65
  %upper = icmp ule i8 %u, 25
  br i1 %upper, label %up, label %lowercheck
up:
  %uv = zext i8 %u to i32
  ret i32 %uv
lowercheck:
  %l = sub i8 %c, 97
  %lower = icmp ule i8 %l, 25
  br i1 %lower, label %low, label %numcheck
low:
  %lv = zext i8 %l to i32
  %ln = add i32 %lv, 26
  ret i32 %ln
numcheck:
  %d = sub i8 %c, 48
  %digit = icmp ule i8 %d, 9
  br i1 %digit, label %num, label %symbols
num:
  %dv = zext i8 %d to i32
  %dn = add i32 %dv, 52
  ret i32 %dn
symbols:
  switch i8 %c, label %bad [i8 43, label %plus i8 47, label %slash]
plus:
  ret i32 62
slash:
  ret i32 63
bad:
  ret i32 -1
}

define ptr @t_base64d(ptr %input) {
entry:
  %s = call ptr @b_data(ptr %input)
  %n = call i64 @b_len(ptr %input)
  %cap = add i64 %n, 1
  %buf = call ptr @j_alloc(i64 %cap)
  br label %loop
loop:
  %i = phi i64 [0, %entry], [%next, %advance]
  %pos = phi i64 [0, %entry], [%pn, %advance]
  %word = phi i32 [0, %entry], [%joined, %advance]
  %bits = phi i32 [0, %entry], [%remaining, %advance]
  %more = icmp slt i64 %i, %n
  br i1 %more, label %body, label %tail
body:
  %src = getelementptr i8, ptr %s, i64 %i
  %c = load i8, ptr %src
  %padding = icmp eq i8 %c, 61
  br i1 %padding, label %tail, label %digit
digit:
  %v = call i32 @t_base64_digit(i8 %c)
  %valid = icmp sge i32 %v, 0
  br i1 %valid, label %decode, label %bad
decode:
  %shifted = shl i32 %word, 6
  %joined = or i32 %shifted, %v
  %newbits = add i32 %bits, 6
  %emit = icmp sge i32 %newbits, 8
  br i1 %emit, label %write, label %nowrite
write:
  %rem = sub i32 %newbits, 8
  %byteword = lshr i32 %joined, %rem
  %byte = trunc i32 %byteword to i8
  %dst = getelementptr i8, ptr %buf, i64 %pos
  store i8 %byte, ptr %dst
  %written = add i64 %pos, 1
  br label %advance
nowrite:
  br label %advance
advance:
  %remaining = phi i32 [%rem, %write], [%newbits, %nowrite]
  %pn = phi i64 [%written, %write], [%pos, %nowrite]
  %next = add i64 %i, 1
  br label %loop
tail:
  %invalidtail = icmp eq i32 %bits, 6
  br i1 %invalidtail, label %badtail, label %done
bad:
  call void @b_type_error(ptr %input, ptr @t.errbase64)
  br label %failed
badtail:
  call void @b_type_error(ptr %input, ptr @t.errbasetail)
  br label %failed
failed:
  %nil = call ptr @j_null()
  ret ptr %nil
done:
  %out = call ptr @j_str(ptr %buf, i64 %pos)
  ret ptr %out
}

define ptr @t_csv(ptr %input, i1 %tsv) {
entry:
  %tag = call i32 @b_tag(ptr %input)
  %array = icmp eq i32 %tag, 5
  br i1 %array, label %start, label %bad
bad:
  %msg = select i1 %tsv, ptr @t.errtsv, ptr @t.errcsv
  call void @b_type_error(ptr %input, ptr %msg)
  %nil = call ptr @j_null()
  ret ptr %nil
start:
  %json = call ptr @j_dump(ptr %input, i32 0)
  %size0 = call i64 @b_len(ptr %json)
  %size1 = mul i64 %size0, 6
  %size = add i64 %size1, 32
  %buf = call ptr @j_alloc(i64 %size)
  %n = call i64 @b_len(ptr %input)
  %sep = select i1 %tsv, i8 9, i8 44
  br label %outer
outer:
  %i = phi i64 [0, %start], [%next, %advance]
  %pos = phi i64 [0, %start], [%afterfield, %advance]
  %more = icmp slt i64 %i, %n
  br i1 %more, label %body, label %done
body:
  %first = icmp eq i64 %i, 0
  br i1 %first, label %firstfield, label %separator
separator:
  %sepp = getelementptr i8, ptr %buf, i64 %pos
  store i8 %sep, ptr %sepp
  %sepnext = add i64 %pos, 1
  br label %field
firstfield:
  br label %field
field:
  %fieldpos = phi i64 [%sepnext, %separator], [%pos, %firstfield]
  %value = call ptr @j_at(ptr %input, i64 %i)
  %vt = call i32 @b_tag(ptr %value)
  %isnull = icmp eq i32 %vt, 0
  br i1 %isnull, label %emptyfield, label %nonempty
nonempty:
  %isstr = icmp eq i32 %vt, 4
  %string = call ptr @b_tostring(ptr %value)
  %s = call ptr @b_data(ptr %string)
  %sn = call i64 @b_len(ptr %string)
  %csv = xor i1 %tsv, true
  %quoted = and i1 %csv, %isstr
  br i1 %quoted, label %openquote, label %noquote
openquote:
  %qp = getelementptr i8, ptr %buf, i64 %fieldpos
  store i8 34, ptr %qp
  %qnext = add i64 %fieldpos, 1
  br label %inner
noquote:
  br label %inner
inner:
  %j = phi i64 [0, %openquote], [0, %noquote], [%jn, %charadvance]
  %p = phi i64 [%qnext, %openquote], [%fieldpos, %noquote], [%pn, %charadvance]
  %jm = icmp slt i64 %j, %sn
  br i1 %jm, label %charbody, label %closequote
charbody:
  %src = getelementptr i8, ptr %s, i64 %j
  %c = load i8, ptr %src
  %dst = getelementptr i8, ptr %buf, i64 %p
  br i1 %tsv, label %tsvchar, label %csvchar
tsvchar:
  switch i8 %c, label %plain [i8 9, label %tab i8 10, label %newline i8 13, label %return i8 92, label %backslash]
tab:
  br label %escape
newline:
  br label %escape
return:
  br label %escape
backslash:
  br label %escape
escape:
  %escaped = phi i8 [116, %tab], [110, %newline], [114, %return], [92, %backslash]
  store i8 92, ptr %dst
  %ep = getelementptr i8, ptr %dst, i64 1
  store i8 %escaped, ptr %ep
  br label %charadvance
csvchar:
  %q = icmp eq i8 %c, 34
  %double = and i1 %quoted, %q
  br i1 %double, label %doublequote, label %plain
doublequote:
  store i8 34, ptr %dst
  %dq = getelementptr i8, ptr %dst, i64 1
  store i8 34, ptr %dq
  br label %charadvance
plain:
  store i8 %c, ptr %dst
  br label %charadvance
charadvance:
  %written = phi i64 [2, %escape], [2, %doublequote], [1, %plain]
  %pn = add i64 %p, %written
  %jn = add i64 %j, 1
  br label %inner
closequote:
  br i1 %quoted, label %close, label %closed
close:
  %endq = getelementptr i8, ptr %buf, i64 %p
  store i8 34, ptr %endq
  %afterquote = add i64 %p, 1
  br label %advance
closed:
  br label %advance
emptyfield:
  br label %advance
advance:
  %afterfield = phi i64 [%afterquote, %close], [%p, %closed], [%fieldpos, %emptyfield]
  %next = add i64 %i, 1
  br label %outer
done:
  %out = call ptr @j_str(ptr %buf, i64 %pos)
  ret ptr %out
}

define ptr @t_sh_scalar(ptr %input) {
entry:
  %tag = call i32 @b_tag(ptr %input)
  %str = icmp eq i32 %tag, 4
  br i1 %str, label %string, label %plain
plain:
  %s = call ptr @b_tostring(ptr %input)
  ret ptr %s
string:
  %d = call ptr @b_data(ptr %input)
  %n = call i64 @b_len(ptr %input)
  %size0 = mul i64 %n, 4
  %size = add i64 %size0, 3
  %buf = call ptr @j_alloc(i64 %size)
  store i8 39, ptr %buf
  br label %loop
loop:
  %i = phi i64 [0, %string], [%next, %advance]
  %pos = phi i64 [1, %string], [%pn, %advance]
  %more = icmp slt i64 %i, %n
  br i1 %more, label %body, label %done
body:
  %src = getelementptr i8, ptr %d, i64 %i
  %c = load i8, ptr %src
  %dst = getelementptr i8, ptr %buf, i64 %pos
  %quote = icmp eq i8 %c, 39
  br i1 %quote, label %escaped, label %literal
escaped:
  call void @j_copy(ptr %dst, ptr @t.shquote, i64 4)
  br label %advance
literal:
  store i8 %c, ptr %dst
  br label %advance
advance:
  %written = phi i64 [4, %escaped], [1, %literal]
  %pn = add i64 %pos, %written
  %next = add i64 %i, 1
  br label %loop
done:
  %endp = getelementptr i8, ptr %buf, i64 %pos
  store i8 39, ptr %endp
  %len = add i64 %pos, 1
  %out = call ptr @j_str(ptr %buf, i64 %len)
  ret ptr %out
}

define ptr @t_sh(ptr %input) {
entry:
  %tag = call i32 @b_tag(ptr %input)
  %array = icmp eq i32 %tag, 5
  br i1 %array, label %start, label %scalar
scalar:
  %s = call ptr @t_sh_scalar(ptr %input)
  ret ptr %s
start:
  %n = call i64 @b_len(ptr %input)
  %values = call ptr @j_array()
  br label %loop
loop:
  %i = phi i64 [0, %start], [%next, %body]
  %more = icmp slt i64 %i, %n
  br i1 %more, label %body, label %done
body:
  %v = call ptr @j_at(ptr %input, i64 %i)
  %e = call ptr @t_sh_scalar(ptr %v)
  call void @j_push(ptr %values, ptr %e)
  %next = add i64 %i, 1
  br label %loop
done:
  %space = call ptr @j_cstr(ptr @t.space)
  %out = call ptr @t_join(ptr %values, ptr %space)
  ret ptr %out
}

define ptr @j_text_names() {
entry:
  ret ptr @t.names
}

define i1 @j_text_known(ptr %name, i64 %arity) {
entry:
  %id = call i32 @b_find(ptr %name, ptr @t.names)
  %known = icmp sge i32 %id, 0
  br i1 %known, label %check, label %internal
internal:
  %is = call i1 @j_is(ptr %name, ptr @t.strindices)
  %one = icmp eq i64 %arity, 1
  %ir = and i1 %is, %one
  ret i1 %ir
check:
  switch i32 %id, label %zero [i32 0, label %onetwo i32 1, label %arg i32 6, label %arg i32 7, label %arg i32 8, label %arg i32 9, label %arg i32 10, label %arg i32 24, label %arg]
zero:
  %z = icmp eq i64 %arity, 0
  ret i1 %z
arg:
  %a = icmp eq i64 %arity, 1
  ret i1 %a
onetwo:
  %o = icmp eq i64 %arity, 1
  %t = icmp eq i64 %arity, 2
  %r = or i1 %o, %t
  ret i1 %r
}
