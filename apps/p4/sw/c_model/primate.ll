; ModuleID = 'primate.cpp'
source_filename = "primate.cpp"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%"class.std::ios_base::Init" = type { i8 }
%"class.std::basic_ostream" = type { ptr, %"class.std::basic_ios" }
%"class.std::basic_ios" = type { %"class.std::ios_base", ptr, i8, i8, ptr, ptr, ptr, ptr }
%"class.std::ios_base" = type { ptr, i64, i64, i32, i32, i32, ptr, %"struct.std::ios_base::_Words", [8 x %"struct.std::ios_base::_Words"], i32, ptr, %"class.std::locale" }
%"struct.std::ios_base::_Words" = type { ptr, i64 }
%"class.std::locale" = type { ptr }
%struct.payload_t = type { i512, i32, i8 }
%struct.ethernet_t = type { i48, i48, i16 }
%struct.ptp_l_t = type { i40, i8, i112 }
%struct.ptp_h_t = type { i192 }
%struct.ipv4_t = type { i72, i8, i80 }
%struct.tcp_t = type { i160 }
%struct.udp_t = type { i64 }
%struct.header_t = type { i16, i16, i16, i16 }
%"class.std::ctype" = type <{ %"class.std::locale::facet.base", [4 x i8], ptr, i8, [7 x i8], ptr, ptr, ptr, i8, [256 x i8], [256 x i8], i8, [6 x i8] }>
%"class.std::locale::facet.base" = type <{ ptr, i32 }>
%class.primate_io = type { i512, i32, i32, i32, i32, i8, %struct.payload_t, i8, %"class.std::vector", %"class.std::basic_ifstream", %"class.std::basic_ofstream" }
%"class.std::vector" = type { %"struct.std::_Vector_base" }
%"struct.std::_Vector_base" = type { %"struct.std::_Vector_base<payload_t, std::allocator<payload_t>>::_Vector_impl" }
%"struct.std::_Vector_base<payload_t, std::allocator<payload_t>>::_Vector_impl" = type { %"struct.std::_Vector_base<payload_t, std::allocator<payload_t>>::_Vector_impl_data" }
%"struct.std::_Vector_base<payload_t, std::allocator<payload_t>>::_Vector_impl_data" = type { ptr, ptr, ptr }
%"class.std::basic_ifstream" = type { %"class.std::basic_istream.base", %"class.std::basic_filebuf", %"class.std::basic_ios" }
%"class.std::basic_istream.base" = type { ptr, i64 }
%"class.std::basic_filebuf" = type { %"class.std::basic_streambuf", %union.pthread_mutex_t, %"class.std::__basic_file", i32, %struct.__mbstate_t, %struct.__mbstate_t, %struct.__mbstate_t, ptr, i64, i8, i8, i8, i8, ptr, ptr, i8, ptr, ptr, i64, ptr, ptr }
%"class.std::basic_streambuf" = type { ptr, ptr, ptr, ptr, ptr, ptr, ptr, %"class.std::locale" }
%union.pthread_mutex_t = type { %struct.__pthread_mutex_s }
%struct.__pthread_mutex_s = type { i32, i32, i32, i32, i32, i16, i16, %struct.__pthread_internal_list }
%struct.__pthread_internal_list = type { ptr, ptr }
%"class.std::__basic_file" = type <{ ptr, i8, [7 x i8] }>
%struct.__mbstate_t = type { i32, %union.anon }
%union.anon = type { i32 }
%"class.std::basic_ofstream" = type { %"class.std::basic_ostream.base", %"class.std::basic_filebuf", %"class.std::basic_ios" }
%"class.std::basic_ostream.base" = type { ptr }

$_ZN10primate_io12Input_headerI10ethernet_tEEviRT_ = comdat any

$_ZN10primate_io12Input_headerI7ptp_l_tEEviRT_ = comdat any

$_ZN10primate_io12Input_headerI7ptp_h_tEEviRT_ = comdat any

$_ZN10primate_io12Input_headerI8header_tEEviRT_ = comdat any

$_ZN10primate_io12Input_headerI6ipv4_tEEviRT_ = comdat any

$_ZN10primate_io12Input_headerI5tcp_tEEviRT_ = comdat any

$_ZN10primate_io12Input_headerI5udp_tEEviRT_ = comdat any

$_ZN10primate_io10Input_doneEv = comdat any

$_ZlsRSoRK9payload_t = comdat any

@_ZStL8__ioinit = internal global %"class.std::ios_base::Init" zeroinitializer, align 1
@__dso_handle = external hidden global i8
@.str = private unnamed_addr constant [26 x i8] c"vector::_M_realloc_insert\00", align 1
@.str.1 = private unnamed_addr constant [8 x i8] c"data = \00", align 1
@.str.2 = private unnamed_addr constant [11 x i8] c"; empty = \00", align 1
@.str.3 = private unnamed_addr constant [10 x i8] c"; last = \00", align 1
@_ZSt4cout = external global %"class.std::basic_ostream", align 8
@llvm.global_ctors = appending global [1 x { i32, ptr, ptr }] [{ i32, ptr, ptr } { i32 65535, ptr @_GLOBAL__sub_I_primate.cpp, ptr null }]

declare void @_ZNSt8ios_base4InitC1Ev(ptr noundef nonnull align 1 dereferenceable(1)) unnamed_addr #0

; Function Attrs: nounwind
declare void @_ZNSt8ios_base4InitD1Ev(ptr noundef nonnull align 1 dereferenceable(1)) unnamed_addr #1

; Function Attrs: nofree nounwind
declare i32 @__cxa_atexit(ptr, ptr, ptr) local_unnamed_addr #2

; Function Attrs: uwtable
define dso_local void @_Z12primate_mainR10primate_io(ptr noundef nonnull align 8 dereferenceable(1224) %top_intf) local_unnamed_addr #3 personality ptr @__gxx_personality_v0 {
entry:
  %pl.i263 = alloca %struct.payload_t, align 8
  %pl.i253 = alloca %struct.payload_t, align 8
  %pl.i236 = alloca %struct.payload_t, align 8
  %pl.i226 = alloca %struct.payload_t, align 8
  %pl.i216 = alloca %struct.payload_t, align 8
  %pl.i206 = alloca %struct.payload_t, align 8
  %pl.i196 = alloca %struct.payload_t, align 8
  %pl.i186 = alloca %struct.payload_t, align 8
  %pl.i176 = alloca %struct.payload_t, align 8
  %pl.i166 = alloca %struct.payload_t, align 8
  %pl.i156 = alloca %struct.payload_t, align 8
  %pl.i146 = alloca %struct.payload_t, align 8
  %pl.i129 = alloca %struct.payload_t, align 8
  %pl.i = alloca %struct.payload_t, align 8
  %eth = alloca %struct.ethernet_t, align 8
  %ptp_l = alloca %struct.ptp_l_t, align 8
  %ptp_h = alloca %struct.ptp_h_t, align 8
  %ipv4 = alloca %struct.ipv4_t, align 8
  %tcp = alloca %struct.tcp_t, align 8
  %udp = alloca %struct.udp_t, align 8
  %header_0 = alloca %struct.header_t, align 8
  %header_1 = alloca %struct.header_t, align 8
  %header_2 = alloca %struct.header_t, align 8
  %header_3 = alloca %struct.header_t, align 8
  %header_4 = alloca %struct.header_t, align 8
  %header_5 = alloca %struct.header_t, align 8
  %header_6 = alloca %struct.header_t, align 8
  %header_7 = alloca %struct.header_t, align 8
  %port = alloca i16, align 2
  call void @llvm.lifetime.start.p0(i64 24, ptr nonnull %eth) #12
  call void @llvm.lifetime.start.p0(i64 32, ptr nonnull %ptp_l) #12
  call void @llvm.lifetime.start.p0(i64 24, ptr nonnull %ptp_h) #12
  call void @llvm.lifetime.start.p0(i64 40, ptr nonnull %ipv4) #12
  call void @llvm.lifetime.start.p0(i64 24, ptr nonnull %tcp) #12
  call void @llvm.lifetime.start.p0(i64 8, ptr nonnull %udp) #12
  call void @llvm.lifetime.start.p0(i64 8, ptr nonnull %header_0) #12
  call void @llvm.lifetime.start.p0(i64 8, ptr nonnull %header_1) #12
  call void @llvm.lifetime.start.p0(i64 8, ptr nonnull %header_2) #12
  call void @llvm.lifetime.start.p0(i64 8, ptr nonnull %header_3) #12
  call void @llvm.lifetime.start.p0(i64 8, ptr nonnull %header_4) #12
  call void @llvm.lifetime.start.p0(i64 8, ptr nonnull %header_5) #12
  call void @llvm.lifetime.start.p0(i64 8, ptr nonnull %header_6) #12
  call void @llvm.lifetime.start.p0(i64 8, ptr nonnull %header_7) #12
  call void @_ZN10primate_io12Input_headerI10ethernet_tEEviRT_(ptr noundef nonnull align 8 dereferenceable(1224) %top_intf, i32 noundef 14, ptr noundef nonnull align 8 dereferenceable(24) %eth)
  %etherType = getelementptr inbounds %struct.ethernet_t, ptr %eth, i64 0, i32 2
  %0 = load i16, ptr %etherType, align 8, !tbaa !5
  switch i16 %0, label %if.end53 [
    i16 -30473, label %if.then
    i16 2048, label %if.then41
  ]

if.then:                                          ; preds = %entry
  call void @_ZN10primate_io12Input_headerI7ptp_l_tEEviRT_(ptr noundef nonnull align 8 dereferenceable(1224) %top_intf, i32 noundef 20, ptr noundef nonnull align 8 dereferenceable(32) %ptp_l)
  call void @_ZN10primate_io12Input_headerI7ptp_h_tEEviRT_(ptr noundef nonnull align 8 dereferenceable(1224) %top_intf, i32 noundef 24, ptr noundef nonnull align 8 dereferenceable(24) %ptp_h)
  %reserved2 = getelementptr inbounds %struct.ptp_l_t, ptr %ptp_l, i64 0, i32 1
  %1 = load i8, ptr %reserved2, align 8, !tbaa !11
  %cmp2 = icmp eq i8 %1, 1
  br i1 %cmp2, label %if.then3, label %if.end53

if.then3:                                         ; preds = %if.then
  call void @_ZN10primate_io12Input_headerI8header_tEEviRT_(ptr noundef nonnull align 8 dereferenceable(1224) %top_intf, i32 noundef 8, ptr noundef nonnull align 2 dereferenceable(8) %header_0)
  %2 = load i16, ptr %header_0, align 8, !tbaa !16
  %cmp5.not = icmp eq i16 %2, 0
  br i1 %cmp5.not, label %if.end53, label %if.then6

if.then6:                                         ; preds = %if.then3
  call void @_ZN10primate_io12Input_headerI8header_tEEviRT_(ptr noundef nonnull align 8 dereferenceable(1224) %top_intf, i32 noundef 8, ptr noundef nonnull align 2 dereferenceable(8) %header_1)
  %3 = load i16, ptr %header_1, align 8, !tbaa !16
  %cmp9.not = icmp eq i16 %3, 0
  br i1 %cmp9.not, label %if.end53, label %if.then10

if.then10:                                        ; preds = %if.then6
  call void @_ZN10primate_io12Input_headerI8header_tEEviRT_(ptr noundef nonnull align 8 dereferenceable(1224) %top_intf, i32 noundef 8, ptr noundef nonnull align 2 dereferenceable(8) %header_2)
  %4 = load i16, ptr %header_2, align 8, !tbaa !16
  %cmp13.not = icmp eq i16 %4, 0
  br i1 %cmp13.not, label %if.end53, label %if.then14

if.then14:                                        ; preds = %if.then10
  call void @_ZN10primate_io12Input_headerI8header_tEEviRT_(ptr noundef nonnull align 8 dereferenceable(1224) %top_intf, i32 noundef 8, ptr noundef nonnull align 2 dereferenceable(8) %header_3)
  %5 = load i16, ptr %header_3, align 8, !tbaa !16
  %cmp17.not = icmp eq i16 %5, 0
  br i1 %cmp17.not, label %if.end53, label %if.then18

if.then18:                                        ; preds = %if.then14
  call void @_ZN10primate_io12Input_headerI8header_tEEviRT_(ptr noundef nonnull align 8 dereferenceable(1224) %top_intf, i32 noundef 8, ptr noundef nonnull align 2 dereferenceable(8) %header_4)
  %6 = load i16, ptr %header_4, align 8, !tbaa !16
  %cmp21.not = icmp eq i16 %6, 0
  br i1 %cmp21.not, label %if.end53, label %if.then22

if.then22:                                        ; preds = %if.then18
  call void @_ZN10primate_io12Input_headerI8header_tEEviRT_(ptr noundef nonnull align 8 dereferenceable(1224) %top_intf, i32 noundef 8, ptr noundef nonnull align 2 dereferenceable(8) %header_5)
  %7 = load i16, ptr %header_5, align 8, !tbaa !16
  %cmp25.not = icmp eq i16 %7, 0
  br i1 %cmp25.not, label %if.end53, label %if.then26

if.then26:                                        ; preds = %if.then22
  call void @_ZN10primate_io12Input_headerI8header_tEEviRT_(ptr noundef nonnull align 8 dereferenceable(1224) %top_intf, i32 noundef 8, ptr noundef nonnull align 2 dereferenceable(8) %header_6)
  %8 = load i16, ptr %header_6, align 8, !tbaa !16
  %cmp29.not = icmp eq i16 %8, 0
  br i1 %cmp29.not, label %if.end53, label %if.then30

if.then30:                                        ; preds = %if.then26
  call void @_ZN10primate_io12Input_headerI8header_tEEviRT_(ptr noundef nonnull align 8 dereferenceable(1224) %top_intf, i32 noundef 8, ptr noundef nonnull align 2 dereferenceable(8) %header_7)
  br label %if.end53

if.then41:                                        ; preds = %entry
  call void @_ZN10primate_io12Input_headerI6ipv4_tEEviRT_(ptr noundef nonnull align 8 dereferenceable(1224) %top_intf, i32 noundef 20, ptr noundef nonnull align 8 dereferenceable(40) %ipv4)
  %protocol = getelementptr inbounds %struct.ipv4_t, ptr %ipv4, i64 0, i32 1
  %9 = load i8, ptr %protocol, align 8, !tbaa !19
  switch i8 %9, label %if.end53 [
    i8 6, label %if.then44
    i8 17, label %if.then49
  ]

if.then44:                                        ; preds = %if.then41
  call void @_ZN10primate_io12Input_headerI5tcp_tEEviRT_(ptr noundef nonnull align 8 dereferenceable(1224) %top_intf, i32 noundef 20, ptr noundef nonnull align 8 dereferenceable(24) %tcp)
  br label %if.end53

if.then49:                                        ; preds = %if.then41
  call void @_ZN10primate_io12Input_headerI5udp_tEEviRT_(ptr noundef nonnull align 8 dereferenceable(1224) %top_intf, i32 noundef 8, ptr noundef nonnull align 8 dereferenceable(8) %udp)
  br label %if.end53

if.end53:                                         ; preds = %if.then41, %entry, %if.then49, %if.then44, %if.then, %if.then6, %if.then14, %if.then22, %if.then30, %if.then26, %if.then18, %if.then10, %if.then3
  %cmp57 = phi i1 [ false, %if.then49 ], [ false, %if.then44 ], [ true, %if.then ], [ true, %if.then6 ], [ true, %if.then14 ], [ true, %if.then22 ], [ true, %if.then30 ], [ true, %if.then26 ], [ true, %if.then18 ], [ true, %if.then10 ], [ true, %if.then3 ], [ true, %entry ], [ false, %if.then41 ]
  %cmp84 = phi i1 [ false, %if.then49 ], [ true, %if.then44 ], [ false, %if.then ], [ false, %if.then6 ], [ false, %if.then14 ], [ false, %if.then22 ], [ false, %if.then30 ], [ false, %if.then26 ], [ false, %if.then18 ], [ false, %if.then10 ], [ false, %if.then3 ], [ false, %entry ], [ false, %if.then41 ]
  %cmp59 = phi i1 [ true, %if.then49 ], [ true, %if.then44 ], [ false, %if.then ], [ true, %if.then6 ], [ true, %if.then14 ], [ true, %if.then22 ], [ true, %if.then30 ], [ true, %if.then26 ], [ true, %if.then18 ], [ true, %if.then10 ], [ true, %if.then3 ], [ false, %entry ], [ true, %if.then41 ]
  %cmp61 = phi i1 [ true, %if.then49 ], [ true, %if.then44 ], [ false, %if.then ], [ true, %if.then6 ], [ true, %if.then14 ], [ true, %if.then22 ], [ true, %if.then30 ], [ true, %if.then26 ], [ true, %if.then18 ], [ true, %if.then10 ], [ false, %if.then3 ], [ false, %entry ], [ true, %if.then41 ]
  %cmp63 = phi i1 [ true, %if.then49 ], [ true, %if.then44 ], [ false, %if.then ], [ false, %if.then6 ], [ true, %if.then14 ], [ true, %if.then22 ], [ true, %if.then30 ], [ true, %if.then26 ], [ true, %if.then18 ], [ true, %if.then10 ], [ false, %if.then3 ], [ false, %entry ], [ true, %if.then41 ]
  %cmp65 = phi i1 [ true, %if.then49 ], [ true, %if.then44 ], [ false, %if.then ], [ false, %if.then6 ], [ true, %if.then14 ], [ true, %if.then22 ], [ true, %if.then30 ], [ true, %if.then26 ], [ true, %if.then18 ], [ false, %if.then10 ], [ false, %if.then3 ], [ false, %entry ], [ true, %if.then41 ]
  %cmp67 = phi i1 [ true, %if.then49 ], [ true, %if.then44 ], [ false, %if.then ], [ false, %if.then6 ], [ false, %if.then14 ], [ true, %if.then22 ], [ true, %if.then30 ], [ true, %if.then26 ], [ true, %if.then18 ], [ false, %if.then10 ], [ false, %if.then3 ], [ false, %entry ], [ true, %if.then41 ]
  %cmp69 = phi i1 [ true, %if.then49 ], [ true, %if.then44 ], [ false, %if.then ], [ false, %if.then6 ], [ false, %if.then14 ], [ true, %if.then22 ], [ true, %if.then30 ], [ true, %if.then26 ], [ false, %if.then18 ], [ false, %if.then10 ], [ false, %if.then3 ], [ false, %entry ], [ true, %if.then41 ]
  %cmp71 = phi i1 [ true, %if.then49 ], [ true, %if.then44 ], [ false, %if.then ], [ false, %if.then6 ], [ false, %if.then14 ], [ false, %if.then22 ], [ true, %if.then30 ], [ true, %if.then26 ], [ false, %if.then18 ], [ false, %if.then10 ], [ false, %if.then3 ], [ false, %entry ], [ true, %if.then41 ]
  %cmp73 = phi i1 [ true, %if.then49 ], [ true, %if.then44 ], [ false, %if.then ], [ false, %if.then6 ], [ false, %if.then14 ], [ false, %if.then22 ], [ true, %if.then30 ], [ false, %if.then26 ], [ false, %if.then18 ], [ false, %if.then10 ], [ false, %if.then3 ], [ false, %entry ], [ true, %if.then41 ]
  call void @_ZN10primate_io10Input_doneEv(ptr noundef nonnull align 8 dereferenceable(1224) %top_intf)
  call void @llvm.lifetime.start.p0(i64 2, ptr nonnull %port) #12
  %call = call noundef i32 @_Z13forward_exactRDU48_Rt(ptr noundef nonnull align 8 dereferenceable(8) %eth, ptr noundef nonnull align 2 dereferenceable(2) %port)
  switch i32 %call, label %sw.epilog [
    i32 0, label %sw.bb
    i32 1, label %sw.bb55
  ]

sw.bb:                                            ; preds = %if.end53
  %10 = load i16, ptr %port, align 2, !tbaa !23
  %11 = zext i16 %10 to i64
  br label %sw.epilog

sw.bb55:                                          ; preds = %if.end53
  br label %sw.epilog

sw.epilog:                                        ; preds = %if.end53, %sw.bb55, %sw.bb
  %standard_metadata.sroa.0.0 = phi i64 [ 0, %if.end53 ], [ 511, %sw.bb55 ], [ %11, %sw.bb ]
  %call.i.i = call noundef nonnull align 8 dereferenceable(8) ptr @_ZNSo9_M_insertImEERSoT_(ptr noundef nonnull align 8 dereferenceable(8) @_ZSt4cout, i64 noundef %standard_metadata.sroa.0.0)
  %vtable.i.i = load ptr, ptr %call.i.i, align 8, !tbaa !24
  %vbase.offset.ptr.i.i = getelementptr i8, ptr %vtable.i.i, i64 -24
  %vbase.offset.i.i = load i64, ptr %vbase.offset.ptr.i.i, align 8
  %add.ptr.i.i = getelementptr inbounds i8, ptr %call.i.i, i64 %vbase.offset.i.i
  %_M_ctype.i.i.i = getelementptr inbounds %"class.std::basic_ios", ptr %add.ptr.i.i, i64 0, i32 5
  %12 = load ptr, ptr %_M_ctype.i.i.i, align 8, !tbaa !26
  %tobool.not.i.i.i.i = icmp eq ptr %12, null
  br i1 %tobool.not.i.i.i.i, label %if.then.i.i.i.i, label %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i.i.i

if.then.i.i.i.i:                                  ; preds = %sw.epilog
  call void @_ZSt16__throw_bad_castv() #13
  unreachable

_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i.i.i: ; preds = %sw.epilog
  %_M_widen_ok.i.i.i.i = getelementptr inbounds %"class.std::ctype", ptr %12, i64 0, i32 8
  %13 = load i8, ptr %_M_widen_ok.i.i.i.i, align 8, !tbaa !37
  %tobool.not.i3.i.i.i = icmp eq i8 %13, 0
  br i1 %tobool.not.i3.i.i.i, label %if.end.i.i.i.i, label %if.then.i4.i.i.i

if.then.i4.i.i.i:                                 ; preds = %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i.i.i
  %arrayidx.i.i.i.i = getelementptr inbounds %"class.std::ctype", ptr %12, i64 0, i32 9, i64 10
  %14 = load i8, ptr %arrayidx.i.i.i.i, align 1, !tbaa !40
  br label %_ZN10primate_io11Output_metaI19standard_metadata_tEEvRT_.exit

if.end.i.i.i.i:                                   ; preds = %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i.i.i
  call void @_ZNKSt5ctypeIcE13_M_widen_initEv(ptr noundef nonnull align 8 dereferenceable(570) %12)
  %vtable.i.i.i.i = load ptr, ptr %12, align 8, !tbaa !24
  %vfn.i.i.i.i = getelementptr inbounds ptr, ptr %vtable.i.i.i.i, i64 6
  %15 = load ptr, ptr %vfn.i.i.i.i, align 8
  %call.i.i.i.i = call noundef signext i8 %15(ptr noundef nonnull align 8 dereferenceable(570) %12, i8 noundef signext 10)
  br label %_ZN10primate_io11Output_metaI19standard_metadata_tEEvRT_.exit

