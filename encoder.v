//temporary, not able to figure out how to parametrize it :(

module encoder(in, out);
    input wire [31:0] in;
    output reg [4:0] out;

    always @(*)
        case(in)
        32'h1: out = 5'b00000;
        32'h2: out = 5'b00001;
        32'h4: out = 5'b00010;
        32'h8: out = 5'b00011;
        32'h10: out = 5'b00100;
        32'h20: out = 5'b00101;
        32'h40: out = 5'b00110;
        32'h80: out = 5'b00111;
        32'h100: out = 5'b01000;
        32'h200: out = 5'b01001;
        32'h400: out = 5'b01010;
        32'h800: out = 5'b01011;
        32'h1000: out = 5'b01100;
        32'h2000: out = 5'b01101;
        32'h4000: out = 5'b01110;
        32'h8000: out = 5'b01111;
        32'h10000: out = 5'b10000;
        32'h20000: out = 5'b10001;
        32'h40000: out = 5'b10010;
        32'h80000: out = 5'b10011;
        32'h100000: out = 5'b10100;
        32'h200000: out = 5'b10101;
        32'h400000: out = 5'b10110;
        32'h800000: out = 5'b10111;
        32'h1000000: out = 5'b11000;
        32'h2000000: out = 5'b11001;
        32'h4000000: out = 5'b11010;
        32'h8000000: out = 5'b11011;
        32'h10000000: out = 5'b11100;
        32'h20000000: out = 5'b11101;
        32'h40000000: out = 5'b11110;
        32'h80000000: out = 5'b11111;
        default: out = 5'b00000;
        endcase
endmodule