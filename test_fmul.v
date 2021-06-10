module test_fmul();
    reg [31:0] in1, in2;
    wire [31:0] out;
    wire overflow;
    wire underflow;
 
    fmul f1(in1, in2, out, overflow, underflow);

    initial begin
        in1 = 32'h40400000;
        in2 = 32'h40000000;

        #10

        in1 = 32'h440cd99a;
        in2 = 32'h4447a666;

        #10
        
        in1 = 32'h007fffff;
        in2 = 32'h007fffff;
        
        #10

        in1 = 32'h00c00000;
        in2 = 32'h00400000;

        #10

        in1 = 32'h00c00000;
        in2 = 32'h00800000;

        #10

        in1 = 32'h7f800000;
        in2 = 32'h7f800000;

        #10

        in1 = 32'h7f7fffff;
        in2 = 32'h7f7fffff;

        #10
        
        $finish;
    end

    initial begin
        $dumpfile("fmul.vcd");
		$dumpvars(0,test_fmul);
    end
endmodule