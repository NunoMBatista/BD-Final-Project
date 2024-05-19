SELECT COUNT(DISTINCT id_sur) AS NUM_SURGERIES, COUNT (DISTINCT prescriptions_id_pres) AS NUM_PRESCRIPTIONS, SUM(payed)
FROM
    hospitalizations
    JOIN billings ON hospitalizations.billings_id_bill = billings.id_bill
    JOIN surgeries ON hospitalizations.id_hos = surgeries.hospitalizations_id_hos
    JOIN prescriptions_hospitalizations ON hospitalizations.id_hos = prescriptions_hospitalizations.hospitalizations_id_hos
WHERE
    hospitalizations.date_begin = '2024-04-16'
