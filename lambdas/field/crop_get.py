import json
import boto3
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
    logger.info("Getting crop status")

    crop_id = event["id"]

    table_item = table.get_item(Key={"id": crop_id})

    if "Item" not in table_item:
        metrics.add_metric(name="FailedCropGet", unit=MetricUnit.Count, value=1)
        raise Exception("Crop not found")

    body = table_item["Item"]

    item = {
        "id": body["id"],
        "cultivar": body["cultivar"],
        "cultivar_start": body["cultivar_start"],
        "cultivar_end": body["cultivar_end"],
        "created": body["created"],
        "generation": body["generation"],
        "maturation_time": body["maturation_time"],
    }

    metrics.add_metric(name="SuccessfulCropGet", unit=MetricUnit.Count, value=1)

    return item
