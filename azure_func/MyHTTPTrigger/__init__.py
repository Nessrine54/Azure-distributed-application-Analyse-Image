import logging
import json, os
from pymongo import MongoClient

import azure.functions as func


def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    mongo_url = os.environ['MONGO_URL'];
    client_mongo = MongoClient(mongo_url);

    collection = client_mongo['ImageDescribe']['describe'];
    listDescribe = collection.find();
    
    list = {"result": []};

    for x in listDescribe:
        list["result"].append(x["describe"]);
    
    return func.HttpResponse(json.dumps(list), mimetype="application/json", status_code=200);
