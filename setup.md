## Steps

Before you start you will need a Google Cloud Platform account, you will need to set up a billing account (either credit card or by invoice), you will need to set up a project (e.g. called ```my_project``` and you will need to make sure your billing account is linked to your project.

Then:

### 1. Get a GCP VM

Log in to google cloud platform, create a small basic VM and SSH into it

We currently use:

* Debian GNU/Linux 9 (stretch) 
* 1 vCPU
* 5.5Gb RAM
* "Allow full access to all Cloud APIs"
* Allow http and https traffic
* Use default service account

### 2 update some tools on the VM

```sh
sudo apt-get update

sudo apt-get install git bzip2
```

### 3 download and install conda

```sh
wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh

# install it
sh Miniconda3-latest-Linux-x86_64.sh

# review license
# accept license
# accept or change home location
# yes to placing it in your path

# source .bashrc
source $HOME/.bashrc

# update conda (just because)
conda update -n base conda
```

### 4 Clone this github repo

Clone this git hub repo.

### 5 create the cloud metagenomics env and activate it

```sh
conda env create -f envs/google_cloud_metagenomics.yaml
source activate google_cloud_metagenomics
```

### 6 install additional stuff

```sh
pip install --upgrade google-api-python-client
pip install google-cloud-storage
pip install kubernetes 
```

### 7 create a bucket for pipeline inputs/outputs

In the google cloud console, go to Storage -> Browser and create a new bucket

Regional is fine but make sure it's the same region as the kubernetes cluster and your VM

Let's assume your bucket is called ```my_bucket```

### 8 copy runs folder to bucket

I am not sure quite yet why they need to match but they do

```sh
gsutil cp -r runs gs://my_bucket
```

### 9 Authorise

```sh
gcloud auth login
```

Click on the link, authorise and copy back the code to the console

```sh
gcloud auth application-default login 
```

Follow the same process

```sh
gcloud config set project my_project # set to project
```

Use the name of your project in the above command

### 10 trial run

```sh
snakemake -np -s Snakefile --default-remote-provider GS --default-remote-prefix my_bucket
```

This should produce

```
Job counts:
        count   jobs
        1       all
        2       bwa_index
        4       bwa_mem
        2       checkm
        1       checkm_data
        2       coverage
        2       cutadapt
        2       megahit
        2       metabat2
        18
```

### 11 set up Kubernetes cluster

```
export CLOUDSDK_CONTAINER_USE_APPLICATION_DEFAULT_CREDENTIALS=true # environment variable needed to make conda gcloud work

gcloud container clusters get-credentials mw-metagenomics --zone europe-west1-b # get credentials for my kubernetes cluster
```

### 12 run it

```
snakemake -p --verbose --keep-remote -j 4000 --kubernetes -s Snakefile --default-remote-provider GS --default-remote-prefix my_bucket --use-conda 
```
