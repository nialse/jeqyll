@m.names = private constant [426 x i8] c"abs\00fabs\00floor\00ceil\00round\00trunc\00rint\00nearbyint\00sqrt\00pow\00exp\00exp2\00exp10\00log\00log2\00log10\00sin\00cos\00tan\00atan\00asin\00acos\00atan2\00hypot\00sinh\00cosh\00tanh\00asinh\00acosh\00atanh\00cbrt\00fmod\00remainder\00drem\00modf\00frexp\00ldexp\00scalbn\00scalb\00significand\00logb\00ilogb\00expm1\00log1p\00infinite\00nan\00isinfinite\00isnan\00isfinite\00isnormal\00finites\00normals\00fmax\00fmin\00fdim\00copysign\00nextafter\00nexttoward\00erf\00erfc\00tgamma\00gamma\00lgamma\00lgamma_r\00j0\00j1\00y0\00y1\00jn\00yn\00fma\00scalbln\00\00"
@m.errnumber = private constant [16 x i8] c"number required\00"
@j_error = external global ptr

declare i32 @b_find(ptr, ptr)
declare i32 @b_tag(ptr)
declare i64 @b_len(ptr)
declare double @b_number(ptr)
declare ptr @b_one(ptr)
declare ptr @b_arg(ptr, i64, ptr, ptr)
declare void @b_type_error(ptr, ptr)
declare void @b_pushvalid(ptr, ptr)
declare ptr @j_num(double)
declare ptr @j_bool(i1)
declare ptr @j_null()
declare ptr @j_array()
declare void @j_push(ptr, ptr)
declare ptr @j_at(ptr, i64)
declare ptr @j_negate(ptr)
declare i32 @j_cmp(ptr, ptr)
declare double @llvm.fabs.f64(double)
declare double @llvm.sqrt.f64(double)
declare i64 @llvm.ctlz.i64(i64, i1)
declare double @m_scale_bits(double, i64)
declare double @m_fmod_bits(double, double)
declare double @m_remainder_bits(double, double)
declare double @m_atan2_bits(double, double)
declare double @m_hypot_bits(double, double)
declare double @m_fma(double, double, double)
declare double @m_expm1(double)
declare double @m_log1p(double)
declare double @m_pow(double, double)
declare double @m_erf(double, i1)
declare double @m_lgamma(double, ptr)
declare double @m_gamma(double)
declare double @m_bessel(double, double, i1)
declare double @m_trig(double, i1)
declare double @m_hyperbolic(i32, double)
declare double @m_cbrt(double)

define double @m_trunc(double %x) {
entry:
  %raw = bitcast double %x to i64
  %shifted = lshr i64 %raw, 52
  %ebits = and i64 %shifted, 2047
  %exp = sub i64 %ebits, 1023
  %negativeexp = icmp slt i64 %exp, 0
  br i1 %negativeexp, label %zero, label %fraction
zero:
  %sign = and i64 %raw, -9223372036854775808
  %z = bitcast i64 %sign to double
  ret double %z
fraction:
  %integral = icmp sge i64 %exp, 52
  br i1 %integral, label %same, label %mask
mask:
  %bits = sub i64 52, %exp
  %one = shl i64 1, %bits
  %lowmask = sub i64 %one, 1
  %keep = xor i64 %lowmask, -1
  %value = and i64 %raw, %keep
  %result = bitcast i64 %value to double
  ret double %result
same:
  ret double %x
}

define double @m_floor(double %x) {
entry:
  %t = call double @m_trunc(double %x)
  %down = fcmp ogt double %t, %x
  %d = fsub double %t, 1.000000e+00
  %r = select i1 %down, double %d, double %t
  ret double %r
}

define double @m_ceil(double %x) {
entry:
  %t = call double @m_trunc(double %x)
  %up = fcmp olt double %t, %x
  %u = fadd double %t, 1.000000e+00
  %r = select i1 %up, double %u, double %t
  ret double %r
}

define double @m_round(double %x, i1 %even) {
entry:
  %t = call double @m_trunc(double %x)
  %f = fsub double %x, %t
  %a = call double @llvm.fabs.f64(double %f)
  %more = fcmp ogt double %a, 5.000000e-01
  %half = fcmp oeq double %a, 5.000000e-01
  %away = xor i1 %even, true
  %halfaway = and i1 %half, %away
  %h = fdiv double %t, 2.000000e+00
  %ht = call double @m_trunc(double %h)
  %odd = fcmp one double %h, %ht
  %halfodd = and i1 %half, %odd
  %move0 = or i1 %more, %halfaway
  %move = or i1 %move0, %halfodd
  %negative = fcmp olt double %x, 0.000000e+00
  %delta = select i1 %negative, double -1.000000e+00, double 1.000000e+00
  %rounded = fadd double %t, %delta
  %r = select i1 %move, double %rounded, double %t
  ret double %r
}

