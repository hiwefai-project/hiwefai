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

# The date of the first image in iso 8601 UTC
iso8601=$1 

# The time interval in seconds between images, for example 600 is 10 minutes
dt=$2

# The file produced by the rain predictor
wrInput=$3

echo $wrInput

# ToDo: add parameters check and usage

# Set the current directory
THISDIR=`pwd`

# Create the data/output directory
mkdir -p $THISDIR/data/output 2>/dev/null

# Link the best model in the checkpoint directory
ln -sf $HIWEFAI_ROOT/models/lperfect-m/data/domain.nc $THISDIR/data/domain.nc

# Link the predict script
ln -sf $HIWEFAI_ROOT/models/lperfect-m/LPERFECT-M/utils/wr_to_rainrate.py $THISDIR

# Link the input files in data/input
ln -sf $wrInput $THISDIR/data/input

# Set CONDA environment
source /opt/share/sw/anaconda/anaconda3/etc/profile.d/conda.sh
conda activate hiwefai_lperfect-m

# RUn weather radar to rain rate
python wr_to_rainrate.py \
  --input-dir $THISDIR/data/input \
  --output $THISDIR/data/output/radar.nc \
  --time $iso8601 \
  --dt $dt \
  --domain $THISDIR/data/domain.nc \
  --source-name "DPC radar mosaic" \
  --institution "Italian Department of Civil Protection" \
  --source "https://data.meteo.uniparthenope.it/instruments/rdr0"


