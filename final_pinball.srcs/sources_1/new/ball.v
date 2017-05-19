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
localparam signed [7:0] initialdy = -7;
localparam signed [7:0] initialdx = 2;
localparam signed [7:0] max_velo = 4'd8;
localparam [1:0] gravity_magnitude = 2'd1;
localparam [3:0] gravity_rate = 4'd5;
localparam [3:0] bs = 4'd8;

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

assign size = bs;

// Initial speed
reg signed [7:0] dx = initialdx; 
reg signed [7:0] dy = initialdy;

reg [7:0] newx = initialx;
reg [7:0] newy = initialy;
reg signed [7:0] newdx = 0;
reg signed [7:0] newdy = initialdy;

reg [3:0] gravity_ctr = 0;
wire gravity_tick = (gravity_ctr == gravity_rate);

always @(posedge gameclk)
begin
	posx <= newx;
	posy <= newy;
	dx <= newdx;
	dy <= newdy;
	
	if (gravity_tick)
	begin
		gravity_ctr <= 0;
	end
	else gravity_ctr <= gravity_ctr + 1;
end





// Storage registers
reg [7:0] storex;
reg [7:0] storey;
reg signed [7:0] storedx;
reg signed [7:0] storedy;
wire [7:0] abs_storedy = (storedy < 0) ? storedy * -1: storedy;


// Status
reg collision = 0;
reg gravity_applied = 0;
wire [3:0] situation;

// Counters

reg [1:0] step = 0;


always @(posedge pclk)
begin
	case(step)
		2'd0: // React to collision at current position, modify velocity accordingly
		begin		
			if (!reset)
			begin
				storex <= posx;
				storey <= posy;
				
				case (situation) // left, right, top, bottom
					4'b1000, 4'b0100, 4'b0011, 4'b1011, 4'b0111:  // left, right
					begin
						// if the collision has not been detected yet
						// flip the velocity
						// otherwise use old value 
						storedx <= (!collision) ? dx * -1: storedx;
						// if collision bit is on we know gravity has been applied
						gravity_applied <= collision;
						storedy <= dy;
						collision <= 1;
					end
					4'b0010, 4'b0001, 4'b1110, 4'b1101, 4'b1100:  // top, bottom, odd case when both sides and top hit
					begin
						if (!collision)
						begin
							storedy <= (bumper_hit) ? -1 * max_velo: dy * -1;
						end
						else storedy <= storedy;
						gravity_applied <= collision;
						storedx <= dx;
						collision <= 1;
					end
					4'b1010, 4'b1001, 4'b0110, 4'b0101: // Corners
					begin
						storedx <= (!collision) ? dy * -1: storedy;
						storedy <= (!collision) ? dx * -1: storedx;
						gravity_applied <= collision;
						collision <= 1;
					end
					
					default: 
					begin
						storedx <= dx;
						storedy <= dy;
						collision <= 0;
						gravity_applied <= 0;
					end
					
				endcase
			
			end
			else // Handle a reset
			begin 
				storex <= initialx;
				storey <= initialy;
				storedx <= initialdx;
				storedy <= initialdy;
				gravity_applied <= 0;
			end 
			step <= step + 1;
		end
		2'd1: // apply gravity
		begin
			if (gravity_tick)
			begin // only accelerate if under max speed
				// make sure to subract unsigned numbers only
				if (storedy < max_velo && !gravity_applied) 
				begin
					// if gravity hasnt been applied yet, apply it
					storedy <= (storedy >= 0) ? storedy + gravity_magnitude : -1 * (abs_storedy - gravity_magnitude);
					gravity_applied <= 1;
				end
				else if (storedy > max_velo) storedy <= max_velo;
				else storedy <= storedy;
			end
			
			storedx <= storedx;
			
			step <= step + 1;
		end
		2'd2: // update location
		begin
			newx <= storex + storedx;
			newy <= storey + storedy;
			newdy <= storedy;
			newdx <= storedx;
			step <= 2'd0; // back to start
		end
		default: step <= 2'd0; // back to start;
	endcase
