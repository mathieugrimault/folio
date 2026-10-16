--metadb:function get_personnels_non_emprunteurs
DROP FUNCTION IF EXISTS get_pne;
CREATE FUNCTION get_pne(
    param_etablissement TEXT DEFAULT '',
    param_loandate TEXT DEFAULT ''
)
RETURNS TABLE (
    user_uuid UUID
)
AS
$$
select
    ut.id as user_uuid
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
