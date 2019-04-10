#Adding support to GCS
from pathlib import Path
from snakemake.remote.GS import RemoteProvider as GSRemoteProvider
GS = GSRemoteProvider()

GS_INPUT = "mw_test_metagenomics"
GS_PREFIX = GS_INPUT

shell.executable("/bin/bash")
shell.prefix("source $HOME/.bashrc; ")

IDS,  = glob_wildcards("runs/{id}.txt")
IDS2, = glob_wildcards("runs/{id}.txt")

######################################################
#
#
# rule "all" is the default rule that Snakemake runs
# this rule basically pulls data through the entire
# pipeline by specifying the final outputs of the
# pipeline as input. The rule does nothing
#
#
######################################################


rule all:
	input: GS.remote(expand(GS_PREFIX + "/checkm/{sample}.checkm.txt", sample=IDS))

######################################################
#
#
# staging rules - these are designed to run each stage
# of the pipleine one after the other
#
#
######################################################

rule run_cutadapt:
	input: GS.remote(expand(GS_PREFIX + "/trimmed/{sample}_1.t.fastq.gz", sample=IDS))

rule run_megahit:
	input: GS.remote(expand(GS_PREFIX + "/megahit/{sample}/final.contigs.fa", sample=IDS))

rule run_bwa_index:
	input: GS.remote(expand(GS_PREFIX + "/bwa_indices/{sample}.fa.ann", sample=IDS))

rule run_bwa_mem:
	input: GS.remote(expand(GS_PREFIX + "/bam/{sample}.{sample2}.bam.flagstat", sample=IDS, sample2=IDS2))

rule run_coverage:
	input: GS.remote(expand(GS_PREFIX + "/coverage/{sample}.{sample2}.txt", sample=IDS, sample2=IDS2))

rule run_metabat2:
	input: GS.remote(expand(GS_PREFIX + "/metabat2/{sample}/{sample}.unbinned.fa", sample=IDS))

rule run_checkm:
	input: GS.remote(expand(GS_PREFIX + "/checkm/{sample}.checkm.txt", sample=IDS))

######################################################
#
#
# The actual rules
#
#
######################################################

rule cutadapt:
	input: "runs/{id}.txt"

	output:
		R1=GS.remote(GS_PREFIX + "/trimmed/{id}_1.t.fastq.gz"),
		R2=GS.remote(GS_PREFIX + "/trimmed/{id}_2.t.fastq.gz")
	params:
		id="{id}"
	conda: "envs/cutadapt.yaml"
	threads: 4
	shell: "curl https://raw.githubusercontent.com/WatsonLab/GoogleMAGs/master/scripts/ftp_n_trimm.sh | bash -s {params.id} {output.R1} {output.R2}"


rule megahit:
	input:
		R1=GS.remote(GS_PREFIX + "/trimmed/{id}_1.t.fastq.gz"),
		R2=GS.remote(GS_PREFIX + "/trimmed/{id}_2.t.fastq.gz")
	params:
		di=GS.remote(GS_PREFIX + "/megahit/{id}")
	output: 
		fa=GS.remote(GS_PREFIX + "/megahit/{id}/final.contigs.fa")
	conda: "envs/megahit.yaml"
	threads: 8
	shell: "mkdir -p {params.di} && megahit --continue --k-list 27,47,67,87 --kmin-1pass -m 0.95 --min-contig-len 1000 -t {threads} -1 {input.R1} -2 {input.R2} -o {params.di}"


rule bwa_index:
	input:  GS.remote(GS_PREFIX + "/megahit/{id}/final.contigs.fa")
	output: 
		ann=GS.remote(GS_PREFIX + "/bwa_indices/{id}.fa.ann"),
		pac=GS.remote(GS_PREFIX + "/bwa_indices/{id}.fa.pac"),
		amb=GS.remote(GS_PREFIX + "/bwa_indices/{id}.fa.amb"),
		bwt=GS.remote(GS_PREFIX + "/bwa_indices/{id}.fa.bwt"),
		sa =GS.remote(GS_PREFIX + "/bwa_indices/{id}.fa.sa")
	params:
		idx=GS.remote(GS_PREFIX + "/bwa_indices/{id}.fa")
	conda: "envs/bwa.yaml"
	threads: 8
	shell:
		'''
		bwa index -p {params.idx} {input}
		'''

