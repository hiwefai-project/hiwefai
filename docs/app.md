# `app.py` workflow guide

The `app.py` script defines the DAGonStar scientific workflow used by the Hi-WeFAI demonstrator. It assembles tasks into a directed acyclic graph (DAG) and executes them on local or scheduled resources.

## Responsibilities of `app.py`

- **Workflow definition**: Declares the DAGonStar tasks and their dependencies.
- **Task configuration**: Maps each task to a shell script in `scripts/` and supplies arguments.
- **Execution mode**: Chooses task types (local shell, SLURM, or batch) based on your environment.
- **Orchestration**: Ensures downstream tasks only run when upstream data products are complete.

## How DAGonStar tasks are structured

A DAGonStar workflow typically includes:

1. **Inputs**: Paths or URLs provided to the workflow.
2. **Tasks**: Each task runs a shell script with input/output paths.
3. **Dependencies**: Downstream tasks depend on upstream outputs.
4. **Outputs**: Final artifacts are written to task output folders.

In Hi-WeFAI, those tasks include (high level):

- **download**: Retrieve radar scans from URLs.
- **rainPredictor**: Produce predicted frames.
- **compare**: Compare predicted vs. observed scans.
- **wr_to_rainrate**: Convert reflectivity to rain rate.
- **lperfectm**: Run the LPERFECT-M model.
- **output_plot**: Render plots for visualization.

## Creating your own DAGonStar workflow

To create a new workflow in `app.py` (or a new script modeled after it):

1. **Define inputs**
   - Decide which files, URLs, or parameters are needed.
   - Parse them from the CLI or configuration.

2. **Declare tasks**
   - Use DAGonStar task constructors to define each workflow stage.
   - Point each task at a `scripts/*.sh` file.
   - Provide parameters such as input files, output directories, and any model-specific options.

3. **Set dependencies**
   - Order tasks so outputs from one are inputs to the next.
   - Ensure parallelizable tasks do not depend on one another unless needed.

4. **Choose execution backends**
   - Set `TaskType.SLURM` for HPC or `TaskType.BATCH`/local for workstations.
   - Confirm that the appropriate scheduler configurations are in `dagon.ini`.

5. **Run and monitor**
   - Execute `python app.py` with the desired input queue.
   - Monitor logs and output directories for completion.

## Tips for DAGonStar workflow development

- Keep each task script focused on one responsibility.
- Write outputs into deterministic directories so downstream tasks can locate them reliably.
- If you need to debug a single task, run its script directly from `scripts/` with a subset of data.
- Use the same `config.json` paths in `app.py` so local and WebSocket-driven runs behave consistently.
