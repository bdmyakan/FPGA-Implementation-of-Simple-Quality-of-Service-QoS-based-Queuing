module clock_divider_3sn(input clk, output reg clk_out);

integer c ;
integer max ;
initial begin 
c = 0 ;
max = 75000001 ;
clk_out = 0 ;
end 
always @(posedge clk) begin

c <= c + 1 ;

if (c == max) begin 
// in the 75000001 positive edge of clk we are giving positive edge clock out in that way we can achive 3sn clock
clk_out = ~clk_out ;
c <= 0 ;
end 
end 
endmodule
