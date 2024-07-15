/**
 * Returns a channel with the path if it's defined, otherwise returns a default channel.
 * 
 * @param path             The path to include into the channel
 * @param default_channel  A channel to use as the default if no path is defined.
 * @return                 A channel with a path, or the default channel
 */
def readWithDefault( String path, Object default_channel ) {
    path ? Channel.fromPath( path, checkIfExists: true ) : default_channel
}

/**
 * Returns a channel with the file defined by the path resolved against the directory.
 * 
 * @param path  The path of the file relative to the directory in dir
 * @param dir   A channel with a directory.
 * @return      A channel with a path relative to the dir path
 */
def resolveFileFromDir ( String path, Object dir ){
    dir.map{ results -> file( results.resolve( path ) ) }
}

/**
 * Returns a channel with a samplesheet for nf-core/mag. 
 * 
 * @param dir   A channel with a directory. Fastq.gz files are assumed to be in a folder called fastq here.
 * @return      A channel with a samplesheet or empty list
 */
def createMagSamplesheet ( Object dir ){
    if ( dir ) {
        dir.map { results -> 
                files( results.resolve( 'fastq/*fastq.gz' ) )
                    .collect {
                        "${it.simpleName},0,${it},,"
                    }
            }
            .flatMap { [ "sample,group,short_reads_1,short_reads_2,long_reads" ] + it }
            .collectFile( name: 'mag_samplesheet.csv', newLine: true, sort: false )
    } else {
        Channel.value([])
    }
}
