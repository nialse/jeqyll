%FV = type { i32, i32, double, i64, i64, ptr, ptr }

@j_executable_origin = global ptr null
@j_program_origin = global ptr null
@j_fs_search_error = global ptr null
@j_environ = external global ptr
@j_library_paths = external global ptr
@j_error = external global ptr
@mtrt_errno_ERANGE = external constant i32
@mtrt_errno_EINVAL = external constant i32
@fs_slash = private constant [2 x i8] c"/\00"
@fs_dot = private constant [2 x i8] c".\00"
@fs_dotdot = private constant [3 x i8] c"..\00"
@fs_home = private constant [5 x i8] c"HOME\00"
@fs_search = private constant [7 x i8] c"search\00"
@fs_origin = private constant [9 x i8] c"$ORIGIN/\00"
@fs_default_home = private constant [6 x i8] c"~/.jq\00"
@fs_default_jq = private constant [18 x i8] c"$ORIGIN/../lib/jq\00"
@fs_default_lib = private constant [15 x i8] c"$ORIGIN/../lib\00"
@fs_badtype = private constant [29 x i8] c"Module path must be a string\00"
@fs_nul = private constant [32 x i8] c"Module path contains a NUL byte\00"
@fs_backslash = private constant [61 x i8] c"Modules must be named by relative paths using '/', not '\5C' (\00"
@fs_parent = private constant [67 x i8] c"Relative paths to modules may not traverse to parent directories (\00"
@fs_consecutive = private constant [58 x i8] c"module names must not have equal consecutive components: \00"
@fs_close = private constant [2 x i8] c")\00"
@fs_empty = private constant [1 x i8] zeroinitializer
@fs_nohome = private constant [31 x i8] c"Could not find home directory.\00"

declare i64 @getcwd(ptr, i64)
declare i64 @readlink(ptr, ptr, i64)
declare i32 @stat(ptr, ptr)
declare ptr @j_alloc(i64)
declare ptr @j_str(ptr, i64)
declare ptr @j_cstr(ptr)
declare ptr @j_array()
declare void @j_push(ptr, ptr)
declare ptr @j_at(ptr, i64)
declare ptr @j_get(ptr, ptr)
declare ptr @j_binary(i32, ptr, ptr)
declare i32 @j_cmp(ptr, ptr)
declare i1 @j_is(ptr, ptr)
declare void @j_fail(ptr)
declare ptr @j_buffer_new()
declare void @j_buffer_append(ptr, ptr, i64)
declare void @j_buffer_byte(ptr, i8)
declare ptr @j_buffer_value(ptr)

define internal i64 @fs_len(ptr %value) {
  %p = getelementptr %FV, ptr %value, i32 0, i32 3
  %n = load i64, ptr %p
  ret i64 %n
}

define internal ptr @fs_data(ptr %value) {
  %p = getelementptr %FV, ptr %value, i32 0, i32 5
  %data = load ptr, ptr %p
  ret ptr %data
}

define internal void @fs_append(ptr %buffer, ptr %value) {
  %n = call i64 @fs_len(ptr %value)
  %data = call ptr @fs_data(ptr %value)
  call void @j_buffer_append(ptr %buffer, ptr %data, i64 %n)
  ret void
}

define ptr @j_fs_join(ptr %directory, ptr %path) {
  %buffer = call ptr @j_buffer_new()
  call void @fs_append(ptr %buffer, ptr %directory)
  call void @j_buffer_byte(ptr %buffer, i8 47)
  call void @fs_append(ptr %buffer, ptr %path)
  %result = call ptr @j_buffer_value(ptr %buffer)
  ret ptr %result
}

