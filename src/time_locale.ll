@j_environ = external global ptr
@mtrt_errno_EINTR = external constant i32
@lc.initialized = internal global i1 false
@lc.data = internal global ptr null
@lc.length = internal global i64 0
@lc.all = private constant [7 x i8] c"LC_ALL\00"
@lc.time = private constant [8 x i8] c"LC_TIME\00"
@lc.lang = private constant [5 x i8] c"LANG\00"
@lc.path = private constant [8 x i8] c"LOCPATH\00"
@lc.root = private constant [16 x i8] c"/usr/lib/locale\00"
@lc.archive = private constant [31 x i8] c"/usr/lib/locale/locale-archive\00"
@lc.filename = private constant [9 x i8] c"/LC_TIME\00"
@lc.slash = private constant [2 x i8] c"/\00"
@lc.colon = private constant [2 x i8] c":\00"
@lc.C = private constant [2 x i8] c"C\00"
@lc.POSIX = private constant [6 x i8] c"POSIX\00"

declare ptr @j_alloc(i64)
declare ptr @j_alloc_permanent(i64)
declare void @j_copy(ptr, ptr, i64)
declare ptr @j_str(ptr, i64)
declare ptr @j_cstr(ptr)
declare ptr @j_get(ptr, ptr)
declare ptr @j_binary(i32, ptr, ptr)
declare ptr @j_split(ptr, ptr)
declare ptr @j_array()
declare void @j_push(ptr, ptr)
declare ptr @j_at(ptr, i64)
declare i1 @j_is(ptr, ptr)
declare i32 @j_cmp(ptr, ptr)
declare ptr @b_data(ptr)
declare i64 @b_len(ptr)
declare i32 @b_tag(ptr)
declare i32 @open(ptr, i32, i32)
declare i64 @pread(i32, ptr, i64, i64)
declare i64 @lseek(i32, i64, i32)
declare i32 @close(i32)
declare i32 @j_utf8_next(ptr, i64, ptr)
declare i32 @rx_unicode_fold(i32)
declare i64 @j_strlen(ptr)

define internal i32 @lc_open(ptr %path) {
entry:
  %interrupted = load i32, ptr @mtrt_errno_EINTR
  %negative = sub i32 0, %interrupted
  br label %retry
retry:
  %fd = call i32 @open(ptr %path, i32 0, i32 0)
  %again = icmp eq i32 %fd, %negative
  br i1 %again, label %retry, label %done
done:
  ret i32 %fd
}

define internal i64 @lc_size(i32 %fd) {
entry:
  %interrupted = load i32, ptr @mtrt_errno_EINTR
  %wide = sext i32 %interrupted to i64
  %negative = sub i64 0, %wide
  br label %retry
retry:
  %size = call i64 @lseek(i32 %fd, i64 0, i32 2)
  %again = icmp eq i64 %size, %negative
  br i1 %again, label %retry, label %done
done:
  ret i64 %size
}

define internal i64 @lc_read(i32 %fd, ptr %buffer, i64 %length, i64 %offset) {
entry:
  %interrupted = load i32, ptr @mtrt_errno_EINTR
  %wide = sext i32 %interrupted to i64
  %negative = sub i64 0, %wide
  br label %loop
loop:
  %filled = phi i64 [0, %entry], [%filled, %read], [%next, %advance]
  %remaining = sub i64 %length, %filled
  %complete = icmp eq i64 %remaining, 0
  br i1 %complete, label %done, label %read
read:
  %position = add i64 %offset, %filled
  %target = getelementptr i8, ptr %buffer, i64 %filled
  %count = call i64 @pread(i32 %fd, ptr %target, i64 %remaining, i64 %position)
  %again = icmp eq i64 %count, %negative
  br i1 %again, label %loop, label %check
check:
  %failed = icmp slt i64 %count, 0
  br i1 %failed, label %error, label %progress
progress:
  %eof = icmp eq i64 %count, 0
  br i1 %eof, label %done, label %advance
advance:
  %next = add i64 %filled, %count
  br label %loop
error:
  ret i64 %count
done:
  ret i64 %filled
}

