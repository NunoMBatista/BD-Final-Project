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
    
    try:
        cur.execute("BEGIN;")
        
        with open('queries/top3.sql', 'r') as f:
            query = f.read()
        
        cur.execute(query)
        
        top3_list = cur.fetchall()
        
        response = {
            'status': StatusCodes['success'],
            'errors': None,
            'response': top3_list
        }
        
    except (Exception, psycopg2.DatabaseError) as error:
        logger.error(f'GET /dbproj/top3 {error}')
        response = {
            'status': StatusCodes['internal_error'],
            'errors': str(error)
        }
        return flask.jsonify(response)
    
    finally:
        if conn is not None:
            conn.close()
            
        return flask.jsonify(response)