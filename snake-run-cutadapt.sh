#!/bin/bash

set -x #echo on
RULE=run_cutadapt
RUNID=16
CLUSTERNAME=metagenomics-benchmarking
CLUSTERZONE=europe-west1-d
GSPREFIX=metagenomics-benchmarking
DOCKERIMAGE='gcr.io/tagareby/snakemake'

snakemake -s $SNAKEFILE --unlock

#Run run_cutadapt
gsutil -m rm -r gs://metagenomics-benchmarking/trimmed
SAMPLES=2
SNAKEFILE=Snakefile.sc.pig${SAMPLES}
gcloud container clusters update $CLUSTERNAME --update-labels sample-count=$SAMPLES,rule=$RULE,run-id=$RUNID --zone $CLUSTERZONE
snakemake  -p --verbose --keep-remote  -j 400 --kubernetes -s $SNAKEFILE --default-remote-provider GS  --default-remote-prefix $GSPREFIX --use-conda $RULE --container-image $DOCKERIMAGE

sleep 10m
snakemake  -p --verbose --keep-remote  -j 400 --kubernetes -s $SNAKEFILE --default-remote-provider GS  --default-remote-prefix $GSPREFIX --use-conda $RULE --container-image $DOCKERIMAGE

#Run run_cutadapt
gsutil -m rm -r gs://metagenomics-benchmarking/trimmed
SAMPLES=5
SNAKEFILE=Snakefile.sc.pig${SAMPLES}
gcloud container clusters update $CLUSTERNAME --update-labels sample-count=$SAMPLES,rule=$RULE,run-id=$RUNID --zone $CLUSTERZONE
snakemake  -p --verbose --keep-remote  -j 400 --kubernetes -s $SNAKEFILE --default-remote-provider GS  --default-remote-prefix $GSPREFIX --use-conda $RULE --container-image $DOCKERIMAGE

sleep 10m
snakemake  -p --verbose --keep-remote  -j 400 --kubernetes -s $SNAKEFILE --default-remote-provider GS  --default-remote-prefix $GSPREFIX --use-conda $RULE --container-image $DOCKERIMAGE

#Run run_cutadapt
gsutil -m rm -r gs://metagenomics-benchmarking/trimmed
SAMPLES=15
SNAKEFILE=Snakefile.sc.pig${SAMPLES}
gcloud container clusters update $CLUSTERNAME --update-labels sample-count=$SAMPLES,rule=$RULE,run-id=$RUNID --zone $CLUSTERZONE
snakemake  -p --verbose --keep-remote  -j 400 --kubernetes -s $SNAKEFILE --default-remote-provider GS  --default-remote-prefix $GSPREFIX --use-conda $RULE --container-image $DOCKERIMAGE

sleep 10m
snakemake  -p --verbose --keep-remote  -j 400 --kubernetes -s $SNAKEFILE --default-remote-provider GS  --default-remote-prefix $GSPREFIX --use-conda $RULE --container-image $DOCKERIMAGE

#Run run_cutadapt
gsutil -m rm -r gs://metagenomics-benchmarking/trimmed
SAMPLES=25
SNAKEFILE=Snakefile.sc.pig${SAMPLES}
gcloud container clusters update $CLUSTERNAME --update-labels sample-count=$SAMPLES,rule=$RULE,run-id=$RUNID --zone $CLUSTERZONE
snakemake  -p --verbose --keep-remote  -j 400 --kubernetes -s $SNAKEFILE --default-remote-provider GS  --default-remote-prefix $GSPREFIX --use-conda $RULE --container-image $DOCKERIMAGE

sleep 10m
snakemake  -p --verbose --keep-remote  -j 400 --kubernetes -s $SNAKEFILE --default-remote-provider GS  --default-remote-prefix $GSPREFIX --use-conda $RULE --container-image $DOCKERIMAGE

#Run run_cutadapt
gsutil -m rm -r gs://metagenomics-benchmarking/trimmed
SAMPLES=50
SNAKEFILE=Snakefile.sc.pig${SAMPLES}
gcloud container clusters update $CLUSTERNAME --update-labels sample-count=$SAMPLES,rule=$RULE,run-id=$RUNID --zone $CLUSTERZONE
snakemake  -p --verbose --keep-remote  -j 400 --kubernetes -s $SNAKEFILE --default-remote-provider GS  --default-remote-prefix $GSPREFIX --use-conda $RULE --container-image $DOCKERIMAGE

sleep 10m
snakemake  -p --verbose --keep-remote  -j 400 --kubernetes -s $SNAKEFILE --default-remote-provider GS  --default-remote-prefix $GSPREFIX --use-conda $RULE --container-image $DOCKERIMAGE

#Run run_cutadapt
gsutil -m rm -r gs://metagenomics-benchmarking/trimmed
SAMPLES=100
SNAKEFILE=Snakefile.sc.pig${SAMPLES}
gcloud container clusters update $CLUSTERNAME --update-labels sample-count=$SAMPLES,rule=$RULE,run-id=$RUNID --zone $CLUSTERZONE
snakemake  -p --verbose --keep-remote  -j 800 --kubernetes -s $SNAKEFILE --default-remote-provider GS  --default-remote-prefix $GSPREFIX --use-conda $RULE --container-image $DOCKERIMAGE

sleep 10m
snakemake  -p --verbose --keep-remote  -j 800 --kubernetes -s $SNAKEFILE --default-remote-provider GS  --default-remote-prefix $GSPREFIX --use-conda $RULE --container-image $DOCKERIMAGE

#Run run_cutadapt
gsutil -m rm -r gs://metagenomics-benchmarking/trimmed
SAMPLES=238
SNAKEFILE=Snakefile.sc.pig${SAMPLES}
gcloud container clusters update $CLUSTERNAME --update-labels sample-count=$SAMPLES,rule=$RULE,run-id=$RUNID --zone $CLUSTERZONE
snakemake  -p --verbose --keep-remote  -j 2000 --kubernetes -s $SNAKEFILE --default-remote-provider GS  --default-remote-prefix $GSPREFIX --use-conda $RULE --container-image $DOCKERIMAGE

sleep 10m
snakemake  -p --verbose --keep-remote  -j 2000 --kubernetes -s $SNAKEFILE --default-remote-provider GS  --default-remote-prefix $GSPREFIX --use-conda $RULE --container-image $DOCKERIMAGE


#Reset labels
gcloud container clusters update $CLUSTERNAME --update-labels sample-count=0,rule=idle,run-id=0 --zone $CLUSTERZONE
