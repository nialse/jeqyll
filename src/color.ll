@j_environ = external global ptr
@col.palette = internal global ptr null
@col.key = private constant [10 x i8] c"JQ_COLORS\00"
@col.null = private constant [5 x i8] c"0;90\00"
@col.number = private constant [5 x i8] c"0;39\00"
@col.string = private constant [5 x i8] c"0;32\00"
@col.container = private constant [5 x i8] c"1;39\00"
@col.field = private constant [5 x i8] c"1;34\00"
@col.warning = private constant [26 x i8] c"Failed to set $JQ_COLORS\0A\00"
@col.reset = private constant [4 x i8] c"\1B[0m"
@col.defaults = private constant [8 x ptr] [ptr @col.null, ptr @col.number, ptr @col.number, ptr @col.number, ptr @col.string, ptr @col.container, ptr @col.container, ptr @col.field]

declare ptr @j_alloc(i64)
declare ptr @j_array()
declare ptr @j_cstr(ptr)
declare ptr @j_str(ptr, i64)
declare void @j_push(ptr, ptr)
declare ptr @j_at(ptr, i64)
declare ptr @j_get(ptr, ptr)
declare void @j_copy(ptr, ptr, i64)
declare i32 @b_tag(ptr)
declare i64 @b_len(ptr)
declare ptr @b_data(ptr)
declare i64 @write(i32, ptr, i64)

define void @j_color_init() {
entry:
  %existing = load ptr, ptr @col.palette
  %initialized = icmp ne ptr %existing, null
  br i1 %initialized, label %done, label %start
start:
  %defaults = call ptr @j_array()
  br label %defaultloop
defaultloop:
  %i = phi i64 [0, %start], [%next, %defaultbody]
  %more = icmp ult i64 %i, 8
  br i1 %more, label %defaultbody, label %environment
defaultbody:
  %p = getelementptr ptr, ptr @col.defaults, i64 %i
  %defaultcodeptr = load ptr, ptr %p
  %s = call ptr @j_cstr(ptr %defaultcodeptr)
  call void @j_push(ptr %defaults, ptr %s)
  %next = add i64 %i, 1
  br label %defaultloop
environment:
  store ptr %defaults, ptr @col.palette
  %env = load ptr, ptr @j_environ
  %hasenv = icmp ne ptr %env, null
  br i1 %hasenv, label %getenv, label %done
getenv:
  %key = call ptr @j_cstr(ptr @col.key)
  %value = call ptr @j_get(ptr %env, ptr %key)
  %tag = call i32 @b_tag(ptr %value)
  %string = icmp eq i32 %tag, 4
  br i1 %string, label %check, label %done
check:
  %n = call i64 @b_len(ptr %value)
  %sdata = call ptr @b_data(ptr %value)
  %nonempty = icmp sgt i64 %n, 0
  br i1 %nonempty, label %parseinit, label %done
parseinit:
  %custom = call ptr @j_array()
  br label %parse
parse:
  %pos = phi i64 [0, %parseinit], [%after, %separator], [%posnext, %validchar]
  %begin = phi i64 [0, %parseinit], [%after, %separator], [%begin, %validchar]
  %index = phi i64 [0, %parseinit], [%indexnext, %separator], [%index, %validchar]
  %morechars = icmp ult i64 %pos, %n
  br i1 %morechars, label %character, label %last
character:
  %cp = getelementptr i8, ptr %sdata, i64 %pos
  %c = load i8, ptr %cp
  %colon = icmp eq i8 %c, 58
  br i1 %colon, label %separator, label %checkchar
checkchar:
  %digit = sub i8 %c, 48
  %isnum = icmp ule i8 %digit, 9
  %semicolon = icmp eq i8 %c, 59
  %valid = or i1 %isnum, %semicolon
  br i1 %valid, label %validchar, label %invalid
validchar:
  %posnext = add i64 %pos, 1
  br label %parse
separator:
  %size = sub i64 %pos, %begin
  %startptr = getelementptr i8, ptr %sdata, i64 %begin
  %code = call ptr @j_str(ptr %startptr, i64 %size)
  call void @j_push(ptr %custom, ptr %code)
  %indexnext = add i64 %index, 1
  %after = add i64 %pos, 1
  %full = icmp uge i64 %indexnext, 8
  br i1 %full, label %complete, label %parse
last:
  %lastsize = sub i64 %pos, %begin
  %haslast = icmp sgt i64 %lastsize, 0
  br i1 %haslast, label %lastput, label %complete
lastput:
  %lastptr = getelementptr i8, ptr %sdata, i64 %begin
  %lastcode = call ptr @j_str(ptr %lastptr, i64 %lastsize)
  call void @j_push(ptr %custom, ptr %lastcode)
  br label %complete
complete:
  %customcount = call i64 @b_len(ptr %custom)
  %defaultdata = call ptr @b_data(ptr %defaults)
  br label %copyloop
copyloop:
  %j = phi i64 [0, %complete], [%jnext, %copybody]
  %jmore = icmp ult i64 %j, %customcount
  br i1 %jmore, label %copybody, label %done
copybody:
  %customcode = call ptr @j_at(ptr %custom, i64 %j)
  %slot = getelementptr ptr, ptr %defaultdata, i64 %j
  store ptr %customcode, ptr %slot
  %jnext = add i64 %j, 1
  br label %copyloop
invalid:
  %written = call i64 @write(i32 2, ptr @col.warning, i64 25)
  br label %done
done:
  ret void
}

