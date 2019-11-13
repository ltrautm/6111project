

module rgb_over_serial(
    input clk_in,
    input rst_in, 
    input [11:0] val_in,
    output logic [7:0] val_out
);

    logic [31:0] count = 0;
    logic [1:0] rgb_count = 0;

    always_ff @(posedge clk_in) begin
        if (rst_in) begin
            //reset
            count <= 0;
            rgb_count <= 0;
            val_out <= 8'b0;
        end else begin
            //check if it should be r, g, or b
            //check if the divisor is right (switch order)
        end
    end

endmodule
