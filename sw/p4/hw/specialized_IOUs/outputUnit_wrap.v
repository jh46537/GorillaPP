
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
//  Generated date: Wed Nov  1 15:17:45 2023
// ----------------------------------------------------------------------

// 
// ------------------------------------------------------------------
//  Design Unit:    outputUnit_outputUnit_outputUnit_rsp_outputUnit_rsp_outputUnit_rsp_fsm
//  FSM Module
// ------------------------------------------------------------------


module outputUnit_outputUnit_outputUnit_rsp_outputUnit_rsp_outputUnit_rsp_fsm (
  i_clk, i_rst, outputUnit_rsp_wen, fsm_output
);
  input i_clk;
  input i_rst;
  input outputUnit_rsp_wen;
  output [5:0] fsm_output;
  reg [5:0] fsm_output;


  // FSM State Type Declaration for outputUnit_outputUnit_outputUnit_rsp_outputUnit_rsp_outputUnit_rsp_fsm_1
  parameter
    outputUnit_rsp_rlp_C_0 = 3'd0,
    while_C_0 = 3'd1,
    while_C_1 = 3'd2,
    while_C_2 = 3'd3,
    while_C_3 = 3'd4,
    while_C_4 = 3'd5;

  reg [2:0] state_var;
  reg [2:0] state_var_NS;


  // Interconnect Declarations for Component Instantiations 
  always @(*)
  begin : outputUnit_outputUnit_outputUnit_rsp_outputUnit_rsp_outputUnit_rsp_fsm_1
    case (state_var)
      while_C_0 : begin
        fsm_output = 6'b000010;
        state_var_NS = while_C_1;
      end
      while_C_1 : begin
        fsm_output = 6'b000100;
        state_var_NS = while_C_2;
      end
      while_C_2 : begin
        fsm_output = 6'b001000;
        state_var_NS = while_C_3;
      end
      while_C_3 : begin
        fsm_output = 6'b010000;
        state_var_NS = while_C_4;
      end
      while_C_4 : begin
        fsm_output = 6'b100000;
        state_var_NS = while_C_0;
      end
      // outputUnit_rsp_rlp_C_0
      default : begin
        fsm_output = 6'b000001;
        state_var_NS = while_C_0;
      end
    endcase
  end

  always @(posedge i_clk) begin
    if ( i_rst ) begin
      state_var <= outputUnit_rsp_rlp_C_0;
    end
    else if ( outputUnit_rsp_wen ) begin
      state_var <= state_var_NS;
    end
  end

endmodule

// ------------------------------------------------------------------
//  Design Unit:    outputUnit_outputUnit_outputUnit_rsp_outputUnit_rsp_staller
// ------------------------------------------------------------------


module outputUnit_outputUnit_outputUnit_rsp_outputUnit_rsp_staller (
  i_clk, i_rst, outputUnit_rsp_wen, outputUnit_rsp_wten, bfu_rdrsp_t_Pop_mioi_wen_comp,
      stream_out_t_Push_mioi_wen_comp, req_rsp_fifo_cnsi_wen_comp
);
  input i_clk;
  input i_rst;
  output outputUnit_rsp_wen;
  output outputUnit_rsp_wten;
  reg outputUnit_rsp_wten;
  input bfu_rdrsp_t_Pop_mioi_wen_comp;
  input stream_out_t_Push_mioi_wen_comp;
  input req_rsp_fifo_cnsi_wen_comp;



  // Interconnect Declarations for Component Instantiations 
  assign outputUnit_rsp_wen = bfu_rdrsp_t_Pop_mioi_wen_comp & stream_out_t_Push_mioi_wen_comp
      & req_rsp_fifo_cnsi_wen_comp;
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      outputUnit_rsp_wten <= 1'b0;
    end
    else begin
      outputUnit_rsp_wten <= ~ outputUnit_rsp_wen;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    outputUnit_outputUnit_outputUnit_rsp_outputUnit_rsp_req_rsp_fifo_cnsi_req_rsp_fifo_wait_dp
// ------------------------------------------------------------------


