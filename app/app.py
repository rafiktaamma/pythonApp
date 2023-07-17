from flask import Flask, request, jsonify
from flask_pymongo import PyMongo
from pymongo import MongoClient
from bson.objectid import ObjectId
import socket
import os
from dotenv import load_dotenv
import datetime
import logging


load_dotenv()
app = Flask(__name__)

logging.basicConfig(level=logging.INFO)


mongo_username = os.environ.get("MONGO_USERNAME")  # Retrieve MONGO_USERNAME from the environment variable
mongo_password = os.environ.get("MONGO_PASSWORD")  # Retrieve MONGO_PASSWORD from the environment variable
mongo_socket_path = os.environ.get("MONGO_SOCKET_PATH")  # Retrieve MONGO_SOCKET_PATH from the environment variable

app.config["MONGO_URI"] = "mongodb+srv://{}:{}@{}".format(mongo_username,mongo_password,mongo_socket_path)

app.config['JSONIFY_PRETTYPRINT_REGULAR'] = True
mongo = MongoClient(app.config["MONGO_URI"])
db_name = os.environ.get("MONGO_DB_NAME")
db = mongo.get_database(db_name)


@app.route("/")
def index():
    hostname = socket.gethostname()
    current_time = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    log_message = "Processing index request with hostname: {}. Current time: {}".format(hostname, current_time)
    app.logger.info(log_message)
    return jsonify(
        message="Welcome to Tasks app! I am running inside {} pod!".format(hostname)
    )

@app.route("/db-info")
def get_db_name():
    return jsonify(
        message="Welcome , I am using {} ".format(db_name)
    )


@app.route("/tasks")
def get_all_tasks():
    tasks = db.task.find()
    data = []
    for task in tasks:
        item = {
            "id": str(task["_id"]),
            "task": task["task"]
        }
        data.append(item)
    return jsonify(
        data=data
    )


@app.route("/task", methods=["POST"])
def create_task():
    data = request.get_json(force=True)
    db.task.insert_one({"task": data["task"]})
    return jsonify(
        message="Task saved successfully!"
    )


@app.route("/task/<id>", methods=["PUT"])
def update_task(id):
    data = request.get_json(force=True)["task"]
    response = db.task.update_one({"_id": ObjectId(id)}, {"$set": {"task": data}})
    if response.matched_count:
        message = "Task updated successfully!"
    else:
        message = "No Task found!"
    return jsonify(
        message=message
    )


@app.route("/task/<id>", methods=["DELETE"])
def delete_task(id):
    response = db.task.delete_one({"_id": ObjectId(id)})
    if response.deleted_count:
        message = "Task deleted successfully!"
    else:
        message = "No Task found!"
    return jsonify(
        message=message
    )


@app.route("/tasks/delete", methods=["POST"])
def delete_all_tasks():
    db.task.remove()
    return jsonify(
        message="All Tasks deleted!"
    )


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)