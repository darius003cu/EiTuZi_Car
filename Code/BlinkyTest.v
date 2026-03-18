/* Test code for led blinking */

module BlinkyTest(

input		Clk,
output reg 	Led

);

	reg State = 0;
	
	always @(posedge Clk) begin
		Led <= ~Led;
	end
	
	
endmodule