# *-* encoding: utf8 *-*

package File::NicoNicoLog::ThreadExtractor;

use 5.0080001;
use strict;
use warnings;
use utf8;

use Archive::Tar;

our $VERSION = "0.1";

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

# args
#   $_[1] .. video id
sub thread {
  my $self       = shift;
  my $id         = shift;
  my $num        = $self->_make_number_from_id($id);
  my $path_file  = $self->_make_path_from_number($num);
  my $path_inner = sprintf('%04s/%s.dat', $num, $id);

  $self->_check_tar_command
      ? Archive::Tar->new($path_file)->get_content($path_inner)
      : `tar -xOf "$path_file" "$path_inner"`;
}

# args
#   $_[1] .. number of archive files
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

# args
#   $_[1] .. number of thread archive file
sub list_files {
  my $self = shift;
  my $num  = shift;
  my $path = $self->_make_path_from_number($num);

  $self->_check_tar_command
      ? Archive::Tar->list_archive($path)
      : split("\n", `tar -tf "$path"`);
}

# = = = = = = = = = = = = = = = = = = = = =
# private methods

# args
#   $_[1] .. number of thread archive file
sub _make_path_from_number {
  my $self     = shift;
  my $filename = $self->_make_filename_from_number(shift);

  File::Spec->catfile(
      $self->{dir}, $filename);
}
# args
#   $_[1] .. number of thread archive file
sub _make_filename_from_number {
  sprintf("%04d.tar.gz", $_[1]);
}

sub _make_number_from_id {
  my $self = shift;
  my $id   = shift;

  if ($id !~ /^(sm|nm)\d+/) {
    die "\"$id\" is not the format of video ID.";
  }

  if ($id !~ s/^\D{2}(\d+)\d{4}$/$1/) {
    $id = 0;
  }

  $id;
}

# = = = = = = = = = = = = = = = = = = = = =
# private methods (other)

# Check if tar command is available in system
# The command tool is faster than Archive::Tar module
sub _check_tar_command {
  system "which tar > /dev/null";
}
