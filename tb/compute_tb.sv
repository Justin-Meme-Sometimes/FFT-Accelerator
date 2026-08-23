`timescale 1ns/1ps

// Testbench for the `compute` butterfly unit (src/compute_unit.sv).
// File-based co-simulation: reads Q8.8 stimulus produced by tb/gen_vectors.py
// from tb/vectors.hex, drives the DUT, and writes captured outputs to
// tb/dut_out.hex for tb/compare.py to check against tb/golden.hex.
//
// Each vector is held constant for CYCLES_PER_VECTOR clock cycles before
// sampling the outputs. This is deliberately more than the DUT's actual
// pipeline depth so the testbench doesn't depend on knowing that depth
// exactly - by the time we sample, the pipeline has fully settled on the
// current vector and flushed the previous one (there's no feedback path).

module compute_tb;

    localparam int CLK_PERIOD_NS      = 10;
    localparam int CYCLES_PER_VECTOR  = 6;

    logic clk;
    logic rst_n;

    logic signed [15:0] a_r, a_i, b_r, b_i, w_r, w_i;
    logic signed [15:0] out_0_r, out_0_i, out_1_r, out_1_i;

    compute dut (
        .clk     (clk),
        .rst_n   (rst_n),
        .a_r     (a_r),
        .a_i     (a_i),
        .b_r     (b_r),
        .b_i     (b_i),
        .w_r     (w_r),
        .w_i     (w_i),
        .out_0_r (out_0_r),
        .out_0_i (out_0_i),
        .out_1_r (out_1_r),
        .out_1_i (out_1_i)
    );

    initial clk = 0;
    always #(CLK_PERIOD_NS/2) clk = ~clk;

    int in_fd, out_fd;
    int code;
    int vec_count;

    initial begin
        rst_n = 0;
        a_r = '0; a_i = '0; b_r = '0; b_i = '0; w_r = '0; w_i = '0;

        repeat (4) @(posedge clk);
        rst_n = 1;
        @(posedge clk);

        in_fd = $fopen("tb/vectors.hex", "r");
        if (in_fd == 0) begin
            $fatal(1, "compute_tb: could not open tb/vectors.hex - run tb/gen_vectors.py first");
        end
        out_fd = $fopen("tb/dut_out.hex", "w");

        vec_count = 0;
        while (!$feof(in_fd)) begin
            code = $fscanf(in_fd, "%h %h %h %h %h %h", a_r, a_i, b_r, b_i, w_r, w_i);
            if (code != 6) begin
                // hit EOF / trailing blank line
                break;
            end

            repeat (CYCLES_PER_VECTOR) @(posedge clk);
            #1; // let combinational logic settle after the last edge

            $fdisplay(out_fd, "%04h %04h %04h %04h", out_0_r, out_0_i, out_1_r, out_1_i);
            vec_count++;
        end

        $fclose(in_fd);
        $fclose(out_fd);
        $display("compute_tb: applied %0d vectors, results written to tb/dut_out.hex", vec_count);
        $finish;
    end

    // safety net in case a run hangs
    initial begin
        #100000;
        $fatal(1, "compute_tb: timeout - simulation did not finish");
    end

endmodule
