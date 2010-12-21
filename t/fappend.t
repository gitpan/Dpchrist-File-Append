# $Id: fappend.t,v 1.16 2010-12-20 06:05:18 dpchrist Exp $

use strict;
use warnings;

use Test::More tests => 12;

use Dpchrist::File::Append	qw( fappend );

use Capture::Tiny		qw( capture );
use Carp;
use Data::Dumper;
use File::Basename;
use File::Slurp;

$|				= 1;
$Data::Dumper::Sortkeys		= 1;

my $r;		# eval{} return value
my $f;		# temporary file
my @m;		# temporary array
my $s;		# script
my $stdout;	# capture
my $stderr;	# capture
my $u;		# contents of $f


### test bad arguments:

$f = undef;
$r = eval {
    fappend $f;
};
ok(                                                             #     1
    !defined $r
    && $@ =~ /invalid file handle or file name/,
    'call on undefined value should fail'
) or confess join(" ",  basename(__FILE__), __LINE__,
    Data::Dumper->Dump([$r, $@],
		     [qw(r   @)]),
);

$r = eval {
    fappend {};
};
ok(                                                             #     2
    !defined $r
    && $@ =~ /invalid file handle or file name/,
    'call on reference should fail'
) or confess join(" ",  basename(__FILE__), __LINE__,
    Data::Dumper->Dump([$r, $@],
		     [qw(r   @)]),
);

$r = eval {
    fappend 'no/such/file';
};
ok(                                                             #     3
    !defined $r
    && $@ =~ /invalid file handle or file name/s,
    'call on bad file name should fail'
) or confess join(" ",  basename(__FILE__), __LINE__,
    Data::Dumper->Dump([$r, $@, $f],
		     [qw(r   @   f)]),
);

### test *STDERR:

@m = ('hello, ', 'world!');

($stdout, $stderr) = capture {
    eval { $r = fappend *STDERR, @m }
};
ok(                                                             #     4
    defined $r
    && $r == 1
    && $stdout eq ''
    && $stderr =~ /hello..world/,
    'call to *STDERR should work'
) or confess join(" ", basename(__FILE__), __LINE__,
    Data::Dumper->Dump([$r, $@, \@m, $stdout, $stderr],
		     [qw(r   @   *m   stdout   stderr)]),
);

($stdout, $stderr) = capture {
    eval { $r = fappend '*STDERR', @m }
};
ok(                                                             #     5
    defined $r
    && $r == 1
    && $stdout eq ''
    && $stderr =~ /hello..world/,
    'call to *STDERR as string should work'
) or confess join(" ", basename(__FILE__), __LINE__,
    Data::Dumper->Dump([$r, $@, \@m, $stdout, $stderr],
		     [qw(r   @   *m   stdout   stderr)]),
);


### test filename:

$f = basename(__FILE__) . '~' . __LINE__ . "~tmp";

if (-e $f) {
    unlink($f)
	or confess "ERROR unlinking file '$f': $!";
}

$r = eval {
    fappend $f;
};
ok(                                                             #     6
    defined $r
    && $r == 1
    && -z $f,
    "call on file name with no list should " .
    "create empty file " .
    "and return true",
) or confess join(" ", basename(__FILE__), __LINE__,
    Data::Dumper->Dump([$r, $@, $f, $u],
		     [qw(r   @   f   u)]),
);

$f = basename(__FILE__) . '~' . __LINE__ . "~tmp";

if (-e $f) { unlink($f) or die $! }

$r = eval {
    fappend $f, ();
};
ok(                                                             #     7
    defined $r
    && $r == 1
    && -z $f,
    "call on file name with empty list should " .
    "create empty file" .
    "and return true",
) or confess join(" ", basename(__FILE__), __LINE__,
    Data::Dumper->Dump([$r, $@, $f, $u],
		     [qw(r   @   f   u)]),
);

@m = (basename(__FILE__), __LINE__);
$s = join '', @m;
$r = eval {
    fappend $f, @m;
};
$u = read_file($f);
ok(                                                             #     8
    defined $r
    && $r == 1
    && $u eq $s,
    "call on file name with list should " .
    "append to file " .
    "and return true"
) or confess join(" ", basename(__FILE__), __LINE__,
    Data::Dumper->Dump([$r, $@, $f, \@m, $s, $u],
		     [qw(r   @   f   *m   s   u)]),
);

@m = (basename(__FILE__), __LINE__);
$s .= join '', @m;
$r = eval {
    fappend $f, @m;
};
$u = read_file($f);
ok(                                                             #     9
    defined $r
    && $r == 1
    && $u eq $s,
    "another call on file name with list should " .
    "append to file " .
    "and return true",
) or confess join(" ", basename(__FILE__), __LINE__,
    Data::Dumper->Dump([$r, $@, $f, \@m, $s, $u],
                     [qw(r   $   f   *m   s   u)]),
);


### test filehandle reference:

open(F, ">> $f") or die $!;
@m = ("ignore this message ", basename(__FILE__), " ", __LINE__, "\n",
      "ignore this message ", basename(__FILE__), " ", __LINE__, "\n");
$s .= join "", @m;
$r = eval {
    fappend *F, @m;
};
close(F) or die $!;
$u = read_file($f);
ok(                                                             #    10
    defined $r
    && $r == 1
    && $u eq $s,
    "call on filehandle with list should " .
    "append to file " .
    "and return true",
) or confess join(" ", basename(__FILE__), __LINE__,
    Data::Dumper->Dump([$r, $@, $f, \@m, $s, $u],
                     [qw(r   @   f   *m   s   u)]),
);

open(F, ">> $f") or die $!;
my $fh = *F;
@m = ("ignore this message ", basename(__FILE__), " ", __LINE__, "\n",
      "ignore this message ", basename(__FILE__), " ", __LINE__, "\n");
$s .= join "", @m;
$r = eval {
    fappend $fh, @m;
};
close(F) or die $!;
$u = read_file($f);
ok(                                                             #    11
    defined $r
    && $r == 1
    && $u eq $s,
    "call with filehandle reference variable should " .
    "append to file" .
    "and return true",
) or confess join(" ", basename(__FILE__), __LINE__,
    Data::Dumper->Dump([$r, $@, $f, \@m, $s, $u],
		     [qw(r   @   f   *m   s   u)]),
);


### test GLOB reference:

open(my $h, ">> $f") or die $!;
@m = ("ignore this message ", basename(__FILE__), " ", __LINE__, "\n",
      "ignore this message ", basename(__FILE__), " ", __LINE__, "\n");
$s .= join "", @m;
$r = eval {
    fappend $h, @m;
};
close($h) or die $!;
$u = read_file($f);
ok(                                                             #    12
    defined $r
    && $r == 1
    && $u eq $s,
    "call with GLOB reference should " .
    "append to file" .
    "and return list",
) or confess join(" ", basename(__FILE__), __LINE__,
    Data::Dumper->Dump([$r, $@, $f, $fh, \@m, $s, $u],
		     [qw(r   @   f   fh   *m   s   u)]),
);

