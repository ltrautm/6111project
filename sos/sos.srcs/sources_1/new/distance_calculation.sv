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
    logic signed [16:0] world1_x;
    logic signed [16:0] world1_y;
    logic signed [16:0] scaling1;
    
    logic signed [16:0] scaled1_x;
    logic signed [16:0] scaled1_y;
    
    
    //Camera 2 world vector
    logic signed [16:0] world2_x;
    logic signed [16:0] world2_y;
    logic signed [16:0] scaling2;
    
    logic signed [16:0] scaled2_x;
    logic signed [16:0] scaled2_y;
    
    
    // Midpoint Calculation Variables
    //Camera 1 unit vector
    logic signed [16:0] u1;
    logic signed [16:0] u2;
    logic signed [16:0] u3;
    
    // Camera 2 unit vector
    logic signed [16:0] v1;
    logic signed [16:0] v2;
    logic signed [16:0] v3;
    
    // scaling factor of where the two lines come closest
    logic signed [16:0] t_cpa;
    
    
//    logic [16:0] divisor;
//    get_divisor eq1(
//        .clk_in(clk_in),
//        .number(scaling1),
//        .divisor(divisor)     
//    );
    logic div_1a_valid, div_1a_ready, div_1b_valid, div_1b_ready,
          div_1result_valid, div_1result_ready;
    
    logic dividend_result_valid;
    logic divisor_result_valid;
    
    logic signed [31:0] dividend_int32 = 32'd15;
    logic signed [63:0] dividend_float64;
    logic signed [31:0] divisor_int32 = 32'd2;
    logic signed [63:0] divisor_float64;
    
    logic division_result_valid;
    logic signed [63:0] division_result;

//    logic conv1_a_tvalid;
//    logic conv1_a_tready;
//    logic [31:0] conv1_a_tdata;
//    logic conv1_result_tvalid;
//    logic conv1_result_tready;
//    logic [63:0] conv1_result_tdata;
    
