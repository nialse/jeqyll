%GV = type { i32, i32, double, i64, i64, ptr, ptr }
%GN = type { i32, i32, ptr, ptr, ptr, ptr, ptr, i64, i64 }
%GE = type { ptr, ptr, ptr, i32, ptr, ptr }
%GW = type { ptr, i32, i32, ptr, ptr, ptr, ptr, ptr, ptr, ptr, i64 }
%GK = type { i32, i32, ptr, ptr, ptr, ptr, ptr, ptr, ptr, i64 }
%GH = type { ptr, ptr, ptr, ptr, ptr, ptr }
%GA = type { ptr, ptr, ptr, ptr, ptr, ptr, ptr, i64 }

@j_error = external global ptr
@ev_break_name = external global ptr
@ev_module_directory = external global ptr
@cli_halted = external global i1
@j_deferred_input_error = external global ptr
@j_gc_pressure = external global i64
@j_collect_enabled = external global i1
@g_next_depth = internal global i64 0
@g_keyerror = private constant [33 x i8] c"Cannot use non-string object key\00"
@g_generators = private constant [130 x i8] c"select\00range\00recurse\00recurse_down\00while\00until\00repeat\00first\00last\00nth\00limit\00skip\00isempty\00inputs\00any\00all\00fromstream\00truncate_stream\00\00"
@g_range_error = private constant [29 x i8] c"Range bounds must be numeric\00"
@g_limit_error = private constant [37 x i8] c"limit doesn't support negative count\00"
@g_skip_error = private constant [36 x i8] c"skip doesn't support negative count\00"
@g_nth_error = private constant [37 x i8] c"nth doesn't support negative indices\00"
@g_filterargs = private constant [125 x i8] c"sort_by\00group_by\00unique_by\00min_by\00max_by\00map\00map_values\00with_entries\00paths\00leaf_paths\00walk\00INDEX\00IN\00path\00pick\00del\00debug\00add\00\00"
@g_sub = private constant [4 x i8] c"sub\00"
@g_gsub = private constant [5 x i8] c"gsub\00"
@g_join = private constant [5 x i8] c"JOIN\00"
@g_in = private constant [3 x i8] c"IN\00"
@g_tree_names = private constant [27 x i8] c"tostream\00paths\00leaf_paths\00\00"
@g_reverse_args = private constant [146 x i8] c"pow\00atan2\00hypot\00fmod\00remainder\00drem\00ldexp\00scalb\00scalbln\00scalbn\00fmax\00fmin\00fdim\00copysign\00nextafter\00nexttoward\00jn\00yn\00fma\00setpath\00match\00test\00capture\00\00"

declare ptr @j_alloc(i64)
declare ptr @j_array()
declare ptr @j_object()
declare ptr @j_null()
declare ptr @j_num(double)
declare ptr @j_bool(i1)
declare ptr @j_cstr(ptr)
declare void @j_push(ptr, ptr)
declare ptr @j_at(ptr, i64)
declare ptr @j_clone(ptr)
declare void @j_put(ptr, ptr, ptr)
declare ptr @j_get(ptr, ptr)
declare i32 @j_cmp(ptr, ptr)
declare i1 @j_is(ptr, ptr)
declare i1 @j_truth(ptr)
declare ptr @j_binary(i32, ptr, ptr)
declare ptr @j_negate(ptr)
declare void @j_fail(ptr)
declare void @j_object_key_error(ptr)
declare ptr @j_eval_atom(ptr, ptr, ptr)
declare ptr @j_bind(ptr, ptr, ptr)
declare ptr @ev_node(i32, i32, ptr, ptr, ptr, ptr)
declare ptr @ev_lookup(ptr, ptr, i32, i64)
declare ptr @ev_bindpattern(ptr, ptr, ptr, ptr)
declare ptr @ev_patternnull(ptr, ptr)
declare ptr @ev_importenv(ptr, ptr, ptr)
declare void @ev_itererror(ptr)
declare ptr @ev_slice(ptr, ptr, ptr)
declare i64 @b_len(ptr)
declare ptr @b_data(ptr)
declare i32 @b_find(ptr, ptr)
declare double @b_number(ptr)
declare ptr @b_setpath(ptr, ptr, i64, ptr)
declare ptr @b_keys(ptr, i1)
declare ptr @cli_take_input()
declare void @j_collect(ptr)
declare ptr @j_expand_builtin(ptr, ptr, ptr, ptr)

define internal ptr @g_work(ptr %iterator, i32 %kind, i32 %op, ptr %node, ptr %input, ptr %env, ptr %continuation, ptr %handler, ptr %a, ptr %b, i64 %index) {
  %work = call ptr @j_alloc(i64 80)
  %previous = load ptr, ptr %iterator
  store ptr %previous, ptr %work
  %kp = getelementptr %GW, ptr %work, i32 0, i32 1
  store i32 %kind, ptr %kp
  %op.p = getelementptr %GW, ptr %work, i32 0, i32 2
  store i32 %op, ptr %op.p
  %np = getelementptr %GW, ptr %work, i32 0, i32 3
  store ptr %node, ptr %np
  %ip = getelementptr %GW, ptr %work, i32 0, i32 4
  store ptr %input, ptr %ip
  %ep = getelementptr %GW, ptr %work, i32 0, i32 5
  store ptr %env, ptr %ep
  %cp = getelementptr %GW, ptr %work, i32 0, i32 6
  store ptr %continuation, ptr %cp
  %hp = getelementptr %GW, ptr %work, i32 0, i32 7
  store ptr %handler, ptr %hp
  %ap = getelementptr %GW, ptr %work, i32 0, i32 8
  store ptr %a, ptr %ap
  %bp = getelementptr %GW, ptr %work, i32 0, i32 9
  store ptr %b, ptr %bp
  %xp = getelementptr %GW, ptr %work, i32 0, i32 10
  store i64 %index, ptr %xp
  store ptr %work, ptr %iterator
  ret ptr %work
}

define internal ptr @g_cont(i32 %kind, i32 %op, ptr %parent, ptr %env, ptr %handler, ptr %a, ptr %b, ptr %c, ptr %d, i64 %index) {
  %cont = call ptr @j_alloc(i64 72)
  store i32 %kind, ptr %cont
  %op.p = getelementptr %GK, ptr %cont, i32 0, i32 1
  store i32 %op, ptr %op.p
  %pp = getelementptr %GK, ptr %cont, i32 0, i32 2
  store ptr %parent, ptr %pp
  %ep = getelementptr %GK, ptr %cont, i32 0, i32 3
  store ptr %env, ptr %ep
  %hp = getelementptr %GK, ptr %cont, i32 0, i32 4
  store ptr %handler, ptr %hp
  %ap = getelementptr %GK, ptr %cont, i32 0, i32 5
  store ptr %a, ptr %ap
  %bp = getelementptr %GK, ptr %cont, i32 0, i32 6
  store ptr %b, ptr %bp
  %cp = getelementptr %GK, ptr %cont, i32 0, i32 7
  store ptr %c, ptr %cp
  %dp = getelementptr %GK, ptr %cont, i32 0, i32 8
  store ptr %d, ptr %dp
  %xp = getelementptr %GK, ptr %cont, i32 0, i32 9
  store i64 %index, ptr %xp
  ret ptr %cont
}

define internal ptr @g_handler(ptr %iterator, ptr %outer, ptr %catch, ptr %env, ptr %continuation, ptr %label) {
  %handler = call ptr @j_alloc(i64 48)
  store ptr %outer, ptr %handler
  %cp = getelementptr %GH, ptr %handler, i32 0, i32 1
  store ptr %catch, ptr %cp
  %ep = getelementptr %GH, ptr %handler, i32 0, i32 2
  store ptr %env, ptr %ep
  %kp = getelementptr %GH, ptr %handler, i32 0, i32 3
  store ptr %continuation, ptr %kp
  %sp = getelementptr %GH, ptr %handler, i32 0, i32 4
  %saved = load ptr, ptr %iterator
  store ptr %saved, ptr %sp
  %lp = getelementptr %GH, ptr %handler, i32 0, i32 5
  store ptr %label, ptr %lp
  ret ptr %handler
}

define internal void @g_schedule(ptr %iterator, ptr %node, ptr %input, ptr %env, ptr %continuation, ptr %handler) {
  %work = call ptr @g_work(ptr %iterator, i32 0, i32 0, ptr %node, ptr %input, ptr %env, ptr %continuation, ptr %handler, ptr null, ptr null, i64 0)
  ret void
}

define internal void @g_values(ptr %iterator, ptr %values, ptr %continuation, ptr %handler) {
  %work = call ptr @g_work(ptr %iterator, i32 3, i32 0, ptr null, ptr %values, ptr null, ptr %continuation, ptr %handler, ptr null, ptr null, i64 0)
  ret void
}

define internal i64 @g_value_mask(ptr %name) {
entry:
  %filter = call i32 @b_find(ptr %name, ptr @g_filterargs)
  %filters = icmp sge i32 %filter, 0
  br i1 %filters, label %none, label %replacement
none:
  ret i64 0
replacement:
  %sub = call i1 @j_is(ptr %name, ptr @g_sub)
  %gsub = call i1 @j_is(ptr %name, ptr @g_gsub)
  %replace = or i1 %sub, %gsub
  br i1 %replace, label %replaceargs, label %join
replaceargs:
  ret i64 5
join:
  %joincall = call i1 @j_is(ptr %name, ptr @g_join)
  %mask = select i1 %joincall, i64 1, i64 -1
  ret i64 %mask
}

define internal void @g_native_args(ptr %iterator, ptr %node, ptr %args, i64 %index, ptr %input, ptr %env, ptr %continuation, ptr %handler) {
entry:
  %np = getelementptr %GN, ptr %node, i32 0, i32 2
  %name = load ptr, ptr %np
  %mask = call i64 @g_value_mask(ptr %name)
  %n = call i64 @b_len(ptr %args)
  %reverseid = call i32 @b_find(ptr %name, ptr @g_reverse_args)
  %reverse = icmp sge i32 %reverseid, 0
  %step = select i1 %reverse, i64 -1, i64 1
  %stepop = trunc i64 %step to i32
  br label %loop
loop:
  %i = phi i64 [%index, %entry], [%next, %skip]
  %done = icmp uge i64 %i, %n
  br i1 %done, label %invoke, label %check
check:
  %bit = shl i64 1, %i
  %masked = and i64 %mask, %bit
  %valuearg = icmp ne i64 %masked, 0
  br i1 %valuearg, label %evaluate, label %skip
skip:
  %next = add i64 %i, %step
  br label %loop
evaluate:
  %actual = call ptr @j_at(ptr %args, i64 %i)
  %cont = call ptr @g_cont(i32 31, i32 %stepop, ptr %continuation, ptr %env, ptr %handler, ptr %node, ptr %args, ptr %input, ptr null, i64 %i)
  call void @g_schedule(ptr %iterator, ptr %actual, ptr %input, ptr %env, ptr %cont, ptr %handler)
  ret void
invoke:
  %opp = getelementptr %GN, ptr %node, i32 0, i32 1
  %op = load i32, ptr %opp
  %private = icmp sle i32 %op, -2
  %boundop = select i1 %private, i32 -3, i32 -1
  %call = call ptr @ev_node(i32 7, i32 %boundop, ptr %name, ptr %args, ptr null, ptr null)
  call void @g_schedule(ptr %iterator, ptr %call, ptr %input, ptr %env, ptr %continuation, ptr %handler)
  ret void
}

