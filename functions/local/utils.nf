/**
 * Returns a channel with each defined element of the map as a Path object.
 * 
 * @param path             A map of paths where the key is the parameter name, e.g. [ params-file: '/path/to/params.yml' ]
 * @param default_channel  A channel to use as the default if no path is defined.
 * @return                 A channel with a Map of Path objects
 */
def readMapAsFiles( Map<String, String> path_map, Object default_channel ) {
    default_channel.map { it -> 
        it + path_map.findAll { key, value -> value }
            .collectEntries { key, path -> [ (key): file( path , checkIfExists: true ) ] } 
    }
}

/**
 * Returns a channel with the file defined by the path resolved against the directory.
 * 
 * @param path  The path of the file relative to the directory in dir
 * @param dir   A channel with a directory.
 * @return      A channel with a path relative to the dir path
 */
def resolveFileFromDir ( Map<String, String> path_map, Object dir ){
    dir.map{ results -> path_map.collectEntries { key, value -> [ (key): file( results.resolve( value ), checkIfExists: true ) ] } }
}

/**
 * Returns a channel with a samplesheet for nf-core/mag. 
 * 
 * @param dir   A channel with a directory. Fastq.gz files are assumed to be in a folder called fastq here.
 * @return      A channel with a samplesheet or an empty map
 */
def createMagSamplesheet ( Object dir ){
    if ( dir ) {
        dir.map { results -> 
                files( results.resolve( 'fastq/*fastq.gz' ), checkIfExists: true )
                    .collect {
                        "${it.simpleName},0,${it},,"
                    }
            }
            .flatMap { [ "sample,group,short_reads_1,short_reads_2,long_reads" ] + it }
            .collectFile( name: 'mag_samplesheet.csv', newLine: true, sort: false )
            .map{ csv -> [ input: csv ] }
    } else {
        Channel.value( [:] )
    }
}

/**
 * Returns a channel with a samplesheet for nf-core/funcscan. 
 * 
 * @param dir   A channel with a directory. Fa.gz files are assumed to be in a folder called assembly/<assembler>/ here.
 * @return      A channel with a samplesheet or empty map
 */
def createFuncscanSamplesheet ( Object dir ){
    if ( dir ) {
        dir.map { results -> 
                files( results.resolve( 'Assembly/*/*fastq.gz' ), checkIfExists: true )
                    .collect {
                        "${it.simpleName},${it}"
                    }
            }
            .flatMap { [ "sample,fasta" ] + it }
            .collectFile( name: 'mag_samplesheet.csv', newLine: true, sort: false )
            .map{ csv -> [ input: csv ] }
    } else {
        Channel.value( [:] )
    }
}
