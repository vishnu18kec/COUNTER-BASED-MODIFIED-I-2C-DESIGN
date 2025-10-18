`timescale 1ns/1ps

module sda_receiver (
    input  wire       clk,
    input  wire       rst_n,     // active low reset
    input  wire       q,         // serial input bit (from left_shift_counter)
    input  wire [3:0] qcnt,      // bit counter (from left_shift_counter)
    output reg  [7:0] data_out,  // received byte
    output reg        ack        // high for one clock when full byte received
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_out <= 8'd0;
            ack      <= 1'b0;
        end else begin
            ack <= 1'b0; // default no-ack every cycle

            // Capture bits as they come
            if (qcnt > 0 && qcnt <= 8) begin
                data_out <= {data_out[6:0], q};  // shift left and store q (MSB first)
            end

            // After 8 bits received -> raise ACK for one cycle
            if (qcnt == 4'd8) begin
                ack <= 1'b1;
            end
        end
    end

endmodule

