declare i128 @llvm.ctlz.i128(i128, i1)
declare i64 @llvm.ctlz.i64(i64, i1)
declare double @llvm.fabs.f64(double)
declare double @llvm.sqrt.f64(double)
declare double @m_atan(double)

define i64 @m_parts(double %x, ptr %exponent) {
entry:
  %bits = bitcast double %x to i64
  %shifted = lshr i64 %bits, 52
  %encoded = and i64 %shifted, 2047
  %fraction = and i64 %bits, 4503599627370495
  %normal = icmp ne i64 %encoded, 0
  %withbit = or i64 %fraction, 4503599627370496
  %mantissa = select i1 %normal, i64 %withbit, i64 %fraction
  %power = sub i64 %encoded, 1075
  %actual = select i1 %normal, i64 %power, i64 -1074
  store i64 %actual, ptr %exponent
  ret i64 %mantissa
}

define double @m_pack(i128 %magnitude, i64 %exponent, i64 %sign) {
entry:
  %zero = icmp eq i128 %magnitude, 0
  br i1 %zero, label %zerovalue, label %start
zerovalue:
  %z = bitcast i64 %sign to double
  ret double %z
start:
  %leading = call i128 @llvm.ctlz.i128(i128 %magnitude, i1 false)
  %leading64 = trunc i128 %leading to i64
  %top = sub i64 127, %leading64
  %highest = add i64 %top, %exponent
  %wanted = sub i64 %highest, 52
  %subnormal = icmp slt i64 %wanted, -1074
  %target = select i1 %subnormal, i64 -1074, i64 %wanted
  %shift = sub i64 %target, %exponent
  %right = icmp sgt i64 %shift, 0
  br i1 %right, label %rightcheck, label %left
left:
  %ls = sub i64 0, %shift
  %lswide = zext i64 %ls to i128
  %leftvalue = shl i128 %magnitude, %lswide
  br label %rounded
rightcheck:
  %toofar = icmp sge i64 %shift, 128
  br i1 %toofar, label %zerovalue, label %rightshift
rightshift:
  %rs = zext i64 %shift to i128
  %q = lshr i128 %magnitude, %rs
  %one = shl i128 1, %rs
  %mask = sub i128 %one, 1
  %remainder = and i128 %magnitude, %mask
  %half = lshr i128 %one, 1
  %greater = icmp ugt i128 %remainder, %half
  %equal = icmp eq i128 %remainder, %half
  %oddpart = and i128 %q, 1
  %odd = icmp ne i128 %oddpart, 0
  %tie = and i1 %equal, %odd
  %roundup = or i1 %greater, %tie
  %increment = zext i1 %roundup to i128
  %rightvalue = add i128 %q, %increment
  br label %rounded
rounded:
  %value = phi i128 [%leftvalue, %left], [%rightvalue, %rightshift]
  %carry = icmp uge i128 %value, 9007199254740992
  %halved = lshr i128 %value, 1
  %final = select i1 %carry, i128 %halved, i128 %value
  %step = zext i1 %carry to i64
  %finalpower = add i64 %target, %step
  %overflow = icmp sgt i64 %finalpower, 971
  br i1 %overflow, label %infinity, label %encode
infinity:
  %infbits = or i64 %sign, 9218868437227405312
  %inf = bitcast i64 %infbits to double
  ret double %inf
encode:
  %mantissa = trunc i128 %final to i64
  %normal = icmp uge i64 %mantissa, 4503599627370496
  %powerbits = add i64 %finalpower, 1075
  %biased = select i1 %normal, i64 %powerbits, i64 0
  %exponentbits = shl i64 %biased, 52
  %fraction = and i64 %mantissa, 4503599627370495
  %positive = or i64 %exponentbits, %fraction
  %resultbits = or i64 %positive, %sign
  %result = bitcast i64 %resultbits to double
  ret double %result
}

