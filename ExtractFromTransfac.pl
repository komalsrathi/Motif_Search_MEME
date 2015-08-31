#!/usrbin/perl

open MAT, "matrix.dat";

open LIST, 'motiflist_TRANSFAC.txt' or die print $!;

my %motifs;
while(<LIST>){
        chomp;
        s/\w\_//;
        print $_;
        $motifs{$_}++;
}

local $/='//';

my $foo = <MAT>;
print $foo;
while(<MAT>){
/ID\s+\w\$(\w+)/;
print $_ if $motifs{$1};
#exit;

}

# motiflist_TRANSFAC.txt is file with TFs per new line as below:
# V_MYOD_01
# V_E47_01

# matrix.dat can be downloaded from TRANSFAC
