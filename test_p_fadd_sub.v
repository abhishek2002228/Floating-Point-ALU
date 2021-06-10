module test_p_fadd_sub();
    reg [31:0] in1, in2;
    reg op;
    reg clk, rst, en;
    wire [31:0] out;
    wire overflow;
    wire underflow;
 
    p_fadd_sub f1(clk, rst, en, in1, in2, op, out, overflow, underflow);

    always #5 clk = ~clk;

    initial begin
        rst = 1'b1;
        clk = 1'b0;
        en = 1'b0;

        #20
        rst = 1'b0;
        en = 1'b1;
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

        #50
        
        $finish;
    end

    initial begin
        $dumpfile("p_fadd_sub.vcd");
		$dumpvars(0,test_p_fadd_sub);
    end
endmodule