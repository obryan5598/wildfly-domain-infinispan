#!/bin/bash

function cleanup() {
    podman rm -f host-controller-1 host-controller-2 domain-controller

    buildah rmi -f host-controller-1 host-controller-2 domain-controller

    podman network rm demo
}

function compile_code() {
    local APP=$1

    pushd .

    cd applications/$APP/

    mvn clean verify

    popd
}

function configure_cluster() {
    local T=$1

    echo -n "Please wait while the cluster is starting up "

    for i in $(seq 1 $T); do
	echo -n "."
	sleep 1s
    done

    echo

    podman exec -it domain-controller /opt/wildfly-23.0.2.Final/bin/jboss-cli.sh --connect --file=/tmp/setup.cli
}

function download() {
    local URL=$1
    local ARCHIVE=$(echo $URL | awk 'BEGIN { FS="/" } { print $NF }')
    local DOWNLOAD=1

    if [ -f "products/$ARCHIVE" ]; then
	sha1sum -c products/$ARCHIVE.sha1 2>&1 > /dev/null
	DOWNLOAD=$?
    fi

    if [ $DOWNLOAD -ne 0 ]; then
	rm -f products/$ARCHIVE
	curl -JLk $URL > products/$ARCHIVE
    fi
}

function setup() {
    podman network create demo
}

function start_node() {
    local DEMO_GWADDR=$(podman network inspect demo | jq -r .[0].subnets[0].gateway)
    local DEMO_SUBNET=$(echo $DEMO_GWADDR | cut -d '.' -f 1-3)
    local K="$(( $(echo $DEMO_GWADDR | cut -d '.' -f 4) + 1 ))"
    local CMD=""
    local NAME=$1

    shift 1

    if [[ ! "$1" =~ ":" ]]; then
	NAME="$NAME-$1"
	K=$(( $K + $1 ))
	CMD="-Djboss.bind.address.private=$DEMO_SUBNET.$K"
	shift 1
    fi

    buildah build -t $NAME -f containers/Dockerfile.$NAME

    podman run --name $NAME --hostname=$NAME -dit --network demo $(for i in "$@" ; do echo -n " -p $i" ; done) $NAME $CMD
}

__START=$(date -u +%s)

download https://download.jboss.org/wildfly/23.0.2.Final/wildfly-23.0.2.Final.tar.gz

cleanup

compile_code appv1
compile_code appv2

setup

start_node domain-controller 9990:9990
start_node host-controller 1 8080:8080 8180:8180
start_node host-controller 2 8081:8080 8181:8180

configure_cluster 120

__STOP=$(date -u +%s)

echo "Total elapsed time: $(( $__STOP - $__START )) seconds."

unset __START __STOP
