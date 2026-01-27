# Environment configuration

This folder contains environment setup files and reference Conda specs used by the workflow.

## Recreate the Conda environments

Use one of the provided environment files depending on the model you want to run:

```bash
conda env create -f lperfect.m.yml
conda env create -f rainpredictor.yml
```

If you are mirroring an existing environment, export it to a spec file first and then recreate it:

```bash
conda env export > spec-file.yml
conda env create -f spec-file.yml
```