_ZN10primate_io11Output_metaI19standard_metadata_tEEvRT_.exit: ; preds = %if.then.i4.i.i.i, %if.end.i.i.i.i
  %retval.0.i.i.i.i = phi i8 [ %14, %if.then.i4.i.i.i ], [ %call.i.i.i.i, %if.end.i.i.i.i ]
  %call1.i.i = call noundef nonnull align 8 dereferenceable(8) ptr @_ZNSo3putEc(ptr noundef nonnull align 8 dereferenceable(8) %call.i.i, i8 noundef signext %retval.0.i.i.i.i)
  %call.i.i.i = call noundef nonnull align 8 dereferenceable(8) ptr @_ZNSo5flushEv(ptr noundef nonnull align 8 dereferenceable(8) %call1.i.i)
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %pl.i) #12
  %16 = load i16, ptr %etherType, align 8, !tbaa !5, !noalias !41
  %conv.i.i128 = zext i16 %16 to i192
  %shl.i.i = shl nuw nsw i192 %conv.i.i128, 96
  %srcAddr.i.i = getelementptr inbounds %struct.ethernet_t, ptr %eth, i64 0, i32 1
  %17 = load i48, ptr %srcAddr.i.i, align 8, !tbaa !44, !noalias !41
  %conv2.i.i = zext i48 %17 to i192
  %shl3.i.i = shl nuw nsw i192 %conv2.i.i, 48
  %or.i.i = or i192 %shl3.i.i, %shl.i.i
  %18 = load i48, ptr %eth, align 8, !tbaa !45, !noalias !41
  %conv4.i.i = zext i48 %18 to i192
  %or5.i.i = or i192 %or.i.i, %conv4.i.i
  %conv.i = zext i192 %or5.i.i to i512
  store i512 %conv.i, ptr %pl.i, align 8, !tbaa !46
  %empty.i = getelementptr inbounds %struct.payload_t, ptr %pl.i, i64 0, i32 1
  store i32 50, ptr %empty.i, align 8, !tbaa !49
  %last.i = getelementptr inbounds %struct.payload_t, ptr %pl.i, i64 0, i32 2
  %pkt_buf.i = getelementptr inbounds %class.primate_io, ptr %top_intf, i64 0, i32 8
  %19 = load ptr, ptr %pkt_buf.i, align 8, !tbaa !50
  %_M_finish.i.i.i = getelementptr inbounds %class.primate_io, ptr %top_intf, i64 0, i32 8, i32 0, i32 0, i32 0, i32 1
  %20 = load ptr, ptr %_M_finish.i.i.i, align 8, !tbaa !50
  %cmp.i.i.i = icmp eq ptr %19, %20
  %spec.store.select.i = zext i1 %cmp.i.i.i to i8
  store i8 %spec.store.select.i, ptr %last.i, align 4
  %outfile.i = getelementptr inbounds %class.primate_io, ptr %top_intf, i64 0, i32 10
  %call3.i = call noundef nonnull align 8 dereferenceable(8) ptr @_ZlsRSoRK9payload_t(ptr noundef nonnull align 8 dereferenceable(8) %outfile.i, ptr noundef nonnull align 8 dereferenceable(72) %pl.i)
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %pl.i) #12
  br i1 %cmp57, label %if.then58, label %if.else83

if.then58:                                        ; preds = %_ZN10primate_io11Output_metaI19standard_metadata_tEEvRT_.exit
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %pl.i129) #12
  %flags_reserved3.i.i = getelementptr inbounds %struct.ptp_l_t, ptr %ptp_l, i64 0, i32 2
  %21 = load i112, ptr %flags_reserved3.i.i, align 8, !tbaa !51, !noalias !52
  %conv.i.i130 = zext i112 %21 to i192
  %shl.i.i131 = shl nuw nsw i192 %conv.i.i130, 48
  %reserved2.i.i = getelementptr inbounds %struct.ptp_l_t, ptr %ptp_l, i64 0, i32 1
  %22 = load i8, ptr %reserved2.i.i, align 8, !tbaa !11, !noalias !52
  %conv2.i.i132 = zext i8 %22 to i192
  %shl3.i.i133 = shl nuw nsw i192 %conv2.i.i132, 40
  %or.i.i134 = or i192 %shl3.i.i133, %shl.i.i131
  %23 = load i40, ptr %ptp_l, align 8, !tbaa !55, !noalias !52
  %conv4.i.i135 = zext i40 %23 to i192
  %or5.i.i136 = or i192 %or.i.i134, %conv4.i.i135
  %conv.i137 = zext i192 %or5.i.i136 to i512
  store i512 %conv.i137, ptr %pl.i129, align 8, !tbaa !46
  %empty.i138 = getelementptr inbounds %struct.payload_t, ptr %pl.i129, i64 0, i32 1
  store i32 44, ptr %empty.i138, align 8, !tbaa !49
  %last.i139 = getelementptr inbounds %struct.payload_t, ptr %pl.i129, i64 0, i32 2
  %24 = load ptr, ptr %pkt_buf.i, align 8, !tbaa !50
  %25 = load ptr, ptr %_M_finish.i.i.i, align 8, !tbaa !50
  %cmp.i.i.i142 = icmp eq ptr %24, %25
  %spec.store.select.i143 = zext i1 %cmp.i.i.i142 to i8
  store i8 %spec.store.select.i143, ptr %last.i139, align 4
  %call3.i145 = call noundef nonnull align 8 dereferenceable(8) ptr @_ZlsRSoRK9payload_t(ptr noundef nonnull align 8 dereferenceable(8) %outfile.i, ptr noundef nonnull align 8 dereferenceable(72) %pl.i129)
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %pl.i129) #12
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %pl.i146) #12
  %26 = load i192, ptr %ptp_h, align 8, !tbaa !56, !noalias !59
  %conv.i147 = zext i192 %26 to i512
  store i512 %conv.i147, ptr %pl.i146, align 8, !tbaa !46
  %empty.i148 = getelementptr inbounds %struct.payload_t, ptr %pl.i146, i64 0, i32 1
  store i32 40, ptr %empty.i148, align 8, !tbaa !49
  %last.i149 = getelementptr inbounds %struct.payload_t, ptr %pl.i146, i64 0, i32 2
  %27 = load ptr, ptr %pkt_buf.i, align 8, !tbaa !50
  %28 = load ptr, ptr %_M_finish.i.i.i, align 8, !tbaa !50
  %cmp.i.i.i152 = icmp eq ptr %27, %28
  %spec.store.select.i153 = zext i1 %cmp.i.i.i152 to i8
  store i8 %spec.store.select.i153, ptr %last.i149, align 4
  %call3.i155 = call noundef nonnull align 8 dereferenceable(8) ptr @_ZlsRSoRK9payload_t(ptr noundef nonnull align 8 dereferenceable(8) %outfile.i, ptr noundef nonnull align 8 dereferenceable(72) %pl.i146)
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %pl.i146) #12
  br i1 %cmp59, label %if.then60, label %if.end88

if.then60:                                        ; preds = %if.then58
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %pl.i156) #12
  %29 = load i64, ptr %header_0, align 8, !noalias !62
  %conv.i157 = zext i64 %29 to i512
  store i512 %conv.i157, ptr %pl.i156, align 8, !tbaa !46
  %empty.i158 = getelementptr inbounds %struct.payload_t, ptr %pl.i156, i64 0, i32 1
  store i32 56, ptr %empty.i158, align 8, !tbaa !49
  %last.i159 = getelementptr inbounds %struct.payload_t, ptr %pl.i156, i64 0, i32 2
  %30 = load ptr, ptr %pkt_buf.i, align 8, !tbaa !50
  %31 = load ptr, ptr %_M_finish.i.i.i, align 8, !tbaa !50
  %cmp.i.i.i162 = icmp eq ptr %30, %31
  %spec.store.select.i163 = zext i1 %cmp.i.i.i162 to i8
  store i8 %spec.store.select.i163, ptr %last.i159, align 4
  %call3.i165 = call noundef nonnull align 8 dereferenceable(8) ptr @_ZlsRSoRK9payload_t(ptr noundef nonnull align 8 dereferenceable(8) %outfile.i, ptr noundef nonnull align 8 dereferenceable(72) %pl.i156)
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %pl.i156) #12
  br i1 %cmp61, label %if.then62, label %if.end88

if.then62:                                        ; preds = %if.then60
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %pl.i166) #12
  %32 = load i64, ptr %header_1, align 8, !noalias !65
  %conv.i167 = zext i64 %32 to i512
  store i512 %conv.i167, ptr %pl.i166, align 8, !tbaa !46
  %empty.i168 = getelementptr inbounds %struct.payload_t, ptr %pl.i166, i64 0, i32 1
  store i32 56, ptr %empty.i168, align 8, !tbaa !49
  %last.i169 = getelementptr inbounds %struct.payload_t, ptr %pl.i166, i64 0, i32 2
  %33 = load ptr, ptr %pkt_buf.i, align 8, !tbaa !50
  %34 = load ptr, ptr %_M_finish.i.i.i, align 8, !tbaa !50
  %cmp.i.i.i172 = icmp eq ptr %33, %34
  %spec.store.select.i173 = zext i1 %cmp.i.i.i172 to i8
  store i8 %spec.store.select.i173, ptr %last.i169, align 4
  %call3.i175 = call noundef nonnull align 8 dereferenceable(8) ptr @_ZlsRSoRK9payload_t(ptr noundef nonnull align 8 dereferenceable(8) %outfile.i, ptr noundef nonnull align 8 dereferenceable(72) %pl.i166)
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %pl.i166) #12
  br i1 %cmp63, label %if.then64, label %if.end88

if.then64:                                        ; preds = %if.then62
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %pl.i176) #12
  %35 = load i64, ptr %header_2, align 8, !noalias !68
  %conv.i177 = zext i64 %35 to i512
  store i512 %conv.i177, ptr %pl.i176, align 8, !tbaa !46
  %empty.i178 = getelementptr inbounds %struct.payload_t, ptr %pl.i176, i64 0, i32 1
  store i32 56, ptr %empty.i178, align 8, !tbaa !49
  %last.i179 = getelementptr inbounds %struct.payload_t, ptr %pl.i176, i64 0, i32 2
  %36 = load ptr, ptr %pkt_buf.i, align 8, !tbaa !50
  %37 = load ptr, ptr %_M_finish.i.i.i, align 8, !tbaa !50
  %cmp.i.i.i182 = icmp eq ptr %36, %37
  %spec.store.select.i183 = zext i1 %cmp.i.i.i182 to i8
  store i8 %spec.store.select.i183, ptr %last.i179, align 4
  %call3.i185 = call noundef nonnull align 8 dereferenceable(8) ptr @_ZlsRSoRK9payload_t(ptr noundef nonnull align 8 dereferenceable(8) %outfile.i, ptr noundef nonnull align 8 dereferenceable(72) %pl.i176)
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %pl.i176) #12
  br i1 %cmp65, label %if.then66, label %if.end88

if.then66:                                        ; preds = %if.then64
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %pl.i186) #12
  %38 = load i64, ptr %header_3, align 8, !noalias !71
  %conv.i187 = zext i64 %38 to i512
  store i512 %conv.i187, ptr %pl.i186, align 8, !tbaa !46
  %empty.i188 = getelementptr inbounds %struct.payload_t, ptr %pl.i186, i64 0, i32 1
  store i32 56, ptr %empty.i188, align 8, !tbaa !49
  %last.i189 = getelementptr inbounds %struct.payload_t, ptr %pl.i186, i64 0, i32 2
  %39 = load ptr, ptr %pkt_buf.i, align 8, !tbaa !50
  %40 = load ptr, ptr %_M_finish.i.i.i, align 8, !tbaa !50
  %cmp.i.i.i192 = icmp eq ptr %39, %40
  %spec.store.select.i193 = zext i1 %cmp.i.i.i192 to i8
  store i8 %spec.store.select.i193, ptr %last.i189, align 4
  %call3.i195 = call noundef nonnull align 8 dereferenceable(8) ptr @_ZlsRSoRK9payload_t(ptr noundef nonnull align 8 dereferenceable(8) %outfile.i, ptr noundef nonnull align 8 dereferenceable(72) %pl.i186)
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %pl.i186) #12
  br i1 %cmp67, label %if.then68, label %if.end88

if.then68:                                        ; preds = %if.then66
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %pl.i196) #12
  %41 = load i64, ptr %header_4, align 8, !noalias !74
  %conv.i197 = zext i64 %41 to i512
  store i512 %conv.i197, ptr %pl.i196, align 8, !tbaa !46
  %empty.i198 = getelementptr inbounds %struct.payload_t, ptr %pl.i196, i64 0, i32 1
  store i32 56, ptr %empty.i198, align 8, !tbaa !49
  %last.i199 = getelementptr inbounds %struct.payload_t, ptr %pl.i196, i64 0, i32 2
  %42 = load ptr, ptr %pkt_buf.i, align 8, !tbaa !50
  %43 = load ptr, ptr %_M_finish.i.i.i, align 8, !tbaa !50
  %cmp.i.i.i202 = icmp eq ptr %42, %43
  %spec.store.select.i203 = zext i1 %cmp.i.i.i202 to i8
  store i8 %spec.store.select.i203, ptr %last.i199, align 4
  %call3.i205 = call noundef nonnull align 8 dereferenceable(8) ptr @_ZlsRSoRK9payload_t(ptr noundef nonnull align 8 dereferenceable(8) %outfile.i, ptr noundef nonnull align 8 dereferenceable(72) %pl.i196)
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %pl.i196) #12
  br i1 %cmp69, label %if.then70, label %if.end88

if.then70:                                        ; preds = %if.then68
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %pl.i206) #12
  %44 = load i64, ptr %header_5, align 8, !noalias !77
  %conv.i207 = zext i64 %44 to i512
  store i512 %conv.i207, ptr %pl.i206, align 8, !tbaa !46
  %empty.i208 = getelementptr inbounds %struct.payload_t, ptr %pl.i206, i64 0, i32 1
  store i32 56, ptr %empty.i208, align 8, !tbaa !49
  %last.i209 = getelementptr inbounds %struct.payload_t, ptr %pl.i206, i64 0, i32 2
  %45 = load ptr, ptr %pkt_buf.i, align 8, !tbaa !50
  %46 = load ptr, ptr %_M_finish.i.i.i, align 8, !tbaa !50
  %cmp.i.i.i212 = icmp eq ptr %45, %46
  %spec.store.select.i213 = zext i1 %cmp.i.i.i212 to i8
  store i8 %spec.store.select.i213, ptr %last.i209, align 4
  %call3.i215 = call noundef nonnull align 8 dereferenceable(8) ptr @_ZlsRSoRK9payload_t(ptr noundef nonnull align 8 dereferenceable(8) %outfile.i, ptr noundef nonnull align 8 dereferenceable(72) %pl.i206)
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %pl.i206) #12
  br i1 %cmp71, label %if.then72, label %if.end88

if.then72:                                        ; preds = %if.then70
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %pl.i216) #12
  %47 = load i64, ptr %header_6, align 8, !noalias !80
  %conv.i217 = zext i64 %47 to i512
  store i512 %conv.i217, ptr %pl.i216, align 8, !tbaa !46
  %empty.i218 = getelementptr inbounds %struct.payload_t, ptr %pl.i216, i64 0, i32 1
  store i32 56, ptr %empty.i218, align 8, !tbaa !49
  %last.i219 = getelementptr inbounds %struct.payload_t, ptr %pl.i216, i64 0, i32 2
  %48 = load ptr, ptr %pkt_buf.i, align 8, !tbaa !50
  %49 = load ptr, ptr %_M_finish.i.i.i, align 8, !tbaa !50
  %cmp.i.i.i222 = icmp eq ptr %48, %49
  %spec.store.select.i223 = zext i1 %cmp.i.i.i222 to i8
  store i8 %spec.store.select.i223, ptr %last.i219, align 4
  %call3.i225 = call noundef nonnull align 8 dereferenceable(8) ptr @_ZlsRSoRK9payload_t(ptr noundef nonnull align 8 dereferenceable(8) %outfile.i, ptr noundef nonnull align 8 dereferenceable(72) %pl.i216)
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %pl.i216) #12
  br i1 %cmp73, label %if.then74, label %if.end88

if.then74:                                        ; preds = %if.then72
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %pl.i226) #12
  %50 = load i64, ptr %header_7, align 8, !noalias !83
  %conv.i227 = zext i64 %50 to i512
  store i512 %conv.i227, ptr %pl.i226, align 8, !tbaa !46
  %empty.i228 = getelementptr inbounds %struct.payload_t, ptr %pl.i226, i64 0, i32 1
  store i32 56, ptr %empty.i228, align 8, !tbaa !49
  %last.i229 = getelementptr inbounds %struct.payload_t, ptr %pl.i226, i64 0, i32 2
  %51 = load ptr, ptr %pkt_buf.i, align 8, !tbaa !50
  %52 = load ptr, ptr %_M_finish.i.i.i, align 8, !tbaa !50
  %cmp.i.i.i232 = icmp eq ptr %51, %52
  %spec.store.select.i233 = zext i1 %cmp.i.i.i232 to i8
  store i8 %spec.store.select.i233, ptr %last.i229, align 4
  %call3.i235 = call noundef nonnull align 8 dereferenceable(8) ptr @_ZlsRSoRK9payload_t(ptr noundef nonnull align 8 dereferenceable(8) %outfile.i, ptr noundef nonnull align 8 dereferenceable(72) %pl.i226)
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %pl.i226) #12
  br label %if.end88

if.else83:                                        ; preds = %_ZN10primate_io11Output_metaI19standard_metadata_tEEvRT_.exit
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %pl.i236) #12
  %hdrChecksum_dstAddr.i.i = getelementptr inbounds %struct.ipv4_t, ptr %ipv4, i64 0, i32 2
  %53 = load i80, ptr %hdrChecksum_dstAddr.i.i, align 8, !tbaa !86, !noalias !87
  %conv.i.i237 = zext i80 %53 to i192
  %shl.i.i238 = shl nuw nsw i192 %conv.i.i237, 80
  %protocol.i.i = getelementptr inbounds %struct.ipv4_t, ptr %ipv4, i64 0, i32 1
  %54 = load i8, ptr %protocol.i.i, align 8, !tbaa !19, !noalias !87
  %conv2.i.i239 = zext i8 %54 to i192
  %shl3.i.i240 = shl nuw nsw i192 %conv2.i.i239, 72
  %or.i.i241 = or i192 %shl3.i.i240, %shl.i.i238
  %55 = load i72, ptr %ipv4, align 8, !tbaa !90, !noalias !87
  %conv4.i.i242 = zext i72 %55 to i192
  %or5.i.i243 = or i192 %or.i.i241, %conv4.i.i242
  %conv.i244 = zext i192 %or5.i.i243 to i512
  store i512 %conv.i244, ptr %pl.i236, align 8, !tbaa !46
  %empty.i245 = getelementptr inbounds %struct.payload_t, ptr %pl.i236, i64 0, i32 1
  store i32 44, ptr %empty.i245, align 8, !tbaa !49
  %last.i246 = getelementptr inbounds %struct.payload_t, ptr %pl.i236, i64 0, i32 2
  %56 = load ptr, ptr %pkt_buf.i, align 8, !tbaa !50
  %57 = load ptr, ptr %_M_finish.i.i.i, align 8, !tbaa !50
  %cmp.i.i.i249 = icmp eq ptr %56, %57
  %spec.store.select.i250 = zext i1 %cmp.i.i.i249 to i8
  store i8 %spec.store.select.i250, ptr %last.i246, align 4
  %call3.i252 = call noundef nonnull align 8 dereferenceable(8) ptr @_ZlsRSoRK9payload_t(ptr noundef nonnull align 8 dereferenceable(8) %outfile.i, ptr noundef nonnull align 8 dereferenceable(72) %pl.i236)
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %pl.i236) #12
  br i1 %cmp84, label %if.then85, label %if.else86

if.then85:                                        ; preds = %if.else83
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %pl.i253) #12
  %58 = load i160, ptr %tcp, align 8, !tbaa !91, !noalias !94
  %conv.i254 = zext i160 %58 to i512
  store i512 %conv.i254, ptr %pl.i253, align 8, !tbaa !46
  %empty.i255 = getelementptr inbounds %struct.payload_t, ptr %pl.i253, i64 0, i32 1
  store i32 44, ptr %empty.i255, align 8, !tbaa !49
  %last.i256 = getelementptr inbounds %struct.payload_t, ptr %pl.i253, i64 0, i32 2
  %59 = load ptr, ptr %pkt_buf.i, align 8, !tbaa !50
  %60 = load ptr, ptr %_M_finish.i.i.i, align 8, !tbaa !50
  %cmp.i.i.i259 = icmp eq ptr %59, %60
  %spec.store.select.i260 = zext i1 %cmp.i.i.i259 to i8
  store i8 %spec.store.select.i260, ptr %last.i256, align 4
  %call3.i262 = call noundef nonnull align 8 dereferenceable(8) ptr @_ZlsRSoRK9payload_t(ptr noundef nonnull align 8 dereferenceable(8) %outfile.i, ptr noundef nonnull align 8 dereferenceable(72) %pl.i253)
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %pl.i253) #12
  br label %if.end88

if.else86:                                        ; preds = %if.else83
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %pl.i263) #12
  %61 = load i64, ptr %udp, align 8, !tbaa !97, !noalias !100
  %conv.i264 = zext i64 %61 to i512
  store i512 %conv.i264, ptr %pl.i263, align 8, !tbaa !46
  %empty.i265 = getelementptr inbounds %struct.payload_t, ptr %pl.i263, i64 0, i32 1
  store i32 56, ptr %empty.i265, align 8, !tbaa !49
  %last.i266 = getelementptr inbounds %struct.payload_t, ptr %pl.i263, i64 0, i32 2
  %62 = load ptr, ptr %pkt_buf.i, align 8, !tbaa !50
  %63 = load ptr, ptr %_M_finish.i.i.i, align 8, !tbaa !50
  %cmp.i.i.i269 = icmp eq ptr %62, %63
  %spec.store.select.i270 = zext i1 %cmp.i.i.i269 to i8
  store i8 %spec.store.select.i270, ptr %last.i266, align 4
  %call3.i272 = call noundef nonnull align 8 dereferenceable(8) ptr @_ZlsRSoRK9payload_t(ptr noundef nonnull align 8 dereferenceable(8) %outfile.i, ptr noundef nonnull align 8 dereferenceable(72) %pl.i263)
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %pl.i263) #12
  br label %if.end88