define double @m_scale2(double %x, i64 %power) {
entry:
  %result = call double @m_scale_bits(double %x, i64 %power)
  ret double %result
}

define double @m_exp(double %x) {
entry:
  %overflow = fcmp ogt double %x, 7.0978271289338397e+02
  %underflow = fcmp olt double %x, -7.4513321910194111e+02
  %nan = fcmp uno double %x, %x
  br i1 %nan, label %same, label %check
same:
  ret double %x
check:
  br i1 %overflow, label %inf, label %checkunder
inf:
  ret double 0x7FF0000000000000
checkunder:
  br i1 %underflow, label %zero, label %start
zero:
  ret double 0.000000e+00
start:
  %q = fmul double %x, 1.4426950408889634e+00
  %round = call double @m_round(double %q, i1 false)
  %n = fptosi double %round to i64
  %ln2hi = fmul double %round, 6.9314718036912382e-01
  %ln2lo = fmul double %round, 1.9082149292705877e-10
  %r0 = fsub double %x, %ln2hi
  %r = fsub double %r0, %ln2lo
  br label %loop
loop:
  %i = phi i64 [1, %start], [%next, %body]
  %term = phi double [1.000000e+00, %start], [%tn, %body]
  %sum = phi double [1.000000e+00, %start], [%sn, %body]
  %correction = phi double [0.000000e+00, %start], [%cn, %body]
  %more = icmp sle i64 %i, 20
  br i1 %more, label %body, label %done
body:
  %f = sitofp i64 %i to double
  %product = fmul double %term, %r
  %tn = fdiv double %product, %f
  %adjustedterm = fsub double %tn, %correction
  %sn = fadd double %sum, %adjustedterm
  %diff = fsub double %sn, %sum
  %cn = fsub double %diff, %adjustedterm
  %next = add i64 %i, 1
  br label %loop
done:
  %result = call double @m_scale2(double %sum, i64 %n)
  ret double %result
}

define double @m_log(double %x) {
entry:
  %zero = fcmp oeq double %x, 0.000000e+00
  %negative = fcmp olt double %x, 0.000000e+00
  %nan = fcmp uno double %x, %x
  %bad = or i1 %negative, %nan
  br i1 %zero, label %neginf, label %check
neginf:
  ret double 0xFFF0000000000000
check:
  br i1 %bad, label %invalid, label %infinity
invalid:
  ret double 0x7FF8000000000000
infinity:
  %inf = fcmp oeq double %x, 0x7FF0000000000000
  br i1 %inf, label %same, label %start
same:
  ret double %x
start:
  %raw = bitcast double %x to i64
  %es = lshr i64 %raw, 52
  %eb = and i64 %es, 2047
  %sub = icmp eq i64 %eb, 0
  br i1 %sub, label %subnormal, label %normal
subnormal:
  %scaled = fmul double %x, 4.503599627370496e+15
  %lr = call double @m_log(double %scaled)
  %adjusted = fsub double %lr, 3.6043653389117154e+01
  ret double %adjusted
normal:
  %exp0 = sub i64 %eb, 1023
  %man0 = and i64 %raw, 4503599627370495
  %manbits = or i64 %man0, 4607182418800017408
  %man0value = bitcast i64 %manbits to double
  %reduce = fcmp ogt double %man0value, 1.4142135623730951e+00
  %halfman = fmul double %man0value, 5.000000e-01
  %man = select i1 %reduce, double %halfman, double %man0value
  %increment = zext i1 %reduce to i64
  %exp = add i64 %exp0, %increment
  %num = fsub double %man, 1.000000e+00
  %den = fadd double %man, 1.000000e+00
  %y = fdiv double %num, %den
  %y2 = fmul double %y, %y
  br label %loop
loop:
  %i = phi i64 [3, %normal], [%next, %body]
  %term = phi double [%y, %normal], [%tn, %body]
  %sum = phi double [%y, %normal], [%sn, %body]
  %correction = phi double [0.000000e+00, %normal], [%cn, %body]
  %more = icmp sle i64 %i, 61
  br i1 %more, label %body, label %done
body:
  %tn = fmul double %term, %y2
  %f = sitofp i64 %i to double
  %add = fdiv double %tn, %f
  %adjustedterm = fsub double %add, %correction
  %sn = fadd double %sum, %adjustedterm
  %diff = fsub double %sn, %sum
  %cn = fsub double %diff, %adjustedterm
  %next = add i64 %i, 2
  br label %loop
done:
  %logman = fmul double %sum, 2.000000e+00
  %ef = sitofp i64 %exp to double
  %loghi = fmul double %ef, 6.9314718036912382e-01
  %loglo = fmul double %ef, 1.9082149292705877e-10
  %lowresult = fadd double %logman, %loglo
  %result = fadd double %loghi, %lowresult
  ret double %result
}

