#!/bin/sh

cd /Volumes/Brumfield_Lab_Drive/mike_data/6_seqcap_pop/Campephilus_rubricollis/
: '
mkdir 5_mapping 5_mapping/bam 5_mapping/sam 6_picard 6_picard/bam_cleaned 6_picard/mark_pcr_duplicates 
mkdir 6_picard/mark_pcr_metrics 6_picard/read_groups 7_merge-bams 8_GATK
mkdir 9_SNP-tables 10_sequences 11_fasta-parts 12_raw-alignments 13_processed-phylip 14_formatted_output
mkdir 14_formatted_output/adegenet 14_formatted_output/gphocs 14_formatted_output/structure 14_formatted_output/faststructure 14_formatted_output/genepop


# in this document you will need to replace the following:
# sample names in steps 4-8, step 9, and steps 21-23
# reference individual "Campephilus_rubricollis_LSUMNS15139.fasta"
# all instances of "Campephilus_rubricollis" with the name of your taxon

# paths to GATK, picard, and seqcap_pop scripts
# the maximum java ram permitted on your system (e.g. 'java -Xmx16g')

# bwa index

bwa index -a is /Volumes/Brumfield_Lab_Drive/mike_data/mafft-nexus-edge-trimmed-exploded-uncontaminated/Campephilus_rubricollis_LSUMNS15139.fasta

# steps 4-8

for SAMPLE in Campephilus_rubricollis_AMNH3870 Campephilus_rubricollis_FMNH456685 Campephilus_rubricollis_LSUMNS5075 Campephilus_rubricollis_LSUMNS15139 Campephilus_rubricollis_LSUMNS39164 Campephilus_rubricollis_LSUMNS42486 Campephilus_rubricollis_LSUMNS48392 Campephilus_rubricollis_LSUMNS75519 Campephilus_rubricollis_LSUMNS80981 Campephilus_rubricollis_MPEG3577 Campephilus_rubricollis_MPEG7906 
do
	# step 4: map reads to contigs

	/Users/mharvey/src/bwa-0.7.17/bwa mem /Volumes/Brumfield_Lab_Drive/mike_data/mafft-nexus-edge-trimmed-exploded-uncontaminated/Campephilus_rubricollis_LSUMNS15139.fasta \
	/Volumes/Brumfield_Lab_Drive/mike_data/2_clean_reads/${SAMPLE}/split-adapter-quality-trimmed/${SAMPLE}-READ1.fastq.gz \
	/Volumes/Brumfield_Lab_Drive/mike_data/2_clean_reads/${SAMPLE}/split-adapter-quality-trimmed/${SAMPLE}-READ2.fastq.gz \
	> 5_mapping/sam/${SAMPLE}-aln-pe.sam

	# step 5: convert sam to bam
	
	samtools view -bS 5_mapping/sam/${SAMPLE}-aln-pe.sam \
	> 5_mapping/bam/${SAMPLE}-aln-pe.bam

	# step 6: clean bam

	java -jar ~/anaconda/jar/CleanSam.jar \
	I=5_mapping/bam/${SAMPLE}-aln-pe.bam \
	O=6_picard/bam_cleaned/${SAMPLE}-aln-pe_CL.bam \
	VALIDATION_STRINGENCY=SILENT


	# step 7: add read groups

	java -Xmx16g -jar ~/anaconda/jar/AddOrReplaceReadGroups.jar \
	I=6_picard/bam_cleaned/${SAMPLE}-aln-pe_CL.bam \
	O=6_picard/read_groups/${SAMPLE}-aln_RG.bam \
	SORT_ORDER=coordinate \
	RGPL=illumina \
	RGPU=TestXX \
	RGLB=Lib1 \
	RGID=${SAMPLE} \
	RGSM=${SAMPLE} \
	VALIDATION_STRINGENCY=LENIENT

	# step 8: mark PCR duplicate reads

	java -Xmx16g -jar ~/anaconda/jar/MarkDuplicates.jar \
	I=6_picard/read_groups/${SAMPLE}-aln_RG.bam \
	O=6_picard/mark_pcr_duplicates/${SAMPLE}-aln_MD.bam \
	METRICS_FILE=6_picard/mark_pcr_metrics/${SAMPLE}.metrics \
	MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=250 \
	ASSUME_SORTED=true \
	REMOVE_DUPLICATES=false

done

# step 9: merge bams

