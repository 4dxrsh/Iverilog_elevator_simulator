// counter.v: A 4-bit up/down counter with an enable signal.

module counter(
    input clk,
    input reset,
    input enable,       // Only count when this is high
    input up_down,      // 1 for up, 0 for down
    output reg [3:0] count
);

    // Initial floor is 0
    initial begin
        count = 4'd0;
    end

    always @(posedge clk or posedge reset)
    begin
        if (reset)
        begin
            count <= 4'd0; // Reset to ground floor
        end
        else if (enable) // Only change count if enabled
        begin
            if (up_down)
            begin
                // Increment if not at the top floor (15)
                if (count < 4'd15)
                    count <= count + 1;
            end
            else
            begin
                // Decrement if not at the ground floor (0)
                if (count > 4'd0)
                    count <= count - 1;
            end
        end
    end

endmodule