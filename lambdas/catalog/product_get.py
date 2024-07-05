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
table = dynamodb.Table("products")


@metrics.log_metrics
@logger.inject_lambda_context(log_event=True)
@tracer.capture_lambda_handler
def handler(event, context: LambdaContext):
    product_id = event["id"]
    logger.info("Getting product", {"product_id": product_id})

    table_item = table.get_item(Key={"id": product_id})

    if "Item" not in table_item:
        metrics.add_metric(name="FailedProductGet", unit=MetricUnit.Count, value=1)
        raise Exception("Product not found")

    body = table_item["Item"]

    item = {
        "id": body["id"],
        "slug": body["slug"],
        "name": body["name"],
        "source": body["source"],
        "yield": body["yield"],
        "sell_price": body["sell_price"],
        "maturation_time": body["maturation_time"]
    }

    metrics.add_metric(name="SuccessfulProductGet", unit=MetricUnit.Count, value=1)

    return item
