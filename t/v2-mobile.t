# (X)Emacs mode: -*- cperl -*-

use strict;

=head1 Unit Test Package for Term::ProgressBar

This package tests the moving target functionality of Term::ProgressBar.

=cut

use Data::Dumper qw( Dumper );
use FindBin      qw( $Bin );
use Test         qw( ok plan );

use lib $Bin;
use test qw( DATA_DIR
             evcheck restore_output save_output );

BEGIN {
  # 1 for compilation test,
  plan tests  => 7,
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

=head2 Tests 2--7: Count 1-20

Create a progress bar with 10 things.
Update it it from 1 to 5.
Change target to 20.
Update it from 11 to 20.

(1) Check no exception thrown on creation
(2) Check no exception thrown on update (1..5)
(3) Check no exception thrown on target update
(4) Check no exception thrown on update (6..10)
(5) Check bar is complete
(6) Check bar number is 100%

=cut

{
  my $p;
  save_output('stderr', *STDERR{IO});
  ok (evcheck(sub { $p = Term::ProgressBar->new(10); }, 'Count 1-20 (1)' ),
      1, 'Count 1-20 (1)');
  ok (evcheck(sub { $p->update($_) for 1..5  },  'Count 1-20 (2)' ),
      1, 'Count 1-20 (2)');
  ok (evcheck(sub { $p->target(20)    },         'Count 1-20 (3)' ),
      1, 'Count 1-20 (3)');
  ok (evcheck(sub { $p->update($_) for 11..20 }, 'Count 1-20 (4)' ),
      1, 'Count 1-20 (4)');
  my $err = restore_output('stderr');

  $err =~ s!^.*\r!!gm;
  print STDERR "ERR:\n$err\nlength: ", length($err), "\n"
    if $ENV{TEST_DEBUG};

  my @lines = split /\n/, $err;

  ok $lines[-1], qr/\[=+\]/,            'Count 1-20 (5)';
  ok $lines[-1], qr/^\s*100%/,          'Count 1-20 (6)';
}
