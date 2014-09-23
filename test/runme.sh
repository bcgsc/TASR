echo Downloading NGS reads
wget ftp://ftp.bcgsc.ca/supplementary/SSAKE/SRR066437.fastq.bz2
echo Decompressing
bunzip2 SRR066437.fastq.bz2
echo Running TASR
../TASR -s targets.fa -f foobar.fof -m 15 -c 1 -u 1
