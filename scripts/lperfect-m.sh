#!/usr/bin/env bash
# lperfect-m.sh
#

module load ompi-4.1.0-gcc-8.3.1

# Check if the application root is set
if [ "$HIWEFAI_ROOT" == "" ]
then
  echo "HIWEFAI_ROOT not defined!"
  exit -1
fi

# Get the parameters

# The date of the first image in iso 8601 UTC
iso8601=$1

# Simulation time
simulationTime=$2

# The file produced by the wr_to_rainrate.py
wrInput=$3 # The Rainrate

# ToDo: add parameters check and usage

# Set the current directory
THISDIR=`pwd`

# Create the data/output directory
mkdir -p $THISDIR/data/output 2>/dev/null

# Create the data/restart directory
mkdir -p $THISDIR/data/restart 2>/dev/null

# Create the data/forcing directory
mkdir -p $THISDIR/data/forcing 2>/dev/null

# Link the wrf
ln -sf $HIWEFAI_ROOT/models/lperfect-m/data/forcing/wrf_d02.nc $THISDIR/data/forcing/wrf_d02.nc

# Link the ws
ln -sf $HIWEFAI_ROOT/models/lperfect-m/data/forcing/ws.nc $THISDIR/data/forcing/ws.nc

# Link the best model in the checkpoint directory
ln -sf $HIWEFAI_ROOT/models/lperfect-m/data/domain.nc $THISDIR/data/domain.nc


# Link the radar data
ln -sf $wrInput $THISDIR/data/input


# Link the lperfect-m script
ln -sf $HIWEFAI_ROOT/models/lperfect-m/LPERFECT-M/main.py .

# Link the model core
ln -sf $HIWEFAI_ROOT/models/lperfect-m/LPERFECT-M/lperfect .

# Link the input files in data/input
ln -sf $wrInput $THISDIR/data/input


# Create the configuration file
cat >> config.json << EOF
{
  "domain": {
    "mode": "netcdf",
    "varmap": {
      "dem": "dem",
      "d8": "d8",
      "cn": "cn",
      "channel_mask": "channel_mask",
      "x": "longitude",
      "y": "latitude"
    }
  },
  "domains": [
    {
      "name": "italy_20251223",
      "domain_nc": "$THISDIR/data/domain.nc",
      "output": {
        "out_netcdf": "$THISDIR/data/output/history.nc",
        "save_every_s": 0,
        "rotate_every_s": 3600,
        "outflow_geojson": null,
        "Conventions": "CF-1.10",
        "title": "LPERFECT flood depth + hydrogeological risk index",
        "institution": "UniParthenope"
      },
      "restart": {
        "in": null,
        "out": "$THISDIR/data/restart/restart.nc",
        "every": 120,
        "strict_grid_check": true
      }
    }
  ],
  "model": {
    "start_time": "$iso8601",
    "T_s": $simulationTime,
    "dt_s": 30,
    "encoding": "esri",
    "ia_ratio": 0.2,
    "particle_vol_m3": 0.25,
    "travel_time_s": 5,
    "travel_time_channel_s": 1,
    "travel_time_mode": "auto",
    "travel_time_auto": {
      "hillslope_velocity_ms": 0.5,
      "channel_velocity_ms": 1.5,
      "min_s": 0.25,
      "max_s": 3600.0
    },
    "outflow_sink": true,
    "log_every": 10
  },
  "rain": {
    "schema": {
      "time_var": "time",
      "lat_var": "latitude",
      "lon_var": "longitude",
      "rain_var": "rain_rate",
      "crs_var": "crs",
      "time_units": "hours since 1900-01-01 00:00:0.0",
      "rate_units": "mm h-1",
      "require_cf": true,
      "require_time_dim": true
    },
    "sources": {
      "rain": {
        "kind": "netcdf",
        "path": "$THISDIR/data/input/radar.nc",
        "var": "rain_rate",
        "time_var": "time",
        "select": "previous",
        "mode": "intensity_mmph",
        "weight": 0.4
      },
      "wrf": {
        "kind": "netcdf",
        "path": "$THISDIR/data/forcing/wrf_d02.nc",
        "var": "rain_rate",
        "time_var": "time",
        "select": "previous",
        "mode": "intensity_mmph",
        "weight": 0.2
      },
      "ws": {
        "kind": "netcdf",
        "path": "$THISDIR/data/forcing/ws.nc",
        "var": "rain_rate",
        "time_var": "time",
        "select": "previous",
        "mode": "intensity_mmph",
        "weight": 0.4
      }
    }
  },
  "risk": {
    "enabled": true,
    "balance": 0.15,
    "p_low": 5.0,
    "p_high": 95.0
  },
  "restart": {
    "in": null,
    "out": "$THISDIR/data/restart.nc",
    "every": 120,
    "strict_grid_check": true
  },
  "output": {
    "out_netcdf": "$THISDIR/data/history.nc",
    "save_every_s": 0,
    "rotate_every_s": 3600,
    "outflow_geojson": null,
    "Conventions": "CF-1.10",
    "title": "LPERFECT flood depth + hydrogeological risk index",
    "institution": "UniParthenope",
    "variables": ["flood_depth", "risk_index", "inundation_mask"]
  },
  "compute": {
    "device": "cpu",
    "mpi": {
      "enabled": true,
      "decomposition": "balanced",
      "min_rows_per_rank": 8
    },
    "shared_memory": {
      "enabled": false,
      "workers": 1,
      "min_particles_per_worker": 20000
    }
  }
}
EOF

# Set CONDA environment
source /opt/share/sw/anaconda/anaconda3/etc/profile.d/conda.sh
conda activate hiwefai_lperfect-m

# NB: this script is run on an HPC cluster
# If conda doesn't works, try to understand why
# Everythong goes wrong, just execute on the frontend
# using TaskType.BATCH


# Run the the model
mpirun python main.py --config config.json

cp $THISDIR/data/output/history_0000.nc $HIWEFAI_ROOT/data/output/history_0000.nc
