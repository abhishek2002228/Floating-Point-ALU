module shifter #(parameter SIZE = 32)(in, shamt, dir, out);
    input wire [SIZE-1:0] in;
    input wire [8:0] shamt; 
    input wire dir; // 1 for right, 0 for left
    output wire [SIZE-1:0] out;

    assign out = dir ? (in >> shamt) : (in << shamt);
endmodule
