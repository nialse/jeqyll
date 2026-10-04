%MD = type { double, double }
%MSC = type { %MD, %MD }

declare double @m_fma(double, double, double)
declare double @llvm.fabs.f64(double)
declare double @llvm.sqrt.f64(double)
declare double @m_scale_bits(double, i64)
declare i32 @m_reduce_pio2(double, ptr, ptr)
declare double @m_round(double, i1)

define %MD @md_value(double %x) {
  %value = insertvalue %MD zeroinitializer, double %x, 0
  ret %MD %value
}

define %MD @md_add(%MD %a, %MD %b) {
  %ah = extractvalue %MD %a, 0
  %al = extractvalue %MD %a, 1
  %bh = extractvalue %MD %b, 0
  %bl = extractvalue %MD %b, 1
  %s = fadd double %ah, %bh
  %v = fsub double %s, %ah
  %u = fsub double %s, %v
  %ae = fsub double %ah, %u
  %be = fsub double %bh, %v
  %e = fadd double %ae, %be
  %tails = fadd double %al, %bl
  %t = fadd double %e, %tails
  %h = fadd double %s, %t
  %captured = fsub double %h, %s
  %l = fsub double %t, %captured
  %head = insertvalue %MD poison, double %h, 0
  %result = insertvalue %MD %head, double %l, 1
  ret %MD %result
}

define %MD @md_neg(%MD %a) {
  %ah = extractvalue %MD %a, 0
  %al = extractvalue %MD %a, 1
  %h = fneg double %ah
  %l = fneg double %al
  %head = insertvalue %MD poison, double %h, 0
  %result = insertvalue %MD %head, double %l, 1
  ret %MD %result
}

define %MD @md_mul(%MD %a, %MD %b) {
  %ah = extractvalue %MD %a, 0
  %al = extractvalue %MD %a, 1
  %bh = extractvalue %MD %b, 0
  %bl = extractvalue %MD %b, 1
  %p = fmul double %ah, %bh
  %np = fneg double %p
  %e = call double @m_fma(double %ah, double %bh, double %np)
  %ab = fmul double %ah, %bl
  %ba = fmul double %al, %bh
  %cross = fadd double %ab, %ba
  %t = fadd double %e, %cross
  %h = fadd double %p, %t
  %captured = fsub double %h, %p
  %l = fsub double %t, %captured
  %head = insertvalue %MD poison, double %h, 0
  %result = insertvalue %MD %head, double %l, 1
  ret %MD %result
}

define %MD @md_div(%MD %a, %MD %b) {
  %ah = extractvalue %MD %a, 0
  %bh = extractvalue %MD %b, 0
  %q = fdiv double %ah, %bh
  %qv = call %MD @md_value(double %q)
  %p = call %MD @md_mul(%MD %qv, %MD %b)
  %np = call %MD @md_neg(%MD %p)
  %r = call %MD @md_add(%MD %a, %MD %np)
  %rh = extractvalue %MD %r, 0
  %rl = extractvalue %MD %r, 1
  %rall = fadd double %rh, %rl
  %correction = fdiv double %rall, %bh
  %cv = call %MD @md_value(double %correction)
  %result = call %MD @md_add(%MD %qv, %MD %cv)
  ret %MD %result
}

define %MD @md_sqrt(%MD %a) {
entry:
  %ah = extractvalue %MD %a, 0
  %root = call double @llvm.sqrt.f64(double %ah)
  %rv = call %MD @md_value(double %root)
  %positive = fcmp ogt double %root, 0.0
  br i1 %positive, label %refine, label %done
refine:
  %square = call %MD @md_mul(%MD %rv, %MD %rv)
  %nsquare = call %MD @md_neg(%MD %square)
  %error = call %MD @md_add(%MD %a, %MD %nsquare)
  %twice = fmul double %root, 2.0
  %den = call %MD @md_value(double %twice)
  %correction = call %MD @md_div(%MD %error, %MD %den)
  %result = call %MD @md_add(%MD %rv, %MD %correction)
  ret %MD %result
done:
  ret %MD %rv
}

