import logging
import boto3
import os

logger = logging.getLogger()
logger.setLevel(logging.INFO)

privateHostedZoneName = os.environ['PrivateHostedZoneName']
esDomain = os.environ['EsDomain']


def handler(event, context):
    logger.info("Event: {}\n".format(event))
    asg_name = event['detail']['AutoScalingGroupName']
    logger.info("PrivateHostedZoneName: {}\n".format(privateHostedZoneName))
    logger.info("EsDomain: {}\n".format(esDomain))
    logger.info("AutoScalingGroupName: {}\n".format(asg_name))

    private_ips = get_instances_ip(asg_name)
    update_record(privateHostedZoneName, esDomain, private_ips)


def get_instances_ip(asg_name):
    private_ips = []
    autoscaling = boto3.client('autoscaling')
    ec2 = boto3.client('ec2')
    asg_response = autoscaling.describe_auto_scaling_groups(
        AutoScalingGroupNames=[
            asg_name,
        ],
        MaxRecords=100
    )

    instance_ids = list(map(lambda x: x['InstanceId'], asg_response['AutoScalingGroups'][0]['Instances']))
    logger.info(instance_ids)

    ec2_response = ec2.describe_instances(
        InstanceIds=instance_ids,
        DryRun=False,
    )

    for reservation in ec2_response['Reservations']:
        for instance in reservation['Instances']:
            if instance['State']['Name'] == 'running':
                private_ips.append(instance['PrivateIpAddress'])

    logger.info("Private IPS:")
    logger.info(private_ips)
    return private_ips


def update_record(hosted_zone_name, domain, ips):
    route53 = boto3.client('route53')
    response = route53.list_hosted_zones_by_name(
        DNSName=hosted_zone_name,
    )
    route53.change_resource_record_sets(
        HostedZoneId=response['HostedZones'][0]['Id'],
        ChangeBatch={
            'Changes': [
                {
                    'Action': 'UPSERT',
                    'ResourceRecordSet': {
                        'Name': domain,
                        'Type': 'A',
                        'TTL': 300,
                        'ResourceRecords': list(map(lambda ip: {'Value': ip}, ips))
                    }
                },
            ]
        }
    )
