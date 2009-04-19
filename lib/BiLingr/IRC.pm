package BiLingr::IRC;
use MooseX::POE;
use POE qw(Component::IRC);

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
	my ( $self, $who, $where, $what ) = @_[OBJECT, ARG0 .. $#_];

	$poe_kernel->post(
		$self->lingr => said => 
		$who, $what,
	);
};

event said => sub {
	my ( $self, $who, $what ) = @_[OBJECT, ARG0 .. $#_];

	$self->_irc->yield(
		privmsg => $self->channel, "$who: $what",
	);
};


no  MooseX::POE;
1;
