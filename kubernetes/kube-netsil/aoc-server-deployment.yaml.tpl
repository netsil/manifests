apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  namespace: netsil
  name: netsil
spec:
  replicas: 1
  template:
    metadata:
      name: stream-processor
      labels:
        app: netsil
        component: netsil
        version: stable
    spec:
      containers:
      - name: netsil
        image: netsil/netsil:stable-1.4.5
        command:
        - /root/startup.sh
        ports:
        - containerPort: 80
        - containerPort: 443
        - containerPort: 2001
        - containerPort: 2003
        - containerPort: 2003
          protocol: UDP
        volumeMounts:
        - name: alerts
          mountPath: /var/lib/netsil/alerts/data
        - name: ceph-conf
          mountPath: /etc/ceph
        - name: ceph-data
          mountPath: /var/lib/ceph-data
        - name: druid-index-cache
          mountPath: /var/tmp/druid/indexCache
        - name: druid-realtime-segments
          mountPath: /var/lib/netsil/druid/realtime-segments
        - name: elasticsearch
          mountPath: /usr/share/elasticsearch/data
        - name: kafka-logs
          mountPath: /var/lib/netsil/kafka/kafka-log-dir
        - name: licenses
          mountPath: /var/lib/netsil/lite/license-manager/licenses
        - name: mysql
          mountPath: /var/lib/mysql
        - name: redis
          mountPath: /var/lib/redis
        - name: user-persistence
          mountPath: /var/lib/netsil/user-persistence/data
        - name: zookeeper
          mountPath: /var/lib/netsil/zookeeper/data
      volumes:
      - name: alerts
        hostPath:
          path: /var/lib/netsil/lite/alerts/data
      - name: ceph-conf
        hostPath:
          path: /var/lib/netsil/lite/ceph/conf
      - name: ceph-data
        hostPath:
          path: /var/lib/netsil/lite/ceph/data
      - name: druid-index-cache
        hostPath:
          path: /var/tmp/druid/indexCache
      - name: druid-realtime-segments
        hostPath:
          path: /var/lib/netsil/lite/druid/realtime-segments
      - name: elasticsearch
        hostPath:
          path: /var/lib/netsil/lite/elasticsearch/data
      - name: licenses
        hostPath:
          path: /var/lib/netsil/lite/license-manager/licenses
      - name: kafka-logs
        hostPath:
          path: /var/lib/netsil/lite/kafka/kafka-log-dir
      - name: mysql
        hostPath:
          path: /var/lib/netsil/lite/mysql/data
      - name: redis
        hostPath:
          path: /var/lib/netsil/lite/redis
      - name: user-persistence
        hostPath:
          path: /var/lib/netsil/lite/user-persistence/data
      - name: zookeeper
        hostPath:
          path: /var/lib/netsil/lite/zookeeper/data
      nodeSelector:
        kubernetes.io/hostname: #AOC_SERVER#
