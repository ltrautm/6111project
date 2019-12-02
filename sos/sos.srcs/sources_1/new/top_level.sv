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
   output logic [1:0] jc //outputting the serial here
   );
   
    logic clk_65mhz;
    // create 65mhz system clock, happens to match 1024 x 768 XVGA timing
    clk_wiz_lab3 clkdivider(.clk_in1(clk_100mhz), .clk_out1(clk_65mhz));
    
    
    logic [7:0] myang = 8'd90;
    
    servo my_servo(.clk(clk_100mhz), .angle(myang), .servo_pulse(jc[0]));    
    
//    always_ff @(posedge clk_65mhz) begin
        
            
//    end

endmodule


