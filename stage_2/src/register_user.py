import flask
import logging
import psycopg2
import time
import jwt
from datetime import datetime

from global_functions import db_connection, logger, StatusCodes, check_required_fields
from hashing import hash_password

def insert_service_user(cur, name, nationality, phone, birthday, email, password):
    # Open the query file
    add_service_user_script = 'queries/add_service_user.sql'
    with open(add_service_user_script, 'r') as f:
        query = f.read()
        
    # Insert the user into the service_user table
    cur.execute(query, (name, nationality, phone, birthday, email, password))
    
    # Get and return the user_id
    user_id = cur.fetchone()[0]
    return user_id
    
def insert_patient(cur, user_id):
    cur.execute("""
                INSERT INTO patient (service_user_user_id)
                VALUES (%s);
                """, (str(user_id),))
    

# def register_service_user(user_type, extra_fields):
#     # Get the request payload
#     payload = flask.request.get_json()
    
#     # Connect to the database
#     conn = db_connection()
#     cur = conn.cursor()
    
#     # Write request to debug log
#     logger.debug(f'POST /dbproj/register/service_user - payload: {payload}')
    
#     # Check if all required fields are present
#     required_fields = ['name', 'nationality', 'phone', 'birthday', 'email', 'password']
#     missing_keys = check_required_fields(payload, required_fields + extra_fields)
#     if(len(missing_keys) > 0):
#         response = {
#             'status': StatusCodes['bad_request'],
#             'errors': f'Missing required field(s): {", ".join(missing_keys)}'
#         }
#         return flask.jsonify(response)
    
#     try:
#         # Start the transaction
#         cur.execute('BEGIN;')
        
#         # Insert the user into the service_user table
#         user_id = insert_service_user(cur, payload['name'], payload['nationality'], str(payload['phone']), payload['birthday'], payload['email'], hash_password(payload['password']))
        
#         # Insert the user into the specific table
#         extra_fields_values = tuple([payload[field] for field in extra_fields])
        
        
        
        
        
        
            
    

def register_patient():
    # Get the request payload
    payload = flask.request.get_json()
    
    # Connect to the database
    conn = db_connection()
    cur = conn.cursor()
    
    # Write request to debug log
    logger.debug(f'POST /dbproj/register/patient - payload: {payload}')

    # Check if all required fields are present
    missing_keys = check_required_fields(payload, ['name', 'nationality', 'phone', 'birthday', 'email', 'password'])
    if (len(missing_keys) > 0):
        response = {
            'status': StatusCodes['bad_request'],
            'errors': f'Missing required field(s): {", ".join(missing_keys)}'
        }
        return flask.jsonify(response)
    
    # Get the payload values
    values = (payload['name'], payload['nationality'], str(payload['phone']), payload['birthday'], payload['email'], hash_password(payload['password']))
        
    # Open the query file
    add_service_user_script = 'queries/add_service_user.sql'
    with open(add_service_user_script, 'r') as f:
        query = f.read()
    
    try:
        # Start the transaction
        cur.execute('BEGIN;')
        
        # Insert the patient into the service_user table
        cur.execute(query, values)

        # Get the user_id
        user_id = cur.fetchone()[0] # Get the returned user_id from the query

        # Insert the patient into the patient table
        cur.execute(
            """
            INSERT INTO patient (service_user_user_id)
            VALUES (%s);
            """, (str(user_id),)
        )

        # Commit the transaction
        cur.execute('COMMIT;')
        
        response = {'status': StatusCodes['success'], 
                    'errors': None, 
                    'results': f'user_id: {user_id}'}
        
    except(Exception, psycopg2.DatabaseError) as error:
        logger.error(f'POST /dbproj/register/patient - error: {error}')
        response = {
            'status': StatusCodes['internal_error'], 
            'errors': str(error)
        }
        
        # Rollback the transaction
        cur.execute('ROLLBACK;')
    
    finally:
        if conn is not None:
            conn.close()
        
    return flask.jsonify(response)        


