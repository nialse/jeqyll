%CV = type { i32, i32, double, i64, i64, ptr, ptr }
%CN = type { i32, i32, ptr, ptr, ptr, ptr, ptr, i64, i64 }
%CE = type { ptr, ptr, ptr, i32, ptr, ptr }
%CW = type { ptr, i32, i32, ptr, ptr, ptr, ptr, ptr, ptr, ptr, i64 }
%CK = type { i32, i32, ptr, ptr, ptr, ptr, ptr, ptr, ptr, i64 }

@collect_queue = internal global ptr null
@collect_mark = internal global [3 x i64] zeroinitializer
@j_collect_enabled = global i1 false
@ev_module_cache = external global ptr
@collect_sizes = private constant [12 x i64] [i64 48, i64 64, i64 48, i64 80, i64 72, i64 48, i64 64, i64 8, i64 48, i64 8, i64 48, i64 32]
@collect_nodes = private constant [28 x [5 x i8]] [
  [5 x i8] zeroinitializer,
  [5 x i8] zeroinitializer,
  [5 x i8] [i8 1,i8 1,i8 0,i8 0,i8 0],
  [5 x i8] [i8 1,i8 1,i8 0,i8 0,i8 0],
  [5 x i8] [i8 1,i8 1,i8 0,i8 0,i8 0],
  [5 x i8] [i8 1,i8 1,i8 0,i8 0,i8 0],
  [5 x i8] [i8 1,i8 0,i8 0,i8 0,i8 0],
  [5 x i8] [i8 0,i8 8,i8 0,i8 0,i8 0],
  [5 x i8] [i8 1,i8 0,i8 0,i8 0,i8 0],
  [5 x i8] [i8 8,i8 0,i8 0,i8 0,i8 0],
  [5 x i8] zeroinitializer,
  [5 x i8] [i8 1,i8 1,i8 1,i8 0,i8 0],
  [5 x i8] [i8 0,i8 8,i8 1,i8 1,i8 0],
  [5 x i8] [i8 1,i8 1,i8 1,i8 0,i8 0],
  [5 x i8] [i8 1,i8 1,i8 0,i8 0,i8 0],
  [5 x i8] [i8 1,i8 0,i8 0,i8 0,i8 0],
  [5 x i8] [i8 1,i8 0,i8 0,i8 0,i8 0],
  [5 x i8] zeroinitializer,
  [5 x i8] [i8 1,i8 1,i8 1,i8 1,i8 1],
  [5 x i8] [i8 1,i8 1,i8 0,i8 0,i8 0],
  [5 x i8] [i8 1,i8 1,i8 1,i8 0,i8 0],
  [5 x i8] [i8 1,i8 1,i8 0,i8 0,i8 0],
  [5 x i8] [i8 0,i8 1,i8 0,i8 0,i8 0],
  [5 x i8] zeroinitializer,
  [5 x i8] [i8 0,i8 0,i8 1,i8 0,i8 0],
  [5 x i8] [i8 0,i8 1,i8 0,i8 0,i8 0],
  [5 x i8] zeroinitializer,
  [5 x i8] [i8 8,i8 0,i8 0,i8 0,i8 0]
]
@collect_conts = private constant [34 x [4 x i8]] [
  [4 x i8] zeroinitializer,
  [4 x i8] [i8 1,i8 0,i8 0,i8 0],
  [4 x i8] [i8 1,i8 0,i8 0,i8 0],
  [4 x i8] zeroinitializer,
  [4 x i8] [i8 1,i8 0,i8 0,i8 0],
  [4 x i8] zeroinitializer,
  [4 x i8] zeroinitializer,
  [4 x i8] zeroinitializer,
  [4 x i8] [i8 1,i8 1,i8 0,i8 0],
  [4 x i8] [i8 1,i8 1,i8 0,i8 0],
  [4 x i8] zeroinitializer,
  [4 x i8] [i8 9,i8 0,i8 0,i8 0],
  [4 x i8] [i8 8,i8 0,i8 0,i8 1],
  [4 x i8] [i8 8,i8 0,i8 0,i8 0],
  [4 x i8] [i8 6,i8 0,i8 0,i8 0],
  [4 x i8] zeroinitializer,
  [4 x i8] [i8 8,i8 0,i8 0,i8 0],
  [4 x i8] [i8 8,i8 0,i8 0,i8 0],
  [4 x i8] zeroinitializer,
  [4 x i8] [i8 1,i8 1,i8 0,i8 0],
  [4 x i8] [i8 1,i8 0,i8 0,i8 0],
  [4 x i8] [i8 1,i8 1,i8 0,i8 0],
  [4 x i8] [i8 1,i8 0,i8 0,i8 0],
  [4 x i8] [i8 1,i8 0,i8 0,i8 0],
  [4 x i8] zeroinitializer,
  [4 x i8] [i8 0,i8 1,i8 0,i8 0],
  [4 x i8] [i8 1,i8 0,i8 1,i8 0],
  [4 x i8] [i8 1,i8 0,i8 0,i8 0],
  [4 x i8] [i8 1,i8 1,i8 0,i8 0],
  [4 x i8] [i8 1,i8 0,i8 0,i8 0],
  [4 x i8] zeroinitializer,
  [4 x i8] [i8 1,i8 8,i8 0,i8 0],
  [4 x i8] [i8 1,i8 0,i8 0,i8 0],
  [4 x i8] [i8 8,i8 0,i8 0,i8 0]
]

