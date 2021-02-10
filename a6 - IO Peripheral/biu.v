`timescale 1ns/1ps
// Bus interface unit: assumes two branches of the bus -
// 1. connect to dmem
// 2. connect to a single peripheral
// The BIU needs to know the addresses at which DMEM and peripheral are
// connected, so it can do the required multiplexing. 
// These need to be added as part of your code. 
module biu (
    input clk,
    input reset,
    input [31:0] daddr,
    input [31:0] dwdata,
    input [3:0] dwe,
    output [31:0] drdata,

    //Signals going to/from dmem
    output [31:0] daddr1,
    output [31:0] dwdata1,
    output [3:0]  dwe1,
    input  [31:0] drdata1,

    //Signals going to/from peripheral
    output [31:0] daddr2,
    output [31:0] dwdata2,
    output [3:0]  dwe2,
    input  [31:0] drdata2
);
    
    //DMEM needs 4K locations (16KB memory). So only lower 14 bits (12 for 4K locations, last 2 ignored) of the address bus are used
    //So, map the peripheral to the remaining unallotted memory
    //Use the upper 18 bits of addr bus as select line for peripheral or dmem

    assign drdata = (daddr[31:14] == 0) ?  drdata1 : drdata2;
    assign dwe1 = (daddr[31:14] == 0) ? dwe : 0;
    assign dwe2 = (daddr[31:14] !== 0) ? dwe : 0;

    // Send values to DMEM or peripheral (or both if it does not matter) as required

    assign daddr1 = daddr;
    assign dwdata1 = dwdata;

    assign daddr2 = daddr;
    assign dwdata2 = dwdata;

endmodule
