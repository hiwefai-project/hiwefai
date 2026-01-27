# Hi-WeFAI

DAGonStar scientific workflow application running the Hi-WeFAI Project demonstrator. The repository orchestrates a weather-radar-driven workflow that downloads radar scans, predicts future frames, converts radar to rain rate, and runs the LPERFECT-M hydrological model to generate outputs. The workflow is built around DAGonStar tasks and can be executed directly or triggered by a WebSocket client that collects radar updates.

## DAGonStar (aka DAGon*)
DAGonStar (Directed Acyclic Graph on anything) is a lightweight Python library implementing a workflow engine able to execute parallel jobs represented by directed acyclic graphs on any combination of local machines, on-premise high-performance computing clusters, containers, and cloud-based virtual infrastructures. Learn more on the [project page](https://github.com/DagOnStar/dagonstar).

## What’s included

- **Workflow driver**: `app.py` defines the DAGonStar workflow graph and the SLURM/BATCH tasks it runs.
- **WebSocket client**: `main.py` listens for radar updates and launches the workflow when enough inputs have arrived.
- **Shell entry points**: `app.sh` runs a sample workflow with fixed URLs; `run.sh` starts the WebSocket client.
- **Task scripts**: `scripts/` contains the concrete shell scripts invoked by each workflow task.
- **Configuration**: `config.json`, `dagon.ini`, and `etc/profile` centralize runtime settings.

## Repository layout

```
.
├── app.py                # DAGonStar workflow definition
├── app.sh                # Example workflow invocation with sample URLs
├── main.py               # WebSocket client that triggers the workflow
├── config.json           # Shared runtime configuration for the client/server
├── dagon.ini             # DAGonStar configuration
├── etc/profile           # Project-specific environment settings
├── models/               # External model repositories (cloned)
├── opt/                  # External utilities (cloned)
├── scripts/              # Workflow task scripts
├── data/                 # Downloaded data assets (tarball extract)
└── run.sh                # Start the WebSocket client
```

## Prerequisites

The Hi-WeFAI application is a fully functional, pure-Python prototype.

Tested platforms:
- Linux
- macOS (limited testing)

Hardware/software guidelines:
- 64 GB RAM
- 4 CPU cores
- NVIDIA CUDA GPU (optional)
- Python 3.11+
- A SLURM environment for `TaskType.SLURM` steps (or adjust task types for local runs)

## Install

1. Clone the repository.
   ```bash
   git clone https://github.com/hiwefai-project/hiwefai.git
   cd hiwefai
   ```

2. Set the application root path in `etc/profile` (update `HIWEFAI_ROOT`).

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

6. Create and activate a Python environment, then install requirements.
   ```bash
   python3 -m venv .venv
   . .venv/bin/activate
   pip3 install -r requirements.txt
   ```

> **Tip:** If you use a module system (e.g., on HPC clusters), align with the versions in `app.sh` and `run.sh`.

## Configuration

- `config.json` controls the WebSocket client/server, download behavior, and local web server settings.
- `dagon.ini` contains DAGonStar runtime configuration.
- `etc/profile` defines project-level environment variables used by the shell scripts.

Adjust these files to match your environment (paths, ports, scheduler settings, etc.).

## Documentation

- [Installation guide](docs/install.md)
- [Configuration guide](docs/configure.md)
- [Getting started](docs/getting_started.md)
- [`app.py` workflow guide](docs/app.md)
- [Launcher scripts guide](docs/launcher_scripts.md)
- [December 23rd, 2025 use case](docs/use_case.md)

## Running the server

The download and provisioning weather radar server must be configured in simulation mode in order to produce radar images previously stored. Before starting the server, confirm that `config.json` points to the replay directory containing archived radar scans and that the WebSocket host/port match what the client expects. If you want the server to be reachable from another machine, bind to `0.0.0.0` in the configuration.

Start the server in its own terminal so it can stream frames while the client is running:
```bash
python opt/weather-radar-utilities/weather-radar-websocket-server.py --config config.json
```

After it starts, verify that it is listening on the configured port and that it is reading from the expected replay directory. Leave it running while you start the WebSocket client or invoke `app.py` directly.

## Running the workflow

### Option 1: Run the workflow directly

Provide a list of radar image URLs to `app.py`:

```bash
python app.py --queue "<url1> <url2> ... <urlN>"
```

For a ready-to-run example that uses a sample queue, use:

```bash
./app.sh
```

### Option 2: Run the WebSocket client

The WebSocket client listens for radar updates and triggers the workflow once enough inputs are buffered.

```bash
./run.sh
```

Update `config.json` to point to your WebSocket server or to enable the simulated radar stream.

## Workflow steps (high level)

The DAGonStar workflow in `app.py` currently runs the following steps:

1. **download** – download radar scans from the provided URLs.
2. **rainPredictor** – generate synthetic radar scans using the RainPredictor model.
3. **compare** – compare predicted vs. observed frames (placeholder task).
4. **wr_to_rainrate** – convert radar reflectivity to rain rate.
5. **lperfectm** – run the LPERFECT-M hydrological model.
6. **output_plot** – generate plots from LPERFECT-M outputs.

Task commands and parameters are defined in `scripts/` and within `app.py`.

## Output

Outputs are written to the workflow’s task-specific `data/output` folders and include plots and model artifacts (see `scripts/output_plot.sh` and `scripts/output_to_geo.sh`).

## Troubleshooting

- Ensure `etc/profile` points to the correct application root.
- Confirm that cloned model repositories are placed in the expected `models/` subdirectories.
- Check `config.json` for correct WebSocket and web server ports.
- If SLURM is unavailable, consider updating `TaskType.SLURM` steps in `app.py` to a local execution type.
