/*module traseuVirajat(Sensors, Clk, EN1A, EN2A, EN1B, EN2B, IN1A, IN2A, IN3A, IN4A, IN1B, IN2B, IN3B, IN4B);

	localparam baseSpeed = 100;

	input Clk;
	input[4:0] Sensors;
	output wire EN1A, EN2A, EN1B, EN2B;
	output wire IN1A, IN2A, IN3A, IN4A, IN1B, IN2B, IN3B, IN4B;
	reg[7:0] leftSpeed, rightSpeed;
	reg leftTriggered, rightTriggered;
	
	
	assign IN1A = 1'b0;
    assign IN2A = 1'b1;
    assign IN3A = 1'b0;
    assign IN4A = 1'b1;
    assign IN1B = 1'b0;
    assign IN2B = 1'b1;
    assign IN3B = 1'b0;
    assign IN4B = 1'b1;
    
    
    Motors_Speed ms0(EN1A, Clk, leftSpeed);
    Motors_Speed ms1(EN2A, Clk, rightSpeed);
    Motors_Speed ms2(EN1B, Clk, rightSpeed);
    Motors_Speed ms3(EN2B, Clk, leftSpeed);
        
    initial begin
		
		leftSpeed      = baseSpeed;
		rightSpeed     = baseSpeed;
		leftTriggered = 0;
		rightTriggered = 0;
		
    end
    
// Block 2 - clocked, applies correction to speed after PID has computed
/*always @(Sensors) begin
    case(Sensors)
        5'b00100: begin
			if(leftTriggered == 1'b1) begin
			
			leftSpeed = baseSpeed - 50;
            rightSpeed = baseSpeed + 20;
        
        end
			else begin
            leftSpeed = baseSpeed;
            rightSpeed = baseSpeed;
            leftTriggered = 1'b0;

            end
        end
        5'b00101: begin
        
            leftSpeed  = baseSpeed;
            rightSpeed = baseSpeed;
            leftTriggered = 1'b1;
            
        end
        
        5'b00000: begin
            if(leftTriggered == 1'b1) begin
            
				leftSpeed = baseSpeed - 50;
				rightSpeed = baseSpeed + 20;
            
            end
            else begin
            
				leftSpeed = 0;
				rightSpeed = 0;
				leftTriggered = 1'b0;

				end
        end
        
        5'b01000: begin
	
			leftSpeed = baseSpeed + 50;
			rightSpeed = baseSpeed - 30;
			leftTriggered = 1'b0;
	
		end
        
        
        default: begin
            if(leftTriggered == 1'b1) begin
			leftSpeed = baseSpeed - 50;
            rightSpeed = baseSpeed + 20;
        end
        else begin
			leftSpeed = baseSpeed;
            rightSpeed = baseSpeed;
            leftTriggered = 1'b0;
        end
        end
    endcase
end

always @(Sensors) begin
    case(Sensors)
        5'b00100: error = 0;
        5'b00110: error = -1;
        5'b00010: error = -2;
        5'b00001: error = -3;
        5'b01100: error = 1;
        5'b01000: error = 2;
        5'b10000: error = 3;
        5'b10100: error = 0;
        5'b00101: error = 0;
        default:  error = lastError;
    endcase
    lastError = error;
end

// Block 2 - clocked, applies correction to speed after PID has computed
always @(posedge Clk) begin
    case(Sensors)
        5'b10100: begin
            leftSpeed  <= 160 + correction;
            rightSpeed <= 160 - correction;
        end
        5'b00101: begin
            leftSpeed  <= 160 + correction;
            rightSpeed <= 160 - correction;
        end
        5'b00000: begin
            leftSpeed  <= 120;
            rightSpeed <= 120;
        end
        default: begin
            leftSpeed  <= baseSpeed + correction;
            rightSpeed <= baseSpeed - correction;
        end
    endcase

    if(leftSpeed < 120)  leftSpeed  <= 120;
    if(rightSpeed < 120) rightSpeed <= 120;
    if(leftSpeed > 255)  leftSpeed  <= 255;
    if(rightSpeed > 255) rightSpeed <= 255;
end
    
endmodule*/

module traseuVirajat(Sensors, Clk, EN1A, EN2A, EN1B, EN2B, IN1A, IN2A, IN3A, IN4A, IN1B, IN2B, IN3B, IN4B);
    localparam baseSpeed = 100;
    input Clk;
    input[4:0] Sensors;
    output wire EN1A, EN2A, EN1B, EN2B;
    output wire IN1A, IN2A, IN3A, IN4A, IN1B, IN2B, IN3B, IN4B;
    reg[7:0] leftSpeed, rightSpeed;
    reg signed[2:0] error, lastError;
    wire signed[7:0] correction;

    /* Forward movement */
    assign IN1A = 1'b0;
    assign IN2A = 1'b1;
    assign IN3A = 1'b0;
    assign IN4A = 1'b1;
    assign IN1B = 1'b0;
    assign IN2B = 1'b1;
    assign IN3B = 1'b0;
    assign IN4B = 1'b1;

    /* Motor PWM */
    Motors_Speed ms0(EN1A, Clk, leftSpeed);
    Motors_Speed ms1(EN2A, Clk, rightSpeed);
    Motors_Speed ms2(EN1B, Clk, rightSpeed);
    Motors_Speed ms3(EN2B, Clk, leftSpeed);

    /* PID Controller */
    PIDcontroller pid(Clk, correction, error);

    initial begin
        leftSpeed  = baseSpeed;
        rightSpeed = baseSpeed;
        error      = 0;
        lastError  = 0;
    end

    /* Error from sensors - combinational */
    always @(Sensors) begin
        case(Sensors)
            5'b00100: error = 0;
            5'b00110: error = -1;
            5'b00010: error = -2;
            5'b00001: error = -3;
            5'b01100: error = 1;
            5'b01000: error = 2;
            5'b10000: error = 3;
            5'b10100: error = 0;
            5'b00101: error = 0;
            default:  error = lastError;
        endcase
        lastError = error;
    end

    /* Speed assignment - clocked */
    always @(posedge Clk) begin
        case(Sensors)
            5'b10100: begin
                leftSpeed  <= 90 + correction;
                rightSpeed <= 90 - correction;
            end
            5'b00101: begin
                leftSpeed  <= 90 + correction;
                rightSpeed <= 90 - correction;
            end
            5'b00000: begin
                leftSpeed  <= 90;
                rightSpeed <= 90;
            end
            default: begin
                leftSpeed  <= baseSpeed + correction;
                rightSpeed <= baseSpeed - correction;
            end
        endcase

        if(leftSpeed < 50)  leftSpeed  <= 50;
        if(rightSpeed < 50) rightSpeed <= 50;
        if(leftSpeed > 200)  leftSpeed  <= 200;
        if(rightSpeed > 200) rightSpeed <= 200;
    end

endmodule