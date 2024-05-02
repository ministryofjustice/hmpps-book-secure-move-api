select l.title as from_loc,
t.title as to_loc,
	m.date,
	m.reference,
	person.first_names,
	person.last_name,
	getstatus(risk.status) as risk,
	getstatus(offence.status) as offence,
	getstatus(health.status) as health,
	getstatus(property.status) as property,
	m.status as move_status,
	COALESCE(per.status, 'No PER') as per_status,
	m.allocation_id as allocation,
	COALESCE(s.name, 'BaSM Frontend') as created_by,
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
		select profile_id, section.key, section.status from person_escort_records, jsonb_to_recordset(person_escort_records.section_progress) as section(key text, status text)
	    where section.key = 'offence-information'
		and profile_id in (
			select pro.id from moves m
			left join profiles pro on m.profile_id = pro.id
			left join person_escort_records per on pro.id = per.profile_id
			left join people person on  pro.person_id = person.id
			where m.date between '2023-12-01' and '2024-01-01'
		)
	) as offence 
	on offence.profile_id = pro.id

	left join (
		select profile_id, section.key, section.status from person_escort_records, jsonb_to_recordset(person_escort_records.section_progress) as section(key text, status text)
		where section.key = 'property-information'
		and profile_id in (
			select pro.id from moves m
			left join profiles pro on m.profile_id = pro.id
			left join person_escort_records per on pro.id = per.profile_id
			left join people person on  pro.person_id = person.id
			where m.date between '2023-12-01' and '2024-01-01'
		)
	) as property 
	on property.profile_id = pro.id
	
	left join (
			select profile_id, section.key, section.status from person_escort_records, jsonb_to_recordset(person_escort_records.section_progress) as section(key text, status text)
			where section.key = 'risk-information'
			and profile_id in (
			select pro.id from moves m
			left join profiles pro on m.profile_id = pro.id
			left join person_escort_records per on pro.id = per.profile_id
			left join people person on  pro.person_id = person.id
			where m.date between '2023-12-01' and '2024-01-01'
	)
	) as risk 
	on risk.profile_id = pro.id
	
	left join (
			select profile_id, section.key, section.status from person_escort_records, jsonb_to_recordset(person_escort_records.section_progress) as section(key text, status text)
			where section.key = 'health-information'
			and profile_id in (
			select pro.id from moves m
			left join profiles pro on m.profile_id = pro.id
			left join person_escort_records per on pro.id = per.profile_id
			left join people person on  pro.person_id = person.id
			where m.date between '2023-12-01' and '2024-01-01'
	)
	) as health 
	on health.profile_id = pro.id
	
join (		
select distinct(first_names, last_name, date), first_names, last_name, date from (
select m.date,
	upper(person.first_names) as first_names,
	upper(person.last_name) as last_name
	from moves m 
	left join profiles pro on m.profile_id = pro.id
	left join person_escort_records per on pro.id = per.profile_id
	left join people person on  pro.person_id = person.id
	left join (
		select m.id, 'true' as dupe 
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
				and m.date between '2023-12-01' and '2024-01-01'
				group by m.date,
				upper(ps.last_name),
				upper(ps.first_names),
				
				m.from_location_id
			) as i

			where i.occ > 1

			) as j

			join people ps on j.last_name = upper(ps.last_name) and j.first_names = upper(ps.first_names)
			join profiles p on p.person_id = ps.id
			join moves m on m.date = j.date and m.profile_id = p.id
	) as dupe
	on dupe.id = m.id	
	where m.date between '2023-12-01' and '2024-01-01'
	and m.status = 'completed'
	and (per.id is null or per.status not in ('completed', 'confirmed'))
	and dupe.dupe = 'true'
   ) as dupe_people ) as dupes
	on dupes.last_name = upper(person.last_name) and dupes.first_names= upper(person.first_names) and m.date = dupes.date

	where m.date between '2023-12-01' and '2024-01-01'
	
	order by date, last_name, first_names, move_status, per_status
	

