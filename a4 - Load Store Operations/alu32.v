module alu32(
    input [5:0] op,      // some input encoding of your choice
    input [31:0] rv1,    // First operand
    input [31:0] rv2,    // Second operand
    output [31:0] rvout  // Output value
);
   
    reg [31:0] alu_out;
   
    //Combinational block to compute ALU ops
    assign rvout = alu_out;

    always @(*) begin
        case (op)
            0       :   alu_out = 0;
            1       :   alu_out = rv1 + rv2;                                 //ADD
            2       :   alu_out = rv1 + (~rv2) + 1;                          //SUB
            3       :   alu_out = rv1 & rv2;                                 //AND
            4       :   alu_out = rv1 | rv2;                                 //OR
            5       :   alu_out = rv1 ^ rv2;                                 //XOR
            6       :   alu_out = (rv1 < rv2) ? 1 : 0;                       //SLT
            7       :   alu_out = ($unsigned(rv1) < $unsigned(rv2)) ? 1 : 0; //SLTU
            8       :   alu_out = rv1 << rv2;                                //SLL
            9       :   alu_out = rv1 >> rv2;                                //SRL
            10      :   alu_out = rv1 >>> rv2;                               //SRA                                                 
            default :   alu_out = 1'bx;                                      //Invalid
        endcase
    end

endmodule
