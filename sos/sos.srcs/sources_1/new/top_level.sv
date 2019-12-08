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
   output logic jd4 //outputting the serial here
   );
   
//    logic clk_65mhz;
    // create 65mhz system clock, happens to match 1024 x 768 XVGA timing
//    clk_wiz_lab3 clkdivider(.clk_in1(clk_100mhz), .clk_out1(clk_65mhz));
    
    
    logic [7:0] myang = 8'd255;
    
    logic clk_50mhz = 1'b0;
    
    logic county = 1'b0;
    always_ff @(posedge clk_100mhz) begin
        if (county == 1'b1) begin
            county <= 1'b0;
            clk_50mhz <= 1'b0;
        end else begin
            county <= 1'b1;
            clk_50mhz <= 1'b1; 
        end
    
    end
        
//    clk_wiz_0 clkmulti(.clk_in1(clk_100mhz), .clk_out1(clk_50mhz));


    //code to make servo sweep
    logic [27:0] hz_count = 28'b0;
    logic mydir = 0; //direction of the servo, 0 is left, 1 is right
    always_ff @(posedge clk_100mhz) begin
        if (hz_count == 28'd50000000) begin
            hz_count <= 28'b0;
            
            if (myang >= 8'd250) mydir <= 0;
            else if (myang <= 8'd5) mydir <= 1;
            
            if (mydir == 0) myang <= myang-28'd5;
            else if (mydir == 1) myang <= myang +28'd5;
        end else begin
            hz_count <= hz_count+28'd1;
        end
    
    end


    servo_controller mysc(.clk(clk_50mhz),
                            .rst(1'b0),
                            .position(myang),
                            .servo(jd4));
    
//    servo my_servo(.clk(clk_100mhz), .angle(myang), .servo_pulse(jc[0]));    
    
//    always_ff @(posedge clk_65mhz) begin
        
            
//    end

endmodule


