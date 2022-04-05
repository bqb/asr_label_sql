SELECT polygon.id,
polygon.lib, -- Place here any field releveant for you (they must also be 
  in grouping clauses, see below)
group_concat(line.id,',') as list_id_line -- this function concatenate the 
  id of every line that touch you polygon
FROM polygon LEFT OUTER JOIN line
ON Intersects(polygon.geom,line.geom) -- Spatial Dabatabase Rule !
GROUP BY polygon.id, polygon.lib -- theses are the grouping clauses


-- https://uwescience.github.io/SQL-geospatial-tutorial/07-Supplemental/


SELECT c2.id, c1.population, c1.popdensity, c1.vacant_housing, c2.geom FROM
(SELECT "Census Tract"::float/100 AS CT, 
  "Total Population, 2010" AS population, 
  "Persons per Square Mile, 2010" AS popdensity,
  "Vacant Housing Units, 2010" AS vacant_housing
  FROM census_data) AS c1,
(SELECT id, name10::float AS CT, geom FROM census_tracts) AS c2
WHERE c1.CT = c2.CT;


-- https://www.postgresql.org/docs/8.1/static/tutorial-join.html 

--  make eas point with CNN and corresponding street segment geometry (2018-09-19)

SELECT sf13_eas_cnnonly_pt.id, 
			eas_pt,
			str_ctr_li,
			sf13_eas_cnnonly_pt.fid,
			sf13_eas_cnnonly_pt.map_block_lot,
			street_cnn
	INTO 
		sf13_eas_cnn_pt_li
   FROM "sfgis"."sf13_eas_cnnonly_pt"
		LEFT OUTER JOIN  "sfgis"."sf13_st_ctr_li"  
		ON  (sf13_eas_cnnonly_pt.street_cnn  =  sf13_st_ctr_li.cnn);


--  try to join street segment to parcel centroid

SELECT  mbl_centroid, 
	sf13_mbl_centroid_pt.mapblklot,
	sf13_eas_cnn_pt_li.str_ctr_li,
	sf13_eas_cnn_pt_li.street_cnn
	FROM "sfgis"."sf13_mbl_centroid_pt"
	JOIN  "sfgis"."sf13_eas_cnn_pt_li"
	ON  ( sf13_mbl_centroid_pt.mapblklot  =  sf13_eas_cnn_pt_li.map_block_lot);


SELECT * FROM "sfgis"."sf13_mbl_centroid_pt"
	JOIN "sfgis"."sf13_eas_cnnonly_pt"
	ON  (sf13_mbl_centroid_pt.mapblklot  =  sf13_eas_cnnonly_pt.map_block_lot
		AND   sf13_mbl_centroid_pt.street  =  sf13_eas_cnnonly_pt.street_name) ;


SELECT * FROM "sfgis"."sf13_mbl_centroid_pt"
	LEFT OUTER JOIN "sfgis"."sf13_eas_cnnonly_pt"
	ON  sf13_mbl_centroid_pt.mapblklot  =  sf13_eas_cnnonly_pt.map_block_lot ;


SELECT 
	c_pt.mapblklot   as   mapblocklot,
	c_pt.shape   as  mbl_cent_pt,
	s_li.str_ctr_li   as  str_ctr_li,
	c_pt.from_st  as  from_strno,
	c_pt.to_st   as  to_strno,
	s_li.cnntext   as   cnn_text
--INTO
	--sf13_mbl_cnn_ptli_1_pgis
	FROM "sfgis"."sf13_pcl_centroid_cnn3_pt"  as  c_pt
	LEFT OUTER JOIN  "sfgis"."sf13_st_ctr_li"  as  s_li
	ON (c_pt.front_cnn  =  s_li.cnntext )
	ORDER BY mapblocklot;


SELECT 
	ptli.mapblocklot,
	ptli.mbl_cent_pt,
	st_setsrid(st_closestpoint(ptli.str_ctr_li, ptli.mbl_cent_pt), 7131)  as str_look_pt,
	ptli.from_strno,
	ptli.to_strno,
	ptli.cnn_text
INTO
	sf13_mbl_cnn_ptpt_3_pgis
	FROM  "sfgis"."sf13_mbl_cnn_ptli_1_pgis"  as  ptli
	ORDER BY mapblocklot;


SELECT 
	ptli.mapblocklot,
	ptli.mbl_cent_pt,
	ptli.str_look_pt,
	st_azimuth(ptli.str_look_pt, ptli.mbl_cent_pt)  as  str_look_az,
	2.2 * st_distance(ptli.str_look_pt, ptli.mbl_cent_pt)  as  str_look_dist,
	ptli.from_strno,
	ptli.to_strno,
	ptli.cnn_text
