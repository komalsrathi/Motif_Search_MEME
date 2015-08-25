#!/usr/bin/perl
use strict;
use warnings;

#$ARGV[0]='/home/mmorley/dsdata/projects/mouse_lincRNA/Motif/Canidates/fimo/fimo.txt';
my $usage = q(
Program to convert fimo.txt to bed file
fimo2bed.pl fimo.txt
);
my $CUTOFF = 0.05;
# requirement check
if (scalar(@ARGV) != 1) {
    print $usage;
    exit
}

open FIMO, $ARGV[0] or die print $!;

my $name = ($ARGV[1])?$ARGV[1]:$ARGV[0];  
$name =~ s/.txt//;

open(my $bed, '>', 'fimo001.bed');

print $bed "track name=$name description=$name useScore=1 \n";

<FIMO>;
while(<FIMO>){
	chomp; 
	my @r = split('\t');
	print $r[6],$r[7];
	print "\n";
	next if $r[7] > $CUTOFF;
	$r[7]=-log($r[7])*100;
	$r[7] = 1000 if $r[7] > 1000;
	print $bed join("\t",@r[1,2,3,0,7,4]),"\n";
#	last;
}

close $bed;
