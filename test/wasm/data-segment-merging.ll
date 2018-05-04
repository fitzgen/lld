target triple = "wasm32-unknown-unknown-wasm"

@a = hidden global [6 x i8] c"hello\00", align 1
@b = hidden global [8 x i8] c"goodbye\00", align 1
@c = hidden global [9 x i8] c"whatever\00", align 1
@d = hidden global i32 42, align 4

; RUN: llc -filetype=obj %s -o %t.data-segment-merging.o

; RUN: wasm-ld -no-gc-sections --allow-undefined -o %t.merged.wasm %t.data-segment-merging.o
; RUN: obj2yaml %t.merged.wasm | FileCheck %s --check-prefix=MERGE
; MERGE:  - Type:            DATA
; MERGE:    Segments:
; MERGE:      - SectionOffset:   7
; MERGE:        MemoryIndex:     0
; MERGE:        Offset:
; MERGE:          Opcode:          I32_CONST
; MERGE:          Value:           1024
; MERGE:        Content:         68656C6C6F00676F6F6462796500776861746576657200002A000000

; RUN: wasm-ld -no-gc-sections --allow-undefined --no-merge-data-segments -o %t.separate.wasm %t.data-segment-merging.o
; RUN: obj2yaml %t.separate.wasm | FileCheck %s --check-prefix=SEPARATE
; SEPARATE:  - Type:            DATA
; SEPARATE:    Segments:
; SEPARATE:      - SectionOffset:   7
; SEPARATE:        MemoryIndex:     0
; SEPARATE:        Offset:
; SEPARATE:          Opcode:          I32_CONST
; SEPARATE:          Value:           1024
; SEPARATE:        Content:         68656C6C6F00
; SEPARATE:      - SectionOffset:   19
; SEPARATE:        MemoryIndex:     0
; SEPARATE:        Offset:
; SEPARATE:          Opcode:          I32_CONST
; SEPARATE:          Value:           1030
; SEPARATE:        Content:         676F6F6462796500
; SEPARATE:      - SectionOffset:   33
; SEPARATE:        MemoryIndex:     0
; SEPARATE:        Offset:
; SEPARATE:          Opcode:          I32_CONST
; SEPARATE:          Value:           1038
; SEPARATE:        Content:         '776861746576657200'
; SEPARATE:      - SectionOffset:   48
; SEPARATE:        MemoryIndex:     0
; SEPARATE:        Offset:
; SEPARATE:          Opcode:          I32_CONST
; SEPARATE:          Value:           1048
; SEPARATE:        Content:         2A000000