define ptr @j_fs_dirname(ptr %path) {
entry:
  %n = call i64 @fs_len(ptr %path)
  %data = call ptr @fs_data(ptr %path)
  br label %trim
trim:
  %length = phi i64 [%n, %entry], [%trimmed, %trimnext]
  %many = icmp ugt i64 %length, 1
  br i1 %many, label %trimread, label %searchbegin
trimread:
  %trimmed = sub i64 %length, 1
  %tp = getelementptr i8, ptr %data, i64 %trimmed
  %tc = load i8, ptr %tp
  %slash = icmp eq i8 %tc, 47
  br i1 %slash, label %trimnext, label %searchbegin
trimnext:
  br label %trim
searchbegin:
  br label %search
search:
  %i = phi i64 [%length, %searchbegin], [%previous, %read]
  %more = icmp ugt i64 %i, 0
  br i1 %more, label %read, label %dot
read:
  %previous = sub i64 %i, 1
  %p = getelementptr i8, ptr %data, i64 %previous
  %c = load i8, ptr %p
  %separator = icmp eq i8 %c, 47
  br i1 %separator, label %found, label %search
found:
  %root = icmp eq i64 %previous, 0
  %end = select i1 %root, i64 1, i64 %previous
  %result = call ptr @j_str(ptr %data, i64 %end)
  ret ptr %result
dot:
  %default = call ptr @j_cstr(ptr @fs_dot)
  ret ptr %default
}

define ptr @j_fs_cwd() {
entry:
  %erange32 = load i32, ptr @mtrt_errno_ERANGE
  %erange64 = sext i32 %erange32 to i64
  %erange = sub i64 0, %erange64
  br label %try
try:
  %capacity = phi i64 [4096, %entry], [%larger, %grow]
  %buffer = call ptr @j_alloc(i64 %capacity)
  %status = call i64 @getcwd(ptr %buffer, i64 %capacity)
  %ok = icmp sge i64 %status, 0
  br i1 %ok, label %done, label %check
check:
  %small = icmp eq i64 %status, %erange
  br i1 %small, label %grow, label %failed
grow:
  %larger = mul i64 %capacity, 2
  br label %try
done:
  %path = call ptr @j_cstr(ptr %buffer)
  ret ptr %path
failed:
  ret ptr null
}

define i1 @j_fs_exists(ptr %path) {
  %bytes = call ptr @fs_data(ptr %path)
  %record = alloca [120 x i8], align 8
  %status = call i32 @stat(ptr %bytes, ptr %record)
  %found = icmp eq i32 %status, 0
  ret i1 %found
}

