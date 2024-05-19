import flask
import logging
import jwt
import datetime

def authenticate_user():
    # Get the request data
    payload = flask.req