`timescale 1ns / 1ps
module divider_tb;
    logic clk;
    logic [16:0] number;
    logic [16:0] divisor;

    get_divisor my_div(
        // inputs
        .clk_in(clk),
        .number(number),
        .divisor(divisor)
      );
        
        
    always begin
        #5;
        clk = !clk;
     end

     initial begin
        clk = 0;

        number = 15;


        #50000;  //as you run it...should see 10101010 show up ont eh data out line
     end
endmodule