#!/usr/bin/env perl

use warnings;
use strict;

my $input_file = './assets/02.txt' ;

our @to_compare = (14, 12, 13); # blue, red, green
our $result = 0;

open (FH, '<', $input_file) or die $!;
while (<FH>) {
	# split and keep only the right side (exclude game identifier)
	our $game_index = $1 if ( (split(/:/,$_))[0] =~ m/(\d+)/ ); # Grab game index
	my @handful_list = split(/;/, (split(/:/,$_))[1] ) ;
	our $impossible = 0;
	foreach (@handful_list) { # here it is each take inside the bag
		if ( $_ =~ m/(\d+)\s*blue/ ) {
			#print $1, " blue on index ", $game_index, "\n";
			if ( $1 > $to_compare[0] ) {
				#print "\n", $_, $game_index," is impossible!\n";
				$impossible = 1;
			};
		};
		if ( $_ =~ m/(\d+)\s*red/ ) {
			#print $1, " red on index ", $game_index, "\n";
			if ( $1 > $to_compare[1] ) {
				#print "\n", $_, $game_index, " is impossible!\n";
				$impossible = 1;
			};
		};
		if ( $_ =~ m/(\d+)\s*green/ ) {
			#print $1, " green on index ", $game_index, "\n";
			if ( $1 > $to_compare[2] ) {
				#print "\n", $_, $game_index ," is impossible!\n";
				$impossible = 1;
			};
		};
	};
	if ( $impossible == 0 ) {
		#print $_, "\n\n";
		$result += $game_index ; # add game-id to result
	};
};
close(FH);

print $result;
