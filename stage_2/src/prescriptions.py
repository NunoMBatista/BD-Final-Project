import flask
import logging
import psycopg2
import time
import jwt
from datetime import datetime
from flask_jwt_extended import get_jwt_identity

from global_functions import db_connection, logger, StatusCodes, check_required_fields

def prescribe_medication():
    # Get the payload data
    payload = flask.request.get_json()
    
    # Check if the required fields are present
    missing_keys = check_required_fields(payload, ['patient_id', 'doctor_id', 'medication', 'dosage', 'start_date', 'end_date'])