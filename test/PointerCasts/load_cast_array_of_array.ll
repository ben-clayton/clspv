; RUN: clspv-opt %s -o %t -ReplacePointerBitcast
; RUN: FileCheck %s < %t

target datalayout = "e-p:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024"
target triple = "spir-unknown-unknown"

define void @foo(i32 addrspace(1)* %a, [4 x [8 x i32]] addrspace(3)* %b, i32 %n) {
entry:
  %cast = bitcast [4 x [8 x i32]] addrspace(3)* %b to i32 addrspace(3)*
  %gep = getelementptr i32, i32 addrspace(3)* %cast, i32 %n
  %ld = load i32, i32 addrspace(3)* %gep
  store i32 %ld, i32 addrspace(1)* %a, align 4
  ret void
}

; CHECK: [[div32:%[^ ]+]] = udiv i32 %n, 32
; CHECK: [[rem32:%[^ ]+]] = urem i32 %n, 32
; CHECK: [[div8:%[^ ]+]] = udiv i32 [[rem32]], 8
; CHECK: [[rem8:%[^ ]+]] = urem i32 [[rem32]], 8
; CHECK: [[gep:%[^ ]+]] = getelementptr [4 x [8 x i32]], [4 x [8 x i32]] addrspace(3)* %b, i32 [[div32]], i32 [[div8]], i32 [[rem8]]
; CHECK: [[ld:%[^ ]+]] = load i32, i32 addrspace(3)* [[gep]], align 4
; CHECK: store i32 [[ld]], i32 addrspace(1)* %a, align 4
