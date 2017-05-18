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
localparam signed [7:0] initialdy = -6;
localparam [3:0] max_velo = 4'd10;
localparam [1:0] gravity_magnitude = 2'd2;
localparam [3:0] gravity_rate = 4'd4;

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
wire [3:0] situation;

// Counters

reg [1:0] step = 0;
reg [3:0] gravity_ctr = 0;


always @(posedge pclk)
begin
	case(step)
		2'd0: // React to collision, modify velocity accordingly
		begin		
			if (!reset)
			begin
				storex <= posx;
				storey <= posy;
				
				case (situation) // left, right, top, bottom
					4'b1000, 4'b0100:  // left, right
					begin
						dx <= (!collision) ? dx * -1: dx;
						collision <= 1;
					end
					4'b0010, 4'b0001, 4'b1110, 4'b1101:  // top, bottom, odd case when both sides and top hit
					begin
						dy <= (!collision) ? dy * -1: dy;
						collision <= 1;
					end
					4'b1010, 4'b1001, 4'b0110, 4'b0101: // Corners
					begin
						dx <= (!collision) ? dx * -1: dx;
						dy <= (!collision) ? dy * -1: dy;
						collision <= 1;
					end
					
					default: collision <= 0;
					
				endcase
			
			end
			else // Handle a reset
			begin 
				storex <= initialx;
				storey <= initialy;
				dx <= 0;
				dy <= initialdy;
			end 
			step <= step + 1;
		end
		2'd1: // apply gravity
		begin
			if (gravity_ctr == gravity_rate)
			begin // only accelerate if under max speed
				// make sure to subract unsigned numbers only
				if (dy < max_velo)
				begin
					dy <= (dy > 0) ? dy + gravity_magnitude : -1 * ((dy * -1) - gravity_magnitude);
				end
				else dy <= dy;
				gravity_ctr <= 0; // reset counter
			end
			else gravity_ctr <= gravity_ctr + 1;
			
			dx <= dx;
			
			step <= step + 1;
		end
		2'd2: // update location
		begin
			newx <= storex + dx;
			newy <= storey + dy;
			step <= 2'd0; // back to start
		end
		default: step <= 2'd0; // back to start;
	endcase
end

/******************************* functions ******************/    

assign situation[3] = (posx < 20); // left
assign situation[2] = (posx > 240); // right
assign situation[1] = (posy < 20); // top
assign situation[0] = (posy > 240); // bottom

function [3:0] SITUATION;
input topLX, topLY; 
	SITUATION = {CHECK_LEFT(topLX), CHECK_RIGHT(topLX), CHECK_UPPER(topLY), CHECK_LOWER(topLY)};
endfunction
    
function [0:0] CHECK_UPPER; // 0010
input topLY;
	CHECK_UPPER = (topLY < 20);
endfunction

function [0:0]CHECK_LOWER; // 0001
input topLY;
	CHECK_LOWER = (topLY > 230);
endfunction

function [0:0] CHECK_LEFT; //1000
input topLX;
	CHECK_LEFT = (topLX <= size);
endfunction

function [0:0] CHECK_RIGHT; //0100
input topLX;
	CHECK_RIGHT = ((topLX + size) >= (8'd255 - size));
	endfunction
    

endmodule
