#!/usr/bin/perl
    use strict;
    use warnings;

#Prints the OEN as an adjacency matrix
#use: ./3_Gen-gen_adjacency_matrix.pl ../Results/Gen-Gen.list



	my %genes_and_genes = create_hashofhashes_first("< $ARGV[0]");
	my @gene_names = get_only_names("< $ARGV[0]");

	#print_hash_of_hashes(\%genes_and_genes);
	#print "@gene_names\n";
	#print "$#gene_names\n";
	
	my @adjacency_matrix;
	
	for my $i (0 .. $#gene_names) {
		my @array;
		$array[0] = $gene_names[$i];
		$adjacency_matrix[$i] = [@array]; #array of arrays
	}
	
	#print_array_of_arrays(\@adjacency_matrix);
	
	my $count = 0;
	for my $i (reverse 0 .. $#gene_names) {
		#print "$gene_names[$i]\t";
		print "genes left = $i\n";
		my %hash;
		#if ( exists $genes_and_genes{$gene_names[$i]} ) {
		#	%hash = %{$genes_and_genes{$gene_names[$i]}};
		#} else {
		#	%hash = ();
		#}
		#my @array = @{$adjacency_matrix[$i]};
		#print "@array\n";
		#print "$gene_names[$i] => $_\n" for keys %hash;
		for my $j (0 .. $#gene_names-$count) {
			#my %hash2;
			#if ( exists $genes_and_genes{$gene_names[$j]} ) {
			#	%hash2 = %{$genes_and_genes{$gene_names[$j]}};
			#} else {
			#	%hash2 = ();
			#}
			#print "$gene_names[$j] => $_\n" for keys %hash2;
			if ( exists $genes_and_genes{$gene_names[$i]}{$gene_names[$j]} || $genes_and_genes{$gene_names[$j]}{$gene_names[$i]}) {
				# || or , && and
				#push (@array, "1"); 
				push ($adjacency_matrix[$i], "1");
				#print "$gene_names[$i]\t$gene_names[$j] SI\n"; 
			} else {
				#push (@array, "0"); 
				push ($adjacency_matrix[$i], "0");
				#print "$gene_names[$i]\t$gene_names[$j] NO\n"; 
			}
			#print_array_of_arrays(\@adjacency_matrix);
			#print "$adjacency_matrix[$i]\n";
			
		}
		#for my $j (0 .. $#{$adjacency_matrix[$i]}) {
		#	print "$adjacency_matrix[$i][$j]\t"; #imprimir metabolitos
		#}
		#print "\n";
		#$adjacency_matrix[$i] = [@array];
		$count++;
	}
	
	#print "printing matrix\n";
	#print_array_of_arrays(\@adjacency_matrix);



	open my $OUT, "> ../Results/Gen-Gen_adjacency.matrix";
	for my $i (0 .. $#adjacency_matrix) {
		print $OUT "$adjacency_matrix[$i][0]\t"; 
		
	}
	print $OUT "\n"; 
  
  
  	for my $i (0 .. $#adjacency_matrix) {
		print "printed = $i\n";
  		for my $j (0 .. $#{$adjacency_matrix[$i]}) {
  			print $OUT "$adjacency_matrix[$i][$j]\t"; 
  		}
		#for my $k ($i .. $#adjacency_matrix - $#{$adjacency_matrix[$i]} +1) {
		for my $k ($i .. $#adjacency_matrix) {
			if ( exists $adjacency_matrix[$k+1][$i+1] ) {
				print $OUT "$adjacency_matrix[$k+1][$i+1]\t"; 
			}
		
		}
  		print $OUT "\n"; 
  	}
		

	close $OUT;
	
	#system("awk '{print substr($0, 0, length($0)-1)}' Gen-Gen2.matrix ");
	

exit 0;




#________________________________Subroutines___________________________________________________________

#Creates a hash of hashes, Firts column MasterKeys:
sub create_hashofhashes_first {
	my ($FILE) = @_;	
	my %masterhash; #hash of hashes with MasterKeys
	my $count = 0;
	#open my $BLASTEDGENES, "< $ARGV[0]";
	open DATA, $FILE;
	while ( my $line = <DATA> ) {
		chomp $line;
		my @columns = split (/\t/, $line);
		my %subhash;
		
		if ( exists $masterhash{$columns[0]} ) {
			$masterhash{$columns[0]}{$columns[1]} = 1;
			#%subhash = %{$masterhash{$columns[0]}};
		} else {
			%subhash = ();
			$subhash{$columns[1]} = 1;
			$masterhash{$columns[0]} = {%subhash}; # se hace una hash de hashes,
		}
		$count++;
		#print "$count\n";
		#$subhash{$_}++ for ($columns[1]);
		#$masterhash{$columns[0]} = {%subhash}; # se hace una hash de hashes,
	}
	close DATA;
	return %masterhash;
}

#________________________________________________________________________________________________________

#Reads a file of gen-gen pairs and returns only unique gene names:
sub get_only_names {
	my ($FILE) = @_;	
	my @onlynames; #array with gene names
	
	#open my $BLASTEDGENES, "< $ARGV[0]";
	open DATA, $FILE;
	
	print "\nGetting Genes\n";
	while ( my $line = <DATA> ) {
		
			chomp $line;
			my @columns = split (/\t/, $line);
			push (@onlynames, @columns); 
			#print "$#onlynames\n";
		
	
	}
	close DATA;
	print "Removing duplicates\n";
	@onlynames = uniq(@onlynames);
	print "Total number of genes: $#onlynames\n";
	return @onlynames;
}

#remove duplicates
sub uniq {
    return keys %{{ map { $_ => 1 } @_ }};
}


#________________________________________________________________________________________________________

#Prints a hash oh hashes

sub print_hash_of_hashes {
  my $master_reference = shift;
  my %masterhash = %$master_reference;
  
	foreach my $masterkey (sort keys %masterhash) {
		print "$masterkey\t"; #imprimir EC number
		foreach my $key (keys %{$masterhash{$masterkey}}) {
			print "$key\t"; #imprimir metabolitos
		}
		print "\n"; 
	}
  
}

#________________________________________________________________________________________________________

#Prints an array of arrays

sub print_array_of_arrays {
  my $master_reference = shift;
  my @masterarray = @$master_reference;
  
	for my $i (0 .. $#masterarray) {
		for my $j (0 .. $#{$masterarray[$i]}) {
			print "$masterarray[$i][$j]\t"; #imprimir metabolitos
		}
		print "\n"; 
	}
  
}
