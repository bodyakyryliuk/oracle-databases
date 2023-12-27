ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';

CREATE TABLE Enemies (  
    enemy_name VARCHAR2(15) PRIMARY KEY,  
    hostility_degree NUMBER(3, 0) CHECK (hostility_degree >= 1 AND hostility_degree <= 100),  
    species VARCHAR2(15),  
    bride VARCHAR2(20)  
);

CREATE TABLE Functions (  
    function VARCHAR2(10) PRIMARY KEY,  
    min_mice NUMBER(3) CHECK (min_mice >= 5),  
    max_mice NUMBER(3),  
    CONSTRAINT check_min_max_mice CHECK (max_mice <= 200 AND max_mice >= min_mice)  
);

CREATE TABLE Bands (  
    Band_no NUMBER(2) PRIMARY KEY,  
    name VARCHAR2(20) NOT NULL,  
    site VARCHAR2(15) UNIQUE,  
    band_chief VARCHAR2(15) UNIQUE  
  
);

CREATE TABLE Cats (  
    name VARCHAR2(15) NOT NULL,  
    gender VARCHAR2(1) CHECK (gender IN ('M', 'W')),  
    nickname VARCHAR2(15) PRIMARY KEY,  
    function VARCHAR2(10),  
    chief VARCHAR2(15),  
    in_herd_since DATE DEFAULT SYSDATE,  
    mice_ration NUMBER(3) CHECK (mice_ration >= 0),  
    mice_extra NUMBER(2),  
    band_no NUMBER(3),  
    FOREIGN KEY (function) REFERENCES Functions(function),  
    FOREIGN KEY (chief) REFERENCES Cats(nickname) DEFERRABLE INITIALLY DEFERRED,  
    FOREIGN KEY (band_no) REFERENCES Bands(Band_no) DEFERRABLE INITIALLY DEFERRED  
);
-- DEFERRABLE INITIALLY DEFERRED - enforcement of the foreign key constraint is delayed until the transaction is committed, rather than being checked immediately after each operation.
ALTER TABLE Bands  
ADD CONSTRAINT fk_band_chief  
FOREIGN KEY (band_chief) REFERENCES Cats(nickname) DEFERRABLE INITIALLY DEFERRED;

CREATE TABLE Incidents (  
    nickname VARCHAR2(15),  
    enemy_name VARCHAR2(15),  
    incident_date DATE,  
    incident_desc VARCHAR2(50) NOT NULL,  
    PRIMARY KEY (nickname, enemy_name),  
    FOREIGN KEY (nickname) REFERENCES Cats(nickname),  
    FOREIGN KEY (enemy_name) REFERENCES Enemies(enemy_name)  
);

INSERT ALL  
    INTO Enemies (enemy_name, hostility_degree, species, bride) VALUES ('KAZIO', 10, 'MAN', 'BOTTLE')  
    INTO Enemies (enemy_name, hostility_degree, species, bride) VALUES ('STUPID SOPHIA', 1, 'MAN', 'BEAD')  
    INTO Enemies (enemy_name, hostility_degree, species, bride) VALUES ('UNRULY DYZIO', 7, 'MAN', 'CHEWING GUM')  
    INTO Enemies (enemy_name, hostility_degree, species, bride) VALUES ('DUN', 4, 'DOG', 'BONE')  
    INTO Enemies (enemy_name, hostility_degree, species, bride) VALUES ('WILD BILL', 10, 'DOG', NULL)  
    INTO Enemies (enemy_name, hostility_degree, species, bride) VALUES ('REKS', 2, 'DOG', 'BONE')  
    INTO Enemies (enemy_name, hostility_degree, species, bride) VALUES ('BETHOVEN', 1, 'DOG', 'PEDIGRIPALL')  
    INTO Enemies (enemy_name, hostility_degree, species, bride) VALUES ('SLYBOOTS', 5, 'FOX', 'CHICKEN')  
    INTO Enemies (enemy_name, hostility_degree, species, bride) VALUES ('SLIM', 1, 'PINE', NULL)  
    INTO Enemies (enemy_name, hostility_degree, species, bride) VALUES ('BASIL', 3, 'ROOSTER', 'HEN TO THE HERD')  
SELECT * FROM DUAL;

INSERT ALL  
    INTO Functions (function, min_mice, max_mice) VALUES ('BOSS', 90, 110)  
    INTO Functions (function, min_mice, max_mice) VALUES ('THUG', 70, 90)  
    INTO Functions (function, min_mice, max_mice) VALUES ('CATCHING', 60, 70)  
    INTO Functions (function, min_mice, max_mice) VALUES ('CATCHER', 50, 60)  
    INTO Functions (function, min_mice, max_mice) VALUES ('CAT', 40, 50)  
    INTO Functions (function, min_mice, max_mice) VALUES ('NICE', 20, 30)  
    INTO Functions (function, min_mice, max_mice) VALUES ('DIVISIVE', 45, 55)  
    INTO Functions (function, min_mice, max_mice) VALUES ('HONORARY', 6, 25)  
