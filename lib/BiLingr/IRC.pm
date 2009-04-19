package BiLingr::IRC;
use MooseX::POE;
use POE qw(Component::IRC);
use Encode;

has server => (
	isa      => 'Str',
	is       => 'ro',
	required => 1,
);

has nick => (
	isa      => 'Str',
	is       => 'ro',
	default  => 'bilingr_irc',
);

has channel => (
	isa      => 'Str',
	is       => 'ro',
	required => 1,
);

has charset => (
	isa      => 'Str',
	is       => 'ro',
	default  => 'utf8',
);

has lingr => (
	isa        => 'Int',
	is         => 'rw',
);

has _irc => (
	isa        => 'POE::Component::IRC',
	is         => 'rw',
);


# POE events ----------------------------------------------
sub START {
	my ( $self ) = @_[OBJECT, ARG0 .. $#_];
	my $irc = POE::Component::IRC->spawn( 
		nick    => $self->nick,
		# ircname => $self->nick,
		server  => $self->server,
	);

	$irc->yield( register => 'all' );
	$irc->yield( connect  => {} );

	$self->_irc( $irc );
}

event irc_001 => sub {
	my ( $self ) = @_[OBJECT, ARG0 .. $#_];
	$self->_irc->yield( join => $self->channel );
};

event irc_public => sub {
	my ( $self, $who_where, $channel, $what ) = @_[OBJECT, ARG0 .. $#_];

	my ($who, $where) = split /!/, $who_where, 2;

	$poe_kernel->post(
		$self->lingr => said => 
		$who, Encode::decode($self->charset, $what),
	);
};

event said => sub {
	my ( $self, $who, $what ) = @_[OBJECT, ARG0 .. $#_];

	my $enc_who  = Encode::encode($self->charset, $who );
	my $enc_what = Encode::encode($self->charset, $what);

	$self->_irc->yield(
		privmsg => $self->channel, "$enc_who: $enc_what",
	);
};


no  MooseX::POE;
1;
