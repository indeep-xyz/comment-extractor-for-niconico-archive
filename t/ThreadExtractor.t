#!/usr/bin/perl

use 5.0080001;
use strict;
use warnings;
use utf8;

use File::Spec;
use File::Basename qw/dirname/;
use lib File::Spec->catdir(dirname(__FILE__), '..', 'lib');
use File::NicoNicoLog::Thread;

use Test::Simple tests => 3;

my $THREAD_DIR = File::Spec->catdir(
    dirname(__FILE__), '..', 'assets', 'thread');

# = = = = = = = = = = = = = = = = = = = = =
# functions

sub first_line {
  (split(/[\n\r]+/, $_[0]))[0];
}

# = = = = = = = = = = = = = = = = = = = = =
# tasks

my $ex = File::NicoNicoLog::ThreadExtractor->new(
    dir => $THREAD_DIR
    );

ok(($ex->list_files('0001'))[0] eq '0001/',
    '$instance->list_files');

ok(($ex->list_ids('0001'))[0] eq 'sm14759',
    '$instance->list_ids');

{
  my $line = first_line($ex->thread('sm10002'));
  my $sample_line = '{"date":1173247452,"no":1,"vpos":2153,"comment":"\u2191\u5973\u306e\u5b50","command":"shita pink"}';

  ok($line eq $sample_line, '$instance->thread');
}

