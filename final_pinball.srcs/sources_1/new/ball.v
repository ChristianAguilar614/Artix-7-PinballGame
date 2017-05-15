// File: ball.v
// This is the ball design for EE178 Final Project.

// The `timescale directive specifies what the
// simulation time units are (1 ns here) and what
// the simulator time step should be (1 ps here).

`timescale 1 ns / 1 ps

// Declare the module and its ports. This is
// using Verilog-2001 syntax.
//////////////////////////////////////////////////////////////////////////////////
`define gravity 1
`define max_velo 3

module ball(
    input wire clk,
    input wire board,
    output reg topleft_x = 4'h0000, // just store single corner
    output reg topleft_y = 4'h0000, // others can be calculated
    
    output wire size
    );
     
//    reg speed;
//    reg gravityConstant;
//    reg curX, curY;
//    reg nextX, nextY;
//    //nothing yet
//    //will do all movement for ball
    
    
    reg dx = 0; 
    reg dy = 0;
    
    // set size of ball ?
    assign size = 1'h4;
    
    always @(posedge clk)
    begin
        // Check Collision on current location
        // check top
            //for all point between top left and right
                // if matching pixel found with environment
                    // swap dy
                    // break (dont want multiple swaps per side
        // check bottom
            //for all point between bottom left and right
               // if matching pixel found with environment
                    //swap dy
                    // break (dont want multiple swaps per side
        // check left
        //for all point between left top and bottom
              // if matching pixel found with environment
                    //swap dx
                    // break (dont want multiple swaps per side
        // check right
        //for all point between right top and bott
              // if matching pixel found with environment
                    //swap dx
                    // break (dont want multiple swaps per side

        // Apply Air Resistance?
        dx <= dx; //(dx > 0) ? dx - 1: ((dx < 0) ? dx + 1 : 0);
         
        // Apply Gravity (up to max fall speed)
        dy <= (dy > -3 || dy < 3) ? dy - `gravity: dy;
        
        // move ball
        topleft_x <= topleft_x + dx;
        topleft_y <= topleft_y + dy;
        
    
    end
    

endmodule
