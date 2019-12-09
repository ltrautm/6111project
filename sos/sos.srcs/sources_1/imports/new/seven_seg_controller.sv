module seven_seg_controller(input               clk_in,
                            input               rst_in,
                            input [31:0]        val_in,
                            output logic[6:0]   cat_out,
                            output logic[7:0]   an_out
    );
  
    logic[7:0]      segment_state;
    logic[31:0]     segment_counter;
    logic [3:0]     routed_vals;
    logic [6:0]     led_out;
    
    binary_to_seven_seg my_converter ( .bin_in(routed_vals), .hex_out(led_out));
    assign cat_out = ~led_out;
    assign an_out = ~segment_state;

    
    always_comb begin
        case(segment_state)
            8'b0000_0001:   routed_vals = val_in[3:0];
            8'b0000_0010:   routed_vals = val_in[7:4];
            8'b0000_0100:   routed_vals = val_in[11:8];
            8'b0000_1000:   routed_vals = val_in[15:12];
            8'b0001_0000:   routed_vals = val_in[19:16];
            8'b0010_0000:   routed_vals = val_in[23:20];
            8'b0100_0000:   routed_vals = val_in[27:24];
            8'b1000_0000:   routed_vals = val_in[31:28];
            default:        routed_vals = val_in[3:0];       
        endcase
    end
    
    always_ff @(posedge clk_in)begin
        if (rst_in)begin
            segment_state <= 8'b0000_0001;
            segment_counter <= 32'b0;
        end else begin
            if (segment_counter == 32'd25_000)begin
                segment_counter <= 32'd0;
                segment_state <= {segment_state[6:0],segment_state[7]};
            end else begin
                segment_counter <= segment_counter +1;
            end
        end
    end
        
endmodule //seven_seg_controller


module binary_to_seven_seg( 
                            bin_in,
                            hex_out
);

    input [3:0]             bin_in;  //declaring input explicitely
    output logic [6:0]      hex_out;  //declaring output explicitely

    always_comb
        begin
            case (bin_in)
                4'b0000: hex_out = 7'b0111111; //0
                4'b0001: hex_out = 7'b0000110; //1
                4'b0010: hex_out = 7'b1011011; //2
                4'b0011: hex_out = 7'b1001111; //3
                4'b0100: hex_out = 7'b1100110; //4
                4'b0101: hex_out = 7'b1101101; //5
                4'b0110: hex_out = 7'b1111101; //6
                4'b0111: hex_out = 7'b0000111; //7
                4'b1000: hex_out = 7'b1111111; //8
                4'b1001: hex_out = 7'b1101111; //9
                4'b1010: hex_out = 7'b1110111; //A
                4'b1011: hex_out = 7'b1111100; //B
                4'b1100: hex_out = 7'b0111001; //C
                4'b1101: hex_out = 7'b1011110; //D
                4'b1110: hex_out = 7'b1111001; //E
                4'b1111: hex_out = 7'b1110001; //F
                default: begin end
            endcase
        end
endmodule //binary_to_seven_seg