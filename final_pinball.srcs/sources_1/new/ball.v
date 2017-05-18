// File: ball.v
// This is the ball design for EE178 Final Project.

// The `timescale directive specifies what the
// simulation time units are (1 ns here) and what
// the simulator time step should be (1 ps here).

`timescale 1 ns / 1 ps

// Declare the module and its ports. This is
// using Verilog-2001 syntax.
//////////////////////////////////////////////////////////////////////////////////
localparam [3:0] max_velo = 4'd3;
localparam [1:0] gravity = 2'd1;


module ball(
    input wire gameclk,
    output reg [7:0] topleft_x = 8'd230, // just store single corner
    output reg [7:0] topleft_y = 8'd100, // others can be calculated
    output wire [3:0] size
    );
    
    
reg [1:0] dx = 1; 
reg [1:0] dy = 1;

// set size of ball ?
assign size = 4'h4;
reg [3:0] count = 4'b0000;
reg isLeft, isRight, isTop, isBot;
reg [3:0] situations;

always @(posedge gameclk)
begin
    
    //sets the collision logic in anticipation of the maximum declared speed of ball
    //max = 10 pixle movements per framerate
    case (count)
		4'h0: 
			begin 
				//move ball on entry
				 topleft_x = topleft_x + dx;
				 topleft_y = topleft_y + dy;
				 
				 isLeft <= CHECK_LEFT(topleft_x, topleft_y);
				 isRight <= CHECK_RIGHT(topleft_x, topleft_y);
				 isTop <= CHECK_LOWER(topleft_x, topleft_y);
				 isBot <= CHECK_UPPER(topleft_x, topleft_y);
				 
				 situations = {isLeft, isTop, isRight, isBot};
				 case(situations)
					4'b0001, 4'b0100 : dy = ~(dy); 	//Bottom and Top only collision
					4'b0010, 4'b1000 : dx = ~(dx);	//Right and Left only collision
					4'b0011, 4'b0101, 4'b1001, 4'b1100 : 
						begin
							dx = ~(dx);
							dy = ~(dy);
						end
				 endcase 
			end
		4'h1: begin 
				//move ball on entry
				 topleft_x = topleft_x + dx;
				 topleft_y = topleft_y + dy;
				 
				 //check for collisions
				 isLeft <= CHECK_LEFT(topleft_x, topleft_y);
				 isRight <= CHECK_RIGHT(topleft_x, topleft_y);
				 isTop <= CHECK_LOWER(topleft_x, topleft_y);
				 isBot <= CHECK_UPPER(topleft_x, topleft_y);
				 
				 //change bounce actions when collision is detected
				 situations = {isLeft, isTop, isRight, isBot};
				 case(situations)
					4'b0001, 4'b0100 : dy = ~(dy); 	//Bottom and Top only collision
					4'b0010, 4'b1000 : dx = ~(dx);	//Right and Left only collision
					4'b0011, 4'b0101, 4'b1001, 4'b1100 : 
						begin
							dx = ~(dx);
							dy = ~(dy);
						end
				 endcase
			end
		4'h2: begin 
				//move ball on entry
				 topleft_x = topleft_x + dx;
				 topleft_y = topleft_y + dy;
				 
				 //check for collisions
				 isLeft <= CHECK_LEFT(topleft_x, topleft_y);
				 isRight <= CHECK_RIGHT(topleft_x, topleft_y);
				 isTop <= CHECK_LOWER(topleft_x, topleft_y);
				 isBot <= CHECK_UPPER(topleft_x, topleft_y);
				 
				 //change bounce actions when collision is detected
				 situations = {isLeft, isTop, isRight, isBot};
				 case(situations)
					4'b0001, 4'b0100 : dy = ~(dy); 	//Bottom and Top only collision
					4'b0010, 4'b1000 : dx = ~(dx);	//Right and Left only collision
					4'b0011, 4'b0101, 4'b1001, 4'b1100 : 
						begin
							dx = ~(dx);
							dy = ~(dy);
						end
				 endcase
			end
		4'h3: begin 
				//move ball on entry
				 topleft_x = topleft_x + dx;
				 topleft_y = topleft_y + dy;
				 
				 //check for collisions
				 isLeft <= CHECK_LEFT(topleft_x, topleft_y);
				 isRight <= CHECK_RIGHT(topleft_x, topleft_y);
				 isTop <= CHECK_LOWER(topleft_x, topleft_y);
				 isBot <= CHECK_UPPER(topleft_x, topleft_y);
				 
				 //change bounce actions when collision is detected
				 situations = {isLeft, isTop, isRight, isBot};
				 case(situations)
					4'b0001, 4'b0100 : dy = ~(dy); 	//Bottom and Top only collision
					4'b0010, 4'b1000 : dx = ~(dx);	//Right and Left only collision
					4'b0011, 4'b0101, 4'b1001, 4'b1100 : 
						begin
							dx = ~(dx);
							dy = ~(dy);
						end
				 endcase
			end
		4'h4: begin 
				//move ball on entry
				 topleft_x = topleft_x + dx;
				 topleft_y = topleft_y + dy;
				 
				 //check for collisions
				 isLeft <= CHECK_LEFT(topleft_x, topleft_y);
				 isRight <= CHECK_RIGHT(topleft_x, topleft_y);
				 isTop <= CHECK_LOWER(topleft_x, topleft_y);
				 isBot <= CHECK_UPPER(topleft_x, topleft_y);
				 
				 //change bounce actions when collision is detected
				 situations = {isLeft, isTop, isRight, isBot};
				 case(situations)
					4'b0001, 4'b0100 : dy = ~(dy); 	//Bottom and Top only collision
					4'b0010, 4'b1000 : dx = ~(dx);	//Right and Left only collision
					4'b0011, 4'b0101, 4'b1001, 4'b1100 : 
						begin
							dx = ~(dx);
							dy = ~(dy);
						end
				 endcase
			end
		4'h5: begin 
				//move ball on entry
				 topleft_x = topleft_x + dx;
				 topleft_y = topleft_y + dy;
				 
				 //check for collisions
				 isLeft <= CHECK_LEFT(topleft_x, topleft_y);
				 isRight <= CHECK_RIGHT(topleft_x, topleft_y);
				 isTop <= CHECK_LOWER(topleft_x, topleft_y);
				 isBot <= CHECK_UPPER(topleft_x, topleft_y);
				 
				 //change bounce actions when collision is detected
				 situations = {isLeft, isTop, isRight, isBot};
				 case(situations)
					4'b0001, 4'b0100 : dy = ~(dy); 	//Bottom and Top only collision
					4'b0010, 4'b1000 : dx = ~(dx);	//Right and Left only collision
					4'b0011, 4'b0101, 4'b1001, 4'b1100 : 
						begin
							dx = ~(dx);
							dy = ~(dy);
						end
				 endcase
			end
		4'h6: begin 
				//move ball on entry
				 topleft_x = topleft_x + dx;
				 topleft_y = topleft_y + dy;
				 
				 //check for collisions
				 isLeft <= CHECK_LEFT(topleft_x, topleft_y);
				 isRight <= CHECK_RIGHT(topleft_x, topleft_y);
				 isTop <= CHECK_LOWER(topleft_x, topleft_y);
				 isBot <= CHECK_UPPER(topleft_x, topleft_y);
				 
				 //change bounce actions when collision is detected
				 situations = {isLeft, isTop, isRight, isBot};
				 case(situations)
					4'b0001, 4'b0100 : dy = ~(dy); 	//Bottom and Top only collision
					4'b0010, 4'b1000 : dx = ~(dx);	//Right and Left only collision
					4'b0011, 4'b0101, 4'b1001, 4'b1100 : 
						begin
							dx = ~(dx);
							dy = ~(dy);
						end
				 endcase
			end
		4'h7: begin 
				//move ball on entry
				 topleft_x = topleft_x + dx;
				 topleft_y = topleft_y + dy;
				 
				 //check for collisions
				 isLeft <= CHECK_LEFT(topleft_x, topleft_y);
				 isRight <= CHECK_RIGHT(topleft_x, topleft_y);
				 isTop <= CHECK_LOWER(topleft_x, topleft_y);
				 isBot <= CHECK_UPPER(topleft_x, topleft_y);
				 
				 //change bounce actions when collision is detected
				 situations = {isLeft, isTop, isRight, isBot};
				 case(situations)
					4'b0001, 4'b0100 : dy = ~(dy); 	//Bottom and Top only collision
					4'b0010, 4'b1000 : dx = ~(dx);	//Right and Left only collision
					4'b0011, 4'b0101, 4'b1001, 4'b1100 : 
						begin
							dx = ~(dx);
							dy = ~(dy);
						end
				 endcase
			end
		4'h8: begin 
				//move ball on entry
				 topleft_x = topleft_x + dx;
				 topleft_y = topleft_y + dy;
				 
				 //check for collisions
				 isLeft <= CHECK_LEFT(topleft_x, topleft_y);
				 isRight <= CHECK_RIGHT(topleft_x, topleft_y);
				 isTop <= CHECK_LOWER(topleft_x, topleft_y);
				 isBot <= CHECK_UPPER(topleft_x, topleft_y);
				 
				 //change bounce actions when collision is detected
				 situations = {isLeft, isTop, isRight, isBot};
				 case(situations)
					4'b0001, 4'b0100 : dy = ~(dy); 	//Bottom and Top only collision
					4'b0010, 4'b1000 : dx = ~(dx);	//Right and Left only collision
					4'b0011, 4'b0101, 4'b1001, 4'b1100 : 
						begin
							dx = ~(dx);
							dy = ~(dy);
						end
				 endcase
			end
		4'h9: begin 
				//move ball on entry
				 topleft_x = topleft_x + dx;
				 topleft_y = topleft_y + dy;
				 
				 //check for collisions
				 isLeft <= CHECK_LEFT(topleft_x, topleft_y);
				 isRight <= CHECK_RIGHT(topleft_x, topleft_y);
				 isTop <= CHECK_LOWER(topleft_x, topleft_y);
				 isBot <= CHECK_UPPER(topleft_x, topleft_y);
				 
				 //change bounce actions when collision is detected
				 situations = {isLeft, isTop, isRight, isBot};
				 case(situations)
					4'b0001, 4'b0100 : dy = ~(dy); 	//Bottom and Top only collision
					4'b0010, 4'b1000 : dx = ~(dx);	//Right and Left only collision
					4'b0011, 4'b0101, 4'b1001, 4'b1100 : 
						begin
							dx = ~(dx);
							dy = ~(dy);
						end
				 endcase
			end
		4'hA: begin 
				//move ball on entry
				 topleft_x = topleft_x + dx;
				 topleft_y = topleft_y + dy;
				 
				 //check for collisions
				 isLeft <= CHECK_LEFT(topleft_x, topleft_y);
				 isRight <= CHECK_RIGHT(topleft_x, topleft_y);
				 isTop <= CHECK_LOWER(topleft_x, topleft_y);
				 isBot <= CHECK_UPPER(topleft_x, topleft_y);
				 
				 //change bounce actions when collision is detected
				 situations = {isLeft, isTop, isRight, isBot};
				 case(situations)
						4'b0001, 4'b0100 : dy = ~(dy); 	//Bottom and Top only collision
						4'b0010, 4'b1000 : dx = ~(dx);	//Right and Left only collision
						4'b0011, 4'b0101, 4'b1001, 4'b1100 : 
							begin
								dx = ~(dx);
								dy = ~(dy);
							end
					 endcase
			end
    endcase
    
	count = count + 1;
	//reset count after a max of 10 movements
	if (count == max_velo && count <= 1'hA) begin
		count = 0;
	end

	// Apply Air Resistance?
	dx <= dx; //(dx > 0) ? dx - 1: ((dx < 0) ? dx + 1 : 0);
	 
	// Apply Gravity (up to max fall speed)
	dy <= (dy > -(max_velo) || dy < max_velo) ? dy - gravity: dy;
	
	// move ball
	topleft_x <= topleft_x + dx;
	topleft_y <= topleft_y + dy;
	

end
    
/******************************* functions ******************/    
    
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