declare ptr @j_gc_copy(ptr, i64, ptr)
declare ptr @j_gc_value(ptr)
declare void @j_gc_begin(ptr)
declare void @j_gc_end(ptr)
declare void @j_arena_mark(ptr)
declare ptr @j_array()
declare void @j_push(ptr, ptr)
declare ptr @j_at(ptr, i64)
declare i64 @b_len(ptr)
declare void @cli_trace()

define internal ptr @collect_copy(ptr %old, i32 %type) {
entry:
  %json = icmp eq i32 %type, 0
  br i1 %json, label %value, label %record
value:
  %v = call ptr @j_gc_value(ptr %old)
  ret ptr %v
record:
  %freshp = alloca i1
  %sizep = getelementptr [12 x i64], ptr @collect_sizes, i64 0, i32 %type
  %size = load i64, ptr %sizep
  %new = call ptr @j_gc_copy(ptr %old, i64 %size, ptr %freshp)
  %fresh = load i1, ptr %freshp
  br i1 %fresh, label %enqueue, label %done
enqueue:
  %queue = load ptr, ptr @collect_queue
  %typen = zext i32 %type to i64
  %typeptr = inttoptr i64 %typen to ptr
  call void @j_push(ptr %queue, ptr %typeptr)
  call void @j_push(ptr %queue, ptr %new)
  br label %done
done:
  ret ptr %new
}

define internal void @collect_field(ptr %record, i64 %offset, i32 %type) {
  %slot = getelementptr i8, ptr %record, i64 %offset
  %old = load ptr, ptr %slot
  %new = call ptr @collect_copy(ptr %old, i32 %type)
  store ptr %new, ptr %slot
  ret void
}

define void @j_collect_start() {
  call void @j_arena_mark(ptr @collect_mark)
  store i1 true, ptr @j_collect_enabled
  ret void
}

