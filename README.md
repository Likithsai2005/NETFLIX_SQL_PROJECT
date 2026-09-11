# **Netflix Movies and TV Shows Data Analysis using SQL**

![Netflix Logo](https://github.com/Likithsai2005/NETFLIX_SQL_PROJECT/blob/main/logo.png)

## **Overview**

This project involves a comprehensive analysis of **Netflix Movies and TV Shows data using MySQL**. The objective is to extract meaningful business insights from the dataset by applying SQL concepts such as **Filtering, Aggregation, Joins, Subqueries, CTEs, Window Functions, String Functions, Date Functions, and JSON_TABLE()**.

The project contains **15 business problems** covering content distribution, ratings, countries, genres, actors, release trends, and content categorization.

---

## **Objectives**

* Analyze the distribution of **Movies vs TV Shows**.
* Identify the **most common ratings** for Movies and TV Shows.
* Analyze content based on **release years, countries, genres, and durations**.
* Identify the **top countries producing Netflix content**.
* Analyze **Indian movies and actors**.
* Find content based on **specific keywords and categories**.
* Apply advanced SQL techniques to solve real-world business problems.

---

## **Dataset**

The data for this project is sourced from the **Netflix Movies and TV Shows dataset** available on Kaggle.

**Dataset:** Netflix Movies and TV Shows Dataset

---

## **Schema**

```sql
DROP TABLE IF EXISTS netflix;

CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    cast         VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);
```

---

# **Business Problems and Solutions**

## **1. Count the Number of Movies vs TV Shows**

```sql
SELECT
    type,
    COUNT(*) AS total_content
FROM netflix
GROUP BY type;
```

**Objective:** Determine the distribution of Movies and TV Shows available on Netflix.

---

## **2. Find the Most Common Rating for Movies and TV Shows**

```sql
SELECT
    type,
    rating
FROM (
    SELECT
        type,
        rating,
        COUNT(*) AS total,
        RANK() OVER (
            PARTITION BY type
            ORDER BY COUNT(*) DESC
        ) AS ranking
    FROM netflix
    GROUP BY type, rating
) t1
WHERE ranking = 1;
```

**Objective:** Identify the most frequently occurring rating for each type of content.

---

## **3. List All Movies Released in a Specific Year (2020)**

```sql
SELECT *
FROM netflix
WHERE type = 'Movie'
  AND release_year = 2020;
```

**Objective:** Retrieve all movies released in a specific year.

---

## **4. Find the Top 5 Countries with the Most Content on Netflix**

```sql
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
GROUP BY TRIM(jt.new_country)
ORDER BY total_content DESC
LIMIT 5;
```

**Objective:** Identify the top 5 countries with the highest number of Netflix content items.

---

## **5. Identify the Longest Movie**

```sql
SELECT *
FROM netflix
WHERE type = 'Movie'
  AND CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) = (
      SELECT MAX(
          CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED)
      )
      FROM netflix
      WHERE type = 'Movie'
  );
```

**Objective:** Find the movie with the longest duration.

---

## **6. Find Content Added in the Last 5 Years**

```sql
SELECT *
FROM netflix
WHERE STR_TO_DATE(date_added, '%M %d, %Y')
      >= CURRENT_DATE() - INTERVAL 5 YEAR;
```

**Objective:** Retrieve content added to Netflix within the last 5 years.

---

## **7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'**

```sql
SELECT *
FROM netflix
WHERE director LIKE '%Rajiv Chilaka%';
```

**Objective:** List all content directed by Rajiv Chilaka.

---

## **8. List All TV Shows with More Than 5 Seasons**

```sql
SELECT *
FROM netflix
WHERE type = 'TV Show'
  AND CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) > 5;
```

**Objective:** Identify TV shows having more than 5 seasons.

---

## **9. Count the Number of Content Items in Each Genre**

```sql
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
```

**Objective:** Count the number of Netflix content items in each genre.

---

## **10. Find Each Year and Content Releases in India**

```sql
SELECT
    release_year,
    COUNT(*) AS total_content,
    AVG(COUNT(*)) OVER () AS avg_content_per_year
FROM netflix
WHERE country LIKE '%India%'
GROUP BY release_year
ORDER BY total_content DESC
LIMIT 5;
```

**Objective:** Identify the top 5 years with the highest number of content releases from India and calculate the average yearly content release.

---

## **11. List All Movies that are Documentaries**

```sql
SELECT *
FROM netflix
WHERE type = 'Movie'
  AND listed_in LIKE '%Documentaries%';
```

**Objective:** Retrieve all movies classified as documentaries.

---

## **12. Find All Content Without a Director**

```sql
SELECT *
FROM netflix
WHERE director IS NULL;
```

**Objective:** Identify content where director information is missing.

---

## **13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years**

```sql
SELECT
    COUNT(*) AS total_movies
FROM netflix
WHERE type = 'Movie'
  AND cast LIKE '%Salman Khan%'
  AND release_year >= YEAR(CURDATE()) - 10;
```

**Objective:** Count the number of movies featuring Salman Khan released within the last 10 years.

---

## **14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India**

```sql
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
WHERE n.type = 'Movie'
  AND n.country LIKE '%India%'
  AND n.cast IS NOT NULL
GROUP BY TRIM(jt.actor)
ORDER BY movie_count DESC
LIMIT 10;
```

**Objective:** Identify the top 10 actors with the highest number of appearances in Indian-produced movies.

---

## **15. Categorize Content Based on 'Kill' and 'Violence' Keywords**

```sql
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
```

**Objective:** Categorize content as **'Bad'** if the description contains the keywords `kill` or `violence`, and **'Good'** otherwise.

---

# **Skills & SQL Concepts Used**

### **SQL Skills**

* SELECT
* WHERE
* GROUP BY
* ORDER BY
* HAVING
* CASE Statements
* Aggregate Functions
* Subqueries
* CTEs
* Window Functions
* RANK()
* JOIN
* String Functions
* Date Functions
* JSON_TABLE()
* Data Cleaning
* Data Transformation

### **Tools**

* **MySQL**
* **MySQL Workbench**
* **Git & GitHub**
* **Kaggle Dataset**

---

# **Findings and Conclusion**

### **Content Distribution**

Analyzed the distribution of Movies and TV Shows available on Netflix.

### **Ratings**

Identified the most common ratings across different content types.

### **Geographical Insights**

Identified the countries producing the highest amount of Netflix content and analyzed India's yearly content releases.

### **Genre Analysis**

Analyzed the most common genres and documentary content available on Netflix.

### **Actor Analysis**

Identified actors with the highest number of appearances in Indian-produced movies.

### **Content Categorization**

Used SQL `CASE` statements and keyword matching to categorize content based on descriptions containing **'kill'** and **'violence'**.

### **Overall Conclusion**

This project demonstrates the ability to use **MySQL and advanced SQL techniques to solve real-world business problems and extract meaningful insights from large datasets**.

---

# **Author – P Likith Sai**

This project is part of my **Data Analyst / SQL portfolio**, showcasing practical SQL skills including **data analysis, data transformation, advanced queries, and business problem solving**.

If you have any questions, feedback, or would like to collaborate, feel free to get in touch.

---

⭐ **If you find this project useful, consider giving the repository a star!**
