--Schema
CREATE TABLE netflix
(
	show_id VARCHAR(6),
	type VARCHAR(10),
	title VARCHAR(150),
	director VARCHAR(250),
	country VARCHAR(150),
	date_added DATE,
	release_year INT,
	rating VARCHAR(10),
	duration VARCHAR(15),
	listed_in VARCHAR(100)
);

--Checking if data imported correctly
SELECT * FROM netflix;

--1. What year has the most total releases?
SELECT release_year, COUNT(*) AS total_releases
FROM netflix
GROUP BY release_year
ORDER BY total_releases DESC
LIMIT 1;

--2. Which country produced the most TV Shows?
SELECT TRIM(SPLIT_PART(country, ',', 1)) AS country,
COUNT(*) AS tv_shows
FROM netflix
WHERE type = 'TV Show'
AND country IS NOT NULL
GROUP BY country
ORDER BY tv_shows DESC
LIMIT 5;

--3. Which country produced the most Movies?
SELECT TRIM(SPLIT_PART(country, ',', 1)) AS country,
COUNT(*) AS movies
FROM netflix
WHERE type = 'Movie'
AND country IS NOT NULL
GROUP BY country
ORDER BY movies DESC
LIMIT 5;

--4. Which year had the highest number of new TV Shows added?
SELECT EXTRACT(YEAR FROM TO_DATE(date_added,'YYYY-MM-DD')) AS year_added,
COUNT(*) AS tv_shows_added
FROM netflix
WHERE type = 'TV Show'
GROUP BY year_added
ORDER BY tv_shows_added DESC
LIMIT 1;

--5. Find the shortest movie
SELECT title, CAST(SPLIT_PART(duration, ' ', 1) AS INT) AS minutes
FROM netflix
WHERE type= 'Movie'
ORDER BY minutes ASC
LIMIT 1;

--6.Which genre has the most TV Shows?
SELECT TRIM(SPLIT_PART(listed_in, ',', 1)) AS genre,
COUNT(*) AS tv_shows
FROM netflix
WHERE type = 'TV Show'
GROUP BY genre
ORDER BY tv_shows DESC
LIMIT 5;

--7. Which genre has the most Movies?
SELECT TRIM(SPLIT_PART(listed_in, ',', 1)) AS genre,
COUNT(*) AS movies
FROM netflix
WHERE type = 'Movie'
GROUP BY genre
ORDER BY movies DESC
LIMIT 5;

--8. How many titles were released before 2000?
SELECT COUNT(*) AS titles_before_2000
FROM netflix
WHERE release_year < 2000;

--9. Which year did Netflix add the most content overall?
SELECT EXTRACT(YEAR FROM TO_DATE(date_added, 'YYYY-MM-DD')) AS year_added,
COUNT (*) AS titles
FROM netflix
GROUP BY year_added
ORDER BY titles DESC
LIMIT 1;

--10. Which directors have more than 10 titles on Netflix?
SELECT director, COUNT(*) AS titles
FROM netflix
WHERE director IS NOT NULL
GROUP BY director 
HAVING COUNT(*) > 10
ORDER BY titles DESC;
