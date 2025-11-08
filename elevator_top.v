// elevator_top.v: Top-level module for the Digital Elevator.

module elevator_top(
    input clk,
    input reset,
    input [15:0] floor_buttons, // Simulates pressing floor buttons
    output [6:0] seven_seg_display
);

    // Wires to connect the modules
    wire [3:0] floor_count;
    wire enable_signal;
    wire up_down_signal;

    // 1. Instantiate the Counter
    counter u_counter (
        .clk(clk),
        .reset(reset),
        .enable(enable_signal),
        .up_down(up_down_signal),
        .count(floor_count)
    );

    // 2. Instantiate the Control Unit
    elevator_control u_control (
        .clk(clk),
        .reset(reset),
        .current_floor(floor_count),
        .floor_buttons(floor_buttons),
        .count_enable(enable_signal),
        .up_down(up_down_signal)
    );

    // 3. Instantiate the Display Decoder
    display_decoder u_decoder (
        .floor_number(floor_count),
        .segments(seven_seg_display)
    );

endmodule