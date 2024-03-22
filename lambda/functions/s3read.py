import boto3
import os

def lambda_handler(event, context):
    # S3にファイルを書き込む
    bucket_name = os.environ.get('S3_BUCKET_NAME')
    print(f'env S3_BUCKET_NAME = {bucket_name}')

    file_name = 'example.txt'
    s3 = boto3.client('s3')
    file_obj = s3.get_object(Bucket=bucket_name, Key=file_name)

    # ファイルの内容を取得
    content = file_obj['Body'].read().decode('utf-8')
    print(f'content = "{content}"')

    return {
        'statusCode': 200,
        'body': f'Successfully read from S3: {content}'
    }
