module fifo #(
    DATA_WIDTH = 32,
    DEPTH      = 32,
    SKID       = 0) (
    input  logic clkIn,
    input  logic rstIn,
    input  logic wrValidIn,
    output logic wrConsentOut,
    input  logic [DATA_WIDTH-1:0] wrDataIn,
    output logic rdValidOut,
    input  logic rdConsentIn,
    output logic [DATA_WIDTH-1:0] rdDataOut);
    
    localparam ADDR_WIDTH = $clog2(DEPTH);
    
    logic [ADDR_WIDTH-1:0] rdAddrR;
    logic [ADDR_WIDTH-1:0] wrAddrR;
    logic [ADDR_WIDTH:0] countR;
    logic rdValidR;
    logic wrConsentR;
    logic rstR;
    
    logic wrValid;
    logic rdValid;
    
    assign wrValid = wrValidIn & wrConsentR;
    assign rdValid = rdValidR & rdConsentIn;
    
    always @(posedge clkIn) begin
        rstR                    <= rstIn;
        if (rstIn) begin
            wrAddrR             <= 0;
            rdAddrR             <= 0;
            countR              <= 0;
            rdValidR            <= 0;
            wrConsentR          <= 0;
        end else begin
            if (rstR) begin
                wrConsentR      <= 1;
            end
            if (wrValid) begin
                wrAddrR         <= wrAddrR + 1;
            end
            if (rdValid) begin
                rdAddrR         <= rdAddrR + 1;
            end
            if (wrValid && !rdValid) begin
                countR          <= countR + 1;
                rdValidR        <= 1;
                if (countR == (DEPTH - SKID - 1)) begin
                    wrConsentR  <= 0;
                end
            end else if (!wrValid && rdValid) begin
                countR          <= countR - 1;
                wrConsentR      <= 1;
                if (countR == 1) begin
                    rdValidR    <= 0;
                end
            end
        end
    end
    
    assign rdValidOut = rdValidR;
    assign wrConsentOut = wrConsentR;
    
    dp_ram #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH))
        ram (
        .clkIn(clkIn),
        .wrEnIn(wrValidIn),
        .wrAddrIn(wrAddrR),
        .wrDataIn(wrDataIn),
        .rdAddrIn(rdAddrR),
        .rdDataOut(rdDataOut));

endmodule