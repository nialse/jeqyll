%V = type { i32, i32, double, i64, i64, ptr, ptr }
%Buffer = type { ptr, i64, i64 }
%Decimal = type { i32, i32, i64, i64, ptr }
%RoundInterval = type { ptr, ptr, i64, i64, i64, i64, i1 }
%ArenaBlock = type { ptr, i64, ptr, i64 }
%ArenaMark = type { ptr, ptr, i64 }

@j_error = global ptr null
@j_indent = global i32 2
@j_parse_error_offset = global i64 0
@j_parse_error_eof = global i1 false
@j_parse_error_message = global ptr null
@j_parse_error_path = global ptr null
@parse_depth = internal global i32 0
@parse_stream_mode = internal global i1 false
@parse_path = internal global ptr null
@compare_depth = internal global i32 0
@merge_depth = internal global i32 0
@compare_message = internal global ptr @error_compare_depth
@arena_cursor = internal global ptr null
@arena_left = internal global i64 0
@arena_block = internal global ptr null
@permanent_cursor = internal global ptr null
@permanent_left = internal global i64 0
@permanent_block = internal global ptr null
@gc_active = internal global i1 false
@gc_old_state = internal global %ArenaMark zeroinitializer
@gc_base_mark = internal global %ArenaMark zeroinitializer
@gc_table = internal global ptr null
@gc_capacity = internal global i64 0
@gc_count = internal global i64 0
@gc_min_addr = internal global i64 -1
@gc_max_addr = internal global i64 0
@gc_ranges = internal global [128 x [2 x i64]] zeroinitializer
@gc_range_count = internal global i64 0
@gc_range_overflow = internal global i1 false
@j_gc_pressure = global i64 0
@j_gc_threshold = global i64 8388608
@value_null = internal global %V zeroinitializer
@value_false = internal global %V { i32 1, i32 0, double 0.0, i64 0, i64 0, ptr null, ptr null }
@value_true = internal global %V { i32 2, i32 0, double 0.0, i64 0, i64 0, ptr null, ptr null }
@text_null = private constant [5 x i8] c"null\00"
@text_false = private constant [6 x i8] c"false\00"
@text_true = private constant [5 x i8] c"true\00"
@text_empty = private constant [1 x i8] zeroinitializer
@text_digit_zero = private constant [2 x i8] c"0\00"
@text_nan = private constant [4 x i8] c"NaN\00"
@text_nan_lower = private constant [4 x i8] c"nan\00"
@text_infinity = private constant [9 x i8] c"Infinity\00"
@text_infinity_lower = private constant [9 x i8] c"infinity\00"
@hex_digits = private constant [17 x i8] c"0123456789abcdef\00"
@error_parse = private constant [21 x i8] c"Invalid JSON input\00\00\00"
@error_number = private constant [24 x i8] c"Invalid numeric literal\00"
@error_literal = private constant [16 x i8] c"Invalid literal\00"
@error_index = private constant [30 x i8] c"Cannot index value with key\00\00\00"
@error_key = private constant [35 x i8] c"Cannot use non-string object key\00\00\00"
@error_binary = private constant [32 x i8] c"Incompatible types for operator\00"
@error_zero = private constant [17 x i8] c"division by zero\00"
@error_memory = private constant [20 x i8] c"jeqy: out of memory\0A"
@error_checkpoint = private constant [25 x i8] c"Invalid arena checkpoint\00"
@error_collection = private constant [34 x i8] c"Invalid copying collection state\00\00"
@kind_number = private constant [7 x i8] c"number\00"
@kind_boolean = private constant [8 x i8] c"boolean\00"
@kind_string = private constant [7 x i8] c"string\00"
@kind_array = private constant [6 x i8] c"array\00"
@kind_object = private constant [7 x i8] c"object\00"
@text_openparen = private constant [3 x i8] c" (\00"
@text_and = private constant [6 x i8] c" and \00"
@text_dots = private constant [4 x i8] c"...\00"
@text_cannot_index = private constant [14 x i8] c"Cannot index \00"
@text_with = private constant [7 x i8] c" with \00"
@error_add = private constant [16 x i8] c"cannot be added\00"
@error_subtract = private constant [21 x i8] c"cannot be subtracted\00"
@error_multiply = private constant [21 x i8] c"cannot be multiplied\00"
@error_divide = private constant [18 x i8] c"cannot be divided\00"
@error_remainder = private constant [31 x i8] c"cannot be divided (remainder)\00\00"
@error_dividezero = private constant [46 x i8] c"cannot be divided because the divisor is zero\00"
@error_remainderzero = private constant [58 x i8] c"cannot be divided (remainder) because the divisor is zero\00"
@error_negate = private constant [18 x i8] c"cannot be negated\00"
@error_repeat = private constant [30 x i8] c"Repeat string result too long\00"
@error_parse_depth = private constant [33 x i8] c"Exceeds depth limit for parsing\00\00"
@error_compare_depth = private constant [21 x i8] c"Comparison too deep\00\00"
@error_equal_depth = private constant [25 x i8] c"Equality check too deep\00\00"
@error_merge_depth = private constant [23 x i8] c"Object merge too deep\00\00"
@text_print_depth = private constant [22 x i8] c"\22<skipped: too deep>\22\00"
@error_string_literal = private constant [46 x i8] c"Invalid string literal; expected \22, but got '\00"
@text_at_eof = private constant [8 x i8] c" at EOF\00"
@text_at_line = private constant [10 x i8] c" at line \00"
@text_column = private constant [10 x i8] c", column \00"
@text_while_parsing = private constant [18 x i8] c" (while parsing '\00"
@text_parse_end = private constant [3 x i8] c"')\00"
@error_unfinished_string = private constant [19 x i8] c"Unfinished string\00\00"
@error_unfinished_json = private constant [22 x i8] c"Unfinished JSON term\00\00"
@error_string_control = private constant [78 x i8] c"Invalid string: control characters from U+0000 through U+001F must be escaped\00"
@error_escape = private constant [16 x i8] c"Invalid escape\00\00"
@error_unicode_escape = private constant [22 x i8] c"Invalid \5CuXXXX escape\00"
@error_unicode_hex = private constant [36 x i8] c"Invalid characters in \5CuXXXX escape\00"
@error_unicode_pair = private constant [44 x i8] c"Invalid \5CuXXXX\5CuXXXX surrogate pair escape\00\00"
@error_unmatched_array = private constant [15 x i8] c"Unmatched ']'\00\00"
@error_unmatched_object = private constant [15 x i8] c"Unmatched '}'\00\00"
@error_array_element = private constant [32 x i8] c"Expected another array element\00\00"
@error_object_pair = private constant [33 x i8] c"Expected another key-value pair\00\00"
@error_separator = private constant [35 x i8] c"Expected separator between values\00\00"
@error_object_parts = private constant [41 x i8] c"Objects must consist of key:value pairs\00\00"
@error_object_keys = private constant [29 x i8] c"Object keys must be strings\00\00"
@error_stream_object_object = private constant [39 x i8] c"Expected string key after '{', not '{'\00"
@error_stream_object_array = private constant [39 x i8] c"Expected string key after '{', not '['\00"
@error_stream_comma_object = private constant [49 x i8] c"Expected string key after ',' in object, not '{'\00"
@error_stream_comma_array = private constant [49 x i8] c"Expected string key after ',' in object, not '['\00"
@error_stream_top_array = private constant [31 x i8] c"Unmatched ']' at the top-level\00"
@error_stream_top_object = private constant [31 x i8] c"Unmatched '}' at the top-level\00"
@error_stream_middle_array = private constant [41 x i8] c"Unmatched ']' in the middle of an object\00"
@error_stream_middle_object = private constant [40 x i8] c"Unmatched '}' in the middle of an array\00"
@error_stream_missing_value = private constant [32 x i8] c"Missing value in key:value pair\00"

declare i64 @mmap(i64, i64, i32, i32, i32, i64)
declare i32 @munmap(i64, i64)
declare i64 @write(i32, ptr, i64)
declare void @_exit(i32) noreturn
declare double @llvm.trunc.f64(double)
declare double @llvm.fabs.f64(double)
declare ptr @j_split(ptr, ptr)

define ptr @j_alloc(i64 %bytes) {
entry:
  %overflow = icmp ugt i64 %bytes, 9223372036854770000
  br i1 %overflow, label %failure, label %sizecheck
sizecheck:
  %plus = add i64 %bytes, 15
  %aligned = and i64 %plus, -16
  %empty = icmp eq i64 %aligned, 0
  %size = select i1 %empty, i64 16, i64 %aligned
  %pressure = load i64, ptr @j_gc_pressure
  %newpressure = add i64 %pressure, %size
  store i64 %newpressure, ptr @j_gc_pressure
  %left = load i64, ptr @arena_left
  %enough = icmp ule i64 %size, %left
  br i1 %enough, label %allocate, label %map
map:
  %needed = add i64 %size, 32
  %large = icmp ugt i64 %needed, 16777216
  %pageplus = add i64 %needed, 4095
  %pages = and i64 %pageplus, -4096
  %mapsize = select i1 %large, i64 %pages, i64 16777216
  %address = call i64 @mmap(i64 0, i64 %mapsize, i32 3, i32 34, i32 -1, i64 0)
  %bad = icmp slt i64 %address, 0
  br i1 %bad, label %failure, label %mapped
failure:
  %ignored = call i64 @write(i32 2, ptr @error_memory, i64 20)
  call void @_exit(i32 2)
  unreachable
mapped:
  %base = inttoptr i64 %address to ptr
  %previous = load ptr, ptr @arena_block
  %sizep = getelementptr %ArenaBlock, ptr %base, i32 0, i32 1
  %usedp = getelementptr %ArenaBlock, ptr %base, i32 0, i32 2
  %payload = getelementptr i8, ptr %base, i64 32
  %usable = sub i64 %mapsize, 32
  store ptr %previous, ptr %base
  store i64 %mapsize, ptr %sizep
  store ptr %payload, ptr %usedp
  store ptr %base, ptr @arena_block
  store ptr %payload, ptr @arena_cursor
  store i64 %usable, ptr @arena_left
  br label %allocate
allocate:
  %cursor = load ptr, ptr @arena_cursor
  %available = load i64, ptr @arena_left
  %next = getelementptr i8, ptr %cursor, i64 %size
  %remain = sub i64 %available, %size
  store ptr %next, ptr @arena_cursor
  store i64 %remain, ptr @arena_left
  %block = load ptr, ptr @arena_block
  %lastused = getelementptr %ArenaBlock, ptr %block, i32 0, i32 2
  store ptr %next, ptr %lastused
  ret ptr %cursor
}

define ptr @j_alloc_permanent(i64 %bytes) {
entry:
  %transientblock = load ptr, ptr @arena_block
  %transientcursor = load ptr, ptr @arena_cursor
  %transientleft = load i64, ptr @arena_left
  %block = load ptr, ptr @permanent_block
  %cursor = load ptr, ptr @permanent_cursor
  %left = load i64, ptr @permanent_left
  store ptr %block, ptr @arena_block
  store ptr %cursor, ptr @arena_cursor
  store i64 %left, ptr @arena_left
  %value = call ptr @j_alloc(i64 %bytes)
  %newblock = load ptr, ptr @arena_block
  %newcursor = load ptr, ptr @arena_cursor
  %newleft = load i64, ptr @arena_left
  store ptr %newblock, ptr @permanent_block
  store ptr %newcursor, ptr @permanent_cursor
  store i64 %newleft, ptr @permanent_left
  store ptr %transientblock, ptr @arena_block
  store ptr %transientcursor, ptr @arena_cursor
  store i64 %transientleft, ptr @arena_left
  ret ptr %value
}

; Marks are caller-owned 24-byte records, normally on the stack. A rewind
; invalidates every allocation made after its mark. It is only valid between
; complete runtime operations, with no suspended state retaining those values.
define void @j_arena_mark(ptr %mark) {
entry:
  %cursorp = getelementptr %ArenaMark, ptr %mark, i32 0, i32 1
  %remainingp = getelementptr %ArenaMark, ptr %mark, i32 0, i32 2
  %block = load ptr, ptr @arena_block
  %cursor = load ptr, ptr @arena_cursor
  %remaining = load i64, ptr @arena_left
  store ptr %block, ptr %mark
  store ptr %cursor, ptr %cursorp
  store i64 %remaining, ptr %remainingp
  ret void
}

define void @j_arena_rewind(ptr %mark) {
entry:
  %cursorp = getelementptr %ArenaMark, ptr %mark, i32 0, i32 1
  %remainingp = getelementptr %ArenaMark, ptr %mark, i32 0, i32 2
  %target = load ptr, ptr %mark
  %cursor = load ptr, ptr %cursorp
  %remaining = load i64, ptr %remainingp
  %head = load ptr, ptr @arena_block
  br label %validate
validate:
  %checking = phi ptr [ %head, %entry ], [ %checkprevious, %walk ]
  %found = icmp eq ptr %checking, %target
  br i1 %found, label %validatecursor, label %checkend
checkend:
  %absent = icmp eq ptr %checking, null
  br i1 %absent, label %invalid, label %walk
walk:
  %checkprevious = load ptr, ptr %checking
  br label %validate
validatecursor:
  %empty = icmp eq ptr %target, null
  br i1 %empty, label %validateempty, label %checkrange
validateempty:
  %nullcursor = icmp eq ptr %cursor, null
  %noremaining = icmp eq i64 %remaining, 0
  %validempty = and i1 %nullcursor, %noremaining
  br i1 %validempty, label %release, label %invalid
checkrange:
  %sizep = getelementptr %ArenaBlock, ptr %target, i32 0, i32 1
  %usedp = getelementptr %ArenaBlock, ptr %target, i32 0, i32 2
  %mapsize = load i64, ptr %sizep
  %used = load ptr, ptr %usedp
  %payload = getelementptr i8, ptr %target, i64 32
  %end = getelementptr i8, ptr %target, i64 %mapsize
  %afterstart = icmp uge ptr %cursor, %payload
  %beforeused = icmp ule ptr %cursor, %used
  %endaddress = ptrtoint ptr %end to i64
  %cursoraddress = ptrtoint ptr %cursor to i64
  %expectedremaining = sub i64 %endaddress, %cursoraddress
  %correctremaining = icmp eq i64 %remaining, %expectedremaining
  %within = and i1 %afterstart, %beforeused
  %valid = and i1 %within, %correctremaining
  br i1 %valid, label %release, label %invalid
release:
  br label %freeloop
freeloop:
  %block = phi ptr [ %head, %release ], [ %previous, %unmapped ]
  %atmark = icmp eq ptr %block, %target
  br i1 %atmark, label %clearcheck, label %unmap
unmap:
  %previous = load ptr, ptr %block
  %lengthp = getelementptr %ArenaBlock, ptr %block, i32 0, i32 1
  %length = load i64, ptr %lengthp
  %address = ptrtoint ptr %block to i64
  %result = call i32 @munmap(i64 %address, i64 %length)
  %failed = icmp slt i32 %result, 0
  br i1 %failed, label %fatal, label %unmapped
unmapped:
  br label %freeloop
clearcheck:
  br i1 %empty, label %restore, label %clear
clear:
  %usedfield = getelementptr %ArenaBlock, ptr %target, i32 0, i32 2
  %oldused = load ptr, ptr %usedfield
  %usedaddress = ptrtoint ptr %oldused to i64
  %markedaddress = ptrtoint ptr %cursor to i64
  %discarded = sub i64 %usedaddress, %markedaddress
  %cleared = call ptr @memset(ptr %cursor, i32 0, i64 %discarded)
  store ptr %cursor, ptr %usedfield
  br label %restore
restore:
  store ptr %target, ptr @arena_block
  store ptr %cursor, ptr @arena_cursor
  store i64 %remaining, ptr @arena_left
  store ptr null, ptr @j_parse_error_path
  store ptr null, ptr @j_parse_error_message
  store i64 0, ptr @j_parse_error_offset
  store i1 false, ptr @j_parse_error_eof
  ret void
invalid:
  call void @j_fail(ptr @error_checkpoint)
  ret void
fatal:
  %written = call i64 @write(i32 2, ptr @error_memory, i64 20)
  call void @_exit(i32 2)
  unreachable
}

; A copying collection evacuates only storage newer than the supplied mark.
; The caller's typed visitor must rewrite its roots before j_gc_end releases
; the old storage. Permanent allocations and immutable pre-mark graphs stay.
define void @j_gc_begin(ptr %mark) {
entry:
  %active = load i1, ptr @gc_active
  br i1 %active, label %error, label %begin
begin:
  call void @j_arena_mark(ptr @gc_old_state)
  call void @j_copy(ptr @gc_base_mark, ptr %mark, i64 24)
  store i64 0, ptr @gc_range_count
  store i1 false, ptr @gc_range_overflow
  %head = load ptr, ptr @gc_old_state
  %base = load ptr, ptr @gc_base_mark
  %cursorp = getelementptr %ArenaMark, ptr @gc_base_mark, i32 0, i32 1
  %markedcursor = load ptr, ptr %cursorp
  br label %boundloop
boundloop:
  %b = phi ptr [ %head, %begin ], [ %bprev, %boundnext ]
  %min = phi i64 [ -1, %begin ], [ %nextmin, %boundnext ]
  %max = phi i64 [ 0, %begin ], [ %nextmax, %boundnext ]
  %bend = icmp eq ptr %b, null
  br i1 %bend, label %bounddone, label %boundbody
boundbody:
  %atmark = icmp eq ptr %b, %base
  %payload = getelementptr i8, ptr %b, i64 32
  %bstart = select i1 %atmark, ptr %markedcursor, ptr %payload
  %usedp = getelementptr %ArenaBlock, ptr %b, i32 0, i32 2
  %bused = load ptr, ptr %usedp
  %nonempty = icmp ult ptr %bstart, %bused
  br i1 %nonempty, label %recordrange, label %boundstep
recordrange:
  %startint = ptrtoint ptr %bstart to i64
  %usedint = ptrtoint ptr %bused to i64
  %lessmin = icmp ult i64 %startint, %min
  %candmin = select i1 %lessmin, i64 %startint, i64 %min
  %moremax = icmp ugt i64 %usedint, %max
  %candmax = select i1 %moremax, i64 %usedint, i64 %max
  %rcount = load i64, ptr @gc_range_count
  %hasroom = icmp ult i64 %rcount, 128
  br i1 %hasroom, label %insertloop, label %markoverflow
insertloop:
  %ins = phi i64 [ %rcount, %recordrange ], [ %insprev, %insertshift ]
  %atfront = icmp eq i64 %ins, 0
  br i1 %atfront, label %insertput, label %insertcmp
insertcmp:
  %insprev = sub i64 %ins, 1
  %prevsp = getelementptr [128 x [2 x i64]], ptr @gc_ranges, i64 0, i64 %insprev, i64 0
  %prevs = load i64, ptr %prevsp
  %prevgreater = icmp ugt i64 %prevs, %startint
  br i1 %prevgreater, label %insertshift, label %insertput
insertshift:
  %prevep = getelementptr [128 x [2 x i64]], ptr @gc_ranges, i64 0, i64 %insprev, i64 1
  %preve = load i64, ptr %prevep
  %dstsp = getelementptr [128 x [2 x i64]], ptr @gc_ranges, i64 0, i64 %ins, i64 0
  %dstep = getelementptr [128 x [2 x i64]], ptr @gc_ranges, i64 0, i64 %ins, i64 1
  store i64 %prevs, ptr %dstsp
  store i64 %preve, ptr %dstep
  br label %insertloop
insertput:
  %putsp = getelementptr [128 x [2 x i64]], ptr @gc_ranges, i64 0, i64 %ins, i64 0
  %putep = getelementptr [128 x [2 x i64]], ptr @gc_ranges, i64 0, i64 %ins, i64 1
  store i64 %startint, ptr %putsp
  store i64 %usedint, ptr %putep
  %newrcount = add i64 %rcount, 1
  store i64 %newrcount, ptr @gc_range_count
  br label %boundstep
markoverflow:
  store i1 true, ptr @gc_range_overflow
  br label %boundstep
boundstep:
  %nextmin = phi i64 [ %min, %boundbody ], [ %candmin, %insertput ], [ %candmin, %markoverflow ]
  %nextmax = phi i64 [ %max, %boundbody ], [ %candmax, %insertput ], [ %candmax, %markoverflow ]
  br i1 %atmark, label %bounddone, label %boundnext
boundnext:
  %bprev = load ptr, ptr %b
  br label %boundloop
bounddone:
  %finalmin = phi i64 [ %min, %boundloop ], [ %nextmin, %boundstep ]
  %finalmax = phi i64 [ %max, %boundloop ], [ %nextmax, %boundstep ]
  store i64 %finalmin, ptr @gc_min_addr
  store i64 %finalmax, ptr @gc_max_addr
  store i64 0, ptr @j_gc_pressure
  store ptr null, ptr @arena_block
  store ptr null, ptr @arena_cursor
  store i64 0, ptr @arena_left
  store ptr null, ptr @gc_table
  store i64 0, ptr @gc_capacity
  store i64 0, ptr @gc_count
  store i1 true, ptr @gc_active
  ret void
error:
  call void @j_fail(ptr @error_collection)
  ret void
}

define internal i1 @gc_movable(ptr %value) {
entry:
  %addr = ptrtoint ptr %value to i64
  %min = load i64, ptr @gc_min_addr
  %max = load i64, ptr @gc_max_addr
  %gemin = icmp uge i64 %addr, %min
  %ltmax = icmp ult i64 %addr, %max
  %inbox = and i1 %gemin, %ltmax
  br i1 %inbox, label %checkoverflow, label %no
checkoverflow:
  %overflow = load i1, ptr @gc_range_overflow
  br i1 %overflow, label %slowwalk, label %fastcheck
fastcheck:
  %rcount = load i64, ptr @gc_range_count
  %single = icmp eq i64 %rcount, 1
  br i1 %single, label %yes, label %bsearch
bsearch:
  %lo = phi i64 [ 0, %fastcheck ], [ %lo_next, %bsearch_right ], [ %lo, %bsearch_left ]
  %hi = phi i64 [ %rcount, %fastcheck ], [ %hi, %bsearch_right ], [ %mid, %bsearch_left ]
  %hasrange = icmp ult i64 %lo, %hi
  br i1 %hasrange, label %bsearch_body, label %no
bsearch_body:
  %sum = add i64 %lo, %hi
  %mid = lshr i64 %sum, 1
  %sp = getelementptr [128 x [2 x i64]], ptr @gc_ranges, i64 0, i64 %mid, i64 0
  %rstart = load i64, ptr %sp
  %before = icmp ult i64 %addr, %rstart
  br i1 %before, label %bsearch_left, label %bsearch_endcheck
bsearch_left:
  br label %bsearch
bsearch_endcheck:
  %ep = getelementptr [128 x [2 x i64]], ptr @gc_ranges, i64 0, i64 %mid, i64 1
  %rend = load i64, ptr %ep
  %inside = icmp ult i64 %addr, %rend
  br i1 %inside, label %yes, label %bsearch_right
bsearch_right:
  %lo_next = add i64 %mid, 1
  br label %bsearch
slowwalk:
  %head = load ptr, ptr @gc_old_state
  %mark = load ptr, ptr @gc_base_mark
  %cursorp = getelementptr %ArenaMark, ptr @gc_base_mark, i32 0, i32 1
  %markedcursor = load ptr, ptr %cursorp
  br label %loop
loop:
  %block = phi ptr [ %head, %slowwalk ], [ %previous, %advance ]
  %end = icmp eq ptr %block, null
  br i1 %end, label %no, label %range
range:
  %atmark = icmp eq ptr %block, %mark
  %payload = getelementptr i8, ptr %block, i64 32
  %begin = select i1 %atmark, ptr %markedcursor, ptr %payload
  %usedp = getelementptr %ArenaBlock, ptr %block, i32 0, i32 2
  %used = load ptr, ptr %usedp
  %afterbegin = icmp uge ptr %value, %begin
  %beforeend = icmp ult ptr %value, %used
  %inblock = and i1 %afterbegin, %beforeend
  br i1 %inblock, label %yes, label %nextcheck
nextcheck:
  br i1 %atmark, label %no, label %advance
advance:
  %previous = load ptr, ptr %block
  br label %loop
yes:
  ret i1 true
no:
  ret i1 false
}

define internal ptr @gc_slot(ptr %table, i64 %capacity, ptr %key) {
entry:
  %address = ptrtoint ptr %key to i64
  %aligned = lshr i64 %address, 4
  %mixed = mul i64 %aligned, -7046029254386353131
  %high = lshr i64 %mixed, 32
  %hash = xor i64 %mixed, %high
  %mask = sub i64 %capacity, 1
  %initial = and i64 %hash, %mask
  br label %probe
probe:
  %index = phi i64 [ %initial, %entry ], [ %next, %advance ]
  %slotindex = shl i64 %index, 1
  %slot = getelementptr ptr, ptr %table, i64 %slotindex
  %stored = load ptr, ptr %slot
  %empty = icmp eq ptr %stored, null
  %same = icmp eq ptr %stored, %key
  %found = or i1 %empty, %same
  br i1 %found, label %done, label %advance
advance:
  %increment = add i64 %index, 1
  %next = and i64 %increment, %mask
  br label %probe
done:
  ret ptr %slot
}

define internal void @gc_grow() {
entry:
  %old = load ptr, ptr @gc_table
  %oldcapacity = load i64, ptr @gc_capacity
  %initial = icmp eq i64 %oldcapacity, 0
  %twice = shl i64 %oldcapacity, 1
  %capacity = select i1 %initial, i64 1024, i64 %twice
  %bytes = mul i64 %capacity, 16
  %table = call ptr @j_alloc(i64 %bytes)
  br label %loop
loop:
  %i = phi i64 [ 0, %entry ], [ %next, %advance ]
  %done = icmp eq i64 %i, %oldcapacity
  br i1 %done, label %finish, label %body
body:
  %index = shl i64 %i, 1
  %slot = getelementptr ptr, ptr %old, i64 %index
  %key = load ptr, ptr %slot
  %occupied = icmp ne ptr %key, null
  br i1 %occupied, label %rehash, label %advance
rehash:
  %valuep = getelementptr ptr, ptr %slot, i64 1
  %value = load ptr, ptr %valuep
  %newslot = call ptr @gc_slot(ptr %table, i64 %capacity, ptr %key)
  %newvaluep = getelementptr ptr, ptr %newslot, i64 1
  store ptr %key, ptr %newslot
  store ptr %value, ptr %newvaluep
  br label %advance
advance:
  %next = add i64 %i, 1
  br label %loop
finish:
  store ptr %table, ptr @gc_table
  store i64 %capacity, ptr @gc_capacity
  ret void
}

define ptr @j_gc_copy(ptr %old, i64 %bytes, ptr %isnew) {
entry:
  store i1 false, ptr %isnew
  %active = load i1, ptr @gc_active
  br i1 %active, label %classify, label %error
classify:
  %movable = call i1 @gc_movable(ptr %old)
  br i1 %movable, label %capacitycheck, label %unchanged
capacitycheck:
  %capacity = load i64, ptr @gc_capacity
  %count = load i64, ptr @gc_count
  %nextcount = add i64 %count, 1
  %half = lshr i64 %capacity, 1
  %grow = icmp ugt i64 %nextcount, %half
  br i1 %grow, label %growth, label %lookup
growth:
  call void @gc_grow()
  br label %lookup
lookup:
  %table = load ptr, ptr @gc_table
  %currentcapacity = load i64, ptr @gc_capacity
  %slot = call ptr @gc_slot(ptr %table, i64 %currentcapacity, ptr %old)
  %key = load ptr, ptr %slot
  %valuep = getelementptr ptr, ptr %slot, i64 1
  %known = icmp ne ptr %key, null
  br i1 %known, label %forwarded, label %copy
forwarded:
  %forward = load ptr, ptr %valuep
  ret ptr %forward
copy:
  %new = call ptr @j_alloc(i64 %bytes)
  call void @j_copy(ptr %new, ptr %old, i64 %bytes)
  store ptr %old, ptr %slot
  store ptr %new, ptr %valuep
  store i64 %nextcount, ptr @gc_count
  store i1 true, ptr %isnew
  ret ptr %new
unchanged:
  ret ptr %old
error:
  call void @j_fail(ptr @error_collection)
  ret ptr %old
}

; Copy a %V header, moving single-allocation strings (data == old + 48) with
; their inline bytes in one j_gc_copy call.
define internal ptr @j_gc_obj(ptr %old, ptr %isnew) {
entry:
  %isnull = icmp eq ptr %old, null
  br i1 %isnull, label %plain, label %checktag
checktag:
  %tag = load i32, ptr %old
  %isstring = icmp eq i32 %tag, 4
  br i1 %isstring, label %string, label %plain
string:
  %dp = getelementptr %V, ptr %old, i32 0, i32 5
  %data = load ptr, ptr %dp
  %inlinep = getelementptr i8, ptr %old, i64 48
  %isinline = icmp eq ptr %data, %inlinep
  br i1 %isinline, label %sized, label %plain
sized:
  %lp = getelementptr %V, ptr %old, i32 0, i32 3
  %length = load i64, ptr %lp
  %total = add i64 %length, 49
  %copy = call ptr @j_gc_copy(ptr %old, i64 %total, ptr %isnew)
  ret ptr %copy
plain:
  %plaincopy = call ptr @j_gc_copy(ptr %old, i64 48, ptr %isnew)
  ret ptr %plaincopy
}

; This work queue handles arbitrary JSON graph depth without native recursion.
; Forwarding is installed before enqueueing, so shared and cyclic graphs are
; processed only once even when callers construct internal cyclic values.
define ptr @j_gc_value(ptr %value) {
entry:
  %isnew = alloca i1
  %root = call ptr @j_gc_obj(ptr %value, ptr %isnew)
  %fresh = load i1, ptr %isnew
  br i1 %fresh, label %begin, label %done
begin:
  %queue = call ptr @j_array()
  call void @j_push(ptr %queue, ptr %value)
  call void @j_push(ptr %queue, ptr %root)
  %queuelenp = getelementptr %V, ptr %queue, i32 0, i32 3
  br label %loop
loop:
  %i = phi i64 [ 0, %begin ], [ %next, %advance ]
  %queuelen = load i64, ptr %queuelenp
  %finished = icmp uge i64 %i, %queuelen
  br i1 %finished, label %done, label %body
body:
  %old = call ptr @j_at(ptr %queue, i64 %i)
  %newindex = add i64 %i, 1
  %new = call ptr @j_at(ptr %queue, i64 %newindex)
  %tag = load i32, ptr %old
  switch i32 %tag, label %advance [ i32 3, label %number i32 4, label %string i32 5, label %container i32 6, label %container ]
number:
  %oldliteralp = getelementptr %V, ptr %old, i32 0, i32 6
  %literal = load ptr, ptr %oldliteralp
  %hasliteral = icmp ne ptr %literal, null
  br i1 %hasliteral, label %copyliteral, label %advance
copyliteral:
  %literallen = call i64 @j_strlen(ptr %literal)
  %literalbytes = add i64 %literallen, 1
  %newliteral = call ptr @j_gc_copy(ptr %literal, i64 %literalbytes, ptr %isnew)
  %newliteralp = getelementptr %V, ptr %new, i32 0, i32 6
  store ptr %newliteral, ptr %newliteralp
  br label %advance
string:
  %stringlengthp = getelementptr %V, ptr %old, i32 0, i32 3
  %stringdatap = getelementptr %V, ptr %old, i32 0, i32 5
  %stringlength = load i64, ptr %stringlengthp
  %stringdata = load ptr, ptr %stringdatap
  %inlinep = getelementptr i8, ptr %old, i64 48
  %isinline = icmp eq ptr %stringdata, %inlinep
  br i1 %isinline, label %stringinline, label %stringsplit
stringinline:
  %inlinedata = getelementptr i8, ptr %new, i64 48
  br label %stringstore
stringsplit:
  %stringbytes = add i64 %stringlength, 1
  %newstringdata = call ptr @j_gc_copy(ptr %stringdata, i64 %stringbytes, ptr %isnew)
  br label %stringstore
stringstore:
  %finaldata = phi ptr [ %inlinedata, %stringinline ], [ %newstringdata, %stringsplit ]
  %newstringdatap = getelementptr %V, ptr %new, i32 0, i32 5
  store ptr %finaldata, ptr %newstringdatap
  br label %advance
container:
  %lengthp = getelementptr %V, ptr %old, i32 0, i32 3
  %capacityp = getelementptr %V, ptr %old, i32 0, i32 4
  %datap = getelementptr %V, ptr %old, i32 0, i32 5
  %length = load i64, ptr %lengthp
  %capacity = load i64, ptr %capacityp
  %data = load ptr, ptr %datap
  %object = icmp eq i32 %tag, 6
  %width = select i1 %object, i64 2, i64 1
  %slots = mul i64 %length, %width
  %allocatedslots = mul i64 %capacity, %width
  %bytes = mul i64 %allocatedslots, 8
  %newdata = call ptr @j_gc_copy(ptr %data, i64 %bytes, ptr %isnew)
  %newdatap = getelementptr %V, ptr %new, i32 0, i32 5
  store ptr %newdata, ptr %newdatap
  br label %children
children:
  %j = phi i64 [ 0, %container ], [ %nextchild, %childnext ]
  %lastchild = icmp eq i64 %j, %slots
  br i1 %lastchild, label %advance, label %child
child:
  %oldslot = getelementptr ptr, ptr %data, i64 %j
  %newslot = getelementptr ptr, ptr %newdata, i64 %j
  %oldchild = load ptr, ptr %oldslot
  %newchild = call ptr @j_gc_obj(ptr %oldchild, ptr %isnew)
  store ptr %newchild, ptr %newslot
  %childfresh = load i1, ptr %isnew
  br i1 %childfresh, label %enqueue, label %childnext
enqueue:
  call void @j_push(ptr %queue, ptr %oldchild)
  call void @j_push(ptr %queue, ptr %newchild)
  br label %childnext
childnext:
  %nextchild = add i64 %j, 1
  br label %children
advance:
  %next = add i64 %i, 2
  br label %loop
done:
  ret ptr %root
}

