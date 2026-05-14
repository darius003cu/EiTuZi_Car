module traseuVirajat(Sensors, Clk, EN1A, EN2A, EN1B, EN2B, IN1A, IN2A, IN3A, IN4A, IN1B, IN2B, IN3B, IN4B, led);
    localparam baseSpeed = 120;
    input Clk;
    input[4:0] Sensors;
    output wire EN1A, EN2A, EN1B, EN2B;
    output wire IN1A, IN2A, IN3A, IN4A, IN1B, IN2B, IN3B, IN4B;
    output wire[2:0] led;
    reg signed [9:0] rawLeft, rawRight;

    reg [7:0] leftSpeed, rightSpeed;
    reg signed [2:0] error;
    wire signed [7:0] correction;
    reg finishLine;

	//Forward movement of the car
    assign IN1A = 1'b0;
    assign IN2A = 1'b1;
    assign IN3A = 1'b0;
    assign IN4A = 1'b1;
    assign IN1B = 1'b0;
    assign IN2B = 1'b1;
    assign IN3B = 1'b0;
    assign IN4B = 1'b1;
    
    //Modules for PWM, PID controller and lights
    Motors_Speed ms0(EN1A, Clk, leftSpeed);  
    Motors_Speed ms1(EN2A, Clk, rightSpeed); 
    Motors_Speed ms2(EN1B, Clk, rightSpeed); 
    Motors_Speed ms3(EN2B, Clk, leftSpeed);  

    PIDcontroller pid(Clk, correction, error);
    corneringLights LEDs(Clk, Sensors, led, finishLine); 

    initial begin
        leftSpeed  = baseSpeed;
        rightSpeed = baseSpeed;
        error      = 0;
        finishLine = 1'b0;
    end

	//Error calculation (based on how far the center sensor is from the main road
    always @(posedge Clk) begin
        case(Sensors)
            5'b00100: error <= 0;
            5'b00110: error <= -1;
            5'b00010: error <= -2;
            5'b00001: error <= -3;
            5'b01100: error <= 1;
            5'b01000: error <= 2;
            5'b10000: error <= 3;
            default:  error <= error;
        endcase
    end

    always @(posedge Clk) begin
        
        case(Sensors) 
            5'b10100, 5'b00101: begin
                rawLeft  = baseSpeed - 30;
                rawRight = baseSpeed - 30;
            end
                        
            default: begin
                rawLeft  = baseSpeed + correction;
                rawRight = baseSpeed - correction;
            end
        endcase

        if(rawLeft < 0)        leftSpeed <= 0;
        else if(rawLeft > 255) leftSpeed <= 255;
        else                   leftSpeed <= rawLeft[7:0];
        
        if(rawRight < 0)        rightSpeed <= 0;
        else if(rawRight > 255) rightSpeed <= 255;
        else                    rightSpeed <= rawRight[7:0];
        
    end
endmodule