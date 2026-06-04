-- 08_deals_em_risco.sql
-- Deals em aberto parados há mais de 30 dias sem atualização.
-- Técnicas: DATEDIFF, CASE WHEN, subquery, ORDER BY

WITH deals_abertos AS (
    SELECT
        deal_id,
        nome_empresa,
        pipeline,
        etapa,
        vendedor_nome,
        data_criacao,
        ultima_atualizacao,
        DATEDIFF('day',
            ultima_atualizacao,
            CURRENT_DATE
        )                                       AS dias_parado
    FROM deals
    WHERE etapa NOT LIKE 'Ganho%'
      AND etapa != 'Perdido'
)

SELECT
    deal_id,
    nome_empresa,
    pipeline,
    etapa,
    vendedor_nome,
    ultima_atualizacao,
    dias_parado,
    CASE
        WHEN dias_parado >= 60 THEN 'Crítico'
        WHEN dias_parado >= 30 THEN 'Em risco'
        ELSE                       'Saudável'
    END                                         AS status_risco
FROM deals_abertos
ORDER BY dias_parado DESC;