end

/******************************* functions ******************/    

assign situation[3] = CHECK_LEFT(posx,posy); //posx < 10); // left
assign situation[2] = CHECK_RIGHT(posx,posy); //(posx > 240); // right
assign situation[1] = CHECK_UPPER(posx,posy); //(posy < 10); // top
assign situation[0] = CHECK_LOWER(posx,posy); //((posy > 240) || ((control[0] && posy > 210) && (posx > 64) && (posx < 106)) || ((control[1] && posy > 210) && (posx > 150) && (posx < 192))); // bottom  

assign bumper_hit = ((control[0] && (posy > (210 - size/2 - max_velo))) && (posx > 64) && (posx < 106)) || ((control[1] && (posy > (210 - size/2 - max_velo)) && (posx > 150) && (posx < 192))); // bottom  ;


function [3:0] SITUATION;
input topLX, topLY; 
	SITUATION = {CHECK_LEFT(topLX,topLY), CHECK_RIGHT(topLX,topLY), CHECK_UPPER(topLX,topLY), CHECK_LOWER(topLX,topLY)};
endfunction
    
	
// ******* CHECK TOP ********************************************************************
function [0:0] CHECK_UPPER; // 0010
input [7:0] topLX, topLY;
reg [8:0] x,y;
begin
	CHECK_UPPER = 0;
	
	// Check Top Right Diagonal
	if (topLX + bs >= (215 - bs) && topLY <= (40 + bs)) 
	begin
		y = bs;
		for(x = 215; x <= (255 - bs); x = x+1)
		begin
			if ((topLY == y) && (topLX <= x && topLX+bs >= x))
				CHECK_UPPER = 1;
			
			y = y + 1;
		end
	end
	
	// Check Center Obstacle
	else if ((topLX + bs >= 101 && topLX <= 155) && (topLY + bs >= 93 && topLY <= 120)) 
	begin
		y = 93;
		
		// Center Right Diagonal 
		for(x = 128; x <= 155; x = x+1) 
		begin
			
			if ((topLY == y) && (topLX <= x && topLX+bs >= x))
				CHECK_UPPER = 1;
			
			y = y + 1;
		end
		
		// Center Left Diagonal 
		for(x = 101; x <= 128; x = x+1)
		begin
			if ((topLY == y) && (topLX <= x && topLX+bs >= x))
				CHECK_UPPER = 1;
			
			y = y - 1;
		end
	end
	
	else CHECK_UPPER = (topLY <= bs); //default top case
end
endfunction

	
	
// ******* CHECK BOTTOM *****************************************************************
function [0:0]CHECK_LOWER; // 0001
input [7:0] topLX, topLY;
reg [8:0] x, y;
begin
	CHECK_LOWER = 0;
	
	// Check Bottom Left Diagonal
	if ((topLX <= 60 + bs) && (topLY + bs >= 150 && topLY <= 210))
	begin
		y = 150;
		for(x = bs; x <= (60 + bs); x = x+1)
		begin
			if ((topLY + bs == y) && (topLX <= x && topLX+bs >= x))
				CHECK_LOWER = 1;
			
			y = y + 1;
		end	
	end
	
	// Check Bottom Right Diagonal
	else if ((topLX >= 195 - bs) && (topLY + bs >= 150 && topLY <= 210)) 
	begin
		y = 210;
		for(x = 195 - bs; x <= (255 - bs); x = x+1)
		begin
			if ((topLY + bs == y) && (topLX <= x && topLX+bs >= x))
				CHECK_LOWER = 1;
				
			y = y - 1;
		end	
	end
	
	// Check Center Obstacle
	else if ((topLX + bs >= 101 && topLX <= 155) && (topLY + bs >= 93 && topLY <= 120))
	begin
		
		y = 93;
		
		// Center Right Diagonal 
		for(x = 128; x <= 155; x = x+1) 
		begin
			
			if ((topLY + bs == y) && (topLX <= x && topLX+bs >= x))
				CHECK_LOWER = 1;
			
			y = y + 1;
		end
		
		// Center Left Diagonal 
		for(x = 101; x <= 128; x = x+1)
		begin
			if ((topLY + bs == y) && (topLX <= x && topLX+bs >= x))
				CHECK_LOWER = 1;
			
			y = y - 1;
		end
	end
	

	else CHECK_LOWER = bumper_hit || ((topLY + bs) >= (255 - bs)); // bottom  ;
