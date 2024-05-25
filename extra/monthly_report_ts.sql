SELECT month, name, total_surgeries
FROM
(
    SELECT
    TO_CHAR(date_trunc('month', surgery.surg_date), 'YYYY-MM') AS month,
    service_user.name,
    COUNT(*) AS total_surgeries,
    RANK() OVER (PARTITION BY TO_CHAR(date_trunc('month', surgery.surg_date), 'YYYY-MM') ORDER BY COUNT(*) DESC) as rank

    FROM surgery
    JOIN service_user ON service_user.user_id = surgery.doctor_employee_contract_service_user_user_id
    WHERE surgery.surg_date >= (NOW() - INTERVAL '1 year')
    GROUP BY TO_CHAR(date_trunc('month', surgery.surg_date), 'YYYY-MM'), service_user.name

)AS sub

WHERE rank = 1 ORDER BY month DESC;
