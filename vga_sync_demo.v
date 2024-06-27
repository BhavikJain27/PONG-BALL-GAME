`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.06.2024 15:46:05
// Design Name: 
// Module Name: vga_sync_demo
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


module vga_sync_demo 
   #(parameter CD= 12)    // color depth
   (
    input   clk, reset,
    // stream input
    input  [CD-1:0] vga_si_rgb,
    // to vga monitor
    output  hsync, vsync,
    output [CD-1:0] rgb,
    // frame counter output
    output [10:0] hc, vc
   );

   // localparam declaration
   // vga 640-by-480 sync parameters
   localparam HD = 640;  // horizontal display area
   localparam HF = 16;   // h. front porch
   localparam HB = 48;   // h. back porch
   localparam HR = 96;   // h. retrace
   localparam HT = HD+HF+HB+HR; // horizontal total (800)
   localparam VD = 480;  // vertical display area
   localparam VF = 10;   // v. front porch
   localparam VB = 33;   // v. back porch
   localparam VR = 2;    // v. retrace
   localparam VT = VD+VF+VB+VR; // vertical total (525)
   // signal delaration
   reg [1:0] q_reg;
   wire tick_25M;
   wire[10:0] x, y;
   wire hsync_i, vsync_i, video_on_i;
   reg hsync_reg, vsync_reg;  
   reg [CD-1:0] rgb_reg;  

   // body 
   // mod-4 counter to generate 25M-Hz tick
   always @(posedge clk)
      q_reg <= q_reg + 1;
   assign tick_25M = (q_reg == 2'b11) ? 1 : 0;
   // instantiate frame counter
   frame_counter #(.HMAX(HT), .VMAX(VT)) frame_unit
      (.clk(clk), .reset(reset), .hcount(x), .vcount(y), .inc(tick_25M), 
       .frame_start(), .frame_end());
   // horizontal sync decoding
   assign hsync_i = ((x>=(HD+HF)) && (x<=(HD+HF+HR-1))) ? 0 : 1;
   // vertical sync decoding
   assign vsync_i = ((y>=(VD+VF)) && (y<=(VD+VF+VR-1))) ? 0 : 1;
   // display on/off
   assign video_on_i = ((x < HD) && (y < VD)) ? 1: 0;
   // buffered output to vga monitor
   always @(posedge clk) begin
      vsync_reg <= vsync_i;
      hsync_reg <= hsync_i;
      if (video_on_i)
         rgb_reg <= vga_si_rgb;
      else
         rgb_reg <= 0;    // black when display off 
   end
   // output 
   assign hsync = hsync_reg;
   assign vsync = vsync_reg;
   assign rgb = rgb_reg;
   assign hc = x;
   assign vc = y;
endmodule