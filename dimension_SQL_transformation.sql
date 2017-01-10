CREATE TABLE campaign_dim (
	campaign_id				varchar(100)	not null sortkey,
	insertion_order 		varchar(100),
	advertiser 				varchar(100),
	salesgroup 				varchar(50),
	campaigngroup  			varchar(100),
	bookedimps 				decimal(15,6),
	bookedclicks 			decimal(15,6),
	priority 				decimal(15,6),
	weight 					decimal(15,6),
	deliveryrate 			varchar(50),
	impoverrun 				decimal(15,6),
	dailyimp 				decimal(15,6),
	start_date 				date,
	end_date 				date,
	inventory_reservation 	varchar(100),
	pages 					varchar(100),
	contracted_revenue 		decimal(15,6),
	billoffcontracted 		varchar(100),
	cpm 					decimal(15,6),
	cpc 					decimal(15,6),
	cpa 					decimal(15,6),
	flatrate 				decimal(15,6),
	currency 				varchar(10),
	billingnotes 			varchar(5000)
) diststyle all;

CREATE TABLE state_country_dim (
	geography_id	varchar(100)	not null sortkey,
	country_name	varchar(100),
	country_code	varchar(10),
	continent		varchar(50),
	state_code		varchar(50),
	marine_area		varchar(50)
) diststyle all;

CREATE TABLE position_dim (
	id				varchar(100)	not null sortkey distkey,
	pos 			varchar(25) 	not null,
	site_section 	varchar(25) 	not null,
	portal			varchar(25)		not null,
  	most_used		int				not null
);

CREATE TABLE dma_geo_dim (
	dma_geo_id				varchar(100)	not null sortkey,
	dma_geography 			varchar(100) 	not null
) diststyle all;

insert into campaign_dim
with w1 as
(

select
case when campaign_id in ('NA','') then null else campaign_id end campaign_id,
case when insertion_order in ('NA','') then null else insertion_order end insertion_order,
case when advertiser in ('NA','') then null else advertiser end advertiser,
case
	when lower(campaign_id) like '%passback%' then 'PASSBACK'
	when lower(campaign_id) = 'default' then 'UNKNOWN_DEFAULT'
	when advertiser = 'HouseAdsTest' then 'KNOWN_DEFAULT'
	when lower(advertiser) like 'ddm%' then 'DDM'
	when advertiser = '00001111' then 'HOUSE'
	ELSE 'MARINE'
END salesgroup,
case when CampaignGroupId in ('NA','') then null else CampaignGroupId end CampaignGroup,
case when bookedImps in ('NA','') then null else bookedImps::decimal(15,6) end bookedImps,
case when bookedClicks in ('NA','') then null else bookedClicks::decimal(15,6) end bookedClicks,
case when priority in ('NA','') then null else priority::decimal(15,6) end priority,
case when weight in ('NA','') then null else weight::decimal(15,6) end weight,
case when DeliveryRate in ('NA','') then null else DeliveryRate end DeliveryRate,
case when ImpOverRun in ('NA','') then null else ImpOverRun::decimal(15,6) end ImpOverRun,
case when DailyImp in ('NA','') then null else DailyImp::decimal(15,6) end DailyImp,
case when start_date in ('NA','') then null else to_date(start_date,'YYYY-MM-DD') end start_date,
case when end_date in ('NA','') then null else to_date(end_date,'YYYY-MM-DD') end end_date,
case when inventory_reservation in ('NA','') then null else inventory_reservation end inventory_reservation,
case when pages in ('NA','') then null else pages end pages,
case when contracted_revenue in ('NA','') then null else contracted_revenue::decimal(15,6) end contracted_revenue,
case when BillOffContracted  in ('NA','') then null else BillOffContracted end BillOffContracted,
case when cpm in ('NA','') then null else cpm::decimal(15,6) end cpm,
case when cpc in ('NA','') then null else cpc::decimal(15,6) end cpc,
case when cpa in ('NA','') then null else cpa::decimal(15,6) end cpa,
case when FlatRate in ('NA','') then null else FlatRate::decimal(15,6) end FlatRate,
case when Currency in ('NA','') then null else Currency end Currency,
case when BillingNotes in ('NA','') then null else BillingNotes end BillingNotes


from "oascampaign_dim"
)

select * from w1

union all

