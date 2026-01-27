# Installation guide

This guide walks through installing the Hi-WeFAI demonstrator with either a Python virtual environment or Conda. It assumes you have cloned the repository and are working from the project root.

## Before you begin

1. Clone the repository and enter it.
   ```bash
   git clone https://github.com/hiwefai-project/hiwefai.git
   cd hiwefai
   ```

2. Set the application root path in `etc/profile`.

3. Clone required model repositories.
   ```bash
   git clone https://github.com/hiwefai-project/RainPredictor.git models/rainpredictor
   git clone https://github.com/hiwefai-project/LPERFECT-M.git models/lperfectm
   ```

4. Clone supporting utilities.
   ```bash
   git clone https://github.com/hiwefai-project/weather-radar-utilities.git opt/weather-radar-utilities
   ```

5. Download the data assets.
   ```bash
   mkdir -p models/rainpredictor/data models/lperfectm/data data

   curl -L -o models/rainpredictor/data/rainpredictor-data.tar.gz \
     https://data.meteo.uniparthenope.it/extras/hiwefai/rainpredictor-data.tar.gz
   tar -xzf models/rainpredictor/data/rainpredictor-data.tar.gz -C models/rainpredictor/data
   rm models/rainpredictor/data/rainpredictor-data.tar.gz

   curl -L -o models/lperfectm/data/lperfectm-data.tar.gz \
     https://data.meteo.uniparthenope.it/extras/hiwefai/lperfectm-data.tar.gz
   tar -xzf models/lperfectm/data/lperfectm-data.tar.gz -C models/lperfectm/data
   rm models/lperfectm/data/lperfectm-data.tar.gz

   curl -L -o data/data.tar.gz \
     https://data.meteo.uniparthenope.it/extras/hiwefai/data.tar.gz
   tar -xzf data/data.tar.gz -C data
   rm data/data.tar.gz
   ```

## Option A: Python virtual environment

1. Create and activate a virtual environment.
   ```bash
   python3 -m venv .venv
   . .venv/bin/activate
   ```

2. Install dependencies.
   ```bash
   pip3 install -r requirements.txt
   ```

3. (Optional) Verify Python and pip point to the venv.
   ```bash
   which python
   which pip
   ```

## Option B: Conda environment

1. Create and activate a Conda environment.
   ```bash
   conda create -n hiwefai python=3.11
   conda activate hiwefai
   ```

2. Install dependencies.
   ```bash
   pip install -r requirements.txt
   ```

3. (Optional) Export the environment for reproducibility.
   ```bash
   conda env export --name hiwefai > hiwefai-environment.yml
   ```

## Post-install checks

- Confirm the DAGonStar configuration exists at `dagon.ini`.
- Confirm `etc/profile` points to your local clone.
- If you are on an HPC system, match module versions to those referenced in `app.sh` and `run.sh`.
- Proceed to the configuration guide to customize `config.json`.