define ptr @j_colorize(ptr %json) {
entry:
  call void @j_color_init()
  %palette = load ptr, ptr @col.palette
  %source = call ptr @b_data(ptr %json)
  %length = call i64 @b_len(ptr %json)
  br label %maxloop
maxloop:
  %mi = phi i64 [0, %entry], [%mn, %maxbody]
  %max = phi i64 [0, %entry], [%newmax, %maxbody]
  %mmore = icmp ult i64 %mi, 8
  br i1 %mmore, label %maxbody, label %allocate
maxbody:
  %code = call ptr @j_at(ptr %palette, i64 %mi)
  %clen = call i64 @b_len(ptr %code)
  %bigger = icmp ugt i64 %clen, %max
  %newmax = select i1 %bigger, i64 %clen, i64 %max
  %mn = add i64 %mi, 1
  br label %maxloop
allocate:
  %multiplier = add i64 %max, 8
  %size0 = mul i64 %length, %multiplier
  %size = add i64 %size0, 1
  %out = call ptr @j_alloc(i64 %size)
  %stacksize = add i64 %length, 1
  %stack = call ptr @j_alloc(i64 %stacksize)
  br label %loop
loop:
  %pos = phi i64 [0, %allocate], [%positionnext, %advance], [%whitenext, %whitespace]
  %written = phi i64 [0, %allocate], [%writenext, %advance], [%whitewritten, %whitespace]
  %depth = phi i64 [0, %allocate], [%depthnext, %advance], [%depth, %whitespace]
  %more = icmp ult i64 %pos, %length
  br i1 %more, label %body, label %done
body:
  %src = getelementptr i8, ptr %source, i64 %pos
  %c = load i8, ptr %src
  %space = icmp ule i8 %c, 32
  br i1 %space, label %whitespace, label %token
whitespace:
  %wdst = getelementptr i8, ptr %out, i64 %written
  store i8 %c, ptr %wdst
  %whitenext = add i64 %pos, 1
  %whitewritten = add i64 %written, 1
  br label %loop
token:
  switch i8 %c, label %primitive [i8 34, label %string i8 91, label %openarray i8 123, label %openobject i8 93, label %closearray i8 125, label %closeobject i8 44, label %comma i8 58, label %colon]
openarray:
  br label %open
openobject:
  br label %open
open:
  %opentype = phi i64 [5, %openarray], [6, %openobject]
  %closechar = phi i8 [93, %openarray], [125, %openobject]
  %opennext = add i64 %pos, 1
  %hasnext = icmp ult i64 %opennext, %length
  br i1 %hasnext, label %emptycheck, label %nonempty
emptycheck:
  %nextptr = getelementptr i8, ptr %source, i64 %opennext
  %nextchar = load i8, ptr %nextptr
  %emptycontainer = icmp eq i8 %nextchar, %closechar
  br i1 %emptycontainer, label %empty, label %nonempty
empty:
  %emptyend = add i64 %pos, 2
  br label %emit
nonempty:
  %stackptr = getelementptr i8, ptr %stack, i64 %depth
  %kindbyte = trunc i64 %opentype to i8
  store i8 %kindbyte, ptr %stackptr
  %openlevel = add i64 %depth, 1
  br label %emit
closearray:
  br label %close
closeobject:
  br label %close
close:
  %closetype = phi i64 [5, %closearray], [6, %closeobject]
  %closeend = add i64 %pos, 1
  %closedepth = sub i64 %depth, 1
  br label %emit
comma:
  %hasparent = icmp ugt i64 %depth, 0
  br i1 %hasparent, label %parent, label %noparent
parent:
  %parentidx = sub i64 %depth, 1
  %parentptr = getelementptr i8, ptr %stack, i64 %parentidx
  %parentbyte = load i8, ptr %parentptr
  %parenttype = zext i8 %parentbyte to i64
  br label %commatype
noparent:
  br label %commatype
commatype:
  %commacolor = phi i64 [%parenttype, %parent], [5, %noparent]
  %commaend = add i64 %pos, 1
  br label %emit
colon:
  %colonend = add i64 %pos, 1
  br label %emit
string:
  %stringstart = add i64 %pos, 1
  br label %stringloop
stringloop:
  %si = phi i64 [%stringstart, %string], [%sinext, %stringadvance], [%escapeend, %escaped]
  %smore = icmp ult i64 %si, %length
  br i1 %smore, label %stringbody, label %stringclosed
stringbody:
  %sp = getelementptr i8, ptr %source, i64 %si
  %sc = load i8, ptr %sp
  %slash = icmp eq i8 %sc, 92
  %quote = icmp eq i8 %sc, 34
  br i1 %slash, label %escaped, label %quotecheck
escaped:
  %escapeend = add i64 %si, 2
  br label %stringloop
quotecheck:
  br i1 %quote, label %stringclosed, label %stringadvance
stringadvance:
  %sinext = add i64 %si, 1
  br label %stringloop
stringclosed:
  %stringend = add i64 %si, 1
  br label %keyloop
keyloop:
  %ki = phi i64 [%stringend, %stringclosed], [%kinext, %keywhite]
  %kmore = icmp ult i64 %ki, %length
  br i1 %kmore, label %keybody, label %valuecolor
keybody:
  %kp = getelementptr i8, ptr %source, i64 %ki
  %kc = load i8, ptr %kp
  %keyspace = icmp ule i8 %kc, 32
  br i1 %keyspace, label %keywhite, label %keycheck
keywhite:
  %kinext = add i64 %ki, 1
  br label %keyloop
keycheck:
  %iskey = icmp eq i8 %kc, 58
  br i1 %iskey, label %keycolor, label %valuecolor
keycolor:
  br label %stringcolor
valuecolor:
  br label %stringcolor
stringcolor:
  %strtype = phi i64 [7, %keycolor], [4, %valuecolor]
  br label %emit
primitive:
  switch i8 %c, label %number [i8 110, label %null i8 102, label %false i8 116, label %true]
null:
  br label %primstart
false:
  br label %primstart
true:
  br label %primstart
number:
  br label %primstart
primstart:
  %primtype = phi i64 [0, %null], [1, %false], [2, %true], [3, %number]
  br label %primloop
primloop:
  %pi = phi i64 [%pos, %primstart], [%pinext, %primadvance]
  %pmore = icmp ult i64 %pi, %length
  br i1 %pmore, label %primbody, label %primdone
primbody:
  %pp = getelementptr i8, ptr %source, i64 %pi
  %pc = load i8, ptr %pp
  %pspace = icmp ule i8 %pc, 32
  br i1 %pspace, label %primdone, label %primcheck
primcheck:
  switch i8 %pc, label %primadvance [i8 44, label %primdone i8 93, label %primdone i8 125, label %primdone]
primadvance:
  %pinext = add i64 %pi, 1
  br label %primloop
primdone:
  br label %emit
emit:
  %type = phi i64 [%opentype, %empty], [%opentype, %nonempty], [%closetype, %close], [%commacolor, %commatype], [6, %colon], [%strtype, %stringcolor], [%primtype, %primdone]
  %end = phi i64 [%emptyend, %empty], [%opennext, %nonempty], [%closeend, %close], [%commaend, %commatype], [%colonend, %colon], [%stringend, %stringcolor], [%pi, %primdone]
  %newdepth = phi i64 [%depth, %empty], [%openlevel, %nonempty], [%closedepth, %close], [%depth, %commatype], [%depth, %colon], [%depth, %stringcolor], [%depth, %primdone]
  %color = call ptr @j_at(ptr %palette, i64 %type)
  %colorptr = call ptr @b_data(ptr %color)
  %colorlen = call i64 @b_len(ptr %color)
  %dst = getelementptr i8, ptr %out, i64 %written
  store i8 27, ptr %dst
  %bracket = getelementptr i8, ptr %dst, i64 1
  store i8 91, ptr %bracket
  %colorslot = getelementptr i8, ptr %dst, i64 2
  call void @j_copy(ptr %colorslot, ptr %colorptr, i64 %colorlen)
  %suffix = getelementptr i8, ptr %colorslot, i64 %colorlen
  store i8 109, ptr %suffix
  %tokenptr = getelementptr i8, ptr %suffix, i64 1
  %tokenlen = sub i64 %end, %pos
  call void @j_copy(ptr %tokenptr, ptr %src, i64 %tokenlen)
  %resetptr = getelementptr i8, ptr %tokenptr, i64 %tokenlen
  call void @j_copy(ptr %resetptr, ptr @col.reset, i64 4)
  %added0 = add i64 %colorlen, %tokenlen
  %added = add i64 %added0, 7
  %newwritten = add i64 %written, %added
  br label %advance
advance:
  %positionnext = add i64 %end, 0
  %writenext = add i64 %newwritten, 0
  %depthnext = add i64 %newdepth, 0
  br label %loop
done:
  %result = call ptr @j_str(ptr %out, i64 %written)
  ret ptr %result
}
