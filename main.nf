include { NEXTFLOW_RUN as NFCORE_DEMO          } from "$projectDir/modules/local/nextflow/run/main"
include { NEXTFLOW_RUN as NFCORE_FETCHNGS      } from "$projectDir/modules/local/nextflow/run/main"
include { NEXTFLOW_RUN as NFCORE_RNASEQ        } from "$projectDir/modules/local/nextflow/run/main"
include { readWithDefault                      } from "$projectDir/functions/local/utils"
include { resolveFileFromDir as getSamplesheet } from "$projectDir/functions/local/utils"

workflow {
    if ( params.run_nfcore_demo ) {
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
    } else {
        // FETCHNGS
        NFCORE_FETCHNGS (
            'nf-core/fetchngs',
            "${params.general.wf_opts?: ''} ${params.fetchngs.wf_opts?: ''}",  // workflow opts
            readWithDefault( params.fetchngs.params_file, Channel.value([]) ), // input params file
            readWithDefault( params.fetchngs.input, Channel.value([]) ),       // samplesheet
            readWithDefault( params.fetchngs.add_config, Channel.value([]) ),  // custom config
        )
        fetchngs_to_rnaseq_samplesheet = getSamplesheet( 'samplesheet/samplesheet.csv', NFCORE_FETCHNGS.out.output )

        // RNASEQ
        NFCORE_RNASEQ (
            'nf-core/rnaseq',
            "${ params.general.wf_opts?: ''} ${params.rnaseq.wf_opts?: ''}",        // workflow opts
            readWithDefault( params.rnaseq.params_file, Channel.value([]) ),        // input params file
            readWithDefault( params.rnaseq.input, fetchngs_to_rnaseq_samplesheet ), // samplesheet
            readWithDefault( params.rnaseq.add_config, Channel.value([]) ),         // custom config
        )        
    }
}