define internal ptr @g_bind_alternatives(ptr %pattern, ptr %value, ptr %input, ptr %body) {
entry:
  %pp = getelementptr %GN, ptr %pattern, i32 0, i32 2
  %patterns = load ptr, ptr %pp
  %count = call i64 @b_len(ptr %patterns)
  %literal = call ptr @ev_node(i32 0, i32 0, ptr %value, ptr null, ptr null, ptr null)
  %original = call ptr @ev_node(i32 0, i32 0, ptr %input, ptr null, ptr null, ptr null)
  br label %loop
loop:
  %i = phi i64 [%count, %entry], [%previous, %next]
  %expression = phi ptr [null, %entry], [%combined, %next]
  %done = icmp eq i64 %i, 0
  br i1 %done, label %finish, label %one
one:
  %previous = sub i64 %i, 1
  %part = call ptr @j_at(ptr %patterns, i64 %previous)
  %binding = call ptr @ev_node(i32 11, i32 0, ptr %literal, ptr %part, ptr %body, ptr null)
  %last = icmp eq ptr %expression, null
  br i1 %last, label %lastbranch, label %alternative
lastbranch:
  br label %next
alternative:
  %resume = call ptr @ev_node(i32 2, i32 0, ptr %original, ptr %expression, ptr null, ptr null)
  %protected = call ptr @ev_node(i32 14, i32 0, ptr %binding, ptr %resume, ptr null, ptr null)
  br label %next
next:
  %combined = phi ptr [%binding, %lastbranch], [%protected, %alternative]
  br label %loop
finish:
  ret ptr %expression
}

define internal void @g_object(ptr %iterator, ptr %pairs, i64 %index, ptr %object, ptr %input, ptr %env, ptr %continuation, ptr %handler) {
entry:
  %count = call i64 @b_len(ptr %pairs)
  %done = icmp uge i64 %index, %count
  br i1 %done, label %emit, label %pair
emit:
  %work = call ptr @g_work(ptr %iterator, i32 1, i32 0, ptr null, ptr %object, ptr %env, ptr %continuation, ptr %handler, ptr null, ptr null, i64 0)
  ret void
pair:
  %key = call ptr @j_at(ptr %pairs, i64 %index)
  %vi = add i64 %index, 1
  %value = call ptr @j_at(ptr %pairs, i64 %vi)
  %cont = call ptr @g_cont(i32 12, i32 0, ptr %continuation, ptr %env, ptr %handler, ptr %pairs, ptr %object, ptr %input, ptr %value, i64 %index)
  call void @g_schedule(ptr %iterator, ptr %key, ptr %input, ptr %env, ptr %cont, ptr %handler)
  ret void
}

define internal void @g_callargs(ptr %iterator, ptr %body, ptr %params, ptr %args, i64 %index, ptr %input, ptr %calling, ptr %bound, ptr %continuation, ptr %handler) {
entry:
  %count = call i64 @b_len(ptr %params)
  br label %loop
loop:
  %i = phi i64 [ %index, %entry ], [ %next, %filter ]
  %env = phi ptr [ %bound, %entry ], [ %closure, %filter ]
  %done = icmp uge i64 %i, %count
  br i1 %done, label %evaluate, label %formal
evaluate:
  call void @g_schedule(ptr %iterator, ptr %body, ptr %input, ptr %env, ptr %continuation, ptr %handler)
  ret void
formal:
  %param = call ptr @j_at(ptr %params, i64 %i)
  %actual = call ptr @j_at(ptr %args, i64 %i)
  %kind = load i32, ptr %param
  %namep = getelementptr %GN, ptr %param, i32 0, i32 2
  %name = load ptr, ptr %namep
  %isvalue = icmp eq i32 %kind, 10
  %next = add i64 %i, 1
  br i1 %isvalue, label %value, label %filter
filter:
  %closure = call ptr @j_bind(ptr %env, ptr %name, ptr %actual)
  %typep = getelementptr %GE, ptr %closure, i32 0, i32 3
  store i32 2, ptr %typep
  %capturep = getelementptr %GE, ptr %closure, i32 0, i32 5
  store ptr %calling, ptr %capturep
  br label %loop
value:
  %state = call ptr @j_alloc(i64 64)
  store ptr %body, ptr %state
  %paramsp = getelementptr %GA, ptr %state, i32 0, i32 1
  store ptr %params, ptr %paramsp
  %argsp = getelementptr %GA, ptr %state, i32 0, i32 2
  store ptr %args, ptr %argsp
  %inputp = getelementptr %GA, ptr %state, i32 0, i32 3
  store ptr %input, ptr %inputp
  %callingp = getelementptr %GA, ptr %state, i32 0, i32 4
  store ptr %calling, ptr %callingp
  %boundp = getelementptr %GA, ptr %state, i32 0, i32 5
  store ptr %env, ptr %boundp
  %namefield = getelementptr %GA, ptr %state, i32 0, i32 6
  store ptr %name, ptr %namefield
  %indexp = getelementptr %GA, ptr %state, i32 0, i32 7
  store i64 %next, ptr %indexp
  %cont = call ptr @g_cont(i32 14, i32 0, ptr %continuation, ptr %calling, ptr %handler, ptr %state, ptr null, ptr null, ptr null, i64 0)
  call void @g_schedule(ptr %iterator, ptr %actual, ptr %input, ptr %calling, ptr %cont, ptr %handler)
  ret void
}

define ptr @j_iter(ptr %node, ptr %input, ptr %env) {
  %iterator = call ptr @j_alloc(i64 8)
  call void @g_schedule(ptr %iterator, ptr %node, ptr %input, ptr %env, ptr null, ptr null)
  ret ptr %iterator
}

define void @j_iter_into(ptr %iterator, ptr %node, ptr %input, ptr %env) {
  store ptr null, ptr %iterator
  call void @g_schedule(ptr %iterator, ptr %node, ptr %input, ptr %env, ptr null, ptr null)
  ret void
}

