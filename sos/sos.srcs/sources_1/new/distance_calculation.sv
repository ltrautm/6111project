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
    output logic signed [16:0] world_x,
    output logic signed [16:0] world_y,
    output logic signed [16:0] world_z
    );
    
    // 16 bits to decimal: 2^16 = 65536
    
    /* LEFT CAMERA */
    
    //inverted camera 1 matrix
    parameter signed P1_inv11 = 'd2025;
    parameter signed P1_inv12 = 'd64;
    parameter signed P1_inv13 = 'd0;
    parameter signed P1_inv21 = -'d59;
    parameter signed P1_inv22 = 'd2007;
    parameter signed P1_inv23 = 'd0;
    parameter signed P1_inv31 = -'d508674;
    parameter signed P1_inv32 = -'d282414;
    parameter signed P1_inv33 = 'd429;
    
    //real world coords of camera 1
    parameter signed C1_1 = 'd292;
    parameter signed C1_2 = 'd73;
    parameter signed C1_3 = -'d2075;
    
    
    /* RIGHT CAMERA */
    
    //inverted camera 2 matrix
    parameter signed P2_inv11 =  'd1970;
    parameter signed P2_inv12 =  'd60;
    parameter signed P2_inv13 =  'd0;
    parameter signed P2_inv21 = -'d70;
    parameter signed P2_inv22 =  'd2013;
    parameter signed P2_inv23 =  'd0;
    parameter signed P2_inv31 = -'d90649;
    parameter signed P2_inv32 = -'d230430;
    parameter signed P2_inv33 =  'd520;

    //real world coords for camera 2
    parameter signed C2_1 = 'd24;
    parameter signed C2_2 = 'd185;
    parameter signed C2_3 = -'d2083;
    
    // Camera 1 world vector
    logic signed [31:0] world1_x;
    logic signed [31:0] world1_y;
    logic signed [31:0] scaling1 = 1;
   
    
    
    //Camera 2 world vector
    logic signed [31:0] world2_x;
    logic signed [31:0] world2_y;
    logic signed [31:0] scaling2 = 1;
    
  
    
//    logic [16:0] divisor;
//    get_divisor eq1(
//        .clk_in(clk_in),
//        .number(scaling1),
//        .divisor(divisor)     
//    );

