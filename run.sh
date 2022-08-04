#!/bin/bash

function cleanup() {
    podman rm -f host-controller-1 host-controller-2 domain-controller

    buildah rmi -f host-controller-1 host-controller-2 domain-controller

    podman network rm demo
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

download https://download.jboss.org/wildfly/23.0.2.Final/wildfly-23.0.2.Final.tar.gz

cleanup

unset HC2_ADDR HC1_ADDR DEMO_SUBNET DEMO_GWADDR

podman network create demo

DEMO_GWADDR=$(podman network inspect demo | jq -r .[0].subnets[0].gateway)
DEMO_SUBNET=$(echo $GWADDR | cut -d '.' -f 1-3)

buildah build -t domain-controller -f containers/Dockerfile.domain-controller

podman run --name domain-controller --hostname=domain-controller -dit -p 9990:9990 --network demo domain-controller

buildah build -t host-controller-1 -f containers/Dockerfile.host-controller-1

HC1_ADDR="$DEMO_SUBNET.$(( $(echo $DEMO_GWADDR | cut -d '.' -f 4) + 2 ))"
podman run --name host-controller-1 --hostname=host-controller-1 -dit -p 8080:8080 -p 8180:8180 --network demo host-controller-1 -Djboss.bind.address.private=$HC1_ADDR

buildah build -t host-controller-2 -f containers/Dockerfile.host-controller-2

HC2_ADDR="$DEMO_SUBNET.$(( $(echo $DEMO_GWADDR | cut -d '.' -f 4) + 3 ))"
podman run --name host-controller-2 --hostname=host-controller-2 -dit -p 8081:8080 -p 8181:8180 --network demo host-controller-2 -Djboss.bind.address.private=$HC2_ADDR

sleep 5s

podman exec -it domain-controller /opt/wildfly-23.0.2.Final/bin/jboss-cli.sh --connect --file=/tmp/setup.cli
