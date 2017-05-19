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
localparam signed [7:0] initialdx = 1;
localparam signed [7:0] max_velo = 4'd8;
localparam [1:0] gravity_magnitude = 2'd1;
localparam [3:0] gravity_rate = 4'd5;

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

assign size = `BS;

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

// Calculation
wire [7:0] BTOP, BBOT, BLEFT, BRIGHT;
assign BTOP = posy;
assign BBOT = posy + `BS;
assign BLEFT = posx;
assign BRIGHT = posx + `BS;


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
							storedy <= (paddle_hit) ? -1 * max_velo: dy * -1;
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

assign situation[3] = CHECK_LEFT(BLEFT, BRIGHT, BTOP, BBOT); //posx < 10); // left
assign situation[2] = CHECK_RIGHT(BLEFT, BRIGHT, BTOP, BBOT); //(posx > 240); // right
assign situation[1] = CHECK_UPPER(BLEFT, BRIGHT, BTOP, BBOT); //(posy < 10); // top
assign situation[0] = CHECK_LOWER(BLEFT, BRIGHT, BTOP, BBOT); //((posy > 240) || ((control[0] && posy > 210) && (posx > 64) && (posx < 106)) || ((control[1] && posy > 210) && (posx > 150) && (posx < 192))); // bottom  

assign paddle_hit = (
						(BBOT >= `LPAD_UP_ENDY && BBOT <= `LPAD_DN_ENDY)
						&& (
							(control[0] && (BRIGHT >= `LPAD_UP_STAX && BLEFT <= `LPAD_UP_ENDX)) 
							|| (control[1] && (BRIGHT >= `RPAD_UP_STAX && BLEFT <= `RPAD_UP_ENDX))
						)
					);


// ******* CHECK TOP ********************************************************************
function CHECK_UPPER; // 0010
input [7:0] LEFT, RIGHT, TOP, BOTTOM;
reg [7:0] x,y;
begin
	CHECK_UPPER = 0;
	
	// Check Top Right Diagonal
	if ((RIGHT >= `TR_DIAG_STAX) && (TOP <= `TR_DIAG_ENDY)) 
	begin
		y = `BOARD_TOP;
		for(x = `TR_DIAG_STAX; x <= `TR_DIAG_ENDX; x = x+1)
		begin
			if ((TOP == y) && (LEFT <= x && RIGHT >= x))
				CHECK_UPPER = 1;
			
			y = y + 1;
		end
	end
	
	// Check Center Obstacle
	else if ((RIGHT >= `CTR_STAX && LEFT <= `CTR_ENDX) && (BOTTOM >= `CTR_TOPY && TOP <= `CTR_BOTY)) 
	begin
		y = `CTR_TOPY;
		
		// Center Right Diagonal 
		for(x = `CTR_MIDX; x <= `CTR_ENDX; x = x+1) 
		begin
			
			if ((TOP == y) && (LEFT <= x && RIGHT >= x))
				CHECK_UPPER = 1;
			
			y = y + 1;
		end
		
		// Center Left Diagonal 
		for (x = `CTR_STAX; x <= `CTR_MIDX; x = x+1)
		begin
			if ((TOP == y) && (LEFT <= x && RIGHT >= x))
				CHECK_UPPER = 1;
			
			y = y - 1;
		end
	end
	
	else CHECK_UPPER = (TOP <= `BOARD_TOP); //default top case
end
endfunction

	
	
