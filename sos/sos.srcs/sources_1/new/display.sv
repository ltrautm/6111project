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

module labkit(
   input clk_100mhz,
   input[15:0] sw,
   input btnc, btnu, btnl, btnr, btnd,
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

    // create 65mhz system clock, happens to match 1024 x 768 XVGA timing
    logic clk_65mhz;
    clk_wiz_lab3 clkdivider(.clk_in1(clk_100mhz), .clk_out1(clk_65mhz));

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

    wire [10:0] hcount;    // pixel on current line
    wire [9:0] vcount;     // line number
    wire hsync, vsync;
    wire [11:0] pixel;
    reg [11:0] rgb; 
    logic blank;   
    xvga xvga1(.vclock_in(clk_65mhz),.hcount_out(hcount),.vcount_out(vcount),
          .hsync_out(hsync),.vsync_out(vsync),.blank_out(blank));

    // btnc button is user reset

    wire phsync,pvsync,pblank;
    display_select ds(.vclock_in(clk_65mhz),.selectors(sw[15:14]), .processing(sw[13:10]),
                .hcount_in(hcount),.vcount_in(vcount),
                .hsync_in(hsync),.vsync_in(vsync),.blank_in(blank),
                .phsync_out(phsync),.pvsync_out(pvsync),.pblank_out(pblank),.pixel_out(pixel));

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
         rgb <= pixel;
      end
    end

//    assign rgb = sw[0] ? {12{border}} : pixel ; //{{4{hcount[7]}}, {4{hcount[6]}}, {4{hcount[5]}}};

    // the following lines are required for the Nexys4 VGA circuit - do not change
    assign vga_r = ~b ? rgb[11:8]: 0;
    assign vga_g = ~b ? rgb[7:4] : 0;
    assign vga_b = ~b ? rgb[3:0] : 0;

    assign vga_hs = ~hs;
    assign vga_vs = ~vs;

endmodule


module display_select (
   input vclock_in,        // 65MHz clock
   input [10:0] hcount_in, // horizontal index of current pixel (0..1023)
   input [9:0]  vcount_in, // vertical index of current pixel (0..767)
   input hsync_in,         // XVGA horizontal sync signal (active low)
   input vsync_in,         // XVGA vertical sync signal (active low)
   input blank_in,         // XVGA blanking (1 means output black pixel)
   input [1:0] selectors,  // selects between normal or processed image
   input [3:0] processing, // selects which kind of process is being done
        
   output phsync_out,       // pong game's horizontal sync
   output pvsync_out,       // pong game's vertical sync
   output pblank_out,       // pong game's blanking
   output [11:0] pixel_out  // pong game's pixel  // r=11:8, g=7:4, b=3:0
   );

        

   assign phsync_out = hsync_in;
   assign pvsync_out = vsync_in;
   assign pblank_out = blank_in;
   
   logic [11:0] centroid;
   logic [11:0] mandm;
   assign pixel_out = centroid + mandm;

   picture_blob  dulcecito(.pixel_clk_in(vclock_in), .x_in(11'd0), .hcount_in(hcount_in),
     .y_in(10'd0), .vcount_in(vcount_in), .original(selectors[1]), .processed(selectors[0]), .process_selects(processing), .pixel_out(mandm));
   
   //centroid details
  // wire [11:0] centre_pixel; //show centroid
//   logic [15:0] centroid_x;
//   logic [15:0] centroid_y;
   
   blob #(.WIDTH(16),.HEIGHT(16),.COLOR(12'hFF0))   // yellow!
     the_centroid(.pixel_clk_in(vclock_in),.hcount_in(hcount_in),.vcount_in(vcount_in), 
     .original(selectors[1]), .processed(selectors[0]), .process_selects(processing), .pixel_out(centroid)); 

endmodule

module picture_blob
   #(parameter WIDTH = 320,     // default picture width
               HEIGHT = 240)    // default picture height
   (input pixel_clk_in,
    input [10:0] x_in,hcount_in,
    input [9:0] y_in,vcount_in,
    input original, //selection of original or processed image
    input processed,
    input [3:0] process_selects, // allows us to see erosion and dilation, and to choose hue thresholds
    output logic [11:0] pixel_out);

   logic [15:0] image_addr;   // num of bits for 256*240 ROM
   logic [7:0] image_bits, red_mapped, green_mapped, blue_mapped;
   


   // calculate rom address and read the location
   assign image_addr = (hcount_in-x_in) + (vcount_in-y_in) * WIDTH;
   m_and_m_rom image_rom(.clka(pixel_clk_in), .addra(image_addr), .douta(image_bits));
//     square_image image_rom(.clka(pixel_clk_in), .addra(image_addr), .douta(image_bits));

   // use color map to create 4 bits R, 4 bits G, 4 bits B
   // since the image is greyscale, just replicate the red pixels
   // and not bother with the other two color maps.
   red_rom rcm(.clka(pixel_clk_in), .addra(image_bits), .douta(red_mapped));
   green_rom gcm (.clka(pixel_clk_in), .addra(image_bits), .douta(green_mapped));
   blue_rom bcm (.clka(pixel_clk_in), .addra(image_bits), .douta(blue_mapped));
      //blk_mem_gen_0 square_map(.clka(pixel_clk_in), .addra(image_bits), .douta(red_mapped));
   // note the one clock cycle delay in pixel!
   
   logic [15:0] yy;//y-coordinate of center
   logic [15:0] xx;//x-coordinate of the center
   logic [23:0] pixel_in; //pixel that goes in to be binarized
   logic [11:0] pixxel; //output from image processing
   

   logic clk_200mhz;
   clk_wiz_0 clkmulti(.clk_in1(pixel_clk_in), .clk_out1(clk_200mhz));
   
   //logic centro_listo; // the center is ready to be displayed
   object_detection ob_det(.clk(pixel_clk_in), .dilate(process_selects[1]), .erode(process_selects[0]), .thresholds(process_selects[3:2]),
         .pixel_in(pixel_in), .hcount(hcount_in), .vcount(vcount_in), .centroid_x(xx), .centroid_y(yy), .pixel_out(pixxel));
  

   //logic centroid_trigger = 0;
    
   
             
   always_ff @ (posedge pixel_clk_in) begin
        if ((hcount_in >= (x_in) && hcount_in < (x_in+WIDTH)) &&
           (vcount_in >= y_in && vcount_in < (y_in+HEIGHT))) begin
           if (processed) begin
                pixel_in <= {red_mapped, green_mapped, blue_mapped};
 
                pixel_out <= pixxel;
           end else if (original) begin
                pixel_out <= {red_mapped[7:4], green_mapped[7:4], blue_mapped[7:4]};
           end
        end else begin
            pixel_out <= 0;
        end
   end
endmodule


//////////////////////////////////////////////////////////////////////
//
// blob: generate rectangle on screen
//
//////////////////////////////////////////////////////////////////////
module blob
   #(parameter WIDTH = 64,            // default width: 64 pixels
               HEIGHT = 64,           // default height: 64 pixels
               COLOR = 12'hFFF)  // default color: white
   (input pixel_clk_in,
    input [10:0] hcount_in,
    input [9:0] vcount_in,
    input original, //selection of original or processed image
    input processed,
    input [3:0] process_selects, // allows us to see erosion and dilation, and to choose hue thresholds
    output logic [11:0] pixel_out);
   
   logic clk_200mhz;
   clk_wiz_0 clkmulti(.clk_in1(pixel_clk_in), .clk_out1(clk_200mhz));
   
   logic [24:0] yy;//y-coordinate of center
   logic [24:0] xx;//x-coordinate of the center
   logic [23:0] pixel_in; //pixel that goes in to be binarized
   logic [11:0] pixxel; //output from image processing
   
    
   //logic centro_listo; // the center is ready to be displayed
   object_detection ob_det(.clk(pixel_clk_in), .dilate(process_selects[1]), .erode(process_selects[0]), .thresholds(process_selects[3:2]),
         .pixel_in(pixel_in), .centroid_x(xx), .centroid_y(yy), .pixel_out(pixxel));
  
   always_ff @(posedge pixel_clk_in) begin
        if ((hcount_in >= xx && hcount_in < (xx+WIDTH)) &&
           (vcount_in >= yy && vcount_in < (yy+HEIGHT))) begin
            pixel_out <= COLOR;
        end else begin
            pixel_out <= 0;
        end
          
   end

endmodule