java -Xmx16g -jar ~/anaconda/jar/MergeSamFiles.jar \
SO=coordinate \
AS=true \
I=6_picard/mark_pcr_duplicates/Campephilus_rubricollis_AMNH3870-aln_MD.bam \
I=6_picard/mark_pcr_duplicates/Campephilus_rubricollis_FMNH456685-aln_MD.bam \
I=6_picard/mark_pcr_duplicates/Campephilus_rubricollis_LSUMNS5075-aln_MD.bam \
I=6_picard/mark_pcr_duplicates/Campephilus_rubricollis_LSUMNS15139-aln_MD.bam \
I=6_picard/mark_pcr_duplicates/Campephilus_rubricollis_LSUMNS39164-aln_MD.bam \
I=6_picard/mark_pcr_duplicates/Campephilus_rubricollis_LSUMNS42486-aln_MD.bam \
I=6_picard/mark_pcr_duplicates/Campephilus_rubricollis_LSUMNS48392-aln_MD.bam \
I=6_picard/mark_pcr_duplicates/Campephilus_rubricollis_LSUMNS75519-aln_MD.bam \
I=6_picard/mark_pcr_duplicates/Campephilus_rubricollis_LSUMNS80981-aln_MD.bam \
I=6_picard/mark_pcr_duplicates/Campephilus_rubricollis_MPEG3577-aln_MD.bam \
I=6_picard/mark_pcr_duplicates/Campephilus_rubricollis_MPEG7906-aln_MD.bam \
O=7_merge-bams/Campephilus_rubricollis.bam 


# step 10: index bams


samtools index 7_merge-bams/Campephilus_rubricollis.bam 

'
# steps 11 and 12: create and index dictionary

java -Xmx16g -jar ~/anaconda/pkgs/picard-1.106-0/jar/CreateSequenceDictionary.jar \
R=/Volumes/Brumfield_Lab_Drive/mike_data/mafft-nexus-edge-trimmed-exploded-uncontaminated/Campephilus_rubricollis_LSUMNS15139.fasta \
O=/Volumes/Brumfield_Lab_Drive/mike_data/mafft-nexus-edge-trimmed-exploded-uncontaminated/Campephilus_rubricollis_LSUMNS15139.dict

samtools faidx /Volumes/Brumfield_Lab_Drive/mike_data/mafft-nexus-edge-trimmed-exploded-uncontaminated/Campephilus_rubricollis_LSUMNS15139.fasta


# step 13: call indels

java -Xmx16g -jar ~/anaconda/GenomeAnalysisTK-3.3-0/GenomeAnalysisTK.jar \
-T RealignerTargetCreator \
-R /Volumes/Brumfield_Lab_Drive/mike_data/mafft-nexus-edge-trimmed-exploded-uncontaminated/Campephilus_rubricollis_LSUMNS15139.fasta \
-I 7_merge-bams/Campephilus_rubricollis.bam   \
--minReadsAtLocus 7 \
-o 8_GATK/Campephilus_rubricollis.intervals



# step 14: realign indels

java -Xmx16g -jar ~/anaconda/GenomeAnalysisTK-3.3-0/GenomeAnalysisTK.jar \
-T IndelRealigner \
-R /Volumes/Brumfield_Lab_Drive/mike_data/mafft-nexus-edge-trimmed-exploded-uncontaminated/Campephilus_rubricollis_LSUMNS15139.fasta \
-I 7_merge-bams/Campephilus_rubricollis.bam  \
-targetIntervals 8_GATK/Campephilus_rubricollis.intervals \
-LOD 3.0 \
-o 8_GATK/Campephilus_rubricollis_RI.bam


# step 15: call SNPs

java -Xmx16g -jar ~/anaconda/GenomeAnalysisTK-3.3-0/GenomeAnalysisTK.jar \
-T UnifiedGenotyper \
-R /Volumes/Brumfield_Lab_Drive/mike_data/mafft-nexus-edge-trimmed-exploded-uncontaminated/Campephilus_rubricollis_LSUMNS15139.fasta \
-I 8_GATK/Campephilus_rubricollis_RI.bam \
-gt_mode DISCOVERY \
-o 8_GATK/Campephilus_rubricollis_raw_SNPs.vcf \
-ploidy 2 \
-rf BadCigar


# step 16: annotate SNPs

java -Xmx16g -jar ~/anaconda/GenomeAnalysisTK-3.3-0/GenomeAnalysisTK.jar \
-T VariantAnnotator \
-R /Volumes/Brumfield_Lab_Drive/mike_data/mafft-nexus-edge-trimmed-exploded-uncontaminated/Campephilus_rubricollis_LSUMNS15139.fasta \
-I 8_GATK/Campephilus_rubricollis_RI.bam \
-G StandardAnnotation \
-V:variant,VCF 8_GATK/Campephilus_rubricollis_raw_SNPs.vcf \
-XA SnpEff \
-o 8_GATK/Campephilus_rubricollis_SNPs_annotated.vcf \
-rf BadCigar      



