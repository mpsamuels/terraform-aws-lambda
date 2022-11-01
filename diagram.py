from diagrams import Diagram, Cluster
from urllib.request import urlretrieve
from diagrams.custom import Custom

from diagrams.aws.storage import S3

from diagrams.aws.compute import LambdaFunction
from diagrams.aws.mobile import APIGateway
from diagrams.aws.network import Route53
from diagrams.aws.integration import Eventbridge

with Diagram("Lambda", show=False):
    lambda_function = LambdaFunction("Lambda Function")
    api_gateway = APIGateway("API Gateway")
    r_53 = Route53("Route 53")
    event_bridge = Eventbridge("Event Bridge")

    r_53 >> api_gateway >> lambda_function
    event_bridge >>  lambda_function