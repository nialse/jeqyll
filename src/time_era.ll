%LE = type { i64, i64, i64, i64, i64, i64, i64, i64, ptr, ptr }

declare ptr @j_alloc(i64)
declare ptr @j_locale_raw(i64, ptr)
declare i64 @j_strlen(ptr)
declare i32 @j_utf8_next(ptr, i64, ptr)
declare i32 @rx_unicode_fold(i32)

define internal i64 @le_word(ptr %record, i64 %offset) {
entry:
  %p = getelementptr i8, ptr %record, i64 %offset
  %word = load i32, ptr %p, align 1
  %value = sext i32 %word to i64
  ret i64 %value
}

define internal ptr @le_string_end(ptr %begin, ptr %end, i64 %width) {
entry:
  br label %loop
loop:
  %p = phi ptr [%begin, %entry], [%next, %advance]
  %next = getelementptr i8, ptr %p, i64 %width
  %inside = icmp ule ptr %next, %end
  br i1 %inside, label %read, label %missing
read:
  %wide = icmp eq i64 %width, 4
  br i1 %wide, label %readwide, label %readbyte
readwide:
  %word = load i32, ptr %p, align 1
  %wordnul = icmp eq i32 %word, 0
  br i1 %wordnul, label %found, label %advance
readbyte:
  %byte = load i8, ptr %p
  %bytenul = icmp eq i8 %byte, 0
  br i1 %bytenul, label %found, label %advance
advance:
  br label %loop
found:
  ret ptr %next
missing:
  ret ptr null
}

define internal i1 @le_before(i64 %ay, i64 %am, i64 %ad, i64 %by, i64 %bm, i64 %bd) {
entry:
  %yearless = icmp slt i64 %ay, %by
  %yearsamen = icmp eq i64 %ay, %by
  %monthless = icmp slt i64 %am, %bm
  %monthsame = icmp eq i64 %am, %bm
  %dayless = icmp sle i64 %ad, %bd
  %sameday = and i1 %monthsame, %dayless
  %monthday = or i1 %monthless, %sameday
  %sameyear = and i1 %yearsamen, %monthday
  %result = or i1 %yearless, %sameyear
  ret i1 %result
}