define internal ptr @lc_env(ptr %key) {
entry:
  %env = load ptr, ptr @j_environ
  %present = icmp ne ptr %env, null
  br i1 %present, label %get, label %missing
get:
  %name = call ptr @j_cstr(ptr %key)
  %value = call ptr @j_get(ptr %env, ptr %name)
  %tag = call i32 @b_tag(ptr %value)
  %string = icmp eq i32 %tag, 4
  %n = call i64 @b_len(ptr %value)
  %nonempty = icmp ugt i64 %n, 0
  %valid = and i1 %string, %nonempty
  br i1 %valid, label %found, label %missing
found:
  ret ptr %value
missing:
  ret ptr null
}

define internal ptr @lc_normalize(ptr %name) {
entry:
  %source = call ptr @b_data(ptr %name)
  %n = call i64 @b_len(ptr %name)
  %size = add i64 %n, 1
  %target = call ptr @j_alloc(i64 %size)
  br label %loop
loop:
  %i = phi i64 [0, %entry], [%next, %advance]
  %j = phi i64 [0, %entry], [%newj, %advance]
  %codeset = phi i1 [false, %entry], [%nextcodeset, %advance]
  %more = icmp ult i64 %i, %n
  br i1 %more, label %body, label %done
body:
  %p = getelementptr i8, ptr %source, i64 %i
  %c = load i8, ptr %p
  %dot = icmp eq i8 %c, 46
  %at = icmp eq i8 %c, 64
  %nextcodeset0 = or i1 %codeset, %dot
  %nextcodeset = select i1 %at, i1 false, i1 %nextcodeset0
  %upperoffset = sub i8 %c, 65
  %upper = icmp ule i8 %upperoffset, 25
  %lowered = add i8 %c, 32
  %lower = select i1 %upper, i8 %lowered, i8 %c
  %letteroffset = sub i8 %lower, 97
  %letter = icmp ule i8 %letteroffset, 25
  %digitoffset = sub i8 %c, 48
  %digit = icmp ule i8 %digitoffset, 9
  %alnum = or i1 %letter, %digit
  %normalized = and i1 %codeset, %alnum
  %inside = and i1 %codeset, %nextcodeset
  %badchar = xor i1 %alnum, true
  %skip = and i1 %inside, %badchar
  br i1 %skip, label %advance, label %put
put:
  %outchar = select i1 %normalized, i8 %lower, i8 %c
  %outp = getelementptr i8, ptr %target, i64 %j
  store i8 %outchar, ptr %outp
  %written = add i64 %j, 1
  br label %advance
advance:
  %newj = phi i64 [%j, %body], [%written, %put]
  %next = add i64 %i, 1
  br label %loop
done:
  %result = call ptr @j_str(ptr %target, i64 %j)
  ret ptr %result
}

define internal i64 @lc_u32(ptr %data, i64 %offset) {
entry:
  %p = getelementptr i8, ptr %data, i64 %offset
  %word = load i32, ptr %p, align 1
  %wide = zext i32 %word to i64
  ret i64 %wide
}

define internal i1 @lc_read_category(i32 %fd, i64 %offset, i64 %length) {
entry:
  %minimum = icmp uge i64 %length, 184
  %nonnegative = icmp sge i64 %offset, 0
  %positive = icmp sge i64 %length, 0
  %basic0 = and i1 %minimum, %nonnegative
  %basic = and i1 %basic0, %positive
  br i1 %basic, label %bounds, label %bad
bounds:
  %filesize = call i64 @lc_size(i32 %fd)
  %filenonnegative = icmp sge i64 %filesize, 0
  %offsetfits = icmp ule i64 %offset, %filesize
  %remaining = sub i64 %filesize, %offset
  %lengthfits = icmp ule i64 %length, %remaining
  %bound0 = and i1 %filenonnegative, %offsetfits
  %bound = and i1 %bound0, %lengthfits
  br i1 %bound, label %read, label %bad
read:
  %buffer = call ptr @j_alloc(i64 %length)
  %count = call i64 @lc_read(i32 %fd, ptr %buffer, i64 %length, i64 %offset)
  %complete = icmp eq i64 %count, %length
  br i1 %complete, label %check, label %bad
check:
  %magic = call i64 @lc_u32(ptr %buffer, i64 0)
  %correct = icmp eq i64 %magic, 537071895
  %items = call i64 @lc_u32(ptr %buffer, i64 4)
  %enough = icmp uge i64 %items, 44
  %indexbytes = mul i64 %items, 4
  %indexend = add i64 %indexbytes, 8
  %fits = icmp ult i64 %indexend, %length
  %ok0 = and i1 %correct, %enough
  %ok = and i1 %ok0, %fits
  br i1 %ok, label %indexloop, label %bad
indexloop:
  %i = phi i64 [0, %check], [%next, %indexbody]
  %more = icmp ult i64 %i, %items
  br i1 %more, label %indexbody, label %save
indexbody:
  %ibyte = mul i64 %i, 4
  %iposition = add i64 %ibyte, 8
  %itemoffset = call i64 @lc_u32(ptr %buffer, i64 %iposition)
  %afterindex = icmp uge i64 %itemoffset, %indexend
  %beforeend = icmp ult i64 %itemoffset, %length
  %itemvalid = and i1 %afterindex, %beforeend
  %next = add i64 %i, 1
  br i1 %itemvalid, label %indexloop, label %bad
save:
  %durable = call ptr @j_alloc_permanent(i64 %length)
  call void @j_copy(ptr %durable, ptr %buffer, i64 %length)
  store ptr %durable, ptr @lc.data
  store i64 %length, ptr @lc.length
  ret i1 true
bad:
  ret i1 false
}

