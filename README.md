# hiwefai
DAGonStar scientific workflow application running the Hi-WeFAI Project demonstrator.

## Prerequisites

The Hi-WeFAI application is a fully working pure Python prototype.
It has been tested on Linux and MacOS. On Windows was never tested, but probably it works.
Minimal configuration in Linux/MacOS
64 GB of RAM
4 computing CPU cores
NVIDIA CUDA GPU -- optional.
Minimum Python version 3.11

## Install
* Clone the repository from https://github.com/hiwefai-project/hiwefai.git
* Set the application root path in etc/profile
* In models/rainpredictor, clone the https://github.com/hiwefai-project/RainPredictor.git model
* In models/lperfectm, clone the https://github.com/hiwefai-project/LPERFECT-M.git model
* In opt, clone the https://github.com/hiwefai-project/weather-radar-utilities.git repository
* In models/rainpredictor/data, download the file https://data.meteo.uniparthenope.it/extras/hiwefai/rainpredictor-data.tar.gz
* Uncompress and remove the file.
* In models/lperfectm/data, download the file https://data.meteo.uniparthenope.it/extras/hiwefai/lperfectm-data.tar.gz
* Uncompress and remove the file.
* In data, download the file https://data.meteo.uniparthenope.it/extras/hiwefai/data.tar.gz
* Uncompress and remove the file.
* Setup the environment

  - Activate the Python runtime.
  - Create the Python environment.
  - Install the requirements.
  
  For example:
  ```bash

  module load python/3.11.14 gcc-9.9.1 openssl/3.6.0 cuda/12.4 netcdf/4.8.1-gcc-8.3.1
  python3 -m venv .venv
  . .venv/bin/activate
  pip3 install -r requirements.txt

  ```
  

## Use case

## Output
