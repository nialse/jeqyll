%RC = type { ptr, ptr, ptr, i64, i32, i32, ptr, i64, i64, i64, ptr, ptr, ptr, ptr, i64 }
%RX = type { i32, i32, i32, i32, ptr, ptr, ptr }
%RB = type { ptr, ptr, i64, %RC }
%RG = type { ptr, i64, ptr }

declare ptr @j_alloc(i64)
declare void @j_copy(ptr, ptr, i64)
declare i32 @rx_unicode_expand(i32, ptr)

define i64 @rx_call_level(ptr %ctx) {
entry:
  %stackp = getelementptr %RC, ptr %ctx, i32 0, i32 13
  %frame = load ptr, ptr %stackp
  %empty = icmp eq ptr %frame, null
  br i1 %empty, label %zero, label %read
zero:
  ret i64 0
read:
  %levelp = getelementptr i64, ptr %frame, i64 4
  %level = load i64, ptr %levelp
  ret i64 %level
}

define i64 @rx_max_width(ptr %ast, i64 %cap, i32 %flags) {
entry:
  %empty = icmp eq ptr %ast, null
  br i1 %empty, label %zero, label %read
read:
  %op = load i32, ptr %ast
  %ap = getelementptr %RX, ptr %ast, i32 0, i32 4
  %bp = getelementptr %RX, ptr %ast, i32 0, i32 5
  %a = load ptr, ptr %ap
  %b = load ptr, ptr %bp
  switch i32 %op, label %unknown [
    i32 0, label %zero i32 1, label %literal i32 2, label %one i32 3, label %one
    i32 4, label %concat i32 5, label %alternate i32 6, label %repeat i32 7, label %wrapped
    i32 8, label %zero i32 9, label %zero i32 10, label %zero i32 11, label %zero
    i32 12, label %zero i32 13, label %one i32 15, label %zero i32 16, label %zero
    i32 17, label %wrapped i32 18, label %options i32 19, label %one i32 20, label %newline
    i32 21, label %zero i32 22, label %zero i32 24, label %zero i32 26, label %alternate
  ]
zero:
  ret i64 0
one:
  %hasone = icmp ugt i64 %cap, 0
  %unit = zext i1 %hasone to i64
  ret i64 %unit
literal:
  %foldbit = and i32 %flags, 1
  %fold = icmp ne i32 %foldbit, 0
  %valuep = getelementptr %RX, ptr %ast, i32 0, i32 1
  %value = load i32, ptr %valuep
  %folded = alloca [3 x i32]
  %foldwidth = call i32 @rx_unicode_expand(i32 %value, ptr %folded)
  %foldwide = zext i32 %foldwidth to i64
  %literalmax = select i1 %fold, i64 %foldwide, i64 1
  %shortliteral = icmp ult i64 %cap, %literalmax
  %literalwidth = select i1 %shortliteral, i64 %cap, i64 %literalmax
  ret i64 %literalwidth
newline:
  %shortnewline = icmp ult i64 %cap, 2
  %newlinewidth = select i1 %shortnewline, i64 %cap, i64 2
  ret i64 %newlinewidth
wrapped:
  %width = call i64 @rx_max_width(ptr %a, i64 %cap, i32 %flags)
  ret i64 %width
options:
  %flagp = getelementptr %RX, ptr %ast, i32 0, i32 1
  %localflags = load i32, ptr %flagp
  %localwidth = call i64 @rx_max_width(ptr %a, i64 %cap, i32 %localflags)
  ret i64 %localwidth
concat:
  %left = call i64 @rx_max_width(ptr %a, i64 %cap, i32 %flags)
  %right = call i64 @rx_max_width(ptr %b, i64 %cap, i32 %flags)
  %room = sub i64 %cap, %right
  %overflow = icmp ugt i64 %left, %room
  %sum = add i64 %left, %right
  %combined = select i1 %overflow, i64 %cap, i64 %sum
  ret i64 %combined
alternate:
  %first = call i64 @rx_max_width(ptr %a, i64 %cap, i32 %flags)
  %second = call i64 @rx_max_width(ptr %b, i64 %cap, i32 %flags)
  %larger = icmp ugt i64 %first, %second
  %maximum = select i1 %larger, i64 %first, i64 %second
  ret i64 %maximum
repeat:
  %hip = getelementptr %RX, ptr %ast, i32 0, i32 3
  %hi = load i32, ptr %hip
  %unbounded = icmp slt i32 %hi, 0
  br i1 %unbounded, label %unknown, label %bounded
bounded:
  %none = icmp eq i32 %hi, 0
  br i1 %none, label %zero, label %product
product:
  %count = zext i32 %hi to i64
  %body = call i64 @rx_max_width(ptr %a, i64 %cap, i32 %flags)
  %factorlimit = udiv i64 %cap, %count
  %large = icmp ugt i64 %body, %factorlimit
  %multiplied = mul i64 %body, %count
  %repeated = select i1 %large, i64 %cap, i64 %multiplied
  ret i64 %repeated
unknown:
  ret i64 %cap
}

