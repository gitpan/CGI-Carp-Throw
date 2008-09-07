#!/usr/bin/perl -w

use strict;
use lib 'lib', 'CGI-Carp-Throw/lib'; # IIS funiness

use CGI qw/:standard/;
use CGI::Carp::Throw qw/name=wo_browser/;

print header(), start_html(-title => 'Throw test'), h2("something before");

my $die_param = param('die') || '';
if ($die_param eq 'die') {
    die "really die - not just a <b>message</b>";
}
elsif ($die_param eq 'throw') {
    throw_browser 'just a browser message';
}
else {
    croak "really croak - not just a <b>message</b>";
}

print h1('some page'), end_html();
