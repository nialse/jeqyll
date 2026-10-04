%TZP = type { ptr, i64, i64, i1 }
%TZR = type { i64, i64, i64, i64, i64, i64 }
%TZV = type { i64, ptr }

declare ptr @j_alloc(i64)
declare ptr @j_str(ptr, i64)
declare ptr @b_data(ptr)
declare i64 @b_len(ptr)
declare i64 @t_days(i64, i64, i64)
declare ptr @t_gmtime(double)
declare i64 @t_field(ptr, i64)
declare ptr @j_posix_default_rules()

define internal i8 @tz_peek(ptr %parser) {
entry:
  %lenp = getelementptr %TZP, ptr %parser, i32 0, i32 1
  %posp = getelementptr %TZP, ptr %parser, i32 0, i32 2
  %len = load i64, ptr %lenp
  %pos = load i64, ptr %posp
  %more = icmp ult i64 %pos, %len
  br i1 %more, label %read, label %end
read:
  %data = load ptr, ptr %parser
  %p = getelementptr i8, ptr %data, i64 %pos
  %char = load i8, ptr %p
  ret i8 %char
end:
  ret i8 0
}

define internal void @tz_advance(ptr %parser) {
entry:
  %posp = getelementptr %TZP, ptr %parser, i32 0, i32 2
  %pos = load i64, ptr %posp
  %next = add i64 %pos, 1
  store i64 %next, ptr %posp
  ret void
}

define internal void @tz_error(ptr %parser) {
entry:
  %p = getelementptr %TZP, ptr %parser, i32 0, i32 3
  store i1 true, ptr %p
  ret void
}

define internal void @tz_expect(ptr %parser, i8 %expected) {
entry:
  %char = call i8 @tz_peek(ptr %parser)
  %same = icmp eq i8 %char, %expected
  br i1 %same, label %advance, label %bad
advance:
  call void @tz_advance(ptr %parser)
  ret void
bad:
  call void @tz_error(ptr %parser)
  ret void
}

define internal i64 @tz_uint(ptr %parser, i64 %maximum) {
entry:
  br label %loop
loop:
  %value = phi i64 [0, %entry], [%nextvalue, %digit]
  %count = phi i64 [0, %entry], [%nextcount, %digit]
  %char = call i8 @tz_peek(ptr %parser)
  %d = sub i8 %char, 48
  %numeric = icmp ule i8 %d, 9
  br i1 %numeric, label %digit, label %done
digit:
  %wide = zext i8 %d to i64
  %ten = mul i64 %value, 10
  %nextvalue0 = add i64 %ten, %wide
  %overflow = icmp ugt i64 %nextvalue0, %maximum
  %nextvalue = select i1 %overflow, i64 1000000, i64 %nextvalue0
  %nextcount = add i64 %count, 1
  call void @tz_advance(ptr %parser)
  br label %loop
done:
  %empty = icmp eq i64 %count, 0
  %large = icmp ugt i64 %value, %maximum
  %invalid = or i1 %empty, %large
  br i1 %invalid, label %bad, label %return
bad:
  call void @tz_error(ptr %parser)
  br label %return
return:
  ret i64 %value
}

define internal ptr @tz_name(ptr %parser) {
entry:
  %posp = getelementptr %TZP, ptr %parser, i32 0, i32 2
  %first = call i8 @tz_peek(ptr %parser)
  %bracketed = icmp eq i8 %first, 60
  br i1 %bracketed, label %bracket, label %start
bracket:
  call void @tz_advance(ptr %parser)
  br label %start
start:
  %begin = load i64, ptr %posp
  br label %loop
loop:
  %c = call i8 @tz_peek(ptr %parser)
  %lower = or i8 %c, 32
  %letteroffset = sub i8 %lower, 97
  %letter = icmp ule i8 %letteroffset, 25
  %digitoffset = sub i8 %c, 48
  %digit = icmp ule i8 %digitoffset, 9
  %plus = icmp eq i8 %c, 43
  %minus = icmp eq i8 %c, 45
  %sign = or i1 %plus, %minus
  %other = or i1 %digit, %sign
  %quotedother = and i1 %bracketed, %other
  %valid = or i1 %letter, %quotedother
  br i1 %valid, label %next, label %done
next:
  call void @tz_advance(ptr %parser)
  br label %loop
done:
  %end = load i64, ptr %posp
  %length = sub i64 %end, %begin
  %short = icmp ult i64 %length, 3
  br i1 %short, label %bad, label %closecheck
bad:
  call void @tz_error(ptr %parser)
  br label %closecheck
closecheck:
  br i1 %bracketed, label %close, label %finish
close:
  call void @tz_expect(ptr %parser, i8 62)
  br label %finish
finish:
  %data = load ptr, ptr %parser
  %nameptr = getelementptr i8, ptr %data, i64 %begin
  %name = call ptr @j_str(ptr %nameptr, i64 %length)
  ret ptr %name
}

