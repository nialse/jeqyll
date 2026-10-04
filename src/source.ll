%SV = type { i32, i32, double, i64, i64, ptr, ptr }

@j_environ = external global ptr
@j_library_paths = external global ptr
@source_home = private constant [5 x i8] c"HOME\00"
@source_jq = private constant [5 x i8] c"/.jq\00"

declare ptr @j_cstr(ptr)
declare ptr @j_get(ptr, ptr)
declare ptr @j_binary(i32, ptr, ptr)
declare void @j_push(ptr, ptr)
declare ptr @j_alloc(i64)
declare ptr @j_read_file(ptr)
declare ptr @j_buffer_new()
declare void @j_buffer_append(ptr, ptr, i64)
declare void @j_buffer_byte(ptr, i8)
declare ptr @j_buffer_value(ptr)
declare i32 @stat(ptr, ptr)

define internal void @source_append(ptr %buffer, ptr %value) {
  %np = getelementptr %SV, ptr %value, i32 0, i32 3
  %n = load i64, ptr %np
  %dp = getelementptr %SV, ptr %value, i32 0, i32 5
  %data = load ptr, ptr %dp
  call void @j_buffer_append(ptr %buffer, ptr %data, i64 %n)
  ret void
}

define ptr @j_home_source(ptr %program) {
entry:
  %env = load ptr, ptr @j_environ
  %key = call ptr @j_cstr(ptr @source_home)
  %home = call ptr @j_get(ptr %env, ptr %key)
  %tag = load i32, ptr %home
  %string = icmp eq i32 %tag, 4
  br i1 %string, label %path, label %unchanged
path:
  %suffix = call ptr @j_cstr(ptr @source_jq)
  %pathvalue = call ptr @j_binary(i32 0, ptr %home, ptr %suffix)
  %dp = getelementptr %SV, ptr %pathvalue, i32 0, i32 5
  %bytes = load ptr, ptr %dp
  %info = call ptr @j_alloc(i64 120)
  %status = call i32 @stat(ptr %bytes, ptr %info)
  %ok = icmp eq i32 %status, 0
  br i1 %ok, label %mode, label %unchanged
mode:
  %modep = getelementptr i8, ptr %info, i64 24
  %bits = load i32, ptr %modep
  %type = and i32 %bits, 61440
  switch i32 %type, label %unchanged [ i32 16384, label %directory i32 32768, label %file ]
directory:
  %paths = load ptr, ptr @j_library_paths
  call void @j_push(ptr %paths, ptr %pathvalue)
  br label %unchanged
file:
  %contents = call ptr @j_read_file(ptr %bytes)
  %read = icmp ne ptr %contents, null
  br i1 %read, label %prepend, label %unchanged
prepend:
  %buffer = call ptr @j_buffer_new()
  call void @source_append(ptr %buffer, ptr %contents)
  call void @j_buffer_byte(ptr %buffer, i8 10)
  call void @source_append(ptr %buffer, ptr %program)
  %result = call ptr @j_buffer_value(ptr %buffer)
  ret ptr %result
unchanged:
  ret ptr %program
}
