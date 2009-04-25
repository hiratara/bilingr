package BiLingr::Bot;

use MooseX::POE;
use BiLingr::Lingr;
use BiLingr::IRC;
use UNIVERSAL::require;

has parent => (
	isa      => 'BiLingr',
	is       => 'ro',
	required => 1,
);

has rooms => (
	isa     => 'ArrayRef[Object]',
	is      => 'ro',
	default => sub { [] },
);

# POE events ----------------------------------------------
sub START {
	my ( $self ) = @_[OBJECT, ARG0 .. $#_];

	for my $setting( @{$self->parent->rooms} ){
		my $class = 'BiLingr::' . $setting->{protocol};
		$class->require;
		my $room = $class->new(
			%{$setting},
			parent => $self->get_session_id,
		);
		push @{ $self->rooms }, $room;
	}

	$poe_kernel->sig( INT => 'sig_int' );
}


event notify_message => sub {
	my ( $self, $who, $what ) = @_[OBJECT, ARG0 .. $#_];

	my $sender = $_[SENDER];
	for my $room ( @{ $self->rooms } ){
		next if $room->get_session_id == $sender->ID;
		$room->yield('said' => $who, $what);
	}
};


event sig_int => sub {
	my ( $self ) = @_[OBJECT, ARG0 .. $#_];
	for my $room ( @{ $self->rooms } ){
		$room->yield( 'exit_room' );
	}
	$poe_kernel->sig_handled;
};


no  MooseX::POE;
1;
