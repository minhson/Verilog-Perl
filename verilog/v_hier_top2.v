// $Id: v_hier_top2.v 49328 2008-01-07 16:28:25Z wsnyder $
// DESCRIPTION: Verilog-Perl: Example Verilog for testing package
// This file ONLY is placed into the Public Domain, for any use,
// without warranty, 2000-2008 by Wilson Snyder.

module v_hier_top2 (/*AUTOARG*/
   // Inputs
   clk
   );
   input clk;

   v_hier_noport noport ();

endmodule
