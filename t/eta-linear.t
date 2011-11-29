# (X)Emacs mode: -*- cperl -*-

use strict;

=head1 Unit Test Package for Term::ProgressBar

This package tests the basic functionality of Term::ProgressBar.

=cut

use Data::Dumper  qw( Dumper );
use FindBin       qw( $Bin );
use Test          qw( ok plan );

use lib $Bin;
use test qw( DATA_DIR
             evcheck restore_output save_output );

BEGIN {
  # 1 for compilation test,
  plan tests  => 10,
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

=head2 Tests 2--10: Count 1-10

Create a progress bar with 10 things.  Invoke ETA and name on it.
Update it it from 1 to 10.

(1) Check no exception thrown on creation
(2) Check no exception thrown on update 1..5
(3) Check no exception thrown on message issued
(4) Check no exception thrown on update 6..10
(5) Check message seen
(6) Check bar is complete
(7) Check bar number is 100%
(8) Check --DONE-- issued
(9) Check estimation done

=cut

{
  my $p;
  save_output('stderr', *STDERR{IO});
  ok (evcheck(sub {
                $p = Term::ProgressBar->new({count => 10, name => 'fred',
                                             ETA => 'linear'});
              }, 'Count 1-10 (1)' ),
      1, 'Count 1-10 (1)');
  ok (evcheck(sub { for (1..5) { $p->update($_); sleep 1 } },
              'Count 1-10 (2)' ),
      1, 'Count 1-10 (2)');
  ok (evcheck(sub { $p->message('Hello Mum!') },
              'Count 1-10 (3)' ),
      1, 'Count 1-10 (3)');
  ok (evcheck(sub { for (6..10) { $p->update($_); sleep 1 } },
              'Count 1-10 (4)' ),
      1, 'Count 1-10 (4)');
  my $err = restore_output('stderr');
#  $err =~ s!^.*\r!!gm;
  my @lines = grep $_ ne '', split /[\n\r]+/, $err;
  print Dumper \@lines
    if $ENV{TEST_DEBUG};
  ok grep $_ eq 'Hello Mum!', @lines;
  ok $lines[-1], qr/\[=+\]/,                                  'Count 1-10 (6)';
  ok $lines[-1], qr/^fred: \s*100%/,                          'Count 1-10 (7)';
  ok $lines[-1], qr/D[ \d]\dh\d{2}m\d{2}s$/,                  'Count 1-10 (8)';
  ok $lines[-2], qr/ Left$/,                                  'Count 1-10 (9)';
}

# ----------------------------------------------------------------------------
