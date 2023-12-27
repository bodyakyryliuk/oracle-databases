-- TASK 17
--
-- Modification: the most cats are hunting (not exactly in field area)
SELECT nickname "Hunts in the field", mice_ration, bands.name, site
FROM cats
JOIN bands ON cats.band_no = bands.band_no
WHERE mice_ration > 50
AND site = (
    SELECT site
    FROM (
        SELECT site, COUNT(*) as cat_count
        FROM cats
        JOIN bands ON cats.band_no = bands.band_no
        GROUP BY site
        ORDER BY cat_count DESC
    )
    WHERE ROWNUM = 1
)
ORDER BY mice_ration DESC;


-- TASK 18
-- Modification: not jacek 
-- to cat who has the lowest total mice ration
SELECT cats2.name, cats2.in_herd_since "Hunts since"
FROM cats cats1
JOIN cats cats2
ON cats1.name = (
    SELECT name
    FROM (
        SELECT name, NVL(mice_ration, 0) + NVL(mice_extra, 0) as total_ration
        FROM cats
        ORDER BY total_ration ASC
    )
    WHERE ROWNUM = 1
)
WHERE cats1.in_herd_since > cats2.in_herd_since
ORDER BY cats2.in_herd_since DESC;

-- TASK 19 A
SELECT cats.name, cats.function, cats1.name "Chief 1", cats2.name "Chief 2", cats3.name "Chief 3"
FROM cats
LEFT JOIN cats cats1 ON cats.chief = cats1.nickname
LEFT JOIN cats cats2 ON cats1.chief = cats2.nickname
LEFT JOIN cats cats3 ON cats2.chief = cats3.nickname
WHERE cats.function IN ('CAT', 'NICE');

-- TASK 19 B
-- CONNECT_BY_ROOT name "Name" selects the name of the current row and assigns it an alias "Name"
-- LEVEL selects the level of the current row in the hierarchy
SELECT *
FROM (SELECT CONNECT_BY_ROOT name "Name", name chief, CONNECT_BY_ROOT function "Function", LEVEL AS "LEV"
      FROM cats
      CONNECT BY PRIOR chief = nickname
      START WITH function IN ('CAT','NICE'))
PIVOT (
    MIN(chief)
    FOR lev
    IN (2 "Chief 1", 3 "Chief 2", 4 "Chief 3")
    );
    
-- TASK 19 C
SELECT CONNECT_BY_ROOT name "Name",
       CONNECT_BY_ROOT function "Function",
       LTRIM(SYS_CONNECT_BY_PATH(name, ' | '), ' |') AS "Names of subsequent chiefs"
FROM cats
WHERE chief IS NULL
CONNECT BY PRIOR chief = nickname
START WITH function IN ('CAT','NICE');

-- TASK 20
-- one more column calculate total mice ration 
SELECT 
    cats.name "Name of female cat", 
    bands.name "Band name", 
    enemies.enemy_name "Enemy name", 
    enemies.hostility_degree "Enemy rating", 
    incident_date "Incident date",
    NVL(mice_ration, 0) + NVL(mice_extra, 0) as "Total ration"
FROM cats
JOIN bands ON cats.band_no = bands.band_no
JOIN incidents ON cats.nickname = incidents.nickname
JOIN enemies ON incidents.enemy_name = enemies.enemy_name
WHERE incident_date > TO_DATE('2007-01-01')
AND gender = 'W'
ORDER BY cats.name;

-- TASK 21
-- band name cats with enemies, cat with the most enemies in each band
SELECT bands.name, count(DISTINCT cats.nickname), cats.nickname
FROM cats
JOIN bands ON cats.band_no = bands.band_no
JOIN incidents ON cats.nickname = incidents.nickname
GROUP BY bands.name;

