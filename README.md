# nf-cascade

A proof of concept daisy-chaining Nextflow workflows.

> [!WARNING]  
> This is still in development.

## Usage

Run nf-core/demo:
```bash
nextflow run main.nf
```

Run nf-core/fetchngs + nf-core/rnaseq:
```bash
nextflow run main.nf -params-file params.yml
```