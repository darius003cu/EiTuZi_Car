/* Test code for led blinking */

module BlinkyTest(

input		Clk,
output reg 	Led

);

	reg State = 0;
	
	initial begin
		Led = 1;
	end
	
	
endmodule

