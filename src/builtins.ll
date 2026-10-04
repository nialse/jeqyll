%BValue = type { i32, i32, double, i64, i64, ptr, ptr }

@j_error = external global ptr
@b.names = private constant [572 x i8] c"empty\00error\00not\00type\00length\00utf8bytelength\00tostring\00tojson\00fromjson\00tonumber\00toboolean\00arrays\00objects\00iterables\00booleans\00numbers\00strings\00nulls\00values\00scalars\00keys\00keys_unsorted\00has\00in\00contains\00inside\00reverse\00sort\00sort_by\00group_by\00unique\00unique_by\00min\00max\00min_by\00max_by\00add\00flatten\00map\00map_values\00select\00range\00any\00all\00first\00last\00nth\00limit\00skip\00isempty\00to_entries\00from_entries\00with_entries\00transpose\00combinations\00getpath\00setpath\00delpaths\00paths\00leaf_paths\00recurse\00recurse_down\00walk\00while\00until\00bsearch\00indices\00index\00rindex\00INDEX\00IN\00builtins\00have_decnum\00have_literal_numbers\00\00"
@b.null = private constant [5 x i8] c"null\00"
@b.boolean = private constant [8 x i8] c"boolean\00"
@b.number = private constant [7 x i8] c"number\00"
@b.string = private constant [7 x i8] c"string\00"
@b.array = private constant [6 x i8] c"array\00"
@b.object = private constant [7 x i8] c"object\00"
@b.true = private constant [5 x i8] c"true\00"
@b.false = private constant [6 x i8] c"false\00"
@b.empty = private constant [1 x i8] zeroinitializer
@b.open = private constant [3 x i8] c" (\00"
@b.close = private constant [3 x i8] c") \00"
@b.key = private constant [4 x i8] c"key\00"
@b.value = private constant [6 x i8] c"value\00"
@b.Key = private constant [4 x i8] c"Key\00"
@b.Value = private constant [6 x i8] c"Value\00"
@b.name = private constant [5 x i8] c"name\00"
@b.Name = private constant [5 x i8] c"Name\00"
@b.errlen = private constant [22 x i8] c"has no length defined\00"
@b.errutf8 = private constant [36 x i8] c"only strings have UTF-8 byte length\00"
@b.errnumber = private constant [29 x i8] c"cannot be parsed as a number\00"
@b.errboolean = private constant [30 x i8] c"cannot be parsed as a boolean\00"
@b.erriter = private constant [19 x i8] c"cannot be iterated\00"
@b.errflat = private constant [35 x i8] c"flatten depth must not be negative\00"
@b.errnth = private constant [37 x i8] c"nth doesn't support negative indices\00"
@b.errpath = private constant [32 x i8] c"Path must be specified as array\00"
@b.errdeep = private constant [20 x i8] c"Exceeds depth limit\00"
@b.errskip = private constant [36 x i8] c"skip doesn't support negative count\00"
@b.errlimit = private constant [37 x i8] c"limit doesn't support negative count\00"
@b.errpaths = private constant [36 x i8] c"Paths must be specified as an array\00"
@b.errpathtoo = private constant [14 x i8] c"Path too deep\00"
@b.errcontainsdeep = private constant [27 x i8] c"Containment check too deep\00"
@b.errsearch = private constant [24 x i8] c"cannot be searched from\00"
@b.errupdatearray = private constant [44 x i8] c"Cannot update field at array index of array\00"
@b.slash = private constant [2 x i8] c"/\00"
@b.errextrajson = private constant [29 x i8] c"Unexpected extra JSON values\00"
@b.errkeys = private constant [12 x i8] c"has no keys\00"
@b.errsort = private constant [40 x i8] c"cannot be sorted, as it is not an array\00"
@b.errhasprefix = private constant [22 x i8] c"Cannot check whether \00"
@b.errhasmiddle = private constant [8 x i8] c" has a \00"
@b.errhassuffix = private constant [5 x i8] c" key\00"
@b.errcontain = private constant [15 x i8] c"cannot contain\00"

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
declare ptr @j_dump(ptr, i32)
declare ptr @j_binary(i32, ptr, ptr)
declare void @j_fail(ptr)
declare ptr @j_eval(ptr, ptr, ptr)
declare ptr @j_eval_take(ptr, ptr, ptr, i64)
declare ptr @j_text_builtin(ptr, ptr, ptr, ptr)
declare ptr @j_math_builtin(ptr, ptr, ptr, ptr)
declare ptr @j_time_builtin(ptr, ptr, ptr, ptr)
declare ptr @j_stream_builtin(ptr, ptr, ptr, ptr)
declare ptr @j_cli_builtin(ptr, ptr, ptr, ptr)
declare ptr @j_regex_builtin(ptr, ptr, ptr, ptr)
declare double @llvm.fabs.f64(double)
declare ptr @j_negate(ptr)
declare void @j_type_error(ptr, ptr)
declare void @j_type_error2(ptr, ptr, ptr)
declare i1 @j_text_known(ptr, i64)
declare i1 @j_math_known(ptr, i64)
declare i1 @j_stream_known(ptr, i64)
declare i1 @j_time_known(ptr, i64)
declare i1 @j_regex_known(ptr, i64)
declare i1 @j_cli_known(ptr, i64)
declare ptr @j_text_names()
declare ptr @j_math_names()
declare ptr @j_stream_names()
declare ptr @j_time_names()
declare ptr @j_regex_names()
declare ptr @j_cli_names()
declare ptr @b_delete_many(ptr, ptr)

define i32 @b_tag(ptr %v) {
entry:
  %isnull = icmp eq ptr %v, null
  br i1 %isnull, label %zero, label %read
zero:
  ret i32 0
read:
  %p = getelementptr %BValue, ptr %v, i32 0, i32 0
  %t = load i32, ptr %p
  ret i32 %t
}

define i64 @b_len(ptr %v) {
entry:
  %p = getelementptr %BValue, ptr %v, i32 0, i32 3
  %n = load i64, ptr %p
  ret i64 %n
}

define ptr @b_data(ptr %v) {
entry:
  %p = getelementptr %BValue, ptr %v, i32 0, i32 5
  %d = load ptr, ptr %p
  ret ptr %d
}

define double @b_number(ptr %v) {
entry:
  %p = getelementptr %BValue, ptr %v, i32 0, i32 2
  %d = load double, ptr %p
  ret double %d
}

define ptr @b_one(ptr %v) {
entry:
  %r = call ptr @j_array()
  %error = load ptr, ptr @j_error
  %valid = icmp eq ptr %error, null
  br i1 %valid, label %put, label %done
put:
  call void @j_push(ptr %r, ptr %v)
  br label %done
done:
  ret ptr %r
}

define void @b_pushvalid(ptr %out, ptr %value) {
entry:
  %error = load ptr, ptr @j_error
  %valid = icmp eq ptr %error, null
  br i1 %valid, label %put, label %done
put:
  call void @j_push(ptr %out, ptr %value)
  br label %done
done:
  ret void
}

define void @b_extend(ptr %dst, ptr %src) {
entry:
  %n = call i64 @b_len(ptr %src)
  br label %loop
loop:
  %i = phi i64 [0, %entry], [%next, %body]
  %more = icmp slt i64 %i, %n
  br i1 %more, label %body, label %done
body:
  %v = call ptr @j_at(ptr %src, i64 %i)
  call void @j_push(ptr %dst, ptr %v)
  %next = add i64 %i, 1
  br label %loop
done:
  ret void
}

define ptr @b_arg(ptr %args, i64 %i, ptr %input, ptr %env) {
entry:
  %ast = call ptr @j_at(ptr %args, i64 %i)
  %r = call ptr @j_eval(ptr %ast, ptr %input, ptr %env)
  ret ptr %r
}

define ptr @b_arg_take(ptr %args, i64 %i, ptr %input, ptr %env, i64 %count) {
entry:
  %ast = call ptr @j_at(ptr %args, i64 %i)
  %r = call ptr @j_eval_take(ptr %ast, ptr %input, ptr %env, i64 %count)
  ret ptr %r
}

define i32 @b_find(ptr %name, ptr %table) {
entry:
  br label %loop
loop:
  %p = phi ptr [%table, %entry], [%next, %advance]
  %i = phi i32 [0, %entry], [%inext, %advance]
  %c = load i8, ptr %p
  %end = icmp eq i8 %c, 0
  br i1 %end, label %missing, label %compare
compare:
  %same = call i1 @j_is(ptr %name, ptr %p)
  br i1 %same, label %found, label %advance
advance:
  %len = call i64 @j_strlen(ptr %p)
  %step = add i64 %len, 1
  %next = getelementptr i8, ptr %p, i64 %step
  %inext = add i32 %i, 1
  br label %loop
found:
  ret i32 %i
missing:
  ret i32 -1
}

define ptr @b_typename(ptr %v) {
entry:
  %t = call i32 @b_tag(ptr %v)
  switch i32 %t, label %null [i32 1, label %bool i32 2, label %bool i32 3, label %num i32 4, label %str i32 5, label %arr i32 6, label %obj]
null:
  ret ptr @b.null
bool:
  ret ptr @b.boolean
num:
  ret ptr @b.number
str:
  ret ptr @b.string
arr:
  ret ptr @b.array
obj:
  ret ptr @b.object
}

define ptr @b_tostring(ptr %v) {
entry:
  %t = call i32 @b_tag(ptr %v)
  %is = icmp eq i32 %t, 4
  br i1 %is, label %same, label %dump
same:
  ret ptr %v
dump:
  %s = call ptr @j_dump(ptr %v, i32 0)
  ret ptr %s
}

define void @b_type_error(ptr %v, ptr %suffix) {
entry:
  call void @j_type_error(ptr %v, ptr %suffix)
  ret void
}

define ptr @b_values(ptr %v) {
entry:
  %t = call i32 @b_tag(ptr %v)
  %a = icmp eq i32 %t, 5
  br i1 %a, label %same, label %other
same:
  ret ptr %v
other:
  %r = call ptr @j_array()
  %o = icmp eq i32 %t, 6
  br i1 %o, label %obj, label %bad
obj:
  %n = call i64 @b_len(ptr %v)
  %d = call ptr @b_data(ptr %v)
  br label %loop
loop:
  %i = phi i64 [0, %obj], [%next, %body]
  %more = icmp slt i64 %i, %n
  br i1 %more, label %body, label %done
body:
  %twice = shl i64 %i, 1
  %vi = add i64 %twice, 1
  %p = getelementptr ptr, ptr %d, i64 %vi
  %x = load ptr, ptr %p
  call void @j_push(ptr %r, ptr %x)
  %next = add i64 %i, 1
  br label %loop
bad:
  call void @b_type_error(ptr %v, ptr @b.erriter)
  br label %done
done:
  ret ptr %r
}

define ptr @b_keys(ptr %v, i1 %sort) {
entry:
  %t = call i32 @b_tag(ptr %v)
  %r = call ptr @j_array()
  %isarray = icmp eq i32 %t, 5
  %isobject = icmp eq i32 %t, 6
  %valid = or i1 %isarray, %isobject
  br i1 %valid, label %start, label %bad
bad:
  call void @b_type_error(ptr %v, ptr @b.errkeys)
  ret ptr %r
start:
  %n = call i64 @b_len(ptr %v)
  %d = call ptr @b_data(ptr %v)
  %obj = icmp eq i32 %t, 6
  br label %loop
loop:
  %i = phi i64 [0, %start], [%next, %append]
  %more = icmp slt i64 %i, %n
  br i1 %more, label %body, label %done
body:
  br i1 %obj, label %okey, label %akey
okey:
  %twice = shl i64 %i, 1
  %p = getelementptr ptr, ptr %d, i64 %twice
  %k = load ptr, ptr %p
  br label %append
akey:
  %f = sitofp i64 %i to double
  %a = call ptr @j_num(double %f)
  br label %append
append:
  %key = phi ptr [%k, %okey], [%a, %akey]
  call void @j_push(ptr %r, ptr %key)
  %next = add i64 %i, 1
  br label %loop
done:
  br i1 %sort, label %sorted, label %return
sorted:
  call void @b_sort_inplace(ptr %r, ptr %r)
  br label %return
return:
  ret ptr %r
}

