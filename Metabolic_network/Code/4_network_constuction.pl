#!/usr/bin/perl
use strict;
use warnings;

#use ./4_network_constuction.pl ../Data/reactions_slim.filter_NUMBER 
#usage example ./4_network_constuction.pl ../Data/reactions_slim.filter_40
my @slimmet; #hash of arrays, keys are reactions, arrays are metabolites
my @metcom; #metabolites in common between reactions

#---------------Load ../Data/reaction_slim---------
open my $OPENMET, "< $ARGV[0]";  
while (my $line = <$OPENMET>){
chomp $line;
my @linea = split /\t/, $line;
push @slimmet, [@linea];
}
close $OPENMET;

#pairwise comparison betwwen all reactions
for my $i (0 .. $#slimmet)  {
	my @reaction1;
	my @reaction2;
	for my $j (0 .. $#{$slimmet[$i]}) { #load reaction1
		push @reaction1, $slimmet[$i][$j];
	} #end for j
	for (my $x = $i+1; $x <= $#slimmet; $x++) {
		#	my $x = $i+1;
		for my $y (0 .. $#{$slimmet[$x]}) { #load reaction2
			push @reaction2, $slimmet[$x][$y];
		} #end for y
		compare(\@reaction1, \@reaction2); #compare reaction1 and reaction2
		@reaction2 = ();
	} #end for x
	@reaction1 = ();
} #end for i


#------------------Out reactions with common metabolites----------
#in case that the pairs of reactions and the metabolites are needed in the out file, comment lines 41 and 55

=com
my $altnameout  = "../Data/common_metabolites";
open my $ALTOUT, '>', "$altnameout";
for my $i (0 .. $#metcom)  {
	for my $j (0 .. $#{$metcom[$i]}) {
		if ( exists $metcom[$i][2] ) {
			print $ALTOUT "$metcom[$i][$j]\t";
		}
	}
	if ( exists $metcom[$i][2] ) {
		print $ALTOUT "\n";
	}
}
close $ALTOUT;
=cut

#-------only prints reaction names----------------
#$name=~s/(.*);/$1/g;
#my $nameout  = $ARGV[0];
my $nameout;
($nameout = $ARGV[0]) =~ s/Data\//Results\/network./;
#open my $OUT, '>', "common_met.$nameout";
open my $OUT, '>', "$nameout";
for my $i (0 .. $#metcom)  {
	for my $j (0 .. 1) {
		if ( exists $metcom[$i][2] ) {
			print $OUT "$metcom[$i][$j]\t";
		}
	}
	if ( exists $metcom[$i][2] ) {
		print $OUT "\n";
	}
}
close $OUT;

exit;

#________________________________Subroutines______________________________________________________

#subrutine that compares two reactions and inserts the ids of the reactions and the metabolites in common

sub compare {
	my ( $reaction1, $reaction2 ) = @_;
	my @common;
	$common[0] = $$reaction1[0];
	$common[1] = $$reaction2[0];

	my %hash; 
	$hash{$_}++ for (@$reaction1[ 1 .. $#$reaction1 ], @$reaction2[ 1 .. $#$reaction2 ]);
	for (keys %hash) {
		if ($hash{$_} > 1) {
		push @common, $_;
		}
	}
	push @metcom, [@common];
}
