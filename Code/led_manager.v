module led_manager (
    input clk,              
    input [4:0] senzori,    
    output reg [9:0] leduri );

    reg [7:0] pwm_cnt;
    wire faza_scurta;
    
    always @(posedge clk) begin
        pwm_cnt <= pwm_cnt + 1'b1; 
    end
    assign faza_scurta = (pwm_cnt < 8'd15);

    always @(*) begin
        leduri = {10{faza_scurta}};

        // GRUP STANGA (LED-urile 9, 8, 7)
        if (senzori[4] || senzori[3]) begin
            leduri[9:7] = 3'b111; 
        end
        
        // GRUP FATA (LED-urile 6, 5, 4, 3)
        if (senzori[2]) begin
            leduri[6:3] = 4'b1111;
        end
        
        // GRUP DREAPTA (LED-urile 2, 1, 0)
        if (senzori[1] || senzori[0]) begin
            leduri[2:0] = 3'b111;
        end
    end

endmodule
);