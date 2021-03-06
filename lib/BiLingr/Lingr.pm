package BiLingr::Lingr;
use MooseX::POE;
use POE qw(Component::Client::Lingr);

has api_key => (
	isa      => 'Str',
	is       => 'ro',
	required => 1,
);

has room => (
	isa      => 'Str',
	is       => 'ro',
	required => 1,
);

has pass => (
	isa      => 'Str',
	is       => 'ro',
);

has nick => (
	isa      => 'Str',
	is       => 'ro',
	default  => __PACKAGE__,
);

has irc => (
	isa        => 'Int',
	is         => 'rw',
);

has parent => (
	isa        => 'Int',
	is         => 'rw',
);

has _lingr => (
	isa        => 'Str',
	is         => 'ro',
	lazy_build => 1,
);

sub _build__lingr{
	my $self = shift;
	return 'lingr' . ($self + 0);
}


# POE events ----------------------------------------------
sub START {
	my ( $self ) = @_[OBJECT, ARG0 .. $#_];
	POE::Component::Client::Lingr->spawn(alias => $self->_lingr);
	$poe_kernel->post( $self->_lingr => 'register' );
	$poe_kernel->post(
		$self->_lingr => call => 
		'session.create', { api_key => $self->api_key }
	);
}

event 'lingr.session.create' => sub {
	my ( $self, $event ) = @_[OBJECT, ARG0 .. $#_];
	$poe_kernel->call(
		$self->_lingr => call => 
		'room.enter', { 
			id       => $self->room, nickname => $self->nick,
			password => $self->pass,
		}
	);
};

event 'lingr.room.enter' => sub {
	my ( $self, $event ) = @_[OBJECT, ARG0 .. $#_];
};

event 'lingr.room.observe' => sub {
	my ( $self, $event ) = @_[OBJECT, ARG0 .. $#_];
	for my $msg (@{ $event->{messages} || []}){
		next unless $msg->{client_type} eq 'human';
		$poe_kernel->post(
			$self->parent => notify_message => 
			$msg->{nickname}, $msg->{text},
		);
	}
};

event said => sub {
	my ( $self, $who, $what ) = @_[OBJECT, ARG0 .. $#_];

	$poe_kernel->post(
		$self->_lingr => call => 
		'room.say', { message => "$who: $what" }
	);
};

# for DEBUG ==================
use Data::Dumper;
event 'lingr.error.http' => sub {
	my ( $self, $event ) = @_[OBJECT, ARG0 .. $#_];
	warn Dumper($event);
};

event 'lingr.error.response' => sub {
	my ( $self, $event ) = @_[OBJECT, ARG0 .. $#_];
	die Dumper($event);
};

event exit_room => sub {
	my ( $self ) = @_[OBJECT, ARG0 .. $#_];

	$poe_kernel->post(
		$self->_lingr => 'call' => 
		'room.exit', {},
	);
};

event 'lingr.room.exit' => sub {
	my ( $self ) = @_[OBJECT, ARG0 .. $#_];

	$poe_kernel->post( $self->_lingr => 'unregister' );
	# TODO: Not clean exit. Observer process make an invalid request 
	#       after exit.
	#       (If ticket error is occured, the observer will be stopped.)
};


no  MooseX::POE;
1;
