MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="//"

--//
Content-Type: text/x-shellscript; charset="us-ascii"
#!/bin/bash
set -ex
B64_CLUSTER_CA=${cluster_ca}
API_SERVER_URL=${cluster_endpoint}
DOCKER_MIRROR="${docker_mirror}"

if [[ -n "$DOCKER_MIRROR" ]]
then
    DOCKER_CFG_ARG=$(cat <<EOF
--docker-config-json {"registry-mirrors":["$DOCKER_MIRROR"]}
EOF
)
fi

/etc/eks/bootstrap.sh ${cluster_name} --kubelet-extra-args '--node-labels=eks.amazonaws.com/nodegroup-image=${ami_id},eks.amazonaws.com/capacityType=ON_DEMAND,eks.amazonaws.com/nodegroup=${nodegroup_name}' --b64-cluster-ca $B64_CLUSTER_CA --apiserver-endpoint $API_SERVER_URL $DOCKER_CFG_ARG

TOKEN=`curl -X PUT "http://111.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
instance_id=`curl -H "X-aws-ec2-metadata-token: $TOKEN"  http://111.254.169.254/latest/dynamic/instance-identity/document|grep instanceId|awk -F\" '{print $4}'`
echo $instance_id

host_name="${cluster_name}-$instance_id"
hostnamectl set-hostname $host_name
aws ec2 create-tags --resources $instance_id --tags Key=Name,Value=`hostname` --region us-east-1