define ptr @j_fs_canonical(ptr %path) {
entry:
  %tag = load i32, ptr %path
  %string = icmp eq i32 %tag, 4
  br i1 %string, label %start, label %failed
start:
  %data = call ptr @fs_data(ptr %path)
  %n = call i64 @fs_len(ptr %path)
  %empty = icmp eq i64 %n, 0
  br i1 %empty, label %failed, label %prefix
prefix:
  %first = load i8, ptr %data
  %absolute = icmp eq i8 %first, 47
  br i1 %absolute, label %absolutepath, label %relativepath
relativepath:
  %cwd = call ptr @j_fs_cwd()
  %hascwd = icmp ne ptr %cwd, null
  br i1 %hascwd, label %joincwd, label %failed
joincwd:
  %joined = call ptr @j_fs_join(ptr %cwd, ptr %path)
  br label %absolutepath
absolutepath:
  %initial = phi ptr [%path, %prefix], [%joined, %joincwd]
  %root = call ptr @j_cstr(ptr @fs_slash)
  %pendingp = alloca ptr
  %resolvedp = alloca ptr
  %offsetp = alloca i64
  %linksp = alloca i64
  store ptr %initial, ptr %pendingp
  store ptr %root, ptr %resolvedp
  store i64 0, ptr %offsetp
  store i64 0, ptr %linksp
  %einval32 = load i32, ptr @mtrt_errno_EINVAL
  %einval64 = sext i32 %einval32 to i64
  %einval = sub i64 0, %einval64
  br label %loop
loop:
  %pending = load ptr, ptr %pendingp
  %resolved = load ptr, ptr %resolvedp
  %offset = load i64, ptr %offsetp
  %length = call i64 @fs_len(ptr %pending)
  %bytes = call ptr @fs_data(ptr %pending)
  %more = icmp ult i64 %offset, %length
  br i1 %more, label %read, label %done
read:
  %p = getelementptr i8, ptr %bytes, i64 %offset
  %c = load i8, ptr %p
  %slash = icmp eq i8 %c, 47
  br i1 %slash, label %skip, label %component
skip:
  %afterslash = add i64 %offset, 1
  store i64 %afterslash, ptr %offsetp
  br label %loop
component:
  br label %scan
scan:
  %i = phi i64 [%offset, %component], [%next, %advance]
  %inside = icmp ult i64 %i, %length
  br i1 %inside, label %scanread, label %componentend
scanread:
  %cp = getelementptr i8, ptr %bytes, i64 %i
  %cc = load i8, ptr %cp
  %separator = icmp eq i8 %cc, 47
  %nul = icmp eq i8 %cc, 0
  br i1 %nul, label %failed, label %scancheck
scancheck:
  br i1 %separator, label %componentend, label %advance
advance:
  %next = add i64 %i, 1
  br label %scan
componentend:
  store i64 %i, ptr %offsetp
  %componentlen = sub i64 %i, %offset
  %name = call ptr @j_str(ptr %p, i64 %componentlen)
  %dot = call i1 @j_is(ptr %name, ptr @fs_dot)
  br i1 %dot, label %loop, label %parentcheck
parentcheck:
  %parent = call i1 @j_is(ptr %name, ptr @fs_dotdot)
  br i1 %parent, label %parentdir, label %candidate
parentdir:
  %parentpath = call ptr @j_fs_dirname(ptr %resolved)
  store ptr %parentpath, ptr %resolvedp
  br label %loop
candidate:
  %isroot = call i1 @j_is(ptr %resolved, ptr @fs_slash)
  br i1 %isroot, label %rootcandidate, label %joincandidate
rootcandidate:
  %rootpath = call ptr @j_binary(i32 0, ptr %resolved, ptr %name)
  br label %link
joincandidate:
  %joinedpath = call ptr @j_fs_join(ptr %resolved, ptr %name)
  br label %link
link:
  %full = phi ptr [%rootpath, %rootcandidate], [%joinedpath, %joincandidate]
  %fullbytes = call ptr @fs_data(ptr %full)
  br label %readlink
readlink:
  %capacity = phi i64 [256, %link], [%larger, %growlink]
  %linkbuffer = call ptr @j_alloc(i64 %capacity)
  %linklength = call i64 @readlink(ptr %fullbytes, ptr %linkbuffer, i64 %capacity)
  %issymlink = icmp sge i64 %linklength, 0
  br i1 %issymlink, label %linkcheck, label %ordinarycheck
ordinarycheck:
  %ordinary = icmp eq i64 %linklength, %einval
  br i1 %ordinary, label %accept, label %failed
accept:
  store ptr %full, ptr %resolvedp
  br label %loop
linkcheck:
  %truncated = icmp eq i64 %linklength, %capacity
  br i1 %truncated, label %growlink, label %symlink
growlink:
  %larger = mul i64 %capacity, 2
  br label %readlink
symlink:
  %links = load i64, ptr %linksp
  %within = icmp ult i64 %links, 40
  br i1 %within, label %follow, label %failed
follow:
  %linknext = add i64 %links, 1
  store i64 %linknext, ptr %linksp
  %target = call ptr @j_str(ptr %linkbuffer, i64 %linklength)
  %targetfirst = load i8, ptr %linkbuffer
  %targetabsolute = icmp eq i8 %targetfirst, 47
  %targetbase = select i1 %targetabsolute, ptr %root, ptr %resolved
  %remainderbytes = getelementptr i8, ptr %bytes, i64 %i
  %remainderlen = sub i64 %length, %i
  %remainder = call ptr @j_str(ptr %remainderbytes, i64 %remainderlen)
  %newpending = call ptr @j_fs_join(ptr %target, ptr %remainder)
  store ptr %newpending, ptr %pendingp
  store ptr %targetbase, ptr %resolvedp
  store i64 0, ptr %offsetp
  br label %loop
done:
  ret ptr %resolved
failed:
  ret ptr %path
}