define %MSC @md_sincos(double %x) {
entry:
  %hp = alloca double
  %lp = alloca double
  %q = call i32 @m_reduce_pio2(double %x, ptr %hp, ptr %lp)
  %h = load double, ptr %hp
  %l = load double, ptr %lp
  %hv = insertvalue %MD poison, double %h, 0
  %r = insertvalue %MD %hv, double %l, 1
  %square = call %MD @md_mul(%MD %r, %MD %r)
  %negative = call %MD @md_neg(%MD %square)
  br label %loop
loop:
  %i = phi i64 [1, %entry], [%next, %body]
  %st = phi %MD [%r, %entry], [%snext, %body]
  %ct = phi %MD [{double 1.0, double 0.0}, %entry], [%cnext, %body]
  %ss = phi %MD [%r, %entry], [%snew, %body]
  %cs = phi %MD [{double 1.0, double 0.0}, %entry], [%cnew, %body]
  %more = icmp ule i64 %i, 15
  br i1 %more, label %body, label %quadrant
body:
  %twice = mul i64 %i, 2
  %plus = add i64 %twice, 1
  %minus = sub i64 %twice, 1
  %sdeni = mul i64 %twice, %plus
  %cdeni = mul i64 %twice, %minus
  %sd = uitofp i64 %sdeni to double
  %cd = uitofp i64 %cdeni to double
  %sdv = call %MD @md_value(double %sd)
  %cdv = call %MD @md_value(double %cd)
  %sp = call %MD @md_mul(%MD %st, %MD %negative)
  %cp = call %MD @md_mul(%MD %ct, %MD %negative)
  %snext = call %MD @md_div(%MD %sp, %MD %sdv)
  %cnext = call %MD @md_div(%MD %cp, %MD %cdv)
  %snew = call %MD @md_add(%MD %ss, %MD %snext)
  %cnew = call %MD @md_add(%MD %cs, %MD %cnext)
  %next = add i64 %i, 1
  br label %loop
quadrant:
  %odd = and i32 %q, 1
  %swap = icmp ne i32 %odd, 0
  %s = select i1 %swap, %MD %cs, %MD %ss
  %c = select i1 %swap, %MD %ss, %MD %cs
  %ns = call %MD @md_neg(%MD %s)
  %nc = call %MD @md_neg(%MD %c)
  %snegative = icmp ne i32 %q, 0
  %qhigh = and i32 %q, 2
  %sneg = icmp ne i32 %qhigh, 0
  %cshift = add i32 %q, 1
  %chigh = and i32 %cshift, 2
  %cneg = icmp ne i32 %chigh, 0
  %sine = select i1 %sneg, %MD %ns, %MD %s
  %cosine = select i1 %cneg, %MD %nc, %MD %c
  %sr = insertvalue %MSC poison, %MD %sine, 0
  %result = insertvalue %MSC %sr, %MD %cosine, 1
  ret %MSC %result
}

define double @m_precise_trig(double %x, i32 %mode) {
entry:
  %a = call double @llvm.fabs.f64(double %x)
  %tiny = fcmp olt double %a, 7.4505805969238281e-09
  br i1 %tiny, label %small, label %finitecheck
small:
  %iscos = icmp eq i32 %mode, 1
  %identity = select i1 %iscos, double 1.0, double %x
  ret double %identity
finitecheck:
  %finite = fcmp olt double %a, 0x7FF0000000000000
  br i1 %finite, label %calculate, label %invalid
invalid:
  %nan = fsub double %x, %x
  ret double %nan
calculate:
  %both = call %MSC @md_sincos(double %x)
  %sine = extractvalue %MSC %both, 0
  %cosine = extractvalue %MSC %both, 1
  %istan = icmp eq i32 %mode, 2
  br i1 %istan, label %tangent, label %select
tangent:
  %ratio = call %MD @md_div(%MD %sine, %MD %cosine)
  %tan = extractvalue %MD %ratio, 0
  ret double %tan
select:
  %cos = icmp eq i32 %mode, 1
  %value = select i1 %cos, %MD %cosine, %MD %sine
  %result = extractvalue %MD %value, 0
  ret double %result
}