define ptr @j_locale_era_at(i64 %index) {
entry:
  %sizep = alloca i64
  %countp = call ptr @j_locale_raw(i64 50, ptr %sizep)
  %countsize = load i64, ptr %sizep
  %hascount = icmp ne ptr %countp, null
  %countfits = icmp uge i64 %countsize, 4
  %countvalid = and i1 %hascount, %countfits
  br i1 %countvalid, label %count, label %missing
count:
  %encodedcount = load i32, ptr %countp, align 1
  %countwide = zext i32 %encodedcount to i64
  %inrange = icmp ult i64 %index, %countwide
  br i1 %inrange, label %data, label %missing
data:
  %base = call ptr @j_locale_raw(i64 51, ptr %sizep)
  %bytes = load i64, ptr %sizep
  %end = getelementptr i8, ptr %base, i64 %bytes
  %hasdata = icmp ne ptr %base, null
  br i1 %hasdata, label %loop, label %missing
loop:
  %i = phi i64 [0, %data], [%nextindex, %advance]
  %p = phi ptr [%base, %data], [%afterwideformat, %advance]
  %numericend = getelementptr i8, ptr %p, i64 32
  %numericfits = icmp ule ptr %numericend, %end
  br i1 %numericfits, label %names, label %missing
names:
  %aftername = call ptr @le_string_end(ptr %numericend, ptr %end, i64 1)
  %namevalid = icmp ne ptr %aftername, null
  br i1 %namevalid, label %format, label %missing
format:
  %afterformat = call ptr @le_string_end(ptr %aftername, ptr %end, i64 1)
  %formatvalid = icmp ne ptr %afterformat, null
  br i1 %formatvalid, label %align, label %missing
align:
  %pi = ptrtoint ptr %p to i64
  %fi = ptrtoint ptr %afterformat to i64
  %used = sub i64 %fi, %pi
  %pad = add i64 %used, 3
  %aligned = and i64 %pad, -4
  %widebegin = getelementptr i8, ptr %p, i64 %aligned
  %afterwidename = call ptr @le_string_end(ptr %widebegin, ptr %end, i64 4)
  %widenamevalid = icmp ne ptr %afterwidename, null
  br i1 %widenamevalid, label %wideformat, label %missing
wideformat:
  %afterwideformat = call ptr @le_string_end(ptr %afterwidename, ptr %end, i64 4)
  %wideformatvalid = icmp ne ptr %afterwideformat, null
  br i1 %wideformatvalid, label %select, label %missing
select:
  %wanted = icmp eq i64 %i, %index
  br i1 %wanted, label %decode, label %advance
advance:
  %nextindex = add i64 %i, 1
  br label %loop
decode:
  %direction = call i64 @le_word(ptr %p, i64 0)
  %forward = icmp eq i64 %direction, 43
  %backward = icmp eq i64 %direction, 45
  %directionvalid = or i1 %forward, %backward
  br i1 %directionvalid, label %record, label %missing
record:
  %offset = call i64 @le_word(ptr %p, i64 4)
  %sy0 = call i64 @le_word(ptr %p, i64 8)
  %sm = call i64 @le_word(ptr %p, i64 12)
  %sd = call i64 @le_word(ptr %p, i64 16)
  %ey0 = call i64 @le_word(ptr %p, i64 20)
  %em = call i64 @le_word(ptr %p, i64 24)
  %ed = call i64 @le_word(ptr %p, i64 28)
  %sy = add i64 %sy0, 1900
  %ey = add i64 %ey0, 1900
  %ascending = call i1 @le_before(i64 %sy, i64 %sm, i64 %sd, i64 %ey, i64 %em, i64 %ed)
  %positive = icmp eq i1 %ascending, %forward
  %absolute = select i1 %positive, i64 1, i64 -1
  %out = call ptr @j_alloc(i64 80)
  store i64 %offset, ptr %out
  %syp = getelementptr %LE, ptr %out, i32 0, i32 1
  %dp = getelementptr %LE, ptr %out, i32 0, i32 2
  %smp = getelementptr %LE, ptr %out, i32 0, i32 3
  %sdp = getelementptr %LE, ptr %out, i32 0, i32 4
  %eyp = getelementptr %LE, ptr %out, i32 0, i32 5
  %emp = getelementptr %LE, ptr %out, i32 0, i32 6
  %edp = getelementptr %LE, ptr %out, i32 0, i32 7
  %np = getelementptr %LE, ptr %out, i32 0, i32 8
  %fp = getelementptr %LE, ptr %out, i32 0, i32 9
  store i64 %sy, ptr %syp
  store i64 %absolute, ptr %dp
  store i64 %sm, ptr %smp
  store i64 %sd, ptr %sdp
  store i64 %ey, ptr %eyp
  store i64 %em, ptr %emp
  store i64 %ed, ptr %edp
  store ptr %numericend, ptr %np
  store ptr %aftername, ptr %fp
  ret ptr %out
missing:
  ret ptr null
}

