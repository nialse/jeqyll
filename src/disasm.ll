%N = type { i32, i32, ptr, ptr, ptr, ptr, ptr, i64, i64 }
%E = type { ptr, ptr, ptr, i32, ptr, ptr }
%DS = type { ptr, ptr, i64 }

@j_error = external global ptr
@j_compile_env = external global ptr
@ds.empty = private constant [1 x i8] zeroinitializer
@ds.space = private constant [2 x i8] c" \00"
@ds.newline = private constant [2 x i8] c"\0A\00"
@ds.colon = private constant [2 x i8] c":\00"
@ds.slash = private constant [2 x i8] c"/\00"
@ds.zeros = private constant [5 x i8] c"0000\00"
@ds.return = private constant [4 x i8] c"RET\00"
@ds.opcodes = private constant [199 x i8] c"LOADK\00IDENTITY\00PIPE\00FORK\00BINARY\00INDEX\00EACH\00CALL\00COLLECT\00OBJECT\00LOADV\00BIND\00DEFINE\00BRANCH\00TRY\00NEGATE\00OPTIONAL\00RECURSE\00REDUCE\00ASSIGN\00SLICE\00ALTERNATIVE\00LABEL\00BREAK\00IMPORT\00MODULE\00PATTERN\00PATTERNS\00UNKNOWN\00"

declare ptr @j_alloc(i64)
declare ptr @j_cstr(ptr)
declare ptr @j_str(ptr, i64)
declare ptr @j_num(double)
declare ptr @j_dump(ptr, i32)
declare ptr @j_binary(i32, ptr, ptr)
declare ptr @j_negate(ptr)
declare ptr @j_array()
declare void @j_push(ptr, ptr)
declare ptr @j_at(ptr, i64)
declare ptr @j_bind(ptr, ptr, ptr)
declare i32 @j_cmp(ptr, ptr)
declare i64 @j_strlen(ptr)
declare i64 @b_len(ptr)
declare ptr @b_data(ptr)
declare ptr @j_debug_import_env(ptr, ptr)

define internal void @ds_foldchild(ptr %node, i64 %offset) {
entry:
  %slot = getelementptr i8, ptr %node, i64 %offset
  %child = load ptr, ptr %slot
  %folded = call ptr @j_fold_constants(ptr %child)
  ret void
}

