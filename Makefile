float2int:
	iverilog -o float2int float2int.v test_float2int.v
	vvp float2int
	gtkwave float2int.vcd
int2float:
	iverilog -o int2float int2float.v test_int2float.v
	vvp int2float
	gtkwave int2float.vcd
clean:
	rm float2int float2int.vcd int2float int2float.vcd