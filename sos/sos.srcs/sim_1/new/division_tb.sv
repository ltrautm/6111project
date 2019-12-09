`timescale 1ns / 1ps
module divsion_tb;
    logic clk;
    logic signed [31:0] dividend;
    logic signed [31:0] divisor;
    logic signed [31:0] quotient;

    my_division my_div(
        // inputs
        .clk_in(clk),
    .dividend(dividend),
    .divisor(divisor),
    .valid_signal(1),
    .quotient(quotient)
      );
        
        
    always begin
        #5;
        clk = !clk;
     end

     initial begin
        clk = 0;

        dividend = {16'd15, 16'd0};
        divisor = {16'd2, 16'd0}; 


        #50000;  //as you run it...should see 10101010 show up ont eh data out line
     end
endmodule