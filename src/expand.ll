@expand_combinations = private constant [13 x i8] c"combinations\00"
@expand_walk = private constant [5 x i8] c"walk\00"
@expand_index = private constant [6 x i8] c"INDEX\00"
@expand_length = private constant [7 x i8] c"length\00"
@expand_range = private constant [6 x i8] c"range\00"
@expand_type = private constant [5 x i8] c"type\00"
@expand_map_values = private constant [11 x i8] c"map_values\00"
@expand_tostring = private constant [9 x i8] c"tostring\00"
@expand_object = private constant [7 x i8] c"object\00"
@expand_array = private constant [6 x i8] c"array\00"
@expand_product_name = private constant [2 x i8] c"\00C"
@expand_x_name = private constant [2 x i8] c"\00x"
@expand_y_name = private constant [2 x i8] c"\00y"
@expand_dot_name = private constant [2 x i8] c"\00d"
@expand_walker_name = private constant [2 x i8] c"\00w"
@expand_row_name = private constant [2 x i8] c"\00r"

declare ptr @ev_node(i32, i32, ptr, ptr, ptr, ptr)
declare ptr @j_str(ptr, i64)
declare ptr @j_cstr(ptr)
declare ptr @j_num(double)
declare ptr @j_array()
declare ptr @j_object()
declare void @j_push(ptr, ptr)
declare ptr @j_at(ptr, i64)
declare i1 @j_is(ptr, ptr)
declare i64 @b_len(ptr)

define internal ptr @expand_literal(ptr %value) {
  %node = call ptr @ev_node(i32 0, i32 0, ptr %value, ptr null, ptr null, ptr null)
  ret ptr %node
}

define internal ptr @expand_identity() {
  %node = call ptr @ev_node(i32 1, i32 0, ptr null, ptr null, ptr null, ptr null)
  ret ptr %node
}

define internal ptr @expand_variable(ptr %name) {
  %node = call ptr @ev_node(i32 10, i32 0, ptr %name, ptr null, ptr null, ptr null)
  ret ptr %node
}

define internal ptr @expand_pipe(ptr %left, ptr %right) {
  %node = call ptr @ev_node(i32 2, i32 0, ptr %left, ptr %right, ptr null, ptr null)
  ret ptr %node
}

define internal ptr @expand_bind(ptr %source, ptr %name, ptr %body) {
  %pattern = call ptr @expand_variable(ptr %name)
  %node = call ptr @ev_node(i32 11, i32 0, ptr %source, ptr %pattern, ptr %body, ptr null)
  ret ptr %node
}

define internal ptr @expand_definition(ptr %name, ptr %body, ptr %rest) {
  %params = call ptr @j_array()
  %node = call ptr @ev_node(i32 12, i32 0, ptr %name, ptr %params, ptr %body, ptr %rest)
  ret ptr %node
}

define internal ptr @expand_private_call(ptr %name) {
  %args = call ptr @j_array()
  %node = call ptr @ev_node(i32 7, i32 0, ptr %name, ptr %args, ptr null, ptr null)
  ret ptr %node
}

; Call op -2 selects an intrinsic without looking through user lexical bindings.
define internal ptr @expand_intrinsic(ptr %text, ptr %argument) {
entry:
  %name = call ptr @j_cstr(ptr %text)
  %args = call ptr @j_array()
  %hasarg = icmp ne ptr %argument, null
  br i1 %hasarg, label %append, label %call
append:
  call void @j_push(ptr %args, ptr %argument)
  br label %call
call:
  %node = call ptr @ev_node(i32 7, i32 -2, ptr %name, ptr %args, ptr null, ptr null)
  ret ptr %node
}

