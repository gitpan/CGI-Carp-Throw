#!/usr/bin/perl -w

use strict;
use lib 'lib', 'CGI-Carp-Throw/lib'; # IIS funiness

use CGI qw/:standard/;
use CGI::Carp::Throw qw/:carp_browser cluck/;
#use CGI::Carp::Throw;

print header(), start_html(-title => 'Throw test'), h2("something before");

cluck "really die - not just a <b>message</b>";

print h1('some page'), end_html();
