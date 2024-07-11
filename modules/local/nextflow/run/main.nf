import java.nio.file.Paths
import java.nio.file.Files

process NEXTFLOW_RUN {
    tag "$pipeline_name"

    input:
    val pipeline_name         // String
    val nextflow_opts         // String[]
    path pipeline_inputs      // path to input file
    path additional_configs   // custom configs

    when:
    task.ext.when == null || task.ext.when

    exec:
    // def args = task.ext.args ?: ''
    def cache_dir = Paths.get("nxf-workflowdir/$pipeline_name")
    Files.createDirectories(cache_dir)
    def builder = new ProcessBuilder(
        'nextflow', 'run',
            pipeline_name,
            '-profile', 'test,singularity',
            '-ansi-log', 'false',
            '-resume',
            '--outdir', "$task.workDir/results"
    )
    builder.directory(cache_dir.toFile())
    def process = builder.start()
    process.waitFor()
    nflog = process.text

    output:
    path "results", emit: output
    val nflog     , emit: log
}
