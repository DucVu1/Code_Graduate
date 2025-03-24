onerror {quit -f}
vlib work
vlog -work work matching_stage.vo
vlog -work work matching_stage.vt
vsim -novopt -c -t 1ps -L cycloneii_ver -L altera_ver -L altera_mf_ver -L 220model_ver -L sgate work.matching_stage_vlg_vec_tst
vcd file -direction matching_stage.msim.vcd
vcd add -internal matching_stage_vlg_vec_tst/*
vcd add -internal matching_stage_vlg_vec_tst/i1/*
add wave /*
run -all
