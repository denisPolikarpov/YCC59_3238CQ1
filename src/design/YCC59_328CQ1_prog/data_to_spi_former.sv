`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Polikarpov D. A.
// 
// Create Date: 08.03.2026 15:55:36
// Module Name: data_to_spi_former
// Project Name: YCC59_328CQ1
// Target Devices: Zynq, Artix, etc.
// Description: 
// * Form data for SPI
// Dependencies: 
// * edge_sense.sv
// * serial_to_parallel.sv
// Revision:
// Revision 0.01 - File Created
//          0.02 - First version
// Additional Comments:
// Read for address in increment order and form 26-bit vector to send
//////////////////////////////////////////////////////////////////////////////////


module data_to_spi_former
(
    input  logic          i_clk,
                          i_start,
           logic [ 7 : 0] i_data_from_bram,
    output logic          o_enable_cn,
                          o_data_ready,
           logic [25 : 0] o_spi_data
);
    // -----------------------------------------------
    // Defenitions
    logic [25 : 0] iternal_register = '0;
    logic [5  : 0] SRL_of_enable_sig;
    genvar register_part;
    // -----------------------------------------------
    // SRL for rise edge detection pulse
    serial_to_parallel
    #(
        .OUTPUT_WIDTH (   6   ),
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
    // -----------------------------------------------
    // Iternal register logic
    for (register_part = 1; register_part < 5; register_part++) begin
        always_ff @(posedge i_clk) begin : iternal_register_logic
            if (register_part == 1) begin
                if (SRL_of_enable_sig[register_part]) begin
                    iternal_register[25 : 18] <= i_data_from_bram;
                end
            end
            else begin
                if (SRL_of_enable_sig[register_part]) begin
                    iternal_register[17 - 6*(register_part - 2) : 12 - 6*(register_part - 2)] <= i_data_from_bram[7 : 2];
                end
            end
        end : iternal_register_logic
    end
    // -----------------------------------------------
    // Assigns
    assign o_spi_data   = iternal_register;
    assign o_data_ready = SRL_of_enable_sig[5];
    
    assign o_enable_cn  = SRL_of_enable_sig[0] || SRL_of_enable_sig[1] || SRL_of_enable_sig[2];
endmodule : data_to_spi_former
/*
    data_to_spi_former data_to_spi_former_isnt
    (
        .i_clk            ( ),
        .i_start          ( ),
        .i_data_from_bram ( ),
        .o_enable_cn      ( ),
        .o_data_ready     ( ),
        .o_spi_data       ( )
    );
*/