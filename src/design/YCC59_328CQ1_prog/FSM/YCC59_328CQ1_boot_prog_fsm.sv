`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Polikarpov D. A.
// 
// Create Date: 09.03.2026 21:13:19
// Module Name: YCC59_328CQ1_boot_prog_fsm
// Project Name: YCC59_328CQ1
// Target Devices: Zynq, Artix, etc.
// Description: 
// * FSM which controll programming attenuation and phase values of YCC59_328CQ1
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module YCC59_328CQ1_boot_prog_fsm
(
    input  logic i_clk,
    // Report signals
    input  logic i_start_boot_prog_fsm,
                 i_all_data_trans_finished,
                 i_func_trans_finished,
    // Controll signals
    output logic         o_spi_data_init,
                         o_spi_func_init,
                         o_boot_prog_fsm_finished,
           logic [2 : 0] o_boot_prog_fsm_state
);
    // ----------------------------------------------------------------------------------------------
    // Defenition
    enum logic [2 : 0] {
        IDLE_STATE     = 3'b001,
        SPI_DATA_STATE = 3'b010,
        SPI_FUNC_STATE = 3'b100
    } current_state = IDLE_STATE;
    
    assign o_boot_prog_fsm_state = current_state;
    // ----------------------------------------------------------------------------------------------
    // FSM
    always_ff @(posedge i_clk) begin
        unique case(current_state)
            IDLE_STATE : begin
                if (i_start_boot_prog_fsm) begin
                    current_state            <= SPI_DATA_STATE;
                   
                    o_spi_data_init          <= '1;
                    o_spi_func_init          <= '0;
                    o_boot_prog_fsm_finished <= '0;
                end
                else begin
                    current_state            <= IDLE_STATE;
                   
                    o_spi_data_init          <= '0;
                    o_spi_func_init          <= '0;
                    o_boot_prog_fsm_finished <= '0;
                end
            end
            SPI_DATA_STATE : begin
                if (i_all_data_trans_finished) begin
                    current_state            <= SPI_FUNC_STATE;
                   
                    o_spi_data_init          <= '0;
                    o_spi_func_init          <= '1;
                    o_boot_prog_fsm_finished <= '0;
                end
                else begin
                    current_state            <= SPI_DATA_STATE;
                   
                    o_spi_data_init          <= '0;
                    o_spi_func_init          <= '0;
                    o_boot_prog_fsm_finished <= '0;
                end
            end
            SPI_FUNC_STATE : begin 
                if (i_func_trans_finished) begin
                    current_state            <= IDLE_STATE;
                   
                    o_spi_data_init          <= '0;
                    o_spi_func_init          <= '0;
                    o_boot_prog_fsm_finished <= '1;
                end
                else begin
                    current_state            <= SPI_FUNC_STATE;
                   
                    o_spi_data_init          <= '0;
                    o_spi_func_init          <= '0;
                    o_boot_prog_fsm_finished <= '0;
                end
            end
        endcase
    end
endmodule : YCC59_328CQ1_boot_prog_fsm
/*
    YCC59_328CQ1_boot_prog_fsm YCC59_328CQ1_boot_prog_fsm_inst
    (
        .i_clk ( ),
        // Report signals
        .i_start_boot_prog_fsm     ( ),
        .i_all_data_trans_finished ( ),
        .i_func_trans_finished     ( ),
        // Controll signals
        .o_spi_data_init          ( ),
        .o_spi_func_init          ( ),
        .o_boot_prog_fsm_finished ( ),
        .o_prog_fsm_state         ( )
    );
*/