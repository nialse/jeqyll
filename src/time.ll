@j_error = external global ptr
@j_environ = external global ptr
@t.names = private constant [107 x i8] c"now\00gmtime\00localtime\00mktime\00strftime\00strflocaltime\00strptime\00fromdate\00fromdateiso8601\00todate\00todateiso8601\00\00"
@t.iso = private constant [21 x i8] c"%Y-%m-%dT%H:%M:%SZ\00\00\00"
@t.date = private constant [9 x i8] c"%Y-%m-%d\00"
@t.clock = private constant [9 x i8] c"%H:%M:%S\00"
@t.shortclock = private constant [6 x i8] c"%H:%M\00"
@t.slashdate = private constant [9 x i8] c"%m/%d/%y\00"
@t.cformat = private constant [21 x i8] c"%a %b %e %H:%M:%S %Y\00"
@t.rformat = private constant [12 x i8] c"%I:%M:%S %p\00"
@t.months = private constant [86 x i8] c"January\00February\00March\00April\00May\00June\00July\00August\00September\00October\00November\00December\00"
@t.weekdays = private constant [57 x i8] c"Sunday\00Monday\00Tuesday\00Wednesday\00Thursday\00Friday\00Saturday\00"
@t.am = private constant [3 x i8] c"AM\00"
@t.pm = private constant [3 x i8] c"PM\00"
@t.UTC = private constant [4 x i8] c"UTC\00"
@t.TZ = private constant [3 x i8] c"TZ\00"
@t.zonebase = private constant [22 x i8] c"/usr/share/zoneinfo/\00\00"
@t.localfile = private constant [15 x i8] c"/etc/localtime\00"
@t.errgmtime = private constant [33 x i8] c"gmtime() requires numeric inputs\00"
@t.errlocaltime = private constant [36 x i8] c"localtime() requires numeric inputs\00"
@t.errmktimearray = private constant [31 x i8] c"mktime requires array inputs\00\00\00"
@t.errmktime = private constant [40 x i8] c"mktime requires parsed datetime inputs\00\00"
@t.errstrftime = private constant [43 x i8] c"strftime/1 requires parsed datetime inputs\00"
@t.errstrflocal = private constant [48 x i8] c"strflocaltime/1 requires parsed datetime inputs\00"
@t.errformat = private constant [36 x i8] c"strftime/1 requires a string format\00"
@t.errlocalformat = private constant [41 x i8] c"strflocaltime/1 requires a string format\00"
@t.errstrptime = private constant [52 x i8] c"strptime/1 requires string inputs and arguments\00\00\00\00\00"
@t.errclock = private constant [22 x i8] c"Cannot read the clock\00"
@t.errdate = private constant [59 x i8] c"error converting number of seconds since epoch to datetime\00"
@t.errzone = private constant [30 x i8] c"Cannot load timezone database\00"
@t.dateprefix = private constant [7 x i8] c"date \22\00"
@t.datebetween = private constant [26 x i8] c"\22 does not match format \22\00"
@t.zone_data = internal global ptr null
@t.zone_size = internal global i64 0
@t.zone_offset = internal global i64 0
@t.zone_name = internal global ptr @t.UTC

declare ptr @j_alloc(i64)
declare ptr @j_null()
declare ptr @j_num(double)
declare ptr @j_array()
declare void @j_push(ptr, ptr)
declare ptr @j_at(ptr, i64)
declare ptr @j_str(ptr, i64)
declare ptr @j_cstr(ptr)
declare i64 @j_strlen(ptr)
declare ptr @j_get(ptr, ptr)
declare ptr @j_binary(i32, ptr, ptr)
declare void @j_copy(ptr, ptr, i64)
declare void @j_fail(ptr)
declare i32 @b_tag(ptr)
declare i64 @b_len(ptr)
declare ptr @b_data(ptr)
declare double @b_number(ptr)
declare ptr @b_one(ptr)
declare ptr @b_arg(ptr, i64, ptr, ptr)
declare i32 @b_find(ptr, ptr)
declare i32 @clock_gettime(i32, ptr)
declare i32 @open(ptr, i32, i32)
declare i64 @read(i32, ptr, i64)
declare i32 @close(i32)
declare ptr @j_buffer_new()
declare void @j_buffer_append(ptr, ptr, i64)
declare void @j_buffer_byte(ptr, i8)
declare ptr @j_buffer_value(ptr)

define internal i64 @t_floordiv(i64 %a, i64 %b) {
  %q = sdiv i64 %a, %b
  %r = srem i64 %a, %b
  %negative = icmp slt i64 %r, 0
  %less = sub i64 %q, 1
  %result = select i1 %negative, i64 %less, i64 %q
  ret i64 %result
}

define internal i64 @t_days(i64 %year, i64 %month, i64 %day) {
  %early = icmp sle i64 %month, 2
  %prior = sub i64 %year, 1
  %y = select i1 %early, i64 %prior, i64 %year
  %era = call i64 @t_floordiv(i64 %y, i64 400)
  %erayears = mul i64 %era, 400
  %yoe = sub i64 %y, %erayears
  %shift = select i1 %early, i64 9, i64 -3
  %m = add i64 %month, %shift
  %m153 = mul i64 %m, 153
  %mplus = add i64 %m153, 2
  %mpart = sdiv i64 %mplus, 5
  %d0 = sub i64 %day, 1
  %doy = add i64 %mpart, %d0
  %base = mul i64 %yoe, 365
  %leap4 = udiv i64 %yoe, 4
  %leap100 = udiv i64 %yoe, 100
  %with4 = add i64 %base, %leap4
  %without100 = sub i64 %with4, %leap100
  %doe = add i64 %without100, %doy
  %eradays = mul i64 %era, 146097
  %absolute = add i64 %eradays, %doe
  %days = sub i64 %absolute, 719468
  ret i64 %days
}

define internal void @t_push_int(ptr %array, i64 %i) {
  %n = sitofp i64 %i to double
  %v = call ptr @j_num(double %n)
  call void @j_push(ptr %array, ptr %v)
  ret void
}