define ptr @j_locale_era_for(i64 %year, i64 %month, i64 %day) {
entry:
  br label %loop
loop:
  %i = phi i64 [0, %entry], [%next, %advance]
  %record = call ptr @j_locale_era_at(i64 %i)
  %present = icmp ne ptr %record, null
  br i1 %present, label %compare, label %missing
compare:
  %syp = getelementptr %LE, ptr %record, i32 0, i32 1
  %smp = getelementptr %LE, ptr %record, i32 0, i32 3
  %sdp = getelementptr %LE, ptr %record, i32 0, i32 4
  %eyp = getelementptr %LE, ptr %record, i32 0, i32 5
  %emp = getelementptr %LE, ptr %record, i32 0, i32 6
  %edp = getelementptr %LE, ptr %record, i32 0, i32 7
  %sy = load i64, ptr %syp
  %sm = load i64, ptr %smp
  %sd = load i64, ptr %sdp
  %ey = load i64, ptr %eyp
  %em = load i64, ptr %emp
  %ed = load i64, ptr %edp
  %sa = call i1 @le_before(i64 %sy, i64 %sm, i64 %sd, i64 %year, i64 %month, i64 %day)
  %ae = call i1 @le_before(i64 %year, i64 %month, i64 %day, i64 %ey, i64 %em, i64 %ed)
  %ea = call i1 @le_before(i64 %ey, i64 %em, i64 %ed, i64 %year, i64 %month, i64 %day)
  %as = call i1 @le_before(i64 %year, i64 %month, i64 %day, i64 %sy, i64 %sm, i64 %sd)
  %forward = and i1 %sa, %ae
  %backward = and i1 %ea, %as
  %inside = or i1 %forward, %backward
  br i1 %inside, label %found, label %advance
advance:
  %next = add i64 %i, 1
  br label %loop
found:
  ret ptr %record
missing:
  ret ptr null
}

define i64 @j_locale_era_year(ptr %record, i64 %year, i1 %inverse) {
entry:
  %syp = getelementptr %LE, ptr %record, i32 0, i32 1
  %dp = getelementptr %LE, ptr %record, i32 0, i32 2
  %offset = load i64, ptr %record
  %sy = load i64, ptr %syp
  %direction = load i64, ptr %dp
  %from = select i1 %inverse, i64 %offset, i64 %sy
  %to = select i1 %inverse, i64 %sy, i64 %offset
  %delta = sub i64 %year, %from
  %relative = mul i64 %delta, %direction
  %result = add i64 %to, %relative
  ret i64 %result
}

define i1 @j_locale_era_year_valid(ptr %record, i64 %year) {
entry:
  %sy = getelementptr %LE, ptr %record, i32 0, i32 1
  %ey = getelementptr %LE, ptr %record, i32 0, i32 5
  %a = load i64, ptr %sy
  %b = load i64, ptr %ey
  %ge_a = icmp sge i64 %year, %a
  %le_b = icmp sle i64 %year, %b
  %ge_b = icmp sge i64 %year, %b
  %le_a = icmp sle i64 %year, %a
  %forward = and i1 %ge_a, %le_b
  %backward = and i1 %ge_b, %le_a
  %valid = or i1 %forward, %backward
  ret i1 %valid
}

define ptr @j_locale_era_text(ptr %record, i1 %format) {
entry:
  %index = select i1 %format, i64 9, i64 8
  %p = getelementptr i64, ptr %record, i64 %index
  %value = load ptr, ptr %p
  ret ptr %value
}

define i1 @j_locale_match_name(ptr %name, ptr %data, i64 %length, ptr %position) {
entry:
  %inputpos = alloca i64
  %namepos = alloca i64
  %start = load i64, ptr %position
  store i64 %start, ptr %inputpos
  store i64 0, ptr %namepos
  %namelen = call i64 @j_strlen(ptr %name)
  %nonempty = icmp ne i64 %namelen, 0
  br i1 %nonempty, label %loop, label %missing
loop:
  %a = load i64, ptr %inputpos
  %b = load i64, ptr %namepos
  %complete = icmp eq i64 %b, %namelen
  br i1 %complete, label %found, label %check
check:
  %left = icmp ult i64 %a, %length
  br i1 %left, label %characters, label %missing
characters:
  %ac = call i32 @j_utf8_next(ptr %data, i64 %length, ptr %inputpos)
  %bc = call i32 @j_utf8_next(ptr %name, i64 %namelen, ptr %namepos)
  %af = call i32 @rx_unicode_fold(i32 %ac)
  %bf = call i32 @rx_unicode_fold(i32 %bc)
  %same = icmp eq i32 %af, %bf
  br i1 %same, label %loop, label %missing
found:
  store i64 %a, ptr %position
  ret i1 true
missing:
  ret i1 false
}
