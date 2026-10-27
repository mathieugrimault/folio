--metadb:function get_personnels_non_emprunteurs
DROP FUNCTION IF EXISTS get_pne;
CREATE FUNCTION get_pne(
    param_etablissement TEXT DEFAULT '',
    param_loandate TEXT DEFAULT ''
)
RETURNS TABLE (
    user_uuid UUID,
    code_barres TEXT,
    nom TEXT,
    prenom TEXT,
    date_dernier_pret TIMESTAMP,
    date_expiration TEXT
)
AS
$$
select
    ut.id as user_uuid,
    ut.jsonb -> 'barcode' as code_barres,
    ut.jsonb -> 'personal' ->> 'lastName' as nom,
    ut.jsonb -> 'personal' ->> 'firstName' as prenom,
    to_char(max(li.loan_date), 'DD-MM-YYYY') as date_dernier_pret,
    (ut.jsonb -> 'expirationDate') as date as date_expiration
from
    folio_derived.loans_items li,
    folio_users.users__ ut
where
    li.user_id = ut.id
    and ut.__current = true
    and ut.jsonb -> 'customFields' ->> 'etablissement' = param_etablissement
    and ut.jsonb -> 'patronGroup' = '3684a786-6671-4268-8ed0-9db82ebca60b'
    and ut.jsonb -> 'active' = 'true'
    and not li.loan_date >= param_loandate
group by
    user_uuid, code_barres, nom, prenom, date_expiration
order by
    nom, prenom, date_expiration;
$$
LANGUAGE SQL STABLE;
