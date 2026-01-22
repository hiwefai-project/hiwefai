#!/usr/bin/env bash
# rainpredictor.sh
#

# Check if the application root is set
if [ "$HIWEFAI_ROOT" == "" ]
then
  echo "HIWEFAI_ROOT not defined!"
  exit -1
fi

# Get the parameters
wrPrev=$1
wrNext=$2
wrInput=$3

# ToDo: add parameters check and usage

# Set the current directory
THISDIR=`pwd`

# Create the data/output directory
mkdir -p $THISDIR/data/output 2>/dev/null

# Create the checkpoints directory
mkdir -p $THISDIR/checkpoints

# Link the best model in the checkpoint directory
ln -sf $HIWEFAI_ROOT/models/rainpredictor/data/checkpoints/20251207Z082748_hiwefi_best_model.pth $THISDIR/checkpoints/best_model.pth

# Link the predict script
ln -sf $HIWEFAI_ROOT/models/rainpredictor/RainPredictor/predict.py .

# Link the model core
ln -sf $HIWEFAI_ROOT/models/rainpredictor/RainPredictor/rainpred .

# Link the input files in data/input
ln -sf $wrInput $THISDIR/data/input

# Set CONDA environment
source /opt/share/sw/anaconda/anaconda3/etc/profile.d/conda.sh
conda activate hiwefai_rainpredictor


# NB: this script is run on an HPC cluster
# If conda doesn't works, try to understand why
# Everythong goes wrong, just execute on the frontend
# using TaskType.BATCH


# Run the predict
python3 predict.py --input-dir $THISDIR/data/input/ --checkpoint $THISDIR/checkpoints/best_model.pth --output-dir $THISDIR/data/output/ -n $wrNext -m $wrPrev