-- TASK 22
SELECT MIN(function) "Function", cats.nickname "Nickname of cat",  count(incidents.nickname) "Number of enemies"
FROM cats
JOIN incidents ON cats.nickname = incidents.nickname
GROUP BY cats.nickname
HAVING count(incidents.nickname)  > 1;

-- Modification for combined 21-22
SELECT b.name as "Band Name", 
       cats_enemies_count.CatsWithEnemies as "Cats with Enemies",
       cat_with_most_enemies.Nickname as "Cat with Most Enemies", 
       cat_with_most_enemies.EnemyCount as "Number of Enemies"
FROM bands b
JOIN (
    SELECT c.band_no, COUNT(DISTINCT c.nickname) as CatsWithEnemies
    FROM cats c
    JOIN incidents i ON c.nickname = i.nickname
    GROUP BY c.band_no
) cats_enemies_count ON b.band_no = cats_enemies_count.band_no
JOIN (
    SELECT c.band_no, 
           c.nickname, 
           COUNT(i.nickname) as EnemyCount
    FROM cats c
    JOIN incidents i ON c.nickname = i.nickname
    GROUP BY c.band_no, c.nickname
    HAVING COUNT(i.nickname) = (
        SELECT MAX(EnemyCount)
        FROM (
            SELECT c2.nickname, COUNT(i.nickname) as EnemyCount
            FROM cats c2
            JOIN incidents i ON c2.nickname = i.nickname
            WHERE c2.band_no = c.band_no
            GROUP BY c2.nickname
        )
    )
) cat_with_most_enemies ON b.band_no = cat_with_most_enemies.band_no
ORDER BY b.name;


-- TASK 23
SELECT name, (mice_ration + mice_extra)*12 "Annual dose", 'above 864' "Dose"
FROM cats
WHERE (mice_ration + mice_extra)*12 > 864 AND mice_extra IS NOT NULL
UNION
SELECT name, (mice_ration + mice_extra)*12 "Annual dose", '864' "Dose"
FROM cats
WHERE (mice_ration + mice_extra)*12 = 864 AND mice_extra IS NOT NULL
UNION
SELECT name, (mice_ration + mice_extra)*12 "Annual dose", 'below 864' "Dose"
FROM cats
WHERE (mice_ration + mice_extra)*12 < 864 AND mice_extra IS NOT NULL
ORDER BY "Annual dose" DESC;

-- TASK 24 A
SELECT bands.band_no, bands.name, site
FROM bands
LEFT JOIN cats ON bands.band_no = cats.band_no
WHERE cats.name IS NULL;

-- TASK 24 B
SELECT bands.band_no, bands.name, site
FROM bands
MINUS 
SELECT bands.band_no, bands.name, site
FROM bands
JOIN cats ON bands.band_no = cats.band_no;

-- TASK 25
SELECT name, function, mice_ration "RATION OF MICE"
FROM cats
WHERE mice_ration >= ALL(
    SELECT 3*NVL(mice_ration, 0)
    FROM cats
    JOIN bands ON cats.band_no = bands.band_no    
    WHERE site in ('WHOLE AREA','ORCHARD')
    AND function = 'NICE'
    );

-- TASK 26
SELECT function, ROUND(AVG(NVL(mice_ration, 0) + NVL(mice_extra,0))) "Average min and max mice"
FROM cats
WHERE function != 'BOSS'
GROUP by function
HAVING
	ROUND(AVG(NVL(mice_ration, 0) + NVL(mice_extra,0)))
	IN(
    	(
    		SELECT MIN(ROUND(AVG(NVL(mice_ration, 0) + NVL(mice_extra,0))))
    		FROM cats
			WHERE function != 'BOSS'
			GROUP by function
    	),
    	(
    		SELECT MAX(ROUND(AVG(NVL(mice_ration, 0) + NVL(mice_extra,0))))
    		FROM cats
			WHERE function != 'BOSS'
			GROUP by function
        )
    );

