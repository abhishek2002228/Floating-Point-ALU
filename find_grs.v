module find_grs(in, grs);
    input wire [25:0] in;
    output wire [2:0] grs;

    assign grs = {in[25:24], |in[23:0]};
endmodule