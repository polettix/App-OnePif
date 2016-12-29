requires 'perl',           '5.010';
requires 'Term::ReadLine', '1.14';
requires 'Mo',             '0.40';
requires 'Path::Tiny',     '0.098';

on test => sub {
   requires 'Test::More', '0.88';
};

on develop => sub {
   requires 'Template::Perlish', '1.52';
};
