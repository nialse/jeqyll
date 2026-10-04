%UR = type { ptr, i64 }
%UN = type { ptr, i64, i32 }
%UF = type { i32, i32, i32, i32, i32 }

@rx_unicode_range_count = external constant i32
@rx_unicode_name_count = external constant i32
@rx_unicode_fold_count = external constant i32
@rx_unicode_ranges = external constant [0 x %UR]
@rx_unicode_names = external constant [0 x %UN]
@rx_unicode_folds = external constant [0 x %UF]

define i32 @rx_unicode_property(ptr %name, i64 %length) {
entry:
  %buffer = alloca [64 x i8]
  br label %normalize
normalize:
  %i = phi i64 [0, %entry], [%next, %skip], [%next, %store]
  %n = phi i64 [0, %entry], [%n, %skip], [%added, %store]
  %more = icmp ult i64 %i, %length
  br i1 %more, label %read, label %lookup
read:
  %p = getelementptr i8, ptr %name, i64 %i
  %c = load i8, ptr %p
  %next = add i64 %i, 1
  %space = icmp eq i8 %c, 32
  %dash = icmp eq i8 %c, 45
  %underscore = icmp eq i8 %c, 95
  %skip0 = or i1 %space, %dash
  %ignored = or i1 %skip0, %underscore
  br i1 %ignored, label %skip, label %check
skip:
  br label %normalize
check:
  %ascii = icmp ult i8 %c, -128
  %room = icmp ult i64 %n, 63
  %valid = and i1 %ascii, %room
  br i1 %valid, label %store, label %missing
store:
  %upperlo = icmp uge i8 %c, 65
  %upperhi = icmp ule i8 %c, 90
  %upper = and i1 %upperlo, %upperhi
  %lower = add i8 %c, 32
  %fold = select i1 %upper, i8 %lower, i8 %c
  %bp = getelementptr i8, ptr %buffer, i64 %n
  store i8 %fold, ptr %bp
  %added = add i64 %n, 1
  br label %normalize
lookup:
  %total32 = load i32, ptr @rx_unicode_name_count
  %total = zext i32 %total32 to i64
  br label %names
names:
  %j = phi i64 [0, %lookup], [%jn, %advance]
  %available = icmp ult i64 %j, %total
  br i1 %available, label %row, label %missing
row:
  %record = getelementptr %UN, ptr @rx_unicode_names, i64 %j
  %lp = getelementptr %UN, ptr %record, i32 0, i32 1
  %len = load i64, ptr %lp
  %same = icmp eq i64 %len, %n
  br i1 %same, label %comparebegin, label %advance
comparebegin:
  %bytes = load ptr, ptr %record
  br label %compare
compare:
  %k = phi i64 [0, %comparebegin], [%kn, %equal]
  %end = icmp eq i64 %k, %n
  br i1 %end, label %found, label %byte
byte:
  %ap = getelementptr i8, ptr %bytes, i64 %k
  %bp2 = getelementptr i8, ptr %buffer, i64 %k
  %a = load i8, ptr %ap
  %b = load i8, ptr %bp2
  %eq = icmp eq i8 %a, %b
  br i1 %eq, label %equal, label %advance
equal:
  %kn = add i64 %k, 1
  br label %compare
advance:
  %jn = add i64 %j, 1
  br label %names
found:
  %idp = getelementptr %UN, ptr %record, i32 0, i32 2
  %id = load i32, ptr %idp
  ret i32 %id
missing:
  ret i32 -1
}

define i1 @rx_unicode_has(i32 %property, i32 %codepoint) {
entry:
  %count = load i32, ptr @rx_unicode_range_count
  %valid = icmp ult i32 %property, %count
  br i1 %valid, label %table, label %no
table:
  %id = zext i32 %property to i64
  %record = getelementptr %UR, ptr @rx_unicode_ranges, i64 %id
  %ranges = load ptr, ptr %record
  %np = getelementptr %UR, ptr %record, i32 0, i32 1
  %n = load i64, ptr %np
  br label %search
search:
  %lo = phi i64 [0, %table], [%midnext, %right], [%lo, %left]
  %hi = phi i64 [%n, %table], [%hi, %right], [%mid, %left]
  %more = icmp ult i64 %lo, %hi
  br i1 %more, label %probe, label %no
probe:
  %sum = add i64 %lo, %hi
  %mid = lshr i64 %sum, 1
  %r = getelementptr {i32, i32}, ptr %ranges, i64 %mid
  %start = load i32, ptr %r
  %ep = getelementptr i32, ptr %r, i64 1
  %end = load i32, ptr %ep
  %below = icmp ult i32 %codepoint, %start
  br i1 %below, label %left, label %endcheck
endcheck:
  %above = icmp ugt i32 %codepoint, %end
  br i1 %above, label %right, label %yes
right:
  %midnext = add i64 %mid, 1
  br label %search
left:
  br label %search
yes:
  ret i1 true
no:
  ret i1 false
}