if.end88:                                         ; preds = %if.then85, %if.else86, %if.then58, %if.then62, %if.then66, %if.then70, %if.then74, %if.then72, %if.then68, %if.then64, %if.then60
  %64 = load ptr, ptr %pkt_buf.i, align 8, !tbaa !50
  %65 = load ptr, ptr %_M_finish.i.i.i, align 8, !tbaa !50
  %cmp.i.not13.i = icmp eq ptr %64, %65
  br i1 %cmp.i.not13.i, label %_ZN10primate_io11Output_doneEv.exit, label %for.body.i

for.cond.cleanup.i:                               ; preds = %for.body.i
  %.pre.i = load ptr, ptr %pkt_buf.i, align 8, !tbaa !103
  %tobool.not.i.i.i = icmp eq ptr %incdec.ptr.i.i, %.pre.i
  br i1 %tobool.not.i.i.i, label %_ZN10primate_io11Output_doneEv.exit, label %invoke.cont.i.i.i

invoke.cont.i.i.i:                                ; preds = %for.cond.cleanup.i
  store ptr %.pre.i, ptr %_M_finish.i.i.i, align 8, !tbaa !105
  br label %_ZN10primate_io11Output_doneEv.exit

for.body.i:                                       ; preds = %if.end88, %for.body.i
  %it.sroa.0.014.i = phi ptr [ %incdec.ptr.i.i, %for.body.i ], [ %64, %if.end88 ]
  %call7.i = call noundef nonnull align 8 dereferenceable(8) ptr @_ZlsRSoRK9payload_t(ptr noundef nonnull align 8 dereferenceable(8) %outfile.i, ptr noundef nonnull align 8 dereferenceable(72) %it.sroa.0.014.i)
  %incdec.ptr.i.i = getelementptr inbounds %struct.payload_t, ptr %it.sroa.0.014.i, i64 1
  %66 = load ptr, ptr %_M_finish.i.i.i, align 8, !tbaa !50
  %cmp.i.not.i = icmp eq ptr %incdec.ptr.i.i, %66
  br i1 %cmp.i.not.i, label %for.cond.cleanup.i, label %for.body.i, !llvm.loop !106

_ZN10primate_io11Output_doneEv.exit:              ; preds = %if.end88, %for.cond.cleanup.i, %invoke.cont.i.i.i
  call void @llvm.lifetime.end.p0(i64 2, ptr nonnull %port) #12
  call void @llvm.lifetime.end.p0(i64 8, ptr nonnull %header_7) #12
  call void @llvm.lifetime.end.p0(i64 8, ptr nonnull %header_6) #12
  call void @llvm.lifetime.end.p0(i64 8, ptr nonnull %header_5) #12
  call void @llvm.lifetime.end.p0(i64 8, ptr nonnull %header_4) #12
  call void @llvm.lifetime.end.p0(i64 8, ptr nonnull %header_3) #12
  call void @llvm.lifetime.end.p0(i64 8, ptr nonnull %header_2) #12
  call void @llvm.lifetime.end.p0(i64 8, ptr nonnull %header_1) #12
  call void @llvm.lifetime.end.p0(i64 8, ptr nonnull %header_0) #12
  call void @llvm.lifetime.end.p0(i64 8, ptr nonnull %udp) #12
  call void @llvm.lifetime.end.p0(i64 24, ptr nonnull %tcp) #12
  call void @llvm.lifetime.end.p0(i64 40, ptr nonnull %ipv4) #12
  call void @llvm.lifetime.end.p0(i64 24, ptr nonnull %ptp_h) #12
  call void @llvm.lifetime.end.p0(i64 32, ptr nonnull %ptp_l) #12
  call void @llvm.lifetime.end.p0(i64 24, ptr nonnull %eth) #12
  ret void
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr nocapture) #4

; Function Attrs: mustprogress uwtable
define linkonce_odr dso_local void @_ZN10primate_io12Input_headerI10ethernet_tEEviRT_(ptr noundef nonnull align 8 dereferenceable(1224) %this, i32 noundef %length, ptr noundef nonnull align 8 dereferenceable(24) %header) local_unnamed_addr #5 comdat align 2 {
entry:
  %bv.i = alloca i112, align 8
  %ref.tmp = alloca %struct.payload_t, align 8
  %coerce = alloca i112, align 8
  %ref.tmp47 = alloca %struct.payload_t, align 8
  %payload_v = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 7
  %0 = load i8, ptr %payload_v, align 8, !tbaa !108, !range !122, !noundef !123
  %tobool.not = icmp eq i8 %0, 0
  br i1 %tobool.not, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %ref.tmp) #12
  %infile = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 9
  call void @_Z9get_inputRSt14basic_ifstreamIcSt11char_traitsIcEE(ptr nonnull sret(%struct.payload_t) align 8 %ref.tmp, ptr noundef nonnull align 8 dereferenceable(256) %infile)
  %payload = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 6
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 8 dereferenceable(72) %payload, ptr noundef nonnull align 8 dereferenceable(72) %ref.tmp, i64 72, i1 false), !tbaa.struct !124
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %ref.tmp) #12
  store i8 1, ptr %payload_v, align 8, !tbaa !108
  br label %if.end

if.end:                                           ; preds = %if.then, %entry
  %input_buf_len = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 3
  %srcAddr.i = getelementptr inbounds %struct.ethernet_t, ptr %header, i64 0, i32 1
  %etherType.i = getelementptr inbounds %struct.ethernet_t, ptr %header, i64 0, i32 2
  %payload13 = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 6
  %fifo_empty = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 4
  %last = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 6, i32 2
  %last_buf = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 5
  %infile48 = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 9
  %flits = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 2
  %coerce.8.coerce.8.coerce.8.coerce.8..sroa_idx = getelementptr inbounds i8, ptr %coerce, i64 8
  %bv.i.8.bv.i.8.bv.i.8.bv.8.bv.8.bv.8..sroa_idx = getelementptr inbounds i8, ptr %bv.i, i64 8
  br label %while.body

while.body:                                       ; preds = %if.end, %if.end57
  %res_valid.066 = phi i8 [ 0, %if.end ], [ %res_valid.1, %if.end57 ]
  %1 = load i32, ptr %input_buf_len, align 8, !tbaa !128
  %cmp.not = icmp slt i32 %1, %length
  br i1 %cmp.not, label %if.end5, label %if.then4

if.then4:                                         ; preds = %while.body
  %2 = load i512, ptr %this, align 8, !tbaa !129
  %conv = trunc i512 %2 to i112
  store i112 %conv, ptr %coerce, align 8, !tbaa !130
  %3 = trunc i512 %2 to i64
  %coerce.8.coerce.8.coerce.8.coerce.8. = load i64, ptr %coerce.8.coerce.8.coerce.8.coerce.8..sroa_idx, align 8
  call void @llvm.lifetime.start.p0(i64 16, ptr nonnull %bv.i)
  store i64 %3, ptr %bv.i, align 8
  store i64 %coerce.8.coerce.8.coerce.8.coerce.8., ptr %bv.i.8.bv.i.8.bv.i.8.bv.8.bv.8.bv.8..sroa_idx, align 8
  %bv.i.0.bv.i.0.bv.i.0.bv.0.bv.0.bv.0.bv1.i = load i112, ptr %bv.i, align 8, !tbaa !130
  %conv.i = trunc i112 %bv.i.0.bv.i.0.bv.i.0.bv.0.bv.0.bv.0.bv1.i to i48
  store i48 %conv.i, ptr %header, align 8, !tbaa !45
  %shr.i = lshr i112 %bv.i.0.bv.i.0.bv.i.0.bv.0.bv.0.bv.0.bv1.i, 48
  %conv3.i = trunc i112 %shr.i to i48
  store i48 %conv3.i, ptr %srcAddr.i, align 8, !tbaa !44
  %shr4.i = lshr i112 %bv.i.0.bv.i.0.bv.i.0.bv.0.bv.0.bv.0.bv1.i, 96
  %conv5.i = trunc i112 %shr4.i to i16
  store i16 %conv5.i, ptr %etherType.i, align 8, !tbaa !5
  call void @llvm.lifetime.end.p0(i64 16, ptr nonnull %bv.i)
  br label %if.end5

if.end5:                                          ; preds = %if.then4, %while.body
  %res_valid.1 = phi i8 [ 1, %if.then4 ], [ %res_valid.066, %while.body ]
  %shift.0 = phi i32 [ %length, %if.then4 ], [ 0, %while.body ]
  %cmp7 = icmp eq i32 %1, 0
  %cmp9 = icmp eq i32 %1, %shift.0
  %or.cond = or i1 %cmp7, %cmp9
  %4 = load i512, ptr %payload13, align 8, !tbaa !131
  %.pre = load i32, ptr %fifo_empty, align 4, !tbaa !132
  br i1 %or.cond, label %if.end32, label %if.else

if.else:                                          ; preds = %if.end5
  %mul = shl nsw i32 %.pre, 3
  %sh_prom = zext i32 %mul to i512
  %shr = lshr i512 %4, %sh_prom
  %mul16 = shl nsw i32 %1, 3
  %mul17 = shl nsw i32 %shift.0, 3
  %sub = sub nsw i32 %mul16, %mul17
  %sh_prom18 = zext i32 %sub to i512
  %shl = shl i512 %shr, %sh_prom18
  %5 = load i512, ptr %this, align 8, !tbaa !129
  %sub22 = sub nsw i32 512, %mul16
  %sh_prom23 = zext i32 %sub22 to i512
  %shl24 = shl i512 %5, %sh_prom23
  %add = add nsw i32 %mul17, %sub22
  %sh_prom29 = zext i32 %add to i512
  %shr30 = lshr i512 %shl24, %sh_prom29
  %or = or i512 %shl, %shr30
  br label %if.end32

if.end32:                                         ; preds = %if.end5, %if.else
  %storemerge = phi i512 [ %or, %if.else ], [ %4, %if.end5 ]
  store i512 %storemerge, ptr %this, align 8, !tbaa !129
  %sub34 = sub nsw i32 %1, %shift.0
  %cmp36.not = icmp sgt i32 %sub34, %.pre
  br i1 %cmp36.not, label %if.else50, label %if.then37

if.then37:                                        ; preds = %if.end32
  %add40 = add nsw i32 %sub34, 64
  %sub42 = sub i32 %add40, %.pre
  store i32 %sub42, ptr %input_buf_len, align 8, !tbaa !128
  %6 = load i8, ptr %last, align 4, !tbaa !133, !range !122, !noundef !123
  store i8 %6, ptr %last_buf, align 8, !tbaa !134
  store i32 0, ptr %fifo_empty, align 4, !tbaa !132
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %ref.tmp47) #12
  call void @_Z9get_inputRSt14basic_ifstreamIcSt11char_traitsIcEE(ptr nonnull sret(%struct.payload_t) align 8 %ref.tmp47, ptr noundef nonnull align 8 dereferenceable(256) %infile48)
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 8 dereferenceable(72) %payload13, ptr noundef nonnull align 8 dereferenceable(72) %ref.tmp47, i64 72, i1 false), !tbaa.struct !124
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %ref.tmp47) #12
  %7 = load i32, ptr %flits, align 4, !tbaa !135
  %inc = add i32 %7, 1
  store i32 %inc, ptr %flits, align 4, !tbaa !135
  br label %if.end57

if.else50:                                        ; preds = %if.end32
  %sub52 = sub i32 64, %1
  %add53 = add nsw i32 %sub52, %shift.0
  %add55 = add nsw i32 %add53, %.pre
  store i32 %add55, ptr %fifo_empty, align 4, !tbaa !132
  store i32 64, ptr %input_buf_len, align 8, !tbaa !128
  br label %if.end57

if.end57:                                         ; preds = %if.else50, %if.then37
  %8 = and i8 %res_valid.1, 1
  %tobool3.not = icmp eq i8 %8, 0
  br i1 %tobool3.not, label %while.body, label %while.end, !llvm.loop !136

while.end:                                        ; preds = %if.end57
  ret void
}

; Function Attrs: mustprogress uwtable
define linkonce_odr dso_local void @_ZN10primate_io12Input_headerI7ptp_l_tEEviRT_(ptr noundef nonnull align 8 dereferenceable(1224) %this, i32 noundef %length, ptr noundef nonnull align 8 dereferenceable(32) %header) local_unnamed_addr #5 comdat align 2 {
entry:
  %ref.tmp = alloca %struct.payload_t, align 8
  %ref.tmp47 = alloca %struct.payload_t, align 8
  %payload_v = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 7
  %0 = load i8, ptr %payload_v, align 8, !tbaa !108, !range !122, !noundef !123
  %tobool.not = icmp eq i8 %0, 0
  br i1 %tobool.not, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %ref.tmp) #12
  %infile = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 9
  call void @_Z9get_inputRSt14basic_ifstreamIcSt11char_traitsIcEE(ptr nonnull sret(%struct.payload_t) align 8 %ref.tmp, ptr noundef nonnull align 8 dereferenceable(256) %infile)
  %payload = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 6
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 8 dereferenceable(72) %payload, ptr noundef nonnull align 8 dereferenceable(72) %ref.tmp, i64 72, i1 false), !tbaa.struct !124
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %ref.tmp) #12
  store i8 1, ptr %payload_v, align 8, !tbaa !108
  br label %if.end

if.end:                                           ; preds = %if.then, %entry
  %input_buf_len = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 3
  %reserved2.i = getelementptr inbounds %struct.ptp_l_t, ptr %header, i64 0, i32 1
  %flags_reserved3.i = getelementptr inbounds %struct.ptp_l_t, ptr %header, i64 0, i32 2
  %payload13 = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 6
  %fifo_empty = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 4
  %last = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 6, i32 2
  %last_buf = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 5
  %infile48 = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 9
  %flits = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 2
  br label %while.body

while.body:                                       ; preds = %if.end, %if.end57
  %res_valid.069 = phi i8 [ 0, %if.end ], [ %res_valid.1, %if.end57 ]
  %1 = load i32, ptr %input_buf_len, align 8, !tbaa !128
  %cmp.not = icmp slt i32 %1, %length
  br i1 %cmp.not, label %if.end5, label %if.then4

if.then4:                                         ; preds = %while.body
  %2 = load i512, ptr %this, align 8, !tbaa !129
  %conv.i = trunc i512 %2 to i40
  store i40 %conv.i, ptr %header, align 8, !tbaa !55
  %shr.i66 = lshr i512 %2, 40
  %conv3.i = trunc i512 %shr.i66 to i8
  store i8 %conv3.i, ptr %reserved2.i, align 8, !tbaa !11
  %shr4.i67 = lshr i512 %2, 48
  %conv5.i = trunc i512 %shr4.i67 to i112
  store i112 %conv5.i, ptr %flags_reserved3.i, align 8, !tbaa !51
  br label %if.end5

if.end5:                                          ; preds = %if.then4, %while.body
  %res_valid.1 = phi i8 [ 1, %if.then4 ], [ %res_valid.069, %while.body ]
  %shift.0 = phi i32 [ %length, %if.then4 ], [ 0, %while.body ]
  %cmp7 = icmp eq i32 %1, 0
  %cmp9 = icmp eq i32 %1, %shift.0
  %or.cond = or i1 %cmp7, %cmp9
  %3 = load i512, ptr %payload13, align 8, !tbaa !131
  %.pre = load i32, ptr %fifo_empty, align 4, !tbaa !132
  br i1 %or.cond, label %if.end32, label %if.else

if.else:                                          ; preds = %if.end5
  %mul = shl nsw i32 %.pre, 3
  %sh_prom = zext i32 %mul to i512
  %shr = lshr i512 %3, %sh_prom
  %mul16 = shl nsw i32 %1, 3
  %mul17 = shl nsw i32 %shift.0, 3
  %sub = sub nsw i32 %mul16, %mul17
  %sh_prom18 = zext i32 %sub to i512
  %shl = shl i512 %shr, %sh_prom18
  %4 = load i512, ptr %this, align 8, !tbaa !129
  %sub22 = sub nsw i32 512, %mul16
  %sh_prom23 = zext i32 %sub22 to i512
  %shl24 = shl i512 %4, %sh_prom23
  %add = add nsw i32 %mul17, %sub22
  %sh_prom29 = zext i32 %add to i512
  %shr30 = lshr i512 %shl24, %sh_prom29
  %or = or i512 %shl, %shr30
  br label %if.end32

if.end32:                                         ; preds = %if.end5, %if.else
  %storemerge = phi i512 [ %or, %if.else ], [ %3, %if.end5 ]
  store i512 %storemerge, ptr %this, align 8, !tbaa !129
  %sub34 = sub nsw i32 %1, %shift.0
  %cmp36.not = icmp sgt i32 %sub34, %.pre
  br i1 %cmp36.not, label %if.else50, label %if.then37

if.then37:                                        ; preds = %if.end32
  %add40 = add nsw i32 %sub34, 64
  %sub42 = sub i32 %add40, %.pre
  store i32 %sub42, ptr %input_buf_len, align 8, !tbaa !128
  %5 = load i8, ptr %last, align 4, !tbaa !133, !range !122, !noundef !123
  store i8 %5, ptr %last_buf, align 8, !tbaa !134
  store i32 0, ptr %fifo_empty, align 4, !tbaa !132
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %ref.tmp47) #12
  call void @_Z9get_inputRSt14basic_ifstreamIcSt11char_traitsIcEE(ptr nonnull sret(%struct.payload_t) align 8 %ref.tmp47, ptr noundef nonnull align 8 dereferenceable(256) %infile48)
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 8 dereferenceable(72) %payload13, ptr noundef nonnull align 8 dereferenceable(72) %ref.tmp47, i64 72, i1 false), !tbaa.struct !124
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %ref.tmp47) #12
  %6 = load i32, ptr %flits, align 4, !tbaa !135
  %inc = add i32 %6, 1
  store i32 %inc, ptr %flits, align 4, !tbaa !135
  br label %if.end57

if.else50:                                        ; preds = %if.end32
  %sub52 = sub i32 64, %1
  %add53 = add nsw i32 %sub52, %shift.0
  %add55 = add nsw i32 %add53, %.pre
  store i32 %add55, ptr %fifo_empty, align 4, !tbaa !132
  store i32 64, ptr %input_buf_len, align 8, !tbaa !128
  br label %if.end57

if.end57:                                         ; preds = %if.else50, %if.then37
  %7 = and i8 %res_valid.1, 1
  %tobool3.not = icmp eq i8 %7, 0
  br i1 %tobool3.not, label %while.body, label %while.end, !llvm.loop !137

while.end:                                        ; preds = %if.end57
  ret void
}

; Function Attrs: mustprogress uwtable
define linkonce_odr dso_local void @_ZN10primate_io12Input_headerI7ptp_h_tEEviRT_(ptr noundef nonnull align 8 dereferenceable(1224) %this, i32 noundef %length, ptr noundef nonnull align 8 dereferenceable(24) %header) local_unnamed_addr #5 comdat align 2 {
entry:
  %ref.tmp = alloca %struct.payload_t, align 8
  %ref.tmp47 = alloca %struct.payload_t, align 8
  %payload_v = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 7
  %0 = load i8, ptr %payload_v, align 8, !tbaa !108, !range !122, !noundef !123
  %tobool.not = icmp eq i8 %0, 0
  br i1 %tobool.not, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %ref.tmp) #12
  %infile = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 9
  call void @_Z9get_inputRSt14basic_ifstreamIcSt11char_traitsIcEE(ptr nonnull sret(%struct.payload_t) align 8 %ref.tmp, ptr noundef nonnull align 8 dereferenceable(256) %infile)
  %payload = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 6
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 8 dereferenceable(72) %payload, ptr noundef nonnull align 8 dereferenceable(72) %ref.tmp, i64 72, i1 false), !tbaa.struct !124
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %ref.tmp) #12
  store i8 1, ptr %payload_v, align 8, !tbaa !108
  br label %if.end

if.end:                                           ; preds = %if.then, %entry
  %input_buf_len = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 3
  %payload13 = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 6
  %fifo_empty = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 4
  %last = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 6, i32 2
  %last_buf = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 5
  %infile48 = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 9
  %flits = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 2
  br label %while.body

while.body:                                       ; preds = %if.end, %if.end57
  %res_valid.067 = phi i8 [ 0, %if.end ], [ %res_valid.1, %if.end57 ]
  %1 = load i32, ptr %input_buf_len, align 8, !tbaa !128
  %cmp.not = icmp slt i32 %1, %length
  br i1 %cmp.not, label %if.end5, label %if.then4

if.then4:                                         ; preds = %while.body
  %2 = load i512, ptr %this, align 8, !tbaa !129
  %conv = trunc i512 %2 to i192
  store i192 %conv, ptr %header, align 8, !tbaa !56
  br label %if.end5

if.end5:                                          ; preds = %if.then4, %while.body
  %res_valid.1 = phi i8 [ 1, %if.then4 ], [ %res_valid.067, %while.body ]
  %shift.0 = phi i32 [ %length, %if.then4 ], [ 0, %while.body ]
  %cmp7 = icmp eq i32 %1, 0
  %cmp9 = icmp eq i32 %1, %shift.0
  %or.cond = or i1 %cmp7, %cmp9
  %3 = load i512, ptr %payload13, align 8, !tbaa !131
  %.pre = load i32, ptr %fifo_empty, align 4, !tbaa !132
  br i1 %or.cond, label %if.end32, label %if.else

if.else:                                          ; preds = %if.end5
  %mul = shl nsw i32 %.pre, 3
  %sh_prom = zext i32 %mul to i512
  %shr = lshr i512 %3, %sh_prom
  %mul16 = shl nsw i32 %1, 3
  %mul17 = shl nsw i32 %shift.0, 3
  %sub = sub nsw i32 %mul16, %mul17
  %sh_prom18 = zext i32 %sub to i512
  %shl = shl i512 %shr, %sh_prom18
  %4 = load i512, ptr %this, align 8, !tbaa !129
  %sub22 = sub nsw i32 512, %mul16
  %sh_prom23 = zext i32 %sub22 to i512
  %shl24 = shl i512 %4, %sh_prom23
  %add = add nsw i32 %mul17, %sub22
  %sh_prom29 = zext i32 %add to i512
  %shr30 = lshr i512 %shl24, %sh_prom29
  %or = or i512 %shl, %shr30
  br label %if.end32

if.end32:                                         ; preds = %if.end5, %if.else
  %storemerge = phi i512 [ %or, %if.else ], [ %3, %if.end5 ]
  store i512 %storemerge, ptr %this, align 8, !tbaa !129
  %sub34 = sub nsw i32 %1, %shift.0
  %cmp36.not = icmp sgt i32 %sub34, %.pre
  br i1 %cmp36.not, label %if.else50, label %if.then37

