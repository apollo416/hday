import boto3
import http.client as httpclient
import requests
from behave import given, when, then

sts_client = boto3.client("sts")
response = sts_client.assume_role(
    RoleArn="***REMOVED***",
    RoleSessionName="tmp",
)
credentials = response["Credentials"]


def before_all(context):
    context.aws_access_key_id = credentials["AccessKeyId"]
    context.aws_secret_access_key = credentials["SecretAccessKey"]
    context.aws_session_token = credentials["SessionToken"]

    apicli = boto3.client(
        "apigateway",
        aws_access_key_id=context.aws_access_key_id,
        aws_secret_access_key=context.aws_secret_access_key,
        aws_session_token=context.aws_session_token,
    )

    aws_rest_api_urls = {}

    _rest_apis = apicli.get_rest_apis()
    for a in _rest_apis["items"]:
        id = a["id"]
        name = a["name"]
        aws_rest_api_urls[name] = (
            f"https://{id}.execute-api.us-east-1.amazonaws.com/main"
        )

    context.aws_rest_api_urls = aws_rest_api_urls


def before_feature(context, feature):
    if feature.name == "Add new Crop":
        context.api_name = "field_api"


@given('the address is: "{path}"')
def step_impl(context, path):
    context.request_path = path


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
    print("passed status", status, type(status))
    print("status_code", context.request.status_code, type(context.request.status_code))
    print("text", context.request.text, type(context.request.text))
    assert status == httpclient.responses[context.request.status_code]


@then("the response should be a json document")
def step_impl(context):
    context.json_content = context.request.json()
    print(context.request.headers["content-type"])
    assert context.request.headers["content-type"] == "application/json"
