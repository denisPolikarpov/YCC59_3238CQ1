`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Polikarpov D. A.
// 
// Create Date: 07.03.2026 23:04:58
// Module Name: YCC59_328CQ1_main_fsm
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

import YCC59_328CQ1_pkg::*;

module YCC59_328CQ1_main_fsm
(
    input  logic i_clk,
    // Report signals
    input  logic i_init,
                 i_data_spi_finished,
                 i_func_spi_finished,
    // Control signals
    output start_addr_mux_te o_mem_start_addr,
           logic             o_BRAM_read_write,
                             o_addr_counter_enable,
                             o_addr_counter_reset,
                             o_block_ps_access,
                             o_start_data_spi,
                             o_start_func_spi
);

    enum logic [4 : 0] {
        SLEEP_STATE = 5'b00001,
        BOOT_STATE  = 5'b00010,
        SELF_TEST   = 5'b00100,
        WAIT_STATE  = 5'b01000,
        PROG_STATE  = 5'b10000
    } current_state = SLEEP_STATE;
    
    always_ff @(posedge i_clk) begin
        case(current_state) 
            SLEEP_STATE : begin
                if (i_init) begin
                    current_state         <= BOOT_STATE;
                    
                    o_mem_start_addr      <= UNLOCK_SEQ;
                    o_BRAM_read_write     <= '0;
                    o_addr_counter_enable <= '0;
                    o_addr_counter_reset  <= '0;
                    o_block_ps_access     <= '0;
                    o_start_data_spi      <= '0;
                    o_start_func_spi      <= '0;
                end
                else begin
                    current_state         <= SLEEP_STATE;
                    
                    o_mem_start_addr      <= TR_EN_OTHER;
                    o_BRAM_read_write     <= '0;
                    o_addr_counter_enable <= '0;
                    o_addr_counter_reset  <= '1;
                    o_block_ps_access     <= '0;
                    o_start_data_spi      <= '0;
                    o_start_func_spi      <= '0;
                end
            end
            BOOT_STATE  : begin
            end
            SELF_TEST   : begin
            end
            WAIT_STATE  : begin
            end
            PROG_STATE  : begin
            end
        endcase
    end
    
endmodule : YCC59_328CQ1_main_fsm
/*
    YCC59_328CQ1_main_fsm YCC59_328CQ1_main_fsm_inst
    (
        .i_clk ( ),
        // Report signals
        .i_init              ( ),
        .i_data_spi_finished ( ),
        .i_func_spi_finished ( ),
        // Control signals
        .o_mem_start_addr      ( ),
        .o_BRAM_read_write     ( ),
        .o_addr_counter_enable ( ),
        .o_addr_counter_reset  ( ),
        .o_block_ps_access     ( ),
        .o_start_data_spi      ( ),
        .o_start_func_spi      ( )
    );
*/