define ptr @j_fold_constants(ptr %node) {
entry:
  %absent = icmp eq ptr %node, null
  br i1 %absent, label %done, label %dispatch
dispatch:
  %kind = load i32, ptr %node
  %ap = getelementptr %N, ptr %node, i32 0, i32 2
  %a = load ptr, ptr %ap
  %bp = getelementptr %N, ptr %node, i32 0, i32 3
  %b = load ptr, ptr %bp
  switch i32 %kind, label %done [i32 2, label %two i32 3, label %two i32 4, label %two i32 5, label %two i32 6, label %one i32 7, label %arguments i32 8, label %one i32 9, label %members i32 11, label %binding i32 12, label %definition i32 13, label %three i32 14, label %two i32 15, label %one i32 16, label %one i32 18, label %reduction i32 19, label %two i32 20, label %three i32 21, label %two i32 22, label %second i32 24, label %third i32 25, label %second]
one:
  call void @ds_foldchild(ptr %node, i64 8)
  br label %attempt
two:
  call void @ds_foldchild(ptr %node, i64 8)
  call void @ds_foldchild(ptr %node, i64 16)
  br label %attempt
three:
  call void @ds_foldchild(ptr %node, i64 8)
  call void @ds_foldchild(ptr %node, i64 16)
  call void @ds_foldchild(ptr %node, i64 24)
  br label %done
binding:
  call void @ds_foldchild(ptr %node, i64 8)
  call void @ds_foldchild(ptr %node, i64 24)
  br label %done
definition:
  call void @ds_foldchild(ptr %node, i64 24)
  call void @ds_foldchild(ptr %node, i64 32)
  br label %done
reduction:
  call void @ds_foldchild(ptr %node, i64 8)
  call void @ds_foldchild(ptr %node, i64 24)
  call void @ds_foldchild(ptr %node, i64 32)
  call void @ds_foldchild(ptr %node, i64 40)
  br label %done
second:
  call void @ds_foldchild(ptr %node, i64 16)
  br label %done
third:
  call void @ds_foldchild(ptr %node, i64 24)
  br label %done
arguments:
  br label %list
members:
  br label %list
list:
  %items = phi ptr [%b, %arguments], [%a, %members]
  %count = call i64 @b_len(ptr %items)
  br label %loop
loop:
  %i = phi i64 [0, %list], [%next, %body]
  %more = icmp ult i64 %i, %count
  br i1 %more, label %body, label %done
body:
  %child = call ptr @j_at(ptr %items, i64 %i)
  %folded = call ptr @j_fold_constants(ptr %child)
  %next = add i64 %i, 1
  br label %loop
attempt:
  %isbinary = icmp eq i32 %kind, 4
  %isnegative = icmp eq i32 %kind, 15
  %eligible = or i1 %isbinary, %isnegative
  br i1 %eligible, label %leftconstant, label %done
leftconstant:
  %ak = load i32, ptr %a
  %aliteral = icmp eq i32 %ak, 0
  br i1 %aliteral, label %rightconstant, label %done
rightconstant:
  br i1 %isnegative, label %calculate, label %rightkind
rightkind:
  %bk = load i32, ptr %b
  %bliteral = icmp eq i32 %bk, 0
  br i1 %bliteral, label %calculate, label %done
calculate:
  %savederror = load ptr, ptr @j_error
  store ptr null, ptr @j_error
  %avp = getelementptr %N, ptr %a, i32 0, i32 2
  %av = load ptr, ptr %avp
  br i1 %isnegative, label %negate, label %binary
negate:
  %negativevalue = call ptr @j_negate(ptr %av)
  br label %result
binary:
  %op.p = getelementptr %N, ptr %node, i32 0, i32 1
  %op = load i32, ptr %op.p
  %bvp = getelementptr %N, ptr %b, i32 0, i32 2
  %bv = load ptr, ptr %bvp
  %binaryvalue = call ptr @j_binary(i32 %op, ptr %av, ptr %bv)
  br label %result
result:
  %value = phi ptr [%negativevalue, %negate], [%binaryvalue, %binary]
  %error = load ptr, ptr @j_error
  store ptr %savederror, ptr @j_error
  %success = icmp eq ptr %error, null
  br i1 %success, label %replace, label %done
replace:
  store i32 0, ptr %node
  %replacementop = getelementptr %N, ptr %node, i32 0, i32 1
  store i32 0, ptr %replacementop
  store ptr %value, ptr %ap
  store ptr null, ptr %bp
  %replacementc = getelementptr %N, ptr %node, i32 0, i32 4
  %replacementd = getelementptr %N, ptr %node, i32 0, i32 5
  %replacementextra = getelementptr %N, ptr %node, i32 0, i32 6
  store ptr null, ptr %replacementc
  store ptr null, ptr %replacementd
  store ptr null, ptr %replacementextra
  br label %done
done:
  ret ptr %node
}

define internal ptr @ds_uint(i64 %number) {
entry:
  %double = uitofp i64 %number to double
  %value = call ptr @j_num(double %double)
  %string = call ptr @j_dump(ptr %value, i32 0)
  ret ptr %string
}

define internal void @ds_append(ptr %state, ptr %string) {
entry:
  %old = load ptr, ptr %state
  %joined = call ptr @j_binary(i32 0, ptr %old, ptr %string)
  store ptr %joined, ptr %state
  ret void
}

define internal void @ds_cappend(ptr %state, ptr %string) {
entry:
  %value = call ptr @j_cstr(ptr %string)
  call void @ds_append(ptr %state, ptr %value)
  ret void
}

define internal ptr @ds_opcode(i32 %kind) {
entry:
  %valid = icmp ult i32 %kind, 28
  %index = select i1 %valid, i32 %kind, i32 28
  br label %loop
loop:
  %i = phi i32 [0, %entry], [%next, %advance]
  %name = phi ptr [@ds.opcodes, %entry], [%nextname, %advance]
  %found = icmp eq i32 %i, %index
  br i1 %found, label %done, label %advance
advance:
  %length = call i64 @j_strlen(ptr %name)
  %step = add i64 %length, 1
  %nextname = getelementptr i8, ptr %name, i64 %step
  %next = add i32 %i, 1
  br label %loop
done:
  ret ptr %name
}

