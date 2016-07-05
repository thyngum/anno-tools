#!/usr/bin/perl

# Extracts the sequences from one or more annotated files and save them to corresponding
# FASTA files (with *.fasta extension).

#   anno-to-fasta.pl [-f <format>] <file(s)>

#	-f   	Any of the formats supported by BioPerl (guessed if not specified).

use Bio::SeqIO;
use File::Basename;
use File::Spec;
use Getopt::Long;

GetOptions ( 'f=s' => \$format );

die "Usage: anno-to-fasta.pl [-f <format>] <file(s)>\n" unless ( @ARGV );

foreach my $item ( @ARGV ) {
	next if ($item =~ m/^\./);
	
	if ( -f $item ) {		
		my ($name, $path, $suffix) = fileparse($item, qr/\.[^.]*/);		    
		my $output = $path . "/" . $name . ".fasta";

		if ( $format ) {
			$seqio_in = new Bio::SeqIO(-file => $item,
			                           -format => $format ) or die "Error opening file \'$item\'!";
		}
		else {
			$seqio_in = new Bio::SeqIO(-file => $item) or die "Error opening file \'$item\'!";
		}

		if ( -e $output ) {
			print "File \'$name.fasta\' already exist! Overwrite it? (y/N) ";
			my $answer = <STDIN>;
			chomp $answer;
			
			next if ( $answer ne 'y' or $answer ne 'Y' );
		}

		my $seq_out = new Bio::SeqIO(-format => 'fasta',
		                             -file   => ">$output");
		
		while ( my $seq = $seqio_in->next_seq() ) {
			$seq->id($name) if ( $seq->id eq "unknown_id" ); # Address the issue that IDs are missing in some EMBL files
			$seq_out->write_seq($seq);	
		}

		print STDERR "$name.fasta .. done\n";
		
	} 
	else {
		print STDERR "File \'$item\' not found!\n";
	}          
}
