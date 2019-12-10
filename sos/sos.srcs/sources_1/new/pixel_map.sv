`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/09/2019 02:21:31 PM
// Design Name: 
// Module Name: pixel_map
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


module pixel_map( input clk,
                  input signed [31:0] distance,
                  input signed [31:0] world_x,
                  input signed [31:0] world_y,
                  input signed [31:0] world_z,
   
                  output logic [24:0] spixel_x,
                  output logic [24:0] spixel_y,
                  output logic [24:0] tpixel_x,
                  output logic [24:0] tpixel_y);
                  

   
  logic [39:0] x_top;
  logic x_top_valid;
  
  logic signed [15:0] rounded_world_x;
  logic signed [15:0] rounded_world_y;
  logic signed [15:0] rounded_world_z;
  
  assign rounded_world_x = world_x[31:16];
  assign rounded_world_y = world_y[31:16];
  assign rounded_world_z = world_z[31:16];
  
 // div_gen_0 x_coor_top (.aclk(clk),
   //                     .s_axis_divisor_tdata({17'b0, rounded_world_x[14:0]}),
     //                   .s_axis_divisor_tvalid(1'b1),
       //                 .s_axis_dividend_tdata(8'd10),
         //               .s_axis_dividend_tvalid(1'b1),
           //             .m_axis_dout_tdata(x_top),
             //           .m_axis_dout_tvalid(x_top_valid));
  
 // logic [39:0] y_top;
 // logic y_top_valid;
  
  //div_gen_0 y_coor_top (.aclk(clk),
    //                    .s_axis_divisor_tdata({17'b0, rounded_world_z[14:0]}),
      //                  .s_axis_divisor_tvalid(1'b1),
        //                .s_axis_dividend_tdata(8'd10),
          //              .s_axis_dividend_tvalid(1'b1),
            //            .m_axis_dout_tdata(y_top),
              //          .m_axis_dout_tvalid(y_top_valid));
                        
  //logic [39:0] x_side;
  //logic x_side_valid;
  
  //div_gen_0 x_coor_side (.aclk(clk),
          //              .s_axis_divisor_tdata({17'b0, rounded_world_z[14:0]}),
        //                .s_axis_divisor_tvalid(1'b1),
      //                  .s_axis_dividend_tdata(8'd7),
       //                 .s_axis_dividend_tvalid(1'b1),
     //                   .m_axis_dout_tdata(x_side),
    //                    .m_axis_dout_tvalid(x_side_valid));
  
  //logic [39:0] y_side;
  //logic y_side_valid;
  
 // div_gen_0 y_coor_side (.aclk(clk),
//                        .s_axis_divisor_tdata({17'b0, rounded_world_y[14:0]}),
//                        .s_axis_divisor_tvalid(1'b1), 
//                        .s_axis_dividend_tdata(8'd7),
//                        .s_axis_dividend_tvalid(1'b1),
//                        .m_axis_dout_tdata(y_side),
 //                       .m_axis_dout_tvalid(y_side_valid));
                        
   
//   logic [32:0] x_side_feed;
//   logic [32:0] y_side_feed;
//   logic [32:0] x_top_feed;
//   logic [32:0] y_top_feed;

   logic [15:0] tneg_x;
   assign tneg_x = {rounded_world_x[15], 14'b0};
   logic [15:0] tneg_y;
   assign tneg_y = {rounded_world_z[15], 14'b0};
   
   logic [15:0] sneg_x;
   assign sneg_x = {rounded_world_z[15], 14'b0};
   logic [15:0] sneg_y;
   assign sneg_y = {rounded_world_z[15], 14'b0};
   
   always_ff @(posedge clk) begin
                tpixel_x <= 25'd480 - (tneg_x >> 3) + (rounded_world_x[14:0]>>3);
                tpixel_y <= 25'd250 + (tneg_y >> 3) - (rounded_world_x[14:0] >>3);
                spixel_x <= 25'd300 - (sneg_x >> 3) + (rounded_world_z[14:0] >>3);
                spixel_y <= 25'd360 - (sneg_y >> 3) + (rounded_world_z[14:0] >>3); 
       end
endmodule
