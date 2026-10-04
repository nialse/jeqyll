@j_environ = external global ptr
@source_home = private constant [5 x i8] c"HOME\00"
@source_empty = private constant [1 x i8] zeroinitializer
@source_optional = private constant [9 x i8] c"optional\00"
@source_search = private constant [7 x i8] c"search\00"

declare ptr @j_cstr(ptr)
declare ptr @j_get(ptr, ptr)
declare ptr @j_object()
declare ptr @j_bool(i1)
declare void @j_put(ptr, ptr, ptr)
declare ptr @ev_node(i32, i32, ptr, ptr, ptr, ptr)

define ptr @j_home_ast(ptr %program) {
entry:
  %env = load ptr, ptr @j_environ
  %hasenv = icmp ne ptr %env, null
  br i1 %hasenv, label %lookup, label %unchanged
lookup:
  %key = call ptr @j_cstr(ptr @source_home)
  %home = call ptr @j_get(ptr %env, ptr %key)
  %tag = load i32, ptr %home
  %string = icmp eq i32 %tag, 4
  br i1 %string, label %wrap, label %unchanged
wrap:
  %path = call ptr @j_cstr(ptr @source_empty)
  %optionalkey = call ptr @j_cstr(ptr @source_optional)
  %searchkey = call ptr @j_cstr(ptr @source_search)
  %true = call ptr @j_bool(i1 true)
  %metadata = call ptr @j_object()
  call void @j_put(ptr %metadata, ptr %optionalkey, ptr %true)
  call void @j_put(ptr %metadata, ptr %searchkey, ptr %home)
  %import = call ptr @ev_node(i32 24, i32 0, ptr %path, ptr null, ptr %program, ptr %metadata)
  ret ptr %import
unchanged:
  ret ptr %program
}
