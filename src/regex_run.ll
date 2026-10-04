%RX = type { i32, i32, i32, i32, ptr, ptr, ptr }
%RC = type { ptr, ptr, ptr, i64, i32, i32, ptr, i64, i64, i64, ptr, ptr, ptr, ptr, i64 }

@rr_badref = private constant [35 x i8] c"Regex failure: undefined reference\00"

declare ptr @j_alloc(i64)
declare ptr @j_at(ptr, i64)
declare i32 @j_cmp(ptr, ptr)
declare void @j_fail(ptr)
declare ptr @b_data(ptr)
declare i64 @b_len(ptr)
declare i64 @rx_run(ptr, ptr, i64, ptr, i64)
declare void @llvm.memcpy.p0.p0.i64(ptr, ptr, i64, i1)

define internal void @rr_copy(ptr %destination, ptr %source, i64 %bytes) {
entry:
  br label %loop
loop:
  %i = phi i64 [0, %entry], [%next, %body]
  %more = icmp ult i64 %i, %bytes
  br i1 %more, label %body, label %done
body:
  %sp = getelementptr i8, ptr %source, i64 %i
  %dp = getelementptr i8, ptr %destination, i64 %i
  %value = load volatile i64, ptr %sp, align 8
  store volatile i64 %value, ptr %dp, align 8
  %next = add i64 %i, 8
  br label %loop
done:
  ret void
}

define internal i64 @rr_capture_bytes(ptr %ctx) {
  %cp = getelementptr %RC, ptr %ctx, i32 0, i32 5
  %count = load i32, ptr %cp
  %count64 = zext i32 %count to i64
  %bytes = mul i64 %count64, 16
  ret i64 %bytes
}

define i64 @rx_split(ptr %node, ptr %ctx, i64 %pos, ptr %captures, i64 %depth) {
entry:
  %vp = getelementptr %RC, ptr %ctx, i32 0, i32 10
  %visited = load ptr, ptr %vp
  br label %guard
guard:
  %v = phi ptr [%visited, %entry], [%previous, %guardnext]
  %empty = icmp eq ptr %v, null
  br i1 %empty, label %begin, label %guardread
guardread:
  %active = load ptr, ptr %v
  %pp = getelementptr i64, ptr %v, i64 1
  %activepos = load i64, ptr %pp
  %samenode = icmp eq ptr %active, %node
  %samepos = icmp eq i64 %activepos, %pos
  %cycle = and i1 %samenode, %samepos
  br i1 %cycle, label %fail, label %guardnext
guardnext:
  %np = getelementptr ptr, ptr %v, i64 2
  %previous = load ptr, ptr %np
  br label %guard
begin:
  %guardrow = alloca {ptr, i64, ptr}
  store ptr %node, ptr %guardrow
  %guardpos = getelementptr i64, ptr %guardrow, i64 1
  %guardprev = getelementptr ptr, ptr %guardrow, i64 2
  store i64 %pos, ptr %guardpos
  store ptr %visited, ptr %guardprev
  store ptr %guardrow, ptr %vp
  %ap = getelementptr %RX, ptr %node, i32 0, i32 4
  %bp = getelementptr %RX, ptr %node, i32 0, i32 5
  %a = load ptr, ptr %ap
  %b = load ptr, ptr %bp
  %fp = getelementptr %RC, ptr %ctx, i32 0, i32 4
  %flags = load i32, ptr %fp
  %lb = and i32 %flags, 64
  %longest = icmp ne i32 %lb, 0
  %kp = getelementptr %RC, ptr %ctx, i32 0, i32 8
  %oldkeep = load i64, ptr %kp
  %bytes = call i64 @rr_capture_bytes(ptr %ctx)
  %before = call ptr @j_alloc(i64 %bytes)
  call void @rr_copy(ptr %before, ptr %captures, i64 %bytes)
  %left = call i64 @rx_run(ptr %a, ptr %ctx, i64 %pos, ptr %captures, i64 %depth)
  %leftok = icmp sge i64 %left, 0
  %shortest = xor i1 %longest, true
  %acceptfirst = and i1 %leftok, %shortest
  br i1 %acceptfirst, label %leftdone, label %right
right:
  %leftkeep = load i64, ptr %kp
  %leftcaps = call ptr @j_alloc(i64 %bytes)
  call void @rr_copy(ptr %leftcaps, ptr %captures, i64 %bytes)
  call void @rr_copy(ptr %captures, ptr %before, i64 %bytes)
  store i64 %oldkeep, ptr %kp
  %rightresult = call i64 @rx_run(ptr %b, ptr %ctx, i64 %pos, ptr %captures, i64 %depth)
  %preferleft = icmp sge i64 %left, %rightresult
  %useleft = and i1 %preferleft, %leftok
  br i1 %useleft, label %restoreleft, label %rightdone
restoreleft:
  call void @rr_copy(ptr %captures, ptr %leftcaps, i64 %bytes)
  store i64 %leftkeep, ptr %kp
  br label %leftdone
leftdone:
  store ptr %visited, ptr %vp
  ret i64 %left
rightdone:
  store ptr %visited, ptr %vp
  ret i64 %rightresult
fail:
  ret i64 -1
}

