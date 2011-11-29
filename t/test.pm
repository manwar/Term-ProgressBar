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

  save_output('stderr', *STDERR{IO});
  warn 'Hello, Mum!';
  print restore_output('stderr');

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

=item save_output

=item restore_output

=item tmpnam

=item tempdir

=back

=cut

@EXPORT_OK = qw( evcheck save_output restore_output );

# Utility -----------------------------

use Carp                          qw( carp croak );
use Cwd                      2.01 qw( cwd );
use Env                           qw( PATH );
use Fatal                    1.02 qw( close open seek sysopen unlink );
use Fcntl                    1.03 qw( :DEFAULT );
use File::Basename                qw( basename );
use File::Path             1.0401 qw( mkpath rmtree );
use File::Spec                0.6 qw( );
use FindBin                  1.42 qw( $Bin );
use POSIX                    1.02 qw( );
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

my $tmpdn = tempdir();
$| = 1;

mkpath $tmpdn;
die "Couldn't create temp dir: $tmpdn: $!\n"
  unless -r $tmpdn and -w $tmpdn and -x $tmpdn and -o $tmpdn and -d $tmpdn;

chdir $tmpdn;

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

=head2 save_output

Redirect a filehandle to temporary storage for later examination.

=over 4

=item ARGUMENTS

=over 4

=item name

Name to store as (used in L<restore_output>)

=item filehandle

The filehandle to save

=back

=cut

# Map from names to saved filehandles.

# Values are arrayrefs, being filehandle that was saved (to restore), the
# filehandle being printed to in the meantime, and the original filehandle.
# This may be treated as a stack; to allow multiple saves... push & pop this
# stack.

my %grabs;

sub save_output {
  croak sprintf("%s takes 2 arguments\n", (caller 0)[3])
    unless @_ == 2;
  my ($name, $filehandle) = @_;

  my $tmpfh  = do { local *F; *F; };
  my $savefh = do { local *F; *F; };

  (undef, $tmpfh) = test::tmpnam();
  select((select($tmpfh), $| = 1)[0]);

  open $savefh, '>&' . fileno $filehandle
    or die "can't dup $name: $!";
  open $filehandle, '>&' . fileno $tmpfh
    or die "can't open $name to tempfile: $!";

  push @{$grabs{$name}}, $savefh, $tmpfh, $filehandle;
}

# -------------------------------------

=head2 restore_output

Restore a saved filehandle to its original state, return the saved output.

=over 4

=item ARGUMENTS

=over 4

=item name

Name of the filehandle to restore (as passed to L<save_output>).

=back

=item RETURNS

=over 4

=item saved_string

A single string being the output saved.

=back

=cut

sub restore_output {
  my ($name) = @_;

  croak "$name has not been saved\n"
    unless exists $grabs{$name};
  croak "All saved instances of $name have been restored\n"
    unless @{$grabs{$name}};
  my ($savefh, $tmpfh, $origfh) = splice @{$grabs{$name}}, -3;

  close $origfh
    or die "cannot close $name opened to tempfile: $!";
  open  $origfh, '>&' . fileno $savefh
    or die "cannot dup $name back again: $!";
  select((select($origfh), $| = 1)[0]);

  seek $tmpfh, 0, 0;
  local $/ = undef;
  my $string = <$tmpfh>;
  close $tmpfh;

  return $string;
}

sub _test_save_restore_output {
  warn "to stderr 1\n";
  save_output("stderr", *STDERR{IO});
  warn "Hello, Mum!";
  print 'SAVED:->:', restore_output("stderr"), ":<-\n";
  warn "to stderr 2\n";
}

# -------------------------------------

=head2 tmpnam

Very much like the one in L<POSIX> or L<File::Temp>, but does not get deleted
if TEST_DEBUG has SAVE in the value.

=over 4

=item ARGUMENTS

=over 4

=item name

I<Optional>.  If defined, a name by which to refer to the tmpfile in user
messages.

=back

=item RETURNS

=over 4

=item filename

Name of temporary file.

=item fh

Open filehandle to temp file, in r/w mode.  Only created & returned in list
context.

=back

=back

=cut

my @tmpfns;

BEGIN {
  my $savewarn = $SIG{__WARN__};
  # Subvert bizarre (& incorrect) subroutine redefined errors in 5.005_03
  local $SIG{__WARN__} =
    sub {
      $savewarn->(@_)
        if defined $savewarn                        and
           UNIVERSAL::isa($savewarn,'CODE')         and
           $_[0] !~ /^Subroutine tmpnam redefined/;
    };

  *tmpnam = sub {
    my $tmpnam = POSIX::tmpnam;

    if (@_) {
      push @tmpfns, [ $tmpnam, $_[0] ];
    } else {
      push @tmpfns, $tmpnam;
    }

    if (wantarray) {
      sysopen my $tmpfh, $tmpnam, O_RDWR | O_CREAT | O_EXCL;
      return $tmpnam, $tmpfh;
    } else {
      return $tmpnam;
    }
  }
}

END {
  if ( defined $ENV{TEST_DEBUG} and $ENV{TEST_DEBUG} =~ /\bSAVE\b/ ) {
    for (@tmpfns) {
      if ( ref $_ ) {
        printf "Used temp file: %s (%s)\n", @$_;
      } else {
        print "Used temp file: $_\n";
      }
    }
  } else {
    unlink map((ref $_ ? $_->[0] : $_), @tmpfns)
      if @tmpfns;
  }
}

# -------------------------------------

=head2 tempdir

Very much like the one in L<POSIX> or L<File::Temp>, but does not get deleted
if TEST_DEBUG has SAVE in the value (does get deleted otherwise).

=over 4

=item ARGUMENTS

I<None>

=item RETURNS

=over 4

=item name

Name of temporary dir.

=back

=back

=cut

my @tmpdirs;
sub tempdir {
  my $tempdir = POSIX::tmpnam;
  mkdir $tempdir, 0700
    or die "Failed to create temporary directory $tempdir: $!\n";

  if (@_) {
    push @tmpdirs, [ $tempdir, $_[0] ];
  } else {
    push @tmpdirs, $tempdir;
  }

  return $tempdir;
}

END {
  for (@tmpdirs) {
    if ( ref $_ ) {
      if ( defined $ENV{TEST_DEBUG} and $ENV{TEST_DEBUG} =~ /\bSAVE\b/ ) {
        printf "Used temp dir: %s (%s)\n", @$_;
      } else {
        # Solaris gets narky about removing the pwd.
        chdir File::Spec->rootdir;
        rmtree $_->[0];
      }
    } else {
      if ( defined $ENV{TEST_DEBUG} and $ENV{TEST_DEBUG} =~ /\bSAVE\b/ ) {
        print "Used temp dir: $_\n";
      } else {
        # Solaris gets narky about removing the pwd.
        chdir File::Spec->rootdir;
        rmtree $_;
      }
    }
  }
}


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
