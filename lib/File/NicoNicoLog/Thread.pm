# *-* encoding: utf8 *-*

package File::NicoNicoLog::Thread;

use 5.0080001;
use strict;
use warnings;
use utf8;

use JSON::PP;
use File::NicoNicoLog::ThreadExtractor;

our $VERSION = "0.1";
our @JSON_KEY_ORDER = qw/date no vpos comment command/;

# = = = = = = = = = = = = = = = = = = = = =
# public methods

sub new {
  my $class = shift;
  my $self = {
      dir    => '.',
      id     => undef,
      object => undef,
      raw    => undef,
      @_
      };

  bless($self, $class);
}

# = = = = = = = = = = = = = = = = = = = = =
# public methods (get)

sub comments {
  my $self     = shift;
  my $object   = $self->object;
  my @comments = ();

  for (@$object) {
    push(@comments, $$_{comment});
  }

  @comments;
}

sub object {
  my $self   = shift;

  $self->_init_object unless ($self->{object});
  $self->{object};
}

sub raw {
  my $self   = shift;

  $self->_init_raw unless ($self->{raw});
  $self->{raw};
}

# Get JSON string
sub json {
  my $self   = shift;
  my $object = $self->object;

  encode_json($object);
}

# Get JSON string formated like the original data.
sub json_originally {
  my $self   = shift;
  my $object = $self->object;
  my $text   = '';

  for (@$object) {
    $text .= sprintf("%s\n", $self->_make_json(\%$_));
  }

  $text;
}

# = = = = = = = = = = = = = = = = = = = = =
# public methods (update)

sub sort_by_date {
  $_[0]->_sort('date');
  $_[0]
}

sub sort_by_no {
  $_[0]->_sort('no');
  $_[0]
}

sub sort_by_vpos {
  $_[0]->_sort('vpos');
  $_[0]
}

# = = = = = = = = = = = = = = = = = = = = =
# private methods (update object)

# Initialize my own object data
sub _init_object {
  my $self   = shift;
  my @object = ();

  for (split("\n", $self->raw)) {
    push(@object, decode_json($_));
  }

  $self->{object} = \@object;
}

sub _sort {
  my $self   = shift;
  my $key    = shift;
  my $object = $self->object;

  @$object = sort { $a->{$key} <=> $b->{$key} } @$object;

  $self->{object} = $object;
}

# = = = = = = = = = = = = = = = = = = = = =
# private methods (update raw)

sub _init_raw {
  my $self = shift;
  my $id   = $self->{id};
  my $extractor = File::NicoNicoLog::ThreadExtractor->new(
      dir => $self->{dir});

  $self->{raw} = $extractor->thread($id);
}

# = = = = = = = = = = = = = = = = = = = = =
# private methods (other)

# Make JSON string in the same style
# as the original data
sub _make_json {
  my $self = shift;
  my $hash = shift;
  my $json = JSON::PP->new;
  my $str  = '{';

  foreach my $key (@JSON_KEY_ORDER) {
    my $val = ($key =~ /comment|command/)
        ? $json->string_to_json($$hash{$key})
        : $$hash{$key};

    $str .= sprintf('%s:%s,',
        $json->string_to_json($key),
        $val);
  }

  substr($str, 0, -1) . '}';
}
