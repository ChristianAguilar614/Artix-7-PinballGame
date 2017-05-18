// File: StartScreen.v
// This is the start screen layout for EE178 Final Lab.

// The `timescale directive specifies what the
// simulation time units are (1 ns here) and what
// the simulator time step should be (1 ps here).

`timescale 1 ns / 1 ps

// Declare the module and its ports. This is
// using Verilog-2001 syntax.
//////////////////////////////////////////////////////////////////////////////////


module StartScreen(
	input wire pclk,
	output reg [7:0] startx = 0,
	output reg [7:0] starty = 0,
	output reg [7:0] endx = 0,
	output reg [7:0] endy = 0,
	output reg [1:0] mode = 0,
	output reg [3:0] beam = 0,
	input wire busy,
	output reg go = 0
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
reg [4:0] setup_state = 0;
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
                    //Letter P
					5'h0: {startx, starty, endx, endy, beam, mode} <= {8'd67, 8'd55, 8'd67, 8'd116, REG_DATA_BEAM_HI, REG_DATA_MODE_HLD};
					5'h1: {startx, starty, endx, endy, beam, mode} <= {8'd101, 8'd55, 8'd101, 8'd85, REG_DATA_BEAM_HI, REG_DATA_MODE_HLD};
					5'h2: {startx, starty, endx, endy, beam, mode} <= {8'd67, 8'd55, 8'd101, 8'd55, REG_DATA_BEAM_HI, REG_DATA_MODE_HLD}; 
					5'h3: {startx, starty, endx, endy, beam, mode} <= {8'd67, 8'd85, 8'd101, 8'd85, REG_DATA_BEAM_HI, REG_DATA_MODE_HLD}; 
					//Letter I
					5'h4: {startx, starty, endx, endy, beam, mode} <= {8'd126, 8'd55, 8'd126, 8'd116, REG_DATA_BEAM_HI, REG_DATA_MODE_HLD}; 
					5'h5: {startx, starty, endx, endy, beam, mode} <= {8'd114, 8'd55, 8'd139, 8'd55, REG_DATA_BEAM_HI, REG_DATA_MODE_HLD}; 
					5'h6: {startx, starty, endx, endy, beam, mode} <= {8'd114, 8'd116, 8'd139, 8'd116, REG_DATA_BEAM_HI, REG_DATA_MODE_HLD}; 
					//Letter N
					5'h7: {startx, starty, endx, endy, beam, mode} <= {8'd151, 8'd55, 8'd151, 8'd116, REG_DATA_BEAM_HI, REG_DATA_MODE_HLD};
					5'h8: {startx, starty, endx, endy, beam, mode} <= {8'd189, 8'd55, 8'd189, 8'd116, REG_DATA_BEAM_HI, REG_DATA_MODE_HLD}; 
					5'hA: {startx, starty, endx, endy, beam, mode} <= {8'd151, 8'd55, 8'd189, 8'd116, REG_DATA_BEAM_HI, REG_DATA_MODE_HLD}; 
					//Letter B
					5'hB: {startx, starty, endx, endy, beam, mode} <= {8'd40, 8'd139, 8'd40, 8'd200, REG_DATA_BEAM_HI, REG_DATA_MODE_HLD};
					5'hC: {startx, starty, endx, endy, beam, mode} <= {8'd74, 8'd139, 8'd74, 8'd200, REG_DATA_BEAM_HI, REG_DATA_MODE_HLD};
					5'hD: {startx, starty, endx, endy, beam, mode} <= {8'd40, 8'd139, 8'd74, 8'd139, REG_DATA_BEAM_HI, REG_DATA_MODE_HLD};
					5'hE: {startx, starty, endx, endy, beam, mode} <= {8'd40, 8'd169, 8'd74, 8'd169, REG_DATA_BEAM_HI, REG_DATA_MODE_HLD};
					5'hF: {startx, starty, endx, endy, beam, mode} <= {8'd40, 8'd200, 8'd74, 8'd200, REG_DATA_BEAM_HI, REG_DATA_MODE_HLD};
					//Letter A
					5'h10: {startx, starty, endx, endy, beam, mode} <= {8'd40, 8'd139, 8'd40, 8'd200, REG_DATA_BEAM_HI, REG_DATA_MODE_HLD}; //leter A
					5'h11: {startx, starty, endx, endy, beam, mode} <= {8'd86, 8'd139, 8'd86, 8'd200, REG_DATA_BEAM_HI, REG_DATA_MODE_HLD};
					5'h12: {startx, starty, endx, endy, beam, mode} <= {8'd120, 8'd139, 8'd120, 8'd200, REG_DATA_BEAM_HI, REG_DATA_MODE_HLD};
					5'h13: {startx, starty, endx, endy, beam, mode} <= {8'd86, 8'd139, 8'd120, 8'd139, REG_DATA_BEAM_HI, REG_DATA_MODE_HLD};
					//Letter L
					5'h14: {startx, starty, endx, endy, beam, mode} <= {8'd86, 8'd169, 8'd120, 8'd169, REG_DATA_BEAM_HI, REG_DATA_MODE_HLD};
					5'h15: {startx, starty, endx, endy, beam, mode} <= {8'd134, 8'd139, 8'd134, 8'd200, REG_DATA_BEAM_HI, REG_DATA_MODE_HLD};
					//Letter L
					5'h16: {startx, starty, endx, endy, beam, mode} <= {8'd182, 8'd139, 8'd182, 8'd200, REG_DATA_BEAM_HI, REG_DATA_MODE_HLD};
					5'h17: {startx, starty, endx, endy, beam, mode} <= {8'd182, 8'd200, 8'd216, 8'd200, REG_DATA_BEAM_HI, REG_DATA_MODE_HLD};  
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
        	end
        	else go <= 0; // else end the go pulse
        end
	end
	else go <= 0;
end

endmodule