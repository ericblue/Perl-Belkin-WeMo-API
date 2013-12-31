#!/usr/bin/env perl

# $Id: Device.pm,v 1.4 2013-12-31 03:29:22 ericblue76 Exp $
#
# Author:       Eric Blue - ericblue76@gmail.com
# Project:      Belkin Wemo API
# Url:          http://eric-blue.com/belkin-wemo-api/
#

# ABSTRACT: Uses UPNP to control Belkin Wemo Switches

package WebService::Belkin::WeMo::Device;

use Data::Dumper;
use Net::UPnP::ControlPoint;
use Carp;

use strict;

sub new {

	my $class  = shift;
	my $self   = {};
	my %params = @_;

	if ( ( !defined $params{'ip'} ) && ( !defined $params{'name'} ) ) {
		croak("Insufficient parameters: ip or name are required!");
	}

	$self->{'_ip'}   = $params{'ip'};
	$self->{'_name'} = $params{'name'};
	$self->{'_db'}   = $params{'db'};

	my $wemoDiscover = WebService::Belkin::WeMo::Discover->new();
	my $discovered;
	if ( defined $params{'db'} ) {
		$discovered = $wemoDiscover->load($params{'db'});
	}
	else {
		$discovered = $wemoDiscover->search();
	}

	if ( defined( $params{'ip'} ) ) {
		if ( !defined $discovered->{ $self->{'_ip'} } ) {
			croak "IP not found - try running another discovery search!";
		}

		$self->{_device} = $discovered->{ $self->{'_ip'} }->{'device'};
		$self->{_type} = $discovered->{ $self->{'_ip'} }->{'type'};
		
	}

	if ( defined( $params{'name'} ) ) {
		my $found = 0;

		foreach ( keys( %{$discovered} ) ) {

			if ( $discovered->{$_}->{'name'} eq $params{'name'} ) {
				$found = 1;
				$self->{_device} = $discovered->{$_}->{'device'};
				last;
			}

		}

		if ( !$found ) {
			croak "Name not found - try running another discovery search!";
		}

	}

	# Load service - only basic is here for now, others will be supported later
	foreach my $service ( $self->{_device}->getservicelist() ) {

		if ( $service->getservicetype() =~ /urn:Belkin:service:basicevent:1/ ) {
			$self->{_basicService} = $service;
		}
	}

	bless $self, $class;

	$self;

}

sub getType() {
    
    my $self = shift;
    
    if (defined($self->{_type})) {
        return $self->{_type};
    } else {
        return "undefined";
    }
    
    
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
	
	if ($self->getType() eq "sensor") {
        warn "Method only supported for switches, not sensors.\n";
	    return;
	}

	my $state  = $self->isSwitchOn();
	my $toggle = $state ^= 1;

	$self->on()  if $toggle == 1;
	$self->off() if $toggle == 0;

}

sub getBinaryState() {

	my $self = shift;

	my $resp =
	  $self->{_basicService}
	  ->postaction( "GetBinaryState");
	if ( $resp->getstatuscode() == 200 ) {

		my $state = $resp->getargumentlist()->{'BinaryState'};
		if ($state == 1) { 
		    return "on";
		} elsif ($state == 0) {
		    return "off";
		} else {
		    return "unknown";
		}
	}
	else {
		croak "Got status code " . $resp->getstatuscode() . "!\n";
	}

}

sub on() {

	my $self = shift;
	
    if ($self->getType() eq "sensor") {
        warn "Method only supported for switches, not sensors.\n";
	    return;
	}

	my $resp =
	  $self->{_basicService}
	  ->postaction( "SetBinaryState", { BinaryState => 1 } );
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
	
	if ($self->getType() eq "sensor") {
	    warn "Method only supported for switches, not sensors.\n";
	    return;
	}

	my $resp =
	  $self->{_basicService}
	  ->postaction( "SetBinaryState", { BinaryState => 0 } );
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

OR

my $wemo = WebService::Belkin::WeMo::Device->new(name => 'Desk Lamp', db => '/tmp/belkin.db');



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
    * isSwitchOn - Returns true (1) or false (0)
    * on - Turn switch on
    * off - Turn switch off
    * toggle - Toggle switch on/off



=head1 AUTHOR

Eric Blue <ericblue76@gmail.com> - http://eric-blue.com

=head1 COPYRIGHT

Copyright (c) 2013 Eric Blue. This program is free
software; you can redistribute it and/or modify it under the same terms
as Perl itself.

=cut