SELECT * FROM DUAL;

INSERT ALL  
    INTO Cats (name, gender, nickname, function, chief, in_herd_since, mice_ration, mice_extra, band_no)   
    VALUES ('JACEK', 'M', 'CAKE', 'CATCHING', 'BALD', '2008-12-01', 67, NULL, 2)  
    INTO Cats (name, gender, nickname, function, chief, in_herd_since, mice_ration, mice_extra, band_no)   
    VALUES ('BARI', 'M', 'TUBE', 'CATCHER', 'BALD', '2009-09-01', 56, NULL, 2)  
    INTO Cats (name, gender, nickname, function, chief, in_herd_since, mice_ration, mice_extra, band_no)   
    VALUES ('MICKA', 'W', 'LOLA', 'NICE', 'TIGER', '2009-10-14', 25, 47, 1)  
    INTO Cats (name, gender, nickname, function, chief, in_herd_since, mice_ration, mice_extra, band_no)   
    VALUES ('LUCEK', 'M', 'ZERO', 'CAT', 'HEN', '2010-03-01', 43, NULL, 3)  
    INTO Cats (name, gender, nickname, function, chief, in_herd_since, mice_ration, mice_extra, band_no)   
    VALUES ('SONIA', 'W', 'FLUFFY', 'NICE', 'ZOMBIES', '2010-11-18', 20, 35, 3)  
    INTO Cats (name, gender, nickname, function, chief, in_herd_since, mice_ration, mice_extra, band_no)   
    VALUES ('LATKA', 'W', 'EAR', 'CAT', 'REEF', '2011-01-01', 40, NULL, 4)  
    INTO Cats (name, gender, nickname, function, chief, in_herd_since, mice_ration, mice_extra, band_no)   
    VALUES ('DUDEK', 'M', 'SMALL', 'CAT', 'REEF', '2011-05-15', 40, NULL, 4)  
    INTO Cats (name, gender, nickname, function, chief, in_herd_since, mice_ration, mice_extra, band_no)   
    VALUES ('MRUCZEK', 'M', 'TIGER', 'BOSS', NULL, '2002-01-01', 103, 33, 1)  
    INTO Cats (name, gender, nickname, function, chief, in_herd_since, mice_ration, mice_extra, band_no)   
    VALUES ('CHYTRY', 'M', 'BOLEK', 'DIVISIVE', 'TIGER', '2002-05-05', 50, NULL, 1)  
    INTO Cats (name, gender, nickname, function, chief, in_herd_since, mice_ration, mice_extra, band_no)   
    VALUES ('KOREK', 'M', 'ZOMBIES', 'THUG', 'TIGER', '2004-03-16', 75, 13, 3)  
    INTO Cats (name, gender, nickname, function, chief, in_herd_since, mice_ration, mice_extra, band_no)   
    VALUES ('BOLEK', 'M', 'BALD', 'THUG', 'TIGER', '2006-08-15', 72, 21, 2)  
    INTO Cats (name, gender, nickname, function, chief, in_herd_since, mice_ration, mice_extra, band_no)   
    VALUES ('ZUZIA', 'W', 'FAST', 'CATCHING', 'BALD', '2006-07-21', 65, NULL, 2)  
    INTO Cats (name, gender, nickname, function, chief, in_herd_since, mice_ration, mice_extra, band_no)   
    VALUES ('RUDA', 'W', 'LITTLE', 'NICE', 'TIGER', '2006-09-17', 22, 42, 1)  
    INTO Cats (name, gender, nickname, function, chief, in_herd_since, mice_ration, mice_extra, band_no)   
    VALUES ('PUCEK', 'M', 'REEF', 'CATCHING', 'TIGER', '2006-10-15', 65, NULL, 4)  
    INTO Cats (name, gender, nickname, function, chief, in_herd_since, mice_ration, mice_extra, band_no)   
    VALUES ('PUNIA', 'W', 'HEN', 'CATCHING', 'ZOMBIES', '2008-01-01', 61, NULL, 3)  
    INTO Cats (name, gender, nickname, function, chief, in_herd_since, mice_ration, mice_extra, band_no)   
    VALUES ('BELA', 'W', 'MISS', 'NICE', 'BALD', '2008-02-01', 24, 28, 2)  
    INTO Cats (name, gender, nickname, function, chief, in_herd_since, mice_ration, mice_extra, band_no)   
    VALUES ('KSAWERY', 'M', 'MAN', 'CATCHER', 'REEF', '2008-07-12', 51, NULL, 4)  
    INTO Cats (name, gender, nickname, function, chief, in_herd_since, mice_ration, mice_extra, band_no)   
    VALUES ('MELA', 'W', 'LADY', 'CATCHER', 'REEF', '2008-11-01', 51, NULL, 4) 
