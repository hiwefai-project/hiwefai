# Launcher scripts guide

The `scripts/` directory contains the launcher scripts that are updateable task entry points for the DAGonStar workflow. Each script wraps a model or processing step and exposes a shell interface that DAGonStar can call.

## Script structure

A typical launcher script should:

1. Source environment variables (if needed).
2. Parse positional arguments supplied by `app.py`.
3. Run the underlying model or utility.
4. Write outputs to deterministic paths.

**Recommended template:**

```bash
#!/usr/bin/env bash
set -euo pipefail

# Example: source project environment
# source /path/to/hiwefai/etc/profile

INPUT_PATH="$1"
OUTPUT_DIR="$2"

mkdir -p "${OUTPUT_DIR}"

# Call your model or processing command here
# python some_model.py --input "${INPUT_PATH}" --output "${OUTPUT_DIR}"
```

## Naming conventions

- Use short, descriptive names that match task names (e.g., `download.sh`, `lperfectm.sh`).
- Keep filenames lowercase with underscores if needed.

## Adding a new launcher script

1. Create the script under `scripts/`.
2. Make it executable.
   ```bash
   chmod +x scripts/my_new_task.sh
   ```
3. Update `app.py` to reference the new script in the matching DAGonStar task.
4. Confirm the script runs when invoked manually.

## Best practices

- Keep scripts idempotent: re-running should not break existing outputs.
- Prefer explicit paths over `cd` where possible.
- Capture model logs into a task-specific log file.
- Validate that required inputs exist and exit with a helpful message if not.

## Debugging tips

- Run the script with sample data outside of DAGonStar to validate inputs.
- Add `set -x` temporarily to echo commands during execution.
- Ensure any required environment variables are available (e.g., paths to model checkpoints).
