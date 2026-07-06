#!/bin/bash

AMI_ID="ami-0220d79f3f480ecf5"
HOSTED_ZONE_ID="Z0719276WYZLUK5OQVOA"
DOMAIN_NAME="chinnimaha.online"

# Creating an EC2 instance

for instance in $@ 
do 
    echo "Creating an EC2 instance for $instance"
    Instance_id=$(aws ec2 run-instances \
        --image-id $AMI_ID \
        --count 1 \
        --instance-type t3.micro \
        --security-groups "roboshop-common" "roboshop-$instance" \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=Roboshop-$instance}]"\
        --query 'Instances[0].InstanceId' \
        --output text
    )

    echo "Instance ID for $instance instance is $Instance_id" 

    if [ $instance == "frontend" ]; then
        IP=$(aws ec2 describe-instances \
            --instance-ids $Instance_id \
            --query 'Reservations[*].Instances[*].PublicIpAddress' \
            --output text
        )

        R53_Record="$DOMAIN_NAME"
    else
        IP=$(aws ec2 describe-instances \
            --instance-ids $Instance_id \
            --query 'Reservations[*].Instances[*].PrivateIpAddress' \
            --output text  
        )
        R53_Record="$instance.$DOMAIN_NAME"
    fi

## Updating the Route53 records for the instance

 echo "Updating the Route53 records for $instance"

 aws route53 change-resource-record-sets \
        --hosted-zone-id $HOSTED_ZONE_ID \
        --change-batch '
        {
            "Comment": "Creating record set for $instance",
            "Changes": [
                {
                    "Action": "UPSERT",
                    "ResourceRecordSet": {
                        "Name": "'$R53_Record'",
                        "Type": "A",
                        "TTL": 1,
                        "ResourceRecords": [
                            {
                                "Value": "'$IP'"
                            }
                        ]
                    }
                }
            ]
        }'
done


