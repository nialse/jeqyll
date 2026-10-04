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
@j_gc_pressure = global i64 0
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
  %head = load ptr, ptr @gc_old_state
  %mark = load ptr, ptr @gc_base_mark
  %cursorp = getelementptr %ArenaMark, ptr @gc_base_mark, i32 0, i32 1
  %markedcursor = load ptr, ptr %cursorp
  br label %loop
loop:
  %block = phi ptr [ %head, %entry ], [ %previous, %advance ]
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
  %inside = and i1 %afterbegin, %beforeend
  br i1 %inside, label %yes, label %nextcheck
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

; This work queue handles arbitrary JSON graph depth without native recursion.
; Forwarding is installed before enqueueing, so shared and cyclic graphs are
; processed only once even when callers construct internal cyclic values.
define ptr @j_gc_value(ptr %value) {
entry:
  %isnew = alloca i1
  %root = call ptr @j_gc_copy(ptr %value, i64 48, ptr %isnew)
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
  %stringbytes = add i64 %stringlength, 1
  %newstringdata = call ptr @j_gc_copy(ptr %stringdata, i64 %stringbytes, ptr %isnew)
  %newstringdatap = getelementptr %V, ptr %new, i32 0, i32 5
  store ptr %newstringdata, ptr %newstringdatap
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
  %newchild = call ptr @j_gc_copy(ptr %oldchild, i64 48, ptr %isnew)
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

define void @j_copy(ptr %dest, ptr %source, i64 %length) noinline optnone {
entry:
  br label %loop
loop:
  %i = phi i64 [ 0, %entry ], [ %next, %body ]
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
  ret void
}

define ptr @memcpy(ptr %dest, ptr %source, i64 %length) noinline optnone {
entry:
  call void @j_copy(ptr %dest, ptr %source, i64 %length)
  ret ptr %dest
}

define ptr @memset(ptr %dest, i32 %value, i64 %length) noinline optnone {
entry:
  %byte = trunc i32 %value to i8
  br label %loop
loop:
  %i = phi i64 [ 0, %entry ], [ %next, %body ]
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
  %v = call ptr @j_alloc(i64 48)
  store i32 4, ptr %v
  %n = add i64 %length, 1
  %data = call ptr @j_alloc(i64 %n)
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

define void @j_put(ptr %object, ptr %key, ptr %value) {
entry:
  %tag = load i32, ptr %key
  %valid = icmp eq i32 %tag, 4
  br i1 %valid, label %start, label %error
error:
  call void @j_fail(ptr @error_key)
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
  %cmp = call i32 @j_cmp(ptr %k, ptr %key)
  %equal = icmp eq i32 %cmp, 0
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
  %cmp = call i32 @j_cmp(ptr %k, ptr %key)
  %equal = icmp eq i32 %cmp, 0
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
  %isobj = icmp eq i32 %tag, 6
  %width = select i1 %isobj, i64 16, i64 8
  %bytes = mul i64 %len, %width
  %data = load ptr, ptr %dp
  %newdata = call ptr @j_alloc(i64 %bytes)
  call void @j_copy(ptr %newdata, ptr %data, i64 %bytes)
  store i64 %len, ptr %cp
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
  %llitp = getelementptr %V, ptr %left, i32 0, i32 6
  %rlitp = getelementptr %V, ptr %right, i32 0, i32 6
  %llit = load ptr, ptr %llitp
  %rlit = load ptr, ptr %rlitp
  %ldec = icmp ne ptr %llit, null
  %rdec = icmp ne ptr %rlit, null
  %bothdecimal = and i1 %ldec, %rdec
  br i1 %bothdecimal, label %decimalnumbers, label %binarynumbers
decimalnumbers:
  %dc = call i32 @decimal_compare(ptr %llit, ptr %rlit)
  ret i32 %dc
binarynumbers:
  %lnp = getelementptr %V, ptr %left, i32 0, i32 2
  %rnp = getelementptr %V, ptr %right, i32 0, i32 2
  %ln = load double, ptr %lnp
  %rn = load double, ptr %rnp
  %ne = fcmp oeq double %ln, %rn
  %nl = fcmp ult double %ln, %rn
  %no = select i1 %nl, i32 -1, i32 1
  %nr = select i1 %ne, i32 0, i32 %no
  ret i32 %nr
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
  %truncated = icmp ugt i64 %stop, %length
  br i1 %truncated, label %invalid, label %decode
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
  br label %loop
validate:
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

define internal i64 @json_space(ptr %data, i64 %length, i64 %start) {
entry:
  br label %loop
loop:
  %i = phi i64 [ %start, %entry ], [ %next, %skip ], [ %bomnext, %bomskip ]
  %end = icmp uge i64 %i, %length
  br i1 %end, label %done, label %body
body:
  %p = getelementptr i8, ptr %data, i64 %i
  %c = load i8, ptr %p
  %space = icmp eq i8 %c, 32
  %tab = icmp eq i8 %c, 9
  %lf = icmp eq i8 %c, 10
  %cr = icmp eq i8 %c, 13
  %w1 = or i1 %space, %tab
  %w2 = or i1 %lf, %cr
  %ws = or i1 %w1, %w2
  br i1 %ws, label %skip, label %bomcheck
skip:
  %next = add i64 %i, 1
  br label %loop
bomcheck:
  %bom = icmp eq i8 %c, -17
  %room = add i64 %i, 2
  %has = icmp ult i64 %room, %length
  %possible = and i1 %bom, %has
  br i1 %possible, label %bomrest, label %done
bomrest:
  %b1p = getelementptr i8, ptr %p, i64 1
  %b2p = getelementptr i8, ptr %p, i64 2
  %b1 = load i8, ptr %b1p
  %b2 = load i8, ptr %b2p
  %ok1 = icmp eq i8 %b1, -69
  %ok2 = icmp eq i8 %b2, -65
  %ok = and i1 %ok1, %ok2
  br i1 %ok, label %bomskip, label %done
bomskip:
  %bomnext = add i64 %i, 3
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
  %remaining = sub i64 %length, %begin
  %allocsize = mul i64 %remaining, 3
  %out = call ptr @j_alloc(i64 %allocsize)
  br label %loop
loop:
  %i = phi i64 [ %first, %entry ], [ %inext, %copy ], [ %escnext, %simple ], [ %unext, %unicodeout ], [ %utfnext, %utfout ]
  %o = phi i64 [ 0, %entry ], [ %onext, %copy ], [ %simpleonext, %simple ], [ %unicodeonext, %unicodeout ], [ %utfoutnext, %utfout ]
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
  %v = call ptr @j_str(ptr %out, i64 %o)
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
  %literal_value = call ptr @j_str(ptr %sp, i64 %literal_length)
  %ldp = getelementptr %V, ptr %literal_value, i32 0, i32 5
  %literal = load ptr, ptr %ldp
  %signednumber = call double @j_decimal_to_double(ptr %literal)
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
  %key = call ptr @j_parse(ptr %data, i64 %length, ptr %offset)
  %kfailed = icmp eq ptr %key, null
  br i1 %kfailed, label %childfailure, label %keycheck
keycheck:
  %kt = load i32, ptr %key
  %stringkey = icmp eq i32 %kt, 4
  br i1 %stringkey, label %colonspace, label %keytypeerror
keytypeerror:
  %badkeyend = load i64, ptr %offset
  %badkeycolon = call i64 @json_space(ptr %data, i64 %length, i64 %badkeyend)
  %badkeyafter = add i64 %badkeycolon, 1
  call void @j_json_error(ptr %data, i64 %length, i64 %badkeyafter, ptr @error_object_keys, i1 false)
  ret ptr null
colonspace:
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
  %p = alloca i8
  store i8 %c, ptr %p
  call void @buffer_append(ptr %b, ptr %p, i64 1)
  ret void
}

define internal ptr @buffer_value(ptr %b) {
  %lp = getelementptr %Buffer, ptr %b, i32 0, i32 1
  %len = load i64, ptr %lp
  %data = load ptr, ptr %b
  %v = call ptr @j_str(ptr %data, i64 %len)
  ret ptr %v
}

define internal void @buffer_uint(ptr %b, i64 %n) {
entry:
  %digits = alloca [24 x i8]
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
  %end = icmp eq i64 %i, 0
  br i1 %end, label %finish, label %body
body:
  %previous = sub i64 %i, 1
  %p = getelementptr i8, ptr %digits, i64 %previous
  %c = load i8, ptr %p
  call void @buffer_byte(ptr %b, i8 %c)
  br label %reverse
finish:
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

define double @j_decimal_to_double(ptr %literal) {
entry:
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
  %large = icmp sge i32 %exponent, 21
  %small = icmp slt i32 %exponent, -6
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

define internal void @dump_indent(ptr %b, i32 %depth) {
entry:
  call void @buffer_byte(ptr %b, i8 10)
  %width = load i32, ptr @j_indent
  %tab = icmp slt i32 %width, 0
  %spaces = mul i32 %depth, %width
  %count = select i1 %tab, i32 %depth, i32 %spaces
  %c = select i1 %tab, i8 9, i8 32
  br label %loop
loop:
  %i = phi i32 [ 0, %entry ], [ %next, %body ]
  %done = icmp sge i32 %i, %count
  br i1 %done, label %end, label %body
body:
  call void @buffer_byte(ptr %b, i8 %c)
  %next = add i32 %i, 1
  br label %loop
end:
  ret void
}

define internal void @dump_hex4(ptr %b, i32 %codepoint) {
entry:
  call void @buffer_byte(ptr %b, i8 92)
  call void @buffer_byte(ptr %b, i8 117)
  br label %loop
loop:
  %shift = phi i32 [ 12, %entry ], [ %next, %loop ]
  %part = lshr i32 %codepoint, %shift
  %hex = and i32 %part, 15
  %p = getelementptr i8, ptr @hex_digits, i32 %hex
  %c = load i8, ptr %p
  call void @buffer_byte(ptr %b, i8 %c)
  %next = sub i32 %shift, 4
  %done = icmp eq i32 %shift, 0
  br i1 %done, label %end, label %loop
end:
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
  br label %loop
loop:
  %i = phi i64 [ 0, %entry ], [ %next, %plain ], [ %next, %shortescape ], [ %next, %control ], [ %unext, %unicodeend ]
  %done = icmp eq i64 %i, %length
  br i1 %done, label %end, label %body
body:
  %p = getelementptr i8, ptr %data, i64 %i
  %c = load i8, ptr %p
  %next = add i64 %i, 1
  switch i8 %c, label %ordinary [ i8 34, label %quote i8 92, label %slash i8 8, label %backspace i8 9, label %tab i8 10, label %newline i8 12, label %formfeed i8 13, label %return ]
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
  br label %loop
ordinary:
  %lowcontrol = icmp ult i8 %c, 32
  %delete = icmp eq i8 %c, 127
  %ctrl = or i1 %lowcontrol, %delete
  br i1 %ctrl, label %control, label %unicodecheck
control:
  %cc = zext i8 %c to i32
  call void @dump_hex4(ptr %b, i32 %cc)
  br label %loop
unicodecheck:
  %utf8 = icmp uge i8 %c, -128
  %escapeunicode = and i1 %ascii, %utf8
  br i1 %escapeunicode, label %unicode, label %plain
plain:
  call void @buffer_byte(ptr %b, i8 %c)
  br label %loop
unicode:
  store i64 %i, ptr %offset
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
  br label %loop
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
  %newliteral = phi ptr [ %positivebytes, %positive ], [ %out, %addminus ]
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
  %a = call ptr @decimal_parts(ptr %left)
  %b = call ptr @decimal_parts(ptr %right)
  %as = load i32, ptr %a
  %bs = load i32, ptr %b
  %samesign = icmp eq i32 %as, %bs
  br i1 %samesign, label %zerocheck, label %signorder
signorder:
  %signless = icmp slt i32 %as, %bs
  %signresult = select i1 %signless, i32 -1, i32 1
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
  ret i32 %result
equal:
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

define internal void @json_path_begin(i1 %object) {
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

define internal void @json_path_set(ptr %value) {
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

define internal void @json_path_index(i64 %index) {
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

define internal void @json_path_pop() {
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
