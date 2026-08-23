module fp_add 
#(paramter FRACTION_BITS = 8,
  parameter WHOLE_BITS = 8
)
(input logic  signed [(FRACTION_BITS-1)+(WHOLE_BITS-1):0] a,
 input logic  signed  [(FRACTION_BITS-1)+(WHOLE_BITS-1):0] b,
 output logic signed [(FRACTION_BITS-1)+(WHOLE_BITS-1)+1:0] out_x);

    assign out_x = a + b;
 endmodule;