-- 03_rolling_avg_receita.sql
-- Média móvel de receita dos últimos 3 meses por pipeline.
-- Técnicas: AVG() OVER (ROWS BETWEEN), CTE encadeada

WITH receita_mensal AS (
    SELECT
        STRFTIME(data_criacao, '%Y-%m')   AS mes,
        pipeline,
        ROUND(SUM(receita_total), 2)      AS receita_mes
    FROM deals
    WHERE etapa LIKE 'Ganho%'
    GROUP BY mes, pipeline
)

SELECT
    mes,
    pipeline,
    receita_mes,
    ROUND(
        AVG(receita_mes) OVER (
            PARTITION BY pipeline
            ORDER BY mes
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ), 2
    ) AS media_movel_3m
FROM receita_mensal
ORDER BY pipeline, mes;