define i64 @rx_assert(ptr %node, ptr %ctx, i64 %pos, ptr %captures, i64 %depth) {
entry:
  %op = load i32, ptr %node
  %ap = getelementptr %RX, ptr %node, i32 0, i32 4
  %bp = getelementptr %RX, ptr %node, i32 0, i32 5
  %next = load ptr, ptr %ap
  %inner = load ptr, ptr %bp
  %negativeahead = icmp eq i32 %op, 12
  %negativebehind = icmp eq i32 %op, 16
  %negative = or i1 %negativeahead, %negativebehind
  %positivebehind = icmp eq i32 %op, 15
  %behind = or i1 %positivebehind, %negativebehind
  %atomic = icmp eq i32 %op, 17
  %bytes = call i64 @rr_capture_bytes(ptr %ctx)
  %before = call ptr @j_alloc(i64 %bytes)
  %working = call ptr @j_alloc(i64 %bytes)
  call void @rr_copy(ptr %before, ptr %captures, i64 %bytes)
  %innerctx = alloca %RC
  call void @rr_copy(ptr %innerctx, ptr %ctx, i64 112)
  %fp = getelementptr %RC, ptr %innerctx, i32 0, i32 4
  %flags = load i32, ptr %fp
  %assertflags = and i32 %flags, -97
  store i32 %assertflags, ptr %fp
  %targetp = getelementptr %RC, ptr %innerctx, i32 0, i32 9
  store i64 %pos, ptr %targetp
  %visitedp = getelementptr %RC, ptr %innerctx, i32 0, i32 10
  store ptr null, ptr %visitedp
  %kp = getelementptr %RC, ptr %ctx, i32 0, i32 8
  %beforekeep = load i64, ptr %kp
  br label %try
try:
  %start = phi i64 [%pos, %entry], [%previous, %advance]
  call void @rr_copy(ptr %working, ptr %before, i64 %bytes)
  %result = call i64 @rx_run(ptr %inner, ptr %innerctx, i64 %start, ptr %working, i64 %depth)
  %matched = icmp sge i64 %result, 0
  br i1 %matched, label %found, label %miss
miss:
  %hasprevious = icmp ugt i64 %start, 0
  %retry = and i1 %hasprevious, %behind
  br i1 %retry, label %advance, label %notfound
advance:
  %previous = sub i64 %start, 1
  br label %try
found:
  br i1 %negative, label %fail, label %success
notfound:
  br i1 %negative, label %continue, label %fail
success:
  call void @rr_copy(ptr %captures, ptr %working, i64 %bytes)
  %innerkp = getelementptr %RC, ptr %innerctx, i32 0, i32 8
  %innerkeep = load i64, ptr %innerkp
  store i64 %innerkeep, ptr %kp
  br label %continue
continue:
  %after = phi i64 [%pos, %notfound], [%result, %success]
  %nextpos = select i1 %atomic, i64 %after, i64 %pos
  %continued = call i64 @rx_run(ptr %next, ptr %ctx, i64 %nextpos, ptr %captures, i64 %depth)
  %ok = icmp sge i64 %continued, 0
  br i1 %ok, label %done, label %restore
restore:
  call void @rr_copy(ptr %captures, ptr %before, i64 %bytes)
  store i64 %beforekeep, ptr %kp
  br label %fail
done:
  ret i64 %continued
fail:
  ret i64 -1
}

