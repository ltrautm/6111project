module fsm(input clk,
                input rst,
                input btnleft,
                input btnright,
                input btncalc,
                output logic servo_dir,
                output logic servo_stop);

        //define the possible states
        logic [1:0] IDLE = 2'b00;
        logic [1:0] LEFTMOVE = 2'b01;
        logic [1:0] RIGHTMOVE = 2'b10;
        logic [1:0] CALC = 2'b11;

        logic [1:0] state = 2'b00;


        always_ff @(posedge clk) begin
                if (rst) state <= IDLE;
                else begin
                case (state) 
                        IDLE: begin
                                if (btnleft == 1'b1) state <= LEFTMOVE;
                                else if (btnright == 1'b1) state <= RIGHTMOVE;
                                else if (btncalc == 1'b1) state <= CALC;
                        end

                        LEFTMOVE: begin
                                //do stuff to actually move the servo left

                                if (btnleft == 1'b0) state <= IDLE;
                                else if (btnright == 1'b1) state <= RIGHTMOVE;
                        end

                        RIGHTMOVE: begin
                                //do stuff to actually move the servo right

                                if (btnright == 1'b0) state <= IDLE;
                                else if (btnleft == 1'b1) state <= LEFTMOVE;
                        end

                        CALC: begin
                                //make sure the servo is stopped
                                //display the centroid 
                                //display the distance
                                if (rst == 1'b1) state <= IDLE;
                        end

                        default begin
                                state <= IDLE;
                        end

                endcase
                end



        end //end of always block



endmodule //end of fsm