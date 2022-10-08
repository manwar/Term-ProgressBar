use strict;
use warnings;

=head1 Unit Test Package for Term::ProgressBar

This package tests that the bar ends up full when finished

=cut

use Test::More tests => 6;
use Test::Exception;
use Test::Warnings; # Test 6 at the end

use Capture::Tiny qw(capture_stderr);

use_ok 'Term::ProgressBar';

Term::ProgressBar->__force_term(79);

# -------------------------------------

=head2 Tests 2--5: Tricky math

Create a progress bar with 241 things.
Update it it from 1 to 241.

(1) Check no exception thrown on creation
(2) Check no exception thrown on update
(3) Check bar is complete
(4) Check bar number is 100%

=cut
{
  my $err = capture_stderr {
    my $p;
    lives_ok { $p = Term::ProgressBar->new({ count => 241, ETA => 'linear' }); } 'Tricky math (1)';
    lives_ok { $p->update($_) for 1..241 } 'Tricky math (2)';
  };

  my @lines = grep {$_ ne ''} split /\r/, $err;
  diag explain \@lines
    if $ENV{TEST_DEBUG};
  like $lines[-1], qr/\[=+\]/,            'Tricky math (3)';
  like $lines[-1], qr/^\s*100%/,          'Tricky math (4)';
}