INTO
	sf13_mbl_cnn_ptpt_4_pgis
	FROM  "sfgis"."sf13_mbl_cnn_ptpt_3_pgis"  as  ptli
	ORDER BY mapblocklot;


SELECT
    to_pt.id   as   fid,
    look_pt.mbl   as   mbl, 
	--st_setsrid(look_pt.shape, 7131)  as  fm_pt,
	--st_setsrid(to_pt.geom, 7131)   as  to_pt,
	look_pt.cnn_text  as  cnn_text
--  INTO  sf13_look_ptpt_6_pgis
	FROM "sfgis"."sf13_mbl_look_5_pt"  as  look_pt
	JOIN  "sfgis"."sf13m_mbl_lookto_5_pt"  as  to_pt
	ON  ( look_pt.mbl  =  to_pt.mbl);


SELECT 
	ptli.mapblocklot,
	st_setsrid(ptli.str_look_pt, 7131),
	st_azimuth(ptli.str_look_pt, ptli.mbl_cent_pt)  as  str_look_az,
	2.2 * st_distance(ptli.str_look_pt, ptli.mbl_cent_pt)  as  str_look_dist,
	ptli.from_strno,
	ptli.to_strno,
	ptli.cnn_text
INTO
	sf13_mbl_cnn_ptpt_4_pgis
	FROM  "sfgis"."sf13_mbl_cnn_ptpt_4_pgis"  as  ptli
	ORDER BY mapblocklot;

SELECT
    to_pt.fid,
    look_pt.mbl   as   mbl, 
	--st_setsrid(look_pt.shape, 7131)  as  fm_pt,
	--st_setsrid(to_pt.geom, 7131)   as  to_pt,
	look_pt.cnn_text
--  INTO  sf13_look_ptpt_6_pgis
	FROM "sfgis"."sf13_mbl_look_5_pt"  as  look_pt
	JOIN  "sfgis"."sf13m_mbl_lookto_5_pt"  as  to_pt
	ON  ( look_pt.mbl  =  to_pt.mbl);


SELECT
    to_pt.id   as   fid,
    look_pt.mbl   as   mbl, 
	st_setsrid(look_pt.shape, 7131)  as  fm_pt,
	st_setsrid(to_pt.geom, 7131)   as  to_pt,
	look_pt.cnn_text  as  cnn_text
--  INTO  sf13_look_ptpt_6_pgis
	FROM "sfgis"."sf13_mbl_look_5_pt"  as  look_pt
	JOIN  "sfgis"."sf13m_mbl_lookto_5_pt"  as  to_pt
	ON  ( look_pt.mbl  =  to_pt.mbl);



--  example of sub-select and lateral join
select a.id,b2.id2,st_distance(a.geom,b2.geom) dist,st_shortestline(a.geom,b2.geom) geom
    from points a 
    cross join lateral
    (select b.id2,b.geom
        from lines b
        order by a.geom <-> b.geom)b2
order by dist;


select

SELECT 
to_pt.id  as  id,
from_pt.id  as  fid,
to_pt.mbl  as  mbl
 FROM "sfgis"."sf13_lookto7_geom_pt" as to_pt
 LEFT OUTER JOIN "sfgis"."sf13_look7_geom_pt" as from_pt
 on  to_pt.id  =  from_pt.id
 ORDER BY  to_pt.mbl;

 SELECT 
    to_pt.id  as  id,
    from_pt.id  as  fid,
	st_setsrid(from_pt.from_pt, 7131)  as  fm_pt,
	st_setsrid(to_pt.to_pt, 7131)   as  to_pt,
    to_pt.mbl  as  mbl
 FROM "sfgis"."sf13_lookto7_geom_pt" as to_pt
 LEFT OUTER JOIN "sfgis"."sf13_look7_geom_pt" as from_pt
 on  to_pt.id  =  from_pt.id
 ORDER BY  to_pt.mbl;

 SELECT 
    to_pt.id  as  id,
    from_pt.id  as  fid,
	st_setsrid(from_pt.from_pt, 7131)  as  fm_pt,
	st_setsrid(to_pt.to_pt, 7131)   as  to_pt,
    to_pt.mbl  as  mbl
INTO  sf13_look_ptpt_7_pgis
    FROM "sfgis"."sf13_lookto7_geom_pt" as to_pt
    LEFT OUTER JOIN "sfgis"."sf13_look7_geom_pt" as from_pt
    on  to_pt.id  =  from_pt.id
    ORDER BY  to_pt.mbl;

