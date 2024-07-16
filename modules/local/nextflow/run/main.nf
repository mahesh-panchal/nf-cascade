import java.nio.file.Paths
import java.nio.file.Files

process NEXTFLOW_RUN {
    tag "$pipeline_name"

    input:
    val pipeline_name     // String
    val nextflow_opts     // String
    val nextflow_files    // Map [ params-file: params.yml , c: configs/multiqc.config ]
    val pipeline_files    // Map [ input: samplesheet.csv ]

    when:
    task.ext.when == null || task.ext.when

    exec:
    def cache_dir = Paths.get(workflow.workDir.resolve(pipeline_name).toUri())
    Files.createDirectories(cache_dir)
    def nxf_cmd = [
        'nextflow run',
            pipeline_name,
            nextflow_opts,
            nextflow_files ? nextflow_files.collect{ key, value -> "-$key $value" }.join(' ') : '',
            pipeline_files ? pipeline_files.collect{ key, value -> "--$key $value" }.join(' ') : '',
            "--outdir $task.workDir/results",
    ]
    def builder = new ProcessBuilder(nxf_cmd.join(" ").tokenize(" "))
    builder.directory(cache_dir.toFile())
    process = builder.start()
    assert process.waitFor() == 0: process.text

    output:
    path "results"  , emit: output
    val process.text, emit: log
}
