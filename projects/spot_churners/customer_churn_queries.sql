WITH get_Satisfaction AS (
	SELECT
		customer_id,
        customer_status,
        churn_score,
        churn_category,
        satisfaction_score,
        churn_label
	FROM 
		status_analysis
),
get_Relationships AS (
	SELECT
		customer_id,
        married
	FROM
		customer_info
),
does_relationship_affects AS (
	SELECT 
		gr.married,
        gs.customer_id,
        gs.customer_status,
        gs.churn_score,
        gs.satisfaction_score,
        gs.churn_label
	FROM
		get_Relationships as gr
	JOIN
		get_Satisfaction AS gs ON
		gr.customer_id = gs.customer_id
	WHERE gr.married = "Yes"
)
SELECT 	
	SUM(CASE WHEN churn_label = "Yes" THEN 1 ELSE 0 END) AS how_many_left 
FROM
	does_relationship_affects;
-- window function p/ encontrar qual o mais selecionado, rank, das razões
	
SELECT
	churn_reason,
    COUNT(churn_reason) AS number_of_complaints,
    RANK() OVER (ORDER BY COUNT(churn_reason) DESC) AS ranking
FROM 
	status_analysis
WHERE
	churn_reason <> 'N/A'
GROUP BY
	churn_reason
ORDER BY
	number_of_complaints DESC;

WITH churns AS (
	SELECT
		customer_id, 
        AVG(churn_score) AS bellow_avg_churn,
        AVG(satisfaction_score) AS above_average_satisfaction
	FROM 
		status_analysis
	WHERE
		churn_score > (SELECT AVG(churn_score) FROM status_analysis) AND
        satisfaction_score < (SELECT AVG(satisfaction_score) FROM status_analysis) 
	GROUP BY 
		customer_id
	ORDER BY 
		bellow_avg_churn DESC
)
SELECT * from churns;

-- CREATE VIEW does_high_monthly_charges_increase_churn AS
WITH high_monthly_charges AS (
	SELECT
		ROUND(AVG(monthly_charges), 2) AS above_monthly_charges,
        customer_id
	FROM 
		payment_info
	WHERE 
		monthly_charges > (SELECT AVG(monthly_charges) FROM payment_info)
	GROUP BY 
		customer_id
),
satisfaction AS (
	SELECT
		customer_id,
        ROUND(AVG(satisfaction_score), 2) AS avg_satisfaction_score,
        ROUND(AVG(churn_score), 2) AS avg_churn_score 
	FROM
		status_analysis
	GROUP BY
		customer_id
),
get_info AS (
	SELECT
		above_monthly_charges,
        avg_satisfaction_score,
        avg_churn_score
	FROM
		satisfaction AS s
	JOIN 
		high_monthly_charges AS h ON h.customer_id = s.customer_id
)
SELECT * FROM get_info ORDER BY above_monthly_charges DESC;

-- CREATE VIEW range_of_total_charges AS
WITH range_of_charges AS (
	SELECT
		customer_id,
        CASE 
			WHEN total_charges < 100 THEN '0-100'
            WHEN total_charges BETWEEN 100 AND 500 THEN '100-500'
            WHEN total_charges BETWEEN 500 AND 1000 THEN '500-1000'
            WHEN total_charges BETWEEN 1000 AND 2000 THEN '1000-2000'
            WHEN total_charges BETWEEN 2000 AND 5000 THEN '2000-5000'
			WHEN total_charges BETWEEN 5000 AND 10000 THEN '5000-10000'
            ELSE '10000+'
		END AS
			range_of_total_charges
	FROM
		payment_info
),
 get_customers_info AS (
	SELECT
		customer_id,
		ROUND(AVG(satisfaction_score), 2) AS avg_satisfaction_score,
		ROUND(AVG(churn_score), 2) AS avg_churn_score 
	FROM	
		status_analysis
	GROUP BY
		customer_id
),
join_infos AS (
	SELECT
		r.range_of_total_charges,
        g.avg_satisfaction_score,
        g.avg_churn_score
	FROM
		range_of_charges AS r
	JOIN	
		get_customers_info AS g ON r.customer_id = g.customer_id
)
SELECT * FROM join_infos ORDER BY avg_satisfaction_score, avg_churn_score DESC;