def register_assistant():
    # Get the request payload
    payload = flask.request.get_json()
    
    # Connect to the database
    conn = db_connection()
    cur = conn.cursor()
    
    # Write request to debug log
    logger.debug(f'POST /dbproj/register/assistant - payload: {payload}')

    # Check if all required fields are present
    missing_keys = check_required_fields(payload, ['name', 'nationality', 'phone', 'birthday', 'email', 'password'])
    if (len(missing_keys) > 0):
        response = {
            'status': StatusCodes['bad_request'],
            'errors': f'Missing required field(s): {", ".join(missing_keys)}'
        }
        return flask.jsonify(response)
    
    # Get the payload values
    values = (payload['name'], payload['nationality'], str(payload['phone']), payload['birthday'], payload['email'], hash_password(payload['password']))
    
    # Open the query file
    add_service_user_script = 'queries/add_service_user.sql'
    with open(add_service_user_script, 'r') as f:
        query = f.read()
        
    try:
        # Start the transaction
        cur.execute('BEGIN;')
        
        # Insert the assistant into the service_user table
        cur.execute(query, values)
        # Get the user_id
        user_id = cur.fetchone()[0] # Get the returned user_id from the query
        
        # Get the values for the employee_contract table
        contract_values = (user_id, payload['contract_start_date'], payload['contract_end_date'])

        # Insert the assistant into the employee_contract table
        add_employee_script = 'queries/add_employee.sql'
        with open(add_employee_script, 'r') as f:
            query = f.read()
        cur.execute(query, contract_values)
        
        
        # Insert the assistant into the assistant table 
        cur.execute(
            """
            INSERT INTO assistant (employee_contract_service_user_user_id)
            VALUES (%s);
            """, (str(user_id),)
        )
        
        # Commit the transaction
        cur.execute('COMMIT;')
        
        response = {'status': StatusCodes['success'], 
                    'errors': None,
                    'results': f'user_id: {user_id}'}
            
    except(Exception, psycopg2.DatabaseError) as error:
        logger.error(f'POST /dbproj/register/assistant - error: {error}')
        response = {'status': StatusCodes['internal_error'], 'errors': str(error)}
        
        # Rollback the transaction
        cur.execute('ROLLBACK;')
    
    finally:
        if conn is not None:
            conn.close()
            
    return flask.jsonify(response)


def register_nurse():
    # Get the request payload
    payload = flask.request.get_json()
    
    # Connect to the database
    conn = db_connection()
    cur = conn.cursor()
    
    # Write request to debug log
    logger.debug(f'POST /dbproj/register/nurse - payload: {payload}')

    # Check if all required fields are present
    missing_keys = check_required_fields(payload, ['name', 'nationality', 'phone', 'birthday', 'email', 'password', 'contract_start_date', 'contract_end_date', 'rank_id'])
    if (len(missing_keys) > 0):
        response = {
            'status': StatusCodes['bad_request'],
            'errors': f'Missing required field(s): {", ".join(missing_keys)}'
        }
        return flask.jsonify(response)
    
    
    # Get the payload values
    values = (payload['name'], payload['nationality'], str(payload['phone']), payload['birthday'], payload['email'], hash_password(payload['password']))
    
    # Open the query file
    add_service_user_script = 'queries/add_service_user.sql'
    with open(add_service_user_script, 'r') as f:
        query = f.read()
        
    try:
        # Start the transaction
        cur.execute('BEGIN;')
        
        # Insert the nurse into the service_user table
        cur.execute(query, values)
        # Get the user_id
        user_id = cur.fetchone()[0] # Get the returned user_id from the query
        
        # Get the values for the employee_contract table
        contract_values = (user_id, payload['contract_start_date'], payload['contract_end_date'])

        # Insert the nurse into the employee_contract table
        add_employee_script = 'queries/add_employee.sql'
        with open(add_employee_script, 'r') as f:
            query = f.read()
        cur.execute(query, contract_values)
        
        # Insert the nurse into the nurse table 
        cur.execute(
            """
            INSERT INTO nurse (employee_contract_service_user_user_id, rank_rank_id)
            VALUES (%s, %s);
            """, (str(user_id), str(payload['rank_id']))
        )
        
        # Commit the transaction
        cur.execute('COMMIT;')
        
        response = {'status': StatusCodes['success'], 
                    'errors': None,                    
                    'results': f'user_id: {user_id}'}
            
    except(Exception, psycopg2.DatabaseError) as error:
        logger.error(f'POST /dbproj/register/nurse - error: {error}')
        response = {'status': StatusCodes['internal_error'], 'errors': str(error)}
        
        # Rollback the transaction
        cur.execute('ROLLBACK;')
        
    finally:
        if conn is not None:
            conn.close()
            
    return flask.jsonify(response)


