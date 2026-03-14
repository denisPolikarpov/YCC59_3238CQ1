`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Polikarpov D. A.
// 
// Create Date: 11.03.2026 18:01:54
// Module Name: address_counter
// Project Name: YCC59_328CQ1
// Target Devices: Zynq, Artix, etc.
// Description: 
// * Address counter for YCC59_328CQ1_programm
// Dependencies: 
// * counter.sv
// * general_mux.sv
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module address_counter
#(
    parameter int unsigned ADDR_WIDTH            = 8,
    parameter int unsigned UNLOCK_SEQ_START_ADDR = 'h00,
    parameter int unsigned PROG_DATA_START_ADDR  = 'h04,
    parameter int unsigned TR_EN_OTHER_ADDR      = 'h18,
    parameter int unsigned SELFTEST_START_ADDR   = 'h19,
    parameter int unsigned MEM_FINAL_ADDRESS     = 'h2C
)
(
    input  logic                      i_clk,
                                      i_reset,
                                      i_enable_switch,
                                      i_enable_for_read,
                                      i_enable_for_write,
           logic [1              : 0] i_mem_space_mux,
    output logic [ADDR_WIDTH - 1 : 0] o_address_to_memmory
);
    // ----------------------------------------------------------------------------------------------
    // Declarations
    localparam logic[ADDR_WIDTH - 1 : 0] START_ADDRESS_ARRAY [3 : 0] = 
        '{SELFTEST_START_ADDR, TR_EN_OTHER_ADDR, PROG_DATA_START_ADDR, UNLOCK_SEQ_START_ADDR};
    localparam logic[ADDR_WIDTH - 1 : 0] FINAL_ADDRESS_ARRAY [3 : 0] = 
        '{MEM_FINAL_ADDRESS, TR_EN_OTHER_ADDR, TR_EN_OTHER_ADDR - 1'b1, PROG_DATA_START_ADDR - 1'b1};
    wire [ADDR_WIDTH - 1 : 0] start_address,
                              final_address;
    wire enable_counter;
    // ----------------------------------------------------------------------------------------------
    // Counter which counts in constrained space
    counter
    #(
        .COUNTER_WIDTH      ( ADDR_WIDTH ),
        .START_VALUE_SOURCE (   "PORT"   ),  // "PARAMETER"  // "PORT"
        .START_VALUE        (      0     ),
        .FINAL_VALUE_SOURCE (   "PORT"   ),  // "PARAMETER"  // "PORT"
        .FINAL_VALUE        (  2**16 - 1 )
    )
    counter_in_address_counter
    (
        .*,
        .i_enable              (     enable_counter   ),
        .i_start_value         (     start_address    ),
        .i_final_value         (     final_address    ),
        .o_value               ( o_address_to_memmory ),
        .o_final_value_reached ( )
    );
    // ----------------------------------------------------------------------------------------------
    // Start address in memory space mux
    general_mux
    #(
        .INPUT_WIDTH    ( ADDR_WIDTH ),
        .NUM_OF_SIGNALS (      4     ),
        .SYNC_OR_ASYNC  (   "ASYNC"  )  // "SYNC"   // "ASYNC"
    )
    start_adress_mux
    (
        .*,
        .i_ctrl    (   i_mem_space_mux   ),
        .i_signals ( START_ADDRESS_ARRAY ),
        .o_signal  (    start_address    )
    );
    // ----------------------------------------------------------------------------------------------
    // Final address in memory space mux
    general_mux
    #(
        .INPUT_WIDTH    ( ADDR_WIDTH ),
        .NUM_OF_SIGNALS (      4     ),
        .SYNC_OR_ASYNC  (   "ASYNC"  )  // "SYNC"   // "ASYNC"
    )
    final_adress_mux
    (
        .*,
        .i_ctrl    (   i_mem_space_mux   ),
        .i_signals ( FINAL_ADDRESS_ARRAY ),
        .o_signal  (    final_address    )
    );
    // ----------------------------------------------------------------------------------------------
    // Mux for enable signal
    general_mux
    #(
        .INPUT_WIDTH    (    1    ),
        .NUM_OF_SIGNALS (    2    ),
        .SYNC_OR_ASYNC  ( "ASYNC" )  // "SYNC"   // "ASYNC"
    )
    enable_signal_mux
    (
        .*,
        .i_ctrl    (              i_enable_switch             ),
        .i_signals ( '{i_enable_for_write, i_enable_for_read} ),
        .o_signal  (              enable_counter              )
    );
endmodule : address_counter
/*
    address_counter
    #(
        .ADDR_WIDTH            (   8  ),
        .UNLOCK_SEQ_START_ADDR ( 'h00 ),
        .PROG_DATA_START_ADDR  ( 'h04 ),
        .TR_EN_OTHER_ADDR      ( 'h18 ),
        .SELFTEST_START_ADDR   ( 'h19 ),
        .MEM_FINAL_ADDRESS     ( 'h40 )
    )
    address_counter_inst
    (
        .i_clk                ( ),
        .i_reset              ( ),
        .i_enable_switch      ( ),
        .i_enable_for_read    ( ),
        .i_enable_for_write   ( ),
        .i_mem_space_mux      ( ),
        .o_address_to_memmory ( )
    );
*/