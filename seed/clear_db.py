import os
import boto3
import time
from botocore.exceptions import ClientError

table_name = os.environ.get("DYNAMODB_TABLE")
if not table_name:
    raise Exception("DYNAMODB_TABLE environment variable not set")

# Safety check: do not run if table name contains dev, stable, or prod
for forbidden in ["dev", "stable", "prod"]:
    if forbidden in table_name.lower():
        raise Exception(f"Refusing to run destructive operation on table '{table_name}' (contains '{forbidden}').")

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(table_name)

def delete_batch(items, batch_number):
    batch_size = 25
    for i in range(0, len(items), batch_size):
        sub_batch = items[i:i+batch_size]
        while True:
            try:
                with table.batch_writer() as batch:
                    for item in sub_batch:
                        key = {k: item[k] for k in ["userId", "wishId"]}
                        batch.delete_item(Key=key)
                print(f"Batch {batch_number}.{i // batch_size + 1} successfully deleted ({len(sub_batch)} items).")
                break
            except ClientError as e:
                if e.response['Error']['Code'] == 'ProvisionedThroughputExceededException':
                    print(f"ProvisionedThroughputExceededException on batch {batch_number}.{i // batch_size + 1}: Throughput exceeded, retrying in 2 seconds...")
                    time.sleep(2)
                else:
                    raise
        time.sleep(2)

print(f"Scanning and deleting all items from table: {table_name}")

scan_count = 1
while True:
    print(f"Starting scan #{scan_count}...")
    scan = table.scan() if scan_count == 1 else table.scan(ExclusiveStartKey=scan["LastEvaluatedKey"])
    print(f"Scan #{scan_count} completed. Found {len(scan.get('Items', []))} items.")
    time.sleep(2)
    items = scan.get("Items", [])
    if items:
        print(f"Deleting {len(items)} items in batches for scan #{scan_count}...")
        delete_batch(items, scan_count)
    if "LastEvaluatedKey" not in scan:
        break
    scan_count += 1

print("All items deleted.")
