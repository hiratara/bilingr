package BiLingr::IRC;
use MooseX::POE;
use POE qw(Component::IRC);
use Encode;

has server => (
	isa      => 'Str',
	is       => 'ro',
	required => 1,
);

has port => (
	isa      => 'Str',
	is       => 'ro',
);

has password => (
	isa      => 'Str',
	is       => 'ro',
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

has key => (
	isa      => 'Str',
	is       => 'ro',
);

has charset => (
	isa      => 'Str',
	is       => 'ro',
	default  => 'utf8',
);

has parent => (
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
		nick     => $self->nick,
		# ircname => $self->nick,
		server   => $self->server,
		port     => $self->port,
		password => $self->password,
	);

	$irc->yield( register => 'all' );
	$irc->yield( connect  => {} );

	$self->_irc( $irc );
}

event irc_001 => sub {
	my ( $self ) = @_[OBJECT, ARG0 .. $#_];

	my $channel = $self->channel;
	$channel .= ' ' . $self->key if $self->key;

	$self->_irc->yield( join => $channel );
};

event irc_public => sub {
	my ( $self, $who_where, $channel, $what ) = @_[OBJECT, ARG0 .. $#_];

	my ($who, $where) = split /!/, $who_where, 2;

	$poe_kernel->post(
		$self->parent => notify_message => 
		$who, Encode::decode($self->charset, $what),
	);
};

event said => sub {
	my ( $self, $who, $what ) = @_[OBJECT, ARG0 .. $#_];

	my $enc_who  = Encode::encode($self->charset, $who );
	my $enc_what = Encode::encode($self->charset, $what);

	$self->_irc->yield(
		notice => $self->channel, "$enc_who: $enc_what",
	);
};


event exit_room => sub {
	my ( $self ) = @_[OBJECT, ARG0 .. $#_];
	$self->_irc->yield( 'shutdown' );
};


no  MooseX::POE;
1;
