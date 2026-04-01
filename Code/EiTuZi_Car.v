module EiTuZi_Car(IN1a, IN2a, IN3a, IN4a, IN1b, IN2b, IN3b, IN4b, HL, AnalogInput);
	output IN1a, IN2a, IN3a, IN4a, IN1b, IN2b, IN3b, IN4b;
	output[2:0] 	HL;
	input  	AnalogInput;
	
	Motor_Driver M1(IN1a, IN2a, IN3a, IN4a);
	Motor_Driver M2(IN1b, IN2b, IN3b, IN4b);
	Headlights	L1(HL);
	
	//Motor_Driver M1(IN1a, IN2a, IN3a, IN4a);
	//Motor_Driver M2(IN1b, IN2b, IN3b, IN4b);
	
endmodule