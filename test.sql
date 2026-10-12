--metadb:function get_testaa
DROP FUNCTION IF EXISTS get_testaa;
CREATE FUNCTION get_testaa(
    param_emplacement TEXT DEFAULT '',
    param_rcr TEXT DEFAULT ''
)
RETURNS TABLE (
    instance_uuid UUID,
    item_status TEXT,
    identifier TEXT
)
AS
$$
SELECT DISTINCT
    ihi.instance_id,
    ihi.item_id, i.jsonb -> 'status' ->> 'name' as item_status,
    ii.identifier
FROM
    folio_derived.items_holdings_instances ihi,
    folio_derived.locations_libraries l,
    folio_inventory.holdings_record__t hrt,
    folio_inventory.item i,
    folio_derived.instance_identifiers ii
WHERE
    ihi.holdings_id = hrt.id
    and ii.instance_id = ihi.instance_id
    and ihi.item_id = i.id
    and hrt.effective_location_id = l.location_id
    and l.location_code = param_emplacement
    and i.jsonb -> 'status' ->> 'name' in (
        'Available', 'Checked out', 'Aged to lost',
        'Claimed returned', 'Unknown', 'Restricted',
        'Missing', 'Awaiting pickup', 'In transit',
        'Paged', 'Unavailable'
    )
    and ii.identifier like '(ABES)%'
    AND NOT EXISTS (
      SELECT 1
      FROM folio_source_record.marc__t m
      WHERE m.instance_id = ihi.instance_id
        AND m.field = '930'
        AND m.sf = '5'
        AND m.content LIKE CONCAT(param_rcr, ':%')
    );
$$
LANGUAGE SQL STABLE;
