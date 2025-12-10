import json
import os
from decimal import Decimal

import boto3

dynamodb = boto3.resource("dynamodb")
table_name = os.environ["VEHICLES_TABLE_NAME"]
table = dynamodb.Table(table_name)


def _decimal_to_float(obj):
    if isinstance(obj, list):
        return [_decimal_to_float(x) for x in obj]
    if isinstance(obj, dict):
        return {k: _decimal_to_float(v) for k, v in obj.items()}
    if isinstance(obj, Decimal):
        return float(obj)
    return obj


def _get_vehicle_id_from_event(event: dict) -> str | None:
    """
    Essaie de récupérer l'id :
    - en priorité dans pathParameters["id"] (API Gateway REST/HTTP)
    - en fallback dans queryStringParameters["id"]
    """
    path_params = event.get("pathParameters") or {}
    if "id" in path_params and path_params["id"]:
        return path_params["id"]

    qs = event.get("queryStringParameters") or {}
    if "id" in qs and qs["id"]:
        return qs["id"]

    return None


def handler(event, context):
    """
    Lambda GET /vehicle/{id}
    Retourne un véhicule par id.
    """
    vehicle_id = _get_vehicle_id_from_event(event)

    if not vehicle_id:
        return {
            "statusCode": 400,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"message": "Missing 'id' parameter"}),
        }

    try:
        response = table.get_item(Key={"id": vehicle_id})
        item = response.get("Item")

        if not item:
            return {
                "statusCode": 404,
                "headers": {"Content-Type": "application/json"},
                "body": json.dumps({"message": "Vehicle not found"}),
            }

        item = _decimal_to_float(item)

        return {
            "statusCode": 200,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps(item),
        }

    except Exception as e:
        print(f"[ERROR] Error getting vehicle {vehicle_id} from table {table_name}: {e}")
        return {
            "statusCode": 500,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"message": "Internal server error"}),
        }
