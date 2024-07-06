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
    logger.info("Updating crop")

    crop_id = event["id"]
    crop = table.get_item(Key={"id": crop_id})
    crop = crop["Item"]
    logger.info(crop)

    if crop["cultivar_end"] != "":
        return crop

    current_timestamp = datetime.now()
    start = datetime.fromisoformat(crop["cultivar_start"])
    maturation_time = int(crop["maturation_time"])

    duration = current_timestamp - start
    duration = duration.total_seconds() // 60

    completed = duration > maturation_time

    logger.info(
        {
            "start": start,
            "current_timestamp": current_timestamp,
            "duration": duration,
            "maturation_time": maturation_time,
            "completed": completed,
        }
    )

    if completed:
        crop["cultivar_end"] = current_timestamp.isoformat()
        update_crop(crop)
        metrics.add_metric(name="SuccessfulCropUpdated", unit=MetricUnit.Count, value=1)

    return crop


def update_crop(crop):
    table.update_item(
        Key={"id": crop["id"]},
        UpdateExpression="SET cultivar_end = :timestamp",
        ConditionExpression="cultivar_end = :empty",
        ExpressionAttributeValues={
            ":timestamp": crop["cultivar_end"],
            ":empty": "",
        },
        ReturnValues="ALL_NEW",
    )
