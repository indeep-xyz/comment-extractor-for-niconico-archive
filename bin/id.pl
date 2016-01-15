#!/usr/bin/perl

use 5.0080001;
use strict;
use warnings;

use File::Spec;
use File::Basename qw/dirname/;
use lib File::Spec->catdir(dirname(__FILE__), '..', 'lib');

use Getopt::Std;
use File::OpenData::NicoVideo::ThreadExtractor;

my $THREAD_DIR = File::Spec->catdir(
    dirname(__FILE__), '..', 'assets', 'thread');

# - - - - - - - - - - - - - - - - - - -
# command options

my %opts = ();

# getopts
# - d ... directory path of thread
getopts ("d:", \%opts);

# set defaults
$opts{'d'} ||= $THREAD_DIR;

# - - - - - - - - - - - - - - - - - - -
# main

my $file_number = $ARGV[0] || '1';
my $thread = File::OpenData::NicoVideo::ThreadExtractor->new(
    dir => $opts{'d'}
    );

print join("\n",
    $thread->list_ids($file_number));
