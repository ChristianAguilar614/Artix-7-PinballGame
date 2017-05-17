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
	output reg [7:0] startx = 0,
	output reg [7:0] starty = 0,
	output reg [7:0] endx = 0,
	output reg [7:0] endy = 0,
	output reg [1:0] mode = 0,
	output reg [3:0] beam = 0,
	input wire busy,
	output reg go = 0
);
 
//************* might be unessisary ******
reg [17:1] prng = 1;
//************* might be unessisary ******


//local variables indicating various registers and modes
localparam [2:0] REG_ADDR_STAX = 3'd0;
localparam [2:0] REG_ADDR_STAY = 3'd1;
localparam [2:0] REG_ADDR_ENDX = 3'd2;
localparam [2:0] REG_ADDR_ENDY = 3'd3;
localparam [2:0] REG_ADDR_BUSY = 3'd4;
localparam [2:0] REG_ADDR_BEAM = 3'd5;
localparam [2:0] REG_ADDR_MODE = 3'd6;
localparam [2:0] REG_ADDR_PRNG = 3'd7;

localparam [3:0] REG_DATA_BUSY_GO = 8'h01;
localparam [3:0] REG_DATA_BEAM_HI = 8'h0f;
localparam [3:0] REG_DATA_BEAM_MD = 8'h07;
localparam [3:0] REG_DATA_BEAM_LO = 8'h03;
localparam [1:0] REG_DATA_MODE_HLD = 8'h0;
localparam [1:0] REG_DATA_MODE_CLR = 8'h1;
localparam [1:0] REG_DATA_MODE_LIN = 8'h2;
localparam [1:0] REG_DATA_MODE_EXP = 8'h3;


wire setup;
reg [3:0] setup_state = 0;

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
					4'h0: {startx, starty, endx, endy, beam, mode} <= {8'd200, 8'd200, 8'd210, 8'd210, REG_DATA_BEAM_HI, REG_DATA_MODE_HLD};
					4'h1: {startx, starty, endx, endy, beam, mode} <= {8'd128, 8'd200, 8'd128, 8'd210, REG_DATA_BEAM_HI, REG_DATA_MODE_HLD};
					4'h2: {startx, starty, endx, endy, beam, mode} <= {8'd100, 8'd100, 8'd90, 8'd90, REG_DATA_BEAM_HI, REG_DATA_MODE_HLD};
					4'h3: {startx, starty, endx, endy, beam, mode} <= {8'd100, 8'd200, 8'd90, 8'd210, REG_DATA_BEAM_HI, REG_DATA_MODE_HLD};
					4'h4: {startx, starty, endx, endy, beam, mode} <= {8'd200, 8'd100, 8'd210, 8'd90, REG_DATA_BEAM_HI, REG_DATA_MODE_HLD};
					4'h5: {startx, starty, endx, endy, beam, mode} <= {8'd100, 8'd128, 8'd90, 8'd128, REG_DATA_BEAM_HI, REG_DATA_MODE_HLD};
					4'h6: {startx, starty, endx, endy, beam, mode} <= {8'd128, 8'd100, 8'd128, 8'd90, REG_DATA_BEAM_HI, REG_DATA_MODE_HLD};
					4'h7: {startx, starty, endx, endy, beam, mode} <= {8'd200, 8'd128, 8'd210, 8'd128, REG_DATA_BEAM_HI, REG_DATA_MODE_HLD};
					4'h8: ;
                    4'h9: ;
					4'hA: ;
					4'hB: ;
					4'hC: ;
					4'hD: ;
					4'hE: ;
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
            // Pull from ball and levers
        end
	end
	else go <= 0;
end

//*************** output declarations *********
// ********************************************    
endmodule


/*

//borders
    //top horizantal line
    WRITE_REGISTER (4, 4, 252, 4);
    
    //button horizantal line

    WRITE_REGISTER (4, 252, 252, 252);
    
    //Right vertical line

    WRITE_REGISTER (252, 4, 252, 252);

    //left vertical line

    WRITE_REGISTER (4, 4, 4, 252);    
    
    //top right diagonal line

    WRITE_REGISTER (222, 4, 251, 41); 

    //triangle in the middle

    WRITE_REGISTER (86, 120, 127, 96);

    WRITE_REGISTER (127, 96, 168, 120);   
   
    
    //left paddel extention
    
    WRITE_REGISTER (4, 210, 64, 210);
    
    WRITE_REGISTER (4, 154, 64, 210);
     
    WRITE_REGISTER (64, 210, 90, 230);
        
    //right paddel extention

    WRITE_REGISTER (252, 210, 193, 210);
    
    WRITE_REGISTER (252, 154, 193, 210);
     
    WRITE_REGISTER (193, 210, 167, 230);

*/