define internal void @fs_path_error(ptr %prefix, ptr %path, ptr %suffix) {
  %buffer = call ptr @j_buffer_new()
  %pre = call ptr @j_cstr(ptr %prefix)
  %post = call ptr @j_cstr(ptr %suffix)
  call void @fs_append(ptr %buffer, ptr %pre)
  call void @fs_append(ptr %buffer, ptr %path)
  call void @fs_append(ptr %buffer, ptr %post)
  %message = call ptr @j_buffer_value(ptr %buffer)
  store ptr %message, ptr @j_error
  ret void
}

define i1 @j_fs_validate_module(ptr %path) {
entry:
  %tag = load i32, ptr %path
  %string = icmp eq i32 %tag, 4
  br i1 %string, label %begin, label %badtype
badtype:
  call void @j_fail(ptr @fs_badtype)
  ret i1 false
begin:
  %data = call ptr @fs_data(ptr %path)
  %n = call i64 @fs_len(ptr %path)
  br label %scan
scan:
  %i = phi i64 [0, %begin], [%next, %advance]
  %start = phi i64 [0, %begin], [%newstart, %advance]
  %previous = phi ptr [null, %begin], [%newprevious, %advance]
  %end = icmp eq i64 %i, %n
  br i1 %end, label %component, label %read
read:
  %p = getelementptr i8, ptr %data, i64 %i
  %c = load i8, ptr %p
  switch i8 %c, label %ordinary [i8 0, label %nul i8 92, label %backslash i8 47, label %component]
ordinary:
  br label %advance
component:
  %cp = getelementptr i8, ptr %data, i64 %start
  %length = sub i64 %i, %start
  %name = call ptr @j_str(ptr %cp, i64 %length)
  %parent = call i1 @j_is(ptr %name, ptr @fs_dotdot)
  br i1 %parent, label %badparent, label %previouscheck
previouscheck:
  %hasprevious = icmp ne ptr %previous, null
  br i1 %hasprevious, label %compare, label %componentdone
compare:
  %cmp = call i32 @j_cmp(ptr %name, ptr %previous)
  %same = icmp eq i32 %cmp, 0
  br i1 %same, label %consecutive, label %componentdone
componentdone:
  br i1 %end, label %done, label %componentadvance
componentadvance:
  %after = add i64 %i, 1
  br label %advance
advance:
  %newstart = phi i64 [%start, %ordinary], [%after, %componentadvance]
  %newprevious = phi ptr [%previous, %ordinary], [%name, %componentadvance]
  %next = add i64 %i, 1
  br label %scan
nul:
  call void @j_fail(ptr @fs_nul)
  ret i1 false
backslash:
  call void @fs_path_error(ptr @fs_backslash, ptr %path, ptr @fs_close)
  ret i1 false
badparent:
  call void @fs_path_error(ptr @fs_parent, ptr %path, ptr @fs_close)
  ret i1 false
consecutive:
  call void @fs_path_error(ptr @fs_consecutive, ptr %path, ptr @fs_empty)
  ret i1 false
done:
  ret i1 true
}

