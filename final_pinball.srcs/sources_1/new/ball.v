// File: ball.v
// This is the ball design for EE178 Final Project.

// The `timescale directive specifies what the
// simulation time units are (1 ns here) and what
// the simulator time step should be (1 ps here).

`timescale 1 ns / 1 ps

// Declare the module and its ports. This is
// using Verilog-2001 syntax.
//////////////////////////////////////////////////////////////////////////////////

module ball(
	input wire pclk,
    input wire gameclk,
    output reg [7:0] topleft_x = 8'd230, // just store single corner
    output reg [7:0] topleft_y = 8'd100, // others can be calculated
    output wire [3:0] size
    );
    
localparam [3:0] max_velo = 4'd8;
localparam [1:0] gravity = 2'd1;
    
// every pclk, if temp == 0
// calculate next location, set it to temp
// every gameclk set position = temp, temp = 0

reg [7:0] tempx = 8'd230;
reg [7:0] tempy = 8'd100;

always @(posedge gameclk)
begin
	topleft_x <= tempx;
	topleft_y <= tempy;
end
    
reg [1:0] dx = 0; 
reg [1:0] dy = 0;

// set size of ball ?
assign size = 4'h8;

reg [1:0] step = 0;

reg [7:0] calc_tempx = 8'd230;
reg [7:0] calc_tempy = 8'd100;


always @(posedge pclk)
begin
    //sets the collision logic in anticipation of the maximum declared speed of ball
    //max = 10 pixle movements per framerate
	//move ball on entry	
	case (step)
	0:
		begin
		case(SITUATION(topleft_x,topleft_y))
			4'b0001, 4'b0010 : dy <= ~(dy); 	//Bottom and Top only collision
			4'b1000, 4'b0100 : dx <= ~(dx);	//Right and Left only collision
			4'b1010, 4'b0110, 4'b0101, 4'b1001 : 
			begin
				dx <= ~(dx);
				dy <= ~(dy);
			end
		endcase 
		calc_tempx <= topleft_x;
		calc_tempy <= topleft_y;
		end
	1:
	begin
		// Apply Air Resistance?
		dx <= dx; //(dx > 0) ? dx - 1: ((dx < 0) ? dx + 1 : 0);
		 
		// Apply Gravity (up to max fall speed)
		dy <= (dy < max_velo) ? dy + gravity: dy;
	end
	2:
	begin
		// move ball
		tempx <= calc_tempx + dx;
		tempy <= calc_tempy + dy;
	end
		
	endcase
	
	step <= step + 1;
	
end
    
/******************************* functions ******************/    


function SITUATION;
input topLX, topLY;
begin
	SITUATION = {CHECK_LEFT(topleft_x, topleft_y), CHECK_RIGHT(topleft_x, topleft_y), CHECK_UPPER(topleft_x, topleft_y), CHECK_LOWER(topleft_x, topleft_y)};
end
endfunction
	
    
function CHECK_UPPER;
input topLX, topLY;
begin
	//check top of screen
	if(topLY == 0) begin
		CHECK_UPPER = 1'b1;
	end
	//assign CHECK w/ hit marker
end
endfunction



function CHECK_LOWER;
input topLX, topLY;
begin
	if((topLY - size) == 255) begin
		CHECK_LOWER = 1'b1;
	end
	//assign CHECK w/ hit marker
end
endfunction



function CHECK_LEFT;
input topLX, topLY;
begin
	if(topLX == 0) begin
		CHECK_LEFT = 1'b1;
	end
	//assign CHECK w/ hit marker
end
endfunction



function CHECK_RIGHT;
input topLX, topLY;
begin
	if((topLX - size) == 255) begin
		CHECK_RIGHT = 1'b1;
	end
	//assign CHECK w/ hit marker
end
endfunction

endmodule