if.then37:                                        ; preds = %if.end32
  %add40 = add nsw i32 %sub34, 64
  %sub42 = sub i32 %add40, %.pre
  store i32 %sub42, ptr %input_buf_len, align 8, !tbaa !128
  %5 = load i8, ptr %last, align 4, !tbaa !133, !range !122, !noundef !123
  store i8 %5, ptr %last_buf, align 8, !tbaa !134
  store i32 0, ptr %fifo_empty, align 4, !tbaa !132
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %ref.tmp47) #12
  call void @_Z9get_inputRSt14basic_ifstreamIcSt11char_traitsIcEE(ptr nonnull sret(%struct.payload_t) align 8 %ref.tmp47, ptr noundef nonnull align 8 dereferenceable(256) %infile48)
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 8 dereferenceable(72) %payload13, ptr noundef nonnull align 8 dereferenceable(72) %ref.tmp47, i64 72, i1 false), !tbaa.struct !124
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %ref.tmp47) #12
  %6 = load i32, ptr %flits, align 4, !tbaa !135
  %inc = add i32 %6, 1
  store i32 %inc, ptr %flits, align 4, !tbaa !135
  br label %if.end57

if.else50:                                        ; preds = %if.end32
  %sub52 = sub i32 64, %1
  %add53 = add nsw i32 %sub52, %shift.0
  %add55 = add nsw i32 %add53, %.pre
  store i32 %add55, ptr %fifo_empty, align 4, !tbaa !132
  store i32 64, ptr %input_buf_len, align 8, !tbaa !128
  br label %if.end57

if.end57:                                         ; preds = %if.else50, %if.then37
  %7 = and i8 %res_valid.1, 1
  %tobool3.not = icmp eq i8 %7, 0
  br i1 %tobool3.not, label %while.body, label %while.end, !llvm.loop !138

while.end:                                        ; preds = %if.end57
  ret void
}

; Function Attrs: mustprogress uwtable
define linkonce_odr dso_local void @_ZN10primate_io12Input_headerI8header_tEEviRT_(ptr noundef nonnull align 8 dereferenceable(1224) %this, i32 noundef %length, ptr noundef nonnull align 2 dereferenceable(8) %header) local_unnamed_addr #5 comdat align 2 {
entry:
  %ref.tmp = alloca %struct.payload_t, align 8
  %ref.tmp47 = alloca %struct.payload_t, align 8
  %payload_v = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 7
  %0 = load i8, ptr %payload_v, align 8, !tbaa !108, !range !122, !noundef !123
  %tobool.not = icmp eq i8 %0, 0
  br i1 %tobool.not, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %ref.tmp) #12
  %infile = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 9
  call void @_Z9get_inputRSt14basic_ifstreamIcSt11char_traitsIcEE(ptr nonnull sret(%struct.payload_t) align 8 %ref.tmp, ptr noundef nonnull align 8 dereferenceable(256) %infile)
  %payload = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 6
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 8 dereferenceable(72) %payload, ptr noundef nonnull align 8 dereferenceable(72) %ref.tmp, i64 72, i1 false), !tbaa.struct !124
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %ref.tmp) #12
  store i8 1, ptr %payload_v, align 8, !tbaa !108
  br label %if.end

if.end:                                           ; preds = %if.then, %entry
  %input_buf_len = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 3
  %payload13 = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 6
  %fifo_empty = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 4
  %last = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 6, i32 2
  %last_buf = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 5
  %infile48 = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 9
  %flits = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 2
  br label %while.body

while.body:                                       ; preds = %if.end, %if.end57
  %res_valid.069 = phi i8 [ 0, %if.end ], [ %res_valid.1, %if.end57 ]
  %1 = load i32, ptr %input_buf_len, align 8, !tbaa !128
  %cmp.not = icmp slt i32 %1, %length
  br i1 %cmp.not, label %if.end5, label %if.then4

if.then4:                                         ; preds = %while.body
  %2 = load i512, ptr %this, align 8, !tbaa !129
  %shr.i65 = lshr i512 %2, 16
  %shr4.i66 = lshr i512 %2, 32
  %shr7.i67 = lshr i512 %2, 48
  %3 = insertelement <4 x i512> poison, i512 %2, i64 0
  %4 = insertelement <4 x i512> %3, i512 %shr.i65, i64 1
  %5 = insertelement <4 x i512> %4, i512 %shr4.i66, i64 2
  %6 = insertelement <4 x i512> %5, i512 %shr7.i67, i64 3
  %7 = trunc <4 x i512> %6 to <4 x i16>
  store <4 x i16> %7, ptr %header, align 2, !tbaa !23
  br label %if.end5

if.end5:                                          ; preds = %if.then4, %while.body
  %res_valid.1 = phi i8 [ 1, %if.then4 ], [ %res_valid.069, %while.body ]
  %shift.0 = phi i32 [ %length, %if.then4 ], [ 0, %while.body ]
  %cmp7 = icmp eq i32 %1, 0
  %cmp9 = icmp eq i32 %1, %shift.0
  %or.cond = or i1 %cmp7, %cmp9
  %8 = load i512, ptr %payload13, align 8, !tbaa !131
  %.pre = load i32, ptr %fifo_empty, align 4, !tbaa !132
  br i1 %or.cond, label %if.end32, label %if.else

if.else:                                          ; preds = %if.end5
  %mul = shl nsw i32 %.pre, 3
  %sh_prom = zext i32 %mul to i512
  %shr = lshr i512 %8, %sh_prom
  %mul16 = shl nsw i32 %1, 3
  %mul17 = shl nsw i32 %shift.0, 3
  %sub = sub nsw i32 %mul16, %mul17
  %sh_prom18 = zext i32 %sub to i512
  %shl = shl i512 %shr, %sh_prom18
  %9 = load i512, ptr %this, align 8, !tbaa !129
  %sub22 = sub nsw i32 512, %mul16
  %sh_prom23 = zext i32 %sub22 to i512
  %shl24 = shl i512 %9, %sh_prom23
  %add = add nsw i32 %mul17, %sub22
  %sh_prom29 = zext i32 %add to i512
  %shr30 = lshr i512 %shl24, %sh_prom29
  %or = or i512 %shl, %shr30
  br label %if.end32

if.end32:                                         ; preds = %if.end5, %if.else
  %storemerge = phi i512 [ %or, %if.else ], [ %8, %if.end5 ]
  store i512 %storemerge, ptr %this, align 8, !tbaa !129
  %sub34 = sub nsw i32 %1, %shift.0
  %cmp36.not = icmp sgt i32 %sub34, %.pre
  br i1 %cmp36.not, label %if.else50, label %if.then37

if.then37:                                        ; preds = %if.end32
  %add40 = add nsw i32 %sub34, 64
  %sub42 = sub i32 %add40, %.pre
  store i32 %sub42, ptr %input_buf_len, align 8, !tbaa !128
  %10 = load i8, ptr %last, align 4, !tbaa !133, !range !122, !noundef !123
  store i8 %10, ptr %last_buf, align 8, !tbaa !134
  store i32 0, ptr %fifo_empty, align 4, !tbaa !132
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %ref.tmp47) #12
  call void @_Z9get_inputRSt14basic_ifstreamIcSt11char_traitsIcEE(ptr nonnull sret(%struct.payload_t) align 8 %ref.tmp47, ptr noundef nonnull align 8 dereferenceable(256) %infile48)
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 8 dereferenceable(72) %payload13, ptr noundef nonnull align 8 dereferenceable(72) %ref.tmp47, i64 72, i1 false), !tbaa.struct !124
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %ref.tmp47) #12
  %11 = load i32, ptr %flits, align 4, !tbaa !135
  %inc = add i32 %11, 1
  store i32 %inc, ptr %flits, align 4, !tbaa !135
  br label %if.end57

if.else50:                                        ; preds = %if.end32
  %sub52 = sub i32 64, %1
  %add53 = add nsw i32 %sub52, %shift.0
  %add55 = add nsw i32 %add53, %.pre
  store i32 %add55, ptr %fifo_empty, align 4, !tbaa !132
  store i32 64, ptr %input_buf_len, align 8, !tbaa !128
  br label %if.end57

if.end57:                                         ; preds = %if.else50, %if.then37
  %12 = and i8 %res_valid.1, 1
  %tobool3.not = icmp eq i8 %12, 0
  br i1 %tobool3.not, label %while.body, label %while.end, !llvm.loop !139

while.end:                                        ; preds = %if.end57
  ret void
}

; Function Attrs: mustprogress uwtable
define linkonce_odr dso_local void @_ZN10primate_io12Input_headerI6ipv4_tEEviRT_(ptr noundef nonnull align 8 dereferenceable(1224) %this, i32 noundef %length, ptr noundef nonnull align 8 dereferenceable(40) %header) local_unnamed_addr #5 comdat align 2 {
entry:
  %ref.tmp = alloca %struct.payload_t, align 8
  %ref.tmp47 = alloca %struct.payload_t, align 8
  %payload_v = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 7
  %0 = load i8, ptr %payload_v, align 8, !tbaa !108, !range !122, !noundef !123
  %tobool.not = icmp eq i8 %0, 0
  br i1 %tobool.not, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %ref.tmp) #12
  %infile = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 9
  call void @_Z9get_inputRSt14basic_ifstreamIcSt11char_traitsIcEE(ptr nonnull sret(%struct.payload_t) align 8 %ref.tmp, ptr noundef nonnull align 8 dereferenceable(256) %infile)
  %payload = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 6
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 8 dereferenceable(72) %payload, ptr noundef nonnull align 8 dereferenceable(72) %ref.tmp, i64 72, i1 false), !tbaa.struct !124
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %ref.tmp) #12
  store i8 1, ptr %payload_v, align 8, !tbaa !108
  br label %if.end

if.end:                                           ; preds = %if.then, %entry
  %input_buf_len = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 3
  %protocol.i = getelementptr inbounds %struct.ipv4_t, ptr %header, i64 0, i32 1
  %hdrChecksum_dstAddr.i = getelementptr inbounds %struct.ipv4_t, ptr %header, i64 0, i32 2
  %payload13 = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 6
  %fifo_empty = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 4
  %last = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 6, i32 2
  %last_buf = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 5
  %infile48 = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 9
  %flits = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 2
  br label %while.body

while.body:                                       ; preds = %if.end, %if.end57
  %res_valid.069 = phi i8 [ 0, %if.end ], [ %res_valid.1, %if.end57 ]
  %1 = load i32, ptr %input_buf_len, align 8, !tbaa !128
  %cmp.not = icmp slt i32 %1, %length
  br i1 %cmp.not, label %if.end5, label %if.then4

if.then4:                                         ; preds = %while.body
  %2 = load i512, ptr %this, align 8, !tbaa !129
  %conv.i = trunc i512 %2 to i72
  store i72 %conv.i, ptr %header, align 8, !tbaa !90
  %shr.i66 = lshr i512 %2, 72
  %conv2.i = trunc i512 %shr.i66 to i8
  store i8 %conv2.i, ptr %protocol.i, align 8, !tbaa !19
  %shr3.i67 = lshr i512 %2, 80
  %conv4.i = trunc i512 %shr3.i67 to i80
  store i80 %conv4.i, ptr %hdrChecksum_dstAddr.i, align 8, !tbaa !86
  br label %if.end5

if.end5:                                          ; preds = %if.then4, %while.body
  %res_valid.1 = phi i8 [ 1, %if.then4 ], [ %res_valid.069, %while.body ]
  %shift.0 = phi i32 [ %length, %if.then4 ], [ 0, %while.body ]
  %cmp7 = icmp eq i32 %1, 0
  %cmp9 = icmp eq i32 %1, %shift.0
  %or.cond = or i1 %cmp7, %cmp9
  %3 = load i512, ptr %payload13, align 8, !tbaa !131
  %.pre = load i32, ptr %fifo_empty, align 4, !tbaa !132
  br i1 %or.cond, label %if.end32, label %if.else

if.else:                                          ; preds = %if.end5
  %mul = shl nsw i32 %.pre, 3
  %sh_prom = zext i32 %mul to i512
  %shr = lshr i512 %3, %sh_prom
  %mul16 = shl nsw i32 %1, 3
  %mul17 = shl nsw i32 %shift.0, 3
  %sub = sub nsw i32 %mul16, %mul17
  %sh_prom18 = zext i32 %sub to i512
  %shl = shl i512 %shr, %sh_prom18
  %4 = load i512, ptr %this, align 8, !tbaa !129
  %sub22 = sub nsw i32 512, %mul16
  %sh_prom23 = zext i32 %sub22 to i512
  %shl24 = shl i512 %4, %sh_prom23
  %add = add nsw i32 %mul17, %sub22
  %sh_prom29 = zext i32 %add to i512
  %shr30 = lshr i512 %shl24, %sh_prom29
  %or = or i512 %shl, %shr30
  br label %if.end32

if.end32:                                         ; preds = %if.end5, %if.else
  %storemerge = phi i512 [ %or, %if.else ], [ %3, %if.end5 ]
  store i512 %storemerge, ptr %this, align 8, !tbaa !129
  %sub34 = sub nsw i32 %1, %shift.0
  %cmp36.not = icmp sgt i32 %sub34, %.pre
  br i1 %cmp36.not, label %if.else50, label %if.then37

if.then37:                                        ; preds = %if.end32
  %add40 = add nsw i32 %sub34, 64
  %sub42 = sub i32 %add40, %.pre
  store i32 %sub42, ptr %input_buf_len, align 8, !tbaa !128
  %5 = load i8, ptr %last, align 4, !tbaa !133, !range !122, !noundef !123
  store i8 %5, ptr %last_buf, align 8, !tbaa !134
  store i32 0, ptr %fifo_empty, align 4, !tbaa !132
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %ref.tmp47) #12
  call void @_Z9get_inputRSt14basic_ifstreamIcSt11char_traitsIcEE(ptr nonnull sret(%struct.payload_t) align 8 %ref.tmp47, ptr noundef nonnull align 8 dereferenceable(256) %infile48)
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 8 dereferenceable(72) %payload13, ptr noundef nonnull align 8 dereferenceable(72) %ref.tmp47, i64 72, i1 false), !tbaa.struct !124
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %ref.tmp47) #12
  %6 = load i32, ptr %flits, align 4, !tbaa !135
  %inc = add i32 %6, 1
  store i32 %inc, ptr %flits, align 4, !tbaa !135
  br label %if.end57

if.else50:                                        ; preds = %if.end32
  %sub52 = sub i32 64, %1
  %add53 = add nsw i32 %sub52, %shift.0
  %add55 = add nsw i32 %add53, %.pre
  store i32 %add55, ptr %fifo_empty, align 4, !tbaa !132
  store i32 64, ptr %input_buf_len, align 8, !tbaa !128
  br label %if.end57

if.end57:                                         ; preds = %if.else50, %if.then37
  %7 = and i8 %res_valid.1, 1
  %tobool3.not = icmp eq i8 %7, 0
  br i1 %tobool3.not, label %while.body, label %while.end, !llvm.loop !140

while.end:                                        ; preds = %if.end57
  ret void
}

; Function Attrs: mustprogress uwtable
define linkonce_odr dso_local void @_ZN10primate_io12Input_headerI5tcp_tEEviRT_(ptr noundef nonnull align 8 dereferenceable(1224) %this, i32 noundef %length, ptr noundef nonnull align 8 dereferenceable(24) %header) local_unnamed_addr #5 comdat align 2 {
entry:
  %ref.tmp = alloca %struct.payload_t, align 8
  %ref.tmp47 = alloca %struct.payload_t, align 8
  %payload_v = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 7
  %0 = load i8, ptr %payload_v, align 8, !tbaa !108, !range !122, !noundef !123
  %tobool.not = icmp eq i8 %0, 0
  br i1 %tobool.not, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %ref.tmp) #12
  %infile = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 9
  call void @_Z9get_inputRSt14basic_ifstreamIcSt11char_traitsIcEE(ptr nonnull sret(%struct.payload_t) align 8 %ref.tmp, ptr noundef nonnull align 8 dereferenceable(256) %infile)
  %payload = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 6
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 8 dereferenceable(72) %payload, ptr noundef nonnull align 8 dereferenceable(72) %ref.tmp, i64 72, i1 false), !tbaa.struct !124
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %ref.tmp) #12
  store i8 1, ptr %payload_v, align 8, !tbaa !108
  br label %if.end

if.end:                                           ; preds = %if.then, %entry
  %input_buf_len = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 3
  %payload13 = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 6
  %fifo_empty = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 4
  %last = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 6, i32 2
  %last_buf = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 5
  %infile48 = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 9
  %flits = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 2
  br label %while.body

while.body:                                       ; preds = %if.end, %if.end57
  %res_valid.067 = phi i8 [ 0, %if.end ], [ %res_valid.1, %if.end57 ]
  %1 = load i32, ptr %input_buf_len, align 8, !tbaa !128
  %cmp.not = icmp slt i32 %1, %length
  br i1 %cmp.not, label %if.end5, label %if.then4

if.then4:                                         ; preds = %while.body
  %2 = load i512, ptr %this, align 8, !tbaa !129
  %conv = trunc i512 %2 to i160
  store i160 %conv, ptr %header, align 8, !tbaa !91
  br label %if.end5

if.end5:                                          ; preds = %if.then4, %while.body
  %res_valid.1 = phi i8 [ 1, %if.then4 ], [ %res_valid.067, %while.body ]
  %shift.0 = phi i32 [ %length, %if.then4 ], [ 0, %while.body ]
  %cmp7 = icmp eq i32 %1, 0
  %cmp9 = icmp eq i32 %1, %shift.0
  %or.cond = or i1 %cmp7, %cmp9
  %3 = load i512, ptr %payload13, align 8, !tbaa !131
  %.pre = load i32, ptr %fifo_empty, align 4, !tbaa !132
  br i1 %or.cond, label %if.end32, label %if.else

if.else:                                          ; preds = %if.end5
  %mul = shl nsw i32 %.pre, 3
  %sh_prom = zext i32 %mul to i512
  %shr = lshr i512 %3, %sh_prom
  %mul16 = shl nsw i32 %1, 3
  %mul17 = shl nsw i32 %shift.0, 3
  %sub = sub nsw i32 %mul16, %mul17
  %sh_prom18 = zext i32 %sub to i512
  %shl = shl i512 %shr, %sh_prom18
  %4 = load i512, ptr %this, align 8, !tbaa !129
  %sub22 = sub nsw i32 512, %mul16
  %sh_prom23 = zext i32 %sub22 to i512
  %shl24 = shl i512 %4, %sh_prom23
  %add = add nsw i32 %mul17, %sub22
  %sh_prom29 = zext i32 %add to i512
  %shr30 = lshr i512 %shl24, %sh_prom29
  %or = or i512 %shl, %shr30
  br label %if.end32

if.end32:                                         ; preds = %if.end5, %if.else
  %storemerge = phi i512 [ %or, %if.else ], [ %3, %if.end5 ]
  store i512 %storemerge, ptr %this, align 8, !tbaa !129
  %sub34 = sub nsw i32 %1, %shift.0
  %cmp36.not = icmp sgt i32 %sub34, %.pre
  br i1 %cmp36.not, label %if.else50, label %if.then37

if.then37:                                        ; preds = %if.end32
  %add40 = add nsw i32 %sub34, 64
  %sub42 = sub i32 %add40, %.pre
  store i32 %sub42, ptr %input_buf_len, align 8, !tbaa !128
  %5 = load i8, ptr %last, align 4, !tbaa !133, !range !122, !noundef !123
  store i8 %5, ptr %last_buf, align 8, !tbaa !134
  store i32 0, ptr %fifo_empty, align 4, !tbaa !132
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %ref.tmp47) #12
  call void @_Z9get_inputRSt14basic_ifstreamIcSt11char_traitsIcEE(ptr nonnull sret(%struct.payload_t) align 8 %ref.tmp47, ptr noundef nonnull align 8 dereferenceable(256) %infile48)
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 8 dereferenceable(72) %payload13, ptr noundef nonnull align 8 dereferenceable(72) %ref.tmp47, i64 72, i1 false), !tbaa.struct !124
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %ref.tmp47) #12
  %6 = load i32, ptr %flits, align 4, !tbaa !135
  %inc = add i32 %6, 1
  store i32 %inc, ptr %flits, align 4, !tbaa !135
  br label %if.end57

if.else50:                                        ; preds = %if.end32
  %sub52 = sub i32 64, %1
  %add53 = add nsw i32 %sub52, %shift.0
  %add55 = add nsw i32 %add53, %.pre
  store i32 %add55, ptr %fifo_empty, align 4, !tbaa !132
  store i32 64, ptr %input_buf_len, align 8, !tbaa !128
  br label %if.end57

if.end57:                                         ; preds = %if.else50, %if.then37
  %7 = and i8 %res_valid.1, 1
  %tobool3.not = icmp eq i8 %7, 0
  br i1 %tobool3.not, label %while.body, label %while.end, !llvm.loop !141

while.end:                                        ; preds = %if.end57
  ret void
}

; Function Attrs: mustprogress uwtable
define linkonce_odr dso_local void @_ZN10primate_io12Input_headerI5udp_tEEviRT_(ptr noundef nonnull align 8 dereferenceable(1224) %this, i32 noundef %length, ptr noundef nonnull align 8 dereferenceable(8) %header) local_unnamed_addr #5 comdat align 2 {
entry:
  %ref.tmp = alloca %struct.payload_t, align 8
  %ref.tmp47 = alloca %struct.payload_t, align 8
  %payload_v = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 7
  %0 = load i8, ptr %payload_v, align 8, !tbaa !108, !range !122, !noundef !123
  %tobool.not = icmp eq i8 %0, 0
  br i1 %tobool.not, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %ref.tmp) #12
  %infile = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 9
  call void @_Z9get_inputRSt14basic_ifstreamIcSt11char_traitsIcEE(ptr nonnull sret(%struct.payload_t) align 8 %ref.tmp, ptr noundef nonnull align 8 dereferenceable(256) %infile)
  %payload = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 6
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 8 dereferenceable(72) %payload, ptr noundef nonnull align 8 dereferenceable(72) %ref.tmp, i64 72, i1 false), !tbaa.struct !124
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %ref.tmp) #12
  store i8 1, ptr %payload_v, align 8, !tbaa !108
  br label %if.end

if.end:                                           ; preds = %if.then, %entry
  %input_buf_len = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 3
  %payload13 = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 6
  %fifo_empty = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 4
  %last = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 6, i32 2
  %last_buf = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 5
  %infile48 = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 9
  %flits = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 2
  br label %while.body

while.body:                                       ; preds = %if.end, %if.end57
  %res_valid.066 = phi i8 [ 0, %if.end ], [ %res_valid.1, %if.end57 ]
  %1 = load i32, ptr %input_buf_len, align 8, !tbaa !128
  %cmp.not = icmp slt i32 %1, %length
  br i1 %cmp.not, label %if.end5, label %if.then4

if.then4:                                         ; preds = %while.body
  %2 = load i512, ptr %this, align 8, !tbaa !129
  %conv = trunc i512 %2 to i64
  store i64 %conv, ptr %header, align 8, !tbaa !97
  br label %if.end5

