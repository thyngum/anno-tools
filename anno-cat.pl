#!/usr/bin/perl

# Concatenates a set of annotated files into a single file with the same format. Joins the input
# sequences and appends the annotations with corrected coordinates. Output is saved to an "anno.cat"
# file or to the file specified with the -out option.

# 	anno-cat.pl -f <format> [-out <filename>] <file(s)>

#   	-f <format>	Output format (required). Should accept most of the annotated formats,
#	               	but only tested with Genbank/EMBL.

use Bio::SeqIO;
use Bio::SeqUtils;
use File::Basename;
use File::Spec;
use Getopt::Long;

GetOptions ( 'f=s' => \$format, 'out=s' => \$output );

my $count = 0;
my @files = ();

die "Usage: anno-cat.pl -f <format> [-out <filename>] <file(s)>\n" if ( ! $format or ! @ARGV );


foreach my $item ( @ARGV ) {
	next if ($item =~ m/^\./); # ignoring files beginning with a period

	if ( -f $item ) {
		(my $name, my $path, my $suffix) = fileparse($item, qr/\.[^.]*/);	

	    my $filename = $path . "/" . $name . $suffix;

		$count++;
    	push @files, $filename;
	} 
	else {
		die "File \'$item\' not found!\n";
	}
}


die "Enter two or more input files!\n" if ( @files <= 1 );

if ( ! $output ) {
	$output = $path . "/anno.cat";
}
else {
	($name, $path, $suffix) = fileparse($output, qr/\.[^.]*/);
    $output = $path . "/" . $name . $suffix;	
}

if ( -e $output ) {
	unlink $output;
}

my @seqs = ();
foreach my $file ( @files ) {
	print STDERR  "$file .. added\n";

   	$seqio = new Bio::SeqIO(-format => $format,
	                        -file   => $file);

	while ( my $seq = $seqio->next_seq) {
		push @seqs, $seq;
	}
}

my $seqout = new Bio::SeqIO(-format => $format,
                            -file   => ">$output");

Bio::SeqUtils->cat(@seqs);

$seqout->write_seq($seqs[0]);

print STDERR "\n$count files concatenated!\n";