define double @m_pow_finite(double %x, double %y) {
entry:
  %zero = fcmp oeq double %y, 0.000000e+00
  br i1 %zero, label %one, label %check
one:
  ret double 1.000000e+00
check:
  %yt = call double @m_trunc(double %y)
  %int = fcmp oeq double %yt, %y
  %ay = call double @llvm.fabs.f64(double %y)
  %small = fcmp olt double %ay, 9.007199254740992e+15
  %integer = and i1 %int, %small
  br i1 %integer, label %integral, label %fractional
integral:
  %power = fptosi double %ay to i64
  %negative = fcmp olt double %y, 0.000000e+00
  %reciprocal = fdiv double 1.000000e+00, %x
  %initial = select i1 %negative, double %reciprocal, double %x
  br label %loop
loop:
  %n = phi i64 [%power, %integral], [%nn, %body]
  %base = phi double [%initial, %integral], [%bn, %body]
  %acc = phi double [1.000000e+00, %integral], [%an, %body]
  %directbase = phi double [%x, %integral], [%directbn, %body]
  %directacc = phi double [1.000000e+00, %integral], [%directan, %body]
  %more = icmp sgt i64 %n, 0
  br i1 %more, label %body, label %done
body:
  %bit = and i64 %n, 1
  %odd = icmp ne i64 %bit, 0
  %product = fmul double %acc, %base
  %an = select i1 %odd, double %product, double %acc
  %bn = fmul double %base, %base
  %directproduct = fmul double %directacc, %directbase
  %directan = select i1 %odd, double %directproduct, double %directacc
  %directbn = fmul double %directbase, %directbase
  %nn = lshr i64 %n, 1
  br label %loop
done:
  %directmagnitude = call double @llvm.fabs.f64(double %directacc)
  %directfinite = fcmp olt double %directmagnitude, 0x7FF0000000000000
  %invert = and i1 %negative, %directfinite
  %directinverse = fdiv double 1.000000e+00, %directacc
  %result = select i1 %invert, double %directinverse, double %acc
  ret double %result
fractional:
  %lx = call double @m_log(double %x)
  %exponent = fmul double %lx, %y
  %value = call double @m_exp(double %exponent)
  ret double %value
}

define double @m_sin(double %x) {
entry:
  %result = call double @m_trig(double %x, i1 false)
  ret double %result
}

define double @m_cos(double %x) {
entry:
  %result = call double @m_trig(double %x, i1 true)
  ret double %result
}

define double @m_atan(double %x) {
entry:
  %a = call double @llvm.fabs.f64(double %x)
  %invert = fcmp ogt double %a, 1.000000e+00
  %inv = fdiv double 1.000000e+00, %a
  %u = select i1 %invert, double %inv, double %a
  %reduce = fcmp ogt double %u, 4.1421356237309505e-01
  %num = fsub double %u, 1.000000e+00
  %den = fadd double %u, 1.000000e+00
  %reduced = fdiv double %num, %den
  %r = select i1 %reduce, double %reduced, double %u
  %r2 = fmul double %r, %r
  %negative = fneg double %r2
  br label %loop
loop:
  %i = phi i64 [3, %entry], [%next, %body]
  %term = phi double [%r, %entry], [%tn, %body]
  %sum = phi double [%r, %entry], [%sn, %body]
  %more = icmp sle i64 %i, 49
  br i1 %more, label %body, label %done
body:
  %tn = fmul double %term, %negative
  %f = sitofp i64 %i to double
  %add = fdiv double %tn, %f
  %sn = fadd double %sum, %add
  %next = add i64 %i, 2
  br label %loop
done:
  %adjusted = fadd double %sum, 7.8539816339744828e-01
  %angle = select i1 %reduce, double %adjusted, double %sum
  %inverted = fsub double 1.5707963267948966e+00, %angle
  %absresult = select i1 %invert, double %inverted, double %angle
  %xraw = bitcast double %x to i64
  %neg = icmp slt i64 %xraw, 0
  %negresult = fneg double %absresult
  %result = select i1 %neg, double %negresult, double %absresult
  ret double %result
}

