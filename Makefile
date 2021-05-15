float2int:
	iverilog -o float2int float2int.v test_float2int.v
	vvp float2int
	gtkwave float2int.vcd
clean:
	rm float2int
	rm float2int.vcd
