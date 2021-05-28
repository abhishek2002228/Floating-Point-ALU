module test_int2float();
    reg [31:0] int;
    wire [31:0] float;
    wire precision_lost;

    int2float i1(int, float, precision_lost);

    initial begin
        int = 32'd10;
        #5
        int = 32'd8;
        #5
        int = 32'd0;
        #5
        $finish;
    end

    initial begin
        $dumpfile("int2float.vcd");
		$dumpvars(0,test_int2float);
    end
endmodule