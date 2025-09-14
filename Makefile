# Use spaces instead of tabs
.RECIPEPREFIX := $() $()

SOURCES := \
    radix_2_butterfly_tb.sv \
    radix_2_butterfly.sv

TB := radix_2_butterfly_tb.sv

EXECUTABLE := $(shell echo "./obj_dir/V$(TB)" | sed 's/.sv//g')

.PHONY: all clean

all: $(EXECUTABLE)
    rm "waveform.vcd"
    $(EXECUTABLE)
    
$(EXECUTABLE): $(SOURCES)
    verilator --binary --timing --trace $(SOURCES)

clean:
    rm -rf obj_dir
    $(MAKE) all
