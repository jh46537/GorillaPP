
//------> /tools/Siemens_EDA/Catapult_Synthesis_2022.2-1008433/Mgc_home/pkgs/siflibs/ccs_in_wait_v1.v 
//------------------------------------------------------------------------------
// Catapult Synthesis - Sample I/O Port Library
//
// Copyright (c) 2003-2017 Mentor Graphics Corp.
//       All Rights Reserved
//
// This document may be used and distributed without restriction provided that
// this copyright statement is not removed from the file and that any derivative
// work contains this copyright notice.
//
// The design information contained in this file is intended to be an example
// of the functionality which the end user may study in preparation for creating
// their own custom interfaces. This design does not necessarily present a 
// complete implementation of the named protocol or standard.
//
//------------------------------------------------------------------------------


module ccs_in_wait_v1 (idat, rdy, ivld, dat, irdy, vld);

  parameter integer rscid = 1;
  parameter integer width = 8;

  output [width-1:0] idat;
  output             rdy;
  output             ivld;
  input  [width-1:0] dat;
  input              irdy;
  input              vld;

  wire   [width-1:0] idat;
  wire               rdy;
  wire               ivld;

  localparam stallOff = 0; 
  wire                  stall_ctrl;
  assign stall_ctrl = stallOff;

  assign idat = dat;
  assign rdy = irdy && !stall_ctrl;
  assign ivld = vld && !stall_ctrl;

endmodule


//------> /tools/Siemens_EDA/Catapult_Synthesis_2022.2-1008433/Mgc_home/pkgs/siflibs/ccs_out_wait_v1.v 
//------------------------------------------------------------------------------
// Catapult Synthesis - Sample I/O Port Library
//
// Copyright (c) 2003-2017 Mentor Graphics Corp.
//       All Rights Reserved
//
// This document may be used and distributed without restriction provided that
// this copyright statement is not removed from the file and that any derivative
// work contains this copyright notice.
//
// The design information contained in this file is intended to be an example
// of the functionality which the end user may study in preparation for creating
// their own custom interfaces. This design does not necessarily present a 
// complete implementation of the named protocol or standard.
//
//------------------------------------------------------------------------------


module ccs_out_wait_v1 (dat, irdy, vld, idat, rdy, ivld);

  parameter integer rscid = 1;
  parameter integer width = 8;

  output [width-1:0] dat;
  output             irdy;
  output             vld;
  input  [width-1:0] idat;
  input              rdy;
  input              ivld;

  wire   [width-1:0] dat;
  wire               irdy;
  wire               vld;

  localparam stallOff = 0; 
  wire stall_ctrl;
  assign stall_ctrl = stallOff;

  assign dat = idat;
  assign irdy = rdy && !stall_ctrl;
  assign vld = ivld && !stall_ctrl;

endmodule



//------> /tools/Siemens_EDA/Catapult_Synthesis_2022.2-1008433/Mgc_home/pkgs/siflibs/ccs_genreg_v1.v 
//------------------------------------------------------------------------------
// Catapult Synthesis - Sample I/O Port Library
//
// Copyright (c) 2003-2017 Mentor Graphics Corp.
//       All Rights Reserved
//
// This document may be used and distributed without restriction provided that
// this copyright statement is not removed from the file and that any derivative
// work contains this copyright notice.
//
// The design information contained in this file is intended to be an example
// of the functionality which the end user may study in preparation for creating
// their own custom interfaces. This design does not necessarily present a 
// complete implementation of the named protocol or standard.
//
//------------------------------------------------------------------------------

