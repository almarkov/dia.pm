################################################################################

sub select__logout {

	sql_do ("DELETE FROM $conf->{systables}->{__access_log} WHERE id_session = ?", $_REQUEST {sid}) if ($conf -> {core_auto_esc} == 2);

	sql_do ("DELETE FROM $conf->{systables}->{sessions} WHERE id = ?", $_REQUEST {sid});

	redirect ('/?type=logon', {kind => 'js', target => '_top', label => $i18n -> {session_terminated}});

}

1;