define i32 @rx_reference_id(ptr %name, i32 %base, ptr %ctx, ptr %captures) {
entry:
  %numbered = icmp eq ptr %name, null
  br i1 %numbered, label %direct, label %named
direct:
  ret i32 %base
named:
  %data = call ptr @b_data(ptr %name)
  %n = call i64 @b_len(ptr %name)
  %first = load i8, ptr %data
  %negative = icmp eq i8 %first, 45
  %positive = icmp eq i8 %first, 43
  %signed = or i1 %negative, %positive
  %start = zext i1 %signed to i64
  br label %number
number:
  %i = phi i64 [%start, %named], [%next, %digit]
  %value = phi i32 [0, %named], [%sum, %digit]
  %more = icmp ult i64 %i, %n
  br i1 %more, label %read, label %numeric
read:
  %p = getelementptr i8, ptr %data, i64 %i
  %c = load i8, ptr %p
  %d = sub i8 %c, 48
  %decimal = icmp ult i8 %d, 10
  br i1 %decimal, label %digit, label %names
digit:
  %d32 = zext i8 %d to i32
  %times = mul i32 %value, 10
  %sum = add i32 %times, %d32
  %next = add i64 %i, 1
  br label %number
numeric:
  %relative = sub i32 %base, %value
  %absolute = sub i32 %value, 1
  %forward = add i32 %base, %absolute
  %nonnegative = select i1 %positive, i32 %forward, i32 %absolute
  %numberid = select i1 %negative, i32 %relative, i32 %nonnegative
  ret i32 %numberid
names:
  %np = getelementptr %RC, ptr %ctx, i32 0, i32 6
  %allnames = load ptr, ptr %np
  %cp = getelementptr %RC, ptr %ctx, i32 0, i32 5
  %count = load i32, ptr %cp
  br label %loop
loop:
  %index = phi i32 [%count, %names], [%candidate, %advance]
  %has = icmp ugt i32 %index, 0
  br i1 %has, label %check, label %missing
check:
  %candidate = sub i32 %index, 1
  %index64 = zext i32 %candidate to i64
  %other = call ptr @j_at(ptr %allnames, i64 %index64)
  %cmp = call i32 @j_cmp(ptr %name, ptr %other)
  %same = icmp eq i32 %cmp, 0
  br i1 %same, label %capturecheck, label %advance
capturecheck:
  %nullcaps = icmp eq ptr %captures, null
  br i1 %nullcaps, label %found, label %captureread
captureread:
  %capindex = mul i64 %index64, 2
  %capp = getelementptr i64, ptr %captures, i64 %capindex
  %capturestart = load i64, ptr %capp
  %set = icmp sge i64 %capturestart, 0
  br i1 %set, label %found, label %advance
advance:
  br label %loop
found:
  ret i32 %candidate
missing:
  ret i32 -1
}