define internal void @ds_line(ptr %state, ptr %opcode, ptr %operand, i64 %depth) {
entry:
  %pcp = getelementptr %DS, ptr %state, i32 0, i32 2
  %pc = load i64, ptr %pcp
  %number = call ptr @ds_uint(i64 %pc)
  %n = call i64 @b_len(ptr %number)
  %short = icmp ult i64 %n, 4
  %padding0 = sub i64 4, %n
  %padding = select i1 %short, i64 %padding0, i64 0
  %zeros = call ptr @j_str(ptr @ds.zeros, i64 %padding)
  call void @ds_append(ptr %state, ptr %zeros)
  call void @ds_append(ptr %state, ptr %number)
  call void @ds_cappend(ptr %state, ptr @ds.space)
  br label %indentloop
indentloop:
  %i = phi i64 [0, %entry], [%next, %indent]
  %more = icmp ult i64 %i, %depth
  br i1 %more, label %indent, label %instruction
indent:
  call void @ds_cappend(ptr %state, ptr @ds.space)
  call void @ds_cappend(ptr %state, ptr @ds.space)
  %next = add i64 %i, 1
  br label %indentloop
instruction:
  call void @ds_cappend(ptr %state, ptr %opcode)
  %hasoperand = icmp ne ptr %operand, null
  br i1 %hasoperand, label %writeoperand, label %newline
writeoperand:
  call void @ds_cappend(ptr %state, ptr @ds.space)
  call void @ds_append(ptr %state, ptr %operand)
  br label %newline
newline:
  call void @ds_cappend(ptr %state, ptr @ds.newline)
  %pcnext = add i64 %pc, 1
  store i64 %pcnext, ptr %pcp
  ret void
}

define internal ptr @ds_lookup(ptr %env, ptr %name, i64 %arity) {
entry:
  br label %loop
loop:
  %current = phi ptr [%env, %entry], [%next, %advance]
  %absent = icmp eq ptr %current, null
  br i1 %absent, label %missing, label %check
check:
  %kindp = getelementptr %E, ptr %current, i32 0, i32 3
  %kind = load i32, ptr %kindp
  %isfunction = icmp eq i32 %kind, 1
  br i1 %isfunction, label %compare, label %advance
compare:
  %namep = getelementptr %E, ptr %current, i32 0, i32 1
  %entryname = load ptr, ptr %namep
  %comparison = call i32 @j_cmp(ptr %name, ptr %entryname)
  %samename = icmp eq i32 %comparison, 0
  %paramsp = getelementptr %E, ptr %current, i32 0, i32 4
  %params = load ptr, ptr %paramsp
  %count = call i64 @b_len(ptr %params)
  %samearity = icmp eq i64 %count, %arity
  %same = and i1 %samename, %samearity
  br i1 %same, label %found, label %advance
advance:
  %next = load ptr, ptr %current
  br label %loop
found:
  ret ptr %current
missing:
  ret ptr null
}

define internal void @ds_enqueue(ptr %state, ptr %function) {
entry:
  %absent = icmp eq ptr %function, null
  br i1 %absent, label %done, label %start
start:
  %workp = getelementptr %DS, ptr %state, i32 0, i32 1
  %work = load ptr, ptr %workp
  %n = call i64 @b_len(ptr %work)
  %bodyp = getelementptr %E, ptr %function, i32 0, i32 2
  %body = load ptr, ptr %bodyp
  %namep = getelementptr %E, ptr %function, i32 0, i32 1
  %name = load ptr, ptr %namep
  br label %loop
loop:
  %i = phi i64 [0, %start], [%next, %advance]
  %more = icmp ult i64 %i, %n
  br i1 %more, label %compare, label %append
compare:
  %existing = call ptr @j_at(ptr %work, i64 %i)
  %existingbodyp = getelementptr %E, ptr %existing, i32 0, i32 2
  %existingbody = load ptr, ptr %existingbodyp
  %samebody = icmp eq ptr %existingbody, %body
  br i1 %samebody, label %namecheck, label %advance
namecheck:
  %existingnamep = getelementptr %E, ptr %existing, i32 0, i32 1
  %existingname = load ptr, ptr %existingnamep
  %cmp = call i32 @j_cmp(ptr %name, ptr %existingname)
  %samename = icmp eq i32 %cmp, 0
  br i1 %samename, label %done, label %advance
advance:
  %next = add i64 %i, 1
  br label %loop
append:
  call void @j_push(ptr %work, ptr %function)
  br label %done
done:
  ret void
}

