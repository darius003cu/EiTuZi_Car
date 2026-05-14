module traseuVirajat(Sensors, Clk, EN1A, EN2A, EN1B, EN2B, IN1A, IN2A, IN3A, IN4A, IN1B, IN2B, IN3B, IN4B, led);
    
    input Clk;
    input [4:0] Sensors;
    output wire EN1A, EN2A, EN1B, EN2B;
    // Pinii IN sunt acum de tip "reg" pentru a putea schimba direc?ia dinamic!
    output reg IN1A, IN2A, IN3A, IN4A, IN1B, IN2B, IN3B, IN4B;
    output wire [2:0] led;
    
    reg signed [10:0] rawLeft, rawRight; 
    reg [7:0] leftSpeed, rightSpeed;
    
    // Variabile pentru controlul dinamic al vitezei si erorii
    reg signed [9:0] currentBaseSpeed;
    reg signed [2:0] error;
    wire signed [9:0] correction; 
    wire finishLine = 1'b0; 
    
    // Extragem doar senzorii centrali pentru direc?ie
    wire [2:0] centerSensors = Sensors[3:1];
    
    // Instan?ierea modulelor secundare
    Motors_Speed ms0(EN1A, Clk, leftSpeed);  // Stânga Fa?a
    Motors_Speed ms1(EN2A, Clk, rightSpeed); // Dreapta Fa?a
    Motors_Speed ms2(EN1B, Clk, rightSpeed); // Dreapta Spate
    Motors_Speed ms3(EN2B, Clk, leftSpeed);  // Stânga Spate

    PIDcontroller pid(Clk, correction, error);
    corneringLights LEDs(Clk, Sensors, led, finishLine); 

    initial begin
        leftSpeed  = 90;
        rightSpeed = 90;
        currentBaseSpeed = 90;
        error      = 0;
    end

    always @(posedge Clk) begin
        
        // =======================================================
        // 1. SETAREA VITEZEI DE BAZA ?I A ERORII
        // =======================================================
        case(centerSensors)
            3'b010: begin error <= 0;  currentBaseSpeed <= 90; end // Centru perfect
            
            // --- CURBA LA STÂNGA ---
            3'b011: begin error <= -1;  currentBaseSpeed <= 65; end // U?or Stânga
            3'b001: begin error <= -3;  currentBaseSpeed <= 50; end // Strâns Stânga
            
            // --- CURBA LA DREAPTA ---
            3'b110: begin error <= 1; currentBaseSpeed <= 65; end // U?or Dreapta
            3'b100: begin error <= 3; currentBaseSpeed <= 50; end // Strâns Dreapta
            
            // --- PIERDERE LINIE ---
            3'b000: begin 
                error <= error;          // Pastreaza ultima direc?ie!
                currentBaseSpeed <= 80;  // ?oc de putere pentru a for?a redresarea
            end
            
            3'b111: begin
				error <= 0;
				currentBaseSpeed <= 90;
			end
            
            default: begin error <= error; currentBaseSpeed <= currentBaseSpeed; end
        endcase

        // =======================================================
        // 2. APLICAREA MATEMATICII PID
        // =======================================================
        rawLeft  <= currentBaseSpeed + correction;
        rawRight <= currentBaseSpeed - correction;

        // =======================================================
        // 3. TANK TURN - CONTROLUL DIREC?IEI ?I AL VITEZEI RO?ILOR
        // =======================================================
        
        // =======================================================
        // 3. TANK TURN - CONTROLUL DIREC?IEI ?I AL VITEZEI RO?ILOR
        // =======================================================
        
        // --- RO?ILE DIN STÂNGA ---
        if (rawLeft < 0) begin
            // MERS ÎNAPOI
            IN1A <= 1'b1; IN2A <= 1'b0; // Fa?a
            IN3B <= 1'b1; IN4B <= 1'b0; // Spate
            
            // LIMITATOR DE SPIN: Nu o lasam sa dea înapoi prea tare!
            // Taiem for?a mar?arierului la maxim 70 PWM
            if (rawLeft < -70) leftSpeed <= 70;
            else               leftSpeed <= -rawLeft; // Valoarea absoluta
        end else begin
            // MERS ÎNAINTE
            IN1A <= 1'b0; IN2A <= 1'b1; // Fa?a
            IN3B <= 1'b0; IN4B <= 1'b1; // Spate
            
            if (rawLeft > 255)  leftSpeed <= 255;
            else                leftSpeed <= rawLeft[7:0];
        end

        // --- RO?ILE DIN DREAPTA ---
        if (rawRight < 0) begin
            // MERS ÎNAPOI
            IN3A <= 1'b1; IN4A <= 1'b0; // Fa?a
            IN1B <= 1'b1; IN2B <= 1'b0; // Spate
            
            // LIMITATOR DE SPIN: Taiem for?a mar?arierului la maxim 70 PWM
            if (rawRight < -70) rightSpeed <= 70;
            else                rightSpeed <= -rawRight; // Valoarea absoluta
        end else begin
            // MERS ÎNAINTE
            IN3A <= 1'b0; IN4A <= 1'b1; // Fa?a
            IN1B <= 1'b0; IN2B <= 1'b1; // Spate
            
            if (rawRight > 255)  rightSpeed <= 255;
            else                 rightSpeed <= rawRight[7:0];
        end
        end
endmodule