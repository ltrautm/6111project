`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////

//

// Updated 8/10/2019 Lab 3

// Updated 8/12/2018 V2.lab5c

// Create Date: 10/1/2015 V1.0

// Design Name:

// Module Name: labkit

//

//////////////////////////////////////////////////////////////////////////////////



module top_level(

   input clk_100mhz,

   input[15:0] sw,

   input btnc, btnu, btnl, btnr, btnd,

   input [7:0] ja,

   input [2:0] jb,

   input [7:0] jc,

   input [2:0] jd,

   output   jbclk,

   output   jdclk,

   output  logic jdfour,

   output[3:0] vga_r,

   output[3:0] vga_b,

   output[3:0] vga_g,

   output vga_hs,

   output vga_vs,

   output led16_b, led16_g, led16_r,

   output led17_b, led17_g, led17_r,

   output[15:0] led,

   output ca, cb, cc, cd, ce, cf, cg, dp,  // segments a-g, dp

   output[7:0] an    // Display location 0-7

   );

    logic clk_65mhz;

    // create 65mhz system clock, happens to match 1024 x 768 XVGA timing

    clk_wiz_lab3 clkdivider(.clk_in1(clk_100mhz), .clk_out1(clk_65mhz));

    logic [31:0] selector;
    logic [24:0] center_x;
    logic [24:0] center_x2;
    logic [24:0] center_x3;
    logic [24:0] x_acc;
    logic [24:0] x_acc2;
    logic [24:0] x_acc3;
    logic [24:0] y_acc;
    logic [24:0] y_acc2;
    logic [24:0] y_acc3;
    logic [24:0] bit_count;
    logic [24:0] bit_count2;
    logic [24:0] bit_count3;
    
    assign selector = {7'd0, bit_count};
    display_8hex my_controller(
        .clk_in(clk_65mhz),
        .data_in(selector),
        .seg_out({cg, cf, ce, cd, cc, cb, ca}),
        .strobe_out(an)
    );


//    logic clk_50mhz;

//    clk_wiz_1 clk50(.clk_in1(clk_100mhz), .clk_out1(clk_50mhz));



    wire [31:0] data;      //  instantiate 7-segment display; display (8) 4-bit hex

    wire [6:0] segments;

    assign {cg, cf, ce, cd, cc, cb, ca} = segments[6:0];

    //display_8hex display(.clk_in(clk_65mhz),.data_in(data), .seg_out(segments), .strobe_out(an));

    //assign seg[6:0] = segments;

    assign  dp = 1'b1;  // turn off the period



    assign led = sw;                        // turn leds on

    assign data = {28'h0123456, sw[3:0]};   // display 0123456 + sw[3:0]

    assign led16_r = btnl;                  // left button -> red led

    assign led16_g = btnc;                  // center button -> green led

    assign led16_b = btnr;                  // right button -> blue led

    assign led17_r = btnl;

    assign led17_g = btnc;

    assign led17_b = btnr;

    

    

    ////Servo Controller//////

//    logic clkk_100mhz;

//    assign clkk_100mhz = clk_100mhz;



    //make a 50mhz clock

//    logic clk_50mhz = 1'b0;

    

//    logic county = 1'b0;

//    always_ff @(posedge clk_100mhz) begin

//        if (county == 1'b1) begin

//            county <= 1'b0;

//            clk_50mhz <= 1'b0;

//        end else begin

//            county <= 1'b1;

//            clk_50mhz <= 1'b1; 

//        end

    

//    end



    //try to use the 65 or 200 mhz clocks to generate a 50mhz clock

//    servo_wrapper myservo(.clk(clk_260mhz), .js(jd4));

    

    

    

    /////Display Initialization//////



    wire [10:0] hcount;    // pixel on current line

    wire [9:0] vcount;     // line number

    wire hsync, vsync, blank;

    wire [11:0] pixel;

    wire [11:0] pixel2;
    
    wire [11:0] pixel3;

    reg [11:0] rgb;    

    xvga xvga1(.vclock_in(clk_65mhz),.hcount_out(hcount),.vcount_out(vcount),

          .hsync_out(hsync),.vsync_out(vsync),.blank_out(blank));





    // btnc button is user reset

    wire reset;

    debounce db1(.reset_in(reset),.clock_in(clk_65mhz),.noisy_in(btnc),.clean_out(reset));

   

   ////////////////////////////////////////////CAMERA_1////////////////////////////////////////////                        

    

    logic [11:0] cam1;

    logic pclk_in;

    logic [11:0] frame_buff_out;

    logic [15:0] output_pixels;

    logic [15:0] old_output_pixels;

    logic [12:0] processed_pixels;

    logic valid_pixel;

    logic frame_done_out;

    

    logic she_valid;

    assign she_valid = valid_pixel & ~sw[7];

    

    logic [16:0] pixel_addr_in;

    logic [16:0] pixel_addr_out;

    

    

    blk_mem_gen_0 jojos_bram(.addra(pixel_addr_in), //take a pic based on switch and  

                             .clka(pclk_in),

                             .dina(processed_pixels),

                             .wea(she_valid),

                             .addrb(pixel_addr_out),

                             .clkb(clk_65mhz),

                             .doutb(frame_buff_out));

    

    always_ff @(posedge pclk_in)begin

        if (frame_done_out)begin

            pixel_addr_in <= 17'b0;  

        end else if (valid_pixel)begin

            pixel_addr_in <= pixel_addr_in +1;  

        end

    end

    

    always_ff @(posedge clk_65mhz) begin

        old_output_pixels <= output_pixels;

        processed_pixels = {output_pixels[15:12],output_pixels[10:7],output_pixels[4:1]};            

    end

  

    assign pixel_addr_out = hcount+vcount*32'd320;

//    assign cam1 = ((hcount<320) &&  (vcount<240))?frame_buff_out:12'h000;

    assign cam1 = frame_buff_out;

                                  

                                  

    camera_wrapper my_wrap(

                           .clk_65mhz(clk_65mhz),

                           .j0(jd[0]), .j1(jd[1]), .j2(jd[2]), //WAS JB

                           .ju(jc),  //WAS JA

                           .output_pixels(output_pixels),

                           .valid_pixel(valid_pixel),

                           .jclk(jdclk),

                           .pclk_in(pclk_in),

                           .frame_done_out(frame_done_out));

                           

                           

   ////////////////////////////////////////////CAMERA_2////////////////////////////////////////////                        

   

    logic [11:0] cam2;

    logic pclk_in2;

    logic [11:0] frame_buff_out2;

    logic [15:0] output_pixels2;

    logic [15:0] old_output_pixels2;

    logic [12:0] processed_pixels2;

    logic valid_pixel2;

    logic frame_done_out2;

    

    logic she_valid2;

    assign she_valid2 = valid_pixel2 & ~sw[7];

    

    logic [16:0] pixel_addr_in2;

    logic [16:0] pixel_addr_out2;

    

    

    

    blk_mem_gen_1 leileis_bram(.addra(pixel_addr_in2), //take a pic based on switch and  

                             .clka(pclk_in2),

                             .dina(processed_pixels2),

                             .wea(she_valid2),

                             .addrb(pixel_addr_out2),

                             .clkb(clk_65mhz),

                             .doutb(frame_buff_out2));

    

    always_ff @(posedge pclk_in2)begin

        if (frame_done_out2)begin

            pixel_addr_in2 <= 17'b0;  

        end else if (valid_pixel2)begin

            pixel_addr_in2 <= pixel_addr_in2 +1;  

        end

    end

    

    always_ff @(posedge clk_65mhz) begin

        old_output_pixels2 <= output_pixels2;

        processed_pixels2 = {output_pixels2[15:12],output_pixels2[10:7],output_pixels2[4:1]};            

    end

  

    assign pixel_addr_out2 = hcount+vcount*32'd320;

    assign cam2 = frame_buff_out2;

                                  

                                  

    camera_wrapper my_wrap2(

                           .clk_65mhz(clk_65mhz),

                           .j0(jb[0]), .j1(jb[1]), .j2(jb[2]),

                           .ju(ja),

                           .output_pixels(output_pixels2),

                           .valid_pixel(valid_pixel2),

                           .jclk(jbclk),

                           .pclk_in(pclk_in2),

                           .frame_done_out(frame_done_out2));

   

   

   

   

   /////////end CAMERA_2//////////

   

   ////Camera 1 and 2 fusion on display

   logic [11:0] cam;

   

//   if ((hcount<320) &&  (vcount<240)) cam <= cam1;

//   else cam <= 12'h000;

                                  



    wire phsync,pvsync,pblank;

    

//    display_select ds(.vclock_in(clk_65mhz), .hsync_in(hsync),.vsync_in(vsync),.blank_in(blank),

//                .phsync_out(phsync),.pvsync_out(pvsync),.pblank_out(pblank));

                

    logic clk_200mhz;

    logic clk_200mhz2;
    logic clk_200mhz3;

    logic inbound1;
    logic inbound2;
    assign inbound1 = hcount > 11'd20 && hcount < 11'd340 &&  vcount < 10'd240;
    assign inbound2 = hcount > 11'd340 && hcount < 11'd660 && vcount < 10'd240;            

    display_select ds(.vclock_in(clk_65mhz),

//                        .selectors(sw[15:14]), 

                        .processing(sw[13:10]),

                        .pixel_in(cam1),
                        
                        .inBounds(inbound1),

                        .hcount_in(hcount),

                        .vcount_in(vcount),

                        .hsync_in(hsync),

                        .vsync_in(vsync),

                        .blank_in(blank),

                        .phsync_out(phsync),

                        .pvsync_out(pvsync),

                        .pblank_out(pblank),

                        .pixel_out(pixel),

                        .clk_200mhz(clk_200mhz),
                        .center_x(center_x),
                        .x_acc(x_acc),
                        .y_acc(y_acc),
                        .bit_count(bit_count));

                        

    display_select ds2(.vclock_in(clk_65mhz),

//                        .selectors(sw[15:14]), 

                        .processing(sw[13:10]),

                        .pixel_in(cam2),
                        .inBounds(inbound2),

                        .hcount_in(hcount),

                        .vcount_in(vcount),

                        .hsync_in(hsync),

                        .vsync_in(vsync),

                        .blank_in(blank),

                        .phsync_out(phsync),
 
                        .pvsync_out(pvsync),

                        .pblank_out(pblank),

                        .pixel_out(pixel2),

                        .clk_200mhz(clk_200mhz2),
                        .center_x(center_x2),
                        .x_acc(x_acc2),
                        .y_acc(y_acc2),
                        .bit_count(bit_count2));

    display_select ds3(
            .vclock_in(clk_65mhz),        // 65MHz clock
            .hcount_in(hcount), // horizontal index of current pixel (0..1023)
            .vcount_in(vcount), // vertical index of current pixel (0..767)
            .hsync_in(hsync),         // XVGA horizontal sync signal (active low)
            .vsync_in(vsync),         // XVGA vertical sync signal (active low)
            .blank_in(blank),         // XVGA blanking (1 means output black pixel)

//   input [1:0] selectors,  // selects between normal or processed image
            .processing(sw[13:10]), // selects which kind of process is being done
            .pixel_in(pixel3),
            .inBounds(vcount >= 10'd240),
            .phsync_out(phsync),       // pong game's horizontal sync
            .pvsync_out(pvsync),       // pong game's vertical sync
            .pblank_out(pblank),       // pong game's blanking
            .pixel_out(pixel3),  // pong game's pixel  // r=11:8, g=7:4, b=3:0
            .clk_200mhz(clk_200mhz3),
            .center_x(center_x3), ///testing centroid_x
            .x_acc(x_acc3),
            .y_acc(y_acc3),
             .bit_count(bit_count3));




    wire border = (hcount==0 | hcount==1023 | vcount==0 | vcount==767 |

                   hcount == 512 | vcount == 384);



    reg b,hs,vs;

    always_ff @(posedge clk_65mhz) begin

      if (sw[1:0] == 2'b01) begin

         // 1 pixel outline of visible area (white)

         hs <= hsync;

         vs <= vsync;

         b <= blank;

         rgb <= {12{border}};

      end else if (sw[1:0] == 2'b10) begin
      end else if (sw[1:0] == 2'b10) begin

         // color bars

         hs <= hsync;

         vs <= vsync;

         b <= blank;

         rgb <= {{4{hcount[8]}}, {4{hcount[7]}}, {4{hcount[6]}}} ;

      end else begin

         // default: pong

         hs <= phsync;

         vs <= pvsync;

         b <= pblank;

         //rgb <= pixel;

         if ((hcount<320) &&  (vcount<240)) cam <= pixel; //left camera display

         else if ((hcount > 320) && (vcount<240) && (hcount < 641)) cam <= pixel2; //right camera display

//         else if ((hcount<320) && (vcount>240) && (vcount<480)) cam <= pixel; //eroded left camera

         else cam <= 12'h000;

         rgb <= cam;

      end

    end



    // the following lines are required for the Nexys4 VGA circuit - do not change

    assign vga_r = ~b ? rgb[11:8]: 0;

    assign vga_g = ~b ? rgb[7:4] : 0;

    assign vga_b = ~b ? rgb[3:0] : 0;



    assign vga_hs = ~hs;

    assign vga_vs = ~vs;



    servo_wrapper myservo(.clk(clk_200mhz), .js(jdfour));



endmodule



////////////////////////////////////////////////////////////////////////////////

//

// display-select: wrapper for object detection

//

////////////////////////////////////////////////////////////////////////////////



module display_select (

   input vclock_in,        // 65MHz clock

   input [10:0] hcount_in, // horizontal index of current pixel (0..1023)

   input [9:0]  vcount_in, // vertical index of current pixel (0..767)

   input hsync_in,         // XVGA horizontal sync signal (active low)

   input vsync_in,         // XVGA vertical sync signal (active low)

   input blank_in,         // XVGA blanking (1 means output black pixel)

//   input [1:0] selectors,  // selects between normal or processed image

   input [3:0] processing, // selects which kind of process is being done

   input [11:0] pixel_in,

   input inBounds,

   output logic phsync_out,       // pong game's horizontal sync

   output logic pvsync_out,       // pong game's vertical sync

   output logic pblank_out,       // pong game's blanking

   output logic [11:0] pixel_out,  // pong game's pixel  // r=11:8, g=7:4, b=3:0

   output logic clk_200mhz,
   
   output [24:0] center_x, ///testing centroid_x
   output logic [24:0] x_acc,
   output logic [24:0] y_acc,
   output logic [24:0] bit_count
   );

    

    

       //centroid stuff

   logic [11:0] centroid;

   logic [11:0] pixel_outta;

   assign pixel_out = centroid + pixel_outta;

   logic [24:0] centroid_x;
   assign center_x = centroid_x;
   logic [24:0] centroid_y;
    
    
   //end centroid stuff

   

    //changing pixel to make it useful for ob det//////

    logic [23:0] pixxel_in;

    assign pixxel_in = {pixel_in[11:8], 4'b0, pixel_in[7:4], 4'b0, pixel_in[3:0], 4'b0};

    

   /////object_detection///

      object_detection ob_det(.clk(vclock_in),
                            .hcount(hcount_in),
                            .vcount(vcount_in),
                            .inBounds(inBounds),
                            .dilate(processing[1]), 

                            .erode(processing[0]), 

                            .thresholds(processing[3:2]),

                            .pixel_in(pixxel_in),

                            .centroid_x(centroid_x), 

                            .centroid_y(centroid_y), 

                            .pixel_out(pixel_outta),
                            
                            .x_acc(x_acc),
                            .y_acc(y_acc),
                            .bit_count(bit_count));

   



   assign phsync_out = hsync_in;

   assign pvsync_out = vsync_in;

   assign pblank_out = blank_in;

  

   

   picture_blob  dulcecito(.pixel_clk_in(vclock_in), 

                            .x_in(11'd200), 

                            .hcount_in(hcount_in),

                            .y_in(10'd200), 

                            .vcount_in(vcount_in), 

                            .pixel_in(pixel_in),

//                            .original(selectors[1]), 

//                            .processed(selectors[0]), 

                            .process_selects(processing), 

      //                      .pixel_out(pixel_outta),

                            .clk_260mhz(clk_200mhz));

                            

                            

    blob #(.WIDTH(16),.HEIGHT(16),.COLOR(12'hFF0))   // yellow!

     the_centroid(.pixel_clk_in(vclock_in),

                    .hcount_in(hcount_in),

                    .vcount_in(vcount_in),

                    .centroid_x(centroid_x),

                    .centroid_y(centroid_y), 

//                    .original(selectors[1]), 

//                    .processed(selectors[0]), 

      //              .process_selects(processing), 

                    .pixel_out(centroid)); 



endmodule



///////////////////////////////////////////////////////////////////////////////

//

// picture_blob: displays the image manipu40.88lated 

//

///////////////////////////////////////////////////////////////////////////////



module picture_blob

   #(parameter WIDTH = 320,     // default picture width

               HEIGHT = 240)    // default picture height

   (input pixel_clk_in,

    input [10:0] x_in,hcount_in,

    input [9:0] y_in,vcount_in,

    input [11:0] pixel_in,

//    input original, //selection of original or processed image

//    input processed,

    input [3:0] process_selects, // allows us to see erosion and dilation, and to choose hue thresholds

    //output logic [11:0] pixel_out,

    output logic clk_260mhz);



   //logic [15:0] image_addr;   // num of bits for 256*240 ROM

   //logic [7:0] image_bits, red_mapped, green_mapped, blue_mapped;

   





   // calculate rom address and read the location

//   assign image_addr = (hcount_in-x_in) + (vcount_in-y_in) * WIDTH;

//   m_and_m_rom image_rom(.clka(pixel_clk_in), .addra(image_addr), .douta(image_bits));



   // use color map to create 4 bits R, 4 bits G, 4 bits B

   // since the image is greyscale, just replicate the red pixels

   // and not bother with the other two color maps.

//   red_rom rcm(.clka(pixel_clk_in), .addra(image_bits), .douta(red_mapped));

//   green_rom gcm (.clka(pixel_clk_in), .addra(image_bits), .douta(green_mapped));

//   blue_rom bcm (.clka(pixel_clk_in), .addra(image_bits), .douta(blue_mapped));

   // note the one clock cycle delay in pixel!

   

   //logic [9:0] yy;

   //logic [9:0] xx;

//   logic [23:0] pixel_in; //pixel that goes in to be binarized

//   logic [11:0] pixxel; //output from image processing

   

//   logic clk_260mhz;

   clk_wiz_0 clkmulti(.clk_in1(pixel_clk_in), .clk_out1(clk_260mhz));

   

   //logic [23:0] pixxel_in;

   

  // assign pixxel_in = {pixel_in[11:8], 4'b0, pixel_in[7:4], 4'b0, pixel_in[3:0], 4'b0};

   

   //logic centro_listo;

   

//   object_detection ob_det(.clk(clk_260mhz), 

//                            .dilate(process_selects[1]), 

//                            .erode(process_selects[0]), 

//                            .thresholds(process_selects[3:2]),

//                            .pixel_in(pixxel_in),

//                            .centroid_x(xx), 

//                            .centroid_y(yy), 

//                            .pixel_out(pixel_out));

   





   

//   always_ff @ (posedge pixel_clk_in) begin

//        if ((hcount_in >= (x_in) && hcount_in < (x_in+WIDTH)) &&

//           (vcount_in >= y_in && vcount_in < (y_in+HEIGHT))) begin

//           if (processed) begin

//                pixel_in <= {red_mapped, green_mapped, blue_mapped};

//                pixel_out <= pixxel;

//           end else if (original) begin

//                pixel_out <= {red_mapped[7:4], green_mapped[7:4], blue_mapped[7:4]};

//           end 

//        end else pixel_out <= 0;

           

   

//   end

endmodule



////////BLOB////////

module blob

   #(parameter WIDTH = 64,            // default width: 64 pixels

               HEIGHT = 64,           // default height: 64 pixels

               COLOR = 12'hFFF)  // default color: white

   (input pixel_clk_in,

    input [10:0] hcount_in,

    input [9:0] vcount_in,

    input [24:0] centroid_x,

    input [24:0] centroid_y,

//    input original, //selection of original or processed image

//    input processed,

    //input [3:0] process_selects, // allows us to see erosion and dilation, and to choose hue thresholds

    output logic [11:0] pixel_out);

   

    logic clk_200mhz;

    clk_wiz_0 clkmulti(.clk_in1(pixel_clk_in), .clk_out1(clk_200mhz));

   

    //logic [24:0] yy;//y-coordinate of center

    //logic [24:0] xx;//x-coordinate of the center

    //logic [23:0] pixel_in; //pixel that goes in to be binarized

    //logic [11:0] pixxel; //output from image processing

   

    

   //logic centro_listo; // the center is ready to be displayed

//    object_detection ob_det(.clk(clk_200mhz), .dilate(process_selects[1]), .erode(process_selects[0]), .thresholds(process_selects[3:2]),

//         .pixel_in(pixel_in), .centroid_x(xx), .centroid_y(yy), .pixel_out(pixxel));

  

  

   // Jeana Code

   

//    parameter IDLE = 2'b01;

//    parameter RENDER = 2'b10;

//    logic [1:0] state = IDLE; 

    

//    always_ff @(posedge pixel_clk_in) begin

//        case (state)

//            IDLE: begin

//                if(centro_listo)begin

//                    state <= RENDER;

//                end

//            end

//            RENDER: begin

//                if ((hcount_in >= xx && hcount_in < (xx + WIDTH)) && 

//                    (vcount_in >= yy && vcount_in < (yy + HEIGHT))) begin

//                    pixel_out <= COLOR;

//                end else begin

//                    pixel_out <= 0;

//                end

//                state <= IDLE;

//            end

//        endcase      

//    end   

    

   // Ryan Code

   

           



   always_ff @(posedge pixel_clk_in) begin

        if ((hcount_in >= centroid_x && hcount_in < (centroid_x+WIDTH)) &&

           (vcount_in >= centroid_y && vcount_in < (centroid_y+HEIGHT))) begin

            pixel_out <= COLOR;

        end else begin

            pixel_out <= 0;

        end

          

   end



endmodule







///////ENDBLOB///////



///////////////////////////////////////////////////////////////////////////////

//

// Pushbutton Debounce Module (video version - 24 bits)  

//

///////////////////////////////////////////////////////////////////////////////



module debounce (input reset_in, clock_in, noisy_in,

                 output reg clean_out);



   reg [19:0] count;

   reg new_input;



   always_ff @(posedge clock_in)

     if (reset_in) begin 

        new_input <= noisy_in; 

        clean_out <= noisy_in; 

        count <= 0; end

     else if (noisy_in != new_input) begin new_input<=noisy_in; count <= 0; end

     else if (count == 650000) clean_out <= new_input;

     else count <= count+1;





endmodule



//////////////////////////////////////////////////////////////////////////////////

// Engineer:   g.p.hom

// 

// Create Date:    18:18:59 04/21/2013 

// Module Name:    display_8hex 

// Description:  Display 8 hex numbers on 7 segment display

//

//////////////////////////////////////////////////////////////////////////////////



module display_8hex(

    input clk_in,                 // system clock

    input [31:0] data_in,         // 8 hex numbers, msb first

    output reg [6:0] seg_out,     // seven segment display output

    output reg [7:0] strobe_out   // digit strobe

    );



    localparam bits = 13;

     

    reg [bits:0] counter = 0;  // clear on power up

     

    wire [6:0] segments[15:0]; // 16 7 bit memorys

    assign segments[0]  = 7'b100_0000;  // inverted logic

    assign segments[1]  = 7'b111_1001;  // gfedcba

    assign segments[2]  = 7'b010_0100;

    assign segments[3]  = 7'b011_0000;

    assign segments[4]  = 7'b001_1001;

    assign segments[5]  = 7'b001_0010;

    assign segments[6]  = 7'b000_0010;

    assign segments[7]  = 7'b111_1000;

    assign segments[8]  = 7'b000_0000;

    assign segments[9]  = 7'b001_1000;

    assign segments[10] = 7'b000_1000;

    assign segments[11] = 7'b000_0011;

    assign segments[12] = 7'b010_0111;

    assign segments[13] = 7'b010_0001;

    assign segments[14] = 7'b000_0110;

    assign segments[15] = 7'b000_1110;

     

    always_ff @(posedge clk_in) begin

      // Here I am using a counter and select 3 bits which provides

      // a reasonable refresh rate starting the left most digit

      // and moving left.

      counter <= counter + 1;

      case (counter[bits:bits-2])

          3'b000: begin  // use the MSB 4 bits

                  seg_out <= segments[data_in[31:28]];

                  strobe_out <= 8'b0111_1111 ;

                 end



          3'b001: begin

                  seg_out <= segments[data_in[27:24]];

                  strobe_out <= 8'b1011_1111 ;

                 end



          3'b010: begin

                   seg_out <= segments[data_in[23:20]];

                   strobe_out <= 8'b1101_1111 ;

                  end

          3'b011: begin

                  seg_out <= segments[data_in[19:16]];

                  strobe_out <= 8'b1110_1111;        

                 end

          3'b100: begin

                  seg_out <= segments[data_in[15:12]];

                  strobe_out <= 8'b1111_0111;

                 end



          3'b101: begin

                  seg_out <= segments[data_in[11:8]];

                  strobe_out <= 8'b1111_1011;

                 end



          3'b110: begin

                   seg_out <= segments[data_in[7:4]];

                   strobe_out <= 8'b1111_1101;

                  end

          3'b111: begin

                  seg_out <= segments[data_in[3:0]];

                  strobe_out <= 8'b1111_1110;

                 end



       endcase

      end



endmodule



//////////////////////////////////////////////////////////////////////////////////

// Update: 8/8/2019 GH 

// Create Date: 10/02/2015 02:05:19 AM

// Module Name: xvga

//

// xvga: Generate VGA display signals (1024 x 768 @ 60Hz)

//

//                              ---- HORIZONTAL -----     ------VERTICAL -----

//                              Active                    Active

//                    Freq      Video   FP  Sync   BP      Video   FP  Sync  BP

//   640x480, 60Hz    25.175    640     16    96   48       480    11   2    31

//   800x600, 60Hz    40.000    800     40   128   88       600     1   4    23

//   1024x768, 60Hz   65.000    1024    24   136  160       768     3   6    29

//   1280x1024, 60Hz  108.00    1280    48   112  248       768     1   3    38

//   1280x720p 60Hz   75.25     1280    72    80  216       720     3   5    30

//   1920x1080 60Hz   148.5     1920    88    44  148      1080     4   5    36

//

// change the clock frequency, front porches, sync's, and back porches to create 

// other screen resolutions

////////////////////////////////////////////////////////////////////////////////



module xvga(input vclock_in,

            output reg [10:0] hcount_out,    // pixel number on current line

            output reg [9:0] vcount_out,     // line number

            output reg vsync_out, hsync_out,

            output reg blank_out);



   parameter DISPLAY_WIDTH  = 1024;      // display width

   parameter DISPLAY_HEIGHT = 768;       // number of lines



   parameter  H_FP = 24;                 // horizontal front porch

   parameter  H_SYNC_PULSE = 136;        // horizontal sync

   parameter  H_BP = 160;                // horizontal back porch



   parameter  V_FP = 3;                  // vertical front porch

   parameter  V_SYNC_PULSE = 6;          // vertical sync 

   parameter  V_BP = 29;                 // vertical back porch



   // horizontal: 1344 pixels total

   // display 1024 pixels per line

   reg hblank,vblank;

   wire hsyncon,hsyncoff,hreset,hblankon;

   assign hblankon = (hcount_out == (DISPLAY_WIDTH -1));    

   assign hsyncon = (hcount_out == (DISPLAY_WIDTH + H_FP - 1));  //1047

   assign hsyncoff = (hcount_out == (DISPLAY_WIDTH + H_FP + H_SYNC_PULSE - 1));  // 1183

   assign hreset = (hcount_out == (DISPLAY_WIDTH + H_FP + H_SYNC_PULSE + H_BP - 1));  //1343



   // vertical: 806 lines total

   // display 768 lines

   wire vsyncon,vsyncoff,vreset,vblankon;

   assign vblankon = hreset & (vcount_out == (DISPLAY_HEIGHT - 1));   // 767 

   assign vsyncon = hreset & (vcount_out == (DISPLAY_HEIGHT + V_FP - 1));  // 771

   assign vsyncoff = hreset & (vcount_out == (DISPLAY_HEIGHT + V_FP + V_SYNC_PULSE - 1));  // 777

   assign vreset = hreset & (vcount_out == (DISPLAY_HEIGHT + V_FP + V_SYNC_PULSE + V_BP - 1)); // 805



   // sync and blanking

   wire next_hblank,next_vblank;

   assign next_hblank = hreset ? 0 : hblankon ? 1 : hblank;

   assign next_vblank = vreset ? 0 : vblankon ? 1 : vblank;

   always_ff @(posedge vclock_in) begin

      hcount_out <= hreset ? 0 : hcount_out + 1;

      hblank <= next_hblank;

      hsync_out <= hsyncon ? 0 : hsyncoff ? 1 : hsync_out;  // active low



      vcount_out <= hreset ? (vreset ? 0 : vcount_out + 1) : vcount_out;

      vblank <= next_vblank;

      vsync_out <= vsyncon ? 0 : vsyncoff ? 1 : vsync_out;  // active low



      blank_out <= next_vblank | (next_hblank & ~hreset);

   end

endmodule