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

    return {"statusCode": 200, "body": RetVal}
