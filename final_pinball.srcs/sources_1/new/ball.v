// File: ball.v
// This is the ball design for EE178 Final Project.

// The `timescale directive specifies what the
// simulation time units are (1 ns here) and what
// the simulator time step should be (1 ps here).

`timescale 1 ns / 1 ps

// Declare the module and its ports. This is
// using Verilog-2001 syntax.
//////////////////////////////////////////////////////////////////////////////////

localparam [7:0] initialx = 8'd230;
localparam [7:0] initialy = 8'd100;
localparam signed [7:0] initialdy = 0;
localparam [3:0] max_velo = 4'd6;
localparam [1:0] gravity_magnitude = 2'd1;
localparam [3:0] gravity_rate = 4'd1;

module ball(
	input wire pclk,
    input wire gameclk,
    output reg [7:0] posx = initialx, // just store single corner
    output reg [7:0] posy = initialy, // others can be calculated
    output wire [3:0] size,
    input wire [2:0] control
    );

wire reset;
assign reset = control[2];

// ****** OUTPUT ***********

assign size = 4'h8;

reg [7:0] newx = initialx;
reg [7:0] newy = initialy;

always @(posedge gameclk)
begin
	posx <= newx;
	posy <= newy;
end


// ******* CALCULATIONS *******

// Initial speed
reg signed [7:0] dx = 1; 
reg signed [7:0] dy = initialdy;

// Storage registers
reg [7:0] storex;
reg [7:0] storey;

// Status
reg collision = 0;
reg [3:0] situation = 0;

// Counters

reg [1:0] step = 0;
reg [3:0] gravity_ctr = 0;


always @(posedge pclk)
begin
	case(step)
		2'd0: // save current position for calculations. Check current location for collision
		begin
			if (!reset)
			begin
				situation <= SITUATION(posx, posy);
				storex <= posx;
				storey <= posy;
			end
			else // Handle a reset
			begin 
				storex <= initialx;
				storey <= initialy;
				dx <= 0;
				dy <= initialdy;
				situation <= 4'b0000;
			end
			step <= step + 1;
		end
		2'd1: // React to collision, modify velocity accordingly
		begin
			// save current position
			
			case (situation) // left, right, top, bottom
				4'b1000, 4'b0100:  // left, right
				begin
						
					collision <= 1;
				end
				4'b0010, 4'b0001, 4'b1110, 4'b1101:  // top, bottom, odd case when both sides and top hit
				begin
					dy <= (!collision) ? dy * -1: dy;
					collision <= 1;
				end
				4'b1010: // Left Top
				begin
					collision <= 1;
				end
				4'b1001: // Left Bottom
				begin
					collision <= 1;
				end
				4'b0110: // Right Top
				begin
					collision <= 1;
				end
				4'b0101: // Right Bottom
				begin
					collision <= 1;
				end
				
				default: collision <= 0;
					
			endcase
			
				/*
				if (posy < 20 || posy > 230)
				begin
					// only apply on first time collision is detected
					dy <= (!collision) ? dy * -1: dy;
					collision <= 1;
				end
				else collision <= 0; */
				
				// if posy > Blah do stuff
				// (dy < 0) storey <= storey - (dy * -1): storey + dy;
				// handles signed 
			
			step <= step + 1;
		end
		2'd2: // apply gravity
		begin
			if (gravity_ctr == gravity_rate)
			begin // only accelerate if under max speed
				// make sure to subract unsigned numbers only
				if (dy < max_velo)
				begin
					dy <= (dy > 0) ? dy + gravity_magnitude : -1 * ((dy * -1) - gravity_magnitude);
				end
				else dy <= dy;
				gravity_ctr <= 0;
			end
			else gravity_ctr <= gravity_ctr + 1;
			
			dx <= dx;
			
			step <= step + 1;
		end
		2'd3: // update location
		begin
			newx <= storex + dx;
			newy <= storey + dy;
			step <= 2'd0; // back to start
		end
		default: ;
	endcase
end

/******************************* functions ******************/    


function [3:0] SITUATION;
input topLX, topLY; 
	SITUATION = {CHECK_LEFT(topLX, topLY), CHECK_RIGHT(topLX, topLY), CHECK_UPPER(topLX, topLY), CHECK_LOWER(topLX, topLY)};
endfunction
    
function [0:0] CHECK_UPPER; // 0010
input topLX, topLY;
	CHECK_UPPER = (topLY < 20);
endfunction

function [0:0]CHECK_LOWER; // 0001
input topLX, topLY;
	CHECK_LOWER = (topLY > 230);
endfunction

function [0:0] CHECK_LEFT; //1000
input topLX, topLY;
	CHECK_LEFT = (topLX <= size);
endfunction

function [0:0] CHECK_RIGHT; //0100
input topLX, topLY;
	CHECK_RIGHT = ((topLX + size) >= (8'd255 - size));
	endfunction
    

endmodule
