#!/bin/bash

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

download https://download.jboss.org/wildfly/23.0.2.Final/wildfly-23.0.2.Final.tar.gz

podman network create demo

buildah build -t domain-controller -f containers/Dockerfile.domain-controller

podman run --name domain-controller --hostname=domain-controller -dit -p 8080:8080 -p 9990:9990 --network demo domain-controller

buildah build -t host-controller-1 -f containers/Dockerfile.host-controller-1

podman run --name host-controller-1 --hostname=host-controller-1 -dit -p 8081:8080 -p 9991:9990 --network demo host-controller-1

buildah build -t host-controller-2 -f containers/Dockerfile.host-controller-2

podman run --name host-controller-2 --hostname=host-controller-2 -dit -p 8082:8080 -p 9992:9990 --network demo host-controller-2