module Motors_Speed(PWM, Clk, Duty_Cycle);

input Clk;
input[7:0] Duty_Cycle;
reg[7:0] Counter;
output reg PWM;

always @(posedge Clk) begin

	Counter <= Counter + 1;
	PWM <= (Counter <= Duty_Cycle);
	
end

endmodule
		
