/* Code for testing the sensors
*  AI  -> Analog Input
*  DO  -> Digital Output
*  
*/

module Sensor_Test(AI, DO, D1);
	input AI;
	output DO, D1;
	reg DO, D1;
	
	
	always @(AI) begin
		if(AI == 1'b0)											
			begin
				DO = 1'b0;
				D1 = 1'b1;
			end
		else
			begin
				DO = 1'b1;
				D1 = 1'b1;
			end
		end
	
endmodule