//////////////////////////////////////////////////////////////////////////////
//    logic div_1a_valid, div_1a_ready, div_1b_valid, div_1b_ready,
//          div_1result_valid, div_1result_ready;
    
    logic dividend_result_valid;
    logic divisor_result_valid;
    
    logic signed [31:0] dividend_int32 = 32'd15;
    logic signed [63:0] dividend_float64;
    logic signed [31:0] divisor_int32 = 32'd2;
    logic signed [63:0] divisor_float64;
    
    logic division_result_valid;
    logic signed [63:0] division_result;

   
    
    int_to_float conv1(
        .aclk(clk_in),                              //: IN STD_LOGIC;
        .s_axis_a_tvalid(1),                        //: IN STD_LOGIC;
        .s_axis_a_tready( ),                        //: OUT STD_LOGIC;
        .s_axis_a_tdata(dividend_int32),            //: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        .m_axis_result_tvalid(dividend_result_valid),    //: OUT STD_LOGIC;
        .m_axis_result_tready(1),                       //: IN STD_LOGIC;
        .m_axis_result_tdata(dividend_float64)       //: OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
    ); 
    
    int_to_float conv2(
        .aclk(clk_in),                                   //: IN STD_LOGIC;
        .s_axis_a_tvalid(1),                             //: IN STD_LOGIC;
        .s_axis_a_tready( ),                             //: OUT STD_LOGIC;
        .s_axis_a_tdata(divisor_int32),                  //: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        .m_axis_result_tvalid(divisor_result_valid),     //: OUT STD_LOGIC;
        .m_axis_result_tready(1),                        //: IN STD_LOGIC;
        .m_axis_result_tdata(divisor_float64)            //: OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
    ); 
        
    floating_point_0 div1(
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
    
///////////////////////////////////////////////////////////////////////
    // STAGE 1 CONVERSIONS
    logic world1_x_result_valid;
    logic signed [63:0] world1_x_float64;
    logic world1_y_result_valid;
    logic signed [63:0] world1_y_float64;
    logic scaling1_result_valid;
    logic signed [63:0] scaling1_float64;
    
    int_to_float world1_x_conv(
        .aclk(clk_in),                              //: IN STD_LOGIC;
        .s_axis_a_tvalid(1),                        //: IN STD_LOGIC;
        .s_axis_a_tready( ),                        //: OUT STD_LOGIC;
        .s_axis_a_tdata(world1_x),            //: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        .m_axis_result_tvalid(world1_x_result_valid),    //: OUT STD_LOGIC;
        .m_axis_result_tready(1),                       //: IN STD_LOGIC;
        .m_axis_result_tdata(world1_x_float64)       //: OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
    );
    
    int_to_float world1_y_conv(
        .aclk(clk_in),                              //: IN STD_LOGIC;
        .s_axis_a_tvalid(1),                        //: IN STD_LOGIC;
        .s_axis_a_tready( ),                        //: OUT STD_LOGIC;
        .s_axis_a_tdata(world1_y),            //: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        .m_axis_result_tvalid(world1_y_result_valid),    //: OUT STD_LOGIC;
        .m_axis_result_tready(1),                       //: IN STD_LOGIC;
        .m_axis_result_tdata(world1_y_float64)       //: OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
    );
    
    int_to_float scaling1_conv(
        .aclk(clk_in),                              //: IN STD_LOGIC;
        .s_axis_a_tvalid(1),                        //: IN STD_LOGIC;
        .s_axis_a_tready( ),                        //: OUT STD_LOGIC;
        .s_axis_a_tdata(scaling1),            //: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        .m_axis_result_tvalid(scaling1_result_valid),    //: OUT STD_LOGIC;
        .m_axis_result_tready(1),                       //: IN STD_LOGIC;
        .m_axis_result_tdata(scaling1_float64)       //: OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
    );
    
    logic world2_x_result_valid;
    logic signed [63:0] world2_x_float64;
    logic world2_y_result_valid;
    logic signed [63:0] world2_y_float64;
    logic scaling2_result_valid;
    logic signed [63:0] scaling2_float64;
    
    int_to_float world2_x_conv(
        .aclk(clk_in),                              //: IN STD_LOGIC;
        .s_axis_a_tvalid(1),                        //: IN STD_LOGIC;
        .s_axis_a_tready( ),                        //: OUT STD_LOGIC;
        .s_axis_a_tdata(world2_x),                  //: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        .m_axis_result_tvalid(world2_x_result_valid),    //: OUT STD_LOGIC;
        .m_axis_result_tready(1),                       //: IN STD_LOGIC;
        .m_axis_result_tdata(world2_x_float64)       //: OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
    );

    int_to_float world2_y_conv(
        .aclk(clk_in),                              //: IN STD_LOGIC;
        .s_axis_a_tvalid(1),                        //: IN STD_LOGIC;
        .s_axis_a_tready( ),                        //: OUT STD_LOGIC;
        .s_axis_a_tdata(world2_y),            //: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        .m_axis_result_tvalid( world2_y_result_valid),    //: OUT STD_LOGIC;
        .m_axis_result_tready(1),                       //: IN STD_LOGIC;
        .m_axis_result_tdata( world2_y_float64)       //: OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
    );
    
    int_to_float scaling2_conv(
        .aclk(clk_in),                              //: IN STD_LOGIC;
        .s_axis_a_tvalid(1),                        //: IN STD_LOGIC;
        .s_axis_a_tready( ),                        //: OUT STD_LOGIC;
        .s_axis_a_tdata(scaling2),            //: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        .m_axis_result_tvalid(scaling2_result_valid),    //: OUT STD_LOGIC;
        .m_axis_result_tready(1),                       //: IN STD_LOGIC;
        .m_axis_result_tdata(scaling2_float64)       //: OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
    );
    
    logic C1_1_result_valid;
    logic signed [63:0] C1_1_float64;
    logic C1_2_result_valid;
    logic signed [63:0] C1_2_float64;
    logic C1_3_result_valid;
    logic signed [63:0] C1_3_float64;   
    
    int_to_float C1_1_conv(
        .aclk(clk_in),                              //: IN STD_LOGIC;
        .s_axis_a_tvalid(1),                        //: IN STD_LOGIC;
        .s_axis_a_tready( ),                        //: OUT STD_LOGIC;
        .s_axis_a_tdata(C1_1),                  //: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        .m_axis_result_tvalid(C1_1_result_valid),    //: OUT STD_LOGIC;
        .m_axis_result_tready(1),                       //: IN STD_LOGIC;
        .m_axis_result_tdata(C1_1_float64)       //: OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
    );
    
    int_to_float C1_2_conv(
        .aclk(clk_in),                              //: IN STD_LOGIC;
        .s_axis_a_tvalid(1),                        //: IN STD_LOGIC;
        .s_axis_a_tready( ),                        //: OUT STD_LOGIC;
        .s_axis_a_tdata(C1_2),                  //: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        .m_axis_result_tvalid(C1_2_result_valid),    //: OUT STD_LOGIC;
        .m_axis_result_tready(1),                       //: IN STD_LOGIC;
        .m_axis_result_tdata(C1_2_float64)       //: OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
    );
    
    int_to_float C1_3_conv(
        .aclk(clk_in),                              //: IN STD_LOGIC;
        .s_axis_a_tvalid(1),                        //: IN STD_LOGIC;
        .s_axis_a_tready( ),                        //: OUT STD_LOGIC;
        .s_axis_a_tdata(C1_3),                  //: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        .m_axis_result_tvalid(C1_3_result_valid),    //: OUT STD_LOGIC;
        .m_axis_result_tready(1),                       //: IN STD_LOGIC;
        .m_axis_result_tdata(C1_3_float64)       //: OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
    );
    
    
    logic C2_1_result_valid;
    logic signed [63:0] C2_1_float64;
    logic C2_2_result_valid;
    logic signed [63:0] C2_2_float64;
    logic C2_3_result_valid;
    logic signed [63:0] C2_3_float64;

    int_to_float C2_1_conv(
        .aclk(clk_in),                              //: IN STD_LOGIC;
        .s_axis_a_tvalid(1),                        //: IN STD_LOGIC;
        .s_axis_a_tready( ),                        //: OUT STD_LOGIC;
        .s_axis_a_tdata(C2_1),                  //: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        .m_axis_result_tvalid(C2_1_result_valid),    //: OUT STD_LOGIC;
        .m_axis_result_tready(1),                       //: IN STD_LOGIC;
        .m_axis_result_tdata(C2_1_float64)       //: OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
    );
    
    int_to_float C2_2_conv(
        .aclk(clk_in),                              //: IN STD_LOGIC;
        .s_axis_a_tvalid(1),                        //: IN STD_LOGIC;
        .s_axis_a_tready( ),                        //: OUT STD_LOGIC;
        .s_axis_a_tdata(C2_2),                  //: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        .m_axis_result_tvalid(C2_2_result_valid),    //: OUT STD_LOGIC;
        .m_axis_result_tready(1),                       //: IN STD_LOGIC;
        .m_axis_result_tdata(C2_2_float64)       //: OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
    );
    
    int_to_float C2_3_conv(
        .aclk(clk_in),                              //: IN STD_LOGIC;
        .s_axis_a_tvalid(1),                        //: IN STD_LOGIC;
        .s_axis_a_tready( ),                        //: OUT STD_LOGIC;
        .s_axis_a_tdata(C2_3),                  //: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        .m_axis_result_tvalid(C2_3_result_valid),    //: OUT STD_LOGIC;
        .m_axis_result_tready(1),                       //: IN STD_LOGIC;
        .m_axis_result_tdata(C2_3_float64)       //: OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
    );
///////////////////////////////////////////////////////////////////////
// STAGE 2 DIVISIONS
    logic scaling1_x_divisor_result_valid;
    logic scaled1_x_result_valid;
    logic signed [63:0] scaled1_x; // float64 scaled world1_x
   
    
    floating_point_0 scaled1_x_division(
        .aclk(clk_in),     
        .s_axis_a_tvalid(world1_x_result_valid),         // IN STD_LOGIC;
        .s_axis_a_tready( ),             // OUT STD_LOGIC;
        .s_axis_a_tdata(world1_x_float64),          // IN STD_LOGIC_VECTOR(63 DOWNTO 0);
        .s_axis_b_tvalid(scaling1_result_valid),                        // IN STD_LOGIC;
        .s_axis_b_tready(scaling1_x_divisor_result_valid),             // OUT STD_LOGIC;
        .s_axis_b_tdata(scaling1_float64),           //: IN STD_LOGIC_VECTOR(63 DOWNTO 0);
        .m_axis_result_tvalid(scaled1_x_result_valid),   //: OUT STD_LOGIC;
        .m_axis_result_tready(1),                   //: IN STD_LOGIC;
        .m_axis_result_tdata(scaled1_x)             //: OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
        );
        
    logic scaling1_y_divisor_result_valid;
    logic scaled1_y_result_valid;
    logic signed [63:0] scaled1_y; // float64 scaled world1_y
    
    floating_point_0 scaled1_y_division(
        .aclk(clk_in),     
        .s_axis_a_tvalid(world1_y_result_valid),         // IN STD_LOGIC;
        .s_axis_a_tready( ),             // OUT STD_LOGIC;
        .s_axis_a_tdata(world1_y_float64),          // IN STD_LOGIC_VECTOR(63 DOWNTO 0);
        .s_axis_b_tvalid(scaling1_result_valid),                        // IN STD_LOGIC;
        .s_axis_b_tready(scaling1_y_divisor_result_valid),             // OUT STD_LOGIC;
        .s_axis_b_tdata(scaling1_float64),           //: IN STD_LOGIC_VECTOR(63 DOWNTO 0);
        .m_axis_result_tvalid(scaled1_y_result_valid),   //: OUT STD_LOGIC;
        .m_axis_result_tready(1),                   //: IN STD_LOGIC;
        .m_axis_result_tdata(scaled1_y)             //: OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
        );
        
    logic scaling2_x_divisor_result_valid;
    logic scaled2_x_result_valid;
    logic signed [63:0] scaled2_x; // float64 scaled world2_x
    
     floating_point_0 scaled2_x_division(
        .aclk(clk_in),     
        .s_axis_a_tvalid(world2_x_result_valid),         // IN STD_LOGIC;
        .s_axis_a_tready( ),             // OUT STD_LOGIC;
        .s_axis_a_tdata(world2_x_float64),          // IN STD_LOGIC_VECTOR(63 DOWNTO 0);
        .s_axis_b_tvalid(scaling2_result_valid),                        // IN STD_LOGIC;
        .s_axis_b_tready(scaling2_x_divisor_result_valid),             // OUT STD_LOGIC;
        .s_axis_b_tdata(scaling2_float64),           //: IN STD_LOGIC_VECTOR(63 DOWNTO 0);
        .m_axis_result_tvalid(scaled2_x_result_valid),   //: OUT STD_LOGIC;
        .m_axis_result_tready(1),                   //: IN STD_LOGIC;
        .m_axis_result_tdata(scaled2_x)             //: OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
        );   
    
    
    
    logic scaling2_y_divisor_result_valid;
    logic scaled2_y_result_valid;
    logic signed [63:0] scaled2_y; // float64 scaled world2_y

     floating_point_0 scaled2_y_division(
        .aclk(clk_in),     
        .s_axis_a_tvalid(world2_y_result_valid),         // IN STD_LOGIC;
        .s_axis_a_tready( ),             // OUT STD_LOGIC;
        .s_axis_a_tdata(world2_y_float64),          // IN STD_LOGIC_VECTOR(63 DOWNTO 0);
        .s_axis_b_tvalid(scaling2_result_valid),                        // IN STD_LOGIC;
        .s_axis_b_tready(scaling2_y_divisor_result_valid),             // OUT STD_LOGIC;
        .s_axis_b_tdata(scaling2_float64),           //: IN STD_LOGIC_VECTOR(63 DOWNTO 0);
        .m_axis_result_tvalid(scaled2_y_result_valid),   //: OUT STD_LOGIC;
        .m_axis_result_tready(1),                   //: IN STD_LOGIC;
        .m_axis_result_tdata(scaled2_y)             //: OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
        );   
        
///////////////////////////////////////////////////////////////////////
// STAGE 3 u, v calculations
    // Midpoint Calculation Variables
    //Camera 1 unit vector
    logic signed [63:0] u1;
    logic signed [63:0] u2;
    logic signed [63:0] u3;
    
    subtract_floats u1_calc(
        .aclk(clk_in),     
        .s_axis_a_tvalid(scaled1_x_result_valid),         // IN STD_LOGIC;
        .s_axis_a_tready( ),             // OUT STD_LOGIC;
        .s_axis_a_tdata(scaled1_x),          // IN STD_LOGIC_VECTOR(63 DOWNTO 0);
        .s_axis_b_tvalid(scaling1_result_valid),                        // IN STD_LOGIC;
        .s_axis_b_tready(scaling1_x_divisor_result_valid),             // OUT STD_LOGIC;
        .s_axis_b_tdata(scaling1_float64),           //: IN STD_LOGIC_VECTOR(63 DOWNTO 0);
        .m_axis_result_tvalid(scaled1_x_result_valid),   //: OUT STD_LOGIC;
        .m_axis_result_tready(1),                   //: IN STD_LOGIC;
        .m_axis_result_tdata(scaled1_x)             //: OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
        );
        
//    subtract_floats u2_calc(
//        .aclk(clk_in),     
//        .s_axis_a_tvalid(world1_x_result_valid),         // IN STD_LOGIC;
//        .s_axis_a_tready( ),             // OUT STD_LOGIC;
//        .s_axis_a_tdata(world1_x_float64),          // IN STD_LOGIC_VECTOR(63 DOWNTO 0);
//        .s_axis_b_tvalid(scaling1_result_valid),                        // IN STD_LOGIC;
//        .s_axis_b_tready(scaling1_x_divisor_result_valid),             // OUT STD_LOGIC;
//        .s_axis_b_tdata(scaling1_float64),           //: IN STD_LOGIC_VECTOR(63 DOWNTO 0);
//        .m_axis_result_tvalid(scaled1_x_result_valid),   //: OUT STD_LOGIC;
//        .m_axis_result_tready(1),                   //: IN STD_LOGIC;
//        .m_axis_result_tdata(scaled1_x)             //: OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
//        );
        
//    subtract_floats u3_calc(
//        .aclk(clk_in),     
//        .s_axis_a_tvalid(world1_x_result_valid),         // IN STD_LOGIC;
//        .s_axis_a_tready( ),             // OUT STD_LOGIC;
//        .s_axis_a_tdata(world1_x_float64),          // IN STD_LOGIC_VECTOR(63 DOWNTO 0);
//        .s_axis_b_tvalid(scaling1_result_valid),                        // IN STD_LOGIC;
//        .s_axis_b_tready(scaling1_x_divisor_result_valid),             // OUT STD_LOGIC;
//        .s_axis_b_tdata(scaling1_float64),           //: IN STD_LOGIC_VECTOR(63 DOWNTO 0);
//        .m_axis_result_tvalid(scaled1_x_result_valid),   //: OUT STD_LOGIC;
//        .m_axis_result_tready(1),                   //: IN STD_LOGIC;
//        .m_axis_result_tdata(scaled1_x)             //: OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
//        );
    logic signed [63:0] u1_delay;
    logic signed [63:0] u2_delay;
    logic signed [63:0] u3_delay;
    
    // Camera 2 unit vector
    logic signed [63:0] v1;
    logic signed [63:0] v2;
    logic signed [63:0] v3;

    logic signed [63:0] v1_delay;
    logic signed [63:0] v2_delay;
    logic signed [63:0] v3_delay;
    
    // scaling factor of where the two lines come closest
    logic signed [31:0] t_cpa;
///////////////////////////////////////////////////////////////////////            
    always_ff @(posedge clk_in)begin    
        // STAGE 1 [x y 1 ]* P_inv to get world coord X, Y (scale by third value)
        world1_x <= x1*P1_inv11 + y1*P1_inv21 + P1_inv31; 
        world1_y <= x1*P1_inv12 + y1*P1_inv22 + P1_inv32;
        scaling1 <= x1*P1_inv13 + y1*P1_inv23 + P1_inv33;
        
        
        world2_x <= x2*P2_inv11 + y2*P2_inv21 + P2_inv31;
        world2_y <= x2*P2_inv12 + y2*P2_inv22 + P2_inv32;
        scaling2 <= x2*P2_inv13 + y2*P2_inv23 + P2_inv33;
        
        
        // STAGE 2
        // divide both world1_x and world1_y by scaling1
        // divide both world2_x and world2_y by scaling2
        
        
        //STAGE 3
        u1 <= world1_x - C1_1;
        u2 <= world1_y - C1_2;
        u3 <= - C1_3;
        
        v1 <= world2_x - C2_1;
        v2 <= world2_y - C2_2;
        v3 <= - C2_3;
        
        // STAGE 4
        t_cpa <= -( (C1_1 - C2_1)*(u1 - v1) + (C1_2 - C2_2)*(u2 - v2) + (C1_3 - C2_3)*(u3 - v3) ); // break these up
        // divide t_cpa by ((u1 - v1)*(u1 - v1) + (u2 - v2)*(u2 - v2) + (u3 - v3)*(u3 - v3))
        // u1_delay
        // u2_delay
        // u3_delay
        // v1_delay
        // v2_delay
        // v3_delay
         
        // STAGE 5: individual multiplications
        world_x <= (C1_1 + t_cpa*u1 + C2_1 + t_cpa*v1) >> 1; // change these to delays, 
        world_y <= (C1_2 + t_cpa*u2 + C2_2 + t_cpa*v2) >> 1;
        world_z <= (C1_3 + t_cpa*u3 + C2_3 + t_cpa*v3) >> 1;
        
        // STAGE 6: add to get world_x, world_y, and world_z
        
        // STAGE 7
        // do individual multiplications
        // world_x_sq 
        // world_y_sq
        // world_z_sq
        
        // STAGE 8
        // add to get distance (change below to use _sq signals)
        distance <= world_x * world_x + world_y * world_y + world_z * world_z;
        
        // STAGE 9
        // compute sqrt
     
    end
    
    
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