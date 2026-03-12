`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Polikarpov D. A.
// 
// Create Date: 09.03.2026 17:56:55
// Testbench Name: YCC59_328CQ1_programm_tb
// Project Name: YCC59_328CQ1
// Target Devices: Zynq, Artix, etc.
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module YCC59_328CQ1_programm_tb();
    logic i_clk;
    // TR and EN control signals
    logic o_TR1,
          o_TR2,
          o_EN;
    // Data SPI signals
    logic o_DEN,
          o_CLK,
          o_DIN,
          o_OE;
    logic i_DOUT = '0;
    // Function SPI
    logic o_FEN,
          o_FIN;
    // Test outputs
    logic [4 : 0] o_main_fsm_state;
    logic [2 : 0] o_boot_prog_fsm_state;
    logic [2 : 0] o_selftest_fsm_state;
    logic [25 : 0] transmit_seq = 26'h3567F;
    logic [4 : 0] bit_num = 'd25;
    YCC59_328CQ1_programm
    #(
        .MAIN_CLK_SIGNAL       ( 120000000 ),
        .UNLOCK_SEQ_START_ADDR (    'h00   ),
        .PROG_DATA_START_ADDR  (    'h04   ),
        .TR_EN_OTHER_ADDR      (    'h18   ),
        .SELFTEST_START_ADDR   (    'h19   ),
        .MEM_FINAL_ADDRESS     (    'h40   )
    )
    YCC59_328CQ1_programm_DUT
    (
        .*
    );
    
    initial begin
        i_clk <= '0;
        forever #1 i_clk <= ~i_clk;
    end
    
    always_ff @(negedge o_CLK) begin
        if (~o_OE & ~o_DEN) begin
            i_DOUT <= transmit_seq[bit_num];
            if (bit_num == 'd0) begin
                bit_num <= 'd25;
            end
            else begin
                bit_num <= bit_num - 'd1;
            end
        end
    end
endmodule : YCC59_328CQ1_programm_tb
