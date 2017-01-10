CREATE TABLE page_pos_fact (
	id				varchar(500)	not null,
  	campaign_id		varchar(100)	not null,
	event_date		date			not null sortkey,
	pos 			varchar(25) 	not null,
	site_section 	varchar(25) 	not null,
	site_country	varchar(25) 	not null,
	portal			varchar(25)		not null,
	international	int				not null,
    most_used		int				not null,
	impressions		decimal(15,6)	not null,
	clicks			decimal(15,6)	not null
);

CREATE TABLE dma_fact (
	dma_id							varchar(500)	not null,
	dma_campaign_id					varchar(100)	not null,
	dma_event_date 					date 			not null	sortkey,
	dma_geography	 				varchar(100) 	not null,
	dma_impression_attribution		decimal(15,6)	not null,
	dma_click_attribution			decimal(15,6)	not null,
	dma_pos_id						varchar(100)	not null	distkey,
	dma_pos_impressions				decimal(15,6)	not null,
	dma_pos_clicks					decimal(15,6)	not null,
	dma_est_impressions				decimal(15,6)	not null,
	dma_est_clicks					decimal(15,6)	not null
);

CREATE TABLE state_country_fact (
	scf_id							varchar(500)	not null,
	scf_campaign_id					varchar(100)	not null,
	scf_event_date 					date 			not null	sortkey,
	scf_geograph_id					varchar(100) 	not null,
	scf_impression_attribution		decimal(15,6)	not null,
	scf_click_attribution			decimal(15,6)	not null,
	scf_pos_id						varchar(100)	not null	distkey,
	scf_pos_impressions					decimal(15,6)	not null,
	scf_pos_clicks						decimal(15,6)	not null,
	scf_est_impressions				decimal(15,6)	not null,
	scf_est_clicks					decimal(15,6)	not null
);

insert into page_pos_fact

select
cast(x.campaign||'-'||to_char(x.event_date,'YYYY-MM-DD')||'-'||x.pos||'-'||x.site_section||'-'||x.site_country||'-'||x.portal as varchar(500)) as id,
x.campaign as campaign_id,
x.event_date,
x.pos,
x.site_section,
x.site_country,
x.portal,
case when x.site_country = 'DOMESTIC' then 0 else 1 end as international,
case
    when x.pos in ('x21','x22','x23','x25') and x.site_section in ('BR','DT','SR','HOME') and x.portal in ('BT','YW','BC') then 1
    when x.pos in ('Middle1','Middle2') and x.site_section in ('SR','BR') and x.portal = 'BT' then 1
    when x.pos = 'Top' and x.site_section = 'DT' and x.portal = 'BT' then 1
    else 0
end as most_used,
sum(x.impressions) as impressions,
sum(x.clicks) as clicks

from
(
SELECT campaign, TO_DATE("date",'YYYY-MM-DD') as event_date, impressions::decimal(15,6) as impressions, clicks::decimal(15,6) as clicks,
            p.pos,
            case 
                when p.url in ('www.yachtworld.com/en/boatsearch.html', 'www.boattrader.com/find/search.php', 'www.us.boats.com/advsearch.html', 
                'www.yachtworld.com/au/boatsearch.html', 'www.yachtworld.com/au/directory.html', 'www.yachtworld.com/de/boatsearch.html', 
                'www.yachtworld.com/de/directory.html', 'www.yachtworld.com/dk/boatsearch.html', 'www.yachtworld.com/dk/directory.html', 
                'www.yachtworld.com/es/boatsearch.html', 'www.yachtworld.com/es/directory.html', 'www.yachtworld.com/fi/boatsearch.html', 
                'www.yachtworld.com/fi/directory.html', 'www.yachtworld.com/fr/boatsearch.html', 'www.yachtworld.com/fr/directory.html', 
                'www.yachtworld.com/gb/boatsearch.html', 'www.yachtworld.com/gb/directory.html', 'www.yachtworld.com/it/boatsearch.html', 
                'www.yachtworld.com/it/directory.html', 'www.yachtworld.com/nl/boatsearch.html', 'www.yachtworld.com/nl/directory.html', 
                'www.yachtworld.com/no/boatsearch.html', 'www.yachtworld.com/no/directory.html', 'www.yachtworld.com/ru/boatsearch.html', 
                'www.yachtworld.com/ru/directory.html', 'www.yachtworld.com/se/boatsearch.html', 'www.yachtworld.com/se/directory.html', 
                'www.au.boats.com/advsearch.html', 'www.ca.boats.com/advsearch.html', 'www.de.boats.com/advsearch.html', 'www.es.boats.com/advsearch.html', 
                'www.fr.boats.com/advsearch.html', 'www.it.boats.com/advsearch.html', 'www.nl.boats.com/advsearch.html', 'www.uk.boats.com/advsearch.html')
                then 'ADVSR'
                when lower(p.url) like '%browse%' then 'BR'
                when lower(p.url) like '%detail%' then 'DT'
                when lower(p.url) like '%/resources%' then 'RES'
                when lower(p.url) like '%search%' then 'SR'
                when lower(p.url) like '%page%' then 'HOME'
                when lower(p.url) like '%com' then 'HOME'
                when lower(p.url) like '%www.boattrader.com/find/dealers/main.php%' then 'BR'
                when lower(p.url) like '%myt/listings.php' then 'DT'
                when lower(p.url) like '%engine%' then 'ENG'
                when lower(p.url) like '%features%' then 'FEATURES'
                when lower(p.url) like '%insurance%' then 'INSURANCE'
                when lower(p.url) like '%directory%' then 'RES'
                when lower(p.url) like '%fsbo%' then 'RES'
                when lower(p.url) like '%pbs%' then 'RES'
                when lower(p.url) like '%transport%' then 'TRANSPORT'
                else 'OTHER'
            end site_section,
            case
                when lower(p.url) like 'm%' then 'MOBILE'
                when lower(p.url) like 'www.au.boats%' then 'AU'
                when lower(p.url) like '%com' then 'DOMESTIC'
                when lower(p.url) like 'www.boats.com/en/%' then 'DOMESTIC'
                when lower(p.url) like 'www.boattrader.com%' then 'DOMESTIC'
                when lower(p.url) like 'www.ca.boats%' then 'CA'
                when lower(p.url) like 'www.de.boats%' then 'DE'
                when lower(p.url) like 'www.es.boats%' then 'ES'
                when lower(p.url) like 'www.fr.boats%' then 'FR'
                when lower(p.url) like 'www.it.boats%' then 'IT'
                when lower(p.url) like 'www.nl.boats%' then 'NL'
                when lower(p.url) like 'www.uk.boats%' then 'UK'
                when lower(p.url) like 'www.us.boats%' then 'DOMESTIC'
                when lower(p.url) like 'www.yachtworld.com/au%' then 'AU'
                when lower(p.url) like 'www.yachtworld.com/de%' then 'DE'
                when lower(p.url) like 'www.yachtworld.com/dk%' then 'DK'
                when lower(p.url) like 'www.yachtworld.com/e/%' then 'E'
                when lower(p.url) like 'www.yachtworld.com/en%' then 'DOMESTIC'
                when lower(p.url) like 'www.yachtworld.com/es%' then 'ES'
                when lower(p.url) like 'www.yachtworld.com/fi%' then 'FI'
                when lower(p.url) like 'www.yachtworld.com/fr%' then 'FR'
                when lower(p.url) like 'www.yachtworld.com/gb%' then 'UK'
                when lower(p.url) like 'www.yachtworld.com/it%' then 'IT'
                when lower(p.url) like 'www.yachtworld.com/nl%' then 'NL'
                when lower(p.url) like 'www.yachtworld.com/no%' then 'NO'
                when lower(p.url) like 'www.yachtworld.com/ru%' then 'RU'
                when lower(p.url) like 'www.yachtworld.com/t/%' then 'T'
                when lower(p.url) like 'www.yachtworld.com/uk%' then 'UK'
                when lower(p.url) like 'www.yachtworldcharters.com%' then 'YWCHART'
                when lower(p.url) like 'www.yachtworld.com/se/%' then 'SE'
                when lower(p.url) like 'www.boats.com/en%' then 'DOMESTIC'
                when lower(p.url) like 'www.boats.com/e/%' then 'E'
                when lower(p.url) like 'www.yachtworld.com/us/%' then 'DOMESTIC'
                when lower(p.url) like 'www.yachtworld.com/n/%' then 'N'
                when lower(p.url) like 'www.yachtworld.com/s/%' then 'S'
                when lower(p.url) like 'www.yachtworld.com/dn/%' then 'DN'
                when lower(p.url) like 'www.boats.com/gb/%' then 'UK'
                when lower(p.url) like 'www.boats.com/de/%' then 'DE'
                when lower(p.url) like 'www.yachtworld.com/sv/%' then 'SV'
                when lower(p.url) like 'www.boats.com/au/%' then 'AU'
                when lower(p.url) like 'www.yachtworld.com/r/%' then 'R'
                when lower(p.url) like 'www.boats.com/ca/%' then 'CA'
                ELSE 'OTHER'
            END site_country,
            CASE
                WHEN lower(p.url) like 'www.boattrader.com%' then 'BT'
                WHEN lower(p.url) like '%yacht%' then 'YW'
                WHEN lower(p.url) like '%boats.com%' then 'BC'
                WHEN lower(p.url) like '%boatwizard%' then 'BOATWIZARD'
                ELSE 'OTHER'
            END portal
            
            
            from "oasdelbypagepos" p
            
            WHERE TO_DATE(p."date",'YYYY-MM-DD') between (select max(TO_DATE("date",'YYYY-MM-DD')) - 7 from "oasdelbypagepos") and (select max(TO_DATE("date",'YYYY-MM-DD')) from "oasdelbypagepos")
  			and 
  			CASE
                WHEN lower(p.url) like 'www.boattrader.com%' then 'BT'
                WHEN lower(p.url) like '%yacht%' then 'YW'
                WHEN lower(p.url) like '%boats.com%' then 'BC'
                WHEN lower(p.url) like '%boatwizard%' then 'BOATWIZARD'
                ELSE 'OTHER'
            END <> 'OTHER'
) x

group by
cast(x.campaign||'-'||to_char(x.event_date,'YYYY-MM-DD')||'-'||x.pos||'-'||x.site_section||'-'||x.portal as varchar(500)),
x.campaign,
x.event_date,
x.pos,
x.site_section,
x.site_country,
x.portal,
case when x.site_country = 'DOMESTIC' then 0 else 1 end,
case
    when x.pos in ('x21','x22','x23','x25') and x.site_section in ('BR','DT','SR','HOME') and x.portal in ('BT','YW','BC') then 1
    when x.pos in ('Middle1','Middle2') and x.site_section in ('SR','BR') and x.portal = 'BT' then 1
    when x.pos = 'Top' and x.site_section = 'DT' and x.portal = 'BT' then 1
    else 0
end;

insert into dma_fact

select
cast(pos.campaign||'-'||to_char(pos.event_date,'YYYY-MM-DD')||'-'||geo.geography||'-'||pos.id as VARCHAR(500)) AS dma_id,
pos.campaign as dma_campaign_id, pos.event_date as dma_event_date, geo.geography as dma_geography, 
geo.impression_attribution as dma_impression_attribution, geo.click_attribution as dma_click_attribution,
pos.id as dma_pos_id, pos.impressions as dma_pos_impressions, pos.clicks as dma_pos_clicks,
geo.impression_attribution*pos.impressions as dma_est_impressions,
geo.click_attribution*pos.clicks as dma_est_clicks

