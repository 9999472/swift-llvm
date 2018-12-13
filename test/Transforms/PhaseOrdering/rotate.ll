; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -O3 -S < %s                    | FileCheck %s --check-prefixes=ANY,OLDPM
; RUN: opt -passes='default<O3>' -S < %s  | FileCheck %s --check-prefixes=ANY,NEWPM

; This should become a single funnel shift through a combination
; of aggressive-instcombine, simplifycfg, and instcombine.
; https://bugs.llvm.org/show_bug.cgi?id=34924

define i32 @rotl(i32 %a, i32 %b) {
; OLDPM-LABEL: @rotl(
; OLDPM-NEXT:  entry:
; OLDPM-NEXT:    [[CMP:%.*]] = icmp eq i32 [[B:%.*]], 0
; OLDPM-NEXT:    br i1 [[CMP]], label [[END:%.*]], label [[ROTBB:%.*]]
; OLDPM:       rotbb:
; OLDPM-NEXT:    [[SUB:%.*]] = sub i32 32, [[B]]
; OLDPM-NEXT:    [[SHR:%.*]] = lshr i32 [[A:%.*]], [[SUB]]
; OLDPM-NEXT:    [[SHL:%.*]] = shl i32 [[A]], [[B]]
; OLDPM-NEXT:    [[OR:%.*]] = or i32 [[SHR]], [[SHL]]
; OLDPM-NEXT:    br label [[END]]
; OLDPM:       end:
; OLDPM-NEXT:    [[COND:%.*]] = phi i32 [ [[OR]], [[ROTBB]] ], [ [[A]], [[ENTRY:%.*]] ]
; OLDPM-NEXT:    ret i32 [[COND]]
;
; NEWPM-LABEL: @rotl(
; NEWPM-NEXT:  entry:
; NEWPM-NEXT:    [[TMP0:%.*]] = sub i32 0, [[B:%.*]]
; NEWPM-NEXT:    [[TMP1:%.*]] = and i32 [[B]], 31
; NEWPM-NEXT:    [[TMP2:%.*]] = and i32 [[TMP0]], 31
; NEWPM-NEXT:    [[TMP3:%.*]] = lshr i32 [[A:%.*]], [[TMP2]]
; NEWPM-NEXT:    [[TMP4:%.*]] = shl i32 [[A]], [[TMP1]]
; NEWPM-NEXT:    [[SPEC_SELECT:%.*]] = or i32 [[TMP3]], [[TMP4]]
; NEWPM-NEXT:    ret i32 [[SPEC_SELECT]]
;
entry:
  %cmp = icmp eq i32 %b, 0
  br i1 %cmp, label %end, label %rotbb

rotbb:
  %sub = sub i32 32, %b
  %shr = lshr i32 %a, %sub
  %shl = shl i32 %a, %b
  %or = or i32 %shr, %shl
  br label %end

end:
  %cond = phi i32 [ %or, %rotbb ], [ %a, %entry ]
  ret i32 %cond
}

