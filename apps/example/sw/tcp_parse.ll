; ModuleID = 'tcp_parse.cpp'
source_filename = "tcp_parse.cpp"
target datalayout = "e-G1-m:e-p:32:32-i64:64-n32-S128"
target triple = "primate32-unknown-linux-gnu"

%struct.ethernet_t = type { i48, i48, i16 }
%struct.ipv4_t = type { i72, i8, i80 }
%struct.tcp_t = type { i96, i4, i60 }
%struct.udp_t = type { i64 }

; Function Attrs: alwaysinline mustprogress nounwind
define dso_local void @_ZN7PRIMATE10input_doneEv() local_unnamed_addr #0 !primate !7 {
entry:
  tail call void @llvm.primate.input.done()
  ret void
}

; Function Attrs: nounwind
declare !primate !7 void @llvm.primate.input.done() #1

; Function Attrs: alwaysinline mustprogress nounwind
define dso_local void @_ZN7PRIMATE11output_doneEv() local_unnamed_addr #0 !primate !7 {
entry:
  tail call void @llvm.primate.output.done()
  ret void
}

; Function Attrs: nounwind
declare !primate !7 void @llvm.primate.output.done() #1

; Function Attrs: mustprogress nounwind
define dso_local void @_Z12primate_mainv() local_unnamed_addr #2 {
entry:
  %0 = tail call %struct.ethernet_t @llvm.primate.input.s_struct.ethernet_ts.i32(i32 24)
  %.fca.2.extract70 = extractvalue %struct.ethernet_t %0, 2
  tail call void @llvm.primate.output.s_struct.ethernet_ts.i32(%struct.ethernet_t %0, i32 24)
  %cmp = icmp eq i16 %.fca.2.extract70, 2048
  br i1 %cmp, label %if.then, label %if.end38

if.then:                                          ; preds = %entry
  %1 = tail call %struct.ipv4_t @llvm.primate.input.s_struct.ipv4_ts.i32(i32 40)
  %.fca.1.extract66 = extractvalue %struct.ipv4_t %1, 1
  tail call void @llvm.primate.output.s_struct.ipv4_ts.i32(%struct.ipv4_t %1, i32 40)
  switch i8 %.fca.1.extract66, label %if.end38 [
    i8 6, label %if.then5
    i8 17, label %if.then33
  ]

if.then5:                                         ; preds = %if.then
  %2 = tail call %struct.tcp_t @llvm.primate.input.s_struct.tcp_ts.i32(i32 32)
  %.fca.1.extract = extractvalue %struct.tcp_t %2, 1
  tail call void @llvm.primate.output.s_struct.tcp_ts.i32(%struct.tcp_t %2, i32 32)
  %or.cond = icmp sgt i4 %.fca.1.extract, 5
  br i1 %or.cond, label %while.body.preheader, label %if.end38

while.body.preheader:                             ; preds = %if.then5
  %conv12 = zext nneg i4 %.fca.1.extract to i32
  %sub = shl nuw nsw i32 %conv12, 2
  %mul = add nsw i32 %sub, -20
  br label %while.body

while.body:                                       ; preds = %while.body.preheader, %cleanup
  %hdr_byte_left.053 = phi i32 [ %hdr_byte_left.2, %cleanup ], [ %mul, %while.body.preheader ]
  %3 = tail call i8 @llvm.primate.input.i8.i32(i32 1)
  switch i8 %3, label %cleanup [
    i8 0, label %if.then16
    i8 1, label %if.then23
  ]

if.then16:                                        ; preds = %while.body
  tail call void @llvm.primate.output.i8.i32(i8 0, i32 1)
  %cmp1854 = icmp ugt i32 %hdr_byte_left.053, 1
  br i1 %cmp1854, label %while.body19.preheader, label %if.end38

while.body19.preheader:                           ; preds = %if.then16
  %dec = add nsw i32 %hdr_byte_left.053, -1
  br label %while.body19

