#!/usr/bin/env python3
import os
import json
import boto3
from datetime import datetime, timedelta, timezone
import random
import time
from botocore.exceptions import ClientError

table_name = os.environ.get("DYNAMODB_TABLE")
data_file = os.environ.get("SEED_DATA_FILE", "test_data.json")

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(table_name)

with open(data_file) as f:
    items = json.load(f)

batch_size = 25
for i in range(0, len(items), batch_size):
    print(f"Writing batch {i // batch_size + 1} with {min(batch_size, len(items) - i)} items")
    while True:
        try:
            with table.batch_writer() as batch:
                for item in items[i:i+batch_size]:
                    now = datetime.now(timezone.utc)
                    created_str = now.strftime('%Y-%m-%dT%H:%M:%SZ')
                    item["all"] = "all"
                    item["created"] = created_str
                    item["updated"] = created_str

                    # Random due date between 1 and 30 days from now
                    due_delta = timedelta(days=random.randint(1, 30))
                    due = now + due_delta
                    due_str = due.strftime('%Y-%m-%dT%H:%M:%SZ')
                    item["due"] = due_str

                    # Expires is due + 30 days
                    expires = due + timedelta(days=30)
                    expires_str = expires.strftime('%Y-%m-%dT%H:%M:%SZ')
                    item["expires"] = expires_str

                    batch.put_item(Item=item)
            print(f"Batch {i // batch_size + 1} successfully written to DynamoDB.")
            break
        except ClientError as e:
            if e.response['Error']['Code'] == 'ProvisionedThroughputExceededException':
                print("ProvisionedThroughputExceededException: Throughput exceeded, retrying in 2 seconds...")
                time.sleep(2)
            else:
                raise
    time.sleep(2)

print(f"Seeded {len(items)} items into {table_name}")
