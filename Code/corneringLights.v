module corneringLights (Clk, Sensors, Led, finishLine);
    input Clk;       
    input [4:0] Sensors;
    output reg [2:0] Led;
    reg[2:0] blinkCount;
    reg blinkState;
    input finishLine;

	//led[0] -> right, led[1] -> left, led[2] -> front

	reg [24:0] Timer = 0;
	localparam BLINK_DELAY = 25000000;	//0.5 seconds at 50MHz

    always @(posedge Clk) begin
		
		if(finishLine == 1'b1) begin
		
			if(blinkCount < 3) begin
		
				if(Timer >= BLINK_DELAY) begin
					Timer <= 0;
					blinkState <= ~blinkState;
					
					if(blinkState == 1'b1) begin
					
						blinkCount <= blinkCount + 1;
			
					end
					
				end
				
				else begin
			
					Timer <= Timer + 1;
				
				end
				
				if(blinkState == 1'b1)	Led <= 3'b111;
				else					Led <= 3'b000;
				
			end
			
			else begin
				Led <= 3'b000;
			end
        
		end
		
		else begin
	
			case(Sensors)
			
				5'b00101:	Led <= 3'b110;
				5'b10100:	Led <= 3'b101;
				default:	Led <= 3'b100;
			
			endcase
			
			blinkCount <= 0;
			Timer <= 0;
			blinkState <= 1'b1;
			
		end
		   
	end
 
endmodule