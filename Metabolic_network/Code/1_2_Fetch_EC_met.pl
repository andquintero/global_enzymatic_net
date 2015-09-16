#!/usr/bin/perl
    use strict;
    use warnings;
    use LWP::Simple;

# this scripts connects to the KEGG database and downloads a list of all EC numbers, after that retrieves the compounds associated with each EC number, and finally prints a file with EC numbers and compounds associated with each one of these.
#use: ./1_2_Fetch_EC_met.pl ../Data


#___________________________#download EC number list___________________________________________
	##my $ecnumber; #ecnumber readed from eclist
	##my @genename; #genes names list
	my @eclist; #array to store EC number list
	my $ecurl = 'http://rest.kegg.jp/list/ec'; #url to download EC numbers list
	print "\nRetrieving EC number list\n";
	my $noparsed = get($ecurl) or die "Unable to get $ecurl";
	my @linestoparse = split(/\n/, $noparsed);
	#print "\n$linestoparse[0]\n";
	
	for my $i (0 ..$#linestoparse) {
		my @line = split(/:|\t/, $linestoparse[$i]);
		$eclist[$i] = $line[1];
	}
	print "@{[$#eclist+1]} EC numbers downloaded\n";
	
#_____________________#download and store compounds realted to each EC number____________________
	my @complete_reaction; #array to store EC and associated compounds
	
	for my $i (0 .. $#eclist) {
		my $comurl = "http://rest.kegg.jp/link/compound/" . $eclist[$i]; #url to download 
		print "@{[$i+1]}/" . "@{[$#eclist+1]} Retrieving compounds for EC $eclist[$i] => ";
		my $compound_noparsed = get($comurl) or die "Unable to get $comurl";
		my @compound_linestoparse = split(/\n/, $compound_noparsed);
		print "@{[$#compound_linestoparse+1]} retrieved\n";
		
		push (@complete_reaction, $eclist[$i]);
		#$complete_reaction[$i] = $eclist[$i];
		for my $j (0 ..$#compound_linestoparse) {
			my @line = split(/:/, $compound_linestoparse[$j]);
			$complete_reaction[$i] = $complete_reaction[$i] . "\t" . $line[2];			
		}
		#print "$complete_reaction[$i]\n\n";
	}
	
#_____________________#Print EC numbers and associated compounds to file________________________
	print "Printing reactions to file\n";

	open my $OUT, "> ../Data/reactions_slim";
	for my $i (0 .. $#complete_reaction){
		my @line = split(/\t/, $complete_reaction[$i]);
		if ($#line > 0) {
			print $OUT "$complete_reaction[$i]\n";
		}
	
	}
	close $OUT;
	
=com
#_____________________#Print EC numbers and associated compounds to file________________________
	print "Printing reactions to file\n";
	open my $ECLIST, "> ../Data/eclist";
	for my $i (0 .. $#complete_reaction){
		my @line = split(/\t/, $complete_reaction[$i]);
		if ($#line > 0) {
			print $ECLIST "$line[0]\n";
		}

	}
	close $ECLIST;
=cut
    exit 0;
	