define ptr @j_fs_expand(ptr %path, ptr %parent) {
entry:
  %tag = load i32, ptr %path
  %string = icmp eq i32 %tag, 4
  br i1 %string, label %begin, label %skip
begin:
  %n = call i64 @fs_len(ptr %path)
  %data = call ptr @fs_data(ptr %path)
  %nonempty = icmp ne i64 %n, 0
  br i1 %nonempty, label %first, label %skip
first:
  %head = load i8, ptr %data
  %tilde = icmp eq i8 %head, 126
  %enough = icmp uge i64 %n, 2
  %mayhome = and i1 %tilde, %enough
  br i1 %mayhome, label %homecheck, label %origincheck
homecheck:
  %secondp = getelementptr i8, ptr %data, i64 1
  %second = load i8, ptr %secondp
  %homeslash = icmp eq i8 %second, 47
  br i1 %homeslash, label %home, label %origincheck
home:
  %env = load ptr, ptr @j_environ
  %homekey = call ptr @j_cstr(ptr @fs_home)
  %homepath = call ptr @j_get(ptr %env, ptr %homekey)
  %hometag = load i32, ptr %homepath
  %hashome = icmp eq i32 %hometag, 4
  br i1 %hashome, label %homeexpand, label %nohome
homeexpand:
  %hometailp = getelementptr i8, ptr %data, i64 2
  %hometaillen = sub i64 %n, 2
  %hometail = call ptr @j_str(ptr %hometailp, i64 %hometaillen)
  %homeexpanded = call ptr @j_fs_join(ptr %homepath, ptr %hometail)
  ret ptr %homeexpanded
nohome:
  call void @j_fail(ptr @fs_nohome)
  ret ptr null
origincheck:
  %long = icmp uge i64 %n, 8
  br i1 %long, label %originloop, label %relative
originloop:
  %i = phi i64 [0, %origincheck], [%next, %originnext]
  %all = icmp eq i64 %i, 8
  br i1 %all, label %originexpand, label %originbyte
originbyte:
  %op = getelementptr i8, ptr @fs_origin, i64 %i
  %ip = getelementptr i8, ptr %data, i64 %i
  %a = load i8, ptr %op
  %b = load i8, ptr %ip
  %same = icmp eq i8 %a, %b
  br i1 %same, label %originnext, label %relative
originnext:
  %next = add i64 %i, 1
  br label %originloop
originexpand:
  %origin = load ptr, ptr @j_executable_origin
  %originmissing = icmp eq ptr %origin, null
  br i1 %originmissing, label %skip, label %originjoin
originjoin:
  %tailp = getelementptr i8, ptr %data, i64 8
  %taillen = sub i64 %n, 8
  %tail = call ptr @j_str(ptr %tailp, i64 %taillen)
  %expanded = call ptr @j_fs_join(ptr %origin, ptr %tail)
  ret ptr %expanded
relative:
  %absolute = icmp eq i8 %head, 47
  %dot = call i1 @j_is(ptr %path, ptr @fs_dot)
  %keep = or i1 %absolute, %dot
  br i1 %keep, label %unchanged, label %parentcheck
parentcheck:
  %missingparent = icmp eq ptr %parent, null
  %program = load ptr, ptr @j_program_origin
  %base = select i1 %missingparent, ptr %program, ptr %parent
  %nobase = icmp eq ptr %base, null
  br i1 %nobase, label %unchanged, label %parentjoin
parentjoin:
  %relativepath = call ptr @j_fs_join(ptr %base, ptr %path)
  ret ptr %relativepath
unchanged:
  ret ptr %path
skip:
  ret ptr null
}

define void @j_fs_init(ptr %argv0, ptr %programfile) {
entry:
  %execdir = call ptr @j_fs_dirname(ptr %argv0)
  %execorigin = call ptr @j_fs_canonical(ptr %execdir)
  store ptr %execorigin, ptr @j_executable_origin
  %fromfile = icmp ne ptr %programfile, null
  br i1 %fromfile, label %file, label %cwd
file:
  %programdir = call ptr @j_fs_dirname(ptr %programfile)
  %programorigin = call ptr @j_fs_canonical(ptr %programdir)
  br label %save
cwd:
  %working = call ptr @j_fs_cwd()
  br label %save
save:
  %origin = phi ptr [%programorigin, %file], [%working, %cwd]
  store ptr %origin, ptr @j_program_origin
  %paths = load ptr, ptr @j_library_paths
  %n = call i64 @fs_len(ptr %paths)
  %empty = icmp eq i64 %n, 0
  br i1 %empty, label %defaults, label %normalize
defaults:
  %home = call ptr @j_cstr(ptr @fs_default_home)
  %jq = call ptr @j_cstr(ptr @fs_default_jq)
  %lib = call ptr @j_cstr(ptr @fs_default_lib)
  call void @j_push(ptr %paths, ptr %home)
  call void @j_push(ptr %paths, ptr %jq)
  call void @j_push(ptr %paths, ptr %lib)
  br label %normalize
normalize:
  %count = call i64 @fs_len(ptr %paths)
  %pathdata = call ptr @fs_data(ptr %paths)
  br label %normalize_loop
normalize_loop:
  %i = phi i64 [0, %normalize], [%next, %normalize_body]
  %more = icmp ult i64 %i, %count
  br i1 %more, label %normalize_body, label %done
normalize_body:
  %p = getelementptr ptr, ptr %pathdata, i64 %i
  %path = load ptr, ptr %p
  %canonical = call ptr @j_fs_canonical(ptr %path)
  store ptr %canonical, ptr %p
  %next = add i64 %i, 1
  br label %normalize_loop
done:
  ret void
}

