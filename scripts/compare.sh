#! /bin/bash


if [ "$HIWEFAI_ROOT" == "" ]
then
  echo "HIWEFAI_ROOT not defined!"
  exit -1
fi

# Get the parameters
predDir=$1

# ToDo: add parameters check and usage

# Set the current directory
THISDIR=`pwd`

# Create the data/output directory
mkdir -p $THISDIR/data/ 2>/dev/null

# Link the predict script
ln -sf $HIWEFAI_ROOT/models/rainpredictor/RainPredictor/utils/compare.py .

# Link the colour palette
ln -sf $HIWEFAI_ROOT/models/rainpredictor/RainPredictor/utils/palette.json .

# Link the input files in data/pred
ln -sf $predDir $THISDIR/data/pred

# Link the input files in data/truth
ln -sf $HIWEFAI_ROOT/models/rainpredictor/data/truth $THISDIR/data/truth

# Set CONDA environment
source /opt/share/sw/anaconda/anaconda3/etc/profile.d/conda.sh
conda activate hiwefai_rainpredictor

#python $THISDIR/compare.py --truth-dir $THISDIR/data/truth --pred-dir $THISDIR/data/pred --metrics --metrics-json $THISDIR/data/metrics.json --palette $THISDIR/palette.json --save $THISDIR/data/output.png

echo "python $THISDIR/compare.py --truth-dir $THISDIR/data/truth --pred-dir $THISDIR/data/pred --palette $THISDIR/palette.json --save $THISDIR/data/output.png"

# python $THISDIR/compare.py --truth-dir $THISDIR/data/truth --pred-dir $THISDIR/data/pred --palette $THISDIR/palette.json --save $THISDIR/data/output.png
python $THISDIR/compare.py --truth-dir $THISDIR/data/truth --pred-dir $predDir --palette $THISDIR/palette.json --save $THISDIR/data/output.png
