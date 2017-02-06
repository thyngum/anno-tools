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
		my $locus_tag = "";
		my $product = "";		

		if ( $type eq 'CDS') {
			if ( $feature->has_tag('codon_start') ) {
				( $codon_start ) = $feature->get_tag_values('codon_start');
			}
			else {
				$codon_start = 1;
			}
			unless ( $feature->has_tag('partial') or $codon_start != 1 ) {
				if ( $feature->has_tag('pseudo') ) {
					if ( $pseudo ) {
						$count_CDS++;
						$count_pseudo++;

						( $locus_tag ) = $feature->get_tag_values('locus_tag');
						die "CDS feature marked as pseudo starting at $start has no locus_tag!" unless $locus_tag;
						( $product ) = $feature->get_tag_values('product');
						$product = "Unknown product" unless $product;
						print ">$locus_tag $product (pseudo)\n";
						print sblock($feature->spliced_seq->seq);
					}
				}
				else {
					$count_CDS++;

					( $locus_tag ) = $feature->get_tag_values('locus_tag');
					die "CDS feature starting at $start has no locus_tag!" unless $locus_tag;
					( $product ) = $feature->get_tag_values('product');
					$product = "Unknown product" unless $product;
					print ">$locus_tag $product\n";
					print sblock($feature->spliced_seq->seq);
				}
			}
			else {
				print STDERR "Partial CDS feature starting at $start was ignored!";
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
