module shifter #(parameter SIZE = 32, parameter shift_size = 9)(in, shamt, dir, out);
    input wire [SIZE-1:0] in;
    input wire [shift_size - 1:0] shamt; 
    input wire dir; // 1 for right, 0 for left
    output wire [SIZE-1:0] out;

    assign out = dir ? (in >> shamt) : (in << shamt);
endmodule
