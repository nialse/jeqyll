%TE = type { ptr, i64, i64, i1, i1 }

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
@t.posixrules = private constant [31 x i8] c"/usr/share/zoneinfo/posixrules\00"
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
declare ptr @j_alloc_permanent(i64)
declare ptr @j_posix_timezone(ptr, double)
declare i1 @j_tzif_valid(ptr, i64)
declare ptr @j_locale_item(i64, ptr)
declare i64 @j_locale_parse(ptr, i64, ptr, i64, i64, i64)
declare ptr @j_locale_alt_digit(i64)
declare i64 @j_locale_parse_digit(ptr, i64, ptr)
declare ptr @j_locale_era_at(i64)
declare ptr @j_locale_era_for(i64, i64, i64)
declare i64 @j_locale_era_year(ptr, i64, i1)
declare i1 @j_locale_era_year_valid(ptr, i64)
declare ptr @j_locale_era_text(ptr, i1)
declare i1 @j_locale_match_name(ptr, ptr, i64, ptr)
declare i64 @j_time_iso_week(i64, i64, i64, ptr)
declare ptr @t_ascii(ptr, i1)
declare ptr @j_null()
declare ptr @j_bool(i1)
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
declare ptr @j_read_file(ptr)
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

define i64 @t_days(i64 %year, i64 %month, i64 %day) {
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

define ptr @t_gmtime(double %seconds) {
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
  %below = fcmp olt double %seconds, %integerfloat
  %adjust = uitofp i1 %below to double
  %floored = fsub double %integerfloat, %adjust
  %fraction = fsub double %seconds, %floored
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

define i64 @t_field(ptr %array, i64 %index) {
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
  %timevalidlow = fcmp oge double %seconds, -6.0e16
  %timevalidhigh = fcmp ole double %seconds, 6.0e16
  %timevalid = and i1 %timevalidlow, %timevalidhigh
  br i1 %timevalid, label %cachecheck, label %timeerror
timeerror:
  call void @j_fail(ptr @t.errdate)
  ret i64 0
cachecheck:
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
  br i1 %colon, label %zonepath, label %posixzone
posixzone:
  %posix = call ptr @j_posix_timezone(ptr %zone, double %seconds)
  %hasposix = icmp ne ptr %posix, null
  br i1 %hasposix, label %posixresult, label %zonepath
posixresult:
  %posixoffset = load i64, ptr %posix
  %posixnamep = getelementptr i8, ptr %posix, i64 8
  %posixname = load ptr, ptr %posixnamep
  store ptr %posixname, ptr @t.zone_name
  store i64 %posixoffset, ptr @t.zone_offset
  ret i64 %posixoffset
zonepath:
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
  %savederror = load ptr, ptr @j_error
  %filevalue = call ptr @j_read_file(ptr %path)
  store ptr %savederror, ptr @j_error
  %unreadable = icmp eq ptr %filevalue, null
  br i1 %unreadable, label %error, label %readfile
readfile:
  %bytes = call ptr @b_data(ptr %filevalue)
  %size_read = call i64 @b_len(ptr %filevalue)
  %short = icmp slt i64 %size_read, 44
  br i1 %short, label %error, label %validatefile
validatefile:
  %validfile = call i1 @j_tzif_valid(ptr %bytes, i64 %size_read)
  br i1 %validfile, label %save, label %error
save:
  %durablebytes = call ptr @j_alloc_permanent(i64 %size_read)
  call void @j_copy(ptr %durablebytes, ptr %bytes, i64 %size_read)
  store ptr %durablebytes, ptr @t.zone_data
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
  %hasfooter = icmp eq i64 %width, 8
  br i1 %hasfooter, label %footercheck, label %transstart
footercheck:
  %notransitions = icmp eq i64 %ntimes, 0
  br i1 %notransitions, label %footerread, label %lasttransition
lasttransition:
  %lastindex = sub i64 %ntimes, 1
  %lastoffset = mul i64 %lastindex, 8
  %lastptr = getelementptr i8, ptr %transitions, i64 %lastoffset
  %lasttime = call i64 @t_be(ptr %lastptr, i64 8)
  %pastlast = icmp sge i64 %epoch, %lasttime
  br i1 %pastlast, label %footerread, label %transstart
footerread:
  %filesize = load i64, ptr @t.zone_size
  %footer = call ptr @t_zone_footer(ptr %data, i64 %filesize)
  %footerexists = icmp ne ptr %footer, null
  br i1 %footerexists, label %footerevaluate, label %transstart
footerevaluate:
  %footervalue = call ptr @j_posix_timezone(ptr %footer, double %seconds)
  %footerok = icmp ne ptr %footervalue, null
  br i1 %footerok, label %footerresult, label %transstart
footerresult:
  %footoffset = load i64, ptr %footervalue
  %footnamep = getelementptr i8, ptr %footervalue, i64 8
  %footname = load ptr, ptr %footnamep
  store ptr %footname, ptr @t.zone_name
  store i64 %footoffset, ptr @t.zone_offset
  ret i64 %footoffset
transstart:
  br label %transloop
transloop:
  %i = phi i64 [ 0, %transstart ], [ %next, %take ]
  %index = phi i64 [ 0, %transstart ], [ %typeindex, %take ]
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

define internal ptr @t_zone_footer(ptr %data, i64 %length) {
entry:
  %long = icmp uge i64 %length, 46
  br i1 %long, label %check, label %missing
check:
  %last = sub i64 %length, 1
  %lastp = getelementptr i8, ptr %data, i64 %last
  %lastchar = load i8, ptr %lastp
  %newline = icmp eq i8 %lastchar, 10
  br i1 %newline, label %loop, label %missing
loop:
  %i = phi i64 [%last, %check], [%previous, %read]
  %more = icmp ugt i64 %i, 44
  br i1 %more, label %read, label %missing
read:
  %previous = sub i64 %i, 1
  %p = getelementptr i8, ptr %data, i64 %previous
  %c = load i8, ptr %p
  %found = icmp eq i8 %c, 10
  br i1 %found, label %result, label %loop
result:
  %n = sub i64 %last, %i
  %text = getelementptr i8, ptr %data, i64 %i
  %footer = call ptr @j_str(ptr %text, i64 %n)
  ret ptr %footer
missing:
  ret ptr null
}

define ptr @j_posix_default_rules() {
entry:
  %savederror = load ptr, ptr @j_error
  %filevalue = call ptr @j_read_file(ptr @t.posixrules)
  store ptr %savederror, ptr @j_error
  %failed = icmp eq ptr %filevalue, null
  br i1 %failed, label %missing, label %read
read:
  %buffer = call ptr @b_data(ptr %filevalue)
  %n = call i64 @b_len(ptr %filevalue)
  %valid = call i1 @j_tzif_valid(ptr %buffer, i64 %n)
  br i1 %valid, label %footer, label %missing
footer:
  %text = call ptr @t_zone_footer(ptr %buffer, i64 %n)
  %hastext = icmp ne ptr %text, null
  br i1 %hastext, label %start, label %missing
start:
  %bytes = call ptr @b_data(ptr %text)
  %length = call i64 @b_len(ptr %text)
  br label %loop
loop:
  %i = phi i64 [0, %start], [%next, %body]
  %more = icmp ult i64 %i, %length
  br i1 %more, label %body, label %missing
body:
  %p = getelementptr i8, ptr %bytes, i64 %i
  %c = load i8, ptr %p
  %comma = icmp eq i8 %c, 44
  %next = add i64 %i, 1
  br i1 %comma, label %result, label %loop
result:
  %suffixlength = sub i64 %length, %i
  %suffix = call ptr @j_str(ptr %p, i64 %suffixlength)
  ret ptr %suffix
missing:
  ret ptr null
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
  %result = call ptr @t_expand_depth(ptr %format, i64 0)
  ret ptr %result
}

define internal ptr @t_expand_depth(ptr %format, i64 %depth) {
entry:
  %data = call ptr @b_data(ptr %format)
  %len = call i64 @b_len(ptr %format)
  %buffer = call ptr @j_buffer_new()
  br label %loop
loop:
  %i = phi i64 [ 0, %entry ], [ %next, %plain ], [ %after, %copy ], [ %after, %expandnested ]
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
  %firstspec = load i8, ptr %sp
  %isera = icmp eq i8 %firstspec, 69
  %thirdindex = add i64 %i, 2
  %hasthird = icmp ult i64 %thirdindex, %len
  %eraspec = and i1 %isera, %hasthird
  br i1 %eraspec, label %eraspecifier, label %plainspecifier
eraspecifier:
  %thirdp = getelementptr i8, ptr %data, i64 %thirdindex
  %thirdspec = load i8, ptr %thirdp
  br label %specifier
plainspecifier:
  br label %specifier
specifier:
  %s = phi i8 [%thirdspec, %eraspecifier], [%firstspec, %plainspecifier]
  %directivewidth = select i1 %eraspec, i64 3, i64 2
  %after = add i64 %i, %directivewidth
  switch i8 %s, label %copy [ i8 70, label %date i8 84, label %clock i8 82, label %shortclock i8 68, label %slashdate i8 120, label %slashdate i8 88, label %clock i8 99, label %cformat i8 114, label %rformat ]
copy:
  call void @j_buffer_append(ptr %buffer, ptr %p, i64 %directivewidth)
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
  %fallback = phi ptr [ @t.date, %date ], [ @t.clock, %clock ], [ @t.shortclock, %shortclock ], [ @t.slashdate, %slashdate ], [ @t.cformat, %cformat ], [ @t.rformat, %rformat ]
  %isx = icmp eq i8 %s, 120
  %isX = icmp eq i8 %s, 88
  %isc = icmp eq i8 %s, 99
  %isr = icmp eq i8 %s, 114
  %ix0 = select i1 %isx, i64 41, i64 -1
  %ix1 = select i1 %isX, i64 42, i64 %ix0
  %ix2 = select i1 %isc, i64 40, i64 %ix1
  %item = select i1 %isr, i64 43, i64 %ix2
  %normaltext = call ptr @j_locale_item(i64 %item, ptr %fallback)
  %normalfirst = load i8, ptr %normaltext
  %normalempty = icmp eq i8 %normalfirst, 0
  %normalvalue = select i1 %normalempty, ptr %fallback, ptr %normaltext
  %eraix0 = select i1 %isx, i64 46, i64 -1
  %eraix1 = select i1 %isX, i64 49, i64 %eraix0
  %eraix2 = select i1 %isc, i64 48, i64 %eraix1
  %eraindex = select i1 %eraspec, i64 %eraix2, i64 -1
  %eratext = call ptr @j_locale_item(i64 %eraindex, ptr %normalvalue)
  %erafirst = load i8, ptr %eratext
  %eraempty = icmp eq i8 %erafirst, 0
  %text = select i1 %eraempty, ptr %normalvalue, ptr %eratext
  %nestedformat = call ptr @j_cstr(ptr %text)
  %nextdepth = add i64 %depth, 1
  %deep = icmp uge i64 %depth, 32
  br i1 %deep, label %expanddeep, label %expandnested
expanddeep:
  call void @j_fail(ptr @t.errformat)
  br label %end
expandnested:
  %nested = call ptr @t_expand_depth(ptr %nestedformat, i64 %nextdepth)
  %nesteddata = call ptr @b_data(ptr %nested)
  %nestedlength = call i64 @b_len(ptr %nested)
  call void @j_buffer_append(ptr %buffer, ptr %nesteddata, i64 %nestedlength)
  br label %loop
end:
  %out = call ptr @j_buffer_value(ptr %buffer)
  ret ptr %out
}

define internal ptr @t_format(ptr %array, ptr %format, double %epochseconds, i1 %local) {
entry:
  %result = call ptr @t_format_depth(ptr %array, ptr %format, double %epochseconds, i1 %local, i64 0)
  ret ptr %result
}

define internal ptr @t_format_depth(ptr %array, ptr %format, double %epochseconds, i1 %local, i64 %depth) {
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
  %weekyearslot = alloca i64
  %isoweekvalue = call i64 @j_time_iso_week(i64 %yearvalue, i64 %yearday0, i64 %weekdayvalue, ptr %weekyearslot)
  %isoyearvalue = load i64, ptr %weekyearslot
  %era = call ptr @j_locale_era_for(i64 %yearvalue, i64 %month0, i64 %dayvalue)
  %hasera = icmp ne ptr %era, null
  br label %loop
loop:
  %i = phi i64 [ 0, %entry ], [ %next, %plain ], [ %after, %numericplain ], [ %after, %numericlocalized ], [ %after, %text ], [ %after, %single ], [ %after, %zone ], [ %after, %unsupported ]
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
  %alternative = phi i1 [false, %specstart], [%newalternative, %modifier]
  %eramodifier = phi i1 [false, %specstart], [%neweramodifier, %modifier]
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
  %newalternative = or i1 %alternative, %ismod2
  %neweramodifier = or i1 %eramodifier, %ismod1
  br label %modifiers
dispatch:
  %after = add i64 %position, 1
  %useera = and i1 %hasera, %eramodifier
  br i1 %useera, label %eradispatch, label %normaldispatch
eradispatch:
  switch i8 %s, label %normaldispatch [i8 67, label %eraname i8 121, label %erayear i8 89, label %erafull]
eraname:
  %eranametext = call ptr @j_locale_era_text(ptr %era, i1 false)
  %eranamelen = call i64 @j_strlen(ptr %eranametext)
  br label %text
erayear:
  %erayearvalue = call i64 @j_locale_era_year(ptr %era, i64 %yearvalue, i1 false)
  br label %numeric
erafull:
  %eratoodeep = icmp uge i64 %depth, 32
  br i1 %eratoodeep, label %eradeep, label %eraexpand
eradeep:
  call void @j_fail(ptr @t.errformat)
  br label %end
eraexpand:
  %eraformattext = call ptr @j_locale_era_text(ptr %era, i1 true)
  %eraformat = call ptr @j_cstr(ptr %eraformattext)
  %eranextdepth = add i64 %depth, 1
  %eraformatted = call ptr @t_format_depth(ptr %array, ptr %eraformat, double %epochseconds, i1 %local, i64 %eranextdepth)
  %eraformatteddata = call ptr @b_data(ptr %eraformatted)
  %eraformattedlen = call i64 @b_len(ptr %eraformatted)
  br label %text
normaldispatch:
  switch i8 %s, label %unsupported [ i8 89, label %year i8 121, label %year2 i8 67, label %century i8 109, label %month i8 100, label %day i8 101, label %dayblank i8 72, label %hour i8 107, label %hourblank i8 73, label %hour12 i8 108, label %hour12 i8 77, label %minute i8 83, label %second i8 106, label %yearday i8 119, label %weekday i8 117, label %isoweekday i8 65, label %weekdayname i8 97, label %weekdayname i8 66, label %monthname i8 98, label %monthname i8 104, label %monthname i8 112, label %ampm i8 80, label %ampm i8 90, label %zonename i8 122, label %zone i8 115, label %epoch i8 37, label %literalpercent i8 110, label %newline i8 116, label %tab i8 85, label %week_sunday i8 87, label %week_monday i8 86, label %iso_week i8 71, label %iso_year i8 103, label %iso_year2 ]
iso_week:
  br label %numeric
iso_year:
  br label %numeric
iso_year2:
  %iy2 = srem i64 %isoyearvalue, 100
  br label %numeric
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
  %n = phi i64 [ %yearvalue, %year ], [ %y2, %year2 ], [ %cent, %century ], [ %monthvalue, %month ], [ %dayvalue, %day ], [ %dayvalue, %dayblank ], [ %hourvalue, %hour ], [ %hourvalue, %hourblank ], [ %h12, %hour12 ], [ %minutevalue, %minute ], [ %secondvalue, %second ], [ %yeardayvalue, %yearday ], [ %weekdayvalue, %weekday ], [ %iso, %isoweekday ], [ %timestamp, %epoch ], [ %wsunday, %week_sunday ], [ %wmonday, %week_monday ], [%isoweekvalue, %iso_week], [%isoyearvalue, %iso_year], [%iy2, %iso_year2], [%erayearvalue, %erayear]
  %width = phi i64 [ 4, %year ], [ 2, %year2 ], [ 2, %century ], [ 2, %month ], [ 2, %day ], [ 2, %dayblank ], [ 2, %hour ], [ 2, %hourblank ], [ 2, %hour12 ], [ 2, %minute ], [ 2, %second ], [ 3, %yearday ], [ 1, %weekday ], [ 1, %isoweekday ], [ 1, %epoch ], [ 2, %week_sunday ], [ 2, %week_monday ], [2, %iso_week], [4, %iso_year], [2, %iso_year2], [2, %erayear]
  %defaultpad = phi i8 [ %padding, %year ], [ %padding, %year2 ], [ %padding, %century ], [ %padding, %month ], [ %padding, %day ], [ 32, %dayblank ], [ %padding, %hour ], [ 32, %hourblank ], [ %padding, %hour12 ], [ %padding, %minute ], [ %padding, %second ], [ %padding, %yearday ], [ %padding, %weekday ], [ %padding, %isoweekday ], [ %padding, %epoch ], [ %padding, %week_sunday ], [ %padding, %week_monday ], [%padding, %iso_week], [%padding, %iso_year], [%padding, %iso_year2], [%padding, %erayear]
  %effectivewidth = select i1 %nopad, i64 1, i64 %width
  br i1 %alternative, label %numericlookup, label %numericplain
numericlookup:
  %alttext = call ptr @j_locale_alt_digit(i64 %n)
  %hasalt = icmp ne ptr %alttext, null
  br i1 %hasalt, label %numericlocalized, label %numericplain
numericlocalized:
  %altlength = call i64 @j_strlen(ptr %alttext)
  call void @j_buffer_append(ptr %buffer, ptr %alttext, i64 %altlength)
  br label %loop
numericplain:
  call void @t_uint(ptr %buffer, i64 %n, i64 %effectivewidth, i8 %defaultpad)
  br label %loop
weekdayname:
  %wfallback = call ptr @t_name(ptr @t.weekdays, i64 %weekdayvalue)
  %wfull = call i64 @j_strlen(ptr %wfallback)
  %wshort = icmp eq i8 %s, 97
  %wfalllen = select i1 %wshort, i64 3, i64 %wfull
  %wfallstr = call ptr @j_str(ptr %wfallback, i64 %wfalllen)
  %wfallptr = call ptr @b_data(ptr %wfallstr)
  %witembase = select i1 %wshort, i64 0, i64 7
  %windex = add i64 %witembase, %weekdayvalue
  %wname = call ptr @j_locale_item(i64 %windex, ptr %wfallptr)
  %wlen = call i64 @j_strlen(ptr %wname)
  br label %text
monthname:
  %mfallback = call ptr @t_name(ptr @t.months, i64 %month0)
  %mfull = call i64 @j_strlen(ptr %mfallback)
  %mlong = icmp eq i8 %s, 66
  %mfalllen = select i1 %mlong, i64 %mfull, i64 3
  %mfallstr = call ptr @j_str(ptr %mfallback, i64 %mfalllen)
  %mfallptr = call ptr @b_data(ptr %mfallstr)
  %mbase = select i1 %mlong, i64 26, i64 14
  %mindex = add i64 %mbase, %month0
  %mname = call ptr @j_locale_item(i64 %mindex, ptr %mfallptr)
  %mlen = call i64 @j_strlen(ptr %mname)
  br label %text
ampm:
  %pm = icmp uge i64 %hourvalue, 12
  %ampfallback = select i1 %pm, ptr @t.pm, ptr @t.am
  %ampitem = select i1 %pm, i64 39, i64 38
  %amplocal = call ptr @j_locale_item(i64 %ampitem, ptr %ampfallback)
  %ampstring = call ptr @j_cstr(ptr %amplocal)
  %amplower = call ptr @t_ascii(ptr %ampstring, i1 false)
  %amplowerdata = call ptr @b_data(ptr %amplower)
  %isloweramp = icmp eq i8 %s, 80
  %apname = select i1 %isloweramp, ptr %amplowerdata, ptr %amplocal
  %amplen = call i64 @j_strlen(ptr %apname)
  br label %text
zonename:
  %localname = load ptr, ptr @t.zone_name
  %zname = select i1 %local, ptr %localname, ptr @t.UTC
  %zlen = call i64 @j_strlen(ptr %zname)
  br label %text
text:
  %textdata = phi ptr [ %wname, %weekdayname ], [ %mname, %monthname ], [ %apname, %ampm ], [ %zname, %zonename ], [%eranametext, %eraname], [%eraformatteddata, %eraexpand]
  %textlen = phi i64 [ %wlen, %weekdayname ], [ %mlen, %monthname ], [ %amplen, %ampm ], [ %zlen, %zonename ], [%eranamelen, %eraname], [%eraformattedlen, %eraexpand]
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
  %unsupportedlength = sub i64 %after, %i
  call void @j_buffer_append(ptr %buffer, ptr %p, i64 %unsupportedlength)
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
  %fields = call ptr @j_alloc(i64 64)
  store i64 1900, ptr %fields
  %offset = alloca i64
  store i64 0, ptr %offset
  %ampm = alloca i64
  store i64 -1, ptr %ampm
  %eras = call ptr @j_alloc(i64 32)
  %centuryp = getelementptr %TE, ptr %eras, i32 0, i32 2
  store i64 -1, ptr %centuryp
  %result = call ptr @t_strptime_depth(ptr %input, ptr %format, ptr %fields, ptr %ampm, ptr %eras, ptr %offset, i64 0, i1 false)
  ret ptr %result
}

define internal ptr @t_strptime_depth(ptr %input, ptr %format, ptr %fields, ptr %ampm, ptr %eras, ptr %offset, i64 %depth, i1 %fragment) {
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
  %erayearp = getelementptr %TE, ptr %eras, i32 0, i32 1
  %centuryp = getelementptr %TE, ptr %eras, i32 0, i32 2
  %haserayearp = getelementptr %TE, ptr %eras, i32 0, i32 3
  %wantcenturyp = getelementptr %TE, ptr %eras, i32 0, i32 4
  br label %loop
loop:
  %i = phi i64 [ 0, %start ], [ %next, %plain ], [ %next, %space ], [ %after, %storefield ], [ %after, %ampmcontinue ], [ %after, %weekdayname ], [ %after, %specspace ], [ %after, %literalpercent ], [ %after, %zoneskip ], [%after, %eranamestored], [%after, %erayearstored], [%after, %erafullmatched], [%after, %centurystored]
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
  br i1 %ismodE, label %eradispatch, label %normaldispatch
eradispatch:
  switch i8 %s, label %normaldispatch [i8 67, label %eranameparse i8 121, label %erayearparse i8 89, label %erafullparse]
eranameparse:
  %knownera = load ptr, ptr %eras
  %hasknownera = icmp ne ptr %knownera, null
  br i1 %hasknownera, label %eranameknown, label %eranameloop
eranameknown:
  %knownname = call ptr @j_locale_era_text(ptr %knownera, i1 false)
  %knownmatch = call i1 @j_locale_match_name(ptr %knownname, ptr %data, i64 %length, ptr %offset)
  br i1 %knownmatch, label %eranamestored, label %mismatch
eranameloop:
  %erani = phi i64 [0, %eranameparse], [%erannext, %eranamenext]
  %nameera = call ptr @j_locale_era_at(i64 %erani)
  %nameerapresent = icmp ne ptr %nameera, null
  br i1 %nameerapresent, label %eranamecandidate, label %numspec
eranamecandidate:
  %candidatename = call ptr @j_locale_era_text(ptr %nameera, i1 false)
  %candidatematch = call i1 @j_locale_match_name(ptr %candidatename, ptr %data, i64 %length, ptr %offset)
  br i1 %candidatematch, label %eranamestored, label %eranamenext
eranamenext:
  %erannext = add i64 %erani, 1
  br label %eranameloop
eranamestored:
  %namedrecord = phi ptr [%knownera, %eranameknown], [%nameera, %eranamecandidate]
  store ptr %namedrecord, ptr %eras
  br label %loop
erayearparse:
  %existingera = load ptr, ptr %eras
  %existingpresent = icmp ne ptr %existingera, null
  %firstera = call ptr @j_locale_era_at(i64 0)
  %firstpresent = icmp ne ptr %firstera, null
  %anyera = or i1 %existingpresent, %firstpresent
  br i1 %anyera, label %erayearread, label %numspec
erayearread:
  %eraoffset0 = load i64, ptr %offset
  %eraclean = call i64 @t_skip_space(ptr %data, i64 %length, i64 %eraoffset0)
  store i64 %eraclean, ptr %offset
  %parsedyear = call i64 @t_read_uint(ptr %data, i64 %length, ptr %offset, i64 4)
  %parsedyearvalid = icmp sge i64 %parsedyear, 0
  br i1 %parsedyearvalid, label %erayearloop, label %mismatch
erayearloop:
  %erayi = phi i64 [0, %erayearread], [%eraynext, %erayearnext]
  %enumeratedera = call ptr @j_locale_era_at(i64 %erayi)
  %yearera = select i1 %existingpresent, ptr %existingera, ptr %enumeratedera
  %yearerapresent = icmp ne ptr %yearera, null
  br i1 %yearerapresent, label %erayearcandidate, label %mismatch
erayearcandidate:
  %candidateyear = call i64 @j_locale_era_year(ptr %yearera, i64 %parsedyear, i1 true)
  %yearvalid = call i1 @j_locale_era_year_valid(ptr %yearera, i64 %candidateyear)
  br i1 %yearvalid, label %erayearstored, label %erayearreject
erayearreject:
  br i1 %existingpresent, label %mismatch, label %erayearnext
erayearnext:
  %eraynext = add i64 %erayi, 1
  br label %erayearloop
erayearstored:
  store ptr %yearera, ptr %eras
  store i64 %parsedyear, ptr %erayearp
  store i1 true, ptr %haserayearp
  br label %loop
erafullparse:
  %erafulltoodeep = icmp uge i64 %depth, 32
  br i1 %erafulltoodeep, label %mismatch, label %erafullsave
erafullsave:
  %savedfields = call ptr @j_alloc(i64 64)
  %savederas = call ptr @j_alloc(i64 32)
  call void @j_copy(ptr %savedfields, ptr %fields, i64 64)
  call void @j_copy(ptr %savederas, ptr %eras, i64 32)
  %savedoffset = load i64, ptr %offset
  %savedampm = load i64, ptr %ampm
  %nextdepth = add i64 %depth, 1
  br label %erafullcandidate
erafullcandidate:
  %erafi = phi i64 [0, %erafullsave], [%erafnext, %erafullnext]
  call void @j_copy(ptr %fields, ptr %savedfields, i64 64)
  call void @j_copy(ptr %eras, ptr %savederas, i64 32)
  store i64 %savedoffset, ptr %offset
  store i64 %savedampm, ptr %ampm
  %fullera = call ptr @j_locale_era_at(i64 %erafi)
  %fullerapresent = icmp ne ptr %fullera, null
  br i1 %fullerapresent, label %erafulltry, label %numspec
erafulltry:
  store ptr %fullera, ptr %eras
  %erafmttext = call ptr @j_locale_era_text(ptr %fullera, i1 true)
  %erafmtfirst = load i8, ptr %erafmttext
  %erafmtnonempty = icmp ne i8 %erafmtfirst, 0
  br i1 %erafmtnonempty, label %erafullrecurse, label %erafullnext
erafullrecurse:
  %erafmt = call ptr @j_cstr(ptr %erafmttext)
  %erafullresult = call ptr @t_strptime_depth(ptr %input, ptr %erafmt, ptr %fields, ptr %ampm, ptr %eras, ptr %offset, i64 %nextdepth, i1 true)
  %erafullsuccess = icmp ne ptr %erafullresult, null
  br i1 %erafullsuccess, label %erafullmatched, label %erafullnext
erafullnext:
  %erafnext = add i64 %erafi, 1
  br label %erafullcandidate
erafullmatched:
  br label %loop
normaldispatch:
  switch i8 %s, label %mismatch [ i8 89, label %numspec i8 121, label %numspec i8 67, label %numspec i8 109, label %numspec i8 100, label %numspec i8 101, label %numspec i8 72, label %numspec i8 73, label %numspec i8 77, label %numspec i8 83, label %numspec i8 106, label %numspec i8 119, label %numspec i8 117, label %numspec i8 65, label %weekdayparse i8 97, label %weekdayparse i8 66, label %monthparse i8 98, label %monthparse i8 104, label %monthparse i8 112, label %ampmparse i8 37, label %percentcheck i8 110, label %specspace i8 116, label %specspace i8 122, label %zoneparse i8 90, label %zonenameparse ]
numspec:
  %before = load i64, ptr %offset
  %clean = call i64 @t_skip_space(ptr %data, i64 %length, i64 %before)
  store i64 %clean, ptr %offset
  %yearspec = icmp eq i8 %s, 89
  %dayspec = icmp eq i8 %s, 106
  %otherwidth = select i1 %dayspec, i64 3, i64 2
  %width = select i1 %yearspec, i64 4, i64 %otherwidth
  br i1 %ismodO, label %alternatenumber, label %ordinarynumber
alternatenumber:
  %localizednumber = call i64 @j_locale_parse_digit(ptr %data, i64 %length, ptr %offset)
  %haslocalizednumber = icmp sge i64 %localizednumber, 0
  br i1 %haslocalizednumber, label %numbercheck, label %ordinarynumber
ordinarynumber:
  %plainnumber = call i64 @t_read_uint(ptr %data, i64 %length, ptr %offset, i64 %width)
  br label %numbercheck
numbercheck:
  %number = phi i64 [%localizednumber, %alternatenumber], [%plainnumber, %ordinarynumber]
  %numberbad = icmp slt i64 %number, 0
  br i1 %numberbad, label %mismatch, label %numberdispatch
numberdispatch:
  switch i8 %s, label %second [ i8 89, label %year i8 121, label %year2 i8 67, label %centurystored i8 109, label %month i8 100, label %day i8 101, label %day i8 72, label %hour i8 73, label %hour i8 77, label %minute i8 106, label %yearday i8 119, label %weekday i8 117, label %weekday ]
centurystored:
  store i64 %number, ptr %centuryp
  br label %loop
year:
  store i1 false, ptr %wantcenturyp
  br label %storefield
year2:
  store i1 true, ptr %wantcenturyp
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
  %localmonth = call i64 @j_locale_parse(ptr %data, i64 %length, ptr %offset, i64 26, i64 12, i64 14)
  %haslocalmonth = icmp sge i64 %localmonth, 0
  br i1 %haslocalmonth, label %monthparsed, label %englishmonth
englishmonth:
  %engmonth = call i64 @t_parse_name(ptr %data, i64 %length, ptr %offset, ptr @t.months, i64 12)
  br label %monthparsed
monthparsed:
  %monthindex = phi i64 [%localmonth, %monthparse], [%engmonth, %englishmonth]
  %monthmissing = icmp slt i64 %monthindex, 0
  br i1 %monthmissing, label %mismatch, label %monthname
monthname:
  br label %storefield
weekdayparse:
  %localday = call i64 @j_locale_parse(ptr %data, i64 %length, ptr %offset, i64 7, i64 7, i64 0)
  %haslocalday = icmp sge i64 %localday, 0
  br i1 %haslocalday, label %dayparsed, label %englishday
englishday:
  %engday = call i64 @t_parse_name(ptr %data, i64 %length, ptr %offset, ptr @t.weekdays, i64 7)
  br label %dayparsed
dayparsed:
  %dayindex = phi i64 [%localday, %weekdayparse], [%engday, %englishday]
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
  %localampm = call i64 @j_locale_parse(ptr %data, i64 %length, ptr %offset, i64 38, i64 2, i64 -1)
  %haslocalampm = icmp sge i64 %localampm, 0
  br i1 %haslocalampm, label %localampmstore, label %englishampm
localampmstore:
  store i64 %localampm, ptr %ampm
  br label %ampmcontinue
englishampm:
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
  br label %ampmcontinue
ampmcontinue:
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
  br i1 %fragment, label %fragmentdone, label %tailstart
fragmentdone:
  %fragmentvalue = call ptr @j_bool(i1 true)
  ret ptr %fragmentvalue
tailstart:
  %stop = load i64, ptr %offset
  %all = icmp eq i64 %stop, %length
  br i1 %all, label %build, label %tailcheck
tailcheck:
  %tailp = getelementptr i8, ptr %data, i64 %stop
  %tailc = load i8, ptr %tailp
  %tailspace = call i1 @t_whitespace(i8 %tailc)
  br i1 %tailspace, label %build, label %mismatch
build:
  %centuryvalue = load i64, ptr %centuryp
  %hascentury = icmp sge i64 %centuryvalue, 0
  br i1 %hascentury, label %centurybuild, label %erabuildcheck
centurybuild:
  %rawyear = load i64, ptr %fields
  %rawyear2 = srem i64 %rawyear, 100
  %wantcentury = load i1, ptr %wantcenturyp
  %yearwithincentury = select i1 %wantcentury, i64 %rawyear2, i64 0
  %centurybase = mul i64 %centuryvalue, 100
  %yearwithcentury = add i64 %centurybase, %yearwithincentury
  store i64 %yearwithcentury, ptr %fields
  br label %erabuildcheck
erabuildcheck:
  %selectedera = load ptr, ptr %eras
  %hasselectedera = icmp ne ptr %selectedera, null
  br i1 %hasselectedera, label %erabuild, label %hourbuild
erabuild:
  %wantyear = load i1, ptr %haserayearp
  %raweryear = load i64, ptr %erayearp
  %startingyear = load i64, ptr %selectedera
  %effectiveerayear = select i1 %wantyear, i64 %raweryear, i64 %startingyear
  %convertedyear = call i64 @j_locale_era_year(ptr %selectedera, i64 %effectiveerayear, i1 true)
  store i64 %convertedyear, ptr %fields
  br label %hourbuild
hourbuild:
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
  %f = phi i64 [ 0, %hourbuild ], [ %fn, %fieldbody ]
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
  br i1 %fragment, label %fragmentfailed, label %diagnostic
fragmentfailed:
  ret ptr null
diagnostic:
  %errbuffer = call ptr @j_buffer_new()
  call void @j_buffer_append(ptr %errbuffer, ptr @t.dateprefix, i64 6)
  %inputdata = call ptr @b_data(ptr %input)
  %inputlen = call i64 @j_strlen(ptr %inputdata)
  call void @j_buffer_append(ptr %errbuffer, ptr %inputdata, i64 %inputlen)
  call void @j_buffer_append(ptr %errbuffer, ptr @t.datebetween, i64 25)
  %formatdata = call ptr @b_data(ptr %format)
  %formatlen = call i64 @j_strlen(ptr %formatdata)
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
