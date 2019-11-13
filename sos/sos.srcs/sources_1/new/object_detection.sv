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

module object_detection (input clk_100mhz,
                         input sw[0],
                         input [239:0][319:0] image, 
                         output [2:0][9:0] edges
                         );
    
    logic [2:0][319:0] buffer_1;
    logic [2:0][319:0] buffer_2;
    
    hue_thresholding thresh(.clk(clk_100mhz), .image(image), .buffer(buffer_1));
    erosion eroding(.clk(clk_100mhz), .erode(sw[0]), .buffer(buffer_1), .eroded(buffer_2));
                         
                         
endmodule

module hue_thresholding (input clk,
                         input [239:0][319:0] image,
                         output [2:0][319:0] buffer
                         );
                         
    logic [8:0] y1 = 9'd0;
    logic [8:0] y2 = 9'd2;
    
    logic [239:0][319:0] image_store;
    assign image_store = image;
    
    always_ff @(posedge clk) begin
        buffer <= image_store [y2:y1][319:0];
        y1 <= y1 + 9'd3;
        y2 <= y2 + 9'd3;
        end
        
module erosion(input clk,
               input erode,
               input [2:0][239:0] buffer,
               output [2:0][239:0] eroded
    );
    
    
endmodule