define %MD @md_atan(%MD %x) {
entry:
  %h = extractvalue %MD %x, 0
  %infinite = fcmp oeq double %h, 0x7FF0000000000000
  br i1 %infinite, label %halfpi, label %start
halfpi:
  ret %MD {double 1.5707963267948966e+00, double 6.1232339957367660e-17}
start:
  %invert = fcmp ogt double %h, 1.0
  br i1 %invert, label %inverse, label %direct
inverse:
  %inv = call %MD @md_div(%MD {double 1.0, double 0.0}, %MD %x)
  br label %reduce
direct:
  br label %reduce
reduce:
  %u = phi %MD [%inv, %inverse], [%x, %direct]
  %uh = extractvalue %MD %u, 0
  %shift = fcmp ogt double %uh, 4.1421356237309505e-01
  br i1 %shift, label %shifted, label %unchanged
shifted:
  %num = call %MD @md_add(%MD %u, %MD {double -1.0, double 0.0})
  %den = call %MD @md_add(%MD %u, %MD {double 1.0, double 0.0})
  %reduced = call %MD @md_div(%MD %num, %MD %den)
  br label %series
unchanged:
  br label %series
series:
  %r = phi %MD [%reduced, %shifted], [%u, %unchanged]
  %square = call %MD @md_mul(%MD %r, %MD %r)
  %negative = call %MD @md_neg(%MD %square)
  br label %loop
loop:
  %i = phi i64 [3, %series], [%next, %body]
  %term = phi %MD [%r, %series], [%tn, %body]
  %sum = phi %MD [%r, %series], [%sn, %body]
  %more = icmp ule i64 %i, 89
  br i1 %more, label %body, label %adjust
body:
  %tn = call %MD @md_mul(%MD %term, %MD %negative)
  %d = uitofp i64 %i to double
  %dv = call %MD @md_value(double %d)
  %part = call %MD @md_div(%MD %tn, %MD %dv)
  %sn = call %MD @md_add(%MD %sum, %MD %part)
  %next = add i64 %i, 2
  br label %loop
adjust:
  %shiftedangle = call %MD @md_add(%MD %sum, %MD {double 7.8539816339744828e-01, double 3.0616169978683830e-17})
  %angle = select i1 %shift, %MD %shiftedangle, %MD %sum
  %negativeangle = call %MD @md_neg(%MD %angle)
  %inverted = call %MD @md_add(%MD {double 1.5707963267948966e+00, double 6.1232339957367660e-17}, %MD %negativeangle)
  %result = select i1 %invert, %MD %inverted, %MD %angle
  ret %MD %result
}

define double @m_precise_atan(double %x) {
entry:
  %a = call double @llvm.fabs.f64(double %x)
  %tiny = fcmp olt double %a, 7.4505805969238281e-09
  br i1 %tiny, label %same, label %calculate
same:
  ret double %x
calculate:
  %v = call %MD @md_value(double %a)
  %angle = call %MD @md_atan(%MD %v)
  %h = extractvalue %MD %angle, 0
  %negative = fcmp olt double %x, 0.0
  %nh = fneg double %h
  %result = select i1 %negative, double %nh, double %h
  ret double %result
}