define internal i64 @tz_clock(ptr %parser, i64 %maximum) {
entry:
  %char = call i8 @tz_peek(ptr %parser)
  %negative = icmp eq i8 %char, 45
  %positive = icmp eq i8 %char, 43
  %signed = or i1 %negative, %positive
  br i1 %signed, label %sign, label %hour
sign:
  call void @tz_advance(ptr %parser)
  br label %hour
hour:
  %h = call i64 @tz_uint(ptr %parser, i64 %maximum)
  %hs = mul i64 %h, 3600
  %next = call i8 @tz_peek(ptr %parser)
  %hasminutes = icmp eq i8 %next, 58
  br i1 %hasminutes, label %minute, label %finish
minute:
  call void @tz_advance(ptr %parser)
  %m = call i64 @tz_uint(ptr %parser, i64 59)
  %ms = mul i64 %m, 60
  %hm = add i64 %hs, %ms
  %afterminute = call i8 @tz_peek(ptr %parser)
  %hasseconds = icmp eq i8 %afterminute, 58
  br i1 %hasseconds, label %second, label %finish
second:
  call void @tz_advance(ptr %parser)
  %s = call i64 @tz_uint(ptr %parser, i64 59)
  %hms = add i64 %hm, %s
  br label %finish
finish:
  %magnitude = phi i64 [%hs, %hour], [%hm, %minute], [%hms, %second]
  %negated = sub i64 0, %magnitude
  %result = select i1 %negative, i64 %negated, i64 %magnitude
  ret i64 %result
}

define internal ptr @tz_rule(ptr %parser) {
entry:
  %rule = call ptr @j_alloc(i64 48)
  %ap = getelementptr %TZR, ptr %rule, i32 0, i32 1
  %bp = getelementptr %TZR, ptr %rule, i32 0, i32 2
  %cp = getelementptr %TZR, ptr %rule, i32 0, i32 3
  %timep = getelementptr %TZR, ptr %rule, i32 0, i32 4
  %basisp = getelementptr %TZR, ptr %rule, i32 0, i32 5
  store i64 7200, ptr %timep
  %char = call i8 @tz_peek(ptr %parser)
  switch i8 %char, label %ordinal [i8 74, label %julian i8 77, label %month]
ordinal:
  %day = call i64 @tz_uint(ptr %parser, i64 365)
  store i64 %day, ptr %ap
  br label %timecheck
julian:
  call void @tz_advance(ptr %parser)
  %jday = call i64 @tz_uint(ptr %parser, i64 365)
  %jzero = icmp eq i64 %jday, 0
  br i1 %jzero, label %bad, label %jstore
jstore:
  store i64 1, ptr %rule
  store i64 %jday, ptr %ap
  br label %timecheck
month:
  call void @tz_advance(ptr %parser)
  %m = call i64 @tz_uint(ptr %parser, i64 12)
  call void @tz_expect(ptr %parser, i8 46)
  %week = call i64 @tz_uint(ptr %parser, i64 5)
  call void @tz_expect(ptr %parser, i8 46)
  %weekday = call i64 @tz_uint(ptr %parser, i64 6)
  %mzero = icmp eq i64 %m, 0
  %wzero = icmp eq i64 %week, 0
  %invalid = or i1 %mzero, %wzero
  br i1 %invalid, label %bad, label %mstore
mstore:
  store i64 2, ptr %rule
  store i64 %m, ptr %ap
  store i64 %week, ptr %bp
  store i64 %weekday, ptr %cp
  br label %timecheck
bad:
  call void @tz_error(ptr %parser)
  br label %timecheck
timecheck:
  %next = call i8 @tz_peek(ptr %parser)
  %hastime = icmp eq i8 %next, 47
  br i1 %hastime, label %time, label %done
time:
  call void @tz_advance(ptr %parser)
  %seconds = call i64 @tz_clock(ptr %parser, i64 167)
  store i64 %seconds, ptr %timep
  %suffix = call i8 @tz_peek(ptr %parser)
  switch i8 %suffix, label %done [i8 119, label %wall i8 115, label %standard i8 117, label %universal i8 103, label %universal i8 122, label %universal]
wall:
  br label %suffixdone
standard:
  store i64 1, ptr %basisp
  br label %suffixdone
universal:
  store i64 2, ptr %basisp
  br label %suffixdone
suffixdone:
  call void @tz_advance(ptr %parser)
  br label %done
done:
  ret ptr %rule
}

