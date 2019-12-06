`timescale 1ns / 1ps
module distance_calculation_tb;
    logic clk;
    logic rst;
    logic trigger;
    logic[7:0] val;
    logic [15:0] x1;
    logic [15:0] y1;
    logic [15:0] x2;
    logic [15:0] y2;
    logic [9:0] servo_angle;
    logic [15:0] distance;
    logic [15:0] world_x;
    logic [15:0] world_y;
    logic [15:0] world_z;

    distance_calculation my_dist(
        // inputs
        .clk_in(clk),
        .rst_in(rst),
        .start(trigger),
        .x1(x1),
        .y1(y1),
        .x2(x2),
        .y2(y2),
        .servo_angle(servo_angle),
        // outputs
        .distance(distance),
        .world_x(world_x),
        .world_y(world_y),
        .world_z(world_z)
        );
        
        
    always begin
        #5;
        clk = !clk;
     end

     initial begin
        clk = 0;
        rst = 0;
        trigger = 0;
        x1 = 253;
        y1 = 131;
        
        x2 = 53;
        y2 = 113;


        #50000;  //as you run it...should see 10101010 show up ont eh data out line
     end
endmodule