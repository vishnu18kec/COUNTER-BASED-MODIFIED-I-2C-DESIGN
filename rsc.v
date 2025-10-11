module right_shift_counter (
    input        clk,       // Clock
    input        rst_n,     // Active-low reset
    input        en,        // Enable input
    input        data_in,   // Serial data input
    output reg [7:0] data_reg, // Stores all 8 bits after 8 cycles
    output reg i             // Goes high after 8 bits counted
);

    reg [7:0] shift_reg;    // Shift register
    reg [2:0] count;        // 3-bit counter for 8 cycles

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            shift_reg <= 8'b0;
            count     <= 3'b0;
            data_reg  <= 8'b0;
            i         <= 1'b0;
        end else if (en) begin
            shift_reg <= {data_in, shift_reg[7:1]}; // Right shift with new bit in MSB
            count <= count + 1;

            if (count == 3'b111) begin
                data_reg <= {data_in, shift_reg[7:1]}; // Capture all 8 bits
                count <= 3'b0;
                i <= 1'b1;   // Signal counting done
            end else begin
                i <= 1'b0;
            end
        end else begin
            i <= 1'b0;
        end
    end

endmodule

