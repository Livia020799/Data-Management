#######################################################################################################################################################
#(1) Select the distinct full names and the number of games participated in by athletes who were born after 1994 and have not won more than one medal.#
#It orders the results by the number of games participated in, in descending order.####################################################################
####################################################################################
#Table without constraints
SELECT DISTINCT a.athlete_full_name, a.games_participations 
FROM `olympics-base`.athletes a
WHERE a.athlete_year_birth > 1994
AND NOT EXISTS (
    SELECT *
    FROM `olympics-base`.medals m
    WHERE a.athlete_full_name = m.athlete_full_name
    AND (SELECT COUNT(*) 
         FROM `olympics-base`.medals m2 
         WHERE m2.athlete_full_name = m.athlete_full_name) > 1 
    #counts the number of medals greater than 1 for each athlete
) 
ORDER BY a.games_participations  DESC;

#AVG execution Time : 5.5 minutes

#Table with constraints - OPTIMIZATION WITH VIEW (MySQL doesn't allow materialized views)
USE olympics;

CREATE VIEW athletes_medal_counts AS
SELECT a.athlete_full_name, a.games_participations, a.athlete_year_birth, COUNT(m.medal_type) AS medal_count
FROM olympics.athletes a
LEFT JOIN olympics.medals m ON a.ID_athlete = m.ID_athletes
GROUP BY a.athlete_full_name, a.games_participations, a.athlete_year_birth ;

SELECT athlete_full_name, games_participations, medal_count
FROM athletes_medal_counts
WHERE medal_count > 1
AND athlete_year_birth > 1994
ORDER BY medal_count DESC;

#AVG execution Time : 0.119 sec
#You can partecipate in more than one discipline in one game


##############################################################################################################
#(2) Medal type and host of the games won by Italian athletes, age < 25, at the Olympic Summer Games in Tokyo#
##############################################################################################################	
#Table without constraints
SELECT DISTINCT m.athlete_full_name, m.slug_game, m.discipline_title, m.medal_type
FROM `olympics-base`.medals m
WHERE m.slug_game LIKE "tokyo-%" 
AND m.country_name = "Italy" 
AND YEAR(NOW()) - 
	(SELECT a.athlete_year_birth 
	FROM `olympics-base`.athletes a 
	WHERE a.athlete_full_name = m.athlete_full_name) < 25
AND 
	(SELECT h.game_season 
	FROM `olympics-base`.hosts h 
	WHERE h.game_slug = m.slug_game) = "Summer";
	
#AVG execution Time : 5.200 sec

#Table with constraints - OPTIMIZATION WITH EXPLICIT JOIN AND FOREIGN/PRIMARY KEY - rewriting the SQL query (without changing its meaning)
SELECT DISTINCT m.athlete_full_name, m.slug_game, m.discipline_title, m.medal_type
FROM olympics.medals m
JOIN olympics.athletes a ON a.ID_athlete = m.ID_athletes
JOIN olympics.hosts h ON h.ID_hosts = m.ID_hosts
WHERE m.slug_game LIKE "tokyo-%" 
AND m.country_name = "Italy" 
AND YEAR(NOW()) - a.athlete_year_birth < 25
AND h.game_season = "Summer";
	
#AVG execution Time : 0.038 sec



##################################################################################################################################################################################
#(3) Find the athlete, among the individual olimpic games, with the highest number of "DNF", "DNS", "DNC" rank positions (with at least one DNF and one DNS) in the olimpic game #
#that has the highest number of such rank positions ##############################################################################################################################
####################################################
#Table without constraints - NOT OPTIMIZED
SELECT r.athlete_full_name, r.country_name, SUM(CASE WHEN r.rank_position IN ('DNF', 'DNS', 'DNC') THEN 1 ELSE 0 END) AS dnf_dns_dnc_count, r.slug_game
FROM `olympics-base`.results r
WHERE r.slug_game = (SELECT r2.slug_game
					 FROM `olympics-base`.results r2
                     GROUP BY r2.slug_game
					 ORDER BY SUM(CASE WHEN r2.rank_position IN ('DNF', 'DNS', 'DNC') THEN 1 ELSE 0 END) DESC
					 LIMIT 1
					)
