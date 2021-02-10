module cpu (
    input clk, 
    input reset,
    output [31:0] iaddr,
    input [31:0] idata,
    output [31:0] daddr,
    input [31:0] drdata,
    output [31:0] dwdata,
    output [3:0] dwe
);
    //Given input/outputs
    reg [31:0] iaddr;   

    //Standard parts in idata
    wire [11:0] immediate;  
    wire [6:0] opcode;
    wire [2:0] func3;
    wire [4:0] rs1, rs2, rd;

    //CPU specific variables
    reg [4:0] opflag;

    //ALU specific variables
    wire [31:0] alu_in1, alu_in2, alu_out;  
    reg [5:0] alu_opcode;   
    wire [11:0] alu_imm; 

    //Load/Store specific variables
    wire [11:0] s_offset, offset;
    wire [31:0] mem_addr;

    //Buffers for bytes/half-words
    wire [31:0] buff_in;
    reg [31:0]  buff_out;

    //32 32-bit registers in memory
    reg [31:0] memory [31:0]; 
    integer i;

    alu32 i1(
        .op(alu_opcode),
        .rv1(alu_in1),  
        .rv2(alu_in2),
        .rvout(alu_out)
    );


    //preset internal registers to 0
    initial begin
        for(i=0; i<32; i=i+1) begin
            memory[i] <= 32'b0;
        end
        opflag = 0;
        alu_opcode = 0;
    end

    /*--------------------------------------------------------------------------------------------------------------------*/

    //Program Counter
    always @(posedge clk) begin
        if (reset) begin
            iaddr <= 0;
        end else begin 
            iaddr <= iaddr + 4;    //Doesn't handle branching ops. So, always inc pc(iaddr) by 4
        end
        memory[0] <= 0;
    end

    /*--------------------------------------------------------------------------------------------------------------------*/

    //Decoding instruction
    assign immediate = idata[31:20]; //Immediate value
    assign rs2 = idata[24:20];       //Source register 2
    assign rs1 = idata[19:15];       //Source register 1
    assign func3 = idata[14:12];     //Sub func code
    assign rd = idata[11:7];         //Destination register
    assign opcode = idata[6:0];      //Opcode

    always @(opcode) begin
        case (opcode[6:0])
            7'b0110011:   opflag = 1;   //ALU_ops_reg
            7'b0010011:   opflag = 2;   //ALU_ops_imm
            7'b1100011:   opflag = 3;   //Branch_ops 
            7'b0110111:   opflag = 4;   //LUI
            7'b0010111:   opflag = 5;   //AUIPC
            7'b1101111:   opflag = 6;   //JAL
            7'b1100111:   opflag = 7;   //JALR
            7'b0000011:   opflag = 8;   //Load_ops
            7'b0100011:   opflag = 9;   //Store_ops
            default:      opflag = 0;   //Invalid
        endcase
    end

    /*--------------------------------------------------------------------------------------------------------------------*/

    //ALU
    assign alu_imm = (func3[1:0] == 2'b01) ? {7'b0,rs2} : immediate;
    assign alu_in1 = memory[rs1];
    assign alu_in2 = (opflag === 2) ? {{20{alu_imm[11]}},alu_imm} : memory[rs2];

    always @(*) begin
        casez ({opcode[5],idata[30],func3})
            5'b0?000 : alu_opcode = 1;      //ADD
            5'b10000 : alu_opcode = 1;      //ADD
            5'b11000 : alu_opcode = 2;      //SUB
            5'b??111 : alu_opcode = 3;      //AND
            5'b??110 : alu_opcode = 4;      //OR
            5'b??100 : alu_opcode = 5;      //XOR
            5'b??010 : alu_opcode = 6;      //SLT
            5'b??011 : alu_opcode = 7;      //SLTU
            5'b??001 : alu_opcode = 8;      //SLL
            5'b?0101 : alu_opcode = 9;      //SRL
            5'b?1101 : alu_opcode = 10;     //SRA
            default  : alu_opcode = 0;      //undefined
        endcase
    end

    /*--------------------------------------------------------------------------------------------------------------------*/

    //Load/Store
    assign s_offset = {idata[31:25],idata[11:7]};             //offset for store ops
    assign offset = (opflag === 8) ? immediate : s_offset;    //actual offset
    assign daddr = {{20{offset[11]}},offset} + memory[rs1];   //addr for dmem
    assign mem_addr = (opflag === 8) ? rd : rs2;              //addr for internal registers

    //Handling mis-aligned address cases with a buffer
    assign buff_in = (opflag == 9) ? memory[mem_addr] :
                      (daddr[1:0] == 2'b00) ? drdata :
                      (daddr[1:0] == 2'b01) ? (drdata >> 8) :
                      (daddr[1:0] == 2'b10) ? (drdata >> 16) :
                      (daddr[1:0] == 2'b11) ? (drdata >>24) : 0;

    always @(buff_in) begin
        case (func3)
            3'b000:   buff_out <= {{24{buff_in[7]}},buff_in[7:0]};      //Byte
            3'b001:   buff_out <= {{16{buff_in[15]}},buff_in[15:0]};    //Half-Word
            3'b010:   buff_out <= buff_in;                              //Word
            3'b100:   buff_out <= {24'b0,buff_in[7:0]};                 //Byte-Unsigned
            3'b101:   buff_out <= {16'b0,buff_in[15:0]};                //Half-Word-Unsigned
            default:  buff_out <= 32'b0;
        endcase             
    end

    //data value for dmem and write enable
    assign dwdata = (daddr[1:0] == 2'b00) ? buff_out :
                    (daddr[1:0] == 2'b01) ? (buff_out << 8) :
                    (daddr[1:0] == 2'b10) ? (buff_out << 16) : 
                    (daddr[1:0] == 2'b11) ? (buff_out << 24) : 0;
    
    assign dwe = (opflag !== 9) ? 0 :
                 (func3 == 3'b000 | func3 == 3'b100) ? {daddr[1] & daddr[0], daddr[1] & !daddr[0], !daddr[1] & daddr[0],!daddr[1] & !daddr[0]} : 
                 (func3 == 3'b001 | func3 == 3'b101) ? {daddr[1], daddr[1], !daddr[1], !daddr[1]} :
                 (func3 == 3'b010) ? 4'b1111 : 4'b0000;

    /*--------------------------------------------------------------------------------------------------------------------*/
    
    //Updating internal registers
    always @(idata) begin
        case(opflag)
            5'd1:   memory[rd] <= alu_out;         //ALU_ops_reg
            5'd2:   memory[rd] <= alu_out;         //ALU_ops_imm
            5'd8:   memory[mem_addr] <= buff_out;  //Load_ops                     
        endcase
    end

endmodule
