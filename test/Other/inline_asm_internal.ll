; RUN: opt -O1 -S -o - < %s | FileCheck %s
define void @main( ) {
  call void @foo( i32 0)
  ret void
}

define internal void @foo(i32 %i) {
  ; CHECK: foobar
  tail call void asm sideeffect "foobar", "r"(i32 %i) readnone
  ret void
}