define %MD @md_log(double %x) {
entry:
  %raw = bitcast double %x to i64
  %eb = lshr i64 %raw, 52
  %subnormal = icmp eq i64 %eb, 0
  %scaled = fmul double %x, 4.503599627370496e+15
  %normal = select i1 %subnormal, double %scaled, double %x
  %bits = bitcast double %normal to i64
  %exponentbits = lshr i64 %bits, 52
  %bias = select i1 %subnormal, i64 1075, i64 1023
  %exponent0 = sub i64 %exponentbits, %bias
  %mantissabits = and i64 %bits, 4503599627370495
  %unitbits = or i64 %mantissabits, 4607182418800017408
  %unit = bitcast i64 %unitbits to double
  %reduce = fcmp ogt double %unit, 1.4142135623730951e+00
  %half = fmul double %unit, 0.5
  %man = select i1 %reduce, double %half, double %unit
  %inc = zext i1 %reduce to i64
  %exponent = add i64 %exponent0, %inc
  %mv = call %MD @md_value(double %man)
  %num = call %MD @md_add(%MD %mv, %MD {double -1.0, double 0.0})
  %den = call %MD @md_add(%MD %mv, %MD {double 1.0, double 0.0})
  %y = call %MD @md_div(%MD %num, %MD %den)
  %square = call %MD @md_mul(%MD %y, %MD %y)
  br label %loop
loop:
  %i = phi i64 [3, %entry], [%next, %body]
  %term = phi %MD [%y, %entry], [%tn, %body]
  %sum = phi %MD [%y, %entry], [%sn, %body]
  %more = icmp ule i64 %i, 45
  br i1 %more, label %body, label %finish
body:
  %tn = call %MD @md_mul(%MD %term, %MD %square)
  %d = uitofp i64 %i to double
  %dv = call %MD @md_value(double %d)
  %part = call %MD @md_div(%MD %tn, %MD %dv)
  %sn = call %MD @md_add(%MD %sum, %MD %part)
  %next = add i64 %i, 2
  br label %loop
finish:
  %logman = call %MD @md_mul(%MD %sum, %MD {double 2.0, double 0.0})
  %ef = sitofp i64 %exponent to double
  %ev = call %MD @md_value(double %ef)
  %logexp = call %MD @md_mul(%MD %ev, %MD {double 6.9314718055994529e-01, double 2.3190468138462996e-17})
  %result = call %MD @md_add(%MD %logexp, %MD %logman)
  ret %MD %result
}

define double @m_precise_log(double %x, i1 %base2) {
entry:
  %positive = fcmp ogt double %x, 0.0
  br i1 %positive, label %finitecheck, label %nonpositive
nonpositive:
  %zero = fcmp oeq double %x, 0.0
  %special = select i1 %zero, double 0xFFF0000000000000, double 0x7FF8000000000000
  ret double %special
finitecheck:
  %finite = fcmp olt double %x, 0x7FF0000000000000
  br i1 %finite, label %calculate, label %same
same:
  ret double %x
calculate:
  %log = call %MD @md_log(double %x)
  br i1 %base2, label %binary, label %natural
binary:
  %ratio = call %MD @md_div(%MD %log, %MD {double 6.9314718055994529e-01, double 2.3190468138462996e-17})
  %log2 = extractvalue %MD %ratio, 0
  ret double %log2
natural:
  %result = extractvalue %MD %log, 0
  ret double %result
}

define double @m_precise_log1p(double %x) {
entry:
  %a = call double @llvm.fabs.f64(double %x)
  %tiny = fcmp olt double %a, 5.5511151231257827e-17
  br i1 %tiny, label %same, label %check
same:
  ret double %x
check:
  %valid = fcmp ogt double %x, -1.0
  %finite = fcmp olt double %x, 0x7FF0000000000000
  %ordinary = and i1 %valid, %finite
  br i1 %ordinary, label %calculate, label %special
special:
  %arg = fadd double 1.0, %x
  %specialresult = call double @m_precise_log(double %arg, i1 false)
  ret double %specialresult
calculate:
  %xv = call %MD @md_value(double %x)
  %sum = call %MD @md_add(%MD %xv, %MD {double 1.0, double 0.0})
  %h = extractvalue %MD %sum, 0
  %l = extractvalue %MD %sum, 1
  %correction = fdiv double %l, %h
  %cv = call %MD @md_value(double %correction)
  %log = call %MD @md_log(double %h)
  %corrected = call %MD @md_add(%MD %log, %MD %cv)
  %result = extractvalue %MD %corrected, 0
  ret double %result
}