-- modification for task 27: not mice consumption but number of enemies. N = 2
SELECT nickname, EnemyCount "Enemies Count"
FROM (
    SELECT C.nickname, EC.EnemyCount
    FROM cats C
    JOIN (
        SELECT I.nickname, COUNT(DISTINCT I.enemy_name) as EnemyCount
        FROM incidents I
        GROUP BY I.nickname
    ) EC ON C.nickname = EC.nickname
    ORDER BY EC.EnemyCount DESC
)
WHERE ROWNUM <= 2;


-- TASK 27 A
SELECT nickname, (NVL(mice_ration, 0) + NVL(mice_extra, 0)) "EATS"
FROM cats C
WHERE 2 > (
    SELECT COUNT(DISTINCT (NVL(mice_ration, 0) + NVL(mice_extra, 0)))
    FROM cats
    WHERE (NVL(C.mice_ration, 0) + NVL(C.mice_extra, 0)) < (NVL(mice_ration, 0) + NVL(mice_extra, 0))
)
ORDER BY "EATS" DESC;

SELECT cats.nickname "Nickname of cat",  count(incidents.nickname) "Number of enemies"
FROM cats
WHERE 2 >(
    SELECT count(incidents.nickname) "Number of enemies"
    FROM cats
    JOIN incidents ON cats.nickname = incidents.nickname
    GROUP BY cats.
    HAVING count(incidents.nickname)  > 1
);

-- TASK 27 B
SELECT nickname, (NVL(mice_ration, 0) + NVL(mice_extra, 0))  "EATS"
FROM cats
WHERE (NVL(mice_ration, 0) + NVL(mice_extra, 0)) IN (
    SELECT "EATS"
    FROM (
        SELECT DISTINCT (NVL(mice_ration, 0) + NVL(mice_extra, 0)) "EATS"
        FROM cats
        ORDER BY "EATS" DESC
    )
    WHERE ROWNUM <= 6 
);

-- TASK 27 C
SELECT cats1.nickname, MIN(NVL(cats1.mice_ration, 0) + NVL(cats1.mice_extra, 0)) "EATS"
FROM cats cats1
JOIN cats cats2 ON NVL(cats1.mice_ration,0) + NVL(cats1.mice_extra,0) <= NVL(cats2.mice_ration,0) + NVL(cats2.mice_extra,0) 
GROUP BY cats1.nickname
HAVING COUNT(DISTINCT NVL(cats2.mice_ration,0) +NVL(cats2.mice_extra,0)) <= 6
ORDER BY "EATS" DESC;

-- TASK 28
SELECT TO_CHAR(EXTRACT(YEAR FROM in_herd_since)) "YEAR", COUNT(*) "NUMBER OF ENTRIES"
FROM cats
GROUP BY EXTRACT(YEAR FROM in_herd_since)
HAVING COUNT(*)  IN (
    (SELECT MAX(less) 
    FROM 
    	(SELECT DISTINCT COUNT(*) less 
                    FROM cats
                    GROUP BY EXTRACT(YEAR FROM in_herd_since)
                    HAVING COUNT(*) <
                           (SELECT AVG(COUNT(EXTRACT(YEAR FROM in_herd_since)))
                            FROM cats
                            GROUP BY EXTRACT(YEAR FROM in_herd_since))
                    ORDER BY COUNT(*) DESC
    	)
    ),
    (SELECT MIN(more) 
    FROM 
    	(SELECT DISTINCT COUNT(*) more
                    FROM cats
                    GROUP BY EXTRACT(YEAR FROM in_herd_since)
                    HAVING COUNT(*) >
                           (SELECT AVG(COUNT(EXTRACT(YEAR FROM in_herd_since)))
                            FROM cats
                            GROUP BY EXTRACT(YEAR FROM in_herd_since))
                    ORDER BY COUNT(*))
    	) 
    )
UNION ALL
SELECT 'Average', ROUND(AVG(COUNT(nickname)),7)
FROM cats
GROUP BY TO_CHAR(EXTRACT(YEAR FROM in_herd_since))
ORDER BY 2;

