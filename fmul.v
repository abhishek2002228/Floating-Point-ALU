`include "denormal.v"
`include "mul.v"
module fmul(in1, in2, out, overflow, underflow);
    input wire [31:0] in1;
    input wire [31:0] in2;
    output wire [31:0] out;
    output wire overflow;
    output wire underflow;

    //extracting fields
    wire [7:0] exp1, exp2;
    wire [22:0] man1, man2;
    wire sign1, sign2;

    assign sign1 = in1[31];
    assign sign2 = in2[31];
    assign exp1 = in1[30:23];
    assign exp2 = in2[30:23];
    assign man1 = in1[22:0];
    assign man2 = in2[22:0];

    //forming significands
    wire hidden1, hidden2, denormal1, denormal2, in1_isZero, in2_isZero;
    wire sign, man1_isZero, man2_isZero;
    wire [23:0] significand1_1, significand2_1;
    wire [47:0] mul1;
    wire [9:0] expout1; // 10 bits becauase range between -125 to 384 : 2^(N-1) >= 384

    assign hidden1 = |exp1;
    assign hidden2 = |exp2;
    assign significand1_1 = {hidden1, man1};
    assign significand2_1 = {hidden2, man2};
    assign man1_isZero = ~|man1;
    assign man2_isZero = ~|man2;
    assign in1_isZero = (~hidden1) & man1_isZero;
    assign in2_isZero = (~hidden2) & man2_isZero;
    assign expout1 = {2'b00,exp1} + {2'b00,exp2} - 10'd127 + {9'd0,~hidden1} + {9'd0,~hidden2};

    denormal d1(exp1, man1, denormal1);
    denormal d2(exp2, man2, denormal2);

    assign sign = sign1 ^ sign2;

    mul #(24) m1(significand1_1, significand2_1, mul1);

    //alternate and better logic for leading one detector and encoder combined
    wire [46:0] z5, z4, z3, z2, z_1, z_0; // x.xxxxxxxxxxxxxxxxxxxxxxxxxx...
    wire [5:0] zeros;

    assign zeros[5] = ~|mul1[46:15];
    assign z5 = zeros[5]? {mul1[14:0],32'h0} : mul1[46:0];
    assign zeros[4] = ~|z5[46:31];
    assign z4 = zeros[4]? {z5[30:0], 16'h0} : z5;
    assign zeros[3] = ~|z4[46:39];
    assign z3 = zeros[3]? {z4[38:0], 8'h0} : z4;
    assign zeros[2] = ~|z3[46:43];
    assign z2 = zeros[2]? {z3[42:0], 4'h0} : z3;
    assign zeros[1] = ~|z2[46:45];
    assign z_1 = zeros[1]? {z2[44:0], 2'b00} : z2;
    assign zeros[0] = ~z_1[46];
    assign z_0 = zeros[0]? {z_1[45:0], 1'b0} : z_1; 

    reg [46:0] frac_notRounded;
    reg [9:0] exp_notRounded;

    always @(*)
    begin
        if(mul1[47])//1x.xxxx... case
        begin
            frac_notRounded = {mul1[47:2],mul1[1]|mul1[0]}; //play with this and check accuracy
            exp_notRounded = expout1 + 10'd1; //shifted right so increase exponent
        end
        else
        begin // ($signed(expout1) > zeros) && (z_0[46]) not working
            if(!expout1[9] && (expout1[8:0] > zeros) && (z_0[46])) // 0x.xxxx.. result can be written as 1.xx.. * 2^(expout1 - zeros - 127)
            begin                                      // $signed(expout1) > zeros is violated if normal * zero
                frac_notRounded = z_0;                  // Therefore z0[46] ensures that mul1 is not 0 
                exp_notRounded = expout1 - zeros;                               
            end
            else   //result is denormal : normal * denormal -> denormal (when $signed(expout1) <= zeros)
            begin  //denormal * denormal -> denormal (always), normal * normal -> denormal (when expout1 <= 0) (handled by $signed(expout1) > zero's)
                exp_notRounded = 0;
                //$signed(expout1) > 0 is not working 
                if(!expout1[9] && (expout1 != 0)) //(this is only possible in the normal * denormal case)
                begin
                    frac_notRounded = mul1[46:0] << (expout1 - 1) ; // (expout1 - 1) - 126
                end
                else //posssible in denormal * denormal , normal * denormal, normal * normal  
                begin //negative or 0, shift right by 1 if 0
                    frac_notRounded = mul1[46:0] >> (10'h1 - expout1) ; // -(1 - expout1) - 126 // adjust to make exponent -126 
                end
            end                                           
        end
    end

    wire [2:0] grs;
    wire round;
    wire [26:0] frac_grs; //24 + 3
    wire [24:0] fracRounded, fracRoundAdjusted;
    wire [9:0] expRounded;

    assign grs = {frac_notRounded[22:21],|frac_notRounded[20:0]}; //46-24+1 = 23
    assign frac_grs = {frac_notRounded[46:23],grs};
    assign round = (grs[2] && (|grs[1:0])) ? 1'b1 : (grs[2]) ? ~(1'b1 ^ frac_notRounded[23]) : 1'b0 ;
    assign fracRounded = round ? {1'b0, frac_grs[26:3]} + 1 : {1'b0,frac_grs[26:3]};
    assign fracRoundAdjusted = fracRounded[24] ? {1'b0,fracRounded[24:1]} : fracRounded ; 
    assign expRounded = fracRounded[24] ? exp_notRounded + 1 : exp_notRounded;
    assign overflow = (exp_notRounded >= 10'h0ff) || (expRounded >= 10'h0ff);

    wire exp1_isFF, exp2_isFF;
    wire in1_isInf, in2_isInf, in1_isNaN, in2_isNaN, out_isInfUsed;
    reg out_isInf, out_isNaN;

    assign exp1_isFF = &exp1;
    assign exp2_isFF = &exp2;
    assign in1_isInf = exp1_isFF && man1_isZero;
    assign in2_isInf = exp2_isFF && man2_isZero;
    assign in1_isNaN = exp1_isFF && (~man1_isZero);
    assign in2_isNaN = exp2_isFF && (~man2_isZero);

    always @(*)
    begin
        if(in1_isInf)
        begin
            if(in2_isInf)
            begin
               out_isInf = 1'b1;
               out_isNaN = 1'b0;
            end
            else
            begin
                out_isNaN = (in2_isNaN | in2_isZero);
                out_isInf = ~(in2_isNaN | in2_isZero);
            end
        end
        else
        begin
            if(in2_isInf)
            begin
                out_isInf = ~(in1_isNaN | in1_isZero);
                out_isNaN = (in1_isNaN | in1_isZero);
            end
            else
            begin
                out_isNaN = in1_isNaN | in2_isNaN;
                out_isInf = 1'b0;
            end 
        end
    end

    assign out_isInfUsed = out_isInf | overflow;
    
    wire [7:0] expUsed;
    wire [22:0] fracUsed;
    assign expUsed = (out_isInfUsed | out_isNaN) ? (8'hFF) : expRounded;
    assign fracUsed = (out_isInfUsed) ? 23'd0 : fracRoundAdjusted;
    assign outisZero = (~|expUsed) & (~|fracUsed);

    assign out = {sign, expUsed, fracUsed};
    assign underflow = (~in1_isZero)&(~in2_isZero)&(outisZero);
endmodule