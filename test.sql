--metadb:function get_test
DROP FUNCTION IF EXISTS get_test;
CREATE FUNCTION get_test(
    param_emplacement TEXT DEFAULT '',
    param_rcr TEXT DEFAULT ''
)
RETURNS TABLE (
    instance_uuid TEXT,
)
AS
$$
SELECT DISTINCT ihi.instance_id :: TEXT
FROM
    folio_derived.items_holdings_instances ihi,
    folio_derived.locations_libraries l,
    folio_inventory.holdings_record__t hrt
WHERE
    ihi.holdings_id = hrt.id
    and hrt.effective_location_id = l.location_id
    and l.location_code = param_emplacement
    AND NOT EXISTS (
      SELECT 1
      FROM folio_source_record.marc__t m
      WHERE m.instance_id = ihi.instance_id
        AND m.field = '930'
        AND m.sf = '5'
        AND m.content LIKE CONCAT(param_rcr, ':%')
    )
$$
LANGUAGE SQL STABLE;;