module ccs_genreg_v1 (clk, en, arst, srst, d, z);
    parameter integer width   = 1;
    parameter integer ph_clk  = 1;
    parameter integer ph_en   = 1;
    parameter integer ph_arst = 0;
    parameter integer ph_srst = 1;
    parameter         has_en  = 1'b1;

    input clk;
    input en;
    input arst;
    input srst;
    input      [width-1:0] d;
    output reg [width-1:0] z;

    //  Generate parameters
    //  ph_clk | ph_arst | has_en     Label:
    //    1        1          1       GEN_CLK1_ARST1_EN1
    //    1        1          0       GEN_CLK1_ARST1_EN0
    //    1        0          1       GEN_CLK1_ARST0_EN1
    //    1        0          0       GEN_CLK1_ARST0_EN0
    //    0        1          1       GEN_CLK0_ARST1_EN1
    //    0        1          0       GEN_CLK0_ARST1_EN0
    //    0        0          1       GEN_CLK0_ARST0_EN1
    //    0        0          0       GEN_CLK0_ARST0_EN0
    
    generate 
      // Pos edge clock, pos edge async reset, has enable
      if (ph_clk == 1 & ph_arst == 1 & has_en == 1)
      begin: GEN_CLK1_ARST1_EN1
        always @(posedge clk or posedge arst)
          if (arst == 1'b1)
            z <= {width{1'b0}};
          else if (srst == $unsigned(ph_srst))
            z <= {width{1'b0}};
          else if (en == $unsigned(ph_en))
            z <= d;
      end  //GEN_CLK1_ARST1_EN1

      // Pos edge clock, pos edge async reset, no enable
      else if (ph_clk == 1 & ph_arst == 1 & has_en == 0)
      begin: GEN_CLK1_ARST1_EN0
        always @(posedge clk or posedge arst)
          if (arst == 1'b1)
            z <= {width{1'b0}};
          else if (srst == $unsigned(ph_srst))
            z <= {width{1'b0}};
          else
            z <= d;
      end  //GEN_CLK1_ARST1_EN0

      // Pos edge clock, neg edge async reset, has enable
      else if (ph_clk == 1 & ph_arst == 0 & has_en == 1)
      begin: GEN_CLK1_ARST0_EN1
        always @(posedge clk or negedge arst)
          if (arst == 1'b0)
            z <= {width{1'b0}};
          else if (srst == $unsigned(ph_srst))
            z <= {width{1'b0}};
          else if (en == $unsigned(ph_en))
            z <= d;
      end  //GEN_CLK1_ARST0_EN1

      // Pos edge clock, neg edge async reset, no enable
      else if (ph_clk == 1 & ph_arst == 0 & has_en == 0)
      begin: GEN_CLK1_ARST0_EN0
        always @(posedge clk or negedge arst)
          if (arst == 1'b0)
            z <= {width{1'b0}};
          else if (srst == $unsigned(ph_srst))
            z <= {width{1'b0}};
          else
            z <= d;
      end  //GEN_CLK1_ARST0_EN0


      // Neg edge clock, pos edge async reset, has enable
      if (ph_clk == 0 & ph_arst == 1 & has_en == 1)
      begin: GEN_CLK0_ARST1_EN1
        always @(negedge clk or posedge arst)
          if (arst == 1'b1)
            z <= {width{1'b0}};
          else if (srst == $unsigned(ph_srst))
            z <= {width{1'b0}};
          else if (en == $unsigned(ph_en))
            z <= d;
      end  //GEN_CLK0_ARST1_EN1

      // Neg edge clock, pos edge async reset, no enable
      else if (ph_clk == 0 & ph_arst == 1 & has_en == 0)
      begin: GEN_CLK0_ARST1_EN0
        always @(negedge clk or posedge arst)
          if (arst == 1'b1)
            z <= {width{1'b0}};
          else if (srst == $unsigned(ph_srst))
            z <= {width{1'b0}};
          else
            z <= d;
      end  //GEN_CLK0_ARST1_EN0

      // Neg edge clock, neg edge async reset, has enable
      else if (ph_clk == 0 & ph_arst == 0 & has_en == 1)
      begin: GEN_CLK0_ARST0_EN1
        always @(negedge clk or negedge arst)
          if (arst == 1'b0)
            z <= {width{1'b0}};
          else if (srst == $unsigned(ph_srst))
            z <= {width{1'b0}};
          else if (en == $unsigned(ph_en))
            z <= d;
      end  //GEN_CLK0_ARST0_EN1

      // Neg edge clock, neg edge async reset, no enable
      else if (ph_clk == 0 & ph_arst == 0 & has_en == 0)
      begin: GEN_CLK0_ARST0_EN0
        always @(negedge clk or negedge arst)
          if (arst == 1'b0)
            z <= {width{1'b0}};
          else if (srst == $unsigned(ph_srst))
            z <= {width{1'b0}};
          else
            z <= d;
      end  //GEN_CLK0_ARST0_EN0
    endgenerate
endmodule


//------> /tools/Siemens_EDA/Catapult_Synthesis_2022.2-1008433/Mgc_home/pkgs/siflibs/ccs_fifo_wait_core_v5.v 
//------------------------------------------------------------------------------
// Catapult Synthesis - Sample I/O Port Library
//
// Copyright (c) 2003-2017 Mentor Graphics Corp.
//       All Rights Reserved
//
// This document may be used and distributed without restriction provided that
// this copyright statement is not removed from the file and that any derivative
// work contains this copyright notice.
//
// The design information contained in this file is intended to be an example
// of the functionality which the end user may study in preparation for creating
// their own custom interfaces. This design does not necessarily present a 
// complete implementation of the named protocol or standard.
//
//------------------------------------------------------------------------------

/*
 *            _________________________________________________
 * WRITER    |                                                 |   READER
 *           |               ccs_fifo_wait_core                |
 *           |             _____________________               |
 *        --<|  din_rdy --<|  ---------------- <|--- dout_rdy <|---
 *           |             |       FIFO         |              |
 *        ---|> din_vld ---|> ----------------  |>-- dout_vld  |>--
 *        ---|>     din ---|> ----------------  |>-- dout      |>--
 *           |             |____________________|              |
 *           |_________________________________________________|
 *
 *    rdy    - can be considered as a notFULL signal
 *    vld    - can be considered as a notEMPTY signal
 *    is_idle - clk can be safely gated
 *
 * Change History:
 *    2019-01-24 - Add assertion to verify rdy signal behavior under reset.
 *                 Fix bug in that behavior.
 */

module ccs_fifo_wait_core_v5 (clk, en, arst, srst, din_vld, din_rdy, din, dout_vld, dout_rdy, dout, sd, is_idle);

    parameter integer rscid    = 0;     // resource ID
    parameter integer width    = 8;     // fifo width
    parameter integer sz_width = 8;     // size of port for elements in fifo
    parameter integer fifo_sz  = 8;     // fifo depth
    parameter integer ph_clk   = 1;     // clock polarity 1=rising edge, 0=falling edge
    parameter integer ph_en    = 1;     // clock enable polarity
    parameter integer ph_arst  = 1;     // async reset polarity
    parameter integer ph_srst  = 1;     // sync reset polarity
    parameter integer ph_log2  = 3;     // log2(fifo_sz)

    input                 clk;
    input                 en;
    input                 arst;
    input                 srst;
    input                 din_vld;    // writer has valid data
    output                din_rdy;    // fifo ready for data (not full)
    input  [width-1:0]    din;
    output                dout_vld;   // fifo has valid data (not empty)
    input                 dout_rdy;   // reader ready for data
    output [width-1:0]    dout;
    output [sz_width-1:0] sd;
    output                is_idle;

    localparam integer fifo_b  = width * fifo_sz;
    localparam integer fifo_mx = (fifo_sz > 0) ? (fifo_sz-1) : 0 ;
    localparam integer fifo_mx_over_8 = fifo_mx / 8 ;

    reg      [fifo_mx:0] stat_pre;
    wire     [fifo_mx:0] stat;
    reg      [( (fifo_b > 0) ? fifo_b : 1)-1:0] buff_pre;
    wire     [( (fifo_b > 0) ? fifo_b : 1)-1:0] buff;
    reg      [fifo_mx:0] en_l;
    reg      [fifo_mx_over_8:0] en_l_s;

    reg      [width-1:0] buff_nxt;

    reg                  stat_nxt;
    reg                  stat_behind;
    reg                  stat_ahead;
    reg                  stat_tail;
    reg                  en_l_var;

    integer              i;
    genvar               eni;

    wire [32:0]          size_t;
    reg  [31:0]          count;
    reg  [31:0]          count_t;
    reg  [32:0]          n_elem;
    wire                 din_rdy_drv;
    wire                 dout_vld_drv;
    wire                 din_vld_int;
    wire                 hs_init;
    wire                 active;
    wire                 is_idle_drv;

    // synopsys translate_off
    reg  [31:0]          peak;
    initial
    begin
      count = 32'b0;
      peak  = 32'b0;
    end
    // synopsys translate_on

    assign din_rdy = din_rdy_drv;
    assign dout_vld = dout_vld_drv;
    assign is_idle = is_idle_drv;

    generate
    if ( fifo_sz > 0 )
    begin: FIFO_REG
      assign din_vld_int = din_vld & hs_init;
      assign din_rdy_drv = (dout_rdy | (~stat[0])) & hs_init;
      assign dout_vld_drv = din_vld_int | stat[fifo_sz-1];

      assign active = (din_vld_int & din_rdy_drv) | (dout_rdy & dout_vld_drv);
      assign is_idle_drv = (~active) & hs_init;

      assign size_t = (count - {31'b0, (dout_rdy & stat[fifo_sz-1])}) + {31'b0, din_vld_int};
      assign sd = size_t[sz_width-1:0];

      assign dout = (stat[fifo_sz-1]) ? buff[fifo_b-1:width*(fifo_sz-1)] : din;

      always @(*)
      begin: FIFOPROC
        n_elem = 33'b0;
        for (i = fifo_sz-1; i >= 0; i = i - 1)
        begin
          stat_behind = (i != 0) ? stat[i-1] : 1'b0;
          stat_ahead  = (i != (fifo_sz-1)) ? stat[i+1] : 1'b1;

          // Determine if this buffer element will have data
          stat_nxt = stat_ahead &                       // valid element ahead of this one (or head)
                       (stat_behind                     // valid element behind this one
                         | (stat[i] & (~dout_rdy))      // valid element and output not ready (in use and not shifted)
                         | (stat[i] & din_vld_int)      // valid element and input has data
                         | (din_vld_int & (~dout_rdy))  // input has data and output not ready
                       );
          stat_pre[i] = stat_nxt;

          // First empty elem when not shifting or last valid elem after shifting (assumes stat_behind == 0)
          stat_tail = stat_ahead & (((~stat[i]) & (~dout_rdy)) | (stat[i] & dout_rdy));

          if (dout_rdy & stat_behind)
          begin
            // shift valid element
            buff_nxt[0+:width] = buff[width*(i-1)+:width];
            en_l_var = 1'b1;
          end
          else if (din_vld_int & stat_tail)
          begin
            // update tail with input data
            buff_nxt = din;
            en_l_var = 1'b1;
          end
          else
          begin
            // no-op, disable register
            buff_nxt = din; // Don't care input to disabled flop
            en_l_var = 1'b0;
          end
          buff_pre[width*i+:width] = buff_nxt[0+:width];

          if (ph_en != 0)
            en_l[i] = en & en_l_var;
          else
            en_l[i] = en | ~en_l_var;

          if ((stat_ahead == 1'b1) & (stat[i] == 1'b0))
            //found tail, update the number of elements for count
            n_elem = ($unsigned(fifo_sz) - 1) - $unsigned(i);
        end //for loop

        // Enable for stat registers (partitioned into banks of eight)
        // Take care of the head first
        if (ph_en != 0)
          en_l_s[(((fifo_sz > 0) ? fifo_sz : 1)-1)/8] = en & active;
        else
          en_l_s[(((fifo_sz > 0) ? fifo_sz : 1)-1)/8] = en | ~active;

        // Now every eight
        for (i = fifo_sz-1; i >= 7; i = i - 1)
        begin
          if (($unsigned(i) % 32'd8) == 0)
          begin
            if (ph_en != 0)
              en_l_s[(i/8)-1] = en & (stat[i]) & (active);
            else
              en_l_s[(i/8)-1] = (en) | (~stat[i]) | (~active);
          end
        end

        // Update count and peak
        if ( stat[fifo_sz-1] == 1'b0 )
          count_t = 32'b0;
        else if ( stat[0] == 1'b1 )
          count_t = fifo_sz;
        else
          count_t = n_elem[31:0];
        count = count_t;
        // synopsys translate_off
        if ( peak < count )
          peak = count;
        // synopsys translate_on
      end //FIFOPROC

      // Handshake valid after reset
      ccs_genreg_v1
      #(
        .width   (1),
        .ph_clk  (ph_clk),
        .ph_en   (1),
        .ph_arst (ph_arst),
        .ph_srst (ph_srst),
        .has_en  (1'b0)
      )
      HS_INIT_REG
      (
        .clk     (clk),
        .en      (1'b1),
        .arst    (arst),
        .srst    (srst),
        .d       (1'b1),
        .z       (hs_init)
      );

      // Buffer and status registers
      for (eni = fifo_sz-1; eni >= 0; eni = eni - 1)
      begin: GEN_REGS
        ccs_genreg_v1
        #(
          .width   (1),
          .ph_clk  (ph_clk),
          .ph_en   (ph_en),
          .ph_arst (ph_arst),
          .ph_srst (ph_srst),
          .has_en  (1'b1)
        )
        STATREG
        (
          .clk     (clk),
          .en      (en_l_s[eni/8]),
          .arst    (arst),
          .srst    (srst),
          .d       (stat_pre[eni]),
          .z       (stat[eni])
        );

        ccs_genreg_v1
        #(
          .width   (width),
          .ph_clk  (ph_clk),
          .ph_en   (ph_en),
          .ph_arst (ph_arst),
          .ph_srst (ph_srst),
          .has_en  (1'b1)
        )
        BUFREG
        (
          .clk     (clk),
          .en      (en_l[eni]),
          .arst    (arst),
          .srst    (srst),
          .d       (buff_pre[width*eni+:width]),
          .z       (buff[width*eni+:width])
        );
      end

    end
    else
    begin: FEED_THRU
      assign din_rdy_drv  = dout_rdy;
      assign dout_vld_drv = din_vld;
      assign dout     = din;
      // non-blocking is not II=1 when fifo_sz=0
      assign sd = {{(sz_width-1){1'b0}}, (din_vld & ~dout_rdy)};
      assign is_idle_drv = ~(din_vld & dout_rdy);
    end
    endgenerate

`ifdef RDY_ASRT
    generate
    if (ph_clk==1)
    begin: POS_CLK_ASSERT

       property rdyAsrt ;
         @(posedge clk) (srst==ph_srst) |=> (din_rdy==0);
       endproperty
       a1Pos: assert property(rdyAsrt);

       property rdyAsrtASync ;
         @(posedge clk) (arst==ph_arst) |-> (din_rdy==0);
       endproperty
       a2Pos: assert property(rdyAsrtASync);

    end else if (ph_clk==0)
    begin: NEG_CLK_ASSERT

       property rdyAsrt ;
         @(negedge clk) ((srst==ph_srst) || (arst==ph_arst)) |=> (din_rdy==0);
       endproperty
       a1Neg: assert property(rdyAsrt);

       property rdyAsrtASync ;
         @(negedge clk) (arst==ph_arst) |-> (din_rdy==0);
       endproperty
       a2Neg: assert property(rdyAsrtASync);

    end
    endgenerate
`endif

endmodule

//------> /tools/Siemens_EDA/Catapult_Synthesis_2022.2-1008433/Mgc_home/pkgs/siflibs/ccs_pipe_v6.v 
//------------------------------------------------------------------------------
// Catapult Synthesis - Sample I/O Port Library
//
// Copyright (c) 2003-2017 Mentor Graphics Corp.
//       All Rights Reserved
//
// This document may be used and distributed without restriction provided that
// this copyright statement is not removed from the file and that any derivative
// work contains this copyright notice.
//
// The design information contained in this file is intended to be an example
// of the functionality which the end user may study in preparation for creating
// their own custom interfaces. This design does not necessarily present a 
// complete implementation of the named protocol or standard.
//
//------------------------------------------------------------------------------
/*
 *
 *            _______________________________________________
 * WRITER    |                                              |          READER
 *           |                 ccs_pipe                     |
 *           |            ______________________            |
 *        --<| din_rdy --<|  ---------------- <|---dout_rdy<|---
 *           |            |       FIFO         |            |
 *        ---|>din_vld ---|> ----------------  |>--dout_vld |>--
 *        ---|>din -------|> ----------------  |> -----dout |>--
 *           |            |____________________|            |
 *           |______________________________________________|
 *
 *    din_rdy     - can be considered as a notFULL signal
 *    dout_vld    - can be considered as a notEMPTY signal
 *    write_stall - an internal debug signal formed from din_vld & !din_rdy
 *    read_stall  - an internal debug signal formed from dout_rdy & !dout_vld
 *    is_idle     - indicates the clock can be safely gated
 *    stall_ctrl  - Stall the pipe(fifo).  Used by STALL_FLAG_SV directive
 */

module ccs_pipe_v6 (clk, en, arst, srst, din_rdy, din_vld, din, dout_rdy, dout_vld, dout, 
                    sz, sz_req, is_idle);

    parameter integer rscid    = 0; // resource ID
    parameter integer width    = 8; // fifo width
    parameter integer sz_width = 8; // width of size of elements in fifo
    parameter integer fifo_sz  = 8; // fifo depth
    parameter integer log2_sz  = 3; // log2(fifo_sz)
    parameter integer ph_clk   = 1; // clock polarity 1=rising edge, 0=falling edge
    parameter integer ph_en    = 1; // clock enable polarity
    parameter integer ph_arst  = 1; // async reset polarity
    parameter integer ph_srst  = 1; // sync reset polarity

    // clock 
    input              clk;
    input              en;
    input              arst;
    input              srst;

    // writer
    output             din_rdy;
    input              din_vld;
    input  [width-1:0] din;

    // reader
    input              dout_rdy;
    output             dout_vld;
    output [width-1:0] dout;

    // size
    output [sz_width-1:0] sz;
    input                 sz_req;
    output                is_idle;

    localparam stallOff = 0; 
    wire                  stall_ctrl;
    assign stall_ctrl = stallOff;
   
    // synopsys translate_off
    wire   write_stall;
    wire   read_stall;
    assign write_stall = (din_vld & !din_rdy) | stall_ctrl;
    assign read_stall  = (dout_rdy & !dout_vld) | stall_ctrl;
    // synopsys translate_on

    wire    tmp_din_rdy;
    assign  din_rdy = tmp_din_rdy & !stall_ctrl;
    wire    tmp_dout_vld;
    assign  dout_vld = tmp_dout_vld & !stall_ctrl;
   
    ccs_fifo_wait_core_v5
    #(
        .rscid    (rscid),
        .width    (width),
        .sz_width (sz_width),
        .fifo_sz  (fifo_sz),
        .ph_clk   (ph_clk),
        .ph_en    (ph_en),
        .ph_arst  (ph_arst),
        .ph_srst  (ph_srst),
        .ph_log2  (log2_sz)
    )
    FIFO
    (
        .clk      (clk),
        .en       (en),
        .arst     (arst),
        .srst     (srst),
        .din_vld  (din_vld & !stall_ctrl),
        .din_rdy  (tmp_din_rdy),
        .din      (din),
        .dout_vld (tmp_dout_vld),
        .dout_rdy (dout_rdy & !stall_ctrl),
        .dout     (dout),
        .sd       (sz),
        .is_idle  (is_idle)
    );

endmodule


//------> ./rtl.v 
// ----------------------------------------------------------------------
//  HLS HDL:        Verilog Netlister
//  HLS Version:    2022.2/1008433 Production Release
//  HLS Date:       Fri Aug 19 18:40:59 PDT 2022
// 
//  Generated by:   rui.ma@fpga02
//  Generated date: Thu Nov  9 08:29:59 2023
// ----------------------------------------------------------------------

// 
// ------------------------------------------------------------------
//  Design Unit:    inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_pktReassembly_stage1_fsm
//  FSM Module
// ------------------------------------------------------------------


module inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_pktReassembly_stage1_fsm
    (
  i_clk, i_rst, pktReassembly_stage1_wen, fsm_output
);
  input i_clk;
  input i_rst;
  input pktReassembly_stage1_wen;
  output [1:0] fsm_output;
  reg [1:0] fsm_output;


  // FSM State Type Declaration for inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_pktReassembly_stage1_fsm_1
  parameter
    pktReassembly_stage1_rlp_C_0 = 1'd0,
    while_C_0 = 1'd1;

  reg  state_var;
  reg  state_var_NS;


  // Interconnect Declarations for Component Instantiations 
  always @(*)
  begin : inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_pktReassembly_stage1_fsm_1
    case (state_var)
      while_C_0 : begin
        fsm_output = 2'b10;
        state_var_NS = while_C_0;
      end
      // pktReassembly_stage1_rlp_C_0
      default : begin
        fsm_output = 2'b01;
        state_var_NS = while_C_0;
      end
    endcase
  end

  always @(posedge i_clk) begin
    if ( i_rst ) begin
      state_var <= pktReassembly_stage1_rlp_C_0;
    end
    else if ( pktReassembly_stage1_wen ) begin
      state_var <= state_var_NS;
    end
  end

endmodule

// ------------------------------------------------------------------
//  Design Unit:    inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_staller
// ------------------------------------------------------------------


module inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_staller
    (
  i_clk, i_rst, pktReassembly_stage1_wen, pktReassembly_stage1_wten, stream_out_t_Push_mioi_wen_comp,
      bfu_out_t_Push_mioi_wen_comp, flow_table_read_rsp_t_Pop_mioi_wen_comp, flow_table_write_req_t_Push_mioi_wen_comp,
      unlock_req_t_Push_mioi_wen_comp, req_rsp_fifo_cnsi_wen_comp, pktReassembly_stage1_flen_unreg
);
  input i_clk;
  input i_rst;
  output pktReassembly_stage1_wen;
  output pktReassembly_stage1_wten;
  reg pktReassembly_stage1_wten;
  input stream_out_t_Push_mioi_wen_comp;
  input bfu_out_t_Push_mioi_wen_comp;
  input flow_table_read_rsp_t_Pop_mioi_wen_comp;
  input flow_table_write_req_t_Push_mioi_wen_comp;
  input unlock_req_t_Push_mioi_wen_comp;
  input req_rsp_fifo_cnsi_wen_comp;
  input pktReassembly_stage1_flen_unreg;



  // Interconnect Declarations for Component Instantiations 
  assign pktReassembly_stage1_wen = stream_out_t_Push_mioi_wen_comp & bfu_out_t_Push_mioi_wen_comp
      & flow_table_read_rsp_t_Pop_mioi_wen_comp & flow_table_write_req_t_Push_mioi_wen_comp
      & unlock_req_t_Push_mioi_wen_comp & req_rsp_fifo_cnsi_wen_comp & (~ pktReassembly_stage1_flen_unreg);
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      pktReassembly_stage1_wten <= 1'b0;
    end
    else begin
      pktReassembly_stage1_wten <= ~ pktReassembly_stage1_wen;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_req_rsp_fifo_cnsi_req_rsp_fifo_wait_dp
// ------------------------------------------------------------------


module inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_req_rsp_fifo_cnsi_req_rsp_fifo_wait_dp
    (
  i_clk, i_rst, req_rsp_fifo_cnsi_oswt_unreg, req_rsp_fifo_cnsi_bawt, req_rsp_fifo_cnsi_wen_comp,
      req_rsp_fifo_cnsi_idat_mxwt, req_rsp_fifo_cnsi_biwt, req_rsp_fifo_cnsi_bdwt,
      req_rsp_fifo_cnsi_bcwt, req_rsp_fifo_cnsi_idat
);
  input i_clk;
  input i_rst;
  input req_rsp_fifo_cnsi_oswt_unreg;
  output req_rsp_fifo_cnsi_bawt;
  output req_rsp_fifo_cnsi_wen_comp;
  output [261:0] req_rsp_fifo_cnsi_idat_mxwt;
  input req_rsp_fifo_cnsi_biwt;
  input req_rsp_fifo_cnsi_bdwt;
  output req_rsp_fifo_cnsi_bcwt;
  reg req_rsp_fifo_cnsi_bcwt;
  input [261:0] req_rsp_fifo_cnsi_idat;


  // Interconnect Declarations
  reg [261:0] req_rsp_fifo_cnsi_idat_bfwt;


  // Interconnect Declarations for Component Instantiations 
  assign req_rsp_fifo_cnsi_bawt = req_rsp_fifo_cnsi_biwt | req_rsp_fifo_cnsi_bcwt;
  assign req_rsp_fifo_cnsi_wen_comp = (~ req_rsp_fifo_cnsi_oswt_unreg) | req_rsp_fifo_cnsi_bawt;
  assign req_rsp_fifo_cnsi_idat_mxwt = MUX_v_262_2_2(req_rsp_fifo_cnsi_idat, req_rsp_fifo_cnsi_idat_bfwt,
      req_rsp_fifo_cnsi_bcwt);
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      req_rsp_fifo_cnsi_bcwt <= 1'b0;
    end
    else begin
      req_rsp_fifo_cnsi_bcwt <= ~((~(req_rsp_fifo_cnsi_bcwt | req_rsp_fifo_cnsi_biwt))
          | req_rsp_fifo_cnsi_bdwt);
    end
  end
  always @(posedge i_clk) begin
    if ( req_rsp_fifo_cnsi_biwt ) begin
      req_rsp_fifo_cnsi_idat_bfwt <= req_rsp_fifo_cnsi_idat;
    end
  end

  function automatic [261:0] MUX_v_262_2_2;
    input [261:0] input_0;
    input [261:0] input_1;
    input  sel;
    reg [261:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_262_2_2 = result;
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_req_rsp_fifo_cnsi_req_rsp_fifo_wait_ctrl
// ------------------------------------------------------------------


module inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_req_rsp_fifo_cnsi_req_rsp_fifo_wait_ctrl
    (
  pktReassembly_stage1_wen, req_rsp_fifo_cnsi_oswt_unreg, req_rsp_fifo_cnsi_iswt0,
      req_rsp_fifo_cnsi_biwt, req_rsp_fifo_cnsi_bdwt, req_rsp_fifo_cnsi_bcwt, req_rsp_fifo_cnsi_irdy_pktReassembly_stage1_sct,
      req_rsp_fifo_cnsi_ivld
);
  input pktReassembly_stage1_wen;
  input req_rsp_fifo_cnsi_oswt_unreg;
  input req_rsp_fifo_cnsi_iswt0;
  output req_rsp_fifo_cnsi_biwt;
  output req_rsp_fifo_cnsi_bdwt;
  input req_rsp_fifo_cnsi_bcwt;
  output req_rsp_fifo_cnsi_irdy_pktReassembly_stage1_sct;
  input req_rsp_fifo_cnsi_ivld;


  // Interconnect Declarations
  wire req_rsp_fifo_cnsi_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign req_rsp_fifo_cnsi_bdwt = req_rsp_fifo_cnsi_oswt_unreg & pktReassembly_stage1_wen;
  assign req_rsp_fifo_cnsi_biwt = req_rsp_fifo_cnsi_ogwt & req_rsp_fifo_cnsi_ivld;
  assign req_rsp_fifo_cnsi_ogwt = req_rsp_fifo_cnsi_iswt0 & (~ req_rsp_fifo_cnsi_bcwt);
  assign req_rsp_fifo_cnsi_irdy_pktReassembly_stage1_sct = req_rsp_fifo_cnsi_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_unlock_req_t_Push_mioi_unlock_req_t_Push_mio_wait_dp
// ------------------------------------------------------------------


module inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_unlock_req_t_Push_mioi_unlock_req_t_Push_mio_wait_dp
    (
  i_clk, i_rst, unlock_req_t_Push_mioi_oswt_unreg, unlock_req_t_Push_mioi_bawt, unlock_req_t_Push_mioi_wen_comp,
      unlock_req_t_Push_mioi_biwt, unlock_req_t_Push_mioi_bdwt
);
  input i_clk;
  input i_rst;
  input unlock_req_t_Push_mioi_oswt_unreg;
  output unlock_req_t_Push_mioi_bawt;
  output unlock_req_t_Push_mioi_wen_comp;
  input unlock_req_t_Push_mioi_biwt;
  input unlock_req_t_Push_mioi_bdwt;


  // Interconnect Declarations
  reg unlock_req_t_Push_mioi_bcwt;


  // Interconnect Declarations for Component Instantiations 
  assign unlock_req_t_Push_mioi_bawt = unlock_req_t_Push_mioi_biwt | unlock_req_t_Push_mioi_bcwt;
  assign unlock_req_t_Push_mioi_wen_comp = (~ unlock_req_t_Push_mioi_oswt_unreg)
      | unlock_req_t_Push_mioi_bawt;
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      unlock_req_t_Push_mioi_bcwt <= 1'b0;
    end
    else begin
      unlock_req_t_Push_mioi_bcwt <= ~((~(unlock_req_t_Push_mioi_bcwt | unlock_req_t_Push_mioi_biwt))
          | unlock_req_t_Push_mioi_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_unlock_req_t_Push_mioi_unlock_req_t_Push_mio_wait_ctrl
// ------------------------------------------------------------------


module inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_unlock_req_t_Push_mioi_unlock_req_t_Push_mio_wait_ctrl
    (
  i_clk, i_rst, pktReassembly_stage1_wen, pktReassembly_stage1_wten, unlock_req_t_Push_mioi_oswt_unreg,
      unlock_req_t_Push_mioi_iswt0, unlock_req_t_Push_mioi_biwt, unlock_req_t_Push_mioi_bdwt,
      unlock_req_t_Push_mioi_ivld_pktReassembly_stage1_sct, unlock_req_t_Push_mioi_irdy
);
  input i_clk;
  input i_rst;
  input pktReassembly_stage1_wen;
  input pktReassembly_stage1_wten;
  input unlock_req_t_Push_mioi_oswt_unreg;
  input unlock_req_t_Push_mioi_iswt0;
  output unlock_req_t_Push_mioi_biwt;
  output unlock_req_t_Push_mioi_bdwt;
  output unlock_req_t_Push_mioi_ivld_pktReassembly_stage1_sct;
  input unlock_req_t_Push_mioi_irdy;


  // Interconnect Declarations
  wire unlock_req_t_Push_mioi_ogwt;
  reg unlock_req_t_Push_mioi_icwt;


  // Interconnect Declarations for Component Instantiations 
  assign unlock_req_t_Push_mioi_bdwt = unlock_req_t_Push_mioi_oswt_unreg & pktReassembly_stage1_wen;
  assign unlock_req_t_Push_mioi_biwt = unlock_req_t_Push_mioi_ogwt & unlock_req_t_Push_mioi_irdy;
  assign unlock_req_t_Push_mioi_ogwt = ((~ pktReassembly_stage1_wten) & unlock_req_t_Push_mioi_iswt0)
      | unlock_req_t_Push_mioi_icwt;
  assign unlock_req_t_Push_mioi_ivld_pktReassembly_stage1_sct = unlock_req_t_Push_mioi_ogwt;
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      unlock_req_t_Push_mioi_icwt <= 1'b0;
    end
    else begin
      unlock_req_t_Push_mioi_icwt <= unlock_req_t_Push_mioi_ogwt & (~ unlock_req_t_Push_mioi_biwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_flow_table_write_req_t_Push_mioi_flow_table_write_req_t_Push_mio_wait_dp
// ------------------------------------------------------------------


module inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_flow_table_write_req_t_Push_mioi_flow_table_write_req_t_Push_mio_wait_dp
    (
  i_clk, i_rst, flow_table_write_req_t_Push_mioi_oswt_unreg, flow_table_write_req_t_Push_mioi_bawt,
      flow_table_write_req_t_Push_mioi_wen_comp, flow_table_write_req_t_Push_mioi_biwt,
      flow_table_write_req_t_Push_mioi_bdwt
);
  input i_clk;
  input i_rst;
  input flow_table_write_req_t_Push_mioi_oswt_unreg;
  output flow_table_write_req_t_Push_mioi_bawt;
  output flow_table_write_req_t_Push_mioi_wen_comp;
  input flow_table_write_req_t_Push_mioi_biwt;
  input flow_table_write_req_t_Push_mioi_bdwt;


  // Interconnect Declarations
  reg flow_table_write_req_t_Push_mioi_bcwt;


  // Interconnect Declarations for Component Instantiations 
  assign flow_table_write_req_t_Push_mioi_bawt = flow_table_write_req_t_Push_mioi_biwt
      | flow_table_write_req_t_Push_mioi_bcwt;
  assign flow_table_write_req_t_Push_mioi_wen_comp = (~ flow_table_write_req_t_Push_mioi_oswt_unreg)
      | flow_table_write_req_t_Push_mioi_bawt;
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      flow_table_write_req_t_Push_mioi_bcwt <= 1'b0;
    end
    else begin
      flow_table_write_req_t_Push_mioi_bcwt <= ~((~(flow_table_write_req_t_Push_mioi_bcwt
          | flow_table_write_req_t_Push_mioi_biwt)) | flow_table_write_req_t_Push_mioi_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_flow_table_write_req_t_Push_mioi_flow_table_write_req_t_Push_mio_wait_ctrl
// ------------------------------------------------------------------


module inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_flow_table_write_req_t_Push_mioi_flow_table_write_req_t_Push_mio_wait_ctrl
    (
  i_clk, i_rst, pktReassembly_stage1_wen, pktReassembly_stage1_wten, flow_table_write_req_t_Push_mioi_oswt_unreg,
      flow_table_write_req_t_Push_mioi_iswt0, flow_table_write_req_t_Push_mioi_biwt,
      flow_table_write_req_t_Push_mioi_bdwt, flow_table_write_req_t_Push_mioi_ivld_pktReassembly_stage1_sct,
      flow_table_write_req_t_Push_mioi_irdy
);
  input i_clk;
  input i_rst;
  input pktReassembly_stage1_wen;
  input pktReassembly_stage1_wten;
  input flow_table_write_req_t_Push_mioi_oswt_unreg;
  input flow_table_write_req_t_Push_mioi_iswt0;
  output flow_table_write_req_t_Push_mioi_biwt;
  output flow_table_write_req_t_Push_mioi_bdwt;
  output flow_table_write_req_t_Push_mioi_ivld_pktReassembly_stage1_sct;
  input flow_table_write_req_t_Push_mioi_irdy;


  // Interconnect Declarations
  wire flow_table_write_req_t_Push_mioi_ogwt;
  reg flow_table_write_req_t_Push_mioi_icwt;


  // Interconnect Declarations for Component Instantiations 
  assign flow_table_write_req_t_Push_mioi_bdwt = flow_table_write_req_t_Push_mioi_oswt_unreg
      & pktReassembly_stage1_wen;
  assign flow_table_write_req_t_Push_mioi_biwt = flow_table_write_req_t_Push_mioi_ogwt
      & flow_table_write_req_t_Push_mioi_irdy;
  assign flow_table_write_req_t_Push_mioi_ogwt = ((~ pktReassembly_stage1_wten) &
      flow_table_write_req_t_Push_mioi_iswt0) | flow_table_write_req_t_Push_mioi_icwt;
  assign flow_table_write_req_t_Push_mioi_ivld_pktReassembly_stage1_sct = flow_table_write_req_t_Push_mioi_ogwt;
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      flow_table_write_req_t_Push_mioi_icwt <= 1'b0;
    end
    else begin
      flow_table_write_req_t_Push_mioi_icwt <= flow_table_write_req_t_Push_mioi_ogwt
          & (~ flow_table_write_req_t_Push_mioi_biwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_flow_table_read_rsp_t_Pop_mioi_flow_table_read_rsp_t_Pop_mio_wait_dp
// ------------------------------------------------------------------


module inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_flow_table_read_rsp_t_Pop_mioi_flow_table_read_rsp_t_Pop_mio_wait_dp
    (
  i_clk, i_rst, flow_table_read_rsp_t_Pop_mioi_oswt_unreg, flow_table_read_rsp_t_Pop_mioi_bawt,
      flow_table_read_rsp_t_Pop_mioi_wen_comp, flow_table_read_rsp_t_Pop_mioi_idat_mxwt,
      flow_table_read_rsp_t_Pop_mioi_biwt, flow_table_read_rsp_t_Pop_mioi_bdwt, flow_table_read_rsp_t_Pop_mioi_idat
);
  input i_clk;
  input i_rst;
  input flow_table_read_rsp_t_Pop_mioi_oswt_unreg;
  output flow_table_read_rsp_t_Pop_mioi_bawt;
  output flow_table_read_rsp_t_Pop_mioi_wen_comp;
  output [521:0] flow_table_read_rsp_t_Pop_mioi_idat_mxwt;
  input flow_table_read_rsp_t_Pop_mioi_biwt;
  input flow_table_read_rsp_t_Pop_mioi_bdwt;
  input [528:0] flow_table_read_rsp_t_Pop_mioi_idat;


  // Interconnect Declarations
  reg flow_table_read_rsp_t_Pop_mioi_bcwt;
  reg [517:0] flow_table_read_rsp_t_Pop_mioi_idat_bfwt_528_11;
  reg [3:0] flow_table_read_rsp_t_Pop_mioi_idat_bfwt_3_0;

  wire[517:0] flow_table_read_rsp_read_mux_2_nl;
  wire[3:0] flow_table_read_rsp_read_mux_3_nl;

  // Interconnect Declarations for Component Instantiations 
  assign flow_table_read_rsp_t_Pop_mioi_bawt = flow_table_read_rsp_t_Pop_mioi_biwt
      | flow_table_read_rsp_t_Pop_mioi_bcwt;
  assign flow_table_read_rsp_t_Pop_mioi_wen_comp = (~ flow_table_read_rsp_t_Pop_mioi_oswt_unreg)
      | flow_table_read_rsp_t_Pop_mioi_bawt;
  assign flow_table_read_rsp_read_mux_2_nl = MUX_v_518_2_2((flow_table_read_rsp_t_Pop_mioi_idat[528:11]),
      flow_table_read_rsp_t_Pop_mioi_idat_bfwt_528_11, flow_table_read_rsp_t_Pop_mioi_bcwt);
  assign flow_table_read_rsp_read_mux_3_nl = MUX_v_4_2_2((flow_table_read_rsp_t_Pop_mioi_idat[3:0]),
      flow_table_read_rsp_t_Pop_mioi_idat_bfwt_3_0, flow_table_read_rsp_t_Pop_mioi_bcwt);
  assign flow_table_read_rsp_t_Pop_mioi_idat_mxwt = {flow_table_read_rsp_read_mux_2_nl
      , flow_table_read_rsp_read_mux_3_nl};
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      flow_table_read_rsp_t_Pop_mioi_bcwt <= 1'b0;
    end
    else begin
      flow_table_read_rsp_t_Pop_mioi_bcwt <= ~((~(flow_table_read_rsp_t_Pop_mioi_bcwt
          | flow_table_read_rsp_t_Pop_mioi_biwt)) | flow_table_read_rsp_t_Pop_mioi_bdwt);
    end
  end
  always @(posedge i_clk) begin
    if ( flow_table_read_rsp_t_Pop_mioi_biwt ) begin
      flow_table_read_rsp_t_Pop_mioi_idat_bfwt_528_11 <= flow_table_read_rsp_t_Pop_mioi_idat[528:11];
      flow_table_read_rsp_t_Pop_mioi_idat_bfwt_3_0 <= flow_table_read_rsp_t_Pop_mioi_idat[3:0];
    end
  end

  function automatic [3:0] MUX_v_4_2_2;
    input [3:0] input_0;
    input [3:0] input_1;
    input  sel;
    reg [3:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_4_2_2 = result;
  end
  endfunction


  function automatic [517:0] MUX_v_518_2_2;
    input [517:0] input_0;
    input [517:0] input_1;
    input  sel;
    reg [517:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_518_2_2 = result;
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_flow_table_read_rsp_t_Pop_mioi_flow_table_read_rsp_t_Pop_mio_wait_ctrl
// ------------------------------------------------------------------


module inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_flow_table_read_rsp_t_Pop_mioi_flow_table_read_rsp_t_Pop_mio_wait_ctrl
    (
  i_clk, i_rst, pktReassembly_stage1_wen, pktReassembly_stage1_wten, flow_table_read_rsp_t_Pop_mioi_oswt_unreg,
      flow_table_read_rsp_t_Pop_mioi_iswt0, flow_table_read_rsp_t_Pop_mioi_biwt,
      flow_table_read_rsp_t_Pop_mioi_bdwt, flow_table_read_rsp_t_Pop_mioi_ivld, flow_table_read_rsp_t_Pop_mioi_irdy_pktReassembly_stage1_sct
);
  input i_clk;
  input i_rst;
  input pktReassembly_stage1_wen;
  input pktReassembly_stage1_wten;
  input flow_table_read_rsp_t_Pop_mioi_oswt_unreg;
  input flow_table_read_rsp_t_Pop_mioi_iswt0;
  output flow_table_read_rsp_t_Pop_mioi_biwt;
  output flow_table_read_rsp_t_Pop_mioi_bdwt;
  input flow_table_read_rsp_t_Pop_mioi_ivld;
  output flow_table_read_rsp_t_Pop_mioi_irdy_pktReassembly_stage1_sct;


  // Interconnect Declarations
  wire flow_table_read_rsp_t_Pop_mioi_ogwt;
  reg flow_table_read_rsp_t_Pop_mioi_icwt;


  // Interconnect Declarations for Component Instantiations 
  assign flow_table_read_rsp_t_Pop_mioi_bdwt = flow_table_read_rsp_t_Pop_mioi_oswt_unreg
      & pktReassembly_stage1_wen;
  assign flow_table_read_rsp_t_Pop_mioi_biwt = flow_table_read_rsp_t_Pop_mioi_ogwt
      & flow_table_read_rsp_t_Pop_mioi_ivld;
  assign flow_table_read_rsp_t_Pop_mioi_ogwt = ((~ pktReassembly_stage1_wten) & flow_table_read_rsp_t_Pop_mioi_iswt0)
      | flow_table_read_rsp_t_Pop_mioi_icwt;
  assign flow_table_read_rsp_t_Pop_mioi_irdy_pktReassembly_stage1_sct = flow_table_read_rsp_t_Pop_mioi_ogwt;
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      flow_table_read_rsp_t_Pop_mioi_icwt <= 1'b0;
    end
    else begin
      flow_table_read_rsp_t_Pop_mioi_icwt <= flow_table_read_rsp_t_Pop_mioi_ogwt
          & (~ flow_table_read_rsp_t_Pop_mioi_biwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_bfu_out_t_Push_mioi_bfu_out_t_Push_mio_wait_dp
// ------------------------------------------------------------------


module inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_bfu_out_t_Push_mioi_bfu_out_t_Push_mio_wait_dp
    (
  i_clk, i_rst, bfu_out_t_Push_mioi_oswt_unreg, bfu_out_t_Push_mioi_bawt, bfu_out_t_Push_mioi_wen_comp,
      bfu_out_t_Push_mioi_biwt, bfu_out_t_Push_mioi_bdwt
);
  input i_clk;
  input i_rst;
  input bfu_out_t_Push_mioi_oswt_unreg;
  output bfu_out_t_Push_mioi_bawt;
  output bfu_out_t_Push_mioi_wen_comp;
  input bfu_out_t_Push_mioi_biwt;
  input bfu_out_t_Push_mioi_bdwt;


  // Interconnect Declarations
  reg bfu_out_t_Push_mioi_bcwt;


  // Interconnect Declarations for Component Instantiations 
  assign bfu_out_t_Push_mioi_bawt = bfu_out_t_Push_mioi_biwt | bfu_out_t_Push_mioi_bcwt;
  assign bfu_out_t_Push_mioi_wen_comp = (~ bfu_out_t_Push_mioi_oswt_unreg) | bfu_out_t_Push_mioi_bawt;
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      bfu_out_t_Push_mioi_bcwt <= 1'b0;
    end
    else begin
      bfu_out_t_Push_mioi_bcwt <= ~((~(bfu_out_t_Push_mioi_bcwt | bfu_out_t_Push_mioi_biwt))
          | bfu_out_t_Push_mioi_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_bfu_out_t_Push_mioi_bfu_out_t_Push_mio_wait_ctrl
// ------------------------------------------------------------------


module inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_bfu_out_t_Push_mioi_bfu_out_t_Push_mio_wait_ctrl
    (
  i_clk, i_rst, pktReassembly_stage1_wen, pktReassembly_stage1_wten, bfu_out_t_Push_mioi_oswt_unreg,
      bfu_out_t_Push_mioi_iswt0, bfu_out_t_Push_mioi_biwt, bfu_out_t_Push_mioi_bdwt,
      bfu_out_t_Push_mioi_ivld_pktReassembly_stage1_sct, bfu_out_t_Push_mioi_irdy
);
  input i_clk;
  input i_rst;
  input pktReassembly_stage1_wen;
  input pktReassembly_stage1_wten;
  input bfu_out_t_Push_mioi_oswt_unreg;
  input bfu_out_t_Push_mioi_iswt0;
  output bfu_out_t_Push_mioi_biwt;
  output bfu_out_t_Push_mioi_bdwt;
  output bfu_out_t_Push_mioi_ivld_pktReassembly_stage1_sct;
  input bfu_out_t_Push_mioi_irdy;


  // Interconnect Declarations
  wire bfu_out_t_Push_mioi_ogwt;
  reg bfu_out_t_Push_mioi_icwt;


  // Interconnect Declarations for Component Instantiations 
  assign bfu_out_t_Push_mioi_bdwt = bfu_out_t_Push_mioi_oswt_unreg & pktReassembly_stage1_wen;
  assign bfu_out_t_Push_mioi_biwt = bfu_out_t_Push_mioi_ogwt & bfu_out_t_Push_mioi_irdy;
  assign bfu_out_t_Push_mioi_ogwt = ((~ pktReassembly_stage1_wten) & bfu_out_t_Push_mioi_iswt0)
      | bfu_out_t_Push_mioi_icwt;
  assign bfu_out_t_Push_mioi_ivld_pktReassembly_stage1_sct = bfu_out_t_Push_mioi_ogwt;
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      bfu_out_t_Push_mioi_icwt <= 1'b0;
    end
    else begin
      bfu_out_t_Push_mioi_icwt <= bfu_out_t_Push_mioi_ogwt & (~ bfu_out_t_Push_mioi_biwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_stream_out_t_Push_mioi_stream_out_t_Push_mio_wait_dp
// ------------------------------------------------------------------


module inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_stream_out_t_Push_mioi_stream_out_t_Push_mio_wait_dp
    (
  i_clk, i_rst, stream_out_t_Push_mioi_oswt_unreg, stream_out_t_Push_mioi_bawt, stream_out_t_Push_mioi_wen_comp,
      stream_out_t_Push_mioi_biwt, stream_out_t_Push_mioi_bdwt
);
  input i_clk;
  input i_rst;
  input stream_out_t_Push_mioi_oswt_unreg;
  output stream_out_t_Push_mioi_bawt;
  output stream_out_t_Push_mioi_wen_comp;
  input stream_out_t_Push_mioi_biwt;
  input stream_out_t_Push_mioi_bdwt;


  // Interconnect Declarations
  reg stream_out_t_Push_mioi_bcwt;


  // Interconnect Declarations for Component Instantiations 
  assign stream_out_t_Push_mioi_bawt = stream_out_t_Push_mioi_biwt | stream_out_t_Push_mioi_bcwt;
  assign stream_out_t_Push_mioi_wen_comp = (~ stream_out_t_Push_mioi_oswt_unreg)
      | stream_out_t_Push_mioi_bawt;
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      stream_out_t_Push_mioi_bcwt <= 1'b0;
    end
    else begin
      stream_out_t_Push_mioi_bcwt <= ~((~(stream_out_t_Push_mioi_bcwt | stream_out_t_Push_mioi_biwt))
          | stream_out_t_Push_mioi_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_stream_out_t_Push_mioi_stream_out_t_Push_mio_wait_ctrl
// ------------------------------------------------------------------


module inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_stream_out_t_Push_mioi_stream_out_t_Push_mio_wait_ctrl
    (
  i_clk, i_rst, pktReassembly_stage1_wen, pktReassembly_stage1_wten, stream_out_t_Push_mioi_oswt_unreg,
      stream_out_t_Push_mioi_iswt0, stream_out_t_Push_mioi_biwt, stream_out_t_Push_mioi_bdwt,
      stream_out_t_Push_mioi_ivld_pktReassembly_stage1_sct, stream_out_t_Push_mioi_irdy
);
  input i_clk;
  input i_rst;
  input pktReassembly_stage1_wen;
  input pktReassembly_stage1_wten;
  input stream_out_t_Push_mioi_oswt_unreg;
  input stream_out_t_Push_mioi_iswt0;
  output stream_out_t_Push_mioi_biwt;
  output stream_out_t_Push_mioi_bdwt;
  output stream_out_t_Push_mioi_ivld_pktReassembly_stage1_sct;
  input stream_out_t_Push_mioi_irdy;


  // Interconnect Declarations
  wire stream_out_t_Push_mioi_ogwt;
  reg stream_out_t_Push_mioi_icwt;


  // Interconnect Declarations for Component Instantiations 
  assign stream_out_t_Push_mioi_bdwt = stream_out_t_Push_mioi_oswt_unreg & pktReassembly_stage1_wen;
  assign stream_out_t_Push_mioi_biwt = stream_out_t_Push_mioi_ogwt & stream_out_t_Push_mioi_irdy;
  assign stream_out_t_Push_mioi_ogwt = ((~ pktReassembly_stage1_wten) & stream_out_t_Push_mioi_iswt0)
      | stream_out_t_Push_mioi_icwt;
  assign stream_out_t_Push_mioi_ivld_pktReassembly_stage1_sct = stream_out_t_Push_mioi_ogwt;
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      stream_out_t_Push_mioi_icwt <= 1'b0;
    end
    else begin
      stream_out_t_Push_mioi_icwt <= stream_out_t_Push_mioi_ogwt & (~ stream_out_t_Push_mioi_biwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    inputUnit_pktReassembly_pktReassembly_stage0_pktReassembly_stage0_pktReassembly_stage0_fsm
//  FSM Module
// ------------------------------------------------------------------


module inputUnit_pktReassembly_pktReassembly_stage0_pktReassembly_stage0_pktReassembly_stage0_fsm
    (
  i_clk, i_rst, pktReassembly_stage0_wen, fsm_output
);
  input i_clk;
  input i_rst;
  input pktReassembly_stage0_wen;
  output [1:0] fsm_output;
  reg [1:0] fsm_output;


  // FSM State Type Declaration for inputUnit_pktReassembly_pktReassembly_stage0_pktReassembly_stage0_pktReassembly_stage0_fsm_1
  parameter
    pktReassembly_stage0_rlp_C_0 = 1'd0,
    while_C_0 = 1'd1;

  reg  state_var;
  reg  state_var_NS;


  // Interconnect Declarations for Component Instantiations 
  always @(*)
  begin : inputUnit_pktReassembly_pktReassembly_stage0_pktReassembly_stage0_pktReassembly_stage0_fsm_1
    case (state_var)
      while_C_0 : begin
        fsm_output = 2'b10;
        state_var_NS = while_C_0;
      end
      // pktReassembly_stage0_rlp_C_0
      default : begin
        fsm_output = 2'b01;
        state_var_NS = while_C_0;
      end
    endcase
  end

  always @(posedge i_clk) begin
    if ( i_rst ) begin
      state_var <= pktReassembly_stage0_rlp_C_0;
    end
    else if ( pktReassembly_stage0_wen ) begin
      state_var <= state_var_NS;
    end
  end

endmodule

// ------------------------------------------------------------------
//  Design Unit:    inputUnit_pktReassembly_pktReassembly_stage0_pktReassembly_stage0_staller
// ------------------------------------------------------------------


module inputUnit_pktReassembly_pktReassembly_stage0_pktReassembly_stage0_staller
    (
  i_clk, i_rst, pktReassembly_stage0_wen, pktReassembly_stage0_wten, cmd_in_t_Pop_mioi_wen_comp,
      stream_in_t_Pop_mioi_wen_comp, flow_table_read_req_t_Push_mioi_wen_comp, req_rsp_fifo_cnsi_wen_comp,
      pktReassembly_stage0_flen_unreg
);
  input i_clk;
  input i_rst;
  output pktReassembly_stage0_wen;
  output pktReassembly_stage0_wten;
  reg pktReassembly_stage0_wten;
  input cmd_in_t_Pop_mioi_wen_comp;
  input stream_in_t_Pop_mioi_wen_comp;
  input flow_table_read_req_t_Push_mioi_wen_comp;
  input req_rsp_fifo_cnsi_wen_comp;
  input pktReassembly_stage0_flen_unreg;



  // Interconnect Declarations for Component Instantiations 
  assign pktReassembly_stage0_wen = cmd_in_t_Pop_mioi_wen_comp & stream_in_t_Pop_mioi_wen_comp
      & flow_table_read_req_t_Push_mioi_wen_comp & req_rsp_fifo_cnsi_wen_comp & (~
      pktReassembly_stage0_flen_unreg);
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      pktReassembly_stage0_wten <= 1'b0;
    end
    else begin
      pktReassembly_stage0_wten <= ~ pktReassembly_stage0_wen;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    inputUnit_pktReassembly_pktReassembly_stage0_pktReassembly_stage0_req_rsp_fifo_cnsi_req_rsp_fifo_wait_dp
// ------------------------------------------------------------------


module inputUnit_pktReassembly_pktReassembly_stage0_pktReassembly_stage0_req_rsp_fifo_cnsi_req_rsp_fifo_wait_dp
    (
  i_clk, i_rst, req_rsp_fifo_cnsi_oswt_unreg, req_rsp_fifo_cnsi_bawt, req_rsp_fifo_cnsi_wen_comp,
      req_rsp_fifo_cnsi_biwt, req_rsp_fifo_cnsi_bdwt, req_rsp_fifo_cnsi_bcwt
);
  input i_clk;
  input i_rst;
  input req_rsp_fifo_cnsi_oswt_unreg;
  output req_rsp_fifo_cnsi_bawt;
  output req_rsp_fifo_cnsi_wen_comp;
  input req_rsp_fifo_cnsi_biwt;
  input req_rsp_fifo_cnsi_bdwt;
  output req_rsp_fifo_cnsi_bcwt;
  reg req_rsp_fifo_cnsi_bcwt;



  // Interconnect Declarations for Component Instantiations 
  assign req_rsp_fifo_cnsi_bawt = req_rsp_fifo_cnsi_biwt | req_rsp_fifo_cnsi_bcwt;
  assign req_rsp_fifo_cnsi_wen_comp = (~ req_rsp_fifo_cnsi_oswt_unreg) | req_rsp_fifo_cnsi_bawt;
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      req_rsp_fifo_cnsi_bcwt <= 1'b0;
    end
    else begin
      req_rsp_fifo_cnsi_bcwt <= ~((~(req_rsp_fifo_cnsi_bcwt | req_rsp_fifo_cnsi_biwt))
          | req_rsp_fifo_cnsi_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    inputUnit_pktReassembly_pktReassembly_stage0_pktReassembly_stage0_req_rsp_fifo_cnsi_req_rsp_fifo_wait_ctrl
// ------------------------------------------------------------------


module inputUnit_pktReassembly_pktReassembly_stage0_pktReassembly_stage0_req_rsp_fifo_cnsi_req_rsp_fifo_wait_ctrl
    (
  pktReassembly_stage0_wen, req_rsp_fifo_cnsi_oswt_unreg, req_rsp_fifo_cnsi_iswt0,
      req_rsp_fifo_cnsi_biwt, req_rsp_fifo_cnsi_bdwt, req_rsp_fifo_cnsi_bcwt, req_rsp_fifo_cnsi_irdy,
      req_rsp_fifo_cnsi_ivld_pktReassembly_stage0_sct
);
  input pktReassembly_stage0_wen;
  input req_rsp_fifo_cnsi_oswt_unreg;
  input req_rsp_fifo_cnsi_iswt0;
  output req_rsp_fifo_cnsi_biwt;
  output req_rsp_fifo_cnsi_bdwt;
  input req_rsp_fifo_cnsi_bcwt;
  input req_rsp_fifo_cnsi_irdy;
  output req_rsp_fifo_cnsi_ivld_pktReassembly_stage0_sct;


  // Interconnect Declarations
  wire req_rsp_fifo_cnsi_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign req_rsp_fifo_cnsi_bdwt = req_rsp_fifo_cnsi_oswt_unreg & pktReassembly_stage0_wen;
  assign req_rsp_fifo_cnsi_biwt = req_rsp_fifo_cnsi_ogwt & req_rsp_fifo_cnsi_irdy;
  assign req_rsp_fifo_cnsi_ogwt = req_rsp_fifo_cnsi_iswt0 & (~ req_rsp_fifo_cnsi_bcwt);
  assign req_rsp_fifo_cnsi_ivld_pktReassembly_stage0_sct = req_rsp_fifo_cnsi_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    inputUnit_pktReassembly_pktReassembly_stage0_pktReassembly_stage0_flow_table_read_req_t_Push_mioi_flow_table_read_req_t_Push_mio_wait_dp
// ------------------------------------------------------------------


module inputUnit_pktReassembly_pktReassembly_stage0_pktReassembly_stage0_flow_table_read_req_t_Push_mioi_flow_table_read_req_t_Push_mio_wait_dp
    (
  i_clk, i_rst, flow_table_read_req_t_Push_mioi_oswt_unreg, flow_table_read_req_t_Push_mioi_bawt,
      flow_table_read_req_t_Push_mioi_wen_comp, flow_table_read_req_t_Push_mioi_biwt,
      flow_table_read_req_t_Push_mioi_bdwt
);
  input i_clk;
  input i_rst;
  input flow_table_read_req_t_Push_mioi_oswt_unreg;
  output flow_table_read_req_t_Push_mioi_bawt;
  output flow_table_read_req_t_Push_mioi_wen_comp;
  input flow_table_read_req_t_Push_mioi_biwt;
  input flow_table_read_req_t_Push_mioi_bdwt;


  // Interconnect Declarations
  reg flow_table_read_req_t_Push_mioi_bcwt;


  // Interconnect Declarations for Component Instantiations 
  assign flow_table_read_req_t_Push_mioi_bawt = flow_table_read_req_t_Push_mioi_biwt
      | flow_table_read_req_t_Push_mioi_bcwt;
  assign flow_table_read_req_t_Push_mioi_wen_comp = (~ flow_table_read_req_t_Push_mioi_oswt_unreg)
      | flow_table_read_req_t_Push_mioi_bawt;
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      flow_table_read_req_t_Push_mioi_bcwt <= 1'b0;
    end
    else begin
      flow_table_read_req_t_Push_mioi_bcwt <= ~((~(flow_table_read_req_t_Push_mioi_bcwt
          | flow_table_read_req_t_Push_mioi_biwt)) | flow_table_read_req_t_Push_mioi_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    inputUnit_pktReassembly_pktReassembly_stage0_pktReassembly_stage0_flow_table_read_req_t_Push_mioi_flow_table_read_req_t_Push_mio_wait_ctrl
// ------------------------------------------------------------------


module inputUnit_pktReassembly_pktReassembly_stage0_pktReassembly_stage0_flow_table_read_req_t_Push_mioi_flow_table_read_req_t_Push_mio_wait_ctrl
    (
  i_clk, i_rst, pktReassembly_stage0_wen, pktReassembly_stage0_wten, flow_table_read_req_t_Push_mioi_oswt_unreg,
      flow_table_read_req_t_Push_mioi_iswt0, flow_table_read_req_t_Push_mioi_biwt,
      flow_table_read_req_t_Push_mioi_bdwt, flow_table_read_req_t_Push_mioi_ivld_pktReassembly_stage0_sct,
      flow_table_read_req_t_Push_mioi_irdy
);
  input i_clk;
  input i_rst;
  input pktReassembly_stage0_wen;
  input pktReassembly_stage0_wten;
  input flow_table_read_req_t_Push_mioi_oswt_unreg;
  input flow_table_read_req_t_Push_mioi_iswt0;
  output flow_table_read_req_t_Push_mioi_biwt;
  output flow_table_read_req_t_Push_mioi_bdwt;
  output flow_table_read_req_t_Push_mioi_ivld_pktReassembly_stage0_sct;
  input flow_table_read_req_t_Push_mioi_irdy;


  // Interconnect Declarations
  wire flow_table_read_req_t_Push_mioi_ogwt;
  reg flow_table_read_req_t_Push_mioi_icwt;


  // Interconnect Declarations for Component Instantiations 
  assign flow_table_read_req_t_Push_mioi_bdwt = flow_table_read_req_t_Push_mioi_oswt_unreg
      & pktReassembly_stage0_wen;
  assign flow_table_read_req_t_Push_mioi_biwt = flow_table_read_req_t_Push_mioi_ogwt
      & flow_table_read_req_t_Push_mioi_irdy;
  assign flow_table_read_req_t_Push_mioi_ogwt = ((~ pktReassembly_stage0_wten) &
      flow_table_read_req_t_Push_mioi_iswt0) | flow_table_read_req_t_Push_mioi_icwt;
  assign flow_table_read_req_t_Push_mioi_ivld_pktReassembly_stage0_sct = flow_table_read_req_t_Push_mioi_ogwt;
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      flow_table_read_req_t_Push_mioi_icwt <= 1'b0;
    end
    else begin
      flow_table_read_req_t_Push_mioi_icwt <= flow_table_read_req_t_Push_mioi_ogwt
          & (~ flow_table_read_req_t_Push_mioi_biwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    inputUnit_pktReassembly_pktReassembly_stage0_pktReassembly_stage0_stream_in_t_Pop_mioi_stream_in_t_Pop_mio_wait_dp
// ------------------------------------------------------------------


module inputUnit_pktReassembly_pktReassembly_stage0_pktReassembly_stage0_stream_in_t_Pop_mioi_stream_in_t_Pop_mio_wait_dp
    (
  i_clk, i_rst, stream_in_t_Pop_mioi_oswt_unreg, stream_in_t_Pop_mioi_bawt, stream_in_t_Pop_mioi_wen_comp,
      stream_in_t_Pop_mioi_idat_mxwt, stream_in_t_Pop_mioi_biwt, stream_in_t_Pop_mioi_bdwt,
      stream_in_t_Pop_mioi_idat
);
  input i_clk;
  input i_rst;
  input stream_in_t_Pop_mioi_oswt_unreg;
  output stream_in_t_Pop_mioi_bawt;
  output stream_in_t_Pop_mioi_wen_comp;
  output [248:0] stream_in_t_Pop_mioi_idat_mxwt;
  input stream_in_t_Pop_mioi_biwt;
  input stream_in_t_Pop_mioi_bdwt;
  input [265:0] stream_in_t_Pop_mioi_idat;


  // Interconnect Declarations
  reg stream_in_t_Pop_mioi_bcwt;
  reg [57:0] stream_in_t_Pop_mioi_idat_bfwt_255_198;
  reg [190:0] stream_in_t_Pop_mioi_idat_bfwt_194_4;

  wire[57:0] stream_in_read_mux_2_nl;
  wire[190:0] stream_in_read_mux_3_nl;

  // Interconnect Declarations for Component Instantiations 
  assign stream_in_t_Pop_mioi_bawt = stream_in_t_Pop_mioi_biwt | stream_in_t_Pop_mioi_bcwt;
  assign stream_in_t_Pop_mioi_wen_comp = (~ stream_in_t_Pop_mioi_oswt_unreg) | stream_in_t_Pop_mioi_bawt;
  assign stream_in_read_mux_2_nl = MUX_v_58_2_2((stream_in_t_Pop_mioi_idat[255:198]),
      stream_in_t_Pop_mioi_idat_bfwt_255_198, stream_in_t_Pop_mioi_bcwt);
  assign stream_in_read_mux_3_nl = MUX_v_191_2_2((stream_in_t_Pop_mioi_idat[194:4]),
      stream_in_t_Pop_mioi_idat_bfwt_194_4, stream_in_t_Pop_mioi_bcwt);
  assign stream_in_t_Pop_mioi_idat_mxwt = {stream_in_read_mux_2_nl , stream_in_read_mux_3_nl};
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      stream_in_t_Pop_mioi_bcwt <= 1'b0;
    end
    else begin
      stream_in_t_Pop_mioi_bcwt <= ~((~(stream_in_t_Pop_mioi_bcwt | stream_in_t_Pop_mioi_biwt))
          | stream_in_t_Pop_mioi_bdwt);
    end
  end
  always @(posedge i_clk) begin
    if ( stream_in_t_Pop_mioi_biwt ) begin
      stream_in_t_Pop_mioi_idat_bfwt_255_198 <= stream_in_t_Pop_mioi_idat[255:198];
      stream_in_t_Pop_mioi_idat_bfwt_194_4 <= stream_in_t_Pop_mioi_idat[194:4];
    end
  end

  function automatic [190:0] MUX_v_191_2_2;
    input [190:0] input_0;
    input [190:0] input_1;
    input  sel;
    reg [190:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_191_2_2 = result;
  end
  endfunction


  function automatic [57:0] MUX_v_58_2_2;
    input [57:0] input_0;
    input [57:0] input_1;
    input  sel;
    reg [57:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_58_2_2 = result;
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    inputUnit_pktReassembly_pktReassembly_stage0_pktReassembly_stage0_stream_in_t_Pop_mioi_stream_in_t_Pop_mio_wait_ctrl
// ------------------------------------------------------------------


module inputUnit_pktReassembly_pktReassembly_stage0_pktReassembly_stage0_stream_in_t_Pop_mioi_stream_in_t_Pop_mio_wait_ctrl
    (
  i_clk, i_rst, pktReassembly_stage0_wen, pktReassembly_stage0_wten, stream_in_t_Pop_mioi_oswt_unreg,
      stream_in_t_Pop_mioi_iswt0, stream_in_t_Pop_mioi_biwt, stream_in_t_Pop_mioi_bdwt,
      stream_in_t_Pop_mioi_ivld, stream_in_t_Pop_mioi_irdy_pktReassembly_stage0_sct
);
  input i_clk;
  input i_rst;
  input pktReassembly_stage0_wen;
  input pktReassembly_stage0_wten;
  input stream_in_t_Pop_mioi_oswt_unreg;
  input stream_in_t_Pop_mioi_iswt0;
  output stream_in_t_Pop_mioi_biwt;
  output stream_in_t_Pop_mioi_bdwt;
  input stream_in_t_Pop_mioi_ivld;
  output stream_in_t_Pop_mioi_irdy_pktReassembly_stage0_sct;


  // Interconnect Declarations
  wire stream_in_t_Pop_mioi_ogwt;
  reg stream_in_t_Pop_mioi_icwt;


  // Interconnect Declarations for Component Instantiations 
  assign stream_in_t_Pop_mioi_bdwt = stream_in_t_Pop_mioi_oswt_unreg & pktReassembly_stage0_wen;
  assign stream_in_t_Pop_mioi_biwt = stream_in_t_Pop_mioi_ogwt & stream_in_t_Pop_mioi_ivld;
  assign stream_in_t_Pop_mioi_ogwt = ((~ pktReassembly_stage0_wten) & stream_in_t_Pop_mioi_iswt0)
      | stream_in_t_Pop_mioi_icwt;
  assign stream_in_t_Pop_mioi_irdy_pktReassembly_stage0_sct = stream_in_t_Pop_mioi_ogwt;
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      stream_in_t_Pop_mioi_icwt <= 1'b0;
    end
    else begin
      stream_in_t_Pop_mioi_icwt <= stream_in_t_Pop_mioi_ogwt & (~ stream_in_t_Pop_mioi_biwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    inputUnit_pktReassembly_pktReassembly_stage0_pktReassembly_stage0_cmd_in_t_Pop_mioi_cmd_in_t_Pop_mio_wait_dp
// ------------------------------------------------------------------


module inputUnit_pktReassembly_pktReassembly_stage0_pktReassembly_stage0_cmd_in_t_Pop_mioi_cmd_in_t_Pop_mio_wait_dp
    (
  i_clk, i_rst, cmd_in_t_Pop_mioi_oswt_unreg, cmd_in_t_Pop_mioi_bawt, cmd_in_t_Pop_mioi_wen_comp,
      cmd_in_t_Pop_mioi_idat_mxwt, cmd_in_t_Pop_mioi_biwt, cmd_in_t_Pop_mioi_bdwt,
      cmd_in_t_Pop_mioi_idat
);
  input i_clk;
  input i_rst;
  input cmd_in_t_Pop_mioi_oswt_unreg;
  output cmd_in_t_Pop_mioi_bawt;
  output cmd_in_t_Pop_mioi_wen_comp;
  output [9:0] cmd_in_t_Pop_mioi_idat_mxwt;
  input cmd_in_t_Pop_mioi_biwt;
  input cmd_in_t_Pop_mioi_bdwt;
  input [312:0] cmd_in_t_Pop_mioi_idat;


  // Interconnect Declarations
  reg cmd_in_t_Pop_mioi_bcwt;
  reg [9:0] cmd_in_t_Pop_mioi_idat_bfwt_9_0;


  // Interconnect Declarations for Component Instantiations 
  assign cmd_in_t_Pop_mioi_bawt = cmd_in_t_Pop_mioi_biwt | cmd_in_t_Pop_mioi_bcwt;
  assign cmd_in_t_Pop_mioi_wen_comp = (~ cmd_in_t_Pop_mioi_oswt_unreg) | cmd_in_t_Pop_mioi_bawt;
  assign cmd_in_t_Pop_mioi_idat_mxwt = MUX_v_10_2_2((cmd_in_t_Pop_mioi_idat[9:0]),
      cmd_in_t_Pop_mioi_idat_bfwt_9_0, cmd_in_t_Pop_mioi_bcwt);
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      cmd_in_t_Pop_mioi_bcwt <= 1'b0;
    end
    else begin
      cmd_in_t_Pop_mioi_bcwt <= ~((~(cmd_in_t_Pop_mioi_bcwt | cmd_in_t_Pop_mioi_biwt))
          | cmd_in_t_Pop_mioi_bdwt);
    end
  end
  always @(posedge i_clk) begin
    if ( cmd_in_t_Pop_mioi_biwt ) begin
      cmd_in_t_Pop_mioi_idat_bfwt_9_0 <= cmd_in_t_Pop_mioi_idat[9:0];
    end
  end

  function automatic [9:0] MUX_v_10_2_2;
    input [9:0] input_0;
    input [9:0] input_1;
    input  sel;
    reg [9:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_10_2_2 = result;
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    inputUnit_pktReassembly_pktReassembly_stage0_pktReassembly_stage0_cmd_in_t_Pop_mioi_cmd_in_t_Pop_mio_wait_ctrl
// ------------------------------------------------------------------


module inputUnit_pktReassembly_pktReassembly_stage0_pktReassembly_stage0_cmd_in_t_Pop_mioi_cmd_in_t_Pop_mio_wait_ctrl
    (
  i_clk, i_rst, pktReassembly_stage0_wen, pktReassembly_stage0_wten, cmd_in_t_Pop_mioi_oswt_unreg,
      cmd_in_t_Pop_mioi_iswt0, cmd_in_t_Pop_mioi_biwt, cmd_in_t_Pop_mioi_bdwt, cmd_in_t_Pop_mioi_ivld,
      cmd_in_t_Pop_mioi_irdy_pktReassembly_stage0_sct
);
  input i_clk;
  input i_rst;
  input pktReassembly_stage0_wen;
  input pktReassembly_stage0_wten;
  input cmd_in_t_Pop_mioi_oswt_unreg;
  input cmd_in_t_Pop_mioi_iswt0;
  output cmd_in_t_Pop_mioi_biwt;
  output cmd_in_t_Pop_mioi_bdwt;
  input cmd_in_t_Pop_mioi_ivld;
  output cmd_in_t_Pop_mioi_irdy_pktReassembly_stage0_sct;


  // Interconnect Declarations
  wire cmd_in_t_Pop_mioi_ogwt;
  reg cmd_in_t_Pop_mioi_icwt;


  // Interconnect Declarations for Component Instantiations 
  assign cmd_in_t_Pop_mioi_bdwt = cmd_in_t_Pop_mioi_oswt_unreg & pktReassembly_stage0_wen;
  assign cmd_in_t_Pop_mioi_biwt = cmd_in_t_Pop_mioi_ogwt & cmd_in_t_Pop_mioi_ivld;
  assign cmd_in_t_Pop_mioi_ogwt = ((~ pktReassembly_stage0_wten) & cmd_in_t_Pop_mioi_iswt0)
      | cmd_in_t_Pop_mioi_icwt;
  assign cmd_in_t_Pop_mioi_irdy_pktReassembly_stage0_sct = cmd_in_t_Pop_mioi_ogwt;
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      cmd_in_t_Pop_mioi_icwt <= 1'b0;
    end
    else begin
      cmd_in_t_Pop_mioi_icwt <= cmd_in_t_Pop_mioi_ogwt & (~ cmd_in_t_Pop_mioi_biwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_req_rsp_fifo_cnsi
// ------------------------------------------------------------------


module inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_req_rsp_fifo_cnsi
    (
  i_clk, i_rst, req_rsp_fifo_cns_dat, req_rsp_fifo_cns_vld, req_rsp_fifo_cns_rdy,
      pktReassembly_stage1_wen, req_rsp_fifo_cnsi_oswt_unreg, req_rsp_fifo_cnsi_bawt,
      req_rsp_fifo_cnsi_iswt0, req_rsp_fifo_cnsi_wen_comp, req_rsp_fifo_cnsi_idat_mxwt
);
  input i_clk;
  input i_rst;
  input [261:0] req_rsp_fifo_cns_dat;
  input req_rsp_fifo_cns_vld;
  output req_rsp_fifo_cns_rdy;
  input pktReassembly_stage1_wen;
  input req_rsp_fifo_cnsi_oswt_unreg;
  output req_rsp_fifo_cnsi_bawt;
  input req_rsp_fifo_cnsi_iswt0;
  output req_rsp_fifo_cnsi_wen_comp;
  output [261:0] req_rsp_fifo_cnsi_idat_mxwt;


  // Interconnect Declarations
  wire req_rsp_fifo_cnsi_biwt;
  wire req_rsp_fifo_cnsi_bdwt;
  wire req_rsp_fifo_cnsi_bcwt;
  wire req_rsp_fifo_cnsi_irdy_pktReassembly_stage1_sct;
  wire req_rsp_fifo_cnsi_ivld;
  wire [261:0] req_rsp_fifo_cnsi_idat;


  // Interconnect Declarations for Component Instantiations 
  ccs_in_wait_v1 #(.rscid(32'sd49),
  .width(32'sd262)) req_rsp_fifo_cnsi (
      .rdy(req_rsp_fifo_cns_rdy),
      .vld(req_rsp_fifo_cns_vld),
      .dat(req_rsp_fifo_cns_dat),
      .irdy(req_rsp_fifo_cnsi_irdy_pktReassembly_stage1_sct),
      .ivld(req_rsp_fifo_cnsi_ivld),
      .idat(req_rsp_fifo_cnsi_idat)
    );
  inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_req_rsp_fifo_cnsi_req_rsp_fifo_wait_ctrl
      pktReassembly_pktReassembly_stage1_pktReassembly_stage1_req_rsp_fifo_cnsi_req_rsp_fifo_wait_ctrl_inst
      (
      .pktReassembly_stage1_wen(pktReassembly_stage1_wen),
      .req_rsp_fifo_cnsi_oswt_unreg(req_rsp_fifo_cnsi_oswt_unreg),
      .req_rsp_fifo_cnsi_iswt0(req_rsp_fifo_cnsi_iswt0),
      .req_rsp_fifo_cnsi_biwt(req_rsp_fifo_cnsi_biwt),
      .req_rsp_fifo_cnsi_bdwt(req_rsp_fifo_cnsi_bdwt),
      .req_rsp_fifo_cnsi_bcwt(req_rsp_fifo_cnsi_bcwt),
      .req_rsp_fifo_cnsi_irdy_pktReassembly_stage1_sct(req_rsp_fifo_cnsi_irdy_pktReassembly_stage1_sct),
      .req_rsp_fifo_cnsi_ivld(req_rsp_fifo_cnsi_ivld)
    );
  inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_req_rsp_fifo_cnsi_req_rsp_fifo_wait_dp
      pktReassembly_pktReassembly_stage1_pktReassembly_stage1_req_rsp_fifo_cnsi_req_rsp_fifo_wait_dp_inst
      (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .req_rsp_fifo_cnsi_oswt_unreg(req_rsp_fifo_cnsi_oswt_unreg),
      .req_rsp_fifo_cnsi_bawt(req_rsp_fifo_cnsi_bawt),
      .req_rsp_fifo_cnsi_wen_comp(req_rsp_fifo_cnsi_wen_comp),
      .req_rsp_fifo_cnsi_idat_mxwt(req_rsp_fifo_cnsi_idat_mxwt),
      .req_rsp_fifo_cnsi_biwt(req_rsp_fifo_cnsi_biwt),
      .req_rsp_fifo_cnsi_bdwt(req_rsp_fifo_cnsi_bdwt),
      .req_rsp_fifo_cnsi_bcwt(req_rsp_fifo_cnsi_bcwt),
      .req_rsp_fifo_cnsi_idat(req_rsp_fifo_cnsi_idat)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_unlock_req_t_Push_mioi
// ------------------------------------------------------------------


module inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_unlock_req_t_Push_mioi
    (
  i_clk, i_rst, unlock_req_t_val, unlock_req_t_rdy, unlock_req_t_msg, pktReassembly_stage1_wen,
      pktReassembly_stage1_wten, unlock_req_t_Push_mioi_oswt_unreg, unlock_req_t_Push_mioi_bawt,
      unlock_req_t_Push_mioi_iswt0, unlock_req_t_Push_mioi_wen_comp, unlock_req_t_Push_mioi_idat
);
  input i_clk;
  input i_rst;
  output unlock_req_t_val;
  input unlock_req_t_rdy;
  output [287:0] unlock_req_t_msg;
  input pktReassembly_stage1_wen;
  input pktReassembly_stage1_wten;
  input unlock_req_t_Push_mioi_oswt_unreg;
  output unlock_req_t_Push_mioi_bawt;
  input unlock_req_t_Push_mioi_iswt0;
  output unlock_req_t_Push_mioi_wen_comp;
  input [287:0] unlock_req_t_Push_mioi_idat;


  // Interconnect Declarations
  wire unlock_req_t_Push_mioi_biwt;
  wire unlock_req_t_Push_mioi_bdwt;
  wire unlock_req_t_Push_mioi_ivld_pktReassembly_stage1_sct;
  wire unlock_req_t_Push_mioi_irdy;


  // Interconnect Declarations for Component Instantiations 
  wire [287:0] nl_unlock_req_t_Push_mioi_idat;
  assign nl_unlock_req_t_Push_mioi_idat = {14'b00000000000000 , (unlock_req_t_Push_mioi_idat[273:22])
      , 18'b000000000000000001 , (unlock_req_t_Push_mioi_idat[3:0])};
  ccs_out_wait_v1 #(.rscid(32'sd47),
  .width(32'sd288)) unlock_req_t_Push_mioi (
      .vld(unlock_req_t_val),
      .rdy(unlock_req_t_rdy),
      .dat(unlock_req_t_msg),
      .ivld(unlock_req_t_Push_mioi_ivld_pktReassembly_stage1_sct),
      .irdy(unlock_req_t_Push_mioi_irdy),
      .idat(nl_unlock_req_t_Push_mioi_idat[287:0])
    );
  inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_unlock_req_t_Push_mioi_unlock_req_t_Push_mio_wait_ctrl
      pktReassembly_pktReassembly_stage1_pktReassembly_stage1_unlock_req_t_Push_mioi_unlock_req_t_Push_mio_wait_ctrl_inst
      (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .pktReassembly_stage1_wen(pktReassembly_stage1_wen),
      .pktReassembly_stage1_wten(pktReassembly_stage1_wten),
      .unlock_req_t_Push_mioi_oswt_unreg(unlock_req_t_Push_mioi_oswt_unreg),
      .unlock_req_t_Push_mioi_iswt0(unlock_req_t_Push_mioi_iswt0),
      .unlock_req_t_Push_mioi_biwt(unlock_req_t_Push_mioi_biwt),
      .unlock_req_t_Push_mioi_bdwt(unlock_req_t_Push_mioi_bdwt),
      .unlock_req_t_Push_mioi_ivld_pktReassembly_stage1_sct(unlock_req_t_Push_mioi_ivld_pktReassembly_stage1_sct),
      .unlock_req_t_Push_mioi_irdy(unlock_req_t_Push_mioi_irdy)
    );
  inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_unlock_req_t_Push_mioi_unlock_req_t_Push_mio_wait_dp
      pktReassembly_pktReassembly_stage1_pktReassembly_stage1_unlock_req_t_Push_mioi_unlock_req_t_Push_mio_wait_dp_inst
      (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .unlock_req_t_Push_mioi_oswt_unreg(unlock_req_t_Push_mioi_oswt_unreg),
      .unlock_req_t_Push_mioi_bawt(unlock_req_t_Push_mioi_bawt),
      .unlock_req_t_Push_mioi_wen_comp(unlock_req_t_Push_mioi_wen_comp),
      .unlock_req_t_Push_mioi_biwt(unlock_req_t_Push_mioi_biwt),
      .unlock_req_t_Push_mioi_bdwt(unlock_req_t_Push_mioi_bdwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_flow_table_write_req_t_Push_mioi
// ------------------------------------------------------------------


module inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_flow_table_write_req_t_Push_mioi
    (
  i_clk, i_rst, flow_table_write_req_t_val, flow_table_write_req_t_rdy, flow_table_write_req_t_msg,
      pktReassembly_stage1_wen, pktReassembly_stage1_wten, flow_table_write_req_t_Push_mioi_oswt_unreg,
      flow_table_write_req_t_Push_mioi_bawt, flow_table_write_req_t_Push_mioi_iswt0,
      flow_table_write_req_t_Push_mioi_wen_comp, flow_table_write_req_t_Push_mioi_idat
);
  input i_clk;
  input i_rst;
  output flow_table_write_req_t_val;
  input flow_table_write_req_t_rdy;
  output [287:0] flow_table_write_req_t_msg;
  input pktReassembly_stage1_wen;
  input pktReassembly_stage1_wten;
  input flow_table_write_req_t_Push_mioi_oswt_unreg;
  output flow_table_write_req_t_Push_mioi_bawt;
  input flow_table_write_req_t_Push_mioi_iswt0;
  output flow_table_write_req_t_Push_mioi_wen_comp;
  input [287:0] flow_table_write_req_t_Push_mioi_idat;


  // Interconnect Declarations
  wire flow_table_write_req_t_Push_mioi_biwt;
  wire flow_table_write_req_t_Push_mioi_bdwt;
  wire flow_table_write_req_t_Push_mioi_ivld_pktReassembly_stage1_sct;
  wire flow_table_write_req_t_Push_mioi_irdy;


  // Interconnect Declarations for Component Instantiations 
  wire [287:0] nl_flow_table_write_req_t_Push_mioi_idat;
  assign nl_flow_table_write_req_t_Push_mioi_idat = {(flow_table_write_req_t_Push_mioi_idat[287:22])
      , 16'b0000000000000000 , (flow_table_write_req_t_Push_mioi_idat[5:0])};
  ccs_out_wait_v1 #(.rscid(32'sd46),
  .width(32'sd288)) flow_table_write_req_t_Push_mioi (
      .vld(flow_table_write_req_t_val),
      .rdy(flow_table_write_req_t_rdy),
      .dat(flow_table_write_req_t_msg),
      .ivld(flow_table_write_req_t_Push_mioi_ivld_pktReassembly_stage1_sct),
      .irdy(flow_table_write_req_t_Push_mioi_irdy),
      .idat(nl_flow_table_write_req_t_Push_mioi_idat[287:0])
    );
  inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_flow_table_write_req_t_Push_mioi_flow_table_write_req_t_Push_mio_wait_ctrl
      pktReassembly_pktReassembly_stage1_pktReassembly_stage1_flow_table_write_req_t_Push_mioi_flow_table_write_req_t_Push_mio_wait_ctrl_inst
      (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .pktReassembly_stage1_wen(pktReassembly_stage1_wen),
      .pktReassembly_stage1_wten(pktReassembly_stage1_wten),
      .flow_table_write_req_t_Push_mioi_oswt_unreg(flow_table_write_req_t_Push_mioi_oswt_unreg),
      .flow_table_write_req_t_Push_mioi_iswt0(flow_table_write_req_t_Push_mioi_iswt0),
      .flow_table_write_req_t_Push_mioi_biwt(flow_table_write_req_t_Push_mioi_biwt),
      .flow_table_write_req_t_Push_mioi_bdwt(flow_table_write_req_t_Push_mioi_bdwt),
      .flow_table_write_req_t_Push_mioi_ivld_pktReassembly_stage1_sct(flow_table_write_req_t_Push_mioi_ivld_pktReassembly_stage1_sct),
      .flow_table_write_req_t_Push_mioi_irdy(flow_table_write_req_t_Push_mioi_irdy)
    );
  inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_flow_table_write_req_t_Push_mioi_flow_table_write_req_t_Push_mio_wait_dp
      pktReassembly_pktReassembly_stage1_pktReassembly_stage1_flow_table_write_req_t_Push_mioi_flow_table_write_req_t_Push_mio_wait_dp_inst
      (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .flow_table_write_req_t_Push_mioi_oswt_unreg(flow_table_write_req_t_Push_mioi_oswt_unreg),
      .flow_table_write_req_t_Push_mioi_bawt(flow_table_write_req_t_Push_mioi_bawt),
      .flow_table_write_req_t_Push_mioi_wen_comp(flow_table_write_req_t_Push_mioi_wen_comp),
      .flow_table_write_req_t_Push_mioi_biwt(flow_table_write_req_t_Push_mioi_biwt),
      .flow_table_write_req_t_Push_mioi_bdwt(flow_table_write_req_t_Push_mioi_bdwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_flow_table_read_rsp_t_Pop_mioi
// ------------------------------------------------------------------


module inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_flow_table_read_rsp_t_Pop_mioi
    (
  i_clk, i_rst, flow_table_read_rsp_t_val, flow_table_read_rsp_t_rdy, flow_table_read_rsp_t_msg,
      pktReassembly_stage1_wen, pktReassembly_stage1_wten, flow_table_read_rsp_t_Pop_mioi_oswt_unreg,
      flow_table_read_rsp_t_Pop_mioi_bawt, flow_table_read_rsp_t_Pop_mioi_iswt0,
      flow_table_read_rsp_t_Pop_mioi_wen_comp, flow_table_read_rsp_t_Pop_mioi_idat_mxwt
);
  input i_clk;
  input i_rst;
  input flow_table_read_rsp_t_val;
  output flow_table_read_rsp_t_rdy;
  input [528:0] flow_table_read_rsp_t_msg;
  input pktReassembly_stage1_wen;
  input pktReassembly_stage1_wten;
  input flow_table_read_rsp_t_Pop_mioi_oswt_unreg;
  output flow_table_read_rsp_t_Pop_mioi_bawt;
  input flow_table_read_rsp_t_Pop_mioi_iswt0;
  output flow_table_read_rsp_t_Pop_mioi_wen_comp;
  output [521:0] flow_table_read_rsp_t_Pop_mioi_idat_mxwt;


  // Interconnect Declarations
  wire flow_table_read_rsp_t_Pop_mioi_biwt;
  wire flow_table_read_rsp_t_Pop_mioi_bdwt;
  wire flow_table_read_rsp_t_Pop_mioi_ivld;
  wire flow_table_read_rsp_t_Pop_mioi_irdy_pktReassembly_stage1_sct;
  wire [528:0] flow_table_read_rsp_t_Pop_mioi_idat;
  wire [521:0] flow_table_read_rsp_t_Pop_mioi_idat_mxwt_pconst;


  // Interconnect Declarations for Component Instantiations 
  ccs_in_wait_v1 #(.rscid(32'sd45),
  .width(32'sd529)) flow_table_read_rsp_t_Pop_mioi (
      .vld(flow_table_read_rsp_t_val),
      .rdy(flow_table_read_rsp_t_rdy),
      .dat(flow_table_read_rsp_t_msg),
      .ivld(flow_table_read_rsp_t_Pop_mioi_ivld),
      .irdy(flow_table_read_rsp_t_Pop_mioi_irdy_pktReassembly_stage1_sct),
      .idat(flow_table_read_rsp_t_Pop_mioi_idat)
    );
  inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_flow_table_read_rsp_t_Pop_mioi_flow_table_read_rsp_t_Pop_mio_wait_ctrl
      pktReassembly_pktReassembly_stage1_pktReassembly_stage1_flow_table_read_rsp_t_Pop_mioi_flow_table_read_rsp_t_Pop_mio_wait_ctrl_inst
      (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .pktReassembly_stage1_wen(pktReassembly_stage1_wen),
      .pktReassembly_stage1_wten(pktReassembly_stage1_wten),
      .flow_table_read_rsp_t_Pop_mioi_oswt_unreg(flow_table_read_rsp_t_Pop_mioi_oswt_unreg),
      .flow_table_read_rsp_t_Pop_mioi_iswt0(flow_table_read_rsp_t_Pop_mioi_iswt0),
      .flow_table_read_rsp_t_Pop_mioi_biwt(flow_table_read_rsp_t_Pop_mioi_biwt),
      .flow_table_read_rsp_t_Pop_mioi_bdwt(flow_table_read_rsp_t_Pop_mioi_bdwt),
      .flow_table_read_rsp_t_Pop_mioi_ivld(flow_table_read_rsp_t_Pop_mioi_ivld),
      .flow_table_read_rsp_t_Pop_mioi_irdy_pktReassembly_stage1_sct(flow_table_read_rsp_t_Pop_mioi_irdy_pktReassembly_stage1_sct)
    );
  inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_flow_table_read_rsp_t_Pop_mioi_flow_table_read_rsp_t_Pop_mio_wait_dp
      pktReassembly_pktReassembly_stage1_pktReassembly_stage1_flow_table_read_rsp_t_Pop_mioi_flow_table_read_rsp_t_Pop_mio_wait_dp_inst
      (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .flow_table_read_rsp_t_Pop_mioi_oswt_unreg(flow_table_read_rsp_t_Pop_mioi_oswt_unreg),
      .flow_table_read_rsp_t_Pop_mioi_bawt(flow_table_read_rsp_t_Pop_mioi_bawt),
      .flow_table_read_rsp_t_Pop_mioi_wen_comp(flow_table_read_rsp_t_Pop_mioi_wen_comp),
      .flow_table_read_rsp_t_Pop_mioi_idat_mxwt(flow_table_read_rsp_t_Pop_mioi_idat_mxwt_pconst),
      .flow_table_read_rsp_t_Pop_mioi_biwt(flow_table_read_rsp_t_Pop_mioi_biwt),
      .flow_table_read_rsp_t_Pop_mioi_bdwt(flow_table_read_rsp_t_Pop_mioi_bdwt),
      .flow_table_read_rsp_t_Pop_mioi_idat(flow_table_read_rsp_t_Pop_mioi_idat)
    );
  assign flow_table_read_rsp_t_Pop_mioi_idat_mxwt = flow_table_read_rsp_t_Pop_mioi_idat_mxwt_pconst;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_bfu_out_t_Push_mioi
// ------------------------------------------------------------------


module inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_bfu_out_t_Push_mioi
    (
  i_clk, i_rst, bfu_out_t_val, bfu_out_t_rdy, bfu_out_t_msg, pktReassembly_stage1_wen,
      pktReassembly_stage1_wten, bfu_out_t_Push_mioi_oswt_unreg, bfu_out_t_Push_mioi_bawt,
      bfu_out_t_Push_mioi_iswt0, bfu_out_t_Push_mioi_wen_comp, bfu_out_t_Push_mioi_idat
);
  input i_clk;
  input i_rst;
  output bfu_out_t_val;
  input bfu_out_t_rdy;
  output [556:0] bfu_out_t_msg;
  input pktReassembly_stage1_wen;
  input pktReassembly_stage1_wten;
  input bfu_out_t_Push_mioi_oswt_unreg;
  output bfu_out_t_Push_mioi_bawt;
  input bfu_out_t_Push_mioi_iswt0;
  output bfu_out_t_Push_mioi_wen_comp;
  input [556:0] bfu_out_t_Push_mioi_idat;


  // Interconnect Declarations
  wire bfu_out_t_Push_mioi_biwt;
  wire bfu_out_t_Push_mioi_bdwt;
  wire bfu_out_t_Push_mioi_ivld_pktReassembly_stage1_sct;
  wire bfu_out_t_Push_mioi_irdy;


  // Interconnect Declarations for Component Instantiations 
  wire [556:0] nl_bfu_out_t_Push_mioi_idat;
  assign nl_bfu_out_t_Push_mioi_idat = {(bfu_out_t_Push_mioi_idat[556:291]) , 3'b000
      , (bfu_out_t_Push_mioi_idat[287]) , 1'b0 , (bfu_out_t_Push_mioi_idat[285])
      , 14'b00000000000000 , (bfu_out_t_Push_mioi_idat[270:19]) , 4'b0000 , (bfu_out_t_Push_mioi_idat[14:12])
      , 4'b1000 , (bfu_out_t_Push_mioi_idat[7:0])};
  ccs_out_wait_v1 #(.rscid(32'sd44),
  .width(32'sd557)) bfu_out_t_Push_mioi (
      .vld(bfu_out_t_val),
      .rdy(bfu_out_t_rdy),
      .dat(bfu_out_t_msg),
      .ivld(bfu_out_t_Push_mioi_ivld_pktReassembly_stage1_sct),
      .irdy(bfu_out_t_Push_mioi_irdy),
      .idat(nl_bfu_out_t_Push_mioi_idat[556:0])
    );
  inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_bfu_out_t_Push_mioi_bfu_out_t_Push_mio_wait_ctrl
      pktReassembly_pktReassembly_stage1_pktReassembly_stage1_bfu_out_t_Push_mioi_bfu_out_t_Push_mio_wait_ctrl_inst
      (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .pktReassembly_stage1_wen(pktReassembly_stage1_wen),
      .pktReassembly_stage1_wten(pktReassembly_stage1_wten),
      .bfu_out_t_Push_mioi_oswt_unreg(bfu_out_t_Push_mioi_oswt_unreg),
      .bfu_out_t_Push_mioi_iswt0(bfu_out_t_Push_mioi_iswt0),
      .bfu_out_t_Push_mioi_biwt(bfu_out_t_Push_mioi_biwt),
      .bfu_out_t_Push_mioi_bdwt(bfu_out_t_Push_mioi_bdwt),
      .bfu_out_t_Push_mioi_ivld_pktReassembly_stage1_sct(bfu_out_t_Push_mioi_ivld_pktReassembly_stage1_sct),
      .bfu_out_t_Push_mioi_irdy(bfu_out_t_Push_mioi_irdy)
    );
  inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_bfu_out_t_Push_mioi_bfu_out_t_Push_mio_wait_dp
      pktReassembly_pktReassembly_stage1_pktReassembly_stage1_bfu_out_t_Push_mioi_bfu_out_t_Push_mio_wait_dp_inst
      (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .bfu_out_t_Push_mioi_oswt_unreg(bfu_out_t_Push_mioi_oswt_unreg),
      .bfu_out_t_Push_mioi_bawt(bfu_out_t_Push_mioi_bawt),
      .bfu_out_t_Push_mioi_wen_comp(bfu_out_t_Push_mioi_wen_comp),
      .bfu_out_t_Push_mioi_biwt(bfu_out_t_Push_mioi_biwt),
      .bfu_out_t_Push_mioi_bdwt(bfu_out_t_Push_mioi_bdwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_stream_out_t_Push_mioi
// ------------------------------------------------------------------


module inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_stream_out_t_Push_mioi
    (
  i_clk, i_rst, stream_out_t_val, stream_out_t_rdy, stream_out_t_msg, pktReassembly_stage1_wen,
      pktReassembly_stage1_wten, stream_out_t_Push_mioi_oswt_unreg, stream_out_t_Push_mioi_bawt,
      stream_out_t_Push_mioi_iswt0, stream_out_t_Push_mioi_wen_comp, stream_out_t_Push_mioi_idat
);
  input i_clk;
  input i_rst;
  output stream_out_t_val;
  input stream_out_t_rdy;
  output [265:0] stream_out_t_msg;
  input pktReassembly_stage1_wen;
  input pktReassembly_stage1_wten;
  input stream_out_t_Push_mioi_oswt_unreg;
  output stream_out_t_Push_mioi_bawt;
  input stream_out_t_Push_mioi_iswt0;
  output stream_out_t_Push_mioi_wen_comp;
  input [265:0] stream_out_t_Push_mioi_idat;


  // Interconnect Declarations
  wire stream_out_t_Push_mioi_biwt;
  wire stream_out_t_Push_mioi_bdwt;
  wire stream_out_t_Push_mioi_ivld_pktReassembly_stage1_sct;
  wire stream_out_t_Push_mioi_irdy;


  // Interconnect Declarations for Component Instantiations 
  wire [265:0] nl_stream_out_t_Push_mioi_idat;
  assign nl_stream_out_t_Push_mioi_idat = {10'b1000000000 , (stream_out_t_Push_mioi_idat[255:0])};
  ccs_out_wait_v1 #(.rscid(32'sd43),
  .width(32'sd266)) stream_out_t_Push_mioi (
      .vld(stream_out_t_val),
      .rdy(stream_out_t_rdy),
      .dat(stream_out_t_msg),
      .ivld(stream_out_t_Push_mioi_ivld_pktReassembly_stage1_sct),
      .irdy(stream_out_t_Push_mioi_irdy),
      .idat(nl_stream_out_t_Push_mioi_idat[265:0])
    );
  inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_stream_out_t_Push_mioi_stream_out_t_Push_mio_wait_ctrl
      pktReassembly_pktReassembly_stage1_pktReassembly_stage1_stream_out_t_Push_mioi_stream_out_t_Push_mio_wait_ctrl_inst
      (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .pktReassembly_stage1_wen(pktReassembly_stage1_wen),
      .pktReassembly_stage1_wten(pktReassembly_stage1_wten),
      .stream_out_t_Push_mioi_oswt_unreg(stream_out_t_Push_mioi_oswt_unreg),
      .stream_out_t_Push_mioi_iswt0(stream_out_t_Push_mioi_iswt0),
      .stream_out_t_Push_mioi_biwt(stream_out_t_Push_mioi_biwt),
      .stream_out_t_Push_mioi_bdwt(stream_out_t_Push_mioi_bdwt),
      .stream_out_t_Push_mioi_ivld_pktReassembly_stage1_sct(stream_out_t_Push_mioi_ivld_pktReassembly_stage1_sct),
      .stream_out_t_Push_mioi_irdy(stream_out_t_Push_mioi_irdy)
    );
  inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_stream_out_t_Push_mioi_stream_out_t_Push_mio_wait_dp
      pktReassembly_pktReassembly_stage1_pktReassembly_stage1_stream_out_t_Push_mioi_stream_out_t_Push_mio_wait_dp_inst
      (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .stream_out_t_Push_mioi_oswt_unreg(stream_out_t_Push_mioi_oswt_unreg),
      .stream_out_t_Push_mioi_bawt(stream_out_t_Push_mioi_bawt),
      .stream_out_t_Push_mioi_wen_comp(stream_out_t_Push_mioi_wen_comp),
      .stream_out_t_Push_mioi_biwt(stream_out_t_Push_mioi_biwt),
      .stream_out_t_Push_mioi_bdwt(stream_out_t_Push_mioi_bdwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    inputUnit_pktReassembly_pktReassembly_stage0_pktReassembly_stage0_req_rsp_fifo_cnsi
// ------------------------------------------------------------------


module inputUnit_pktReassembly_pktReassembly_stage0_pktReassembly_stage0_req_rsp_fifo_cnsi
    (
  i_clk, i_rst, req_rsp_fifo_cns_dat, req_rsp_fifo_cns_vld, req_rsp_fifo_cns_rdy,
      pktReassembly_stage0_wen, req_rsp_fifo_cnsi_oswt_unreg, req_rsp_fifo_cnsi_bawt,
      req_rsp_fifo_cnsi_iswt0, req_rsp_fifo_cnsi_wen_comp, req_rsp_fifo_cnsi_idat
);
  input i_clk;
  input i_rst;
  output [261:0] req_rsp_fifo_cns_dat;
  output req_rsp_fifo_cns_vld;
  input req_rsp_fifo_cns_rdy;
  input pktReassembly_stage0_wen;
  input req_rsp_fifo_cnsi_oswt_unreg;
  output req_rsp_fifo_cnsi_bawt;
  input req_rsp_fifo_cnsi_iswt0;
  output req_rsp_fifo_cnsi_wen_comp;
  input [261:0] req_rsp_fifo_cnsi_idat;


  // Interconnect Declarations
  wire req_rsp_fifo_cnsi_biwt;
  wire req_rsp_fifo_cnsi_bdwt;
  wire req_rsp_fifo_cnsi_bcwt;
  wire req_rsp_fifo_cnsi_irdy;
  wire req_rsp_fifo_cnsi_ivld_pktReassembly_stage0_sct;


  // Interconnect Declarations for Component Instantiations 
  wire [261:0] nl_req_rsp_fifo_cnsi_idat;
  assign nl_req_rsp_fifo_cnsi_idat = {(req_rsp_fifo_cnsi_idat[261:204]) , 1'b0 ,
      (req_rsp_fifo_cnsi_idat[202]) , 1'b0 , (req_rsp_fifo_cnsi_idat[200:0])};
  ccs_out_wait_v1 #(.rscid(32'sd48),
  .width(32'sd262)) req_rsp_fifo_cnsi (
      .irdy(req_rsp_fifo_cnsi_irdy),
      .ivld(req_rsp_fifo_cnsi_ivld_pktReassembly_stage0_sct),
      .idat(nl_req_rsp_fifo_cnsi_idat[261:0]),
      .rdy(req_rsp_fifo_cns_rdy),
      .vld(req_rsp_fifo_cns_vld),
      .dat(req_rsp_fifo_cns_dat)
    );
  inputUnit_pktReassembly_pktReassembly_stage0_pktReassembly_stage0_req_rsp_fifo_cnsi_req_rsp_fifo_wait_ctrl
      pktReassembly_pktReassembly_stage0_pktReassembly_stage0_req_rsp_fifo_cnsi_req_rsp_fifo_wait_ctrl_inst
      (
      .pktReassembly_stage0_wen(pktReassembly_stage0_wen),
      .req_rsp_fifo_cnsi_oswt_unreg(req_rsp_fifo_cnsi_oswt_unreg),
      .req_rsp_fifo_cnsi_iswt0(req_rsp_fifo_cnsi_iswt0),
      .req_rsp_fifo_cnsi_biwt(req_rsp_fifo_cnsi_biwt),
      .req_rsp_fifo_cnsi_bdwt(req_rsp_fifo_cnsi_bdwt),
      .req_rsp_fifo_cnsi_bcwt(req_rsp_fifo_cnsi_bcwt),
      .req_rsp_fifo_cnsi_irdy(req_rsp_fifo_cnsi_irdy),
      .req_rsp_fifo_cnsi_ivld_pktReassembly_stage0_sct(req_rsp_fifo_cnsi_ivld_pktReassembly_stage0_sct)
    );
  inputUnit_pktReassembly_pktReassembly_stage0_pktReassembly_stage0_req_rsp_fifo_cnsi_req_rsp_fifo_wait_dp
      pktReassembly_pktReassembly_stage0_pktReassembly_stage0_req_rsp_fifo_cnsi_req_rsp_fifo_wait_dp_inst
      (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .req_rsp_fifo_cnsi_oswt_unreg(req_rsp_fifo_cnsi_oswt_unreg),
      .req_rsp_fifo_cnsi_bawt(req_rsp_fifo_cnsi_bawt),
      .req_rsp_fifo_cnsi_wen_comp(req_rsp_fifo_cnsi_wen_comp),
      .req_rsp_fifo_cnsi_biwt(req_rsp_fifo_cnsi_biwt),
      .req_rsp_fifo_cnsi_bdwt(req_rsp_fifo_cnsi_bdwt),
      .req_rsp_fifo_cnsi_bcwt(req_rsp_fifo_cnsi_bcwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    inputUnit_pktReassembly_pktReassembly_stage0_pktReassembly_stage0_flow_table_read_req_t_Push_mioi
// ------------------------------------------------------------------


module inputUnit_pktReassembly_pktReassembly_stage0_pktReassembly_stage0_flow_table_read_req_t_Push_mioi
    (
  i_clk, i_rst, flow_table_read_req_t_val, flow_table_read_req_t_rdy, flow_table_read_req_t_msg,
      pktReassembly_stage0_wen, pktReassembly_stage0_wten, flow_table_read_req_t_Push_mioi_oswt_unreg,
      flow_table_read_req_t_Push_mioi_bawt, flow_table_read_req_t_Push_mioi_iswt0,
      flow_table_read_req_t_Push_mioi_wen_comp, flow_table_read_req_t_Push_mioi_idat
);
  input i_clk;
  input i_rst;
  output flow_table_read_req_t_val;
  input flow_table_read_req_t_rdy;
  output [287:0] flow_table_read_req_t_msg;
  input pktReassembly_stage0_wen;
  input pktReassembly_stage0_wten;
  input flow_table_read_req_t_Push_mioi_oswt_unreg;
  output flow_table_read_req_t_Push_mioi_bawt;
  input flow_table_read_req_t_Push_mioi_iswt0;
  output flow_table_read_req_t_Push_mioi_wen_comp;
  input [287:0] flow_table_read_req_t_Push_mioi_idat;


  // Interconnect Declarations
  wire flow_table_read_req_t_Push_mioi_biwt;
  wire flow_table_read_req_t_Push_mioi_bdwt;
  wire flow_table_read_req_t_Push_mioi_ivld_pktReassembly_stage0_sct;
  wire flow_table_read_req_t_Push_mioi_irdy;


  // Interconnect Declarations for Component Instantiations 
  wire [287:0] nl_flow_table_read_req_t_Push_mioi_idat;
  assign nl_flow_table_read_req_t_Push_mioi_idat = {14'b00000000000000 , (flow_table_read_req_t_Push_mioi_idat[273:216])
      , 1'b0 , (flow_table_read_req_t_Push_mioi_idat[214]) , 1'b0 , (flow_table_read_req_t_Push_mioi_idat[212:22])
      , 18'b000000000000000100 , (flow_table_read_req_t_Push_mioi_idat[3:0])};
  ccs_out_wait_v1 #(.rscid(32'sd42),
  .width(32'sd288)) flow_table_read_req_t_Push_mioi (
      .vld(flow_table_read_req_t_val),
      .rdy(flow_table_read_req_t_rdy),
      .dat(flow_table_read_req_t_msg),
      .ivld(flow_table_read_req_t_Push_mioi_ivld_pktReassembly_stage0_sct),
      .irdy(flow_table_read_req_t_Push_mioi_irdy),
      .idat(nl_flow_table_read_req_t_Push_mioi_idat[287:0])
    );
  inputUnit_pktReassembly_pktReassembly_stage0_pktReassembly_stage0_flow_table_read_req_t_Push_mioi_flow_table_read_req_t_Push_mio_wait_ctrl
      pktReassembly_pktReassembly_stage0_pktReassembly_stage0_flow_table_read_req_t_Push_mioi_flow_table_read_req_t_Push_mio_wait_ctrl_inst
      (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .pktReassembly_stage0_wen(pktReassembly_stage0_wen),
      .pktReassembly_stage0_wten(pktReassembly_stage0_wten),
      .flow_table_read_req_t_Push_mioi_oswt_unreg(flow_table_read_req_t_Push_mioi_oswt_unreg),
      .flow_table_read_req_t_Push_mioi_iswt0(flow_table_read_req_t_Push_mioi_iswt0),
      .flow_table_read_req_t_Push_mioi_biwt(flow_table_read_req_t_Push_mioi_biwt),
      .flow_table_read_req_t_Push_mioi_bdwt(flow_table_read_req_t_Push_mioi_bdwt),
      .flow_table_read_req_t_Push_mioi_ivld_pktReassembly_stage0_sct(flow_table_read_req_t_Push_mioi_ivld_pktReassembly_stage0_sct),
      .flow_table_read_req_t_Push_mioi_irdy(flow_table_read_req_t_Push_mioi_irdy)
    );
  inputUnit_pktReassembly_pktReassembly_stage0_pktReassembly_stage0_flow_table_read_req_t_Push_mioi_flow_table_read_req_t_Push_mio_wait_dp
      pktReassembly_pktReassembly_stage0_pktReassembly_stage0_flow_table_read_req_t_Push_mioi_flow_table_read_req_t_Push_mio_wait_dp_inst
      (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .flow_table_read_req_t_Push_mioi_oswt_unreg(flow_table_read_req_t_Push_mioi_oswt_unreg),
      .flow_table_read_req_t_Push_mioi_bawt(flow_table_read_req_t_Push_mioi_bawt),
      .flow_table_read_req_t_Push_mioi_wen_comp(flow_table_read_req_t_Push_mioi_wen_comp),
      .flow_table_read_req_t_Push_mioi_biwt(flow_table_read_req_t_Push_mioi_biwt),
      .flow_table_read_req_t_Push_mioi_bdwt(flow_table_read_req_t_Push_mioi_bdwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    inputUnit_pktReassembly_pktReassembly_stage0_pktReassembly_stage0_stream_in_t_Pop_mioi
// ------------------------------------------------------------------


module inputUnit_pktReassembly_pktReassembly_stage0_pktReassembly_stage0_stream_in_t_Pop_mioi
    (
  i_clk, i_rst, stream_in_t_val, stream_in_t_rdy, stream_in_t_msg, pktReassembly_stage0_wen,
      pktReassembly_stage0_wten, stream_in_t_Pop_mioi_oswt_unreg, stream_in_t_Pop_mioi_bawt,
      stream_in_t_Pop_mioi_iswt0, stream_in_t_Pop_mioi_wen_comp, stream_in_t_Pop_mioi_idat_mxwt
);
  input i_clk;
  input i_rst;
  input stream_in_t_val;
  output stream_in_t_rdy;
  input [265:0] stream_in_t_msg;
  input pktReassembly_stage0_wen;
  input pktReassembly_stage0_wten;
  input stream_in_t_Pop_mioi_oswt_unreg;
  output stream_in_t_Pop_mioi_bawt;
  input stream_in_t_Pop_mioi_iswt0;
  output stream_in_t_Pop_mioi_wen_comp;
  output [248:0] stream_in_t_Pop_mioi_idat_mxwt;


  // Interconnect Declarations
  wire stream_in_t_Pop_mioi_biwt;
  wire stream_in_t_Pop_mioi_bdwt;
  wire stream_in_t_Pop_mioi_ivld;
  wire stream_in_t_Pop_mioi_irdy_pktReassembly_stage0_sct;
  wire [265:0] stream_in_t_Pop_mioi_idat;
  wire [248:0] stream_in_t_Pop_mioi_idat_mxwt_pconst;


  // Interconnect Declarations for Component Instantiations 
  ccs_in_wait_v1 #(.rscid(32'sd41),
  .width(32'sd266)) stream_in_t_Pop_mioi (
      .vld(stream_in_t_val),
      .rdy(stream_in_t_rdy),
      .dat(stream_in_t_msg),
      .ivld(stream_in_t_Pop_mioi_ivld),
      .irdy(stream_in_t_Pop_mioi_irdy_pktReassembly_stage0_sct),
      .idat(stream_in_t_Pop_mioi_idat)
    );
  inputUnit_pktReassembly_pktReassembly_stage0_pktReassembly_stage0_stream_in_t_Pop_mioi_stream_in_t_Pop_mio_wait_ctrl
      pktReassembly_pktReassembly_stage0_pktReassembly_stage0_stream_in_t_Pop_mioi_stream_in_t_Pop_mio_wait_ctrl_inst
      (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .pktReassembly_stage0_wen(pktReassembly_stage0_wen),
      .pktReassembly_stage0_wten(pktReassembly_stage0_wten),
      .stream_in_t_Pop_mioi_oswt_unreg(stream_in_t_Pop_mioi_oswt_unreg),
      .stream_in_t_Pop_mioi_iswt0(stream_in_t_Pop_mioi_iswt0),
      .stream_in_t_Pop_mioi_biwt(stream_in_t_Pop_mioi_biwt),
      .stream_in_t_Pop_mioi_bdwt(stream_in_t_Pop_mioi_bdwt),
      .stream_in_t_Pop_mioi_ivld(stream_in_t_Pop_mioi_ivld),
      .stream_in_t_Pop_mioi_irdy_pktReassembly_stage0_sct(stream_in_t_Pop_mioi_irdy_pktReassembly_stage0_sct)
    );
  inputUnit_pktReassembly_pktReassembly_stage0_pktReassembly_stage0_stream_in_t_Pop_mioi_stream_in_t_Pop_mio_wait_dp
      pktReassembly_pktReassembly_stage0_pktReassembly_stage0_stream_in_t_Pop_mioi_stream_in_t_Pop_mio_wait_dp_inst
      (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .stream_in_t_Pop_mioi_oswt_unreg(stream_in_t_Pop_mioi_oswt_unreg),
      .stream_in_t_Pop_mioi_bawt(stream_in_t_Pop_mioi_bawt),
      .stream_in_t_Pop_mioi_wen_comp(stream_in_t_Pop_mioi_wen_comp),
      .stream_in_t_Pop_mioi_idat_mxwt(stream_in_t_Pop_mioi_idat_mxwt_pconst),
      .stream_in_t_Pop_mioi_biwt(stream_in_t_Pop_mioi_biwt),
      .stream_in_t_Pop_mioi_bdwt(stream_in_t_Pop_mioi_bdwt),
      .stream_in_t_Pop_mioi_idat(stream_in_t_Pop_mioi_idat)
    );
  assign stream_in_t_Pop_mioi_idat_mxwt = stream_in_t_Pop_mioi_idat_mxwt_pconst;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    inputUnit_pktReassembly_pktReassembly_stage0_pktReassembly_stage0_cmd_in_t_Pop_mioi
// ------------------------------------------------------------------


module inputUnit_pktReassembly_pktReassembly_stage0_pktReassembly_stage0_cmd_in_t_Pop_mioi
    (
  i_clk, i_rst, cmd_in_t_val, cmd_in_t_rdy, cmd_in_t_msg, pktReassembly_stage0_wen,
      pktReassembly_stage0_wten, cmd_in_t_Pop_mioi_oswt_unreg, cmd_in_t_Pop_mioi_bawt,
      cmd_in_t_Pop_mioi_iswt0, cmd_in_t_Pop_mioi_wen_comp, cmd_in_t_Pop_mioi_idat_mxwt
);
  input i_clk;
  input i_rst;
  input cmd_in_t_val;
  output cmd_in_t_rdy;
  input [312:0] cmd_in_t_msg;
  input pktReassembly_stage0_wen;
  input pktReassembly_stage0_wten;
  input cmd_in_t_Pop_mioi_oswt_unreg;
  output cmd_in_t_Pop_mioi_bawt;
  input cmd_in_t_Pop_mioi_iswt0;
  output cmd_in_t_Pop_mioi_wen_comp;
  output [9:0] cmd_in_t_Pop_mioi_idat_mxwt;


  // Interconnect Declarations
  wire cmd_in_t_Pop_mioi_biwt;
  wire cmd_in_t_Pop_mioi_bdwt;
  wire cmd_in_t_Pop_mioi_ivld;
  wire cmd_in_t_Pop_mioi_irdy_pktReassembly_stage0_sct;
  wire [312:0] cmd_in_t_Pop_mioi_idat;
  wire [9:0] cmd_in_t_Pop_mioi_idat_mxwt_pconst;


  // Interconnect Declarations for Component Instantiations 
  ccs_in_wait_v1 #(.rscid(32'sd40),
  .width(32'sd313)) cmd_in_t_Pop_mioi (
      .vld(cmd_in_t_val),
      .rdy(cmd_in_t_rdy),
      .dat(cmd_in_t_msg),
      .ivld(cmd_in_t_Pop_mioi_ivld),
      .irdy(cmd_in_t_Pop_mioi_irdy_pktReassembly_stage0_sct),
      .idat(cmd_in_t_Pop_mioi_idat)
    );
  inputUnit_pktReassembly_pktReassembly_stage0_pktReassembly_stage0_cmd_in_t_Pop_mioi_cmd_in_t_Pop_mio_wait_ctrl
      pktReassembly_pktReassembly_stage0_pktReassembly_stage0_cmd_in_t_Pop_mioi_cmd_in_t_Pop_mio_wait_ctrl_inst
      (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .pktReassembly_stage0_wen(pktReassembly_stage0_wen),
      .pktReassembly_stage0_wten(pktReassembly_stage0_wten),
      .cmd_in_t_Pop_mioi_oswt_unreg(cmd_in_t_Pop_mioi_oswt_unreg),
      .cmd_in_t_Pop_mioi_iswt0(cmd_in_t_Pop_mioi_iswt0),
      .cmd_in_t_Pop_mioi_biwt(cmd_in_t_Pop_mioi_biwt),
      .cmd_in_t_Pop_mioi_bdwt(cmd_in_t_Pop_mioi_bdwt),
      .cmd_in_t_Pop_mioi_ivld(cmd_in_t_Pop_mioi_ivld),
      .cmd_in_t_Pop_mioi_irdy_pktReassembly_stage0_sct(cmd_in_t_Pop_mioi_irdy_pktReassembly_stage0_sct)
    );
  inputUnit_pktReassembly_pktReassembly_stage0_pktReassembly_stage0_cmd_in_t_Pop_mioi_cmd_in_t_Pop_mio_wait_dp
      pktReassembly_pktReassembly_stage0_pktReassembly_stage0_cmd_in_t_Pop_mioi_cmd_in_t_Pop_mio_wait_dp_inst
      (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .cmd_in_t_Pop_mioi_oswt_unreg(cmd_in_t_Pop_mioi_oswt_unreg),
      .cmd_in_t_Pop_mioi_bawt(cmd_in_t_Pop_mioi_bawt),
      .cmd_in_t_Pop_mioi_wen_comp(cmd_in_t_Pop_mioi_wen_comp),
      .cmd_in_t_Pop_mioi_idat_mxwt(cmd_in_t_Pop_mioi_idat_mxwt_pconst),
      .cmd_in_t_Pop_mioi_biwt(cmd_in_t_Pop_mioi_biwt),
      .cmd_in_t_Pop_mioi_bdwt(cmd_in_t_Pop_mioi_bdwt),
      .cmd_in_t_Pop_mioi_idat(cmd_in_t_Pop_mioi_idat)
    );
  assign cmd_in_t_Pop_mioi_idat_mxwt = cmd_in_t_Pop_mioi_idat_mxwt_pconst;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1
// ------------------------------------------------------------------


module inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1 (
  i_clk, i_rst, stream_out_t_val, stream_out_t_rdy, stream_out_t_msg, bfu_out_t_val,
      bfu_out_t_rdy, bfu_out_t_msg, unlock_req_t_val, unlock_req_t_rdy, unlock_req_t_msg,
      flow_table_read_rsp_t_val, flow_table_read_rsp_t_rdy, flow_table_read_rsp_t_msg,
      flow_table_write_req_t_val, flow_table_write_req_t_rdy, flow_table_write_req_t_msg,
      req_rsp_fifo_cns_dat, req_rsp_fifo_cns_vld, req_rsp_fifo_cns_rdy
);
  input i_clk;
  input i_rst;
  output stream_out_t_val;
  input stream_out_t_rdy;
  output [265:0] stream_out_t_msg;
  output bfu_out_t_val;
  input bfu_out_t_rdy;
  output [556:0] bfu_out_t_msg;
  output unlock_req_t_val;
  input unlock_req_t_rdy;
  output [287:0] unlock_req_t_msg;
  input flow_table_read_rsp_t_val;
  output flow_table_read_rsp_t_rdy;
  input [528:0] flow_table_read_rsp_t_msg;
  output flow_table_write_req_t_val;
  input flow_table_write_req_t_rdy;
  output [287:0] flow_table_write_req_t_msg;
  input [261:0] req_rsp_fifo_cns_dat;
  input req_rsp_fifo_cns_vld;
  output req_rsp_fifo_cns_rdy;


  // Interconnect Declarations
  wire pktReassembly_stage1_wen;
  wire pktReassembly_stage1_wten;
  wire stream_out_t_Push_mioi_bawt;
  reg stream_out_t_Push_mioi_iswt0;
  wire stream_out_t_Push_mioi_wen_comp;
  wire bfu_out_t_Push_mioi_bawt;
  reg bfu_out_t_Push_mioi_iswt0;
  wire bfu_out_t_Push_mioi_wen_comp;
  wire flow_table_read_rsp_t_Pop_mioi_bawt;
  reg flow_table_read_rsp_t_Pop_mioi_iswt0;
  wire flow_table_read_rsp_t_Pop_mioi_wen_comp;
  wire [521:0] flow_table_read_rsp_t_Pop_mioi_idat_mxwt;
  wire flow_table_write_req_t_Push_mioi_bawt;
  reg flow_table_write_req_t_Push_mioi_iswt0;
  wire flow_table_write_req_t_Push_mioi_wen_comp;
  wire unlock_req_t_Push_mioi_bawt;
  reg unlock_req_t_Push_mioi_iswt0;
  wire unlock_req_t_Push_mioi_wen_comp;
  wire req_rsp_fifo_cnsi_bawt;
  reg req_rsp_fifo_cnsi_iswt0;
  wire req_rsp_fifo_cnsi_wen_comp;
  wire [261:0] req_rsp_fifo_cnsi_idat_mxwt;
  reg [57:0] stream_out_t_Push_mioi_idat_255_198;
  reg [2:0] stream_out_t_Push_mioi_idat_197_195;
  reg [190:0] stream_out_t_Push_mioi_idat_194_4;
  reg [3:0] stream_out_t_Push_mioi_idat_3_0;
  reg [265:0] bfu_out_t_Push_mioi_idat_556_291;
  reg [251:0] bfu_out_t_Push_mioi_idat_270_19;
  reg [3:0] bfu_out_t_Push_mioi_idat_3_0;
  reg [4:0] flow_table_write_req_t_Push_mioi_idat_287_283;
  reg [132:0] flow_table_write_req_t_Push_mioi_idat_282_150;
  reg [31:0] flow_table_write_req_t_Push_mioi_idat_149_118;
  reg [95:0] flow_table_write_req_t_Push_mioi_idat_117_22;
  reg [3:0] flow_table_write_req_t_Push_mioi_idat_3_0;
  reg [57:0] unlock_req_t_Push_mioi_idat_273_216;
  reg [2:0] unlock_req_t_Push_mioi_idat_215_213;
  reg [190:0] unlock_req_t_Push_mioi_idat_212_22;
  reg [3:0] unlock_req_t_Push_mioi_idat_3_0;
  reg [1:0] flow_table_write_req_t_Push_mioi_idat_5_4;
  wire [1:0] fsm_output;
  wire while_and_3_tmp;
  wire pktReassembly_pktReassembly_stage1_core_if_equal_tmp;
  wire while_and_2_tmp;
  wire while_and_1_tmp;
  wire nand_tmp_1;
  wire and_dcpl_8;
  wire and_dcpl_9;
  wire or_tmp_12;
  wire or_tmp_14;
  wire mux_tmp_8;
  wire mux_tmp_10;
  wire and_dcpl_14;
  wire and_dcpl_20;
  wire and_dcpl_21;
  wire and_dcpl_22;
  wire and_dcpl_24;
  wire and_dcpl_26;
  wire and_dcpl_33;
  wire and_dcpl_35;
  wire and_dcpl_43;
  wire and_dcpl_46;
  wire and_dcpl_54;
  wire and_dcpl_63;
  wire or_dcpl_20;
  wire or_tmp_29;
  wire or_tmp_36;
  reg [5:0] while_slc_out_set_bv_9_4_itm_1;
  reg pktReassembly_pktReassembly_stage1_core_if_else_slc_32_itm_1;
  reg pktReassembly_pktReassembly_stage1_core_if_if_if_slc_pktReassembly_pktReassembly_stage1_core_if_if_acc_10_itm_1;
  reg pktReassembly_pktReassembly_stage1_core_if_equal_itm_1;
  reg [4:0] flow_table_read_rsp_read_slc_flow_table_read_rsp_t_Pop_mio_mrgout_dat_528_11_1_itm_1;
  reg [5:0] while_slc_out_set_bv_9_4_itm_2;
  reg pktReassembly_pktReassembly_stage1_core_else_conc_itm_1_0;
  reg pktReassembly_pktReassembly_stage1_core_else_conc_itm_1_1;
  reg reg_bfu_out_t_Push_mioi_idat_287_271_ftd;
  wire bfu_out_write_last_and_1_ssc;
  reg bfu_out_t_Push_mioi_idat_12;
  reg [3:0] bfu_out_t_Push_mioi_idat_7_4;
  wire stream_out_write_and_1_cse;
  wire bfu_out_write_last_and_cse;
  wire and_118_cse;
  wire or_14_cse;
  wire flow_table_write_req_write_2_and_cse;
  wire unlock_req_write_2_and_1_cse;
  wire bfu_out_write_last_and_3_cse;
  wire pktReassembly_pktReassembly_stage1_core_if_if_else_and_cse;
  wire pktReassembly_pktReassembly_stage1_core_else_and_2_cse;
  wire pktReassembly_pktReassembly_stage1_core_if_if_else_and_2_cse;
  wire or_10_cse;
  wire nor_21_cse;
  wire and_117_cse;
  wire or_15_cse;
  wire and_114_cse;
  wire while_while_nand_14_cse;
  wire nor_8_cse;
  wire or_16_cse;
  wire nor_13_cse;
  reg while_stage_v_1;
  reg while_stage_v_2;
  reg [4:0] flow_table_read_rsp_read_slc_flow_table_read_rsp_t_Pop_mio_mrgout_dat_528_11_1_itm;
  reg pktReassembly_pktReassembly_stage1_core_if_equal_itm;
  reg pktReassembly_pktReassembly_stage1_core_if_if_if_slc_pktReassembly_pktReassembly_stage1_core_if_if_acc_10_itm;
  reg pktReassembly_pktReassembly_stage1_core_if_else_slc_32_itm;
  reg pktReassembly_pktReassembly_stage1_core_else_conc_itm_1;
  reg pktReassembly_pktReassembly_stage1_core_else_conc_itm_0;
  reg pktReassembly_pktReassembly_stage1_core_if_if_else_conc_itm_1;
  reg pktReassembly_pktReassembly_stage1_core_if_if_else_conc_itm_0;
  reg [251:0] out_set_bv_sva_1_261_10;
  reg [3:0] out_set_bv_sva_1_3_0;
  reg pktReassembly_pktReassembly_stage1_core_if_if_else_conc_itm_1_1;
  reg pktReassembly_pktReassembly_stage1_core_if_if_else_conc_itm_1_0;
  wire bfu_out_t_Push_mioi_idat_12_4_mx0c1;
  wire bfu_out_t_Push_mioi_idat_12_4_mx0c2;
  wire flow_table_write_req_t_Push_mioi_idat_5_4_mx0c2;
  wire while_stage_v_2_mx0c1;
  wire pktReassembly_pktReassembly_stage1_core_if_if_if_slc_pktReassembly_pktReassembly_stage1_core_if_if_acc_10_itm_1_mx0c1;
  wire pktReassembly_pktReassembly_stage1_core_if_else_slc_32_itm_1_mx0c1;
  wire while_stage_v_1_mx0c1;
  wire while_while_or_cse_1;
  wire while_or_cse_1;
  wire while_or_1_cse_1;
  wire while_or_19_cse_1;
  wire while_or_20_cse_1;
  wire while_or_21_cse_1;
  wire while_or_22_cse_1;
  wire while_or_23_cse_1;
  wire while_or_24_cse_1;
  wire while_or_25_cse_1;
  wire while_or_26_cse_1;
  wire while_or_27_cse_1;
  wire while_or_28_cse_1;
  wire while_or_29_cse_1;
  wire while_or_30_cse_1;
  wire while_or_31_cse_1;
  wire while_or_32_cse_1;
  wire while_nand_36_cse_1;
  wire while_nand_32_cse_1;
  wire while_nand_26_cse_1;
  wire while_while_nand_cse_1;
  wire pktReassembly_pktReassembly_stage1_core_if_if_else_pktReassembly_pktReassembly_stage1_core_if_if_else_or_cse_1;
  wire pktReassembly_pktReassembly_stage1_core_if_if_else_pktReassembly_pktReassembly_stage1_core_if_if_else_nor_cse_1;
  wire pktReassembly_pktReassembly_stage1_core_else_pktReassembly_pktReassembly_stage1_core_else_nor_cse_1;
  wire while_nand_5_cse_1;
  wire while_nand_11_cse_1;
  wire while_nand_2_cse_1;
  wire while_and_8_cse;
  wire pktReassembly_pktReassembly_stage1_core_if_if_acc_itm_10_1;
  wire pktReassembly_pktReassembly_stage1_core_if_else_acc_itm_32_1;

  wire mux_4_nl;
  wire bfu_out_write_last_not_5_nl;
  wire bfu_out_write_last_not_7_nl;
  wire mux_11_nl;
  wire[31:0] pktReassembly_pktReassembly_stage1_core_if_if_else_else_acc_nl;
  wire[32:0] nl_pktReassembly_pktReassembly_stage1_core_if_if_else_else_acc_nl;
  wire mux_12_nl;
  wire or_30_nl;
  wire[1:0] flow_table_write_req_write_2_mux_nl;
  wire and_61_nl;
  wire[10:0] pktReassembly_pktReassembly_stage1_core_if_if_acc_nl;
  wire[11:0] nl_pktReassembly_pktReassembly_stage1_core_if_if_acc_nl;
  wire[32:0] pktReassembly_pktReassembly_stage1_core_if_else_acc_nl;
  wire[33:0] nl_pktReassembly_pktReassembly_stage1_core_if_else_acc_nl;
  wire mux_2_nl;
  wire mux_9_nl;

  // Interconnect Declarations for Component Instantiations 
  wire mux_1_nl;
  wire  nl_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_stream_out_t_Push_mioi_inst_stream_out_t_Push_mioi_oswt_unreg;
  assign mux_1_nl = MUX_s_1_2_2(pktReassembly_pktReassembly_stage1_core_if_else_slc_32_itm_1,
      pktReassembly_pktReassembly_stage1_core_if_if_if_slc_pktReassembly_pktReassembly_stage1_core_if_if_acc_10_itm_1,
      pktReassembly_pktReassembly_stage1_core_if_equal_itm_1);
  assign nl_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_stream_out_t_Push_mioi_inst_stream_out_t_Push_mioi_oswt_unreg
      = (nor_21_cse | and_117_cse | (~ mux_1_nl)) & while_and_1_tmp & (fsm_output[1]);
  wire [265:0] nl_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_stream_out_t_Push_mioi_inst_stream_out_t_Push_mioi_idat;
  assign nl_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_stream_out_t_Push_mioi_inst_stream_out_t_Push_mioi_idat
      = {10'b1000000000 , stream_out_t_Push_mioi_idat_255_198 , stream_out_t_Push_mioi_idat_197_195
      , stream_out_t_Push_mioi_idat_194_4 , stream_out_t_Push_mioi_idat_3_0};
  wire  nl_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_bfu_out_t_Push_mioi_inst_bfu_out_t_Push_mioi_oswt_unreg;
  assign nl_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_bfu_out_t_Push_mioi_inst_bfu_out_t_Push_mioi_oswt_unreg
      = while_and_1_tmp & (fsm_output[1]);
  wire [556:0] nl_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_bfu_out_t_Push_mioi_inst_bfu_out_t_Push_mioi_idat;
  assign nl_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_bfu_out_t_Push_mioi_inst_bfu_out_t_Push_mioi_idat
      = {bfu_out_t_Push_mioi_idat_556_291 , 3'b000 , reg_bfu_out_t_Push_mioi_idat_287_271_ftd
      , 1'b0 , reg_bfu_out_t_Push_mioi_idat_287_271_ftd , 14'b00000000000000 , bfu_out_t_Push_mioi_idat_270_19
      , 4'b0000 , (signext_11_9({bfu_out_t_Push_mioi_idat_12 , 4'b1000 , bfu_out_t_Push_mioi_idat_7_4}))
      , bfu_out_t_Push_mioi_idat_3_0};
  wire  nl_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_flow_table_read_rsp_t_Pop_mioi_inst_flow_table_read_rsp_t_Pop_mioi_oswt_unreg;
  assign nl_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_flow_table_read_rsp_t_Pop_mioi_inst_flow_table_read_rsp_t_Pop_mioi_oswt_unreg
      = and_dcpl_9 & (fsm_output[1]);
  wire mux_3_nl;
  wire or_12_nl;
  wire or_11_nl;
  wire  nl_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_flow_table_write_req_t_Push_mioi_inst_flow_table_write_req_t_Push_mioi_oswt_unreg;
  assign or_12_nl = pktReassembly_pktReassembly_stage1_core_else_conc_itm_1_0 | pktReassembly_pktReassembly_stage1_core_else_conc_itm_1_1;
  assign or_11_nl = (~ pktReassembly_pktReassembly_stage1_core_if_equal_itm_1) |
      pktReassembly_pktReassembly_stage1_core_if_if_if_slc_pktReassembly_pktReassembly_stage1_core_if_if_acc_10_itm_1;
  assign mux_3_nl = MUX_s_1_2_2(or_12_nl, or_11_nl, or_10_cse);
  assign nl_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_flow_table_write_req_t_Push_mioi_inst_flow_table_write_req_t_Push_mioi_oswt_unreg
      = (~(and_117_cse | mux_3_nl)) & while_and_1_tmp & (fsm_output[1]);
  wire [287:0] nl_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_flow_table_write_req_t_Push_mioi_inst_flow_table_write_req_t_Push_mioi_idat;
  assign nl_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_flow_table_write_req_t_Push_mioi_inst_flow_table_write_req_t_Push_mioi_idat
      = {flow_table_write_req_t_Push_mioi_idat_287_283 , flow_table_write_req_t_Push_mioi_idat_282_150
      , flow_table_write_req_t_Push_mioi_idat_149_118 , flow_table_write_req_t_Push_mioi_idat_117_22
      , 16'b0000000000000000 , flow_table_write_req_t_Push_mioi_idat_5_4 , flow_table_write_req_t_Push_mioi_idat_3_0};
  wire mux_7_nl;
  wire mux_6_nl;
  wire mux_5_nl;
  wire  nl_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_unlock_req_t_Push_mioi_inst_unlock_req_t_Push_mioi_oswt_unreg;
  assign mux_6_nl = MUX_s_1_2_2(and_117_cse, or_tmp_12, pktReassembly_pktReassembly_stage1_core_if_else_slc_32_itm_1);
  assign mux_5_nl = MUX_s_1_2_2(and_117_cse, or_tmp_12, pktReassembly_pktReassembly_stage1_core_if_if_if_slc_pktReassembly_pktReassembly_stage1_core_if_if_acc_10_itm_1);
  assign mux_7_nl = MUX_s_1_2_2(mux_6_nl, mux_5_nl, pktReassembly_pktReassembly_stage1_core_if_equal_itm_1);
  assign nl_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_unlock_req_t_Push_mioi_inst_unlock_req_t_Push_mioi_oswt_unreg
      = (~ mux_7_nl) & while_and_1_tmp & (fsm_output[1]);
  wire [287:0] nl_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_unlock_req_t_Push_mioi_inst_unlock_req_t_Push_mioi_idat;
  assign nl_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_unlock_req_t_Push_mioi_inst_unlock_req_t_Push_mioi_idat
      = {14'b00000000000000 , unlock_req_t_Push_mioi_idat_273_216 , unlock_req_t_Push_mioi_idat_215_213
      , unlock_req_t_Push_mioi_idat_212_22 , 18'b000000000000000001 , unlock_req_t_Push_mioi_idat_3_0};
  wire  nl_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_staller_inst_pktReassembly_stage1_flen_unreg;
  assign nl_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_staller_inst_pktReassembly_stage1_flen_unreg
      = ~((~ (fsm_output[1])) | while_and_3_tmp | while_and_2_tmp | while_and_1_tmp);
  inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_stream_out_t_Push_mioi
      pktReassembly_pktReassembly_stage1_pktReassembly_stage1_stream_out_t_Push_mioi_inst
      (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .stream_out_t_val(stream_out_t_val),
      .stream_out_t_rdy(stream_out_t_rdy),
      .stream_out_t_msg(stream_out_t_msg),
      .pktReassembly_stage1_wen(pktReassembly_stage1_wen),
      .pktReassembly_stage1_wten(pktReassembly_stage1_wten),
      .stream_out_t_Push_mioi_oswt_unreg(nl_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_stream_out_t_Push_mioi_inst_stream_out_t_Push_mioi_oswt_unreg),
      .stream_out_t_Push_mioi_bawt(stream_out_t_Push_mioi_bawt),
      .stream_out_t_Push_mioi_iswt0(stream_out_t_Push_mioi_iswt0),
      .stream_out_t_Push_mioi_wen_comp(stream_out_t_Push_mioi_wen_comp),
      .stream_out_t_Push_mioi_idat(nl_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_stream_out_t_Push_mioi_inst_stream_out_t_Push_mioi_idat[265:0])
    );
  inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_bfu_out_t_Push_mioi
      pktReassembly_pktReassembly_stage1_pktReassembly_stage1_bfu_out_t_Push_mioi_inst
      (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .bfu_out_t_val(bfu_out_t_val),
      .bfu_out_t_rdy(bfu_out_t_rdy),
      .bfu_out_t_msg(bfu_out_t_msg),
      .pktReassembly_stage1_wen(pktReassembly_stage1_wen),
      .pktReassembly_stage1_wten(pktReassembly_stage1_wten),
      .bfu_out_t_Push_mioi_oswt_unreg(nl_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_bfu_out_t_Push_mioi_inst_bfu_out_t_Push_mioi_oswt_unreg),
      .bfu_out_t_Push_mioi_bawt(bfu_out_t_Push_mioi_bawt),
      .bfu_out_t_Push_mioi_iswt0(bfu_out_t_Push_mioi_iswt0),
      .bfu_out_t_Push_mioi_wen_comp(bfu_out_t_Push_mioi_wen_comp),
      .bfu_out_t_Push_mioi_idat(nl_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_bfu_out_t_Push_mioi_inst_bfu_out_t_Push_mioi_idat[556:0])
    );
  inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_flow_table_read_rsp_t_Pop_mioi
      pktReassembly_pktReassembly_stage1_pktReassembly_stage1_flow_table_read_rsp_t_Pop_mioi_inst
      (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .flow_table_read_rsp_t_val(flow_table_read_rsp_t_val),
      .flow_table_read_rsp_t_rdy(flow_table_read_rsp_t_rdy),
      .flow_table_read_rsp_t_msg(flow_table_read_rsp_t_msg),
      .pktReassembly_stage1_wen(pktReassembly_stage1_wen),
      .pktReassembly_stage1_wten(pktReassembly_stage1_wten),
      .flow_table_read_rsp_t_Pop_mioi_oswt_unreg(nl_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_flow_table_read_rsp_t_Pop_mioi_inst_flow_table_read_rsp_t_Pop_mioi_oswt_unreg),
      .flow_table_read_rsp_t_Pop_mioi_bawt(flow_table_read_rsp_t_Pop_mioi_bawt),
      .flow_table_read_rsp_t_Pop_mioi_iswt0(flow_table_read_rsp_t_Pop_mioi_iswt0),
      .flow_table_read_rsp_t_Pop_mioi_wen_comp(flow_table_read_rsp_t_Pop_mioi_wen_comp),
      .flow_table_read_rsp_t_Pop_mioi_idat_mxwt(flow_table_read_rsp_t_Pop_mioi_idat_mxwt)
    );
  inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_flow_table_write_req_t_Push_mioi
      pktReassembly_pktReassembly_stage1_pktReassembly_stage1_flow_table_write_req_t_Push_mioi_inst
      (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .flow_table_write_req_t_val(flow_table_write_req_t_val),
      .flow_table_write_req_t_rdy(flow_table_write_req_t_rdy),
      .flow_table_write_req_t_msg(flow_table_write_req_t_msg),
      .pktReassembly_stage1_wen(pktReassembly_stage1_wen),
      .pktReassembly_stage1_wten(pktReassembly_stage1_wten),
      .flow_table_write_req_t_Push_mioi_oswt_unreg(nl_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_flow_table_write_req_t_Push_mioi_inst_flow_table_write_req_t_Push_mioi_oswt_unreg),
      .flow_table_write_req_t_Push_mioi_bawt(flow_table_write_req_t_Push_mioi_bawt),
      .flow_table_write_req_t_Push_mioi_iswt0(flow_table_write_req_t_Push_mioi_iswt0),
      .flow_table_write_req_t_Push_mioi_wen_comp(flow_table_write_req_t_Push_mioi_wen_comp),
      .flow_table_write_req_t_Push_mioi_idat(nl_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_flow_table_write_req_t_Push_mioi_inst_flow_table_write_req_t_Push_mioi_idat[287:0])
    );
  inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_unlock_req_t_Push_mioi
      pktReassembly_pktReassembly_stage1_pktReassembly_stage1_unlock_req_t_Push_mioi_inst
      (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .unlock_req_t_val(unlock_req_t_val),
      .unlock_req_t_rdy(unlock_req_t_rdy),
      .unlock_req_t_msg(unlock_req_t_msg),
      .pktReassembly_stage1_wen(pktReassembly_stage1_wen),
      .pktReassembly_stage1_wten(pktReassembly_stage1_wten),
      .unlock_req_t_Push_mioi_oswt_unreg(nl_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_unlock_req_t_Push_mioi_inst_unlock_req_t_Push_mioi_oswt_unreg),
      .unlock_req_t_Push_mioi_bawt(unlock_req_t_Push_mioi_bawt),
      .unlock_req_t_Push_mioi_iswt0(unlock_req_t_Push_mioi_iswt0),
      .unlock_req_t_Push_mioi_wen_comp(unlock_req_t_Push_mioi_wen_comp),
      .unlock_req_t_Push_mioi_idat(nl_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_unlock_req_t_Push_mioi_inst_unlock_req_t_Push_mioi_idat[287:0])
    );
  inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_req_rsp_fifo_cnsi
      pktReassembly_pktReassembly_stage1_pktReassembly_stage1_req_rsp_fifo_cnsi_inst
      (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .req_rsp_fifo_cns_dat(req_rsp_fifo_cns_dat),
      .req_rsp_fifo_cns_vld(req_rsp_fifo_cns_vld),
      .req_rsp_fifo_cns_rdy(req_rsp_fifo_cns_rdy),
      .pktReassembly_stage1_wen(pktReassembly_stage1_wen),
      .req_rsp_fifo_cnsi_oswt_unreg(or_tmp_36),
      .req_rsp_fifo_cnsi_bawt(req_rsp_fifo_cnsi_bawt),
      .req_rsp_fifo_cnsi_iswt0(req_rsp_fifo_cnsi_iswt0),
      .req_rsp_fifo_cnsi_wen_comp(req_rsp_fifo_cnsi_wen_comp),
      .req_rsp_fifo_cnsi_idat_mxwt(req_rsp_fifo_cnsi_idat_mxwt)
    );
  inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_staller pktReassembly_pktReassembly_stage1_pktReassembly_stage1_staller_inst
      (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .pktReassembly_stage1_wen(pktReassembly_stage1_wen),
      .pktReassembly_stage1_wten(pktReassembly_stage1_wten),
      .stream_out_t_Push_mioi_wen_comp(stream_out_t_Push_mioi_wen_comp),
      .bfu_out_t_Push_mioi_wen_comp(bfu_out_t_Push_mioi_wen_comp),
      .flow_table_read_rsp_t_Pop_mioi_wen_comp(flow_table_read_rsp_t_Pop_mioi_wen_comp),
      .flow_table_write_req_t_Push_mioi_wen_comp(flow_table_write_req_t_Push_mioi_wen_comp),
      .unlock_req_t_Push_mioi_wen_comp(unlock_req_t_Push_mioi_wen_comp),
      .req_rsp_fifo_cnsi_wen_comp(req_rsp_fifo_cnsi_wen_comp),
      .pktReassembly_stage1_flen_unreg(nl_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_staller_inst_pktReassembly_stage1_flen_unreg)
    );
  inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1_pktReassembly_stage1_fsm
      pktReassembly_pktReassembly_stage1_pktReassembly_stage1_pktReassembly_stage1_fsm_inst
      (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .pktReassembly_stage1_wen(pktReassembly_stage1_wen),
      .fsm_output(fsm_output)
    );
  assign nor_21_cse = ~((flow_table_read_rsp_read_slc_flow_table_read_rsp_t_Pop_mio_mrgout_dat_528_11_1_itm_1!=5'b00000));
  assign or_10_cse = (flow_table_read_rsp_read_slc_flow_table_read_rsp_t_Pop_mio_mrgout_dat_528_11_1_itm_1!=5'b00000);
  assign and_117_cse = (while_slc_out_set_bv_9_4_itm_2==6'b111111);
  assign and_118_cse = (while_slc_out_set_bv_9_4_itm_1==6'b111111);
  assign or_14_cse = (flow_table_read_rsp_t_Pop_mioi_idat_mxwt[521:517]!=5'b00000);
  assign or_15_cse = pktReassembly_pktReassembly_stage1_core_if_if_acc_itm_10_1 |
      (~ pktReassembly_pktReassembly_stage1_core_if_equal_tmp);
  assign or_16_cse = (flow_table_read_rsp_t_Pop_mioi_idat_mxwt[188]) | (flow_table_read_rsp_t_Pop_mioi_idat_mxwt[186]);
  assign stream_out_write_and_1_cse = pktReassembly_stage1_wen & (and_dcpl_20 | and_dcpl_14);
  assign bfu_out_write_last_and_cse = pktReassembly_stage1_wen & while_and_2_tmp;
  assign bfu_out_write_last_and_1_ssc = pktReassembly_stage1_wen & (and_dcpl_8 |
      bfu_out_t_Push_mioi_idat_12_4_mx0c1 | bfu_out_t_Push_mioi_idat_12_4_mx0c2);
  assign bfu_out_write_last_and_3_cse = pktReassembly_stage1_wen & (and_dcpl_20 |
      and_dcpl_9);
  assign mux_11_nl = MUX_s_1_2_2(nor_13_cse, nor_8_cse, or_14_cse);
  assign flow_table_write_req_write_2_and_cse = pktReassembly_stage1_wen & while_while_nand_14_cse
      & mux_11_nl & while_and_2_tmp;
  assign unlock_req_write_2_and_1_cse = pktReassembly_stage1_wen & (~(mux_tmp_10
      | (~ while_and_2_tmp)));
  assign while_and_8_cse = pktReassembly_stage1_wen & while_and_3_tmp;
  assign pktReassembly_pktReassembly_stage1_core_if_if_else_and_cse = pktReassembly_stage1_wen
      & (and_dcpl_46 | and_dcpl_63);
  assign pktReassembly_pktReassembly_stage1_core_else_and_2_cse = pktReassembly_stage1_wen
      & (~(and_118_cse | (flow_table_read_rsp_t_Pop_mioi_idat_mxwt[521:517]!=5'b00000)
      | (~ while_and_2_tmp)));
  assign pktReassembly_pktReassembly_stage1_core_if_if_else_and_2_cse = pktReassembly_stage1_wen
      & (~(nand_tmp_1 | or_dcpl_20 | pktReassembly_pktReassembly_stage1_core_if_if_acc_itm_10_1));
  assign while_and_3_tmp = req_rsp_fifo_cnsi_bawt & while_while_or_cse_1 & while_or_cse_1
      & while_or_1_cse_1 & while_or_19_cse_1 & while_or_20_cse_1 & while_or_21_cse_1
      & while_or_22_cse_1 & while_or_23_cse_1 & while_or_24_cse_1 & while_or_25_cse_1
      & while_or_26_cse_1 & while_or_27_cse_1 & while_or_28_cse_1 & while_or_29_cse_1
      & while_or_30_cse_1 & while_or_31_cse_1 & while_or_32_cse_1;
  assign while_and_2_tmp = while_stage_v_1 & while_while_or_cse_1 & while_or_cse_1
      & while_or_1_cse_1 & while_or_19_cse_1 & while_or_20_cse_1 & while_or_21_cse_1
      & while_or_22_cse_1 & while_or_23_cse_1 & while_or_24_cse_1 & while_or_25_cse_1
      & while_or_26_cse_1 & while_or_27_cse_1 & while_or_28_cse_1 & while_or_29_cse_1
      & while_or_30_cse_1 & while_or_31_cse_1 & while_or_32_cse_1;
  assign while_and_1_tmp = while_stage_v_2 & while_or_cse_1 & while_or_1_cse_1 &
      (flow_table_write_req_t_Push_mioi_bawt | (~(pktReassembly_pktReassembly_stage1_core_else_pktReassembly_pktReassembly_stage1_core_else_nor_cse_1
      & nor_21_cse & while_while_nand_cse_1))) & (unlock_req_t_Push_mioi_bawt | while_nand_5_cse_1)
      & (stream_out_t_Push_mioi_bawt | while_nand_5_cse_1) & (bfu_out_t_Push_mioi_bawt
      | while_nand_5_cse_1) & (bfu_out_t_Push_mioi_bawt | (~(pktReassembly_pktReassembly_stage1_core_if_if_if_slc_pktReassembly_pktReassembly_stage1_core_if_if_acc_10_itm_1
      & pktReassembly_pktReassembly_stage1_core_if_equal_itm_1 & or_10_cse & while_while_nand_cse_1)))
      & (flow_table_write_req_t_Push_mioi_bawt | (~(pktReassembly_pktReassembly_stage1_core_if_if_else_pktReassembly_pktReassembly_stage1_core_if_if_else_nor_cse_1
      & (~ pktReassembly_pktReassembly_stage1_core_if_if_if_slc_pktReassembly_pktReassembly_stage1_core_if_if_acc_10_itm_1)
      & pktReassembly_pktReassembly_stage1_core_if_equal_itm_1 & or_10_cse & while_while_nand_cse_1)))
      & (flow_table_write_req_t_Push_mioi_bawt | (~(pktReassembly_pktReassembly_stage1_core_if_if_else_pktReassembly_pktReassembly_stage1_core_if_if_else_or_cse_1
      & (~ pktReassembly_pktReassembly_stage1_core_if_if_if_slc_pktReassembly_pktReassembly_stage1_core_if_if_acc_10_itm_1)
      & pktReassembly_pktReassembly_stage1_core_if_equal_itm_1 & or_10_cse & while_while_nand_cse_1)))
      & (unlock_req_t_Push_mioi_bawt | while_nand_11_cse_1) & (stream_out_t_Push_mioi_bawt
      | while_nand_11_cse_1) & (bfu_out_t_Push_mioi_bawt | while_nand_11_cse_1) &
      (bfu_out_t_Push_mioi_bawt | (~(pktReassembly_pktReassembly_stage1_core_if_else_slc_32_itm_1
      & (~ pktReassembly_pktReassembly_stage1_core_if_equal_itm_1) & or_10_cse &
      while_while_nand_cse_1))) & (unlock_req_t_Push_mioi_bawt | pktReassembly_pktReassembly_stage1_core_if_else_slc_32_itm_1
      | pktReassembly_pktReassembly_stage1_core_if_equal_itm_1 | nor_21_cse | and_117_cse)
      & (stream_out_t_Push_mioi_bawt | pktReassembly_pktReassembly_stage1_core_if_else_slc_32_itm_1
      | pktReassembly_pktReassembly_stage1_core_if_equal_itm_1 | nor_21_cse | and_117_cse)
      & (bfu_out_t_Push_mioi_bawt | pktReassembly_pktReassembly_stage1_core_if_else_slc_32_itm_1
      | pktReassembly_pktReassembly_stage1_core_if_equal_itm_1 | nor_21_cse | and_117_cse);
  assign nl_pktReassembly_pktReassembly_stage1_core_if_if_acc_nl = ({1'b1 , (~ (flow_table_read_rsp_t_Pop_mioi_idat_mxwt[403:394]))})
      + 11'b00000000001;
  assign pktReassembly_pktReassembly_stage1_core_if_if_acc_nl = nl_pktReassembly_pktReassembly_stage1_core_if_if_acc_nl[10:0];
  assign pktReassembly_pktReassembly_stage1_core_if_if_acc_itm_10_1 = readslicef_11_1_10(pktReassembly_pktReassembly_stage1_core_if_if_acc_nl);
  assign nl_pktReassembly_pktReassembly_stage1_core_if_else_acc_nl = ({1'b1 , (flow_table_read_rsp_t_Pop_mioi_idat_mxwt[383:352])})
      + conv_u2u_32_33(~ (flow_table_read_rsp_t_Pop_mioi_idat_mxwt[139:108])) + 33'b000000000000000000000000000000001;
  assign pktReassembly_pktReassembly_stage1_core_if_else_acc_nl = nl_pktReassembly_pktReassembly_stage1_core_if_else_acc_nl[32:0];
  assign pktReassembly_pktReassembly_stage1_core_if_else_acc_itm_32_1 = readslicef_33_1_32(pktReassembly_pktReassembly_stage1_core_if_else_acc_nl);
  assign pktReassembly_pktReassembly_stage1_core_if_equal_tmp = (flow_table_read_rsp_t_Pop_mioi_idat_mxwt[139:108])
      == (flow_table_read_rsp_t_Pop_mioi_idat_mxwt[383:352]);
  assign while_while_nand_14_cse = ~((while_slc_out_set_bv_9_4_itm_1==6'b111111));
  assign while_while_or_cse_1 = flow_table_read_rsp_t_Pop_mioi_bawt | (~(while_while_nand_14_cse
      & while_stage_v_1));
  assign while_or_cse_1 = stream_out_t_Push_mioi_bawt | while_nand_2_cse_1;
  assign while_or_1_cse_1 = bfu_out_t_Push_mioi_bawt | while_nand_2_cse_1;
  assign while_or_19_cse_1 = flow_table_write_req_t_Push_mioi_bawt | (~(pktReassembly_pktReassembly_stage1_core_else_pktReassembly_pktReassembly_stage1_core_else_nor_cse_1
      & nor_21_cse & while_while_nand_cse_1 & while_stage_v_2));
  assign while_or_20_cse_1 = unlock_req_t_Push_mioi_bawt | while_nand_26_cse_1;
  assign while_or_21_cse_1 = stream_out_t_Push_mioi_bawt | while_nand_26_cse_1;
  assign while_or_22_cse_1 = bfu_out_t_Push_mioi_bawt | while_nand_26_cse_1;
  assign while_or_23_cse_1 = bfu_out_t_Push_mioi_bawt | (~(pktReassembly_pktReassembly_stage1_core_if_if_if_slc_pktReassembly_pktReassembly_stage1_core_if_if_acc_10_itm_1
      & pktReassembly_pktReassembly_stage1_core_if_equal_itm_1 & or_10_cse & while_while_nand_cse_1
      & while_stage_v_2));
  assign while_or_24_cse_1 = flow_table_write_req_t_Push_mioi_bawt | (~(pktReassembly_pktReassembly_stage1_core_if_if_else_pktReassembly_pktReassembly_stage1_core_if_if_else_nor_cse_1
      & (~ pktReassembly_pktReassembly_stage1_core_if_if_if_slc_pktReassembly_pktReassembly_stage1_core_if_if_acc_10_itm_1)
      & pktReassembly_pktReassembly_stage1_core_if_equal_itm_1 & or_10_cse & while_while_nand_cse_1
      & while_stage_v_2));
  assign while_or_25_cse_1 = flow_table_write_req_t_Push_mioi_bawt | (~(pktReassembly_pktReassembly_stage1_core_if_if_else_pktReassembly_pktReassembly_stage1_core_if_if_else_or_cse_1
      & (~ pktReassembly_pktReassembly_stage1_core_if_if_if_slc_pktReassembly_pktReassembly_stage1_core_if_if_acc_10_itm_1)
      & pktReassembly_pktReassembly_stage1_core_if_equal_itm_1 & or_10_cse & while_while_nand_cse_1
      & while_stage_v_2));
  assign while_or_26_cse_1 = unlock_req_t_Push_mioi_bawt | while_nand_32_cse_1;
  assign while_or_27_cse_1 = stream_out_t_Push_mioi_bawt | while_nand_32_cse_1;
  assign while_or_28_cse_1 = bfu_out_t_Push_mioi_bawt | while_nand_32_cse_1;
  assign while_or_29_cse_1 = bfu_out_t_Push_mioi_bawt | (~(pktReassembly_pktReassembly_stage1_core_if_else_slc_32_itm_1
      & (~ pktReassembly_pktReassembly_stage1_core_if_equal_itm_1) & or_10_cse &
      while_while_nand_cse_1 & while_stage_v_2));
  assign while_or_30_cse_1 = unlock_req_t_Push_mioi_bawt | while_nand_36_cse_1;
  assign while_or_31_cse_1 = stream_out_t_Push_mioi_bawt | while_nand_36_cse_1;
  assign while_or_32_cse_1 = bfu_out_t_Push_mioi_bawt | while_nand_36_cse_1;
  assign while_nand_36_cse_1 = ~((~(pktReassembly_pktReassembly_stage1_core_if_else_slc_32_itm_1
      | pktReassembly_pktReassembly_stage1_core_if_equal_itm_1 | nor_21_cse | and_117_cse))
      & while_stage_v_2);
  assign while_nand_32_cse_1 = ~((~ pktReassembly_pktReassembly_stage1_core_if_if_if_slc_pktReassembly_pktReassembly_stage1_core_if_if_acc_10_itm_1)
      & pktReassembly_pktReassembly_stage1_core_if_equal_itm_1 & or_10_cse & while_while_nand_cse_1
      & while_stage_v_2);
  assign while_nand_26_cse_1 = ~(nor_21_cse & while_while_nand_cse_1 & while_stage_v_2);
  assign while_while_nand_cse_1 = ~((while_slc_out_set_bv_9_4_itm_2==6'b111111));
  assign pktReassembly_pktReassembly_stage1_core_if_if_else_pktReassembly_pktReassembly_stage1_core_if_if_else_or_cse_1
      = pktReassembly_pktReassembly_stage1_core_if_if_else_conc_itm_1_1 | pktReassembly_pktReassembly_stage1_core_if_if_else_conc_itm_1_0;
  assign pktReassembly_pktReassembly_stage1_core_if_if_else_pktReassembly_pktReassembly_stage1_core_if_if_else_nor_cse_1
      = ~(pktReassembly_pktReassembly_stage1_core_if_if_else_conc_itm_1_1 | pktReassembly_pktReassembly_stage1_core_if_if_else_conc_itm_1_0);
  assign pktReassembly_pktReassembly_stage1_core_else_pktReassembly_pktReassembly_stage1_core_else_nor_cse_1
      = ~(pktReassembly_pktReassembly_stage1_core_else_conc_itm_1_1 | pktReassembly_pktReassembly_stage1_core_else_conc_itm_1_0);
  assign while_nand_5_cse_1 = ~(nor_21_cse & while_while_nand_cse_1);
  assign while_nand_11_cse_1 = ~((~ pktReassembly_pktReassembly_stage1_core_if_if_if_slc_pktReassembly_pktReassembly_stage1_core_if_if_acc_10_itm_1)
      & pktReassembly_pktReassembly_stage1_core_if_equal_itm_1 & or_10_cse & while_while_nand_cse_1);
  assign while_nand_2_cse_1 = ~((while_slc_out_set_bv_9_4_itm_2==6'b111111) & while_stage_v_2);
  assign nand_tmp_1 = (~((flow_table_read_rsp_t_Pop_mioi_idat_mxwt[521:517]!=5'b00000)))
      | and_118_cse;
  assign and_114_cse = pktReassembly_pktReassembly_stage1_core_if_if_acc_itm_10_1
      & pktReassembly_pktReassembly_stage1_core_if_equal_tmp;
  assign mux_2_nl = MUX_s_1_2_2(and_114_cse, or_15_cse, pktReassembly_pktReassembly_stage1_core_if_else_acc_itm_32_1);
  assign and_dcpl_8 = (nand_tmp_1 | (~ mux_2_nl)) & while_and_2_tmp;
  assign and_dcpl_9 = (~ and_118_cse) & while_and_2_tmp;
  assign or_tmp_12 = (flow_table_read_rsp_read_slc_flow_table_read_rsp_t_Pop_mio_mrgout_dat_528_11_1_itm_1!=5'b00000)
      | and_117_cse;
  assign or_tmp_14 = (flow_table_read_rsp_t_Pop_mioi_idat_mxwt[521:517]!=5'b00000)
      | and_118_cse;
  assign nor_8_cse = ~(pktReassembly_pktReassembly_stage1_core_if_if_acc_itm_10_1
      | (~ pktReassembly_pktReassembly_stage1_core_if_equal_tmp));
  assign mux_tmp_8 = MUX_s_1_2_2(or_tmp_14, and_118_cse, nor_8_cse);
  assign mux_9_nl = MUX_s_1_2_2(and_118_cse, or_tmp_14, and_114_cse);
  assign mux_tmp_10 = MUX_s_1_2_2(mux_9_nl, mux_tmp_8, pktReassembly_pktReassembly_stage1_core_if_else_acc_itm_32_1);
  assign and_dcpl_14 = (~ mux_tmp_10) & while_and_2_tmp;
  assign and_dcpl_20 = (while_slc_out_set_bv_9_4_itm_1==6'b111111) & while_and_2_tmp;
  assign and_dcpl_21 = (~ mux_tmp_8) & while_and_2_tmp;
  assign and_dcpl_22 = while_and_2_tmp & (~ pktReassembly_pktReassembly_stage1_core_if_equal_tmp);
  assign and_dcpl_24 = (~ nand_tmp_1) & and_dcpl_22 & (~ pktReassembly_pktReassembly_stage1_core_if_else_acc_itm_32_1);
  assign and_dcpl_26 = while_and_2_tmp & pktReassembly_pktReassembly_stage1_core_if_equal_tmp;
  assign nor_13_cse = ~((flow_table_read_rsp_t_Pop_mioi_idat_mxwt[188]) | (flow_table_read_rsp_t_Pop_mioi_idat_mxwt[186]));
  assign and_dcpl_33 = and_dcpl_26 & (~ pktReassembly_pktReassembly_stage1_core_if_if_acc_itm_10_1);
  assign and_dcpl_35 = (~ nand_tmp_1) & and_dcpl_33 & nor_13_cse;
  assign and_dcpl_43 = (~(and_118_cse | (flow_table_read_rsp_t_Pop_mioi_idat_mxwt[517])))
      & (flow_table_read_rsp_t_Pop_mioi_idat_mxwt[521:518]==4'b0000) & while_and_2_tmp
      & (~ (flow_table_read_rsp_t_Pop_mioi_idat_mxwt[186])) & (~ (flow_table_read_rsp_t_Pop_mioi_idat_mxwt[188]));
  assign and_dcpl_46 = (~ nand_tmp_1) & and_dcpl_33;
  assign and_dcpl_54 = or_tmp_14 & while_and_2_tmp;
  assign and_dcpl_63 = (nand_tmp_1 | or_15_cse) & while_and_2_tmp;
  assign or_dcpl_20 = ~(while_and_2_tmp & pktReassembly_pktReassembly_stage1_core_if_equal_tmp);
  assign or_tmp_29 = while_and_2_tmp & (fsm_output[1]);
  assign or_tmp_36 = while_and_3_tmp & (fsm_output[1]);
  assign bfu_out_t_Push_mioi_idat_12_4_mx0c1 = (~ nand_tmp_1) & and_dcpl_26 & pktReassembly_pktReassembly_stage1_core_if_if_acc_itm_10_1;
  assign bfu_out_t_Push_mioi_idat_12_4_mx0c2 = (~ nand_tmp_1) & and_dcpl_22 & pktReassembly_pktReassembly_stage1_core_if_else_acc_itm_32_1;
  assign flow_table_write_req_t_Push_mioi_idat_5_4_mx0c2 = (~ nand_tmp_1) & and_dcpl_33
      & or_16_cse;
  assign while_stage_v_2_mx0c1 = (~ while_and_2_tmp) & while_and_1_tmp & (fsm_output[1]);
  assign pktReassembly_pktReassembly_stage1_core_if_if_if_slc_pktReassembly_pktReassembly_stage1_core_if_if_acc_10_itm_1_mx0c1
      = (nand_tmp_1 | (~ pktReassembly_pktReassembly_stage1_core_if_equal_tmp)) &
      while_and_2_tmp;
  assign pktReassembly_pktReassembly_stage1_core_if_else_slc_32_itm_1_mx0c1 = (nand_tmp_1
      | pktReassembly_pktReassembly_stage1_core_if_equal_tmp) & while_and_2_tmp;
  assign while_stage_v_1_mx0c1 = while_and_2_tmp & (~ while_and_3_tmp) & (fsm_output[1]);
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      req_rsp_fifo_cnsi_iswt0 <= 1'b0;
    end
    else if ( pktReassembly_stage1_wen & (while_and_3_tmp | (fsm_output[0])) ) begin
      req_rsp_fifo_cnsi_iswt0 <= 1'b1;
    end
  end
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      stream_out_t_Push_mioi_iswt0 <= 1'b0;
      bfu_out_t_Push_mioi_iswt0 <= 1'b0;
      flow_table_read_rsp_t_Pop_mioi_iswt0 <= 1'b0;
      flow_table_write_req_t_Push_mioi_iswt0 <= 1'b0;
      unlock_req_t_Push_mioi_iswt0 <= 1'b0;
    end
    else if ( pktReassembly_stage1_wen ) begin
      stream_out_t_Push_mioi_iswt0 <= and_dcpl_8 & (fsm_output[1]);
      bfu_out_t_Push_mioi_iswt0 <= or_tmp_29;
      flow_table_read_rsp_t_Pop_mioi_iswt0 <= ((req_rsp_fifo_cnsi_idat_mxwt[9:4]!=6'b111111))
          & while_and_3_tmp & (fsm_output[1]);
      flow_table_write_req_t_Push_mioi_iswt0 <= (~(and_118_cse | mux_4_nl)) & while_and_2_tmp
          & (fsm_output[1]);
      unlock_req_t_Push_mioi_iswt0 <= and_dcpl_14 & (fsm_output[1]);
    end
  end
  always @(posedge i_clk) begin
    if ( pktReassembly_stage1_wen & (and_dcpl_20 | and_dcpl_21 | and_dcpl_24) ) begin
      stream_out_t_Push_mioi_idat_197_195 <= MUX1HOT_v_3_3_2((out_set_bv_sva_1_261_10[193:191]),
          (flow_table_read_rsp_t_Pop_mioi_idat_mxwt[197:195]), 3'b001, {and_dcpl_20
          , and_dcpl_21 , and_dcpl_24});
    end
  end
  always @(posedge i_clk) begin
    if ( stream_out_write_and_1_cse ) begin
      stream_out_t_Push_mioi_idat_194_4 <= MUX_v_191_2_2((out_set_bv_sva_1_261_10[190:0]),
          (flow_table_read_rsp_t_Pop_mioi_idat_mxwt[194:4]), and_dcpl_14);
      stream_out_t_Push_mioi_idat_255_198 <= MUX_v_58_2_2((out_set_bv_sva_1_261_10[251:194]),
          (flow_table_read_rsp_t_Pop_mioi_idat_mxwt[255:198]), and_dcpl_14);
      stream_out_t_Push_mioi_idat_3_0 <= MUX_v_4_2_2(out_set_bv_sva_1_3_0, (flow_table_read_rsp_t_Pop_mioi_idat_mxwt[3:0]),
          and_dcpl_14);
    end
  end
  always @(posedge i_clk) begin
    if ( bfu_out_write_last_and_cse ) begin
      bfu_out_t_Push_mioi_idat_270_19 <= MUX_v_252_2_2(252'b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,
          (flow_table_read_rsp_t_Pop_mioi_idat_mxwt[255:4]), bfu_out_write_last_not_5_nl);
      bfu_out_t_Push_mioi_idat_556_291 <= MUX_v_266_2_2(266'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,
          (flow_table_read_rsp_t_Pop_mioi_idat_mxwt[521:256]), bfu_out_write_last_not_7_nl);
      reg_bfu_out_t_Push_mioi_idat_287_271_ftd <= ~ and_dcpl_8;
    end
  end
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      pktReassembly_pktReassembly_stage1_core_else_conc_itm_1_1 <= 1'b0;
      pktReassembly_pktReassembly_stage1_core_else_conc_itm_1_0 <= 1'b0;
      pktReassembly_pktReassembly_stage1_core_if_equal_itm_1 <= 1'b0;
      while_slc_out_set_bv_9_4_itm_2 <= 6'b000000;
    end
    else if ( bfu_out_write_last_and_cse ) begin
      pktReassembly_pktReassembly_stage1_core_else_conc_itm_1_1 <= MUX_s_1_2_2((flow_table_read_rsp_t_Pop_mioi_idat_mxwt[188]),
          pktReassembly_pktReassembly_stage1_core_else_conc_itm_1, and_dcpl_54);
      pktReassembly_pktReassembly_stage1_core_else_conc_itm_1_0 <= MUX_s_1_2_2((flow_table_read_rsp_t_Pop_mioi_idat_mxwt[186]),
          pktReassembly_pktReassembly_stage1_core_else_conc_itm_0, and_dcpl_54);
      pktReassembly_pktReassembly_stage1_core_if_equal_itm_1 <= MUX_s_1_2_2(pktReassembly_pktReassembly_stage1_core_if_equal_tmp,
          pktReassembly_pktReassembly_stage1_core_if_equal_itm, and_61_nl);
      while_slc_out_set_bv_9_4_itm_2 <= while_slc_out_set_bv_9_4_itm_1;
    end
  end
  always @(posedge i_clk) begin
    if ( bfu_out_write_last_and_1_ssc ) begin
      bfu_out_t_Push_mioi_idat_12 <= bfu_out_t_Push_mioi_idat_12_4_mx0c1 | bfu_out_t_Push_mioi_idat_12_4_mx0c2;
      bfu_out_t_Push_mioi_idat_7_4 <= MUX1HOT_v_4_3_2(4'b0001, 4'b0110, 4'b1011,
          {and_dcpl_8 , bfu_out_t_Push_mioi_idat_12_4_mx0c1 , bfu_out_t_Push_mioi_idat_12_4_mx0c2});
    end
  end
  always @(posedge i_clk) begin
    if ( bfu_out_write_last_and_3_cse ) begin
      bfu_out_t_Push_mioi_idat_3_0 <= MUX_v_4_2_2(out_set_bv_sva_1_3_0, (flow_table_read_rsp_t_Pop_mioi_idat_mxwt[3:0]),
          and_dcpl_9);
    end
  end
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      flow_table_read_rsp_read_slc_flow_table_read_rsp_t_Pop_mio_mrgout_dat_528_11_1_itm_1
          <= 5'b00000;
    end
    else if ( bfu_out_write_last_and_3_cse ) begin
      flow_table_read_rsp_read_slc_flow_table_read_rsp_t_Pop_mio_mrgout_dat_528_11_1_itm_1
          <= MUX_v_5_2_2((flow_table_read_rsp_t_Pop_mioi_idat_mxwt[521:517]), flow_table_read_rsp_read_slc_flow_table_read_rsp_t_Pop_mio_mrgout_dat_528_11_1_itm,
          and_dcpl_20);
    end
  end
  always @(posedge i_clk) begin
    if ( flow_table_write_req_write_2_and_cse ) begin
      flow_table_write_req_t_Push_mioi_idat_117_22 <= flow_table_read_rsp_t_Pop_mioi_idat_mxwt[351:256];
      flow_table_write_req_t_Push_mioi_idat_282_150 <= flow_table_read_rsp_t_Pop_mioi_idat_mxwt[516:384];
      flow_table_write_req_t_Push_mioi_idat_3_0 <= flow_table_read_rsp_t_Pop_mioi_idat_mxwt[3:0];
    end
  end
  always @(posedge i_clk) begin
    if ( pktReassembly_stage1_wen & (((~(and_118_cse | mux_12_nl)) & while_and_2_tmp)
        | and_dcpl_35) ) begin
      flow_table_write_req_t_Push_mioi_idat_149_118 <= MUX_v_32_2_2((flow_table_read_rsp_t_Pop_mioi_idat_mxwt[383:352]),
          pktReassembly_pktReassembly_stage1_core_if_if_else_else_acc_nl, and_dcpl_35);
    end
  end
  always @(posedge i_clk) begin
    if ( pktReassembly_stage1_wen & (and_dcpl_43 | and_dcpl_35 | flow_table_write_req_t_Push_mioi_idat_5_4_mx0c2)
        ) begin
      flow_table_write_req_t_Push_mioi_idat_5_4 <= MUX_v_2_2_2(flow_table_write_req_write_2_mux_nl,
          2'b11, flow_table_write_req_t_Push_mioi_idat_5_4_mx0c2);
    end
  end
  always @(posedge i_clk) begin
    if ( pktReassembly_stage1_wen & (and_dcpl_43 | and_dcpl_46) ) begin
      flow_table_write_req_t_Push_mioi_idat_287_283 <= MUX_v_5_2_2(5'b10000, (flow_table_read_rsp_t_Pop_mioi_idat_mxwt[521:517]),
          and_dcpl_46);
    end
  end
  always @(posedge i_clk) begin
    if ( unlock_req_write_2_and_1_cse ) begin
      unlock_req_t_Push_mioi_idat_212_22 <= flow_table_read_rsp_t_Pop_mioi_idat_mxwt[194:4];
      unlock_req_t_Push_mioi_idat_273_216 <= flow_table_read_rsp_t_Pop_mioi_idat_mxwt[255:198];
      unlock_req_t_Push_mioi_idat_3_0 <= flow_table_read_rsp_t_Pop_mioi_idat_mxwt[3:0];
    end
  end
  always @(posedge i_clk) begin
    if ( pktReassembly_stage1_wen & (and_dcpl_21 | and_dcpl_24) ) begin
      unlock_req_t_Push_mioi_idat_215_213 <= MUX_v_3_2_2((flow_table_read_rsp_t_Pop_mioi_idat_mxwt[197:195]),
          3'b001, and_dcpl_24);
    end
  end
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      while_stage_v_2 <= 1'b0;
    end
    else if ( pktReassembly_stage1_wen & (or_tmp_29 | while_stage_v_2_mx0c1) ) begin
      while_stage_v_2 <= ~ while_stage_v_2_mx0c1;
    end
  end
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      pktReassembly_pktReassembly_stage1_core_if_if_if_slc_pktReassembly_pktReassembly_stage1_core_if_if_acc_10_itm_1
          <= 1'b0;
    end
    else if ( pktReassembly_stage1_wen & (((~ nand_tmp_1) & and_dcpl_26) | pktReassembly_pktReassembly_stage1_core_if_if_if_slc_pktReassembly_pktReassembly_stage1_core_if_if_acc_10_itm_1_mx0c1)
        ) begin
      pktReassembly_pktReassembly_stage1_core_if_if_if_slc_pktReassembly_pktReassembly_stage1_core_if_if_acc_10_itm_1
          <= MUX_s_1_2_2(pktReassembly_pktReassembly_stage1_core_if_if_acc_itm_10_1,
          pktReassembly_pktReassembly_stage1_core_if_if_if_slc_pktReassembly_pktReassembly_stage1_core_if_if_acc_10_itm,
          pktReassembly_pktReassembly_stage1_core_if_if_if_slc_pktReassembly_pktReassembly_stage1_core_if_if_acc_10_itm_1_mx0c1);
    end
  end
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      pktReassembly_pktReassembly_stage1_core_if_else_slc_32_itm_1 <= 1'b0;
    end
    else if ( pktReassembly_stage1_wen & (((~ nand_tmp_1) & and_dcpl_22) | pktReassembly_pktReassembly_stage1_core_if_else_slc_32_itm_1_mx0c1)
        ) begin
      pktReassembly_pktReassembly_stage1_core_if_else_slc_32_itm_1 <= MUX_s_1_2_2(pktReassembly_pktReassembly_stage1_core_if_else_acc_itm_32_1,
          pktReassembly_pktReassembly_stage1_core_if_else_slc_32_itm, pktReassembly_pktReassembly_stage1_core_if_else_slc_32_itm_1_mx0c1);
    end
  end
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      while_stage_v_1 <= 1'b0;
    end
    else if ( pktReassembly_stage1_wen & (or_tmp_36 | while_stage_v_1_mx0c1) ) begin
      while_stage_v_1 <= ~ while_stage_v_1_mx0c1;
    end
  end
  always @(posedge i_clk) begin
    if ( while_and_8_cse ) begin
      out_set_bv_sva_1_3_0 <= req_rsp_fifo_cnsi_idat_mxwt[3:0];
      out_set_bv_sva_1_261_10 <= req_rsp_fifo_cnsi_idat_mxwt[261:10];
    end
  end
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      while_slc_out_set_bv_9_4_itm_1 <= 6'b000000;
    end
    else if ( while_and_8_cse ) begin
      while_slc_out_set_bv_9_4_itm_1 <= req_rsp_fifo_cnsi_idat_mxwt[9:4];
    end
  end
  always @(posedge i_clk) begin
    if ( pktReassembly_pktReassembly_stage1_core_if_if_else_and_cse ) begin
      pktReassembly_pktReassembly_stage1_core_if_if_else_conc_itm_1_1 <= MUX_s_1_2_2((flow_table_read_rsp_t_Pop_mioi_idat_mxwt[188]),
          pktReassembly_pktReassembly_stage1_core_if_if_else_conc_itm_1, and_dcpl_63);
      pktReassembly_pktReassembly_stage1_core_if_if_else_conc_itm_1_0 <= MUX_s_1_2_2((flow_table_read_rsp_t_Pop_mioi_idat_mxwt[186]),
          pktReassembly_pktReassembly_stage1_core_if_if_else_conc_itm_0, and_dcpl_63);
    end
  end
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      pktReassembly_pktReassembly_stage1_core_else_conc_itm_1 <= 1'b0;
      pktReassembly_pktReassembly_stage1_core_else_conc_itm_0 <= 1'b0;
    end
    else if ( pktReassembly_pktReassembly_stage1_core_else_and_2_cse ) begin
      pktReassembly_pktReassembly_stage1_core_else_conc_itm_1 <= flow_table_read_rsp_t_Pop_mioi_idat_mxwt[188];
      pktReassembly_pktReassembly_stage1_core_else_conc_itm_0 <= flow_table_read_rsp_t_Pop_mioi_idat_mxwt[186];
    end
  end
  always @(posedge i_clk) begin
    if ( pktReassembly_pktReassembly_stage1_core_if_if_else_and_2_cse ) begin
      pktReassembly_pktReassembly_stage1_core_if_if_else_conc_itm_1 <= flow_table_read_rsp_t_Pop_mioi_idat_mxwt[188];
      pktReassembly_pktReassembly_stage1_core_if_if_else_conc_itm_0 <= flow_table_read_rsp_t_Pop_mioi_idat_mxwt[186];
    end
  end
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      pktReassembly_pktReassembly_stage1_core_if_if_if_slc_pktReassembly_pktReassembly_stage1_core_if_if_acc_10_itm
          <= 1'b0;
    end
    else if ( pktReassembly_stage1_wen & (~(nand_tmp_1 | or_dcpl_20)) ) begin
      pktReassembly_pktReassembly_stage1_core_if_if_if_slc_pktReassembly_pktReassembly_stage1_core_if_if_acc_10_itm
          <= pktReassembly_pktReassembly_stage1_core_if_if_acc_itm_10_1;
    end
  end
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      pktReassembly_pktReassembly_stage1_core_if_else_slc_32_itm <= 1'b0;
    end
    else if ( pktReassembly_stage1_wen & (~(nand_tmp_1 | (~ while_and_2_tmp) | pktReassembly_pktReassembly_stage1_core_if_equal_tmp))
        ) begin
      pktReassembly_pktReassembly_stage1_core_if_else_slc_32_itm <= pktReassembly_pktReassembly_stage1_core_if_else_acc_itm_32_1;
    end
  end
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      pktReassembly_pktReassembly_stage1_core_if_equal_itm <= 1'b0;
    end
    else if ( pktReassembly_stage1_wen & (~(nand_tmp_1 | (~ while_and_2_tmp))) )
        begin
      pktReassembly_pktReassembly_stage1_core_if_equal_itm <= pktReassembly_pktReassembly_stage1_core_if_equal_tmp;
    end
  end
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      flow_table_read_rsp_read_slc_flow_table_read_rsp_t_Pop_mio_mrgout_dat_528_11_1_itm
          <= 5'b00000;
    end
    else if ( pktReassembly_stage1_wen & (~(and_118_cse | (~ while_and_2_tmp))) )
        begin
      flow_table_read_rsp_read_slc_flow_table_read_rsp_t_Pop_mio_mrgout_dat_528_11_1_itm
          <= flow_table_read_rsp_t_Pop_mioi_idat_mxwt[521:517];
    end
  end
  assign mux_4_nl = MUX_s_1_2_2(or_16_cse, or_15_cse, or_14_cse);
  assign bfu_out_write_last_not_5_nl = ~ and_dcpl_8;
  assign bfu_out_write_last_not_7_nl = ~ and_dcpl_8;
  assign and_61_nl = nand_tmp_1 & while_and_2_tmp;
  assign nl_pktReassembly_pktReassembly_stage1_core_if_if_else_else_acc_nl = (flow_table_read_rsp_t_Pop_mioi_idat_mxwt[139:108])
      + conv_u2u_16_32(flow_table_read_rsp_t_Pop_mioi_idat_mxwt[155:140]);
  assign pktReassembly_pktReassembly_stage1_core_if_if_else_else_acc_nl = nl_pktReassembly_pktReassembly_stage1_core_if_if_else_else_acc_nl[31:0];
  assign or_30_nl = pktReassembly_pktReassembly_stage1_core_if_if_acc_itm_10_1 |
      (~(pktReassembly_pktReassembly_stage1_core_if_equal_tmp & or_16_cse));
  assign mux_12_nl = MUX_s_1_2_2(or_16_cse, or_30_nl, or_14_cse);
  assign flow_table_write_req_write_2_mux_nl = MUX_v_2_2_2(2'b01, 2'b10, and_dcpl_35);

  function automatic [2:0] MUX1HOT_v_3_3_2;
    input [2:0] input_2;
    input [2:0] input_1;
    input [2:0] input_0;
    input [2:0] sel;
    reg [2:0] result;
  begin
    result = input_0 & {3{sel[0]}};
    result = result | (input_1 & {3{sel[1]}});
    result = result | (input_2 & {3{sel[2]}});
    MUX1HOT_v_3_3_2 = result;
  end
  endfunction


  function automatic [3:0] MUX1HOT_v_4_3_2;
    input [3:0] input_2;
    input [3:0] input_1;
    input [3:0] input_0;
    input [2:0] sel;
    reg [3:0] result;
  begin
    result = input_0 & {4{sel[0]}};
    result = result | (input_1 & {4{sel[1]}});
    result = result | (input_2 & {4{sel[2]}});
    MUX1HOT_v_4_3_2 = result;
  end
  endfunction


  function automatic  MUX_s_1_2_2;
    input  input_0;
    input  input_1;
    input  sel;
    reg  result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_s_1_2_2 = result;
  end
  endfunction


  function automatic [190:0] MUX_v_191_2_2;
    input [190:0] input_0;
    input [190:0] input_1;
    input  sel;
    reg [190:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_191_2_2 = result;
  end
  endfunction


  function automatic [251:0] MUX_v_252_2_2;
    input [251:0] input_0;
    input [251:0] input_1;
    input  sel;
    reg [251:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_252_2_2 = result;
  end
  endfunction


  function automatic [265:0] MUX_v_266_2_2;
    input [265:0] input_0;
    input [265:0] input_1;
    input  sel;
    reg [265:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_266_2_2 = result;
  end
  endfunction


  function automatic [1:0] MUX_v_2_2_2;
    input [1:0] input_0;
    input [1:0] input_1;
    input  sel;
    reg [1:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_2_2_2 = result;
  end
  endfunction


  function automatic [31:0] MUX_v_32_2_2;
    input [31:0] input_0;
    input [31:0] input_1;
    input  sel;
    reg [31:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_32_2_2 = result;
  end
  endfunction


  function automatic [2:0] MUX_v_3_2_2;
    input [2:0] input_0;
    input [2:0] input_1;
    input  sel;
    reg [2:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_3_2_2 = result;
  end
  endfunction


  function automatic [3:0] MUX_v_4_2_2;
    input [3:0] input_0;
    input [3:0] input_1;
    input  sel;
    reg [3:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_4_2_2 = result;
  end
  endfunction


  function automatic [57:0] MUX_v_58_2_2;
    input [57:0] input_0;
    input [57:0] input_1;
    input  sel;
    reg [57:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_58_2_2 = result;
  end
  endfunction


  function automatic [4:0] MUX_v_5_2_2;
    input [4:0] input_0;
    input [4:0] input_1;
    input  sel;
    reg [4:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_5_2_2 = result;
  end
  endfunction


  function automatic [0:0] readslicef_11_1_10;
    input [10:0] vector;
    reg [10:0] tmp;
  begin
    tmp = vector >> 10;
    readslicef_11_1_10 = tmp[0:0];
  end
  endfunction


  function automatic [0:0] readslicef_33_1_32;
    input [32:0] vector;
    reg [32:0] tmp;
  begin
    tmp = vector >> 32;
    readslicef_33_1_32 = tmp[0:0];
  end
  endfunction


  function automatic [10:0] signext_11_9;
    input [8:0] vector;
  begin
    signext_11_9= {{2{vector[8]}}, vector};
  end
  endfunction


  function automatic [31:0] conv_u2u_16_32 ;
    input [15:0]  vector ;
  begin
    conv_u2u_16_32 = {{16{1'b0}}, vector};
  end
  endfunction


  function automatic [32:0] conv_u2u_32_33 ;
    input [31:0]  vector ;
  begin
    conv_u2u_32_33 = {1'b0, vector};
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    inputUnit_pktReassembly_pktReassembly_stage0_pktReassembly_stage0
// ------------------------------------------------------------------


module inputUnit_pktReassembly_pktReassembly_stage0_pktReassembly_stage0 (
  i_clk, i_rst, stream_in_t_val, stream_in_t_rdy, stream_in_t_msg, cmd_in_t_val,
      cmd_in_t_rdy, cmd_in_t_msg, flow_table_read_req_t_val, flow_table_read_req_t_rdy,
      flow_table_read_req_t_msg, req_rsp_fifo_cns_dat, req_rsp_fifo_cns_vld, req_rsp_fifo_cns_rdy
);
  input i_clk;
  input i_rst;
  input stream_in_t_val;
  output stream_in_t_rdy;
  input [265:0] stream_in_t_msg;
  input cmd_in_t_val;
  output cmd_in_t_rdy;
  input [312:0] cmd_in_t_msg;
  output flow_table_read_req_t_val;
  input flow_table_read_req_t_rdy;
  output [287:0] flow_table_read_req_t_msg;
  output [261:0] req_rsp_fifo_cns_dat;
  output req_rsp_fifo_cns_vld;
  input req_rsp_fifo_cns_rdy;


  // Interconnect Declarations
  wire pktReassembly_stage0_wen;
  wire pktReassembly_stage0_wten;
  wire cmd_in_t_Pop_mioi_bawt;
  wire cmd_in_t_Pop_mioi_wen_comp;
  wire [9:0] cmd_in_t_Pop_mioi_idat_mxwt;
  wire stream_in_t_Pop_mioi_bawt;
  wire stream_in_t_Pop_mioi_wen_comp;
  wire [248:0] stream_in_t_Pop_mioi_idat_mxwt;
  wire flow_table_read_req_t_Push_mioi_bawt;
  reg flow_table_read_req_t_Push_mioi_iswt0;
  wire flow_table_read_req_t_Push_mioi_wen_comp;
  wire req_rsp_fifo_cnsi_bawt;
  reg req_rsp_fifo_cnsi_iswt0;
  wire req_rsp_fifo_cnsi_wen_comp;
  reg [57:0] flow_table_read_req_t_Push_mioi_idat_273_216;
  reg flow_table_read_req_t_Push_mioi_idat_214;
  reg [190:0] flow_table_read_req_t_Push_mioi_idat_212_22;
  reg [3:0] flow_table_read_req_t_Push_mioi_idat_3_0;
  reg [57:0] req_rsp_fifo_cnsi_idat_261_204;
  reg req_rsp_fifo_cnsi_idat_202;
  reg [190:0] req_rsp_fifo_cnsi_idat_200_10;
  reg [5:0] req_rsp_fifo_cnsi_idat_9_4;
  reg [3:0] req_rsp_fifo_cnsi_idat_3_0;
  wire [1:0] fsm_output;
  wire pktReassembly_pktReassembly_stage0_core_nor_tmp;
  wire and_dcpl;
  wire or_dcpl_1;
  wire or_dcpl_2;
  wire and_dcpl_11;
  wire or_dcpl_3;
  wire and_dcpl_15;
  wire and_tmp_3;
  wire mux_tmp_2;
  wire and_dcpl_19;
  wire and_dcpl_20;
  wire and_dcpl_46;
  wire or_tmp_8;
  wire and_64_cse;
  wire while_stage_en_3;
  reg while_stage_v_1;
  wire pktReassembly_pktReassembly_stage0_core_else_nor_cse_1;
  wire while_nand_2_cse_1;
  wire while_nand_14_cse_1;
  wire pktReassembly_pktReassembly_stage0_core_else_pktReassembly_pktReassembly_stage0_core_else_nand_cse_1;
  wire while_nand_4_cse_1;
  reg [7:0] stream_in_read_slc_stream_in_t_Pop_mio_mrgout_dat_194_4_19_itm_1;
  reg [8:0] pktReassembly_pktReassembly_stage0_core_conc_itm_1_24_16;
  reg [15:0] pktReassembly_pktReassembly_stage0_core_conc_itm_1_15_0;
  reg reg_stream_in_t_Pop_mioi_iswt0_cse;
  wire pktReassembly_pktReassembly_stage0_core_if_and_1_cse;
  wire flow_table_read_req_write_and_cse;
  wire and_1_cse;
  wire or_17_cse;
  reg [7:0] stream_in_read_slc_stream_in_t_Pop_mio_mrgout_dat_194_4_19_itm;
  wire req_rsp_fifo_cnsi_idat_202_mx0c1;
  wire req_rsp_fifo_cnsi_idat_9_4_mx0c0;
  wire pktReassembly_pktReassembly_stage0_core_else_else_pktReassembly_pktReassembly_stage0_core_else_else_if_or_mdf_sva_mx0w0;

  wire nor_8_nl;
  wire mux_4_nl;
  wire mux_3_nl;

  // Interconnect Declarations for Component Instantiations 
  wire mux_1_nl;
  wire and_19_nl;
  wire  nl_pktReassembly_pktReassembly_stage0_pktReassembly_stage0_flow_table_read_req_t_Push_mioi_inst_flow_table_read_req_t_Push_mioi_oswt_unreg;
  assign and_19_nl = ((pktReassembly_pktReassembly_stage0_core_conc_itm_1_15_0!=16'b0000000000000000)
      | (pktReassembly_pktReassembly_stage0_core_conc_itm_1_24_16[0]) | (pktReassembly_pktReassembly_stage0_core_conc_itm_1_24_16[1])
      | (pktReassembly_pktReassembly_stage0_core_conc_itm_1_24_16[2]) | (pktReassembly_pktReassembly_stage0_core_conc_itm_1_24_16[3])
      | (pktReassembly_pktReassembly_stage0_core_conc_itm_1_24_16[5]) | (pktReassembly_pktReassembly_stage0_core_conc_itm_1_24_16[6])
      | (pktReassembly_pktReassembly_stage0_core_conc_itm_1_24_16[7]) | (pktReassembly_pktReassembly_stage0_core_conc_itm_1_24_16[8]))
      & (pktReassembly_pktReassembly_stage0_core_nor_tmp | flow_table_read_req_t_Push_mioi_bawt);
  assign mux_1_nl = MUX_s_1_2_2(flow_table_read_req_t_Push_mioi_bawt, and_19_nl,
      pktReassembly_pktReassembly_stage0_core_conc_itm_1_24_16[4]);
  assign nl_pktReassembly_pktReassembly_stage0_pktReassembly_stage0_flow_table_read_req_t_Push_mioi_inst_flow_table_read_req_t_Push_mioi_oswt_unreg
      = ((stream_in_read_slc_stream_in_t_Pop_mio_mrgout_dat_194_4_19_itm_1!=8'b00010001))
      & mux_1_nl & and_dcpl_11;
  wire [287:0] nl_pktReassembly_pktReassembly_stage0_pktReassembly_stage0_flow_table_read_req_t_Push_mioi_inst_flow_table_read_req_t_Push_mioi_idat;
  assign nl_pktReassembly_pktReassembly_stage0_pktReassembly_stage0_flow_table_read_req_t_Push_mioi_inst_flow_table_read_req_t_Push_mioi_idat
      = {14'b00000000000000 , flow_table_read_req_t_Push_mioi_idat_273_216 , 1'b0
      , flow_table_read_req_t_Push_mioi_idat_214 , 1'b0 , flow_table_read_req_t_Push_mioi_idat_212_22
      , 18'b000000000000000100 , flow_table_read_req_t_Push_mioi_idat_3_0};
  wire  nl_pktReassembly_pktReassembly_stage0_pktReassembly_stage0_req_rsp_fifo_cnsi_inst_req_rsp_fifo_cnsi_oswt_unreg;
  assign nl_pktReassembly_pktReassembly_stage0_pktReassembly_stage0_req_rsp_fifo_cnsi_inst_req_rsp_fifo_cnsi_oswt_unreg
      = while_stage_v_1 & req_rsp_fifo_cnsi_bawt & or_dcpl_1;
  wire [261:0] nl_pktReassembly_pktReassembly_stage0_pktReassembly_stage0_req_rsp_fifo_cnsi_inst_req_rsp_fifo_cnsi_idat;
  assign nl_pktReassembly_pktReassembly_stage0_pktReassembly_stage0_req_rsp_fifo_cnsi_inst_req_rsp_fifo_cnsi_idat
      = {req_rsp_fifo_cnsi_idat_261_204 , 1'b0 , req_rsp_fifo_cnsi_idat_202 , 1'b0
      , req_rsp_fifo_cnsi_idat_200_10 , req_rsp_fifo_cnsi_idat_9_4 , req_rsp_fifo_cnsi_idat_3_0};
  wire  nl_pktReassembly_pktReassembly_stage0_pktReassembly_stage0_staller_inst_pktReassembly_stage0_flen_unreg;
  assign nl_pktReassembly_pktReassembly_stage0_pktReassembly_stage0_staller_inst_pktReassembly_stage0_flen_unreg
      = ~((~ (fsm_output[1])) | while_stage_en_3 | (while_stage_v_1 & (req_rsp_fifo_cnsi_bawt
      | while_nand_2_cse_1) & (req_rsp_fifo_cnsi_bawt | (~((stream_in_read_slc_stream_in_t_Pop_mio_mrgout_dat_194_4_19_itm_1[4])
      & (stream_in_read_slc_stream_in_t_Pop_mio_mrgout_dat_194_4_19_itm_1[0]) & pktReassembly_pktReassembly_stage0_core_else_nor_cse_1
      & while_nand_2_cse_1))) & (req_rsp_fifo_cnsi_bawt | while_nand_4_cse_1) & (flow_table_read_req_t_Push_mioi_bawt
      | while_nand_4_cse_1)));
  inputUnit_pktReassembly_pktReassembly_stage0_pktReassembly_stage0_cmd_in_t_Pop_mioi
      pktReassembly_pktReassembly_stage0_pktReassembly_stage0_cmd_in_t_Pop_mioi_inst
      (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .cmd_in_t_val(cmd_in_t_val),
      .cmd_in_t_rdy(cmd_in_t_rdy),
      .cmd_in_t_msg(cmd_in_t_msg),
      .pktReassembly_stage0_wen(pktReassembly_stage0_wen),
      .pktReassembly_stage0_wten(pktReassembly_stage0_wten),
      .cmd_in_t_Pop_mioi_oswt_unreg(and_64_cse),
      .cmd_in_t_Pop_mioi_bawt(cmd_in_t_Pop_mioi_bawt),
      .cmd_in_t_Pop_mioi_iswt0(reg_stream_in_t_Pop_mioi_iswt0_cse),
      .cmd_in_t_Pop_mioi_wen_comp(cmd_in_t_Pop_mioi_wen_comp),
      .cmd_in_t_Pop_mioi_idat_mxwt(cmd_in_t_Pop_mioi_idat_mxwt)
    );
  inputUnit_pktReassembly_pktReassembly_stage0_pktReassembly_stage0_stream_in_t_Pop_mioi
      pktReassembly_pktReassembly_stage0_pktReassembly_stage0_stream_in_t_Pop_mioi_inst
      (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .stream_in_t_val(stream_in_t_val),
      .stream_in_t_rdy(stream_in_t_rdy),
      .stream_in_t_msg(stream_in_t_msg),
      .pktReassembly_stage0_wen(pktReassembly_stage0_wen),
      .pktReassembly_stage0_wten(pktReassembly_stage0_wten),
      .stream_in_t_Pop_mioi_oswt_unreg(and_64_cse),
      .stream_in_t_Pop_mioi_bawt(stream_in_t_Pop_mioi_bawt),
      .stream_in_t_Pop_mioi_iswt0(reg_stream_in_t_Pop_mioi_iswt0_cse),
      .stream_in_t_Pop_mioi_wen_comp(stream_in_t_Pop_mioi_wen_comp),
      .stream_in_t_Pop_mioi_idat_mxwt(stream_in_t_Pop_mioi_idat_mxwt)
    );
  inputUnit_pktReassembly_pktReassembly_stage0_pktReassembly_stage0_flow_table_read_req_t_Push_mioi
      pktReassembly_pktReassembly_stage0_pktReassembly_stage0_flow_table_read_req_t_Push_mioi_inst
      (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .flow_table_read_req_t_val(flow_table_read_req_t_val),
      .flow_table_read_req_t_rdy(flow_table_read_req_t_rdy),
      .flow_table_read_req_t_msg(flow_table_read_req_t_msg),
      .pktReassembly_stage0_wen(pktReassembly_stage0_wen),
      .pktReassembly_stage0_wten(pktReassembly_stage0_wten),
      .flow_table_read_req_t_Push_mioi_oswt_unreg(nl_pktReassembly_pktReassembly_stage0_pktReassembly_stage0_flow_table_read_req_t_Push_mioi_inst_flow_table_read_req_t_Push_mioi_oswt_unreg),
      .flow_table_read_req_t_Push_mioi_bawt(flow_table_read_req_t_Push_mioi_bawt),
      .flow_table_read_req_t_Push_mioi_iswt0(flow_table_read_req_t_Push_mioi_iswt0),
      .flow_table_read_req_t_Push_mioi_wen_comp(flow_table_read_req_t_Push_mioi_wen_comp),
      .flow_table_read_req_t_Push_mioi_idat(nl_pktReassembly_pktReassembly_stage0_pktReassembly_stage0_flow_table_read_req_t_Push_mioi_inst_flow_table_read_req_t_Push_mioi_idat[287:0])
    );
  inputUnit_pktReassembly_pktReassembly_stage0_pktReassembly_stage0_req_rsp_fifo_cnsi
      pktReassembly_pktReassembly_stage0_pktReassembly_stage0_req_rsp_fifo_cnsi_inst
      (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .req_rsp_fifo_cns_dat(req_rsp_fifo_cns_dat),
      .req_rsp_fifo_cns_vld(req_rsp_fifo_cns_vld),
      .req_rsp_fifo_cns_rdy(req_rsp_fifo_cns_rdy),
      .pktReassembly_stage0_wen(pktReassembly_stage0_wen),
      .req_rsp_fifo_cnsi_oswt_unreg(nl_pktReassembly_pktReassembly_stage0_pktReassembly_stage0_req_rsp_fifo_cnsi_inst_req_rsp_fifo_cnsi_oswt_unreg),
      .req_rsp_fifo_cnsi_bawt(req_rsp_fifo_cnsi_bawt),
      .req_rsp_fifo_cnsi_iswt0(req_rsp_fifo_cnsi_iswt0),
      .req_rsp_fifo_cnsi_wen_comp(req_rsp_fifo_cnsi_wen_comp),
      .req_rsp_fifo_cnsi_idat(nl_pktReassembly_pktReassembly_stage0_pktReassembly_stage0_req_rsp_fifo_cnsi_inst_req_rsp_fifo_cnsi_idat[261:0])
    );
  inputUnit_pktReassembly_pktReassembly_stage0_pktReassembly_stage0_staller pktReassembly_pktReassembly_stage0_pktReassembly_stage0_staller_inst
      (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .pktReassembly_stage0_wen(pktReassembly_stage0_wen),
      .pktReassembly_stage0_wten(pktReassembly_stage0_wten),
      .cmd_in_t_Pop_mioi_wen_comp(cmd_in_t_Pop_mioi_wen_comp),
      .stream_in_t_Pop_mioi_wen_comp(stream_in_t_Pop_mioi_wen_comp),
      .flow_table_read_req_t_Push_mioi_wen_comp(flow_table_read_req_t_Push_mioi_wen_comp),
      .req_rsp_fifo_cnsi_wen_comp(req_rsp_fifo_cnsi_wen_comp),
      .pktReassembly_stage0_flen_unreg(nl_pktReassembly_pktReassembly_stage0_pktReassembly_stage0_staller_inst_pktReassembly_stage0_flen_unreg)
    );
  inputUnit_pktReassembly_pktReassembly_stage0_pktReassembly_stage0_pktReassembly_stage0_fsm
      pktReassembly_pktReassembly_stage0_pktReassembly_stage0_pktReassembly_stage0_fsm_inst
      (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .pktReassembly_stage0_wen(pktReassembly_stage0_wen),
      .fsm_output(fsm_output)
    );
  assign pktReassembly_pktReassembly_stage0_core_if_and_1_cse = pktReassembly_stage0_wen
      & (~(and_dcpl_20 | or_dcpl_3));
  assign flow_table_read_req_write_and_cse = pktReassembly_stage0_wen & (~((~ mux_tmp_2)
      | or_dcpl_3));
  assign pktReassembly_pktReassembly_stage0_core_else_else_pktReassembly_pktReassembly_stage0_core_else_else_if_or_mdf_sva_mx0w0
      = (stream_in_t_Pop_mioi_idat_mxwt[151:136]!=16'b0000000000000000);
  assign while_stage_en_3 = cmd_in_t_Pop_mioi_bawt & stream_in_t_Pop_mioi_bawt &
      (req_rsp_fifo_cnsi_bawt | (~((pktReassembly_pktReassembly_stage0_core_conc_itm_1_24_16[4])
      & pktReassembly_pktReassembly_stage0_core_nor_tmp & while_stage_v_1))) & (req_rsp_fifo_cnsi_bawt
      | (~((stream_in_read_slc_stream_in_t_Pop_mio_mrgout_dat_194_4_19_itm_1[4])
      & (stream_in_read_slc_stream_in_t_Pop_mio_mrgout_dat_194_4_19_itm_1[0]) & pktReassembly_pktReassembly_stage0_core_else_nor_cse_1
      & while_nand_2_cse_1 & while_stage_v_1))) & (req_rsp_fifo_cnsi_bawt | while_nand_14_cse_1)
      & (flow_table_read_req_t_Push_mioi_bawt | while_nand_14_cse_1);
  assign pktReassembly_pktReassembly_stage0_core_nor_tmp = ~((pktReassembly_pktReassembly_stage0_core_conc_itm_1_24_16[8])
      | (pktReassembly_pktReassembly_stage0_core_conc_itm_1_24_16[7]) | (pktReassembly_pktReassembly_stage0_core_conc_itm_1_24_16[6])
      | (pktReassembly_pktReassembly_stage0_core_conc_itm_1_24_16[5]) | (pktReassembly_pktReassembly_stage0_core_conc_itm_1_24_16[3])
      | (pktReassembly_pktReassembly_stage0_core_conc_itm_1_24_16[2]) | (pktReassembly_pktReassembly_stage0_core_conc_itm_1_24_16[1])
      | (pktReassembly_pktReassembly_stage0_core_conc_itm_1_24_16[0]) | (pktReassembly_pktReassembly_stage0_core_conc_itm_1_15_0!=16'b0000000000000000));
  assign pktReassembly_pktReassembly_stage0_core_else_nor_cse_1 = ~((stream_in_read_slc_stream_in_t_Pop_mio_mrgout_dat_194_4_19_itm_1[7])
      | (stream_in_read_slc_stream_in_t_Pop_mio_mrgout_dat_194_4_19_itm_1[6]) | (stream_in_read_slc_stream_in_t_Pop_mio_mrgout_dat_194_4_19_itm_1[5])
      | (stream_in_read_slc_stream_in_t_Pop_mio_mrgout_dat_194_4_19_itm_1[3]) | (stream_in_read_slc_stream_in_t_Pop_mio_mrgout_dat_194_4_19_itm_1[2])
      | (stream_in_read_slc_stream_in_t_Pop_mio_mrgout_dat_194_4_19_itm_1[1]));
  assign while_nand_2_cse_1 = ~((pktReassembly_pktReassembly_stage0_core_conc_itm_1_24_16[4])
      & pktReassembly_pktReassembly_stage0_core_nor_tmp);
  assign while_nand_14_cse_1 = ~(pktReassembly_pktReassembly_stage0_core_else_pktReassembly_pktReassembly_stage0_core_else_nand_cse_1
      & while_nand_2_cse_1 & while_stage_v_1);
  assign pktReassembly_pktReassembly_stage0_core_else_pktReassembly_pktReassembly_stage0_core_else_nand_cse_1
      = ~((stream_in_read_slc_stream_in_t_Pop_mio_mrgout_dat_194_4_19_itm_1[4]) &
      (stream_in_read_slc_stream_in_t_Pop_mio_mrgout_dat_194_4_19_itm_1[0]) & pktReassembly_pktReassembly_stage0_core_else_nor_cse_1);
  assign while_nand_4_cse_1 = ~(pktReassembly_pktReassembly_stage0_core_else_pktReassembly_pktReassembly_stage0_core_else_nand_cse_1
      & while_nand_2_cse_1);
  assign and_dcpl = stream_in_t_Pop_mioi_bawt & cmd_in_t_Pop_mioi_bawt;
  assign and_1_cse = (pktReassembly_pktReassembly_stage0_core_conc_itm_1_24_16[4])
      & pktReassembly_pktReassembly_stage0_core_nor_tmp;
  assign or_dcpl_1 = ((stream_in_read_slc_stream_in_t_Pop_mio_mrgout_dat_194_4_19_itm_1==8'b00010001))
      | and_1_cse | flow_table_read_req_t_Push_mioi_bawt;
  assign or_dcpl_2 = ~((~(or_dcpl_1 & req_rsp_fifo_cnsi_bawt)) & while_stage_v_1);
  assign and_dcpl_11 = req_rsp_fifo_cnsi_bawt & while_stage_v_1;
  assign or_dcpl_3 = ~(stream_in_t_Pop_mioi_bawt & cmd_in_t_Pop_mioi_bawt);
  assign and_dcpl_15 = or_dcpl_1 & and_dcpl_11 & or_dcpl_3;
  assign and_tmp_3 = ((stream_in_t_Pop_mioi_idat_mxwt[190]) | (stream_in_t_Pop_mioi_idat_mxwt[189])
      | (stream_in_t_Pop_mioi_idat_mxwt[188]) | (stream_in_t_Pop_mioi_idat_mxwt[187])
      | (~ (stream_in_t_Pop_mioi_idat_mxwt[186])) | (stream_in_t_Pop_mioi_idat_mxwt[185])
      | (stream_in_t_Pop_mioi_idat_mxwt[184]) | (stream_in_t_Pop_mioi_idat_mxwt[183])
      | (stream_in_t_Pop_mioi_idat_mxwt[182]) | (stream_in_t_Pop_mioi_idat_mxwt[151])
      | (stream_in_t_Pop_mioi_idat_mxwt[150]) | (stream_in_t_Pop_mioi_idat_mxwt[149])
      | (stream_in_t_Pop_mioi_idat_mxwt[148]) | (stream_in_t_Pop_mioi_idat_mxwt[147])
      | (stream_in_t_Pop_mioi_idat_mxwt[146]) | (stream_in_t_Pop_mioi_idat_mxwt[145])
      | (stream_in_t_Pop_mioi_idat_mxwt[144]) | (stream_in_t_Pop_mioi_idat_mxwt[143])
      | (stream_in_t_Pop_mioi_idat_mxwt[142]) | (stream_in_t_Pop_mioi_idat_mxwt[141])
      | (stream_in_t_Pop_mioi_idat_mxwt[140]) | (stream_in_t_Pop_mioi_idat_mxwt[139])
      | (stream_in_t_Pop_mioi_idat_mxwt[138]) | (stream_in_t_Pop_mioi_idat_mxwt[137])
      | (stream_in_t_Pop_mioi_idat_mxwt[136])) & or_dcpl_2;
  assign or_17_cse = (stream_in_t_Pop_mioi_idat_mxwt[7:1]!=7'b0001000);
  assign nor_8_nl = ~((stream_in_t_Pop_mioi_idat_mxwt[0]) | (~ and_tmp_3));
  assign mux_tmp_2 = MUX_s_1_2_2(nor_8_nl, and_tmp_3, or_17_cse);
  assign and_dcpl_19 = mux_tmp_2 & and_dcpl;
  assign and_dcpl_20 = (~(((~((stream_in_read_slc_stream_in_t_Pop_mio_mrgout_dat_194_4_19_itm_1!=8'b00010001)))
      | and_1_cse | flow_table_read_req_t_Push_mioi_bawt) & req_rsp_fifo_cnsi_bawt))
      & while_stage_v_1;
  assign and_dcpl_46 = or_dcpl_2 & and_dcpl & (~((stream_in_t_Pop_mioi_idat_mxwt[137:136]!=2'b00)))
      & (~((stream_in_t_Pop_mioi_idat_mxwt[140:138]!=3'b000))) & (~((stream_in_t_Pop_mioi_idat_mxwt[143:141]!=3'b000)))
      & (~((stream_in_t_Pop_mioi_idat_mxwt[145:144]!=2'b00))) & (~((stream_in_t_Pop_mioi_idat_mxwt[148:146]!=3'b000)))
      & (~((stream_in_t_Pop_mioi_idat_mxwt[150:149]!=2'b00))) & (~((stream_in_t_Pop_mioi_idat_mxwt[151])
      | (stream_in_t_Pop_mioi_idat_mxwt[182]) | (stream_in_t_Pop_mioi_idat_mxwt[183])))
      & (~((stream_in_t_Pop_mioi_idat_mxwt[185:184]!=2'b00))) & (stream_in_t_Pop_mioi_idat_mxwt[186])
      & (~ (stream_in_t_Pop_mioi_idat_mxwt[187])) & (~ (stream_in_t_Pop_mioi_idat_mxwt[188]))
      & (~((stream_in_t_Pop_mioi_idat_mxwt[190:189]!=2'b00)));
  assign or_tmp_8 = (stream_in_t_Pop_mioi_idat_mxwt[190]) | (stream_in_t_Pop_mioi_idat_mxwt[189])
      | (stream_in_t_Pop_mioi_idat_mxwt[188]) | (stream_in_t_Pop_mioi_idat_mxwt[187])
      | (~ (stream_in_t_Pop_mioi_idat_mxwt[186])) | (stream_in_t_Pop_mioi_idat_mxwt[185])
      | (stream_in_t_Pop_mioi_idat_mxwt[184]) | (stream_in_t_Pop_mioi_idat_mxwt[183])
      | (stream_in_t_Pop_mioi_idat_mxwt[182]) | (stream_in_t_Pop_mioi_idat_mxwt[151])
      | (stream_in_t_Pop_mioi_idat_mxwt[150]) | (stream_in_t_Pop_mioi_idat_mxwt[149])
      | (stream_in_t_Pop_mioi_idat_mxwt[148]) | (stream_in_t_Pop_mioi_idat_mxwt[147])
      | (stream_in_t_Pop_mioi_idat_mxwt[146]) | (stream_in_t_Pop_mioi_idat_mxwt[145])
      | (stream_in_t_Pop_mioi_idat_mxwt[144]) | (stream_in_t_Pop_mioi_idat_mxwt[143])
      | (stream_in_t_Pop_mioi_idat_mxwt[142]) | (stream_in_t_Pop_mioi_idat_mxwt[141])
      | (stream_in_t_Pop_mioi_idat_mxwt[140]) | (stream_in_t_Pop_mioi_idat_mxwt[139])
      | (stream_in_t_Pop_mioi_idat_mxwt[138]) | (stream_in_t_Pop_mioi_idat_mxwt[137])
      | (stream_in_t_Pop_mioi_idat_mxwt[136]) | and_dcpl_20;
  assign and_64_cse = or_dcpl_2 & and_dcpl & (fsm_output[1]);
  assign req_rsp_fifo_cnsi_idat_202_mx0c1 = and_tmp_3 & and_dcpl & (stream_in_t_Pop_mioi_idat_mxwt[7:0]==8'b00010001);
  assign mux_3_nl = MUX_s_1_2_2(or_tmp_8, (~ or_dcpl_2), stream_in_t_Pop_mioi_idat_mxwt[0]);
  assign mux_4_nl = MUX_s_1_2_2(mux_3_nl, or_tmp_8, or_17_cse);
  assign req_rsp_fifo_cnsi_idat_9_4_mx0c0 = (~ mux_4_nl) & and_dcpl;
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      reg_stream_in_t_Pop_mioi_iswt0_cse <= 1'b0;
      flow_table_read_req_t_Push_mioi_iswt0 <= 1'b0;
    end
    else if ( pktReassembly_stage0_wen ) begin
      reg_stream_in_t_Pop_mioi_iswt0_cse <= ~((~ while_stage_en_3) & (fsm_output[1]));
      flow_table_read_req_t_Push_mioi_iswt0 <= and_dcpl_19 & (fsm_output[1]);
    end
  end
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      req_rsp_fifo_cnsi_iswt0 <= 1'b0;
    end
    else if ( pktReassembly_stage0_wen & (and_64_cse | (or_dcpl_1 & and_dcpl_11 &
        and_dcpl) | and_dcpl_15) ) begin
      req_rsp_fifo_cnsi_iswt0 <= ~ and_dcpl_15;
    end
  end
  always @(posedge i_clk) begin
    if ( pktReassembly_pktReassembly_stage0_core_if_and_1_cse ) begin
      req_rsp_fifo_cnsi_idat_200_10 <= stream_in_t_Pop_mioi_idat_mxwt[190:0];
      req_rsp_fifo_cnsi_idat_3_0 <= cmd_in_t_Pop_mioi_idat_mxwt[3:0];
      req_rsp_fifo_cnsi_idat_261_204 <= stream_in_t_Pop_mioi_idat_mxwt[248:191];
    end
  end
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      pktReassembly_pktReassembly_stage0_core_conc_itm_1_24_16 <= 9'b000000000;
      pktReassembly_pktReassembly_stage0_core_conc_itm_1_15_0 <= 16'b0000000000000000;
    end
    else if ( pktReassembly_pktReassembly_stage0_core_if_and_1_cse ) begin
      pktReassembly_pktReassembly_stage0_core_conc_itm_1_24_16 <= stream_in_t_Pop_mioi_idat_mxwt[190:182];
      pktReassembly_pktReassembly_stage0_core_conc_itm_1_15_0 <= stream_in_t_Pop_mioi_idat_mxwt[151:136];
    end
  end
  always @(posedge i_clk) begin
    if ( pktReassembly_stage0_wen & (and_dcpl_46 | req_rsp_fifo_cnsi_idat_202_mx0c1
        | and_dcpl_19) ) begin
      req_rsp_fifo_cnsi_idat_202 <= pktReassembly_pktReassembly_stage0_core_else_else_pktReassembly_pktReassembly_stage0_core_else_else_if_or_mdf_sva_mx0w0
          | req_rsp_fifo_cnsi_idat_202_mx0c1;
    end
  end
  always @(posedge i_clk) begin
    if ( pktReassembly_stage0_wen & (req_rsp_fifo_cnsi_idat_9_4_mx0c0 | and_dcpl_19)
        ) begin
      req_rsp_fifo_cnsi_idat_9_4 <= MUX_v_6_2_2((cmd_in_t_Pop_mioi_idat_mxwt[9:4]),
          6'b111111, req_rsp_fifo_cnsi_idat_9_4_mx0c0);
    end
  end
  always @(posedge i_clk) begin
    if ( flow_table_read_req_write_and_cse ) begin
      flow_table_read_req_t_Push_mioi_idat_214 <= pktReassembly_pktReassembly_stage0_core_else_else_pktReassembly_pktReassembly_stage0_core_else_else_if_or_mdf_sva_mx0w0;
      flow_table_read_req_t_Push_mioi_idat_212_22 <= stream_in_t_Pop_mioi_idat_mxwt[190:0];
      flow_table_read_req_t_Push_mioi_idat_273_216 <= stream_in_t_Pop_mioi_idat_mxwt[248:191];
      flow_table_read_req_t_Push_mioi_idat_3_0 <= cmd_in_t_Pop_mioi_idat_mxwt[3:0];
    end
  end
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      while_stage_v_1 <= 1'b0;
    end
    else if ( pktReassembly_stage0_wen & (and_64_cse | and_dcpl_15) ) begin
      while_stage_v_1 <= ~ and_dcpl_15;
    end
  end
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      stream_in_read_slc_stream_in_t_Pop_mio_mrgout_dat_194_4_19_itm_1 <= 8'b00000000;
    end
    else if ( pktReassembly_stage0_wen & ((and_tmp_3 & and_dcpl) | and_dcpl_46) )
        begin
      stream_in_read_slc_stream_in_t_Pop_mio_mrgout_dat_194_4_19_itm_1 <= MUX_v_8_2_2((stream_in_t_Pop_mioi_idat_mxwt[7:0]),
          stream_in_read_slc_stream_in_t_Pop_mio_mrgout_dat_194_4_19_itm, and_dcpl_46);
    end
  end
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      stream_in_read_slc_stream_in_t_Pop_mio_mrgout_dat_194_4_19_itm <= 8'b00000000;
    end
    else if ( pktReassembly_stage0_wen & (~((~ and_tmp_3) | or_dcpl_3)) ) begin
      stream_in_read_slc_stream_in_t_Pop_mio_mrgout_dat_194_4_19_itm <= stream_in_t_Pop_mioi_idat_mxwt[7:0];
    end
  end

  function automatic  MUX_s_1_2_2;
    input  input_0;
    input  input_1;
    input  sel;
    reg  result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_s_1_2_2 = result;
  end
  endfunction


  function automatic [5:0] MUX_v_6_2_2;
    input [5:0] input_0;
    input [5:0] input_1;
    input  sel;
    reg [5:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_6_2_2 = result;
  end
  endfunction


  function automatic [7:0] MUX_v_8_2_2;
    input [7:0] input_0;
    input [7:0] input_1;
    input  sel;
    reg [7:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_8_2_2 = result;
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    inputUnit_pktReassembly_pktReassembly_stage1
// ------------------------------------------------------------------


module inputUnit_pktReassembly_pktReassembly_stage1 (
  i_clk, i_rst, stream_out_t_val, stream_out_t_rdy, stream_out_t_msg, bfu_out_t_val,
      bfu_out_t_rdy, bfu_out_t_msg, unlock_req_t_val, unlock_req_t_rdy, unlock_req_t_msg,
      flow_table_read_rsp_t_val, flow_table_read_rsp_t_rdy, flow_table_read_rsp_t_msg,
      flow_table_write_req_t_val, flow_table_write_req_t_rdy, flow_table_write_req_t_msg,
      req_rsp_fifo_cns_dat, req_rsp_fifo_cns_vld, req_rsp_fifo_cns_rdy
);
  input i_clk;
  input i_rst;
  output stream_out_t_val;
  input stream_out_t_rdy;
  output [265:0] stream_out_t_msg;
  output bfu_out_t_val;
  input bfu_out_t_rdy;
  output [556:0] bfu_out_t_msg;
  output unlock_req_t_val;
  input unlock_req_t_rdy;
  output [287:0] unlock_req_t_msg;
  input flow_table_read_rsp_t_val;
  output flow_table_read_rsp_t_rdy;
  input [528:0] flow_table_read_rsp_t_msg;
  output flow_table_write_req_t_val;
  input flow_table_write_req_t_rdy;
  output [287:0] flow_table_write_req_t_msg;
  input [261:0] req_rsp_fifo_cns_dat;
  input req_rsp_fifo_cns_vld;
  output req_rsp_fifo_cns_rdy;



  // Interconnect Declarations for Component Instantiations 
  inputUnit_pktReassembly_pktReassembly_stage1_pktReassembly_stage1 pktReassembly_pktReassembly_stage1_pktReassembly_stage1_inst
      (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .stream_out_t_val(stream_out_t_val),
      .stream_out_t_rdy(stream_out_t_rdy),
      .stream_out_t_msg(stream_out_t_msg),
      .bfu_out_t_val(bfu_out_t_val),
      .bfu_out_t_rdy(bfu_out_t_rdy),
      .bfu_out_t_msg(bfu_out_t_msg),
      .unlock_req_t_val(unlock_req_t_val),
      .unlock_req_t_rdy(unlock_req_t_rdy),
      .unlock_req_t_msg(unlock_req_t_msg),
      .flow_table_read_rsp_t_val(flow_table_read_rsp_t_val),
      .flow_table_read_rsp_t_rdy(flow_table_read_rsp_t_rdy),
      .flow_table_read_rsp_t_msg(flow_table_read_rsp_t_msg),
      .flow_table_write_req_t_val(flow_table_write_req_t_val),
      .flow_table_write_req_t_rdy(flow_table_write_req_t_rdy),
      .flow_table_write_req_t_msg(flow_table_write_req_t_msg),
      .req_rsp_fifo_cns_dat(req_rsp_fifo_cns_dat),
      .req_rsp_fifo_cns_vld(req_rsp_fifo_cns_vld),
      .req_rsp_fifo_cns_rdy(req_rsp_fifo_cns_rdy)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    inputUnit_pktReassembly_pktReassembly_stage0
// ------------------------------------------------------------------


module inputUnit_pktReassembly_pktReassembly_stage0 (
  i_clk, i_rst, stream_in_t_val, stream_in_t_rdy, stream_in_t_msg, cmd_in_t_val,
      cmd_in_t_rdy, cmd_in_t_msg, flow_table_read_req_t_val, flow_table_read_req_t_rdy,
      flow_table_read_req_t_msg, req_rsp_fifo_cns_dat, req_rsp_fifo_cns_vld, req_rsp_fifo_cns_rdy
);
  input i_clk;
  input i_rst;
  input stream_in_t_val;
  output stream_in_t_rdy;
  input [265:0] stream_in_t_msg;
  input cmd_in_t_val;
  output cmd_in_t_rdy;
  input [312:0] cmd_in_t_msg;
  output flow_table_read_req_t_val;
  input flow_table_read_req_t_rdy;
  output [287:0] flow_table_read_req_t_msg;
  output [261:0] req_rsp_fifo_cns_dat;
  output req_rsp_fifo_cns_vld;
  input req_rsp_fifo_cns_rdy;



  // Interconnect Declarations for Component Instantiations 
  inputUnit_pktReassembly_pktReassembly_stage0_pktReassembly_stage0 pktReassembly_pktReassembly_stage0_pktReassembly_stage0_inst
      (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .stream_in_t_val(stream_in_t_val),
      .stream_in_t_rdy(stream_in_t_rdy),
      .stream_in_t_msg(stream_in_t_msg),
      .cmd_in_t_val(cmd_in_t_val),
      .cmd_in_t_rdy(cmd_in_t_rdy),
      .cmd_in_t_msg(cmd_in_t_msg),
      .flow_table_read_req_t_val(flow_table_read_req_t_val),
      .flow_table_read_req_t_rdy(flow_table_read_req_t_rdy),
      .flow_table_read_req_t_msg(flow_table_read_req_t_msg),
      .req_rsp_fifo_cns_dat(req_rsp_fifo_cns_dat),
      .req_rsp_fifo_cns_vld(req_rsp_fifo_cns_vld),
      .req_rsp_fifo_cns_rdy(req_rsp_fifo_cns_rdy)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    pktReassembly
// ------------------------------------------------------------------


module pktReassembly (
  i_clk, i_rst, stream_in_t_val, stream_in_t_rdy, stream_in_t_msg, stream_out_t_val,
      stream_out_t_rdy, stream_out_t_msg, cmd_in_t_val, cmd_in_t_rdy, cmd_in_t_msg,
      bfu_out_t_val, bfu_out_t_rdy, bfu_out_t_msg, unlock_req_t_val, unlock_req_t_rdy,
      unlock_req_t_msg, flow_table_read_req_t_val, flow_table_read_req_t_rdy, flow_table_read_req_t_msg,
      flow_table_read_rsp_t_val, flow_table_read_rsp_t_rdy, flow_table_read_rsp_t_msg,
      flow_table_write_req_t_val, flow_table_write_req_t_rdy, flow_table_write_req_t_msg
);
  input i_clk;
  input i_rst;
  input stream_in_t_val;
  output stream_in_t_rdy;
  input [265:0] stream_in_t_msg;
  output stream_out_t_val;
  input stream_out_t_rdy;
  output [265:0] stream_out_t_msg;
  input cmd_in_t_val;
  output cmd_in_t_rdy;
  input [312:0] cmd_in_t_msg;
  output bfu_out_t_val;
  input bfu_out_t_rdy;
  output [556:0] bfu_out_t_msg;
  output unlock_req_t_val;
  input unlock_req_t_rdy;
  output [287:0] unlock_req_t_msg;
  output flow_table_read_req_t_val;
  input flow_table_read_req_t_rdy;
  output [287:0] flow_table_read_req_t_msg;
  input flow_table_read_rsp_t_val;
  output flow_table_read_rsp_t_rdy;
  input [528:0] flow_table_read_rsp_t_msg;
  output flow_table_write_req_t_val;
  input flow_table_write_req_t_rdy;
  output [287:0] flow_table_write_req_t_msg;


  // Interconnect Declarations
  wire [261:0] req_rsp_fifo_cns_dat_n_pktReassembly_pktReassembly_stage0_inst;
  wire req_rsp_fifo_cns_rdy_n_pktReassembly_pktReassembly_stage0_inst;
  wire [261:0] req_rsp_fifo_cns_dat_n_pktReassembly_pktReassembly_stage1_inst;
  wire req_rsp_fifo_cns_vld_n_pktReassembly_pktReassembly_stage1_inst;
  wire req_rsp_fifo_cns_vld_n_pktReassembly_pktReassembly_stage0_inst_bud;
  wire req_rsp_fifo_cns_rdy_n_pktReassembly_pktReassembly_stage1_inst_bud;
  wire req_rsp_fifo_unc_2;
  wire req_rsp_fifo_idle;


  // Interconnect Declarations for Component Instantiations 
  ccs_pipe_v6 #(.rscid(32'sd39),
  .width(32'sd262),
  .sz_width(32'sd1),
  .fifo_sz(32'sd16),
  .log2_sz(32'sd4),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd1)) req_rsp_fifo_cns_pipe (
      .clk(i_clk),
      .en(1'b0),
      .arst(1'b1),
      .srst(i_rst),
      .din_rdy(req_rsp_fifo_cns_rdy_n_pktReassembly_pktReassembly_stage0_inst),
      .din_vld(req_rsp_fifo_cns_vld_n_pktReassembly_pktReassembly_stage0_inst_bud),
      .din(req_rsp_fifo_cns_dat_n_pktReassembly_pktReassembly_stage0_inst),
      .dout_rdy(req_rsp_fifo_cns_rdy_n_pktReassembly_pktReassembly_stage1_inst_bud),
      .dout_vld(req_rsp_fifo_cns_vld_n_pktReassembly_pktReassembly_stage1_inst),
      .dout(req_rsp_fifo_cns_dat_n_pktReassembly_pktReassembly_stage1_inst),
      .sz(req_rsp_fifo_unc_2),
      .sz_req(1'b0),
      .is_idle(req_rsp_fifo_idle)
    );
  inputUnit_pktReassembly_pktReassembly_stage0 pktReassembly_pktReassembly_stage0_inst
      (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .stream_in_t_val(stream_in_t_val),
      .stream_in_t_rdy(stream_in_t_rdy),
      .stream_in_t_msg(stream_in_t_msg),
      .cmd_in_t_val(cmd_in_t_val),
      .cmd_in_t_rdy(cmd_in_t_rdy),
      .cmd_in_t_msg(cmd_in_t_msg),
      .flow_table_read_req_t_val(flow_table_read_req_t_val),
      .flow_table_read_req_t_rdy(flow_table_read_req_t_rdy),
      .flow_table_read_req_t_msg(flow_table_read_req_t_msg),
      .req_rsp_fifo_cns_dat(req_rsp_fifo_cns_dat_n_pktReassembly_pktReassembly_stage0_inst),
      .req_rsp_fifo_cns_vld(req_rsp_fifo_cns_vld_n_pktReassembly_pktReassembly_stage0_inst_bud),
      .req_rsp_fifo_cns_rdy(req_rsp_fifo_cns_rdy_n_pktReassembly_pktReassembly_stage0_inst)
    );
  inputUnit_pktReassembly_pktReassembly_stage1 pktReassembly_pktReassembly_stage1_inst
      (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .stream_out_t_val(stream_out_t_val),
      .stream_out_t_rdy(stream_out_t_rdy),
      .stream_out_t_msg(stream_out_t_msg),
      .bfu_out_t_val(bfu_out_t_val),
      .bfu_out_t_rdy(bfu_out_t_rdy),
      .bfu_out_t_msg(bfu_out_t_msg),
      .unlock_req_t_val(unlock_req_t_val),
      .unlock_req_t_rdy(unlock_req_t_rdy),
      .unlock_req_t_msg(unlock_req_t_msg),
      .flow_table_read_rsp_t_val(flow_table_read_rsp_t_val),
      .flow_table_read_rsp_t_rdy(flow_table_read_rsp_t_rdy),
      .flow_table_read_rsp_t_msg(flow_table_read_rsp_t_msg),
      .flow_table_write_req_t_val(flow_table_write_req_t_val),
      .flow_table_write_req_t_rdy(flow_table_write_req_t_rdy),
      .flow_table_write_req_t_msg(flow_table_write_req_t_msg),
      .req_rsp_fifo_cns_dat(req_rsp_fifo_cns_dat_n_pktReassembly_pktReassembly_stage1_inst),
      .req_rsp_fifo_cns_vld(req_rsp_fifo_cns_vld_n_pktReassembly_pktReassembly_stage1_inst),
      .req_rsp_fifo_cns_rdy(req_rsp_fifo_cns_rdy_n_pktReassembly_pktReassembly_stage1_inst_bud)
    );
endmodule



