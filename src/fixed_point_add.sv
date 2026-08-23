module fp_add 
(input logic  signed [31:0] a,
 input logic  signed  [31:0] b,
 input logic  add_or_sub,
 output logic signed [31:0] sum);

    always_comb begin
        sum = 0;
        if(add_or_sub) begin
            sum = a + b;
        end else begin
            sum = a - b;
        end
    end
 endmodule