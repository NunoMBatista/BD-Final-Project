import flask
import logging
import psycopg2
import time
import jwt
from datetime import datetime
from flask_jwt_extended import get_jwt_identity

from global_functions import db_connection, logger, StatusCodes, check_required_fields

def check_nurse_fields(nurses):
    for nurse in nurses:
        if 'nurse_id' not in nurse or 'role' not in nurse:
            raise ValueError('Nurses must have id and role')

def check_doctor_availability(cur, doctor_id, date):
    # Check if the doctor has no simultaneous appointments
    check_doctor_appointment_availability(cur, doctor_id, date)
    
    # Check if the doctor has no simultaneous surgeries
    check_doctor_surgery_availability(cur, doctor_id, date)

def check_doctor_appointment_availability(cur, doctor_id, date):
    cur.execute("""
                SELECT * FROM appointment 
                WHERE doctor_employee_contract_service_user_user_id = %s AND app_date = %s
                """, (doctor_id, date))
    if cur.fetchone():
        raise ValueError('Doctor is not available on the selected date')

def check_doctor_surgery_availability(cur, doctor_id, date):
    cur.execute("""
                SELECT * FROM surgery 
                WHERE doctor_employee_contract_service_user_user_id = %s AND surg_date = %s
                """, (doctor_id, date))
    if cur.fetchone():
        raise ValueError('Doctor is not available on the selected date')

def check_nurse_availability(cur, nurse_id, date):
    # Check if the nurse has no simultaneous appointments
    check_nurse_appointment_availability(cur, nurse_id, date)
    
    # Check if the nurse has no simultaneous surgeries
    check_nurse_surgery_availability(cur, nurse_id, date)

def check_nurse_appointment_availability(cur, nurse_id, date):
    cur.execute("""
                SELECT ap.* FROM enrolment_appointment ea
                JOIN appointment ap ON ea.appointment_app_id = ap.app_id
                WHERE ea.nurse_employee_contract_service_user_user_id = %s AND ap.app_date = %s
                """, (nurse_id, date)) 
    if cur.fetchone():
        raise ValueError('Nurse is not available on the selected date')

def check_nurse_surgery_availability(cur, nurse_id, date):
    cur.execute("""
                SELECT s.* FROM enrolment_surgery es
                JOIN surgery s ON es.surgery_surgery_id = s.surgery_id
                WHERE es.nurse_employee_contract_service_user_user_id = %s AND s.surg_date = %s
                """, (nurse_id, date))
    if cur.fetchone():
        raise ValueError('Nurse is not available on the selected date')

def get_type_id(cur, type):
    cur.execute("""
                SELECT type_id FROM app_type WHERE type_name = %s
                """, (type,))
    return cur.fetchone()[0]

def insert_appointment(cur, date, doctor_id, user_id, type_id):
    cur.execute("""
                INSERT INTO appointment (app_date, doctor_employee_contract_service_user_user_id, patient_service_user_user_id, app_type_type_id) 
                VALUES (%s, %s, %s, %s) 
                RETURNING app_id
                """, (date, doctor_id, user_id, type_id))
    return cur.fetchone()[0]

def insert_nurses(cur, app_id, nurses):
    for nurse in nurses:
        cur.execute("""
                    INSERT INTO enrolment_appointment (appointment_app_id, nurse_employee_contract_service_user_user_id, role_role_id) 
                    VALUES (%s, %s, (
                        SELECT role_id FROM role
                        WHERE role_name = %s
                        ))
                    """, (app_id, nurse['nurse_id'], nurse['role']))

def schedule_appointment():
    # Get the request payload
    payload = flask.request.get_json()
    
    # Get the user ID from the JWT
    user_id = get_jwt_identity()[0]
    
    # Connect to the database
    conn = db_connection()
    cur = conn.cursor()
    
    try: 
        # Start the transaction
        cur.execute("BEGIN;")
        
        # Check if all the required fields are present
        check_required_fields(payload, ['doctor_id', 'date', 'type'])
    
        # Get the payload values
        doctor_id = payload['doctor_id']
        date = payload['date']
        # Nurses are optional, they have id and role
        nurses = payload.get('nurses', [])
    
        # Check if all nurses have id and role
        check_nurse_fields(nurses)
        
        # Check if the doctor and nurses are available
        check_doctor_availability(cur, doctor_id, date)
        
        for nurse in nurses:
            check_nurse_availability(cur, nurse['nurse_id'], date)
        
            
        # Get the appointment type id
        type_id = get_type_id(cur, payload['type'])
            
        # Insert the appointment
        app_id = insert_appointment(cur, date, doctor_id, user_id, type_id)
        
        # Insert the nurses into the enrolement_appointments table
        insert_nurses(cur, app_id, nurses)
                
        # Commit the transaction
        cur.execute("COMMIT;")

        response = {
            'status': StatusCodes['success'],
            'results': f'appointment_id: {app_id}'
        }
        
    except(Exception, psycopg2.DatabaseError) as error:
        logger.error(error)
        response = {
            'status': StatusCodes['internal_error'],
            'errors': 'An error occurred while scheduling the appointment'
        }
        
        cur.execute("ROLLBACK;")
        
    finally:
        if cur is not None:
            cur.close()
            
    return flask.jsonify(response)