`timescale 1ns/1ns
`include "complex_types.svh"

module radix_2_butterfly #(
    parameter DATA_WIDTH = 16
) (
    input  logic       clkIn,
    input  logic       rstIn,
    input  logic       enIn,
    input  logic       validIn,
    input  ComplexType dataIn,
    output logic       validOut,
    output ComplexType dataOut
);

    // X[k] = sum( x[n] * e^{j*2*pi*n*k/N} )
    // X[0] = x[0] + x[1]
    // X[1] = x[0] - x[1]
    
    typedef enum {DATA_0, DATA_1} StateType;
    
    logic [2:0] validR;
    
    StateType stateR;
    
    always @(posedge clkIn) begin
        if (rstIn) begin
            stateR <= DATA_0;
        end else begin
            if (enIn) begin
                case (stateR)
                    DATA_0 : begin
                        if (validIn) begin
                            stateR <= DATA_1;
                        end
                    end
                    DATA_1 : begin
                        if (validIn) begin
                            stateR <= DATA_0;
                        end
                    end
                endcase
                validR <= {validR[1:0], validIn};
            end
        end
    end
    
    logic [DATA_WIDTH-1:0] dataRe;
    logic [DATA_WIDTH-1:0] dataIm;
    
    assign dataRe = unpackReal(dataIn.re, DATA_WIDTH);
    assign dataIm = unpackReal(dataIn.im, DATA_WIDTH);
    
    logic signed [DATA_WIDTH:0] dataExtendRe;
    logic signed [DATA_WIDTH:0] dataExtendIm;
    
    assign dataExtendRe = {dataRe[DATA_WIDTH-1], dataRe};
    assign dataExtendIm = {dataIm[DATA_WIDTH-1], dataIm};
    
    logic signed [DATA_WIDTH:0] dataExtendReR;
    logic signed [DATA_WIDTH:0] dataExtendImR;
    logic signed [1:0][DATA_WIDTH:0] dataReR;
    logic signed [1:0][DATA_WIDTH:0] dataImR;
    logic signed [DATA_WIDTH:0] dataOutReR;
    logic signed [DATA_WIDTH:0] dataOutImR;
    
    always @(posedge clkIn) begin
        if (enIn) begin
            case (stateR)
                DATA_0 : begin
                    dataExtendReR   <= dataExtendRe;
                    dataExtendImR   <= dataExtendIm;
                    dataReR[1]      <= -dataReR[1];
                    dataImR[1]      <= -dataImR[1];
                end
                DATA_1 : begin
                    dataReR[0]      <= dataExtendReR;
                    dataImR[0]      <= dataExtendImR;
                    dataReR[1]      <= dataExtendRe;
                    dataImR[1]      <= dataExtendIm;
                end
            endcase
            
            dataOutReR              <= dataReR[0] + dataReR[1];
            dataOutImR              <= dataImR[0] + dataImR[1];
        end
    end
    
    assign dataOut.re = packReal($unsigned(dataOutReR), DATA_WIDTH+1);
    assign dataOut.im = packReal($unsigned(dataOutImR), DATA_WIDTH+1);
    assign validOut   = validR[2];
    
endmodule
