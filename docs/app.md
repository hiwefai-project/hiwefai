# `app.py` workflow guide with inline commentary

This guide embeds the `app.py` workflow script in blocks, adding narrative context for each section so you can understand how the DAGonStar workflow is assembled end-to-end.

## Imports and dependencies

The script begins by importing DAGonStar workflow primitives and standard CLI parsing tools.

```python
from dagon import Workflow, DataMover, StagerMover
from dagon.task import DagonTask, TaskType
import argparse
```

**Why it matters:** `Workflow` and `DagonTask` define the DAG nodes and edges. `TaskType` identifies the execution backend (batch vs. SLURM). `argparse` is used to collect runtime parameters from the command line.

## Command-line argument parsing

The helper function below parses the URL list that seeds the download task.

```python

def parse_args():
    parser = argparse.ArgumentParser(description="")
    parser.add_argument("--queue", type=str, help="List of url from queue")
    return parser.parse_args()
```

**Why it matters:** DAGonStar workflows are often parameterized with external inputs. Here, the `--queue` argument provides the list of radar image URLs to fetch.

## Entrypoint and CLI setup

The script uses the standard Python entrypoint guard and captures the parsed CLI arguments.

```python

if __name__ == '__main__':


    parser = parse_args()
```

**Why it matters:** This prevents accidental execution when the module is imported. The parsed arguments (`parser.queue`) are later used when building the download task.

## Workflow metadata and script location

A new workflow is created and the base directory for helper scripts is declared.

```python
    
    # Create the workflow
    workflow = Workflow("HiWeFAI-Demo", config_file="dagon.ini")

    # The application root
    hiwefai_root = "/projects/HiWeFAI/hiwefai"
    command_dir_base = hiwefai_root + "/scripts/"
```

**Why it matters:** `Workflow(...)` sets the DAG’s identity and loads configuration from `dagon.ini`. The script directory is then used to assemble shell command paths for each task.

## Domain parameters for the workflow

The workflow uses several fixed parameters (later passed to the shell scripts).

```python
    # ToDo: set those parameters by command line
    m = 18 
    n = 6
    time_interval = 600
    iso8601 = "2025-12-23T14:00:00Z"
    simulation_time = 3600
```

**Why it matters:** These constants shape the prediction window, timestamps, and simulation horizon. They are noted as candidates for future CLI exposure.

## High-level workflow outline

This comment block documents the planned workflow stages.

```python
    # Workflow
    # Task A (BATCH) Leggi gli n file tiff dalle url della coda ---> nessuna dipendenza di dati 
    # Task B (SLURM) RainPredict --->  
    # Task C (SLURM) LPERFECTM
    #### I vari task per l'allarme e per l'output
```

**Why it matters:** Even though the comments are informal, they sketch the DAG structure: download, prediction, conversion, simulation, and output steps.

## Task: download input radar data

The first task reads the URL queue and downloads the input imagery.

```python

    # Root Task - download weather radar images from given URL list
    cmd_download = "{}/download.sh {}".format(command_dir_base, parser.queue)
    task_download = DagonTask(TaskType.BATCH, "download", cmd_download)
```

**Why it matters:** This task is the root of the DAG. It runs in batch mode and generates the initial dataset that all downstream tasks consume.

## Task: generate synthetic radar predictions

The prediction step uses prior frames to generate `n` predicted frames.

```python
    # RainPredictor - generates n synthetic weather radar images using m previous images
    cmd_rainpredictor = "{}/rainpredictor.sh {} {} workflow:///download/data/".format(command_dir_base, m, n)
    task_rainpredictor = DagonTask(TaskType.SLURM, "rainPredictor", cmd_rainpredictor, partition="xhicpu", ntasks=1, memory=128000)
```

**Why it matters:** This step is scheduled via SLURM, uses the `download` output as input, and produces a forecast dataset for comparison and simulation.

## Task: compare predicted vs. observed

A comparison step validates model output against observations.

```python
    # ToDo: Add compare
    cmd_compare = "{}/compare.sh workflow:///rainPredictor/data/output/".format(command_dir_base)
    task_compare = DagonTask(TaskType.SLURM, "compare", cmd_compare, partition="xhicpu", ntasks=1, memory=128000)
```

**Why it matters:** The comparison task reads the rain predictor output. Although the comment notes future enhancements, it already exists in the DAG definition.

## Task: convert reflectivity to rain rate

The next task transforms radar reflectivity into rain-rate values.

```python
    # Weather Radar to Rain Rate
    cmd_wr_to_rainrate = "{}/wr_to_rainrate.sh {} {} workflow:///rainPredictor/data/output/".format(command_dir_base, iso8601, time_interval)
    task_wr_to_rainrate = DagonTask(TaskType.SLURM, "wr_to_rainrate", cmd_wr_to_rainrate, partition="xhicpu", ntasks=1, memory=128000)
```

**Why it matters:** This conversion is a prerequisite for running the LPERFECT-M model. It depends on the predicted radar output and uses time metadata.

## Task: run LPERFECT-M simulation

The hydrological simulation consumes the rain-rate dataset.

```python
    # LPERFECT-M
    cmd_lperfectm = "{}/lperfect-m.sh {} {} workflow:///wr_to_rainrate/data/output/".format(command_dir_base, iso8601, simulation_time)
    task_lperfectm = DagonTask(TaskType.SLURM, "lperfectm", cmd_lperfectm, partition="xhicpu", memory=128000, nodes=1, ntasks_per_node=2)
```

**Why it matters:** This is a heavier compute step (multiple tasks per node) and uses the simulation time to control model runtime.

## Task: render output plots

The pipeline then renders visualization artifacts.

```python
    # Perform output on plot
    cmd_output_plot= "{}/output_plot.sh workflow:///lperfectm/data/output/history_0000.nc".format(command_dir_base)
    task_output_plot = DagonTask(TaskType.SLURM, "output_plot", cmd_output_plot, partition="xhicpu", ntasks=1, memory=128000)

    cmd_output_plot_geo = "{}/output_to_geo.sh workflow://lperfectm/output/".format(command_dir_base)
    task_output_plot_geo = DagonTask(TaskType.SLURM, "output_geo", cmd_output_plot_geo,  partition="xhicpu", ntasks=1, memory=128000)
```

**Why it matters:** These tasks convert simulation outputs into plots and geo formats. The script currently declares both, but only the plot task is added to the workflow below.

## Register tasks and execute the DAG

Finally, tasks are registered, dependencies are derived automatically, and the workflow is executed.

```python

    # Add tasks to the workflow
    workflow.add_task(task_download)
    workflow.add_task(task_rainpredictor)
    workflow.add_task(task_compare)
    workflow.add_task(task_wr_to_rainrate)
    workflow.add_task(task_lperfectm)
    workflow.add_task(task_output_plot)
    # ToDo: add output
    # ToDo: add alarm worm

    # Let DAGonStar automatically resolve dependencies between tasks
    workflow.make_dependencies()

    # Run the workflow: tasks are executed respecting their dependencies
    workflow.run()
```

**Why it matters:** `make_dependencies()` analyzes input/output references (e.g., `workflow:///...`) to build edges. `workflow.run()` submits tasks in the correct order.