define double @m_unary(i32 %id, double %x) {
entry:
  %specialfunction = icmp uge i32 %id, 58
  br i1 %specialfunction, label %special, label %dispatch
special:
  switch i32 %id, label %bessel [i32 58, label %erf i32 59, label %erf i32 60, label %gamma i32 61, label %lgamma i32 62, label %lgamma]
erf:
  %complement = icmp eq i32 %id, 59
  %er = call double @m_erf(double %x, i1 %complement)
  ret double %er
gamma:
  %ga = call double @m_gamma(double %x)
  ret double %ga
lgamma:
  %signslot = alloca i64
  %lg = call double @m_lgamma(double %x, ptr %signslot)
  ret double %lg
bessel:
  %secondkind = icmp uge i32 %id, 66
  %parity = and i32 %id, 1
  %order = uitofp i32 %parity to double
  %be = call double @m_bessel(double %order, double %x, i1 %secondkind)
  ret double %be
dispatch:
  switch i32 %id, label %logb [i32 0, label %abs i32 1, label %abs i32 2, label %floor i32 3, label %ceil i32 4, label %round i32 5, label %trunc i32 6, label %rint i32 7, label %rint i32 8, label %sqrt i32 10, label %exp i32 11, label %exp2 i32 12, label %exp10 i32 13, label %log i32 14, label %log2 i32 15, label %log10 i32 16, label %sin i32 17, label %cos i32 18, label %tan i32 19, label %atan i32 20, label %asin i32 21, label %acos i32 24, label %sinh i32 25, label %cosh i32 26, label %tanh i32 27, label %asinh i32 28, label %acosh i32 29, label %atanh i32 30, label %cbrt i32 39, label %significand i32 42, label %expm1 i32 43, label %log1p]
abs:
  %absx = call double @llvm.fabs.f64(double %x)
  ret double %absx
floor:
  %floorx = call double @m_floor(double %x)
  ret double %floorx
ceil:
  %ceilx = call double @m_ceil(double %x)
  ret double %ceilx
round:
  %roundx = call double @m_round(double %x, i1 false)
  ret double %roundx
trunc:
  %truncx = call double @m_trunc(double %x)
  ret double %truncx
rint:
  %rintx = call double @m_round(double %x, i1 true)
  ret double %rintx
sqrt:
  %sqrtx = call double @llvm.sqrt.f64(double %x)
  ret double %sqrtx
exp:
  %expx = call double @m_exp(double %x)
  ret double %expx
exp2:
  %exp2x = call double @m_pow(double 2.000000e+00, double %x)
  ret double %exp2x
exp10:
  %exp10x = call double @m_pow(double 1.000000e+01, double %x)
  ret double %exp10x
log:
  %logx = call double @m_log(double %x)
  ret double %logx
log2:
  %log2l = call double @m_log(double %x)
  %log2x = fdiv double %log2l, 6.9314718055994529e-01
  ret double %log2x
log10:
  %log10l = call double @m_log(double %x)
  %log10x = fdiv double %log10l, 2.3025850929940459e+00
  ret double %log10x
sin:
  %sinx = call double @m_sin(double %x)
  ret double %sinx
cos:
  %cosx = call double @m_cos(double %x)
  ret double %cosx
tan:
  %tans = call double @m_sin(double %x)
  %tanc = call double @m_cos(double %x)
  %tanx = fdiv double %tans, %tanc
  ret double %tanx
atan:
  %atanx = call double @m_atan(double %x)
  ret double %atanx
asin:
  %asinxx = fmul double %x, %x
  %asind = fsub double 1.000000e+00, %asinxx
  %asins = call double @llvm.sqrt.f64(double %asind)
  %asinr = fdiv double %x, %asins
  %asinx = call double @m_atan(double %asinr)
  ret double %asinx
acos:
  %acosasin = call double @m_unary(i32 20, double %x)
  %acosx = fsub double 1.5707963267948966e+00, %acosasin
  ret double %acosx
sinh:
  %sinhx = call double @m_hyperbolic(i32 24, double %x)
  ret double %sinhx
cosh:
  %coshx = call double @m_hyperbolic(i32 25, double %x)
  ret double %coshx
tanh:
  %tanha = call double @llvm.fabs.f64(double %x)
  %tanhn = fmul double %tanha, -2.000000e+00
  %tanhnum = call double @m_expm1(double %tanhn)
  %tanhden = fadd double %tanhnum, 2.000000e+00
  %tanhnegative = fdiv double %tanhnum, %tanhden
  %tanhpositive = fneg double %tanhnegative
  %tanhbits = bitcast double %x to i64
  %tanhneg = icmp slt i64 %tanhbits, 0
  %tanhx = select i1 %tanhneg, double %tanhnegative, double %tanhpositive
  ret double %tanhx
asinh:
  %asinhx = call double @m_hyperbolic(i32 27, double %x)
  ret double %asinhx
acosh:
  %acoshx = call double @m_hyperbolic(i32 28, double %x)
  ret double %acoshx
atanh:
  %atanhx = call double @m_hyperbolic(i32 29, double %x)
  ret double %atanhx
cbrt:
  %cbrtx = call double @m_cbrt(double %x)
  ret double %cbrtx
significand:
  %sigexponent = call double @m_unary(i32 40, double %x)
  %sigfinite = fcmp olt double %sigexponent, 0x7FF0000000000000
  %siglow = fcmp ogt double %sigexponent, 0xFFF0000000000000
  %sigvalid = and i1 %sigfinite, %siglow
  %sigsafe = select i1 %sigvalid, double %sigexponent, double 0.000000e+00
  %sigpower = fptosi double %sigsafe to i64
  %signegpower = sub i64 0, %sigpower
  %sigx = call double @m_scale2(double %x, i64 %signegpower)
  ret double %sigx
expm1:
  %expm1x = call double @m_expm1(double %x)
  ret double %expm1x
log1p:
  %log1px = call double @m_log1p(double %x)
  ret double %log1px
logb:
  %raw = bitcast double %x to i64
  %expshift = lshr i64 %raw, 52
  %expbits = and i64 %expshift, 2047
  %exponent = sub i64 %expbits, 1023
  %magnitude = and i64 %raw, 9223372036854775807
  %sub = icmp eq i64 %expbits, 0
  %clz = call i64 @llvm.ctlz.i64(i64 %magnitude, i1 false)
  %subexp = sub i64 -1011, %clz
  %actualexp = select i1 %sub, i64 %subexp, i64 %exponent
  %ordinaryexp = sitofp i64 %actualexp to double
  %zero = icmp eq i64 %magnitude, 0
  %inf = icmp eq i64 %magnitude, 9218868437227405312
  %nan = icmp ugt i64 %magnitude, 9218868437227405312
  %integer = icmp eq i32 %id, 41
  %zeroval = select i1 %integer, double -2.147483648e+09, double 0xFFF0000000000000
  %infval = select i1 %integer, double 2.147483647e+09, double 0x7FF0000000000000
  %nanval = select i1 %integer, double -2.147483648e+09, double %x
  %ez = select i1 %zero, double %zeroval, double %ordinaryexp
  %ei = select i1 %inf, double %infval, double %ez
  %expf = select i1 %nan, double %nanval, double %ei
  ret double %expf
}

