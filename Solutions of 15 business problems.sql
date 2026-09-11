-- Netflix Data Analysis using SQL
-- Solutions of 15 business problems
-- 1. Count the number of Movies vs TV Shows

SELECT TYPE_S,COUNT(*) FROM NETFLIX
group by TYPE_S;

-- 2. Find the most common rating for movies and TV shows

SELECT
	TYPE_S,
    RATING FROM (
			SELECT TYPE_S,RATING,COUNT(*),
				RANK() OVER(PARTITION BY TYPE_S ORDER BY COUNT(*) DESC) AS RANKING
			FROM netflix
			group by 1,2) T1
	WHERE RANKING = 1;


-- 3. List all movies released in a specific year (e.g., 2020)

SELECT * FROM netflix
WHERE TYPE_S = 'MOVIE' AND release_year = '2020';


-- 4. Find the top 5 countries with the most content on Netflix

SELECT
    TRIM(jt.new_country) AS new_country,
    COUNT(n.show_id) AS total_content
FROM netflix n
JOIN JSON_TABLE(
    CONCAT(
        '["',
        REPLACE(n.country, ',', '","'),
        '"]'
    ),
    '$[*]' COLUMNS (
        new_country VARCHAR(255) PATH '$'
    )
) AS jt
WHERE n.country IS NOT NULL
GROUP BY new_country
ORDER BY total_content DESC
LIMIT 5;


-- 5. Identify the longest movie

select * from netflix
where
	type_s = 'Movie' and
    duration = (select max(duration) from netflix);


-- 6. Find content added in the last 5 years
SELECT *
FROM netflix
WHERE STR_TO_DATE(date_added, '%M %d, %Y')
      >= CURRENT_DATE - INTERVAL 5 YEAR;


-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

select * from netflix
where director like '%Rajiv Chilaka%';

-- 8. List all TV shows with more than 5 seasons

SELECT * FROM netflix
WHERE type_s = 'TV Show'
  AND CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) > 5;


-- 9. Count the number of content items in each genre

SELECT
    TRIM(jt.genre) AS genre,
    COUNT(*) AS total_content
FROM netflix n
JOIN JSON_TABLE(
    CONCAT(
        '["',
        REPLACE(n.listed_in, ', ', '","'),
        '"]'
    ),
    '$[*]' COLUMNS (
        genre VARCHAR(255) PATH '$'
    )
) AS jt
GROUP BY TRIM(jt.genre)
ORDER BY total_content DESC;


-- 10. Find each year and the average numbers of content release by India on netflix. 
-- return top 5 year with highest avg content release !


SELECT release_year,COUNT(*) AS total_content,
    AVG(COUNT(*)) OVER () AS avg_content_per_year
FROM netflix
WHERE country LIKE '%India%'
GROUP BY release_year
ORDER BY total_content DESC
LIMIT 5;


-- 11. List all movies that are documentaries
select * from netflix
where TYPE_S = 'Movie' and listed_in like '%Documentaries%';



-- 12. Find all content without a director
SELECT *
FROM netflix
WHERE director IS NULL;


-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT COUNT(*) AS total_movies
FROM netflix
WHERE type_s = 'Movie'
  AND cast LIKE '%Salman Khan%'
  AND release_year >= YEAR(CURDATE()) - 10;


-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.



SELECT
    TRIM(jt.actor) AS actor,
    COUNT(*) AS movie_count
FROM netflix n
JOIN JSON_TABLE(
    CONCAT(
        '["',
        REPLACE(n.cast, ', ', '","'),
        '"]'
    ),
    '$[*]' COLUMNS (
        actor VARCHAR(255) PATH '$'
    )
) AS jt
WHERE n.type_s = 'Movie'
  AND n.country LIKE '%India%'
  AND n.cast IS NOT NULL
GROUP BY TRIM(jt.actor)
ORDER BY movie_count DESC
LIMIT 10;

/*
Question 15:
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
*/


SELECT
    CASE
        WHEN LOWER(description) LIKE '%kill%'
          OR LOWER(description) LIKE '%violence%'
        THEN 'Bad'
        ELSE 'Good'
    END AS category,
    COUNT(*) AS total_content
FROM netflix
GROUP BY category;




-- End of reports