define double @m_precise_asin(double %x, i1 %acos) {
entry:
  %a = call double @llvm.fabs.f64(double %x)
  %valid = fcmp ole double %a, 1.0
  br i1 %valid, label %calculate, label %invalid
invalid:
  ret double 0x7FF8000000000000
calculate:
  %v = call %MD @md_value(double %a)
  %square = call %MD @md_mul(%MD %v, %MD %v)
  %negative = call %MD @md_neg(%MD %square)
  %distance = call %MD @md_add(%MD {double 1.0, double 0.0}, %MD %negative)
  %root = call %MD @md_sqrt(%MD %distance)
  %unit = fcmp oeq double %a, 1.0
  br i1 %unit, label %endpoint, label %ordinary
endpoint:
  br label %sign
ordinary:
  %ratio = call %MD @md_div(%MD %v, %MD %root)
  %angle = call %MD @md_atan(%MD %ratio)
  br label %sign
sign:
  %magnitude = phi %MD [{double 1.5707963267948966e+00, double 6.1232339957367660e-17}, %endpoint], [%angle, %ordinary]
  %xb = bitcast double %x to i64
  %neg = icmp slt i64 %xb, 0
  %negangle = call %MD @md_neg(%MD %magnitude)
  %signed = select i1 %neg, %MD %negangle, %MD %magnitude
  br i1 %acos, label %complement, label %direct
complement:
  %nsigned = call %MD @md_neg(%MD %signed)
  %comp = call %MD @md_add(%MD {double 1.5707963267948966e+00, double 6.1232339957367660e-17}, %MD %nsigned)
  %cosresult = extractvalue %MD %comp, 0
  ret double %cosresult
direct:
  %sinresult = extractvalue %MD %signed, 0
  %zero = fcmp oeq double %x, 0.0
  %result = select i1 %zero, double %x, double %sinresult
  ret double %result
}

define %MD @md_log_value(%MD %x) {
  %h = extractvalue %MD %x, 0
  %l = extractvalue %MD %x, 1
  %correction = fdiv double %l, %h
  %cv = call %MD @md_value(double %correction)
  %log = call %MD @md_log(double %h)
  %result = call %MD @md_add(%MD %log, %MD %cv)
  ret %MD %result
}

define double @m_precise_inverse_hyperbolic(double %x, i1 %acosh) {
entry:
  %a = call double @llvm.fabs.f64(double %x)
  %below = fcmp ult double %x, 1.0
  %baddomain = and i1 %acosh, %below
  br i1 %baddomain, label %invalid, label %finitecheck
invalid:
  ret double 0x7FF8000000000000
finitecheck:
  %finite = fcmp olt double %a, 0x7FF0000000000000
  br i1 %finite, label %size, label %same
same:
  ret double %x
size:
  %tiny = fcmp olt double %a, 3.7252902984619141e-09
  br i1 %tiny, label %same, label %largecheck
largecheck:
  %large = fcmp ogt double %a, 2.684354560e+08
  br i1 %large, label %logarithm, label %calculate
logarithm:
  %log = call %MD @md_log(double %a)
  %largevalue = call %MD @md_add(%MD %log, %MD {double 6.9314718055994529e-01, double 2.3190468138462996e-17})
  br label %sign
calculate:
  %v = call %MD @md_value(double %a)
  br i1 %acosh, label %cosh, label %sinh
cosh:
  %minus = call %MD @md_add(%MD %v, %MD {double -1.0, double 0.0})
  %plus = call %MD @md_add(%MD %v, %MD {double 1.0, double 0.0})
  %product = call %MD @md_mul(%MD %minus, %MD %plus)
  %coshroot = call %MD @md_sqrt(%MD %product)
  %cosharg = call %MD @md_add(%MD %v, %MD %coshroot)
  %coshvalue = call %MD @md_log_value(%MD %cosharg)
  br label %sign
sinh:
  %square = call %MD @md_mul(%MD %v, %MD %v)
  %squaresum = call %MD @md_add(%MD %square, %MD {double 1.0, double 0.0})
  %sinhroot = call %MD @md_sqrt(%MD %squaresum)
  %sinharg = call %MD @md_add(%MD %v, %MD %sinhroot)
  %sinhvalue = call %MD @md_log_value(%MD %sinharg)
  br label %sign
sign:
  %value = phi %MD [%largevalue, %logarithm], [%coshvalue, %cosh], [%sinhvalue, %sinh]
  %h = extractvalue %MD %value, 0
  %negative = fcmp olt double %x, 0.0
  %nh = fneg double %h
  %result = select i1 %negative, double %nh, double %h
  ret double %result
}

