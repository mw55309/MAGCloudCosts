# MAGCloudCosts
Costing MAG creation on the cloud

## Steps

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
conda install -c conda-forge google-cloud-sdk 
```
