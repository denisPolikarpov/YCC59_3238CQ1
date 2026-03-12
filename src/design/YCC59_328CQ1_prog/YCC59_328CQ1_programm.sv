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
    parameter int unsigned MEM_FINAL_ADDRESS     = 'h40,
    parameter int unsigned NUM_OF_CLKS_BEETWEEN  = 7            // At least 5
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
           logic [2 : 0] o_boot_prog_fsm_state,
           logic [2 : 0] o_selftest_fsm_state
);
    // ----------------------------------------------------------------------------------------------
    // Defenitions
    // Ctrl sequance
    localparam logic [11 : 0] BOOT_FUNC_SEQ = 12'h380;
    localparam logic [11 : 0] LATCH_TRANNS  = 12'h11F;
    // Internal constants
    localparam int unsigned MEM_WIDTH     = 8;
    localparam int unsigned MEM_DEPTH     = MEM_FINAL_ADDRESS + 'h1;
    localparam int unsigned ADDR_WIDTH    = 8;
    localparam int unsigned SPI_SCLK_FREQ = 20000000;
    
    wire reset_counter,
         enable_counter_read,
         enable_counter_write,
         func_spi_seq,
         spi_data_trans_finished,
         spi_func_trans_finished,
         block_bram_output,
         start_data_trans,
         start_func_trans,
         recieve_data_enable,
         bram_we;
         
    wire [1 : 0] mem_space_mux;
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
    assign BRAM_intr_to_SPI.we  = '{default : bram_we};
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
    address_counter
    #(
        .ADDR_WIDTH            (       ADDR_WIDTH      ),
        .UNLOCK_SEQ_START_ADDR ( UNLOCK_SEQ_START_ADDR ),
        .PROG_DATA_START_ADDR  (  PROG_DATA_START_ADDR ),
        .TR_EN_OTHER_ADDR      (    TR_EN_OTHER_ADDR   ),
        .SELFTEST_START_ADDR   (  SELFTEST_START_ADDR  ),
        .MEM_FINAL_ADDRESS     (   MEM_FINAL_ADDRESS   )
    )
    address_counter_inst
    (
        .i_clk,
        .i_reset              (     reset_counter     ),
        .i_enable_switch      (  recieve_data_enable  ),
        .i_enable_for_read    (  enable_counter_read  ),
        .i_enable_for_write   (  enable_counter_write ),
        .i_mem_space_mux      (     mem_space_mux     ),
        .o_address_to_memmory ( BRAM_intr_to_SPI.addr )
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
        .intr_SPI_master ( SPI_DATA ),
        // Other signals
        .i_start                   (     start_data_trans    ),
        .i_enable_recieve_data     (   recieve_data_enable   ),
        .i_data_from_bram          (  BRAM_intr_to_SPI.dout  ),
        .o_data_to_bram            (  BRAM_intr_to_SPI.din   ),
        .o_write_data_to_bram      (         bram_we         ),
        .o_enable_read_address_cn  (   enable_counter_read   ),
        .o_enable_write_address_cn (   enable_counter_write  ),
        .o_trans_finished          (                         ),
        .o_all_trans_finished      ( spi_data_trans_finished )
    );
    
    func_spi
    #(
        .BOOT_FUNC_SEQ   (     BOOT_FUNC_SEQ    ),
        .LATCH_TRANNS    (     LATCH_TRANNS     ),
        .NUM_OF_SCLK     ( NUM_OF_CLKS_BEETWEEN ),
        .MAIN_CLK_SIGNAL (    MAIN_CLK_SIGNAL   ),
        .SPI_SCLK_FREQ   (     SPI_SCLK_FREQ    )
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
    // Block Reading from bram for 2 cycles
    pulse_generation
    #(
        .PULSE_WIDTH    (     2    ),
        .EDGE_DETECTION ( "RISING" )  // "RISING" // "FALLING" // "BOTH"
    )
    pulse_generation_inst
    (
        .i_clk,
        .i_signal (   reset_counter   ),
        .o_pulse  ( block_bram_output )
    );
    // ----------------------------------------------------------------------------------------------
    // FSM
    YCC59_3238CQ1_fsm YCC59_3238CQ1_fsm_inst
    (
        .*,
        // Init YCC59_328CQ1_programm
        .i_init ( BRAM_intr_to_SPI.dout[5 : 5] & ~block_bram_output ),
        // Start programming of YCC59_328CQ1
        .i_programm ( BRAM_intr_to_SPI.dout[3 : 3] & ~block_bram_output ),
        // Start selftest of YCC59_328CQ1
        .i_begin_selftest ( BRAM_intr_to_SPI.dout[4 : 4] & ~block_bram_output ),
        // DATA and FUNC SPI finished transmission signals
        .i_all_data_trans_finished ( spi_data_trans_finished ),
        .i_func_trans_finished     ( spi_func_trans_finished ),
        // Control output sequance
        .o_start_final_addr_mux  (    mem_space_mux    ),
        .o_func_spi_seq          (    func_spi_seq     ),
        .o_block_ps_access       (                     ),
        .o_reset_address_counter (    reset_counter    ),
        .o_bram_write            ( recieve_data_enable ),
        .o_spi_data_init         (   start_data_trans  ),
        .o_spi_func_init         (   start_func_trans  )
    );
    // ----------------------------------------------------------------------------------------------
    // EN, TR1, TR2
    always_ff @(posedge i_clk) begin : register
        if ((mem_space_mux == 2'b10) & ~block_bram_output) begin
            o_EN  <= BRAM_intr_to_SPI.dout[0 : 0];
            o_TR1 <= BRAM_intr_to_SPI.dout[1 : 1];
            o_TR2 <= BRAM_intr_to_SPI.dout[2 : 2];
        end
    end : register
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
        .o_boot_fsm_state ( ),
        .o_prog_fsm_state ( )
    );
*/