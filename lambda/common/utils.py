import pandas as pd

def get_parameter(event, param_name, defauls_value = None):
    if 'queryStringParameters' in event and event['queryStringParameters'] is not None:
        params = event['queryStringParameters']
        return params.get(param_name, defauls_value)
    else:
        return defauls_value

# DataFrameに変換
def to_dataframe(str1, str2):
    return pd.DataFrame([[str1, str2]])
