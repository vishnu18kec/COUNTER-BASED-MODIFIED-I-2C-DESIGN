`timescale 1ns/1ps

module tb_top_system;

    reg clk;
    reg rst_n;

    // Instantiate Top System
    top_system uut (
        .clk(clk),
        .rst_n(rst_n)
    );

    // Clock generation: 10ns period (100MHz)
    always #5 clk = ~clk;

    initial begin
        // Initialize signals
        clk   = 0;
        rst_n = 0;

        // Apply reset
        #20;
        rst_n = 1;  // CPU will automatically send data

        // Wait for first ACK
        @(posedge uut.ack);
        $display("T=%0t : Received FIRST byte = %b | CPU I=%b", 
                  $time, uut.data_out, uut.I);

        // Wait for second ACK
        @(posedge uut.ack);
        $display("T=%0t : Received SECOND byte = %b | CPU I=%b", 
                  $time, uut.data_out, uut.I);

        #50;
        $stop;
    end

    // Monitor signals
    initial begin
        $monitor("T=%0t | ACK=%b I=%b DATA_OUT=%b", 
                  $time, uut.ack, uut.I, uut.data_out);
    end

    // Dump waveform for GTKWave
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_top_system);
    end

endmodule

