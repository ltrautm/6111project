module distance_calculation(
    input clk_in,
    input rst_in,
    input start,
    input [15:0] x1,
    input [15:0] y1,
    input [15:0] x2,
    input [15:0] y2,
    input [9:0] servo_angle,
    output logic [15:0] distance,
    output logic [15:0] world_x,
    output logic [15:0] world_y,
    output logic [15:0] world_z
    );
    
    // 16 bits to decimal: 2^16 = 65536
    parameter P_inv11 = 'd0;
    parameter P_inv12 = 'd0;
    parameter P_inv13 = 'd0;
    parameter P_inv21 = 'd0;
    parameter P_inv22 = 'd0;
    parameter P_inv23 = 'd0;
    parameter P_inv31 = 'd0;
    parameter P_inv32 = 'd0;
    parameter P_inv33 = 'd0;
    parameter P_inv41 = 'd0;
    parameter P_inv42 = 'd0;
    parameter P_inv43 = 'd0;
    
    parameter s_reciprocal = 'd1; // scalar factor
    
    // Camera 1 world vector
    logic [15:0] world_x1;
    logic [15:0] world_y1;
    logic [15:0] world_z1;
    
    //Camera 2 world vector
    logic [15:0] world_x2;
    logic [15:0] world_y2;
    logic [15:0] world_z2;
    
    
    always_ff @(posedge clk_in)begin
        world_x1 <= P_inv11*x1 + P_inv12*y1 + P_inv13*1;
        world_y1 <= P_inv21*x1 + P_inv22*y1 + P_inv23*1;
        world_z1 <= P_inv31*x1 + P_inv32*y1 + P_inv33*1;
        
        world_x2 <= P_inv11*x2 + P_inv12*y2 + P_inv13*1;
        world_y2 <= P_inv21*x2 + P_inv22*y2 + P_inv23*1;
        world_z2 <= P_inv31*x2 + P_inv32*y2 + P_inv33*1;
        
        world_x <= (world_x1 + world_x2) >> 2;
        world_y <= (world_y1 + world_y2) >> 2;
        world_z <= (world_z1 + world_z2) >> 2;
    end
    
    
endmodule
