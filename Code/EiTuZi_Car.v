module EiTuZi_Car(IN1a, IN2a, IN3a, IN4a, IN1b, IN2b, IN3b, IN4b, HL);
	output IN1a, IN2a, IN3a, IN4a, IN1b, IN2b, IN3b, IN4b;
	output[2:0] HL;

	Motor_Driver M1(IN1a, IN2a, IN3a, IN4a);
	Motor_Driver M2(IN1b, IN2b, IN3b, IN4b);
	Headlights M3(HL);
	
endmodule