define void @b_sort_inplace(ptr %values, ptr %keys) {
entry:
  %n = call i64 @b_len(ptr %values)
  %vd = call ptr @b_data(ptr %values)
  %kd = call ptr @b_data(ptr %keys)
  %same = icmp eq ptr %values, %keys
  br label %outer
outer:
  %i = phi i64 [1, %entry], [%inext, %insert]
  %more = icmp slt i64 %i, %n
  br i1 %more, label %prepare, label %done
prepare:
  %vp = getelementptr ptr, ptr %vd, i64 %i
  %kp = getelementptr ptr, ptr %kd, i64 %i
  %value = load ptr, ptr %vp
  %key = load ptr, ptr %kp
  br label %inner
inner:
  %j = phi i64 [%i, %prepare], [%prev, %shift]
  %nonzero = icmp sgt i64 %j, 0
  br i1 %nonzero, label %compare, label %insert
compare:
  %prev = sub i64 %j, 1
  %prevkp = getelementptr ptr, ptr %kd, i64 %prev
  %prevkey = load ptr, ptr %prevkp
  %cmp = call i32 @j_cmp(ptr %prevkey, ptr %key)
  %greater = icmp sgt i32 %cmp, 0
  br i1 %greater, label %shift, label %insert
shift:
  %prevvp = getelementptr ptr, ptr %vd, i64 %prev
  %prevvalue = load ptr, ptr %prevvp
  %targetvp = getelementptr ptr, ptr %vd, i64 %j
  %targetkp = getelementptr ptr, ptr %kd, i64 %j
  store ptr %prevvalue, ptr %targetvp
  store ptr %prevkey, ptr %targetkp
  br label %inner
insert:
  %destvp = getelementptr ptr, ptr %vd, i64 %j
  %destkp = getelementptr ptr, ptr %kd, i64 %j
  store ptr %value, ptr %destvp
  store ptr %key, ptr %destkp
  %inext = add i64 %i, 1
  br label %outer
done:
  ret void
}

define i1 @b_bytes_equal(ptr %a, ptr %b, i64 %n) {
entry:
  br label %loop
loop:
  %i = phi i64 [0, %entry], [%next, %body]
  %more = icmp ult i64 %i, %n
  br i1 %more, label %body, label %yes
body:
  %ap = getelementptr i8, ptr %a, i64 %i
  %bp = getelementptr i8, ptr %b, i64 %i
  %ac = load i8, ptr %ap
  %bc = load i8, ptr %bp
  %eq = icmp eq i8 %ac, %bc
  %next = add i64 %i, 1
  br i1 %eq, label %loop, label %no
yes:
  ret i1 true
no:
  ret i1 false
}

define i64 @b_search_bytes(ptr %a, i64 %an, ptr %b, i64 %bn, i64 %start) {
entry:
  %last = sub i64 %an, %bn
  br label %loop
loop:
  %i = phi i64 [%start, %entry], [%next, %body]
  %more = icmp sle i64 %i, %last
  br i1 %more, label %body, label %no
body:
  %p = getelementptr i8, ptr %a, i64 %i
  %same = call i1 @b_bytes_equal(ptr %p, ptr %b, i64 %bn)
  %next = add i64 %i, 1
  br i1 %same, label %yes, label %loop
yes:
  ret i64 %i
no:
  ret i64 -1
}

define i64 @b_utf8_length(ptr %s, i64 %n) {
entry:
  br label %loop
loop:
  %i = phi i64 [0, %entry], [%next, %body]
  %count = phi i64 [0, %entry], [%countnext, %body]
  %more = icmp ult i64 %i, %n
  br i1 %more, label %body, label %done
body:
  %p = getelementptr i8, ptr %s, i64 %i
  %c = load i8, ptr %p
  %masked = and i8 %c, -64
  %lead = icmp ne i8 %masked, -128
  %inc = zext i1 %lead to i64
  %countnext = add i64 %count, %inc
  %next = add i64 %i, 1
  br label %loop
done:
  ret i64 %count
}

define i1 @b_contains(ptr %a, ptr %b) {
entry:
  %r = call i1 @b_contains_depth(ptr %a, ptr %b, i64 0)
  ret i1 %r
}

define i1 @b_contains_depth(ptr %a, ptr %b, i64 %depth) {
entry:
  %too = icmp sge i64 %depth, 10000
  br i1 %too, label %deep, label %start
deep:
  call void @j_fail(ptr @b.errcontainsdeep)
  ret i1 false
start:
  %dn = add i64 %depth, 1
  %at = call i32 @b_tag(ptr %a)
  %bt = call i32 @b_tag(ptr %b)
  %same = icmp eq i32 %at, %bt
  br i1 %same, label %types, label %no
types:
  switch i32 %at, label %scalar [i32 4, label %string i32 5, label %array i32 6, label %object]
string:
  %ad = call ptr @b_data(ptr %a)
  %bd = call ptr @b_data(ptr %b)
  %an = call i64 @b_len(ptr %a)
  %bn = call i64 @b_len(ptr %b)
  %found = call i64 @b_search_bytes(ptr %ad, i64 %an, ptr %bd, i64 %bn, i64 0)
  %ok = icmp sge i64 %found, 0
  ret i1 %ok
scalar:
  %cmp = call i32 @j_cmp(ptr %a, ptr %b)
  %eq = icmp eq i32 %cmp, 0
  ret i1 %eq
array:
  %alen = call i64 @b_len(ptr %a)
  %blen = call i64 @b_len(ptr %b)
  br label %aloop
aloop:
  %bi = phi i64 [0, %array], [%bnext, %amatch]
  %bmore = icmp slt i64 %bi, %blen
  br i1 %bmore, label %asearch, label %yes
asearch:
  %bv = call ptr @j_at(ptr %b, i64 %bi)
  br label %ainner
ainner:
  %ai = phi i64 [0, %asearch], [%anext, %acompare]
  %amore = icmp slt i64 %ai, %alen
  br i1 %amore, label %acompare, label %no
acompare:
  %av = call ptr @j_at(ptr %a, i64 %ai)
  %contained = call i1 @b_contains_depth(ptr %av, ptr %bv, i64 %dn)
  %anext = add i64 %ai, 1
  br i1 %contained, label %amatch, label %ainner
amatch:
  %bnext = add i64 %bi, 1
  br label %aloop
object:
  %olen = call i64 @b_len(ptr %b)
  %od = call ptr @b_data(ptr %b)
  br label %oloop
oloop:
  %oi = phi i64 [0, %object], [%onext, %ocompare]
  %omore = icmp slt i64 %oi, %olen
  br i1 %omore, label %obody, label %yes
obody:
  %twice = shl i64 %oi, 1
  %vi = add i64 %twice, 1
  %kp = getelementptr ptr, ptr %od, i64 %twice
  %vp = getelementptr ptr, ptr %od, i64 %vi
  %key = load ptr, ptr %kp
  %value = load ptr, ptr %vp
  %exists = call i1 @b_has(ptr %a, ptr %key)
  br i1 %exists, label %ocompare, label %no
ocompare:
  %other = call ptr @j_get(ptr %a, ptr %key)
  %oc = call i1 @b_contains_depth(ptr %other, ptr %value, i64 %dn)
  %onext = add i64 %oi, 1
  br i1 %oc, label %oloop, label %no
yes:
  ret i1 true
no:
  ret i1 false
}

define i1 @b_has(ptr %v, ptr %key) {
entry:
  %t = call i32 @b_tag(ptr %v)
  %kt = call i32 @b_tag(ptr %key)
  switch i32 %t, label %bad [i32 0, label %no i32 5, label %array i32 6, label %object]
array:
  %numeric = icmp eq i32 %kt, 3
  br i1 %numeric, label %arraycheck, label %bad
arraycheck:
  %f = call double @b_number(ptr %key)
  %n = call i64 @b_len(ptr %v)
  %nf = sitofp i64 %n to double
  %lo = fcmp oge double %f, 0.000000e+00
  %hi = fcmp olt double %f, %nf
  %ok = and i1 %lo, %hi
  ret i1 %ok
object:
  %string = icmp eq i32 %kt, 4
  br i1 %string, label %objcheck, label %bad
objcheck:
  %len = call i64 @b_len(ptr %v)
  %d = call ptr @b_data(ptr %v)
  br label %loop
loop:
  %i = phi i64 [0, %objcheck], [%next, %body]
  %more = icmp slt i64 %i, %len
  br i1 %more, label %body, label %no
body:
  %ix = shl i64 %i, 1
  %p = getelementptr ptr, ptr %d, i64 %ix
  %k = load ptr, ptr %p
  %cmp = call i32 @j_cmp(ptr %k, ptr %key)
  %eq = icmp eq i32 %cmp, 0
  %next = add i64 %i, 1
  br i1 %eq, label %yes, label %loop
yes:
  ret i1 true
bad:
  %prefix = call ptr @j_cstr(ptr @b.errhasprefix)
  %tn = call ptr @b_typename(ptr %v)
  %ts = call ptr @j_cstr(ptr %tn)
  %a = call ptr @j_binary(i32 0, ptr %prefix, ptr %ts)
  %middle = call ptr @j_cstr(ptr @b.errhasmiddle)
  %b = call ptr @j_binary(i32 0, ptr %a, ptr %middle)
  %kn = call ptr @b_typename(ptr %key)
  %ks = call ptr @j_cstr(ptr %kn)
  %c = call ptr @j_binary(i32 0, ptr %b, ptr %ks)
  %suffix = call ptr @j_cstr(ptr @b.errhassuffix)
  %message = call ptr @j_binary(i32 0, ptr %c, ptr %suffix)
  store ptr %message, ptr @j_error
  ret i1 false
no:
  ret i1 false
}

define void @b_flatten(ptr %v, i64 %depth, ptr %out) {
entry:
  %values = call ptr @b_values(ptr %v)
  %n = call i64 @b_len(ptr %values)
  br label %loop
loop:
  %i = phi i64 [0, %entry], [%next, %advance]
  %more = icmp slt i64 %i, %n
  br i1 %more, label %body, label %done
body:
  %x = call ptr @j_at(ptr %values, i64 %i)
  %t = call i32 @b_tag(ptr %x)
  %arr = icmp eq i32 %t, 5
  %go = icmp ne i64 %depth, 0
  %recurse = and i1 %arr, %go
  br i1 %recurse, label %nested, label %append
nested:
  %dn = sub i64 %depth, 1
  call void @b_flatten(ptr %x, i64 %dn, ptr %out)
  br label %advance
append:
  call void @j_push(ptr %out, ptr %x)
  br label %advance
advance:
  %next = add i64 %i, 1
  br label %loop
done:
  ret void
}

define ptr @b_entries(ptr %v) {
entry:
  %r = call ptr @j_array()
  %keys = call ptr @b_keys(ptr %v, i1 false)
  %n = call i64 @b_len(ptr %keys)
  %ks = call ptr @j_cstr(ptr @b.key)
  %vs = call ptr @j_cstr(ptr @b.value)
  br label %loop
loop:
  %i = phi i64 [0, %entry], [%next, %body]
  %more = icmp slt i64 %i, %n
  br i1 %more, label %body, label %done
body:
  %k = call ptr @j_at(ptr %keys, i64 %i)
  %x = call ptr @j_get(ptr %v, ptr %k)
  %o = call ptr @j_object()
  call void @j_put(ptr %o, ptr %ks, ptr %k)
  call void @j_put(ptr %o, ptr %vs, ptr %x)
  call void @j_push(ptr %r, ptr %o)
  %next = add i64 %i, 1
  br label %loop
done:
  ret ptr %r
}

