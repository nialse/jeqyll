@s.names = private constant [49 x i8] c"JOIN\00tostream\00fromstream\00truncate_stream\00repeat\00\00"
@s.range = private constant [6 x i8] c"range\00"
@s.recurse = private constant [8 x i8] c"recurse\00"
@s.recursedown = private constant [13 x i8] c"recurse_down\00"
@s.while = private constant [6 x i8] c"while\00"
@s.until = private constant [6 x i8] c"until\00"
@s.repeat = private constant [7 x i8] c"repeat\00"
@j_error = external global ptr

declare i32 @b_find(ptr, ptr)
declare i32 @b_tag(ptr)
declare i64 @b_len(ptr)
declare double @b_number(ptr)
declare ptr @b_one(ptr)
declare ptr @b_arg(ptr, i64, ptr, ptr)
declare void @b_extend(ptr, ptr)
declare ptr @b_values(ptr)
declare ptr @b_keys(ptr, i1)
declare ptr @b_setpath(ptr, ptr, i64, ptr)
declare ptr @b_tostring(ptr)
declare ptr @j_eval(ptr, ptr, ptr)
declare ptr @j_eval_take(ptr, ptr, ptr, i64)
declare i1 @j_is(ptr, ptr)
declare ptr @b_range_count(ptr, ptr, ptr, i64)
declare void @b_recurse_count(ptr, ptr, ptr, ptr, i64, i64)
declare void @b_while_count(ptr, ptr, ptr, ptr, i1, i64, i64)
declare ptr @j_array()
declare void @j_push(ptr, ptr)
declare ptr @j_at(ptr, i64)
declare ptr @j_get(ptr, ptr)
declare ptr @j_clone(ptr)
declare ptr @j_null()

define ptr @j_stream_builtin(ptr %name, ptr %args, ptr %input, ptr %env) {
entry:
  %id = call i32 @b_find(ptr %name, ptr @s.names)
  switch i32 %id, label %unknown [i32 0, label %join i32 1, label %tostream i32 2, label %fromstream i32 3, label %truncate i32 4, label %repeat]
unknown:
  ret ptr null
join:
  %joinr = call ptr @s_join(ptr %args, ptr %input, ptr %env)
  ret ptr %joinr
tostream:
  %tsr = call ptr @j_array()
  %path = call ptr @j_array()
  call void @s_tostream(ptr %input, ptr %path, ptr %tsr)
  ret ptr %tsr
fromstream:
  %fsr = call ptr @s_fromstream(ptr %args, ptr %input, ptr %env)
  ret ptr %fsr
truncate:
  %tr = call ptr @s_truncate(ptr %args, ptr %input, ptr %env)
  ret ptr %tr
repeat:
  %out = call ptr @j_array()
  br label %repeatloop
repeatloop:
  %values = call ptr @b_arg(ptr %args, i64 0, ptr %input, ptr %env)
  call void @b_extend(ptr %out, ptr %values)
  %err = load ptr, ptr @j_error
  %failed = icmp ne ptr %err, null
  br i1 %failed, label %repeatdone, label %repeatloop
repeatdone:
  ret ptr %out
}

define void @s_tostream(ptr %input, ptr %path, ptr %out) {
entry:
  %tag = call i32 @b_tag(ptr %input)
  %a = icmp eq i32 %tag, 5
  %o = icmp eq i32 %tag, 6
  %iter = or i1 %a, %o
  %len = call i64 @b_len(ptr %input)
  %nonempty = icmp sgt i64 %len, 0
  %children = and i1 %iter, %nonempty
  br i1 %children, label %start, label %leaf
leaf:
  %event = call ptr @j_array()
  call void @j_push(ptr %event, ptr %path)
  call void @j_push(ptr %event, ptr %input)
  call void @j_push(ptr %out, ptr %event)
  ret void
start:
  %keys = call ptr @b_keys(ptr %input, i1 false)
  br label %loop
loop:
  %i = phi i64 [0, %start], [%next, %body]
  %lastpath = phi ptr [%path, %start], [%childpath, %body]
  %more = icmp slt i64 %i, %len
  br i1 %more, label %body, label %close
body:
  %key = call ptr @j_at(ptr %keys, i64 %i)
  %value = call ptr @j_get(ptr %input, ptr %key)
  %childpath = call ptr @j_clone(ptr %path)
  call void @j_push(ptr %childpath, ptr %key)
  call void @s_tostream(ptr %value, ptr %childpath, ptr %out)
  %next = add i64 %i, 1
  br label %loop
close:
  %closeevent = call ptr @b_one(ptr %lastpath)
  call void @j_push(ptr %out, ptr %closeevent)
  ret void
}

