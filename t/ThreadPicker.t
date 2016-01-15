#!/usr/bin/perl

use 5.0080001;
use strict;
use warnings;
use utf8;

use File::Spec;
use File::Basename qw/dirname/;
use lib File::Spec->catdir(dirname(__FILE__), '..', 'lib');
use File::OpenData::NicoVideo::Thread;

use Test::Simple tests => 6;

my $THREAD_DIR = File::Spec->catdir(
    dirname(__FILE__), '..', 'assets', 'thread');

# = = = = = = = = = = = = = = = = = = = = =
# functions

sub first_line {
  (split(/[\n\r]+/, $_[0]))[0];
}

# ret
#   true if the method is randomable, else false
sub check_random {
  my $instance = shift;
  my $method   = shift;
  my $size     = shift || 3;
  my @array = ();

  for (my $i = 0; $i < $size; $i++) {
    push(@array, $instance->$method)
  }

  scalar @array == scalar uniq(sort @array);
}

sub uniq{
    my @array = @_;
    my %hash = map{$_, 1} @array;

    keys %hash;
}

# = = = = = = = = = = = = = = = = = = = = =
# tasks

my $picker = File::OpenData::NicoVideo::ThreadPicker->new(
    dir => $THREAD_DIR
    );

ok(($picker->list_files('0001'))[0] eq '0001/',
    '$picker->list_files');

ok(($picker->list_ids('0001'))[0] eq 'sm14759',
    '$picker->list_ids');

{
  my $line = first_line($picker->thread('sm10002'));
  my $sample_line = '{"date":1173247452,"no":1,"vpos":2153,"comment":"\u2191\u5973\u306e\u5b50","command":"shita pink"}';

  ok($line eq $sample_line, '$picker->thread');
}

ok(check_random($picker, 'random_id', 3),
    '$picker->random_id');

ok(check_random($picker, 'random_file_number', 3),
    '$picker->random_file_number');

ok(check_random($picker, 'random_file_path', 3),
    '$picker->random_file_path');



