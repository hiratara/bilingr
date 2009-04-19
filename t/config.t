use strict;
use warnings;
use BiLingr;
use Test::More tests => 6;


# default config file is 'bilingr.[ANY]'.
my $b1 = BiLingr->new_with_config();

is $b1->lingr->{api_key}, 'API_KEY';
is $b1->lingr->{room},    'ROOM';
is $b1->lingr->{nick},    'NICK';


# set config file explicitly
my $b2 = BiLingr->new_with_config( configfile => 't/test.yaml' );

is $b2->lingr->{api_key}, 'api_key';
is $b2->lingr->{room},    'room';
is $b2->lingr->{nick},    'nick';
