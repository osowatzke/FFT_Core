`timescale 1ns/1ns
`include "complex_types.svh"

module radix_2_butterfly_tb #(
    parameter DATA_WIDTH = 16,
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
    
    logic [DATA_WIDTH-1:0] dataReVar;
    logic [DATA_WIDTH-1:0] dataImVar;
    logic [DATA_WIDTH-1:0] dataReR;
    logic [DATA_WIDTH-1:0] dataImR;
    logic validR;
    
    logic wrCntR;
    logic [DATA_WIDTH:0] sumReVar;
    logic [DATA_WIDTH:0] sumImVar;
    logic [DATA_WIDTH:0] diffReVar;
    logic [DATA_WIDTH:0] diffImVar;
    logic [2*DATA_WIDTH+1:0] sumWrDataR;
    logic [2*DATA_WIDTH+1:0] diffWrDataR;
    logic fifoWrValidR;
    
    always @(posedge clk) begin
        if (rst) begin
            dataReR             <= 0;
            dataImR             <= 0;
            validR              <= 0;
            wrCntR              <= 0;
            sumWrDataR          <= 0;
            diffWrDataR         <= 0;
            fifoWrValidR        <= 0;
        end else begin
            dataReVar            = $random;
            dataImVar            = $random;
            dataReR             <= dataReVar;
            dataImR             <= dataImVar;
            validR              <= 1;
            wrCntR              <= wrCntR + 1;
            fifoWrValidR        <= 0;
            if (wrCntR == 1) begin
                wrCntR          <= 0;
                fifoWrValidR    <= 1;
                sumReVar         = $signed({dataReR[DATA_WIDTH-1], dataReR}) +
                                   $signed({dataReVar[DATA_WIDTH-1], dataReVar});
                sumImVar         = $signed({dataImR[DATA_WIDTH-1], dataImR}) +
                                   $signed({dataImVar[DATA_WIDTH-1], dataImVar});
                diffReVar        = $signed({dataReR[DATA_WIDTH-1], dataReR}) -
                                   $signed({dataReVar[DATA_WIDTH-1], dataReVar});
                diffImVar        = $signed({dataImR[DATA_WIDTH-1], dataImR}) -
                                   $signed({dataImVar[DATA_WIDTH-1], dataImVar});
                sumWrDataR      <= {sumImVar, sumReVar};
                diffWrDataR     <= {diffImVar, diffReVar};
            end
        end
    end
    
    logic resultValid;
    ComplexType data;
    ComplexType result;
    
    assign data.re = packReal(dataReR, DATA_WIDTH);
    assign data.im = packReal(dataImR, DATA_WIDTH);

    radix_2_butterfly #(
        .DATA_WIDTH(DATA_WIDTH))
        r2_butterfly (
        .clkIn(clk),
        .rstIn(rst),
        .enIn(1'b1),
        .dataIn(data),
        .validIn(validR),
        .validOut(resultValid),
        .dataOut(result));
    
    logic rdCntR;
    logic sumRdValid;
    logic sumRdConsent;
    logic [2*DATA_WIDTH+1:0] sumRdData;
    
    assign sumRdConsent = (rdCntR == 0) ? resultValid : 0;
    
    fifo #(
        .DATA_WIDTH(2*(DATA_WIDTH+1)))
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
    logic [2*DATA_WIDTH+1:0] diffRdData;
    
    assign diffRdConsent = (rdCntR == 1) ? resultValid : 0;
        
    fifo #(
        .DATA_WIDTH(2*(DATA_WIDTH+1)))
        diff_fifo (
        .clkIn(clk),
        .rstIn(rst),
        .wrValidIn(fifoWrValidR),
        .wrDataIn(diffWrDataR),
        .rdValidOut(diffRdValid),
        .rdConsentIn(diffRdConsent),
        .rdDataOut(diffRdData));
        
    logic [DATA_WIDTH:0] expectedVar;
    logic [DATA_WIDTH:0] resultVar;
    
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
                    expectedVar = sumRdData[DATA_WIDTH:0];
                    resultVar   = unpackReal(result.re, DATA_WIDTH+1);
                    if (expectedVar !== resultVar) begin
                        $error("Real part of result: %d does not matched expected value: %d", resultVar, expectedVar);
                    end
                    expectedVar = sumRdData[2*DATA_WIDTH+1:DATA_WIDTH+1];
                    resultVar   = unpackReal(result.im, DATA_WIDTH+1);
                    if (expectedVar !== resultVar) begin
                        $error("Imaginary part of result: %d does not matched expected value: %d", resultVar, expectedVar);
                    end
                end
                else begin
                    if(!diffRdValid) begin
                        $error("Expected diffRdValid = 1 when resultValid = 1");
                    end
                    expectedVar = diffRdData[DATA_WIDTH:0];
                    resultVar   = unpackReal(result.re, DATA_WIDTH+1);
                    if (expectedVar !== resultVar) begin
                        $error("Real part of result: %d does not matched expected value: %d", resultVar, expectedVar);
                    end
                    expectedVar = diffRdData[2*DATA_WIDTH+1:DATA_WIDTH+1];
                    resultVar   = unpackReal(result.im, DATA_WIDTH+1);
                    if (expectedVar !== resultVar) begin
                        $error("Imaginary part of result: %d does not matched expected value: %d", resultVar, expectedVar);
                    end
                end
            end
        end
    end
        
endmodule
