module PWM_test(PWM, Clk);

reg[7:0] Duty_Cycle;
reg[7:0] Counter;
output reg PWM;
input Clk;


initial begin 
	PWM = 1'b0;
	Duty_Cycle = 10;
	Counter = 0;
	end

always @(posedge Clk) begin

	if(Counter <= 255) Counter <= Counter + 1;
	else Counter <= 0;
	
	if(Counter <= Duty_Cycle) PWM = 1'b1;
	else PWM = 1'b0;
	
end


endmodule
		
