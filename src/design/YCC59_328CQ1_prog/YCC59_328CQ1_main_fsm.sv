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

module YCC59_328CQ1_main_fsm
(
    input  logic i_clk,
    // Report signals
    input  logic i_init,
                 i_boot_fsm_finished,
    // Control signals
    output logic [1 : 0] o_start_final_addr_mux,
           logic         o_func_spi_seq,
                         o_block_ps_access,
                         o_reset_address_counter,
                         o_start_boot_fsm,
           logic [4 : 0] o_main_fsm_state
);

    enum logic [4 : 0] {
        SLEEP_STATE = 5'b00001,
        BOOT_STATE  = 5'b00010,
        WAIT_STATE  = 5'b00100,
        SELF_TEST   = 5'b01000,
        PROG_STATE  = 5'b10000
    } current_state = SLEEP_STATE;
    
    assign o_main_fsm_state = current_state;
    
    always_ff @(posedge i_clk) begin
        case(current_state) 
            SLEEP_STATE : begin
                if (i_init) begin
                    current_state           <= BOOT_STATE;
                    
                    o_start_final_addr_mux  <= 2'b00;
                    o_func_spi_seq          <= '0;
                    o_block_ps_access       <= '0;
                    o_reset_address_counter <= '1;
                    o_start_boot_fsm        <= '1;
                end
                else begin
                    current_state           <= SLEEP_STATE;
                    
                    o_start_final_addr_mux  <= 2'b10;
                    o_func_spi_seq          <= '0;
                    o_block_ps_access       <= '0;
                    o_reset_address_counter <= '1;
                    o_start_boot_fsm        <= '0;
                end
            end
            BOOT_STATE  : begin
                if (i_boot_fsm_finished) begin
                    current_state           <= WAIT_STATE;
                    
                    o_start_final_addr_mux  <= 2'b10;
                    o_func_spi_seq          <= '0;
                    o_block_ps_access       <= '0;
                    o_reset_address_counter <= '1;
                    o_start_boot_fsm        <= '0;
                end
                else begin
                    current_state           <= BOOT_STATE;
                    
                    o_start_final_addr_mux  <= 2'b00;
                    o_func_spi_seq          <= '0;
                    o_block_ps_access       <= '0;
                    o_reset_address_counter <= '0;
                    o_start_boot_fsm        <= '0;
                end
            end
            WAIT_STATE  : begin
                current_state           <= WAIT_STATE;
                
                o_start_final_addr_mux  <= 2'b10;
                o_func_spi_seq          <= '0;
                o_block_ps_access       <= '0;
                o_reset_address_counter <= '0;
                o_start_boot_fsm        <= '0;
            end
            SELF_TEST : begin
            
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
        .i_boot_fsm_finished ( ),
        // Control signals
        .o_start_final_addr_mux  ( ),
        .o_func_spi_seq          ( ),
        .o_block_ps_access       ( ),
        .o_reset_address_counter ( ),
        .o_start_boot_fsm        ( ),
        .o_main_fsm_state        ( )
    );
*/