-- TASK 29 A
SELECT cats1.name, NVL(cats1.mice_ration, 0) + NVL(cats1.mice_extra, 0) "EATS", cats1.band_no "BAND NO", AVG(NVL(cats2.mice_ration, 0) + NVL(cats2.mice_extra, 0)) "AVERAGE"
FROM cats cats1
JOIN cats cats2
ON cats1.band_no = cats2.band_no
WHERE cats1.gender = 'M'
GROUP BY cats1.name, cats1.band_no, NVL(cats1.mice_ration, 0), NVL(cats1.mice_extra, 0)
HAVING (NVL(cats1.mice_ration, 0) + NVL(cats1.mice_extra, 0)) < AVG(NVL(cats2.mice_ration, 0) + NVL(cats2.mice_extra, 0))
ORDER BY cats1.band_no DESC;

-- TASK 29 B
SELECT cats1.name, NVL(cats1.mice_ration, 0) + NVL(cats1.mice_extra, 0) "EATS", cats1.band_no "BAND NO", AVG "AVERAGE"
FROM (SELECT band_no bandNo, AVG(mice_ration + NVL(mice_extra,0)) "AVG" 
        FROM cats
        GROUP BY band_no)
JOIN cats cats1
ON cats1.band_no = bandNo
WHERE cats1.gender = 'M'
AND (NVL(mice_ration, 0) + NVL(mice_extra, 0)) < AVG
ORDER BY band_no DESC;

-- TASK 29 C
SELECT cats1.name, NVL(cats1.mice_ration, 0) + NVL(cats1.mice_extra, 0) "EATS", cats1.band_no "BAND NO", 
(
	SELECT AVG(NVL(cats2.mice_ration, 0) + NVL(cats2.mice_extra, 0))
	FROM cats cats2
	WHERE cats1.band_no = cats2.band_no
) "AVERAGE"
FROM cats cats1
WHERE cats1.gender = 'M'
AND (NVL(cats1.mice_ration, 0) + NVL(cats1.mice_extra, 0)) < (
    SELECT AVG(NVL(mice_ration, 0) + NVL(mice_extra, 0))
    FROM cats cats2
    WHERE cats1.band_no = cats2.band_no
)
ORDER BY band_no DESC;


-- TASK 30
SELECT c.name, in_herd_since "JOIN THE HERD", '<--- SHORTEST TIME IN THE BAND ' || bands.name " "
FROM cats c
JOIN bands 
ON c.band_no = bands.band_no
WHERE in_herd_since = (
    SELECT MAX(in_herd_since)
    FROM cats
    WHERE band_no = c.band_no
    )
    
UNION ALL
    
SELECT c.name, in_herd_since "JOIN THE HERD", '<--- LONGEST TIME IN THE BAND ' || bands.name " "
FROM cats c
JOIN bands 
ON c.band_no = bands.band_no
WHERE in_herd_since = (
    SELECT MIN(in_herd_since)
    FROM cats
    WHERE band_no = c.band_no
    )
    
UNION ALL
    
SELECT c.name, in_herd_since "JOIN THE HERD", ' '
FROM cats c
WHERE in_herd_since NOT IN (
    (
    	SELECT MIN(in_herd_since)
        FROM cats
        WHERE band_no = c.band_no
    ),
    (
        SELECT MAX(in_herd_since)
        FROM cats
        WHERE band_no = c.band_no)
    )
ORDER BY name;


-- TASK 31
DROP VIEW band_statistics;
CREATE VIEW band_statistics (BAND_NAME, AVG_CONS, MAX_CONS, MIN_CONS, CAT, CAT_WITH_EXTRA) AS
SELECT 
	b.name,
	AVG(c.mice_ration),
	MAX(c.mice_ration),
	MIN(c.mice_ration),
	COUNT(*),
	COUNT(c.mice_extra)
