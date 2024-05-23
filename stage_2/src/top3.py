import flask
import logging
import psycopg2
import time
import jwt
from datetime import datetime
from flask_jwt_extended import get_jwt_identity

from global_functions import db_connection, logger, StatusCodes, check_required_fields, APPOINTMENT_DURATION, SURGERY_DURATION

def top3():
    # Write to debug log
    logger.debug(f'GET /dbproj/top3')
    
    # Connect to the database
    conn = db_connection()
    cur = conn.cursor()
    
    