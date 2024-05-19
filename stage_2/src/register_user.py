import flask
import logging
import psycopg2
import time
import jwt
from datetime import datetime

from global_functions import db_connection, logger, StatusCodes

def register_patient():
    # Get the request data
    payload = flask.request.get_json()
    
    # Connect to the database
    conn = db_connection()
    cur = conn.cursor()
    
    # Write request to debug log
    logger.debug(f'POST /dbproj/register/patient - payload: {payload}')

    # Check if all required fields are present
    required_keys = ['name', 'nationality', 'phone', 'birthday', 'email', 'password']
    missing_keys = [key for key in required_keys if key not in payload]
    if len(missing_keys) > 0:
        # Return an error response
        response = {'status': StatusCodes['api_error'], 'errors': f'Missing required field(s): {", ".join(missing_keys)}'}
        return flask.jsonify(response)
    
    # Get the payload values
    values = (payload['name'], payload['nationality'], str(payload['phone']), payload['birthday'], payload['email'], payload['password'])
        
    # Open the query file
    add_service_user_script = 'queries/add_service_user.sql'
    with open(add_service_user_script, 'r') as f:
        query = f.read()
    
    try:
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
        conn.commit()
        
        response = {'status': StatusCodes['success'], 'results': f'user_id: {user_id}'}
        
    except(Exception, psycopg2.DatabaseError) as error:
        logger.error(f'POST /dbproj/register/patient - error: {error}')
        response = {'status': StatusCodes['internal_error'], 'errors': str(error)}
        
        # Rollback the transaction
        conn.rollback()
    
    finally:
        if conn is not None:
            conn.close()
        
    return flask.jsonify(response)        


def register_assistant():
    # Get the request data
    payload = flask.request.get_json()
    
    # Connect to the database
    conn = db_connection()
    cur = conn.cursor()
    
    # Write request to debug log
    logger.debug(f'POST /dbproj/register/assistant - payload: {payload}')

    # Check if all required fields are present
    required_keys = ['name', 'nationality', 'phone', 'birthday', 'email', 'password', 'contract_start_date', 'contract_end_date']
    missing_keys = [key for key in required_keys if key not in payload]
    
    if len(missing_keys) > 0:       
        # Return an error response
        response = {'status': StatusCodes['api_error'], 'errors': f'Missing required field(s): {", ".join(missing_keys)}'}
        return flask.jsonify(response)
    
    # Get the payload values
    values = (payload['name'], payload['nationality'], str(payload['phone']), payload['birthday'], payload['email'], payload['password'])
    
    # Open the query file
    add_service_user_script = 'queries/add_service_user.sql'
    with open(add_service_user_script, 'r') as f:
        query = f.read()
        
    try:
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
        conn.commit()
        
        response = {'status': StatusCodes['success'], 'results': f'user_id: {user_id}'}
            
    except(Exception, psycopg2.DatabaseError) as error:
        logger.error(f'POST /dbproj/register/assistant - error: {error}')
        response = {'status': StatusCodes['internal_error'], 'errors': str(error)}
        
        # Rollback the transaction
        conn.rollback()
    
    finally:
        if conn is not None:
            conn.close()
            
    return flask.jsonify(response)


def register_nurse():
    # Get the request data
    payload = flask.request.get_json()
    
    # Connect to the database
    conn = db_connection()
    cur = conn.cursor()
    
    # Write request to debug log
    logger.debug(f'POST /dbproj/register/nurse - payload: {payload}')

    # Check if all required fields are present
    required_keys = ['name', 'nationality', 'phone', 'birthday', 'email', 'password', 'contract_start_date', 'contract_end_date', 'rank_id']
    missing_keys = [key for key in required_keys if key not in payload]
    
    if len(missing_keys) > 0:       
        # Return an error response
        response = {'status': StatusCodes['api_error'], 'errors': f'Missing required field(s): {", ".join(missing_keys)}'}
        return flask.jsonify(response)
    
    # Get the payload values
    values = (payload['name'], payload['nationality'], str(payload['phone']), payload['birthday'], payload['email'], payload['password'])
    
    # Open the query file
    add_service_user_script = 'queries/add_service_user.sql'
    with open(add_service_user_script, 'r') as f:
        query = f.read()
        
    try:
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
        conn.commit()
        
        response = {'status': StatusCodes['success'], 'results': f'user_id: {user_id}'}
            
    except(Exception, psycopg2.DatabaseError) as error:
        logger.error(f'POST /dbproj/register/nurse - error: {error}')
        response = {'status': StatusCodes['internal_error'], 'errors': str(error)}
        
        # Rollback the transaction
        conn.rollback()
    
    finally:
        if conn is not None:
            conn.close()
            
    return flask.jsonify(response)


def register_doctor():
    # Get the request data
    payload = flask.request.get_json()
    
    # Connect to the database
    conn = db_connection()
    cur = conn.cursor()
    
    # Write request to debug log
    logger.debug(f'POST /dbproj/register/doctor - payload: {payload}')

    # Check if all required fields are present
    required_keys = ['name', 'nationality', 'phone', 'birthday', 'email', 'password', 'contract_start_date', 'contract_end_date', 'university', 'graduation_date', 'specializations']
    missing_keys = [key for key in required_keys if key not in payload]
    
    if len(missing_keys) > 0:       
        # Return an error response
        response = {'status': StatusCodes['api_error'], 'errors': f'Missing required field(s): {", ".join(missing_keys)}'}
        return flask.jsonify(response)
    
    # Get the payload values
    values = (payload['name'], payload['nationality'], str(payload['phone']), payload['birthday'], payload['email'], payload['password'])
    
    # Open the query file
    add_service_user_script = 'queries/add_service_user.sql'
    with open(add_service_user_script, 'r') as f:
        query = f.read()
        
    try:
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
                response = {'status': StatusCodes['api_error'], 'errors': f'Specialization {spec_name} does not exist'}
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
        conn.commit()
        
        response = {'status': StatusCodes['success'], 'results': f'user_id: {user_id}'}
            
    except(Exception, psycopg2.DatabaseError) as error:
        logger.error(f'POST /dbproj/register/doctor - error: {error}')
        response = {'status': StatusCodes['internal_error'], 'errors': str(error)}
        
        # Rollback the transaction
        conn.rollback()
    
    finally:
        if conn is not None:
            conn.close()
            
    return flask.jsonify(response)