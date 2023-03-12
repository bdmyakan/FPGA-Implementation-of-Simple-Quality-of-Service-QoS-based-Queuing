module buffer (input clk, //clock, read enable, write enable and reset values comes from main
					input clk3sn,
					input rd,
					input wr_en,
					input [1:0] buf_in, // data in if write enable
					output reg [1:0] buf_out, //data out if read enable 
					output reg [6:0] dropped_package,
					output reg [6:0] transmitted_package,
					output reg [2:0] data_count, // how many data inside
					output reg [11:0] all_data_in_buf,
					output reg out_en);

reg [1:0] buf_memory [0:5];
reg prevclk;
reg rd_en;
reg buf_empty;
reg buf_full;
reg error;

initial begin
	buf_memory [0] <= {2'b00};
	buf_memory [1] <= {2'b00};
	buf_memory [2] <= {2'b00};
	buf_memory [3] <= {2'b00};
	buf_memory [4] <= {2'b00};
	buf_memory [5] <= {2'b00};
	data_count <= 3'b0;
	error <= 1'b0;
	buf_empty <= 1'b1;
	buf_full <= 1'b0;
	dropped_package <= 7'b0;
	transmitted_package <= 7'b0;
	
end

always @(data_count) begin // checking the buffer is empty or full in every change of data_count
	buf_empty <= (data_count == 3'b000)? 1'b1:1'b0; //if data count is 0 then buffer empty is 1
	buf_full <= (data_count == 3'b110)? 1'b1:1'b0; //if data count is 6 then buffer full is 1
end

always @(posedge clk) begin
		// to find the positive edge of 3sn clock which will be used for reading the data from the buffer
		if (clk3sn == 1) prevclk <= 1;
		else if (clk3sn == 0) prevclk <= 0;
		
		if (prevclk == 0 && clk3sn == 1)	rd_en <= rd; // pos edge of 3sn clock rd_en is given as rd 
		else rd_en <= 1'b0;  // otherwise it is 0 
		
		if((~buf_full && wr_en) && (~buf_empty && rd_en)) //write read at the same time
			data_count <= data_count;
		else if( ~buf_full && wr_en ) // write
			data_count <= data_count + 3'b001;
		else if( ~buf_empty && rd_en ) //read
			data_count <= data_count - 3'b001;
		else
			data_count <= data_count;
		

		if(rd_en && ~buf_empty) begin
			buf_out <= buf_memory [0];	
			buf_memory [0] <= buf_memory [1];
			buf_memory [1] <= buf_memory [2];
			buf_memory [2] <= buf_memory [3];
			buf_memory [3] <= buf_memory [4];
			buf_memory [4] <= buf_memory [5];
			buf_memory [5] <= {2'b00};
			out_en <= 1'b1;
			transmitted_package <= transmitted_package + 7'b0000001;
			error = 1'b0;
		end
		else if(rd_en && buf_empty) begin
			error = 1'b1; // error is given because we are trying to read from empty buffer
			out_en <= 1'b0;
		end
		
		if (wr_en && ~buf_full) begin
			buf_memory [data_count] <= buf_in; //if buffer not full data is put into the last slot of the memory
			out_en <= 1'b0;
		end
		else if(wr_en && buf_full) begin // we need to drop package from full buffer to put the input
			buf_memory [0] <= buf_memory [1];
			buf_memory [1] <= buf_memory [2];
			buf_memory [2] <= buf_memory [3];
			buf_memory [3] <= buf_memory [4];
			buf_memory [4] <= buf_memory [5];
			buf_memory [5] <= {buf_in};
			out_en <= 1'b0;
			dropped_package <= dropped_package + 7'b0000001;
		end
		
		if((~buf_full && wr_en) && (~buf_empty && rd_en)) // write and read at the same time
		begin
			buf_out <= buf_memory [0];
			buf_memory [0] <= buf_memory [1];
			buf_memory [1] <= buf_memory [2];
			buf_memory [2] <= buf_memory [3];
			buf_memory [3] <= buf_memory [4];
			buf_memory [4] <= buf_memory [5];
			buf_memory [5] <= {2'b00} ;
			buf_memory [data_count-1] <= buf_in;
			out_en <= 1'b1;
			transmitted_package <= transmitted_package + 7'b0000001;
		end
		
		all_data_in_buf[11:10] <= buf_memory[5];
		all_data_in_buf[9:8] <= buf_memory[4];
		all_data_in_buf[7:6] <= buf_memory[3];
		all_data_in_buf[5:4] <= buf_memory[2];
		all_data_in_buf[3:2] <= buf_memory[1];
		all_data_in_buf[1:0] <= buf_memory[0];
		
end
endmodule		