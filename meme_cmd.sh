# convert transfac matrix.dat to matrix.meme file
transfac2meme matrix.dat matrix.meme

# your bedfile is in $bedfile

# convert your bed file to fasta
# bedtools getfasta & repeatmask
bedtools getfasta -fi mm9.fa -bed $bedfile -fo - | sed -e 's/[acgt]/N/g' - | sed -e 's/>N/>c/g' > ${bedfile%.*}.fasta

# get markov
fasta-get-markov -m 1 <${bedfile%.*}.fasta> ${bedfile%.*}_markov

# this step is not necessary
# get chr info from fasta
# grep chr ${bedfile%.*}.fasta | sed -e 's/\:/ /g' -e 's/\-/ /g' -e 's/>/ /g' > ${bedfile%.*}_chr.txt

# run fimo
fimo --text --bgfile ${bedfile%.*}_markov --parse-genomic-coord matrix.meme ${bedfile%.*}.fasta > ${bedfile%.*}_fimo.txt

# run meme
meme ${bedfile%.*}.fasta -oc meme_output -dna -bfile ${bedfile%.*}_markov -revcomp -p 20 -nostatus -maxsize 1355523

# run tomtom
tomtom -verbosity 1 -oc tomtom_output -min-overlap 5 -dist pearson -evalue -thresh 1 -no-ssc -bfile ${bedfile%.*}_markov meme_output/meme.xml matrix.meme

# run ame
ame --oc ame_output --bgfile ${bedfile%.*}_markov ${bedfile%.*}.fasta matrix.meme
