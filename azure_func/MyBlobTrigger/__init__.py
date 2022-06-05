import logging
import os.path
from pymongo import MongoClient


import azure.functions as func
from azure.cognitiveservices.vision.computervision import ComputerVisionClient
from msrest.authentication import CognitiveServicesCredentials

import os


def main(myblob: func.InputStream):
    logging.info(f"Python blob trigger function processed blob \n"
                 f"Name: {myblob.name}\n"
                 f"Blob Size: {myblob.length} bytes")

    key = os.environ['KEY'];
    mongo_url = os.environ['MONGO_URL'];
    blob_storage_url = os.environ['BLOB_STORAGE_URL'];
    computer_vision_analyse_url = os.environ['COMPUTER_VISION_ANALYSE_URL'];

    credentials = CognitiveServicesCredentials(key);
    client_cognitiveServices= ComputerVisionClient(
        endpoint=computer_vision_analyse_url,
        credentials=credentials
    );

    client_mongo = MongoClient(mongo_url);
    
    analysis = client_cognitiveServices.describe_image((blob_storage_url + myblob.name), 3, "en");

    for caption in analysis.captions:
        logging.info(f"Analyze image done \n"
                     f"Text: {caption.text}");
    
    describe = {"describe": caption.text};
    collection = client_mongo['ImageDescribe']['describe'];
    collection.insert_one(describe);

