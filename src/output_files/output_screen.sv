module output_screen(input  CLOCK_50,
				// VGA Interface 
             output logic [7:0]  VGA_R,        //VGA Red
                                 VGA_G,        //VGA Green
                                 VGA_B,        //VGA Blue
             output logic        VGA_CLK,      //VGA Clock
                                 VGA_SYNC_N,   //VGA Sync signal
                                 VGA_BLANK_N,  //VGA Blank signal
                                 VGA_VS,       //VGA virtical sync signal
                                 VGA_HS,       //VGA horizontal sync signal
				input logic DRAW_DONE,BUFFER1_WR,BUFFER2_WR,BUFFER1_WR_CLK,BUFFER2_WR_CLK,
				input logic [2:0] BUFFER1_DATA,BUFFER2_DATA,
				input logic [16:0] BUFFER1_ADDR,BUFFER2_ADDR,
				output logic frame_switched
											);
								
								
logic r,g,b,r1,g1,b1,select; 
logic [9:0] DrawX, DrawY;
logic VGA_NEW_FRAME;assign VGA_NEW_FRAME = VGA_VS;

	vga_clk vga_clk(.inclk0(CLOCK_50),.c0(VGA_CLK));

	VGA_controller vga_control(.Clk(CLOCK_50),         // 50 MHz clock
                              .Reset(1'b0),       // Active-high reset signal
										.VGA_HS(VGA_HS),      // Horizontal sync pulse.  Active low
                              .VGA_VS(VGA_VS),      // Vertical sync pulse.  Active low
										.VGA_CLK(VGA_CLK),     // 25 MHz VGA clock input
										.VGA_BLANK_N(VGA_BLANK_N), // Blanking interval indicator.  Active low.
                              .VGA_SYNC_N(VGA_SYNC_N),  // Composite Sync signal.  Active low.  We don't use it in this lab,
                                                        // but the video DAC on the DE2 board requires an input for it.
										.DrawX(DrawX),       // horizontal coordinate
                              .DrawY(DrawY)        // vertical coordinate
										);   

//Only switch frame buffers when GPU is done 
//rendering
always_ff @ (negedge VGA_NEW_FRAME)
begin
//switch frame buffer
if(DRAW_DONE == 1'b1)
begin
select <= ~select;
frame_switched<=1'b1;
end
else
begin
frame_switched <= 1'b0;
select <= select;
end
end


//Initially, load from buffer1
always_comb
begin
if(select) begin
	VGA_R = {8{r1}};
	VGA_G = {8{g1}};
	VGA_B = {8{b1}}; end
else begin
	VGA_R = {8{r}};
	VGA_G = {8{g}};
	VGA_B = {8{b}};
end
end

		GBUFFER1 buffer1( //FIRST FRAME BUFFER TO DISPLAY *OUTPUT IS NOT SYNCHRONOUS*
				.rdclock(VGA_CLK),
				.wrclock(BUFFER1_WR_CLK),
				.data(BUFFER1_DATA),
				.rdaddress(((DrawY>>1)%240)*320+((DrawX>>1)%320)),
				.wraddress(BUFFER1_ADDR),
				.wren(BUFFER1_WR),
				.q({r,g,b}));

		 GBUFFER2 buffer2(//SECOND FRAME BUFFER *OUTPUT IS NOT SYNCHRONOUS*
				.rdclock(VGA_CLK),
				.wrclock(BUFFER2_WR_CLK),
				.data(BUFFER2_DATA),
				.rdaddress(((DrawY>>1)%240)*320+((DrawX>>1)%320)),
				.wraddress(BUFFER2_ADDR),
				.wren(BUFFER2_WR),
				.q({r1,g1,b1}));
							
								
								
								
endmodule								