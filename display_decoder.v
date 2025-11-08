// display_decoder.v: Converts a 4-bit number to a 7-segment display output.

module display_decoder(
    input [3:0] floor_number,
    output reg [6:0] segments // Output for segments (g,f,e,d,c,b,a)
);

    // This is a combinational block, it updates whenever floor_number changes
    always @(*)
    begin
        case (floor_number)
            4'd0: segments = 7'b0111111; // 0
            4'd1: segments = 7'b0000110; // 1
            4'd2: segments = 7'b1011011; // 2
            4'd3: segments = 7'b1001111; // 3
            4'd4: segments = 7'b1100110; // 4
            4'd5: segments = 7'b1101101; // 5
            4'd6: segments = 7'b1111101; // 6
            4'd7: segments = 7'b0000111; // 7
            4'd8: segments = 7'b1111111; // 8
            4'd9: segments = 7'b1101111; // 9
            4'd10: segments = 7'b1110111; // A
            4'd11: segments = 7'b1111100; // b
            4'd12: segments = 7'b0111001; // C
            4'd13: segments = 7'b1011110; // d
            4'd14: segments = 7'b1111001; // E
            4'd15: segments = 7'b1110001; // F
            default: segments = 7'b0000000; // Off
        endcase
    end

endmodule