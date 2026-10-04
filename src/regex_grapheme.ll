@rx_grapheme_count = external constant i32
@rx_grapheme_ranges = external constant [0 x {i32, i32, i32}]

declare i1 @rx_unicode_has(i32, i32)

define internal i32 @rg_type(i32 %codepoint) {
entry:
  %count = load i32, ptr @rx_grapheme_count
  %n = zext i32 %count to i64
  br label %loop
loop:
  %lo = phi i64 [0, %entry], [%next, %right], [%lo, %left]
  %hi = phi i64 [%n, %entry], [%hi, %right], [%mid, %left]
  %more = icmp ult i64 %lo, %hi
  br i1 %more, label %probe, label %other
probe:
  %sum = add i64 %lo, %hi
  %mid = lshr i64 %sum, 1
  %row = getelementptr {i32, i32, i32}, ptr @rx_grapheme_ranges, i64 %mid
  %first = load i32, ptr %row
  %ep = getelementptr i32, ptr %row, i64 1
  %last = load i32, ptr %ep
  %below = icmp ult i32 %codepoint, %first
  br i1 %below, label %left, label %endcheck
endcheck:
  %above = icmp ugt i32 %codepoint, %last
  br i1 %above, label %right, label %found
right:
  %next = add i64 %mid, 1
  br label %loop
left:
  br label %loop
found:
  %tp = getelementptr i32, ptr %row, i64 2
  %type = load i32, ptr %tp
  ret i32 %type
other:
  ret i32 0
}

define i1 @rx_grapheme_boundary(ptr %cps, i64 %n, i64 %pos) {
entry:
  %start = icmp eq i64 %pos, 0
  %end = icmp uge i64 %pos, %n
  %outside = or i1 %start, %end
  br i1 %outside, label %yes, label %read
read:
  %prev = sub i64 %pos, 1
  %ap = getelementptr i32, ptr %cps, i64 %prev
  %bp = getelementptr i32, ptr %cps, i64 %pos
  %a = load i32, ptr %ap
  %b = load i32, ptr %bp
  %at = call i32 @rg_type(i32 %a)
  %bt = call i32 @rg_type(i32 %b)
  %cr = icmp eq i32 %at, 1
  %lf = icmp eq i32 %bt, 2
  %crlf = and i1 %cr, %lf
  br i1 %crlf, label %no, label %control
control:
  %ac = sub i32 %at, 1
  %bc = sub i32 %bt, 1
  %acontrol = icmp ult i32 %ac, 3
  %bcontrol = icmp ult i32 %bc, 3
  %hascontrol = or i1 %acontrol, %bcontrol
  br i1 %hascontrol, label %yes, label %hangull
hangull:
  %al = icmp eq i32 %at, 5
  %bl = icmp eq i32 %bt, 5
  %bv = icmp eq i32 %bt, 6
  %blv = icmp eq i32 %bt, 8
  %blvt = icmp eq i32 %bt, 9
  %l0 = or i1 %bl, %bv
  %l1 = or i1 %blv, %blvt
  %l2 = or i1 %l0, %l1
  %lnobreak = and i1 %al, %l2
  br i1 %lnobreak, label %no, label %hangulv
hangulv:
  %av = icmp eq i32 %at, 6
  %alv = icmp eq i32 %at, 8
  %vstart = or i1 %av, %alv
  %btail = icmp eq i32 %bt, 7
  %vend = or i1 %bv, %btail
  %vnobreak = and i1 %vstart, %vend
  br i1 %vnobreak, label %no, label %hangult
hangult:
  %atail = icmp eq i32 %at, 7
  %alvt = icmp eq i32 %at, 9
  %tstart = or i1 %atail, %alvt
  %tnobreak = and i1 %tstart, %btail
  br i1 %tnobreak, label %no, label %extend
extend:
  %combining = icmp eq i32 %bt, 4
  %zwj = icmp eq i32 %bt, 13
  %spacingmark = icmp eq i32 %bt, 12
  %prepend = icmp eq i32 %at, 10
  %extend0 = or i1 %combining, %zwj
  %extend1 = or i1 %spacingmark, %prepend
  %extended = or i1 %extend0, %extend1
  br i1 %extended, label %no, label %emoji
emoji:
  %previouszwj = icmp eq i32 %at, 13
  %pictographic = call i1 @rx_unicode_has(i32 81, i32 %b)
  %possibleemoji = and i1 %previouszwj, %pictographic
  br i1 %possibleemoji, label %emojiloop, label %regional
emojiloop:
  %ei = phi i64 [%prev, %emoji], [%previous, %emojiextend]
  %hasprevious = icmp ugt i64 %ei, 0
  br i1 %hasprevious, label %emojiread, label %regional
emojiread:
  %previous = sub i64 %ei, 1
  %ep = getelementptr i32, ptr %cps, i64 %previous
  %ec = load i32, ptr %ep
  %et = call i32 @rg_type(i32 %ec)
  %eextend = icmp eq i32 %et, 4
  br i1 %eextend, label %emojiextend, label %emojicheck
emojiextend:
  br label %emojiloop
emojicheck:
  %epictographic = call i1 @rx_unicode_has(i32 81, i32 %ec)
  br i1 %epictographic, label %no, label %regional
regional:
  %ari = icmp eq i32 %at, 11
  %bri = icmp eq i32 %bt, 11
  %bothregional = and i1 %ari, %bri
  br i1 %bothregional, label %riloop, label %yes
riloop:
  %ri = phi i64 [%pos, %regional], [%riprev, %ricount]
  %odd = phi i1 [false, %regional], [%flipped, %ricount]
  %rimore = icmp ugt i64 %ri, 0
  br i1 %rimore, label %riread, label %ridone
riread:
  %riprev = sub i64 %ri, 1
  %rip = getelementptr i32, ptr %cps, i64 %riprev
  %ric = load i32, ptr %rip
  %rit = call i32 @rg_type(i32 %ric)
  %isregional = icmp eq i32 %rit, 11
  br i1 %isregional, label %ricount, label %ridone
ricount:
  %flipped = xor i1 %odd, true
  br label %riloop
ridone:
  %even = xor i1 %odd, true
  ret i1 %even
yes:
  ret i1 true
no:
  ret i1 false
}

define i64 @rx_grapheme_end(ptr %cps, i64 %n, i64 %pos) {
entry:
  %start = add i64 %pos, 1
  br label %loop
loop:
  %i = phi i64 [%start, %entry], [%next, %advance]
  %more = icmp ult i64 %i, %n
  br i1 %more, label %check, label %done
check:
  %boundary = call i1 @rx_grapheme_boundary(ptr %cps, i64 %n, i64 %i)
  br i1 %boundary, label %done, label %advance
advance:
  %next = add i64 %i, 1
  br label %loop
done:
  ret i64 %i
}
