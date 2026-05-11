module PIDcontroller(Clk, correction, error);

	input Clk;
	input signed[2:0] error;
	output reg signed[8:0] correction;
	
	localparam Kp = 120;
	localparam Ki = 0;
	localparam Kd = 15;

	
	reg signed[15:0] integral;
	reg signed[2:0] prevError;
	
	initial begin

		integral = 0;
		prevError = 0;
		correction = 0;

	end
	
	always @(posedge Clk) begin
		reg signed[15:0] rawCorrection;
		integral <= integral + error;
		rawCorrection = (Kp * error) + (Ki * integral) + (Kd * (error - prevError));
		prevError <= error;
		if(rawCorrection > 200) correction <= 200;
		else if(rawCorrection < -200) correction <= -200;
		else correction <= rawCorrection[8:0];
		// prevent integral from growing too large
		/*if(integral > 5)       integral <= 2;
		else if(integral < -5) integral <= -2;
		else                    integral <= integral + error;*/
	end

endmodule