define internal i1 @lc_file(ptr %directory, ptr %name) {
entry:
  %slash = call ptr @j_cstr(ptr @lc.slash)
  %filename = call ptr @j_cstr(ptr @lc.filename)
  %prefix = call ptr @j_binary(i32 0, ptr %directory, ptr %slash)
  %named = call ptr @j_binary(i32 0, ptr %prefix, ptr %name)
  %full = call ptr @j_binary(i32 0, ptr %named, ptr %filename)
  %path = call ptr @b_data(ptr %full)
  %fd = call i32 @lc_open(ptr %path)
  %failed = icmp slt i32 %fd, 0
  br i1 %failed, label %bad, label %size
size:
  %length = call i64 @lc_size(i32 %fd)
  %valid = icmp sge i64 %length, 184
  br i1 %valid, label %read, label %closebad
read:
  %loaded = call i1 @lc_read_category(i32 %fd, i64 0, i64 %length)
  %closed = call i32 @close(i32 %fd)
  ret i1 %loaded
closebad:
  %cb = call i32 @close(i32 %fd)
  br label %bad
bad:
  ret i1 false
}

define internal i1 @lc_archive(ptr %desired) {
entry:
  %fd = call i32 @lc_open(ptr @lc.archive)
  %failed = icmp slt i32 %fd, 0
  br i1 %failed, label %bad, label %header
header:
  %buffer = call ptr @j_alloc(i64 56)
  %n = call i64 @lc_read(i32 %fd, ptr %buffer, i64 56, i64 0)
  %full = icmp eq i64 %n, 56
  br i1 %full, label %check, label %closebad
check:
  %magic = call i64 @lc_u32(ptr %buffer, i64 0)
  %validmagic = icmp eq i64 %magic, 3724673289
  br i1 %validmagic, label %start, label %closebad
start:
  %table = call i64 @lc_u32(ptr %buffer, i64 8)
  %entries = call i64 @lc_u32(ptr %buffer, i64 16)
  %archivesize = call i64 @lc_size(i32 %fd)
  %tablebytes = mul i64 %entries, 12
  %tableend = add i64 %table, %tablebytes
  %archivevalid = icmp sge i64 %archivesize, 56
  %tablevalid = icmp ule i64 %tableend, %archivesize
  %boundsvalid = and i1 %archivevalid, %tablevalid
  br i1 %boundsvalid, label %allocate, label %closebad
allocate:
  %record = call ptr @j_alloc(i64 28)
  %namelen = call i64 @b_len(ptr %desired)
  %namesize = add i64 %namelen, 32
  %namebuffer = call ptr @j_alloc(i64 %namesize)
  br label %loop
loop:
  %i = phi i64 [0, %allocate], [%next, %advance]
  %more = icmp ult i64 %i, %entries
  br i1 %more, label %entryread, label %closebad
entryread:
  %entryoffset0 = mul i64 %i, 12
  %entryoffset = add i64 %table, %entryoffset0
  %read = call i64 @lc_read(i32 %fd, ptr %record, i64 12, i64 %entryoffset)
  %readok = icmp eq i64 %read, 12
  br i1 %readok, label %entrycheck, label %closebad
entrycheck:
  %nameoffset = call i64 @lc_u32(ptr %record, i64 4)
  %recordoffset = call i64 @lc_u32(ptr %record, i64 8)
  %hasname = icmp ne i64 %nameoffset, 0
  %hasrecord = icmp ne i64 %recordoffset, 0
  %present = and i1 %hasname, %hasrecord
  br i1 %present, label %nameread, label %advance
nameread:
  %nr = call i64 @lc_read(i32 %fd, ptr %namebuffer, i64 %namesize, i64 %nameoffset)
  %nonempty = icmp sgt i64 %nr, 0
  br i1 %nonempty, label %nameloop, label %closebad
nameloop:
  %j = phi i64 [0, %nameread], [%jn, %namebody]
  %nm = icmp slt i64 %j, %nr
  br i1 %nm, label %namebody, label %advance
namebody:
  %np = getelementptr i8, ptr %namebuffer, i64 %j
  %nc = load i8, ptr %np
  %terminated = icmp eq i8 %nc, 0
  %jn = add i64 %j, 1
  br i1 %terminated, label %compare, label %nameloop
compare:
  %entryname = call ptr @j_str(ptr %namebuffer, i64 %j)
  %normalized = call ptr @lc_normalize(ptr %entryname)
  %comparison = call i32 @j_cmp(ptr %normalized, ptr %desired)
  %same = icmp eq i32 %comparison, 0
  br i1 %same, label %category, label %advance
category:
  %rr = call i64 @lc_read(i32 %fd, ptr %record, i64 28, i64 %recordoffset)
  %rok = icmp eq i64 %rr, 28
  br i1 %rok, label %categoryread, label %closebad
categoryread:
  %categoryoffset = call i64 @lc_u32(ptr %record, i64 20)
  %categorylength = call i64 @lc_u32(ptr %record, i64 24)
  %loaded = call i1 @lc_read_category(i32 %fd, i64 %categoryoffset, i64 %categorylength)
  %closed = call i32 @close(i32 %fd)
  ret i1 %loaded
advance:
  %next = add i64 %i, 1
  br label %loop
closebad:
  %cb = call i32 @close(i32 %fd)
  br label %bad
bad:
  ret i1 false
}

