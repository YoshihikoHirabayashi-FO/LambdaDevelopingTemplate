import os
import boto3
import json

def lambda_handler(event, context):
    # シークレットの値を取得
    client = boto3.client('secretsmanager')
    secret_value = client.get_secret_value(SecretId='MySecret')
    print(f'secret_value_type={type(secret_value)}')
    print(f'secret_value={secret_value}')
    secret_str = secret_value['SecretString']
    print(f'secret_str={secret_str}')
    secret = json.loads(secret_str)

    # 認証情報を取得
    username = secret['username']
    password = secret['password']

    return {
        'statusCode': 200,
        'body': json.dumps({"username": username, "password": password})
    }