define internal ptr @t_gmtime(double %seconds) {
entry:
  %low = fcmp oge double %seconds, -6.0e16
  %high = fcmp ole double %seconds, 6.0e16
  %valid = and i1 %low, %high
  br i1 %valid, label %convert, label %error
error:
  call void @j_fail(ptr @t.errdate)
  %null = call ptr @j_null()
  ret ptr %null
convert:
  %integral = fptosi double %seconds to i64
  %integerfloat = sitofp i64 %integral to double
  %fraction = fsub double %seconds, %integerfloat
  %days = call i64 @t_floordiv(i64 %integral, i64 86400)
  %dayseconds = mul i64 %days, 86400
  %remaining = sub i64 %integral, %dayseconds
  %hour = udiv i64 %remaining, 3600
  %hourremain = urem i64 %remaining, 3600
  %minute = udiv i64 %hourremain, 60
  %second = urem i64 %hourremain, 60
  %secondfloat = uitofp i64 %second to double
  %secondsfloat = fadd double %secondfloat, %fraction
  %absolute = add i64 %days, 719468
  %era = call i64 @t_floordiv(i64 %absolute, i64 146097)
  %eradays = mul i64 %era, 146097
  %doe = sub i64 %absolute, %eradays
  %d1460 = udiv i64 %doe, 1460
  %d36524 = udiv i64 %doe, 36524
  %d146096 = udiv i64 %doe, 146096
  %minus4 = sub i64 %doe, %d1460
  %plus100 = add i64 %minus4, %d36524
  %minus400 = sub i64 %plus100, %d146096
  %yoe = udiv i64 %minus400, 365
  %erayears = mul i64 %era, 400
  %yearbase = add i64 %erayears, %yoe
  %year365 = mul i64 %yoe, 365
  %year4 = udiv i64 %yoe, 4
  %year100 = udiv i64 %yoe, 100
  %with4 = add i64 %year365, %year4
  %without100 = sub i64 %with4, %year100
  %doy = sub i64 %doe, %without100
  %doy5 = mul i64 %doy, 5
  %doyplus = add i64 %doy5, 2
  %mp = udiv i64 %doyplus, 153
  %mp153 = mul i64 %mp, 153
  %mpplus = add i64 %mp153, 2
  %mpdays = udiv i64 %mpplus, 5
  %day0 = sub i64 %doy, %mpdays
  %day = add i64 %day0, 1
  %late = icmp ult i64 %mp, 10
  %monthshift = select i1 %late, i64 3, i64 -9
  %month = add i64 %mp, %monthshift
  %early = icmp ule i64 %month, 2
  %yearnext = add i64 %yearbase, 1
  %year = select i1 %early, i64 %yearnext, i64 %yearbase
  %month0 = sub i64 %month, 1
  %jan1 = call i64 @t_days(i64 %year, i64 1, i64 1)
  %yearday = sub i64 %days, %jan1
  %weekdayraw = add i64 %days, 4
  %weekdayrem = srem i64 %weekdayraw, 7
  %weekdaynegative = icmp slt i64 %weekdayrem, 0
  %weekdayplus = add i64 %weekdayrem, 7
  %weekday = select i1 %weekdaynegative, i64 %weekdayplus, i64 %weekdayrem
  %out = call ptr @j_array()
  call void @t_push_int(ptr %out, i64 %year)
  call void @t_push_int(ptr %out, i64 %month0)
  call void @t_push_int(ptr %out, i64 %day)
  call void @t_push_int(ptr %out, i64 %hour)
  call void @t_push_int(ptr %out, i64 %minute)
  %secondsvalue = call ptr @j_num(double %secondsfloat)
  call void @j_push(ptr %out, ptr %secondsvalue)
  call void @t_push_int(ptr %out, i64 %weekday)
  call void @t_push_int(ptr %out, i64 %yearday)
  ret ptr %out
}

define internal i64 @t_field(ptr %array, i64 %index) {
entry:
  %length = call i64 @b_len(ptr %array)
  %present = icmp ult i64 %index, %length
  br i1 %present, label %read, label %missing
read:
  %value = call ptr @j_at(ptr %array, i64 %index)
  %n = call double @b_number(ptr %value)
  %result = fptosi double %n to i64
  ret i64 %result
missing:
  %year = icmp eq i64 %index, 0
  %default = select i1 %year, i64 1900, i64 0
  ret i64 %default
}

define internal i1 @t_valid_array(ptr %array) {
entry:
  %tag = call i32 @b_tag(ptr %array)
  %isarray = icmp eq i32 %tag, 5
  br i1 %isarray, label %start, label %invalid
start:
  %length = call i64 @b_len(ptr %array)
  %long = icmp ugt i64 %length, 8
  %count = select i1 %long, i64 8, i64 %length
  br label %loop
loop:
  %i = phi i64 [ 0, %start ], [ %next, %numeric ]
  %done = icmp eq i64 %i, %count
  br i1 %done, label %valid, label %body
body:
  %v = call ptr @j_at(ptr %array, i64 %i)
  %t = call i32 @b_tag(ptr %v)
  %number = icmp eq i32 %t, 3
  br i1 %number, label %numbercheck, label %invalid
numbercheck:
  %n = call double @b_number(ptr %v)
  %lo = fcmp oge double %n, -2.147483648e9
  %hi = fcmp ole double %n, 2.147483647e9
  %fits = and i1 %lo, %hi
  br i1 %fits, label %numeric, label %invalid
numeric:
  %next = add i64 %i, 1
  br label %loop
valid:
  ret i1 true
invalid:
  ret i1 false
}

define internal double @t_mktime(ptr %array) {
  %year = call i64 @t_field(ptr %array, i64 0)
  %month = call i64 @t_field(ptr %array, i64 1)
  %day = call i64 @t_field(ptr %array, i64 2)
  %hour = call i64 @t_field(ptr %array, i64 3)
  %minute = call i64 @t_field(ptr %array, i64 4)
  %second = call i64 @t_field(ptr %array, i64 5)
  %extrayears = call i64 @t_floordiv(i64 %month, i64 12)
  %normalyear = add i64 %year, %extrayears
  %yearmonths = mul i64 %extrayears, 12
  %month0 = sub i64 %month, %yearmonths
  %month1 = add i64 %month0, 1
  %days = call i64 @t_days(i64 %normalyear, i64 %month1, i64 %day)
  %dsec = mul i64 %days, 86400
  %hsec = mul i64 %hour, 3600
  %msec = mul i64 %minute, 60
  %dh = add i64 %dsec, %hsec
  %dhm = add i64 %dh, %msec
  %seconds = add i64 %dhm, %second
  %result = sitofp i64 %seconds to double
  ret double %result
}

define internal i64 @t_be(ptr %p, i64 %width) {
entry:
  br label %loop
loop:
  %i = phi i64 [ 0, %entry ], [ %next, %body ]
  %n = phi i64 [ 0, %entry ], [ %value, %body ]
  %done = icmp eq i64 %i, %width
  br i1 %done, label %end, label %body
body:
  %bp = getelementptr i8, ptr %p, i64 %i
  %b = load i8, ptr %bp
  %bu = zext i8 %b to i64
  %shift = shl i64 %n, 8
  %value = or i64 %shift, %bu
  %next = add i64 %i, 1
  br label %loop
end:
  ret i64 %n
}

define internal i64 @t_header(ptr %p, i64 %offset) {
  %field = getelementptr i8, ptr %p, i64 %offset
  %n = call i64 @t_be(ptr %field, i64 4)
  ret i64 %n
}