define double @m_binary(i32 %id, double %x, double %y) {
entry:
  switch i32 %id, label %nextafter [i32 9, label %pow i32 22, label %atan2 i32 23, label %hypot i32 31, label %fmod i32 32, label %remainder i32 33, label %remainder i32 36, label %scale i32 37, label %scale i32 38, label %scale i32 52, label %max i32 53, label %min i32 54, label %dim i32 55, label %copysign i32 68, label %bessel i32 69, label %bessel i32 71, label %scale]
bessel:
  %secondkind = icmp eq i32 %id, 69
  %be = call double @m_bessel(double %x, double %y, i1 %secondkind)
  ret double %be
pow:
  %p = call double @m_pow(double %x, double %y)
  ret double %p
atan2:
  %atan2r = call double @m_atan2_bits(double %x, double %y)
  ret double %atan2r
hypot:
  %h = call double @m_hypot_bits(double %x, double %y)
  ret double %h
fmod:
  %rem = call double @m_fmod_bits(double %x, double %y)
  ret double %rem
remainder:
  %r = call double @m_remainder_bits(double %x, double %y)
  ret double %r
scale:
  %ynan = fcmp uno double %y, %y
  %sct = call double @m_trunc(double %y)
  %fractional = fcmp one double %sct, %y
  %isscalb = icmp eq i32 %id, 38
  %badscalb = and i1 %isscalb, %fractional
  %xzero = fcmp oeq double %x, 0.000000e+00
  %xinfinite = call double @llvm.fabs.f64(double %x)
  %xinf = fcmp oeq double %xinfinite, 0x7FF0000000000000
  %positiveinf = fcmp oeq double %y, 0x7FF0000000000000
  %negativeinf = fcmp oeq double %y, 0xFFF0000000000000
  %zeroinf = and i1 %xzero, %positiveinf
  %infzero = and i1 %xinf, %negativeinf
  %invalidinf = or i1 %zeroinf, %infzero
  %badscalbinf = and i1 %isscalb, %invalidinf
  %badscale0 = or i1 %ynan, %badscalb
  %badscale = or i1 %badscale0, %badscalbinf
  br i1 %badscale, label %scalenan, label %scalebound
scalenan:
  ret double 0x7FF8000000000000
scalebound:
  %high = fcmp ogt double %y, 4.096000e+03
  %low = fcmp olt double %y, -4.096000e+03
  %boundedhigh = select i1 %high, double 4.096000e+03, double %y
  %bounded = select i1 %low, double -4.096000e+03, double %boundedhigh
  %power = fptosi double %bounded to i64
  %scaled = call double @m_scale2(double %x, i64 %power)
  ret double %scaled
max:
  %greater = fcmp ogt double %x, %y
  %maxynan = fcmp uno double %y, %y
  %maxusex = or i1 %greater, %maxynan
  %maxr = select i1 %maxusex, double %x, double %y
  ret double %maxr
min:
  %less = fcmp olt double %x, %y
  %minynan = fcmp uno double %y, %y
  %minusex = or i1 %less, %minynan
  %minr = select i1 %minusex, double %x, double %y
  ret double %minr
dim:
  %diff = fsub double %x, %y
  %positive = fcmp ogt double %diff, 0.000000e+00
  %dimnan = fcmp uno double %diff, %diff
  %dimuse = or i1 %positive, %dimnan
  %dimr = select i1 %dimuse, double %diff, double 0.000000e+00
  ret double %dimr
copysign:
  %xb = bitcast double %x to i64
  %yb = bitcast double %y to i64
  %mag = and i64 %xb, 9223372036854775807
  %sign = and i64 %yb, -9223372036854775808
  %joined = or i64 %mag, %sign
  %copied = bitcast i64 %joined to double
  ret double %copied
nextafter:
  %nextnan = fcmp uno double %x, %y
  br i1 %nextnan, label %nextinvalid, label %nextcheck
nextinvalid:
  %nextnanvalue = fadd double %x, %y
  ret double %nextnanvalue
nextcheck:
  %equal = fcmp oeq double %x, %y
  br i1 %equal, label %same, label %move
same:
  ret double %y
move:
  %iszero = fcmp oeq double %x, 0.000000e+00
  br i1 %iszero, label %fromzero, label %nonzero
fromzero:
  %yraw = bitcast double %y to i64
  %ysign = and i64 %yraw, -9223372036854775808
  %tiny = or i64 %ysign, 1
  %tz = bitcast i64 %tiny to double
  ret double %tz
nonzero:
  %xraw = bitcast double %x to i64
  %xpos = fcmp ogt double %x, 0.000000e+00
  %ascending = fcmp ogt double %y, %x
  %increment = icmp eq i1 %xpos, %ascending
  %delta = select i1 %increment, i64 1, i64 -1
  %next = add i64 %xraw, %delta
  %nr = bitcast i64 %next to double
  ret double %nr
}

