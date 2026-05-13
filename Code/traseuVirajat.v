module traseuVirajat(Sensors, Clk, EN1A, EN2A, EN1B, EN2B, IN1A, IN2A, IN3A, IN4A, IN1B, IN2B, IN3B, IN4B);
    localparam baseSpeed = 150;
    input Clk;
    input[4:0] Sensors;
    output wire EN1A, EN2A, EN1B, EN2B;
    output wire IN1A, IN2A, IN3A, IN4A, IN1B, IN2B, IN3B, IN4B;
    reg[7:0] leftSpeed, rightSpeed;
    reg signed[2:0] error, lastError;
    wire signed[7:0] correction;
    reg[2:0] Trigger;
reg signed [9:0] rawLeft, rawRight; 


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
        Trigger = 2'b00;
    end

    /* Error from sensors - combinational */
    always @(Sensors) begin
        case(Sensors)
            5'b00100: error = 0;
            5'b00110: error = -1;
            5'b00010: error = -2;
            5'b01100: error = 1;
            5'b01000: error = 2;
            default:  error = lastError;
        endcase
        lastError = error;
    end

    /* Unified Speed Assignment & Trigger Sequence */
    always @(posedge Clk) begin
        
        // ==========================================
        // 1. UPDATE THE TRIGGER MEMORY
        // ==========================================
        case (Trigger)
            2'b000: begin // IDLE
                if (Sensors == 5'b10100) Trigger <= 2'b001; // ARM!
            end
            2'b001: begin // ARMED
                if (Sensors == 5'b00100) Trigger <= 2'b010; // FIRE! (Marker ended)
            end
            3'b010: begin // YANK LEFT (Waiting for the line to leave the center)
                // If the sensors are no longer reading the center 3 positions, move to State 11
                if (Sensors != 5'b00100 && Sensors != 5'b01100 && Sensors != 5'b00110) 
                    Trigger <= 2'b011; 
            end
            3'b011: begin // CATCH CURVE (Waiting to find line again)
                // Once the line swings back into any of the center 3 positions, the turn is done!
                if (Sensors == 5'b01100 || Sensors == 5'b00110 || Sensors == 5'b00100) 
                    Trigger <= 3'b000; // Back to PID!
            end
        endcase

        if (Trigger == 3'b010 || Trigger == 3'b011) begin
            leftSpeed  <= 0;  
            rightSpeed <= 255; 
        end
        
        else if (Trigger == 3'b001) begin
            leftSpeed  <= baseSpeed;
            rightSpeed <= baseSpeed;
        end
        
        else begin
            rawLeft  = baseSpeed + correction;
            rawRight = baseSpeed - correction;
            
            if(rawLeft < 0)       leftSpeed <= 0;
            else if(rawLeft > 255) leftSpeed <= 255;
            else                   leftSpeed <= rawLeft[7:0];

            if(rawRight < 0)       rightSpeed <= 0;
            else if(rawRight > 255) rightSpeed <= 255;
            else                    rightSpeed <= rawRight[7:0];
        end
    end
endmodule