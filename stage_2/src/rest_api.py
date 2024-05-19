'''
               Databases
             LEI 2023/2024

     +----------------------------+
     | Hospital Management System |
     +----------------------------+

     -> Nuno Batista 👍 2022213951
    -> Miguel Martins 👍 2022213951
    
'''

import flask
import logging
import psycopg2
import time
import jwt
from datetime import datetime
from flask_jwt_extended import JWTManager, create_access_token

from global_functions import db_connection, logger, StatusCodes, run_sql_script, landing_page
from register_user import register_patient, register_assistant, register_nurse, register_doctor

app = flask.Flask(__name__)

# Set up the JWT secret key
app.config['JWT_SECRET_KEY'] = 'secret key'
jwt = JWTManager(app)

# Improve later
app.route('/') (landing_page)

# Register a patient
app.route('/dbproj/register/patient', methods=['POST']) (register_patient)

# Register an assistant
app.route('/dbproj/register/assistant', methods=['POST']) (register_assistant)

# Register a nurse
app.route('/dbproj/register/nurse', methods=['POST']) (register_nurse)

# Register a doctor
app.route('/dbproj/register/doctor', methods=['POST']) (register_doctor)

# Authenticate a user
@app.route('/dbproj/user', methods=['POST'])
def authenticate_user():
    payload = flask.request.get_json()
    username = payload['email']
    password = payload['password']
    
    # Connect to the database
    conn = db_connection()
    cur = conn.cursor()
    
    
    

if __name__ == '__main__':
    # Set up logging
    logging.basicConfig(filename='log_file.log')   
    logger.setLevel(logging.DEBUG)
    ch = logging.StreamHandler()
    ch.setLevel(logging.DEBUG)
    
    # Set up the formatter
    formatter = logging.Formatter('%(asctime)s [%(levelname)s]: %(message)s', '%H:%M:%S')
    ch.setFormatter(formatter)
    logger.addHandler(ch)
    
    # Run table creation script
    run_sql_script('queries/drop_tables.sql')
    run_sql_script('queries/tables_creation.sql')
    run_sql_script('queries/tables_constraints.sql')
    run_sql_script('queries/populate_tables.sql')
    
    # Start the server
    host = '127.0.0.1'
    port = 8080
    logger.info(f'Starting HMS server on http://{host}:{port}')
    app.run(host=host, threaded=True, port=port)