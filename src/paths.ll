@j_error = external global ptr
@pick_arity = private constant [27 x i8] c"pick requires one argument\00"

declare ptr @j_array()
declare ptr @j_null()
declare ptr @j_at(ptr, i64)
declare i64 @b_len(ptr)
declare ptr @b_one(ptr)
declare void @j_fail(ptr)
declare ptr @ev_paths(ptr, ptr, ptr)
declare ptr @ev_fetchpath(ptr, ptr)
declare ptr @ev_storepath(ptr, ptr, i64, ptr)

define ptr @j_pick(ptr %args, ptr %input, ptr %env) {
entry:
  %argc = call i64 @b_len(ptr %args)
  %one = icmp eq i64 %argc, 1
  br i1 %one, label %capture, label %badarity
badarity:
  call void @j_fail(ptr @pick_arity)
  %bad = call ptr @j_array()
  ret ptr %bad
capture:
  %ast = call ptr @j_at(ptr %args, i64 0)
  %paths = call ptr @ev_paths(ptr %ast, ptr %input, ptr %env)
  %n = call i64 @b_len(ptr %paths)
  %initial = call ptr @j_null()
  br label %loop
loop:
  %i = phi i64 [ 0, %capture ], [ %next, %store ]
  %value = phi ptr [ %initial, %capture ], [ %updated, %store ]
  %done = icmp uge i64 %i, %n
  %pending = load ptr, ptr @j_error
  %failed = icmp ne ptr %pending, null
  br i1 %failed, label %error, label %check
check:
  br i1 %done, label %finish, label %fetch
fetch:
  %path = call ptr @j_at(ptr %paths, i64 %i)
  %selected = call ptr @ev_fetchpath(ptr %input, ptr %path)
  %fetcherror = load ptr, ptr @j_error
  %fetchfailed = icmp ne ptr %fetcherror, null
  br i1 %fetchfailed, label %error, label %store
store:
  %updated = call ptr @ev_storepath(ptr %value, ptr %path, i64 0, ptr %selected)
  %next = add i64 %i, 1
  br label %loop
finish:
  %out = call ptr @b_one(ptr %value)
  ret ptr %out
error:
  %empty = call ptr @j_array()
  ret ptr %empty
}
