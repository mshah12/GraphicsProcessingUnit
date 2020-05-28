module polygonRaster(input logic CLOCK_50,
					output logic [17:0] coord, input logic startRaster,
						output logic rasterDone, input logic readCoord, 
						output logic bufferEmpty,output [8:0] out,
						input logic [31:0] x[12][3],
		input logic [31:0] y[12][3],
		input logic [31:0] z[12][3]);
//Number of line modules, select line for mux(depends on NUM_LINES)
	parameter NUM_LINES = 36,SELECT_SIZE = 6,NUM_TRIANGLES = 12,COORD_WIDTH = 18;		
	parameter NUM_LINES_TEST = 36;
	
//logic [SELECT_SIZE-1:0] select;
logic [COORD_WIDTH-1:0]a [NUM_LINES];//mux input(output of each line module)


logic [8:0] X[NUM_TRIANGLES][3];logic [8:0] Y[NUM_TRIANGLES][3];
logic readFIFO[NUM_LINES];logic is_done[NUM_LINES];logic is_calculating[NUM_LINES];
logic [17:0] outputFIFO[NUM_LINES];
logic [8:0] fifoSize[NUM_LINES];
logic start[NUM_LINES];
assign a=outputFIFO;

logic [31:0] newX[NUM_TRIANGLES][3];logic [31:0] newY[NUM_TRIANGLES][3];
logic startProj[NUM_TRIANGLES]; logic projDone[NUM_TRIANGLES];logic compDone[NUM_TRIANGLES];
logic [31:0] proj_x[NUM_TRIANGLES][3];logic [31:0] proj_y[NUM_TRIANGLES][3];
logic [31:0] proj_z[NUM_TRIANGLES][3];

