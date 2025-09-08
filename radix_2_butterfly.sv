`timescale 1ns/1ns

module radix_2_butterfly #(
    parameter DATA_WIDTH = 16
) (
    input  logic clkIn,
    input  logic rstIn,
    input  logic enIn,
    input  logic validIn,
    input  logic [DATA_WIDTH-1:0] dataIn,
    output logic validOut,
    output logic [DATA_WIDTH:0] dataOut
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
    
    logic signed [DATA_WIDTH:0] dataExtend;
    logic signed [DATA_WIDTH:0] dataExtendR;
    logic signed [1:0][DATA_WIDTH:0] dataR;
    logic signed [DATA_WIDTH:0] dataOutR;
    
    assign dataExtend = {dataIn[DATA_WIDTH-1], dataIn};
    
    always @(posedge clkIn) begin
        if (enIn) begin
            case (stateR)
                DATA_0 : begin
                    dataExtendR <= dataExtend;
                    dataR[1]    <= -dataR[1];
                end
                DATA_1 : begin
                    dataR[0]    <= dataExtendR;
                    dataR[1]    <= dataExtend;
                end
            endcase
            
            dataOutR          <= dataR[0] + dataR[1];
        end
    end
    
    assign dataOut  = dataOutR;
    assign validOut = validR[2];
    
endmodule
