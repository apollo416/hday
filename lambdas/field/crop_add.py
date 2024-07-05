import uuid
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
    logger.info("Adding a new crop")

    crop_id = str(uuid.uuid4())
    created = datetime.now().isoformat()

    item = {
        "id": crop_id,
        "cultivar": "",
        "cultivar_start": "",
        "cultivar_end": "",
        "created": created,
        "generation": 0,
    }

    table.put_item(Item=item)

    metrics.add_metric(name="SuccessfulCropAdd", unit=MetricUnit.Count, value=1)

    return item
