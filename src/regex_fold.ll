%RX = type { i32, i32, i32, i32, ptr, ptr, ptr }
%RC = type { ptr, ptr, ptr, i64, i32, i32, ptr, i64, i64, i64, ptr, ptr, ptr, ptr, i64 }

declare i32 @rx_unicode_expand(i32, ptr)
declare i64 @rx_run(ptr, ptr, i64, ptr, i64)

define i64 @rx_literal_fold(ptr %node, ptr %ctx, i64 %pos, ptr %captures, i64 %depth) {
entry:
  %left = alloca [3 x i32]
  %right = alloca [3 x i32]
  %cp = getelementptr %RX, ptr %node, i32 0, i32 1
  %code = load i32, ptr %cp
  %ln = call i32 @rx_unicode_expand(i32 %code, ptr %left)
  %cpsp = getelementptr %RC, ptr %ctx, i32 0, i32 1
  %cps = load ptr, ptr %cpsp
  %np = getelementptr %RC, ptr %ctx, i32 0, i32 14
  %n = load i64, ptr %np
  %inputp = getelementptr i32, ptr %cps, i64 %pos
  %input = load i32, ptr %inputp
  %rn = call i32 @rx_unicode_expand(i32 %input, ptr %right)
  br label %loop
loop:
  %current = phi ptr [%node, %entry], [%nextnode, %patternread], [%current, %inputread]
  %position = phi i64 [%pos, %entry], [%position, %patternread], [%nextpos, %inputread]
  %li = phi i32 [0, %entry], [0, %patternread], [%linext, %inputread]
  %ri = phi i32 [0, %entry], [%rinext, %patternread], [0, %inputread]
  %lwidth = phi i32 [%ln, %entry], [%newln, %patternread], [%lwidth, %inputread]
  %rwidth = phi i32 [%rn, %entry], [%rwidth, %patternread], [%newrn, %inputread]
  br label %units
units:
  %lindex = phi i32 [%li, %loop], [%linext, %unitnext]
  %rindex = phi i32 [%ri, %loop], [%rinext, %unitnext]
  %lp = getelementptr i32, ptr %left, i32 %lindex
  %rp = getelementptr i32, ptr %right, i32 %rindex
  %lc = load i32, ptr %lp
  %rc = load i32, ptr %rp
  %same = icmp eq i32 %lc, %rc
  br i1 %same, label %advance, label %fail
advance:
  %linext = add i32 %lindex, 1
  %rinext = add i32 %rindex, 1
  %lend = icmp eq i32 %linext, %lwidth
  %rend = icmp eq i32 %rinext, %rwidth
  %both = and i1 %lend, %rend
  br i1 %both, label %continue, label %oneend
oneend:
  br i1 %lend, label %patternnext, label %inputcheck
inputcheck:
  br i1 %rend, label %inputnext, label %unitnext
unitnext:
  br label %units
patternnext:
  %nextp = getelementptr %RX, ptr %current, i32 0, i32 4
  %nextnode = load ptr, ptr %nextp
  %hasnode = icmp ne ptr %nextnode, null
  br i1 %hasnode, label %patterncheck, label %fail
patterncheck:
  %op = load i32, ptr %nextnode
  %literal = icmp eq i32 %op, 1
  br i1 %literal, label %patternread, label %fail
patternread:
  %valuep = getelementptr %RX, ptr %nextnode, i32 0, i32 1
  %value = load i32, ptr %valuep
  %newln = call i32 @rx_unicode_expand(i32 %value, ptr %left)
  br label %loop
inputnext:
  %nextpos = add i64 %position, 1
  %available = icmp ult i64 %nextpos, %n
  br i1 %available, label %inputread, label %fail
inputread:
  %nextinputp = getelementptr i32, ptr %cps, i64 %nextpos
  %nextinput = load i32, ptr %nextinputp
  %newrn = call i32 @rx_unicode_expand(i32 %nextinput, ptr %right)
  br label %loop
continue:
  %tailp = getelementptr %RX, ptr %current, i32 0, i32 4
  %tail = load ptr, ptr %tailp
  %end = add i64 %position, 1
  %result = call i64 @rx_run(ptr %tail, ptr %ctx, i64 %end, ptr %captures, i64 %depth)
  ret i64 %result
fail:
  ret i64 -1
}