from
(
	select x.campaign, to_date(x."date",'YYYY-MM-DD') as event_date, x.geography, 
	case
		when sum(x.impressions) over(partition by campaign,"date") = 0 then 0
		else x.impressions/sum(x.impressions) over(partition by campaign,"date")
	end impression_attribution, 
	case 
		when sum(x.clicks) over(partition by campaign,"date") = 0 then 0
		else x.clicks/sum(x.clicks) over(partition by campaign,"date")
	end click_attribution
	
	from "oasdelbydma" x
  
  	where TO_DATE(x."date",'YYYY-MM-DD') between (select max(TO_DATE("date",'YYYY-MM-DD')) - 7 from "oasdelbydma") and (select max(TO_DATE("date",'YYYY-MM-DD')) from "oasdelbydma")
	--where x."date" = '2016-02-12'
	--and x.campaign = '27822-1_13237_BluewaterYacht_BTOL-SR-RT2-300x250_CC_T3_JanThrJul'
) geo
join
(
	select
	y.campaign, y.event_date, cast(y.pos||'-'||y.site_section||'-'||y.portal as varchar(100))  id,
	sum(y.impressions) as impressions, sum(y.clicks) as clicks
	from
	(
		SELECT campaign, TO_DATE("date",'YYYY-MM-DD') as event_date, impressions::decimal(15,6) as impressions, clicks::decimal(15,6) as clicks,
			p.pos,
			case 
				when p.url in ('www.yachtworld.com/en/boatsearch.html', 'www.boattrader.com/find/search.php', 'www.us.boats.com/advsearch.html', 
				'www.yachtworld.com/au/boatsearch.html', 'www.yachtworld.com/au/directory.html', 'www.yachtworld.com/de/boatsearch.html', 
				'www.yachtworld.com/de/directory.html', 'www.yachtworld.com/dk/boatsearch.html', 'www.yachtworld.com/dk/directory.html', 
				'www.yachtworld.com/es/boatsearch.html', 'www.yachtworld.com/es/directory.html', 'www.yachtworld.com/fi/boatsearch.html', 
				'www.yachtworld.com/fi/directory.html', 'www.yachtworld.com/fr/boatsearch.html', 'www.yachtworld.com/fr/directory.html', 
				'www.yachtworld.com/gb/boatsearch.html', 'www.yachtworld.com/gb/directory.html', 'www.yachtworld.com/it/boatsearch.html', 
				'www.yachtworld.com/it/directory.html', 'www.yachtworld.com/nl/boatsearch.html', 'www.yachtworld.com/nl/directory.html', 
				'www.yachtworld.com/no/boatsearch.html', 'www.yachtworld.com/no/directory.html', 'www.yachtworld.com/ru/boatsearch.html', 
				'www.yachtworld.com/ru/directory.html', 'www.yachtworld.com/se/boatsearch.html', 'www.yachtworld.com/se/directory.html', 
				'www.au.boats.com/advsearch.html', 'www.ca.boats.com/advsearch.html', 'www.de.boats.com/advsearch.html', 'www.es.boats.com/advsearch.html', 
				'www.fr.boats.com/advsearch.html', 'www.it.boats.com/advsearch.html', 'www.nl.boats.com/advsearch.html', 'www.uk.boats.com/advsearch.html')
				then 'ADVSR'
				when lower(p.url) like '%browse%' then 'BR'
				when lower(p.url) like '%detail%' then 'DT'
				when lower(p.url) like '%/resources%' then 'RES'
				when lower(p.url) like '%search%' then 'SR'
				when lower(p.url) like '%page%' then 'HOME'
				when lower(p.url) like '%com' then 'HOME'
				when lower(p.url) like '%www.boattrader.com/find/dealers/main.php%' then 'BR'
				when lower(p.url) like '%myt/listings.php' then 'DT'
				when lower(p.url) like '%engine%' then 'ENG'
				when lower(p.url) like '%features%' then 'FEATURES'
				when lower(p.url) like '%insurance%' then 'INSURANCE'
				when lower(p.url) like '%directory%' then 'RES'
				when lower(p.url) like '%fsbo%' then 'RES'
				when lower(p.url) like '%pbs%' then 'RES'
				when lower(p.url) like '%transport%' then 'TRANSPORT'
				else 'OTHER'
			end site_section,
			case
				when lower(p.url) like 'm%' then 'MOBILE'
				when lower(p.url) like 'www.au.boats%' then 'AU'
				when lower(p.url) like '%com' then 'DOMESTIC'
				when lower(p.url) like 'www.boats.com/en/%' then 'DOMESTIC'
				when lower(p.url) like 'www.boattrader.com%' then 'DOMESTIC'
				when lower(p.url) like 'www.ca.boats%' then 'CA'
				when lower(p.url) like 'www.de.boats%' then 'DE'
				when lower(p.url) like 'www.es.boats%' then 'ES'
				when lower(p.url) like 'www.fr.boats%' then 'FR'
				when lower(p.url) like 'www.it.boats%' then 'IT'
				when lower(p.url) like 'www.nl.boats%' then 'NL'
				when lower(p.url) like 'www.uk.boats%' then 'UK'
				when lower(p.url) like 'www.us.boats%' then 'DOMESTIC'
				when lower(p.url) like 'www.yachtworld.com/au%' then 'AU'
				when lower(p.url) like 'www.yachtworld.com/de%' then 'DE'
				when lower(p.url) like 'www.yachtworld.com/dk%' then 'DK'
				when lower(p.url) like 'www.yachtworld.com/e/%' then 'E'
				when lower(p.url) like 'www.yachtworld.com/en%' then 'DOMESTIC'
				when lower(p.url) like 'www.yachtworld.com/es%' then 'ES'
				when lower(p.url) like 'www.yachtworld.com/fi%' then 'FI'
				when lower(p.url) like 'www.yachtworld.com/fr%' then 'FR'
				when lower(p.url) like 'www.yachtworld.com/gb%' then 'UK'
				when lower(p.url) like 'www.yachtworld.com/it%' then 'IT'
				when lower(p.url) like 'www.yachtworld.com/nl%' then 'NL'
				when lower(p.url) like 'www.yachtworld.com/no%' then 'NO'
				when lower(p.url) like 'www.yachtworld.com/ru%' then 'RU'
				when lower(p.url) like 'www.yachtworld.com/t/%' then 'T'
				when lower(p.url) like 'www.yachtworld.com/uk%' then 'UK'
				when lower(p.url) like 'www.yachtworldcharters.com%' then 'YWCHART'
				when lower(p.url) like 'www.yachtworld.com/se/%' then 'SE'
				when lower(p.url) like 'www.boats.com/en%' then 'DOMESTIC'
				when lower(p.url) like 'www.boats.com/e/%' then 'E'
				when lower(p.url) like 'www.yachtworld.com/us/%' then 'DOMESTIC'
				when lower(p.url) like 'www.yachtworld.com/n/%' then 'N'
				when lower(p.url) like 'www.yachtworld.com/s/%' then 'S'
				when lower(p.url) like 'www.yachtworld.com/dn/%' then 'DN'
				when lower(p.url) like 'www.boats.com/gb/%' then 'UK'
				when lower(p.url) like 'www.boats.com/de/%' then 'DE'
				when lower(p.url) like 'www.yachtworld.com/sv/%' then 'SV'
				when lower(p.url) like 'www.boats.com/au/%' then 'AU'
				when lower(p.url) like 'www.yachtworld.com/r/%' then 'R'
				when lower(p.url) like 'www.boats.com/ca/%' then 'CA'
				ELSE 'OTHER'
			END site_country,
			CASE
				WHEN lower(p.url) like 'www.boattrader.com%' then 'BT'
				WHEN lower(p.url) like '%yacht%' then 'YW'
				WHEN lower(p.url) like '%boats.com%' then 'BC'
				WHEN lower(p.url) like '%boatwizard%' then 'BOATWIZARD'
				ELSE 'OTHER'
			END portal
			
			
			from "oasdelbypagepos" p
			
            WHERE TO_DATE(p."date",'YYYY-MM-DD') between (select max(TO_DATE("date",'YYYY-MM-DD')) - 7 from "oasdelbypagepos") and (select max(TO_DATE("date",'YYYY-MM-DD')) from "oasdelbypagepos")
  			and 
  			CASE
                WHEN lower(p.url) like 'www.boattrader.com%' then 'BT'
                WHEN lower(p.url) like '%yacht%' then 'YW'
                WHEN lower(p.url) like '%boats.com%' then 'BC'
                WHEN lower(p.url) like '%boatwizard%' then 'BOATWIZARD'
                ELSE 'OTHER'
            END <> 'OTHER'
		) y
	
	--where to_char(y.event_date,'YYYY-MM-DD') = '2016-02-12'
	--and y.campaign = '27822-1_13237_BluewaterYacht_BTOL-SR-RT2-300x250_CC_T3_JanThrJul'
	group by
	y.campaign, y.event_date, cast(y.pos||'-'||y.site_section||'-'||y.portal as varchar(100))
) pos
on geo.campaign = pos.campaign and geo.event_date = pos.event_date;

insert into state_country_fact

select
cast(pos.campaign||'-'||to_char(pos.event_date,'YYYY-MM-DD')||'-'||geo.geography||'-'||pos.id as VARCHAR(500)) AS scf_id,
pos.campaign as scf_campaign_id, pos.event_date as scf_event_date, geo.geography as scf_geography_id, 
geo.impression_attribution as scf_impression_attribution, geo.click_attribution as scf_click_attribution,
pos.id as scf_pos_id, pos.impressions as scf_pos_impressions, pos.clicks as scf_pos_clicks,
geo.impression_attribution*pos.impressions as scf_est_impressions,
geo.click_attribution*pos.clicks as scf_est_clicks

