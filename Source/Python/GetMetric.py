################################################################################
# Lambda Function to increment Visitor Metric in DynamoDB.
################################################################################

import json
import boto3

Client = boto3.client("dynamodb")
TableName = "MJ-Metrics"


def Execute(event, context):
    response = Client.update_item(
        TableName="MJ-Metrics",
        Key={"VisitorMetric": {"S": "Visitor Metric Counter"}},
        UpdateExpression="ADD Metric :inc",
        ExpressionAttributeValues={":inc": {"N": "1"}},
        ReturnValues="UPDATED_NEW",
    )

    RetVal = response["Attributes"]["Metric"]["N"]

    origin = event.get("headers", {}).get("origin", "")
    allowed_origins = ["https://johminsoo.com", "https://www.johminsoo.com"]

    if origin in allowed_origins:
        cors_origin = origin
    else:
        cors_origin = ""
    return {
        "statusCode": 200,
        "headers": {
            "Access-Control-Allow-Origin": cors_origin,
            "Access-Control-Allow-Credentials": True,
            "Content-Type": "application/json",
        },
        "body": json.dumps(RetVal),
    }
