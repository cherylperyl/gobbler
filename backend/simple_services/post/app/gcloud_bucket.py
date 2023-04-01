import os
import time
from google.cloud import storage

BUCKET_NAME = "gobbler-posts"

def upload_to_posts_bucket(blob_name, contents):
    # print(os.environ.get("GOOGLE_APPLICATION_CREDENTIALS"))
    # with open(os.environ.get("GOOGLE_APPLICATION_CREDENTIALS"), "r") as f:
    #     print(f.read())
    storage_client = storage.Client(project=os.getenv("GCP_PROJECT_ID"))
    bucket = storage_client.bucket(BUCKET_NAME)
    unique_blob_name = str(int(time.time())) + "_" + blob_name
    blob = bucket.blob(unique_blob_name)

    blob.upload_from_file(contents)
    print("Successfully uploaded to bucket")
    return blob.public_url
