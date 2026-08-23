module fft_top(
    input logic clk,
    input logic rst_n,
    input logic [7:0] u_in,
    input logic [7:0] uio_in,
    output logic [7:0] uio_out,
    output logic [7:0] u_out
);

    logic [7:0] opcode_reg; 

    localparam OP_COMPUTE = 8'h1;
    localparam OP_LOAD_BANK_A = 8'h2;
    localparam OP_LOAD_BANK_B = 8'h3;
    localparam OP_READ_OUTPUTS = 8'h4;


   always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            opcode_reg <= 0;
        end else begin
            opcode_reg <= uio_in;
        end
    end
    


enmdodule