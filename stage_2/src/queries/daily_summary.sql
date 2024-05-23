WITH payments_sum AS (
    SELECT SUM(amount) AS amount_spent
    FROM payment
    WHERE TO_DATE(payment_date::text, 'YYYY-MM-DD') = TO_DATE(%s, 'YYYY-MM-DD')
    ),
    surgeries_count AS (
        SELECT COUNT(*) AS surgeries
        FROM surgery
        WHERE TO_DATE(surg_date::text, 'YYYY-MM-DD') = TO_DATE(%s, 'YYYY-MM-DD')
    ),
    prescriptions_count AS (
        SELECT COUNT(*) AS prescriptions
        FROM prescription
        WHERE validity = TO_DATE(%s, 'YYYY-MM-DD')
    )
SELECT 
    COALESCE((SELECT amount_spent FROM payments_sum), 0) AS amount_spent,
    COALESCE((SELECT surgeries FROM surgeries_count), 0) AS surgeries,
    COALESCE((SELECT prescriptions FROM prescriptions_count), 0) AS prescriptions;