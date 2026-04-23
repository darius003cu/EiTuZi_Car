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

        // GRUP STANGA (LED-urile 9, 8,7, 4, 3,2 )
        if (senzori[4] || senzori[3]) begin
            leduri[9:7] = 3'b111; 
            leduri[4:2] = 3'b111; 

        end
        
        // GRUP FATA (LED-urile 8, 7, 6, 3, 2, 1 )
        if (senzori[2]) begin
            leduri[8:6] = 3'b111;
            leduri[3:1] = 3'b111;
        end
        
        // GRUP DREAPTA (LED-urile 7, 6, 5, 2, 1, 0)
        if (senzori[1] || senzori[0]) begin
            leduri[7:5] = 3'b111;
            leduri[2:0] = 3'b111;
        end
    end

endmodule