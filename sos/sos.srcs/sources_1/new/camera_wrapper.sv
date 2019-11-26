
module camera_wrapper( 
                       input clk_65mhz,
                       input j0,
                       input j1,
                       input j2,
                       input [7:0] ju,
                       output logic [15:0] output_pixels,
                       output logic valid_pixel,
                       output logic jclk,
                       output logic pclk_in,
                       output logic frame_done_out
        );
        
        
        logic xclk;
        logic[1:0] xclk_count;
        logic pclk_buff;  //, pclk_in;
        logic vsync_buff, vsync_in;
        logic href_buff, href_in;
        logic[7:0] pixel_buff, pixel_in;
        
        assign xclk = (xclk_count >2'b01);
        assign jclk = xclk;
        
        always_ff @(posedge clk_65mhz) begin
            xclk_count <= xclk_count + 2'b01;
            pclk_buff <= j0;
            pclk_in <= pclk_buff;
            vsync_buff <= j1;
            vsync_in <= vsync_buff;
            href_buff <= j2;
            href_in <= href_buff;
            pixel_buff <= ju;
            pixel_in <= pixel_buff;
        end
        
        camera_read  my_camera(.p_clock_in(pclk_in),
                              .vsync_in(vsync_in),
                              .href_in(href_in),
                              .p_data_in(pixel_in),
                              .pixel_data_out(output_pixels),
                              .pixel_valid_out(valid_pixel),
                              .frame_done_out(frame_done_out));
                              

endmodule //camera_wrapper














// this module is meant to wrap up all the reading in the camera
// maybe there should be another wrapper for (vga) display stuff

//TODOs: Bring back the ILAAAAAA (use IP catalog and uncomment joe's ila)

//module camera_wrapper(
        
//    input clk_65mhz,
//    input she_val,
//    input j0,j1,j2,
//    input [7:0] ju,
//    input [10:0] hcount,
//    input [9:0] vcount,
//    output logic [11:0] cam,
//    output logic she_valid,
//    output logic [16:0] pixel_addr_in,
//    output logic pclk_in,
//    output logic [12:0] processed_pixels,
//    output logic [16:0] pixel_addr_out,
//    output logic [11:0] frame_buff_out
//    );



//    logic xclk;
//    logic[1:0] xclk_count;
    
//    logic pclk_buff;//, pclk_in;
//    logic vsync_buff, vsync_in;
//    logic href_buff, href_in;
//    logic[7:0] pixel_buff, pixel_in;
    
////    logic [11:0] cam;
////    logic [11:0] frame_buff_out;
//    logic [15:0] output_pixels;
//    logic [15:0] old_output_pixels;
////    logic [12:0] processed_pixels;
//    logic [3:0] red_diff;
//    logic [3:0] green_diff;
//    logic [3:0] blue_diff;
//    logic valid_pixel;
//    logic frame_done_out;
    
////    logic she_valid;
//    assign she_valid = valid_pixel & ~she_val;
    
////    logic [16:0] pixel_addr_in;
////    logic [16:0] pixel_addr_out;
    
//    assign xclk = (xclk_count >2'b01);
////    assign jbclk = xclk;  //only for ila?
////    assign jdclk = xclk;
    
////    assign red_diff = (output_pixels[15:12]>old_output_pixels[15:12])?output_pixels[15:12]-old_output_pixels[15:12]:old_output_pixels[15:12]-output_pixels[15:12];
////    assign green_diff = (output_pixels[10:7]>old_output_pixels[10:7])?output_pixels[10:7]-old_output_pixels[10:7]:old_output_pixels[10:7]-output_pixels[10:7];
////    assign blue_diff = (output_pixels[4:1]>old_output_pixels[4:1])?output_pixels[4:1]-old_output_pixels[4:1]:old_output_pixels[4:1]-output_pixels[4:1];


//always_ff @(posedge pclk_in)begin
//        if (frame_done_out)begin
//            pixel_addr_in <= 17'b0;  
//        end else if (valid_pixel)begin
//            pixel_addr_in <= pixel_addr_in +1;  
//        end
//    end
    
//    always_ff @(posedge clk_65mhz) begin
//        pclk_buff <= j0;//WAS JB
//        vsync_buff <= j1; //WAS JB
//        href_buff <= j2; //WAS JB
//        pixel_buff <= ju;
//        pclk_in <= pclk_buff;
//        vsync_in <= vsync_buff;
//        href_in <= href_buff;
//        pixel_in <= pixel_buff;
//        old_output_pixels <= output_pixels;
//        xclk_count <= xclk_count + 2'b01;
////        if (sw[3])begin
////            //processed_pixels <= {red_diff<<2, green_diff<<2, blue_diff<<2};
////            processed_pixels <= output_pixels - old_output_pixels;
////        end else if (sw[4]) begin
////            if ((output_pixels[15:12]>4'b1000)&&(output_pixels[10:7]<4'b1000)&&(output_pixels[4:1]<4'b1000))begin
////                processed_pixels <= 12'hF00;
////            end else begin
////                processed_pixels <= 12'h000;
////            end
////        end else if (sw[5]) begin
////            if ((output_pixels[15:12]<4'b1000)&&(output_pixels[10:7]>4'b1000)&&(output_pixels[4:1]<4'b1000))begin
////                processed_pixels <= 12'h0F0;
////            end else begin
////                processed_pixels <= 12'h000;
////            end
////        end else if (sw[6]) begin
////            if ((output_pixels[15:12]<4'b1000)&&(output_pixels[10:7]<4'b1000)&&(output_pixels[4:1]>4'b1000))begin
////                processed_pixels <= 12'h00F;
////            end else begin
////                processed_pixels <= 12'h000;
////            end
////        end else begin
//            processed_pixels <= {output_pixels[15:12],output_pixels[10:7],output_pixels[4:1]};
////        end
            
//    end
////    //next two lines allow you to switch between small and thiccc screens
//////    assign pixel_addr_out = sw[2]?((hcount>>1)+(vcount>>1)*32'd320):hcount+vcount*32'd320;
//////    assign cam = sw[2]&&((hcount<640) &&  (vcount<480))?frame_buff_out:~sw[2]&&((hcount<320) &&  (vcount<240))?frame_buff_out:12'h000;
    
//    assign pixel_addr_out = hcount+vcount*32'd320;
//    assign cam = ((hcount<320) &&  (vcount<240))?frame_buff_out:12'h000;
    
    
//       camera_read  my_camera(.p_clock_in(pclk_in),
//                          .vsync_in(vsync_in),
//                          .href_in(href_in),
//                          .p_data_in(pixel_in),
//                          .pixel_data_out(output_pixels),
//                          .pixel_valid_out(valid_pixel),
//                          .frame_done_out(frame_done_out));


//endmodule