define internal ptr @rx_unicode_foldrow(i32 %codepoint) {
entry:
  %count = load i32, ptr @rx_unicode_fold_count
  %n = zext i32 %count to i64
  br label %search
search:
  %lo = phi i64 [0, %entry], [%next, %right], [%lo, %left]
  %hi = phi i64 [%n, %entry], [%hi, %right], [%mid, %left]
  %more = icmp ult i64 %lo, %hi
  br i1 %more, label %probe, label %missing
probe:
  %sum = add i64 %lo, %hi
  %mid = lshr i64 %sum, 1
  %row = getelementptr %UF, ptr @rx_unicode_folds, i64 %mid
  %key = load i32, ptr %row
  %eq = icmp eq i32 %key, %codepoint
  br i1 %eq, label %found, label %direction
direction:
  %less = icmp ult i32 %key, %codepoint
  br i1 %less, label %right, label %left
right:
  %next = add i64 %mid, 1
  br label %search
left:
  br label %search
found:
  ret ptr %row
missing:
  ret ptr null
}

define i32 @rx_unicode_expand(i32 %codepoint, ptr %out) {
entry:
  %row = call ptr @rx_unicode_foldrow(i32 %codepoint)
  %found = icmp ne ptr %row, null
  br i1 %found, label %mapped, label %identity
identity:
  store i32 %codepoint, ptr %out
  ret i32 1
mapped:
  %np = getelementptr %UF, ptr %row, i32 0, i32 1
  %n = load i32, ptr %np
  br label %copy
copy:
  %i = phi i32 [0, %mapped], [%next, %body]
  %more = icmp ult i32 %i, %n
  br i1 %more, label %body, label %done
body:
  %srcindex = add i32 %i, 2
  %sp = getelementptr i32, ptr %row, i32 %srcindex
  %dp = getelementptr i32, ptr %out, i32 %i
  %value = load i32, ptr %sp
  store i32 %value, ptr %dp
  %next = add i32 %i, 1
  br label %copy
done:
  ret i32 %n
}

define i32 @rx_unicode_fold(i32 %codepoint) {
entry:
  %row = call ptr @rx_unicode_foldrow(i32 %codepoint)
  %found = icmp ne ptr %row, null
  br i1 %found, label %mapped, label %identity
mapped:
  %np = getelementptr %UF, ptr %row, i32 0, i32 1
  %n = load i32, ptr %np
  %single = icmp eq i32 %n, 1
  br i1 %single, label %simple, label %canonicalbegin
simple:
  %vp = getelementptr %UF, ptr %row, i32 0, i32 2
  %value = load i32, ptr %vp
  ret i32 %value
canonicalbegin:
  %count = load i32, ptr @rx_unicode_fold_count
  %total = zext i32 %count to i64
  br label %canonical
canonical:
  %i = phi i64 [0, %canonicalbegin], [%next, %advance]
  %more = icmp ult i64 %i, %total
  br i1 %more, label %check, label %identity
check:
  %candidate = getelementptr %UF, ptr @rx_unicode_folds, i64 %i
  %cnp = getelementptr %UF, ptr %candidate, i32 0, i32 1
  %cn = load i32, ptr %cnp
  %samewidth = icmp eq i32 %cn, %n
  br i1 %samewidth, label %sequence, label %advance
sequence:
  %k = phi i32 [0, %check], [%kn, %equal]
  %finished = icmp eq i32 %k, %n
  br i1 %finished, label %selected, label %element
element:
  %index = add i32 %k, 2
  %ap = getelementptr i32, ptr %row, i32 %index
  %bp = getelementptr i32, ptr %candidate, i32 %index
  %a = load i32, ptr %ap
  %b = load i32, ptr %bp
  %same = icmp eq i32 %a, %b
  br i1 %same, label %equal, label %advance
equal:
  %kn = add i32 %k, 1
  br label %sequence
advance:
  %next = add i64 %i, 1
  br label %canonical
selected:
  %key = load i32, ptr %candidate
  ret i32 %key
identity:
  ret i32 %codepoint
}

define i1 @rx_unicode_case_range(i32 %codepoint, i32 %start, i32 %end) {
entry:
  %fold = call i32 @rx_unicode_fold(i32 %codepoint)
  %lower = icmp uge i32 %codepoint, %start
  %upper = icmp ule i32 %codepoint, %end
  %direct = and i1 %lower, %upper
  %fl = icmp uge i32 %fold, %start
  %fu = icmp ule i32 %fold, %end
  %mapped = and i1 %fl, %fu
  %simple = or i1 %direct, %mapped
  br i1 %simple, label %yes, label %begin
begin:
  %count = load i32, ptr @rx_unicode_fold_count
  %n = zext i32 %count to i64
  br label %loop
loop:
  %i = phi i64 [0, %begin], [%next, %advance]
  %more = icmp ult i64 %i, %n
  br i1 %more, label %row, label %no
row:
  %p = getelementptr %UF, ptr @rx_unicode_folds, i64 %i
  %key = load i32, ptr %p
  %below = icmp ult i32 %key, %start
  %above = icmp ugt i32 %key, %end
  br i1 %above, label %no, label %eligible
eligible:
  br i1 %below, label %advance, label %compare
compare:
  %candidate = call i32 @rx_unicode_fold(i32 %key)
  %same = icmp eq i32 %candidate, %fold
  br i1 %same, label %yes, label %advance
advance:
  %next = add i64 %i, 1
  br label %loop
yes:
  ret i1 true
no:
  ret i1 false
}