define internal i64 @t_timezone(double %seconds) {
entry:
  %cached = load ptr, ptr @t.zone_data
  %loaded = icmp ne ptr %cached, null
  br i1 %loaded, label %ready, label %load
load:
  %environ = load ptr, ptr @j_environ
  %envexists = icmp ne ptr %environ, null
  br i1 %envexists, label %environment, label %defaultpath
environment:
  %key = call ptr @j_cstr(ptr @t.TZ)
  %zone = call ptr @j_get(ptr %environ, ptr %key)
  %tag = call i32 @b_tag(ptr %zone)
  %string = icmp eq i32 %tag, 4
  br i1 %string, label %zonename, label %defaultpath
zonename:
  %zlen = call i64 @b_len(ptr %zone)
  %zdata = call ptr @b_data(ptr %zone)
  %empty = icmp eq i64 %zlen, 0
  br i1 %empty, label %utc, label %zonefirst
zonefirst:
  %first = load i8, ptr %zdata
  %colon = icmp eq i8 %first, 58
  %skip = zext i1 %colon to i64
  %zstart = getelementptr i8, ptr %zdata, i64 %skip
  %zl = sub i64 %zlen, %skip
  %c = load i8, ptr %zstart
  %absolute = icmp eq i8 %c, 47
  br i1 %absolute, label %absolutepath, label %relativepath
absolutepath:
  br label %openfile
relativepath:
  %size = add i64 %zl, 21
  %full = call ptr @j_alloc(i64 %size)
  call void @j_copy(ptr %full, ptr @t.zonebase, i64 20)
  %tail = getelementptr i8, ptr %full, i64 20
  call void @j_copy(ptr %tail, ptr %zstart, i64 %zl)
  br label %openfile
defaultpath:
  br label %openfile
openfile:
  %path = phi ptr [ @t.localfile, %defaultpath ], [ %full, %relativepath ], [ %zstart, %absolutepath ]
  %fd = call i32 @open(ptr %path, i32 0, i32 0)
  %badfd = icmp slt i32 %fd, 0
  br i1 %badfd, label %error, label %readfile
readfile:
  %bytes = call ptr @j_alloc(i64 1048576)
  %size_read = call i64 @read(i32 %fd, ptr %bytes, i64 1048576)
  %closed = call i32 @close(i32 %fd)
  %short = icmp slt i64 %size_read, 44
  br i1 %short, label %error, label %save
save:
  store ptr %bytes, ptr @t.zone_data
  store i64 %size_read, ptr @t.zone_size
  br label %ready
ready:
  %data = load ptr, ptr @t.zone_data
  %magic = call i64 @t_be(ptr %data, i64 4)
  %validmagic = icmp eq i64 %magic, 1415211366
  br i1 %validmagic, label %version, label %error
version:
  %vp = getelementptr i8, ptr %data, i64 4
  %v = load i8, ptr %vp
  %v2 = icmp uge i8 %v, 50
  br i1 %v2, label %skipfirst, label %firstblock
skipfirst:
  %gmtcnt = call i64 @t_header(ptr %data, i64 20)
  %stdcnt = call i64 @t_header(ptr %data, i64 24)
  %leapcnt = call i64 @t_header(ptr %data, i64 28)
  %timecnt = call i64 @t_header(ptr %data, i64 32)
  %typecnt = call i64 @t_header(ptr %data, i64 36)
  %charcnt = call i64 @t_header(ptr %data, i64 40)
  %t5 = mul i64 %timecnt, 5
  %types = mul i64 %typecnt, 6
  %leaps = mul i64 %leapcnt, 8
  %a = add i64 %gmtcnt, %stdcnt
  %b = add i64 %a, %leaps
  %c1 = add i64 %b, %t5
  %d = add i64 %c1, %types
  %e = add i64 %d, %charcnt
  %blocksize = add i64 %e, 44
  %nextheader = getelementptr i8, ptr %data, i64 %blocksize
  br label %block
firstblock:
  br label %block
block:
  %header = phi ptr [ %nextheader, %skipfirst ], [ %data, %firstblock ]
  %width = phi i64 [ 8, %skipfirst ], [ 4, %firstblock ]
  %ntimes = call i64 @t_header(ptr %header, i64 32)
  %ntypes = call i64 @t_header(ptr %header, i64 36)
  %transitions = getelementptr i8, ptr %header, i64 44
  %timebytes = mul i64 %ntimes, %width
  %indices = getelementptr i8, ptr %transitions, i64 %timebytes
  %typesbase = getelementptr i8, ptr %indices, i64 %ntimes
  %typebytes = mul i64 %ntypes, 6
  %names = getelementptr i8, ptr %typesbase, i64 %typebytes
  %epoch = fptosi double %seconds to i64
  br label %transloop
transloop:
  %i = phi i64 [ 0, %block ], [ %next, %take ]
  %index = phi i64 [ 0, %block ], [ %typeindex, %take ]
  %done = icmp eq i64 %i, %ntimes
  br i1 %done, label %selected, label %transbody
transbody:
  %offset = mul i64 %i, %width
  %tp = getelementptr i8, ptr %transitions, i64 %offset
  %raw = call i64 @t_be(ptr %tp, i64 %width)
  %is32 = icmp eq i64 %width, 4
  %raw32 = trunc i64 %raw to i32
  %sign32 = sext i32 %raw32 to i64
  %when = select i1 %is32, i64 %sign32, i64 %raw
  %future = icmp sgt i64 %when, %epoch
  br i1 %future, label %selected, label %take
take:
  %ip = getelementptr i8, ptr %indices, i64 %i
  %ix = load i8, ptr %ip
  %typeindex = zext i8 %ix to i64
  %next = add i64 %i, 1
  br label %transloop
selected:
  %typeoffset = mul i64 %index, 6
  %type = getelementptr i8, ptr %typesbase, i64 %typeoffset
  %offsetraw = call i64 @t_be(ptr %type, i64 4)
  %offset32 = trunc i64 %offsetraw to i32
  %gmtoff = sext i32 %offset32 to i64
  %abbrp = getelementptr i8, ptr %type, i64 5
  %abbr8 = load i8, ptr %abbrp
  %abbr = zext i8 %abbr8 to i64
  %name = getelementptr i8, ptr %names, i64 %abbr
  store ptr %name, ptr @t.zone_name
  store i64 %gmtoff, ptr @t.zone_offset
  ret i64 %gmtoff
utc:
  store ptr @t.UTC, ptr @t.zone_name
  store i64 0, ptr @t.zone_offset
  ret i64 0
error:
  call void @j_fail(ptr @t.errzone)
  ret i64 0
}

define internal ptr @t_name(ptr %table, i64 %index) {
entry:
  br label %loop
loop:
  %p = phi ptr [ %table, %entry ], [ %next, %body ]
  %i = phi i64 [ 0, %entry ], [ %in, %body ]
  %done = icmp eq i64 %i, %index
  br i1 %done, label %end, label %body
body:
  %len = call i64 @j_strlen(ptr %p)
  %size = add i64 %len, 1
  %next = getelementptr i8, ptr %p, i64 %size
  %in = add i64 %i, 1
  br label %loop
end:
  ret ptr %p
}

define internal void @t_uint(ptr %buffer, i64 %number, i64 %width, i8 %pad) {
entry:
  %negative = icmp slt i64 %number, 0
  %negated = sub i64 0, %number
  %magnitude = select i1 %negative, i64 %negated, i64 %number
  %digits = alloca [24 x i8]
  br i1 %negative, label %sign, label %start
sign:
  call void @j_buffer_byte(ptr %buffer, i8 45)
  br label %start
start:
  br label %loop
loop:
  %n = phi i64 [ %magnitude, %start ], [ %quotient, %loop ]
  %len = phi i64 [ 0, %start ], [ %ln, %loop ]
  %r = urem i64 %n, 10
  %d = trunc i64 %r to i8
  %c = add i8 %d, 48
  %p = getelementptr i8, ptr %digits, i64 %len
  store i8 %c, ptr %p
  %quotient = udiv i64 %n, 10
  %ln = add i64 %len, 1
  %done = icmp eq i64 %quotient, 0
  br i1 %done, label %padding, label %loop
padding:
  %i = phi i64 [ %ln, %loop ], [ %in, %padone ]
  %padded = icmp uge i64 %i, %width
  br i1 %padded, label %reverse, label %padone
padone:
  call void @j_buffer_byte(ptr %buffer, i8 %pad)
  %in = add i64 %i, 1
  br label %padding
reverse:
  %j = phi i64 [ %ln, %padding ], [ %previous, %emit ]
  %end = icmp eq i64 %j, 0
  br i1 %end, label %finish, label %emit
emit:
  %previous = sub i64 %j, 1
  %dp = getelementptr i8, ptr %digits, i64 %previous
  %dc = load i8, ptr %dp
  call void @j_buffer_byte(ptr %buffer, i8 %dc)
  br label %reverse
finish:
  ret void
}