# this appears to work connecting the look point and lookto point with a line
# but the lines are all pointed northward with the wrong azimuth and show how
# none of the ToPt features are correctly positioned

 SELECT 
    pt_to_pt.id  as  id,
	pt_to_pt.fm_pt as  from_pt,
	pt_to_pt.to_pt as  lookto_pt,
	st_setsrid(st_shortestline(pt_to_pt.fm_pt, pt_to_pt.to_pt), 7131)  as look_li,
    pt_to_pt.mbl  as  mbl
INTO  sf13_look_ptptli_8_pgis
    FROM "sfgis"."sf13_look_ptpt_7_pgis" as pt_to_pt
    ORDER BY  pt_to_pt.mbl;


# re-try an earlier query using st_shortestline  rather than  st_closestpoint

SELECT 
	ptli.mapblocklot,
	ptli.mbl_cent_pt,
	st_setsrid(st_shortestline(ptli.str_ctr_li, ptli.mbl_cent_pt), 7131)  as centlook_li,
	ptli.from_strno,
	ptli.to_strno,
	ptli.cnn_text
--INTO sf13_outlook_ptlili_9_pgis
	FROM  "sfgis"."sf13_mbl_cnn_ptli_1_pgis"  as  ptli
	ORDER BY mapblocklot;


SELECT * FROM "sfgis"."sf13_mbl_centroid_pt"  as  cent_pt
	LEFT OUTER JOIN "sfgis"."sf13_eas_cnnonly_pt"  as  eascnn_pt
	ON  (cent_pt.mapblklot  =  eascnn_pt.map_block_lot );
--		AND   sf13_mbl_centroid_pt.street  =  sf13_eas_cnnonly_pt.street_name) ;


###===========================================================================================
###===========================================================================================
###===========================================================================================
# starting over, with epsg:7131 parcels in PostGIS  2018-09-23

SELECT
    pcl_pg.id  as  id,
    pcl_pg.objectid  as  orig_id,
    pcl_pg.mapblklot  as  mbl,
    pcl_pg.street  as  street,
    st_setsrid(pcl_pg.pcl_pg, 7131)  as  prcl_pg
INTO  sf13_parcel_2_pg
FROM "sfgis"."sf13_MBL_pcl_pg" as pcl_pg


SELECT
    eas_pt.objectid  as  id,
    eas_pt.id  as  eas_id,
    eas_pt.street_name  as  street,
    eas_pt.street_cnn  as  street_cnn,
    eas_pt.map_block_lot  as  mbl,
    eas_pt.eas_pt  as  eas_7131_pt
--INTO  sf13_eas_pt
FROM "sfgis"."sf13_eas_20180922_pt"  as  eas_pt

# With freshly created sf13_parcel_3_pt  centroids and  sf13_eas_pt including CNN
# do a join with both mbl and street name matching

# the following yields 17,615,996 rows in 94.3 seconds, with tons of duplicates
# take-away:  don't give up on PostGIS and kill the process, be a bit patient!
SELECT 
pclpt.fid as  fid,
pclpt.orig_id  as  orig_id,
pclpt.mbl  as  mbl,
st_setsrid(pclpt.pcl_cent_pt, 7131)  as  pcl_cent_pt,
easpt.street_cnn  as  street_cnn
FROM "sfgis"."sf13_parcel_3_pt"  as  pclpt
left  join  "sfgis"."sf13_eas_pt"  as  easpt
on (pclpt.mbl  =  easpt.mbl  and  pclpt.street  =  easpt.street)
order by pclpt.mbl;


# the following yielded 222,607 rows in 54.7 seconds, which is what we want!
# yea PostGIS!
# add a few more columns and this open Distinct on all columns yielded 
#  17,615,996  rows in   200.3 seconds
#  so obviously PostgreSQL is rather open to multiple DISTINCT columns!
SELECT DISTINCT
    pclpt.fid as  fid,
    pclpt.orig_id  as  orig_id,
    pclpt.mbl  as  mbl,
    pclpt.street as street_nom,
    easpt.street_cnn  as  street_cnn,
    easpt.eas_id  as  eas_id,
    st_setsrid(pclpt.pcl_cent_pt, 7131)  as  pcl_cent_pt
--INTO  "sfgis"."sf13_parcel_4_pt"
    FROM "sfgis"."sf13_parcel_3_pt"  as  pclpt
    left  join  "sfgis"."sf13_eas_pt"  as  easpt
    on (pclpt.mbl  =  easpt.mbl  and  pclpt.street  =  easpt.street)
    order by pclpt.mbl;

