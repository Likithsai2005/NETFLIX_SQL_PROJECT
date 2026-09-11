**Netflix Movies and TV Shows Data Engineer using SQL**
![Netflix Logo](https://github.com/Likithsai2005/NETFLIX_SQL_PROJECT/blob/main/logo.png)

**Overview**
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

**Objectives**
Analyze the distribution of content types (movies vs TV shows).
Identify the most common ratings for movies and TV shows.
List and analyze content based on release years, countries, and durations.
Explore and categorize content based on specific criteria and keywords.

**Dataset**
The data for this project is sourced from the Kaggle dataset:

Dataset Link: Movies Dataset
**Schema**
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);
**Business Problems and Solutions**
1. Count the Number of Movies vs TV Shows
SELECT TYPE_S,COUNT(*) FROM NETFLIX
group by TYPE_S;
Objective: Determine the distribution of content types on Netflix.

2. Find the Most Common Rating for Movies and TV Shows
SELECT
	TYPE_S,
    RATING FROM (
			SELECT TYPE_S,RATING,COUNT(*),
				RANK() OVER(PARTITION BY TYPE_S ORDER BY COUNT(*) DESC) AS RANKING
			FROM netflix
			group by 1,2) T1
	WHERE RANKING = 1;
Objective: Identify the most frequently occurring rating for each type of content.

3. List All Movies Released in a Specific Year (e.g., 2020)
SELECT * FROM netflix
WHERE TYPE_S = 'MOVIE' AND release_year = '2020';
Objective: Retrieve all movies released in a specific year.

4. Find the Top 5 Countries with the Most Content on Netflix
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
Objective: Identify the top 5 countries with the highest number of content items.

5. Identify the Longest Movie
select * from netflix
where
	type_s = 'Movie' and
    duration = (select max(duration) from netflix);
Objective: Find the movie with the longest duration.

6. Find Content Added in the Last 5 Years
SELECT *
FROM netflix
WHERE STR_TO_DATE(date_added, '%M %d, %Y')
      >= CURRENT_DATE - INTERVAL 5 YEAR;
Objective: Retrieve content added to Netflix in the last 5 years.

7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'
select * from netflix
where director like '%Rajiv Chilaka%';
Objective: List all content directed by 'Rajiv Chilaka'.

8. List All TV Shows with More Than 5 Seasons
SELECT * FROM netflix
WHERE type_s = 'TV Show'
  AND CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) > 5;
Objective: Identify TV shows with more than 5 seasons.

9. Count the Number of Content Items in Each Genre
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
Objective: Count the number of content items in each genre.

10.Find each year and the average numbers of content release in India on netflix.
return top 5 year with highest avg content release!

SELECT release_year,COUNT(*) AS total_content,
    AVG(COUNT(*)) OVER () AS avg_content_per_year
FROM netflix
WHERE country LIKE '%India%'
GROUP BY release_year
ORDER BY total_content DESC
LIMIT 5;
Objective: Calculate and rank years by the average number of content releases by India.

11. List All Movies that are Documentaries
select * from netflix
where TYPE_S = 'Movie' and listed_in like '%Documentaries%';
Objective: Retrieve all movies classified as documentaries.

12. Find All Content Without a Director
SELECT *
FROM netflix
WHERE director IS NULL;
Objective: List content that does not have a director.

13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
SELECT COUNT(*) AS total_movies
FROM netflix
WHERE type_s = 'Movie'
  AND cast LIKE '%Salman Khan%'
  AND release_year >= YEAR(CURDATE()) - 10;
Objective: Count the number of movies featuring 'Salman Khan' in the last 10 years.

14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
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
Objective: Identify the top 10 actors with the most appearances in Indian-produced movies.

15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
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
Objective: Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.

**Findings and Conclusion**
Content Distribution: The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
Common Ratings: Insights into the most common ratings provide an understanding of the content's target audience.
Geographical Insights: The top countries and the average content releases by India highlight regional content distribution.
Content Categorization: Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.
This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.

**Author - P Likith Sai**
This project is part of my portfolio, showcasing the SQL skills essential for data analyst roles. If you have any questions, feedback, or would like to collaborate, feel free to get in touch!
