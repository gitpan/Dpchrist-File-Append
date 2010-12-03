#######################################################################
# $Id: Append.pm,v 1.33 2010-12-03 05:13:48 dpchrist Exp $
#######################################################################
# package:
#----------------------------------------------------------------------

package Dpchrist::File::Append;

use strict;
use warnings;

require Exporter;

our @ISA	= qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw(
	fappend
) ], );

our @EXPORT_OK	= (
    @{ $EXPORT_TAGS{'all'} },
);

our @EXPORT	= qw();

our $VERSION	= sprintf "%d.%03d", q$Revision: 1.33 $ =~ /(\d+)/g;

#######################################################################
# uses:
#----------------------------------------------------------------------

use Carp;
use Data::Dumper;
use Dpchrist::Is	qw( :all );
use File::Slurp;

#######################################################################

=head1 NAME

Dpchrist::File::Append - append to file or filehandle


=head1 DESCRIPTION

This documentation describes module revision $Revision: 1.33 $.


This is alpha test level software
and may change or disappear at any time.


=head2 SUBROUTINES

=cut

#######################################################################

=head3 fappend

    fappend FILEHANDLE, LIST
    fappend FILENAME, LIST

If first argument is a filehandle
or a string beginning with '*',
writes LIST to specified FILEHANDLE via print()
and returns true.
Whether the file is clobbered or appended
is determined by how the caller opened the filehandle.

Otherwise, assumes first argument is a file name,
appends LIST to file via File::Slurp::write_file()
and returns true.

LIST is optional in either case,
but fappend() will write to filehandle
or append to file regardless,
creating the file if it did not exist.


Calls Carp::confess() on error.

=cut

#----------------------------------------------------------------------

sub fappend($@)
{
    my $x = shift;

    ### GLOB reference:
    ###     open my $h, ...
    ###     fappend $h, ...
    ###
    ### filehandle reference:
    ###     fappend *STDERR, ...
    ###     open     H, ...
    ###     fappend *H, ...
    ###
    if (is_filehandle $x) {
	no strict "refs";

	return print($x @_)
	    or confess "print() failed: $!";
    }
    ### filename:
    ###     fappend "file.txt", ...
    ###
    elsif (is_filename $x) {
	my @args = ($x, {append => 1}, @_);

	return write_file(@args)
	    or confess "write_file() failed: $!";
    }
    else {
	confess 'invalid file handle or file name',
	    Data::Dumper->Dump([$x], [qw(x)]);
    }
}

#######################################################################
# end of code:
#----------------------------------------------------------------------

1;

__END__

#######################################################################

=head2 EXPORT

None by default.

All of the subroutines may be imported by using the ':all' tag:

    use Dpchrist::File::Append		qw( :all );


=head1 INSTALLATION

Old school:

    $ perl Makefile.PL
    $ make
    $ make test
    $ make install

Minimal:

    $ cpan Dpchrist::File::Append

Complete:

    $ cpan Bundle::Dpchrist


=head2 PREREQUISITES

See Makefile.PL in the source distribution root directory.


=head1 SEE ALSO

    Perl Cookbook, 2 e., recipe 7.5


=head1 AUTHOR

David Paul Christensen  dpchrist@holgerdanske.com


=head1 COPYRIGHT AND LICENSE

Copyright 2010 by David Paul Christensen  dpchrist@holgerdanske.com

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; version 2.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307,
USA.

=cut

#######################################################################