define void @j_gc_end(ptr %mark) {
entry:
  %active = load i1, ptr @gc_active
  br i1 %active, label %validate, label %error
validate:
  %markcursorp = getelementptr %ArenaMark, ptr %mark, i32 0, i32 1
  %markleftp = getelementptr %ArenaMark, ptr %mark, i32 0, i32 2
  %basecursorp = getelementptr %ArenaMark, ptr @gc_base_mark, i32 0, i32 1
  %baseleftp = getelementptr %ArenaMark, ptr @gc_base_mark, i32 0, i32 2
  %markblock = load ptr, ptr %mark
  %markcursor = load ptr, ptr %markcursorp
  %markleft = load i64, ptr %markleftp
  %baseblock = load ptr, ptr @gc_base_mark
  %basecursor = load ptr, ptr %basecursorp
  %baseleft = load i64, ptr %baseleftp
  %sameblock = icmp eq ptr %markblock, %baseblock
  %samecursor = icmp eq ptr %markcursor, %basecursor
  %sameleft = icmp eq i64 %markleft, %baseleft
  %sameplace = and i1 %sameblock, %samecursor
  %same = and i1 %sameplace, %sameleft
  br i1 %same, label %prepare, label %error
prepare:
  %newhead = load ptr, ptr @arena_block
  %newcursor = load ptr, ptr @arena_cursor
  %newleft = load i64, ptr @arena_left
  %oldcursorp = getelementptr %ArenaMark, ptr @gc_old_state, i32 0, i32 1
  %oldleftp = getelementptr %ArenaMark, ptr @gc_old_state, i32 0, i32 2
  %oldhead = load ptr, ptr @gc_old_state
  %oldcursor = load ptr, ptr %oldcursorp
  %oldleft = load i64, ptr %oldleftp
  store ptr %oldhead, ptr @arena_block
  store ptr %oldcursor, ptr @arena_cursor
  store i64 %oldleft, ptr @arena_left
  call void @j_arena_rewind(ptr @gc_base_mark)
  %newempty = icmp eq ptr %newhead, null
  br i1 %newempty, label %finish, label %tail
tail:
  %block = phi ptr [ %newhead, %prepare ], [ %previous, %tail ]
  %previous = load ptr, ptr %block
  %last = icmp eq ptr %previous, null
  br i1 %last, label %attach, label %tail
attach:
  store ptr %baseblock, ptr %block
  store ptr %newhead, ptr @arena_block
  store ptr %newcursor, ptr @arena_cursor
  store i64 %newleft, ptr @arena_left
  br label %finish
finish:
  %surviving = load i64, ptr @j_gc_pressure
  %doublesurv = shl i64 %surviving, 1
  %largesurv = icmp ugt i64 %doublesurv, 8388608
  %nextthresh = select i1 %largesurv, i64 %doublesurv, i64 8388608
  store i64 %nextthresh, ptr @j_gc_threshold
  store i1 false, ptr @gc_active
  store i64 0, ptr @j_gc_pressure
  store ptr null, ptr @gc_table
  store i64 0, ptr @gc_capacity
  store i64 0, ptr @gc_count
  ret void
error:
  call void @j_fail(ptr @error_collection)
  ret void
}

; j_copy is a non-overlapping forward copy. It lowers to the memcpy intrinsic so
; constant-size copies are expanded inline; variable sizes call @memcpy below.
define void @j_copy(ptr %dest, ptr %source, i64 %length) alwaysinline {
entry:
  call void @llvm.memcpy.p0.p0.i64(ptr %dest, ptr %source, i64 %length, i1 false)
  ret void
}

; The freestanding memory primitives are compiled with "no-builtins" so the
; loop idiom recognizer cannot turn their loops back into self-calls. Bulk
; work moves eight bytes per iteration and the tail is finished bytewise.
define ptr @memcpy(ptr %dest, ptr %source, i64 %length) noinline #0 {
entry:
  %words = lshr i64 %length, 3
  br label %wordloop
wordloop:
  %w = phi i64 [ 0, %entry ], [ %wnext, %wordbody ]
  %wdone = icmp eq i64 %w, %words
  br i1 %wdone, label %tailstart, label %wordbody
wordbody:
  %ws = getelementptr i64, ptr %source, i64 %w
  %wd = getelementptr i64, ptr %dest, i64 %w
  %wv = load i64, ptr %ws, align 1
  store i64 %wv, ptr %wd, align 1
  %wnext = add i64 %w, 1
  br label %wordloop
tailstart:
  %tail = shl i64 %words, 3
  br label %loop
loop:
  %i = phi i64 [ %tail, %tailstart ], [ %next, %body ]
  %done = icmp uge i64 %i, %length
  br i1 %done, label %end, label %body
body:
  %s = getelementptr i8, ptr %source, i64 %i
  %d = getelementptr i8, ptr %dest, i64 %i
  %b = load i8, ptr %s
  store i8 %b, ptr %d
  %next = add i64 %i, 1
  br label %loop
end:
  ret ptr %dest
}

define ptr @memset(ptr %dest, i32 %value, i64 %length) noinline #0 {
entry:
  %byte = trunc i32 %value to i8
  %wide = zext i8 %byte to i64
  %pattern = mul i64 %wide, 72340172838076673
  %words = lshr i64 %length, 3
  br label %wordloop
wordloop:
  %w = phi i64 [ 0, %entry ], [ %wnext, %wordbody ]
  %wdone = icmp eq i64 %w, %words
  br i1 %wdone, label %tailstart, label %wordbody
wordbody:
  %wd = getelementptr i64, ptr %dest, i64 %w
  store i64 %pattern, ptr %wd, align 1
  %wnext = add i64 %w, 1
  br label %wordloop
tailstart:
  %tail = shl i64 %words, 3
  br label %loop
loop:
  %i = phi i64 [ %tail, %tailstart ], [ %next, %body ]
  %done = icmp uge i64 %i, %length
  br i1 %done, label %end, label %body
body:
  %d = getelementptr i8, ptr %dest, i64 %i
  store i8 %byte, ptr %d
  %next = add i64 %i, 1
  br label %loop
end:
  ret ptr %dest
}

declare void @llvm.memcpy.p0.p0.i64(ptr, ptr, i64, i1)

attributes #0 = { "no-builtins" }

define ptr @j_null() {
  ret ptr @value_null
}

define ptr @j_bool(i1 %b) {
  %v = select i1 %b, ptr @value_true, ptr @value_false
  ret ptr %v
}

define ptr @j_num(double %n) {
  %v = call ptr @j_alloc(i64 48)
  store i32 3, ptr %v
  %np = getelementptr %V, ptr %v, i32 0, i32 2
  store double %n, ptr %np
  ret ptr %v
}

define i64 @j_strlen(ptr %string) {
entry:
  br label %loop
loop:
  %i = phi i64 [ 0, %entry ], [ %next, %loop ]
  %p = getelementptr i8, ptr %string, i64 %i
  %b = load i8, ptr %p
  %next = add i64 %i, 1
  %end = icmp eq i8 %b, 0
  br i1 %end, label %done, label %loop
done:
  ret i64 %i
}

define i64 @strlen(ptr %string) noinline optnone {
entry:
  br label %loop
loop:
  %i = phi i64 [ 0, %entry ], [ %next, %loop ]
  %p = getelementptr i8, ptr %string, i64 %i
  %b = load i8, ptr %p
  %next = add i64 %i, 1
  %end = icmp eq i8 %b, 0
  br i1 %end, label %done, label %loop
done:
  ret i64 %i
}

define ptr @j_str(ptr %bytes, i64 %length) {
  %total = add i64 %length, 49
  %v = call ptr @j_alloc(i64 %total)
  store i32 4, ptr %v
  %data = getelementptr i8, ptr %v, i64 48
  call void @j_copy(ptr %data, ptr %bytes, i64 %length)
  %end = getelementptr i8, ptr %data, i64 %length
  store i8 0, ptr %end
  %lp = getelementptr %V, ptr %v, i32 0, i32 3
  %dp = getelementptr %V, ptr %v, i32 0, i32 5
  store i64 %length, ptr %lp
  store ptr %data, ptr %dp
  ret ptr %v
}

define ptr @j_cstr(ptr %string) {
  %n = call i64 @j_strlen(ptr %string)
  %v = call ptr @j_str(ptr %string, i64 %n)
  ret ptr %v
}

define internal i32 @bytes_cmp(ptr %a, i64 %an, ptr %b, i64 %bn) {
entry:
  %lesslen = icmp ult i64 %an, %bn
  %n = select i1 %lesslen, i64 %an, i64 %bn
  br label %loop
loop:
  %i = phi i64 [ 0, %entry ], [ %next, %same ]
  %done = icmp eq i64 %i, %n
  br i1 %done, label %lengths, label %body
body:
  %ap = getelementptr i8, ptr %a, i64 %i
  %bp = getelementptr i8, ptr %b, i64 %i
  %ac = load i8, ptr %ap
  %bc = load i8, ptr %bp
  %eq = icmp eq i8 %ac, %bc
  br i1 %eq, label %same, label %different
same:
  %next = add i64 %i, 1
  br label %loop
different:
  %less = icmp ult i8 %ac, %bc
  %r = select i1 %less, i32 -1, i32 1
  ret i32 %r
lengths:
  %equal = icmp eq i64 %an, %bn
  %lr = select i1 %lesslen, i32 -1, i32 1
  %result = select i1 %equal, i32 0, i32 %lr
  ret i32 %result
}

define i1 @j_is(ptr %value, ptr %name) {
entry:
  %absent = icmp eq ptr %value, null
  br i1 %absent, label %no, label %check
check:
  %tag = load i32, ptr %value
  %string = icmp eq i32 %tag, 4
  br i1 %string, label %compare, label %no
compare:
  %lp = getelementptr %V, ptr %value, i32 0, i32 3
  %dp = getelementptr %V, ptr %value, i32 0, i32 5
  %n = load i64, ptr %lp
  %data = load ptr, ptr %dp
  %nn = call i64 @j_strlen(ptr %name)
  %cmp = call i32 @bytes_cmp(ptr %data, i64 %n, ptr %name, i64 %nn)
  %eq = icmp eq i32 %cmp, 0
  ret i1 %eq
no:
  ret i1 false
}

define ptr @j_array() {
  %v = call ptr @j_alloc(i64 48)
  store i32 5, ptr %v
  ret ptr %v
}

define ptr @j_object() {
  %v = call ptr @j_alloc(i64 48)
  store i32 6, ptr %v
  ret ptr %v
}

define internal void @reserve(ptr %v, i64 %count, i64 %width) {
entry:
  %cp = getelementptr %V, ptr %v, i32 0, i32 4
  %dp = getelementptr %V, ptr %v, i32 0, i32 5
  %cap = load i64, ptr %cp
  %enough = icmp uge i64 %cap, %count
  br i1 %enough, label %done, label %grow
grow:
  %double = mul i64 %cap, 2
  %small = icmp ult i64 %double, 8
  %atleast = select i1 %small, i64 8, i64 %double
  %larger = icmp ugt i64 %count, %atleast
  %newcap = select i1 %larger, i64 %count, i64 %atleast
  %size = mul i64 %newcap, %width
  %newdata = call ptr @j_alloc(i64 %size)
  %data = load ptr, ptr %dp
  %oldsize = mul i64 %cap, %width
  call void @j_copy(ptr %newdata, ptr %data, i64 %oldsize)
  store i64 %newcap, ptr %cp
  store ptr %newdata, ptr %dp
  br label %done
done:
  ret void
}

define void @j_push(ptr %array, ptr %value) {
  %lp = getelementptr %V, ptr %array, i32 0, i32 3
  %dp = getelementptr %V, ptr %array, i32 0, i32 5
  %len = load i64, ptr %lp
  %next = add i64 %len, 1
  call void @reserve(ptr %array, i64 %next, i64 8)
  %data = load ptr, ptr %dp
  %slot = getelementptr ptr, ptr %data, i64 %len
  store ptr %value, ptr %slot
  store i64 %next, ptr %lp
  ret void
}

define ptr @j_at(ptr %array, i64 %index) {
entry:
  %absent = icmp eq ptr %array, null
  br i1 %absent, label %missing, label %check
check:
  %lp = getelementptr %V, ptr %array, i32 0, i32 3
  %len = load i64, ptr %lp
  %negative = icmp slt i64 %index, 0
  %fromend = add i64 %len, %index
  %i = select i1 %negative, i64 %fromend, i64 %index
  %valid = icmp ult i64 %i, %len
  br i1 %valid, label %found, label %missing
found:
  %dp = getelementptr %V, ptr %array, i32 0, i32 5
  %data = load ptr, ptr %dp
  %slot = getelementptr ptr, ptr %data, i64 %i
  %v = load ptr, ptr %slot
  ret ptr %v
missing:
  ret ptr @value_null
}

define i1 @j_str_eq(ptr %a, ptr %b) {
entry:
  %same = icmp eq ptr %a, %b
  br i1 %same, label %yes, label %checklen
checklen:
  %alp = getelementptr %V, ptr %a, i32 0, i32 3
  %blp = getelementptr %V, ptr %b, i32 0, i32 3
  %alen = load i64, ptr %alp
  %blen = load i64, ptr %blp
  %samelen = icmp eq i64 %alen, %blen
  br i1 %samelen, label %checkbytes, label %no
checkbytes:
  %adp = getelementptr %V, ptr %a, i32 0, i32 5
  %bdp = getelementptr %V, ptr %b, i32 0, i32 5
  %adata = load ptr, ptr %adp
  %bdata = load ptr, ptr %bdp
  %short = icmp ule i64 %alen, 8
  br i1 %short, label %shortcheck, label %longcheck
shortcheck:
  %ge4 = icmp uge i64 %alen, 4
  br i1 %ge4, label %short4to8, label %short0to3
short4to8:
  %last4 = sub i64 %alen, 4
  %a0 = load i32, ptr %adata, align 1
  %b0 = load i32, ptr %bdata, align 1
  %ap4 = getelementptr i8, ptr %adata, i64 %last4
  %bp4 = getelementptr i8, ptr %bdata, i64 %last4
  %a1 = load i32, ptr %ap4, align 1
  %b1 = load i32, ptr %bp4, align 1
  %x0 = xor i32 %a0, %b0
  %x1 = xor i32 %a1, %b1
  %x48 = or i32 %x0, %x1
  %eq48 = icmp eq i32 %x48, 0
  ret i1 %eq48
short0to3:
  %empty = icmp eq i64 %alen, 0
  br i1 %empty, label %yes, label %short1to3
short1to3:
  %mid = lshr i64 %alen, 1
  %last1 = sub i64 %alen, 1
  %sa0 = load i8, ptr %adata
  %sb0 = load i8, ptr %bdata
  %sam = getelementptr i8, ptr %adata, i64 %mid
  %sbm = getelementptr i8, ptr %bdata, i64 %mid
  %sa1 = load i8, ptr %sam
  %sb1 = load i8, ptr %sbm
  %sal = getelementptr i8, ptr %adata, i64 %last1
  %sbl = getelementptr i8, ptr %bdata, i64 %last1
  %sa2 = load i8, ptr %sal
  %sb2 = load i8, ptr %sbl
  %sx0 = xor i8 %sa0, %sb0
  %sx1 = xor i8 %sa1, %sb1
  %sx2 = xor i8 %sa2, %sb2
  %sx01 = or i8 %sx0, %sx1
  %sx = or i8 %sx01, %sx2
  %eq13 = icmp eq i8 %sx, 0
  ret i1 %eq13
longcheck:
  %words = lshr i64 %alen, 3
  br label %wordloop
wordloop:
  %w = phi i64 [ 0, %longcheck ], [ %wnext, %wordnext ]
  %wdone = icmp eq i64 %w, %words
  br i1 %wdone, label %tailstart, label %wordbody
wordbody:
  %wa = getelementptr i64, ptr %adata, i64 %w
  %wb = getelementptr i64, ptr %bdata, i64 %w
  %av = load i64, ptr %wa, align 1
  %bv = load i64, ptr %wb, align 1
  %weq = icmp eq i64 %av, %bv
  br i1 %weq, label %wordnext, label %no
wordnext:
  %wnext = add i64 %w, 1
  br label %wordloop
tailstart:
  %tail = shl i64 %words, 3
  br label %tailloop
tailloop:
  %i = phi i64 [ %tail, %tailstart ], [ %inext, %tailnext ]
  %tdone = icmp eq i64 %i, %alen
  br i1 %tdone, label %yes, label %tailbody
tailbody:
  %pa = getelementptr i8, ptr %adata, i64 %i
  %pb = getelementptr i8, ptr %bdata, i64 %i
  %ca = load i8, ptr %pa
  %cb = load i8, ptr %pb
  %ceq = icmp eq i8 %ca, %cb
  br i1 %ceq, label %tailnext, label %no
tailnext:
  %inext = add i64 %i, 1
  br label %tailloop
yes:
  ret i1 true
no:
  ret i1 false
}

define void @j_put(ptr %object, ptr %key, ptr %value) {
entry:
  %tag = load i32, ptr %key
  %valid = icmp eq i32 %tag, 4
  br i1 %valid, label %start, label %error
error:
  call void @j_object_key_error(ptr %key)
  ret void
start:
  %lp = getelementptr %V, ptr %object, i32 0, i32 3
  %dp = getelementptr %V, ptr %object, i32 0, i32 5
  %len = load i64, ptr %lp
  %data = load ptr, ptr %dp
  br label %loop
loop:
  %i = phi i64 [ 0, %start ], [ %next, %advance ]
  %done = icmp eq i64 %i, %len
  br i1 %done, label %append, label %body
body:
  %ki = mul i64 %i, 2
  %kp = getelementptr ptr, ptr %data, i64 %ki
  %k = load ptr, ptr %kp
  %equal = call i1 @j_str_eq(ptr %k, ptr %key)
  br i1 %equal, label %replace, label %advance
advance:
  %next = add i64 %i, 1
  br label %loop
replace:
  %vp = getelementptr ptr, ptr %kp, i64 1
  store ptr %value, ptr %vp
  ret void
append:
  %newlen = add i64 %len, 1
  call void @reserve(ptr %object, i64 %newlen, i64 16)
  %newdata = load ptr, ptr %dp
  %index = mul i64 %len, 2
  %newkp = getelementptr ptr, ptr %newdata, i64 %index
  %newvp = getelementptr ptr, ptr %newkp, i64 1
  store ptr %key, ptr %newkp
  store ptr %value, ptr %newvp
  store i64 %newlen, ptr %lp
  ret void
}

define ptr @j_get(ptr %value, ptr %key) {
entry:
  %tag = load i32, ptr %value
  %ktag = load i32, ptr %key
  switch i32 %tag, label %error [ i32 0, label %missing i32 5, label %array i32 6, label %object ]
array:
  %numeric = icmp eq i32 %ktag, 3
  br i1 %numeric, label %arrayindex, label %error
arrayindex:
  %np = getelementptr %V, ptr %key, i32 0, i32 2
  %n = load double, ptr %np
  %lo = fcmp oge double %n, -9.223372036854775808e18
  %hi = fcmp olt double %n, 9.223372036854775808e18
  %valid = and i1 %lo, %hi
  br i1 %valid, label %readarray, label %missing
readarray:
  %index = fptosi double %n to i64
  %element = call ptr @j_at(ptr %value, i64 %index)
  ret ptr %element
object:
  %string = icmp eq i32 %ktag, 4
  br i1 %string, label %objectstart, label %error
objectstart:
  %lp = getelementptr %V, ptr %value, i32 0, i32 3
  %dp = getelementptr %V, ptr %value, i32 0, i32 5
  %len = load i64, ptr %lp
  %data = load ptr, ptr %dp
  br label %loop
loop:
  %i = phi i64 [ 0, %objectstart ], [ %next, %advance ]
  %done = icmp eq i64 %i, %len
  br i1 %done, label %missing, label %body
body:
  %ki = mul i64 %i, 2
  %kp = getelementptr ptr, ptr %data, i64 %ki
  %k = load ptr, ptr %kp
  %equal = call i1 @j_str_eq(ptr %k, ptr %key)
  br i1 %equal, label %found, label %advance
advance:
  %next = add i64 %i, 1
  br label %loop
found:
  %vp = getelementptr ptr, ptr %kp, i64 1
  %result = load ptr, ptr %vp
  ret ptr %result
error:
  call void @j_index_error(ptr %value, ptr %key)
  br label %missing
missing:
  ret ptr @value_null
}

define ptr @j_clone(ptr %value) {
entry:
  %tag = load i32, ptr %value
  %container = icmp uge i32 %tag, 5
  br i1 %container, label %copy, label %same
copy:
  %v = call ptr @j_alloc(i64 48)
  call void @j_copy(ptr %v, ptr %value, i64 48)
  %lp = getelementptr %V, ptr %v, i32 0, i32 3
  %cp = getelementptr %V, ptr %v, i32 0, i32 4
  %dp = getelementptr %V, ptr %v, i32 0, i32 5
  %len = load i64, ptr %lp
  %newcap = add i64 %len, 2
  %isobj = icmp eq i32 %tag, 6
  %width = select i1 %isobj, i64 16, i64 8
  %bytes = mul i64 %len, %width
  %allocbytes = mul i64 %newcap, %width
  %data = load ptr, ptr %dp
  %newdata = call ptr @j_alloc(i64 %allocbytes)
  call void @j_copy(ptr %newdata, ptr %data, i64 %bytes)
  store i64 %newcap, ptr %cp
  store ptr %newdata, ptr %dp
  ret ptr %v
same:
  ret ptr %value
}

define i1 @j_truth(ptr %value) {
  %tag = load i32, ptr %value
  %truth = icmp ugt i32 %tag, 1
  ret i1 %truth
}

define void @j_fail(ptr %message) {
  %v = call ptr @j_cstr(ptr %message)
  store ptr %v, ptr @j_error
  ret void
}

define ptr @j_keys_sorted(ptr %object) {
entry:
  %a = call ptr @j_array()
  %lp = getelementptr %V, ptr %object, i32 0, i32 3
  %dp = getelementptr %V, ptr %object, i32 0, i32 5
  %len = load i64, ptr %lp
  %data = load ptr, ptr %dp
  br label %copy
copy:
  %i = phi i64 [ 0, %entry ], [ %next, %body ]
  %end = icmp eq i64 %i, %len
  br i1 %end, label %sortstart, label %body
body:
  %ix = mul i64 %i, 2
  %kp = getelementptr ptr, ptr %data, i64 %ix
  %k = load ptr, ptr %kp
  call void @j_push(ptr %a, ptr %k)
  %next = add i64 %i, 1
  br label %copy
sortstart:
  %adp = getelementptr %V, ptr %a, i32 0, i32 5
  %ad = load ptr, ptr %adp
  br label %outer
outer:
  %x = phi i64 [ 1, %sortstart ], [ %xn, %outerend ]
  %done = icmp uge i64 %x, %len
  br i1 %done, label %finish, label %begin
begin:
  %xp = getelementptr ptr, ptr %ad, i64 %x
  %item = load ptr, ptr %xp
  br label %inner
inner:
  %j = phi i64 [ %x, %begin ], [ %previous, %move ]
  %first = icmp eq i64 %j, 0
  br i1 %first, label %insert, label %compare
compare:
  %previous = sub i64 %j, 1
  %pp = getelementptr ptr, ptr %ad, i64 %previous
  %pv = load ptr, ptr %pp
  %cmp = call i32 @j_cmp(ptr %pv, ptr %item)
  %greater = icmp sgt i32 %cmp, 0
  br i1 %greater, label %move, label %insert
move:
  %jp = getelementptr ptr, ptr %ad, i64 %j
  store ptr %pv, ptr %jp
  br label %inner
insert:
  %ip = getelementptr ptr, ptr %ad, i64 %j
  store ptr %item, ptr %ip
  br label %outerend
outerend:
  %xn = add i64 %x, 1
  br label %outer
finish:
  ret ptr %a
}

define internal i32 @cmp_inner(ptr %left, ptr %right) {
entry:
  %identical = icmp eq ptr %left, %right
  %lefttag = load i32, ptr %left
  %scalar = icmp ult i32 %lefttag, 5
  %samevalue = and i1 %identical, %scalar
  br i1 %samevalue, label %equal, label %tags
tags:
  %lt = load i32, ptr %left
  %rt = load i32, ptr %right
  %same = icmp eq i32 %lt, %rt
  br i1 %same, label %dispatch, label %tagorder
tagorder:
  %tl = icmp ult i32 %lt, %rt
  %to = select i1 %tl, i32 -1, i32 1
  ret i32 %to
dispatch:
  switch i32 %lt, label %equal [ i32 3, label %numbers i32 4, label %strings i32 5, label %arrays i32 6, label %objects ]
numbers:
  %lnp = getelementptr %V, ptr %left, i32 0, i32 2
  %rnp = getelementptr %V, ptr %right, i32 0, i32 2
  %ln = load double, ptr %lnp
  %rn = load double, ptr %rnp
  %ne = fcmp oeq double %ln, %rn
  br i1 %ne, label %numequal, label %numdiff
numequal:
  %llitp = getelementptr %V, ptr %left, i32 0, i32 6
  %rlitp = getelementptr %V, ptr %right, i32 0, i32 6
  %llit = load ptr, ptr %llitp
  %rlit = load ptr, ptr %rlitp
  %ldec = icmp ne ptr %llit, null
  %rdec = icmp ne ptr %rlit, null
  %bothdecimal = and i1 %ldec, %rdec
  br i1 %bothdecimal, label %decimalnumbers, label %equal
decimalnumbers:
  %dc = call i32 @decimal_compare(ptr %llit, ptr %rlit)
  ret i32 %dc
numdiff:
  %nl = fcmp ult double %ln, %rn
  %no = select i1 %nl, i32 -1, i32 1
  ret i32 %no
strings:
  %llp = getelementptr %V, ptr %left, i32 0, i32 3
  %rlp = getelementptr %V, ptr %right, i32 0, i32 3
  %ldp = getelementptr %V, ptr %left, i32 0, i32 5
  %rdp = getelementptr %V, ptr %right, i32 0, i32 5
  %ll = load i64, ptr %llp
  %rl = load i64, ptr %rlp
  %ld = load ptr, ptr %ldp
  %rd = load ptr, ptr %rdp
  %sc = call i32 @bytes_cmp(ptr %ld, i64 %ll, ptr %rd, i64 %rl)
  ret i32 %sc
objects:
  %lk = call ptr @j_keys_sorted(ptr %left)
  %rk = call ptr @j_keys_sorted(ptr %right)
  %kc = call i32 @j_cmp(ptr %lk, ptr %rk)
  %ke = icmp eq i32 %kc, 0
  br i1 %ke, label %objstart, label %keyresult
keyresult:
  ret i32 %kc
objstart:
  %klp = getelementptr %V, ptr %lk, i32 0, i32 3
  %kl = load i64, ptr %klp
  br label %objloop
objloop:
  %oi = phi i64 [ 0, %objstart ], [ %onext, %objnext ]
  %odone = icmp eq i64 %oi, %kl
  br i1 %odone, label %equal, label %objbody
objbody:
  %key = call ptr @j_at(ptr %lk, i64 %oi)
  %lv = call ptr @j_get(ptr %left, ptr %key)
  %rv = call ptr @j_get(ptr %right, ptr %key)
  %oc = call i32 @j_cmp(ptr %lv, ptr %rv)
  %oe = icmp eq i32 %oc, 0
  br i1 %oe, label %objnext, label %objresult
objnext:
  %onext = add i64 %oi, 1
  br label %objloop
objresult:
  ret i32 %oc
arrays:
  %alp = getelementptr %V, ptr %left, i32 0, i32 3
  %blp = getelementptr %V, ptr %right, i32 0, i32 3
  %al = load i64, ptr %alp
  %bl = load i64, ptr %blp
  %shorter = icmp ult i64 %al, %bl
  %min = select i1 %shorter, i64 %al, i64 %bl
  br label %arrayloop
arrayloop:
  %ai = phi i64 [ 0, %arrays ], [ %anext, %arraynext ]
  %adone = icmp eq i64 %ai, %min
  br i1 %adone, label %arraylengths, label %arraybody
arraybody:
  %av = call ptr @j_at(ptr %left, i64 %ai)
  %bv = call ptr @j_at(ptr %right, i64 %ai)
  %ac = call i32 @j_cmp(ptr %av, ptr %bv)
  %ae = icmp eq i32 %ac, 0
  br i1 %ae, label %arraynext, label %arrayresult
arraynext:
  %anext = add i64 %ai, 1
  br label %arrayloop
arrayresult:
  ret i32 %ac
arraylengths:
  %eqsize = icmp eq i64 %al, %bl
  %sizeorder = select i1 %shorter, i32 -1, i32 1
  %sizecmp = select i1 %eqsize, i32 0, i32 %sizeorder
  ret i32 %sizecmp
equal:
  ret i32 0
}