define internal ptr @t_expand(ptr %format) {
entry:
  %data = call ptr @b_data(ptr %format)
  %len = call i64 @b_len(ptr %format)
  %buffer = call ptr @j_buffer_new()
  br label %loop
loop:
  %i = phi i64 [ 0, %entry ], [ %next, %plain ], [ %after, %copy ], [ %after, %expand ]
  %done = icmp uge i64 %i, %len
  br i1 %done, label %end, label %body
body:
  %p = getelementptr i8, ptr %data, i64 %i
  %c = load i8, ptr %p
  %next = add i64 %i, 1
  %percent = icmp eq i8 %c, 37
  %hasnext = icmp ult i64 %next, %len
  %directive = and i1 %percent, %hasnext
  br i1 %directive, label %spec, label %plain
plain:
  call void @j_buffer_byte(ptr %buffer, i8 %c)
  br label %loop
spec:
  %sp = getelementptr i8, ptr %p, i64 1
  %s = load i8, ptr %sp
  %after = add i64 %i, 2
  switch i8 %s, label %copy [ i8 70, label %date i8 84, label %clock i8 82, label %shortclock i8 68, label %slashdate i8 120, label %slashdate i8 88, label %clock i8 99, label %cformat i8 114, label %rformat ]
copy:
  call void @j_buffer_append(ptr %buffer, ptr %p, i64 2)
  br label %loop
date:
  br label %expand
clock:
  br label %expand
shortclock:
  br label %expand
slashdate:
  br label %expand
cformat:
  br label %expand
rformat:
  br label %expand
expand:
  %text = phi ptr [ @t.date, %date ], [ @t.clock, %clock ], [ @t.shortclock, %shortclock ], [ @t.slashdate, %slashdate ], [ @t.cformat, %cformat ], [ @t.rformat, %rformat ]
  %length = call i64 @j_strlen(ptr %text)
  call void @j_buffer_append(ptr %buffer, ptr %text, i64 %length)
  br label %loop
end:
  %out = call ptr @j_buffer_value(ptr %buffer)
  ret ptr %out
}

define internal ptr @t_format(ptr %array, ptr %format, double %epochseconds, i1 %local) {
entry:
  %expanded = call ptr @t_expand(ptr %format)
  %data = call ptr @b_data(ptr %expanded)
  %length = call i64 @b_len(ptr %expanded)
  %buffer = call ptr @j_buffer_new()
  %yearvalue = call i64 @t_field(ptr %array, i64 0)
  %month0 = call i64 @t_field(ptr %array, i64 1)
  %monthvalue = add i64 %month0, 1
  %dayvalue = call i64 @t_field(ptr %array, i64 2)
  %hourvalue = call i64 @t_field(ptr %array, i64 3)
  %minutevalue = call i64 @t_field(ptr %array, i64 4)
  %secondvalue = call i64 @t_field(ptr %array, i64 5)
  %weekdayvalue = call i64 @t_field(ptr %array, i64 6)
  %yearday0 = call i64 @t_field(ptr %array, i64 7)
  %yeardayvalue = add i64 %yearday0, 1
  br label %loop
loop:
  %i = phi i64 [ 0, %entry ], [ %next, %plain ], [ %after, %numeric ], [ %after, %text ], [ %after, %single ], [ %after, %zone ], [ %after, %unsupported ]
  %done = icmp uge i64 %i, %length
  br i1 %done, label %end, label %body
body:
  %p = getelementptr i8, ptr %data, i64 %i
  %c = load i8, ptr %p
  %next = add i64 %i, 1
  %percent = icmp eq i8 %c, 37
  %hasnext = icmp ult i64 %next, %length
  %directive = and i1 %percent, %hasnext
  br i1 %directive, label %specstart, label %plain
plain:
  call void @j_buffer_byte(ptr %buffer, i8 %c)
  br label %loop
specstart:
  br label %modifiers
modifiers:
  %position = phi i64 [ %next, %specstart ], [ %modnext, %modifier ]
  %padding = phi i8 [ 48, %specstart ], [ %newpadding, %modifier ]
  %nopad = phi i1 [ false, %specstart ], [ %newnopad, %modifier ]
  %sp = getelementptr i8, ptr %data, i64 %position
  %s = load i8, ptr %sp
  %ismod1 = icmp eq i8 %s, 69
  %ismod2 = icmp eq i8 %s, 79
  %spacepad = icmp eq i8 %s, 95
  %zeropad = icmp eq i8 %s, 48
  %dash = icmp eq i8 %s, 45
  %moda = or i1 %ismod1, %ismod2
  %modb = or i1 %spacepad, %zeropad
  %modc = or i1 %moda, %modb
  %ismod = or i1 %modc, %dash
  %modnext = add i64 %position, 1
  %more = icmp ult i64 %modnext, %length
  %canmod = and i1 %ismod, %more
  br i1 %canmod, label %modifier, label %dispatch
modifier:
  %padzero = select i1 %zeropad, i8 48, i8 %padding
  %newpadding = select i1 %spacepad, i8 32, i8 %padzero
  %newnopad = or i1 %nopad, %dash
  br label %modifiers
dispatch:
  %after = add i64 %position, 1
  switch i8 %s, label %unsupported [ i8 89, label %year i8 121, label %year2 i8 67, label %century i8 109, label %month i8 100, label %day i8 101, label %dayblank i8 72, label %hour i8 107, label %hourblank i8 73, label %hour12 i8 108, label %hour12 i8 77, label %minute i8 83, label %second i8 106, label %yearday i8 119, label %weekday i8 117, label %isoweekday i8 65, label %weekdayname i8 97, label %weekdayname i8 66, label %monthname i8 98, label %monthname i8 104, label %monthname i8 112, label %ampm i8 80, label %ampm i8 90, label %zonename i8 122, label %zone i8 115, label %epoch i8 37, label %literalpercent i8 110, label %newline i8 116, label %tab i8 85, label %week_sunday i8 87, label %week_monday ]
year:
  br label %numeric
year2:
  %y2 = srem i64 %yearvalue, 100
  br label %numeric
century:
  %cent = sdiv i64 %yearvalue, 100
  br label %numeric
month:
  br label %numeric
day:
  br label %numeric
dayblank:
  br label %numeric
hour:
  br label %numeric
hourblank:
  br label %numeric
hour12:
  %hrem = urem i64 %hourvalue, 12
  %hzero = icmp eq i64 %hrem, 0
  %h12 = select i1 %hzero, i64 12, i64 %hrem
  br label %numeric
minute:
  br label %numeric
second:
  br label %numeric
yearday:
  br label %numeric
weekday:
  br label %numeric
isoweekday:
  %sunday = icmp eq i64 %weekdayvalue, 0
  %iso = select i1 %sunday, i64 7, i64 %weekdayvalue
  br label %numeric
epoch:
  %timestamp = fptosi double %epochseconds to i64
  br label %numeric
week_sunday:
  %wbase = sub i64 %yearday0, %weekdayvalue
  %wplus = add i64 %wbase, 7
  %wsunday = udiv i64 %wplus, 7
  br label %numeric
week_monday:
  %wdplus = add i64 %weekdayvalue, 6
  %wdmon = urem i64 %wdplus, 7
  %wmbase = sub i64 %yearday0, %wdmon
  %wmplus = add i64 %wmbase, 7
  %wmonday = udiv i64 %wmplus, 7
  br label %numeric
numeric:
  %n = phi i64 [ %yearvalue, %year ], [ %y2, %year2 ], [ %cent, %century ], [ %monthvalue, %month ], [ %dayvalue, %day ], [ %dayvalue, %dayblank ], [ %hourvalue, %hour ], [ %hourvalue, %hourblank ], [ %h12, %hour12 ], [ %minutevalue, %minute ], [ %secondvalue, %second ], [ %yeardayvalue, %yearday ], [ %weekdayvalue, %weekday ], [ %iso, %isoweekday ], [ %timestamp, %epoch ], [ %wsunday, %week_sunday ], [ %wmonday, %week_monday ]
  %width = phi i64 [ 4, %year ], [ 2, %year2 ], [ 2, %century ], [ 2, %month ], [ 2, %day ], [ 2, %dayblank ], [ 2, %hour ], [ 2, %hourblank ], [ 2, %hour12 ], [ 2, %minute ], [ 2, %second ], [ 3, %yearday ], [ 1, %weekday ], [ 1, %isoweekday ], [ 1, %epoch ], [ 2, %week_sunday ], [ 2, %week_monday ]
  %defaultpad = phi i8 [ %padding, %year ], [ %padding, %year2 ], [ %padding, %century ], [ %padding, %month ], [ %padding, %day ], [ 32, %dayblank ], [ %padding, %hour ], [ 32, %hourblank ], [ %padding, %hour12 ], [ %padding, %minute ], [ %padding, %second ], [ %padding, %yearday ], [ %padding, %weekday ], [ %padding, %isoweekday ], [ %padding, %epoch ], [ %padding, %week_sunday ], [ %padding, %week_monday ]
  %effectivewidth = select i1 %nopad, i64 1, i64 %width
  call void @t_uint(ptr %buffer, i64 %n, i64 %effectivewidth, i8 %defaultpad)
  br label %loop
weekdayname:
  %wname = call ptr @t_name(ptr @t.weekdays, i64 %weekdayvalue)
  %wfull = call i64 @j_strlen(ptr %wname)
  %wshort = icmp eq i8 %s, 97
  %wlen = select i1 %wshort, i64 3, i64 %wfull
  br label %text
monthname:
  %mname = call ptr @t_name(ptr @t.months, i64 %month0)
  %mfull = call i64 @j_strlen(ptr %mname)
  %mlong = icmp eq i8 %s, 66
  %mlen = select i1 %mlong, i64 %mfull, i64 3
  br label %text
ampm:
  %pm = icmp uge i64 %hourvalue, 12
  %apname = select i1 %pm, ptr @t.pm, ptr @t.am
  br label %text
zonename:
  %localname = load ptr, ptr @t.zone_name
  %zname = select i1 %local, ptr %localname, ptr @t.UTC
  %zlen = call i64 @j_strlen(ptr %zname)
  br label %text
text:
  %textdata = phi ptr [ %wname, %weekdayname ], [ %mname, %monthname ], [ %apname, %ampm ], [ %zname, %zonename ]
  %textlen = phi i64 [ %wlen, %weekdayname ], [ %mlen, %monthname ], [ 2, %ampm ], [ %zlen, %zonename ]
  call void @j_buffer_append(ptr %buffer, ptr %textdata, i64 %textlen)
  br label %loop
zone:
  %localoffset = load i64, ptr @t.zone_offset
  %gmtoff = select i1 %local, i64 %localoffset, i64 0
  %znegative = icmp slt i64 %gmtoff, 0
  %zsign = select i1 %znegative, i8 45, i8 43
  call void @j_buffer_byte(ptr %buffer, i8 %zsign)
  %znegated = sub i64 0, %gmtoff
  %zabs = select i1 %znegative, i64 %znegated, i64 %gmtoff
  %zhour = udiv i64 %zabs, 3600
  %zremain = urem i64 %zabs, 3600
  %zminute = udiv i64 %zremain, 60
  call void @t_uint(ptr %buffer, i64 %zhour, i64 2, i8 48)
  call void @t_uint(ptr %buffer, i64 %zminute, i64 2, i8 48)
  br label %loop
literalpercent:
  br label %single
newline:
  br label %single
tab:
  br label %single
single:
  %char = phi i8 [ 37, %literalpercent ], [ 10, %newline ], [ 9, %tab ]
  call void @j_buffer_byte(ptr %buffer, i8 %char)
  br label %loop
unsupported:
  call void @j_buffer_byte(ptr %buffer, i8 37)
  call void @j_buffer_byte(ptr %buffer, i8 %s)
  br label %loop
end:
  %result = call ptr @j_buffer_value(ptr %buffer)
  ret ptr %result
}

