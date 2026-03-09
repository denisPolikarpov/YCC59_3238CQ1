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

module YCC59_328CQ1_programm
#(
    parameter int unsigned MAIN_CLK_SIGNAL       = 120000000,
    parameter int unsigned UNLOCK_SEQ_START_ADDR = 'h00,
    parameter int unsigned PROG_DATA_START_ADDR  = 'h04,
    parameter int unsigned TR_EN_OTHER_ADDR      = 'h18,
    parameter int unsigned SELFTEST_START_ADDR   = 'h19,
    parameter int unsigned MEM_FINAL_ADDRESS     = 'h2C
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
                 o_FIN,
    // Test outputs
    output logic [4 : 0] o_main_fsm_state,
           logic [3 : 0] o_boot_fsm_state
);
    // -----------------------------------------------
    // Defenitions
    // Ctrl sequance
    localparam logic [11 : 0] BOOT_FUNC_SEQ = 12'h380;
    localparam logic [11 : 0] LATCH_TRANNS  = 12'h11F;
    // Internal constants
    localparam int unsigned NUM_OF_SCLK   = 5;
    localparam int unsigned MEM_WIDTH     = 8;
    localparam int unsigned MEM_DEPTH     = 'h29;
    localparam int unsigned ADDR_WIDTH    = 8;
    localparam int unsigned SPI_SCLK_FREQ = 20000000;
    
    wire boot_start_func_trans,
         reset_counter,
         enable_counter,
         func_spi_seq,
         spi_data_trans_finished,
         spi_func_trans_finished,
         start_func_trans_delay,
         falling_edge_of_SCLK;
    wor  start_data_trans,
         start_func_trans;
         
    wire [1 : 0] start_finish_address_mux_ctrl;
    
    wire [ADDR_WIDTH - 1 : 0] start_address,
                              final_address;
    wire [$bits(LATCH_TRANNS) - 1 : 0] func_seq_to_trans;
    // ----------------------------------------------------------------------------------------------
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
    assign BRAM_intr_to_SPI.we  = '0;
    // ----------------------------------------------------------------------------------------------
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
    // ----------------------------------------------------------------------------------------------
    // Address counter
    counter
    #(
        .COUNTER_WIDTH      ( ADDR_WIDTH ),
        .START_VALUE_SOURCE (   "PORT"   ),  // "PARAMETER"  // "PORT"
        .START_VALUE        (      0     ),
        .FINAL_VALUE_SOURCE (   "PORT"   ),  // "PARAMETER"  // "PORT"
        .FINAL_VALUE        (  2**16 - 1 )
    )
    address_counter
    (
        .i_clk,
        .i_reset               (     reset_counter     ),
        .i_enable              (     enable_counter    ),
        .i_start_value         (     start_address     ),
        .i_final_value         (     final_address     ),
        .o_value               ( BRAM_intr_to_SPI.addr ),
        .o_final_value_reached (                       )
    );
    
    general_mux
    #(
        .INPUT_WIDTH    ( ADDR_WIDTH ),
        .NUM_OF_SIGNALS (      4     ),
        .SYNC_OR_ASYNC  (   "ASYNC"  )  // "SYNC"   // "ASYNC"
    )
    start_adress_mux
    (
        .i_clk, 
        .i_ctrl    (                             start_finish_address_mux_ctrl                             ),
        .i_signals ( '{SELFTEST_START_ADDR, TR_EN_OTHER_ADDR, PROG_DATA_START_ADDR, UNLOCK_SEQ_START_ADDR} ),
        .o_signal  (                                     start_address                                     )
    );
    
    general_mux
    #(
        .INPUT_WIDTH    ( ADDR_WIDTH ),
        .NUM_OF_SIGNALS (      4     ),
        .SYNC_OR_ASYNC  (   "ASYNC"  )  // "SYNC"   // "ASYNC"
    )
    final_adress_mux
    (
        .i_clk, 
        .i_ctrl    (                          start_finish_address_mux_ctrl                         ),
        .i_signals ( '{MEM_FINAL_ADDRESS, TR_EN_OTHER_ADDR, TR_EN_OTHER_ADDR - 1'b1, PROG_DATA_START_ADDR - 1'b1} ),
        .o_signal  (                                  final_address                                 )
    );
    // ----------------------------------------------------------------------------------------------
    // SPIs
    data_spi
    #(
        .MAIN_CLK_SIGNAL ( MAIN_CLK_SIGNAL ),
        .SPI_SCLK_FREQ   (  SPI_SCLK_FREQ  )
    )
    data_spi_inst
    (
        .i_clk,
        // SPI interface
        .intr_SPI_master      (         SPI_DATA        ),
        // Other signals
        .i_start              (     start_data_trans    ),
        .i_data_from_bram     (  BRAM_intr_to_SPI.dout  ),
        .o_enable_address_cn  (      enable_counter     ),
        .o_trans_finished     (                         ),
        .o_all_trans_finished ( spi_data_trans_finished )
    );
    
    func_spi
    #(
        .BOOT_FUNC_SEQ   (  BOOT_FUNC_SEQ  ),
        .LATCH_TRANNS    (   LATCH_TRANNS  ),
        .NUM_OF_SCLK     (   NUM_OF_SCLK   ),
        .MAIN_CLK_SIGNAL ( MAIN_CLK_SIGNAL ),
        .SPI_SCLK_FREQ   (  SPI_SCLK_FREQ  )
    )
    func_spi_inst
    (
        .i_clk,
        // SPI Interface
        .intr_SPI_master  ( SPI_FUNC ),
        // Other signals
        .i_start          (     start_func_trans    ),
        .i_seq_ctrl       (       func_spi_seq      ),
        .o_trans_finished ( spi_func_trans_finished )
    );
    // ----------------------------------------------------------------------------------------------
    // Alias fsm start and finished signal
    alias i_boot_fsm_finished = o_boot_fsm_finished;
    alias i_start_boot_fsm    = o_start_boot_fsm;
    // MAIN FSM
    YCC59_328CQ1_main_fsm YCC59_328CQ1_main_fsm_inst
    (
        .i_clk,
        // Report signals
        .i_init              ( BRAM_intr_to_SPI.dout[5 : 5] ),
        .i_boot_fsm_finished,
        // Control signals
        .o_start_final_addr_mux  ( start_finish_address_mux_ctrl ),
        .o_func_spi_seq          (          func_spi_seq         ),
        .o_block_ps_access       ( ),
        .o_reset_address_counter (         reset_counter         ),
        .o_start_boot_fsm,
        .o_main_fsm_state
    );
    // BOOT FSM
    YCC59_328CQ1_boot_fsm YCC59_328CQ1_boot_fsm_inst
    (
        .i_clk,
        // Report signals
        .i_start_boot_fsm,
        .i_all_data_trans_finished ( spi_data_trans_finished ),
        .i_func_trans_finished     ( spi_func_trans_finished ),
        // Controll signals
        .o_spi_data_init     ( start_data_trans ),
        .o_spi_func_init     ( start_func_trans ),
        .o_boot_fsm_finished,
        .o_boot_fsm_state
    );
endmodule : YCC59_328CQ1_programm
/*
    YCC59_328CQ1_programm
    #(
        .MAIN_CLK_SIGNAL       ( 120000000 ),
        .UNLOCK_SEQ_START_ADDR (    'h00   ),
        .PROG_DATA_START_ADDR  (    'h04   ),
        .TR_EN_OTHER_ADDR      (    'h18   ),
        .SELFTEST_START_ADDR   (    'h19   ),
        .MEM_FINAL_ADDRESS     (    'h2C   )
    )
    YCC59_328CQ1_programm_inst
    (
        .i_clk ( ),
        // TR and EN control signals
        .o_TR1 ( ),
        .o_TR2 ( ),
        .o_EN  ( ),
        // Data SPI signals
        .o_DEN  ( ),
        .o_CLK  ( ),
        .o_DIN  ( ),
        .o_OE   ( ),
        .i_DOUT ( ),
        // Function SPI
        .o_FEN ( ),
        .o_FIN ( ),
        // Test outputs
        .o_main_fsm_state ( ),
        .o_boot_fsm_state ( )
    );
*/