declare double @llvm.fabs.f64(double)
declare double @llvm.sqrt.f64(double)
declare double @m_exp(double)
declare double @m_log(double)
declare double @m_sin(double)
declare double @m_cos(double)
declare double @m_trunc(double)
declare double @m_scale2(double, i64)
declare double @m_pow_finite(double, double)

define double @m_expm1(double %x) {
entry:
  %a = call double @llvm.fabs.f64(double %x)
  %tiny = fcmp olt double %a, 5.5511151231257827e-17
  br i1 %tiny, label %same, label %check
same:
  ret double %x
check:
  %small = fcmp olt double %a, 5.000000e-01
  br i1 %small, label %start, label %ordinary
ordinary:
  %e = call double @m_exp(double %x)
  %r = fsub double %e, 1.000000e+00
  ret double %r
start:
  br label %loop
loop:
  %i = phi i64 [2, %start], [%next, %body]
  %term = phi double [%x, %start], [%tn, %body]
  %sum = phi double [%x, %start], [%sn, %body]
  %correction = phi double [0.000000e+00, %start], [%cn, %body]
  %more = icmp ule i64 %i, 24
  br i1 %more, label %body, label %done
body:
  %if = uitofp i64 %i to double
  %p = fmul double %term, %x
  %tn = fdiv double %p, %if
  %adjusted = fsub double %tn, %correction
  %sn = fadd double %sum, %adjusted
  %diff = fsub double %sn, %sum
  %cn = fsub double %diff, %adjusted
  %next = add i64 %i, 1
  br label %loop
done:
  ret double %sum
}

define double @m_log1p(double %x) {
entry:
  %a = call double @llvm.fabs.f64(double %x)
  %tiny = fcmp olt double %a, 5.5511151231257827e-17
  br i1 %tiny, label %same, label %check
same:
  ret double %x
check:
  %small = fcmp olt double %a, 5.000000e-01
  br i1 %small, label %start, label %ordinary
ordinary:
  %arg = fadd double 1.000000e+00, %x
  %r = call double @m_log(double %arg)
  ret double %r
start:
  %den = fadd double 2.000000e+00, %x
  %y = fdiv double %x, %den
  %y2 = fmul double %y, %y
  br label %loop
loop:
  %i = phi i64 [3, %start], [%next, %body]
  %term = phi double [%y, %start], [%tn, %body]
  %sum = phi double [%y, %start], [%sn, %body]
  %correction = phi double [0.000000e+00, %start], [%cn, %body]
  %more = icmp ule i64 %i, 55
  br i1 %more, label %body, label %done
body:
  %if = uitofp i64 %i to double
  %tn = fmul double %term, %y2
  %part = fdiv double %tn, %if
  %adjusted = fsub double %part, %correction
  %sn = fadd double %sum, %adjusted
  %diff = fsub double %sn, %sum
  %cn = fsub double %diff, %adjusted
  %next = add i64 %i, 2
  br label %loop
done:
  %result = fmul double %sum, 2.000000e+00
  ret double %result
}

define double @m_pow(double %x, double %y) {
entry:
  %yzero = fcmp oeq double %y, 0.000000e+00
  %xone = fcmp oeq double %x, 1.000000e+00
  %one = or i1 %yzero, %xone
  br i1 %one, label %unity, label %checknan
unity:
  ret double 1.000000e+00
checknan:
  %xn = fcmp uno double %x, %x
  %yn = fcmp uno double %y, %y
  %nan = or i1 %xn, %yn
  br i1 %nan, label %invalid, label %infinity
invalid:
  ret double 0x7FF8000000000000
infinity:
  %ax = call double @llvm.fabs.f64(double %x)
  %ay = call double @llvm.fabs.f64(double %y)
  %yi = fcmp oeq double %ay, 0x7FF0000000000000
  br i1 %yi, label %infinitepower, label %basecheck
infinitepower:
  %unitbase = fcmp oeq double %ax, 1.000000e+00
  br i1 %unitbase, label %unity, label %powermagnitude
powermagnitude:
  %largex = fcmp ogt double %ax, 1.000000e+00
  %positivey = fcmp ogt double %y, 0.000000e+00
  %grow = icmp eq i1 %largex, %positivey
  %endvalue = select i1 %grow, double 0x7FF0000000000000, double 0.000000e+00
  ret double %endvalue
basecheck:
  %yt = call double @m_trunc(double %y)
  %integer = fcmp oeq double %yt, %y
  %smallint = fcmp olt double %ay, 9.007199254740992e+15
  %half = fmul double %y, 5.000000e-01
  %halft = call double @m_trunc(double %half)
  %halffraction = fcmp one double %half, %halft
  %odd0 = and i1 %integer, %smallint
  %odd = and i1 %odd0, %halffraction
  %xb = bitcast double %x to i64
  %negativex = icmp slt i64 %xb, 0
  %negativeanswer = and i1 %negativex, %odd
  %xi = fcmp oeq double %ax, 0x7FF0000000000000
  br i1 %xi, label %infinitebase, label %finite
infinitebase:
  %positivepower = fcmp ogt double %y, 0.000000e+00
  %magnitude = select i1 %positivepower, double 0x7FF0000000000000, double 0.000000e+00
  %negative = fneg double %magnitude
  %signed = select i1 %negativeanswer, double %negative, double %magnitude
  ret double %signed
finite:
  %forceabsolute = and i1 %integer, %negativex
  %base = select i1 %forceabsolute, double %ax, double %x
  %positive = call double @m_pow_finite(double %base, double %y)
  %negated = fneg double %positive
  %result = select i1 %negativeanswer, double %negated, double %positive
  ret double %result
}

