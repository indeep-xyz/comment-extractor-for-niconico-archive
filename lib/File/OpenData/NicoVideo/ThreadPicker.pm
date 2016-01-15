# *-* encoding: utf8 *-*

package File::OpenData::NicoVideo::ThreadPicker;

use 5.0080001;
use strict;
use warnings;
use utf8;

use Archive::Tar;

our $VERSION = "0.2.0";

# = = = = = = = = = = = = = = = = = = = = =
# public methods

sub new {
  my $class = shift;
  my $self = {
      dir => '.',
      @_
      };

  bless($self, $class);
}

# = = = = = = = = = = = = = = = = = = = = =
# public methods (get thread)

# args
#   $_[1] .. video id
# ret
#   raw string of a video thread
sub thread {
  my $self        = shift;
  my ($archive, $inner) = $self->_make_pathes(shift);

  $self->_check_tar_command
      ? Archive::Tar->new($archive)->get_content($inner)
      : `tar -xOf "$archive" "$inner"`;
}

# ret
#   raw string of a video thread
sub random_thread {
  $_[0]->thread($_[0]->random_id);
}

# = = = = = = = = = = = = = = = = = = = = =
# public methods (get video id, file number, etc..)

# ret
#   code number of archive file
sub random_file_number {
  my $self = shift;
  my @file_numbers = $self->list_archive_file_numbers;

  $file_numbers[rand @file_numbers];
}

# ret
#   path of archive file
sub random_file_path {
  my $self = shift;
  my $file_number = $self->random_file_number;

  $self->_make_archive_path($file_number);
}

# args
#   $_[1] .. code number of archive file (not require)
# ret
#   video id
sub random_id {
  my $self        = shift;
  my $file_number = shift || $self->random_file_number;
  my @ids         = $self->list_ids($file_number);

  $ids[rand @ids];
}

# ret
#   array of archive file names
sub list_archive_file_names {
  my $self       = shift;
  my $pattern    = File::Spec->catfile($self->{dir}, '*.tar.gz');
  my @file_names = ();

  for (glob(sprintf('"%s"', $pattern))) {
    if ($_ =~ s!$self->{dir}/!!) {
      push(@file_names, $_);
    }
  }

  @file_names;
}

# ret
#   array of archive file numbers
sub list_archive_file_numbers {
  my $self         = shift;
  my @file_names   = $self->list_archive_file_names;
  my @file_numbers = ();

  for (@file_names) {
    if ($_ =~ s/\.tar\.gz$//) {
      push(@file_numbers, $_ + 0);
    }
  }

  @file_numbers;
}

# args
#   $_[1] .. code number of archive file
# ret
#   array of file names in the archive file
sub list_files {
  my $self = shift;
  my $path = $self->_make_archive_path(shift);

  $self->_check_tar_command
      ? Archive::Tar->list_archive($path)
      : split("\n", `tar -tf "$path"`);
}

# args
#   $_[1] .. code number of archive file
# ret
#   array of video IDs
sub list_ids {
  my $self      = shift;
  my @list      = $self->list_files(shift);
  my @threads   = ();

  foreach (@list) {
    if ($_ =~ s|^.+/(.+)\.dat|$1|) {
      push(@threads, $_);
    }
  }

  @threads;
}

# = = = = = = = = = = = = = = = = = = = = =
# private methods

# args
#   $_[1] .. code number of archive file
# ret
#   array
#     path of archive file
#     path in archive file
sub _make_pathes {
  my $self = shift;
  my $id   = shift;
  my $file_number = $self->_make_file_number($id);

  (
      $self->_make_archive_path($file_number),
      $self->_make_inner_path($file_number, $id),
      );
}

# args
#   $_[1] .. code number of archive file
# ret
#   path of archive file
sub _make_archive_path {
  my $self = shift;
  my $file_number = shift;

  File::Spec->catfile($self->{dir},
      sprintf('%04d.tar.gz', $file_number));
}

# args
#   $_[1] .. code number of archive file
#   $_[2] .. video id
# ret
#   path in archive file
sub _make_inner_path {
  sprintf('%04s/%s.dat', $_[1], $_[2]);
}

# args
#   $_[1] .. video id
# ret
#   code number of archive file
sub _make_file_number {
  my $self = shift;
  my $num  = $self->_extract_numeral_from_id(shift);

  if ($num !~ s/^(\d+)\d{4}$/$1/) {
    $num = 0;
  }

  $num;
}

# args
#   $_[1] .. video id
# ret
#   numeral characters of video id
sub _extract_numeral_from_id {
  my $self = shift;
  my $id   = shift;

  if ($id !~ /^(sm|nm)\d+/) {
    die "\"$id\" is not in the format of video ID.";
  }

  substr($id, 2);
}

# = = = = = = = = = = = = = = = = = = = = =
# private methods (other)

# Check if tar command is available in system
# The command tool is faster than Archive::Tar module
#
# ret
#   true if the command is available, else false
sub _check_tar_command {
  system "which tar > /dev/null";
}
