import boto3
import os
from common.utils import get_parameter

def lambda_handler(event, context):
    # パラメータを取得
    content = get_parameter(event, 'content', 'Hello World!')
    print(f'parameter content = "{content}"')

    # S3にファイルを書き込む
    bucket_name = os.environ.get('S3_BUCKET_NAME')
    print(f'env S3_BUCKET_NAME = {bucket_name}')
    
    file_name = 'example.txt'
    s3 = boto3.client('s3')
    s3.put_object(Bucket=bucket_name, Key=file_name, Body=content)
    
    return {
        'statusCode': 200,
        'body': 'Successfully wrote file to S3!'
    }