define double @m_erf(double %x, i1 %complement) {
entry:
  %a = call double @llvm.fabs.f64(double %x)
  %nan = fcmp uno double %x, %x
  br i1 %nan, label %unchanged, label %check
unchanged:
  ret double %x
check:
  %large = fcmp ogt double %a, 2.700000e+01
  br i1 %large, label %saturated, label %selectmethod
saturated:
  br label %finish
selectmethod:
  %z = fmul double %a, %a
  %small = fcmp olt double %a, 1.500000e+00
  br i1 %small, label %series, label %fraction
series:
  br label %seriesloop
seriesloop:
  %i = phi i64 [1, %series], [%next, %seriesbody]
  %term = phi double [1.000000e+00, %series], [%tn, %seriesbody]
  %sum = phi double [1.000000e+00, %series], [%sn, %seriesbody]
  %more = icmp ule i64 %i, 64
  br i1 %more, label %seriesbody, label %seriesdone
seriesbody:
  %if = uitofp i64 %i to double
  %den = fadd double %if, 5.000000e-01
  %num = fmul double %term, %z
  %tn = fdiv double %num, %den
  %sn = fadd double %sum, %tn
  %next = add i64 %i, 1
  br label %seriesloop
seriesdone:
  %minusz = fneg double %z
  %exponential = call double @m_exp(double %minusz)
  %scale = fmul double %a, 1.1283791670955126e+00
  %e0 = fmul double %scale, %exponential
  %erfvalue = fmul double %e0, %sum
  %seriesq = fsub double 1.000000e+00, %erfvalue
  br label %finish
fraction:
  br label %fractionloop
fractionloop:
  %k = phi i64 [160, %fraction], [%previous, %fractionbody]
  %tail = phi double [0.000000e+00, %fraction], [%newtail, %fractionbody]
  %keep = icmp ugt i64 %k, 0
  br i1 %keep, label %fractionbody, label %fractiondone
fractionbody:
  %kf = uitofp i64 %k to double
  %numerator = fmul double %kf, 5.000000e-01
  %denominator = fadd double %a, %tail
  %newtail = fdiv double %numerator, %denominator
  %previous = sub i64 %k, 1
  br label %fractionloop
fractiondone:
  %negz = fneg double %z
  %ex = call double @m_exp(double %negz)
  %den0 = fadd double %a, %tail
  %den1 = fmul double %den0, 1.7724538509055160e+00
  %fractionq = fdiv double %ex, %den1
  br label %finish
finish:
  %q = phi double [0.000000e+00, %saturated], [%seriesq, %seriesdone], [%fractionq, %fractiondone]
  %direct = phi double [1.000000e+00, %saturated], [%erfvalue, %seriesdone], [0.000000e+00, %fractiondone]
  %usecomplement = phi i1 [false, %saturated], [false, %seriesdone], [true, %fractiondone]
  %negative = fcmp olt double %x, 0.000000e+00
  %qnegative = fsub double 2.000000e+00, %q
  %signedq = select i1 %negative, double %qnegative, double %q
  %efromq = fsub double 1.000000e+00, %q
  %e = select i1 %usecomplement, double %efromq, double %direct
  %enegative = fneg double %e
  %signede = select i1 %negative, double %enegative, double %e
  %zero = fcmp oeq double %x, 0.000000e+00
  %preserved = select i1 %zero, double %x, double %signede
  %result = select i1 %complement, double %signedq, double %preserved
  ret double %result
}