-- CREATE VIEW range_of_monthly_charges AS
WITH range_of_monthly_charges AS (
	SELECT
		customer_id,
        CASE 
			WHEN monthly_charges < 20 THEN '0-20'
            WHEN monthly_charges BETWEEN 20 AND 40 THEN '20-40'
            WHEN monthly_charges BETWEEN 40 AND 80 THEN '40-80'
            ELSE '80+'
		END AS
			monthly_total_charges
	FROM
		payment_info
),
 get_customers_info AS (
	SELECT
		customer_id,
		ROUND(AVG(satisfaction_score), 2) AS avg_satisfaction_score,
		ROUND(AVG(churn_score), 2) AS avg_churn_score 
	FROM	
		status_analysis
	GROUP BY
		customer_id
),
join_infos AS (
	SELECT
		r.monthly_total_charges,
        g.avg_satisfaction_score,
        g.avg_churn_score
	FROM
		range_of_monthly_charges AS r
	JOIN	
		get_customers_info AS g ON r.customer_id = g.customer_id
)
SELECT * FROM join_infos ORDER BY avg_satisfaction_score, avg_churn_score DESC;

-- CREATE VIEW does_extra_charges_increase_churn_score AS 
WITH does_long_distance_charges_increase_churn_score AS (
	SELECT
		customer_id,
        CASE 
			WHEN total_long_distance_charges < 50 THEN '0-50'
            WHEN total_long_distance_charges BETWEEN 50 AND 100 THEN '50-100'
            WHEN total_long_distance_charges BETWEEN 100 AND 200 THEN '100-200'
            WHEN total_long_distance_charges BETWEEN 200 AND 500 THEN '200-500'
            WHEN total_long_distance_charges BETWEEN 500 AND 1000 THEN '500-1000'
            WHEN total_long_distance_charges BETWEEN 1000 AND 2000 THEN '1000-2000'
            ELSE '2000+'
		END AS range_total_distance,
        CASE 
			WHEN total_extra_data_charges < 10 THEN '0-10'
            WHEN total_extra_data_charges BETWEEN 10 AND 50 THEN '10-50'
            WHEN total_extra_data_charges BETWEEN 50 AND 100 THEN '50-100'
            WHEN total_extra_data_charges BETWEEN 100 AND 150 THEN '100-150'
            ELSE '150+'
		END AS range_extra_data
	FROM 
		payment_info
),
get_customer AS (
	SELECT
		customer_id,
        ROUND(AVG(satisfaction_score), 2) AS avg_satisfaction_score,
		ROUND(AVG(churn_score), 2) AS avg_churn_score 
	FROM
		status_analysis
	GROUP BY
		customer_id
),
join_infos AS (
	SELECT
		d.range_total_distance,
        d.range_extra_data,
        g.avg_satisfaction_score,
        g.avg_churn_score 
	FROM 
		get_customer AS g
	JOIN 
		does_long_distance_charges_increase_churn_score AS d ON g.customer_id = d.customer_id
)
SELECT * FROM join_infos ORDER BY avg_satisfaction_score, avg_churn_score;

-- CREATE VIEW how_many_left_depending_on_location AS 
WITH how_many_left_depending_on_location AS (
	SELECT
		customer_id,
		churn_value,
        ROUND(AVG(satisfaction_score), 2) as avg_satisfaction_score,
        ROUND(AVG(churn_score), 2) AS avg_churn_score
	FROM
		status_analysis
	GROUP BY 
		customer_id, churn_value
),
get_location AS (
	SELECT DISTINCT
		customer_id,
        latitude, 
        longitude
	FROM 
		location_data
),
get_info AS (
	SELECT
		h.churn_value,
        h.avg_satisfaction_score,
		h.avg_churn_score,
        g.latitude,
        g.longitude
	FROM
		how_many_left_depending_on_location AS h 
	JOIN 
		get_location as g ON g.customer_id = h.customer_id
)
SELECT * FROM get_info;

