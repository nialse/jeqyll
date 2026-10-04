define internal i64 @tzv_be(ptr %data, i64 %offset, i64 %width) {
entry:
  br label %loop
loop:
  %i = phi i64 [0, %entry], [%next, %body]
  %value = phi i64 [0, %entry], [%joined, %body]
  %more = icmp ult i64 %i, %width
  br i1 %more, label %body, label %done
body:
  %index = add i64 %offset, %i
  %p = getelementptr i8, ptr %data, i64 %index
  %c = load i8, ptr %p
  %wide = zext i8 %c to i64
  %shifted = shl i64 %value, 8
  %joined = or i64 %shifted, %wide
  %next = add i64 %i, 1
  br label %loop
done:
  ret i64 %value
}

define internal i64 @tzv_block(ptr %data, i64 %length, i64 %start, i64 %width) {
entry:
  %headerend = add i64 %start, 44
  %enough = icmp ule i64 %headerend, %length
  br i1 %enough, label %header, label %bad
header:
  %magic = call i64 @tzv_be(ptr %data, i64 %start, i64 4)
  %correct = icmp eq i64 %magic, 1415211366
  br i1 %correct, label %counts, label %bad
counts:
  %utp = add i64 %start, 20
  %stdp = add i64 %start, 24
  %leapp = add i64 %start, 28
  %timep = add i64 %start, 32
  %typep = add i64 %start, 36
  %charp = add i64 %start, 40
  %utcount = call i64 @tzv_be(ptr %data, i64 %utp, i64 4)
  %stdcount = call i64 @tzv_be(ptr %data, i64 %stdp, i64 4)
  %leapcount = call i64 @tzv_be(ptr %data, i64 %leapp, i64 4)
  %timecount = call i64 @tzv_be(ptr %data, i64 %timep, i64 4)
  %typecount = call i64 @tzv_be(ptr %data, i64 %typep, i64 4)
  %charcount = call i64 @tzv_be(ptr %data, i64 %charp, i64 4)
  %typesnonzero = icmp ugt i64 %typecount, 0
  %typesfit = icmp ule i64 %typecount, 256
  %charsnonzero = icmp ugt i64 %charcount, 0
  %utnone = icmp eq i64 %utcount, 0
  %utall = icmp eq i64 %utcount, %typecount
  %utvalid = or i1 %utnone, %utall
  %stdnone = icmp eq i64 %stdcount, 0
  %stdall = icmp eq i64 %stdcount, %typecount
  %stdvalid = or i1 %stdnone, %stdall
  %ok0 = and i1 %typesnonzero, %typesfit
  %ok1 = and i1 %charsnonzero, %utvalid
  %ok2 = and i1 %ok0, %ok1
  %ok = and i1 %ok2, %stdvalid
  br i1 %ok, label %extent, label %bad
extent:
  %timebytes = mul i64 %timecount, %width
  %indices = add i64 %headerend, %timebytes
  %types = add i64 %indices, %timecount
  %typebytes = mul i64 %typecount, 6
  %names = add i64 %types, %typebytes
  %namesend = add i64 %names, %charcount
  %leapwidth = add i64 %width, 4
  %leapbytes = mul i64 %leapcount, %leapwidth
  %flags = add i64 %namesend, %leapbytes
  %flagcount = add i64 %stdcount, %utcount
  %end = add i64 %flags, %flagcount
  %fits = icmp ule i64 %end, %length
  br i1 %fits, label %transitions, label %bad
transitions:
  %ti = phi i64 [0, %extent], [%tnext, %transitionvalue]
  %previous = phi i64 [-9223372036854775808, %extent], [%when, %transitionvalue]
  %timesleft = icmp ult i64 %ti, %timecount
  br i1 %timesleft, label %transitionread, label %typesloop
transitionread:
  %toffset = mul i64 %ti, %width
  %tposition = add i64 %headerend, %toffset
  %rawtime = call i64 @tzv_be(ptr %data, i64 %tposition, i64 %width)
  %shorttime = trunc i64 %rawtime to i32
  %signedtime = sext i32 %shorttime to i64
  %is32 = icmp eq i64 %width, 4
  %when = select i1 %is32, i64 %signedtime, i64 %rawtime
  %first = icmp eq i64 %ti, 0
  %later = icmp sgt i64 %when, %previous
  %ordered = or i1 %first, %later
  %iposition = add i64 %indices, %ti
  %ip = getelementptr i8, ptr %data, i64 %iposition
  %indexbyte = load i8, ptr %ip
  %index = zext i8 %indexbyte to i64
  %validindex = icmp ult i64 %index, %typecount
  %transitionvalid = and i1 %ordered, %validindex
  br i1 %transitionvalid, label %transitionvalue, label %bad
transitionvalue:
  %tnext = add i64 %ti, 1
  br label %transitions
typesloop:
  %yi = phi i64 [0, %transitions], [%ynext, %typeadvance]
  %typesleft = icmp ult i64 %yi, %typecount
  br i1 %typesleft, label %typeread, label %flagsloop
typeread:
  %yoffset = mul i64 %yi, 6
  %yposition = add i64 %types, %yoffset
  %utoffset = call i64 @tzv_be(ptr %data, i64 %yposition, i64 4)
  %offsetvalid = icmp ne i64 %utoffset, 2147483648
  %dstposition = add i64 %yposition, 4
  %nameposition = add i64 %yposition, 5
  %dstp = getelementptr i8, ptr %data, i64 %dstposition
  %namep = getelementptr i8, ptr %data, i64 %nameposition
  %dst = load i8, ptr %dstp
  %namebyte = load i8, ptr %namep
  %dstvalid = icmp ule i8 %dst, 1
  %nameindex = zext i8 %namebyte to i64
  %namevalid = icmp ult i64 %nameindex, %charcount
  %typevalid0 = and i1 %offsetvalid, %dstvalid
  %typevalid = and i1 %typevalid0, %namevalid
  %namestart = add i64 %names, %nameindex
  br i1 %typevalid, label %nameloop, label %bad
nameloop:
  %ni = phi i64 [%namestart, %typeread], [%nnext, %namebody]
  %nameleft = icmp ult i64 %ni, %namesend
  br i1 %nameleft, label %namebody, label %bad
namebody:
  %np = getelementptr i8, ptr %data, i64 %ni
  %nc = load i8, ptr %np
  %terminated = icmp eq i8 %nc, 0
  %nnext = add i64 %ni, 1
  br i1 %terminated, label %typeadvance, label %nameloop
typeadvance:
  %ynext = add i64 %yi, 1
  br label %typesloop
flagsloop:
  %fi = phi i64 [0, %typesloop], [%fnext, %flagbody]
  %flagsleft = icmp ult i64 %fi, %flagcount
  br i1 %flagsleft, label %flagbody, label %done
flagbody:
  %fposition = add i64 %flags, %fi
  %fp = getelementptr i8, ptr %data, i64 %fposition
  %flag = load i8, ptr %fp
  %flagvalid = icmp ule i8 %flag, 1
  %fnext = add i64 %fi, 1
  br i1 %flagvalid, label %flagsloop, label %bad
done:
  ret i64 %end
bad:
  ret i64 -1
}

