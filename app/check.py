import boto3

client = boto3.client('ecs')

response = client.update_service(cluster="white-hart",service="nodeapp",forceNewDeployment=True)

