docker run -td \
    --name netsil_aoc \
    -v /opt/netsil/lite/ceph/conf:/etc/ceph \
    -v /opt/netsil/lite/ceph/data:/var/lib/ceph-data \
    -v /opt/netsil/lite/druid/realtime-segments:/opt/netsil/druid/realtime-segments \
    -v /opt/netsil/lite/druid/indexCache:/var/tmp/druid/indexCache \
    -v /opt/netsil/lite/elasticsearch/data:/usr/share/elasticsearch/data \
    -v /opt/netsil/lite/kafka/kafka-log-dir:/opt/netsil/kafka/kafka-log-dir \
    -v /opt/netsil/lite/license-manager/licenses:/opt/netsil/license-manager/licenses \
    -v /opt/netsil/lite/mysql/data:/var/lib/mysql \
    -v /opt/netsil/lite/redis:/var/lib/redis \
    -v /opt/netsil/lite/zookeeper/data:/opt/netsil/zookeeper/data \
    -p 80:80 \
    -p 443:443 \
    -p 2000:2000 \
    -p 2001:2001 \
    -p 2003:2003 \
    -p 2003:2003/udp \
    --log-driver=none \
    netsil/netsil:stable-1.5.3 \
    /root/startup.sh
