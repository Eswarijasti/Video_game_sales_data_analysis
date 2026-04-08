CREATE DATABASE VIDEO_GAME;
USE  VIDEO_GAME;

DROP TABLE IF EXISTS games;
CREATE TABLE games (
    game_id INT PRIMARY KEY,
    title VARCHAR(255),
    release_date VARCHAR(255),
    team VARCHAR(255),
    rating DECIMAL(10,2),
    times_listed DECIMAL(10,2),
    number_of_reviews DECIMAL(10,2),
    genres VARCHAR(255),
    summary TEXT,
	Reviews TEXT,
    plays DECIMAL(10,2),
    playing DECIMAL(10,2),
    backlogs DECIMAL(10,2),
    wishlist DECIMAL(10,2)
);
 
 Drop table sales;
CREATE TABLE sales (
    sale_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255),
    platform VARCHAR(50),
    year INT,
    genre VARCHAR(100),
    publisher VARCHAR(255),
    na_sales FLOAT,
    eu_sales FLOAT,
    jp_sales FLOAT,
    other_sales FLOAT,
    global_sales FLOAT
);


SELECT * FROM games;
SELECT * FROM sales;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/clean_games.csv'
INTO TABLE games
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/clean_sales.csv'
INTO TABLE sales
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;



UPDATE games
SET 
    Genres = COALESCE(NULLIF(Genres, '[]'), 'unknown');
-- top rated games 
SELECT *
FROM games
ORDER BY rating DESC
LIMIT 10;

-- best deelopers
SELECT team, AVG(rating) AS avg_rating
FROM games
GROUP BY team
ORDER BY avg_rating DESC;

-- most commonly play
SELECT genres, COUNT(*) AS count
FROM games
GROUP BY genres
ORDER BY count DESC;

-- sales data by region
SELECT 
    SUM(na_sales) AS NA,
    SUM(eu_sales) AS EU,
    SUM(jp_sales) AS JP
FROM sales;




drop table if exists game_metadata;

CREATE TABLE game_metadata (
game_id INT auto_increment PRIMARY KEY,
    title VARCHAR(255),
    genre VARCHAR(100),
    release_date VARCHAR(20)
);

select * from game_metadata;

SELECT g.game_id, COUNT(*)
FROM games g
LEFT JOIN sales s ON g.Title = s.Name
GROUP BY g.game_id
HAVING COUNT(*) > 1;

INSERT INTO game_metadata (title, genre, release_date)
SELECT DISTINCT
   g.Title,
    g.Genres,
   g.Release_Date 
FROM games g left join sales s on g.Title=s.Name;


drop table if exists sales_data;

CREATE TABLE sales_data (
    sale_id INT PRIMARY KEY AUTO_INCREMENT,
    game_id INT,
    na_sales FLOAT,
    eu_sales FLOAT,
    jp_sales FLOAT,
    global_sales FLOAT,
	other_sales Float,
    Platform TEXT,
    Publisher TEXT,
    year INT,
    FOREIGN KEY (game_id) REFERENCES game_metadata(game_id)
);

INSERT INTO sales_data (game_id, na_sales, eu_sales, jp_sales, global_sales,other_sales,Platform,Publisher,year)
SELECT DISTINCT
    gm.game_id,
    s.NA_Sales,
    s.EU_Sales,
    s.JP_Sales,
    s.Global_Sales,
    s.other_sales,
    s.Platform,
    s.Publisher,
    s.year
    
FROM sales s
JOIN game_metadata gm 
ON s.Name = gm.title;

select * from sales_data;

Drop table if exists game_stats;

CREATE TABLE game_stats (
    stat_id INT PRIMARY KEY AUTO_INCREMENT,
    game_id INT,
    rating DECIMAL(10,1),
    plays DECIMAL(10,2),
    reviews TEXT,
   wishlist decimal(10,2),
    FOREIGN KEY (game_id) REFERENCES game_metadata(game_id)
);

INSERT INTO game_stats (game_id, rating, plays, reviews,wishlist)
SELECT DISTINCT
    gm.game_id,
    g.Rating,
    g.Plays,
    g.Reviews,
    g.wishlist
FROM games g
JOIN game_metadata gm 
ON (TRIM(g.Title)) = (TRIM(gm.title));

select * from game_stats;
