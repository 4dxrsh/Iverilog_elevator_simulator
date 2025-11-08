// elevator_control.v: Robust FSM (returns to IDLE to re-evaluate).

module elevator_control(
    input clk,
    input reset,
    input [3:0] current_floor,
    input [15:0] floor_buttons,

    output reg count_enable,
    output reg up_down
);
    // FSM States
    parameter IDLE = 3'b000;
    parameter MOVE_UP = 3'b010;
    parameter MOVE_DOWN = 3'b011;
    parameter DOOR_OPEN = 3'b100;

    // Internal registers
    reg [2:0] state, next_state;
    reg [15:0] requests;
    reg direction; // 1 for UP, 0 for DOWN
    reg [7:0] delay_counter;

    // Helper flags for checking requests
    reg reqs_above;
    reg reqs_below;
    integer j; // Loop variable

    // Combinational logic to calculate helper flags
    always @(*) begin
        reqs_above = 1'b0;
        for (j = current_floor + 1; j < 16; j = j + 1) begin
            if (requests[j]) reqs_above = 1'b1;
        end
        reqs_below = 1'b0;
        for (j = 0; j < current_floor; j = j + 1) begin
            if (requests[j]) reqs_below = 1'b1;
        end
    end

    // Latch new requests and clear serviced ones
    always @(posedge clk or posedge reset) begin
        if (reset)
            requests <= 16'b0;
        else
            requests <= (requests | floor_buttons) & ~(serviced_mask);
    end

    wire [15:0] serviced_mask = (state == DOOR_OPEN) ? (1'b1 << current_floor) : 16'b0;

    // Main FSM state transitions and delay counter
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            delay_counter <= 0;
            direction <= 1'b1; // Default direction is UP
        end else begin
            state <= next_state;
            if (next_state == DOOR_OPEN && state != DOOR_OPEN)
                delay_counter <= 10;
            else if (state == DOOR_OPEN)
                delay_counter <= delay_counter - 1;
        end
    end

    // FSM combinational logic for outputs and next state
    always @(*) begin
        count_enable = 1'b0;
        up_down = direction;
        next_state = state; // Default to stay in state

        case (state)
            IDLE: begin
                // Priority 1: Service the current floor if requested
                if (requests[current_floor]) begin
                    next_state = DOOR_OPEN;
                // Priority 2: Continue in the current direction if requests exist there
                end else if (direction == 1'b1 && reqs_above) begin
                    next_state = MOVE_UP;
                end else if (direction == 1'b0 && reqs_below) begin
                    next_state = MOVE_DOWN;
                // Priority 3: Reverse direction if no more requests ahead
                end else if (reqs_below) begin // Must be reqs below, as reqs_above is false
                    next_state = MOVE_DOWN;
                end else if (reqs_above) begin // Must be reqs above, as reqs_below is false
                    next_state = MOVE_UP;
                end else begin
                    next_state = IDLE; // No requests, stay idle
                end
            end

            MOVE_UP: begin
                count_enable = 1'b1;
                up_down = 1'b1;
                direction = 1'b1;
                next_state = IDLE; // Always return to IDLE at the new floor to re-evaluate
            end

            MOVE_DOWN: begin
                count_enable = 1'b1;
                up_down = 1'b0;
                direction = 1'b0;
                next_state = IDLE; // Always return to IDLE at the new floor to re-evaluate
            end

            DOOR_OPEN: begin
                if (delay_counter == 1)
                    next_state = IDLE;
                else
                    next_state = DOOR_OPEN; // Stay in door open
            end
        endcase
    end
endmodule