-- CREATE VIEW having_cellphone_service AS 	
WITH having_cellphone_service AS (
	SELECT
		customer_id,
        phone_service
	FROM
		service_options
	WHERE 
		phone_service = 'Yes'
),
get_customers AS (
	SELECT
        customer_id,
		churn_value,
        ROUND(AVG(satisfaction_score), 2) as avg_satisfaction_score,
        ROUND(AVG(churn_score), 2) AS avg_churn_score
	FROM 
		status_analysis
	GROUP BY
		customer_id, churn_value
),
get_infos AS (
	SELECT
		phone_service,
        churn_value,
        avg_satisfaction_score,
        avg_churn_score
	FROM 
		get_customers AS g
	JOIN 
		having_cellphone_service as h ON g.customer_id = h.customer_id
)
SELECT * FROM get_infos ORDER BY avg_satisfaction_score, avg_churn_score;

-- CREATE VIEW not_having_cellphone_service AS 
WITH not_having_cellphone_service AS (
	SELECT
		customer_id,
        phone_service
	FROM
		service_options
	WHERE 
		phone_service = 'No'
),
get_customers AS (
	SELECT
        customer_id,
		churn_value,
        ROUND(AVG(satisfaction_score), 2) as avg_satisfaction_score,
        ROUND(AVG(churn_score), 2) AS avg_churn_score
	FROM 
		status_analysis
	GROUP BY
		customer_id, churn_value
),
get_infos AS (
	SELECT
		phone_service,
        churn_value,
        avg_satisfaction_score,
        avg_churn_score
	FROM 
		get_customers AS g
	JOIN 
		not_having_cellphone_service as h ON g.customer_id = h.customer_id
)
SELECT * FROM get_infos ORDER BY avg_satisfaction_score, avg_churn_score;

-- CREATE VIEW correlation_between_monthlycharges_and_churnscore AS
WITH global_averages AS (
	SELECT
		AVG(monthly_charges) AS avg_monthly_charges,
        AVG(churn_score) AS avg_churn_score
	FROM
		payment_info, status_analysis -- nem sabia que podia fazer isso
),
variance_x AS (
	SELECT
		customer_id,
		monthly_charges - (SELECT avg_monthly_charges FROM global_averages) x_minus_avg,
        POWER(monthly_charges - (SELECT avg_monthly_charges FROM global_averages), 2) AS x_square_minus_avg
	FROM
		payment_info 
),
variance_y AS (
	SELECT
		customer_id,
		churn_score - (SELECT avg_churn_score FROM global_averages) AS y_minus_avg,
        POWER(churn_score - (SELECT avg_churn_score FROM global_averages), 2) AS y_square_minus_avg
	FROM
		status_analysis
),
get_correlation AS (
	SELECT
        SUM(x_square_minus_avg) AS variance_of_x,
        SUM(y_square_minus_avg) AS variance_of_y,
        SUM(x.x_minus_avg * y.y_minus_avg) AS numerator
	FROM	
		variance_x AS x
	JOIN
		variance_y AS y ON x.customer_id = y.customer_id 
)
SELECT numerator/sqrt(variance_of_x * variance_of_y) AS correlation FROM get_correlation;

