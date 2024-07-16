include { NEXTFLOW_RUN as NFCORE_DEMO          } from "$projectDir/modules/local/nextflow/run/main"
include { NEXTFLOW_RUN as NFCORE_FETCHNGS      } from "$projectDir/modules/local/nextflow/run/main"
include { NEXTFLOW_RUN as NFCORE_RNASEQ        } from "$projectDir/modules/local/nextflow/run/main"
include { NEXTFLOW_RUN as NFCORE_TAXPROFILER   } from "$projectDir/modules/local/nextflow/run/main"
include { NEXTFLOW_RUN as NFCORE_MAG           } from "$projectDir/modules/local/nextflow/run/main"
include { NEXTFLOW_RUN as NFCORE_FUNCSCAN      } from "$projectDir/modules/local/nextflow/run/main"
include { readMapAsFiles                       } from "$projectDir/functions/local/utils"
include { resolveFileFromDir as getSamplesheet } from "$projectDir/functions/local/utils"
include { createMagSamplesheet                 } from "$projectDir/functions/local/utils"
include { createFuncscanSamplesheet            } from "$projectDir/functions/local/utils"

workflow {
    // Validate possible pipeline chains
    def valid_chains = [
        'demo',
        'fetchngs',
        'fetchngs,rnaseq',
        'fetchngs,taxprofiler',
        'fetchngs,taxprofiler,mag',
        'fetchngs,taxprofiler,mag,funcscan',
        'fetchngs,mag,funcscan',
        'rnaseq',
        'taxprofiler',
        'mag',
        'funcscan',
    ]
    assert params.workflows in valid_chains
    def wf_chain = params.workflows.tokenize(',')

    // Initialise undefined channels
    def fetchngs_output_samplesheet = Channel.value( [:] )
    def fetchngs_output             = null
    def mag_output                  = null


    // Run pipelines
    if ( 'demo' in wf_chain ) {
        NFCORE_DEMO ( // [ pipeline name, nextflow options, nextflow files, pipeline files ]
            'nf-core/demo',
            "${params.general.nxf_opts?: ''} ${params.demo.nxf_opts?: ''}", // Nextflow opts:
            readMapAsFiles(                                                 // Nextflow files:
                [
                    'params-file': params.demo.params_file,                 // params_file
                    c: params.demo.add_config                               // custom config
                ], 
                Channel.value( [:] ) ), 
            readMapAsFiles(                                                 // Pipeline files:
                [ input: params.demo.input ],                               // samplesheet
                Channel.value( [:] ) 
            ),
        )
    }
    if ( 'fetchngs' in wf_chain ){ 
        // FETCHNGS
        NFCORE_FETCHNGS (
            'nf-core/fetchngs',
            "${params.general.nxf_opts?: ''} ${params.fetchngs.nxf_opts?: ''}", // Nextflow opts:
            readMapAsFiles(                                                     // Nextflow files:
                [ 
                    'params-file': params.fetchngs.params_file,                 // params_file
                    c: params.fetchngs.add_config                               // custom config
                ], 
                Channel.value( [:] ) ), 
            readMapAsFiles(                                                     // Pipeline files:
                [ input: params.fetchngs.input ],                               // samplesheet
                Channel.value( [:] ) 
            ),
        )
        fetchngs_output_samplesheet = getSamplesheet( [ input: 'samplesheet/samplesheet.csv' ], NFCORE_FETCHNGS.out.output )
        fetchngs_output             = NFCORE_FETCHNGS.out.output
    } 
    if ('rnaseq' in wf_chain ){
        // RNASEQ
        NFCORE_RNASEQ (
            'nf-core/rnaseq',
            "${ params.general.nxf_opts?: ''} ${params.rnaseq.nxf_opts?: ''}", // Nextflow opts:
            readMapAsFiles( [                                                  // Nextflow files:
                'params-file': params.rnaseq.params_file,                      // params_file
                c: params.rnaseq.add_config                                    // custom config
            ], Channel.value( [:] ) ), 
            readMapAsFiles(                                                    // Pipeline files:
                [ input: params.rnaseq.input ],                                // samplesheet
                fetchngs_output_samplesheet 
            ),
        )
    }
    if ('taxprofiler' in wf_chain ){
        // TAXPROFILER
        NFCORE_TAXPROFILER (
            'nf-core/taxprofiler',
            "${ params.general.nxf_opts?: ''} ${params.taxprofiler.nxf_opts?: ''}", // Nextflow opts:
            readMapAsFiles( [                                                       // Nextflow files:
                'params-file': params.taxprofiler.params_file,                      // params_file
                c: params.taxprofiler.add_config                                    // custom config
            ], Channel.value( [:] ) ), 
            readMapAsFiles(                                                         // Pipeline files:
                [ input: params.taxprofiler.input ],                                // samplesheet
                fetchngs_output_samplesheet 
            ),
        )
    }
    if ('mag' in wf_chain ){
        // MAG
        NFCORE_MAG (
            'nf-core/mag',
            "${ params.general.nxf_opts?: ''} ${params.mag.nxf_opts?: ''}", // Nextflow opts:
            readMapAsFiles(                                                 // Nextflow files:
                [ 
                    'params-file': params.mag.params_file,                  // params_file
                    c: params.mag.add_config                                // custom config
                ], 
                Channel.value( [:] ) ), 
            readMapAsFiles(                                                 // Pipeline files:
                [ input: params.mag.input ],                                // samplesheet
                createMagSamplesheet(fetchngs_output) 
            ),                          
        )
        mag_output                  = NFCORE_MAG.out.output
    }
    if ('funcscan' in wf_chain ){
        // FUNCSCAN
        NFCORE_FUNCSCAN (
            'nf-core/funcscan',
            "${ params.general.nxf_opts?: ''} ${params.funcscan.nxf_opts?: ''}", // Nextflow opts:
            readMapAsFiles(                                                      // Nextflow files:
                [ 
                    'params-file': params.funcscan.params_file,                  // params_file
                    c: params.funcscan.add_config                                // custom config
                ], 
                Channel.value( [:] ) ), 
            readMapAsFiles(                                                      // Pipeline files:
                [ input: params.funcscan.input ],                                // samplesheet
                createFuncscanSamplesheet(mag_output) 
            ), 
        )
    }
}