define i32 @j_utf8_next(ptr %data, i64 %length, ptr %offset) {
entry:
  %i = load i64, ptr %offset
  %end = icmp uge i64 %i, %length
  br i1 %end, label %eof, label %first
first:
  %p = getelementptr i8, ptr %data, i64 %i
  %b = load i8, ptr %p
  %c = zext i8 %b to i32
  %next = add i64 %i, 1
  store i64 %next, ptr %offset
  %ascii = icmp ult i32 %c, 128
  br i1 %ascii, label %one, label %leading
one:
  ret i32 %c
leading:
  %low = icmp ult i32 %c, 194
  %high = icmp ugt i32 %c, 244
  %bad = or i1 %low, %high
  br i1 %bad, label %invalid, label %width
width:
  %two = icmp ult i32 %c, 224
  %three = icmp ult i32 %c, 240
  %wide = select i1 %three, i64 3, i64 4
  %n = select i1 %two, i64 2, i64 %wide
  %stop = add i64 %i, %n
  br label %decode
decode:
  %mask3 = select i1 %three, i32 15, i32 7
  %mask = select i1 %two, i32 31, i32 %mask3
  %initial = and i32 %c, %mask
  br label %loop
loop:
  %j = phi i64 [ 1, %decode ], [ %jn, %append ]
  %code = phi i32 [ %initial, %decode ], [ %updated, %append ]
  %done = icmp eq i64 %j, %n
  br i1 %done, label %validate, label %continuation
continuation:
  %byteindex = add i64 %i, %j
  %available = icmp ult i64 %byteindex, %length
  br i1 %available, label %continuationbyte, label %invalid
continuationbyte:
  %q = getelementptr i8, ptr %p, i64 %j
  %cb = load i8, ptr %q
  %top = and i8 %cb, -64
  %cont = icmp eq i8 %top, -128
  br i1 %cont, label %append, label %invalid
append:
  %bits = and i8 %cb, 63
  %ext = zext i8 %bits to i32
  %shift = shl i32 %code, 6
  %updated = or i32 %shift, %ext
  %jn = add i64 %j, 1
  %consumed = add i64 %i, %jn
  store i64 %consumed, ptr %offset
  br label %loop
validate:
  store i64 %stop, ptr %offset
  %min3 = select i1 %three, i32 2048, i32 65536
  %minimum = select i1 %two, i32 128, i32 %min3
  %overlong = icmp ult i32 %code, %minimum
  %toobig = icmp ugt i32 %code, 1114111
  %surrogatediff = sub i32 %code, 55296
  %surrogate = icmp ult i32 %surrogatediff, 2048
  %b1 = or i1 %overlong, %toobig
  %b2 = or i1 %b1, %surrogate
  br i1 %b2, label %invalid, label %valid
valid:
  store i64 %stop, ptr %offset
  ret i32 %code
invalid:
  ret i32 65533
eof:
  ret i32 -1
}

define i64 @j_utf8_put(ptr %output, i32 %cp) {
entry:
  %valid = icmp ule i32 %cp, 1114111
  %delta = sub i32 %cp, 55296
  %surrogate = icmp ult i32 %delta, 2048
  %notvalid = xor i1 %valid, true
  %bad = or i1 %notvalid, %surrogate
  %c = select i1 %bad, i32 65533, i32 %cp
  %one = icmp ult i32 %c, 128
  br i1 %one, label %ascii, label %multi
ascii:
  %a = trunc i32 %c to i8
  store i8 %a, ptr %output
  ret i64 1
multi:
  %two = icmp ult i32 %c, 2048
  %three = icmp ult i32 %c, 65536
  %n3 = select i1 %three, i64 3, i64 4
  %n = select i1 %two, i64 2, i64 %n3
  %prefix3 = select i1 %three, i32 224, i32 240
  %prefix = select i1 %two, i32 192, i32 %prefix3
  %nminus = sub i64 %n, 1
  %shift64 = mul i64 %nminus, 6
  %shift = trunc i64 %shift64 to i32
  %high = lshr i32 %c, %shift
  %first = or i32 %high, %prefix
  %b = trunc i32 %first to i8
  store i8 %b, ptr %output
  br label %loop
loop:
  %i = phi i64 [ 1, %multi ], [ %next, %body ]
  %done = icmp eq i64 %i, %n
  br i1 %done, label %end, label %body
body:
  %remaining = sub i64 %nminus, %i
  %s64 = mul i64 %remaining, 6
  %s = trunc i64 %s64 to i32
  %part = lshr i32 %c, %s
  %bits = and i32 %part, 63
  %prefixed = or i32 %bits, 128
  %out = trunc i32 %prefixed to i8
  %p = getelementptr i8, ptr %output, i64 %i
  store i8 %out, ptr %p
  %next = add i64 %i, 1
  br label %loop
end:
  ret i64 %n
}

define internal i64 @json_space(ptr %data, i64 %length, i64 %start) alwaysinline {
entry:
  br label %loop
loop:
  %i = phi i64 [ %start, %entry ], [ %next, %skip ]
  %end = icmp uge i64 %i, %length
  br i1 %end, label %done, label %body
body:
  %p = getelementptr i8, ptr %data, i64 %i
  %c = load i8, ptr %p
  %nonws = icmp ugt i8 %c, 32
  br i1 %nonws, label %done, label %wscheck
wscheck:
  %space = icmp eq i8 %c, 32
  %tab = icmp eq i8 %c, 9
  %lf = icmp eq i8 %c, 10
  %cr = icmp eq i8 %c, 13
  %w1 = or i1 %space, %tab
  %w2 = or i1 %lf, %cr
  %ws = or i1 %w1, %w2
  br i1 %ws, label %skip, label %done
skip:
  %next = add i64 %i, 1
  br label %loop
done:
  ret i64 %i
}

define internal i32 @hex4(ptr %p) {
entry:
  br label %loop
loop:
  %i = phi i64 [ 0, %entry ], [ %next, %append ]
  %code = phi i32 [ 0, %entry ], [ %updated, %append ]
  %done = icmp eq i64 %i, 4
  br i1 %done, label %end, label %body
body:
  %q = getelementptr i8, ptr %p, i64 %i
  %b = load i8, ptr %q
  %c = zext i8 %b to i32
  %digit = sub i32 %c, 48
  %number = icmp ult i32 %digit, 10
  %lower = or i32 %c, 32
  %letter = sub i32 %lower, 97
  %alpha = icmp ult i32 %letter, 6
  %valid = or i1 %number, %alpha
  br i1 %valid, label %append, label %error
append:
  %hexletter = add i32 %letter, 10
  %hex = select i1 %number, i32 %digit, i32 %hexletter
  %shift = shl i32 %code, 4
  %updated = or i32 %shift, %hex
  %next = add i64 %i, 1
  br label %loop
end:
  ret i32 %code
error:
  ret i32 -1
}

define internal ptr @json_string(ptr %data, i64 %length, ptr %offset) {
entry:
  %begin = load i64, ptr %offset
  %first = add i64 %begin, 1
  br label %fastloop
fastloop:
  %fi = phi i64 [ %first, %entry ], [ %finext, %fastnext ]
  %fend = icmp uge i64 %fi, %length
  br i1 %fend, label %unfinished, label %fastbody
fastbody:
  %fp = getelementptr i8, ptr %data, i64 %fi
  %fc = load i8, ptr %fp
  %fquote = icmp eq i8 %fc, 34
  br i1 %fquote, label %fastfinish, label %fastcheck
fastcheck:
  %fslash = icmp eq i8 %fc, 92
  %fspecial = icmp slt i8 %fc, 32
  %fslow = or i1 %fslash, %fspecial
  br i1 %fslow, label %scanstart, label %fastnext
fastnext:
  %finext = add i64 %fi, 1
  br label %fastloop
fastfinish:
  %fafter = add i64 %fi, 1
  store i64 %fafter, ptr %offset
  %fstartp = getelementptr i8, ptr %data, i64 %first
  %flen = sub i64 %fi, %first
  %fv = call ptr @j_str(ptr %fstartp, i64 %flen)
  ret ptr %fv
scanstart:
  br label %scanloop
scanloop:
  %si = phi i64 [ %fi, %scanstart ], [ %sinext, %scannext ]
  %sesc = phi i1 [ false, %scanstart ], [ %snextesc, %scannext ]
  %send = icmp uge i64 %si, %length
  br i1 %send, label %slowalloc, label %scanbody
scanbody:
  %sp = getelementptr i8, ptr %data, i64 %si
  %sc = load i8, ptr %sp
  %sunesc = xor i1 %sesc, true
  %squote = icmp eq i8 %sc, 34
  %sdone = and i1 %squote, %sunesc
  br i1 %sdone, label %slowalloc, label %scannext
scannext:
  %sslash = icmp eq i8 %sc, 92
  %snextesc = and i1 %sslash, %sunesc
  %sinext = add i64 %si, 1
  br label %scanloop
slowalloc:
  %rawspan = sub i64 %si, %first
  %span3 = mul i64 %rawspan, 3
  %allocsize = add i64 %span3, 4
  %out = call ptr @j_alloc(i64 %allocsize)
  %prefixlen = sub i64 %fi, %first
  %prefixsrc = getelementptr i8, ptr %data, i64 %first
  call void @j_copy(ptr %out, ptr %prefixsrc, i64 %prefixlen)
  br label %loop
loop:
  %i = phi i64 [ %fi, %slowalloc ], [ %inext, %copy ], [ %escnext, %simple ], [ %unext, %unicodeout ], [ %utfnext, %utfout ]
  %o = phi i64 [ %prefixlen, %slowalloc ], [ %onext, %copy ], [ %simpleonext, %simple ], [ %unicodeonext, %unicodeout ], [ %utfoutnext, %utfout ]
  %end = icmp uge i64 %i, %length
  br i1 %end, label %unfinished, label %body
body:
  %p = getelementptr i8, ptr %data, i64 %i
  %c = load i8, ptr %p
  %dst = getelementptr i8, ptr %out, i64 %o
  %quote = icmp eq i8 %c, 34
  br i1 %quote, label %finish, label %notquote
notquote:
  %slash = icmp eq i8 %c, 92
  br i1 %slash, label %escape, label %plain
plain:
  %control = icmp ult i8 %c, 32
  br i1 %control, label %controlerror, label %notcontrol
notcontrol:
  %utf = icmp uge i8 %c, -128
  br i1 %utf, label %utfout, label %copy
copy:
  store i8 %c, ptr %dst
  %inext = add i64 %i, 1
  %onext = add i64 %o, 1
  br label %loop
utfout:
  store i64 %i, ptr %offset
  %codepoint = call i32 @j_utf8_next(ptr %data, i64 %length, ptr %offset)
  %utfnext = load i64, ptr %offset
  %utfbytes = call i64 @j_utf8_put(ptr %dst, i32 %codepoint)
  %utfoutnext = add i64 %o, %utfbytes
  br label %loop
escape:
  %ei = add i64 %i, 1
  %short = icmp uge i64 %ei, %length
  br i1 %short, label %unfinished, label %escaped
escaped:
  %ep = getelementptr i8, ptr %data, i64 %ei
  %e = load i8, ptr %ep
  switch i8 %e, label %escapeerror [ i8 34, label %literal i8 92, label %literal i8 47, label %literal i8 98, label %backspace i8 102, label %formfeed i8 110, label %newline i8 114, label %return i8 116, label %tab i8 117, label %unicode ]
literal:
  br label %simple
backspace:
  br label %simple
formfeed:
  br label %simple
newline:
  br label %simple
return:
  br label %simple
tab:
  br label %simple
simple:
  %ec = phi i8 [ %e, %literal ], [ 8, %backspace ], [ 12, %formfeed ], [ 10, %newline ], [ 13, %return ], [ 9, %tab ]
  store i8 %ec, ptr %dst
  %escnext = add i64 %i, 2
  %simpleonext = add i64 %o, 1
  br label %loop
unicode:
  %ustop = add i64 %i, 6
  %ushort = icmp ugt i64 %ustop, %length
  br i1 %ushort, label %unicodeerror, label %hex
hex:
  %hp = getelementptr i8, ptr %p, i64 2
  %cp = call i32 @hex4(ptr %hp)
  %invalid = icmp slt i32 %cp, 0
  br i1 %invalid, label %hexerror, label %surrogatecheck
surrogatecheck:
  %hd = sub i32 %cp, 55296
  %highsurrogate = icmp ult i32 %hd, 1024
  br i1 %highsurrogate, label %paircheck, label %singleunicode
singleunicode:
  %ld = sub i32 %cp, 56320
  %lone = icmp ult i32 %ld, 1024
  br i1 %lone, label %surrogateerror, label %unicodeout
paircheck:
  %pairstop = add i64 %i, 12
  %pairshort = icmp ugt i64 %pairstop, %length
  br i1 %pairshort, label %surrogateerror, label %pairread
pairread:
  %s1p = getelementptr i8, ptr %p, i64 6
  %s2p = getelementptr i8, ptr %p, i64 7
  %s1 = load i8, ptr %s1p
  %s2 = load i8, ptr %s2p
  %s1ok = icmp eq i8 %s1, 92
  %s2ok = icmp eq i8 %s2, 117
  %pairok = and i1 %s1ok, %s2ok
  br i1 %pairok, label %pairhex, label %surrogateerror
pairhex:
  %lowp = getelementptr i8, ptr %p, i64 8
  %low = call i32 @hex4(ptr %lowp)
  %lowdelta = sub i32 %low, 56320
  %lowvalid = icmp ult i32 %lowdelta, 1024
  br i1 %lowvalid, label %pairvalue, label %surrogateerror
pairvalue:
  %highbits = shl i32 %hd, 10
  %both = or i32 %highbits, %lowdelta
  %paired = add i32 %both, 65536
  br label %unicodeout
unicodeout:
  %uc = phi i32 [ %cp, %singleunicode ], [ %paired, %pairvalue ]
  %unext = phi i64 [ %ustop, %singleunicode ], [ %pairstop, %pairvalue ]
  %written = call i64 @j_utf8_put(ptr %dst, i32 %uc)
  %unicodeonext = add i64 %o, %written
  br label %loop
finish:
  %after = add i64 %i, 1
  store i64 %after, ptr %offset
  %outend = getelementptr i8, ptr %out, i64 %o
  store i8 0, ptr %outend
  %v = call ptr @j_alloc(i64 48)
  store i32 4, ptr %v
  %vlp = getelementptr %V, ptr %v, i32 0, i32 3
  %vdp = getelementptr %V, ptr %v, i32 0, i32 5
  store i64 %o, ptr %vlp
  store ptr %out, ptr %vdp
  ret ptr %v
unfinished:
  store i64 %length, ptr %offset
  call void @j_json_error(ptr %data, i64 %length, i64 %length, ptr @error_unfinished_string, i1 true)
  ret ptr null
controlerror:
  br label %error
escapeerror:
  br label %error
unicodeerror:
  br label %error
hexerror:
  br label %error
surrogateerror:
  br label %error
error:
  %message = phi ptr [ @error_string_control, %controlerror ], [ @error_escape, %escapeerror ], [ @error_unicode_escape, %unicodeerror ], [ @error_unicode_hex, %hexerror ], [ @error_unicode_pair, %surrogateerror ]
  call void @json_string_error(ptr %data, i64 %length, i64 %begin, ptr %message)
  %errorpos = load i64, ptr @j_parse_error_offset
  store i64 %errorpos, ptr %offset
  ret ptr null
}

define internal void @json_string_error(ptr %data, i64 %length, i64 %begin, ptr %message) {
entry:
  %start = add i64 %begin, 1
  br label %loop
loop:
  %i = phi i64 [ %start, %entry ], [ %next, %advance ]
  %escaped = phi i1 [ false, %entry ], [ %newescaped, %advance ]
  %done = icmp uge i64 %i, %length
  br i1 %done, label %eof, label %body
body:
  %p = getelementptr i8, ptr %data, i64 %i
  %c = load i8, ptr %p
  %quote = icmp eq i8 %c, 34
  %unescaped = xor i1 %escaped, true
  %end = and i1 %quote, %unescaped
  br i1 %end, label %finished, label %advance
advance:
  %slash = icmp eq i8 %c, 92
  %newescaped = and i1 %slash, %unescaped
  %next = add i64 %i, 1
  br label %loop
finished:
  %after = add i64 %i, 1
  call void @j_json_error(ptr %data, i64 %length, i64 %after, ptr %message, i1 false)
  ret void
eof:
  call void @j_json_error(ptr %data, i64 %length, i64 %length, ptr @error_unfinished_string, i1 true)
  ret void
}

define double @j_pow10(i32 %exponent) {
entry:
  %negative = icmp slt i32 %exponent, 0
  %negated = sub i32 0, %exponent
  %magnitude = select i1 %negative, i32 %negated, i32 %exponent
  br label %loop
loop:
  %e = phi i32 [ %magnitude, %entry ], [ %shift, %body ]
  %base = phi double [ 1.0e1, %entry ], [ %squared, %body ]
  %product = phi double [ 1.0, %entry ], [ %updated, %body ]
  %done = icmp eq i32 %e, 0
  br i1 %done, label %finish, label %body
body:
  %bit = and i32 %e, 1
  %odd = icmp ne i32 %bit, 0
  %multiplied = fmul double %product, %base
  %updated = select i1 %odd, double %multiplied, double %product
  %squared = fmul double %base, %base
  %shift = lshr i32 %e, 1
  br label %loop
finish:
  %reciprocal = fdiv double 1.0, %product
  %answer = select i1 %negative, double %reciprocal, double %product
  ret double %answer
}

define internal ptr @json_number(ptr %data, i64 %length, ptr %offset) {
entry:
  %start = load i64, ptr %offset
  %sp = getelementptr i8, ptr %data, i64 %start
  %first = load i8, ptr %sp
  %negative = icmp eq i8 %first, 45
  %plus = icmp eq i8 %first, 43
  %signed = or i1 %negative, %plus
  %signwidth = zext i1 %signed to i64
  %begin = add i64 %start, %signwidth
  %hasb = icmp ult i64 %begin, %length
  br i1 %hasb, label %checkfirstdig, label %tryjson_special
checkfirstdig:
  %bp = getelementptr i8, ptr %data, i64 %begin
  %bc = load i8, ptr %bp
  %bd = sub i8 %bc, 48
  %bisdig = icmp ult i8 %bd, 10
  br i1 %bisdig, label %digitstart, label %tryjson_special
tryjson_special:
  %special = call ptr @json_special(ptr %data, i64 %length, ptr %offset)
  %isspecial = icmp ne ptr %special, null
  br i1 %isspecial, label %specialresult, label %digitstart
specialresult:
  ret ptr %special
digitstart:
  br label %digits
digits:
  %i = phi i64 [ %begin, %digitstart ], [ %next, %append ], [ %dotnext, %dot ]
  %decimal = phi i1 [ false, %digitstart ], [ %decimal, %append ], [ true, %dot ]
  %seen = phi i1 [ false, %digitstart ], [ true, %append ], [ %seen, %dot ]
  %end = icmp uge i64 %i, %length
  br i1 %end, label %finishdigits, label %digitbody
digitbody:
  %p = getelementptr i8, ptr %data, i64 %i
  %c = load i8, ptr %p
  %d = sub i8 %c, 48
  %digit = icmp ult i8 %d, 10
  br i1 %digit, label %append, label %nondigit
append:
  %next = add i64 %i, 1
  br label %digits
nondigit:
  %isdecimal = icmp eq i8 %c, 46
  %notdecimal = xor i1 %decimal, true
  %candot = and i1 %isdecimal, %notdecimal
  br i1 %candot, label %dot, label %finishdigits
dot:
  %dotnext = add i64 %i, 1
  br label %digits
finishdigits:
  br i1 %seen, label %exponentcheck, label %error
exponentcheck:
  %hasnext = icmp ult i64 %i, %length
  br i1 %hasnext, label %exponentbyte, label %noexponent
exponentbyte:
  %expbytep = getelementptr i8, ptr %data, i64 %i
  %expbyte = load i8, ptr %expbytep
  %lower = or i8 %expbyte, 32
  %hasexp = icmp eq i8 %lower, 101
  br i1 %hasexp, label %exponentstart, label %noexponent
exponentstart:
  %es = add i64 %i, 1
  %missingexp = icmp uge i64 %es, %length
  br i1 %missingexp, label %error, label %exponentsign
exponentsign:
  %esp = getelementptr i8, ptr %data, i64 %es
  %esc = load i8, ptr %esp
  %enegative = icmp eq i8 %esc, 45
  %eplus = icmp eq i8 %esc, 43
  %esigned = or i1 %enegative, %eplus
  %eskip = zext i1 %esigned to i64
  %ebegin = add i64 %es, %eskip
  br label %exploop
exploop:
  %ei = phi i64 [ %ebegin, %exponentsign ], [ %einext, %expappend ]
  %eend = icmp uge i64 %ei, %length
  br i1 %eend, label %expend, label %expbody
expbody:
  %ep = getelementptr i8, ptr %data, i64 %ei
  %ec = load i8, ptr %ep
  %ed = sub i8 %ec, 48
  %edigit = icmp ult i8 %ed, 10
  br i1 %edigit, label %expappend, label %expend
expappend:
  %einext = add i64 %ei, 1
  br label %exploop
expend:
  %noexpdigits = icmp eq i64 %ei, %ebegin
  br i1 %noexpdigits, label %error, label %expvalid
expvalid:
  br label %calculate
noexponent:
  br label %calculate
calculate:
  %stop = phi i64 [ %i, %noexponent ], [ %ei, %expvalid ]
  %literal_length = sub i64 %stop, %start
  %lit_alloc = add i64 %literal_length, 1
  %literal = call ptr @j_alloc(i64 %lit_alloc)
  call void @j_copy(ptr %literal, ptr %sp, i64 %literal_length)
  %lit_end = getelementptr i8, ptr %literal, i64 %literal_length
  store i8 0, ptr %lit_end
  %fastraw = call { i64, i1 } @decimal_fast(ptr %data, i64 %start, i64 %stop)
  %fastbits = extractvalue { i64, i1 } %fastraw, 0
  %fastok = extractvalue { i64, i1 } %fastraw, 1
  br i1 %fastok, label %fastdone, label %slowparse
fastdone:
  %fastdouble = bitcast i64 %fastbits to double
  br label %havedouble
slowparse:
  %slowdouble = call double @j_decimal_to_double(ptr %literal)
  br label %havedouble
havedouble:
  %signednumber = phi double [ %fastdouble, %fastdone ], [ %slowdouble, %slowparse ]
  %v = call ptr @j_num(double %signednumber)
  %lp = getelementptr %V, ptr %v, i32 0, i32 6
  store ptr %literal, ptr %lp
  store i64 %stop, ptr %offset
  ret ptr %v
error:
  %quote = icmp eq i8 %first, 39
  %errmessage = select i1 %quote, ptr @error_string_literal, ptr @error_number
  call void @json_token_error(ptr %data, i64 %length, i64 %start, ptr %errmessage)
  ret ptr null
}

define internal double @decimal_binary64(ptr %data, i64 %begin, i64 %end, i32 %exponent) {
entry:
  br label %loop
loop:
  %i = phi i64 [ %begin, %entry ], [ %next, %skip ], [ %next, %retain ], [ %next, %discard ]
  %coefficient = phi i64 [ 0, %entry ], [ %coefficient, %skip ], [ %updated, %retain ], [ %coefficient, %discard ]
  %kept = phi i32 [ 0, %entry ], [ %kept, %skip ], [ %newkept, %retain ], [ %kept, %discard ]
  %dropped = phi i32 [ 0, %entry ], [ %dropped, %skip ], [ %dropped, %retain ], [ %newdropped, %discard ]
  %rounddigit = phi i8 [ 0, %entry ], [ %rounddigit, %skip ], [ %rounddigit, %retain ], [ %newrounddigit, %discard ]
  %sticky = phi i1 [ false, %entry ], [ %sticky, %skip ], [ %sticky, %retain ], [ %newsticky, %discard ]
  %done = icmp uge i64 %i, %end
  br i1 %done, label %round, label %body
body:
  %p = getelementptr i8, ptr %data, i64 %i
  %c = load i8, ptr %p
  %digit = sub i8 %c, 48
  %isnumber = icmp ult i8 %digit, 10
  %next = add i64 %i, 1
  %empty = icmp eq i32 %kept, 0
  %zero = icmp eq i8 %digit, 0
  %leadingzero = and i1 %empty, %zero
  %notnumber = xor i1 %isnumber, true
  %ignored = or i1 %notnumber, %leadingzero
  br i1 %ignored, label %skip, label %capacity
skip:
  br label %loop
capacity:
  %room = icmp ult i32 %kept, 19
  br i1 %room, label %retain, label %discard
retain:
  %d = zext i8 %digit to i64
  %times = mul i64 %coefficient, 10
  %updated = add i64 %times, %d
  %newkept = add i32 %kept, 1
  br label %loop
discard:
  %firstdiscard = icmp eq i32 %dropped, 0
  %newrounddigit = select i1 %firstdiscard, i8 %digit, i8 %rounddigit
  %notfirst = xor i1 %firstdiscard, true
  %nonzero = icmp ne i8 %digit, 0
  %laternonzero = and i1 %notfirst, %nonzero
  %newsticky = or i1 %sticky, %laternonzero
  %newdropped = add i32 %dropped, 1
  br label %loop
round:
  %abovehalf = icmp ugt i8 %rounddigit, 5
  %half = icmp eq i8 %rounddigit, 5
  %lowbit = and i64 %coefficient, 1
  %odd = icmp ne i64 %lowbit, 0
  %tailup = or i1 %sticky, %odd
  %halfup = and i1 %half, %tailup
  %roundup = or i1 %abovehalf, %halfup
  %increment = zext i1 %roundup to i64
  %rounded = add i64 %coefficient, %increment
  %effective = add i32 %exponent, %dropped
  %iszero = icmp eq i64 %rounded, 0
  br i1 %iszero, label %zeroresult, label %range
range:
  %overflow = icmp sgt i32 %effective, 308
  br i1 %overflow, label %infinity, label %underflowcheck
underflowcheck:
  %underflow = icmp slt i32 %effective, -343
  br i1 %underflow, label %zeroresult, label %convert
convert:
  %value = uitofp i64 %rounded to double
  %negative = icmp slt i32 %effective, 0
  br i1 %negative, label %scaledown, label %scaleup
scaleup:
  %upscale = call double @decimal_power(i32 %effective)
  %upvalue = fmul double %value, %upscale
  ret double %upvalue
scaledown:
  %magnitude = sub i32 0, %effective
  %split = icmp ugt i32 %magnitude, 308
  br i1 %split, label %splitscale, label %singlescale
singlescale:
  %downscale = call double @decimal_power(i32 %magnitude)
  %downvalue = fdiv double %value, %downscale
  ret double %downvalue
splitscale:
  %remaining = sub i32 %magnitude, 308
  %firstscale = call double @decimal_power(i32 %remaining)
  %intermediate = fdiv double %value, %firstscale
  %small = fdiv double %intermediate, 1.0e308
  ret double %small
zeroresult:
  ret double 0.0
infinity:
  ret double 0x7FF0000000000000
}

define internal double @decimal_power(i32 %exponent) {
entry:
  %large = icmp uge i32 %exponent, 256
  %after256 = sub i32 %exponent, 256
  %e128 = select i1 %large, i32 %after256, i32 %exponent
  %p256 = select i1 %large, double 1.0e256, double 1.0
  %has128 = icmp uge i32 %e128, 128
  %after128 = sub i32 %e128, 128
  %e64 = select i1 %has128, i32 %after128, i32 %e128
  %p128 = select i1 %has128, double 1.0e128, double 1.0
  %v128 = fmul double %p256, %p128
  %has64 = icmp uge i32 %e64, 64
  %after64 = sub i32 %e64, 64
  %e32 = select i1 %has64, i32 %after64, i32 %e64
  %p64 = select i1 %has64, double 1.0e64, double 1.0
  %v64 = fmul double %v128, %p64
  %has32 = icmp uge i32 %e32, 32
  %after32 = sub i32 %e32, 32
  %e16 = select i1 %has32, i32 %after32, i32 %e32
  %p32 = select i1 %has32, double 1.0e32, double 1.0
  %v32 = fmul double %v64, %p32
  %has16 = icmp uge i32 %e16, 16
  %after16 = sub i32 %e16, 16
  %e8 = select i1 %has16, i32 %after16, i32 %e16
  %p16 = select i1 %has16, double 1.0e16, double 1.0
  %v16 = fmul double %v32, %p16
  %has8 = icmp uge i32 %e8, 8
  %after8 = sub i32 %e8, 8
  %e4 = select i1 %has8, i32 %after8, i32 %e8
  %p8 = select i1 %has8, double 1.0e8, double 1.0
  %v8 = fmul double %v16, %p8
  %has4 = icmp uge i32 %e4, 4
  %after4 = sub i32 %e4, 4
  %e2 = select i1 %has4, i32 %after4, i32 %e4
  %p4 = select i1 %has4, double 1.0e4, double 1.0
  %v4 = fmul double %v8, %p4
  %has2 = icmp uge i32 %e2, 2
  %after2 = sub i32 %e2, 2
  %e1 = select i1 %has2, i32 %after2, i32 %e2
  %p2 = select i1 %has2, double 1.0e2, double 1.0
  %v2 = fmul double %v4, %p2
  %has1 = icmp ne i32 %e1, 0
  %p1 = select i1 %has1, double 1.0e1, double 1.0
  %value = fmul double %v2, %p1
  ret double %value
}

