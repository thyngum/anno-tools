#!/usr/bin/perl

# Extracts the sequence of one or more annotated files and save it to corresponding
# FASTA files (with *.fasta extension).

# 	anno-to-fasta.pl [-f <format>] <file(s)>

#   	-f <format>		Any of the formats supported by BioPerl (guessed if not specified).

use Bio::SeqIO;
use File::Basename;
use File::Spec;
use Getopt::Long;

GetOptions ( 'f=s' => \$format );

if ( @ARGV ) {

	foreach $item ( @ARGV ) {
		next if ($item =~ m/^\./); # ignoring files beginning with a period
		
		if ( -f $item ) {		
			($name, $path, $suffix) = fileparse($item, qr/\.[^.]*/);	
		    
		    $output = $path . "/" . $name . ".fasta";

		    if ( $format ) {
		    	$seqio = new Bio::SeqIO(-file => $item,
		    	                        -format => $format ) or die "Error opening file \'$item\'!";
		    }
		    else {
		    	$seqio = new Bio::SeqIO(-file => $item) or die "Error opening file \'$item\'!";
		    }
		    
		    if ( -e $output ) {
		    	print "File \'$name.fasta\' already exist! Overwrite it? (y/N) ";
		    	$answer = <STDIN>;
		    	chomp $answer;
		    	
		    	next if ( $answer ne 'y' and $answer ne 'Y' );
		    }
		    
		    $seqout = new Bio::SeqIO(-format => 'fasta',
			   						 -file   => ">$output");
			
			while ( $seq = $seqio->next_seq ) {
	
				# Address the issue that IDs are missing in some EMBL files
				if ( $seq->id eq "unknown_id" ) {
					$seq->id($name);
				}
				$seqout->write_seq($seq);	
			}
			
			print "$name.fasta .. done\n";
			
		} 
		else {
			print STDERR "File \'$item\' not found!\n";
		}          
	}
	
}
else {
	die "Usage: anno-to-fasta.pl [-f <format>] <file(s)>\n";
}

