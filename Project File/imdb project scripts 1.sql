-- Count rows in movie table
SELECT COUNT(*) FROM movie;

-- Count rows in genre table
SELECT COUNT(*) FROM genre;

-- Count rows in director_mapping table
SELECT COUNT(*) FROM director_mapping;

-- Count rows in role_mapping table
SELECT COUNT(*) FROM role_mapping;

-- Count rows in names table
SELECT COUNT(*) FROM names;

-- Count rows in ratings table
SELECT COUNT(*) FROM ratings;

-- Count null values in each column of the movie table
SELECT COUNT(*) FROM movie WHERE title IS NULL;
SELECT COUNT(*) FROM movie WHERE year IS NULL;
SELECT COUNT(*) FROM movie WHERE date_published IS NULL;
SELECT COUNT(*) FROM movie WHERE duration IS NULL;
SELECT COUNT(*) FROM movie WHERE country IS NULL;
SELECT COUNT(*) FROM movie WHERE worldwide_gross_income IS NULL;
SELECT COUNT(*) FROM movie WHERE languages IS NULL;


-- Segment 2: Movie Release Trends



select * from movie;

-- Month-wise Trend of Movie Releases


SELECT 
    YEAR(date_published) AS year,
    MONTH(date_published) AS month,
    COUNT(id) AS total_movies
FROM 
    Movie
GROUP BY 
    year, month
ORDER BY 
    year, month
LIMIT 1000;




-- Calculate the number of movies produced in the USA or India in the year 2019.

SELECT COUNT(*) AS total_movies
FROM movie
WHERE (country = 'USA' OR country = 'India') AND YEAR(date_published) = 2019;

-- Segment 3: Production Statistics and Genre Analysis

-- Retrieve the unique list of genres present in the dataset.

SELECT * from genre;
SELECT DISTINCT genre FROM genre;

	-- Identify the genre with the highest number of movies produced overall.
    
    SELECT genre, COUNT(*) AS genre_count
FROM genre
GROUP BY genre
ORDER BY genre_count DESC
LIMIT 1;

	-- Determine the count of movies that belong to only one genre.
    
	-- Calculate the average duration of movies in each genre.
select * from movie;
select * FROM genre;
   
   select genre,avg(duration) as Avg_duration
   from movie as A
   join genre as B
   on A.id = B.movie_id
   group by genre
   order by genre asc;
   
   -- Find the rank of the 'thriller' genre among all genres in terms of the number of movies produced.
 with movie_count as (  
select genre,count(movie_id) as total_movie from movie as A
join genre as B
on A.id = B.movie_id 
group by genre
),movie_rank as (
select *,dense_rank() over(order by total_movie desc) as movie_rankk from movie_count)
select*from movie_rank
where genre = "thriller"

-- Segment 4: Ratings Analysis and Crew Members

-- Retrieve the minimum and maximum values in each column of the ratings table (except movie_id).


select * from ratings;

SELECT 
    MIN(AVG_RATING) AS Min_value,
    MIN(total_votes) AS Min_votes,
    MIN(median_rating) AS Min_median,
    MAX(AVG_RATING) AS Max_value,
    MAX(total_votes) As Max_votes,
    MAX(median_rating)As Max_median
FROM 
    ratings;
    
-- Identify the top 10 movies based on average rating.
select * from movie;
select * from ratings;

-- Query to identify the top 10 movies based on average rating
SELECT m.id, m.title, r.avg_rating
FROM movie m
JOIN ratings r ON m.id = r.movie_id
ORDER BY r.avg_rating DESC
LIMIT 10;

-- Summarise the ratings table based on movie counts by median ratings.


SELECT median_rating, COUNT(*) as movie_count
FROM ratings
GROUP BY median_rating
ORDER BY median_rating;


-- Identify the production house that has produced the most number of hit movies (average rating > 8).
select * from ratings;
select * from movie;

select production_company,count(avg_rating) from movie as A
join ratings as B
on A.id = B.movie_id
where B.avg_rating > 8
group by  production_company
order by production_company asc;


-- Determine the number of movies released in each genre during March 2017 in the USA with more than 1,000 votes.

select * from movie;
select * from genre;
select * from ratings;

