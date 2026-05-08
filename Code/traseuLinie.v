module traseuLinie(Sensors, Clk, EN1A, EN2A, EN1B, EN2B, IN1A, IN2A, IN3A, IN4A, IN1B, IN2B, IN3B, IN4B);
    localparam baseSpeed = 200;
    input Clk;
    input[4:0] Sensors;
    output wire EN1A, EN2A, EN1B, EN2B;
    output reg IN1A, IN2A, IN3A, IN4A, IN1B, IN2B, IN3B, IN4B;
    reg[7:0] leftSpeed, rightSpeed;
    reg signed[2:0] error, lastError;
    wire signed[7:0] correction;
    reg stop;
    
    initial begin
        leftSpeed  = baseSpeed;
        rightSpeed = baseSpeed;
        error      = 0;
        lastError  = 0;
        stop       = 0;
        IN1A = 1'b0;
        IN2A = 1'b1;
        IN3A = 1'b0;
        IN4A = 1'b1;
        IN1B = 1'b0;
        IN2B = 1'b1;
        IN3B = 1'b0;
        IN4B = 1'b1;
    end
   
    
       /* Motor PWM */
 Motors_Speed ms0(EN1A, Clk, leftSpeed);
 Motors_Speed ms1(EN2A, Clk, rightSpeed);
 Motors_Speed ms2(EN1B, Clk, rightSpeed);
 Motors_Speed ms3(EN2B, Clk, leftSpeed);

      /* PID Controller */
 PIDcontroller pid(Clk, correction, error);
 
 always @(*) begin
        case(Sensors)
            5'b00100: error = 0;
            5'b00110: error = -1;
            5'b00010: error = -2;
            5'b01100: error = 1;
            5'b01000: error = 2;
            5'b10100: error = 0;
            5'b00101: error = 0;
            default:  error = lastError;
        endcase
    end

    
     always @(posedge Clk) begin
            if(stop == 1'b1 || Sensors == 5'b11111 || Sensors == 5'b11110 || Sensors == 5'b01111 || Sensors == 5'b01110 || Sensors == 5'b10111 || Sensors == 5'b11101 || Sensors == 5'b11011 || Sensors == 5'b11100 || Sensors == 5'b00111) begin
                  stop       <= 1'b1;
                  leftSpeed  <= 0;
                  rightSpeed <= 0;
                  IN1A <= 1'b1;
                  IN2A <= 1'b1;
                  IN3A <= 1'b1;
                  IN4A <= 1'b1;
                  IN1B <= 1'b1;
                  IN2B <= 1'b1;
                  IN3B <= 1'b1;
                  IN4B <= 1'b1;
             end else begin
                  lastError <= error;
                  IN1A <= 1'b0;
                  IN2A <= 1'b1;
                  IN3A <= 1'b0;
                  IN4A <= 1'b1;
                  IN1B <= 1'b0;
                  IN2B <= 1'b1;
                  IN3B <= 1'b0;
                  IN4B <= 1'b1;
         
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
             if(leftSpeed > 255)  leftSpeed  <= 255;
             if(rightSpeed > 255) rightSpeed <= 255;
            end
       end
        
 endmodule