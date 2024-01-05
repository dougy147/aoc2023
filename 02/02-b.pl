#!/usr/bin/env perl

use warnings;
use strict;

my $input_file = './assets/02.txt' ;

#our @to_compare = (14, 12, 13); # blue, red, green
our $result = 0;

open (FH, '<', $input_file) or die $!;
while (<FH>) {
	# split and keep only the right side (exclude game identifier)
	our $game_index = $1 if ( (split(/:/,$_))[0] =~ m/(\d+)/ ); # Grab game index
	my @handful_list = split(/;/, (split(/:/,$_))[1] ) ;
	our $max_blue = 0;
	our $max_red = 0;
	our $max_green = 0;
	foreach (@handful_list) { # here it is each take inside the bag
		if ( $_ =~ m/(\d+)\s*blue/ ) {
			my $blue_count = $1;
			if ( $blue_count > $max_blue ) {
				$max_blue = $blue_count;
			};
		};
		if ( $_ =~ m/(\d+)\s*red/ ) {
			my $red_count = $1;
			if ( $red_count > $max_red ) {
				$max_red = $red_count;
			};
		};
		if ( $_ =~ m/(\d+)\s*green/ ) {
			my $green_count = $1;
			if ( $green_count > $max_green ) {
				$max_green = $green_count;
			};
		};
	};
	#print $game_index, " : max blue = ", $max_blue, ", max red = ", $max_red, ", max green = ", $max_green, "\n";
	$result += $max_blue * $max_green * $max_red;
};
close(FH);

print $result;
