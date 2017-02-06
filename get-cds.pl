#!/usr/bin/perl

# Extracts the amino acid sequence of each CDS from an annotated sequence file. 
# The sequences are saved in a FASTA file, named after the input file.

# 	get-cds.pl [-f <format>] [-p] <file>

#   	-f 		Input file format (guessed if not specified).
#		-pseudo	Include CDS features flagged as pseudogenes.

use Bio::SeqIO;
use Cwd 'abs_path';
use File::Basename;
use File::Spec;
use Getopt::Long;

GetOptions ( 'dir=s' => \$dir, 'f=s' => \$format, 'p' => \$print );

die "Usage: get-cds-nucs.pl [-f <format>] [-p] -dir <directory>\n" if ( !$dir ); 

$dir = abs_path($dir);
die "Invalid input directory\n" if ( ! -d $dir );

opendir(DIR, $dir) or die $!;

$format = "genbank" if ( !$format );
if ( $format eq "genbank" ) {
	$exp_suffix = ".gbk";
}
else {
	if ( $format eq "embl" ) {
		$exp_suffix = ".embl";
	}
	else {
		die "Invalid format, only 'genbank' and 'embl' are accepted.\n";
	}
}

print "LOCUS_TAG\tDESC\tLENGTH_BP\n" if ( $print );

$count = 0;
$global_cds_count = 0;



    if ( ! -d $filename ) {       
        ($name,$path,$suffix) = fileparse($filename, qr/\.[^.]*/);
        $suffix = lc($suffix);
        if ( $suffix eq $exp_suffix ) {
        	$count++;
        	
            $seqio = new Bio::SeqIO(-format => $format,
			   						-file   => $filename);
            
            $output = $dir . "/" . $name . "-CDS.fasta";
            
            $seqout = new Bio::SeqIO(-format => 'fasta',
			   					     -file   => ">$output");

			print STDERR "Processing file \'$name$suffix\':\n";
			$feat_count = 0;
			while ( $seq = $seqio->next_seq ) {			
				for $feat_object ($seq->get_SeqFeatures) {    
					if ( uc($feat_object->primary_tag) eq "CDS" ) {
						
						$feat_count++;
						$global_cds_count++;
						
						if ($feat_object->has_tag("locus_tag")) {
							@locus_tag = $feat_object->get_tag_values("locus_tag");
							print $locus_tag[0] . "\t" if ( $print );
							$id = $locus_tag[0];
						}
						else {
							print STDERR "No \'locus_tag\' found for feature $feat_count, using 'CDS$feat_count' as tag: ";
							$id = "CDS$feat_count";
						}
						
						if ($feat_object->has_tag("product")) {
							@product = $feat_object->get_tag_values("product");
							$desc = $product[0];
						}
						else {
							$desc = "unknown product";
						}
						
						
						$cds_seq = $feat_object->seq;
						$cds_seq->id($id);
						$cds_seq->desc($desc);
						
						# Uncomment to see what should be printed to the output FASTA files
						# print STDERR "\n>" . $cds_seq->id . "    " . $cds_seq->desc . "\n" .  $cds_seq->seq . "\n";
						$seqout->write_seq($cds_seq);
						
						print "\"" . $cds_seq->desc . "\"\t" . length($cds_seq->seq) . "\n" if ( $print );
						
					}	
				}							 
			}
        }    
    }

