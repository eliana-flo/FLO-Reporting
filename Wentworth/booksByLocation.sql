--metadb:function booksByLocation

DROP FUNCTION IF EXISTS booksByLocation;

CREATE FUNCTION booksByLocation()
RETURNS TABLE
  (location text,
item_count integer)
AS $$
SELECT 
l.name as location, 
COUNT (it.id) as item_count
FROM 
folio_inventory.item__t it
LEFT JOIN folio_inventory.location__t l ON (l.id = it.effective_location_id)
LEFT JOIN folio_inventory.material_type__t m ON (m.id = it.material_type_id)
WHERE m.name = 'Book'
GROUP BY l.name
ORDER BY item_count
$$
LANGUAGE SQL
STABLE
PARALLEL SAFE;
