import json
import uuid
import boto3
import datetime
import jsonschema
from behave import *


@then('the response should contain the key "{key}" as a {typ}')
def step_impl(context, key, typ):
    assert key in context.json_content
    if typ == "integer":
        assert isinstance(context.json_content[key], int)
    else:
        assert True == False


@then('the response should contain the key "{key}" of type {typ} formated as {fmt}')
def step_impl(context, key, typ, fmt):
    assert key in context.json_content
    if typ == "string":
        assert isinstance(context.json_content[key], str)
    else:
        raise Exception("Unknow type")

    if fmt == "date-time":
        if context.json_content[key] != "":
            timestamp = datetime.datetime.fromisoformat(context.json_content[key])
            assert isinstance(timestamp, datetime.datetime)

    elif fmt == "uuid":
        if context.json_content[key] != "":
            assert uuid.UUID(context.json_content[key], version=4)
    else:
        raise Exception("Unknow format")


@then('the response should contain the key "{key}" of type string equals "{required}"')
def step_impl(context, key, required):
    value = context.json_content[key]
    print("required", required)
    print("current", value)
    assert value == required


@then('the field "{key}" should be empty')
def step_impl(context, key):
    assert context.json_content[key] == ""


@then('the response should be a valid "{name}" resource')
def step_impl(context, name):
    name = name.lower()
    with open(f"./schemas/{name}.json") as f:
        schema = json.load(f)
        jsonschema.validate(instance=context.json_content, schema=schema)


@then("the crop should be present on the server")
def step_impl(context):
    dynamodb = boto3.resource(
        "dynamodb",
        aws_access_key_id=context.aws_access_key_id,
        aws_secret_access_key=context.aws_secret_access_key,
        aws_session_token=context.aws_session_token,
    )
    table = dynamodb.Table("crops")
    crop = table.get_item(Key={"id": context.json_content["id"]})
    assert "Item" in crop
    assert crop["Item"]["id"] == context.json_content["id"]
