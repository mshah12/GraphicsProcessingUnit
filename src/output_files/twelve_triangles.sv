
/*ONLY ACTIVATED 6 TRIANGLES OUT OF 12*/

module twelve_triangles(input [8:0] DrawX,DrawY,
								input [31:0] sin_out,cos_out,neg_sin_out,
								input INCREMENT_ANGLE,CLOCK_50,
								output logic [4:0] ANGLE_ADDRESS, output is_white);

logic w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12;

assign is_white = w1 | w2 | w3 | w4 | w5 | w6 | w7 | w8 | w9 | w10 | w11 | w12;				
		logic [63:0] v0x,v0y,v1x,v1y,v2x,v2y,
		v1x1,v2x1,v1x2,v2x2,v1x3,v2x3,v1x4,v2x4,v1x5,v2x5,v1x6,v2x6;
		logic [31:0]v0x_in,v0y_in,v1x_in,v1y_in,v2x_in,v2y_in,
		v0x_in1,v0y_in1,v1x_in1,v1y_in1,
		v2x_in1,v2y_in1,v0x_in2,v0y_in2,v1x_in2,v1y_in2,
		v2x_in2,v2y_in2,v0x_in3,v0y_in3,v1x_in3,v1y_in3,
		v2x_in3,v2y_in3,v0x_in4,v0y_in4,v1x_in4,v1y_in4,
		v2x_in4,v2y_in4,v0x_in5,v0y_in5,v1x_in5,v1y_in5,
		v2x_in5,v2y_in5,v0x_in6,v0y_in6,v1x_in6,v1y_in6,
		v2x_in6,v2y_in6,v0y_in7,v1x_in7,v1y_in7,
		v2x_in7,v2y_in7,v0y_in8,v1x_in8,v1y_in8,
		v2x_in8,v2y_in8,v0y_in9,v1x_in9,v1y_in9,
		v2x_in9,v2y_in9,v0y_in10,v1x_in10,v1y_in10,
		v2x_in10,v2y_in10,v0y_in11,v1x_in11,v1y_in11,
		v2x_in11,v2y_in11;							
		
		assign v0x_in = 32'b00000000001111000000000000000000;//120
		assign v0y_in = 32'b00000000001111000000000000000000;//120
		assign v1x_in = 32'b00000000010001100000000000000000;//140
		assign v1y_in = 32'b00000000010001100000000000000000;//140
		assign v2x_in = 32'b00000000010001100000000000000000;//140
		assign v2y_in = 32'b00000000001111000000000000000000;//120
		assign v0x_in1 = 32'b00000000001111000000000000000000;//120
		assign v0y_in1 = 32'b00000000001101110000000000000000;//110
		assign v1x_in1 = 32'b00000000010001100000000000000000;//140
		assign v1y_in1 = 32'b00000000001101110000000000000000;//110
		assign v2x_in1 = 32'b00000000010001100000000000000000;//140
		assign v2y_in1 = 32'b00000000001110011000000000000000;//115
		assign v0x_in2 = 32'b00000000001111000000000000000000;//120
		assign v0y_in2 = 32'b00000000001011010000000000000000;//90
		assign v1x_in2 = 32'b00000000010001100000000000000000;//140
		assign v1y_in2 = 32'b00000000001011010000000000000000;//90
		assign v2x_in2 = 32'b00000000010001100000000000000000;//140
		assign v2y_in2 = 32'b00000000001100100000000000000000;//100
		assign v0x_in3 = 32'b00000000001111000000000000000000;//120
		assign v0y_in3 = 32'b00000000001000110000000000000000;//70
		assign v1x_in3 = 32'b00000000010001100000000000000000;//140
		assign v1y_in3 = 32'b00000000001000110000000000000000;//70
		assign v2x_in3 = 32'b00000000010001100000000000000000;//140
		assign v2y_in3 = 32'b00000000001010101000000000000000;//85
		assign v0x_in4 = 32'b00000000001111000000000000000000;//120
		assign v0y_in4 = 32'b00000000000110010000000000000000;//50
		assign v1x_in4 = 32'b00000000010001100000000000000000;//140
		assign v1y_in4 = 32'b00000000000110010000000000000000;//50
		assign v2x_in4 = 32'b00000000010001100000000000000000;//140
		assign v2y_in4 = 32'b00000000001000001000000000000000;//65
		assign v0x_in5 = 32'b00000000001111000000000000000000;//120
		assign v0y_in5 = 32'b00000000000011110000000000000000;//30
		assign v1x_in5 = 32'b00000000010001100000000000000000;//140
		assign v1y_in5 = 32'b00000000000011110000000000000000;//30
		assign v2x_in5 = 32'b00000000010001100000000000000000;//140
		assign v2y_in5 = 32'b00000000000101101000000000000000;//45
		assign v0x_in6 = 32'b00000000001111000000000000000000;//120
		assign v0y_in6 = 32'b00000000000001010000000000000000;//10
		assign v1x_in6 = 32'b00000000010001100000000000000000;//140
		assign v1y_in6 = 32'b00000000000001010000000000000000;//10
		assign v2x_in6 = 32'b00000000010001100000000000000000;//140
		assign v2y_in6 = 32'b00000000000010100000000000000000;//20
		
		//assign v0x = ((v0x_in*cos_out)>>15) + ((sin_out*v0y_in)>>15);
		assign v1x = ((v1x_in*cos_out)>>15); //+ ((sin_out*v1y_in)>>15);
		assign v2x = ((v2x_in*cos_out)>>15); //+ ((sin_out*v2y_in)>>15);
		assign v1x1 = ((v1x_in1*cos_out)>>15); //+ ((sin_out*v1y_in)>>15);
		assign v2x1 = ((v2x_in1*cos_out)>>15); //+ ((sin_out*v2y_in)>>15);
		assign v1x2 = ((v1x_in2*cos_out)>>15); //+ ((sin_out*v1y_in)>>15);
		assign v2x2 = ((v2x_in2*cos_out)>>15); //+ ((sin_out*v2y_in)>>15);
		assign v1x3 = ((v1x_in3*cos_out)>>15); //+ ((sin_out*v1y_in)>>15);
		assign v2x3 = ((v2x_in3*cos_out)>>15); //+ ((sin_out*v2y_in)>>15);
		assign v1x4 = ((v1x_in4*cos_out)>>15); //+ ((sin_out*v1y_in)>>15);
		assign v2x4 = ((v2x_in4*cos_out)>>15); //+ ((sin_out*v2y_in)>>15);
		assign v1x5 = ((v1x_in5*cos_out)>>15); //+ ((sin_out*v1y_in)>>15);
		assign v2x5 = ((v2x_in5*cos_out)>>15); //+ ((sin_out*v2y_in)>>15);
		assign v1x6 = ((v1x_in6*cos_out)>>15); //+ ((sin_out*v1y_in)>>15);
		assign v2x6 = ((v2x_in6*cos_out)>>15); //+ ((sin_out*v2y_in)>>15);
		//assign v0y = ((v0x_in*neg_sin_out)>>15) + ((cos_out*v0y_in)>>15);
		//assign v1y = ((v1x_in*neg_sin_out)>>15) + ((cos_out*v1y_in)>>15);
		//assign v2y = ((v2x_in*neg_sin_out)>>15) + ((cos_out*v2y_in)>>15);
		
		always_ff @ (posedge CLOCK_50)
 		begin
		if(INCREMENT_ANGLE)
		ANGLE_ADDRESS <= ANGLE_ADDRESS + 1'b1;
		else if(ANGLE_ADDRESS == 9)
		ANGLE_ADDRESS <= 0;
		end

	/*Returns true if pixel at DrawX and DrawY should be white*/
	on_triangle t1(.v0x(v0x_in>>15),.v0y(v0y_in>>15),
					 .v1x(v1x>>15),.v1y(v1y_in>>15),
					 .v2x(v2x>>15),.v2y(v2y_in>>15),
					 .currx(DrawX),.curry(DrawY),
					.on_triangle(w1));		


	/*Returns true if pixel at DrawX and DrawY should be white*/
	on_triangle t2(.v0x(v0x_in1>>15),.v0y(v0y_in1>>15),
					 .v1x(v1x1>>15),.v1y(v1y_in1>>15),
					 .v2x(v2x1>>15),.v2y(v2y_in1>>15),
					 .currx(DrawX),.curry(DrawY),
					.on_triangle(w2));	

	/*Returns true if pixel at DrawX and DrawY should be white*/
	on_triangle t3(.v0x(v0x_in2>>15),.v0y(v0y_in2>>15),
					 .v1x(v1x2>>15),.v1y(v1y_in2>>15),
					 .v2x(v2x2>>15),.v2y(v2y_in2>>15),
					 .currx(DrawX),.curry(DrawY),
					.on_triangle(w3));
	/*Returns true if pixel at DrawX and DrawY should be white*/
	on_triangle t4(.v0x(v0x_in3>>15),.v0y(v0y_in3>>15),
					 .v1x(v1x3>>15),.v1y(v1y_in3>>15),
					 .v2x(v2x3>>15),.v2y(v2y_in3>>15),
					 .currx(DrawX),.curry(DrawY),
					.on_triangle(w4));	
	/*Returns true if pixel at DrawX and DrawY should be white*/
	on_triangle t5(.v0x(v0x_in4>>15),.v0y(v0y_in4>>15),
					 .v1x(v1x4>>15),.v1y(v1y_in4>>15),
					 .v2x(v2x4>>15),.v2y(v2y_in4>>15),
					 .currx(DrawX),.curry(DrawY),
					.on_triangle(w5));	
		/*Returns true if pixel at DrawX and DrawY should be white*/
	on_triangle t6(.v0x(v0x_in5>>15),.v0y(v0y_in5>>15),
					 .v1x(v1x5>>15),.v1y(v1y_in5>>15),
					 .v2x(v2x5>>15),.v2y(v2y_in5>>15),
					 .currx(DrawX),.curry(DrawY),
					.on_triangle(w6));	
		/*Returns true if pixel at DrawX and DrawY should be white*/
	on_triangle t7(.v0x(v0x_in6>>15),.v0y(v0y_in6>>15),
					 .v1x(v1x6>>15),.v1y(v1y_in6>>15),
					 .v2x(v2x6>>15),.v2y(v2y_in6>>15),
					 .currx(DrawX),.curry(DrawY),
					.on_triangle(w7));	
