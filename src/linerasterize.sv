/*After changing input values wait at least two clock cycles to start 
rasterization*/

module linerasterize(input logic  [8:0]x0,y0,x1,y1,
							input logic CLOCK_50,start,proj_fin,readFIFO,
							output logic is_done,
							output logic [17:0] outputFIFO, output logic [8:0] fifoSize,
							output logic is_calculating);
							
logic [8:0] minX,minX_in,maxX,maxX_in,minY,minY_in,maxY,maxY_in, dx,dx_in,dy,dy_in;
logic [31:0] p,p_in;

enum logic [7:0] {INITIAL,BEGIN,S1,S2,S3,S4,DONE,WAIT1,WAIT2,T1,T2,T3,T4,
						clear_calc}   State = INITIAL, Next_state; 
logic [8:0] x,x_in,y,y_in,size,size_in;
logic [17:0] coordinateData;
logic writeFIFO,negslope,negslope_in,bigslope,bigslope_in,is_done_in,
is_calculating_in;
assign fifoSize = size;


lineoutput coordinateInfo(
	.clock(CLOCK_50),
	.data(coordinateData),
	.rdreq(readFIFO),
	.wrreq(writeFIFO),
	.q(outputFIFO));	

always_ff @ (posedge CLOCK_50)
	begin
	State <= Next_state;
	x<=x_in;
	y<=y_in;
	size <= size_in;
	p<=p_in;
	if(start) begin
	minX <= 0;
	maxX <= 0;
	minY <= 0;
	maxY <= 0;
	negslope <= 0;
	bigslope <=0;
	is_done <= 1'b0; 
	dy<= 0;
	dx<=0;
	is_calculating <= 1'b1;
	end
	else begin
	is_done <= is_done_in;
	minX <= minX_in;
	maxX <= maxX_in;
	minY <= minY_in;
	maxY <= maxY_in;
	negslope <= negslope_in;
	bigslope <= bigslope_in;
	dy <= dy_in;
	dx <= dx_in;
	is_calculating <= is_calculating_in;
	end
	end
	

always_comb
	begin
	Next_state = State;
	is_done_in = is_done;
	size_in = size;
	x_in = x;
	y_in = y;
	writeFIFO = 1'b0;
	p_in = p;
	coordinateData = 18'b0;
	minX_in = minX;
	maxX_in = maxX;
	minY_in = minY;
	maxY_in = maxY;
	negslope_in = negslope;
	bigslope_in = bigslope;
	dy_in = dy;
	dx_in = dx;
	is_calculating_in = is_calculating;
	unique case(State)
	INITIAL: begin
	if(start)
	Next_state = T1;
	else
	Next_state = INITIAL;
	end
	T1: begin
	if(x0 < x1)
	minX_in = x0;
	else
	minX_in = x1;
	if(x0 > x1)
	maxX_in = x0;else
	maxX_in = x1;
	Next_state = T2;
	end
	T2: begin
	if(y0 < y1)
	minY_in = y0;else
	minY_in = y1;
	if(y0 > y1)
	maxY_in = y0;else
	maxY_in = y1;
	Next_state = T3;
	end
	T3:
	begin
	if((x0<x1 && y0 > y1) || (x1<x0 && y1>y0))
	negslope_in = 1'b1;
	else
	negslope_in = 1'b0;
	dy_in = maxY - minY;
	dx_in= maxX - minX;
	Next_state = T4;
	end
	T4:begin
	if(dy > dx)
	bigslope_in = 1'b1;
	else
	bigslope_in = 1'b0;
	Next_state = BEGIN;
	end
	BEGIN: begin
	if(bigslope)
	x_in = minY;
	else
	x_in = minX;	
	if(negslope)
	begin	
	if(bigslope)
	y_in = maxX;
	else
	y_in = maxY;
	end
	else begin
	if(bigslope)
	y_in = minX;
	else
	y_in = minY;
	end
	size_in = 9'b0;
	if(bigslope)
	p_in = (2*dx)-dy;
	else
	p_in = (2*dy)-dx;
	Next_state = S1;
	end
	S1:begin
	if(bigslope)begin
	if(x <= maxY) begin
	coordinateData = {y,x};
	writeFIFO = 1'b1;
	x_in++;
	size_in++;
	Next_state = S2; end
	else
	Next_state = DONE;
	end
	else begin
	if(x <= maxX) begin
	coordinateData = {x,y};
	writeFIFO = 1'b1;
	x_in++;
	size_in++;
	Next_state = S2; end
	else
	Next_state = DONE;
	end
	end
	S2: begin
	if(p[31] == 1 ) begin
	if(bigslope)
	p_in = p + (2*dx);
	else
	p_in = p + (2*dy);
	Next_state = S1;
	end 
	else begin
	if(bigslope)
	p_in = p + (2*dx) - (2*dy);
	else
	p_in = p + (2*dy) - (2*dx);
	if(negslope)
	y_in--;
	else
	y_in++;
	Next_state = S1;
				end
						end
	DONE:begin
	is_done_in = 1'b1;
	Next_state = clear_calc;
	end
	clear_calc: begin
	is_calculating_in = 1'b0;
	Next_state = INITIAL;
	end
	endcase
end
			
							
endmodule
