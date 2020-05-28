module testbench();
timeunit 10ns; //half clock cycle for 10ns, #1 is one time unit 
				
timeprecision 1ns; //round amount of time to nearest decimal point

logic [31:0] newx,newy,newz,x,y,z;
logic CLK,STARTER,DONE;
always
begin:clock_gen
#1 CLK = ~CLK;
end

initial 
begin:Clock_init
CLK = 0;
end

test_toplevel t1(.*);

initial begin
STARTER = 1'b0;
x=32'b0;
y=32'b0;
z=32'b0;
#1
STARTER =1'b1;
#1
STARTER = 1'b0;

end



endmodule
