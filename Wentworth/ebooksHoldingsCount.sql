--metadb:function ebooksHoldingsCount

DROP FUNCTION IF EXISTS ebooksHoldingsCount;

CREATE FUNCTION ebooksHoldingsCount()
RETURNS TABLE
  (holdings_count integer)
AS $$
SELECT COUNT(hr.id) as holdings_count
FROM folio_inventory.holdings_record__t hr
LEFT JOIN folio_inventory.location__t l ON (l.id = hr.permanent_location_id)
WHERE l.name LIKE 'Ebooks'
$$
LANGUAGE SQL
STABLE
PARALLEL SAFE;
