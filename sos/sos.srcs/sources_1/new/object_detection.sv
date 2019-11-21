`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/06/2019 02:36:44 PM
// Design Name: 
// Module Name: object_detection
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module object_detection (input clk,
                         input select, //switch operated mechanism that allows us to see either erosion or dilation---temporary testing input
                         input [11:0] pixel_in, //pixel that goes in 
                         output [9:0] radius,
                         output [9:0] centroid_x,
                         output [9:0] centroid_y,
                         output logic [11:0] pixel_out
                         //output done, //makes display module wait until calulation is done before displaying--for testing only
                        // output [11:0] image_out [239:0][319:0] //displays image of choice--testing purposes only
                         );

    logic [11:0] pixel; //pixel that goes in module
    
    logic thresh_out; //bit leaving hue thresholding
    logic erosion_out; //bit leaving erosion
    logic dilation_out; //bit leaving dilation
    
    logic [9:0] erode_x;
    logic [9:0] erode_y;
    logic [9:0] dilate_x;
    logic [9:0] dilate_y;
    
    hue_thresholding thresh(.clk(clk),.pixel_in(pixel), .thresh_bit(thresh_out));
    erosion eroding(.clk(clk), .bit_in(thresh_out), .eroded_bit(erosion_out), .xcounter(erode_x), .ycounter(erode_y));
//    dilation dilating(.clk(clk), .bit_in(erosion_out), .eroxcount(erode_x), .eroycount(erode_y), 
//        .dilated_bit(dilation_out), .xcounter(dilate_x), .ycounter(dilate_y));
    
    always_ff @(posedge clk) begin
        pixel <= pixel_in;
        if (select == 2'b10) begin
            if (dilation_out == 1) begin
                pixel_out <= 12'b1111_1111_1111;
            end else if (dilation_out == 0) begin
                pixel_out <= 12'b0000_0000_0000;
            end
        end else if (select == 2'b01) begin
            if (erosion_out == 1) begin
                pixel_out <= 12'b1111_1111_1111;
            end else if (erosion_out == 0) begin
                pixel_out <= 12'b0000_0000_0000;
            end
        end
            
    end
                         
                         
endmodule

module hue_thresholding (input clk,
                         input [11:0] pixel_in,
                         output logic thresh_bit
                         );
      
      always_ff @(posedge clk) begin
            if (pixel_in == 12'b0000_0000_0000) begin
                thresh_bit <= 0;
            end else if (pixel_in == 12'b1111_1111_1111) begin
                thresh_bit <= 1;
            end
        end
endmodule        

module erosion(input clk,
               input bit_in,
               output logic eroded_bit,
               output logic [9:0] ycounter,
               output logic [9:0] xcounter
    );
    
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
    assign kernel = kernel_workspace[xcounter-3] && kernel_workspace[xcounter-2] && kernel_workspace[xcounter-1];
    
    always_ff @(posedge clk) begin
        if (ycounter == 10'd239) begin
            ycounter <= 10'd0;
        end else if (xcounter == 10'd320) begin
            xcounter <= 10'd1;
            ycounter <= ycounter + 1'd1;
        end else if (xcounter < 10'd320) begin
            xcounter <= xcounter + 1'd1;
            
        end if (xcounter == 10'd2) begin
            erosion_trigger <= 1;
        end if (erosion_trigger) begin
            eroded_bit <= kernel;
        end
        
        kernel_workspace[xcounter] <= bit_in;
    end
 endmodule
    
//    always_ff @(posedge clk) begin
//        if (ycounter == 10'd240) begin
//            ycounter <= 10'd0;
//        end else if (xcounter == 10'd320) begin
//            xcounter <= 10'd0;
//            ycounter <= ycounter + 1;
            
//        end if (wksp_counter == 2'd2) begin
//            erosion_trigger <= 1;
//            wksp_counter <= 2'd2;
//        end else if (wksp_counter < 2'd2) begin
//            wksp_counter <= wksp_counter + 1;
            
//        end if (erosion_trigger) begin
//            eroded_bit <= kernel;
//            kernel_window[0] <= kernel_window[1];
//            kernel_window[1] <= kernel_window[2];
//        end
        
//        kernel_window[wksp_counter] <= bit_in;
       

//    logic [2:0][321:0] kernel_workspace;
//    logic [9:0] wsp_xcounter;
//    logic [2:0] wsp_ycounter;
    
//    logic kernel; //3 x 3 square
//    assign kernel = (kernel_workspace[wsp_ycounter-1][wsp_xcounter-1] && kernel_workspace[wsp_ycounter-1][wsp_xcounter] 
//            && kernel_workspace[wsp_ycounter-1][wsp_xcounter + 1] && kernel_workspace[wsp_ycounter][wsp_xcounter-1] 
//            && kernel_workspace[wsp_ycounter][wsp_xcounter+1] && kernel_workspace[wsp_ycounter+1][wsp_xcounter-1] 
//            && kernel_workspace[wsp_ycounter+1][wsp_xcounter] && kernel_workspace[wsp_ycounter+1][wsp_xcounter+1]);
            
//    //kernel is one if all surrounding values are one
    
//    logic kernel_go; //tells kernel to start analysis
    
//    initial begin
//        kernel_go = 0;
//        wsp_xcounter = 10'b1;
//        wsp_ycounter = 2'd1;
//        kernel_workspace[0] = 322'b0;
//        kernel_workspace[0][0] = 1'b0;
//        kernel_workspace[1][0] = 1'b0;
//        kernel_workspace[2][0] = 1'b0; 
//        kernel_workspace[0][321] = 1'b0;
//        kernel_workspace[1][321] = 1'b0;
//        kernel_workspace[2][321] = 1'b0;
//     end
    
    
//    always_ff @(posedge clk) begin
//        if (wsp_ycounter == 2'd3 && wsp_xcounter == 10'd321) begin
//            kernel_go <= 1;
//            wsp_ycounter <= 2'd2;
//            wsp_xcounter <= 10'd1;
//            kernel_workspace[0] <= kernel_workspace[1];
//            kernel_workspace[1] <= kernel_workspace[2];
//        end else begin
//            if (wsp_xcounter == 10'd321) begin
//                wsp_ycounter <= wsp_ycounter + 1;
//                wsp_xcounter <= 10'd1;
//            end else begin
//                kernel_workspace [wsp_ycounter][wsp_xcounter] <= bit_in;
//                wsp_xcounter <= wsp_xcounter + 1;
//            end
//        end if (kernel_go) begin
//            if (kernel_workspace[1][wsp_xcounter] == 1'b0) begin
//                eroded_bit <= 0;
//            end else if (kernel_workspace[wsp_ycounter][wsp_xcounter] == 1'b1) begin
//                eroded_bit <= kernel;   
//            end
//        end
//    end
  
//module dilation(input clk,
//                input bit_in,
//                input [9:0] eroxcount,
//                input [9:0] eroycount,
//                output logic dilated_bit,
//                output logic [9:0] xcounter,
//                output logic [9:0] ycounter
//                );
    
//    logic [321:0] kernel_workspace; //workspace register
//    assign ycounter = eroycount; //counts the location of the pointer
//    assign xcounter = eroxcount;
//    logic dilation_trigger; //tells the module when to start dilating
    
//    logic kernel = kernel_workspace[xcounter-3] | kernel_workspace[xcounter-1] | kernel_workspace[xcounter-2];

//    initial begin
//        kernel_workspace[0] = 0;
//        kernel_workspace[321] = 0;
//        dilation_trigger = 0;
//     end
     
//    always_ff @(posedge clk) begin
//        if (ycounter == 10'd240) begin
//            ycounter <= 10'd0;
//        end else if (xcounter == 10'd321) begin
//            xcounter <= 10'd1;
//            ycounter <= ycounter + 1;
            
//        end else if (xcounter == 10'd2) begin
//            dilation_trigger <= 1;
//        end if (dilation_trigger) begin
//            dilated_bit <= kernel;
            
//        end if (xcounter <= 10'd320) begin
//            kernel_workspace[xcounter] <= bit_in;
//            xcounter <= xcounter + 1;
//        end
//    end
// endmodule