define internal ptr @t_formatted(ptr %input, ptr %format, i1 %local) {
entry:
  %ft = call i32 @b_tag(ptr %format)
  %string = icmp eq i32 %ft, 4
  br i1 %string, label %inputcheck, label %formaterror
formaterror:
  %fmsg = select i1 %local, ptr @t.errlocalformat, ptr @t.errformat
  call void @j_fail(ptr %fmsg)
  br label %error
inputcheck:
  %tag = call i32 @b_tag(ptr %input)
  %number = icmp eq i32 %tag, 3
  br i1 %number, label %numeric, label %arraycheck
arraycheck:
  %valid = call i1 @t_valid_array(ptr %input)
  br i1 %valid, label %array, label %arrayerror
arrayerror:
  %amsg = select i1 %local, ptr @t.errstrflocal, ptr @t.errstrftime
  call void @j_fail(ptr %amsg)
  br label %error
array:
  %arrayseconds = call double @t_mktime(ptr %input)
  br i1 %local, label %localarray, label %formatstart
localarray:
  %guessoff = call i64 @t_timezone(double %arrayseconds)
  %goff = sitofp i64 %guessoff to double
  %guessepoch = fsub double %arrayseconds, %goff
  %actualoff = call i64 @t_timezone(double %guessepoch)
  %aoff = sitofp i64 %actualoff to double
  %arrayepoch = fsub double %arrayseconds, %aoff
  br label %formatstart
numeric:
  %numberseconds = call double @b_number(ptr %input)
  br i1 %local, label %localnumeric, label %formatstart
localnumeric:
  %offset = call i64 @t_timezone(double %numberseconds)
  %off = sitofp i64 %offset to double
  %localseconds = fadd double %numberseconds, %off
  br label %formatstart
formatstart:
  %seconds = phi double [ %arrayseconds, %array ], [ %arrayseconds, %localarray ], [ %numberseconds, %numeric ], [ %localseconds, %localnumeric ]
  %epoch = phi double [ %arrayseconds, %array ], [ %arrayepoch, %localarray ], [ %numberseconds, %numeric ], [ %numberseconds, %localnumeric ]
  %date = call ptr @t_gmtime(double %seconds)
  %err = load ptr, ptr @j_error
  %failed = icmp ne ptr %err, null
  br i1 %failed, label %error, label %emitformat
emitformat:
  %result = call ptr @t_format(ptr %date, ptr %format, double %epoch, i1 %local)
  ret ptr %result
error:
  %null = call ptr @j_null()
  ret ptr %null
}