define internal ptr @parse_inner(ptr %data, i64 %length, ptr %offset) {
entry:
  %streammode = load i1, ptr @parse_stream_mode
  %old = load i64, ptr %offset
  %start = call i64 @json_space(ptr %data, i64 %length, i64 %old)
  store i64 %start, ptr %offset
  %end = icmp uge i64 %start, %length
  br i1 %end, label %eof, label %dispatch
dispatch:
  %p = getelementptr i8, ptr %data, i64 %start
  %c = load i8, ptr %p
  switch i8 %c, label %number [ i8 34, label %string i8 91, label %array i8 123, label %object i8 110, label %nullcheck i8 116, label %true i8 102, label %false i8 93, label %unmatchedarray i8 125, label %unmatchedobject ]
unmatchedarray:
  %uap = add i64 %start, 1
  %uamessage = call ptr @json_unmatched_message(i8 93)
  call void @j_json_error(ptr %data, i64 %length, i64 %uap, ptr %uamessage, i1 false)
  ret ptr null
unmatchedobject:
  %uop = add i64 %start, 1
  %uomessage = call ptr @json_unmatched_message(i8 125)
  call void @j_json_error(ptr %data, i64 %length, i64 %uop, ptr %uomessage, i1 false)
  ret ptr null
string:
  %sv = call ptr @json_string(ptr %data, i64 %length, ptr %offset)
  ret ptr %sv
number:
  %nv = call ptr @json_number(ptr %data, i64 %length, ptr %offset)
  ret ptr %nv
nullcheck:
  %nullnext = add i64 %start, 1
  %nullhas = icmp ult i64 %nullnext, %length
  br i1 %nullhas, label %nullread, label %number
nullread:
  %nullp = getelementptr i8, ptr %p, i64 1
  %nullc = load i8, ptr %nullp
  %isnull = icmp eq i8 %nullc, 117
  br i1 %isnull, label %null, label %number
null:
  br label %literal
true:
  br label %literal
false:
  br label %literal
nan:
  br label %literal
infinity:
  br label %literal
literal:
  %text = phi ptr [ @text_null, %null ], [ @text_true, %true ], [ @text_false, %false ], [ @text_nan, %nan ], [ @text_infinity, %infinity ]
  %width = phi i64 [ 4, %null ], [ 4, %true ], [ 5, %false ], [ 3, %nan ], [ 8, %infinity ]
  %litstop = add i64 %start, %width
  %short = icmp ugt i64 %litstop, %length
  br i1 %short, label %literalerror, label %literalcompare
literalcompare:
  %cmp = call i32 @bytes_cmp(ptr %p, i64 %width, ptr %text, i64 %width)
  %eq = icmp eq i32 %cmp, 0
  br i1 %eq, label %literalvalid, label %literalerror
literalerror:
  call void @json_token_error(ptr %data, i64 %length, i64 %start, ptr @error_literal)
  ret ptr null
literalvalid:
  store i64 %litstop, ptr %offset
  switch i8 %c, label %litnull [ i8 116, label %littrue i8 102, label %litfalse i8 78, label %litnan i8 73, label %litinfinity ]
litnull:
  ret ptr @value_null
littrue:
  ret ptr @value_true
litfalse:
  ret ptr @value_false
litnan:
  %nanv = call ptr @j_num(double 0x7FF8000000000000)
  ret ptr %nanv
litinfinity:
  %infv = call ptr @j_num(double 0x7FF0000000000000)
  ret ptr %infv
array:
  %a = call ptr @j_array()
  call void @json_path_begin(i1 false)
  %afirst = add i64 %start, 1
  %aspace = call i64 @json_space(ptr %data, i64 %length, i64 %afirst)
  store i64 %aspace, ptr %offset
  %aend = icmp uge i64 %aspace, %length
  br i1 %aend, label %unfinished, label %arraycheck
arraycheck:
  %acp = getelementptr i8, ptr %data, i64 %aspace
  %ac = load i8, ptr %acp
  %empty = icmp eq i8 %ac, 93
  br i1 %empty, label %arrayempty, label %arrayloop
arrayempty:
  %ae = add i64 %aspace, 1
  store i64 %ae, ptr %offset
  call void @json_path_pop()
  ret ptr %a
arrayloop:
  %indexp = getelementptr %V, ptr %a, i32 0, i32 3
  %arrayindex = load i64, ptr %indexp
  call void @json_path_index(i64 %arrayindex)
  %beforeitem = load i64, ptr %offset
  %itemstart = call i64 @json_space(ptr %data, i64 %length, i64 %beforeitem)
  store i64 %itemstart, ptr %offset
  %itemeof = icmp uge i64 %itemstart, %length
  br i1 %itemeof, label %unfinished, label %arrayitemcheck
arrayitemcheck:
  %itemp = getelementptr i8, ptr %data, i64 %itemstart
  %itemc = load i8, ptr %itemp
  %itemclose = icmp eq i8 %itemc, 93
  br i1 %itemclose, label %arrayelementerror, label %arrayitem
arrayelementerror:
  %afteritem = add i64 %itemstart, 1
  call void @j_json_error(ptr %data, i64 %length, i64 %afteritem, ptr @error_array_element, i1 false)
  ret ptr null
arrayitem:
  %item = call ptr @j_parse(ptr %data, i64 %length, ptr %offset)
  %afailed = icmp eq ptr %item, null
  br i1 %afailed, label %childfailure, label %arrayappend
arrayappend:
  call void @j_push(ptr %a, ptr %item)
  %apos = load i64, ptr %offset
  %anext = call i64 @json_space(ptr %data, i64 %length, i64 %apos)
  store i64 %anext, ptr %offset
  %ashort = icmp uge i64 %anext, %length
  br i1 %ashort, label %unfinished, label %arrayseparator
arrayseparator:
  %asp = getelementptr i8, ptr %data, i64 %anext
  %asep = load i8, ptr %asp
  %aftersep = add i64 %anext, 1
  store i64 %aftersep, ptr %offset
  switch i8 %asep, label %arrayseparatorerror [ i8 93, label %arraydone i8 44, label %arrayloop ]
arrayseparatorerror:
  call void @json_value_error(ptr %data, i64 %length, i64 %anext, ptr @error_separator)
  ret ptr null
arraydone:
  call void @json_path_pop()
  ret ptr %a
object:
  %obj = call ptr @j_object()
  call void @json_path_begin(i1 true)
  %ofirst = add i64 %start, 1
  %ospace = call i64 @json_space(ptr %data, i64 %length, i64 %ofirst)
  store i64 %ospace, ptr %offset
  %oend = icmp uge i64 %ospace, %length
  br i1 %oend, label %unfinished, label %objectcheck
objectcheck:
  %ocp = getelementptr i8, ptr %data, i64 %ospace
  %oc = load i8, ptr %ocp
  %oempty = icmp eq i8 %oc, 125
  br i1 %oempty, label %objectempty, label %objectloop
objectempty:
  %oe = add i64 %ospace, 1
  store i64 %oe, ptr %offset
  call void @json_path_pop()
  ret ptr %obj
objectloop:
  call void @json_path_set(ptr @value_null)
  %beforekey = load i64, ptr %offset
  %keystart = call i64 @json_space(ptr %data, i64 %length, i64 %beforekey)
  store i64 %keystart, ptr %offset
  %keyeof = icmp uge i64 %keystart, %length
  br i1 %keyeof, label %unfinished, label %objectkeycheck
objectkeycheck:
  %keyp = getelementptr i8, ptr %data, i64 %keystart
  %keyc = load i8, ptr %keyp
  %keyclose = icmp eq i8 %keyc, 125
  br i1 %keyclose, label %objectpairerror, label %objectkey
objectpairerror:
  %afterkey = add i64 %keystart, 1
  call void @j_json_error(ptr %data, i64 %length, i64 %afterkey, ptr @error_object_pair, i1 false)
  ret ptr null
objectkey:
  %keyarray = icmp eq i8 %keyc, 91
  %keyobject = icmp eq i8 %keyc, 123
  %keycontainer = or i1 %keyarray, %keyobject
  %badstreamkey = and i1 %streammode, %keycontainer
  br i1 %badstreamkey, label %streamkeyerror, label %objectkeyparse
streamkeyerror:
  %firstkey = icmp eq i64 %keystart, %ospace
  %arraykeymessage = select i1 %firstkey, ptr @error_stream_object_array, ptr @error_stream_comma_array
  %objectkeymessage = select i1 %firstkey, ptr @error_stream_object_object, ptr @error_stream_comma_object
  %keymessage = select i1 %keyarray, ptr %arraykeymessage, ptr %objectkeymessage
  %keyerrorpos = add i64 %keystart, 1
  call void @j_json_error(ptr %data, i64 %length, i64 %keyerrorpos, ptr %keymessage, i1 false)
  ret ptr null
objectkeyparse:
  %keyisquote = icmp eq i8 %keyc, 34
  br i1 %keyisquote, label %objectkeyfast, label %objectkeygeneral
objectkeyfast:
  %fastkey = call ptr @json_string(ptr %data, i64 %length, ptr %offset)
  %fkfailed = icmp eq ptr %fastkey, null
  br i1 %fkfailed, label %childfailure, label %colonspace
objectkeygeneral:
  %genkey = call ptr @j_parse(ptr %data, i64 %length, ptr %offset)
  %kfailed = icmp eq ptr %genkey, null
  br i1 %kfailed, label %childfailure, label %keycheck
keycheck:
  %kt = load i32, ptr %genkey
  %stringkey = icmp eq i32 %kt, 4
  br i1 %stringkey, label %colonspace, label %keytypeerror
keytypeerror:
  %badkeyend = load i64, ptr %offset
  %badkeycolon = call i64 @json_space(ptr %data, i64 %length, i64 %badkeyend)
  %badkeyafter = add i64 %badkeycolon, 1
  call void @j_json_error(ptr %data, i64 %length, i64 %badkeyafter, ptr @error_object_keys, i1 false)
  ret ptr null
colonspace:
  %key = phi ptr [ %fastkey, %objectkeyfast ], [ %genkey, %keycheck ]
  %kpos = load i64, ptr %offset
  %colonpos = call i64 @json_space(ptr %data, i64 %length, i64 %kpos)
  store i64 %colonpos, ptr %offset
  %colonshort = icmp uge i64 %colonpos, %length
  br i1 %colonshort, label %unfinished, label %coloncheck
coloncheck:
  %colonp = getelementptr i8, ptr %data, i64 %colonpos
  %colon = load i8, ptr %colonp
  %colonvalid = icmp eq i8 %colon, 58
  br i1 %colonvalid, label %objectvalue, label %colonerror
colonerror:
  %colondone = add i64 %colonpos, 1
  call void @j_json_error(ptr %data, i64 %length, i64 %colondone, ptr @error_object_parts, i1 false)
  ret ptr null
objectvalue:
  call void @json_path_set(ptr %key)
  %valuestart = add i64 %colonpos, 1
  store i64 %valuestart, ptr %offset
  %value = call ptr @j_parse(ptr %data, i64 %length, ptr %offset)
  %vfailed = icmp eq ptr %value, null
  br i1 %vfailed, label %childfailure, label %objectput
objectput:
  call void @j_put(ptr %obj, ptr %key, ptr %value)
  %vpos = load i64, ptr %offset
  %onext = call i64 @json_space(ptr %data, i64 %length, i64 %vpos)
  store i64 %onext, ptr %offset
  %oshort = icmp uge i64 %onext, %length
  br i1 %oshort, label %unfinished, label %objectseparator
objectseparator:
  %osp = getelementptr i8, ptr %data, i64 %onext
  %osep = load i8, ptr %osp
  %oaftersep = add i64 %onext, 1
  store i64 %oaftersep, ptr %offset
  switch i8 %osep, label %objectseparatorerror [ i8 125, label %objectdone i8 44, label %objectloop ]
objectseparatorerror:
  call void @json_value_error(ptr %data, i64 %length, i64 %onext, ptr @error_separator)
  ret ptr null
objectdone:
  call void @json_path_pop()
  ret ptr %obj
error:
  %errpos = load i64, ptr %offset
  %erreof = icmp uge i64 %errpos, %length
  call void @j_json_error(ptr %data, i64 %length, i64 %errpos, ptr @error_parse, i1 %erreof)
  ret ptr null
childfailure:
  %child_error = load ptr, ptr @j_error
  %child_haserror = icmp ne ptr %child_error, null
  br i1 %child_haserror, label %eof, label %unfinished
unfinished:
  store i64 %length, ptr %offset
  call void @j_json_error(ptr %data, i64 %length, i64 %length, ptr @error_unfinished_json, i1 true)
  ret ptr null
eof:
  ret ptr null
}

define internal void @json_value_error(ptr %data, i64 %length, i64 %position, ptr %message) {
entry:
  %p = getelementptr i8, ptr %data, i64 %position
  %c = load i8, ptr %p
  %quote = icmp eq i8 %c, 34
  br i1 %quote, label %string, label %token
string:
  call void @json_string_error(ptr %data, i64 %length, i64 %position, ptr %message)
  ret void
token:
  call void @json_token_error(ptr %data, i64 %length, i64 %position, ptr %message)
  ret void
}

define internal ptr @buffer_new() {
  %b = call ptr @j_alloc(i64 24)
  ret ptr %b
}

define ptr @j_buffer_new() {
  %b = call ptr @buffer_new()
  ret ptr %b
}

define void @j_buffer_append(ptr %b, ptr %data, i64 %length) {
  call void @buffer_append(ptr %b, ptr %data, i64 %length)
  ret void
}

define void @j_buffer_byte(ptr %b, i8 %c) {
  call void @buffer_byte(ptr %b, i8 %c)
  ret void
}

define ptr @j_buffer_value(ptr %b) {
  %v = call ptr @buffer_value(ptr %b)
  ret ptr %v
}

define internal void @buffer_append(ptr %b, ptr %data, i64 %length) {
entry:
  %lp = getelementptr %Buffer, ptr %b, i32 0, i32 1
  %cp = getelementptr %Buffer, ptr %b, i32 0, i32 2
  %oldlen = load i64, ptr %lp
  %cap = load i64, ptr %cp
  %newlen = add i64 %oldlen, %length
  %need = add i64 %newlen, 1
  %fits = icmp ule i64 %need, %cap
  br i1 %fits, label %copy, label %grow
grow:
  %double = mul i64 %cap, 2
  %small = icmp ult i64 %double, 256
  %minimum = select i1 %small, i64 256, i64 %double
  %big = icmp ugt i64 %need, %minimum
  %newcap = select i1 %big, i64 %need, i64 %minimum
  %newdata = call ptr @j_alloc(i64 %newcap)
  %olddata = load ptr, ptr %b
  call void @j_copy(ptr %newdata, ptr %olddata, i64 %oldlen)
  store ptr %newdata, ptr %b
  store i64 %newcap, ptr %cp
  br label %copy
copy:
  %dest = load ptr, ptr %b
  %out = getelementptr i8, ptr %dest, i64 %oldlen
  call void @j_copy(ptr %out, ptr %data, i64 %length)
  store i64 %newlen, ptr %lp
  %end = getelementptr i8, ptr %dest, i64 %newlen
  store i8 0, ptr %end
  ret void
}

define internal void @buffer_byte(ptr %b, i8 %c) {
entry:
  %lp0 = getelementptr %Buffer, ptr %b, i32 0, i32 1
  %cp0 = getelementptr %Buffer, ptr %b, i32 0, i32 2
  %oldlen = load i64, ptr %lp0
  %cap = load i64, ptr %cp0
  %need = add i64 %oldlen, 2
  %fits = icmp ule i64 %need, %cap
  br i1 %fits, label %fast, label %slow
fast:
  %dest = load ptr, ptr %b
  %out = getelementptr i8, ptr %dest, i64 %oldlen
  store i8 %c, ptr %out
  %newlen = add i64 %oldlen, 1
  store i64 %newlen, ptr %lp0
  %end = getelementptr i8, ptr %dest, i64 %newlen
  store i8 0, ptr %end
  ret void
slow:
  %p = alloca i8
  store i8 %c, ptr %p
  call void @buffer_append(ptr %b, ptr %p, i64 1)
  ret void
}

; Finalizes %b into an immutable JSON string by transferring ownership of its
; NUL-terminated backing storage and resetting %b so subsequent writes cannot
; alias the returned value.
define internal ptr @buffer_value(ptr %b) {
  %lp = getelementptr %Buffer, ptr %b, i32 0, i32 1
  %cp = getelementptr %Buffer, ptr %b, i32 0, i32 2
  %len = load i64, ptr %lp
  %data = load ptr, ptr %b
  %v = call ptr @j_alloc(i64 48)
  store i32 4, ptr %v
  %lpv = getelementptr %V, ptr %v, i32 0, i32 3
  store i64 %len, ptr %lpv
  %dpv = getelementptr %V, ptr %v, i32 0, i32 5
  %empty = icmp eq ptr %data, null
  br i1 %empty, label %fresh, label %wrap
fresh:
  %one = call ptr @j_alloc(i64 1)
  store i8 0, ptr %one
  store ptr %one, ptr %dpv
  ret ptr %v
wrap:
  store ptr %data, ptr %dpv
  store ptr null, ptr %b
  store i64 0, ptr %lp
  store i64 0, ptr %cp
  ret ptr %v
}

define internal void @buffer_uint(ptr %b, i64 %n) {
entry:
  %digits = alloca [24 x i8]
  %out = alloca [20 x i8]
  br label %loop
loop:
  %v = phi i64 [ %n, %entry ], [ %quotient, %loop ]
  %len = phi i64 [ 0, %entry ], [ %next, %loop ]
  %remainder = urem i64 %v, 10
  %digit = trunc i64 %remainder to i8
  %ascii = add i8 %digit, 48
  %dp = getelementptr i8, ptr %digits, i64 %len
  store i8 %ascii, ptr %dp
  %quotient = udiv i64 %v, 10
  %next = add i64 %len, 1
  %done = icmp eq i64 %quotient, 0
  br i1 %done, label %reverse, label %loop
reverse:
  %i = phi i64 [ %next, %loop ], [ %previous, %body ]
  %outslot = phi i64 [ 0, %loop ], [ %outnext, %body ]
  %end = icmp eq i64 %i, 0
  br i1 %end, label %finish, label %body
body:
  %previous = sub i64 %i, 1
  %p = getelementptr i8, ptr %digits, i64 %previous
  %c = load i8, ptr %p
  %op = getelementptr i8, ptr %out, i64 %outslot
  store i8 %c, ptr %op
  %outnext = add i64 %outslot, 1
  br label %reverse
finish:
  call void @buffer_append(ptr %b, ptr %out, i64 %outslot)
  ret void
}

define internal i32 @decimal_coefficient(ptr %digits, i64 %mantissa, i32 %binary_exponent) {
entry:
  br label %initial
initial:
  %m = phi i64 [ %mantissa, %entry ], [ %q, %initial ]
  %len = phi i32 [ 0, %entry ], [ %ln, %initial ]
  %r = urem i64 %m, 10
  %digit = trunc i64 %r to i8
  %dp = getelementptr i8, ptr %digits, i32 %len
  store i8 %digit, ptr %dp
  %q = udiv i64 %m, 10
  %ln = add i32 %len, 1
  %initialdone = icmp eq i64 %q, 0
  br i1 %initialdone, label %setup, label %initial
setup:
  %negative = icmp slt i32 %binary_exponent, 0
  %negated = sub i32 0, %binary_exponent
  %steps = select i1 %negative, i32 %negated, i32 %binary_exponent
  %factor = select i1 %negative, i32 5, i32 2
  br label %outer
outer:
  %step = phi i32 [ 0, %setup ], [ %sn, %carrydone ]
  %length = phi i32 [ %ln, %setup ], [ %newlen, %carrydone ]
  %done = icmp eq i32 %step, %steps
  br i1 %done, label %finish, label %multiply
multiply:
  %i = phi i32 [ 0, %outer ], [ %in, %body ]
  %carry = phi i32 [ 0, %outer ], [ %newcarry, %body ]
  %end = icmp eq i32 %i, %length
  br i1 %end, label %carrycheck, label %body
body:
  %p = getelementptr i8, ptr %digits, i32 %i
  %d8 = load i8, ptr %p
  %d = zext i8 %d8 to i32
  %product = mul i32 %d, %factor
  %sum = add i32 %product, %carry
  %newdigit = urem i32 %sum, 10
  %newcarry = udiv i32 %sum, 10
  %out = trunc i32 %newdigit to i8
  store i8 %out, ptr %p
  %in = add i32 %i, 1
  br label %multiply
carrycheck:
  %hascarry = icmp ne i32 %carry, 0
  br i1 %hascarry, label %carryappend, label %carrydone
carryappend:
  %endp = getelementptr i8, ptr %digits, i32 %length
  %lastdigit = trunc i32 %carry to i8
  store i8 %lastdigit, ptr %endp
  %morelen = add i32 %length, 1
  br label %carrydone
carrydone:
  %newlen = phi i32 [ %length, %carrycheck ], [ %morelen, %carryappend ]
  %sn = add i32 %step, 1
  br label %outer
finish:
  ret i32 %length
}

; Compare a normalized decimal with an exact binary coefficient. Binary
; digits are little-endian base ten; decimal input digits are ASCII forward.
define internal i32 @decimal_compare_digits(ptr %parts, ptr %binarydigits, i64 %binarylength, i64 %binaryposition) {
entry:
  %positionp = getelementptr %Decimal, ptr %parts, i32 0, i32 3
  %position = load i64, ptr %positionp
  %sameposition = icmp eq i64 %position, %binaryposition
  br i1 %sameposition, label %digits, label %positionorder
positionorder:
  %lessposition = icmp slt i64 %position, %binaryposition
  %positionresult = select i1 %lessposition, i32 -1, i32 1
  ret i32 %positionresult
digits:
  %lengthp = getelementptr %Decimal, ptr %parts, i32 0, i32 2
  %datap = getelementptr %Decimal, ptr %parts, i32 0, i32 4
  %length = load i64, ptr %lengthp
  %data = load ptr, ptr %datap
  %longer = icmp ugt i64 %length, %binarylength
  %count = select i1 %longer, i64 %length, i64 %binarylength
  br label %loop
loop:
  %i = phi i64 [ 0, %digits ], [ %next, %equalbyte ]
  %done = icmp eq i64 %i, %count
  br i1 %done, label %equal, label %leftcheck
leftcheck:
  %hasleft = icmp ult i64 %i, %length
  br i1 %hasleft, label %left, label %leftzero
left:
  %lp = getelementptr i8, ptr %data, i64 %i
  %ascii = load i8, ptr %lp
  %digit = sub i8 %ascii, 48
  br label %rightcheck
leftzero:
  br label %rightcheck
rightcheck:
  %a = phi i8 [ %digit, %left ], [ 0, %leftzero ]
  %hasright = icmp ult i64 %i, %binarylength
  br i1 %hasright, label %right, label %rightzero
right:
  %reverse = sub i64 %binarylength, %i
  %index = sub i64 %reverse, 1
  %rp = getelementptr i8, ptr %binarydigits, i64 %index
  %binarydigit = load i8, ptr %rp
  br label %compare
rightzero:
  br label %compare
compare:
  %b = phi i8 [ %binarydigit, %right ], [ 0, %rightzero ]
  %same = icmp eq i8 %a, %b
  br i1 %same, label %equalbyte, label %different
equalbyte:
  %next = add i64 %i, 1
  br label %loop
different:
  %less = icmp ult i8 %a, %b
  %result = select i1 %less, i32 -1, i32 1
  ret i32 %result
equal:
  ret i32 0
}

; The upper boundary of binary64 x is (2*m+1)*2^(e-1). This expression
; also describes the zero/subnormal boundary and the overflow threshold.
define internal i32 @decimal_upper(ptr %digits, ptr %positionout, i64 %bits) {
entry:
  %fraction = and i64 %bits, 4503599627370495
  %encoded64 = lshr i64 %bits, 52
  %encoded = trunc i64 %encoded64 to i32
  %subnormal = icmp eq i32 %encoded, 0
  %normalized = or i64 %fraction, 4503599627370496
  %mantissa = select i1 %subnormal, i64 %fraction, i64 %normalized
  %normalexponent = sub i32 %encoded, 1075
  %exponent = select i1 %subnormal, i32 -1074, i32 %normalexponent
  %twice = shl i64 %mantissa, 1
  %middle = add i64 %twice, 1
  %middleexponent = sub i32 %exponent, 1
  %length = call i32 @decimal_coefficient(ptr %digits, i64 %middle, i32 %middleexponent)
  %negative = icmp slt i32 %middleexponent, 0
  %decimalexponent = select i1 %negative, i32 %middleexponent, i32 0
  %position32 = add i32 %length, %decimalexponent
  %position = sext i32 %position32 to i64
  store i64 %position, ptr %positionout
  ret i32 %length
}

define internal i32 @decimal_compare_upper(ptr %parts, i64 %bits) noinline {
entry:
  %digits = alloca [1100 x i8]
  %positionout = alloca i64
  %length32 = call i32 @decimal_upper(ptr %digits, ptr %positionout, i64 %bits)
  %length = zext i32 %length32 to i64
  %position = load i64, ptr %positionout
  %result = call i32 @decimal_compare_digits(ptr %parts, ptr %digits, i64 %length, i64 %position)
  ret i32 %result
}

@decimal_fast_hi = private unnamed_addr constant [651 x i64] [
i64 17218479456385750618, i64 10761549660241094136, i64 13451937075301367670, i64 16814921344126709587,
    i64 10509325840079193492, i64 13136657300098991865, i64 16420821625123739831, i64 10263013515702337394,
    i64 12828766894627921743, i64 16035958618284902179, i64 10022474136428063862, i64 12528092670535079827,
    i64 15660115838168849784, i64 9787572398855531115, i64 12234465498569413894, i64 15293081873211767368,
    i64 9558176170757354605, i64 11947720213446693256, i64 14934650266808366570, i64 9334156416755229106,
    i64 11667695520944036383, i64 14584619401180045478, i64 18230774251475056848, i64 11394233907171910530,
    i64 14242792383964888162, i64 17803490479956110203, i64 11127181549972568877, i64 13908976937465711096,
    i64 17386221171832138870, i64 10866388232395086794, i64 13582985290493858492, i64 16978731613117323115,
    i64 10611707258198326947, i64 13264634072747908684, i64 16580792590934885855, i64 10362995369334303659,
    i64 12953744211667879574, i64 16192180264584849468, i64 10120112665365530917, i64 12650140831706913647,
    i64 15812676039633642058, i64 9882922524771026286, i64 12353653155963782858, i64 15442066444954728573,
    i64 9651291528096705358, i64 12064114410120881697, i64 15080143012651102122, i64 9425089382906938826,
    i64 11781361728633673532, i64 14726702160792091916, i64 18408377700990114895, i64 11505236063118821809,
    i64 14381545078898527261, i64 17976931348623159077, i64 11235582092889474423, i64 14044477616111843029,
    i64 17555597020139803786, i64 10972248137587377366, i64 13715310171984221708, i64 17144137714980277135,
    i64 10715086071862673209, i64 13393857589828341511, i64 16742321987285426889, i64 10463951242053391806,
    i64 13079939052566739757, i64 16349923815708424697, i64 10218702384817765435, i64 12773377981022206794,
    i64 15966722476277758493, i64 9979201547673599058, i64 12474001934591998822, i64 15592502418239998528,
    i64 9745314011399999080, i64 12181642514249998850, i64 15227053142812498563, i64 9516908214257811601,
    i64 11896135267822264502, i64 14870169084777830627, i64 9293855677986144142, i64 11617319597482680178,
    i64 14521649496853350222, i64 18152061871066687778, i64 11345038669416679861, i64 14181298336770849826,
    i64 17726622920963562283, i64 11079139325602226427, i64 13848924157002783033, i64 17311155196253478792,
    i64 10819471997658424245, i64 13524339997073030306, i64 16905424996341287883, i64 10565890622713304927,
    i64 13207363278391631158, i64 16509204097989538948, i64 10318252561243461842, i64 12897815701554327303,
    i64 16122269626942909129, i64 10076418516839318205, i64 12595523146049147757, i64 15744403932561434696,
    i64 9840252457850896685, i64 12300315572313620856, i64 15375394465392026070, i64 9609621540870016294,
    i64 12012026926087520367, i64 15015033657609400459, i64 9384396036005875287, i64 11730495045007344109,
    i64 14663118806259180136, i64 18328898507823975170, i64 11455561567389984481, i64 14319451959237480602,
    i64 17899314949046850752, i64 11187071843154281720, i64 13983839803942852150, i64 17479799754928565188,
    i64 10924874846830353242, i64 13656093558537941553, i64 17070116948172426941, i64 10668823092607766838,
    i64 13336028865759708548, i64 16670036082199635685, i64 10418772551374772303, i64 13023465689218465379,
    i64 16279332111523081723, i64 10174582569701926077, i64 12718228212127407596, i64 15897785265159259495,
    i64 9936115790724537184, i64 12420144738405671481, i64 15525180923007089351, i64 9703238076879430844,
    i64 12129047596099288555, i64 15161309495124110694, i64 9475818434452569184, i64 11844773043065711480,
    i64 14805966303832139350, i64 9253728939895087094, i64 11567161174868858867, i64 14458951468586073584,
    i64 18073689335732591980, i64 11296055834832869987, i64 14120069793541087484, i64 17650087241926359355,
    i64 11031304526203974597, i64 13789130657754968246, i64 17236413322193710308, i64 10772758326371068942,
    i64 13465947907963836178, i64 16832434884954795223, i64 10520271803096747014, i64 13150339753870933768,
    i64 16437924692338667210, i64 10273702932711667006, i64 12842128665889583757, i64 16052660832361979697,
    i64 10032913020226237310, i64 12541141275282796638, i64 15676426594103495798, i64 9797766621314684873,
    i64 12247208276643356092, i64 15309010345804195115, i64 9568131466127621947, i64 11960164332659527433,
    i64 14950205415824409292, i64 9343878384890255807, i64 11679847981112819759, i64 14599809976391024699,
    i64 18249762470488780874, i64 11406101544055488046, i64 14257626930069360058, i64 17822033662586700072,
    i64 11138771039116687545, i64 13923463798895859431, i64 17404329748619824289, i64 10877706092887390181,
    i64 13597132616109237726, i64 16996415770136547158, i64 10622759856335341973, i64 13278449820419177467,
    i64 16598062275523971834, i64 10373788922202482396, i64 12967236152753102995, i64 16209045190941378744,
    i64 10130653244338361715, i64 12663316555422952143, i64 15829145694278690179, i64 9893216058924181362,
    i64 12366520073655226703, i64 15458150092069033378, i64 9661343807543145861, i64 12076679759428932327,
    i64 15095849699286165408, i64 9434906062053853380, i64 11793632577567316725, i64 14742040721959145907,
    i64 18427550902448932383, i64 11517219314030582739, i64 14396524142538228424, i64 17995655178172785531,
    i64 11247284486357990957, i64 14059105607947488696, i64 17573882009934360870, i64 10983676256208975543,
    i64 13729595320261219429, i64 17161994150326524287, i64 10726246343954077679, i64 13407807929942597099,
    i64 16759759912428246374, i64 10474849945267653984, i64 13093562431584567480, i64 16366953039480709350,
    i64 10229345649675443343, i64 12786682062094304179, i64 15983352577617880224, i64 9989595361011175140,
    i64 12486994201263968925, i64 15608742751579961156, i64 9755464219737475723, i64 12194330274671844653,
    i64 15242912843339805817, i64 9526820527087378635, i64 11908525658859223294, i64 14885657073574029118,
    i64 9303535670983768199, i64 11629419588729710248, i64 14536774485912137810, i64 18170968107390172263,
    i64 11356855067118857664, i64 14196068833898572081, i64 17745086042373215101, i64 11090678776483259438,
    i64 13863348470604074297, i64 17329185588255092872, i64 10830740992659433045, i64 13538426240824291306,
    i64 16923032801030364133, i64 10576895500643977583, i64 13221119375804971979, i64 16526399219756214973,
    i64 10328999512347634358, i64 12911249390434542948, i64 16139061738043178685, i64 10086913586276986678,
    i64 12608641982846233347, i64 15760802478557791684, i64 9850501549098619803, i64 12313126936373274753,
    i64 15391408670466593442, i64 9619630419041620901, i64 12024538023802026126, i64 15030672529752532658,
    i64 9394170331095332911, i64 11742712913869166139, i64 14678391142336457674, i64 18347988927920572092,
    i64 11467493079950357558, i64 14334366349937946947, i64 17917957937422433684, i64 11198723710889021052,
    i64 13998404638611276315, i64 17498005798264095394, i64 10936253623915059621, i64 13670317029893824527,
    i64 17087896287367280659, i64 10679935179604550411, i64 13349918974505688014, i64 16687398718132110018,
    i64 10429624198832568761, i64 13037030248540710952, i64 16296287810675888690, i64 10185179881672430431,
    i64 12731474852090538039, i64 15914343565113172548, i64 9946464728195732843, i64 12433080910244666053,
    i64 15541351137805832567, i64 9713344461128645354, i64 12141680576410806693, i64 15177100720513508366,
    i64 9485687950320942729, i64 11857109937901178411, i64 14821387422376473014, i64 9263367138985295633,
    i64 11579208923731619542, i64 14474011154664524427, i64 18092513943330655534, i64 11307821214581659709,
    i64 14134776518227074636, i64 17668470647783843295, i64 11042794154864902059, i64 13803492693581127574,
    i64 17254365866976409468, i64 10783978666860255917, i64 13479973333575319897, i64 16849966666969149871,
    i64 10531229166855718669, i64 13164036458569648337, i64 16455045573212060421, i64 10284403483257537763,
    i64 12855504354071922204, i64 16069380442589902755, i64 10043362776618689222, i64 12554203470773361527,
    i64 15692754338466701909, i64 9807971461541688693, i64 12259964326927110866, i64 15324955408658888583,
    i64 9578097130411805364, i64 11972621413014756705, i64 14965776766268445882, i64 9353610478917778676,
    i64 11692013098647223345, i64 14615016373309029182, i64 18268770466636286477, i64 11417981541647679048,
    i64 14272476927059598810, i64 17840596158824498513, i64 11150372599265311570, i64 13937965749081639463,
    i64 17422457186352049329, i64 10889035741470030830, i64 13611294676837538538, i64 17014118346046923173,
    i64 10633823966279326983, i64 13292279957849158729, i64 16615349947311448411, i64 10384593717069655257,
    i64 12980742146337069071, i64 16225927682921336339, i64 10141204801825835211, i64 12676506002282294014,
    i64 15845632502852867518, i64 9903520314283042199, i64 12379400392853802748, i64 15474250491067253436,
    i64 9671406556917033397, i64 12089258196146291747, i64 15111572745182864683, i64 9444732965739290427,
    i64 11805916207174113034, i64 14757395258967641292, i64 9223372036854775808, i64 11529215046068469760,
    i64 14411518807585587200, i64 18014398509481984000, i64 11258999068426240000, i64 14073748835532800000,
    i64 17592186044416000000, i64 10995116277760000000, i64 13743895347200000000, i64 17179869184000000000,
    i64 10737418240000000000, i64 13421772800000000000, i64 16777216000000000000, i64 10485760000000000000,
    i64 13107200000000000000, i64 16384000000000000000, i64 10240000000000000000, i64 12800000000000000000,
    i64 16000000000000000000, i64 10000000000000000000, i64 12500000000000000000, i64 15625000000000000000,
    i64 9765625000000000000, i64 12207031250000000000, i64 15258789062500000000, i64 9536743164062500000,
    i64 11920928955078125000, i64 14901161193847656250, i64 9313225746154785156, i64 11641532182693481445,
    i64 14551915228366851806, i64 18189894035458564758, i64 11368683772161602973, i64 14210854715202003717,
    i64 17763568394002504646, i64 11102230246251565404, i64 13877787807814456755, i64 17347234759768070944,
    i64 10842021724855044340, i64 13552527156068805425, i64 16940658945086006781, i64 10587911840678754238,
    i64 13234889800848442797, i64 16543612251060553497, i64 10339757656912845935, i64 12924697071141057419,
    i64 16155871338926321774, i64 10097419586828951109, i64 12621774483536188886, i64 15777218104420236108,
    i64 9860761315262647567, i64 12325951644078309459, i64 15407439555097886824, i64 9629649721936179265,
    i64 12037062152420224081, i64 15046327690525280101, i64 9403954806578300063, i64 11754943508222875079,
    i64 14693679385278593849, i64 18367099231598242312, i64 11479437019748901445, i64 14349296274686126806,
    i64 17936620343357658507, i64 11210387714598536567, i64 14012984643248170709, i64 17516230804060213386,
    i64 10947644252537633366, i64 13684555315672041708, i64 17105694144590052135, i64 10691058840368782584,
    i64 13363823550460978230, i64 16704779438076222788, i64 10440487148797639242, i64 13050608935997049053,
    i64 16313261169996311316, i64 10195788231247694572, i64 12744735289059618216, i64 15930919111324522770,
    i64 9956824444577826731, i64 12446030555722283414, i64 15557538194652854267, i64 9723461371658033917,
    i64 12154326714572542396, i64 15192908393215677995, i64 9495567745759798747, i64 11869459682199748434,
    i64 14836824602749685542, i64 9273015376718553464, i64 11591269220898191830, i64 14489086526122739788,
    i64 18111358157653424735, i64 11319598848533390459, i64 14149498560666738074, i64 17686873200833422592,
    i64 11054295750520889120, i64 13817869688151111400, i64 17272337110188889250, i64 10795210693868055781,
    i64 13494013367335069727, i64 16867516709168837158, i64 10542197943230523224, i64 13177747429038154030,
    i64 16472184286297692538, i64 10295115178936057836, i64 12868893973670072295, i64 16086117467087590369,
    i64 10053823416929743980, i64 12567279271162179975, i64 15709099088952724969, i64 9818186930595453106,
    i64 12272733663244316382, i64 15340917079055395478, i64 9588073174409622174, i64 11985091468012027717,
    i64 14981364335015034646, i64 9363352709384396654, i64 11704190886730495817, i64 14630238608413119772,
    i64 18287798260516399715, i64 11429873912822749822, i64 14287342391028437277, i64 17859177988785546597,
    i64 11161986242990966623, i64 13952482803738708279, i64 17440603504673385348, i64 10900377190420865842,
    i64 13625471488026082303, i64 17031839360032602879, i64 10644899600020376799, i64 13306124500025470999,
    i64 16632655625031838749, i64 10395409765644899218, i64 12994262207056124023, i64 16242827758820155028,
    i64 10151767349262596893, i64 12689709186578246116, i64 15862136483222807645, i64 9913835302014254778,
    i64 12392294127517818473, i64 15490367659397273091, i64 9681479787123295682, i64 12101849733904119602,
    i64 15127312167380149503, i64 9454570104612593439, i64 11818212630765741799, i64 14772765788457177249,
    i64 9232978617785735780, i64 11541223272232169725, i64 14426529090290212157, i64 18033161362862765196,
    i64 11270725851789228247, i64 14088407314736535309, i64 17610509143420669137, i64 11006568214637918210,
    i64 13758210268297397763, i64 17197762835371747204, i64 10748601772107342002, i64 13435752215134177503,
    i64 16794690268917721879, i64 10496681418073576174, i64 13120851772591970218, i64 16401064715739962772,
    i64 10250665447337476733, i64 12813331809171845916, i64 16016664761464807395, i64 10010415475915504622,
    i64 12513019344894380777, i64 15641274181117975972, i64 9775796363198734982, i64 12219745453998418728,
    i64 15274681817498023410, i64 9546676135936264631, i64 11933345169920330789, i64 14916681462400413486,
    i64 9322925914000258429, i64 11653657392500323036, i64 14567071740625403795, i64 18208839675781754744,
    i64 11380524797363596715, i64 14225655996704495894, i64 17782069995880619867, i64 11113793747425387417,
    i64 13892242184281734271, i64 17365302730352167839, i64 10853314206470104899, i64 13566642758087631124,
    i64 16958303447609538905, i64 10598939654755961816, i64 13248674568444952270, i64 16560843210556190337,
    i64 10350527006597618960, i64 12938158758247023701, i64 16172698447808779626, i64 10107936529880487266,
    i64 12634920662350609083, i64 15793650827938261354, i64 9871031767461413346, i64 12338789709326766682,
    i64 15423487136658458353, i64 9639679460411536470, i64 12049599325514420588, i64 15061999156893025735,
    i64 9413749473058141084, i64 11767186841322676356, i64 14708983551653345445, i64 18386229439566681806,
    i64 11491393399729176129, i64 14364241749661470161, i64 17955302187076837701, i64 11222063866923023563,
    i64 14027579833653779454, i64 17534474792067224318, i64 10959046745042015198, i64 13698808431302518998,
    i64 17123510539128148748, i64 10702194086955092967, i64 13377742608693866209, i64 16722178260867332761,
    i64 10451361413042082976, i64 13064201766302603720, i64 16330252207878254650, i64 10206407629923909156,
    i64 12758009537404886445, i64 15947511921756108056, i64 9967194951097567535, i64 12458993688871959419,
    i64 15573742111089949274, i64 9733588819431218296, i64 12166986024289022870, i64 15208732530361278588,
    i64 9505457831475799117, i64 11881822289344748896, i64 14852277861680936121, i64 9282673663550585075,
    i64 11603342079438231344, i64 14504177599297789180, i64 18130221999122236476, i64 11331388749451397797,
    i64 14164235936814247246, i64 17705294921017809058, i64 11065809325636130661, i64 13832261657045163327,
    i64 17290327071306454158, i64 10806454419566533849, i64 13508068024458167311, i64 16885085030572709139,
    i64 10553178144107943212, i64 13191472680134929015, i64 16489340850168661269, i64 10305838031355413293,
    i64 12882297539194266616, i64 16102871923992833270, i64 10064294952495520794, i64 12580368690619400992,
    i64 15725460863274251240, i64 9828413039546407025, i64 12285516299433008781, i64 15356895374291260977,
    i64 9598059608932038110, i64 11997574511165047638, i64 14996968138956309548, i64 9373105086847693467,
    i64 11716381358559616834, i64 14645476698199521043, i64 18306845872749401303, i64 11441778670468375814,
    i64 14302223338085469768, i64 17877779172606837210, i64 11173611982879273256, i64 13967014978599091570,
    i64 17458768723248864463, i64 10911730452030540289, i64 13639663065038175362, i64 17049578831297719202,
    i64 10655986769561074501, i64 13319983461951343127, i64 16649979327439178909, i64 10406237079649486818,
    i64 13007796349561858522, i64 16259745436952323153, i64 10162340898095201970, i64 12702926122619002463,
    i64 15878657653273753079, i64 9924161033296095674, i64 12405201291620119593, i64 15506501614525149491,
    i64 9691563509078218432, i64 12114454386347773040, i64 15143067982934716300, i64 9464417489334197687,
    i64 11830521861667747109, i64 14788152327084683887, i64 9242595204427927429, i64 11553244005534909286,
    i64 14441555006918636608, i64 18051943758648295760, i64 11282464849155184850, i64 14103081061443981063,
    i64 17628851326804976328, i64 11018032079253110205, i64 13772540099066387756, i64 17215675123832984696,
    i64 10759796952395615435, i64 13449746190494519293, i64 16812182738118149117, i64 10507614211323843198,
    i64 13134517764154803997, i64 16418147205193504997, i64 10261342003245940623
]

