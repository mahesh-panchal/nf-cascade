def readWithDefault( String param, Object def_channel ) {
    param ? Channel.fromPath( param, checkIfExists: true ) : def_channel
}

def resolveFileFromDir ( String path, Object dir ){
    dir.map{ results -> file( results.resolve( path ) ) }
}