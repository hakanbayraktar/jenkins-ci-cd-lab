import os

from flask import Flask, jsonify

app = Flask(__name__)


@app.get("/")
def index():
    return jsonify(application="jenkins-ci-cd-lab", message="CI/CD pipeline is working")


@app.get("/health")
def health():
    return jsonify(status="healthy")


@app.get("/version")
def version():
    return jsonify(version=os.getenv("APP_VERSION", "development"), environment="training")
