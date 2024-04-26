CREATE EXTENSION IF NOT EXISTS tablefunc;
    create or replace function getstatus(varchar) RETURNS integer
AS $$
BEGIN        

	if $1 = 'completed' then
	   return 1;
	elsif $1 = 'not_started' then
	   return -1;
	elsif $1 = 'in_progress' then
	   return 0;
	else
	   return null;
	end if;
END;
$$ LANGUAGE plpgsql;


select l.title as from_loc,
t.title as to_loc,
COALESCE(s.name, 'BaSM Frontend') as created_by,
m.status,
	m.date,
	m.reference,
	person.first_names,
	person.last_name,
	getstatus(info."risk-information") as risk,
	getstatus(info."offence-information") as offence,
	getstatus(info."health-information") as health,
	getstatus(info."property-information") as property,
	dupe.dupe as dupe,
	CASE
		WHEN s.name is not null and l.location_type = 'court' then 'true'
		ELSE null
	END as supplier_from_court,
	m.allocation_id as allocation,
	'https://bookasecuremove.service.justice.gov.uk/move/' || m.id as url
	from moves m 
	left join profiles pro on m.profile_id = pro.id
	left join person_escort_records per on pro.id = per.profile_id
	left join people person on  pro.person_id = person.id
	left join locations l on  m.from_location_id = l.id
	left join locations t on  m.to_location_id = t.id
	left outer join versions v on v.item_id = m.id and v.item_type = 'Move' and v.event = 'create'
	left outer join suppliers s on v.supplier_id = s.id
	left join (
select *
FROM crosstab('
		select profile_id, section.key, section.status from person_escort_records, jsonb_to_recordset(person_escort_records.section_progress) as section(key text, status text)
		
		where profile_id in (
			select pro.id from moves m
			left join profiles pro on m.profile_id = pro.id
			left join person_escort_records per on pro.id = per.profile_id
			left join people person on  pro.person_id = person.id
			where m.date between ''2024-03-01'' and ''2024-04-01''
			and m.status = ''completed''
			and (per.id is null or per.status not in (''completed'', ''confirmed''))
			)
			order by profile_id, section.key
		') as ct (profile_id uuid,
				"health-information" text,
				"offence-information" text,
				"property-information" text,				
				"risk-information" text)
    ) as info
	on info.profile_id = pro.id
	
	left join (
		select m.id, m.from_location_id, 'true' as dupe 
		from (
			select  i.date, i.first_names, i.last_name, i.from_location_id from (
				select count(*) as occ,
				m.date,
				upper(ps.last_name) as last_name,
				upper(ps.first_names) as first_names,
				m.from_location_id
				from moves m
				join profiles p on m.profile_id = p.id
				join people ps on p.person_id = ps.id
				and m.date between '2024-03-01' and '2024-04-01'
				group by m.date,
				upper(ps.last_name),
				upper(ps.first_names),
				
				m.from_location_id
			) as i

			where i.occ > 1

			) as j

			join people ps on j.last_name = upper(ps.last_name) and j.first_names = upper(ps.first_names)
			join profiles p on p.person_id = ps.id
			join moves m on m.date = j.date and m.profile_id = p.id and m.from_location_id = j.from_location_id
	) as dupe
	on dupe.id = m.id and dupe.from_location_id = m.from_location_id
	
	
	where m.date between '2024-03-01' and '2024-04-01'
	and m.status = 'completed'
	and (per.id is null or per.status not in ('completed', 'confirmed'))
	--and v.supplier_id is null
	order by from_loc, date