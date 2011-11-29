# (X)Emacs mode: -*- cperl -*-

use strict;

=head1 Unit Test Package for Term::ProgressBar

This package tests the name functionality of Term::ProgressBar.

=cut

use Data::Dumper  qw( Dumper );
use FindBin       qw( $Bin );
use Test          qw( ok plan );

use lib $Bin;
use test qw( DATA_DIR
             evcheck restore_output save_output );

use constant MESSAGE1 => 'The Gospel of St. Jude';
use constant NAME1    => 'Algenon';
use constant NAME2    => 'Smegma';

BEGIN {
  # 1 for compilation test,
  plan tests  => 18,
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

Create a progress bar with 10 things, and a name 'Algenon'.
Update it it from 1 to 10.

(1) Check no exception thrown on creation
(2) Check no exception thrown on update (1..3)
(3) Check bar number is 30%
(4) Check bar is 30% along
(5) Check no exception thrown on message send
(6) Check no exception thrown on update (6..10)
(7) Check message seen
(8) Check bar is complete
(9) Check bar number is 100%

=cut

{
  my $p;
  save_output('stderr', *STDERR{IO});
  ok (evcheck(sub {
                $p = Term::ProgressBar->new({count => 10, name => NAME1});
              },                                            'Count 1-10 ( 1)'),
      1,                                                    'Count 1-10 ( 1)');
  ok (evcheck(sub { $p->update($_) for 1..3  },             'Count 1-10 ( 2)'),
      1,                                                    'Count 1-10 ( 2)');

  my $err = restore_output('stderr');

  $err =~ s!^.*\r!!gm;
  print STDERR "ERR (1) :\n$err\nlength: ", length($err), "\n"
    if $ENV{TEST_DEBUG};
  my @lines = split /\n/, $err;
  ok $lines[-1], qr/^@{[NAME1()]}: \s*\b30%/,                'Count 1-10 ( 3)';
  my ($bar, $space) = $lines[-1] =~ /\[(=*)(\s*)\]/;
  my $length = length($bar) + length($space);
  print STDERR
    ("LENGTHS (1) :BAR:", length($bar), ":SPACE:", length($space), "\n")
    if $ENV{TEST_DEBUG};
  my $barexpect = $length * 0.3;
  my $ok = length($bar) > $barexpect -1 && length($bar) < $barexpect+1;
  ok $ok;

  save_output('stderr', *STDERR{IO});

  ok (evcheck(sub { $p->message(MESSAGE1)    },             'Count 1-10 ( 5)'),
      1,                                                    'Count 1-10 ( 5)');
  ok (evcheck(sub { $p->update($_) for 6..10 },             'Count 1-10 ( 6)'),
      1,                                                    'Count 1-10 ( 6)');
  $err = restore_output('stderr');

  $err =~ s!^.*\r!!gm;
  print STDERR "ERR (2) :\n$err\nlength: ", length($err), "\n"
    if $ENV{TEST_DEBUG};

  @lines = split /\n/, $err;

  ok $lines[0], MESSAGE1,                                    'Count 1-10 ( 7)';
  ok $lines[-1], qr/\[=+\]/,                                 'Count 1-10 ( 8)';
  ok $lines[-1], qr/^@{[NAME1()]}: \s*100%/,                 'Count 1-10 ( 9)';
}

# -------------------------------------

=head2 Tests 11--20: Count 1-20

Create a progress bar with 20 things, and a name 'Smegma'.
Update it it from 1 to 20.
Use v1 mode

(1) Check no exception thrown on creation
(2) Check no exception thrown on update (1..12)
(3) Check bar number is 60%
(4) Check bar is 60% along
(5) Check no exception thrown on message send
(6) Check no exception thrown on update (13..20)
(7) Check message seen
(8) Check bar is complete
(9) Check bar number is 100%

=cut

{
  my $p;
  save_output('stderr', *STDERR{IO});
  ok (evcheck(sub { $p = Term::ProgressBar->new(NAME2, 10); }, 
                                                            'Count 1-10 ( 1)'),
      1,                                                    'Count 1-10 ( 1)');
  ok (evcheck(sub { $p->update($_) for 1..3  },             'Count 1-10 ( 2)'),
      1,                                                    'Count 1-10 ( 2)');

  my $err = restore_output('stderr');

  $err =~ s!^.*\r!!gm;
  print STDERR "ERR (1) :\n$err\nlength: ", length($err), "\n"
    if $ENV{TEST_DEBUG};
  my @lines = split /\n/, $err;
  ok $lines[-1], qr/^@{[NAME2()]}: \s*\b30%/,                'Count 1-10 ( 3)';
  my ($bar, $space) = $lines[-1] =~ /(\#*)(\s*)/;
  my $length = length($bar) + length($space);
  print STDERR
    ("LENGTHS (1) :BAR:", length($bar), ":SPACE:", length($space), "\n")
    if $ENV{TEST_DEBUG};
  my $barexpect = $length * 0.3;
  my $ok = length($bar) > $barexpect -1 && length($bar) < $barexpect+1;
  ok $ok;

  save_output('stderr', *STDERR{IO});

  ok (evcheck(sub { $p->message(MESSAGE1)    },             'Count 1-10 ( 5)'),
      1,                                                    'Count 1-10 ( 5)');
  ok (evcheck(sub { $p->update($_) for 6..10 },             'Count 1-10 ( 6)'),
      1,                                                    'Count 1-10 ( 6)');
  $err = restore_output('stderr');

  $err =~ s!^.*\r!!gm;
  print STDERR "ERR (2) :\n$err\nlength: ", length($err), "\n"
    if $ENV{TEST_DEBUG};

  @lines = split /\n/, $err;

  ok $lines[-1], qr/^@{[NAME2()]}: \s*\d+% \#*$/,            'Count 1-10 ( 8)';
  ok $lines[-1], qr/^@{[NAME2()]}: \s*100%/,                 'Count 1-10 ( 9)';
}

# -------------------------------------
