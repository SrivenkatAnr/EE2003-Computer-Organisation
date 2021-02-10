module regfile(
    input [4:0] rs1,     // address of first operand to read - 5 bits
    input [4:0] rs2,     // address of second operand
    input [4:0] rd,      // address of value to write
    input we,            // should write update occur
    input [31:0] wdata,  // value to be written
    output [31:0] rv1,   // First read value
    output [31:0] rv2,   // Second read value
    input clk            // Clock signal - all changes at clock posedge
);
    // Desired function
    // rv1, rv2 are combinational outputs - they will update whenever rs1, rs2 change
    // on clock edge, if we=1, regfile entry for rd will be updated

    reg [31:0] memory [31:0]; // 32 32-bit registers in memory
    reg reset;
    integer i;

    assign rv1 = memory[rs1];   //value in register 1 
    assign rv2 = memory[rs2];   //value in register 2

    initial begin
        #0 reset = 1;
        #1 reset = 0;
    end

    always @(posedge clk) begin
        if (reset) begin
            for(i=0; i<32; i=i+1) begin
                memory[i] = 32'b0;
            end
        end

        else if (we) begin
            memory[rd] <= wdata;
        end
    end


endmodule
