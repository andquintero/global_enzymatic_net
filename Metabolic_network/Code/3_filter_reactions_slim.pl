#!/usr/bin/perl
use strict;
use warnings;

#count metabolite frequency and discards the n most common, this helps to reduce the high connectivity present in this kind of networks
#use ./3_filter_reactions_slim.pl NUMBER ../Data/reactions_slim 

#usage example: ./3_filter_reactions_slim.pl 40 ../Data/reactions_slim 

my @slimmet; #hash of arrays, keys are reactions, arrays are metabolites
my %incidence;

#---------------Load ../Data/reaction_slim---------
open my $OPENMET, "< $ARGV[1]";  
while (my $line = <$OPENMET>){
chomp $line;
my @linea = split /\t/, $line;
push @slimmet, [@linea];
}
close $OPENMET;

#hash %incidence keys metabolites => values incidence
for my $i (0 .. $#slimmet)  {
	for my $j (1 .. $#{$slimmet[$i]}) {
		$incidence{$slimmet[$i][$j]}++;
	} #end for of %incidence
}

#sort metabolites from most to least common
my @metsorted = sort by_score keys %incidence;

#----------Delete most n common metabolites--------
my $n = $ARGV[0];
for my $i (0 .. $#slimmet)  {
my @deleteindex = ();
my @reaction = ($slimmet[$i][0]);
	for my $j (1 .. $#{$slimmet[$i]}) {
		push @reaction ,$slimmet[$i][$j];
		#save indices 
		for my $x (0 .. $n-1) {
			if ( $metsorted[$x] eq $slimmet[$i][$j]) {
				push @deleteindex, $j;	
			} #end if
		}
	} #end for $j
	#removes the n most common metabolites
	for my $dindex (reverse 0 .. $#deleteindex) {
		splice @reaction, $deleteindex[$dindex], 1;
	}
	$slimmet[$i] = [@reaction];
}

#-----------PRINT FILTER----------------------------------
my $nameout  = $ARGV[1];
open my $OUT, '>', "$nameout.filter_$n";
for my $i (0 .. $#slimmet)  {
	for my $j (0 .. $#{$slimmet[$i]}) {
		if ( exists $slimmet[$i][1] ) {
			print $OUT "$slimmet[$i][$j]\t";
		}
	}
	if ( exists $slimmet[$i][1] ) {
		print $OUT "\n";
	}
}
close $OUT;


exit;

#________________________________Subroutines______________________________________________________

#subrutine that sorts the keys of a hash by its value
sub by_score { $incidence{$b} <=> $incidence{$a} }
