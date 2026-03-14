`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Polikarpov D. A.
// 
// Create Date: 03/13/2026 11:29:18 AM
// Module Name: bd_wrapper
// Project Name: YCC59_328CQ1
// Target Devices: Zynq, Artix, etc.
// Description: 
// * Wrapper of erilog bd to systemverilog types
// Dependencies: 
// design_1_wrapper.sv
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module bd_wrapper
(
     output logic o_clk,
     BRAM_memory_intr.nonMem intr_from_axi_to_bram,
     DDRx_intr.ports         ddr,
     FIXEDIO_intr.ports      fixed_io,
     input  logic         i_CLK,
                          i_DEN,
                          i_DIN,
                          i_DOUT,
                          i_EN,
                          i_FEN,
                          i_FIN,
                          i_OE,
                          i_TR1,
                          i_TR2,
                          i_boot_prog_fsm_state,
                          i_main_fsm_state,
                          i_selftest_fsm_state,
            logic [7 : 0] i_addrb,
                          i_dinb,
                          i_dout_bram,
            logic         i_web
);
    // ----------------------------------------------------------------------------------------------
    // Defenitions
    wire bram_clk;
    // ----------------------------------------------------------------------------------------------
    // Interfaces
//    BRAM_memory_intr
//    #(
//        .DATA_WIDTH    ( 32 ),
//        .ADDRESS_WIDTH ( 12 )
//    ) 
//    BRAM_memory_intr_inst
//    ( 
//        .clk ( bram_clk )
//    );
    
//    assign BRAM_memory_intr_inst.addr = intr_from_axi_to_bram.addr;
//    assign BRAM_memory_intr_inst.din  = intr_from_axi_to_bram.din;
//    assign intr_from_axi_to_bram.dout = BRAM_memory_intr_inst.dout;
//    assign BRAM_memory_intr_inst.en   = intr_from_axi_to_bram.en ;
//    assign BRAM_memory_intr_inst.rst  = intr_from_axi_to_bram.rst;
    // ----------------------------------------------------------------------------------------------
    // Block design auto wrapper
    design_1_wrapper design_1_wrapper_inst
    (
        // BRAM interface
        .BRAM_PORTA_addr ( intr_from_axi_to_bram.addr ),
        .BRAM_PORTA_clk  (          bram_clk          ),
        .BRAM_PORTA_din  ( intr_from_axi_to_bram.din  ),
        .BRAM_PORTA_dout ( intr_from_axi_to_bram.dout ),
        .BRAM_PORTA_en   (  intr_from_axi_to_bram.en  ),
        .BRAM_PORTA_rst  (  intr_from_axi_to_bram.rst ),
        .BRAM_PORTA_we   (  intr_from_axi_to_bram.we  ),
        // DDR interface
        .DDR_addr        (   ddr.Addr   ),
        .DDR_ba          ( ddr.BankAddr ),
        .DDR_cas_n       (   ddr.CAS_n  ),
        .DDR_ck_n        (   ddr.Clk_n  ),
        .DDR_ck_p        (    ddr.Clk   ),
        .DDR_cke         (    ddr.CKE   ),
        .DDR_cs_n        (   ddr.CS_n   ),
        .DDR_dm          (    ddr.DM    ),
        .DDR_dq          (    ddr.DQ    ),
        .DDR_dqs_n       (   ddr.DQS_n  ),
        .DDR_dqs_p       (    ddr.DQS   ),
        .DDR_odt         (    ddr.ODT   ),
        .DDR_ras_n       (   ddr.RAS_n  ),
        .DDR_reset_n     (   ddr.DRSTB  ),
        .DDR_we_n        (    ddr.WEB   ),
        // FIXED IO interface
        .FIXED_IO_ddr_vrn  (  fixed_io.DDR_VRN ),
        .FIXED_IO_ddr_vrp  (  fixed_io.DDR_VRP ),
        .FIXED_IO_mio      (    fixed_io.MIO   ),
        .FIXED_IO_ps_clk   (  fixed_io.PS_CLK  ),
        .FIXED_IO_ps_porb  (  fixed_io.PS_PORB ),
        .FIXED_IO_ps_srstb ( fixed_io.PS_SRSTB ),
        // CLK
        .o_clk,
        // Port of YCC59_328CQ1
        .i_CLK,
        .i_DEN,
        .i_DIN,
        .i_DOUT,
        .i_EN,
        .i_FEN,
        .i_FIN,
        .i_OE,
        .i_TR1,
        .i_TR2,
        .i_addrb,
        .i_dinb, 
        .i_dout_bram,
        .i_web,   
        // ILA exlusive signals
        .i_boot_prog_fsm_state,
        .i_main_fsm_state,
        .i_selftest_fsm_state
    );
endmodule : bd_wrapper
/*
    bd_wrapper bd_wrapper_inst
    (
         .o_clk                 ( ),
         .intr_from_axi_to_bram ( ),
         .ddr                   ( ),
         .fixed_io              ( ),
         .i_addrb               ( ),   
         .i_dinb                ( ),    
         .i_dout_bram           ( ),
         .i_web                 ( )
    );
*/