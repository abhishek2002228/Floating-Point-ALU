module p_calc(op_implied, significand_grsA, significand_grsB, calc);
    input wire op_implied;
    input wire [27:0] significand_grsA, significand_grsB;
    output wire [27:0] calc;

    assign calc = (op_implied) ? (significand_grsA - significand_grsB) : (significand_grsA + significand_grsB);
endmodule