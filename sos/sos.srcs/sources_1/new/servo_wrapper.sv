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

module servo_wrapper(
   input clk, //200mhz
   output logic js //outputting the serial here
   );
   
//    logic clk_65mhz;
    // create 65mhz system clock, happens to match 1024 x 768 XVGA timing
//    clk_wiz_lab3 clkdivider(.clk_in1(clk_100mhz), .clk_out1(clk_65mhz));
    
    
    logic [7:0] myang = 8'd255;
    
    logic clk_50mhz = 1'b0;
    
    logic [2:0]  county = 3'b0;
    always_ff @(posedge clk) begin
        if (county == 3'd4) begin
            county <= 1'b0;
            clk_50mhz <= 1'b1;
        end else begin
            county <= county + 4'd1;
            clk_50mhz <= 1'b0; 
        end
    
    end
        
//    clk_wiz_0 clkmulti(.clk_in1(clk_100mhz), .clk_out1(clk_50mhz));


    //code to make servo sweep
    logic [27:0] hz_count = 28'b0;
    logic mydir = 0; //direction of the servo, 0 is left, 1 is right
    always_ff @(posedge clk) begin
        if (hz_count == 28'd100000000) begin
            hz_count <= 28'b0;
            
            if (myang >= 8'd250) mydir <= 0;
            else if (myang <= 8'd5) mydir <= 5;
            
            if (mydir == 0) myang <= myang-28'd5;
            else if (mydir == 1) myang <= myang +28'd5;
        end else begin
            hz_count <= hz_count+28'b1;
        end
    
    end


    servo_controller mysc(.clk(clk),
                            .rst(1'b0),
                            .position(myang),
                            .servo(js));
    
//    servo my_servo(.clk(clk_100mhz), .angle(myang), .servo_pulse(jc[0]));    
    
//    always_ff @(posedge clk_65mhz) begin
        
            
//    end

endmodule

