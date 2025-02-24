-- TASK1) count number of movies vs tv shows
use netflix_db1;
SELECT
count(type),type
FROM netflix
where type in ('Movie','TV Show')
group by type;

SELECT
count(type),type
FROM netflix
group by type;

-- Find the most common rating for movies and tv shows
select type,rating,count(rating) as total_rating
FROM netflix
group by type,rating
order by total_rating desc limit 4
;


SELECT
type,
rating,
total_rating from(select 
type,
rating,
count(rating) as total_rating,-- COUNT(rating) → Counts occurrences within each (type, rating) pair.
RANK() OVER(PARTITION BY type order by count(rating) desc) as ranking
-- RANK() OVER(PARTITION BY type ORDER BY COUNT(rating) DESC) → Assigns a rank within each type category.
FROM netflix
group by type,rating)as t1
WHERE ranking <=2; -- GROUP BY type, rating → Groups rows where type and rating are the same.

-- TASK 3 list all the movies released in specifc year
SELECT * FROM netflix
where release_year = '2021'
AND type = 'Movie';

-- Find the top 5 countries with most content on netflix
SELECT new_country,count(*) as total
FROM
(SELECT new_country
FROM netflix,
JSON_TABLE(
concat('["',REPLACE(country,',','","'),'"]'),
'$[*]' COLUMNS(new_country VARCHAR(255) PATH '$')
)AS country_list)
country_names
WHERE new_country IS NOT NULL
AND trim(new_country) <> '' -- empty strings or spaces.
AND  LENGTH(TRIM(new_country)) > 0
GROUP BY new_country
order by total desc limit 5;

-- TASK5 Find the longest movie
SELECT type,
 cast(replace(duration,'min','') as unsigned) duration1
 FROM netflix
 WHERE type = 'MOVIE'
 order by duration desc limit 1;
 
 -- Task6 Find content added in last 5 years
 SELECT 
 *
 FROM netflix 
 WHERE STR_TO_DATE(date_added, '%M %d, %Y') <= CURDATE() - INTERVAL 3 YEAR;
 
 -- Task7) Find all the movies/TV show by director Toshiya Shinohara
 SELECT * FROM netflix
 WHERE director LIKE '%Toshiya Shinohara%';
 
 -- TASK8) List all TV shows with more than 5 seasons
 select 
 type,
 cast(replace(replace(duration,'seasons',''),'seasons','')as unsigned) duration
 FROM netflix
 WHERE duration >5
AND type  = 'TV Show';

-- TASK9) Count the number of content item in each genre
SELECT listed_in1,count(*) as content_count
FROM
(SELECT 
listed_in1
FROM netflix,
 JSON_TABLE(
concat('["',replace(listed_in,',','","'),'"]'),
'$[*]' COLUMNS(listed_in1 VARCHAR(255) PATH '$')) as hi)
as iw
GROUP BY listed_in1;
 
 -- Task 10) Find each year and the average number of content release by India on netflix
 -- return top five years with highest avg content release
 SELECT *, ROUND(AVG(total),1) as average_each_year FROM
 (SELECT release_year,count(*) as total
 FROM netflix
 where country LIKE '%India%'
 GROUP BY release_year) as each_year_total
 GROUP BY release_year
 ORDER BY average_each_year desc limit 5;
  -- Task 10) Find each day and the average number of content release by India on netflix
 -- return top five day with highest avg content release
 SELECT DAY(STR_TO_DATE(date_added, '%M %d, %Y')) as days_of_month, AVG(total) as average_days
 FROM
 (SELECT 
 date_added,
 DAY(STR_TO_DATE(date_added, '%M %d, %Y')) as days ,count(*) as total
 FROM netflix
 where country LIKE '%India%'
 GROUP BY date_added) as jk
 GROUP BY days_of_month
 ORDER BY average_days desc limit 5;
 
 -- Task11) list all the movies that are documentaries
 SELECT * FROM netflix
 WHERE listed_in LIKE '%Documentaries%';
 
 -- TASK12) Find all the content without director
 SELECT * FROM netflix 
 where TRIM(director) = '' OR director is null;
 
 /*NULL and an empty string ('') are treated differently in SQL:
NULL means that the value is unknown or missing.
An empty string ('') is a value, but it’s just a string with no characters.*/

-- TASK13) In how many movies actor Roy Scheider appered in last 50 years
SELECT cast,count(*) as apperenens,release_year
FROM netflix 
where cast LIKE '%Roy Scheider%'
AND release_year BETWEEN (YEAR(curdate())  - 50)AND YEAR(curdate())
group by release_year,cast;
 
 -- TASK 14)Fid top 10 actors who appreared highest in movies in india
 SELECT directors,count(*) as total FROM(
 SELECT hi.new_director as directors,type,country  FROM netflix,
	 JSON_TABLE(concat('["',REPLACE(cast,',','","'),'"]'),
	 '$[*]' COLUMNS(new_director VARCHAR(255) PATH '$')
	 )as hi

 WHERE type ='Movie'
 AND country like '%India%'
 )  as asww
 GROUP BY directors;

-- TASK 15) Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN description LIKE '%kill%' OR description LIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY category;
 
 