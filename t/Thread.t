#!/usr/bin/perl

use 5.0080001;
use strict;
use warnings;
use utf8;

use File::Spec;
use File::Basename qw/dirname/;
use lib File::Spec->catdir(dirname(__FILE__), '..', 'lib');
use Storable qw/dclone/;
use File::NicoNicoLog::Thread;

use Test::Simple tests => 5;

my $THREAD_DIR = File::Spec->catdir(
    dirname(__FILE__), '..', 'assets', 'thread');

# = = = = = = = = = = = = = = = = = = = = =
# functions

sub first_line {
  (split(/[\n\r]+/, $_[0]))[0];
}

sub compare_head {
  my $hay = shift;
  my $needle = shift;

  substr($hay, 0, length($needle)) eq $needle;
}

# = = = = = = = = = = = = = = = = = = = = =
# tasks

my $thread = File::NicoNicoLog::Thread->new(
    dir => $THREAD_DIR,
    id  => 'sm10002',
    );

{
  my $line = first_line($thread->json_originally);
  my $sample_line = '{"date":1173247452,"no":1,"vpos":2153,"comment":"↑女の子","command":"shita pink"}';

  ok($line eq $sample_line, '$thread->json_originally');
}

{
  my $th = dclone($thread);
  my $line = first_line($th->sort_by_vpos->json_originally);
  my $sample_line = '{"date":1174270531,"no":28,"vpos":3,"comment":"盛り上がるよ","command":""}';

  ok($line eq $sample_line, '$thread->json_originally (sort by vpos column)');
}

{
  my $th = dclone($thread);
  my $json = first_line($th->json);
  my $sample_head = '[{"';

  ok(compare_head($json, $sample_head), '$thread->json');
}

{
  my $th = dclone($thread);
  my $hash = @{$th->object}[0];

  ok($hash->{date} == 1173247452, '$thread->object');
}

{
  my $th = dclone($thread);
  my $hash = @{$th->sort_by_vpos->object}[0];

  ok($hash->{date} == 1174270531, '$thread->object (sort by vpos column)');
}
