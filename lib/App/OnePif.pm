package App::OnePif;
use strict;
use warnings;
{ our $VERSION = '0.001'; }
use English qw( -no_match_vars );
use Carp;

use Mo qw< is default >;
use Path::Tiny;

has file => (
   is      => 'rw',
   lazy    => 1,
   default => sub { 'data.1pif' },
);

has attachments_dir => (
   is => 'rw',
   lazy => 1,
   default => sub {
      my $self = shift;
      Path::Class::file($self->file())->dir()->subdir('attachments')
   },
);

has records => (
   is      => 'rw',
   lazy    => 1,
   default => sub {
      my ($self) = @_;
      my $file = $self->file();
      open my $fh, '<:raw', $file
        or croak "open('$file'): $OS_ERROR";
      my $decoder = $self->JSON_decoder();
      my @records;
      while (<$fh>) {
         my $record = $decoder->($_);
         if (my $attachments = $self->attachments_for($record->{uuid})) {
            $record->{attachments} = $attachments;
         }
         push @records, $record;
         scalar <$fh>;    # drop a line
      }
      return \@records;
   },
);

has records_bytype => (
   is => 'rw',
   lazy => 1,
   default => sub { $_[0]->_records_by('typeName', 'title') },
);

has JSON_decoder => (
   is      => 'rw',
   lazy    => 1,
   default => sub {
      for my $module (qw< JSON JSON::PP >) {
         (my $filename = "$module.pm") =~ s{::}{/}gmxs;
         my $retval = eval {
            require $filename;
            $module->can('decode_json');
         } or next;
         return $retval;
      } ## end for my $module (qw< JSON JSON::PP >)
      return;
   },
);

has YAML_dumper => (
   is      => 'rw',
   lazy    => 1,
   default => sub {
      for my $module (qw< YAML YAML::Tiny >) {
         (my $filename = "$module.pm") =~ s{::}{/}gmxs;
         my $retval = eval {
            require $filename;
            $module->can('Dump');
         } or next;
         return $retval;
      } ## end for my $module (qw< YAML YAML::Tiny >)
      return;
   },
);

has term => (
   is      => 'rw',
   lazy    => 1,
   default => sub {
      return Term::ReadLine->new('1password');
   },
);

has out => (
   is      => 'rw',
   lazy    => 1,
   default => sub {
      my ($self) = @_;
      my $term = $self->term();
      my $out = eval { $term->out() } || \*STDOUT;
      binmode $out, ':encoding(utf8)';
      return $out;
   },
);

has type => (
   is      => 'rw',
   lazy    => 1,
   default => sub { '*' },
);

sub run {
   my ($package, @ARGV) = @_;
   $package->new(args => \@ARGV)->run_interactive();
}

sub run_interactive {
   my ($self) = @_;
   require Term::ReadLine;
   my $term = $self->term();
   my $out  = $self->out();
   while (defined(my $line = $term->readline('1password> '))) {
      my ($command, $rest) = $line =~ m{\A \s* (\S+) \s* (.*?) \s*\z}mxs;
      next unless defined($command) && length($command);
      if (my $cb = $self->can("do_$command")) {
         $self->$cb($rest);
      }
      else {
         print {$out} "ERROR: unknown command [$command]\n",;
      }
   } ## end while (defined(my $line =...
} ## end sub run_interactive

sub attachments_for {
   my ($self, $uuid) = @_;
   my $target = $self->attachments_dir()->subdir($uuid);
   return unless -e $target;
   return [ map { $_->stringify() } $target->children() ];
}

sub clear_records {
   my ($self) = @_;
   delete $self->{records};
   return $self;
}

sub clear_attachments_dir {
   my ($self) = @_;
   delete $self->{attachments_dir};
   return $self;
}

sub do_help {
   my ($self) = @_;
   $self->print(<<'END_OF_HELP');
Available commands:
* quit
   exit the program immediately, exit code is 0
* exit [code]
   exit the program immediately, can accept optional exit code
* file [filename]
   set the filename to use for taking data (default: 'data1.pif')
* types
   show available types and possible aliases
* type [wanted]
   get current default type or set it to wanted. It is possible to
   reset the default type by setting type "*" (no quotes)
* use [wanted]
   alias for type
* list [type]
   get a list for the current set type. By default no type is set
   and the list includes all elements, otherwise it is filtered
   by the wanted type.
   If type parameter is provided, work on specified type instead
   of default one.
* print [ <id> | <type> <id> ]
   show record by provided id (look for ids with the list command).
   It is also possible to specify the type, in which case the id
   is interpreted in the context of the specific type.
END_OF_HELP
}

sub do_quit {
   exit 0;
}

sub do_exit {
   my ($self, $code) = @_;
   exit($code || 0);
}

