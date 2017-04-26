#!/bin/sh
if [ -z "${NETSIL_HOST}" ] ; then
    echo "Exiting because NETSIL_HOST variable not defined"
    exit 1
fi

docker run -td \
       --name=netsil_collectors \
       --net=host \
       -v /var/run/docker.sock:/var/run/docker.sock:ro \
       -v /proc/:/host/proc/:ro \
       -v /sys/fs/cgroup/:/host/sys/fs/cgroup:ro \
       --cap-add=NET_RAW \
       --cap-add=NET_ADMIN \
       -e NETSIL_SP_HOST=${NETSIL_HOST} \
       -e NETSIL_TRAFFIC_PORT=2003 \
       -e NETSIL_INFRA_PORT=2001 \
       -e DEPLOY_ENV="docker" \
       -e SAMPLINGRATE=32 \
       netsil/collectors:stable-1.2.4
