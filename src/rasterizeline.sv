/*There are techniques that can reduce the multiplications to just addition*/
module rasterizeline(input  [8:0]x0,y0,x1,y1,px,py,
							output  on_line);

logic [8:0] minX,maxX,minY,maxY;
logic [16:0] result;
always_comb
begin
if(x0 < x1)
minX = x0;else
minX = x1;
end
always_comb
begin
if(y0 < y1)
minY = y0;else
minY = y1;
end

always_comb
begin
if(x0 > x1)
maxX = x0;else
maxX = x1;
end
always_comb
begin
if(y0 > y1)
maxY = y0;else
maxY = y1;
end

assign result = (((px-x0)*(y1-y0))-((py-y0)*(x1-x0)));

always_comb
begin
if(result == 0)
begin
if(px >= minX && py >=minY && px <= maxX && py <=maxY)
on_line = 1'b1;else
on_line = 1'b0;
end
else
begin
on_line = 1'b0;
end
end
endmodule
