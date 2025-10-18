`timescale 1ns/1ps

module cpu_controller (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       ack,          // ack from SDA receiver
    output reg        en,           // enable pulse for left_shift_counter
    output reg  [7:0] din,          // data to send
    output reg        I,            // 0=new byte started, 1=finished (ACK)
    output reg        sda_enable    // stays high for 8 full cycles
);

    reg ack_d;
    wire ack_rise;
    wire I_fall = (~I) & I_d;
    wire I_rise = I & (~I_d);
    reg [1:0] state;
    reg [3:0] sda_cnt;
    reg [2:0] index;
    reg [7:0] mem [0:4];
    reg [7:0] I_counter;  // free-running counter when I=0
    reg       I_d;        // for edge detection

    parameter S_IDLE     = 2'b00;
    parameter S_SENDING  = 2'b01;
    parameter S_WAIT_ACK = 2'b10;
    parameter S_DONE     = 2'b11;
    parameter LAST_INDEX = 3'd4;

    assign ack_rise = ack & ~ack_d;

    // Edge detector for ACK
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            ack_d <= 1'b0;
        else
            ack_d <= ack;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state      <= S_IDLE;
            en         <= 1'b0;
            din        <= 8'b0;
            I          <= 1'b0;
            sda_enable <= 1'b0;
            sda_cnt    <= 4'd0;
            index      <= 3'd0;

            // Initialize memory (ADDR,DATA,ADDR,DATA,ADDR)
            mem[0] <= 8'hA0;
            mem[1] <= 8'h11;
            mem[2] <= 8'hA2;
            mem[3] <= 8'h22;
            mem[4] <= 8'hA4;
        end else begin
            case (state)
                // Load and start transmission
                S_IDLE: begin
                    if (index <= LAST_INDEX) begin
                        din        <= mem[index];
                        en         <= 1'b1;   // pulse once
                        I          <= 1'b0;   // mark "new transmission"
                        sda_enable <= 1'b1;   // start SDA high
                        sda_cnt    <= 4'd0;   // start counting from 0
                        state      <= S_SENDING;
                    end else begin
                        en         <= 1'b0;
                        sda_enable <= 1'b0;
                        state      <= S_DONE;
                    end
                end

                // Keep sda_enable HIGH for full 8 cycles
                S_SENDING: begin
                    en <= 1'b0;
                    if (sda_cnt < 4'd7) begin
                        sda_cnt <= sda_cnt + 1'b1;
                    end else begin
                        // This edge completes the 8th cycle
                        sda_enable <= 1'b0;  // drop SDA after full 8 periods
                        state      <= S_WAIT_ACK;
                    end
                end

                // Wait for ACK from receiver
                S_WAIT_ACK: begin
                    if (ack_rise) begin
                        I <= 1'b1; // mark finished
                        if (index < LAST_INDEX)
                            index <= index + 1'b1;
                        state <= (index < LAST_INDEX) ? S_IDLE : S_DONE;
                    end
                end

                S_DONE: begin
                    en         <= 1'b0;
                    sda_enable <= 1'b0;
                end

                default: state <= S_IDLE;
            endcase
        end
    end
endmodule

