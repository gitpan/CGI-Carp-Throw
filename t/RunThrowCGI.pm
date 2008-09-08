package RunThrowCGI;

use strict;
use warnings;
use Config;
use Test::More;
use FileHandle;
use File::Spec;
use IPC::Open3;

use Class::Struct map { $_ => '$' } qw(
    output_page trace_comment wo_trace_comment err_output script
);


my $null_dev = File::Spec->devnull;
our $perl_path;

foreach my $perl ($^X, $Config{perlpath}, 'perl') {
    if (length(`$perl -v 2>$null_dev` || '') >= 100) {
        $perl_path = $perl;
        last;
    }
}

sub run_throw_cgi {
    my $self = shift;
    my $script = $self->script( shift );
    
    $self->$_(undef) foreach(
        qw(output_page trace_comment wo_trace_comment err_output)
    );

    local $/ = undef;
    my $page = $self->output_page(`$perl_path -Ilib t/$script 2>$null_dev`);

    $self->trace_comment(
            $page =~ /(<!--\s*CGI::Carp::Throw tracing.*?-->)/s
    );
    
    $page =~ s/<!--\s*CGI::Carp::Throw tracing.*?-->//s;
    $self->wo_trace_comment( $page );
    
    return map { $self->$_ } qw(output_page trace_comment wo_trace_comment);
}

sub run_throw_cgi_w_err {
    no strict 'vars';
    my $self = shift;
    my $script = $self->script( shift );
    
    $self->$_(undef) foreach(
        qw(output_page trace_comment wo_trace_comment err_output)
    );

    local $/ = undef;
    my ($wtr, $rdr);
    my $err = new FileHandle;
    my $pid = open3($wtr, $rdr, $err,
        "$perl_path -Ilib t/$script"
    );
    
    close $wtr;
    my $page = $self->output_page( <$rdr> );
    $self->err_output(<$err>);
    
    waitpid $pid, 0;
    
    $self->trace_comment(
        $self->output_page =~ /(<!--\s*CGI::Carp::Throw tracing.*?-->)/s
    );
    $page =~ s/<!--\s*CGI::Carp::Throw tracing.*?-->//s;
    $self->wo_trace_comment($page);
    
    return map { $self->$_ } qw(output_page trace_comment wo_trace_comment);
}

sub has_trace {
    my $self = shift;

    return ($self->trace_comment || '') =~ /::throw_browser\(/s;
}

sub ok_has_trace {
    my $self = shift;
    
    ok( $self->has_trace, 'found trace in comment from ' . $self->script );    
}

sub has_no_vis_trace {
    my $self = shift;
    
    return $self->wo_trace_comment !~ /\bat\b.*line\s+\d+/s;
}

sub ok_has_no_vis_trace {
    my $self = shift;

    ok( $self->has_no_vis_trace,
        'no trace outside comment in reply body from ' . $self->script
    );    
    
}

1;