@decimal_fast_lo = private unnamed_addr constant [651 x i64] [
i64 1242899115359157055, i64 5388497965526861063, i64 6735622456908576329, i64 17642900107990496220,
    i64 8720969558280366185, i64 10901211947850457732, i64 18238200953240460069, i64 18316404623416369399,
    i64 13672133742415685941, i64 12478481159592219522, i64 5493207715531443249, i64 16089881681269079869,
    i64 15500666083158961933, i64 9687916301974351208, i64 7498209359040551106, i64 149389661945913074,
    i64 93368538716195671, i64 4728396691822632493, i64 5910495864778290617, i64 8305745933913819539,
    i64 1158810380537498616, i64 15283571030954036982, i64 9881091751837770420, i64 6175682344898606512,
    i64 16942974967978033949, i64 11955346673117766628, i64 5166248661484910190, i64 11069496845283525642,
    i64 13836871056604407053, i64 4036358391950366504, i64 14268820026792733938, i64 17836025033490917422,
    i64 8841672636718129437, i64 6440404777470273892, i64 8050505971837842365, i64 11949095260039733334,
    i64 10324683056622278764, i64 3682481783923072647, i64 11524923151806696212, i64 571095884476206553,
    i64 14548927910877421904, i64 13704765962725776594, i64 7907585416552444934, i64 661109733835780360,
    i64 2719036592861056677, i64 12622167777931096654, i64 1942651667131707105, i64 5825843310384704845,
    i64 16505676174835656864, i64 2185351144835019464, i64 2731688931043774330, i64 8624834609543440812,
    i64 15392729280356688919, i64 5405853545163697437, i64 5684501474941004850, i64 2493940825248868159,
    i64 7729112049988473103, i64 9442381049670183593, i64 2579604275232953683, i64 3224505344041192104,
    i64 8932844867666826921, i64 15777742103010921555, i64 15110491610336264040, i64 2526528228819083169,
    i64 12381532322878629770, i64 1641857348316123500, i64 12555375888766046947, i64 11082533842530170780,
    i64 4629795266307937667, i64 5199465050656154994, i64 15722703350174969551, i64 10430007150863936130,
    i64 6518754469289960081, i64 8148443086612450102, i64 962181821410786819, i64 16742264702877599426,
    i64 7092772823314835570, i64 18089338065998320271, i64 8999993282035256217, i64 2026619565689294464,
    i64 11756646493966393888, i64 5472436080603216552, i64 8031958568804398249, i64 14651634229432885715,
    i64 9091170749936331336, i64 3376138709496513133, i64 18055231442152805128, i64 8733981247408842698,
    i64 5458738279630526686, i64 11435108867965546262, i64 5070514048102157020, i64 863228270850154185,
    i64 14914093393844856443, i64 9419244705451294746, i64 15110399977761835024, i64 9664627935347517973,
    i64 7469098900757009562, i64 16197401859041600736, i64 6411694268519837208, i64 12626303854077184414,
    i64 7891439908798240259, i64 14475985904425188227, i64 18094982380531485284, i64 6697677969404790399,
    i64 17595469498610763806, i64 17382650854836066854, i64 8558313775058847832, i64 6086206200396171886,
    i64 12219443768922602761, i64 15274304711153253452, i64 14158126462898171311, i64 3862600023340550427,
    i64 14051622066030463842, i64 8782263791269039901, i64 10977829739086299876, i64 4498915137003099037,
    i64 12035193997481712706, i64 5820620459997365075, i64 11887461593424094248, i64 9735506505103752857,
    i64 2946011094524915263, i64 3682513868156144079, i64 4607414176811284001, i64 1147581702586717097,
    i64 15269535183515560084, i64 7237616480483531100, i64 13658706619031801779, i64 17073383273789752224,
    i64 17588393573759676996, i64 3538747893490044629, i64 9035120885289943691, i64 12564479580947296663,
    i64 15705599476184120828, i64 15020313326802763131, i64 4776009810824339053, i64 5970012263530423816,
    i64 7462515329413029771, i64 52386062455755702, i64 9288854614924470436, i64 6999382250228200141,
    i64 8749227812785250177, i64 14691639419845557168, i64 13752863256379558556, i64 17191079070474448196,
    i64 8438581409832836170, i64 15159912780718433117, i64 9726518939043265588, i64 15302446373756816800,
    i64 9904685930341245193, i64 3157485376071780683, i64 8890957387685944783, i64 1890324697752655170,
    i64 2362905872190818963, i64 6088502188546649756, i64 16833999772538088003, i64 7207441660390446292,
    i64 16033866083812498692, i64 10818960567910847557, i64 4300328673033783639, i64 16522763475928278486,
    i64 6818396289628184396, i64 8522995362035230495, i64 3021029092058325107, i64 17611344420355070096,
    i64 8179122470161673908, i64 14335323580705822000, i64 13307468457454889596, i64 12022649553391224092,
    i64 10416625923311642211, i64 11122077220497164286, i64 4679224488766679549, i64 15072402647813125244,
    i64 9420251654883203278, i64 16387000587031392001, i64 15872064715361852097, i64 3002511419460075705,
    i64 8364825292752482535, i64 1232659579085827361, i64 14605470292210805812, i64 4421779809981343554,
    i64 915538744049291538, i64 5183897733458195115, i64 6479872166822743894, i64 3488154190101041964,
    i64 2180096368813151227, i64 16560178516298602746, i64 16088537126945865529, i64 7749492695127472003,
    i64 463493832054564196, i64 14414425345350368957, i64 13620701859271368502, i64 3190819268807046916,
    i64 17823582141290972357, i64 11139738838306857723, i64 13924673547883572154, i64 3570783879572301480,
    i64 18298537904747540562, i64 18354115218108294707, i64 18330958004207980480, i64 4466953431550423984,
    i64 486002885505321038, i64 5219189625309039202, i64 6523987031636299002, i64 17912549950054850588,
    i64 17779001419141175331, i64 8388693718644305452, i64 12160462601793772764, i64 10588892233814828051,
    i64 8624429273841147159, i64 778582277723329070, i64 973227847154161338, i64 1216534808942701673,
    i64 14595392310871352257, i64 13632554370161802418, i64 12429006944274865118, i64 7768129340171790699,
    i64 9710161675214738374, i64 16749388112445810871, i64 1244995533423855986, i64 15391302472061983695,
    i64 5404070034795315907, i64 14906758817815542202, i64 14021762503842039848, i64 8303831092947774002,
    i64 578208414664970847, i64 14557818573613377271, i64 18197273217016721589, i64 13523219484416126178,
    i64 15369541205401160717, i64 765182433041899281, i64 5568164059729762005, i64 5785945546544795205,
    i64 16455803970035769814, i64 6734696907262548556, i64 4209185567039092847, i64 9873167977226253963,
    i64 3118087934678041646, i64 4254647968387469981, i64 706623942056949572, i64 14718337982853350677,
    i64 11504804248497038125, i64 5157633273766521849, i64 6447041592208152311, i64 6335244004343789146,
    i64 17142427042284512241, i64 16816347784428252397, i64 1286845328412881940, i64 15443614715798266137,
    i64 5469460339465668959, i64 8030098730593431003, i64 14649309431669176658, i64 9088264752731695015,
    i64 10291851488884697288, i64 8253128342678483706, i64 5704724409920716729, i64 16354277549255671720,
    i64 998051431430019017, i64 10470936326142299579, i64 8476984389250486570, i64 14521487280136329914,
    i64 18151859100170412392, i64 18078137856785627587, i64 15910522178918405146, i64 6053094668365842720,
    i64 2954682317029915496, i64 17987577512639554849, i64 17872785872372055657, i64 13117610303610293764,
    i64 12810192458183821506, i64 2177682517447613171, i64 2722103146809516464, i64 6313000485183335694,
    i64 3279564588051781713, i64 17934513790346890853, i64 1985699082112030975, i64 16317181907922202431,
    i64 6561419329620589327, i64 11018416108653950185, i64 4549648098962661924, i64 10298746142130715309,
    i64 1825030320404309164, i64 6892973918932774359, i64 4004531380238580045, i64 16337890167931276240,
    i64 6587304654631931588, i64 17457502855144690293, i64 17210192550503474962, i64 6144684325637283947,
    i64 12292541425473992838, i64 15365676781842491048, i64 16521077016292638761, i64 16039660251938410547,
    i64 10826203278068237376, i64 15989749085647424168, i64 6152128301777116498, i64 12301846395648783526,
    i64 14606183024921571560, i64 4422670725869800738, i64 10140024425764638826, i64 8643358275316593218,
    i64 6192511825718353619, i64 7740639782147942024, i64 2532056854628769813, i64 12388443105140738074,
    i64 10873867862998534689, i64 9102010423587778132, i64 15989199047912110569, i64 10763126773035362404,
    i64 13644483260788183358, i64 17055604075985229198, i64 7484447039699372786, i64 9289465418239495895,
    i64 11611831772799369869, i64 679731660717048624, i64 10073036612751086588, i64 8601490892183123069,
    i64 10751863615228903837, i64 4216457482181353988, i64 14164500972431816002, i64 8482254178684994195,
    i64 5991131704928854840, i64 15273672361649004035, i64 9868718415206479236, i64 3112525982153323237,
    i64 4251171748059520975, i64 702278666647013314, i64 5489534351736154547, i64 1125115960621402640,
    i64 6018080969204141204, i64 2910915193077788601, i64 17960223060169475539, i64 17838592806784456520,
    i64 13074868971625794843, i64 3560107088838733872, i64 18285191916330581053, i64 4409745821703674700,
    i64 11979463175419572495, i64 1139270913992301907, i64 15259146697772541096, i64 7231123676894144233,
    i64 4427218577690292387, i64 14757395258967641292, i64 0, i64 0,
    i64 0, i64 0, i64 0, i64 0,
    i64 0, i64 0, i64 0, i64 0,
    i64 0, i64 0, i64 0, i64 0,
    i64 0, i64 0, i64 0, i64 0,
    i64 0, i64 0, i64 0, i64 0,
    i64 0, i64 0, i64 0, i64 0,
    i64 0, i64 0, i64 4611686018427387904, i64 5764607523034234880,
    i64 11817445422220181504, i64 5548434740920451072, i64 17302829768357445632, i64 7793479155164643328,
    i64 14353534962383192064, i64 4359273333062107136, i64 5449091666327633920, i64 2199678564482154496,
    i64 1374799102801346560, i64 1718498878501683200, i64 6759809616554491904, i64 6530724019560251392,
    i64 17386777061305090048, i64 7898413271349198848, i64 16465723340661719040, i64 15970468157399760896,
    i64 15351399178322313216, i64 4982938468024057856, i64 10840359103457460224, i64 4327076842467049472,
    i64 11927795063396681728, i64 10298057810818464256, i64 8260886245095692416, i64 5163053903184807760,
    i64 11065503397408397604, i64 18443565265187884909, i64 13833071299956122020, i64 12679653106517764621,
    i64 11237880364719817872, i64 212292400617608628, i64 132682750386005392, i64 4777539456409894645,
    i64 15195296357367144114, i64 7191217214140771119, i64 4377335499248575995, i64 10083355392488107898,
    i64 10913783138732455340, i64 4418856886560793367, i64 5523571108200991709, i64 10369760970266701674,
    i64 12962201212833377092, i64 6979379479186945558, i64 13585484211346616781, i64 7758483227328495169,
    i64 14309790052588006865, i64 18166990819722280098, i64 4261994450943298507, i64 5327493063679123134,
    i64 7941369183226839863, i64 5315025460606161924, i64 15867153862612478214, i64 7611128154919104931,
    i64 14125596212076269068, i64 17656995265095336336, i64 8729779031470891258, i64 6300537770911226168,
    i64 17099044250493808518, i64 6075216638131242420, i64 7594020797664053025, i64 269153960225290473,
    i64 336442450281613091, i64 7127805559067090038, i64 4298070930406474644, i64 14595960699862869113,
    i64 9122475437414293195, i64 11403094296767866494, i64 14253867870959833118, i64 13520353437777283602,
    i64 3065383741939440791, i64 17666787732706464701, i64 6430056314514152534, i64 8037570393142690668,
    i64 823590954573587527, i64 5126430365035880108, i64 6408037956294850135, i64 3398361426941174765,
    i64 13653190937906703988, i64 17066488672383379985, i64 16721424822051837077, i64 3533361486141316317,
    i64 13640073894531421205, i64 7826720331309500698, i64 280014188641050032, i64 9573389772656088348,
    i64 16578423234247498339, i64 5749828502977298558, i64 16410657665576399005, i64 6678264026688335045,
    i64 8347830033360418806, i64 2911550761636567802, i64 12862810488900485560, i64 2243455055843443238,
    i64 3708002419115845976, i64 23317005467419566, i64 13864204312116438170, i64 17888499731927549664,
    i64 13137252628054661272, i64 11809879766640938686, i64 14298703881791668535, i64 13261693833812197764,
    i64 11965431273837859301, i64 9784237555362356015, i64 3006924907348169211, i64 17593714189467375226,
    i64 1772699331562333708, i64 6827560182880305039, i64 8534450228600381299, i64 7639874402088932264,
    i64 326470965756389522, i64 5019774725622874806, i64 831516194300602802, i64 10262767279730529310,
    i64 3605087062808385830, i64 9170708441896323000, i64 6851699533943015846, i64 3952938399001381903,
    i64 13999801545444333449, i64 17499751931805416812, i64 8039631859474607303, i64 14661225842770647033,
    i64 18386638188586430203, i64 18371611717305649850, i64 9129456591349898601, i64 17235125415662156385,
    i64 12320534732722919674, i64 10788982397476261688, i64 15966486035277439363, i64 10734735507242023396,
    i64 8806733365625141341, i64 12421737381156795194, i64 6303799689591218185, i64 17103121648843798539,
    i64 1466078993672598279, i64 6444284760518135752, i64 8055355950647669691, i64 2728754459941099604,
    i64 12634315111781150314, i64 1957835834444274180, i64 10447019433382447170, i64 3835402254873283155,
    i64 4794252818591603944, i64 7608094030047140369, i64 4898431519131537557, i64 10734725417341809851,
    i64 2097517367411243253, i64 7233582727691441970, i64 9041978409614302462, i64 6690786993590490174,
    i64 4181741870994056359, i64 615491320315182544, i64 9992736187248753989, i64 3939617107816777291,
    i64 9536207403198359517, i64 7308573235570561493, i64 11485387299872682789, i64 9745048106413465582,
    i64 12181310133016831978, i64 695789805494438130, i64 869737256868047663, i64 10310543607939835386,
    i64 17973304801030866876, i64 4019886927579031980, i64 9636544677901177879, i64 10634526442115624078,
    i64 4069786015789754290, i64 475546501309804958, i64 4908902581746016003, i64 15359500264037295811,
    i64 9976003293191843956, i64 17764217104313372233, i64 12981899343536939483, i64 16227374179421174354,
    i64 17059637889779315827, i64 2877803288514593168, i64 3597254110643241460, i64 9108253656731439729,
    i64 1080972517029761926, i64 5962901664714590312, i64 12065313099320625794, i64 9846663696289085073,
    i64 7696643601933968437, i64 397432465562684739, i64 14083453346258841674, i64 8380944645968776284,
    i64 1252808770606194547, i64 10006377518483647400, i64 7896285879677171346, i64 14482043368023852087,
    i64 2133748077373825698, i64 2667185096717282123, i64 3333981370896602653, i64 6695424375237764562,
    i64 8369280469047205703, i64 15073286604736395033, i64 9420804127960246895, i64 7164319141522920715,
    i64 4343712908476262990, i64 7326506586225052273, i64 9158133232781315341, i64 2224294504121868368,
    i64 10613556101930943538, i64 17878631145841067327, i64 3901544858591782542, i64 13967680582688333849,
    i64 12847914709933029407, i64 16059893387416286759, i64 1628122660560806833, i64 10240948699705280078,
    i64 17412871893058988002, i64 12542717829468959195, i64 12450884661845487401, i64 1728547772024695539,
    i64 15995742770313033136, i64 5385653213018257806, i64 11343752534700210161, i64 9568004649947874797,
    i64 3674159897003727796, i64 4592699871254659745, i64 1129188820640936778, i64 3011586022114279438,
    i64 8376168546070237202, i64 10470210682587796502, i64 1932195658189984910, i64 11638616609592256945,
    i64 14548270761990321182, i64 9092669226243950738, i64 15977522551232326327, i64 6136845133758244197,
    i64 15364743254667372383, i64 9982557031479439671, i64 3254824252494523781, i64 11257637194663853171,
    i64 9460360474902428559, i64 2602078556773259891, i64 17087656251248738576, i64 17597314184671543466,
    i64 12773270693984653525, i64 15966588367480816906, i64 14590803748102898470, i64 18238504685128623088,
    i64 13574758819556003052, i64 15401753289863583763, i64 5417133557047315992, i64 15994788983163920798,
    i64 14608429132904838403, i64 4425478360848884291, i64 920161932633717460, i64 2880944217109767365,
    i64 12824552308241985014, i64 6807318348447705459, i64 15783789013848285672, i64 10506364230455581282,
    i64 8521269269642088699, i64 12243322321167387293, i64 6080780864604458308, i64 12212662099182960789,
    i64 5327070802775656541, i64 6658838503469570676, i64 8323548129336963345, i64 14425589617690377899,
    i64 13420301003685584469, i64 2940318199324816875, i64 8755227902219092403, i64 15555720896201253407,
    i64 10221279083396790951, i64 12776598854245988689, i64 7985374283903742931, i64 758345818024902856,
    i64 14782990327813292282, i64 9239368954883307676, i64 16160897212031522499, i64 1754377441329851508,
    i64 1096485900831157192, i64 15205665431321110202, i64 5172023733869224041, i64 5538357842881958977,
    i64 16146319340457224530, i64 6347841120289366950, i64 6273243709394548296
]

@decimal_fast_ex = private unnamed_addr constant [651 x i64] [
i64 -1264, i64 -1260, i64 -1257, i64 -1254, i64 -1250, i64 -1247, i64 -1244, i64 -1240,
    i64 -1237, i64 -1234, i64 -1230, i64 -1227, i64 -1224, i64 -1220, i64 -1217, i64 -1214,
    i64 -1210, i64 -1207, i64 -1204, i64 -1200, i64 -1197, i64 -1194, i64 -1191, i64 -1187,
    i64 -1184, i64 -1181, i64 -1177, i64 -1174, i64 -1171, i64 -1167, i64 -1164, i64 -1161,
    i64 -1157, i64 -1154, i64 -1151, i64 -1147, i64 -1144, i64 -1141, i64 -1137, i64 -1134,
    i64 -1131, i64 -1127, i64 -1124, i64 -1121, i64 -1117, i64 -1114, i64 -1111, i64 -1107,
    i64 -1104, i64 -1101, i64 -1098, i64 -1094, i64 -1091, i64 -1088, i64 -1084, i64 -1081,
    i64 -1078, i64 -1074, i64 -1071, i64 -1068, i64 -1064, i64 -1061, i64 -1058, i64 -1054,
    i64 -1051, i64 -1048, i64 -1044, i64 -1041, i64 -1038, i64 -1034, i64 -1031, i64 -1028,
    i64 -1024, i64 -1021, i64 -1018, i64 -1014, i64 -1011, i64 -1008, i64 -1004, i64 -1001,
    i64 -998, i64 -995, i64 -991, i64 -988, i64 -985, i64 -981, i64 -978, i64 -975,
    i64 -971, i64 -968, i64 -965, i64 -961, i64 -958, i64 -955, i64 -951, i64 -948,
    i64 -945, i64 -941, i64 -938, i64 -935, i64 -931, i64 -928, i64 -925, i64 -921,
    i64 -918, i64 -915, i64 -911, i64 -908, i64 -905, i64 -902, i64 -898, i64 -895,
    i64 -892, i64 -888, i64 -885, i64 -882, i64 -878, i64 -875, i64 -872, i64 -868,
    i64 -865, i64 -862, i64 -858, i64 -855, i64 -852, i64 -848, i64 -845, i64 -842,
    i64 -838, i64 -835, i64 -832, i64 -828, i64 -825, i64 -822, i64 -818, i64 -815,
    i64 -812, i64 -808, i64 -805, i64 -802, i64 -799, i64 -795, i64 -792, i64 -789,
    i64 -785, i64 -782, i64 -779, i64 -775, i64 -772, i64 -769, i64 -765, i64 -762,
    i64 -759, i64 -755, i64 -752, i64 -749, i64 -745, i64 -742, i64 -739, i64 -735,
    i64 -732, i64 -729, i64 -725, i64 -722, i64 -719, i64 -715, i64 -712, i64 -709,
    i64 -706, i64 -702, i64 -699, i64 -696, i64 -692, i64 -689, i64 -686, i64 -682,
    i64 -679, i64 -676, i64 -672, i64 -669, i64 -666, i64 -662, i64 -659, i64 -656,
    i64 -652, i64 -649, i64 -646, i64 -642, i64 -639, i64 -636, i64 -632, i64 -629,
    i64 -626, i64 -622, i64 -619, i64 -616, i64 -613, i64 -609, i64 -606, i64 -603,
    i64 -599, i64 -596, i64 -593, i64 -589, i64 -586, i64 -583, i64 -579, i64 -576,
    i64 -573, i64 -569, i64 -566, i64 -563, i64 -559, i64 -556, i64 -553, i64 -549,
    i64 -546, i64 -543, i64 -539, i64 -536, i64 -533, i64 -529, i64 -526, i64 -523,
    i64 -519, i64 -516, i64 -513, i64 -510, i64 -506, i64 -503, i64 -500, i64 -496,
    i64 -493, i64 -490, i64 -486, i64 -483, i64 -480, i64 -476, i64 -473, i64 -470,
    i64 -466, i64 -463, i64 -460, i64 -456, i64 -453, i64 -450, i64 -446, i64 -443,
    i64 -440, i64 -436, i64 -433, i64 -430, i64 -426, i64 -423, i64 -420, i64 -417,
    i64 -413, i64 -410, i64 -407, i64 -403, i64 -400, i64 -397, i64 -393, i64 -390,
    i64 -387, i64 -383, i64 -380, i64 -377, i64 -373, i64 -370, i64 -367, i64 -363,
    i64 -360, i64 -357, i64 -353, i64 -350, i64 -347, i64 -343, i64 -340, i64 -337,
    i64 -333, i64 -330, i64 -327, i64 -323, i64 -320, i64 -317, i64 -314, i64 -310,
    i64 -307, i64 -304, i64 -300, i64 -297, i64 -294, i64 -290, i64 -287, i64 -284,
    i64 -280, i64 -277, i64 -274, i64 -270, i64 -267, i64 -264, i64 -260, i64 -257,
    i64 -254, i64 -250, i64 -247, i64 -244, i64 -240, i64 -237, i64 -234, i64 -230,
    i64 -227, i64 -224, i64 -221, i64 -217, i64 -214, i64 -211, i64 -207, i64 -204,
    i64 -201, i64 -197, i64 -194, i64 -191, i64 -187, i64 -184, i64 -181, i64 -177,
    i64 -174, i64 -171, i64 -167, i64 -164, i64 -161, i64 -157, i64 -154, i64 -151,
    i64 -147, i64 -144, i64 -141, i64 -137, i64 -134, i64 -131, i64 -127, i64 -124,
    i64 -121, i64 -118, i64 -114, i64 -111, i64 -108, i64 -104, i64 -101, i64 -98,
    i64 -94, i64 -91, i64 -88, i64 -84, i64 -81, i64 -78, i64 -74, i64 -71,
    i64 -68, i64 -64, i64 -61, i64 -58, i64 -54, i64 -51, i64 -48, i64 -44,
    i64 -41, i64 -38, i64 -34, i64 -31, i64 -28, i64 -25, i64 -21, i64 -18,
    i64 -15, i64 -11, i64 -8, i64 -5, i64 -1, i64 2, i64 5, i64 9,
    i64 12, i64 15, i64 19, i64 22, i64 25, i64 29, i64 32, i64 35,
    i64 39, i64 42, i64 45, i64 49, i64 52, i64 55, i64 59, i64 62,
    i64 65, i64 68, i64 72, i64 75, i64 78, i64 82, i64 85, i64 88,
    i64 92, i64 95, i64 98, i64 102, i64 105, i64 108, i64 112, i64 115,
    i64 118, i64 122, i64 125, i64 128, i64 132, i64 135, i64 138, i64 142,
    i64 145, i64 148, i64 152, i64 155, i64 158, i64 162, i64 165, i64 168,
    i64 171, i64 175, i64 178, i64 181, i64 185, i64 188, i64 191, i64 195,
    i64 198, i64 201, i64 205, i64 208, i64 211, i64 215, i64 218, i64 221,
    i64 225, i64 228, i64 231, i64 235, i64 238, i64 241, i64 245, i64 248,
    i64 251, i64 255, i64 258, i64 261, i64 264, i64 268, i64 271, i64 274,
    i64 278, i64 281, i64 284, i64 288, i64 291, i64 294, i64 298, i64 301,
    i64 304, i64 308, i64 311, i64 314, i64 318, i64 321, i64 324, i64 328,
    i64 331, i64 334, i64 338, i64 341, i64 344, i64 348, i64 351, i64 354,
    i64 358, i64 361, i64 364, i64 367, i64 371, i64 374, i64 377, i64 381,
    i64 384, i64 387, i64 391, i64 394, i64 397, i64 401, i64 404, i64 407,
    i64 411, i64 414, i64 417, i64 421, i64 424, i64 427, i64 431, i64 434,
    i64 437, i64 441, i64 444, i64 447, i64 451, i64 454, i64 457, i64 460,
    i64 464, i64 467, i64 470, i64 474, i64 477, i64 480, i64 484, i64 487,
    i64 490, i64 494, i64 497, i64 500, i64 504, i64 507, i64 510, i64 514,
    i64 517, i64 520, i64 524, i64 527, i64 530, i64 534, i64 537, i64 540,
    i64 544, i64 547, i64 550, i64 553, i64 557, i64 560, i64 563, i64 567,
    i64 570, i64 573, i64 577, i64 580, i64 583, i64 587, i64 590, i64 593,
    i64 597, i64 600, i64 603, i64 607, i64 610, i64 613, i64 617, i64 620,
    i64 623, i64 627, i64 630, i64 633, i64 637, i64 640, i64 643, i64 647,
    i64 650, i64 653, i64 656, i64 660, i64 663, i64 666, i64 670, i64 673,
    i64 676, i64 680, i64 683, i64 686, i64 690, i64 693, i64 696, i64 700,
    i64 703, i64 706, i64 710, i64 713, i64 716, i64 720, i64 723, i64 726,
    i64 730, i64 733, i64 736, i64 740, i64 743, i64 746, i64 749, i64 753,
    i64 756, i64 759, i64 763, i64 766, i64 769, i64 773, i64 776, i64 779,
    i64 783, i64 786, i64 789, i64 793, i64 796, i64 799, i64 803, i64 806,
    i64 809, i64 813, i64 816, i64 819, i64 823, i64 826, i64 829, i64 833,
    i64 836, i64 839, i64 843, i64 846, i64 849, i64 852, i64 856, i64 859,
    i64 862, i64 866, i64 869, i64 872, i64 876, i64 879, i64 882, i64 886,
    i64 889, i64 892, i64 896
]