-- CREATE VIEW correlation_between_total_charges_and_satisfaction_score AS
WITH global_averages AS (
	SELECT
		AVG(total_charges) AS avg_total_charges,
        AVG(satisfaction_score) AS avg_satisfaction_score
	FROM
		payment_info, status_analysis
),
variance_x AS (
	SELECT
		customer_id,
        total_charges - (SELECT avg_total_charges FROM global_averages) AS x_minus_avg,
        POWER(total_charges - (SELECT avg_total_charges FROM global_averages), 2) AS x_minus_avg_squared
	FROM	
		payment_info
),
variance_y AS (
	SELECT
		customer_id,
        satisfaction_score - (SELECT avg_satisfaction_score FROM global_averages) AS y_minus_avg,
        POWER(satisfaction_score - (SELECT avg_satisfaction_score FROM global_averages), 2) as y_minus_avg_squared
	FROM
		status_analysis
),
correlation_x_and_y AS (
	SELECT
		SUM(x.x_minus_avg * y.y_minus_avg) AS numerator,
        SUM(x.x_minus_avg_squared) AS variance_of_x,
        SUM(y.y_minus_avg_squared) AS variance_of_y
	FROM
		variance_x AS x
	JOIN
		variance_y AS y ON x.customer_id = y.customer_id
)
SELECT 
	numerator/sqrt(variance_of_x*variance_of_y) AS correlation
FROM
	correlation_x_and_y;
-- CREATE VIEW correlation_high_total_charges AS
WITH global_averages AS (
	SELECT
		AVG(total_charges) AS avg_total_charges,
        AVG(satisfaction_score) AS avg_satisfaction_score
	FROM
		payment_info, status_analysis
),
variance_x AS (
	SELECT
		customer_id,
        (total_charges - (SELECT avg_total_charges FROM global_averages)) AS high_x_minus_avg,
        POWER(total_charges - (SELECT avg_total_charges FROM global_averages), 2) AS high_x_minus_avg_squared
	FROM	
		payment_info
	WHERE 
		total_charges > (SELECT avg_total_charges FROM global_averages)
),
variance_y AS (
	SELECT
		customer_id,
        (satisfaction_score  - (SELECT avg_satisfaction_score FROM global_averages)) AS high_y_minus_avg,
        POWER(satisfaction_score - (SELECT avg_satisfaction_score FROM global_averages), 2) AS high_y_minus_avg_squared
	FROM
		status_analysis
	WHERE	
		satisfaction_score > (SELECT avg_satisfaction_score FROM global_averages)
),
correlation_x_and_y AS (
	SELECT
		SUM(x.high_x_minus_avg * y.high_y_minus_avg) AS numerator,
        SUM(x.high_x_minus_avg_squared) AS variance_of_x,
        SUM(y.high_y_minus_avg_squared) AS variance_of_y
	FROM
		variance_x AS x
	JOIN
		variance_y AS y ON x.customer_id = y.customer_id
)
SELECT 
	numerator/sqrt(variance_of_x*variance_of_y) AS correlation
FROM
	correlation_x_and_y;
-- CREATE VIEW correlation_high_monthly_charges_churn_score AS	
WITH global_averages AS (
    SELECT
        AVG(monthly_charges) AS avg_monthly_charges,
        AVG(churn_score) AS avg_churn_score
    FROM
        payment_info, status_analysis
),
variance_x AS (
    SELECT
        customer_id,
        monthly_charges - (SELECT avg_monthly_charges FROM global_averages) AS high_x_minus_avg,
        POWER(monthly_charges - (SELECT avg_monthly_charges FROM global_averages), 2) AS high_x_square_minus_avg
    FROM
        payment_info
    WHERE
        monthly_charges > (SELECT avg_monthly_charges FROM global_averages)
),
variance_y AS (
    SELECT
        customer_id,
        churn_score - (SELECT avg_churn_score FROM global_averages) AS high_y_minus_avg,
        POWER(churn_score - (SELECT avg_churn_score FROM global_averages), 2) AS high_y_square_minus_avg
    FROM
        status_analysis
    WHERE
        churn_score > (SELECT avg_churn_score FROM global_averages)
),
get_correlation AS (
    SELECT
        SUM(x.high_x_square_minus_avg) AS variance_of_x,
        SUM(y.high_y_square_minus_avg) AS variance_of_y,
        SUM(x.high_x_minus_avg * y.high_y_minus_avg) AS numerator
    FROM
        variance_x AS x
    JOIN
        variance_y AS y ON x.customer_id = y.customer_id
)
SELECT 
    numerator/SQRT(variance_of_x * variance_of_y) AS correlation
