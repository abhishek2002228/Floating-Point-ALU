module p_reg_cn (
    input wire clk, rst, en,
    input wire c_sign, c_denormalA, c_denormalB, c_op_implied,
    input wire [22:0] c_manA, c_manB,
    input wire [7:0] c_expA, c_expB,
    input wire [27:0] c_calc,
    output reg n_sign, n_denormalA, n_denormalB, n_op_implied,
    output reg [22:0] n_manA, n_manB,
    output reg [7:0] n_expA, n_expB,
    output reg [27:0] n_calc
);

    always @(posedge clk, posedge rst)
        begin
            if(rst)
            begin
                n_sign <= 0;
                n_denormalA <= 0;
                n_denormalB <= 0;
                n_op_implied <= 0;
                n_manA <= 0;
                n_manB <= 0;
                n_expA <= 0;
                n_expB <= 0;
                n_calc <= 0;
            end
            else
            begin
                if(en)
                begin
                    n_sign <= c_sign;
                    n_denormalA <= c_denormalA;
                    n_denormalB <= c_denormalB;
                    n_op_implied <= c_op_implied;
                    n_manA <= c_manA;
                    n_manB <= c_manB;
                    n_expA <= c_expA;
                    n_expB <= c_expB;
                    n_calc <= c_calc;            
                end            
            end
        end
    
endmodule