define internal i64 @tz_transition(ptr %rule, i64 %year, i64 %beforeoffset, i64 %standardoffset) {
entry:
  %kind = load i64, ptr %rule
  %ap = getelementptr %TZR, ptr %rule, i32 0, i32 1
  %a = load i64, ptr %ap
  %jan1 = call i64 @t_days(i64 %year, i64 1, i64 1)
  switch i64 %kind, label %ordinal [i64 1, label %julian i64 2, label %month]
ordinal:
  %nday = add i64 %jan1, %a
  br label %time
julian:
  %r4 = srem i64 %year, 4
  %r100 = srem i64 %year, 100
  %r400 = srem i64 %year, 400
  %by4 = icmp eq i64 %r4, 0
  %not100 = icmp ne i64 %r100, 0
  %by400 = icmp eq i64 %r400, 0
  %century = or i1 %not100, %by400
  %leap = and i1 %by4, %century
  %aftermarch = icmp uge i64 %a, 60
  %addday = and i1 %leap, %aftermarch
  %leapday = zext i1 %addday to i64
  %joffset0 = add i64 %a, %leapday
  %joffset = sub i64 %joffset0, 1
  %jday = add i64 %jan1, %joffset
  br label %time
month:
  %bp = getelementptr %TZR, ptr %rule, i32 0, i32 2
  %cp = getelementptr %TZR, ptr %rule, i32 0, i32 3
  %week = load i64, ptr %bp
  %weekday = load i64, ptr %cp
  %firstday = call i64 @t_days(i64 %year, i64 %a, i64 1)
  %firstweekday0 = add i64 %firstday, 4
  %firstweekday1 = srem i64 %firstweekday0, 7
  %negative = icmp slt i64 %firstweekday1, 0
  %firstweekday2 = add i64 %firstweekday1, 7
  %firstweekday = select i1 %negative, i64 %firstweekday2, i64 %firstweekday1
  %difference = sub i64 %weekday, %firstweekday
  %diffplus = add i64 %difference, 7
  %weekoffset = urem i64 %diffplus, 7
  %priorweeks = sub i64 %week, 1
  %weekdays = mul i64 %priorweeks, 7
  %dayoffset = add i64 %weekoffset, %weekdays
  %target0 = add i64 %firstday, %dayoffset
  %nextmonth = add i64 %a, 1
  %monthend = call i64 @t_days(i64 %year, i64 %nextmonth, i64 1)
  %pastend = icmp sge i64 %target0, %monthend
  %previousweek = sub i64 %target0, 7
  %mday = select i1 %pastend, i64 %previousweek, i64 %target0
  br label %time
time:
  %day = phi i64 [%nday, %ordinal], [%jday, %julian], [%mday, %month]
  %timep = getelementptr %TZR, ptr %rule, i32 0, i32 4
  %basisp = getelementptr %TZR, ptr %rule, i32 0, i32 5
  %clock = load i64, ptr %timep
  %basis = load i64, ptr %basisp
  %standard = icmp eq i64 %basis, 1
  %universal = icmp eq i64 %basis, 2
  %offset0 = select i1 %standard, i64 %standardoffset, i64 %beforeoffset
  %offset = select i1 %universal, i64 0, i64 %offset0
  %midnight = mul i64 %day, 86400
  %local = add i64 %midnight, %clock
  %epoch = sub i64 %local, %offset
  ret i64 %epoch
}

