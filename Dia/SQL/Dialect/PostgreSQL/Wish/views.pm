#############################################################################

sub wish_to_actually_create_views {

	my ($items, $options) = @_;
	
	foreach my $i (@$items) {

		sql_do ("DROP VIEW IF EXISTS $i->{name} CASCADE");

		sql_do ("CREATE VIEW $i->{name} ($i->{columns}) AS $i->{sql}");

	}

}

1;