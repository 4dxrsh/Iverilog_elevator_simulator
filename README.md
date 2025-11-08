# Iverilog_elevator_simulator
A Verilog HDL project implementing a 4-bit synchronous Up/Down counter as a digital elevator control system. Simulates 16 floors, handles floor requests, and includes a 7-segment display output.

# 4-bit Up/Down Counter (Digital Elevator Simulator)

[cite_start]This is a digital logic design project for class 3A [cite: 2] [cite_start]that implements a 4-bit synchronous Up/Down counter using Verilog HDL[cite: 8]. The counter is used as the core logic for a digital elevator floor indicator, simulating the elevator's movement between 16 floors (0-15) and displaying the current floor on a 7-segment display.

This project was designed and tested using Icarus Verilog (`iverilog`) and GTKWave.

## Project Modules

As outlined in the project brief, the design is split into several key modules:

* `elevator_top.v`: The top-level module that connects all the components.
* `elevator_control.v`: The "brain" of the elevator. This Finite State Machine (FSM) handles floor requests, determines the direction of travel, and controls the door open/close delay.
* [cite_start]`counter.v`: The core 4-bit synchronous counter [cite: 8, 11] that represents the current floor number (0-15). [cite_start]It takes `up_down` [cite: 12] and `enable` signals from the control unit.
* `display_decoder.v`: A combinational module that translates the 4-bit floor number from the counter into the 7-segment signals required for the display.
* `testbench.v`: An exhaustive testbench that validates all functionalities, including boundary conditions (floors 0 and 15), sequential requests, mid-transit requests, and system resets.

## Features

* [cite_start]**Up/Down Counter:** The core logic increments or decrements the floor number based on a control signal[cite: 9].
* **Floor Limits:** The counter is limited to a 0-15 floor range.
* **7-Segment Display:** The current floor is output to a simulated 7-segment display.
* **Floor Buttons:** Simulates floor button presses using a 16-bit input.
* **Door Open Delay:** A built-in delay using clock cycles simulates the door remaining open after arriving at a floor.
* **Floor Request Servicing:** The control unit intelligently services requests in its direction of travel.

## How to Run the Simulation

1.  **Compile the Modules:**
    Use `iverilog` to compile all Verilog files into a simulation executable.
    ```sh
    iverilog -o elevator_sim elevator_top.v elevator_control.v counter.v display_decoder.v testbench.v
    ```

2.  **Run the Simulation:**
    Use `vvp` to execute the compiled file. This will run all test cases and print status updates to the terminal.
    ```sh
    vvp elevator_sim
    ```

3.  **View Waveforms:**
    The simulation generates a `elevator_final_validation.vcd` file. You can open this in a waveform viewer like GTKWave to analyze the signals.
    ```sh
    gtkwave elevator_final_validation.vcd
    ```

* [cite_start]Adarsh Rajesh (PES1UG24CS020) [cite: 4]
* [cite_start]Aadhavan Muthusamy (PES1UG24CS002) [cite: 5]
* [cite_start]Abhinav Agraharam (PES1UG24CS001) [cite: 6]