SELECT * FROM DUAL;

INSERT ALL
    INTO Bands (band_no, name, site, band_chief) VALUES (1, 'SUPERIORS', 'WHOLE AREA', 'TIGER')  
    INTO Bands (band_no, name, site, band_chief) VALUES (2, 'BLACK KNIGHTS', 'FIELD', 'BALD')  
    INTO Bands (band_no, name, site, band_chief) VALUES (3, 'WHITE HUNTERS', 'ORCHARD', 'ZOMBIES')  
    INTO Bands (band_no, name, site, band_chief) VALUES (4, 'PINTO HUNTERS', 'HILLOCK', 'REEF')  
    INTO Bands (band_no, name, site, band_chief) VALUES (5, 'ROCKERS', 'FARM', NULL)  
SELECT * FROM DUAL;

INSERT ALL  
    INTO Incidents (nickname, enemy_name, incident_date, incident_desc) VALUES ('TIGER', 'KAZIO', '2004-10-13', 'HE WAS TRYING TO STICK ON THE FORK')  
    INTO Incidents (nickname, enemy_name, incident_date, incident_desc) VALUES ('ZOMBIES', 'UNRULY DYZIO', '2005-03-07', 'HE TOOK AN EYE FROM PROCAST')  
    INTO Incidents (nickname, enemy_name, incident_date, incident_desc) VALUES ('BOLEK', 'KAZIO', '2005-03-29', 'HE FOUGHT WITH A DOG')  
    INTO Incidents (nickname, enemy_name, incident_date, incident_desc) VALUES ('FAST', 'STUPID SOPHIA', '2006-09-12', 'SHE USED THE CAT AS A CLOTH')  
    INTO Incidents (nickname, enemy_name, incident_date, incident_desc) VALUES ('LITTLE', 'SLYBOOTS', '2007-03-07', 'HE PROPOSED HIMSELF AS A HUSBAND')  
    INTO Incidents (nickname, enemy_name, incident_date, incident_desc) VALUES ('TIGER', 'WILD BILL', '2007-06-12', 'HE TRIED TO ATTACK')  
    INTO Incidents (nickname, enemy_name, incident_date, incident_desc) VALUES ('BOLEK', 'WILD BILL', '2007-11-10', 'HE BIT AN EAR')  
    INTO Incidents (nickname, enemy_name, incident_date, incident_desc) VALUES ('MISS', 'WILD BILL', '2008-12-12', 'HE SCRATCHED')  
    INTO Incidents (nickname, enemy_name, incident_date, incident_desc) VALUES ('MISS', 'KAZIO', '2009-01-07', 'HE CAUGHT THE TAIL AND CREATED A STORM')  
    INTO Incidents (nickname, enemy_name, incident_date, incident_desc) VALUES ('LADY', 'KAZIO', '2009-02-07', 'HE TRIED TO SKIN OFF')  
    INTO Incidents (nickname, enemy_name, incident_date, incident_desc) VALUES ('MAN', 'REKS', '2009-04-14', 'HE BARKED EXTREMELY RUDELY')  
    INTO Incidents (nickname, enemy_name, incident_date, incident_desc) VALUES ('BALD', 'BETHOVEN', '2009-05-11', 'HE DID NOT SHARE THE PORRIDGE')  
    INTO Incidents (nickname, enemy_name, incident_date, incident_desc) VALUES ('TUBE', 'WILD BILL', '2009-09-03', 'HE TOOK THE TAIL')  
    INTO Incidents (nickname, enemy_name, incident_date, incident_desc) VALUES ('CAKE', 'BASIL', '2010-07-12', 'HE PREVENTED THE CHICKEN FROM BEING HUNTED')  
    INTO Incidents (nickname, enemy_name, incident_date, incident_desc) VALUES ('FLUFFY', 'SLIM', '2010-11-19', 'SHE THREW CONES')  
    INTO Incidents (nickname, enemy_name, incident_date, incident_desc) VALUES ('HEN', 'DUN', '2010-12-14', 'HE CHASED')  
    INTO Incidents (nickname, enemy_name, incident_date, incident_desc) VALUES ('SMALL', 'SLYBOOTS', '2011-07-13', 'HE TOOK THE STOLEN EGGS')  
    INTO Incidents (nickname, enemy_name, incident_date, incident_desc) VALUES ('EAR', 'UNRULY DYZIO', '2011-07-14', 'HE THREW STONES') 
SELECT * FROM DUAL;