define i64 @rx_capture_bytes(ptr %ctx) {
  %countp = getelementptr %RC, ptr %ctx, i32 0, i32 5
  %count = load i32, ptr %countp
  %wide = zext i32 %count to i64
  %bytes = mul i64 %wide, 16
  ret i64 %bytes
}

define ptr @rx_choice(ptr %previous, ptr %node, i64 %pos, ptr %ctx, ptr %captures) {
  %bytes = call i64 @rx_capture_bytes(ptr %ctx)
  %size = add i64 %bytes, 136
  %frame = call ptr @j_alloc(i64 %size)
  store ptr %previous, ptr %frame
  %nodep = getelementptr %RB, ptr %frame, i32 0, i32 1
  %posp = getelementptr %RB, ptr %frame, i32 0, i32 2
  %savedctx = getelementptr %RB, ptr %frame, i32 0, i32 3
  %savedcaps = getelementptr i8, ptr %frame, i64 136
  store ptr %node, ptr %nodep
  store i64 %pos, ptr %posp
  call void @j_copy(ptr %savedctx, ptr %ctx, i64 112)
  call void @j_copy(ptr %savedcaps, ptr %captures, i64 %bytes)
  ret ptr %frame
}

define void @rx_restore_choice(ptr %frame, ptr %ctx, ptr %captures) {
  %savedctx = getelementptr %RB, ptr %frame, i32 0, i32 3
  %savedcaps = getelementptr i8, ptr %frame, i64 136
  call void @j_copy(ptr %ctx, ptr %savedctx, i64 112)
  %bytes = call i64 @rx_capture_bytes(ptr %ctx)
  call void @j_copy(ptr %captures, ptr %savedcaps, i64 %bytes)
  ret void
}

define i1 @rx_guard(ptr %node, ptr %ctx, i64 %pos) {
entry:
  %visitedp = getelementptr %RC, ptr %ctx, i32 0, i32 10
  %visited = load ptr, ptr %visitedp
  br label %loop
loop:
  %row = phi ptr [%visited, %entry], [%previous, %advance]
  %empty = icmp eq ptr %row, null
  br i1 %empty, label %add, label %read
read:
  %active = load ptr, ptr %row
  %posp = getelementptr %RG, ptr %row, i32 0, i32 1
  %position = load i64, ptr %posp
  %earlier = icmp ult i64 %position, %pos
  br i1 %earlier, label %add, label %check
check:
  %samenode = icmp eq ptr %active, %node
  %samepos = icmp eq i64 %position, %pos
  %cycle = and i1 %samenode, %samepos
  br i1 %cycle, label %fail, label %advance
advance:
  %prevp = getelementptr %RG, ptr %row, i32 0, i32 2
  %previous = load ptr, ptr %prevp
  br label %loop
add:
  %next = call ptr @j_alloc(i64 24)
  %nextposp = getelementptr %RG, ptr %next, i32 0, i32 1
  %nextprevp = getelementptr %RG, ptr %next, i32 0, i32 2
  store ptr %node, ptr %next
  store i64 %pos, ptr %nextposp
  store ptr %visited, ptr %nextprevp
  store ptr %next, ptr %visitedp
  ret i1 true
fail:
  ret i1 false
}
