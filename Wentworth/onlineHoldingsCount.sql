SELECT COUNT(hr.id) 
FROM folio_inventory.holdings_record__t hr
LEFT JOIN folio_inventory.location__t l ON (l.id = hr.permanent_location_id)
WHERE l.name LIKE 'Online'
