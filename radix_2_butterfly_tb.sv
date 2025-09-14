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
    
    logic [DATA_WIDTH-1:0] dataVar;
    logic [DATA_WIDTH-1:0] dataR;
    logic validR;
    
    logic wrCntR;
    logic [DATA_WIDTH:0] sumWrDataR;
    logic [DATA_WIDTH:0] diffWrDataR;
    logic fifoWrValidR;
    
    always @(posedge clk) begin
        if (rst) begin
            dataR               <= 0;
            validR              <= 0;
            wrCntR              <= 0;
            sumWrDataR          <= 0;
            diffWrDataR         <= 0;
            fifoWrValidR        <= 0;
        end else begin
            dataVar             = $random;
            dataR               <= dataVar;
            validR              <= 1;
            wrCntR              <= wrCntR + 1;
            fifoWrValidR        <= 0;
            if (wrCntR == 1) begin
                wrCntR          <= 0;
                fifoWrValidR    <= 1;
                sumWrDataR      <= $signed({dataR[DATA_WIDTH-1], dataR}) +
                                   $signed({dataVar[DATA_WIDTH-1], dataVar});
                diffWrDataR     <= $signed({dataR[DATA_WIDTH-1], dataR}) -
                                   $signed({dataVar[DATA_WIDTH-1], dataVar});
            end
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
    
    logic rdCntR;
    logic sumRdValid;
    logic sumRdConsent;
    logic [DATA_WIDTH:0] sumRdData;
    
    assign sumRdConsent = (rdCntR == 0) ? resultValid : 0;
    
    fifo #(
        .DATA_WIDTH(DATA_WIDTH+1))
        sum_fifo (
        .clkIn(clk),
        .rstIn(rst),
        .wrValidIn(fifoWrValidR),
        .wrDataIn(sumWrDataR),
        .rdValidOut(sumRdValid),
        .rdConsentIn(sumRdConsent),
        .rdDataOut(sumRdData));
    
    logic diffRdValid;
    logic diffRdConsent;
    logic [DATA_WIDTH:0] diffRdData;
    
    assign diffRdConsent = (rdCntR == 1) ? resultValid : 0;
        
    fifo #(
        .DATA_WIDTH(DATA_WIDTH+1))
        diff_fifo (
        .clkIn(clk),
        .rstIn(rst),
        .wrValidIn(fifoWrValidR),
        .wrDataIn(diffWrDataR),
        .rdValidOut(diffRdValid),
        .rdConsentIn(diffRdConsent),
        .rdDataOut(diffRdData));
        
    always @(posedge clk) begin
        if (rst) begin
            rdCntR <= 0;
        end
        else begin
            if (resultValid) begin
                rdCntR <= rdCntR + 1;
                if (rdCntR == 1) begin
                    rdCntR <= 0;
                end
                if(rdCntR == 0) begin
                    if (!sumRdValid) begin
                        $error("Expected sumRdValid = 1 when resultValid = 1");
                    end
                    if (sumRdData !== result) begin
                        $error("Result (0x%09X) does not matched Expected Result (0x%09X)", result, sumRdData);
                    end
                end
                else begin
                    if(!diffRdValid) begin
                        $error("Expected diffRdValid = 1 when resultValid = 1");
                    end
                    if (diffRdData !== result) begin
                        $error("Result (0x%09X) does not matched Expected Result (0x%09X)", result, diffRdData);
                    end
                end
            end
        end
    end
        
endmodule
