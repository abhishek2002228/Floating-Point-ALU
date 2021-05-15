module test_float2int();
    reg [31:0] float;
    wire [31:0] int;
    wire precision_lost, invalid, denormal;

    float2int f1(float, int, precision_lost, denormal, invalid);

    initial begin
        float = 32'h40A00000;
        #5
        float = 32'h43010000;
        #5
        float = 32'h42CF224E;
        #5
        $finish;
    end

    initial begin
        $dumpfile("float2int.vcd");
		$dumpvars(0,test_float2int);
    end
endmodule