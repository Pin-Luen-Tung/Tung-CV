clear -all
check_cov -init -type all

# include source code
analyze -sv [glob ../source/original/RV12/submodules/ahb3lite_pkg/rtl/verilog/*.sv]
analyze -sv [glob ../source/original/RV12/rtl/verilog/pkg/riscv_state_pkg.sv]
analyze -sv [glob ../source/original/RV12/rtl/verilog/pkg/*.sv]
analyze -sv [glob ../source/original/RV12/submodules/memory/rtl/verilog/*.sv]
analyze -sv [glob ../source/original/RV12/rtl/verilog/core/*.sv]
analyze -sv [glob ../source/original/RV12/rtl/verilog/core/ex/*.sv]
analyze -sv [glob ../source/original/RV12/rtl/verilog/core/cache/*.sv]
analyze -sv [glob ../source/original/RV12/rtl/verilog/core/mmu/*.sv]
analyze -sv [glob ../source/original/RV12/rtl/verilog/core/memory/*.sv]
analyze -sv [glob ../source/original/RV12/rtl/verilog/ahb3lite/*.sv]
analyze -sv [glob ../property/isa.sva]

elaborate -top riscv_top_ahb3lite

# Setup environment
set wait_user true
set g_necessaryInstances {}
set g_totalCost 0
set cpf_revision 1.0
# Read in HDL files

set_superlint_arithmetic_overflow_style both
set_superlint_arithmetic_overflow_enable_multiplication false

clock {HCLK}
reset ~HRESETn ~core.rst_ni
# Setup global environment
# Setup global clocks and resets
# Setup current task environment

# always fetch hit 
stopat core.if_unit.parcel_valid 
assume {core.if_unit.parcel_valid == 1'b1} 

# no debug mode
assume {core.du_stall == 1'b0}
assume {core.du_stall_if == 1'b0}
assume {core.du_re_rf == 1'b0}
assume {core.dbg_we_i == 1'b0}
assume {core.int_rf.du_we_rf_i == 0}
assume {core.cpu_state.du_we_csr_i == 0}

# no exception
assume {dmem_ctrl_inst.pma_exception == 0}
stopat core.if_unit.parcel_exceptions
assume {core.if_unit.parcel_exceptions == 0}
assume {core.wb_exceptions == 0}
assume {core.id_unit.my_exceptions == 0}

# always fetch legal instruction 
stopat core.if_unit.rv_instr
assume {core.if_unit.rv_instr == formaltest_RV12.rvfi_input_insn}



task -set <embedded>
set_proofgrid_per_engine_max_local_jobs 15
set_prove_cache on

set_prove_time_limit 259200s

prove -all
