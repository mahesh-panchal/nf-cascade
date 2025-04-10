process NEXTFLOW_RUN {
    input:
    val pipeline_name     // String
    val nextflow_opts     // String
    val params_file       // pipeline params-file
    val samplesheet       // pipeline samplesheet
    val additional_config // custom configs
    val cache_dir         // cache directory

    // directives:
    tag "$pipeline_name"

    when:
    task.ext.when == null || task.ext.when

    exec:
    // def args = task.ext.args ?: ''
    def cache_path = file(cache_dir)
    assert cache_path.mkdirs()
    // construct nextflow command
    def nxf_cmd = [
        'nextflow run',
            pipeline_name,
            nextflow_opts,
            params_file ? "-params-file $params_file" : '',
            additional_config ? "-c $additional_config" : '',
            samplesheet ? "--input $samplesheet" : '',
            "--outdir $task.workDir/results",
    ]
    // Copy command to shell script in work dir for reference/debugging.
    file("$task.workDir/nf-cmd.sh").text = nxf_cmd.join(" ")
    // Run nextflow command locally
    def builder = new ProcessBuilder(nxf_cmd.join(" ").tokenize(" "))
    builder.directory(cache_path.toFile())
    process = builder.start()
    assert process.waitFor() == 0: process.text
    // Copy nextflow log to work directory
    cache_path.resolve(".nextflow.log").copyTo("$task.workDir/.nextflow.log")

    output:
    path "results"  , emit: output
    val process.text, emit: log
}