define ptr @j_next(ptr %iterator) {
entry:
  %previousdepth = load i64, ptr @g_next_depth
  %nextdepth = add i64 %previousdepth, 1
  store i64 %nextdepth, ptr @g_next_depth
  %toplevel = icmp eq i64 %previousdepth, 0
  %currentvalue = alloca ptr
  %currentcont = alloca ptr
  %currenthandler = alloca ptr
  store ptr null, ptr %currenthandler
  %priorerror = load ptr, ptr @j_error
  %priorbreak = load ptr, ptr @ev_break_name
  %errorpending = icmp ne ptr %priorerror, null
  %breakpending = icmp ne ptr %priorbreak, null
  %blocked = or i1 %errorpending, %breakpending
  br i1 %blocked, label %done, label %loop
loop:
  %enabled = load i1, ptr @j_collect_enabled
  %safe = and i1 %enabled, %toplevel
  %pressure = load i64, ptr @j_gc_pressure
  %needed = icmp uge i64 %pressure, 8388608
  %collect = and i1 %safe, %needed
  br i1 %collect, label %collection, label %jobs
collection:
  call void @j_collect(ptr %iterator)
  br label %jobs
jobs:
  %work = load ptr, ptr %iterator
  %empty = icmp eq ptr %work, null
  %halted = load i1, ptr @cli_halted
  %stop = or i1 %empty, %halted
  br i1 %stop, label %done, label %pop
pop:
  %nextwork = load ptr, ptr %work
  store ptr %nextwork, ptr %iterator
  %wkp = getelementptr %GW, ptr %work, i32 0, i32 1
  %wkind = load i32, ptr %wkp
  %wopp = getelementptr %GW, ptr %work, i32 0, i32 2
  %wop = load i32, ptr %wopp
  %wnp = getelementptr %GW, ptr %work, i32 0, i32 3
  %node = load ptr, ptr %wnp
  %wip = getelementptr %GW, ptr %work, i32 0, i32 4
  %input = load ptr, ptr %wip
  %wep = getelementptr %GW, ptr %work, i32 0, i32 5
  %env = load ptr, ptr %wep
  %wcp = getelementptr %GW, ptr %work, i32 0, i32 6
  %continuation = load ptr, ptr %wcp
  %whp = getelementptr %GW, ptr %work, i32 0, i32 7
  %handler = load ptr, ptr %whp
  %wap = getelementptr %GW, ptr %work, i32 0, i32 8
  %wa = load ptr, ptr %wap
  %wbp = getelementptr %GW, ptr %work, i32 0, i32 9
  %wb = load ptr, ptr %wbp
  %wxp = getelementptr %GW, ptr %work, i32 0, i32 10
  %index = load i64, ptr %wxp
  store ptr %handler, ptr %currenthandler
  store ptr %continuation, ptr %currentcont
  switch i32 %wkind, label %loop [ i32 0, label %ast i32 1, label %workvalue i32 2, label %workvalue i32 3, label %each i32 4, label %workerror i32 5, label %default i32 6, label %consume i32 7, label %readinput i32 8, label %fromevent i32 9, label %tree i32 10, label %reduceadvance ]
workvalue:
  store ptr %input, ptr %currentvalue
  br label %emit
each:
  %n = call i64 @b_len(ptr %input)
  %eachdone = icmp uge i64 %index, %n
  br i1 %eachdone, label %loop, label %eachvalue
eachvalue:
  %itag = load i32, ptr %input
  %objectvalue = icmp eq i32 %itag, 6
  %twice = mul i64 %index, 2
  %objectindex = add i64 %twice, 1
  %slotindex = select i1 %objectvalue, i64 %objectindex, i64 %index
  %idata = call ptr @b_data(ptr %input)
  %slot = getelementptr ptr, ptr %idata, i64 %slotindex
  %element = load ptr, ptr %slot
  %nextindex = add i64 %index, 1
  store i64 %nextindex, ptr %wxp
  %rest = load ptr, ptr %iterator
  store ptr %rest, ptr %work
  store ptr %work, ptr %iterator
  store ptr %element, ptr %currentvalue
  br label %emit
workerror:
  store ptr %input, ptr @j_error
  store ptr %wa, ptr @ev_break_name
  br label %raise
default:
  %seen = load i1, ptr %wa
  br i1 %seen, label %loop, label %usedefault
usedefault:
  call void @g_schedule(ptr %iterator, ptr %node, ptr %input, ptr %env, ptr %continuation, ptr %handler)
  br label %loop
consume:
  %childvalue = call ptr @j_next(ptr %wa)
  %childend = icmp eq ptr %childvalue, null
  %childerror = load ptr, ptr @j_error
  %childerrorpending = icmp ne ptr %childerror, null
  %childbreak = load ptr, ptr @ev_break_name
  %childbreakpending = icmp ne ptr %childbreak, null
  %childfailed = or i1 %childerrorpending, %childbreakpending
  br i1 %childfailed, label %raise, label %consumemode
consumemode:
  %anymode = icmp eq i32 %wop, 14
  %allmode = icmp eq i32 %wop, 15
  %anyall = or i1 %anymode, %allmode
  br i1 %anyall, label %consumetest, label %consumenormal
consumetest:
  br i1 %childend, label %consumetestend, label %consumetruth
consumetestend:
  %testdefault = call ptr @j_bool(i1 %allmode)
  store ptr %testdefault, ptr %currentvalue
  br label %emit
consumetruth:
  %testtruth = call i1 @j_truth(ptr %childvalue)
  %decisive = xor i1 %testtruth, %allmode
  br i1 %decisive, label %consumedecisive, label %consumetestmore
consumedecisive:
  %testanswer = call ptr @j_bool(i1 %testtruth)
  store ptr %testanswer, ptr %currentvalue
  br label %emit
consumetestmore:
  %testtail = load ptr, ptr %iterator
  store ptr %testtail, ptr %work
  store ptr %work, ptr %iterator
  br label %loop
consumenormal:
  %isempty = icmp eq i32 %wop, 12
  br i1 %isempty, label %consumeempty, label %consumevalue
consumeempty:
  %emptyvalue = call ptr @j_bool(i1 %childend)
  store ptr %emptyvalue, ptr %currentvalue
  br label %emit
consumevalue:
  br i1 %childend, label %consumeend, label %consumegot
consumeend:
  %islast = icmp eq i32 %wop, 8
  %haslast = icmp ne ptr %wb, null
  %emitlast = and i1 %islast, %haslast
  br i1 %emitlast, label %consumelast, label %loop
consumelast:
  store ptr %wb, ptr %currentvalue
  br label %emit
consumegot:
  switch i32 %wop, label %consumequota [ i32 7, label %consumefirst i32 8, label %consumekeep ]
consumefirst:
  store ptr %childvalue, ptr %currentvalue
  br label %emit
consumekeep:
  store ptr %childvalue, ptr %wbp
  %lastrest = load ptr, ptr %iterator
  store ptr %lastrest, ptr %work
  store ptr %work, ptr %iterator
  br label %loop
consumequota:
  %decrement = call ptr @j_num(double 1.000000e+00)
  %countvalue = call ptr @j_binary(i32 1, ptr %wb, ptr %decrement)
  %decrementerror = load ptr, ptr @j_error
  %decrementfailed = icmp ne ptr %decrementerror, null
  br i1 %decrementfailed, label %raise, label %consumecount
consumecount:
  %less = call double @b_number(ptr %countvalue)
  store ptr %countvalue, ptr %wbp
  %limitmode = icmp eq i32 %wop, 10
  %quotaended = fcmp ole double %less, 0.000000e+00
  %limitended = and i1 %limitmode, %quotaended
  %nthmode = icmp eq i32 %wop, 9
  %nthreshold = fcmp olt double %less, 0.000000e+00
  %nthended = and i1 %nthmode, %nthreshold
  %consumedone = or i1 %limitended, %nthended
  br i1 %consumedone, label %consumeemitcheck, label %consumemore
consumemore:
  %consumetail = load ptr, ptr %iterator
  store ptr %consumetail, ptr %work
  store ptr %work, ptr %iterator
  br label %consumeemitcheck
consumeemitcheck:
  %keepvalue = or i1 %limitmode, %nthreshold
  br i1 %keepvalue, label %consumefirst, label %loop
readinput:
  %inputvalue = call ptr @cli_take_input()
  %inputend = icmp eq ptr %inputvalue, null
  br i1 %inputend, label %readinputend, label %readinputgot
readinputend:
  %deferredinput = load ptr, ptr @j_deferred_input_error
  store ptr null, ptr @j_deferred_input_error
  store ptr %deferredinput, ptr @j_error
  br label %checkerror
readinputgot:
  %inputtail = load ptr, ptr %iterator
  store ptr %inputtail, ptr %work
  store ptr %work, ptr %iterator
  store ptr %inputvalue, ptr %currentvalue
  br label %emit
fromevent:
  %event = call ptr @j_next(ptr %wa)
  %eventbreak = load ptr, ptr @ev_break_name
  %eventbroken = icmp ne ptr %eventbreak, null
  br i1 %eventbroken, label %raise, label %eventcheck
eventcheck:
  %eventend = icmp eq ptr %event, null
  br i1 %eventend, label %checkerror, label %eventgot
eventgot:
  %eventlength = call i64 @b_len(ptr %event)
  %eventpath = call ptr @j_at(ptr %event, i64 0)
  %pathlength = call i64 @b_len(ptr %eventpath)
  %haseventvalue = icmp eq i64 %eventlength, 2
  br i1 %haseventvalue, label %eventset, label %eventclose
eventset:
  %eventvalue = call ptr @j_at(ptr %event, i64 1)
  %eventupdated = call ptr @b_setpath(ptr %wb, ptr %eventpath, i64 0, ptr %eventvalue)
  %eventroot = icmp eq i64 %pathlength, 0
  br label %eventready
eventclose:
  %eventclosed = icmp eq i64 %pathlength, 1
  br label %eventready
eventready:
  %eventcurrent = phi ptr [ %eventupdated, %eventset ], [ %wb, %eventclose ]
  %eventcomplete = phi i1 [ %eventroot, %eventset ], [ %eventclosed, %eventclose ]
  %eventnil = call ptr @j_null()
  %eventnextstate = select i1 %eventcomplete, ptr %eventnil, ptr %eventcurrent
  store ptr %eventnextstate, ptr %wbp
  %eventtail = load ptr, ptr %iterator
  store ptr %eventtail, ptr %work
  store ptr %work, ptr %iterator
  store ptr %eventcurrent, ptr %currentvalue
  br i1 %eventcomplete, label %emitcheck, label %checkerror
tree:
  %treeinitial = icmp eq i64 %index, -1
  %treeisstream = icmp eq i32 %wop, 0
  br i1 %treeinitial, label %treeenter, label %treechildren
treeenter:
  %treetag = load i32, ptr %input
  %treearray = icmp eq i32 %treetag, 5
  %treeobject = icmp eq i32 %treetag, 6
  %treecontainer = or i1 %treearray, %treeobject
  %treelen = call i64 @b_len(ptr %input)
  %treenonempty = icmp ne i64 %treelen, 0
  %treehaschildren = and i1 %treecontainer, %treenonempty
  br i1 %treehaschildren, label %treeexpand, label %treevisit
treeexpand:
  %treekeys = call ptr @b_keys(ptr %input, i1 false)
  store ptr %treekeys, ptr %wbp
  store i64 0, ptr %wxp
  %treetail = load ptr, ptr %iterator
  store ptr %treetail, ptr %work
  store ptr %work, ptr %iterator
  br label %treevisit
treevisit:
  br i1 %treeisstream, label %treeevent, label %treepath
treeevent:
  br i1 %treehaschildren, label %loop, label %treeleaf
treeleaf:
  %leafevent = call ptr @j_array()
  call void @j_push(ptr %leafevent, ptr %wa)
  call void @j_push(ptr %leafevent, ptr %input)
  store ptr %leafevent, ptr %currentvalue
  br label %emit
treepath:
  %treepathlen = call i64 @b_len(ptr %wa)
  %treeroot = icmp eq i64 %treepathlen, 0
  %onlyleaves = icmp eq i32 %wop, 2
  %notscalar = and i1 %onlyleaves, %treecontainer
  %pathskip = or i1 %treeroot, %notscalar
  br i1 %pathskip, label %loop, label %treepathselect
treepathselect:
  %treefilter = icmp ne ptr %node, null
  br i1 %treefilter, label %treecondition, label %treepathyield
treecondition:
  %treeconditionk = call ptr @g_cont(i32 15, i32 0, ptr %continuation, ptr %env, ptr %handler, ptr %wa, ptr null, ptr null, ptr null, i64 0)
  call void @g_schedule(ptr %iterator, ptr %node, ptr %input, ptr %env, ptr %treeconditionk, ptr %handler)
  br label %loop
treepathyield:
  store ptr %wa, ptr %currentvalue
  br label %emit
treechildren:
  %treekeyn = call i64 @b_len(ptr %wb)
  %treeclosed = icmp uge i64 %index, %treekeyn
  br i1 %treeclosed, label %treeclose, label %treechild
treechild:
  %treekey = call ptr @j_at(ptr %wb, i64 %index)
  %treechildvalue = call ptr @j_get(ptr %input, ptr %treekey)
  %treechildpath = call ptr @j_clone(ptr %wa)
  call void @j_push(ptr %treechildpath, ptr %treekey)
  %treenext = add i64 %index, 1
  store i64 %treenext, ptr %wxp
  %treeparenttail = load ptr, ptr %iterator
  store ptr %treeparenttail, ptr %work
  store ptr %work, ptr %iterator
  %treechildwork = call ptr @g_work(ptr %iterator, i32 9, i32 %wop, ptr %node, ptr %treechildvalue, ptr %env, ptr %continuation, ptr %handler, ptr %treechildpath, ptr null, i64 -1)
  br label %checkerror
treeclose:
  br i1 %treeisstream, label %treecloseevent, label %loop
treecloseevent:
  %treelastkey = call ptr @j_at(ptr %wb, i64 -1)
  %treelastpath = call ptr @j_clone(ptr %wa)
  call void @j_push(ptr %treelastpath, ptr %treelastkey)
  %treeclosing = call ptr @j_array()
  call void @j_push(ptr %treeclosing, ptr %treelastpath)
  store ptr %treeclosing, ptr %currentvalue
  br label %emit
reduceadvance:
  %reduceditem = call ptr @j_next(ptr %wa)
  %reducedend = icmp eq ptr %reduceditem, null
  %reduceerror = load ptr, ptr @j_error
  %reduceerrorpending = icmp ne ptr %reduceerror, null
  %reducebreak = load ptr, ptr @ev_break_name
  %reducebroken = icmp ne ptr %reducebreak, null
  %reducefailed = or i1 %reduceerrorpending, %reducebroken
  br i1 %reducefailed, label %raise, label %reduceendcheck
reduceendcheck:
  br i1 %reducedend, label %reducedone, label %reduceitem
reducedone:
  %foreachdone = icmp eq i32 %wop, 280
  br i1 %foreachdone, label %loop, label %reducestates
reducestates:
  call void @g_values(ptr %iterator, ptr %wb, ptr %continuation, ptr %handler)
  br label %loop
reduceitem:
  %reducepatternp = getelementptr %GN, ptr %node, i32 0, i32 3
  %reducepattern = load ptr, ptr %reducepatternp
  %reduceupdatep = getelementptr %GN, ptr %node, i32 0, i32 5
  %reduceupdate = load ptr, ptr %reduceupdatep
  %reduceextractp = getelementptr %GN, ptr %node, i32 0, i32 6
  %reduceextract = load ptr, ptr %reduceextractp
  %reducedenv = call ptr @ev_bindpattern(ptr %env, ptr %reducepattern, ptr %reduceditem, ptr %input)
  %reducenew = call ptr @j_array()
  store ptr %reducenew, ptr %wbp
  %reducetail = load ptr, ptr %iterator
  store ptr %reducetail, ptr %work
  store ptr %work, ptr %iterator
  %reducek = call ptr @g_cont(i32 26, i32 %wop, ptr %continuation, ptr %reducedenv, ptr %handler, ptr %reduceupdate, ptr %reducenew, ptr %reduceextract, ptr null, i64 0)
  call void @g_values(ptr %iterator, ptr %wb, ptr %reducek, ptr %handler)
  br label %checkerror
ast:
  %none = icmp eq ptr %node, null
  br i1 %none, label %loop, label %dispatch
dispatch:
  %kind = load i32, ptr %node
  %opp = getelementptr %GN, ptr %node, i32 0, i32 1
  %op = load i32, ptr %opp
  %ap = getelementptr %GN, ptr %node, i32 0, i32 2
  %a = load ptr, ptr %ap
  %bp = getelementptr %GN, ptr %node, i32 0, i32 3
  %b = load ptr, ptr %bp
  %cp = getelementptr %GN, ptr %node, i32 0, i32 4
  %c = load ptr, ptr %cp
  %dp = getelementptr %GN, ptr %node, i32 0, i32 5
  %d = load ptr, ptr %dp
  switch i32 %kind, label %atom [ i32 0, label %literal i32 1, label %identity i32 2, label %pipe i32 3, label %comma i32 4, label %binary i32 5, label %field i32 6, label %iterate i32 7, label %call i32 8, label %array i32 9, label %object i32 11, label %binding i32 12, label %definition i32 13, label %conditional i32 14, label %try i32 15, label %negative i32 16, label %optional i32 17, label %recursivedefault i32 18, label %reduce i32 19, label %assignment i32 20, label %slice i32 21, label %alternative i32 22, label %label i32 23, label %break i32 24, label %import i32 25, label %module i32 100, label %repeatstep i32 101, label %recursestep i32 102, label %whilestep i32 103, label %rangestep ]
literal:
  store ptr %a, ptr %currentvalue
  br label %emit
identity:
  store ptr %input, ptr %currentvalue
  br label %emit
pipe:
  %pk = call ptr @g_cont(i32 1, i32 0, ptr %continuation, ptr %env, ptr %handler, ptr %b, ptr null, ptr null, ptr null, i64 0)
  call void @g_schedule(ptr %iterator, ptr %a, ptr %input, ptr %env, ptr %pk, ptr %handler)
  br label %loop
comma:
  call void @g_schedule(ptr %iterator, ptr %b, ptr %input, ptr %env, ptr %continuation, ptr %handler)
  call void @g_schedule(ptr %iterator, ptr %a, ptr %input, ptr %env, ptr %continuation, ptr %handler)
  br label %loop
binary:
  %logical = icmp uge i32 %op, 11
  %outer = select i1 %logical, ptr %a, ptr %b
  %inner = select i1 %logical, ptr %b, ptr %a
  %bk = call ptr @g_cont(i32 2, i32 %op, ptr %continuation, ptr %env, ptr %handler, ptr %inner, ptr %input, ptr null, ptr null, i64 0)
  call void @g_schedule(ptr %iterator, ptr %outer, ptr %input, ptr %env, ptr %bk, ptr %handler)
  br label %loop
field:
  %fk = call ptr @g_cont(i32 4, i32 0, ptr %continuation, ptr %env, ptr %handler, ptr %b, ptr %input, ptr null, ptr null, i64 0)
  call void @g_schedule(ptr %iterator, ptr %a, ptr %input, ptr %env, ptr %fk, ptr %handler)
  br label %loop
iterate:
  %ik = call ptr @g_cont(i32 6, i32 0, ptr %continuation, ptr %env, ptr %handler, ptr null, ptr null, ptr null, ptr null, i64 0)
  call void @g_schedule(ptr %iterator, ptr %a, ptr %input, ptr %env, ptr %ik, ptr %handler)
  br label %loop
array:
  %accumulator = call ptr @j_array()
  %finisharray = call ptr @g_work(ptr %iterator, i32 2, i32 0, ptr null, ptr %accumulator, ptr %env, ptr %continuation, ptr %handler, ptr null, ptr null, i64 0)
  %ak = call ptr @g_cont(i32 7, i32 0, ptr %continuation, ptr %env, ptr %handler, ptr %accumulator, ptr null, ptr null, ptr null, i64 0)
  call void @g_schedule(ptr %iterator, ptr %a, ptr %input, ptr %env, ptr %ak, ptr %handler)
  br label %loop
object:
  %newobject = call ptr @j_object()
  call void @g_object(ptr %iterator, ptr %a, i64 0, ptr %newobject, ptr %input, ptr %env, ptr %continuation, ptr %handler)
  br label %loop
binding:
  %bindk = call ptr @g_cont(i32 8, i32 0, ptr %continuation, ptr %env, ptr %handler, ptr %b, ptr %c, ptr %input, ptr null, i64 0)
  call void @g_schedule(ptr %iterator, ptr %a, ptr %input, ptr %env, ptr %bindk, ptr %handler)
  br label %loop
definition:
  %de = call ptr @j_bind(ptr %env, ptr %a, ptr %c)
  %det = getelementptr %GE, ptr %de, i32 0, i32 3
  store i32 1, ptr %det
  %dep = getelementptr %GE, ptr %de, i32 0, i32 4
  store ptr %b, ptr %dep
  %dec = getelementptr %GE, ptr %de, i32 0, i32 5
  store ptr %de, ptr %dec
  call void @g_schedule(ptr %iterator, ptr %d, ptr %input, ptr %de, ptr %continuation, ptr %handler)
  br label %loop
conditional:
  %ck = call ptr @g_cont(i32 9, i32 0, ptr %continuation, ptr %env, ptr %handler, ptr %b, ptr %c, ptr %input, ptr null, i64 0)
  call void @g_schedule(ptr %iterator, ptr %a, ptr %input, ptr %env, ptr %ck, ptr %handler)
  br label %loop
try:
  %th = call ptr @g_handler(ptr %iterator, ptr %handler, ptr %b, ptr %env, ptr %continuation, ptr null)
  call void @g_schedule(ptr %iterator, ptr %a, ptr %input, ptr %env, ptr %continuation, ptr %th)
  br label %loop
optional:
  %oh = call ptr @g_handler(ptr %iterator, ptr %handler, ptr null, ptr %env, ptr %continuation, ptr null)
  call void @g_schedule(ptr %iterator, ptr %a, ptr %input, ptr %env, ptr %continuation, ptr %oh)
  br label %loop
negative:
  %nk = call ptr @g_cont(i32 10, i32 0, ptr %continuation, ptr %env, ptr %handler, ptr null, ptr null, ptr null, ptr null, i64 0)
  call void @g_schedule(ptr %iterator, ptr %a, ptr %input, ptr %env, ptr %nk, ptr %handler)
  br label %loop
alternative:
  %tracker = call ptr @j_alloc(i64 8)
  %defaultjob = call ptr @g_work(ptr %iterator, i32 5, i32 0, ptr %b, ptr %input, ptr %env, ptr %continuation, ptr %handler, ptr %tracker, ptr null, i64 0)
  %altk = call ptr @g_cont(i32 11, i32 0, ptr %continuation, ptr %env, ptr %handler, ptr %tracker, ptr null, ptr null, ptr null, i64 0)
  call void @g_schedule(ptr %iterator, ptr %a, ptr %input, ptr %env, ptr %altk, ptr %handler)
  br label %loop
label:
  %lh = call ptr @g_handler(ptr %iterator, ptr %handler, ptr null, ptr %env, ptr %continuation, ptr %a)
  call void @g_schedule(ptr %iterator, ptr %b, ptr %input, ptr %env, ptr %continuation, ptr %lh)
  br label %loop
break:
  store ptr %a, ptr @ev_break_name
  br label %raise
import:
  %directory = load ptr, ptr @ev_module_directory
  %importenv = call ptr @ev_importenv(ptr %node, ptr %env, ptr %directory)
  call void @g_schedule(ptr %iterator, ptr %c, ptr %input, ptr %importenv, ptr %continuation, ptr %handler)
  br label %checkerror
module:
  call void @g_schedule(ptr %iterator, ptr %b, ptr %input, ptr %env, ptr %continuation, ptr %handler)
  br label %loop
reduce:
  %redinitialk = call ptr @g_cont(i32 27, i32 %op, ptr %continuation, ptr %env, ptr %handler, ptr %node, ptr %input, ptr null, ptr null, i64 0)
  call void @g_schedule(ptr %iterator, ptr %c, ptr %input, ptr %env, ptr %redinitialk, ptr %handler)
  br label %loop
slice:
  %slicek = call ptr @g_cont(i32 28, i32 0, ptr %continuation, ptr %env, ptr %handler, ptr %b, ptr %c, ptr %input, ptr null, i64 0)
  call void @g_schedule(ptr %iterator, ptr %a, ptr %input, ptr %env, ptr %slicek, ptr %handler)
  br label %loop
assignment:
  %plainassign = icmp eq i32 %op, 61
  %compoundlow = icmp uge i32 %op, 266
  %compoundhigh = icmp ule i32 %op, 270
  %compound = and i1 %compoundlow, %compoundhigh
  %valueassign = or i1 %plainassign, %compound
  br i1 %valueassign, label %assignmentvalue, label %atom
assignmentvalue:
  %assignk = call ptr @g_cont(i32 32, i32 %op, ptr %continuation, ptr %env, ptr %handler, ptr %a, ptr %input, ptr null, ptr null, i64 0)
  call void @g_schedule(ptr %iterator, ptr %b, ptr %input, ptr %env, ptr %assignk, ptr %handler)
  br label %loop
call:
  %arity = call i64 @b_len(ptr %b)
  %privatebuiltin = icmp sle i32 %op, -2
  br i1 %privatebuiltin, label %generatorlookup, label %userlookup
userlookup:
  %function = call ptr @ev_lookup(ptr %env, ptr %a, i32 1, i64 %arity)
  %foundfunction = icmp ne ptr %function, null
  br i1 %foundfunction, label %usercall, label %filterlookup
usercall:
  %bodyp = getelementptr %GE, ptr %function, i32 0, i32 2
  %body = load ptr, ptr %bodyp
  %paramsp = getelementptr %GE, ptr %function, i32 0, i32 4
  %params = load ptr, ptr %paramsp
  %capturep = getelementptr %GE, ptr %function, i32 0, i32 5
  %capture = load ptr, ptr %capturep
  call void @g_callargs(ptr %iterator, ptr %body, ptr %params, ptr %b, i64 0, ptr %input, ptr %env, ptr %capture, ptr %continuation, ptr %handler)
  br label %loop
filterlookup:
  %filter = call ptr @ev_lookup(ptr %env, ptr %a, i32 2, i64 0)
  %foundfilter = icmp ne ptr %filter, null
  br i1 %foundfilter, label %filtercall, label %generatorlookup
filtercall:
  %filterbodyp = getelementptr %GE, ptr %filter, i32 0, i32 2
  %filterbody = load ptr, ptr %filterbodyp
  %filterenvp = getelementptr %GE, ptr %filter, i32 0, i32 5
  %filterenv = load ptr, ptr %filterenvp
  call void @g_schedule(ptr %iterator, ptr %filterbody, ptr %input, ptr %filterenv, ptr %continuation, ptr %handler)
  br label %loop
generatorlookup:
  %gid = call i32 @b_find(ptr %a, ptr @g_generators)
  switch i32 %gid, label %nativecall [ i32 0, label %selectcall i32 1, label %rangecall i32 2, label %recursecall i32 3, label %recursecall i32 4, label %whilecall i32 5, label %whilecall i32 6, label %repeatcall i32 7, label %consumecall i32 8, label %consumecall i32 9, label %quotacall i32 10, label %quotacall i32 11, label %quotacall i32 12, label %consumecall i32 13, label %inputscall i32 14, label %anyallcall i32 15, label %anyallcall i32 16, label %fromstreamcall i32 17, label %truncatecall ]
nativecall:
  %expansion = call ptr @j_expand_builtin(ptr %a, ptr %b, ptr %input, ptr %env)
  %expanded = icmp ne ptr %expansion, null
  br i1 %expanded, label %expandedcall, label %treecheck
expandedcall:
  call void @g_schedule(ptr %iterator, ptr %expansion, ptr %input, ptr %env, ptr %continuation, ptr %handler)
  br label %checkerror
treecheck:
  %treeid = call i32 @b_find(ptr %a, ptr @g_tree_names)
  %treebuiltin = icmp sge i32 %treeid, 0
  br i1 %treebuiltin, label %treecall, label %joincheck
treecall:
  %treehasfilter = icmp ne i64 %arity, 0
  br i1 %treehasfilter, label %treefiltercall, label %treenofilter
treefiltercall:
  %treefilterast = call ptr @j_at(ptr %b, i64 0)
  br label %treecallready
treenofilter:
  br label %treecallready
treecallready:
  %treepredicate = phi ptr [%treefilterast, %treefiltercall], [null, %treenofilter]
  %treepathroot = call ptr @j_array()
  %treework = call ptr @g_work(ptr %iterator, i32 9, i32 %treeid, ptr %treepredicate, ptr %input, ptr %env, ptr %continuation, ptr %handler, ptr %treepathroot, ptr null, i64 -1)
  br label %loop
joincheck:
  %isjoin = call i1 @j_is(ptr %a, ptr @g_join)
  br i1 %isjoin, label %joincall, label %membershipcheck
joincall:
  %joinindexast = call ptr @j_at(ptr %b, i64 0)
  %joink = call ptr @g_cont(i32 33, i32 0, ptr %continuation, ptr %env, ptr %handler, ptr %b, ptr %input, ptr null, ptr null, i64 0)
  call void @g_schedule(ptr %iterator, ptr %joinindexast, ptr %input, ptr %env, ptr %joink, ptr %handler)
  br label %loop
membershipcheck:
  %ismembership = call i1 @j_is(ptr %a, ptr @g_in)
  br i1 %ismembership, label %membership, label %nativecheck
membership:
  %membershipleft = call ptr @j_at(ptr %b, i64 0)
  %membershiptwo = icmp eq i64 %arity, 2
  br i1 %membershiptwo, label %membershiprhs, label %membershipdot
membershiprhs:
  %membershipsource = call ptr @j_at(ptr %b, i64 1)
  br label %membershipready
membershipdot:
  %membershipidentity = call ptr @ev_node(i32 1, i32 0, ptr null, ptr null, ptr null, ptr null)
  br label %membershipready
membershipready:
  %membershipright = phi ptr [%membershipsource, %membershiprhs], [%membershipidentity, %membershipdot]
  %membershipcompare = call ptr @ev_node(i32 4, i32 5, ptr %membershipleft, ptr %membershipright, ptr null, ptr null)
  %membershipiterator = call ptr @j_iter(ptr %membershipcompare, ptr %input, ptr %env)
  %membershipwork = call ptr @g_work(ptr %iterator, i32 6, i32 14, ptr null, ptr %input, ptr %env, ptr %continuation, ptr %handler, ptr %membershipiterator, ptr null, i64 0)
  br label %loop
nativecheck:
  %nativeboundpublic = icmp eq i32 %op, -1
  %nativeboundprivate = icmp eq i32 %op, -3
  %nativebound = or i1 %nativeboundpublic, %nativeboundprivate
  %noargs = icmp eq i64 %arity, 0
  %valueargmask = call i64 @g_value_mask(ptr %a)
  %nofilterargs = icmp eq i64 %valueargmask, 0
  %nativebasic = or i1 %nativebound, %noargs
  %nativeplain = or i1 %nativebasic, %nofilterargs
  br i1 %nativeplain, label %atom, label %nativeargs
nativeargs:
  %reverseargid = call i32 @b_find(ptr %a, ptr @g_reverse_args)
  %reverseargorder = icmp sge i32 %reverseargid, 0
  %lastarg = sub i64 %arity, 1
  %firstarg = select i1 %reverseargorder, i64 %lastarg, i64 0
  call void @g_native_args(ptr %iterator, ptr %node, ptr %b, i64 %firstarg, ptr %input, ptr %env, ptr %continuation, ptr %handler)
  br label %loop
inputscall:
  %inputswork = call ptr @g_work(ptr %iterator, i32 7, i32 0, ptr null, ptr null, ptr %env, ptr %continuation, ptr %handler, ptr null, ptr null, i64 0)
  br label %loop
anyallcall:
  %anytwo = icmp eq i64 %arity, 2
  %anyidentity = call ptr @ev_node(i32 1, i32 0, ptr null, ptr null, ptr null, ptr null)
  %anyiterate = call ptr @ev_node(i32 6, i32 0, ptr %anyidentity, ptr null, ptr null, ptr null)
  br i1 %anytwo, label %anygenerator, label %anyvalues
anygenerator:
  %anygeneratorast = call ptr @j_at(ptr %b, i64 0)
  %anyconditionast = call ptr @j_at(ptr %b, i64 1)
  br label %anyready
anyvalues:
  %anyhascond = icmp ne i64 %arity, 0
  br i1 %anyhascond, label %anycondition, label %anyplain
anycondition:
  %anyonecondition = call ptr @j_at(ptr %b, i64 0)
  br label %anyready
anyplain:
  br label %anyready
anyready:
  %anygen = phi ptr [ %anygeneratorast, %anygenerator ], [ %anyiterate, %anycondition ], [ %anyiterate, %anyplain ]
  %anycond = phi ptr [ %anyconditionast, %anygenerator ], [ %anyonecondition, %anycondition ], [ %anyidentity, %anyplain ]
  %anypipe = call ptr @ev_node(i32 2, i32 0, ptr %anygen, ptr %anycond, ptr null, ptr null)
  %anyiter = call ptr @j_iter(ptr %anypipe, ptr %input, ptr %env)
  %anywork = call ptr @g_work(ptr %iterator, i32 6, i32 %gid, ptr null, ptr %input, ptr %env, ptr %continuation, ptr %handler, ptr %anyiter, ptr null, i64 0)
  br label %loop
fromstreamcall:
  %fromast = call ptr @j_at(ptr %b, i64 0)
  %fromiter = call ptr @j_iter(ptr %fromast, ptr %input, ptr %env)
  %fromnil = call ptr @j_null()
  %fromwork = call ptr @g_work(ptr %iterator, i32 8, i32 0, ptr null, ptr %input, ptr %env, ptr %continuation, ptr %handler, ptr %fromiter, ptr %fromnil, i64 0)
  br label %loop
truncatecall:
  %truncateast = call ptr @j_at(ptr %b, i64 0)
  %truncatenil = call ptr @j_null()
  %truncatek = call ptr @g_cont(i32 24, i32 0, ptr %continuation, ptr %env, ptr %handler, ptr %input, ptr null, ptr null, ptr null, i64 0)
  call void @g_schedule(ptr %iterator, ptr %truncateast, ptr %truncatenil, ptr %env, ptr %truncatek, ptr %handler)
  br label %loop
selectcall:
  %selectast = call ptr @j_at(ptr %b, i64 0)
  %selectk = call ptr @g_cont(i32 15, i32 0, ptr %continuation, ptr %env, ptr %handler, ptr %input, ptr null, ptr null, ptr null, i64 0)
  call void @g_schedule(ptr %iterator, ptr %selectast, ptr %input, ptr %env, ptr %selectk, ptr %handler)
  br label %loop
rangecall:
  %singlebound = icmp eq i64 %arity, 1
  %rangefirst = call ptr @j_at(ptr %b, i64 0)
  br i1 %singlebound, label %rangezero, label %rangestart
rangezero:
  %zero = call ptr @j_num(double 0.000000e+00)
  %rangeendk = call ptr @g_cont(i32 17, i32 0, ptr %continuation, ptr %env, ptr %handler, ptr %b, ptr %input, ptr %zero, ptr null, i64 0)
  call void @g_schedule(ptr %iterator, ptr %rangefirst, ptr %input, ptr %env, ptr %rangeendk, ptr %handler)
  br label %loop
rangestart:
  %rangestartk = call ptr @g_cont(i32 16, i32 0, ptr %continuation, ptr %env, ptr %handler, ptr %b, ptr %input, ptr null, ptr null, i64 0)
  call void @g_schedule(ptr %iterator, ptr %rangefirst, ptr %input, ptr %env, ptr %rangestartk, ptr %handler)
  br label %loop
recursecall:
  %hasstep = icmp ugt i64 %arity, 0
  br i1 %hasstep, label %recurseargs, label %recursivedefault
recurseargs:
  %recursestepast = call ptr @j_at(ptr %b, i64 0)
  %haspredicate = icmp ugt i64 %arity, 1
  br i1 %haspredicate, label %recursepredicate, label %recursenopredicate
recursepredicate:
  %recursecondition = call ptr @j_at(ptr %b, i64 1)
  br label %recurseready
recursenopredicate:
  br label %recurseready
recurseready:
  %recursecond = phi ptr [ %recursecondition, %recursepredicate ], [ null, %recursenopredicate ]
  %recursenode = call ptr @ev_node(i32 101, i32 0, ptr %recursestepast, ptr %recursecond, ptr null, ptr null)
  call void @g_schedule(ptr %iterator, ptr %recursenode, ptr %input, ptr %env, ptr %continuation, ptr %handler)
  br label %loop
recursivedefault:
  %rid = call ptr @ev_node(i32 1, i32 0, ptr null, ptr null, ptr null, ptr null)
  %riter = call ptr @ev_node(i32 6, i32 0, ptr %rid, ptr null, ptr null, ptr null)
  %ropt = call ptr @ev_node(i32 16, i32 0, ptr %riter, ptr null, ptr null, ptr null)
  %rdefault = call ptr @ev_node(i32 101, i32 0, ptr %ropt, ptr null, ptr null, ptr null)
  call void @g_schedule(ptr %iterator, ptr %rdefault, ptr %input, ptr %env, ptr %continuation, ptr %handler)
  br label %loop
whilecall:
  %condast = call ptr @j_at(ptr %b, i64 0)
  %updateast = call ptr @j_at(ptr %b, i64 1)
  %until = icmp eq i32 %gid, 5
  %untilop = zext i1 %until to i32
  %whilenode = call ptr @ev_node(i32 102, i32 %untilop, ptr %condast, ptr %updateast, ptr null, ptr null)
  call void @g_schedule(ptr %iterator, ptr %whilenode, ptr %input, ptr %env, ptr %continuation, ptr %handler)
  br label %loop
repeatcall:
  %repeatast = call ptr @j_at(ptr %b, i64 0)
  %repeatnode = call ptr @ev_node(i32 100, i32 0, ptr %repeatast, ptr null, ptr null, ptr null)
  call void @g_schedule(ptr %iterator, ptr %repeatnode, ptr %input, ptr %env, ptr %continuation, ptr %handler)
  br label %loop
repeatstep:
  call void @g_schedule(ptr %iterator, ptr %node, ptr %input, ptr %env, ptr %continuation, ptr %handler)
  call void @g_schedule(ptr %iterator, ptr %a, ptr %input, ptr %env, ptr %continuation, ptr %handler)
  br label %loop
recursestep:
  %rnext = call ptr @g_cont(i32 19, i32 0, ptr %continuation, ptr %env, ptr %handler, ptr %node, ptr %b, ptr null, ptr null, i64 0)
  call void @g_schedule(ptr %iterator, ptr %a, ptr %input, ptr %env, ptr %rnext, ptr %handler)
  store ptr %input, ptr %currentvalue
  br label %emit
whilestep:
  %whilek = call ptr @g_cont(i32 21, i32 %op, ptr %continuation, ptr %env, ptr %handler, ptr %node, ptr %b, ptr %input, ptr null, i64 0)
  call void @g_schedule(ptr %iterator, ptr %a, ptr %input, ptr %env, ptr %whilek, ptr %handler)
  br label %loop
rangestep:
  %rangetag = load i32, ptr %a
  %boundtag = load i32, ptr %b
  %rangenum = icmp eq i32 %rangetag, 3
  %boundnum = icmp eq i32 %boundtag, 3
  %numericrange = and i1 %rangenum, %boundnum
  br i1 %numericrange, label %rangecompare, label %rangeerror
rangeerror:
  call void @j_fail(ptr @g_range_error)
  br label %raise
rangecompare:
  %rangevalue = call double @b_number(ptr %a)
  %rangebound = call double @b_number(ptr %b)
  %rangestepvalue = call double @b_number(ptr %c)
  %ascending = fcmp ogt double %rangestepvalue, 0.000000e+00
  %descending = fcmp olt double %rangestepvalue, 0.000000e+00
  %below = fcmp ult double %rangevalue, %rangebound
  %above = fcmp ogt double %rangevalue, %rangebound
  %up = and i1 %ascending, %below
  %down = and i1 %descending, %above
  %inrange = or i1 %up, %down
  br i1 %inrange, label %rangeemit, label %loop
rangeemit:
  %rangeincrement = fadd double %rangevalue, %rangestepvalue
  %rangeupdated = call ptr @j_num(double %rangeincrement)
  store ptr %rangeupdated, ptr %ap
  call void @g_schedule(ptr %iterator, ptr %node, ptr %input, ptr %env, ptr %continuation, ptr %handler)
  store ptr %a, ptr %currentvalue
  br label %emit
consumecall:
  %hasgenerator = icmp ugt i64 %arity, 0
  br i1 %hasgenerator, label %consumerstart, label %atom
consumerstart:
  %generatorast = call ptr @j_at(ptr %b, i64 0)
  %generatoriter = call ptr @j_iter(ptr %generatorast, ptr %input, ptr %env)
  %consumerwork = call ptr @g_work(ptr %iterator, i32 6, i32 %gid, ptr null, ptr %input, ptr %env, ptr %continuation, ptr %handler, ptr %generatoriter, ptr null, i64 0)
  br label %loop
quotacall:
  %twoparams = icmp eq i64 %arity, 2
  br i1 %twoparams, label %quotastart, label %atom
quotastart:
  %countast = call ptr @j_at(ptr %b, i64 0)
  %quotagenerator = call ptr @j_at(ptr %b, i64 1)
  %quotak = call ptr @g_cont(i32 23, i32 %gid, ptr %continuation, ptr %env, ptr %handler, ptr %quotagenerator, ptr %input, ptr null, ptr null, i64 0)
  call void @g_schedule(ptr %iterator, ptr %countast, ptr %input, ptr %env, ptr %quotak, ptr %handler)
  br label %loop
atom:
  %values = call ptr @j_eval_atom(ptr %node, ptr %input, ptr %env)
  %pendingerror = load ptr, ptr @j_error
  %pendingbreak = load ptr, ptr @ev_break_name
  %haserror = icmp ne ptr %pendingerror, null
  %hasbreak = icmp ne ptr %pendingbreak, null
  %haspending = or i1 %haserror, %hasbreak
  br i1 %haspending, label %defererror, label %atomvalues
defererror:
  store ptr null, ptr @j_error
  store ptr null, ptr @ev_break_name
  %errorjob = call ptr @g_work(ptr %iterator, i32 4, i32 0, ptr null, ptr %pendingerror, ptr %env, ptr %continuation, ptr %handler, ptr %pendingbreak, ptr null, i64 0)
  br label %atomvalues
atomvalues:
  call void @g_values(ptr %iterator, ptr %values, ptr %continuation, ptr %handler)
  br label %loop
emit:
  %value = load ptr, ptr %currentvalue
  %cont = load ptr, ptr %currentcont
  %root = icmp eq ptr %cont, null
  br i1 %root, label %yield, label %continue
continue:
  %kk = load i32, ptr %cont
  %kop.p = getelementptr %GK, ptr %cont, i32 0, i32 1
  %kop = load i32, ptr %kop.p
  %kpp = getelementptr %GK, ptr %cont, i32 0, i32 2
  %parent = load ptr, ptr %kpp
  %kep = getelementptr %GK, ptr %cont, i32 0, i32 3
  %kenv = load ptr, ptr %kep
  %khp = getelementptr %GK, ptr %cont, i32 0, i32 4
  %kh = load ptr, ptr %khp
  %kap = getelementptr %GK, ptr %cont, i32 0, i32 5
  %ka = load ptr, ptr %kap
  %kbp = getelementptr %GK, ptr %cont, i32 0, i32 6
  %kb = load ptr, ptr %kbp
  %kcp = getelementptr %GK, ptr %cont, i32 0, i32 7
  %kc = load ptr, ptr %kcp
  %kdp = getelementptr %GK, ptr %cont, i32 0, i32 8
  %kd = load ptr, ptr %kdp
  %kxp = getelementptr %GK, ptr %cont, i32 0, i32 9
  %kx = load i64, ptr %kxp
  store ptr %kh, ptr %currenthandler
  store ptr %parent, ptr %currentcont
  switch i32 %kk, label %loop [ i32 1, label %kpipe i32 2, label %kbinaryouter i32 3, label %kbinary i32 4, label %kfieldouter i32 5, label %kfield i32 6, label %kiterate i32 7, label %kcollect i32 8, label %kbind i32 9, label %kcondition i32 10, label %knegative i32 11, label %kalternative i32 12, label %kobjectkey i32 13, label %kobjectvalue i32 14, label %kcallarg i32 15, label %kselect i32 16, label %krangestart i32 17, label %krangeend i32 18, label %krangestep i32 19, label %krecurse i32 20, label %krecursecondition i32 21, label %kwhile i32 22, label %kloop i32 23, label %kquota i32 24, label %ktruncate i32 25, label %kreducecollect i32 26, label %kreducestate i32 27, label %kreduceinitial i32 28, label %kslicebase i32 29, label %kslicestart i32 30, label %ksliceend i32 31, label %knativearg i32 32, label %kassignment i32 33, label %kjoin ]
kpipe:
  call void @g_schedule(ptr %iterator, ptr %ka, ptr %value, ptr %kenv, ptr %parent, ptr %kh)
  br label %loop
kbinaryouter:
  %islogic = icmp uge i32 %kop, 11
  br i1 %islogic, label %logic, label %binaryinner
logic:
  %truth = call i1 @j_truth(ptr %value)
  %isand = icmp eq i32 %kop, 11
  %short = xor i1 %truth, %isand
  br i1 %short, label %shortcircuit, label %binaryinner
shortcircuit:
  %boolean = call ptr @j_bool(i1 %truth)
  store ptr %boolean, ptr %currentvalue
  br label %emit
binaryinner:
  %applybinary = call ptr @g_cont(i32 3, i32 %kop, ptr %parent, ptr %kenv, ptr %kh, ptr %value, ptr null, ptr null, ptr null, i64 0)
  call void @g_schedule(ptr %iterator, ptr %ka, ptr %kb, ptr %kenv, ptr %applybinary, ptr %kh)
  br label %loop
kbinary:
  %logicop = icmp uge i32 %kop, 11
  %left = select i1 %logicop, ptr %ka, ptr %value
  %right = select i1 %logicop, ptr %value, ptr %ka
  %binaryvalue = call ptr @j_binary(i32 %kop, ptr %left, ptr %right)
  store ptr %binaryvalue, ptr %currentvalue
  br label %emitcheck
kfieldouter:
  %fieldk = call ptr @g_cont(i32 5, i32 0, ptr %parent, ptr %kenv, ptr %kh, ptr %value, ptr null, ptr null, ptr null, i64 0)
  call void @g_schedule(ptr %iterator, ptr %ka, ptr %kb, ptr %kenv, ptr %fieldk, ptr %kh)
  br label %loop
kfield:
  %fieldvalue = call ptr @j_get(ptr %ka, ptr %value)
  store ptr %fieldvalue, ptr %currentvalue
  br label %emitcheck
kiterate:
  %iterkind = load i32, ptr %value
  %iterarray = icmp eq i32 %iterkind, 5
  %iterobject = icmp eq i32 %iterkind, 6
  %iterable = or i1 %iterarray, %iterobject
  br i1 %iterable, label %iterready, label %iterbad
iterready:
  call void @g_values(ptr %iterator, ptr %value, ptr %parent, ptr %kh)
  br label %loop
iterbad:
  call void @ev_itererror(ptr %value)
  br label %raise
kcollect:
  call void @j_push(ptr %ka, ptr %value)
  br label %loop
kbind:
  %patternkind = load i32, ptr %ka
  %patterns = icmp eq i32 %patternkind, 27
  br i1 %patterns, label %kbindalternatives, label %kbindsingle
kbindalternatives:
  %initialized = call ptr @ev_patternnull(ptr %ka, ptr %kenv)
  %alternatives = call ptr @g_bind_alternatives(ptr %ka, ptr %value, ptr %kc, ptr %kb)
  call void @g_schedule(ptr %iterator, ptr %alternatives, ptr %kc, ptr %initialized, ptr %parent, ptr %kh)
  br label %checkerror
kbindsingle:
  %bound = call ptr @ev_bindpattern(ptr %kenv, ptr %ka, ptr %value, ptr %kc)
  call void @g_schedule(ptr %iterator, ptr %kb, ptr %kc, ptr %bound, ptr %parent, ptr %kh)
  br label %checkerror
kcondition:
  %condition = call i1 @j_truth(ptr %value)
  %branch = select i1 %condition, ptr %ka, ptr %kb
  call void @g_schedule(ptr %iterator, ptr %branch, ptr %kc, ptr %kenv, ptr %parent, ptr %kh)
  br label %loop
knegative:
  %negativevalue = call ptr @j_negate(ptr %value)
  store ptr %negativevalue, ptr %currentvalue
  br label %emitcheck
kalternative:
  %keep = call i1 @j_truth(ptr %value)
  br i1 %keep, label %altkeep, label %loop
altkeep:
  store i1 true, ptr %ka
  br label %emit
kobjectkey:
  %keytype = load i32, ptr %value
  %stringkey = icmp eq i32 %keytype, 4
  br i1 %stringkey, label %objectkeyvalid, label %objectkeybad
objectkeybad:
  call void @j_object_key_error(ptr %value)
  br label %raise
objectkeyvalid:
  %nextpair = add i64 %kx, 2
  %objectk = call ptr @g_cont(i32 13, i32 0, ptr %parent, ptr %kenv, ptr %kh, ptr %ka, ptr %kb, ptr %kc, ptr %value, i64 %nextpair)
  call void @g_schedule(ptr %iterator, ptr %kd, ptr %kc, ptr %kenv, ptr %objectk, ptr %kh)
  br label %loop
kobjectvalue:
  %objectcopy = call ptr @j_clone(ptr %kb)
  call void @j_put(ptr %objectcopy, ptr %kd, ptr %value)
  call void @g_object(ptr %iterator, ptr %ka, i64 %kx, ptr %objectcopy, ptr %kc, ptr %kenv, ptr %parent, ptr %kh)
  br label %loop
kcallarg:
  %callbody = load ptr, ptr %ka
  %cap = getelementptr %GA, ptr %ka, i32 0, i32 1
  %callparams = load ptr, ptr %cap
  %cbp = getelementptr %GA, ptr %ka, i32 0, i32 2
  %callargs = load ptr, ptr %cbp
  %cip = getelementptr %GA, ptr %ka, i32 0, i32 3
  %callinput = load ptr, ptr %cip
  %cep = getelementptr %GA, ptr %ka, i32 0, i32 4
  %callenv = load ptr, ptr %cep
  %cbasep = getelementptr %GA, ptr %ka, i32 0, i32 5
  %callbase = load ptr, ptr %cbasep
  %cnp = getelementptr %GA, ptr %ka, i32 0, i32 6
  %callname = load ptr, ptr %cnp
  %cxp = getelementptr %GA, ptr %ka, i32 0, i32 7
  %callindex = load i64, ptr %cxp
  %callbound = call ptr @j_bind(ptr %callbase, ptr %callname, ptr %value)
  call void @g_callargs(ptr %iterator, ptr %callbody, ptr %callparams, ptr %callargs, i64 %callindex, ptr %callinput, ptr %callenv, ptr %callbound, ptr %parent, ptr %kh)
  br label %loop
kselect:
  %selected = call i1 @j_truth(ptr %value)
  br i1 %selected, label %selectedvalue, label %loop
selectedvalue:
  store ptr %ka, ptr %currentvalue
  br label %emit
krangestart:
  %endast = call ptr @j_at(ptr %ka, i64 1)
  %endk = call ptr @g_cont(i32 17, i32 0, ptr %parent, ptr %kenv, ptr %kh, ptr %ka, ptr %kb, ptr %value, ptr null, i64 0)
  call void @g_schedule(ptr %iterator, ptr %endast, ptr %kb, ptr %kenv, ptr %endk, ptr %kh)
  br label %loop
krangeend:
  %rangeparams = call i64 @b_len(ptr %ka)
  %givestep = icmp ugt i64 %rangeparams, 2
  br i1 %givestep, label %rangedynamicstep, label %rangeunitstep
rangedynamicstep:
  %stepast = call ptr @j_at(ptr %ka, i64 2)
  %stepk = call ptr @g_cont(i32 18, i32 0, ptr %parent, ptr %kenv, ptr %kh, ptr %kc, ptr %value, ptr null, ptr null, i64 0)
  call void @g_schedule(ptr %iterator, ptr %stepast, ptr %kb, ptr %kenv, ptr %stepk, ptr %kh)
  br label %loop
rangeunitstep:
  %unit = call ptr @j_num(double 1.000000e+00)
  %unitrange = call ptr @ev_node(i32 103, i32 0, ptr %kc, ptr %value, ptr %unit, ptr null)
  call void @g_schedule(ptr %iterator, ptr %unitrange, ptr %kb, ptr %kenv, ptr %parent, ptr %kh)
  br label %loop
krangestep:
  %stepzero = call ptr @j_num(double 0.000000e+00)
  %steporder = call i32 @j_cmp(ptr %value, ptr %stepzero)
  %stepnonzero = icmp ne i32 %steporder, 0
  br i1 %stepnonzero, label %rangegeneral, label %loop
rangegeneral:
  %steppositive = icmp sgt i32 %steporder, 0
  %rangecomparison = select i1 %steppositive, i32 7, i32 9
  %rangedot = call ptr @ev_node(i32 1, i32 0, ptr null, ptr null, ptr null, ptr null)
  %endconstant = call ptr @ev_node(i32 0, i32 0, ptr %kb, ptr null, ptr null, ptr null)
  %stepconstant = call ptr @ev_node(i32 0, i32 0, ptr %value, ptr null, ptr null, ptr null)
  %rangecondition = call ptr @ev_node(i32 4, i32 %rangecomparison, ptr %rangedot, ptr %endconstant, ptr null, ptr null)
  %rangeupdate = call ptr @ev_node(i32 4, i32 0, ptr %rangedot, ptr %stepconstant, ptr null, ptr null)
  %steprange = call ptr @ev_node(i32 102, i32 0, ptr %rangecondition, ptr %rangeupdate, ptr null, ptr null)
  call void @g_schedule(ptr %iterator, ptr %steprange, ptr %ka, ptr %kenv, ptr %parent, ptr %kh)
  br label %loop
krecurse:
  %hascondition = icmp ne ptr %kb, null
  br i1 %hascondition, label %recursecheck, label %recurseagain
recursecheck:
  %predicatek = call ptr @g_cont(i32 20, i32 0, ptr %parent, ptr %kenv, ptr %kh, ptr %ka, ptr %value, ptr null, ptr null, i64 0)
  call void @g_schedule(ptr %iterator, ptr %kb, ptr %value, ptr %kenv, ptr %predicatek, ptr %kh)
  br label %loop
recurseagain:
  call void @g_schedule(ptr %iterator, ptr %ka, ptr %value, ptr %kenv, ptr %parent, ptr %kh)
  br label %loop
krecursecondition:
  %recurseyes = call i1 @j_truth(ptr %value)
  br i1 %recurseyes, label %recursetrue, label %loop
recursetrue:
  call void @g_schedule(ptr %iterator, ptr %ka, ptr %kb, ptr %kenv, ptr %parent, ptr %kh)
  br label %loop
kwhile:
  %conditiontruth = call i1 @j_truth(ptr %value)
  %untilmode = icmp ne i32 %kop, 0
  %keepgoing = xor i1 %conditiontruth, %untilmode
  br i1 %keepgoing, label %whileupdate, label %whilefinished
whileupdate:
  %loopk = call ptr @g_cont(i32 22, i32 0, ptr %parent, ptr %kenv, ptr %kh, ptr %ka, ptr null, ptr null, ptr null, i64 0)
  call void @g_schedule(ptr %iterator, ptr %kb, ptr %kc, ptr %kenv, ptr %loopk, ptr %kh)
  br i1 %untilmode, label %loop, label %whileemit
whilefinished:
  br i1 %untilmode, label %whileemit, label %loop
whileemit:
  store ptr %kc, ptr %currentvalue
  br label %emit
kloop:
  call void @g_schedule(ptr %iterator, ptr %ka, ptr %value, ptr %kenv, ptr %parent, ptr %kh)
  br label %loop
kquota:
  %quota = call double @b_number(ptr %value)
  %quotazero = call ptr @j_num(double 0.000000e+00)
  %quotacomparison = call i32 @j_cmp(ptr %value, ptr %quotazero)
  %negativequota = icmp slt i32 %quotacomparison, 0
  br i1 %negativequota, label %quotanegative, label %quotacheck
quotanegative:
  %skipmode = icmp eq i32 %kop, 11
  %nthquotamode = icmp eq i32 %kop, 9
  %quotamsg0 = select i1 %skipmode, ptr @g_skip_error, ptr @g_limit_error
  %quotamsg = select i1 %nthquotamode, ptr @g_nth_error, ptr %quotamsg0
  call void @j_fail(ptr %quotamsg)
  br label %raise
quotacheck:
  %zerolimit = fcmp oeq double %quota, 0.000000e+00
  %limiting = icmp eq i32 %kop, 10
  %skipall = and i1 %zerolimit, %limiting
  br i1 %skipall, label %loop, label %quotaiter
quotaiter:
  %quotachild = call ptr @j_iter(ptr %ka, ptr %kb, ptr %kenv)
  %quotawork = call ptr @g_work(ptr %iterator, i32 6, i32 %kop, ptr null, ptr %kb, ptr %kenv, ptr %parent, ptr %kh, ptr %quotachild, ptr %value, i64 0)
  br label %loop
ktruncate:
  %truncatepath = call ptr @j_at(ptr %value, i64 0)
  %truncatelen = call i64 @b_len(ptr %truncatepath)
  %truncatelend = uitofp i64 %truncatelen to double
  %truncatedepth = call double @b_number(ptr %ka)
  %truncatemore = fcmp ogt double %truncatelend, %truncatedepth
  br i1 %truncatemore, label %truncatekeep, label %loop
truncatekeep:
  %truncateend = call ptr @j_null()
  %truncatedpath = call ptr @ev_slice(ptr %truncatepath, ptr %ka, ptr %truncateend)
  %truncatedevent = call ptr @j_array()
  call void @j_push(ptr %truncatedevent, ptr %truncatedpath)
  %truncatesize = call i64 @b_len(ptr %value)
  %truncatedata = icmp eq i64 %truncatesize, 2
  br i1 %truncatedata, label %truncatevalue, label %truncatedone
truncatevalue:
  %truncateleaf = call ptr @j_at(ptr %value, i64 1)
  call void @j_push(ptr %truncatedevent, ptr %truncateleaf)
  br label %truncatedone
truncatedone:
  store ptr %truncatedevent, ptr %currentvalue
  br label %emitcheck
kreduceinitial:
  %redsourcep = getelementptr %GN, ptr %ka, i32 0, i32 2
  %redsource = load ptr, ptr %redsourcep
  %rediterator = call ptr @j_iter(ptr %redsource, ptr %kb, ptr %kenv)
  %redstates = call ptr @j_array()
  call void @j_push(ptr %redstates, ptr %value)
  %redwork = call ptr @g_work(ptr %iterator, i32 10, i32 %kop, ptr %ka, ptr %kb, ptr %kenv, ptr %parent, ptr %kh, ptr %rediterator, ptr %redstates, i64 0)
  br label %loop
kreducestate:
  %redupdatek = call ptr @g_cont(i32 25, i32 %kop, ptr %parent, ptr %kenv, ptr %kh, ptr %kb, ptr %kc, ptr null, ptr null, i64 0)
  call void @g_schedule(ptr %iterator, ptr %ka, ptr %value, ptr %kenv, ptr %redupdatek, ptr %kh)
  br label %loop
kreducecollect:
  call void @j_push(ptr %ka, ptr %value)
  %isforeach = icmp eq i32 %kop, 280
  br i1 %isforeach, label %foreachvalue, label %loop
foreachvalue:
  %hasextract = icmp ne ptr %kb, null
  br i1 %hasextract, label %foreachextract, label %emit
foreachextract:
  call void @g_schedule(ptr %iterator, ptr %kb, ptr %value, ptr %kenv, ptr %parent, ptr %kh)
  br label %loop
kslicebase:
  %slicenull = call ptr @j_null()
  %slicenullast = call ptr @ev_node(i32 0, i32 0, ptr %slicenull, ptr null, ptr null, ptr null)
  %slicenostart = icmp eq ptr %ka, null
  %slicestartast = select i1 %slicenostart, ptr %slicenullast, ptr %ka
  %slicestartk = call ptr @g_cont(i32 29, i32 0, ptr %parent, ptr %kenv, ptr %kh, ptr %kb, ptr %value, ptr %kc, ptr null, i64 0)
  call void @g_schedule(ptr %iterator, ptr %slicestartast, ptr %kc, ptr %kenv, ptr %slicestartk, ptr %kh)
  br label %loop
kslicestart:
  %sliceendnull = call ptr @j_null()
  %sliceendnullast = call ptr @ev_node(i32 0, i32 0, ptr %sliceendnull, ptr null, ptr null, ptr null)
  %slicenoend = icmp eq ptr %ka, null
  %sliceendast = select i1 %slicenoend, ptr %sliceendnullast, ptr %ka
  %sliceendk = call ptr @g_cont(i32 30, i32 0, ptr %parent, ptr %kenv, ptr %kh, ptr %kb, ptr %value, ptr null, ptr null, i64 0)
  call void @g_schedule(ptr %iterator, ptr %sliceendast, ptr %kc, ptr %kenv, ptr %sliceendk, ptr %kh)
  br label %loop
ksliceend:
  %sliced = call ptr @ev_slice(ptr %ka, ptr %kb, ptr %value)
  store ptr %sliced, ptr %currentvalue
  br label %emitcheck
knativearg:
  %nativeargsclone = call ptr @j_clone(ptr %kb)
  %nativeargsdata = call ptr @b_data(ptr %nativeargsclone)
  %nativeargslot = getelementptr ptr, ptr %nativeargsdata, i64 %kx
  %nativeargliteral = call ptr @ev_node(i32 0, i32 0, ptr %value, ptr null, ptr null, ptr null)
  store ptr %nativeargliteral, ptr %nativeargslot
  %nativeargstep = sext i32 %kop to i64
  %nativenextarg = add i64 %kx, %nativeargstep
  call void @g_native_args(ptr %iterator, ptr %ka, ptr %nativeargsclone, i64 %nativenextarg, ptr %kc, ptr %kenv, ptr %parent, ptr %kh)
  br label %loop
kassignment:
  %assignmentliteral = call ptr @ev_node(i32 0, i32 0, ptr %value, ptr null, ptr null, ptr null)
  %assignmentnode = call ptr @ev_node(i32 19, i32 %kop, ptr %ka, ptr %assignmentliteral, ptr null, ptr null)
  %assignmentresults = call ptr @j_eval_atom(ptr %assignmentnode, ptr %kb, ptr %kenv)
  call void @g_values(ptr %iterator, ptr %assignmentresults, ptr %parent, ptr %kh)
  br label %checkerror
kjoin:
  %joinarity = call i64 @b_len(ptr %ka)
  %jointwo = icmp eq i64 %joinarity, 2
  %joinfour = icmp eq i64 %joinarity, 4
  %joinidentity = call ptr @ev_node(i32 1, i32 0, ptr null, ptr null, ptr null, ptr null)
  br i1 %jointwo, label %joinvalues, label %joingenerator
joinvalues:
  %joiniterate = call ptr @ev_node(i32 6, i32 0, ptr %joinidentity, ptr null, ptr null, ptr null)
  br label %joinready
joingenerator:
  %joinrows = call ptr @j_at(ptr %ka, i64 1)
  br label %joinready
joinready:
  %joinstream = phi ptr [%joiniterate, %joinvalues], [%joinrows, %joingenerator]
  %joinkeyindex = select i1 %jointwo, i64 1, i64 2
  %joinkeyast = call ptr @j_at(ptr %ka, i64 %joinkeyindex)
  %joinindexliteral = call ptr @ev_node(i32 0, i32 0, ptr %value, ptr null, ptr null, ptr null)
  %joinlookup = call ptr @ev_node(i32 5, i32 0, ptr %joinindexliteral, ptr %joinkeyast, ptr null, ptr null)
  %joinpairbody = call ptr @ev_node(i32 3, i32 0, ptr %joinidentity, ptr %joinlookup, ptr null, ptr null)
  %joinpair = call ptr @ev_node(i32 8, i32 0, ptr %joinpairbody, ptr null, ptr null, ptr null)
  %joinpairs = call ptr @ev_node(i32 2, i32 0, ptr %joinstream, ptr %joinpair, ptr null, ptr null)
  br i1 %jointwo, label %joincollect, label %jointransformcheck
joincollect:
  %joinarray = call ptr @ev_node(i32 8, i32 0, ptr %joinpairs, ptr null, ptr null, ptr null)
  br label %joinexecute
jointransformcheck:
  br i1 %joinfour, label %jointransform, label %joinplain
jointransform:
  %jointransformast = call ptr @j_at(ptr %ka, i64 3)
  %jointransformed = call ptr @ev_node(i32 2, i32 0, ptr %joinpairs, ptr %jointransformast, ptr null, ptr null)
  br label %joinexecute
joinplain:
  br label %joinexecute
joinexecute:
  %joinexpression = phi ptr [%joinarray, %joincollect], [%jointransformed, %jointransform], [%joinpairs, %joinplain]
  call void @g_schedule(ptr %iterator, ptr %joinexpression, ptr %kb, ptr %kenv, ptr %parent, ptr %kh)
  br label %loop
emitcheck:
  %emiterror = load ptr, ptr @j_error
  %emitbad = icmp ne ptr %emiterror, null
  br i1 %emitbad, label %raise, label %emit
checkerror:
  %checkerr = load ptr, ptr @j_error
  %checkbad = icmp ne ptr %checkerr, null
  br i1 %checkbad, label %raise, label %loop
raise:
  %raised = load ptr, ptr @j_error
  %broken = load ptr, ptr @ev_break_name
  %isbreak = icmp ne ptr %broken, null
  %firsthandler = load ptr, ptr %currenthandler
  br label %findhandler
findhandler:
  %h = phi ptr [ %firsthandler, %raise ], [ %outerhandler, %handlernext ]
  %unhandled = icmp eq ptr %h, null
  br i1 %unhandled, label %abort, label %handlercheck
handlercheck:
  %outerhandler = load ptr, ptr %h
  %labelp = getelementptr %GH, ptr %h, i32 0, i32 5
  %labelname = load ptr, ptr %labelp
  %islabel = icmp ne ptr %labelname, null
  br i1 %isbreak, label %breakhandler, label %errorhandler
breakhandler:
  br i1 %islabel, label %labelmatch, label %handlernext
labelmatch:
  %labelcmp = call i32 @j_cmp(ptr %labelname, ptr %broken)
  %matchinglabel = icmp eq i32 %labelcmp, 0
  br i1 %matchinglabel, label %caughtbreak, label %handlernext
errorhandler:
  br i1 %islabel, label %handlernext, label %caughterror
handlernext:
  br label %findhandler
caughtbreak:
  %breaksavedp = getelementptr %GH, ptr %h, i32 0, i32 4
  %breaksaved = load ptr, ptr %breaksavedp
  store ptr %breaksaved, ptr %iterator
  store ptr null, ptr @ev_break_name
  br label %loop
caughterror:
  %errorresume = getelementptr %GH, ptr %h, i32 0, i32 4
  %errorsaved = load ptr, ptr %errorresume
  store ptr %errorsaved, ptr %iterator
  store ptr null, ptr @j_error
  %catchp = getelementptr %GH, ptr %h, i32 0, i32 1
  %catch = load ptr, ptr %catchp
  %catchenvp = getelementptr %GH, ptr %h, i32 0, i32 2
  %catchenv = load ptr, ptr %catchenvp
  %catchkp = getelementptr %GH, ptr %h, i32 0, i32 3
  %catchk = load ptr, ptr %catchkp
  call void @g_schedule(ptr %iterator, ptr %catch, ptr %raised, ptr %catchenv, ptr %catchk, ptr %outerhandler)
  br label %loop
abort:
  store ptr null, ptr %iterator
  br label %done
yield:
  store i64 %previousdepth, ptr @g_next_depth
  ret ptr %value
done:
  store i64 %previousdepth, ptr @g_next_depth
  ret ptr null
}

define ptr @j_eval(ptr %node, ptr %input, ptr %env) {
entry:
  %iterator = call ptr @j_iter(ptr %node, ptr %input, ptr %env)
  %values = call ptr @j_array()
  br label %loop
loop:
  %value = call ptr @j_next(ptr %iterator)
  %done = icmp eq ptr %value, null
  br i1 %done, label %finish, label %append
append:
  call void @j_push(ptr %values, ptr %value)
  br label %loop
finish:
  ret ptr %values
}

define ptr @j_eval_take(ptr %node, ptr %input, ptr %env, i64 %count) {
entry:
  %iterator = call ptr @j_iter(ptr %node, ptr %input, ptr %env)
  %values = call ptr @j_array()
  br label %loop
loop:
  %i = phi i64 [ 0, %entry ], [ %next, %append ]
  %enough = icmp sge i64 %i, %count
  br i1 %enough, label %finish, label %take
take:
  %value = call ptr @j_next(ptr %iterator)
  %done = icmp eq ptr %value, null
  br i1 %done, label %finish, label %append
append:
  call void @j_push(ptr %values, ptr %value)
  %next = add i64 %i, 1
  br label %loop
finish:
  ret ptr %values
}
