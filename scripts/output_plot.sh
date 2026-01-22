#!/usr/bin/env bash
# output_plot.sh
#

# Check if the application root is set
if [ "$HIWEFAI_ROOT" == "" ]
then
  echo "HIWEFAI_ROOT not defined!"
  exit -1
fi

# Get the parameters

# The input file
inputFile=$1 

# ToDo: add parameters check and usage

# Set the current directory
THISDIR=`pwd`

# Create the data/output directory
mkdir -p $THISDIR/data/output 2>/dev/null

# Link the best model in the checkpoint directory
ln -sf $HIWEFAI_ROOT/models/lperfect-m/data/domain.nc $THISDIR/data/domain.nc

# Link the predict script
ln -sf $HIWEFAI_ROOT/models/lperfect-m/LPERFECT-M/utils/output_plot.py $THISDIR

# Set CONDA environment
source /opt/share/sw/anaconda/anaconda3/etc/profile.d/conda.sh
conda activate hiwefai_lperfect-m

# Run output_plot
python output_plot.py \
  --flood $inputFile \
  --domain $THISDIR/data/domain.nc \
  --bbox 13.7 39.9 15.9 41.6 \
  --out $THISDIR/output/flood_campania.png
