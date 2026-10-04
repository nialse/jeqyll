@mt.two_over_pi = private constant [144 x i8] c"\A2\F9\83\6E\4E\44\15\29\FC\27\57\D1\F5\34\DD\C0\DB\62\95\99\3C\43\90\41\FE\51\63\AB\DE\BB\C5\61\B7\24\6E\3A\42\4D\D2\E0\06\49\2E\EA\09\D1\92\1C\FE\1D\EB\1C\B1\29\A7\3E\E8\82\35\F5\2E\BB\44\84\E9\9C\70\26\B4\5F\7E\41\39\91\D6\39\83\53\39\F4\9C\84\5F\8B\BD\F9\28\3B\1F\F8\97\FF\DE\05\98\0F\EF\2F\11\8B\5A\0A\6D\1F\6D\36\7E\CF\27\CB\09\B7\4F\46\3F\66\9E\5F\EA\2D\75\27\BA\C7\EB\E5\F1\7B\3D\07\39\F7\8A\52\92\EA\6B\FB\5F\B1\1F\8D\5D\08"

declare double @llvm.fabs.f64(double)
declare double @m_scale_bits(double, i64)
declare double @m_fma(double, double, double)
declare i64 @m_parts(double, ptr)

define i32 @m_reduce_pio2(double %x, ptr %high, ptr %low) {
entry:
  store double 0.000000e+00, ptr %low
  %a = call double @llvm.fabs.f64(double %x)
  %small = fcmp ole double %a, 7.8539816339744828e-01
  br i1 %small, label %unchanged, label %finitecheck
unchanged:
  store double %x, ptr %high
  ret i32 0
finitecheck:
  %finite = fcmp olt double %a, 0x7FF0000000000000
  br i1 %finite, label %start, label %invalid
invalid:
  %nan = fsub double %x, %x
  store double %nan, ptr %high
  ret i32 0
start:
  %ep = alloca i64
  %mantissa = call i64 @m_parts(double %a, ptr %ep)
  %exponent = load i64, ptr %ep
  %product = alloca [151 x i8], align 16
  br label %multiply
multiply:
  %i = phi i64 [0, %start], [%next, %digit]
  %carry = phi i64 [0, %start], [%nextcarry, %digit]
  %more = icmp ult i64 %i, 144
  br i1 %more, label %digit, label %carryloop
digit:
  %reverse = sub i64 143, %i
  %source = getelementptr i8, ptr @mt.two_over_pi, i64 %reverse
  %byte = load i8, ptr %source
  %wide = zext i8 %byte to i64
  %part = mul i64 %wide, %mantissa
  %sum = add i64 %part, %carry
  %lowbyte = trunc i64 %sum to i8
  %target = getelementptr i8, ptr %product, i64 %i
  store i8 %lowbyte, ptr %target
  %nextcarry = lshr i64 %sum, 8
  %next = add i64 %i, 1
  br label %multiply
carryloop:
  %ci = phi i64 [144, %multiply], [%cinext, %carrybody]
  %remaining = phi i64 [%carry, %multiply], [%rest, %carrybody]
  %carrymore = icmp ult i64 %ci, 151
  br i1 %carrymore, label %carrybody, label %bitsstart
carrybody:
  %cb = trunc i64 %remaining to i8
  %cp = getelementptr i8, ptr %product, i64 %ci
  store i8 %cb, ptr %cp
  %rest = lshr i64 %remaining, 8
  %cinext = add i64 %ci, 1
  br label %carryloop
bitsstart:
  %binarypoint = sub i64 1152, %exponent
  %firstbit = add i64 %binarypoint, 1
  br label %bitsloop
bitsloop:
  %bi = phi i64 [0, %bitsstart], [%binext, %bitsbody]
  %acc = phi i128 [0, %bitsstart], [%accnext, %bitsbody]
  %bitsmore = icmp ult i64 %bi, 114
  br i1 %bitsmore, label %bitsbody, label %fraction
bitsbody:
  %bitpos = sub i64 %firstbit, %bi
  %byteindex = lshr i64 %bitpos, 3
  %bitindex = and i64 %bitpos, 7
  %bp = getelementptr i8, ptr %product, i64 %byteindex
  %value = load i8, ptr %bp
  %shift = trunc i64 %bitindex to i8
  %bit0 = lshr i8 %value, %shift
  %bit = and i8 %bit0, 1
  %bitwide = zext i8 %bit to i128
  %accshift = shl i128 %acc, 1
  %accnext = or i128 %accshift, %bitwide
  %binext = add i64 %bi, 1
  br label %bitsloop
fraction:
  %unit = shl i128 1, 112
  %mask = sub i128 %unit, 1
  %fractionbits = and i128 %acc, %mask
  %half = lshr i128 %unit, 1
  %round = icmp uge i128 %fractionbits, %half
  %complement = sub i128 %unit, %fractionbits
  %magnitude = select i1 %round, i128 %complement, i128 %fractionbits
  %integerbits = lshr i128 %acc, 112
  %quadrant0 = trunc i128 %integerbits to i32
  %increment = zext i1 %round to i32
  %quadrant1 = add i32 %quadrant0, %increment
  %quadrant = and i32 %quadrant1, 3
  %highbitswide = lshr i128 %magnitude, 64
  %highbits = trunc i128 %highbitswide to i64
  %lowbits = trunc i128 %magnitude to i64
  %highfloat = uitofp i64 %highbits to double
  %lowfloat = uitofp i64 %lowbits to double
  %highfraction = call double @m_scale_bits(double %highfloat, i64 -48)
  %lowfraction = call double @m_scale_bits(double %lowfloat, i64 -112)
  %fh = fadd double %highfraction, %lowfraction
  %captured = fsub double %fh, %highfraction
  %fl = fsub double %lowfraction, %captured
  %rh = fmul double %fh, 1.5707963267948966e+00
  %negrh = fneg double %rh
  %producterror = call double @m_fma(double %fh, double 1.5707963267948966e+00, double %negrh)
  %pitail = fmul double %fh, 6.1232339957367660e-17
  %fractiontail = fmul double %fl, 1.5707963267948966e+00
  %tail0 = fadd double %producterror, %pitail
  %rl = fadd double %tail0, %fractiontail
  %xbits = bitcast double %x to i64
  %xnegative = icmp slt i64 %xbits, 0
  %negative = xor i1 %xnegative, %round
  %rhn = fneg double %rh
  %rln = fneg double %rl
  %resulthead = select i1 %negative, double %rhn, double %rh
  %resulttail = select i1 %negative, double %rln, double %rl
  store double %resulthead, ptr %high
  store double %resulttail, ptr %low
  %qnegative = sub i32 0, %quadrant
  %qsigned = select i1 %xnegative, i32 %qnegative, i32 %quadrant
  %resultquadrant = and i32 %qsigned, 3
  ret i32 %resultquadrant
}

