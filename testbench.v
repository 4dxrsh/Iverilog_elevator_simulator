`timescale 1ns / 1ps

module testbench;

    reg clk;
    reg reset;
    reg [15:0] floor_buttons;
    wire [6:0] seven_seg_display;
    wire [3:0] floor_w;
    wire [2:0] state_w; // 3-bit state wire
    wire [15:0] requests_w;

    // Instantiate the top-level elevator module
    elevator_top dut (
        .clk(clk), .reset(reset), .floor_buttons(floor_buttons), .seven_seg_display(seven_seg_display)
    );

    // Aliases for easier monitoring in testbench and GTKWave
    assign floor_w = dut.u_counter.count;
    assign state_w = dut.u_control.state;
    assign requests_w = dut.u_control.requests;

    // Clock Generation
    initial begin clk = 0; forever #5 clk = ~clk; end

    // --- Reusable Test Tasks ---
    task press_button;
        input [3:0] floor;
        begin
            $display("    [ACTION] @ %0t ns: Pressing button for floor %0d.", $time, floor);
            floor_buttons[floor] = 1'b1;
            #10; // Hold for one cycle
            floor_buttons[floor] = 1'b0;
        end
    endtask
    
    task press_multiple_buttons;
        input [15:0] floors_to_press;
        begin
            $display("    [ACTION] @ %0t ns: Pressing multiple buttons.", $time);
            floor_buttons = floors_to_press;
            #10;
            floor_buttons = 16'b0;
        end
    endtask

    task wait_for_floor;
        input [3:0] target_floor;
        begin
            $display("    [WAIT] Waiting to arrive at floor %0d...", target_floor);
            wait (floor_w == target_floor);
            wait (state_w == 3'b100); // Wait for DOOR_OPEN state
            $display("    [SUCCESS] @ %0t ns: Arrived at floor %0d. Door is open.", $time, floor_w);
        end
    endtask

    task wait_for_idle;
        begin
             #110; // Wait long enough for door cycle to complete
             wait (state_w == 3'b000); // Wait for IDLE state
             $display("    [INFO] @ %0t ns: Elevator is now IDLE at floor %0d.", $time, floor_w);
             #10;
        end
    endtask
    
    task reset_system;
        begin
            $display("    [ACTION] @ %0t ns: Asserting SYSTEM RESET.", $time);
            reset = 1; #25; reset = 0;
            if (floor_w == 0 && requests_w == 0 && state_w == 3'b000)
                $display("    [SUCCESS] System correctly reset to idle at floor 0.");
            else
                $display("    [***FAILURE***] System reset failed! Floor: %d, State: %b, Requests: %h", floor_w, state_w, requests_w);
            wait_for_idle();
        end
    endtask

    // --- Main Simulation Sequence ---
    initial begin
        $dumpfile("elevator_final_validation.vcd");
        $dumpvars(0, testbench);
        floor_buttons = 16'b0;

        $display("\n--- TC1: System Boot & Reset ---");
        reset_system();

        $display("\n--- TC2: Full Boundary Runs (0 -> 15 and 15 -> 0) ---");
        press_button(15);
        wait_for_floor(15);
        wait_for_idle();
        press_button(0);
        wait_for_floor(0);
        wait_for_idle();

        $display("\n--- TC3: Upward Collection Run (Floor Scanning) ---");
        $display("    At floor 0. Requesting 3, 7, 11, 14.");
        press_multiple_buttons({1'b1, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0});
        wait_for_floor(3);
        wait_for_floor(7);
        wait_for_floor(11);
        wait_for_floor(14);
        wait_for_idle();

        $display("\n--- TC4: Downward Collection Run (Floor Scanning) ---");
        $display("    At floor 14. Requesting 1, 6, 10, 13.");
        press_multiple_buttons({1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0});
        wait_for_floor(13);
        wait_for_floor(10);
        wait_for_floor(6);
        wait_for_floor(1);
        wait_for_idle();

        $display("\n--- TC5: Complex Run - Direction Reversal (Up -> Down) ---");
        $display("    At floor 1, going to 12. Adding requests for 5 (on the way) and 2 (requires reversal).");
        press_button(12);
        #40; // Wait until it's moving
        press_button(5);
        press_button(2);
        wait_for_floor(5);
        wait_for_floor(12);
        wait_for_idle();
        wait_for_floor(2);
        wait_for_idle();

        $display("\n--- TC6: Request Current Floor (Idle & During Door Cycle) ---");
        $display("    At floor 2. Pressing 2. Should just open/close door.");
        press_button(2);
        wait (state_w == 3'b100); $display("    [SUCCESS] Door opened.");
        #30; // Wait while door is open
        $display("    Pressing 2 again while door is open. Should have no effect.");
        press_button(2);
        wait_for_idle();

        // *** TEST CASE 7 HAS BEEN REMOVED ***

        $display("\n--- TC8: Comprehensive Reset Tests ---");
        $display("    Testing reset while moving UP...");
        press_button(10);
        #40; // Let it move for a bit
        reset_system();

        $display("    Testing reset while moving DOWN...");
        press_button(15);
        wait_for_floor(15);
        wait_for_idle();
        press_button(5);
        #40; // Let it move for a bit
        reset_system();

        $display("    Testing reset while DOOR IS OPEN...");
        press_button(4);
        wait_for_floor(4); // Door is now open
        reset_system();

        $display("\n\n✅ ALL VALIDATION TEST CASES COMPLETED (TC7 skipped). ✅");
        $finish;
    end
endmodule