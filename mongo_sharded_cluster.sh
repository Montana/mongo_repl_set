#!/bin/bash

set -e

red=$(tput setaf 1)
green=$(tput setaf 2)
default=$(tput sgr0)

function finish {
    pid=`cat ~/mongosvr/shard-config-0.pid`
    kill $pid
    wait $pid
}
trap finish EXIT

mkdir -p ~/mongosvr/config-0

mongod --configsvr --dbpath ~/mongosvr/config-0 --port 27019 \
    --config . --pidfilepath ~/mongosvr/shard-config-0.pid 2>&1 | sed "s/.*/$red&$default/" &

sleep 3

mongos --configdb localhost:27019 | sed "s/.*/$green&$default/" &

sleep 3

mongo --eval "JSON.stringify(sh._adminCommand( { addShard : 'set/localhost:27091' } , true ))"

mongo --eval "JSON.stringify(sh._adminCommand( { enableSharding : 'test' } ))"

cat
