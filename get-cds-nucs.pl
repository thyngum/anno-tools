#!/usr/bin/perl

# Extracts the nucleotide sequence of each CDS from an annotated sequence file. 
# Outputs sequences in FASTA format to STDOUT.

#   get-cds.pl [-f <format>] [-pseudo] <file>

#     -f          Input file format (guessed if not specified).
#     -pseudo     Include CDS features flagged as pseudogenes.

use Bio::SeqIO;
use File::Basename;
use File::Spec;
use Getopt::Long;

GetOptions ( 'f=s' => \$format, 'pseudo' => \$pseudo );

die "Usage: get-cds.pl [-f <format>] [-pseudo] <file>\n" unless ( @ARGV ); 

my $item = $ARGV[0];

die "File \'$item\' not found!\n" unless ( -f $item );

if ( $format ) {
	$seqio_in = new Bio::SeqIO(-file => $item,
	                           -format => $format ) or die "Error opening file \'$item\'!";
}
else {
	$seqio_in = new Bio::SeqIO(-file => $item) or die "Error opening file \'$item\'!";
}

my $count_CDS = 0;
my $count_pseudo = 0;

while ( my $seq = $seqio_in->next_seq() ) {
	foreach my $feature ( $seq->get_SeqFeatures ) {
		my $type = $feature->primary_tag;
		my $start = $feature->start;

		if ( $type eq 'CDS') {

			my $ok = 0;
			if ( $feature->has_tag('pseudo') ) {
				if ( $pseudo ) {
					$ok = 1;
					$count_pseudo++;
				}
			}
			else {
				$ok = 1;
			}

			if ( $ok ) {
				my $locus_tag;
				if ( $feature->has_tag('locus_tag') ) {
					( $locus_tag ) = $feature->get_tag_values('locus_tag');
				}
				else {
					die "CDS feature at $start has no locus_tag!\n";
				}
				my $product;
				if ( $feature->has_tag('product') ) {
					( $product ) = $feature->get_tag_values('product');
				}
				else {
					$product = "unknown product"
				}

				print ">$locus_tag $product\n";
				print sblock($feature->spliced_seq->seq);

				$count_CDS++;
			}

		}			
	}
}

if ( $pseudo ) {
	print STDERR "$item: $count_CDS CDS, $count_pseudo flagged as pseudo\n";
}
else {
	print STDERR "$item: $count_CDS CDS\n";
}


sub sblock {

	# Returns a sequence block with n chars per line (n = 60 by default).
	# 	Usage: sblock(sequence, n)

	my ( $seq, $n ) = @_;
	$n = 60 unless ( $n );

	$block = "";
	while ( my $chunk = substr($seq, 0, $n, "") ) {
		$block .= "$chunk\n";
	}

	return $block;
}