while.body19:                                     ; preds = %while.body19.preheader, %while.body19
  %hdr_byte_left.155 = phi i32 [ %sub20, %while.body19 ], [ %dec, %while.body19.preheader ]
  %4 = tail call i128 @llvm.primate.input.i128.i32(i32 16)
  tail call void @llvm.primate.output.i128.i32(i128 %4, i32 16)
  %sub20 = add nsw i32 %hdr_byte_left.155, -16
  %cmp18 = icmp ugt i32 %hdr_byte_left.155, 16
  br i1 %cmp18, label %while.body19, label %if.end38, !llvm.loop !8

if.then23:                                        ; preds = %while.body
  %dec25 = add nsw i32 %hdr_byte_left.053, -1
  tail call void @llvm.primate.output.i8.i32(i8 1, i32 1)
  br label %cleanup

cleanup:                                          ; preds = %if.then23, %while.body
  %hdr_byte_left.2 = phi i32 [ %dec25, %if.then23 ], [ %hdr_byte_left.053, %while.body ]
  %cmp13 = icmp sgt i32 %hdr_byte_left.2, 0
  br i1 %cmp13, label %while.body, label %if.end38

if.then33:                                        ; preds = %if.then
  %5 = tail call %struct.udp_t @llvm.primate.input.s_struct.udp_ts.i32(i32 8)
  tail call void @llvm.primate.output.s_struct.udp_ts.i32(%struct.udp_t %5, i32 8)
  br label %if.end38

if.end38:                                         ; preds = %cleanup, %while.body19, %if.then16, %if.then, %if.then5, %if.then33, %entry
  tail call void @llvm.primate.input.done()
  ret void
}

; Function Attrs: nounwind
declare !primate !7 %struct.ethernet_t @llvm.primate.input.s_struct.ethernet_ts.i32(i32) #1

; Function Attrs: nounwind
declare !primate !7 %struct.ipv4_t @llvm.primate.input.s_struct.ipv4_ts.i32(i32) #1

; Function Attrs: nounwind
declare !primate !7 %struct.tcp_t @llvm.primate.input.s_struct.tcp_ts.i32(i32) #1

; Function Attrs: nounwind
declare !primate !7 i8 @llvm.primate.input.i8.i32(i32) #1

; Function Attrs: nounwind
declare !primate !7 i128 @llvm.primate.input.i128.i32(i32) #1

; Function Attrs: nounwind
declare !primate !7 %struct.udp_t @llvm.primate.input.s_struct.udp_ts.i32(i32) #1

; Function Attrs: nounwind
declare !primate !7 void @llvm.primate.output.s_struct.ethernet_ts.i32(%struct.ethernet_t, i32) #1

; Function Attrs: nounwind
declare !primate !7 void @llvm.primate.output.s_struct.ipv4_ts.i32(%struct.ipv4_t, i32) #1

; Function Attrs: nounwind
declare !primate !7 void @llvm.primate.output.s_struct.tcp_ts.i32(%struct.tcp_t, i32) #1

; Function Attrs: nounwind
declare !primate !7 void @llvm.primate.output.i8.i32(i8, i32) #1

; Function Attrs: nounwind
declare !primate !7 void @llvm.primate.output.i128.i32(i128, i32) #1

; Function Attrs: nounwind
declare !primate !7 void @llvm.primate.output.s_struct.udp_ts.i32(%struct.udp_t, i32) #1

attributes #0 = { alwaysinline mustprogress nounwind "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-features"="+32bit" }
attributes #1 = { nounwind }
attributes #2 = { mustprogress nounwind "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-features"="+32bit" }

!llvm.module.flags = !{!0, !1, !2, !3, !4, !5}
!llvm.ident = !{!6}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 1, !"target-abi", !"ilp32"}
!2 = !{i32 8, !"PIC Level", i32 2}
!3 = !{i32 7, !"PIE Level", i32 2}
!4 = !{i32 7, !"frame-pointer", i32 2}
!5 = !{i32 8, !"SmallDataLimit", i32 8}
!6 = !{!"clang version 18.1.8 (git@github.com:FAST-Research-Group/primate-arch-gen.git e8582d4315ec2267abfc97212fa19f342d0812e8)"}
!7 = !{!"blue", !"IO", i64 1, i64 1}
!8 = distinct !{!8, !9}
!9 = !{!"llvm.loop.mustprogress"}
