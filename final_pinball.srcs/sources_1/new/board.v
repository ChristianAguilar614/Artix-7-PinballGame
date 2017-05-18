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
	input wire pclk,
	input wire gameclk,
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
	input wire [3:0]ballSize,
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


reg [4:0] draw_state = 0;

always @(posedge pclk)
begin
    if (!busy) // if no job already running
    begin
   		if (!go) // if a go pulse is not in progress
   		begin
      		case (draw_state)
            	//borders
       			// ******** BOARD **********************
				4'd0: {startx, starty, endx, endy, beam, mode} <= {8'd004, 8'd004, 8'd127, 8'd004, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP};//top horizantal line Part 1
				4'd1: {startx, starty, endx, endy, beam, mode} <= {8'd128, 8'd004, 8'd252, 8'd004, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP};//top horizantal line Part 2
				4'd2: {startx, starty, endx, endy, beam, mode} <= {8'd252, 8'd004, 8'd252, 8'd127, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP}; //Right vertical line Part 1
				4'd3: {startx, starty, endx, endy, beam, mode} <= {8'd252, 8'd128, 8'd252, 8'd252, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP}; //Right vertical line Part 2
				4'd4: {startx, starty, endx, endy, beam, mode} <= {8'd004, 8'd004, 8'd004, 8'd127, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP}; //left vertical line Part 1
				4'd5: {startx, starty, endx, endy, beam, mode} <= {8'd004, 8'd128, 8'd004, 8'd252, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP}; //left vertical line Part 2
				4'd6: {startx, starty, endx, endy, beam, mode} <= {8'd214, 8'd004, 8'd252, 8'd042, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP}; //top right diagonal line
				//triangle in the middle
				4'd7: {startx, starty, endx, endy, beam, mode} <= {8'd101, 8'd120, 8'd128, 8'd093, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP}; //86, 120, 127, 96
				4'd8: {startx, starty, endx, endy, beam, mode} <= {8'd128, 8'd093, 8'd155, 8'd120, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP}; //127, 96, 168, 120
				//left paddel extention
				4'd9: {startx, starty, endx, endy, beam, mode} <= {8'd004, 8'd210, 8'd064, 8'd210, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP}; //4, 210, 64, 210
				4'd10: {startx, starty, endx, endy, beam, mode} <= {8'd004, 8'd150, 8'd064, 8'd210, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP}; //4, 154, 64, 210
         		4'd11: ;//{startx, starty, endx, endy, beam, mode} <= {8'd064, 8'd210, 8'd095, 8'd241, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP}; // paddle left
          		//right paddel extention
				4'd12: {startx, starty, endx, endy, beam, mode} <= {8'd252, 8'd210, 8'd192, 8'd210, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP}; 
				4'd13: {startx, starty, endx, endy, beam, mode} <= {8'd192, 8'd210, 8'd252, 8'd150, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP};
				4'd14: ;//{startx, starty, endx, endy, beam, mode} <= {8'd161, 8'd241, 8'd192, 8'd210, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP};  // paddle right
				4'd15: ; // should never get here
                    
        		// ******** DYNAMIC PARTS ***************
       			5'd16: {startx, starty, endx, endy, beam, mode} <= {ballX, ballY, ballX+ballSize, ballY, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP}; //top line
				5'd17: {startx, starty, endx, endy, beam, mode} <= {ballX+ballSize, ballY, ballX+ballSize, ballY+ballSize, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP}; //right line
            	5'd18: {startx, starty, endx, endy, beam, mode} <= {ballX, ballY+ballSize, ballX+ballSize, ballY+ballSize, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP}; //bot line
        		5'd19: {startx, starty, endx, endy, beam, mode} <= {ballX, ballY, ballX, ballY+ballSize, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP}; //left line
				5'd20: // show left lever
          		begin
      				if (control[0]) {startx, starty, endx, endy, beam, mode} <= {8'd064, 8'd210, 8'd106, 8'd210, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP}; // paddle left
   					else {startx, starty, endx, endy, beam, mode} <= {8'd064, 8'd210, 8'd095, 8'd241, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP}; // paddle left
    			end
    			5'd21: // show right lever
    			begin
					if (control[1]) {startx, starty, endx, endy, beam, mode} <= {8'd150, 8'd210, 8'd192, 8'd210, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP};  // paddle right up
     				else {startx, starty, endx, endy, beam, mode} <= {8'd161, 8'd241, 8'd192, 8'd210, REG_DATA_BEAM_HI, REG_DATA_MODE_EXP};  // paddle right down
  				end
				default: ;
			endcase
			draw_state <= draw_state + 1;
			go <= 1;
    	end
 		else go <= 0; // else end the go pulse
	end
	else go <= 0;
end
   
endmodule

