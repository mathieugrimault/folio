--metadb:function get_pret_sur_place
DROP FUNCTION IF EXISTS get_pret_sur_place;
CREATE FUNCTION get_pret_sur_place(
    param_source TEXT DEFAULT NULL,
    param_mindate TEXT DEFAULT '',
    param_maxdate TEXT DEFAULT ''
)
RETURNS TABLE (
    operateur TEXT,
    date TEXT,
    titre TEXT,
    cote TEXT,
    codebarres TEXT,
    enumeration TEXT,
    bibliotheque TEXT,
    emplacement TEXT
)
AS
$$
select
    cl.jsonb ->> 'source' as operateur,
    to_char(cl.__start, 'YYYY-MM-DD HH:MM') as date,
    ihi.title as titre,
    ihi.item_level_call_number as cote,
    ihi.barcode as codebarres,
    it.display_summary as enumeration,
    ll.library_name as bibliotheque,
    ll.location_name as emplacement
from
    folio_derived.items_holdings_instances ihi,
    folio_audit.circulation_logs__ cl,
    folio_inventory.item__t it,
    folio_derived.locations_libraries ll
where
    ihi.item_id = (cl.jsonb -> 'items' -> 0 ->> 'itemId')::uuid
    and ihi.item_id = it.id
    and it.effective_location_id = ll.location_id
    and cl.__current = true
    and jsonb_array_length(cl.jsonb -> 'items') = 1
    and cl.jsonb -> 'items' -> 0 -> 'loanId' is null
    and cl.jsonb -> 'userBarcode' is null
    and cl.jsonb ->> 'object' = 'N/A'
    and cl.jsonb ->> 'description' = 'Item status: Available.'
    and (param_source IS NULL OR cl.jsonb ->> 'source' = param_source)
    and cl.__start::date BETWEEN param_mindate::date and param_maxdate::date;
$$
LANGUAGE SQL STABLE;
