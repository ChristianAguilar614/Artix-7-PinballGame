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
    input wire clk,
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

wire irq;


initial
begin
    // Draw with a high intensity
    // Draw horizontal and vertical crosshairs 1 of 4
     WRITE_REGISTER (128,126,156,100,REG_DATA_BEAM_HI,REG_DATA_MODE_HLD); 
     //SET_GO_POLL_BUSY;
    // Draw horizontal and vertical crosshairs 2 of 4
     WRITE_REGISTER (128,130,128,156,REG_DATA_BEAM_HI,REG_DATA_MODE_HLD); 
     //SET_GO_POLL_BUSY;
    // Draw horizontal and vertical crossharis 3 of 4
     WRITE_REGISTER (126,128,100,128,REG_DATA_BEAM_HI,REG_DATA_MODE_HLD); 
     //SET_GO_POLL_BUSY;
    // Draw horizontal and veritcal crosshairs 4 of 4
    WRITE_REGISTER (130,128,156,128,REG_DATA_BEAM_HI,REG_DATA_MODE_HLD); // write(startx,starty, endx, endy)
    //SET_GO_POLL_BUSY;
    //DRAW LETTER A
    WRITE_REGISTER (108,80,128,10,REG_DATA_BEAM_HI,REG_DATA_MODE_HLD);
    //SET_GO_POLL_BUSY;
    WRITE_REGISTER (128,10,148,80,REG_DATA_BEAM_HI,REG_DATA_MODE_HLD);
    //SET_GO_POLL_BUSY;
    WRITE_REGISTER (120,40,136,40,REG_DATA_BEAM_HI,REG_DATA_MODE_HLD);
    //SET_GO_POLL_BUSY;
    //DRAW NUMBER 4
    WRITE_REGISTER (128,250,128,190,REG_DATA_BEAM_HI,REG_DATA_MODE_HLD);
    //SET_GO_POLL_BUSY;
    WRITE_REGISTER (128,190,110,225,REG_DATA_BEAM_HI,REG_DATA_MODE_HLD);
    //SET_GO_POLL_BUSY;
    WRITE_REGISTER (110,225,130,225,REG_DATA_BEAM_HI,REG_DATA_MODE_HLD);
    //SET_GO_POLL_BUSY;
end
    
    
  reg [1:0] status;
  reg write;
  // Describe a task that will select a register
  // and write it with data.

  task WRITE_REGISTER;
    // This task is using the negative edge
    // of the pclock to apply the inputs to
    // the register interface centered over
    // the positive edge of the pclock.
    input [7:0] data_startx;
    input [7:0] data_starty;
    input [7:0] data_endx;
    input [7:0] data_endy;
    input [3:0] data_beam;
    input [1:0] data_mode;
  begin
      @(posedge pclk) 
      startx <= data_startx;
      starty <= data_starty;
      endx <= data_endx;
      endy <=  data_endy;
      beam <= data_beam;
      mode <= data_mode;
      go <= 1'b1;
      @(posedge pclk);
      go <= 1'b0;
      while (busy)
      begin
        @(posedge pclk);
        $display("Info: it is busy, waiting...");
      end
  end
  endtask

    
    
//*************** output declarations *********
// ********************************************    
endmodule
