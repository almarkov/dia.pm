#############################################################################

sub wish_to_clarify_demands_for_table_triggers {

	my ($i, $options) = @_;
	
	my ($phase, @events) = split /_/, $i -> {name};

	$i -> {phase} = uc $phase;

	$i -> {prefix} = 'on_';
	if ($i -> {phase} eq 'LAST') {
		$i -> {phase}   = 'AFTER';
		$i -> {prefix} = 'z_';
	}
	
	$i -> {events} = [sort map {uc} @events];

	my $tail = lc (join '_', (
		$i -> {phase}, 
		@{$i -> {events}}, 
		$options -> {table}
	));
	
	length $tail < 61 or $tail = Digest::MD5::md5_hex ($tail);
				
	$i -> {global_name} = $i -> {prefix} . $tail;

}

#############################################################################

sub wish_to_actually_create_table_triggers {

	my ($items, $options) = @_;
		
	foreach my $i (@$items) {
	
		$i -> {body} = qq {
			BEGIN
			$i->{body}
			END;
		} if $i -> {body} !~ /^\s*DECLARE/gism;

		my $events = join ' OR ', @{$i -> {events}};

		foreach my $sql (
		
			qq {
			
				CREATE OR REPLACE FUNCTION $i->{global_name}() RETURNS trigger AS \$$i->{global_name}\$

					$i->{body}

				\$$i->{global_name}\$ LANGUAGE plpgsql;
				
			},

			qq {

				DROP TRIGGER IF EXISTS 
					$i->{global_name}
				ON 
					$options->{table};

			},
			
			qq {

				CREATE TRIGGER 
					$i->{global_name}
				$i->{phase} $events ON 
					$options->{table} 
				FOR EACH ROW EXECUTE PROCEDURE 
					$i->{global_name} ();

			},
			
		) {
		
			$sql =~ s{\s+}{ }gsm;
			$sql =~ s{^ }{};
			$sql =~ s{ $}{};
			
			sql_do ($sql);
		
		}

	
	}

}
