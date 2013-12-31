#!/usr/bin/perl

BEGIN { push( @INC, "../lib" ); }

use WebService::Belkin::WeMo::Device;
use WebService::Belkin::WeMo::Discover;
use Data::Dumper;
use strict;

my $wemoDiscover = WebService::Belkin::WeMo::Discover->new();
my $discovered = $wemoDiscover->load("/etc/belkin.db");

foreach my $ip (keys %{$discovered}) {
	my $wemo = WebService::Belkin::WeMo::Device->new(ip =>$ip, db => '/etc/belkin.db');
	print "ip = $ip" . " name = " . $wemo->getFriendlyName() . " type = " . $wemo->getType() . "\n";
	$wemo->off();
	
}
