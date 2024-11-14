
//------> /tools/Siemens_EDA/Catapult_Synthesis_2022.2-1008433/Mgc_home/pkgs/siflibs/ccs_ctrl_in_buf_wait_v4.v 
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
// Change History:
//    2019-01-24 - Add assertion to verify rdy signal behavior under reset.
//                 Fix bug in that behavior.
//    2019-01-04 - Fixed bug 54073 - rdy signal should not be asserted during
//                 reset
//    2018-11-19 - Improved code coverage for is_idle
//    2018-08-22 - Added is_idle to interface (as compare to 
//                 ccs_ctrl_in_buf_wait_v2)
//------------------------------------------------------------------------------


module ccs_ctrl_in_buf_wait_v4 (clk, en, arst, srst, irdy, ivld, idat, vld, rdy, dat, is_idle);

    parameter integer rscid   = 1;
    parameter integer width   = 8;
    parameter integer ph_clk  = 1;
    parameter integer ph_en   = 1;
    parameter integer ph_arst = 1;
    parameter integer ph_srst = 1;

    input              clk;
    input              en;
    input              arst;
    input              srst;
    output             rdy;
    input              vld;
    input  [width-1:0] dat;
    input              irdy;
    output             ivld;
    output [width-1:0] idat;
    output             is_idle;

    wire               rdy_int;
    wire               vld_int;
    reg                filled;
    wire               filled_next;
    wire               lbuf;
    reg    [width-1:0] abuf;
    reg                hs_init;

    assign rdy_int = ~filled | irdy;
    assign rdy = rdy_int & hs_init;
    assign vld_int = vld & hs_init;

    assign ivld = filled_next;
    assign idat = abuf;

    assign lbuf = vld_int & rdy_int;
    assign filled_next = vld_int | (filled & ~irdy);

    assign is_idle = ~lbuf & (filled ~^ filled_next) & hs_init;

    // Output registers:
    generate
    if (ph_arst == 0 && ph_clk == 1)
    begin: POS_CLK_NEG_ARST
        always @(posedge clk or negedge arst)
        if (arst == 1'b0)
        begin
            filled <= 1'b0;
            hs_init <= 1'b0;
            abuf <= {width{1'b0}};
        end
        else if (srst == ph_srst)
        begin
            filled <= 1'b0;
            hs_init <= 1'b0;
            abuf <= {width{1'b0}};
        end
        else if (en == ph_en)
        begin
            filled <= filled_next;
            hs_init <= 1'b1;
            if (lbuf == 1'b1)
                abuf <= dat;
        end
    end
    else if (ph_arst == 1 && ph_clk == 1)
    begin: POS_CLK_POS_ARST
        always @(posedge clk or posedge arst)
        if (arst == 1'b1)
        begin
            filled <= 1'b0;
            hs_init <= 1'b0;
            abuf <= {width{1'b0}};
        end
        else if (srst == ph_srst)
        begin
            filled <= 1'b0;
            hs_init <= 1'b0;
            abuf <= {width{1'b0}};
        end
        else if (en == ph_en)
        begin
            filled <= filled_next;
            hs_init <= 1'b1;
            if (lbuf == 1'b1)
                abuf <= dat;
        end
    end
    else if (ph_arst == 0 && ph_clk == 0)
    begin: NEG_CLK_NEG_ARST
        always @(negedge clk or negedge arst)
        if (arst == 1'b0)
        begin
            filled <= 1'b0;
            hs_init <= 1'b0;
            abuf <= {width{1'b0}};
        end
        else if (srst == ph_srst)
        begin
            filled <= 1'b0;
            hs_init <= 1'b0;
            abuf <= {width{1'b0}};
        end
        else if (en == ph_en)
        begin
            filled <= filled_next;
            hs_init <= 1'b1;
            if (lbuf == 1'b1)
                abuf <= dat;
        end
    end
    else if (ph_arst == 1 && ph_clk == 0)
    begin: NEG_CLK_POS_ARST
        always @(negedge clk or posedge arst)
        if (arst == 1'b1)
        begin
            filled <= 1'b0;
            hs_init <= 1'b0;
            abuf <= {width{1'b0}};
        end
        else if (srst == ph_srst)
        begin
            filled <= 1'b0;
            hs_init <= 1'b0;
            abuf <= {width{1'b0}};
        end
        else if (en == ph_en)
        begin
            filled <= filled_next;
            hs_init <= 1'b1;
            if (lbuf == 1'b1)
                abuf <= dat;
        end
    end
    endgenerate

`ifdef RDY_ASRT 
    generate
    if (ph_clk==1) 
    begin: POS_CLK_ASSERT

       property rdyAsrt ;
         @(posedge clk) (srst==ph_srst) |=> (rdy==0);
       endproperty
       a1: assert property(rdyAsrt);

       property rdyAsrtASync ;
         @(posedge clk) (arst==ph_arst) |-> (rdy==0);
       endproperty
       a2: assert property(rdyAsrtASync);

    end else if (ph_clk==0) 
    begin: NEG_CLK_ASSERT

       property rdyAsrt ;
         @(negedge clk) ((srst==ph_srst) || (arst==ph_arst)) |=> (rdy==0);
       endproperty
       a1: assert property(rdyAsrt);

       property rdyAsrtASync ;
         @(negedge clk) (arst==ph_arst) |-> (rdy==0);
       endproperty
       a2: assert property(rdyAsrtASync);
    end
    endgenerate

`endif

endmodule



//------> /tools/Siemens_EDA/Catapult_Synthesis_2022.2-1008433/Mgc_home/pkgs/siflibs/ccs_out_buf_wait_v5.v 
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

module ccs_out_buf_wait_v5 (clk, en, arst, srst, ivld, irdy, idat, rdy, vld, dat, is_idle);

    parameter integer  rscid   = 1;
    parameter integer  width   = 8;
    parameter integer  ph_clk  = 1;
    parameter integer  ph_en   = 1;
    parameter integer  ph_arst = 1;
    parameter integer  ph_srst = 1;
    parameter integer  rst_val = 0;

    input              clk;
    input              en;
    input              arst;
    input              srst;
    output             irdy;
    input              ivld;
    input  [width-1:0] idat;
    input              rdy;
    output             vld;
    output [width-1:0] dat;
    output             is_idle;

    reg                filled;
    wire               filled_next;
    wire               lbuf;
    reg    [width-1:0] abuf;

    assign irdy = ~filled_next;

    assign vld = filled | ivld;
    assign dat = filled ? abuf : idat;

    assign lbuf = ivld & ~filled & ~rdy;
    assign filled_next = filled ? ~rdy : lbuf;

    assign is_idle = ~lbuf & (filled ~^ filled_next);

    // Output registers:
    generate
    if (ph_arst == 0 && ph_clk == 1)
    begin: POS_CLK_NEG_ARST
        always @(posedge clk or negedge arst)
        if (arst == 1'b0)
        begin
            filled <= 1'b0;
            abuf <= {width{rst_val}};
        end
        else if (srst == ph_srst)
        begin
            filled <= 1'b0;
            abuf <= {width{rst_val}};
        end
        else if (en == ph_en)
        begin
            filled <= filled_next;
            if (lbuf == 1'b1)
                abuf <= idat;
        end
    end
    else if (ph_arst == 1 && ph_clk == 1)
    begin: POS_CLK_POS_ARST
        always @(posedge clk or posedge arst)
        if (arst == 1'b1)
        begin
            filled <= 1'b0;
            abuf <= {width{rst_val}};
        end
        else if (srst == ph_srst)
        begin
            filled <= 1'b0;
            abuf <= {width{rst_val}};
        end
        else if (en == ph_en)
        begin
            filled <= filled_next;
            if (lbuf == 1'b1)
                abuf <= idat;
        end
    end
    else if (ph_arst == 0 && ph_clk == 0)
    begin: NEG_CLK_NEG_ARST
        always @(negedge clk or negedge arst)
        if (arst == 1'b0)
        begin
            filled <= 1'b0;
            abuf <= {width{rst_val}};
        end
        else if (srst == ph_srst)
        begin
            filled <= 1'b0;
            abuf <= {width{rst_val}};
        end
        else if (en == ph_en)
        begin
            filled <= filled_next;
            if (lbuf == 1'b1)
                abuf <= idat;
        end
    end
    else if (ph_arst == 1 && ph_clk == 0)
    begin: NEG_CLK_POS_ARST
        always @(negedge clk or posedge arst)
        if (arst == 1'b1)
        begin
            filled <= 1'b0;
            abuf <= {width{rst_val}};
        end
        else if (srst == ph_srst)
        begin
            filled <= 1'b0;
            abuf <= {width{rst_val}};
        end
        else if (en == ph_en)
        begin
            filled <= filled_next;
            if (lbuf == 1'b1)
                abuf <= idat;
        end
    end
    endgenerate
endmodule

//------> ./rtl.v 
// ----------------------------------------------------------------------
//  HLS HDL:        Verilog Netlister
//  HLS Version:    2022.2/1008433 Production Release
//  HLS Date:       Fri Aug 19 18:40:59 PDT 2022
// 
//  Generated by:   rui.ma@fpga02
//  Generated date: Tue Oct 31 11:55:19 2023
// ----------------------------------------------------------------------

// 
// ------------------------------------------------------------------
//  Design Unit:    inputUnit_inputUnit_inputUnit_main_inputUnit_main_fsm
//  FSM Module
// ------------------------------------------------------------------


module inputUnit_inputUnit_inputUnit_main_inputUnit_main_fsm (
  i_clk, i_rst, inputUnit_main_wen, fsm_output, while_C_4_tr0, inputUnit_inputUnit_core_while_C_0_tr0
);
  input i_clk;
  input i_rst;
  input inputUnit_main_wen;
  output [10:0] fsm_output;
  reg [10:0] fsm_output;
  input while_C_4_tr0;
  input inputUnit_inputUnit_core_while_C_0_tr0;


  // FSM State Type Declaration for inputUnit_inputUnit_inputUnit_main_inputUnit_main_fsm_1
  parameter
    inputUnit_main_rlp_C_0 = 4'd0,
    while_C_0 = 4'd1,
    while_C_1 = 4'd2,
    while_C_2 = 4'd3,
    while_C_3 = 4'd4,
    while_C_4 = 4'd5,
    inputUnit_inputUnit_core_while_C_0 = 4'd6,
    while_C_5 = 4'd7,
    while_C_6 = 4'd8,
    while_C_7 = 4'd9,
    while_C_8 = 4'd10;

  reg [3:0] state_var;
  reg [3:0] state_var_NS;


  // Interconnect Declarations for Component Instantiations 
  always @(*)
  begin : inputUnit_inputUnit_inputUnit_main_inputUnit_main_fsm_1
    case (state_var)
      while_C_0 : begin
        fsm_output = 11'b00000000010;
        state_var_NS = while_C_1;
      end
      while_C_1 : begin
        fsm_output = 11'b00000000100;
        state_var_NS = while_C_2;
      end
      while_C_2 : begin
        fsm_output = 11'b00000001000;
        state_var_NS = while_C_3;
      end
      while_C_3 : begin
        fsm_output = 11'b00000010000;
        state_var_NS = while_C_4;
      end
      while_C_4 : begin
        fsm_output = 11'b00000100000;
        if ( while_C_4_tr0 ) begin
          state_var_NS = while_C_5;
        end
        else begin
          state_var_NS = inputUnit_inputUnit_core_while_C_0;
        end
      end
      inputUnit_inputUnit_core_while_C_0 : begin
        fsm_output = 11'b00001000000;
        if ( inputUnit_inputUnit_core_while_C_0_tr0 ) begin
          state_var_NS = while_C_5;
        end
        else begin
          state_var_NS = inputUnit_inputUnit_core_while_C_0;
        end
      end
      while_C_5 : begin
        fsm_output = 11'b00010000000;
        state_var_NS = while_C_6;
      end
      while_C_6 : begin
        fsm_output = 11'b00100000000;
        state_var_NS = while_C_7;
      end
      while_C_7 : begin
        fsm_output = 11'b01000000000;
        state_var_NS = while_C_8;
      end
      while_C_8 : begin
        fsm_output = 11'b10000000000;
        state_var_NS = while_C_0;
      end
      // inputUnit_main_rlp_C_0
      default : begin
        fsm_output = 11'b00000000001;
        state_var_NS = while_C_0;
      end
    endcase
  end

  always @(posedge i_clk) begin
    if ( i_rst ) begin
      state_var <= inputUnit_main_rlp_C_0;
    end
    else if ( inputUnit_main_wen ) begin
      state_var <= state_var_NS;
    end
  end

endmodule

// ------------------------------------------------------------------
//  Design Unit:    inputUnit_inputUnit_inputUnit_main_staller
// ------------------------------------------------------------------


module inputUnit_inputUnit_inputUnit_main_staller (
  inputUnit_main_wen, cmd_in_t_Pop_mioi_wen_comp, bfu_out_t_Push_mioi_wen_comp, stream_in_t_Pop_mioi_wen_comp,
      pkt_buf_out_t_Push_mioi_wen_comp
);
  output inputUnit_main_wen;
  input cmd_in_t_Pop_mioi_wen_comp;
  input bfu_out_t_Push_mioi_wen_comp;
  input stream_in_t_Pop_mioi_wen_comp;
  input pkt_buf_out_t_Push_mioi_wen_comp;



  // Interconnect Declarations for Component Instantiations 
  assign inputUnit_main_wen = cmd_in_t_Pop_mioi_wen_comp & bfu_out_t_Push_mioi_wen_comp
      & stream_in_t_Pop_mioi_wen_comp & pkt_buf_out_t_Push_mioi_wen_comp;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    inputUnit_inputUnit_inputUnit_main_pkt_buf_out_t_Push_mioi_pkt_buf_out_t_Push_mio_wait_dp
// ------------------------------------------------------------------


module inputUnit_inputUnit_inputUnit_main_pkt_buf_out_t_Push_mioi_pkt_buf_out_t_Push_mio_wait_dp
    (
  i_clk, i_rst, pkt_buf_out_t_Push_mioi_oswt, pkt_buf_out_t_Push_mioi_wen_comp, pkt_buf_out_t_Push_mioi_biwt,
      pkt_buf_out_t_Push_mioi_bdwt, pkt_buf_out_t_Push_mioi_bcwt, pkt_buf_out_t_Push_mioi_biwt_pff,
      pkt_buf_out_t_Push_mioi_bcwt_pff
);
  input i_clk;
  input i_rst;
  input pkt_buf_out_t_Push_mioi_oswt;
  output pkt_buf_out_t_Push_mioi_wen_comp;
  input pkt_buf_out_t_Push_mioi_biwt;
  input pkt_buf_out_t_Push_mioi_bdwt;
  output pkt_buf_out_t_Push_mioi_bcwt;
  input pkt_buf_out_t_Push_mioi_biwt_pff;
  output pkt_buf_out_t_Push_mioi_bcwt_pff;


  // Interconnect Declarations
  reg pkt_buf_out_t_Push_mioi_bcwt_reg;
  wire pkt_buf_out_write_nor_rmff;


  // Interconnect Declarations for Component Instantiations 
  assign pkt_buf_out_write_nor_rmff = ~((~(pkt_buf_out_t_Push_mioi_bcwt | pkt_buf_out_t_Push_mioi_biwt))
      | pkt_buf_out_t_Push_mioi_bdwt);
  assign pkt_buf_out_t_Push_mioi_wen_comp = (~ pkt_buf_out_t_Push_mioi_oswt) | pkt_buf_out_t_Push_mioi_biwt_pff
      | pkt_buf_out_t_Push_mioi_bcwt_pff;
  assign pkt_buf_out_t_Push_mioi_bcwt = pkt_buf_out_t_Push_mioi_bcwt_reg;
  assign pkt_buf_out_t_Push_mioi_bcwt_pff = pkt_buf_out_write_nor_rmff;
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      pkt_buf_out_t_Push_mioi_bcwt_reg <= 1'b0;
    end
    else begin
      pkt_buf_out_t_Push_mioi_bcwt_reg <= pkt_buf_out_write_nor_rmff;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    inputUnit_inputUnit_inputUnit_main_pkt_buf_out_t_Push_mioi_pkt_buf_out_t_Push_mio_wait_ctrl
// ------------------------------------------------------------------


module inputUnit_inputUnit_inputUnit_main_pkt_buf_out_t_Push_mioi_pkt_buf_out_t_Push_mio_wait_ctrl
    (
  inputUnit_main_wen, pkt_buf_out_t_Push_mioi_oswt, pkt_buf_out_t_Push_mioi_iswt0,
      pkt_buf_out_t_Push_mioi_irdy_oreg, pkt_buf_out_t_Push_mioi_biwt, pkt_buf_out_t_Push_mioi_bdwt,
      pkt_buf_out_t_Push_mioi_bcwt, pkt_buf_out_t_Push_mioi_ivld_inputUnit_main_sct,
      pkt_buf_out_t_Push_mioi_biwt_pff, pkt_buf_out_t_Push_mioi_iswt0_pff, pkt_buf_out_t_Push_mioi_bcwt_pff,
      pkt_buf_out_t_Push_mioi_irdy_oreg_pff
);
  input inputUnit_main_wen;
  input pkt_buf_out_t_Push_mioi_oswt;
  input pkt_buf_out_t_Push_mioi_iswt0;
  input pkt_buf_out_t_Push_mioi_irdy_oreg;
  output pkt_buf_out_t_Push_mioi_biwt;
  output pkt_buf_out_t_Push_mioi_bdwt;
  input pkt_buf_out_t_Push_mioi_bcwt;
  output pkt_buf_out_t_Push_mioi_ivld_inputUnit_main_sct;
  output pkt_buf_out_t_Push_mioi_biwt_pff;
  input pkt_buf_out_t_Push_mioi_iswt0_pff;
  input pkt_buf_out_t_Push_mioi_bcwt_pff;
  input pkt_buf_out_t_Push_mioi_irdy_oreg_pff;


  // Interconnect Declarations
  wire pkt_buf_out_t_Push_mioi_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign pkt_buf_out_t_Push_mioi_bdwt = pkt_buf_out_t_Push_mioi_oswt & inputUnit_main_wen;
  assign pkt_buf_out_t_Push_mioi_ogwt = pkt_buf_out_t_Push_mioi_iswt0 & (~ pkt_buf_out_t_Push_mioi_bcwt);
  assign pkt_buf_out_t_Push_mioi_ivld_inputUnit_main_sct = pkt_buf_out_t_Push_mioi_ogwt;
  assign pkt_buf_out_t_Push_mioi_biwt = pkt_buf_out_t_Push_mioi_ogwt & pkt_buf_out_t_Push_mioi_irdy_oreg;
  assign pkt_buf_out_t_Push_mioi_biwt_pff = pkt_buf_out_t_Push_mioi_iswt0_pff & (~
      pkt_buf_out_t_Push_mioi_bcwt_pff) & pkt_buf_out_t_Push_mioi_irdy_oreg_pff;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    inputUnit_inputUnit_inputUnit_main_stream_in_t_Pop_mioi_stream_in_t_Pop_mio_wait_dp
// ------------------------------------------------------------------


module inputUnit_inputUnit_inputUnit_main_stream_in_t_Pop_mioi_stream_in_t_Pop_mio_wait_dp
    (
  i_clk, i_rst, stream_in_t_Pop_mioi_oswt, stream_in_t_Pop_mioi_wen_comp, stream_in_t_Pop_mioi_idat_mxwt,
      stream_in_t_Pop_mioi_biwt, stream_in_t_Pop_mioi_bdwt, stream_in_t_Pop_mioi_bcwt,
      stream_in_t_Pop_mioi_idat, stream_in_t_Pop_mioi_biwt_pff, stream_in_t_Pop_mioi_bcwt_pff
);
  input i_clk;
  input i_rst;
  input stream_in_t_Pop_mioi_oswt;
  output stream_in_t_Pop_mioi_wen_comp;
  output [522:0] stream_in_t_Pop_mioi_idat_mxwt;
  input stream_in_t_Pop_mioi_biwt;
  input stream_in_t_Pop_mioi_bdwt;
  output stream_in_t_Pop_mioi_bcwt;
  input [522:0] stream_in_t_Pop_mioi_idat;
  input stream_in_t_Pop_mioi_biwt_pff;
  output stream_in_t_Pop_mioi_bcwt_pff;


  // Interconnect Declarations
  reg [522:0] stream_in_t_Pop_mioi_idat_bfwt;
  reg stream_in_t_Pop_mioi_bcwt_reg;
  wire stream_in_read_nor_rmff;


  // Interconnect Declarations for Component Instantiations 
  assign stream_in_read_nor_rmff = ~((~(stream_in_t_Pop_mioi_bcwt | stream_in_t_Pop_mioi_biwt))
      | stream_in_t_Pop_mioi_bdwt);
  assign stream_in_t_Pop_mioi_idat_mxwt = MUX_v_523_2_2(stream_in_t_Pop_mioi_idat,
      stream_in_t_Pop_mioi_idat_bfwt, stream_in_t_Pop_mioi_bcwt);
  assign stream_in_t_Pop_mioi_wen_comp = (~ stream_in_t_Pop_mioi_oswt) | stream_in_t_Pop_mioi_biwt_pff
      | stream_in_t_Pop_mioi_bcwt_pff;
  assign stream_in_t_Pop_mioi_bcwt = stream_in_t_Pop_mioi_bcwt_reg;
  assign stream_in_t_Pop_mioi_bcwt_pff = stream_in_read_nor_rmff;
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      stream_in_t_Pop_mioi_bcwt_reg <= 1'b0;
    end
    else begin
      stream_in_t_Pop_mioi_bcwt_reg <= stream_in_read_nor_rmff;
    end
  end
  always @(posedge i_clk) begin
    if ( stream_in_t_Pop_mioi_biwt ) begin
      stream_in_t_Pop_mioi_idat_bfwt <= stream_in_t_Pop_mioi_idat;
    end
  end

  function automatic [522:0] MUX_v_523_2_2;
    input [522:0] input_0;
    input [522:0] input_1;
    input  sel;
    reg [522:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_523_2_2 = result;
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    inputUnit_inputUnit_inputUnit_main_stream_in_t_Pop_mioi_stream_in_t_Pop_mio_wait_ctrl
// ------------------------------------------------------------------


module inputUnit_inputUnit_inputUnit_main_stream_in_t_Pop_mioi_stream_in_t_Pop_mio_wait_ctrl
    (
  inputUnit_main_wen, stream_in_t_Pop_mioi_oswt, stream_in_t_Pop_mioi_iswt0, stream_in_t_Pop_mioi_ivld_oreg,
      stream_in_t_Pop_mioi_biwt, stream_in_t_Pop_mioi_bdwt, stream_in_t_Pop_mioi_bcwt,
      stream_in_t_Pop_mioi_irdy_inputUnit_main_sct, stream_in_t_Pop_mioi_biwt_pff,
      stream_in_t_Pop_mioi_iswt0_pff, stream_in_t_Pop_mioi_bcwt_pff, stream_in_t_Pop_mioi_ivld_oreg_pff
);
  input inputUnit_main_wen;
  input stream_in_t_Pop_mioi_oswt;
  input stream_in_t_Pop_mioi_iswt0;
  input stream_in_t_Pop_mioi_ivld_oreg;
  output stream_in_t_Pop_mioi_biwt;
  output stream_in_t_Pop_mioi_bdwt;
  input stream_in_t_Pop_mioi_bcwt;
  output stream_in_t_Pop_mioi_irdy_inputUnit_main_sct;
  output stream_in_t_Pop_mioi_biwt_pff;
  input stream_in_t_Pop_mioi_iswt0_pff;
  input stream_in_t_Pop_mioi_bcwt_pff;
  input stream_in_t_Pop_mioi_ivld_oreg_pff;


  // Interconnect Declarations
  wire stream_in_t_Pop_mioi_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign stream_in_t_Pop_mioi_bdwt = stream_in_t_Pop_mioi_oswt & inputUnit_main_wen;
  assign stream_in_t_Pop_mioi_ogwt = stream_in_t_Pop_mioi_iswt0 & (~ stream_in_t_Pop_mioi_bcwt);
  assign stream_in_t_Pop_mioi_irdy_inputUnit_main_sct = stream_in_t_Pop_mioi_ogwt;
  assign stream_in_t_Pop_mioi_biwt = stream_in_t_Pop_mioi_ogwt & stream_in_t_Pop_mioi_ivld_oreg;
  assign stream_in_t_Pop_mioi_biwt_pff = stream_in_t_Pop_mioi_iswt0_pff & (~ stream_in_t_Pop_mioi_bcwt_pff)
      & stream_in_t_Pop_mioi_ivld_oreg_pff;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    inputUnit_inputUnit_inputUnit_main_bfu_out_t_Push_mioi_bfu_out_t_Push_mio_wait_dp
// ------------------------------------------------------------------


module inputUnit_inputUnit_inputUnit_main_bfu_out_t_Push_mioi_bfu_out_t_Push_mio_wait_dp
    (
  i_clk, i_rst, bfu_out_t_Push_mioi_oswt, bfu_out_t_Push_mioi_wen_comp, bfu_out_t_Push_mioi_biwt,
      bfu_out_t_Push_mioi_bdwt, bfu_out_t_Push_mioi_bcwt, bfu_out_t_Push_mioi_biwt_pff,
      bfu_out_t_Push_mioi_bcwt_pff
);
  input i_clk;
  input i_rst;
  input bfu_out_t_Push_mioi_oswt;
  output bfu_out_t_Push_mioi_wen_comp;
  input bfu_out_t_Push_mioi_biwt;
  input bfu_out_t_Push_mioi_bdwt;
  output bfu_out_t_Push_mioi_bcwt;
  input bfu_out_t_Push_mioi_biwt_pff;
  output bfu_out_t_Push_mioi_bcwt_pff;


  // Interconnect Declarations
  reg bfu_out_t_Push_mioi_bcwt_reg;
  wire bfu_out_write_last_nor_rmff;


  // Interconnect Declarations for Component Instantiations 
  assign bfu_out_write_last_nor_rmff = ~((~(bfu_out_t_Push_mioi_bcwt | bfu_out_t_Push_mioi_biwt))
      | bfu_out_t_Push_mioi_bdwt);
  assign bfu_out_t_Push_mioi_wen_comp = (~ bfu_out_t_Push_mioi_oswt) | bfu_out_t_Push_mioi_biwt_pff
      | bfu_out_t_Push_mioi_bcwt_pff;
  assign bfu_out_t_Push_mioi_bcwt = bfu_out_t_Push_mioi_bcwt_reg;
  assign bfu_out_t_Push_mioi_bcwt_pff = bfu_out_write_last_nor_rmff;
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      bfu_out_t_Push_mioi_bcwt_reg <= 1'b0;
    end
    else begin
      bfu_out_t_Push_mioi_bcwt_reg <= bfu_out_write_last_nor_rmff;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    inputUnit_inputUnit_inputUnit_main_bfu_out_t_Push_mioi_bfu_out_t_Push_mio_wait_ctrl
// ------------------------------------------------------------------


module inputUnit_inputUnit_inputUnit_main_bfu_out_t_Push_mioi_bfu_out_t_Push_mio_wait_ctrl
    (
  inputUnit_main_wen, bfu_out_t_Push_mioi_oswt, bfu_out_t_Push_mioi_iswt0, bfu_out_t_Push_mioi_irdy_oreg,
      bfu_out_t_Push_mioi_biwt, bfu_out_t_Push_mioi_bdwt, bfu_out_t_Push_mioi_bcwt,
      bfu_out_t_Push_mioi_ivld_inputUnit_main_sct, bfu_out_t_Push_mioi_biwt_pff,
      bfu_out_t_Push_mioi_iswt0_pff, bfu_out_t_Push_mioi_bcwt_pff, bfu_out_t_Push_mioi_irdy_oreg_pff
);
  input inputUnit_main_wen;
  input bfu_out_t_Push_mioi_oswt;
  input bfu_out_t_Push_mioi_iswt0;
  input bfu_out_t_Push_mioi_irdy_oreg;
  output bfu_out_t_Push_mioi_biwt;
  output bfu_out_t_Push_mioi_bdwt;
  input bfu_out_t_Push_mioi_bcwt;
  output bfu_out_t_Push_mioi_ivld_inputUnit_main_sct;
  output bfu_out_t_Push_mioi_biwt_pff;
  input bfu_out_t_Push_mioi_iswt0_pff;
  input bfu_out_t_Push_mioi_bcwt_pff;
  input bfu_out_t_Push_mioi_irdy_oreg_pff;


  // Interconnect Declarations
  wire bfu_out_t_Push_mioi_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign bfu_out_t_Push_mioi_bdwt = bfu_out_t_Push_mioi_oswt & inputUnit_main_wen;
  assign bfu_out_t_Push_mioi_ogwt = bfu_out_t_Push_mioi_iswt0 & (~ bfu_out_t_Push_mioi_bcwt);
  assign bfu_out_t_Push_mioi_ivld_inputUnit_main_sct = bfu_out_t_Push_mioi_ogwt;
  assign bfu_out_t_Push_mioi_biwt = bfu_out_t_Push_mioi_ogwt & bfu_out_t_Push_mioi_irdy_oreg;
  assign bfu_out_t_Push_mioi_biwt_pff = bfu_out_t_Push_mioi_iswt0_pff & (~ bfu_out_t_Push_mioi_bcwt_pff)
      & bfu_out_t_Push_mioi_irdy_oreg_pff;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    inputUnit_inputUnit_inputUnit_main_wait_dp
// ------------------------------------------------------------------


module inputUnit_inputUnit_inputUnit_main_wait_dp (
  i_clk, i_rst, bfu_out_t_Push_mioi_irdy, bfu_out_t_Push_mioi_irdy_oreg, stream_in_t_Pop_mioi_ivld,
      stream_in_t_Pop_mioi_ivld_oreg, pkt_buf_out_t_Push_mioi_irdy, pkt_buf_out_t_Push_mioi_irdy_oreg
);
  input i_clk;
  input i_rst;
  input bfu_out_t_Push_mioi_irdy;
  output bfu_out_t_Push_mioi_irdy_oreg;
  input stream_in_t_Pop_mioi_ivld;
  output stream_in_t_Pop_mioi_ivld_oreg;
  input pkt_buf_out_t_Push_mioi_irdy;
  output pkt_buf_out_t_Push_mioi_irdy_oreg;


  // Interconnect Declarations
  reg bfu_out_t_Push_mioi_irdy_oreg_rneg;
  reg stream_in_t_Pop_mioi_ivld_oreg_rneg;
  reg pkt_buf_out_t_Push_mioi_irdy_oreg_rneg;


  // Interconnect Declarations for Component Instantiations 
  assign bfu_out_t_Push_mioi_irdy_oreg = ~ bfu_out_t_Push_mioi_irdy_oreg_rneg;
  assign stream_in_t_Pop_mioi_ivld_oreg = ~ stream_in_t_Pop_mioi_ivld_oreg_rneg;
  assign pkt_buf_out_t_Push_mioi_irdy_oreg = ~ pkt_buf_out_t_Push_mioi_irdy_oreg_rneg;
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      bfu_out_t_Push_mioi_irdy_oreg_rneg <= 1'b0;
      stream_in_t_Pop_mioi_ivld_oreg_rneg <= 1'b0;
      pkt_buf_out_t_Push_mioi_irdy_oreg_rneg <= 1'b0;
    end
    else begin
      bfu_out_t_Push_mioi_irdy_oreg_rneg <= ~ bfu_out_t_Push_mioi_irdy;
      stream_in_t_Pop_mioi_ivld_oreg_rneg <= ~ stream_in_t_Pop_mioi_ivld;
      pkt_buf_out_t_Push_mioi_irdy_oreg_rneg <= ~ pkt_buf_out_t_Push_mioi_irdy;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    inputUnit_inputUnit_inputUnit_main_cmd_in_t_Pop_mioi_cmd_in_t_Pop_mio_wait_ctrl
// ------------------------------------------------------------------


module inputUnit_inputUnit_inputUnit_main_cmd_in_t_Pop_mioi_cmd_in_t_Pop_mio_wait_ctrl
    (
  cmd_in_t_Pop_mioi_iswt0, cmd_in_t_Pop_mioi_ivld_oreg, cmd_in_t_Pop_mioi_biwt
);
  input cmd_in_t_Pop_mioi_iswt0;
  input cmd_in_t_Pop_mioi_ivld_oreg;
  output cmd_in_t_Pop_mioi_biwt;



  // Interconnect Declarations for Component Instantiations 
  assign cmd_in_t_Pop_mioi_biwt = cmd_in_t_Pop_mioi_iswt0 & cmd_in_t_Pop_mioi_ivld_oreg;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    inputUnit_inputUnit_inputUnit_main_pkt_buf_out_t_Push_mioi
// ------------------------------------------------------------------


module inputUnit_inputUnit_inputUnit_main_pkt_buf_out_t_Push_mioi (
  i_clk, i_rst, pkt_buf_out_t_val, pkt_buf_out_t_rdy, pkt_buf_out_t_msg, inputUnit_main_wen,
      pkt_buf_out_t_Push_mioi_oswt, pkt_buf_out_t_Push_mioi_iswt0, pkt_buf_out_t_Push_mioi_wen_comp,
      pkt_buf_out_t_Push_mioi_idat, pkt_buf_out_t_Push_mioi_irdy, pkt_buf_out_t_Push_mioi_irdy_oreg,
      pkt_buf_out_t_Push_mioi_oswt_pff, pkt_buf_out_t_Push_mioi_iswt0_pff, pkt_buf_out_t_Push_mioi_irdy_oreg_pff
);
  input i_clk;
  input i_rst;
  output pkt_buf_out_t_val;
  input pkt_buf_out_t_rdy;
  output [522:0] pkt_buf_out_t_msg;
  input inputUnit_main_wen;
  input pkt_buf_out_t_Push_mioi_oswt;
  input pkt_buf_out_t_Push_mioi_iswt0;
  output pkt_buf_out_t_Push_mioi_wen_comp;
  input [522:0] pkt_buf_out_t_Push_mioi_idat;
  output pkt_buf_out_t_Push_mioi_irdy;
  input pkt_buf_out_t_Push_mioi_irdy_oreg;
  input pkt_buf_out_t_Push_mioi_oswt_pff;
  input pkt_buf_out_t_Push_mioi_iswt0_pff;
  input pkt_buf_out_t_Push_mioi_irdy_oreg_pff;


  // Interconnect Declarations
  wire pkt_buf_out_t_Push_mioi_biwt;
  wire pkt_buf_out_t_Push_mioi_bdwt;
  wire pkt_buf_out_t_Push_mioi_bcwt;
  wire pkt_buf_out_t_Push_mioi_ivld_inputUnit_main_sct;
  wire pkt_buf_out_t_Push_mioi_wen_comp_reg;
  wire pkt_buf_out_t_Push_mioi_biwt_iff;
  wire pkt_buf_out_t_Push_mioi_bcwt_iff;


  // Interconnect Declarations for Component Instantiations 
  ccs_out_buf_wait_v5 #(.rscid(32'sd27),
  .width(32'sd523),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd1)) pkt_buf_out_t_Push_mioi (
      .vld(pkt_buf_out_t_val),
      .rdy(pkt_buf_out_t_rdy),
      .dat(pkt_buf_out_t_msg),
      .idat(pkt_buf_out_t_Push_mioi_idat),
      .irdy(pkt_buf_out_t_Push_mioi_irdy),
      .ivld(pkt_buf_out_t_Push_mioi_ivld_inputUnit_main_sct),
      .clk(i_clk),
      .en(1'b0),
      .arst(1'b1),
      .srst(i_rst)
    );
  inputUnit_inputUnit_inputUnit_main_pkt_buf_out_t_Push_mioi_pkt_buf_out_t_Push_mio_wait_ctrl
      inputUnit_inputUnit_main_pkt_buf_out_t_Push_mioi_pkt_buf_out_t_Push_mio_wait_ctrl_inst
      (
      .inputUnit_main_wen(inputUnit_main_wen),
      .pkt_buf_out_t_Push_mioi_oswt(pkt_buf_out_t_Push_mioi_oswt),
      .pkt_buf_out_t_Push_mioi_iswt0(pkt_buf_out_t_Push_mioi_iswt0),
      .pkt_buf_out_t_Push_mioi_irdy_oreg(pkt_buf_out_t_Push_mioi_irdy_oreg),
      .pkt_buf_out_t_Push_mioi_biwt(pkt_buf_out_t_Push_mioi_biwt),
      .pkt_buf_out_t_Push_mioi_bdwt(pkt_buf_out_t_Push_mioi_bdwt),
      .pkt_buf_out_t_Push_mioi_bcwt(pkt_buf_out_t_Push_mioi_bcwt),
      .pkt_buf_out_t_Push_mioi_ivld_inputUnit_main_sct(pkt_buf_out_t_Push_mioi_ivld_inputUnit_main_sct),
      .pkt_buf_out_t_Push_mioi_biwt_pff(pkt_buf_out_t_Push_mioi_biwt_iff),
      .pkt_buf_out_t_Push_mioi_iswt0_pff(pkt_buf_out_t_Push_mioi_iswt0_pff),
      .pkt_buf_out_t_Push_mioi_bcwt_pff(pkt_buf_out_t_Push_mioi_bcwt_iff),
      .pkt_buf_out_t_Push_mioi_irdy_oreg_pff(pkt_buf_out_t_Push_mioi_irdy_oreg_pff)
    );
  inputUnit_inputUnit_inputUnit_main_pkt_buf_out_t_Push_mioi_pkt_buf_out_t_Push_mio_wait_dp
      inputUnit_inputUnit_main_pkt_buf_out_t_Push_mioi_pkt_buf_out_t_Push_mio_wait_dp_inst
      (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .pkt_buf_out_t_Push_mioi_oswt(pkt_buf_out_t_Push_mioi_oswt_pff),
      .pkt_buf_out_t_Push_mioi_wen_comp(pkt_buf_out_t_Push_mioi_wen_comp_reg),
      .pkt_buf_out_t_Push_mioi_biwt(pkt_buf_out_t_Push_mioi_biwt),
      .pkt_buf_out_t_Push_mioi_bdwt(pkt_buf_out_t_Push_mioi_bdwt),
      .pkt_buf_out_t_Push_mioi_bcwt(pkt_buf_out_t_Push_mioi_bcwt),
      .pkt_buf_out_t_Push_mioi_biwt_pff(pkt_buf_out_t_Push_mioi_biwt_iff),
      .pkt_buf_out_t_Push_mioi_bcwt_pff(pkt_buf_out_t_Push_mioi_bcwt_iff)
    );
  assign pkt_buf_out_t_Push_mioi_wen_comp = pkt_buf_out_t_Push_mioi_wen_comp_reg;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    inputUnit_inputUnit_inputUnit_main_stream_in_t_Pop_mioi
// ------------------------------------------------------------------


module inputUnit_inputUnit_inputUnit_main_stream_in_t_Pop_mioi (
  i_clk, i_rst, stream_in_t_val, stream_in_t_rdy, stream_in_t_msg, inputUnit_main_wen,
      stream_in_t_Pop_mioi_oswt, stream_in_t_Pop_mioi_iswt0, stream_in_t_Pop_mioi_wen_comp,
      stream_in_t_Pop_mioi_idat_mxwt, stream_in_t_Pop_mioi_ivld, stream_in_t_Pop_mioi_ivld_oreg,
      stream_in_t_Pop_mioi_oswt_pff, stream_in_t_Pop_mioi_iswt0_pff, stream_in_t_Pop_mioi_ivld_oreg_pff
);
  input i_clk;
  input i_rst;
  input stream_in_t_val;
  output stream_in_t_rdy;
  input [522:0] stream_in_t_msg;
  input inputUnit_main_wen;
  input stream_in_t_Pop_mioi_oswt;
  input stream_in_t_Pop_mioi_iswt0;
  output stream_in_t_Pop_mioi_wen_comp;
  output [522:0] stream_in_t_Pop_mioi_idat_mxwt;
  output stream_in_t_Pop_mioi_ivld;
  input stream_in_t_Pop_mioi_ivld_oreg;
  input stream_in_t_Pop_mioi_oswt_pff;
  input stream_in_t_Pop_mioi_iswt0_pff;
  input stream_in_t_Pop_mioi_ivld_oreg_pff;


  // Interconnect Declarations
  wire stream_in_t_Pop_mioi_biwt;
  wire stream_in_t_Pop_mioi_bdwt;
  wire stream_in_t_Pop_mioi_bcwt;
  wire [522:0] stream_in_t_Pop_mioi_idat;
  wire stream_in_t_Pop_mioi_irdy_inputUnit_main_sct;
  wire stream_in_t_Pop_mioi_wen_comp_reg;
  wire stream_in_t_Pop_mioi_biwt_iff;
  wire stream_in_t_Pop_mioi_bcwt_iff;


  // Interconnect Declarations for Component Instantiations 
  ccs_ctrl_in_buf_wait_v4 #(.rscid(32'sd26),
  .width(32'sd523),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd1)) stream_in_t_Pop_mioi (
      .vld(stream_in_t_val),
      .rdy(stream_in_t_rdy),
      .dat(stream_in_t_msg),
      .idat(stream_in_t_Pop_mioi_idat),
      .irdy(stream_in_t_Pop_mioi_irdy_inputUnit_main_sct),
      .ivld(stream_in_t_Pop_mioi_ivld),
      .clk(i_clk),
      .en(1'b0),
      .arst(1'b1),
      .srst(i_rst)
    );
  inputUnit_inputUnit_inputUnit_main_stream_in_t_Pop_mioi_stream_in_t_Pop_mio_wait_ctrl
      inputUnit_inputUnit_main_stream_in_t_Pop_mioi_stream_in_t_Pop_mio_wait_ctrl_inst
      (
      .inputUnit_main_wen(inputUnit_main_wen),
      .stream_in_t_Pop_mioi_oswt(stream_in_t_Pop_mioi_oswt),
      .stream_in_t_Pop_mioi_iswt0(stream_in_t_Pop_mioi_iswt0),
      .stream_in_t_Pop_mioi_ivld_oreg(stream_in_t_Pop_mioi_ivld_oreg),
      .stream_in_t_Pop_mioi_biwt(stream_in_t_Pop_mioi_biwt),
      .stream_in_t_Pop_mioi_bdwt(stream_in_t_Pop_mioi_bdwt),
      .stream_in_t_Pop_mioi_bcwt(stream_in_t_Pop_mioi_bcwt),
      .stream_in_t_Pop_mioi_irdy_inputUnit_main_sct(stream_in_t_Pop_mioi_irdy_inputUnit_main_sct),
      .stream_in_t_Pop_mioi_biwt_pff(stream_in_t_Pop_mioi_biwt_iff),
      .stream_in_t_Pop_mioi_iswt0_pff(stream_in_t_Pop_mioi_iswt0_pff),
      .stream_in_t_Pop_mioi_bcwt_pff(stream_in_t_Pop_mioi_bcwt_iff),
      .stream_in_t_Pop_mioi_ivld_oreg_pff(stream_in_t_Pop_mioi_ivld_oreg_pff)
    );
  inputUnit_inputUnit_inputUnit_main_stream_in_t_Pop_mioi_stream_in_t_Pop_mio_wait_dp
      inputUnit_inputUnit_main_stream_in_t_Pop_mioi_stream_in_t_Pop_mio_wait_dp_inst
      (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .stream_in_t_Pop_mioi_oswt(stream_in_t_Pop_mioi_oswt_pff),
      .stream_in_t_Pop_mioi_wen_comp(stream_in_t_Pop_mioi_wen_comp_reg),
      .stream_in_t_Pop_mioi_idat_mxwt(stream_in_t_Pop_mioi_idat_mxwt),
      .stream_in_t_Pop_mioi_biwt(stream_in_t_Pop_mioi_biwt),
      .stream_in_t_Pop_mioi_bdwt(stream_in_t_Pop_mioi_bdwt),
      .stream_in_t_Pop_mioi_bcwt(stream_in_t_Pop_mioi_bcwt),
      .stream_in_t_Pop_mioi_idat(stream_in_t_Pop_mioi_idat),
      .stream_in_t_Pop_mioi_biwt_pff(stream_in_t_Pop_mioi_biwt_iff),
      .stream_in_t_Pop_mioi_bcwt_pff(stream_in_t_Pop_mioi_bcwt_iff)
    );
  assign stream_in_t_Pop_mioi_wen_comp = stream_in_t_Pop_mioi_wen_comp_reg;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    inputUnit_inputUnit_inputUnit_main_bfu_out_t_Push_mioi
// ------------------------------------------------------------------


module inputUnit_inputUnit_inputUnit_main_bfu_out_t_Push_mioi (
  i_clk, i_rst, bfu_out_t_val, bfu_out_t_rdy, bfu_out_t_msg, inputUnit_main_wen,
      bfu_out_t_Push_mioi_oswt, bfu_out_t_Push_mioi_iswt0, bfu_out_t_Push_mioi_wen_comp,
      bfu_out_t_Push_mioi_idat, bfu_out_t_Push_mioi_irdy, bfu_out_t_Push_mioi_irdy_oreg,
      bfu_out_t_Push_mioi_oswt_pff, bfu_out_t_Push_mioi_iswt0_pff, bfu_out_t_Push_mioi_irdy_oreg_pff
);
  input i_clk;
  input i_rst;
  output bfu_out_t_val;
  input bfu_out_t_rdy;
  output [433:0] bfu_out_t_msg;
  input inputUnit_main_wen;
  input bfu_out_t_Push_mioi_oswt;
  input bfu_out_t_Push_mioi_iswt0;
  output bfu_out_t_Push_mioi_wen_comp;
  input [433:0] bfu_out_t_Push_mioi_idat;
  output bfu_out_t_Push_mioi_irdy;
  input bfu_out_t_Push_mioi_irdy_oreg;
  input bfu_out_t_Push_mioi_oswt_pff;
  input bfu_out_t_Push_mioi_iswt0_pff;
  input bfu_out_t_Push_mioi_irdy_oreg_pff;


  // Interconnect Declarations
  wire bfu_out_t_Push_mioi_biwt;
  wire bfu_out_t_Push_mioi_bdwt;
  wire bfu_out_t_Push_mioi_bcwt;
  wire bfu_out_t_Push_mioi_ivld_inputUnit_main_sct;
  wire bfu_out_t_Push_mioi_wen_comp_reg;
  wire bfu_out_t_Push_mioi_biwt_iff;
  wire bfu_out_t_Push_mioi_bcwt_iff;


  // Interconnect Declarations for Component Instantiations 
  wire [433:0] nl_bfu_out_t_Push_mioi_idat;
  assign nl_bfu_out_t_Push_mioi_idat = {(bfu_out_t_Push_mioi_idat[433:241]) , 1'b0
      , (bfu_out_t_Push_mioi_idat[239:236]) , 32'b00000000000000000000000000000000
      , (bfu_out_t_Push_mioi_idat[203:44]) , 2'b00 , (bfu_out_t_Push_mioi_idat[41:0])};
  ccs_out_buf_wait_v5 #(.rscid(32'sd25),
  .width(32'sd434),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd1)) bfu_out_t_Push_mioi (
      .vld(bfu_out_t_val),
      .rdy(bfu_out_t_rdy),
      .dat(bfu_out_t_msg),
      .idat(nl_bfu_out_t_Push_mioi_idat[433:0]),
      .irdy(bfu_out_t_Push_mioi_irdy),
      .ivld(bfu_out_t_Push_mioi_ivld_inputUnit_main_sct),
      .clk(i_clk),
      .en(1'b0),
      .arst(1'b1),
      .srst(i_rst)
    );
  inputUnit_inputUnit_inputUnit_main_bfu_out_t_Push_mioi_bfu_out_t_Push_mio_wait_ctrl
      inputUnit_inputUnit_main_bfu_out_t_Push_mioi_bfu_out_t_Push_mio_wait_ctrl_inst
      (
      .inputUnit_main_wen(inputUnit_main_wen),
      .bfu_out_t_Push_mioi_oswt(bfu_out_t_Push_mioi_oswt),
      .bfu_out_t_Push_mioi_iswt0(bfu_out_t_Push_mioi_iswt0),
      .bfu_out_t_Push_mioi_irdy_oreg(bfu_out_t_Push_mioi_irdy_oreg),
      .bfu_out_t_Push_mioi_biwt(bfu_out_t_Push_mioi_biwt),
      .bfu_out_t_Push_mioi_bdwt(bfu_out_t_Push_mioi_bdwt),
      .bfu_out_t_Push_mioi_bcwt(bfu_out_t_Push_mioi_bcwt),
      .bfu_out_t_Push_mioi_ivld_inputUnit_main_sct(bfu_out_t_Push_mioi_ivld_inputUnit_main_sct),
      .bfu_out_t_Push_mioi_biwt_pff(bfu_out_t_Push_mioi_biwt_iff),
      .bfu_out_t_Push_mioi_iswt0_pff(bfu_out_t_Push_mioi_iswt0_pff),
      .bfu_out_t_Push_mioi_bcwt_pff(bfu_out_t_Push_mioi_bcwt_iff),
      .bfu_out_t_Push_mioi_irdy_oreg_pff(bfu_out_t_Push_mioi_irdy_oreg_pff)
    );
  inputUnit_inputUnit_inputUnit_main_bfu_out_t_Push_mioi_bfu_out_t_Push_mio_wait_dp
      inputUnit_inputUnit_main_bfu_out_t_Push_mioi_bfu_out_t_Push_mio_wait_dp_inst
      (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .bfu_out_t_Push_mioi_oswt(bfu_out_t_Push_mioi_oswt_pff),
      .bfu_out_t_Push_mioi_wen_comp(bfu_out_t_Push_mioi_wen_comp_reg),
      .bfu_out_t_Push_mioi_biwt(bfu_out_t_Push_mioi_biwt),
      .bfu_out_t_Push_mioi_bdwt(bfu_out_t_Push_mioi_bdwt),
      .bfu_out_t_Push_mioi_bcwt(bfu_out_t_Push_mioi_bcwt),
      .bfu_out_t_Push_mioi_biwt_pff(bfu_out_t_Push_mioi_biwt_iff),
      .bfu_out_t_Push_mioi_bcwt_pff(bfu_out_t_Push_mioi_bcwt_iff)
    );
  assign bfu_out_t_Push_mioi_wen_comp = bfu_out_t_Push_mioi_wen_comp_reg;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    inputUnit_inputUnit_inputUnit_main_cmd_in_t_Pop_mioi
// ------------------------------------------------------------------


module inputUnit_inputUnit_inputUnit_main_cmd_in_t_Pop_mioi (
  i_clk, i_rst, cmd_in_t_val, cmd_in_t_rdy, cmd_in_t_msg, cmd_in_t_Pop_mioi_oswt,
      cmd_in_t_Pop_mioi_iswt0, cmd_in_t_Pop_mioi_wen_comp, cmd_in_t_Pop_mioi_idat_mxwt,
      cmd_in_t_Pop_mioi_iswt0_pff
);
  input i_clk;
  input i_rst;
  input cmd_in_t_val;
  output cmd_in_t_rdy;
  input [78:0] cmd_in_t_msg;
  input cmd_in_t_Pop_mioi_oswt;
  input cmd_in_t_Pop_mioi_iswt0;
  output cmd_in_t_Pop_mioi_wen_comp;
  output [73:0] cmd_in_t_Pop_mioi_idat_mxwt;
  input cmd_in_t_Pop_mioi_iswt0_pff;


  // Interconnect Declarations
  wire cmd_in_t_Pop_mioi_biwt;
  wire [78:0] cmd_in_t_Pop_mioi_idat;
  wire cmd_in_t_Pop_mioi_ivld;


  // Interconnect Declarations for Component Instantiations 
  ccs_ctrl_in_buf_wait_v4 #(.rscid(32'sd24),
  .width(32'sd79),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd1)) cmd_in_t_Pop_mioi (
      .vld(cmd_in_t_val),
      .rdy(cmd_in_t_rdy),
      .dat(cmd_in_t_msg),
      .idat(cmd_in_t_Pop_mioi_idat),
      .irdy(cmd_in_t_Pop_mioi_iswt0),
      .ivld(cmd_in_t_Pop_mioi_ivld),
      .clk(i_clk),
      .en(1'b0),
      .arst(1'b1),
      .srst(i_rst)
    );
  inputUnit_inputUnit_inputUnit_main_cmd_in_t_Pop_mioi_cmd_in_t_Pop_mio_wait_ctrl
      inputUnit_inputUnit_main_cmd_in_t_Pop_mioi_cmd_in_t_Pop_mio_wait_ctrl_inst
      (
      .cmd_in_t_Pop_mioi_iswt0(cmd_in_t_Pop_mioi_iswt0_pff),
      .cmd_in_t_Pop_mioi_ivld_oreg(cmd_in_t_Pop_mioi_ivld),
      .cmd_in_t_Pop_mioi_biwt(cmd_in_t_Pop_mioi_biwt)
    );
  assign cmd_in_t_Pop_mioi_wen_comp = (~ cmd_in_t_Pop_mioi_oswt) | cmd_in_t_Pop_mioi_biwt;
  assign cmd_in_t_Pop_mioi_idat_mxwt = {(cmd_in_t_Pop_mioi_idat[78:15]) , (cmd_in_t_Pop_mioi_idat[9:0])};
endmodule

// ------------------------------------------------------------------
//  Design Unit:    inputUnit_inputUnit_inputUnit_main
// ------------------------------------------------------------------


module inputUnit_inputUnit_inputUnit_main (
  i_clk, i_rst, stream_in_t_val, stream_in_t_rdy, stream_in_t_msg, cmd_in_t_val,
      cmd_in_t_rdy, cmd_in_t_msg, bfu_out_t_val, bfu_out_t_rdy, bfu_out_t_msg, pkt_buf_out_t_val,
      pkt_buf_out_t_rdy, pkt_buf_out_t_msg
);
  input i_clk;
  input i_rst;
  input stream_in_t_val;
  output stream_in_t_rdy;
  input [522:0] stream_in_t_msg;
  input cmd_in_t_val;
  output cmd_in_t_rdy;
  input [78:0] cmd_in_t_msg;
  output bfu_out_t_val;
  input bfu_out_t_rdy;
  output [433:0] bfu_out_t_msg;
  output pkt_buf_out_t_val;
  input pkt_buf_out_t_rdy;
  output [522:0] pkt_buf_out_t_msg;


  // Interconnect Declarations
  reg inputUnit_main_wen;
  wire cmd_in_t_Pop_mioi_wen_comp;
  wire [73:0] cmd_in_t_Pop_mioi_idat_mxwt;
  wire bfu_out_t_Push_mioi_wen_comp;
  wire bfu_out_t_Push_mioi_irdy;
  wire bfu_out_t_Push_mioi_irdy_oreg;
  wire stream_in_t_Pop_mioi_wen_comp;
  wire [522:0] stream_in_t_Pop_mioi_idat_mxwt;
  wire stream_in_t_Pop_mioi_ivld;
  wire stream_in_t_Pop_mioi_ivld_oreg;
  wire pkt_buf_out_t_Push_mioi_wen_comp;
  wire pkt_buf_out_t_Push_mioi_irdy;
  wire pkt_buf_out_t_Push_mioi_irdy_oreg;
  reg [63:0] bfu_out_t_Push_mioi_idat_433_370;
  reg [123:0] bfu_out_t_Push_mioi_idat_369_246;
  reg [31:0] bfu_out_t_Push_mioi_idat_203_172;
  reg [15:0] bfu_out_t_Push_mioi_idat_171_156;
  reg [47:0] bfu_out_t_Push_mioi_idat_155_108;
  reg [15:0] bfu_out_t_Push_mioi_idat_107_92;
  reg [47:0] bfu_out_t_Push_mioi_idat_91_44;
  reg [31:0] bfu_out_t_Push_mioi_idat_35_4;
  reg [3:0] bfu_out_t_Push_mioi_idat_3_0;
  reg pkt_buf_out_t_Push_mioi_idat_522;
  reg [17:0] pkt_buf_out_t_Push_mioi_idat_517_500;
  reg [3:0] pkt_buf_out_t_Push_mioi_idat_3_0;
  reg [2:0] bfu_out_t_Push_mioi_idat_245_243;
  reg bfu_out_t_Push_mioi_idat_242;
  reg [1:0] pkt_buf_out_t_Push_mioi_idat_521_520;
  reg pkt_buf_out_t_Push_mioi_idat_519;
  reg pkt_buf_out_t_Push_mioi_idat_518;
  reg [63:0] pkt_buf_out_t_Push_mioi_idat_499_436;
  reg [31:0] pkt_buf_out_t_Push_mioi_idat_435_404;
  reg bfu_out_t_Push_mioi_idat_241;
  reg [5:0] bfu_out_t_Push_mioi_idat_41_36;
  wire [10:0] fsm_output;
  wire inputUnit_inputUnit_core_else_if_nor_tmp;
  wire inputUnit_inputUnit_core_inputUnit_inputUnit_core_nand_tmp;
  wire nor_tmp_1;
  wire or_dcpl_18;
  wire and_dcpl_50;
  wire or_dcpl_64;
  wire and_dcpl_63;
  wire and_dcpl_64;
  wire or_dcpl_70;
  wire or_dcpl_78;
  wire or_dcpl_99;
  wire or_dcpl_104;
  wire or_dcpl_108;
  wire and_tmp_7;
  wire not_tmp_133;
  wire or_dcpl_120;
  wire mux_tmp_15;
  wire or_tmp_61;
  wire or_tmp_62;
  wire or_tmp_64;
  wire or_tmp_76;
  wire or_tmp_87;
  wire or_tmp_102;
  wire or_tmp_186;
  wire or_tmp_187;
  wire and_189_cse;
  wire and_191_cse;
  wire and_187_cse;
  wire and_206_cse;
  wire and_250_cse;
  wire and_198_cse;
  wire inputUnit_inputUnit_core_if_if_and_4_ssc_mx0w1;
  wire inputUnit_inputUnit_core_and_tmp_1;
  reg inputUnit_inputUnit_core_unequal_tmp;
  wire inputUnit_inputUnit_core_if_if_if_unequal_tmp_1;
  reg inputUnit_inputUnit_core_if_if_unequal_tmp;
  wire inputUnit_inputUnit_core_inputUnit_inputUnit_core_nor_1_ssc_1;
  wire inputUnit_inputUnit_core_if_if_and_ssc_1;
  wire inputUnit_inputUnit_core_and_ssc_2;
  wire inputUnit_inputUnit_core_if_if_if_if_and_ssc_3;
  wire inputUnit_inputUnit_core_if_if_if_if_and_4_ssc_1;
  wire inputUnit_inputUnit_core_if_if_if_if_if_if_and_ssc_4;
  wire inputUnit_inputUnit_core_if_if_if_if_if_if_if_unequal_tmp_1;
  wire inputUnit_inputUnit_core_if_if_if_if_if_if_unequal_tmp_1;
  wire inputUnit_inputUnit_core_if_if_if_if_and_3_m1c_1;
  wire inputUnit_inputUnit_core_if_if_and_1_m1c_1;
  wire inputUnit_inputUnit_core_if_unequal_tmp_1;
  wire inputUnit_inputUnit_core_if_if_if_if_and_9_mx0w1;
  wire inputUnit_inputUnit_core_if_if_if_if_if_if_and_2_ssc_mx0w1;
  wire inputUnit_inputUnit_core_if_if_if_if_unequal_tmp_1;
  wire inputUnit_inputUnit_core_if_if_if_if_if_unequal_tmp_1;
  reg while_unequal_tmp;
  reg inputUnit_inputUnit_core_or_2_psp;
  reg [15:0] header_0_hdr0_set_bv_63_48_lpi_1_dfm_1;
  reg inputUnit_inputUnit_core_inputUnit_inputUnit_core_and_1_itm;
  reg inputUnit_inputUnit_core_while_stage_0_1;
  reg inputUnit_inputUnit_core_if_unequal_tmp;
  reg while_if_nor_1_itm;
  reg inputUnit_inputUnit_core_and_ssc_1;
  reg [7:0] stream_in_read_slc_stream_in_t_Pop_mio_mrgout_dat_515_4_6_itm;
  reg [15:0] stream_in_read_slc_stream_in_t_Pop_mio_mrgout_dat_515_4_7_itm;
  wire inputUnit_inputUnit_core_if_if_if_if_and_ssc_mx0w0;
  reg inputUnit_inputUnit_core_if_if_if_if_and_ssc;
  reg [463:0] reg_stream_in_t_Pop_1mio_mrgout_dat_ftd_55;
  wire inputUnit_main_wen_rtff;
  reg reg_cmd_in_t_Pop_mioi_oswt_tmp;
  reg reg_cmd_in_t_Pop_mioi_iswt0_tmp;
  reg reg_bfu_out_t_Push_mioi_oswt_tmp;
  reg reg_bfu_out_t_Push_mioi_iswt0_tmp;
  reg reg_stream_in_t_Pop_mioi_oswt_tmp;
  reg reg_stream_in_t_Pop_mioi_iswt0_tmp;
  reg reg_pkt_buf_out_t_Push_mioi_oswt_tmp;
  reg reg_pkt_buf_out_t_Push_mioi_iswt0_tmp;
  wire cmd_in_read_mux_rmff;
  wire cmd_in_read_mux_1_rmff;
  wire bfu_out_write_last_mux_rmff;
  wire bfu_out_write_last_mux_1_rmff;
  wire stream_in_read_mux_4_rmff;
  wire stream_in_read_mux_5_rmff;
  wire pkt_buf_out_write_mux_rmff;
  wire pkt_buf_out_write_mux_1_rmff;
  wire bfu_out_write_last_and_cse;
  wire bfu_out_write_last_and_8_cse;
  wire bfu_out_write_last_and_1_cse;
  wire bfu_out_write_last_and_3_cse;
  wire pkt_buf_out_write_and_cse;
  wire cmd_in_read_and_cse;
  wire and_597_cse;
  reg stream_in_t_Pop_mio_mrgout_dat_sva_522;
  reg [511:0] stream_in_t_Pop_mio_mrgout_dat_sva_515_4;
  reg [3:0] stream_in_t_Pop_mio_mrgout_dat_sva_3_0;
  reg [63:0] cmd_in_t_Pop_mio_mrgout_dat_sva_78_15;
  reg [9:0] cmd_in_t_Pop_mio_mrgout_dat_sva_9_0;
  wire bfu_out_write_last_and_5_ssc;
  reg [2:0] bfu_out_t_Push_mioi_idat_239_237;
  reg bfu_out_t_Push_mioi_idat_236;
  wire pkt_buf_out_write_or_itm;
  reg [159:0] ptp_l_set_bv_lpi_1;
  reg [191:0] ptp_h_set_bv_lpi_1;
  reg [447:0] inputUnit_inputUnit_core_payload_data_3_463_16_lpi_1;
  reg [15:0] header_0_hdr0_set_bv_63_48_lpi_1;
  reg [31:0] bt0_sva;
  reg [31:0] bt1_sva;
  reg inputUnit_inputUnit_core_if_if_if_if_if_if_if_if_unequal_tmp;
  reg [159:0] ptp_l_set_bv_lpi_1_dfm;
  reg [191:0] ptp_h_set_bv_lpi_1_dfm;
  reg [447:0] inputUnit_inputUnit_core_payload_data_3_463_16_lpi_1_dfm_1;
  reg inputUnit_inputUnit_core_if_if_and_2_tmp;
  reg inputUnit_inputUnit_core_mux_itm;
  reg [47:0] stream_in_read_slc_stream_in_t_Pop_mio_mrgout_dat_515_4_itm;
  reg [127:0] inputUnit_inputUnit_core_payload_data_slc_inputUnit_inputUnit_core_payload_data_3_463_16_447_320_itm;
  reg [127:0] inputUnit_inputUnit_core_payload_data_slc_inputUnit_inputUnit_core_payload_data_3_463_16_319_192_itm;
  reg [31:0] bfu_out_write_4_asn_itm;
  reg [3:0] cmd_in_read_slc_cmd_in_t_Pop_mio_mrgout_dat_3_0_itm;
  reg inputUnit_inputUnit_core_if_if_if_if_and_5_ssc;
  reg inputUnit_inputUnit_core_if_if_if_if_if_if_and_2_ssc;
  reg [2:0] inputUnit_inputUnit_core_hdr_count_lpi_1_dfm_8_3_1;
  reg inputUnit_inputUnit_core_hdr_count_lpi_1_dfm_8_0;
  reg [1:0] inputUnit_inputUnit_core_pkt_empty_5_2_lpi_1_dfm_8_3_2;
  reg inputUnit_inputUnit_core_pkt_empty_5_2_lpi_1_dfm_8_1;
  reg [63:0] inputUnit_inputUnit_core_and_6_itm_95_32;
  reg [31:0] inputUnit_inputUnit_core_and_6_itm_31_0;
  wire bfu_out_t_Push_mioi_oswt_mx0;
  wire stream_in_t_Pop_mioi_oswt_mx0;
  wire bfu_out_t_Push_mioi_idat_241_mx0c0;
  wire bfu_out_t_Push_mioi_idat_35_4_mx0c2;
  wire bfu_out_t_Push_mioi_idat_3_0_mx0c1;
  wire inputUnit_inputUnit_core_if_if_if_if_if_if_if_if_unequal_tmp_mx0w0;
  wire inputUnit_inputUnit_core_if_if_if_if_if_if_if_if_unequal_tmp_mx2;
  wire inputUnit_inputUnit_core_if_if_if_if_if_if_and_ssc_3;
  wire inputUnit_inputUnit_core_if_if_if_if_if_if_and_6_ssc_1;
  wire inputUnit_inputUnit_core_and_ssc_1_mx0c2;
  wire inputUnit_inputUnit_core_if_if_and_3_ssc_1;
  wire inputUnit_inputUnit_core_nor_seb_1;
  wire inputUnit_inputUnit_core_if_if_asn_11;
  wire inputUnit_inputUnit_core_if_if_asn_13;
  wire inputUnit_inputUnit_core_if_if_and_9_ssc;
  reg [63:0] inputUnit_inputUnit_core_slc_inputUnit_inputUnit_core_pkt_data_buf_495_0_lpi_1_dfm_6_399_0_itm_303_240;
  reg [63:0] inputUnit_inputUnit_core_slc_inputUnit_inputUnit_core_pkt_data_buf_495_0_lpi_1_dfm_6_399_0_itm_239_176;
  wire inputUnit_inputUnit_core_if_if_if_if_if_if_if_if_mux_1_ssc;
  wire inputUnit_inputUnit_core_if_if_if_if_and_11_ssc;
  wire inputUnit_inputUnit_core_if_if_if_if_and_12_ssc;
  reg [47:0] inputUnit_inputUnit_core_slc_inputUnit_inputUnit_core_pkt_data_buf_495_0_lpi_1_dfm_6_399_0_itm_47_0;
  wire [63:0] inputUnit_inputUnit_core_pkt_data_buf_495_0_lpi_1_dfm_6_431_368;
  reg [63:0] pkt_buf_out_t_Push_mioi_idat_307_244;
  reg [63:0] pkt_buf_out_t_Push_mioi_idat_243_180;
  wire pkt_buf_out_write_pkt_buf_out_write_nor_ssc;
  wire pkt_buf_out_write_and_13_ssc;
  reg [47:0] pkt_buf_out_t_Push_mioi_idat_51_4;
  reg [31:0] inputUnit_inputUnit_core_slc_inputUnit_inputUnit_core_pkt_data_buf_495_0_lpi_1_dfm_6_399_0_itm_399_368;
  reg [63:0] inputUnit_inputUnit_core_slc_inputUnit_inputUnit_core_pkt_data_buf_495_0_lpi_1_dfm_6_399_0_itm_367_304;
  reg [31:0] pkt_buf_out_t_Push_mioi_idat_403_372;
  reg [63:0] pkt_buf_out_t_Push_mioi_idat_371_308;
  wire inputUnit_inputUnit_core_if_if_and_10_cse;
  wire inputUnit_inputUnit_core_if_and_cse;
  wire inputUnit_inputUnit_core_hdr_count_and_cse;
  wire inputUnit_inputUnit_core_and_20_cse;
  wire inputUnit_inputUnit_core_if_if_and_13_cse;
  wire stream_in_read_and_1_cse;
  reg [63:0] inputUnit_inputUnit_core_slc_inputUnit_inputUnit_core_pkt_data_buf_495_0_lpi_1_dfm_6_399_0_itm_175_112;
  reg [63:0] inputUnit_inputUnit_core_slc_inputUnit_inputUnit_core_pkt_data_buf_495_0_lpi_1_dfm_6_399_0_itm_111_48;
  reg [63:0] pkt_buf_out_t_Push_mioi_idat_179_116;
  reg [63:0] pkt_buf_out_t_Push_mioi_idat_115_52;
  wire inputUnit_inputUnit_core_if_if_and_14_cse;
  wire cmd_in_read_and_1_cse;

  wire[47:0] bfu_out_write_last_mux1h_nl;
  wire bfu_out_write_last_not_14_nl;
  wire[15:0] bfu_out_write_last_mux1h_1_nl;
  wire bfu_out_write_last_not_15_nl;
  wire[15:0] bfu_out_write_last_mux1h_2_nl;
  wire bfu_out_write_last_not_16_nl;
  wire bfu_out_write_last_not_17_nl;
  wire[47:0] bfu_out_write_last_mux1h_3_nl;
  wire bfu_out_write_last_not_18_nl;
  wire[2:0] bfu_out_write_last_bfu_out_write_last_nor_nl;
  wire[2:0] bfu_out_write_last_mux1h_4_nl;
  wire t_read_reset_check_ResetChecker_mux1h_1_nl;
  wire[2:0] bfu_out_write_last_mux1h_6_nl;
  wire bfu_out_write_last_not_22_nl;
  wire[31:0] inputUnit_inputUnit_mux1h_1_nl;
  wire bfu_out_write_last_not_23_nl;
  wire[123:0] bfu_out_write_last_mux1h_7_nl;
  wire bfu_out_write_last_not_24_nl;
  wire bfu_out_write_last_not_25_nl;
  wire[31:0] inputUnit_inputUnit_core_inputUnit_inputUnit_core_and_3_nl;
  wire[31:0] inputUnit_inputUnit_core_mux_20_nl;
  wire inputUnit_inputUnit_core_not_30_nl;
  wire[63:0] inputUnit_inputUnit_core_inputUnit_inputUnit_core_and_6_nl;
  wire[63:0] inputUnit_inputUnit_core_mux_27_nl;
  wire inputUnit_inputUnit_core_not_21_nl;
  wire[63:0] inputUnit_inputUnit_core_inputUnit_inputUnit_core_and_4_nl;
  wire[63:0] inputUnit_inputUnit_core_mux_21_nl;
  wire inputUnit_inputUnit_core_not_29_nl;
  wire[63:0] inputUnit_inputUnit_core_inputUnit_inputUnit_core_and_5_nl;
  wire[63:0] inputUnit_inputUnit_core_mux_26_nl;
  wire inputUnit_inputUnit_core_not_25_nl;
  wire[63:0] pkt_buf_out_write_pkt_buf_out_write_pkt_buf_out_write_mux1h_nl;
  wire inputUnit_inputUnit_core_not_32_nl;
  wire[63:0] pkt_buf_out_write_pkt_buf_out_write_pkt_buf_out_write_mux1h_2_nl;
  wire inputUnit_inputUnit_core_not_28_nl;
  wire[63:0] inputUnit_inputUnit_core_if_if_if_if_inputUnit_inputUnit_core_if_if_if_if_and_nl;
  wire inputUnit_inputUnit_core_if_if_if_if_nor_nl;
  wire or_164_nl;
  wire[63:0] inputUnit_inputUnit_core_if_if_inputUnit_inputUnit_core_if_if_mux1h_3_nl;
  wire inputUnit_inputUnit_core_not_31_nl;
  wire[63:0] inputUnit_inputUnit_core_if_if_if_if_if_if_if_if_inputUnit_inputUnit_core_if_if_if_if_if_if_if_if_and_nl;
  wire inputUnit_inputUnit_core_not_26_nl;
  wire inputUnit_inputUnit_core_if_if_and_16_nl;
  wire inputUnit_inputUnit_core_if_if_and_17_nl;
  wire[63:0] inputUnit_inputUnit_core_if_if_inputUnit_inputUnit_core_if_if_mux1h_1_nl;
  wire inputUnit_inputUnit_core_not_nl;
  wire[63:0] inputUnit_inputUnit_core_if_if_if_if_if_if_inputUnit_inputUnit_core_if_if_if_if_if_if_and_nl;
  wire inputUnit_inputUnit_core_if_if_if_if_if_if_nor_nl;
  wire inputUnit_inputUnit_core_if_mux_nl;
  wire t_read_reset_check_ResetChecker_t_read_reset_check_ResetChecker_and_nl;
  wire inputUnit_inputUnit_core_if_mux_7_nl;
  wire[1:0] inputUnit_inputUnit_core_and_12_nl;
  wire[1:0] inputUnit_inputUnit_core_if_if_inputUnit_inputUnit_core_if_if_inputUnit_inputUnit_core_if_if_or_1_nl;
  wire[1:0] inputUnit_inputUnit_core_if_if_mux_6_nl;
  wire inputUnit_inputUnit_core_if_if_or_1_nl;
  wire inputUnit_inputUnit_core_if_if_if_if_if_if_and_3_nl;
  wire inputUnit_inputUnit_core_if_if_if_if_mux_nl;
  wire inputUnit_inputUnit_core_if_if_mux_4_nl;
  wire inputUnit_inputUnit_core_if_if_mux_2_nl;
  wire inputUnit_inputUnit_core_if_if_nor_nl;
  wire[2:0] inputUnit_inputUnit_core_inputUnit_inputUnit_core_mux1h_1_nl;
  wire inputUnit_inputUnit_core_or_3_nl;
  wire inputUnit_inputUnit_core_or_4_nl;
  wire inputUnit_inputUnit_core_or_5_nl;
  wire inputUnit_inputUnit_core_if_if_if_if_if_if_and_1_nl;
  wire while_if_nor_nl;
  wire inputUnit_inputUnit_core_or_7_nl;
  wire inputUnit_inputUnit_core_and_19_nl;
  wire or_165_nl;
  wire[63:0] inputUnit_inputUnit_core_if_if_mux_nl;
  wire inputUnit_inputUnit_core_if_if_not_nl;
  wire inputUnit_inputUnit_core_if_if_if_if_mux_2_nl;
  wire or_168_nl;

  // Interconnect Declarations for Component Instantiations 
  wire [433:0] nl_inputUnit_inputUnit_main_bfu_out_t_Push_mioi_inst_bfu_out_t_Push_mioi_idat;
  assign nl_inputUnit_inputUnit_main_bfu_out_t_Push_mioi_inst_bfu_out_t_Push_mioi_idat
      = {bfu_out_t_Push_mioi_idat_433_370 , bfu_out_t_Push_mioi_idat_369_246 , bfu_out_t_Push_mioi_idat_245_243
      , bfu_out_t_Push_mioi_idat_242 , bfu_out_t_Push_mioi_idat_241 , 1'b0 , bfu_out_t_Push_mioi_idat_239_237
      , bfu_out_t_Push_mioi_idat_236 , 32'b00000000000000000000000000000000 , bfu_out_t_Push_mioi_idat_203_172
      , bfu_out_t_Push_mioi_idat_171_156 , bfu_out_t_Push_mioi_idat_155_108 , bfu_out_t_Push_mioi_idat_107_92
      , bfu_out_t_Push_mioi_idat_91_44 , 2'b00 , bfu_out_t_Push_mioi_idat_41_36 ,
      bfu_out_t_Push_mioi_idat_35_4 , bfu_out_t_Push_mioi_idat_3_0};
  wire [522:0] nl_inputUnit_inputUnit_main_pkt_buf_out_t_Push_mioi_inst_pkt_buf_out_t_Push_mioi_idat;
  assign nl_inputUnit_inputUnit_main_pkt_buf_out_t_Push_mioi_inst_pkt_buf_out_t_Push_mioi_idat
      = {pkt_buf_out_t_Push_mioi_idat_522 , pkt_buf_out_t_Push_mioi_idat_521_520
      , pkt_buf_out_t_Push_mioi_idat_519 , pkt_buf_out_t_Push_mioi_idat_518 , pkt_buf_out_t_Push_mioi_idat_517_500
      , pkt_buf_out_t_Push_mioi_idat_499_436 , pkt_buf_out_t_Push_mioi_idat_435_404
      , pkt_buf_out_t_Push_mioi_idat_403_372 , pkt_buf_out_t_Push_mioi_idat_371_308
      , pkt_buf_out_t_Push_mioi_idat_307_244 , pkt_buf_out_t_Push_mioi_idat_243_180
      , pkt_buf_out_t_Push_mioi_idat_179_116 , pkt_buf_out_t_Push_mioi_idat_115_52
      , pkt_buf_out_t_Push_mioi_idat_51_4 , pkt_buf_out_t_Push_mioi_idat_3_0};
  inputUnit_inputUnit_inputUnit_main_cmd_in_t_Pop_mioi inputUnit_inputUnit_main_cmd_in_t_Pop_mioi_inst
      (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .cmd_in_t_val(cmd_in_t_val),
      .cmd_in_t_rdy(cmd_in_t_rdy),
      .cmd_in_t_msg(cmd_in_t_msg),
      .cmd_in_t_Pop_mioi_oswt(cmd_in_read_mux_rmff),
      .cmd_in_t_Pop_mioi_iswt0(reg_cmd_in_t_Pop_mioi_iswt0_tmp),
      .cmd_in_t_Pop_mioi_wen_comp(cmd_in_t_Pop_mioi_wen_comp),
      .cmd_in_t_Pop_mioi_idat_mxwt(cmd_in_t_Pop_mioi_idat_mxwt),
      .cmd_in_t_Pop_mioi_iswt0_pff(cmd_in_read_mux_1_rmff)
    );
  inputUnit_inputUnit_inputUnit_main_wait_dp inputUnit_inputUnit_main_wait_dp_inst
      (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .bfu_out_t_Push_mioi_irdy(bfu_out_t_Push_mioi_irdy),
      .bfu_out_t_Push_mioi_irdy_oreg(bfu_out_t_Push_mioi_irdy_oreg),
      .stream_in_t_Pop_mioi_ivld(stream_in_t_Pop_mioi_ivld),
      .stream_in_t_Pop_mioi_ivld_oreg(stream_in_t_Pop_mioi_ivld_oreg),
      .pkt_buf_out_t_Push_mioi_irdy(pkt_buf_out_t_Push_mioi_irdy),
      .pkt_buf_out_t_Push_mioi_irdy_oreg(pkt_buf_out_t_Push_mioi_irdy_oreg)
    );
  inputUnit_inputUnit_inputUnit_main_bfu_out_t_Push_mioi inputUnit_inputUnit_main_bfu_out_t_Push_mioi_inst
      (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .bfu_out_t_val(bfu_out_t_val),
      .bfu_out_t_rdy(bfu_out_t_rdy),
      .bfu_out_t_msg(bfu_out_t_msg),
      .inputUnit_main_wen(inputUnit_main_wen),
      .bfu_out_t_Push_mioi_oswt(reg_bfu_out_t_Push_mioi_oswt_tmp),
      .bfu_out_t_Push_mioi_iswt0(reg_bfu_out_t_Push_mioi_iswt0_tmp),
      .bfu_out_t_Push_mioi_wen_comp(bfu_out_t_Push_mioi_wen_comp),
      .bfu_out_t_Push_mioi_idat(nl_inputUnit_inputUnit_main_bfu_out_t_Push_mioi_inst_bfu_out_t_Push_mioi_idat[433:0]),
      .bfu_out_t_Push_mioi_irdy(bfu_out_t_Push_mioi_irdy),
      .bfu_out_t_Push_mioi_irdy_oreg(bfu_out_t_Push_mioi_irdy_oreg),
      .bfu_out_t_Push_mioi_oswt_pff(bfu_out_write_last_mux_rmff),
      .bfu_out_t_Push_mioi_iswt0_pff(bfu_out_write_last_mux_1_rmff),
      .bfu_out_t_Push_mioi_irdy_oreg_pff(bfu_out_t_Push_mioi_irdy)
    );
  inputUnit_inputUnit_inputUnit_main_stream_in_t_Pop_mioi inputUnit_inputUnit_main_stream_in_t_Pop_mioi_inst
      (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .stream_in_t_val(stream_in_t_val),
      .stream_in_t_rdy(stream_in_t_rdy),
      .stream_in_t_msg(stream_in_t_msg),
      .inputUnit_main_wen(inputUnit_main_wen),
      .stream_in_t_Pop_mioi_oswt(reg_stream_in_t_Pop_mioi_oswt_tmp),
      .stream_in_t_Pop_mioi_iswt0(reg_stream_in_t_Pop_mioi_iswt0_tmp),
      .stream_in_t_Pop_mioi_wen_comp(stream_in_t_Pop_mioi_wen_comp),
      .stream_in_t_Pop_mioi_idat_mxwt(stream_in_t_Pop_mioi_idat_mxwt),
      .stream_in_t_Pop_mioi_ivld(stream_in_t_Pop_mioi_ivld),
      .stream_in_t_Pop_mioi_ivld_oreg(stream_in_t_Pop_mioi_ivld_oreg),
      .stream_in_t_Pop_mioi_oswt_pff(stream_in_read_mux_4_rmff),
      .stream_in_t_Pop_mioi_iswt0_pff(stream_in_read_mux_5_rmff),
      .stream_in_t_Pop_mioi_ivld_oreg_pff(stream_in_t_Pop_mioi_ivld)
    );
  inputUnit_inputUnit_inputUnit_main_pkt_buf_out_t_Push_mioi inputUnit_inputUnit_main_pkt_buf_out_t_Push_mioi_inst
      (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .pkt_buf_out_t_val(pkt_buf_out_t_val),
      .pkt_buf_out_t_rdy(pkt_buf_out_t_rdy),
      .pkt_buf_out_t_msg(pkt_buf_out_t_msg),
      .inputUnit_main_wen(inputUnit_main_wen),
      .pkt_buf_out_t_Push_mioi_oswt(reg_pkt_buf_out_t_Push_mioi_oswt_tmp),
      .pkt_buf_out_t_Push_mioi_iswt0(reg_pkt_buf_out_t_Push_mioi_iswt0_tmp),
      .pkt_buf_out_t_Push_mioi_wen_comp(pkt_buf_out_t_Push_mioi_wen_comp),
      .pkt_buf_out_t_Push_mioi_idat(nl_inputUnit_inputUnit_main_pkt_buf_out_t_Push_mioi_inst_pkt_buf_out_t_Push_mioi_idat[522:0]),
      .pkt_buf_out_t_Push_mioi_irdy(pkt_buf_out_t_Push_mioi_irdy),
      .pkt_buf_out_t_Push_mioi_irdy_oreg(pkt_buf_out_t_Push_mioi_irdy_oreg),
      .pkt_buf_out_t_Push_mioi_oswt_pff(pkt_buf_out_write_mux_rmff),
      .pkt_buf_out_t_Push_mioi_iswt0_pff(pkt_buf_out_write_mux_1_rmff),
      .pkt_buf_out_t_Push_mioi_irdy_oreg_pff(pkt_buf_out_t_Push_mioi_irdy)
    );
  inputUnit_inputUnit_inputUnit_main_staller inputUnit_inputUnit_main_staller_inst
      (
      .inputUnit_main_wen(inputUnit_main_wen_rtff),
      .cmd_in_t_Pop_mioi_wen_comp(cmd_in_t_Pop_mioi_wen_comp),
      .bfu_out_t_Push_mioi_wen_comp(bfu_out_t_Push_mioi_wen_comp),
      .stream_in_t_Pop_mioi_wen_comp(stream_in_t_Pop_mioi_wen_comp),
      .pkt_buf_out_t_Push_mioi_wen_comp(pkt_buf_out_t_Push_mioi_wen_comp)
    );
  inputUnit_inputUnit_inputUnit_main_inputUnit_main_fsm inputUnit_inputUnit_main_inputUnit_main_fsm_inst
      (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .inputUnit_main_wen(inputUnit_main_wen),
      .fsm_output(fsm_output),
      .while_C_4_tr0(or_dcpl_64),
      .inputUnit_inputUnit_core_while_C_0_tr0(and_dcpl_63)
    );
  assign cmd_in_read_mux_rmff = MUX_s_1_2_2(reg_cmd_in_t_Pop_mioi_oswt_tmp, (~ and_dcpl_64),
      inputUnit_main_wen);
  assign cmd_in_read_mux_1_rmff = MUX_s_1_2_2(reg_cmd_in_t_Pop_mioi_iswt0_tmp, (~
      and_dcpl_64), inputUnit_main_wen);
  assign bfu_out_write_last_mux_rmff = MUX_s_1_2_2(reg_bfu_out_t_Push_mioi_oswt_tmp,
      bfu_out_t_Push_mioi_oswt_mx0, inputUnit_main_wen);
  assign bfu_out_write_last_mux_1_rmff = MUX_s_1_2_2(reg_bfu_out_t_Push_mioi_iswt0_tmp,
      bfu_out_t_Push_mioi_oswt_mx0, inputUnit_main_wen);
  assign stream_in_read_mux_4_rmff = MUX_s_1_2_2(reg_stream_in_t_Pop_mioi_oswt_tmp,
      stream_in_t_Pop_mioi_oswt_mx0, inputUnit_main_wen);
  assign stream_in_read_mux_5_rmff = MUX_s_1_2_2(reg_stream_in_t_Pop_mioi_iswt0_tmp,
      stream_in_t_Pop_mioi_oswt_mx0, inputUnit_main_wen);
  assign pkt_buf_out_write_mux_rmff = MUX_s_1_2_2(reg_pkt_buf_out_t_Push_mioi_oswt_tmp,
      pkt_buf_out_write_or_itm, inputUnit_main_wen);
  assign pkt_buf_out_write_mux_1_rmff = MUX_s_1_2_2(reg_pkt_buf_out_t_Push_mioi_iswt0_tmp,
      pkt_buf_out_write_or_itm, inputUnit_main_wen);
  assign bfu_out_write_last_and_cse = inputUnit_main_wen & (and_189_cse | and_191_cse
      | inputUnit_inputUnit_core_and_20_cse | and_206_cse | or_tmp_61 | or_tmp_62);
  assign bfu_out_write_last_and_1_cse = inputUnit_main_wen & (or_tmp_64 | and_206_cse
      | or_tmp_61 | or_tmp_62);
  assign bfu_out_write_last_and_3_cse = inputUnit_main_wen & (or_tmp_76 | and_206_cse);
  assign bfu_out_write_last_and_5_ssc = inputUnit_main_wen & (and_189_cse | or_tmp_87
      | and_206_cse | or_tmp_61 | or_tmp_62);
  assign bfu_out_write_last_and_8_cse = inputUnit_main_wen & (or_tmp_102 | inputUnit_inputUnit_core_and_20_cse
      | and_206_cse | or_tmp_61 | or_tmp_62);
  assign pkt_buf_out_write_or_itm = (and_dcpl_50 & (fsm_output[4])) | and_198_cse;
  assign pkt_buf_out_write_and_cse = inputUnit_main_wen & pkt_buf_out_write_or_itm;
  assign pkt_buf_out_write_pkt_buf_out_write_nor_ssc = ~(inputUnit_inputUnit_core_if_unequal_tmp
      | inputUnit_inputUnit_core_unequal_tmp | and_198_cse);
  assign pkt_buf_out_write_and_13_ssc = inputUnit_inputUnit_core_unequal_tmp & (~
      and_198_cse);
  assign inputUnit_inputUnit_core_if_if_and_10_cse = inputUnit_main_wen & or_dcpl_18
      & (stream_in_read_slc_stream_in_t_Pop_mio_mrgout_dat_515_4_6_itm==8'b00000001)
      & (header_0_hdr0_set_bv_63_48_lpi_1_dfm_1==16'b1000100011110111) & (fsm_output[3]);
  assign and_597_cse = (cmd_in_t_Pop_mio_mrgout_dat_sva_9_0[9:4]==6'b111111);
  assign inputUnit_inputUnit_core_if_if_and_13_cse = inputUnit_main_wen & while_unequal_tmp
      & (~ inputUnit_inputUnit_core_or_2_psp) & (fsm_output[7]);
  assign inputUnit_inputUnit_core_if_and_cse = inputUnit_main_wen & (~ inputUnit_inputUnit_core_unequal_tmp)
      & while_unequal_tmp & (fsm_output[7]);
  assign cmd_in_read_and_cse = inputUnit_main_wen & (fsm_output[1]);
  assign stream_in_read_and_1_cse = inputUnit_main_wen & (~(or_dcpl_120 | (fsm_output[6:5]!=2'b00)));
  assign inputUnit_inputUnit_core_if_if_and_14_cse = inputUnit_main_wen & (~(or_dcpl_78
      | (fsm_output[7:6]!=2'b00)));
  assign or_164_nl = not_tmp_133 | or_dcpl_104 | (stream_in_read_slc_stream_in_t_Pop_mio_mrgout_dat_515_4_6_itm[5:2]!=4'b0000)
      | or_dcpl_99;
  assign inputUnit_inputUnit_core_if_if_if_if_if_if_if_if_mux_1_ssc = MUX_s_1_2_2(inputUnit_inputUnit_core_if_if_if_if_if_if_if_if_unequal_tmp_mx0w0,
      inputUnit_inputUnit_core_if_if_if_if_if_if_if_if_unequal_tmp, or_164_nl);
  assign inputUnit_inputUnit_core_if_if_if_if_and_11_ssc = inputUnit_inputUnit_core_if_if_if_if_if_if_and_ssc_3
      & inputUnit_inputUnit_core_if_if_if_if_and_3_m1c_1 & inputUnit_inputUnit_core_if_if_and_4_ssc_mx0w1;
  assign inputUnit_inputUnit_core_if_if_if_if_and_12_ssc = inputUnit_inputUnit_core_if_if_if_if_if_if_and_6_ssc_1
      & inputUnit_inputUnit_core_if_if_if_if_and_3_m1c_1 & inputUnit_inputUnit_core_if_if_and_4_ssc_mx0w1;
  assign inputUnit_inputUnit_core_if_if_and_9_ssc = inputUnit_inputUnit_core_if_if_if_if_and_3_m1c_1
      & inputUnit_inputUnit_core_if_if_and_4_ssc_mx0w1;
  assign inputUnit_inputUnit_core_hdr_count_and_cse = inputUnit_main_wen & (~(or_dcpl_78
      | (fsm_output[6])));
  assign inputUnit_inputUnit_core_and_20_cse = and_dcpl_63 & (fsm_output[6]);
  assign cmd_in_read_and_1_cse = inputUnit_main_wen & (~ (fsm_output[8]));
  assign bfu_out_t_Push_mioi_oswt_mx0 = and_187_cse | and_189_cse | inputUnit_inputUnit_core_and_20_cse
      | and_191_cse;
  assign stream_in_t_Pop_mioi_oswt_mx0 = (or_dcpl_18 & (~(inputUnit_inputUnit_core_inputUnit_inputUnit_core_and_1_itm
      | inputUnit_inputUnit_core_and_ssc_1)) & (fsm_output[5])) | (((cmd_in_t_Pop_mioi_idat_mxwt[9:4]!=6'b111111))
      & (fsm_output[1])) | ((~((stream_in_t_Pop_mioi_idat_mxwt[522]) & inputUnit_inputUnit_core_while_stage_0_1))
      & (~ inputUnit_inputUnit_core_and_ssc_1) & inputUnit_inputUnit_core_if_unequal_tmp
      & (fsm_output[6])) | (or_dcpl_18 & (stream_in_t_Pop_mioi_idat_mxwt[100]) &
      (stream_in_t_Pop_mioi_idat_mxwt[101]) & (stream_in_t_Pop_mioi_idat_mxwt[102])
      & (~ (stream_in_t_Pop_mioi_idat_mxwt[103])) & (stream_in_t_Pop_mioi_idat_mxwt[104])
      & (stream_in_t_Pop_mioi_idat_mxwt[105]) & (stream_in_t_Pop_mioi_idat_mxwt[106])
      & (stream_in_t_Pop_mioi_idat_mxwt[107]) & (~ (stream_in_t_Pop_mioi_idat_mxwt[108]))
      & (~((stream_in_t_Pop_mioi_idat_mxwt[110:109]!=2'b00))) & (~((stream_in_t_Pop_mioi_idat_mxwt[113:112]!=2'b00)))
      & (~ (stream_in_t_Pop_mioi_idat_mxwt[114])) & (stream_in_t_Pop_mioi_idat_mxwt[115])
      & (stream_in_t_Pop_mioi_idat_mxwt[111]) & (stream_in_t_Pop_mioi_idat_mxwt[156])
      & (~((stream_in_t_Pop_mioi_idat_mxwt[158:157]!=2'b00))) & (~((stream_in_t_Pop_mioi_idat_mxwt[160:159]!=2'b00)))
      & (~((stream_in_t_Pop_mioi_idat_mxwt[163:161]!=3'b000))) & (fsm_output[2]));
  assign inputUnit_inputUnit_core_if_if_if_if_and_9_mx0w1 = (~ inputUnit_inputUnit_core_if_if_if_if_if_if_unequal_tmp_1)
      & inputUnit_inputUnit_core_if_if_if_if_and_3_m1c_1 & inputUnit_inputUnit_core_if_if_and_4_ssc_mx0w1;
  assign inputUnit_inputUnit_core_if_if_if_if_if_if_and_2_ssc_mx0w1 = (~ inputUnit_inputUnit_core_if_if_if_if_if_if_if_unequal_tmp_1)
      & inputUnit_inputUnit_core_if_if_if_if_if_if_unequal_tmp_1 & inputUnit_inputUnit_core_if_if_if_if_and_3_m1c_1
      & inputUnit_inputUnit_core_if_if_and_4_ssc_mx0w1;
  assign inputUnit_inputUnit_core_if_if_and_4_ssc_mx0w1 = inputUnit_inputUnit_core_if_if_if_unequal_tmp_1
      & inputUnit_inputUnit_core_if_if_unequal_tmp;
  assign inputUnit_inputUnit_core_if_if_if_if_if_if_if_if_unequal_tmp_mx0w0 = (stream_in_t_Pop_mioi_idat_mxwt[355:340]!=16'b0000000000000000);
  assign or_165_nl = not_tmp_133 | or_dcpl_108;
  assign inputUnit_inputUnit_core_if_if_if_if_if_if_if_if_unequal_tmp_mx2 = MUX_s_1_2_2(inputUnit_inputUnit_core_if_if_if_if_if_if_if_if_unequal_tmp_mx0w0,
      inputUnit_inputUnit_core_if_if_if_if_if_if_if_if_unequal_tmp, or_165_nl);
  assign inputUnit_inputUnit_core_if_if_if_if_if_if_and_ssc_3 = (~ inputUnit_inputUnit_core_if_if_if_if_if_if_if_unequal_tmp_1)
      & inputUnit_inputUnit_core_if_if_if_if_if_if_unequal_tmp_1;
  assign inputUnit_inputUnit_core_if_if_if_if_if_if_and_6_ssc_1 = inputUnit_inputUnit_core_if_if_if_if_if_if_if_unequal_tmp_1
      & inputUnit_inputUnit_core_if_if_if_if_if_if_unequal_tmp_1;
  assign inputUnit_inputUnit_core_if_if_if_if_and_ssc_mx0w0 = (~ inputUnit_inputUnit_core_if_if_if_if_if_unequal_tmp_1)
      & inputUnit_inputUnit_core_if_if_if_if_unequal_tmp_1;
  assign inputUnit_inputUnit_core_inputUnit_inputUnit_core_nand_tmp = ~((stream_in_t_Pop_mioi_idat_mxwt[115:100]==16'b1000100011110111));
  assign inputUnit_inputUnit_core_else_if_nor_tmp = ~((stream_in_t_Pop_mioi_idat_mxwt[115])
      | (stream_in_t_Pop_mioi_idat_mxwt[114]) | (stream_in_t_Pop_mioi_idat_mxwt[113])
      | (stream_in_t_Pop_mioi_idat_mxwt[112]) | (stream_in_t_Pop_mioi_idat_mxwt[110])
      | (stream_in_t_Pop_mioi_idat_mxwt[109]) | (stream_in_t_Pop_mioi_idat_mxwt[108])
      | (stream_in_t_Pop_mioi_idat_mxwt[107]) | (stream_in_t_Pop_mioi_idat_mxwt[106])
      | (stream_in_t_Pop_mioi_idat_mxwt[105]) | (stream_in_t_Pop_mioi_idat_mxwt[104])
      | (stream_in_t_Pop_mioi_idat_mxwt[103]) | (stream_in_t_Pop_mioi_idat_mxwt[102])
      | (stream_in_t_Pop_mioi_idat_mxwt[101]) | (stream_in_t_Pop_mioi_idat_mxwt[100]));
  assign inputUnit_inputUnit_core_if_unequal_tmp_1 = ~((stream_in_t_Pop_mio_mrgout_dat_sva_515_4[159:152]==8'b00000001));
  assign inputUnit_inputUnit_core_and_tmp_1 = inputUnit_inputUnit_core_if_unequal_tmp_1
      & (~ inputUnit_inputUnit_core_unequal_tmp);
  assign inputUnit_inputUnit_core_if_if_if_if_if_if_if_unequal_tmp_1 = (stream_in_t_Pop_mioi_idat_mxwt[291:276]!=16'b0000000000000000);
  assign inputUnit_inputUnit_core_if_if_if_if_if_if_unequal_tmp_1 = (stream_in_t_Pop_mioi_idat_mxwt[227:212]!=16'b0000000000000000);
  assign inputUnit_inputUnit_core_if_if_if_if_if_unequal_tmp_1 = (stream_in_t_Pop_mioi_idat_mxwt[163:148]!=16'b0000000000000000);
  assign inputUnit_inputUnit_core_if_if_if_if_and_3_m1c_1 = inputUnit_inputUnit_core_if_if_if_if_if_unequal_tmp_1
      & inputUnit_inputUnit_core_if_if_if_if_unequal_tmp_1;
  assign inputUnit_inputUnit_core_if_if_if_if_unequal_tmp_1 = (stream_in_t_Pop_mioi_idat_mxwt[99:84]!=16'b0000000000000000);
  assign inputUnit_inputUnit_core_if_if_if_unequal_tmp_1 = (stream_in_t_Pop_mioi_idat_mxwt[35:20]!=16'b0000000000000000);
  assign inputUnit_inputUnit_core_if_if_mux_nl = MUX_v_64_2_2((stream_in_t_Pop_mioi_idat_mxwt[451:388]),
      (stream_in_t_Pop_mioi_idat_mxwt[515:452]), inputUnit_inputUnit_core_if_if_and_3_ssc_1);
  assign inputUnit_inputUnit_core_if_if_not_nl = ~ inputUnit_inputUnit_core_if_if_and_4_ssc_mx0w1;
  assign inputUnit_inputUnit_core_pkt_data_buf_495_0_lpi_1_dfm_6_431_368 = MUX_v_64_2_2(64'b0000000000000000000000000000000000000000000000000000000000000000,
      inputUnit_inputUnit_core_if_if_mux_nl, inputUnit_inputUnit_core_if_if_not_nl);
  assign inputUnit_inputUnit_core_if_if_and_3_ssc_1 = (~ inputUnit_inputUnit_core_if_if_if_unequal_tmp_1)
      & inputUnit_inputUnit_core_if_if_unequal_tmp;
  assign inputUnit_inputUnit_core_inputUnit_inputUnit_core_nor_1_ssc_1 = ~(inputUnit_inputUnit_core_if_if_unequal_tmp
      | inputUnit_inputUnit_core_and_tmp_1);
  assign inputUnit_inputUnit_core_if_if_and_ssc_1 = (~ inputUnit_inputUnit_core_if_if_if_unequal_tmp_1)
      & inputUnit_inputUnit_core_if_if_unequal_tmp & (~ inputUnit_inputUnit_core_and_tmp_1);
  assign inputUnit_inputUnit_core_and_ssc_2 = (~ inputUnit_inputUnit_core_if_if_if_if_unequal_tmp_1)
      & inputUnit_inputUnit_core_if_if_and_1_m1c_1;
  assign inputUnit_inputUnit_core_if_if_if_if_and_ssc_3 = (~ inputUnit_inputUnit_core_if_if_if_if_if_unequal_tmp_1)
      & inputUnit_inputUnit_core_if_if_if_if_unequal_tmp_1 & inputUnit_inputUnit_core_if_if_and_1_m1c_1;
  assign inputUnit_inputUnit_core_if_if_if_if_and_4_ssc_1 = (~ inputUnit_inputUnit_core_if_if_if_if_if_if_unequal_tmp_1)
      & inputUnit_inputUnit_core_if_if_if_if_and_3_m1c_1 & inputUnit_inputUnit_core_if_if_and_1_m1c_1;
  assign inputUnit_inputUnit_core_if_if_if_if_if_if_and_ssc_4 = (~ inputUnit_inputUnit_core_if_if_if_if_if_if_if_unequal_tmp_1)
      & inputUnit_inputUnit_core_if_if_if_if_if_if_unequal_tmp_1 & inputUnit_inputUnit_core_if_if_if_if_and_3_m1c_1
      & inputUnit_inputUnit_core_if_if_and_1_m1c_1;
  assign inputUnit_inputUnit_core_if_if_and_1_m1c_1 = inputUnit_inputUnit_core_if_if_if_unequal_tmp_1
      & inputUnit_inputUnit_core_if_if_unequal_tmp & (~ inputUnit_inputUnit_core_and_tmp_1);
  assign inputUnit_inputUnit_core_nor_seb_1 = ~(inputUnit_inputUnit_core_and_tmp_1
      | inputUnit_inputUnit_core_unequal_tmp);
  assign inputUnit_inputUnit_core_if_if_asn_11 = (~ inputUnit_inputUnit_core_if_if_if_if_unequal_tmp_1)
      & inputUnit_inputUnit_core_if_if_and_4_ssc_mx0w1;
  assign or_168_nl = (~ and_tmp_7) | or_dcpl_108;
  assign inputUnit_inputUnit_core_if_if_if_if_mux_2_nl = MUX_s_1_2_2(inputUnit_inputUnit_core_if_if_if_if_and_ssc_mx0w0,
      inputUnit_inputUnit_core_if_if_if_if_and_ssc, or_168_nl);
  assign inputUnit_inputUnit_core_if_if_asn_13 = inputUnit_inputUnit_core_if_if_if_if_mux_2_nl
      & inputUnit_inputUnit_core_if_if_and_4_ssc_mx0w1;
  assign nor_tmp_1 = while_if_nor_1_itm & (cmd_in_t_Pop_mio_mrgout_dat_sva_78_15[32]);
  assign or_dcpl_18 = (cmd_in_t_Pop_mio_mrgout_dat_sva_9_0[9:4]!=6'b111111);
  assign and_dcpl_50 = or_dcpl_18 & (~ inputUnit_inputUnit_core_inputUnit_inputUnit_core_and_1_itm);
  assign or_dcpl_64 = and_597_cse | inputUnit_inputUnit_core_inputUnit_inputUnit_core_and_1_itm;
  assign and_dcpl_63 = ~(inputUnit_inputUnit_core_while_stage_0_1 | inputUnit_inputUnit_core_if_unequal_tmp);
  assign and_dcpl_64 = ~((fsm_output[0]) | (fsm_output[10]));
  assign or_dcpl_70 = (fsm_output[9:8]!=2'b00);
  assign or_dcpl_78 = (fsm_output[5:4]!=2'b00);
  assign or_dcpl_99 = (stream_in_read_slc_stream_in_t_Pop_mio_mrgout_dat_515_4_6_itm[1:0]!=2'b01);
  assign or_dcpl_104 = (stream_in_read_slc_stream_in_t_Pop_mio_mrgout_dat_515_4_6_itm[7:6]!=2'b00);
  assign or_dcpl_108 = or_dcpl_104 | (stream_in_read_slc_stream_in_t_Pop_mio_mrgout_dat_515_4_6_itm[5:2]!=4'b0000)
      | or_dcpl_99 | (header_0_hdr0_set_bv_63_48_lpi_1_dfm_1!=16'b1000100011110111);
  assign and_tmp_7 = inputUnit_inputUnit_core_if_if_if_unequal_tmp_1 & ((stream_in_read_slc_stream_in_t_Pop_mio_mrgout_dat_515_4_7_itm!=16'b0000000000000000));
  assign not_tmp_133 = ~(inputUnit_inputUnit_core_if_if_if_if_unequal_tmp_1 & inputUnit_inputUnit_core_if_if_if_if_if_if_unequal_tmp_1
      & inputUnit_inputUnit_core_if_if_if_if_if_if_if_unequal_tmp_1 & inputUnit_inputUnit_core_if_if_if_if_if_unequal_tmp_1
      & and_tmp_7);
  assign or_dcpl_120 = (fsm_output[4:3]!=2'b00);
  assign mux_tmp_15 = (stream_in_t_Pop_mio_mrgout_dat_sva_515_4[159:152]!=8'b00000001);
  assign and_189_cse = (cmd_in_t_Pop_mioi_idat_mxwt[9:4]==6'b111111) & (fsm_output[1]);
  assign and_191_cse = (~(and_597_cse | (~((~ (stream_in_t_Pop_mioi_idat_mxwt[115]))
      | (stream_in_t_Pop_mioi_idat_mxwt[114]) | (stream_in_t_Pop_mioi_idat_mxwt[113])
      | (stream_in_t_Pop_mioi_idat_mxwt[112]) | (stream_in_t_Pop_mioi_idat_mxwt[110])
      | (stream_in_t_Pop_mioi_idat_mxwt[109]) | (stream_in_t_Pop_mioi_idat_mxwt[108])
      | (~ (stream_in_t_Pop_mioi_idat_mxwt[107])) | (~ (stream_in_t_Pop_mioi_idat_mxwt[106]))
      | (~ (stream_in_t_Pop_mioi_idat_mxwt[105])) | (~ (stream_in_t_Pop_mioi_idat_mxwt[104]))
      | (stream_in_t_Pop_mioi_idat_mxwt[103]) | (~((stream_in_t_Pop_mioi_idat_mxwt[102:100]==3'b111)))))))
      & (stream_in_t_Pop_mioi_idat_mxwt[111]) & inputUnit_inputUnit_core_else_if_nor_tmp
      & (fsm_output[2]);
  assign and_187_cse = and_dcpl_50 & (or_dcpl_70 | (fsm_output[7]));
  assign and_198_cse = inputUnit_inputUnit_core_while_stage_0_1 & (~ inputUnit_inputUnit_core_and_ssc_1)
      & (fsm_output[6]);
  assign and_206_cse = and_dcpl_50 & (fsm_output[7]);
  assign or_tmp_61 = and_dcpl_50 & (fsm_output[8]);
  assign or_tmp_62 = and_dcpl_50 & (fsm_output[9]);
  assign or_tmp_64 = and_189_cse | inputUnit_inputUnit_core_and_20_cse | and_191_cse;
  assign and_250_cse = and_dcpl_50 & or_dcpl_70;
  assign or_tmp_76 = and_250_cse | and_189_cse | inputUnit_inputUnit_core_and_20_cse
      | and_191_cse;
  assign or_tmp_87 = inputUnit_inputUnit_core_and_20_cse | and_191_cse;
  assign or_tmp_102 = and_189_cse | and_191_cse;
  assign or_tmp_186 = (mux_tmp_15 | inputUnit_inputUnit_core_unequal_tmp) & (fsm_output[3]);
  assign or_tmp_187 = (~(mux_tmp_15 | inputUnit_inputUnit_core_unequal_tmp)) & (fsm_output[3]);
  assign bfu_out_t_Push_mioi_idat_241_mx0c0 = and_187_cse | and_189_cse;
  assign bfu_out_t_Push_mioi_idat_35_4_mx0c2 = and_206_cse | inputUnit_inputUnit_core_and_20_cse;
  assign bfu_out_t_Push_mioi_idat_3_0_mx0c1 = and_206_cse | inputUnit_inputUnit_core_and_20_cse
      | and_191_cse;
  assign inputUnit_inputUnit_core_and_ssc_1_mx0c2 = or_dcpl_64 & (fsm_output[5]);
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      reg_cmd_in_t_Pop_mioi_oswt_tmp <= 1'b0;
      reg_cmd_in_t_Pop_mioi_iswt0_tmp <= 1'b0;
      reg_bfu_out_t_Push_mioi_oswt_tmp <= 1'b0;
      reg_bfu_out_t_Push_mioi_iswt0_tmp <= 1'b0;
      reg_stream_in_t_Pop_mioi_oswt_tmp <= 1'b0;
      reg_stream_in_t_Pop_mioi_iswt0_tmp <= 1'b0;
      reg_pkt_buf_out_t_Push_mioi_oswt_tmp <= 1'b0;
      reg_pkt_buf_out_t_Push_mioi_iswt0_tmp <= 1'b0;
      inputUnit_main_wen <= 1'b1;
    end
    else begin
      reg_cmd_in_t_Pop_mioi_oswt_tmp <= cmd_in_read_mux_rmff;
      reg_cmd_in_t_Pop_mioi_iswt0_tmp <= cmd_in_read_mux_1_rmff;
      reg_bfu_out_t_Push_mioi_oswt_tmp <= bfu_out_write_last_mux_rmff;
      reg_bfu_out_t_Push_mioi_iswt0_tmp <= bfu_out_write_last_mux_1_rmff;
      reg_stream_in_t_Pop_mioi_oswt_tmp <= stream_in_read_mux_4_rmff;
      reg_stream_in_t_Pop_mioi_iswt0_tmp <= stream_in_read_mux_5_rmff;
      reg_pkt_buf_out_t_Push_mioi_oswt_tmp <= pkt_buf_out_write_mux_rmff;
      reg_pkt_buf_out_t_Push_mioi_iswt0_tmp <= pkt_buf_out_write_mux_1_rmff;
      inputUnit_main_wen <= inputUnit_main_wen_rtff;
    end
  end
  always @(posedge i_clk) begin
    if ( bfu_out_write_last_and_cse ) begin
      bfu_out_t_Push_mioi_idat_155_108 <= MUX_v_48_2_2(48'b000000000000000000000000000000000000000000000000,
          bfu_out_write_last_mux1h_nl, bfu_out_write_last_not_14_nl);
      bfu_out_t_Push_mioi_idat_107_92 <= MUX_v_16_2_2(16'b0000000000000000, bfu_out_write_last_mux1h_2_nl,
          bfu_out_write_last_not_16_nl);
      bfu_out_t_Push_mioi_idat_91_44 <= MUX_v_48_2_2(48'b000000000000000000000000000000000000000000000000,
          bfu_out_write_last_mux1h_3_nl, bfu_out_write_last_not_18_nl);
      bfu_out_t_Push_mioi_idat_41_36 <= MUX1HOT_v_6_6_2(6'b000001, 6'b001111, 6'b001100,
          6'b010100, 6'b100100, 6'b110101, {and_189_cse , and_191_cse , inputUnit_inputUnit_core_and_20_cse
          , and_206_cse , or_tmp_61 , or_tmp_62});
    end
  end
  always @(posedge i_clk) begin
    if ( bfu_out_write_last_and_1_cse ) begin
      bfu_out_t_Push_mioi_idat_171_156 <= MUX_v_16_2_2(16'b0000000000000000, bfu_out_write_last_mux1h_1_nl,
          bfu_out_write_last_not_15_nl);
      bfu_out_t_Push_mioi_idat_369_246 <= MUX_v_124_2_2(124'b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,
          bfu_out_write_last_mux1h_7_nl, bfu_out_write_last_not_24_nl);
    end
  end
  always @(posedge i_clk) begin
    if ( bfu_out_write_last_and_3_cse ) begin
      bfu_out_t_Push_mioi_idat_203_172 <= MUX_v_32_2_2(32'b00000000000000000000000000000000,
          (ptp_l_set_bv_lpi_1_dfm[159:128]), bfu_out_write_last_not_17_nl);
      bfu_out_t_Push_mioi_idat_433_370 <= MUX_v_64_2_2(64'b0000000000000000000000000000000000000000000000000000000000000000,
          (ptp_h_set_bv_lpi_1_dfm[191:128]), bfu_out_write_last_not_25_nl);
    end
  end
  always @(posedge i_clk) begin
    if ( bfu_out_write_last_and_5_ssc ) begin
      bfu_out_t_Push_mioi_idat_239_237 <= MUX_v_3_2_2(bfu_out_write_last_bfu_out_write_last_nor_nl,
          3'b111, or_tmp_62);
      bfu_out_t_Push_mioi_idat_236 <= ~ and_189_cse;
    end
  end
  always @(posedge i_clk) begin
    if ( inputUnit_main_wen & (bfu_out_t_Push_mioi_idat_241_mx0c0 | or_tmp_87) )
        begin
      bfu_out_t_Push_mioi_idat_241 <= ~ bfu_out_t_Push_mioi_idat_241_mx0c0;
    end
  end
  always @(posedge i_clk) begin
    if ( bfu_out_write_last_and_8_cse ) begin
      bfu_out_t_Push_mioi_idat_242 <= t_read_reset_check_ResetChecker_mux1h_1_nl
          & (~ or_tmp_102);
      bfu_out_t_Push_mioi_idat_245_243 <= MUX_v_3_2_2(3'b000, bfu_out_write_last_mux1h_6_nl,
          bfu_out_write_last_not_22_nl);
    end
  end
  always @(posedge i_clk) begin
    if ( inputUnit_main_wen & (and_189_cse | and_191_cse | bfu_out_t_Push_mioi_idat_35_4_mx0c2
        | and_250_cse) ) begin
      bfu_out_t_Push_mioi_idat_35_4 <= MUX_v_32_2_2(32'b00000000000000000000000000000000,
          inputUnit_inputUnit_mux1h_1_nl, bfu_out_write_last_not_23_nl);
    end
  end
  always @(posedge i_clk) begin
    if ( inputUnit_main_wen & (and_189_cse | bfu_out_t_Push_mioi_idat_3_0_mx0c1 |
        and_250_cse) ) begin
      bfu_out_t_Push_mioi_idat_3_0 <= MUX1HOT_v_4_3_2((cmd_in_t_Pop_mioi_idat_mxwt[3:0]),
          (cmd_in_t_Pop_mio_mrgout_dat_sva_9_0[3:0]), cmd_in_read_slc_cmd_in_t_Pop_mio_mrgout_dat_3_0_itm,
          {and_189_cse , bfu_out_t_Push_mioi_idat_3_0_mx0c1 , and_250_cse});
    end
  end
  always @(posedge i_clk) begin
    if ( pkt_buf_out_write_and_cse ) begin
      pkt_buf_out_t_Push_mioi_idat_517_500 <= MUX_v_18_2_2(18'b100000000000000000,
          (stream_in_t_Pop_mioi_idat_mxwt[517:500]), and_198_cse);
      pkt_buf_out_t_Push_mioi_idat_403_372 <= MUX_v_32_2_2(inputUnit_inputUnit_core_inputUnit_inputUnit_core_and_3_nl,
          (stream_in_t_Pop_mioi_idat_mxwt[403:372]), and_198_cse);
      pkt_buf_out_t_Push_mioi_idat_371_308 <= MUX_v_64_2_2(inputUnit_inputUnit_core_inputUnit_inputUnit_core_and_6_nl,
          (stream_in_t_Pop_mioi_idat_mxwt[371:308]), and_198_cse);
      pkt_buf_out_t_Push_mioi_idat_307_244 <= MUX_v_64_2_2(inputUnit_inputUnit_core_inputUnit_inputUnit_core_and_4_nl,
          (stream_in_t_Pop_mioi_idat_mxwt[307:244]), and_198_cse);
      pkt_buf_out_t_Push_mioi_idat_243_180 <= MUX_v_64_2_2(inputUnit_inputUnit_core_inputUnit_inputUnit_core_and_5_nl,
          (stream_in_t_Pop_mioi_idat_mxwt[243:180]), and_198_cse);
      pkt_buf_out_t_Push_mioi_idat_435_404 <= MUX_v_32_2_2(inputUnit_inputUnit_core_and_6_itm_31_0,
          (stream_in_t_Pop_mioi_idat_mxwt[435:404]), and_198_cse);
      pkt_buf_out_t_Push_mioi_idat_179_116 <= MUX_v_64_2_2(64'b0000000000000000000000000000000000000000000000000000000000000000,
          pkt_buf_out_write_pkt_buf_out_write_pkt_buf_out_write_mux1h_nl, inputUnit_inputUnit_core_not_32_nl);
      pkt_buf_out_t_Push_mioi_idat_115_52 <= MUX_v_64_2_2(64'b0000000000000000000000000000000000000000000000000000000000000000,
          pkt_buf_out_write_pkt_buf_out_write_pkt_buf_out_write_mux1h_2_nl, inputUnit_inputUnit_core_not_28_nl);
      pkt_buf_out_t_Push_mioi_idat_51_4 <= MUX1HOT_v_48_4_2(inputUnit_inputUnit_core_slc_inputUnit_inputUnit_core_pkt_data_buf_495_0_lpi_1_dfm_6_399_0_itm_47_0,
          (stream_in_t_Pop_mio_mrgout_dat_sva_515_4[511:464]), (stream_in_t_Pop_mio_mrgout_dat_sva_515_4[159:112]),
          (stream_in_t_Pop_mioi_idat_mxwt[51:4]), {pkt_buf_out_write_pkt_buf_out_write_nor_ssc
          , inputUnit_inputUnit_core_and_ssc_1 , pkt_buf_out_write_and_13_ssc , and_198_cse});
      pkt_buf_out_t_Push_mioi_idat_499_436 <= MUX_v_64_2_2(inputUnit_inputUnit_core_and_6_itm_95_32,
          (stream_in_t_Pop_mioi_idat_mxwt[499:436]), and_198_cse);
      pkt_buf_out_t_Push_mioi_idat_519 <= MUX_s_1_2_2(inputUnit_inputUnit_core_pkt_empty_5_2_lpi_1_dfm_8_1,
          (stream_in_t_Pop_mioi_idat_mxwt[519]), and_198_cse);
      pkt_buf_out_t_Push_mioi_idat_518 <= MUX_s_1_2_2(inputUnit_inputUnit_core_unequal_tmp,
          (stream_in_t_Pop_mioi_idat_mxwt[518]), and_198_cse);
      pkt_buf_out_t_Push_mioi_idat_521_520 <= MUX_v_2_2_2(inputUnit_inputUnit_core_pkt_empty_5_2_lpi_1_dfm_8_3_2,
          (stream_in_t_Pop_mioi_idat_mxwt[521:520]), and_198_cse);
      pkt_buf_out_t_Push_mioi_idat_3_0 <= MUX_v_4_2_2(cmd_in_read_slc_cmd_in_t_Pop_mio_mrgout_dat_3_0_itm,
          (stream_in_t_Pop_mioi_idat_mxwt[3:0]), and_198_cse);
      pkt_buf_out_t_Push_mioi_idat_522 <= MUX_s_1_2_2(inputUnit_inputUnit_core_mux_itm,
          (stream_in_t_Pop_mioi_idat_mxwt[522]), and_198_cse);
    end
  end
  always @(posedge i_clk) begin
    if ( inputUnit_inputUnit_core_if_if_and_10_cse ) begin
      inputUnit_inputUnit_core_if_if_if_if_and_5_ssc <= inputUnit_inputUnit_core_if_if_if_if_and_9_mx0w1;
      inputUnit_inputUnit_core_if_if_if_if_if_if_and_2_ssc <= inputUnit_inputUnit_core_if_if_if_if_if_if_and_2_ssc_mx0w1;
    end
  end
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      inputUnit_inputUnit_core_if_if_and_2_tmp <= 1'b0;
    end
    else if ( inputUnit_inputUnit_core_if_if_and_10_cse ) begin
      inputUnit_inputUnit_core_if_if_and_2_tmp <= inputUnit_inputUnit_core_if_if_and_4_ssc_mx0w1;
    end
  end
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      inputUnit_inputUnit_core_if_if_if_if_if_if_if_if_unequal_tmp <= 1'b0;
    end
    else if ( inputUnit_main_wen & (~((~ (fsm_output[3])) | and_597_cse | not_tmp_133
        | or_dcpl_108)) ) begin
      inputUnit_inputUnit_core_if_if_if_if_if_if_if_if_unequal_tmp <= inputUnit_inputUnit_core_if_if_if_if_if_if_if_if_unequal_tmp_mx0w0;
    end
  end
  always @(posedge i_clk) begin
    if ( inputUnit_inputUnit_core_if_if_and_13_cse ) begin
      header_0_hdr0_set_bv_63_48_lpi_1 <= reg_stream_in_t_Pop_1mio_mrgout_dat_ftd_55[15:0];
      inputUnit_inputUnit_core_payload_data_3_463_16_lpi_1 <= reg_stream_in_t_Pop_1mio_mrgout_dat_ftd_55[463:16];
    end
  end
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      bt0_sva <= 32'b00000000000000000000000000000000;
    end
    else if ( inputUnit_main_wen & (~(nor_tmp_1 | while_unequal_tmp | inputUnit_inputUnit_core_and_ssc_1))
        & (fsm_output[7]) ) begin
      bt0_sva <= cmd_in_t_Pop_mio_mrgout_dat_sva_78_15[31:0];
    end
  end
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      inputUnit_inputUnit_core_if_if_if_if_and_ssc <= 1'b0;
    end
    else if ( inputUnit_main_wen & (~((~ (fsm_output[3])) | (~((~((cmd_in_t_Pop_mio_mrgout_dat_sva_9_0[9:4]==6'b111111)))
        & and_tmp_7)) | or_dcpl_108)) ) begin
      inputUnit_inputUnit_core_if_if_if_if_and_ssc <= inputUnit_inputUnit_core_if_if_if_if_and_ssc_mx0w0;
    end
  end
  always @(posedge i_clk) begin
    if ( inputUnit_inputUnit_core_if_and_cse ) begin
      ptp_l_set_bv_lpi_1 <= stream_in_t_Pop_mio_mrgout_dat_sva_515_4[271:112];
      ptp_h_set_bv_lpi_1 <= stream_in_t_Pop_mio_mrgout_dat_sva_515_4[463:272];
    end
  end
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      bt1_sva <= 32'b00000000000000000000000000000000;
    end
    else if ( inputUnit_main_wen & nor_tmp_1 & (~ while_unequal_tmp) & (fsm_output[7])
        ) begin
      bt1_sva <= cmd_in_t_Pop_mio_mrgout_dat_sva_78_15[31:0];
    end
  end
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      inputUnit_inputUnit_core_or_2_psp <= 1'b0;
    end
    else if ( inputUnit_main_wen & or_dcpl_18 & (fsm_output[3]) ) begin
      inputUnit_inputUnit_core_or_2_psp <= inputUnit_inputUnit_core_if_unequal_tmp_1
          | inputUnit_inputUnit_core_unequal_tmp;
    end
  end
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      cmd_in_t_Pop_mio_mrgout_dat_sva_78_15 <= 64'b0000000000000000000000000000000000000000000000000000000000000000;
      cmd_in_t_Pop_mio_mrgout_dat_sva_9_0 <= 10'b0000000000;
      while_unequal_tmp <= 1'b0;
    end
    else if ( cmd_in_read_and_cse ) begin
      cmd_in_t_Pop_mio_mrgout_dat_sva_78_15 <= cmd_in_t_Pop_mioi_idat_mxwt[73:10];
      cmd_in_t_Pop_mio_mrgout_dat_sva_9_0 <= cmd_in_t_Pop_mioi_idat_mxwt[9:0];
      while_unequal_tmp <= ~((cmd_in_t_Pop_mioi_idat_mxwt[9:4]==6'b111111));
    end
  end
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      while_if_nor_1_itm <= 1'b0;
    end
    else if ( inputUnit_main_wen & (~(or_dcpl_120 | (fsm_output[5]) | (fsm_output[2])
        | (fsm_output[6]))) ) begin
      while_if_nor_1_itm <= ~((cmd_in_t_Pop_mioi_idat_mxwt[73:43]!=31'b0000000000000000000000000000000));
    end
  end
  always @(posedge i_clk) begin
    if ( inputUnit_main_wen ) begin
      inputUnit_inputUnit_core_slc_inputUnit_inputUnit_core_pkt_data_buf_495_0_lpi_1_dfm_6_399_0_itm_399_368
          <= inputUnit_inputUnit_core_pkt_data_buf_495_0_lpi_1_dfm_6_431_368[31:0];
      inputUnit_inputUnit_core_slc_inputUnit_inputUnit_core_pkt_data_buf_495_0_lpi_1_dfm_6_399_0_itm_367_304
          <= MUX1HOT_v_64_3_2((stream_in_t_Pop_mioi_idat_mxwt[387:324]), (stream_in_t_Pop_mioi_idat_mxwt[451:388]),
          inputUnit_inputUnit_core_if_if_if_if_inputUnit_inputUnit_core_if_if_if_if_and_nl,
          {(~ inputUnit_inputUnit_core_if_if_unequal_tmp) , inputUnit_inputUnit_core_if_if_and_3_ssc_1
          , inputUnit_inputUnit_core_if_if_and_4_ssc_mx0w1});
      inputUnit_inputUnit_core_slc_inputUnit_inputUnit_core_pkt_data_buf_495_0_lpi_1_dfm_6_399_0_itm_175_112
          <= MUX_v_64_2_2(64'b0000000000000000000000000000000000000000000000000000000000000000,
          inputUnit_inputUnit_core_if_if_inputUnit_inputUnit_core_if_if_mux1h_3_nl,
          inputUnit_inputUnit_core_not_31_nl);
      inputUnit_inputUnit_core_slc_inputUnit_inputUnit_core_pkt_data_buf_495_0_lpi_1_dfm_6_399_0_itm_111_48
          <= MUX1HOT_v_64_7_2((stream_in_t_Pop_mioi_idat_mxwt[131:68]), (stream_in_t_Pop_mioi_idat_mxwt[195:132]),
          (stream_in_t_Pop_mioi_idat_mxwt[259:196]), (stream_in_t_Pop_mioi_idat_mxwt[323:260]),
          (stream_in_t_Pop_mioi_idat_mxwt[387:324]), (stream_in_t_Pop_mioi_idat_mxwt[451:388]),
          inputUnit_inputUnit_core_if_if_if_if_if_if_if_if_inputUnit_inputUnit_core_if_if_if_if_if_if_if_if_and_nl,
          {(~ inputUnit_inputUnit_core_if_if_unequal_tmp) , inputUnit_inputUnit_core_if_if_and_3_ssc_1
          , inputUnit_inputUnit_core_if_if_asn_11 , inputUnit_inputUnit_core_if_if_asn_13
          , inputUnit_inputUnit_core_if_if_if_if_and_9_mx0w1 , inputUnit_inputUnit_core_if_if_if_if_and_11_ssc
          , inputUnit_inputUnit_core_if_if_if_if_and_12_ssc});
      inputUnit_inputUnit_core_slc_inputUnit_inputUnit_core_pkt_data_buf_495_0_lpi_1_dfm_6_399_0_itm_47_0
          <= MUX1HOT_v_48_8_2((stream_in_t_Pop_mioi_idat_mxwt[67:20]), (stream_in_t_Pop_mioi_idat_mxwt[131:84]),
          (stream_in_t_Pop_mioi_idat_mxwt[195:148]), (stream_in_t_Pop_mioi_idat_mxwt[259:212]),
          (stream_in_t_Pop_mioi_idat_mxwt[323:276]), (stream_in_t_Pop_mioi_idat_mxwt[387:340]),
          (stream_in_t_Pop_mioi_idat_mxwt[451:404]), (stream_in_t_Pop_mioi_idat_mxwt[515:468]),
          {(~ inputUnit_inputUnit_core_if_if_unequal_tmp) , inputUnit_inputUnit_core_if_if_and_3_ssc_1
          , inputUnit_inputUnit_core_if_if_asn_11 , inputUnit_inputUnit_core_if_if_asn_13
          , inputUnit_inputUnit_core_if_if_if_if_and_9_mx0w1 , inputUnit_inputUnit_core_if_if_if_if_and_11_ssc
          , inputUnit_inputUnit_core_if_if_and_16_nl , inputUnit_inputUnit_core_if_if_and_17_nl});
      inputUnit_inputUnit_core_slc_inputUnit_inputUnit_core_pkt_data_buf_495_0_lpi_1_dfm_6_399_0_itm_303_240
          <= MUX_v_64_2_2(64'b0000000000000000000000000000000000000000000000000000000000000000,
          inputUnit_inputUnit_core_if_if_inputUnit_inputUnit_core_if_if_mux1h_1_nl,
          inputUnit_inputUnit_core_not_nl);
      inputUnit_inputUnit_core_slc_inputUnit_inputUnit_core_pkt_data_buf_495_0_lpi_1_dfm_6_399_0_itm_239_176
          <= MUX1HOT_v_64_5_2((stream_in_t_Pop_mioi_idat_mxwt[259:196]), (stream_in_t_Pop_mioi_idat_mxwt[323:260]),
          (stream_in_t_Pop_mioi_idat_mxwt[387:324]), (stream_in_t_Pop_mioi_idat_mxwt[451:388]),
          inputUnit_inputUnit_core_if_if_if_if_if_if_inputUnit_inputUnit_core_if_if_if_if_if_if_and_nl,
          {(~ inputUnit_inputUnit_core_if_if_unequal_tmp) , inputUnit_inputUnit_core_if_if_and_3_ssc_1
          , inputUnit_inputUnit_core_if_if_asn_11 , inputUnit_inputUnit_core_if_if_asn_13
          , inputUnit_inputUnit_core_if_if_and_9_ssc});
      inputUnit_inputUnit_core_pkt_empty_5_2_lpi_1_dfm_8_3_2 <= MUX_v_2_2_2(inputUnit_inputUnit_core_and_12_nl,
          2'b11, inputUnit_inputUnit_core_and_tmp_1);
      inputUnit_inputUnit_core_pkt_empty_5_2_lpi_1_dfm_8_1 <= (((inputUnit_inputUnit_core_if_if_if_if_if_if_if_if_unequal_tmp_mx2
          & (~((~ inputUnit_inputUnit_core_if_if_if_if_unequal_tmp_1) | inputUnit_inputUnit_core_if_if_if_if_mux_nl)))
          | (~ inputUnit_inputUnit_core_if_if_mux_4_nl) | inputUnit_inputUnit_core_if_if_if_if_and_ssc_mx0w0
          | inputUnit_inputUnit_core_if_if_mux_2_nl) & inputUnit_inputUnit_core_if_if_unequal_tmp)
          | inputUnit_inputUnit_core_and_tmp_1 | inputUnit_inputUnit_core_unequal_tmp;
      inputUnit_inputUnit_core_and_6_itm_95_32 <= (stream_in_t_Pop_mioi_idat_mxwt[515:452])
          & (signext_64_1(inputUnit_inputUnit_core_if_if_nor_nl)) & ({{63{inputUnit_inputUnit_core_nor_seb_1}},
          inputUnit_inputUnit_core_nor_seb_1});
      inputUnit_inputUnit_core_and_6_itm_31_0 <= MUX_v_32_2_2(32'b00000000000000000000000000000000,
          (inputUnit_inputUnit_core_pkt_data_buf_495_0_lpi_1_dfm_6_431_368[63:32]),
          inputUnit_inputUnit_core_nor_seb_1);
      inputUnit_inputUnit_core_payload_data_slc_inputUnit_inputUnit_core_payload_data_3_463_16_319_192_itm
          <= inputUnit_inputUnit_core_payload_data_3_463_16_lpi_1_dfm_1[319:192];
      inputUnit_inputUnit_core_payload_data_slc_inputUnit_inputUnit_core_payload_data_3_463_16_447_320_itm
          <= inputUnit_inputUnit_core_payload_data_3_463_16_lpi_1_dfm_1[447:320];
    end
  end
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      stream_in_read_slc_stream_in_t_Pop_mio_mrgout_dat_515_4_7_itm <= 16'b0000000000000000;
      inputUnit_inputUnit_core_if_if_unequal_tmp <= 1'b0;
      stream_in_read_slc_stream_in_t_Pop_mio_mrgout_dat_515_4_6_itm <= 8'b00000000;
      stream_in_t_Pop_mio_mrgout_dat_sva_522 <= 1'b0;
      stream_in_t_Pop_mio_mrgout_dat_sva_3_0 <= 4'b0000;
      inputUnit_inputUnit_core_if_unequal_tmp <= 1'b0;
      inputUnit_inputUnit_core_mux_itm <= 1'b0;
      inputUnit_inputUnit_core_while_stage_0_1 <= 1'b0;
    end
    else if ( inputUnit_main_wen ) begin
      stream_in_read_slc_stream_in_t_Pop_mio_mrgout_dat_515_4_7_itm <= stream_in_t_Pop_mioi_idat_mxwt[483:468];
      inputUnit_inputUnit_core_if_if_unequal_tmp <= (stream_in_t_Pop_mioi_idat_mxwt[483:468]!=16'b0000000000000000);
      stream_in_read_slc_stream_in_t_Pop_mio_mrgout_dat_515_4_6_itm <= stream_in_t_Pop_mioi_idat_mxwt[163:156];
      stream_in_t_Pop_mio_mrgout_dat_sva_522 <= stream_in_t_Pop_mioi_idat_mxwt[522];
      stream_in_t_Pop_mio_mrgout_dat_sva_3_0 <= stream_in_t_Pop_mioi_idat_mxwt[3:0];
      inputUnit_inputUnit_core_if_unequal_tmp <= inputUnit_inputUnit_core_if_mux_nl
          | (fsm_output[5]);
      inputUnit_inputUnit_core_mux_itm <= MUX_s_1_2_2(inputUnit_inputUnit_core_if_mux_7_nl,
          stream_in_t_Pop_mio_mrgout_dat_sva_522, inputUnit_inputUnit_core_unequal_tmp);
      inputUnit_inputUnit_core_while_stage_0_1 <= ~((~(inputUnit_inputUnit_core_if_unequal_tmp
          & (~(inputUnit_inputUnit_core_while_stage_0_1 & inputUnit_inputUnit_core_and_ssc_1))))
          & (fsm_output[6]));
    end
  end
  always @(posedge i_clk) begin
    if ( stream_in_read_and_1_cse ) begin
      ptp_l_set_bv_lpi_1_dfm <= MUX_v_160_2_2((stream_in_t_Pop_mioi_idat_mxwt[275:116]),
          ptp_l_set_bv_lpi_1, inputUnit_inputUnit_core_inputUnit_inputUnit_core_nand_tmp);
      ptp_h_set_bv_lpi_1_dfm <= MUX_v_192_2_2((stream_in_t_Pop_mioi_idat_mxwt[467:276]),
          ptp_h_set_bv_lpi_1, inputUnit_inputUnit_core_inputUnit_inputUnit_core_nand_tmp);
    end
  end
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      stream_in_t_Pop_mio_mrgout_dat_sva_515_4 <= 512'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( stream_in_read_and_1_cse ) begin
      stream_in_t_Pop_mio_mrgout_dat_sva_515_4 <= stream_in_t_Pop_mioi_idat_mxwt[515:4];
    end
  end
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      inputUnit_inputUnit_core_unequal_tmp <= 1'b0;
    end
    else if ( inputUnit_main_wen & (fsm_output[2]) ) begin
      inputUnit_inputUnit_core_unequal_tmp <= inputUnit_inputUnit_core_inputUnit_inputUnit_core_nand_tmp;
    end
  end
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      inputUnit_inputUnit_core_inputUnit_inputUnit_core_and_1_itm <= 1'b0;
    end
    else if ( inputUnit_main_wen & (~(and_dcpl_64 & (~ (fsm_output[9])) & (~((fsm_output[2:1]!=2'b00)))))
        ) begin
      inputUnit_inputUnit_core_inputUnit_inputUnit_core_and_1_itm <= (stream_in_t_Pop_mioi_idat_mxwt[111])
          & inputUnit_inputUnit_core_else_if_nor_tmp;
    end
  end
  always @(posedge i_clk) begin
    if ( inputUnit_inputUnit_core_if_if_and_14_cse ) begin
      inputUnit_inputUnit_core_payload_data_3_463_16_lpi_1_dfm_1 <= MUX_v_448_2_2(inputUnit_inputUnit_core_payload_data_3_463_16_lpi_1,
          (stream_in_t_Pop_mioi_idat_mxwt[467:20]), or_tmp_187);
    end
  end
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      header_0_hdr0_set_bv_63_48_lpi_1_dfm_1 <= 16'b0000000000000000;
    end
    else if ( inputUnit_inputUnit_core_if_if_and_14_cse ) begin
      header_0_hdr0_set_bv_63_48_lpi_1_dfm_1 <= MUX1HOT_v_16_3_2((stream_in_t_Pop_mioi_idat_mxwt[115:100]),
          header_0_hdr0_set_bv_63_48_lpi_1, (stream_in_t_Pop_mioi_idat_mxwt[19:4]),
          {(fsm_output[2]) , or_tmp_186 , or_tmp_187});
    end
  end
  always @(posedge i_clk) begin
    if ( inputUnit_inputUnit_core_hdr_count_and_cse ) begin
      inputUnit_inputUnit_core_hdr_count_lpi_1_dfm_8_3_1 <= ~(inputUnit_inputUnit_core_inputUnit_inputUnit_core_mux1h_1_nl
          | ({{2{inputUnit_inputUnit_core_and_tmp_1}}, inputUnit_inputUnit_core_and_tmp_1})
          | ({{2{inputUnit_inputUnit_core_unequal_tmp}}, inputUnit_inputUnit_core_unequal_tmp}));
      inputUnit_inputUnit_core_hdr_count_lpi_1_dfm_8_0 <= ~((~((inputUnit_inputUnit_core_if_if_if_if_if_if_if_if_unequal_tmp_mx2
          & (~(inputUnit_inputUnit_core_inputUnit_inputUnit_core_nor_1_ssc_1 | inputUnit_inputUnit_core_and_ssc_2
          | inputUnit_inputUnit_core_if_if_if_if_and_4_ssc_1))) | inputUnit_inputUnit_core_if_if_and_ssc_1
          | inputUnit_inputUnit_core_if_if_if_if_and_ssc_3 | inputUnit_inputUnit_core_if_if_if_if_if_if_and_ssc_4
          | inputUnit_inputUnit_core_and_tmp_1)) | inputUnit_inputUnit_core_unequal_tmp);
    end
  end
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      reg_stream_in_t_Pop_1mio_mrgout_dat_ftd_55 <= 464'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( inputUnit_inputUnit_core_hdr_count_and_cse ) begin
      reg_stream_in_t_Pop_1mio_mrgout_dat_ftd_55 <= stream_in_t_Pop_mioi_idat_mxwt[467:4];
    end
  end
  always @(posedge i_clk) begin
    if ( i_rst ) begin
      inputUnit_inputUnit_core_and_ssc_1 <= 1'b0;
    end
    else if ( inputUnit_main_wen & ((fsm_output[4:3]!=2'b00) | inputUnit_inputUnit_core_and_ssc_1_mx0c2
        | (fsm_output[6])) & (inputUnit_inputUnit_core_while_stage_0_1 | and_dcpl_63
        | (fsm_output[4:3]!=2'b00) | inputUnit_inputUnit_core_and_ssc_1_mx0c2) )
        begin
      inputUnit_inputUnit_core_and_ssc_1 <= MUX1HOT_s_1_4_2(inputUnit_inputUnit_core_and_tmp_1,
          inputUnit_inputUnit_core_mux_itm, while_if_nor_nl, (stream_in_t_Pop_mioi_idat_mxwt[522]),
          {(fsm_output[3]) , (fsm_output[4]) , inputUnit_inputUnit_core_or_7_nl ,
          inputUnit_inputUnit_core_and_19_nl});
    end
  end
  always @(posedge i_clk) begin
    if ( cmd_in_read_and_1_cse ) begin
      cmd_in_read_slc_cmd_in_t_Pop_mio_mrgout_dat_3_0_itm <= MUX1HOT_v_4_3_2(stream_in_t_Pop_mio_mrgout_dat_sva_3_0,
          (stream_in_t_Pop_mioi_idat_mxwt[3:0]), (cmd_in_t_Pop_mio_mrgout_dat_sva_9_0[3:0]),
          {or_tmp_186 , or_tmp_187 , (fsm_output[7])});
      bfu_out_write_4_asn_itm <= bt0_sva;
    end
  end
  always @(posedge i_clk) begin
    if ( inputUnit_main_wen & (~ (fsm_output[7])) ) begin
      stream_in_read_slc_stream_in_t_Pop_mio_mrgout_dat_515_4_itm <= stream_in_t_Pop_mio_mrgout_dat_sva_515_4[511:464];
    end
  end
  assign bfu_out_write_last_mux1h_nl = MUX1HOT_v_48_5_2((stream_in_t_Pop_mioi_idat_mxwt[115:68]),
      (stream_in_t_Pop_mio_mrgout_dat_sva_515_4[111:64]), (ptp_l_set_bv_lpi_1_dfm[111:64]),
      (inputUnit_inputUnit_core_payload_data_3_463_16_lpi_1_dfm_1[47:0]), (inputUnit_inputUnit_core_payload_data_slc_inputUnit_inputUnit_core_payload_data_3_463_16_319_192_itm[111:64]),
      {and_191_cse , inputUnit_inputUnit_core_and_20_cse , and_206_cse , or_tmp_61
      , or_tmp_62});
  assign bfu_out_write_last_not_14_nl = ~ and_189_cse;
  assign bfu_out_write_last_mux1h_2_nl = MUX1HOT_v_16_5_2((stream_in_t_Pop_mioi_idat_mxwt[67:52]),
      (stream_in_t_Pop_mio_mrgout_dat_sva_515_4[63:48]), (ptp_l_set_bv_lpi_1_dfm[63:48]),
      header_0_hdr0_set_bv_63_48_lpi_1_dfm_1, (inputUnit_inputUnit_core_payload_data_slc_inputUnit_inputUnit_core_payload_data_3_463_16_319_192_itm[63:48]),
      {and_191_cse , inputUnit_inputUnit_core_and_20_cse , and_206_cse , or_tmp_61
      , or_tmp_62});
  assign bfu_out_write_last_not_16_nl = ~ and_189_cse;
  assign bfu_out_write_last_mux1h_3_nl = MUX1HOT_v_48_5_2((stream_in_t_Pop_mioi_idat_mxwt[51:4]),
      (stream_in_t_Pop_mio_mrgout_dat_sva_515_4[47:0]), (ptp_l_set_bv_lpi_1_dfm[47:0]),
      stream_in_read_slc_stream_in_t_Pop_mio_mrgout_dat_515_4_itm, (inputUnit_inputUnit_core_payload_data_slc_inputUnit_inputUnit_core_payload_data_3_463_16_319_192_itm[47:0]),
      {and_191_cse , inputUnit_inputUnit_core_and_20_cse , and_206_cse , or_tmp_61
      , or_tmp_62});
  assign bfu_out_write_last_not_18_nl = ~ and_189_cse;
  assign bfu_out_write_last_mux1h_1_nl = MUX1HOT_v_16_3_2((ptp_l_set_bv_lpi_1_dfm[127:112]),
      (inputUnit_inputUnit_core_payload_data_3_463_16_lpi_1_dfm_1[63:48]), (inputUnit_inputUnit_core_payload_data_slc_inputUnit_inputUnit_core_payload_data_3_463_16_319_192_itm[127:112]),
      {and_206_cse , or_tmp_61 , or_tmp_62});
  assign bfu_out_write_last_not_15_nl = ~ or_tmp_64;
  assign bfu_out_write_last_mux1h_7_nl = MUX1HOT_v_124_3_2((ptp_h_set_bv_lpi_1_dfm[127:4]),
      (inputUnit_inputUnit_core_payload_data_3_463_16_lpi_1_dfm_1[191:68]), (inputUnit_inputUnit_core_payload_data_slc_inputUnit_inputUnit_core_payload_data_3_463_16_447_320_itm[127:4]),
      {and_206_cse , or_tmp_61 , or_tmp_62});
  assign bfu_out_write_last_not_24_nl = ~ or_tmp_64;
  assign bfu_out_write_last_not_17_nl = ~ or_tmp_76;
  assign bfu_out_write_last_not_25_nl = ~ or_tmp_76;
  assign bfu_out_write_last_mux1h_4_nl = MUX1HOT_v_3_3_2(3'b001, 3'b100, 3'b010,
      {or_tmp_87 , and_206_cse , or_tmp_61});
  assign bfu_out_write_last_bfu_out_write_last_nor_nl = ~(MUX_v_3_2_2(bfu_out_write_last_mux1h_4_nl,
      3'b111, and_189_cse));
  assign t_read_reset_check_ResetChecker_mux1h_1_nl = MUX1HOT_s_1_4_2(inputUnit_inputUnit_core_hdr_count_lpi_1_dfm_8_0,
      (ptp_h_set_bv_lpi_1_dfm[0]), (inputUnit_inputUnit_core_payload_data_3_463_16_lpi_1_dfm_1[64]),
      (inputUnit_inputUnit_core_payload_data_slc_inputUnit_inputUnit_core_payload_data_3_463_16_447_320_itm[0]),
      {inputUnit_inputUnit_core_and_20_cse , and_206_cse , or_tmp_61 , or_tmp_62});
  assign bfu_out_write_last_mux1h_6_nl = MUX1HOT_v_3_4_2(inputUnit_inputUnit_core_hdr_count_lpi_1_dfm_8_3_1,
      (ptp_h_set_bv_lpi_1_dfm[3:1]), (inputUnit_inputUnit_core_payload_data_3_463_16_lpi_1_dfm_1[67:65]),
      (inputUnit_inputUnit_core_payload_data_slc_inputUnit_inputUnit_core_payload_data_3_463_16_447_320_itm[3:1]),
      {inputUnit_inputUnit_core_and_20_cse , and_206_cse , or_tmp_61 , or_tmp_62});
  assign bfu_out_write_last_not_22_nl = ~ or_tmp_102;
  assign inputUnit_inputUnit_mux1h_1_nl = MUX1HOT_v_32_3_2(bt1_sva, bt0_sva, bfu_out_write_4_asn_itm,
      {and_191_cse , bfu_out_t_Push_mioi_idat_35_4_mx0c2 , and_250_cse});
  assign bfu_out_write_last_not_23_nl = ~ and_189_cse;
  assign inputUnit_inputUnit_core_mux_20_nl = MUX_v_32_2_2(inputUnit_inputUnit_core_slc_inputUnit_inputUnit_core_pkt_data_buf_495_0_lpi_1_dfm_6_399_0_itm_399_368,
      (stream_in_t_Pop_mio_mrgout_dat_sva_515_4[511:480]), inputUnit_inputUnit_core_unequal_tmp);
  assign inputUnit_inputUnit_core_not_30_nl = ~ inputUnit_inputUnit_core_and_ssc_1;
  assign inputUnit_inputUnit_core_inputUnit_inputUnit_core_and_3_nl = MUX_v_32_2_2(32'b00000000000000000000000000000000,
      inputUnit_inputUnit_core_mux_20_nl, inputUnit_inputUnit_core_not_30_nl);
  assign inputUnit_inputUnit_core_mux_27_nl = MUX_v_64_2_2(inputUnit_inputUnit_core_slc_inputUnit_inputUnit_core_pkt_data_buf_495_0_lpi_1_dfm_6_399_0_itm_367_304,
      (stream_in_t_Pop_mio_mrgout_dat_sva_515_4[479:416]), inputUnit_inputUnit_core_unequal_tmp);
  assign inputUnit_inputUnit_core_not_21_nl = ~ inputUnit_inputUnit_core_and_ssc_1;
  assign inputUnit_inputUnit_core_inputUnit_inputUnit_core_and_6_nl = MUX_v_64_2_2(64'b0000000000000000000000000000000000000000000000000000000000000000,
      inputUnit_inputUnit_core_mux_27_nl, inputUnit_inputUnit_core_not_21_nl);
  assign inputUnit_inputUnit_core_mux_21_nl = MUX_v_64_2_2(inputUnit_inputUnit_core_slc_inputUnit_inputUnit_core_pkt_data_buf_495_0_lpi_1_dfm_6_399_0_itm_303_240,
      (stream_in_t_Pop_mio_mrgout_dat_sva_515_4[415:352]), inputUnit_inputUnit_core_unequal_tmp);
  assign inputUnit_inputUnit_core_not_29_nl = ~ inputUnit_inputUnit_core_and_ssc_1;
  assign inputUnit_inputUnit_core_inputUnit_inputUnit_core_and_4_nl = MUX_v_64_2_2(64'b0000000000000000000000000000000000000000000000000000000000000000,
      inputUnit_inputUnit_core_mux_21_nl, inputUnit_inputUnit_core_not_29_nl);
  assign inputUnit_inputUnit_core_mux_26_nl = MUX_v_64_2_2(inputUnit_inputUnit_core_slc_inputUnit_inputUnit_core_pkt_data_buf_495_0_lpi_1_dfm_6_399_0_itm_239_176,
      (stream_in_t_Pop_mio_mrgout_dat_sva_515_4[351:288]), inputUnit_inputUnit_core_unequal_tmp);
  assign inputUnit_inputUnit_core_not_25_nl = ~ inputUnit_inputUnit_core_and_ssc_1;
  assign inputUnit_inputUnit_core_inputUnit_inputUnit_core_and_5_nl = MUX_v_64_2_2(64'b0000000000000000000000000000000000000000000000000000000000000000,
      inputUnit_inputUnit_core_mux_26_nl, inputUnit_inputUnit_core_not_25_nl);
  assign pkt_buf_out_write_pkt_buf_out_write_pkt_buf_out_write_mux1h_nl = MUX1HOT_v_64_3_2(inputUnit_inputUnit_core_slc_inputUnit_inputUnit_core_pkt_data_buf_495_0_lpi_1_dfm_6_399_0_itm_175_112,
      (stream_in_t_Pop_mio_mrgout_dat_sva_515_4[287:224]), (stream_in_t_Pop_mioi_idat_mxwt[179:116]),
      {pkt_buf_out_write_pkt_buf_out_write_nor_ssc , pkt_buf_out_write_and_13_ssc
      , and_198_cse});
  assign inputUnit_inputUnit_core_not_32_nl = ~ inputUnit_inputUnit_core_and_ssc_1;
  assign pkt_buf_out_write_pkt_buf_out_write_pkt_buf_out_write_mux1h_2_nl = MUX1HOT_v_64_3_2(inputUnit_inputUnit_core_slc_inputUnit_inputUnit_core_pkt_data_buf_495_0_lpi_1_dfm_6_399_0_itm_111_48,
      (stream_in_t_Pop_mio_mrgout_dat_sva_515_4[223:160]), (stream_in_t_Pop_mioi_idat_mxwt[115:52]),
      {pkt_buf_out_write_pkt_buf_out_write_nor_ssc , pkt_buf_out_write_and_13_ssc
      , and_198_cse});
  assign inputUnit_inputUnit_core_not_28_nl = ~ inputUnit_inputUnit_core_and_ssc_1;
  assign inputUnit_inputUnit_core_if_if_if_if_nor_nl = ~(inputUnit_inputUnit_core_if_if_if_if_and_ssc_mx0w0
      | inputUnit_inputUnit_core_if_if_if_if_and_3_m1c_1);
  assign inputUnit_inputUnit_core_if_if_if_if_inputUnit_inputUnit_core_if_if_if_if_and_nl
      = MUX_v_64_2_2(64'b0000000000000000000000000000000000000000000000000000000000000000,
      (stream_in_t_Pop_mioi_idat_mxwt[515:452]), inputUnit_inputUnit_core_if_if_if_if_nor_nl);
  assign inputUnit_inputUnit_core_if_if_inputUnit_inputUnit_core_if_if_mux1h_3_nl
      = MUX1HOT_v_64_6_2((stream_in_t_Pop_mioi_idat_mxwt[195:132]), (stream_in_t_Pop_mioi_idat_mxwt[259:196]),
      (stream_in_t_Pop_mioi_idat_mxwt[323:260]), (stream_in_t_Pop_mioi_idat_mxwt[387:324]),
      (stream_in_t_Pop_mioi_idat_mxwt[451:388]), (stream_in_t_Pop_mioi_idat_mxwt[515:452]),
      {(~ inputUnit_inputUnit_core_if_if_unequal_tmp) , inputUnit_inputUnit_core_if_if_and_3_ssc_1
      , inputUnit_inputUnit_core_if_if_asn_11 , inputUnit_inputUnit_core_if_if_asn_13
      , inputUnit_inputUnit_core_if_if_if_if_and_9_mx0w1 , inputUnit_inputUnit_core_if_if_if_if_and_11_ssc});
  assign inputUnit_inputUnit_core_not_31_nl = ~ inputUnit_inputUnit_core_if_if_if_if_and_12_ssc;
  assign inputUnit_inputUnit_core_not_26_nl = ~ inputUnit_inputUnit_core_if_if_if_if_if_if_if_if_mux_1_ssc;
  assign inputUnit_inputUnit_core_if_if_if_if_if_if_if_if_inputUnit_inputUnit_core_if_if_if_if_if_if_if_if_and_nl
      = MUX_v_64_2_2(64'b0000000000000000000000000000000000000000000000000000000000000000,
      (stream_in_t_Pop_mioi_idat_mxwt[515:452]), inputUnit_inputUnit_core_not_26_nl);
  assign inputUnit_inputUnit_core_if_if_and_16_nl = (~ inputUnit_inputUnit_core_if_if_if_if_if_if_if_if_mux_1_ssc)
      & inputUnit_inputUnit_core_if_if_if_if_and_12_ssc;
  assign inputUnit_inputUnit_core_if_if_and_17_nl = inputUnit_inputUnit_core_if_if_if_if_if_if_if_if_mux_1_ssc
      & inputUnit_inputUnit_core_if_if_if_if_and_12_ssc;
  assign inputUnit_inputUnit_core_if_if_inputUnit_inputUnit_core_if_if_mux1h_1_nl
      = MUX1HOT_v_64_4_2((stream_in_t_Pop_mioi_idat_mxwt[323:260]), (stream_in_t_Pop_mioi_idat_mxwt[387:324]),
      (stream_in_t_Pop_mioi_idat_mxwt[451:388]), (stream_in_t_Pop_mioi_idat_mxwt[515:452]),
      {(~ inputUnit_inputUnit_core_if_if_unequal_tmp) , inputUnit_inputUnit_core_if_if_and_3_ssc_1
      , inputUnit_inputUnit_core_if_if_asn_11 , inputUnit_inputUnit_core_if_if_asn_13});
  assign inputUnit_inputUnit_core_not_nl = ~ inputUnit_inputUnit_core_if_if_and_9_ssc;
  assign inputUnit_inputUnit_core_if_if_if_if_if_if_nor_nl = ~(inputUnit_inputUnit_core_if_if_if_if_if_if_and_ssc_3
      | inputUnit_inputUnit_core_if_if_if_if_if_if_and_6_ssc_1);
  assign inputUnit_inputUnit_core_if_if_if_if_if_if_inputUnit_inputUnit_core_if_if_if_if_if_if_and_nl
      = MUX_v_64_2_2(64'b0000000000000000000000000000000000000000000000000000000000000000,
      (stream_in_t_Pop_mioi_idat_mxwt[515:452]), inputUnit_inputUnit_core_if_if_if_if_if_if_nor_nl);
  assign t_read_reset_check_ResetChecker_t_read_reset_check_ResetChecker_and_nl =
      inputUnit_inputUnit_core_if_unequal_tmp & (~ inputUnit_inputUnit_core_and_ssc_1);
  assign inputUnit_inputUnit_core_if_mux_nl = MUX_s_1_2_2(inputUnit_inputUnit_core_if_unequal_tmp_1,
      t_read_reset_check_ResetChecker_t_read_reset_check_ResetChecker_and_nl, fsm_output[6]);
  assign inputUnit_inputUnit_core_if_mux_7_nl = MUX_s_1_2_2((stream_in_t_Pop_mioi_idat_mxwt[522]),
      stream_in_t_Pop_mio_mrgout_dat_sva_522, inputUnit_inputUnit_core_if_unequal_tmp_1);
  assign inputUnit_inputUnit_core_if_if_or_1_nl = inputUnit_inputUnit_core_if_if_if_if_and_9_mx0w1
      | inputUnit_inputUnit_core_if_if_if_if_if_if_and_2_ssc_mx0w1;
  assign inputUnit_inputUnit_core_if_if_mux_6_nl = MUX_v_2_2_2(2'b01, 2'b10, inputUnit_inputUnit_core_if_if_or_1_nl);
  assign inputUnit_inputUnit_core_if_if_if_if_if_if_and_3_nl = inputUnit_inputUnit_core_if_if_if_if_if_if_if_unequal_tmp_1
      & inputUnit_inputUnit_core_if_if_if_if_if_if_unequal_tmp_1 & inputUnit_inputUnit_core_if_if_if_if_and_3_m1c_1
      & inputUnit_inputUnit_core_if_if_and_4_ssc_mx0w1;
  assign inputUnit_inputUnit_core_if_if_inputUnit_inputUnit_core_if_if_inputUnit_inputUnit_core_if_if_or_1_nl
      = MUX_v_2_2_2(inputUnit_inputUnit_core_if_if_mux_6_nl, 2'b11, inputUnit_inputUnit_core_if_if_if_if_if_if_and_3_nl);
  assign inputUnit_inputUnit_core_and_12_nl = inputUnit_inputUnit_core_if_if_inputUnit_inputUnit_core_if_if_inputUnit_inputUnit_core_if_if_or_1_nl
      & ({{1{inputUnit_inputUnit_core_if_if_and_4_ssc_mx0w1}}, inputUnit_inputUnit_core_if_if_and_4_ssc_mx0w1})
      & ({{1{inputUnit_inputUnit_core_if_if_unequal_tmp}}, inputUnit_inputUnit_core_if_if_unequal_tmp})
      & (signext_2_1(~ inputUnit_inputUnit_core_unequal_tmp));
  assign inputUnit_inputUnit_core_if_if_if_if_mux_nl = MUX_s_1_2_2(inputUnit_inputUnit_core_if_if_if_if_and_9_mx0w1,
      inputUnit_inputUnit_core_if_if_if_if_and_5_ssc, or_dcpl_108);
  assign inputUnit_inputUnit_core_if_if_mux_4_nl = MUX_s_1_2_2(inputUnit_inputUnit_core_if_if_and_4_ssc_mx0w1,
      inputUnit_inputUnit_core_if_if_and_2_tmp, or_dcpl_108);
  assign inputUnit_inputUnit_core_if_if_mux_2_nl = MUX_s_1_2_2(inputUnit_inputUnit_core_if_if_if_if_if_if_and_2_ssc_mx0w1,
      inputUnit_inputUnit_core_if_if_if_if_if_if_and_2_ssc, or_dcpl_108);
  assign inputUnit_inputUnit_core_if_if_nor_nl = ~(inputUnit_inputUnit_core_if_if_and_3_ssc_1
      | inputUnit_inputUnit_core_if_if_and_4_ssc_mx0w1);
  assign inputUnit_inputUnit_core_or_3_nl = inputUnit_inputUnit_core_inputUnit_inputUnit_core_nor_1_ssc_1
      | inputUnit_inputUnit_core_if_if_and_ssc_1;
  assign inputUnit_inputUnit_core_or_4_nl = inputUnit_inputUnit_core_and_ssc_2 |
      inputUnit_inputUnit_core_if_if_if_if_and_ssc_3;
  assign inputUnit_inputUnit_core_or_5_nl = inputUnit_inputUnit_core_if_if_if_if_and_4_ssc_1
      | inputUnit_inputUnit_core_if_if_if_if_if_if_and_ssc_4;
  assign inputUnit_inputUnit_core_if_if_if_if_if_if_and_1_nl = inputUnit_inputUnit_core_if_if_if_if_if_if_if_unequal_tmp_1
      & inputUnit_inputUnit_core_if_if_if_if_if_if_unequal_tmp_1 & inputUnit_inputUnit_core_if_if_if_if_and_3_m1c_1
      & inputUnit_inputUnit_core_if_if_and_1_m1c_1;
  assign inputUnit_inputUnit_core_inputUnit_inputUnit_core_mux1h_1_nl = MUX1HOT_v_3_4_2(3'b110,
      3'b101, 3'b100, 3'b011, {inputUnit_inputUnit_core_or_3_nl , inputUnit_inputUnit_core_or_4_nl
      , inputUnit_inputUnit_core_or_5_nl , inputUnit_inputUnit_core_if_if_if_if_if_if_and_1_nl});
  assign while_if_nor_nl = ~((~((cmd_in_t_Pop_mio_mrgout_dat_sva_78_15[63:32]!=32'b00000000000000000000000000000000)))
      | ((cmd_in_t_Pop_mio_mrgout_dat_sva_78_15[63:32]==32'b00000000000000000000000000000001)));
  assign inputUnit_inputUnit_core_or_7_nl = inputUnit_inputUnit_core_and_ssc_1_mx0c2
      | inputUnit_inputUnit_core_and_20_cse;
  assign inputUnit_inputUnit_core_and_19_nl = (~ and_dcpl_63) & (fsm_output[6]);

  function automatic  MUX1HOT_s_1_4_2;
    input  input_3;
    input  input_2;
    input  input_1;
    input  input_0;
    input [3:0] sel;
    reg  result;
  begin
    result = input_0 & sel[0];
    result = result | (input_1 & sel[1]);
    result = result | (input_2 & sel[2]);
    result = result | (input_3 & sel[3]);
    MUX1HOT_s_1_4_2 = result;
  end
  endfunction


  function automatic [123:0] MUX1HOT_v_124_3_2;
    input [123:0] input_2;
    input [123:0] input_1;
    input [123:0] input_0;
    input [2:0] sel;
    reg [123:0] result;
  begin
    result = input_0 & {124{sel[0]}};
    result = result | (input_1 & {124{sel[1]}});
    result = result | (input_2 & {124{sel[2]}});
    MUX1HOT_v_124_3_2 = result;
  end
  endfunction


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


  function automatic [15:0] MUX1HOT_v_16_5_2;
    input [15:0] input_4;
    input [15:0] input_3;
    input [15:0] input_2;
    input [15:0] input_1;
    input [15:0] input_0;
    input [4:0] sel;
    reg [15:0] result;
  begin
    result = input_0 & {16{sel[0]}};
    result = result | (input_1 & {16{sel[1]}});
    result = result | (input_2 & {16{sel[2]}});
    result = result | (input_3 & {16{sel[3]}});
    result = result | (input_4 & {16{sel[4]}});
    MUX1HOT_v_16_5_2 = result;
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


  function automatic [47:0] MUX1HOT_v_48_4_2;
    input [47:0] input_3;
    input [47:0] input_2;
    input [47:0] input_1;
    input [47:0] input_0;
    input [3:0] sel;
    reg [47:0] result;
  begin
    result = input_0 & {48{sel[0]}};
    result = result | (input_1 & {48{sel[1]}});
    result = result | (input_2 & {48{sel[2]}});
    result = result | (input_3 & {48{sel[3]}});
    MUX1HOT_v_48_4_2 = result;
  end
  endfunction


  function automatic [47:0] MUX1HOT_v_48_5_2;
    input [47:0] input_4;
    input [47:0] input_3;
    input [47:0] input_2;
    input [47:0] input_1;
    input [47:0] input_0;
    input [4:0] sel;
    reg [47:0] result;
  begin
    result = input_0 & {48{sel[0]}};
    result = result | (input_1 & {48{sel[1]}});
    result = result | (input_2 & {48{sel[2]}});
    result = result | (input_3 & {48{sel[3]}});
    result = result | (input_4 & {48{sel[4]}});
    MUX1HOT_v_48_5_2 = result;
  end
  endfunction


  function automatic [47:0] MUX1HOT_v_48_8_2;
    input [47:0] input_7;
    input [47:0] input_6;
    input [47:0] input_5;
    input [47:0] input_4;
    input [47:0] input_3;
    input [47:0] input_2;
    input [47:0] input_1;
    input [47:0] input_0;
    input [7:0] sel;
    reg [47:0] result;
  begin
    result = input_0 & {48{sel[0]}};
    result = result | (input_1 & {48{sel[1]}});
    result = result | (input_2 & {48{sel[2]}});
    result = result | (input_3 & {48{sel[3]}});
    result = result | (input_4 & {48{sel[4]}});
    result = result | (input_5 & {48{sel[5]}});
    result = result | (input_6 & {48{sel[6]}});
    result = result | (input_7 & {48{sel[7]}});
    MUX1HOT_v_48_8_2 = result;
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


  function automatic [63:0] MUX1HOT_v_64_4_2;
    input [63:0] input_3;
    input [63:0] input_2;
    input [63:0] input_1;
    input [63:0] input_0;
    input [3:0] sel;
    reg [63:0] result;
  begin
    result = input_0 & {64{sel[0]}};
    result = result | (input_1 & {64{sel[1]}});
    result = result | (input_2 & {64{sel[2]}});
    result = result | (input_3 & {64{sel[3]}});
    MUX1HOT_v_64_4_2 = result;
  end
  endfunction


  function automatic [63:0] MUX1HOT_v_64_5_2;
    input [63:0] input_4;
    input [63:0] input_3;
    input [63:0] input_2;
    input [63:0] input_1;
    input [63:0] input_0;
    input [4:0] sel;
    reg [63:0] result;
  begin
    result = input_0 & {64{sel[0]}};
    result = result | (input_1 & {64{sel[1]}});
    result = result | (input_2 & {64{sel[2]}});
    result = result | (input_3 & {64{sel[3]}});
    result = result | (input_4 & {64{sel[4]}});
    MUX1HOT_v_64_5_2 = result;
  end
  endfunction


  function automatic [63:0] MUX1HOT_v_64_6_2;
    input [63:0] input_5;
    input [63:0] input_4;
    input [63:0] input_3;
    input [63:0] input_2;
    input [63:0] input_1;
    input [63:0] input_0;
    input [5:0] sel;
    reg [63:0] result;
  begin
    result = input_0 & {64{sel[0]}};
    result = result | (input_1 & {64{sel[1]}});
    result = result | (input_2 & {64{sel[2]}});
    result = result | (input_3 & {64{sel[3]}});
    result = result | (input_4 & {64{sel[4]}});
    result = result | (input_5 & {64{sel[5]}});
    MUX1HOT_v_64_6_2 = result;
  end
  endfunction


  function automatic [63:0] MUX1HOT_v_64_7_2;
    input [63:0] input_6;
    input [63:0] input_5;
    input [63:0] input_4;
    input [63:0] input_3;
    input [63:0] input_2;
    input [63:0] input_1;
    input [63:0] input_0;
    input [6:0] sel;
    reg [63:0] result;
  begin
    result = input_0 & {64{sel[0]}};
    result = result | (input_1 & {64{sel[1]}});
    result = result | (input_2 & {64{sel[2]}});
    result = result | (input_3 & {64{sel[3]}});
    result = result | (input_4 & {64{sel[4]}});
    result = result | (input_5 & {64{sel[5]}});
    result = result | (input_6 & {64{sel[6]}});
    MUX1HOT_v_64_7_2 = result;
  end
  endfunction


  function automatic [5:0] MUX1HOT_v_6_6_2;
    input [5:0] input_5;
    input [5:0] input_4;
    input [5:0] input_3;
    input [5:0] input_2;
    input [5:0] input_1;
    input [5:0] input_0;
    input [5:0] sel;
    reg [5:0] result;
  begin
    result = input_0 & {6{sel[0]}};
    result = result | (input_1 & {6{sel[1]}});
    result = result | (input_2 & {6{sel[2]}});
    result = result | (input_3 & {6{sel[3]}});
    result = result | (input_4 & {6{sel[4]}});
    result = result | (input_5 & {6{sel[5]}});
    MUX1HOT_v_6_6_2 = result;
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


  function automatic [123:0] MUX_v_124_2_2;
    input [123:0] input_0;
    input [123:0] input_1;
    input  sel;
    reg [123:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_124_2_2 = result;
  end
  endfunction


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


  function automatic [17:0] MUX_v_18_2_2;
    input [17:0] input_0;
    input [17:0] input_1;
    input  sel;
    reg [17:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_18_2_2 = result;
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


  function automatic [447:0] MUX_v_448_2_2;
    input [447:0] input_0;
    input [447:0] input_1;
    input  sel;
    reg [447:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_448_2_2 = result;
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

endmodule

// ------------------------------------------------------------------
//  Design Unit:    inputUnit
// ------------------------------------------------------------------


module inputUnit_wrap (
  i_clk, i_rst, stream_in_t_val, stream_in_t_rdy, stream_in_t_msg, cmd_in_t_val,
      cmd_in_t_rdy, cmd_in_t_msg, bfu_out_t_val, bfu_out_t_rdy, bfu_out_t_msg, pkt_buf_out_t_val,
      pkt_buf_out_t_rdy, pkt_buf_out_t_msg
);
  input i_clk;
  input i_rst;
  input stream_in_t_val;
  output stream_in_t_rdy;
  input [522:0] stream_in_t_msg;
  input cmd_in_t_val;
  output cmd_in_t_rdy;
  input [78:0] cmd_in_t_msg;
  output bfu_out_t_val;
  input bfu_out_t_rdy;
  output [433:0] bfu_out_t_msg;
  output pkt_buf_out_t_val;
  input pkt_buf_out_t_rdy;
  output [522:0] pkt_buf_out_t_msg;



  // Interconnect Declarations for Component Instantiations 
  inputUnit_inputUnit_inputUnit_main inputUnit_inputUnit_main_inst (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .stream_in_t_val(stream_in_t_val),
      .stream_in_t_rdy(stream_in_t_rdy),
      .stream_in_t_msg(stream_in_t_msg),
      .cmd_in_t_val(cmd_in_t_val),
      .cmd_in_t_rdy(cmd_in_t_rdy),
      .cmd_in_t_msg(cmd_in_t_msg),
      .bfu_out_t_val(bfu_out_t_val),
      .bfu_out_t_rdy(bfu_out_t_rdy),
      .bfu_out_t_msg(bfu_out_t_msg),
      .pkt_buf_out_t_val(pkt_buf_out_t_val),
      .pkt_buf_out_t_rdy(pkt_buf_out_t_rdy),
      .pkt_buf_out_t_msg(pkt_buf_out_t_msg)
    );
endmodule