define double @m_scale_bits(double %x, i64 %power) {
entry:
  %bits = bitcast double %x to i64
  %mag = and i64 %bits, 9223372036854775807
  %special = icmp uge i64 %mag, 9218868437227405312
  %zero = icmp eq i64 %mag, 0
  %same = or i1 %special, %zero
  br i1 %same, label %unchanged, label %scale
unchanged:
  ret double %x
scale:
  %slot = alloca i64
  %mantissa = call i64 @m_parts(double %x, ptr %slot)
  %exponent = load i64, ptr %slot
  %high = icmp sgt i64 %power, 4096
  %low = icmp slt i64 %power, -4096
  %limitedhigh = select i1 %high, i64 4096, i64 %power
  %limited = select i1 %low, i64 -4096, i64 %limitedhigh
  %adjusted = add i64 %exponent, %limited
  %wide = zext i64 %mantissa to i128
  %sign = and i64 %bits, -9223372036854775808
  %result = call double @m_pack(i128 %wide, i64 %adjusted, i64 %sign)
  ret double %result
}

define double @m_fmod_bits(double %x, double %y) {
entry:
  %xb = bitcast double %x to i64
  %yb = bitcast double %y to i64
  %xm = and i64 %xb, 9223372036854775807
  %ym = and i64 %yb, 9223372036854775807
  %xinvalid = icmp uge i64 %xm, 9218868437227405312
  %ynan = icmp ugt i64 %ym, 9218868437227405312
  %yzero = icmp eq i64 %ym, 0
  %bad0 = or i1 %xinvalid, %ynan
  %bad = or i1 %bad0, %yzero
  br i1 %bad, label %nan, label %compare
nan:
  ret double 0x7FF8000000000000
compare:
  %small = icmp ult i64 %xm, %ym
  br i1 %small, label %same, label %start
same:
  ret double %x
start:
  %sign = and i64 %xb, -9223372036854775808
  %xep = alloca i64
  %yep = alloca i64
  %xmant0 = call i64 @m_parts(double %x, ptr %xep)
  %ymant0 = call i64 @m_parts(double %y, ptr %yep)
  %xe0 = load i64, ptr %xep
  %ye0 = load i64, ptr %yep
  %xlz = call i64 @llvm.ctlz.i64(i64 %xmant0, i1 false)
  %ylz = call i64 @llvm.ctlz.i64(i64 %ymant0, i1 false)
  %xshift = sub i64 %xlz, 11
  %yshift = sub i64 %ylz, 11
  %xmant = shl i64 %xmant0, %xshift
  %ymant = shl i64 %ymant0, %yshift
  %xe = sub i64 %xe0, %xshift
  %ye = sub i64 %ye0, %yshift
  br label %loop
loop:
  %mant = phi i64 [%xmant, %start], [%doubled, %advance]
  %exponent = phi i64 [%xe, %start], [%previous, %advance]
  %enough = icmp uge i64 %mant, %ymant
  %difference = sub i64 %mant, %ymant
  %rest = select i1 %enough, i64 %difference, i64 %mant
  %finished = icmp sle i64 %exponent, %ye
  br i1 %finished, label %done, label %advance
advance:
  %doubled = shl i64 %rest, 1
  %previous = sub i64 %exponent, 1
  br label %loop
done:
  %wide = zext i64 %rest to i128
  %result = call double @m_pack(i128 %wide, i64 %ye, i64 %sign)
  ret double %result
}

define double @m_remainder_bits(double %x, double %y) {
entry:
  %a = call double @llvm.fabs.f64(double %x)
  %b = call double @llvm.fabs.f64(double %y)
  %twob = fmul double %b, 2.000000e+00
  %r = call double @m_fmod_bits(double %a, double %twob)
  %twicer = fmul double %r, 2.000000e+00
  %first = fcmp ogt double %twicer, %b
  %r1sub = fsub double %r, %b
  %r1 = select i1 %first, double %r1sub, double %r
  %twicer1 = fmul double %r1, 2.000000e+00
  %secondpossible = fcmp oge double %twicer1, %b
  %second = and i1 %first, %secondpossible
  %r2sub = fsub double %r1, %b
  %r2 = select i1 %second, double %r2sub, double %r1
  %raw = bitcast double %x to i64
  %negative = icmp slt i64 %raw, 0
  %negated = fneg double %r2
  %result = select i1 %negative, double %negated, double %r2
  ret double %result
}

