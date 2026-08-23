module twiddle_ROM(

    input logic clk,
    input logic [9:0] rom_addr,
    output logic [15:0] twiddle_re,
    output logic [15:0] twiddle_im

);

    logic [15:0] twiddle_factors [0:1024];
        
    initial begin

        $readmemh("twiddle_lut.mem", twiddle_factors);

        //check if values loaded correctly 
        $display("Index 0: %h", twiddle_factors[0]);
        $display("Index 16: %h", twiddle_factors[16]);

    end

    //ROM read logic
    always_ff@(posedge clk) begin
        
    end

endmodule
