-- TASK 17
SELECT nickname "Hunts in the field", mice_ration, bands.name
FROM cats
JOIN bands
ON cats.band_no = bands.band_no
WHERE mice_ration > 50
AND site in ('FIELD', 'WHOLE AREA')
ORDER BY mice_ration DESC;

-- TASK 18
SELECT cats2.name, cats2.in_herd_since "Hunts since" 
FROM cats cats1
JOIN cats cats2
ON cats1.name = 'JACEK'
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
SELECT 
    cats.name "Name of female cat", 
    bands.name "Band name", 
    enemies.enemy_name "Enemy name", 
    enemies.hostility_degree "Enemy rating", 
    incident_date "Incident date"
FROM cats
JOIN bands ON cats.band_no = bands.band_no
JOIN incidents ON cats.nickname = incidents.nickname
JOIN enemies ON incidents.enemy_name = enemies.enemy_name
WHERE incident_date > TO_DATE('2007-01-01')
AND gender = 'W'
ORDER BY cats.name

-- TASK 21
SELECT bands.name, count(DISTINCT cats.nickname)
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
ORDER BY "Annual dose" DESC

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
    )

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
    
-- TASK 27 A
SELECT nickname, (NVL(mice_ration, 0) + NVL(mice_extra, 0)) "EATS"
FROM cats C
WHERE 6 > (
    SELECT COUNT(DISTINCT (NVL(mice_ration, 0) + NVL(mice_extra, 0)))
    FROM cats
    WHERE (NVL(C.mice_ration, 0) + NVL(C.mice_extra, 0)) < (NVL(mice_ration, 0) + NVL(mice_extra, 0))
)
ORDER BY "EATS" DESC;

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
ORDER BY "EATS" DESC

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
SELECT nickname "Nickname", gender "Gender", mice_ration "Mice before pay increase", NVL(mice_extra,0) "Extra before pay increase"
FROM Cats
LEFT JOIN bands b on CATS.BAND_NO = b.BAND_NO
WHERE nickname IN (SELECT nickname --po nickname?
                 FROM (SELECT nickname
                       FROM CATS
                       LEFT JOIN BANDS b USING (BAND_NO)
                       WHERE b.name = 'BLACK KNIGHTS'
                       ORDER BY IN_HERD_SINCE)
                WHERE ROWNUM <=3
                UNION ALL
                SELECT nickname --po nickname?
                 FROM (SELECT nickname
                       FROM CATS
                       LEFT JOIN BANDS b USING (BAND_NO)
                       WHERE b.name = 'PINTO HUNTERS'
                       ORDER BY IN_HERD_SINCE)
                WHERE ROWNUM <=3);
--update
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

SELECT nickname "Nickname", gender "Gender", mice_ration "Mice after pay increase", NVL(mice_extra,0) "Extra after pay increase"
FROM Cats
LEFT JOIN bands b on CATS.BAND_NO = b.BAND_NO
WHERE nickname IN (SELECT nickname --po nickname?
                 FROM (SELECT nickname
                       FROM CATS
                       LEFT JOIN BANDS b USING (BAND_NO)
                       WHERE b.name = 'BLACK KNIGHTS'
                       ORDER BY IN_HERD_SINCE)
                WHERE ROWNUM <=3
                UNION ALL
                SELECT nickname --po nickname?
                 FROM (SELECT nickname
                       FROM CATS
                       LEFT JOIN BANDS b USING (BAND_NO)
                       WHERE b.name = 'PINTO HUNTERS'
                       ORDER BY IN_HERD_SINCE)
                WHERE ROWNUM <=3);
ROLLBACK;