define ptr @j_time_builtin(ptr %name, ptr %args, ptr %input, ptr %env) {
entry:
  %id = call i32 @b_find(ptr %name, ptr @t.names)
  switch i32 %id, label %unknown [ i32 0, label %now i32 1, label %gmtime i32 2, label %gmtime i32 3, label %mktime i32 4, label %formatargs i32 5, label %formatargs i32 6, label %formatargs i32 7, label %fromdate i32 8, label %fromdate i32 9, label %todate i32 10, label %todate ]
now:
  %timespec = alloca { i64, i64 }
  %clockresult = call i32 @clock_gettime(i32 0, ptr %timespec)
  %clockbad = icmp slt i32 %clockresult, 0
  br i1 %clockbad, label %clockerror, label %clockvalue
clockerror:
  call void @j_fail(ptr @t.errclock)
  br label %error
clockvalue:
  %seconds = load i64, ptr %timespec
  %nsp = getelementptr i64, ptr %timespec, i64 1
  %nanos = load i64, ptr %nsp
  %sd = sitofp i64 %seconds to double
  %nd = sitofp i64 %nanos to double
  %fraction = fdiv double %nd, 1.0e9
  %nowvalue = fadd double %sd, %fraction
  %nv = call ptr @j_num(double %nowvalue)
  br label %one
gmtime:
  %gtag = call i32 @b_tag(ptr %input)
  %gnumber = icmp eq i32 %gtag, 3
  %local = icmp eq i32 %id, 2
  br i1 %gnumber, label %gmtimeread, label %gmtimeerror
gmtimeerror:
  %gmsg = select i1 %local, ptr @t.errlocaltime, ptr @t.errgmtime
  call void @j_fail(ptr %gmsg)
  br label %error
gmtimeread:
  %gseconds = call double @b_number(ptr %input)
  br i1 %local, label %localtime, label %gmtimeconvert
localtime:
  %goffset = call i64 @t_timezone(double %gseconds)
  %god = sitofp i64 %goffset to double
  %glocal = fadd double %gseconds, %god
  br label %gmtimeconvert
gmtimeconvert:
  %gepoch = phi double [ %gseconds, %gmtimeread ], [ %glocal, %localtime ]
  %gv = call ptr @t_gmtime(double %gepoch)
  br label %one
mktime:
  %mtag = call i32 @b_tag(ptr %input)
  %marray = icmp eq i32 %mtag, 5
  br i1 %marray, label %mktimecheck, label %mktimearrayerror
mktimearrayerror:
  call void @j_fail(ptr @t.errmktimearray)
  br label %error
mktimecheck:
  %mvalid = call i1 @t_valid_array(ptr %input)
  br i1 %mvalid, label %mktimeconvert, label %mktimeerror
mktimeerror:
  call void @j_fail(ptr @t.errmktime)
  br label %error
mktimeconvert:
  %mseconds = call double @t_mktime(ptr %input)
  %mv = call ptr @j_num(double %mseconds)
  br label %one
todate:
  %isoformat = call ptr @j_cstr(ptr @t.iso)
  %todatestring = call ptr @t_formatted(ptr %input, ptr %isoformat, i1 false)
  br label %one
fromdate:
  %fromformat = call ptr @j_cstr(ptr @t.iso)
  %fromarray = call ptr @t_strptime(ptr %input, ptr %fromformat)
  %fromerr = load ptr, ptr @j_error
  %fromfailed = icmp ne ptr %fromerr, null
  br i1 %fromfailed, label %error, label %fromseconds
fromseconds:
  %fromepoch = call double @t_mktime(ptr %fromarray)
  %fromvalue = call ptr @j_num(double %fromepoch)
  br label %one
formatargs:
  %formats = call ptr @b_arg(ptr %args, i64 0, ptr %input, ptr %env)
  %formatcount = call i64 @b_len(ptr %formats)
  %out = call ptr @j_array()
  %localformat = icmp eq i32 %id, 5
  br label %formatloop
formatloop:
  %i = phi i64 [ 0, %formatargs ], [ %next, %formatappend ]
  %done = icmp eq i64 %i, %formatcount
  br i1 %done, label %formatdone, label %formatbody
formatbody:
  %fmt = call ptr @j_at(ptr %formats, i64 %i)
  %parsing = icmp eq i32 %id, 6
  br i1 %parsing, label %parseformat, label %printformat
parseformat:
  %parsed = call ptr @t_strptime(ptr %input, ptr %fmt)
  br label %formatcheck
printformat:
  %formatted = call ptr @t_formatted(ptr %input, ptr %fmt, i1 %localformat)
  br label %formatcheck
formatcheck:
  %formatresult = phi ptr [ %parsed, %parseformat ], [ %formatted, %printformat ]
  %ferr = load ptr, ptr @j_error
  %ffailed = icmp ne ptr %ferr, null
  br i1 %ffailed, label %formatdone, label %formatappend
formatappend:
  call void @j_push(ptr %out, ptr %formatresult)
  %next = add i64 %i, 1
  br label %formatloop
formatdone:
  ret ptr %out
one:
  %value = phi ptr [ %nv, %clockvalue ], [ %gv, %gmtimeconvert ], [ %mv, %mktimeconvert ], [ %todatestring, %todate ], [ %fromvalue, %fromseconds ]
  %err = load ptr, ptr @j_error
  %failed = icmp ne ptr %err, null
  br i1 %failed, label %error, label %success
success:
  %stream = call ptr @b_one(ptr %value)
  ret ptr %stream
error:
  %empty = call ptr @j_array()
  ret ptr %empty
unknown:
  ret ptr null
}

define internal i64 @t_read_uint(ptr %data, i64 %length, ptr %offset, i64 %width) {
entry:
  %start = load i64, ptr %offset
  br label %loop
loop:
  %i = phi i64 [ %start, %entry ], [ %next, %digit ]
  %n = phi i64 [ 0, %entry ], [ %sum, %digit ]
  %read = sub i64 %i, %start
  %full = icmp eq i64 %read, %width
  %eof = icmp uge i64 %i, %length
  %done = or i1 %full, %eof
  br i1 %done, label %end, label %body
body:
  %p = getelementptr i8, ptr %data, i64 %i
  %c = load i8, ptr %p
  %d = sub i8 %c, 48
  %is = icmp ult i8 %d, 10
  br i1 %is, label %digit, label %end
digit:
  %du = zext i8 %d to i64
  %times = mul i64 %n, 10
  %sum = add i64 %times, %du
  %next = add i64 %i, 1
  br label %loop
end:
  store i64 %i, ptr %offset
  %empty = icmp eq i64 %i, %start
  %result = select i1 %empty, i64 -1, i64 %n
  ret i64 %result
}

define internal i1 @t_whitespace(i8 %c) {
  %space = icmp eq i8 %c, 32
  %control = sub i8 %c, 9
  %controlspace = icmp ult i8 %control, 5
  %result = or i1 %space, %controlspace
  ret i1 %result
}

define internal i64 @t_skip_space(ptr %data, i64 %length, i64 %start) {
entry:
  br label %loop
loop:
  %i = phi i64 [ %start, %entry ], [ %next, %body ]
  %end = icmp uge i64 %i, %length
  br i1 %end, label %done, label %body
body:
  %p = getelementptr i8, ptr %data, i64 %i
  %c = load i8, ptr %p
  %space = call i1 @t_whitespace(i8 %c)
  %next = add i64 %i, 1
  br i1 %space, label %loop, label %done
done:
  ret i64 %i
}

define internal i64 @t_parse_name(ptr %data, i64 %length, ptr %offset, ptr %table, i64 %count) {
entry:
  %start = load i64, ptr %offset
  %available = sub i64 %length, %start
  %base = getelementptr i8, ptr %data, i64 %start
  br label %outer
outer:
  %index = phi i64 [ 0, %entry ], [ %nextindex, %advance ]
  %name = phi ptr [ %table, %entry ], [ %nextname, %advance ]
  %done = icmp eq i64 %index, %count
  br i1 %done, label %error, label %setup
setup:
  %namelen = call i64 @j_strlen(ptr %name)
  %short = icmp ult i64 %available, %namelen
  %n = select i1 %short, i64 %available, i64 %namelen
  br label %loop
loop:
  %i = phi i64 [ 0, %setup ], [ %next, %same ]
  %end = icmp eq i64 %i, %n
  br i1 %end, label %checkmatch, label %body
body:
  %ap = getelementptr i8, ptr %base, i64 %i
  %bp = getelementptr i8, ptr %name, i64 %i
  %ac = load i8, ptr %ap
  %bc = load i8, ptr %bp
  %alower = or i8 %ac, 32
  %blower = or i8 %bc, 32
  %eq = icmp eq i8 %alower, %blower
  br i1 %eq, label %same, label %checkmatch
same:
  %next = add i64 %i, 1
  br label %loop
checkmatch:
  %enough = icmp uge i64 %i, 3
  br i1 %enough, label %found, label %advance
found:
  %complete = icmp eq i64 %i, %namelen
  %consumed = select i1 %complete, i64 %namelen, i64 3
  %after = add i64 %start, %consumed
  store i64 %after, ptr %offset
  ret i64 %index
advance:
  %step = add i64 %namelen, 1
  %nextname = getelementptr i8, ptr %name, i64 %step
  %nextindex = add i64 %index, 1
  br label %outer
error:
  ret i64 -1
}

