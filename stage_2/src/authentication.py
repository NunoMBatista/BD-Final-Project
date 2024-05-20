import flask
import logging
import jwt
import psycopg2
import datetime
from flask_jwt_extended import create_access_token, get_jwt, set_access_cookies
from functools import wraps

from global_functions import db_connection, logger, StatusCodes

# Authenticate a user and return an access token
def authenticate_user():
    payload = flask.request.get_json()
    
    # Connect to the database
    conn = db_connection()
    cur = conn.cursor()
    
    # Write request to debug log
    logger.debug(f'POST /dbproj/user - payload: {payload}')
    
    # Check if all required fields are present
    required_keys = ['email', 'password']
    missing_keys = [key for key in required_keys if key not in payload]
    
    if len(missing_keys) > 0:
        # Return an error response
        response = {
            'status': StatusCodes['bad_request'],
            'errors': f'Missing required field(s): {missing_keys}'
        }
        return flask.jsonify(response)
    
    # Get the values
    values = (payload['email'], payload['password'])
    
    try:
        # Query the database for the user_id
        cur.execute("""
                    SELECT user_id FROM service_user
                    WHERE email = %s AND password = %s
                    """, values)
        user_id = cur.fetchone()     
        
        if user_id is None:
            # Return an error response
            response = {
                'status': StatusCodes['bad_request'],
                'errors': 'User not found'
            }
            return flask.jsonify(response)
        
        # Determine the user's role
        role = None 
        tables = {
            'patient': 'service_user_user_id',
            'assistant': 'employee_contract_service_user_user_id',
            'nurse': 'employee_contract_service_user_user_id',
            'doctor': 'employee_contract_service_user_user_id'
        }
        # Query each possible role table to see if the user_id is present
        for table, id_column in tables.items():
            query = f"""
                    SELECT 1 FROM {table}
                    WHERE {id_column} = %s 
                    """
            cur.execute(query, (user_id,))
            # If the user_id is present in the table, the user has that role
            if cur.fetchone() is not None:
                role = table
                break
            
        # If the user has no role, return an error response
        if role is None:
            response = {
                'status': StatusCodes['bad_request'],
                'errors': 'User has no role'
            }
            return flask.jsonify(response)
    
        logger.debug(f'POST /dbproj/user - user_id: {user_id[0]}, role: {role}')
    
        # Generate an access token
        additional_claims = {'role': role}
        access_token = create_access_token(identity=user_id, additional_claims=additional_claims)
        
        # Create a Flask Response object
        response = flask.make_response(flask.jsonify({
            'status': StatusCodes['success'],
            'results': access_token
        }))
        
        # Set the access token as a cookie 
        set_access_cookies(response, access_token)
                
    except(Exception, psycopg2.DatabaseError) as error:
        logger.error(f'POST /dbproj/user - error: {error}')
        response = flask.make_response(flask.jsonify({
            'status': StatusCodes['internal_error'],
            'errors': 'Internal server error'
        }))
               
        return flask.jsonify(response)
 
    finally:
        if conn is not None:
            conn.close()
    
    return response
    
# Decorator to check if the user has the required role
def role_required(required_role):
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs): # Same arguments as the original function
            claims = get_jwt() 
            # Check if the user has the required role
            if claims['role'] != required_role: 
                logger.error(f'Insufficient permissions - required: {required_role}, actual: {claims["role"]}')
                response = {
                    'status': StatusCodes['bad_request'],
                    'errors': 'Insufficient permissions'
                }
                return flask.jsonify(response)
            # If the user has the required role, call the original function
            return func(*args, **kwargs)
        # Return the wrapper function to be called instead of the original function
        return wrapper
    # Return the decorator function to be called with the required role
    return decorator
