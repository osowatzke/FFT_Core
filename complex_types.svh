`ifndef COMPLEX_TYPES_SVH_
`define COMPLEX_TYPES_SVH_

parameter REAL_DATA_WIDTH = 32;

typedef logic[REAL_DATA_WIDTH-1:0] RealDataType;

function automatic RealDataType unpackReal(input RealDataType arg, input int NUM_BITS);
    if (NUM_BITS > REAL_DATA_WIDTH) begin
        $error("Attempted to grab %d bits from %d bit RealDataType", NUM_BITS, REAL_DATA_WIDTH);
    end
    return arg >> (REAL_DATA_WIDTH - NUM_BITS);
endfunction

function automatic RealDataType packReal(input RealDataType arg, input int NUM_BITS);
    if (NUM_BITS > REAL_DATA_WIDTH) begin
        $error("Attempted to pack %d bits in %d bit RealDataType", NUM_BITS, REAL_DATA_WIDTH);
    end
    return arg << (REAL_DATA_WIDTH - NUM_BITS);
endfunction

typedef struct packed {
    RealDataType re;
    RealDataType im;
} ComplexType;

typedef logic[2*REAL_DATA_WIDTH-1:0] ComplexLogicType;

function automatic ComplexLogicType complexToLogic(input ComplexType arg);
    return {arg.im, arg.re};
endfunction

function automatic ComplexType logicToComplex(input ComplexLogicType arg);
    return '{re: arg[REAL_DATA_WIDTH-1:0], im: arg[2*REAL_DATA_WIDTH-1:REAL_DATA_WIDTH]};
endfunction

`endif // COMPLEX_TYPES_SVH_
