CREATE OR REPLACE FUNCTION create_bill_trigger() 
RETURNS TRIGGER AS $$
BEGIN
    -- Insert a new bill with default values
    INSERT INTO bill (cost, is_payed) 
    VALUES (50, FALSE) RETURNING bill_id 
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
EXECUTE FUNCTION create_bill_trigger();