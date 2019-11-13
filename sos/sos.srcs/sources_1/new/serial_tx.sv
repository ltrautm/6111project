module serial_tx(   input           clk_in,
                    input           rst_in,
                    input           trigger_in,
                    input [11:0]     val_in,
                    output logic    data_out);
                    
    parameter   DIVISOR = 1335;// to account for 65 mhz clock. 868; //treat this like a constant!!
    
    logic [13:0]         shift_buffer; //10 bits...interesting
    logic [31:0]        count;
    
    always_ff @(posedge clk_in)begin
        if(rst_in)begin
            count <= 32'd0; //reset count
            shift_buffer <= 10'b1; // reset to 1
        end else begin  
            if(trigger_in)begin
                shift_buffer <= {1'b1, val_in, 1'b0}; // prepend val_in with 0 and append with 1, store in shift_buffer
                count <= DIVISOR;
            end else begin
                if(count==DIVISOR)begin // if count == DIVISOR
                    count <= 32'd0; //reset count
                    data_out <= shift_buffer[0]; // send least significant bit first
                    shift_buffer <= {1'b1, shift_buffer[13:1]}; // shift to right, pad the unused bits as HIGH
                end else begin
                    count <= count + 1; // else keep counting
                end
            end
        end
    end              
endmodule //serial_tx