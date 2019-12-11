`timescale 1ns / 1ps
module distance_tb;
    logic clk;
    logic rst;
//    logic trigger;
    logic [24:0] x1;
    logic [24:0] y1;
    logic [24:0] x2;
    logic [24:0] y2;
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
//        x1 = 25'd253;
//        y1 = 25'd131;
        
//        x2 = 25'd53;
//        y2 = 25'd113;
//        #5;
        // TRIAL 1
        x1 = 25'hd3;
        y1 = 25'h78;
        
        x2 = 25'h25;
        y2 = 25'h62;
        
        #5000
        
        x1 = 25'hE6;
        y1 = 25'h75;
        
        x2 = 25'hA7;
        y2 = 25'h5d;
        
        #5000
        
        x1 = 25'hd8;
        y1 = 25'h62;
        
        x2 = 25'h74;
        y2 = 25'h4F;
        
        #5000
        
        x1 = 25'hd0;
        y1 = 25'h83;
        
        x2 = 25'h68;
        y2 = 25'h6E;
        //
        
        # 5000
        //TRIAL 2
        x1 = 25'hAb;
        y1 = 25'h88;
        
        x2 = 25'hCE;
        y2 = 25'h7d;
        
        #5000
        
        x1 = 25'hd6;
        y1 = 25'h54;
        
        x2 = 25'h7E;
        y2 = 25'h47;
        
        #5000
        
        x1 = 25'hE6;
        y1 = 25'h75;
        
        x2 = 25'h85;
        y2 = 25'h66;
        
        #5000
        
        x1 = 25'hC9;
        y1 = 25'h63;
        
        x2 = 25'h5E;
        y2 = 25'h55;       
        
//        #5000
//        x1 = 25'd267;
//        y1 = 25'd115;
        
//        x2 = 25'd76;
//        y2 = 25'd97;
        #50000;  //as you run it...should see 10101010 show up ont eh data out line
     end
endmodule