define double @m_lgamma(double %x, ptr %signp) {
entry:
  store i64 1, ptr %signp
  %one = fcmp oeq double %x, 1.000000e+00
  %two = fcmp oeq double %x, 2.000000e+00
  %unity = or i1 %one, %two
  br i1 %unity, label %exactzero, label %nancheck
exactzero:
  ret double 0.000000e+00
nancheck:
  %nan = fcmp uno double %x, %x
  br i1 %nan, label %same, label %check
same:
  ret double %x
check:
  %a = call double @llvm.fabs.f64(double %x)
  %infinite = fcmp oeq double %a, 0x7FF0000000000000
  %zero = fcmp oeq double %a, 0.000000e+00
  %singular = or i1 %infinite, %zero
  br i1 %singular, label %infinity, label %negativecheck
infinity:
  %bits = bitcast double %x to i64
  %negativezero = icmp slt i64 %bits, 0
  %sgn = select i1 %negativezero, i64 -1, i64 1
  store i64 %sgn, ptr %signp
  ret double 0x7FF0000000000000
negativecheck:
  %negative = fcmp olt double %x, 0.000000e+00
  br i1 %negative, label %reflection, label %positive
reflection:
  %integer = call double @m_trunc(double %x)
  %pole = fcmp oeq double %integer, %x
  br i1 %pole, label %infinity, label %reflect
reflect:
  %fraction = fsub double %x, %integer
  %phase = fmul double %fraction, 3.1415926535897931e+00
  %sin0 = call double @m_sin(double %phase)
  %half = fmul double %integer, 5.000000e-01
  %halft = call double @m_trunc(double %half)
  %odd = fcmp one double %half, %halft
  %sinneg = fneg double %sin0
  %sine = select i1 %odd, double %sinneg, double %sin0
  %sinenegative = fcmp olt double %sine, 0.000000e+00
  %sign = select i1 %sinenegative, i64 -1, i64 1
  %other = fsub double 1.000000e+00, %x
  %ignored = alloca i64
  %loggamma = call double @m_lgamma(double %other, ptr %ignored)
  %abssin = call double @llvm.fabs.f64(double %sine)
  %logsin = call double @m_log(double %abssin)
  %lp = fsub double 1.1447298858494002e+00, %logsin
  %reflected = fsub double %lp, %loggamma
  store i64 %sign, ptr %signp
  ret double %reflected
positive:
  br label %recurrence
recurrence:
  %y = phi double [%x, %positive], [%nexty, %recur]
  %correction = phi double [0.000000e+00, %positive], [%newcorrection, %recur]
  %small = fcmp olt double %y, 1.600000e+01
  br i1 %small, label %recur, label %stirling
recur:
  %logy = call double @m_log(double %y)
  %newcorrection = fsub double %correction, %logy
  %nexty = fadd double %y, 1.000000e+00
  br label %recurrence
stirling:
  %log = call double @m_log(double %y)
  %ymhalf = fsub double %y, 5.000000e-01
  %main = fmul double %ymhalf, %log
  %minus = fsub double %main, %y
  %constant = fadd double %minus, 9.1893853320467278e-01
  %inv = fdiv double 1.000000e+00, %y
  %inv2 = fmul double %inv, %inv
  %p6 = fmul double %inv2, -1.9175269175269176e-03
  %p5a = fadd double %p6, 8.4175084175084171e-04
  %p5 = fmul double %p5a, %inv2
  %p4a = fadd double %p5, -5.9523809523809529e-04
  %p4 = fmul double %p4a, %inv2
  %p3a = fadd double %p4, 7.9365079365079365e-04
  %p3 = fmul double %p3a, %inv2
  %p2a = fadd double %p3, -2.7777777777777779e-03
  %p2 = fmul double %p2a, %inv2
  %p1a = fadd double %p2, 8.3333333333333329e-02
  %tail = fmul double %p1a, %inv
  %approximation = fadd double %constant, %tail
  %result = fadd double %approximation, %correction
  ret double %result
}

