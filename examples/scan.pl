#!/usr/bin/perl

BEGIN { push( @INC, "../lib" ); }

use WebService::Belkin::WeMo::Device;
use WebService::Belkin::WeMo::Discover;
use Data::Dumper;
use strict;

$SIG{PIPE} = 'IGNORE';

my $wemoDiscover = WebService::Belkin::WeMo::Discover->new();

# Enable debug to see what's going on with UPNP.
# Note: if running in a VM, make sure bridged networking is enabled not NAT
# $Net::UPnP::DEBUG = 1;
my $discovered = $wemoDiscover->search();

$wemoDiscover->save("/etc/belkin.db");


foreach my $ip (keys %{$discovered}) {
	print "Found $ip\n";
}
