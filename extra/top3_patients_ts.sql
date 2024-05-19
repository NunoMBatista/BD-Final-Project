SELECT
    nome,
    total_payed,
    app_id,
    doctor_id,
    date

FROM (
    SELECT
        person.name AS nome,
        SUM(billings.payed) OVER (PARTITION BY person.name) AS total_payed,
        appointments.id_app AS app_id,
        appointments.doctors_employees_person_cc AS doctor_id,
        appointments.data AS date

    FROM
        person
        JOIN patients ON person.cc = patients.person_cc
        JOIN appointments ON patients.person_cc = appointments.patients_person_cc
        JOIN billings ON appointments.billings_id_bill = billings.id_bill
)sub

ORDER BY
    total_payed DESC,
    nome;
