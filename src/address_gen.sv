module address_gen (
    input  logic       clk,
    input  logic       rst_n,
    input  logic        start,
    input  logic        advance,
    input  logic [3:0]  stage,

    output logic [9:0]  addr_top,
    output logic [9:0]  addr_bot,
    output logic        parity_top,
    output logic        parity_bot,
    output logic [8:0]  twiddle_addr,

    output logic         stage_done
);

    logic [9:0] j_cnt;
    logic [9:0] half_group;
    logic [9:0] local_idx;
    logic [9:0] group_idx_shifted;

    assign half_group = 10'd1 << stage;

    assign local_idx = j_cnt & (half_group - 1'b1);

    assign group_idx_shifted = (j_cnt >> stage) << (stage + 1);

    assign addr_top = group_idx_shifted | local_idx;
    assign addr_bot = addr_top | half_group;

    assign parity_top = addr_top[0];
    assign parity_bot = addr_bot[0];

    assign twiddle_addr = local_idx[8:0] << (4'd9 - stage);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            j_cnt <= 10'd0;
        end else if (start) begin
            j_cnt <= 10'd0;
        end else if (advance) begin
            j_cnt <= j_cnt + 10'd1;
        end
    end

    assign stage_done = (j_cnt == 10'd511);

endmodule