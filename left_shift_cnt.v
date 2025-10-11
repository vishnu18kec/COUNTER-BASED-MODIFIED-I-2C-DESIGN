`timescale 1ns/1ps

module left_shift_counter (
    input  wire       clk,
    input  wire       rst_n,   // active low reset
    input  wire       en,      // external start signal (level, not pulse)
    input  wire [7:0] din,     // parallel input data
    output reg        q,       // serial output bit (MSB first)
    output reg  [3:0] qcnt     // 4-bit counter
);

    reg [7:0] shift_reg;
    reg       active;
    reg       en_d;     // delayed version of en for edge detection

    // Rising-edge detector for en
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            en_d <= 1'b0;
        else
            en_d <= en;
    end

    wire start = en & ~en_d;   // pulse only on rising edge of en

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            shift_reg <= 8'b0;
            q         <= 1'bz;   // idle as high-Z
            qcnt      <= 4'd0;
            active    <= 1'b0;
        end else begin
            // ----------- START OPERATION -----------
            if (start && !active) begin
                shift_reg <= din;
                q         <= din[7];      // output MSB first
                qcnt      <= 4'd1;        // first bit shifted
                active    <= 1'b1;        // latch into active mode
            end 
            // ----------- SHIFTING -----------
            else if (active) begin
                if (qcnt < 4'd8) begin
                    shift_reg <= shift_reg << 1;
                    q         <= shift_reg[6]; // next MSB
                    qcnt      <= qcnt + 1;
                end else begin
                    // ----------- FINISHED -----------
                    active    <= 1'b0;   // stop shifting
                    q         <= 1'bz;   // release line (idle)
                    qcnt      <= 4'd0;   // reset counter
                end
            end
        end
    end

endmodule

