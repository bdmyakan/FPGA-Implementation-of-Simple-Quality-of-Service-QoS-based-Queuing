`timescale 1ns / 1ps

module display(
	input clk,         
	input [11:0] buffer3,
	input [11:0] buffer2,
	input [11:0] buffer1,
	input [11:0] buffer0,
	output o_hsync,     
	output o_vsync,	    
	output [7:0] red_a,
	output [7:0] blue_a,
	output [7:0] green_a,
	output sync,
	output blank,
	output clk25MHz,
	input [2:0] number_of_data3,
	input [2:0] number_of_data2,
	input [2:0] number_of_data1,
	input [2:0] number_of_data0,
	input [6:0] drop_count3,
	input [6:0] drop_count2,
	input [6:0] drop_count1,
	input [6:0] drop_count0,
	input [6:0] transmit_count3,
	input [6:0] transmit_count2,
	input [6:0] transmit_count1,
	input [6:0] transmit_count0,
	input [6:0] total_count3,
	input [6:0] total_count2,
	input [6:0] total_count1,
	input [6:0] total_count0,
	input [3:0] data_out
);

	reg [9:0] counter_x = 0;  
	reg [9:0] counter_y = 0;  
	reg [7:0] red_b = 0;
	reg [7:0] blue_b = 0;
	reg [7:0] green_b = 0;
	
	reg [1:0] buffers [0:3][0:5]; 
	reg [3:0] count [0:3];
	
	
	reg [3:0] zero [0:3][0:5];
	reg [3:0] one [0:3][0:5];
	reg [3:0] two [0:3][0:5];
	reg [3:0] three [0:3][0:5];

	reg [3:0] a;
		
	reg reset = 0;  

	integer hdif = 35;
	integer xdif = 144;
	integer i;
	integer j;
	integer k;
	integer yoffset = 496;
	integer xoffset = 72;
	integer yoffset1 = 190;
	integer xoffset1 = 280;
	integer xoffset2 = 486;
	integer yoffset2 = 404;
	ip ip1(
		.areset(reset),
		.inclk0(clk),
		.c0(clk25MHz),
		.locked()
		);  
	
	always @(posedge clk25MHz)  
		begin 
			if (counter_x < 799)
				counter_x <= counter_x + 1;  
			else
				counter_x <= 0;              
		end   
		
	always @ (posedge clk25MHz)  
		begin 
			if (counter_x == 799)  
				begin
					if (counter_y < 525)  
						counter_y <= counter_y + 1;
					else
						counter_y <= 0;              
				end 
		end  

	assign o_hsync = (counter_x >= 0 && counter_x < 96) ? 1:0;                                                
	assign o_vsync = (counter_y >= 0 && counter_y < 2) ? 1:0;   
	
		always @ (posedge clk)
		begin
		
		a[3] = data_out[0];
		a[2] = data_out[1];
		a[1] = data_out[2];
		a[0] = data_out[3];
		
		count[0] = number_of_data0;
		count[1] = number_of_data1;
		count[2] = number_of_data2;
		count[3] = number_of_data3;
		
		buffers[0][0] = buffer0[1:0];
		buffers[0][1] = buffer0[3:2];
		buffers[0][2] = buffer0[5:4];
		buffers[0][3] = buffer0[7:6];
		buffers[0][4] = buffer0[9:8];
		buffers[0][5] = buffer0[11:10];
		
		buffers[1][0] = buffer1[1:0];
		buffers[1][1] = buffer1[3:2];
		buffers[1][2] = buffer1[5:4];
		buffers[1][3] = buffer1[7:6];
		buffers[1][4] = buffer1[9:8];
		buffers[1][5] = buffer1[11:10];
		
		buffers[2][0] = buffer2[1:0];
		buffers[2][1] = buffer2[3:2];
		buffers[2][2] = buffer2[5:4];
		buffers[2][3] = buffer2[7:6];
		buffers[2][4] = buffer2[9:8];
		buffers[2][5] = buffer2[11:10];
		
		buffers[3][0] = buffer3[1:0];
		buffers[3][1] = buffer3[3:2];
		buffers[3][2] = buffer3[5:4];
		buffers[3][3] = buffer3[7:6];
		buffers[3][4] = buffer3[9:8];
		buffers[3][5] = buffer3[11:10];

		for(i=0; i<6; i = i+1) begin 
			for(j=0; j<4; j = j+1) begin 
				zero[j][i] = (buffers[j][i]==2'b00 && count[j]>i) ? 4'b0001 : 4'b1111;
				one[j][i] = (buffers[j][i]==2'b01 && count[j]>i) ? 4'b0001 : 4'b1111;
				two[j][i] = (buffers[j][i]==2'b10 && count[j]>i) ? 4'b0001 : 4'b1111;
				three[j][i] = (buffers[j][i]==2'b11 && count[j]>i) ? 4'b0001 : 4'b1111;
			end
		end

			if ((counter_y < 27+hdif)|| (counter_y > 460+hdif))
			begin              
				red_b <= 8'hFF;   
				blue_b <= 8'hFF;
				green_b <= 8'hFF;
			end 
			else if ((counter_y >= 29+hdif && counter_y < 99+hdif)
			||(counter_y >= 101+hdif && counter_y < 171+hdif)
			||(counter_y >= 173+hdif && counter_y < 243+hdif)
			||(counter_y >= 245+hdif && counter_y < 315+hdif)
			||(counter_y >= 317+hdif && counter_y < 387+hdif)
			||(counter_y >= 389+hdif && counter_y < 459+hdif))
			begin 
					if ((counter_x < 4 + xdif) )
					begin 
						red_b <= 8'hFF;   
						blue_b <= 8'hFF;
						green_b <= 8'hFF;
					end 	
					else if (counter_x >= 8+ xdif && counter_x < 10+ xdif)
					begin 
						red_b <= 8'h00;    
						blue_b <= 8'h00;
						green_b <= 8'h00;
					end  
					else if (counter_x >= 10+ xdif && counter_x < 80+ xdif)
					begin 
						red_b <= 8'hFF;    
						blue_b <= 8'hFF;
						green_b <= 8'hFF;
					end  
					else if (counter_x >= 80+ xdif && counter_x < 82+ xdif)
					begin 
						red_b <= 8'h00;    
						blue_b <= 8'h00;
						green_b <= 8'h00;
					end  
					else if (counter_x >= 82+ xdif && counter_x < 90+ xdif)
					begin 
						red_b <= 8'hFF;    
						blue_b <= 8'hFF;
						green_b <= 8'hFF;
					end  
					else if (counter_x >= 90+ xdif && counter_x < 92+ xdif)
					begin 
						red_b <= 8'h00;    
						blue_b <= 8'h00;
						green_b <= 8'h00;
					end  
					else if (counter_x >= 92+ xdif && counter_x < 162+ xdif)
					begin 
						red_b <= 8'hFF;   
						blue_b <= 8'hFF;
						green_b <= 8'hFF;
					end  
					else if (counter_x >= 162+ xdif && counter_x < 164+ xdif)
					begin 
						red_b <= 8'h00;    
						blue_b <= 8'h00;
						green_b <= 8'h00;
					end  
					else if (counter_x >= 164+ xdif && counter_x < 172+ xdif)
					begin 
						red_b <= 8'hFF;   
						blue_b <= 8'hFF;
						green_b <= 8'hFF;
					end  
					else if (counter_x >= 172+ xdif && counter_x < 174+ xdif)
					begin 
						red_b <= 8'h00;   
						blue_b <= 8'h00;
						green_b <= 8'h00;
					end  
					else if (counter_x >= 174+ xdif && counter_x < 244+ xdif)
					begin 
						red_b <= 8'hFF;    
						blue_b <= 8'hFF;
						green_b <= 8'hFF;
					end  
					else if (counter_x >= 244+ xdif&& counter_x < 246+ xdif)
					begin 
						red_b <= 8'h00;    
						blue_b <= 8'h00;
						green_b <= 8'h00;
					end  
					else if (counter_x >= 246+ xdif && counter_x < 254+ xdif)
					begin 
						red_b <= 8'hFF;    
						blue_b <= 8'hFF;
						green_b <= 8'hFF;
					end
					else if (counter_x >= 254+ xdif && counter_x < 256+ xdif)
					begin 
						red_b <= 8'h00;    
						blue_b <= 8'h00;
						green_b <= 8'h00;
					end  
					else if (counter_x >= 256 + xdif&& counter_x < 326+ xdif)
					begin 
						red_b <= 8'hFF;    
						blue_b <= 8'hFF;
						green_b <= 8'hFF;
					end  
					else if (counter_x >= 326 + xdif&& counter_x < 328+ xdif)
					begin 
						red_b <= 8'h00;    
						blue_b <= 8'h00;
						green_b <= 8'h00;
					end  
					else if (counter_x >= 328 + xdif)
					begin 
						red_b <= 8'hFF;    
						blue_b <= 8'hFF;
						green_b <= 8'hFF;
					end 
				end	
			
			  if(counter_x >= 10+ xdif && counter_x < 80+ xdif)
					begin
					if (number_of_data0 == 3'b000);
					else if (number_of_data0 == 3'b001)
                begin
                     if ((counter_y >= 389+hdif && counter_y < 459+hdif)) begin
                        red_b <= 8'hAF;    
						blue_b <= 8'h00;
						green_b <= 8'h00;
                     end
                end
					else if (number_of_data0 == 3'b010)
                    begin
                     if ((counter_y >= 389+hdif && counter_y < 459+hdif)) begin
                        red_b <= 8'hAF;   
						blue_b <= 8'h00;
						green_b <= 8'h00;
                     end
                     if ((counter_y >= 317+hdif && counter_y < 387+hdif)) begin
                        red_b <= 8'hAF;   
						blue_b <= 8'h00;
						green_b <= 8'h00;
                     end
                    end

					else if (number_of_data0 == 3'b011)
                    begin
                     if ((counter_y >= 389+hdif && counter_y < 459+hdif)) begin
                        red_b <= 8'hAF;   
						blue_b <= 8'h00;
						green_b <= 8'h00;
                     end
                     if ((counter_y >= 317+hdif && counter_y < 387+hdif)) begin
                        red_b <= 8'hAF;   
						blue_b <= 8'h00;
						green_b <= 8'h00;
                     end
                     if ((counter_y >= 245+hdif && counter_y < 315+hdif)) begin
                        red_b <= 8'hAF;    
						blue_b <= 8'h00;
						green_b <= 8'h00;
                     end
                    end
					else if (number_of_data0 == 3'b100)
                    begin
                     if ((counter_y >= 389+hdif && counter_y < 459+hdif)) begin
                        red_b <= 8'hAF;  
						blue_b <= 8'h00;
						green_b <= 8'h00;
                     end
                     if ((counter_y >= 317+hdif && counter_y < 387+hdif)) begin
                        red_b <= 8'hAF;    
						blue_b <= 8'h00;
						green_b <= 8'h00;
                     end
                     if ((counter_y >= 245+hdif && counter_y < 315+hdif)) begin
                        red_b <= 8'hAF;   
						blue_b <= 8'h00;
						green_b <= 8'h00;
                     end
                     if ((counter_y >= 173+hdif && counter_y < 243+hdif)) begin
                        red_b <= 8'hAF;    
						blue_b <= 8'h00;
						green_b <= 8'h00;
                     end
                     end
					else if (number_of_data0 == 3'b101)
                    begin
                     if ((counter_y >= 389+hdif && counter_y < 459+hdif)) begin
                        red_b <= 8'hAF;  
						blue_b <= 8'h00;
						green_b <= 8'h00;
                     end
                     if ((counter_y >= 317+hdif && counter_y < 387+hdif)) begin
                        red_b <= 8'hAF;   
						blue_b <= 8'h00;
						green_b <= 8'h00;
                     end
                     if ((counter_y >= 245+hdif && counter_y < 315+hdif)) begin
                        red_b <= 8'hAF;    
						blue_b <= 8'h00;
						green_b <= 8'h00;
                     end
                     if ((counter_y >= 173+hdif && counter_y < 243+hdif)) begin
                        red_b <= 8'hAF;  
						blue_b <= 8'h00;
						green_b <= 8'h00;
                     end
                     if ((counter_y >= 101+hdif && counter_y < 171+hdif)) begin
                        red_b <= 8'hAF;    
						blue_b <= 8'h00;
						green_b <= 8'h00;
                     end
                     end
					else if (number_of_data0 == 3'b110)
                    begin
                     if ((counter_y >= 389+hdif && counter_y < 459+hdif)) begin
                        red_b <= 8'hAF;   
						blue_b <= 8'h00;
						green_b <= 8'h00;
                     end
                     if ((counter_y >= 317+hdif && counter_y < 387+hdif)) begin
                        red_b <= 8'hAF;    
						blue_b <= 8'h00;
						green_b <= 8'h00;
                     end
                     if ((counter_y >= 245+hdif && counter_y < 315+hdif)) begin
                        red_b <= 8'hAF;  
						blue_b <= 8'h00;
						green_b <= 8'h00;
                     end
                     if ((counter_y >= 173+hdif && counter_y < 243+hdif)) begin
                        red_b <= 8'hAF;  
						blue_b <= 8'h00;
						green_b <= 8'h00;
                     end
                     if ((counter_y >= 101+hdif && counter_y < 171+hdif)) begin
                        red_b <= 8'hAF;   
						blue_b <= 8'h00;
						green_b <= 8'h00;
                     end
                     if ((counter_y >= 29+hdif && counter_y < 99+hdif)) begin
                        red_b <= 8'hAF;   
						blue_b <= 8'h00;
						green_b <= 8'h00;
                     end
                    end
            else;
          end
		
			if(counter_x >= 92+ xdif && counter_x < 162+ xdif)
          begin
            if (number_of_data1 == 3'b000);
            else if (number_of_data1 == 3'b001)
                begin
                     if ((counter_y >= 389+hdif && counter_y < 459+hdif)) begin
								red_b <= 8'h00;
								blue_b <= 8'hFF;
								green_b <= 8'haf;
                     end
                end
            else if (number_of_data1 == 3'b010)
                    begin
                     if ((counter_y >= 389+hdif && counter_y < 459+hdif)) begin
								red_b <= 8'h00;   
								blue_b <= 8'hFF;
								green_b <= 8'haf;
                     end
                     if ((counter_y >= 317+hdif && counter_y < 387+hdif)) begin
								red_b <= 8'h00; 
								blue_b <= 8'hFF;
								green_b <= 8'haf;
                     end
                    end

            else if (number_of_data1 == 3'b011)
                    begin
                     if ((counter_y >= 389+hdif && counter_y < 459+hdif)) begin
								red_b <= 8'h00;   
								blue_b <= 8'hFF;
								green_b <= 8'haf;
                     end
                     if ((counter_y >= 317+hdif && counter_y < 387+hdif)) begin
								red_b <= 8'h00;   
								blue_b <= 8'hFF;
								green_b <= 8'haf;
                     end
                     if ((counter_y >= 245+hdif && counter_y < 315+hdif)) begin
								red_b <= 8'h00;   
								blue_b <= 8'hFF;
								green_b <= 8'haf;
                     end
                    end
            else if (number_of_data1 == 3'b100)
                    begin
                     if ((counter_y >= 389+hdif && counter_y < 459+hdif)) begin
								red_b <= 8'h00;    
								blue_b <= 8'hFF;
								green_b <= 8'haf;
                     end
                     if ((counter_y >= 317+hdif && counter_y < 387+hdif)) begin
								red_b <= 8'h00;   
								blue_b <= 8'hFF;
								green_b <= 8'haf;
                     end
                     if ((counter_y >= 245+hdif && counter_y < 315+hdif)) begin
								red_b <= 8'h00;    
								blue_b <= 8'hFF;
								green_b <= 8'haf;
                     end
                     if ((counter_y >= 173+hdif && counter_y < 243+hdif)) begin
								red_b <= 8'h00;    
								blue_b <= 8'hFF;
								green_b <= 8'haf;
                     end
                     end
            else if (number_of_data1 == 3'b101)
                    begin
                     if ((counter_y >= 389+hdif && counter_y < 459+hdif)) begin
								red_b <= 8'h00;    
								blue_b <= 8'hFF;
								green_b <= 8'haf;
                     end
                     if ((counter_y >= 317+hdif && counter_y < 387+hdif)) begin
								red_b <= 8'h00;   
								blue_b <= 8'hFF;
								green_b <= 8'haf;
                     end
                     if ((counter_y >= 245+hdif && counter_y < 315+hdif)) begin
								red_b <= 8'h00;    
								blue_b <= 8'hFF;
								green_b <= 8'haf;
                     end
                     if ((counter_y >= 173+hdif && counter_y < 243+hdif)) begin
								red_b <= 8'h00;    
								blue_b <= 8'hFF;
								green_b <= 8'haf;
                     end
                     if ((counter_y >= 101+hdif && counter_y < 171+hdif)) begin
								red_b <= 8'h00;    
								blue_b <= 8'hFF;
								green_b <= 8'haf;
                     end
                     end
            else if (number_of_data1 == 3'b110)
                    begin
                     if ((counter_y >= 389+hdif && counter_y < 459+hdif)) begin
								red_b <= 8'h00;    
								blue_b <= 8'hFF;
								green_b <= 8'haf;
                     end
                     if ((counter_y >= 317+hdif && counter_y < 387+hdif)) begin
								red_b <= 8'h00;    
								blue_b <= 8'hFF;
								green_b <= 8'haf;
                     end
                     if ((counter_y >= 245+hdif && counter_y < 315+hdif)) begin
								red_b <= 8'h00;    
								blue_b <= 8'hFF;
								green_b <= 8'haf;
                     end
                     if ((counter_y >= 173+hdif && counter_y < 243+hdif)) begin
								red_b <= 8'h00;    
								blue_b <= 8'hFF;
								green_b <= 8'haf;
                     end
                     if ((counter_y >= 101+hdif && counter_y < 171+hdif)) begin
								red_b <= 8'h00;    
								blue_b <= 8'hFF;
								green_b <= 8'haf;
                     end
                     if ((counter_y >= 29+hdif && counter_y < 99+hdif)) begin
								red_b <= 8'h00;    
								blue_b <= 8'hFF;
								green_b <= 8'haf;
                     end
                    end
            else;
          end
		
			if(counter_x >= 174+ xdif && counter_x < 244+xdif)
          begin
            if (number_of_data2 == 3'b000);
            else if (number_of_data2 == 3'b001)
                begin
                     if ((counter_y >= 389+hdif && counter_y < 459+hdif)) begin
                        red_b <= 8'hDF;     
                        blue_b <= 8'h00;
                        green_b <= 8'hDF;
                     end
                end
            else if (number_of_data2 == 3'b010)
                    begin
                     if ((counter_y >= 389+hdif && counter_y < 459+hdif)) begin
                        red_b <= 8'hDF;     
                        blue_b <= 8'h00;
                        green_b <= 8'hDF;
                     end
                     if ((counter_y >= 317+hdif && counter_y < 387+hdif)) begin
                        red_b <= 8'hDF;     
                        blue_b <= 8'h00;
                        green_b <= 8'hDF;
                     end
                    end

            else if (number_of_data2 == 3'b011)
                    begin
                     if ((counter_y >= 389+hdif && counter_y < 459+hdif)) begin
                        red_b <= 8'hDF;     
                        blue_b <= 8'h00;
                        green_b <= 8'hDF;
                     end
                     if ((counter_y >= 317+hdif && counter_y < 387+hdif)) begin
                        red_b <= 8'hDF;     
                        blue_b <= 8'h00;
                        green_b <= 8'hDF;
                     end
                     if ((counter_y >= 245+hdif && counter_y < 315+hdif)) begin
                        red_b <= 8'hDF;     
                        blue_b <= 8'h00;
                        green_b <= 8'hDF;
                     end
                    end
            else if (number_of_data2 == 3'b100)
                    begin
                     if ((counter_y >= 389+hdif && counter_y < 459+hdif)) begin
                        red_b <= 8'hDF;     
                        blue_b <= 8'h00;
                        green_b <= 8'hDF;
                     end
                     if ((counter_y >= 317+hdif && counter_y < 387+hdif)) begin
                        red_b <= 8'hDF;     
                        blue_b <= 8'h00;
                        green_b <= 8'hDF;
                     end
                     if ((counter_y >= 245+hdif && counter_y < 315+hdif)) begin
                        red_b <= 8'hDF;     
                        blue_b <= 8'h00;
                        green_b <= 8'hDF;
                     end
                     if ((counter_y >= 173+hdif && counter_y < 243+hdif)) begin
                        red_b <= 8'hDF;     
                        blue_b <= 8'h00;
                        green_b <= 8'hDF;
                     end
                     end
            else if (number_of_data2 == 3'b101)
                    begin
                     if ((counter_y >= 389+hdif && counter_y < 459+hdif)) begin
                        red_b <= 8'hDF;     
                        blue_b <= 8'h00;
                        green_b <= 8'hDF;
                     end
                     if ((counter_y >= 317+hdif && counter_y < 387+hdif)) begin
                        red_b <= 8'hDF;     
                        blue_b <= 8'h00;
                        green_b <= 8'hDF;
                     end
                     if ((counter_y >= 245+hdif && counter_y < 315+hdif)) begin
                        red_b <= 8'hDF;     
                        blue_b <= 8'h00;
                        green_b <= 8'hDF;
                     end
                     if ((counter_y >= 173+hdif && counter_y < 243+hdif)) begin
                        red_b <= 8'hDF;     
                        blue_b <= 8'h00;
                        green_b <= 8'hDF;
                     end
                     if ((counter_y >= 101+hdif && counter_y < 171+hdif)) begin
                        red_b <= 8'hDF;     
                        blue_b <= 8'h00;
                        green_b <= 8'hDF;
                     end
                     end
            else if (number_of_data2 == 3'b110)
                    begin
                     if ((counter_y >= 389+hdif && counter_y < 459+hdif)) begin
                        red_b <= 8'hDF;     
                        blue_b <= 8'h00;
                        green_b <= 8'hDF;
                     end
                     if ((counter_y >= 317+hdif && counter_y < 387+hdif)) begin
                        red_b <= 8'hDF;     
                        blue_b <= 8'h00;
                        green_b <= 8'hDF;
                     end
                     if ((counter_y >= 245+hdif && counter_y < 315+hdif)) begin
                        red_b <= 8'hDF;     
                        blue_b <= 8'h00;
                        green_b <= 8'hDF;
                     end
                     if ((counter_y >= 173+hdif && counter_y < 243+hdif)) begin
                        red_b <= 8'hDF;     
                        blue_b <= 8'h00;
                        green_b <= 8'hDF;
                     end
                     if ((counter_y >= 101+hdif && counter_y < 171+hdif)) begin
                        red_b <= 8'hDF;     
                        blue_b <= 8'h00;
                        green_b <= 8'hDF;
                     end
                     if ((counter_y >= 29+hdif && counter_y < 99+hdif)) begin
                        red_b <= 8'hDF;     
                        blue_b <= 8'h00;
                        green_b <= 8'hDF;
                     end
                    end
            else;
          end
			
			if(counter_x >= 256+ xdif && counter_x < 326+xdif)
          begin
            if (number_of_data3 == 3'b000);
            else if (number_of_data3 == 3'b001)
                begin
                     if ((counter_y >= 389+hdif && counter_y < 459+hdif)) begin
                        red_b <= 8'h00;     
                        blue_b <= 8'h00;
                        green_b <= 8'hAF;
                     end
                end
            else if (number_of_data3 == 3'b010)
                    begin
                     if ((counter_y >= 389+hdif && counter_y < 459+hdif)) begin
                        red_b <= 8'h00;     
                        blue_b <= 8'h00;
                        green_b <= 8'hAF;
                     end
                     if ((counter_y >= 317+hdif && counter_y < 387+hdif)) begin
                        red_b <= 8'h00;     
                        blue_b <= 8'h00;
                        green_b <= 8'hAF;
                     end
                    end

            else if (number_of_data3 == 3'b011)
                    begin
                     if ((counter_y >= 389+hdif && counter_y < 459+hdif)) begin
                        red_b <= 8'h00;     
                        blue_b <= 8'h00;
                        green_b <= 8'hAF;
                     end
                     if ((counter_y >= 317+hdif && counter_y < 387+hdif)) begin
                        red_b <= 8'h00;     
                        blue_b <= 8'h00;
                        green_b <= 8'hAF;
                     end
                     if ((counter_y >= 245+hdif && counter_y < 315+hdif)) begin
                        red_b <= 8'h00;     
                        blue_b <= 8'h00;
                        green_b <= 8'hAF;
                     end
                    end
            else if (number_of_data3 == 3'b100)
                    begin
                     if ((counter_y >= 389+hdif && counter_y < 459+hdif)) begin
                        red_b <= 8'h00;     
                        blue_b <= 8'h00;
                        green_b <= 8'hAF;
                     end
                     if ((counter_y >= 317+hdif && counter_y < 387+hdif)) begin
                        red_b <= 8'h00;     
                        blue_b <= 8'h00;
                        green_b <= 8'hAF;
                     end
                     if ((counter_y >= 245+hdif && counter_y < 315+hdif)) begin
                        red_b <= 8'h00;     
                        blue_b <= 8'h00;
                        green_b <= 8'hAF;
                     end
                     if ((counter_y >= 173+hdif && counter_y < 243+hdif)) begin
                        red_b <= 8'h00;     
                        blue_b <= 8'h00;
                        green_b <= 8'hAF;
                     end
                     end
            else if (number_of_data3 == 3'b101)
                    begin
                     if ((counter_y >= 389+hdif && counter_y < 459+hdif)) begin
                        red_b <= 8'h00;     
                        blue_b <= 8'h00;
                        green_b <= 8'hAF;
                     end
                     if ((counter_y >= 317+hdif && counter_y < 387+hdif)) begin
                        red_b <= 8'h00;     
                        blue_b <= 8'h00;
                        green_b <= 8'hAF;
                     end
                     if ((counter_y >= 245+hdif && counter_y < 315+hdif)) begin
                        red_b <= 8'h00;     
                        blue_b <= 8'h00;
                        green_b <= 8'hAF;
                     end
                     if ((counter_y >= 173+hdif && counter_y < 243+hdif)) begin
                        red_b <= 8'h00;     
                        blue_b <= 8'h00;
                        green_b <= 8'hAF;
                     end
                     if ((counter_y >= 101+hdif && counter_y < 171+hdif)) begin
                        red_b <= 8'h00;     
                        blue_b <= 8'h00;
                        green_b <= 8'hAF;
                     end
                     end
            else if (number_of_data3 == 3'b110)
                    begin
                     if ((counter_y >= 389+hdif && counter_y < 459+hdif)) begin
                        red_b <= 8'h00;     
                        blue_b <= 8'h00;
                        green_b <= 8'hAF;
                     end
                     if ((counter_y >= 317+hdif && counter_y < 387+hdif)) begin
                        red_b <= 8'h00;     
                        blue_b <= 8'h00;
                        green_b <= 8'hAF;
                     end
                     if ((counter_y >= 245+hdif && counter_y < 315+hdif)) begin
                        red_b <= 8'h00;     
                        blue_b <= 8'h00;
                        green_b <= 8'hAF;
                     end
                     if ((counter_y >= 173+hdif && counter_y < 243+hdif)) begin
                        red_b <= 8'h00;     
                        blue_b <= 8'h00;
                        green_b <= 8'hAF;
                     end
                     if ((counter_y >= 101+hdif && counter_y < 171+hdif)) begin
                        red_b <= 8'h00;     
                        blue_b <= 8'h00;
                        green_b <= 8'hAF;
                     end
                     if ((counter_y >= 29+hdif && counter_y < 99+hdif)) begin
                        red_b <= 8'h00;     
                        blue_b <= 8'h00;
                        green_b <= 8'hAF;
                     end
                    end
            else;
          end


			else if ((counter_y >= 27+hdif && counter_y < 29+hdif) 
			||(counter_y >= 99+hdif && counter_y < 101+hdif)
			||(counter_y >= 171+hdif && counter_y < 173+hdif)
			||(counter_y >= 243+hdif && counter_y < 245+hdif)
			||(counter_y >= 315+hdif && counter_y < 317+hdif)
			||(counter_y >= 387+hdif && counter_y < 389+hdif)
			||(counter_y >= 459+hdif && counter_y < 461+hdif))
			begin 
					if (counter_x < 8 + xdif)
					begin 
						red_b <= 8'hFF;    
						blue_b <= 8'hFF;
						green_b <= 8'hFF;
					end 
					else if (counter_x >= 8+ xdif && counter_x < 82+ xdif)
					begin 
						red_b <= 8'h00;    
						blue_b <= 8'h00;
						green_b <= 8'h00;
					end  
					else if (counter_x >= 82+ xdif && counter_x < 90+ xdif)
					begin 
						red_b <= 8'hFF;    
						blue_b <= 8'hFF;
						green_b <= 8'hFF;
					end  
					else if (counter_x >= 90+ xdif && counter_x < 164+ xdif)
					begin 
						red_b <= 8'h00;    
						blue_b <= 8'h00;
						green_b <= 8'h00;
					end  
					else if (counter_x >= 164+ xdif && counter_x < 172+ xdif)
					begin 
						red_b <= 8'hFF;    
						blue_b <= 8'hFF;
						green_b <= 8'hFF;
					end  
					else if (counter_x >= 172 + xdif && counter_x < 246+ xdif)
					begin 
						red_b <= 8'h00;    
						blue_b <= 8'h00;
						green_b <= 8'h00;
					end  
					else if (counter_x >= 246+ xdif && counter_x < 254+ xdif)
					begin 
						red_b <= 8'hFF;    
						blue_b <= 8'hFF;
						green_b <= 8'hFF;
					end  
					else if (counter_x >= 254+ xdif && counter_x < 328+ xdif)
					begin 
						red_b <= 8'h00;    
						blue_b <= 8'h00;
						green_b <= 8'h00;
					end  
					else if (counter_x >= 328+ xdif)
					begin 
						red_b <= 8'hFF;    
						blue_b <= 8'hFF;
						green_b <= 8'hFF;
					end 

			end			
			
			
					
			for (i=0; i<6; i = i+1)begin 
			for (j=0; j<4; j = j+1) begin
				if (counter_y >= 10+yoffset-(zero[j][i]*(i+1)*72) && counter_y < 12+yoffset-(zero[j][i]*(i+1)*72)) 
				begin
					if (counter_x >= 20+xoffset+(zero[j][i]*(j+1)*82) && counter_x < 50+xoffset+(zero[j][i]*(j+1)*82)) 
					begin
						red_b <= 8'h00;    
						blue_b <= 8'h00;
						green_b <= 8'h00;
					end
				end

			

				else if (counter_y >= 12+yoffset-(zero[j][i]*(i+1)*72) && counter_y < 34+yoffset-(zero[j][i]*(i+1)*72)) 
				begin
					if (counter_x >= 20+xoffset+(zero[j][i]*(j+1)*82) && counter_x < 22+xoffset+(zero[j][i]*(j+1)*82)) 
					begin
						red_b <= 8'h00;    
						blue_b <= 8'h00;
						green_b <= 8'h00;
					end
					else if (counter_x >= 48+xoffset+(zero[j][i]*(j+1)*82) && counter_x < 50+xoffset+(zero[j][i]*(j+1)*82)) 
					begin
						red_b <= 8'h00;   
						blue_b <= 8'h00;
						green_b <= 8'h00;		
					end
				end


				else if (counter_y >= 34+yoffset-(zero[j][i]*(i+1)*72) && counter_y < 36+yoffset-(zero[j][i]*(i+1)*72)) 
				begin
					if (counter_x >= 20+xoffset+(zero[j][i]*(j+1)*82) && counter_x < 22+xoffset+(zero[j][i]*(j+1)*82)) 
					begin
						red_b <= 8'h00;    
						blue_b <= 8'h00;
						green_b <= 8'h00;	
					end

					else if (counter_x >= 48+xoffset+(zero[j][i]*(j+1)*82) && counter_x < 50+xoffset+(zero[j][i]*(j+1)*82)) 
					begin
						red_b <= 8'h00;   
						blue_b <= 8'h00;
						green_b <= 8'h00;	
					end
				end

	

				else if (counter_y >= 36+yoffset-(zero[j][i]*(i+1)*72) && counter_y < 58+yoffset-(zero[j][i]*(i+1)*72)) 
				begin
					if (counter_x >= 20+xoffset+(zero[j][i]*(j+1)*82) && counter_x < 22+xoffset+(zero[j][i]*(j+1)*82)) 
					begin
						red_b <= 8'h00;  
						blue_b <= 8'h00;
						green_b <= 8'h00;
					end
					else if (counter_x >= 48+xoffset+(zero[j][i]*(j+1)*82) && counter_x < 50+xoffset+(zero[j][i]*(j+1)*82)) 
					begin
						red_b <= 8'h00;   
						blue_b <= 8'h00;
						green_b <= 8'h00;	
					end
				end

				else if (counter_y >= 58+yoffset-(zero[j][i]*(i+1)*72) && counter_y < 60+yoffset-(zero[j][i]*(i+1)*72)) 
				begin
					if (counter_x >= 20+xoffset+(zero[j][i]*(j+1)*82) && counter_x < 50+xoffset+(zero[j][i]*(j+1)*82))
					begin
						red_b <= 8'h00;    
						blue_b <= 8'h00;
						green_b <= 8'h00;
					end
				end
			end 
			end 
			
			for (i=0; i<6; i = i+1)begin 
			for (j=0; j<4; j = j+1) begin
				if (counter_y >= 12+yoffset-(one[j][i]*(i+1)*72) && counter_y < 34+yoffset-(one[j][i]*(i+1)*72)) 
				begin
					if (counter_x >= 48+xoffset+(one[j][i]*(j+1)*82) && counter_x < 50+xoffset+(one[j][i]*(j+1)*82)) 
					begin
						red_b <= 8'h00;    
						blue_b <= 8'h00;
						green_b <= 8'h00;		
					end
				end

				

				else if (counter_y >= 34+yoffset-(one[j][i]*(i+1)*72) && counter_y < 36+yoffset-(one[j][i]*(i+1)*72))
				begin
					if (counter_x >= 48+xoffset+(one[j][i]*(j+1)*82) && counter_x < 50+xoffset+(one[j][i]*(j+1)*82)) 
					begin
						red_b <= 8'h00;   
						blue_b <= 8'h00;
						green_b <= 8'h00;		
					end
				end

				

				else if (counter_y >= 36+yoffset-(one[j][i]*(i+1)*72) && counter_y < 58+yoffset-(one[j][i]*(i+1)*72)) 
				begin
					if (counter_x >= 48+xoffset+(one[j][i]*(j+1)*82) && counter_x < 50+xoffset+(one[j][i]*(j+1)*82)) 
					begin
						red_b <= 8'h00;   
						blue_b <= 8'h00;
						green_b <= 8'h00;		
					end
				end
			
			end 
			end 
			
			for (i=0; i<6; i = i+1)begin 
			for (j=0; j<4; j = j+1) begin
				if (counter_y >= 10+yoffset-(two[j][i]*(i+1)*72) && counter_y < 12+yoffset-(two[j][i]*(i+1)*72)) 
				begin
					if (counter_x >= 20+xoffset+(two[j][i]*(j+1)*82) && counter_x < 50+xoffset+(two[j][i]*(j+1)*82))
					begin
						red_b <= 8'h00;    
						blue_b <= 8'h00;
						green_b <= 8'h00;
					end
				end

				

				else if (counter_y >= 12+yoffset-(two[j][i]*(i+1)*72) && counter_y < 34+yoffset-(two[j][i]*(i+1)*72)) 
				begin
					if (counter_x >= 48+xoffset+(two[j][i]*(j+1)*82) && counter_x < 50+xoffset+(two[j][i]*(j+1)*82)) 
					begin
						red_b <= 8'h00;   
						blue_b <= 8'h00;
						green_b <= 8'h00;		
					end
				end

				

				else if (counter_y >= 34+yoffset-(two[j][i]*(i+1)*72) && counter_y < 36+yoffset-(two[j][i]*(i+1)*72)) 
				begin
					if (counter_x >= 20+xoffset+(two[j][i]*(j+1)*82) && counter_x < 50+xoffset+(two[j][i]*(j+1)*82))
					begin
						red_b <= 8'h00;    
						blue_b <= 8'h00;
						green_b <= 8'h00;
					end
				end

				

				else if (counter_y >= 36+yoffset-(two[j][i]*(i+1)*72) && counter_y < 58+yoffset-(two[j][i]*(i+1)*72))
				begin
					if (counter_x >= 20+xoffset+(two[j][i]*(j+1)*82) && counter_x < 22+xoffset+(two[j][i]*(j+1)*82))
					begin
						red_b <= 8'h00;    
						blue_b <= 8'h00;
						green_b <= 8'h00;
					end
				end

				

				else if (counter_y >= 58+yoffset-(two[j][i]*(i+1)*72) && counter_y < 60+yoffset-(two[j][i]*(i+1)*72)) 
				begin
					if (counter_x >= 20+xoffset+(two[j][i]*(j+1)*82) && counter_x < 50+xoffset+(two[j][i]*(j+1)*82)) 
					begin
						red_b <= 8'h00;    
						blue_b <= 8'h00;
						green_b <= 8'h00;
					end
				end
				
			end 
			end 
			
			for (i=0; i<6; i = i+1)begin 
		
			for (j=0; j<4; j = j+1) begin
				if (counter_y >= 10+yoffset-(three[j][i]*(i+1)*72) && counter_y < 12+yoffset-(three[j][i]*(i+1)*72)) 
				begin
					if (counter_x >= 20+xoffset+(three[j][i]*(j+1)*82) && counter_x < 50+xoffset+(three[j][i]*(j+1)*82)) 
					begin
						red_b <= 8'h00;      
						blue_b <= 8'h00;
						green_b <= 8'h00;
					end
				end

				

				else if (counter_y >= 12+yoffset-(three[j][i]*(i+1)*72) && counter_y < 34+yoffset-(three[j][i]*(i+1)*72)) 
				begin
					if (counter_x >= 48+xoffset+(three[j][i]*(j+1)*82) && counter_x < 50+xoffset+(three[j][i]*(j+1)*82)) 
					begin
						red_b <= 8'h00;
						blue_b <= 8'h00;
						green_b <= 8'h00;		
					end
				end

				

				else if (counter_y >= 34+yoffset-(three[j][i]*(i+1)*72) && counter_y < 36+yoffset-(three[j][i]*(i+1)*72)) 
				begin
					if (counter_x >= 20+xoffset+(three[j][i]*(j+1)*82) && counter_x < 50+xoffset+(three[j][i]*(j+1)*82)) 
					begin
						red_b <= 8'h00;
						blue_b <= 8'h00;
						green_b <= 8'h00;
					end
				end

				

				else if (counter_y >= 36+yoffset-(three[j][i]*(i+1)*72) && counter_y < 58+yoffset-(three[j][i]*(i+1)*72))
				begin
					if (counter_x >= 48+xoffset+(three[j][i]*(j+1)*82) && counter_x < 50+xoffset+(three[j][i]*(j+1)*82)) 
					begin
						red_b <= 8'h00;    
						blue_b <= 8'h00;
						green_b <= 8'h00;		
					end
				end

				

				else if (counter_y >= 58+yoffset-(three[j][i]*(i+1)*72) && counter_y < 60+yoffset-(three[j][i]*(i+1)*72)) 
				begin
					if (counter_x >= 20+xoffset+(three[j][i]*(j+1)*82) && counter_x < 50+xoffset+(three[j][i]*(j+1)*82)) 
					begin
						red_b <= 8'h00;    
						blue_b <= 8'h00;
						green_b <= 8'h00;
					end
				end
			end 
			end 
			

				
				if (counter_y >= 55+hdif && counter_y < 58+hdif)	begin
					if (counter_x >= 440+ xdif && counter_x < 470 + xdif)
						begin 
							red_b <= 8'h00;    
							blue_b <= 8'h00;
							green_b <= 8'h00;
						end  
						
				end
				else if (counter_y >= 58+hdif && counter_y < 68+hdif)	begin
					if (counter_x >= 454+ xdif && counter_x < 457 + xdif)
						begin 
							red_b <= 8'h00;      
							blue_b <= 8'h00;
							green_b <= 8'h00;
						end  
						
				end
				else if (counter_y >= 68+hdif && counter_y < 85+hdif)	begin
					if (counter_x >= 454+ xdif && counter_x < 457 + xdif)
						begin 
							red_b <= 8'h00;      
							blue_b <= 8'h00;
							green_b <= 8'h00;
						end  
						
				end	
				
				else if (counter_y >= 152+hdif && counter_y < 155+hdif)	begin
					if (counter_x >= 437+ xdif && counter_x < 460 + xdif)
						begin 
							red_b <= 8'h00;      
							blue_b <= 8'h00;
							green_b <= 8'h00;
						end  
						end
				else if (counter_y >= 152+hdif && counter_y < 166+hdif)	begin
					if (counter_x >= 457+ xdif && counter_x < 460 + xdif)
						begin 
							red_b <= 8'h00;      
							blue_b <= 8'h00;
							green_b <= 8'h00;
						end 
					else if (counter_x >= 437+ xdif && counter_x < 440 + xdif)
						begin 
							red_b <= 8'h00;      
							blue_b <= 8'h00;
							green_b <= 8'h00;
						end  
						end	

				else if (counter_y >= 152+hdif && counter_y < 180+hdif)	begin
					if (counter_x >= 437+ xdif && counter_x < 440 + xdif)
						begin 
							red_b <= 8'h00;      
							blue_b <= 8'h00;
							green_b <= 8'h00;
						end    
						
				end
				
				else if (counter_y >= 240+hdif && counter_y < 242+hdif)	begin
					if (counter_x >= 434+ xdif && counter_x < 458 + xdif)
						begin 
							red_b <= 8'h00;      
							blue_b <= 8'h00;
							green_b <= 8'h00;
						end  
						
				end				
				
				else if (counter_y >= 242+hdif && counter_y < 265+hdif)	begin
					if (counter_x >= 438+ xdif && counter_x < 441 + xdif)
						begin 
							red_b <= 8'h00;      
							blue_b <= 8'h00;
							green_b <= 8'h00;
						end  
					else if (counter_x >= 455+ xdif && counter_x < 458 + xdif)
						begin 
							red_b <= 8'h00;      
							blue_b <= 8'h00;
							green_b <= 8'h00;
						end  
						
				end
				else if (counter_y >= 265+hdif && counter_y < 267+hdif)	begin
					if (counter_x >= 434+ xdif && counter_x < 458 + xdif)
						begin 
							red_b <= 8'h00;      
							blue_b <= 8'h00;
							green_b <= 8'h00;
						end  
						
				end
				
				if ((counter_y >= 100+hdif && counter_y < 102+hdif)
				||(counter_y >= 190+hdif && counter_y < 192+hdif)
				||(counter_y >= 280+hdif && counter_y < 282+hdif))
				begin
					if (counter_x >= 340+ xdif && counter_x < 390 + xdif)
						begin 
							red_b <= 8'h00;      
							blue_b <= 8'h00;
							green_b <= 8'h00;
						end  
					else if (counter_x >= 400+ xdif && counter_x < 450 + xdif)
						begin 
							red_b <= 8'h00;      
							blue_b <= 8'h00;
							green_b <= 8'h00;
						end  
					else if (counter_x >= 460+ xdif && counter_x < 510 + xdif)
						begin 
							red_b <= 8'h00;      
							blue_b <= 8'h00;
							green_b <= 8'h00;
						end  
					else if (counter_x >= 520+ xdif && counter_x < 570 + xdif)
						begin 
							red_b <= 8'h00;      
							blue_b <= 8'h00;
							green_b <= 8'h00;
						end  
					end	
				else if ((counter_y >= 102+hdif && counter_y < 142+hdif)
				||(counter_y >= 192+hdif && counter_y < 232+hdif)
				||(counter_y >= 282+hdif && counter_y <323 +hdif))
				begin
					if (counter_x >= 340+ xdif && counter_x < 342 + xdif)
						begin 
							red_b <= 8'h00;      
							blue_b <= 8'h00;
							green_b <= 8'h00;
						end  
					else if (counter_x >= 388+ xdif && counter_x < 390 + xdif)
						begin 
							red_b <= 8'h00;      
							blue_b <= 8'h00;
							green_b <= 8'h00;
						end  
					else if (counter_x >= 400+ xdif && counter_x < 402 + xdif)
						begin 
							red_b <= 8'h00;      
							blue_b <= 8'h00;
							green_b <= 8'h00;
						end  
					else if (counter_x >= 448+ xdif && counter_x < 450 + xdif)
						begin 
							red_b <= 8'h00;      
							blue_b <= 8'h00;
							green_b <= 8'h00;
						end  	
					else if (counter_x >= 460+ xdif && counter_x < 462 + xdif)
						begin 
							red_b <= 8'h00;      
							blue_b <= 8'h00;
							green_b <= 8'h00;
						end  
					else if (counter_x >= 508+ xdif && counter_x < 510 + xdif)
						begin 
							red_b <= 8'h00;      
							blue_b <= 8'h00;
							green_b <= 8'h00;
						end  
					else if (counter_x >= 520+ xdif && counter_x < 522 + xdif)
						begin 
							red_b <= 8'h00;      
							blue_b <= 8'h00;
							green_b <= 8'h00;
						end  
					else if (counter_x >= 568+ xdif && counter_x < 570 + xdif)
						begin 
							red_b <= 8'h00;      
							blue_b <= 8'h00;
							green_b <= 8'h00;
						end  	
				end
				else if ((counter_y >= 142+hdif && counter_y < 144+hdif)
				||(counter_y >= 232+hdif && counter_y < 234+hdif)
				||(counter_y >= 323+hdif && counter_y < 325+hdif))
				begin
					if (counter_x >= 340+ xdif && counter_x < 390 + xdif)
						begin 
							red_b <= 8'h00;      
							blue_b <= 8'h00;
							green_b <= 8'h00;
						end  
					else if (counter_x >= 400+ xdif && counter_x < 450 + xdif)
						begin 
							red_b <= 8'h00;      
							blue_b <= 8'h00;
							green_b <= 8'h00;
						end  
					else if (counter_x >= 460+ xdif && counter_x < 510 + xdif)
						begin 
							red_b <= 8'h00;      
							blue_b <= 8'h00;
							green_b <= 8'h00;
						end  
					else if (counter_x >= 520+ xdif && counter_x < 570 + xdif)
						begin 
							red_b <= 8'h00;      
							blue_b <= 8'h00;
							green_b <= 8'h00;
						end 
				end
				
				if (counter_y >= 370+hdif && counter_y < 372+hdif)
				begin 
						if (counter_x >= 340+ xdif && counter_x < 570 + xdif)
							begin
						
							red_b <= 8'h00;      
							blue_b <= 8'h00;
							green_b <= 8'h00;
						end				
				end
				else if (counter_y >= 372+hdif && counter_y <433 +hdif)
				begin
				if (counter_x >= 340+ xdif && counter_x < 342 + xdif) begin;
							red_b <= 8'h00;      
							blue_b <= 8'h00;
							green_b <= 8'h00;
						end
				else if (counter_x >= 568+ xdif && counter_x < 570 + xdif) begin;
							red_b <= 8'h00;      
							blue_b <= 8'h00;
							green_b <= 8'h00;
						end		
				end
				else if(counter_y >= 433+hdif && counter_y < 435+hdif)
				begin
						if(counter_x >= 340+ xdif && counter_x < 570 + xdif)begin
						
							red_b <= 8'h00;      
							blue_b <= 8'h00;
							green_b <= 8'h00;
						end
				end
				
				
				if (counter_y >= 10+hdif && counter_y < 50+hdif) 
				
				begin
					if (counter_x >= 360+ xdif && counter_x < 362 + xdif)
						begin 
							red_b <= 8'h00;      
							blue_b <= 8'h00;
							green_b <= 8'h00;
						end  
				if (counter_y >= 10+hdif && counter_y < 12+hdif) 
				begin
					if (counter_x >= 415+xdif && counter_x < 445+xdif) 
					begin
						red_b <= 8'h00;      
						blue_b <= 8'h00;
						green_b <= 8'h00;
					end
				end

				

				else if (counter_y >= 12+hdif && counter_y < 28+hdif) 
				begin
					if (counter_x >= 448+xdif && counter_x < 450+xdif) 
					begin
						red_b <= 8'h00;      
						blue_b <= 8'h00;
						green_b <= 8'h00;		
					end
				end

				

				else if (counter_y >= 28+hdif && counter_y < 30+hdif) 
				begin
					if (counter_x >= 420+xdif && counter_x < 450+xdif) 
					begin
						red_b <= 8'h00;      
						blue_b <= 8'h00;
						green_b <= 8'h00;
					end
				end

				

				else if (counter_y >= 30+hdif && counter_y < 46+hdif) 
				begin
					if (counter_x >= 415+xdif && counter_x < 417+xdif) 
					begin
						red_b <= 8'h00;      
						blue_b <= 8'h00;
						green_b <= 8'h00;
					end
				end
				

				

				else if (counter_y >= 46+hdif && counter_y < 48+hdif) 
				begin
					if (counter_x >= 415+xdif && counter_x < 450+xdif) 
					begin
						red_b <= 8'h00;      
						blue_b <= 8'h00;
						green_b <= 8'h00;
					end
				end
				
				if (counter_y >= 10+hdif && counter_y < 12+hdif) 
				begin
					if (counter_x >= 475+xdif && counter_x < 495+xdif) 
					begin
						red_b <= 8'h00;      
						blue_b <= 8'h00;
						green_b <= 8'h00;
					end
				end

				

				else if (counter_y >= 12+hdif && counter_y < 29+hdif) 
				begin
					if (counter_x >= 493+xdif && counter_x < 495+xdif) 
					begin
						red_b <= 8'h00;      
						blue_b <= 8'h00;
						green_b <= 8'h00;		
					end
				end

				

				else if (counter_y >= 29+hdif && counter_y < 31+hdif) 
				begin
					if (counter_x >= 475+xdif && counter_x < 495+xdif) 
					begin
						red_b <= 8'h00;      
						blue_b <= 8'h00;
						green_b <= 8'h00;
					end
				end

				

				else if (counter_y >= 31+hdif && counter_y < 48+hdif) 
				begin
					if (counter_x >= 493+xdif && counter_x < 495+xdif) 
					begin
						red_b <= 8'h00;      
						blue_b <= 8'h00;
						green_b <= 8'h00;		
					end
				end

				

				else if (counter_y >= 31+hdif < 48+hdif) 
				begin
					if (counter_x >= 475+xdif && counter_x < 495++xdif) 
					begin
						red_b <= 8'h00;      
						blue_b <= 8'h00;
						green_b <= 8'h00;
					end
				end
				
				if (counter_y >= 12+hdif && counter_y < 40+hdif) 
				begin
					if (counter_x >= 530+xdif && counter_x < 532+xdif)
					begin
						red_b <= 8'h00;      
						blue_b <= 8'h00;
						green_b <= 8'h00;
					end
				end
				

				else if (counter_y >= 42+hdif && counter_y < 44+hdif) 
				begin
					if (counter_x >= 530+xdif && counter_x < 560+xdif) 
					begin
						red_b <= 8'h00;      
						blue_b <= 8'h00;
						green_b <= 8'h00;
					end
				end

				

				else if (counter_y >= 26+hdif && counter_y < 48+hdif) 
				begin
					if (counter_x >= 544+xdif && counter_x < 546+xdif) 
					begin
						red_b <= 8'h00;      
						blue_b <= 8'h00;
						green_b <= 8'h00;		
					end
				end
					
			end
					
			for (k=0; k<4; k = k+1)begin		
				if(a[k]==0)
				begin 
					if (counter_y >= 10+yoffset2 && counter_y < 12+yoffset2) 
					begin
						if (counter_x >= 20+xoffset2+k*50 && counter_x < 50+xoffset2+k*50) 
						begin
							red_b <= 8'h00;      
							blue_b <= 8'h00;
							green_b <= 8'h00;
						end
					end

					

					else if  (counter_y >= 12+yoffset2 && counter_y < 34+yoffset2) 
					begin
						if (counter_x >= 20+xoffset2+k*50 && counter_x < 22+xoffset2+k*50) 
						begin
							red_b <= 8'h00;      
							blue_b <= 8'h00;
							green_b <= 8'h00;
						end
						else if (counter_x >= 48+xoffset2+k*50 && counter_x < 50+xoffset2+k*50)
						begin
							red_b <= 8'h00;      
							blue_b <= 8'h00;
							green_b <= 8'h00;		
						end
					end

					else if (counter_y >= 34+yoffset2 && counter_y < 36+yoffset2) 
					begin
						if (counter_x >= 20+xoffset2+k*50 && counter_x < 22+xoffset2+k*50) 
						begin
							red_b <= 8'h00;      
							blue_b <= 8'h00;
							green_b <= 8'h00;	
						end

						else if (counter_x >= 48+xoffset2+k*50 && counter_x < 50+xoffset2+k*50)
						begin
							red_b <= 8'h00;      
							blue_b <= 8'h00;
							green_b <= 8'h00;	
						end
					end

					

					else if (counter_y >= 36+yoffset2 && counter_y < 58+yoffset2) 
					begin
						if (counter_x >= 20+xoffset2+k*50 && counter_x < 22+xoffset2+k*50) 
						begin
							red_b <= 8'h00;      
							blue_b <= 8'h00;
							green_b <= 8'h00;
						end
						else if (counter_x >= 48+xoffset2+k*50 && counter_x < 50+xoffset2+k*50) 
						begin
							red_b <= 8'h00;      
							blue_b <= 8'h00;
							green_b <= 8'h00;	
						end
					end
		

					

					else if (counter_y >= 58+yoffset2 && counter_y < 60+yoffset2) 
					begin
						if (counter_x >= 20+xoffset2+k*50 && counter_x < 50+xoffset2+k*50) 
						begin
							red_b <= 8'h00;      
							blue_b <= 8'h00;
							green_b <= 8'h00;
						end
					end
					
			end
				else if(a[k]==1)
				begin 
				if (counter_y >= 10+yoffset2 && counter_y < 12+yoffset2) 
				begin
					if (counter_x >= 48+xoffset2+k*50 && counter_x < 50+xoffset2+k*50) 
					begin
						red_b <= 8'h00;      
						blue_b <= 8'h00;
						green_b <= 8'h00;	
					end
				end
				else if  (counter_y >= 12+yoffset2 && counter_y < 34+yoffset2) 
				begin
					if (counter_x >= 48+xoffset2+k*50 && counter_x < 50+xoffset2+k*50) 
					begin
						red_b <= 8'h00;      
						blue_b <= 8'h00;
						green_b <= 8'h00;	
					end
				end	
				else if (counter_y >= 34+yoffset2 && counter_y < 36+yoffset2) 
				begin
					if (counter_x >= 48+xoffset2 +k*50&& counter_x < 50+xoffset2+k*50) 
					begin
						red_b <= 8'h00;      
						blue_b <= 8'h00;
						green_b <= 8'h00;	
					end
				end
				else if (counter_y >= 36+yoffset2 && counter_y < 58+yoffset2) 
				begin
					if (counter_x >= 48+xoffset2+k*50 && counter_x < 50+xoffset2+k*50) 
					begin
						red_b <= 8'h00;      
						blue_b <= 8'h00;
						green_b <= 8'h00;	
					end
				end
			end 

			end
			
	
		if ((counter_y >= 100+hdif && counter_y < 144+hdif))
				begin
           case (transmit_count0)
                        7'b0000001:begin
                            if ((counter_y >= 111+hdif && counter_y < 133+hdif))
				            begin
                                if (counter_x >= 363+ xdif && counter_x < 366 + xdif)
                                    begin 
                                        red_b <= 8'h00;      
                                        blue_b <= 8'h00;
                                        green_b <= 8'h00;
                                    end  
                            end
                        end
                        7'b0000010: begin
                                if (counter_y >= 110+hdif && counter_y < 112+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                        

                                  if (counter_y >= 112+hdif && counter_y < 121+hdif)
                                        begin
                                            if (counter_x >= 373+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                        
                                    if (counter_y >= 121+hdif && counter_y < 123+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                        
                                       if (counter_y >= 123+hdif && counter_y < 132+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 357+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                        
                                    if (counter_y >= 132+hdif && counter_y < 134+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0000011: begin
                                if (counter_y >= 110+hdif && counter_y < 112+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                        

                                  if (counter_y >= 112+hdif && counter_y < 121+hdif)
                                        begin
                                            if (counter_x >= 373+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                        
                                    if (counter_y >= 121+hdif && counter_y < 123+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                        
                                       if (counter_y >= 123+hdif && counter_y < 132+hdif)
                                        begin
                                            if (counter_x >= 373+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                        
                                    if (counter_y >= 132+hdif && counter_y < 134+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0000100: begin
                             if (counter_y >= 110+hdif && counter_y < 127+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 357+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                        

                                  if (counter_y >= 127+hdif && counter_y < 132+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 357+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                            else if (counter_x >= 366+xdif && counter_x < 367+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                   
                                 if (counter_y >= 132+hdif && counter_y < 134+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                        
                                    if (counter_y >= 134+hdif && counter_y < 139+hdif)
                                    begin
                                        if (counter_x >= 366+xdif && counter_x < 367+xdif) 
                                        begin
                                            red_b <= 8'h00;      
                                            blue_b <= 8'h00;
                                            green_b <= 8'h00;
                                        end
                                    end
                                   

                        end
                        7'b0000101: begin

                                if (counter_y >= 110+hdif && counter_y < 112+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                        

                                  if (counter_y >= 112+hdif && counter_y < 121+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 357+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                        
                                    if (counter_y >= 121+hdif && counter_y < 123+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                        
                                       if (counter_y >= 123+hdif && counter_y < 132+hdif)
                                        begin
                                            if (counter_x >= 373+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                    if (counter_y >= 132+hdif && counter_y < 134+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0000110: begin
                            if (counter_y >= 110+hdif && counter_y < 112+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                        

                                  if (counter_y >= 112+hdif && counter_y < 121+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 357+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                        
                                    if (counter_y >= 121+hdif && counter_y < 123+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                        
                                       if (counter_y >= 123+hdif && counter_y < 132+hdif)
                                        begin
                                            if (counter_x >= 373+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end

                                            if (counter_x >= 355+xdif && counter_x < 357+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                        
                                    if (counter_y >= 132+hdif && counter_y < 134+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0000111: begin
                            if (counter_y >= 110+hdif && counter_y < 112+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                        

                                  if (counter_y >= 112+hdif && counter_y < 134+hdif)
                                        begin
                                            if (counter_x >= 373+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0001000: begin
                            if (counter_y >= 110+hdif && counter_y < 112+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+hdif && counter_y < 121+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 357+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                            if (counter_x >= 373+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+hdif && counter_y < 123+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+hdif && counter_y < 132+hdif)
                                        begin
                                            if (counter_x >= 373+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end

                                            if (counter_x >= 355+xdif && counter_x < 357+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+hdif && counter_y < 134+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0001001: begin
                            if (counter_y >= 110+hdif && counter_y < 112+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+hdif && counter_y < 121+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 357+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                            if (counter_x >= 373+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+hdif && counter_y < 123+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+hdif && counter_y < 132+hdif)
                                        begin
                                            if (counter_x >= 373+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+hdif && counter_y < 134+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end

                        default:  begin
                            if (counter_y >= 110+hdif && counter_y < 112+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+hdif && counter_y < 121+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 357+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                            if (counter_x >= 373+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+hdif && counter_y < 123+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 357+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                            if (counter_x >= 373+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+hdif && counter_y < 132+hdif)
                                        begin
                                            if (counter_x >= 373+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end

                                            if (counter_x >= 355+xdif && counter_x < 357+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+hdif && counter_y < 134+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                            
                        end
							endcase
					
				
				 case (transmit_count1)
                        7'b0000001:begin
                            if ((counter_y >= 111+hdif && counter_y < 133+hdif))
				            begin
                                if (counter_x >= 363+60+xdif && counter_x < 366+60+xdif)
                                    begin 
                                        red_b <= 8'h00;      
                                        blue_b <= 8'h00;
                                        green_b <= 8'h00;
                                    end  
                            end
                        end
                        7'b0000010: begin
                                if (counter_y >= 110+hdif && counter_y < 112+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+hdif && counter_y < 121+hdif)
                                        begin
                                            if (counter_x >= 373+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+hdif && counter_y < 123+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+hdif && counter_y < 132+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 357+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+hdif && counter_y < 134+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0000011: begin
                                if (counter_y >= 110+hdif && counter_y < 112+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+hdif && counter_y < 121+hdif)
                                        begin
                                            if (counter_x >= 373+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+hdif && counter_y < 123+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+hdif && counter_y < 132+hdif)
                                        begin
                                            if (counter_x >= 373+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+hdif && counter_y < 134+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0000100: begin
                             if (counter_y >= 110+hdif && counter_y < 127+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 357+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 127+hdif && counter_y < 132+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 357+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                            else if (counter_x >= 366+60+xdif && counter_x < 367+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                     
                                 if (counter_y >= 132+hdif && counter_y < 134+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          
                                    if (counter_y >= 134+hdif && counter_y < 139+hdif)
                                    begin
                                        if (counter_x >= 366+60+xdif && counter_x < 367+60+xdif) 
                                        begin
                                            red_b <= 8'h00;      
                                            blue_b <= 8'h00;
                                            green_b <= 8'h00;
                                        end
                                    end
                                   

                        end
                        7'b0000101: begin

                                if (counter_y >= 110+hdif && counter_y < 112+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+hdif && counter_y < 121+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 357+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+hdif && counter_y < 123+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+hdif && counter_y < 132+hdif)
                                        begin
                                            if (counter_x >= 373+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+hdif && counter_y < 134+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0000110: begin
                            if (counter_y >= 110+hdif && counter_y < 112+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+hdif && counter_y < 121+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 357+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+hdif && counter_y < 123+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+hdif && counter_y < 132+hdif)
                                        begin
                                            if (counter_x >= 373+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end

                                            if (counter_x >= 355+60+xdif && counter_x < 357+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+hdif && counter_y < 134+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0000111: begin
                            if (counter_y >= 110+hdif && counter_y < 112+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+hdif && counter_y < 134+hdif)
                                        begin
                                            if (counter_x >= 373+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0001000: begin
                            if (counter_y >= 110+hdif && counter_y < 112+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+hdif && counter_y < 121+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 357+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                            if (counter_x >= 373+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+hdif && counter_y < 123+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+hdif && counter_y < 132+hdif)
                                        begin
                                            if (counter_x >= 373+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end

                                            if (counter_x >= 355+60+xdif && counter_x < 357+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+hdif && counter_y < 134+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0001001: begin
                            if (counter_y >= 110+hdif && counter_y < 112+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+hdif && counter_y < 121+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 357+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                            if (counter_x >= 373+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+hdif && counter_y < 123+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+hdif && counter_y < 132+hdif)
                                        begin
                                            if (counter_x >= 373+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+hdif && counter_y < 134+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end

                        default: begin
                            if (counter_y >= 110+hdif && counter_y < 112+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+hdif && counter_y < 121+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 357+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                            if (counter_x >= 373+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+hdif && counter_y < 123+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 357+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                            if (counter_x >= 373+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+hdif && counter_y < 132+hdif)
                                        begin
                                            if (counter_x >= 373+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end

                                            if (counter_x >= 355+60+xdif && counter_x < 357+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+hdif && counter_y < 134+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                            
                        end
                    endcase
						  
				  case (transmit_count2)
                        7'b0000001:begin
                            if ((counter_y >= 111+hdif && counter_y < 133+hdif))
				            begin
                                if (counter_x >= 363+60+60+xdif && counter_x < 366+60+60+xdif)
                                    begin 
                                        red_b <= 8'h00;      
                                        blue_b <= 8'h00;
                                        green_b <= 8'h00;
                                    end  
                            end
                        end
                        7'b0000010: begin
                                if (counter_y >= 110+hdif && counter_y < 112+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+hdif && counter_y < 121+hdif)
                                        begin
                                            if (counter_x >= 373+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+hdif && counter_y < 123+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+hdif && counter_y < 132+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 357+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+hdif && counter_y < 134+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0000011: begin
                                if (counter_y >= 110+hdif && counter_y < 112+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+hdif && counter_y < 121+hdif)
                                        begin
                                            if (counter_x >= 373+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+hdif && counter_y < 123+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+hdif && counter_y < 132+hdif)
                                        begin
                                            if (counter_x >= 373+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+hdif && counter_y < 134+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0000100: begin
                             if (counter_y >= 110+hdif && counter_y < 127+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 357+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 127+hdif && counter_y < 132+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 357+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                            else if (counter_x >= 366+60+60+xdif && counter_x < 367+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                     
                                 if (counter_y >= 132+hdif && counter_y < 134+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          
                                    if (counter_y >= 134+hdif && counter_y < 139+hdif)
                                    begin
                                        if (counter_x >= 366+60+60+xdif && counter_x < 367+60+60+xdif) 
                                        begin
                                            red_b <= 8'h00;      
                                            blue_b <= 8'h00;
                                            green_b <= 8'h00;
                                        end
                                    end
                                     

                        end
                        7'b0000101: begin

                                if (counter_y >= 110+hdif && counter_y < 112+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+hdif && counter_y < 121+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 357+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+hdif && counter_y < 123+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+hdif && counter_y < 132+hdif)
                                        begin
                                            if (counter_x >= 373+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+hdif && counter_y < 134+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0000110: begin
                            if (counter_y >= 110+hdif && counter_y < 112+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+hdif && counter_y < 121+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 357+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+hdif && counter_y < 123+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+hdif && counter_y < 132+hdif)
                                        begin
                                            if (counter_x >= 373+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end

                                            if (counter_x >= 355+60+60+xdif && counter_x < 357+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+hdif && counter_y < 134+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0000111: begin
                            if (counter_y >= 110+hdif && counter_y < 112+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+hdif && counter_y < 134+hdif)
                                        begin
                                            if (counter_x >= 373+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0001000: begin
                            if (counter_y >= 110+hdif && counter_y < 112+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+hdif && counter_y < 121+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 357+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                            if (counter_x >= 373+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+hdif && counter_y < 123+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+hdif && counter_y < 132+hdif)
                                        begin
                                            if (counter_x >= 373+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end

                                            if (counter_x >= 355+60+60+xdif && counter_x < 357+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+hdif && counter_y < 134+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0001001: begin
                            if (counter_y >= 110+hdif && counter_y < 112+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+hdif && counter_y < 121+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 357+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                            if (counter_x >= 373+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+hdif && counter_y < 123+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+hdif && counter_y < 132+hdif)
                                        begin
                                            if (counter_x >= 373+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+hdif && counter_y < 134+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end

                        default: begin
                            if (counter_y >= 110+hdif && counter_y < 112+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+hdif && counter_y < 121+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 357+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                            if (counter_x >= 373+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+hdif && counter_y < 123+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 357+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                            if (counter_x >= 373+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+hdif && counter_y < 132+hdif)
                                        begin
                                            if (counter_x >= 373+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end

                                            if (counter_x >= 355+60+60+xdif && counter_x < 357+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+hdif && counter_y < 134+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                            
                        end
                    endcase

				
				case (transmit_count3)
                        7'b0000001:begin
                            if ((counter_y >= 111+hdif && counter_y < 133+hdif))
				            begin
                                if (counter_x >= 363+60+60+60+xdif && counter_x < 366+60+60+60+xdif)
                                    begin 
                                        red_b <= 8'h00;      
                                        blue_b <= 8'h00;
                                        green_b <= 8'h00;
                                    end  
                            end
                        end
                        7'b0000010: begin
                                if (counter_y >= 110+hdif && counter_y < 112+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+hdif && counter_y < 121+hdif)
                                        begin
                                            if (counter_x >= 373+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+hdif && counter_y < 123+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+hdif && counter_y < 132+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 357+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+hdif && counter_y < 134+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0000011: begin
                                if (counter_y >= 110+hdif && counter_y < 112+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+hdif && counter_y < 121+hdif)
                                        begin
                                            if (counter_x >= 373+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+hdif && counter_y < 123+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+hdif && counter_y < 132+hdif)
                                        begin
                                            if (counter_x >= 373+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+hdif && counter_y < 134+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0000100: begin
                             if (counter_y >= 110+hdif && counter_y < 127+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 357+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 127+hdif && counter_y < 132+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 357+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                            else if (counter_x >= 366+60+60+60+xdif && counter_x < 367+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                     
                                 if (counter_y >= 132+hdif && counter_y < 134+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          
                                    if (counter_y >= 134+hdif && counter_y < 139+hdif)
                                    begin
                                        if (counter_x >= 366+60+60+60+xdif && counter_x < 367+60+60+60+xdif) 
                                        begin
                                            red_b <= 8'h00;      
                                            blue_b <= 8'h00;
                                            green_b <= 8'h00;
                                        end
                                    end
                                     

                        end
                        7'b0000101: begin

                                if (counter_y >= 110+hdif && counter_y < 112+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+hdif && counter_y < 121+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 357+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+hdif && counter_y < 123+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+hdif && counter_y < 132+hdif)
                                        begin
                                            if (counter_x >= 373+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+hdif && counter_y < 134+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0000110: begin
                            if (counter_y >= 110+hdif && counter_y < 112+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+hdif && counter_y < 121+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 357+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+hdif && counter_y < 123+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+hdif && counter_y < 132+hdif)
                                        begin
                                            if (counter_x >= 373+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end

                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 357+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+hdif && counter_y < 134+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0000111: begin
                            if (counter_y >= 110+hdif && counter_y < 112+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+hdif && counter_y < 134+hdif)
                                        begin
                                            if (counter_x >= 373+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0001000: begin
                            if (counter_y >= 110+hdif && counter_y < 112+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+hdif && counter_y < 121+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 357+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                            if (counter_x >= 373+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+hdif && counter_y < 123+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+hdif && counter_y < 132+hdif)
                                        begin
                                            if (counter_x >= 373+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end

                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 357+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+hdif && counter_y < 134+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0001001: begin
                            if (counter_y >= 110+hdif && counter_y < 112+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+hdif && counter_y < 121+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 357+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                            if (counter_x >= 373+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+hdif && counter_y < 123+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+hdif && counter_y < 132+hdif)
                                        begin
                                            if (counter_x >= 373+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+hdif && counter_y < 134+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end

                        default: begin
                            if (counter_y >= 110+hdif && counter_y < 112+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+hdif && counter_y < 121+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 357+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                            if (counter_x >= 373+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+hdif && counter_y < 123+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 357+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                            if (counter_x >= 373+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+hdif && counter_y < 132+hdif)
                                        begin
                                            if (counter_x >= 373+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end

                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 357+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+hdif && counter_y < 134+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                            
                        end
                    endcase
			
			end
			
	
	
		if ((counter_y >= 100+90+hdif && counter_y < 144+90+hdif))
				begin
                    case (total_count0)
                     
                        7'b0000001:begin
                            if ((counter_y >= 111+90+hdif && counter_y < 133+90+hdif))
				            begin
                                if (counter_x >= 363+ xdif && counter_x < 366 + xdif)
                                    begin 
                                        red_b <= 8'h00;      
                                        blue_b <= 8'h00;
                                        green_b <= 8'h00;
                                    end  
                            end
                        end
                        7'b0000010: begin
                                if (counter_y >= 110+90+hdif && counter_y < 112+90+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+hdif && counter_y < 121+90+hdif)
                                        begin
                                            if (counter_x >= 373+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+90+hdif && counter_y < 123+90+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+90+hdif && counter_y < 132+90+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 357+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+90+hdif && counter_y < 134+90+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0000011: begin
                                if (counter_y >= 110+90+hdif && counter_y < 112+90+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+hdif && counter_y < 121+90+hdif)
                                        begin
                                            if (counter_x >= 373+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+90+hdif && counter_y < 123+90+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+90+hdif && counter_y < 132+90+hdif)
                                        begin
                                            if (counter_x >= 373+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+90+hdif && counter_y < 134+90+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0000100: begin
                             if (counter_y >= 110+90+hdif && counter_y < 127+90+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 357+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 127+90+hdif && counter_y < 132+90+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 357+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                            else if (counter_x >= 366+xdif && counter_x < 367+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                     
                                 if (counter_y >= 132+90+hdif && counter_y < 134+90+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          
                                    if (counter_y >= 134+90+hdif && counter_y < 139+90+hdif)
                                    begin
                                        if (counter_x >= 366+xdif && counter_x < 367+xdif) 
                                        begin
                                            red_b <= 8'h00;      
                                            blue_b <= 8'h00;
                                            green_b <= 8'h00;
                                        end
                                    end
                                     

                        end
                        7'b0000101: begin

                                if (counter_y >= 110+90+hdif && counter_y < 112+90+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+hdif && counter_y < 121+90+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 357+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+90+hdif && counter_y < 123+90+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+90+hdif && counter_y < 132+90+hdif)
                                        begin
                                            if (counter_x >= 373+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+90+hdif && counter_y < 134+90+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0000110: begin
                            if (counter_y >= 110+90+hdif && counter_y < 112+90+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+hdif && counter_y < 121+90+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 357+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+90+hdif && counter_y < 123+90+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+90+hdif && counter_y < 132+90+hdif)
                                        begin
                                            if (counter_x >= 373+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end

                                            if (counter_x >= 355+xdif && counter_x < 357+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+90+hdif && counter_y < 134+90+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0000111: begin
                            if (counter_y >= 110+90+hdif && counter_y < 112+90+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+hdif && counter_y < 134+90+hdif)
                                        begin
                                            if (counter_x >= 373+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0001000: begin
                            if (counter_y >= 110+90+hdif && counter_y < 112+90+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+hdif && counter_y < 121+90+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 357+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                            if (counter_x >= 373+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+90+hdif && counter_y < 123+90+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+90+hdif && counter_y < 132+90+hdif)
                                        begin
                                            if (counter_x >= 373+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end

                                            if (counter_x >= 355+xdif && counter_x < 357+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+90+hdif && counter_y < 134+90+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0001001: begin
                            if (counter_y >= 110+90+hdif && counter_y < 112+90+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+hdif && counter_y < 121+90+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 357+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                            if (counter_x >= 373+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+90+hdif && counter_y < 123+90+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+90+hdif && counter_y < 132+90+hdif)
                                        begin
                                            if (counter_x >= 373+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+90+hdif && counter_y < 134+90+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end

                        default: begin
                            if (counter_y >= 110+90+hdif && counter_y < 112+90+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+hdif && counter_y < 121+90+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 357+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                            if (counter_x >= 373+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+90+hdif && counter_y < 123+90+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 357+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                            if (counter_x >= 373+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+90+hdif && counter_y < 132+90+hdif)
                                        begin
                                            if (counter_x >= 373+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end

                                            if (counter_x >= 355+xdif && counter_x < 357+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+90+hdif && counter_y < 134+90+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                            
                        end
					 endcase
					 
                    
					
                   

				
				
				
							case (total_count1)
                        7'b0000001:begin
                            if ((counter_y >= 111+90+hdif && counter_y < 133+90+hdif))
				            begin
                                if (counter_x >= 363+60+xdif && counter_x < 366+60+xdif)
                                    begin 
                                        red_b <= 8'h00;      
                                        blue_b <= 8'h00;
                                        green_b <= 8'h00;
                                    end  
                            end
                        end
                        7'b0000010: begin
                                if (counter_y >= 110+90+hdif && counter_y < 112+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+hdif && counter_y < 121+90+hdif)
                                        begin
                                            if (counter_x >= 373+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+90+hdif && counter_y < 123+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+90+hdif && counter_y < 132+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 357+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+90+hdif && counter_y < 134+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0000011: begin
                                if (counter_y >= 110+90+hdif && counter_y < 112+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+hdif && counter_y < 121+90+hdif)
                                        begin
                                            if (counter_x >= 373+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+90+hdif && counter_y < 123+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+90+hdif && counter_y < 132+90+hdif)
                                        begin
                                            if (counter_x >= 373+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+90+hdif && counter_y < 134+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0000100: begin
                             if (counter_y >= 110+90+hdif && counter_y < 127+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 357+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 127+90+hdif && counter_y < 132+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 357+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                            else if (counter_x >= 366+60+xdif && counter_x < 367+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                     
                                 if (counter_y >= 132+90+hdif && counter_y < 134+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          
                                    if (counter_y >= 134+90+hdif && counter_y < 139+90+hdif)
                                    begin
                                        if (counter_x >= 366+60+xdif && counter_x < 367+60+xdif) 
                                        begin
                                            red_b <= 8'h00;      
                                            blue_b <= 8'h00;
                                            green_b <= 8'h00;
                                        end
                                    end
                                     

                        end
                        7'b0000101: begin

                                if (counter_y >= 110+90+hdif && counter_y < 112+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+hdif && counter_y < 121+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 357+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+90+hdif && counter_y < 123+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+90+hdif && counter_y < 132+90+hdif)
                                        begin
                                            if (counter_x >= 373+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+90+hdif && counter_y < 134+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0000110: begin
                            if (counter_y >= 110+90+hdif && counter_y < 112+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+hdif && counter_y < 121+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 357+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+90+hdif && counter_y < 123+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+90+hdif && counter_y < 132+90+hdif)
                                        begin
                                            if (counter_x >= 373+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end

                                            if (counter_x >= 355+60+xdif && counter_x < 357+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+90+hdif && counter_y < 134+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0000111: begin
                            if (counter_y >= 110+90+hdif && counter_y < 112+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+hdif && counter_y < 134+90+hdif)
                                        begin
                                            if (counter_x >= 373+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0001000: begin
                            if (counter_y >= 110+90+hdif && counter_y < 112+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+hdif && counter_y < 121+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 357+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                            if (counter_x >= 373+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+90+hdif && counter_y < 123+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+90+hdif && counter_y < 132+90+hdif)
                                        begin
                                            if (counter_x >= 373+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end

                                            if (counter_x >= 355+60+xdif && counter_x < 357+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+90+hdif && counter_y < 134+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0001001: begin
                            if (counter_y >= 110+90+hdif && counter_y < 112+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+hdif && counter_y < 121+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 357+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                            if (counter_x >= 373+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+90+hdif && counter_y < 123+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+90+hdif && counter_y < 132+90+hdif)
                                        begin
                                            if (counter_x >= 373+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+90+hdif && counter_y < 134+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end

                        default: begin
                            if (counter_y >= 110+90+hdif && counter_y < 112+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+hdif && counter_y < 121+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 357+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                            if (counter_x >= 373+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+90+hdif && counter_y < 123+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 357+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                            if (counter_x >= 373+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+90+hdif && counter_y < 132+90+hdif)
                                        begin
                                            if (counter_x >= 373+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end

                                            if (counter_x >= 355+60+xdif && counter_x < 357+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+90+hdif && counter_y < 134+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                            
                        end
                    endcase
				
				
							 case (total_count2)
                        7'b0000001:begin
                            if ((counter_y >= 111+90+hdif && counter_y < 133+90+hdif))
				            begin
                                if (counter_x >= 363+60+60+xdif && counter_x < 366+60+60+xdif)
                                    begin 
                                        red_b <= 8'h00;      
                                        blue_b <= 8'h00;
                                        green_b <= 8'h00;
                                    end  
                            end
                        end
                        7'b0000010: begin
                                if (counter_y >= 110+90+hdif && counter_y < 112+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+hdif && counter_y < 121+90+hdif)
                                        begin
                                            if (counter_x >= 373+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+90+hdif && counter_y < 123+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+90+hdif && counter_y < 132+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 357+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+90+hdif && counter_y < 134+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0000011: begin
                                if (counter_y >= 110+90+hdif && counter_y < 112+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+hdif && counter_y < 121+90+hdif)
                                        begin
                                            if (counter_x >= 373+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+90+hdif && counter_y < 123+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+90+hdif && counter_y < 132+90+hdif)
                                        begin
                                            if (counter_x >= 373+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+90+hdif && counter_y < 134+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0000100: begin
                             if (counter_y >= 110+90+hdif && counter_y < 127+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 357+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 127+90+hdif && counter_y < 132+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 357+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                            else if (counter_x >= 366+60+60+xdif && counter_x < 367+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                     
                                 if (counter_y >= 132+90+hdif && counter_y < 134+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          
                                    if (counter_y >= 134+90+hdif && counter_y < 139+90+hdif)
                                    begin
                                        if (counter_x >= 366+60+60+xdif && counter_x < 367+60+60+xdif) 
                                        begin
                                            red_b <= 8'h00;      
                                            blue_b <= 8'h00;
                                            green_b <= 8'h00;
                                        end
                                    end
                                     

                        end
                        7'b0000101: begin

                                if (counter_y >= 110+90+hdif && counter_y < 112+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+hdif && counter_y < 121+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 357+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+90+hdif && counter_y < 123+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+90+hdif && counter_y < 132+90+hdif)
                                        begin
                                            if (counter_x >= 373+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+90+hdif && counter_y < 134+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0000110: begin
                            if (counter_y >= 110+90+hdif && counter_y < 112+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+hdif && counter_y < 121+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 357+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+90+hdif && counter_y < 123+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+90+hdif && counter_y < 132+90+hdif)
                                        begin
                                            if (counter_x >= 373+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end

                                            if (counter_x >= 355+60+60+xdif && counter_x < 357+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+90+hdif && counter_y < 134+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0000111: begin
                            if (counter_y >= 110+90+hdif && counter_y < 112+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+hdif && counter_y < 134+90+hdif)
                                        begin
                                            if (counter_x >= 373+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0001000: begin
                            if (counter_y >= 110+90+hdif && counter_y < 112+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+hdif && counter_y < 121+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 357+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                            if (counter_x >= 373+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+90+hdif && counter_y < 123+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+90+hdif && counter_y < 132+90+hdif)
                                        begin
                                            if (counter_x >= 373+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end

                                            if (counter_x >= 355+60+60+xdif && counter_x < 357+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+90+hdif && counter_y < 134+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0001001: begin
                            if (counter_y >= 110+90+hdif && counter_y < 112+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+hdif && counter_y < 121+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 357+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                            if (counter_x >= 373+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+90+hdif && counter_y < 123+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+90+hdif && counter_y < 132+90+hdif)
                                        begin
                                            if (counter_x >= 373+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+90+hdif && counter_y < 134+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end

                        default: begin
                            if (counter_y >= 110+90+hdif && counter_y < 112+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+hdif && counter_y < 121+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 357+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                            if (counter_x >= 373+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+90+hdif && counter_y < 123+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 357+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                            if (counter_x >= 373+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+90+hdif && counter_y < 132+90+hdif)
                                        begin
                                            if (counter_x >= 373+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end

                                            if (counter_x >= 355+60+60+xdif && counter_x < 357+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+90+hdif && counter_y < 134+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                            
                        end
                    endcase
				
							 case (total_count3)
                        7'b0000001:begin
                            if ((counter_y >= 111+90+hdif && counter_y < 133+90+hdif))
				            begin
                                if (counter_x >= 363+60+60+60+xdif && counter_x < 366+60+60+60+xdif)
                                    begin 
                                        red_b <= 8'h00;      
                                        blue_b <= 8'h00;
                                        green_b <= 8'h00;
                                    end  
                            end
                        end
                        7'b0000010: begin
                                if (counter_y >= 110+90+hdif && counter_y < 112+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+hdif && counter_y < 121+90+hdif)
                                        begin
                                            if (counter_x >= 373+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+90+hdif && counter_y < 123+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+90+hdif && counter_y < 132+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 357+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+90+hdif && counter_y < 134+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0000011: begin
                                if (counter_y >= 110+90+hdif && counter_y < 112+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+hdif && counter_y < 121+90+hdif)
                                        begin
                                            if (counter_x >= 373+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+90+hdif && counter_y < 123+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+90+hdif && counter_y < 132+90+hdif)
                                        begin
                                            if (counter_x >= 373+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+90+hdif && counter_y < 134+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0000100: begin
                             if (counter_y >= 110+90+hdif && counter_y < 127+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 357+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 127+90+hdif && counter_y < 132+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 357+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                            else if (counter_x >= 366+60+60+60+xdif && counter_x < 367+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                     
                                 if (counter_y >= 132+90+hdif && counter_y < 134+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          
                                    if (counter_y >= 134+90+hdif && counter_y < 139+90+hdif)
                                    begin
                                        if (counter_x >= 366+60+60+60+xdif && counter_x < 367+60+60+60+xdif) 
                                        begin
                                            red_b <= 8'h00;      
                                            blue_b <= 8'h00;
                                            green_b <= 8'h00;
                                        end
                                    end
                                     

                        end
                        7'b0000101: begin

                                if (counter_y >= 110+90+hdif && counter_y < 112+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+hdif && counter_y < 121+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 357+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+90+hdif && counter_y < 123+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+90+hdif && counter_y < 132+90+hdif)
                                        begin
                                            if (counter_x >= 373+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+90+hdif && counter_y < 134+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0000110: begin
                            if (counter_y >= 110+90+hdif && counter_y < 112+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+hdif && counter_y < 121+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 357+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+90+hdif && counter_y < 123+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+90+hdif && counter_y < 132+90+hdif)
                                        begin
                                            if (counter_x >= 373+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end

                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 357+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+90+hdif && counter_y < 134+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0000111: begin
                            if (counter_y >= 110+90+hdif && counter_y < 112+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+hdif && counter_y < 134+90+hdif)
                                        begin
                                            if (counter_x >= 373+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0001000: begin
                            if (counter_y >= 110+90+hdif && counter_y < 112+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+hdif && counter_y < 121+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 357+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                            if (counter_x >= 373+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+90+hdif && counter_y < 123+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+90+hdif && counter_y < 132+90+hdif)
                                        begin
                                            if (counter_x >= 373+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end

                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 357+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+90+hdif && counter_y < 134+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0001001: begin
                            if (counter_y >= 110+90+hdif && counter_y < 112+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+hdif && counter_y < 121+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 357+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                            if (counter_x >= 373+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+90+hdif && counter_y < 123+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+90+hdif && counter_y < 132+90+hdif)
                                        begin
                                            if (counter_x >= 373+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+90+hdif && counter_y < 134+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end

                        default: begin
                            if (counter_y >= 110+90+hdif && counter_y < 112+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+hdif && counter_y < 121+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 357+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                            if (counter_x >= 373+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+90+hdif && counter_y < 123+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 357+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                            if (counter_x >= 373+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+90+hdif && counter_y < 132+90+hdif)
                                        begin
                                            if (counter_x >= 373+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end

                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 357+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+90+hdif && counter_y < 134+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                            
                        end
                    endcase
				
				end
				
	
	
	if ((counter_y >= 100+90+90+hdif && counter_y < 144+90+90+hdif))
				begin
                    case (drop_count0)
                        
                        7'b0000001:begin
                            if ((counter_y >= 111+90+90+hdif && counter_y < 133+90+90+hdif))
				            begin
                                if (counter_x >= 363+ xdif && counter_x < 366 + xdif)
                                    begin 
                                        red_b <= 8'h00;      
                                        blue_b <= 8'h00;
                                        green_b <= 8'h00;
                                    end  
                            end
                        end
                        7'b0000010: begin
                                if (counter_y >= 110+90+90+hdif && counter_y < 112+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+90+hdif && counter_y < 121+90+90+hdif)
                                        begin
                                            if (counter_x >= 373+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+90+90+hdif && counter_y < 123+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+90+90+hdif && counter_y < 132+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 357+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+90+90+hdif && counter_y < 134+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0000011: begin
                                if (counter_y >= 110+90+90+hdif && counter_y < 112+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+90+hdif && counter_y < 121+90+90+hdif)
                                        begin
                                            if (counter_x >= 373+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+90+90+hdif && counter_y < 123+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+90+90+hdif && counter_y < 132+90+90+hdif)
                                        begin
                                            if (counter_x >= 373+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+90+90+hdif && counter_y < 134+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0000100: begin
                             if (counter_y >= 110+90+90+hdif && counter_y < 127+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 357+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 127+90+90+hdif && counter_y < 132+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 357+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                            else if (counter_x >= 366+xdif && counter_x < 367+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                     
                                 if (counter_y >= 132+90+90+hdif && counter_y < 134+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          
                                    if (counter_y >= 134+90+90+hdif && counter_y < 139+90+90+hdif)
                                    begin
                                        if (counter_x >= 366+xdif && counter_x < 367+xdif) 
                                        begin
                                            red_b <= 8'h00;      
                                            blue_b <= 8'h00;
                                            green_b <= 8'h00;
                                        end
                                    end
                                     

                        end
                        7'b0000101: begin

                                if (counter_y >= 110+90+90+hdif && counter_y < 112+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+90+hdif && counter_y < 121+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 357+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+90+90+hdif && counter_y < 123+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+90+90+hdif && counter_y < 132+90+90+hdif)
                                        begin
                                            if (counter_x >= 373+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+90+90+hdif && counter_y < 134+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0000110: begin
                            if (counter_y >= 110+90+90+hdif && counter_y < 112+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+90+hdif && counter_y < 121+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 357+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+90+90+hdif && counter_y < 123+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+90+90+hdif && counter_y < 132+90+90+hdif)
                                        begin
                                            if (counter_x >= 373+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end

                                            if (counter_x >= 355+xdif && counter_x < 357+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+90+90+hdif && counter_y < 134+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0000111: begin
                            if (counter_y >= 110+90+90+hdif && counter_y < 112+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+90+hdif && counter_y < 134+90+90+hdif)
                                        begin
                                            if (counter_x >= 373+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0001000: begin
                            if (counter_y >= 110+90+90+hdif && counter_y < 112+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+90+hdif && counter_y < 121+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 357+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                            if (counter_x >= 373+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+90+90+hdif && counter_y < 123+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+90+90+hdif && counter_y < 132+90+90+hdif)
                                        begin
                                            if (counter_x >= 373+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end

                                            if (counter_x >= 355+xdif && counter_x < 357+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+90+90+hdif && counter_y < 134+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0001001: begin
                            if (counter_y >= 110+90+90+hdif && counter_y < 112+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+90+hdif && counter_y < 121+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 357+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                            if (counter_x >= 373+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+90+90+hdif && counter_y < 123+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+90+90+hdif && counter_y < 132+90+90+hdif)
                                        begin
                                            if (counter_x >= 373+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+90+90+hdif && counter_y < 134+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end

                        default: begin
                            if (counter_y >= 110+90+90+hdif && counter_y < 112+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+90+hdif && counter_y < 121+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 357+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                            if (counter_x >= 373+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+90+90+hdif && counter_y < 123+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 357+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                            if (counter_x >= 373+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+90+90+hdif && counter_y < 132+90+90+hdif)
                                        begin
                                            if (counter_x >= 373+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end

                                            if (counter_x >= 355+xdif && counter_x < 357+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+90+90+hdif && counter_y < 134+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+xdif && counter_x < 375+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                            
                        end
                    endcase

              
                    case (drop_count1)
                        
                        7'b0000001:begin
                            if ((counter_y >= 111+90+90+hdif && counter_y < 133+90+90+hdif))
				            begin
                                if (counter_x >= 363+60+xdif && counter_x < 366 +60+xdif)
                                    begin 
                                        red_b <= 8'h00;      
                                        blue_b <= 8'h00;
                                        green_b <= 8'h00;
                                    end  
                            end
                        end
                        7'b0000010: begin
                                if (counter_y >= 110+90+90+hdif && counter_y < 112+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+90+hdif && counter_y < 121+90+90+hdif)
                                        begin
                                            if (counter_x >= 373+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+90+90+hdif && counter_y < 123+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+90+90+hdif && counter_y < 132+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 357+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+90+90+hdif && counter_y < 134+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0000011: begin
                                if (counter_y >= 110+90+90+hdif && counter_y < 112+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+90+hdif && counter_y < 121+90+90+hdif)
                                        begin
                                            if (counter_x >= 373+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+90+90+hdif && counter_y < 123+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+90+90+hdif && counter_y < 132+90+90+hdif)
                                        begin
                                            if (counter_x >= 373+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+90+90+hdif && counter_y < 134+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0000100: begin
                             if (counter_y >= 110+90+90+hdif && counter_y < 127+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 357+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 127+90+90+hdif && counter_y < 132+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 357+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                            else if (counter_x >= 366+60+xdif && counter_x < 367+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                     
                                 if (counter_y >= 132+90+90+hdif && counter_y < 134+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          
                                    if (counter_y >= 134+90+90+hdif && counter_y < 139+90+90+hdif)
                                    begin
                                        if (counter_x >= 366+60+xdif && counter_x < 367+60+xdif) 
                                        begin
                                            red_b <= 8'h00;      
                                            blue_b <= 8'h00;
                                            green_b <= 8'h00;
                                        end
                                    end
                                     

                        end
                        7'b0000101: begin

                                if (counter_y >= 110+90+90+hdif && counter_y < 112+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+90+hdif && counter_y < 121+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 357+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+90+90+hdif && counter_y < 123+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+90+90+hdif && counter_y < 132+90+90+hdif)
                                        begin
                                            if (counter_x >= 373+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+90+90+hdif && counter_y < 134+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0000110: begin
                            if (counter_y >= 110+90+90+hdif && counter_y < 112+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+90+hdif && counter_y < 121+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 357+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+90+90+hdif && counter_y < 123+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+90+90+hdif && counter_y < 132+90+90+hdif)
                                        begin
                                            if (counter_x >= 373+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end

                                            if (counter_x >= 355+60+xdif && counter_x < 357+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+90+90+hdif && counter_y < 134+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0000111: begin
                            if (counter_y >= 110+90+90+hdif && counter_y < 112+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+90+hdif && counter_y < 134+90+90+hdif)
                                        begin
                                            if (counter_x >= 373+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0001000: begin
                            if (counter_y >= 110+90+90+hdif && counter_y < 112+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+90+hdif && counter_y < 121+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 357+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                            if (counter_x >= 373+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+90+90+hdif && counter_y < 123+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+90+90+hdif && counter_y < 132+90+90+hdif)
                                        begin
                                            if (counter_x >= 373+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end

                                            if (counter_x >= 355+60+xdif && counter_x < 357+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+90+90+hdif && counter_y < 134+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0001001: begin
                            if (counter_y >= 110+90+90+hdif && counter_y < 112+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+90+hdif && counter_y < 121+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 357+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                            if (counter_x >= 373+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+90+90+hdif && counter_y < 123+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+90+90+hdif && counter_y < 132+90+90+hdif)
                                        begin
                                            if (counter_x >= 373+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+90+90+hdif && counter_y < 134+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end

                        default: begin
                            if (counter_y >= 110+90+90+hdif && counter_y < 112+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+90+hdif && counter_y < 121+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 357+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                            if (counter_x >= 373+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+90+90+hdif && counter_y < 123+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 357+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                            if (counter_x >= 373+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+90+90+hdif && counter_y < 132+90+90+hdif)
                                        begin
                                            if (counter_x >= 373+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end

                                            if (counter_x >= 355+60+xdif && counter_x < 357+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+90+90+hdif && counter_y < 134+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+xdif && counter_x < 375+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                            
                        end
                    endcase
				
                    case (drop_count2)
                        
                        7'b0000001:begin
                            if ((counter_y >= 111+90+90+hdif && counter_y < 133+90+90+hdif))
				            begin
                                if (counter_x >= 363+60+60+xdif && counter_x < 366+60+60+xdif)
                                    begin 
                                        red_b <= 8'h00;      
                                        blue_b <= 8'h00;
                                        green_b <= 8'h00;
                                    end  
                            end
                        end
                        7'b0000010: begin
                                if (counter_y >= 110+90+90+hdif && counter_y < 112+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+90+hdif && counter_y < 121+90+90+hdif)
                                        begin
                                            if (counter_x >= 373+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+90+90+hdif && counter_y < 123+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+90+90+hdif && counter_y < 132+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 357+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+90+90+hdif && counter_y < 134+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0000011: begin
                                if (counter_y >= 110+90+90+hdif && counter_y < 112+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+90+hdif && counter_y < 121+90+90+hdif)
                                        begin
                                            if (counter_x >= 373+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+90+90+hdif && counter_y < 123+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+90+90+hdif && counter_y < 132+90+90+hdif)
                                        begin
                                            if (counter_x >= 373+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+90+90+hdif && counter_y < 134+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0000100: begin
                             if (counter_y >= 110+90+90+hdif && counter_y < 127+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 357+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 127+90+90+hdif && counter_y < 132+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 357+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                            else if (counter_x >= 366+60+60+xdif && counter_x < 367+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                     
                                 if (counter_y >= 132+90+90+hdif && counter_y < 134+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          
                                    if (counter_y >= 134+90+90+hdif && counter_y < 139+90+90+hdif)
                                    begin
                                        if (counter_x >= 366+60+60+xdif && counter_x < 367+60+60+xdif) 
                                        begin
                                            red_b <= 8'h00;      
                                            blue_b <= 8'h00;
                                            green_b <= 8'h00;
                                        end
                                    end
                                     

                        end
                        7'b0000101: begin

                                if (counter_y >= 110+90+90+hdif && counter_y < 112+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+90+hdif && counter_y < 121+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 357+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+90+90+hdif && counter_y < 123+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+90+90+hdif && counter_y < 132+90+90+hdif)
                                        begin
                                            if (counter_x >= 373+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+90+90+hdif && counter_y < 134+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0000110: begin
                            if (counter_y >= 110+90+90+hdif && counter_y < 112+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+90+hdif && counter_y < 121+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 357+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+90+90+hdif && counter_y < 123+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+90+90+hdif && counter_y < 132+90+90+hdif)
                                        begin
                                            if (counter_x >= 373+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end

                                            if (counter_x >= 355+60+60+xdif && counter_x < 357+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+90+90+hdif && counter_y < 134+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0000111: begin
                            if (counter_y >= 110+90+90+hdif && counter_y < 112+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+90+hdif && counter_y < 134+90+90+hdif)
                                        begin
                                            if (counter_x >= 373+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0001000: begin
                            if (counter_y >= 110+90+90+hdif && counter_y < 112+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+90+hdif && counter_y < 121+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 357+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                            if (counter_x >= 373+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+90+90+hdif && counter_y < 123+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+90+90+hdif && counter_y < 132+90+90+hdif)
                                        begin
                                            if (counter_x >= 373+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end

                                            if (counter_x >= 355+60+60+xdif && counter_x < 357+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+90+90+hdif && counter_y < 134+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0001001: begin
                            if (counter_y >= 110+90+90+hdif && counter_y < 112+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+90+hdif && counter_y < 121+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 357+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                            if (counter_x >= 373+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+90+90+hdif && counter_y < 123+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+90+90+hdif && counter_y < 132+90+90+hdif)
                                        begin
                                            if (counter_x >= 373+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+90+90+hdif && counter_y < 134+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end

                        default: begin
                            if (counter_y >= 110+90+90+hdif && counter_y < 112+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+90+hdif && counter_y < 121+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 357+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                            if (counter_x >= 373+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+90+90+hdif && counter_y < 123+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 357+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                            if (counter_x >= 373+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+90+90+hdif && counter_y < 132+90+90+hdif)
                                        begin
                                            if (counter_x >= 373+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end

                                            if (counter_x >= 355+60+60+xdif && counter_x < 357+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+90+90+hdif && counter_y < 134+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+xdif && counter_x < 375+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                            
                        end
                    endcase

				
				
				
                    case (drop_count3)
                        
                        7'b0000001:begin
                            if ((counter_y >= 111+90+90+hdif && counter_y < 133+90+90+hdif))
				            begin
                                if (counter_x >= 363+60+60+60+xdif && counter_x < 366+60+60+60+xdif)
                                    begin 
                                        red_b <= 8'h00;      
                                        blue_b <= 8'h00;
                                        green_b <= 8'h00;
                                    end  
                            end
                        end
                        7'b0000010: begin
                                if (counter_y >= 110+90+90+hdif && counter_y < 112+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+90+hdif && counter_y < 121+90+90+hdif)
                                        begin
                                            if (counter_x >= 373+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+90+90+hdif && counter_y < 123+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+90+90+hdif && counter_y < 132+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 357+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+90+90+hdif && counter_y < 134+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0000011: begin
                                if (counter_y >= 110+90+90+hdif && counter_y < 112+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+90+hdif && counter_y < 121+90+90+hdif)
                                        begin
                                            if (counter_x >= 373+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+90+90+hdif && counter_y < 123+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+90+90+hdif && counter_y < 132+90+90+hdif)
                                        begin
                                            if (counter_x >= 373+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+90+90+hdif && counter_y < 134+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0000100: begin
                             if (counter_y >= 110+90+90+hdif && counter_y < 127+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 357+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 127+90+90+hdif && counter_y < 132+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 357+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                            else if (counter_x >= 366+60+60+60+xdif && counter_x < 367+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                     
                                 if (counter_y >= 132+90+90+hdif && counter_y < 134+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          
                                    if (counter_y >= 134+90+90+hdif && counter_y < 139+90+90+hdif)
                                    begin
                                        if (counter_x >= 366+60+60+60+xdif && counter_x < 367+60+60+60+xdif) 
                                        begin
                                            red_b <= 8'h00;      
                                            blue_b <= 8'h00;
                                            green_b <= 8'h00;
                                        end
                                    end
                                     

                        end
                        7'b0000101: begin

                                if (counter_y >= 110+90+90+hdif && counter_y < 112+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+90+hdif && counter_y < 121+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 357+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+90+90+hdif && counter_y < 123+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+90+90+hdif && counter_y < 132+90+90+hdif)
                                        begin
                                            if (counter_x >= 373+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+90+90+hdif && counter_y < 134+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0000110: begin
                            if (counter_y >= 110+90+90+hdif && counter_y < 112+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+90+hdif && counter_y < 121+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 357+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+90+90+hdif && counter_y < 123+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+90+90+hdif && counter_y < 132+90+90+hdif)
                                        begin
                                            if (counter_x >= 373+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end

                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 357+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+90+90+hdif && counter_y < 134+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0000111: begin
                            if (counter_y >= 110+90+90+hdif && counter_y < 112+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+90+hdif && counter_y < 134+90+90+hdif)
                                        begin
                                            if (counter_x >= 373+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0001000: begin
                            if (counter_y >= 110+90+90+hdif && counter_y < 112+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+90+hdif && counter_y < 121+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 357+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                            if (counter_x >= 373+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+90+90+hdif && counter_y < 123+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+90+90+hdif && counter_y < 132+90+90+hdif)
                                        begin
                                            if (counter_x >= 373+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end

                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 357+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+90+90+hdif && counter_y < 134+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end
                        7'b0001001: begin
                            if (counter_y >= 110+90+90+hdif && counter_y < 112+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+90+hdif && counter_y < 121+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 357+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                            if (counter_x >= 373+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+90+90+hdif && counter_y < 123+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+90+90+hdif && counter_y < 132+90+90+hdif)
                                        begin
                                            if (counter_x >= 373+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+90+90+hdif && counter_y < 134+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                        end

                        default: begin
                            if (counter_y >= 110+90+90+hdif && counter_y < 112+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end

                                          

                                  if (counter_y >= 112+90+90+hdif && counter_y < 121+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 357+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                            if (counter_x >= 373+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 121+90+90+hdif && counter_y < 123+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 357+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                            if (counter_x >= 373+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                       if (counter_y >= 123+90+90+hdif && counter_y < 132+90+90+hdif)
                                        begin
                                            if (counter_x >= 373+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end

                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 357+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                                          
                                    if (counter_y >= 132+90+90+hdif && counter_y < 134+90+90+hdif)
                                        begin
                                            if (counter_x >= 355+60+60+60+xdif && counter_x < 375+60+60+60+xdif) 
                                            begin
                                                red_b <= 8'h00;      
                                                blue_b <= 8'h00;
                                                green_b <= 8'h00;
                                            end
                                        end
                            
                        end
                    endcase

				
				
				
				end
		
		end  			
	assign red_a = (counter_x > 144 && counter_x <= 783 && counter_y > 35 && counter_y <= 514) ? red_b : 8'h00;
	assign blue_a = (counter_x > 144 && counter_x <= 783 && counter_y > 35 && counter_y <= 514) ? blue_b : 8'h00;
	assign green_a = (counter_x > 144 && counter_x <= 783 && counter_y > 35 && counter_y <= 514) ? green_b : 8'h00;
	
	assign sync = 1'b0;
	assign blank = (counter_x > 144 && counter_x <= 783 && counter_y > 35 && counter_y <= 514) ? 1'b1 : 1'b0;
	
endmodule
