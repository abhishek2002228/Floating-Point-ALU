float2int:
	iverilog -o float2int float2int.v test_float2int.v
	vvp float2int
	gtkwave float2int.vcd
int2float:
	iverilog -o int2float int2float.v test_int2float.v
	vvp int2float
	gtkwave int2float.vcd
fadd_sub:
	iverilog -o fadd_sub fadd_sub.v test_fadd_sub.v
	vvp fadd_sub
	gtkwave fadd_sub.vcd
p_fadd_sub:
	iverilog -o p_fadd_sub p_fadd_sub.v test_p_fadd_sub.v
	vvp p_fadd_sub
	gtkwave p_fadd_sub.vcd
fmul:
	iverilog -o fmul fmul.v test_fmul.v
	vvp fmul
	gtkwave fmul.vcd
clean:
	rm float2int float2int.vcd int2float int2float.vcd fadd_sub fadd_sub.vcd fmul fmul.vcd p_fadd_sub p_fadd_sub.vcd