define internal void @ds_walkchild(ptr %node, i64 %offset, ptr %env, ptr %state, i64 %depth) {
entry:
  %slot = getelementptr i8, ptr %node, i64 %offset
  %child = load ptr, ptr %slot
  call void @ds_walk(ptr %child, ptr %env, ptr %state, i64 %depth)
  ret void
}

define internal void @ds_walk(ptr %node, ptr %env, ptr %state, i64 %depth) {
entry:
  %absent = icmp eq ptr %node, null
  br i1 %absent, label %done, label %dispatch
dispatch:
  %kind = load i32, ptr %node
  %ap = getelementptr %N, ptr %node, i32 0, i32 2
  %a = load ptr, ptr %ap
  %bp = getelementptr %N, ptr %node, i32 0, i32 3
  %b = load ptr, ptr %bp
  %cp = getelementptr %N, ptr %node, i32 0, i32 4
  %c = load ptr, ptr %cp
  %dp = getelementptr %N, ptr %node, i32 0, i32 5
  %d = load ptr, ptr %dp
  %opcode = call ptr @ds_opcode(i32 %kind)
  %nested = add i64 %depth, 1
  switch i32 %kind, label %plain [i32 0, label %literal i32 4, label %operator i32 7, label %call i32 10, label %named i32 12, label %definition i32 19, label %operator i32 22, label %named i32 23, label %named i32 24, label %import i32 25, label %module]
literal:
  %literaltext = call ptr @j_dump(ptr %a, i32 0)
  call void @ds_line(ptr %state, ptr %opcode, ptr %literaltext, i64 %depth)
  br label %done
operator:
  %opp = getelementptr %N, ptr %node, i32 0, i32 1
  %op = load i32, ptr %opp
  %wideop = zext i32 %op to i64
  %optext = call ptr @ds_uint(i64 %wideop)
  call void @ds_line(ptr %state, ptr %opcode, ptr %optext, i64 %depth)
  br label %children
named:
  call void @ds_line(ptr %state, ptr %opcode, ptr %a, i64 %depth)
  br label %children
definition:
  %defined = call ptr @j_bind(ptr %env, ptr %a, ptr %c)
  %definedkindp = getelementptr %E, ptr %defined, i32 0, i32 3
  store i32 1, ptr %definedkindp
  %definedparamsp = getelementptr %E, ptr %defined, i32 0, i32 4
  store ptr %b, ptr %definedparamsp
  %definedenvp = getelementptr %E, ptr %defined, i32 0, i32 5
  store ptr %defined, ptr %definedenvp
  call void @ds_walk(ptr %d, ptr %defined, ptr %state, i64 %depth)
  br label %done
import:
  call void @ds_line(ptr %state, ptr %opcode, ptr %a, i64 %depth)
  %imported = call ptr @j_debug_import_env(ptr %node, ptr %env)
  call void @ds_walk(ptr %c, ptr %imported, ptr %state, i64 %depth)
  br label %done
module:
  call void @ds_walk(ptr %b, ptr %env, ptr %state, i64 %depth)
  br label %done
call:
  %arity = call i64 @b_len(ptr %b)
  %aritytext = call ptr @ds_uint(i64 %arity)
  %slash = call ptr @j_cstr(ptr @ds.slash)
  %prefix = call ptr @j_binary(i32 0, ptr %a, ptr %slash)
  %callname = call ptr @j_binary(i32 0, ptr %prefix, ptr %aritytext)
  call void @ds_line(ptr %state, ptr %opcode, ptr %callname, i64 %depth)
  %function = call ptr @ds_lookup(ptr %env, ptr %a, i64 %arity)
  call void @ds_enqueue(ptr %state, ptr %function)
  br label %arguments
plain:
  call void @ds_line(ptr %state, ptr %opcode, ptr null, i64 %depth)
  br label %children
children:
  switch i32 %kind, label %done [i32 2, label %two i32 3, label %two i32 4, label %two i32 5, label %two i32 6, label %one i32 8, label %one i32 9, label %members i32 11, label %three i32 13, label %three i32 14, label %two i32 15, label %one i32 16, label %one i32 18, label %reduction i32 19, label %two i32 20, label %three i32 21, label %two i32 22, label %second i32 27, label %members]
one:
  call void @ds_walk(ptr %a, ptr %env, ptr %state, i64 %nested)
  br label %done
two:
  call void @ds_walk(ptr %a, ptr %env, ptr %state, i64 %nested)
  call void @ds_walk(ptr %b, ptr %env, ptr %state, i64 %nested)
  br label %done
three:
  call void @ds_walk(ptr %a, ptr %env, ptr %state, i64 %nested)
  call void @ds_walk(ptr %b, ptr %env, ptr %state, i64 %nested)
  call void @ds_walk(ptr %c, ptr %env, ptr %state, i64 %nested)
  br label %done
second:
  call void @ds_walk(ptr %b, ptr %env, ptr %state, i64 %nested)
  br label %done
reduction:
  call void @ds_walk(ptr %a, ptr %env, ptr %state, i64 %nested)
  call void @ds_walk(ptr %b, ptr %env, ptr %state, i64 %nested)
  call void @ds_walk(ptr %c, ptr %env, ptr %state, i64 %nested)
  call void @ds_walk(ptr %d, ptr %env, ptr %state, i64 %nested)
  call void @ds_walkchild(ptr %node, i64 40, ptr %env, ptr %state, i64 %nested)
  br label %done
arguments:
  br label %list
members:
  br label %list
list:
  %items = phi ptr [%b, %arguments], [%a, %members]
  %count = call i64 @b_len(ptr %items)
  br label %loop
loop:
  %i = phi i64 [0, %list], [%next, %body]
  %more = icmp ult i64 %i, %count
  br i1 %more, label %body, label %done
body:
  %item = call ptr @j_at(ptr %items, i64 %i)
  call void @ds_walk(ptr %item, ptr %env, ptr %state, i64 %nested)
  %next = add i64 %i, 1
  br label %loop
done:
  ret void
}

