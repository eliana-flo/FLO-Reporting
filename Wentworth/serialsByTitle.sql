--metadb:function serialsByTitle

DROP FUNCTION IF EXISTS serialsByTitle;

CREATE FUNCTION serialsByTitle()
RETURNS TABLE
  (title text,
  contributor_name text, 
  publisher text,
  dates_of_publication text,
  call_number text,
  shelving_location text,
  discovery_suppress boolean,
  instance_format_name text,
  identifiers text,
  holdings_statements text)
AS $$
with 
  inst_contributors AS (
  select ic.instance_id, ic.contributor_name
  from 
  folio_derived.instance_contributors ic where ic.contributor_is_primary='TRUE'
  group by ic.instance_id,ic.contributor_name
  )
select it.title, ic2.contributor_name, string_agg(distinct ip.publisher, ', ') as publisher, string_agg( distinct ip.date_of_publication, ', ') as dates_of_publication, hrt.call_number, lt.name as shelving_location, it.discovery_suppress, if2.instance_format_name, string_agg(distinct ii.identifier,', ') as identifiers, string_agg(distinct hs.holdings_statement, ', ') as holdings_statements
from folio_inventory.instance__t it 
left join folio_derived.instance_publication ip ON (it.id = ip.instance_id)
left join folio_inventory.holdings_record__t hrt ON (it.id = hrt.instance_id)
left join folio_inventory.location__t lt ON (hrt.effective_location_id = lt.id)
left join folio_derived.instance_formats if2 ON (it.id = if2.instance_id)
left join folio_derived.instance_identifiers ii ON (it.id = ii.instance_id)
left join folio_derived.holdings_statements hs ON (it.id = hs.instance_id)
left join inst_contributors ic2 on (it.id = ic2.instance_id)
WHERE lt.code = 'srl'
GROUP BY hrt.id, it.title, ic2.contributor_name, hrt.call_number, lt.name, it.discovery_suppress, if2.instance_format_name
ORDER BY it.title
  $$
LANGUAGE SQL
STABLE
PARALLEL SAFE;
