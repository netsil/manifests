#!/bin/bash

echo "Source AMI is: " ${SOURCE_AMI}
echo "Source region is: " ${SOURCE_REGION}
AMI_NAME=${AMI_NAME:-"Netsil - Stable ${NETSIL_VERSION_NUMBER}"}

dryrun_s3=""
dryrun_ami=""
if [[ ${DO_DRY} == "yes" ]] ; then
    dryrun_s3="--dryrun"
    dryrun_ami="--dry-run"
fi

# The aws ec2 copy command doesn't block, and returns the image id in stdout
function copy_ami() {
    dest_region=$1
    aws ec2 copy-image ${dryrun_ami} \
        --source-image-id ${SOURCE_AMI} \
        --source-region ${SOURCE_REGION} \
        --region ${dest_region} \
        --name "${AMI_NAME}"
}

DEST_REGIONS=(
    us-east-1 \
    us-east-2 \
    us-west-1 \
    eu-west-1 \
    eu-central-1 \
    ap-southeast-1 \
    ap-northeast-1 \
    ap-south-1 \
    sa-east-1 \
)


# Copy AMIs
for region in ${DEST_REGIONS[@]}
do
    rm -f "${region}-ami.json"
    copy_ami $region > "${region}-ami.json"
done
