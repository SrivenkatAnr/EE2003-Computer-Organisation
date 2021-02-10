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
            6'd0    :   alu_out = 0;
            6'd1    :   alu_out = rv1 + rv2;                                  //ADD
            6'd2    :   alu_out = rv1 + (~rv2) + 1;                           //SUB
            6'd3    :   alu_out = rv1 & rv2;                                  //AND
            6'd4    :   alu_out = rv1 | rv2;                                  //OR
            6'd5    :   alu_out = rv1 ^ rv2;                                  //XOR
            6'd6    :   alu_out = (rv1 < rv2) ? 1 : 0;                        //SLT  (Set Less Than)
            6'd7    :   alu_out = ($unsigned(rv1) < $unsigned(rv2)) ? 1 : 0;  //SLTU (Set Less Than Unsigned)
            6'd8    :   alu_out = rv1 << rv2;                                 //SLL  (Shift Left Logical)
            6'd9    :   alu_out = rv1 >> rv2;                                 //SRL  (Shift Right Logical)
            6'd10   :   alu_out = rv1 >>> rv2;                                //SRA  (Shift Right Arithmetic)                                            
            default :   alu_out = 1'bx;                                       //Invalid
        endcase
    end

endmodule