def register_doctor():
    # Get the request payload
    payload = flask.request.get_json()
    
    # Connect to the database
    conn = db_connection()
    cur = conn.cursor()
    
    # Write request to debug log
    logger.debug(f'POST /dbproj/register/doctor - payload: {payload}')

    # Check if all required fields are present
    missing_keys = check_required_fields(payload, ['name', 'nationality', 'phone', 'birthday', 'email', 'password', 'contract_start_date', 'contract_end_date', 'university', 'graduation_date', 'specializations'])
    if (len(missing_keys) > 0):
        response = {
            'status': StatusCodes['bad_request'],
            'errors': f'Missing required field(s): {", ".join(missing_keys)}'
        }
        return flask.jsonify(response)
    
    # Get the payload values
    values = (payload['name'], payload['nationality'], str(payload['phone']), payload['birthday'], payload['email'], hash_password(payload['password']))
    
    # Open the query file
    add_service_user_script = 'queries/add_service_user.sql'
    with open(add_service_user_script, 'r') as f:
        query = f.read()
        
    try:
        # Start the transaction
        cur.execute('BEGIN;')
        
        # Insert the doctor into the service_user table
        cur.execute(query, values)
        # Get the user_id
        user_id = cur.fetchone()[0] # Get the returned user_id from the query
        
        # Get the values for the employee_contract table
        contract_values = (user_id, payload['contract_start_date'], payload['contract_end_date'])

        # Insert the doctor into the employee_contract table
        add_employee_script = 'queries/add_employee.sql'
        with open(add_employee_script, 'r') as f:
            query = f.read()
        cur.execute(query, contract_values)
        
        # Insert the doctor into the doctor table 
        cur.execute(
            """
            INSERT INTO doctor (university, graduation_date, employee_contract_service_user_user_id)
            VALUES (%s, %s, %s);
            """, (payload['university'], payload['graduation_date'], str(user_id))
        )
        
        # Insert the doctor's specializations into the specialization_doctor table
        for spec_name in payload['specializations']:
            # Get the specialization ID from the specializations table
            cur.execute(
                """
                SELECT spec_id
                FROM specialization
                WHERE spec_name = %s;
                """, (spec_name,)
            )
            spec_id = cur.fetchone()
            # Check if the specialization exists
            if spec_id is None:
                logger.error(f'POST /dbproj/register/doctor - error: Specialization {spec_name} does not exist')
                response = {'status': StatusCodes['bad_request'], 'errors': f'Specialization {spec_name} does not exist'}
                return flask.jsonify(response)
            spec_id = spec_id[0]

            # Insert the specialization into the specialization_doctor table
            cur.execute(
                """
                INSERT INTO specialization_doctor (specialization_spec_id, doctor_employee_contract_service_user_user_id)
                VALUES (%s, %s);
                """, (str(spec_id), str(user_id))
            )
        
        # Commit the transaction
        cur.execute('COMMIT;')
        
        response = {'status': StatusCodes['success'], 
                    'errors': None,
                    'results': f'user_id: {user_id}'}
            
    except(Exception, psycopg2.DatabaseError) as error:
        logger.error(f'POST /dbproj/register/doctor - error: {error}')
        response = {'status': StatusCodes['internal_error'], 'errors': str(error)}
        
        # Rollback the transaction
        cur.execute('ROLLBACK;')
    
    finally:
        if conn is not None:
            conn.close()
            
    return flask.jsonify(response)