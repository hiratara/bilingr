package BiLingr::Bot;

use MooseX::POE;
use BiLingr::Lingr;
use BiLingr::IRC;

has parent => (
	isa      => 'BiLingr',
	is       => 'ro',
	required => 1,
);

# POE events ----------------------------------------------
sub START {
	my ( $self ) = @_[OBJECT, ARG0 .. $#_];
	my $lingr = BiLingr::Lingr->new( %{ $self->parent->lingr } );
	my $irc   = BiLingr::IRC->new( %{ $self->parent->irc } );

	$lingr->irc( $irc->get_session_id );
	$irc->lingr( $lingr->get_session_id );
}


no  MooseX::POE;
1;
