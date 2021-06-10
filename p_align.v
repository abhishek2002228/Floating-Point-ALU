`include "denormal.v"
`include "shifter.v"
`include "find_grs.v"
`include "encoder.v"
`include "leading_one_detector.v"
module p_align(in1, in2, op, sign, denormalA, denormalB, manA, manB, expA, expB, op_implied, significand_grsA, significand_grsB);
    input wire [31:0] in1, in2;
    input wire op; //1 -> sub, 0 -> add
    output wire op_implied, sign, denormalA, denormalB;
    output wire [22:0] manA, manB;
    output wire [7:0] expA, expB;
    output wire [27:0] significand_grsA, significand_grsB;

    wire exchange, signA, signB, hiddenA, hiddenB;
    wire [23:0] significandA1, significandB1;
    wire [7:0] exp_diff, shamt, shamt_used;
    wire [49:0] significandB2;
    wire [2:0] grsB;
    
    
    assign exchange = (in2[30:0] > in1[30:0]); //exchange if |in2| > |in1| , unsigned comparision
    assign signA = exchange ? in2[31] : in1[31];
    assign signB = exchange ? in1[31] : in2[31];
    assign hiddenA = |expA;
    assign hiddenB = |expB;

    assign sign = (~exchange) ? signA : ((~op) ? signA : (~signA)) ;
    assign op_implied = (op) ? ~(signA ^ signB) : (signA ^ signB); //0-> add 1-> sub
    assign expA = exchange ? in2[30:23] : in1[30:23]; //expA is the bigger exp always
    assign expB = exchange ? in1[30:23] : in2[30:23]; //expB is the smaller exp always
    assign manA = exchange ? in2[22:0] : in1[22:0];
    assign manB = exchange ? in1[22:0] : in2[22:0];

    assign significandA1 = {hiddenA, manA};
    assign significandB1 = {hiddenB, manB};
    assign exp_diff = expA - expB;

    denormal d1(expA, manA, denormalA);
    denormal d2(expB, manB, denormalB);

    assign shamt = (denormalB & ~denormalA) ? exp_diff - 8'd1 : exp_diff; //if normal + denormal 
    assign shamt_used = (shamt >= 26)? 8'd26 : shamt;

    shifter #(50, 8) s1({significandB1, 26'd0}, shamt_used, 1'b1, significandB2);
    find_grs f1(significandB2[25:0], grsB);

    assign significand_grsA = {1'b0, significandA1, 3'b000};
    assign significand_grsB = {1'b0, significandB2[49:26], grsB};
endmodule