if.end5:                                          ; preds = %if.then4, %while.body
  %res_valid.1 = phi i8 [ 1, %if.then4 ], [ %res_valid.066, %while.body ]
  %shift.0 = phi i32 [ %length, %if.then4 ], [ 0, %while.body ]
  %cmp7 = icmp eq i32 %1, 0
  %cmp9 = icmp eq i32 %1, %shift.0
  %or.cond = or i1 %cmp7, %cmp9
  %3 = load i512, ptr %payload13, align 8, !tbaa !131
  %.pre = load i32, ptr %fifo_empty, align 4, !tbaa !132
  br i1 %or.cond, label %if.end32, label %if.else

if.else:                                          ; preds = %if.end5
  %mul = shl nsw i32 %.pre, 3
  %sh_prom = zext i32 %mul to i512
  %shr = lshr i512 %3, %sh_prom
  %mul16 = shl nsw i32 %1, 3
  %mul17 = shl nsw i32 %shift.0, 3
  %sub = sub nsw i32 %mul16, %mul17
  %sh_prom18 = zext i32 %sub to i512
  %shl = shl i512 %shr, %sh_prom18
  %4 = load i512, ptr %this, align 8, !tbaa !129
  %sub22 = sub nsw i32 512, %mul16
  %sh_prom23 = zext i32 %sub22 to i512
  %shl24 = shl i512 %4, %sh_prom23
  %add = add nsw i32 %mul17, %sub22
  %sh_prom29 = zext i32 %add to i512
  %shr30 = lshr i512 %shl24, %sh_prom29
  %or = or i512 %shl, %shr30
  br label %if.end32

if.end32:                                         ; preds = %if.end5, %if.else
  %storemerge = phi i512 [ %or, %if.else ], [ %3, %if.end5 ]
  store i512 %storemerge, ptr %this, align 8, !tbaa !129
  %sub34 = sub nsw i32 %1, %shift.0
  %cmp36.not = icmp sgt i32 %sub34, %.pre
  br i1 %cmp36.not, label %if.else50, label %if.then37

if.then37:                                        ; preds = %if.end32
  %add40 = add nsw i32 %sub34, 64
  %sub42 = sub i32 %add40, %.pre
  store i32 %sub42, ptr %input_buf_len, align 8, !tbaa !128
  %5 = load i8, ptr %last, align 4, !tbaa !133, !range !122, !noundef !123
  store i8 %5, ptr %last_buf, align 8, !tbaa !134
  store i32 0, ptr %fifo_empty, align 4, !tbaa !132
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %ref.tmp47) #12
  call void @_Z9get_inputRSt14basic_ifstreamIcSt11char_traitsIcEE(ptr nonnull sret(%struct.payload_t) align 8 %ref.tmp47, ptr noundef nonnull align 8 dereferenceable(256) %infile48)
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 8 dereferenceable(72) %payload13, ptr noundef nonnull align 8 dereferenceable(72) %ref.tmp47, i64 72, i1 false), !tbaa.struct !124
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %ref.tmp47) #12
  %6 = load i32, ptr %flits, align 4, !tbaa !135
  %inc = add i32 %6, 1
  store i32 %inc, ptr %flits, align 4, !tbaa !135
  br label %if.end57

if.else50:                                        ; preds = %if.end32
  %sub52 = sub i32 64, %1
  %add53 = add nsw i32 %sub52, %shift.0
  %add55 = add nsw i32 %add53, %.pre
  store i32 %add55, ptr %fifo_empty, align 4, !tbaa !132
  store i32 64, ptr %input_buf_len, align 8, !tbaa !128
  br label %if.end57

if.end57:                                         ; preds = %if.else50, %if.then37
  %7 = and i8 %res_valid.1, 1
  %tobool3.not = icmp eq i8 %7, 0
  br i1 %tobool3.not, label %while.body, label %while.end, !llvm.loop !142

while.end:                                        ; preds = %if.end57
  ret void
}

; Function Attrs: uwtable
define linkonce_odr dso_local void @_ZN10primate_io10Input_doneEv(ptr noundef nonnull align 8 dereferenceable(1224) %this) local_unnamed_addr #3 comdat align 2 personality ptr @__gxx_personality_v0 {
entry:
  %ref.tmp = alloca %struct.payload_t, align 8
  %fifo_empty = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 4
  %0 = load i32, ptr %fifo_empty, align 4, !tbaa !132
  %cmp.not = icmp eq i32 %0, 0
  br i1 %cmp.not, label %if.end21, label %if.then

if.then:                                          ; preds = %entry
  %1 = load i512, ptr %this, align 8, !tbaa !129
  %input_buf_len = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 3
  %2 = load i32, ptr %input_buf_len, align 8, !tbaa !128
  %sub = sub nsw i32 64, %2
  %add = add nsw i32 %sub, %0
  %last_buf = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 5
  %3 = load i8, ptr %last_buf, align 8, !tbaa !134, !range !122, !noundef !123
  %pkt_buf = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 8
  %_M_finish.i = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 8, i32 0, i32 0, i32 0, i32 1
  %4 = load ptr, ptr %_M_finish.i, align 8, !tbaa !105
  %_M_end_of_storage.i = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 8, i32 0, i32 0, i32 0, i32 2
  %5 = load ptr, ptr %_M_end_of_storage.i, align 8, !tbaa !143
  %cmp.not.i = icmp eq ptr %4, %5
  br i1 %cmp.not.i, label %if.else.i, label %if.then.i

if.then.i:                                        ; preds = %if.then
  store i512 %1, ptr %4, align 8, !tbaa.struct !124
  %pl.sroa.5.0..sroa_idx = getelementptr inbounds i8, ptr %4, i64 64
  store i32 %add, ptr %pl.sroa.5.0..sroa_idx, align 8, !tbaa.struct !144
  %pl.sroa.6.0..sroa_idx = getelementptr inbounds i8, ptr %4, i64 68
  store i8 %3, ptr %pl.sroa.6.0..sroa_idx, align 4, !tbaa.struct !145
  %6 = load ptr, ptr %_M_finish.i, align 8, !tbaa !105
  %incdec.ptr.i = getelementptr inbounds %struct.payload_t, ptr %6, i64 1
  store ptr %incdec.ptr.i, ptr %_M_finish.i, align 8, !tbaa !105
  br label %_ZNSt6vectorI9payload_tSaIS0_EE9push_backERKS0_.exit

if.else.i:                                        ; preds = %if.then
  %7 = load ptr, ptr %pkt_buf, align 8, !tbaa !103
  %sub.ptr.lhs.cast.i.i.i.i = ptrtoint ptr %4 to i64
  %sub.ptr.rhs.cast.i.i.i.i = ptrtoint ptr %7 to i64
  %sub.ptr.sub.i.i.i.i = sub i64 %sub.ptr.lhs.cast.i.i.i.i, %sub.ptr.rhs.cast.i.i.i.i
  %cmp.i.i.i = icmp eq i64 %sub.ptr.sub.i.i.i.i, 9223372036854775800
  br i1 %cmp.i.i.i, label %if.then.i.i.i, label %_ZNKSt6vectorI9payload_tSaIS0_EE12_M_check_lenEmPKc.exit.i.i

if.then.i.i.i:                                    ; preds = %if.else.i
  tail call void @_ZSt20__throw_length_errorPKc(ptr noundef nonnull @.str) #13
  unreachable

_ZNKSt6vectorI9payload_tSaIS0_EE12_M_check_lenEmPKc.exit.i.i: ; preds = %if.else.i
  %sub.ptr.div.i.i.i.i = sdiv exact i64 %sub.ptr.sub.i.i.i.i, 72
  %.sroa.speculated.i.i.i = tail call i64 @llvm.umax.i64(i64 %sub.ptr.div.i.i.i.i, i64 1)
  %add.i.i.i = add i64 %.sroa.speculated.i.i.i, %sub.ptr.div.i.i.i.i
  %cmp7.i.i.i = icmp ult i64 %add.i.i.i, %sub.ptr.div.i.i.i.i
  %cmp9.i.i.i = icmp ugt i64 %add.i.i.i, 128102389400760775
  %or.cond.i.i.i = or i1 %cmp7.i.i.i, %cmp9.i.i.i
  %cond.i.i.i = select i1 %or.cond.i.i.i, i64 128102389400760775, i64 %add.i.i.i
  %cmp.not.i.i.i = icmp eq i64 %cond.i.i.i, 0
  br i1 %cmp.not.i.i.i, label %_ZNSt12_Vector_baseI9payload_tSaIS0_EE11_M_allocateEm.exit.i.i, label %_ZNSt16allocator_traitsISaI9payload_tEE8allocateERS1_m.exit.i.i.i

_ZNSt16allocator_traitsISaI9payload_tEE8allocateERS1_m.exit.i.i.i: ; preds = %_ZNKSt6vectorI9payload_tSaIS0_EE12_M_check_lenEmPKc.exit.i.i
  %mul.i.i.i.i.i = mul nuw nsw i64 %cond.i.i.i, 72
  %call5.i.i.i.i.i = tail call noalias noundef nonnull ptr @_Znwm(i64 noundef %mul.i.i.i.i.i) #14
  br label %_ZNSt12_Vector_baseI9payload_tSaIS0_EE11_M_allocateEm.exit.i.i

_ZNSt12_Vector_baseI9payload_tSaIS0_EE11_M_allocateEm.exit.i.i: ; preds = %_ZNSt16allocator_traitsISaI9payload_tEE8allocateERS1_m.exit.i.i.i, %_ZNKSt6vectorI9payload_tSaIS0_EE12_M_check_lenEmPKc.exit.i.i
  %cond.i31.i.i = phi ptr [ %call5.i.i.i.i.i, %_ZNSt16allocator_traitsISaI9payload_tEE8allocateERS1_m.exit.i.i.i ], [ null, %_ZNKSt6vectorI9payload_tSaIS0_EE12_M_check_lenEmPKc.exit.i.i ]
  %add.ptr.i.i = getelementptr inbounds %struct.payload_t, ptr %cond.i31.i.i, i64 %sub.ptr.div.i.i.i.i
  store i512 %1, ptr %add.ptr.i.i, align 8, !tbaa.struct !124
  %pl.sroa.5.0.add.ptr.i.i.sroa_idx = getelementptr inbounds i8, ptr %add.ptr.i.i, i64 64
  store i32 %add, ptr %pl.sroa.5.0.add.ptr.i.i.sroa_idx, align 8, !tbaa.struct !144
  %pl.sroa.6.0.add.ptr.i.i.sroa_idx = getelementptr inbounds i8, ptr %add.ptr.i.i, i64 68
  store i8 %3, ptr %pl.sroa.6.0.add.ptr.i.i.sroa_idx, align 4, !tbaa.struct !145
  %cmp.i.i.i32.i.i = icmp sgt i64 %sub.ptr.sub.i.i.i.i, 0
  br i1 %cmp.i.i.i32.i.i, label %if.then.i.i.i33.i.i, label %_ZNSt6vectorI9payload_tSaIS0_EE11_S_relocateEPS0_S3_S3_RS1_.exit41.i.i

if.then.i.i.i33.i.i:                              ; preds = %_ZNSt12_Vector_baseI9payload_tSaIS0_EE11_M_allocateEm.exit.i.i
  tail call void @llvm.memmove.p0.p0.i64(ptr nonnull align 8 %cond.i31.i.i, ptr align 8 %7, i64 %sub.ptr.sub.i.i.i.i, i1 false)
  br label %_ZNSt6vectorI9payload_tSaIS0_EE11_S_relocateEPS0_S3_S3_RS1_.exit41.i.i

_ZNSt6vectorI9payload_tSaIS0_EE11_S_relocateEPS0_S3_S3_RS1_.exit41.i.i: ; preds = %if.then.i.i.i33.i.i, %_ZNSt12_Vector_baseI9payload_tSaIS0_EE11_M_allocateEm.exit.i.i
  %incdec.ptr.i.i = getelementptr inbounds %struct.payload_t, ptr %add.ptr.i.i, i64 1
  %tobool.not.i.i.i = icmp eq ptr %7, null
  br i1 %tobool.not.i.i.i, label %_ZNSt6vectorI9payload_tSaIS0_EE17_M_realloc_insertIJRKS0_EEEvN9__gnu_cxx17__normal_iteratorIPS0_S2_EEDpOT_.exit.i, label %if.then.i42.i.i

if.then.i42.i.i:                                  ; preds = %_ZNSt6vectorI9payload_tSaIS0_EE11_S_relocateEPS0_S3_S3_RS1_.exit41.i.i
  tail call void @_ZdlPv(ptr noundef nonnull %7) #15
  br label %_ZNSt6vectorI9payload_tSaIS0_EE17_M_realloc_insertIJRKS0_EEEvN9__gnu_cxx17__normal_iteratorIPS0_S2_EEDpOT_.exit.i

_ZNSt6vectorI9payload_tSaIS0_EE17_M_realloc_insertIJRKS0_EEEvN9__gnu_cxx17__normal_iteratorIPS0_S2_EEDpOT_.exit.i: ; preds = %if.then.i42.i.i, %_ZNSt6vectorI9payload_tSaIS0_EE11_S_relocateEPS0_S3_S3_RS1_.exit41.i.i
  store ptr %cond.i31.i.i, ptr %pkt_buf, align 8, !tbaa !103
  store ptr %incdec.ptr.i.i, ptr %_M_finish.i, align 8, !tbaa !105
  %add.ptr19.i.i = getelementptr inbounds %struct.payload_t, ptr %cond.i31.i.i, i64 %cond.i.i.i
  store ptr %add.ptr19.i.i, ptr %_M_end_of_storage.i, align 8, !tbaa !143
  br label %_ZNSt6vectorI9payload_tSaIS0_EE9push_backERKS0_.exit

_ZNSt6vectorI9payload_tSaIS0_EE9push_backERKS0_.exit: ; preds = %if.then.i, %_ZNSt6vectorI9payload_tSaIS0_EE17_M_realloc_insertIJRKS0_EEEvN9__gnu_cxx17__normal_iteratorIPS0_S2_EEDpOT_.exit.i
  %8 = phi ptr [ %incdec.ptr.i, %if.then.i ], [ %incdec.ptr.i.i, %_ZNSt6vectorI9payload_tSaIS0_EE17_M_realloc_insertIJRKS0_EEEvN9__gnu_cxx17__normal_iteratorIPS0_S2_EEDpOT_.exit.i ]
  store i32 0, ptr %input_buf_len, align 8, !tbaa !128
  store i32 0, ptr %fifo_empty, align 4, !tbaa !132
  %9 = load i8, ptr %last_buf, align 8, !tbaa !134, !range !122, !noundef !123
  %tobool6.not = icmp eq i8 %9, 0
  br i1 %tobool6.not, label %if.then7, label %if.end21

if.then7:                                         ; preds = %_ZNSt6vectorI9payload_tSaIS0_EE9push_backERKS0_.exit
  %payload = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 6
  %10 = load ptr, ptr %_M_end_of_storage.i, align 8, !tbaa !143
  %cmp.not.i24 = icmp eq ptr %8, %10
  br i1 %cmp.not.i24, label %if.else.i31, label %if.then.i26

if.then.i26:                                      ; preds = %if.then7
  tail call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 8 dereferenceable(72) %8, ptr noundef nonnull align 8 dereferenceable(72) %payload, i64 72, i1 false), !tbaa.struct !124
  %11 = load ptr, ptr %_M_finish.i, align 8, !tbaa !105
  %incdec.ptr.i25 = getelementptr inbounds %struct.payload_t, ptr %11, i64 1
  store ptr %incdec.ptr.i25, ptr %_M_finish.i, align 8, !tbaa !105
  br label %_ZNSt6vectorI9payload_tSaIS0_EE9push_backERKS0_.exit56

if.else.i31:                                      ; preds = %if.then7
  %12 = load ptr, ptr %pkt_buf, align 8, !tbaa !103
  %sub.ptr.lhs.cast.i.i.i.i27 = ptrtoint ptr %8 to i64
  %sub.ptr.rhs.cast.i.i.i.i28 = ptrtoint ptr %12 to i64
  %sub.ptr.sub.i.i.i.i29 = sub i64 %sub.ptr.lhs.cast.i.i.i.i27, %sub.ptr.rhs.cast.i.i.i.i28
  %cmp.i.i.i30 = icmp eq i64 %sub.ptr.sub.i.i.i.i29, 9223372036854775800
  br i1 %cmp.i.i.i30, label %if.then.i.i.i32, label %_ZNKSt6vectorI9payload_tSaIS0_EE12_M_check_lenEmPKc.exit.i.i41

if.then.i.i.i32:                                  ; preds = %if.else.i31
  tail call void @_ZSt20__throw_length_errorPKc(ptr noundef nonnull @.str) #13
  unreachable

_ZNKSt6vectorI9payload_tSaIS0_EE12_M_check_lenEmPKc.exit.i.i41: ; preds = %if.else.i31
  %sub.ptr.div.i.i.i.i33 = sdiv exact i64 %sub.ptr.sub.i.i.i.i29, 72
  %.sroa.speculated.i.i.i34 = tail call i64 @llvm.umax.i64(i64 %sub.ptr.div.i.i.i.i33, i64 1)
  %add.i.i.i35 = add i64 %.sroa.speculated.i.i.i34, %sub.ptr.div.i.i.i.i33
  %cmp7.i.i.i36 = icmp ult i64 %add.i.i.i35, %sub.ptr.div.i.i.i.i33
  %cmp9.i.i.i37 = icmp ugt i64 %add.i.i.i35, 128102389400760775
  %or.cond.i.i.i38 = or i1 %cmp7.i.i.i36, %cmp9.i.i.i37
  %cond.i.i.i39 = select i1 %or.cond.i.i.i38, i64 128102389400760775, i64 %add.i.i.i35
  %cmp.not.i.i.i40 = icmp eq i64 %cond.i.i.i39, 0
  br i1 %cmp.not.i.i.i40, label %_ZNSt12_Vector_baseI9payload_tSaIS0_EE11_M_allocateEm.exit.i.i48, label %_ZNSt16allocator_traitsISaI9payload_tEE8allocateERS1_m.exit.i.i.i44

_ZNSt16allocator_traitsISaI9payload_tEE8allocateERS1_m.exit.i.i.i44: ; preds = %_ZNKSt6vectorI9payload_tSaIS0_EE12_M_check_lenEmPKc.exit.i.i41
  %mul.i.i.i.i.i42 = mul nuw nsw i64 %cond.i.i.i39, 72
  %call5.i.i.i.i.i43 = tail call noalias noundef nonnull ptr @_Znwm(i64 noundef %mul.i.i.i.i.i42) #14
  br label %_ZNSt12_Vector_baseI9payload_tSaIS0_EE11_M_allocateEm.exit.i.i48

_ZNSt12_Vector_baseI9payload_tSaIS0_EE11_M_allocateEm.exit.i.i48: ; preds = %_ZNSt16allocator_traitsISaI9payload_tEE8allocateERS1_m.exit.i.i.i44, %_ZNKSt6vectorI9payload_tSaIS0_EE12_M_check_lenEmPKc.exit.i.i41
  %cond.i31.i.i45 = phi ptr [ %call5.i.i.i.i.i43, %_ZNSt16allocator_traitsISaI9payload_tEE8allocateERS1_m.exit.i.i.i44 ], [ null, %_ZNKSt6vectorI9payload_tSaIS0_EE12_M_check_lenEmPKc.exit.i.i41 ]
  %add.ptr.i.i46 = getelementptr inbounds %struct.payload_t, ptr %cond.i31.i.i45, i64 %sub.ptr.div.i.i.i.i33
  tail call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 8 dereferenceable(72) %add.ptr.i.i46, ptr noundef nonnull align 8 dereferenceable(72) %payload, i64 72, i1 false), !tbaa.struct !124
  %cmp.i.i.i32.i.i47 = icmp sgt i64 %sub.ptr.sub.i.i.i.i29, 0
  br i1 %cmp.i.i.i32.i.i47, label %if.then.i.i.i33.i.i49, label %_ZNSt6vectorI9payload_tSaIS0_EE11_S_relocateEPS0_S3_S3_RS1_.exit41.i.i52

if.then.i.i.i33.i.i49:                            ; preds = %_ZNSt12_Vector_baseI9payload_tSaIS0_EE11_M_allocateEm.exit.i.i48
  tail call void @llvm.memmove.p0.p0.i64(ptr nonnull align 8 %cond.i31.i.i45, ptr align 8 %12, i64 %sub.ptr.sub.i.i.i.i29, i1 false)
  br label %_ZNSt6vectorI9payload_tSaIS0_EE11_S_relocateEPS0_S3_S3_RS1_.exit41.i.i52

_ZNSt6vectorI9payload_tSaIS0_EE11_S_relocateEPS0_S3_S3_RS1_.exit41.i.i52: ; preds = %if.then.i.i.i33.i.i49, %_ZNSt12_Vector_baseI9payload_tSaIS0_EE11_M_allocateEm.exit.i.i48
  %incdec.ptr.i.i50 = getelementptr inbounds %struct.payload_t, ptr %add.ptr.i.i46, i64 1
  %tobool.not.i.i.i51 = icmp eq ptr %12, null
  br i1 %tobool.not.i.i.i51, label %_ZNSt6vectorI9payload_tSaIS0_EE17_M_realloc_insertIJRKS0_EEEvN9__gnu_cxx17__normal_iteratorIPS0_S2_EEDpOT_.exit.i55, label %if.then.i42.i.i53

if.then.i42.i.i53:                                ; preds = %_ZNSt6vectorI9payload_tSaIS0_EE11_S_relocateEPS0_S3_S3_RS1_.exit41.i.i52
  tail call void @_ZdlPv(ptr noundef nonnull %12) #15
  br label %_ZNSt6vectorI9payload_tSaIS0_EE17_M_realloc_insertIJRKS0_EEEvN9__gnu_cxx17__normal_iteratorIPS0_S2_EEDpOT_.exit.i55

_ZNSt6vectorI9payload_tSaIS0_EE17_M_realloc_insertIJRKS0_EEEvN9__gnu_cxx17__normal_iteratorIPS0_S2_EEDpOT_.exit.i55: ; preds = %if.then.i42.i.i53, %_ZNSt6vectorI9payload_tSaIS0_EE11_S_relocateEPS0_S3_S3_RS1_.exit41.i.i52
  store ptr %cond.i31.i.i45, ptr %pkt_buf, align 8, !tbaa !103
  store ptr %incdec.ptr.i.i50, ptr %_M_finish.i, align 8, !tbaa !105
  %add.ptr19.i.i54 = getelementptr inbounds %struct.payload_t, ptr %cond.i31.i.i45, i64 %cond.i.i.i39
  store ptr %add.ptr19.i.i54, ptr %_M_end_of_storage.i, align 8, !tbaa !143
  br label %_ZNSt6vectorI9payload_tSaIS0_EE9push_backERKS0_.exit56