define ptr @b_from_entries(ptr %v) {
entry:
  %r = call ptr @j_object()
  %n = call i64 @b_len(ptr %v)
  %key = call ptr @j_cstr(ptr @b.key)
  %Key = call ptr @j_cstr(ptr @b.Key)
  %name = call ptr @j_cstr(ptr @b.name)
  %Name = call ptr @j_cstr(ptr @b.Name)
  %value = call ptr @j_cstr(ptr @b.value)
  %Value = call ptr @j_cstr(ptr @b.Value)
  br label %loop
loop:
  %i = phi i64 [0, %entry], [%next, %put]
  %more = icmp slt i64 %i, %n
  br i1 %more, label %body, label %done
body:
  %entryv = call ptr @j_at(ptr %v, i64 %i)
  %k1 = call ptr @j_get(ptr %entryv, ptr %key)
  %tr1 = call i1 @j_truth(ptr %k1)
  br i1 %tr1, label %gotkey, label %key2
key2:
  %k2 = call ptr @j_get(ptr %entryv, ptr %Key)
  %tr2 = call i1 @j_truth(ptr %k2)
  br i1 %tr2, label %gotkey, label %key3
key3:
  %k3 = call ptr @j_get(ptr %entryv, ptr %name)
  %tr3 = call i1 @j_truth(ptr %k3)
  br i1 %tr3, label %gotkey, label %key4
key4:
  %k4 = call ptr @j_get(ptr %entryv, ptr %Name)
  br label %gotkey
gotkey:
  %k = phi ptr [%k1, %body], [%k2, %key2], [%k3, %key3], [%k4, %key4]
  %hasvalue = call i1 @b_has(ptr %entryv, ptr %value)
  br i1 %hasvalue, label %lower, label %upper
lower:
  %v1 = call ptr @j_get(ptr %entryv, ptr %value)
  br label %put
upper:
  %v2 = call ptr @j_get(ptr %entryv, ptr %Value)
  br label %put
put:
  %x = phi ptr [%v1, %lower], [%v2, %upper]
  call void @j_put(ptr %r, ptr %k, ptr %x)
  %next = add i64 %i, 1
  br label %loop
done:
  ret ptr %r
}

define ptr @b_getpath(ptr %v, ptr %path) {
entry:
  %n = call i64 @b_len(ptr %path)
  %too = icmp sgt i64 %n, 10000
  br i1 %too, label %deep, label %start
deep:
  call void @j_fail(ptr @b.errpathtoo)
  %nil = call ptr @j_null()
  ret ptr %nil
start:
  br label %loop
loop:
  %i = phi i64 [0, %start], [%next, %body]
  %cur = phi ptr [%v, %start], [%child, %body]
  %more = icmp slt i64 %i, %n
  br i1 %more, label %body, label %done
body:
  %key = call ptr @j_at(ptr %path, i64 %i)
  %child = call ptr @j_get(ptr %cur, ptr %key)
  %next = add i64 %i, 1
  br label %loop
done:
  ret ptr %cur
}

define ptr @b_setpath(ptr %v, ptr %path, i64 %pos, ptr %value) {
entry:
  %n = call i64 @b_len(ptr %path)
  %too = icmp sgt i64 %n, 10000
  br i1 %too, label %deep, label %start
deep:
  call void @j_fail(ptr @b.errpathtoo)
  %deepnull = call ptr @j_null()
  ret ptr %deepnull
start:
  %done = icmp sge i64 %pos, %n
  br i1 %done, label %replace, label %key
replace:
  ret ptr %value
key:
  %k = call ptr @j_at(ptr %path, i64 %pos)
  %kt = call i32 @b_tag(ptr %k)
  %vt = call i32 @b_tag(ptr %v)
  %nil = icmp eq i32 %vt, 0
  %num = icmp eq i32 %kt, 3
  br i1 %nil, label %fresh, label %copy
fresh:
  br i1 %num, label %fresharray, label %freshobject
fresharray:
  %fa = call ptr @j_array()
  br label %getchild
freshobject:
  %fo = call ptr @j_object()
  br label %getchild
copy:
  %cp = call ptr @j_clone(ptr %v)
  br label %getchild
getchild:
  %out = phi ptr [%fa, %fresharray], [%fo, %freshobject], [%cp, %copy]
  %otag = call i32 @b_tag(ptr %out)
  %oa = icmp eq i32 %otag, 5
  %ka = icmp eq i32 %kt, 5
  %badupdate = and i1 %oa, %ka
  br i1 %badupdate, label %arraykeyerror, label %get
arraykeyerror:
  call void @j_fail(ptr @b.errupdatearray)
  ret ptr %out
get:
  %old = call ptr @j_get(ptr %out, ptr %k)
  %error = load ptr, ptr @j_error
  %failed = icmp ne ptr %error, null
  br i1 %failed, label %geterror, label %setchild
geterror:
  ret ptr %out
setchild:
  %next = add i64 %pos, 1
  %child = call ptr @b_setpath(ptr %old, ptr %path, i64 %next, ptr %value)
  %ot = call i32 @b_tag(ptr %out)
  %arr = icmp eq i32 %ot, 5
  br i1 %arr, label %array, label %object
object:
  call void @j_put(ptr %out, ptr %k, ptr %child)
  ret ptr %out
array:
  %f = call double @b_number(ptr %k)
  %idx0 = fptosi double %f to i64
  %len = call i64 @b_len(ptr %out)
  %neg = icmp slt i64 %idx0, 0
  %adjust = add i64 %idx0, %len
  %idx = select i1 %neg, i64 %adjust, i64 %idx0
  %valid = icmp sge i64 %idx, 0
  br i1 %valid, label %extend, label %return
extend:
  %i = phi i64 [%len, %array], [%inc, %pad]
  %need = icmp sle i64 %i, %idx
  br i1 %need, label %pad, label %set
pad:
  %null = call ptr @j_null()
  call void @j_push(ptr %out, ptr %null)
  %inc = add i64 %i, 1
  br label %extend
set:
  %data = call ptr @b_data(ptr %out)
  %slot = getelementptr ptr, ptr %data, i64 %idx
  store ptr %child, ptr %slot
  br label %return
return:
  ret ptr %out
}

define ptr @b_delpath(ptr %v, ptr %path, i64 %pos) {
entry:
  %n = call i64 @b_len(ptr %path)
  %too = icmp sgt i64 %n, 10000
  br i1 %too, label %deep, label %check
deep:
  call void @j_fail(ptr @b.errpathtoo)
  %deepnil = call ptr @j_null()
  ret ptr %deepnil
check:
  %done = icmp sge i64 %pos, %n
  br i1 %done, label %nil, label %start
nil:
  %nv = call ptr @j_null()
  ret ptr %nv
start:
  %key = call ptr @j_at(ptr %path, i64 %pos)
  %next = add i64 %pos, 1
  %leaf = icmp eq i64 %next, %n
  %tag = call i32 @b_tag(ptr %v)
  switch i32 %tag, label %same [i32 5, label %array i32 6, label %object]
same:
  ret ptr %v
array:
  %outa = call ptr @j_array()
  %an = call i64 @b_len(ptr %v)
  %f = call double @b_number(ptr %key)
  %idx0 = fptosi double %f to i64
  %neg = icmp slt i64 %idx0, 0
  %adj = add i64 %idx0, %an
  %idx = select i1 %neg, i64 %adj, i64 %idx0
  br label %aloop
aloop:
  %ai = phi i64 [0, %array], [%anext, %anextblock]
  %amore = icmp slt i64 %ai, %an
  br i1 %amore, label %abody, label %adone
abody:
  %av = call ptr @j_at(ptr %v, i64 %ai)
  %match = icmp eq i64 %ai, %idx
  br i1 %match, label %atarget, label %akeep
atarget:
  br i1 %leaf, label %anextblock, label %anested
anested:
  %ac = call ptr @b_delpath(ptr %av, ptr %path, i64 %next)
  call void @j_push(ptr %outa, ptr %ac)
  br label %anextblock
akeep:
  call void @j_push(ptr %outa, ptr %av)
  br label %anextblock
anextblock:
  %anext = add i64 %ai, 1
  br label %aloop
adone:
  ret ptr %outa
object:
  %outo = call ptr @j_object()
  %on = call i64 @b_len(ptr %v)
  %data = call ptr @b_data(ptr %v)
  br label %oloop
oloop:
  %oi = phi i64 [0, %object], [%onext, %onextblock]
  %omore = icmp slt i64 %oi, %on
  br i1 %omore, label %obody, label %odone
obody:
  %twice = shl i64 %oi, 1
  %vi = add i64 %twice, 1
  %kp = getelementptr ptr, ptr %data, i64 %twice
  %vp = getelementptr ptr, ptr %data, i64 %vi
  %ok = load ptr, ptr %kp
  %ov = load ptr, ptr %vp
  %cmp = call i32 @j_cmp(ptr %ok, ptr %key)
  %omatch = icmp eq i32 %cmp, 0
  br i1 %omatch, label %otarget, label %okeep
otarget:
  br i1 %leaf, label %onextblock, label %onested
onested:
  %oc = call ptr @b_delpath(ptr %ov, ptr %path, i64 %next)
  call void @j_put(ptr %outo, ptr %ok, ptr %oc)
  br label %onextblock
okeep:
  call void @j_put(ptr %outo, ptr %ok, ptr %ov)
  br label %onextblock
onextblock:
  %onext = add i64 %oi, 1
  br label %oloop
odone:
  ret ptr %outo
}

define ptr @j_builtin(ptr %name, ptr %args, ptr %input, ptr %env) {
entry:
  %id = call i32 @b_find(ptr %name, ptr @b.names)
  %known = icmp sge i32 %id, 0
  br i1 %known, label %core, label %text
core:
  %r = call ptr @b_core(i32 %id, ptr %args, ptr %input, ptr %env)
  ret ptr %r
text:
  %tr = call ptr @j_text_builtin(ptr %name, ptr %args, ptr %input, ptr %env)
  %tok = icmp ne ptr %tr, null
  br i1 %tok, label %textdone, label %math
textdone:
  ret ptr %tr
math:
  %mr = call ptr @j_math_builtin(ptr %name, ptr %args, ptr %input, ptr %env)
  %mok = icmp ne ptr %mr, null
  br i1 %mok, label %mathdone, label %time
mathdone:
  ret ptr %mr
time:
  %timer = call ptr @j_time_builtin(ptr %name, ptr %args, ptr %input, ptr %env)
  %timeok = icmp ne ptr %timer, null
  br i1 %timeok, label %timedone, label %streams
timedone:
  ret ptr %timer
streams:
  %streamr = call ptr @j_stream_builtin(ptr %name, ptr %args, ptr %input, ptr %env)
  %streamok = icmp ne ptr %streamr, null
  br i1 %streamok, label %streamdone, label %regex
streamdone:
  ret ptr %streamr
regex:
  %rr = call ptr @j_regex_builtin(ptr %name, ptr %args, ptr %input, ptr %env)
  %rok = icmp ne ptr %rr, null
  br i1 %rok, label %regexdone, label %cli
regexdone:
  ret ptr %rr
cli:
  %cr = call ptr @j_cli_builtin(ptr %name, ptr %args, ptr %input, ptr %env)
  ret ptr %cr
}