//    assign conv1_a_tvalid = 1;
//    assign conv1_a_tdata = dividend_int32;
//    assign dividend_float64 = conv1_result_tdata;
    
    int_to_float conv1(
        .aclk(clk_in),                              //: IN STD_LOGIC;
        .s_axis_a_tvalid(1),                        //: IN STD_LOGIC;
        .s_axis_a_tready( ),                //: OUT STD_LOGIC;
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
    
        
//    floating_point_0 div2(
//        .aclk(clk_in),     
//        .s_axis_a_tvalid(), // IN STD_LOGIC;
//        .s_axis_a_tready(), // OUT STD_LOGIC;
//        .s_axis_a_tdata(world1_y), // IN STD_LOGIC_VECTOR(63 DOWNTO 0);
//        .s_axis_b_tvalid(), // IN STD_LOGIC;
//        .s_axis_b_tready(), // OUT STD_LOGIC;
//        .s_axis_b_tdata(scaling1), //: IN STD_LOGIC_VECTOR(63 DOWNTO 0);
//        .m_axis_result_tvalid(), //: OUT STD_LOGIC;
//        .m_axis_result_tready(), //: IN STD_LOGIC;
//        .m_axis_result_tdata(scaled1_y) //: OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
//        );
    
//    floating_point_0 div3(
//        .aclk(clk_in),     
//        .s_axis_a_tvalid(), // IN STD_LOGIC;
//        .s_axis_a_tready(), // OUT STD_LOGIC;
//        .s_axis_a_tdata(world2_x), // IN STD_LOGIC_VECTOR(63 DOWNTO 0);
//        .s_axis_b_tvalid(), // IN STD_LOGIC;
//        .s_axis_b_tready(), // OUT STD_LOGIC;
//        .s_axis_b_tdata(scaling2), //: IN STD_LOGIC_VECTOR(63 DOWNTO 0);
//        .m_axis_result_tvalid(), //: OUT STD_LOGIC;
//        .m_axis_result_tready(), //: IN STD_LOGIC;
//        .m_axis_result_tdata(scaled2_x) //: OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
//        );
    
//    floating_point_0 div4(
//        .aclk(clk_in),     
//        .s_axis_a_tvalid(), // IN STD_LOGIC;
//        .s_axis_a_tready(), // OUT STD_LOGIC;
//        .s_axis_a_tdata(world2_y), // IN STD_LOGIC_VECTOR(63 DOWNTO 0);
//        .s_axis_b_tvalid(), // IN STD_LOGIC;
//        .s_axis_b_tready(), // OUT STD_LOGIC;
//        .s_axis_b_tdata(scaling2), //: IN STD_LOGIC_VECTOR(63 DOWNTO 0);
//        .m_axis_result_tvalid(), //: OUT STD_LOGIC;
//        .m_axis_result_tready(), //: IN STD_LOGIC;
//        .m_axis_result_tdata(scaled2_y) //: OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
//        );
            
    always_ff @(posedge clk_in)begin    
        // STAGE 1
        world1_x <= x1*P1_inv11 + y1*P1_inv21 + 1*P1_inv31;
        world1_y <= x1*P1_inv12 + y1*P1_inv22 + 1*P1_inv32;
        scaling1 <= x1*P1_inv13 + y1*P1_inv23 + 1*P1_inv33;
        // divide both world1_x and world1_y by scaling1
        
        world2_x <= x2*P2_inv11 + y2*P2_inv21 + 1*P2_inv31;
        world2_y <= x2*P2_inv12 + y2*P2_inv22 + 1*P2_inv32;
        scaling2 <= x2*P2_inv13 + y2*P2_inv23 + 1*P2_inv33;
        // divide both world2_x and world2_y by scaling2
        
        //STAGE 2
        u1 <= world1_x - C1_1;
        u2 <= world1_y - C1_2;
        u3 <= - C1_3;
        
        v1 <= world2_x - C2_1;
        v2 <= world2_y - C2_2;
        v3 <= - C2_3;
        
        // STAGE 3
        t_cpa <= -( (C1_1 - C2_1)*(u1 - v1) + (C1_2 - C2_2)*(u2 - v2) + (C1_3 - C2_3)*(u3 - v3) ); // break these up
        // divide t_cpa by ((u1 - v1)*(u1 - v1) + (u2 - v2)*(u2 - v2) + (u3 - v3)*(u3 - v3))
        // u1_delay
        // u2_delay
        // u3_delay
        // v1_delay
        // v2_delay
        // v3_delay
         
        // STAGE 4
        world_x <= (C1_1 + t_cpa*u1 + C2_1 + t_cpa*v1) >> 1; // change these to delays
        world_y <= (C1_2 + t_cpa*u2 + C2_2 + t_cpa*v2) >> 1;
        world_z <= (C1_3 + t_cpa*u3 + C2_3 + t_cpa*v3) >> 1;
        
        // STAGE 5
        // do individual multiplications
        // world_x_sq 
        // world_y_sq
        // world_z_sq
        
        // STAGE 6
        // add to get distance (change below to use _sq signals)
        distance <= world_x * world_x + world_y * world_y + world_z * world_z;
        
        // STAGE 7
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
// The divider module divides one number by another. It
// produces a signal named "ready" when the quotient output
// is ready, and takes a signal named "start" to indicate
// the the input dividend and divider is ready.
// sign -- 0 for unsigned, 1 for twos complement

// It uses a simple restoring divide algorithm.
// http://en.wikipedia.org/wiki/Division_(digital)#Restoring_division
// 
// Author Logan Williams, updated 11/25/2018 gph

module divider #(parameter WIDTH = 8) 
  (input clk, sign, start,
   input [WIDTH-1:0] dividend, 
   input [WIDTH-1:0] divider,
   output reg [WIDTH-1:0] quotient,
   output [WIDTH-1:0] remainder,
   output ready);

   reg [WIDTH-1:0]  quotient_temp;
   reg [WIDTH*2-1:0] dividend_copy, divider_copy, diff;
   reg negative_output;
   
   assign remainder = (!negative_output) ?
             dividend_copy[WIDTH-1:0] : ~dividend_copy[WIDTH-1:0] + 1'b1;

   reg [5:0] a_bit = 0;
   reg del_ready = 1;
   assign ready = (a_bit==0) & ~del_ready;

   wire [WIDTH-2:0] zeros = 0;
   initial a_bit = 0;
   initial negative_output = 0;
   always @( posedge clk ) begin
      del_ready <= (a_bit==0);
      if( start ) begin

         a_bit = WIDTH;
         quotient = 0;
         quotient_temp = 0;
         dividend_copy = (!sign || !dividend[WIDTH-1]) ?
                         {1'b0,zeros,dividend} :  
                         {1'b0,zeros,~dividend + 1'b1};
         divider_copy = (!sign || !divider[WIDTH-1]) ?
			 {1'b0,divider,zeros} :
			 {1'b0,~divider + 1'b1,zeros};

         negative_output = sign &&
                           ((divider[WIDTH-1] && !dividend[WIDTH-1])
                            ||(!divider[WIDTH-1] && dividend[WIDTH-1]));
       end
      else if ( a_bit > 0 ) begin
         diff = dividend_copy - divider_copy;
         quotient_temp = quotient_temp << 1;
         if( !diff[WIDTH*2-1] ) begin
            dividend_copy = diff;
            quotient_temp[0] = 1'd1;
         end
         quotient = (!negative_output) ?
                    quotient_temp :
                    ~quotient_temp + 1'b1;
         divider_copy = divider_copy >> 1;
         a_bit = a_bit - 1'b1;
      end
   end
endmodule // divider
