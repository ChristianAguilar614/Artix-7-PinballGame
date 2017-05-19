// File: board.v
// This is the board design for EE178 Lab #6.

// The `timescale directive specifies what the
// simulation time units are (1 ns here) and what
// the simulator time step should be (1 ps here).

`timescale 1 ns / 1 ps

// Declare the module and its ports. This is
// using Verilog-2001 syntax.
//////////////////////////////////////////////////////////////////////////////////

module board(
	//input wire pclk,
	input wire pclk,
	output reg [7:0] startx = 0,
	output reg [7:0] starty = 0,
	output reg [7:0] endx = 0,
	output reg [7:0] endy = 0,
	output reg [1:0] mode = 0,
	output reg [3:0] beam = 0,
	input wire busy,
	output reg go = 0,
	input wire [7:0] ballX, //top left x
	input wire [7:0] ballY, // top left y
	input wire [3:0] ballSize,
	input wire [2:0] control
);

//local variables indicating various registers and modes
localparam [3:0] REG_DATA_BUSY_GO = 4'h01;
localparam [3:0] REG_DATA_BEAM_HI = 4'h0f;
localparam [3:0] REG_DATA_BEAM_MD = 4'h07;
localparam [3:0] REG_DATA_BEAM_LO = 4'h03;
localparam [3:0] REG_DATA_BEAM_OFF = 4'h00;
localparam [1:0] REG_DATA_MODE_HLD = 2'h0;
localparam [1:0] REG_DATA_MODE_CLR = 2'h1;
localparam [1:0] REG_DATA_MODE_LIN = 2'h2;
localparam [1:0] REG_DATA_MODE_EXP = 2'h3;

reg [1:0] gameState = 2'b01;
reg [4:0] draw_state = 4'b0000;
reg [3:0] state_toggle_ctr = 0;

wire loss = (ballY >= `LPAD_DN_ENDY);