# step 17: annotate indels

java -Xmx16g -jar ~/anaconda/GenomeAnalysisTK-3.3-0/GenomeAnalysisTK.jar \
-T UnifiedGenotyper \
-R /Volumes/Brumfield_Lab_Drive/mike_data/mafft-nexus-edge-trimmed-exploded-uncontaminated/Campephilus_rubricollis_LSUMNS15139.fasta \
-I 8_GATK/Campephilus_rubricollis_RI.bam \
-gt_mode DISCOVERY \
-glm INDEL \
-o 8_GATK/Campephilus_rubricollis_SNPs_indels.vcf \
-rf BadCigar         



# step 18: mask indels

java -Xmx16g -jar ~/anaconda/GenomeAnalysisTK-3.3-0/GenomeAnalysisTK.jar \
-T VariantFiltration \
-R /Volumes/Brumfield_Lab_Drive/mike_data/mafft-nexus-edge-trimmed-exploded-uncontaminated/Campephilus_rubricollis_LSUMNS15139.fasta \
-V 8_GATK/Campephilus_rubricollis_raw_SNPs.vcf \
--mask 8_GATK/Campephilus_rubricollis_SNPs_indels.vcf \
--maskExtension 5 \
--maskName InDel \
--clusterWindowSize 10 \
--filterExpression "MQ0 >= 4 && ((MQ0 / (1.0 * DP)) > 0.1)" \
--filterName "BadValidation" \
--filterExpression "QUAL < 30.0" \
--filterName "LowQual" \
--filterExpression "QD < 5.0" \
--filterName "LowVQCBD" \
-o 8_GATK/Campephilus_rubricollis_SNPs_no_indels.vcf  \
-rf BadCigar


# step 19: Restrict to high-quality SNPs (bash)

cat 8_GATK/Campephilus_rubricollis_SNPs_no_indels.vcf | grep 'PASS\|^#' > 8_GATK/Campephilus_rubricollis_SNPs_pass-only.vcf 


# step 20: Read-backed phasing (GATK)


java -Xmx16g -jar ~/anaconda/GenomeAnalysisTK-3.3-0/GenomeAnalysisTK.jar \
-T ReadBackedPhasing \
-R /Volumes/Brumfield_Lab_Drive/mike_data/mafft-nexus-edge-trimmed-exploded-uncontaminated/Campephilus_rubricollis_LSUMNS15139.fasta \
-I 8_GATK/Campephilus_rubricollis_RI.bam \
--variant 8_GATK/Campephilus_rubricollis_SNPs_pass-only.vcf \
-L 8_GATK/Campephilus_rubricollis_SNPs_pass-only.vcf \
-o 8_GATK/Campephilus_rubricollis_SNPs_phased.vcf \
--phaseQualityThresh 20.0 \
-rf BadCigar



# steps 21-23

for SAMPLE in Campephilus_rubricollis_AMNH3870 Campephilus_rubricollis_FMNH456685 Campephilus_rubricollis_LSUMNS5075 Campephilus_rubricollis_LSUMNS15139 Campephilus_rubricollis_LSUMNS39164 Campephilus_rubricollis_LSUMNS42486 Campephilus_rubricollis_LSUMNS48392 Campephilus_rubricollis_LSUMNS75519 Campephilus_rubricollis_LSUMNS80981 Campephilus_rubricollis_MPEG3577 Campephilus_rubricollis_MPEG7906 
do

	java -Xmx16g -jar ~/anaconda/GenomeAnalysisTK-3.3-0/GenomeAnalysisTK.jar \
	-T SelectVariants \
	-R /Volumes/Brumfield_Lab_Drive/mike_data/mafft-nexus-edge-trimmed-exploded-uncontaminated/Campephilus_rubricollis_LSUMNS15139.fasta \
	--variant 8_GATK/Campephilus_rubricollis_SNPs_phased.vcf \
	-o 8_GATK/${SAMPLE}_SNPs.vcf \
	-sn ${SAMPLE} \
	-rf BadCigar


	java -Xmx16g -jar ~/anaconda/GenomeAnalysisTK-3.3-0/GenomeAnalysisTK.jar \
	-T VariantsToTable \
	-R /Volumes/Brumfield_Lab_Drive/mike_data/mafft-nexus-edge-trimmed-exploded-uncontaminated/Campephilus_rubricollis_LSUMNS15139.fasta \
	-V 8_GATK/${SAMPLE}_SNPs.vcf \
	-F CHROM -F POS -F QUAL -GF GT -GF DP -GF HP -GF AD \
	-o 9_SNP-tables/${SAMPLE}_SNPs_phased-table.txt \
	-rf BadCigar


	python /Users/mharvey/seqcap_pop-master/bin/add_phased_snps_to_seqs_filter.py \
	/Volumes/Brumfield_Lab_Drive/mike_data/mafft-nexus-edge-trimmed-exploded-uncontaminated/Campephilus_rubricollis_LSUMNS15139.fasta \
	9_SNP-tables/${SAMPLE}_SNPs_phased-table.txt \
	10_sequences/${SAMPLE}_sequences.txt \
	1


