WITH months AS (
    SELECT generate_series(
        date_trunc('month', CURRENT_DATE - INTERVAL '11 months'),
        date_trunc('month', CURRENT_DATE),
        '1 month'::interval
    ) AS month
),
doctor_surgeries AS (
    SELECT 
        date_trunc('month', surg_date) AS month,
        doctor_employee_contract_service_user_user_id AS doctor_id,
        COUNT(*) AS surgery_count
    FROM surgery
    GROUP BY month, doctor_id
)
SELECT 
    months.month,
    service_user.name AS doctor_name,
    MAX(doctor_surgeries.surgery_count) AS surgery_count
FROM months
LEFT JOIN doctor_surgeries ON months.month = doctor_surgeries.month
LEFT JOIN service_user ON doctor_surgeries.doctor_id = service_user.user_id
GROUP BY months.month, service_user.name
ORDER BY months.month;