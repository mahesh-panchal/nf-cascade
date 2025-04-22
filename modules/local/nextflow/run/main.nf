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

    exec:
    // Set cache directory so workflow can `-resume`
    def cache_path = file(cache_dir)
    assert cache_path.mkdirs()
    // Construct nextflow command
    def nxf_cmd = [
        'nextflow run',
            pipeline_name,
            nextflow_opts,
            params_file ? "-params-file $params_file" : '',
            additional_config ? "-c $additional_config" : '',
            samplesheet ? "--input $samplesheet" : '',
            "--outdir ${task.workDir}/results",
    ].join(" ")
    // Copy command to shell script in work dir for reference/debugging.
    file("$task.workDir/nf-cmd.sh").text = nxf_cmd
    // Run nextflow command locally in cache directory
    def process = nxf_cmd.execute(null, cache_path.toFile())
    process.waitFor()
    stdout = process.text
    assert process.exitValue() == 0: stdout
    // Copy nextflow log to work directory
    cache_path.resolve(".nextflow.log").copyTo("${task.workDir}/nextflow.log")

    output:
    path "results" , emit: output
    val stdout, emit: log
}
