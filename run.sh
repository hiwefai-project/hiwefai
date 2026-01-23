#!/bin/bash

module load python/3.11.14 gcc-9.9.1 openssl/3.6.0 cuda/12.4 netcdf/4.8.1-gcc-8.3.1

cd "$(dirname "$0")"
source .venv/bin/activate
source etc/profile

python3 main.py
