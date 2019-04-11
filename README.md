# MAGCloudCosts
Costing MAG creation on the cloud

We have six snakefiles:

* Snakefile.pig5
* Snakefile.pig15
* Snakefile.pig25
* Snakefile.pig50
* Snakefile.pig100
* Snakefile.pig238

These will run the pipeline on the samples in the relevant folders, which have 5, 15, 25, 50, 100 and 238 samples in respectively.

Within each Snakefile we have:

* run_cutadapt 
* run_megahit 
* run_bwa_index 
* run_bwa_mem 
* run_coverage 
* run_metabat2 
* run_checkm

These rules will allow staging of the pipeline and can be run in order. They will run all steps up to and including the respective rule.

Therefore to run e.g. 5 samples up to (and including) the bwa_mem stage:

```sh
snakemake -s Snakefile.pig5 [other options here] run_bwa_mem
```


