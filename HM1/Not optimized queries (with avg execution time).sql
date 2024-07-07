############################################################################################################################################
#(1) All athletes who have taken part in more than 3 individual Olympic Games ("Athletes" in the result table) with the respective country #
############################################################################################################################################	
#Table without constraints - NOT OPTIMIZED
SELECT DISTINCT r.athlete_full_name, a.games_participations, r.country_name
FROM `olympics-base`.results r
JOIN `olympics-base`.athletes a ON a.athlete_full_name=r.athlete_full_name
WHERE r.participant_type = 'Athlete'
AND a.games_participations > 3
ORDER BY a.games_participations DESC;

#AVG execution Time : 0.415 sec
#Ian Miller holds the record for most appearances in history
# we have same atheltes names with different nationalities because they can change nationality to have an higher chance to get elected


############################################################################################################
#(2) How many people won a gold or silver medal in the Summer Olympic that were held between 1896 and 1956 #
############################################################################################################
#Table without constraints - NOT OPTIMIZED
SELECT h.game_location, h.game_year, COUNT(*) AS athlete_count
FROM `olympics-base`.medals m
JOIN `olympics-base`.hosts h ON m.slug_game = h.game_slug
WHERE h.game_year BETWEEN 1896 AND 1956
AND (m.medal_type = 'GOLD' OR m.medal_type = 'SILVER')
AND h.game_season = 'Summer'
GROUP BY h.game_year, h.game_location
ORDER BY game_year ASC;

#AVG execution Time : 0.040 sec
#The first Olympic was in 1896. II World War ended in 1945 so the olimpics weren't held from 1936-1948 (They were cancelled in 1940 and 1944), also during the 
#I World War 1914-1918 the olympics were cancelled in 1916

####################################################################################################
#(3) Number of participants in Japanese summer women's matches with the event and discipline title # -> Linked to the II WW query we did before
####################################################################################################
#Table without constraints - NOT OPTIMIZED
SELECT h.game_year, h.game_location, COUNT(*) AS num_participants
FROM `olympics-base`.results r
JOIN `olympics-base`.hosts h ON r.slug_game = h.game_slug
WHERE (r.event_title LIKE '%women%' OR r.event_title LIKE '%Women%')
AND h.game_season='Summer' 
AND r.country_name = 'Japan'
GROUP BY h.game_year, h.game_location
ORDER BY game_year ASC;

#AVG execution Time : 0.616 sec

# II WW -> partecipation decrease between 1936 and 1952
#Japan (sort of) women's right = 1945 -> partecipation increase (after)
#1972 -> Japanese General Election - first change in government since the II WW


#####################################################################################################################################################
#(4) For every athlete, the number of individual Olympic Games, during the pandemic (2019-2022), in which each athlete participated but did not win,#
#along with the worst rank they achieved ############################################################################################################
##########################################
#Table without constraints - NOT OPTIMIZED
SELECT r.athlete_full_name, r.country_name, MAX(r.rank_position) AS worst_rank, COUNT(CASE WHEN r.medal_type IS NULL THEN 1 ELSE 0 END) AS games_lost, r.discipline_title
FROM `olympics-base`.results r
JOIN `olympics-base`.hosts h ON h.game_slug = r.slug_game
WHERE YEAR(h.game_start_date) >= 2019
AND YEAR(h.game_end_date) <= 2022
AND r.rank_position != 'WDR' #WDR = Win by Withdrawal
AND r.participant_type= 'Athlete'
GROUP BY r.athlete_full_name, r.country_name, r.discipline_title
ORDER BY games_lost DESC;
#We consider DNF (Did Not Finish), DNS (Did Not Start), DNC (Did Not Come) worse than a bad rank
#ROC = Russian Olympic Committee

#AVG execution Time : 0.487 sec	


###########################################################################################################################################
#(5) All participants, with less than 40 years old, of individual Olympic games who have won more medals than the oldest champion (>= 40) #
###########################################################################################################################################

#Table without constraints 
SELECT a.athlete_full_name, a.athlete_year_birth, COUNT(m.medal_type) as medals, m.discipline_title, m.country_name
FROM `olympics-base`.athletes a
JOIN `olympics-base`.medals m ON a.athlete_full_name = m.athlete_full_name
WHERE a.athlete_year_birth > (YEAR(NOW()) - 40) #1984
AND m.participant_type = 'Athlete'
GROUP BY a.athlete_full_name, a.athlete_year_birth, m.discipline_title, m.country_name
HAVING medals > (
SELECT MAX(old_medals)
FROM (SELECT COUNT(m2.medal_type) AS old_medals
	  FROM `olympics-base`.athletes a2
      JOIN `olympics-base`.medals m2 ON a2.athlete_full_name = m2.athlete_full_name
	  WHERE a2.athlete_year_birth < (YEAR(NOW()) - 40) #1984
      AND m2.participant_type = 'Athlete'
	  GROUP BY a2.athlete_full_name
	  ) AS max_medals
)
ORDER BY medals DESC; 

#AVG execution Time : 0.481 sec


############################################################################################################################################################
#(6) For each year, the number of gold medals won by athletes taking part in the Winter Olympic Games, with the average age of the athletes per Games year #
############################################################################################################################################################
#Table without constraints
SELECT h.game_year, COUNT(*) AS gold_medals, AVG(h.game_year - a.athlete_year_birth) AS average_age
FROM `olympics-base`.hosts h
JOIN `olympics-base`.medals m ON m.slug_game = h.game_slug
JOIN `olympics-base`.athletes a ON m.athlete_full_name = a.athlete_full_name
WHERE m.medal_type = 'Gold'
AND h.game_season = 'Winter'
GROUP BY h.game_year
ORDER BY h.game_year ASC;

#AVG execution Time : 0.250 sec