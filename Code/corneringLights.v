module corneringLights (Clk, Sensors, Led, finishLine);
    input Clk, finishLine;
    input [4:0] Sensors;
    output reg [2:0] Led;

    reg [2:0] blinkCount;
    reg blinkState;
    reg [24:0] Timer;
    localparam BLINK_DELAY = 12500000; 

    always @(posedge Clk) begin
        if(finishLine) begin
            if(blinkCount < 4) begin
                if(Timer >= BLINK_DELAY) begin
                    Timer <= 0;
                    blinkState <= ~blinkState;
                    if(blinkState == 1'b1) blinkCount <= blinkCount + 1;
                end else Timer <= Timer + 1;
                Led <= (blinkState) ? 3'b111 : 3'b000;
            end else Led <= 3'b000;
        end else begin
            case(Sensors[3:1])
                3'b100:  Led <= 3'b101; 
                3'b001:  Led <= 3'b110; 
                default: Led <= 3'b100; 
            endcase
            blinkCount <= 0; Timer <= 0; blinkState <= 1'b1;
        end
    end
endmodule