rule bwa_mem:
	input:
		R1=GS.remote(GS_PREFIX + "/trimmed/{id}_1.t.fastq.gz"),
		R2=GS.remote(GS_PREFIX + "/trimmed/{id}_2.t.fastq.gz"),
		ann=GS.remote(GS_PREFIX + "/bwa_indices/{id2}.fa.ann"),
		pac=GS.remote(GS_PREFIX + "/bwa_indices/{id2}.fa.pac"),
		amb=GS.remote(GS_PREFIX + "/bwa_indices/{id2}.fa.amb"),
		bwt=GS.remote(GS_PREFIX + "/bwa_indices/{id2}.fa.bwt"),
		sa =GS.remote(GS_PREFIX + "/bwa_indices/{id2}.fa.sa")
	output: 
		bam=GS.remote(GS_PREFIX + "/bam/{id}.{id2}.bam"),
		bai=GS.remote(GS_PREFIX + "/bam/{id}.{id2}.bam.bai"),
		fla=GS.remote(GS_PREFIX + "/bam/{id}.{id2}.bam.flagstat")
	params:
		idx=GS.remote(GS_PREFIX + "/bwa_indices/{id2}.fa")
	conda: "envs/bwa.yaml"
	threads: 8
	shell: 
		'''
		bwa mem -t 8 {params.idx} {input.R1} {input.R2} | samtools sort -@8 -m 500M -o {output.bam} -
		samtools index {output.bam}

		samtools flagstat {output.bam} > {output.fla}
		'''
	
rule coverage:
	input: 
		bam=GS.remote(GS_PREFIX + "/bam/{id}.{id2}.bam"),
		bai=GS.remote(GS_PREFIX + "/bam/{id}.{id2}.bam.bai")
	output:
		cov=GS.remote(GS_PREFIX + "/coverage/{id}.{id2}.txt")
	conda: "envs/metabat2.yaml"
	shell:
		'''
		jgi_summarize_bam_contig_depths --outputDepth {output.cov} {input.bam}
		'''	

rule metabat2:
	input:
		asm=GS.remote(GS_PREFIX + "/megahit/{id}/final.contigs.fa"),
		cov=GS.remote(GS_PREFIX + "/coverage/{id}.{id2}.txt")
	output:
		unb=GS.remote(GS_PREFIX + "/metabat2/{id}/{id}.unbinned.fa"),
		dir=GS.remote(GS_PREFIX + "/metabat2/{id}/")
	params:
		out=GS.remote(GS_PREFIX + "/metabat2/{id}/{id}")
	threads: 9
	conda: "envs/metabat2.yaml"
	shell:
		'''
		metabat2 -t {threads} -i {input.asm} -a {input.cov} --unbinned -o {params.out}
		'''

rule checkm_data:
	output: GS.remote(GS_PREFIX + "/checkm_data")
	shell:
		'''
		mkdir -p {output}
		cd {output}
		wget https://data.ace.uq.edu.au/public/CheckM_databases/checkm_data_2015_01_16.tar.gz
		gunzip < checkm_data_2015_01_16.tar.gz | tar xvf -
		cd ..
		'''

rule checkm:
	input:
		dir=GS.remote(GS_PREFIX + "/metabat2/{id}/"),
		cin=GS.remote(GS_PREFIX + "/checkm_data")
	output: GS.remote(GS_PREFIX + "/checkm/{id}.checkm.txt")
	params:
		dir=GS.remote(GS_PREFIX + "/checkm/{id}")
	threads: 8
	conda: "envs/checkm.yaml"
	shell:
		'''
		echo {input.cin} | checkm data setRoot {input.cin}
		checkm lineage_wf --tab_table -f {output} --reduced_tree -t {threads} -x fa {input.dir} {params.dir}
		'''

