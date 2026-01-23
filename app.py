from dagon import Workflow, DataMover, StagerMover
from dagon.task import DagonTask, TaskType
import argparse



def parse_args():
    parser = argparse.ArgumentParser(description="")
    parser.add_argument("--queue", type=str, help="List of url from queue")
    return parser.parse_args()


if __name__ == '__main__':


    parser = parse_args()

    
    # Create the workflow
    workflow = Workflow("HiWeFAI-Demo", config_file="dagon.ini")

    # The application root
    hiwefai_root = "/projects/HiWeFAI/hiwefai"
    command_dir_base = hiwefai_root + "/scripts/"

    # ToDo: set those parameters by command line
    m = 18 
    n = 6
    time_interval = 600
    iso8601 = "2025-12-23T14:00:00Z"
    simulation_time = 3600

    # Workflow
    # Task A (BATCH) Leggi gli n file tiff dalle url della coda ---> nessuna dipendenza di dati 
    # Task B (SLURM) RainPredict --->  
    # Task C (SLURM) LPERFECTM
    #### I vari task per l'allarme e per l'output


    # Root Task - download weather radar images from given URL list
    cmd_download = "{}/download.sh {}".format(command_dir_base, parser.queue)
    task_download = DagonTask(TaskType.BATCH, "download", cmd_download)

    # RainPredictor - generates n synthetic weather radar images using m previous images
    cmd_rainpredictor = "{}/rainpredictor.sh {} {} workflow:///download/data/".format(command_dir_base, m, n)
    task_rainpredictor = DagonTask(TaskType.SLURM, "rainPredictor", cmd_rainpredictor, partition="xhicpu", ntasks=1, memory=128000)

    # ToDo: Add compare
    cmd_compare = "{}/compare.sh workflow:///rainPredictor/data/output/".format(command_dir_base)
    task_compare = DagonTask(TaskType.SLURM, "compare", cmd_compare, partition="xhicpu", ntasks=1, memory=128000)

    # Weather Radar to Rain Rate
    cmd_wr_to_rainrate = "{}/wr_to_rainrate.sh {} {} workflow:///rainPredictor/data/output/".format(command_dir_base, iso8601, time_interval)
    task_wr_to_rainrate = DagonTask(TaskType.SLURM, "wr_to_rainrate", cmd_wr_to_rainrate, partition="xhicpu", ntasks=1, memory=128000)

    # LPERFECT-M
    cmd_lperfectm = "{}/lperfect-m.sh {} {} workflow:///wr_to_rainrate/data/output/".format(command_dir_base, iso8601, simulation_time)
    task_lperfectm = DagonTask(TaskType.SLURM, "lperfectm", cmd_lperfectm, partition="xhicpu", memory=128000, nodes=1, ntasks_per_node=2)

    # Perform output on plot
    cmd_output_plot= "{}/output_plot.sh workflow:///lperfectm/data/output/history_0000.nc".format(command_dir_base)
    task_output_plot = DagonTask(TaskType.SLURM, "output_plot", cmd_output_plot, partition="xhicpu", ntasks=1, memory=128000)

    cmd_output_plot_geo = "{}/output_to_geo.sh workflow://lperfectm/output/".format(command_dir_base)
    task_output_plot_geo = DagonTask(TaskType.SLURM, "output_geo", cmd_output_plot_geo,  partition="xhicpu", ntasks=1, memory=128000)

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
