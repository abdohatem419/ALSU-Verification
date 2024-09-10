vlib work
vlog ALSU.v ALSU_GM.v ALSU_process.sv ALSU_tb.sv  +cover -covercells
vsim -voptargs=+acc work.ALSU_tb -cover
add wave *
coverage save ALSU_tb.ucdb -onexit
run -all
