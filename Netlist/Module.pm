# Verilog - Verilog Perl Interface
# $Id: Module.pm,v 1.8 2002/05/03 13:55:00 wsnyder Exp $
# Author: Wilson Snyder <wsnyder@wsnyder.org>
######################################################################
#
# This program is Copyright 2000 by Wilson Snyder.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of either the GNU General Public License or the
# Perl Artistic License, with the exception that it cannot be placed
# on a CD-ROM or similar media for commercial distribution without the
# prior approval of the author.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# If you do not have a copy of the GNU General Public License write to
# the Free Software Foundation, Inc., 675 Mass Ave, Cambridge, 
# MA 02139, USA.
######################################################################

package Verilog::Netlist::Module;
use Class::Struct;

use Verilog::Netlist;
use Verilog::Netlist::Port;
use Verilog::Netlist::Net;
use Verilog::Netlist::Cell;
use Verilog::Netlist::Pin;
use Verilog::Netlist::Subclass;
@ISA = qw(Verilog::Netlist::Module::Struct
	Verilog::Netlist::Subclass);
$VERSION = '2.200';
use strict;

structs('new',
	'Verilog::Netlist::Module::Struct'
	=>[name     	=> '$', #'	# Name of the module
	   filename 	=> '$', #'	# Filename this came from
	   lineno	=> '$', #'	# Linenumber this came from
	   netlist	=> '$', #'	# Netlist is a member of
	   userdata	=> '%',		# User information
	   #
	   ports	=> '%',		# hash of Verilog::Netlist::Ports
	   nets		=> '%',		# hash of Verilog::Netlist::Nets
	   cells	=> '%',		# hash of Verilog::Netlist::Cells
	   _celldecls	=> '%',		# hash of declared cells (for autocell only)
	   _cellarray	=> '%',		# hash of declared cell widths (for autocell only)
	   is_top	=> '$', #'	# Module is at top of hier (not a child)
	   is_libcell	=> '$', #'	# Module is a library cell
	   # SystemPerl:
	   _autocovers  => '%', #'	# Hash of covers found in code
	   _autosignal	=> '$', #'	# Module has /*AUTOSIGNAL*/ in it
	   _autosubcells=> '$', #'	# Module has /*AUTOSUBCELL_DECL*/ in it
	   _autotrace	=> '$', #'	# Module has /*AUTOTRACE*/ in it
	   _autoinoutmod=> '$', #'	# Module has /*AUTOINOUT_MODULE*/ in it
	   _ctor	=> '$', #'	# Module has SC_CTOR in it
	   _code_symbols=> '$', #'	# Hash ref of symbols found in raw code
	   lesswarn     => '$',	#'	# True if some warnings should be disabled
	   ]);

sub modulename_from_filename {
    my $filename = shift;
    (my $module = $filename) =~ s/.*\///;
    $module =~ s/\.[a-z]+$//;
    return $module;
}

sub find_port {
    my $self = shift;
    my $search = shift;
    return $self->ports->{$search};
}
sub find_cell {
    my $self = shift;
    my $search = shift;
    return $self->cells->{$search};
}
sub find_net {
    my $self = shift;
    my $search = shift;
    my $rtn = $self->nets->{$search}||"";
    #print "FINDNET ",$self->name, " SS $search  $rtn\n";
    return $self->nets->{$search};
}

sub nets_sorted {
    my $self = shift;
    return (sort {$a->name() cmp $b->name()} (values %{$self->nets}));
}
sub ports_sorted {
    my $self = shift;
    return (sort {$a->name() cmp $b->name()} (values %{$self->ports}));
}
sub cells_sorted {
    my $self = shift;
    return (sort {$a->name() cmp $b->name()} (values %{$self->cells}));
}
sub nets_and_ports_sorted {
    my $self = shift;
    my @list = ((values %{$self->nets}), (values %{$self->ports}), );
    my @outlist; my $last = "";
    # Eliminate duplicates
    foreach my $e (sort {$a->name() cmp $b->name()} (@list)) {
	next if $e eq $last;
	push @outlist, $e;
	$last = $e;
    }
    return (@outlist);
}