FROM bands b
JOIN cats c ON b.band_no = c.band_no
GROUP BY b.name;

SELECT * 
FROM band_statistics
ORDER BY 2 DESC;

SELECT 
    c.nickname, 
    c.name, 
    c.function, 
    c.mice_ration "EATS", 
    'FROM ' || bs.min_cons ||
    ' TO ' || bs.max_cons "CONSUMPTION LIMITS", 
    c.in_herd_since "HUNT FROM"
FROM 
    band_statistics bs
JOIN 
    bands b ON bs.band_name = b.name
JOIN 
    cats c ON b.band_no = c.band_no
WHERE 
    c.nickname = 'CAKE';


-- TASK 32
-- Selecting cat details before the pay increase
SELECT 
    Nickname AS "Nickname", 
    Gender AS "Gender", 
    Mice_Ration AS "Mice before pay increase", 
    NVL(Mice_Extra, 0) AS "Extra before pay increase"
FROM 
    Cats
LEFT JOIN 
    Bands ON Cats.Band_No = Bands.Band_No
WHERE 
    Nickname IN (
        SELECT Nickname FROM (
            SELECT Nickname
            FROM Cats
            LEFT JOIN Bands ON Cats.Band_No = Bands.Band_No
            WHERE Bands.Name = 'BLACK KNIGHTS'
            ORDER BY In_Herd_Since
        ) WHERE ROWNUM <= 3
        UNION ALL
        SELECT Nickname FROM (
            SELECT Nickname
            FROM Cats
            LEFT JOIN Bands ON Cats.Band_No = Bands.Band_No
            WHERE Bands.Name = 'PINTO HUNTERS'
            ORDER BY In_Herd_Since
        ) WHERE ROWNUM <= 3
    );

-- Updating pay based on gender and average band pay
UPDATE Cats
SET mice_ration = CASE gender
WHEN 'W' THEN mice_ration + (SELECT MIN(mice_ration)
								 FROM CATS) * 0.10
WHEN 'M' THEN mice_ration + 10
END,
    mice_extra = NVL(mice_extra,0) + (SELECT AVG(NVL(mice_extra, 0))
                                        FROM CATS c
                                        WHERE c.BAND_NO = Cats.band_no) * 0.15
WHERE nickname IN (SELECT nickname
                 FROM (SELECT nickname
                       FROM CATS
                       LEFT JOIN BANDS b USING (BAND_NO)
                       WHERE b.name = 'BLACK KNIGHTS'
                       ORDER BY IN_HERD_SINCE)
                WHERE ROWNUM <=3
                UNION ALL
                SELECT nickname
                 FROM (SELECT nickname
                       FROM CATS
                       LEFT JOIN BANDS b USING (BAND_NO)
                       WHERE b.name = 'PINTO HUNTERS'
                       ORDER BY IN_HERD_SINCE)
                WHERE ROWNUM <=3);

-- Selecting cat details after the pay increase
SELECT 
    Nickname AS "Nickname", 
    Gender AS "Gender", 
    Mice_Ration AS "Mice after pay increase", 
    NVL(Mice_Extra, 0) AS "Extra after pay increase"
FROM 
    Cats
LEFT JOIN 
    Bands ON Cats.Band_No = Bands.Band_No
WHERE 
    Nickname IN (
        SELECT Nickname FROM (
            SELECT Nickname
            FROM Cats
            LEFT JOIN Bands ON Cats.Band_No = Bands.Band_No
            WHERE Bands.Name = 'BLACK KNIGHTS'
            ORDER BY In_Herd_Since
        ) WHERE ROWNUM <= 3
        UNION ALL
        SELECT Nickname FROM (
            SELECT Nickname
            FROM Cats
            LEFT JOIN Bands ON Cats.Band_No = Bands.Band_No
            WHERE Bands.Name = 'PINTO HUNTERS'
            ORDER BY In_Herd_Since
        ) WHERE ROWNUM <= 3
    );