define ptr @j_posix_timezone(ptr %text, double %seconds) {
entry:
  %parser = call ptr @j_alloc(i64 32)
  %data = call ptr @b_data(ptr %text)
  %length = call i64 @b_len(ptr %text)
  store ptr %data, ptr %parser
  %lenp = getelementptr %TZP, ptr %parser, i32 0, i32 1
  %posp = getelementptr %TZP, ptr %parser, i32 0, i32 2
  %badp = getelementptr %TZP, ptr %parser, i32 0, i32 3
  store i64 %length, ptr %lenp
  %standardname = call ptr @tz_name(ptr %parser)
  %offset = call i64 @tz_clock(ptr %parser, i64 24)
  %standardoffset = sub i64 0, %offset
  %next = call i8 @tz_peek(ptr %parser)
  %nost = icmp eq i8 %next, 0
  br i1 %nost, label %fixed, label %daylight
fixed:
  br label %finish
daylight:
  %daylightname = call ptr @tz_name(ptr %parser)
  %nextchar = call i8 @tz_peek(ptr %parser)
  %comma = icmp eq i8 %nextchar, 44
  %end = icmp eq i8 %nextchar, 0
  %defaultoffset = or i1 %comma, %end
  br i1 %defaultoffset, label %defaultdaylight, label %explicitdaylight
defaultdaylight:
  %defaultvalue = add i64 %standardoffset, 3600
  br label %rules
explicitdaylight:
  %dayoffset = call i64 @tz_clock(ptr %parser, i64 24)
  %explicitvalue = sub i64 0, %dayoffset
  br label %rules
rules:
  %daylightoffset = phi i64 [%defaultvalue, %defaultdaylight], [%explicitvalue, %explicitdaylight]
  %rulechar = call i8 @tz_peek(ptr %parser)
  %missingrules = icmp eq i8 %rulechar, 0
  br i1 %missingrules, label %defaultsrules, label %parserules
defaultsrules:
  %defaulttext = call ptr @j_posix_default_rules()
  %hasdefaults = icmp ne ptr %defaulttext, null
  br i1 %hasdefaults, label %setdefaults, label %nodefaults
nodefaults:
  call void @tz_error(ptr %parser)
  br label %parserules
setdefaults:
  %defaultdata = call ptr @b_data(ptr %defaulttext)
  %defaultlength = call i64 @b_len(ptr %defaulttext)
  store ptr %defaultdata, ptr %parser
  store i64 %defaultlength, ptr %lenp
  store i64 0, ptr %posp
  br label %parserules
parserules:
  call void @tz_expect(ptr %parser, i8 44)
  %start = call ptr @tz_rule(ptr %parser)
  call void @tz_expect(ptr %parser, i8 44)
  %stop = call ptr @tz_rule(ptr %parser)
  %yearparts = call ptr @t_gmtime(double %seconds)
  %year = call i64 @t_field(ptr %yearparts, i64 0)
  %epoch = fptosi double %seconds to i64
  %firstyear = sub i64 %year, 1
  br label %yearloop
yearloop:
  %yi = phi i64 [0, %parserules], [%ynext, %yearbody]
  %laststart = phi i64 [-9223372036854775808, %parserules], [%newstart, %yearbody]
  %laststop = phi i64 [-9223372036854775808, %parserules], [%newstop, %yearbody]
  %yearmore = icmp ult i64 %yi, 3
  br i1 %yearmore, label %yearbody, label %yearfinish
yearbody:
  %currentyear = add i64 %firstyear, %yi
  %starttime = call i64 @tz_transition(ptr %start, i64 %currentyear, i64 %standardoffset, i64 %standardoffset)
  %stoptime = call i64 @tz_transition(ptr %stop, i64 %currentyear, i64 %daylightoffset, i64 %standardoffset)
  %startpast = icmp sle i64 %starttime, %epoch
  %startrecent = icmp sgt i64 %starttime, %laststart
  %usestart = and i1 %startpast, %startrecent
  %stoppast = icmp sle i64 %stoptime, %epoch
  %stoprecent = icmp sgt i64 %stoptime, %laststop
  %usestop = and i1 %stoppast, %stoprecent
  %newstart = select i1 %usestart, i64 %starttime, i64 %laststart
  %newstop = select i1 %usestop, i64 %stoptime, i64 %laststop
  %ynext = add i64 %yi, 1
  br label %yearloop
yearfinish:
  %dst = icmp sge i64 %laststart, %laststop
  %chosenoffset = select i1 %dst, i64 %daylightoffset, i64 %standardoffset
  %chosenname = select i1 %dst, ptr %daylightname, ptr %standardname
  br label %finish
finish:
  %resultoffset = phi i64 [%standardoffset, %fixed], [%chosenoffset, %yearfinish]
  %resultname = phi ptr [%standardname, %fixed], [%chosenname, %yearfinish]
  %position = load i64, ptr %posp
  %parselength = load i64, ptr %lenp
  %consumed = icmp eq i64 %position, %parselength
  %bad = load i1, ptr %badp
  %nobad = xor i1 %bad, true
  %success = and i1 %consumed, %nobad
  br i1 %success, label %result, label %invalid
result:
  %record = call ptr @j_alloc(i64 16)
  store i64 %resultoffset, ptr %record
  %namep = getelementptr %TZV, ptr %record, i32 0, i32 1
  %namebytes = call ptr @b_data(ptr %resultname)
  store ptr %namebytes, ptr %namep
  ret ptr %record
invalid:
  ret ptr null
}
