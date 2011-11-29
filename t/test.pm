# (X)Emacs mode: -*- cperl -*-

package test;

=head1 NAME

test - tools for helping in test suites (not including running externalprograms).

=head1 SYNOPSIS

  use FindBin               1.42 qw( $Bin );
  use Test                  1.13 qw( ok plan );

  BEGIN { unshift @INC, $Bin };

  use test                  qw(   evcheck runcheck );

  BEGIN {
    plan tests  => 3,
         todo   => [],
         ;
  }

  ok evcheck(sub {
               open my $fh, '>', 'foo';
               print $fh "$_\n"
                 for 'Bulgaria', 'Cholet';
               close $fh;
             }, 'write foo'), 1, 'write foo';

=head1 DESCRIPTION

This package provides some variables, and sets up an environment, for test
scripts, such as those used in F<t/>.

This package does not including running external programs; that is provided by
C<test2.pm>.  This is so that suites not needing that can include only
test.pm, and so not require the presence of C<IPC::Run>.

Setting up the environment includes:

=over 4

=item Prepending F<blib/script> onto the path

=item Pushing the module F<lib/> dir onto the @INC var

For internal C<use> calls.

=item Changing directory to a temporary directory

To avoid cluttering the local dir, and/or allowing the local directory
structure to affect matters.

=item Cleaning up the temporary directory afterwards

Unless TEST_DEBUG is set in the environment.

=back

=cut

# ----------------------------------------------------------------------------

# Pragmas -----------------------------

use 5.00503;
use strict;
use vars qw( @EXPORT_OK );

# Inheritance -------------------------

use base qw( Exporter );

=head2 EXPORTS

The following symbols are exported upon request:

=over 4

=item evcheck

=back

=cut

@EXPORT_OK = qw( evcheck );

# Utility -----------------------------

use Carp                          qw( carp croak );
use Cwd                      2.01 qw( cwd );
use Env                           qw( PATH );
use Fatal                    1.02 qw( close open seek sysopen unlink );
use Fcntl                    1.03 qw( :DEFAULT );
use File::Basename                qw( basename );
use File::Path             1.0401 qw( mkpath rmtree );
use File::Spec                0.6 qw( );
use File::Temp                    qw( tempdir );
use FindBin                  1.42 qw( $Bin );
#use POSIX                    1.02 qw( );
use Test                    1.122 qw( ok skip );

# ----------------------------------------------------------------------------

# -------------------------------------
# PACKAGE CONSTANTS
# -------------------------------------

use constant BUILD_SCRIPT_DIR => => File::Spec->catdir( $Bin, File::Spec->updir, qw( blib script ) );

# -------------------------------------
# PACKAGE ACTIONS
# -------------------------------------

$PATH = join ':', BUILD_SCRIPT_DIR, split /:/, $PATH;

$| = 1;

# -------------------------------------
# PACKAGE FUNCTIONS
# -------------------------------------

=head2 evcheck

Eval code, return status

=over 4

=item ARGUMENTS

=over 4

=item code

Coderef to eval

=item name

Name to use in error messages

=back

=item RETURNS

=over 4

=item okay

1 if eval was okay, 0 if not.

=back

=back

=cut

sub evcheck {
  my ($code, $name) = @_;

  my $ok = 0;

  eval {
    &$code;
    $ok = 1;
  }; if ( $@ ) {
    carp "Code $name failed: $@\n"
      if $ENV{TEST_DEBUG};
    $ok = 0;
  }

  return $ok;
}

# -------------------------------------

# defined further up to use in constants

# ----------------------------------------------------------------------------

=head1 EXAMPLES

Z<>

=head1 BUGS

Z<>

=head1 REPORTING BUGS

Email the author.

=head1 AUTHOR

Martyn J. Pearce C<fluffy@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2001, 2002, 2004 Martyn J. Pearce.  This program is free
software; you can redistribute it and/or modify it under the same terms as
Perl itself.

=head1 SEE ALSO

Z<>

=cut

1; # keep require happy.

__END__
