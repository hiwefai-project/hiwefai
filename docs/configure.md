# Configuration guide (`config.json`)

The `config.json` file centralizes settings for the WebSocket client/server, download behavior, and the local web server used by the workflow. Update it to match your environment before running the demonstrator.

> **Tip:** Keep a backup of your original `config.json` so you can revert to defaults.

## File structure overview

A typical `config.json` includes sections like:

- **WebSocket settings**: host, port, and mode for the radar stream.
- **Downloader settings**: where to store radar scans and how many to buffer.
- **Server settings**: local HTTP server and file paths.

Use the structure below as a checklist while editing.

## WebSocket settings

- **Host and port**: Ensure the client and server settings point to the same host and port.
- **Simulation mode**: When testing, enable simulation mode for the weather radar server so it replays pre-existing radar scans from disk.
- **Buffering**: Confirm the expected buffer length matches the workflow requirements (for example, how many input frames are required before the workflow starts).

**Recommended steps:**
1. Decide whether you are running a simulated radar server or connecting to a live one.
2. Align the `host` and `port` values with the server you start in the “Running the server” section of the README.
3. Set the buffer/queue size to the minimum number of frames your workflow needs.

## Download settings

- **Download root**: Path where radar scans are stored before processing.
- **Temporary directories**: Confirm any scratch or temp paths exist and are writable.
- **Cleanup behavior**: If the configuration supports cleanup toggles, keep them enabled during development so repeated runs do not consume disk space.

**Recommended steps:**
1. Point download paths to a local filesystem with enough free space for large radar datasets.
2. Keep the directory within the project tree if you plan to archive outputs with the repository.

## Local web server settings

- **Static file root**: Location of rendered plots and outputs served by the local HTTP server.
- **Port**: The port that `app.py` or other scripts use to expose outputs.
- **Binding**: Use `0.0.0.0` if you need to access the server remotely.

**Recommended steps:**
1. Keep the static root under `data/` or a dedicated output folder.
2. Ensure the port does not conflict with other services on your system.

## Validation checklist

After editing `config.json`, verify:

- [ ] All paths are absolute or correctly relative to the project root.
- [ ] The WebSocket server and client ports match.
- [ ] Simulation mode is enabled when replaying stored radar scans.
- [ ] Output directories exist or can be created by the workflow.

## Example workflow

1. Edit `config.json` with your chosen host, ports, and paths.
2. Start the simulated radar server.
3. Start the WebSocket client.
4. Run the workflow and confirm outputs appear in the configured output directories.
