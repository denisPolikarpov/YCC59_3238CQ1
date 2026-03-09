`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Polikarpov D. A.
// 
// Create Date: 08.03.2026 16:55:28
// Module Name: YCC59_328CQ1_boot_fsm
// Project Name: YCC59_328CQ1
// Target Devices: Zynq, Artix, etc.
// Description: 
// * FSM which controll first stage of programming YCC59_328CQ1
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// * First step is to read boot constant from memmory and form spi data vector
// * Second step is to transmitte previously formed vector five times
// * Third step is to 
//////////////////////////////////////////////////////////////////////////////////


module YCC59_328CQ1_boot_fsm
(
    input  logic i_clk,
    // Report signals
    input  logic i_start_boot_fsm,
                 i_all_data_trans_finished,
                 i_func_trans_finished,
    // Controll signals
    output logic         o_spi_data_init,
                         o_spi_func_init,
                         o_boot_fsm_finished,
           logic [3 : 0] o_boot_fsm_state
);
    // -----------------------------------------------
    // Defenition
    enum logic [3 : 0] {
        IDLE_STATE         = 4'b0001,
        SPI_DATA_STATE     = 4'b0010,
        SPI_FUNC_STATE     = 4'b0100,
        FINAL_STATE        = 4'b1000
    } current_state = IDLE_STATE;
    
    assign o_boot_fsm_state = current_state;
    // -----------------------------------------------
    // FSM
    always_ff @(posedge i_clk) begin
        unique case(current_state)
            IDLE_STATE : begin
                if (i_start_boot_fsm) begin
                    current_state       <= SPI_DATA_STATE;
                   
                    o_spi_data_init     <= '1;
                    o_spi_func_init     <= '0;
                    o_boot_fsm_finished <= '0;
                end
                else begin
                    current_state       <= IDLE_STATE;
                   
                    o_spi_data_init     <= '0;
                    o_spi_func_init     <= '0;
                    o_boot_fsm_finished <= '0;
                end
            end
            SPI_DATA_STATE : begin
                if (i_all_data_trans_finished) begin
                    current_state       <= SPI_FUNC_STATE;
                   
                    o_spi_data_init     <= '0;
                    o_spi_func_init     <= '1;
                    o_boot_fsm_finished <= '0;
                end
                else begin
                    current_state       <= SPI_DATA_STATE;
                   
                    o_spi_data_init     <= '0;
                    o_spi_func_init     <= '0;
                    o_boot_fsm_finished <= '0;
                end
            end
            SPI_FUNC_STATE : begin 
                if (i_func_trans_finished) begin
                    current_state       <= FINAL_STATE;
                   
                    o_spi_data_init     <= '0;
                    o_spi_func_init     <= '0;
                    o_boot_fsm_finished <= '1;
                end
                else begin
                    current_state       <= SPI_FUNC_STATE;
                   
                    o_spi_data_init     <= '0;
                    o_spi_func_init     <= '0;
                    o_boot_fsm_finished <= '0;
                end
            end
            FINAL_STATE : begin
                current_state       <= FINAL_STATE;
                
                o_spi_data_init     <= '0;
                o_spi_func_init     <= '0;
                o_boot_fsm_finished <= '0;
            end
        endcase
    end
    
endmodule : YCC59_328CQ1_boot_fsm
/*
    YCC59_328CQ1_boot_fsm YCC59_328CQ1_boot_fsm_inst
    (
        .i_clk ( ),
        // Report signals
        .i_start_boot_fsm          ( ),
        .i_all_data_trans_finished ( ),
        .i_func_trans_finished     ( ),
        // Controll signals
        .o_spi_data_init     ( ),
        .o_spi_func_init     ( ),
        .o_boot_fsm_finished ( ),
        .o_boot_fsm_state    ( )
    );
*/