#!/usr/local/bin/perl -w
# $Id: 50_vrename.t,v 1.3 2002/03/11 14:07:22 wsnyder Exp $
# DESCRIPTION: Perl ExtUtils: Type 'make test' to test this package

use strict;
use Test;

BEGIN { plan tests => 4 }
BEGIN { require "t/test_utils.pl"; }

print "Checking vrename...\n";

unlink 'signals.vrename';
run_system ("${PERL} ./vrename -list -xref verilog/test.v");
ok(1);
ok(-r 'signals.vrename');

mkdir 'test_dir', 0777;
mkdir 'test_dir/verilog', 0777;
run_system ("${PERL} ./vrename -change --changefile verilog/test.vrename"
	    ." -o test_dir verilog/test.v");
ok(1);
ok(-r 'test_dir/verilog/test.v');