define internal ptr @t_strptime(ptr %input, ptr %format) {
entry:
  %it = call i32 @b_tag(ptr %input)
  %ft = call i32 @b_tag(ptr %format)
  %is = icmp eq i32 %it, 4
  %fs = icmp eq i32 %ft, 4
  %strings = and i1 %is, %fs
  br i1 %strings, label %start, label %typeerror
typeerror:
  call void @j_fail(ptr @t.errstrptime)
  br label %error
start:
  %expanded = call ptr @t_expand(ptr %format)
  %fmt = call ptr @b_data(ptr %expanded)
  %flen = call i64 @b_len(ptr %expanded)
  %data = call ptr @b_data(ptr %input)
  %length = call i64 @b_len(ptr %input)
  %offset = alloca i64
  store i64 0, ptr %offset
  %fields = call ptr @j_alloc(i64 64)
  store i64 1900, ptr %fields
  %ampm = alloca i64
  store i64 -1, ptr %ampm
  br label %loop
loop:
  %i = phi i64 [ 0, %start ], [ %next, %plain ], [ %next, %space ], [ %after, %storefield ], [ %after, %ampmstore ], [ %after, %weekdayname ], [ %after, %specspace ], [ %after, %literalpercent ], [ %after, %zoneskip ]
  %done = icmp uge i64 %i, %flen
  br i1 %done, label %finish, label %body
body:
  %fp = getelementptr i8, ptr %fmt, i64 %i
  %fc = load i8, ptr %fp
  %next = add i64 %i, 1
  %ispercent = icmp eq i8 %fc, 37
  %whitespace = call i1 @t_whitespace(i8 %fc)
  br i1 %ispercent, label %specstart, label %spacecheck
spacecheck:
  br i1 %whitespace, label %space, label %plaincheck
space:
  %spacepos = load i64, ptr %offset
  %spaceafter = call i64 @t_skip_space(ptr %data, i64 %length, i64 %spacepos)
  store i64 %spaceafter, ptr %offset
  br label %loop
plaincheck:
  %pos = load i64, ptr %offset
  %short = icmp uge i64 %pos, %length
  br i1 %short, label %mismatch, label %plainread
plainread:
  %p = getelementptr i8, ptr %data, i64 %pos
  %c = load i8, ptr %p
  %match = icmp eq i8 %c, %fc
  br i1 %match, label %plain, label %mismatch
plain:
  %posnext = add i64 %pos, 1
  store i64 %posnext, ptr %offset
  br label %loop
specstart:
  %missing = icmp uge i64 %next, %flen
  br i1 %missing, label %mismatch, label %specfirst
specfirst:
  %firstspecp = getelementptr i8, ptr %fmt, i64 %next
  %firstspec = load i8, ptr %firstspecp
  %ismodE = icmp eq i8 %firstspec, 69
  %ismodO = icmp eq i8 %firstspec, 79
  %ismod = or i1 %ismodE, %ismodO
  %modskip = zext i1 %ismod to i64
  %specpos = add i64 %next, %modskip
  %sp = getelementptr i8, ptr %fmt, i64 %specpos
  %s = load i8, ptr %sp
  %after = add i64 %specpos, 1
  switch i8 %s, label %mismatch [ i8 89, label %numspec i8 121, label %numspec i8 109, label %numspec i8 100, label %numspec i8 101, label %numspec i8 72, label %numspec i8 73, label %numspec i8 77, label %numspec i8 83, label %numspec i8 106, label %numspec i8 119, label %numspec i8 117, label %numspec i8 65, label %weekdayparse i8 97, label %weekdayparse i8 66, label %monthparse i8 98, label %monthparse i8 104, label %monthparse i8 112, label %ampmparse i8 37, label %percentcheck i8 110, label %specspace i8 116, label %specspace i8 122, label %zoneparse i8 90, label %zonenameparse ]
numspec:
  %before = load i64, ptr %offset
  %clean = call i64 @t_skip_space(ptr %data, i64 %length, i64 %before)
  store i64 %clean, ptr %offset
  %yearspec = icmp eq i8 %s, 89
  %dayspec = icmp eq i8 %s, 106
  %otherwidth = select i1 %dayspec, i64 3, i64 2
  %width = select i1 %yearspec, i64 4, i64 %otherwidth
  %number = call i64 @t_read_uint(ptr %data, i64 %length, ptr %offset, i64 %width)
  %numberbad = icmp slt i64 %number, 0
  br i1 %numberbad, label %mismatch, label %numberdispatch
numberdispatch:
  switch i8 %s, label %second [ i8 89, label %year i8 121, label %year2 i8 109, label %month i8 100, label %day i8 101, label %day i8 72, label %hour i8 73, label %hour i8 77, label %minute i8 106, label %yearday i8 119, label %weekday i8 117, label %weekday ]
year:
  br label %storefield
year2:
  %recent = icmp ule i64 %number, 68
  %century = select i1 %recent, i64 2000, i64 1900
  %full_year = add i64 %century, %number
  br label %storefield
month:
  %monthzero = sub i64 %number, 1
  %monthvalid = icmp ult i64 %monthzero, 12
  br i1 %monthvalid, label %monthstore, label %mismatch
monthstore:
  br label %storefield
day:
  %dayzero = sub i64 %number, 1
  %dayvalid = icmp ult i64 %dayzero, 31
  br i1 %dayvalid, label %daystore, label %mismatch
daystore:
  br label %storefield
hour:
  %hourvalid = icmp ult i64 %number, 24
  br i1 %hourvalid, label %hourstore, label %mismatch
hourstore:
  br label %storefield
minute:
  %minutevalid = icmp ult i64 %number, 60
  br i1 %minutevalid, label %minutestore, label %mismatch
minutestore:
  br label %storefield
second:
  %secondvalid = icmp ult i64 %number, 62
  br i1 %secondvalid, label %secondstore, label %mismatch
secondstore:
  br label %storefield
yearday:
  %monthp = getelementptr i64, ptr %fields, i64 1
  store i64 0, ptr %monthp
  br label %storefield
weekday:
  br label %storefield
monthparse:
  %monthindex = call i64 @t_parse_name(ptr %data, i64 %length, ptr %offset, ptr @t.months, i64 12)
  %monthmissing = icmp slt i64 %monthindex, 0
  br i1 %monthmissing, label %mismatch, label %monthname
monthname:
  br label %storefield
weekdayparse:
  %dayindex = call i64 @t_parse_name(ptr %data, i64 %length, ptr %offset, ptr @t.weekdays, i64 7)
  %daymissing = icmp slt i64 %dayindex, 0
  br i1 %daymissing, label %mismatch, label %weekdayname
weekdayname:
  br label %loop
storefield:
  %fieldindex = phi i64 [ 0, %year ], [ 0, %year2 ], [ 1, %monthstore ], [ 2, %daystore ], [ 3, %hourstore ], [ 4, %minutestore ], [ 5, %secondstore ], [ 2, %yearday ], [ 6, %weekday ], [ 1, %monthname ]
  %fieldvalue = phi i64 [ %number, %year ], [ %full_year, %year2 ], [ %monthzero, %monthstore ], [ %number, %daystore ], [ %number, %hourstore ], [ %number, %minutestore ], [ %number, %secondstore ], [ %number, %yearday ], [ %number, %weekday ], [ %monthindex, %monthname ]
  %fieldp = getelementptr i64, ptr %fields, i64 %fieldindex
  store i64 %fieldvalue, ptr %fieldp
  br label %loop
ampmparse:
  %ap = load i64, ptr %offset
  %apend = add i64 %ap, 2
  %apshort = icmp ugt i64 %apend, %length
  br i1 %apshort, label %mismatch, label %ampmread
ampmread:
  %amp = getelementptr i8, ptr %data, i64 %ap
  %mmp = getelementptr i8, ptr %amp, i64 1
  %a = load i8, ptr %amp
  %m = load i8, ptr %mmp
  %alower = or i8 %a, 32
  %mlower = or i8 %m, 32
  %isam = icmp eq i8 %alower, 97
  %ispm = icmp eq i8 %alower, 112
  %ism = icmp eq i8 %mlower, 109
  %apvalid = or i1 %isam, %ispm
  %ampmvalid = and i1 %apvalid, %ism
  br i1 %ampmvalid, label %ampmstore, label %mismatch
ampmstore:
  %half = zext i1 %ispm to i64
  store i64 %half, ptr %ampm
  store i64 %apend, ptr %offset
  br label %loop
specspace:
  %ss = load i64, ptr %offset
  %ssend = call i64 @t_skip_space(ptr %data, i64 %length, i64 %ss)
  store i64 %ssend, ptr %offset
  br label %loop
percentcheck:
  %ppos = load i64, ptr %offset
  %pshort = icmp uge i64 %ppos, %length
  br i1 %pshort, label %mismatch, label %percentread
percentread:
  %pp = getelementptr i8, ptr %data, i64 %ppos
  %pc = load i8, ptr %pp
  %pvalid = icmp eq i8 %pc, 37
  br i1 %pvalid, label %literalpercent, label %mismatch
literalpercent:
  %pend = add i64 %ppos, 1
  store i64 %pend, ptr %offset
  br label %loop
zoneparse:
  %zs = load i64, ptr %offset
  %zshort = icmp uge i64 %zs, %length
  br i1 %zshort, label %mismatch, label %zoneread
zoneread:
  %zp = getelementptr i8, ptr %data, i64 %zs
  %zc = load i8, ptr %zp
  %zulu = icmp eq i8 %zc, 90
  %znext = add i64 %zs, 1
  store i64 %znext, ptr %offset
  br i1 %zulu, label %zoneskip, label %zonesign
zonesign:
  %plus = icmp eq i8 %zc, 43
  %minus = icmp eq i8 %zc, 45
  %signed = or i1 %plus, %minus
  br i1 %signed, label %zonehour, label %mismatch
zonehour:
  %zh = call i64 @t_read_uint(ptr %data, i64 %length, ptr %offset, i64 2)
  %zhvalid = icmp ult i64 %zh, 24
  br i1 %zhvalid, label %zonecolon, label %mismatch
zonecolon:
  %zmid = load i64, ptr %offset
  %zmp = getelementptr i8, ptr %data, i64 %zmid
  %zmc = load i8, ptr %zmp
  %zcolon = icmp eq i8 %zmc, 58
  %zskip = zext i1 %zcolon to i64
  %zmstart = add i64 %zmid, %zskip
  store i64 %zmstart, ptr %offset
  %zm = call i64 @t_read_uint(ptr %data, i64 %length, ptr %offset, i64 2)
  %zmvalid = icmp ult i64 %zm, 60
  br i1 %zmvalid, label %zoneskip, label %mismatch
zonenameparse:
  %znstart = load i64, ptr %offset
  br label %znloop
znloop:
  %zi = phi i64 [ %znstart, %zonenameparse ], [ %zinext, %znbody ]
  %zend = icmp uge i64 %zi, %length
  br i1 %zend, label %znend, label %znbody
znbody:
  %znp = getelementptr i8, ptr %data, i64 %zi
  %znc = load i8, ptr %znp
  %znlower = or i8 %znc, 32
  %zndiff = sub i8 %znlower, 97
  %znalpha = icmp ult i8 %zndiff, 26
  %zinext = add i64 %zi, 1
  br i1 %znalpha, label %znloop, label %znend
znend:
  store i64 %zi, ptr %offset
  br label %zoneskip
zoneskip:
  br label %loop
finish:
  %stop = load i64, ptr %offset
  %all = icmp eq i64 %stop, %length
  br i1 %all, label %build, label %tailcheck
tailcheck:
  %tailp = getelementptr i8, ptr %data, i64 %stop
  %tailc = load i8, ptr %tailp
  %tailspace = call i1 @t_whitespace(i8 %tailc)
  br i1 %tailspace, label %build, label %mismatch
build:
  %halfday = load i64, ptr %ampm
  %hashalf = icmp sge i64 %halfday, 0
  %hourp = getelementptr i64, ptr %fields, i64 3
  %rawhour = load i64, ptr %hourp
  %hmod = urem i64 %rawhour, 12
  %halfadd = mul i64 %halfday, 12
  %withhalf = add i64 %hmod, %halfadd
  %hourvalue = select i1 %hashalf, i64 %withhalf, i64 %rawhour
  store i64 %hourvalue, ptr %hourp
  %initial = call ptr @j_array()
  br label %fieldloop
fieldloop:
  %f = phi i64 [ 0, %build ], [ %fn, %fieldbody ]
  %fdone = icmp eq i64 %f, 6
  br i1 %fdone, label %normalize, label %fieldbody
fieldbody:
  %vp = getelementptr i64, ptr %fields, i64 %f
  %v = load i64, ptr %vp
  call void @t_push_int(ptr %initial, i64 %v)
  %fn = add i64 %f, 1
  br label %fieldloop
normalize:
  %epochvalue = call double @t_mktime(ptr %initial)
  %result = call ptr @t_gmtime(double %epochvalue)
  br i1 %all, label %parsedone, label %appendtail
appendtail:
  %remaining = sub i64 %length, %stop
  %remainingp = getelementptr i8, ptr %data, i64 %stop
  %remainder = call ptr @j_str(ptr %remainingp, i64 %remaining)
  call void @j_push(ptr %result, ptr %remainder)
  br label %parsedone
parsedone:
  ret ptr %result
mismatch:
  %errbuffer = call ptr @j_buffer_new()
  call void @j_buffer_append(ptr %errbuffer, ptr @t.dateprefix, i64 6)
  %inputdata = call ptr @b_data(ptr %input)
  %inputlen = call i64 @b_len(ptr %input)
  call void @j_buffer_append(ptr %errbuffer, ptr %inputdata, i64 %inputlen)
  call void @j_buffer_append(ptr %errbuffer, ptr @t.datebetween, i64 25)
  %formatdata = call ptr @b_data(ptr %format)
  %formatlen = call i64 @b_len(ptr %format)
  call void @j_buffer_append(ptr %errbuffer, ptr %formatdata, i64 %formatlen)
  call void @j_buffer_byte(ptr %errbuffer, i8 34)
  %message = call ptr @j_buffer_value(ptr %errbuffer)
  store ptr %message, ptr @j_error
  br label %error
error:
  %null = call ptr @j_null()
  ret ptr %null
}

define i1 @j_time_known(ptr %name, i64 %arity) {
  %id = call i32 @b_find(ptr %name, ptr @t.names)
  %found = icmp sge i32 %id, 0
  %above = icmp sge i32 %id, 4
  %below = icmp sle i32 %id, 6
  %argument = and i1 %above, %below
  %expected = zext i1 %argument to i64
  %same = icmp eq i64 %arity, %expected
  %known = and i1 %found, %same
  ret i1 %known
}

define ptr @j_time_names() {
  ret ptr @t.names
}