_ZNSt6vectorI9payload_tSaIS0_EE9push_backERKS0_.exit56: ; preds = %if.then.i26, %_ZNSt6vectorI9payload_tSaIS0_EE17_M_realloc_insertIJRKS0_EEEvN9__gnu_cxx17__normal_iteratorIPS0_S2_EEDpOT_.exit.i55
  %payload_v = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 7
  store i8 0, ptr %payload_v, align 8, !tbaa !108
  %last10 = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 6, i32 2
  %13 = load i8, ptr %last10, align 4, !tbaa !133, !range !122, !noundef !123
  %is_last.0.not95 = icmp eq i8 %13, 0
  br i1 %is_last.0.not95, label %while.body.lr.ph, label %if.end21

while.body.lr.ph:                                 ; preds = %_ZNSt6vectorI9payload_tSaIS0_EE9push_backERKS0_.exit56
  %infile = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 9
  br label %while.body

while.body:                                       ; preds = %while.body.lr.ph, %_ZNSt6vectorI9payload_tSaIS0_EE9push_backERKS0_.exit91
  call void @llvm.lifetime.start.p0(i64 72, ptr nonnull %ref.tmp) #12
  call void @_Z9get_inputRSt14basic_ifstreamIcSt11char_traitsIcEE(ptr nonnull sret(%struct.payload_t) align 8 %ref.tmp, ptr noundef nonnull align 8 dereferenceable(256) %infile)
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 8 dereferenceable(72) %payload, ptr noundef nonnull align 8 dereferenceable(72) %ref.tmp, i64 72, i1 false), !tbaa.struct !124
  call void @llvm.lifetime.end.p0(i64 72, ptr nonnull %ref.tmp) #12
  %14 = load i8, ptr %last10, align 4, !tbaa !133, !range !122, !noundef !123
  %15 = load ptr, ptr %_M_finish.i, align 8, !tbaa !105
  %16 = load ptr, ptr %_M_end_of_storage.i, align 8, !tbaa !143
  %cmp.not.i59 = icmp eq ptr %15, %16
  br i1 %cmp.not.i59, label %if.else.i66, label %if.then.i61

if.then.i61:                                      ; preds = %while.body
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 8 dereferenceable(72) %15, ptr noundef nonnull align 8 dereferenceable(72) %payload, i64 72, i1 false), !tbaa.struct !124
  %17 = load ptr, ptr %_M_finish.i, align 8, !tbaa !105
  %incdec.ptr.i60 = getelementptr inbounds %struct.payload_t, ptr %17, i64 1
  store ptr %incdec.ptr.i60, ptr %_M_finish.i, align 8, !tbaa !105
  br label %_ZNSt6vectorI9payload_tSaIS0_EE9push_backERKS0_.exit91

if.else.i66:                                      ; preds = %while.body
  %18 = load ptr, ptr %pkt_buf, align 8, !tbaa !103
  %sub.ptr.lhs.cast.i.i.i.i62 = ptrtoint ptr %15 to i64
  %sub.ptr.rhs.cast.i.i.i.i63 = ptrtoint ptr %18 to i64
  %sub.ptr.sub.i.i.i.i64 = sub i64 %sub.ptr.lhs.cast.i.i.i.i62, %sub.ptr.rhs.cast.i.i.i.i63
  %cmp.i.i.i65 = icmp eq i64 %sub.ptr.sub.i.i.i.i64, 9223372036854775800
  br i1 %cmp.i.i.i65, label %if.then.i.i.i67, label %_ZNKSt6vectorI9payload_tSaIS0_EE12_M_check_lenEmPKc.exit.i.i76

if.then.i.i.i67:                                  ; preds = %if.else.i66
  call void @_ZSt20__throw_length_errorPKc(ptr noundef nonnull @.str) #13
  unreachable

_ZNKSt6vectorI9payload_tSaIS0_EE12_M_check_lenEmPKc.exit.i.i76: ; preds = %if.else.i66
  %sub.ptr.div.i.i.i.i68 = sdiv exact i64 %sub.ptr.sub.i.i.i.i64, 72
  %.sroa.speculated.i.i.i69 = call i64 @llvm.umax.i64(i64 %sub.ptr.div.i.i.i.i68, i64 1)
  %add.i.i.i70 = add i64 %.sroa.speculated.i.i.i69, %sub.ptr.div.i.i.i.i68
  %cmp7.i.i.i71 = icmp ult i64 %add.i.i.i70, %sub.ptr.div.i.i.i.i68
  %cmp9.i.i.i72 = icmp ugt i64 %add.i.i.i70, 128102389400760775
  %or.cond.i.i.i73 = or i1 %cmp7.i.i.i71, %cmp9.i.i.i72
  %cond.i.i.i74 = select i1 %or.cond.i.i.i73, i64 128102389400760775, i64 %add.i.i.i70
  %cmp.not.i.i.i75 = icmp eq i64 %cond.i.i.i74, 0
  br i1 %cmp.not.i.i.i75, label %_ZNSt12_Vector_baseI9payload_tSaIS0_EE11_M_allocateEm.exit.i.i83, label %_ZNSt16allocator_traitsISaI9payload_tEE8allocateERS1_m.exit.i.i.i79

_ZNSt16allocator_traitsISaI9payload_tEE8allocateERS1_m.exit.i.i.i79: ; preds = %_ZNKSt6vectorI9payload_tSaIS0_EE12_M_check_lenEmPKc.exit.i.i76
  %mul.i.i.i.i.i77 = mul nuw nsw i64 %cond.i.i.i74, 72
  %call5.i.i.i.i.i78 = call noalias noundef nonnull ptr @_Znwm(i64 noundef %mul.i.i.i.i.i77) #14
  br label %_ZNSt12_Vector_baseI9payload_tSaIS0_EE11_M_allocateEm.exit.i.i83

_ZNSt12_Vector_baseI9payload_tSaIS0_EE11_M_allocateEm.exit.i.i83: ; preds = %_ZNSt16allocator_traitsISaI9payload_tEE8allocateERS1_m.exit.i.i.i79, %_ZNKSt6vectorI9payload_tSaIS0_EE12_M_check_lenEmPKc.exit.i.i76
  %cond.i31.i.i80 = phi ptr [ %call5.i.i.i.i.i78, %_ZNSt16allocator_traitsISaI9payload_tEE8allocateERS1_m.exit.i.i.i79 ], [ null, %_ZNKSt6vectorI9payload_tSaIS0_EE12_M_check_lenEmPKc.exit.i.i76 ]
  %add.ptr.i.i81 = getelementptr inbounds %struct.payload_t, ptr %cond.i31.i.i80, i64 %sub.ptr.div.i.i.i.i68
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 8 dereferenceable(72) %add.ptr.i.i81, ptr noundef nonnull align 8 dereferenceable(72) %payload, i64 72, i1 false), !tbaa.struct !124
  %cmp.i.i.i32.i.i82 = icmp sgt i64 %sub.ptr.sub.i.i.i.i64, 0
  br i1 %cmp.i.i.i32.i.i82, label %if.then.i.i.i33.i.i84, label %_ZNSt6vectorI9payload_tSaIS0_EE11_S_relocateEPS0_S3_S3_RS1_.exit41.i.i87

if.then.i.i.i33.i.i84:                            ; preds = %_ZNSt12_Vector_baseI9payload_tSaIS0_EE11_M_allocateEm.exit.i.i83
  call void @llvm.memmove.p0.p0.i64(ptr nonnull align 8 %cond.i31.i.i80, ptr align 8 %18, i64 %sub.ptr.sub.i.i.i.i64, i1 false)
  br label %_ZNSt6vectorI9payload_tSaIS0_EE11_S_relocateEPS0_S3_S3_RS1_.exit41.i.i87

_ZNSt6vectorI9payload_tSaIS0_EE11_S_relocateEPS0_S3_S3_RS1_.exit41.i.i87: ; preds = %if.then.i.i.i33.i.i84, %_ZNSt12_Vector_baseI9payload_tSaIS0_EE11_M_allocateEm.exit.i.i83
  %incdec.ptr.i.i85 = getelementptr inbounds %struct.payload_t, ptr %add.ptr.i.i81, i64 1
  %tobool.not.i.i.i86 = icmp eq ptr %18, null
  br i1 %tobool.not.i.i.i86, label %_ZNSt6vectorI9payload_tSaIS0_EE17_M_realloc_insertIJRKS0_EEEvN9__gnu_cxx17__normal_iteratorIPS0_S2_EEDpOT_.exit.i90, label %if.then.i42.i.i88

if.then.i42.i.i88:                                ; preds = %_ZNSt6vectorI9payload_tSaIS0_EE11_S_relocateEPS0_S3_S3_RS1_.exit41.i.i87
  call void @_ZdlPv(ptr noundef nonnull %18) #15
  br label %_ZNSt6vectorI9payload_tSaIS0_EE17_M_realloc_insertIJRKS0_EEEvN9__gnu_cxx17__normal_iteratorIPS0_S2_EEDpOT_.exit.i90

_ZNSt6vectorI9payload_tSaIS0_EE17_M_realloc_insertIJRKS0_EEEvN9__gnu_cxx17__normal_iteratorIPS0_S2_EEDpOT_.exit.i90: ; preds = %if.then.i42.i.i88, %_ZNSt6vectorI9payload_tSaIS0_EE11_S_relocateEPS0_S3_S3_RS1_.exit41.i.i87
  store ptr %cond.i31.i.i80, ptr %pkt_buf, align 8, !tbaa !103
  store ptr %incdec.ptr.i.i85, ptr %_M_finish.i, align 8, !tbaa !105
  %add.ptr19.i.i89 = getelementptr inbounds %struct.payload_t, ptr %cond.i31.i.i80, i64 %cond.i.i.i74
  store ptr %add.ptr19.i.i89, ptr %_M_end_of_storage.i, align 8, !tbaa !143
  br label %_ZNSt6vectorI9payload_tSaIS0_EE9push_backERKS0_.exit91

_ZNSt6vectorI9payload_tSaIS0_EE9push_backERKS0_.exit91: ; preds = %if.then.i61, %_ZNSt6vectorI9payload_tSaIS0_EE17_M_realloc_insertIJRKS0_EEEvN9__gnu_cxx17__normal_iteratorIPS0_S2_EEDpOT_.exit.i90
  %is_last.0.not = icmp eq i8 %14, 0
  br i1 %is_last.0.not, label %while.body, label %if.end21, !llvm.loop !146

if.end21:                                         ; preds = %_ZNSt6vectorI9payload_tSaIS0_EE9push_backERKS0_.exit91, %_ZNSt6vectorI9payload_tSaIS0_EE9push_backERKS0_.exit, %_ZNSt6vectorI9payload_tSaIS0_EE9push_backERKS0_.exit56, %entry
  %flits = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 2
  store i32 0, ptr %flits, align 4, !tbaa !135
  %pktID = getelementptr inbounds %class.primate_io, ptr %this, i64 0, i32 1
  %19 = load i32, ptr %pktID, align 8, !tbaa !147
  %inc = add i32 %19, 1
  store i32 %inc, ptr %pktID, align 8, !tbaa !147
  ret void
}

declare noundef i32 @_Z13forward_exactRDU48_Rt(ptr noundef nonnull align 8 dereferenceable(8), ptr noundef nonnull align 2 dereferenceable(2)) local_unnamed_addr #0

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(i64 immarg, ptr nocapture) #4

declare void @_Z9get_inputRSt14basic_ifstreamIcSt11char_traitsIcEE(ptr sret(%struct.payload_t) align 8, ptr noundef nonnull align 8 dereferenceable(256)) local_unnamed_addr #0

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias nocapture writeonly, ptr noalias nocapture readonly, i64, i1 immarg) #6

; Function Attrs: noreturn
declare void @_ZSt20__throw_length_errorPKc(ptr noundef) local_unnamed_addr #7

declare i32 @__gxx_personality_v0(...)

; Function Attrs: nobuiltin allocsize(0)
declare noundef nonnull ptr @_Znwm(i64 noundef) local_unnamed_addr #8

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memmove.p0.p0.i64(ptr nocapture writeonly, ptr nocapture readonly, i64, i1 immarg) #6

; Function Attrs: nobuiltin nounwind
declare void @_ZdlPv(ptr noundef) local_unnamed_addr #9

; Function Attrs: inlinehint mustprogress uwtable
define linkonce_odr dso_local noundef nonnull align 8 dereferenceable(8) ptr @_ZlsRSoRK9payload_t(ptr noundef nonnull align 8 dereferenceable(8) %os, ptr noundef nonnull align 8 dereferenceable(72) %val) local_unnamed_addr #10 comdat {
entry:
  %0 = load i512, ptr %val, align 8, !tbaa !46
  %conv = trunc i512 %0 to i64
  %shr = lshr i512 %0, 64
  %conv.1 = trunc i512 %shr to i64
  %shr.1 = lshr i512 %0, 128
  %conv.2 = trunc i512 %shr.1 to i64
  %shr.2 = lshr i512 %0, 192
  %conv.3 = trunc i512 %shr.2 to i64
  %shr.3 = lshr i512 %0, 256
  %conv.4 = trunc i512 %shr.3 to i64
  %shr.4 = lshr i512 %0, 320
  %conv.5 = trunc i512 %shr.4 to i64
  %shr.5 = lshr i512 %0, 384
  %conv.6 = trunc i512 %shr.5 to i64
  %shr.6 = lshr i512 %0, 448
  %conv.7 = trunc i512 %shr.6 to i64
  %vtable.i = load ptr, ptr %os, align 8, !tbaa !24
  %vbase.offset.ptr.i = getelementptr i8, ptr %vtable.i, i64 -24
  %vbase.offset.i = load i64, ptr %vbase.offset.ptr.i, align 8
  %add.ptr.i = getelementptr inbounds i8, ptr %os, i64 %vbase.offset.i
  %_M_flags.i.i = getelementptr inbounds %"class.std::ios_base", ptr %add.ptr.i, i64 0, i32 3
  %1 = load i32, ptr %_M_flags.i.i, align 8, !tbaa !148
  %and.i.i.i.i = and i32 %1, -75
  %or.i.i.i.i = or i32 %and.i.i.i.i, 8
  store i32 %or.i.i.i.i, ptr %_M_flags.i.i, align 8, !tbaa !149
  %call1.i = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) %os, ptr noundef nonnull @.str.1, i64 noundef 7)
  %vtable.i47 = load ptr, ptr %os, align 8, !tbaa !24
  %vbase.offset.ptr.i48 = getelementptr i8, ptr %vtable.i47, i64 -24
  %vbase.offset.i49 = load i64, ptr %vbase.offset.ptr.i48, align 8
  %add.ptr.i50 = getelementptr inbounds i8, ptr %os, i64 %vbase.offset.i49
  %_M_width.i.i = getelementptr inbounds %"class.std::ios_base", ptr %add.ptr.i50, i64 0, i32 2
  store i64 16, ptr %_M_width.i.i, align 8, !tbaa !150
  %vbase.offset.i53 = load i64, ptr %vbase.offset.ptr.i48, align 8
  %add.ptr.i54 = getelementptr inbounds i8, ptr %os, i64 %vbase.offset.i53
  %_M_fill_init.i.i.i = getelementptr inbounds %"class.std::basic_ios", ptr %add.ptr.i54, i64 0, i32 3
  %2 = load i8, ptr %_M_fill_init.i.i.i, align 1, !tbaa !151, !range !122, !noundef !123
  %tobool.not.i.i.i = icmp eq i8 %2, 0
  br i1 %tobool.not.i.i.i, label %if.then.i.i.i, label %_ZStlsIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_St8_SetfillIS3_E.exit

if.then.i.i.i64:                                  ; preds = %_ZStlsIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_St8_SetfillIS3_E.exit.7
  tail call void @_ZSt16__throw_bad_castv() #13
  unreachable

_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i.i: ; preds = %_ZStlsIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_St8_SetfillIS3_E.exit.7
  %_M_widen_ok.i.i.i = getelementptr inbounds %"class.std::ctype", ptr %40, i64 0, i32 8
  %3 = load i8, ptr %_M_widen_ok.i.i.i, align 8, !tbaa !37
  %tobool.not.i3.i.i = icmp eq i8 %3, 0
  br i1 %tobool.not.i3.i.i, label %if.end.i.i.i, label %if.then.i4.i.i

if.then.i4.i.i:                                   ; preds = %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i.i
  %arrayidx.i.i.i = getelementptr inbounds %"class.std::ctype", ptr %40, i64 0, i32 9, i64 10
  %4 = load i8, ptr %arrayidx.i.i.i, align 1, !tbaa !40
  br label %_ZSt4endlIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_.exit

if.end.i.i.i:                                     ; preds = %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i.i
  tail call void @_ZNKSt5ctypeIcE13_M_widen_initEv(ptr noundef nonnull align 8 dereferenceable(570) %40)
  %vtable.i.i.i = load ptr, ptr %40, align 8, !tbaa !24
  %vfn.i.i.i = getelementptr inbounds ptr, ptr %vtable.i.i.i, i64 6
  %5 = load ptr, ptr %vfn.i.i.i, align 8
  %call.i.i.i = tail call noundef signext i8 %5(ptr noundef nonnull align 8 dereferenceable(570) %40, i8 noundef signext 10)
  br label %_ZSt4endlIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_.exit

_ZSt4endlIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_.exit: ; preds = %if.then.i4.i.i, %if.end.i.i.i
  %retval.0.i.i.i = phi i8 [ %4, %if.then.i4.i.i ], [ %call.i.i.i, %if.end.i.i.i ]
  %call1.i65 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZNSo3putEc(ptr noundef nonnull align 8 dereferenceable(8) %call.i45, i8 noundef signext %retval.0.i.i.i)
  %call.i.i66 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZNSo5flushEv(ptr noundef nonnull align 8 dereferenceable(8) %call1.i65)
  ret ptr %os

if.then.i.i.i:                                    ; preds = %entry
  %_M_ctype.i.i.i.i = getelementptr inbounds %"class.std::basic_ios", ptr %add.ptr.i54, i64 0, i32 5
  %6 = load ptr, ptr %_M_ctype.i.i.i.i, align 8, !tbaa !26
  %tobool.not.i.i.i.i.i = icmp eq ptr %6, null
  br i1 %tobool.not.i.i.i.i.i, label %if.then.i.i.i.i.i, label %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i.i.i.i

if.then.i.i.i.i.i:                                ; preds = %if.then.i.i.i.7, %if.then.i.i.i.6, %if.then.i.i.i.5, %if.then.i.i.i.4, %if.then.i.i.i.3, %if.then.i.i.i.2, %if.then.i.i.i.1, %if.then.i.i.i
  tail call void @_ZSt16__throw_bad_castv() #13
  unreachable

_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i.i.i.i: ; preds = %if.then.i.i.i
  %_M_widen_ok.i.i.i.i.i = getelementptr inbounds %"class.std::ctype", ptr %6, i64 0, i32 8
  %7 = load i8, ptr %_M_widen_ok.i.i.i.i.i, align 8, !tbaa !37
  %tobool.not.i3.i.i.i.i = icmp eq i8 %7, 0
  br i1 %tobool.not.i3.i.i.i.i, label %if.end.i.i.i.i.i, label %_ZNKSt9basic_iosIcSt11char_traitsIcEE5widenEc.exit.i.i.i

if.end.i.i.i.i.i:                                 ; preds = %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i.i.i.i
  tail call void @_ZNKSt5ctypeIcE13_M_widen_initEv(ptr noundef nonnull align 8 dereferenceable(570) %6)
  %vtable.i.i.i.i.i = load ptr, ptr %6, align 8, !tbaa !24
  %vfn.i.i.i.i.i = getelementptr inbounds ptr, ptr %vtable.i.i.i.i.i, i64 6
  %8 = load ptr, ptr %vfn.i.i.i.i.i, align 8
  %call.i.i.i.i.i = tail call noundef signext i8 %8(ptr noundef nonnull align 8 dereferenceable(570) %6, i8 noundef signext 32)
  br label %_ZNKSt9basic_iosIcSt11char_traitsIcEE5widenEc.exit.i.i.i

_ZNKSt9basic_iosIcSt11char_traitsIcEE5widenEc.exit.i.i.i: ; preds = %if.end.i.i.i.i.i, %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i.i.i.i
  store i8 1, ptr %_M_fill_init.i.i.i, align 1, !tbaa !151
  br label %_ZStlsIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_St8_SetfillIS3_E.exit

_ZStlsIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_St8_SetfillIS3_E.exit: ; preds = %entry, %_ZNKSt9basic_iosIcSt11char_traitsIcEE5widenEc.exit.i.i.i
  %_M_fill.i.i = getelementptr inbounds %"class.std::basic_ios", ptr %add.ptr.i54, i64 0, i32 2
  store i8 48, ptr %_M_fill.i.i, align 8, !tbaa !152
  %call.i55 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZNSo9_M_insertIyEERSoT_(ptr noundef nonnull align 8 dereferenceable(8) %os, i64 noundef %conv.7)
  %vtable.i47.1 = load ptr, ptr %os, align 8, !tbaa !24
  %vbase.offset.ptr.i48.1 = getelementptr i8, ptr %vtable.i47.1, i64 -24
  %vbase.offset.i49.1 = load i64, ptr %vbase.offset.ptr.i48.1, align 8
  %add.ptr.i50.1 = getelementptr inbounds i8, ptr %os, i64 %vbase.offset.i49.1
  %_M_width.i.i.1 = getelementptr inbounds %"class.std::ios_base", ptr %add.ptr.i50.1, i64 0, i32 2
  store i64 16, ptr %_M_width.i.i.1, align 8, !tbaa !150
  %vbase.offset.i53.1 = load i64, ptr %vbase.offset.ptr.i48.1, align 8
  %add.ptr.i54.1 = getelementptr inbounds i8, ptr %os, i64 %vbase.offset.i53.1
  %_M_fill_init.i.i.i.1 = getelementptr inbounds %"class.std::basic_ios", ptr %add.ptr.i54.1, i64 0, i32 3
  %9 = load i8, ptr %_M_fill_init.i.i.i.1, align 1, !tbaa !151, !range !122, !noundef !123
  %tobool.not.i.i.i.1 = icmp eq i8 %9, 0
  br i1 %tobool.not.i.i.i.1, label %if.then.i.i.i.1, label %_ZStlsIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_St8_SetfillIS3_E.exit.1

if.then.i.i.i.1:                                  ; preds = %_ZStlsIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_St8_SetfillIS3_E.exit
  %_M_ctype.i.i.i.i.1 = getelementptr inbounds %"class.std::basic_ios", ptr %add.ptr.i54.1, i64 0, i32 5
  %10 = load ptr, ptr %_M_ctype.i.i.i.i.1, align 8, !tbaa !26
  %tobool.not.i.i.i.i.i.1 = icmp eq ptr %10, null
  br i1 %tobool.not.i.i.i.i.i.1, label %if.then.i.i.i.i.i, label %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i.i.i.i.1

