import os
import boto3
import requests
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

CATALOG_BASE_URL = os.environ.get("CATALOG_BASE_URL")


@metrics.log_metrics
@logger.inject_lambda_context(log_event=True)
@tracer.capture_lambda_handler
def handler(event, context):
    logger.info("Planting a new crop")

    crop_id = event["id"]
    cultivar = event["cultivar"]
    timestamp = datetime.now().isoformat()

    plant = get_plant(event["cultivar"])

    try:
        item = table.update_item(
            Key={"id": crop_id},
            UpdateExpression="""
                SET 
                cultivar = :cultivar,
                cultivar_start = :cultivar_start,
                generation = generation + :inc,
                maturation_time = :maturation_time
            """,
            ConditionExpression="cultivar_start = :empty",
            ExpressionAttributeValues={
                ":cultivar": cultivar,
                ":cultivar_start": timestamp,
                ":inc": 1,
                ":maturation_time": plant["maturation_time"],
                ":empty": "",
            },
            ReturnValues="ALL_NEW",
        )

        item = {
            "id": item["Attributes"]["id"],
            "cultivar": item["Attributes"]["cultivar"],
            "cultivar_start": item["Attributes"]["cultivar_start"],
            "cultivar_end": "",
            "created": item["Attributes"]["created"],
            "generation": item["Attributes"]["generation"],
            "maturation_time": plant["maturation_time"],
        }

        metrics.add_metric(name="SuccessfulCropPlanted", unit=MetricUnit.Count, value=1)

        return item

    except ClientError as e:
        if e.response["Error"]["Code"] == "ConditionalCheckFailedException":
            raise Exception("Crop already planted")

    raise Exception("Unknown error")


def get_plant(id):
    address = f"{CATALOG_BASE_URL}/products/{id}"
    logger.info(address)
    r = requests.get(address)
    return r.json()
