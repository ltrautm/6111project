//from ryan branch

`timescale 1ns / 1ps

module object_detection (input clk,
                         input dilate,
                         input erode, //switch operated mechanism that allows us to see either erosion or dilation---temporary testing input
                         input [1:0] thresholds, //switch-based thresholding alternators
                         input [23:0] pixel_in, //pixel that goes in 
                         output [9:0] centroid_x,
                         output [9:0] centroid_y,
                         output logic [11:0] pixel_out
                         //output done, //makes display module wait until calulation is done before displaying--for testing only
                        // output [11:0] image_out [239:0][319:0] //displays image of choice--testing purposes only
                         );

    logic [23:0] pixel; //pixel that goes in module
    
    logic thresh_out; //bit leaving hue thresholding
    logic erosion_out; //bit leaving erosion
    logic dilation_out; //bit leaving dilation
    
    logic [9:0] dilate_x; // intermediates
    logic [9:0] dilate_y;
    
    logic [7:0] hue; //hsv 
    logic [7:0] sat;
    logic [7:0] val;
    
    rgb2hsv convert(.clock(clk), .reset(0), .r(pixel[23:16]), .g(pixel[17:8]), .b(pixel[7:0]), .h(hue), .s(sat), .v(val));
    hue_thresholding thresh(.clk(clk), .threshes(thresholds), .hue_val(hue), .val_val(val), .thresh_bit(thresh_out));
    erosion eroding(.clk(clk), .bit_in(thresh_out), .eroded_bit(erosion_out));
    dilation dilating(.clk(clk), .bit_in(erosion_out), .dilated_bit(dilation_out), .xcount(dilate_x), .ycount(dilate_y));
    
    always_ff @(posedge clk) begin
        pixel <= pixel_in;
        if (dilate) begin
            if (dilation_out == 1'b1) begin
                pixel_out <= 12'b1111_1111_1111;
            end else if (dilation_out == 1'b0) begin
                pixel_out <= 12'b0000_0000_0000;
            end
        end else if (erode) begin
            if (erosion_out == 1'b1) begin
                pixel_out <= 12'b1111_1111_1111;
            end else if (erosion_out == 1'b0) begin
                pixel_out <= 12'b0000_0000_0000;
            end
        end else begin
            if (thresh_out == 1'b1) begin
                pixel_out <= 12'b1111_1111_1111;
            end else if (thresh_out == 1'b0) begin
                pixel_out <= 12'b0000_0000_0000;
            end 
        end
    end
                         
                         
endmodule

module hue_thresholding (input clk,
                         input [1:0] threshes,
                         input [7:0] hue_val,
                         input [7:0] val_val,
                         output logic thresh_bit
                         );
     
      always_ff @(posedge clk) begin
            if (threshes == 2'b00) begin
                if (hue_val > 8'd167 || hue_val < 8'd165) begin
                    thresh_bit <= 0;
                end else begin
                    thresh_bit <= 1;
                end
            end else if (threshes == 2'b01) begin
                if ((hue_val > 8'd169 || hue_val < 8'd167)) begin
                    thresh_bit <= 0;
                end else begin
                    thresh_bit <= 1;
                end
            end else if (threshes == 2'b10) begin
                if (hue_val > 8'd172 || hue_val < 8'd169) begin
                    thresh_bit <= 0;
                end else begin
                    thresh_bit <= 1;
                end
            end else if (threshes == 2'b11) begin
                if (hue_val > 8'd172 || hue_val < 8'd165) begin
                    thresh_bit <= 0;
                end else begin
                    thresh_bit <= 1;
                end
            end
        end
endmodule        

module erosion(input clk,
               input bit_in,
               output logic eroded_bit
    );
    
    logic [9:0] ycounter;
    logic [9:0] xcounter;
    logic [321:0] kernel_workspace; //workspace register
    logic erosion_trigger; //tells the module when to start eroding
    
    
    initial begin
        xcounter = 10'd1;
        ycounter = 10'd0;
        erosion_trigger = 1'b0;
        kernel_workspace[321] = 1'b1;
        kernel_workspace[0] = 1'b1;
     end
    
    logic kernel; // result of erosion
    assign kernel = kernel_workspace[xcounter-5] && kernel_workspace[xcounter-4] && kernel_workspace[xcounter-3]
     && kernel_workspace[xcounter-2] && kernel_workspace[xcounter-1];
    
    always_ff @(posedge clk) begin
        if (ycounter == 10'd239) begin
            ycounter <= 10'd0;
        end else if (xcounter == 10'd320) begin
            xcounter <= 10'd1;
            ycounter <= ycounter + 1'd1;
        end else if (xcounter < 10'd320) begin
            xcounter <= xcounter + 1'd1;
            
        end if (xcounter == 10'd4) begin
            erosion_trigger <= 1;
        end if (erosion_trigger) begin
            eroded_bit <= kernel;
        end
        
        kernel_workspace[xcounter] <= bit_in;
    end
 endmodule
    
module dilation(input clk,
                input bit_in,
                output logic dilated_bit,
                output logic [9:0] xcount,
                output logic [9:0] ycount
                );
    
    logic [321:0] kernel_workspace; //workspace register
 
    logic dilation_trigger; //tells the module when to start dilating
    
    logic kernel;
    assign kernel = kernel_workspace[xcount-5] || kernel_workspace[xcount-4] || kernel_workspace[xcount-3]
     || kernel_workspace[xcount-2] || kernel_workspace[xcount-1];

    initial begin
        xcount = 10'd1;
        ycount = 10'd0;
        kernel_workspace[0] = 1'b1;
        kernel_workspace[321] = 1'b1;
        dilation_trigger = 1'b0;
     end
     
    always_ff @(posedge clk) begin
        if (ycount == 10'd239) begin
            ycount <= 10'd0;
        end else if (xcount == 10'd320) begin
            xcount <= 10'd1;
            ycount <= ycount + 1'd1;
        end else if (xcount < 10'd320) begin
            xcount <= xcount + 1;
            
        end if (xcount == 10'd4) begin
            dilation_trigger <= 1;
        end if (dilation_trigger) begin
            dilated_bit <= kernel;
        end
        
        kernel_workspace[xcount] <= bit_in;
    end
 endmodule
 
// module localizer( input clk,
//                   input [9:0] xcount,
//                   input [9:0] ycount,
//                   output logic [9:0] x_center,
//                   output logic [9:0] y_center
//                   );

// logic x_acc



//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Kevin Zheng Class of 2012 
//           Dept of Electrical Engineering &  Computer Science
// 
// Create Date:    18:45:01 11/10/2010 
// Design Name: 
// Module Name:    rgb2hsv 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module rgb2hsv(clock, reset, r, g, b, h, s, v);
		input wire clock;
		input wire reset;
		input wire [7:0] r;
		input wire [7:0] g;
		input wire [7:0] b;
		output reg [7:0] h;
		output reg [7:0] s;
		output reg [7:0] v;
		reg [7:0] my_r_delay1, my_g_delay1, my_b_delay1;
		reg [7:0] my_r_delay2, my_g_delay2, my_b_delay2;
		reg [7:0] my_r, my_g, my_b;
		reg [7:0] min, max, delta;
		reg [15:0] s_top;
		reg [15:0] s_bottom;
		reg [15:0] h_top;
		reg [15:0] h_bottom;
		wire [15:0] s_quotient;
		wire [15:0] s_remainder;
		wire s_rfd;
		wire [15:0] h_quotient;
		wire [15:0] h_remainder;
		wire h_rfd;
		reg [7:0] v_delay [19:0];
		reg [18:0] h_negative;
		reg [15:0] h_add [18:0];
		reg [4:0] i;
		// Clocks 4-18: perform all the divisions
		//the s_divider (16/16) has delay 18
		//the hue_div (16/16) has delay 18

		divider hue_div1(
		.clk(clock),
		.dividend(s_top),
		.divider(s_bottom),
		.quotient(s_quotient),
	        // note: the "fractional" output was originally named "remainder" in this
		// file -- it seems coregen will name this output "fractional" even if
		// you didn't select the remainder type as fractional.
		.remainder(s_remainder),
		.ready(s_rfd)
		);
		divider hue_div2(
		.clk(clock),
		.dividend(h_top),
		.divider(h_bottom),
		.quotient(h_quotient),
		.remainder(h_remainder),
		.ready(h_rfd)
		);
		always @ (posedge clock) begin
		
			// Clock 1: latch the inputs (always positive)
			{my_r, my_g, my_b} <= {r, g, b};
			
			// Clock 2: compute min, max
			{my_r_delay1, my_g_delay1, my_b_delay1} <= {my_r, my_g, my_b};
			
			if((my_r >= my_g) && (my_r >= my_b)) //(B,S,S)
				max <= my_r;
			else if((my_g >= my_r) && (my_g >= my_b)) //(S,B,S)
				max <= my_g;
			else	max <= my_b;
			
			if((my_r <= my_g) && (my_r <= my_b)) //(S,B,B)
				min <= my_r;
			else if((my_g <= my_r) && (my_g <= my_b)) //(B,S,B)
				min <= my_g;
			else
				min <= my_b;
				
			// Clock 3: compute the delta
			{my_r_delay2, my_g_delay2, my_b_delay2} <= {my_r_delay1, my_g_delay1, my_b_delay1};
			v_delay[0] <= max;
			delta <= max - min;
			
			// Clock 4: compute the top and bottom of whatever divisions we need to do
			s_top <= 8'd255 * delta;
			s_bottom <= (v_delay[0]>0)?{8'd0, v_delay[0]}: 16'd1;
			
			
			if(my_r_delay2 == v_delay[0]) begin
				h_top <= (my_g_delay2 >= my_b_delay2)?(my_g_delay2 - my_b_delay2) * 8'd255:(my_b_delay2 - my_g_delay2) * 8'd255;
				h_negative[0] <= (my_g_delay2 >= my_b_delay2)?0:1;
				h_add[0] <= 16'd0;
			end 
			else if(my_g_delay2 == v_delay[0]) begin
				h_top <= (my_b_delay2 >= my_r_delay2)?(my_b_delay2 - my_r_delay2) * 8'd255:(my_r_delay2 - my_b_delay2) * 8'd255;
				h_negative[0] <= (my_b_delay2 >= my_r_delay2)?0:1;
				h_add[0] <= 16'd85;
			end 
			else if(my_b_delay2 == v_delay[0]) begin
				h_top <= (my_r_delay2 >= my_g_delay2)?(my_r_delay2 - my_g_delay2) * 8'd255:(my_g_delay2 - my_r_delay2) * 8'd255;
				h_negative[0] <= (my_r_delay2 >= my_g_delay2)?0:1;
				h_add[0] <= 16'd170;
			end
			
			h_bottom <= (delta > 0)?delta * 8'd6:16'd6;
		
			
			//delay the v and h_negative signals 18 times
			for(i=1; i<19; i=i+1) begin
				v_delay[i] <= v_delay[i-1];
				h_negative[i] <= h_negative[i-1];
				h_add[i] <= h_add[i-1];
			end
		
			v_delay[19] <= v_delay[18];
			//Clock 22: compute the final value of h
			//depending on the value of h_delay[18], we need to subtract 255 from it to make it come back around the circle
			if(h_negative[18] && (h_quotient > h_add[18])) begin
				h <= 8'd255 - h_quotient[7:0] + h_add[18];
			end 
			else if(h_negative[18]) begin
				h <= h_add[18] - h_quotient[7:0];
			end 
			else begin
				h <= h_quotient[7:0] + h_add[18];
			end
			
			//pass out s and v straight
			s <= s_quotient;
			v <= v_delay[19];
		end
endmodule

// The divider module divides one number by another. It
// produces a signal named "ready" when the quotient output
// is ready, and takes a signal named "start" to indicate
// the the input dividend and divider is ready.
// sign -- 0 for unsigned, 1 for twos complement

// It uses a simple restoring divide algorithm.
// http://en.wikipedia.org/wiki/Division_(digital)#Restoring_division
// 
// Author Logan Williams, updated 11/25/2018 gph

module divider #(parameter WIDTH = 8) 
  (input clk, sign, start,
   input [WIDTH-1:0] dividend, 
   input [WIDTH-1:0] divider,
   output reg [WIDTH-1:0] quotient,
   output [WIDTH-1:0] remainder,
   output ready);

   reg [WIDTH-1:0]  quotient_temp;
   reg [WIDTH*2-1:0] dividend_copy, divider_copy, diff;
   reg negative_output;
   
   assign remainder = (!negative_output) ?
             dividend_copy[WIDTH-1:0] : ~dividend_copy[WIDTH-1:0] + 1'b1;

   reg [5:0] a_bit = 0;
   reg del_ready = 1;
   assign ready = (a_bit==0) & ~del_ready;

   wire [WIDTH-2:0] zeros = 0;
   initial a_bit = 0;
   initial negative_output = 0;
   always @( posedge clk ) begin
      del_ready <= (a_bit==0);
      if( start ) begin

         a_bit = WIDTH;
         quotient = 0;
         quotient_temp = 0;
         dividend_copy = (!sign || !dividend[WIDTH-1]) ?
                         {1'b0,zeros,dividend} :  
                         {1'b0,zeros,~dividend + 1'b1};
         divider_copy = (!sign || !divider[WIDTH-1]) ?
			 {1'b0,divider,zeros} :
			 {1'b0,~divider + 1'b1,zeros};

         negative_output = sign &&
                           ((divider[WIDTH-1] && !dividend[WIDTH-1])
                            ||(!divider[WIDTH-1] && dividend[WIDTH-1]));
       end
      else if ( a_bit > 0 ) begin
         diff = dividend_copy - divider_copy;
         quotient_temp = quotient_temp << 1;
         if( !diff[WIDTH*2-1] ) begin
            dividend_copy = diff;
            quotient_temp[0] = 1'd1;
         end
         quotient = (!negative_output) ?
                    quotient_temp :
                    ~quotient_temp + 1'b1;
         divider_copy = divider_copy >> 1;
         a_bit = a_bit - 1'b1;
      end
   end
endmodule