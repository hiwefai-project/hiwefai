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

# Link the domain deifnition
ln -sf $HIWEFAI_ROOT/models/lperfect-m/data/domain.nc $THISDIR/data/domain.nc

# Link the administrative boundaries geojson
ln -sf $HIWEFAI_ROOT/models/lperfect-m/data/limits_IT_municipalities.geojson $THISDIR/data/boundaries.geojson

# Link the predict script
ln -sf $HIWEFAI_ROOT/models/lperfect-m/LPERFECT-M/utils/output_plot.py $THISDIR

# Set CONDA environment
source /opt/share/sw/anaconda/anaconda3/etc/profile.d/conda.sh
conda activate hiwefai_lperfect-m

# Run output_plot
python output_plot.py \
  --flood $inputFile \
  --plot-var flood_depth \
  --domain $THISDIR/data/domain.nc \
  --overlay-notext $THISDIR/data/boundaries.geojson \
  --bbox 13.7 39.9 15.9 41.6 \
  --out $HIWEFAI_ROOT/data/output/campania_flood_depth.png


python output_plot.py \
  --flood $inputFile \
  --plot-var risk_index \
  --domain $THISDIR/data/domain.nc \
  --overlay-notext $THISDIR/data/boundaries.geojson \
  --bbox 13.7 39.9 15.9 41.6 \
  --out $HIWEFAI_ROOT/data/output/campania_risk_index.png

python output_plot.py \
  --flood $inputFile \
  --plot-var inundation_mask \
  --domain $THISDIR/data/domain.nc \
  --overlay-notext $THISDIR/data/boundaries.geojson \
  --bbox 13.7 39.9 15.9 41.6 \
  --out $HIWEFAI_ROOT/data/output/campania_inundation_mask.png

#######################################################################

python output_plot.py \
  --flood $inputFile \
  --plot-var flood_depth \
  --domain $THISDIR/data/domain.nc \
  --overlay-notext $THISDIR/data/boundaries.geojson \
  --bbox 13.8 40.6 14.9 41.2 \
  --out $HIWEFAI_ROOT/data/output/provna_flood_depth.png

python output_plot.py \
  --flood $inputFile \
  --plot-var risk_index \
  --domain $THISDIR/data/domain.nc \
  --overlay-notext $THISDIR/data/boundaries.geojson \
  --bbox 13.8 40.6 14.9 41.2 \
  --out $HIWEFAI_ROOT/data/output/provna_risk_index.png

python output_plot.py \
  --flood $inputFile \
  --plot-var inundation_mask \
  --domain $THISDIR/data/domain.nc \
  --overlay-notext $THISDIR/data/boundaries.geojson \
  --bbox 13.8 40.6 14.9 41.2 \
  --out $HIWEFAI_ROOT/data/output/provna_inundation_mask.png

#######################################################################

python output_plot.py \
  --flood $inputFile \
  --plot-var flood_depth \
  --domain $THISDIR/data/domain.nc \
  --overlay-notext $THISDIR/data/boundaries.geojson \
  --bbox 14.14 40.78 14.30 40.88 \
  --out $HIWEFAI_ROOT/data/output/naples_flood_depth.png

python output_plot.py \
  --flood $inputFile \
  --plot-var risk_index \
  --domain $THISDIR/data/domain.nc \
  --overlay-notext $THISDIR/data/boundaries.geojson \
  --bbox 14.14 40.78 14.30 40.88 \
  --out $HIWEFAI_ROOT/data/output/naples_risk_index.png

python output_plot.py \
  --flood $inputFile \
  --plot-var inundation_mask \
  --domain $THISDIR/data/domain.nc \
  --overlay-notext $THISDIR/data/boundaries.geojson \
  --bbox 14.14 40.78 14.30 40.88 \
  --out $HIWEFAI_ROOT/data/output/naples_inundation_mask.png

