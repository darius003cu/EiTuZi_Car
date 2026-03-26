module Motor_Driver(IN1, IN2, IN3, IN4);
	output IN1, IN2, IN3, IN4;
	
	/* Forward direction */
	assign IN1 = 1'b0;
	assign IN2 = 1'b1;
	assign IN3 = 1'b0;
	assign IN4 = 1'b1;

	/* INPUT PINS: 40 - IN1, 41 - IN2, 42 - IN3, 43 - IN4 */
endmodule