# with a cleaner DISTINCT field this seems like it should be faster
# this was still 17M rows in 200 seconds, or illegal ORDER BY at end.
#
SELECT 
	DISTINCT ON (fid)
	pclpt.fid as  fid,
    pclpt.orig_id  as  orig_id,
    pclpt.mbl  as  mbl,
    pclpt.street as street_nom,
    easpt.street_cnn  as  street_cnn,
    easpt.eas_id  as  eas_id,
    st_setsrid(pclpt.pcl_cent_pt, 7131)  as  pcl_cent_pt
--INTO  "sfgis"."sf13_parcel_4_pt"
    FROM "sfgis"."sf13_parcel_3_pt"  as  pclpt
    left  join  "sfgis"."sf13_eas_pt"  as  easpt
    on (pclpt.mbl  =  easpt.mbl  and  pclpt.street  =  easpt.street)
    ORDER BY pclpt.mbl;

# finally this was 221,227 rows in 23.8 seconds, much more what I want.
#  I write this into  sf13_parcel_4_pt
SELECT 
	DISTINCT ON (fid)
	pclpt.fid as  fid,
    pclpt.orig_id  as  orig_id,
    pclpt.mbl  as  mbl,
    pclpt.street as street_nom,
    easpt.street_cnn  as  street_cnn,
    easpt.eas_id  as  eas_id,
    st_setsrid(pclpt.pcl_cent_pt, 7131)  as  pcl_cent_pt
INTO  "sfgis"."sf13_parcel_4_pt"
    FROM "sfgis"."sf13_parcel_3_pt"  as  pclpt
    left  join  "sfgis"."sf13_eas_pt"  as  easpt
    on (pclpt.mbl  =  easpt.mbl  and  pclpt.street  =  easpt.street);

# not to create look lines.  Using st_shortestline we don't really need to
# have a ptli multi-geom and generate look points separately.  We can just
# join on street_cnn and directly generate an st_shortestline, can't we?
#  221,227 rows in 3.6 seconds.   Si se puede!
SELECT 
	DISTINCT ON (fid)
	pclpt.fid as  fid,
	pclpt.eas_id  as  eas_id,
	pclpt.mbl  as  mbl,
    pclpt.street_nom as street_nom,
	pclpt.street_cnn  as  street_cnn,
	st_setsrid(st_shortestline(stctrli.str_ctr_li, pclpt.pcl_cent_pt), 7131)  as centlook_li
INTO  "sfgis"."sf13_centlook_li"
	FROM "sfgis"."sf13_parcel_4_pt"  as  pclpt
	LEFT OUTER JOIN  "sfgis"."sf13_st_ctr_li"  as  stctrli
	ON  (pclpt.street_cnn  =  stctrli.cnn );

#  Now the challenge, not trivial, of extending these lines from street
# through centroid and on through back of lot.  Web suggests that we need the
# start and end point and some trigonometry to make this work, or elese use
# the line centroid and an affine mapping, which would work fine since our use
# is to clip this line with the parcel polygon anyhow...
# so using sf13_centlook_li to continue

# this does not work because it simply scales all coordinates, making a big copy
# to the NEly of City
SELECT
    DISTINCT ON (fid)
	clookli.fid as  fid,
	clookli.eas_id  as  eas_id,
	clookli.mbl  as  mbl,
    clookli.street_nom as street_nom,
	clookli.street_cnn  as  street_cnn,
	st_setsrid(st_transscale(clookli.centlook_li, 0, 0, 2.2, 2.2), 7131)  as look_li
INTO "sfgis"."sf13_backlook_li"
	FROM "sfgis"."sf13_centlook_li"  as clookli


# so here it's just a wee bit of trigonometry and some length-extending scale
SELECT
    DISTINCT ON (fid)
	clookli.fid as  fid,
	clookli.eas_id  as  eas_id,
	clookli.mbl  as  mbl,
    clookli.street_nom as street_nom,
	clookli.street_cnn  as  street_cnn,
	st_setsrid(st_startpoint(clookli.centlook_li), 7131)  as start_pt,
	st_setsrid(st_endpoint(clookli.centlook_li), 7131)  as  end_pt,
	st_azimuth(start_pt, end_pt)  as  look_az,
	2.2 * st_distance(start_pt, end_pt)  as  back_dist,
	st_setsrid(st_translate(start_pt, sin(look_az) * back_dist, cos(look_az) * back_dist), 7131)  as back_pt,
	st_setsrid(st_shortestline(start_pt, back_pt), 7131)  as back_li
--INTO "sfgis"."sf13_backlook_li"
	FROM "sfgis"."sf13_centlook_li"  as clookli