ROLLBACK;

-- TASK 33 A
SELECT * FROM (SELECT 
  TO_CHAR(Bands.name) "Bands name",
  TO_CHAR(DECODE(gender, 'M', 'MALE', 'FEMALE') || ' CAT') "Gender",
  TO_CHAR(COUNT(nickname)) "HOW MANY",
  TO_CHAR(NVL((SELECT SUM(NVL(mice_ration, 0) + NVL(mice_extra, 0)) FROM Cats C 
	WHERE function = 'BOSS' AND C.band_no = Cats.band_no AND C.gender = Cats.gender), 0)) "BOSS",
  TO_CHAR(NVL((SELECT SUM(NVL(mice_ration, 0) + NVL(mice_extra, 0)) FROM Cats C 
	WHERE function = 'THUG' AND C.band_no = Cats.band_no AND C.gender = Cats.gender), 0)) "THUG",
  TO_CHAR(NVL((SELECT SUM(NVL(mice_ration, 0) + NVL(mice_extra, 0)) FROM Cats C 
	WHERE function = 'CATCHING' AND C.band_no = Cats.band_no AND C.gender = Cats.gender), 0)) "CATCHING",
  TO_CHAR(NVL((SELECT SUM(NVL(mice_ration, 0) + NVL(mice_extra, 0)) FROM Cats C 
	WHERE function = 'CATCHER' AND C.band_no = Cats.band_no AND C.gender = Cats.gender), 0)) "CATCHER",
  TO_CHAR(NVL((SELECT SUM(NVL(mice_ration, 0) + NVL(mice_extra, 0)) FROM Cats C 
	WHERE function = 'CAT' AND C.band_no = Cats.band_no AND C.gender = Cats.gender), 0)) "CAT",
  TO_CHAR(NVL((SELECT SUM(NVL(mice_ration, 0) + NVL(mice_extra, 0)) FROM Cats C 
	WHERE function = 'NICE' AND C.band_no = Cats.band_no AND C.gender = Cats.gender), 0)) "NICE",
  TO_CHAR(NVL((SELECT SUM(NVL(mice_ration, 0) + NVL(mice_extra, 0)) FROM Cats C 
	WHERE function = 'DIVISIVE' AND C.band_no = Cats.band_no AND C.gender = Cats.gender), 0)) "DIVISIVE",
  TO_CHAR(NVL((SELECT SUM(NVL(mice_ration, 0) + NVL(mice_extra, 0)) FROM Cats C 
	WHERE C.band_no = Cats.band_no AND C.gender = Cats.gender), 0)) "SUM"
FROM (Cats JOIN Bands ON Cats.band_no = Bands.band_no)
	GROUP BY Bands.name, gender, Cats.band_no
	ORDER BY Bands.name)
UNION ALL
SELECT DISTINCT 
       'Eats in total',
       ' ',
       ' ',
       TO_CHAR(NVL((SELECT SUM(NVL(mice_ration, 0) + NVL(mice_extra, 0)) FROM Cats C 
		WHERE function = 'BOSS'), 0)) "BOSS",
       TO_CHAR(NVL((SELECT SUM(NVL(mice_ration, 0) + NVL(mice_extra, 0)) FROM Cats C 
		WHERE function = 'THUG'), 0)) "THUG",
       TO_CHAR(NVL((SELECT SUM(NVL(mice_ration, 0) + NVL(mice_extra, 0)) FROM Cats C 
		WHERE function = 'CATCHING'), 0)) "CATCHING",
       TO_CHAR(NVL((SELECT SUM(NVL(mice_ration, 0) + NVL(mice_extra, 0)) FROM Cats C 
		WHERE function = 'CATCHER'), 0)) "CATCHER",
       TO_CHAR(NVL((SELECT SUM(NVL(mice_ration, 0) + NVL(mice_extra, 0)) FROM Cats C 
		WHERE function = 'CAT'), 0)) "CAT",
       TO_CHAR(NVL((SELECT SUM(NVL(mice_ration, 0) + NVL(mice_extra, 0)) FROM Cats C 
		WHERE function = 'NICE'), 0)) "NICE",
       TO_CHAR(NVL((SELECT SUM(NVL(mice_ration, 0) + NVL(mice_extra, 0)) FROM Cats C 
		WHERE function = 'DIVISIVE'), 0)) "DIVISIVE",
       TO_CHAR(NVL((SELECT SUM(NVL(mice_ration, 0) + NVL(mice_extra, 0)) FROM Cats C), 0)) "SUM"
