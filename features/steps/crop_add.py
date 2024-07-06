import uuid
import requests
import datetime
from behave import *


@when("the message is sent as a POST message")
def step_impl(context):
    base = context.aws_rest_api_urls[context.api_name]
    path = context.request_path
    url = f"{base}{path}"
    print(url)
    context.request = requests.post(url)


@when("the message is sent as a GET message")
def step_impl(context):
    base = context.aws_rest_api_urls[context.api_name]
    path = context.request_path
    url = f"{base}{path}"
    print(url)
    context.request = requests.get(url)


@then('the response content encoding should be "{encoding}"')
def step_impl(context, encoding):
    print(context.request.encoding)
    assert context.request.encoding == encoding


@then('the response status code should be "{status}"')
def step_impl(context, status):
    status = int(status)
    print("passed status", status, type(status))
    print("status_code", context.request.status_code, type(context.request.status_code))
    print("text", context.request.text, type(context.request.text))
    assert context.request.status_code == status


@then("the response should be a json document")
def step_impl(context):
    context.json_content = context.request.json()
    print(context.request.headers["content-type"])
    assert context.request.headers["content-type"] == "application/json"


@then('the response should contain the key "{key}"')
def step_impl(context, key):
    assert key in context.json_content


@then('the field "{id}" should be an UUIDv4')
def step_impl(context, id):
    uuid_obj = uuid.UUID(context.json_content[id], version=4)


@then('the field "{key}" should be empty')
def step_impl(context, key):
    assert context.json_content[key] == ""


@then("the field {key} should be a timestamp")
def step_impl(context, key):
    print(context.json_content[key])
    timestamp = datetime.datetime.fromisoformat(context.json_content[key])
    assert isinstance(timestamp, datetime.datetime)
