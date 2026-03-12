`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Polikarpov D. A.
// 
// Create Date: 11.03.2026 17:40:23
// Module Name: YCC59_3238CQ1_fsm
// Project Name: YCC59_3238CQ1
// Target Devices: Zynq, Artix, etc.
// Description: 
// * FSM of YCC59_328CQ1_programm
// Dependencies: 
// * YCC59_328CQ1_main_fsm.sv
// * YCC59_328CQ1_prog_boot_fsm.sv
// * YCC59_328CQ1_selftest_fsm.sv
// Revision:
// Revision 0.01 - File Created
//          0.02 - Boot state is done
//          0.03 - Prog state is done
//          0.04 - Selftest state is done
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module YCC59_3238CQ1_fsm
(
    input logic i_clk,
    // Init YCC59_328CQ1_programm
    input logic i_init,
    // Start programming of YCC59_328CQ1
    input logic i_programm,
    // Start selftest of YCC59_328CQ1
    input logic i_begin_selftest,
    // DATA and FUNC SPI finished transmission signals
    input logic i_all_data_trans_finished,
                i_func_trans_finished,
    // Control output sequance
    output logic [1 : 0] o_start_final_addr_mux,
           logic         o_func_spi_seq,
                         o_block_ps_access,
                         o_reset_address_counter,
                         o_OE,
                         o_bram_write,
           wor           o_spi_data_init,
                         o_spi_func_init,
    // Report of current state
    output logic [4 : 0] o_main_fsm_state,
           logic [2 : 0] o_boot_prog_fsm_state,
           logic [2 : 0] o_selftest_fsm_state
);
    // ----------------------------------------------------------------------------------------------
    // Alias block
    alias i_boot_prog_fsm_finished = o_boot_prog_fsm_finished;
    alias i_start_boot_prog_fsm    = o_start_boot_prog_fsm;
    alias i_selftest_fsm_finished  = o_selftest_fsm_finished;
    alias i_start_selftest_fsm     = o_start_selftest_fsm;
    // ----------------------------------------------------------------------------------------------
    YCC59_328CQ1_main_fsm YCC59_328CQ1_main_fsm_inst ( .* );
    // ----------------------------------------------------------------------------------------------
    // BOOT and PROG FSM
    YCC59_328CQ1_boot_prog_fsm YCC59_328CQ1_boot_prog_fsm_inst ( .* );
    // ----------------------------------------------------------------------------------------------
    // SELFTEST FSM
    YCC59_3238CQ1_selftest_fsm YCC59_3238CQ1_selftest_fsm_inst ( .* );
endmodule : YCC59_3238CQ1_fsm
/*
    YCC59_3238CQ1_fsm YCC59_3238CQ1_fsm_inst
    (
        .i_clk ( ),
        // Init YCC59_328CQ1_programm
        .i_init ( ),
        // Start programming of YCC59_328CQ1
        .i_programm ( ),
        // Start selftest of YCC59_328CQ1
        .i_begin_selftest ( ),
        // DATA and FUNC SPI finished transmission signals
        .i_all_data_trans_finished ( ),
        .i_func_trans_finished     ( ),
        // Control output sequance
        .o_start_final_addr_mux  ( ),
        .o_func_spi_seq          ( ),
        .o_block_ps_access       ( ),
        .o_reset_address_counter ( ),
        .o_OE                    ( ),
        .o_bram_write            ( ),
        .o_spi_data_init         ( ),
        .o_spi_func_init         ( ),
        // Report of current state
        .o_main_fsm_state        ( ),    
        .o_boot_prog_fsm_state   ( ),
        .o_selftest_fsm_state    ( )
    );
*/