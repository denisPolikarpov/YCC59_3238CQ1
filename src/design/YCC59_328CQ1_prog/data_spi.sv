`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Polikarpov D. A.
// 
// Create Date: 08.03.2026 18:26:20
// Design Name: 
// Module Name: data_spi
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module data_spi
#(
    parameter int unsigned MAIN_CLK_SIGNAL = 120000000,
    parameter int unsigned SPI_SCLK_FREQ   = 20000000,
    parameter int unsigned NUM_OF_SCLK     = 5
)
(
    input  logic i_clk,
    // SPI interface
    SPI_intr.master intr_SPI_master,
    // Other signals
    input  logic i_start,
                 i_enable_recieve_data,
           byte  i_data_from_bram,
    output byte  o_data_to_bram,
           logic o_write_data_to_bram,
                 o_enable_read_address_cn,
                 o_enable_write_address_cn,
                 o_trans_finished,
                 o_all_trans_finished
);
    
    // ----------------------------------------------------------------------------------------------
    // Defenition
    wire [25 : 0] data_to_data_spi,
                  data_from_data_spi;
    wire start_detected,
         data_ready,
         start_SPI,
         stop_SPI,
         spi_trans_detected,
         spi_trans_finished,
         spi_trans_active,
         sclk_rising_edge,
         delayed_trans_finished;
    logic start_data_forming,
          reg_all_trans_finished;
    // ----------------------------------------------------------------------------------------------
    // React only on rise edge of i_start
    edge_sense
    #(
        .EDGE_TO_DETECT ( "RISING" ) // "RISING" // "FALLING" // "BOTH"
    )
    rise_edge_of_start_detection
    (
        .i_clk,
        .i_signal (     i_start    ),
        .o_detect ( start_detected )
    );
    // ----------------------------------------------------------------------------------------------
    // Form data in start or on negedge of intr_SPI_master.CSn or spi_trans_finished
    data_to_spi_former data_to_spi_former_isnt
    (
        .i_clk,
        .i_start          (    start_data_forming    ),
        .i_data_from_bram,
        .o_enable_cn      ( o_enable_read_address_cn ),
        .o_data_ready     (        data_ready        ),
        .o_spi_data       (     data_to_data_spi     )
    );
    
    spi_from_data_former spi_from_data_former_inst
    (
        .i_clk,
        .i_start         ( spi_trans_finished & i_enable_recieve_data ),
        .i_data_from_spi (              data_from_data_spi            ),
        .o_enable_cn     (          o_enable_write_address_cn         ),
        .o_data_ready    (             o_write_data_to_bram           ),
        .o_bram_data     (                o_data_to_bram              )
    );
    
    edge_sense
    #(
        .EDGE_TO_DETECT ( "FALLING" ) // "RISING" // "FALLING" // "BOTH"
    )
    fall_edge_of_CSn
    (
        .i_clk,
        .i_signal (  spi_trans_active  ),
        .o_detect ( spi_trans_detected )
    );
    
    always_comb begin
        start_data_forming <= start_detected || (start_SPI && spi_trans_detected);
    end
    // ----------------------------------------------------------------------------------------------
    // SPI start 
    RS_latch 
    #(
        .INITIAL_VALUE ( 1'b0 )
    )
    RS_latch_spi_start
    (
        .i_clk,
        .i_R   (  stop_SPI  ),
        .i_S   ( data_ready ),
        .o_Q   (  start_SPI )
    );
    // ----------------------------------------------------------------------------------------------
    // Count to last transmission
    counter
    #(
        .COUNTER_WIDTH      (      3      ),
        .START_VALUE_SOURCE ( "PARAMETER" ),  // "PARAMETER"  // "PORT"
        .START_VALUE        (      0      ),
        .FINAL_VALUE_SOURCE ( "PARAMETER" ),  // "PARAMETER"  // "PORT"
        .FINAL_VALUE        (      4      )
    )
    counter_inst
    (
        .i_clk,
        .i_reset               (     ~start_SPI     ),
        .i_enable              ( spi_trans_finished ),
        .i_start_value         (         '0         ),
        .i_final_value         (         '0         ),
        .o_value               (                    ),
        .o_final_value_reached (      stop_SPI      )
    );
    // ----------------------------------------------------------------------------------------------
    // Data SPI
    SPI_master
    #(
        .INPUT_WIDTH    (        26       ),
        .MAIN_CLK_FREQ  ( MAIN_CLK_SIGNAL ),
        .SCLK_FREQ      (  SPI_SCLK_FREQ  ),
        .SCLK_NOT_END   (      "YES"      ),     // "YES"    // "NO"
        .TRANSMIT_ORDER (      "MSB"      )      // "MSB"    // "LSB"
    )
    SPI_master_DATA
    (
        .i_clk,
        // SPI master interface 
        .intr_SPI_master,
        // Data to transfer
        .i_data  ( data_to_data_spi ),
        .i_start (     start_SPI    ),
        // Recieved data
        .o_recieved_data   (  data_from_data_spi  ),
        .o_data_valid      (  spi_trans_finished  ),
        .o_transfer_active (   spi_trans_active   )
    );
    // ----------------------------------------------------------------------------------------------
    // Delay fo transfers finished
    edge_sense
    #(
        .EDGE_TO_DETECT ( "RISING" ) // "RISING" // "FALLING" // "BOTH"
    )
    rise_edges_of_sclk
    (
        .i_clk,
        .i_signal ( intr_SPI_master.SCLK ),
        .o_detect (   sclk_rising_edge   )
    );
    
    always_ff @(posedge i_clk) begin
        reg_all_trans_finished <= spi_trans_finished && ~start_SPI;
    end
    
    delay
    #(
        .DELAY_TIME  ( NUM_OF_SCLK - 1 ),
        .INPUT_WIDTH (        1        )
    )
    delay_spi_trans_finished
    (
        .i_clk,
        .i_enable  (    sclk_rising_edge    ),
        .i_signal  ( reg_all_trans_finished ),
        .o_delayed ( delayed_trans_finished )
    );
    
    edge_sense
    #(
        .EDGE_TO_DETECT ( "RISING" ) // "RISING" // "FALLING" // "BOTH"
    )
    rise_edge_of_all_trans_finished
    (
        .i_clk,
        .i_signal ( delayed_trans_finished ),
        .o_detect (  o_all_trans_finished  )
    );
    // ----------------------------------------------------------------------------------------------
    // Assign block
    assign o_trans_finished = spi_trans_finished;
endmodule : data_spi
/*
    data_spi 
    #(
        .MAIN_CLK_SIGNAL ( 120000000 ),
        .SPI_SCLK_FREQ   (  20000000 ),
        .NUM_OF_SCLK     (     5     )
    )
    data_spi_inst
    (
        .i_clk  ( ),
        // SPI interface
        .intr_SPI_master ( ),
        // Other signals
        .i_start                   ( ),
        .i_enable_recieve_data     ( ),
        .i_data_from_bram          ( ),
        .o_data_to_bram            ( ),
        .o_write_data_to_bram      ( ),
        .o_enable_read_address_cn, ( ),
        .o_enable_write_address_cn ( ),
        .o_trans_finished          ( ),
        .o_all_trans_finished      ( )
    );
*/