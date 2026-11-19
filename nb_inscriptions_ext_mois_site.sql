--metadb:function get_inscriptions_ext_mois_site
set lc_time to 'fr_FR';
DROP FUNCTION IF EXISTS get_inscriptions_ext_mois_site;
CREATE FUNCTION get_inscriptions_ext_mois_site(
    param_annee INTEGER DEFAULT 2026
)
RETURNS TABLE (
    mois TEXT,
    bibliotheque TEXT,
    groupe TEXT,
    inscriptions INTEGER
)
AS
$$
WITH params AS (
    SELECT param_annee AS annee
),
months AS (
    SELECT generate_series(1, 12) AS mois
)
SELECT
    TO_CHAR(
        MAKE_DATE(p.annee, m.mois, 1),
        'TMMonth'
    ) AS mois,
    COALESCE(spt.name, 'Non renseigné') AS bibliotheque,
    case ut.patron_group
        when '503a81cd-6c26-400f-b620-14c08943697c' then 'Extérieurs'
        when '59c0490d-9d96-4ea8-9bcc-43e5a63002e6' then 'Temporaire'
        else 'erreur'
    end as groupe,
    COUNT(DISTINCT ut.id) AS inscriptions
FROM months m
CROSS JOIN params p
LEFT JOIN folio_users.users__t ut
    ON EXTRACT(YEAR FROM ut.updated_date) = p.annee
    AND EXTRACT(MONTH FROM ut.updated_date) = m.mois
    AND ut.patron_group IN (
        '503a81cd-6c26-400f-b620-14c08943697c',
        '59c0490d-9d96-4ea8-9bcc-43e5a63002e6'
    )
LEFT JOIN folio_circulation.user_request_preference__t urpt
    ON urpt.user_id = ut.id
LEFT JOIN folio_inventory.service_point__t spt
    ON urpt.default_service_point_id = spt.id
GROUP BY
    p.annee,
    m.mois,
    spt.name,
    groupe
ORDER BY
    m.mois,
    bibliotheque;
$$
LANGUAGE SQL STABLE;