AND r.participant_type = 'Athlete'
GROUP BY r.athlete_full_name, r.slug_game, r.country_name
HAVING SUM(CASE WHEN r.rank_position IN ('DNF', 'DNS') THEN 1 ELSE 0 END) > 2
ORDER BY dnf_dns_dnc_count DESC
LIMIT 1;
#AVG execution Time : 1.30 sec

#Table with constraints  - OPTIMIZATION WITH THE CREATION OF ANOTHER TABLE
USE olympics;

CREATE TABLE table_results AS
SELECT r.athlete_full_name, r.country_name, SUM(CASE WHEN r.rank_position IN ('DNF', 'DNS', 'DNC') THEN 1 ELSE 0 END) AS dnf_dns_dnc_count, SUM(CASE WHEN r.rank_position IN ('DNF', 'DNS') THEN 1 ELSE 0 END) AS dnf_dns_count, r.slug_game
FROM olympics.results r
WHERE r.participant_type = 'Athlete'
GROUP BY r.athlete_full_name, r.slug_game, r.country_name;

SELECT r.athlete_full_name, r.country_name, r.dnf_dns_dnc_count, r.slug_game
FROM table_results r
WHERE r.slug_game = (
    SELECT slug_game
    FROM table_results
    GROUP BY slug_game
    ORDER BY SUM(dnf_dns_dnc_count) DESC
    LIMIT 1
)
AND r.dnf_dns_count > 2
ORDER BY r.dnf_dns_dnc_count DESC
LIMIT 1;

#AVG execution Time : 0.471 sec




##############################################################################################################################################
#(4) Selects the athlete's full name, country name, game name, and game location of those who were born after 1980 and have won more than one#
#gold medal in the Olympic Games hosted by their own country, considering only the games held between 1980 and 2020 ##########################
####################################################################################################################
#Table without constraints 
SELECT DISTINCT m.athlete_full_name, m.country_name, h.game_name, h.game_location
FROM `olympics-base`.medals m
JOIN `olympics-base`.hosts h ON m.slug_game = h.game_slug
JOIN `olympics-base`.athletes a ON a.athlete_full_name = m.athlete_full_name
WHERE m.medal_type = "GOLD"
AND a.athlete_year_birth > 1980
AND h.game_location = m.country_name
AND (SELECT COUNT(*) 
	 FROM `olympics-base`.medals m2 
	 JOIN `olympics-base`.hosts h2 ON m2.slug_game = h2.game_slug
	 WHERE m2.athlete_full_name = m.athlete_full_name 
	 AND m2.medal_type = "GOLD" 
	 AND h2.game_location = m.country_name
     AND h2.game_year BETWEEN 1980 AND 2020
	) > 1;

#AVG execution Time : 6.037 sec	
	
#Table with constraints - OPTIMIZATION WITH INDEXING
CREATE INDEX idx_medals_subquery ON olympics.medals (slug_game(100), medal_type(10));
CREATE INDEX idx_hosts_game_location_game_year ON olympics.hosts (game_location(100), game_year);
CREATE INDEX idx_hosts_subquery ON olympics.hosts (game_year);
	
SELECT DISTINCT m.athlete_full_name, m.country_name, h.game_name, h.game_location
FROM olympics.medals m
JOIN olympics.hosts h ON m.slug_game = h.game_slug
JOIN olympics.athletes a ON a.athlete_full_name = m.athlete_full_name
WHERE m.medal_type = "GOLD"
AND a.athlete_year_birth > 1980
AND h.game_location = m.country_name
AND (SELECT COUNT(*) 
	 FROM olympics.medals m2 
	 JOIN olympics.hosts h2 ON m2.slug_game = h2.game_slug
	 WHERE m2.athlete_full_name = m.athlete_full_name 
	 AND m2.medal_type = "GOLD" 
	 AND h2.game_location = m.country_name
	 AND h2.game_year BETWEEN 1980 AND 2020
	) > 1;

#AVG execution Time : 0.043 sec	
