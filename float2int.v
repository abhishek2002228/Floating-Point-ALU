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
    assign {borrow, shamt} = 9'd127 + 9'd31 - {1'b0, exponent}; // 127 + 31 - exponent
    /*
    Borrow to check if the expression is negative or positive
    1.negative : too small to represent and the shamt field means nothing
    2.positive : can be represented, shamt field represents the amount to shift right by

    Why 127 + 31 ?
    Integers are limited to [-(2^31), (2^31) - 1]. Max exponent is 127 + 31 for correct representation, in which case 0 bits 
    have to be shifted to the right. 127 + 31 - exponent is supposed to be shifted right for other values.
    */
    denormal d1(exponent, mantissa, denormal); // to check if number is denormal

    /*
        we want to find if precision is reduced, hence we need to keep track of the 
        shifted 24 bits to know that useful information has been shifted out
    */

    wire [55:0] significand, significand_shifted;

    assign significand = {hidden_bit, mantissa, 32'd0}; // hidden bit + 23 frac bits + lower 8'b0 + shifted out 24' digits
    assign shift = ($signed({borrow, shamt}) > 9'd32) ? 9'd32 : {borrow, shamt};
    /*
    Why have we kept the shifted significand 56 bit ? 
    hidden_bit - mantissa - shifted zero's - extra space
    1 bit        23 bits    8 bits           24 bits     = 56 bits
    
    Why 24 bits for the extra space ?
    If all 32 bits are shifted out, the extra space will contain the hidden_bit - mantissa information.
    This is needed to figure out if precision is lost

    If more than 32 bits are shifted out, we restrict the shift amount to 32 bits. Why is that ?
    If 32 or more than 32 bits are shifted out, the answer will anyways be 0 because the exponent is too small 
    but, we need to keep track of precision lost too. The information about precision will be lost if we shift out more than 32 bits
    */
    
    shifter #(56) s1(significand, shift, 1'b1, significand_shifted);
    
    assign int_temp = sign ? (~significand_shifted[55:24] + 32'd1) : significand_shifted[55:24];
    assign p_lost = |significand_shifted[23:0]; //shifted out bits may contain info about frac

    always @(*)
    begin
        if (denormal) //denormal 
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
                    if(sign == 1'b0 && int_temp[31] == 1'b1) // this is addded to account for the case when 
                begin                                        // sign = 0 but exponent = 127 + 31
                        precision_lost = 0;                  // this means 0 bits will be shifted right and msb is 1
                        invalid = 1;                         // Therefore this result is too big for positive numbers
                        int = 32'h80000000;
                    end
                    else
                    begin
                        precision_lost = p_lost;
                        invalid = 0;
                        int = int_temp;
                    end
                end
            end            
        end
    end
endmodule