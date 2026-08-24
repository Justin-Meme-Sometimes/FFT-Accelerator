module addr_gen (
    input  logic       clk,
    input  logic       rst_n,      // Active-low asynchronous reset
    input  logic       en,         // Enable counting
    output logic [8:0] rom_addr,   // Connects to twiddle_ROM.rom_addr
    output logic       valid       // High when ROM output is valid (delayed en)
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rom_addr <= '0;
        end else if (en) begin
            rom_addr <= rom_addr + 1'b1;
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid <= 1'b0;
        end else begin
            valid <= en; 
        end
    end

endmodule