define void @j_collect(ptr %iterator) {
entry:
  %freshp = alloca i1
  call void @j_gc_begin(ptr @collect_mark)
  %queue = call ptr @j_array()
  store ptr %queue, ptr @collect_queue
  call void @collect_field(ptr %iterator, i64 0, i32 3)
  call void @collect_field(ptr @ev_module_cache, i64 0, i32 10)
  call void @cli_trace()
  br label %loop
loop:
  %index = phi i64 [0, %entry], [%next, %advance]
  %length = call i64 @b_len(ptr %queue)
  %finished = icmp uge i64 %index, %length
  br i1 %finished, label %done, label %record
record:
  %typeptr = call ptr @j_at(ptr %queue, i64 %index)
  %typen = ptrtoint ptr %typeptr to i64
  %type = trunc i64 %typen to i32
  %valueindex = add i64 %index, 1
  %value = call ptr @j_at(ptr %queue, i64 %valueindex)
  switch i32 %type, label %advance [i32 1, label %node i32 2, label %environment i32 3, label %work i32 4, label %continuation i32 5, label %handler i32 6, label %arguments i32 7, label %childiterator i32 8, label %nodes i32 10, label %nodes i32 11, label %module]
node:
  %kind = load i32, ptr %value
  %ordinary = icmp ult i32 %kind, 28
  br i1 %ordinary, label %nodefields, label %specialnode
nodefields:
  br label %nodefield
nodefield:
  %field = phi i64 [0, %nodefields], [%fieldnext, %nodefieldcopy]
  %fieldsdone = icmp eq i64 %field, 5
  br i1 %fieldsdone, label %advance, label %nodefieldcopy
nodefieldcopy:
  %fieldtypep = getelementptr [28 x [5 x i8]], ptr @collect_nodes, i64 0, i32 %kind, i64 %field
  %fieldtypebyte = load i8, ptr %fieldtypep
  %fieldtype = zext i8 %fieldtypebyte to i32
  %fieldbytes = mul i64 %field, 8
  %fieldoffset = add i64 %fieldbytes, 8
  call void @collect_field(ptr %value, i64 %fieldoffset, i32 %fieldtype)
  %fieldnext = add i64 %field, 1
  br label %nodefield
specialnode:
  %range = icmp eq i32 %kind, 103
  %specialtype = select i1 %range, i32 0, i32 1
  call void @collect_field(ptr %value, i64 8, i32 %specialtype)
  call void @collect_field(ptr %value, i64 16, i32 %specialtype)
  call void @collect_field(ptr %value, i64 24, i32 0)
  call void @collect_field(ptr %value, i64 32, i32 0)
  br label %advance
environment:
  call void @collect_field(ptr %value, i64 0, i32 2)
  call void @collect_field(ptr %value, i64 8, i32 0)
  %envtypep = getelementptr %CE, ptr %value, i32 0, i32 3
  %envtype = load i32, ptr %envtypep
  %boundvalue = icmp eq i32 %envtype, 0
  %envvaluetype = select i1 %boundvalue, i32 0, i32 1
  call void @collect_field(ptr %value, i64 16, i32 %envvaluetype)
  call void @collect_field(ptr %value, i64 32, i32 8)
  call void @collect_field(ptr %value, i64 40, i32 2)
  br label %advance
work:
  call void @collect_field(ptr %value, i64 0, i32 3)
  call void @collect_field(ptr %value, i64 16, i32 1)
  call void @collect_field(ptr %value, i64 24, i32 0)
  call void @collect_field(ptr %value, i64 32, i32 2)
  call void @collect_field(ptr %value, i64 40, i32 4)
  call void @collect_field(ptr %value, i64 48, i32 5)
  %workkindp = getelementptr %CW, ptr %value, i32 0, i32 1
  %workkind = load i32, ptr %workkindp
  %consumer = icmp eq i32 %workkind, 6
  %fromstream = icmp eq i32 %workkind, 8
  %reduce = icmp eq i32 %workkind, 10
  %iter0 = or i1 %consumer, %fromstream
  %iter = or i1 %iter0, %reduce
  %tracker = icmp eq i32 %workkind, 5
  %watype0 = select i1 %iter, i32 7, i32 0
  %watype = select i1 %tracker, i32 9, i32 %watype0
  call void @collect_field(ptr %value, i64 56, i32 %watype)
  call void @collect_field(ptr %value, i64 64, i32 0)
  br label %advance
continuation:
  call void @collect_field(ptr %value, i64 8, i32 4)
  call void @collect_field(ptr %value, i64 16, i32 2)
  call void @collect_field(ptr %value, i64 24, i32 5)
  %contkind = load i32, ptr %value
  br label %contfield
contfield:
  %ci = phi i64 [0, %continuation], [%cinext, %contfieldcopy]
  %contdone = icmp eq i64 %ci, 4
  br i1 %contdone, label %advance, label %contfieldcopy
contfieldcopy:
  %conttypep = getelementptr [34 x [4 x i8]], ptr @collect_conts, i64 0, i32 %contkind, i64 %ci
  %conttypebyte = load i8, ptr %conttypep
  %conttype = zext i8 %conttypebyte to i32
  %contbytes = mul i64 %ci, 8
  %contoffset = add i64 %contbytes, 32
  call void @collect_field(ptr %value, i64 %contoffset, i32 %conttype)
  %cinext = add i64 %ci, 1
  br label %contfield
handler:
  call void @collect_field(ptr %value, i64 0, i32 5)
  call void @collect_field(ptr %value, i64 8, i32 1)
  call void @collect_field(ptr %value, i64 16, i32 2)
  call void @collect_field(ptr %value, i64 24, i32 4)
  call void @collect_field(ptr %value, i64 32, i32 3)
  call void @collect_field(ptr %value, i64 40, i32 0)
  br label %advance
arguments:
  call void @collect_field(ptr %value, i64 0, i32 1)
  call void @collect_field(ptr %value, i64 8, i32 8)
  call void @collect_field(ptr %value, i64 16, i32 8)
  call void @collect_field(ptr %value, i64 24, i32 0)
  call void @collect_field(ptr %value, i64 32, i32 2)
  call void @collect_field(ptr %value, i64 40, i32 2)
  call void @collect_field(ptr %value, i64 48, i32 0)
  br label %advance
childiterator:
  call void @collect_field(ptr %value, i64 0, i32 3)
  br label %advance
module:
  call void @collect_field(ptr %value, i64 0, i32 1)
  call void @collect_field(ptr %value, i64 8, i32 0)
  call void @collect_field(ptr %value, i64 16, i32 0)
  call void @collect_field(ptr %value, i64 24, i32 0)
  br label %advance
nodes:
  %modulearray = icmp eq i32 %type, 10
  %itemtype = select i1 %modulearray, i32 11, i32 1
  %lenp = getelementptr %CV, ptr %value, i32 0, i32 3
  %capacityp = getelementptr %CV, ptr %value, i32 0, i32 4
  %datap = getelementptr %CV, ptr %value, i32 0, i32 5
  %len = load i64, ptr %lenp
  %capacity = load i64, ptr %capacityp
  %data = load ptr, ptr %datap
  %bytes = mul i64 %capacity, 8
  %newdata = call ptr @j_gc_copy(ptr %data, i64 %bytes, ptr %freshp)
  store ptr %newdata, ptr %datap
  br label %nodeitem
nodeitem:
  %ni = phi i64 [0, %nodes], [%ninext, %nodeitemcopy]
  %nodesdone = icmp eq i64 %ni, %len
  br i1 %nodesdone, label %advance, label %nodeitemcopy
nodeitemcopy:
  %nibytes = mul i64 %ni, 8
  call void @collect_field(ptr %newdata, i64 %nibytes, i32 %itemtype)
  %ninext = add i64 %ni, 1
  br label %nodeitem
advance:
  %next = add i64 %index, 2
  br label %loop
done:
  store ptr null, ptr @collect_queue
  call void @j_gc_end(ptr @collect_mark)
  ret void
}