define double @m_atan2_bits(double %y, double %x) {
entry:
  %xb = bitcast double %x to i64
  %yb = bitcast double %y to i64
  %xm = and i64 %xb, 9223372036854775807
  %ym = and i64 %yb, 9223372036854775807
  %xn = icmp slt i64 %xb, 0
  %yn = icmp slt i64 %yb, 0
  %xnan = icmp ugt i64 %xm, 9218868437227405312
  %ynan = icmp ugt i64 %ym, 9218868437227405312
  %nan = or i1 %xnan, %ynan
  br i1 %nan, label %invalid, label %checkzero
invalid:
  %nv = fadd double %x, %y
  ret double %nv
checkzero:
  %yz = icmp eq i64 %ym, 0
  br i1 %yz, label %axis, label %checkxzero
axis:
  %signedpi = select i1 %yn, double -3.1415926535897931e+00, double 3.1415926535897931e+00
  %axisangle = select i1 %xn, double %signedpi, double %y
  ret double %axisangle
checkxzero:
  %xz = icmp eq i64 %xm, 0
  br i1 %xz, label %vertical, label %checkinfinite
vertical:
  %halfpi = select i1 %yn, double -1.5707963267948966e+00, double 1.5707963267948966e+00
  ret double %halfpi
checkinfinite:
  %xi = icmp eq i64 %xm, 9218868437227405312
  %yi = icmp eq i64 %ym, 9218868437227405312
  %both = and i1 %xi, %yi
  br i1 %both, label %diagonal, label %ordinary
diagonal:
  %quadrant = select i1 %xn, double 2.3561944901923448e+00, double 7.8539816339744828e-01
  br label %sign
ordinary:
  %ratio = fdiv double %y, %x
  %absratio = call double @llvm.fabs.f64(double %ratio)
  %acute = call double @m_atan(double %absratio)
  %obtuse = fsub double 3.1415926535897931e+00, %acute
  %angle = select i1 %xn, double %obtuse, double %acute
  br label %sign
sign:
  %positive = phi double [%quadrant, %diagonal], [%angle, %ordinary]
  %negative = fneg double %positive
  %result = select i1 %yn, double %negative, double %positive
  ret double %result
}

define double @m_hypot_bits(double %x, double %y) {
entry:
  %a = call double @llvm.fabs.f64(double %x)
  %b = call double @llvm.fabs.f64(double %y)
  %ainf = fcmp oeq double %a, 0x7FF0000000000000
  %binf = fcmp oeq double %b, 0x7FF0000000000000
  %inf = or i1 %ainf, %binf
  br i1 %inf, label %infinite, label %check
infinite:
  ret double 0x7FF0000000000000
check:
  %nan = fcmp uno double %a, %b
  br i1 %nan, label %invalid, label %order
invalid:
  %nanresult = fadd double %a, %b
  ret double %nanresult
order:
  %greater = fcmp ogt double %a, %b
  %large = select i1 %greater, double %a, double %b
  %small = select i1 %greater, double %b, double %a
  %zero = fcmp oeq double %large, 0.000000e+00
  br i1 %zero, label %same, label %calculate
same:
  ret double %large
calculate:
  %ratio = fdiv double %small, %large
  %square = fmul double %ratio, %ratio
  %sum = fadd double 1.000000e+00, %square
  %root = call double @llvm.sqrt.f64(double %sum)
  %result = fmul double %large, %root
  ret double %result
}

define internal i128 @m_rightjam(i128 %value, i64 %shift) {
entry:
  %zero = icmp eq i64 %shift, 0
  br i1 %zero, label %same, label %check
same:
  ret i128 %value
check:
  %large = icmp uge i64 %shift, 128
  br i1 %large, label %sticky, label %shiftvalue
sticky:
  %nonzero = icmp ne i128 %value, 0
  %bit = zext i1 %nonzero to i128
  ret i128 %bit
shiftvalue:
  %wide = zext i64 %shift to i128
  %q = lshr i128 %value, %wide
  %back = shl i128 %q, %wide
  %lost = icmp ne i128 %back, %value
  %last = zext i1 %lost to i128
  %result = or i128 %q, %last
  ret i128 %result
}

