module PIDcontroller(Clk, correction, error);

    input Clk;
    input signed [2:0] error;
    output reg signed [9:0] correction;
    reg signed [15:0] rawCorrection;

    // Constante PD ajustate 
    localparam Kp = 70;  
    localparam Kd = 40;

    reg signed [15:0] integral;
    reg signed [2:0] prevError;
    
    initial begin
        prevError = 0;
        correction = 0;
    end
    
    always @(posedge Clk) begin
        rawCorrection <= (Kp * error) + (Kd * (error - prevError));
        prevError <= error;
        
    //Limitare corectii
        if(rawCorrection > 200)        correction <= 200;
        else if(rawCorrection < -200)  correction <= -200;
        else                           correction <= rawCorrection[7:0];
    end

endmodule