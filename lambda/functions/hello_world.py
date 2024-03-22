import pandas as pd
from io import StringIO
from common.utils import get_parameter, to_dataframe

def lambda_handler(event, context):
    # パラメータを取得
    param1 = get_parameter(event, "param1", "__hello__")
    param2 = get_parameter(event, "param2", "__world__")

    # パラメータを連結
    df = to_dataframe(param1, param2)
    output = StringIO()
    df.to_csv(output, index=False, header=False)
    message = output.getvalue()

    return {
        'statusCode': 200,
        'headers': {'Content-Type': 'text/plain'},
        'body': message
    }
