module quality_of_service(clk, current_data_count0, current_data_count1, current_data_count2, current_data_count3, 
read_from);

input clk;
input [2:0] current_data_count0;
input [2:0] current_data_count1;
input [2:0] current_data_count2;
input [2:0] current_data_count3;

output reg [3:0] read_from;

initial begin

	read_from<=4'b0000;

end

always@(posedge clk) begin
if(current_data_count3>3'b000 || current_data_count2>3'b000 || current_data_count1>3'b000 || current_data_count0>3'b000) begin
		read_from<=4'b0000;
	
	if(current_data_count3>=3'b100) begin
			read_from <= 4'b1000; // enable read from buff 4
			end
		
	else if(current_data_count3<3'b100 && current_data_count2>=3'b101)begin
			read_from <= 4'b0100; // enable read from buff 3
			end
			
	else if(current_data_count3<3'b100 && current_data_count2<3'b101 && current_data_count1>=3'b101) begin
			read_from <= 4'b0010; // enable read from buff 2
			end
			
	else if(current_data_count3<3'b100 && current_data_count2<3'b101 && current_data_count1<3'b101 && current_data_count0>=3'b101) begin
			read_from <= 4'b0001; // enable read from buff 1
			end
	
	else if(current_data_count3<3'b100 && current_data_count2<3'b101 && current_data_count1<3'b101 && current_data_count0<3'b101)
		begin
		
			if(current_data_count0 != 3'b000) begin
				read_from <= 4'b0001; // enable read from buff 1
				end
				
			else if(current_data_count0==3'b000 && current_data_count1!=3'b000) begin
				read_from <= 4'b0010; // enable read from buff 2
				end
				
			else if(current_data_count0==3'b000 && current_data_count1 == 3'b000 && current_data_count2!=3'b000) begin
					read_from <= 4'b0100; // enable read from buff 3
					end
				
			else if(current_data_count0==3'b000 && current_data_count1 == 3'b000 && current_data_count2==3'b000 && current_data_count3!=3'b000) begin
						read_from <= 4'b1000; // enable read from buff 4
					end

			else read_from <= 4'b0000; // no enable reading from any of the buffers
		end
end
else; //There is no data to read
end
endmodule
