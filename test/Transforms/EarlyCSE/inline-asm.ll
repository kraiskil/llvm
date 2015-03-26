; RUN: opt -early-cse -S -o - < %s | FileCheck %s
define void @foo() {
  %var = add i32 0, 0
  ; CHECK: foobar
  %call1 = call i32 asm sideeffect "foobar", "=r,r"(i32 %var) nounwind readnone
  ; CHECK: foobar
  %call2 = call i32 asm sideeffect "foobar", "=r,r"(i32 %var) nounwind readnone

  ret void
}