define double @m_precise_pow(double %x, double %y) {
entry:
  %log = call %MD @md_log(double %x)
  %lh = extractvalue %MD %log, 0
  %estimate = fmul double %lh, %y
  %large = fcmp ogt double %estimate, 710.0
  br i1 %large, label %overflow, label %underflowcheck
overflow:
  ret double 0x7FF0000000000000
underflowcheck:
  %small = fcmp olt double %estimate, -746.0
  br i1 %small, label %underflow, label %calculate
underflow:
  ret double 0.0
calculate:
  %yv = call %MD @md_value(double %y)
  %exponent = call %MD @md_mul(%MD %log, %MD %yv)
  %eh = extractvalue %MD %exponent, 0
  %binary = fmul double %eh, 1.4426950408889634e+00
  %kf = call double @m_round(double %binary, i1 true)
  %k = fptosi double %kf to i64
  %nkf = fneg double %kf
  %kv = call %MD @md_value(double %nkf)
  %offset = call %MD @md_mul(%MD %kv, %MD {double 6.9314718055994529e-01, double 2.3190468138462996e-17})
  %remainder = call %MD @md_add(%MD %exponent, %MD %offset)
  br label %loop
loop:
  %i = phi i64 [1, %calculate], [%next, %body]
  %term = phi %MD [{double 1.0, double 0.0}, %calculate], [%tn, %body]
  %sum = phi %MD [{double 1.0, double 0.0}, %calculate], [%sn, %body]
  %more = icmp ule i64 %i, 26
  br i1 %more, label %body, label %done
body:
  %product = call %MD @md_mul(%MD %term, %MD %remainder)
  %denominator = uitofp i64 %i to double
  %dv = call %MD @md_value(double %denominator)
  %tn = call %MD @md_div(%MD %product, %MD %dv)
  %sn = call %MD @md_add(%MD %sum, %MD %tn)
  %next = add i64 %i, 1
  br label %loop
done:
  %high = extractvalue %MD %sum, 0
  %result = call double @m_scale_bits(double %high, i64 %k)
  ret double %result
}

define double @m_precise_atan2_finite(double %y, double %x) {
entry:
  %ax = call double @llvm.fabs.f64(double %x)
  %ay = call double @llvm.fabs.f64(double %y)
  %invert = fcmp ogt double %ay, %ax
  %num = select i1 %invert, double %ax, double %ay
  %den = select i1 %invert, double %ay, double %ax
  %nv = call %MD @md_value(double %num)
  %dv = call %MD @md_value(double %den)
  %ratio = call %MD @md_div(%MD %nv, %MD %dv)
  %angle = call %MD @md_atan(%MD %ratio)
  %negative = call %MD @md_neg(%MD %angle)
  %complement = call %MD @md_add(%MD {double 1.5707963267948966e+00, double 6.1232339957367660e-17}, %MD %negative)
  %acute = select i1 %invert, %MD %complement, %MD %angle
  %nacute = call %MD @md_neg(%MD %acute)
  %obtuse = call %MD @md_add(%MD {double 3.1415926535897931e+00, double 1.2246467991473532e-16}, %MD %nacute)
  %xn = fcmp olt double %x, 0.0
  %quadrant = select i1 %xn, %MD %obtuse, %MD %acute
  %h = extractvalue %MD %quadrant, 0
  %yn = fcmp olt double %y, 0.0
  %nh = fneg double %h
  %result = select i1 %yn, double %nh, double %h
  ret double %result
}
