-- TASK 1
SELECT enemy_name as "Enemy", incident_desc as "Fault description" FROM incidents
WHERE TO_CHAR(incident_date, 'YYYY') = '2009';

-- TASK 2
SELECT name, function, in_herd_since as "WITH AS FROM" FROM cats
WHERE in_herd_since BETWEEN TO_DATE('2005-09-01') AND TO_DATE('2007-07-31');

-- TASK 3
SELECT enemy_name as "ENEMY", species, hostility_degree as "HOSTILITY DEGREE"
FROM enemies
ORDER BY hostility_degree ASC;

-- TASK 4
SELECT 
    NAME || ' called ' || NICKNAME || ' (fun. ' || FUNCTION || ') has been catching mice in band ' || BAND_NO || ' since ' || TO_CHAR(IN_HERD_SINCE) AS ALL_ABOUT_MALE_CATS
FROM 
    cats
WHERE 
    GENDER = 'M'
ORDER BY IN_HERD_SINCE DESC, NICKNAME ASC;

-- TASK 5
-- REGEXP_REPLACE (source_string, pattern, replace_string, start_position, match_occurrence, match_parameter)
-- INSTR function returns the position of the first occurrence of a substring in a string. If the substring isn't found, it returns 0.
SELECT 
    NICKNAME,
REGEXP_REPLACE(REGEXP_REPLACE(NICKNAME, 'A', '#', 1, 1), 'L', '%', 1, 1)
   "After replacing A and L"
FROM 
    Cats
WHERE 
    INSTR(NICKNAME, 'A') > 0 AND INSTR(NICKNAME, 'L') > 0;
    
-- TASK 6
-- use SYSDATE for current date
SELECT name , in_herd_since "In herd", CEIL(mice_ration * 0.9) "Ate", ADD_MONTHS(in_herd_since, 6) "Increase", mice_ration "Eat"
FROM Cats
WHERE in_herd_since <= ADD_MONTHS(TO_DATE('2020-04-04'), -132)
AND EXTRACT(MONTH FROM in_herd_since) BETWEEN 3 AND 9
ORDER BY mice_ration DESC;

-- TASK 7

SELECT name, mice_ration * 3 "MICE QUARTERLY", NVL(mice_extra, 0) * 3 "EXTRA QUATERLY"
FROM Cats
WHERE mice_ration > NVL(mice_extra * 2, 0)
AND mice_ration >= 55
ORDER BY mice_ration DESC, name ASC;

-- TASK 8

SELECT name, 
    CASE
    	WHEN (NVL(mice_ration,0) * 12) > 660 THEN TO_CHAR((NVL(mice_ration,0) * 12))
    	WHEN (NVL(mice_ration,0) * 12) = 660 THEN 'LIMIT'
		WHEN (NVL(mice_ration,0) * 12) < 660 THEN 'Below 660'
	END "Eats annually"
FROM Cats
ORDER BY name ASC;

-- TASK 9

SELECT nickname, in_herd_since "IN HERD",  
    CASE
        WHEN NEXT_DAY(LAST_DAY('2020-10-27')-7,'WEDNESDAY') >= '2020-10-27' THEN  
        CASE
    		WHEN EXTRACT(DAY FROM in_herd_since) BETWEEN 1 AND 15 THEN NEXT_DAY(LAST_DAY('2020-10-27')-7,'WEDNESDAY')
        	ELSE NEXT_DAY(LAST_DAY(ADD_MONTHS('2020-10-27',1))-7,'WEDNESDAY')
    	END
	ELSE NEXT_DAY(LAST_DAY(ADD_MONTHS('2020-10-27',1))-7,'WEDNESDAY')
END "PAYMENT"
FROM cats
ORDER BY in_herd_since;

SELECT nickname, in_herd_since "IN HERD",  
    CASE
        WHEN NEXT_DAY(LAST_DAY('2020-10-29')-7,'WEDNESDAY') >= '2020-10-29' THEN  
        CASE
    		WHEN EXTRACT(DAY FROM in_herd_since) BETWEEN 1 AND 15 THEN NEXT_DAY(LAST_DAY('2020-10-29')-7,'WEDNESDAY')
        	ELSE NEXT_DAY(LAST_DAY(ADD_MONTHS('2020-10-29',1))-7,'WEDNESDAY')
    	END
	ELSE NEXT_DAY(LAST_DAY(ADD_MONTHS('2020-10-29',1))-7,'WEDNESDAY')
END "PAYMENT"
FROM cats
ORDER BY in_herd_since;

-- TASK 10
SELECT 
	CASE
		WHEN COUNT(nickname) = 1 THEN nickname || ' - unique'
		ELSE nickname || ' - non-unique'
	END "The uniqueness of the nickname"
FROM cats
GROUP BY nickname
ORDER BY nickname ASC;

SELECT 
	CASE
		WHEN COUNT(chief) = 1 THEN chief || ' - unique'
		ELSE chief || ' - non-unique'
	END "The uniqueness of the chief"
FROM cats
GROUP BY chief
ORDER BY chief ASC;

-- TASK 11
SELECT nickname, COUNT(ENEMY_NAME) "Number of enemies"
FROM Incidents
GROUP BY nickname
HAVING COUNT(ENEMY_NAME) >= 2;

-- TASK 12
SELECT 'Number of cats= ' || COUNT(*) || ' hunts as '|| function || ' and eats max. ' || TO_CHAR(MAX(NVL(mice_ration, 0) + NVL(mice_extra, 0))) ||' mice per month'
FROM Cats
WHERE function <> 'BOSS'
AND gender <> 'M'
GROUP BY function
HAVING AVG(mice_ration + NVL(mice_extra, 0)) > 50;

-- TASK 13
SELECT band_no, gender, MIN(NVL(mice_ration, 0)) "Minimum ration"
FROM cats
GROUP BY band_no, gender;

-- LEVEL: column that indicates the depth of a row in a hierarchical query.
-- START WITH: Specifies the root row(s) from which the hierarchical query begins.
-- CONNECT BY: Defines the parent-child relationship between rows in a hierarchical query.
-- PRIOR: Refers to the parent row's value in a hierarchical query's CONNECT BY condition.
-- TASK 14
SELECT LEVEL, Nickname, Function, Band_No
FROM Cats
START WITH Function = 'THUG' AND gender = 'M'
CONNECT BY PRIOR Nickname = chief
ORDER BY LEVEL, Nickname;

-- TASK 15
SELECT LPAD((LEVEL-1),(LEVEL-1)*4+1,'===>') ||'			' || Name, NVL(Chief, 'Master yourself') "Nickname of the Chief", Function
FROM Cats
WHERE Function IS NOT NULL
CONNECT BY PRIOR Nickname = chief
START WITH chief IS NULL;

-- TASK 16
SELECT LPAD(' ', 2*(LEVEL)) || nickname "Path of chiefs"
FROM cats
CONNECT BY nickname = PRIOR chief
START WITH gender = 'M'
AND mice_extra IS NULL
AND in_herd_since <= ADD_MONTHS(TO_DATE('2020-04-04'), -132);


