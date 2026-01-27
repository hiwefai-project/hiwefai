# December 23rd, 2025 use case (Campania Region, 14:00Z–15:00Z)

This guide describes the workflow for the December 23rd, 2025, demonstrator run focused on the Campania Region, from 14:00Z to 15:00Z. It assumes you are operating the Hi-WeFAI workflow in simulation mode with archived radar scans.

## Narrative overview

At 14:00Z on December 23rd, 2025, the Campania Region is expected to experience a short-lived but intense precipitation event. The demonstrator runs replays the radar scans for that hour, executes the RainPredictor model to estimate near-term evolution, and then runs LPERFECT-M to generate hydrological outputs (e.g., discharge estimations) for the area.

All datasets used in this use case are available for download [here](https://data.meteo.uniparthenope.it/extras/hiwefai/).

The workflow combines:

1. **Radar ingestion** from archived scans.
2. **Nowcasting** via RainPredictor to fill the next time steps.
3. **Hydrological modeling** with LPERFECT-M.
4. **Visualization** of outputs for situational awareness.

## Technical prerequisites

- Archived radar scans for Campania between 14:00Z and 15:00Z are available to the simulated WebSocket server.
- `config.json` points to the correct host/port and paths for replaying stored scans.
- The RainPredictor and LPERFECT-M model data assets have been downloaded.

## Step-by-step runbook

### 1. Prepare the data directories

Ensure the data tarballs have been extracted:

```bash
ls models/rainpredictor/data
ls models/lperfectm/data
ls data
```

### 2. Confirm configuration

Update `config.json` for the Campania use case:

- Set the replay directory for the simulated radar server to the Campania datasets.
- Ensure the WebSocket host/port match what the client will connect to.
- Confirm the output directories are writable.

### 3. Start the simulated radar server

```bash
python opt/weather-radar-utilities/weather-radar-websocket-server.py --config config.json
```

### 4. Start the WebSocket client

```bash
./run.sh
```

Monitor the client logs to confirm it receives frames that align with the 14:00Z–15:00Z window.

### 5. Observe workflow execution

When enough frames arrive, the workflow starts automatically:

- **download**: stores incoming scans in the download directory.
- **rainPredictor**: generates predicted frames for the next intervals.
- **wr_to_rainrate**: converts to rain rate for hydrological modeling.
- **lperfectm**: runs the hydrological model to estimate outputs.
- **output_plot**: produces plots for review.

### 6. Review outputs

Outputs are written to the task-specific `data/output` directories. For the December 23rd use case, archive the outputs with a timestamp (e.g., `data/output/2025-12-23T1400Z`) so they can be shared with stakeholders.

## Validation checklist

- [ ] Radar scans cover the 14:00Z–15:00Z window for Campania.
- [ ] The WebSocket client receives the expected number of frames.
- [ ] RainPredictor outputs are generated in the expected output folder.
- [ ] LPERFECT-M outputs are produced without errors.
- [ ] Plots are generated and accessible via the configured output directory.

## Operational notes

- If you need to rerun the use case, clear the output directories to prevent mixing outputs from previous runs.
- Keep a copy of `config.json` and the logs from the WebSocket client for traceability.
- If SLURM is unavailable, update `app.py` to use local task execution.
