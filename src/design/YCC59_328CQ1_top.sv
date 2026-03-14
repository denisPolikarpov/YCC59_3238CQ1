`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Polikarpov D. A.
// 
// Create Date: 07.03.2026 14:40:44
// Module Name: YCC59_328CQ1_top
// Project Name: YCC59_328CQ1
// Target Devices: Zynq, Artix, etc.
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module YCC59_328CQ1_top
(
    DDRx_intr.ports    ddr,
    FIXEDIO_intr.ports fixed_io,
    // YCC59_328CQ1 signals
    output logic o_TR1,
                 o_TR2,
                 o_EN,
    // Data SPI signals
    output logic o_DEN,
                 o_CLK,
                 o_DIN,
                 o_OE,
    //input  logic i_DOUT,
    // Function SPI
    output logic o_FEN,
                 o_FIN
);
    // ----------------------------------------------------------------------------------------------
    // Defenitions
    alias i_clk = o_clk;
    
    BRAM_memory_intr
    #(
        .DATA_WIDTH    (  8 ),
        .ADDRESS_WIDTH ( 16 )
    ) 
    BRAM_intr_to_SPI
    ( 
        .clk ( i_clk )
    );
    // ----------------------------------------------------------------------------------------------
    // Programming module
    YCC59_328CQ1_programm
    #(
        .MAIN_CLK_SIGNAL       ( 120000000 ),
        .UNLOCK_SEQ_START_ADDR (    'h00   ),
        .PROG_DATA_START_ADDR  (    'h04   ),
        .TR_EN_OTHER_ADDR      (    'h18   ),
        .SELFTEST_START_ADDR   (    'h19   ),
        .MEM_FINAL_ADDRESS     (    'h40   )
    )
    YCC59_328CQ1_programm_inst
    (
        .*,
        .i_DOUT ( '1 ),
        // BRAM interface to AXI
        .intr_to_bram ( BRAM_intr_to_SPI )
    );
    // ----------------------------------------------------------------------------------------------
    // Block design wrapper
    alias i_boot_prog_fsm_state = o_boot_prog_fsm_state;
    alias i_main_fsm_state      = o_main_fsm_state;
    alias i_selftest_fsm_state  = o_selftest_fsm_state;
    alias i_addrb     = o_addr;
    alias i_dinb      = o_din;
    alias i_dout_bram = o_dout;
    alias i_web       = o_we;
    
    bd_wrapper bd_wrapper_inst
    (
         .*,
         .intr_from_axi_to_bram ( BRAM_intr_to_SPI ),
         .i_CLK ( o_CLK ),                
         .i_DEN ( o_DEN ),                
         .i_DIN ( o_DIN ),                
         .i_DOUT( '1 ),               
         .i_EN  (  o_EN ),                 
         .i_FEN ( o_FEN ),                
         .i_FIN ( o_FIN ),                
         .i_OE  (  o_OE ),                 
         .i_TR1 ( o_TR1 ),                
         .i_TR2 ( o_TR2 ),                
         .i_boot_prog_fsm_state,
         .i_main_fsm_state,     
         .i_selftest_fsm_state,
         .i_addrb,   
         .i_dinb,    
         .i_dout_bram,
         .i_web      
    );
    
endmodule : YCC59_328CQ1_top