define double @m_trig(double %x, i1 %cosine) {
entry:
  %zero = fcmp oeq double %x, 0.000000e+00
  br i1 %zero, label %identity, label %reduce
identity:
  %unit = select i1 %cosine, double 1.000000e+00, double %x
  ret double %unit
reduce:
  %hi = alloca double
  %lo = alloca double
  %q = call i32 @m_reduce_pio2(double %x, ptr %hi, ptr %lo)
  %r = load double, ptr %hi
  %tail = load double, ptr %lo
  %r2 = fmul double %r, %r
  %nr2 = fneg double %r2
  br label %loop
loop:
  %i = phi i64 [1, %reduce], [%next, %body]
  %sterm = phi double [%r, %reduce], [%st, %body]
  %cterm = phi double [1.000000e+00, %reduce], [%ct, %body]
  %ssum = phi double [%r, %reduce], [%ss, %body]
  %csum = phi double [1.000000e+00, %reduce], [%cs, %body]
  %scorrection = phi double [0.000000e+00, %reduce], [%sc, %body]
  %ccorrection = phi double [0.000000e+00, %reduce], [%cc, %body]
  %more = icmp ule i64 %i, 12
  br i1 %more, label %body, label %done
body:
  %twice = mul i64 %i, 2
  %plus = add i64 %twice, 1
  %minus = sub i64 %twice, 1
  %sdeni = mul i64 %twice, %plus
  %cdeni = mul i64 %twice, %minus
  %sd = uitofp i64 %sdeni to double
  %cd = uitofp i64 %cdeni to double
  %sn = fmul double %sterm, %nr2
  %cn = fmul double %cterm, %nr2
  %st = fdiv double %sn, %sd
  %ct = fdiv double %cn, %cd
  %sy = fsub double %st, %scorrection
  %cy = fsub double %ct, %ccorrection
  %ss = fadd double %ssum, %sy
  %cs = fadd double %csum, %cy
  %sdiff = fsub double %ss, %ssum
  %cdiff = fsub double %cs, %csum
  %sc = fsub double %sdiff, %sy
  %cc = fsub double %cdiff, %cy
  %next = add i64 %i, 1
  br label %loop
done:
  %sine = call double @m_fma(double %tail, double %csum, double %ssum)
  %negsine = fneg double %ssum
  %cos = call double @m_fma(double %tail, double %negsine, double %csum)
  %cosineshift = zext i1 %cosine to i32
  %phase = add i32 %q, %cosineshift
  %odd = and i32 %phase, 1
  %swapped = icmp ne i32 %odd, 0
  %positive = select i1 %swapped, double %cos, double %sine
  %sign = and i32 %phase, 2
  %negative = icmp ne i32 %sign, 0
  %negated = fneg double %positive
  %result = select i1 %negative, double %negated, double %positive
  ret double %result
}
