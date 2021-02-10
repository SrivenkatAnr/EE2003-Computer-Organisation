`timescale 1ns/1ps
`define OUTFILE "output.txt"

module outperiph (
    input clk,
    input reset,
    input [31:0] daddr,
    input [31:0] dwdata,
    input [3:0] dwe,
    output [31:0] drdata
);

    reg [31:0] drdata;
    integer out_file;
    
    // Implement the peripheral logic here: use $fwrite to the file output.txt
    // Use the `define above to open the file so that it can be 
    // overridden later if needed

    // Return value from here (if requested based on address) should
    // be the number of values written so far

    //Preset counter value to 0
    //Open file `OUTFILE for writing data
    initial begin 
        drdata = 0;  
        out_file = $fopen(`OUTFILE,"w");  
    end
    
    always @(posedge clk) begin
        if (reset) begin        //Make counter to 0 whenever reset occurs
            drdata = 0;
        end else begin
            if (dwe) begin      //When dwe on : Sync write of dwdata (char) into `OUTFILE and increment counter
                $fwrite(out_file,"%c",dwdata);
                drdata = drdata + 1;
            end
        end
    end
    
endmodule