define ptr @b_core(i32 %id, ptr %args, ptr %input, ptr %env) {
entry:
  %argc = call i64 @b_len(ptr %args)
  %tag = call i32 @b_tag(ptr %input)
  switch i32 %id, label %other [
    i32 0, label %empty
    i32 1, label %error
    i32 2, label %not
    i32 3, label %type
    i32 4, label %length
    i32 5, label %utf8length
    i32 6, label %tostring
    i32 7, label %tojson
    i32 8, label %fromjson
    i32 9, label %tonumber
    i32 10, label %toboolean
    i32 11, label %filter
    i32 12, label %filter
    i32 13, label %filter
    i32 14, label %filter
    i32 15, label %filter
    i32 16, label %filter
    i32 17, label %filter
    i32 18, label %filter
    i32 19, label %filter
    i32 20, label %keys
    i32 21, label %keys
    i32 26, label %reverse
    i32 27, label %sort
    i32 28, label %sort
    i32 29, label %sort
    i32 30, label %sort
    i32 31, label %sort
    i32 32, label %sort
    i32 33, label %sort
    i32 34, label %sort
    i32 35, label %sort
    i32 36, label %add
    i32 37, label %flatten
    i32 38, label %map
    i32 39, label %map
    i32 40, label %select
    i32 41, label %range
    i32 42, label %anyall
    i32 43, label %anyall
    i32 44, label %stream
    i32 45, label %stream
    i32 46, label %stream
    i32 47, label %stream
    i32 48, label %stream
    i32 49, label %isempty
    i32 50, label %entries
    i32 51, label %fromentries
    i32 52, label %withentries
    i32 53, label %transpose
    i32 54, label %combinations
    i32 56, label %setpath
    i32 58, label %paths
    i32 59, label %paths
    i32 60, label %recurse
    i32 61, label %recurse
    i32 62, label %walk
    i32 63, label %while
    i32 64, label %while
    i32 69, label %indexobj
    i32 70, label %infilter
    i32 71, label %builtins
    i32 72, label %true
    i32 73, label %true
  ]
empty:
  %es = call ptr @j_array()
  ret ptr %es
error:
  %hasarg = icmp sgt i64 %argc, 0
  br i1 %hasarg, label %errarg, label %errinput
errarg:
  %ers = call ptr @b_arg(ptr %args, i64 0, ptr %input, ptr %env)
  %erm = call ptr @j_at(ptr %ers, i64 0)
  br label %errset
errinput:
  br label %errset
errset:
  %message = phi ptr [%erm, %errarg], [%input, %errinput]
  br label %raise
raise:
  store ptr %message, ptr @j_error
  br label %empty
not:
  %truth = call i1 @j_truth(ptr %input)
  %neg = xor i1 %truth, true
  %nb = call ptr @j_bool(i1 %neg)
  %ns = call ptr @b_one(ptr %nb)
  ret ptr %ns
type:
  %tn = call ptr @b_typename(ptr %input)
  %ts = call ptr @j_cstr(ptr %tn)
  %typer = call ptr @b_one(ptr %ts)
  ret ptr %typer
length:
  switch i32 %tag, label %lenbad [i32 0, label %lenzero i32 3, label %lenabs i32 4, label %lenstr i32 5, label %lencontainer i32 6, label %lencontainer]
lenzero:
  br label %lennum
lenabs:
  %f = call double @b_number(ptr %input)
  %isnegative = fcmp olt double %f, 0.000000e+00
  br i1 %isnegative, label %lennegative, label %identity
lennegative:
  %abs = call ptr @j_negate(ptr %input)
  %absr = call ptr @b_one(ptr %abs)
  ret ptr %absr
lenstr:
  %strn = call i64 @b_len(ptr %input)
  %strd = call ptr @b_data(ptr %input)
  %ulen = call i64 @b_utf8_length(ptr %strd, i64 %strn)
  %uf = sitofp i64 %ulen to double
  br label %lennum
lencontainer:
  %clen = call i64 @b_len(ptr %input)
  %cf = sitofp i64 %clen to double
  br label %lennum
lennum:
  %ln = phi double [0.000000e+00, %lenzero], [%uf, %lenstr], [%cf, %lencontainer]
  %lv = call ptr @j_num(double %ln)
  %lr = call ptr @b_one(ptr %lv)
  ret ptr %lr
lenbad:
  call void @b_type_error(ptr %input, ptr @b.errlen)
  br label %empty
utf8length:
  %isstr = icmp eq i32 %tag, 4
  br i1 %isstr, label %lencontainer, label %utf8bad
utf8bad:
  call void @b_type_error(ptr %input, ptr @b.errutf8)
  br label %empty
tostring:
  %stringv = call ptr @b_tostring(ptr %input)
  %stringr = call ptr @b_one(ptr %stringv)
  ret ptr %stringr
tojson:
  %jsonv = call ptr @j_dump(ptr %input, i32 0)
  %jsonr = call ptr @b_one(ptr %jsonv)
  ret ptr %jsonr
tonumber:
  %isnum = icmp eq i32 %tag, 3
  br i1 %isnum, label %identity, label %fromjson
fromjson:
  %parseable = icmp eq i32 %tag, 4
  br i1 %parseable, label %parse, label %parsebad
parse:
  %pd = call ptr @b_data(ptr %input)
  %pn = call i64 @b_len(ptr %input)
  %offset = alloca i64
  store i64 0, ptr %offset
  %parsed = call ptr @j_parse(ptr %pd, i64 %pn, ptr %offset)
  %valid = icmp ne ptr %parsed, null
  br i1 %valid, label %parsedcheck, label %parsedbad
parsedbad:
  %wasnumber = icmp eq i32 %id, 9
  br i1 %wasnumber, label %parsebad, label %empty
parsedcheck:
  %consumed = load i64, ptr %offset
  %numberparse = icmp eq i32 %id, 9
  br i1 %numberparse, label %parsednumber, label %jsontrailing
parsednumber:
  %parsedtag = call i32 @b_tag(ptr %parsed)
  %parsednumeric = icmp eq i32 %parsedtag, 3
  %complete = icmp eq i64 %consumed, %pn
  %nonemptystring = icmp sgt i64 %pn, 0
  br i1 %nonemptystring, label %numberleading, label %parsebad
numberleading:
  %leading = load i8, ptr %pd
  %space = icmp ule i8 %leading, 32
  %nospace = xor i1 %space, true
  %validtype = and i1 %parsednumeric, %complete
  %validnumber = and i1 %validtype, %nospace
  br i1 %validnumber, label %parsedok, label %parsebad
jsontrailing:
  br label %whitespaceloop
whitespaceloop:
  %wi = phi i64 [%consumed, %jsontrailing], [%wn, %whitespace]
  %wm = icmp slt i64 %wi, %pn
  br i1 %wm, label %whitespacecheck, label %parsedok
whitespacecheck:
  %wp = getelementptr i8, ptr %pd, i64 %wi
  %wc = load i8, ptr %wp
  switch i8 %wc, label %extrajson [i8 9, label %whitespace i8 10, label %whitespace i8 13, label %whitespace i8 32, label %whitespace]
whitespace:
  %wn = add i64 %wi, 1
  br label %whitespaceloop
extrajson:
  call void @j_fail(ptr @b.errextrajson)
  br label %empty
parsedok:
  %pr = call ptr @b_one(ptr %parsed)
  ret ptr %pr
parsebad:
  call void @b_type_error(ptr %input, ptr @b.errnumber)
  br label %empty
toboolean:
  %isfalse = icmp eq i32 %tag, 1
  %istrue = icmp eq i32 %tag, 2
  %isbool = or i1 %isfalse, %istrue
  br i1 %isbool, label %identity, label %boolstr
boolstr:
  %istrueword = call i1 @j_is(ptr %input, ptr @b.true)
  br i1 %istrueword, label %true, label %boolfalse
boolfalse:
  %isfalseword = call i1 @j_is(ptr %input, ptr @b.false)
  br i1 %isfalseword, label %false, label %boolbad
boolbad:
  call void @b_type_error(ptr %input, ptr @b.errboolean)
  br label %empty
filter:
  %arr = icmp eq i32 %tag, 5
  %obj = icmp eq i32 %tag, 6
  %iter = or i1 %arr, %obj
  %b1 = icmp eq i32 %tag, 1
  %b2 = icmp eq i32 %tag, 2
  %boolean = or i1 %b1, %b2
  %number = icmp eq i32 %tag, 3
  %str = icmp eq i32 %tag, 4
  %null = icmp eq i32 %tag, 0
  %nonnull = xor i1 %null, true
  %scalar = xor i1 %iter, true
  switch i32 %id, label %fscalar [i32 11, label %farr i32 12, label %fobj i32 13, label %fiter i32 14, label %fbool i32 15, label %fnum i32 16, label %fstr i32 17, label %fnull i32 18, label %fvalue]
farr:
  br i1 %arr, label %identity, label %empty
fobj:
  br i1 %obj, label %identity, label %empty
fiter:
  br i1 %iter, label %identity, label %empty
fbool:
  br i1 %boolean, label %identity, label %empty
fnum:
  br i1 %number, label %identity, label %empty
fstr:
  br i1 %str, label %identity, label %empty
fnull:
  br i1 %null, label %identity, label %empty
fvalue:
  br i1 %nonnull, label %identity, label %empty
fscalar:
  br i1 %scalar, label %identity, label %empty
keys:
  %sorted = icmp eq i32 %id, 20
  %kv = call ptr @b_keys(ptr %input, i1 %sorted)
  %kr = call ptr @b_one(ptr %kv)
  ret ptr %kr
reverse:
  %rev = call ptr @j_array()
  %rn = call i64 @b_len(ptr %input)
  br label %revloop
revloop:
  %ri = phi i64 [%rn, %reverse], [%prev, %revbody]
  %rmore = icmp sgt i64 %ri, 0
  br i1 %rmore, label %revbody, label %revdone
revbody:
  %prev = sub i64 %ri, 1
  %rv = call ptr @j_at(ptr %input, i64 %prev)
  call void @j_push(ptr %rev, ptr %rv)
  br label %revloop
revdone:
  %rr = call ptr @b_one(ptr %rev)
  ret ptr %rr
sort:
  %sr = call ptr @b_sort_family(i32 %id, ptr %args, ptr %input, ptr %env)
  ret ptr %sr
add:
  %explicit = icmp sgt i64 %argc, 0
  br i1 %explicit, label %addarg, label %addvalues
addarg:
  %ag = call ptr @b_arg(ptr %args, i64 0, ptr %input, ptr %env)
  br label %addstart
addvalues:
  %av = call ptr @b_values(ptr %input)
  br label %addstart
addstart:
  %addsrc = phi ptr [%ag, %addarg], [%av, %addvalues]
  %addn = call i64 @b_len(ptr %addsrc)
  %initial = call ptr @j_null()
  br label %addloop
addloop:
  %ai = phi i64 [0, %addstart], [%anext, %addbody]
  %acc = phi ptr [%initial, %addstart], [%sum, %addbody]
  %amore = icmp slt i64 %ai, %addn
  br i1 %amore, label %addbody, label %adddone
addbody:
  %item = call ptr @j_at(ptr %addsrc, i64 %ai)
  %sum = call ptr @j_binary(i32 0, ptr %acc, ptr %item)
  %anext = add i64 %ai, 1
  br label %addloop
adddone:
  %ar = call ptr @b_one(ptr %acc)
  ret ptr %ar
flatten:
  %hasdepth = icmp sgt i64 %argc, 0
  br i1 %hasdepth, label %other, label %flatall
flatall:
  %flat = call ptr @j_array()
  call void @b_flatten(ptr %input, i64 -1, ptr %flat)
  %flatr = call ptr @b_one(ptr %flat)
  ret ptr %flatr
map:
  %mapast = call ptr @j_at(ptr %args, i64 0)
  %preserve = icmp eq i32 %id, 39
  %mapped = call ptr @b_map(ptr %mapast, ptr %input, ptr %env, i1 %preserve, i1 false)
  %mapr = call ptr @b_one(ptr %mapped)
  ret ptr %mapr
select:
  %conds = call ptr @b_arg(ptr %args, i64 0, ptr %input, ptr %env)
  %cn = call i64 @b_len(ptr %conds)
  %selr = call ptr @j_array()
  br label %selloop
selloop:
  %ci = phi i64 [0, %select], [%cnext, %selnext]
  %cmore = icmp slt i64 %ci, %cn
  br i1 %cmore, label %selbody, label %seldone
selbody:
  %cond = call ptr @j_at(ptr %conds, i64 %ci)
  %ct = call i1 @j_truth(ptr %cond)
  br i1 %ct, label %selput, label %selnext
selput:
  call void @j_push(ptr %selr, ptr %input)
  br label %selnext
selnext:
  %cnext = add i64 %ci, 1
  br label %selloop
seldone:
  ret ptr %selr
range:
  %ranger = call ptr @b_range(ptr %args, ptr %input, ptr %env)
  ret ptr %ranger
anyall:
  %all = icmp eq i32 %id, 43
  %anyr = call ptr @b_anyall(ptr %args, ptr %input, ptr %env, i1 %all)
  ret ptr %anyr
stream:
  %streamr = call ptr @b_stream(i32 %id, ptr %args, ptr %input, ptr %env)
  ret ptr %streamr
isempty:
  %ies = call ptr @b_arg_take(ptr %args, i64 0, ptr %input, ptr %env, i64 1)
  %ien = call i64 @b_len(ptr %ies)
  %ie = icmp eq i64 %ien, 0
  %ieb = call ptr @j_bool(i1 %ie)
  %ier = call ptr @b_one(ptr %ieb)
  ret ptr %ier
entries:
  %ent = call ptr @b_entries(ptr %input)
  %entr = call ptr @b_one(ptr %ent)
  ret ptr %entr
fromentries:
  %objent = call ptr @b_from_entries(ptr %input)
  %objentr = call ptr @b_one(ptr %objent)
  ret ptr %objentr
withentries:
  %wentr = call ptr @b_entries(ptr %input)
  %wast = call ptr @j_at(ptr %args, i64 0)
  %wmap = call ptr @b_map(ptr %wast, ptr %wentr, ptr %env, i1 false, i1 false)
  %wo = call ptr @b_from_entries(ptr %wmap)
  %wr = call ptr @b_one(ptr %wo)
  ret ptr %wr
transpose:
  %trans = call ptr @b_transpose(ptr %input)
  %transr = call ptr @b_one(ptr %trans)
  ret ptr %transr
combinations:
  %combr = call ptr @b_combinations(ptr %args, ptr %input, ptr %env)
  ret ptr %combr
setpath:
  %spr = call ptr @b_setpath_family(ptr %args, ptr %input, ptr %env)
  ret ptr %spr
paths:
  %pathr = call ptr @j_array()
  %path0 = call ptr @j_array()
  %patharg = icmp sgt i64 %argc, 0
  br i1 %patharg, label %pathargyes, label %pathargno
pathargyes:
  %pa = call ptr @j_at(ptr %args, i64 0)
  br label %pathgo
pathargno:
  br label %pathgo
pathgo:
  %pf = phi ptr [%pa, %pathargyes], [null, %pathargno]
  %leaf = icmp eq i32 %id, 59
  call void @b_paths(ptr %input, ptr %path0, ptr %pf, ptr %env, ptr %pathr, i1 %leaf)
  ret ptr %pathr
recurse:
  %recr = call ptr @j_array()
  call void @b_recurse(ptr %args, ptr %input, ptr %env, ptr %recr, i64 0)
  ret ptr %recr
walk:
  %walkast = call ptr @j_at(ptr %args, i64 0)
  %walkr = call ptr @b_walk(ptr %walkast, ptr %input, ptr %env)
  ret ptr %walkr
while:
  %until = icmp eq i32 %id, 64
  %whiler = call ptr @j_array()
  call void @b_while(ptr %args, ptr %input, ptr %env, ptr %whiler, i1 %until, i64 0)
  ret ptr %whiler
indexobj:
  %indexr = call ptr @b_index_object(ptr %args, ptr %input, ptr %env)
  ret ptr %indexr
infilter:
  %inr = call ptr @b_in_filter(ptr %args, ptr %input, ptr %env)
  ret ptr %inr
builtins:
  %bis = call ptr @j_array()
  call void @b_catalog(ptr %bis, ptr @b.names)
  %textnames = call ptr @j_text_names()
  %mathnames = call ptr @j_math_names()
  %streamnames = call ptr @j_stream_names()
  %timenames = call ptr @j_time_names()
  %regexnames = call ptr @j_regex_names()
  %clinames = call ptr @j_cli_names()
  call void @b_catalog(ptr %bis, ptr %textnames)
  call void @b_catalog(ptr %bis, ptr %mathnames)
  call void @b_catalog(ptr %bis, ptr %streamnames)
  call void @b_catalog(ptr %bis, ptr %timenames)
  call void @b_catalog(ptr %bis, ptr %regexnames)
  call void @b_catalog(ptr %bis, ptr %clinames)
  %bir = call ptr @b_one(ptr %bis)
  ret ptr %bir
false:
  %fb = call ptr @j_bool(i1 false)
  %fr = call ptr @b_one(ptr %fb)
  ret ptr %fr
true:
  %tb = call ptr @j_bool(i1 true)
  %tr = call ptr @b_one(ptr %tb)
  ret ptr %tr
identity:
  %ir = call ptr @b_one(ptr %input)
  ret ptr %ir
other:
  %ur = call ptr @b_unary_args(i32 %id, ptr %args, ptr %input, ptr %env)
  ret ptr %ur
}

