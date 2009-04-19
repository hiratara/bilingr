use inc::Module::Install;
name 'BiLingr';
all_from 'lib/BiLingr.pm';

requires 'Config::Any'              => '0.07';
requires 'MooseX::POE'              => '0.1';
requires 'MooseX::Getopt'           => '0.15';
requires 'MooseX::ConfigFromFile'   => '0.02';
requires 'POE::Component::Client::Lingr' => '0.04_01';
requires 'POE::Component::IRC'      => '6.04';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
