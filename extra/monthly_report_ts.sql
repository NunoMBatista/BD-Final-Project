SELECT month, name, total_surgeries
FROM
(
    SELECT
    TO_CHAR(date_trunc('month', surgeries.data), 'YYYY-MM') AS month,
    person.name,
    COUNT(*) AS total_surgeries,
    RANK() OVER (PARTITION BY TO_CHAR(date_trunc('month', surgeries.data), 'YYYY-MM') ORDER BY COUNT(*) DESC) as rank

    FROM surgeries
    JOIN person ON person.cc = surgeries.doctors_employees_person_cc
    WHERE surgeries.data >= (NOW() - INTERVAL '1 year')
    GROUP BY TO_CHAR(date_trunc('month', surgeries.data), 'YYYY-MM'), person.name

)AS sub

WHERE rank = 1 ORDER BY month DESC;
