`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
// Updated 8/10/2019 Lab 3
// Updated 8/12/2018 V2.lab5c
// Create Date: 10/1/2015 V1.0
// Design Name:
// Module Name: labkit
//
//////////////////////////////////////////////////////////////////////////////////

module top_level(
   input clk_100mhz,
//   input[15:0] sw,
//   input btnc, btnu, btnl, btnr, btnd,
//   input [7:0] ja,
//   input [2:0] jb,
//   output   jbclk,
//   input [2:0] jd,
//   output   jdclk,
//   output[3:0] vga_r,
//   output[3:0] vga_b,
//   output[3:0] vga_g,
//   output vga_hs,
//   output vga_vs,
//   output led16_b, led16_g, led16_r,
//   output led17_b, led17_g, led17_r,
//   output[15:0] led,
//   output ca, cb, cc, cd, ce, cf, cg, dp,  // segments a-g, dp
//   output[7:0] an,    // Display location 0-7
   output logic [1:0] jc //outputting the serial here
   );
   
    
    // create 65mhz system clock, happens to match 1024 x 768 XVGA timing
    logic clk_65mhz;
    clk_wiz_lab3 clkdivider(.clk_in1(clk_100mhz), .clk_out1(clk_65mhz));
    
    
    
    logic [7:0] myang = 8'd90;
    
    servo my_servo(.clk(clk_100mhz), .angle(myang), .servo_pulse(jc[0]));    
    
//    always_ff @(posedge clk_65mhz) begin
        
            
//    end

endmodule


