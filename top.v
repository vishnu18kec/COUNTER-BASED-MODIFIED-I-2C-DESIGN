`timescale 1ns/1ps

module top_system (
    input wire clk,
    input wire rst_n
);
    wire q;
    wire [3:0] qcnt;
    wire ack;
    wire [7:0] data_out;
    wire [7:0] din;
    wire en;
    wire I;
    wire sda_enable;

    // CPU controller
    cpu_controller cpu (
        .clk(clk),
        .rst_n(rst_n),
        .ack(ack),
        .en(en),
        .din(din),
        .I(I),
        .sda_enable(sda_enable)
    );

    // left_shift_counter (your existing module)
    left_shift_counter lsc (
        .clk(clk),
        .rst_n(rst_n),
        .en(en),
        .din(din),
        .q(q),
        .qcnt(qcnt)
    );

    // sda_receiver (your existing module)
    sda_receiver sda (
        .clk(clk),
        .rst_n(rst_n),
        .q(q),
        .qcnt(qcnt),
        .data_out(data_out),
        .ack(ack)
    );

    // expose signals for hierarchical access in testbench
    // (testbench can use uut.I, uut.sda_enable, uut.data_out, uut.ack)
    // top_system internal wires are accessible via hierarchical name (uut.I etc.)

endmodule

