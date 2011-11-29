use Module::Build 0.18;

use File::Spec;

my $build = Module::Build->new
  (module_name   => 'Term::ProgressBar',
   dist_version  => '2.09',
   license       => 'perl',
   requires      => {
                     Class::MethodMaker => '1.02',
                     Term::ReadKey      => '2.14',
                    },
  );

$build->create_build_script
