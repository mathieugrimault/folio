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
    date_dernier_pret TEXT,
    date_expiration TEXT
)
AS
$$
select
    ut.id as user_uuid,
    jsonb_extract_path_text(ut.jsonb, 'barcode') as code_barres,
    jsonb_extract_path_text(ut.jsonb, 'personal', 'lastName') as nom,
    jsonb_extract_path_text(ut.jsonb, 'personal', 'firstName') as prenom,
    to_char(max(li.loan_date), 'DD-MM-YYYY') as date_dernier_pret,
    to_char(jsonb_extract_path_text(ut.jsonb, 'expirationDate'), 'DD-MM-YYYY') as date_expiration
from
    folio_derived.loans_items li,
    folio_users.users__ ut
where
    li.user_id = ut.id
    and ut.__current = true
    and jsonb_extract_path_text(ut.jsonb, 'customFields', 'etablissement') = param_etablissement
    and jsonb_extract_path_text(ut.jsonb, 'patronGroup') = '3684a786-6671-4268-8ed0-9db82ebca60b'
    and jsonb_extract_path_text(ut.jsonb, 'active') = 'true'
    and not li.loan_date >= param_loandate
group by
    user_uuid, code_barres, nom, prenom, date_expiration
order by
    nom, prenom, date_expiration;
$$
LANGUAGE SQL STABLE;
