`timescale 1ns / 1ps

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
    logic [24:0] center_y;
    logic [24:0] center_y2;
    logic [24:0] center_y3;
    logic [24:0] x_acc;
    logic [24:0] x_acc2;
    logic [24:0] x_acc3;
    logic [24:0] y_acc;
    logic [24:0] y_acc2;
    logic [24:0] y_acc3;
    logic [24:0] bit_count;
    logic [24:0] bit_count2;
    logic [24:0] bit_count3;


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
 
//////////////// DISTANCE /////////////////////////////////
    logic signed [31:0] distance;
    logic signed [31:0] world_x;
    logic signed [31:0] world_y;
    logic signed [31:0] world_z;
    logic [4:0] jitter_counter = 5'd0;
    logic [28:0] jitter_accumulator_x1 = 29'd0;
    logic [28:0] jitter_accumulator_y1 = 29'd0;
    logic [28:0] jitter_accumulator_x2 = 29'd0;
    logic [28:0] jitter_accumulator_y2 = 29'd0;
    

    logic [24:0] nice_centroid_x1;
    logic [24:0] nice_centroid_y1;
    logic [24:0] nice_centroid_x2;
    logic [24:0] nice_centroid_y2;
    
    always_ff@(posedge clk_65mhz)begin
        if(jitter_counter == 15)begin
            nice_centroid_x1 <= jitter_accumulator_x1 >> 4;
            nice_centroid_y1 <= jitter_accumulator_y1 >> 4;
            
            nice_centroid_x2 <= jitter_accumulator_x2 >> 4;
            nice_centroid_y2 <= jitter_accumulator_y2 >> 4;
            
            jitter_counter <= 0;
            
            jitter_accumulator_x1 <= 0;
            jitter_accumulator_y1 <= 0;
            jitter_accumulator_x2 <= 0;
            jitter_accumulator_y2 <= 0;
        end else begin

            jitter_counter <= jitter_counter + 1;
            
            jitter_accumulator_x1 <= jitter_accumulator_x1 + center_x;
            jitter_accumulator_y1 <= jitter_accumulator_y1 + center_y;
            
            jitter_accumulator_x2 <= jitter_accumulator_x2 + center_x2;
            jitter_accumulator_y2 <= jitter_accumulator_y2 + center_y2;

        end
    end
    
//    logic [15:0] filtered_distance;
//    always_ff@(posedge clk_65mhz)begin
//        if(distance[31:16] < 16'hB00)begin
//            filtered_distance <= distance[31:16];
//        end
//    end
    
    
    distance my_distance(
        // inputs
        .clk_in(clk_65mhz),
        .rst_in(reset),
//        .start(trigger),
        .x1(nice_centroid_x1),
        .y1(nice_centroid_y1),
        .x2(nice_centroid_x2),
        .y2(nice_centroid_y2),
//        .servo_angle(servo_angle),
        // outputs
        .distance(distance),
        .world_x(world_x),
        .world_y(world_y),
        .world_z(world_z)
        );
    logic [31:0] selected;
//    assign selected = {distance[31:16], 16'b0}; // change this later
    assign selected = {nice_centroid_x1[7:0], nice_centroid_y1[7:0], nice_centroid_x2[7:0], nice_centroid_y2[7:0]};
//    logic [31:0] sel_set;
//    logic [26:0] counter_boi = 27'b0;
//    always_ff @(posedge clk_65mhz) begin
//        if (counter_boi == 27'd100000000) begin
//            sel_set <= selected;
//            counter_boi <= 27'b0;
//        end else counter_boi <= counter_boi + 27'd1;
    
//    end

    seven_seg_controller my_controller(
        .clk_in(clk_65mhz),.rst_in(reset),
        .val_in(selected),
        .cat_out({cg, cf, ce, cd, cc, cb, ca}),
        .an_out(an)
    );
    
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

 wire phsync,pvsync,pblank;    
             
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
                        .world_x(world_x),
                        .world_y(world_y),
                        .world_z(world_z),
                        .phsync_out(phsync),
                        .pvsync_out(pvsync),
                        .pblank_out(pblank),
                        .pixel_out(pixel),
                        .clk_200mhz(clk_200mhz),
                        .center_x(center_x),
                        .center_y(center_y),
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
                        .world_x(world_x),
                        .world_y(world_y),
                        .world_z(world_z),
                        .phsync_out(phsync),
                        .pvsync_out(pvsync),
                        .pblank_out(pblank),
                        .pixel_out(pixel2),
                        .clk_200mhz(clk_200mhz2),
                        .center_x(center_x2),
                        .center_y(center_y2),
                        .x_acc(x_acc2),
                        .y_acc(y_acc2),
                        .bit_count(bit_count2));
    
    logic cam3; //not a real camera
    display_select ds3(
            .vclock_in(clk_65mhz),        // 65MHz clock
            .hcount_in(hcount), // horizontal index of current pixel (0..1023)
            .vcount_in(vcount), // vertical index of current pixel (0..767)
            .hsync_in(hsync),         // XVGA horizontal sync signal (active low)
            .vsync_in(vsync),         // XVGA vertical sync signal (active low)
            .blank_in(blank),         // XVGA blanking (1 means output black pixel
            .world_x(world_x),
            .world_y(world_y),
            .world_z(world_z),
//            .selectors(sw[15:14]),  // selects between normal or processed image
            .processing(sw[13:10]), // selects which kind of process is being done
            .pixel_in(cam3),
            .inBounds(vcount >= 10'd240),
            .phsync_out(phsync),       // pong game's horizontal sync
            .pvsync_out(pvsync),       // pong game's vertical sync
            .pblank_out(pblank),       // pong game's blanking
            .pixel_out(pixel3),  // pong game's pixel  // r=11:8, g=7:4, b=3:0
            .clk_200mhz(clk_200mhz3),
            .center_x(center_x3), ///testing centroid_x
            .center_y(center_y3),
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
        else if (vcount>240 && (vcount<480)) cam <= pixel3; //the blobs
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
   input signed [31:0] world_x,
   input signed [31:0] world_y,
   input signed [31:0] world_z,
   output logic phsync_out,       // pong game's horizontal sync
   output logic pvsync_out,       // pong game's vertical sync
   output logic pblank_out,       // pong game's blanking
   output logic [11:0] pixel_out,  // pong game's pixel  // r=11:8, g=7:4, b=3:0
   output logic clk_200mhz,
  
   output [24:0] center_x, ///testing centroid_x
   output [24:0] center_y,
   output logic [24:0] x_acc,
   output logic [24:0] y_acc,
   output logic [24:0] bit_count
   );

   //centroid stuff
   logic [11:0] centroid;
   logic [11:0] pixel_outta;
   

   logic [24:0] centroid_x;

   logic [24:0] centroid_y;

    logic [24:0] valid_center_x;
    logic [24:0] valid_center_y;
    
   assign center_x = centroid_x;
   assign center_y = centroid_y;
   //end centroid stuff
  
    //changing pixel to make it useful for ob det//////

    logic [23:0] pixxel_in;
    assign pixxel_in = {pixel_in[11:8], 4'b0, pixel_in[7:4], 4'b0, pixel_in[3:0], 4'b0};
    
    always_comb begin
        if(centroid_x > 25'd319)begin
            valid_center_x = centroid_x;
        end
        if(centroid_y > 25'd239)begin
            valid_center_y = centroid_y;
        end
    end
   
   /////object_detection///
//  logic [11:0] process_pixel;
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
//                        .pixel_out(process_pixel),
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

//    logic [24:0] centroid_x_in;
//    logic [24:0] centroid_y_in;  

    blob #(.WIDTH(16),.HEIGHT(16),.COLOR(12'hFF0))   // yellow!

     the_centroid(.pixel_clk_in(vclock_in),
                    .hcount_in(hcount_in),
                    .vcount_in(vcount_in),
                    .centroid_x(centroid_x),
                    .centroid_y(centroid_y),  
//                    .centroid_x(centroid_x_in),
//                    .centroid_y(centroid_y_in), 
//                    .original(selectors[1]), 
//                    .processed(selectors[0]), 
      //              .process_selects(processing), 
                    .pixel_out(centroid)); 

    // SIDE VIEW
    // z bounds from camera: [-2083, 0]
    // -y bounds from camera: 185 -> 0
    logic signed [31:0] side_ball_x;
    logic signed [31:0] side_ball_y;
    
    logic signed [31:0] top_ball_x;
    logic signed [31:0] top_ball_y;
    
//    assign side_ball_x = (-world_z[31:16]*320)  >>> 11; // change denom
//    assign side_ball_y = (240*300 - world_y[31:16]*240)  >>> 9;

    
    // TOP VIEW
    // x bounds from camera: 24, 292, 0
    // z bounds from camera: -2083, -2075, 0 --> [2083,0
    
//      assign top_ball_x = (world_x[31:16] * 320 +  320*300) >>> 9 ;
//      assign top_ball_y = (-world_z[31:16] * 240) >>> 11;  
    
    

    ///interesting math to map distance module values to pixels//////
    logic [11:0] side_view;
    blob #(.WIDTH(320), .HEIGHT(240), .COLOR(12'h00F))
        side_v(.pixel_clk_in(vclock_in), .hcount_in(hcount_in), .vcount_in(vcount_in),
        .centroid_x(25'd0), .centroid_y(25'd240), .pixel_out(side_view));
    
    logic [11:0] top_view;
    blob #(.WIDTH(320), .HEIGHT(240), .COLOR(12'h0F0))
        top_v(.pixel_clk_in(vclock_in), .hcount_in(hcount_in), .vcount_in(vcount_in),
        .centroid_x(25'd320), .centroid_y(25'd240), .pixel_out(top_view));
        
    logic [11:0] side_or;
    blob #(.WIDTH(12), .HEIGHT(12), .COLOR(12'hFF0))
        side_origin(.pixel_clk_in(vclock_in), .hcount_in(hcount_in), .vcount_in(vcount_in),
        .centroid_x(25'd300), .centroid_y(25'd360), .pixel_out(side_or));
        
    logic [11:0] side_cam;
    blob #(.WIDTH(8), .HEIGHT(8), .COLOR(12'hF00))
        side_camera(.pixel_clk_in(vclock_in), .hcount_in(hcount_in), .vcount_in(vcount_in),
        .centroid_x(25'd0), .centroid_y(25'd387), .pixel_out(side_cam));
    
      
    logic [11:0] side_obj;
    blob #(.WIDTH(16), .HEIGHT(16), .COLOR(12'h0F0))
        side_object(.pixel_clk_in(vclock_in), .hcount_in(hcount_in), .vcount_in(vcount_in),
        .centroid_x(side_ball_x[24:0]), .centroid_y(side_ball_y[24:0] + 25'd240), .pixel_out(side_obj));
        
    logic [11:0] top_or;
    blob #(.WIDTH(12), .HEIGHT(12), .COLOR(12'hF00))
        top_origin(.pixel_clk_in(vclock_in), .hcount_in(hcount_in), .vcount_in(vcount_in),
        .centroid_x(25'd480), .centroid_y(25'd250), .pixel_out(top_or));
        
    logic [11:0] top_cam1;
    blob #(.WIDTH(8), .HEIGHT(8), .COLOR(12'hF0F))
        top_camL(.pixel_clk_in(vclock_in), .hcount_in(hcount_in), .vcount_in(vcount_in),
        .centroid_x(25'd510), .centroid_y(25'd458), .pixel_out(top_cam1));
        
    logic [11:0] top_cam2;
    blob #(.WIDTH(8), .HEIGHT(8), .COLOR(12'hF0F))
        top_camR(.pixel_clk_in(vclock_in), .hcount_in(hcount_in), .vcount_in(vcount_in),
        .centroid_x(25'd537), .centroid_y(25'd459), .pixel_out(top_cam2));
        
    logic [11:0] top_obj;
    blob #(.WIDTH(16), .HEIGHT(16), .COLOR(12'h00F))
        top_object(.pixel_clk_in(vclock_in), .hcount_in(hcount_in), .vcount_in(vcount_in),
        .centroid_x(top_ball_x[24:0]), .centroid_y(top_ball_y[24:0] + 25'd240), .pixel_out(top_obj));
     
//   always_ff @(posedge vclock_in) begin
//        if (selectors == 2'b10) begin
//           if ((hcount_in >= centroid_x_in && hcount_in <= centroid_x_in + 25'd16) 
//            && (vcount_in >= centroid_y_in  && vcount_in <= centroid_y_in + 25'd16)) begin
//                pixel_outta <= 12'd0;
//            end else pixel_outta <= process_pixel;
//            centroid_x_in <= centroid_x;
//            centroid_y_in <= centroid_y;
//        end else if (selectors == 2'b01) begin
//            if ((hcount_in >= centroid_x_in && hcount_in <= centroid_x_in + 25'd16) 
//            && (vcount_in >= centroid_y_in  && vcount_in <= centroid_y_in + 25'd16)) begin
//                pixel_outta <= 12'd0;
//            end else pixel_outta <= pixel_in;
//            centroid_x_in <= centroid_x - 25'd20;
//            centroid_y_in <= centroid_y - 25'd20;
//       end 
//    end
     
   
    assign pixel_out = centroid + pixel_outta + side_cam + 
    side_or + side_obj + top_or + top_cam1 + top_cam2 + top_obj + top_view + side_view;



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
    
  clk_wiz_0 clkmulti(.clk_in1(pixel_clk_in), .clk_out1(clk_260mhz));

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