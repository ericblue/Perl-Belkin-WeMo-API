#!/usr/bin/env perl

# $Id: Device.pm,v 1.1 2012-11-22 01:27:30 ericblue76 Exp $
#
# Author:       Eric Blue - ericblue76@gmail.com
# Project:      Belkin Wemo API
# Url:          http://eric-blue.com/belkin-wemo-api/
#

# ABSTRACT: Uses UPNP to control Belkin Wemo Switches

package WebService::Belkin::WeMo::Device;
{
  $WebService::Belkin::WeMo::Device::VERSION = '0.9';
}

use Data::Dumper;
use Net::UPnP::ControlPoint;
use Carp;

use strict;

sub new {

	my $class  = shift;
	my $self   = {};
	my %params = @_;

	if ( !defined $params{'ip'} ) {
		croak("IP is a required field!");
	}

	$self->{'_ip'} = $params{'ip'};

	my $wemoDiscover = WebService::Belkin::WeMo::Discover->new();
	my $discovered;
	if ( defined $params{'db'} ) {
		$discovered = $wemoDiscover->load("/tmp/belkin.db");
	}
	else {
		$discovered = $wemoDiscover->search();
	}

	if ( !defined $discovered->{ $self->{'_ip'} } ) {
		croak "IP not found - try running another discovery search!";
	}

	$self->{_device} = $discovered->{ $self->{'_ip'} }->{'device'};

	# Load service - only basic is here for now, others will be supported later
	foreach my $service ( $self->{_device}->getservicelist() ) {

		if ( $service->getservicetype() =~ /urn:Belkin:service:basicevent:1/ ) {
			$self->{_basicService} = $service;
		}
	}

	bless $self, $class;

	$self;

}

sub getFriendlyName() {

	my $self = shift;

	my $resp = $self->{_basicService}->postaction("GetFriendlyName");
	if ( $resp->getstatuscode() == 200 ) {
		return $resp->getargumentlist()->{'FriendlyName'};
	}
	else {
		croak "Got status code " . $resp->getstatuscode() . "!\n";
	}

}

sub isSwitchOn() {

	my $self = shift;

	my $resp = $self->{_basicService}->postaction("GetBinaryState");
	if ( $resp->getstatuscode() == 200 ) {
		return $resp->getargumentlist()->{'BinaryState'};
	}
	else {
		croak "Got status code " . $resp->getstatuscode() . "!\n";
	}

}

sub toggleSwitch() {

	my $self = shift;

	my $state  = $self->isSwitchOn();
	my $toggle = $state ^= 1;
	
	$self->on() if $toggle == 1;
	$self->off() if $toggle == 0;

}

sub on() {

	my $self = shift;

	my $resp   = $self->{_basicService}->postaction( "SetBinaryState", { BinaryState => 1 } );
	if ( $resp->getstatuscode() == 200 ) {
		# Not this will be Error if the switch is already on
		return $resp->getargumentlist()->{'BinaryState'};
	}
	else {
		croak "Got status code " . $resp->getstatuscode() . "!\n";
	}

}

sub off() {

	my $self = shift;

	my $resp   = $self->{_basicService}->postaction( "SetBinaryState", { BinaryState => 0 } );
	if ( $resp->getstatuscode() == 200 ) {
		# Not this will be Error if the switch is already off
		return $resp->getargumentlist()->{'BinaryState'};
	}
	else {
		croak "Got status code " . $resp->getstatuscode() . "!\n";
	}

}

1;

__END__


=head1 NAME

WebService::Belkin::Wemo::Device - Device class for controlling Wemo Switches
=head1 SYNOPSIS

Sample Usage:

my $wemo = WebService::Belkin::WeMo::Device->new(ip => '192.168.2.126', db => '/tmp/belkin.db');

print "Name = " . $wemo->getFriendlyName() . "\n";
print "On/Off = " . $wemo->isSwitchOn() . "\n"; 

print "Turning off...\n";
$wemo->off();

print "Turning on...\n";
$wemo->on();
=head1 DESCRIPTION

The Belkin WeMo Switch lets you turn electronic devices on or off from anywhere inside--or outside--your home. 
The WeMo Switch uses your existing home Wi-Fi network to provide wireless control of TVs, lamps, stereos, and more. 
This library allows basic control of the switches (turning on/off and getting device info) through UPNP

=head1 METHODS

    * getFriendlyName - Get the name of the switch
    * on - Turn switch on
    * off - Turn switch off
    * toggle - Toggle switch on/off



=head1 AUTHOR

Eric Blue <ericblue76@gmail.com> - http://eric-blue.com

=head1 COPYRIGHT

Copyright (c) 2012 Eric Blue. This program is free
software; you can redistribute it and/or modify it under the same terms
as Perl itself.

=cut


