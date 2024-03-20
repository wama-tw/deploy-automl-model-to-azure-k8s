# Create request json
import base64
import os

dataset_dir = "./sample_request_data"
sample_image = os.path.join(dataset_dir, "56.jpg")


def read_image(image_path):
    with open(image_path, "rb") as f:
        return f.read()


request_json = {
    "input_data": {
        "columns": ["image"],
        "data": [base64.encodebytes(read_image(sample_image)).decode("utf-8")],
    }
}

import json

request_file_name = "./sample_request_data/sample_request_data.json"

with open(request_file_name, "w") as request_file:
    json.dump(request_json, request_file)