; The product is a recursive generator. Only the chosen prefix and pending
; continuations survive between results, rather than a complete product array.
define internal ptr @expand_product(ptr %args, i64 %arity) {
entry:
  %name = call ptr @j_str(ptr @expand_product_name, i64 2)
  %xname = call ptr @j_str(ptr @expand_x_name, i64 2)
  %yname = call ptr @j_str(ptr @expand_y_name, i64 2)
  %identity = call ptr @expand_identity()
  %zero = call ptr @j_num(double 0.0)
  %one = call ptr @j_num(double 1.0)
  %zeronode = call ptr @expand_literal(ptr %zero)
  %onenode = call ptr @expand_literal(ptr %one)
  %empty = call ptr @j_array()
  %emptynode = call ptr @expand_literal(ptr %empty)
  %length = call ptr @expand_intrinsic(ptr @expand_length, ptr null)
  %finished = call ptr @ev_node(i32 4, i32 5, ptr %length, ptr %zeronode, ptr null, ptr null)
  %head = call ptr @ev_node(i32 5, i32 0, ptr %identity, ptr %zeronode, ptr null, ptr null)
  %choices = call ptr @ev_node(i32 6, i32 0, ptr %head, ptr null, ptr null, ptr null)
  %tail = call ptr @ev_node(i32 20, i32 0, ptr %identity, ptr %onenode, ptr null, ptr null)
  %recurse = call ptr @expand_private_call(ptr %name)
  %suffixes = call ptr @expand_pipe(ptr %tail, ptr %recurse)
  %x = call ptr @expand_variable(ptr %xname)
  %y = call ptr @expand_variable(ptr %yname)
  %prefix = call ptr @ev_node(i32 8, i32 0, ptr %x, ptr null, ptr null, ptr null)
  %combined = call ptr @ev_node(i32 4, i32 0, ptr %prefix, ptr %y, ptr null, ptr null)
  %eachsuffix = call ptr @expand_bind(ptr %suffixes, ptr %yname, ptr %combined)
  %eachchoice = call ptr @expand_bind(ptr %choices, ptr %xname, ptr %eachsuffix)
  %body = call ptr @ev_node(i32 13, i32 0, ptr %finished, ptr %emptynode, ptr %eachchoice, ptr null)
  %invoke = call ptr @expand_private_call(ptr %name)
  %repeat = icmp eq i64 %arity, 1
  br i1 %repeat, label %repeated, label %plain
repeated:
  %dotname = call ptr @j_str(ptr @expand_dot_name, i64 2)
  %dot = call ptr @expand_variable(ptr %dotname)
  %n = call ptr @j_at(ptr %args, i64 0)
  %range = call ptr @expand_intrinsic(ptr @expand_range, ptr %n)
  %repetitions = call ptr @expand_pipe(ptr %range, ptr %dot)
  %sets = call ptr @ev_node(i32 8, i32 0, ptr %repetitions, ptr null, ptr null, ptr null)
  %product = call ptr @expand_pipe(ptr %sets, ptr %invoke)
  %capture = call ptr @expand_bind(ptr %identity, ptr %dotname, ptr %product)
  %repeateddefinition = call ptr @expand_definition(ptr %name, ptr %body, ptr %capture)
  ret ptr %repeateddefinition
plain:
  %definition = call ptr @expand_definition(ptr %name, ptr %body, ptr %invoke)
  ret ptr %definition
}

; Post-order transformation. Array mapping uses the ordinary array collector;
; object mapping takes the first result per key, including key removal on empty.
define internal ptr @expand_postorder(ptr %args) {
entry:
  %name = call ptr @j_str(ptr @expand_walker_name, i64 2)
  %identity = call ptr @expand_identity()
  %recurse = call ptr @expand_private_call(ptr %name)
  %type = call ptr @expand_intrinsic(ptr @expand_type, ptr null)
  %objecttext = call ptr @j_cstr(ptr @expand_object)
  %arraytext = call ptr @j_cstr(ptr @expand_array)
  %objectliteral = call ptr @expand_literal(ptr %objecttext)
  %arrayliteral = call ptr @expand_literal(ptr %arraytext)
  %isobject = call ptr @ev_node(i32 4, i32 5, ptr %type, ptr %objectliteral, ptr null, ptr null)
  %isarray = call ptr @ev_node(i32 4, i32 5, ptr %type, ptr %arrayliteral, ptr null, ptr null)
  %objectwalk = call ptr @expand_intrinsic(ptr @expand_map_values, ptr %recurse)
  %elements = call ptr @ev_node(i32 6, i32 0, ptr %identity, ptr null, ptr null, ptr null)
  %children = call ptr @expand_pipe(ptr %elements, ptr %recurse)
  %arraywalk = call ptr @ev_node(i32 8, i32 0, ptr %children, ptr null, ptr null, ptr null)
  %arraybranch = call ptr @ev_node(i32 13, i32 0, ptr %isarray, ptr %arraywalk, ptr %identity, ptr null)
  %mapped = call ptr @ev_node(i32 13, i32 0, ptr %isobject, ptr %objectwalk, ptr %arraybranch, ptr null)
  %filter = call ptr @j_at(ptr %args, i64 0)
  %body = call ptr @expand_pipe(ptr %mapped, ptr %filter)
  %invoke = call ptr @expand_private_call(ptr %name)
  %definition = call ptr @expand_definition(ptr %name, ptr %body, ptr %invoke)
  ret ptr %definition
}