define double @m_gamma(double %x) {
entry:
  %integer = call double @m_trunc(double %x)
  %exactinteger = fcmp oeq double %integer, %x
  %positive = fcmp ogt double %x, 0.000000e+00
  %small = fcmp ole double %x, 1.710000e+02
  %valid0 = and i1 %exactinteger, %positive
  %factorial = and i1 %valid0, %small
  br i1 %factorial, label %factorialstart, label %ordinary
factorialstart:
  %n = fptoui double %x to i64
  br label %factorialloop
factorialloop:
  %i = phi i64 [1, %factorialstart], [%next, %multiply]
  %acc = phi double [1.000000e+00, %factorialstart], [%product, %multiply]
  %more = icmp ult i64 %i, %n
  br i1 %more, label %multiply, label %factorialdone
multiply:
  %factor = uitofp i64 %i to double
  %product = fmul double %acc, %factor
  %next = add i64 %i, 1
  br label %factorialloop
factorialdone:
  ret double %acc
ordinary:
  %negative = fcmp olt double %x, 0.000000e+00
  %pole = and i1 %negative, %exactinteger
  %neginf = fcmp oeq double %x, 0xFFF0000000000000
  %invalid = or i1 %pole, %neginf
  br i1 %invalid, label %nan, label %logarithm
nan:
  ret double 0x7FF8000000000000
logarithm:
  %signp = alloca i64
  %log = call double @m_lgamma(double %x, ptr %signp)
  %mag = call double @m_exp(double %log)
  %sign = load i64, ptr %signp
  %neg = icmp slt i64 %sign, 0
  %negated = fneg double %mag
  %result = select i1 %neg, double %negated, double %mag
  ret double %result
}

