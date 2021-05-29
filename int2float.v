`include "leading_one_detector.v"
`include "encoder.v"
`include "shifter.v"
module int2float(int, float, precision_lost);
    input wire [31:0] int;
    output wire [31:0] float;
    output wire precision_lost;

    wire [31:0] lod1, shifted_int;
    wire [4:0] lod1_enc;
    wire [4:0] shamt;
    wire [7:0] exponent;
    wire [22:0] mantissa;
    wire sign;

    assign shamt = 5'd31 - lod1_enc;

    lod #(32) l1(int, lod1);
    encoder e1(lod1, lod1_enc);
    shifter #(32, 5) s1(int, shamt, 1'b0, shifted_int);

    assign exponent = 8'd127 + 8'd31 - {3'd0, shamt[4:0]};
    assign mantissa = shifted_int[30:8];
    assign sign = int[31];

    assign precision_lost = (~|int) ? 1'b0 : |shifted_int[7:0];
    assign float = (~|int) ? 32'd0 : {sign, exponent, mantissa};
endmodule