define i64 @rx_call(ptr %node, ptr %ctx, i64 %pos, ptr %captures, i64 %depth) {
entry:
  %vp = getelementptr %RC, ptr %ctx, i32 0, i32 10
  %visited = load ptr, ptr %vp
  br label %guard
guard:
  %active = phi ptr [%visited, %entry], [%previous, %guardnext]
  %empty = icmp eq ptr %active, null
  br i1 %empty, label %resolve, label %guardread
guardread:
  %activenode = load ptr, ptr %active
  %activepp = getelementptr i64, ptr %active, i64 1
  %activepos = load i64, ptr %activepp
  %samenode = icmp eq ptr %activenode, %node
  %samepos = icmp eq i64 %activepos, %pos
  %cycle = and i1 %samenode, %samepos
  br i1 %cycle, label %fail, label %guardnext
guardnext:
  %prevp = getelementptr ptr, ptr %active, i64 2
  %previous = load ptr, ptr %prevp
  br label %guard
resolve:
  %bp = getelementptr %RX, ptr %node, i32 0, i32 1
  %base = load i32, ptr %bp
  %ap = getelementptr %RX, ptr %node, i32 0, i32 4
  %next = load ptr, ptr %ap
  %dp = getelementptr %RX, ptr %node, i32 0, i32 6
  %name = load ptr, ptr %dp
  %id = call i32 @rx_reference_id(ptr %name, i32 %base, ptr %ctx, ptr null)
  %cp = getelementptr %RC, ptr %ctx, i32 0, i32 5
  %count = load i32, ptr %cp
  %capture = icmp ult i32 %id, %count
  br i1 %capture, label %prepare, label %rootcheck
rootcheck:
  %namelen = call i64 @b_len(ptr %name)
  %single = icmp eq i64 %namelen, 1
  %namedata = call ptr @b_data(ptr %name)
  %namechar = load i8, ptr %namedata
  %zero = icmp eq i8 %namechar, 48
  %root = and i1 %single, %zero
  br i1 %root, label %prepare, label %invalid
prepare:
  %guardrow = alloca {ptr, i64, ptr}
  store ptr %node, ptr %guardrow
  %guardpp = getelementptr i64, ptr %guardrow, i64 1
  %guardvp = getelementptr ptr, ptr %guardrow, i64 2
  store i64 %pos, ptr %guardpp
  store ptr %visited, ptr %guardvp
  store ptr %guardrow, ptr %vp
  %groupsp = getelementptr %RC, ptr %ctx, i32 0, i32 12
  %groups = load ptr, ptr %groupsp
  %index = add i32 %id, 1
  %index64 = sext i32 %index to i64
  %body = call ptr @j_at(ptr %groups, i64 %index64)
  %stackp = getelementptr %RC, ptr %ctx, i32 0, i32 13
  %stack = load ptr, ptr %stackp
  %frame = alloca {ptr, ptr, i64}
  store ptr %next, ptr %frame
  %frameprev = getelementptr ptr, ptr %frame, i64 1
  store ptr %stack, ptr %frameprev
  %limitp = getelementptr %RC, ptr %ctx, i32 0, i32 14
  %limit = load i64, ptr %limitp
  %framelimit = getelementptr i64, ptr %frame, i64 2
  store i64 %limit, ptr %framelimit
  store ptr %frame, ptr %stackp
  %result = call i64 @rx_run(ptr %body, ptr %ctx, i64 %pos, ptr %captures, i64 %depth)
  store ptr %stack, ptr %stackp
  store ptr %visited, ptr %vp
  ret i64 %result
invalid:
  call void @j_fail(ptr @rr_badref)
  br label %fail
fail:
  ret i64 -1
}

define i64 @rx_return(ptr %ctx, i64 %pos, ptr %captures, i64 %depth) {
entry:
  %stackp = getelementptr %RC, ptr %ctx, i32 0, i32 13
  %frame = load ptr, ptr %stackp
  %empty = icmp eq ptr %frame, null
  br i1 %empty, label %done, label %return
return:
  %next = load ptr, ptr %frame
  %pp = getelementptr ptr, ptr %frame, i64 1
  %previous = load ptr, ptr %pp
  %lp = getelementptr i64, ptr %frame, i64 2
  %outerlimit = load i64, ptr %lp
  %limitp = getelementptr %RC, ptr %ctx, i32 0, i32 14
  %innerlimit = load i64, ptr %limitp
  store i64 %outerlimit, ptr %limitp
  store ptr %previous, ptr %stackp
  %result = call i64 @rx_run(ptr %next, ptr %ctx, i64 %pos, ptr %captures, i64 %depth)
  store ptr %frame, ptr %stackp
  store i64 %innerlimit, ptr %limitp
  ret i64 %result
done:
  ret i64 %pos
}

