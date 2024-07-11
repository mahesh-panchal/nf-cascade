include { NEXTFLOW_RUN as NFCORE_DEMO } from "$projectDir/modules/local/nextflow/run/main"

workflow  {
    //take:
    
    main:
    NFCORE_DEMO(
        'nf-core/demo', // pipeline name
        [],             // workflow opts
        [],             // input params file
        [],              // custom config
    )

    //emit:
    
}