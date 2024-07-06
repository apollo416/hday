import boto3
from behave import given

sts_client = boto3.client("sts")
response = sts_client.assume_role(
    RoleArn="***REMOVED***",
    RoleSessionName="tmp",
)
credentials = response["Credentials"]


def before_all(context):
    apicli = boto3.client(
        "apigateway",
        aws_access_key_id=credentials["AccessKeyId"],
        aws_secret_access_key=credentials["SecretAccessKey"],
        aws_session_token=credentials["SessionToken"],
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
