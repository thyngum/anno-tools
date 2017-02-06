#!/usr/bin/perl

# Converts one or more sequence files to the Genbank format. Output files are named after the original
# files with the *.gbk extension.

#   anno-to-genbank.pl [-f <format>] <file(s)>

#     -f     Input file format (guessed if not specified).

# Script written by Alejandro Llanes (thyngum@gmail.com)

use Bio::SeqIO;
use File::Basename;
use File::Spec;
use Getopt::Long;

GetOptions ( 'f=s' => \$format );

die "Usage: anno-to-genbank.pl [-f <format>] <file(s)>\n" unless ( @ARGV );

foreach my $item ( @ARGV ) {
	next if ($item =~ m/^\./);
	
	if ( -f $item ) {		
		my ($name, $path, $suffix) = fileparse($item, qr/\.[^.]*/);		    
		my $output = $path . "/" . $name . ".gbk";

		if ( $format ) {
			$seqio_in = new Bio::SeqIO(-file => $item,
			                           -format => $format ) or die "Error opening file \'$item\'!";
		}
		else {
			$seqio_in = new Bio::SeqIO(-file => $item) or die "Error opening file \'$item\'!";
		}

		if ( -e $output ) {
			print "File \'$name.gbk\' already exist! Overwrite it? (y/N) ";
			$answer = <STDIN>;
			chomp $answer;
			
			next if ( $answer ne 'y' and $answer ne 'Y' );
		}
		    
		my $seq_out = Bio::SeqIO->new(-file => ">$output",
		                              -format => 'genbank');
						  
		while ( my $seq = $seqio_in->next_seq() ) {	
			$seq_out->write_seq($seq);
		}		    

		print STDERR "$name.gbk .. done\n"

	}
	else {
		print STDERR "File \'$item\' not found!\n";
	}   		
}
