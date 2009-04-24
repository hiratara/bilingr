package BiLingr;
use Moose;
use Config::Any;
use POE;
use BiLingr::Bot;
our $VERSION = '0.01';

with 'MooseX::ConfigFromFile';

# set default value so that MooseX::ConfigFromFile call get_config_from_file()
has +configfile => (
	default => '',
);

has rooms => (
	is       => 'ro',
	isa      => 'ArrayRef[HashRef]',
	required => 1,
);

# required from MooseX::ConfigFromFile
sub get_config_from_file{
	my( $class, $file ) = @_;

	if (! $file ){
		my $cfg = Config::Any->load_stems({ 
			stems => [ 'bilingr' ],
			use_ext => 1,
		});
		my $first_file = ( keys %{ $cfg->[0] } )[0];
		return $cfg->[0]->{ $first_file } or die "config can't be loaded.";
	}elsif(-f $file) {
		my $cfg = Config::Any->load_files({ 
			files => [ $file ],
			use_ext => 1,
		});
		return $cfg->[0]->{ $file } or die "$file can't be loaded.";
	}

	die "$file does not exists.";
}


sub run {
	my $self = shift;

	BiLingr::Bot->new(parent => $self);

	$poe_kernel->run;
}

__PACKAGE__->meta->make_immutable;
no  Moose;


1;
__END__

=head1 NAME

BiLingr - Simple IRC-Lingr Bridge bot.

=head1 SYNOPSIS

  use BiLingr;

=head1 DESCRIPTION

BiLingr is

=head1 AUTHOR

hiratara E<lt>hiratara@cpan.orgE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