sub new_net {
    my $self = shift;
    # @_ params
    # Create a new net under this module
    my $netref = new Verilog::Netlist::Net (direction=>'net', @_, module=>$self, );
    $self->nets ($netref->name(), $netref);
    return $netref;
}

sub new_port {
    my $self = shift;
    # @_ params
    # Create a new port under this module
    my $portref = new Verilog::Netlist::Port (@_, module=>$self,);
    $self->ports ($portref->name(), $portref);
    return $portref;
}

sub new_cell {
    my $self = shift;
    # @_ params
    # Create a new cell under this module
    my $cellref = new Verilog::Netlist::Cell (@_, module=>$self,);
    $self->cells ($cellref->name(), $cellref);
    return $cellref;
}

sub link {
    my $self = shift;
    # Ports create nets, so link ports before nets
    foreach my $portref (values %{$self->ports}) {
	$portref->_link();
    }
    foreach my $netref (values %{$self->nets}) {
	$netref->_link();
    }
    foreach my $cellref (values %{$self->cells}) {
	$cellref->_link();
    }
}

sub lint {
    my $self = shift;
    if (!$self->netlist->{skip_pin_interconnect}) {
	foreach my $portref (values %{$self->ports}) {
	    $portref->lint();
	}
	foreach my $netref (values %{$self->nets}) {
	    $netref->lint();
	}
    }
    foreach my $cellref (values %{$self->cells}) {
	$cellref->lint();
    }
}

sub dump {
    my $self = shift;
    my $indent = shift||0;
    my $norecurse = shift;
    print " "x$indent,"Module:",$self->name(),"  File:",$self->filename(),"\n";
    if (!$norecurse) {
	foreach my $portref (values %{$self->ports}) {
	    $portref->dump($indent+2);
	}
	foreach my $netref (values %{$self->nets}) {
	    $netref->dump($indent+2);
	}
	foreach my $cellref (values %{$self->cells}) {
	    $cellref->dump($indent+2);
	}
    }
}

######################################################################
#### Package return
1;
__END__

=pod

=head1 NAME

Verilog::Netlist::Module - Module within a Verilog Netlist

=head1 SYNOPSIS

  use Verilog::Netlist;

  ...
  my $module = $netlist->find_module('modname');
  my $cell = $self->find_cell('name')
  my $port =  $self->find_port('name')
  my $net =  $self->find_net('name')

=head1 DESCRIPTION

Verilog::Netlist creates a module for every file in the design.

=head1 ACCESSORS

=over 4

=item $self->cells

Returns list of references to Verilog::Netlist::Cell in the module.

=item $self->filename

The filename the module was created in.

=item $self->lineno

The line number the module was created on.

=item $self->name

The name of the module.

=item $self->ports

Returns list of references to Verilog::Netlist::Port in the module.

=item $self->nets

Returns list of references to Verilog::Netlist::Net in the module.

=back

=head1 MEMBER FUNCTIONS

=over 4

=item $self->autos

Updates the AUTOs for the module.

=item $self->find_cell($name)

Returns Verilog::Netlist::Cell matching given name.

=item $self->find_port($name)

Returns Verilog::Netlist::Port matching given name.

=item $self->find_net($name)

Returns Verilog::Netlist::Net matching given name.

=item $self->lint

Checks the module for errors.

=item $self->link

Creates interconnections between this module and other modules.

=item $self->new_cell

Creates a new Verilog::Netlist::Cell.

=item $self->new_port

Creates a new Verilog::Netlist::Port.

=item $self->new_net

Creates a new Verilog::Netlist::Net.

=item $self->dump

Prints debugging information for this module.

=back

=head1 SEE ALSO

L<Verilog::Netlist>

=head1 AUTHORS

Wilson Snyder <wsnyder@wsnyder.org>

=cut