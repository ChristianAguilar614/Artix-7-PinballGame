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
    output wire [7:0] write_data,
    output wire [2:0] address
    );
    
//************* might be unessisary ******
reg go = 0;
wire busy;
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

localparam [7:0] REG_DATA_BUSY_GO = 8'h01;
localparam [7:0] REG_DATA_BEAM_HI = 8'h0f;
localparam [7:0] REG_DATA_BEAM_MD = 8'h07;
localparam [7:0] REG_DATA_BEAM_LO = 8'h03;
localparam [7:0] REG_DATA_MODE_HLD = 8'h00;
localparam [7:0] REG_DATA_MODE_CLR = 8'h01;
localparam [7:0] REG_DATA_MODE_LIN = 8'h02;
localparam [7:0] REG_DATA_MODE_EXP = 8'h03;

wire pclk_mirror;
wire vs, hs;
wire [3:0] r, g, b;
//reg [7:0] write_data;
wire [7:0] read_data;
reg [7:0] writeData;
reg [2:0] addr;
reg write;
wire irq;


initial begin
    // Put it into exponential decay mode
    WRITE_REGISTER (REG_ADDR_MODE,REG_DATA_MODE_EXP);
    // Draw with a high intensity
    WRITE_REGISTER (REG_ADDR_BEAM,REG_DATA_BEAM_HI);
    // Draw horizontal and vertical crosshairs 1 of 4
    WRITE_REGISTER (REG_ADDR_STAX,128);
    WRITE_REGISTER (REG_ADDR_STAY,126);
    WRITE_REGISTER (REG_ADDR_ENDX,128);
    WRITE_REGISTER (REG_ADDR_ENDY,100);
    SET_GO_POLL_BUSY;
    // Draw horizontal and vertical crosshairs 2 of 4
    WRITE_REGISTER (REG_ADDR_STAX,128);
    WRITE_REGISTER (REG_ADDR_STAY,130);
    WRITE_REGISTER (REG_ADDR_ENDX,128);
    WRITE_REGISTER (REG_ADDR_ENDY,156);
    SET_GO_POLL_BUSY;
    // Draw horizontal and vertical crossharis 3 of 4
    WRITE_REGISTER (REG_ADDR_STAX,126);
    WRITE_REGISTER (REG_ADDR_STAY,128);
    WRITE_REGISTER (REG_ADDR_ENDX,100);
    WRITE_REGISTER (REG_ADDR_ENDY,128);
    SET_GO_POLL_BUSY;
    // Draw horizontal and veritcal crosshairs 4 of 4
    WRITE_REGISTER (REG_ADDR_STAX,130);
    WRITE_REGISTER (REG_ADDR_STAY,128);
    WRITE_REGISTER (REG_ADDR_ENDX,156);
    WRITE_REGISTER (REG_ADDR_ENDY,128);
    SET_GO_POLL_BUSY;
    
    //DRAW LETTER A
    WRITE_REGISTER (REG_ADDR_STAX,108);
    WRITE_REGISTER (REG_ADDR_STAY,80);
    WRITE_REGISTER (REG_ADDR_ENDX,128);
    WRITE_REGISTER (REG_ADDR_ENDY,10);
    SET_GO_POLL_BUSY;
    WRITE_REGISTER (REG_ADDR_STAX,128);
    WRITE_REGISTER (REG_ADDR_STAY,10);
    WRITE_REGISTER (REG_ADDR_ENDX,148);
    WRITE_REGISTER (REG_ADDR_ENDY,80);
    SET_GO_POLL_BUSY;
    WRITE_REGISTER (REG_ADDR_STAX,120);
    WRITE_REGISTER (REG_ADDR_STAY,40);
    WRITE_REGISTER (REG_ADDR_ENDX,136);
    WRITE_REGISTER (REG_ADDR_ENDY,40);
    SET_GO_POLL_BUSY;
    
    //DRAW NUMBER 4
    WRITE_REGISTER (REG_ADDR_STAX,128);
    WRITE_REGISTER (REG_ADDR_STAY,250);
    WRITE_REGISTER (REG_ADDR_ENDX,128);
    WRITE_REGISTER (REG_ADDR_ENDY,190);
    SET_GO_POLL_BUSY;
    WRITE_REGISTER (REG_ADDR_STAX,128);
    WRITE_REGISTER (REG_ADDR_STAY,190);
    WRITE_REGISTER (REG_ADDR_ENDX,110);
    WRITE_REGISTER (REG_ADDR_ENDY,225);
    SET_GO_POLL_BUSY;
    WRITE_REGISTER (REG_ADDR_STAX,110);
    WRITE_REGISTER (REG_ADDR_STAY,225);
    WRITE_REGISTER (REG_ADDR_ENDX,130);
    WRITE_REGISTER (REG_ADDR_ENDY,225);
    SET_GO_POLL_BUSY;
end
    
    
    reg [7:0] result;
    
  initial
  begin
    result = 8'bx;
    writeData <= 8'bx;
    addr <= 3'bx;
    write <= 1'b0;
  end
  
  // Describe a task that will select a register
  // and write it with data.

  task WRITE_REGISTER;
    // This task is using the negative edge
    // of the pclock to apply the inputs to
    // the register interface centered over
    // the positive edge of the pclock.
    input [2:0] addr;
    input [7:0] data;
  begin
    @(negedge pclk_mirror);
    writeData <= data;
    addr <= addr;
    write <= 1'b0;
    @(negedge pclk_mirror);
    write <= 1'b1;
    @(posedge pclk_mirror) if (write) $display("Info: wrote register %d with data %h",addr,write_data);
    @(negedge pclk_mirror);
    writeData = 8'bx;
    addr <= 3'bx;
    write <= 1'b0;
  end
  endtask

  // Describe a task that will select a register
  // and read out the data.  The value is stored
  // for later use if needed.

  task READ_REGISTER;
    // This task is using the negative edge
    // of the pclock to apply the inputs to
    // the register interface centered over
    // the positive edge of the pclock.
    input [2:0] addr;
  begin
    @(negedge pclk_mirror);
    addr <= addr;
    @(negedge pclk_mirror);
    @(posedge pclk_mirror)
    begin
      result <= read_data;
      $display("Info: read register %d with data %h",addr,read_data);
    end
    @(negedge pclk_mirror);
    addr <= 3'bx;
  end
  endtask

  // Describe a task that will pulse the
  // go bit and wait for not busy status.

  task SET_GO_POLL_BUSY;
    // This task uses the other tasks for
    // writing and reading registers.
  begin
    result = REG_DATA_BUSY_GO;
    WRITE_REGISTER (REG_ADDR_BUSY,result);
    while (result == REG_DATA_BUSY_GO)
    begin
      $display("Info: it is busy, waiting...");
      READ_REGISTER (REG_ADDR_BUSY);
    end
  end
  endtask
    
    
    
//*************** output declarations *********
    assign address = addr;
    assign write_data = writeData;
// ********************************************    
endmodule