from
(
	select x.campaign, to_date(x."date",'YYYY-MM-DD') as event_date, x.geography, 
	case
		when sum(x.impressions) over(partition by campaign,"date") = 0 then 0
		else x.impressions/sum(x.impressions) over(partition by campaign,"date")
	end impression_attribution, 
	case 
		when sum(x.clicks) over(partition by campaign,"date") = 0 then 0
		else x.clicks/sum(x.clicks) over(partition by campaign,"date")
	end click_attribution
	
	from
	(
		SELECT campaign,"date",geography, impressions::decimal(15,6) as impressions, clicks::decimal(15,6) as clicks
		FROM "oasdelbystate"
		where geography like 'US%' or geography like 'CA%'
        and TO_DATE("date",'YYYY-MM-DD') between (select max(TO_DATE("date",'YYYY-MM-DD')) - 7 from "oasdelbystate") and (select max(TO_DATE("date",'YYYY-MM-DD')) from "oasdelbystate")
		
		union all
			
		SELECT campaign, "date", geography, impressions::decimal(15,6) as impressions, clicks::decimal(15,6) as clicks
		FROM "oasdelbycountry"
		where geography not in ('United States Of America','Canada')
        and TO_DATE("date",'YYYY-MM-DD') between (select max(TO_DATE("date",'YYYY-MM-DD')) - 7 from "oasdelbystate") and (select max(TO_DATE("date",'YYYY-MM-DD')) from "oasdelbystate")
	) x
	--where x."date" = '2016-02-12'
	--and x.campaign = '27822-1_13237_BluewaterYacht_BTOL-SR-RT2-300x250_CC_T3_JanThrJul'
) geo
join
(
	select
	y.campaign, y.event_date, cast(y.pos||'-'||y.site_section||'-'||y.portal as varchar(100))  id,
	sum(y.impressions) as impressions, sum(y.clicks) as clicks
	from
	(
		SELECT campaign, TO_DATE("date",'YYYY-MM-DD') as event_date, impressions::decimal(15,6) as impressions, clicks::decimal(15,6) as clicks,
			p.pos,
			case 
				when p.url in ('www.yachtworld.com/en/boatsearch.html', 'www.boattrader.com/find/search.php', 'www.us.boats.com/advsearch.html', 
				'www.yachtworld.com/au/boatsearch.html', 'www.yachtworld.com/au/directory.html', 'www.yachtworld.com/de/boatsearch.html', 
				'www.yachtworld.com/de/directory.html', 'www.yachtworld.com/dk/boatsearch.html', 'www.yachtworld.com/dk/directory.html', 
				'www.yachtworld.com/es/boatsearch.html', 'www.yachtworld.com/es/directory.html', 'www.yachtworld.com/fi/boatsearch.html', 
				'www.yachtworld.com/fi/directory.html', 'www.yachtworld.com/fr/boatsearch.html', 'www.yachtworld.com/fr/directory.html', 
				'www.yachtworld.com/gb/boatsearch.html', 'www.yachtworld.com/gb/directory.html', 'www.yachtworld.com/it/boatsearch.html', 
				'www.yachtworld.com/it/directory.html', 'www.yachtworld.com/nl/boatsearch.html', 'www.yachtworld.com/nl/directory.html', 
				'www.yachtworld.com/no/boatsearch.html', 'www.yachtworld.com/no/directory.html', 'www.yachtworld.com/ru/boatsearch.html', 
				'www.yachtworld.com/ru/directory.html', 'www.yachtworld.com/se/boatsearch.html', 'www.yachtworld.com/se/directory.html', 
				'www.au.boats.com/advsearch.html', 'www.ca.boats.com/advsearch.html', 'www.de.boats.com/advsearch.html', 'www.es.boats.com/advsearch.html', 
				'www.fr.boats.com/advsearch.html', 'www.it.boats.com/advsearch.html', 'www.nl.boats.com/advsearch.html', 'www.uk.boats.com/advsearch.html')
				then 'ADVSR'
				when lower(p.url) like '%browse%' then 'BR'
				when lower(p.url) like '%detail%' then 'DT'
				when lower(p.url) like '%/resources%' then 'RES'
				when lower(p.url) like '%search%' then 'SR'
				when lower(p.url) like '%page%' then 'HOME'
				when lower(p.url) like '%com' then 'HOME'
				when lower(p.url) like '%www.boattrader.com/find/dealers/main.php%' then 'BR'
				when lower(p.url) like '%myt/listings.php' then 'DT'
				when lower(p.url) like '%engine%' then 'ENG'
				when lower(p.url) like '%features%' then 'FEATURES'
				when lower(p.url) like '%insurance%' then 'INSURANCE'
				when lower(p.url) like '%directory%' then 'RES'
				when lower(p.url) like '%fsbo%' then 'RES'
				when lower(p.url) like '%pbs%' then 'RES'
				when lower(p.url) like '%transport%' then 'TRANSPORT'
				else 'OTHER'
			end site_section,
			case
				when lower(p.url) like 'm%' then 'MOBILE'
				when lower(p.url) like 'www.au.boats%' then 'AU'
				when lower(p.url) like '%com' then 'DOMESTIC'
				when lower(p.url) like 'www.boats.com/en/%' then 'DOMESTIC'
				when lower(p.url) like 'www.boattrader.com%' then 'DOMESTIC'
				when lower(p.url) like 'www.ca.boats%' then 'CA'
				when lower(p.url) like 'www.de.boats%' then 'DE'
				when lower(p.url) like 'www.es.boats%' then 'ES'
				when lower(p.url) like 'www.fr.boats%' then 'FR'
				when lower(p.url) like 'www.it.boats%' then 'IT'
				when lower(p.url) like 'www.nl.boats%' then 'NL'
				when lower(p.url) like 'www.uk.boats%' then 'UK'
				when lower(p.url) like 'www.us.boats%' then 'DOMESTIC'
				when lower(p.url) like 'www.yachtworld.com/au%' then 'AU'
				when lower(p.url) like 'www.yachtworld.com/de%' then 'DE'
				when lower(p.url) like 'www.yachtworld.com/dk%' then 'DK'
				when lower(p.url) like 'www.yachtworld.com/e/%' then 'E'
				when lower(p.url) like 'www.yachtworld.com/en%' then 'DOMESTIC'
				when lower(p.url) like 'www.yachtworld.com/es%' then 'ES'
				when lower(p.url) like 'www.yachtworld.com/fi%' then 'FI'
				when lower(p.url) like 'www.yachtworld.com/fr%' then 'FR'
				when lower(p.url) like 'www.yachtworld.com/gb%' then 'UK'
				when lower(p.url) like 'www.yachtworld.com/it%' then 'IT'
				when lower(p.url) like 'www.yachtworld.com/nl%' then 'NL'
				when lower(p.url) like 'www.yachtworld.com/no%' then 'NO'
				when lower(p.url) like 'www.yachtworld.com/ru%' then 'RU'
				when lower(p.url) like 'www.yachtworld.com/t/%' then 'T'
				when lower(p.url) like 'www.yachtworld.com/uk%' then 'UK'
				when lower(p.url) like 'www.yachtworldcharters.com%' then 'YWCHART'
				when lower(p.url) like 'www.yachtworld.com/se/%' then 'SE'
				when lower(p.url) like 'www.boats.com/en%' then 'DOMESTIC'
				when lower(p.url) like 'www.boats.com/e/%' then 'E'
				when lower(p.url) like 'www.yachtworld.com/us/%' then 'DOMESTIC'
				when lower(p.url) like 'www.yachtworld.com/n/%' then 'N'
				when lower(p.url) like 'www.yachtworld.com/s/%' then 'S'
				when lower(p.url) like 'www.yachtworld.com/dn/%' then 'DN'
				when lower(p.url) like 'www.boats.com/gb/%' then 'UK'
				when lower(p.url) like 'www.boats.com/de/%' then 'DE'
				when lower(p.url) like 'www.yachtworld.com/sv/%' then 'SV'
				when lower(p.url) like 'www.boats.com/au/%' then 'AU'
				when lower(p.url) like 'www.yachtworld.com/r/%' then 'R'
				when lower(p.url) like 'www.boats.com/ca/%' then 'CA'
				ELSE 'OTHER'
			END site_country,
			CASE
				WHEN lower(p.url) like 'www.boattrader.com%' then 'BT'
				WHEN lower(p.url) like '%yacht%' then 'YW'
				WHEN lower(p.url) like '%boats.com%' then 'BC'
				WHEN lower(p.url) like '%boatwizard%' then 'BOATWIZARD'
				ELSE 'OTHER'
			END portal
			
			
			from "oasdelbypagepos" p
			
            WHERE TO_DATE(p."date",'YYYY-MM-DD') between (select max(TO_DATE("date",'YYYY-MM-DD')) - 7 from "oasdelbypagepos") and (select max(TO_DATE("date",'YYYY-MM-DD')) from "oasdelbypagepos")
  			and 
  			CASE
                WHEN lower(p.url) like 'www.boattrader.com%' then 'BT'
                WHEN lower(p.url) like '%yacht%' then 'YW'
                WHEN lower(p.url) like '%boats.com%' then 'BC'
                WHEN lower(p.url) like '%boatwizard%' then 'BOATWIZARD'
                ELSE 'OTHER'
            END <> 'OTHER'
		) y
	
	--where to_char(y.event_date,'YYYY-MM-DD') = '2016-02-12'
	--and y.campaign = '27822-1_13237_BluewaterYacht_BTOL-SR-RT2-300x250_CC_T3_JanThrJul'
	group by
	y.campaign, y.event_date, cast(y.pos||'-'||y.site_section||'-'||y.portal as varchar(100))
) pos
on geo.campaign = pos.campaign and geo.event_date = pos.event_date;

CREATE TABLE page_pos_fact_alldata (
	id				varchar(500)	not null,
  	campaign_id		varchar(100)	not null,
	event_date		date			not null sortkey,
	pos 			varchar(25) 	not null,
	site_section 	varchar(25) 	not null,
	site_country	varchar(25) 	not null,
	portal			varchar(25)		not null,
	international	int				not null,
    most_used		int				not null,
	impressions		decimal(15,6)	not null,
	clicks			decimal(15,6)	not null
);

CREATE TABLE dma_fact_alldata (
	dma_id							varchar(500)	not null,
	dma_campaign_id					varchar(100)	not null,
	dma_event_date 					date 			not null	sortkey,
	dma_geography	 				varchar(100) 	not null,
	dma_impression_attribution		decimal(15,6)	not null,
	dma_click_attribution			decimal(15,6)	not null,
	dma_pos_id						varchar(100)	not null	distkey,
	dma_pos_impressions				decimal(15,6)	not null,
	dma_pos_clicks					decimal(15,6)	not null,
	dma_est_impressions				decimal(15,6)	not null,
	dma_est_clicks					decimal(15,6)	not null
);

CREATE TABLE state_country_fact_alldata (
	scf_id							varchar(500)	not null,
	scf_campaign_id					varchar(100)	not null,
	scf_event_date 					date 			not null	sortkey,
	scf_geograph_id					varchar(100) 	not null,
	scf_impression_attribution		decimal(15,6)	not null,
	scf_click_attribution			decimal(15,6)	not null,
	scf_pos_id						varchar(100)	not null	distkey,
	scf_pos_impressions					decimal(15,6)	not null,
	scf_pos_clicks						decimal(15,6)	not null,
	scf_est_impressions				decimal(15,6)	not null,
	scf_est_clicks					decimal(15,6)	not null
);

insert into page_pos_fact_alldata

select
cast(x.campaign||'-'||to_char(x.event_date,'YYYY-MM-DD')||'-'||x.pos||'-'||x.site_section||'-'||x.site_country||'-'||x.portal as varchar(500)) as id,
x.campaign as campaign_id,
x.event_date,
x.pos,
x.site_section,
x.site_country,
x.portal,
case when x.site_country = 'DOMESTIC' then 0 else 1 end as international,
case
    when x.pos in ('x21','x22','x23','x25') and x.site_section in ('BR','DT','SR','HOME') and x.portal in ('BT','YW','BC') then 1
    when x.pos in ('Middle1','Middle2') and x.site_section in ('SR','BR') and x.portal = 'BT' then 1
    when x.pos = 'Top' and x.site_section = 'DT' and x.portal = 'BT' then 1
    else 0
end as most_used,
sum(x.impressions) as impressions,
sum(x.clicks) as clicks

