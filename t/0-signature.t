#!/usr/bin/perl
use strict;
use warnings;

use Test::More;

plan skip_all => 'Signature has not been updated';


if ( ! eval { require Module::Signature; 1 } ) {
  plan skip_all => 'Needs Module::Signature to verify the integrity of this distribution.';
} elsif ( ! eval { require Socket; Socket::inet_aton('pgp.mit.edu') } ) {
  plan skip_all => 'Cannot connect to the keyserver';
} else {
  plan tests => 1;
  is Module::Signature::verify(), Module::Signature::SIGNATURE_OK(), 'Valid signature';
}

