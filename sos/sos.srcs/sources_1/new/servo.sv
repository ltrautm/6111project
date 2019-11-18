//probably the servo needs a pulse every 20ms
//neutral is apparently a pulse width of 1.5ms


module servo(clk, angle, servo_pulse);
    input clk;
    input [7:0] angle;
    output logic servo_pulse;
    
//    logic serpul=0;
//    assign servo_pulse = serpul;
    
    //TODO: add a state that sets the servo low in the beginning for a little while
    
    
    logic [17:0] counter = 18'd0;
    logic onn = 1'b1;
    
    always_ff @(posedge clk) begin
        if (angle == 8'd90) begin
            if (onn == 1'b1) begin
                servo_pulse <= 1'b1;
                onn <= 1'b0;
            end 
            if (counter == 18'd150000) begin
                servo_pulse <= 0;
            end
        end
    end

endmodule
