
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