parameter one = 32'b00000000000000001000000000000000;
parameter negative_one = 32'b11111111111111111000000000000000;



		logic [31:0] sin_out,cos_out,neg_sin_out;
		logic [8:0] ANGLE_ADDRESS, ANGLE_ADDRESS_in;
		
		//LUT for SIN					 
		sin s(.address(ANGLE_ADDRESS),
	.clock(CLOCK_50),
	.q(sin_out));	
		//LUT for COS
		cos c(.address(ANGLE_ADDRESS),
	.clock(CLOCK_50),
	.q(cos_out));						 
		//LUT for -sin
		neg_sin ns(.address(ANGLE_ADDRESS),
	.clock(CLOCK_50),
	.q(neg_sin_out));			

	
		always_ff @ (posedge CLOCK_50)
 		begin

		if(ANGLE_ADDRESS > 313)
		ANGLE_ADDRESS <= 0;
		else
		ANGLE_ADDRESS <= ANGLE_ADDRESS_in;
		end
	
	
		always_comb
		begin
		ANGLE_ADDRESS_in = ANGLE_ADDRESS;
		if(startRaster == 1'b1)
		ANGLE_ADDRESS_in = ANGLE_ADDRESS_in + 8'b1;
		end

		
		
		
genvar index10;
genvar row10;
generate
for(row10 = 0;row10<NUM_TRIANGLES;row10=row10+1)
begin:row_label10
for (index10=0; index10 < 3; index10=index10+1)
  begin: gen_code_label10
	assign proj_x[row10][index10] = x[row10][index10];
	assign proj_y[row10][index10] = ((y[row10][index10]*cos_out) + (sin_out*z[row10][index10]))>>15;
	assign proj_z[row10][index10] = ((z[row10][index10]*cos_out) + (neg_sin_out*y[row10][index10]))>>15;
  end
 end
endgenerate




genvar index1;
genvar row1;
generate
for(row1 = 0;row1<NUM_TRIANGLES;row1=row1+1)
begin:row_label1
for (index1=0; index1 < 3; index1=index1+1)
  begin: gen_code_label1
	assign X[row1][index1] = newX[row1][index1][23:15];
	assign Y[row1][index1] = newY[row1][index1][23:15];
  end
 end
endgenerate



genvar index2;
genvar row2;
generate
for(row2 = 0;row2<NUM_TRIANGLES;row2=row2+1)
begin:row_label2
for (index2=0; index2 < 3; index2=index2+1)
  begin: gen_code_label2
  localparam temp = row2*3+index2;
    linerasterize lineinst(.x0(X[row2][index2]),.y0(Y[row2][index2]),
							.x1(X[row2][(index2+1)%3]),
							.y1(Y[row2][(index2+1)%3]),
							.CLOCK_50(CLOCK_50),.start(start[temp]),.proj_fin(),
							.readFIFO(readFIFO[temp]),
							.is_done(is_done[temp]),
							.outputFIFO(outputFIFO[temp]),.fifoSize(fifoSize[temp]),
							.is_calculating(is_calculating[temp]));
  end
 end
endgenerate
			
		

genvar index3;
genvar row3;
generate
for(row3 = 0;row3<NUM_TRIANGLES;row3=row3+1)
begin:row_label3

							
	 triangleProjection triaInst(.x(proj_x[row3]), .y(proj_y[row3]), 
							.z(proj_z[row3]), 
							  .CLOCK_50(CLOCK_50), .START(startProj[row3]),
							  .newx(newX[row3]), .newy(newY[row3]), .newz(),
							  .DONE(projDone[row3]));						
 end
endgenerate		

							  	

								
								


	/*FSM*/	
	logic [8:0] counter,counter_in,muxselect,muxselect_in;	
	logic rasterDone_in,bufferEmpty_in;
	enum logic [7:0] {INITIAL,STARTPROJ,START,STARTRAST,S1,S2,S3,S4,
	S5,S6,S7,test1,test2,test3,test4}   State = INITIAL, Next_state; 
	always_ff @ (posedge CLOCK_50)
	begin
	State <= Next_state;
	//If we need to set DrawX and DrawY to zero
	if(startRaster) begin
	counter <=0;
	muxselect <=0;
	rasterDone <= 0;
	bufferEmpty <=0;
	end
	//increment DrawX and DrawY accordingly
	else begin
	muxselect <= muxselect_in;
	counter <= counter_in;
	bufferEmpty <= bufferEmpty_in; 
	rasterDone <= rasterDone_in;
	end
	end 	
				
	always_comb
	begin
	Next_state = State;
	counter_in = counter;
	muxselect_in = muxselect;
	bufferEmpty_in = bufferEmpty;
	start = '{default:0};
	rasterDone_in = rasterDone;
	readFIFO = '{default:0};
	startProj ='{default:0};
	compDone = '{default:1};
	unique case(State)
	INITIAL: begin //Wait till you start the raster
		if(startRaster)
		begin
		Next_state = test4;
		end
		else
		Next_state = INITIAL;
	end
	test4:begin
	Next_state = test3;
	end
	test3:begin
	Next_state = test2;
	end
	test2:begin
	Next_state = test1;
	end
	test1: begin
		startProj = '{default:1};
		Next_state = STARTPROJ;
	end
	STARTPROJ: begin
	if(projDone == compDone)
	Next_state = STARTRAST;
	else
	Next_state = STARTPROJ;
	end
	STARTRAST: begin
	start = '{default:1};
	Next_state = START;
	end
	START: begin
	if(is_done[counter])
	Next_state = S3;
	else
	begin
	if(is_calculating[counter])
	Next_state=START;
	else
	Next_state = S3;
	end
	end
	
	S3:begin
	counter_in++;
	Next_state = S1;
	end
	
	S1: begin//CHECK IF LOOKED AT LAST MUX INPUT
	if(counter == NUM_LINES_TEST)begin //CHANGE THIS
	counter_in = 0;
	Next_state = S4;end
	else
	Next_state = START;	
	end
	
	S4:begin //ALL LINES HAVE BEEN CREATED TELL FRAMEBUFFER
	rasterDone_in = 1'b1;
	Next_state = S5;
	end
	
	S5: begin //begin outputing fifos
	if(readCoord == 1'b1)
	begin
	readFIFO[muxselect] = 1'b1; //pop from fifo 
	counter_in++;
	Next_state = S6;
	end
	else
	Next_state = S5;
	end
	S6:begin
	if(counter == fifoSize[muxselect] && muxselect == NUM_LINES_TEST-1)//end of mux CHANGE THIS
	begin
	bufferEmpty_in = 1'b1;
	Next_state = INITIAL;
	end
	else if(counter == fifoSize[muxselect])
	begin
	counter_in=0;
	muxselect_in++;
	Next_state = S5;
	end
	else
	Next_state = S5;
	end
	
	
	endcase
	end
											
			var_mux #(COORD_WIDTH,NUM_LINES,SELECT_SIZE)
coordinateMux(.a(a),
					.select(muxselect),
					.y(coord)
					);			
						
endmodule


/*Variable mux that takes in a unpacked array of packed dimensions. */
module var_mux #(parameter WIDTH = 18, NUM_INPUTS  = 36,SELECT_SIZE = 6)
(
  input logic  [ WIDTH - 1 : 0 ]a [NUM_INPUTS],
  input logic [ SELECT_SIZE - 1 : 0 ] select,
  output logic [ WIDTH -1 : 0 ] y
);

  assign y = a[select];
endmodule































module triangleProjection(input logic [31:0] x[3], y[3], z[3], 
							  input logic CLOCK_50, START,
							  output logic [31:0] newx[3], newy[3], newz[3],
							  output logic DONE);
							  
logic done1, done2, done3, projStart, DONEIN;


enum logic [7:0] {WAIT,S0,S1,S2,DONESTATE}   State = WAIT, Next_state;  

always_ff @ (posedge CLOCK_50)
begin
	State <= Next_state;
	DONE <= DONEIN;
end


always_comb
begin
Next_state = State;
DONEIN = DONE;
projStart = 0;

unique case(State)

	WAIT: 
	begin
	DONEIN = 0;
	if(START == 0)
	begin
	Next_state = WAIT;
	end
	else
	begin
	Next_state = S1;
	end
	end
	
	S1:
	begin
	projStart = 1;
	Next_state = S2;
	end
	
	S2:
	begin
	projStart = 0;
	if(done1 && done2 && done3)
	begin
	Next_state = DONESTATE;
	end
	else
	begin
	Next_state = S2;
	end
	end
	
	DONESTATE:
	begin
	DONEIN = 1;
	if(START == 1)
	begin
	DONEIN = 0;
	Next_state = S1;
	end
	else
	begin
	Next_state = DONESTATE;
	end
	end
	
	default: ;
	
endcase
end

projection coordinate1(.X(x[0]), .Y(y[0]), .Z(z[0]), .CLOCK_50(CLOCK_50), .START(projStart), .newx(newx[0]), .newy(newy[0]), .newz(newz[0]), .DONE(done1));
projection coordinate2(.X(x[1]), .Y(y[1]), .Z(z[1]), .CLOCK_50(CLOCK_50), .START(projStart), .newx(newx[1]), .newy(newy[1]), .newz(newz[1]), .DONE(done2));
projection coordinate3(.X(x[2]), .Y(y[2]), .Z(z[2]), .CLOCK_50(CLOCK_50), .START(projStart), .newx(newx[2]), .newy(newy[2]), .newz(newz[2]), .DONE(done3));

endmodule



/* division (a / b) - left shift a first by 15 bits, then divide by b
	multiply (a * b) - multiply a by b first then divide by (1 << 15) 
	
	zfar = 1000
	znear = 0.1
	theta = 90 degrees --> 1/(tan(theta/2)) = 1/tan(45) = 1/1 = 1 */


module projection(input logic [31:0] X, Y, Z, input logic CLOCK_50, START, output logic [31:0] newx, newy, newz, output logic DONE);


logic DONEIN, Dstart, Mstart, completex, completey, completez, completemx, completemy, completemz, od1, od2, od3, om1, om2, om3;
logic flipX, flipXin, flipY, flipYin, flipZ, flipZin, flipDivider, flipDividerin;
logic [31:0] newx_in, newy_in, newz_in, aspect_ratio, width, height, q, znearq, zplusthree, quotientx, quotienty, quotientz, productx, producty, productz, multx, multy, multz, multxin, multyin, multzin;
logic[31:0] tempx, tempy, tempz, tempxin, tempyin, tempzin;


enum logic [7:0] {WAIT,S0,S00,S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,S11,S12,S13,S14,S15,S16,S17,S18,S19,DONESTATE1,DONESTATE2}   State = WAIT, Next_state; 


always_ff @ (posedge CLOCK_50)
begin
	State <= Next_state;
	newx <= newx_in;
	newy <= newy_in;
	newz <= newz_in;
	tempx <= tempxin;
	tempy <= tempyin;
	tempz <= tempzin;
	flipX <= flipXin;
	flipY <= flipYin;
	flipZ <= flipZin;
	flipDivider <= flipDividerin;
	multx <= multxin;
	multy <= multyin;
	multz <= multzin;
	DONE <= DONEIN;
end

	
always_comb
begin
Next_state = State;
newx_in = newx;
newy_in = newy;
newz_in = newz;
tempxin = tempx;
tempyin = tempy;
tempzin = tempz;
flipXin = flipX;
flipYin = flipY;
flipZin = flipZ;
flipDividerin = flipDivider;
multxin = multx;
multyin = multy;
multzin = multz;
DONEIN = DONE;
Dstart = 0; //default the start signal for the divison module to zero
Mstart = 0;
aspect_ratio = 32'b00000000000000000110000000000000; //aspect ratio = 240/320 (h/w) in fixed_point notation
width = 32'b00000000010011111100000000000000; // width = 319 * 0.5
height = 32'b00000000001110111100000000000000; // height = 239 * 0.5
q = 32'b00000000000000001000000000000011; // q = (zfar / (zfar - znear))  = (1000 / (1000 - 0.11)) = (1000 / 999.9)
znearq = 32'b00000000000000000000110011001101; // znearq = (1000/999.9) * 0.1 = 0.100010001
zplusthree = (Z + 32'b00000000000000011000000000000000); // add 3 to Z


//newx will be (aspect_ratio * x) / z
//newy will be y / z
//newz will be z * (zfar / zfar - znear) - (zfar * znear / zfar - znear) = (z * (zfar / zfar - znear)) - (znear * (zfar / zfar - znear)) = (z * (1000 / 999.9)) - (1 * (1000 / 999.9)) = ((z * q - q) / z)

//multiplication takes one clock cycle
//division module takes multiple clock cycles, but no matter the size of the input takes the same amount of clock cycles

unique case(State)

	WAIT: 
	begin
	newx_in = 0;
	newy_in = 0;
	newz_in = 0;
	tempxin = 0;
	tempyin = 0;
	tempzin = 0;
	flipXin = 0;
	flipYin = 0;
	flipZin = 0;
	flipDividerin = 0;
	multxin = 0;
	multyin = 0;
	multzin = 0;
	Dstart = 0;
	Mstart = 0;
	if(START == 0)
	begin
	Next_state = WAIT;
	end
	else
	begin
	Next_state = S0;
	end
	end
	
	S0:
	begin
	tempxin = tempx;
	tempyin = tempy;
	tempzin = tempz;
	Next_state = S1;
	end
	
	S00:
	begin
	tempxin = 0;
	tempyin = 0;
	tempzin = 0;
	newx_in = 0;
	newy_in = 0;
	newz_in = 0;
	flipXin = 0;
	flipYin = 0;
	flipZin = 0;
	flipDividerin = 0;
	multxin = 0;
	multyin = 0;
	multzin = 0;
	Dstart = 0;
	Mstart = 0;
	Next_state = S1;
	end
	
	S1:
	begin
	if(X[31] == 1)
	begin
	flipXin = 1;
	tempxin = (~X + 1);
	end
	else
	begin
	tempxin = X;
	end
	if(zplusthree[31] == 1)
	begin
	flipZin = 1;
	tempzin = (~zplusthree + 1);
	end
	else
	begin
	tempzin = zplusthree;
	end
	multxin = aspect_ratio;
	multzin = q;
	Next_state = S2;
	end
	
	S2: 
	begin
	Mstart = 1; // begin multiplication
	Next_state = S3;
	end
	
	S3:
	begin
	if(completemx && completemz)
	begin
	Next_state = S4; // only move on when all three multiplications computations are complete
	end
	else
	begin
	Next_state = S3; // dummy state to allow multiplication to finish
	end
	end
	
	S4:
	begin
	tempxin = productx;
	tempyin = Y;
	tempzin = productz;
	Next_state = S5;
	end
	
	S5:
	begin
	if(flipX)
	begin
	flipXin = 0;
	tempxin = (~tempx + 1);
	end
	if(flipZ)
	begin
	flipZin = 0;
	tempzin = (~tempz + 1);
	end
	Next_state = S6;
	end

	S6: 
	begin
	tempzin = (tempz - znearq); // divide by left shift 15 to complete multiplication
	Next_state = S7;
	end
	
	S7:
	begin
	if(zplusthree == 0)
	begin
	Next_state = S11; // if z equals zero, then go to final state
	end
	else
	begin
	Next_state = S8; 
	end
	end
	
	S8:
	begin
	if(tempx[31] == 1)
	begin
	flipXin = 1;
	tempxin = (~tempx + 1); // if tempx is negative, change to positive and set the flag
	end
	if(tempy[31] == 1)
	begin
	flipYin = 1;
	tempyin = (~tempy + 1); // if tempx is negative, change to positive and set the flag
	end
	if(tempz[31] == 1)
	begin
	flipZin = 1;
	tempzin = (~tempz + 1); // if tempx is negative, change to positive and set the flag
	end
	if(zplusthree[31] == 1) 
	begin
	flipDividerin = 1;
	zplusthree = (~zplusthree + 1); // if the divisor is negative, change to positive and set the flag
	end
	Next_state = S9;
	end
	
	S9:
	begin
	Dstart = 1;
	Next_state = S10;
	end
	
	S10:
	begin
	if(completex && completey && completez)
	begin
	Next_state = S11; // only move on when all three divison computations are complete
	end
	else
	begin
	Next_state = S10; // dummy state to allow division to finish
	end
	end
	
	S11:
	begin
	tempxin = quotientx; // load quotient into tempx
	tempyin = quotienty; // load quotient into tempy
	tempzin = quotientz; // load quotient into tempz
	Next_state = S12;
	end
	
	S12:
	begin
	if((flipX || flipDivider) && (flipX == 1 && flipDivider == 0))
	begin
	tempxin = (~tempx + 1);
	end
	if((flipY || flipDivider) && (flipY == 1 && flipDivider == 0))
	begin
	tempyin = (~tempy + 1);
	end
	if((flipZ || flipDivider) && (flipZ == 1 && flipDivider == 0))
	begin
	tempzin = (~tempz + 1);
	end
	if(flipDivider)
	begin
	zplusthree = (~zplusthree + 1);
	end
	flipXin = 0;
	flipYin = 0;
	flipZin = 0;
	flipDividerin = 0;
	Next_state = S13;
	end
	
	S13:
	begin
	tempxin = (tempx + 32'b00000000000000001000000000000000); // add 1 to x, so the range is between 0 and 2 
	tempyin = (tempy + 32'b00000000000000001000000000000000); // add 1 to y, so the range is between 0 and 2 
	Next_state = S14;
	end
	
	S14:
	begin
	multxin = width;
	multyin = height;
	if(tempx[31] == 1)
	begin
	flipXin = 1;
	tempxin = (~tempx + 1);
	end
	if(tempy[31] == 1)
	begin
	flipYin = 1;
	tempyin = (~tempy + 1);
	end
	Next_state = S15;
	end
	
	S15:
	begin
	Mstart = 1;
	Next_state = S16;
	end
	
	S16:
	begin
	if(completemx && completemy)
	begin
	tempxin = productx;
	tempyin = producty;
	Next_state = S17; // only move on when all three multiplications computations are complete
	end
	else
	begin
	Next_state = S16; // dummy state to allow multiplication to finish
	end
	end
	
	S17:
	begin
	if(flipX)
	begin
	flipXin = 0;
	tempxin = (~tempx + 1);
	end
	if(flipY)
	begin
	flipYin = 0;
	tempyin = (~tempy + 1);
	end
	Next_state = S18;
	end
	
	S18:
	begin
	if(tempx[14] == 1)
	begin
	tempxin = (tempx + 32'b00000000000000001000000000000000);
	end
	if(tempy[14] == 1)
	begin
	tempyin = (tempy + 32'b00000000000000001000000000000000);
	end
	Next_state = S19;
	end
	
	S19:
	begin
	tempxin[14] = 0;
	tempxin[13] = 0;
	tempxin[12] = 0;
	tempxin[11] = 0;
	tempxin[10] = 0;
	tempxin[9] = 0;
	tempxin[8] = 0;
	tempxin[7] = 0;
	tempxin[6] = 0;
	tempxin[5] = 0;
	tempxin[4] = 0;
	tempxin[3] = 0;
	tempxin[2] = 0;
	tempxin[1] = 0;
	tempxin[0] = 0;
	tempyin[14] = 0;
	tempyin[13] = 0;
	tempyin[12] = 0;
	tempyin[11] = 0;
	tempyin[10] = 0;
	tempyin[9] = 0;
	tempyin[8] = 0;
	tempyin[7] = 0;
	tempyin[6] = 0;
	tempyin[5] = 0;
	tempyin[4] = 0;
	tempyin[3] = 0;
	tempyin[2] = 0;
	tempyin[1] = 0;
	tempyin[0] = 0;
	Next_state = DONESTATE1;
	end

	DONESTATE1:
	begin
	newx_in = tempx[31:0]; // shift from 64 bit logic to 32-bit coordinate
	newy_in = tempy[31:0]; // shift from 64 bit logic to 32-bit coordinate
	newz_in = tempz[31:0]; // shift from 64 bit logic to 32-bit coordinate
	DONEIN = 1'b1; // assert DONE signal to '1'
	Next_state = DONESTATE2;
	end
	
	DONESTATE2:
	begin 
	DONEIN = 1'b1;
	if(START == 1)
	begin
	DONEIN = 1'b0;
	Next_state = S00;
	end
	else
	begin
	Next_state = DONESTATE2;
	end
	end
	
	default: ;

endcase
end	

divider d1(.i_dividend(tempx), .i_divisor(zplusthree), .i_start(Dstart), .CLOCK_50(CLOCK_50), .o_quotient_out(quotientx), .o_complete(completex), .o_overflow(od1));
divider d2(.i_dividend(tempy), .i_divisor(zplusthree), .i_start(Dstart), .CLOCK_50(CLOCK_50), .o_quotient_out(quotienty), .o_complete(completey), .o_overflow(od2));
divider d3(.i_dividend(tempz), .i_divisor(zplusthree), .i_start(Dstart), .CLOCK_50(CLOCK_50), .o_quotient_out(quotientz), .o_complete(completez), .o_overflow(od3));				
multiplier m1(.i_multiplicand(tempx), .i_multiplier(multx), .i_start(Mstart), .CLOCK_50(CLOCK_50), .o_result_out(productx), .o_complete(completemx), .o_overflow(om1));
multiplier m2(.i_multiplicand(tempy), .i_multiplier(multy), .i_start(Mstart), .CLOCK_50(CLOCK_50), .o_result_out(producty), .o_complete(completemy), .o_overflow(om2));
multiplier m3(.i_multiplicand(tempz), .i_multiplier(multz), .i_start(Mstart), .CLOCK_50(CLOCK_50), .o_result_out(productz), .o_complete(completemz), .o_overflow(om3));
						
endmodule

//division module taken from Fixed Point Math Library for Verilog by Freecores
//credit: https://github.com/freecores/verilog_fixed_point_math_library

module divider #(
	//Parameterized values
	parameter Q = 15,
	parameter N = 32
	)
	(
	input 	[N-1:0] i_dividend,
	input 	[N-1:0] i_divisor,
	input 	i_start,
	input 	CLOCK_50,
	output 	[N-1:0] o_quotient_out,
	output 	o_complete,
	output	o_overflow
	);
 
	reg [2*N+Q-3:0]	reg_working_quotient;	//	Our working copy of the quotient
	reg [N-1:0] 		reg_quotient;				//	Final quotient
	reg [N-2+Q:0] 		reg_working_dividend;	//	Working copy of the dividend
	reg [2*N+Q-3:0]	reg_working_divisor;		// Working copy of the divisor
 
	reg [N-1:0] 			reg_count; 		//	This is obviously a lot bigger than it needs to be, as we only need 
													//		count to N-1+Q but, computing that number of bits requires a 
													//		logarithm (base 2), and I don't know how to do that in a 
													//		way that will work for everyone
										 
	reg					reg_done;			//	Computation completed flag
	reg					reg_sign;			//	The quotient's sign bit
	reg					reg_overflow;		//	Overflow flag
 
	initial reg_done = 1'b1;				//	Initial state is to not be doing anything
	initial reg_overflow = 1'b0;			//		And there should be no woverflow present
	initial reg_sign = 1'b0;				//		And the sign should be positive

	initial reg_working_quotient = 0;	
	initial reg_quotient = 0;				
	initial reg_working_dividend = 0;	
	initial reg_working_divisor = 0;		
 	initial reg_count = 0; 		

 
	assign o_quotient_out[N-2:0] = reg_quotient[N-2:0];	//	The division results
	assign o_quotient_out[N-1] = reg_sign;						//	The sign of the quotient
	assign o_complete = reg_done;
	assign o_overflow = reg_overflow;
 
	always @( posedge CLOCK_50 ) begin
		if( reg_done && i_start ) begin										//	This is our startup condition
			//  Need to check for a divide by zero right here, I think....
			reg_done <= 1'b0;												//	We're not done			
			reg_count <= N+Q-1;											//	Set the count
			reg_working_quotient <= 0;									//	Clear out the quotient register
			reg_working_dividend <= 0;									//	Clear out the dividend register 
			reg_working_divisor <= 0;									//	Clear out the divisor register 
			reg_overflow <= 1'b0;										//	Clear the overflow register

			reg_working_dividend[N+Q-2:Q] <= i_dividend[N-2:0];				//	Left-align the dividend in its working register
			reg_working_divisor[2*N+Q-3:N+Q-1] <= i_divisor[N-2:0];		//	Left-align the divisor into its working register

			reg_sign <= i_dividend[N-1] ^ i_divisor[N-1];		//	Set the sign bit
			end 
		else if(!reg_done) begin
			reg_working_divisor <= reg_working_divisor >> 1;	//	Right shift the divisor (that is, divide it by two - aka reduce the divisor)
			reg_count <= reg_count - 1;								//	Decrement the count

			//	If the dividend is greater than the divisor
			if(reg_working_dividend >= reg_working_divisor) begin
				reg_working_quotient[reg_count] <= 1'b1;										//	Set the quotient bit
				reg_working_dividend <= reg_working_dividend - reg_working_divisor;	//		and subtract the divisor from the dividend
				end
 
			//stop condition
			if(reg_count == 0) begin
				reg_done <= 1'b1;										//	If we're done, it's time to tell the calling process
				reg_quotient <= reg_working_quotient;			//	Move in our working copy to the outside world
				if (reg_working_quotient[2*N+Q-3:N]>0)
					reg_overflow <= 1'b1;
					end
			else
				reg_count <= reg_count - 1;	
			end
		end
endmodule

//multiplication module taken from Fixed Point Math Library for Verilog by Freecores
//credit: https://github.com/freecores/verilog_fixed_point_math_library
module multiplier#(
	//Parameterized values
	parameter Q = 15,
	parameter N = 32
	)
	(
	input 	[N-1:0]  i_multiplicand,
	input 	[N-1:0]	i_multiplier,
	input 	i_start,
	input 	CLOCK_50,
	output 	[N-1:0] o_result_out,
	output 	o_complete,
	output	o_overflow
	);

	reg [2*N-2:0]	reg_working_result;		//	a place to accumulate our result
	reg [2*N-2:0]	reg_multiplier_temp;		//	a working copy of the multiplier
	reg [N-1:0]		reg_multiplicand_temp;	//	a working copy of the umultiplicand
	
	reg [N-1:0] 			reg_count; 		//	This is obviously a lot bigger than it needs to be, as we only need 
												//		count to N, but computing that number of bits requires a 
												//		logarithm (base 2), and I don't know how to do that in a 
												//		way that will work for every possibility
										 
	reg					reg_done;		//	Computation completed flag
	reg					reg_sign;		//	The result's sign bit
	reg					reg_overflow;	//	Overflow flag
 
	initial reg_done = 1'b1;			//	Initial state is to not be doing anything
	initial reg_overflow = 1'b0;		//		And there should be no woverflow present
	initial reg_sign = 1'b0;			//		And the sign should be positive
	
	assign o_result_out[N-2:0] = reg_working_result[N-2+Q:Q];	//	The multiplication results
	assign o_result_out[N-1] = reg_sign;								//	The sign of the result
	assign o_complete = reg_done;											//	"Done" flag
	assign o_overflow = reg_overflow;									//	Overflow flag
	
	always @( posedge CLOCK_50 ) begin
		if( reg_done && i_start ) begin										//	This is our startup condition
			reg_done <= 1'b0;														//	We're not done			
			reg_count <= 0;														//	Reset the count
			reg_working_result <= 0;											//	Clear out the result register
			reg_multiplier_temp <= 0;											//	Clear out the multiplier register 
			reg_multiplicand_temp <= 0;										//	Clear out the multiplicand register 
			reg_overflow <= 1'b0;												//	Clear the overflow register

			reg_multiplicand_temp <= i_multiplicand[N-2:0];				//	Load the multiplicand in its working register and lose the sign bit
			reg_multiplier_temp <= i_multiplier[N-2:0];					//	Load the multiplier into its working register and lose the sign bit

			reg_sign <= i_multiplicand[N-1] ^ i_multiplier[N-1];		//	Set the sign bit
			end 

		else if (!reg_done) begin
			if (reg_multiplicand_temp[reg_count] == 1'b1)								//	if the appropriate multiplicand bit is 1
				reg_working_result <= reg_working_result + reg_multiplier_temp;	//		then add the temp multiplier
	
			reg_multiplier_temp <= reg_multiplier_temp << 1;						//	Do a left-shift on the multiplier
			reg_count <= reg_count + 1;													//	Increment the count

			//stop condition
			if(reg_count == N) begin
				reg_done <= 1'b1;										//	If we're done, it's time to tell the calling process
				if (reg_working_result[2*N-2:N-1+Q] > 0)			// Check for an overflow
					reg_overflow <= 1'b1;
//			else
//				reg_count <= reg_count + 1;													//	Increment the count
				end
			end
		end
endmodule

