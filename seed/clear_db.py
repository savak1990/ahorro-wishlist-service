import os
import boto3
import time

table_name = os.environ.get("DYNAMODB_TABLE")
if not table_name:
    raise Exception("DYNAMODB_TABLE environment variable not set")

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(table_name)

print(f"Scanning and deleting all items from table: {table_name}")

scan_count = 1
while True:
    print(f"Starting scan #{scan_count}...")
    scan = table.scan() if scan_count == 1 else table.scan(ExclusiveStartKey=scan["LastEvaluatedKey"])
    print(f"Scan #{scan_count} completed. Found {len(scan.get('Items', []))} items.")
    time.sleep(2)
    if scan.get("Items"):
        print(f"Deleting {len(scan['Items'])} items in batch for scan #{scan_count}...")
        with table.batch_writer() as batch:
            for item in scan["Items"]:
                key = {k: item[k] for k in ["userId", "wishId"]}
                batch.delete_item(Key=key)
        print(f"Batch delete for scan #{scan_count} completed.")
        time.sleep(2)
    if "LastEvaluatedKey" not in scan:
        break
    scan_count += 1

print("All items deleted.")