FROM
    get_correlation;

-- CREATE VIEW does_referrals_effect_on_churn_and_satisfaction AS
WITH referrals_data AS (
	SELECT
		customer_id,
		number_of_referrals
	FROM
		service_options
),
customer_churn_and_satisfaction AS (
	SELECT
		customer_id,
		ROUND(AVG(satisfaction_score), 2) AS avg_satisfaction_score,
		SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) * 1.0 / COUNT(churn_label) AS churn_rate
	FROM
		status_analysis
	GROUP BY
		customer_id
),
referrals_analysis AS (
	SELECT
		r.number_of_referrals,
		ROUND(AVG(c.avg_satisfaction_score), 2) AS avg_satisfaction_score,
		ROUND(AVG(c.churn_rate), 2) AS avg_churn_rate
	FROM
		referrals_data AS r
	JOIN
		customer_churn_and_satisfaction AS c ON r.customer_id = c.customer_id
	GROUP BY
		r.number_of_referrals
)
SELECT
	number_of_referrals,
	avg_satisfaction_score,
	avg_churn_rate
FROM
	referrals_analysis
ORDER BY
	number_of_referrals DESC;
-- CREATE VIEW correlation_satisfaction_and_referrals AS
WITH global_avg_satisfaction AS (
	SELECT
		AVG(satisfaction_score) AS avg_satisfaction 
	FROM
		status_analysis
),
get_avg_number_of_referrals AS (
	SELECT
		AVG(number_of_referrals) AS avg_referrals
	FROM
		service_options
),
variance_x AS (
	SELECT
		customer_id,
        (satisfaction_score - (SELECT avg_satisfaction FROM global_avg_satisfaction)) AS x_minus_avg,
        POWER(satisfaction_score - (SELECT avg_satisfaction FROM global_avg_satisfaction), 2) AS squared_x_minus_avg
	FROM
		status_analysis
),
variance_y AS (
	SELECT
		customer_id,
		(number_of_referrals - (SELECT avg_referrals FROM get_avg_number_of_referrals)) AS y_minus_avg,
        POWER(number_of_referrals - (SELECT avg_referrals FROM get_avg_number_of_referrals), 2) AS squared_y_minus_avg
	FROM
		service_options
),
get_correlation AS (
	SELECT
		SUM(x.x_minus_avg*y.y_minus_avg) AS numerator,
        SUM(x.squared_x_minus_avg) AS x_squared,
        SUM(y.squared_y_minus_avg) AS y_squared
	FROM
		variance_x AS x
	JOIN variance_y AS y ON x.customer_id = y.customer_id
)
SELECT 
	numerator/sqrt(x_squared*y_squared) AS correlation
FROM
	get_correlation;
-- CREATE VIEW correlation_between_churn_score_and_referrals AS 
WITH global_avg_churn AS (
	SELECT
		AVG(churn_score) AS avg_churn_score 
	FROM
		status_analysis
),
get_avg_number_of_referrals AS (
	SELECT
		AVG(number_of_referrals) AS avg_referrals
	FROM
		service_options
),
variance_x AS (
	SELECT
		customer_id,
        (churn_score - (SELECT avg_churn_score FROM global_avg_churn)) AS x_minus_avg,
        POWER(churn_score - (SELECT avg_churn_score FROM global_avg_churn), 2) AS squared_x_minus_avg
	FROM
		status_analysis
),
variance_y AS (
	SELECT
		customer_id,
		(number_of_referrals - (SELECT avg_referrals FROM get_avg_number_of_referrals)) AS y_minus_avg,
        POWER(number_of_referrals - (SELECT avg_referrals FROM get_avg_number_of_referrals), 2) AS squared_y_minus_avg
	FROM
		service_options
),
get_correlation AS (
	SELECT
		SUM(x.x_minus_avg*y.y_minus_avg) AS numerator,
        SUM(x.squared_x_minus_avg) AS x_squared,
        SUM(y.squared_y_minus_avg) AS y_squared
	FROM
		variance_x AS x
	JOIN variance_y AS y ON x.customer_id = y.customer_id
)
SELECT 
	numerator/sqrt(x_squared*y_squared) AS correlation
