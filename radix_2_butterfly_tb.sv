`timescale 1ns/1ns

module radix_2_butterfly_tb #(
    parameter DATA_WIDTH = 32,
    parameter CLK_PERIOD = 10,
    parameter RESET_TIME = 100);

    logic clk, rst;
    
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars();
        clk = 0;
        rst = 1;
        #RESET_TIME;
        rst = 0;
    end
    
    initial begin
        #10000;
        $finish();
    end
        
    
    assign #(CLK_PERIOD/2) clk = !clk;
    
    logic [DATA_WIDTH-1:0] dataR;
    logic validR;
    
    always @(posedge clk) begin
        if (rst) begin
            dataR   <= 0;
            validR  <= 0;
        end else begin
            dataR   <= $random;
            validR  <= 1;
        end
    end
    
    logic resultValid;
    logic [DATA_WIDTH:0] result;
    
    radix_2_butterfly #(
        .DATA_WIDTH(DATA_WIDTH))
        r2_butterfly (
        .clkIn(clk),
        .rstIn(rst),
        .enIn(1'b1),
        .dataIn(dataR),
        .validIn(validR),
        .validOut(resultValid),
        .dataOut(result));
        
endmodule