define internal ptr @expand_index_rows(ptr %args, i64 %arity) {
entry:
  %identity = call ptr @expand_identity()
  %explicit = icmp eq i64 %arity, 2
  br i1 %explicit, label %stream, label %array
stream:
  %streamfilter = call ptr @j_at(ptr %args, i64 0)
  %streamindex = call ptr @j_at(ptr %args, i64 1)
  br label %reduce
array:
  %elements = call ptr @ev_node(i32 6, i32 0, ptr %identity, ptr null, ptr null, ptr null)
  %arrayindex = call ptr @j_at(ptr %args, i64 0)
  br label %reduce
reduce:
  %source = phi ptr [ %streamfilter, %stream ], [ %elements, %array ]
  %index = phi ptr [ %streamindex, %stream ], [ %arrayindex, %array ]
  %rowname = call ptr @j_str(ptr @expand_row_name, i64 2)
  %row = call ptr @expand_variable(ptr %rowname)
  %indexvalue = call ptr @expand_pipe(ptr %row, ptr %index)
  %stringify = call ptr @expand_intrinsic(ptr @expand_tostring, ptr null)
  %key = call ptr @expand_pipe(ptr %indexvalue, ptr %stringify)
  %path = call ptr @ev_node(i32 5, i32 0, ptr %identity, ptr %key, ptr null, ptr null)
  %update = call ptr @ev_node(i32 19, i32 61, ptr %path, ptr %row, ptr null, ptr null)
  %object = call ptr @j_object()
  %initial = call ptr @expand_literal(ptr %object)
  %reducer = call ptr @ev_node(i32 18, i32 279, ptr %source, ptr %row, ptr %initial, ptr %update)
  ret ptr %reducer
}

define ptr @j_expand_builtin(ptr %name, ptr %args, ptr %input, ptr %env) {
entry:
  %arity = call i64 @b_len(ptr %args)
  %combinations = call i1 @j_is(ptr %name, ptr @expand_combinations)
  br i1 %combinations, label %productarity, label %walkcheck
productarity:
  %productvalid = icmp ule i64 %arity, 1
  br i1 %productvalid, label %product, label %unknown
product:
  %productast = call ptr @expand_product(ptr %args, i64 %arity)
  ret ptr %productast
walkcheck:
  %walk = call i1 @j_is(ptr %name, ptr @expand_walk)
  br i1 %walk, label %walkarity, label %indexcheck
walkarity:
  %walkvalid = icmp eq i64 %arity, 1
  br i1 %walkvalid, label %postorder, label %unknown
postorder:
  %walkast = call ptr @expand_postorder(ptr %args)
  ret ptr %walkast
indexcheck:
  %index = call i1 @j_is(ptr %name, ptr @expand_index)
  %indexone = icmp eq i64 %arity, 1
  %indextwo = icmp eq i64 %arity, 2
  %indexarity = or i1 %indexone, %indextwo
  %indexvalid = and i1 %index, %indexarity
  br i1 %indexvalid, label %rows, label %unknown
rows:
  %indexast = call ptr @expand_index_rows(ptr %args, i64 %arity)
  ret ptr %indexast
unknown:
  ret ptr null
}
