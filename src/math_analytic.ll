declare double @llvm.fabs.f64(double)
declare double @llvm.sqrt.f64(double)
declare i64 @llvm.ctlz.i64(i64, i1)
declare double @m_exp(double)
declare double @m_expm1(double)
declare double @m_log(double)
declare double @m_log1p(double)
declare double @m_scale_bits(double, i64)
declare i64 @m_parts(double, ptr)
declare double @m_fma(double, double, double)

define double @m_hyperbolic(i32 %id, double %x) {
entry:
  %a = call double @llvm.fabs.f64(double %x)
  %raw = bitcast double %x to i64
  %negative = icmp slt i64 %raw, 0
  %nan = fcmp uno double %x, %x
  br i1 %nan, label %same, label %dispatch
same:
  ret double %x
dispatch:
  switch i32 %id, label %atanh [i32 24, label %direct i32 25, label %direct i32 27, label %asinh i32 28, label %acosh]
direct:
  %cosh = icmp eq i32 %id, 25
  %tiny = fcmp olt double %a, 3.7252902984619141e-09
  br i1 %tiny, label %directtiny, label %directcheck
directtiny:
  %unit = select i1 %cosh, double 1.000000e+00, double %x
  ret double %unit
directcheck:
  %ordinary = fcmp ole double %a, 2.000000e+01
  br i1 %ordinary, label %directsmall, label %directlarge
directsmall:
  %w = call double @m_expm1(double %a)
  %ep = fadd double %w, 1.000000e+00
  %reciprocalpart = fdiv double %w, %ep
  %sinhdouble = fadd double %w, %reciprocalpart
  %sinh = fmul double %sinhdouble, 5.000000e-01
  %coshpart = fmul double %w, %reciprocalpart
  %coshhalf = fmul double %coshpart, 5.000000e-01
  %coshvalue = fadd double 1.000000e+00, %coshhalf
  %smallresult = select i1 %cosh, double %coshvalue, double %sinh
  br label %directsign
directlarge:
  %halfa = fmul double %a, 5.000000e-01
  %he = call double @m_exp(double %halfa)
  %halfhe = fmul double %he, 5.000000e-01
  %largeresult = fmul double %halfhe, %he
  br label %directsign
directsign:
  %magnitude = phi double [%smallresult, %directsmall], [%largeresult, %directlarge]
  %sinhnegative = xor i1 %cosh, true
  %applynegative = and i1 %sinhnegative, %negative
  %negmagnitude = fneg double %magnitude
  %directresult = select i1 %applynegative, double %negmagnitude, double %magnitude
  ret double %directresult
asinh:
  %asinhtiny = fcmp olt double %a, 3.7252902984619141e-09
  br i1 %asinhtiny, label %same, label %asinhcheck
asinhcheck:
  %asinhlarge = fcmp ogt double %a, 2.684354560e+08
  br i1 %asinhlarge, label %asinhlog, label %asinhsmall
asinhlog:
  %al = call double @m_log(double %a)
  %alplus = fadd double %al, 6.9314718055994529e-01
  br label %asinhsign
asinhsmall:
  %aa = fmul double %a, %a
  %aas = fadd double 1.000000e+00, %aa
  %root = call double @llvm.sqrt.f64(double %aas)
  %den = fadd double %root, 1.000000e+00
  %fraction = fdiv double %aa, %den
  %arg = fadd double %a, %fraction
  %smalllog = call double @m_log1p(double %arg)
  br label %asinhsign
asinhsign:
  %asinhmag = phi double [%alplus, %asinhlog], [%smalllog, %asinhsmall]
  %asinhneg = fneg double %asinhmag
  %asinhresult = select i1 %negative, double %asinhneg, double %asinhmag
  ret double %asinhresult
acosh:
  %belowone = fcmp olt double %x, 1.000000e+00
  br i1 %belowone, label %invalid, label %acoshcheck
acoshcheck:
  %acoshlarge = fcmp ogt double %x, 2.684354560e+08
  br i1 %acoshlarge, label %acoshlog, label %acoshsmall
acoshlog:
  %xl = call double @m_log(double %x)
  %xlplus = fadd double %xl, 6.9314718055994529e-01
  ret double %xlplus
acoshsmall:
  %xm = fsub double %x, 1.000000e+00
  %xp = fadd double %x, 1.000000e+00
  %product = fmul double %xm, %xp
  %acoshroot = call double @llvm.sqrt.f64(double %product)
  %acosharg = fadd double %xm, %acoshroot
  %acoshresult = call double @m_log1p(double %acosharg)
  ret double %acoshresult
atanh:
  %atanhtiny = fcmp olt double %a, 3.7252902984619141e-09
  br i1 %atanhtiny, label %same, label %atanhcheck
atanhcheck:
  %outside = fcmp ogt double %a, 1.000000e+00
  br i1 %outside, label %invalid, label %atanhvalue
atanhvalue:
  %twice = fmul double %a, 2.000000e+00
  %distance = fsub double 1.000000e+00, %a
  %ratio = fdiv double %twice, %distance
  %ratio_log = call double @m_log1p(double %ratio)
  %atanhmag = fmul double %ratio_log, 5.000000e-01
  %atanhneg = fneg double %atanhmag
  %atanhresult = select i1 %negative, double %atanhneg, double %atanhmag
  ret double %atanhresult
invalid:
  ret double 0x7FF8000000000000
}

define double @m_cbrt(double %x) {
entry:
  %a = call double @llvm.fabs.f64(double %x)
  %zero = fcmp oeq double %a, 0.000000e+00
  %special = fcmp uge double %a, 0x7FF0000000000000
  %samevalue = or i1 %zero, %special
  br i1 %samevalue, label %same, label %start
same:
  ret double %x
start:
  %ep = alloca i64
  %mantissa = call i64 @m_parts(double %a, ptr %ep)
  %exponent = load i64, ptr %ep
  %leading = call i64 @llvm.ctlz.i64(i64 %mantissa, i1 false)
  %top = sub i64 63, %leading
  %binaryexponent = add i64 %exponent, %top
  %quotient = sdiv i64 %binaryexponent, 3
  %remainder = srem i64 %binaryexponent, 3
  %negative_remainder = icmp slt i64 %remainder, 0
  %adjustment = zext i1 %negative_remainder to i64
  %third = sub i64 %quotient, %adjustment
  %shift = mul i64 %third, -3
  %normalized = call double @m_scale_bits(double %a, i64 %shift)
  %l = call double @m_log(double %normalized)
  %lt = fdiv double %l, 3.000000e+00
  %seed = call double @m_exp(double %lt)
  br label %loop
loop:
  %i = phi i64 [0, %start], [%next, %body]
  %value = phi double [%seed, %start], [%corrected, %body]
  %more = icmp ult i64 %i, 3
  br i1 %more, label %body, label %done
body:
  %square = fmul double %value, %value
  %negsquare = fneg double %square
  %square_error = call double @m_fma(double %value, double %value, double %negsquare)
  %negvalue = fneg double %value
  %residual0 = call double @m_fma(double %negvalue, double %square, double %normalized)
  %residual = call double @m_fma(double %negvalue, double %square_error, double %residual0)
  %derivative = fmul double %square, 3.000000e+00
  %correction = fdiv double %residual, %derivative
  %corrected = fadd double %value, %correction
  %next = add i64 %i, 1
  br label %loop
done:
  %scaled = call double @m_scale_bits(double %value, i64 %third)
  %bits = bitcast double %x to i64
  %negative = icmp slt i64 %bits, 0
  %negated = fneg double %scaled
  %result = select i1 %negative, double %negated, double %scaled
  ret double %result
}
