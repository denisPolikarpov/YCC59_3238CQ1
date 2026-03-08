`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Polikarpov D. A.
// 
// Create Date: 07.03.2026 14:40:44
// Module Name: YCC59_328CQ1_programm
// Project Name: YCC59_328CQ1
// Target Devices: Zynq, Artix, etc.
// Description: 
// * Used to programm and control YCC59_328CQ1
// Dependencies: 
// *** INTERFACES ***
// * SPI_intr.sv
// * BRAM_memory_intr.sv
// *** COMMON MODULES ***
// * SPI_master.sv
// * BRAM.sv
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

import YCC59_328CQ1_pkg::*;

module YCC59_328CQ1_programm
#(
    parameter int unsigned MAIN_CLK_SIGNAL       = 120000000,
    parameter int unsigned UNLOCK_SEQ_START_ADDR = 'h00,
    parameter int unsigned PROG_DATA_START_ADDR  = 'h04,
    parameter int unsigned TR_EN_OTHER_ADDR      = 'h18,
    parameter int unsigned SELFTEST_START_ADDR   = 'h19
)
(
    input  logic i_clk,
    // TR and EN control signals
    output logic o_TR1,
                 o_TR2,
                 o_EN,
    // Data SPI signals
    output logic o_DEN,
                 o_CLK,
                 o_DIN,
                 o_OE,
    input  logic i_DOUT,
    // Function SPI
    output logic o_FEN,
                 o_FIN
);
    // -----------------------------------------------
    // Defenitions
    localparam int unsigned MEM_WIDTH     = 8;
    localparam int unsigned MEM_DEPTH     = 'h29;
    localparam int unsigned ADDR_WIDTH    = 16;
    localparam int unsigned SPI_SCLK_FREQ = 20000000;
    
    wire reset_addres_counter,
         enable_addres_counter,
         BRAM_read_write;
    wire [ADDR_WIDTH - 1 : 0] beging_address_to_counter;
    start_addr_mux_te start_addr_mux;
    // -----------------------------------------------
    // Interfaces
    SPI_intr SPI_DATA();
    
    assign o_DEN         = SPI_DATA.CSn;
    assign o_CLK         = SPI_DATA.SCLK;
    assign o_DIN         = SPI_DATA.MOSI;
    assign SPI_DATA.MISO = i_DOUT;
    
    SPI_intr SPI_FUNC();
    
    assign o_FEN         = SPI_FUNC.CSn;
    assign o_FIN         = SPI_FUNC.MOSI;
    assign SPI_FUNC.MISO = '0;
    
    BRAM_memory_intr
    #(
        .DATA_WIDTH    (  MEM_WIDTH ),
        .ADDRESS_WIDTH ( ADDR_WIDTH )
    ) 
    BRAM_intr_to_mem
    ( 
        .clk ( i_clk )
    );
    
    BRAM_memory_intr
    #(
        .DATA_WIDTH    (  MEM_WIDTH ),
        .ADDRESS_WIDTH ( ADDR_WIDTH )
    ) 
    BRAM_intr_to_SPI
    ( 
        .clk ( i_clk )
    );

    assign BRAM_intr_to_SPI.rst = '0;
    assign BRAM_intr_to_SPI.en  = '1;
    assign BRAM_intr_to_SPI.we  = '{default : BRAM_read_write};
    // -----------------------------------------------
    // BRAM for options
    BRAM
    #(
        .MEMORY_DEPTH     (      MEM_DEPTH      ),
        .MEMORY_WIDTH     (      MEM_WIDTH      ),
        .TYPE_OF_MEMORY   (  "HIGH_PERFOMANCE"  ),   // "LOW_LATENCY"         // "HIGH_PERFOMANCE"
        .MEMORY_INIT_FILE ( "BRAM_mem_init.mem" )
    )
    BRAM_options
    (
        .mem_bus_a ( BRAM_intr_to_mem ),
        .mem_bus_b ( BRAM_intr_to_SPI )
    );
    // -----------------------------------------------
    // Addres counter
    counter
    #(
        .COUNTER_WIDTH      (     MEM_DEPTH    ),
        .START_VALUE_SOURCE (      "PORT"      ),  // "PARAMETER"  // "PORT"
        .START_VALUE        (         0        ),
        .FINAL_VALUE_SOURCE (    "PARAMETER"   ),  // "PARAMETER"  // "PORT"
        .FINAL_VALUE        ( 2**MEM_DEPTH - 1 )
    )
    addres_counter
    (
        .i_clk,
        .i_reset               (    reset_addres_counter   ),
        .i_enable              (   enable_addres_counter   ),
        .i_start_value         ( beging_address_to_counter ),
        .i_final_value         (             '0            ),
        .o_value               (   BRAM_intr_to_SPI.addr   ),
        .o_final_value_reached (                           )
    );
    
    general_mux
    #(
        .INPUT_WIDTH    ( MEM_DEPTH ),
        .NUM_OF_SIGNALS (     4     )
    )
    mux_start_address
    (
        .i_clk,
        .i_ctrl    (                                     start_addr_mux                                    ),
        .i_signals ( '{SELFTEST_START_ADDR, TR_EN_OTHER_ADDR, PROG_DATA_START_ADDR, UNLOCK_SEQ_START_ADDR} ),
        .o_signal  (                               beging_address_to_counter                               )
    );
    
    // -----------------------------------------------
    // Data SPI
    SPI_master
    #(
        .INPUT_WIDTH    (        8        ),
        .MAIN_CLK_FREQ  ( MAIN_CLK_SIGNAL ),
        .SCLK_FREQ      (  SPI_SCLK_FREQ  ),
        .SCLK_NOT_END   (      "YES"      ),     // "YES"    // "NO"
        .TRANSMIT_ORDER (      "MSB"      )      // "MSB"    // "LSB"
    )
    SPI_master_DATA
    (
        .i_clk,
        // SPI master interface 
        .intr_SPI_master ( SPI_DATA ),
        // Data to transfer
        .i_data  ( BRAM_intr_to_SPI.dout ),
        .i_start ( ),
        // Recieved data
        .o_recieved_data ( BRAM_intr_to_SPI.din ),
        .o_data_valid    ( )
    );
    // -----------------------------------------------
    // SPI fo function line
    SPI_master
    #(
        .INPUT_WIDTH    (        8        ),
        .MAIN_CLK_FREQ  ( MAIN_CLK_SIGNAL ),
        .SCLK_FREQ      (     20000000    ),
        .SCLK_NOT_END   (      "YES"      ),     // "YES"    // "NO"
        .TRANSMIT_ORDER (      "MSB"      )      // "MSB"    // "LSB"
    )
    SPI_master_FUNCTION
    (
        .i_clk,
        // SPI master interface 
        .intr_SPI_master ( SPI_FUNC ),
        // Data to transfer
        .i_data  ( ),
        .i_start ( ),
        // Recieved data
        .o_recieved_data ( ),
        .o_data_valid    ( )
    );
    // -----------------------------------------------
    // Main FSM
    YCC59_328CQ1_main_fsm YCC59_328CQ1_main_fsm_inst
    (
        .i_clk,
        // Report signals
        .i_init              ( BRAM_intr_to_SPI.dout[5 : 5] ),
        .i_data_spi_finished ( ),
        .i_func_spi_finished ( ),
        // Control signals
        .o_mem_start_addr      (     start_addr_mux    ),
        .o_BRAM_read_write     (    BRAM_read_write    ),
        .o_addr_counter_enable ( enable_addres_counter ),
        .o_addr_counter_reset  (  reset_addres_counter ),
        .o_block_ps_access     ( ),
        .o_start_data_spi      ( ),
        .o_start_func_spi      ( )
    );
    
endmodule : YCC59_328CQ1_programm
/*

*/