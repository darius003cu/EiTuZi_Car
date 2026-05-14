module traseuVirajat(Sensors, Clk, EN1A, EN2A, EN1B, EN2B, IN1A, IN2A, IN3A, IN4A, IN1B, IN2B, IN3B, IN4B, led);
    
    input Clk;
    input [4:0] Sensors;
    output wire EN1A, EN2A, EN1B, EN2B;
    output reg IN1A, IN2A, IN3A, IN4A, IN1B, IN2B, IN3B, IN4B;
    output wire [2:0] led;
    
    reg signed [10:0] rawLeft, rawRight; 
    reg [7:0] leftSpeed, rightSpeed;
    
    // Variabile control
    reg signed [9:0] currentBaseSpeed;
    reg signed [2:0] error;
    wire signed [9:0] correction; 
    
    // --- LOGICA FINISH CU COOLDOWN ---
    reg [3:0] intersect_count; 
    reg prev_intersect;
    reg [25:0] cooldown_timer; 
    wire finishLine = (intersect_count >= 6); // FIRUL DE LEGATURA
    
    wire [2:0] centerSensors = Sensors[3:1];
    
    // Instan?ieri PWM
    Motors_Speed ms0(EN1A, Clk, leftSpeed);  
    Motors_Speed ms1(EN2A, Clk, rightSpeed); 
    Motors_Speed ms2(EN1B, Clk, rightSpeed); 
    Motors_Speed ms3(EN2B, Clk, leftSpeed);  

    // PID cu mapare corecta
    PIDcontroller pid(
        .Clk(Clk), 
        .error(error), 
        .correction(correction)
    );
    
    // LED-uri cu legatura la finishLine
    corneringLights LEDs(
        .Clk(Clk), 
        .Sensors(Sensors), 
        .Led(led), 
        .finishLine(finishLine)
    ); 

    initial begin
        leftSpeed  = 100;
        rightSpeed = 100;
        currentBaseSpeed = 100;
        error      = 0;
        intersect_count = 0;
        prev_intersect = 0;
        cooldown_timer = 0;
    end

    // BLOC NUMARATOR (Edge Detector + Cooldown)
    always @(posedge Clk) begin
        if (cooldown_timer > 0) cooldown_timer <= cooldown_timer - 1;
        prev_intersect <= (centerSensors == 3'b111);
        
        if ((centerSensors == 3'b111) && (prev_intersect == 1'b0) && (cooldown_timer == 0)) begin
            intersect_count <= intersect_count + 1;
            cooldown_timer <= 30000000; 
        end
    end

    // BLOC LOGICA MOTOARE
    always @(posedge Clk) begin
        case(centerSensors)
            3'b010: begin error <= 0;  currentBaseSpeed <= 100; end 
            3'b011: begin error <= -1; currentBaseSpeed <= 65;  end 
            3'b001: begin error <= -3; currentBaseSpeed <= 50;  end 
            3'b110: begin error <= 1;  currentBaseSpeed <= 65;  end 
            3'b100: begin error <= 3;  currentBaseSpeed <= 50;  end 
            3'b000: begin error <= error; currentBaseSpeed <= 90; end
            3'b111: begin error <= 0;  currentBaseSpeed <= 100; end
            default: begin error <= error; currentBaseSpeed <= currentBaseSpeed; end
        endcase

        rawLeft  <= currentBaseSpeed + correction;
        rawRight <= currentBaseSpeed - correction;

        if (finishLine) begin
            // STOP ?I FRÂNA
            IN1A <= 1'b0; IN2A <= 1'b0; IN3B <= 1'b0; IN4B <= 1'b0; 
            IN3A <= 1'b0; IN4A <= 1'b0; IN1B <= 1'b0; IN2B <= 1'b0; 
            leftSpeed <= 0; rightSpeed <= 0;
        end else begin
            // TANK TURN STÂNGA
            if (rawLeft < 0) begin
                IN1A <= 1'b1; IN2A <= 1'b0; IN3B <= 1'b1; IN4B <= 1'b0; 
                leftSpeed <= (rawLeft < -70) ? 70 : -rawLeft;
            end else begin
                IN1A <= 1'b0; IN2A <= 1'b1; IN3B <= 1'b0; IN4B <= 1'b1; 
                leftSpeed <= (rawLeft > 255) ? 255 : rawLeft[7:0];
            end
            // TANK TURN DREAPTA
            if (rawRight < 0) begin
                IN3A <= 1'b1; IN4A <= 1'b0; IN1B <= 1'b1; IN2B <= 1'b0; 
                rightSpeed <= (rawRight < -70) ? 70 : -rawRight;
            end else begin
                IN3A <= 1'b0; IN4A <= 1'b1; IN1B <= 1'b0; IN2B <= 1'b1; 
                rightSpeed <= (rawRight > 255) ? 255 : rawRight[7:0];
            end
        end
    end
endmodule