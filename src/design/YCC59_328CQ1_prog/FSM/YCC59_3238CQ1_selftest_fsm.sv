`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Polikarpov D. A.
// 
// Create Date: 11.03.2026 21:00:59
// Module Name: YCC59_3238CQ1_selftest_fsm
// Project Name: YCC59_3238CQ1
// Target Devices: Zynq, Artix, etc.
// Description: 
// * FSM which controll selftest procedure of YCC59_328CQ1
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module YCC59_3238CQ1_selftest_fsm
(
    input  logic i_clk,
    // Report signals
    input  logic i_start_selftest_fsm,
                 i_all_data_trans_finished,
    // Controll signals
    output logic         o_spi_data_init,
                         o_OE,
                         o_bram_write,
                         o_selftest_fsm_finished,
           logic [2 : 0] o_selftest_fsm_state
);
    // ----------------------------------------------------------------------------------------------
    // Defenition
    enum logic [2 : 0] {
        IDLE_STATE                = 3'b001,
        SPI_TEST_DATA_WRITE_STATE = 3'b010,
        SPI_TEST_DATA_READ_STATE  = 3'b100
    } current_state = IDLE_STATE;
    
    assign o_selftest_fsm_state = current_state;
    
    wire delayed_all_data_trans_finished;
    // ----------------------------------------------------------------------------------------------
    // FSM
    delay
    #(
        .DELAY_TIME  ( 6 ),
        .INPUT_WIDTH ( 1 )
    )
    delay_spi_trans_finished
    (
        .i_clk,
        .i_enable  ( '1 ),
        .i_signal  (    i_all_data_trans_finished    ),
        .o_delayed ( delayed_all_data_trans_finished )
    );
    always_ff @(posedge i_clk) begin
        unique case(current_state)
            IDLE_STATE : begin
                if (i_start_selftest_fsm) begin
                    current_state           <= SPI_TEST_DATA_WRITE_STATE;
                    
                    o_spi_data_init         <= '1;
                    o_OE                    <= '1;
                    o_bram_write            <= '0;
                    o_selftest_fsm_finished <= '0;
                end
                else begin
                    current_state           <= IDLE_STATE;
                    
                    o_spi_data_init         <= '0;
                    o_OE                    <= '1;
                    o_bram_write            <= '0;
                    o_selftest_fsm_finished <= '0;
                end
            end
            SPI_TEST_DATA_WRITE_STATE : begin
                if (delayed_all_data_trans_finished) begin
                    current_state           <= SPI_TEST_DATA_READ_STATE;
                    
                    o_spi_data_init         <= '1;
                    o_OE                    <= '0;
                    o_bram_write            <= '1;
                    o_selftest_fsm_finished <= '0;
                end
                else begin
                    current_state           <= SPI_TEST_DATA_WRITE_STATE;
                    
                    o_spi_data_init         <= '0;
                    o_OE                    <= '1;
                    o_bram_write            <= '0;
                    o_selftest_fsm_finished <= '0;
                end
            end
            SPI_TEST_DATA_READ_STATE : begin
                if (delayed_all_data_trans_finished) begin
                    current_state           <= IDLE_STATE;
                    
                    o_spi_data_init         <= '0;
                    o_OE                    <= '1;
                    o_bram_write            <= '0;
                    o_selftest_fsm_finished <= '1;
                end
                else begin
                    current_state           <= SPI_TEST_DATA_READ_STATE;
                    
                    o_spi_data_init         <= '0;
                    o_OE                    <= '0;
                    o_bram_write            <= '1;
                    o_selftest_fsm_finished <= '0;
                end
            end
        endcase
    end
endmodule : YCC59_3238CQ1_selftest_fsm
/*
    YCC59_3238CQ1_selftest_fsm YCC59_3238CQ1_selftest_fsm_inst
    (
        .i_clk ( ),
        // Report signals
        .i_start_selftest_fsm      ( ),
        .i_all_data_trans_finished ( ),
        // Controll signals
        .o_spi_data_init         ( ),
        .o_OE                    ( ),
        .o_bram_write            ( ),
        .o_selftest_fsm_finished ( ),
        .o_selftest_fsm_state    ( )
    );
*/