define ptr @b_map(ptr %ast, ptr %input, ptr %env, i1 %preserve, i1 %walking) {
entry:
  %tag = call i32 @b_tag(ptr %input)
  %obj = icmp eq i32 %tag, 6
  %objectout = and i1 %obj, %preserve
  br i1 %objectout, label %newobj, label %newarr
newobj:
  %o = call ptr @j_object()
  br label %start
newarr:
  %a = call ptr @j_array()
  br label %start
start:
  %out = phi ptr [%o, %newobj], [%a, %newarr]
  %keys = call ptr @b_keys(ptr %input, i1 false)
  %n = call i64 @b_len(ptr %keys)
  br label %loop
loop:
  %i = phi i64 [0, %start], [%next, %advance]
  %more = icmp slt i64 %i, %n
  br i1 %more, label %body, label %done
body:
  %key = call ptr @j_at(ptr %keys, i64 %i)
  %value = call ptr @j_get(ptr %input, ptr %key)
  br i1 %walking, label %walk, label %eval
walk:
  %ws = call ptr @b_walk(ptr %ast, ptr %value, ptr %env)
  br label %mapped
eval:
  %es = call ptr @j_eval(ptr %ast, ptr %value, ptr %env)
  br label %mapped
mapped:
  %results = phi ptr [%ws, %walk], [%es, %eval]
  br i1 %preserve, label %first, label %all
first:
  %count = call i64 @b_len(ptr %results)
  %have = icmp sgt i64 %count, 0
  br i1 %have, label %put, label %advance
put:
  %x = call ptr @j_at(ptr %results, i64 0)
  br i1 %objectout, label %putobj, label %putarr
putobj:
  call void @j_put(ptr %out, ptr %key, ptr %x)
  br label %advance
putarr:
  call void @j_push(ptr %out, ptr %x)
  br label %advance
all:
  call void @b_extend(ptr %out, ptr %results)
  br label %advance
advance:
  %next = add i64 %i, 1
  br label %loop
done:
  ret ptr %out
}

define ptr @b_walk(ptr %ast, ptr %input, ptr %env) {
entry:
  %tag = call i32 @b_tag(ptr %input)
  %arr = icmp eq i32 %tag, 5
  %obj = icmp eq i32 %tag, 6
  %iter = or i1 %arr, %obj
  br i1 %iter, label %map, label %scalar
map:
  %mapped = call ptr @b_map(ptr %ast, ptr %input, ptr %env, i1 %obj, i1 true)
  br label %apply
scalar:
  br label %apply
apply:
  %v = phi ptr [%mapped, %map], [%input, %scalar]
  %r = call ptr @j_eval(ptr %ast, ptr %v, ptr %env)
  ret ptr %r
}

define ptr @b_sort_family(i32 %id, ptr %args, ptr %input, ptr %env) {
entry:
  %tag = call i32 @b_tag(ptr %input)
  %array = icmp eq i32 %tag, 5
  br i1 %array, label %start, label %bad
bad:
  call void @b_type_error(ptr %input, ptr @b.errsort)
  %empty = call ptr @j_array()
  ret ptr %empty
start:
  %values = call ptr @j_clone(ptr %input)
  %argc = call i64 @b_len(ptr %args)
  %haskey = icmp sgt i64 %argc, 0
  %keys = call ptr @j_array()
  %n = call i64 @b_len(ptr %input)
  br label %keyloop
keyloop:
  %i = phi i64 [0, %start], [%next, %keyappend]
  %more = icmp slt i64 %i, %n
  br i1 %more, label %keybody, label %sort
keybody:
  %v = call ptr @j_at(ptr %input, i64 %i)
  br i1 %haskey, label %eval, label %identity
eval:
  %s = call ptr @b_arg(ptr %args, i64 0, ptr %v, ptr %env)
  br label %keyappend
identity:
  br label %keyappend
keyappend:
  %k = phi ptr [%s, %eval], [%v, %identity]
  call void @j_push(ptr %keys, ptr %k)
  %next = add i64 %i, 1
  br label %keyloop
sort:
  call void @b_sort_inplace(ptr %values, ptr %keys)
  switch i32 %id, label %sorted [i32 29, label %group i32 30, label %unique i32 31, label %unique i32 32, label %min i32 33, label %max i32 34, label %min i32 35, label %max]
sorted:
  %sr = call ptr @b_one(ptr %values)
  ret ptr %sr
min:
  %minv = call ptr @j_at(ptr %values, i64 0)
  %minr = call ptr @b_one(ptr %minv)
  ret ptr %minr
max:
  %maxv = call ptr @j_at(ptr %values, i64 -1)
  %maxr = call ptr @b_one(ptr %maxv)
  ret ptr %maxr
group:
  br label %dedup
unique:
  br label %dedup
dedup:
  %groups = icmp eq i32 %id, 29
  %out = call ptr @j_array()
  %firstgroup = call ptr @j_array()
  br label %loop
loop:
  %j = phi i64 [0, %dedup], [%jnext, %advance]
  %prevkey = phi ptr [null, %dedup], [%curkey, %advance]
  %curgroup = phi ptr [%firstgroup, %dedup], [%nextgroup, %advance]
  %jmore = icmp slt i64 %j, %n
  br i1 %jmore, label %body, label %done
body:
  %curkey = call ptr @j_at(ptr %keys, i64 %j)
  %curval = call ptr @j_at(ptr %values, i64 %j)
  %first = icmp eq i64 %j, 0
  br i1 %first, label %newgroup, label %compare
compare:
  %cmp = call i32 @j_cmp(ptr %prevkey, ptr %curkey)
  %same = icmp eq i32 %cmp, 0
  br i1 %same, label %existing, label %newgroup
newgroup:
  br i1 %groups, label %makegroup, label %newvalue
makegroup:
  %ng = call ptr @j_array()
  call void @j_push(ptr %ng, ptr %curval)
  call void @j_push(ptr %out, ptr %ng)
  br label %advance
newvalue:
  call void @j_push(ptr %out, ptr %curval)
  br label %advance
existing:
  br i1 %groups, label %appendgroup, label %advance
appendgroup:
  call void @j_push(ptr %curgroup, ptr %curval)
  br label %advance
advance:
  %nextgroup = phi ptr [%ng, %makegroup], [%curgroup, %newvalue], [%curgroup, %existing], [%curgroup, %appendgroup]
  %jnext = add i64 %j, 1
  br label %loop
done:
  %result = call ptr @b_one(ptr %out)
  ret ptr %result
}

define ptr @b_range(ptr %args, ptr %input, ptr %env) {
entry:
  %out = call ptr @b_range_count(ptr %args, ptr %input, ptr %env, i64 -1)
  ret ptr %out
}

define ptr @b_range_count(ptr %args, ptr %input, ptr %env, i64 %count) {
entry:
  %out = call ptr @j_array()
  %argc = call i64 @b_len(ptr %args)
  %one = icmp eq i64 %argc, 1
  %zero = call ptr @j_num(double 0.000000e+00)
  %unit = call ptr @j_num(double 1.000000e+00)
  %arg0 = call ptr @b_arg(ptr %args, i64 0, ptr %input, ptr %env)
  br i1 %one, label %onearg, label %multiarg
onearg:
  %zs = call ptr @b_one(ptr %zero)
  br label %bounds
multiarg:
  %arg1 = call ptr @b_arg(ptr %args, i64 1, ptr %input, ptr %env)
  br label %bounds
bounds:
  %starts = phi ptr [%zs, %onearg], [%arg0, %multiarg]
  %ends = phi ptr [%arg0, %onearg], [%arg1, %multiarg]
  %three = icmp sge i64 %argc, 3
  br i1 %three, label %stepgiven, label %stepunit
stepgiven:
  %arg2 = call ptr @b_arg(ptr %args, i64 2, ptr %input, ptr %env)
  br label %start
stepunit:
  %units = call ptr @b_one(ptr %unit)
  br label %start
start:
  %steps = phi ptr [%arg2, %stepgiven], [%units, %stepunit]
  %sn = call i64 @b_len(ptr %starts)
  %en = call i64 @b_len(ptr %ends)
  %dn = call i64 @b_len(ptr %steps)
  br label %sloop
sloop:
  %si = phi i64 [0, %start], [%snext, %sadvance]
  %smore = icmp slt i64 %si, %sn
  br i1 %smore, label %sbody, label %done
sbody:
  %sv = call ptr @j_at(ptr %starts, i64 %si)
  %sf = call double @b_number(ptr %sv)
  br label %eloop
eloop:
  %ei = phi i64 [0, %sbody], [%enext, %eadvance]
  %emore = icmp slt i64 %ei, %en
  br i1 %emore, label %ebody, label %sadvance
ebody:
  %ev = call ptr @j_at(ptr %ends, i64 %ei)
  %ef = call double @b_number(ptr %ev)
  br label %dloop
dloop:
  %di = phi i64 [0, %ebody], [%dnext, %dadvance]
  %dmore = icmp slt i64 %di, %dn
  br i1 %dmore, label %dbody, label %eadvance
dbody:
  %dv = call ptr @j_at(ptr %steps, i64 %di)
  %df = call double @b_number(ptr %dv)
  %positive = fcmp ogt double %df, 0.000000e+00
  %negative = fcmp olt double %df, 0.000000e+00
  br label %range
range:
  %f = phi double [%sf, %dbody], [%fnext, %append]
  %bounded = icmp sge i64 %count, 0
  %produced = call i64 @b_len(ptr %out)
  %enough = icmp sge i64 %produced, %count
  %finished = and i1 %bounded, %enough
  br i1 %finished, label %done, label %rangebound
rangebound:
  %below = fcmp olt double %f, %ef
  %above = fcmp ogt double %f, %ef
  %up = and i1 %positive, %below
  %down = and i1 %negative, %above
  %emit = or i1 %up, %down
  br i1 %emit, label %append, label %dadvance
append:
  %nv = call ptr @j_num(double %f)
  call void @j_push(ptr %out, ptr %nv)
  %fnext = fadd double %f, %df
  %progress = fcmp one double %f, %fnext
  br i1 %progress, label %range, label %dadvance
dadvance:
  %dnext = add i64 %di, 1
  br label %dloop
eadvance:
  %enext = add i64 %ei, 1
  br label %eloop
sadvance:
  %snext = add i64 %si, 1
  br label %sloop
done:
  ret ptr %out
}

