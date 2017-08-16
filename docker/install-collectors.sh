NETSIL_HOST=${NETSIL_HOST:-"127.0.0.1"}
docker run -td \
       --name=netsil_collectors \
       --net=host \
       -v /var/run/docker.sock:/var/run/docker.sock:ro \
       -v /proc/:/host/proc/:ro \
       -v /sys/fs/cgroup/:/host/sys/fs/cgroup:ro \
       --cap-add=NET_RAW \
       --cap-add=NET_ADMIN \
       --ulimit core=0 \
       -e DEPLOY_ENV="docker" \
       -e NETSIL_SP_HOST=${NETSIL_HOST} \
       netsil/collectors:stable-1.6.1