module outputUnit_outputUnit_outputUnit_rsp_outputUnit_rsp_req_rsp_fifo_cnsi_req_rsp_fifo_wait_dp
    (
  i_clk, i_rst, req_rsp_fifo_cnsi_oswt, req_rsp_fifo_cnsi_wen_comp, req_rsp_fifo_cnsi_idat_mxwt,
      req_rsp_fifo_cnsi_biwt, req_rsp_fifo_cnsi_bdwt, req_rsp_fifo_cnsi_bcwt, req_rsp_fifo_cnsi_idat
);
  input i_clk;
  input i_rst;
  input req_rsp_fifo_cnsi_oswt;
  output req_rsp_fifo_cnsi_wen_comp;
  output [35:0] req_rsp_fifo_cnsi_idat_mxwt;
  input req_rsp_fifo_cnsi_biwt;
  input req_rsp_fifo_cnsi_bdwt;
  output req_rsp_fifo_cnsi_bcwt;
  reg req_rsp_fifo_cnsi_bcwt;
  input [35:0] req_rsp_fifo_cnsi_idat;


  // Interconnect Declarations
  reg [35:0] req_rsp_fifo_cnsi_idat_bfwt;


  // Interconnect Declarations for Component Instantiations 
  assign req_rsp_fifo_cnsi_wen_comp = (~ req_rsp_fifo_cnsi_oswt) | req_rsp_fifo_cnsi_biwt
      | req_rsp_fifo_cnsi_bcwt;
  assign req_rsp_fifo_cnsi_idat_mxwt = MUX_v_36_2_2(req_rsp_fifo_cnsi_idat, req_rsp_fifo_cnsi_idat_bfwt,
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

  function automatic [35:0] MUX_v_36_2_2;
    input [35:0] input_0;
    input [35:0] input_1;
    input  sel;
    reg [35:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_36_2_2 = result;
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    outputUnit_outputUnit_outputUnit_rsp_outputUnit_rsp_req_rsp_fifo_cnsi_req_rsp_fifo_wait_ctrl
// ------------------------------------------------------------------


module outputUnit_outputUnit_outputUnit_rsp_outputUnit_rsp_req_rsp_fifo_cnsi_req_rsp_fifo_wait_ctrl
    (
  outputUnit_rsp_wen, req_rsp_fifo_cnsi_oswt, req_rsp_fifo_cnsi_biwt, req_rsp_fifo_cnsi_bdwt,
      req_rsp_fifo_cnsi_bcwt, req_rsp_fifo_cnsi_irdy_outputUnit_rsp_sct, req_rsp_fifo_cnsi_ivld
);
  input outputUnit_rsp_wen;
  input req_rsp_fifo_cnsi_oswt;
  output req_rsp_fifo_cnsi_biwt;
  output req_rsp_fifo_cnsi_bdwt;
  input req_rsp_fifo_cnsi_bcwt;
  output req_rsp_fifo_cnsi_irdy_outputUnit_rsp_sct;
  input req_rsp_fifo_cnsi_ivld;


  // Interconnect Declarations
  wire req_rsp_fifo_cnsi_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign req_rsp_fifo_cnsi_bdwt = req_rsp_fifo_cnsi_oswt & outputUnit_rsp_wen;
  assign req_rsp_fifo_cnsi_biwt = req_rsp_fifo_cnsi_ogwt & req_rsp_fifo_cnsi_ivld;
  assign req_rsp_fifo_cnsi_ogwt = req_rsp_fifo_cnsi_oswt & (~ req_rsp_fifo_cnsi_bcwt);
  assign req_rsp_fifo_cnsi_irdy_outputUnit_rsp_sct = req_rsp_fifo_cnsi_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    outputUnit_outputUnit_outputUnit_rsp_outputUnit_rsp_bfu_out_t_PushNB_mioi_bfu_out_t_PushNB_mio_wait_ctrl
// ------------------------------------------------------------------


module outputUnit_outputUnit_outputUnit_rsp_outputUnit_rsp_bfu_out_t_PushNB_mioi_bfu_out_t_PushNB_mio_wait_ctrl
    (
  outputUnit_rsp_wten, bfu_out_t_PushNB_mioi_iswt0, bfu_out_t_PushNB_mioi_biwt
);
  input outputUnit_rsp_wten;
  input bfu_out_t_PushNB_mioi_iswt0;
  output bfu_out_t_PushNB_mioi_biwt;



  // Interconnect Declarations for Component Instantiations 
  assign bfu_out_t_PushNB_mioi_biwt = (~ outputUnit_rsp_wten) & bfu_out_t_PushNB_mioi_iswt0;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    outputUnit_outputUnit_outputUnit_rsp_outputUnit_rsp_stream_out_t_Push_mioi_stream_out_t_Push_mio_wait_dp
// ------------------------------------------------------------------


module outputUnit_outputUnit_outputUnit_rsp_outputUnit_rsp_stream_out_t_Push_mioi_stream_out_t_Push_mio_wait_dp
    (
  i_clk, i_rst, stream_out_t_Push_mioi_oswt, stream_out_t_Push_mioi_wen_comp, stream_out_t_Push_mioi_biwt,
      stream_out_t_Push_mioi_bdwt, stream_out_t_Push_mioi_bcwt
);
  input i_clk;
  input i_rst;
  input stream_out_t_Push_mioi_oswt;
  output stream_out_t_Push_mioi_wen_comp;
  input stream_out_t_Push_mioi_biwt;
  input stream_out_t_Push_mioi_bdwt;
  output stream_out_t_Push_mioi_bcwt;
  reg stream_out_t_Push_mioi_bcwt;



  // Interconnect Declarations for Component Instantiations 
  assign stream_out_t_Push_mioi_wen_comp = (~ stream_out_t_Push_mioi_oswt) | stream_out_t_Push_mioi_biwt
      | stream_out_t_Push_mioi_bcwt;
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
//  Design Unit:    outputUnit_outputUnit_outputUnit_rsp_outputUnit_rsp_stream_out_t_Push_mioi_stream_out_t_Push_mio_wait_ctrl
// ------------------------------------------------------------------


module outputUnit_outputUnit_outputUnit_rsp_outputUnit_rsp_stream_out_t_Push_mioi_stream_out_t_Push_mio_wait_ctrl
    (
  outputUnit_rsp_wen, stream_out_t_Push_mioi_oswt, stream_out_t_Push_mioi_biwt, stream_out_t_Push_mioi_bdwt,
      stream_out_t_Push_mioi_bcwt, stream_out_t_Push_mioi_ivld_outputUnit_rsp_sct,
      stream_out_t_Push_mioi_irdy
);
  input outputUnit_rsp_wen;
  input stream_out_t_Push_mioi_oswt;
  output stream_out_t_Push_mioi_biwt;
  output stream_out_t_Push_mioi_bdwt;
  input stream_out_t_Push_mioi_bcwt;
  output stream_out_t_Push_mioi_ivld_outputUnit_rsp_sct;
  input stream_out_t_Push_mioi_irdy;


  // Interconnect Declarations
  wire stream_out_t_Push_mioi_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign stream_out_t_Push_mioi_bdwt = stream_out_t_Push_mioi_oswt & outputUnit_rsp_wen;
  assign stream_out_t_Push_mioi_biwt = stream_out_t_Push_mioi_ogwt & stream_out_t_Push_mioi_irdy;
  assign stream_out_t_Push_mioi_ogwt = stream_out_t_Push_mioi_oswt & (~ stream_out_t_Push_mioi_bcwt);
  assign stream_out_t_Push_mioi_ivld_outputUnit_rsp_sct = stream_out_t_Push_mioi_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    outputUnit_outputUnit_outputUnit_rsp_outputUnit_rsp_bfu_rdrsp_t_Pop_mioi_bfu_rdrsp_t_Pop_mio_wait_dp
// ------------------------------------------------------------------


module outputUnit_outputUnit_outputUnit_rsp_outputUnit_rsp_bfu_rdrsp_t_Pop_mioi_bfu_rdrsp_t_Pop_mio_wait_dp
    (
  i_clk, i_rst, bfu_rdrsp_t_Pop_mioi_oswt, bfu_rdrsp_t_Pop_mioi_wen_comp, bfu_rdrsp_t_Pop_mioi_idat_mxwt,
      bfu_rdrsp_t_Pop_mioi_biwt, bfu_rdrsp_t_Pop_mioi_bdwt, bfu_rdrsp_t_Pop_mioi_bcwt,
      bfu_rdrsp_t_Pop_mioi_idat
);
  input i_clk;
  input i_rst;
  input bfu_rdrsp_t_Pop_mioi_oswt;
  output bfu_rdrsp_t_Pop_mioi_wen_comp;
  output [351:0] bfu_rdrsp_t_Pop_mioi_idat_mxwt;
  input bfu_rdrsp_t_Pop_mioi_biwt;
  input bfu_rdrsp_t_Pop_mioi_bdwt;
  output bfu_rdrsp_t_Pop_mioi_bcwt;
  reg bfu_rdrsp_t_Pop_mioi_bcwt;
  input [383:0] bfu_rdrsp_t_Pop_mioi_idat;


  // Interconnect Declarations
  reg [191:0] bfu_rdrsp_t_Pop_mioi_idat_bfwt_383_192;
  reg [159:0] bfu_rdrsp_t_Pop_mioi_idat_bfwt_159_0;

  wire[191:0] bfu_rdrsp_read_mux_2_nl;
  wire[159:0] bfu_rdrsp_read_mux_3_nl;

  // Interconnect Declarations for Component Instantiations 
  assign bfu_rdrsp_t_Pop_mioi_wen_comp = (~ bfu_rdrsp_t_Pop_mioi_oswt) | bfu_rdrsp_t_Pop_mioi_biwt
      | bfu_rdrsp_t_Pop_mioi_bcwt;
  assign bfu_rdrsp_read_mux_2_nl = MUX_v_192_2_2((bfu_rdrsp_t_Pop_mioi_idat[383:192]),
      bfu_rdrsp_t_Pop_mioi_idat_bfwt_383_192, bfu_rdrsp_t_Pop_mioi_bcwt);
  assign bfu_rdrsp_read_mux_3_nl = MUX_v_160_2_2((bfu_rdrsp_t_Pop_mioi_idat[159:0]),
      bfu_rdrsp_t_Pop_mioi_idat_bfwt_159_0, bfu_rdrsp_t_Pop_mioi_bcwt);
  assign bfu_rdrsp_t_Pop_mioi_idat_mxwt = {bfu_rdrsp_read_mux_2_nl , bfu_rdrsp_read_mux_3_nl};
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      bfu_rdrsp_t_Pop_mioi_bcwt <= 1'b0;
    end
    else begin
      bfu_rdrsp_t_Pop_mioi_bcwt <= ~((~(bfu_rdrsp_t_Pop_mioi_bcwt | bfu_rdrsp_t_Pop_mioi_biwt))
          | bfu_rdrsp_t_Pop_mioi_bdwt);
    end
  end
  always @(posedge i_clk) begin
    if ( bfu_rdrsp_t_Pop_mioi_biwt ) begin
      bfu_rdrsp_t_Pop_mioi_idat_bfwt_383_192 <= bfu_rdrsp_t_Pop_mioi_idat[383:192];
      bfu_rdrsp_t_Pop_mioi_idat_bfwt_159_0 <= bfu_rdrsp_t_Pop_mioi_idat[159:0];
    end
  end

  function automatic [159:0] MUX_v_160_2_2;
    input [159:0] input_0;
    input [159:0] input_1;
    input  sel;
    reg [159:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_160_2_2 = result;
  end
  endfunction


  function automatic [191:0] MUX_v_192_2_2;
    input [191:0] input_0;
    input [191:0] input_1;
    input  sel;
    reg [191:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_192_2_2 = result;
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    outputUnit_outputUnit_outputUnit_rsp_outputUnit_rsp_bfu_rdrsp_t_Pop_mioi_bfu_rdrsp_t_Pop_mio_wait_ctrl
// ------------------------------------------------------------------


module outputUnit_outputUnit_outputUnit_rsp_outputUnit_rsp_bfu_rdrsp_t_Pop_mioi_bfu_rdrsp_t_Pop_mio_wait_ctrl
    (
  outputUnit_rsp_wen, bfu_rdrsp_t_Pop_mioi_oswt, bfu_rdrsp_t_Pop_mioi_biwt, bfu_rdrsp_t_Pop_mioi_bdwt,
      bfu_rdrsp_t_Pop_mioi_bcwt, bfu_rdrsp_t_Pop_mioi_ivld, bfu_rdrsp_t_Pop_mioi_irdy_outputUnit_rsp_sct
);
  input outputUnit_rsp_wen;
  input bfu_rdrsp_t_Pop_mioi_oswt;
  output bfu_rdrsp_t_Pop_mioi_biwt;
  output bfu_rdrsp_t_Pop_mioi_bdwt;
  input bfu_rdrsp_t_Pop_mioi_bcwt;
  input bfu_rdrsp_t_Pop_mioi_ivld;
  output bfu_rdrsp_t_Pop_mioi_irdy_outputUnit_rsp_sct;


  // Interconnect Declarations
  wire bfu_rdrsp_t_Pop_mioi_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign bfu_rdrsp_t_Pop_mioi_bdwt = bfu_rdrsp_t_Pop_mioi_oswt & outputUnit_rsp_wen;
  assign bfu_rdrsp_t_Pop_mioi_biwt = bfu_rdrsp_t_Pop_mioi_ogwt & bfu_rdrsp_t_Pop_mioi_ivld;
  assign bfu_rdrsp_t_Pop_mioi_ogwt = bfu_rdrsp_t_Pop_mioi_oswt & (~ bfu_rdrsp_t_Pop_mioi_bcwt);
  assign bfu_rdrsp_t_Pop_mioi_irdy_outputUnit_rsp_sct = bfu_rdrsp_t_Pop_mioi_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    outputUnit_outputUnit_outputUnit_req_outputUnit_req_outputUnit_req_fsm
//  FSM Module
// ------------------------------------------------------------------


module outputUnit_outputUnit_outputUnit_req_outputUnit_req_outputUnit_req_fsm (
  i_clk, i_rst, outputUnit_req_wen, fsm_output
);
  input i_clk;
  input i_rst;
  input outputUnit_req_wen;
  output [5:0] fsm_output;
  reg [5:0] fsm_output;


  // FSM State Type Declaration for outputUnit_outputUnit_outputUnit_req_outputUnit_req_outputUnit_req_fsm_1
  parameter
    outputUnit_req_rlp_C_0 = 3'd0,
    while_C_0 = 3'd1,
    while_C_1 = 3'd2,
    while_C_2 = 3'd3,
    while_C_3 = 3'd4,
    while_C_4 = 3'd5;

  reg [2:0] state_var;
  reg [2:0] state_var_NS;


  // Interconnect Declarations for Component Instantiations 
  always @(*)
  begin : outputUnit_outputUnit_outputUnit_req_outputUnit_req_outputUnit_req_fsm_1
    case (state_var)
      while_C_0 : begin
        fsm_output = 6'b000010;
        state_var_NS = while_C_1;
      end
      while_C_1 : begin
        fsm_output = 6'b000100;
        state_var_NS = while_C_2;
      end
      while_C_2 : begin
        fsm_output = 6'b001000;
        state_var_NS = while_C_3;
      end
      while_C_3 : begin
        fsm_output = 6'b010000;
        state_var_NS = while_C_4;
      end
      while_C_4 : begin
        fsm_output = 6'b100000;
        state_var_NS = while_C_0;
      end
      // outputUnit_req_rlp_C_0
      default : begin
        fsm_output = 6'b000001;
        state_var_NS = while_C_0;
      end
    endcase
  end

  always @(posedge i_clk) begin
    if ( i_rst ) begin
      state_var <= outputUnit_req_rlp_C_0;
    end
    else if ( outputUnit_req_wen ) begin
      state_var <= state_var_NS;
    end
  end

endmodule

// ------------------------------------------------------------------
//  Design Unit:    outputUnit_outputUnit_outputUnit_req_outputUnit_req_staller
// ------------------------------------------------------------------


module outputUnit_outputUnit_outputUnit_req_outputUnit_req_staller (
  outputUnit_req_wen, cmd_in_t_Pop_mioi_wen_comp, bfu_rdreq_t_Push_mioi_wen_comp,
      req_rsp_fifo_cnsi_wen_comp
);
  output outputUnit_req_wen;
  input cmd_in_t_Pop_mioi_wen_comp;
  input bfu_rdreq_t_Push_mioi_wen_comp;
  input req_rsp_fifo_cnsi_wen_comp;



  // Interconnect Declarations for Component Instantiations 
  assign outputUnit_req_wen = cmd_in_t_Pop_mioi_wen_comp & bfu_rdreq_t_Push_mioi_wen_comp
      & req_rsp_fifo_cnsi_wen_comp;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    outputUnit_outputUnit_outputUnit_req_outputUnit_req_req_rsp_fifo_cnsi_req_rsp_fifo_wait_dp
// ------------------------------------------------------------------


module outputUnit_outputUnit_outputUnit_req_outputUnit_req_req_rsp_fifo_cnsi_req_rsp_fifo_wait_dp
    (
  i_clk, i_rst, req_rsp_fifo_cnsi_oswt, req_rsp_fifo_cnsi_wen_comp, req_rsp_fifo_cnsi_biwt,
      req_rsp_fifo_cnsi_bdwt, req_rsp_fifo_cnsi_bcwt
);
  input i_clk;
  input i_rst;
  input req_rsp_fifo_cnsi_oswt;
  output req_rsp_fifo_cnsi_wen_comp;
  input req_rsp_fifo_cnsi_biwt;
  input req_rsp_fifo_cnsi_bdwt;
  output req_rsp_fifo_cnsi_bcwt;
  reg req_rsp_fifo_cnsi_bcwt;



  // Interconnect Declarations for Component Instantiations 
  assign req_rsp_fifo_cnsi_wen_comp = (~ req_rsp_fifo_cnsi_oswt) | req_rsp_fifo_cnsi_biwt
      | req_rsp_fifo_cnsi_bcwt;
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
//  Design Unit:    outputUnit_outputUnit_outputUnit_req_outputUnit_req_req_rsp_fifo_cnsi_req_rsp_fifo_wait_ctrl
// ------------------------------------------------------------------


module outputUnit_outputUnit_outputUnit_req_outputUnit_req_req_rsp_fifo_cnsi_req_rsp_fifo_wait_ctrl
    (
  outputUnit_req_wen, req_rsp_fifo_cnsi_oswt, req_rsp_fifo_cnsi_biwt, req_rsp_fifo_cnsi_bdwt,
      req_rsp_fifo_cnsi_bcwt, req_rsp_fifo_cnsi_irdy, req_rsp_fifo_cnsi_ivld_outputUnit_req_sct
);
  input outputUnit_req_wen;
  input req_rsp_fifo_cnsi_oswt;
  output req_rsp_fifo_cnsi_biwt;
  output req_rsp_fifo_cnsi_bdwt;
  input req_rsp_fifo_cnsi_bcwt;
  input req_rsp_fifo_cnsi_irdy;
  output req_rsp_fifo_cnsi_ivld_outputUnit_req_sct;


  // Interconnect Declarations
  wire req_rsp_fifo_cnsi_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign req_rsp_fifo_cnsi_bdwt = req_rsp_fifo_cnsi_oswt & outputUnit_req_wen;
  assign req_rsp_fifo_cnsi_biwt = req_rsp_fifo_cnsi_ogwt & req_rsp_fifo_cnsi_irdy;
  assign req_rsp_fifo_cnsi_ogwt = req_rsp_fifo_cnsi_oswt & (~ req_rsp_fifo_cnsi_bcwt);
  assign req_rsp_fifo_cnsi_ivld_outputUnit_req_sct = req_rsp_fifo_cnsi_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    outputUnit_outputUnit_outputUnit_req_outputUnit_req_bfu_rdreq_t_Push_mioi_bfu_rdreq_t_Push_mio_wait_dp
// ------------------------------------------------------------------


module outputUnit_outputUnit_outputUnit_req_outputUnit_req_bfu_rdreq_t_Push_mioi_bfu_rdreq_t_Push_mio_wait_dp
    (
  i_clk, i_rst, bfu_rdreq_t_Push_mioi_oswt, bfu_rdreq_t_Push_mioi_wen_comp, bfu_rdreq_t_Push_mioi_biwt,
      bfu_rdreq_t_Push_mioi_bdwt, bfu_rdreq_t_Push_mioi_bcwt
);
  input i_clk;
  input i_rst;
  input bfu_rdreq_t_Push_mioi_oswt;
  output bfu_rdreq_t_Push_mioi_wen_comp;
  input bfu_rdreq_t_Push_mioi_biwt;
  input bfu_rdreq_t_Push_mioi_bdwt;
  output bfu_rdreq_t_Push_mioi_bcwt;
  reg bfu_rdreq_t_Push_mioi_bcwt;



  // Interconnect Declarations for Component Instantiations 
  assign bfu_rdreq_t_Push_mioi_wen_comp = (~ bfu_rdreq_t_Push_mioi_oswt) | bfu_rdreq_t_Push_mioi_biwt
      | bfu_rdreq_t_Push_mioi_bcwt;
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      bfu_rdreq_t_Push_mioi_bcwt <= 1'b0;
    end
    else begin
      bfu_rdreq_t_Push_mioi_bcwt <= ~((~(bfu_rdreq_t_Push_mioi_bcwt | bfu_rdreq_t_Push_mioi_biwt))
          | bfu_rdreq_t_Push_mioi_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    outputUnit_outputUnit_outputUnit_req_outputUnit_req_bfu_rdreq_t_Push_mioi_bfu_rdreq_t_Push_mio_wait_ctrl
// ------------------------------------------------------------------


module outputUnit_outputUnit_outputUnit_req_outputUnit_req_bfu_rdreq_t_Push_mioi_bfu_rdreq_t_Push_mio_wait_ctrl
    (
  outputUnit_req_wen, bfu_rdreq_t_Push_mioi_oswt, bfu_rdreq_t_Push_mioi_biwt, bfu_rdreq_t_Push_mioi_bdwt,
      bfu_rdreq_t_Push_mioi_bcwt, bfu_rdreq_t_Push_mioi_ivld_outputUnit_req_sct,
      bfu_rdreq_t_Push_mioi_irdy
);
  input outputUnit_req_wen;
  input bfu_rdreq_t_Push_mioi_oswt;
  output bfu_rdreq_t_Push_mioi_biwt;
  output bfu_rdreq_t_Push_mioi_bdwt;
  input bfu_rdreq_t_Push_mioi_bcwt;
  output bfu_rdreq_t_Push_mioi_ivld_outputUnit_req_sct;
  input bfu_rdreq_t_Push_mioi_irdy;


  // Interconnect Declarations
  wire bfu_rdreq_t_Push_mioi_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign bfu_rdreq_t_Push_mioi_bdwt = bfu_rdreq_t_Push_mioi_oswt & outputUnit_req_wen;
  assign bfu_rdreq_t_Push_mioi_biwt = bfu_rdreq_t_Push_mioi_ogwt & bfu_rdreq_t_Push_mioi_irdy;
  assign bfu_rdreq_t_Push_mioi_ogwt = bfu_rdreq_t_Push_mioi_oswt & (~ bfu_rdreq_t_Push_mioi_bcwt);
  assign bfu_rdreq_t_Push_mioi_ivld_outputUnit_req_sct = bfu_rdreq_t_Push_mioi_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    outputUnit_outputUnit_outputUnit_req_outputUnit_req_cmd_in_t_Pop_mioi_cmd_in_t_Pop_mio_wait_ctrl
// ------------------------------------------------------------------


module outputUnit_outputUnit_outputUnit_req_outputUnit_req_cmd_in_t_Pop_mioi_cmd_in_t_Pop_mio_wait_ctrl
    (
  cmd_in_t_Pop_mioi_iswt0, cmd_in_t_Pop_mioi_biwt, cmd_in_t_Pop_mioi_ivld
);
  input cmd_in_t_Pop_mioi_iswt0;
  output cmd_in_t_Pop_mioi_biwt;
  input cmd_in_t_Pop_mioi_ivld;



  // Interconnect Declarations for Component Instantiations 
  assign cmd_in_t_Pop_mioi_biwt = cmd_in_t_Pop_mioi_iswt0 & cmd_in_t_Pop_mioi_ivld;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    outputUnit_outputUnit_outputUnit_rsp_outputUnit_rsp_req_rsp_fifo_cnsi
// ------------------------------------------------------------------


module outputUnit_outputUnit_outputUnit_rsp_outputUnit_rsp_req_rsp_fifo_cnsi (
  i_clk, i_rst, req_rsp_fifo_cns_dat, req_rsp_fifo_cns_vld, req_rsp_fifo_cns_rdy,
      outputUnit_rsp_wen, req_rsp_fifo_cnsi_oswt, req_rsp_fifo_cnsi_wen_comp, req_rsp_fifo_cnsi_idat_mxwt
);
  input i_clk;
  input i_rst;
  input [35:0] req_rsp_fifo_cns_dat;
  input req_rsp_fifo_cns_vld;
  output req_rsp_fifo_cns_rdy;
  input outputUnit_rsp_wen;
  input req_rsp_fifo_cnsi_oswt;
  output req_rsp_fifo_cnsi_wen_comp;
  output [35:0] req_rsp_fifo_cnsi_idat_mxwt;


  // Interconnect Declarations
  wire req_rsp_fifo_cnsi_biwt;
  wire req_rsp_fifo_cnsi_bdwt;
  wire req_rsp_fifo_cnsi_bcwt;
  wire req_rsp_fifo_cnsi_irdy_outputUnit_rsp_sct;
  wire req_rsp_fifo_cnsi_ivld;
  wire [35:0] req_rsp_fifo_cnsi_idat;


  // Interconnect Declarations for Component Instantiations 
  ccs_in_wait_v1 #(.rscid(32'sd29),
  .width(32'sd36)) req_rsp_fifo_cnsi (
      .rdy(req_rsp_fifo_cns_rdy),
      .vld(req_rsp_fifo_cns_vld),
      .dat(req_rsp_fifo_cns_dat),
      .irdy(req_rsp_fifo_cnsi_irdy_outputUnit_rsp_sct),
      .ivld(req_rsp_fifo_cnsi_ivld),
      .idat(req_rsp_fifo_cnsi_idat)
    );
  outputUnit_outputUnit_outputUnit_rsp_outputUnit_rsp_req_rsp_fifo_cnsi_req_rsp_fifo_wait_ctrl
      outputUnit_outputUnit_rsp_outputUnit_rsp_req_rsp_fifo_cnsi_req_rsp_fifo_wait_ctrl_inst
      (
      .outputUnit_rsp_wen(outputUnit_rsp_wen),
      .req_rsp_fifo_cnsi_oswt(req_rsp_fifo_cnsi_oswt),
      .req_rsp_fifo_cnsi_biwt(req_rsp_fifo_cnsi_biwt),
      .req_rsp_fifo_cnsi_bdwt(req_rsp_fifo_cnsi_bdwt),
      .req_rsp_fifo_cnsi_bcwt(req_rsp_fifo_cnsi_bcwt),
      .req_rsp_fifo_cnsi_irdy_outputUnit_rsp_sct(req_rsp_fifo_cnsi_irdy_outputUnit_rsp_sct),
      .req_rsp_fifo_cnsi_ivld(req_rsp_fifo_cnsi_ivld)
    );
  outputUnit_outputUnit_outputUnit_rsp_outputUnit_rsp_req_rsp_fifo_cnsi_req_rsp_fifo_wait_dp
      outputUnit_outputUnit_rsp_outputUnit_rsp_req_rsp_fifo_cnsi_req_rsp_fifo_wait_dp_inst
      (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .req_rsp_fifo_cnsi_oswt(req_rsp_fifo_cnsi_oswt),
      .req_rsp_fifo_cnsi_wen_comp(req_rsp_fifo_cnsi_wen_comp),
      .req_rsp_fifo_cnsi_idat_mxwt(req_rsp_fifo_cnsi_idat_mxwt),
      .req_rsp_fifo_cnsi_biwt(req_rsp_fifo_cnsi_biwt),
      .req_rsp_fifo_cnsi_bdwt(req_rsp_fifo_cnsi_bdwt),
      .req_rsp_fifo_cnsi_bcwt(req_rsp_fifo_cnsi_bcwt),
      .req_rsp_fifo_cnsi_idat(req_rsp_fifo_cnsi_idat)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    outputUnit_outputUnit_outputUnit_rsp_outputUnit_rsp_bfu_out_t_PushNB_mioi
// ------------------------------------------------------------------


module outputUnit_outputUnit_outputUnit_rsp_outputUnit_rsp_bfu_out_t_PushNB_mioi
    (
  bfu_out_t_val, bfu_out_t_rdy, bfu_out_t_msg, outputUnit_rsp_wten, bfu_out_t_PushNB_mioi_iswt0,
      bfu_out_t_PushNB_mioi_idat
);
  output bfu_out_t_val;
  input bfu_out_t_rdy;
  output [36:0] bfu_out_t_msg;
  input outputUnit_rsp_wten;
  input bfu_out_t_PushNB_mioi_iswt0;
  input [36:0] bfu_out_t_PushNB_mioi_idat;


  // Interconnect Declarations
  wire bfu_out_t_PushNB_mioi_biwt;
  wire bfu_out_t_PushNB_mioi_irdy;


  // Interconnect Declarations for Component Instantiations 
  ccs_out_wait_v1 #(.rscid(32'sd27),
  .width(32'sd37)) bfu_out_t_PushNB_mioi (
      .vld(bfu_out_t_val),
      .rdy(bfu_out_t_rdy),
      .dat(bfu_out_t_msg),
      .ivld(bfu_out_t_PushNB_mioi_biwt),
      .irdy(bfu_out_t_PushNB_mioi_irdy),
      .idat(bfu_out_t_PushNB_mioi_idat)
    );
  outputUnit_outputUnit_outputUnit_rsp_outputUnit_rsp_bfu_out_t_PushNB_mioi_bfu_out_t_PushNB_mio_wait_ctrl
      outputUnit_outputUnit_rsp_outputUnit_rsp_bfu_out_t_PushNB_mioi_bfu_out_t_PushNB_mio_wait_ctrl_inst
      (
      .outputUnit_rsp_wten(outputUnit_rsp_wten),
      .bfu_out_t_PushNB_mioi_iswt0(bfu_out_t_PushNB_mioi_iswt0),
      .bfu_out_t_PushNB_mioi_biwt(bfu_out_t_PushNB_mioi_biwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    outputUnit_outputUnit_outputUnit_rsp_outputUnit_rsp_stream_out_t_Push_mioi
// ------------------------------------------------------------------


module outputUnit_outputUnit_outputUnit_rsp_outputUnit_rsp_stream_out_t_Push_mioi
    (
  i_clk, i_rst, stream_out_t_val, stream_out_t_rdy, stream_out_t_msg, outputUnit_rsp_wen,
      stream_out_t_Push_mioi_oswt, stream_out_t_Push_mioi_wen_comp, stream_out_t_Push_mioi_idat
);
  input i_clk;
  input i_rst;
  output stream_out_t_val;
  input stream_out_t_rdy;
  output [522:0] stream_out_t_msg;
  input outputUnit_rsp_wen;
  input stream_out_t_Push_mioi_oswt;
  output stream_out_t_Push_mioi_wen_comp;
  input [522:0] stream_out_t_Push_mioi_idat;


  // Interconnect Declarations
  wire stream_out_t_Push_mioi_biwt;
  wire stream_out_t_Push_mioi_bdwt;
  wire stream_out_t_Push_mioi_bcwt;
  wire stream_out_t_Push_mioi_ivld_outputUnit_rsp_sct;
  wire stream_out_t_Push_mioi_irdy;


  // Interconnect Declarations for Component Instantiations 
  wire [522:0] nl_stream_out_t_Push_mioi_idat;
  assign nl_stream_out_t_Push_mioi_idat = {1'b0 , (stream_out_t_Push_mioi_idat[521:517])
      , 1'b0 , (stream_out_t_Push_mioi_idat[515:0])};
  ccs_out_wait_v1 #(.rscid(32'sd26),
  .width(32'sd523)) stream_out_t_Push_mioi (
      .vld(stream_out_t_val),
      .rdy(stream_out_t_rdy),
      .dat(stream_out_t_msg),
      .ivld(stream_out_t_Push_mioi_ivld_outputUnit_rsp_sct),
      .irdy(stream_out_t_Push_mioi_irdy),
      .idat(nl_stream_out_t_Push_mioi_idat[522:0])
    );
  outputUnit_outputUnit_outputUnit_rsp_outputUnit_rsp_stream_out_t_Push_mioi_stream_out_t_Push_mio_wait_ctrl
      outputUnit_outputUnit_rsp_outputUnit_rsp_stream_out_t_Push_mioi_stream_out_t_Push_mio_wait_ctrl_inst
      (
      .outputUnit_rsp_wen(outputUnit_rsp_wen),
      .stream_out_t_Push_mioi_oswt(stream_out_t_Push_mioi_oswt),
      .stream_out_t_Push_mioi_biwt(stream_out_t_Push_mioi_biwt),
      .stream_out_t_Push_mioi_bdwt(stream_out_t_Push_mioi_bdwt),
      .stream_out_t_Push_mioi_bcwt(stream_out_t_Push_mioi_bcwt),
      .stream_out_t_Push_mioi_ivld_outputUnit_rsp_sct(stream_out_t_Push_mioi_ivld_outputUnit_rsp_sct),
      .stream_out_t_Push_mioi_irdy(stream_out_t_Push_mioi_irdy)
    );
  outputUnit_outputUnit_outputUnit_rsp_outputUnit_rsp_stream_out_t_Push_mioi_stream_out_t_Push_mio_wait_dp
      outputUnit_outputUnit_rsp_outputUnit_rsp_stream_out_t_Push_mioi_stream_out_t_Push_mio_wait_dp_inst
      (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .stream_out_t_Push_mioi_oswt(stream_out_t_Push_mioi_oswt),
      .stream_out_t_Push_mioi_wen_comp(stream_out_t_Push_mioi_wen_comp),
      .stream_out_t_Push_mioi_biwt(stream_out_t_Push_mioi_biwt),
      .stream_out_t_Push_mioi_bdwt(stream_out_t_Push_mioi_bdwt),
      .stream_out_t_Push_mioi_bcwt(stream_out_t_Push_mioi_bcwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    outputUnit_outputUnit_outputUnit_rsp_outputUnit_rsp_bfu_rdrsp_t_Pop_mioi
// ------------------------------------------------------------------


module outputUnit_outputUnit_outputUnit_rsp_outputUnit_rsp_bfu_rdrsp_t_Pop_mioi (
  i_clk, i_rst, bfu_rdrsp_t_val, bfu_rdrsp_t_rdy, bfu_rdrsp_t_msg, outputUnit_rsp_wen,
      bfu_rdrsp_t_Pop_mioi_oswt, bfu_rdrsp_t_Pop_mioi_wen_comp, bfu_rdrsp_t_Pop_mioi_idat_mxwt
);
  input i_clk;
  input i_rst;
  input bfu_rdrsp_t_val;
  output bfu_rdrsp_t_rdy;
  input [383:0] bfu_rdrsp_t_msg;
  input outputUnit_rsp_wen;
  input bfu_rdrsp_t_Pop_mioi_oswt;
  output bfu_rdrsp_t_Pop_mioi_wen_comp;
  output [351:0] bfu_rdrsp_t_Pop_mioi_idat_mxwt;


  // Interconnect Declarations
  wire bfu_rdrsp_t_Pop_mioi_biwt;
  wire bfu_rdrsp_t_Pop_mioi_bdwt;
  wire bfu_rdrsp_t_Pop_mioi_bcwt;
  wire bfu_rdrsp_t_Pop_mioi_ivld;
  wire bfu_rdrsp_t_Pop_mioi_irdy_outputUnit_rsp_sct;
  wire [383:0] bfu_rdrsp_t_Pop_mioi_idat;
  wire [351:0] bfu_rdrsp_t_Pop_mioi_idat_mxwt_pconst;


  // Interconnect Declarations for Component Instantiations 
  ccs_in_wait_v1 #(.rscid(32'sd25),
  .width(32'sd384)) bfu_rdrsp_t_Pop_mioi (
      .vld(bfu_rdrsp_t_val),
      .rdy(bfu_rdrsp_t_rdy),
      .dat(bfu_rdrsp_t_msg),
      .ivld(bfu_rdrsp_t_Pop_mioi_ivld),
      .irdy(bfu_rdrsp_t_Pop_mioi_irdy_outputUnit_rsp_sct),
      .idat(bfu_rdrsp_t_Pop_mioi_idat)
    );
  outputUnit_outputUnit_outputUnit_rsp_outputUnit_rsp_bfu_rdrsp_t_Pop_mioi_bfu_rdrsp_t_Pop_mio_wait_ctrl
      outputUnit_outputUnit_rsp_outputUnit_rsp_bfu_rdrsp_t_Pop_mioi_bfu_rdrsp_t_Pop_mio_wait_ctrl_inst
      (
      .outputUnit_rsp_wen(outputUnit_rsp_wen),
      .bfu_rdrsp_t_Pop_mioi_oswt(bfu_rdrsp_t_Pop_mioi_oswt),
      .bfu_rdrsp_t_Pop_mioi_biwt(bfu_rdrsp_t_Pop_mioi_biwt),
      .bfu_rdrsp_t_Pop_mioi_bdwt(bfu_rdrsp_t_Pop_mioi_bdwt),
      .bfu_rdrsp_t_Pop_mioi_bcwt(bfu_rdrsp_t_Pop_mioi_bcwt),
      .bfu_rdrsp_t_Pop_mioi_ivld(bfu_rdrsp_t_Pop_mioi_ivld),
      .bfu_rdrsp_t_Pop_mioi_irdy_outputUnit_rsp_sct(bfu_rdrsp_t_Pop_mioi_irdy_outputUnit_rsp_sct)
    );
  outputUnit_outputUnit_outputUnit_rsp_outputUnit_rsp_bfu_rdrsp_t_Pop_mioi_bfu_rdrsp_t_Pop_mio_wait_dp
      outputUnit_outputUnit_rsp_outputUnit_rsp_bfu_rdrsp_t_Pop_mioi_bfu_rdrsp_t_Pop_mio_wait_dp_inst
      (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .bfu_rdrsp_t_Pop_mioi_oswt(bfu_rdrsp_t_Pop_mioi_oswt),
      .bfu_rdrsp_t_Pop_mioi_wen_comp(bfu_rdrsp_t_Pop_mioi_wen_comp),
      .bfu_rdrsp_t_Pop_mioi_idat_mxwt(bfu_rdrsp_t_Pop_mioi_idat_mxwt_pconst),
      .bfu_rdrsp_t_Pop_mioi_biwt(bfu_rdrsp_t_Pop_mioi_biwt),
      .bfu_rdrsp_t_Pop_mioi_bdwt(bfu_rdrsp_t_Pop_mioi_bdwt),
      .bfu_rdrsp_t_Pop_mioi_bcwt(bfu_rdrsp_t_Pop_mioi_bcwt),
      .bfu_rdrsp_t_Pop_mioi_idat(bfu_rdrsp_t_Pop_mioi_idat)
    );
  assign bfu_rdrsp_t_Pop_mioi_idat_mxwt = bfu_rdrsp_t_Pop_mioi_idat_mxwt_pconst;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    outputUnit_outputUnit_outputUnit_req_outputUnit_req_req_rsp_fifo_cnsi
// ------------------------------------------------------------------


module outputUnit_outputUnit_outputUnit_req_outputUnit_req_req_rsp_fifo_cnsi (
  i_clk, i_rst, req_rsp_fifo_cns_dat, req_rsp_fifo_cns_vld, req_rsp_fifo_cns_rdy,
      outputUnit_req_wen, req_rsp_fifo_cnsi_oswt, req_rsp_fifo_cnsi_wen_comp, req_rsp_fifo_cnsi_idat
);
  input i_clk;
  input i_rst;
  output [35:0] req_rsp_fifo_cns_dat;
  output req_rsp_fifo_cns_vld;
  input req_rsp_fifo_cns_rdy;
  input outputUnit_req_wen;
  input req_rsp_fifo_cnsi_oswt;
  output req_rsp_fifo_cnsi_wen_comp;
  input [35:0] req_rsp_fifo_cnsi_idat;


  // Interconnect Declarations
  wire req_rsp_fifo_cnsi_biwt;
  wire req_rsp_fifo_cnsi_bdwt;
  wire req_rsp_fifo_cnsi_bcwt;
  wire req_rsp_fifo_cnsi_irdy;
  wire req_rsp_fifo_cnsi_ivld_outputUnit_req_sct;


  // Interconnect Declarations for Component Instantiations 
  ccs_out_wait_v1 #(.rscid(32'sd28),
  .width(32'sd36)) req_rsp_fifo_cnsi (
      .irdy(req_rsp_fifo_cnsi_irdy),
      .ivld(req_rsp_fifo_cnsi_ivld_outputUnit_req_sct),
      .idat(req_rsp_fifo_cnsi_idat),
      .rdy(req_rsp_fifo_cns_rdy),
      .vld(req_rsp_fifo_cns_vld),
      .dat(req_rsp_fifo_cns_dat)
    );
  outputUnit_outputUnit_outputUnit_req_outputUnit_req_req_rsp_fifo_cnsi_req_rsp_fifo_wait_ctrl
      outputUnit_outputUnit_req_outputUnit_req_req_rsp_fifo_cnsi_req_rsp_fifo_wait_ctrl_inst
      (
      .outputUnit_req_wen(outputUnit_req_wen),
      .req_rsp_fifo_cnsi_oswt(req_rsp_fifo_cnsi_oswt),
      .req_rsp_fifo_cnsi_biwt(req_rsp_fifo_cnsi_biwt),
      .req_rsp_fifo_cnsi_bdwt(req_rsp_fifo_cnsi_bdwt),
      .req_rsp_fifo_cnsi_bcwt(req_rsp_fifo_cnsi_bcwt),
      .req_rsp_fifo_cnsi_irdy(req_rsp_fifo_cnsi_irdy),
      .req_rsp_fifo_cnsi_ivld_outputUnit_req_sct(req_rsp_fifo_cnsi_ivld_outputUnit_req_sct)
    );
  outputUnit_outputUnit_outputUnit_req_outputUnit_req_req_rsp_fifo_cnsi_req_rsp_fifo_wait_dp
      outputUnit_outputUnit_req_outputUnit_req_req_rsp_fifo_cnsi_req_rsp_fifo_wait_dp_inst
      (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .req_rsp_fifo_cnsi_oswt(req_rsp_fifo_cnsi_oswt),
      .req_rsp_fifo_cnsi_wen_comp(req_rsp_fifo_cnsi_wen_comp),
      .req_rsp_fifo_cnsi_biwt(req_rsp_fifo_cnsi_biwt),
      .req_rsp_fifo_cnsi_bdwt(req_rsp_fifo_cnsi_bdwt),
      .req_rsp_fifo_cnsi_bcwt(req_rsp_fifo_cnsi_bcwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    outputUnit_outputUnit_outputUnit_req_outputUnit_req_bfu_rdreq_t_Push_mioi
// ------------------------------------------------------------------


module outputUnit_outputUnit_outputUnit_req_outputUnit_req_bfu_rdreq_t_Push_mioi
    (
  i_clk, i_rst, bfu_rdreq_t_val, bfu_rdreq_t_rdy, bfu_rdreq_t_msg, outputUnit_req_wen,
      bfu_rdreq_t_Push_mioi_oswt, bfu_rdreq_t_Push_mioi_wen_comp, bfu_rdreq_t_Push_mioi_idat
);
  input i_clk;
  input i_rst;
  output bfu_rdreq_t_val;
  input bfu_rdreq_t_rdy;
  output [13:0] bfu_rdreq_t_msg;
  input outputUnit_req_wen;
  input bfu_rdreq_t_Push_mioi_oswt;
  output bfu_rdreq_t_Push_mioi_wen_comp;
  input [13:0] bfu_rdreq_t_Push_mioi_idat;


  // Interconnect Declarations
  wire bfu_rdreq_t_Push_mioi_biwt;
  wire bfu_rdreq_t_Push_mioi_bdwt;
  wire bfu_rdreq_t_Push_mioi_bcwt;
  wire bfu_rdreq_t_Push_mioi_ivld_outputUnit_req_sct;
  wire bfu_rdreq_t_Push_mioi_irdy;


  // Interconnect Declarations for Component Instantiations 
  wire [13:0] nl_bfu_rdreq_t_Push_mioi_idat;
  assign nl_bfu_rdreq_t_Push_mioi_idat = {2'b00 , (bfu_rdreq_t_Push_mioi_idat[11:9])
      , 2'b00 , (bfu_rdreq_t_Push_mioi_idat[6:0])};
  ccs_out_wait_v1 #(.rscid(32'sd24),
  .width(32'sd14)) bfu_rdreq_t_Push_mioi (
      .vld(bfu_rdreq_t_val),
      .rdy(bfu_rdreq_t_rdy),
      .dat(bfu_rdreq_t_msg),
      .ivld(bfu_rdreq_t_Push_mioi_ivld_outputUnit_req_sct),
      .irdy(bfu_rdreq_t_Push_mioi_irdy),
      .idat(nl_bfu_rdreq_t_Push_mioi_idat[13:0])
    );
  outputUnit_outputUnit_outputUnit_req_outputUnit_req_bfu_rdreq_t_Push_mioi_bfu_rdreq_t_Push_mio_wait_ctrl
      outputUnit_outputUnit_req_outputUnit_req_bfu_rdreq_t_Push_mioi_bfu_rdreq_t_Push_mio_wait_ctrl_inst
      (
      .outputUnit_req_wen(outputUnit_req_wen),
      .bfu_rdreq_t_Push_mioi_oswt(bfu_rdreq_t_Push_mioi_oswt),
      .bfu_rdreq_t_Push_mioi_biwt(bfu_rdreq_t_Push_mioi_biwt),
      .bfu_rdreq_t_Push_mioi_bdwt(bfu_rdreq_t_Push_mioi_bdwt),
      .bfu_rdreq_t_Push_mioi_bcwt(bfu_rdreq_t_Push_mioi_bcwt),
      .bfu_rdreq_t_Push_mioi_ivld_outputUnit_req_sct(bfu_rdreq_t_Push_mioi_ivld_outputUnit_req_sct),
      .bfu_rdreq_t_Push_mioi_irdy(bfu_rdreq_t_Push_mioi_irdy)
    );
  outputUnit_outputUnit_outputUnit_req_outputUnit_req_bfu_rdreq_t_Push_mioi_bfu_rdreq_t_Push_mio_wait_dp
      outputUnit_outputUnit_req_outputUnit_req_bfu_rdreq_t_Push_mioi_bfu_rdreq_t_Push_mio_wait_dp_inst
      (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .bfu_rdreq_t_Push_mioi_oswt(bfu_rdreq_t_Push_mioi_oswt),
      .bfu_rdreq_t_Push_mioi_wen_comp(bfu_rdreq_t_Push_mioi_wen_comp),
      .bfu_rdreq_t_Push_mioi_biwt(bfu_rdreq_t_Push_mioi_biwt),
      .bfu_rdreq_t_Push_mioi_bdwt(bfu_rdreq_t_Push_mioi_bdwt),
      .bfu_rdreq_t_Push_mioi_bcwt(bfu_rdreq_t_Push_mioi_bcwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    outputUnit_outputUnit_outputUnit_req_outputUnit_req_cmd_in_t_Pop_mioi
// ------------------------------------------------------------------


module outputUnit_outputUnit_outputUnit_req_outputUnit_req_cmd_in_t_Pop_mioi (
  cmd_in_t_val, cmd_in_t_rdy, cmd_in_t_msg, cmd_in_t_Pop_mioi_oswt, cmd_in_t_Pop_mioi_wen_comp,
      cmd_in_t_Pop_mioi_idat_mxwt
);
  input cmd_in_t_val;
  output cmd_in_t_rdy;
  input [35:0] cmd_in_t_msg;
  input cmd_in_t_Pop_mioi_oswt;
  output cmd_in_t_Pop_mioi_wen_comp;
  output [35:0] cmd_in_t_Pop_mioi_idat_mxwt;


  // Interconnect Declarations
  wire cmd_in_t_Pop_mioi_biwt;
  wire cmd_in_t_Pop_mioi_ivld;
  wire [35:0] cmd_in_t_Pop_mioi_idat;


  // Interconnect Declarations for Component Instantiations 
  ccs_in_wait_v1 #(.rscid(32'sd23),
  .width(32'sd36)) cmd_in_t_Pop_mioi (
      .vld(cmd_in_t_val),
      .rdy(cmd_in_t_rdy),
      .dat(cmd_in_t_msg),
      .ivld(cmd_in_t_Pop_mioi_ivld),
      .irdy(cmd_in_t_Pop_mioi_oswt),
      .idat(cmd_in_t_Pop_mioi_idat)
    );
  outputUnit_outputUnit_outputUnit_req_outputUnit_req_cmd_in_t_Pop_mioi_cmd_in_t_Pop_mio_wait_ctrl
      outputUnit_outputUnit_req_outputUnit_req_cmd_in_t_Pop_mioi_cmd_in_t_Pop_mio_wait_ctrl_inst
      (
      .cmd_in_t_Pop_mioi_iswt0(cmd_in_t_Pop_mioi_oswt),
      .cmd_in_t_Pop_mioi_biwt(cmd_in_t_Pop_mioi_biwt),
      .cmd_in_t_Pop_mioi_ivld(cmd_in_t_Pop_mioi_ivld)
    );
  assign cmd_in_t_Pop_mioi_idat_mxwt = cmd_in_t_Pop_mioi_idat;
  assign cmd_in_t_Pop_mioi_wen_comp = (~ cmd_in_t_Pop_mioi_oswt) | cmd_in_t_Pop_mioi_biwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    outputUnit_outputUnit_outputUnit_rsp_outputUnit_rsp
// ------------------------------------------------------------------


module outputUnit_outputUnit_outputUnit_rsp_outputUnit_rsp (
  i_clk, i_rst, bt0, bt1, stream_out_t_val, stream_out_t_rdy, stream_out_t_msg, bfu_out_t_val,
      bfu_out_t_rdy, bfu_out_t_msg, bfu_rdrsp_t_val, bfu_rdrsp_t_rdy, bfu_rdrsp_t_msg,
      req_rsp_fifo_cns_dat, req_rsp_fifo_cns_vld, req_rsp_fifo_cns_rdy
);
  input i_clk;
  input i_rst;
  input [31:0] bt0;
  input [31:0] bt1;
  output stream_out_t_val;
  input stream_out_t_rdy;
  output [522:0] stream_out_t_msg;
  output bfu_out_t_val;
  input bfu_out_t_rdy;
  output [36:0] bfu_out_t_msg;
  input bfu_rdrsp_t_val;
  output bfu_rdrsp_t_rdy;
  input [383:0] bfu_rdrsp_t_msg;
  input [35:0] req_rsp_fifo_cns_dat;
  input req_rsp_fifo_cns_vld;
  output req_rsp_fifo_cns_rdy;


  // Interconnect Declarations
  wire outputUnit_rsp_wen;
  wire outputUnit_rsp_wten;
  wire bfu_rdrsp_t_Pop_mioi_wen_comp;
  wire [351:0] bfu_rdrsp_t_Pop_mioi_idat_mxwt;
  wire stream_out_t_Push_mioi_wen_comp;
  reg bfu_out_t_PushNB_mioi_iswt0;
  wire req_rsp_fifo_cnsi_wen_comp;
  wire [35:0] req_rsp_fifo_cnsi_idat_mxwt;
  reg [47:0] stream_out_t_Push_mioi_idat_515_468;
  reg [63:0] stream_out_t_Push_mioi_idat_339_276;
  reg [63:0] stream_out_t_Push_mioi_idat_275_212;
  reg [31:0] stream_out_t_Push_mioi_idat_115_84;
  reg [3:0] stream_out_t_Push_mioi_idat_3_0;
  reg bfu_out_t_PushNB_mioi_idat_36;
  reg [31:0] bfu_out_t_PushNB_mioi_idat_35_4;
  reg [3:0] bfu_out_t_PushNB_mioi_idat_3_0;
  reg stream_out_t_Push_mioi_idat_519;
  reg [1:0] stream_out_t_Push_mioi_idat_518_517;
  reg stream_out_t_Push_mioi_idat_521;
  reg stream_out_t_Push_mioi_idat_520;
  wire [5:0] fsm_output;
  wire outputUnit_outputUnit_rsp_core_if_if_if_if_if_if_less_tmp;
  wire outputUnit_outputUnit_rsp_core_if_if_if_if_if_less_tmp;
  wire outputUnit_outputUnit_rsp_core_if_if_if_if_less_tmp;
  wire outputUnit_outputUnit_rsp_core_if_if_if_less_tmp;
  wire and_dcpl_7;
  wire and_dcpl_8;
  wire or_dcpl_2;
  wire or_dcpl_7;
  wire or_tmp_6;
  wire and_26_cse;
  wire and_29_cse;
  wire and_32_cse;
  wire and_47_cse;
  reg outputUnit_outputUnit_rsp_core_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_acc_4_svs;
  reg outputUnit_outputUnit_rsp_core_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_acc_1_31_svs;
  reg outputUnit_outputUnit_rsp_core_if_if_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_if_if_acc_1_31_svs;
  reg outputUnit_outputUnit_rsp_core_if_slc_outputUnit_outputUnit_rsp_core_if_acc_1_31_itm;
  reg outputUnit_outputUnit_rsp_core_if_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_acc_4_svs;
  reg outputUnit_outputUnit_rsp_core_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_acc_1_30_svs;
  wire outputUnit_outputUnit_rsp_core_if_and_ssc;
  wire outputUnit_outputUnit_rsp_core_if_or_ssc;
  reg [63:0] stream_out_t_Push_mioi_idat_467_404;
  reg [63:0] stream_out_t_Push_mioi_idat_403_340;
  reg reg_bfu_rdrsp_t_Pop_mioi_oswt_cse;
  reg reg_stream_out_t_Push_mioi_oswt_cse;
  reg reg_req_rsp_fifo_cnsi_oswt_cse;
  wire stream_out_write_and_cse;
  wire stream_out_write_and_3_cse;
  wire bfu_out_write_1_and_cse;
  wire outputUnit_outputUnit_rsp_core_if_if_if_and_8_cse;
  wire fifo_out_and_ssc;
  reg fifo_out_sva_7;
  reg [4:0] fifo_out_sva_4_0;
  reg [111:0] bfu_rdrsp_t_Pop_mio_mrgout_dat_sva_111_0;
  reg outputUnit_outputUnit_rsp_core_if_if_if_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_if_if_acc_4_svs;
  wire or_12_itm;
  reg [31:0] outputUnit_outputUnit_rsp_core_if_mux_6_itm;
  reg outputUnit_outputUnit_rsp_core_if_mux_2_itm_2;
  reg [1:0] outputUnit_outputUnit_rsp_core_if_mux_2_itm_1_0;
  reg outputUnit_outputUnit_rsp_core_if_if_if_or_1_ssc;
  reg outputUnit_outputUnit_rsp_core_if_if_if_or_2_ssc;
  reg outputUnit_outputUnit_rsp_core_if_mux_2_itm_4;
  reg outputUnit_outputUnit_rsp_core_if_mux_2_itm_3;
  wire stream_out_t_Push_mioi_idat_515_468_mx0c0;
  wire stream_out_t_Push_mioi_idat_519_mx0c0;
  wire stream_out_t_Push_mioi_idat_3_0_mx0c1;
  wire outputUnit_outputUnit_rsp_core_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_acc_1_30_svs_mx1;
  wire outputUnit_outputUnit_rsp_core_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_acc_1_30_svs_mx2;
  wire outputUnit_outputUnit_rsp_core_if_if_if_or_2_ssc_mx0w0;
  wire outputUnit_outputUnit_rsp_core_if_if_if_or_2_ssc_mx1;
  wire outputUnit_outputUnit_rsp_core_if_if_if_if_if_and_ssc_mx0w0;
  wire outputUnit_outputUnit_rsp_core_if_if_if_if_if_and_2_ssc_mx0w0;
  wire outputUnit_outputUnit_rsp_core_if_if_if_or_1_ssc_mx0w0;
  wire outputUnit_outputUnit_rsp_core_if_if_if_or_1_ssc_mx1;
  wire outputUnit_outputUnit_rsp_core_if_if_if_and_2_ssc_mx0w0;
  wire outputUnit_outputUnit_rsp_core_if_if_if_and_4_ssc_mx0w0;
  wire outputUnit_outputUnit_rsp_core_if_if_if_and_3_m1c_mx0w0;
  wire outputUnit_outputUnit_rsp_core_if_if_if_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_if_if_acc_4_svs_1;
  wire outputUnit_outputUnit_rsp_core_if_if_if_if_if_and_1_m1c_1;
  wire outputUnit_outputUnit_rsp_core_if_and_1_m1c_1;
  reg [95:0] bfu_rdrsp_t_Pop_1mio_mrgout_dat_sva_95_0;
  reg [63:0] reg_outputUnit_outputUnit_rsp_core_if_outputUnit_outputUnit_rsp_core_if_mux1h_ftd;
  reg [15:0] reg_outputUnit_outputUnit_rsp_core_if_outputUnit_outputUnit_rsp_core_if_mux1h_ftd_1;
  reg [63:0] outputUnit_outputUnit_rsp_core_if_mux_5_itm_95_32;
  reg [31:0] outputUnit_outputUnit_rsp_core_if_mux_5_itm_31_0;
  reg [63:0] stream_out_t_Push_mioi_idat_211_148;
  reg [31:0] stream_out_t_Push_mioi_idat_147_116;
  reg [63:0] stream_out_t_Push_mioi_idat_83_20;
  reg [15:0] stream_out_t_Push_mioi_idat_19_4;
  wire bfu_rdrsp_read_1_and_ssc;
  reg [191:0] bfu_rdrsp_t_Pop_1mio_mrgout_dat_sva_383_192;
  reg [63:0] bfu_rdrsp_t_Pop_1mio_mrgout_dat_sva_159_96;
  wire outputUnit_outputUnit_rsp_core_if_if_if_if_if_if_if_and_cse;
  wire outputUnit_outputUnit_rsp_core_if_if_acc_1_itm_31_1;
  wire outputUnit_outputUnit_rsp_core_if_acc_1_itm_31_1;

  wire[63:0] stream_out_write_mux_1_nl;
  wire[63:0] outputUnit_outputUnit_rsp_core_if_if_outputUnit_outputUnit_rsp_core_if_if_and_1_nl;
  wire stream_out_write_not_12_nl;
  wire[63:0] stream_out_write_mux_2_nl;
  wire[63:0] outputUnit_outputUnit_rsp_core_if_if_outputUnit_outputUnit_rsp_core_if_if_and_2_nl;
  wire stream_out_write_not_13_nl;
  wire[63:0] stream_out_write_mux_3_nl;
  wire[63:0] outputUnit_outputUnit_rsp_core_if_if_outputUnit_outputUnit_rsp_core_if_if_and_nl;
  wire stream_out_write_not_21_nl;
  wire[63:0] stream_out_write_mux_5_nl;
  wire[63:0] outputUnit_outputUnit_rsp_core_if_if_outputUnit_outputUnit_rsp_core_if_if_and_5_nl;
  wire stream_out_write_not_14_nl;
  wire[63:0] stream_out_write_mux_4_nl;
  wire stream_out_write_not_22_nl;
  wire[31:0] stream_out_write_mux_6_nl;
  wire stream_out_write_not_15_nl;
  wire stream_out_write_not_16_nl;
  wire[1:0] stream_out_write_4_mux_nl;
  wire stream_out_write_not_18_nl;
  wire outputUnit_outputUnit_rsp_core_if_if_nor_nl;
  wire[63:0] outputUnit_outputUnit_rsp_core_if_mux_7_nl;
  wire outputUnit_outputUnit_rsp_core_if_not_nl;
  wire outputUnit_outputUnit_rsp_core_if_or_1_nl;
  wire[31:0] outputUnit_outputUnit_rsp_core_if_if_outputUnit_outputUnit_rsp_core_if_if_and_4_nl;
  wire[63:0] outputUnit_outputUnit_rsp_core_if_if_outputUnit_outputUnit_rsp_core_if_if_and_3_nl;
  wire[31:0] outputUnit_outputUnit_rsp_core_if_if_outputUnit_outputUnit_rsp_core_if_if_and_6_nl;
  wire nand_4_nl;
  wire[31:0] outputUnit_outputUnit_rsp_core_if_if_acc_1_nl;
  wire[32:0] nl_outputUnit_outputUnit_rsp_core_if_if_acc_1_nl;
  wire[31:0] outputUnit_outputUnit_rsp_core_if_acc_1_nl;
  wire[32:0] nl_outputUnit_outputUnit_rsp_core_if_acc_1_nl;

  // Interconnect Declarations for Component Instantiations 
  wire [522:0] nl_outputUnit_outputUnit_rsp_outputUnit_rsp_stream_out_t_Push_mioi_inst_stream_out_t_Push_mioi_idat;
  assign nl_outputUnit_outputUnit_rsp_outputUnit_rsp_stream_out_t_Push_mioi_inst_stream_out_t_Push_mioi_idat
      = {1'b0 , stream_out_t_Push_mioi_idat_521 , stream_out_t_Push_mioi_idat_520
      , stream_out_t_Push_mioi_idat_519 , stream_out_t_Push_mioi_idat_518_517 , 1'b0
      , stream_out_t_Push_mioi_idat_515_468 , stream_out_t_Push_mioi_idat_467_404
      , stream_out_t_Push_mioi_idat_403_340 , stream_out_t_Push_mioi_idat_339_276
      , stream_out_t_Push_mioi_idat_275_212 , stream_out_t_Push_mioi_idat_211_148
      , stream_out_t_Push_mioi_idat_147_116 , stream_out_t_Push_mioi_idat_115_84
      , stream_out_t_Push_mioi_idat_83_20 , stream_out_t_Push_mioi_idat_19_4 , stream_out_t_Push_mioi_idat_3_0};
  wire [36:0] nl_outputUnit_outputUnit_rsp_outputUnit_rsp_bfu_out_t_PushNB_mioi_inst_bfu_out_t_PushNB_mioi_idat;
  assign nl_outputUnit_outputUnit_rsp_outputUnit_rsp_bfu_out_t_PushNB_mioi_inst_bfu_out_t_PushNB_mioi_idat
      = {bfu_out_t_PushNB_mioi_idat_36 , bfu_out_t_PushNB_mioi_idat_35_4 , bfu_out_t_PushNB_mioi_idat_3_0};
  outputUnit_outputUnit_outputUnit_rsp_outputUnit_rsp_bfu_rdrsp_t_Pop_mioi outputUnit_outputUnit_rsp_outputUnit_rsp_bfu_rdrsp_t_Pop_mioi_inst
      (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .bfu_rdrsp_t_val(bfu_rdrsp_t_val),
      .bfu_rdrsp_t_rdy(bfu_rdrsp_t_rdy),
      .bfu_rdrsp_t_msg(bfu_rdrsp_t_msg),
      .outputUnit_rsp_wen(outputUnit_rsp_wen),
      .bfu_rdrsp_t_Pop_mioi_oswt(reg_bfu_rdrsp_t_Pop_mioi_oswt_cse),
      .bfu_rdrsp_t_Pop_mioi_wen_comp(bfu_rdrsp_t_Pop_mioi_wen_comp),
      .bfu_rdrsp_t_Pop_mioi_idat_mxwt(bfu_rdrsp_t_Pop_mioi_idat_mxwt)
    );
  outputUnit_outputUnit_outputUnit_rsp_outputUnit_rsp_stream_out_t_Push_mioi outputUnit_outputUnit_rsp_outputUnit_rsp_stream_out_t_Push_mioi_inst
      (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .stream_out_t_val(stream_out_t_val),
      .stream_out_t_rdy(stream_out_t_rdy),
      .stream_out_t_msg(stream_out_t_msg),
      .outputUnit_rsp_wen(outputUnit_rsp_wen),
      .stream_out_t_Push_mioi_oswt(reg_stream_out_t_Push_mioi_oswt_cse),
      .stream_out_t_Push_mioi_wen_comp(stream_out_t_Push_mioi_wen_comp),
      .stream_out_t_Push_mioi_idat(nl_outputUnit_outputUnit_rsp_outputUnit_rsp_stream_out_t_Push_mioi_inst_stream_out_t_Push_mioi_idat[522:0])
    );
  outputUnit_outputUnit_outputUnit_rsp_outputUnit_rsp_bfu_out_t_PushNB_mioi outputUnit_outputUnit_rsp_outputUnit_rsp_bfu_out_t_PushNB_mioi_inst
      (
      .bfu_out_t_val(bfu_out_t_val),
      .bfu_out_t_rdy(bfu_out_t_rdy),
      .bfu_out_t_msg(bfu_out_t_msg),
      .outputUnit_rsp_wten(outputUnit_rsp_wten),
      .bfu_out_t_PushNB_mioi_iswt0(bfu_out_t_PushNB_mioi_iswt0),
      .bfu_out_t_PushNB_mioi_idat(nl_outputUnit_outputUnit_rsp_outputUnit_rsp_bfu_out_t_PushNB_mioi_inst_bfu_out_t_PushNB_mioi_idat[36:0])
    );
  outputUnit_outputUnit_outputUnit_rsp_outputUnit_rsp_req_rsp_fifo_cnsi outputUnit_outputUnit_rsp_outputUnit_rsp_req_rsp_fifo_cnsi_inst
      (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .req_rsp_fifo_cns_dat(req_rsp_fifo_cns_dat),
      .req_rsp_fifo_cns_vld(req_rsp_fifo_cns_vld),
      .req_rsp_fifo_cns_rdy(req_rsp_fifo_cns_rdy),
      .outputUnit_rsp_wen(outputUnit_rsp_wen),
      .req_rsp_fifo_cnsi_oswt(reg_req_rsp_fifo_cnsi_oswt_cse),
      .req_rsp_fifo_cnsi_wen_comp(req_rsp_fifo_cnsi_wen_comp),
      .req_rsp_fifo_cnsi_idat_mxwt(req_rsp_fifo_cnsi_idat_mxwt)
    );
  outputUnit_outputUnit_outputUnit_rsp_outputUnit_rsp_staller outputUnit_outputUnit_rsp_outputUnit_rsp_staller_inst
      (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .outputUnit_rsp_wen(outputUnit_rsp_wen),
      .outputUnit_rsp_wten(outputUnit_rsp_wten),
      .bfu_rdrsp_t_Pop_mioi_wen_comp(bfu_rdrsp_t_Pop_mioi_wen_comp),
      .stream_out_t_Push_mioi_wen_comp(stream_out_t_Push_mioi_wen_comp),
      .req_rsp_fifo_cnsi_wen_comp(req_rsp_fifo_cnsi_wen_comp)
    );
  outputUnit_outputUnit_outputUnit_rsp_outputUnit_rsp_outputUnit_rsp_fsm outputUnit_outputUnit_rsp_outputUnit_rsp_outputUnit_rsp_fsm_inst
      (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .outputUnit_rsp_wen(outputUnit_rsp_wen),
      .fsm_output(fsm_output)
    );
  assign or_12_itm = and_29_cse | and_26_cse | and_32_cse;
  assign stream_out_write_and_cse = outputUnit_rsp_wen & (and_26_cse | and_29_cse
      | (outputUnit_outputUnit_rsp_core_if_slc_outputUnit_outputUnit_rsp_core_if_acc_1_31_itm
      & (~ outputUnit_outputUnit_rsp_core_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_acc_1_31_svs)
      & (fsm_output[4])) | or_tmp_6);
  assign stream_out_write_and_3_cse = outputUnit_rsp_wen & or_12_itm;
  assign bfu_out_write_1_and_cse = outputUnit_rsp_wen & (and_32_cse | and_47_cse);
  assign outputUnit_outputUnit_rsp_core_if_if_if_and_8_cse = outputUnit_rsp_wen &
      (~((~ (fsm_output[1])) | or_dcpl_7));
  assign outputUnit_outputUnit_rsp_core_if_if_if_if_if_if_if_and_cse = outputUnit_rsp_wen
      & (fsm_output[3:2]==2'b00);
  assign fifo_out_and_ssc = outputUnit_rsp_wen & (fsm_output[1]);
  assign bfu_rdrsp_read_1_and_ssc = outputUnit_rsp_wen & (~ (fsm_output[3]));
  assign outputUnit_outputUnit_rsp_core_if_if_if_if_less_tmp = 1'b0 < (req_rsp_fifo_cnsi_idat_mxwt[7:6]);
  assign nand_4_nl = ~(outputUnit_outputUnit_rsp_core_if_if_acc_1_itm_31_1 & outputUnit_outputUnit_rsp_core_if_if_if_less_tmp);
  assign outputUnit_outputUnit_rsp_core_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_acc_1_30_svs_mx1
      = MUX_s_1_2_2(outputUnit_outputUnit_rsp_core_if_if_if_if_less_tmp, outputUnit_outputUnit_rsp_core_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_acc_1_30_svs,
      nand_4_nl);
  assign outputUnit_outputUnit_rsp_core_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_acc_1_30_svs_mx2
      = MUX_s_1_2_2(outputUnit_outputUnit_rsp_core_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_acc_1_30_svs,
      outputUnit_outputUnit_rsp_core_if_if_if_if_less_tmp, outputUnit_outputUnit_rsp_core_if_if_if_less_tmp);
  assign outputUnit_outputUnit_rsp_core_if_if_if_or_2_ssc_mx0w0 = outputUnit_outputUnit_rsp_core_if_if_if_if_if_and_ssc_mx0w0
      | outputUnit_outputUnit_rsp_core_if_if_if_if_if_and_2_ssc_mx0w0;
  assign outputUnit_outputUnit_rsp_core_if_if_if_or_2_ssc_mx1 = MUX_s_1_2_2(outputUnit_outputUnit_rsp_core_if_if_if_or_2_ssc,
      outputUnit_outputUnit_rsp_core_if_if_if_or_2_ssc_mx0w0, outputUnit_outputUnit_rsp_core_if_if_acc_1_itm_31_1);
  assign outputUnit_outputUnit_rsp_core_if_if_if_if_if_and_ssc_mx0w0 = (~ outputUnit_outputUnit_rsp_core_if_if_if_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_if_if_acc_4_svs_1)
      & outputUnit_outputUnit_rsp_core_if_if_if_if_if_if_less_tmp & outputUnit_outputUnit_rsp_core_if_if_if_and_3_m1c_mx0w0;
  assign outputUnit_outputUnit_rsp_core_if_if_if_if_if_and_2_ssc_mx0w0 = (~ (req_rsp_fifo_cnsi_idat_mxwt[7]))
      & outputUnit_outputUnit_rsp_core_if_if_if_if_if_and_1_m1c_1 & outputUnit_outputUnit_rsp_core_if_if_if_and_3_m1c_mx0w0;
  assign outputUnit_outputUnit_rsp_core_if_if_if_or_1_ssc_mx0w0 = outputUnit_outputUnit_rsp_core_if_if_if_and_2_ssc_mx0w0
      | outputUnit_outputUnit_rsp_core_if_if_if_and_4_ssc_mx0w0;
  assign outputUnit_outputUnit_rsp_core_if_if_if_or_1_ssc_mx1 = MUX_s_1_2_2(outputUnit_outputUnit_rsp_core_if_if_if_or_1_ssc,
      outputUnit_outputUnit_rsp_core_if_if_if_or_1_ssc_mx0w0, outputUnit_outputUnit_rsp_core_if_if_acc_1_itm_31_1);
  assign outputUnit_outputUnit_rsp_core_if_if_if_and_2_ssc_mx0w0 = (~ outputUnit_outputUnit_rsp_core_if_if_if_if_if_less_tmp)
      & outputUnit_outputUnit_rsp_core_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_acc_1_30_svs_mx2;
  assign outputUnit_outputUnit_rsp_core_if_if_if_and_4_ssc_mx0w0 = (~ outputUnit_outputUnit_rsp_core_if_if_if_if_if_if_less_tmp)
      & outputUnit_outputUnit_rsp_core_if_if_if_and_3_m1c_mx0w0;
  assign outputUnit_outputUnit_rsp_core_if_if_if_and_3_m1c_mx0w0 = outputUnit_outputUnit_rsp_core_if_if_if_if_if_less_tmp
      & outputUnit_outputUnit_rsp_core_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_acc_1_30_svs_mx2;
  assign outputUnit_outputUnit_rsp_core_if_if_if_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_if_if_acc_4_svs_1
      = 3'b110 < (req_rsp_fifo_cnsi_idat_mxwt[7:4]);
  assign outputUnit_outputUnit_rsp_core_if_if_if_if_if_if_less_tmp = 2'b10 < (req_rsp_fifo_cnsi_idat_mxwt[7:5]);
  assign outputUnit_outputUnit_rsp_core_if_if_if_if_if_less_tmp = 3'b100 < (req_rsp_fifo_cnsi_idat_mxwt[7:4]);
  assign outputUnit_outputUnit_rsp_core_if_if_if_less_tmp = 2'b10 < (req_rsp_fifo_cnsi_idat_mxwt[7:4]);
  assign nl_outputUnit_outputUnit_rsp_core_if_if_acc_1_nl = ({29'b11111111111111111111111111111
      , (~ (req_rsp_fifo_cnsi_idat_mxwt[7:5]))}) + 32'b00000000000000000000000000000001;
  assign outputUnit_outputUnit_rsp_core_if_if_acc_1_nl = nl_outputUnit_outputUnit_rsp_core_if_if_acc_1_nl[31:0];
  assign outputUnit_outputUnit_rsp_core_if_if_acc_1_itm_31_1 = readslicef_32_1_31(outputUnit_outputUnit_rsp_core_if_if_acc_1_nl);
  assign outputUnit_outputUnit_rsp_core_if_if_if_if_if_and_1_m1c_1 = outputUnit_outputUnit_rsp_core_if_if_if_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_if_if_acc_4_svs_1
      & outputUnit_outputUnit_rsp_core_if_if_if_if_if_if_less_tmp;
  assign nl_outputUnit_outputUnit_rsp_core_if_acc_1_nl = conv_u2u_31_32(req_rsp_fifo_cnsi_idat_mxwt[35:5])
      + 32'b11111111111111111111111111111011;
  assign outputUnit_outputUnit_rsp_core_if_acc_1_nl = nl_outputUnit_outputUnit_rsp_core_if_acc_1_nl[31:0];
  assign outputUnit_outputUnit_rsp_core_if_acc_1_itm_31_1 = readslicef_32_1_31(outputUnit_outputUnit_rsp_core_if_acc_1_nl);
  assign outputUnit_outputUnit_rsp_core_if_and_1_m1c_1 = outputUnit_outputUnit_rsp_core_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_acc_4_svs
      & outputUnit_outputUnit_rsp_core_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_acc_1_31_svs;
  assign and_dcpl_7 = outputUnit_outputUnit_rsp_core_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_acc_1_31_svs
      & outputUnit_outputUnit_rsp_core_if_slc_outputUnit_outputUnit_rsp_core_if_acc_1_31_itm;
  assign and_dcpl_8 = and_dcpl_7 & outputUnit_outputUnit_rsp_core_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_acc_4_svs;
  assign or_dcpl_2 = ~(outputUnit_outputUnit_rsp_core_if_slc_outputUnit_outputUnit_rsp_core_if_acc_1_31_itm
      & outputUnit_outputUnit_rsp_core_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_acc_1_31_svs);
  assign or_dcpl_7 = ~(outputUnit_outputUnit_rsp_core_if_if_acc_1_itm_31_1 & outputUnit_outputUnit_rsp_core_if_acc_1_itm_31_1);
  assign and_26_cse = (~ outputUnit_outputUnit_rsp_core_if_acc_1_itm_31_1) & (fsm_output[1]);
  assign and_29_cse = and_dcpl_7 & (fsm_output[3]);
  assign and_32_cse = outputUnit_outputUnit_rsp_core_if_slc_outputUnit_outputUnit_rsp_core_if_acc_1_31_itm
      & (fsm_output[4]);
  assign or_tmp_6 = and_dcpl_7 & (fsm_output[4]);
  assign and_47_cse = (~ outputUnit_outputUnit_rsp_core_if_slc_outputUnit_outputUnit_rsp_core_if_acc_1_31_itm)
      & (fsm_output[4]);
  assign stream_out_t_Push_mioi_idat_515_468_mx0c0 = and_26_cse | and_32_cse;
  assign stream_out_t_Push_mioi_idat_519_mx0c0 = and_29_cse | and_26_cse;
  assign stream_out_t_Push_mioi_idat_3_0_mx0c1 = and_29_cse | and_32_cse;
  assign outputUnit_outputUnit_rsp_core_if_and_ssc = (~ outputUnit_outputUnit_rsp_core_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_acc_4_svs)
      & outputUnit_outputUnit_rsp_core_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_acc_1_31_svs;
  assign outputUnit_outputUnit_rsp_core_if_or_ssc = ((~ outputUnit_outputUnit_rsp_core_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_acc_1_30_svs)
      & outputUnit_outputUnit_rsp_core_if_and_1_m1c_1) | ((~ outputUnit_outputUnit_rsp_core_if_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_acc_4_svs)
      & outputUnit_outputUnit_rsp_core_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_acc_1_30_svs
      & outputUnit_outputUnit_rsp_core_if_and_1_m1c_1) | (outputUnit_outputUnit_rsp_core_if_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_acc_4_svs
      & outputUnit_outputUnit_rsp_core_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_acc_1_30_svs
      & outputUnit_outputUnit_rsp_core_if_and_1_m1c_1);
  always @(posedge i_clk) begin
    if ( outputUnit_rsp_wen ) begin
      bfu_rdrsp_t_Pop_1mio_mrgout_dat_sva_95_0 <= bfu_rdrsp_t_Pop_mioi_idat_mxwt[95:0];
      reg_outputUnit_outputUnit_rsp_core_if_outputUnit_outputUnit_rsp_core_if_mux1h_ftd
          <= MUX_v_64_2_2(64'b0000000000000000000000000000000000000000000000000000000000000000,
          outputUnit_outputUnit_rsp_core_if_mux_7_nl, outputUnit_outputUnit_rsp_core_if_not_nl);
      reg_outputUnit_outputUnit_rsp_core_if_outputUnit_outputUnit_rsp_core_if_mux1h_ftd_1
          <= MUX_v_16_2_2((bfu_rdrsp_t_Pop_mio_mrgout_dat_sva_111_0[15:0]), (bfu_rdrsp_t_Pop_mioi_idat_mxwt[63:48]),
          outputUnit_outputUnit_rsp_core_if_or_1_nl);
      outputUnit_outputUnit_rsp_core_if_mux_6_itm <= MUX_v_32_2_2((bfu_rdrsp_t_Pop_mio_mrgout_dat_sva_111_0[111:80]),
          outputUnit_outputUnit_rsp_core_if_if_outputUnit_outputUnit_rsp_core_if_if_and_4_nl,
          outputUnit_outputUnit_rsp_core_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_acc_1_31_svs);
      outputUnit_outputUnit_rsp_core_if_mux_5_itm_95_32 <= MUX_v_64_2_2((bfu_rdrsp_t_Pop_1mio_mrgout_dat_sva_95_0[95:32]),
          outputUnit_outputUnit_rsp_core_if_if_outputUnit_outputUnit_rsp_core_if_if_and_3_nl,
          outputUnit_outputUnit_rsp_core_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_acc_1_31_svs);
      outputUnit_outputUnit_rsp_core_if_mux_5_itm_31_0 <= MUX_v_32_2_2((bfu_rdrsp_t_Pop_1mio_mrgout_dat_sva_95_0[31:0]),
          outputUnit_outputUnit_rsp_core_if_if_outputUnit_outputUnit_rsp_core_if_if_and_6_nl,
          outputUnit_outputUnit_rsp_core_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_acc_1_31_svs);
    end
  end
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      reg_bfu_rdrsp_t_Pop_mioi_oswt_cse <= 1'b0;
      reg_stream_out_t_Push_mioi_oswt_cse <= 1'b0;
      bfu_out_t_PushNB_mioi_iswt0 <= 1'b0;
      reg_req_rsp_fifo_cnsi_oswt_cse <= 1'b0;
    end
    else if ( outputUnit_rsp_wen ) begin
      reg_bfu_rdrsp_t_Pop_mioi_oswt_cse <= ~(((or_dcpl_2 | (~ outputUnit_outputUnit_rsp_core_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_acc_4_svs)
          | (~(outputUnit_outputUnit_rsp_core_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_acc_1_30_svs
          & outputUnit_outputUnit_rsp_core_if_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_acc_4_svs
          & outputUnit_outputUnit_rsp_core_if_if_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_if_if_acc_1_31_svs)))
          & (fsm_output[3])) | and_26_cse | (or_dcpl_2 & (fsm_output[2])) | (fsm_output[4]));
      reg_stream_out_t_Push_mioi_oswt_cse <= or_12_itm;
      bfu_out_t_PushNB_mioi_iswt0 <= fsm_output[4];
      reg_req_rsp_fifo_cnsi_oswt_cse <= (fsm_output[0]) | (fsm_output[5]);
    end
  end
  always @(posedge i_clk) begin
    if ( stream_out_write_and_cse ) begin
      stream_out_t_Push_mioi_idat_339_276 <= MUX_v_64_2_2(64'b0000000000000000000000000000000000000000000000000000000000000000,
          stream_out_write_mux_1_nl, stream_out_write_not_12_nl);
      stream_out_t_Push_mioi_idat_275_212 <= MUX_v_64_2_2(64'b0000000000000000000000000000000000000000000000000000000000000000,
          stream_out_write_mux_2_nl, stream_out_write_not_13_nl);
      stream_out_t_Push_mioi_idat_467_404 <= MUX_v_64_2_2(64'b0000000000000000000000000000000000000000000000000000000000000000,
          stream_out_write_mux_3_nl, stream_out_write_not_21_nl);
      stream_out_t_Push_mioi_idat_403_340 <= MUX_v_64_2_2(64'b0000000000000000000000000000000000000000000000000000000000000000,
          stream_out_write_mux_5_nl, stream_out_write_not_14_nl);
    end
  end
  always @(posedge i_clk) begin
    if ( stream_out_write_and_3_cse ) begin
      stream_out_t_Push_mioi_idat_211_148 <= MUX_v_64_2_2(64'b0000000000000000000000000000000000000000000000000000000000000000,
          stream_out_write_mux_4_nl, stream_out_write_not_22_nl);
      stream_out_t_Push_mioi_idat_147_116 <= MUX_v_32_2_2(32'b00000000000000000000000000000000,
          stream_out_write_mux_6_nl, stream_out_write_not_15_nl);
      stream_out_t_Push_mioi_idat_115_84 <= MUX1HOT_v_32_3_2((bfu_rdrsp_t_Pop_mioi_idat_mxwt[111:80]),
          (bfu_rdrsp_t_Pop_mio_mrgout_dat_sva_111_0[111:80]), outputUnit_outputUnit_rsp_core_if_mux_6_itm,
          {and_26_cse , and_29_cse , and_32_cse});
      stream_out_t_Push_mioi_idat_83_20 <= MUX1HOT_v_64_3_2((bfu_rdrsp_t_Pop_mioi_idat_mxwt[79:16]),
          (bfu_rdrsp_t_Pop_mio_mrgout_dat_sva_111_0[79:16]), reg_outputUnit_outputUnit_rsp_core_if_outputUnit_outputUnit_rsp_core_if_mux1h_ftd,
          {and_26_cse , and_29_cse , and_32_cse});
      stream_out_t_Push_mioi_idat_19_4 <= MUX1HOT_v_16_3_2((bfu_rdrsp_t_Pop_mioi_idat_mxwt[15:0]),
          (bfu_rdrsp_t_Pop_mio_mrgout_dat_sva_111_0[15:0]), reg_outputUnit_outputUnit_rsp_core_if_outputUnit_outputUnit_rsp_core_if_mux1h_ftd_1,
          {and_26_cse , and_29_cse , and_32_cse});
      stream_out_t_Push_mioi_idat_518_517 <= MUX_v_2_2_2(2'b00, stream_out_write_4_mux_nl,
          stream_out_write_not_18_nl);
      stream_out_t_Push_mioi_idat_520 <= (outputUnit_outputUnit_rsp_core_if_mux_2_itm_3
          & (~ and_29_cse)) | and_26_cse;
      stream_out_t_Push_mioi_idat_521 <= (outputUnit_outputUnit_rsp_core_if_mux_2_itm_4
          & (~ and_29_cse)) | and_26_cse;
    end
  end
  always @(posedge i_clk) begin
    if ( outputUnit_rsp_wen & (stream_out_t_Push_mioi_idat_515_468_mx0c0 | (and_dcpl_8
        & outputUnit_outputUnit_rsp_core_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_acc_1_30_svs
        & outputUnit_outputUnit_rsp_core_if_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_acc_4_svs
        & (fsm_output[3])) | (and_dcpl_8 & outputUnit_outputUnit_rsp_core_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_acc_1_30_svs
        & (~ outputUnit_outputUnit_rsp_core_if_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_acc_4_svs)
        & (fsm_output[3])) | (and_dcpl_7 & outputUnit_outputUnit_rsp_core_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_acc_4_svs
        & (~ outputUnit_outputUnit_rsp_core_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_acc_1_30_svs)
        & (fsm_output[3])) | (and_dcpl_7 & (~ outputUnit_outputUnit_rsp_core_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_acc_4_svs)
        & (fsm_output[3]))) ) begin
      stream_out_t_Push_mioi_idat_515_468 <= MUX_v_48_2_2(48'b000000000000000000000000000000000000000000000000,
          (bfu_rdrsp_t_Pop_mioi_idat_mxwt[47:0]), stream_out_write_not_16_nl);
    end
  end
  always @(posedge i_clk) begin
    if ( outputUnit_rsp_wen & (stream_out_t_Push_mioi_idat_519_mx0c0 | and_32_cse)
        ) begin
      stream_out_t_Push_mioi_idat_519 <= outputUnit_outputUnit_rsp_core_if_mux_2_itm_2
          & (~ stream_out_t_Push_mioi_idat_519_mx0c0);
    end
  end
  always @(posedge i_clk) begin
    if ( outputUnit_rsp_wen & (and_26_cse | stream_out_t_Push_mioi_idat_3_0_mx0c1)
        ) begin
      stream_out_t_Push_mioi_idat_3_0 <= MUX_v_4_2_2((req_rsp_fifo_cnsi_idat_mxwt[3:0]),
          (fifo_out_sva_4_0[3:0]), stream_out_t_Push_mioi_idat_3_0_mx0c1);
    end
  end
  always @(posedge i_clk) begin
    if ( bfu_out_write_1_and_cse ) begin
      bfu_out_t_PushNB_mioi_idat_35_4 <= MUX_v_32_2_2(bt0, bt1, and_47_cse);
      bfu_out_t_PushNB_mioi_idat_36 <= ~ and_32_cse;
    end
  end
  always @(posedge i_clk) begin
    if ( outputUnit_rsp_wen & (fsm_output[4]) ) begin
      bfu_out_t_PushNB_mioi_idat_3_0 <= fifo_out_sva_4_0[3:0];
    end
  end
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      outputUnit_outputUnit_rsp_core_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_acc_1_30_svs
          <= 1'b0;
    end
    else if ( outputUnit_rsp_wen & (~((~ (fsm_output[1])) | or_dcpl_7 | (~ outputUnit_outputUnit_rsp_core_if_if_if_less_tmp)))
        ) begin
      outputUnit_outputUnit_rsp_core_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_acc_1_30_svs
          <= outputUnit_outputUnit_rsp_core_if_if_if_if_less_tmp;
    end
  end
  always @(posedge i_clk) begin
    if ( outputUnit_outputUnit_rsp_core_if_if_if_and_8_cse ) begin
      outputUnit_outputUnit_rsp_core_if_if_if_or_2_ssc <= outputUnit_outputUnit_rsp_core_if_if_if_or_2_ssc_mx0w0;
      outputUnit_outputUnit_rsp_core_if_if_if_or_1_ssc <= outputUnit_outputUnit_rsp_core_if_if_if_or_1_ssc_mx0w0;
    end
  end
  always @(posedge i_clk) begin
    if ( outputUnit_outputUnit_rsp_core_if_if_if_if_if_if_if_and_cse ) begin
      outputUnit_outputUnit_rsp_core_if_mux_2_itm_4 <= (~(((~ outputUnit_outputUnit_rsp_core_if_if_if_or_1_ssc_mx1)
          | outputUnit_outputUnit_rsp_core_if_if_if_or_2_ssc_mx1 | ((req_rsp_fifo_cnsi_idat_mxwt[7])
          & outputUnit_outputUnit_rsp_core_if_if_if_if_if_and_1_m1c_1 & outputUnit_outputUnit_rsp_core_if_if_if_and_3_m1c_mx0w0))
          & outputUnit_outputUnit_rsp_core_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_acc_1_30_svs_mx1
          & outputUnit_outputUnit_rsp_core_if_if_if_less_tmp)) & outputUnit_outputUnit_rsp_core_if_if_acc_1_itm_31_1;
      outputUnit_outputUnit_rsp_core_if_mux_2_itm_3 <= (~((((req_rsp_fifo_cnsi_idat_mxwt[4])
          & (~ outputUnit_outputUnit_rsp_core_if_if_if_or_2_ssc_mx1)) | outputUnit_outputUnit_rsp_core_if_if_if_or_1_ssc_mx1)
          & outputUnit_outputUnit_rsp_core_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_acc_1_30_svs_mx1
          & outputUnit_outputUnit_rsp_core_if_if_if_less_tmp)) & outputUnit_outputUnit_rsp_core_if_if_acc_1_itm_31_1;
      outputUnit_outputUnit_rsp_core_if_mux_2_itm_1_0 <= ~((signext_2_1(outputUnit_outputUnit_rsp_core_if_if_nor_nl))
          & ({{1{outputUnit_outputUnit_rsp_core_if_if_if_less_tmp}}, outputUnit_outputUnit_rsp_core_if_if_if_less_tmp})
          & ({{1{outputUnit_outputUnit_rsp_core_if_if_acc_1_itm_31_1}}, outputUnit_outputUnit_rsp_core_if_if_acc_1_itm_31_1}));
      outputUnit_outputUnit_rsp_core_if_mux_2_itm_2 <= (((req_rsp_fifo_cnsi_idat_mxwt[4])
          & (~((~ outputUnit_outputUnit_rsp_core_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_acc_1_30_svs_mx1)
          | outputUnit_outputUnit_rsp_core_if_if_if_and_4_ssc_mx0w0))) | outputUnit_outputUnit_rsp_core_if_if_if_and_2_ssc_mx0w0
          | outputUnit_outputUnit_rsp_core_if_if_if_if_if_and_ssc_mx0w0 | outputUnit_outputUnit_rsp_core_if_if_if_if_if_and_2_ssc_mx0w0
          | (~ outputUnit_outputUnit_rsp_core_if_if_if_less_tmp)) & outputUnit_outputUnit_rsp_core_if_if_acc_1_itm_31_1;
    end
  end
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      outputUnit_outputUnit_rsp_core_if_if_if_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_if_if_acc_4_svs
          <= 1'b0;
      outputUnit_outputUnit_rsp_core_if_if_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_if_if_acc_1_31_svs
          <= 1'b0;
      outputUnit_outputUnit_rsp_core_if_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_acc_4_svs
          <= 1'b0;
      outputUnit_outputUnit_rsp_core_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_acc_4_svs
          <= 1'b0;
      outputUnit_outputUnit_rsp_core_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_acc_1_31_svs
          <= 1'b0;
    end
    else if ( outputUnit_outputUnit_rsp_core_if_if_if_if_if_if_if_and_cse ) begin
      outputUnit_outputUnit_rsp_core_if_if_if_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_if_if_acc_4_svs
          <= outputUnit_outputUnit_rsp_core_if_if_if_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_if_if_acc_4_svs_1;
      outputUnit_outputUnit_rsp_core_if_if_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_if_if_acc_1_31_svs
          <= outputUnit_outputUnit_rsp_core_if_if_if_if_if_if_less_tmp;
      outputUnit_outputUnit_rsp_core_if_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_acc_4_svs
          <= outputUnit_outputUnit_rsp_core_if_if_if_if_if_less_tmp;
      outputUnit_outputUnit_rsp_core_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_acc_4_svs
          <= outputUnit_outputUnit_rsp_core_if_if_if_less_tmp;
      outputUnit_outputUnit_rsp_core_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_acc_1_31_svs
          <= outputUnit_outputUnit_rsp_core_if_if_acc_1_itm_31_1;
    end
  end
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      fifo_out_sva_7 <= 1'b0;
      fifo_out_sva_4_0 <= 5'b00000;
      outputUnit_outputUnit_rsp_core_if_slc_outputUnit_outputUnit_rsp_core_if_acc_1_31_itm
          <= 1'b0;
    end
    else if ( fifo_out_and_ssc ) begin
      fifo_out_sva_7 <= req_rsp_fifo_cnsi_idat_mxwt[7];
      fifo_out_sva_4_0 <= req_rsp_fifo_cnsi_idat_mxwt[4:0];
      outputUnit_outputUnit_rsp_core_if_slc_outputUnit_outputUnit_rsp_core_if_acc_1_31_itm
          <= outputUnit_outputUnit_rsp_core_if_acc_1_itm_31_1;
    end
  end
  always @(posedge i_clk) begin
    if ( outputUnit_rsp_wen & (~ (fsm_output[2])) ) begin
      bfu_rdrsp_t_Pop_mio_mrgout_dat_sva_111_0 <= bfu_rdrsp_t_Pop_mioi_idat_mxwt[111:0];
    end
  end
  always @(posedge i_clk) begin
    if ( bfu_rdrsp_read_1_and_ssc ) begin
      bfu_rdrsp_t_Pop_1mio_mrgout_dat_sva_383_192 <= bfu_rdrsp_t_Pop_mioi_idat_mxwt[351:160];
      bfu_rdrsp_t_Pop_1mio_mrgout_dat_sva_159_96 <= bfu_rdrsp_t_Pop_mioi_idat_mxwt[159:96];
    end
  end
  assign outputUnit_outputUnit_rsp_core_if_mux_7_nl = MUX_v_64_2_2((bfu_rdrsp_t_Pop_mio_mrgout_dat_sva_111_0[79:16]),
      (bfu_rdrsp_t_Pop_mioi_idat_mxwt[127:64]), outputUnit_outputUnit_rsp_core_if_or_ssc);
  assign outputUnit_outputUnit_rsp_core_if_not_nl = ~ outputUnit_outputUnit_rsp_core_if_and_ssc;
  assign outputUnit_outputUnit_rsp_core_if_or_1_nl = outputUnit_outputUnit_rsp_core_if_and_ssc
      | outputUnit_outputUnit_rsp_core_if_or_ssc;
  assign outputUnit_outputUnit_rsp_core_if_if_outputUnit_outputUnit_rsp_core_if_if_and_4_nl
      = (bfu_rdrsp_t_Pop_mioi_idat_mxwt[191:160]) & ({{31{outputUnit_outputUnit_rsp_core_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_acc_1_30_svs}},
      outputUnit_outputUnit_rsp_core_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_acc_1_30_svs})
      & ({{31{outputUnit_outputUnit_rsp_core_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_acc_4_svs}},
      outputUnit_outputUnit_rsp_core_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_acc_4_svs});
  assign outputUnit_outputUnit_rsp_core_if_if_outputUnit_outputUnit_rsp_core_if_if_and_3_nl
      = (bfu_rdrsp_t_Pop_mioi_idat_mxwt[287:224]) & ({{63{outputUnit_outputUnit_rsp_core_if_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_acc_4_svs}},
      outputUnit_outputUnit_rsp_core_if_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_acc_4_svs})
      & ({{63{outputUnit_outputUnit_rsp_core_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_acc_1_30_svs}},
      outputUnit_outputUnit_rsp_core_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_acc_1_30_svs})
      & ({{63{outputUnit_outputUnit_rsp_core_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_acc_4_svs}},
      outputUnit_outputUnit_rsp_core_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_acc_4_svs});
  assign outputUnit_outputUnit_rsp_core_if_if_outputUnit_outputUnit_rsp_core_if_if_and_6_nl
      = (bfu_rdrsp_t_Pop_mioi_idat_mxwt[223:192]) & ({{31{outputUnit_outputUnit_rsp_core_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_acc_1_30_svs}},
      outputUnit_outputUnit_rsp_core_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_acc_1_30_svs})
      & ({{31{outputUnit_outputUnit_rsp_core_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_acc_4_svs}},
      outputUnit_outputUnit_rsp_core_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_acc_4_svs});
  assign outputUnit_outputUnit_rsp_core_if_if_outputUnit_outputUnit_rsp_core_if_if_and_1_nl
      = (bfu_rdrsp_t_Pop_mioi_idat_mxwt[127:64]) & ({{63{outputUnit_outputUnit_rsp_core_if_if_if_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_if_if_acc_4_svs}},
      outputUnit_outputUnit_rsp_core_if_if_if_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_if_if_acc_4_svs})
      & ({{63{outputUnit_outputUnit_rsp_core_if_if_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_if_if_acc_1_31_svs}},
      outputUnit_outputUnit_rsp_core_if_if_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_if_if_acc_1_31_svs})
      & ({{63{outputUnit_outputUnit_rsp_core_if_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_acc_4_svs}},
      outputUnit_outputUnit_rsp_core_if_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_acc_4_svs})
      & ({{63{outputUnit_outputUnit_rsp_core_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_acc_1_30_svs}},
      outputUnit_outputUnit_rsp_core_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_acc_1_30_svs})
      & ({{63{outputUnit_outputUnit_rsp_core_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_acc_4_svs}},
      outputUnit_outputUnit_rsp_core_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_acc_4_svs});
  assign stream_out_write_mux_1_nl = MUX_v_64_2_2((bfu_rdrsp_t_Pop_1mio_mrgout_dat_sva_383_192[63:0]),
      outputUnit_outputUnit_rsp_core_if_if_outputUnit_outputUnit_rsp_core_if_if_and_1_nl,
      or_tmp_6);
  assign stream_out_write_not_12_nl = ~ and_26_cse;
  assign outputUnit_outputUnit_rsp_core_if_if_outputUnit_outputUnit_rsp_core_if_if_and_2_nl
      = (bfu_rdrsp_t_Pop_mioi_idat_mxwt[63:0]) & ({{63{outputUnit_outputUnit_rsp_core_if_if_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_if_if_acc_1_31_svs}},
      outputUnit_outputUnit_rsp_core_if_if_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_if_if_acc_1_31_svs})
      & ({{63{outputUnit_outputUnit_rsp_core_if_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_acc_4_svs}},
      outputUnit_outputUnit_rsp_core_if_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_acc_4_svs})
      & ({{63{outputUnit_outputUnit_rsp_core_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_acc_1_30_svs}},
      outputUnit_outputUnit_rsp_core_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_acc_1_30_svs})
      & ({{63{outputUnit_outputUnit_rsp_core_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_acc_4_svs}},
      outputUnit_outputUnit_rsp_core_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_acc_4_svs});
  assign stream_out_write_mux_2_nl = MUX_v_64_2_2(bfu_rdrsp_t_Pop_1mio_mrgout_dat_sva_159_96,
      outputUnit_outputUnit_rsp_core_if_if_outputUnit_outputUnit_rsp_core_if_if_and_2_nl,
      or_tmp_6);
  assign stream_out_write_not_13_nl = ~ and_26_cse;
  assign outputUnit_outputUnit_rsp_core_if_if_outputUnit_outputUnit_rsp_core_if_if_and_nl
      = (bfu_rdrsp_t_Pop_mioi_idat_mxwt[287:224]) & (signext_64_1(fifo_out_sva_4_0[4]))
      & ({{63{fifo_out_sva_7}}, fifo_out_sva_7}) & ({{63{outputUnit_outputUnit_rsp_core_if_if_if_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_if_if_acc_4_svs}},
      outputUnit_outputUnit_rsp_core_if_if_if_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_if_if_acc_4_svs})
      & ({{63{outputUnit_outputUnit_rsp_core_if_if_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_if_if_acc_1_31_svs}},
      outputUnit_outputUnit_rsp_core_if_if_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_if_if_acc_1_31_svs})
      & ({{63{outputUnit_outputUnit_rsp_core_if_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_acc_4_svs}},
      outputUnit_outputUnit_rsp_core_if_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_acc_4_svs})
      & ({{63{outputUnit_outputUnit_rsp_core_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_acc_1_30_svs}},
      outputUnit_outputUnit_rsp_core_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_acc_1_30_svs})
      & ({{63{outputUnit_outputUnit_rsp_core_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_acc_4_svs}},
      outputUnit_outputUnit_rsp_core_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_acc_4_svs});
  assign stream_out_write_mux_3_nl = MUX_v_64_2_2((bfu_rdrsp_t_Pop_1mio_mrgout_dat_sva_383_192[191:128]),
      outputUnit_outputUnit_rsp_core_if_if_outputUnit_outputUnit_rsp_core_if_if_and_nl,
      or_tmp_6);
  assign stream_out_write_not_21_nl = ~ and_26_cse;
  assign outputUnit_outputUnit_rsp_core_if_if_outputUnit_outputUnit_rsp_core_if_if_and_5_nl
      = (bfu_rdrsp_t_Pop_mioi_idat_mxwt[223:160]) & ({{63{fifo_out_sva_7}}, fifo_out_sva_7})
      & ({{63{outputUnit_outputUnit_rsp_core_if_if_if_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_if_if_acc_4_svs}},
      outputUnit_outputUnit_rsp_core_if_if_if_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_if_if_acc_4_svs})
      & ({{63{outputUnit_outputUnit_rsp_core_if_if_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_if_if_acc_1_31_svs}},
      outputUnit_outputUnit_rsp_core_if_if_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_if_if_acc_1_31_svs})
      & ({{63{outputUnit_outputUnit_rsp_core_if_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_acc_4_svs}},
      outputUnit_outputUnit_rsp_core_if_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_acc_4_svs})
      & ({{63{outputUnit_outputUnit_rsp_core_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_acc_1_30_svs}},
      outputUnit_outputUnit_rsp_core_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_acc_1_30_svs})
      & ({{63{outputUnit_outputUnit_rsp_core_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_acc_4_svs}},
      outputUnit_outputUnit_rsp_core_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_acc_4_svs});
  assign stream_out_write_mux_5_nl = MUX_v_64_2_2((bfu_rdrsp_t_Pop_1mio_mrgout_dat_sva_383_192[127:64]),
      outputUnit_outputUnit_rsp_core_if_if_outputUnit_outputUnit_rsp_core_if_if_and_5_nl,
      or_tmp_6);
  assign stream_out_write_not_14_nl = ~ and_26_cse;
  assign stream_out_write_mux_4_nl = MUX_v_64_2_2((bfu_rdrsp_t_Pop_1mio_mrgout_dat_sva_95_0[95:32]),
      outputUnit_outputUnit_rsp_core_if_mux_5_itm_95_32, and_32_cse);
  assign stream_out_write_not_22_nl = ~ and_26_cse;
  assign stream_out_write_mux_6_nl = MUX_v_32_2_2((bfu_rdrsp_t_Pop_1mio_mrgout_dat_sva_95_0[31:0]),
      outputUnit_outputUnit_rsp_core_if_mux_5_itm_31_0, and_32_cse);
  assign stream_out_write_not_15_nl = ~ and_26_cse;
  assign stream_out_write_4_mux_nl = MUX_v_2_2_2(2'b01, outputUnit_outputUnit_rsp_core_if_mux_2_itm_1_0,
      and_32_cse);
  assign stream_out_write_not_18_nl = ~ and_29_cse;
  assign stream_out_write_not_16_nl = ~ stream_out_t_Push_mioi_idat_515_468_mx0c0;
  assign outputUnit_outputUnit_rsp_core_if_if_nor_nl = ~((~ outputUnit_outputUnit_rsp_core_if_if_if_if_slc_outputUnit_outputUnit_rsp_core_if_if_if_if_acc_1_30_svs_mx2)
      | outputUnit_outputUnit_rsp_core_if_if_if_and_2_ssc_mx0w0 | outputUnit_outputUnit_rsp_core_if_if_if_and_4_ssc_mx0w0
      | outputUnit_outputUnit_rsp_core_if_if_if_if_if_and_ssc_mx0w0);

  function automatic [15:0] MUX1HOT_v_16_3_2;
    input [15:0] input_2;
    input [15:0] input_1;
    input [15:0] input_0;
    input [2:0] sel;
    reg [15:0] result;
  begin
    result = input_0 & {16{sel[0]}};
    result = result | (input_1 & {16{sel[1]}});
    result = result | (input_2 & {16{sel[2]}});
    MUX1HOT_v_16_3_2 = result;
  end
  endfunction


  function automatic [31:0] MUX1HOT_v_32_3_2;
    input [31:0] input_2;
    input [31:0] input_1;
    input [31:0] input_0;
    input [2:0] sel;
    reg [31:0] result;
  begin
    result = input_0 & {32{sel[0]}};
    result = result | (input_1 & {32{sel[1]}});
    result = result | (input_2 & {32{sel[2]}});
    MUX1HOT_v_32_3_2 = result;
  end
  endfunction


  function automatic [63:0] MUX1HOT_v_64_3_2;
    input [63:0] input_2;
    input [63:0] input_1;
    input [63:0] input_0;
    input [2:0] sel;
    reg [63:0] result;
  begin
    result = input_0 & {64{sel[0]}};
    result = result | (input_1 & {64{sel[1]}});
    result = result | (input_2 & {64{sel[2]}});
    MUX1HOT_v_64_3_2 = result;
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


  function automatic [15:0] MUX_v_16_2_2;
    input [15:0] input_0;
    input [15:0] input_1;
    input  sel;
    reg [15:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_16_2_2 = result;
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


  function automatic [47:0] MUX_v_48_2_2;
    input [47:0] input_0;
    input [47:0] input_1;
    input  sel;
    reg [47:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_48_2_2 = result;
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


  function automatic [63:0] MUX_v_64_2_2;
    input [63:0] input_0;
    input [63:0] input_1;
    input  sel;
    reg [63:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_64_2_2 = result;
  end
  endfunction


  function automatic [0:0] readslicef_32_1_31;
    input [31:0] vector;
    reg [31:0] tmp;
  begin
    tmp = vector >> 31;
    readslicef_32_1_31 = tmp[0:0];
  end
  endfunction


  function automatic [1:0] signext_2_1;
    input  vector;
  begin
    signext_2_1= {{1{vector}}, vector};
  end
  endfunction


  function automatic [63:0] signext_64_1;
    input  vector;
  begin
    signext_64_1= {{63{vector}}, vector};
  end
  endfunction


  function automatic [31:0] conv_u2u_31_32 ;
    input [30:0]  vector ;
  begin
    conv_u2u_31_32 = {1'b0, vector};
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    outputUnit_outputUnit_outputUnit_req_outputUnit_req
// ------------------------------------------------------------------


module outputUnit_outputUnit_outputUnit_req_outputUnit_req (
  i_clk, i_rst, cmd_in_t_val, cmd_in_t_rdy, cmd_in_t_msg, bfu_rdreq_t_val, bfu_rdreq_t_rdy,
      bfu_rdreq_t_msg, req_rsp_fifo_cns_dat, req_rsp_fifo_cns_vld, req_rsp_fifo_cns_rdy
);
  input i_clk;
  input i_rst;
  input cmd_in_t_val;
  output cmd_in_t_rdy;
  input [35:0] cmd_in_t_msg;
  output bfu_rdreq_t_val;
  input bfu_rdreq_t_rdy;
  output [13:0] bfu_rdreq_t_msg;
  output [35:0] req_rsp_fifo_cns_dat;
  output req_rsp_fifo_cns_vld;
  input req_rsp_fifo_cns_rdy;


  // Interconnect Declarations
  wire outputUnit_req_wen;
  wire cmd_in_t_Pop_mioi_wen_comp;
  wire [35:0] cmd_in_t_Pop_mioi_idat_mxwt;
  wire bfu_rdreq_t_Push_mioi_wen_comp;
  wire req_rsp_fifo_cnsi_wen_comp;
  reg [35:0] req_rsp_fifo_cnsi_idat;
  reg [3:0] bfu_rdreq_t_Push_mioi_idat_3_0;
  reg [2:0] bfu_rdreq_t_Push_mioi_idat_11_9;
  reg [2:0] bfu_rdreq_t_Push_mioi_idat_6_4;
  wire [5:0] fsm_output;
  wire and_dcpl;
  wire or_dcpl_61;
  wire or_dcpl_62;
  wire and_54_cse;
  wire and_57_cse;
  wire and_58_cse;
  reg outputUnit_outputUnit_req_core_else_else_else_if_outputUnit_outputUnit_req_core_else_else_else_if_nand_1_itm;
  reg outputUnit_outputUnit_req_core_else_else_if_outputUnit_outputUnit_req_core_else_else_if_nand_1_itm;
  reg outputUnit_outputUnit_req_core_else_if_outputUnit_outputUnit_req_core_else_if_nand_1_itm;
  reg [35:0] cmd_in_t_Pop_mio_mrgout_dat_sva;
  reg outputUnit_outputUnit_req_core_else_else_else_else_if_slc_outputUnit_outputUnit_req_core_else_else_else_else_if_acc_29_itm;
  reg reg_cmd_in_t_Pop_mioi_oswt_cse;
  reg reg_bfu_rdreq_t_Push_mioi_oswt_cse;
  reg reg_req_rsp_fifo_cnsi_oswt_cse;
  wire while_and_cse;
  wire bfu_rdreq_t_Push_mioi_idat_3_0_mx0c1;
  wire bfu_rdreq_t_Push_mioi_idat_11_9_mx0c2;
  wire bfu_rdreq_t_Push_mioi_idat_11_9_mx0c3;
  wire bfu_rdreq_t_Push_mioi_idat_11_9_mx0c4;
  wire bfu_rdreq_t_Push_mioi_idat_11_9_mx0c5;
  wire or_74_cse;
  wire outputUnit_outputUnit_req_core_else_else_else_else_if_and_cse;

  wire[2:0] bfu_rdreq_write_mux1h_2_nl;
  wire[29:0] outputUnit_outputUnit_req_core_else_else_else_else_if_acc_nl;
  wire[30:0] nl_outputUnit_outputUnit_req_core_else_else_else_else_if_acc_nl;

  // Interconnect Declarations for Component Instantiations 
  wire [13:0] nl_outputUnit_outputUnit_req_outputUnit_req_bfu_rdreq_t_Push_mioi_inst_bfu_rdreq_t_Push_mioi_idat;
  assign nl_outputUnit_outputUnit_req_outputUnit_req_bfu_rdreq_t_Push_mioi_inst_bfu_rdreq_t_Push_mioi_idat
      = {2'b00 , bfu_rdreq_t_Push_mioi_idat_11_9 , 2'b00 , bfu_rdreq_t_Push_mioi_idat_6_4
      , bfu_rdreq_t_Push_mioi_idat_3_0};
  outputUnit_outputUnit_outputUnit_req_outputUnit_req_cmd_in_t_Pop_mioi outputUnit_outputUnit_req_outputUnit_req_cmd_in_t_Pop_mioi_inst
      (
      .cmd_in_t_val(cmd_in_t_val),
      .cmd_in_t_rdy(cmd_in_t_rdy),
      .cmd_in_t_msg(cmd_in_t_msg),
      .cmd_in_t_Pop_mioi_oswt(reg_cmd_in_t_Pop_mioi_oswt_cse),
      .cmd_in_t_Pop_mioi_wen_comp(cmd_in_t_Pop_mioi_wen_comp),
      .cmd_in_t_Pop_mioi_idat_mxwt(cmd_in_t_Pop_mioi_idat_mxwt)
    );
  outputUnit_outputUnit_outputUnit_req_outputUnit_req_bfu_rdreq_t_Push_mioi outputUnit_outputUnit_req_outputUnit_req_bfu_rdreq_t_Push_mioi_inst
      (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .bfu_rdreq_t_val(bfu_rdreq_t_val),
      .bfu_rdreq_t_rdy(bfu_rdreq_t_rdy),
      .bfu_rdreq_t_msg(bfu_rdreq_t_msg),
      .outputUnit_req_wen(outputUnit_req_wen),
      .bfu_rdreq_t_Push_mioi_oswt(reg_bfu_rdreq_t_Push_mioi_oswt_cse),
      .bfu_rdreq_t_Push_mioi_wen_comp(bfu_rdreq_t_Push_mioi_wen_comp),
      .bfu_rdreq_t_Push_mioi_idat(nl_outputUnit_outputUnit_req_outputUnit_req_bfu_rdreq_t_Push_mioi_inst_bfu_rdreq_t_Push_mioi_idat[13:0])
    );
  outputUnit_outputUnit_outputUnit_req_outputUnit_req_req_rsp_fifo_cnsi outputUnit_outputUnit_req_outputUnit_req_req_rsp_fifo_cnsi_inst
      (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .req_rsp_fifo_cns_dat(req_rsp_fifo_cns_dat),
      .req_rsp_fifo_cns_vld(req_rsp_fifo_cns_vld),
      .req_rsp_fifo_cns_rdy(req_rsp_fifo_cns_rdy),
      .outputUnit_req_wen(outputUnit_req_wen),
      .req_rsp_fifo_cnsi_oswt(reg_req_rsp_fifo_cnsi_oswt_cse),
      .req_rsp_fifo_cnsi_wen_comp(req_rsp_fifo_cnsi_wen_comp),
      .req_rsp_fifo_cnsi_idat(req_rsp_fifo_cnsi_idat)
    );
  outputUnit_outputUnit_outputUnit_req_outputUnit_req_staller outputUnit_outputUnit_req_outputUnit_req_staller_inst
      (
      .outputUnit_req_wen(outputUnit_req_wen),
      .cmd_in_t_Pop_mioi_wen_comp(cmd_in_t_Pop_mioi_wen_comp),
      .bfu_rdreq_t_Push_mioi_wen_comp(bfu_rdreq_t_Push_mioi_wen_comp),
      .req_rsp_fifo_cnsi_wen_comp(req_rsp_fifo_cnsi_wen_comp)
    );
  outputUnit_outputUnit_outputUnit_req_outputUnit_req_outputUnit_req_fsm outputUnit_outputUnit_req_outputUnit_req_outputUnit_req_fsm_inst
      (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .outputUnit_req_wen(outputUnit_req_wen),
      .fsm_output(fsm_output)
    );
  assign or_74_cse = and_54_cse | (fsm_output[1]) | and_57_cse | and_58_cse;
  assign while_and_cse = outputUnit_req_wen & (fsm_output[1]);
  assign outputUnit_outputUnit_req_core_else_else_else_else_if_and_cse = outputUnit_req_wen
      & (fsm_output[3:2]==2'b00);
  assign and_dcpl = ~(outputUnit_outputUnit_req_core_else_if_outputUnit_outputUnit_req_core_else_if_nand_1_itm
      | outputUnit_outputUnit_req_core_else_else_if_outputUnit_outputUnit_req_core_else_else_if_nand_1_itm);
  assign or_dcpl_61 = (cmd_in_t_Pop_mio_mrgout_dat_sva[35:4]!=32'b00000000000000000000000000000001);
  assign or_dcpl_62 = outputUnit_outputUnit_req_core_else_else_else_if_outputUnit_outputUnit_req_core_else_else_else_if_nand_1_itm
      | (~ outputUnit_outputUnit_req_core_else_else_else_else_if_slc_outputUnit_outputUnit_req_core_else_else_else_else_if_acc_29_itm);
  assign and_54_cse = ((~ outputUnit_outputUnit_req_core_else_else_else_else_if_slc_outputUnit_outputUnit_req_core_else_else_else_else_if_acc_29_itm)
      | outputUnit_outputUnit_req_core_else_else_else_if_outputUnit_outputUnit_req_core_else_else_else_if_nand_1_itm
      | outputUnit_outputUnit_req_core_else_else_if_outputUnit_outputUnit_req_core_else_else_if_nand_1_itm
      | outputUnit_outputUnit_req_core_else_if_outputUnit_outputUnit_req_core_else_if_nand_1_itm)
      & or_dcpl_61 & (fsm_output[3]);
  assign and_57_cse = (((cmd_in_t_Pop_mio_mrgout_dat_sva[35:4]==32'b00000000000000000000000000000001))
      | outputUnit_outputUnit_req_core_else_if_outputUnit_outputUnit_req_core_else_if_nand_1_itm
      | outputUnit_outputUnit_req_core_else_else_if_outputUnit_outputUnit_req_core_else_else_if_nand_1_itm
      | or_dcpl_62) & (fsm_output[2]);
  assign and_58_cse = or_dcpl_61 & and_dcpl & or_dcpl_62 & (fsm_output[4]);
  assign bfu_rdreq_t_Push_mioi_idat_3_0_mx0c1 = and_54_cse | and_57_cse | and_58_cse;
  assign bfu_rdreq_t_Push_mioi_idat_11_9_mx0c2 = or_dcpl_61 & outputUnit_outputUnit_req_core_else_if_outputUnit_outputUnit_req_core_else_if_nand_1_itm
      & (fsm_output[3]);
  assign bfu_rdreq_t_Push_mioi_idat_11_9_mx0c3 = ((~ outputUnit_outputUnit_req_core_else_else_else_else_if_slc_outputUnit_outputUnit_req_core_else_else_else_else_if_acc_29_itm)
      | outputUnit_outputUnit_req_core_else_else_else_if_outputUnit_outputUnit_req_core_else_else_else_if_nand_1_itm
      | outputUnit_outputUnit_req_core_else_else_if_outputUnit_outputUnit_req_core_else_else_if_nand_1_itm)
      & or_dcpl_61 & (~ outputUnit_outputUnit_req_core_else_if_outputUnit_outputUnit_req_core_else_if_nand_1_itm)
      & (fsm_output[3]);
  assign bfu_rdreq_t_Push_mioi_idat_11_9_mx0c4 = or_dcpl_61 & and_dcpl & outputUnit_outputUnit_req_core_else_else_else_if_outputUnit_outputUnit_req_core_else_else_else_if_nand_1_itm
      & (fsm_output[4]);
  assign bfu_rdreq_t_Push_mioi_idat_11_9_mx0c5 = or_dcpl_61 & and_dcpl & (~(outputUnit_outputUnit_req_core_else_else_else_if_outputUnit_outputUnit_req_core_else_else_else_if_nand_1_itm
      | outputUnit_outputUnit_req_core_else_else_else_else_if_slc_outputUnit_outputUnit_req_core_else_else_else_else_if_acc_29_itm))
      & (fsm_output[4]);
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      reg_cmd_in_t_Pop_mioi_oswt_cse <= 1'b0;
      reg_bfu_rdreq_t_Push_mioi_oswt_cse <= 1'b0;
      reg_req_rsp_fifo_cnsi_oswt_cse <= 1'b0;
    end
    else if ( outputUnit_req_wen ) begin
      reg_cmd_in_t_Pop_mioi_oswt_cse <= (fsm_output[0]) | (fsm_output[5]);
      reg_bfu_rdreq_t_Push_mioi_oswt_cse <= or_74_cse;
      reg_req_rsp_fifo_cnsi_oswt_cse <= fsm_output[1];
    end
  end
  always @(posedge i_clk) begin
    if ( while_and_cse ) begin
      req_rsp_fifo_cnsi_idat <= cmd_in_t_Pop_mioi_idat_mxwt;
    end
  end
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      cmd_in_t_Pop_mio_mrgout_dat_sva <= 36'b000000000000000000000000000000000000;
    end
    else if ( while_and_cse ) begin
      cmd_in_t_Pop_mio_mrgout_dat_sva <= cmd_in_t_Pop_mioi_idat_mxwt;
    end
  end
  always @(posedge i_clk) begin
    if ( outputUnit_req_wen & ((fsm_output[1]) | bfu_rdreq_t_Push_mioi_idat_3_0_mx0c1)
        ) begin
      bfu_rdreq_t_Push_mioi_idat_3_0 <= MUX_v_4_2_2((cmd_in_t_Pop_mioi_idat_mxwt[3:0]),
          (cmd_in_t_Pop_mio_mrgout_dat_sva[3:0]), bfu_rdreq_t_Push_mioi_idat_3_0_mx0c1);
    end
  end
  always @(posedge i_clk) begin
    if ( outputUnit_req_wen & or_74_cse ) begin
      bfu_rdreq_t_Push_mioi_idat_6_4 <= MUX1HOT_v_3_4_2(3'b001, 3'b010, 3'b100, 3'b110,
          {(fsm_output[1]) , and_57_cse , and_54_cse , and_58_cse});
    end
  end
  always @(posedge i_clk) begin
    if ( outputUnit_req_wen & ((fsm_output[1]) | and_57_cse | bfu_rdreq_t_Push_mioi_idat_11_9_mx0c2
        | bfu_rdreq_t_Push_mioi_idat_11_9_mx0c3 | bfu_rdreq_t_Push_mioi_idat_11_9_mx0c4
        | bfu_rdreq_t_Push_mioi_idat_11_9_mx0c5) ) begin
      bfu_rdreq_t_Push_mioi_idat_11_9 <= MUX_v_3_2_2(bfu_rdreq_write_mux1h_2_nl,
          3'b111, bfu_rdreq_t_Push_mioi_idat_11_9_mx0c5);
    end
  end
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      outputUnit_outputUnit_req_core_else_else_else_else_if_slc_outputUnit_outputUnit_req_core_else_else_else_else_if_acc_29_itm
          <= 1'b0;
      outputUnit_outputUnit_req_core_else_else_else_if_outputUnit_outputUnit_req_core_else_else_else_if_nand_1_itm
          <= 1'b0;
      outputUnit_outputUnit_req_core_else_else_if_outputUnit_outputUnit_req_core_else_else_if_nand_1_itm
          <= 1'b0;
      outputUnit_outputUnit_req_core_else_if_outputUnit_outputUnit_req_core_else_if_nand_1_itm
          <= 1'b0;
    end
    else if ( outputUnit_outputUnit_req_core_else_else_else_else_if_and_cse ) begin
      outputUnit_outputUnit_req_core_else_else_else_else_if_slc_outputUnit_outputUnit_req_core_else_else_else_else_if_acc_29_itm
          <= readslicef_30_1_29(outputUnit_outputUnit_req_core_else_else_else_else_if_acc_nl);
      outputUnit_outputUnit_req_core_else_else_else_if_outputUnit_outputUnit_req_core_else_else_else_if_nand_1_itm
          <= ~((~((cmd_in_t_Pop_mioi_idat_mxwt[35:4]==32'b00000000000000000000000000000111)))
          & (~((cmd_in_t_Pop_mioi_idat_mxwt[35:4]==32'b00000000000000000000000000000110))));
      outputUnit_outputUnit_req_core_else_else_if_outputUnit_outputUnit_req_core_else_else_if_nand_1_itm
          <= ~((~((cmd_in_t_Pop_mioi_idat_mxwt[35:4]==32'b00000000000000000000000000000101)))
          & (~((cmd_in_t_Pop_mioi_idat_mxwt[35:4]==32'b00000000000000000000000000000100))));
      outputUnit_outputUnit_req_core_else_if_outputUnit_outputUnit_req_core_else_if_nand_1_itm
          <= ~((~((cmd_in_t_Pop_mioi_idat_mxwt[35:4]==32'b00000000000000000000000000000011)))
          & (~((cmd_in_t_Pop_mioi_idat_mxwt[35:4]==32'b00000000000000000000000000000010))));
    end
  end
  assign bfu_rdreq_write_mux1h_2_nl = MUX1HOT_v_3_5_2(3'b001, 3'b011, 3'b100, 3'b101,
      3'b110, {(fsm_output[1]) , and_57_cse , bfu_rdreq_t_Push_mioi_idat_11_9_mx0c2
      , bfu_rdreq_t_Push_mioi_idat_11_9_mx0c3 , bfu_rdreq_t_Push_mioi_idat_11_9_mx0c4});
  assign nl_outputUnit_outputUnit_req_core_else_else_else_else_if_acc_nl = conv_u2u_29_30(cmd_in_t_Pop_mioi_idat_mxwt[35:7])
      + 30'b111111111111111111111111111111;
  assign outputUnit_outputUnit_req_core_else_else_else_else_if_acc_nl = nl_outputUnit_outputUnit_req_core_else_else_else_else_if_acc_nl[29:0];

  function automatic [2:0] MUX1HOT_v_3_4_2;
    input [2:0] input_3;
    input [2:0] input_2;
    input [2:0] input_1;
    input [2:0] input_0;
    input [3:0] sel;
    reg [2:0] result;
  begin
    result = input_0 & {3{sel[0]}};
    result = result | (input_1 & {3{sel[1]}});
    result = result | (input_2 & {3{sel[2]}});
    result = result | (input_3 & {3{sel[3]}});
    MUX1HOT_v_3_4_2 = result;
  end
  endfunction


  function automatic [2:0] MUX1HOT_v_3_5_2;
    input [2:0] input_4;
    input [2:0] input_3;
    input [2:0] input_2;
    input [2:0] input_1;
    input [2:0] input_0;
    input [4:0] sel;
    reg [2:0] result;
  begin
    result = input_0 & {3{sel[0]}};
    result = result | (input_1 & {3{sel[1]}});
    result = result | (input_2 & {3{sel[2]}});
    result = result | (input_3 & {3{sel[3]}});
    result = result | (input_4 & {3{sel[4]}});
    MUX1HOT_v_3_5_2 = result;
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


  function automatic [0:0] readslicef_30_1_29;
    input [29:0] vector;
    reg [29:0] tmp;
  begin
    tmp = vector >> 29;
    readslicef_30_1_29 = tmp[0:0];
  end
  endfunction


  function automatic [29:0] conv_u2u_29_30 ;
    input [28:0]  vector ;
  begin
    conv_u2u_29_30 = {1'b0, vector};
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    outputUnit_outputUnit_outputUnit_rsp
// ------------------------------------------------------------------


module outputUnit_outputUnit_outputUnit_rsp (
  i_clk, i_rst, bt0, bt1, stream_out_t_val, stream_out_t_rdy, stream_out_t_msg, bfu_out_t_val,
      bfu_out_t_rdy, bfu_out_t_msg, bfu_rdrsp_t_val, bfu_rdrsp_t_rdy, bfu_rdrsp_t_msg,
      req_rsp_fifo_cns_dat, req_rsp_fifo_cns_vld, req_rsp_fifo_cns_rdy
);
  input i_clk;
  input i_rst;
  input [31:0] bt0;
  input [31:0] bt1;
  output stream_out_t_val;
  input stream_out_t_rdy;
  output [522:0] stream_out_t_msg;
  output bfu_out_t_val;
  input bfu_out_t_rdy;
  output [36:0] bfu_out_t_msg;
  input bfu_rdrsp_t_val;
  output bfu_rdrsp_t_rdy;
  input [383:0] bfu_rdrsp_t_msg;
  input [35:0] req_rsp_fifo_cns_dat;
  input req_rsp_fifo_cns_vld;
  output req_rsp_fifo_cns_rdy;



  // Interconnect Declarations for Component Instantiations 
  outputUnit_outputUnit_outputUnit_rsp_outputUnit_rsp outputUnit_outputUnit_rsp_outputUnit_rsp_inst
      (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .bt0(bt0),
      .bt1(bt1),
      .stream_out_t_val(stream_out_t_val),
      .stream_out_t_rdy(stream_out_t_rdy),
      .stream_out_t_msg(stream_out_t_msg),
      .bfu_out_t_val(bfu_out_t_val),
      .bfu_out_t_rdy(bfu_out_t_rdy),
      .bfu_out_t_msg(bfu_out_t_msg),
      .bfu_rdrsp_t_val(bfu_rdrsp_t_val),
      .bfu_rdrsp_t_rdy(bfu_rdrsp_t_rdy),
      .bfu_rdrsp_t_msg(bfu_rdrsp_t_msg),
      .req_rsp_fifo_cns_dat(req_rsp_fifo_cns_dat),
      .req_rsp_fifo_cns_vld(req_rsp_fifo_cns_vld),
      .req_rsp_fifo_cns_rdy(req_rsp_fifo_cns_rdy)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    outputUnit_outputUnit_outputUnit_req
// ------------------------------------------------------------------


module outputUnit_outputUnit_outputUnit_req (
  i_clk, i_rst, cmd_in_t_val, cmd_in_t_rdy, cmd_in_t_msg, bfu_rdreq_t_val, bfu_rdreq_t_rdy,
      bfu_rdreq_t_msg, req_rsp_fifo_cns_dat, req_rsp_fifo_cns_vld, req_rsp_fifo_cns_rdy
);
  input i_clk;
  input i_rst;
  input cmd_in_t_val;
  output cmd_in_t_rdy;
  input [35:0] cmd_in_t_msg;
  output bfu_rdreq_t_val;
  input bfu_rdreq_t_rdy;
  output [13:0] bfu_rdreq_t_msg;
  output [35:0] req_rsp_fifo_cns_dat;
  output req_rsp_fifo_cns_vld;
  input req_rsp_fifo_cns_rdy;



  // Interconnect Declarations for Component Instantiations 
  outputUnit_outputUnit_outputUnit_req_outputUnit_req outputUnit_outputUnit_req_outputUnit_req_inst
      (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .cmd_in_t_val(cmd_in_t_val),
      .cmd_in_t_rdy(cmd_in_t_rdy),
      .cmd_in_t_msg(cmd_in_t_msg),
      .bfu_rdreq_t_val(bfu_rdreq_t_val),
      .bfu_rdreq_t_rdy(bfu_rdreq_t_rdy),
      .bfu_rdreq_t_msg(bfu_rdreq_t_msg),
      .req_rsp_fifo_cns_dat(req_rsp_fifo_cns_dat),
      .req_rsp_fifo_cns_vld(req_rsp_fifo_cns_vld),
      .req_rsp_fifo_cns_rdy(req_rsp_fifo_cns_rdy)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    outputUnit
// ------------------------------------------------------------------


module outputUnit_wrap (
  i_clk, i_rst, bt0, bt1, stream_out_t_val, stream_out_t_rdy, stream_out_t_msg, cmd_in_t_val,
      cmd_in_t_rdy, cmd_in_t_msg, bfu_out_t_val, bfu_out_t_rdy, bfu_out_t_msg, bfu_rdreq_t_val,
      bfu_rdreq_t_rdy, bfu_rdreq_t_msg, bfu_rdrsp_t_val, bfu_rdrsp_t_rdy, bfu_rdrsp_t_msg
);
  input i_clk;
  input i_rst;
  input [31:0] bt0;
  input [31:0] bt1;
  output stream_out_t_val;
  input stream_out_t_rdy;
  output [522:0] stream_out_t_msg;
  input cmd_in_t_val;
  output cmd_in_t_rdy;
  input [35:0] cmd_in_t_msg;
  output bfu_out_t_val;
  input bfu_out_t_rdy;
  output [36:0] bfu_out_t_msg;
  output bfu_rdreq_t_val;
  input bfu_rdreq_t_rdy;
  output [13:0] bfu_rdreq_t_msg;
  input bfu_rdrsp_t_val;
  output bfu_rdrsp_t_rdy;
  input [383:0] bfu_rdrsp_t_msg;


  // Interconnect Declarations
  wire [35:0] req_rsp_fifo_cns_dat_n_outputUnit_outputUnit_req_inst;
  wire req_rsp_fifo_cns_rdy_n_outputUnit_outputUnit_req_inst;
  wire [35:0] req_rsp_fifo_cns_dat_n_outputUnit_outputUnit_rsp_inst;
  wire req_rsp_fifo_cns_vld_n_outputUnit_outputUnit_rsp_inst;
  wire req_rsp_fifo_cns_vld_n_outputUnit_outputUnit_req_inst_bud;
  wire req_rsp_fifo_cns_rdy_n_outputUnit_outputUnit_rsp_inst_bud;
  wire req_rsp_fifo_unc_2;
  wire req_rsp_fifo_idle;


  // Interconnect Declarations for Component Instantiations 
  ccs_pipe_v6 #(.rscid(32'sd22),
  .width(32'sd36),
  .sz_width(32'sd1),
  .fifo_sz(32'sd2),
  .log2_sz(32'sd1),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd1)) req_rsp_fifo_cns_pipe (
      .clk(i_clk),
      .en(1'b0),
      .arst(1'b1),
      .srst(i_rst),
      .din_rdy(req_rsp_fifo_cns_rdy_n_outputUnit_outputUnit_req_inst),
      .din_vld(req_rsp_fifo_cns_vld_n_outputUnit_outputUnit_req_inst_bud),
      .din(req_rsp_fifo_cns_dat_n_outputUnit_outputUnit_req_inst),
      .dout_rdy(req_rsp_fifo_cns_rdy_n_outputUnit_outputUnit_rsp_inst_bud),
      .dout_vld(req_rsp_fifo_cns_vld_n_outputUnit_outputUnit_rsp_inst),
      .dout(req_rsp_fifo_cns_dat_n_outputUnit_outputUnit_rsp_inst),
      .sz(req_rsp_fifo_unc_2),
      .sz_req(1'b0),
      .is_idle(req_rsp_fifo_idle)
    );
  outputUnit_outputUnit_outputUnit_req outputUnit_outputUnit_req_inst (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .cmd_in_t_val(cmd_in_t_val),
      .cmd_in_t_rdy(cmd_in_t_rdy),
      .cmd_in_t_msg(cmd_in_t_msg),
      .bfu_rdreq_t_val(bfu_rdreq_t_val),
      .bfu_rdreq_t_rdy(bfu_rdreq_t_rdy),
      .bfu_rdreq_t_msg(bfu_rdreq_t_msg),
      .req_rsp_fifo_cns_dat(req_rsp_fifo_cns_dat_n_outputUnit_outputUnit_req_inst),
      .req_rsp_fifo_cns_vld(req_rsp_fifo_cns_vld_n_outputUnit_outputUnit_req_inst_bud),
      .req_rsp_fifo_cns_rdy(req_rsp_fifo_cns_rdy_n_outputUnit_outputUnit_req_inst)
    );
  outputUnit_outputUnit_outputUnit_rsp outputUnit_outputUnit_rsp_inst (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .bt0(bt0),
      .bt1(bt1),
      .stream_out_t_val(stream_out_t_val),
      .stream_out_t_rdy(stream_out_t_rdy),
      .stream_out_t_msg(stream_out_t_msg),
      .bfu_out_t_val(bfu_out_t_val),
      .bfu_out_t_rdy(bfu_out_t_rdy),
      .bfu_out_t_msg(bfu_out_t_msg),
      .bfu_rdrsp_t_val(bfu_rdrsp_t_val),
      .bfu_rdrsp_t_rdy(bfu_rdrsp_t_rdy),
      .bfu_rdrsp_t_msg(bfu_rdrsp_t_msg),
      .req_rsp_fifo_cns_dat(req_rsp_fifo_cns_dat_n_outputUnit_outputUnit_rsp_inst),
      .req_rsp_fifo_cns_vld(req_rsp_fifo_cns_vld_n_outputUnit_outputUnit_rsp_inst),
      .req_rsp_fifo_cns_rdy(req_rsp_fifo_cns_rdy_n_outputUnit_outputUnit_rsp_inst_bud)
    );
endmodule



