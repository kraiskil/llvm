; RUN: opt -O3 -S -o - < %s | FileCheck %s

define void @foo(i32 %i) {
entry:
  br label %for.cond

for.cond:
  %j.0 = phi i32 [ 0, %entry ], [ %inc, %for.inc ]
  %cmp = icmp slt i32 %j.0, %i
  br i1 %cmp, label %for.body, label %for.end

for.body:
  ; CHECK: foobar
  call void asm sideeffect "foobar", ""() readnone
  br label %for.inc

for.inc:
  %inc = add nsw i32 %j.0, 1
  br label %for.cond

for.end:
  ret void
}
