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

# Link geojson input
ln -sf $HIWEFAI_ROOT/models/lperfect-m/data/limits_IT_provinces.geojson $THISDIR/data/limits_IT_provinces.geojson

# Link the predict script
ln -sf $HIWEFAI_ROOT/models/lperfect-m/LPERFECT-M/utils/output_to_geo.py $THISDIR

# Set CONDA environment
source /opt/share/sw/anaconda/anaconda3/etc/profile.d/conda.sh
conda activate hiwefai_lperfect-m

# Run output_plot
python output_to_geo.py \
  --nc $inputFile \
  --geojson-in $THISDIR/data/limits_IT_provinces.geojson \
  --geojson-out $THISDIR/data/output/risk.geojson \
  --stats-mode fast \
  --area-weighting coslat \
  --all-touched

cp $THISDIR/data/output/risk.geojson $HIWEFAI_ROOT/data/output/
