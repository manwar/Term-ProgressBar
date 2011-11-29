# (X)Emacs mode: -*- cperl -*-

use strict;

=head1 Unit Test Package for Term::ProgressBar

This package tests the basic functionality of Term::ProgressBar.

=cut

use Data::Dumper 2.101 qw( Dumper );
use FindBin 1.42 qw( $Bin );
use Test 1.122 qw( ok plan );

use lib $Bin;
use test qw( DATA_DIR
             evcheck restore_output save_output );

use constant MESSAGE1 => 'Walking on the Milky Way';

BEGIN {
  # 1 for compilation test,
  plan tests  => 11,
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

=head2 Tests 2--8: Count 1-10

Create a progress bar with 10 things.
Update it it from 1 to 10.  Output a message halfway through.

(1) Check no exception thrown on creation
(2) Check no exception thrown on update (1..5)
(3) Check no exception thrown on message send
(4) Check no exception thrown on update (6..10)
(5) Check message was issued.
(6) Check bar is complete
(7) Check bar number is 100%

=cut

{
  my $p;
  save_output('stderr', *STDERR{IO});
  ok (evcheck(sub { $p = Term::ProgressBar->new(10); }, 'Count 1-10 (1)' ),
      1, 'Count 1-10 (1)');
  ok (evcheck(sub { $p->update($_) for 1..5  }, 'Count 1-10 (2)' ),
      1, 'Count 1-10 (2)');
  ok (evcheck(sub { $p->message(MESSAGE1)    }, 'Count 1-10 (3)' ),
      1, 'Count 1-10 (3)');
  ok (evcheck(sub { $p->update($_) for 6..10 }, 'Count 1-10 (4)' ),
      1, 'Count 1-10 (4)');
  my $err = restore_output('stderr');

  $err =~ s!^.*\r!!gm;
  print STDERR "ERR:\n$err\nlength: ", length($err), "\n"
    if $ENV{TEST_DEBUG};

  my @lines = split /\n/, $err;

  ok $lines[0], MESSAGE1;
  ok $lines[-1], qr/\[=+\]/,            'Count 1-10 (5)';
  ok $lines[-1], qr/^\s*100%/,          'Count 1-10 (6)';
}

# -------------------------------------

=head2 Tests 9--11: Message Check

Run a progress bar from 0 to 100, each time calling a message after an update.
This is to check that message preserves the progress bar value correctly.

( 1) Check no exception thrown on creation
( 2) Check no exception thrown on update, message (0..100).
( 3) Check last progress is 100%

=cut

{
  my $p;
  save_output('stderr', *STDERR{IO});
  ok (evcheck(sub { $p = Term::ProgressBar->new(100); }, 'Message Check ( 1)'),
      1,                                                 'Message Check ( 1)');
  ok (evcheck(sub { for (0..100) { $p->update($_); $p->message("Hello") } },
              'Message Check ( 2)',), 
      1,                                                 'Message Check ( 2)');
  my $err = restore_output('stderr');

  my @err_lines = split /\n/, $err;
  (my $last_line = $err_lines[-1]) =~ tr/\r//d;
  ok substr($last_line, 0, 4), '100%',               'Message Check ( 3)';
}

# ----------------------------------------------------------------------------