define i64 @rx_backref_fold(ptr %ctx, i64 %start, i64 %end, i64 %pos) {
entry:
  %left = alloca [3 x i32]
  %right = alloca [3 x i32]
  %cpsp = getelementptr %RC, ptr %ctx, i32 0, i32 1
  %cps = load ptr, ptr %cpsp
  %np = getelementptr %RC, ptr %ctx, i32 0, i32 14
  %n = load i64, ptr %np
  %empty = icmp eq i64 %start, %end
  br i1 %empty, label %emptydone, label %begin
emptydone:
  ret i64 %pos
begin:
  %available = icmp ult i64 %pos, %n
  br i1 %available, label %first, label %fail
first:
  %lcp = getelementptr i32, ptr %cps, i64 %start
  %rcp = getelementptr i32, ptr %cps, i64 %pos
  %lcode = load i32, ptr %lcp
  %rcode = load i32, ptr %rcp
  %ln = call i32 @rx_unicode_expand(i32 %lcode, ptr %left)
  %rn = call i32 @rx_unicode_expand(i32 %rcode, ptr %right)
  br label %loop
loop:
  %lpos = phi i64 [%start, %first], [%nextleftpos, %readleft], [%lpos, %readright], [%nextleftpos, %readboth]
  %rpos = phi i64 [%pos, %first], [%rpos, %readleft], [%nextrightpos, %readright], [%nextrightpos, %readboth]
  %li = phi i32 [0, %first], [0, %readleft], [%linext, %readright], [0, %readboth]
  %ri = phi i32 [0, %first], [%rinext, %readleft], [0, %readright], [0, %readboth]
  %lwidth = phi i32 [%ln, %first], [%newln, %readleft], [%lwidth, %readright], [%bothln, %readboth]
  %rwidth = phi i32 [%rn, %first], [%rwidth, %readleft], [%newrn, %readright], [%bothrn, %readboth]
  br label %units
units:
  %lindex = phi i32 [%li, %loop], [%linext, %unitnext]
  %rindex = phi i32 [%ri, %loop], [%rinext, %unitnext]
  %lp = getelementptr i32, ptr %left, i32 %lindex
  %rp = getelementptr i32, ptr %right, i32 %rindex
  %lc = load i32, ptr %lp
  %rc = load i32, ptr %rp
  %same = icmp eq i32 %lc, %rc
  br i1 %same, label %advance, label %fail
advance:
  %linext = add i32 %lindex, 1
  %rinext = add i32 %rindex, 1
  %lend = icmp eq i32 %linext, %lwidth
  %rend = icmp eq i32 %rinext, %rwidth
  %nextleftpos = add i64 %lpos, 1
  %nextrightpos = add i64 %rpos, 1
  %leftfinished = icmp eq i64 %nextleftpos, %end
  %allleft = and i1 %lend, %leftfinished
  br i1 %allleft, label %finish, label %bothcheck
finish:
  br i1 %rend, label %done, label %fail
bothcheck:
  %both = and i1 %lend, %rend
  br i1 %both, label %bothbounds, label %leftcheck
bothbounds:
  %bothmore = icmp ult i64 %nextrightpos, %n
  br i1 %bothmore, label %readboth, label %fail
readboth:
  %bothlp = getelementptr i32, ptr %cps, i64 %nextleftpos
  %bothrp = getelementptr i32, ptr %cps, i64 %nextrightpos
  %bothlc = load i32, ptr %bothlp
  %bothrc = load i32, ptr %bothrp
  %bothln = call i32 @rx_unicode_expand(i32 %bothlc, ptr %left)
  %bothrn = call i32 @rx_unicode_expand(i32 %bothrc, ptr %right)
  br label %loop
leftcheck:
  br i1 %lend, label %readleft, label %rightcheck
readleft:
  %nextlp = getelementptr i32, ptr %cps, i64 %nextleftpos
  %nextlc = load i32, ptr %nextlp
  %newln = call i32 @rx_unicode_expand(i32 %nextlc, ptr %left)
  br label %loop
rightcheck:
  br i1 %rend, label %rightbounds, label %unitnext
rightbounds:
  %more = icmp ult i64 %nextrightpos, %n
  br i1 %more, label %readright, label %fail
readright:
  %nextrp = getelementptr i32, ptr %cps, i64 %nextrightpos
  %nextrc = load i32, ptr %nextrp
  %newrn = call i32 @rx_unicode_expand(i32 %nextrc, ptr %right)
  br label %loop
unitnext:
  br label %units
done:
  ret i64 %nextrightpos
fail:
  ret i64 -1
}
