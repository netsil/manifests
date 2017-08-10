#!/bin/bash

if [[ -z "${NEXT_VERSION}" ]] ; then
    echo "NEXT_VERSION not set."
    exit 1
fi


update_version() {
    if [[ -z "${PREVIOUS_VERSION}" ]] ; then
        echo "PREVIOUS_VERSION not set."
        exit 1
    fi

    manifests=(
        ./docker/docker-compose.yml
        ./docker/install-netsil.sh
        ./docker/install-collectors.sh
        ./kubernetes/collector.yaml
        ./kubernetes/1.5/collector.yaml
        ./kubernetes/netsil-rc.yaml
        ./kubernetes/netsil.yml
        ./kubernetes/kube-netsil/kube-netsil.sh
        ./mesos-marathon/netsil-dcos.json
        ./mesos-marathon/netsil-dcos-collectors.json
    )

    for i in "${manifests[@]}"
    do
        sed -i.bak "s/stable-${PREVIOUS_VERSION}/stable-${NEXT_VERSION}/g" $i
    done
}

update_tag() {
    git tag -d latest
    git tag -a "latest" -m "Release ${NEXT_VERSION}"
    git tag -a "${NEXT_VERSION}" -m "Release ${NEXT_VERSION}"
    git push origin --tags -f
}


case "$1" in
    version)
        update_version
        ;;
    tag)
        update_tag
        ;;
    *)
        echo $"Usage: $0 {version|tag}"
        exit 1
esac