sub do_file {
   my ($self, $filename) = @_;
   if (defined $filename && length $filename) {
      if ($filename =~ m{\A(['"])(.*)$1\z}mxs) {
         $filename = $2;
      }
      $self->file($filename);
      $self->clear_records();
   } ## end if (defined $filename ...
   else {
      $self->print($self->file());
   }
   return $self;
} ## end sub do_file

sub has_type {
   my ($self) = @_;
   return exists $self->{type};
}

sub clear_type {
   my ($self) = @_;
   delete $self->{type};
   return $self;
}

my %type_for = (
   'passwords.Password'          => 'passwords.Password',
   'securenotes.SecureNote'      => 'securenotes.SecureNote',
   'wallet.computer.License'     => 'wallet.computer.License',
   'webforms.WebForm'            => 'webforms.WebForm',
   'wallet.financial.CreditCard' => 'wallet.financial.CreditCard',
   password                      => 'passwords.Password',
   note                          => 'securenotes.SecureNote',
   license                       => 'wallet.computer.License',
   form                          => 'webforms.WebForm',
   ccard                         => 'wallet.financial.CreditCard',
   passwords                     => 'passwords.Password',
   notes                         => 'securenotes.SecureNote',
   licenses                      => 'wallet.computer.License',
   forms                         => 'webforms.WebForm',
   ccards                        => 'wallet.financial.CreditCard',
   '*' => '*',
);

my %type_aliases_for;

sub do_types {
   my ($self) = @_;
   if (! keys %type_aliases_for) {
      while (my ($k, $v) = each %type_for) {
         my @stuff = sort {
            length($a) <=> length($b)
         } (@{$type_aliases_for{$v} || []}, $k);
         $type_aliases_for{$v} = \@stuff;
      }
   }
   my (%mix);
   my $current = $self->type();
   my $length = 0;
   for my $type (keys %{$self->records_bytype()}) {
      next unless exists $type_aliases_for{$type};
      my ($shorter, @aliases) = @{$type_aliases_for{$type}};
      $current = $shorter if $type eq $current;
      $length = length($shorter)
         if length($shorter) > $length;
      $mix{$shorter} = \@aliases;
   }
   $mix{'*'} = ' (accept any type)';
   my $marker = '<*>';
   my $blanks = ' ' x length $marker;
   for my $type (sort(keys %mix)) {
      my $rest = $mix{$type};
      $rest = " (also: @$rest)" if ref $rest;
      my $indicator = $type eq $current ? $marker : $blanks;
      $self->print(sprintf "%s %${length}s%s", $indicator, $type, $rest);
   }
}

sub real_type {
   my ($self, $type) = @_;
   return $type_for{$type || $self->type()};
}

sub do_type {
   my ($self, $type) = @_;
   if (defined $type && length $type) {
      if (exists $type_for{$type}) {
         $self->type($type);
      }
      else {
         $self->print("unknown type [$type]");
      }
   }
   else {
      $self->print($self->type());
   }
} ## end sub do_type

sub do_use {
   my $self = shift;
   $self->do_type(@_);
}

sub print {
   my $self = shift;
   print {$self->out()} @_, "\n";
}

sub _records_by {
   my ($self, $field, $sorter) = @_;
   my %retval;
   for my $record (@{$self->records()}) {
      my $key = $record->{$field};
      push @{$retval{$key}}, $record;
   }
   if ($sorter) {
      if (! ref $sorter) {
         my $sf = $sorter;
         $sorter = sub { $a->{$sf} cmp $b->{$sf} };
      }
      for my $list (values %retval) {
         @$list = sort { &$sorter } @$list;
      }
   }
   return \%retval;
}

sub do_list {
   my ($self, $type) = @_;
   $type ||= $self->type();
   $type = $self->real_type($type);
   my $records = $self->clipped_records_bytype($type);
   _traverse($records, sub {
      my ($key) = @_;
      $self->print($key) if $type eq '*'; 
   }, sub {
      my ($n, $record) = @_;
      $self->print(sprintf('   %3d %s', $n, $record->{title}));
   });
}

sub do_print {
   my ($self, $rest) = @_;
   my ($type, $n) = split /\s+/, $rest;
   ($type, $n) = ($n, $type) unless defined($n) && $n =~ m{\A\d+\z};
   my $records = $self->clipped_records_bytype($type);
   my $target;
   _traverse($records, undef, sub {
      my ($i, $record) = @_;
      $target = $record if $n == $i;
   });
   $self->print($self->YAML_dumper()->($target));
}

sub clipped_records_bytype {
   my ($self, $type) = @_;
   $type = $self->real_type($type);
   my $records = $self->records_bytype();
   $records = { $type => $records->{$type} }
      unless $type eq '*';
   return $records;
}

sub _traverse {
   my ($hash, $key_callback, $values_callback) = @_;
   my $n = 0;
   for my $key (sort keys %$hash) {
      $key_callback->($key) if $key_callback;
      next unless $values_callback;
      $values_callback->(++$n, $_) for @{$hash->{$key}};
   }
}

1;
