include { NEXTFLOW_RUN as NFCORE_DEMO          } from "$projectDir/modules/local/nextflow/run/main"
include { NEXTFLOW_RUN as NFCORE_FETCHNGS      } from "$projectDir/modules/local/nextflow/run/main"
include { NEXTFLOW_RUN as NFCORE_RNASEQ        } from "$projectDir/modules/local/nextflow/run/main"
include { readWithDefault                      } from "$projectDir/functions/local/utils"
include { resolveFileFromDir as getSamplesheet } from "$projectDir/functions/local/utils"

workflow {
    def valid_chains = [
        'demo',
        'fetchngs,rnaseq',
    ]
    assert params.workflows in valid_chains
    def wf_chain = params.workflows.tokenize(',')

    if ( 'demo' in wf_chain ) {
        NFCORE_DEMO (
            'nf-core/demo',
            [ 
                params.general.wf_opts?: '',
                params.demo.wf_opts?: '',
            ].join(" ").trim(),                                            // workflow opts
            readWithDefault( params.demo.params_file, Channel.value([]) ), // params file
            readWithDefault( params.demo.input, Channel.value([]) ),       // samplesheet
            readWithDefault( params.demo.add_config, Channel.value([]) ),  // custom config
        )
    }
    if ( 'fetchngs' in wf_chain ){ 
        // FETCHNGS
        NFCORE_FETCHNGS (
            'nf-core/fetchngs',
            "${params.general.wf_opts?: ''} ${params.fetchngs.wf_opts?: ''}",  // workflow opts
            readWithDefault( params.fetchngs.params_file, Channel.value([]) ), // input params file
            readWithDefault( params.fetchngs.input, Channel.value([]) ),       // samplesheet
            readWithDefault( params.fetchngs.add_config, Channel.value([]) ),  // custom config
        )
        fetchngs_output_samplesheet = getSamplesheet( 'samplesheet/samplesheet.csv', NFCORE_FETCHNGS.out.output )
    } 
    if ('rnaseq' in wf_chain ){
        // RNASEQ
        NFCORE_RNASEQ (
            'nf-core/rnaseq',
            "${ params.general.wf_opts?: ''} ${params.rnaseq.wf_opts?: ''}",     // workflow opts
            readWithDefault( params.rnaseq.params_file, Channel.value([]) ),     // input params file
            readWithDefault( params.rnaseq.input, fetchngs_output_samplesheet ), // samplesheet
            readWithDefault( params.rnaseq.add_config, Channel.value([]) ),      // custom config
        )
    }
}