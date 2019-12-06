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
    
    /* LEFT CAMERA */
    
    //inverted camera 1 matrix
    parameter P1_inv11 = 16'd1;
    parameter P1_inv12 = 16'd0;
    parameter P1_inv13 = 16'd0;
    parameter P1_inv21 = 16'd0;
    parameter P1_inv22 = 16'd1;
    parameter P1_inv23 = 16'd0;
    parameter P1_inv31 = 16'd0;
    parameter P1_inv32 = 16'd0;
    parameter P1_inv33 = 16'd1;
    
    //real world coords of camera 1
    parameter C1_1 = 16'd1;
    parameter C1_2 = 16'd1;
    parameter C1_3 = 16'd1;
    
    
    /* RIGHT CAMERA */
    
    //inverted camera 2 matrix
    parameter P2_inv11 = 16'd1;
    parameter P2_inv12 = 16'd0;
    parameter P2_inv13 = 16'd0;
    parameter P2_inv21 = 16'd1;
    parameter P2_inv22 = 16'd0;
    parameter P2_inv23 = 16'd0;
    parameter P2_inv31 = 16'd1;
    parameter P2_inv32 = 16'd0;
    parameter P2_inv33 = 16'd0;

    //real world coords for camera 2
    parameter C2_1 = 16'd2;
    parameter C2_2 = 16'd2;
    parameter C2_3 = 16'd2;
    
    // Camera 1 world vector
    logic [15:0] world1_x;
    logic [15:0] world1_y;
    logic [15:0] scaling1;
    
    //Camera 2 world vector
    logic [15:0] world2_x;
    logic [15:0] world2_y;
    logic [15:0] scaling2;

    // Midpoint Calculation Variables
    //Camera 1 unit vector
    logic [15:0] u1;
    logic [15:0] u2;
    logic [15:0] u3;
    
    // Camera 2 unit vector
    logic [15:0] v1;
    logic [15:0] v2;
    logic [15:0] v3;
    
    // scaling factor of where the two lines come closest
    logic [15:0] t_cpa;
    
    always_ff @(posedge clk_in)begin    
        world1_x <= x1*P1_inv11 + y1*P1_inv21 + 1*P1_inv31;
        world1_y <= x1*P1_inv12 + y1*P1_inv22 + 1*P1_inv32;
        scaling1 <= x1*P1_inv13 + y1*P1_inv23 + 1*P1_inv33;
        // divide both world1_x and world1_y by scaling1
        
        world2_x <= x2*P2_inv11 + y2*P2_inv21 + 1*P2_inv31;
        world2_y <= x2*P2_inv12 + y2*P2_inv22 + 1*P2_inv32;
        scaling2 <= x2*P2_inv13 + y2*P2_inv23 + 1*P2_inv33;
        // divide both world2_x and world2_y by scaling2
        
        u1 <= world1_x - C1_1;
        u2 <= world1_y - C1_2;
        u3 <= - C1_3;
        
        v1 <= world2_x - C2_1;
        v2 <= world2_y - C2_2;
        v3 <= - C2_3;
        
        t_cpa <= -( (C1_1 - C2_1)*(u1 - v1) + (C1_2 - C2_2)*(u2 - v2) + (C1_3 - C2_3)*(u3 - v3) );
        // divide t_cpa by ((u1 - v1)*(u1 - v1) + (u2 - v2)*(u2 - v2) + (u3 - v3)*(u3 - v3))
        
        world_x <= (C1_1 + t_cpa*u1 + C2_1 + t_cpa*v1) >> 1;
        world_y <= (C1_2 + t_cpa*u2 + C2_2 + t_cpa*v2) >> 1;
        world_z <= (C1_3 + t_cpa*u3 + C2_3 + t_cpa*v3) >> 1;
        
        distance <= world_x * world_x + world_y * world_y + world_z * world_z;
     
    end
    
    
endmodule
