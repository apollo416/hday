import uuid
import boto3
import datetime
from behave import *


@given("I have id of a crop")
def step_impl(context):
    dynamodb = boto3.resource(
        "dynamodb",
        aws_access_key_id=context.aws_access_key_id,
        aws_secret_access_key=context.aws_secret_access_key,
        aws_session_token=context.aws_session_token,
    )
