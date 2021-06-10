module p_reg_ac (
    input wire clk, rst, en,
    input wire a_op_implied, a_sign, a_denormalA, a_denormalB,
    input wire [22:0] a_manA, a_manB,
    input wire [7:0] a_expA, a_expB,
    input wire [27:0] a_significand_grsA, a_significand_grsB,
    output reg c_op_implied, c_sign, c_denormalA, c_denormalB,
    output reg [22:0] c_manA, c_manB,
    output reg [7:0] c_expA, c_expB,
    output reg [27:0] c_significand_grsA, c_significand_grsB
);

    always @(posedge clk, posedge rst)
    begin
        if(rst)
        begin
            c_op_implied <= 0;
            c_sign <= 0;
            c_manA <= 0;
            c_manB <= 0;
            c_expA <= 0;
            c_expB <= 0;
            c_significand_grsA <= 0;
            c_significand_grsB <= 0;
            c_denormalA <= 0;
            c_denormalB <= 0;
        end
        else
        begin
            if(en)
            begin
                c_op_implied <= a_op_implied;
                c_sign <= a_sign;
                c_manA <= a_manA;
                c_manB <= a_manB;
                c_expA <= a_expA;
                c_expB <= a_expB;
                c_significand_grsA <= a_significand_grsA;
                c_significand_grsB <= a_significand_grsB;   
                c_denormalA <= a_denormalA;
                c_denormalB <= a_denormalB;             
            end            
        end
    end
    
endmodule