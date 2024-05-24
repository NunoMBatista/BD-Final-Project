WITH months AS (
    SELECT generate_series(
        -- Get each month from 11 months ago to the current month
        date_trunc('month', CURRENT_DATE - INTERVAL '11 months'),
        date_trunc('month', CURRENT_DATE),
        '1 month'::interval -- Step by 1 month
    ) AS month
    ),
doctor_surgeries AS (
    SELECT 
        date_trunc('month', surg_date) AS month, -- Get the month of the surgery
        doctor_employee_contract_service_user_user_id AS doctor_id,  -- Get the doctor ID
        COUNT(*) AS surgery_count -- Count the number of surgeries
    FROM surgery
    GROUP BY month, doctor_id -- Aggregate by month and doctor
    )

SELECT 
    months.month, 
    service_user.name AS doctor_name,
    MAX(doctor_surgeries.surgery_count) AS surgery_count 
FROM months -- Get all months
LEFT JOIN doctor_surgeries ON months.month = doctor_surgeries.month -- Join the surgeries with the months 
LEFT JOIN service_user ON doctor_surgeries.doctor_id = service_user.user_id -- Join the doctor ID with the doctor name
GROUP BY months.month, service_user.name 
ORDER BY months.month;