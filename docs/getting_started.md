# Getting started

This guide provides a step-by-step walkthrough for running the Hi-WeFAI application demonstrator end-to-end.

## 1. Complete installation and configuration

- Follow the installation guide to clone dependencies and install Python requirements.
- Update `etc/profile`, `dagon.ini`, and `config.json` to match your environment.

## 2. Start the simulated radar server

The demonstrator expects a weather-radar WebSocket server. In simulation mode, it replays stored radar scans.

```bash
python opt/weather-radar-utilities/weather-radar-websocket-server.py --config config.json
```

Keep this running in its own terminal tab.

## 3. Start the WebSocket client

The client listens for radar updates and triggers the workflow once enough frames arrive.

```bash
./run.sh
```

If your environment uses a module system, ensure the same modules are loaded as in `run.sh`.

## 4. Run the workflow directly (optional)

You can bypass the WebSocket client by sending URLs directly to `app.py`:

```bash
python app.py --queue "<url1> <url2> ... <urlN>"
```

Or use the preconfigured sample queue:

```bash
./app.sh
```

## 5. Inspect outputs

Workflow outputs are stored in task-specific `data/output` directories and include plots plus model outputs.

## 6. Troubleshooting quick checks

- Verify `config.json` points to the correct WebSocket host and port.
- Confirm the required data tarballs have been downloaded and extracted.
- If SLURM is unavailable, change `TaskType.SLURM` tasks to local execution in `app.py`.
