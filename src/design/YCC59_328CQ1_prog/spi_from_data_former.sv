`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Polikarpov D. A.
// 
// Create Date: 11.03.2026 22:13:05
// Module Name: spi_from_data_former
// Project Name: YCC59_328CQ1
// Target Devices: Zynq, Artix, etc.
// Description: 
// * Form data from SPI to memmory
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module spi_from_data_former
(
    input  logic          i_clk,
                          i_start,
           logic [25 : 0] i_data_from_spi,
    output logic          o_enable_cn,
                          o_data_ready,
           logic [7  : 0] o_bram_data
);
    // ----------------------------------------------------------------------------------------------
    // Defenitions
    logic [25 : 0] input_register = '0;
    logic [4  : 0] SRL_of_enable_sig;
    // ----------------------------------------------------------------------------------------------
    // Input register
    always_ff @(posedge i_clk) begin : input_reg
        if (i_start) begin
            input_register <= i_data_from_spi;
        end
    end : input_reg
    // ----------------------------------------------------------------------------------------------
    // SRL for rise edge detection pulse
    serial_to_parallel
    #(
        .OUTPUT_WIDTH (   5   ),
        .BIT_ORDER    ( "MSB" )   // "MSB"  // "LSB"
    )
    form_signal_enable_for_cn
    (
        .i_clk,
        .i_serial        (      i_start      ),
        .i_reset         (        '0         ),
        .i_enable        (        '1         ),
        .o_parallel_data ( SRL_of_enable_sig )
    );
    // ----------------------------------------------------------------------------------------------
    // Iternal mux logic
    always_ff @(posedge i_clk) begin
        if (SRL_of_enable_sig[0]) begin
            o_bram_data <= input_register[25 : 18];
        end
        if (SRL_of_enable_sig[1]) begin
            o_bram_data <= {input_register[17 : 12], 2'b00};
        end
        if (SRL_of_enable_sig[2]) begin
            o_bram_data <= {input_register[11 :  6], 2'b00};
        end
        if (SRL_of_enable_sig[3]) begin
            o_bram_data <= {input_register[ 5 :  0], 2'b00};
        end
    end
    // ----------------------------------------------------------------------------------------------
    // Assign block
    assign o_data_ready = SRL_of_enable_sig[1] || SRL_of_enable_sig[2] || SRL_of_enable_sig[3] || SRL_of_enable_sig[4];
    assign o_enable_cn  = SRL_of_enable_sig[1] || SRL_of_enable_sig[2] || SRL_of_enable_sig[3] || SRL_of_enable_sig[4];
endmodule : spi_from_data_former
/*
    spi_from_data_former spi_from_data_former_inst
    (
        .i_clk           ( ),
        .i_start         ( ),
        .i_data_from_spi ( ),
        .o_enable_cn     ( ),
        .o_data_ready    ( ),
        .o_bram_data     ( )
    );
*/