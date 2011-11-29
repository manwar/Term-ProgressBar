# (X)Emacs mode: -*- cperl -*-

use strict;
use warnings;

=head1 Unit Test Package for Term::ProgressBar v1.0 Compatibility

This script is based on the test script for Term::ProgressBar version 1.0,
and is intended to test compatibility with that version.

=cut

# Utility -----------------------------

use Data::Dumper qw( );
use Test::More tests => 9;

use Term::ProgressBar;
use POSIX qw<floor ceil>;
use Capture::Tiny qw(capture);

$| = 1;

my $count = 100;

diag 'create a bar';
my $test_str = 'test';

my $tp;
{
  my ($out, $err) = capture { $tp = Term::ProgressBar->new($test_str, $count); };
  ok $tp;
  is $out, '';
  is $err, "$test_str: ";
}

#    print Data::Dumper->Dump([$b, $out, $err], [qw( b o e)])
#      if $ENV{TEST_DEBUG};

diag 'do half the stuff and check half the bar has printed';
my $halfway = floor($count / 2);
{
  my ($out, $err) = capture { update $tp foreach (0 .. $halfway - 1) };
  is $out, '';
  is $err, ('#' x floor(50 / 2));
  
#    print Data::Dumper->Dump([$o], [qw( o )])
#      if $ENV{TEST_DEBUG};
}

# do the rest of the stuff and check the whole bar has printed
{
   my ($out, $err) = capture { update $tp foreach ($halfway .. $count - 1) };
   is $out, '';
   is $err, ('#' x ceil(50 / 2)) . "\n";
#    print Data::Dumper->Dump([$o], [qw( o )])
#      if $ENV{TEST_DEBUG};

}

# try to do another item and check there is an error
eval { update $tp };
ok defined($@);
is substr($@, 0, length(Term::ProgressBar::ALREADY_FINISHED)),
          Term::ProgressBar::ALREADY_FINISHED;
#  print Data::Dumper->Dump([$@], [qw( @ )])
#    if $ENV{TEST_DEBUG};
