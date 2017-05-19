`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/19/2017 01:39:43 PM
// Design Name: 
// Module Name: include
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

// Ball Size
`define BS 8'd8

// LIMITS
`define BOARD_TOP `BS
`define BOARD_BOT 8'd255
`define BOARD_LEFT `BS
`define BOARD_RIGHT 8'd255 - `BS

`define BOARD_BOT_BARRIER 8'd255 - `BS

// UPPER RIGHT TRIANGLE
`define TR_DIAG_STAX 8'd215 - `BS
`define TR_DIAG_STAY `BOARD_TOP
`define TR_DIAG_ENDX `BOARD_RIGHT
`define TR_DIAG_ENDY 8'd40 + `BS

// CENTER OBSTACLE
`define CTR_STAX 8'd101
`define CTR_MIDX 8'd128
`define CTR_ENDX 8'd155
`define CTR_BOTY 8'd120
`define CTR_TOPY 8'd93

// LEFT BUMPER
`define LBUMP_DIAG_STAX `BOARD_LEFT
`define LBUMP_DIAG_STAY 8'd150
`define LBUMP_DIAG_ENDX 8'd060 + `BS
`define LBUMP_DIAG_ENDY 8'd210


// RIGHT BUMPER
`define RBUMP_DIAG_STAX 8'd195 - `BS
`define RBUMP_DIAG_STAY 8'd210
`define RBUMP_DIAG_ENDX `BOARD_RIGHT
`define RBUMP_DIAG_ENDY 8'd150

// LEFT PADDLE
`define LPAD_UP_STAX 8'd060 + `BS
`define LPAD_UP_STAY 8'd210
`define LPAD_UP_ENDX 8'd105 + `BS
`define LPAD_UP_ENDY 8'd210

`define LPAD_DN_STAX 8'd060 + `BS
`define LPAD_DN_STAY 8'd210
`define LPAD_DN_ENDX 8'd095 + `BS
`define LPAD_DN_ENDY 8'd240

// RIGHT PADDLE
`define RPAD_UP_STAX 8'd150 - `BS
`define RPAD_UP_STAY 8'd210
`define RPAD_UP_ENDX 8'd195 - `BS
`define RPAD_UP_ENDY 8'd210

`define RPAD_DN_STAX 8'd160 - `BS
`define RPAD_DN_STAY 8'd240
`define RPAD_DN_ENDX 8'd195 - `BS
`define RPAD_DN_ENDY 8'd210

