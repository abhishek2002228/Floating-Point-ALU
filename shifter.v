module shifter(in, shamt, dir, out);
    input wire [55:0] in;
    input wire [8:0] shamt; 
    input wire dir; // 1 for right, 0 for left
    output wire [55:0] out;

    assign out = dir ? (in >> shamt) : (in << shamt);
endmodule
