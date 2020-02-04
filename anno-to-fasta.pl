#!/usr/bin/perl

# Extracts the sequence from one or more annotated files and save it to corresponding
# FASTA files. Output files are named after the basename of input files, with *.fasta 
# extension.

#   anno-to-fasta.pl [-f <format>] <file(s)>

#     -f     Input file format (genbank/embl, guessed if not specified).

# Script written by Alejandro Llanes (thyngum@gmail.com)

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
			unlink $output;
		}

		print STDERR "$name$suffix";

		my $seq_out = new Bio::SeqIO(-format => 'fasta',
		                             -file   => ">$output");

		while ( my $seq = $seqio_in->next_seq() ) {
			$seq->id($name) if ( $seq->id eq "unknown_id" ); # IDs may be missing
			$seq_out->write_seq($seq);
		}

		print STDERR " -> $name.fasta\n";

	} 
	else {
		print STDERR "File \'$item\' not found!\n";
	}
}

