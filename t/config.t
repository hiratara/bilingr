use strict;
use warnings;
use BiLingr;
use Test::More tests => 12;


# default config file is 'bilingr.[ANY]'.
my $b1 = BiLingr->new_with_config();

ok $b1->lingr->{api_key};
ok $b1->lingr->{room};
ok $b1->lingr->{pass};
ok $b1->lingr->{nick};
ok $b1->irc->{server};
ok $b1->irc->{channel};
ok $b1->irc->{key};
ok $b1->irc->{nick};
ok $b1->irc->{charset};


# set config file explicitly
my $b2 = BiLingr->new_with_config( configfile => 't/test.yaml' );

is $b2->lingr->{api_key}, 'api_key';
is $b2->lingr->{room},    'room';
is $b2->lingr->{nick},    'nick';