SELECT g.genre, COUNT(m.id) AS num_movies
FROM genre g
JOIN movie m ON g.movie_id = m.id
JOIN ratings r ON m.id = r.movie_id
WHERE m.date_published >= '2017-03-01' AND m.date_published <= '2017-03-31'
  AND m.country = 'USA'
  AND r.total_votes > 1000
GROUP BY g.genre
ORDER BY num_movies DESC;

-- Retrieve movies of each genre starting with the word 'The' and having an average rating > 8.

select * from movie;
select * from genre;
select * from ratings;

select A.title, B.genre from movie as A
join genre as B 
on A.id = B.movie_id
join ratings as C
on A.id = C.movie_id
where A.title like "The%"
and C.avg_rating >8
order by genre asc;

-- Segment 5: Crew Analysis

-- Identify the columns in the names table that have null values.

select * from names;
select count(id) from names 
where id = null;

 select count(name) from names
 where name = null;
 
 select count(height) from names
 where height = null;
 
 select count(date_of_birth) from names
 where date_of_birth = null;
 
 select count(known_for_movies) from names
 where known_for_movies = null;
 
-- Determine the top three directors in the top three genres with movies having an average rating > 8.

select * from director_mapping;
select * from genre;
select * from names;
select * from ratings;
select * from movie;

select D.name,B.genre, A.title from movie as A
join genre as B
on A.id = B.movie_id
join director_mapping as C
on c.movie_id = A.id
join names as  D
on D.id = c.name_id 
join ratings as E
on A.id = E.movie_id
where E.avg_rating >8
limit 3;

-- Determine the top three directors in the top three genres with movies having an average rating > 8.
select * from movie;
select * from genre;
select * from director_mapping;
select * from names;
select * from ratings;
select * from role_mapping;

WITH TopGenres AS (
    SELECT g.genre,
           AVG(r.avg_rating) AS avg_genre_rating
    FROM Genre g
    JOIN Ratings r ON g.movie_id = r.movie_id
    GROUP BY g.genre
    ORDER BY avg_genre_rating DESC
    LIMIT 3
),
TopRatedMovies AS (
    SELECT g.genre,
           g.movie_id,
           r.avg_rating
    FROM Genre g
    JOIN Ratings r ON g.movie_id = r.movie_id
    WHERE r.avg_rating > 8
    AND g.genre IN (SELECT genre FROM TopGenres)
),
Directors AS (
    SELECT dm.movie_id,
           n.name,
           g.genre
    FROM Director_Mapping dm
    JOIN Names n ON dm.name_id = n.id
    JOIN TopRatedMovies trm ON dm.movie_id = trm.movie_id
    JOIN Genre g ON trm.movie_id = g.movie_id
),
DirectorCount AS (
    SELECT d.name,
           d.genre,
           COUNT(d.movie_id) AS movie_count
    FROM Directors d
    GROUP BY d.name, d.genre
),
TopDirectors AS (
    SELECT genre,
           name,
           movie_count,
           ROW_NUMBER() OVER (PARTITION BY genre ORDER BY movie_count DESC) as rankk
    FROM DirectorCount
)
SELECT genre, name, movie_count
FROM TopDirectors
WHERE rankk <= 3;



-- Find the top two actors whose movies have a median rating >= 8.


WITH ActorMovies AS (
    SELECT rm.name_id, rm.movie_id, r.median_rating
    FROM role_mapping rm
    JOIN ratings r ON rm.movie_id = r.movie_id
    WHERE rm.category = 'actor' 
),


FilteredActorMovies AS (
    SELECT name_id, movie_id
    FROM ActorMovies
    WHERE median_rating >= 8
),

ActorMovieCounts AS (
    SELECT name_id, COUNT(movie_id) AS movie_count
    FROM FilteredActorMovies
    GROUP BY name_id
),


TopTwoActors AS (
    SELECT name_id, movie_count
    FROM ActorMovieCounts
    ORDER BY movie_count DESC
    LIMIT 2
)


SELECT n.name, tta.movie_count
FROM TopTwoActors tta
JOIN names n ON tta.name_id = n.id;


-- Identify the top three production houses based on the number of votes received by their movies.



