module fp_mul (
    input logic signed [31:0] a,
    input logic signed [31:0] b,
    output logic signed [31:0] product
);
    assign product  = a * b;
endmodule
