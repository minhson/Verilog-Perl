#!/usr/local/bin/perl -w
# $Id: 60_vpm.t,v 1.5 2002/03/20 14:35:56 wsnyder Exp $
# DESCRIPTION: Perl ExtUtils: Type 'make test' to test this package

use strict;
use Test;

BEGIN { plan tests => 4 }
BEGIN { require "t/test_utils.pl"; }

print "Checking vpm...\n";

mkdir 'test_dir', 0777;
chdir 'test_dir';


# Preprocess the files
mkdir ".vpm", 0777;
run_system ("${PERL} ../vpm --nostop --date ../verilog/");
ok(1);
ok(-r '.vpm/pli.v');

my $orig_lines = lines_in("../verilog/example.v");
my $new_lines = lines_in(".vpm/example.v");
print "Line count: $orig_lines =? $new_lines\n";
ok($orig_lines==$new_lines);

# Build the model
unlink "simv";
if (!-r "$ENV{VCS_HOME}/bin/vcs") {
    warn "*** You do not have VCS installed, not running rest of test!\n";
    skip(1,1);
} else {
    run_system (# We use VCS, insert your simulator here
		"$ENV{VCS_HOME}/bin/vcs"
		# vpm uses `pli to point to the hiearchy of the pli module
		." +define+pli=pli"
		# vpm uses `__message_on to point to the message on variable
		." +define+__message_on=pli.message_on"
		# Read files from .vpm BEFORE reading from other directories
		." +librescan +libext+.v -y .vpm"
		# Finally, read the needed top level file
		." .vpm/example.v"
		);
    # Execute the model (VCS is a compiled simulator)
    run_system ("./simv");
    unlink ("./simv");
	
    ok(1);
}

sub lines_in {
    my $filename = shift;
    my $fh = IO::File->new($filename) or die "%Error: $! $filename";
    my @lines = $fh->getlines();
    return $#lines;
}