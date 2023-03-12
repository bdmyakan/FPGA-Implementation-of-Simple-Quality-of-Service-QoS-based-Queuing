
module main (input clk,
				 input start,
				 input button0,
				 input button1,
				 output hsync,      
				 output vsync,				 
             output sync,       
				 output blank,
				 output clk25MHz,
				 output wrt_en,

				 output [7:0] red,
				 output [7:0] blue,
				 output [7:0] green,

				 output [3:0] read_from
);

wire [3:0] input_parallel;

wire [11:0] all_data_buffer3;
wire [11:0] all_data_buffer2;
wire [11:0] all_data_buffer1;
wire [11:0] all_data_buffer0;

reg wrt_en_prev;
wire clk_3second;

wire [3:0] read_enable;

reg [1:0] buffer_select_write;
reg [3:0] write_to_buf;
reg [3:0] prev_write_to_buf;

wire [2:0] data_count_buffer0;
wire [2:0] data_count_buffer1;
wire [2:0] data_count_buffer2;
wire [2:0] data_count_buffer3;

reg [6:0] number_of_received_package0;
reg [6:0] number_of_received_package1;
reg [6:0] number_of_received_package2;
reg [6:0] number_of_received_package3;

wire [6:0] number_of_transmitted_package0;
wire [6:0] number_of_transmitted_package1;
wire [6:0] number_of_transmitted_package2;
wire [6:0] number_of_transmitted_package3;

wire [6:0] number_of_drop0;
wire [6:0] number_of_drop1;
wire [6:0] number_of_drop2;
wire [6:0] number_of_drop3;

wire [1:0] out_from_buf0;
wire [1:0] out_from_buf1;
wire [1:0] out_from_buf2;
wire [1:0] out_from_buf3;

reg [3:0] final_output;

///////////////////////////////////////////////////////////////////////////////////////////////////


clock_divider_3sn clkdv (clk, clk_3second);


take_input takeinput0 (clk, button0, button1, start, input_parallel, wrt_en);	



buffer buf0 (clk, clk_3second, read_from[0], write_to_buf[0], input_parallel[1:0],
out_from_buf0, number_of_drop0, number_of_transmitted_package0, data_count_buffer0, all_data_buffer0, read_enable[0]);

buffer buf1 (clk, clk_3second, read_from[1], write_to_buf[1], input_parallel[1:0],
out_from_buf1, number_of_drop1, number_of_transmitted_package1, data_count_buffer1, all_data_buffer1, read_enable[1]);

buffer buf2 (clk, clk_3second, read_from[2], write_to_buf[2], input_parallel[1:0],
out_from_buf2, number_of_drop2, number_of_transmitted_package2, data_count_buffer2, all_data_buffer2, read_enable[2]);

buffer buf3 (clk, clk_3second, read_from[3], write_to_buf[3], input_parallel[1:0],
out_from_buf3, number_of_drop3, number_of_transmitted_package3, data_count_buffer3, all_data_buffer3, read_enable[3]);


quality_of_service b0 (clk, data_count_buffer0, data_count_buffer1, data_count_buffer2, data_count_buffer3, read_from);


display disp (clk, all_data_buffer3, all_data_buffer2, all_data_buffer1, all_data_buffer0,
hsync, vsync, red, blue, green, sync, blank, clk25MHz, 
data_count_buffer3, data_count_buffer2, data_count_buffer1, data_count_buffer0,
number_of_drop3, number_of_drop2, number_of_drop1, number_of_drop0,
number_of_transmitted_package3, number_of_transmitted_package2, number_of_transmitted_package1, number_of_transmitted_package0,
number_of_received_package3, number_of_received_package2, number_of_received_package1, number_of_received_package0, final_output);

///////////////////////////////////////////////////////////////////////////////////////////////////
initial begin

number_of_received_package0 = 0;
number_of_received_package1 = 0;
number_of_received_package2 = 0;
number_of_received_package3 = 0;

end
always @(posedge clk) begin

	buffer_select_write = input_parallel[3:2]; // which buffer to write
		
	if (wrt_en == 1) wrt_en_prev <= 1;
	else if (wrt_en == 0) wrt_en_prev <= 0;
	
	if (wrt_en == 0 && wrt_en_prev == 1)
	begin
		case(buffer_select_write)
			2'b00: begin
			write_to_buf[3:0] = 4'b0001;
			number_of_received_package0 <= number_of_received_package0 + 7'b0000001;
			end
			2'b01: begin
			write_to_buf[3:0] = 4'b0010;
			number_of_received_package1 <= number_of_received_package1 + 7'b0000001;
			end
			2'b10: begin
			write_to_buf[3:0] = 4'b0100;
			number_of_received_package2 <= number_of_received_package2 + 7'b0000001;
			end
			2'b11: begin
			write_to_buf[3:0] = 4'b1000;
			number_of_received_package3 <= number_of_received_package3 + 7'b0000001;
			end
			default: write_to_buf[3:0] = 4'b0000;
		endcase
	end
	else
	begin
		write_to_buf[3:0] = 4'b0000;
	end
  // read enable is given to the buffers if one of them is one then we read from specified buffer
	if (read_enable[0] || read_enable[1] || read_enable[2] || read_enable[3])
	begin
		case(read_from)
			4'b0001: begin
						final_output <= {2'b00, out_from_buf0};
						end
			4'b0010: begin
						final_output <= {2'b01, out_from_buf1};
						end
			4'b0100: begin
						final_output <= {2'b10, out_from_buf2};
						end
			4'b1000: begin
						final_output <= {2'b11, out_from_buf3};
						end
			4'b0000: final_output <= final_output;
		endcase
	end
	
end

endmodule