_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i.i.i.i.1: ; preds = %if.then.i.i.i.1
  %_M_widen_ok.i.i.i.i.i.1 = getelementptr inbounds %"class.std::ctype", ptr %10, i64 0, i32 8
  %11 = load i8, ptr %_M_widen_ok.i.i.i.i.i.1, align 8, !tbaa !37
  %tobool.not.i3.i.i.i.i.1 = icmp eq i8 %11, 0
  br i1 %tobool.not.i3.i.i.i.i.1, label %if.end.i.i.i.i.i.1, label %_ZNKSt9basic_iosIcSt11char_traitsIcEE5widenEc.exit.i.i.i.1

if.end.i.i.i.i.i.1:                               ; preds = %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i.i.i.i.1
  tail call void @_ZNKSt5ctypeIcE13_M_widen_initEv(ptr noundef nonnull align 8 dereferenceable(570) %10)
  %vtable.i.i.i.i.i.1 = load ptr, ptr %10, align 8, !tbaa !24
  %vfn.i.i.i.i.i.1 = getelementptr inbounds ptr, ptr %vtable.i.i.i.i.i.1, i64 6
  %12 = load ptr, ptr %vfn.i.i.i.i.i.1, align 8
  %call.i.i.i.i.i.1 = tail call noundef signext i8 %12(ptr noundef nonnull align 8 dereferenceable(570) %10, i8 noundef signext 32)
  br label %_ZNKSt9basic_iosIcSt11char_traitsIcEE5widenEc.exit.i.i.i.1

_ZNKSt9basic_iosIcSt11char_traitsIcEE5widenEc.exit.i.i.i.1: ; preds = %if.end.i.i.i.i.i.1, %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i.i.i.i.1
  store i8 1, ptr %_M_fill_init.i.i.i.1, align 1, !tbaa !151
  br label %_ZStlsIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_St8_SetfillIS3_E.exit.1

_ZStlsIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_St8_SetfillIS3_E.exit.1: ; preds = %_ZNKSt9basic_iosIcSt11char_traitsIcEE5widenEc.exit.i.i.i.1, %_ZStlsIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_St8_SetfillIS3_E.exit
  %_M_fill.i.i.1 = getelementptr inbounds %"class.std::basic_ios", ptr %add.ptr.i54.1, i64 0, i32 2
  store i8 48, ptr %_M_fill.i.i.1, align 8, !tbaa !152
  %call.i55.1 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZNSo9_M_insertIyEERSoT_(ptr noundef nonnull align 8 dereferenceable(8) %os, i64 noundef %conv.6)
  %vtable.i47.2 = load ptr, ptr %os, align 8, !tbaa !24
  %vbase.offset.ptr.i48.2 = getelementptr i8, ptr %vtable.i47.2, i64 -24
  %vbase.offset.i49.2 = load i64, ptr %vbase.offset.ptr.i48.2, align 8
  %add.ptr.i50.2 = getelementptr inbounds i8, ptr %os, i64 %vbase.offset.i49.2
  %_M_width.i.i.2 = getelementptr inbounds %"class.std::ios_base", ptr %add.ptr.i50.2, i64 0, i32 2
  store i64 16, ptr %_M_width.i.i.2, align 8, !tbaa !150
  %vbase.offset.i53.2 = load i64, ptr %vbase.offset.ptr.i48.2, align 8
  %add.ptr.i54.2 = getelementptr inbounds i8, ptr %os, i64 %vbase.offset.i53.2
  %_M_fill_init.i.i.i.2 = getelementptr inbounds %"class.std::basic_ios", ptr %add.ptr.i54.2, i64 0, i32 3
  %13 = load i8, ptr %_M_fill_init.i.i.i.2, align 1, !tbaa !151, !range !122, !noundef !123
  %tobool.not.i.i.i.2 = icmp eq i8 %13, 0
  br i1 %tobool.not.i.i.i.2, label %if.then.i.i.i.2, label %_ZStlsIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_St8_SetfillIS3_E.exit.2

if.then.i.i.i.2:                                  ; preds = %_ZStlsIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_St8_SetfillIS3_E.exit.1
  %_M_ctype.i.i.i.i.2 = getelementptr inbounds %"class.std::basic_ios", ptr %add.ptr.i54.2, i64 0, i32 5
  %14 = load ptr, ptr %_M_ctype.i.i.i.i.2, align 8, !tbaa !26
  %tobool.not.i.i.i.i.i.2 = icmp eq ptr %14, null
  br i1 %tobool.not.i.i.i.i.i.2, label %if.then.i.i.i.i.i, label %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i.i.i.i.2

_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i.i.i.i.2: ; preds = %if.then.i.i.i.2
  %_M_widen_ok.i.i.i.i.i.2 = getelementptr inbounds %"class.std::ctype", ptr %14, i64 0, i32 8
  %15 = load i8, ptr %_M_widen_ok.i.i.i.i.i.2, align 8, !tbaa !37
  %tobool.not.i3.i.i.i.i.2 = icmp eq i8 %15, 0
  br i1 %tobool.not.i3.i.i.i.i.2, label %if.end.i.i.i.i.i.2, label %_ZNKSt9basic_iosIcSt11char_traitsIcEE5widenEc.exit.i.i.i.2

if.end.i.i.i.i.i.2:                               ; preds = %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i.i.i.i.2
  tail call void @_ZNKSt5ctypeIcE13_M_widen_initEv(ptr noundef nonnull align 8 dereferenceable(570) %14)
  %vtable.i.i.i.i.i.2 = load ptr, ptr %14, align 8, !tbaa !24
  %vfn.i.i.i.i.i.2 = getelementptr inbounds ptr, ptr %vtable.i.i.i.i.i.2, i64 6
  %16 = load ptr, ptr %vfn.i.i.i.i.i.2, align 8
  %call.i.i.i.i.i.2 = tail call noundef signext i8 %16(ptr noundef nonnull align 8 dereferenceable(570) %14, i8 noundef signext 32)
  br label %_ZNKSt9basic_iosIcSt11char_traitsIcEE5widenEc.exit.i.i.i.2

_ZNKSt9basic_iosIcSt11char_traitsIcEE5widenEc.exit.i.i.i.2: ; preds = %if.end.i.i.i.i.i.2, %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i.i.i.i.2
  store i8 1, ptr %_M_fill_init.i.i.i.2, align 1, !tbaa !151
  br label %_ZStlsIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_St8_SetfillIS3_E.exit.2

_ZStlsIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_St8_SetfillIS3_E.exit.2: ; preds = %_ZNKSt9basic_iosIcSt11char_traitsIcEE5widenEc.exit.i.i.i.2, %_ZStlsIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_St8_SetfillIS3_E.exit.1
  %_M_fill.i.i.2 = getelementptr inbounds %"class.std::basic_ios", ptr %add.ptr.i54.2, i64 0, i32 2
  store i8 48, ptr %_M_fill.i.i.2, align 8, !tbaa !152
  %call.i55.2 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZNSo9_M_insertIyEERSoT_(ptr noundef nonnull align 8 dereferenceable(8) %os, i64 noundef %conv.5)
  %vtable.i47.3 = load ptr, ptr %os, align 8, !tbaa !24
  %vbase.offset.ptr.i48.3 = getelementptr i8, ptr %vtable.i47.3, i64 -24
  %vbase.offset.i49.3 = load i64, ptr %vbase.offset.ptr.i48.3, align 8
  %add.ptr.i50.3 = getelementptr inbounds i8, ptr %os, i64 %vbase.offset.i49.3
  %_M_width.i.i.3 = getelementptr inbounds %"class.std::ios_base", ptr %add.ptr.i50.3, i64 0, i32 2
  store i64 16, ptr %_M_width.i.i.3, align 8, !tbaa !150
  %vbase.offset.i53.3 = load i64, ptr %vbase.offset.ptr.i48.3, align 8
  %add.ptr.i54.3 = getelementptr inbounds i8, ptr %os, i64 %vbase.offset.i53.3
  %_M_fill_init.i.i.i.3 = getelementptr inbounds %"class.std::basic_ios", ptr %add.ptr.i54.3, i64 0, i32 3
  %17 = load i8, ptr %_M_fill_init.i.i.i.3, align 1, !tbaa !151, !range !122, !noundef !123
  %tobool.not.i.i.i.3 = icmp eq i8 %17, 0
  br i1 %tobool.not.i.i.i.3, label %if.then.i.i.i.3, label %_ZStlsIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_St8_SetfillIS3_E.exit.3

if.then.i.i.i.3:                                  ; preds = %_ZStlsIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_St8_SetfillIS3_E.exit.2
  %_M_ctype.i.i.i.i.3 = getelementptr inbounds %"class.std::basic_ios", ptr %add.ptr.i54.3, i64 0, i32 5
  %18 = load ptr, ptr %_M_ctype.i.i.i.i.3, align 8, !tbaa !26
  %tobool.not.i.i.i.i.i.3 = icmp eq ptr %18, null
  br i1 %tobool.not.i.i.i.i.i.3, label %if.then.i.i.i.i.i, label %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i.i.i.i.3

_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i.i.i.i.3: ; preds = %if.then.i.i.i.3
  %_M_widen_ok.i.i.i.i.i.3 = getelementptr inbounds %"class.std::ctype", ptr %18, i64 0, i32 8
  %19 = load i8, ptr %_M_widen_ok.i.i.i.i.i.3, align 8, !tbaa !37
  %tobool.not.i3.i.i.i.i.3 = icmp eq i8 %19, 0
  br i1 %tobool.not.i3.i.i.i.i.3, label %if.end.i.i.i.i.i.3, label %_ZNKSt9basic_iosIcSt11char_traitsIcEE5widenEc.exit.i.i.i.3

if.end.i.i.i.i.i.3:                               ; preds = %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i.i.i.i.3
  tail call void @_ZNKSt5ctypeIcE13_M_widen_initEv(ptr noundef nonnull align 8 dereferenceable(570) %18)
  %vtable.i.i.i.i.i.3 = load ptr, ptr %18, align 8, !tbaa !24
  %vfn.i.i.i.i.i.3 = getelementptr inbounds ptr, ptr %vtable.i.i.i.i.i.3, i64 6
  %20 = load ptr, ptr %vfn.i.i.i.i.i.3, align 8
  %call.i.i.i.i.i.3 = tail call noundef signext i8 %20(ptr noundef nonnull align 8 dereferenceable(570) %18, i8 noundef signext 32)
  br label %_ZNKSt9basic_iosIcSt11char_traitsIcEE5widenEc.exit.i.i.i.3

_ZNKSt9basic_iosIcSt11char_traitsIcEE5widenEc.exit.i.i.i.3: ; preds = %if.end.i.i.i.i.i.3, %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i.i.i.i.3
  store i8 1, ptr %_M_fill_init.i.i.i.3, align 1, !tbaa !151
  br label %_ZStlsIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_St8_SetfillIS3_E.exit.3

_ZStlsIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_St8_SetfillIS3_E.exit.3: ; preds = %_ZNKSt9basic_iosIcSt11char_traitsIcEE5widenEc.exit.i.i.i.3, %_ZStlsIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_St8_SetfillIS3_E.exit.2
  %_M_fill.i.i.3 = getelementptr inbounds %"class.std::basic_ios", ptr %add.ptr.i54.3, i64 0, i32 2
  store i8 48, ptr %_M_fill.i.i.3, align 8, !tbaa !152
  %call.i55.3 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZNSo9_M_insertIyEERSoT_(ptr noundef nonnull align 8 dereferenceable(8) %os, i64 noundef %conv.4)
  %vtable.i47.4 = load ptr, ptr %os, align 8, !tbaa !24
  %vbase.offset.ptr.i48.4 = getelementptr i8, ptr %vtable.i47.4, i64 -24
  %vbase.offset.i49.4 = load i64, ptr %vbase.offset.ptr.i48.4, align 8
  %add.ptr.i50.4 = getelementptr inbounds i8, ptr %os, i64 %vbase.offset.i49.4
  %_M_width.i.i.4 = getelementptr inbounds %"class.std::ios_base", ptr %add.ptr.i50.4, i64 0, i32 2
  store i64 16, ptr %_M_width.i.i.4, align 8, !tbaa !150
  %vbase.offset.i53.4 = load i64, ptr %vbase.offset.ptr.i48.4, align 8
  %add.ptr.i54.4 = getelementptr inbounds i8, ptr %os, i64 %vbase.offset.i53.4
  %_M_fill_init.i.i.i.4 = getelementptr inbounds %"class.std::basic_ios", ptr %add.ptr.i54.4, i64 0, i32 3
  %21 = load i8, ptr %_M_fill_init.i.i.i.4, align 1, !tbaa !151, !range !122, !noundef !123
  %tobool.not.i.i.i.4 = icmp eq i8 %21, 0
  br i1 %tobool.not.i.i.i.4, label %if.then.i.i.i.4, label %_ZStlsIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_St8_SetfillIS3_E.exit.4

if.then.i.i.i.4:                                  ; preds = %_ZStlsIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_St8_SetfillIS3_E.exit.3
  %_M_ctype.i.i.i.i.4 = getelementptr inbounds %"class.std::basic_ios", ptr %add.ptr.i54.4, i64 0, i32 5
  %22 = load ptr, ptr %_M_ctype.i.i.i.i.4, align 8, !tbaa !26
  %tobool.not.i.i.i.i.i.4 = icmp eq ptr %22, null
  br i1 %tobool.not.i.i.i.i.i.4, label %if.then.i.i.i.i.i, label %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i.i.i.i.4

_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i.i.i.i.4: ; preds = %if.then.i.i.i.4
  %_M_widen_ok.i.i.i.i.i.4 = getelementptr inbounds %"class.std::ctype", ptr %22, i64 0, i32 8
  %23 = load i8, ptr %_M_widen_ok.i.i.i.i.i.4, align 8, !tbaa !37
  %tobool.not.i3.i.i.i.i.4 = icmp eq i8 %23, 0
  br i1 %tobool.not.i3.i.i.i.i.4, label %if.end.i.i.i.i.i.4, label %_ZNKSt9basic_iosIcSt11char_traitsIcEE5widenEc.exit.i.i.i.4

if.end.i.i.i.i.i.4:                               ; preds = %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i.i.i.i.4
  tail call void @_ZNKSt5ctypeIcE13_M_widen_initEv(ptr noundef nonnull align 8 dereferenceable(570) %22)
  %vtable.i.i.i.i.i.4 = load ptr, ptr %22, align 8, !tbaa !24
  %vfn.i.i.i.i.i.4 = getelementptr inbounds ptr, ptr %vtable.i.i.i.i.i.4, i64 6
  %24 = load ptr, ptr %vfn.i.i.i.i.i.4, align 8
  %call.i.i.i.i.i.4 = tail call noundef signext i8 %24(ptr noundef nonnull align 8 dereferenceable(570) %22, i8 noundef signext 32)
  br label %_ZNKSt9basic_iosIcSt11char_traitsIcEE5widenEc.exit.i.i.i.4

_ZNKSt9basic_iosIcSt11char_traitsIcEE5widenEc.exit.i.i.i.4: ; preds = %if.end.i.i.i.i.i.4, %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i.i.i.i.4
  store i8 1, ptr %_M_fill_init.i.i.i.4, align 1, !tbaa !151
  br label %_ZStlsIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_St8_SetfillIS3_E.exit.4

_ZStlsIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_St8_SetfillIS3_E.exit.4: ; preds = %_ZNKSt9basic_iosIcSt11char_traitsIcEE5widenEc.exit.i.i.i.4, %_ZStlsIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_St8_SetfillIS3_E.exit.3
  %_M_fill.i.i.4 = getelementptr inbounds %"class.std::basic_ios", ptr %add.ptr.i54.4, i64 0, i32 2
  store i8 48, ptr %_M_fill.i.i.4, align 8, !tbaa !152
  %call.i55.4 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZNSo9_M_insertIyEERSoT_(ptr noundef nonnull align 8 dereferenceable(8) %os, i64 noundef %conv.3)
  %vtable.i47.5 = load ptr, ptr %os, align 8, !tbaa !24
  %vbase.offset.ptr.i48.5 = getelementptr i8, ptr %vtable.i47.5, i64 -24
  %vbase.offset.i49.5 = load i64, ptr %vbase.offset.ptr.i48.5, align 8
  %add.ptr.i50.5 = getelementptr inbounds i8, ptr %os, i64 %vbase.offset.i49.5
  %_M_width.i.i.5 = getelementptr inbounds %"class.std::ios_base", ptr %add.ptr.i50.5, i64 0, i32 2
  store i64 16, ptr %_M_width.i.i.5, align 8, !tbaa !150
  %vbase.offset.i53.5 = load i64, ptr %vbase.offset.ptr.i48.5, align 8
  %add.ptr.i54.5 = getelementptr inbounds i8, ptr %os, i64 %vbase.offset.i53.5
  %_M_fill_init.i.i.i.5 = getelementptr inbounds %"class.std::basic_ios", ptr %add.ptr.i54.5, i64 0, i32 3
  %25 = load i8, ptr %_M_fill_init.i.i.i.5, align 1, !tbaa !151, !range !122, !noundef !123
  %tobool.not.i.i.i.5 = icmp eq i8 %25, 0
  br i1 %tobool.not.i.i.i.5, label %if.then.i.i.i.5, label %_ZStlsIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_St8_SetfillIS3_E.exit.5

if.then.i.i.i.5:                                  ; preds = %_ZStlsIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_St8_SetfillIS3_E.exit.4
  %_M_ctype.i.i.i.i.5 = getelementptr inbounds %"class.std::basic_ios", ptr %add.ptr.i54.5, i64 0, i32 5
  %26 = load ptr, ptr %_M_ctype.i.i.i.i.5, align 8, !tbaa !26
  %tobool.not.i.i.i.i.i.5 = icmp eq ptr %26, null
  br i1 %tobool.not.i.i.i.i.i.5, label %if.then.i.i.i.i.i, label %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i.i.i.i.5

_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i.i.i.i.5: ; preds = %if.then.i.i.i.5
  %_M_widen_ok.i.i.i.i.i.5 = getelementptr inbounds %"class.std::ctype", ptr %26, i64 0, i32 8
  %27 = load i8, ptr %_M_widen_ok.i.i.i.i.i.5, align 8, !tbaa !37
  %tobool.not.i3.i.i.i.i.5 = icmp eq i8 %27, 0
  br i1 %tobool.not.i3.i.i.i.i.5, label %if.end.i.i.i.i.i.5, label %_ZNKSt9basic_iosIcSt11char_traitsIcEE5widenEc.exit.i.i.i.5

if.end.i.i.i.i.i.5:                               ; preds = %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i.i.i.i.5
  tail call void @_ZNKSt5ctypeIcE13_M_widen_initEv(ptr noundef nonnull align 8 dereferenceable(570) %26)
  %vtable.i.i.i.i.i.5 = load ptr, ptr %26, align 8, !tbaa !24
  %vfn.i.i.i.i.i.5 = getelementptr inbounds ptr, ptr %vtable.i.i.i.i.i.5, i64 6
  %28 = load ptr, ptr %vfn.i.i.i.i.i.5, align 8
  %call.i.i.i.i.i.5 = tail call noundef signext i8 %28(ptr noundef nonnull align 8 dereferenceable(570) %26, i8 noundef signext 32)
  br label %_ZNKSt9basic_iosIcSt11char_traitsIcEE5widenEc.exit.i.i.i.5

_ZNKSt9basic_iosIcSt11char_traitsIcEE5widenEc.exit.i.i.i.5: ; preds = %if.end.i.i.i.i.i.5, %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i.i.i.i.5
  store i8 1, ptr %_M_fill_init.i.i.i.5, align 1, !tbaa !151
  br label %_ZStlsIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_St8_SetfillIS3_E.exit.5

_ZStlsIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_St8_SetfillIS3_E.exit.5: ; preds = %_ZNKSt9basic_iosIcSt11char_traitsIcEE5widenEc.exit.i.i.i.5, %_ZStlsIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_St8_SetfillIS3_E.exit.4
  %_M_fill.i.i.5 = getelementptr inbounds %"class.std::basic_ios", ptr %add.ptr.i54.5, i64 0, i32 2
  store i8 48, ptr %_M_fill.i.i.5, align 8, !tbaa !152
  %call.i55.5 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZNSo9_M_insertIyEERSoT_(ptr noundef nonnull align 8 dereferenceable(8) %os, i64 noundef %conv.2)
  %vtable.i47.6 = load ptr, ptr %os, align 8, !tbaa !24
  %vbase.offset.ptr.i48.6 = getelementptr i8, ptr %vtable.i47.6, i64 -24
  %vbase.offset.i49.6 = load i64, ptr %vbase.offset.ptr.i48.6, align 8
  %add.ptr.i50.6 = getelementptr inbounds i8, ptr %os, i64 %vbase.offset.i49.6
  %_M_width.i.i.6 = getelementptr inbounds %"class.std::ios_base", ptr %add.ptr.i50.6, i64 0, i32 2
  store i64 16, ptr %_M_width.i.i.6, align 8, !tbaa !150
  %vbase.offset.i53.6 = load i64, ptr %vbase.offset.ptr.i48.6, align 8
  %add.ptr.i54.6 = getelementptr inbounds i8, ptr %os, i64 %vbase.offset.i53.6
  %_M_fill_init.i.i.i.6 = getelementptr inbounds %"class.std::basic_ios", ptr %add.ptr.i54.6, i64 0, i32 3
  %29 = load i8, ptr %_M_fill_init.i.i.i.6, align 1, !tbaa !151, !range !122, !noundef !123
  %tobool.not.i.i.i.6 = icmp eq i8 %29, 0
  br i1 %tobool.not.i.i.i.6, label %if.then.i.i.i.6, label %_ZStlsIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_St8_SetfillIS3_E.exit.6

if.then.i.i.i.6:                                  ; preds = %_ZStlsIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_St8_SetfillIS3_E.exit.5
  %_M_ctype.i.i.i.i.6 = getelementptr inbounds %"class.std::basic_ios", ptr %add.ptr.i54.6, i64 0, i32 5
  %30 = load ptr, ptr %_M_ctype.i.i.i.i.6, align 8, !tbaa !26
  %tobool.not.i.i.i.i.i.6 = icmp eq ptr %30, null
  br i1 %tobool.not.i.i.i.i.i.6, label %if.then.i.i.i.i.i, label %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i.i.i.i.6

_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i.i.i.i.6: ; preds = %if.then.i.i.i.6
  %_M_widen_ok.i.i.i.i.i.6 = getelementptr inbounds %"class.std::ctype", ptr %30, i64 0, i32 8
  %31 = load i8, ptr %_M_widen_ok.i.i.i.i.i.6, align 8, !tbaa !37
  %tobool.not.i3.i.i.i.i.6 = icmp eq i8 %31, 0
  br i1 %tobool.not.i3.i.i.i.i.6, label %if.end.i.i.i.i.i.6, label %_ZNKSt9basic_iosIcSt11char_traitsIcEE5widenEc.exit.i.i.i.6

