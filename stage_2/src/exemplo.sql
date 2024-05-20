--CREATE TYPE nurse_role AS (
--    nurse_id BIGINT,
--    role varchar
--);

CREATE OR REPLACE FUNCTION is_doctor_available(doctor_id bigint, input_date timestamp without time zone)
RETURNS BOOLEAN AS $$
DECLARE
    is_available BOOLEAN;
BEGIN
    SELECT NOT EXISTS (
        SELECT 1 FROM appointments
        WHERE doctor_id = doctors_employees_person_cc
        AND appointments.data BETWEEN (input_date - INTERVAL '30 minutes') AND (input_date + INTERVAL '30 minutes')
    ) AND NOT EXISTS (
        SELECT 1 FROM surgeries
        JOIN does_surgery ON surgeries.id_sur = does_surgery.surgeries_id_sur
        WHERE doctors_employees_person_cc = doctor_id
        AND data BETWEEN (input_date - INTERVAL '30 minutes') AND (input_date + INTERVAL '30 minutes')
    ) INTO is_available;

    RETURN is_available;
END;
$$ LANGUAGE plpgsql;




CREATE OR REPLACE FUNCTION is_nurse_available(nurse_id bigint, input_date timestamp without time zone)
RETURNS BOOLEAN AS $$
DECLARE
    is_available BOOLEAN;
BEGIN
    SELECT NOT EXISTS (
        SELECT 1 FROM surgeries 
        JOIN does_surgery ON surgeries.id_sur = does_surgery.surgeries_id_sur
        WHERE nurses_employees_person_cc = nurse_id 
        AND data BETWEEN (input_date - INTERVAL '30 minutes') AND (input_date + INTERVAL '30 minutes')
    ) INTO is_available;

    RETURN is_available;
END;
$$ LANGUAGE plpgsql;








CREATE OR REPLACE FUNCTION schedule_surgery(
    input_patient_id bigint, 
    input_doctor_id bigint, 
    nurses nurse_role[], 
    input_date timestamp without time zone, 
    surgery_name varchar,
    hospitalization_date_begin DATE,
    hospitalization_date_end DATE,
    hospitalization_room INT,
    hospitalization_nurse_id BIGINT
)
RETURNS TABLE (
    status_code INT, 
    errors TEXT, 
    returned_hospitalization_id INT, 
    surgery_id INT, 
    patient_id INT, 
    doctor_id INT, 
    date timestamp without time zone
) AS $$



DECLARE
    nurse_role nurse_role;
    new_hospitalization_id bigint;
    new_surgery_id bigint;
BEGIN
    -- Check if the doctor is available
    IF NOT is_doctor_available(input_doctor_id, input_date) THEN
        RAISE EXCEPTION 'Doctor is not available on the specified date' USING ERRCODE = '45000';
    END IF;

    -- Check if the nurses are available
    FOREACH nurse_role IN ARRAY nurses LOOP
        IF NOT is_nurse_available(nurse_role.nurse_id, input_date) THEN
            RAISE EXCEPTION 'Nurse with id % is not available on the specified date', nurse_role.nurse_id USING ERRCODE = '45000';
        END IF;
    END LOOP;

    -- Create a new hospitalization
    INSERT INTO hospitalizations (date_begin, date_end, room, nurses_employees_person_cc, patients_person_cc) 
    VALUES (hospitalization_date_begin, hospitalization_date_end, hospitalization_room, hospitalization_nurse_id, input_patient_id) 
    RETURNING id_hos INTO new_hospitalization_id;

    -- Create a new surgery and associate it with the doctor and the hospitalization
    INSERT INTO surgeries (name, data, doctors_employees_person_cc, hospitalizations_id_hos) 
    VALUES (surgery_name, input_date, input_doctor_id, new_hospitalization_id) 
    RETURNING id_sur INTO new_surgery_id;

    -- For each nurse, create a record in the does_surgery table
    FOREACH nurse_role IN ARRAY nurses LOOP
        INSERT INTO does_surgery (roles_role_num, surgeries_id_sur, nurses_employees_person_cc) 
        VALUES ((SELECT role_num FROM roles WHERE role_name = nurse_role.role), new_surgery_id, nurse_role.nurse_id);
    END LOOP;

    RETURN QUERY SELECT 200, NULL, new_hospitalization_id::int, new_surgery_id::int, input_patient_id::int, input_doctor_id::int, input_date;
EXCEPTION
    WHEN others THEN
        RETURN QUERY SELECT 500, SQLERRM, NULL::int, NULL::int, NULL::int, NULL::int, NULL::timestamp without time zone;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION create_new_bill_surgery()
RETURNS TRIGGER AS $$
DECLARE
    new_bill_id bigint;
BEGIN
    -- Create a new bill
    INSERT INTO billings (total, payed, NIF) 
    VALUES (300, 0, (SELECT nif FROM person WHERE cc = NEW.patients_person_cc)) 
    RETURNING id_bill INTO new_bill_id;

    -- Set the billings_id_bill field of the new hospitalization
    NEW.billings_id_bill = new_bill_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--CREATE TRIGGER create_bill_trigger_hosp
--BEFORE INSERT ON hospitalizations
--FOR EACH ROW
--EXECUTE FUNCTION create_new_bill_surgery();

SELECT * FROM schedule_surgery(111111111, 131313131, ARRAY[ROW(115115115, 'nurse_role_1'), ROW(117117117, 'nurse_role_2')]::nurse_role[], '2024-04-17 11:37:00', 'test6', '2024-04-20', '2024-04-20', 3, 115115115);
--SELECT * FROM hospitalizations

