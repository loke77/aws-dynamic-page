import boto3

def lambda_handler(event, context):
    ssm = boto3.client('ssm')
    response = ssm.get_parameter(Name='/dynamic_string')
    dynamic_string = response['Parameter']['Value']

    return f"<h1>The saved string is {dynamic_string}</h1>" 