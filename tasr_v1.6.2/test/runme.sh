echo Downloading NGS reads
wget http://www.bcgsc.ca/downloads/supplementary/SSAKE/SRR066437.fastq.bz2
echo Decompressing
bunzip2 SRR066437.fastq.bz2
echo Running TASR in reference-guided assembly mode -i 0
../TASR -s targets.fa -f NGSreads.fof -m 15 -c 1 -u 1 -i 0 -b referenceGuided
echo Running TASR in de novo assembly mode -i 1
../TASR -s targets.fa -f NGSreads.fof -m 15 -c 1 -i 1 -b deNovo
