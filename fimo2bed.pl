#!/usr/bin/perl
use strict;
use warnings;

my $usage = q(
Program to convert fimo.txt to bed file
fimo2bed.pl fimo.txt
);

my $CUTOFF = 1e-5;
# requirement check
if (scalar(@ARGV) != 1) {
    print $usage;
    exit
}

open FIMO, $ARGV[0] or die print $!;

my $name = ($ARGV[1])?$ARGV[1]:$ARGV[0];  
$name =~ s/.txt//;

open(my $bed, '>', 'allgenes.bed');

print $bed "track name=$name description=$name useScore=1 \n";

<FIMO>;
while(<FIMO>){
	chomp; 
	my @r = split('\t');
	# Use p value
	next if $r[6] > $CUTOFF;
	$r[6]=-log($r[6])*50;
	$r[6] = 1000 if $r[6] > 1000;
	print $bed join("\t",@r[1,2,3,0,6,4]),"\n";
}
