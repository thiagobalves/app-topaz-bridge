import os

import boto3


def upload_file_to_s3(zip_name):
    aws_region = os.environ.get('AWS_REGION')
    aws_access_key = os.environ.get('AWS_ACCESS_KEY')
    aws_secret_key = os.environ.get('AWS_SECRET_KEY')
    bucket_key = os.environ.get('AWS_BUCKET_KEY')
    s3 = boto3.resource(service_name='s3', region_name=aws_region, aws_access_key_id=aws_access_key,
                        aws_secret_access_key=aws_secret_key)

    bucket = s3.Bucket(bucket_key)
    bucket.upload_file(zip_name + '.zip', f'react-native-heartbeat/{zip_name}.zip')