from
(
SELECT campaign, TO_DATE("date",'YYYY-MM-DD') as event_date, impressions::decimal(15,6) as impressions, clicks::decimal(15,6) as clicks,
            p.pos,
            case 
                when p.url in ('www.yachtworld.com/en/boatsearch.html', 'www.boattrader.com/find/search.php', 'www.us.boats.com/advsearch.html', 
                'www.yachtworld.com/au/boatsearch.html', 'www.yachtworld.com/au/directory.html', 'www.yachtworld.com/de/boatsearch.html', 
                'www.yachtworld.com/de/directory.html', 'www.yachtworld.com/dk/boatsearch.html', 'www.yachtworld.com/dk/directory.html', 
                'www.yachtworld.com/es/boatsearch.html', 'www.yachtworld.com/es/directory.html', 'www.yachtworld.com/fi/boatsearch.html', 
                'www.yachtworld.com/fi/directory.html', 'www.yachtworld.com/fr/boatsearch.html', 'www.yachtworld.com/fr/directory.html', 
                'www.yachtworld.com/gb/boatsearch.html', 'www.yachtworld.com/gb/directory.html', 'www.yachtworld.com/it/boatsearch.html', 
                'www.yachtworld.com/it/directory.html', 'www.yachtworld.com/nl/boatsearch.html', 'www.yachtworld.com/nl/directory.html', 
                'www.yachtworld.com/no/boatsearch.html', 'www.yachtworld.com/no/directory.html', 'www.yachtworld.com/ru/boatsearch.html', 
                'www.yachtworld.com/ru/directory.html', 'www.yachtworld.com/se/boatsearch.html', 'www.yachtworld.com/se/directory.html', 
                'www.au.boats.com/advsearch.html', 'www.ca.boats.com/advsearch.html', 'www.de.boats.com/advsearch.html', 'www.es.boats.com/advsearch.html', 
                'www.fr.boats.com/advsearch.html', 'www.it.boats.com/advsearch.html', 'www.nl.boats.com/advsearch.html', 'www.uk.boats.com/advsearch.html')
                then 'ADVSR'
                when lower(p.url) like '%browse%' then 'BR'
                when lower(p.url) like '%detail%' then 'DT'
                when lower(p.url) like '%/resources%' then 'RES'
                when lower(p.url) like '%search%' then 'SR'
                when lower(p.url) like '%page%' then 'HOME'
                when lower(p.url) like '%com' then 'HOME'
                when lower(p.url) like '%www.boattrader.com/find/dealers/main.php%' then 'BR'
                when lower(p.url) like '%myt/listings.php' then 'DT'
                when lower(p.url) like '%engine%' then 'ENG'
                when lower(p.url) like '%features%' then 'FEATURES'
                when lower(p.url) like '%insurance%' then 'INSURANCE'
                when lower(p.url) like '%directory%' then 'RES'
                when lower(p.url) like '%fsbo%' then 'RES'
                when lower(p.url) like '%pbs%' then 'RES'
                when lower(p.url) like '%transport%' then 'TRANSPORT'
                else 'OTHER'
            end site_section,
            case
                when lower(p.url) like 'm%' then 'MOBILE'
                when lower(p.url) like 'www.au.boats%' then 'AU'
                when lower(p.url) like '%com' then 'DOMESTIC'
                when lower(p.url) like 'www.boats.com/en/%' then 'DOMESTIC'
                when lower(p.url) like 'www.boattrader.com%' then 'DOMESTIC'
                when lower(p.url) like 'www.ca.boats%' then 'CA'
                when lower(p.url) like 'www.de.boats%' then 'DE'
                when lower(p.url) like 'www.es.boats%' then 'ES'
                when lower(p.url) like 'www.fr.boats%' then 'FR'
                when lower(p.url) like 'www.it.boats%' then 'IT'
                when lower(p.url) like 'www.nl.boats%' then 'NL'
                when lower(p.url) like 'www.uk.boats%' then 'UK'
                when lower(p.url) like 'www.us.boats%' then 'DOMESTIC'
                when lower(p.url) like 'www.yachtworld.com/au%' then 'AU'
                when lower(p.url) like 'www.yachtworld.com/de%' then 'DE'
                when lower(p.url) like 'www.yachtworld.com/dk%' then 'DK'
                when lower(p.url) like 'www.yachtworld.com/e/%' then 'E'
                when lower(p.url) like 'www.yachtworld.com/en%' then 'DOMESTIC'
                when lower(p.url) like 'www.yachtworld.com/es%' then 'ES'
                when lower(p.url) like 'www.yachtworld.com/fi%' then 'FI'
                when lower(p.url) like 'www.yachtworld.com/fr%' then 'FR'
                when lower(p.url) like 'www.yachtworld.com/gb%' then 'UK'
                when lower(p.url) like 'www.yachtworld.com/it%' then 'IT'
                when lower(p.url) like 'www.yachtworld.com/nl%' then 'NL'
                when lower(p.url) like 'www.yachtworld.com/no%' then 'NO'
                when lower(p.url) like 'www.yachtworld.com/ru%' then 'RU'
                when lower(p.url) like 'www.yachtworld.com/t/%' then 'T'
                when lower(p.url) like 'www.yachtworld.com/uk%' then 'UK'
                when lower(p.url) like 'www.yachtworldcharters.com%' then 'YWCHART'
                when lower(p.url) like 'www.yachtworld.com/se/%' then 'SE'
                when lower(p.url) like 'www.boats.com/en%' then 'DOMESTIC'
                when lower(p.url) like 'www.boats.com/e/%' then 'E'
                when lower(p.url) like 'www.yachtworld.com/us/%' then 'DOMESTIC'
                when lower(p.url) like 'www.yachtworld.com/n/%' then 'N'
                when lower(p.url) like 'www.yachtworld.com/s/%' then 'S'
                when lower(p.url) like 'www.yachtworld.com/dn/%' then 'DN'
                when lower(p.url) like 'www.boats.com/gb/%' then 'UK'
                when lower(p.url) like 'www.boats.com/de/%' then 'DE'
                when lower(p.url) like 'www.yachtworld.com/sv/%' then 'SV'
                when lower(p.url) like 'www.boats.com/au/%' then 'AU'
                when lower(p.url) like 'www.yachtworld.com/r/%' then 'R'
                when lower(p.url) like 'www.boats.com/ca/%' then 'CA'
                ELSE 'OTHER'
            END site_country,
            CASE
                WHEN lower(p.url) like 'www.boattrader.com%' then 'BT'
                WHEN lower(p.url) like '%yacht%' then 'YW'
                WHEN lower(p.url) like '%boats.com%' then 'BC'
                WHEN lower(p.url) like '%boatwizard%' then 'BOATWIZARD'
                ELSE 'OTHER'
            END portal
            
            
            from "oasdelbypagepos" p
            
            --WHERE TO_DATE(p."date",'YYYY-MM-DD') between (select max(TO_DATE("date",'YYYY-MM-DD')) - 7 from "oasdelbypagepos") and (select max(TO_DATE("date",'YYYY-MM-DD')) from "oasdelbypagepos")
  			--and
			where
  			CASE
                WHEN lower(p.url) like 'www.boattrader.com%' then 'BT'
                WHEN lower(p.url) like '%yacht%' then 'YW'
                WHEN lower(p.url) like '%boats.com%' then 'BC'
                WHEN lower(p.url) like '%boatwizard%' then 'BOATWIZARD'
                ELSE 'OTHER'
            END <> 'OTHER'
) x

group by
cast(x.campaign||'-'||to_char(x.event_date,'YYYY-MM-DD')||'-'||x.pos||'-'||x.site_section||'-'||x.portal as varchar(500)),
x.campaign,
x.event_date,
x.pos,
x.site_section,
x.site_country,
x.portal,
case when x.site_country = 'DOMESTIC' then 0 else 1 end,
case
    when x.pos in ('x21','x22','x23','x25') and x.site_section in ('BR','DT','SR','HOME') and x.portal in ('BT','YW','BC') then 1
    when x.pos in ('Middle1','Middle2') and x.site_section in ('SR','BR') and x.portal = 'BT' then 1
    when x.pos = 'Top' and x.site_section = 'DT' and x.portal = 'BT' then 1
    else 0
end;

insert into dma_fact_alldata

select
cast(pos.campaign||'-'||to_char(pos.event_date,'YYYY-MM-DD')||'-'||geo.geography||'-'||pos.id as VARCHAR(500)) AS dma_id,
pos.campaign as dma_campaign_id, pos.event_date as dma_event_date, geo.geography as dma_geography, 
geo.impression_attribution as dma_impression_attribution, geo.click_attribution as dma_click_attribution,
pos.id as dma_pos_id, pos.impressions as dma_pos_impressions, pos.clicks as dma_pos_clicks,
geo.impression_attribution*pos.impressions as dma_est_impressions,
geo.click_attribution*pos.clicks as dma_est_clicks

from
(
	select x.campaign, to_date(x."date",'YYYY-MM-DD') as event_date, x.geography, 
	case
		when sum(x.impressions) over(partition by campaign,"date") = 0 then 0
		else x.impressions/sum(x.impressions) over(partition by campaign,"date")
	end impression_attribution, 
	case 
		when sum(x.clicks) over(partition by campaign,"date") = 0 then 0
		else x.clicks/sum(x.clicks) over(partition by campaign,"date")
	end click_attribution
	
	from "oasdelbydma" x
  
  	--where TO_DATE(x."date",'YYYY-MM-DD') between (select max(TO_DATE("date",'YYYY-MM-DD')) - 7 from "oasdelbydma") and (select max(TO_DATE("date",'YYYY-MM-DD')) from "oasdelbydma")
	--where x."date" = '2016-02-12'
	--and x.campaign = '27822-1_13237_BluewaterYacht_BTOL-SR-RT2-300x250_CC_T3_JanThrJul'
) geo
join
(
	select
	y.campaign, y.event_date, cast(y.pos||'-'||y.site_section||'-'||y.portal as varchar(100))  id,
	sum(y.impressions) as impressions, sum(y.clicks) as clicks
	from
	(
		SELECT campaign, TO_DATE("date",'YYYY-MM-DD') as event_date, impressions::decimal(15,6) as impressions, clicks::decimal(15,6) as clicks,
			p.pos,
			case 
				when p.url in ('www.yachtworld.com/en/boatsearch.html', 'www.boattrader.com/find/search.php', 'www.us.boats.com/advsearch.html', 
				'www.yachtworld.com/au/boatsearch.html', 'www.yachtworld.com/au/directory.html', 'www.yachtworld.com/de/boatsearch.html', 
				'www.yachtworld.com/de/directory.html', 'www.yachtworld.com/dk/boatsearch.html', 'www.yachtworld.com/dk/directory.html', 
				'www.yachtworld.com/es/boatsearch.html', 'www.yachtworld.com/es/directory.html', 'www.yachtworld.com/fi/boatsearch.html', 
				'www.yachtworld.com/fi/directory.html', 'www.yachtworld.com/fr/boatsearch.html', 'www.yachtworld.com/fr/directory.html', 
				'www.yachtworld.com/gb/boatsearch.html', 'www.yachtworld.com/gb/directory.html', 'www.yachtworld.com/it/boatsearch.html', 
				'www.yachtworld.com/it/directory.html', 'www.yachtworld.com/nl/boatsearch.html', 'www.yachtworld.com/nl/directory.html', 
				'www.yachtworld.com/no/boatsearch.html', 'www.yachtworld.com/no/directory.html', 'www.yachtworld.com/ru/boatsearch.html', 
				'www.yachtworld.com/ru/directory.html', 'www.yachtworld.com/se/boatsearch.html', 'www.yachtworld.com/se/directory.html', 
				'www.au.boats.com/advsearch.html', 'www.ca.boats.com/advsearch.html', 'www.de.boats.com/advsearch.html', 'www.es.boats.com/advsearch.html', 
				'www.fr.boats.com/advsearch.html', 'www.it.boats.com/advsearch.html', 'www.nl.boats.com/advsearch.html', 'www.uk.boats.com/advsearch.html')
				then 'ADVSR'
				when lower(p.url) like '%browse%' then 'BR'
				when lower(p.url) like '%detail%' then 'DT'
				when lower(p.url) like '%/resources%' then 'RES'
				when lower(p.url) like '%search%' then 'SR'
				when lower(p.url) like '%page%' then 'HOME'
				when lower(p.url) like '%com' then 'HOME'
				when lower(p.url) like '%www.boattrader.com/find/dealers/main.php%' then 'BR'
				when lower(p.url) like '%myt/listings.php' then 'DT'
				when lower(p.url) like '%engine%' then 'ENG'
				when lower(p.url) like '%features%' then 'FEATURES'
				when lower(p.url) like '%insurance%' then 'INSURANCE'
				when lower(p.url) like '%directory%' then 'RES'
				when lower(p.url) like '%fsbo%' then 'RES'
				when lower(p.url) like '%pbs%' then 'RES'
				when lower(p.url) like '%transport%' then 'TRANSPORT'
				else 'OTHER'
			end site_section,
			case
				when lower(p.url) like 'm%' then 'MOBILE'
				when lower(p.url) like 'www.au.boats%' then 'AU'
				when lower(p.url) like '%com' then 'DOMESTIC'
				when lower(p.url) like 'www.boats.com/en/%' then 'DOMESTIC'
				when lower(p.url) like 'www.boattrader.com%' then 'DOMESTIC'
				when lower(p.url) like 'www.ca.boats%' then 'CA'
				when lower(p.url) like 'www.de.boats%' then 'DE'
				when lower(p.url) like 'www.es.boats%' then 'ES'
				when lower(p.url) like 'www.fr.boats%' then 'FR'
				when lower(p.url) like 'www.it.boats%' then 'IT'
				when lower(p.url) like 'www.nl.boats%' then 'NL'
				when lower(p.url) like 'www.uk.boats%' then 'UK'
				when lower(p.url) like 'www.us.boats%' then 'DOMESTIC'
				when lower(p.url) like 'www.yachtworld.com/au%' then 'AU'
				when lower(p.url) like 'www.yachtworld.com/de%' then 'DE'
				when lower(p.url) like 'www.yachtworld.com/dk%' then 'DK'
				when lower(p.url) like 'www.yachtworld.com/e/%' then 'E'
				when lower(p.url) like 'www.yachtworld.com/en%' then 'DOMESTIC'
				when lower(p.url) like 'www.yachtworld.com/es%' then 'ES'
				when lower(p.url) like 'www.yachtworld.com/fi%' then 'FI'
				when lower(p.url) like 'www.yachtworld.com/fr%' then 'FR'
				when lower(p.url) like 'www.yachtworld.com/gb%' then 'UK'
				when lower(p.url) like 'www.yachtworld.com/it%' then 'IT'
				when lower(p.url) like 'www.yachtworld.com/nl%' then 'NL'
				when lower(p.url) like 'www.yachtworld.com/no%' then 'NO'
				when lower(p.url) like 'www.yachtworld.com/ru%' then 'RU'
				when lower(p.url) like 'www.yachtworld.com/t/%' then 'T'
				when lower(p.url) like 'www.yachtworld.com/uk%' then 'UK'
				when lower(p.url) like 'www.yachtworldcharters.com%' then 'YWCHART'
				when lower(p.url) like 'www.yachtworld.com/se/%' then 'SE'
				when lower(p.url) like 'www.boats.com/en%' then 'DOMESTIC'
				when lower(p.url) like 'www.boats.com/e/%' then 'E'
				when lower(p.url) like 'www.yachtworld.com/us/%' then 'DOMESTIC'
				when lower(p.url) like 'www.yachtworld.com/n/%' then 'N'
				when lower(p.url) like 'www.yachtworld.com/s/%' then 'S'
				when lower(p.url) like 'www.yachtworld.com/dn/%' then 'DN'
				when lower(p.url) like 'www.boats.com/gb/%' then 'UK'
				when lower(p.url) like 'www.boats.com/de/%' then 'DE'
				when lower(p.url) like 'www.yachtworld.com/sv/%' then 'SV'
				when lower(p.url) like 'www.boats.com/au/%' then 'AU'
				when lower(p.url) like 'www.yachtworld.com/r/%' then 'R'
				when lower(p.url) like 'www.boats.com/ca/%' then 'CA'
				ELSE 'OTHER'
			END site_country,
			CASE
				WHEN lower(p.url) like 'www.boattrader.com%' then 'BT'
				WHEN lower(p.url) like '%yacht%' then 'YW'
				WHEN lower(p.url) like '%boats.com%' then 'BC'
				WHEN lower(p.url) like '%boatwizard%' then 'BOATWIZARD'
				ELSE 'OTHER'
			END portal
			
			
			from "oasdelbypagepos" p
			
            --WHERE TO_DATE(p."date",'YYYY-MM-DD') between (select max(TO_DATE("date",'YYYY-MM-DD')) - 7 from "oasdelbypagepos") and (select max(TO_DATE("date",'YYYY-MM-DD')) from "oasdelbypagepos")
  			--and
			where
  			CASE
                WHEN lower(p.url) like 'www.boattrader.com%' then 'BT'
                WHEN lower(p.url) like '%yacht%' then 'YW'
                WHEN lower(p.url) like '%boats.com%' then 'BC'
                WHEN lower(p.url) like '%boatwizard%' then 'BOATWIZARD'
                ELSE 'OTHER'
            END <> 'OTHER'
		) y
	
	--where to_char(y.event_date,'YYYY-MM-DD') = '2016-02-12'
	--and y.campaign = '27822-1_13237_BluewaterYacht_BTOL-SR-RT2-300x250_CC_T3_JanThrJul'
	group by
	y.campaign, y.event_date, cast(y.pos||'-'||y.site_section||'-'||y.portal as varchar(100))
) pos
on geo.campaign = pos.campaign and geo.event_date = pos.event_date;

