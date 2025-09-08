verilator --binary -j 0 --timing --trace ./radix_2_butterfly.sv ./radix_2_butterfly_tb.sv

gtkwave waveform.vcd