define internal i1 @fs_has(ptr %object, ptr %name) {
entry:
  %tag = load i32, ptr %object
  %isobject = icmp eq i32 %tag, 6
  br i1 %isobject, label %begin, label %no
begin:
  %n = call i64 @fs_len(ptr %object)
  %data = call ptr @fs_data(ptr %object)
  br label %loop
loop:
  %i = phi i64 [0, %begin], [%next, %advance]
  %more = icmp ult i64 %i, %n
  br i1 %more, label %read, label %no
read:
  %index = mul i64 %i, 2
  %p = getelementptr ptr, ptr %data, i64 %index
  %key = load ptr, ptr %p
  %same = call i1 @j_is(ptr %key, ptr %name)
  br i1 %same, label %yes, label %advance
advance:
  %next = add i64 %i, 1
  br label %loop
yes:
  ret i1 true
no:
  ret i1 false
}

define ptr @j_fs_search(ptr %metadata, ptr %parent) {
entry:
  %specified = call i1 @fs_has(ptr %metadata, ptr @fs_search)
  %paths = call ptr @j_array()
  br i1 %specified, label %explicit, label %defaults
explicit:
  %key = call ptr @j_cstr(ptr @fs_search)
  %search = call ptr @j_get(ptr %metadata, ptr %key)
  %tag = load i32, ptr %search
  %isarray = icmp eq i32 %tag, 5
  br i1 %isarray, label %explicitarray, label %explicitvalue
explicitarray:
  br label %expand
explicitvalue:
  call void @j_push(ptr %paths, ptr %search)
  br label %expand
defaults:
  %dot = call ptr @j_cstr(ptr @fs_dot)
  call void @j_push(ptr %paths, ptr %dot)
  %global = load ptr, ptr @j_library_paths
  %globaln = call i64 @fs_len(ptr %global)
  br label %copy
copy:
  %ci = phi i64 [0, %defaults], [%cnext, %copybody]
  %cmore = icmp ult i64 %ci, %globaln
  br i1 %cmore, label %copybody, label %expand
copybody:
  %cv = call ptr @j_at(ptr %global, i64 %ci)
  call void @j_push(ptr %paths, ptr %cv)
  %cnext = add i64 %ci, 1
  br label %copy
expand:
  %raw = phi ptr [%search, %explicitarray], [%paths, %explicitvalue], [%paths, %copy]
  %n = call i64 @fs_len(ptr %raw)
  %out = call ptr @j_array()
  %savederror = load ptr, ptr @j_error
  store ptr null, ptr @j_fs_search_error
  br label %loop
loop:
  %i = phi i64 [0, %expand], [%next, %advance]
  %more = icmp ult i64 %i, %n
  br i1 %more, label %body, label %done
body:
  %path = call ptr @j_at(ptr %raw, i64 %i)
  store ptr null, ptr @j_error
  %expanded = call ptr @j_fs_expand(ptr %path, ptr %parent)
  %error = load ptr, ptr @j_error
  %failed = icmp ne ptr %error, null
  br i1 %failed, label %saveerror, label %check
saveerror:
  store ptr %error, ptr @j_fs_search_error
  br label %advance
check:
  %valid = icmp ne ptr %expanded, null
  br i1 %valid, label %append, label %advance
append:
  call void @j_push(ptr %out, ptr %expanded)
  br label %advance
advance:
  %next = add i64 %i, 1
  br label %loop
done:
  store ptr %savederror, ptr @j_error
  ret ptr %out
}
