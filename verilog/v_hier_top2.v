// $Id: v_hier_top2.v 35110 2007-04-02 13:36:24Z wsnyder $
// DESCRIPTION: Verilog-Perl: Example Verilog for testing package
// This file ONLY is placed into the Public Domain, for any use,
// without warranty, 2000-2007 by Wilson Snyder.

module v_hier_top2 (/*AUTOARG*/
   // Inputs
   clk
   );
   input clk;

   v_hier_noport noport ();

endmodule
