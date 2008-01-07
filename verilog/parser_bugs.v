// Not legal:
// end : ADDRESS_TEST_BLOCK             // See 9.8.1
// `define at EOF with no newline

module bug26141 ();
   wire [0:3] b;
   wire a = b[2];
endmodule

module bug26940 ();
   (* attribute *)
   assign q = {1'b0,a} +{1'b0,b};

   adder u_add (.q(q),.a(d),.b(d));
   initial begin
      # 1;
      q=0;
      if (q!=0) $stop;
   end
endmodule

module bug26968 ();
   reg [4:0]  vect = 5'b10100;
   wire [4:0] tmp = { vect[0], vect[1], vect[2], vect[3], vect[4] };
   initial begin
      #1 $display("vect=%b, tmp=%b", vect, tmp);
   end
endmodule

module bug26969 (input [31:0] ad, output [15:0] regff, input [31:0] read);
   bufif0 ad_drv [31:0] (ad, {16'b0, regff}, read);
endmodule

module bug26970;
   // Copyright (c) 2002 Stephen Williams (steve@icarus.com)
   // GNU Licensed
   parameter   SET  = 1'b1,
		 CLR  = 1'b0,
		 S1   = 2'd1,
		 HINC = 3'd4;
   parameter   
     x = {S1,CLR,CLR,CLR,CLR,SET,SET,CLR,CLR,HINC };
endmodule

module bug26997;
   MUX_REG_8x8 PAGE_REG_B3 (
			    .CLK	(CLK),
			    /*
			     .IN	(DATA_RES[31:24]),
			     .OUT	(PAGE[31:24]),
			     .EN_IN	(EN_B3),
			     .EN_OUT	(PAGE_SEL),
			     */
			    .TC	(),
			    .TD	(),
			    .TQ	());
endmodule

module bug27009();
   // Copyright (c) 2002 Stephen Williams (steve@icarus.com)
   // GNU Licensed
   reg pullval;
   wire (weak0, weak1) value = pullval;
   //Legal?: buf (highz0, strong1) drive0(value, en0);
   //Legal?: not (strong0, highz1) drive1(value, en1);
endmodule // main


module bug27010;
   // Copyright (c) 2000 Yasuhisa Kato <ykato@mac.com>
   // GNU Licensed
   initial begin clk = 0 ; forever #5 clk = ~clk ; end
   drvz N ( clk, b, ~c, s ) ; // line(A)
endmodule

module bug27013;
   submod u1(0);
   submod u2(1);
endmodule

module bug27036;
   reg [2:0]  a_fifo_cam_indices[3:0], lt_fifo_cam_indices[5:0];
   wire [2:0] db0_a_fifo_cam_indices = a_fifo_cam_indices[0];
endmodule

module bug27037;
   reg mem[12:2];
   reg [7:0] i;
endmodule

module bug27039;
   integer i;
endmodule

module bug27045(
    input clk, input reset,
    input [7:0] d,
    output reg [7:0] q );
   parameter 	     REG_DELAY = 0;
   always @(posedge clk or posedge reset)
     q <= #(REG_DELAY*2) d;
endmodule

module bug27062 (input D, output Q);
   p(Q, D);
endmodule

`timescale 1ns/1ns

module bug27066;
   integer i;
   time    t;
   realtime rt;
   function integer toint;
      input integer y;
      input [15:0] x;
      toint = x|y;
   endfunction
endmodule

module bug27067;
    initial $monitor( "%T %b %b %b", $time, clk1, clko1, clko2 );
    initial forever @( negedge clk1 ) dclk1ff <= #50 ~ dclk1ff;
endmodule

module bug27072(
    output reg sum,
    input wire ci);
endmodule

`resetall
module spec;
   specify
      specparam
	Tac = 0.1,
	Tcs = 0.2;
      if ( !B & !M )
	( posedge CLK => (  Q[0] : 1'bx )) = ( Tac, Tcs );
      $width (negedge CLK &&& EN, Tac, 0, notif_clk);
      ( in1 => q ) = (3, 4);
      ( in1 +=> q ) = Tac;
      ( a, b, c *> q1, q2) = 10;
      ( s +*> q ) = Tcs;
   endspecify
endmodule

module bugevent;
   event e;
   initial ->e;
   always @ (e && e) $write("Legal\n");
endmodule

module bugio (input [31:0] a, a2, output [15:0] o, o2, input ibit);
endmodule

module buglocal;
   always #(cyclehalf) begin
      clk <= ~clk;
   end
   always @(*) begin end
   initial force flag = 0;
   initial #(delta+0.5) CLRN <= 1;
   assign (weak0,weak1) VDD=1'b0;
   assign (weak0,weak1) VSS=1'b1;
   wire [71:0] #1 xxout = xxin;
   initial #1000_000 $finish;
   initial $display($time,,"Double commas are stupid");
   initial for (counter[3:0] = 4'h0; counter[3:0] < limit[3:0];
		counter[3:0] = counter[3:0] + 4'h1) $write();
   always @(posedge(clk && !xclk) or negedge(clk && xclk) or reset) $write();

   nmos   # (PullTime, PullTime, 0) (PT,PU,1'b1);
   pulldown (strong0) pullinst (r);

   defparam x.y.z.PAR = 1;

   cdrv #5.0 clk(clk);

   initial PI = 3.1415926535_8979323846;

   always val = @ eventid 1'h1;

   always dly = # (2:3:4) 5'h6 ;

   wire     \33escapeneeded = 1'b1;
   wire     \33escapenewlineend
	    = 1'b1;
   wire     \noescapenewlineend
	    = 1'b1;
   wire     \noescapespaceend = 1'b1;

endmodule

module v2kparam
  #(parameter WIDTH = 1,
    parameter LENGTH = 1, LENGTH2 = 1)
   (output [WIDTH-1:0] myout,
    input  [LENGTH-1:0] myin, myinb
    );
   assign myout = myin ^ myinb ^ $callemptyparens();
endmodule

module foreqn (in);
   input [1:0] in;
   reg        a,b;
   reg [1:0]  c;
   always for ({a,c[0]} = in; a < 1'b1; {b,c[1]} = in) begin
   end
   always for ({a,c[in]} = 0; a < 1'b1; {b,c[in]} = 2'b10) begin
   end
endmodule

module colonslash;
   always @*
     case (cond&4'b1110)
       'h0://Error
	 t = 7;
       'h2:/*Another comment*/
	     t = 6;
       'h4: t = 5;
     endcase
endmodule
