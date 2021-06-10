module mul #(parameter SIZE = 24)(in1, in2, out);
    input wire [SIZE-1:0] in1;
    input wire [SIZE-1:0] in2;
    output wire [(2*SIZE)-1:0] out;

    assign out = in1 * in2; //will change this later to a wallace tree multiplier
endmodule