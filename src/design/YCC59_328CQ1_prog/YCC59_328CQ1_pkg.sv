`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Polikarpov D. A.
// 
// Create Date: 08.03.2026 11:34:17
// Package Name: YCC59_328CQ1_pkg
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


package YCC59_328CQ1_pkg;

    typedef enum logic [1 : 0] {
        UNLOCK_SEQ  = 2'b00,
        PROG_DATA   = 2'b01,
        TR_EN_OTHER = 2'b10,
        SELFTEST    = 2'b11
    } start_addr_mux_te;

endpackage : YCC59_328CQ1_pkg
