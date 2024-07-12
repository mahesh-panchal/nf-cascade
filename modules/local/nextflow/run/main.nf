import java.nio.file.Paths
import java.nio.file.Files

process NEXTFLOW_RUN {
    tag "$pipeline_name"

    input:
    val pipeline_name     // String
    val nextflow_opts     // String
    val params_file       // pipeline params-file
    val samplesheet       // pipeline samplesheet
    val additional_config // custom configs

    when:
    task.ext.when == null || task.ext.when

    exec:
    // def args = task.ext.args ?: ''
    def cache_dir = Paths.get(workflow.workDir.resolve(pipeline_name).toUri())
    Files.createDirectories(cache_dir)
    def nxf_cmd = [
        'nextflow run',
            pipeline_name,
            nextflow_opts,
            params_file ? "-params-file $params_file" : '',
            additional_config ? "-c $additional_config" : '',
            samplesheet ? "--input $samplesheet" : '',
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