always @(posedge pclk) //60 fps
begin
    if (!busy) begin // if no job already running
   		if (!go) begin// if a go pulse is not in progress
   			case (gameState)
      			2'b00: begin
						case (draw_state)
							//Letter P
							5'h0: {startx, starty, endx, endy, beam, mode} <= {8'd67, 8'd55, 8'd67, 8'd116, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP};
							5'h1: {startx, starty, endx, endy, beam, mode} <= {8'd101, 8'd55, 8'd101, 8'd85, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP};
							5'h2: {startx, starty, endx, endy, beam, mode} <= {8'd67, 8'd55, 8'd101, 8'd55, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP}; 
							5'h3: {startx, starty, endx, endy, beam, mode} <= {8'd67, 8'd85, 8'd101, 8'd85, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP}; 
							//Letter I
							5'h4: {startx, starty, endx, endy, beam, mode} <= {8'd126, 8'd55, 8'd126, 8'd116, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP}; 
							5'h5: {startx, starty, endx, endy, beam, mode} <= {8'd114, 8'd55, 8'd139, 8'd55, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP}; 
							5'h6: {startx, starty, endx, endy, beam, mode} <= {8'd114, 8'd116, 8'd139, 8'd116, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP}; 
							//Letter N
							5'h7: {startx, starty, endx, endy, beam, mode} <= {8'd151, 8'd55, 8'd151, 8'd116, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP};
							5'h8: {startx, starty, endx, endy, beam, mode} <= {8'd189, 8'd55, 8'd189, 8'd116, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP}; 
							5'hA: {startx, starty, endx, endy, beam, mode} <= {8'd151, 8'd55, 8'd189, 8'd116, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP}; 
							//Letter B
							5'hB: {startx, starty, endx, endy, beam, mode} <= {8'd40, 8'd139, 8'd40, 8'd200, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP};
							5'hC: {startx, starty, endx, endy, beam, mode} <= {8'd74, 8'd139, 8'd74, 8'd200, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP};
							5'hD: {startx, starty, endx, endy, beam, mode} <= {8'd40, 8'd139, 8'd74, 8'd139, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP};
							5'hE: {startx, starty, endx, endy, beam, mode} <= {8'd40, 8'd169, 8'd74, 8'd169, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP};
							5'hF: {startx, starty, endx, endy, beam, mode} <= {8'd40, 8'd200, 8'd74, 8'd200, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP};
							//Letter A
							5'h10: {startx, starty, endx, endy, beam, mode} <= {8'd86, 8'd139, 8'd86, 8'd200, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP}; //leter A
							5'h11: {startx, starty, endx, endy, beam, mode} <= {8'd120, 8'd139, 8'd120, 8'd200, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP};
							5'h12: {startx, starty, endx, endy, beam, mode} <= {8'd86, 8'd139, 8'd120, 8'd139, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP};
							5'h13: {startx, starty, endx, endy, beam, mode} <= {8'd86, 8'd169, 8'd120, 8'd169, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP};
							//Letter L
							5'h14: {startx, starty, endx, endy, beam, mode} <= {8'd134, 8'd139, 8'd134, 8'd200, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP};
							5'h15: {startx, starty, endx, endy, beam, mode} <= {8'd134, 8'd200, 8'd168, 8'd200, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP};
							//Letter L
							5'h16: {startx, starty, endx, endy, beam, mode} <= {8'd182, 8'd139, 8'd182, 8'd200, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP};
							5'h17: {startx, starty, endx, endy, beam, mode} <= {8'd182, 8'd200, 8'd216, 8'd200, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP};  
							default: ;
						endcase
						draw_state <= draw_state + 1;
						go <= 1;
					end
      			2'b01: begin
						case (draw_state)
						
						// ******** BOARD **********************
						// BORDERS
						5'd0: {startx, starty, endx, endy, beam, mode} <= {`BOARD_LEFT, `BOARD_TOP, 8'd127, `BOARD_TOP, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP};//top horizantal line Part 1
						5'd1: {startx, starty, endx, endy, beam, mode} <= {8'd128, `BOARD_TOP, `BOARD_RIGHT, `BOARD_TOP, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP};//top horizantal line Part 2
						5'd2: {startx, starty, endx, endy, beam, mode} <= {`BOARD_RIGHT, `BOARD_TOP, `BOARD_RIGHT, 8'd127, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP}; //Right vertical line Part 1
						5'd3: {startx, starty, endx, endy, beam, mode} <= {`BOARD_RIGHT, 8'd128, `BOARD_RIGHT, `BOARD_BOT, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP}; //Right vertical line Part 2
						5'd4: {startx, starty, endx, endy, beam, mode} <= {`BOARD_LEFT, `BOARD_TOP, `BOARD_LEFT, 8'd127, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP}; //left vertical line Part 1
						5'd5: {startx, starty, endx, endy, beam, mode} <= {`BOARD_LEFT, 8'd128, `BOARD_LEFT, `BOARD_BOT, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP}; //left vertical line Part 2
						
						//top right diagonal line
						5'd6: {startx, starty, endx, endy, beam, mode} <= {`TR_DIAG_STAX, `TR_DIAG_STAY, `TR_DIAG_ENDX, `TR_DIAG_ENDY, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP}; 
						//triangle in the middle
						5'd7: {startx, starty, endx, endy, beam, mode} <= {`CTR_STAX, `CTR_BOTY, `CTR_MIDX, `CTR_TOPY, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP}; //86, 120, 127, 96
						5'd8: {startx, starty, endx, endy, beam, mode} <= {`CTR_MIDX, `CTR_TOPY, `CTR_ENDX, `CTR_BOTY, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP}; //127, 96, 168, 120
						
						//left paddel extention
						5'd9: {startx, starty, endx, endy, beam, mode} <= {`LBUMP_DIAG_STAX, `LBUMP_DIAG_ENDY, `LBUMP_DIAG_ENDX, `LBUMP_DIAG_ENDY, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP}; // 
						5'd10: {startx, starty, endx, endy, beam, mode} <= {`LBUMP_DIAG_STAX, `LBUMP_DIAG_STAY, `LBUMP_DIAG_ENDX, `LBUMP_DIAG_ENDY, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP}; // DIAG
						
						//right paddel extention
						5'd11: {startx, starty, endx, endy, beam, mode} <= {`RBUMP_DIAG_STAX, `RBUMP_DIAG_STAY, `RBUMP_DIAG_ENDX, `RBUMP_DIAG_STAY, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP}; 
						5'd12: {startx, starty, endx, endy, beam, mode} <= {`RBUMP_DIAG_STAX, `RBUMP_DIAG_STAY, `RBUMP_DIAG_ENDX, `RBUMP_DIAG_ENDY, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP};
						
						// ******** DYNAMIC PARTS ***************
						// BALL
						5'd13: {startx, starty, endx, endy, beam, mode} <= {ballX, ballY, ballX+`BS, ballY, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP}; //top line
						5'd14: {startx, starty, endx, endy, beam, mode} <= {ballX+`BS, ballY, ballX+`BS, ballY+`BS, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP}; //right line
						5'd15: {startx, starty, endx, endy, beam, mode} <= {ballX, ballY+`BS, ballX+`BS, ballY+`BS, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP}; //bot line
						5'd16: {startx, starty, endx, endy, beam, mode} <= {ballX, ballY, ballX, ballY+`BS, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP}; //left line
						
						// PADDLES
						5'd17: // show left lever
						begin
							if (control[0]) {startx, starty, endx, endy, beam, mode} <= {`LPAD_UP_STAX, `LPAD_UP_STAY, `LPAD_UP_ENDX, `LPAD_UP_ENDY, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP}; // paddle left
							else {startx, starty, endx, endy, beam, mode} <= {`LPAD_DN_STAX, `LPAD_DN_STAY, `LPAD_DN_ENDX, `LPAD_DN_ENDY, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP}; // paddle left
						end
						5'd18: // show right lever
						begin
							if (control[1]) {startx, starty, endx, endy, beam, mode} <= {`RPAD_UP_STAX, `RPAD_UP_STAY, `RPAD_UP_ENDX, `RPAD_UP_ENDY, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP};  // paddle right up
							else {startx, starty, endx, endy, beam, mode} <= {`RPAD_DN_STAX, `RPAD_DN_STAY, `RPAD_DN_ENDX, `RPAD_DN_ENDY, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP};  // paddle right down
						end
						default: ;
					endcase
					if (draw_state >= 5'd18) draw_state <= 0;
					else draw_state <= draw_state + 1;
					go <= 1;
				end
				2'b10: begin
						case (draw_state)
							 //Letter G
							5'h0: {startx, starty, endx, endy, beam, mode} <= {8'd38, 8'd59, 8'd38, 8'd120, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP};
							5'h1: {startx, starty, endx, endy, beam, mode} <= {8'd72, 8'd89, 8'd72, 8'd120, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP};
							5'h2: {startx, starty, endx, endy, beam, mode} <= {8'd38, 8'd59, 8'd72, 8'd59, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP}; 
							5'h3: {startx, starty, endx, endy, beam, mode} <= {8'd57, 8'd89, 8'd72, 8'd89, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP}; 
							5'h4: {startx, starty, endx, endy, beam, mode} <= {8'd38, 8'd120, 8'd72, 8'd120, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP}; 
							//Letter A
							5'h5: {startx, starty, endx, endy, beam, mode} <= {8'd83, 8'd59, 8'd83, 8'd120, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP}; 
							5'h6: {startx, starty, endx, endy, beam, mode} <= {8'd117, 8'd59, 8'd117, 8'd120, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP}; 
							5'h7: {startx, starty, endx, endy, beam, mode} <= {8'd83, 8'd59, 8'd117, 8'd59, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP};
							5'h8: {startx, starty, endx, endy, beam, mode} <= {8'd83, 8'd89, 8'd117, 8'd89, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP}; 
							//Letter M
							5'h9: {startx, starty, endx, endy, beam, mode} <= {8'd125, 8'd59, 8'd125, 8'd120, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP}; 
							5'hA: {startx, starty, endx, endy, beam, mode} <= {8'd125, 8'd59, 8'd149, 8'd120, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP};
							5'hB: {startx, starty, endx, endy, beam, mode} <= {8'd149, 8'd120, 8'd173, 8'd59, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP};
							5'hC: {startx, starty, endx, endy, beam, mode} <= {8'd173, 8'd59, 8'd173, 8'd120, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP};
							//Letter E
							5'hD: {startx, starty, endx, endy, beam, mode} <= {8'd184, 8'd59, 8'd184, 8'd120, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP};
							5'hE: {startx, starty, endx, endy, beam, mode} <= {8'd184, 8'd59, 8'd218, 8'd59, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP};
							5'hF: {startx, starty, endx, endy, beam, mode} <= {8'd184, 8'd89, 8'd218, 8'd89, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP}; //leter A
							5'h10: {startx, starty, endx, endy, beam, mode} <= {8'd184, 8'd120, 8'd218, 8'd120, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP};
							//Letter O
							5'h11: {startx, starty, endx, endy, beam, mode} <= {8'd38, 8'd135, 8'd38, 8'd196, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP};
							5'h12: {startx, starty, endx, endy, beam, mode} <= {8'd72, 8'd135, 8'd72, 8'd196, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP};
							5'h13: {startx, starty, endx, endy, beam, mode} <= {8'd38, 8'd135, 8'd72, 8'd135, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP};
							5'h14: {startx, starty, endx, endy, beam, mode} <= {8'd38, 8'd196, 8'd72, 8'd196, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP};
							//Letter V
							5'h15: {startx, starty, endx, endy, beam, mode} <= {8'd93, 8'd135, 8'd100, 8'd196, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP};
							5'h16: {startx, starty, endx, endy, beam, mode} <= {8'd100, 8'd196, 8'd117, 8'd135, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP}; 
							//Letter E
							5'h17: {startx, starty, endx, endy, beam, mode} <= {8'd134, 8'd135, 8'd134, 8'd196, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP};
							5'h18: {startx, starty, endx, endy, beam, mode} <= {8'd134, 8'd135, 8'd168, 8'd135, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP};
							5'h19: {startx, starty, endx, endy, beam, mode} <= {8'd134, 8'd165, 8'd168, 8'd165, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP};
							5'h1A: {startx, starty, endx, endy, beam, mode} <= {8'd134, 8'd196, 8'd168, 8'd196, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP};
							//Letter R
							5'h1B: {startx, starty, endx, endy, beam, mode} <= {8'd184, 8'd135, 8'd184, 8'd196, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP};
							5'h1C: {startx, starty, endx, endy, beam, mode} <= {8'd218, 8'd135, 8'd218, 8'd165, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP};  
							5'h1D: {startx, starty, endx, endy, beam, mode} <= {8'd184, 8'd135, 8'd218, 8'd135, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP};  
							5'h1E: {startx, starty, endx, endy, beam, mode} <= {8'd184, 8'd165, 8'd218, 8'd165, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP};  
							5'h1F: {startx, starty, endx, endy, beam, mode} <= {8'd184, 8'd165, 8'd218, 8'd196, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP};  
							
							default: ;
						endcase
						draw_state <= draw_state + 1;
						go <= 1;
					end
				default: ;
		endcase
    	end
 		else go <= 0; // else end the go pulse
	end
	else go <= 0;
	
	if (control[2]) 
		if (state_toggle_ctr >= 4'hF)
			begin
			case (gameState)
				2'b00: gameState <= 2'b01;
				2'b01: gameState <= 2'b10;
				2'b10: gameState <= 2'b00;
				2'b11 :gameState <= 2'b00;
				default: gameState <= 2'b00;
			endcase
			state_toggle_ctr <= 0;
			end
		else state_toggle_ctr <= state_toggle_ctr + 1;
	
	
end
   
endmodule

