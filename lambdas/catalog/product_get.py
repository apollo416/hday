import boto3

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table("products")


def handler(event, context):
    return


CATALOG = [
    {
        "id": "c62a32e0-74ce-4671-b710-149c8ebf5f3c",
        "name": "wheat",
        "yeld": 2,
        "price": 10,
        "maturation_time": 2,
    },
]
