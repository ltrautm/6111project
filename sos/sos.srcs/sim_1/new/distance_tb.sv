module distance(
    input clk_in,
    input rst_in,
//    input start,
    input [31:0] x1,
    input [31:0] y1,
    input [31:0] x2,
    input [31:0] y2,
//    input [9:0] servo_angle,
    output logic [31:0] distance,
    output logic signed [31:0] world_x,
    output logic signed [31:0] world_y,
    output logic signed [31:0] world_z
    );
    
    // 16 bits to decimal: 2^16 = 65536
    
    /* LEFT CAMERA */
    
    //inverted camera 1 matrix
    parameter signed P1_inv11 = {16'b0,                       16'b0000_0001_1111_1000}; // 0.0077
    parameter signed P1_inv12 = {16'b0,                       16'b0000_0000_0000_1101}; //'d64;
    parameter signed P1_inv13 = {16'b0,                       16'b0};
    parameter signed P1_inv21 = {1'b1, 15'b111111111111111,   16'b1111_1111_1111_0010};//-'d59;
    parameter signed P1_inv22 = {1'b0, 15'b0,                 16'b0000_0001_1111_1000}; //'d2007;
    parameter signed P1_inv23 = {1'b0, 15'b0,   16'b0};
    parameter signed P1_inv31 = {1'b1, 15'b111111111111110,   16'b0000_1111_0101_1100};
    parameter signed P1_inv32 = {1'b1, 15'b111111111111110,   16'b1110_1100_0011_0110};
    parameter signed P1_inv33 = {1'b0, 15'b0,                 16'b0000_0000_0110_1000};
    
    //real world coords of camera 1
    parameter signed C1_1 = 'd292;
    parameter signed C1_2 = 'd73;
    parameter signed C1_3 = -'d2075;
    
    
    /* RIGHT CAMERA */
    
    //inverted camera 2 matrix
    parameter signed P2_inv11 =  32'd1970;
    parameter signed P2_inv12 =  32'd60;
    parameter signed P2_inv13 =  32'd0;
    parameter signed P2_inv21 = -32'd70;
    parameter signed P2_inv22 =  32'd2013;
    parameter signed P2_inv23 =  32'd0;
    parameter signed P2_inv31 = -32'd90649;
    parameter signed P2_inv32 = -32'd230430;
    parameter signed P2_inv33 =  32'd520;

    //real world coords for camera 2
    parameter signed C2_1 = 32'd24;
    parameter signed C2_2 = 32'd185;
    parameter signed C2_3 = -32'd2083;
    

    
// STAGE 1
    logic signed [31:0] s1_world1_x1;
    logic signed [31:0] s1_world1_x2;
    logic signed [31:0] s1_world1_x3;
    
    logic signed [31:0] s1_world1_y1;
    logic signed [31:0] s1_world1_y2;
    logic signed [31:0] s1_world1_y3;
    
    logic signed [31:0] s1_scaling_1 ;
    logic signed [31:0] s1_scaling_2;
    logic signed [31:0] s1_scaling_3;
    
    logic signed [31:0] s2_world1_x1;
    logic signed [31:0] s2_world1_x2;
    logic signed [31:0] s2_world1_x3;
    
    logic signed [31:0] s2_world1_y1;
    logic signed [31:0] s2_world1_y2;
    logic signed [31:0] s2_world1_y3;
    
    logic signed [31:0] s2_scaling_1;
    logic signed [31:0] s2_scaling_2;
    logic signed [31:0] s2_scaling_3;
    
    logic signed [63:0] s1_world1_x1_temp;
    logic signed [63:0] s1_world1_x2_temp;
    
    logic signed [63:0] s1_world1_y1_temp;
    logic signed [63:0] s1_world1_y2_temp;
    
    logic signed [63:0] s1_scaling_1_temp;
    logic signed [63:0] s1_scaling_2_temp;
    
    
    always_comb begin
        s1_world1_x1 = s1_world1_x1_temp[47:16];
        s1_world1_x2 = s1_world1_x2_temp[47:16];
        
        s1_world1_y1 = s1_world1_y1_temp[47:16];
        s1_world1_y2 = s1_world1_y2_temp[47:16];
        
        s1_scaling_1 = s1_scaling_1_temp[47:16];
        s1_scaling_2 = s1_scaling_2_temp[47:16];
    end
//////////////////////////////////////////////////////////////////////////
// STAGE 2: 
    // Camera 1 world vector
    logic signed [31:0] world1_x;
    logic signed [31:0] world1_y;
    logic signed [31:0] scaling1 = 1;

    
    //Camera 2 world vector
    logic signed [31:0] world2_x;
    logic signed [31:0] world2_y;
    logic signed [31:0] scaling2 = 1;
//////////////////////////////////////////////////////////////////////////
// STAGE 3: scaling
    // Camera 1 world vector
    logic signed [31:0] world1_x_scaled;
    logic signed [31:0] world1_y_scaled;
    
    //Camera 2 world vector
    logic signed [31:0] world2_x_scaled;
    logic signed [31:0] world2_y_scaled;

    my_division world1x(
        .clk_in(clk_in),
        .dividend(world1_x),
        .divisor(scaling1),
       .valid_signal(1),
        .quotient(world1_x_scaled)
        );

    my_division world1y(
        .clk_in(clk_in),
        .dividend(world1_y),
        .divisor(scaling1),
       .valid_signal(1),
        .quotient(world1_y_scaled)
        );
        
    my_division world2x(
        .clk_in(clk_in),
        .dividend(world2_x),
        .divisor(scaling2),
       .valid_signal(1),
        .quotient(world2_x_scaled)
        );

    my_division world2y(
        .clk_in(clk_in),
        .dividend(world2_y),
        .divisor(scaling2),
       .valid_signal(1),
        .quotient(world2_y_scaled)
        );
/////////////////////////////////////////////////////////////////////////
// STAGE 4 u, v calculations
    // Midpoint Calculation Variables
    //Camera 1 unit vector
    logic signed [31:0] u1;
    logic signed [31:0] u2;
    logic signed [31:0] u3;

    logic signed [31:0] u1_delay;
    logic signed [31:0] u2_delay;
    logic signed [31:0] u3_delay;

    logic signed [31:0] u1_delay2;
    logic signed [31:0] u2_delay2;
    logic signed [31:0] u3_delay2;

    logic signed [31:0] u1_delay3;
    logic signed [31:0] u2_delay3;
    logic signed [31:0] u3_delay3;
 
    logic signed [31:0] u1_delay4;
    logic signed [31:0] u2_delay4;
    logic signed [31:0] u3_delay4;  
     
    // Camera 2 unit vector
    logic signed [31:0] v1;
    logic signed [31:0] v2;
    logic signed [31:0] v3;

    logic signed [31:0] v1_delay;
    logic signed [31:0] v2_delay;
    logic signed [31:0] v3_delay;

    logic signed [31:0] v1_delay2;
    logic signed [31:0] v2_delay2;
    logic signed [31:0] v3_delay2;

    logic signed [31:0] v1_delay3;
    logic signed [31:0] v2_delay3;
    logic signed [31:0] v3_delay3;
 
    logic signed [31:0] v1_delay4;
    logic signed [31:0] v2_delay4;
    logic signed [31:0] v3_delay4;      

///////////////////////////////////////////////////////////////////////  
// STAGE 5: t_cpa breakdown
    logic signed [31:0] t_subtraction_1;
    logic signed [31:0] t_subtraction_2;
    logic signed [31:0] t_subtraction_3;
    logic signed [31:0] t_subtraction_4;
    logic signed [31:0] t_subtraction_5;
    logic signed [31:0] t_subtraction_6;
    
    logic signed [31:0] t_multiplication_1;
    logic signed [31:0] t_multiplication_2;
    logic signed [31:0] t_multiplication_3;
    
    logic signed [31:0] t_divisor_1;   
    logic signed [31:0] t_divisor_2;
    logic signed [31:0] t_divisor_3;

// STAGE 7
    logic signed [31:0] t_cpa_numerator;
    logic signed [31:0] t_cpa_denominator;
     
// STAGE 8
    // scaling factor of where the two lines come closest
    logic signed [31:0] t_cpa;
///////////////////////////////////////////////////////////////////////
// STAGE 9
    logic signed [31:0] world_x_multiplication_1;
    logic signed [31:0] world_x_multiplication_2;
    
    logic signed [31:0] world_y_multiplication_1;
    logic signed [31:0] world_y_multiplication_2;
    
    logic signed [31:0] world_z_multiplication_1;
    logic signed [31:0] world_z_multiplication_2;
///////////////////////////////////////////////////////////////////////
// STAGE 10
    logic signed [31:0] world_x_numerator;
    logic signed [31:0] world_y_numerator;
    logic signed [31:0] world_z_numerator;
//////////////////////////////////////////////////////////////////////
    logic signed [31:0] world_x_sq;
    logic signed [31:0] world_y_sq;
    logic signed [31:0] world_z_sq;
    
    
//////////////////////////////////////////////////////////////////////       
    always_ff @(posedge clk_in)begin    
        // STAGE 1 [x y 1 ]* P_inv to get world coord X, Y (scale by third value)
        s1_world1_x1_temp <= x1*P1_inv11;
        s1_world1_x2_temp <= y1*P1_inv21;
        s1_world1_x3 <= P1_inv31;
        
        s1_world1_y1_temp <= x1*P1_inv12;
        s1_world1_y2_temp <= y1*P1_inv22;
        s1_world1_y3 <= P1_inv32;
        
        s1_scaling_1_temp <= x1*P1_inv13;
        s1_scaling_2_temp <= y1*P1_inv23;
        s1_scaling_3 <= P1_inv33;
        
        
        s2_world1_x1_temp <= x2*P2_inv11;
        s2_world1_x2_temp <= y2*P2_inv21;
        s2_world1_x3 <= P2_inv31;
        
        s2_world1_y1_temp <= x2*P2_inv12;
        s2_world1_y2_temp <= y2*P2_inv22;
        s2_world1_y3 <= P2_inv32;
        
        s2_scaling_1_temp <= x2*P2_inv13;
        s2_scaling_2_temp <= y2*P2_inv23;
        s2_scaling_3 <= P2_inv33;
        
        
       // STAGE 2
        world1_x <= s1_world1_x1 + s1_world1_x2 + s1_world1_x3;
        world1_y <= s1_world1_y1 + s1_world1_y2 + s1_world1_y3;
        scaling1 <= s1_scaling_1 + s1_scaling_2 + s1_scaling_3;
        
        
        world2_x <= s2_world1_x1 + s2_world1_x2 + s2_world1_x3;
        world2_y <= s2_world1_y1 + s2_world1_y2 + s2_world1_y3;
        scaling2 <= s2_scaling_1 + s2_scaling_2 + s2_scaling_3;
        

        // STAGE 3
        // divide both world1_x and world1_y by scaling1 = world1_x_scaled, world1_y_scaled
        // divide both world2_x and world2_y by scaling2 = world2_x_scaled, world2_y_scaled
        /*
        world1_x_scaled <= world1_x / scaling1;
        world1_y_scaled <= world1_y / scaling1;
        
        world2_x_scaled <= world2_x / scaling2;
        world2_y_scaled <= world2_y / scaling2;
        */
        
        //STAGE 4
        u1 <= world1_x_scaled - C1_1;
        u2 <= world1_y_scaled - C1_2;
        u3 <= - C1_3;
        
        v1 <= world2_x_scaled - C2_1;
        v2 <= world2_y_scaled - C2_2;
        v3 <= - C2_3;
        
        // STAGE 5 
//        t_cpa <= -( (C1_1 - C2_1)*(u1 - v1) + (C1_2 - C2_2)*(u2 - v2) + (C1_3 - C2_3)*(u3 - v3) ); // break these up
//        t_cpa <= (C1_1 - C2_1)*(v1 - u1) + (C1_2 - C2_2)*(v2 - u2) + (C1_3 - C2_3)*(v3 - u3) ;
        t_subtraction_1 <= C1_1 - C2_1;
        t_subtraction_2 <= v1 - u1;
        t_subtraction_3 <= C1_2 - C2_2;
        t_subtraction_4 <= v2 - u2;
        t_subtraction_5 <= C1_3 - C2_3;
        t_subtraction_6 <= v3 - u3;
        
         u1_delay <= u1;
         u2_delay <= u2;
         u3_delay <= u3;
         v1_delay <= v1;
         v2_delay <= v2;
         v3_delay <= v3;
         
         
        
        // STAGE 6
        t_multiplication_1_temp <= t_subtraction_1 * t_subtraction_2;
        t_multiplication_2_temp <= t_subtraction_3 * t_subtraction_4;
        t_multiplication_3_temp <= t_subtraction_5 * t_subtraction_6;
        
         u1_delay2 <= u1_delay;
         u2_delay2 <= u2_delay;
         u3_delay2 <= u3_delay;
         v1_delay2 <= v1_delay;
         v2_delay2 <= v2_delay;
         v3_delay2 <= v3_delay;
         
        
        // divide t_cpa by ((u1 - v1)*(u1 - v1) + (u2 - v2)*(u2 - v2) + (u3 - v3)*(u3 - v3))
        t_divisor_1_temp <= t_subtraction_2 * t_subtraction_2;
        t_divisor_2_temp <= t_subtraction_4 * t_subtraction_4;
        t_divisor_3_temp <= t_subtraction_6 * t_subtraction_6;
        
        
        // STAGE 7
        t_cpa_numerator <= t_multiplication_1 + t_multiplication_2 + t_multiplication_3;
        t_cpa_denominator <= t_divisor_1 + t_divisor_2 + t_divisor_3;
        
         u1_delay3 <= u1_delay2;
         u2_delay3 <= u2_delay2;
         u3_delay3 <= u3_delay2;
         v1_delay3 <= v1_delay2;
         v2_delay3 <= v2_delay2;
         v3_delay3 <= v3_delay2;
        
        // STAGE 8:
        t_cpa <= t_cpa_numerator / t_cpa_denominator;
        
         u1_delay4 <= u1_delay3;
         u2_delay4 <= u2_delay3;
         u3_delay4 <= u3_delay3;
         v1_delay4 <= v1_delay3;
         v2_delay4 <= v2_delay3;
         v3_delay4 <= v3_delay3;
        
        // STAGE 9: individual multiplications
        world_x_multiplication_1_temp <= t_cpa * u1_delay4;
        world_x_multiplication_2_temp <= t_cpa * v1_delay4;
        
        world_y_multiplication_1_temp <= t_cpa * u2_delay4;
        world_y_multiplication_2_temp <= t_cpa * v2_delay4;
        
        world_z_multiplication_1_temp <= t_cpa * u3_delay4;
        world_z_multiplication_2_temp <= t_cpa * v3_delay4;

        
        // STAGE 10: add to get world_x, world_y, and world_z
        world_x_numerator <= C1_1 + world_x_multiplication_1 + C2_1 + world_x_multiplication_2; // change these to delays, 
        world_y_numerator <= C1_2 + world_y_multiplication_1 + C2_2 + world_y_multiplication_2;
        world_z_numerator <= C1_3 + world_z_multiplication_1 + C2_3 + world_z_multiplication_2;
        
//        world_x <= (C1_1 + t_cpa*u1 + C2_1 + t_cpa*v1) >> 1;
//        world_y <= (C1_2 + t_cpa*u2 + C2_2 + t_cpa*v2) >> 1;
//        world_z <= (C1_3 + t_cpa*u3 + C2_3 + t_cpa*v3) >> 1;
        
        // STAGE 11: divide world_x, world_y, and world_z by 2
        world_x <= world_x_numerator >> 1;
        world_y <= world_y_numerator >> 1;
        world_z <= world_z_numerator >> 1;
        
        
        // STAGE 12
        // do individual multiplications
        world_x_sq_temp <= world_x * world_x;
        world_y_sq_temp <= world_y * world_y;
        world_z_sq_temp <= world_z * world_z;
        
        // STAGE 13
        // add to get distance (change below to use _sq signals)
        distance <= world_x_sq + world_y_sq + world_z_sq;
        
        // STAGE 14
        // compute sqrt
     
    end
    
    
endmodule

module my_division(
    input clk_in,
    input signed[31:0] dividend,
    input signed [31:0] divisor,
    input valid_signal,
    output signed [31:0] quotient
    );
    
    logic signed [63:0] dividend_float64;
    logic signed [63:0] divisor_float64;
    logic signed [63:0] division_result;
    logic dividend_result_valid;
    logic divisor_result_valid;
    logic division_result_valid;
    logic quotient_result_valid;
    
    floating_point_0 conv1(
        .aclk(clk_in),                              //: IN STD_LOGIC;
        .s_axis_a_tvalid(valid_signal),                        //: IN STD_LOGIC;
        .s_axis_a_tready( ),                        //: OUT STD_LOGIC;
        .s_axis_a_tdata(dividend),            //: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        .m_axis_result_tvalid(dividend_result_valid),    //: OUT STD_LOGIC;
        .m_axis_result_tready(1),                       //: IN STD_LOGIC;
        .m_axis_result_tdata(dividend_float64)       //: OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
    );
    
    floating_point_0 conv2(
        .aclk(clk_in),                                   //: IN STD_LOGIC;
        .s_axis_a_tvalid(valid_signal),                             //: IN STD_LOGIC;
        .s_axis_a_tready( ),                             //: OUT STD_LOGIC;
        .s_axis_a_tdata(divisor),                  //: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        .m_axis_result_tvalid(divisor_result_valid),     //: OUT STD_LOGIC;
        .m_axis_result_tready(1),                        //: IN STD_LOGIC;
        .m_axis_result_tdata(divisor_float64)            //: OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
    ); 
    
        
    division div1(
        .aclk(clk_in),     
        .s_axis_a_tvalid(dividend_result_valid),         // IN STD_LOGIC;
        .s_axis_a_tready( ),             // OUT STD_LOGIC;
        .s_axis_a_tdata(dividend_float64),          // IN STD_LOGIC_VECTOR(63 DOWNTO 0);
        .s_axis_b_tvalid(divisor_result_valid),                        // IN STD_LOGIC;
        .s_axis_b_tready( ),             // OUT STD_LOGIC;
        .s_axis_b_tdata(divisor_float64),           //: IN STD_LOGIC_VECTOR(63 DOWNTO 0);
        .m_axis_result_tvalid(division_result_valid),   //: OUT STD_LOGIC;
        .m_axis_result_tready(1),                   //: IN STD_LOGIC;
        .m_axis_result_tdata(division_result)             //: OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
        );
        
    floating_point_1 convertBack(
        .aclk(clk_in),                              //: IN STD_LOGIC;
        .s_axis_a_tvalid(division_result_valid),                        //: IN STD_LOGIC;
        .s_axis_a_tready( ),                        //: OUT STD_LOGIC;
        .s_axis_a_tdata(division_result),            //: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        .m_axis_result_tvalid(quotient_result_valid),    //: OUT STD_LOGIC;
        .m_axis_result_tready(1),                       //: IN STD_LOGIC;
        .m_axis_result_tdata(quotient)       //: OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
    );
    
endmodule





module get_divisor(
    input clk_in,
    input [16:0] number,
    output logic [16:0] divisor
);
logic [16:0] curr_num = number;
logic [16:0] temp_divisor = 'd1;

always_ff@(posedge clk_in)begin
    if(curr_num >> 2 == 0)begin
        if(number - temp_divisor < temp_divisor*2 - number)begin
            divisor <= temp_divisor;
        end else begin
            divisor <= temp_divisor * 2;
        end
        curr_num <= number;
        temp_divisor <= 1;
    end else begin
        curr_num <= curr_num >> 2;
        temp_divisor <= temp_divisor * 2;
    end
end

endmodule // get_divisor
