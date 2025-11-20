--metadb:function circStatsByDate

DROP FUNCTION IF EXISTS circStatsByDate;

CREATE FUNCTION circStatsByDate()
RETURNS TABLE
  (title text,
  effective_shelving_order text,
  call_number text,
  enumeration_data text,
  shelving_location text,
  action text,
  count integer)
AS $$
SELECT it.title, it2.effective_shelving_order, hrt.call_number, COALESCE(it2.enumeration, it2.chronology, it2.volume) AS enumeration_data, lt.name as shelving_location, lt2.action, COUNT (DISTINCT lt2.loan_date) 
FROM folio_inventory.instance__t it
LEFT JOIN folio_inventory.holdings_record__t hrt ON (hrt.instance_id = it.id)
LEFT JOIN folio_inventory.item__t it2 ON (it2.holdings_record_id = hrt.id)
LEFT JOIN folio_circulation.loan__t__ lt2 ON (lt2.item_id = it2.id)
LEFT JOIN folio_inventory.location__t lt ON (lt.id = lt2.item_effective_location_id_at_check_out)
WHERE '2023-01-01' <= lt2.loan_date  
AND lt.code = 'stk'
AND lt2.action = 'checkedout'
GROUP BY lt2.item_id, it.title, it2.effective_shelving_order, hrt.call_number, enumeration_data, lt.name, lt2.item_status, lt2.action
  $$
LANGUAGE SQL
STABLE
PARALLEL SAFE;
