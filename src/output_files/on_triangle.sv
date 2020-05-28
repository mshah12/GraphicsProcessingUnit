/*Checks if current x,y coordinate lies on the edge of a triangle, 
if so then return a 1, if not then return a 0*/
module on_triangle(input [8:0] v0x,v0y,
							v1x,v1y,
							v2x,v2y,
							currx,curry,
							output on_triangle);

logic on_line1,on_line2,on_line3;

assign on_triangle =  on_line1 | on_line2 | on_line3;							
							
rasterizeline l1(.x0(v0x),.y0(v0y),.x1(v1x),.y1(v1y),.px(currx),.py(curry),
						.on_line(on_line1));
rasterizeline l2(.x0(v1x),.y0(v1y),.x1(v2x),.y1(v2y),.px(currx),.py(curry),
						.on_line(on_line2));
rasterizeline l3(.x0(v2x),.y0(v2y),.x1(v0x),.y1(v0y),.px(currx),.py(curry),
						.on_line(on_line3));

endmodule
