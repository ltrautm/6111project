`timescale 1ns / 1ps
module distance_tb;
    logic clk;
    logic rst;
//    logic trigger;
    logic [31:0] x1;
    logic [31:0] y1;
    logic [31:0] x2;
    logic [31:0] y2;
//    logic [9:0] servo_angle;
    logic [31:0] distance;
    logic [31:0] world_x;
    logic [31:0] world_y;
    logic [31:0] world_z;

    distance my_dist(
        // inputs
        .clk_in(clk),
        .rst_in(rst),
//        .start(trigger),
        .x1(x1),
        .y1(y1),
        .x2(x2),
        .y2(y2),
//        .servo_angle(servo_angle),
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
//        trigger = 0;
        x1 = {16'd253, 16'd0};
        y1 = {16'd131, 16'd0};
        
        x2 = {16'd53, 16'd0};
        y2 = {16'd113, 16'd0};


        #50000;  //as you run it...should see 10101010 show up ont eh data out line
     end
endmodule