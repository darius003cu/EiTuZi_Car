
module PIDcontroller(Clk, correction, error);

	input Clk;
	input signed[2:0] error;
	output reg signed[7:0] correction;
	reg signed[15:0] rawCorrection;

	
	localparam Kp = 100;
	localparam Ki = 0;
	localparam Kd = 25;

	
	reg signed[15:0] integral;
	reg signed[2:0] prevError;
	
	initial begin

		integral = 0;
		prevError = 0;
		correction = 0;

	end
	
	always @(posedge Clk) begin
		integral <= integral + error;
		rawCorrection <= (Kp * error) + (Ki * integral) + (Kd * (error - prevError));
		prevError <= error;
		if(rawCorrection > 80) correction <= 80;
		else if(rawCorrection < -80) correction <= -80;
		else correction <= rawCorrection;
	end

endmodule