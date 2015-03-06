; RUN: opt -O3 -S -o - < %s | FileCheck %s
define void @foo() {
  ; CHECK: foobar
  call void asm sideeffect "foobar", ""() readnone
  ret void
}