FROM
	get_correlation;
-- CREATE VIEW what_about_the_downloads AS
WITH high_monthly_GB_download AS (
	SELECT
		customer_id,
		avg_monthly_gb_download AS high_amount_of_downloads
	FROM
		service_options
	WHERE
		avg_monthly_gb_download > (SELECT AVG(avg_monthly_gb_download) FROM service_options)
),
get_satisfaction_score AS (
	SELECT
		customer_id,
        satisfaction_score
	FROM
		status_analysis
),
get_payment AS (
	SELECT
		customer_id,
        total_extra_data_charges,
        total_charges
	FROM
		payment_info
),
join_infos AS (
	SELECT
		h.high_amount_of_downloads AS high_amount_of_data,
        gp.total_charges AS charges,
        gs.satisfaction_score AS satisfaction_score
	FROM
		high_monthly_GB_download AS h
	JOIN
		get_satisfaction_score AS gs ON h.customer_id = gs.customer_id
	JOIN
		get_payment AS gp ON h.customer_id = gp.customer_id
)
SELECT 
	high_amount_of_data, charges, satisfaction_score
FROM
	join_infos
ORDER BY 
	satisfaction_score ASC, high_amount_of_data DESC;
-- CREATE VIEW ranking_of_offers AS
SELECT
	offer,
    COUNT(offer) AS amount_of_offers,
    DENSE_RANK() OVER (ORDER BY COUNT(offer) DESC) AS ranking_of_offers,
    SUM(offer) AS total_offers
FROM
	service_options
GROUP BY
	offer;
-- CREATE VIEW most_lucrative_offers AS 
SELECT
    s.offer,
    SUM(p.total_charges) AS total_charges
FROM
	service_options AS s
JOIN
	payment_info AS p ON p.customer_id = s.customer_id
GROUP BY
	s.offer
ORDER BY
	total_charges ASC;
    
-- CREATE VIEW having_services AS 
WITH get_services AS (
	SELECT
		customer_id,
        phone_service,
        internet_service,
        online_security,
        online_backup,
        device_protection,
        premium_tech_support
	FROM
		online_services
	WHERE
        internet_service = 'Yes' AND
        online_security = 'Yes' AND 
        online_backup = 'Yes' AND 
        device_protection = 'Yes' 
),
get_satisfaction_churn_score AS (
	SELECT
		customer_id,
        satisfaction_score,
        churn_score
	FROM
		status_analysis
),
join_infos AS (
	SELECT
		ROUND(AVG(satisfaction_score), 2) AS avg_satisfaction_score,
        ROUND(AVG(churn_score), 2) AS avg_churn_score,
        s.internet_service,
        s.online_security,
        s.online_backup,
        s.device_protection
	FROM
		get_services AS s
	JOIN
		get_satisfaction_churn_score AS gs ON s.customer_id = gs.customer_id
	GROUP BY
        s.internet_service,
        s.online_security,
        s.online_backup,
        s.device_protection
    ORDER BY
		avg_satisfaction_score,
        avg_churn_score
        DESC
)
SELECT * FROM join_infos;

-- CREATE VIEW not_having_services AS 
WITH get_services AS (
	SELECT
		customer_id,
        internet_service,
        online_security,
        online_backup,
        device_protection
	FROM
		online_services
	WHERE
        internet_service = 'No' AND
        online_security = 'No' AND 
        online_backup = 'No' AND 
        device_protection = 'No' 
),
get_satisfaction_churn_score AS (
	SELECT
		customer_id,
        satisfaction_score,
        churn_score
	FROM
		status_analysis
),
join_infos AS (
	SELECT
		ROUND(AVG(satisfaction_score), 2) AS avg_satisfaction_score,
        ROUND(AVG(churn_score), 2) AS avg_churn_score,
        s.internet_service,
        s.online_security,
        s.online_backup,
        s.device_protection
	FROM
		get_services AS s
	JOIN
		get_satisfaction_churn_score AS gs ON s.customer_id = gs.customer_id
	GROUP BY
        s.internet_service,
        s.online_security,
        s.online_backup,
        s.device_protection
    ORDER BY
		avg_satisfaction_score,
        avg_churn_score
        DESC
)
SELECT * FROM join_infos;