select distinct
'default' as campaign_id,
null as insertion_order,
null as advertiser,
'UNKNOWN_DEFAULT' as salesgroup,
null as CampaignGroupId,
null::decimal(15,6) as bookedImps,
null::decimal(15,6) as bookedClicks,
null::decimal(15,6) as priority,
null::decimal(15,6) as weight,
null as DeliveryRate,
null::decimal(15,6) as ImpOverRun,
null::decimal(15,6) as DailyImp,
to_date(null,'YYYY-MM-DD') as start_date,
to_date(null,'YYYY-MM-DD') as end_date,
null as inventory_reservation,
null as pages,
null::decimal(15,6) as contracted_revenue,
null as BillOffContracted,
null::decimal(15,6) as cpm,
null::decimal(15,6) as cpc,
null::decimal(15,6) as cpa,
null::decimal(15,6) as FlatRate,
null as Currency,
null as BillingNotes
from w1;

insert into state_country_dim

select distinct
x.geography as geography_id, x.country_name, x.country_code, x.continent, x.state_code,
case
	when x.geography in ('CA -- Quebec', 'CA -- Prince Edward Island', 'CA -- Ontario', 'CA -- Nova Scotia', 'CA -- Newfoundland And Labrador', 'CA -- New Brunswick','CA -- Newfoundland and Labrador') then 'CA_EAST'
	when x.geography in ('CA -- Alberta', 'CA -- British Columbia', 'CA -- Manitoba', 'CA -- Northwest Territories', 'CA -- Nunavut', 'CA -- Saskatchewan', 'CA -- Yukon Territory') then 'CA_WEST'
	when x.geography in ('US -- Florida') then 'US_Flordia'
	when x.geography in ('US -- Wisconsin', 'US -- Ohio', 'US -- Minnesota', 'US -- Michigan', 'US -- Indiana', 'US -- Illinois','US -- South Dakota', 'US -- Oklahoma', 'US -- North Dakota', 'US -- Nebraska','US -- Missouri', 'US -- Kansas', 'US -- Iowa') then 'US_Midwest'
	when x.geography in ('US -- Texas', 'US -- Mississippi', 'US -- Louisiana', 'US -- Alabama') then 'US_GulfCoast'
	when x.geography in ('US -- West Virginia', 'US -- Virginia', 'US -- Pennsylvania', 'US -- Maryland', 'US -- Delaware', 'US -- District Of Columbia','US -- District of Columbia') then 'US_Mid_Atlantic'
	when x.geography in ('US -- Vermont', 'US -- Rhode Island', 'US -- New Hampshire', 'US -- Massachusetts', 'US -- Maine', 'US -- Connecticut') then 'US_New_England'
	when x.geography in ('US -- Washington', 'US -- Oregon', 'US -- Idaho', 'US -- Alaska','US -- Wyoming', 'US -- Montana') then 'US_NorthWest'
	when x.geography in ('US -- Tennessee', 'US -- South Carolina', 'US -- North Carolina', 'US -- Kentucky', 'US -- Georgia', 'US -- Arkansas') then 'US_Southeast'
	when x.geography in ('US -- Utah', 'US -- New Mexico', 'US -- Nevada', 'US -- Hawaii', 'US -- Colorado', 'US -- California', 'US -- Arizona') then 'US_Southwest'
	when x.geography in ('US -- New Jersey', 'US -- New York') then 'US_NY_NJ'
	when x.country_code in ('NG', 'DJ', 'CI', 'GH', 'SN', 'NA', 'TG', 'TN', 'DZ', 'SC', 'MU', 'KE', 'MA', 'BJ', 'MW', 'CD', 'ML', 'GM', 'MZ', 'TZ', 'AO', 'LY', 'GA', 'CM', 'UG', 'RE', 'BW', 'CV', 'TD', 'YT', 'SL', 'SD', 'ZW', 'GW', 'BI', 'GN', 'ZM', 'SZ', 'CG', 'RW', 'MR', 'CF', 'ET', 'SH', 'GQ', 'BF', 'SO', 'LS', 'NE', 'ST', 'ZA','ER','LR','KM','SS','MG') then 'Africa'
	when x.country_code in ('DE', 'GR', 'CZ', 'MC', 'FR', 'IE', 'UA', 'BE', 'LV', 'PL', 'BG', 'NL', 'GI', 'ES', 'ME', 'RS', 'PT', 'HR', 'MT', 'AT', 'RO', 'SK', 'HU', 'CH', 'EE', 'LT', 'LU', 'BA', 'IM', 'BY', 'DK', 'AX', 'GG', 'AL', 'MD', 'LI', 'JE', 'SM', 'MK', 'IS', 'AD', 'VA','FO','GL','IT','SI','SJ','XK') then 'Europe'
	when x.country_code in ('JP', 'SG', 'IN', 'PK', 'CN', 'MY', 'TH', 'HK', 'ID', 'PH', 'VN', 'GE', 'TW', 'MO', 'BD', 'KZ', 'MN', 'BN', 'KH', 'BT', 'MM', 'IO', 'TM', 'TL', 'KG', 'LA', 'UZ', 'CX', 'TJ','KR','LK','NP','MV') then 'FarEast'
	when x.country_code in ('MQ', 'PA', 'AG', 'BM', 'BS', 'VI', 'VC', 'PR', 'TT', 'VG', 'MX', 'DO', 'GD', 'KY', 'CR', 'DM', 'AW', 'GT', 'GP', 'BZ', 'SV', 'BB', 'KN', 'AI', 'JM', 'LC', 'MS', 'NI', 'CU', 'HT', 'TC', 'HN','CW','MF','SX') then 'NorthAmericaInt'
	when x.country_code in ('AU', 'NZ', 'NC', 'GU', 'PF', 'VU', 'FJ', 'PG', 'CK', 'MP', 'PW', 'TO', 'NU', 'SB', 'FM', 'KI', 'WF', 'TV', 'NR', 'WS', 'NF', 'AS','AF','AM','AZ','MH') then 'Australiasia'
	when x.country_code in ('BH', 'CY', 'EG', 'IR', 'IQ', 'IL', 'JO', 'KW', 'LB', 'OM', 'QA', 'SA', 'SY', 'TR', 'AE', 'YE','PS') then 'MiddleEast'
	when x.country_code in ('EC', 'AR', 'VE', 'BR', 'CO', 'PE', 'UY', 'BO', 'CL', 'PY', 'SR', 'GY', 'GF', 'FK','BQ') then 'SouthAmerica'
	when x.country_code in ('FI', 'NO', 'RU', 'SE') then 'RussiaScandinavia'
	when x.country_code in ('GB') then 'UK'
	else 'OTHER'
