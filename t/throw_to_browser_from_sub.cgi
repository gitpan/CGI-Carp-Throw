#!/usr/bin/perl -w

use strict;
use lib 'lib', 'CGI-Carp-Throw/lib'; # IIS funiness

use CGI qw/:standard/;
use CGI::Carp::Throw qw/:carp_browser/;

sub look_for_sub_in_trace {
    throw_browser("quick <b>and</b> easy but no prep");
}

look_for_sub_in_trace;
