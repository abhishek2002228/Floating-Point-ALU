module p_norm (
    input wire sign, denormalA, denormalB, op_implied,
    input wire [22:0] manA, manB,
    input wire [7:0] expA, expB,
    input wire [27:0] calc,
    output wire overflow, underflow,
    output wire [31:0] out
);
    wire [26:0] lod1, adjusted;
    wire [4:0] lod1_enc, adjust;
    wire [7:0] temp_exp;

    lod #(27) l3(calc[26:0], lod1);
    encoder e1({5'b0, lod1}, lod1_enc);

    assign adjust = 5'd26 - lod1_enc;
    assign temp_exp = expA;

    shifter #(27, 5) s2(calc[26:0], adjust, 1'b0, adjusted);

    reg [26:0] frac_notRounded;
    reg [7:0] exp_notRounded;

    always @(*)
    begin
        if(calc[27]) //normal but has to be shifted right
        begin //calc[27] accounts for cases normal + denormal -> 1x.xxxx and normal + normal -> 1x.xxxxx , both cases in which result is normal
            frac_notRounded = {calc[27:2], calc[0]|calc[1]};//play with this and check accuracy
            exp_notRounded = temp_exp + 8'd1;
        end
        else
        begin
            if((temp_exp > adjust) && (adjusted[26]))//normal of the form 0.xxxxx and 1.xxxx
            begin  // twmp_exp > adjust accounts for only normal + normal -> 1.xxxx and normal + denormal -> 1.xxxxx but not denormal + denormal -> 1.xxxxx
                //denormal + denormal cannot form a normal 0.xxxxx, it can form a normal 1.xxxxxxxx
                exp_notRounded = temp_exp - adjust;
                frac_notRounded = adjusted;
            end
            else
            begin
                if(calc[26] && denormalA && denormalB) // calc[26] && denormalA && denormalB takes care of the denormal + denormal -> 1.xxxx case
                begin
                    exp_notRounded = temp_exp + 8'd1;
                    frac_notRounded = adjusted;
                end
                else // for denormal or 0 results
                begin
                    exp_notRounded = 0;
                    if(|temp_exp)//denormal + denormal, denormal + zero, zero + zero
                    begin        //In these cases, no need to shift the significand
                        frac_notRounded = calc[26:0];
                    end
                    else
                    begin //in case of normal + normal or denormal + normal shift left by temp_exp - 1 to make exponent -126
                        frac_notRounded = calc[26:0] << (temp_exp - 8'd1);
                    end
                end
            end
        end           
    end
  
    // frac_notRounded has 1 + 23 + 3 bits
    // 1st bit -> 1 or 0 based on normal / denormal
    // 23 bits -> mantissa
    // 3 bits -> grs for rounding

    wire [2:0] rounding_grs;
    wire round;

    assign rounding_grs = frac_notRounded[2:0];
    assign round = (frac_notRounded[2] && (|frac_notRounded[1:0])) ? 1'b1 : (frac_notRounded[2]) ? ~(1'b1 ^ frac_notRounded[3]) : 1'b0 ;
    //if grs = 100, round such that last digit is 0 (either add or don't add 1 depending on frac_notRounded[3])
    //if grs > 100, round by adding 1  
    //if grs < 100, do nothing

    wire [24:0] fracRounded, fracRoundAdjusted; //25 bits as adding 1 can carry to next bit
    wire [7:0] expRounded;

    assign fracRounded = round ? {1'b0, frac_notRounded[26:3]} + 1 : {1'b0,frac_notRounded[26:3]};
    assign fracRoundAdjusted = fracRounded[24] ? {1'b0,fracRounded[24:1]} : fracRounded ; 
    assign expRounded = fracRounded[24] ? exp_notRounded + 1 : exp_notRounded;
    assign overflow = &expRounded | &exp_notRounded; //overflow if exp before rounding is FF or exp after rounding is FF

    wire AisNaN, BisNaN, AisInf, BisInf, expA_isFF, expB_isFF, manA_isZero, manB_isZero;
    reg outisNaN, outisInf;
    wire outisInf_used, outisZero, A_isZero, B_isZero;

    assign expA_isFF = &expA;
    assign expB_isFF = &expB;
    assign manA_isZero = ~|manA;
    assign manB_isZero = ~|manB;
    assign AisInf = expA_isFF && manA_isZero;
    assign BisInf = expB_isFF && manB_isZero;
    assign AisNaN = expA_isFF && ~manA_isZero;
    assign BisNaN = expB_isFF && ~manB_isZero;
    assign A_isZero = (|expA) & ~denormalA;
    assign B_isZero = (|expB) & ~denormalB;

    always @(*)
    begin
        if(AisInf)
        begin
            if(BisInf)
            begin
               outisInf = ~op_implied;
               outisNaN = op_implied; 
            end
            else
            begin
                outisNaN = BisNaN;
                outisInf = ~BisNaN;
            end
        end
        else
        begin
            if(BisInf)
            begin
                outisInf = ~AisNaN;
                outisNaN = AisNaN;
            end
            else
            begin
                outisNaN = AisNaN | BisNaN;
                outisInf = 1'b0;
            end 
        end
    end

    assign outisInf_used = outisInf | overflow;

    wire [7:0] expUsed;
    wire [22:0] fracUsed;

    assign expUsed = (outisInf_used | outisNaN) ? (8'hFF) : expRounded;
    assign fracUsed = (outisInf_used) ? 23'd0 : fracRoundAdjusted;
    assign outisZero = (~|expUsed) & (~|fracUsed);

    assign out = {sign, expUsed, fracUsed};
    assign underflow = (~A_isZero)&(~B_isZero)&(outisZero);
endmodule