if.end.i.i.i.i.i.6:                               ; preds = %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i.i.i.i.6
  tail call void @_ZNKSt5ctypeIcE13_M_widen_initEv(ptr noundef nonnull align 8 dereferenceable(570) %30)
  %vtable.i.i.i.i.i.6 = load ptr, ptr %30, align 8, !tbaa !24
  %vfn.i.i.i.i.i.6 = getelementptr inbounds ptr, ptr %vtable.i.i.i.i.i.6, i64 6
  %32 = load ptr, ptr %vfn.i.i.i.i.i.6, align 8
  %call.i.i.i.i.i.6 = tail call noundef signext i8 %32(ptr noundef nonnull align 8 dereferenceable(570) %30, i8 noundef signext 32)
  br label %_ZNKSt9basic_iosIcSt11char_traitsIcEE5widenEc.exit.i.i.i.6

_ZNKSt9basic_iosIcSt11char_traitsIcEE5widenEc.exit.i.i.i.6: ; preds = %if.end.i.i.i.i.i.6, %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i.i.i.i.6
  store i8 1, ptr %_M_fill_init.i.i.i.6, align 1, !tbaa !151
  br label %_ZStlsIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_St8_SetfillIS3_E.exit.6

_ZStlsIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_St8_SetfillIS3_E.exit.6: ; preds = %_ZNKSt9basic_iosIcSt11char_traitsIcEE5widenEc.exit.i.i.i.6, %_ZStlsIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_St8_SetfillIS3_E.exit.5
  %_M_fill.i.i.6 = getelementptr inbounds %"class.std::basic_ios", ptr %add.ptr.i54.6, i64 0, i32 2
  store i8 48, ptr %_M_fill.i.i.6, align 8, !tbaa !152
  %call.i55.6 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZNSo9_M_insertIyEERSoT_(ptr noundef nonnull align 8 dereferenceable(8) %os, i64 noundef %conv.1)
  %vtable.i47.7 = load ptr, ptr %os, align 8, !tbaa !24
  %vbase.offset.ptr.i48.7 = getelementptr i8, ptr %vtable.i47.7, i64 -24
  %vbase.offset.i49.7 = load i64, ptr %vbase.offset.ptr.i48.7, align 8
  %add.ptr.i50.7 = getelementptr inbounds i8, ptr %os, i64 %vbase.offset.i49.7
  %_M_width.i.i.7 = getelementptr inbounds %"class.std::ios_base", ptr %add.ptr.i50.7, i64 0, i32 2
  store i64 16, ptr %_M_width.i.i.7, align 8, !tbaa !150
  %vbase.offset.i53.7 = load i64, ptr %vbase.offset.ptr.i48.7, align 8
  %add.ptr.i54.7 = getelementptr inbounds i8, ptr %os, i64 %vbase.offset.i53.7
  %_M_fill_init.i.i.i.7 = getelementptr inbounds %"class.std::basic_ios", ptr %add.ptr.i54.7, i64 0, i32 3
  %33 = load i8, ptr %_M_fill_init.i.i.i.7, align 1, !tbaa !151, !range !122, !noundef !123
  %tobool.not.i.i.i.7 = icmp eq i8 %33, 0
  br i1 %tobool.not.i.i.i.7, label %if.then.i.i.i.7, label %_ZStlsIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_St8_SetfillIS3_E.exit.7

if.then.i.i.i.7:                                  ; preds = %_ZStlsIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_St8_SetfillIS3_E.exit.6
  %_M_ctype.i.i.i.i.7 = getelementptr inbounds %"class.std::basic_ios", ptr %add.ptr.i54.7, i64 0, i32 5
  %34 = load ptr, ptr %_M_ctype.i.i.i.i.7, align 8, !tbaa !26
  %tobool.not.i.i.i.i.i.7 = icmp eq ptr %34, null
  br i1 %tobool.not.i.i.i.i.i.7, label %if.then.i.i.i.i.i, label %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i.i.i.i.7

_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i.i.i.i.7: ; preds = %if.then.i.i.i.7
  %_M_widen_ok.i.i.i.i.i.7 = getelementptr inbounds %"class.std::ctype", ptr %34, i64 0, i32 8
  %35 = load i8, ptr %_M_widen_ok.i.i.i.i.i.7, align 8, !tbaa !37
  %tobool.not.i3.i.i.i.i.7 = icmp eq i8 %35, 0
  br i1 %tobool.not.i3.i.i.i.i.7, label %if.end.i.i.i.i.i.7, label %_ZNKSt9basic_iosIcSt11char_traitsIcEE5widenEc.exit.i.i.i.7

if.end.i.i.i.i.i.7:                               ; preds = %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i.i.i.i.7
  tail call void @_ZNKSt5ctypeIcE13_M_widen_initEv(ptr noundef nonnull align 8 dereferenceable(570) %34)
  %vtable.i.i.i.i.i.7 = load ptr, ptr %34, align 8, !tbaa !24
  %vfn.i.i.i.i.i.7 = getelementptr inbounds ptr, ptr %vtable.i.i.i.i.i.7, i64 6
  %36 = load ptr, ptr %vfn.i.i.i.i.i.7, align 8
  %call.i.i.i.i.i.7 = tail call noundef signext i8 %36(ptr noundef nonnull align 8 dereferenceable(570) %34, i8 noundef signext 32)
  br label %_ZNKSt9basic_iosIcSt11char_traitsIcEE5widenEc.exit.i.i.i.7

_ZNKSt9basic_iosIcSt11char_traitsIcEE5widenEc.exit.i.i.i.7: ; preds = %if.end.i.i.i.i.i.7, %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i.i.i.i.7
  store i8 1, ptr %_M_fill_init.i.i.i.7, align 1, !tbaa !151
  br label %_ZStlsIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_St8_SetfillIS3_E.exit.7

_ZStlsIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_St8_SetfillIS3_E.exit.7: ; preds = %_ZNKSt9basic_iosIcSt11char_traitsIcEE5widenEc.exit.i.i.i.7, %_ZStlsIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_St8_SetfillIS3_E.exit.6
  %_M_fill.i.i.7 = getelementptr inbounds %"class.std::basic_ios", ptr %add.ptr.i54.7, i64 0, i32 2
  store i8 48, ptr %_M_fill.i.i.7, align 8, !tbaa !152
  %call.i55.7 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZNSo9_M_insertIyEERSoT_(ptr noundef nonnull align 8 dereferenceable(8) %os, i64 noundef %conv)
  %vtable.i36 = load ptr, ptr %os, align 8, !tbaa !24
  %vbase.offset.ptr.i37 = getelementptr i8, ptr %vtable.i36, i64 -24
  %vbase.offset.i38 = load i64, ptr %vbase.offset.ptr.i37, align 8
  %add.ptr.i39 = getelementptr inbounds i8, ptr %os, i64 %vbase.offset.i38
  %_M_flags.i.i56 = getelementptr inbounds %"class.std::ios_base", ptr %add.ptr.i39, i64 0, i32 3
  %37 = load i32, ptr %_M_flags.i.i56, align 8, !tbaa !148
  %and.i.i.i.i57 = and i32 %37, -75
  %or.i.i.i.i58 = or i32 %and.i.i.i.i57, 2
  store i32 %or.i.i.i.i58, ptr %_M_flags.i.i56, align 8, !tbaa !149
  %call1.i42 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) %os, ptr noundef nonnull @.str.2, i64 noundef 10)
  %empty = getelementptr inbounds %struct.payload_t, ptr %val, i64 0, i32 1
  %38 = load i32, ptr %empty, align 8, !tbaa !49
  %call22 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZNSolsEi(ptr noundef nonnull align 8 dereferenceable(8) %os, i32 noundef %38)
  %call1.i44 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8) %call22, ptr noundef nonnull @.str.3, i64 noundef 9)
  %last = getelementptr inbounds %struct.payload_t, ptr %val, i64 0, i32 2
  %39 = load i8, ptr %last, align 4, !tbaa !153, !range !122, !noundef !123
  %tobool = icmp ne i8 %39, 0
  %call.i45 = tail call noundef nonnull align 8 dereferenceable(8) ptr @_ZNSo9_M_insertIbEERSoT_(ptr noundef nonnull align 8 dereferenceable(8) %call22, i1 noundef zeroext %tobool)
  %vtable.i59 = load ptr, ptr %call.i45, align 8, !tbaa !24
  %vbase.offset.ptr.i60 = getelementptr i8, ptr %vtable.i59, i64 -24
  %vbase.offset.i61 = load i64, ptr %vbase.offset.ptr.i60, align 8
  %add.ptr.i62 = getelementptr inbounds i8, ptr %call.i45, i64 %vbase.offset.i61
  %_M_ctype.i.i = getelementptr inbounds %"class.std::basic_ios", ptr %add.ptr.i62, i64 0, i32 5
  %40 = load ptr, ptr %_M_ctype.i.i, align 8, !tbaa !26
  %tobool.not.i.i.i63 = icmp eq ptr %40, null
  br i1 %tobool.not.i.i.i63, label %if.then.i.i.i64, label %_ZSt13__check_facetISt5ctypeIcEERKT_PS3_.exit.i.i
}

declare noundef nonnull align 8 dereferenceable(8) ptr @_ZNSolsEi(ptr noundef nonnull align 8 dereferenceable(8), i32 noundef) local_unnamed_addr #0

declare noundef nonnull align 8 dereferenceable(8) ptr @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(ptr noundef nonnull align 8 dereferenceable(8), ptr noundef, i64 noundef) local_unnamed_addr #0

; Function Attrs: noreturn
declare void @_ZSt16__throw_bad_castv() local_unnamed_addr #7

declare void @_ZNKSt5ctypeIcE13_M_widen_initEv(ptr noundef nonnull align 8 dereferenceable(570)) local_unnamed_addr #0

declare noundef nonnull align 8 dereferenceable(8) ptr @_ZNSo9_M_insertIyEERSoT_(ptr noundef nonnull align 8 dereferenceable(8), i64 noundef) local_unnamed_addr #0

declare noundef nonnull align 8 dereferenceable(8) ptr @_ZNSo9_M_insertIbEERSoT_(ptr noundef nonnull align 8 dereferenceable(8), i1 noundef zeroext) local_unnamed_addr #0

declare noundef nonnull align 8 dereferenceable(8) ptr @_ZNSo3putEc(ptr noundef nonnull align 8 dereferenceable(8), i8 noundef signext) local_unnamed_addr #0

declare noundef nonnull align 8 dereferenceable(8) ptr @_ZNSo5flushEv(ptr noundef nonnull align 8 dereferenceable(8)) local_unnamed_addr #0

declare noundef nonnull align 8 dereferenceable(8) ptr @_ZNSo9_M_insertImEERSoT_(ptr noundef nonnull align 8 dereferenceable(8), i64 noundef) local_unnamed_addr #0

; Function Attrs: uwtable
define internal void @_GLOBAL__sub_I_primate.cpp() #3 section ".text.startup" {
entry:
  tail call void @_ZNSt8ios_base4InitC1Ev(ptr noundef nonnull align 1 dereferenceable(1) @_ZStL8__ioinit)
  %0 = tail call i32 @__cxa_atexit(ptr nonnull @_ZNSt8ios_base4InitD1Ev, ptr nonnull @_ZStL8__ioinit, ptr nonnull @__dso_handle) #12
  ret void
}

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i64 @llvm.umax.i64(i64, i64) #11

attributes #0 = { "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { nounwind "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #2 = { nofree nounwind }
attributes #3 = { uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #4 = { mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #5 = { mustprogress uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #6 = { mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite) }
attributes #7 = { noreturn "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #8 = { nobuiltin allocsize(0) "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #9 = { nobuiltin nounwind "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #10 = { inlinehint mustprogress uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #11 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #12 = { nounwind }
attributes #13 = { noreturn }
attributes #14 = { builtin allocsize(0) }
attributes #15 = { builtin nounwind }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{!"clang version 16.0.6 (https://github.com/llvm/llvm-project.git 7cbf1a2591520c2491aa35339f227775f4d3adf6)"}
!5 = !{!6, !10, i64 16}
!6 = !{!"_ZTS10ethernet_t", !7, i64 0, !7, i64 8, !10, i64 16}
!7 = !{!"_BitInt(48)", !8, i64 0}
!8 = !{!"omnipotent char", !9, i64 0}
!9 = !{!"Simple C++ TBAA"}
!10 = !{!"_BitInt(16)", !8, i64 0}
!11 = !{!12, !14, i64 8}
!12 = !{!"_ZTS7ptp_l_t", !13, i64 0, !14, i64 8, !15, i64 16}
!13 = !{!"_BitInt(40)", !8, i64 0}
!14 = !{!"_BitInt(8)", !8, i64 0}
!15 = !{!"_BitInt(112)", !8, i64 0}
!16 = !{!17, !18, i64 0}
!17 = !{!"_ZTS8header_t", !18, i64 0, !18, i64 2, !18, i64 4, !18, i64 6}
!18 = !{!"short", !8, i64 0}
!19 = !{!20, !14, i64 16}
!20 = !{!"_ZTS6ipv4_t", !21, i64 0, !14, i64 16, !22, i64 24}
!21 = !{!"_BitInt(72)", !8, i64 0}
!22 = !{!"_BitInt(80)", !8, i64 0}
!23 = !{!18, !18, i64 0}
!24 = !{!25, !25, i64 0}
!25 = !{!"vtable pointer", !9, i64 0}
!26 = !{!27, !32, i64 240}
!27 = !{!"_ZTSSt9basic_iosIcSt11char_traitsIcEE", !28, i64 0, !32, i64 216, !8, i64 224, !36, i64 225, !32, i64 232, !32, i64 240, !32, i64 248, !32, i64 256}
!28 = !{!"_ZTSSt8ios_base", !29, i64 8, !29, i64 16, !30, i64 24, !31, i64 28, !31, i64 32, !32, i64 40, !33, i64 48, !8, i64 64, !34, i64 192, !32, i64 200, !35, i64 208}
!29 = !{!"long", !8, i64 0}
!30 = !{!"_ZTSSt13_Ios_Fmtflags", !8, i64 0}
!31 = !{!"_ZTSSt12_Ios_Iostate", !8, i64 0}
!32 = !{!"any pointer", !8, i64 0}
!33 = !{!"_ZTSNSt8ios_base6_WordsE", !32, i64 0, !29, i64 8}
!34 = !{!"int", !8, i64 0}
!35 = !{!"_ZTSSt6locale", !32, i64 0}
!36 = !{!"bool", !8, i64 0}
!37 = !{!38, !8, i64 56}
!38 = !{!"_ZTSSt5ctypeIcE", !39, i64 0, !32, i64 16, !36, i64 24, !32, i64 32, !32, i64 40, !32, i64 48, !8, i64 56, !8, i64 57, !8, i64 313, !8, i64 569}
!39 = !{!"_ZTSNSt6locale5facetE", !34, i64 8}
!40 = !{!8, !8, i64 0}
!41 = !{!42}
!42 = distinct !{!42, !43, !"_ZN10ethernet_t7to_uintEv: %agg.result"}
!43 = distinct !{!43, !"_ZN10ethernet_t7to_uintEv"}
!44 = !{!6, !7, i64 8}
!45 = !{!6, !7, i64 0}
!46 = !{!47, !48, i64 0}
!47 = !{!"_ZTS9payload_t", !48, i64 0, !34, i64 64, !36, i64 68}
!48 = !{!"_BitInt(512)", !8, i64 0}
!49 = !{!47, !34, i64 64}
!50 = !{!32, !32, i64 0}
!51 = !{!12, !15, i64 16}
!52 = !{!53}
!53 = distinct !{!53, !54, !"_ZN7ptp_l_t7to_uintEv: %agg.result"}
!54 = distinct !{!54, !"_ZN7ptp_l_t7to_uintEv"}
!55 = !{!12, !13, i64 0}
!56 = !{!57, !58, i64 0}
!57 = !{!"_ZTS7ptp_h_t", !58, i64 0}
!58 = !{!"_BitInt(192)", !8, i64 0}
!59 = !{!60}
!60 = distinct !{!60, !61, !"_ZN7ptp_h_t7to_uintEv: %agg.result"}
!61 = distinct !{!61, !"_ZN7ptp_h_t7to_uintEv"}
!62 = !{!63}
!63 = distinct !{!63, !64, !"_ZN8header_t7to_uintEv: %agg.result"}
!64 = distinct !{!64, !"_ZN8header_t7to_uintEv"}
!65 = !{!66}
!66 = distinct !{!66, !67, !"_ZN8header_t7to_uintEv: %agg.result"}
!67 = distinct !{!67, !"_ZN8header_t7to_uintEv"}
!68 = !{!69}
!69 = distinct !{!69, !70, !"_ZN8header_t7to_uintEv: %agg.result"}
!70 = distinct !{!70, !"_ZN8header_t7to_uintEv"}
!71 = !{!72}
!72 = distinct !{!72, !73, !"_ZN8header_t7to_uintEv: %agg.result"}
!73 = distinct !{!73, !"_ZN8header_t7to_uintEv"}
!74 = !{!75}
!75 = distinct !{!75, !76, !"_ZN8header_t7to_uintEv: %agg.result"}
!76 = distinct !{!76, !"_ZN8header_t7to_uintEv"}
!77 = !{!78}
!78 = distinct !{!78, !79, !"_ZN8header_t7to_uintEv: %agg.result"}
!79 = distinct !{!79, !"_ZN8header_t7to_uintEv"}
!80 = !{!81}
!81 = distinct !{!81, !82, !"_ZN8header_t7to_uintEv: %agg.result"}
!82 = distinct !{!82, !"_ZN8header_t7to_uintEv"}
!83 = !{!84}
!84 = distinct !{!84, !85, !"_ZN8header_t7to_uintEv: %agg.result"}
!85 = distinct !{!85, !"_ZN8header_t7to_uintEv"}
!86 = !{!20, !22, i64 24}
!87 = !{!88}
!88 = distinct !{!88, !89, !"_ZN6ipv4_t7to_uintEv: %agg.result"}
!89 = distinct !{!89, !"_ZN6ipv4_t7to_uintEv"}
!90 = !{!20, !21, i64 0}
!91 = !{!92, !93, i64 0}
!92 = !{!"_ZTS5tcp_t", !93, i64 0}
!93 = !{!"_BitInt(160)", !8, i64 0}
!94 = !{!95}
!95 = distinct !{!95, !96, !"_ZN5tcp_t7to_uintEv: %agg.result"}
!96 = distinct !{!96, !"_ZN5tcp_t7to_uintEv"}
!97 = !{!98, !99, i64 0}
!98 = !{!"_ZTS5udp_t", !99, i64 0}
!99 = !{!"_BitInt(64)", !8, i64 0}
!100 = !{!101}
!101 = distinct !{!101, !102, !"_ZN5udp_t7to_uintEv: %agg.result"}
!102 = distinct !{!102, !"_ZN5udp_t7to_uintEv"}
!103 = !{!104, !32, i64 0}
!104 = !{!"_ZTSNSt12_Vector_baseI9payload_tSaIS0_EE17_Vector_impl_dataE", !32, i64 0, !32, i64 8, !32, i64 16}
!105 = !{!104, !32, i64 8}
!106 = distinct !{!106, !107}
!107 = !{!"llvm.loop.mustprogress"}
!108 = !{!109, !36, i64 160}
!109 = !{!"_ZTS10primate_io", !48, i64 0, !34, i64 64, !34, i64 68, !34, i64 72, !34, i64 76, !36, i64 80, !47, i64 88, !36, i64 160, !110, i64 168, !113, i64 192, !120, i64 712}
!110 = !{!"_ZTSSt6vectorI9payload_tSaIS0_EE", !111, i64 0}
!111 = !{!"_ZTSSt12_Vector_baseI9payload_tSaIS0_EE", !112, i64 0}
!112 = !{!"_ZTSNSt12_Vector_baseI9payload_tSaIS0_EE12_Vector_implE", !104, i64 0}
!113 = !{!"_ZTSSt14basic_ifstreamIcSt11char_traitsIcEE", !114, i64 0, !115, i64 16}
!114 = !{!"_ZTSSi", !29, i64 8}
!115 = !{!"_ZTSSt13basic_filebufIcSt11char_traitsIcEE", !116, i64 0, !8, i64 64, !117, i64 104, !118, i64 120, !119, i64 124, !119, i64 132, !119, i64 140, !32, i64 152, !29, i64 160, !36, i64 168, !36, i64 169, !36, i64 170, !8, i64 171, !32, i64 176, !32, i64 184, !36, i64 192, !32, i64 200, !32, i64 208, !29, i64 216, !32, i64 224, !32, i64 232}
!116 = !{!"_ZTSSt15basic_streambufIcSt11char_traitsIcEE", !32, i64 8, !32, i64 16, !32, i64 24, !32, i64 32, !32, i64 40, !32, i64 48, !35, i64 56}
!117 = !{!"_ZTSSt12__basic_fileIcE", !32, i64 0, !36, i64 8}
!118 = !{!"_ZTSSt13_Ios_Openmode", !8, i64 0}
!119 = !{!"_ZTS11__mbstate_t", !34, i64 0, !8, i64 4}
!120 = !{!"_ZTSSt14basic_ofstreamIcSt11char_traitsIcEE", !121, i64 0, !115, i64 8}
!121 = !{!"_ZTSSo"}
!122 = !{i8 0, i8 2}
!123 = !{}
!124 = !{i64 0, i64 64, !125, i64 64, i64 4, !126, i64 68, i64 1, !127}
!125 = !{!48, !48, i64 0}
!126 = !{!34, !34, i64 0}
!127 = !{!36, !36, i64 0}
!128 = !{!109, !34, i64 72}
!129 = !{!109, !48, i64 0}
!130 = !{!15, !15, i64 0}
!131 = !{!109, !48, i64 88}
!132 = !{!109, !34, i64 76}
!133 = !{!109, !36, i64 156}
!134 = !{!109, !36, i64 80}
!135 = !{!109, !34, i64 68}
!136 = distinct !{!136, !107}
!137 = distinct !{!137, !107}
!138 = distinct !{!138, !107}
!139 = distinct !{!139, !107}
!140 = distinct !{!140, !107}
!141 = distinct !{!141, !107}
!142 = distinct !{!142, !107}
!143 = !{!104, !32, i64 16}
!144 = !{i64 0, i64 4, !126, i64 4, i64 1, !127}
!145 = !{i64 0, i64 1, !127}
!146 = distinct !{!146, !107}
!147 = !{!109, !34, i64 64}
!148 = !{!28, !30, i64 24}
!149 = !{!30, !30, i64 0}
!150 = !{!28, !29, i64 16}
!151 = !{!27, !36, i64 225}
!152 = !{!27, !8, i64 224}
!153 = !{!47, !36, i64 68}
