`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.06.2024 15:47:55
// Design Name: 
// Module Name: frame_counter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module frame_counter
   #(parameter HMAX = 640,  // max horizontal count
               VMAX = 480    // max vertical count
   )       
   (
    input   clk,
    input   reset,
    input   inc,
    
    output [10:0]  hcount,
    output  [10:0]  vcount,
    output  frame_start,
    output  frame_end
   );

   // signal declaration
   reg [10:0] hc_reg, hc_next;
   reg [10:0] vc_reg, vc_next;

   // body
   // horizontal and vertical pixel counters 
   // register
   always @(posedge clk, posedge reset)
      if (reset) begin
         vc_reg <= 0;
         hc_reg <= 0;
      end  
      else begin 
         vc_reg <= vc_next;
         hc_reg <= hc_next;
      end
      
   // next-state logic of horizontal counter
   always @*
      if (inc) 
         if (hc_reg == (HMAX - 1))
            hc_next = 0;
         else
            hc_next = hc_reg + 1;
      else
         hc_next = hc_reg;
   
   // next-state logic of vertical counter
   always @*
      if (inc && (hc_reg == (HMAX - 1)))
         if (vc_reg == (VMAX - 1))
            vc_next = 0;
         else
            vc_next = vc_reg + 1;
      else
         vc_next = vc_reg;
   // output
   assign hcount = hc_reg;
   assign vcount = vc_reg;
   assign frame_start = vc_reg==0 && hc_reg==0;
   assign frame_end = vc_reg==(VMAX-1) && hc_reg==(HMAX-1);
endmodule