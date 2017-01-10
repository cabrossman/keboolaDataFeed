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