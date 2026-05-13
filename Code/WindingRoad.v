module WindingRoad(Clk, Signal, ENA, ENB);
	
	localparam IDLE 					= 1'b000;
	localparam LEFT_TRIGGERED 			= 1'b001;
	localparam RIGHT_ACTIVE 			= 1'b010;
	localparam LEFT_REBALANCE 			= 1'b011;
	localparam RIGHT_TRIGGERED			= 1'b100;
	localparam LEFT_ACTIVE				= 1'b101;
	localparam RIGHT_REBALANCE			= 1'b110;
	localparam HIBERNATING				= 1'b111;
	
	input Clk;
	input[4:0] Signal;
	output[1:0] ENA, ENB;
	
	reg[7:0] leftSpeed, rightSpeed;
	reg[2:0] Status, nextStatus;
	
	Motors_Speed(ENA[0], Clk, leftSpeed);
	Motors_Speed(ENA[1], Clk, leftSpeed);
	Motors_Speed(ENB[0], Clk, rightSpeed);
	Motors_Speed(ENB[1], Clk, rightSpeed);

	initial begin

		Status = HIBERNATING;
	
	end
	
	always @(posedge Clk) begin
		
		Status <= nextStatus;
		
	end
	
	always @(*) begin

		nextStatus = Status;
		leftSpeed = 255;
		rightSpeed = 255;

		casez(Signal)
	
			5'b00000: begin
				nextStatus = HIBERNATING;
				leftSpeed = 0;
				rightSpeed = 0;
			end
	
			5'b00100: begin
				if(Status == LEFT_TRIGGERED) nextStatus = RIGHT_ACTIVE;
				else if(Status == RIGHT_TRIGGERED) nextStatus = LEFT_ACTIVE;
				
				if(Status == RIGHT_ACTIVE) begin
					leftSpeed = 165;
					rightSpeed = 255;
				end
				
				else if(Status == LEFT_ACTIVE) begin
					leftSpeed = 255;
					rightSpeed = 165;
				end
				
			end
				
			5'b10100: begin
				nextStatus = LEFT_TRIGGERED;
			end
			
			5'b00?10: begin
				nextStatus = LEFT_REBALANCE;
				leftSpeed = 255;
				rightSpeed = 102;
			end
			
			5'b00101: begin
				nextStatus = RIGHT_TRIGGERED;
			end
			
			5'b01?00: begin
				nextStatus = RIGHT_REBALANCE;
				leftSpeed = 102;
				rightSpeed = 255;
			end
			
			default: begin
				nextStatus = HIBERNATING;
			end	
		
		endcase

	end
	
	
endmodule
	