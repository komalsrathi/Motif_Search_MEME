#!/usr/bin/perl -w
use Parallel::ForkManager;
use Data::Dumper;

my $paramfile = $ARGV[0]; 

my $cmd;

# push motif names with starting with V_ in samples
# $cmd="grep V_ /NGSshare/matrix_files/matrix.meme | awk '{print \$2}' > /NGSshare/motif_db/motiflist_TRANSFAC.txt";
# print $cmd,"\n";
# system($cmd);

#read in param file and create a hash of all the parameters. 
open PARAM, $paramfile or die print $!;
my %param;
while(<PARAM>){
        chomp;
        @r = split('=>');
        #print "@r";
        $param{$r[0]}=$r[1];
}

my $genome = $param{'GENOME'};

$param{'fimo_output'} = $param{'PROJECTNAME'}.'/'.$genome.'/fimo_output';
$param{'bed_files'} = $param{'PROJECTNAME'}.'/'.$genome.'/bed_files';
$param{'results'} = $param{'PROJECTNAME'}.'/'.$genome.'/results';

# make dirs
system("mkdir $param{'PROJECTNAME'}") unless (-d $param{'PROJECTNAME'});
system("mkdir $param{'fimo_output'}") unless (-d $param{'fimo_output'});
system("mkdir $param{'bed_files'}") unless (-d $param{'bed_files'});
system("mkdir $param{'results'}") unless (-d $param{'results'});


#open the motif file containing vertebrates' motifs
my @samples;
open (FILE,'motiflist_TRANSFAC.txt');
while(<FILE>)
{
        chomp;
        push(@samples,$_);
}

#run 10 parallel jobs
my $pm=new Parallel::ForkManager(20);

my $CUTOFF = 1e-5;

foreach (@samples)
{       
        $pm->start and next;
        #print $_;
        #run fimo and generate a fimo.txt       
        $cmd="/opt/meme/bin/fimo --text --motif $_ --bgfile /NGSshare/$genome"."_data/$genome"."_genome_markov /NGSshare/matrix_files/matrix.meme /NGSshare/$genome"."_data/$genome"."_repeatmasked.fa > $param{'fimo_output'}/$_.txt";
        print $cmd,"\n";
        system($cmd);   
        
        # open $_.txt to convert it to a $_.bed file
        open (FIMO,'<',"$param{'fimo_output'}/$_.txt");

        # open a bed file in append mode
        open(my $bed, '>>', "$param{'bed_files'}/$_.bed");

        # print to bed file that is already opened in append mode
        print $bed "track name=$_ description=$_ useScore=1 \n";
        <FIMO>;
        while(<FIMO>)
        {
                chomp; 
                my @r = split('\t');
                #Use p value
                next if $r[6] > $CUTOFF;
                $r[6] = -log($r[6])*50;
                $r[6] = 1000 if $r[6] > 1000;
                $r[6] = int $r[6];
                print $bed join("\t",@r[1,2,3,0,6,4]),"\n";
        }
        close $bed;
        
        print "$_ completed\n"; 
        $pm->finish;
}

$pm->wait_all_children;
print "\nbed files completed.....\n";

# concatenate all bed files and sort the final bed file
$cmd="cat $param{'bed_files'}/*.bed | bedtools sort -i - > $param{'results'}/$genome"."_wholegenome_fimo.bed";
print $cmd,"\n";
system($cmd);

# convert bed to bigbed
$cmd="bedToBigBed $param{'results'}/$genome"."_wholegenome_fimo.bed /NGSshare/$genome".".chrom.sizes $param{'results'}/$genome"."_wholegenome_fimo.bb";
print $cmd,"\n";
system($cmd);