define internal double @m_bessel_base(double %x, i1 %orderone, i1 %secondkind) {
entry:
  %a = call double @llvm.fabs.f64(double %x)
  %nan = fcmp uno double %x, %x
  %negative = fcmp olt double %x, 0.000000e+00
  %domain = and i1 %negative, %secondkind
  %bad = or i1 %nan, %domain
  br i1 %bad, label %invalid, label %zeros
invalid:
  ret double 0x7FF8000000000000
zeros:
  %zero = fcmp oeq double %a, 0.000000e+00
  br i1 %zero, label %atzero, label %infinitecheck
atzero:
  %jzero = select i1 %orderone, double %x, double 1.000000e+00
  %zerovalue = select i1 %secondkind, double 0xFFF0000000000000, double %jzero
  ret double %zerovalue
infinitecheck:
  %infinite = fcmp oeq double %a, 0x7FF0000000000000
  br i1 %infinite, label %atinfinity, label %selectmethod
atinfinity:
  ret double 0.000000e+00
selectmethod:
  %large = fcmp ogt double %a, 1.600000e+01
  br i1 %large, label %asymptotic, label %series
series:
  %half = fmul double %a, 5.000000e-01
  %square = fmul double %half, %half
  %negativesquare = fneg double %square
  %initial = select i1 %orderone, double %half, double 1.000000e+00
  %order = uitofp i1 %orderone to double
  %initialharmonic = select i1 %orderone, double %half, double 0.000000e+00
  br label %seriesloop
seriesloop:
  %i = phi i64 [1, %series], [%next, %seriesbody]
  %term = phi double [%initial, %series], [%newterm, %seriesbody]
  %sum = phi double [%initial, %series], [%newsum, %seriesbody]
  %harmonic = phi double [0.000000e+00, %series], [%newharmonic, %seriesbody]
  %hsum = phi double [%initialharmonic, %series], [%newhsum, %seriesbody]
  %more = icmp ule i64 %i, 100
  br i1 %more, label %seriesbody, label %seriesdone
seriesbody:
  %if = uitofp i64 %i to double
  %io = fadd double %if, %order
  %den = fmul double %if, %io
  %num = fmul double %term, %negativesquare
  %newterm = fdiv double %num, %den
  %newsum = fadd double %sum, %newterm
  %inv = fdiv double 1.000000e+00, %if
  %newharmonic = fadd double %harmonic, %inv
  %inext = fadd double %if, 1.000000e+00
  %invnext = fdiv double 1.000000e+00, %inext
  %hdouble = fmul double %newharmonic, 2.000000e+00
  %hpair = fadd double %hdouble, %invnext
  %hfactor = select i1 %orderone, double %hpair, double %newharmonic
  %hterm = fmul double %hfactor, %newterm
  %newhsum = fadd double %hsum, %hterm
  %next = add i64 %i, 1
  br label %seriesloop
seriesdone:
  br i1 %secondkind, label %yseries, label %jsign
yseries:
  %log = call double @m_log(double %half)
  %loggamma = fadd double %log, 5.7721566490153287e-01
  %jlog = fmul double %sum, %loggamma
  %twopi = fmul double %jlog, 6.3661977236758138e-01
  %hscale = select i1 %orderone, double 3.1830988618379069e-01, double 6.3661977236758138e-01
  %hc = fmul double %hsum, %hscale
  %ybase = fsub double %twopi, %hc
  %singular = fdiv double 6.3661977236758138e-01, %a
  %yone = fsub double %ybase, %singular
  %yvalue = select i1 %orderone, double %yone, double %ybase
  ret double %yvalue
jsign:
  %negate = and i1 %orderone, %negative
  %negated = fneg double %sum
  %jvalue = select i1 %negate, double %negated, double %sum
  ret double %jvalue
asymptotic:
  %mu = select i1 %orderone, double 4.000000e+00, double 0.000000e+00
  br label %asymloop
asymloop:
  %k = phi i64 [1, %asymptotic], [%knext, %asymadvance]
  %aterm = phi double [1.000000e+00, %asymptotic], [%anext, %asymadvance]
  %even = phi double [1.000000e+00, %asymptotic], [%enext, %asymadvance]
  %odd = phi double [0.000000e+00, %asymptotic], [%onext, %asymadvance]
  %kmore = icmp ule i64 %k, 40
  br i1 %kmore, label %asymbody, label %asymdone
asymbody:
  %kf = uitofp i64 %k to double
  %twok = fmul double %kf, 2.000000e+00
  %oddk = fsub double %twok, 1.000000e+00
  %ksquare = fmul double %oddk, %oddk
  %factor = fsub double %mu, %ksquare
  %numerator = fmul double %aterm, %factor
  %kx = fmul double %kf, %a
  %denominator = fmul double %kx, 8.000000e+00
  %anext = fdiv double %numerator, %denominator
  %oldabs = call double @llvm.fabs.f64(double %aterm)
  %newabs = call double @llvm.fabs.f64(double %anext)
  %divergent = fcmp ogt double %newabs, %oldabs
  br i1 %divergent, label %asymdone, label %asymadvance
asymadvance:
  %signbit = and i64 %k, 2
  %minus = icmp ne i64 %signbit, 0
  %minusvalue = fneg double %anext
  %signedterm = select i1 %minus, double %minusvalue, double %anext
  %parity = and i64 %k, 1
  %isodd = icmp ne i64 %parity, 0
  %eadd = fadd double %even, %signedterm
  %oadd = fadd double %odd, %signedterm
  %enext = select i1 %isodd, double %even, double %eadd
  %onext = select i1 %isodd, double %oadd, double %odd
  %knext = add i64 %k, 1
  br label %asymloop
asymdone:
  %sine = call double @m_sin(double %a)
  %cosine = call double @m_cos(double %a)
  %sumsc = fadd double %sine, %cosine
  %diffsc = fsub double %sine, %cosine
  %cphase0 = fmul double %sumsc, 7.0710678118654757e-01
  %sphase0 = fmul double %diffsc, 7.0710678118654757e-01
  %negativecphase = fneg double %cphase0
  %cp = select i1 %orderone, double %sphase0, double %cphase0
  %sp = select i1 %orderone, double %negativecphase, double %sphase0
  %ep = fmul double %even, %cp
  %oq = fmul double %odd, %sp
  %janswer = fsub double %ep, %oq
  %eq = fmul double %even, %sp
  %op = fmul double %odd, %cp
  %yanswer = fadd double %eq, %op
  %answer = select i1 %secondkind, double %yanswer, double %janswer
  %scale2 = fdiv double 6.3661977236758138e-01, %a
  %scale = call double @llvm.sqrt.f64(double %scale2)
  %resultpositive = fmul double %answer, %scale
  %negativefirst = and i1 %negative, %orderone
  %firstkind = xor i1 %secondkind, true
  %signchange = and i1 %negativefirst, %firstkind
  %resultnegative = fneg double %resultpositive
  %result = select i1 %signchange, double %resultnegative, double %resultpositive
  ret double %result
}

