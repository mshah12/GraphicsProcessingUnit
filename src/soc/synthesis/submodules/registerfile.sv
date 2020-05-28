module registerfile (
	// Avalon Clock Input
	input logic CLK,
	
	// Avalon Reset Input
	input logic RESET,
	
	// Avalon-MM Slave Signals
	input  logic AVL_READ,					// Avalon-MM Read
	input  logic AVL_WRITE,					// Avalon-MM Write
	input  logic AVL_CS,						// Avalon-MM Chip Select
	input  logic [6:0] AVL_ADDR,			// Avalon-MM Address
	input  logic [31:0] AVL_WRITEDATA,	// Avalon-MM Write Data
	output logic [31:0] AVL_READDATA,	// Avalon-MM Read Data
	
	// Exported Conduit
	output logic [1151:0] EXPORT_X,		// Exported Conduit Signal to LEDs
	output logic [1151:0] EXPORT_Y,
	output logic [1151:0] EXPORT_Z,
	output logic [31:0] EXPORT_START,
	output logic [31:0] EXPORT_SIZE
);

logic [31:0] regs[128];

always_ff @ (posedge CLK)
begin
if(RESET)
begin
	for(int i=0;i<128;i++)
	begin
		regs[i] <= 32'b00000000000000000000000000000000;
	end
end
if(AVL_WRITE == 1'b1 && AVL_CS == 1'b1)
begin
	regs[AVL_ADDR] <= AVL_WRITEDATA;
end	
if(AVL_READ == 1'b1 && AVL_CS == 1'b1)
begin
	AVL_READDATA <= regs[AVL_ADDR];
end
end

always_comb
begin
EXPORT_X = {{regs[0]}, {regs[1]}, {regs[2]}, {regs[3]}, {regs[4]}, {regs[5]}, {regs[6]}, {regs[7]}, {regs[8]}, {regs[9]}, {regs[10]}, {regs[11]}, {regs[12]}, {regs[13]}, {regs[14]}, {regs[15]}, {regs[16]}, {regs[17]}, {regs[18]}, {regs[19]}, {regs[20]}, {regs[21]}, {regs[22]}, {regs[23]}, {regs[24]}, {regs[25]}, {regs[26]}, {regs[27]}, {regs[28]}, {regs[29]}, {regs[30]}, {regs[31]}, {regs[32]}, {regs[33]}, {regs[34]}, {regs[35]}};
EXPORT_Y = {{regs[36]}, {regs[37]}, {regs[38]}, {regs[39]}, {regs[40]}, {regs[41]}, {regs[42]}, {regs[43]}, {regs[44]}, {regs[45]}, {regs[46]}, {regs[47]}, {regs[48]}, {regs[49]}, {regs[50]}, {regs[51]}, {regs[52]}, {regs[53]}, {regs[54]}, {regs[55]}, {regs[56]}, {regs[57]}, {regs[58]}, {regs[59]}, {regs[60]}, {regs[61]}, {regs[62]}, {regs[63]}, {regs[64]}, {regs[65]}, {regs[66]}, {regs[67]}, {regs[68]}, {regs[69]}, {regs[70]}, {regs[71]}};
EXPORT_Z = {{regs[72]}, {regs[73]}, {regs[74]}, {regs[75]}, {regs[76]}, {regs[77]}, {regs[78]}, {regs[79]}, {regs[80]}, {regs[81]}, {regs[82]}, {regs[83]}, {regs[84]}, {regs[85]}, {regs[86]}, {regs[87]}, {regs[88]}, {regs[89]}, {regs[90]}, {regs[91]}, {regs[92]}, {regs[93]}, {regs[94]}, {regs[95]}, {regs[96]}, {regs[97]}, {regs[98]}, {regs[99]}, {regs[100]}, {regs[101]}, {regs[102]}, {regs[103]}, {regs[104]}, {regs[105]}, {regs[106]}, {regs[107]}};
EXPORT_START = regs[126];
EXPORT_SIZE = regs[127];
end

endmodule

//module registerfile (
//	// Avalon Clock Input
//	input logic CLK,
//	
//	// Avalon Reset Input
//	input logic RESET,
//	
//	// Avalon-MM Slave Signals
//	input  logic AVL_READ,					// Avalon-MM Read
//	input  logic AVL_WRITE,					// Avalon-MM Write
//	input  logic AVL_CS,						// Avalon-MM Chip Select
//	input  logic AVL_START,
//	input  logic [6:0] AVL_ADDR,			// Avalon-MM Address
//	input  logic [31:0] AVL_WRITEDATA,	// Avalon-MM Write Data
//	output logic [31:0] AVL_READDATA,	// Avalon-MM Read Data
//	
//	// Exported Conduit
//	output logic [31:0] EXPORT_X[12][3],		// Exported Conduit Signal to LEDs
//	output logic [31:0] EXPORT_Y[12][3],
//	output logic [31:0] EXPORT_Z[12][3],
//	output logic [31:0] EXPORT_START,
//	output logic [31:0] EXPORT_SIZE
//);
//
//logic done, donein;
//logic [31:0] regs[128], size, sizein;
//logic [6:0] tracker, trackerin;
//
//enum logic [7:0] {WAIT,S0,S1,S2,S3,S4,DONE} State = WAIT, Next_state;
//
//always_ff @ (posedge CLK)
//begin
//	State <= Next_state;
//	done <= donein;
//	size <= sizein;
//	tracker <= trackerin;
//end
//
//always_comb
//begin
//Next_state = State;
//donein = done;
//sizein = size;
//trackerin = tracker;
//
//unique case(State)
//	
//	WAIT:
//	begin
//	donein = 1'b0;
//	sizein = 32'b00000000000000000000000000000000;
//	trackerin = 7'b0000000;
//	if(AVL_WRITE == 1'b1 && AVL_CS == 1'b1)
//	begin
//	Next_state = S0;
//	end
//	if(AVL_READ == 1'b1 && AVL_CS == 1'b1)
//	begin
//	Next_state = S1;
//	end
//	AVL_READDATA = 32'hXXXXXXXX;
//	Next_state = WAIT;
//	end
//	
//	S0:
//	begin
//	sizein++;
//	regs[AVL_ADDR] = AVL_WRITEDATA;
//	Next_state = S2;
//	end
//	
//	S1:
//	begin
//	AVL_READDATA = regs[AVL_ADDR];
//	Next_state = S2;
//	end
//	
//	S2:
//	begin
//	donein = 1'b1;
//	Next_state = S3;
//	end
//	
//	S3:
//	begin
//	EXPORT_START = done;
//	EXPORT_SIZE = size;
//	end
//	
//	default: ;
//	
//	endcase
//	end
//
//endmodule