define i1 @j_tzif_valid(ptr %data, i64 %length) {
entry:
  %minimum = icmp uge i64 %length, 44
  br i1 %minimum, label %version, label %bad
version:
  %vp = getelementptr i8, ptr %data, i64 4
  %v = load i8, ptr %vp
  %v1 = icmp eq i8 %v, 0
  %v2 = icmp eq i8 %v, 50
  %v3 = icmp eq i8 %v, 51
  %v4 = icmp eq i8 %v, 52
  %v12 = or i1 %v1, %v2
  %v34 = or i1 %v3, %v4
  %valid = or i1 %v12, %v34
  br i1 %valid, label %first, label %bad
first:
  %firstend = call i64 @tzv_block(ptr %data, i64 %length, i64 0, i64 4)
  %firstok = icmp sge i64 %firstend, 0
  br i1 %firstok, label %secondcheck, label %bad
secondcheck:
  br i1 %v1, label %good, label %second
second:
  %secondend = call i64 @tzv_block(ptr %data, i64 %length, i64 %firstend, i64 8)
  %secondok = icmp sge i64 %secondend, 0
  br i1 %secondok, label %footercheck, label %bad
footercheck:
  %v2offset = add i64 %firstend, 4
  %v2p = getelementptr i8, ptr %data, i64 %v2offset
  %vsecond = load i8, ptr %v2p
  %sameversion = icmp eq i8 %vsecond, %v
  %minimumend = add i64 %secondend, 2
  %footerfits = icmp ule i64 %minimumend, %length
  %footerpossible = and i1 %sameversion, %footerfits
  br i1 %footerpossible, label %footer, label %bad
footer:
  %begin = getelementptr i8, ptr %data, i64 %secondend
  %lastindex = sub i64 %length, 1
  %last = getelementptr i8, ptr %data, i64 %lastindex
  %beginc = load i8, ptr %begin
  %lastc = load i8, ptr %last
  %startsline = icmp eq i8 %beginc, 10
  %endsline = icmp eq i8 %lastc, 10
  %lines = and i1 %startsline, %endsline
  br i1 %lines, label %good, label %bad
good:
  ret i1 true
bad:
  ret i1 false
}
