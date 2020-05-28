//Will be using 32-bit fixed point notation
/*
	x|xxxxxxxxxxxxxxxx|xxxxxxxxxxxxxxx
	*1 bit = 2's complement
	*16 bits = integer
	*15 bits = decimal
	-Addition=Like Usual
	-Subtraction=Like Usual
	-Multiplication = Normal but right shift by # of decimal (15)
	-Division=(x/y) * (1<<15) I believe this is correct but don't know
*/

module top(	input  CLOCK_50,
				// VGA Interface 
             output logic [7:0]  VGA_R,        //VGA Red
                                 VGA_G,        //VGA Green
                                 VGA_B,        //VGA Blue
             output logic        VGA_CLK,      //VGA Clock
                                 VGA_SYNC_N,   //VGA Sync signal
                                 VGA_BLANK_N,  //VGA Blank signal
                                 VGA_VS,       //VGA virtical sync signal
                                 VGA_HS,       //VGA horizontal sync signal
				output logic [6:0] HEX0, HEX1,
				//SDRAM INTERFACE
				 output logic [12:0] DRAM_ADDR,    //SDRAM Address 13 Bits
             inout  wire  [31:0] DRAM_DQ,      //SDRAM Data 32 Bits
             output logic [1:0]  DRAM_BA,      //SDRAM Bank Address 2 Bits
             output logic [3:0]  DRAM_DQM,     //SDRAM Data Mast 4 Bits
             output logic        DRAM_RAS_N,   //SDRAM Row Address Strobe
                                 DRAM_CAS_N,   //SDRAM Column Address Strobe
                                 DRAM_CKE,     //SDRAM Clock Enable
                                 DRAM_WE_N,    //SDRAM Write Enable
                                 DRAM_CS_N,    //SDRAM Chip Select
                                 DRAM_CLK      //SDRAM Clock
											);

											
