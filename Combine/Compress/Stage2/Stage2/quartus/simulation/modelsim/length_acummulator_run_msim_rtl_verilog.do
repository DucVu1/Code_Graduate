transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/Duc/A\ PLACE\ HOLDER/GitHub/Code\ Graduate/Code_Graduate/Compress/Stage2/Stage2/src {C:/Users/Duc/A PLACE HOLDER/GitHub/Code Graduate/Code_Graduate/Compress/Stage2/Stage2/src/word_length_generator.sv}
vlog -sv -work work +incdir+C:/Users/Duc/A\ PLACE\ HOLDER/GitHub/Code\ Graduate/Code_Graduate/Compress/Stage2/Stage2/src {C:/Users/Duc/A PLACE HOLDER/GitHub/Code Graduate/Code_Graduate/Compress/Stage2/Stage2/src/length_generation.sv}
vlog -sv -work work +incdir+C:/Users/Duc/A\ PLACE\ HOLDER/GitHub/Code\ Graduate/Code_Graduate/Compress/Stage2/Stage2/src {C:/Users/Duc/A PLACE HOLDER/GitHub/Code Graduate/Code_Graduate/Compress/Stage2/Stage2/src/length_accumulator.sv}
vlog -sv -work work +incdir+C:/Users/Duc/A\ PLACE\ HOLDER/GitHub/Code\ Graduate/Code_Graduate/Compress/Stage2/Stage2/src {C:/Users/Duc/A PLACE HOLDER/GitHub/Code Graduate/Code_Graduate/Compress/Stage2/Stage2/src/total_length_generator.sv}

