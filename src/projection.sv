module projection(input logic [31:0] X,Y,Z,input logic CLK, startproj,
						output logic [31:0] newx,newy,newz,
						output logic DONE);
logic [31:0] newx_in,newy_in,newz_in;
logic RESET;
											
enum logic [7:0] {WAIT,S1,S2,S3,S4}   State = WAIT, Next_state; 

always_ff @ (posedge CLK)
	begin
	if(RESET)
	begin
	newx <=0;
	newy <=0;
	newz <=0;
	end
			State <= Next_state;
			newx <= newx_in;
			newy <= newy_in;
			newz <= newz_in;
	end		
always_comb
begin
Next_state = State;
newx_in = newx;
newy_in = newy;
newz_in = newz;
DONE = 1'b0;
RESET = 1'b0;
unique case(State)
WAIT: begin
	if(startproj)
	begin
	RESET =1'b1;
	Next_state = S1;
	end else Next_state = WAIT;
end
S1: begin
	newx_in = (X*32'b00000000000000000_110000000000000)>>15;//.75
	newy_in = Y;
	newz_in =Z+((~32'b00000000000000000_000110011010110)+1);//-.1
	Next_state = S2;
end

S2: begin
	if(Z==0)
	begin
	DONE=1'b1;
	Next_state = WAIT;
	end
	else
	begin
	newx_in = newx_in / Z * (1>>15);
	newy_in = newy_in / Z * (1>>15);
	newz_in = newz_in / Z * (1>>15);
	Next_state = S3;
	end
end
S3: begin
	Next_state = S4;
end
S4:
begin
	DONE = 1'b1;
	Next_state = WAIT;
end

endcase
end					
						
						


endmodule


/*
logic [31:0] newx_in,newy_in,newz_in,ox,oy,oz;

logic start,division_done,done1,done2,done3;
assign division_done = done1 & done2 & done3;
//STATE LOGIC 			
enum logic [7:0] {S1,S2,S3}   State, Next_state; 
always_ff @ (posedge CLK)
	begin
			State <= Next_state;
			newx <= newx_in;
			newy <= newy_in;
			newz <= newz_in;
	end
	
always_comb
begin
newx_in = newx;
newy_in = newy;
newz_in = newz;
DONE = 1'b0;
start = 1'b0;
Next_state = State;
unique case(State)
S1: begin
	if(startproj == 1'b1)
	begin
	newx_in = (X*32'b00000000000000000_110000000000000)>>15;//.75
	newy_in = Y;
	newz_in =Z+((~32'b00000000000000000_000110011010110)+1);//-.1
	Next_state = S2;
	end
	else
	begin
	Next_state = S1;
	end
end
S2: begin
	if(Z==0)
	begin
	DONE=1'b1;
	Next_state = S1;
	end
	else
	begin
	start = 1'b1;
	Next_state = S3;
	end
end
S3:begin
	if(division_done == 1'b1)
	begin
	newx_in = ox;
	newy_in = oy;
	newz_in = oz;
	DONE = 1'b1;
	Next_state = S1;
	end
	else Next_state = S3;
end
endcase
end

qdiv x1(.i_dividend(newx),.i_divisor(Z),.i_start(start),.i_clk(CLK),.o_quotient_out(ox),.o_complete(done1),.o_overflow());
qdiv y1(.i_dividend(newy),.i_divisor(Z),.i_start(start),.i_clk(CLK),.o_quotient_out(oy),.o_complete(done2),.o_overflow());
qdiv z2(.i_dividend(newz),.i_divisor(Z),.i_start(start),.i_clk(CLK),.o_quotient_out(oz),.o_complete(done3),.o_overflow());




*/






/*Division module taken from github:https://github.com/freecores/verilog_fixed_point_math_library/blob/master/qdiv.v*/
module qdiv #(
	//Parameterized values
	parameter Q = 15,
	parameter N = 32
	)
	(
	input 	[N-1:0] i_dividend,
	input 	[N-1:0] i_divisor,
	input 	i_start,
	input 	i_clk,
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
 
	always @( posedge i_clk ) begin
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
