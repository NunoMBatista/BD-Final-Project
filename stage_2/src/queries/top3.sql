WITH top_patients AS (
    SELECT patient_service_user_user_id AS patient_id, SUM(amount) AS total_paid
    FROM payment
    JOIN bill ON payment.bill_bill_id = bill.bill_id
    JOIN (
        SELECT bill_bill_id, patient_service_user_user_id FROM appointment
        UNION ALL
        SELECT bill_bill_id, patient_service_user_user_id FROM hospitalization
    ) AS bill_user ON bill.bill_id = bill_user.bill_bill_id
    GROUP BY patient_service_user_user_id
    ORDER BY total_paid DESC
    LIMIT 3
)

SELECT su.name, tp.total_paid, 
       array_agg(json_build_object('procedure_id', COALESCE(a.app_id, h.hosp_id), 
                                   'doctor_id', COALESCE(a.doctor_employee_contract_service_user_user_id, h.nurse_employee_contract_service_user_user_id), 
                                   'date', COALESCE(a.app_date, h.start_date))) AS procedures
FROM top_patients tp
JOIN patient p ON tp.patient_id = p.service_user_user_id
JOIN service_user su ON p.service_user_user_id = su.user_id
LEFT JOIN appointment a ON tp.patient_id = a.patient_service_user_user_id
LEFT JOIN hospitalization h ON tp.patient_id = h.patient_service_user_user_id
GROUP BY su.name, tp.total_paid
ORDER BY tp.total_paid DESC;