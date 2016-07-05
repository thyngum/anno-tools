#!/usr/bin/perl

# Converts one or more sequence files to the EMBL format. Output files are named after the original
# files with the *.embl extension.

#   anno-to-embl.pl [-f <format>] <file(s)>

# 	-f  	Input file format (guessed if not specified).

# Script written by Alejandro Llanes (thyngum@gmail.com)

use Bio::SeqIO;
use File::Basename;
use File::Spec;
use Getopt::Long;

GetOptions ( 'f=s' => \$format );

die "Usage: anno-to-embl.pl [-f <format>] <file(s)>\n" unless ( @ARGV );

foreach my $item ( @ARGV ) {
	next if ($item =~ m/^\./); 
	
	if ( -f $item ) {		
		my ($name, $path, $suffix) = fileparse($item, qr/\.[^.]*/);	
		my $output = $path . "/" . $name . ".embl";

	    if ( $format ) {
	    	$seqio = new Bio::SeqIO(-file => $item,
	    	                        -format => $format ) or die "Error opening file \'$item\'!";
	    }
	    else {
	    	$seqio = new Bio::SeqIO(-file => $item) or die "Error opening file \'$item\'!";
	    }

	    if ( -e $output ) {
	    	print "File \'$name.embl\' already exist! Overwrite it? (y/N) ";
	    	$answer = <STDIN>;
	    	chomp $answer;
	    	
	    	next if ( $answer ne 'y' and $answer ne 'Y' );
	    }
	    
		my $seq_out = Bio::SeqIO->new(-file => ">$output",
								   -format => 'embl');
						  
		while ( my $seq = $seqio->next_seq ) {	
			$seq_out->write_seq($seq);
		}		    
	    
	    print STDERR "$name.embl .. done\n"

	}
	else {
		print STDERR "File \'$item\' not found!\n";
	}   		
}


