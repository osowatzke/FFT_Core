module dp_ram #(
    DATA_WIDTH = 32;
    ADDR_WIDTH = 32) (
    input  logic clkIn,
    input  logic wrEnIn,
    input  logic [ADDR_WIDTH-1:0] wrAddrIn,
    input  logic [DATA_WIDTH-1:0] wrDataIn,
    input  logic [ADDR_WIDTH-1:0] rdAddrIn,
    input  logic [DATA_WIDTH-1:0] rdDataOut);
    
    localparam DEPTH = 1 << ADDR_WIDTH;
    
    logic [DEPTH-1:0][DATA_WIDTH-1:0] dataR
    logic [DATA_WIDTH-1:0] rdDataR;
    
    always @(posedge clkIn) begin
        if (wrEnIn) begin
            dataR[wrAddrIn] = wrDataIn; // Write-First
        end
        rdDataR             <= dataR[rdAddrIn];
    end
    
    assign rdDataOut = rdDataR;
    
endmodule
