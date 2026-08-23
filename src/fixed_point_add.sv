module fp_add 
#(paramter FRACTION_BITS = 8,
  parameter WHOLE_BITS = 8
)
(input logic  signed [15:0] a,
 input logic  signed  [15:0] b,
 output logic signed [16:0] out_x);

    assign out_x = a + b;
 endmodule;