define internal void @lc_init() {
entry:
  %initialized = load i1, ptr @lc.initialized
  br i1 %initialized, label %done, label %all
all:
  store i1 true, ptr @lc.initialized
  %allvalue = call ptr @lc_env(ptr @lc.all)
  %hasall = icmp ne ptr %allvalue, null
  br i1 %hasall, label %selected, label %time
time:
  %timevalue = call ptr @lc_env(ptr @lc.time)
  %hastime = icmp ne ptr %timevalue, null
  br i1 %hastime, label %selected, label %lang
lang:
  %langvalue = call ptr @lc_env(ptr @lc.lang)
  %haslang = icmp ne ptr %langvalue, null
  br i1 %haslang, label %selected, label %done
selected:
  %name = phi ptr [%allvalue, %all], [%timevalue, %time], [%langvalue, %lang]
  %c = call i1 @j_is(ptr %name, ptr @lc.C)
  %posix = call i1 @j_is(ptr %name, ptr @lc.POSIX)
  %builtin = or i1 %c, %posix
  br i1 %builtin, label %done, label %search
search:
  %normalized = call ptr @lc_normalize(ptr %name)
  %root = call ptr @j_cstr(ptr @lc.root)
  %searchpath = call ptr @lc_env(ptr @lc.path)
  %haspath = icmp ne ptr %searchpath, null
  br i1 %haspath, label %paths, label %archive
archive:
  %archived = call i1 @lc_archive(ptr %normalized)
  br i1 %archived, label %done, label %defaultpath
defaultpath:
  %defaultlist = call ptr @j_array()
  call void @j_push(ptr %defaultlist, ptr %root)
  br label %start
paths:
  %separator = call ptr @j_cstr(ptr @lc.colon)
  %pathlist = call ptr @j_split(ptr %searchpath, ptr %separator)
  call void @j_push(ptr %pathlist, ptr %root)
  br label %start
start:
  %directories = phi ptr [%defaultlist, %defaultpath], [%pathlist, %paths]
  %count = call i64 @b_len(ptr %directories)
  br label %loop
loop:
  %i = phi i64 [0, %start], [%next, %advance]
  %more = icmp ult i64 %i, %count
  br i1 %more, label %body, label %done
body:
  %directory = call ptr @j_at(ptr %directories, i64 %i)
  %original = call i1 @lc_file(ptr %directory, ptr %name)
  br i1 %original, label %done, label %normalizedfile
normalizedfile:
  %alternate = call i1 @lc_file(ptr %directory, ptr %normalized)
  br i1 %alternate, label %done, label %advance
advance:
  %next = add i64 %i, 1
  br label %loop
done:
  ret void
}