; ---------------------------------------------------------------------------
; Fast decimal -> binary64 for validated number literals.
;
; decimal_fast(bytes, begin, end) scans the literal bytes [begin, end)
; once (sign, digits, dot, exponent) and tries, in order:
;   1. zero (no significant digits) -> sign only
;   2. integer: q == 0 && sig <= 19 -> single correctly-rounded uitofp
;   3. Clinger: sig <= 15 && |q| <= 22 -> exact 10^0..10^22 table, one
;      fmul (or fdiv) on the exactly representable significand
;   4. Eisel-Lemire: sig <= 19 && q in [-342, 308] -> 128-bit product of
;      the significand with the normalized truncated power of ten, then
;      a rounding decision accepted only when provably the correctly
;      rounded result (normal range, no midpoint ambiguity)
; If none applies it returns ok=false and the caller falls back to the
; exact slow path (j_decimal_to_double).
;
; The tables below hold, for every decimal exponent q in [-342, 308],
; hi:lo = trunc of the normalized 128-bit significand S of 10^q = S * 2^E
; with 2^127 <= S < 2^128, so 0 <= S - (hi:lo) < 1 and E is stored signed.
; Because w << clz < 2^64, trunc(w * S / 2^128) then differs from
; trunc(w * A / 2^128) by at most one unit where A = hi:lo, and the
; acceptance test needs a margin of two: rem is rejected exactly when the
; discarded low bits could still move the result across a midpoint
; (rem == mid-1 or rem == mid), where mid = 2^(shift-1) and shift is
; bits(U) - 53 so the candidate sits on the binary64 significand grid.
; ---------------------------------------------------------------------------

declare i64 @llvm.ctlz.i64(i64, i1)

@decimal_fast_p10 = private unnamed_addr constant [23 x double] [double 1.0, double 10.0, double 100.0, double 1000.0, double 10000.0, double 100000.0, double 1000000.0, double 10000000.0, double 100000000.0, double 1000000000.0, double 10000000000.0, double 100000000000.0, double 1000000000000.0, double 10000000000000.0, double 100000000000000.0, double 1000000000000000.0, double 10000000000000000.0, double 100000000000000000.0, double 1000000000000000000.0, double 10000000000000000000.0, double 100000000000000000000.0, double 1000000000000000000000.0, double 10000000000000000000000.0]

define internal { i64, i1 } @decimal_fast(ptr %bytes, i64 %begin, i64 %end) {
entry:
  %headp = getelementptr i8, ptr %bytes, i64 %begin
  %head = load i8, ptr %headp
  %minus = icmp eq i8 %head, 45
  %plus = icmp eq i8 %head, 43
  %signedp = or i1 %minus, %plus
  %skip = zext i1 %signedp to i64
  %dstart = add i64 %begin, %skip
  br label %digits
digits:
  %i = phi i64 [ %dstart, %entry ], [ %inext, %digit ], [ %dotnext, %dot ]
  %w = phi i64 [ 0, %entry ], [ %wn, %digit ], [ %w, %dot ]
  %sig = phi i64 [ 0, %entry ], [ %sign, %digit ], [ %sig, %dot ]
  %frac = phi i64 [ 0, %entry ], [ %frn, %digit ], [ %frac, %dot ]
  %dotflag = phi i1 [ false, %entry ], [ %dotflag, %digit ], [ true, %dot ]
  %stop0 = icmp uge i64 %i, %end
  br i1 %stop0, label %noexp, label %digitsbody
digitsbody:
  %p = getelementptr i8, ptr %bytes, i64 %i
  %c = load i8, ptr %p
  %d = sub i8 %c, 48
  %isdigit = icmp ult i8 %d, 10
  br i1 %isdigit, label %digit, label %nondigit
digit:
  %inext = add i64 %i, 1
  %fracplus = add i64 %frac, 1
  %frn = select i1 %dotflag, i64 %fracplus, i64 %frac
  %nonzero = icmp ne i8 %d, 0
  %atstart = icmp eq i64 %sig, 0
  %leadzero = xor i1 %nonzero, true
  %islead = and i1 %leadzero, %atstart
  %act = xor i1 %islead, true
  %sigplus = add i64 %sig, 1
  %sign = select i1 %act, i64 %sigplus, i64 %sig
  %room = icmp ult i64 %sig, 19
  %take = and i1 %act, %room
  %w10 = mul i64 %w, 10
  %d64 = zext i8 %d to i64
  %wacc = add i64 %w10, %d64
  %wn = select i1 %take, i64 %wacc, i64 %w
  br label %digits
nondigit:
  %isdot = icmp eq i8 %c, 46
  br i1 %isdot, label %dot, label %expcheck
dot:
  %dotnext = add i64 %i, 1
  br label %digits
expcheck:
  %echar = or i8 %c, 32
  %ise = icmp eq i8 %echar, 101
  br i1 %ise, label %exponent, label %fail
exponent:
  %esignp = getelementptr i8, ptr %p, i64 1
  %esign = load i8, ptr %esignp
  %eneg = icmp eq i8 %esign, 45
  %epos = icmp eq i8 %esign, 43
  %esignal = or i1 %eneg, %epos
  %eskip = zext i1 %esignal to i64
  %eone = add i64 %i, 1
  %e0 = add i64 %eone, %eskip
  br label %exploop
exploop:
  %ei = phi i64 [ %e0, %exponent ], [ %ein, %expdigit ]
  %ev = phi i64 [ 0, %exponent ], [ %evn, %expdigit ]
  %esaw = phi i1 [ false, %exponent ], [ true, %expdigit ]
  %edone = icmp uge i64 %ei, %end
  br i1 %edone, label %expcalc, label %expbody
expbody:
  %epp = getelementptr i8, ptr %bytes, i64 %ei
  %ec = load i8, ptr %epp
  %edv = sub i8 %ec, 48
  %edig = icmp ult i8 %edv, 10
  br i1 %edig, label %expdigit, label %expcalc
expdigit:
  %edu = zext i8 %edv to i64
  %ev10 = mul i64 %ev, 10
  %evadd = add i64 %ev10, %edu
  %huge = icmp ugt i64 %evadd, 400
  %evn = select i1 %huge, i64 400, i64 %evadd
  %ein = add i64 %ei, 1
  br label %exploop
expcalc:
  br i1 %esaw, label %expsigned, label %fail
expsigned:
  %enegated = sub i64 0, %ev
  %expval = select i1 %eneg, i64 %enegated, i64 %ev
  br label %noexp
noexp:
  %expfinal = phi i64 [ 0, %digits ], [ %expval, %expsigned ]
  %q = sub i64 %expfinal, %frac
  %iszero = icmp eq i64 %sig, 0
  %signbit = select i1 %minus, i64 -9223372036854775808, i64 0
  br i1 %iszero, label %zeroout, label %intcheck
zeroout:
  br label %finish
intcheck:
  %isint = icmp eq i64 %q, 0
  %intfit = icmp sle i64 %sig, 19
  %intok = and i1 %isint, %intfit
  br i1 %intok, label %intfast, label %clingercheck
intfast:
  %intdouble = uitofp i64 %w to double
  %intbits = bitcast double %intdouble to i64
  br label %finish
clingercheck:
  %cfit = icmp sle i64 %sig, 15
  %qneg = icmp slt i64 %q, 0
  %qflip = sub i64 0, %q
  %qabs = select i1 %qneg, i64 %qflip, i64 %q
  %csmall = icmp sle i64 %qabs, 22
  %cok = and i1 %cfit, %csmall
  br i1 %cok, label %clinger, label %elcheck
clinger:
  %clbase = uitofp i64 %w to double
  %p10p = getelementptr [23 x double], ptr @decimal_fast_p10, i64 0, i64 %qabs
  %pw = load double, ptr %p10p
  %clup = fmul double %clbase, %pw
  %cldown = fdiv double %clbase, %pw
  %clscaled = select i1 %qneg, double %cldown, double %clup
  %clbits = bitcast double %clscaled to i64
  br label %finish
elcheck:
  %elfit = icmp sle i64 %sig, 19
  %elow = icmp sge i64 %q, -342
  %ehigh = icmp sle i64 %q, 308
  %elrange = and i1 %elow, %ehigh
  %elok = and i1 %elfit, %elrange
  br i1 %elok, label %eisel, label %fail
eisel:
  %wlz = call i64 @llvm.ctlz.i64(i64 %w, i1 false)
  %wz = shl i64 %w, %wlz
  %idx = add i64 %q, 342
  %hip = getelementptr [651 x i64], ptr @decimal_fast_hi, i64 0, i64 %idx
  %lop = getelementptr [651 x i64], ptr @decimal_fast_lo, i64 0, i64 %idx
  %expp = getelementptr [651 x i64], ptr @decimal_fast_ex, i64 0, i64 %idx
  %hi = load i64, ptr %hip
  %lo = load i64, ptr %lop
  %E = load i64, ptr %expp
  %wz128 = zext i64 %wz to i128
  %hi128 = zext i64 %hi to i128
  %lo128 = zext i64 %lo to i128
  %H = mul i128 %wz128, %hi128
  %L = mul i128 %wz128, %lo128
  %Hhi64 = lshr i128 %H, 64
  %Hhi = trunc i128 %Hhi64 to i64
  %Hlo = trunc i128 %H to i64
  %Lhi64 = lshr i128 %L, 64
  %Lhi = trunc i128 %Lhi64 to i64
  %Hlo128 = zext i64 %Hlo to i128
  %Lhi128 = zext i64 %Lhi to i128
  %midsum = add i128 %Hlo128, %Lhi128
  %carry128 = lshr i128 %midsum, 64
  %carry = trunc i128 %carry128 to i64
  %U = add i64 %Hhi, %carry
  %uctlz = call i64 @llvm.ctlz.i64(i64 %U, i1 false)
  %shift = sub i64 11, %uctlz
  %m0 = lshr i64 %U, %shift
  %one = shl i64 1, %shift
  %mask = sub i64 %one, 1
  %rem = and i64 %U, %mask
  %half = lshr i64 %one, 1
  %midminus = sub i64 %half, 1
  %rtie = icmp eq i64 %rem, %midminus
  %rhalf = icmp eq i64 %rem, %half
  %amb = or i1 %rtie, %rhalf
  br i1 %amb, label %fail, label %elround
elround:
  %upcond = icmp ugt i64 %rem, %half
  %m0p1 = add i64 %m0, 1
  %mraw = select i1 %upcond, i64 %m0p1, i64 %m0
  %is53 = icmp eq i64 %mraw, 9007199254740992
  %mnorm = select i1 %is53, i64 4503599627370496, i64 %mraw
  %carryexp = zext i1 %is53 to i64
  %et1 = add i64 %E, 128
  %et2 = sub i64 %et1, %wlz
  %et3 = add i64 %et2, %shift
  %e = add i64 %et3, %carryexp
  %bias = add i64 %e, 1075
  %toolow = icmp slt i64 %bias, 2
  %toohigh = icmp sgt i64 %bias, 2045
  %badrange = or i1 %toolow, %toohigh
  br i1 %badrange, label %fail, label %elpack
elpack:
  %mant = sub i64 %mnorm, 4503599627370496
  %expfield = shl i64 %bias, 52
  %elbits = or i64 %expfield, %mant
  br label %finish
fail:
  ret { i64, i1 } zeroinitializer
finish:
  %unsigned = phi i64 [ 0, %zeroout ], [ %intbits, %intfast ], [ %clbits, %clinger ], [ %elbits, %elpack ]
  %finalbits = or i64 %unsigned, %signbit
  %packed = insertvalue { i64, i1 } undef, i64 %finalbits, 0
  %answer = insertvalue { i64, i1 } %packed, i1 true, 1
  ret { i64, i1 } %answer
}

define double @j_decimal_to_double(ptr %literal) {
entry:
  %litlen = call i64 @j_strlen(ptr %literal)
  %fast = call { i64, i1 } @decimal_fast(ptr %literal, i64 0, i64 %litlen)
  %fastbits = extractvalue { i64, i1 } %fast, 0
  %fastok = extractvalue { i64, i1 } %fast, 1
  br i1 %fastok, label %fastdone, label %slow
fastdone:
  %fastval = bitcast i64 %fastbits to double
  ret double %fastval
slow:
  %first = load i8, ptr %literal
  %negative = icmp eq i8 %first, 45
  %parts = call ptr @decimal_parts(ptr %literal)
  %lengthp = getelementptr %Decimal, ptr %parts, i32 0, i32 2
  %positionp = getelementptr %Decimal, ptr %parts, i32 0, i32 3
  %datap = getelementptr %Decimal, ptr %parts, i32 0, i32 4
  %length = load i64, ptr %lengthp
  %position = load i64, ptr %positionp
  %data = load ptr, ptr %datap
  %zero = icmp eq i64 %length, 0
  br i1 %zero, label %zeroresult, label %range
range:
  %large = icmp sgt i64 %position, 309
  br i1 %large, label %infinity, label %tinycheck
tinycheck:
  %tiny = icmp slt i64 %position, -323
  br i1 %tiny, label %zeroresult, label %approximate
approximate:
  %exponent64 = sub i64 %position, %length
  %exponent = trunc i64 %exponent64 to i32
  %approximation = call double @decimal_binary64(ptr %data, i64 0, i64 %length, i32 %exponent)
  %approximatebits = bitcast double %approximation to i64
  %short = icmp ule i64 %length, 15
  %low = icmp sge i64 %exponent64, -22
  %high = icmp sle i64 %exponent64, 22
  %smallscale = and i1 %low, %high
  %clinger = and i1 %short, %smallscale
  %integer = icmp eq i64 %exponent64, 0
  %word = icmp ule i64 %length, 19
  %wordinteger = and i1 %integer, %word
  %exactfast = or i1 %clinger, %wordinteger
  br i1 %exactfast, label %fastresult, label %correct
fastresult:
  br label %sign
correct:
  %bits = phi i64 [ %approximatebits, %approximate ], [ %higher, %increment ], [ %lower, %decrement ]
  %steps = phi i32 [ 0, %approximate ], [ %nextstep, %increment ], [ %nextstep, %decrement ]
  %nextstep = add i32 %steps, 1
  %many = icmp eq i32 %steps, 8
  br i1 %many, label %binarysearch, label %uppercheck
uppercheck:
  %isinf = icmp eq i64 %bits, 9218868437227405312
  br i1 %isinf, label %lowercheck, label %upper
upper:
  %uppercmp = call i32 @decimal_compare_upper(ptr %parts, i64 %bits)
  %above = icmp sgt i32 %uppercmp, 0
  %atequal = icmp eq i32 %uppercmp, 0
  %parity = and i64 %bits, 1
  %odd = icmp ne i64 %parity, 0
  %tieup = and i1 %atequal, %odd
  %needup = or i1 %above, %tieup
  br i1 %needup, label %increment, label %lowercheck
increment:
  %higher = add i64 %bits, 1
  br label %correct
lowercheck:
  %iszero = icmp eq i64 %bits, 0
  br i1 %iszero, label %correctresult, label %lowerbound
lowerbound:
  %previousbits = sub i64 %bits, 1
  %lowercmp = call i32 @decimal_compare_upper(ptr %parts, i64 %previousbits)
  %below = icmp slt i32 %lowercmp, 0
  %lowerequal = icmp eq i32 %lowercmp, 0
  %lowerparity = and i64 %bits, 1
  %lowerodd = icmp ne i64 %lowerparity, 0
  %tiedown = and i1 %lowerequal, %lowerodd
  %needdown = or i1 %below, %tiedown
  br i1 %needdown, label %decrement, label %correctresult
decrement:
  %lower = sub i64 %bits, 1
  br label %correct
correctresult:
  br label %sign
binarysearch:
  br label %search
search:
  %lo = phi i64 [ 0, %binarysearch ], [ %newlo, %moveup ], [ %lo, %movedown ]
  %hi = phi i64 [ 9218868437227405312, %binarysearch ], [ %hi, %moveup ], [ %midpoint, %movedown ]
  %finished = icmp eq i64 %lo, %hi
  br i1 %finished, label %searchresult, label %searchbody
searchbody:
  %distance = sub i64 %hi, %lo
  %half = lshr i64 %distance, 1
  %midpoint = add i64 %lo, %half
  %comparison = call i32 @decimal_compare_upper(ptr %parts, i64 %midpoint)
  %greater = icmp sgt i32 %comparison, 0
  %equal = icmp eq i32 %comparison, 0
  %midparity = and i64 %midpoint, 1
  %midodd = icmp ne i64 %midparity, 0
  %midtie = and i1 %equal, %midodd
  %after = or i1 %greater, %midtie
  br i1 %after, label %moveup, label %movedown
moveup:
  %newlo = add i64 %midpoint, 1
  br label %search
movedown:
  br label %search
searchresult:
  br label %sign
zeroresult:
  br label %sign
infinity:
  br label %sign
sign:
  %unsignedbits = phi i64 [ 0, %zeroresult ], [ 9218868437227405312, %infinity ], [ %approximatebits, %fastresult ], [ %bits, %correctresult ], [ %lo, %searchresult ]
  %signbit = select i1 %negative, i64 -9223372036854775808, i64 0
  %signedbits = or i64 %unsignedbits, %signbit
  %result = bitcast i64 %signedbits to double
  ret double %result
}

define internal i64 @decimal_round(ptr %digits, i32 %length, i32 %precision) {
entry:
  %short = icmp ult i32 %length, %precision
  %n = select i1 %short, i32 %length, i32 %precision
  br label %prefix
prefix:
  %i = phi i32 [ 0, %entry ], [ %next, %body ]
  %m = phi i64 [ 0, %entry ], [ %sum, %body ]
  %done = icmp eq i32 %i, %n
  br i1 %done, label %roundcheck, label %body
body:
  %fromend = sub i32 %length, %i
  %ix = sub i32 %fromend, 1
  %p = getelementptr i8, ptr %digits, i32 %ix
  %d8 = load i8, ptr %p
  %d = zext i8 %d8 to i64
  %times = mul i64 %m, 10
  %sum = add i64 %times, %d
  %next = add i32 %i, 1
  br label %prefix
roundcheck:
  %remaining = sub i32 %length, %n
  %hasnext = icmp sgt i32 %remaining, 0
  br i1 %hasnext, label %rounddigit, label %down
rounddigit:
  %ri = sub i32 %remaining, 1
  %rp = getelementptr i8, ptr %digits, i32 %ri
  %rd = load i8, ptr %rp
  %less = icmp ult i8 %rd, 5
  %greater = icmp ugt i8 %rd, 5
  br i1 %less, label %down, label %roundupcheck
roundupcheck:
  br i1 %greater, label %up, label %tie
tie:
  %oddpart = and i64 %m, 1
  %odd = icmp ne i64 %oddpart, 0
  br i1 %odd, label %up, label %tail
tail:
  %t = phi i32 [ 0, %tie ], [ %tn, %tailzero ]
  %tailend = icmp eq i32 %t, %ri
  br i1 %tailend, label %down, label %tailbody
tailbody:
  %tp = getelementptr i8, ptr %digits, i32 %t
  %td = load i8, ptr %tp
  %nonzero = icmp ne i8 %td, 0
  br i1 %nonzero, label %up, label %tailzero
tailzero:
  %tn = add i32 %t, 1
  br label %tail
up:
  %rounded = add i64 %m, 1
  ret i64 %rounded
down:
  ret i64 %m
}

; A candidate decimal is admissible exactly when it lies between adjacent
; binary midpoints, including ties only for an even binary significand.
define internal i1 @decimal_candidate(i64 %coefficient, i32 %exponent, ptr %interval) {
entry:
  %zero = icmp eq i64 %coefficient, 0
  br i1 %zero, label %no, label %start
start:
  %digits = alloca [24 x i8]
  %parts = alloca %Decimal
  br label %loop
loop:
  %value = phi i64 [ %coefficient, %start ], [ %quotient, %loop ]
  %length = phi i64 [ 0, %start ], [ %nextlength, %loop ]
  %remainder = urem i64 %value, 10
  %digit = trunc i64 %remainder to i8
  %ascii = add i8 %digit, 48
  %index = sub i64 23, %length
  %p = getelementptr i8, ptr %digits, i64 %index
  store i8 %ascii, ptr %p
  %nextlength = add i64 %length, 1
  %quotient = udiv i64 %value, 10
  %finished = icmp eq i64 %quotient, 0
  br i1 %finished, label %prepare, label %loop
prepare:
  %lp = getelementptr %Decimal, ptr %parts, i32 0, i32 2
  %xp = getelementptr %Decimal, ptr %parts, i32 0, i32 3
  %dp = getelementptr %Decimal, ptr %parts, i32 0, i32 4
  %exp64 = sext i32 %exponent to i64
  %position = add i64 %nextlength, %exp64
  store i64 %nextlength, ptr %lp
  store i64 %position, ptr %xp
  store ptr %p, ptr %dp
  %lowerp = getelementptr %RoundInterval, ptr %interval, i32 0, i32 0
  %upperp = getelementptr %RoundInterval, ptr %interval, i32 0, i32 1
  %lowerlp = getelementptr %RoundInterval, ptr %interval, i32 0, i32 2
  %upperlp = getelementptr %RoundInterval, ptr %interval, i32 0, i32 3
  %lowerxp = getelementptr %RoundInterval, ptr %interval, i32 0, i32 4
  %upperxp = getelementptr %RoundInterval, ptr %interval, i32 0, i32 5
  %evenp = getelementptr %RoundInterval, ptr %interval, i32 0, i32 6
  %lower = load ptr, ptr %lowerp
  %upper = load ptr, ptr %upperp
  %lowerlength = load i64, ptr %lowerlp
  %upperlength = load i64, ptr %upperlp
  %lowerposition = load i64, ptr %lowerxp
  %upperposition = load i64, ptr %upperxp
  %even = load i1, ptr %evenp
  %lowercmp = call i32 @decimal_compare_digits(ptr %parts, ptr %lower, i64 %lowerlength, i64 %lowerposition)
  %lowerinside = icmp sgt i32 %lowercmp, 0
  %lowerequal = icmp eq i32 %lowercmp, 0
  %lowertie = and i1 %lowerequal, %even
  %lowerok = or i1 %lowerinside, %lowertie
  br i1 %lowerok, label %uppercheck, label %no
uppercheck:
  %uppercmp = call i32 @decimal_compare_digits(ptr %parts, ptr %upper, i64 %upperlength, i64 %upperposition)
  %upperinside = icmp slt i32 %uppercmp, 0
  %upperequal = icmp eq i32 %uppercmp, 0
  %uppertie = and i1 %upperequal, %even
  %upperok = or i1 %upperinside, %uppertie
  ret i1 %upperok
no:
  ret i1 false
}

define internal void @dump_number(ptr %b, double %number) {
entry:
  %bits = bitcast double %number to i64
  %negative = icmp slt i64 %bits, 0
  %absbits = and i64 %bits, 9223372036854775807
  %zero = icmp eq i64 %absbits, 0
  %nan = icmp ugt i64 %absbits, 9218868437227405312
  br i1 %nan, label %notnumber, label %sign
notnumber:
  call void @buffer_append(ptr %b, ptr @text_null, i64 4)
  ret void
sign:
  br i1 %negative, label %minus, label %zerocheck
minus:
  call void @buffer_byte(ptr %b, i8 45)
  br label %zerocheck
zerocheck:
  br i1 %zero, label %printzero, label %finite
printzero:
  call void @buffer_byte(ptr %b, i8 48)
  ret void
finite:
  %infinite = icmp eq i64 %absbits, 9218868437227405312
  %finitebits = select i1 %infinite, i64 9218868437227405311, i64 %absbits
  %absolute = bitcast i64 %finitebits to double
  %smallinteger = fcmp ole double %absolute, 9.007199254740992e15
  br i1 %smallinteger, label %integercheck, label %expansion
integercheck:
  %wholevalue = fptoui double %absolute to i64
  %integerpart = uitofp i64 %wholevalue to double
  %integer = fcmp oeq double %integerpart, %absolute
  br i1 %integer, label %whole, label %expansion
whole:
  call void @buffer_uint(ptr %b, i64 %wholevalue)
  ret void
expansion:
  %frac = and i64 %finitebits, 4503599627370495
  %expshift = lshr i64 %finitebits, 52
  %expbits = trunc i64 %expshift to i32
  %subnormal = icmp eq i32 %expbits, 0
  %normalized = or i64 %frac, 4503599627370496
  %mantissa = select i1 %subnormal, i64 %frac, i64 %normalized
  %normalexp = sub i32 %expbits, 1075
  %exp2 = select i1 %subnormal, i32 -1074, i32 %normalexp
  %digits = alloca [1100 x i8]
  %length = call i32 @decimal_coefficient(ptr %digits, i64 %mantissa, i32 %exp2)
  %negexp = icmp slt i32 %exp2, 0
  %decimalexp = select i1 %negexp, i32 %exp2, i32 0
  %expplus = add i32 %decimalexp, %length
  %lowerdigits = alloca [1100 x i8]
  %upperdigits = alloca [1100 x i8]
  %interval = alloca %RoundInterval
  %lowerp = getelementptr %RoundInterval, ptr %interval, i32 0, i32 0
  %upperp = getelementptr %RoundInterval, ptr %interval, i32 0, i32 1
  %lowerlp = getelementptr %RoundInterval, ptr %interval, i32 0, i32 2
  %upperlp = getelementptr %RoundInterval, ptr %interval, i32 0, i32 3
  %lowerxp = getelementptr %RoundInterval, ptr %interval, i32 0, i32 4
  %upperxp = getelementptr %RoundInterval, ptr %interval, i32 0, i32 5
  %evenp = getelementptr %RoundInterval, ptr %interval, i32 0, i32 6
  %previousbits = sub i64 %finitebits, 1
  %lowerlength32 = call i32 @decimal_upper(ptr %lowerdigits, ptr %lowerxp, i64 %previousbits)
  %upperlength32 = call i32 @decimal_upper(ptr %upperdigits, ptr %upperxp, i64 %finitebits)
  %lowerlength = zext i32 %lowerlength32 to i64
  %upperlength = zext i32 %upperlength32 to i64
  %lowbit = and i64 %finitebits, 1
  %even = icmp eq i64 %lowbit, 0
  store ptr %lowerdigits, ptr %lowerp
  store ptr %upperdigits, ptr %upperp
  store i64 %lowerlength, ptr %lowerlp
  store i64 %upperlength, ptr %upperlp
  store i1 %even, ptr %evenp
  br label %precision
precision:
  %n = phi i32 [ 1, %expansion ], [ %nn, %trymore ]
  %short = icmp ult i32 %length, %n
  %used = select i1 %short, i32 %length, i32 %n
  %m = call i64 @decimal_round(ptr %digits, i32 %length, i32 %n)
  %scale = sub i32 %expplus, %used
  %matches = call i1 @decimal_candidate(i64 %m, i32 %scale, ptr %interval)
  br i1 %matches, label %choose, label %trylower
trylower:
  %below = sub i64 %m, 1
  %lowermatches = call i1 @decimal_candidate(i64 %below, i32 %scale, ptr %interval)
  br i1 %lowermatches, label %choose, label %tryupper
tryupper:
  %above = add i64 %m, 1
  %uppermatches = call i1 @decimal_candidate(i64 %above, i32 %scale, ptr %interval)
  br i1 %uppermatches, label %choose, label %trymore
trymore:
  %nn = add i32 %n, 1
  br label %precision
choose:
  %chosen = phi i64 [ %m, %precision ], [ %below, %trylower ], [ %above, %tryupper ]
  br label %trim
trim:
  %coefficient = phi i64 [ %chosen, %choose ], [ %divided, %trimzero ]
  %power10 = phi i32 [ %scale, %choose ], [ %increased, %trimzero ]
  %rem = urem i64 %coefficient, 10
  %trailingzero = icmp eq i64 %rem, 0
  br i1 %trailingzero, label %trimzero, label %coefficientstart
trimzero:
  %divided = udiv i64 %coefficient, 10
  %increased = add i32 %power10, 1
  br label %trim
coefficientstart:
  %outputdigits = alloca [24 x i8]
  br label %coefficientloop
coefficientloop:
  %c = phi i64 [ %coefficient, %coefficientstart ], [ %cq, %coefficientloop ]
  %clen = phi i32 [ 0, %coefficientstart ], [ %clennext, %coefficientloop ]
  %cr = urem i64 %c, 10
  %c8 = trunc i64 %cr to i8
  %ca = add i8 %c8, 48
  %cp = getelementptr i8, ptr %outputdigits, i32 %clen
  store i8 %ca, ptr %cp
  %cq = udiv i64 %c, 10
  %clennext = add i32 %clen, 1
  %cdone = icmp eq i64 %cq, 0
  br i1 %cdone, label %format, label %coefficientloop
format:
  %places = add i32 %clennext, %power10
  %exponent = sub i32 %places, 1
  %fixedlimit = add i32 %clennext, 15
  %large = icmp sgt i32 %places, %fixedlimit
  %small = icmp sle i32 %places, -4
  %scientific = or i1 %large, %small
  br i1 %scientific, label %scientificstart, label %fixedstart
scientificstart:
  br label %scientificloop
scientificloop:
  %si = phi i32 [ 0, %scientificstart ], [ %sin, %scientificdigit ]
  %sdone = icmp eq i32 %si, %clennext
  br i1 %sdone, label %scientificexponent, label %scientificbody
scientificbody:
  %dot = icmp eq i32 %si, 1
  br i1 %dot, label %scientificdot, label %scientificdigit
scientificdot:
  call void @buffer_byte(ptr %b, i8 46)
  br label %scientificdigit
scientificdigit:
  %sx1 = sub i32 %clennext, %si
  %sx = sub i32 %sx1, 1
  %sdp = getelementptr i8, ptr %outputdigits, i32 %sx
  %sd = load i8, ptr %sdp
  call void @buffer_byte(ptr %b, i8 %sd)
  %sin = add i32 %si, 1
  br label %scientificloop
scientificexponent:
  call void @buffer_byte(ptr %b, i8 101)
  %eneg = icmp slt i32 %exponent, 0
  %esign = select i1 %eneg, i8 45, i8 43
  call void @buffer_byte(ptr %b, i8 %esign)
  %enegated = sub i32 0, %exponent
  %eabs = select i1 %eneg, i32 %enegated, i32 %exponent
  %eu = zext i32 %eabs to i64
  %onedigit = icmp ult i32 %eabs, 10
  br i1 %onedigit, label %exponentzero, label %exponentdigits
exponentzero:
  call void @buffer_byte(ptr %b, i8 48)
  br label %exponentdigits
exponentdigits:
  call void @buffer_uint(ptr %b, i64 %eu)
  ret void
fixedstart:
  %leadingfraction = icmp sle i32 %places, 0
  br i1 %leadingfraction, label %fractionstart, label %fixedloopstart
fractionstart:
  call void @buffer_byte(ptr %b, i8 48)
  call void @buffer_byte(ptr %b, i8 46)
  %zeros = sub i32 0, %places
  br label %fractionzeros
fractionzeros:
  %zi = phi i32 [ 0, %fractionstart ], [ %zin, %fractionzero ]
  %zdone = icmp eq i32 %zi, %zeros
  br i1 %zdone, label %fixedloopstart, label %fractionzero
fractionzero:
  call void @buffer_byte(ptr %b, i8 48)
  %zin = add i32 %zi, 1
  br label %fractionzeros
fixedloopstart:
  %positivepower = icmp sgt i32 %power10, 0
  %outlength = select i1 %positivepower, i32 %places, i32 %clennext
  br label %fixedloop
fixedloop:
  %fi = phi i32 [ 0, %fixedloopstart ], [ %fin, %fixedemit ]
  %fdone = icmp eq i32 %fi, %outlength
  br i1 %fdone, label %finish, label %fixedbody
fixedbody:
  %atdot = icmp eq i32 %fi, %places
  %positiveplaces = icmp sgt i32 %places, 0
  %needot = and i1 %atdot, %positiveplaces
  br i1 %needot, label %fixeddot, label %fixeddigit
fixeddot:
  call void @buffer_byte(ptr %b, i8 46)
  br label %fixeddigit
fixeddigit:
  %have = icmp ult i32 %fi, %clennext
  br i1 %have, label %fixedread, label %fixedzero
fixedread:
  %fx1 = sub i32 %clennext, %fi
  %fx = sub i32 %fx1, 1
  %fdp = getelementptr i8, ptr %outputdigits, i32 %fx
  %fd = load i8, ptr %fdp
  br label %fixedemit
fixedzero:
  br label %fixedemit
fixedemit:
  %fc = phi i8 [ %fd, %fixedread ], [ 48, %fixedzero ]
  call void @buffer_byte(ptr %b, i8 %fc)
  %fin = add i32 %fi, 1
  br label %fixedloop
finish:
  ret void
}

