import boto3
from botocore.exceptions import ClientError
from datetime import datetime

from aws_xray_sdk.core import patch_all

from aws_lambda_powertools import Logger
from aws_lambda_powertools import Tracer
from aws_lambda_powertools import Metrics
from aws_lambda_powertools.metrics import MetricUnit
from aws_lambda_powertools.utilities.typing import LambdaContext

patch_all()

tracer = Tracer()
logger = Logger()
metrics = Metrics()

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table("crops")


@metrics.log_metrics
@logger.inject_lambda_context(log_event=True)
@tracer.capture_lambda_handler
def handler(event, context):
    logger.info("Updating crop")

    crop_id = event["id"]
    timestamp = datetime.now().isoformat()

    try:
        item = table.update_item(
            Key={"id": crop_id},
            UpdateExpression="SET cultivar_end = :timestamp",
            ConditionExpression="cultivar_end <> :empty",
            ExpressionAttributeValues={
                ":timestamp": timestamp,
                ":empty": "",
            },
            ReturnValues="ALL_NEW",
        )

        item = {
            "id": item["Attributes"]["id"],
            "cultivar": item["Attributes"]["cultivar"],
            "cultivar_start": item["Attributes"]["cultivar_start"],
            "generation": item["Attributes"]["generation"],
        }

        metrics.add_metric(name="SuccessfulCropUpdated", unit=MetricUnit.Count, value=1)

        return item

    except ClientError as e:
        if e.response["Error"]["Code"] == "ConditionalCheckFailedException":
            raise Exception("Crop already updated")

    raise Exception("Unknown error")