// ******* CHECK BOTTOM *****************************************************************
function CHECK_LOWER; // 0001
input [7:0] LEFT, RIGHT, TOP, BOTTOM;
reg [7:0] x, y;
begin
	CHECK_LOWER = 0;
	
	// Check Bottom Left Diagonal
	if ((LEFT <= `LBUMP_DIAG_ENDX) && (BOTTOM >= `LBUMP_DIAG_STAY && TOP <= `LBUMP_DIAG_ENDY))
	begin
		y = `LBUMP_DIAG_STAY;
		for(x = `LBUMP_DIAG_STAX; x <= `LBUMP_DIAG_ENDX; x = x+1)
		begin
			if ((BOTTOM == y) && (LEFT <= x && RIGHT >= x))
				CHECK_LOWER = 1;
			
			y = y + 1;
		end	
	end
	
	// Check Bottom Right Diagonal
	else if ((RIGHT >= `RBUMP_DIAG_STAX) && (BOTTOM >= `RBUMP_DIAG_ENDY && TOP <= `RBUMP_DIAG_STAY)) 
	begin
		y = `RBUMP_DIAG_STAY;
		for(x = `RBUMP_DIAG_STAX; x <= `RBUMP_DIAG_ENDX; x = x+1)
		begin
			if ((BOTTOM == y) && (LEFT <= x && RIGHT >= x))
				CHECK_LOWER = 1;
				
			y = y - 1;
		end	
	end
	
	// Check Center Obstacle
	else if ((RIGHT >= `CTR_STAX && LEFT <= `CTR_ENDX) && (BOTTOM >= `CTR_TOPY && TOP <= `CTR_BOTY))
	begin
		
		y = `CTR_TOPY;
		
		// Center Right Diagonal 
		for (x = `CTR_MIDX; x <= `CTR_ENDX; x = x+1) 
		begin
			
			if ((BOTTOM == y) && (LEFT <= x && RIGHT >= x))
				CHECK_LOWER = 1;
			
			y = y + 1;
		end
		
		// Center Left Diagonal 
		for (x = `CTR_STAX; x <= `CTR_MIDX; x = x+1)
		begin
			if ((BOTTOM == y) && (LEFT <= x && RIGHT >= x))
				CHECK_LOWER = 1;
			
			y = y - 1;
		end
	end
	

	else CHECK_LOWER = paddle_hit || (BOTTOM >= `BOARD_BOT_BARRIER); // bottom  ;
end
endfunction
	

// ******* CHECK LEFT *******************************************************************
function CHECK_LEFT; //1000
input [7:0] LEFT, RIGHT, TOP, BOTTOM;
reg [7:0] x,y;
begin
	CHECK_LEFT = 0;
	
	// Check Bottom Left Diagonal
	if ((LEFT <= `LBUMP_DIAG_ENDX) && (BOTTOM >= `LBUMP_DIAG_STAY && TOP <= `LBUMP_DIAG_ENDY))
	begin
		y = `LBUMP_DIAG_STAY;
		for(x = `LBUMP_DIAG_STAX; x <= `LBUMP_DIAG_ENDX; x = x+1)
		begin
			if ((LEFT == x) && (TOP <= y && BOTTOM >= y))
				CHECK_LEFT = 1;
				
			y = y + 1;
		end	
	end
	
	// Check Center Obstacle
	else if ((RIGHT >= `CTR_STAX && LEFT <= `CTR_ENDX) && (BOTTOM >= `CTR_TOPY && TOP <= `CTR_BOTY))
	begin
		y = `CTR_TOPY;
		
		// Center Right Diagonal
		for (x = `CTR_MIDX; x <= `CTR_ENDX; x = x+1) 
		begin
			if ((LEFT == x) && (TOP <= y && BOTTOM >= y))
				CHECK_LEFT = 1;
			
			y = y + 1;
		end
		
		// Center Left Diagonal
		for (x = `CTR_STAX; x <= `CTR_MIDX; x = x+1)
		begin
			if ((LEFT == x) && (TOP <= y && BOTTOM >= y))
				CHECK_LEFT = 1;
			
			y = y - 1;
		end
	end
	else CHECK_LEFT = (LEFT <= `BOARD_LEFT) || (LEFT <= `LBUMP_DIAG_ENDX && BOTTOM >= `LBUMP_DIAG_ENDY); //default condition
end
endfunction

	
// ******* CHECK RIGHT ******************************************************************
function CHECK_RIGHT; //0100
input [7:0] LEFT, RIGHT, TOP, BOTTOM;
reg [7:0] x,y;
begin
	CHECK_RIGHT = 0;
	
	// Check Top Right Diagonal
	if ((RIGHT >= `TR_DIAG_STAX) && (TOP <= `TR_DIAG_ENDY)) 
	begin
		y = `BOARD_TOP;
		for(x = `TR_DIAG_STAX; x <= `TR_DIAG_ENDX; x = x+1)
		begin
			if ((RIGHT == x) && (TOP <= y && BOTTOM >= y))
				CHECK_RIGHT = 1;
			
			y = y + 1;
		end
	end
	
	// Check Bottom Right Diagonal
	else if ((RIGHT >= `RBUMP_DIAG_STAX) && (BOTTOM >= `RBUMP_DIAG_ENDY && TOP <= `RBUMP_DIAG_STAY)) 
	begin
		y = `RBUMP_DIAG_STAY;
		for(x = `RBUMP_DIAG_STAX; x <= `RBUMP_DIAG_ENDX; x = x+1)
		begin
			if ((RIGHT == x) && (TOP <= y && BOTTOM >= y))
				CHECK_RIGHT = 1;
			
			y = y - 1;
		end	
	end
	
	// Check Center Obstacle
	else if ((RIGHT >= `CTR_STAX && LEFT <= `CTR_ENDX) && (BOTTOM >= `CTR_TOPY && TOP <= `CTR_BOTY))
	begin
		y = `CTR_TOPY;
		
		// Center Right Diagonal
		for (x = `CTR_MIDX; x <= `CTR_ENDX; x = x+1) 
		begin
			if ((RIGHT == x) && (TOP <= y && BOTTOM >= y))
				CHECK_RIGHT = 1;
			
			y = y + 1;
		end
		
		// Center Left Diagonal
		for (x = `CTR_STAX; x <= `CTR_MIDX; x = x+1)
		begin
			if ((RIGHT == x) && (TOP <= y && BOTTOM >= y))
				CHECK_RIGHT = 1;
			
			y = y - 1;
		end	
	end	
	else CHECK_RIGHT = (RIGHT >= `BOARD_RIGHT) || (RIGHT >= `RBUMP_DIAG_STAX && BOTTOM >= `LBUMP_DIAG_STAY);
end
endfunction
    

endmodule