@spaces64 = private constant [64 x i8] c"                                                                "
@tabs64 = private constant [64 x i8] c"\09\09\09\09\09\09\09\09\09\09\09\09\09\09\09\09\09\09\09\09\09\09\09\09\09\09\09\09\09\09\09\09\09\09\09\09\09\09\09\09\09\09\09\09\09\09\09\09\09\09\09\09\09\09\09\09\09\09\09\09\09\09\09\09"

define internal void @dump_indent(ptr %b, i32 %depth) {
entry:
  call void @buffer_byte(ptr %b, i8 10)
  %width = load i32, ptr @j_indent
  %tab = icmp slt i32 %width, 0
  %spaces = mul i32 %depth, %width
  %count = select i1 %tab, i32 %depth, i32 %spaces
  %count64 = sext i32 %count to i64
  %pad = select i1 %tab, ptr @tabs64, ptr @spaces64
  br label %loop
loop:
  %left = phi i64 [ %count64, %entry ], [ %remain, %body ]
  %done = icmp sle i64 %left, 0
  br i1 %done, label %end, label %body
body:
  %full = icmp ugt i64 %left, 64
  %chunk = select i1 %full, i64 64, i64 %left
  call void @buffer_append(ptr %b, ptr %pad, i64 %chunk)
  %remain = sub i64 %left, %chunk
  br label %loop
end:
  ret void
}

define internal void @dump_hex4(ptr %b, i32 %codepoint) {
entry:
  %buf = alloca [6 x i8]
  store i8 92, ptr %buf
  %up = getelementptr i8, ptr %buf, i64 1
  store i8 117, ptr %up
  br label %loop
loop:
  %shift = phi i32 [ 12, %entry ], [ %next, %loop ]
  %slot = phi i64 [ 2, %entry ], [ %slotnext, %loop ]
  %part = lshr i32 %codepoint, %shift
  %hex = and i32 %part, 15
  %hp = getelementptr i8, ptr @hex_digits, i32 %hex
  %c = load i8, ptr %hp
  %sp = getelementptr i8, ptr %buf, i64 %slot
  store i8 %c, ptr %sp
  %slotnext = add i64 %slot, 1
  %next = sub i32 %shift, 4
  %done = icmp eq i32 %shift, 0
  br i1 %done, label %emit, label %loop
emit:
  call void @buffer_append(ptr %b, ptr %buf, i64 6)
  ret void
}

define internal void @dump_string(ptr %b, ptr %value, i32 %flags) {
entry:
  %lp = getelementptr %V, ptr %value, i32 0, i32 3
  %dp = getelementptr %V, ptr %value, i32 0, i32 5
  %length = load i64, ptr %lp
  %data = load ptr, ptr %dp
  %af = and i32 %flags, 2
  %ascii = icmp ne i32 %af, 0
  %offset = alloca i64
  call void @buffer_byte(ptr %b, i8 34)
  br label %run
run:
  %i = phi i64 [ 0, %entry ], [ %enext, %shortescape ], [ %cnext, %controlend ], [ %unext, %unicodeend ]
  br label %scan
scan:
  %j = phi i64 [ %i, %run ], [ %jn, %plainbyte ]
  %done = icmp eq i64 %j, %length
  br i1 %done, label %flush, label %fetch
fetch:
  %p = getelementptr i8, ptr %data, i64 %j
  %c = load i8, ptr %p
  %jn = add i64 %j, 1
  %atleast = icmp uge i8 %c, 32
  %atmost = icmp ule i8 %c, 126
  %notquote = icmp ne i8 %c, 34
  %notslash = icmp ne i8 %c, 92
  %utf8 = icmp uge i8 %c, -128
  %escapable = and i1 %ascii, %utf8
  %notutf8esc = xor i1 %escapable, true
  %inrange = and i1 %atleast, %atmost
  %inrange2 = and i1 %inrange, %notquote
  %plain = and i1 %inrange2, %notslash
  %plain2 = and i1 %plain, %notutf8esc
  %plainhigh = and i1 %utf8, %notutf8esc
  %plain3 = or i1 %plain2, %plainhigh
  br i1 %plain3, label %plainbyte, label %flush
plainbyte:
  br label %scan
flush:
  %runlen = sub i64 %j, %i
  %have = icmp ugt i64 %runlen, 0
  br i1 %have, label %append, label %atend
append:
  %rp = getelementptr i8, ptr %data, i64 %i
  call void @buffer_append(ptr %b, ptr %rp, i64 %runlen)
  br label %atend
atend:
  %atlast = icmp eq i64 %j, %length
  br i1 %atlast, label %end, label %classify
classify:
  %cp0 = getelementptr i8, ptr %data, i64 %j
  %c0 = load i8, ptr %cp0
  %ishigh = icmp uge i8 %c0, -128
  br i1 %ishigh, label %unicode, label %escswitch
escswitch:
  switch i8 %c0, label %control [ i8 34, label %quote i8 92, label %slash i8 8, label %backspace i8 9, label %tab i8 10, label %newline i8 12, label %formfeed i8 13, label %return ]
quote:
  br label %shortescape
slash:
  br label %shortescape
backspace:
  br label %shortescape
tab:
  br label %shortescape
newline:
  br label %shortescape
formfeed:
  br label %shortescape
return:
  br label %shortescape
shortescape:
  %esc = phi i8 [ 34, %quote ], [ 92, %slash ], [ 98, %backspace ], [ 116, %tab ], [ 110, %newline ], [ 102, %formfeed ], [ 114, %return ]
  call void @buffer_byte(ptr %b, i8 92)
  call void @buffer_byte(ptr %b, i8 %esc)
  %enext = add i64 %j, 1
  br label %run
controlend:
  %cnext = add i64 %j, 1
  br label %run
control:
  %cc = zext i8 %c0 to i32
  call void @dump_hex4(ptr %b, i32 %cc)
  br label %controlend
unicode:
  store i64 %j, ptr %offset
  %cp = call i32 @j_utf8_next(ptr %data, i64 %length, ptr %offset)
  %unext = load i64, ptr %offset
  %pair = icmp uge i32 %cp, 65536
  br i1 %pair, label %surrogates, label %single
single:
  call void @dump_hex4(ptr %b, i32 %cp)
  br label %unicodeend
surrogates:
  %reduced = sub i32 %cp, 65536
  %high = lshr i32 %reduced, 10
  %low = and i32 %reduced, 1023
  %hs = add i32 %high, 55296
  %ls = add i32 %low, 56320
  call void @dump_hex4(ptr %b, i32 %hs)
  call void @dump_hex4(ptr %b, i32 %ls)
  br label %unicodeend
unicodeend:
  br label %run
end:
  call void @buffer_byte(ptr %b, i8 34)
  ret void
}

define internal void @dump_value(ptr %b, ptr %value, i32 %flags, i32 %depth) {
entry:
  %toodeep = icmp ugt i32 %depth, 10000
  br i1 %toodeep, label %depthlimit, label %dispatch
depthlimit:
  call void @buffer_append(ptr %b, ptr @text_print_depth, i64 21)
  ret void
dispatch:
  %tag = load i32, ptr %value
  switch i32 %tag, label %null [ i32 1, label %false i32 2, label %true i32 3, label %number i32 4, label %string i32 5, label %container i32 6, label %container ]
null:
  call void @buffer_append(ptr %b, ptr @text_null, i64 4)
  ret void
false:
  call void @buffer_append(ptr %b, ptr @text_false, i64 5)
  ret void
true:
  call void @buffer_append(ptr %b, ptr @text_true, i64 4)
  ret void
number:
  %litp = getelementptr %V, ptr %value, i32 0, i32 6
  %lit = load ptr, ptr %litp
  %hasliteral = icmp ne ptr %lit, null
  br i1 %hasliteral, label %literal, label %computed
literal:
  call void @dump_literal(ptr %b, ptr %lit)
  ret void
computed:
  %np = getelementptr %V, ptr %value, i32 0, i32 2
  %n = load double, ptr %np
  call void @dump_number(ptr %b, double %n)
  ret void
string:
  call void @dump_string(ptr %b, ptr %value, i32 %flags)
  ret void
container:
  %lp = getelementptr %V, ptr %value, i32 0, i32 3
  %dp = getelementptr %V, ptr %value, i32 0, i32 5
  %length = load i64, ptr %lp
  %data = load ptr, ptr %dp
  %object = icmp eq i32 %tag, 6
  %opener = select i1 %object, i8 123, i8 91
  %closer = select i1 %object, i8 125, i8 93
  %prettybit = and i32 %flags, 1
  %pretty = icmp ne i32 %prettybit, 0
  %sortbit = and i32 %flags, 4
  %sorted = icmp ne i32 %sortbit, 0
  %sortkeys = and i1 %object, %sorted
  %childdepth = add i32 %depth, 1
  call void @buffer_byte(ptr %b, i8 %opener)
  br i1 %sortkeys, label %sort, label %start
sort:
  %keys = call ptr @j_keys_sorted(ptr %value)
  br label %start
start:
  %sortedkeys = phi ptr [ %keys, %sort ], [ null, %container ]
  br label %loop
loop:
  %i = phi i64 [ 0, %start ], [ %next, %emit ]
  %done = icmp eq i64 %i, %length
  br i1 %done, label %closing, label %separatorcheck
separatorcheck:
  %first = icmp eq i64 %i, 0
  br i1 %first, label %indentcheck, label %separator
separator:
  call void @buffer_byte(ptr %b, i8 44)
  br label %indentcheck
indentcheck:
  br i1 %pretty, label %indent, label %element
indent:
  call void @dump_indent(ptr %b, i32 %childdepth)
  br label %element
element:
  br i1 %object, label %objkey, label %arrayelement
arrayelement:
  %ap = getelementptr ptr, ptr %data, i64 %i
  %av = load ptr, ptr %ap
  br label %emit
objkey:
  br i1 %sortkeys, label %sortedkey, label %unsortedkey
sortedkey:
  %sk = call ptr @j_at(ptr %sortedkeys, i64 %i)
  %sv = call ptr @j_get(ptr %value, ptr %sk)
  br label %emitkey
unsortedkey:
  %ki = mul i64 %i, 2
  %kp = getelementptr ptr, ptr %data, i64 %ki
  %vp = getelementptr ptr, ptr %kp, i64 1
  %uk = load ptr, ptr %kp
  %uv = load ptr, ptr %vp
  br label %emitkey
emitkey:
  %key = phi ptr [ %sk, %sortedkey ], [ %uk, %unsortedkey ]
  %objvalue = phi ptr [ %sv, %sortedkey ], [ %uv, %unsortedkey ]
  call void @dump_string(ptr %b, ptr %key, i32 %flags)
  call void @buffer_byte(ptr %b, i8 58)
  br i1 %pretty, label %colonspace, label %objemit
colonspace:
  call void @buffer_byte(ptr %b, i8 32)
  br label %objemit
objemit:
  br label %emit
emit:
  %item = phi ptr [ %av, %arrayelement ], [ %objvalue, %objemit ]
  call void @dump_value(ptr %b, ptr %item, i32 %flags, i32 %childdepth)
  %next = add i64 %i, 1
  br label %loop
closing:
  %nonempty = icmp ne i64 %length, 0
  %closeindent = and i1 %pretty, %nonempty
  br i1 %closeindent, label %lastindent, label %close
lastindent:
  call void @dump_indent(ptr %b, i32 %depth)
  br label %close
close:
  call void @buffer_byte(ptr %b, i8 %closer)
  ret void
}

define ptr @j_dump(ptr %value, i32 %flags) {
  %b = call ptr @buffer_new()
  call void @dump_value(ptr %b, ptr %value, i32 %flags, i32 0)
  %s = call ptr @buffer_value(ptr %b)
  ret ptr %s
}

define ptr @j_kind(ptr %value) {
entry:
  %tag = load i32, ptr %value
  switch i32 %tag, label %null [ i32 1, label %boolean i32 2, label %boolean i32 3, label %number i32 4, label %string i32 5, label %array i32 6, label %object ]
null:
  ret ptr @text_null
boolean:
  ret ptr @kind_boolean
number:
  ret ptr @kind_number
string:
  ret ptr @kind_string
array:
  ret ptr @kind_array
object:
  ret ptr @kind_object
}

define internal void @dump_short(ptr %buffer, ptr %value) {
entry:
  %s = call ptr @j_dump(ptr %value, i32 0)
  %lp = getelementptr %V, ptr %s, i32 0, i32 3
  %dp = getelementptr %V, ptr %s, i32 0, i32 5
  %length = load i64, ptr %lp
  %data = load ptr, ptr %dp
  %long = icmp ugt i64 %length, 29
  br i1 %long, label %truncate, label %whole
whole:
  call void @buffer_append(ptr %buffer, ptr %data, i64 %length)
  ret void
truncate:
  %tag = load i32, ptr %value
  %string = icmp eq i32 %tag, 4
  %array = icmp eq i32 %tag, 5
  %object = icmp eq i32 %tag, 6
  %delimited = icmp uge i32 %tag, 4
  %arrayend = select i1 %array, i8 93, i8 125
  %delimiter = select i1 %string, i8 34, i8 %arrayend
  %count = select i1 %delimited, i64 25, i64 26
  br label %backtrack
backtrack:
  %n = phi i64 [ %count, %truncate ], [ %previous, %stepback ]
  %p = getelementptr i8, ptr %data, i64 %n
  %c = load i8, ptr %p
  %bits = and i8 %c, -64
  %continuation = icmp eq i8 %bits, -128
  br i1 %continuation, label %stepback, label %copy
stepback:
  %previous = sub i64 %n, 1
  br label %backtrack
copy:
  call void @buffer_append(ptr %buffer, ptr %data, i64 %n)
  call void @buffer_append(ptr %buffer, ptr @text_dots, i64 3)
  br i1 %delimited, label %close, label %end
close:
  call void @buffer_byte(ptr %buffer, i8 %delimiter)
  br label %end
end:
  ret void
}

define internal void @describe_value(ptr %buffer, ptr %value) {
  %kind = call ptr @j_kind(ptr %value)
  %length = call i64 @j_strlen(ptr %kind)
  call void @buffer_append(ptr %buffer, ptr %kind, i64 %length)
  call void @buffer_append(ptr %buffer, ptr @text_openparen, i64 2)
  call void @dump_short(ptr %buffer, ptr %value)
  call void @buffer_byte(ptr %buffer, i8 41)
  ret void
}

define void @j_type_error(ptr %value, ptr %message) {
  %buffer = call ptr @buffer_new()
  call void @describe_value(ptr %buffer, ptr %value)
  call void @buffer_byte(ptr %buffer, i8 32)
  %len = call i64 @j_strlen(ptr %message)
  call void @buffer_append(ptr %buffer, ptr %message, i64 %len)
  %s = call ptr @buffer_value(ptr %buffer)
  store ptr %s, ptr @j_error
  ret void
}

define void @j_type_error2(ptr %left, ptr %right, ptr %message) {
  %buffer = call ptr @buffer_new()
  call void @describe_value(ptr %buffer, ptr %left)
  call void @buffer_append(ptr %buffer, ptr @text_and, i64 5)
  call void @describe_value(ptr %buffer, ptr %right)
  call void @buffer_byte(ptr %buffer, i8 32)
  %len = call i64 @j_strlen(ptr %message)
  call void @buffer_append(ptr %buffer, ptr %message, i64 %len)
  %s = call ptr @buffer_value(ptr %buffer)
  store ptr %s, ptr @j_error
  ret void
}

define void @j_index_error(ptr %value, ptr %key) {
  %b = call ptr @buffer_new()
  call void @buffer_append(ptr %b, ptr @text_cannot_index, i64 13)
  %kind = call ptr @j_kind(ptr %value)
  %len = call i64 @j_strlen(ptr %kind)
  call void @buffer_append(ptr %b, ptr %kind, i64 %len)
  call void @buffer_append(ptr %b, ptr @text_with, i64 6)
  call void @describe_value(ptr %b, ptr %key)
  %s = call ptr @buffer_value(ptr %b)
  store ptr %s, ptr @j_error
  ret void
}

@text_cannot_use = private constant [12 x i8] c"Cannot use \00"
@text_object_key = private constant [15 x i8] c" as object key\00"

define void @j_object_key_error(ptr %key) {
  %buffer = call ptr @buffer_new()
  call void @buffer_append(ptr %buffer, ptr @text_cannot_use, i64 11)
  call void @describe_value(ptr %buffer, ptr %key)
  call void @buffer_append(ptr %buffer, ptr @text_object_key, i64 14)
  %message = call ptr @buffer_value(ptr %buffer)
  store ptr %message, ptr @j_error
  ret void
}

define void @j_iteration_error(ptr %value) {
  %buffer = call ptr @buffer_new()
  call void @buffer_append(ptr %buffer, ptr @text_cannot_iterate, i64 20)
  call void @describe_value(ptr %buffer, ptr %value)
  %message = call ptr @buffer_value(ptr %buffer)
  store ptr %message, ptr @j_error
  ret void
}

@text_cannot_iterate = private constant [21 x i8] c"Cannot iterate over \00"

define ptr @j_negate(ptr %value) {
entry:
  %tag = load i32, ptr %value
  %number = icmp eq i32 %tag, 3
  br i1 %number, label %negate, label %error
negate:
  %np = getelementptr %V, ptr %value, i32 0, i32 2
  %n = load double, ptr %np
  %negative = fneg double %n
  %v = call ptr @j_num(double %negative)
  %lp = getelementptr %V, ptr %value, i32 0, i32 6
  %lit = load ptr, ptr %lp
  %hasliteral = icmp ne ptr %lit, null
  br i1 %hasliteral, label %literal, label %done
literal:
  %first = load i8, ptr %lit
  %hasminus = icmp eq i8 %first, 45
  %parts = call ptr @decimal_parts(ptr %lit)
  %sign = load i32, ptr %parts
  %zero = icmp eq i32 %sign, 0
  br i1 %zero, label %literalzero, label %literalsign
literalzero:
  %vnp = getelementptr %V, ptr %v, i32 0, i32 2
  store double 0.0, ptr %vnp
  %unsignedzero = getelementptr i8, ptr %lit, i64 1
  %zeroliteral = select i1 %hasminus, ptr %unsignedzero, ptr %lit
  br label %storeliteral
literalsign:
  br i1 %hasminus, label %positive, label %addminus
positive:
  %positivebytes = getelementptr i8, ptr %lit, i64 1
  br label %storeliteral
addminus:
  %length = call i64 @j_strlen(ptr %lit)
  %alloclen = add i64 %length, 2
  %out = call ptr @j_alloc(i64 %alloclen)
  store i8 45, ptr %out
  %tail = getelementptr i8, ptr %out, i64 1
  %copylen = add i64 %length, 1
  call void @j_copy(ptr %tail, ptr %lit, i64 %copylen)
  br label %storeliteral
storeliteral:
  %newliteral = phi ptr [ %positivebytes, %positive ], [ %out, %addminus ], [ %zeroliteral, %literalzero ]
  %newlp = getelementptr %V, ptr %v, i32 0, i32 6
  store ptr %newliteral, ptr %newlp
  br label %done
done:
  ret ptr %v
error:
  call void @j_type_error(ptr %value, ptr @error_negate)
  ret ptr @value_null
}

define internal i64 @number_to_int(double %n) {
entry:
  %low = fcmp olt double %n, -9.223372036854775808e18
  %high = fcmp oge double %n, 9.223372036854775808e18
  br i1 %low, label %minimum, label %highcheck
minimum:
  ret i64 -9223372036854775808
highcheck:
  br i1 %high, label %maximum, label %convert
maximum:
  ret i64 9223372036854775807
convert:
  %n64 = fptosi double %n to i64
  ret i64 %n64
}

define internal ptr @binary_inner(i32 %op, ptr %left, ptr %right) {
entry:
  %lt = load i32, ptr %left
  %rt = load i32, ptr %right
  %booleanop = icmp uge i32 %op, 11
  br i1 %booleanop, label %boolean, label %comparisoncheck
boolean:
  %lv = call i1 @j_truth(ptr %left)
  %rv = call i1 @j_truth(ptr %right)
  %conjunction = and i1 %lv, %rv
  %disjunction = or i1 %lv, %rv
  %isand = icmp eq i32 %op, 11
  %bv = select i1 %isand, i1 %conjunction, i1 %disjunction
  %br = call ptr @j_bool(i1 %bv)
  ret ptr %br
comparisoncheck:
  %comparison = icmp uge i32 %op, 5
  br i1 %comparison, label %compare, label %arithmetic
compare:
  %oldmessage = load ptr, ptr @compare_message
  %eqop = icmp ule i32 %op, 6
  %cmpmessage = select i1 %eqop, ptr @error_equal_depth, ptr @error_compare_depth
  store ptr %cmpmessage, ptr @compare_message
  %cmp = call i32 @j_cmp(ptr %left, ptr %right)
  store ptr %oldmessage, ptr @compare_message
  switch i32 %op, label %greaterequal [ i32 5, label %equal i32 6, label %notequal i32 7, label %less i32 8, label %lessequal i32 9, label %greater ]
equal:
  %eq = icmp eq i32 %cmp, 0
  br label %compared
notequal:
  %ne = icmp ne i32 %cmp, 0
  br label %compared
less:
  %le = icmp slt i32 %cmp, 0
  br label %compared
lessequal:
  %leeq = icmp sle i32 %cmp, 0
  br label %compared
greater:
  %gr = icmp sgt i32 %cmp, 0
  br label %compared
greaterequal:
  %greq = icmp sge i32 %cmp, 0
  br label %compared
compared:
  %cr = phi i1 [ %eq, %equal ], [ %ne, %notequal ], [ %le, %less ], [ %leeq, %lessequal ], [ %gr, %greater ], [ %greq, %greaterequal ]
  %cv = call ptr @j_bool(i1 %cr)
  ret ptr %cv
arithmetic:
  %lnum = icmp eq i32 %lt, 3
  %rnum = icmp eq i32 %rt, 3
  %numbers = and i1 %lnum, %rnum
  br i1 %numbers, label %numeric, label %polymorphic
numeric:
  %lnp = getelementptr %V, ptr %left, i32 0, i32 2
  %rnp = getelementptr %V, ptr %right, i32 0, i32 2
  %ln = load double, ptr %lnp
  %rn = load double, ptr %rnp
  switch i32 %op, label %remainder [ i32 0, label %add i32 1, label %subtract i32 2, label %multiply i32 3, label %dividecheck ]
add:
  %sum = fadd double %ln, %rn
  br label %numericresult
subtract:
  %difference = fsub double %ln, %rn
  br label %numericresult
multiply:
  %product = fmul double %ln, %rn
  br label %numericresult
dividecheck:
  %zero = fcmp oeq double %rn, 0.0
  br i1 %zero, label %dividezero, label %divide
dividezero:
  call void @j_type_error2(ptr %left, ptr %right, ptr @error_dividezero)
  ret ptr @value_null
divide:
  %quotient = fdiv double %ln, %rn
  br label %numericresult
remainder:
  %nan = fcmp uno double %ln, %rn
  br i1 %nan, label %remaindernan, label %remainderconvert
remaindernan:
  br label %numericresult
remainderconvert:
  %li = call i64 @number_to_int(double %ln)
  %ri = call i64 @number_to_int(double %rn)
  %izero = icmp eq i64 %ri, 0
  br i1 %izero, label %remainderzero, label %remaindercheck
remainderzero:
  call void @j_type_error2(ptr %left, ptr %right, ptr @error_remainderzero)
  ret ptr @value_null
remaindercheck:
  %minusone = icmp eq i64 %ri, -1
  br i1 %minusone, label %remainderone, label %remaindercalculate
remainderone:
  br label %numericresult
remaindercalculate:
  %modulo = srem i64 %li, %ri
  %mod = sitofp i64 %modulo to double
  br label %numericresult
numericresult:
  %result = phi double [ %sum, %add ], [ %difference, %subtract ], [ %product, %multiply ], [ %quotient, %divide ], [ 0x7FF8000000000000, %remaindernan ], [ 0.0, %remainderone ], [ %mod, %remaindercalculate ]
  %nv = call ptr @j_num(double %result)
  ret ptr %nv
polymorphic:
  switch i32 %op, label %typeerror [ i32 0, label %plusnull i32 1, label %arrayminuscheck i32 2, label %multiplytypes i32 3, label %stringdividecheck ]
plusnull:
  %leftnull = icmp eq i32 %lt, 0
  br i1 %leftnull, label %returnright, label %plusrightnull
returnright:
  ret ptr %right
plusrightnull:
  %rightnull = icmp eq i32 %rt, 0
  br i1 %rightnull, label %returnleft, label %plustypes
returnleft:
  ret ptr %left
plustypes:
  %sametype = icmp eq i32 %lt, %rt
  br i1 %sametype, label %plusdispatch, label %typeerror
plusdispatch:
  switch i32 %lt, label %typeerror [ i32 4, label %stringplus i32 5, label %arrayplus i32 6, label %objectmerge ]
stringplus:
  %llp = getelementptr %V, ptr %left, i32 0, i32 3
  %rlp = getelementptr %V, ptr %right, i32 0, i32 3
  %ldp = getelementptr %V, ptr %left, i32 0, i32 5
  %rdp = getelementptr %V, ptr %right, i32 0, i32 5
  %ll = load i64, ptr %llp
  %rl = load i64, ptr %rlp
  %ld = load ptr, ptr %ldp
  %rd = load ptr, ptr %rdp
  %sl = add i64 %ll, %rl
  %alloclen = add i64 %sl, 1
  %bytes = call ptr @j_alloc(i64 %alloclen)
  call void @j_copy(ptr %bytes, ptr %ld, i64 %ll)
  %tail = getelementptr i8, ptr %bytes, i64 %ll
  call void @j_copy(ptr %tail, ptr %rd, i64 %rl)
  %sv = call ptr @j_str(ptr %bytes, i64 %sl)
  ret ptr %sv
arrayplus:
  %outarray = call ptr @j_clone(ptr %left)
  %rap = getelementptr %V, ptr %right, i32 0, i32 3
  %ral = load i64, ptr %rap
  br label %arrayplusloop
arrayplusloop:
  %api = phi i64 [ 0, %arrayplus ], [ %apnext, %arrayplusbody ]
  %apdone = icmp eq i64 %api, %ral
  br i1 %apdone, label %arrayplusdone, label %arrayplusbody
arrayplusbody:
  %apv = call ptr @j_at(ptr %right, i64 %api)
  call void @j_push(ptr %outarray, ptr %apv)
  %apnext = add i64 %api, 1
  br label %arrayplusloop
arrayplusdone:
  ret ptr %outarray
arrayminuscheck:
  %lam = icmp eq i32 %lt, 5
  %ram = icmp eq i32 %rt, 5
  %arrays = and i1 %lam, %ram
  br i1 %arrays, label %arrayminus, label %typeerror
arrayminus:
  %differencearray = call ptr @j_array()
  %lamp = getelementptr %V, ptr %left, i32 0, i32 3
  %ramp = getelementptr %V, ptr %right, i32 0, i32 3
  %laml = load i64, ptr %lamp
  %raml = load i64, ptr %ramp
  br label %arrayminusloop
arrayminusloop:
  %ami = phi i64 [ 0, %arrayminus ], [ %amnext, %arrayminusnext ]
  %amdone = icmp eq i64 %ami, %laml
  br i1 %amdone, label %arrayminusdone, label %arrayminusbody
arrayminusbody:
  %amv = call ptr @j_at(ptr %left, i64 %ami)
  br label %arraysearch
arraysearch:
  %asi = phi i64 [ 0, %arrayminusbody ], [ %asnext, %arraysearchnext ]
  %asdone = icmp eq i64 %asi, %raml
  br i1 %asdone, label %arraykeep, label %arraysearchbody
arraysearchbody:
  %asv = call ptr @j_at(ptr %right, i64 %asi)
  %ascmp = call i32 @j_cmp(ptr %amv, ptr %asv)
  %asequal = icmp eq i32 %ascmp, 0
  br i1 %asequal, label %arrayminusnext, label %arraysearchnext
arraysearchnext:
  %asnext = add i64 %asi, 1
  br label %arraysearch
arraykeep:
  call void @j_push(ptr %differencearray, ptr %amv)
  br label %arrayminusnext
arrayminusnext:
  %amnext = add i64 %ami, 1
  br label %arrayminusloop
arrayminusdone:
  ret ptr %differencearray
multiplytypes:
  %lobj = icmp eq i32 %lt, 6
  %robj = icmp eq i32 %rt, 6
  %objects = and i1 %lobj, %robj
  br i1 %objects, label %objectmerge, label %stringmultiplycheck
stringmultiplycheck:
  %lstr = icmp eq i32 %lt, 4
  %rstr = icmp eq i32 %rt, 4
  %sn = and i1 %lstr, %rnum
  %ns = and i1 %lnum, %rstr
  %stringnumber = or i1 %sn, %ns
  br i1 %stringnumber, label %stringmultiply, label %typeerror
stringmultiply:
  %str = select i1 %lstr, ptr %left, ptr %right
  %num = select i1 %lstr, ptr %right, ptr %left
  %snp = getelementptr %V, ptr %num, i32 0, i32 2
  %repetitions = load double, ptr %snp
  %negative = fcmp ult double %repetitions, 0.0
  br i1 %negative, label %nullrepeat, label %repeatlength
nullrepeat:
  ret ptr @value_null
repeatlength:
  %too_many = fcmp ogt double %repetitions, 2.147483647e9
  %bounded = select i1 %too_many, double 2.147483647e9, double %repetitions
  %count = fptoui double %bounded to i64
  %slp = getelementptr %V, ptr %str, i32 0, i32 3
  %sdp = getelementptr %V, ptr %str, i32 0, i32 5
  %slen = load i64, ptr %slp
  %sdata = load ptr, ptr %sdp
  %total = mul i64 %slen, %count
  %toolong = icmp uge i64 %total, 2147483600
  br i1 %toolong, label %repeaterror, label %repeatallocate
repeaterror:
  call void @j_fail(ptr @error_repeat)
  ret ptr @value_null
repeatallocate:
  %repeatbytes = add i64 %total, 1
  %repeated = call ptr @j_alloc(i64 %repeatbytes)
  br label %repeatloop
repeatloop:
  %repeatpos = phi i64 [ 0, %repeatallocate ], [ %repeatnext, %repeatbody ]
  %repeatdone = icmp eq i64 %repeatpos, %total
  br i1 %repeatdone, label %repeatfinish, label %repeatbody
repeatbody:
  %repeatout = getelementptr i8, ptr %repeated, i64 %repeatpos
  call void @j_copy(ptr %repeatout, ptr %sdata, i64 %slen)
  %repeatnext = add i64 %repeatpos, %slen
  br label %repeatloop
repeatfinish:
  %repeatedvalue = call ptr @j_str(ptr %repeated, i64 %total)
  ret ptr %repeatedvalue
stringdividecheck:
  %lsd = icmp eq i32 %lt, 4
  %rsd = icmp eq i32 %rt, 4
  %strings = and i1 %lsd, %rsd
  br i1 %strings, label %stringdivide, label %typeerror
stringdivide:
  %split = call ptr @j_split(ptr %left, ptr %right)
  ret ptr %split
objectmerge:
  %outobject = call ptr @j_clone(ptr %left)
  %olp = getelementptr %V, ptr %right, i32 0, i32 3
  %odp = getelementptr %V, ptr %right, i32 0, i32 5
  %olen = load i64, ptr %olp
  %odata = load ptr, ptr %odp
  %recursive = icmp eq i32 %op, 2
  br label %objectloop
objectloop:
  %oi = phi i64 [ 0, %objectmerge ], [ %onext, %objectput ]
  %odone = icmp eq i64 %oi, %olen
  br i1 %odone, label %objectdone, label %objectbody
objectbody:
  %oki = mul i64 %oi, 2
  %okp = getelementptr ptr, ptr %odata, i64 %oki
  %ovp = getelementptr ptr, ptr %okp, i64 1
  %ok = load ptr, ptr %okp
  %ov = load ptr, ptr %ovp
  br i1 %recursive, label %recursivecheck, label %objectput
recursivecheck:
  %oldvalue = call ptr @j_get(ptr %outobject, ptr %ok)
  %oldt = load i32, ptr %oldvalue
  %newt = load i32, ptr %ov
  %oldobj = icmp eq i32 %oldt, 6
  %newobj = icmp eq i32 %newt, 6
  %bothobj = and i1 %oldobj, %newobj
  br i1 %bothobj, label %recurse, label %objectput
recurse:
  %merged = call ptr @j_binary(i32 2, ptr %oldvalue, ptr %ov)
  br label %objectput
objectput:
  %putvalue = phi ptr [ %ov, %objectbody ], [ %ov, %recursivecheck ], [ %merged, %recurse ]
  call void @j_put(ptr %outobject, ptr %ok, ptr %putvalue)
  %onext = add i64 %oi, 1
  br label %objectloop
objectdone:
  ret ptr %outobject
typeerror:
  switch i32 %op, label %remerror [ i32 0, label %adderror i32 1, label %suberror i32 2, label %mulerror i32 3, label %diverror ]
adderror:
  br label %report
suberror:
  br label %report
mulerror:
  br label %report
diverror:
  br label %report
remerror:
  br label %report
report:
  %msg = phi ptr [ @error_add, %adderror ], [ @error_subtract, %suberror ], [ @error_multiply, %mulerror ], [ @error_divide, %diverror ], [ @error_remainder, %remerror ]
  call void @j_type_error2(ptr %left, ptr %right, ptr %msg)
  ret ptr @value_null
}