WITH ProductionHouseVotes AS (
    SELECT m.production_company, r.total_votes
    FROM movie m
    JOIN ratings r ON m.id = r.movie_id
),
 ProductionHouseTotalVotes AS (
    SELECT production_company, SUM(total_votes) AS total_votes
    FROM ProductionHouseVotes
    GROUP BY production_company
)
SELECT production_company, total_votes
FROM ProductionHouseTotalVotes
ORDER BY total_votes DESC
LIMIT 3;


-- Rank actors based on their average ratings in Indian movies released in India.



WITH IndianMovies AS (
    SELECT id AS movie_id
    FROM movie
    WHERE country = 'India'
)
, ActorMovieRatings AS (
    SELECT rm.name_id, r.avg_rating
    FROM role_mapping rm
    JOIN ratings r ON rm.movie_id = r.movie_id
    JOIN IndianMovies im ON rm.movie_id = im.movie_id
    WHERE rm.category = 'actor'
)
, ActorAverageRatings AS (
    SELECT name_id, AVG(avg_rating) AS avg_rating
    FROM ActorMovieRatings
    GROUP BY name_id
)
SELECT n.name, aar.avg_rating
FROM ActorAverageRatings aar
JOIN names n ON aar.name_id = n.id
ORDER BY aar.avg_rating DESC;


-- Identify the top five actresses in Hindi movies released in India based on their average ratings.

SELECT n.name, avg_rating
FROM role_mapping rm
JOIN ratings r ON rm.movie_id = r.movie_id
JOIN movie m ON rm.movie_id = m.id
JOIN names n ON rm.name_id = n.id
WHERE rm.category = 'actress'
  AND m.country = 'India'
  AND m.languages LIKE '%Hindi%'
ORDER BY avg_rating DESC
LIMIT 5;


-- Segment 6: Broader Understanding of Data

-- Classify thriller movies based on average ratings into different categories.

SELECT m.title, r.avg_rating,
       CASE
           WHEN r.avg_rating >= 8.5 THEN 'Excellent'
           WHEN r.avg_rating >= 7.0 THEN 'Good'
           WHEN r.avg_rating >= 5.0 THEN 'Average'
           ELSE 'Poor'
       END AS rating_category
FROM movie m
JOIN ratings r ON m.id = r.movie_id
JOIN genre g ON m.id = g.movie_id
WHERE g.genre = 'Thriller';


-- analyse the genre-wise running total and moving average of the average movie duration.

