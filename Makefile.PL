require 5.006;
use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile (
  NAME         => 'Term::ProgressBar',
  VERSION_FROM => 'lib/Term/ProgressBar.pm',
  ABSTRACT_FROM => 'lib/Term/ProgressBar.pm',
  AUTHOR       => 'Martyn J. Pearce',
  LICENSE      => 'perl',
  PREREQ_PM    => { 
    'Class::MethodMaker' => '1.02',
    'Term::ReadKey' => '2.14',

    'Carp'  => 0,
    'Fatal' => 0,
    'POSIX' => 0,
  },
  BUILD_REQUIRES => {
                     'Capture::Tiny' => '0.13',
                     'Test::More'    => '0.80',
                     'Test::Exception' => '0.31',
                     'File::Temp'    => 0,
  },
  META_MERGE        => {
       resources => {
           repository  =>  'https://github.com/szabgab/Term-ProgressBar',
       },
  },
);
