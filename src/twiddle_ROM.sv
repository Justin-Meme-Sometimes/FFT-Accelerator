module twiddle_ROM(

    input logic clk,
    input logic [8:0] rom_addr,
    output logic [15:0] twiddle_re,
    output logic [15:0] twiddle_im

);

    logic [31:0] twiddle_factors [0:511];
    logic [31:0] rom_data_reg;
        
    initial begin

        $readmemh("twiddle_lut.mem", twiddle_factors);

        //check if values loaded correctly 
        $display("Index 0: %h", twiddle_factors[0]);
        $display("Index 16: %h", twiddle_factors[16]);

    end

    //ROM read logic
    always_ff@(posedge clk) begin
        
        rom_data_reg <= twiddle_factors[rom_addr];

    end

    assign twiddle_re = rom_data_reg[31:16];
    assign twiddle_im = rom_data_reg[15:0];

endmodule
