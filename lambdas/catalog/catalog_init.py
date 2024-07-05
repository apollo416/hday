import json
import boto3

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table("products")


def handler(event, context):
    with open("crops.json", "r") as file:
        crops = json.load(file)
    with table.batch_writer(overwrite_by_pkeys=["id"]) as batch:
        for product in crops:
            batch.put_item(Item=product)
