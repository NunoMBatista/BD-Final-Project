import flask
import logging
import psycopg2
import time
import jwt
from datetime import datetime

"""
    Global variabless
"""

db_connection = None
logger = logging.getLogger('logger')
StatusCodes = {
    'api_error': 400,
    'success': 200,
    'internal_error': 500
}




"""
    Global functions
"""

# Connect to the database
def db_connection():
    db = psycopg2.connect(
        user = 'hms_admin',
        password = 'hms_admin',
        host = '127.0.0.1',
        port = '5432',
        database = 'hms_db'
    )
    
    return db

# Run a SQL script
def run_sql_script(script):
    conn = db_connection()
    cursor = conn.cursor()
    
    try:
        with open(script, 'r') as f:
            script_str = f.read()
        cursor.execute(script_str)
        print(script + ' executed successfully')
        conn.commit()
    except Exception as e:
        conn.rollback()
        raise e
    finally:
        cursor.close()
        conn.close()

# Landing page
def landing_page():
    return """
    <!DOCTYPE html>
    <html>
    <head>
        <style>
            body {
                background-color: #f2f2f2;
                font-family: Arial, sans-serif;
            }
            .container {
                width: 80%;
                margin: auto;
                text-align: center;
            }
            h1 {
                color: #333;
            }
            p {
                font-size: 1.2em;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>Welcome to the Hospital Management System</h1>
        </div>
    </body>
    </html>
    """