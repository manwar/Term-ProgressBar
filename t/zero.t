# (X)Emacs mode: -*- cperl -*-

use strict;

=head1 Unit Test Package for Term::ProgressBar

This package tests the zero-progress handling of progress bar.

=cut

use Data::Dumper qw( Dumper );
use FindBin      qw( $Bin );
use Test         qw( ok plan );

use lib $Bin;
use test qw( DATA_DIR
             evcheck restore_output save_output );

BEGIN {
  # 1 for compilation test,
  plan tests  => 9,
       todo   => [],
}

=head2 Test 1: compilation

This test confirms that the test script and the modules it calls compiled
successfully.

=cut

use Term::ProgressBar;

ok 1, 1, 'compilation';

Term::ProgressBar->__force_term (50);

# -------------------------------------

=head2 Tests 2--5: V1 mode

Create a progress bar with 0 things.
Update it it from 1 to 10.

(1) Check no exception thrown on creation
(2) Check no exception thrown on update
(3) Check bar displays name
(3) Check bar says nothing to do

=cut

{
  my $p;
  save_output('stderr', *STDERR{IO});
  my $name = 'doing nothing';
  ok (evcheck(sub { $p = Term::ProgressBar->new($name, 0); },
	 'V1 mode ( 1)' ),
      1,                                                       'V1 mode ( 1)');
  ok (evcheck(sub { $p->update($_) for 1..10 },'V1 mode ( 2)'),
      1,                                                       'V1 mode ( 2)');
  my $err = restore_output('stderr');
  my @lines = grep $_ ne '', split /\r/, $err;
  print Dumper \@lines
    if $ENV{TEST_DEBUG};
  ok $lines[-1], qr/^$name:/,                                  'V1 mode ( 3)';
  ok $lines[-1], qr/\(nothing to do\)/,                        'V1 mode ( 4)';
}

# -------------------------------------

=head2 Tests 6--9: V2 mode

Create a progress bar with 0 things.
Update it it from 1 to 10.

(1) Check no exception thrown on creation
(2) Check no exception thrown on update
(3) Check bar displays name
(4) Check bar says nothing to do

=cut

{
  my $p;
  save_output('stderr', *STDERR{IO});
  my $name = 'zero';
  ok (evcheck(sub { $p = Term::ProgressBar->new({ count => 0,
                                                  name => $name }); },
	 'V2 mode ( 1)' ),
      1,                                                       'V2 mode ( 1)');
  ok (evcheck(sub { $p->update($_) for 1..10 },'V2 mode ( 2)'),
      1,                                                       'V2 mode ( 2)');
  my $err = restore_output('stderr');
  my @lines = grep $_ ne '', split /\r/, $err;
  print Dumper \@lines
    if $ENV{TEST_DEBUG};
  ok $lines[-1], qr/^$name:/,                                  'V2 mode ( 3)';
  ok $lines[-1], qr/\(nothing to do\)/,                        'V2 mode ( 4)';
}

# ----------------------------------------------------------------------------
