; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -mergeicmps -mtriple=x86_64-unknown-unknown -S | FileCheck %s

%"struct.std::pair" = type { i32, i32, i32, i32 }

; The entry block is part of the chain. It however can not be merged. We need to make the
; first comparison block in the chain the new entry block of the function.

define zeroext i1 @opeq1(
; CHECK-LABEL: @opeq1(
; CHECK-NEXT:    br label [[LAND_RHS_I:%.*]]
; CHECK:       land.rhs.i:
; CHECK-NEXT:    [[SECOND_I:%.*]] = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %a, i64 0, i32 0 
; CHECK-NEXT:    [[SECOND2_I:%.*]] = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %b, i64 0, i32 0
; CHECK-NEXT:    [[CSTR:%.*]] = bitcast i32* [[SECOND_I]] to i8*
; CHECK-NEXT:    [[CSTR1:%.*]] = bitcast i32* [[SECOND2_I]] to i8*
; CHECK-NEXT:    [[MEMCMP:%.*]] = call i32 @memcmp(i8* [[CSTR]], i8* [[CSTR1]], i64 8)
;
  %"struct.std::pair"* nocapture readonly dereferenceable(16) %a,
  %"struct.std::pair"* nocapture readonly dereferenceable(16) %b) local_unnamed_addr #0 {
entry:
  %first.i = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %a, i64 0, i32 3 
  %0 = load i32, i32* %first.i, align 4
  %first1.i = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %b, i64 0, i32 2 
  %1 = load i32, i32* %first1.i, align 4
  %cmp.i = icmp eq i32 %0, %1
  br i1 %cmp.i, label %land.rhs.i, label %opeq1.exit

land.rhs.i:
  %second.i = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %a, i64 0, i32 0
  %2 = load i32, i32* %second.i, align 4
  %second2.i = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %b, i64 0, i32 0
  %3 = load i32, i32* %second2.i, align 4
  %cmp3.i = icmp eq i32 %2, %3
  br i1 %cmp3.i, label %land.rhs.i.2, label %opeq1.exit

land.rhs.i.2:
  %third.i = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %a, i64 0, i32 1 
  %4 = load i32, i32* %third.i, align 4
  %third2.i = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %b, i64 0, i32 1
  %5 = load i32, i32* %third2.i, align 4
  %cmp4.i = icmp eq i32 %4, %5
  br i1 %cmp4.i, label %land.rhs.i.3, label %opeq1.exit

land.rhs.i.3:
  %fourth.i = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %a, i64 0, i32 3 
  %6 = load i32, i32* %fourth.i, align 4
  %fourth2.i = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %b, i64 0, i32 3
  %7 = load i32, i32* %fourth2.i, align 4
  %cmp5.i = icmp eq i32 %6, %7
  br label %opeq1.exit

opeq1.exit:
  %8 = phi i1 [ false, %entry ], [ false,  %land.rhs.i], [ false, %land.rhs.i.2 ], [ %cmp5.i, %land.rhs.i.3 ]
  ret i1 %8
}