define ptr @j_math_builtin(ptr %name, ptr %args, ptr %input, ptr %env) {
entry:
  %id = call i32 @b_find(ptr %name, ptr @m.names)
  %known = icmp sge i32 %id, 0
  br i1 %known, label %start, label %unknown
unknown:
  ret ptr null
start:
  %out = call ptr @j_array()
  %argc = call i64 @b_len(ptr %args)
  %hasargs = icmp sgt i64 %argc, 0
  br i1 %hasargs, label %argsstart, label %unary
unary:
  %tag = call i32 @b_tag(ptr %input)
  %numeric = icmp eq i32 %tag, 3
  %x = call double @b_number(ptr %input)
  switch i32 %id, label %numbercheck [i32 0, label %abs i32 44, label %infinite i32 45, label %nan i32 46, label %predicate i32 47, label %predicate i32 48, label %predicate i32 49, label %predicate i32 50, label %predicate i32 51, label %predicate]
abs:
  %zerovalue = call ptr @j_num(double 0.000000e+00)
  %comparison = call i32 @j_cmp(ptr %input, ptr %zerovalue)
  %negative = icmp slt i32 %comparison, 0
  br i1 %negative, label %negate, label %identity
negate:
  %negated = call ptr @j_negate(ptr %input)
  call void @b_pushvalid(ptr %out, ptr %negated)
  ret ptr %out
identity:
  call void @j_push(ptr %out, ptr %input)
  ret ptr %out
infinite:
  %iv = call ptr @j_num(double 0x7FF0000000000000)
  call void @j_push(ptr %out, ptr %iv)
  ret ptr %out
nan:
  %nv = call ptr @j_num(double 0x7FF8000000000000)
  call void @j_push(ptr %out, ptr %nv)
  ret ptr %out
predicate:
  %raw = bitcast double %x to i64
  %mag = and i64 %raw, 9223372036854775807
  %isinfinite = icmp eq i64 %mag, 9218868437227405312
  %isnan = icmp ugt i64 %mag, 9218868437227405312
  %isfinite = icmp ult i64 %mag, 9218868437227405312
  %jqfinite = xor i1 %isinfinite, true
  %normalmag = icmp uge i64 %mag, 4503599627370496
  %isnormal = and i1 %isfinite, %normalmag
  switch i32 %id, label %normalpred [i32 46, label %infpred i32 47, label %nanpred i32 48, label %finitepred i32 50, label %finitepred]
infpred:
  br label %predresult
nanpred:
  br label %predresult
finitepred:
  br label %predresult
normalpred:
  br label %predresult
predresult:
  %condition = phi i1 [%isinfinite, %infpred], [%isnan, %nanpred], [%jqfinite, %finitepred], [%isnormal, %normalpred]
  %truth = and i1 %numeric, %condition
  %filter = icmp sge i32 %id, 50
  br i1 %filter, label %filterresult, label %booleanresult
filterresult:
  br i1 %truth, label %identity, label %done
booleanresult:
  %bv = call ptr @j_bool(i1 %truth)
  call void @j_push(ptr %out, ptr %bv)
  ret ptr %out
numbercheck:
  br i1 %numeric, label %numericvalue, label %badnumber
badnumber:
  call void @b_type_error(ptr %input, ptr @m.errnumber)
  ret ptr %out
numericvalue:
  switch i32 %id, label %ordinary [i32 34, label %modf i32 35, label %frexp i32 63, label %lgammapair]
lgammapair:
  %lgsp = alloca i64
  %lgresult = call double @m_lgamma(double %x, ptr %lgsp)
  %lgsign = load i64, ptr %lgsp
  %lgsf = sitofp i64 %lgsign to double
  %lgv = call ptr @j_num(double %lgresult)
  %lgsv = call ptr @j_num(double %lgsf)
  %lgpair = call ptr @j_array()
  call void @j_push(ptr %lgpair, ptr %lgv)
  call void @j_push(ptr %lgpair, ptr %lgsv)
  call void @j_push(ptr %out, ptr %lgpair)
  ret ptr %out
ordinary:
  %v = call double @m_unary(i32 %id, double %x)
  %value = call ptr @j_num(double %v)
  call void @j_push(ptr %out, ptr %value)
  ret ptr %out
modf:
  %intpart = call double @m_trunc(double %x)
  %fraction0 = fsub double %x, %intpart
  %modfmag = call double @llvm.fabs.f64(double %x)
  %modfinf = fcmp oeq double %modfmag, 0x7FF0000000000000
  %modfinteger = fcmp oeq double %fraction0, 0.000000e+00
  %modfzero = or i1 %modfinf, %modfinteger
  %modfbits = bitcast double %x to i64
  %modfsign = and i64 %modfbits, -9223372036854775808
  %modfsignedzero = bitcast i64 %modfsign to double
  %fraction = select i1 %modfzero, double %modfsignedzero, double %fraction0
  %intv = call ptr @j_num(double %intpart)
  %fractionv = call ptr @j_num(double %fraction)
  %modfr = call ptr @j_array()
  call void @j_push(ptr %modfr, ptr %fractionv)
  call void @j_push(ptr %modfr, ptr %intv)
  call void @j_push(ptr %out, ptr %modfr)
  ret ptr %out
frexp:
  %flogb = call double @m_unary(i32 40, double %x)
  %flow = fcmp oge double %flogb, -1.074000e+03
  %fhigh = fcmp ole double %flogb, 1.023000e+03
  %fvalid = and i1 %flow, %fhigh
  %fexponent = fadd double %flogb, 1.000000e+00
  %fsafe = select i1 %fvalid, double %fexponent, double 0.000000e+00
  %fpower = fptosi double %fsafe to i64
  %fnegpower = sub i64 0, %fpower
  %fmantissa = call double @m_scale2(double %x, i64 %fnegpower)
  %fpf = sitofp i64 %fpower to double
  %fmv = call ptr @j_num(double %fmantissa)
  %fpv = call ptr @j_num(double %fpf)
  %frexpr = call ptr @j_array()
  call void @j_push(ptr %frexpr, ptr %fmv)
  call void @j_push(ptr %frexpr, ptr %fpv)
  call void @j_push(ptr %out, ptr %frexpr)
  ret ptr %out
argsstart:
  %xs = call ptr @b_arg(ptr %args, i64 0, ptr %input, ptr %env)
  %ys = call ptr @b_arg(ptr %args, i64 1, ptr %input, ptr %env)
  %isfma = icmp eq i32 %id, 70
  br i1 %isfma, label %thirdargument, label %nothird
thirdargument:
  %thirdvalues = call ptr @b_arg(ptr %args, i64 2, ptr %input, ptr %env)
  br label %argumentsready
nothird:
  %dummyvalues = call ptr @j_array()
  %dummy = call ptr @j_num(double 0.000000e+00)
  call void @j_push(ptr %dummyvalues, ptr %dummy)
  br label %argumentsready
argumentsready:
  %zs = phi ptr [%thirdvalues, %thirdargument], [%dummyvalues, %nothird]
  %xn = call i64 @b_len(ptr %xs)
  %yn = call i64 @b_len(ptr %ys)
  %zn = call i64 @b_len(ptr %zs)
  br label %outer
outer:
  %i = phi i64 [0, %argumentsready], [%next, %advance]
  %more = icmp slt i64 %i, %xn
  br i1 %more, label %body, label %done
body:
  %xv = call ptr @j_at(ptr %xs, i64 %i)
  %xf = call double @b_number(ptr %xv)
  br label %inner
inner:
  %j = phi i64 [0, %body], [%jn, %innernext]
  %jm = icmp slt i64 %j, %yn
  br i1 %jm, label %put, label %advance
put:
  %yv = call ptr @j_at(ptr %ys, i64 %j)
  %yf = call double @b_number(ptr %yv)
  br label %thirdloop
thirdloop:
  %k = phi i64 [0, %put], [%kn, %resultready]
  %km = icmp ult i64 %k, %zn
  br i1 %km, label %typecheck, label %innernext
typecheck:
  %zv = call ptr @j_at(ptr %zs, i64 %k)
  %xtag = call i32 @b_tag(ptr %xv)
  %ytag = call i32 @b_tag(ptr %yv)
  %ztag = call i32 @b_tag(ptr %zv)
  %xnumber = icmp eq i32 %xtag, 3
  %ynumber = icmp eq i32 %ytag, 3
  %znumber = icmp eq i32 %ztag, 3
  %validxy = and i1 %xnumber, %ynumber
  %validxyz = and i1 %validxy, %znumber
  br i1 %validxyz, label %numericcall, label %argumenterror
argumenterror:
  %badsecond = select i1 %ynumber, ptr %zv, ptr %yv
  %badvalue = select i1 %xnumber, ptr %badsecond, ptr %xv
  call void @b_type_error(ptr %badvalue, ptr @m.errnumber)
  br label %done
numericcall:
  br i1 %isfma, label %fusedcall, label %binarycall
fusedcall:
  %zf = call double @b_number(ptr %zv)
  %fused = call double @m_fma(double %xf, double %yf, double %zf)
  br label %resultready
binarycall:
  %result = call double @m_binary(i32 %id, double %xf, double %yf)
  br label %resultready
resultready:
  %answer = phi double [%fused, %fusedcall], [%result, %binarycall]
  %rv = call ptr @j_num(double %answer)
  call void @b_pushvalid(ptr %out, ptr %rv)
  %kn = add i64 %k, 1
  br label %thirdloop
innernext:
  %jn = add i64 %j, 1
  br label %inner
advance:
  %next = add i64 %i, 1
  br label %outer
done:
  ret ptr %out
}

define ptr @j_math_names() {
entry:
  ret ptr @m.names
}

define i1 @j_math_known(ptr %name, i64 %arity) {
entry:
  %id = call i32 @b_find(ptr %name, ptr @m.names)
  %known = icmp sge i32 %id, 0
  br i1 %known, label %check, label %no
check:
  switch i32 %id, label %zero [i32 9, label %two i32 22, label %two i32 23, label %two i32 31, label %two i32 32, label %two i32 33, label %two i32 36, label %two i32 37, label %two i32 38, label %two i32 52, label %two i32 53, label %two i32 54, label %two i32 55, label %two i32 56, label %two i32 57, label %two i32 68, label %two i32 69, label %two i32 70, label %three i32 71, label %two]
three:
  %threecheck = icmp eq i64 %arity, 3
  ret i1 %threecheck
zero:
  %z = icmp eq i64 %arity, 0
  ret i1 %z
two:
  %t = icmp eq i64 %arity, 2
  ret i1 %t
no:
  ret i1 false
}
