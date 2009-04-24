use strict;
use warnings;
use BiLingr;
use Test::More tests => 13;

{
# default config file is 'bilingr.[ANY]'.
	my $b1 = BiLingr->new_with_config();
	my $lingr = $b1->rooms->[0];
	my $irc   = $b1->rooms->[1];

	ok $lingr->{api_key};
	ok $lingr->{room};
	ok $lingr->{pass};
	ok $lingr->{nick};
	ok $irc->{server};
	ok $irc->{channel};
	ok $irc->{key};
	ok $irc->{nick};
	ok $irc->{charset};
}

{
	# set config file explicitly
	my $b2 = BiLingr->new_with_config( configfile => 't/test.yaml' );
	my $lingr = $b2->rooms->[0];

	is $lingr->{protocol}, 'Lingr';
	is $lingr->{api_key}, 'api_key';
	is $lingr->{room},    'room';
	is $lingr->{nick},    'nick';
}