define i64 @rx_absent(ptr %node, ptr %ctx, i64 %pos, ptr %captures, i64 %depth) {
entry:
  %mp = getelementptr %RX, ptr %node, i32 0, i32 1
  %mode = load i32, ptr %mp
  %ap = getelementptr %RX, ptr %node, i32 0, i32 4
  %bp = getelementptr %RX, ptr %node, i32 0, i32 5
  %dp = getelementptr %RX, ptr %node, i32 0, i32 6
  %next = load ptr, ptr %ap
  %absent = load ptr, ptr %bp
  %expression = load ptr, ptr %dp
  %lp = getelementptr %RC, ptr %ctx, i32 0, i32 14
  %oldlimit = load i64, ptr %lp
  %np = getelementptr %RC, ptr %ctx, i32 0, i32 3
  %n = load i64, ptr %np
  %clear = icmp eq i32 %mode, 3
  br i1 %clear, label %clearlimit, label %begin
clearlimit:
  store i64 %n, ptr %lp
  %clearresult = call i64 @rx_run(ptr %next, ptr %ctx, i64 %pos, ptr %captures, i64 %depth)
  store i64 %oldlimit, ptr %lp
  ret i64 %clearresult
begin:
  %bytes = call i64 @rr_capture_bytes(ptr %ctx)
  %before = call ptr @j_alloc(i64 %bytes)
  %working = call ptr @j_alloc(i64 %bytes)
  %bestcaps = call ptr @j_alloc(i64 %bytes)
  call void @rr_copy(ptr %before, ptr %captures, i64 %bytes)
  %kp = getelementptr %RC, ptr %ctx, i32 0, i32 8
  %oldkeep = load i64, ptr %kp
  %fp = getelementptr %RC, ptr %ctx, i32 0, i32 4
  %flags = load i32, ptr %fp
  %lbit = and i32 %flags, 64
  %longest = icmp ne i32 %lbit, 0
  %scanctx = alloca %RC
  call void @rr_copy(ptr %scanctx, ptr %ctx, i64 112)
  %sfp = getelementptr %RC, ptr %scanctx, i32 0, i32 4
  %scanflags = and i32 %flags, -97
  store i32 %scanflags, ptr %sfp
  %svp = getelementptr %RC, ptr %scanctx, i32 0, i32 10
  store ptr null, ptr %svp
  br label %scan
scan:
  %i = phi i64 [%pos, %begin], [%inext, %scanadvance]
  %more = icmp ule i64 %i, %oldlimit
  br i1 %more, label %scanmatch, label %rangeend
scanmatch:
  call void @rr_copy(ptr %working, ptr %before, i64 %bytes)
  %scanresult = call i64 @rx_run(ptr %absent, ptr %scanctx, i64 %i, ptr %working, i64 %depth)
  %found = icmp sge i64 %scanresult, 0
  br i1 %found, label %rangefound, label %scanadvance
scanadvance:
  %inext = add i64 %i, 1
  br label %scan
rangeend:
  br label %range
rangefound:
  br label %range
range:
  %limit = phi i64 [%oldlimit, %rangeend], [%i, %rangefound]
  switch i32 %mode, label %repeater [i32 1, label %scoped i32 2, label %stopper]
stopper:
  store i64 %limit, ptr %lp
  %stopresult = call i64 @rx_run(ptr %next, ptr %ctx, i64 %pos, ptr %captures, i64 %depth)
  store i64 %oldlimit, ptr %lp
  ret i64 %stopresult
scoped:
  %stackp = getelementptr %RC, ptr %ctx, i32 0, i32 13
  %stack = load ptr, ptr %stackp
  %frame = alloca {ptr, ptr, i64}
  store ptr %next, ptr %frame
  %prevp = getelementptr ptr, ptr %frame, i64 1
  %framelimit = getelementptr i64, ptr %frame, i64 2
  store ptr %stack, ptr %prevp
  store i64 %oldlimit, ptr %framelimit
  store ptr %frame, ptr %stackp
  store i64 %limit, ptr %lp
  %scopedresult = call i64 @rx_run(ptr %expression, ptr %ctx, i64 %pos, ptr %captures, i64 %depth)
  store ptr %stack, ptr %stackp
  store i64 %oldlimit, ptr %lp
  ret i64 %scopedresult
repeater:
  %bestendp = alloca i64
  %bestkeepp = alloca i64
  store i64 -1, ptr %bestendp
  store i64 %oldkeep, ptr %bestkeepp
  br label %try
try:
  %candidate = phi i64 [%limit, %repeater], [%previous, %retry]
  call void @rr_copy(ptr %captures, ptr %before, i64 %bytes)
  store i64 %oldkeep, ptr %kp
  %result = call i64 @rx_run(ptr %next, ptr %ctx, i64 %candidate, ptr %captures, i64 %depth)
  %matched = icmp sge i64 %result, 0
  br i1 %matched, label %accepted, label %nextcandidate
accepted:
  br i1 %longest, label %compare, label %done
compare:
  %best = load i64, ptr %bestendp
  %better = icmp sgt i64 %result, %best
  br i1 %better, label %save, label %nextcandidate
save:
  store i64 %result, ptr %bestendp
  %keep = load i64, ptr %kp
  store i64 %keep, ptr %bestkeepp
  call void @rr_copy(ptr %bestcaps, ptr %captures, i64 %bytes)
  br label %nextcandidate
nextcandidate:
  %hasprevious = icmp ugt i64 %candidate, %pos
  br i1 %hasprevious, label %retry, label %finish
retry:
  %previous = sub i64 %candidate, 1
  br label %try
finish:
  %final = load i64, ptr %bestendp
  %finalkeep = load i64, ptr %bestkeepp
  %hasbest = icmp sge i64 %final, 0
  %finalcaps = select i1 %hasbest, ptr %bestcaps, ptr %before
  call void @rr_copy(ptr %captures, ptr %finalcaps, i64 %bytes)
  store i64 %finalkeep, ptr %kp
  ret i64 %final
done:
  ret i64 %result
}

