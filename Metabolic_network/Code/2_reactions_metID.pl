#!/usr/bin/perl
use strict;
use warnings;

#use ./2_reactions_metID.pl ../Data/br08201.keg ../Data/compound.name_code

my @metabolism=(); #array of arrays, contain reaction = ECnumber	reaction	metabolites products, in each array for each reaction
my @reaction=(); #@reaction = ECnumber	reaction	metabolites products

#reads the br08201.keg file with reaction information
open my $REACTION, "< $ARGV[0]";
while ( my $line = <$REACTION> ) {
	chomp $line;
	#extract ECnumber
	if ( substr($line, 0, 1) eq "D" ) {
		@reaction=();
		$reaction[0] = substr $line, 7;
	}
	#extract Reaction and metabolites
	elsif ( substr($line, 0, 1) eq "E" ) {
		$reaction[1] = substr $line, 9, 6; #reaction ID
		my $metab = substr $line, 17;
		my @s = split( /\s\<\=\>\s/,$metab); #reactives and products
		push @reaction, (split /\s\+\s/, $s[0]);
		#push @reaction, " <=> ";
		push @reaction, (split /\s\+\s/, $s[1]);
		push(@metabolism, [@reaction]);
		@reaction = @reaction[0, 1];
	}
} #end of while REACTION
close $REACTION;


#---------------Load ../Data/compound.name_code hash Diccionary in %name_code---------
my %name_code;
open my $NAMECODE, "< $ARGV[1]";  
while (my $line = <$NAMECODE>){
chomp $line;
my @linea = split /\t/, $line;
$name_code{$linea[0]} = $linea[1];
}
close $NAMECODE;

#--------------------HASH of HASHES-------------------
my %slimmet; #hash of hashes
for my $i (0 .. $#metabolism)  {
	my %hash = ();
	for my $j (2 .. $#{$metabolism[$i]}) { #( my $j = 2; $j <= $#{$metabolism[$i]}; $j++) {
		my $rawmetabolite = remove_n($metabolism[$i][$j]);
		if ( exists $name_code{$rawmetabolite} ) { 
		$hash{$_}++ for ($name_code{$rawmetabolite});
		} 
		#else { print "$rawmetabolite\n"; } #print metabolites not included in dictionary
	} #close for
	$slimmet{$metabolism[$i][0]} = {%hash}; 
} 

#-------------------Print %slimmet the result is a file with ECnumbers and metabolites------------------------
#=com
my $nameout  = "../Data/reactions_slim";
open my $OUT, '>', "$nameout";
foreach my $masterkey (sort keys %slimmet) {
	print $OUT "$masterkey\t"; #print EC number
	foreach my $key (keys %{$slimmet{$masterkey}}) {
		print $OUT "$key\t"; #print metabolites
	}
	print $OUT "\n"; 
}
close $OUT;
#=cut

exit;

#________________________________Subroutines______________________________________________________

#------------Subrutine that strips n, n+1, etc of the metabolites---------------------------------
sub remove_n {
my ($metabolite) = @_;

if ( substr($metabolite, 0, 3) =~ /.*\s/  ) { #pattern n , 1 , ...
	$metabolite =~s/.?\s(.*)/$1/g;
}
elsif ( substr($metabolite, -5) =~ /\(n..\)/  ) { #pattern (n+m), (n+1) ...
	$metabolite = substr($metabolite, 0, -5);
}
elsif ( substr($metabolite, -5) =~ /\(m..\)/  ) { #pattern (m+n), (m+1) ...
	$metabolite = substr($metabolite, 0, -5);
}
elsif ( substr($metabolite, -3) =~ /\(n\)/  ) { #pattern (n)
	$metabolite = substr($metabolite, 0, -3);
}
elsif ( substr($metabolite, -3) =~ /\(m\)/  ) { #pattern (m)
	$metabolite = substr($metabolite, 0, -3);
}

return $metabolite;
}
