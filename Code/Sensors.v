module Sensors(Signal, Led);

input[4:0] Signal;
output reg[9:0] Led;

	always @(*) begin
		case(Signal)
	
			5'b01110:	Led = 10'b0111001110;		//Mers inainte		
			5'b10000:	Led = 10'b1110011100;		//Stanga
			5'b00001:	Led = 10'b0011100111;		//Dreapta
			5'b00000:	Led = 10'b0000000000;		//Oprit
			default: 	Led = 10'b0000000000;		//Case default		
		endcase
	end

endmodule