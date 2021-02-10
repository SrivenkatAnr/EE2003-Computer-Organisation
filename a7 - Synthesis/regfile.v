module regfile(
    input [4:0] rs1,     // Source reg 1
    input [4:0] rs2,     // Source reg 2
    input [4:0] rs3,     // Source reg 3
    input [4:0] rd,      // Dest reg
    input we,            // should write update occur
    input [31:0] wdata,  // value to be written
    output [31:0] rv1,   // First read value
    output [31:0] rv2,   // Second read value
    output [31:0] rv3,   // Third read value
    input clk            // Clock signal
);

    reg [31:0] memory [31:0]; // 32 32-bit registers in memory
    integer i;

   //preset internal register values to 0
    initial begin
        for(i=0; i<32; i=i+1) begin
            memory[i] = 32'b0;
        end
    end

    //combinational read block
    assign rv1 = memory[rs1];   //value in register 1 
    assign rv2 = memory[rs2];   //value in register 2
    assign rv3 = memory[rs3];   //value in register 3

    //synchronous write (wrt clk) block
    always @(posedge clk) begin
        if (we & rd !== 0) 
            memory[rd] <= wdata;
    end

endmodule