define ptr @s_truncate(ptr %args, ptr %input, ptr %env) {
entry:
  %out = call ptr @j_array()
  %f = call double @b_number(ptr %input)
  %depth = fptosi double %f to i64
  %nil = call ptr @j_null()
  %events = call ptr @b_arg(ptr %args, i64 0, ptr %nil, ptr %env)
  %n = call i64 @b_len(ptr %events)
  br label %loop
loop:
  %i = phi i64 [0, %entry], [%next, %advance]
  %more = icmp slt i64 %i, %n
  br i1 %more, label %body, label %done
body:
  %event = call ptr @j_at(ptr %events, i64 %i)
  %path = call ptr @j_at(ptr %event, i64 0)
  %pn = call i64 @b_len(ptr %path)
  %keep = icmp sgt i64 %pn, %depth
  br i1 %keep, label %copy, label %advance
copy:
  %newpath = call ptr @j_array()
  %new = call ptr @j_array()
  br label %inner
inner:
  %j = phi i64 [%depth, %copy], [%jn, %putkey]
  %jm = icmp slt i64 %j, %pn
  br i1 %jm, label %putkey, label %eventbody
putkey:
  %key = call ptr @j_at(ptr %path, i64 %j)
  call void @j_push(ptr %newpath, ptr %key)
  %jn = add i64 %j, 1
  br label %inner
eventbody:
  call void @j_push(ptr %new, ptr %newpath)
  %en = call i64 @b_len(ptr %event)
  %hasvalue = icmp eq i64 %en, 2
  br i1 %hasvalue, label %value, label %emit
value:
  %v = call ptr @j_at(ptr %event, i64 1)
  call void @j_push(ptr %new, ptr %v)
  br label %emit
emit:
  call void @j_push(ptr %out, ptr %new)
  br label %advance
advance:
  %next = add i64 %i, 1
  br label %loop
done:
  ret ptr %out
}

define ptr @s_fromstream(ptr %args, ptr %input, ptr %env) {
entry:
  %out = call ptr @j_array()
  %events = call ptr @b_arg(ptr %args, i64 0, ptr %input, ptr %env)
  %n = call i64 @b_len(ptr %events)
  %nil = call ptr @j_null()
  br label %loop
loop:
  %i = phi i64 [0, %entry], [%next, %advance]
  %current = phi ptr [%nil, %entry], [%newcurrent, %advance]
  %more = icmp slt i64 %i, %n
  br i1 %more, label %body, label %done
body:
  %event = call ptr @j_at(ptr %events, i64 %i)
  %en = call i64 @b_len(ptr %event)
  %path = call ptr @j_at(ptr %event, i64 0)
  %pn = call i64 @b_len(ptr %path)
  %data = icmp eq i64 %en, 2
  br i1 %data, label %set, label %closing
set:
  %value = call ptr @j_at(ptr %event, i64 1)
  %updated = call ptr @b_setpath(ptr %current, ptr %path, i64 0, ptr %value)
  %root = icmp eq i64 %pn, 0
  br label %emitcheck
closing:
  %closedroot = icmp eq i64 %pn, 1
  br label %emitcheck
emitcheck:
  %result = phi ptr [%updated, %set], [%current, %closing]
  %emit = phi i1 [%root, %set], [%closedroot, %closing]
  br i1 %emit, label %output, label %keep
output:
  call void @j_push(ptr %out, ptr %result)
  br label %advance
keep:
  br label %advance
advance:
  %newcurrent = phi ptr [%nil, %output], [%result, %keep]
  %next = add i64 %i, 1
  br label %loop
done:
  ret ptr %out
}

