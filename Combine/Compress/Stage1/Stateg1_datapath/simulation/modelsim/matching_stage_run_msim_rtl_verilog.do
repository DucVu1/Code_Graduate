transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/Duc/A\ PLACE\ HOLDER/GitHub/Code\ Graduate/Code_Graduate/Compress/Stage1/Stateg1_datapath/src {C:/Users/Duc/A PLACE HOLDER/GitHub/Code Graduate/Code_Graduate/Compress/Stage1/Stateg1_datapath/src/word_decoder.sv}
vlog -sv -work work +incdir+C:/Users/Duc/A\ PLACE\ HOLDER/GitHub/Code\ Graduate/Code_Graduate/Compress/Stage1/Stateg1_datapath/src {C:/Users/Duc/A PLACE HOLDER/GitHub/Code Graduate/Code_Graduate/Compress/Stage1/Stateg1_datapath/src/word_length_generator.sv}
vlog -sv -work work +incdir+C:/Users/Duc/A\ PLACE\ HOLDER/GitHub/Code\ Graduate/Code_Graduate/Compress/Stage1/Stateg1_datapath/src {C:/Users/Duc/A PLACE HOLDER/GitHub/Code Graduate/Code_Graduate/Compress/Stage1/Stateg1_datapath/src/word_comparator.sv}
vlog -sv -work work +incdir+C:/Users/Duc/A\ PLACE\ HOLDER/GitHub/Code\ Graduate/Code_Graduate/Compress/Stage1/Stateg1_datapath/src {C:/Users/Duc/A PLACE HOLDER/GitHub/Code Graduate/Code_Graduate/Compress/Stage1/Stateg1_datapath/src/max2_with_index.sv}
vlog -sv -work work +incdir+C:/Users/Duc/A\ PLACE\ HOLDER/GitHub/Code\ Graduate/Code_Graduate/Compress/Stage1/Stateg1_datapath/src {C:/Users/Duc/A PLACE HOLDER/GitHub/Code Graduate/Code_Graduate/Compress/Stage1/Stateg1_datapath/src/max_selector.sv}
vlog -sv -work work +incdir+C:/Users/Duc/A\ PLACE\ HOLDER/GitHub/Code\ Graduate/Code_Graduate/Compress/Stage1/Stateg1_datapath/src {C:/Users/Duc/A PLACE HOLDER/GitHub/Code Graduate/Code_Graduate/Compress/Stage1/Stateg1_datapath/src/matching_stage.sv}
vlog -sv -work work +incdir+C:/Users/Duc/A\ PLACE\ HOLDER/GitHub/Code\ Graduate/Code_Graduate/Compress/Stage1/Stateg1_datapath/src {C:/Users/Duc/A PLACE HOLDER/GitHub/Code Graduate/Code_Graduate/Compress/Stage1/Stateg1_datapath/src/fifo_dict.sv}
vlog -sv -work work +incdir+C:/Users/Duc/A\ PLACE\ HOLDER/GitHub/Code\ Graduate/Code_Graduate/Compress/Stage1/Stateg1_datapath/src {C:/Users/Duc/A PLACE HOLDER/GitHub/Code Graduate/Code_Graduate/Compress/Stage1/Stateg1_datapath/src/control_signal_generator.sv}
vlog -sv -work work +incdir+C:/Users/Duc/A\ PLACE\ HOLDER/GitHub/Code\ Graduate/Code_Graduate/Compress/Stage1/Stateg1_datapath/src {C:/Users/Duc/A PLACE HOLDER/GitHub/Code Graduate/Code_Graduate/Compress/Stage1/Stateg1_datapath/src/compare_value.sv}
vlog -sv -work work +incdir+C:/Users/Duc/A\ PLACE\ HOLDER/GitHub/Code\ Graduate/Code_Graduate/Compress/Stage1/Stateg1_datapath/src {C:/Users/Duc/A PLACE HOLDER/GitHub/Code Graduate/Code_Graduate/Compress/Stage1/Stateg1_datapath/src/comparator_array4.sv}
vlog -sv -work work +incdir+C:/Users/Duc/A\ PLACE\ HOLDER/GitHub/Code\ Graduate/Code_Graduate/Compress/Stage1/Stateg1_datapath/src {C:/Users/Duc/A PLACE HOLDER/GitHub/Code Graduate/Code_Graduate/Compress/Stage1/Stateg1_datapath/src/comparator_array2.sv}
vlog -sv -work work +incdir+C:/Users/Duc/A\ PLACE\ HOLDER/GitHub/Code\ Graduate/Code_Graduate/Compress/Stage1/Stateg1_datapath/src {C:/Users/Duc/A PLACE HOLDER/GitHub/Code Graduate/Code_Graduate/Compress/Stage1/Stateg1_datapath/src/comparator_array1.sv}
vlog -sv -work work +incdir+C:/Users/Duc/A\ PLACE\ HOLDER/GitHub/Code\ Graduate/Code_Graduate/Compress/Stage1/Stateg1_datapath/src {C:/Users/Duc/A PLACE HOLDER/GitHub/Code Graduate/Code_Graduate/Compress/Stage1/Stateg1_datapath/src/comparator.sv}