-- let's explore about the services offered

-- CREATE VIEW phone_services_charges AS 
WITH get_phone_service AS (
	SELECT
		customer_id,
        phone_service
	FROM
		online_services
),
get_payments AS (
	SELECT
		customer_id,
        total_charges,
        monthly_charges
	FROM
		payment_info
),
join_infos AS (
	SELECT
        FORMAT(AVG(gp.total_charges), 2) AS avg_total_charges,
        FORMAT(AVG(gp.monthly_charges), 2) AS avg_monthly_charges,
        gs.phone_service
	FROM
		get_phone_service AS gs
	JOIN get_payments AS gp ON gs.customer_id = gp.customer_id
	GROUP BY 
		gs.phone_service
)
SELECT * FROM join_infos;
-- CREATE VIEW online_sercurity_service_charges AS
WITH get_online_security AS (
    SELECT
        customer_id,
        online_security
    FROM
        online_services
),
get_payments AS (
    SELECT
        customer_id,
        total_charges,
        monthly_charges
    FROM
        payment_info
),
join_infos AS (
    SELECT
        FORMAT(AVG(gp.total_charges), 2) AS avg_total_charges,
        FORMAT(AVG(gp.monthly_charges), 2) AS avg_monthly_charges,
        gs.online_security
    FROM
        get_online_security AS gs
    JOIN get_payments AS gp ON gs.customer_id = gp.customer_id
    GROUP BY 
        gs.online_security
)
SELECT * FROM join_infos;
-- CREATE VIEW online_backup_service_charges AS
WITH get_online_backup AS (
    SELECT
        customer_id,
        online_backup
    FROM
        online_services
),
get_payments AS (
    SELECT
        customer_id,
        total_charges,
        monthly_charges
    FROM
        payment_info
),
join_infos AS (
    SELECT
        FORMAT(AVG(gp.total_charges), 2) AS avg_total_charges,
        FORMAT(AVG(gp.monthly_charges), 2) AS avg_monthly_charges,
        gs.online_backup
    FROM
        get_online_backup AS gs
    JOIN get_payments AS gp ON gs.customer_id = gp.customer_id
    GROUP BY 
        gs.online_backup
)
SELECT * FROM join_infos;

-- CREATE VIEW device_protection_services_charges AS
WITH get_device_protection AS (
    SELECT
        customer_id,
        device_protection
    FROM
        online_services
),
get_payments AS (
    SELECT
        customer_id,
        total_charges,
        monthly_charges
    FROM
        payment_info
),
join_infos AS (
    SELECT
        FORMAT(AVG(gp.total_charges), 2) AS avg_total_charges,
        FORMAT(AVG(gp.monthly_charges), 2) AS avg_monthly_charges,
        gs.device_protection
    FROM
        get_device_protection AS gs
    JOIN get_payments AS gp ON gs.customer_id = gp.customer_id
    GROUP BY 
        gs.device_protection
)
SELECT * FROM join_infos;

-- CREATE VIEW premium_tech_support_services AS
WITH get_premium_tech_support AS (
    SELECT
        customer_id,
        premium_tech_support
    FROM
        online_services
),
get_payments AS (
    SELECT
        customer_id,
        total_charges,
        monthly_charges
    FROM
        payment_info
),
join_infos AS (
    SELECT
        FORMAT(AVG(gp.total_charges), 2) AS avg_total_charges,
        FORMAT(AVG(gp.monthly_charges), 2) AS avg_monthly_charges,
        gs.premium_tech_support
    FROM
        get_premium_tech_support AS gs
    JOIN get_payments AS gp ON gs.customer_id = gp.customer_id
    GROUP BY 
        gs.premium_tech_support
)
SELECT * FROM join_infos;

