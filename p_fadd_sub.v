`include "p_align.v"
`include "p_calc.v"
`include "p_norm.v"
`include "p_reg_ac.v"
`include "p_reg_cn.v"
module p_fadd_sub(clk, rst, en, in1, in2, op, out, overflow, underflow);
    input wire clk, rst, en;
    input wire [31:0] in1, in2;
    input wire op; //1 -> sub, 0 -> add
    output wire [31:0] out;
    output wire overflow;
    output wire underflow;

    wire a_op_implied, a_sign, a_denormalA, a_denormalB;
    wire [22:0] a_manA, a_manB;
    wire [7:0] a_expA, a_expB;
    wire [27:0] a_significand_grsA, a_significand_grsB;


    p_align align(in1, in2, op, a_sign, a_denormalA, a_denormalB, a_manA, a_manB, a_expA, a_expB, a_op_implied, a_significand_grsA, a_significand_grsB);

    wire c_op_implied, c_sign, c_denormalA, c_denormalB;
    wire [22:0] c_manA, c_manB;
    wire [7:0] c_expA, c_expB;
    wire [27:0] c_significand_grsA, c_significand_grsB;

    p_reg_ac reg_ac(clk, rst, en, a_op_implied, a_sign, a_denormalA, a_denormalB, a_manA, a_manB, a_expA, a_expB, a_significand_grsA, a_significand_grsB, c_op_implied, c_sign, c_denormalA, c_denormalB, c_manA, c_manB, c_expA, c_expB, c_significand_grsA, c_significand_grsB);

    wire [27:0] c_calc;

    p_calc calc(c_op_implied, c_significand_grsA, c_significand_grsB, c_calc);

    wire n_sign, n_denormalA, n_denormalB, n_op_implied;
    wire [22:0] n_manA, n_manB;
    wire [7:0] n_expA, n_expB;
    wire [27:0] n_calc;

    p_reg_cn reg_cn(clk, rst, en, c_sign, c_denormalA, c_denormalB, c_op_implied, c_manA, c_manB, c_expA, c_expB, c_calc, n_sign, n_denormalA, n_denormalB, n_op_implied, n_manA, n_manB, n_expA, n_expB, n_calc);

    p_norm norm(n_sign, n_denormalA, n_denormalB, n_op_implied, n_manA, n_manB, n_expA, n_expB, n_calc, overflow, underflow, out);
endmodule