define internal ptr @decimal_parts(ptr %text) {
entry:
  %len = call i64 @j_strlen(ptr %text)
  %out = call ptr @j_alloc(i64 %len)
  %first = load i8, ptr %text
  %negative = icmp eq i8 %first, 45
  %positive = icmp eq i8 %first, 43
  %signed = or i1 %negative, %positive
  %begin = zext i1 %signed to i64
  br label %loop
loop:
  %i = phi i64 [ %begin, %entry ], [ %in, %digit ], [ %dotnext, %dot ]
  %n = phi i64 [ 0, %entry ], [ %nn, %digit ], [ %n, %dot ]
  %fraction = phi i64 [ 0, %entry ], [ %fn, %digit ], [ %fraction, %dot ]
  %decimal = phi i1 [ false, %entry ], [ %decimal, %digit ], [ true, %dot ]
  %p = getelementptr i8, ptr %text, i64 %i
  %c = load i8, ptr %p
  %d = sub i8 %c, 48
  %isdigit = icmp ult i8 %d, 10
  br i1 %isdigit, label %digit, label %nondigit
digit:
  %dp = getelementptr i8, ptr %out, i64 %n
  store i8 %c, ptr %dp
  %in = add i64 %i, 1
  %nn = add i64 %n, 1
  %fplus = add i64 %fraction, 1
  %fn = select i1 %decimal, i64 %fplus, i64 %fraction
  br label %loop
nondigit:
  %isdecimal = icmp eq i8 %c, 46
  br i1 %isdecimal, label %dot, label %exponentcheck
dot:
  %dotnext = add i64 %i, 1
  br label %loop
exponentcheck:
  %lower = or i8 %c, 32
  %hasexp = icmp eq i8 %lower, 101
  br i1 %hasexp, label %exponentstart, label %noexponent
exponentstart:
  %expp = getelementptr i8, ptr %p, i64 1
  %sign = load i8, ptr %expp
  %enegative = icmp eq i8 %sign, 45
  %eplus = icmp eq i8 %sign, 43
  %esigned = or i1 %enegative, %eplus
  %skip = zext i1 %esigned to i64
  %edigits = getelementptr i8, ptr %expp, i64 %skip
  br label %exploop
exploop:
  %ei = phi i64 [ 0, %exponentstart ], [ %en, %expdigit ]
  %ev = phi i64 [ 0, %exponentstart ], [ %esum, %expdigit ]
  %ep = getelementptr i8, ptr %edigits, i64 %ei
  %ec = load i8, ptr %ep
  %ed = sub i8 %ec, 48
  %edigit = icmp ult i8 %ed, 10
  br i1 %edigit, label %expdigit, label %expend
expdigit:
  %edu = zext i8 %ed to i64
  %etimes = mul i64 %ev, 10
  %eadded = add i64 %etimes, %edu
  %huge = icmp ugt i64 %eadded, 400000000000000000
  %esum = select i1 %huge, i64 400000000000000000, i64 %eadded
  %en = add i64 %ei, 1
  br label %exploop
expend:
  %enegated = sub i64 0, %ev
  %signedexp = select i1 %enegative, i64 %enegated, i64 %ev
  br label %normalize
noexponent:
  br label %normalize
normalize:
  %exponent = phi i64 [ 0, %noexponent ], [ %signedexp, %expend ]
  br label %zeros
zeros:
  %z = phi i64 [ 0, %normalize ], [ %zn, %zero ]
  %end = icmp eq i64 %z, %n
  br i1 %end, label %finish, label %zerocheck
zerocheck:
  %zp = getelementptr i8, ptr %out, i64 %z
  %zd = load i8, ptr %zp
  %iszero = icmp eq i8 %zd, 48
  br i1 %iszero, label %zero, label %finish
zero:
  %zn = add i64 %z, 1
  br label %zeros
finish:
  %significant = sub i64 %n, %z
  %nonzero = icmp ne i64 %significant, 0
  %signvalue = select i1 %negative, i32 -1, i32 1
  %signum = select i1 %nonzero, i32 %signvalue, i32 0
  %baseexp = sub i64 %exponent, %fraction
  %position = add i64 %baseexp, %significant
  %digits = getelementptr i8, ptr %out, i64 %z
  %result = call ptr @j_alloc(i64 32)
  %lp = getelementptr %Decimal, ptr %result, i32 0, i32 2
  %xp = getelementptr %Decimal, ptr %result, i32 0, i32 3
  %vp = getelementptr %Decimal, ptr %result, i32 0, i32 4
  store i32 %signum, ptr %result
  store i64 %significant, ptr %lp
  store i64 %position, ptr %xp
  store ptr %digits, ptr %vp
  ret ptr %result
}

define internal void @dump_literal(ptr %b, ptr %literal) {
entry:
  %first = load i8, ptr %literal
  %minus = icmp eq i8 %first, 45
  %iszero0 = icmp eq i8 %first, 48
  br i1 %iszero0, label %checksinglezero, label %checkfaststart
checksinglezero:
  %p1 = getelementptr i8, ptr %literal, i64 1
  %c1 = load i8, ptr %p1
  %onlyzero = icmp eq i8 %c1, 0
  br i1 %onlyzero, label %emitfastzero, label %slowliteral
emitfastzero:
  call void @buffer_byte(ptr %b, i8 48)
  ret void
checkfaststart:
  %startidx = zext i1 %minus to i64
  %pstart = getelementptr i8, ptr %literal, i64 %startidx
  %d0 = load i8, ptr %pstart
  %d0sub = sub i8 %d0, 49
  %d0ok = icmp ult i8 %d0sub, 9
  br i1 %d0ok, label %fastscaninit, label %slowliteral
fastscaninit:
  %firstnext = add i64 %startidx, 1
  br label %fastscan
fastscan:
  %fi = phi i64 [ %firstnext, %fastscaninit ], [ %finext, %fastdigit ], [ %fdotnext, %fastdot ]
  %fdot = phi i1 [ false, %fastscaninit ], [ %fdot, %fastdigit ], [ true, %fastdot ]
  %fpi = getelementptr i8, ptr %literal, i64 %fi
  %fci = load i8, ptr %fpi
  %fend = icmp eq i8 %fci, 0
  br i1 %fend, label %fastendcheck, label %fastchar
fastchar:
  %fcsub = sub i8 %fci, 48
  %fcdig = icmp ult i8 %fcsub, 10
  br i1 %fcdig, label %fastdigit, label %fastcheckdot
fastdigit:
  %finext = add i64 %fi, 1
  br label %fastscan
fastcheckdot:
  %fisdot = icmp eq i8 %fci, 46
  %fnodot = xor i1 %fdot, true
  %fcandot = and i1 %fisdot, %fnodot
  br i1 %fcandot, label %fastdot, label %slowliteral
fastdot:
  %fdotnext = add i64 %fi, 1
  br label %fastscan
fastendcheck:
  %fprevp = getelementptr i8, ptr %fpi, i64 -1
  %fprevc = load i8, ptr %fprevp
  %ftrailingdot = icmp eq i8 %fprevc, 46
  br i1 %ftrailingdot, label %slowliteral, label %fastappend
fastappend:
  call void @buffer_append(ptr %b, ptr %literal, i64 %fi)
  ret void
slowliteral:
  %parts = call ptr @decimal_parts(ptr %literal)
  %lp = getelementptr %Decimal, ptr %parts, i32 0, i32 2
  %xp = getelementptr %Decimal, ptr %parts, i32 0, i32 3
  %dp = getelementptr %Decimal, ptr %parts, i32 0, i32 4
  %rawlen = load i64, ptr %lp
  %rawexp = load i64, ptr %xp
  %rawdata = load ptr, ptr %dp
  %zero = icmp eq i64 %rawlen, 0
  %length = select i1 %zero, i64 1, i64 %rawlen
  %zeroexp = add i64 %rawexp, 1
  %position = select i1 %zero, i64 %zeroexp, i64 %rawexp
  %data = select i1 %zero, ptr @text_digit_zero, ptr %rawdata
  %quantum = sub i64 %position, %length
  %exponent = sub i64 %position, 1
  %positivequantum = icmp sgt i64 %quantum, 0
  %tiny = icmp slt i64 %exponent, -6
  %scientific = or i1 %positivequantum, %tiny
  br i1 %minus, label %sign, label %format
sign:
  call void @buffer_byte(ptr %b, i8 45)
  br label %format
format:
  br i1 %scientific, label %scistart, label %fixedstart
scistart:
  %c = load i8, ptr %data
  call void @buffer_byte(ptr %b, i8 %c)
  %more = icmp ugt i64 %length, 1
  br i1 %more, label %scitail, label %sciexponent
scitail:
  call void @buffer_byte(ptr %b, i8 46)
  %tail = getelementptr i8, ptr %data, i64 1
  %tailn = sub i64 %length, 1
  call void @buffer_append(ptr %b, ptr %tail, i64 %tailn)
  br label %sciexponent
sciexponent:
  call void @buffer_byte(ptr %b, i8 69)
  %enegative = icmp slt i64 %exponent, 0
  %esign = select i1 %enegative, i8 45, i8 43
  call void @buffer_byte(ptr %b, i8 %esign)
  %enegated = sub i64 0, %exponent
  %eabs = select i1 %enegative, i64 %enegated, i64 %exponent
  call void @buffer_uint(ptr %b, i64 %eabs)
  ret void
fixedstart:
  %fraction = icmp sle i64 %position, 0
  br i1 %fraction, label %fractionstart, label %digits
fractionstart:
  call void @buffer_byte(ptr %b, i8 48)
  call void @buffer_byte(ptr %b, i8 46)
  %zeroes = sub i64 0, %position
  br label %zeroloop
zeroloop:
  %z = phi i64 [ 0, %fractionstart ], [ %zn, %zeroemit ]
  %zdone = icmp eq i64 %z, %zeroes
  br i1 %zdone, label %digits, label %zeroemit
zeroemit:
  call void @buffer_byte(ptr %b, i8 48)
  %zn = add i64 %z, 1
  br label %zeroloop
digits:
  br label %digitloop
digitloop:
  %i = phi i64 [ 0, %digits ], [ %next, %emit ]
  %done = icmp eq i64 %i, %length
  br i1 %done, label %end, label %dotcheck
dotcheck:
  %atpoint = icmp eq i64 %i, %position
  %positivepoint = icmp sgt i64 %position, 0
  %needot = and i1 %atpoint, %positivepoint
  br i1 %needot, label %dot, label %emit
dot:
  call void @buffer_byte(ptr %b, i8 46)
  br label %emit
emit:
  %p = getelementptr i8, ptr %data, i64 %i
  %byte = load i8, ptr %p
  call void @buffer_byte(ptr %b, i8 %byte)
  %next = add i64 %i, 1
  br label %digitloop
end:
  ret void
}

define internal i32 @decimal_compare(ptr %left, ptr %right) {
entry:
  %same = icmp eq ptr %left, %right
  br i1 %same, label %sameptr, label %start
sameptr:
  ret i32 0
start:
  %mark = alloca %ArenaMark
  call void @j_arena_mark(ptr %mark)
  %a = call ptr @decimal_parts(ptr %left)
  %b = call ptr @decimal_parts(ptr %right)
  %as = load i32, ptr %a
  %bs = load i32, ptr %b
  %samesign = icmp eq i32 %as, %bs
  br i1 %samesign, label %zerocheck, label %signorder
signorder:
  %signless = icmp slt i32 %as, %bs
  %signresult = select i1 %signless, i32 -1, i32 1
  call void @j_arena_rewind(ptr %mark)
  ret i32 %signresult
zerocheck:
  %zero = icmp eq i32 %as, 0
  br i1 %zero, label %equal, label %positions
positions:
  %axp = getelementptr %Decimal, ptr %a, i32 0, i32 3
  %bxp = getelementptr %Decimal, ptr %b, i32 0, i32 3
  %ax = load i64, ptr %axp
  %bx = load i64, ptr %bxp
  %sameposition = icmp eq i64 %ax, %bx
  br i1 %sameposition, label %digits, label %positionorder
positionorder:
  %positionless = icmp slt i64 %ax, %bx
  %positioncmp = select i1 %positionless, i32 -1, i32 1
  %positionresult = mul i32 %positioncmp, %as
  call void @j_arena_rewind(ptr %mark)
  ret i32 %positionresult
digits:
  %alp = getelementptr %Decimal, ptr %a, i32 0, i32 2
  %blp = getelementptr %Decimal, ptr %b, i32 0, i32 2
  %adp = getelementptr %Decimal, ptr %a, i32 0, i32 4
  %bdp = getelementptr %Decimal, ptr %b, i32 0, i32 4
  %al = load i64, ptr %alp
  %bl = load i64, ptr %blp
  %ad = load ptr, ptr %adp
  %bd = load ptr, ptr %bdp
  %longer = icmp ugt i64 %al, %bl
  %length = select i1 %longer, i64 %al, i64 %bl
  br label %loop
loop:
  %i = phi i64 [ 0, %digits ], [ %next, %advance ]
  %done = icmp eq i64 %i, %length
  br i1 %done, label %equal, label %leftcheck
leftcheck:
  %hasleft = icmp ult i64 %i, %al
  br i1 %hasleft, label %readleft, label %leftzero
readleft:
  %ap = getelementptr i8, ptr %ad, i64 %i
  %ac = load i8, ptr %ap
  br label %rightcheck
leftzero:
  br label %rightcheck
rightcheck:
  %av = phi i8 [ %ac, %readleft ], [ 48, %leftzero ]
  %hasright = icmp ult i64 %i, %bl
  br i1 %hasright, label %readright, label %rightzero
readright:
  %bp = getelementptr i8, ptr %bd, i64 %i
  %bc = load i8, ptr %bp
  br label %compare
rightzero:
  br label %compare
compare:
  %bv = phi i8 [ %bc, %readright ], [ 48, %rightzero ]
  %eq = icmp eq i8 %av, %bv
  br i1 %eq, label %advance, label %different
advance:
  %next = add i64 %i, 1
  br label %loop
different:
  %less = icmp ult i8 %av, %bv
  %cmp = select i1 %less, i32 -1, i32 1
  %result = mul i32 %cmp, %as
  call void @j_arena_rewind(ptr %mark)
  ret i32 %result
equal:
  call void @j_arena_rewind(ptr %mark)
  ret i32 0
}

define ptr @j_parse_stream(ptr %data, i64 %length, ptr %offset) {
entry:
  %oldmode = load i1, ptr @parse_stream_mode
  %oldpath = load ptr, ptr @parse_path
  %path = call ptr @j_array()
  store i1 true, ptr @parse_stream_mode
  store ptr %path, ptr @parse_path
  store ptr null, ptr @j_parse_error_path
  %value = call ptr @j_parse(ptr %data, i64 %length, ptr %offset)
  store i1 %oldmode, ptr @parse_stream_mode
  store ptr %oldpath, ptr @parse_path
  ret ptr %value
}

define internal void @json_path_begin(i1 %object) alwaysinline {
entry:
  %enabled = load i1, ptr @parse_stream_mode
  br i1 %enabled, label %begin, label %done
begin:
  %zero = call ptr @j_num(double 0.0)
  %value = select i1 %object, ptr @value_null, ptr %zero
  %path = load ptr, ptr @parse_path
  call void @j_push(ptr %path, ptr %value)
  br label %done
done:
  ret void
}

define internal void @json_path_set(ptr %value) alwaysinline {
entry:
  %enabled = load i1, ptr @parse_stream_mode
  br i1 %enabled, label %prepare, label %done
prepare:
  %path = load ptr, ptr @parse_path
  %lp = getelementptr %V, ptr %path, i32 0, i32 3
  %length = load i64, ptr %lp
  %nonempty = icmp ne i64 %length, 0
  br i1 %nonempty, label %set, label %done
set:
  %dp = getelementptr %V, ptr %path, i32 0, i32 5
  %data = load ptr, ptr %dp
  %index = sub i64 %length, 1
  %slot = getelementptr ptr, ptr %data, i64 %index
  store ptr %value, ptr %slot
  br label %done
done:
  ret void
}

define internal void @json_path_index(i64 %index) alwaysinline {
entry:
  %enabled = load i1, ptr @parse_stream_mode
  br i1 %enabled, label %set, label %done
set:
  %number = uitofp i64 %index to double
  %value = call ptr @j_num(double %number)
  call void @json_path_set(ptr %value)
  br label %done
done:
  ret void
}

define internal void @json_path_pop() alwaysinline {
entry:
  %enabled = load i1, ptr @parse_stream_mode
  br i1 %enabled, label %prepare, label %done
prepare:
  %path = load ptr, ptr @parse_path
  %lp = getelementptr %V, ptr %path, i32 0, i32 3
  %length = load i64, ptr %lp
  %nonempty = icmp ne i64 %length, 0
  br i1 %nonempty, label %pop, label %done
pop:
  %newlength = sub i64 %length, 1
  store i64 %newlength, ptr %lp
  br label %done
done:
  ret void
}

define internal ptr @json_unmatched_message(i8 %character) {
entry:
  %array = icmp eq i8 %character, 93
  %ordinary = select i1 %array, ptr @error_unmatched_array, ptr @error_unmatched_object
  %enabled = load i1, ptr @parse_stream_mode
  br i1 %enabled, label %stream, label %plain
plain:
  ret ptr %ordinary
stream:
  %path = load ptr, ptr @parse_path
  %lp = getelementptr %V, ptr %path, i32 0, i32 3
  %length = load i64, ptr %lp
  %empty = icmp eq i64 %length, 0
  br i1 %empty, label %top, label %nested
top:
  %topmessage = select i1 %array, ptr @error_stream_top_array, ptr @error_stream_top_object
  ret ptr %topmessage
nested:
  %last = call ptr @j_at(ptr %path, i64 -1)
  %tag = load i32, ptr %last
  %key = icmp eq i32 %tag, 4
  %objectmessage = select i1 %key, ptr @error_stream_missing_value, ptr @error_stream_middle_object
  %nestedmessage = select i1 %array, ptr @error_stream_middle_array, ptr %objectmessage
  ret ptr %nestedmessage
}

define ptr @j_parse(ptr %data, i64 %length, ptr %offset) {
entry:
  %depth = load i32, ptr @parse_depth
  %begin = load i64, ptr %offset
  %toodeep = icmp uge i32 %depth, 10000
  br i1 %toodeep, label %error, label %parse
error:
  %depthpos = add i64 %begin, 1
  call void @j_json_error(ptr %data, i64 %length, i64 %depthpos, ptr @error_parse_depth, i1 false)
  ret ptr null
parse:
  %next = add i32 %depth, 1
  store i32 %next, ptr @parse_depth
  %value = call ptr @parse_inner(ptr %data, i64 %length, ptr %offset)
  store i32 %depth, ptr @parse_depth
  %absent = icmp eq ptr %value, null
  br i1 %absent, label %done, label %literalcheck
literalcheck:
  %tag = load i32, ptr %value
  %literal = icmp ule i32 %tag, 3
  %stop = load i64, ptr %offset
  %hasnext = icmp ult i64 %stop, %length
  %check = and i1 %literal, %hasnext
  br i1 %check, label %boundary, label %done
boundary:
  %p = getelementptr i8, ptr %data, i64 %stop
  %c = load i8, ptr %p
  %valid = call i1 @json_boundary(i8 %c)
  br i1 %valid, label %done, label %invalidliteral
invalidliteral:
  %number = icmp eq i32 %tag, 3
  %literalmsg = select i1 %number, ptr @error_number, ptr @error_literal
  call void @json_token_error(ptr %data, i64 %length, i64 %begin, ptr %literalmsg)
  ret ptr null
done:
  ret ptr %value
}

define ptr @j_lex_number(ptr %data, i64 %length, ptr %offset) {
  %value = call ptr @json_number(ptr %data, i64 %length, ptr %offset)
  ret ptr %value
}

define internal ptr @json_special(ptr %data, i64 %length, ptr %offset) {
entry:
  %start = load i64, ptr %offset
  %p = getelementptr i8, ptr %data, i64 %start
  %c = load i8, ptr %p
  %minus = icmp eq i8 %c, 45
  %plus = icmp eq i8 %c, 43
  %signed = or i1 %minus, %plus
  %skip = zext i1 %signed to i64
  %begin = add i64 %start, %skip
  %remaining = sub i64 %length, %begin
  %short = icmp ult i64 %remaining, 3
  br i1 %short, label %no, label %first
first:
  %q = getelementptr i8, ptr %data, i64 %begin
  %firstbyte = load i8, ptr %q
  %lower = or i8 %firstbyte, 32
  %nan = icmp eq i8 %lower, 110
  %infinity = icmp eq i8 %lower, 105
  %possible = or i1 %nan, %infinity
  br i1 %possible, label %comparestart, label %no
comparestart:
  %target = select i1 %nan, ptr @text_nan_lower, ptr @text_infinity_lower
  br label %loop
loop:
  %i = phi i64 [ 0, %comparestart ], [ %next, %same ]
  %full = icmp eq i64 %i, 8
  %avail = icmp eq i64 %i, %remaining
  %done = or i1 %full, %avail
  br i1 %done, label %finishcheck, label %body
body:
  %tp = getelementptr i8, ptr %target, i64 %i
  %tc = load i8, ptr %tp
  %targetend = icmp eq i8 %tc, 0
  br i1 %targetend, label %finishcheck, label %bytecompare
bytecompare:
  %ip = getelementptr i8, ptr %q, i64 %i
  %ic = load i8, ptr %ip
  %ilower = or i8 %ic, 32
  %eq = icmp eq i8 %ilower, %tc
  br i1 %eq, label %same, label %finishcheck
same:
  %next = add i64 %i, 1
  br label %loop
finishcheck:
  %three = icmp eq i64 %i, 3
  %eight = icmp eq i64 %i, 8
  %infgood = and i1 %infinity, %eight
  %good = or i1 %three, %infgood
  br i1 %good, label %finish, label %no
finish:
  %after = add i64 %begin, %i
  store i64 %after, ptr %offset
  %positive = select i1 %nan, double 0x7FF8000000000000, double 0x7FF0000000000000
  %negative = fneg double %positive
  %number = select i1 %minus, double %negative, double %positive
  %value = call ptr @j_num(double %number)
  ret ptr %value
no:
  ret ptr null
}

define internal i1 @json_boundary(i8 %c) {
entry:
  switch i8 %c, label %no [ i8 32, label %yes i8 9, label %yes i8 10, label %yes i8 13, label %yes i8 91, label %yes i8 93, label %yes i8 123, label %yes i8 125, label %yes i8 44, label %yes i8 58, label %yes i8 34, label %yes ]
yes:
  ret i1 true
no:
  ret i1 false
}

define internal void @json_token_error(ptr %data, i64 %length, i64 %begin, ptr %message) {
entry:
  %start = call i64 @json_space(ptr %data, i64 %length, i64 %begin)
  br label %loop
loop:
  %i = phi i64 [ %start, %entry ], [ %next, %advance ]
  %end = icmp uge i64 %i, %length
  br i1 %end, label %eof, label %body
body:
  %p = getelementptr i8, ptr %data, i64 %i
  %c = load i8, ptr %p
  %boundary = call i1 @json_boundary(i8 %c)
  br i1 %boundary, label %separator, label %advance
advance:
  %next = add i64 %i, 1
  br label %loop
separator:
  %after = add i64 %i, 1
  call void @j_json_error(ptr %data, i64 %length, i64 %after, ptr %message, i1 false)
  ret void
eof:
  call void @j_json_error(ptr %data, i64 %length, i64 %length, ptr %message, i1 true)
  ret void
}

define void @j_json_error(ptr %data, i64 %length, i64 %position, ptr %message, i1 %eof) {
entry:
  store i64 %position, ptr @j_parse_error_offset
  store i1 %eof, ptr @j_parse_error_eof
  store ptr %message, ptr @j_parse_error_message
  %streammode = load i1, ptr @parse_stream_mode
  br i1 %streammode, label %streampath, label %emptypath
streampath:
  %path = load ptr, ptr @parse_path
  %copypath = call ptr @j_clone(ptr %path)
  br label %errorpath
emptypath:
  %empty = call ptr @j_array()
  br label %errorpath
errorpath:
  %resultpath = phi ptr [ %copypath, %streampath ], [ %empty, %emptypath ]
  store ptr %resultpath, ptr @j_parse_error_path
  %b = call ptr @buffer_new()
  %mlen = call i64 @j_strlen(ptr %message)
  call void @buffer_append(ptr %b, ptr %message, i64 %mlen)
  br i1 %eof, label %ateof, label %locate
ateof:
  call void @buffer_append(ptr %b, ptr @text_at_eof, i64 7)
  br label %locate
locate:
  call void @buffer_append(ptr %b, ptr @text_at_line, i64 9)
  br label %loop
loop:
  %i = phi i64 [ 0, %locate ], [ %next, %body ]
  %line = phi i64 [ 1, %locate ], [ %newlineno, %body ]
  %column = phi i64 [ 0, %locate ], [ %newcolumn, %body ]
  %atpos = icmp uge i64 %i, %position
  %atend = icmp uge i64 %i, %length
  %done = or i1 %atpos, %atend
  br i1 %done, label %finish, label %body
body:
  %p = getelementptr i8, ptr %data, i64 %i
  %c = load i8, ptr %p
  %newline = icmp eq i8 %c, 10
  %linenext = add i64 %line, 1
  %columnnext = add i64 %column, 1
  %newlineno = select i1 %newline, i64 %linenext, i64 %line
  %newcolumn = select i1 %newline, i64 0, i64 %columnnext
  %next = add i64 %i, 1
  br label %loop
finish:
  call void @buffer_uint(ptr %b, i64 %line)
  call void @buffer_append(ptr %b, ptr @text_column, i64 9)
  call void @buffer_uint(ptr %b, i64 %column)
  call void @buffer_append(ptr %b, ptr @text_while_parsing, i64 17)
  call void @buffer_append(ptr %b, ptr %data, i64 %length)
  call void @buffer_append(ptr %b, ptr @text_parse_end, i64 2)
  %error = call ptr @buffer_value(ptr %b)
  store ptr %error, ptr @j_error
  ret void
}

define i32 @j_cmp(ptr %left, ptr %right) {
entry:
  %depth = load i32, ptr @compare_depth
  %toodeep = icmp ugt i32 %depth, 10000
  br i1 %toodeep, label %error, label %compare
error:
  %message = load ptr, ptr @compare_message
  call void @j_fail(ptr %message)
  ret i32 0
compare:
  %next = add i32 %depth, 1
  store i32 %next, ptr @compare_depth
  %result = call i32 @cmp_inner(ptr %left, ptr %right)
  store i32 %depth, ptr @compare_depth
  ret i32 %result
}

define ptr @j_binary(i32 %op, ptr %left, ptr %right) {
entry:
  %lt = load i32, ptr %left
  %rt = load i32, ptr %right
  %lobj = icmp eq i32 %lt, 6
  %robj = icmp eq i32 %rt, 6
  %both = and i1 %lobj, %robj
  %multiply = icmp eq i32 %op, 2
  %merge = and i1 %both, %multiply
  br i1 %merge, label %depthcheck, label %other
depthcheck:
  %depth = load i32, ptr @merge_depth
  %toodeep = icmp ugt i32 %depth, 10000
  br i1 %toodeep, label %error, label %merging
error:
  call void @j_fail(ptr @error_merge_depth)
  ret ptr @value_null
merging:
  %next = add i32 %depth, 1
  store i32 %next, ptr @merge_depth
  %merged = call ptr @binary_inner(i32 %op, ptr %left, ptr %right)
  store i32 %depth, ptr @merge_depth
  ret ptr %merged
other:
  %result = call ptr @binary_inner(i32 %op, ptr %left, ptr %right)
  ret ptr %result
}
