-- > ------------------------------------
-- CREATING DATA BASE
-- > ------------------------------------


drop table if exists spotify;
create table spotify(
Artist varchar(250),
Track varchar (255),
Album varchar (300),
Album_type varchar(30),
Danceability float,
Energy float,
Loudness float,
Speechiness float,
Acousticness float,
Instrumentalness float,
Liveness float,
Valence float,
Tempo float,
Duration_min float,
Title varchar(300),
Channel varchar(250),
Views bigint,
Likes bigint,
Comments bigint,
Licensed boolean,
official_video boolean,
Stream boolean,
EnergyLiveness float,
most_playedon varchar(50)
)



select * from spotify


ALTER TABLE spotify
ALTER COLUMN most_playedon TYPE varchar (100);


SELECT * FROM spotify

-- ----------------------------------------------
	-- EXPLORE DATA ANALYST  (EDA)
-- ----------------------------------------------
 
SELECT COUNT(*) FROM SPOTIFY;  


SELECT COUNT(DISTINCT Artist) FROM SPOTIFY;  

SELECT COUNT( DISTINCT ALBUM) FROM SPOTIFY;


SELECT * FROM SPOTIFY
ORDER BY Energy DESC
LIMIT 10;


SELECT DISTINCT Album_type FROM SPOTIFY


SELECT MAX(Duration_min) FROM SPOTIFY
SELECT MIN(Duration_min) FROM SPOTIFY


DELETE FROM SPOTIFY
WHERE Duration_min = 0;
SELECT * FROM SPOTIFY
WHERE Duration_min =0;

SELECT DISTINCT most_playedon FROM SPOTIFY

SELECT count(DISTINCT Channel) FROM Spotify


SELECT Artist,sum(Views) as total_views FROM SPOTIFY
GROUP BY Artist
order by sum(Views) desc
limit 10;

/*
-- ---------------------------------------------------
--  Data Analysis -Esay Category
-- ---------------------------------------------------

Easy Level
Retrieve the names of all tracks that have more than 1 billion streams.
List all albums along with their respective artists.
Get the total number of comments for tracks where licensed = TRUE.
Find all tracks that belong to the album type single.
Count the total number of tracks by each artist.
*/

-- Q.1 Retrieve the names of all tracks that have more than 1 billion streams.

SELECT * FROM spotify
where stream > 1000000000;


-- Q.2 List all albums along with their respective artists.

select
		DISTINCT artist ,
		album 
from spotify
ORDER BY 1;

-- Q.3 Get the total number of comments for tracks where licensed = TRUE.
SELECT * FROM spotify;

SELECT 
	track,
	sum(comments) as total_comments
	from spotify
where licensed = 'true'
group by track;

-- Q.4 Find all tracks that belong to the album type single.

SELECT * FROM spotify
WHERE album_type = 'single'

-- Q.5 Count the total number of tracks by each artist.

SELECT 
	artist,
	COUNT(track) as count_of_tracks
FROM spotify
GROUP BY artist;
/*
Calculate the average danceability of tracks in each album.
Find the top 5 tracks with the highest energy values.
List all tracks along with their views and likes where official_video = TRUE.
For each album, calculate the total views of all associated tracks.
Retrieve the track names that have been streamed on Spotify more than YouTube.
*/

-- Q.6 Calculate the average danceability of tracks in each album.

SELECT * FROM spotify

SELECT album, AVG(danceability)
FROM spotify
group by album
order by 2 desc

-- Q.7 Find the top 5 tracks with the highest energy values.


SELECT track,max(energy) FROM spotify
group by track
order by 2 desc
limit 5;

-- Q.8 List all tracks along with their views and likes where official_video = TRUE.

SELECT artist,
		track,
		album,
		channel,
		sum(views) as total_views,
		sum(likes) as total_likes,
		comments
FROM spotify
where official_video = 'true'

-- Q.9 For each album, calculate the total views of all associated tracks.

select album,
	track,
	sum(views) as total_views
from spotify
group by 1,2
order by 3 desc;

-- Q.10 Retrieve the track names that have been streamed on Spotify more than YouTube.


SELECT * FROM 
(SELECt track,
		coalesce(sum(case when most_playedon = 'Spotify' then stream end),0)as stream_on_youtube,
		coalesce(sum(case when most_playedon = 'Youtube' then stream end),0) as stream_on_spotify
FROM spotify
group by 1
)as t1
WHERE  stream_on_spotify > stream_on_youtube 
		AND 
		stream_on_youtube <> 0;


-- Advanced Level
-- q 11.Find the top 3 most-viewed tracks for each artist using window functions.
--Q 12. Write a query to find tracks where the liveness score is above the average.
-- Q13.Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
-- WITH cte.
-- Q 14.Find tracks where the energy-to-liveness ratio is greater than 1.2.
-- 15.Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.





-- q 11.Find the top 3 most-viewed tracks for each artist using window functions.

SELECT artist,
       track,
       views
FROM (
    SELECT artist,
           track,
           views,
           ROW_NUMBER() OVER (
               PARTITION BY artist
               ORDER BY views DESC
           ) AS rank
    FROM spotify
) ranked_tracks
WHERE rank <= 3
ORDER BY artist, views DESC;

--Q 12. Write a query to find tracks where the liveness score is above the average.

select  track,
		artist,
		liveness
		from spotify
where liveness > (select avg(liveness) from spotify)



-- Q13.Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
-- WITH cte.

with cte as 
(select album , max(energy) as higest_energy,
			min(energy) as lowest_energy 

from spotify
group by album)
select album ,higest_energy-lowest_energy as energy_diff
from cte

-- Q 14.Find tracks where the energy-to-liveness ratio is greater than 1.2.
select * from spotify


select  track, artist, energy, liveness, energy/liveness as diff from spotify
where energy/liveness > 1.2 and liveness > 0

--  15.Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.

SELECT track,
       views,
       likes,
       SUM(likes) OVER (
           ORDER BY views DESC
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS cumulative_likes
FROM spotify
ORDER BY views DESC;

-- Query optimization

EXPLAIN ANALYZE
select artist, track, album
from spotify
where artist = 'Gorillaz'
and 
most_playedon = 'Spotify'
order by stream desc
limit 8



select * from spotify

CREATE INDEX artist_index on spotify (artist)