-- CREATE VIEW internet_type_services_charges AS
WITH get_internet_type AS (
    SELECT
        customer_id,
        internet_type
    FROM
        online_services
),
get_payments AS (
    SELECT
        customer_id,
        total_charges,
        monthly_charges
    FROM
        payment_info
),
join_infos AS (
    SELECT
        FORMAT(AVG(gp.total_charges), 2) AS avg_total_charges,
        FORMAT(AVG(gp.monthly_charges), 2) AS avg_monthly_charges,
        gs.internet_type
    FROM
        get_internet_type AS gs
    JOIN get_payments AS gp ON gs.customer_id = gp.customer_id
    GROUP BY 
        gs.internet_type
)
SELECT * FROM join_infos;

-- CREATE VIEW internet_services_charges AS
WITH get_internet_service AS (
    SELECT
        customer_id,
        internet_service
    FROM
        online_services
),
get_payments AS (
    SELECT
        customer_id,
        total_charges,
        monthly_charges
    FROM
        payment_info
),
join_infos AS (
    SELECT
        FORMAT(AVG(gp.total_charges), 2) AS avg_total_charges,
        FORMAT(AVG(gp.monthly_charges), 2) AS avg_monthly_charges,
        gs.internet_service
    FROM
        get_internet_service AS gs
    JOIN get_payments AS gp ON gs.customer_id = gp.customer_id
    GROUP BY 
        gs.internet_service
)
SELECT * FROM join_infos;

-- CREATE VIEW phone_services_chosen_or_not AS
WITH get_services AS (
	SELECT
        phone_service,
        COUNT(phone_service) AS phone_service_chosen_or_not
	FROM
		online_services
	GROUP BY
		phone_service
)
SELECT * FROM get_services;

-- CREATE VIEW online_security_chosen_or_not AS
WITH get_services AS (
    SELECT
        online_security,
        COUNT(online_security) AS online_security_chosen_or_not
    FROM
        online_services
    GROUP BY
        online_security
)
SELECT * FROM get_services;
-- CREATE VIEW online_backup_chosen_or_not AS
WITH get_services AS (
    SELECT
        online_backup,
        COUNT(online_backup) AS online_backup_chosen_or_not
    FROM
        online_services
    GROUP BY
        online_backup
)
SELECT * FROM get_services;

-- CREATE VIEW device_protection_chosen_or_not AS
WITH get_services AS (
    SELECT
        device_protection,
        COUNT(device_protection) AS device_protection_chosen_or_not
    FROM
        online_services
    GROUP BY
        device_protection
)
SELECT * FROM get_services;

-- CREATE VIEW premium_tech_support_chosen_or_not AS 
WITH get_services AS (
    SELECT
        premium_tech_support,
        COUNT(premium_tech_support) AS premium_tech_support_chosen_or_not
    FROM
        online_services
    GROUP BY
        premium_tech_support
)
SELECT * FROM get_services;

-- CREATE VIEW internet_services_chosen_or_not AS
WITH get_services AS (
    SELECT
        internet_service,
        COUNT(internet_service) AS internet_services_chosen_or_not
    FROM
        online_services
    GROUP BY
        internet_service
)
SELECT * FROM get_services;

-- CREATE VIEW ranking_of_offers_plus_percentage AS
WITH get_ranking_offers AS (
	SELECT
		offer,
		COUNT(offer) AS amount_of_offers,
        ROW_NUMBER() OVER (ORDER BY count(offer) DESC) AS ranking
	FROM
		service_options
	GROUP BY
		offer
)
SELECT 
	offer,
    amount_of_offers,
    (amount_of_offers/7043) AS percentage_of_offers,
    ranking
FROM
	get_ranking_offers




    
	

    

		





		