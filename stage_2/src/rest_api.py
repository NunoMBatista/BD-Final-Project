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
from datetime import timedelta
from flask_jwt_extended import JWTManager, create_access_token, get_jwt_identity, jwt_required

from config import Config
# Import global functions and variables
from global_functions import db_connection, logger, StatusCodes, run_sql_script, landing_page, check_required_fields
# Import the register functions
from register_user import register_patient, register_assistant, register_nurse, register_doctor
# Import the authentication function
from authentication import authenticate_user, role_required
# Import the scheduling function
from scheduling import schedule_appointment

app = flask.Flask(__name__)
app.config.from_object(Config)
jwt = JWTManager(app)

# Improve later
app.route('/') (landing_page)

# Register a patient
@app.route('/dbproj/register/patient', methods=['POST'])
def register_patient_endpoint():
    return register_patient()

# Register an assistant
@app.route('/dbproj/register/assistant', methods=['POST'])
def register_assistant_endpoint():
    return register_assistant()

# Register a nurse
@app.route('/dbproj/register/nurse', methods=['POST'])
def register_nurse_endpoint():
    return register_nurse()

# Register a doctor
@app.route('/dbproj/register/doctor', methods=['POST'])
def register_doctor_endpoint():
    return register_doctor()

# Authenticate a user
@app.route('/dbproj/user', methods=['PUT'])
def authenticate_user_endpoint():
    return authenticate_user()

@app.route('/dbproj/appointment', methods=['POST'])
@jwt_required()
@role_required('patient')
def schedule_appointment_endpoint():
    return schedule_appointment()

# def schedule_appointment():
#     # Get the request payload
#     payload = flask.request.get_json()
    
#     # Get the user ID from the JWT
#     user_id = get_jwt_identity()[0]
    
#     # Connect to the database
#     conn = db_connection()
#     cur = conn.cursor()
    
#     # Check if all the required fields are present
#     required_keys = ['doctor_id', 'date', 'type']
#     missing_keys = [key for key in required_keys if key not in payload]
#     if len(missing_keys) > 0:
#         logger.error(f'Missing required fields: {", ".join(missing_keys)}')
#         response = {
#             'status': StatusCodes['bad_request'],
#             'errors': f'Missing required fields: {", ".join(missing_keys)}'
#             }
#         return flask.jsonify(response)
    
#     # Get the payload values
#     doctor_id = payload['doctor_id']
#     date = payload['date']
#     # Nurses are optional, they have id and role
#     nurses = payload.get('nurses', [])
    
#     # Check if all nurses have id and role
#     for nurse in nurses:
#         if 'nurse_id' not in nurse or 'role' not in nurse:
#             logger.error('Nurses must have id and role')
#             response = {
#                 'status': StatusCodes['bad_request'],
#                 'errors': 'Nurses must have id and role'
#             }
#             return flask.jsonify(response)
    
#     try: 
#         # Start the transaction
#         cur.execute("BEGIN;")
                
#         # Check if the doctor has no simultaneous appointments
#         cur.execute("""
#                     SELECT * FROM appointment 
#                     WHERE doctor_employee_contract_service_user_user_id = %s AND app_date = %s
#                     """, (doctor_id, date))
#         if cur.fetchone():
#             logger.error('Doctor is not available on the selected date')
#             response = {
#                 'status': StatusCodes['bad_request'],
#                 'errors': 'Doctor is not available on the selected date'
#             }
#             return flask.jsonify(response)
        
#         # Check if the doctor has no simultaneous surgeries
#         cur.execute("""
#                     SELECT * FROM surgery 
#                     WHERE doctor_employee_contract_service_user_user_id = %s AND surg_date = %s
#                     """, (doctor_id, date))
#         if cur.fetchone():
#             logger.error('Doctor is not available on the selected date')
#             response = {
#                 'status': StatusCodes['bad_request'],
#                 'errors': 'Doctor is not available on the selected date'
#             }
#             return flask.jsonify(response)
        
        
#         # Check if the nurses have no simultaneous appointments or surgeries
#         for nurse in nurses:
#             nurse_id = nurse['nurse_id']
            
#             # Check if the nurse has no simultaneous appointments
#             cur.execute("""
#                         SELECT ap.* FROM enrolment_appointment ea
#                         JOIN appointment ap ON ea.appointment_app_id = ap.app_id
#                         WHERE ea.nurse_employee_contract_service_user_user_id = %s AND ap.app_date = %s
#                         """, (nurse_id, date)) 
#             if cur.fetchone():
#                 logger.error('Nurse is not available on the selected date')
#                 response = {
#                     'status': StatusCodes['bad_request'],
#                     'errors': 'Nurse is not available on the selected date'
#                 }
#                 return flask.jsonify(response)

#             # Check if the nurse has no simultaneous surgeries
#             cur.execute("""
#                         SELECT s.* FROM enrolment_surgery es
#                         JOIN surgery s ON es.surgery_surgery_id = s.surgery_id
#                         WHERE es.nurse_employee_contract_service_user_user_id = %s AND s.surg_date = %s
#                         """, (nurse_id, date))
#             if cur.fetchone():
#                 logger.error('Nurse is not available on the selected date')
#                 response = {
#                     'status': StatusCodes['bad_request'],
#                     'errors': 'Nurse is not available on the selected date'
#                 }
#                 return flask.jsonify(response)
            
#         # Get the appointment type id
#         cur.execute("""
#                     SELECT type_id FROM app_type WHERE type_name = %s
#                     """, (payload['type'],))
#         type_id = cur.fetchone()[0]
            
#         # Insert the appointment
#         cur.execute("""
#                     INSERT INTO appointment (app_date, doctor_employee_contract_service_user_user_id, patient_service_user_user_id, app_type_type_id) 
#                     VALUES (%s, %s, %s, %s) 
#                     RETURNING app_id
#                     """, (date, doctor_id, user_id, type_id))
#         app_id = cur.fetchone()[0]
        
#         # Insert the nurses into the enrolement_appointments table
#         for nurse in nurses:
#             cur.execute("""
#                         INSERT INTO enrolment_appointment (appointment_app_id, nurse_employee_contract_service_user_user_id, role_role_id) 
#                         VALUES (%s, %s, (
#                             SELECT role_id FROM role
#                             WHERE role_name = %s
#                             ))
#                         """, (app_id, nurse['nurse_id'], nurse['role']))
                
#         # Commit the transaction
#         cur.execute("COMMIT;")

#         response = {
#             'status': StatusCodes['success'],
#             'results': f'appointment_id: {app_id}'
#         }
        
#     except(Exception, psycopg2.DatabaseError) as error:
#         logger.error(error)
#         response = {
#             'status': StatusCodes['internal_error'],
#             'errors': 'An error occurred while scheduling the appointment'
#         }
        
#         cur.execute("ROLLBACK;")
        
#     finally:
#         if cur is not None:
#             cur.close()
            
#     return flask.jsonify(response)

 
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
    run_sql_script('queries/create_bill_trigger.sql')
        
    
    # Start the server
    host = '127.0.0.1'
    port = 8080
    logger.info(f'Starting HMS server on http://{host}:{port}')
    app.run(host=host, threaded=True, port=port)