insert into state_country_fact_alldata

select
cast(pos.campaign||'-'||to_char(pos.event_date,'YYYY-MM-DD')||'-'||geo.geography||'-'||pos.id as VARCHAR(500)) AS scf_id,
pos.campaign as scf_campaign_id, pos.event_date as scf_event_date, geo.geography as scf_geography_id, 
geo.impression_attribution as scf_impression_attribution, geo.click_attribution as scf_click_attribution,
pos.id as scf_pos_id, pos.impressions as scf_pos_impressions, pos.clicks as scf_pos_clicks,
geo.impression_attribution*pos.impressions as scf_est_impressions,
geo.click_attribution*pos.clicks as scf_est_clicks

from
(
	select x.campaign, to_date(x."date",'YYYY-MM-DD') as event_date, x.geography, 
	case
		when sum(x.impressions) over(partition by campaign,"date") = 0 then 0
		else x.impressions/sum(x.impressions) over(partition by campaign,"date")
	end impression_attribution, 
	case 
		when sum(x.clicks) over(partition by campaign,"date") = 0 then 0
		else x.clicks/sum(x.clicks) over(partition by campaign,"date")
	end click_attribution
	
	from
	(
		SELECT campaign,"date",geography, impressions::decimal(15,6) as impressions, clicks::decimal(15,6) as clicks
		FROM "oasdelbystate"
		where geography like 'US%' or geography like 'CA%'
        --and TO_DATE("date",'YYYY-MM-DD') between (select max(TO_DATE("date",'YYYY-MM-DD')) - 7 from "oasdelbystate") and (select max(TO_DATE("date",'YYYY-MM-DD')) from "oasdelbystate")
		
		union all
			
		SELECT campaign, "date", geography, impressions::decimal(15,6) as impressions, clicks::decimal(15,6) as clicks
		FROM "oasdelbycountry"
		where geography not in ('United States Of America','Canada')
        --and TO_DATE("date",'YYYY-MM-DD') between (select max(TO_DATE("date",'YYYY-MM-DD')) - 7 from "oasdelbystate") and (select max(TO_DATE("date",'YYYY-MM-DD')) from "oasdelbystate")
	) x
	--where x."date" = '2016-02-12'
	--and x.campaign = '27822-1_13237_BluewaterYacht_BTOL-SR-RT2-300x250_CC_T3_JanThrJul'
) geo
join
(
	select
	y.campaign, y.event_date, cast(y.pos||'-'||y.site_section||'-'||y.portal as varchar(100))  id,
	sum(y.impressions) as impressions, sum(y.clicks) as clicks
	from
	(
		SELECT campaign, TO_DATE("date",'YYYY-MM-DD') as event_date, impressions::decimal(15,6) as impressions, clicks::decimal(15,6) as clicks,
			p.pos,
			case 
				when p.url in ('www.yachtworld.com/en/boatsearch.html', 'www.boattrader.com/find/search.php', 'www.us.boats.com/advsearch.html', 
				'www.yachtworld.com/au/boatsearch.html', 'www.yachtworld.com/au/directory.html', 'www.yachtworld.com/de/boatsearch.html', 
				'www.yachtworld.com/de/directory.html', 'www.yachtworld.com/dk/boatsearch.html', 'www.yachtworld.com/dk/directory.html', 
				'www.yachtworld.com/es/boatsearch.html', 'www.yachtworld.com/es/directory.html', 'www.yachtworld.com/fi/boatsearch.html', 
				'www.yachtworld.com/fi/directory.html', 'www.yachtworld.com/fr/boatsearch.html', 'www.yachtworld.com/fr/directory.html', 
				'www.yachtworld.com/gb/boatsearch.html', 'www.yachtworld.com/gb/directory.html', 'www.yachtworld.com/it/boatsearch.html', 
				'www.yachtworld.com/it/directory.html', 'www.yachtworld.com/nl/boatsearch.html', 'www.yachtworld.com/nl/directory.html', 
				'www.yachtworld.com/no/boatsearch.html', 'www.yachtworld.com/no/directory.html', 'www.yachtworld.com/ru/boatsearch.html', 
				'www.yachtworld.com/ru/directory.html', 'www.yachtworld.com/se/boatsearch.html', 'www.yachtworld.com/se/directory.html', 
				'www.au.boats.com/advsearch.html', 'www.ca.boats.com/advsearch.html', 'www.de.boats.com/advsearch.html', 'www.es.boats.com/advsearch.html', 
				'www.fr.boats.com/advsearch.html', 'www.it.boats.com/advsearch.html', 'www.nl.boats.com/advsearch.html', 'www.uk.boats.com/advsearch.html')
				then 'ADVSR'
				when lower(p.url) like '%browse%' then 'BR'
				when lower(p.url) like '%detail%' then 'DT'
				when lower(p.url) like '%/resources%' then 'RES'
				when lower(p.url) like '%search%' then 'SR'
				when lower(p.url) like '%page%' then 'HOME'
				when lower(p.url) like '%com' then 'HOME'
				when lower(p.url) like '%www.boattrader.com/find/dealers/main.php%' then 'BR'
				when lower(p.url) like '%myt/listings.php' then 'DT'
				when lower(p.url) like '%engine%' then 'ENG'
				when lower(p.url) like '%features%' then 'FEATURES'
				when lower(p.url) like '%insurance%' then 'INSURANCE'
				when lower(p.url) like '%directory%' then 'RES'
				when lower(p.url) like '%fsbo%' then 'RES'
				when lower(p.url) like '%pbs%' then 'RES'
				when lower(p.url) like '%transport%' then 'TRANSPORT'
				else 'OTHER'
			end site_section,
			case
				when lower(p.url) like 'm%' then 'MOBILE'
				when lower(p.url) like 'www.au.boats%' then 'AU'
				when lower(p.url) like '%com' then 'DOMESTIC'
				when lower(p.url) like 'www.boats.com/en/%' then 'DOMESTIC'
				when lower(p.url) like 'www.boattrader.com%' then 'DOMESTIC'
				when lower(p.url) like 'www.ca.boats%' then 'CA'
				when lower(p.url) like 'www.de.boats%' then 'DE'
				when lower(p.url) like 'www.es.boats%' then 'ES'
				when lower(p.url) like 'www.fr.boats%' then 'FR'
				when lower(p.url) like 'www.it.boats%' then 'IT'
				when lower(p.url) like 'www.nl.boats%' then 'NL'
				when lower(p.url) like 'www.uk.boats%' then 'UK'
				when lower(p.url) like 'www.us.boats%' then 'DOMESTIC'
				when lower(p.url) like 'www.yachtworld.com/au%' then 'AU'
				when lower(p.url) like 'www.yachtworld.com/de%' then 'DE'
				when lower(p.url) like 'www.yachtworld.com/dk%' then 'DK'
				when lower(p.url) like 'www.yachtworld.com/e/%' then 'E'
				when lower(p.url) like 'www.yachtworld.com/en%' then 'DOMESTIC'
				when lower(p.url) like 'www.yachtworld.com/es%' then 'ES'
				when lower(p.url) like 'www.yachtworld.com/fi%' then 'FI'
				when lower(p.url) like 'www.yachtworld.com/fr%' then 'FR'
				when lower(p.url) like 'www.yachtworld.com/gb%' then 'UK'
				when lower(p.url) like 'www.yachtworld.com/it%' then 'IT'
				when lower(p.url) like 'www.yachtworld.com/nl%' then 'NL'
				when lower(p.url) like 'www.yachtworld.com/no%' then 'NO'
				when lower(p.url) like 'www.yachtworld.com/ru%' then 'RU'
				when lower(p.url) like 'www.yachtworld.com/t/%' then 'T'
				when lower(p.url) like 'www.yachtworld.com/uk%' then 'UK'
				when lower(p.url) like 'www.yachtworldcharters.com%' then 'YWCHART'
				when lower(p.url) like 'www.yachtworld.com/se/%' then 'SE'
				when lower(p.url) like 'www.boats.com/en%' then 'DOMESTIC'
				when lower(p.url) like 'www.boats.com/e/%' then 'E'
				when lower(p.url) like 'www.yachtworld.com/us/%' then 'DOMESTIC'
				when lower(p.url) like 'www.yachtworld.com/n/%' then 'N'
				when lower(p.url) like 'www.yachtworld.com/s/%' then 'S'
				when lower(p.url) like 'www.yachtworld.com/dn/%' then 'DN'
				when lower(p.url) like 'www.boats.com/gb/%' then 'UK'
				when lower(p.url) like 'www.boats.com/de/%' then 'DE'
				when lower(p.url) like 'www.yachtworld.com/sv/%' then 'SV'
				when lower(p.url) like 'www.boats.com/au/%' then 'AU'
				when lower(p.url) like 'www.yachtworld.com/r/%' then 'R'
				when lower(p.url) like 'www.boats.com/ca/%' then 'CA'
				ELSE 'OTHER'
			END site_country,
			CASE
				WHEN lower(p.url) like 'www.boattrader.com%' then 'BT'
				WHEN lower(p.url) like '%yacht%' then 'YW'
				WHEN lower(p.url) like '%boats.com%' then 'BC'
				WHEN lower(p.url) like '%boatwizard%' then 'BOATWIZARD'
				ELSE 'OTHER'
			END portal
			
			
			from "oasdelbypagepos" p
			
          --  WHERE TO_DATE(p."date",'YYYY-MM-DD') between (select max(TO_DATE("date",'YYYY-MM-DD')) - 7 from "oasdelbypagepos") and (select max(TO_DATE("date",'YYYY-MM-DD')) from "oasdelbypagepos")
  			--and 
  			where
			CASE
                WHEN lower(p.url) like 'www.boattrader.com%' then 'BT'
                WHEN lower(p.url) like '%yacht%' then 'YW'
                WHEN lower(p.url) like '%boats.com%' then 'BC'
                WHEN lower(p.url) like '%boatwizard%' then 'BOATWIZARD'
                ELSE 'OTHER'
            END <> 'OTHER'
		) y
	
	--where to_char(y.event_date,'YYYY-MM-DD') = '2016-02-12'
	--and y.campaign = '27822-1_13237_BluewaterYacht_BTOL-SR-RT2-300x250_CC_T3_JanThrJul'
	group by
	y.campaign, y.event_date, cast(y.pos||'-'||y.site_section||'-'||y.portal as varchar(100))
) pos
on geo.campaign = pos.campaign and geo.event_date = pos.event_date;

