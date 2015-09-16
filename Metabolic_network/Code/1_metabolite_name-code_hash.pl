#!/usr/bin/perl
use strict;
use warnings;

#use= ./1_metabolite_name-code_hash.pl ../Data/compound 

my %name_code; #hash containing metabolite name and code
my @idline = (0, 0, 4); #array used as control structure for Code(1), Name(2), End_block(4)
my $entry; #metabolite code
my $met_name; #metabolite name

open my $COMPOUND, "< $ARGV[0]";
while ( my $line = <$COMPOUND> ) {
	chomp $line;
	#Metabolite code
	if ( substr($line, 0, 5) eq "ENTRY" ) {
		if ( $idline[2] == 4 ){
		$entry = substr $line, 12, 6;
		$idline[0] = 1;
		} else {
		print "error, not defined end of block near $line";
		}
	}
	#Metabolite name and hash entry
	elsif ( substr($line, 0, 4) eq "NAME" ) {
		$met_name = substr $line, 12;
		$met_name = real_name($met_name);
		$idline[1] = 2;
		nc_add(@idline);
	}
#=comment
	#Metabolite alternative name and hash entry
	elsif ( substr($line, 0, 4) eq "    " ) {
		my $sum;
		$sum += $_ for @idline;
		if ( $sum == 7 ) {
		$met_name = substr $line, 12;
		$met_name = real_name($met_name);
		nc_add(@idline);
		}
	}
#=cut
	#reset idline stats
	elsif ( substr($line, 0, 7) eq "FORMULA" ) {
		@idline = (0, 0, 0);
	} elsif ( substr($line, 0, 6) eq "ENZYME" ) {
		@idline = (0, 0, 0);
	} elsif ( substr($line, 0, 8) eq "REACTION" ) {
		@idline = (0, 0, 0);
	}
	#End of block
	elsif ( substr($line, 0, 3) eq "///" ) {
		$idline[2] = 4;
		$entry = "";  #reinitialize var
		$met_name = "";
	}
} #end while
close $COMPOUND;

#------------------Imprimir diccionario: nombre	codigo-------------
my $nameout  = "$ARGV[0].name_code";
open my $OUT, '>', "$nameout";
foreach my $key (keys %name_code){
	print $OUT "$key\t$name_code{$key}\n";
}
close $OUT;

exit;



#________________________________Subroutines______________________________________________________

#subrutine that strips ";" from metabolite name:
sub real_name {
	my ($name) = @_;
	if ( substr($name, -1) eq ";" ){ #remove ;
	$name=~s/(.*);/$1/g;
	}
	return $name;
}

#subrutinne for filling metabolite name andd code in the hash%name_code, 
sub nc_add {
	my (@stats) = @_;
	my $sum;
	$sum += $_ for @stats;
	if ( $sum == 7 ) {
	$name_code{$met_name} = $entry;
	}
}
