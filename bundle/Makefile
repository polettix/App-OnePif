1pif: Makefile ../lib/App/OnePif.pm ../script/1pif
	mobundle -PB ../script/1pif -o 1pif \
		-I ../local/lib/perl5 -I ../lib \
		-m Path::Tiny \
		-m Mo -m Mo::default -m Mo::is \
		-m YAML::Tiny \
		-m JSON::PP \
		-m App::OnePif
	chmod +x 1pif

clean::
	rm 1pif

force:: clean 1pif
