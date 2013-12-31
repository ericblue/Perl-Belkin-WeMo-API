#!/usr/bin/perl

BEGIN { push( @INC, "../lib" ); }

use WebService::Belkin::WeMo::Device;
use WebService::Belkin::WeMo::Discover;
use Data::Dumper;
use strict;

my $wemo = WebService::Belkin::WeMo::Device->new(ip => '192.168.2.126', db => '/etc/belkin.db');

print "Name = " . $wemo->getFriendlyName() . "\n";
print "On/Off = " . $wemo->isSwitchOn() . "\n"; 

print "Turning off...\n";
$wemo->off();

sleep(5);

print "Turning on...\n";
$wemo->on();
