SELECT*FROM netflix;

--Business Problems
--1. Count the number of Movies vs TV Shows
SELECT type,COUNT(*) FROM netflix
GROUP BY type;

-- 2. Find the most common rating for movies and TV shows
SELECT type,rating FROM
   (SELECT type,rating,COUNT(*),
   RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS RANKING
   FROM netflix
   GROUP BY type,rating) AS t1
WHERE Ranking=1;

-- 3. List all movies released in a specific year (e.g., 2020)
SELECT * FROM netflix
WHERE release_year=2020;

-- 4. Find the top 5 countries with the most content on Netflix
SELECT UNNEST(STRING_TO_ARRAY(country,',')) as new_country,
COUNT(show_id) AS total_content FROM netflix
GROUP BY new_country
ORDER BY COUNT(show_id) DESC LIMIT 5;

-- 5. Identify the longest movie
SELECT*FROM netflix
WHERE type='Movie'
ORDER BY SPLIT_PART(duration,' ',1)::INT
DESC NULLS LAST;;

-- 6. Find content added in the last 5 years
SELECT * FROM netflix
WHERE TO_DATE(date_added,'Month DD,YYYY')>=CURRENT_DATE- INTERVAL'5 YEARS';

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
SELECT*FROM 
   (SELECT *,UNNEST(STRING_TO_ARRAY(director,',')) AS director_name FROM netflix
   ) 
WHERE director_name='Rajiv Chilaka';

-- 8. List all TV shows with more than 5 seasons
SELECT*FROM netflix
WHERE type='TV Show' AND SPLIT_PART(duration,' ',1)::INT>5

-- 9. Count the number of content items in each genre
SELECT UNNEST(STRING_TO_ARRAY(listed_in,',')) AS genre,COUNT(*) as total_content
FROM netflix
GROUP BY genre;

-- 10. Find each year and the average numbers of content release by India on netflix. Return top 5 year with highest avg content release
SELECT 
	country,
	release_year,
	COUNT(show_id) as total_release,
	ROUND(
		COUNT(show_id)::numeric/
								(SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100 
		,2
		)
		as avg_release
FROM netflix
WHERE country = 'India' 
GROUP BY country, 2
ORDER BY avg_release DESC 
LIMIT 5


-- 11. List all movies that are documentaries
SELECT*FROM netflix
WHERE listed_in ILIKE '%Documentaries%';

-- 12. Find all content without a director
SELECT*FROM netflix
WHERE director IS NULL;

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT*FROM netflix
WHERE casts ILIKE '%Salman khan%'
AND release_year>=EXTRACT( YEAR FROM CURRENT_DATE)-10

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
SELECT UNNEST(STRING_TO_ARRAY(casts,',')) AS actors, COUNT(*) AS total_content FROM netflix
WHERE country='India'
GROUP BY actors
ORDER BY total_content DESC LIMIT 10;

/*Question 15:
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category*/
SELECT type,category,COUNT(*) AS content FROM
   (SELECT*, CASE 
                 WHEN description ILIKE '%kill%' OR description ILIKE '%violence' THEN 'BAD'
				 ELSE 'GOOD'
				 END AS category FROM netflix) AS categorized_content
GROUP BY type,category
ORDER BY content;







