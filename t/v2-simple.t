# (X)Emacs mode: -*- cperl -*-

use strict;

=head1 Unit Test Package for Term::ProgressBar

This package tests the basic functionality of Term::ProgressBar.

=cut

use Data::Dumper qw( Dumper );
use FindBin      qw( $Bin );
use Test         qw( ok plan );

use lib $Bin;
use test qw( DATA_DIR
             evcheck restore_output save_output );

BEGIN {
  # 1 for compilation test,
  plan tests  => 31,
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

=head2 Tests 2--16: Count 1-10

Create a progress bar with 10 things.
Update it it from 1 to 10.

(1) Check no exception thrown on creation
(2) Check no exception thrown on update
(3) Check bar is complete
(4) Check bar number is 100%
(5--15) Check bar has no minor characters at any point

=cut

{
  my $p;
  save_output('stderr', *STDERR{IO});
  ok (evcheck(sub { $p = Term::ProgressBar->new(10); }, 'Count 1-10 (1)' ),
      1, 'Count 1-10 (1)');
  ok (evcheck(sub { $p->update($_) for 1..10 }, 'Count 1-10 (2)' ),
      1, 'Count 1-10 (2)');
  my $err = restore_output('stderr');
  my @lines = grep $_ ne '', split /\r/, $err;
  print Dumper \@lines
    if $ENV{TEST_DEBUG};
  ok $lines[-1], qr/\[=+\]/,            'Count 1-10 (3)';
  ok $lines[-1], qr/^\s*100%/,          'Count 1-10 (4)';
  ok $lines[$_], qr/\[[= ]+\]/, sprintf('Count 1-10 (%d)', 5+$_)
    for 0..10;
}

# -------------------------------------

=head2 Tests 17--30: Count 1-9

Create a progress bar with 10 things.
Update it it from 1 to 9.

(1) Check no exception thrown on creation
(2) Check no exception thrown on update
(3) Check bar is incomplete
(4) Check bar number is 90%
(5--14) Check bar has no minor characters at any point

=cut

{
  my $p;
  save_output('stderr', *STDERR{IO});
  ok (evcheck(sub { $p = Term::ProgressBar->new(10); }, 'Count 1-9 (1)' ),
      1, 'Count 1-9 (1)');
  ok (evcheck(sub { $p->update($_) for 1..9 }, 'Count 1-9 (2)' ),
      1, 'Count 1-9 (2)');
  my $err = restore_output('stderr');
  my @lines = grep $_ ne '', split /\r/, $err;
  print Dumper \@lines
    if $ENV{TEST_DEBUG};
  ok $lines[-1], qr/\[=+ +\]/,          'Count 1-9 (3)';
  ok $lines[-1], qr/^\s*90%/,           'Count 1-9 (4)';
  ok $lines[$_], qr/\[[= ]+\]/, sprintf('Count 1-9 (%d)', 5+$_)
    for 0..9;
}

# -------------------------------------

=head2 Test 31

Make sure the same progress bar text is not printed twice to the
terminal (in the case of an update that is too little to affect the
percentage or displayed bar).

=cut
{
  save_output('stderr', *STDERR{IO});
  my $b = Term::ProgressBar->new(1000000);
  $b->update($_) foreach (0, 1);
  my $err = restore_output('stderr');
  my @lines = grep $_ ne '', split /\r/, $err;
  print Dumper \@lines
    if $ENV{TEST_DEBUG};
  ok scalar @lines, 1;
}
