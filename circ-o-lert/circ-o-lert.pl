#!/usr/bin/perl

# Poll Circonus API for sev1 alerts using Raspberry Pi.
# Activate status indicator LED's and Buzzer.
# Disable Buzzer with a momentary switch.
# Rev 1

use strict;
use warnings;

use HTTP::Tiny;
use JSON::PP qw(encode_json decode_json);
use Data::Dumper;
use Device::BCM2835;
use Time::HiRes qw(usleep);

# create an agent
my $agent = HTTP::Tiny->new(
  default_headers => {
    "X-Circonus-App-Name" => "circ-o-lert-",
    "X-Circonus-Auth-Token" => "PUT_YOUR_TOKEN_HERE",
    "Accept" => "application/json",
  },
);

# talk to the API over HTTP
my $response = $agent->get('https://api.circonus.com/alert?f__severity=1');

# parse the result as JSON
my $result = $response->{content} ? decode_json $response->{content} : {};

# handle errors
unless ($response->{success}) {
    die "$response->{status}: $result->{code} ($result->{message})\n";
}

my $alert_count = 0;
foreach my $alert (@{ $result }) {
    print " * $alert->{_alert_url} \n";
    $alert_count++;
}

print "Number of Alerts $alert_count \n";

# Get the Raspberry Pi ready to work
Device::BCM2835::init() || die "Could not init library";

# Set RPi pin 7 to be an OUTPUT
Device::BCM2835::gpio_fsel(&Device::BCM2835::RPI_GPIO_P1_07, 
      &Device::BCM2835::BCM2835_GPIO_FSEL_OUTP);
# Set RPi pin 11 to be an OUTPUT
Device::BCM2835::gpio_fsel(&Device::BCM2835::RPI_GPIO_P1_11, 
      &Device::BCM2835::BCM2835_GPIO_FSEL_OUTP);
# Set RPi pin  to be an OUTPUT
Device::BCM2835::gpio_fsel(&Device::BCM2835::RPI_GPIO_P1_24,
      &Device::BCM2835::BCM2835_GPIO_FSEL_OUTP);
# Set RPi pin 26 to be an INPUT / with PULL Up Resistor
Device::BCM2835::gpio_fsel(&Device::BCM2835::RPI_GPIO_P1_26, 
      &Device::BCM2835::BCM2835_GPIO_FSEL_INPT);
Device::BCM2835::gpio_write(&Device::BCM2835::RPI_GPIO_P1_24, LOW);

my $shutup = Device::BCM2835::gpio_lev(RPI_GPIO_P1_26);

# Alarm until alerts clear
while ($alert_count >= 1) {
   print "looping \n";
   # Change Status Lights from Green to Red
   Device::BCM2835::gpio_write(&Device::BCM2835::RPI_GPIO_P1_11, LOW);
   Device::BCM2835::gpio_write(&Device::BCM2835::RPI_GPIO_P1_07, HIGH);
  
#   $shutup = Device::BCM2835::gpio_lev(RPI_GPIO_P1_26);
   print "The button is $shutup \n";

   $response = $agent->get('https://api.circonus.com/alert?f__severity=1');
   my $result = $response->{content} ? decode_json $response->{content} : {};
   $alert_count = 0;
   foreach my $alert (@{ $result }) {
    $alert_count++;
    }
   print "Remaining Alerts $alert_count \n";

   # switch sample loop
   for (my $bloop=0; $bloop <= 5000; $bloop++) {
     if (Device::BCM2835::gpio_lev(RPI_GPIO_P1_26) == 1) {
       $shutup = 1; 
     }
     if ( $shutup != 1 ) {
      Device::BCM2835::gpio_write(&Device::BCM2835::RPI_GPIO_P1_24, HIGH);
     } else {
      Device::BCM2835::gpio_write(&Device::BCM2835::RPI_GPIO_P1_24, LOW);
     }
     usleep(100) ;
    
   # blink the LED for the number of alerts
#     for (my $blinks=0; $blinks==$alert_count; $blinks++) {
#       print "$blinks";
#       Device::BCM2835::gpio_write(&Device::BCM2835::RPI_GPIO_P1_07, LOW);
#       #usleep(500);
#       sleep 1;
#       Device::BCM2835::gpio_write(&Device::BCM2835::RPI_GPIO_P1_07, HIGH); 
#     }
 } 
   sleep 2; 
} 

# Reset Lights and sounds 
if ($alert_count == 0) {
   Device::BCM2835::gpio_write(&Device::BCM2835::RPI_GPIO_P1_11, HIGH);
   sleep 1;
   Device::BCM2835::gpio_write(&Device::BCM2835::RPI_GPIO_P1_07, LOW);
   sleep 1;
   Device::BCM2835::gpio_write(&Device::BCM2835::RPI_GPIO_P1_24, LOW);
   exit 0;
}

sub decode_response {
  my $response = shift;

  # decode from JSON if content returned
  my $result = $response->{content} ? decode_json $response->{content} : {};

  # throw an error if there was a problem
  unless ($response->{success}) {
    die "$response->{status}: $result->{code} ($result->{message})\n";
  }

  return $result;
}