define ptr @j_locale_item(i64 %index, ptr %fallback) {
entry:
  call void @lc_init()
  %data = load ptr, ptr @lc.data
  %present = icmp ne ptr %data, null
  br i1 %present, label %lookup, label %missing
lookup:
  %length = load i64, ptr @lc.length
  %count = call i64 @lc_u32(ptr %data, i64 4)
  %exists = icmp ult i64 %index, %count
  br i1 %exists, label %offset, label %missing
offset:
  %byteoffset0 = mul i64 %index, 4
  %byteoffset = add i64 %byteoffset0, 8
  %position = call i64 @lc_u32(ptr %data, i64 %byteoffset)
  br label %checkloop
checkloop:
  %i = phi i64 [%position, %offset], [%next, %checkbody]
  %more = icmp ult i64 %i, %length
  br i1 %more, label %checkbody, label %missing
checkbody:
  %p = getelementptr i8, ptr %data, i64 %i
  %c = load i8, ptr %p
  %terminated = icmp eq i8 %c, 0
  %next = add i64 %i, 1
  br i1 %terminated, label %found, label %checkloop
found:
  %result = getelementptr i8, ptr %data, i64 %position
  ret ptr %result
missing:
  ret ptr %fallback
}

define ptr @j_locale_raw(i64 %index, ptr %remaining) {
entry:
  call void @lc_init()
  store i64 0, ptr %remaining
  %data = load ptr, ptr @lc.data
  %present = icmp ne ptr %data, null
  br i1 %present, label %lookup, label %missing
lookup:
  %count = call i64 @lc_u32(ptr %data, i64 4)
  %exists = icmp ult i64 %index, %count
  br i1 %exists, label %offset, label %missing
offset:
  %ibytes = mul i64 %index, 4
  %indexposition = add i64 %ibytes, 8
  %position = call i64 @lc_u32(ptr %data, i64 %indexposition)
  %length = load i64, ptr @lc.length
  %left = sub i64 %length, %position
  store i64 %left, ptr %remaining
  %result = getelementptr i8, ptr %data, i64 %position
  ret ptr %result
missing:
  ret ptr null
}

define ptr @j_locale_alt_digit(i64 %number) {
entry:
  %inrange = icmp ult i64 %number, 100
  br i1 %inrange, label %lookup, label %missing
lookup:
  %first = call ptr @j_locale_item(i64 47, ptr null)
  %present = icmp ne ptr %first, null
  br i1 %present, label %nonempty, label %missing
nonempty:
  %byte = load i8, ptr %first
  %valid = icmp ne i8 %byte, 0
  br i1 %valid, label %bounds, label %missing
bounds:
  %base = load ptr, ptr @lc.data
  %size = load i64, ptr @lc.length
  %end = getelementptr i8, ptr %base, i64 %size
  br label %outer
outer:
  %index = phi i64 [0, %bounds], [%nextindex, %advance]
  %start = phi ptr [%first, %bounds], [%after, %advance]
  br label %scan
scan:
  %p = phi ptr [%start, %outer], [%next, %character]
  %inside = icmp ult ptr %p, %end
  br i1 %inside, label %character, label %missing
character:
  %c = load i8, ptr %p
  %nul = icmp eq i8 %c, 0
  %next = getelementptr i8, ptr %p, i64 1
  br i1 %nul, label %terminated, label %scan
terminated:
  %wanted = icmp eq i64 %index, %number
  br i1 %wanted, label %found, label %advance
advance:
  %after = getelementptr i8, ptr %p, i64 1
  %nextindex = add i64 %index, 1
  br label %outer
found:
  %empty = icmp eq ptr %p, %start
  %result = select i1 %empty, ptr null, ptr %start
  ret ptr %result
missing:
  ret ptr null
}

