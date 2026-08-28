module sram_buff (
    input logic clk,
    input logic rst_n,
    input logic [15:0] addr
    input logic [15:0] d_in
    input logic read,
    input logic write,
    output logic [15:0] d_out,
    output logic error,
);

logic read_new, write_newp;
always_comb begin  //to deal with contention
    read_new = read;
    write_new = write;
    error = '0;
    if(read && write) begin
        read_new = 0;
        write_new = 0;
        error = 1'd1;
    end
end

sky130_sram_4kbytes_1r1w_32x1024_8 buffer_a_mem (
  .clk0(clk), .csb0(!write_new), .wmask0(4'b1100),
  .addr0(addr), .din0(d_in),
  .clk1(clk), .csb1(!read_new), .addr1(addr),
  .dout1(d_out)
);

endmodule