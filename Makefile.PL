require 5.006;
use strict;

use ExtUtils::MakeMaker;

WriteMakefile (
  NAME         => 'Term-ProgressBar',
  VERSION      => '2.09',
  AUTHOR       => 'Martyn J. Pearce ',
  ABSTRACT     => 'provide a progress meter on a standard terminal',
  PREREQ_PM    => +{ 
                     'Class::MethodMaker' => '1.02',
                     'Term::ReadKey' => '2.14',},
  EXE_FILES    => [qw(  )],
  # Need this to stop Makefile treating Build.PL as a producer of Build as a
  # target for 'all'.
  PL_FILES     => +{},
  clean        => +{ FILES => join(' ', qw( Build _build )) },
  realclean    => +{ FILES => join(' ', qw( Build.PL META.yml
                                            Makefile.PL
                                            SIGNATURE
                                            README INSTALL
                                            configure make-pm )) },
);
