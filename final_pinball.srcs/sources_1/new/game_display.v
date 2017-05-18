// File: game_display.v
// This is the top level design for EE178 Lab #6.

// The `timescale directive specifies what the
// simulation time units are (1 ns here) and what
// the simulator time step should be (1 ps here).

`timescale 1 ns / 1 ps

// Declare the module and its ports. This is
// using Verilog-2001 syntax.

module game_display (
	input wire clk,
	output reg vs,
	output reg hs,
	output reg [3:0] r,
	output reg [3:0] g,
	output reg [3:0] b,
	input wire [2:0] control,
	//output wire pclk_mirror,
  
	//input wire write,
	output reg irq
);

// Converts 100 MHz clk into 40 MHz pclk.
// This uses a vendor specific primitive
// called MMCME2, for frequency synthesis.

wire clk_in;
wire locked;
wire clk_fb;
wire clk_ss;
wire clk_out;
wire pclk;
(* KEEP = "TRUE" *) 
(* ASYNC_REG = "TRUE" *)
reg [7:0] safe_start = 0;

IBUF clk_ibuf (.I(clk),.O(clk_in));

MMCME2_BASE #(
	.CLKIN1_PERIOD(10.000),
	.CLKFBOUT_MULT_F(10.000),
	.CLKOUT0_DIVIDE_F(25.000))
clk_in_mmcme2 (
	.CLKIN1(clk_in),
	.CLKOUT0(clk_out),
	.CLKOUT0B(),
	.CLKOUT1(),
	.CLKOUT1B(),
	.CLKOUT2(),
	.CLKOUT2B(),
	.CLKOUT3(),
	.CLKOUT3B(),
	.CLKOUT4(),
	.CLKOUT5(),
	.CLKOUT6(),
	.CLKFBOUT(clkfb),
	.CLKFBOUTB(),
	.CLKFBIN(clkfb),
	.LOCKED(locked),
	.PWRDWN(1'b0),
	.RST(1'b0));

BUFH clk_out_bufh (.I(clk_out),.O(clk_ss));
always @(posedge clk_ss) safe_start <= {safe_start[6:0],locked};

BUFGCE clk_out_bufgce (.I(clk_out),.CE(safe_start[7]),.O(pclk));

// Instantiate the vga_timing module, which is
// the module you are designing for this lab.

wire [10:0] vcount, hcount;
wire vsync, hsync;
wire vblnk, hblnk;

vga_timing my_timing (
	.vcount(vcount),
	.vsync(vsync),
	.vblnk(vblnk),
	.hcount(hcount),
	.hsync(hsync),
	.hblnk(hblnk),
	.pclk(pclk)
);

// Create a slower clock for the game movements;

reg [2:0] frame_counter = 0;
wire gameclk;

assign gameclk = (frame_counter == 0); // clk every 6 (0-5) frames, or 10 FPS

always @(posedge vsync)
begin
	if (frame_counter == 2) frame_counter <= 0;
	else frame_counter <= frame_counter + 1;
end

// We want to put the 256x256 framebuffer into
// the visual center of the 800x600 display.
// Generate an offset for the beam position to
// reference upper left pixel of framebuffer
// as its origin, form the framebuffer address
// and a signal to indicate we are displaying
// the framebuffer or not.

wire [10:0] framebuffer_vpos;
wire [10:0] framebuffer_hpos;
wire [15:0] framebuffer_addr;
wire        framebuffer_ena;
wire        framebuffer_wr;

assign framebuffer_vpos = vcount - 172;
assign framebuffer_hpos = hcount - 272;
assign framebuffer_addr = {framebuffer_vpos[7:0],framebuffer_hpos[7:0]};
assign framebuffer_ena = &{~framebuffer_vpos[10:8],~framebuffer_hpos[10:8]};
assign framebuffer_wr = framebuffer_ena && framebuffer_addr[0];

// Look up pixel pairs on the framebuffer b-port
// which has a clock cycle latency.  This look up
// done with the framebuffer address, a transformed
// version of beam position that was generated above.
// Here also declare (and hook up) another set of
// signals on the framebuffer a-port which is
// going to be used later in the code for the line
// drawing function.

wire [7:0] framebuffer_pixelpair_out;
reg [7:0] framebuffer_pixelpair_in;
wire [1:0] framebuffer_mode;

wire linedraw_wr;
wire [15:0] linedraw_addr;
wire [3:0] linedraw_pixel_in;
wire [3:0] linedraw_pixel_out;

framebuffer my_framebuffer (
	.clka(pclk),
	.wea(linedraw_wr),
	.addra(linedraw_addr),
	.dina(linedraw_pixel_in),
	.douta(linedraw_pixel_out),
	.clkb(pclk),
	.web(framebuffer_wr),
	.addrb(framebuffer_addr[15:1]),
	.dinb(framebuffer_pixelpair_in),
	.doutb(framebuffer_pixelpair_out)
);

// As pixels are read out of the framebuffer
// for display, the values are written back
// into the framebuffer, with one of four
// selectable modifications:
// mode = 0: hold
//           write back without change, to
//           preserve the original pixel
// mode = 1: fill
//           write back a constant, in this
//           particular implementation, zero
//           to quickly "erase" framebuffer
// mode = 2: exponential decay
//           write back the pixel, shifted
//           right by one, for exponential
//           decay of intensity (this gives
//           low persistence)
// mode = 3: linear decay
//           write back the pixel, subtract
//           one with saturation at zero,
//           for linear decay of intensity
//           (this gives high persistence)
// This is done on pixel pairs, and is the
// driving reason for the framebuffer to
// look up two pixel pairs per cycle, so
// that over two clock cycles, two pixels
// are read in the first cycle, then two
// pixels are written in the second cycle,
// achieving the necessary throughput of
// one pixel per cycle.

always @*
begin
case (framebuffer_mode)
	0: framebuffer_pixelpair_in = framebuffer_pixelpair_out; // hold
	1: framebuffer_pixelpair_in = 8'h00; // fill with black - fast erase
	2: begin // linear decay
		if (framebuffer_pixelpair_out[3:0] == 4'h0) framebuffer_pixelpair_in[3:0] = 4'h0;
		else framebuffer_pixelpair_in[3:0] = framebuffer_pixelpair_out[3:0] - 4'h1;
		if (framebuffer_pixelpair_out[7:4] == 4'h0) framebuffer_pixelpair_in[7:4] = 4'h0;
		else framebuffer_pixelpair_in[7:4] = framebuffer_pixelpair_out[7:4] - 4'h1;
	end
	3: begin // exponential decay
		if (framebuffer_pixelpair_out[3:0] == 4'h0) framebuffer_pixelpair_in[3:0] = 4'h0;
		else framebuffer_pixelpair_in[3:0] = framebuffer_pixelpair_out[3:0] >> 1;
		if (framebuffer_pixelpair_out[7:4] == 4'h0) framebuffer_pixelpair_in[7:4] = 4'h0;
		else framebuffer_pixelpair_in[7:4] = framebuffer_pixelpair_out[7:4] >> 1;
	end
	default: framebuffer_pixelpair_in = 8'bx;
endcase
end

// Delay other display signals not going
// through the framebuffer (they are going
// "around" the frame buffer) by a cycle
// to keep them moving in unison with the
// memory access.

reg [10:0] vcount_delayed, hcount_delayed = 0;
reg vsync_delayed, hsync_delayed = 0;
reg vblnk_delayed, hblnk_delayed = 0;
reg framebuffer_pixelpair_out_sel = 0;
reg framebuffer_pixelpair_out_ena = 0;
reg vblnk_delayed_twice = 0;

always @(posedge pclk)
begin
	vcount_delayed <= vcount;
	hcount_delayed <= hcount;
	vsync_delayed <= vsync;
	hsync_delayed <= hsync;
	vblnk_delayed <= vblnk;
	hblnk_delayed <= hblnk;
	framebuffer_pixelpair_out_sel <= framebuffer_addr[0];
	framebuffer_pixelpair_out_ena <= framebuffer_ena;
	vblnk_delayed_twice <= vblnk_delayed;
end

// This is a simple test pattern generator.
// It uses the previous design but has been
// modified to use framebuffer output and
// the correspondingly delayed timing.

always @(posedge pclk)
begin
	// Just pass these through.
	hs <= hsync_delayed;
	vs <= vsync_delayed;
	// During blanking, make it it black.
	if (vblnk_delayed || hblnk_delayed) {r,g,b} <= 12'h0_0_0; 
	else
	begin
		// Active display, top edge, make a yellow line.
		if (vcount_delayed == 0) {r,g,b} <= 12'h0_0_f;
		// Active display, bottom edge, make a red line.
		else if (vcount_delayed == 599) {r,g,b} <= 12'h0_0_f;
		// Active display, left edge, make a green line.
		else if (hcount_delayed == 0) {r,g,b} <= 12'h0_0_f;
		// Active display, right edge, make a blue line.
		else if (hcount_delayed == 799) {r,g,b} <= 12'h0_0_f;
		// Active display, in framebuffer region.
		else if (framebuffer_pixelpair_out_ena)
		begin
			if (framebuffer_pixelpair_out_sel) {r,g,b} <= {3{framebuffer_pixelpair_out[7:4]}};
			else {r,g,b} <= {3{framebuffer_pixelpair_out[3:0]}};        
		end
		// Active display, default color.
		else {r,g,b} <= 12'h0_0_0;     ///8_8_8 previous value
	end
	// Vertical blanking irq.
	irq <= vblnk_delayed && !vblnk_delayed_twice;
end



//*************** Ball Instantiation *********
wire [7:0] ballTLX;
wire [7:0] ballTLY;
wire [3:0] ball_size;

ball gameBall(
.pclk(pclk),
.gameclk(gameclk),
.topleft_x(ballTLX),
.topleft_y(ballTLY),
.size(ball_size)
);
// ********************************************

//***************  Board setup ****************

wire [7:0] stax, stay;
wire [7:0] endx, endy;
wire [3:0] beam;
wire [1:0] mode;
wire go;
wire busy;

assign framebuffer_mode = mode;

board boardDisplay (
    .pclk(pclk),
	.startx(stax),
	.starty(stay),
	.endx(endx),
	.endy(endy),
	.mode(mode),
	.beam(beam),
	.go(go),
	.busy(busy),
	.ballX(ballTLX),
	.ballY(ballTLY),
	.ballSize(ball_size),
	.control(control)
);

// ********************************************


// This module draws lines from the start
// coordinate to the end coordinate.  After
// providing the desired coordinates, pulse
// the go signal for one cycle.  The module
// should then indicate it is busy until it
// has completed the line draw by writing
// the necessary pixels to the framebuffer.

linedraw my_linedraw (
	.go(go),
	.busy(busy),
	.stax(stax),
	.stay(stay),
	.endx(endx),
	.endy(endy),
	.wr(linedraw_wr),
	.addr(linedraw_addr),
	.pclk(pclk)
);

// As currently implemented, the line draw
// is done by "jamming" the selected beam
// intensity into the framebuffer.  Future
// enhancements might use read-modify-write
// during line draw, but for now there's
// no use for linedraw_pixel_out signal.
// For "jamming" there is no need for
// linedraw_pixel_in nor linedraw_pixel_out
// to enter the linedraw module.

assign linedraw_pixel_in = beam;
   
endmodule
