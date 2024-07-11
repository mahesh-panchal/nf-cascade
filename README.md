# nf-cascade

A proof of concept daisy-chaining Nextflow workflows.

> [!WARNING]  
> This is still in development.

> [!TIP]
> If you use code from here please acknowledge it by including a comment
> in your code with the url to the code you've copied/adapted.

## Usage

Run nf-core/demo:
```bash
nextflow run main.nf
```

Run nf-core/fetchngs + nf-core/rnaseq:
```bash
nextflow run main.nf -params-file params.yml
```