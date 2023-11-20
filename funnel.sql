SELECT question,
  COUNT(DISTINCT user_id) AS total_num_completed,
  LAG(COUNT(DISTINCT user_id),1,COUNT(DISTINCT user_id)) OVER (
    ORDER BY question) AS previous_num,
  CAST(COUNT(DISTINCT user_id) AS REAL) / LAG(COUNT(DISTINCT user_id),1,COUNT(DISTINCT user_id)) OVER (
    ORDER BY question) AS diff
FROM survey
GROUP BY 1;

SELECT quiz.user_id,
  home_try_on.user_id IS NOT NULL AS is_home_try_on,
  CAST(home_try_on.number_of_pairs AS INTEGER) AS number_of_pairs,
  purchase.user_id IS NOT NULL AS is_purchase
FROM quiz
LEFT JOIN home_try_on 
  ON quiz.user_id = home_try_on.user_id
LEFT JOIN purchase
  ON home_try_on.user_id = purchase.user_id
LIMIT 10;

WITH funnel AS (
  SELECT DISTINCT quiz.user_id,
    home_try_on.user_id IS NOT NULL AS is_home_try_on,
    (CAST(home_try_on.number_of_pairs AS INTEGER)) AS number_of_pairs,
    purchase.user_id IS NOT NULL AS is_purchase
  FROM quiz
  LEFT JOIN home_try_on 
    ON quiz.user_id = home_try_on.user_id
  LEFT JOIN purchase
    ON home_try_on.user_id = purchase.user_id)
SELECT number_of_pairs, SUM(is_home_try_on), SUM(is_purchase), CAST(SUM(is_purchase) AS REAL) / SUM(is_home_try_on) AS try_on_to_purchase 
FROM funnel
GROUP BY number_of_pairs
HAVING number_of_pairs IS NOT NULL;