define double @m_fma(double %x, double %y, double %z) {
entry:
  %xb = bitcast double %x to i64
  %yb = bitcast double %y to i64
  %zb = bitcast double %z to i64
  %xm = and i64 %xb, 9223372036854775807
  %ym = and i64 %yb, 9223372036854775807
  %zm = and i64 %zb, 9223372036854775807
  %xs = icmp uge i64 %xm, 9218868437227405312
  %ys = icmp uge i64 %ym, 9218868437227405312
  %zs = icmp uge i64 %zm, 9218868437227405312
  %s0 = or i1 %xs, %ys
  %special = or i1 %s0, %zs
  br i1 %special, label %ordinary, label %finite
ordinary:
  %finiteproduct = xor i1 %s0, true
  %onlyzspecial = and i1 %finiteproduct, %zs
  br i1 %onlyzspecial, label %zvalue, label %specialproduct
zvalue:
  ret double %z
specialproduct:
  %product = fmul double %x, %y
  %ordinaryvalue = fadd double %product, %z
  ret double %ordinaryvalue
finite:
  %xep = alloca i64
  %yep = alloca i64
  %zep = alloca i64
  %xmant = call i64 @m_parts(double %x, ptr %xep)
  %ymant = call i64 @m_parts(double %y, ptr %yep)
  %zmant = call i64 @m_parts(double %z, ptr %zep)
  %xe = load i64, ptr %xep
  %ye = load i64, ptr %yep
  %ze = load i64, ptr %zep
  %xw = zext i64 %xmant to i128
  %yw = zext i64 %ymant to i128
  %zw = zext i64 %zmant to i128
  %pm = mul i128 %xw, %yw
  %pmwide = shl i128 %pm, 14
  %zmwide = shl i128 %zw, 67
  %pe0 = add i64 %xe, %ye
  %pe = sub i64 %pe0, 14
  %ce = sub i64 %ze, 67
  %pzero = icmp eq i128 %pm, 0
  %zzero = icmp eq i64 %zmant, 0
  %dominantp = icmp sge i64 %pe, %ce
  %large0 = select i1 %dominantp, i64 %pe, i64 %ce
  %large1 = select i1 %pzero, i64 %ce, i64 %large0
  %large = select i1 %zzero, i64 %pe, i64 %large1
  %pdelta0 = sub i64 %large, %pe
  %zdelta0 = sub i64 %large, %ce
  %pdelta = select i1 %pzero, i64 0, i64 %pdelta0
  %zdelta = select i1 %zzero, i64 0, i64 %zdelta0
  %pa = call i128 @m_rightjam(i128 %pmwide, i64 %pdelta)
  %za = call i128 @m_rightjam(i128 %zmwide, i64 %zdelta)
  %productbits = xor i64 %xb, %yb
  %psign = and i64 %productbits, -9223372036854775808
  %zsign = and i64 %zb, -9223372036854775808
  %samesign = icmp eq i64 %psign, %zsign
  br i1 %samesign, label %add, label %subtract
add:
  %sum = add i128 %pa, %za
  br label %pack
subtract:
  %pgreater = icmp uge i128 %pa, %za
  %pminus = sub i128 %pa, %za
  %zminus = sub i128 %za, %pa
  %difference = select i1 %pgreater, i128 %pminus, i128 %zminus
  %sign0 = select i1 %pgreater, i64 %psign, i64 %zsign
  %cancelled = icmp eq i128 %difference, 0
  %differencesign = select i1 %cancelled, i64 0, i64 %sign0
  br label %pack
pack:
  %magnitude = phi i128 [%sum, %add], [%difference, %subtract]
  %sign = phi i64 [%psign, %add], [%differencesign, %subtract]
  %result = call double @m_pack(i128 %magnitude, i64 %large, i64 %sign)
  ret double %result
}
