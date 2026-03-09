`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:  Polikarpov D. A.
// 
// Create Date: 09.03.2026 20:03:01
// Module Name: func_spi
// Project Name: YCC59_328CQ1
// Target Devices: Zynq, Artix, etc.
// Description: 
// * Module which incapsulates FUNC line of YCC59_328CQ1
// Dependencies: 
// * general_mux.sv
// * edge_sense.sv
// * delay.sv
// * SPI_master.sv
// Revision:
// Revision 0.01 - File Created
//          0.02 - First version
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module func_spi
#(
    parameter logic [11 : 0] BOOT_FUNC_SEQ   = 12'h380,
    parameter logic [11 : 0] LATCH_TRANNS    = 12'h11F,
    parameter int unsigned   NUM_OF_SCLK     = 5,
    parameter int unsigned   MAIN_CLK_SIGNAL = 120000000,
    parameter int unsigned   SPI_SCLK_FREQ   = 20000000
)
(
    input logic i_clk,
    // SPI Interface
    SPI_intr.master intr_SPI_master,
    // Other signals
    input  logic i_start,
                 i_seq_ctrl,
    output logic o_trans_finished
);
    // -----------------------------------------------
    // Defenitions
    wire [11 : 0] func_seq_to_trans;
    wire start_func_trans_delay,
         falling_edge_of_SCLK;
    // -----------------------------------------------
    // Sequance to transmit mux
    general_mux
    #(
        .INPUT_WIDTH    ( $bits(LATCH_TRANNS) ),
        .NUM_OF_SIGNALS (          2          ),
        .SYNC_OR_ASYNC  (       "ASYNC"       )  // "SYNC"   // "ASYNC"
    )
    func_seq_mux
    (
        .i_clk, 
        .i_ctrl    (           i_seq_ctrl           ),
        .i_signals ( '{LATCH_TRANNS, BOOT_FUNC_SEQ} ),
        .o_signal  (        func_seq_to_trans       )
    );
    // -----------------------------------------------
    // Delay start for NUM_OF_SCLK clk cycles
    edge_sense
    #(
        .EDGE_TO_DETECT ( "RISING" ) // "RISING" // "FALLING" // "BOTH"
    )
    edge_sense_inst
    (
        .i_clk,
        .i_signal ( intr_SPI_master.SCLK ),
        .o_detect ( falling_edge_of_SCLK )
    );
    
    delay
    #(
        .DELAY_TIME  ( NUM_OF_SCLK ),
        .INPUT_WIDTH (      1      )
    )
    delay_inst
    (
        .i_clk,
        .i_enable  (  falling_edge_of_SCLK  ),
        .i_signal  (         i_start        ),
        .o_delayed ( start_func_trans_delay )
    );
    // -----------------------------------------------
    // Sequance to transmit mux
    SPI_master
    #(
        .INPUT_WIDTH    ( $bits(LATCH_TRANNS) ),
        .MAIN_CLK_FREQ  (   MAIN_CLK_SIGNAL   ),
        .SCLK_FREQ      (    SPI_SCLK_FREQ    ),
        .SCLK_NOT_END   (        "YES"        ),     // "YES"    // "NO"
        .TRANSMIT_ORDER (        "MSB"        )      // "MSB"    // "LSB"
    )
    SPI_function
    (
        .i_clk,
        // SPI master interface 
        .intr_SPI_master,
        // Data to transfer
        .i_data  (    func_seq_to_trans   ),
        .i_start ( start_func_trans_delay ),
        // Recieved data
        .o_recieved_data   (                  ),
        .o_data_valid      ( o_trans_finished ),
        .o_transfer_active (                  )
    );
endmodule : func_spi
/*
    func_spi
    #(
        .BOOT_FUNC_SEQ   (  12'h380  ),
        .LATCH_TRANNS    (  12'h11F  ),
        .NUM_OF_SCLK     (     5     ),
        .MAIN_CLK_SIGNAL ( 120000000 ),
        .SPI_SCLK_FREQ   (  20000000 )
    )
    func_spi_inst
    (
        .i_clk ( ),
        // SPI Interface
        .intr_SPI_master ( ),
        // Other signals
        .i_start          ( ),
        .i_seq_ctrl       ( ),
        .o_trans_finished ( )
    );
*/