define i64 @rx_conditional(ptr %node, ptr %ctx, i64 %pos, ptr %captures, i64 %depth) {
entry:
  %ap = getelementptr %RX, ptr %node, i32 0, i32 4
  %bp = getelementptr %RX, ptr %node, i32 0, i32 5
  %dp = getelementptr %RX, ptr %node, i32 0, i32 6
  %yes = load ptr, ptr %ap
  %no = load ptr, ptr %bp
  %condition = load ptr, ptr %dp
  %bytes = call i64 @rr_capture_bytes(ptr %ctx)
  %before = call ptr @j_alloc(i64 %bytes)
  call void @rr_copy(ptr %before, ptr %captures, i64 %bytes)
  %conditionctx = alloca %RC
  call void @rr_copy(ptr %conditionctx, ptr %ctx, i64 112)
  %fp = getelementptr %RC, ptr %conditionctx, i32 0, i32 4
  %flags = load i32, ptr %fp
  %localflags = and i32 %flags, -97
  store i32 %localflags, ptr %fp
  %vp = getelementptr %RC, ptr %conditionctx, i32 0, i32 10
  store ptr null, ptr %vp
  %end = call i64 @rx_run(ptr %condition, ptr %conditionctx, i64 %pos, ptr %captures, i64 %depth)
  %matched = icmp sge i64 %end, 0
  br i1 %matched, label %positive, label %negative
positive:
  %yesresult = call i64 @rx_run(ptr %yes, ptr %ctx, i64 %end, ptr %captures, i64 %depth)
  br label %finish
negative:
  call void @rr_copy(ptr %captures, ptr %before, i64 %bytes)
  %noresult = call i64 @rx_run(ptr %no, ptr %ctx, i64 %pos, ptr %captures, i64 %depth)
  br label %finish
finish:
  %result = phi i64 [%yesresult, %positive], [%noresult, %negative]
  %ok = icmp sge i64 %result, 0
  br i1 %ok, label %done, label %restore
restore:
  call void @rr_copy(ptr %captures, ptr %before, i64 %bytes)
  br label %done
done:
  ret i64 %result
}
