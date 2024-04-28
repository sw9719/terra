import json
import boto3

client = boto3.client('ecs')

def lambda_handler(event, context):
    # TODO implement
    print("Received event: " + json.dumps(event, indent=2))
    try:
        response = client.update_service(cluster="white-hart",service="nodeapp",forceNewDeployment=True)
    except Exception as e:
        print(e)
        raise Exception(e)