end
endfunction
	

// ******* CHECK LEFT *******************************************************************
function [0:0] CHECK_LEFT; //1000
input [7:0] topLX, topLY;
reg [8:0] x,y;
begin
	CHECK_LEFT = 0;
	
	// Check Bottom Left Diagonal
	if ((topLX <= 60 + bs) && (topLY + bs >= 150 && topLY <= 210))
	begin
		y = 150;
		for(x = bs; x <= (60 + bs); x = x+1)
		begin
			if ((topLX == x) && (topLY <= y && topLY+bs >= y))
				CHECK_LEFT = 1;
				
			y = y + 1;
		end	
	end
	
	// Check Center Obstacle
	else if ((topLX + bs >= 101 && topLX <= 155) && (topLY + bs >= 93 && topLY <= 120))
	begin
		y = 93;
		
		// Center Right Diagonal
		for(x = 128; x <= 155; x = x+1)
		begin
			if ((topLX == x) && (topLY <= y && topLY+bs >= y))
				CHECK_LEFT = 1;
			
			y = y + 1;
		end
		
		// Center Left Diagonal
		for(x = 101; x <= 128; x = x+1)
		begin
			if ((topLX == x) && (topLY <= y && topLY+bs >= y))
				CHECK_LEFT = 1;
			
			y = y - 1;
		end
	end
	else CHECK_LEFT = (topLX <= bs) || (topLX < (60 + bs) && topLY > 150); //default condition
end
endfunction

	
// ******* CHECK RIGHT ******************************************************************
function [0:0] CHECK_RIGHT; //0100
input [7:0] topLX, topLY;
reg [8:0] x,y;
begin
	CHECK_RIGHT = 0;
	
	// Check Top Right Diagonal
	if (topLX + bs >= (215 - bs) && topLY <= (40 + bs))
	begin
		y = bs;
		for(x = 215 - bs; x <= (255 - bs); x = x+1)
		begin
			if ((topLX + bs == x) && (topLY <= y && topLY+bs >= y))
				CHECK_RIGHT = 1;
			
			y = y + 1;
		end
	end
	
	// Check Bottom Right Diagonal
	else if ((topLX >= 195 - bs) && (topLY + bs >= 150 && topLY <= 210)) 
	begin
		y = 210;
		for(x = 195 - bs; x <= (255 - bs); x = x+1)
		begin
			if ((topLX + bs == x) && (topLY <= y && topLY+bs >= y))
				CHECK_RIGHT = 1;
			
			y = y - 1;
		end	
	end
	
	// Check Center Obstacle
	else if ((topLX + bs >= 101 && topLX <= 155) && (topLY + bs >= 93 && topLY <= 120)) 
	begin
		y = 93;

		// Center Right Diagonal
		for(x = 128; x <= 155; x = x+1)
		begin
			if ((topLX + bs == x) && (topLY <= y && topLY+bs >= y))
				CHECK_RIGHT = 1;
			
			y = y + 1;
		end
		
		// Center Left Diagonal
		for(x = 101; x <= 128; x = x+1)
		begin
			if ((topLX + bs == x) && (topLY <= y && topLY+bs >= y))
				CHECK_RIGHT = 1;
			
			y = y - 1;
		end	
	end	
	else CHECK_RIGHT = ((topLX + bs) >= (255 - bs) || ((topLX + bs) >= (195 - bs) && topLY > 150));
end
endfunction
    

endmodule