create table device_fact as

select
pos.campaign, 
pos.event_date, 
device.device_type, 
device.impression_attribution, 
device.click_attribution,
pos.id, 
pos.impressions, 
pos.clicks,
device.impression_attribution*pos.impressions as est_impressions,
device.click_attribution*pos.clicks as est_clicks

from
(
	SELECT
	cat_device.campaign, 
	to_date(cat_device."date",'YYYY-MM-DD') as event_date,
	--cat_device.device, 
	cat_device.device_type,
	case
        when sum(cat_device.impressions) over(partition by cat_device.campaign,cat_device."date") = 0 then 0
        else cat_device.impressions/sum(cat_device.impressions) over(partition by cat_device.campaign,cat_device."date")
    end impression_attribution, 
    case 
        when sum(cat_device.clicks) over(partition by cat_device.campaign,cat_device."date") = 0 then 0
        else cat_device.clicks/sum(cat_device.clicks) over(partition by cat_device.campaign,cat_device."date")
    end click_attribution
	
	FROM
	(
		SELECT
		sum_device.campaign, sum_device."date", sum_device.device_type,
		sum(impressions) impressions, sum(clicks) clicks
		FROM
		(
			SELECT 
			a.campaign, 
			a."date", 
			a.device, 
			case
				when a.device = 'Apple-iPad-1826129' then 'Tablet'
				when a.device = 'Apple-iPhone-205202' then 'Mobile'
				when a.device = ' Other ' then 'other'
				when a.device = 'Verizon-SM-G900V-6520117' then 'Mobile'
				when a.device = 'Verizon-SM-G920V-8528026' then 'Mobile'
				when a.device = 'Unknown-Generic Windows RT Tablet-6063629' then 'Tablet'
				when a.device = 'Samsung-GT-P5210-5265958' then 'Tablet'
				when a.device = 'Verizon-SM-N920V-9849387' then 'Mobile'
				when a.device = 'Verizon-SM-N910V-7189547' then 'Mobile'
				when a.device = 'Verizon-XT1585-10518887' then 'Mobile'
				when a.device = 'T-SM-G900A-6591387' then 'Mobile'
				when a.device = 'Verizon-SCH-I545-4726133' then 'Mobile'
				when a.device = 'Samsung-GT-N8013-3821292' then 'Tablet'
				when a.device = 'T-SM-G890A-8971648' then 'Mobile'
				when a.device = 'Motorola-XT1080-5360393' then 'Mobile'
				when a.device = 'Sprint-SM-G900P-6426147' then 'Mobile'
				when a.device = 'Samsung-GT-P5113-3569912' then 'Tablet'
				when a.device = 'Sprint-SM-G920P-8397491' then 'Mobile'
				when a.device = 'Amazon-Kindle Fire HDX 7-5838088' then 'Tablet'
				when a.device = 'Amazon-Fire (2015)-10285515' then 'Tablet'
				when a.device = 'Samsung-SM-P600-6056446' then 'Tablet'
				when a.device = 'T-SM-G870A-6812251' then 'Mobile'
				when a.device = 'Verizon-QTAQZ3-7395126' then 'Tablet'
				when a.device = 'Samsung-SM-T350-8808269' then 'Tablet'
				when a.device = 'Samsung-SM-G900T-6544783' then 'Mobile'
				when a.device = 'Samsung-SM-N900V-5667196' then 'Mobile'
				when a.device = 'Sprint-SM-N920P-9735230' then 'Mobile'
				when a.device = 'Verizon-Ellipsis 10-10773338' then 'Tablet'
				when a.device = 'Google-Nexus 7-3757846' then 'Tablet'
				when a.device = 'T-SM-T337A-7071735' then 'Tablet'
				when a.device = 'T-SM-N910A-7188709' then 'Mobile'
				when a.device = 'Verizon-SM-G935V-11312161' then 'Mobile'
				when a.device = 'Samsung-SM-N920A-9937987' then 'Mobile'
				when a.device = 'LG-VK700-9192521' then 'Tablet'
				when a.device = 'T-SM-G920A-8255775' then 'Mobile'
				when a.device = 'Samsung-SM-T520-6492636' then 'Tablet'
				when a.device = 'Amazon-Kindle Fire HD 8.9-3970050' then 'Tablet'
				when a.device = 'T-Mobile-SM-N920T-9914211' then 'Mobile'
				when a.device = 'Amazon-Kindle Fire HDX 8.9-7297756' then 'Tablet'
				when a.device = 'Verizon-QMV7B-6941646' then 'Tablet'
				when a.device = 'LG-V410-7071917' then 'Tablet'
				when a.device = 'Amazon-Fire HD 10 (2015)-10285546' then 'Tablet'
				when a.device = 'Verizon-VK810-6381383' then 'Tablet'
				when a.device = 'Samsung-SM-T560NU-10616753' then 'Tablet'
				when a.device = 'RCA Tablets-RCT6303W87DK-9165607' then 'Tablet'
				when a.device = 'Verizon-VS985-6912364' then 'Mobile'
				when a.device = 'T-SGH-I337-4432361' then 'Mobile'
				when a.device = 'Verizon-QMV7A-5994929' then 'Mobile'
				when a.device = 'Sprint-SM-T217S-5622916' then 'Tablet'
				when a.device = 'Sprint-SM-N910P-7189467' then 'Mobile'
				when a.device = 'Sony-PlayStation 4-5788635' then 'other'
				when a.device = 'Samsung-SM-G920T-8256097' then 'Mobile'
				when a.device = 'Amazon-Kindle Fire HD 7 (3rd Gen)-6053864' then 'Tablet'
				when a.device = 'T-SM-N900A-5667577' then 'Mobile'
				when a.device = 'Samsung-SM-P900-6385474' then 'Tablet'
				when a.device = 'Apple-iPod Touch-312415' then 'Tablet'
				when a.device = 'US Cellular-SM-G900R4-6732618' then 'Mobile'
				when a.device = 'Verizon-E6782-6961632' then 'Mobile'
				when a.device = 'T-SM-G930A-11457998' then 'Mobile'
				when a.device = 'Verizon-SM-T817V-9790378' then 'Tablet'
				when a.device = 'T-SM-G935A-11458052' then 'Mobile'
				when a.device = 'Samsung-SM-N900T-5886066' then 'Mobile'
				when a.device = 'Verizon-SM-P905V-6381316' then 'Tablet'
				when a.device = 'Samsung-SM-T700-6941074' then 'Tablet'
				when a.device = 'Lenovo-A10-70F-10440750' then 'Tablet'
				when a.device = 'Barnes and Noble-BNTV600-3933659' then 'Tablet'
				when a.device = 'Samsung-SGH-I497-3965673' then 'Tablet'
				when a.device = 'T-Mobile-SM-G935T-11312494' then 'Mobile'
				when a.device = 'T-Mobile-SM-G930T-11312439' then 'Mobile'
				when a.device = 'Verizon-SM-T807V-7214724' then 'Tablet'
				when a.device = 'T-SM-T807A-7295679' then 'Tablet'
				when a.device = 'LG-VS990-10562160' then 'Mobile'
				when a.device = 'HTC-Desire 626s-9779004' then 'Mobile'
				when a.device = 'LG-VK815-8938447' then 'Tablet'
				when a.device = 'Amazon-Fire HD 6-7297850' then 'Tablet'
				when a.device = 'Samsung-SM-G928T-9937575' then 'Mobile'
				when a.device = 'Samsung-SM-S820L-9108355' then 'Mobile'
				when a.device = 'LG-MS330-11012517' then 'Mobile'
				when a.device = 'Samsung-SM-T710-9874474' then 'Tablet'
				when a.device = 'T-Mobile-SM-G925T-8249547' then 'Mobile'
				when a.device = 'Verizon-SM-G360V-7590516' then 'Mobile'
				when a.device = 'Samsung-SM-G920F-8249406' then 'Mobile'
				when a.device = 'Samsung-SM-T210R-5261160' then 'Tablet'
				when a.device = 'RCA-RCT6203W46-7891276' then 'Tablet'
				when a.device = 'LG-V495-8552577' then 'Tablet'
				when a.device = 'Google-Nexus 6-7324756' then 'Mobile'
				when a.device = 'T-Mobile-SGH-M919-4748479' then 'Mobile'
				when a.device = 'Samsung-SM-G920R4-8628868' then 'Mobile'
				when a.device = 'Samsung-SCH-I535-3551849' then 'Mobile'
				when a.device = 'Samsung-SM-G935F-11312384' then 'Mobile'
				when a.device = 'Samsung-GT-N5110-4748477' then 'Tablet'
				when a.device = 'Verizon-6525LVW-6499199' then 'Tablet'
				when a.device = 'RCA Tablets-RCT6213W87DK-9446168' then 'Tablet'
				when a.device = 'T-Mobile-SM-G530T-9692958' then 'Mobile'
				when a.device = 'Motorola-XT1030-5360423' then 'Mobile'
				when a.device = 'Amazon-Fire HD 8 (2015)-10285606' then 'Tablet'
				when a.device = 'HTC-One M9-8261881' then 'Mobile'
				when a.device = 'LG-LS770-9072582' then 'Mobile'
				when a.device = 'Sprint-SPH-L720-4630353' then 'Mobile'
				when a.device = 'Samsung-GT-P3113-3557729' then 'Tablet'
				when a.device = 'Nextbook-NXA8QC116-9444408' then 'Tablet'
				when a.device = 'Motorola-XT1565-10030064' then 'Mobile'
				when a.device = 'HTC-One M8-6025472' then 'Mobile'
				when a.device = 'Verizon-SCH-I915-3941882' then 'Tablet'
				when a.device = 'T-Mobile-H811-9062566' then 'Mobile'
				when a.device = 'Sprint-LS991-8821117' then 'Mobile'
				when a.device = 'Samsung-SM-G900W8-6731831' then 'Mobile'
				when a.device = 'T-Mobile-H631-9034177' then 'Mobile'
				when a.device = 'Verizon-SM-T567V-10220044' then 'Tablet'
				when a.device = 'Amazon-Fire HDX 8.9-7297971' then 'Tablet'
				when a.device = 'Samsung-SM-S920L-10590905' then 'Mobile'
				when a.device = 'ZTE-Z970-7276213' then 'Mobile'
				when a.device = 'Sprint-SPH-L720T-6684736' then 'Mobile'
				when a.device = 'Samsung-SM-G891A-13813938' then 'Mobile'
				when a.device = 'Samsung-SM-G530T1-10478244' then 'Mobile'
				when a.device = 'Samsung-SM-T805-6833855' then 'Tablet'
				when a.device = 'Google-D820-5845779' then 'Mobile'
				when a.device = 'Motorola-Moto E2-8456724' then 'Mobile'
				when a.device = 'Nokia-RM-974-6953049' then 'Mobile'
				when a.device = 'RCA Tablets-RCT6773W22B-9816251' then 'Tablet'
				when a.device = 'LG-VS980-5475112' then 'Mobile'
				when a.device = 'T-Mobile-SM-P607T-6775810' then 'Tablet'
				when a.device = 'Samsung-SM-G925F-8249500' then 'Tablet'
				when a.device = 'Sprint-LS990-6863821' then 'Mobile'
				when a.device = 'LG-D850-6889278' then 'Mobile'
				when a.device = 'Microsoft-RM-1075-8282906' then 'Mobile'
				when a.device = 'Orange-SM-G930F-11873536' then 'Mobile'
				when a.device = 'Samsung-SM-T555-9538540' then 'Tablet'
				when a.device = 'Samsung-SM-T535-6875782' then 'Tablet'
				when a.device = 'Samsung-SM-S975L-6772271' then 'Mobile'
				when a.device = 'T-Mobile-SM-G386T-7016178' then 'Mobile'
				when a.device = 'HP-Slate 10 HD-6559113' then 'Tablet'
				when a.device = 'LG-H901-10519423' then 'Mobile'
				when a.device = 'Samsung-SM-P550-8973186' then 'Tablet'
				when a.device = 'Toshiba-AT100-2558936' then 'Mobile'
				when a.device = 'HTC-Desire 526-9426787' then 'Mobile'
				when a.device = 'T-Mobile-SM-T357T-10172101' then 'Tablet'
				when a.device = 'Motorola-MZ601-2351866' then 'Tablet'
				when a.device = 'Sprint-SM-G928P-9735117' then 'Mobile'
				when a.device = 'LG-LS665-9687474' then 'Mobile'
				when a.device = 'Samsung-GT-P7510-2541725' then 'Tablet'
				when a.device = 'Samsung-SGH-I337M-5172349' then 'Mobile'
				when a.device = 'Sprint-SM-J320P-10742588' then 'Mobile'
				when a.device = 'Samsung-SM-G360T-9779146' then 'Mobile'
				when a.device = 'Verizon-SGP561-6912401' then 'Tablet'
				when a.device = 'US Cellular-SM-G930R4-11312217' then 'Mobile'
				when a.device = 'Nextbook-NXA116QC164-8710713' then 'Tablet'
				when a.device = 'Samsung-SM-N9005-5619064' then 'Mobile'
				when a.device = 'UNKNOWN' then 'Desktop/UNKNOWN'
				when a.device = 'Samsung-SM-T530nu-7257537' then 'Tablet'
				when a.device = 'Motorola-XT1254-7343532' then 'Mobile'
				when a.device = 'Samsung-SM-T800-6886274' then 'Tablet'
				when a.device = 'Samsung-SM-T550-8807568' then 'Tablet'
				when a.device = 'Samsung-SM-T230NU-6732168' then 'Mobile'
				when a.device = 'Verizon-SM-G930V-11312105' then 'Mobile'
				when a.device = 'Unknown-Generic Android Tablet-3488729' then 'Tablet'
				when a.device = 'Amazon-Kindle Fire HD-3861992' then 'Tablet'
				when a.device = 'Samsung-SM-T810-9790490' then 'Tablet'
				when a.device = 'Samsung-SM-T320-6845950' then 'Tablet'
				when a.device = 'Samsung-SM-T900-6528597' then 'Tablet'
				when a.device = 'Unknown-Generic Android Mobile-2887676' then 'Mobile'
				when a.device = 'Amazon-Fire HD 7-7297888' then 'Tablet'
				when a.device = 'Amazon-Kindle Fire-2891950' then 'Tablet'
				when a.device = 'Samsung-SM-G928V-9937525' then 'Mobile'
				when a.device = 'T-Mobile-SM-N910T-7189390' then 'Mobile'
				when a.device = 'Verizon-SM-G925V-8528057' then 'Mobile'
				when a.device = 'LG-VS986-8938539' then 'Mobile'
				when a.device = 'Verizon-SM-T537V-6941534' then 'Tablet'
				when a.device = 'Sprint-SM-G930P-11311937' then 'Mobile'
				when a.device = 'Samsung-SM-T310-5564593' then 'Tablet'
				when a.device = 'Google-Nexus 10-3918712' then 'Tablet'
				when a.device = 'Samsung-SM-G900F-6544691' then 'Mobile'
				when a.device = 'Samsung-SM-T330NU-6844570' then 'Tablet'
				when a.device = 'LG-MS631-9165531' then 'Mobile'
				when a.device = 'Samsung-SM-G530AZ-8599914' then 'Mobile'
				when a.device = 'Samsung-SM-T530-6779440' then 'Tablet'
				when a.device = 'Samsung-SM-N900P-5617259' then 'Mobile'
				when a.device = 'Samsung-SM-G360T1-9562653' then 'Mobile'
				when a.device = 'Samsung-SM-T110-6380849' then 'Tablet'
				when a.device = 'Samsung-SM-G925A-8256189' then 'Mobile'
				when a.device = 'LG-MS345-9118287' then 'Mobile'
				when a.device = 'Sprint-SM-G935P-11311881' then 'Mobile'
				when a.device = 'T-SM-G928A-9769177' then 'Mobile'
				when a.device = 'Gigaset-QV830-6871076' then 'Tablet'
				when a.device = 'Sprint-SM-G925P-8397551' then 'Mobile'
				when a.device = 'Samsung-SCH-I925-4008756' then 'Tablet'
				when a.device = 'T-SM-T677A-10810578' then 'Tablet'
				when a.device = 'US Cellular-SCH-R970-5111768' then 'Mobile'
				when a.device = 'Google-Nexus 6P-10220674' then 'Mobile'
				when a.device = 'T-SGH-I537-5261008' then 'Mobile'
				when a.device = 'Samsung-SCH-S968C-6285686' then 'Mobile'
				when a.device = 'Google-Nexus 9-7324786' then 'Tablet'
				when a.device = 'BlackBerry-Q10-4097069' then 'Mobile'
				when a.device = 'Motorola-Moto G (3rd Gen)-9766046' then 'Mobile'
				when a.device = 'Sprint-SM-G860P-6863915' then 'Mobile'
				when a.device = 'Sprint-SM-T237P-6994530' then 'Tablet'
				when a.device = 'Microsoft-XBOX One-6329158' then 'other'
				when a.device = 'LG-VK410-9192670' then 'Tablet'
				when a.device = 'Unknown-Smart TV-6375086' then 'other'
				when a.device = 'HTC-One-4116964' then 'Mobile'
				when a.device = 'Verizon-XT907-3855603' then 'Mobile'
				when a.device = 'Cricket-H634-9874891' then 'Mobile'
				when a.device = 'LG-LS675-10778814' then 'Mobile'
				when a.device = 'T-SM-T537A-6926311' then 'Tablet'
				when a.device = 'T-SGH-I747-3603954' then 'Mobile'
				when a.device = 'Samsung-GT-N8010-3756811' then 'Tablet'
				when a.device = 'Samsung-GT-N8000-3756467' then 'Tablet'
				when a.device = 'Samsung-SM-G920I-8249453' then 'Mobile'
				when a.device = 'BlackBerry-Z10-3947909' then 'Mobile'
				when a.device = 'Samsung-SM-T560-10219962' then 'Tablet'
				when a.device = 'Samsung-SM-N915V-7386776' then 'Mobile'
				when a.device = 'Motorola-XT1032-5809528' then 'Mobile'
				when a.device = 'T-9020A-10327130' then 'Mobile'
				when a.device = 'Sony-SGP771-9574309' then 'Tablet'
				when a.device = 'Sprint-XT1031-6304122' then 'Mobile'
				when a.device = 'LG-LS740-6845823' then 'Mobile'
				when a.device = 'Motorola-XT1528-8763855' then 'Mobile'
				when a.device = 'Samsung-SGH-I467-5261140' then 'Tablet'
				when a.device = 'Lenovo-1050F-7478637' then 'Tablet'
				when a.device = 'Motorola-MZ617-3248887' then 'Tablet'
				when a.device = 'LG-MS395-7508568' then 'Mobile'
				when a.device = 'Samsung-SM-T705-6954391' then 'Tablet'
				when a.device = 'T-SM-P907A-6973158' then 'Tablet'
				when a.device = 'LG-LS775-12501033' then 'Mobile'
				when a.device = 'Kyocera-E6560-7563778' then 'Mobile'
				when a.device = 'Samsung-SM-T707A-7450956' then 'Tablet'
				when a.device = 'Acer-A500-2434036' then 'Tablet'
				when a.device = 'US Cellular-SM-N920R4-10002324' then 'Mobile'
				when a.device = 'Samsung-SM-T537R4-7072041' then 'Tablet'
				when a.device = 'Samsung-SM-T533-8850824' then 'Mobile'
				when a.device = 'Samsung-SM-G900R7-6775734' then 'Mobile'
				when a.device = 'Samsung-GT-I9300-3597327' then 'Mobile'
				when a.device = 'Amazon-Kindle Fire HDX 8.9 LTE-5838109' then 'Tablet'
				when a.device = 'Sprint-SM-N930P-13940507' then 'Mobile'
				when a.device = 'Samsung-SM-T531-6871266' then 'Tablet'
				when a.device = 'Straight Talk-L62VL-12956475' then 'Mobile'
				when a.device = 'Lenovo-A7600-H-6715181' then 'Tablet'
				when a.device = 'OnePlus-A0001-7053235' then 'Mobile'
				when a.device = 'Samsung-SM-T210-5259597' then 'Tablet'
				when a.device = 'Sprint-SM-T377P-10468226' then 'Tablet'
				when a.device = 'Sony-SGP712-9574720' then 'Tablet'
				when a.device = 'Lenovo-1380F-8250207' then 'Mobile'
				when a.device = 'Samsung-SM-T561-9444698' then 'Tablet'
				when a.device = 'Samsung-GT-P6210-3737488' then 'Tablet'
				when a.device = 'Samsung-SM-T113-8415178' then 'Tablet'
				when a.device = 'Hisense-M470BSA-5289023' then 'Tablet'
				when a.device = 'Samsung-GT-N7100-3901793' then 'Mobile'
				when a.device = 'Asus-TF201-3452628' then 'Tablet'
				when a.device = 'Barnes and Noble-BNTV250-3948146' then 'Tablet'
				when a.device = 'Lenovo-A8-50LC-10465113' then 'Tablet'
				when a.device = 'Sony-SGP312-4733515' then 'Tablet'
				when a.device = 'Samsung-SM-T805W-8381721' then 'Tablet'
				when a.device = 'Samsung-SM-G850F-7250953' then 'Mobile'
				when a.device = 'LG-H812-9100715' then 'Mobile'
				when a.device = 'Lenovo-A8-50F-10461602' then 'Tablet'
				when a.device = 'Lenovo-B8000-H-7257330' then 'Tablet'
				when a.device = 'Lenovo-S8-50F-7597651' then 'Tablet'
				when a.device = 'Microsoft-XBOX 360-4072778' then 'other'
				when a.device = 'Samsung-GT-N5100-4354740' then 'Tablet'
				when a.device = 'Lenovo-B8080-F-6913584' then 'Tablet'
				when a.device = 'Unknown-L102-3601196' then 'Mobile'
				when a.device = 'HP-TouchPad-2388211' then 'Tablet'
				when a.device = 'Dragon Touch-A1X Plus-8250533' then 'Tablet'
				when a.device = 'Sprint-AQT80-9986309' then 'Tablet'
				when a.device = 'Sony-SGPT12-3854673' then 'Tablet'
				when a.device = 'Samsung-SM-G361F-9692850' then 'Mobile'
				when a.device = 'LG-LS751-9653103' then 'Mobile'
				when a.device = 'Samsung-GT-N8005-4558714' then 'Tablet'
				when a.device = 'Samsung-SM-T311-5316765' then 'Tablet'
				when a.device = 'Insignia-NS-14T004-6322531' then 'Tablet'
				when a.device = 'Asus-P008-14168266' then 'Mobile'
				when a.device = 'T-SGH-I317-3951865' then 'Tablet'
				when a.device = 'Samsung-SGH-T889-3935423' then 'Mobile'
				when a.device = 'Microsoft-RM-1118-10395257' then 'Mobile'
				when a.device = 'T-SGH-I547-4099642' then 'Mobile'
				when a.device = 'Acer-A700-3431972' then 'Tablet'
				when a.device = 'bq-Edison 3-7437972' then 'Tablet'
				when a.device = 'Acer-B1-810-7536909' then 'Tablet'
				when a.device = 'Acer-A1-840FHD-7133885' then 'Tablet'
				when a.device = 'Runbo-X5-5827908' then 'Mobile'
				when a.device = 'Samsung-SM-T315-5564616' then 'Tablet'
				when a.device = 'Samsung-SM-T715Y-10189089' then 'Tablet'
				when a.device = 'Samsung-SM-Z910F-10559563' then 'Mobile'
				when a.device = 'Insignia-NS-15T8LTE-9759306' then 'Tablet'
				when a.device = 'Sony-E6853-10634789' then 'Mobile'
				when a.device = 'LG-L22C-10777979' then 'Mobile'
				when a.device = 'Samsung-SM-G928C-9937625' then 'Mobile'
				when a.device = 'Alcatel-6045O-10634837' then 'Mobile'
				when a.device = 'Samsung-SCH-R890-6168936' then 'Mobile'
				when a.device = 'Acer-A1-850-8586155' then 'Tablet'
				when a.device = 'Archos-101 Cobalt-6409332' then 'Tablet'
				when a.device = 'Samsung-SM-P602-6314577' then 'Mobile'
				when a.device = 'Contixo-Q102-7791202' then 'Mobile'
				when a.device = 'Motorola-XT1064-7271672' then 'Mobile'
				when a.device = 'DigiLand-DL700D-6898603' then 'Tablet'
				when a.device = 'Samsung-SM-T325-6304165' then 'Mobile'
				when a.device = 'Motorola-XT1055-5684918' then 'Mobile'
				when a.device = 'Lenovo-B8080-H-10498912' then 'Tablet'
				when a.device = 'Le Pan-TC1020-10650638' then 'Tablet'
				when a.device = 'Samsung-SM-T357W-10377498' then 'Tablet'
				when a.device = 'LG-D725-7314863' then 'Mobile'
				when a.device = 'Medion-S1033X-7314817' then 'Tablet'
				when a.device = 'HP-8-6773241' then 'other'
				when a.device = 'Huawei-H60-L04-7297271' then 'Mobile'
				when a.device = 'Insignia-NS-15AT10-7498453' then 'Tablet'
				when a.device = 'Hip Street-HS_9DTB37-8028796' then 'Tablet'
				when a.device = 'Azpen-A1040-8028659' then 'Tablet'
				when a.device = 'LG-K373-13016223' then 'Mobile'
				when a.device = 'ZTE-Z988-13814026' then 'Mobile'
				when a.device = 'Curtis-LT7035-6782938' then 'Tablet'
				when a.device = 'Vodafone-VF-1497-9492766' then 'Mobile'
				when a.device = 'LG-H955-8532935' then 'Mobile'
				when a.device = 'Cubot-X9-11426551' then 'Mobile'
				when a.device = 'Trio-7.85 vQ-9652739' then 'Tablet'
				when a.device = 'HTC-Desire 620-8456327' then 'Mobile'
				when a.device = 'US Cellular-SM-G800R4-7712908' then 'Mobile'
				when a.device = 'Samsung-SM-A700FD-7772973' then 'Mobile'
				when a.device = 'Sprint-SPH-L520-5882593' then 'Mobile'
				when a.device = 'ZTE-Z932L-7508804' then 'Mobile'
				when a.device = 'Lenovo-A7000-a-8960340' then 'Mobile'
				when a.device = 'Lenovo-IdeaPad K1-2921654' then 'Tablet'
				when a.device = 'Samsung-SGH-T989-2902280' then 'Mobile'
				when a.device = 'Samsung-SCH-i545L-9816201' then 'Mobile'
				when a.device = 'Alcatel-P320X-6844047' then 'Tablet'
				when a.device = 'Sony-C2105-5109326' then 'Mobile'
				when a.device = 'Alcatel-4037T-7246666' then 'Mobile'
				when a.device = 'Coolpad-5560S-7547671' then 'Tablet'
				when a.device = 'Samsung-GT-P7500M-8670005' then 'Tablet'
				when a.device = 'HTC-Desire 526G Plus-8068052' then 'Mobile'
				when a.device = 'Samsung-SCH-I800-2913227' then 'Tablet'
				when a.device = 'ZTE-Z752C-9072628' then 'Mobile'
				when a.device = 'LG-F500S-9100828' then 'Mobile'
				when a.device = 'Coby-MID1042-3812456' then 'Tablet'
				when a.device = 'HTC-One S-3406146' then 'Mobile'
				when a.device = 'Mediacom-M-IPRO10-13900270' then 'Tablet'
				when a.device = 'Alcatel-5038A-7412462' then 'Mobile'
				when a.device = 'Prestigio-PMP5101C Quad-6404648' then 'Tablet'
				when a.device = 'bq-Elcano 2-8472157' then 'Tablet'
				when a.device = 'Samsung-SGH-T889V-3965675' then 'Mobile'
				when a.device = 'MediaCom-M-MP1040S2-6118559' then 'Tablet'
				when a.device = 'Trinity-T900-10304695' then 'Tablet'
				when a.device = 'Wolder-miTab Houston-8614760' then 'Tablet'
				when a.device = 'KDDI-SCL22-5884231' then 'Mobile'
				when a.device = 'Fly-IQ235-3837586' then 'Tablet'
				when a.device = 'Huawei-Y520-U03-8156671' then 'Tablet'
				when a.device = 'T-SM-C105A-6020008' then 'Mobile'
				when a.device = 'Samsung-GT-S5570i-4643742' then 'Tablet'
				when a.device = 'LG-E989-6372314' then 'Tablet'
				ELSE 'not categorized'
			end device_type,
			a.impressions::decimal(15,6),
			a.clicks::decimal(15,6)
			FROM oas_delbydevice a
			--where a."date" = '2016-02-12'
	    	--and a.campaign = '27822-1_13237_BluewaterYacht_BTOL-SR-RT2-300x250_CC_T3_JanThrJul'
	    ) sum_device
	    group by sum_device.campaign, sum_device."date", sum_device.device_type
	) cat_device
) device
join
(
    select
    y.campaign, y.event_date, cast(y.pos||'-'||y.site_section||'-'||y.portal as varchar(100))  id,
    sum(y.impressions) as impressions, sum(y.clicks) as clicks
    from
    (
        SELECT campaign, TO_DATE("date",'YYYY-MM-DD') as event_date, impressions::decimal(15,6) as impressions, clicks::decimal(15,6) as clicks,
            p.pos,
            case 
                when p.url in ('www.yachtworld.com/en/boatsearch.html', 'www.boattrader.com/find/search.php', 'www.us.boats.com/advsearch.html', 
                'www.yachtworld.com/au/boatsearch.html', 'www.yachtworld.com/au/directory.html', 'www.yachtworld.com/de/boatsearch.html', 
                'www.yachtworld.com/de/directory.html', 'www.yachtworld.com/dk/boatsearch.html', 'www.yachtworld.com/dk/directory.html', 
                'www.yachtworld.com/es/boatsearch.html', 'www.yachtworld.com/es/directory.html', 'www.yachtworld.com/fi/boatsearch.html', 
                'www.yachtworld.com/fi/directory.html', 'www.yachtworld.com/fr/boatsearch.html', 'www.yachtworld.com/fr/directory.html', 
                'www.yachtworld.com/gb/boatsearch.html', 'www.yachtworld.com/gb/directory.html', 'www.yachtworld.com/it/boatsearch.html', 
                'www.yachtworld.com/it/directory.html', 'www.yachtworld.com/nl/boatsearch.html', 'www.yachtworld.com/nl/directory.html', 
                'www.yachtworld.com/no/boatsearch.html', 'www.yachtworld.com/no/directory.html', 'www.yachtworld.com/ru/boatsearch.html', 
                'www.yachtworld.com/ru/directory.html', 'www.yachtworld.com/se/boatsearch.html', 'www.yachtworld.com/se/directory.html', 
                'www.au.boats.com/advsearch.html', 'www.ca.boats.com/advsearch.html', 'www.de.boats.com/advsearch.html', 'www.es.boats.com/advsearch.html', 
                'www.fr.boats.com/advsearch.html', 'www.it.boats.com/advsearch.html', 'www.nl.boats.com/advsearch.html', 'www.uk.boats.com/advsearch.html')
                then 'ADVSR'
                when lower(p.url) like '%browse%' then 'BR'
                when lower(p.url) like '%detail%' then 'DT'
                when lower(p.url) like '%/resources%' then 'RES'
                when lower(p.url) like '%search%' then 'SR'
                when lower(p.url) like '%page%' then 'HOME'
                when lower(p.url) like '%com' then 'HOME'
                when lower(p.url) like '%www.boattrader.com/find/dealers/main.php%' then 'BR'
                when lower(p.url) like '%myt/listings.php' then 'DT'
                when lower(p.url) like '%engine%' then 'ENG'
                when lower(p.url) like '%features%' then 'FEATURES'
                when lower(p.url) like '%insurance%' then 'INSURANCE'
                when lower(p.url) like '%directory%' then 'RES'
                when lower(p.url) like '%fsbo%' then 'RES'
                when lower(p.url) like '%pbs%' then 'RES'
                when lower(p.url) like '%transport%' then 'TRANSPORT'
                else 'OTHER'
            end site_section,
            case
                when lower(p.url) like 'm%' then 'MOBILE'
                when lower(p.url) like 'www.au.boats%' then 'AU'
                when lower(p.url) like '%com' then 'DOMESTIC'
                when lower(p.url) like 'www.boats.com/en/%' then 'DOMESTIC'
                when lower(p.url) like 'www.boattrader.com%' then 'DOMESTIC'
                when lower(p.url) like 'www.ca.boats%' then 'CA'
                when lower(p.url) like 'www.de.boats%' then 'DE'
                when lower(p.url) like 'www.es.boats%' then 'ES'
                when lower(p.url) like 'www.fr.boats%' then 'FR'
                when lower(p.url) like 'www.it.boats%' then 'IT'
                when lower(p.url) like 'www.nl.boats%' then 'NL'
                when lower(p.url) like 'www.uk.boats%' then 'UK'
                when lower(p.url) like 'www.us.boats%' then 'DOMESTIC'
                when lower(p.url) like 'www.yachtworld.com/au%' then 'AU'
                when lower(p.url) like 'www.yachtworld.com/de%' then 'DE'
                when lower(p.url) like 'www.yachtworld.com/dk%' then 'DK'
                when lower(p.url) like 'www.yachtworld.com/e/%' then 'E'
                when lower(p.url) like 'www.yachtworld.com/en%' then 'DOMESTIC'
                when lower(p.url) like 'www.yachtworld.com/es%' then 'ES'
                when lower(p.url) like 'www.yachtworld.com/fi%' then 'FI'
                when lower(p.url) like 'www.yachtworld.com/fr%' then 'FR'
                when lower(p.url) like 'www.yachtworld.com/gb%' then 'UK'
                when lower(p.url) like 'www.yachtworld.com/it%' then 'IT'
                when lower(p.url) like 'www.yachtworld.com/nl%' then 'NL'
                when lower(p.url) like 'www.yachtworld.com/no%' then 'NO'
                when lower(p.url) like 'www.yachtworld.com/ru%' then 'RU'
                when lower(p.url) like 'www.yachtworld.com/t/%' then 'T'
                when lower(p.url) like 'www.yachtworld.com/uk%' then 'UK'
                when lower(p.url) like 'www.yachtworldcharters.com%' then 'YWCHART'
                when lower(p.url) like 'www.yachtworld.com/se/%' then 'SE'
                when lower(p.url) like 'www.boats.com/en%' then 'DOMESTIC'
                when lower(p.url) like 'www.boats.com/e/%' then 'E'
                when lower(p.url) like 'www.yachtworld.com/us/%' then 'DOMESTIC'
                when lower(p.url) like 'www.yachtworld.com/n/%' then 'N'
                when lower(p.url) like 'www.yachtworld.com/s/%' then 'S'
                when lower(p.url) like 'www.yachtworld.com/dn/%' then 'DN'
                when lower(p.url) like 'www.boats.com/gb/%' then 'UK'
                when lower(p.url) like 'www.boats.com/de/%' then 'DE'
                when lower(p.url) like 'www.yachtworld.com/sv/%' then 'SV'
                when lower(p.url) like 'www.boats.com/au/%' then 'AU'
                when lower(p.url) like 'www.yachtworld.com/r/%' then 'R'
                when lower(p.url) like 'www.boats.com/ca/%' then 'CA'
                ELSE 'OTHER'
            END site_country,
            CASE
                WHEN lower(p.url) like 'www.boattrader.com%' then 'BT'
                WHEN lower(p.url) like '%yacht%' then 'YW'
                WHEN lower(p.url) like '%boats.com%' then 'BC'
                WHEN lower(p.url) like '%boatwizard%' then 'BOATWIZARD'
                ELSE 'OTHER'
            END portal
            
            
            from "oasdelbypagepos" p
            
            WHERE 
              CASE
                WHEN lower(p.url) like 'www.boattrader.com%' then 'BT'
                WHEN lower(p.url) like '%yacht%' then 'YW'
                WHEN lower(p.url) like '%boats.com%' then 'BC'
                WHEN lower(p.url) like '%boatwizard%' then 'BOATWIZARD'
                ELSE 'OTHER'
            END <> 'OTHER'
        ) y
    
    --where to_char(y.event_date,'YYYY-MM-DD') = '2016-02-12'
    --and y.campaign = '27822-1_13237_BluewaterYacht_BTOL-SR-RT2-300x250_CC_T3_JanThrJul'
    group by
    y.campaign, y.event_date, cast(y.pos||'-'||y.site_section||'-'||y.portal as varchar(100))
) pos
on device.campaign = pos.campaign and device.event_date = pos.event_date;