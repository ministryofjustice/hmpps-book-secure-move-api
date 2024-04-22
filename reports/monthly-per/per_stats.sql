SELECT 
	lf.title,
	count(L.flid) as completed_moves,
	NULLIF(count(L.flid) filter (where L.per_status in ('completed', 'confirmed')),0) as completed_per,
	NULLIF(count(L.flid) filter (where L.pro_requires_yra = 'true'),0) as needs_yra,
	NULLIF(count(L.flid) filter (where (L.pro_requires_yra = 'true') and (L.yra_id is null or L.yra_status not in ('completed', 'confirmed'))),0) as incomplete_yra,
	NULLIF(count(L.flid) filter (where L.per_id is null),0) as no_per,
	NULLIF(count(L.flid) filter (where L.per_status = 'unstarted'),0) as unstarted_per,
	NULLIF(count(L.flid) filter (where L.per_status = 'in_progress'),0) as in_progress_pers,
	NULLIF(round(((count(L.flid) filter (where (per_id is null or per_status not in ('completed', 'confirmed'))))::decimal / count(L.flid)::decimal), 3),0) as pc_incomplete
FROM (
	select 
		m.from_location_id as flid,
		per.status as per_status,
		per.id as per_id,
		pro.requires_youth_risk_assessment as pro_requires_yra,
		yra.id as yra_id,
		yra.status as yra_status
	from moves m 
	left join profiles pro on m.profile_id = pro.id
	left join person_escort_records per on pro.id = per.profile_id
	left join youth_risk_assessments yra on pro.id = yra.profile_id
	left outer join versions v on v.item_id = m.id and v.item_type = 'Move' and v.event = 'create'
	where m.date between '2024-03-01' and '2024-04-01'
	and m.status = 'completed') as L
left join locations lf on L.flid = lf.id 
group by lf.title
order by pc_incomplete desc NULLS LAST, (count(L.flid) filter (where (per_id is null or per_status not in ('completed', 'confirmed')))) desc NULLS LAST
