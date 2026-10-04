@p.start = private constant [6 x i8] c"start\00"
@p.end = private constant [4 x i8] c"end\00"
@p.errpaths = private constant [36 x i8] c"Paths must be specified as an array\00"
@p.errpath = private constant [35 x i8] c"Path must be specified as an array\00"
@p.errdeep = private constant [14 x i8] c"Path too deep\00"
@j_error = external global ptr

declare i32 @b_tag(ptr)
declare i64 @b_len(ptr)
declare ptr @b_data(ptr)
declare double @b_number(ptr)
declare ptr @b_keys(ptr, i1)
declare i1 @b_has(ptr, ptr)
declare ptr @j_null()
declare ptr @j_num(double)
declare ptr @j_cstr(ptr)
declare ptr @j_array()
declare ptr @j_object()
declare void @j_push(ptr, ptr)
declare void @j_put(ptr, ptr, ptr)
declare ptr @j_at(ptr, i64)
declare ptr @j_get(ptr, ptr)
declare ptr @j_clone(ptr)
declare i32 @j_cmp(ptr, ptr)
declare void @j_fail(ptr)
declare ptr @t_explode(ptr)
declare ptr @t_implode(ptr)
declare double @m_floor(double)
declare double @m_ceil(double)

define i64 @p_index(ptr %key, i64 %len, i64 %default, i1 %ceil) {
entry:
  %tag = call i32 @b_tag(ptr %key)
  %nil = icmp eq i32 %tag, 0
  br i1 %nil, label %fallback, label %number
fallback:
  ret i64 %default
number:
  %f = call double @b_number(ptr %key)
  %nan = fcmp uno double %f, %f
  br i1 %nan, label %fallback, label %round
round:
  %floor = call double @m_floor(double %f)
  %ceiling = call double @m_ceil(double %f)
  %rounded = select i1 %ceil, double %ceiling, double %floor
  %lf = sitofp i64 %len to double
  %negative = fcmp olt double %rounded, 0.000000e+00
  %relative = fadd double %rounded, %lf
  %adjusted = select i1 %negative, double %relative, double %rounded
  %low = fcmp olt double %adjusted, 0.000000e+00
  %high = fcmp ogt double %adjusted, %lf
  %abovezero = select i1 %low, double 0.000000e+00, double %adjusted
  %bounded = select i1 %high, double %lf, double %abovezero
  %idx = fptosi double %bounded to i64
  ret i64 %idx
}

