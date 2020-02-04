#!/usr/bin/perl

# Converts one or more sequence files beteen format. Output files are named after the original
# input files.

#   anno-convert.pl -c <format> [-f <format>] <file(s)>

#     -c	Output file format (genbank/embl/gff).
#     -f	Input file format (genbank/embl/gff, guessed if not specified).

# Warning: the script overwrites output files if they already exist!

# Script written by Alejandro Llanes (thyngum@gmail.com)

use Bio::SeqIO;
use Bio::Tools::GFF;
use File::Basename;
use File::Spec;
use Getopt::Long;

GetOptions ( 'f=s' => \$format, 'c=s' => \$output_format  );

die "Usage: anno-convert.pl -c <format> [-f <format>] <file(s)>\n" unless ( @ARGV and $output_format );

foreach my $item ( @ARGV ) {
	next if ($item =~ m/^\./);

	if ( -f $item ) {
		my ($name, $path, $suffix) = fileparse($item, qr/\.[^.]*/);

		my $output_suffix = ".conv"; # Default output suffix
		if ( $output_format eq 'genbank' ) {
			$output_suffix = ".gbk"; 
		}
		elsif ( $output_format eq 'embl' ) {
			$output_suffix = ".embl"
		}
		elsif ( $output_format eq 'gff' ) {
			$output_suffix = ".gff"
		}

		my $output = $path . "/" . $name . $output_suffix;
		my $input = $path . "/" . $name . $suffix;

		if ( "$input" eq "$output" ) {
			print STDERR "$name$suffix: same input and output format! \n";
			next;
		}

		if ( $format ) {
			$seqio_in = new Bio::SeqIO(-file => $item,
			                           -format => $format ) or die "Error opening file \'$item\'!";
		}
		else {
			$seqio_in = new Bio::SeqIO(-file => $item) or die "Error opening file \'$item\'!";
		}

		if ( -e $output ) {
			unlink "$output";
		}

		print STDERR "$name$suffix";

		if ( $output_format eq 'gff' ) {

			my $gffout = new Bio::Tools::GFF(-file => ">$output",
				 			                 -gff_version => 3);

			while ( $seq = $seqio_in->next_seq ) {
				for my $feature ( $seq->top_SeqFeatures ) {
					$gffout->write_feature($feature);
				}
			}
		}
		else {
			my $seq_out = Bio::SeqIO->new(-file => ">$output",
					                      -format => $output_format );

			while ( my $seq = $seqio_in->next_seq() ) {	
				$seq_out->write_seq($seq);
			}
		}

		print STDERR " -> $name$output_suffix\n"

	}
	else {
		print STDERR "File \'$item\' not found!\n";
	}   		
}