define ptr @b_anyall(ptr %args, ptr %input, ptr %env, i1 %all) {
entry:
  %argc = call i64 @b_len(ptr %args)
  %two = icmp sge i64 %argc, 2
  br i1 %two, label %generator, label %values
generator:
  %gs = call ptr @b_arg(ptr %args, i64 0, ptr %input, ptr %env)
  br label %start
values:
  %vs = call ptr @b_values(ptr %input)
  br label %start
start:
  %items = phi ptr [%gs, %generator], [%vs, %values]
  %generatorerror = load ptr, ptr @j_error
  store ptr null, ptr @j_error
  %n = call i64 @b_len(ptr %items)
  %argidx = select i1 %two, i64 1, i64 0
  %hascond = icmp sgt i64 %argc, 0
  br label %outer
outer:
  %i = phi i64 [0, %start], [%next, %advance]
  %more = icmp slt i64 %i, %n
  br i1 %more, label %body, label %unchanged
body:
  %item = call ptr @j_at(ptr %items, i64 %i)
  br i1 %hascond, label %eval, label %identity
eval:
  %cs = call ptr @b_arg(ptr %args, i64 %argidx, ptr %item, ptr %env)
  br label %conds
identity:
  %is = call ptr @b_one(ptr %item)
  br label %conds
conds:
  %results = phi ptr [%cs, %eval], [%is, %identity]
  %rn = call i64 @b_len(ptr %results)
  br label %inner
inner:
  %j = phi i64 [0, %conds], [%jnext, %test]
  %jmore = icmp slt i64 %j, %rn
  br i1 %jmore, label %test, label %advance
test:
  %v = call ptr @j_at(ptr %results, i64 %j)
  %truth = call i1 @j_truth(ptr %v)
  %decisive = xor i1 %truth, %all
  %jnext = add i64 %j, 1
  br i1 %decisive, label %changed, label %inner
advance:
  %next = add i64 %i, 1
  br label %outer
changed:
  %opposite = xor i1 %all, true
  br label %done
unchanged:
  %conditionerror = load ptr, ptr @j_error
  %hasconditionerror = icmp ne ptr %conditionerror, null
  %finalerror = select i1 %hasconditionerror, ptr %conditionerror, ptr %generatorerror
  store ptr %finalerror, ptr @j_error
  br label %done
done:
  %result = phi i1 [%opposite, %changed], [%all, %unchanged]
  %value = call ptr @j_bool(i1 %result)
  %out = call ptr @b_one(ptr %value)
  ret ptr %out
}

define ptr @b_stream(i32 %id, ptr %args, ptr %input, ptr %env) {
entry:
  %out = call ptr @j_array()
  %argc = call i64 @b_len(ptr %args)
  %first = icmp eq i32 %id, 44
  %last = icmp eq i32 %id, 45
  %fl = or i1 %first, %last
  %none = icmp eq i64 %argc, 0
  %simple = and i1 %fl, %none
  br i1 %simple, label %arrayfirst, label %checkfl
arrayfirst:
  %idx = select i1 %first, i64 0, i64 -1
  %v = call ptr @j_at(ptr %input, i64 %idx)
  call void @j_push(ptr %out, ptr %v)
  ret ptr %out
checkfl:
  br i1 %fl, label %filterfirst, label %counts
filterfirst:
  br i1 %first, label %takefirst, label %takelast
takefirst:
  %fts = call ptr @b_arg_take(ptr %args, i64 0, ptr %input, ptr %env, i64 1)
  br label %filtervalues
takelast:
  %fls = call ptr @b_arg(ptr %args, i64 0, ptr %input, ptr %env)
  br label %filtervalues
filtervalues:
  %fs = phi ptr [%fts, %takefirst], [%fls, %takelast]
  %fn = call i64 @b_len(ptr %fs)
  %fnonempty = icmp sgt i64 %fn, 0
  br i1 %fnonempty, label %filterput, label %done
filterput:
  %fidx = select i1 %first, i64 0, i64 -1
  %fv = call ptr @j_at(ptr %fs, i64 %fidx)
  call void @j_push(ptr %out, ptr %fv)
  br label %done
counts:
  %ns = call ptr @b_arg(ptr %args, i64 0, ptr %input, ptr %env)
  %nn = call i64 @b_len(ptr %ns)
  %two = icmp sge i64 %argc, 2
  br label %outer
outer:
  %ni = phi i64 [0, %counts], [%nnext, %advance]
  %nmore = icmp slt i64 %ni, %nn
  br i1 %nmore, label %nbody, label %done
nbody:
  %nv = call ptr @j_at(ptr %ns, i64 %ni)
  %nf = call double @b_number(ptr %nv)
  %n = fptosi double %nf to i64
  %negative = icmp slt i64 %n, 0
  %negativegenerator = and i1 %negative, %two
  br i1 %negativegenerator, label %badnegative, label %getitems
badnegative:
  %skip = icmp eq i32 %id, 48
  %limitnegative = icmp eq i32 %id, 47
  %msg0 = select i1 %skip, ptr @b.errskip, ptr @b.errnth
  %msg = select i1 %limitnegative, ptr @b.errlimit, ptr %msg0
  call void @j_fail(ptr %msg)
  br label %done
getitems:
  br i1 %two, label %eval, label %array
eval:
  %limit = icmp eq i32 %id, 47
  %nthtaking = icmp eq i32 %id, 46
  %taking = or i1 %limit, %nthtaking
  br i1 %taking, label %takegenerator, label %fullgenerator
takegenerator:
  %nthcount = add i64 %n, 1
  %takecount = select i1 %limit, i64 %n, i64 %nthcount
  %gts = call ptr @b_arg_take(ptr %args, i64 1, ptr %input, ptr %env, i64 %takecount)
  br label %generatorvalues
fullgenerator:
  %gfs = call ptr @b_arg(ptr %args, i64 1, ptr %input, ptr %env)
  br label %generatorvalues
generatorvalues:
  %gs = phi ptr [%gts, %takegenerator], [%gfs, %fullgenerator]
  br label %items
array:
  br label %items
items:
  %src = phi ptr [%gs, %generatorvalues], [%input, %array]
  %sn = call i64 @b_len(ptr %src)
  %nth = icmp eq i32 %id, 46
  br i1 %nth, label %nthvalue, label %loopsetup
nthvalue:
  %within = icmp slt i64 %n, %sn
  %outside = xor i1 %within, true
  %omit = and i1 %outside, %two
  br i1 %omit, label %advance, label %nthput
nthput:
  %x = call ptr @j_at(ptr %src, i64 %n)
  call void @j_push(ptr %out, ptr %x)
  br label %advance
loopsetup:
  %isskip = icmp eq i32 %id, 48
  %begin = select i1 %isskip, i64 %n, i64 0
  %lessthan = icmp slt i64 %n, %sn
  %limited = select i1 %lessthan, i64 %n, i64 %sn
  %end = select i1 %isskip, i64 %sn, i64 %limited
  br label %loop
loop:
  %i = phi i64 [%begin, %loopsetup], [%inext, %put]
  %more = icmp slt i64 %i, %end
  br i1 %more, label %put, label %advance
put:
  %y = call ptr @j_at(ptr %src, i64 %i)
  call void @j_push(ptr %out, ptr %y)
  %inext = add i64 %i, 1
  br label %loop
advance:
  %nnext = add i64 %ni, 1
  br label %outer
done:
  ret ptr %out
}

define ptr @b_unary_args(i32 %id, ptr %args, ptr %input, ptr %env) {
entry:
  %out = call ptr @j_array()
  %values = call ptr @b_arg(ptr %args, i64 0, ptr %input, ptr %env)
  %n = call i64 @b_len(ptr %values)
  br label %loop
loop:
  %i = phi i64 [0, %entry], [%next, %body]
  %more = icmp slt i64 %i, %n
  br i1 %more, label %body, label %done
body:
  %arg = call ptr @j_at(ptr %values, i64 %i)
  %v = call ptr @b_unary_value(i32 %id, ptr %input, ptr %arg)
  call void @b_pushvalid(ptr %out, ptr %v)
  %next = add i64 %i, 1
  br label %loop
done:
  ret ptr %out
}

define ptr @b_unary_value(i32 %id, ptr %input, ptr %arg) {
entry:
  switch i32 %id, label %null [
    i32 22, label %has
    i32 23, label %in
    i32 24, label %contains
    i32 25, label %inside
    i32 37, label %flatten
    i32 55, label %getpath
    i32 57, label %delpaths
    i32 65, label %bsearch
    i32 66, label %indices
    i32 67, label %indices
    i32 68, label %indices
  ]
has:
  %hv = call i1 @b_has(ptr %input, ptr %arg)
  %hb = call ptr @j_bool(i1 %hv)
  ret ptr %hb
in:
  %iv = call i1 @b_has(ptr %arg, ptr %input)
  %ib = call ptr @j_bool(i1 %iv)
  ret ptr %ib
contains:
  %inputtype = call i32 @b_tag(ptr %input)
  %argtype = call i32 @b_tag(ptr %arg)
  %sametype = icmp eq i32 %inputtype, %argtype
  br i1 %sametype, label %containcheck, label %containbad
containbad:
  call void @j_type_error2(ptr %input, ptr %arg, ptr @b.errcontain)
  br label %null
containcheck:
  %cv = call i1 @b_contains(ptr %input, ptr %arg)
  %cb = call ptr @j_bool(i1 %cv)
  ret ptr %cb
inside:
  %insidetype = call i32 @b_tag(ptr %input)
  %containertype = call i32 @b_tag(ptr %arg)
  %insidesame = icmp eq i32 %insidetype, %containertype
  br i1 %insidesame, label %insidecheck, label %insidebad
insidebad:
  call void @j_type_error2(ptr %arg, ptr %input, ptr @b.errcontain)
  br label %null
insidecheck:
  %inv = call i1 @b_contains(ptr %arg, ptr %input)
  %inb = call ptr @j_bool(i1 %inv)
  ret ptr %inb
flatten:
  %depthf = call double @b_number(ptr %arg)
  %depth = fptosi double %depthf to i64
  %negative = icmp slt i64 %depth, 0
  br i1 %negative, label %flaterror, label %flatdo
flaterror:
  call void @j_fail(ptr @b.errflat)
  br label %null
flatdo:
  %flat = call ptr @j_array()
  call void @b_flatten(ptr %input, i64 %depth, ptr %flat)
  ret ptr %flat
getpath:
  %gp = call ptr @b_getpath(ptr %input, ptr %arg)
  ret ptr %gp
delpaths:
  %deleted = call ptr @b_delete_many(ptr %input, ptr %arg)
  ret ptr %deleted
bsearch:
  %searchtag = call i32 @b_tag(ptr %input)
  %searcharray = icmp eq i32 %searchtag, 5
  br i1 %searcharray, label %searchstart, label %searchbad
searchbad:
  call void @b_type_error(ptr %input, ptr @b.errsearch)
  br label %null
searchstart:
  %bn = call i64 @b_len(ptr %input)
  br label %bloop
bloop:
  %lo = phi i64 [0, %searchstart], [%newlo, %right], [%lo, %left]
  %hi = phi i64 [%bn, %searchstart], [%hi, %right], [%mid, %left]
  %more = icmp slt i64 %lo, %hi
  br i1 %more, label %bcompare, label %bmissing
bcompare:
  %sum = add i64 %lo, %hi
  %mid = lshr i64 %sum, 1
  %value = call ptr @j_at(ptr %input, i64 %mid)
  %cmp = call i32 @j_cmp(ptr %value, ptr %arg)
  %eq = icmp eq i32 %cmp, 0
  br i1 %eq, label %bfound, label %bdir
bdir:
  %less = icmp slt i32 %cmp, 0
  br i1 %less, label %right, label %left
right:
  %newlo = add i64 %mid, 1
  br label %bloop
left:
  br label %bloop
bfound:
  %mf = sitofp i64 %mid to double
  %mv = call ptr @j_num(double %mf)
  ret ptr %mv
bmissing:
  %mpos = sub i64 -1, %lo
  %mpf = sitofp i64 %mpos to double
  %mpv = call ptr @j_num(double %mpf)
  ret ptr %mpv
indices:
  %ix = call ptr @b_indices(ptr %input, ptr %arg)
  %all = icmp eq i32 %id, 66
  br i1 %all, label %indicesall, label %indicesone
indicesall:
  ret ptr %ix
indicesone:
  %last = icmp eq i32 %id, 68
  %idx = select i1 %last, i64 -1, i64 0
  %ixv = call ptr @j_at(ptr %ix, i64 %idx)
  ret ptr %ixv
null:
  %nil = call ptr @j_null()
  ret ptr %nil
}