define void @p_expand(ptr %input, ptr %path, i64 %pos, ptr %prefix, ptr %out) {
entry:
  %pn = call i64 @b_len(ptr %path)
  %done = icmp uge i64 %pos, %pn
  br i1 %done, label %emit, label %start
emit:
  call void @j_push(ptr %out, ptr %prefix)
  ret void
start:
  %key = call ptr @j_at(ptr %path, i64 %pos)
  %kt = call i32 @b_tag(ptr %key)
  %it = call i32 @b_tag(ptr %input)
  %nil = icmp eq i32 %it, 0
  br i1 %nil, label %return, label %kind
kind:
  %nextpos = add i64 %pos, 1
  switch i32 %kt, label %invalid [i32 3, label %index i32 4, label %field i32 6, label %slice]
index:
  %arr = icmp eq i32 %it, 5
  br i1 %arr, label %indexcheck, label %invalid
indexcheck:
  %len = call i64 @b_len(ptr %input)
  %f = call double @b_number(ptr %key)
  %whole = call double @m_floor(double %f)
  %lf = sitofp i64 %len to double
  %negative = fcmp olt double %whole, 0.000000e+00
  %relative = fadd double %whole, %lf
  %adjusted = select i1 %negative, double %relative, double %whole
  %lo = fcmp oge double %adjusted, 0.000000e+00
  %hi = fcmp olt double %adjusted, %lf
  %validindex = and i1 %lo, %hi
  br i1 %validindex, label %indexchild, label %return
indexchild:
  %idx = fptosi double %adjusted to i64
  %indexkey = call ptr @j_num(double %adjusted)
  %indexvalue = call ptr @j_at(ptr %input, i64 %idx)
  br label %descend
field:
  %obj = icmp eq i32 %it, 6
  br i1 %obj, label %fieldcheck, label %invalid
fieldcheck:
  %exists = call i1 @b_has(ptr %input, ptr %key)
  br i1 %exists, label %fieldchild, label %return
fieldchild:
  %fieldvalue = call ptr @j_get(ptr %input, ptr %key)
  br label %descend
descend:
  %childkey = phi ptr [%indexkey, %indexchild], [%key, %fieldchild]
  %childvalue = phi ptr [%indexvalue, %indexchild], [%fieldvalue, %fieldchild]
  %childpath = call ptr @j_clone(ptr %prefix)
  call void @j_push(ptr %childpath, ptr %childkey)
  call void @p_expand(ptr %childvalue, ptr %path, i64 %nextpos, ptr %childpath, ptr %out)
  ret void
slice:
  %sarray = icmp eq i32 %it, 5
  %sstring = icmp eq i32 %it, 4
  %svalid = or i1 %sarray, %sstring
  br i1 %svalid, label %sliceinput, label %invalid
sliceinput:
  br i1 %sstring, label %explode, label %original
explode:
  %codepoints = call ptr @t_explode(ptr %input)
  br label %slicevalues
original:
  br label %slicevalues
slicevalues:
  %src = phi ptr [%codepoints, %explode], [%input, %original]
  %sn = call i64 @b_len(ptr %src)
  %startkey = call ptr @j_cstr(ptr @p.start)
  %endkey = call ptr @j_cstr(ptr @p.end)
  %startvalue = call ptr @j_get(ptr %key, ptr %startkey)
  %endvalue = call ptr @j_get(ptr %key, ptr %endkey)
  %begin = call i64 @p_index(ptr %startvalue, i64 %sn, i64 0, i1 false)
  %end0 = call i64 @p_index(ptr %endvalue, i64 %sn, i64 %sn, i1 true)
  %inverted = icmp slt i64 %end0, %begin
  %end = select i1 %inverted, i64 %begin, i64 %end0
  %terminal = icmp eq i64 %nextpos, %pn
  br i1 %terminal, label %sliceloop, label %slicebuild
sliceloop:
  %si = phi i64 [%begin, %slicevalues], [%sinext, %sliceemit]
  %simore = icmp slt i64 %si, %end
  br i1 %simore, label %sliceemit, label %return
sliceemit:
  %sif = sitofp i64 %si to double
  %sik = call ptr @j_num(double %sif)
  %sp = call ptr @j_clone(ptr %prefix)
  call void @j_push(ptr %sp, ptr %sik)
  call void @j_push(ptr %out, ptr %sp)
  %sinext = add i64 %si, 1
  br label %sliceloop
slicebuild:
  %subarray = call ptr @j_array()
  br label %buildloop
buildloop:
  %bi = phi i64 [%begin, %slicebuild], [%binext, %buildbody]
  %bimore = icmp slt i64 %bi, %end
  br i1 %bimore, label %buildbody, label %expandchild
buildbody:
  %bv = call ptr @j_at(ptr %src, i64 %bi)
  call void @j_push(ptr %subarray, ptr %bv)
  %binext = add i64 %bi, 1
  br label %buildloop
expandchild:
  %subprefix = call ptr @j_array()
  %subpaths = call ptr @j_array()
  call void @p_expand(ptr %subarray, ptr %path, i64 %nextpos, ptr %subprefix, ptr %subpaths)
  %subn = call i64 @b_len(ptr %subpaths)
  br label %translate
translate:
  %ti = phi i64 [0, %expandchild], [%tinext, %translated]
  %timore = icmp slt i64 %ti, %subn
  br i1 %timore, label %translatebody, label %return
translatebody:
  %subpath = call ptr @j_at(ptr %subpaths, i64 %ti)
  %subindex = call ptr @j_at(ptr %subpath, i64 0)
  %subindexf = call double @b_number(ptr %subindex)
  %beginf = sitofp i64 %begin to double
  %absolute = fadd double %subindexf, %beginf
  %absolutekey = call ptr @j_num(double %absolute)
  %newpath = call ptr @j_clone(ptr %prefix)
  call void @j_push(ptr %newpath, ptr %absolutekey)
  %subpathlen = call i64 @b_len(ptr %subpath)
  br label %copytail
copytail:
  %j = phi i64 [1, %translatebody], [%jnext, %copybody]
  %jmore = icmp slt i64 %j, %subpathlen
  br i1 %jmore, label %copybody, label %translated
copybody:
  %tailkey = call ptr @j_at(ptr %subpath, i64 %j)
  call void @j_push(ptr %newpath, ptr %tailkey)
  %jnext = add i64 %j, 1
  br label %copytail
translated:
  call void @j_push(ptr %out, ptr %newpath)
  %tinext = add i64 %ti, 1
  br label %translate
invalid:
  %errorvalue = call ptr @j_get(ptr %input, ptr %key)
  ret void
return:
  ret void
}

