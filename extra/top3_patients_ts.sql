SELECT
    nome,
    total_payed,
    app_id,
    doctor_id,
    date

FROM (
    SELECT
        service_user.name AS nome,
        SUM(bill.already_paid) OVER (PARTITION BY service_user.name) AS total_payed,
        appointment.app_id AS app_id,
        appointment.doctor_employee_contract_service_user_user_id AS doctor_id,
        appointment.app_date AS date

    FROM
        service_user
        JOIN patient ON service_user.user_id = patient.service_user_user_id
        JOIN appointment ON patient.service_user_user_id = appointment.patient_service_user_user_id
        JOIN bill ON appointment.bill_bill_id = bill.bill_id
)sub

ORDER BY
    total_payed DESC,
    nome;