SELECT
    genre,
    AVG(duration) AS avg_duration,
    SUM(AVG(duration)) OVER (PARTITION BY genre ORDER BY genre ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total,
    AVG(AVG(duration)) OVER (PARTITION BY genre ORDER BY genre ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_avg
FROM
    Movie AS m
JOIN
    Genre AS g ON m.id = g.movie_id
GROUP BY
    genre
ORDER BY
    genre;


-- Identify the five highest-grossing movies of each year that belong to the top three genres.



WITH TopGenres AS (
    SELECT 
        g.genre
    FROM 
        Genre g
    JOIN 
        Movie m ON g.movie_id = m.id
    GROUP BY 
        g.genre
    ORDER BY 
        SUM(m.worlwide_gross_income) DESC
    LIMIT 3
),
 RankedMovies AS (
    SELECT 
        m.year, 
        m.title, 
        g.genre, 
        m.worlwide_gross_income,
        ROW_NUMBER() OVER (PARTITION BY m.year, g.genre ORDER BY m.worlwide_gross_income DESC) AS rn
    FROM 
        Movie m
    JOIN 
        Genre g ON m.id = g.movie_id
    WHERE 
        g.genre IN (SELECT genre FROM TopGenres)
)
SELECT 
    year, 
    title, 
    genre, 
    worlwide_gross_income
FROM 
    RankedMovies
WHERE 
    rn <= 5
ORDER BY 
    year, 
    genre, 
    worlwide_gross_income DESC
LIMIT 1000;



select * from movie;


-- Determine the top two production houses that have produced the highest number of hits among multilingual movies.
WITH MultilingualHits AS (
     SELECT m.id, m.production_company
    FROM Movie AS m
    JOIN Ratings AS r ON m.id = r.movie_id
    WHERE (SELECT COUNT(DISTINCT languages)
           FROM movie)  > 1
      AND r.avg_rating > 8

)

SELECT production_company, COUNT(*) AS hit_count
FROM MultilingualHits
where production_company is not null 
GROUP BY production_company
ORDER BY hit_count DESC
LIMIT 2;  


-- Identify the top three actresses based on the number of Super Hit movies (average rating > 8) in the drama genre.

SELECT 
    d.name,
    COUNT(*) AS movie_hits
FROM 
    Movie a
JOIN 
    Genre b ON a.id = b.movie_id
JOIN 
    Role_Mapping c ON a.id = c.movie_id
JOIN 
    Names d ON c.name_id = d.id
Join
    ratings e on a.id = e.movie_id
WHERE 
    b.genre = 'Drama'
    AND e.avg_rating > 8
    AND c.category = 'Actress'
GROUP BY 
    d.name
ORDER BY 
    movie_hits DESC
LIMIT 3;


-- Retrieve details for the top nine directors based on the number of movies, including average inter-movie duration, ratings, and more.

select * from movie;

WITH Hits AS (
     SELECT
         m.id,
         m.production_company,
         m.languages,
         r.avg_rating
     FROM
         Movie m
     JOIN
         Ratings r ON m.id = r.movie_id
     WHERE
         r.avg_rating > 8
         AND INSTR(m.languages, ',') > 0  -- Multilingual check assuming languages are comma-separated
 ),
 ProductionHouseHits AS (
     SELECT
         production_company,
         COUNT(id) AS hit_count
     FROM
         Hits
     GROUP BY
         production_company
 )
 SELECT
     production_company,
     hit_count
 FROM
     ProductionHouseHits
 ORDER BY
     hit_count DESC
 LIMIT 2;
	
    
	-- Based on the analysis, provide recommendations for the types of content Bolly movies should focus on producing.
    
    
    /*
    Recommendations for Bollywood Movie Production
Focus on Popular and High-Rated Genres

Drama and Romance: These genres often attract a broad audience due to their emotional appeal and relatable stories. Ensure high-quality storytelling, strong character development, and engaging plots.
Thriller and Action: These genres consistently perform well with high ratings. Investing in good scripts, special effects, and innovative action sequences can enhance viewer engagement.
Comedy: Light-hearted content with universal humor can appeal to a wide demographic, making it a safe bet for consistent returns.
Capitalize on Top Talent

Successful Directors: Collaborate with directors who have a track record of delivering critically acclaimed and commercially successful films. Their vision and experience can significantly impact a movie's success.
Popular Actors: Cast actors who are not only popular but have also been part of highly rated films. Their star power combined with proven acting skills can draw audiences to theaters.
Cater to Viewer Demographics and Preferences

Youth-Oriented Content: Younger audiences often drive box office revenues. Focus on themes and stories that resonate with them, such as coming-of-age stories, college romances, and contemporary social issues.
Family-Friendly Movies: Films that cater to family audiences, with clean humor and positive messages, tend to perform well, especially during festive seasons and holidays.
Analyze Trends and Adapt

Historical Success Patterns: Look at the ratings and reviews of movies over the past decade to identify patterns and trends. Genres or themes that consistently receive high ratings should be prioritized.
Emerging Themes: Stay ahead of trends by analyzing new themes and genres gaining popularity globally. For instance, sci-fi and fantasy genres have seen a rise in interest.
Enhance Production Quality

Invest in Technology: High-quality production values, including better special effects, sound design, and cinematography, can significantly enhance the viewer experience.
Script and Screenplay: Strong scripts and engaging screenplays are crucial. Focus on original stories or well-adapted remakes that offer fresh perspectives.
Leverage Data Analytics

Audience Feedback: Regularly analyze viewer feedback and ratings to understand what works and what doesn't. This can help in making informed decisions for future projects.
Market Research: Conduct thorough market research to identify gaps in the current offerings and explore new opportunities.
By focusing on these areas, Bollywood can create content that not only appeals to a wide audience but also maintains high standards of quality and storytelling, ensuring both critical and commercial success 
*/