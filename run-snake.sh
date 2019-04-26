#!/bin/bash
set -x #echo on
SNAKEFILE=$1
RULE=$2
SAMPLES=$3
RUNID=$4
gcloud container clusters update snake-cluster-1 --update-labels sample-count=$SAMPLES,rule=$RULE,run-id=$RUNID --zone europe-west1-b
snakemake  -p --verbose --keep-remote  -j 400 --kubernetes -s $SNAKEFILE --default-remote-provider GS  --default-remote-prefix hn-snakemake --use-conda $RULE
gcloud container clusters update snake-cluster-1 --update-labels sample-count=0,rule=idle,run-id=0 --zone europe-west1-b
