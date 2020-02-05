#!/usr/bin/perl

# Reverse complement an annotated sequence file, correcting the coordinates of features. 
# If no output is specified, the output file is named after the input file, appending "_revcomp".

#  anno-revcomp.pl -f <format> -in <filename> [-out <output>]

use Bio::Seq;
use Bio::SeqIO;
use File::Basename;
use File::Spec;
use Getopt::Long;

GetOptions ( 'f=s' => \$format, 'in=s' => \$input, 'out=s' => \$output );

die "Usage: anno-revcomp.pl -f <format> -in <filename> [-out <output>]\n" if ( ! $input or ! $format );

my $filename = File::Spec->rel2abs($input);
die "File \'$filename\' not found.\n" if ( ! -e $filename );

( my $name, my $path, my $suffix) = fileparse($filename, qr/\.[^.]*/);
if ( ! $output ) {
	$output = $path . $name . "_revcomp" . $suffix;			
}
else {		
	$output = File::Spec->rel2abs($output);
}

my $seqio_object = Bio::SeqIO->new(-file => $filename, 
                                   -format => $format ) or die $!;

my $seq = $seqio_object->next_seq;
my $length = $seq->length;

my $rev = $seq->revcom;

for $feature ($seq->get_SeqFeatures) {
		
	my $new_start = $length - $feature->end + 1;
	my $new_end = $length - $feature->start + 1;
	
	$feature->start($new_start);
	$feature->end($new_end);
	
	$rev->add_SeqFeature($feature);
	
}	

my $seqio_output = Bio::SeqIO->new(-file => ">$output" ,
                                   -format => $format);
                                
$seqio_output->write_seq($rev);	