done

: '

# step 24 

python /Users/mharvey/seqcap_pop-master/bin/collate_sample_fastas_GATK.py \
	10_sequences/ \
	11_fasta-parts/ \
	sequences.txt

# step 25: Align the sequences

python /Users/mharvey/seqcap_pop-master/bin/run_mafft.py \
	11_fasta-parts/ \
	12_raw-alignments/


# step 26: Process the alignments

python /Users/mharvey/seqcap_pop-master/bin/process_mafft_alignments_GATK.py \
	12_raw-alignments/ \
	13_processed-phylip/
	
# gphocs

python /Users/mharvey/seqcap_pop-master/bin/gphocs_from_phy.py \
	13_processed-phylip/ \
	14_formatted_output/gphocs/Campephilus_rubricollis_GPHOCS.txt


# structure

python /Users/mharvey/seqcap_pop-master/bin/structure_from_vcf.py \
	8_GATK/Campephilus_rubricollis_SNPs_phased.vcf \
	14_formatted_output/structure/Campephilus_rubricollis_STRUCTURE.txt
	
	
# faststructure

python /Users/mharvey/seqcap_pop-master/bin/faststructure_from_vcf.py \
	8_GATK/Campephilus_rubricollis_SNPs_phased.vcf \
	14_formatted_output/faststructure/ \
	Campephilus_rubricollis \
	--random


# adegenet

python /Users/mharvey/seqcap_pop-master/bin/adegenet_from_vcf.py \
	8_GATK/Campephilus_rubricollis_SNPs_phased.vcf \
	14_formatted_output/adegenet/ \
	Campephilus_rubricollis \
	--random


# genepop

python /Users/mharvey/seqcap_pop-master/bin/genepop_from_vcf.py \
	8_GATK/Campephilus_rubricollis_SNPs_phased.vcf \
	14_formatted_output/genepop/ \
	Campephilus_rubricollis \
	--random


'

source activate phyluce


cd 8_GATK/

# remove indels, restrict to biallelic loci, min mean depth, min quality score
vcftools --vcf Campephilus_rubricollis_SNPs_phased.vcf --remove-indels --min-alleles 2 --max-alleles 2 --minDP 5.5 --minQ 30 --recode --out Campephilus_rubricollis_SNPs_phased_rmIndels_QC_DP

# allow 25% missing data
vcftools --vcf Campephilus_rubricollis_SNPs_phased_rmIndels_QC_DP.recode.vcf --max-missing 0.75 --recode --out Campephilus_rubricollis_SNPs_phased_rmIndels_75_QC_DP

# export mean depth per site
vcftools --vcf Campephilus_rubricollis_SNPs_phased_rmIndels_75_QC_DP.recode.vcf --site-mean-depth --out Campephilus_rubricollis_SNPs_phased

# format files to get one snp per locus
cat Campephilus_rubricollis_SNPs_phased.ldepth.mean | awk '{print $1,$2}' > Campephilus_rubricollis_SNPs_phased_ok.txt

egrep -o "\w+.\w+\s" Campephilus_rubricollis_SNPs_phased_ok.txt | sort -u | parallel 'egrep "{}" Campephilus_rubricollis_SNPs_phased_ok.txt | sort -r | head -1 >> Campephilus_rubricollis_SNPs_phased_random_snps.temp'


# format files
sort -u Campephilus_rubricollis_SNPs_phased_random_snps.temp > Campephilus_rubricollis_SNPs_phased_random_snps.txt

# extract one snp per locus
vcftools --vcf Campephilus_rubricollis_SNPs_phased_rmIndels_75_QC_DP.recode.vcf --positions Campephilus_rubricollis_SNPs_phased_random_snps.txt --recode --out Campephilus_rubricollis_SNPs_phased_rmIndels_75_QC_DP_random

cp Campephilus_rubricollis_SNPs_phased_rmIndels_75_QC_DP_random.recode.vcf /Volumes/Brumfield_Lab_Drive/data/1_analysis/vcf_files_final/

source deactivate

