import os
import uuid
import boto3
import requests
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

awslambda = boto3.client("lambda")

CATALOG_BASE_URL = os.environ.get("CATALOG_BASE_URL")


@metrics.log_metrics
@logger.inject_lambda_context(log_event=True)
@tracer.capture_lambda_handler
def handler(event, context: LambdaContext):
    logger.info("Adding a new crop")

    crop_id = str(uuid.uuid4())
    created = datetime.now().isoformat()

    plant = get_plant(event["cultivar"])

    item = {
        "id": crop_id,
        "cultivar": plant["id"],
        "cultivar_start": datetime.now().isoformat(),
        "cultivar_end": "",
        "created": created,
        "generation": 1,
        "maturation_time": plant["maturation_time"],
    }

    table.put_item(Item=item)

    metrics.add_metric(name="SuccessfulCropAdd", unit=MetricUnit.Count, value=1)

    return item


def get_plant(id):
    address = f"{CATALOG_BASE_URL}/products/{id}"
    logger.info(address)
    r = requests.get(address)
    return r.json()