define double @m_bessel(double %order, double %x, i1 %secondkind) {
entry:
  %withinlow = fcmp oge double %order, -2.147483648e+09
  %withinhigh = fcmp ole double %order, 2.147483647e+09
  %valid = and i1 %withinlow, %withinhigh
  br i1 %valid, label %start, label %invalid
invalid:
  ret double 0x7FF8000000000000
start:
  %n0 = fptosi double %order to i64
  %negativeorder = icmp slt i64 %n0, 0
  %nn = sub i64 0, %n0
  %n = select i1 %negativeorder, i64 %nn, i64 %n0
  %zero = icmp eq i64 %n, 0
  %one = icmp eq i64 %n, 1
  %base = or i1 %zero, %one
  br i1 %base, label %basevalue, label %recurrence
basevalue:
  %bv = call double @m_bessel_base(double %x, i1 %one, i1 %secondkind)
  br label %sign
recurrence:
  %b0 = call double @m_bessel_base(double %x, i1 false, i1 %secondkind)
  %b1 = call double @m_bessel_base(double %x, i1 true, i1 %secondkind)
  %absx = call double @llvm.fabs.f64(double %x)
  %xzero = fcmp oeq double %absx, 0.000000e+00
  %xinf = fcmp oeq double %absx, 0x7FF0000000000000
  %badbase = fcmp uno double %b0, %b0
  %special0 = or i1 %xzero, %xinf
  %special = or i1 %special0, %badbase
  br i1 %special, label %specialvalue, label %direction
specialvalue:
  %specialzero = select i1 %secondkind, double %b0, double 0.000000e+00
  %specialresult = select i1 %badbase, double %b0, double %specialzero
  br label %sign
direction:
  %nf = uitofp i64 %n to double
  %unstable = fcmp ogt double %nf, %absx
  %firstkind = xor i1 %secondkind, true
  %backward = and i1 %firstkind, %unstable
  br i1 %backward, label %millerstart, label %forwardstart
forwardstart:
  br label %loop
loop:
  %i = phi i64 [1, %forwardstart], [%next, %body]
  %previous = phi double [%b0, %forwardstart], [%current, %body]
  %current = phi double [%b1, %forwardstart], [%value, %body]
  %more = icmp ult i64 %i, %n
  br i1 %more, label %body, label %recurdone
body:
  %if = uitofp i64 %i to double
  %twice = fmul double %if, 2.000000e+00
  %factor = fdiv double %twice, %x
  %scaled = fmul double %factor, %current
  %value = fsub double %scaled, %previous
  %next = add i64 %i, 1
  br label %loop
recurdone:
  br label %sign
millerstart:
  %rootarg = fmul double %nf, 4.000000e+01
  %root = call double @llvm.sqrt.f64(double %rootarg)
  %extra = fptoui double %root to i64
  %m0 = add i64 %n, %extra
  %m = add i64 %m0, 32
  br label %millerloop
millerloop:
  %mi = phi i64 [%m, %millerstart], [%mprev, %millerbody]
  %mj = phi double [1.000000e+00, %millerstart], [%mjnext, %millerbody]
  %mjp = phi double [0.000000e+00, %millerstart], [%mjprior, %millerbody]
  %target = phi double [0.000000e+00, %millerstart], [%newtarget, %millerbody]
  %mmore = icmp ugt i64 %mi, 0
  br i1 %mmore, label %millerbody, label %millerdone
millerbody:
  %mif = uitofp i64 %mi to double
  %twomi = fmul double %mif, 2.000000e+00
  %mfactor = fdiv double %twomi, %x
  %mproduct = fmul double %mfactor, %mj
  %nextj = fsub double %mproduct, %mjp
  %mprev = sub i64 %mi, 1
  %istarget = icmp eq i64 %mprev, %n
  %target0 = select i1 %istarget, double %nextj, double %target
  %nextabs = call double @llvm.fabs.f64(double %nextj)
  %rescale = fcmp ogt double %nextabs, 1.0e100
  %scaling = select i1 %rescale, double 1.0e-100, double 1.000000e+00
  %mjnext = fmul double %nextj, %scaling
  %mjprior = fmul double %mj, %scaling
  %newtarget = fmul double %target0, %scaling
  br label %millerloop
millerdone:
  %ab0 = call double @llvm.fabs.f64(double %b0)
  %ab1 = call double @llvm.fabs.f64(double %b1)
  %usezero = fcmp oge double %ab0, %ab1
  %basis = select i1 %usezero, double %b0, double %b1
  %normalization = select i1 %usezero, double %mj, double %mjp
  %ratio = fdiv double %target, %normalization
  %millerresult = fmul double %ratio, %basis
  br label %sign
sign:
  %positive = phi double [%bv, %basevalue], [%current, %recurdone], [%specialresult, %specialvalue], [%millerresult, %millerdone]
  %parity = and i64 %n, 1
  %odd = icmp ne i64 %parity, 0
  %change = and i1 %negativeorder, %odd
  %negative = fneg double %positive
  %result = select i1 %change, double %negative, double %positive
  ret double %result
}
