#!/usr/bin/perl

use 5.0080001;
use strict;
use warnings;
use utf8;

use File::Spec;
use File::Basename qw/dirname/;
use lib File::Spec->catdir(dirname(__FILE__), '..', 'lib');

use Getopt::Std;
use File::OpenData::NicoVideo::Thread;

my $THREAD_DIR = File::Spec->catdir(
    dirname(__FILE__), '..', 'assets', 'thread');

# - - - - - - - - - - - - - - - - - - -
# command options

my %opts = ();

# getopts
# - d ... directory path of assets
# - f ... output format ('json', 'jsonlines', 'raw')
# - s ... sort type ('vpos', 'date', 'no')
getopts ('d:f:s:', \%opts);

# set defaults
$opts{'d'} ||= $THREAD_DIR;
$opts{'f'} ||= 'jsonlines';
$opts{'s'} ||= '';

# - - - - - - - - - - - - - - - - - - -
# main

my $id = $ARGV[0] || 'sm10002';
my $thread = File::OpenData::NicoVideo::Thread->new(
    dir  => $opts{'d'},
    id   => $id,
    );

# sort
$thread->sort_by_vpos if ($opts{'s'} eq 'vpos');
$thread->sort_by_date if ($opts{'s'} eq 'date');
$thread->sort_by_no   if ($opts{'s'} eq 'no');

# output
if ($opts{'f'} eq 'raw') {
  print $thread->raw;
}
elsif ($opts{'f'} eq 'json') {
  print $thread->json;
}
else {
  print $thread->json_originally;
}
