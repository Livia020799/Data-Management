USE  `olympics-base`;

CREATE TABLE `athletes` (
	  `athlete_full_name` text,
	  `games_participations` int,
	  `first_game` text,
	  `athlete_year_birth` int 
) ENGINE=InnoDB AUTO_INCREMENT=7932 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\olympic_athletes_base.csv"
INTO TABLE athletes
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

CREATE TABLE `medals` (
	`discipline_title` text, 
    `slug_game` text,
	`event_title` text, 
	`event_gender` text, 
	`medal_type` text, 
	`participant_type` text, 
	`athlete_full_name` text,
     `country_name` text
     ) ENGINE=InnoDB AUTO_INCREMENT=7932 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\olympic_medals_base.csv"
INTO TABLE medals
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

CREATE TABLE `hosts` (
	`game_slug` text, 
	`game_end_date` datetime, 
	`game_start_date` datetime, 
	`game_location` text, 
	`game_name` text, 
	`game_season` text, 
	`game_year` int 
     ) ENGINE=InnoDB AUTO_INCREMENT=7932 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
     
LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\olympic_hosts_base.csv"
INTO TABLE hosts
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;


CREATE TABLE `results` (
	`discipline_title` text, 
	`event_title` text, 
	`slug_game` text, 
    `participant_type` text, 
	`medal_type` text, 
	`athletes` text, 
	`rank_position` tinytext, 
    `country_name` text, 
    `athlete_full_name` text  
     ) ENGINE=InnoDB AUTO_INCREMENT=7932 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
     
LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\olympic_results_base.csv"
INTO TABLE results
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;