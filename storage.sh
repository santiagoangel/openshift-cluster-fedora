#!/bin/sh
#run:
#export MASTERIP=192.168.88.98
#cd ~; wget https://raw.githubusercontent.com/santiagoangel/openshift-cluster-fedora/master/storage.sh; sh storage.sh


dnf install -y glusterfs-server
systemctl enable glusterd.service
systemctl start glusterd.service
mkdir -p /data/gv0
firewall-cmd --zone=public --add-port=24007-24008/tcp --permanent
firewall-cmd --zone=public --add-port=49152-49251/tcp --permanent
firewall-cmd --reload
gluster volume create gv0 cloud.successfulsoftware.io:/data/gv0  force
gluster volume start gv0

# create pv
#gluster-pv.yaml
cat <<EOF > gluster-pv.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: gluster-pv
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  glusterfs:
    endpoints: glusterfs-cluster
    path: gv0
    readOnly: false
  persistentVolumeReclaimPolicy: Retain
EOF
#install pv
oc login -u system:admin
oc create -f gluster-pv.yaml

# create service
#gluster-service.yaml
cat <<EOF > gluster-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: glusterfs-cluster
spec:
  ports:
  - port: 1 # ignored
EOF
# create endpoints
#gluster-endpoints.yaml
cat <<EOF > gluster-endpoints.yaml
apiVersion: v1
kind: Endpoints
metadata:
  name: glusterfs-cluster
subsets:
- addresses:
  - ip: $MASTERIP # master
  ports:
  - port: 1
EOF

#chmod 777 gluster endpoint
dnf install -y glusterfs-fuse
mkdir -p /mnt/gv0
mount -t glusterfs $MASTERIP:/gv0 /mnt/gv0
chmod -R 777 /mnt/gv0
ls /mnt/gv0/
gluster volume status

oc create -f gluster-service.yaml
oc create -f gluster-endpoints.yaml
