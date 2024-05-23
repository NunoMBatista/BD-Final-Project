-- Define appointment bill trigger
CREATE OR REPLACE FUNCTION create_app_bill_trigger() 
RETURNS TRIGGER AS $$
BEGIN
    -- Insert a new bill with default values
    INSERT INTO bill (total_cost, already_payed) 
    VALUES (50, 0) RETURNING bill_id 
    INTO NEW.bill_bill_id;

    -- Update the appointment with the new bill id
    UPDATE appointment 
    SET bill_bill_id = NEW.bill_bill_id 
    WHERE app_id = NEW.app_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add the trigger to the appointment table
CREATE TRIGGER appointment_before_insert
BEFORE INSERT ON appointment
FOR EACH ROW
EXECUTE FUNCTION create_app_bill_trigger();



-- Define hospitalization bill trigger
CREATE OR REPLACE FUNCTION create_hosp_bill_trigger()
RETURNS TRIGGER AS $$
BEGIN
    -- Insert a new bill with default values
    -- Currently empty, as it will be updated by the surgery trigger
    INSERT INTO bill (total_cost, already_payed) 
    VALUES (0, 0) RETURNING bill_id 
    INTO NEW.bill_bill_id;

    -- Update the hospitalization with the new bill id
    UPDATE hospitalization 
    SET bill_bill_id = NEW.bill_bill_id 
    WHERE hosp_id = NEW.hosp_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add the trigger to the hospitalization table
CREATE TRIGGER hospitalization_before_insert
BEFORE INSERT ON hospitalization
FOR EACH ROW
EXECUTE FUNCTION create_hosp_bill_trigger();




-- Define surgery bill trigger
CREATE OR REPLACE FUNCTION update_surg_bill_trigger()
RETURNS TRIGGER AS $$
BEGIN
    -- Update associated bill with surgery cost
    UPDATE bill
    SET total_cost = total_cost + 100
    WHERE bill_id = (
        SELECT bill_bill_id
        FROM hospitalization
        WHERE hosp_id = NEW.hospitalization_hosp_id
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add the trigger to the surgery table
CREATE TRIGGER surgery_after_insert
AFTER INSERT ON surgery
FOR EACH ROW
EXECUTE FUNCTION update_surg_bill_trigger();



