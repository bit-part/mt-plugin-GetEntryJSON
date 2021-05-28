package GetEntryJSON::Plugin;

use strict;
use warnings;

sub plugin {
    return MT->component('GetEntryJSON');
}

sub _log {
    my ($msg) = @_;
    return unless defined($msg);
    my $prefix = sprintf "%s:%s:%s: %s", caller();
    $msg = $prefix . $msg if $prefix;
    use MT::Log;
    my $log = MT::Log->new;
    $log->message($msg) ;
    $log->save or die $log->errstr;
    return;
}

sub get_setting {
    my $plugin = plugin();
    my ($value, $blog_id) = @_;
    my %plugin_param;

    $plugin->load_config(\%plugin_param, 'blog:'.$blog_id);
    my $value = $plugin_param{$value};
    unless ($value) {
        $plugin->load_config(\%plugin_param, 'system');
        $value = $plugin_param{$value};
    }
    $value;
}

1;
