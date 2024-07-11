include { NEXTFLOW_RUN as NFCORE_DEMO     } from "$projectDir/modules/local/nextflow/run/main"
include { NEXTFLOW_RUN as NFCORE_FETCHNGS } from "$projectDir/modules/local/nextflow/run/main"
include { NEXTFLOW_RUN as NFCORE_RNASEQ   } from "$projectDir/modules/local/nextflow/run/main"
// include { NEXTFLOW_RUN as NFCORE_DEMO } from "$projectDir/modules/local/nextflow/run/main"

workflow {
    if ( params.general.demo ) {
        demo_params_file  = params.demo.params_file ? Channel.fromPath( params.demo.params_file, checkIfExists: true ) : Channel.value([])
        demo_samplesheet  = params.demo.input       ? Channel.fromPath( params.demo.input, checkIfExists: true )       : Channel.value([])
        demo_extra_config = params.demo.add_config  ? Channel.fromPath( params.demo.add_config, checkIfExists: true )  : Channel.value([])
        NFCORE_DEMO (
            'nf-core/demo',       // pipeline name
            [ 
                params.general.wf_opts?: '',
                params.demo.wf_opts?: '',
            ].join(" ").trim(),   // workflow opts
            demo_params_file,     // params file
            demo_samplesheet,     // samplesheet
            demo_extra_config,    // custom config
        )
    } else {
        // FETCHNGS
        fetchngs_params_file  = params.fetchngs.params_file ? Channel.fromPath( params.fetchngs.params_file, checkIfExists: true ) : Channel.value([])
        fetchngs_samplesheet  = params.fetchngs.input       ? Channel.fromPath( params.fetchngs.input, checkIfExists: true )       : Channel.value([])
        fetchngs_extra_config = params.fetchngs.add_config  ? Channel.fromPath( params.fetchngs.add_config, checkIfExists: true )  : Channel.value([])
        NFCORE_FETCHNGS (
            'nf-core/fetchngs',    // pipeline name
            [ 
                params.general.wf_opts?: '',
                params.fetchngs.wf_opts?: '',
            ].join(" ").trim(),    // workflow opts
            fetchngs_params_file,  // input params file
            fetchngs_samplesheet,  // samplesheet
            fetchngs_extra_config, // custom config
        )
        NFCORE_FETCHNGS.out.output
            .map{ results -> file(results.resolve('samplesheet/samplesheet.csv')) }
            .set { fetchngs_to_rnaseq_samplesheet }

        // RNASEQ
        rnaseq_params_file  = params.rnaseq.params_file ? Channel.fromPath( params.rnaseq.params_file, checkIfExists: true ) : Channel.value([])
        rnaseq_samplesheet  = params.rnaseq.input       ? Channel.fromPath( params.rnaseq.input, checkIfExists: true )       : fetchngs_to_rnaseq_samplesheet
        rnaseq_extra_config = params.rnaseq.add_config  ? Channel.fromPath( params.rnaseq.add_config, checkIfExists: true )  : Channel.value([])
        NFCORE_RNASEQ (
            'nf-core/rnaseq',    // pipeline name
            [ 
                params.general.wf_opts?: '',
                params.rnaseq.wf_opts?: '',
            ].join(" ").trim(),  // workflow opts
            rnaseq_params_file,  // input params file
            rnaseq_samplesheet,  // samplesheet
            rnaseq_extra_config, // custom config
        )        
    }
}