//					
//		/*Returns true if pixel at DrawX and DrawY should be white*/
//	on_triangle t8(.v0x(v0x_in>>15),.v0y(v0y_in>>15),
//					 .v1x(v1x>>15),.v1y(v1y_in>>15),
//					 .v2x(v2x>>15),.v2y(v2y_in>>15),
//					 .currx(DrawX),.curry(DrawY),
//					.on_triangle(w8));	
//					
//		/*Returns true if pixel at DrawX and DrawY should be white*/
//	on_triangle t9(.v0x(v0x_in>>15),.v0y(v0y_in>>15),
//					 .v1x(v1x>>15),.v1y(v1y_in>>15),
//					 .v2x(v2x>>15),.v2y(v2y_in>>15),
//					 .currx(DrawX),.curry(DrawY),
//					.on_triangle(w9));	
//					
//					
//	/*Returns true if pixel at DrawX and DrawY should be white*/
//	on_triangle t10(.v0x(v0x_in>>15),.v0y(v0y_in>>15),
//					 .v1x(v1x>>15),.v1y(v1y_in>>15),
//					 .v2x(v2x>>15),.v2y(v2y_in>>15),
//					 .currx(DrawX),.curry(DrawY),
//					.on_triangle(w10));	
//					
//					
//	/*Returns true if pixel at DrawX and DrawY should be white*/
//	on_triangle t11(.v0x(v0x_in>>15),.v0y(v0y_in>>15),
//					 .v1x(v1x>>15),.v1y(v1y_in>>15),
//					 .v2x(v2x>>15),.v2y(v2y_in>>15),
//					 .currx(DrawX),.curry(DrawY),
//					.on_triangle(w11));	
//					
//					
//	/*Returns true if pixel at DrawX and DrawY should be white*/
//	on_triangle t12(.v0x(v0x_in>>15),.v0y(v0y_in>>15),
//					 .v1x(v1x>>15),.v1y(v1y_in>>15),
//					 .v2x(v2x>>15),.v2y(v2y_in>>15),
//					 .currx(DrawX),.curry(DrawY),
//					.on_triangle(w12));	





endmodule
