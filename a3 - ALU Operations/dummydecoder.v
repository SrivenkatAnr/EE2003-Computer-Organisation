module dummydecoder(
    input [31:0] instr,  // Full 32-b instruction
    input  [31:0] r_rv2, // From RegFile
    output [5:0] op,     // some operation encoding of your choice
    output [4:0] rs1,    // First operand
    output [4:0] rs2,    // Second operand
    output [4:0] rd,     // Output reg
    output [31:0] rv2,   // To ALU
    output we            // Write to reg
);
    wire [2:0] func3;
    wire imm_sel;
    wire [11:0] immediate;
    wire [4:0] shamt;
    reg [5:0] opcode;

    assign func3 = instr[14:12];    //sub func code
    assign imm_sel = instr[5];      //flag for immediate ops
    assign shamt = instr[24:20];    //shift amount
    assign op = opcode;

    assign we = 1;      // For only ALU ops, can always set to 1
    // assign we = ({instr[6],instr[4:0]} === 19);  //For checking if arbitrary 7 bit opcode in instr is fine
    
    assign rd = instr[11:7];    //destination register
    assign rs1 = instr[19:15];  //source register 1
    assign rs2 = instr[24:20];  //source register 2

    //check for shift op and then assign immediate value
    assign immediate = (func3[1:0] == 2'b01) ? {{7{1'b0}},shamt} : instr[31:20];

    assign rv2 = imm_sel ? r_rv2 : {{20{immediate[11]}},immediate};
    
    always @(*) begin    // opcode generation
        casez ({imm_sel,instr[30],func3})
            5'b0?000 : opcode = 1;      //ADD
            5'b10000 : opcode = 1;      //ADD
            5'b11000 : opcode = 2;      //SUB
            5'b??111 : opcode = 3;      //AND
            5'b??110 : opcode = 4;      //OR
            5'b??100 : opcode = 5;      //XOR
            5'b??010 : opcode = 6;      //SLT
            5'b??011 : opcode = 7;      //SLTU
            5'b??001 : opcode = 8;      //SLL
            5'b?0101 : opcode = 9;      //SRL
            5'b?1101 : opcode = 10;     //SRA
            default  : opcode = 0;      //undefined
        endcase
    end


endmodule