define ptr @b_indices(ptr %input, ptr %arg) {
entry:
  %out = call ptr @j_array()
  %tag = call i32 @b_tag(ptr %input)
  %str = icmp eq i32 %tag, 4
  br i1 %str, label %string, label %array
string:
  %s = call ptr @b_data(ptr %input)
  %n = call i64 @b_len(ptr %input)
  %a = call ptr @b_data(ptr %arg)
  %an = call i64 @b_len(ptr %arg)
  %nonempty = icmp sgt i64 %an, 0
  br i1 %nonempty, label %sloop, label %done
sloop:
  %pos = phi i64 [0, %string], [%next, %sfound]
  %found = call i64 @b_search_bytes(ptr %s, i64 %n, ptr %a, i64 %an, i64 %pos)
  %ok = icmp sge i64 %found, 0
  br i1 %ok, label %sfound, label %done
sfound:
  %cp = call i64 @b_utf8_length(ptr %s, i64 %found)
  %cpf = sitofp i64 %cp to double
  %cpv = call ptr @j_num(double %cpf)
  call void @j_push(ptr %out, ptr %cpv)
  %next = add i64 %found, 1
  br label %sloop
array:
  %at = call i32 @b_tag(ptr %arg)
  %isarr = icmp eq i32 %at, 5
  br i1 %isarr, label %arrarg, label %scalararg
arrarg:
  br label %astart
scalararg:
  %wrapped = call ptr @b_one(ptr %arg)
  br label %astart
astart:
  %needle = phi ptr [%arg, %arrarg], [%wrapped, %scalararg]
  %alen = call i64 @b_len(ptr %input)
  %blen = call i64 @b_len(ptr %needle)
  %last = sub i64 %alen, %blen
  %notempty = icmp sgt i64 %blen, 0
  br i1 %notempty, label %aloop, label %done
aloop:
  %i = phi i64 [0, %astart], [%inext, %advance]
  %more = icmp sle i64 %i, %last
  br i1 %more, label %inner, label %done
inner:
  %j = phi i64 [0, %aloop], [%jnext, %compare]
  %jmore = icmp slt i64 %j, %blen
  br i1 %jmore, label %compare, label %match
compare:
  %p = add i64 %i, %j
  %av = call ptr @j_at(ptr %input, i64 %p)
  %bv = call ptr @j_at(ptr %needle, i64 %j)
  %cmp = call i32 @j_cmp(ptr %av, ptr %bv)
  %same = icmp eq i32 %cmp, 0
  %jnext = add i64 %j, 1
  br i1 %same, label %inner, label %advance
match:
  %f = sitofp i64 %i to double
  %v = call ptr @j_num(double %f)
  call void @j_push(ptr %out, ptr %v)
  br label %advance
advance:
  %inext = add i64 %i, 1
  br label %aloop
done:
  ret ptr %out
}

define ptr @b_transpose(ptr %input) {
entry:
  %out = call ptr @j_array()
  %n = call i64 @b_len(ptr %input)
  br label %maxloop
maxloop:
  %i = phi i64 [0, %entry], [%next, %maxbody]
  %max = phi i64 [0, %entry], [%newmax, %maxbody]
  %more = icmp slt i64 %i, %n
  br i1 %more, label %maxbody, label %outer
maxbody:
  %v = call ptr @j_at(ptr %input, i64 %i)
  %len = call i64 @b_len(ptr %v)
  %bigger = icmp sgt i64 %len, %max
  %newmax = select i1 %bigger, i64 %len, i64 %max
  %next = add i64 %i, 1
  br label %maxloop
outer:
  %col = phi i64 [0, %maxloop], [%colnext, %rowdone]
  %colmore = icmp slt i64 %col, %max
  br i1 %colmore, label %rowstart, label %done
rowstart:
  %row = call ptr @j_array()
  br label %inner
inner:
  %j = phi i64 [0, %rowstart], [%jnext, %body]
  %jmore = icmp slt i64 %j, %n
  br i1 %jmore, label %body, label %rowdone
body:
  %srcrow = call ptr @j_at(ptr %input, i64 %j)
  %value = call ptr @j_at(ptr %srcrow, i64 %col)
  call void @j_push(ptr %row, ptr %value)
  %jnext = add i64 %j, 1
  br label %inner
rowdone:
  call void @j_push(ptr %out, ptr %row)
  %colnext = add i64 %col, 1
  br label %outer
done:
  ret ptr %out
}

define void @b_combine(ptr %sets, i64 %pos, ptr %prefix, ptr %out) {
entry:
  %n = call i64 @b_len(ptr %sets)
  %end = icmp sge i64 %pos, %n
  br i1 %end, label %emit, label %start
emit:
  call void @j_push(ptr %out, ptr %prefix)
  ret void
start:
  %set = call ptr @j_at(ptr %sets, i64 %pos)
  %len = call i64 @b_len(ptr %set)
  %pn = add i64 %pos, 1
  br label %loop
loop:
  %i = phi i64 [0, %start], [%next, %body]
  %more = icmp slt i64 %i, %len
  br i1 %more, label %body, label %done
body:
  %value = call ptr @j_at(ptr %set, i64 %i)
  %p = call ptr @j_clone(ptr %prefix)
  call void @j_push(ptr %p, ptr %value)
  call void @b_combine(ptr %sets, i64 %pn, ptr %p, ptr %out)
  %next = add i64 %i, 1
  br label %loop
done:
  ret void
}

define ptr @b_combinations(ptr %args, ptr %input, ptr %env) {
entry:
  %out = call ptr @j_array()
  %prefix = call ptr @j_array()
  %argc = call i64 @b_len(ptr %args)
  %none = icmp eq i64 %argc, 0
  br i1 %none, label %simple, label %arg
simple:
  call void @b_combine(ptr %input, i64 0, ptr %prefix, ptr %out)
  ret ptr %out
arg:
  %ns = call ptr @b_arg(ptr %args, i64 0, ptr %input, ptr %env)
  %len = call i64 @b_len(ptr %ns)
  br label %outer
outer:
  %i = phi i64 [0, %arg], [%next, %combine]
  %more = icmp slt i64 %i, %len
  br i1 %more, label %body, label %done
body:
  %nv = call ptr @j_at(ptr %ns, i64 %i)
  %nf = call double @b_number(ptr %nv)
  %n = fptosi double %nf to i64
  %sets = call ptr @j_array()
  br label %repeat
repeat:
  %j = phi i64 [0, %body], [%jn, %put]
  %jm = icmp slt i64 %j, %n
  br i1 %jm, label %put, label %combine
put:
  call void @j_push(ptr %sets, ptr %input)
  %jn = add i64 %j, 1
  br label %repeat
combine:
  call void @b_combine(ptr %sets, i64 0, ptr %prefix, ptr %out)
  %next = add i64 %i, 1
  br label %outer
done:
  ret ptr %out
}

define ptr @b_setpath_family(ptr %args, ptr %input, ptr %env) {
entry:
  %out = call ptr @j_array()
  %ps = call ptr @b_arg(ptr %args, i64 0, ptr %input, ptr %env)
  %vs = call ptr @b_arg(ptr %args, i64 1, ptr %input, ptr %env)
  %pn = call i64 @b_len(ptr %ps)
  %vn = call i64 @b_len(ptr %vs)
  br label %outer
outer:
  %i = phi i64 [0, %entry], [%next, %advance]
  %more = icmp slt i64 %i, %pn
  br i1 %more, label %body, label %done
body:
  %path = call ptr @j_at(ptr %ps, i64 %i)
  br label %inner
inner:
  %j = phi i64 [0, %body], [%jnext, %put]
  %jmore = icmp slt i64 %j, %vn
  br i1 %jmore, label %put, label %advance
put:
  %value = call ptr @j_at(ptr %vs, i64 %j)
  %set = call ptr @b_setpath(ptr %input, ptr %path, i64 0, ptr %value)
  call void @b_pushvalid(ptr %out, ptr %set)
  %jnext = add i64 %j, 1
  br label %inner
advance:
  %next = add i64 %i, 1
  br label %outer
done:
  ret ptr %out
}

define void @b_paths(ptr %input, ptr %path, ptr %filter, ptr %env, ptr %out, i1 %leaves) {
entry:
  %n = call i64 @b_len(ptr %path)
  %nonroot = icmp sgt i64 %n, 0
  %t = call i32 @b_tag(ptr %input)
  %a = icmp eq i32 %t, 5
  %o = icmp eq i32 %t, 6
  %iter = or i1 %a, %o
  br i1 %nonroot, label %select, label %descend
select:
  %hasfilter = icmp ne ptr %filter, null
  br i1 %hasfilter, label %eval, label %leafcheck
eval:
  %conds = call ptr @j_eval(ptr %filter, ptr %input, ptr %env)
  %cn = call i64 @b_len(ptr %conds)
  br label %condloop
condloop:
  %ci = phi i64 [0, %eval], [%cnext, %condadvance]
  %cm = icmp slt i64 %ci, %cn
  br i1 %cm, label %condbody, label %descend
condbody:
  %cond = call ptr @j_at(ptr %conds, i64 %ci)
  %ct = call i1 @j_truth(ptr %cond)
  br i1 %ct, label %condput, label %condadvance
condput:
  call void @j_push(ptr %out, ptr %path)
  br label %condadvance
condadvance:
  %cnext = add i64 %ci, 1
  br label %condloop
leafcheck:
  %exclude = and i1 %leaves, %iter
  br i1 %exclude, label %descend, label %put
put:
  call void @j_push(ptr %out, ptr %path)
  br label %descend
descend:
  br i1 %iter, label %children, label %done
children:
  %keys = call ptr @b_keys(ptr %input, i1 false)
  %kn = call i64 @b_len(ptr %keys)
  br label %loop
loop:
  %i = phi i64 [0, %children], [%next, %body]
  %more = icmp slt i64 %i, %kn
  br i1 %more, label %body, label %done
body:
  %key = call ptr @j_at(ptr %keys, i64 %i)
  %child = call ptr @j_get(ptr %input, ptr %key)
  %p = call ptr @j_clone(ptr %path)
  call void @j_push(ptr %p, ptr %key)
  call void @b_paths(ptr %child, ptr %p, ptr %filter, ptr %env, ptr %out, i1 %leaves)
  %next = add i64 %i, 1
  br label %loop
done:
  ret void
}

define void @b_recurse(ptr %args, ptr %input, ptr %env, ptr %out, i64 %depth) {
entry:
  call void @b_recurse_count(ptr %args, ptr %input, ptr %env, ptr %out, i64 %depth, i64 -1)
  ret void
}

