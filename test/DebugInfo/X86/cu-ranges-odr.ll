; RUN: llc -split-dwarf=Enable -O0 %s -mtriple=x86_64-unknown-linux-gnu -filetype=obj -o %t
; RUN: llvm-dwarfdump -debug-dump=all %t | FileCheck %s
; RUN: llvm-readobj --relocations %t | FileCheck --check-prefix=CHECK-RELOCS %s

; From:
; class A {
; public:
;   A(int i = 0) : a(i) {}
; private:
;   int a;
; };
;
; A a;

; With function sections enabled make sure that we have a DW_AT_ranges attribute.
; CHECK: DW_AT_ranges

; Check that we have a relocation against the .debug_ranges section.
; CHECK-RELOCS: R_X86_64_32 .debug_ranges 0x0

%class.A = type { i32 }

@a = global %class.A zeroinitializer, align 4
@llvm.global_ctors = appending global [1 x { i32, void ()* }] [{ i32, void ()* } { i32 65535, void ()* @_GLOBAL__I_a }]

define internal void @__cxx_global_var_init() section ".text.startup" {
entry:
  call void @_ZN1AC2Ei(%class.A* @a, i32 0), !dbg !26
  ret void, !dbg !26
}

; Function Attrs: nounwind uwtable
define linkonce_odr void @_ZN1AC2Ei(%class.A* %this, i32 %i) unnamed_addr #0 align 2 {
entry:
  %this.addr = alloca %class.A*, align 8
  %i.addr = alloca i32, align 4
  store %class.A* %this, %class.A** %this.addr, align 8
  call void @llvm.dbg.declare(metadata %class.A** %this.addr, metadata !27, metadata !MDExpression()), !dbg !29
  store i32 %i, i32* %i.addr, align 4
  call void @llvm.dbg.declare(metadata i32* %i.addr, metadata !30, metadata !MDExpression()), !dbg !31
  %this1 = load %class.A*, %class.A** %this.addr
  %a = getelementptr inbounds %class.A, %class.A* %this1, i32 0, i32 0, !dbg !31
  %0 = load i32, i32* %i.addr, align 4, !dbg !31
  store i32 %0, i32* %a, align 4, !dbg !31
  ret void, !dbg !31
}

; Function Attrs: nounwind readnone
declare void @llvm.dbg.declare(metadata, metadata, metadata) #1

define internal void @_GLOBAL__I_a() section ".text.startup" {
entry:
  call void @__cxx_global_var_init(), !dbg !32
  ret void, !dbg !32
}

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!23, !24}
!llvm.ident = !{!25}

!0 = !MDCompileUnit(language: DW_LANG_C_plus_plus, producer: "clang version 3.5 (trunk 199923) (llvm/trunk 199940)", isOptimized: false, emissionKind: 1, file: !1, enums: !2, retainedTypes: !3, subprograms: !13, globals: !21, imports: !2)
!1 = !MDFile(filename: "baz.cpp", directory: "/usr/local/google/home/echristo/tmp")
!2 = !{}
!3 = !{!4}
!4 = !MDCompositeType(tag: DW_TAG_class_type, name: "A", line: 1, size: 32, align: 32, file: !1, elements: !5, identifier: "_ZTS1A")
!5 = !{!6, !8}
!6 = !MDDerivedType(tag: DW_TAG_member, name: "a", line: 5, size: 32, align: 32, flags: DIFlagPrivate, file: !1, scope: !"_ZTS1A", baseType: !7)
!7 = !MDBasicType(tag: DW_TAG_base_type, name: "int", size: 32, align: 32, encoding: DW_ATE_signed)
!8 = !MDSubprogram(name: "A", line: 3, isLocal: false, isDefinition: false, virtualIndex: 6, flags: DIFlagPrototyped, isOptimized: false, scopeLine: 3, file: !1, scope: !"_ZTS1A", type: !9, variables: !12)
!9 = !MDSubroutineType(types: !10)
!10 = !{null, !11, !7}
!11 = !MDDerivedType(tag: DW_TAG_pointer_type, size: 64, align: 64, flags: DIFlagArtificial | DIFlagObjectPointer, baseType: !"_ZTS1A")
!12 = !{i32 786468}
!13 = !{!14, !18, !19}
!14 = !MDSubprogram(name: "__cxx_global_var_init", line: 8, isLocal: true, isDefinition: true, virtualIndex: 6, flags: DIFlagPrototyped, isOptimized: false, scopeLine: 8, file: !1, scope: !15, type: !16, function: void ()* @__cxx_global_var_init, variables: !2)
!15 = !MDFile(filename: "baz.cpp", directory: "/usr/local/google/home/echristo/tmp")
!16 = !MDSubroutineType(types: !17)
!17 = !{null}
!18 = !MDSubprogram(name: "A", linkageName: "_ZN1AC2Ei", line: 3, isLocal: false, isDefinition: true, virtualIndex: 6, flags: DIFlagPrototyped, isOptimized: false, scopeLine: 3, file: !1, scope: !"_ZTS1A", type: !9, function: void (%class.A*, i32)* @_ZN1AC2Ei, declaration: !8, variables: !2)
!19 = !MDSubprogram(name: "", linkageName: "_GLOBAL__I_a", line: 3, isLocal: true, isDefinition: true, virtualIndex: 6, flags: DIFlagArtificial, isOptimized: false, scopeLine: 3, file: !1, scope: !15, type: !20, function: void ()* @_GLOBAL__I_a, variables: !2)
!20 = !MDSubroutineType(types: !2)
!21 = !{!22}
!22 = !MDGlobalVariable(name: "a", line: 8, isLocal: false, isDefinition: true, scope: null, file: !15, type: !4, variable: %class.A* @a)
!23 = !{i32 2, !"Dwarf Version", i32 4}
!24 = !{i32 1, !"Debug Info Version", i32 3}
!25 = !{!"clang version 3.5 (trunk 199923) (llvm/trunk 199940)"}
!26 = !MDLocation(line: 8, scope: !14)
!27 = !MDLocalVariable(tag: DW_TAG_arg_variable, name: "this", arg: 1, flags: DIFlagArtificial | DIFlagObjectPointer, scope: !18, type: !28)
!28 = !MDDerivedType(tag: DW_TAG_pointer_type, size: 64, align: 64, baseType: !"_ZTS1A")
!29 = !MDLocation(line: 0, scope: !18)
!30 = !MDLocalVariable(tag: DW_TAG_arg_variable, name: "i", line: 3, arg: 2, scope: !18, file: !15, type: !7)
!31 = !MDLocation(line: 3, scope: !18)
!32 = !MDLocation(line: 3, scope: !19)
