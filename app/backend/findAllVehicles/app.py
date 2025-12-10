import json
import os
from decimal import Decimal

import boto3

dynamodb = boto3.resource("dynamodb")
table_name = os.environ["VEHICLES_TABLE_NAME"]
table = dynamodb.Table(table_name)


def _decimal_to_float(obj):
    """
    Convertit les Decimal DynamoDB en float pour json.dumps.
    """
    if isinstance(obj, list):
        return [_decimal_to_float(x) for x in obj]
    if isinstance(obj, dict):
        return {k: _decimal_to_float(v) for k, v in obj.items()}
    if isinstance(obj, Decimal):
        return float(obj)
    return obj


def handler(event, context):
    """
    Lambda GET /vehicles
    Retourne la liste complète des véhicules.
    """
    try:
        response = table.scan()
        items = response.get("Items", [])
        items = _decimal_to_float(items)

        return {
            "statusCode": 200,
            "headers": {
                "Content-Type": "application/json"
            },
            "body": json.dumps({"items": items}),
        }
    except Exception as e:
        print(f"[ERROR] Error scanning table {table_name}: {e}")
        return {
            "statusCode": 500,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"message": "Internal server error"}),
        }
