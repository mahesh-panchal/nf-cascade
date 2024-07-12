def readWithDefault( String param, Object def_channel ) {
    param ? Channel.fromPath( param, checkIfExists: true ) : def_channel
}