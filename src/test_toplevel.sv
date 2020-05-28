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



module test_toplevel(input logic CLK, STARTER, input logic [31:0] x,y,z,
			output logic [31:0] newx,newy,newz);
logic startproj,DONE,RESET;
logic [31:0] projx,projy,projz,newx_in,newy_in;

projection p1(.X(x),.Y(y),.Z(z),.CLK(CLK), .startproj(startproj),
						 .newx(projx),.newy(projy),.newz(projz),
						.DONE(DONE));

enum logic [7:0] {START,WAIT,S1,S2,S3,S4}   State=START, Next_state; 
always_ff @ (posedge CLK)
	begin
	if(RESET)
	begin
	newx <= 0;
	newy <= 0;
	newz<=0;
	end else begin
			State <= Next_state;
			newx <= newx_in;
			newy <= newy_in;
			newz <= projz;end
	end
always_comb			
begin
Next_state = State;
startproj = 1'b0;
newx_in = newx;
newy_in = newy;
RESET = 1'b0;

unique case(State)
START: begin
if(STARTER) begin
startproj=1'b1;
RESET = 1'b1;
Next_state = S1;
end else Next_state = START;
end
S1: begin
Next_state = WAIT;
end
WAIT: begin
	if(DONE) begin 
	newx_in = projx + 32'b00000000000000001_000000000000000;//add 1
	newy_in = projy + 32'b00000000000000001_000000000000000;//add 1
	Next_state = S2;
	end else Next_state = WAIT;
end
S2: begin
		newx_in = (newx_in * 32'b00000000000000000_100000000000000)>>15; //.5
		newy_in = (newy_in * 32'b00000000000000000_100000000000000)>>15;//.5
		Next_state = S3;
		end
S3: begin
			newx_in = (newx_in * 32'b00000001010000000_000000000000000)>>15;//640
			newy_in = (newy_in * 32'b00000000111100000_000000000000000)>>15;//480	
			Next_state = S4;
end
S4: begin
	Next_state = START;
end
endcase
end		

endmodule


/*



logic [31:0] newx_in,newy_in,newz_in,ox,oy,oz;
logic DONE,startproj;
assign newz = oz;
 projection p1(.X(x),.Y(y),.Z(z),.CLK(CLK),.startproj(startproj),
						.newx(ox),.newy(oy),.newz(oz),
						 .DONE(DONE));
		
		
//STATE LOGIC 			
enum logic [7:0] {S1,S2,S3,S4}   State, Next_state; 
always_ff @ (posedge CLK)
	begin
		if(RESET)
		begin
		newx <= 0;newy<= 0;
		end
		else begin
			State <= Next_state;
			newx <= newx_in;
			newy <= newy_in;
		end
	end
	
always_comb
begin
Next_state = State;
newx_in = newx;
newy_in = newy;
startproj = 1'b1;
unique case(State)
S1: begin
	if(DONE == 1'b1)
	begin 

	Next_state = S2;
	end
	else Next_state = S1;
end
S2: begin
startproj =1'b0;

Next_state = S3;
end
S3:begin
newx_in = (newx_in * 32'b00000001010000000_000000000000000)>>15;//640
newy_in = (newy_in * 32'b00000000111100000_000000000000000)>>15;//480
Next_state = S4;
end
S4:begin

end
endcase
end*/




















