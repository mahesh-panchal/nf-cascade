include { NEXTFLOW_RUN as NFCORE_DEMO     } from "$projectDir/modules/local/nextflow/run/main"
include { NEXTFLOW_RUN as NFCORE_FETCHNGS } from "$projectDir/modules/local/nextflow/run/main"
include { NEXTFLOW_RUN as NFCORE_RNASEQ   } from "$projectDir/modules/local/nextflow/run/main"
// include { NEXTFLOW_RUN as NFCORE_DEMO } from "$projectDir/modules/local/nextflow/run/main"

workflow {
    if (params.general.demo) {
        demo_params_file = Channel.value([])
        if ( params.demo.input ) {
            Channel.fromPath( params.demo.input, checkIfExists: true )
                .set { demo_params_file }
        }
        demo_extra_config = Channel.value([])
        if ( params.demo.add_config ){
            Channel.fromPath( params.demo.add_config, checkIfExists: true )
                .set { demo_extra_config }
        }
        NFCORE_DEMO (
            'nf-core/demo',       // pipeline name
            [ 
                params.general.wf_opts?: '',
                params.demo.wf_opts?: '',
            ].join(" ").trim(),   // workflow opts
            demo_params_file,     // input params file
            demo_extra_config,    // custom config
        )
    } else {
        fetchngs_params_file = Channel.value([])
        if ( params.fetchngs.input ) {
            Channel.fromPath( params.fetchngs.input, checkIfExists: true )
                .set { fetchngs_params_file }
        }
        fetchngs_extra_config = Channel.value([])
        if ( params.fetchngs.add_config ){
            Channel.fromPath( params.fetchngs.add_config, checkIfExists: true )
                .set { fetchngs_extra_config }
        }
        NFCORE_FETCHNGS (
            'nf-core/fetchngs',    // pipeline name
            [ 
                params.general.wf_opts?: '',
                params.fetchngs.wf_opts?: '',
            ].join(" ").trim(),    // workflow opts
            fetchngs_params_file,  // input params file
            fetchngs_extra_config, // custom config
        )
    }
}