FROM (Cats JOIN Bands ON Cats.band_no = Bands.band_no);

-- TASK 33 B

SELECT * FROM (
  SELECT 
    TO_CHAR(BBN) "BANDS NAME",
    TO_CHAR(DECODE(gender, 'M', 'MALE', 'FEMALE') || ' CAT') "GENDER",
    TO_CHAR(HOW_MUCH) "HOW MUCH",
    TO_CHAR(NVL(BOSS, 0)) "BOSS",
    TO_CHAR(NVL(THUG, 0)) "THUG",
    TO_CHAR(NVL(CATCHING, 0)) "CATCHING",
    TO_CHAR(NVL(CATCHER, 0)) "CATCHER",
    TO_CHAR(NVL(CAT, 0)) "CAT",
    TO_CHAR(NVL(NICE, 0)) "NICE",
    TO_CHAR(NVL(DIVISIVE, 0)) "DIVISIVE",
    TO_CHAR(NVL(THIER_SUM, 0)) "SUM"
  FROM
  (
    SELECT Bands.name "BBN", gender, function, NVL(mice_ration, 0) + NVL(mice_extra, 0) ct
    FROM Cats JOIN Bands ON Cats.band_no = Bands.band_no
  ) PIVOT (
      SUM(ct) FOR function IN (
      'BOSS' BOSS, 'THUG' THUG, 'CATCHING' CATCHING, 'CATCHER' CATCHER,
      'CAT' CAT, 'NICE' NICE, 'DIVISIVE' DIVISIVE
    )
  ) JOIN (
    SELECT B.name "BN", gender "G", COUNT(nickname) "HOW_MUCH", SUM(NVL(mice_ration, 0) + NVL(mice_extra, 0)) THIER_SUM
    FROM Cats C JOIN Bands B ON C.band_no = B.band_no
    GROUP BY B.name, gender
    ORDER BY B.name
  ) ON BN = BBN AND G = gender
)
UNION ALL
SELECT  'Eats in total',
        ' ',
        ' ',
        TO_CHAR(NVL(BOSS, 0)) BOSS,
        TO_CHAR(NVL(THUG, 0)) THUG,
        TO_CHAR(NVL(CATCHING, 0)) CATCHING,
        TO_CHAR(NVL(CATCHER, 0)) CATCHER,
        TO_CHAR(NVL(CAT, 0)) CAT,
        TO_CHAR(NVL(NICE, 0)) NICE,
        TO_CHAR(NVL(DIVISIVE, 0)) DIVISIVE,
        TO_CHAR(NVL(THIER_SUM, 0)) "SUM"
FROM
(
  SELECT function, NVL(mice_ration, 0) + NVL(mice_extra, 0) ct, (SELECT SUM(NVL(mice_ration, 0) + NVL(mice_extra, 0)) FROM Cats) THIER_SUM
  FROM Cats JOIN Bands ON Cats.band_no = Bands.band_no
) PIVOT (
    SUM(ct) FOR function IN (
    'BOSS' BOSS, 'THUG' THUG, 'CATCHING' CATCHING, 'CATCHER' CATCHER,
    'CAT' CAT, 'NICE' NICE, 'DIVISIVE' DIVISIVE
  )
);











