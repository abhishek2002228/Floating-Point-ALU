`include "denormal.v"
`include "shifter.v"
module float2int(float, int, precision_lost, denormal, invalid);
    input wire [31:0] float;
    output reg [31:0] int;
    output wire denormal;
    output reg precision_lost, invalid;

    wire exp_is_0, frac_is_0, zero, hidden_bit;
    wire [7:0] exponent;
    wire [22:0] mantissa;
    wire sign, borrow;
    wire [7:0] shamt;
    wire [55:0] temp0, temp1;
    wire [8:0] shift;
    wire [31:0] int_temp;
    wire p_lost;

    assign exponent = float[30:23];
    assign mantissa = float[22:0];
    assign sign = float[31];

    assign exp_is_0 = ~(|exponent);
    assign frac_is_0 = ~(|mantissa);
    assign hidden_bit = ~exp_is_0; // hidden bit is 0 if number is 0 or denormalized
    assign zero = exp_is_0 & frac_is_0;
    assign {borrow, shamt} = 9'd158 - {1'b0, exponent}; // 127 + 31 - exponent, borrow to show it is negative


    denormal d1(exponent, mantissa, denormal);

    /*
        we want to find if precision is reduced, hence we need to keep track of the 
        shifted 24 bits to know that useful information has been shifted out
    */

    wire [55:0] significand, significand_shifted;

    assign significand = {hidden_bit, float[22:0], 32'd0}; // hidden bit + 23 frac bits + lower 8'b0 + shifted out 24' digits
    assign shift = ($signed({borrow, shamt}) > 9'd32) ? 9'd32 : {borrow, shamt};
    
    shifter s1(significand, shift, 1'b1, significand_shifted);
    
    assign int_temp = sign ? (~significand_shifted[55:24] + 32'd1) : significand_shifted[55:24];
    assign p_lost = |significand_shifted[23:0];//shifted out bits may contain info about frac

    always @(*)
    begin
        if (denormal)
        begin
            precision_lost = 1; //numbers in the range 2^-126 cant be represented accurately
            invalid = 0;
            int = 32'd0;
        end
        else // normal
        begin
            if(borrow) //exponent too big 
            begin
                precision_lost = 0;
                invalid = 1;
                int = 32'h80000000;
            end
            else
            begin
                if(exponent < 8'd127)
                begin
                    if(zero) precision_lost = 0;
                    else precision_lost = 1;
                    invalid = 0;
                    int = 32'd0;
                end
                else
                begin                    
                    if(p_lost) precision_lost = 1;
                    else precision_lost = 0;
                    invalid = 0;
                    int = int_temp; 
                end
            end            
        end
    end
endmodule