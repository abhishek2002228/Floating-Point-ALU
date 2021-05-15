module denormal(exponent, mantissa, denormal);
    input wire [7:0] exponent;
    input wire [22:0] mantissa;
    output wire denormal; // 1 if it is denormalized

    assign denormal = (exponent == 8'd0) & ~(mantissa == 23'd0);
endmodule