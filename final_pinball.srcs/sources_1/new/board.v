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
localparam [1:0] REG_DATA_MODE_HLD = 2'h0;
localparam [1:0] REG_DATA_MODE_CLR = 2'h1;
localparam [1:0] REG_DATA_MODE_LIN = 2'h2;
localparam [1:0] REG_DATA_MODE_EXP = 2'h3;


wire setup;
reg [3:0] setup_state = 0;
reg [3:0] dynamDraw = 0;
assign setup = !(setup_state == 4'hF);

always @(posedge pclk)
begin
    if (!busy) // if no job already running
    begin
        if (setup) // if still in setup mode
        begin
            if (!go) // if a go pulse is not in progress
            begin
                case (setup_state)
                    //borders
					4'h0: {startx, starty, endx, endy, beam, mode} <= {8'd004, 8'd004, 8'd252, 8'd004, REG_DATA_BEAM_HI, REG_DATA_MODE_HLD};//top horizantal line
					4'h1: {startx, starty, endx, endy, beam, mode} <= {8'd004, 8'd252, 8'd252, 8'd252, REG_DATA_BEAM_HI, REG_DATA_MODE_HLD};//button horizantal line
					4'h2: {startx, starty, endx, endy, beam, mode} <= {8'd252, 8'd004, 8'd252, 8'd252, REG_DATA_BEAM_HI, REG_DATA_MODE_HLD}; //Right vertical line
					4'h3: {startx, starty, endx, endy, beam, mode} <= {8'd004, 8'd004, 8'd004, 8'd252, REG_DATA_BEAM_HI, REG_DATA_MODE_HLD}; //left vertical line
					4'h4: {startx, starty, endx, endy, beam, mode} <= {8'd214, 8'd004, 8'd252, 8'd042, REG_DATA_BEAM_HI, REG_DATA_MODE_HLD}; //top right diagonal line
					//triangle in the middle
					4'h5: {startx, starty, endx, endy, beam, mode} <= {8'd101, 8'd120, 8'd128, 8'd093, REG_DATA_BEAM_HI, REG_DATA_MODE_HLD}; //86, 120, 127, 96
					4'h6: {startx, starty, endx, endy, beam, mode} <= {8'd128, 8'd093, 8'd155, 8'd120, REG_DATA_BEAM_HI, REG_DATA_MODE_HLD}; //127, 96, 168, 120
					//left paddel extention
					4'h7: {startx, starty, endx, endy, beam, mode} <= {8'd004, 8'd210, 8'd064, 8'd210, REG_DATA_BEAM_HI, REG_DATA_MODE_HLD}; //4, 210, 64, 210
					4'h8: {startx, starty, endx, endy, beam, mode} <= {8'd004, 8'd150, 8'd064, 8'd210, REG_DATA_BEAM_HI, REG_DATA_MODE_HLD}; //4, 154, 64, 210
                    4'h9: ;//{startx, starty, endx, endy, beam, mode} <= {8'd064, 8'd210, 8'd095, 8'd241, REG_DATA_BEAM_HI, REG_DATA_MODE_HLD}; // paddle left
                    //right paddel extention
					4'hA: {startx, starty, endx, endy, beam, mode} <= {8'd252, 8'd210, 8'd192, 8'd210, REG_DATA_BEAM_HI, REG_DATA_MODE_HLD}; 
					4'hB: {startx, starty, endx, endy, beam, mode} <= {8'd192, 8'd210, 8'd252, 8'd150, REG_DATA_BEAM_HI, REG_DATA_MODE_HLD};
					4'hC: ;//{startx, starty, endx, endy, beam, mode} <= {8'd161, 8'd241, 8'd192, 8'd210, REG_DATA_BEAM_HI, REG_DATA_MODE_HLD};  // paddle right
					4'hD: ; //
					4'hE: ; //
					4'hF: ; // should never get here
                            
					default: ;
				endcase
				setup_state <= setup_state + 1;
				go <= 1;
            end
            else go <= 0; // else end the go pulse
        end
        else // else in normal running mode
        begin
        	if (!go) // if a go pulse is not in progress
        	begin
            // Pull from ball and levers
				case (dynamDraw)
					// ball
					4'h0: {startx, starty, endx, endy, beam, mode} <= {ballX, ballY, ballX+ballSize, ballY, REG_DATA_BEAM_HI, REG_DATA_MODE_HLD}; //top line
					4'h1: {startx, starty, endx, endy, beam, mode} <= {ballX+ballSize, ballY, ballX+ballSize, ballY+ballSize, REG_DATA_BEAM_HI, REG_DATA_MODE_HLD}; //right line
					4'h2: {startx, starty, endx, endy, beam, mode} <= {ballX, ballY+ballSize, ballX+ballSize, ballY+ballSize, REG_DATA_BEAM_HI, REG_DATA_MODE_HLD}; //bot line
					4'h3: {startx, starty, endx, endy, beam, mode} <= {ballX, ballY, ballX, ballY+ballSize, REG_DATA_BEAM_HI, REG_DATA_MODE_HLD}; //left line
					// levers
					4'h4:
					begin
						if (control[0]) {startx, starty, endx, endy, beam, mode} <= {8'd064, 8'd210, 8'd106, 8'd210, REG_DATA_BEAM_HI, REG_DATA_MODE_HLD}; // paddle left
						else {startx, starty, endx, endy, beam, mode} <= {8'd064, 8'd210, 8'd095, 8'd241, REG_DATA_BEAM_HI, REG_DATA_MODE_HLD}; // paddle left
					end
					4'h5:
					begin
						if (control[1]) {startx, starty, endx, endy, beam, mode} <= {8'd150, 8'd210, 8'd192, 8'd210, REG_DATA_BEAM_HI, REG_DATA_MODE_HLD};  // paddle right up
						else {startx, starty, endx, endy, beam, mode} <= {8'd161, 8'd241, 8'd192, 8'd210, REG_DATA_BEAM_HI, REG_DATA_MODE_HLD};  // paddle right down
					end
					default: ;
				endcase
				dynamDraw <= dynamDraw + 1;
				go <= 1;
				
        	end
        	else go <= 0; // else end the go pulse
        end
	end
	else go <= 0;
end
   
endmodule