logic [31:0] sizeTriangle, startRender; 
logic [1151:0] x, y,z;
logic [31:0] EXPORT_X[12][3];logic [31:0] EXPORT_Y[12][3];logic [31:0] EXPORT_Z[12][3];



 soc NIOS_SOC(
		.clk_clk(CLOCK_50),                 //          clk.clk
		.export_size_new_signal(sizeTriangle),  //  export_size.new_signal
		.export_start_new_signal(startRender), // export_start.new_signal
		.export_x_new_signal(x),     //     export_x.new_signal
		.export_y_new_signal(y),     //     export_y.new_signal
		.export_z_new_signal(z),     //     export_z.new_signal
		.reset_reset_n(1'b1),           //        reset.reset_n
		.sdram_clk_clk(DRAM_CLK),           //    sdram_clk.clk
		.sdram_wire_addr(DRAM_ADDR),         //   sdram_wire.addr
		.sdram_wire_ba(DRAM_BA),           //             .ba
		.sdram_wire_cas_n(DRAM_CAS_N),        //             .cas_n
		.sdram_wire_cke(DRAM_CKE),          //             .cke
		.sdram_wire_cs_n(DRAM_CS_N),         //             .cs_n
		.sdram_wire_dq(DRAM_DQ),           //             .dq
		.sdram_wire_dqm(DRAM_DQM),          //             .dqm
		.sdram_wire_ras_n(DRAM_RAS_N),        //             .ras_n
		.sdram_wire_we_n(DRAM_WE_N)          //             .we_n
	);


arrayPacker toUnpacked(
		.X(x),
		.Y(y),
		.Z(z),
		.EXPORT_X(EXPORT_X),
		.EXPORT_Y(EXPORT_Y),
		.EXPORT_Z(EXPORT_Z)
	);	




	/*WAYS TO INCREASE SPEED*/
		/* INCREASE THROUGHPUT BY DOING NEXT BUFFER ONCE DRAW_DONE IS HIGH*/	
		/*OPTIMIZE EDGE EQUATION FOR FASTER SPEED*/								
		//OUTPUT OF LOOKUP TABLE
		
		//CURRENT ANGLE			
//		logic [4:0] ANGLE_ADDRESS = 0;							
					
	//Signal when to switch buffer,Write to buffer 1,Write to buffer 2	
	//,BUFFER1 Write CLK, BUFFER2 Write CLK,when vga has finished frame,
	//when to reset drawx and drawy, when to increment the angle
	 logic DRAW_DONE,BUFFER1_WR,BUFFER2_WR,BUFFER1_WR_CLK,BUFFER2_WR_CLK,
			 frame_switched,RESET_RASTER,INCREMENT_ANGLE;
	//Write to buffer at 50Mhz
	assign BUFFER2_WR_CLK = CLOCK_50;
	assign BUFFER1_WR_CLK = CLOCK_50;
	 //3-bit RGB data total of 8 colors for each pixel
	 logic [2:0] BUFFER1_DATA,BUFFER2_DATA;
	 //Pixel address (size= 320*240) access by doing
	 //DrawY*320+DrawX given DrawY between [0,239] & DrawX between [0,319].
	 //[0,0] is top left of screen and first address in mem, [1,0] is sec. address
	 logic [16:0] BUFFER1_ADDR,BUFFER2_ADDR;
	 	
		
		
		output_screen OUTPUT(.*);//Vga controller and double buffer
	
	
	
	//Used to go through buffer
    parameter [8:0] H_TOTAL = 9'd320;
    parameter [8:0] V_TOTAL = 9'd240;
	 logic [8:0] DrawX,DrawY;
	 logic [8:0] h_counter, v_counter;
    logic [8:0] h_counter_in, v_counter_in;
    
    assign DrawX = h_counter;
    assign DrawY = v_counter;	
					 						 
							 
//		//LUT for SIN					 
//		sin s(.address(ANGLE_ADDRESS),
//	.clock(CLOCK_50),
//	.q(sin_out));	
//		//LUT for COS
//		cos c(.address(ANGLE_ADDRESS),
//	.clock(CLOCK_50),
//	.q(cos_out));						 
//		//LUT for -sin
//		neg_sin ns(.address(ANGLE_ADDRESS),
//	.clock(CLOCK_50),
//	.q(neg_sin_out));						 
							 
	
							 						 
							 
	logic startRaster,readCoord,rasterDone,bufferEmpty;
	logic [17:0] outputFIFO;
	logic [31:0] mem;
	
	assign mem = (outputFIFO[8:0]*320)+outputFIFO[17:9];
	logic [8:0] out;
 polygonRaster rasterp(.CLOCK_50(CLOCK_50),
					.coord(outputFIFO),.startRaster(startRaster),
						.rasterDone(rasterDone), .readCoord(readCoord), 
						.bufferEmpty(bufferEmpty),
						.out(out),.x(EXPORT_X),.y(EXPORT_Y),.z(EXPORT_Z));	
							
//	polygonRaster raster1(output [17:0] coord, input startRaster,
//								output rasterDone, output [8:0] fifoSize)
	/*1. startRaster
	  2. clearBuffer
	  3. after clearing buffer check if raster is done
	  4. if raster done then begin popping coord until you reach fifosize
	  5. startRaster again for next frame
	  6. Clear buffer for next frame
	  7. repeat from step 3
		*/		
logic clrBuffer1, clrBuffer2;
logic [16:0] memCounter,memCounter_in;
	always_comb 
	begin
	if(clrBuffer1)
	BUFFER1_ADDR = memCounter;
	else
	BUFFER1_ADDR = mem[16:0];//Always Access memory by using DrawX and DrawY
	end
	
	always_comb 
	begin
	if(clrBuffer2)
	BUFFER2_ADDR = memCounter;//Always Access memory by using DrawX and DrawY
	else
	BUFFER2_ADDR = mem[16:0];//Always Access memory by using DrawX and DrawY

	end

		
	enum logic [7:0] {WAIT2,INITIAL,START,S1,S2,S3,S4,WAIT1,S23,S24,F25,
	F26,F27,F28,CL1, CL2,CL3,CL4, DUMB}   State = WAIT2, Next_state; 
	always_ff @ (posedge CLOCK_50)
	begin
	State <= Next_state;
	//If we need to set DrawX and DrawY to zero
	if(RESET_RASTER) begin
	h_counter <=0;
	v_counter <=0;
	memCounter <= 0;
	end
	//increment DrawX and DrawY accordingly
	else begin
   h_counter <= h_counter_in;
   v_counter <= v_counter_in;
	memCounter <= memCounter_in;end
	end 	

	always_comb
	begin
	Next_state = State;
	//Default states
	DRAW_DONE = 1'b0;//You haven't finished drawing
	BUFFER2_WR = 1'b0;//Don't write by default
	BUFFER2_DATA = 0;//Set pixel data to black by default
	BUFFER1_WR = 1'b0;//Don't write by default
	BUFFER1_DATA = 0;//Set pixel data to black by default
	RESET_RASTER = 1'b0;//By default don't reset DrawX and DrawY
	INCREMENT_ANGLE = 1'b0;//Don't increment Angle by default
	//DRAW diagonal line up until DrawX = 10 (so 11 diagonal dots)
	startRaster = 1'b0;
	readCoord = 1'b0;
	//Don't clear buffer
	clrBuffer1 = 1'b0;
	clrBuffer2 = 1'b0;
	memCounter_in = memCounter;
	unique case(State)
	WAIT2: begin
	if(startRender[0])
	Next_state = DUMB;
	else
	Next_state = WAIT2;
	end
	DUMB:begin
	Next_state = INITIAL;
	end
	INITIAL: begin
	startRaster = 1'b1; //need to wait at least three clock cycles
	Next_state = CL1;
	end
	WAIT1: begin
	if(rasterDone) begin
	RESET_RASTER = 1'b1;//Reset DrawX and DrawY
	Next_state = S23; end
	else
	Next_state = WAIT1;
	end
	S23: begin
	readCoord = 1'b1;
	Next_state = START;
	end
	START:begin
	BUFFER2_DATA = 7;//Set it to white
	BUFFER2_WR = 1'b1;//Write to buffer2
	Next_state = S24;//Otherwise, continue through buffer 
	end
	S24: begin
	if(bufferEmpty)
	Next_state = S1;
	else
	Next_state = S23;
	end
	S1:begin
	DRAW_DONE = 1'b1;//Signal that you finished drawing buffer2
	if(frame_switched == 1'b1) begin//Once VGA is done reading buffer1
	INCREMENT_ANGLE = 1'b1;//Increment the angle
	RESET_RASTER = 1'b1;//Reset DrawX and DrawY
	Next_state = F25; end else//Go to state where you draw buffer1 now
	Next_state = S1;//otherwise, keep waiting till previous frame is done
	end
	F25: begin
	startRaster = 1'b1; //need to wait at least three clock cycles
	Next_state = CL3;
	end
	F26: begin
	if(rasterDone) begin
	RESET_RASTER = 1'b1;//Reset DrawX and DrawY
	Next_state = F27; end
	else
	Next_state = F26;
	end
	F27: begin
	readCoord = 1'b1;
	Next_state = S2;
	end
	S2:begin
	BUFFER1_DATA = 7;//Set it to white
	BUFFER1_WR = 1'b1;//Write to buffer1
	Next_state = F28;
	end
	F28: begin
	if(bufferEmpty)
	Next_state = S3;
	else
	Next_state = F27;
	end
	S3:begin
	DRAW_DONE = 1'b1;//Signal that you finished drawing buffer2
	if(frame_switched == 1'b1) begin//Once VGA is done reading buffer2
	INCREMENT_ANGLE = 1'b1;//Increment the angle
	RESET_RASTER = 1'b1;//Reset DrawX and DrawY
	Next_state = INITIAL; end else//Go to state where you draw buffer2 now
	Next_state = S3;//otherwise, keep waiting till previous frame is done
	end	
	//CLEAR BUFFER 1 and BUFFER 2
	CL1: begin
	clrBuffer2 = 1'b1;
	BUFFER2_DATA = 0;//Set it to black
	BUFFER2_WR = 1'b1;//Write to buffer2
	memCounter_in++;
	Next_state =CL2;
	end
	CL2: begin
	clrBuffer2 = 1'b1;
	if(memCounter == 76800)
	Next_state = WAIT1;
	else
	Next_state = CL1;
	end
	CL3:begin
	clrBuffer1 = 1'b1;
	BUFFER1_DATA = 0;//Set it to black
	BUFFER1_WR = 1'b1;//Write to buffer1
	memCounter_in++;
	Next_state =CL4;
	end
	CL4: begin
	clrBuffer1 = 1'b1;
	if(memCounter == 76800)
	Next_state = F26;
	else
	Next_state = CL3;
	end
	endcase 
	end
	
	//For DrawX and DrawY
	always_comb
	begin
	// horizontal and vertical counter
        h_counter_in = h_counter + 9'd1;
        v_counter_in = v_counter;
        if(h_counter + 10'd1 == H_TOTAL)
        begin
            h_counter_in = 9'd0;
            if(v_counter + 9'd1 == V_TOTAL)
                v_counter_in = 9'd0;
            else
                v_counter_in = v_counter + 9'd1;
        end
	end
	
	
	
HexDriver h1(.In0(startRaster),
                  .Out0(HEX0));
HexDriver h4(.In0(rasterDone),
                  .Out0(HEX1));	
	
	
	
	
endmodule



module arrayPacker(
		input logic [1151:0] X,
		input logic [1151:0] Y,
		input logic [1151:0] Z,
		output logic [31:0] EXPORT_X[12][3],
		output logic [31:0] EXPORT_Y[12][3],
		output logic [31:0] EXPORT_Z[12][3]
);

//logic [31:0] tracker;

genvar index1;
genvar row1;
generate
for(row1 = 0;row1<12;row1=row1+1)
begin:row_label4
for (index1=0; index1 < 3; index1=index1+1)	
  begin: gen_code_label6
  localparam tracker = 1151 - (96 * row1) - (32*index1);
	assign EXPORT_X[row1][index1] = X[tracker : tracker-31];
	assign EXPORT_Y[row1][index1] = Y[tracker : tracker-31];
	assign EXPORT_Z[row1][index1] = Z[tracker : tracker-31];
  end
 end
endgenerate

endmodule


