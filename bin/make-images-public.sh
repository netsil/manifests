#!/bin/bash

# TODO: Generate this list from the copy-images script output in the future
declare -A IMAGE_IDS

for f in *.json ; do
    region=${f%-*}
    image_id=$(cat $f | jq -r '.ImageId')
    IMAGE_IDS[$region]=${image_id}
done

# TODO: Can this command be run before the AMI itself is ready?
for i in ${!IMAGE_IDS[@]}
do
    aws --region ${i} ec2 modify-image-attribute \
        --image-id ${IMAGE_IDS[$i]} \
        --launch-permission "{\"Add\":[{\"Group\":\"all\"}]}"
    echo "Made ${IMAGE_IDS[$i]} public"
done


for i in ${!IMAGE_IDS[@]}
do
	aws --region ${i} ec2 describe-image-attribute \
        --image-id ${IMAGE_IDS[$i]} \
        --attribute launchPermission
done
