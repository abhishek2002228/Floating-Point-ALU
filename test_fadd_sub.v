module test_fadd_sub();
    reg [31:0] in1, in2;
    reg op;
    wire [31:0] out;
    wire overflow;
 
    fadd_sub f1(in1, in2, op, out, overflow);

    initial begin
        in1 = 32'h3c600011;
        in2 = 32'hbe820000;
        op = 1'b0;

        #10

        in1 = 32'h007fffff;
        in2 = 32'h007fffff;
        
        #10

        op = 1'b1;
        in1 = 32'h00c00000;
        in2 = 32'h00400000;

        #10

        in1 = 32'h00c00000;
        in2 = 32'h00800000;

        #10

        op = 1'b0;
        in1 = 32'h7f800000;
        in2 = 32'h7f800000;

        #10

        op = 1'b1;

        #10

        op = 1'b0;
        in1 = 32'h7f7fffff;
        in2 = 32'h7f7fffff;

        #10

        op = 1'b1;

        #20
        
        $finish;
    end

    initial begin
        $dumpfile("fadd_sub.vcd");
		$dumpvars(0,test_fadd_sub);
    end
endmodule