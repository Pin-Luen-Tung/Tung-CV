clear -all
check_cov -init -type all
jasper_scoreboard_3 -init
# include source code
analyze -v2k [glob ../source/modified/biriscv/biriscv/core/biriscv_decode.v]
analyze -sv  [glob ../property/sb3.sv]
elaborate -top fetch_fifo
# set clock and reset signal
clock clk_i
reset rst_i
assume {flush_i == 1'b0}
set_prove_time_limit 259200s
prove -all