
// This is the pipeline compute unit for the FFT (A +/- B*W)
// p_r = b_r*w_r − b_i*w_i     real part of B*W
// p_i = b_r*w_i + b_i*w_r     imag part of B*W
// out0_r = a_r + p_r          out0_i = a_i + p_i     <- A + B*W
// out1_r = a_r − p_r          out1_i = a_i − p_i     <- A − B*W
// We also divide all out's by 2 aswell

module compute (
    input logic clk,
    input logic rst_n,
    input logic signed [15:0] a_r,    
    input logic signed [15:0] a_i,
    input logic signed [15:0] b_r,
    input logic signed [15:0] b_i,
    input logic signed [15:0] w_r,
    input logic signed [15:0] w_i,
    output logic signed [15:0] out_0_r,
    output logic signed [15:0] out_0_i,
    output logic signed [15:0] out_1_r,
    output logic signed [15:0] out_1_i
);

logic signed [31:0] s1_img_prod_1, s1_img_prod_2, s1_real_prod_1, s2_real_prod_2;
logic signed [31:0] s1_real_prod_2;
logic signed [31:0] s2_real_prod_1, s2_img_prod_1, s2_img_prod_2;
logic signed [31:0] s2_a_r, s2_a_i;
logic signed [31:0] s2_p_r_wide, s2_p_i_wide, s2_p_r_round, s2_p_i_round;
logic signed [31:0] s3_p_r, s3_p_i, s3_a_r, s3_a_i;
logic signed [31:0] s3_p_r_wide, s3_p_i_wide;
logic signed [15:0] s3_p_r_round, s3_p_i_round;
logic signed [15:0] s4_p_r, s4_p_i;
logic signed [31:0] s4_a_r, s4_a_i;
logic signed [31:0] s4_out_0_r_wide, s4_out_0_i_wide, s4_out_1_r_wide, s4_out_1_i_wide;
logic signed [31:0] s5_out_0_r_wide, s5_out_0_i_wide, s5_out_1_r_wide, s5_out_1_i_wide;
logic signed [15:0] out_0_r_unshifted, out_0_i_unshifted, out_1_r_unshifted, out_1_i_unshifted;


fp_mul s1_mul_real_1 (.a(b_r), .b(w_r), .product(s1_real_prod_1));
fp_mul s1_mul_real_2 (.a(b_i), .b(w_i), .product(s1_real_prod_2));
fp_mul s1_mul_img_1 (.a(b_r), .b(w_i), .product(s1_img_prod_1));
fp_mul s1_mul_img_2 (.a(b_i), .b(w_r), .product(s1_img_prod_2));

always_ff @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
        s2_real_prod_1 <= 0;
        s2_real_prod_2 <= 0;
        s2_img_prod_1 <= 0;
        s2_img_prod_2 <= 0;
        s2_a_r <= 0;
        s2_a_i <= 0;
    end else begin
        s2_real_prod_1 <= s1_real_prod_1;
        s2_real_prod_2 <= s1_real_prod_2;
        s2_img_prod_1 <= s1_img_prod_1;
        s2_img_prod_2 <= s1_img_prod_2;
        s2_a_r <= a_r;
        s2_a_i <= a_i;
    end
end

fp_add s2_real_add (.a(s2_real_prod_1), .b(s2_real_prod_2), .add_or_sub(0), .sum(s2_p_r_wide));
fp_add s2_img_add (.a(s2_img_prod_1), .b(s2_img_prod_2),   .add_or_sub(1), .sum(s2_p_i_wide));

always_ff @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
        s3_p_r_wide <= 0;
        s3_p_i_wide <= 0;
        s3_a_r <= 0;
        s3_a_i <= 0;
    end else begin
        s3_p_r_wide <= s2_p_r_wide;
        s3_p_i_wide <= s2_p_i_wide;
        s3_a_r <= s2_a_r;
        s3_a_i <= s2_a_i;
    end
end

round round_s3_1 (.a(s3_p_r_wide), .out(s3_p_r_round));
round round_s3_2 (.a(s3_p_i_wide), .out(s3_p_i_round));

always_ff @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
        s4_p_r <= 0;
        s4_p_i <= 0;
        s4_a_r <= 0;
        s4_a_i <= 0;
    end else begin
        s4_p_r <= s3_p_r_round;
        s4_p_i <= s3_p_i_round;
        s4_a_r <= s3_a_r;
        s4_a_i <= s3_a_i;
    end
end

fp_add s4_real_add_1 (.a(s4_a_r), .b(s4_p_r), .add_or_sub(1), .sum(s4_out_0_r_wide));
fp_add s4_img_add_1  (.a(s4_a_i), .b(s4_p_i), .add_or_sub(1), .sum(s4_out_0_i_wide));
fp_add s4_real_add_2 (.a(s4_a_r), .b(s4_p_r), .add_or_sub(0), .sum(s4_out_1_r_wide));
fp_add s4_img_add_2  (.a(s4_a_i), .b(s4_p_i), .add_or_sub(0), .sum(s4_out_1_i_wide));
always_ff @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
        s5_out_0_r_wide <= 0;
        s5_out_0_i_wide <= 0;
        s5_out_1_r_wide <= 0;
        s5_out_1_i_wide <= 0;
    end else begin
        s5_out_0_r_wide <= s4_out_0_r_wide;
        s5_out_0_i_wide <= s4_out_0_i_wide;
        s5_out_1_r_wide <= s4_out_1_r_wide;
        s5_out_1_i_wide <= s4_out_1_i_wide;
    end
end

assign out_0_r = $signed(s5_out_0_r_wide[15:0]) >>> 1; 
assign out_0_i = $signed(s5_out_0_i_wide[15:0]) >>> 1; 
assign out_1_r = $signed(s5_out_1_r_wide[15:0]) >>> 1; 
assign out_1_i = $signed(s5_out_1_i_wide[15:0]) >>> 1; 




    
endmodule


module round(
    input logic [31:0]a,
    output logic [15:0] out
); 
    logic [31:0] shifted_up_out;
    assign shifted_up_out = a + (1 <<< 7);
    assign out = shifted_up_out[23:8];
endmodule