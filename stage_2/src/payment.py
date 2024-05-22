import flask
import logging
import psycopg2
import time
import jwt
from datetime import datetime
from flask_jwt_extended import get_jwt_identity

from global_functions import db_connection, logger, StatusCodes, check_required_fields, APPOINTMENT_DURATION, SURGERY_DURATION

def pay_bill(): #Isto leva argumentos? Deve levar bill_id
    # Get the request payload
    payload = flask.request.get_json()
    
    print(payload)
    
    # Get the user ID from the JWT
    user_id = get_jwt_identity()
    
    print(user_id)
    
    # Connect to the database
    conn = db_connection()
    cur = conn.cursor()
    
    missing_keys = check_required_fields(payload, ['payment_id', 'amount','payment_date', 'payment_method', 'bill_bill_id'])
    if (len(missing_keys) > 0):
        response = {
            'status': StatusCodes['bad_request'],
            'errors': f'Missing required field(s): {", ".join(missing_keys)}'
        }
        return flask.jsonify(response)
    
    # Get the payload values
    payment_id = payload['payment_id']
    amount = payload['amount']
    payment_date = payload['payment_date']
    payment_method = payload['payment_method']
    bill_bill_id = payload['bill_bill_id'] #Nao deve ser preciso
    
    
    # Check if the bill is associated with the user
    cur.execute("SELECT patient_service_user_user_id FROM appointment WHERE bill_bill_id = %s UNION SELECT patient_service_user_user_id FROM hospitalization WHERE bill_bill_id = %s", (bill_bill_id, bill_bill_id))
    result = cur.fetchone()

    if result is None or result[0] != user_id:
        response = {
            'status': StatusCodes['forbidden'],
            'errors': 'You can only pay your own bills.'
        }
        return flask.jsonify(response)
       
    try:
        # Start the transaction
        cur.execute('BEGIN;')

        # Process the payment
        cur.execute("INSERT INTO payment (payment_id, amount, payment_date, payment_method, bill_bill_id) VALUES (%s, %s, %s, %s, %s)", 
            (payment_id, amount, payment_date, payment_method, bill_bill_id))

        # Commit the transaction
        cur.execute('COMMIT;')
        
        response = {'status': StatusCodes['success'], 'results': f'user_id: {user_id}'}
    except(Exception, psycopg2.DatabaseError) as error:
       
        logger.error(f'POST /dbproj/dbproj/bills/<int:bill_id> - error: {error}')
        response = {'status': StatusCodes['internal_error'], 'errors': str(error)}
        
        # Rollback the transaction
        cur.execute('ROLLBACK;')
    
    finally:
        if conn is not None:
            conn.close()
        
    return flask.jsonify(response)   
    
    
    
    
    
    
    ''' Talvez noutra função ???'''
    # Check if the total amount paid matches the cost of the bill
    cur.execute("SELECT cost FROM bill WHERE bill_id = %s", (bill_bill_id,))
    bill_cost = cur.fetchone()[0]

    if bill_cost == amount:
        # If the total amount paid matches the cost of the bill, update the is_payed field to true
        cur.execute("UPDATE bill SET is_payed = true WHERE bill_id = %s", (bill_bill_id,))