define void @b_recurse_count(ptr %args, ptr %input, ptr %env, ptr %out, i64 %depth, i64 %count) {
entry:
  %bounded = icmp sge i64 %count, 0
  %produced = call i64 @b_len(ptr %out)
  %enough = icmp sge i64 %produced, %count
  %finished = and i1 %bounded, %enough
  br i1 %finished, label %done, label %depthcheck
depthcheck:
  %too = icmp sgt i64 %depth, 10000
  br i1 %too, label %bad, label %start
bad:
  call void @j_fail(ptr @b.errdeep)
  ret void
start:
  call void @j_push(ptr %out, ptr %input)
  %countnow = call i64 @b_len(ptr %out)
  %fullnow = icmp sge i64 %countnow, %count
  %donenow = and i1 %bounded, %fullnow
  br i1 %donenow, label %done, label %evaluate
evaluate:
  %argc = call i64 @b_len(ptr %args)
  %hasfilter = icmp sgt i64 %argc, 0
  br i1 %hasfilter, label %filter, label %default
filter:
  %fs = call ptr @b_arg(ptr %args, i64 0, ptr %input, ptr %env)
  br label %children
default:
  %tag = call i32 @b_tag(ptr %input)
  %a = icmp eq i32 %tag, 5
  %o = icmp eq i32 %tag, 6
  %iter = or i1 %a, %o
  br i1 %iter, label %values, label %done
values:
  %vs = call ptr @b_values(ptr %input)
  br label %children
children:
  %items = phi ptr [%fs, %filter], [%vs, %values]
  %n = call i64 @b_len(ptr %items)
  %hascond = icmp sge i64 %argc, 2
  %dn = add i64 %depth, 1
  br label %loop
loop:
  %i = phi i64 [0, %children], [%next, %advance]
  %more = icmp slt i64 %i, %n
  br i1 %more, label %body, label %done
body:
  %v = call ptr @j_at(ptr %items, i64 %i)
  br i1 %hascond, label %cond, label %recur
cond:
  %cs = call ptr @b_arg(ptr %args, i64 1, ptr %v, ptr %env)
  %cv = call ptr @j_at(ptr %cs, i64 0)
  %truth = call i1 @j_truth(ptr %cv)
  br i1 %truth, label %recur, label %advance
recur:
  call void @b_recurse_count(ptr %args, ptr %v, ptr %env, ptr %out, i64 %dn, i64 %count)
  br label %advance
advance:
  %next = add i64 %i, 1
  br label %loop
done:
  ret void
}

define void @b_while(ptr %args, ptr %input, ptr %env, ptr %out, i1 %until, i64 %depth) {
entry:
  call void @b_while_count(ptr %args, ptr %input, ptr %env, ptr %out, i1 %until, i64 %depth, i64 -1)
  ret void
}

define void @b_while_count(ptr %args, ptr %input, ptr %env, ptr %out, i1 %until, i64 %depth, i64 %count) {
entry:
  %bounded = icmp sge i64 %count, 0
  %produced = call i64 @b_len(ptr %out)
  %enough = icmp sge i64 %produced, %count
  %finished = and i1 %bounded, %enough
  br i1 %finished, label %done, label %depthcheck
depthcheck:
  %too = icmp sgt i64 %depth, 100000
  br i1 %too, label %bad, label %start
bad:
  call void @j_fail(ptr @b.errdeep)
  ret void
start:
  %cs = call ptr @b_arg(ptr %args, i64 0, ptr %input, ptr %env)
  %cn = call i64 @b_len(ptr %cs)
  br label %condloop
condloop:
  %ci = phi i64 [0, %start], [%cnext, %cadvance]
  %cm = icmp slt i64 %ci, %cn
  br i1 %cm, label %condbody, label %done
condbody:
  %c = call ptr @j_at(ptr %cs, i64 %ci)
  %truth = call i1 @j_truth(ptr %c)
  %continue = xor i1 %truth, %until
  br i1 %continue, label %update, label %stop
stop:
  br i1 %until, label %putstop, label %cadvance
putstop:
  call void @j_push(ptr %out, ptr %input)
  br label %cadvance
update:
  br i1 %until, label %eval, label %put
put:
  call void @j_push(ptr %out, ptr %input)
  %afterput = call i64 @b_len(ptr %out)
  %putfull = icmp sge i64 %afterput, %count
  %putdone = and i1 %bounded, %putfull
  br i1 %putdone, label %done, label %eval
eval:
  %us = call ptr @b_arg(ptr %args, i64 1, ptr %input, ptr %env)
  %un = call i64 @b_len(ptr %us)
  %dn = add i64 %depth, 1
  br label %uloop
uloop:
  %ui = phi i64 [0, %eval], [%unext, %ubody]
  %um = icmp slt i64 %ui, %un
  br i1 %um, label %ubody, label %cadvance
ubody:
  %u = call ptr @j_at(ptr %us, i64 %ui)
  call void @b_while_count(ptr %args, ptr %u, ptr %env, ptr %out, i1 %until, i64 %dn, i64 %count)
  %unext = add i64 %ui, 1
  br label %uloop
cadvance:
  %cnext = add i64 %ci, 1
  br label %condloop
done:
  ret void
}

define ptr @b_index_object(ptr %args, ptr %input, ptr %env) {
entry:
  %argc = call i64 @b_len(ptr %args)
  %two = icmp sge i64 %argc, 2
  br i1 %two, label %generator, label %values
generator:
  %gs = call ptr @b_arg(ptr %args, i64 0, ptr %input, ptr %env)
  br label %start
values:
  %vs = call ptr @b_values(ptr %input)
  br label %start
start:
  %items = phi ptr [%gs, %generator], [%vs, %values]
  %keyidx = select i1 %two, i64 1, i64 0
  %n = call i64 @b_len(ptr %items)
  %out = call ptr @j_object()
  br label %loop
loop:
  %i = phi i64 [0, %start], [%next, %body]
  %more = icmp slt i64 %i, %n
  br i1 %more, label %body, label %done
body:
  %v = call ptr @j_at(ptr %items, i64 %i)
  %ks = call ptr @b_arg(ptr %args, i64 %keyidx, ptr %v, ptr %env)
  %k = call ptr @j_at(ptr %ks, i64 0)
  %key = call ptr @b_tostring(ptr %k)
  call void @j_put(ptr %out, ptr %key, ptr %v)
  %next = add i64 %i, 1
  br label %loop
done:
  %r = call ptr @b_one(ptr %out)
  ret ptr %r
}

define ptr @b_in_filter(ptr %args, ptr %input, ptr %env) {
entry:
  %argc = call i64 @b_len(ptr %args)
  %two = icmp sge i64 %argc, 2
  %a0 = call ptr @b_arg(ptr %args, i64 0, ptr %input, ptr %env)
  br i1 %two, label %twoargs, label %onearg
twoargs:
  %a1 = call ptr @b_arg(ptr %args, i64 1, ptr %input, ptr %env)
  br label %start
onearg:
  %self = call ptr @b_one(ptr %input)
  br label %start
start:
  %left = phi ptr [%a0, %twoargs], [%self, %onearg]
  %right = phi ptr [%a1, %twoargs], [%a0, %onearg]
  %ln = call i64 @b_len(ptr %left)
  %rn = call i64 @b_len(ptr %right)
  br label %outer
outer:
  %i = phi i64 [0, %start], [%next, %advance]
  %more = icmp slt i64 %i, %ln
  br i1 %more, label %body, label %no
body:
  %l = call ptr @j_at(ptr %left, i64 %i)
  br label %inner
inner:
  %j = phi i64 [0, %body], [%jn, %compare]
  %jm = icmp slt i64 %j, %rn
  br i1 %jm, label %compare, label %advance
compare:
  %r = call ptr @j_at(ptr %right, i64 %j)
  %cmp = call i32 @j_cmp(ptr %l, ptr %r)
  %same = icmp eq i32 %cmp, 0
  %jn = add i64 %j, 1
  br i1 %same, label %yes, label %inner
advance:
  %next = add i64 %i, 1
  br label %outer
yes:
  br label %done
no:
  br label %done
done:
  %result = phi i1 [true, %yes], [false, %no]
  %b = call ptr @j_bool(i1 %result)
  %out = call ptr @b_one(ptr %b)
  ret ptr %out
}

define i1 @b_known(ptr %name, i64 %arity) {
entry:
  %id = call i32 @b_find(ptr %name, ptr @b.names)
  %core = icmp sge i32 %id, 0
  br i1 %core, label %checkarity, label %other
checkarity:
  %mask = call i64 @b_arity_mask(i32 %id)
  %small = icmp ult i64 %arity, 8
  br i1 %small, label %maskcheck, label %no
maskcheck:
  %bit = shl i64 1, %arity
  %matched = and i64 %mask, %bit
  %valid = icmp ne i64 %matched, 0
  ret i1 %valid
other:
  %text = call i1 @j_text_known(ptr %name, i64 %arity)
  %math = call i1 @j_math_known(ptr %name, i64 %arity)
  %streams = call i1 @j_stream_known(ptr %name, i64 %arity)
  %time = call i1 @j_time_known(ptr %name, i64 %arity)
  %regex = call i1 @j_regex_known(ptr %name, i64 %arity)
  %cli = call i1 @j_cli_known(ptr %name, i64 %arity)
  %a = or i1 %text, %math
  %b = or i1 %streams, %time
  %c = or i1 %regex, %cli
  %d = or i1 %a, %b
  %e = or i1 %d, %c
  ret i1 %e
no:
  ret i1 false
}

define i64 @b_arity_mask(i32 %id) {
entry:
  switch i32 %id, label %zero [
    i32 1, label %zeroone i32 22, label %one i32 23, label %one i32 24, label %one i32 25, label %one
    i32 28, label %one i32 29, label %one i32 31, label %one i32 34, label %one i32 35, label %one
    i32 36, label %zeroone i32 37, label %zeroone i32 38, label %one i32 39, label %one i32 40, label %one
    i32 41, label %range i32 42, label %zeroonetwo i32 43, label %zeroonetwo
    i32 44, label %zeroone i32 45, label %zeroone i32 46, label %onetwo i32 47, label %two i32 48, label %two
    i32 49, label %one i32 52, label %one i32 54, label %zeroone i32 55, label %one i32 56, label %two
    i32 57, label %one i32 58, label %zeroone i32 60, label %zeroonetwo i32 62, label %one i32 63, label %two
    i32 64, label %two i32 65, label %one i32 66, label %one i32 67, label %one i32 68, label %one i32 69, label %onetwo i32 70, label %onetwo
  ]
zero:
  ret i64 1
one:
  ret i64 2
two:
  ret i64 4
zeroone:
  ret i64 3
onetwo:
  ret i64 6
zeroonetwo:
  ret i64 7
range:
  ret i64 14
}

define void @b_catalog(ptr %out, ptr %table) {
entry:
  %slash = call ptr @j_cstr(ptr @b.slash)
  br label %outer
outer:
  %p = phi ptr [%table, %entry], [%next, %advance]
  %c = load i8, ptr %p
  %more = icmp ne i8 %c, 0
  br i1 %more, label %body, label %done
body:
  %len = call i64 @j_strlen(ptr %p)
  %name = call ptr @j_str(ptr %p, i64 %len)
  %prefix = call ptr @j_binary(i32 0, ptr %name, ptr %slash)
  %hidden = icmp eq i8 %c, 95
  br i1 %hidden, label %advance, label %inner
inner:
  %arity = phi i64 [0, %body], [%an, %arityadvance]
  %am = icmp sle i64 %arity, 4
  br i1 %am, label %check, label %advance
check:
  %valid = call i1 @b_known(ptr %name, i64 %arity)
  br i1 %valid, label %put, label %arityadvance
put:
  %af = sitofp i64 %arity to double
  %av = call ptr @j_num(double %af)
  %astr = call ptr @b_tostring(ptr %av)
  %item = call ptr @j_binary(i32 0, ptr %prefix, ptr %astr)
  call void @j_push(ptr %out, ptr %item)
  br label %arityadvance
arityadvance:
  %an = add i64 %arity, 1
  br label %inner
advance:
  %step = add i64 %len, 1
  %next = getelementptr i8, ptr %p, i64 %step
  br label %outer
done:
  ret void
}