end marine_area
from
(
	select
	oas.geography,cc.OAS_name as country_name, cc.countrycode as country_code, cc.continent,oas.state_code
	from
	(
		SELECT distinct
		case
			when geography not like '%-%' then 'UNKNOWN'
			ELSE geography
		end geography,
		case
			when geography like '%-%' then substring(geography,1,2)
			else 'UNKNOWN'
		end country_code,
		case
			when geography like '%--%' then substring(geography,7,length(geography))
			when geography like '%-%' and geography not like '%--%' then substring(geography,6,length(geography))
			else 'UNKNOWN'
		end state_code
		
		FROM "oasdelbystate"
	) oas 
	join "countrycodes" cc on lower(cc.countrycode) = lower(oas.country_code)
	where cc.countrycode in ('US','CA')
	
	union all
	
	SELECT distinct
	oas.geography, cc.oas_name as country_name, cc.countrycode as country_code, cc.continent,'international' as state_code
	FROM "oasdelbycountry" oas
	join "countrycodes" cc on lower(oas.geography) = lower(cc.OAS_name)
	where cc.countrycode not in ('US','CA')
) x;

insert into position_dim

select distinct
cast(x.pos||'-'||x.site_section||'-'||x.portal as varchar(100)) as id,
x.pos,
x.site_section,
x.portal,
case
	when x.pos in ('x21','x22','x23','x25') and x.site_section in ('BR','DT','SR','HOME') and x.portal in ('BT','YW','BC') then 1
    when x.pos in ('Middle1','Middle2') and x.site_section in ('SR','BR') and x.portal = 'BT' then 1
    when x.pos = 'Top' and x.site_section = 'DT' and x.portal = 'BT' then 1
    else 0
end as most_used

from
(
	select distinct
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
	
	WHERE CASE
		WHEN lower(p.url) like 'www.boattrader.com%' then 'BT'
		WHEN lower(p.url) like '%yacht%' then 'YW'
		WHEN lower(p.url) like '%boats.com%' then 'BC'
		WHEN lower(p.url) like '%boatwizard%' then 'BOATWIZARD'
		ELSE 'OTHER'
	END <> 'OTHER'
) x;

insert into dma_geo_dim
select distinct
dma.geography as dma_geo_id,
dma.geography as dma_geography

from "oasdelbydma" dma