define ptr @j_disassemble(ptr %ast) {
entry:
  %savederror = load ptr, ptr @j_error
  store ptr null, ptr @j_error
  %state = call ptr @j_alloc(i64 24)
  %empty = call ptr @j_cstr(ptr @ds.empty)
  store ptr %empty, ptr %state
  %work = call ptr @j_array()
  %workp = getelementptr %DS, ptr %state, i32 0, i32 1
  store ptr %work, ptr %workp
  %env = load ptr, ptr @j_compile_env
  call void @ds_walk(ptr %ast, ptr %env, ptr %state, i64 0)
  call void @ds_line(ptr %state, ptr @ds.return, ptr null, i64 0)
  br label %loop
loop:
  %i = phi i64 [0, %entry], [%next, %functiondone]
  %n = call i64 @b_len(ptr %work)
  %more = icmp ult i64 %i, %n
  br i1 %more, label %function, label %done
function:
  %fn = call ptr @j_at(ptr %work, i64 %i)
  %namep = getelementptr %E, ptr %fn, i32 0, i32 1
  %name = load ptr, ptr %namep
  call void @ds_append(ptr %state, ptr %name)
  call void @ds_cappend(ptr %state, ptr @ds.colon)
  %index = call ptr @ds_uint(i64 %i)
  call void @ds_append(ptr %state, ptr %index)
  call void @ds_cappend(ptr %state, ptr @ds.colon)
  call void @ds_cappend(ptr %state, ptr @ds.newline)
  %pcp = getelementptr %DS, ptr %state, i32 0, i32 2
  store i64 0, ptr %pcp
  %bodyp = getelementptr %E, ptr %fn, i32 0, i32 2
  %body = load ptr, ptr %bodyp
  %boundp = getelementptr %E, ptr %fn, i32 0, i32 5
  %bound = load ptr, ptr %boundp
  call void @ds_walk(ptr %body, ptr %bound, ptr %state, i64 0)
  call void @ds_line(ptr %state, ptr @ds.return, ptr null, i64 0)
  br label %functiondone
functiondone:
  %next = add i64 %i, 1
  br label %loop
done:
  %result = load ptr, ptr %state
  store ptr %savederror, ptr @j_error
  ret ptr %result
}