define ptr @s_join(ptr %args, ptr %input, ptr %env) {
entry:
  %out = call ptr @j_array()
  %argc = call i64 @b_len(ptr %args)
  %indices = call ptr @b_arg(ptr %args, i64 0, ptr %input, ptr %env)
  %in = call i64 @b_len(ptr %indices)
  %two = icmp eq i64 %argc, 2
  %four = icmp sge i64 %argc, 4
  br label %outer
outer:
  %i = phi i64 [0, %entry], [%next, %idone]
  %more = icmp slt i64 %i, %in
  br i1 %more, label %body, label %done
body:
  %index = call ptr @j_at(ptr %indices, i64 %i)
  %collected = call ptr @j_array()
  br i1 %two, label %values, label %generator
values:
  %vs = call ptr @b_values(ptr %input)
  br label %items
generator:
  %gs = call ptr @b_arg(ptr %args, i64 1, ptr %input, ptr %env)
  br label %items
items:
  %rows = phi ptr [%vs, %values], [%gs, %generator]
  %keyidx = select i1 %two, i64 1, i64 2
  %rn = call i64 @b_len(ptr %rows)
  br label %rowloop
rowloop:
  %ri = phi i64 [0, %items], [%rinext, %rowadvance]
  %rm = icmp slt i64 %ri, %rn
  br i1 %rm, label %rowbody, label %rowsdone
rowbody:
  %row = call ptr @j_at(ptr %rows, i64 %ri)
  %ks = call ptr @b_arg(ptr %args, i64 %keyidx, ptr %row, ptr %env)
  %kn = call i64 @b_len(ptr %ks)
  br label %keyloop
keyloop:
  %ki = phi i64 [0, %rowbody], [%kinext, %keyadvance]
  %km = icmp slt i64 %ki, %kn
  br i1 %km, label %keybody, label %rowadvance
keybody:
  %key = call ptr @j_at(ptr %ks, i64 %ki)
  %value = call ptr @j_get(ptr %index, ptr %key)
  %pair = call ptr @j_array()
  call void @j_push(ptr %pair, ptr %row)
  call void @j_push(ptr %pair, ptr %value)
  br i1 %four, label %transform, label %default
transform:
  %transformed = call ptr @b_arg(ptr %args, i64 3, ptr %pair, ptr %env)
  call void @b_extend(ptr %out, ptr %transformed)
  br label %keyadvance
default:
  br i1 %two, label %collect, label %emit
collect:
  call void @j_push(ptr %collected, ptr %pair)
  br label %keyadvance
emit:
  call void @j_push(ptr %out, ptr %pair)
  br label %keyadvance
keyadvance:
  %kinext = add i64 %ki, 1
  br label %keyloop
rowadvance:
  %rinext = add i64 %ri, 1
  br label %rowloop
rowsdone:
  br i1 %two, label %emitcollected, label %idone
emitcollected:
  call void @j_push(ptr %out, ptr %collected)
  br label %idone
idone:
  %next = add i64 %i, 1
  br label %outer
done:
  ret ptr %out
}

define ptr @j_stream_names() {
entry:
  ret ptr @s.names
}

define i1 @j_stream_known(ptr %name, i64 %arity) {
entry:
  %id = call i32 @b_find(ptr %name, ptr @s.names)
  %known = icmp sge i32 %id, 0
  br i1 %known, label %check, label %no
check:
  switch i32 %id, label %one [i32 0, label %join i32 1, label %zero]
zero:
  %z = icmp eq i64 %arity, 0
  ret i1 %z
one:
  %o = icmp eq i64 %arity, 1
  ret i1 %o
join:
  %lo = icmp uge i64 %arity, 2
  %hi = icmp ule i64 %arity, 4
  %range = and i1 %lo, %hi
  ret i1 %range
no:
  ret i1 false
}

define ptr @j_builtin_take(ptr %name, ptr %args, ptr %input, ptr %env, i64 %count) {
entry:
  %range = call i1 @j_is(ptr %name, ptr @s.range)
  br i1 %range, label %ranger, label %recursecheck
ranger:
  %rs = call ptr @b_range_count(ptr %args, ptr %input, ptr %env, i64 %count)
  ret ptr %rs
recursecheck:
  %recurse = call i1 @j_is(ptr %name, ptr @s.recurse)
  %recursedown = call i1 @j_is(ptr %name, ptr @s.recursedown)
  %rec = or i1 %recurse, %recursedown
  br i1 %rec, label %recurser, label %whilecheck
recurser:
  %recs = call ptr @j_array()
  call void @b_recurse_count(ptr %args, ptr %input, ptr %env, ptr %recs, i64 0, i64 %count)
  ret ptr %recs
whilecheck:
  %while = call i1 @j_is(ptr %name, ptr @s.while)
  %until = call i1 @j_is(ptr %name, ptr @s.until)
  %wh = or i1 %while, %until
  br i1 %wh, label %whiler, label %repeatcheck
whiler:
  %whs = call ptr @j_array()
  call void @b_while_count(ptr %args, ptr %input, ptr %env, ptr %whs, i1 %until, i64 0, i64 %count)
  ret ptr %whs
repeatcheck:
  %repeat = call i1 @j_is(ptr %name, ptr @s.repeat)
  br i1 %repeat, label %repeatr, label %unknown
repeatr:
  %out = call ptr @j_array()
  %ast = call ptr @j_at(ptr %args, i64 0)
  br label %loop
loop:
  %produced = call i64 @b_len(ptr %out)
  %enough = icmp sge i64 %produced, %count
  %error = load ptr, ptr @j_error
  %failed = icmp ne ptr %error, null
  %done = or i1 %enough, %failed
  br i1 %done, label %return, label %body
body:
  %remaining = sub i64 %count, %produced
  %values = call ptr @j_eval_take(ptr %ast, ptr %input, ptr %env, i64 %remaining)
  call void @b_extend(ptr %out, ptr %values)
  br label %loop
return:
  ret ptr %out
unknown:
  ret ptr null
}
