#!/usr/bin/env perl

# $Id: Discover.pm,v 1.1 2012-11-22 01:27:30 ericblue76 Exp $
#
# Author:       Eric Blue - ericblue76@gmail.com
# Project:      Belkin Wemo API
# Url:          http://eric-blue.com/belkin-wemo-api/
#

# ABSTRACT: Uses UPNP to control Belkin Wemo Switches

package WebService::Belkin::WeMo::Discover;
{
  $WebService::Belkin::WeMo::Discover::VERSION = '0.9';
}

use Storable;
use Carp;

use strict;

sub new {

	my $class  = shift;
	my $self   = {};
	my %params = @_;

	bless $self, $class;

	$self->{_discovered} = {};

	$self;

}

sub search {

	my $self = shift;

	my $upnp    = Net::UPnP::ControlPoint->new();
	my @devices = $upnp->search( st => 'upnp:rootdevice', mx => 3 );

	my $discovered;

	foreach my $device (@devices) {
		my $device_type = $device->getdevicetype();
		if ( $device_type =~ /urn:Belkin:device:controllee/ ) {

			my ($ip) =
			  $device->getssdp() =~ /LOCATION: http:\/\/(.*):49153\/setup.xml/;
			$discovered->{$ip} = {
				ip     => $ip,
				name   => $device->getfriendlyname(),
				device => $device
			};

		}
	}
	$self->{_discovered} = $discovered;

	return $discovered;

}

sub save {

	my $self = shift;
	my ($filename) = @_;
	
	store($self->{_discovered}, $filename);

}

sub load {

	my $self = shift;
	my ($filename) = @_;
	
	if (! -e $filename) {
		croak "Can't load device data $filename!\n";
	}
	
	my $loaded = retrieve($filename);
	return $loaded;

}



1;

__END__


=head1 NAME

WebService::Belkin::Wemo::Discover - Discover devices with UPNP

=head1 SYNOPSIS

Sample Usage:

my $wemoDiscover = WebService::Belkin::WeMo::Discover->new();

# Perform UPNP Search for all Belkin WeMo switches
my $discovered = $wemoDiscover->search();

# Save device info to make API calls faster - eliminates search on startup
$wemoDiscover->save("/tmp/belkin.db");

# Load from storage
my $discovered = $wemoDiscover->load("/tmp/belkin.db");

foreach my $ip (keys %{$discovered}) {
	print "IP = $ip\n";
	print "Friendly Name = $discovered->{$ip}->{'name'}\n"
}

=head1 DESCRIPTION

The Belkin WeMo Switch lets you turn electronic devices on or off from anywhere inside--or outside--your home. 
The WeMo Switch uses your existing home Wi-Fi network to provide wireless control of TVs, lamps, stereos, and more. 
This library allows basic control of the switches (turning on/off and getting device info) through UPNP

=head1 METHODS

    * search - Performs UPNP search
    * save - Saves searched devices to disk
    * load - Loads searched devices from disk



=head1 AUTHOR

Eric Blue <ericblue76@gmail.com> - http://eric-blue.com

=head1 COPYRIGHT

Copyright (c) 2012 Eric Blue. This program is free
software; you can redistribute it and/or modify it under the same terms
as Perl itself.

=cut

