USE  `olympics`;

CREATE TABLE `athletes` (
		`ID_athlete` int NOT NULL PRIMARY KEY,
		`athlete_full_name` text NOT NULL,
		`games_participations` int NOT NULL,
		`first_game` text NOT NULL,
		`athlete_year_birth` int DEFAULT NULL
) ENGINE=InnoDB AUTO_INCREMENT=7932 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\olympic_athletes_new.csv"
INTO TABLE athletes
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;


CREATE TABLE `hosts` (
	`game_slug` text NOT NULL, 
	`game_end_date` datetime NOT NULL, 
	`game_start_date` datetime NOT NULL, 
	`game_location` text NOT NULL, 
	`game_name` text NOT NULL, 
	`game_season` text NOT NULL, 
	`game_year` int NOT NULL
     ) ENGINE=InnoDB AUTO_INCREMENT=7932 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
     
LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\olympic_hosts_new.csv"
INTO TABLE hosts
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;


CREATE TABLE `medals` (
	`ID_medals` int NOT NULL PRIMARY KEY,
	`discipline_title` text NOT NULL, 
	`slug_game` text NOT NULL ,
	`event_title` text , 
	`event_gender` text, 
	`medal_type` text NOT NULL, 
	`participant_type` text, 
	`athlete_full_name` text NOT NULL,
     `country_name` text,
     `ID_hosts` int NOT NULL,
     `ID_athletes` int NOT NULL
     ) ENGINE=InnoDB AUTO_INCREMENT=7932 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\olympic_medals_new.csv"
INTO TABLE medals
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;


CREATE TABLE `results` (
	`ID_results` int NOT NULL PRIMARY KEY,
	`discipline_title` text NOT NULL, 
	`event_title` text, 
	`slug_game` text NOT NULL, 
    `participant_type` text NOT NULL, 
	`medal_type` text, 
	`athletes` text, 
	`rank_position` tinytext NOT NULL, 
    `country_name` text, 
    `athlete_full_name` text,
    `ID_hosts` int NOT NULL
     ) ENGINE=InnoDB AUTO_INCREMENT=7932 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
     
LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\olympic_results_new.csv"
INTO TABLE results
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;