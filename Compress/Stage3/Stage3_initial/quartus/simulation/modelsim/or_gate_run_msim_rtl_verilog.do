transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/Duc/A\ PLACE\ HOLDER/GitHub/Code\ Graduate/Code_Graduate/Compress/Stage3/Stage3_initial/src {C:/Users/Duc/A PLACE HOLDER/GitHub/Code Graduate/Code_Graduate/Compress/Stage3/Stage3_initial/src/or_gate.sv}