define ptr @p_delete(ptr %input, ptr %paths, i64 %level) {
entry:
  %pn = call i64 @b_len(ptr %paths)
  %empty = icmp eq i64 %pn, 0
  br i1 %empty, label %same, label %rootloop
same:
  ret ptr %input
rootloop:
  %ri = phi i64 [0, %entry], [%rinext, %rootbody]
  %rmore = icmp slt i64 %ri, %pn
  br i1 %rmore, label %rootbody, label %start
rootbody:
  %rp = call ptr @j_at(ptr %paths, i64 %ri)
  %rlen = call i64 @b_len(ptr %rp)
  %root = icmp eq i64 %rlen, %level
  %rinext = add i64 %ri, 1
  br i1 %root, label %deleted, label %rootloop
deleted:
  ret ptr null
start:
  %tag = call i32 @b_tag(ptr %input)
  %obj = icmp eq i32 %tag, 6
  %str = icmp eq i32 %tag, 4
  br i1 %str, label %explode, label %original
explode:
  %codepoints = call ptr @t_explode(ptr %input)
  br label %source
original:
  br label %source
source:
  %src = phi ptr [%codepoints, %explode], [%input, %original]
  %keys = call ptr @b_keys(ptr %src, i1 false)
  %n = call i64 @b_len(ptr %keys)
  %ln = add i64 %level, 1
  br i1 %obj, label %newobject, label %newarray
newobject:
  %o = call ptr @j_object()
  br label %outer
newarray:
  %a = call ptr @j_array()
  br label %outer
outer:
  %out = phi ptr [%o, %newobject], [%a, %newarray], [%out, %advance]
  %i = phi i64 [0, %newobject], [0, %newarray], [%next, %advance]
  %more = icmp slt i64 %i, %n
  br i1 %more, label %body, label %done
body:
  %key = call ptr @j_at(ptr %keys, i64 %i)
  %value = call ptr @j_get(ptr %src, ptr %key)
  %matching = call ptr @j_array()
  br label %inner
inner:
  %j = phi i64 [0, %body], [%jnext, %matchadvance]
  %jmore = icmp slt i64 %j, %pn
  br i1 %jmore, label %matchbody, label %apply
matchbody:
  %path = call ptr @j_at(ptr %paths, i64 %j)
  %pathkey = call ptr @j_at(ptr %path, i64 %level)
  %cmp = call i32 @j_cmp(ptr %key, ptr %pathkey)
  %match = icmp eq i32 %cmp, 0
  br i1 %match, label %matchput, label %matchadvance
matchput:
  call void @j_push(ptr %matching, ptr %path)
  br label %matchadvance
matchadvance:
  %jnext = add i64 %j, 1
  br label %inner
apply:
  %child = call ptr @p_delete(ptr %value, ptr %matching, i64 %ln)
  %removed = icmp eq ptr %child, null
  br i1 %removed, label %advance, label %put
put:
  br i1 %obj, label %putobject, label %putarray
putobject:
  call void @j_put(ptr %out, ptr %key, ptr %child)
  br label %advance
putarray:
  call void @j_push(ptr %out, ptr %child)
  br label %advance
advance:
  %next = add i64 %i, 1
  br label %outer
done:
  br i1 %str, label %implode, label %return
implode:
  %string = call ptr @t_implode(ptr %out)
  ret ptr %string
return:
  ret ptr %out
}

define ptr @b_delete_many(ptr %input, ptr %paths) {
entry:
  %tag = call i32 @b_tag(ptr %paths)
  %valid = icmp eq i32 %tag, 5
  br i1 %valid, label %start, label %invalid
invalid:
  call void @j_fail(ptr @p.errpaths)
  ret ptr %input
start:
  %normalized = call ptr @j_array()
  %prefix = call ptr @j_array()
  %n = call i64 @b_len(ptr %paths)
  br label %loop
loop:
  %i = phi i64 [0, %start], [%next, %expanded]
  %more = icmp slt i64 %i, %n
  br i1 %more, label %body, label %apply
body:
  %path = call ptr @j_at(ptr %paths, i64 %i)
  %pt = call i32 @b_tag(ptr %path)
  %pathvalid = icmp eq i32 %pt, 5
  br i1 %pathvalid, label %depthcheck, label %invalidpath
invalidpath:
  call void @j_fail(ptr @p.errpath)
  ret ptr %input
depthcheck:
  %len = call i64 @b_len(ptr %path)
  %too = icmp sgt i64 %len, 10000
  br i1 %too, label %toodeep, label %expand
toodeep:
  call void @j_fail(ptr @p.errdeep)
  ret ptr %input
expand:
  call void @p_expand(ptr %input, ptr %path, i64 0, ptr %prefix, ptr %normalized)
  %error = load ptr, ptr @j_error
  %failed = icmp ne ptr %error, null
  br i1 %failed, label %abort, label %expanded
abort:
  ret ptr %input
expanded:
  %next = add i64 %i, 1
  br label %loop
apply:
  %deleted = call ptr @p_delete(ptr %input, ptr %normalized, i64 0)
  %root = icmp eq ptr %deleted, null
  br i1 %root, label %null, label %done
null:
  %nil = call ptr @j_null()
  ret ptr %nil
done:
  ret ptr %deleted
}