define i64 @j_locale_parse_digit(ptr %data, i64 %length, ptr %position) {
entry:
  %start = load i64, ptr %position
  %remaining = sub i64 %length, %start
  br label %outer
outer:
  %i = phi i64 [0, %entry], [%next, %advance]
  %bestlength = phi i64 [0, %entry], [%newlength, %advance]
  %bestindex = phi i64 [-1, %entry], [%newindex, %advance]
  %more = icmp ult i64 %i, 100
  br i1 %more, label %candidate, label %done
candidate:
  %name = call ptr @j_locale_alt_digit(i64 %i)
  %present = icmp ne ptr %name, null
  br i1 %present, label %checklength, label %advance
checklength:
  %n = call i64 @j_strlen(ptr %name)
  %longer = icmp ugt i64 %n, %bestlength
  %fits = icmp ule i64 %n, %remaining
  %possible = and i1 %longer, %fits
  br i1 %possible, label %matchloop, label %advance
matchloop:
  %j = phi i64 [0, %checklength], [%jn, %matchbyte]
  %complete = icmp eq i64 %j, %n
  br i1 %complete, label %matched, label %matchbyte
matchbyte:
  %inputindex = add i64 %start, %j
  %ip = getelementptr i8, ptr %data, i64 %inputindex
  %np = getelementptr i8, ptr %name, i64 %j
  %a = load i8, ptr %ip
  %b = load i8, ptr %np
  %same = icmp eq i8 %a, %b
  %jn = add i64 %j, 1
  br i1 %same, label %matchloop, label %advance
matched:
  br label %advance
advance:
  %newlength = phi i64 [%bestlength, %candidate], [%bestlength, %checklength], [%bestlength, %matchbyte], [%n, %matched]
  %newindex = phi i64 [%bestindex, %candidate], [%bestindex, %checklength], [%bestindex, %matchbyte], [%i, %matched]
  %next = add i64 %i, 1
  br label %outer
done:
  %stop = add i64 %start, %bestlength
  store i64 %stop, ptr %position
  ret i64 %bestindex
}

define i64 @j_locale_parse(ptr %data, i64 %length, ptr %position, i64 %base, i64 %count, i64 %secondbase) {
entry:
  %start = load i64, ptr %position
  %hasecond = icmp sge i64 %secondbase, 0
  %twice = mul i64 %count, 2
  %total = select i1 %hasecond, i64 %twice, i64 %count
  %inputpos = alloca i64
  %namepos = alloca i64
  br label %outer
outer:
  %i = phi i64 [0, %entry], [%next, %advance]
  %more = icmp ult i64 %i, %total
  br i1 %more, label %candidate, label %missing
candidate:
  %first = icmp ult i64 %i, %count
  %secondindex = sub i64 %i, %count
  %actual = select i1 %first, i64 %i, i64 %secondindex
  %tablebase = select i1 %first, i64 %base, i64 %secondbase
  %index = add i64 %tablebase, %actual
  %name = call ptr @j_locale_item(i64 %index, ptr null)
  %exists = icmp ne ptr %name, null
  br i1 %exists, label %setup, label %advance
setup:
  %namelen = call i64 @j_strlen(ptr %name)
  %nonempty = icmp ugt i64 %namelen, 0
  store i64 %start, ptr %inputpos
  store i64 0, ptr %namepos
  br i1 %nonempty, label %matchloop, label %advance
matchloop:
  %a = load i64, ptr %inputpos
  %b = load i64, ptr %namepos
  %complete = icmp uge i64 %b, %namelen
  br i1 %complete, label %found, label %inputcheck
inputcheck:
  %inputleft = icmp ult i64 %a, %length
  br i1 %inputleft, label %characters, label %advance
characters:
  %ac = call i32 @j_utf8_next(ptr %data, i64 %length, ptr %inputpos)
  %bc = call i32 @j_utf8_next(ptr %name, i64 %namelen, ptr %namepos)
  %af = call i32 @rx_unicode_fold(i32 %ac)
  %bf = call i32 @rx_unicode_fold(i32 %bc)
  %same = icmp eq i32 %af, %bf
  br i1 %same, label %matchloop, label %advance
found:
  store i64 %a, ptr %position
  ret i64 %actual
advance:
  %next = add i64 %i, 1
  br label %outer
missing:
  ret i64 -1
}