# Of course, without subqueries I'm not able to act on an as-yet-nonexistent start_pt and end_pt.
# so just do this piecewise and grind onward
SELECT
    DISTINCT ON (fid)
	clookli.fid as  fid,
	clookli.eas_id  as  eas_id,
	clookli.mbl  as  mbl,
    clookli.street_nom as street_nom,
	clookli.street_cnn  as  street_cnn,
	st_setsrid(st_startpoint(clookli.centlook_li), 7131)  as start_pt,
	st_setsrid(st_endpoint(clookli.centlook_li), 7131)  as  end_pt
--INTO "sfgis"."sf13_backlook_ptpt_pgis"
	FROM "sfgis"."sf13_centlook_li"  as clookli

#  with start and end points, try and create a back lot point with azimuth and distance to construct
SELECT
    DISTINCT ON (fid)
	lkptpt.fid as  fid,
	lkptpt.eas_id  as  eas_id,
	lkptpt.mbl  as  mbl,
    lkptpt.street_nom as street_nom,
	lkptpt.street_cnn  as  street_cnn,
	st_azimuth(lkptpt.start_pt, lkptpt.end_pt)  as  look_az,
	2.2 * st_distance(lkptpt.start_pt, lkptpt.end_pt)  as  back_dist
--INTO "sfgis"."sf13_back_trig_pt"
FROM "sfgis"."sf13_backlook_ptpt_pgis"  as  lkptpt

#  carrying the attributes along, construct the back point
SELECT
    DISTINCT ON (fid)
	lkptpt.fid as  fid,
	lkptpt.eas_id  as  eas_id,
	lkptpt.mbl  as  mbl,
    lkptpt.street_nom as street_nom,
	lkptpt.street_cnn  as  street_cnn,
	lkptpt.look_az  as  look_az,
	lkptpt.back_dist  as  back_dist,
    lkptpt.start_pt  as  start_pt,
    st_setsrid(st_translate(lkptpt.start_pt, sin(look_az) * back_dist, cos(look_az) * back_dist), 7131)  as back_pt
--INTO  "sfgis"."sf13_back_ptpt_pgis"
FROM "sfgis"."sf13_backpt_trig_pt"  as  lkptpt

# Continuing to carry attributes, connect the dots in the back look direction
# This yields 221,227 look lines that almost always pass all the way through parcels
SELECT
    DISTINCT ON (fid)
	lkptpt.fid as  fid,
	lkptpt.eas_id  as  eas_id,
	lkptpt.mbl  as  mbl,
    lkptpt.street_nom as street_nom,
	lkptpt.street_cnn  as  street_cnn,
    st_setsrid(st_shortestline(lkptpt.start_pt, lkptpt.back_pt), 7131)  as back_li
INTO  "sfgis"."sf13_back_li"
FROM "sfgis"."sf13_back_ptpt_pgis"  as  lkptpt

# now associate those back-look lines with their specific parcel for row-wise clipping
SELECT 
    DISTINCT ON (fid)
    pclpg.fid  as  fid,
	pclpg.mbl  as  mbl,
	pclpg.orig_id  as  origpg_id,
	backli.eas_id   as  eas_id,
	backli.street_nom  as  str_nom,
	backli.street_cnn   as   str_cnn,
	st_setsrid(pclpg.pcl_pg, 7131)  as  pcl_pg,
	st_setsrid(backli.geom, 7131)  as  backlook_li
INTO "sfgis"."sf13_pcllook_pgli_pgis"
	FROM "sfgis"."sf13_parcel_3_pg" as pclpg
	LEFT JOIN  "sfgis"."sf13_back2_li"  as  backli
	ON  ( pclpg.mbl  =  backli.mbl );

# now actually do the intersect, row-wise, using this geometry
#  still carrying along the useful identifier attributes an a fid
SELECT 
    DISTINCT ON (fid)
    pgli.fid  as  fid,
	pgli.mbl   as  mbl,
	pgli.origpg_id  as  origpg_id,
	pgli.eas_id   as  eas_id,
	pgli.str_nom  as  str_nom,
	pgli.str_cnn   as   str_cnn,
	st_setsrid(st_intersection(pgli.pcl_pg, pgli.backlook_li), 7131) as  pcl_median_li
	FROM "sfgis"."sf13_pcllook_pgli_pgis" as pgli


# create index to try and make this join happen better
DB Manager > Table > Edit Table > Table Properties > Indexes > Add index
in the pop-up
create index > column, index-name

	FID   int4    Default:  nextval('sf13_mbl_look_5_pt_id_seq'::regclass)

	
