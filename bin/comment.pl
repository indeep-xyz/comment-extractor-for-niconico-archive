#!/usr/bin/perl

use 5.0080001;
use strict;
use warnings;
use utf8;

use File::Spec;
use File::Basename qw/dirname/;
use lib File::Spec->catdir(dirname(__FILE__), '..', 'lib');

use Getopt::Std;
use File::NicoNicoLog::ThreadHelper;

my $THREAD_DIR = File::Spec->catdir(
    dirname(__FILE__), '..', 'assets', 'thread');

# - - - - - - - - - - - - - - - - - - -
# command options

my %opts = ();

# getopts
# - c ... extract column ('date', 'no', 'vpos', 'comment', 'command' or none)
# - d ... directory path of assets
# - s ... sort type ('vpos', 'date', 'no', or none)
getopts ('c:d:s:', \%opts);

# set defaults
$opts{'c'} ||= '';
$opts{'d'} ||= $THREAD_DIR;
$opts{'s'} ||= '';

# - - - - - - - - - - - - - - - - - - -
# main

my $id = $ARGV[0] || 'sm10002';
my $thread = File::NicoNicoLog::Thread->new(
    dir  => $opts{'d'},
    id   => $id,
    );

# sort
$thread->sort_by_vpos if ($opts{'s'} eq 'vpos');
$thread->sort_by_date if ($opts{'s'} eq 'date');
$thread->sort_by_no   if ($opts{'s'} eq 'no');

# output
print join("\n", $thread->comments);
