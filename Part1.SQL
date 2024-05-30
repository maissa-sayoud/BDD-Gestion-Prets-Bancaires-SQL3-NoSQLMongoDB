/* ---------------------------------------------*/
/*                  Bismi Allah                 */
/* ---------------------------------------------*/

/*      Projet de Base de Données Avancées      */

/* Gestion des opérations & des prêts bancaires */

/* ---------------------------------------------*/
/*    BOULKABOUL Amira   &   SAYOUD Maissa      */
/* ---------------------------------------------*/




/*          Partie I        */


/*   B- Création des TableSpaces et utilisateur */
/*2. Créer deux TableSpaces SQL3_TBS ... */
DROP TABLESPACE SQL3_TBS INCLUDING CONTENTS AND DATAFILES;

CREATE TABLESPACE SQL3_TBS 
DATAFILE 'C:\Oracle19c\tablespaces\SQL3_TBS.dat' 
SIZE 100M AUTOEXTEND 
ON;




/* ... et SQL3_TempTBS */
DROP TABLESPACE SQL3_TempTBS INCLUDING CONTENTS AND DATAFILES;

CREATE TEMPORARY TABLESPACE SQL3_TempTBS 
TEMPFILE 'C:\Oracle19c\tablespaces\sql3_temptbs.dat' 
SIZE 100M AUTOEXTEND
ON;



/*3. Créer un utilisateur SQL3 en lui attribuant les deux tableSpaces créés précédemment*/
CREATE USER SQL333
IDENTIFIED BY 0000 
DEFAULT TABLESPACE SQL3_TBS 
TEMPORARY TABLESPACE SQL3_TempTBS;



/*4. Donner tous les privilèges à cet utilisateur.*/
GRANT ALL PRIVILEGES TO SQL3;




-- Se connecter !
CONNECT SQL3/0000




/*  C- Langage de définition de données */
/*5. En se basant sur le diagramme de classes établi, 
définir tous les types abstraits nécessaires.*/
/*drop type Type_Succ force;
drop type Type_Agence force;
drop type Type_Client force;
drop type Type_Operation force;
drop type Type_Pret force;
drop type Type_Compte force;

drop type t_set_ref_Succ force;
drop type t_set_ref_Client force;
drop type T_SET_REF_Compte force;
drop type t_set_ref_Operation force;
drop type t_set_ref_Pret force;
drop type t_set_ref_Agence force;*/


-- Creation des types incomplets !

CREATE OR REPLACE TYPE Type_Client;
/

CREATE OR REPLACE TYPE Type_Succ;
/

CREATE OR REPLACE TYPE Type_Agence;
/

CREATE OR REPLACE TYPE Type_Compte;
/

CREATE OR REPLACE TYPE Type_Operation; 
/

CREATE OR REPLACE TYPE Type_Pret;
/


-- Création des types nécessaires aux associations "les tables imbriquées des références" !

CREATE TYPE t_set_ref_Agence AS TABLE OF REF Type_Agence;
/

CREATE TYPE t_set_ref_Succ AS TABLE OF REF Type_Succ;
/

CREATE TYPE t_set_ref_Client AS TABLE OF REF Type_Client;
/

CREATE TYPE t_set_ref_Compte AS TABLE OF REF Type_Compte;
/

CREATE TYPE t_set_ref_Operation AS TABLE OF REF Type_Operation;
/

CREATE TYPE t_set_ref_Pret AS TABLE OF REF Type_Pret;
/



-- Verification !

SELECT type_name FROM user_types; 




-- Mise à jour des types !

CREATE OR REPLACE TYPE Type_Succ AS OBJECT 
(
    NumSucc     INT            ,
    NomSucc     VARCHAR(50)    ,
    AdresseSucc VARCHAR(100)   ,
    Region      VARCHAR(10)    ,
    Succursale_Agence t_set_ref_Agence
);
/

CREATE OR REPLACE TYPE Type_Agence AS OBJECT 
(
    NumAgence       INT         ,
    NomAgence       VARCHAR(50) ,
    AdresseAgence   VARCHAR(100),
    Categorie       VARCHAR(10) ,
    Agence_Succursale REF Type_Succ,
    Agence_Compte t_set_ref_Compte
);
/

CREATE OR REPLACE TYPE Type_Compte AS OBJECT 
(
    NumCompte       INT           ,
    DateOuverture   DATE          ,
    EtatCompte      VARCHAR(10)   ,
    Solde           FLOAT         ,
    Compte_Agence REF Type_Agence,
    Compte_Client REF Type_Client,
    Compte_Operation t_set_ref_Operation,
    Compte_Pret t_set_ref_Pret 
);
/

CREATE OR REPLACE TYPE Type_Client AS OBJECT 
(
    NumClient       INT         ,
    NomClient       VARCHAR(50) ,
    TypeClient      VARCHAR(15) ,
    AdresseClient   VARCHAR(100),
    NumTel          VARCHAR(12) ,
    Email           VARCHAR(100),
    Client_Compte t_set_ref_Compte
);
/

CREATE OR REPLACE TYPE Type_Operation AS OBJECT 
(
    NumOperation    INT             ,
    NatureOp        VARCHAR(10)     ,
    MontantOp       FLOAT           ,
    DateOp          DATE            ,
    Observation     VARCHAR(100)    ,
    Operation_Compte REF Type_Compte
);
/

CREATE OR REPLACE TYPE Type_Pret AS OBJECT 
(
    NumPret         INT             ,
    MontantPret     FLOAT           ,
    DateEffet       DATE            ,
    Duree           VARCHAR(10)     , -- tout le reste est un VARCHAR selon l'ennoncé
    TypePret        VARCHAR(15)     ,
    TauxInteret     FLOAT           ,
    MontantEcheance FLOAT           ,
    Pret_Compte     REF Type_Compte
);
/



/*6. Définir les méthodes permettant de :
- Calculer pour chaque agence, le nombre de prêts effectuées.*/

/*alter type Type_Agence DROP MEMBER function Nombre_Prets_Eff RETURN NUMBER CASCADE;*/


-- signature de la methode !
ALTER TYPE Type_Agence ADD MEMBER FUNCTION test RETURN NUMBER CASCADE;

-- le corps/body de la methode !
CREATE OR REPLACE TYPE BODY Type_Agence 
AS 
MEMBER FUNCTION Nombre_Prets_Eff 
    RETURN NUMBER 
    IS
        n NUMBER;
    BEGIN

        SELECT COUNT(deref(value (p)).NumPret) 
        INTO n
        FROM TABLE(self.Agence_Compte) c , Table(deref(value(c)).Compte_Pret) p;
        RETURN n;
    END;
END;
/


desc Type_Agence



/*Calculer pour chaque succursale, le nombre d’agences principales qui lui sont rattachées.*/
/*alter type Type_Succ DROP MEMBER function NOMBRE_AGENCES_PRINCIPALES RETURN NUMBER CASCADE;*/

-- signature de la methode !
ALTER TYPE Type_Succ ADD MEMBER FUNCTION Nombre_Agences_Principales RETURN NUMBER CASCADE;

-- le corps/body de la methode !
CREATE OR REPLACE TYPE BODY Type_Succ 
AS 
MEMBER FUNCTION Nombre_Agences_Principales 
    RETURN NUMBER 
    IS
        n NUMBER;
    BEGIN
        SELECT concat(self.NumSucc, 
            (SELECT COUNT(*) 
             FROM TABLE(self.Succursale_Agence) a
             WHERE deref(value(a)).Categorie = 'principale' 
            )) into n
        FROM Succursale s;
        RETURN n;
    END;
END;
/

desc Type_Succ




/*- Calculer pour une agence (de numéro donné), le montant global des prêts effectués durant la période du 01-01-2020 au 01-01-2024.*/

-- signature de la methode !
ALTER TYPE Type_Agence ADD MEMBER FUNCTION Montant_Global_Prets_Periode RETURN NUMBER CASCADE;

-- le corps/body de la methode !
CREATE OR REPLACE TYPE BODY Type_Agence 
AS 
MEMBER FUNCTION Nombre_Prets_Eff 
    RETURN NUMBER 
    IS
        n NUMBER;
    BEGIN

        SELECT COUNT(deref(value (p)).NumPret) 
        INTO n
        FROM TABLE(self.Agence_Compte) c , Table(deref(value(c)).Compte_Pret) p;
        RETURN n;
    END Nombre_Prets_Eff;

    MEMBER FUNCTION Montant_Global_Prets_Periode 
    RETURN NUMBER 
    IS
        nb NUMBER;
    BEGIN
        SELECT SUM(deref(value(p)).MontantPret) 
        INTO nb
        FROM table (self.Agence_Compte) a , table (deref(value(a)).Compte_Pret) p
        WHERE self.NumAgence = 101
        AND value(p).DateEffet BETWEEN '01/01/2020' AND '01/01/2024';

        RETURN nb;
    END Montant_Global_Prets_Periode;


END;
/


desc Type_Agence



/*- Lister toutes agences secondaires (avec la succursale rattachée) ayant au moins un prêt « ANSEJ »*/

-- signature de la methode !
ALTER TYPE Type_Agence ADD MEMBER FUNCTION Agences_Ayant_Pret RETURN NUMBER CASCADE;

-- le corps/body de la methode !
CREATE OR REPLACE TYPE BODY Type_Succ 
AS 

    MEMBER FUNCTION Nombre_Agences_Principales 
    RETURN NUMBER 
    IS
        n NUMBER;
    BEGIN
        SELECT concat(self.NumSucc, 
            (SELECT COUNT(*) 
             FROM TABLE(self.Succursale_Agence) a
             WHERE deref(value(a)).Categorie = 'principale' 
            )) into n
        FROM Succursale s;
        RETURN n;
    END Nombre_Agences_Principales;

    MEMBER FUNCTION Agences_Ayant_Pret 
    RETURN NUMBER 
    IS
        nbr NUMBER;
    BEGIN
        SELECT CONCAT(deref(value(a)).NumAgence, self.NumSucc) 
        INTO nbr
        FROM TABLE (self.Succursale_Agence) a, TABLE (deref(VALUE(a)).Agence_Compte) c, TABLE (deref(VALUE(c)).Compte_Pret) p 
        WHERE VALUE(p).TypePret = 'ANSEJ'
        AND VALUE(a).Categorie = 'Secondaire';
        RETURN nbr;
    END Agences_Ayant_Pret;


END;
/





/*7. Définir les tables nécessaires à la base de données.*/
CREATE TABLE Succursale OF Type_Succ
(
    PRIMARY KEY (NumSucc),
    CONSTRAINT ck_region_succursale CHECK (Region IN ('Nord', 'Sud', 'Est', 'Ouest'))
)
    NESTED TABLE Succursale_Agence STORE AS table_Succursale_Agence;



CREATE TABLE Agence OF Type_Agence
(
    PRIMARY KEY (NumAgence),
    FOREIGN KEY (Agence_Succursale) REFERENCES Succursale,
    CONSTRAINT ck_categorie_agence CHECK (Categorie IN ('Principale', 'Secondaire'))
)
    NESTED TABLE Agence_Compte STORE AS table_Agence_Compte
;



CREATE TABLE Client OF Type_Client
(
    PRIMARY KEY (NumClient),
    CONSTRAINT ck_type_client CHECK (TypeClient IN ('Particulier', 'Entreprise'))
)
    NESTED TABLE Client_Compte STORE AS table_Client_Compte
;



CREATE TABLE Compte OF Type_Compte
(
    PRIMARY KEY (NumCompte),
    FOREIGN KEY (Compte_Client) REFERENCES Client,
    FOREIGN KEY (Compte_Agence) REFERENCES Agence,
    CONSTRAINT ck_etat_compte CHECK (EtatCompte IN ('Actif', 'Bloque'))
)
    NESTED TABLE Compte_Operation STORE AS table_Compte_Operation,
    NESTED TABLE Compte_Pret STORE AS table_Compte_Pret
;



CREATE TABLE Operation OF Type_Operation
(
    PRIMARY KEY (NumOperation),
    FOREIGN KEY (Operation_Compte) REFERENCES Compte,
    CONSTRAINT ck_nature_operation CHECK (NatureOp IN ('Credit', 'Debit'))
);



CREATE TABLE Pret OF Type_Pret
(
    PRIMARY KEY (NumPret),
    FOREIGN KEY (Pret_Compte) REFERENCES Compte,
    CONSTRAINT ck_type_pret CHECK (TypePret IN ('Vehicule', 'Immobilier', 'ANSEJ', 'ANJEM'))
);





/*D- Création des instances dans les tables
8. Remplir toutes les tables par des instances */

/* Insertion de 6 succursales*/

INSERT INTO Succursale VALUES (Type_Succ(001, 'Succursale1', 'Adresse 1 Nord', 'Nord', t_set_ref_Agence()));

INSERT INTO Succursale VALUES (Type_Succ(002, 'Succursale2', 'Adresse 1 Sud', 'Sud', t_set_ref_Agence()));

INSERT INTO Succursale VALUES (Type_Succ(003, 'Succursale3', 'Adresse 1 Est', 'Est', t_set_ref_Agence()));

INSERT INTO Succursale VALUES (Type_Succ(004, 'Succursale4', 'Adresse 1 Ouest', 'Ouest', t_set_ref_Agence()));

INSERT INTO Succursale VALUES (Type_Succ(005, 'Succursale5', 'Adresse 2 Nord', 'Nord', t_set_ref_Agence()));

INSERT INTO Succursale VALUES (Type_Succ(006, 'Succursale6', 'Adresse 2 Nord', 'Sud', t_set_ref_Agence()));


COMMIT;


-- Verification !

SELECT COUNT(*) FROM Succursale;






/* Insertion de 25 agences réparties sur les succursales, */

INSERT INTO Agence VALUES (Type_Agence(101, 'Agence 1', 'Adresse Agence 1', 'Principale', (SELECT REF(s) FROM Succursale s WHERE s.NumSucc = 001), t_set_ref_Compte()));
INSERT INTO Agence VALUES (Type_Agence(102, 'Agence 2', 'Adresse Agence 2', 'Principale', (SELECT REF(s) FROM Succursale s WHERE s.NumSucc = 002), t_set_ref_Compte()));
INSERT INTO Agence VALUES (Type_Agence(103, 'Agence 3', 'Adresse Agence 3', 'Principale', (SELECT REF(s) FROM Succursale s WHERE s.NumSucc = 003), t_set_ref_Compte()));
INSERT INTO Agence VALUES (Type_Agence(104, 'Agence 4', 'Adresse Agence 4', 'Principale', (SELECT REF(s) FROM Succursale s WHERE s.NumSucc = 004), t_set_ref_Compte()));
INSERT INTO Agence VALUES (Type_Agence(105, 'Agence 5', 'Adresse Agence 5', 'Principale', (SELECT REF(s) FROM Succursale s WHERE s.NumSucc = 005), t_set_ref_Compte()));
INSERT INTO Agence VALUES (Type_Agence(106, 'Agence 6', 'Adresse Agence 6', 'Principale', (SELECT REF(s) FROM Succursale s WHERE s.NumSucc = 006), t_set_ref_Compte()));

INSERT INTO Agence VALUES (Type_Agence(107, 'Agence 7', 'Adresse Agence 7', 'Secondaire', (SELECT REF(s) FROM Succursale s WHERE s.NumSucc = 001), t_set_ref_Compte()));
INSERT INTO Agence VALUES (Type_Agence(108, 'Agence 8', 'Adresse Agence 8', 'Secondaire', (SELECT REF(s) FROM Succursale s WHERE s.NumSucc = 002), t_set_ref_Compte()));
INSERT INTO Agence VALUES (Type_Agence(109, 'Agence 9', 'Adresse Agence 9', 'Secondaire', (SELECT REF(s) FROM Succursale s WHERE s.NumSucc = 003), t_set_ref_Compte()));
INSERT INTO Agence VALUES (Type_Agence(110, 'Agence 10', 'Adresse Agence 10', 'Secondaire', (SELECT REF(s) FROM Succursale s WHERE s.NumSucc = 004), t_set_ref_Compte()));
INSERT INTO Agence VALUES (Type_Agence(111, 'Agence 11', 'Adresse Agence 11', 'Secondaire', (SELECT REF(s) FROM Succursale s WHERE s.NumSucc = 005), t_set_ref_Compte()));
INSERT INTO Agence VALUES (Type_Agence(112, 'Agence 12', 'Adresse Agence 12', 'Secondaire', (SELECT REF(s) FROM Succursale s WHERE s.NumSucc = 006), t_set_ref_Compte()));

INSERT INTO Agence VALUES (Type_Agence(113, 'Agence 13', 'Adresse Agence 13', 'Principale', (SELECT REF(s) FROM Succursale s WHERE s.NumSucc = 001), t_set_ref_Compte()));
INSERT INTO Agence VALUES (Type_Agence(114, 'Agence 14', 'Adresse Agence 14', 'Principale', (SELECT REF(s) FROM Succursale s WHERE s.NumSucc = 002), t_set_ref_Compte()));
INSERT INTO Agence VALUES (Type_Agence(115, 'Agence 15', 'Adresse Agence 15', 'Principale', (SELECT REF(s) FROM Succursale s WHERE s.NumSucc = 003), t_set_ref_Compte()));
INSERT INTO Agence VALUES (Type_Agence(116, 'Agence 16', 'Adresse Agence 16', 'Principale', (SELECT REF(s) FROM Succursale s WHERE s.NumSucc = 004), t_set_ref_Compte()));
INSERT INTO Agence VALUES (Type_Agence(117, 'Agence 17', 'Adresse Agence 17', 'Principale', (SELECT REF(s) FROM Succursale s WHERE s.NumSucc = 005), t_set_ref_Compte()));
INSERT INTO Agence VALUES (Type_Agence(118, 'Agence 18', 'Adresse Agence 18', 'Principale', (SELECT REF(s) FROM Succursale s WHERE s.NumSucc = 006), t_set_ref_Compte()));

INSERT INTO Agence VALUES (Type_Agence(119, 'Agence 19', 'Adresse Agence 19', 'Secondaire', (SELECT REF(s) FROM Succursale s WHERE s.NumSucc = 001), t_set_ref_Compte()));
INSERT INTO Agence VALUES (Type_Agence(120, 'Agence 20', 'Adresse Agence 20', 'Secondaire', (SELECT REF(s) FROM Succursale s WHERE s.NumSucc = 002), t_set_ref_Compte()));
INSERT INTO Agence VALUES (Type_Agence(121, 'Agence 21', 'Adresse Agence 21', 'Secondaire', (SELECT REF(s) FROM Succursale s WHERE s.NumSucc = 003), t_set_ref_Compte()));
INSERT INTO Agence VALUES (Type_Agence(122, 'Agence 22', 'Adresse Agence 22', 'Secondaire', (SELECT REF(s) FROM Succursale s WHERE s.NumSucc = 004), t_set_ref_Compte()));
INSERT INTO Agence VALUES (Type_Agence(123, 'Agence 23', 'Adresse Agence 23', 'Secondaire', (SELECT REF(s) FROM Succursale s WHERE s.NumSucc = 005), t_set_ref_Compte()));
INSERT INTO Agence VALUES (Type_Agence(124, 'Agence 24', 'Adresse Agence 24', 'Secondaire', (SELECT REF(s) FROM Succursale s WHERE s.NumSucc = 006), t_set_ref_Compte()));

INSERT INTO Agence VALUES (Type_Agence(125, 'Agence 25', 'Adresse Agence 25', 'Secondaire', (SELECT REF(s) FROM Succursale s WHERE s.NumSucc = 001), t_set_ref_Compte()));


COMMIT;

-- Verification !

SELECT COUNT(*) FROM Agence;







/*Insetion de 100 clients */

INSERT INTO Client VALUES (Type_Client(10001, 'Client 1', 'Particulier', 'Adresse Client 1', '051 134 567', 'client1@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10002, 'Client 2', 'Particulier', 'Adresse Client 2', '052 134 567', 'client2@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10003, 'Client 3', 'Particulier', 'Adresse Client 3', '053 134 567', 'client3@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10004, 'Client 4', 'Particulier', 'Adresse Client 4', '054 134 567', 'client4@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10005, 'Client 5', 'Particulier', 'Adresse Client 5', '055 134 567', 'client5@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10006, 'Client 6', 'Particulier', 'Adresse Client 6', '056 134 567', 'client6@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10007, 'Client 7', 'Particulier', 'Adresse Client 7', '057 134 567', 'client7@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10008, 'Client 8', 'Particulier', 'Adresse Client 8', '058 134 567', 'client8@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10009, 'Client 9', 'Particulier', 'Adresse Client 9', '059 134 567', 'client9@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10010, 'Client 10', 'Particulier', 'Adresse Client 10', '050 134 567', 'client10@email.com', t_set_ref_Compte()));

-- 10

INSERT INTO Client VALUES (Type_Client(10011, 'Client 11', 'Entreprise', 'Adresse Client 11', '021 134 567', 'client11@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10012, 'Client 12', 'Entreprise', 'Adresse Client 12', '022 134 567', 'client12@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10013, 'Client 13', 'Entreprise', 'Adresse Client 13', '023 134 567', 'client13@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10014, 'Client 14', 'Entreprise', 'Adresse Client 14', '024 134 567', 'client14@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10015, 'Client 15', 'Entreprise', 'Adresse Client 15', '025 134 567', 'client15@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10016, 'Client 16', 'Entreprise', 'Adresse Client 16', '026 134 567', 'client16@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10017, 'Client 17', 'Entreprise', 'Adresse Client 17', '027 134 567', 'client17@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10018, 'Client 18', 'Entreprise', 'Adresse Client 18', '028 134 567', 'client18@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10019, 'Client 19', 'Entreprise', 'Adresse Client 19', '029 134 567', 'client19@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10020, 'Client 20', 'Entreprise', 'Adresse Client 20', '020 134 567', 'client20@email.com', t_set_ref_Compte()));

-- 20

INSERT INTO Client VALUES (Type_Client(10021, 'Client 21', 'Particulier', 'Adresse Client 21', '051 234 567', 'client21@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10022, 'Client 22', 'Particulier', 'Adresse Client 22', '052 234 567', 'client22@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10023, 'Client 23', 'Particulier', 'Adresse Client 23', '053 234 567', 'client23@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10024, 'Client 24', 'Particulier', 'Adresse Client 24', '054 234 567', 'client24@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10025, 'Client 25', 'Particulier', 'Adresse Client 25', '055 234 567', 'client25@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10026, 'Client 26', 'Particulier', 'Adresse Client 26', '056 234 567', 'client26@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10027, 'Client 27', 'Particulier', 'Adresse Client 27', '057 234 567', 'client27@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10028, 'Client 28', 'Particulier', 'Adresse Client 28', '058 234 567', 'client28@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10029, 'Client 29', 'Particulier', 'Adresse Client 29', '059 234 567', 'client29@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10030, 'Client 30', 'Particulier', 'Adresse Client 30', '050 234 567', 'client30@email.com', t_set_ref_Compte()));
    
--30

INSERT INTO Client VALUES (Type_Client(10031, 'Client 31', 'Entreprise', 'Adresse Client 31', '021 234 567', 'client31@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10032, 'Client 32', 'Entreprise', 'Adresse Client 32', '022 234 567', 'client32@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10033, 'Client 33', 'Entreprise', 'Adresse Client 33', '023 234 567', 'client33@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10034, 'Client 34', 'Entreprise', 'Adresse Client 34', '024 234 567', 'client34@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10035, 'Client 35', 'Entreprise', 'Adresse Client 35', '025 234 567', 'client35@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10036, 'Client 36', 'Entreprise', 'Adresse Client 36', '026 234 567', 'client36@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10037, 'Client 37', 'Entreprise', 'Adresse Client 37', '027 234 567', 'client37@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10038, 'Client 38', 'Entreprise', 'Adresse Client 38', '028 234 567', 'client38@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10039, 'Client 39', 'Entreprise', 'Adresse Client 39', '029 234 567', 'client39@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10040, 'Client 40', 'Entreprise', 'Adresse Client 40', '020 234 567', 'client40@email.com', t_set_ref_Compte()));

--40

INSERT INTO Client VALUES (Type_Client(10041, 'Client 41', 'Particulier', 'Adresse Client 41', '051 334 567', 'client41@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10042, 'Client 42', 'Particulier', 'Adresse Client 42', '052 334 567', 'client42@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10043, 'Client 43', 'Particulier', 'Adresse Client 43', '053 334 567', 'client43@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10044, 'Client 44', 'Particulier', 'Adresse Client 44', '054 334 567', 'client44@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10045, 'Client 45', 'Particulier', 'Adresse Client 45', '055 334 567', 'client45@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10046, 'Client 46', 'Particulier', 'Adresse Client 46', '056 334 567', 'client46@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10047, 'Client 47', 'Particulier', 'Adresse Client 47', '057 334 567', 'client47@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10048, 'Client 48', 'Particulier', 'Adresse Client 48', '058 334 567', 'client48@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10049, 'Client 49', 'Particulier', 'Adresse Client 49', '059 334 567', 'client49@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10050, 'Client 40', 'Particulier', 'Adresse Client 50', '050 334 567', 'client50@email.com', t_set_ref_Compte()));

-- 50

INSERT INTO Client VALUES (Type_Client(10051, 'Client 51', 'Entreprise', 'Adresse Client 51', '021 334 567', 'client51@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10052, 'Client 52', 'Entreprise', 'Adresse Client 52', '022 334 567', 'client52@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10053, 'Client 53', 'Entreprise', 'Adresse Client 53', '023 334 567', 'client53@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10054, 'Client 54', 'Entreprise', 'Adresse Client 54', '024 334 567', 'client54@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10055, 'Client 55', 'Entreprise', 'Adresse Client 55', '025 334 567', 'client55@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10056, 'Client 56', 'Entreprise', 'Adresse Client 56', '026 334 567', 'client56@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10057, 'Client 57', 'Entreprise', 'Adresse Client 57', '027 334 567', 'client57@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10058, 'Client 58', 'Entreprise', 'Adresse Client 58', '028 334 567', 'client58@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10059, 'Client 59', 'Entreprise', 'Adresse Client 59', '029 334 567', 'client59@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10060, 'Client 60', 'Entreprise', 'Adresse Client 60', '020 334 567', 'client60@email.com', t_set_ref_Compte()));

--60

INSERT INTO Client VALUES (Type_Client(10061, 'Client 61', 'Particulier', 'Adresse Client 61', '051 434 567', 'client41@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10062, 'Client 62', 'Particulier', 'Adresse Client 62', '052 434 567', 'client42@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10063, 'Client 63', 'Particulier', 'Adresse Client 63', '053 434 567', 'client43@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10064, 'Client 64', 'Particulier', 'Adresse Client 64', '054 434 567', 'client44@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10065, 'Client 65', 'Particulier', 'Adresse Client 65', '055 434 567', 'client45@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10066, 'Client 66', 'Particulier', 'Adresse Client 66', '056 434 567', 'client46@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10067, 'Client 67', 'Particulier', 'Adresse Client 67', '057 434 567', 'client47@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10068, 'Client 68', 'Particulier', 'Adresse Client 68', '058 434 567', 'client48@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10069, 'Client 69', 'Particulier', 'Adresse Client 69', '059 434 567', 'client49@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10070, 'Client 70', 'Particulier', 'Adresse Client 70', '050 434 567', 'client50@email.com', t_set_ref_Compte()));

--70

INSERT INTO Client VALUES (Type_Client(10071, 'Client 71', 'Entreprise', 'Adresse Client 71', '021 434 567', 'client71@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10072, 'Client 72', 'Entreprise', 'Adresse Client 72', '022 434 567', 'client72@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10073, 'Client 73', 'Entreprise', 'Adresse Client 73', '023 434 567', 'client73@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10074, 'Client 74', 'Entreprise', 'Adresse Client 74', '024 434 567', 'client74@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10075, 'Client 75', 'Entreprise', 'Adresse Client 75', '025 434 567', 'client75@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10076, 'Client 76', 'Entreprise', 'Adresse Client 76', '026 434 567', 'client76@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10077, 'Client 77', 'Entreprise', 'Adresse Client 77', '027 434 567', 'client77@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10078, 'Client 78', 'Entreprise', 'Adresse Client 78', '028 434 567', 'client78@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10079, 'Client 79', 'Entreprise', 'Adresse Client 79', '029 434 567', 'client79@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10080, 'Client 80', 'Entreprise', 'Adresse Client 80', '020 434 567', 'client80@email.com', t_set_ref_Compte()));

--80

INSERT INTO Client VALUES (Type_Client(10081, 'Client 81', 'Particulier', 'Adresse Client 81', '051 534 567', 'client81@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10082, 'Client 82', 'Particulier', 'Adresse Client 82', '052 534 567', 'client82@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10083, 'Client 83', 'Particulier', 'Adresse Client 83', '053 534 567', 'client83@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10084, 'Client 84', 'Particulier', 'Adresse Client 84', '054 534 567', 'client84@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10085, 'Client 85', 'Particulier', 'Adresse Client 85', '055 534 567', 'client85@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10086, 'Client 86', 'Particulier', 'Adresse Client 86', '056 534 567', 'client86@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10087, 'Client 87', 'Particulier', 'Adresse Client 87', '057 534 567', 'client87@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10088, 'Client 88', 'Particulier', 'Adresse Client 88', '058 534 567', 'client88@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10089, 'Client 89', 'Particulier', 'Adresse Client 89', '059 534 567', 'client89@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10090, 'Client 90', 'Particulier', 'Adresse Client 90', '050 534 567', 'client80@email.com', t_set_ref_Compte()));

-- 90

INSERT INTO Client VALUES (Type_Client(10091, 'Client 91', 'Entreprise', 'Adresse Client 91', '021 534 567', 'client91@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10092, 'Client 92', 'Entreprise', 'Adresse Client 92', '022 534 567', 'client92@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10093, 'Client 93', 'Entreprise', 'Adresse Client 93', '023 534 567', 'client93@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10094, 'Client 94', 'Entreprise', 'Adresse Client 94', '024 534 567', 'client94@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10095, 'Client 95', 'Entreprise', 'Adresse Client 95', '025 534 567', 'client95@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10096, 'Client 96', 'Entreprise', 'Adresse Client 96', '026 534 567', 'client96@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10097, 'Client 97', 'Entreprise', 'Adresse Client 97', '027 534 567', 'client97@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10098, 'Client 98', 'Entreprise', 'Adresse Client 98', '028 534 567', 'client98@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10099, 'Client 99', 'Entreprise', 'Adresse Client 99', '029 534 567', 'client99@email.com', t_set_ref_Compte()));
INSERT INTO Client VALUES (Type_Client(10100, 'Client 100', 'Entreprise', 'Adresse Client 100', '020 534 567', 'client100@email.com', t_set_ref_Compte()));

-- 100 CLIENTS !


COMMIT;


-- Verification !

SELECT COUNT(*) FROM Client;







/* Comptes */

-- Comptes pour les clients 10001 et 10002
INSERT INTO Compte VALUES (Type_Compte(1010000001, '01/01/2000', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 101), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10001), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1020000002, '08/02/2000', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 102), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10002), 
t_set_ref_Operation(), t_set_ref_Pret()));

-- Comptes pour les clients 10001 et 10003
INSERT INTO Compte VALUES (Type_Compte(1030000003, '25/04/2000', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 103), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10001), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1040000004, '30/04/2000', 'Bloque', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 104), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10003), 
t_set_ref_Operation(), t_set_ref_Pret()));

-- Comptes pour les clients 10002 et 10003
INSERT INTO Compte VALUES (Type_Compte(1050000005, '15/05/2000', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 105), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10002), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1060000006, '03/10/2000', 'Bloque', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 106), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10003), 
t_set_ref_Operation(), t_set_ref_Pret()));

-- Comptes pour les clients 10001 et 10004
INSERT INTO Compte VALUES (Type_Compte(1070000007, '12/12/2000', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 107), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10001), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1080000008, '22/02/2001', 'Bloque', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 108), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10004), 
t_set_ref_Operation(), t_set_ref_Pret()));

-- Comptes pour les clients 10002 et 10004
INSERT INTO Compte VALUES (Type_Compte(1090000009, '05/05/2001', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 109), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10002), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1100000010, '10/10/2001', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 110), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10004), 
t_set_ref_Operation(), t_set_ref_Pret()));

-- Comptes pour les clients 10003 et 10004
INSERT INTO Compte VALUES (Type_Compte(1110000011, '15/01/2002', 'Bloque', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 111), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10003), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1120000012, '20/04/2002', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 112), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10004), 
t_set_ref_Operation(), t_set_ref_Pret()));

-- Comptes pour les clients 10001 et 10005
INSERT INTO Compte VALUES (Type_Compte(1130000013, '25/07/2002', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 113), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10001), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1140000014, '30/10/2002', 'Bloque', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 114), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10005), 
t_set_ref_Operation(), t_set_ref_Pret()));

-- Comptes pour les clients 10002 et 10005
INSERT INTO Compte VALUES (Type_Compte(1150000015, '04/01/2003', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 115), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10002), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1160000016, '09/04/2003', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 116), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10005), 
t_set_ref_Operation(), t_set_ref_Pret()));

-- Comptes pour les clients 10003 et 10005
INSERT INTO Compte VALUES (Type_Compte(1170000017, '14/07/2003', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 117), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10003), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1180000018, '19/10/2003', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 118), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10005), 
t_set_ref_Operation(), t_set_ref_Pret()));

-- Comptes pour les clients 10001 et 10006
INSERT INTO Compte VALUES (Type_Compte(1190000019, '24/01/2004', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 119), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10001), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1200000020, '29/04/2004', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 120), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10006), 
t_set_ref_Operation(), t_set_ref_Pret()));

-- Comptes pour les clients 10002 et 10006
INSERT INTO Compte VALUES (Type_Compte(1210000021, '03/08/2004', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 121), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10002), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1220000022, '08/11/2004', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 122), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10006), 
t_set_ref_Operation(), t_set_ref_Pret()));

-- Comptes pour les clients 10003 et 10006
INSERT INTO Compte VALUES (Type_Compte(1230000023, '13/02/2005', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 123), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10003), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1240000024, '18/05/2005', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 124), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10006), 
t_set_ref_Operation(), t_set_ref_Pret()));

-- Comptes pour les clients 10004 et 10006
INSERT INTO Compte VALUES (Type_Compte(1250000025, '23/08/2005', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 125), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10004), 
t_set_ref_Operation(), t_set_ref_Pret()));

--25 --

INSERT INTO Compte VALUES (Type_Compte(1010000026, '28/11/2005', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 101), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10006), 
t_set_ref_Operation(), t_set_ref_Pret()));

-- Comptes pour les clients 10005 et 10006
INSERT INTO Compte VALUES (Type_Compte(1020000027, '03/03/2006', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 102), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10005), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1030000028, '08/06/2006', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 103), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10006), 
t_set_ref_Operation(), t_set_ref_Pret()));

-- Comptes pour les clients 10001 et 10007
INSERT INTO Compte VALUES (Type_Compte(1040000029, '13/09/2006', 'Bloque', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 104), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10001), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1050000030, '18/12/2006', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 105), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10007), 
t_set_ref_Operation(), t_set_ref_Pret()));

/**************************************************************************************/
-- 30
/**************************************************************************************/

-- Comptes pour les clients 10002 et 10007
INSERT INTO Compte VALUES (Type_Compte(1060000031, '23/03/2007', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 106), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10002), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1070000032, '28/06/2007', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 107), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10007), 
t_set_ref_Operation(), t_set_ref_Pret()));

-- Comptes pour les clients 10003 et 10007
INSERT INTO Compte VALUES (Type_Compte(1080000033, '02/09/2007', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 108), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10003), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1090000034, '07/12/2007', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 109), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10007), 
t_set_ref_Operation(), t_set_ref_Pret()));

-- Comptes pour les clients 10004 et 10007
INSERT INTO Compte VALUES (Type_Compte(1100000035, '12/03/2008', 'Bloque', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 110), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10004), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1110000036, '17/06/2008', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 111), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10007), 
t_set_ref_Operation(), t_set_ref_Pret()));

-- Comptes pour les clients 10005 et 10007
INSERT INTO Compte VALUES (Type_Compte(1120000037, '22/09/2008', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 112), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10005), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1130000038, '27/12/2008', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 113), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10007), 
t_set_ref_Operation(), t_set_ref_Pret()));

-- Comptes pour les clients 10006 et 10007
INSERT INTO Compte VALUES (Type_Compte(1140000039, '01/03/2009', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 114), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10006), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1150000040, '06/06/2009', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 115), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10007), 
t_set_ref_Operation(), t_set_ref_Pret()));

-- Comptes pour les clients 10001 et 10008
INSERT INTO Compte VALUES (Type_Compte(1160000041, '11/09/2009', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 116), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10001), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1170000042, '16/12/2009', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 117), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10008), 
t_set_ref_Operation(), t_set_ref_Pret()));

-- Comptes pour les clients 10002 et 10008
INSERT INTO Compte VALUES (Type_Compte(1180000043, '21/03/2010', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 118), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10002), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1190000044, '26/06/2010', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 119), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10008), 
t_set_ref_Operation(), t_set_ref_Pret()));

-- Comptes pour les clients 10003 et 10008
INSERT INTO Compte VALUES (Type_Compte(1200000045, '01/09/2010', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 120), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10003), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1210000046, '06/12/2010', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 121), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10008), 
t_set_ref_Operation(), t_set_ref_Pret()));

-- Comptes pour les clients 10004 et 10008
INSERT INTO Compte VALUES (Type_Compte(1220000047, '11/03/2011', 'Bloque', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 122), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10004), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1230000048, '16/06/2011', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 123), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10008), 
t_set_ref_Operation(), t_set_ref_Pret()));

-- Comptes pour les clients 10005 et 10008
INSERT INTO Compte VALUES (Type_Compte(1240000049, '21/09/2011', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 124), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10005), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1250000050, '26/12/2011', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 125), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10008), 
t_set_ref_Operation(), t_set_ref_Pret()));

-- 50

-- Comptes pour les clients 10006 et 10008
INSERT INTO Compte VALUES (Type_Compte(1010000051, '01/03/2012', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 101), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10006), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1020000052, '06/06/2012', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 102), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10008), 
t_set_ref_Operation(), t_set_ref_Pret()));

-- Comptes pour les clients 10001 et 10009
INSERT INTO Compte VALUES (Type_Compte(1030000053, '11/09/2012', 'Bloque', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 103), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10001), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1040000054, '16/12/2012', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 104), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10009), 
t_set_ref_Operation(), t_set_ref_Pret()));

-- Comptes pour les clients 10002 et 10009
INSERT INTO Compte VALUES (Type_Compte(1050000055, '21/03/2013', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 105), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10002), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1060000056, '26/06/2013', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 106), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10009), 
t_set_ref_Operation(), t_set_ref_Pret()));

-- Comptes pour les clients 10003 et 10009
INSERT INTO Compte VALUES (Type_Compte(1070000057, '01/09/2013', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 107), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10003), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1080000058, '06/12/2013', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 108), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10009), 
t_set_ref_Operation(), t_set_ref_Pret()));

-- Comptes pour les clients 10004 et 10009
INSERT INTO Compte VALUES (Type_Compte(1090000059, '11/03/2014', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 109), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10004), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1100000060, '16/06/2014', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 110), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10009), 
t_set_ref_Operation(), t_set_ref_Pret()));

-- Comptes pour les clients 10005 et 10009
INSERT INTO Compte VALUES (Type_Compte(1110000061, '21/09/2014', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 111), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10005), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1120000062, '26/12/2014', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 112), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10009), 
t_set_ref_Operation(), t_set_ref_Pret()));

-- Comptes pour les clients 10006 et 10009
INSERT INTO Compte VALUES (Type_Compte(1130000063, '01/03/2015', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 113), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10006), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1140000064, '06/06/2015', 'Bloque', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 114), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10009), 
t_set_ref_Operation(), t_set_ref_Pret()));

-- Comptes pour les clients 10007 et 10009
INSERT INTO Compte VALUES (Type_Compte(1150000065, '11/09/2015', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 115), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10007), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1160000066, '16/12/2015', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 116), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10009), 
t_set_ref_Operation(), t_set_ref_Pret()));

-- Comptes pour les clients 10008 et 10009
INSERT INTO Compte VALUES (Type_Compte(1170000067, '21/03/2016', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 117), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10008), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1180000068, '26/06/2016', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 118), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10009), 
t_set_ref_Operation(), t_set_ref_Pret()));

-- Comptes pour les clients 10009 et 10010
INSERT INTO Compte VALUES (Type_Compte(1190000069, '01/09/2016', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 119), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10009), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1200000070, '06/12/2016', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 120), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10010), 
t_set_ref_Operation(), t_set_ref_Pret()));

-- Comptes pour les clients 10009 et 10011
INSERT INTO Compte VALUES (Type_Compte(1210000071, '11/03/2017', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 121), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10009), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1220000072, '16/06/2017', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 122), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10011), 
t_set_ref_Operation(), t_set_ref_Pret()));

-- Comptes pour les clients 10009 et 10012
INSERT INTO Compte VALUES (Type_Compte(1230000073, '21/09/2017', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 123), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10009), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1240000074, '26/12/2017', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 124), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10012), 
t_set_ref_Operation(), t_set_ref_Pret()));

-- Comptes pour les clients 10010 et 10012
INSERT INTO Compte VALUES (Type_Compte(1250000075, '01/03/2018', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 125), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10010), 
t_set_ref_Operation(), t_set_ref_Pret()));

--75

INSERT INTO Compte VALUES (Type_Compte(1010000076, '06/06/2018', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 101), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10012), 
t_set_ref_Operation(), t_set_ref_Pret()));

-- Comptes pour les clients 10011 et 10012
INSERT INTO Compte VALUES (Type_Compte(1020000077, '11/09/2018', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 102), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10011), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1030000078, '16/12/2018', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 103), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10012), 
t_set_ref_Operation(), t_set_ref_Pret()));

-- Comptes pour les clients 10011 et 10013
INSERT INTO Compte VALUES (Type_Compte(1040000079, '21/03/2019', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 104), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10011), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1050000080, '26/06/2019', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 105), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10013), 
t_set_ref_Operation(), t_set_ref_Pret()));

-- Comptes pour les clients 10011 et 10014
INSERT INTO Compte VALUES (Type_Compte(1060000081, '01/09/2019', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 106), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10011), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1070000082, '06/12/2019', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 107), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10014), 
t_set_ref_Operation(), t_set_ref_Pret()));

-- Comptes pour les clients 10011 et 10015
INSERT INTO Compte VALUES (Type_Compte(1080000083, '11/03/2020', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 108), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10011), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1090000084, '16/06/2020', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 109), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10015), 
t_set_ref_Operation(), t_set_ref_Pret()));

-- Comptes pour les clients 10011 et 10016
INSERT INTO Compte VALUES (Type_Compte(1100000085, '21/09/2020', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 110), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10011), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1110000086, '26/12/2020', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 111), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10016), 
t_set_ref_Operation(), t_set_ref_Pret()));

-- Comptes pour les clients 10017 et 10018
INSERT INTO Compte VALUES (Type_Compte(1120000087, '01/03/2021', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 112), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10017), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1130000088, '06/06/2021', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 113), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10018), 
t_set_ref_Operation(), t_set_ref_Pret()));

-- Comptes pour les clients 10019 et 10020
INSERT INTO Compte VALUES (Type_Compte(1140000089, '11/09/2021', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 114), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10019), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1150000090, '16/12/2021', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 115), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10020), 
t_set_ref_Operation(), t_set_ref_Pret()));

-- Comptes pour les clients 10021 et 10022
INSERT INTO Compte VALUES (Type_Compte(1160000091, '21/03/2022', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 116), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10021), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1170000092, '26/06/2022', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 117), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10022), 
t_set_ref_Operation(), t_set_ref_Pret()));

-- Comptes pour les clients 10023 et 10024
INSERT INTO Compte VALUES (Type_Compte(1180000093, '01/09/2022', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 118), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10023), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1190000094, '06/12/2022', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 119), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10024), 
t_set_ref_Operation(), t_set_ref_Pret()));

-- Comptes pour les clients 10025 et 10026
INSERT INTO Compte VALUES (Type_Compte(1200000095, '11/03/2023', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 120), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10025), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1210000096, '16/06/2023', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 121), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10026), 
t_set_ref_Operation(), t_set_ref_Pret()));

-- Comptes pour les clients 10027 et 10028
INSERT INTO Compte VALUES (Type_Compte(1220000097, '21/09/2023', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 122), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10027), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1230000098, '26/12/2023', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 123), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10028), 
t_set_ref_Operation(), t_set_ref_Pret()));

--98

INSERT INTO Compte VALUES (Type_Compte(1230000099, '26/12/2023', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 123), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10027), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1230000100, '26/12/2023', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 123), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10028), 
t_set_ref_Operation(), t_set_ref_Pret()));

-- 100

-- Comptes pour les clients 10031 et 10032
INSERT INTO Compte VALUES (Type_Compte(1010000101, '11/09/2023', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 101), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10031), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1020000102, '16/12/2023', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 102), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10032), 
t_set_ref_Operation(), t_set_ref_Pret()));

-- Comptes pour les clients 10033 et 10034
INSERT INTO Compte VALUES (Type_Compte(1030000103, '21/03/2023', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 103), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10033), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1040000104, '26/06/2023', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 104), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10034), 
t_set_ref_Operation(), t_set_ref_Pret()));

-- Comptes pour les clients 10035 et 10036
INSERT INTO Compte VALUES (Type_Compte(1050000105, '01/09/2023', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 105), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10035), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1060000106, '06/12/2023', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 106), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10036), 
t_set_ref_Operation(), t_set_ref_Pret()));

-- Comptes pour les clients 10037 et 10038
INSERT INTO Compte VALUES (Type_Compte(1070000107, '11/03/2023', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 107), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10037), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1080000108, '16/06/2023', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 108), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10038), 
t_set_ref_Operation(), t_set_ref_Pret()));

-- Comptes pour les clients 10039 et 10040
INSERT INTO Compte VALUES (Type_Compte(1090000109, '21/09/2023', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 109), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10039), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1100000110, '26/12/2023', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 110), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10040), 
t_set_ref_Operation(), t_set_ref_Pret()));

-- Comptes pour les clients 10041 et 10042
INSERT INTO Compte VALUES (Type_Compte(1110000111, '01/03/2023', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 111), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10041), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1120000112, '06/06/2023', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 112), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10042), 
t_set_ref_Operation(), t_set_ref_Pret()));

-- Comptes pour les clients 10043 et 10044
INSERT INTO Compte VALUES (Type_Compte(1130000113, '11/09/2023', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 113), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10043), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1140000114, '16/12/2023', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 114), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10044), 
t_set_ref_Operation(), t_set_ref_Pret()));

-- Comptes pour les clients 10045 et 10046
INSERT INTO Compte VALUES (Type_Compte(1150000115, '21/03/2023', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 115), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10045), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1160000116, '26/06/2023', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 116), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10046), 
t_set_ref_Operation(), t_set_ref_Pret()));

-- Comptes pour les clients 10047 et 10048
INSERT INTO Compte VALUES (Type_Compte(1170000117, '01/09/2023', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 117), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10047), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1180000118, '06/12/2023', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 118), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10048), 
t_set_ref_Operation(), t_set_ref_Pret()));

-- Comptes pour les clients 10049 et 10050
INSERT INTO Compte VALUES (Type_Compte(1190000119, '11/03/2023', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 119), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10049), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1200000120, '16/06/2023', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 120), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10050), 
t_set_ref_Operation(), t_set_ref_Pret()));

-- 120 COMPTES

INSERT INTO Compte VALUES (Type_Compte(1210000121, '21/09/2023', 'Actif', 100.00,
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 121), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10050), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1220000122, '21/09/2023', 'Actif', 100.00,
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 122), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10050), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1230000123, '21/09/2023', 'Actif', 100.00,
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 123), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10048), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1240000124, '16/06/2023', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 124), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10048), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1250000125, '16/06/2023', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 125), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10048), 
t_set_ref_Operation(), t_set_ref_Pret()));

--125

INSERT INTO Compte VALUES (Type_Compte(1010000126, '16/06/2023', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 101), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10032), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1200000127, '16/06/2023', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 120), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10032), 
t_set_ref_Operation(), t_set_ref_Pret()));


INSERT INTO Compte VALUES (Type_Compte(1100000128, '16/06/2023', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 110), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10032), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1080000129, '16/06/2023', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 108), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10032), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1010000130, '16/06/2023', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 101), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10041), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1020000131, '16/06/2023', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 102), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10041), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1030000132, '16/06/2023', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 103), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10041), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1200000133, '16/06/2023', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 120), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10042), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1210000134, '16/06/2023', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 120), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10042), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1230000135, '16/06/2023', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 120), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10042), 
t_set_ref_Operation(), t_set_ref_Pret()));
-------------------------------------------------------------------------------------------
INSERT INTO Compte VALUES (Type_Compte(1240000136, '16/06/2023', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 124), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10042), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1080000137, '16/06/2023', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 108), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10037), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1090000138, '16/06/2023', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 109), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10037), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1100000139, '16/06/2023', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 110), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 100037), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1110005564, '16/06/2022', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 111), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10037), 
t_set_ref_Operation(), t_set_ref_Pret()));

INSERT INTO Compte VALUES (Type_Compte(1180005564, '16/06/2022', 'Actif', 100.00, 
(SELECT REF(a) FROM Agence a WHERE a.NumAgence = 118), 
(SELECT REF(c) FROM Client c WHERE c.NumClient = 10004), 
t_set_ref_Operation(), t_set_ref_Pret()));



-- 141 COMPTES de 50 clients différents !


COMMIT;


-- Verification !

SELECT COUNT(*) FROM Comptes;










/*dont 40 ont effectué des prêts auprès de différentes agences rattachées à différentes succursales*/

INSERT INTO Pret VALUES (Type_Pret (1, 7000.00, '15/01/2023', '2 ans', 'Vehicule', 0.10, 100.00, (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1010000001)));
INSERT INTO Pret VALUES (Type_Pret (2, 6000.00, '28/03/2023', '3 ans', 'Vehicule', 0.10, 100.00, (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1020000002)));
INSERT INTO Pret VALUES (Type_Pret (3, 5000.00, '10/05/2023', '4 ans', 'Vehicule', 0.10, 100.00, (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1040000004)));
INSERT INTO Pret VALUES (Type_Pret (4, 4000.00, '21/07/2023', '5 ans', 'Vehicule', 0.10, 100.00, (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1100000010)));
INSERT INTO Pret VALUES (Type_Pret (5, 3000.00, '02/09/2023', '6 ans', 'Vehicule', 0.10, 100.00, (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1160000016)));
INSERT INTO Pret VALUES (Type_Pret (6, 2000.00, '14/11/2023', '7 ans', 'Vehicule', 0.10, 100.00, (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1200000020)));
INSERT INTO Pret VALUES (Type_Pret (7, 8000.00, '06/02/2023', '2 ans', 'Vehicule', 0.10, 100.00, (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1050000030)));
INSERT INTO Pret VALUES (Type_Pret (8, 9000.00, '17/04/2023', '3 ans', 'Vehicule', 0.10, 100.00, (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1190000044)));
INSERT INTO Pret VALUES (Type_Pret (9, 10000.00, '29/06/2023', '4 ans', 'Vehicule', 0.10, 100.00, (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1040000054)));
INSERT INTO Pret VALUES (Type_Pret (10, 8000.00, '10/08/2023', '5 ans', 'Vehicule', 0.10, 100.00, (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1200000070)));

-- 10

INSERT INTO Pret VALUES (Type_Pret (11, 9000.00, '03/06/2019', '6 ans', 'Immobilier', 0.10, 100.00, (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1220000072)));
INSERT INTO Pret VALUES (Type_Pret (12, 5000.00, '08/02/2018', '7 ans', 'Immobilier', 0.10, 100.00, (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1240000074)));
INSERT INTO Pret VALUES (Type_Pret (13, 3000.00, '27/05/2023', '2 ans', 'Immobilier', 0.10, 100.00, (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1050000080)));
INSERT INTO Pret VALUES (Type_Pret (14, 2000.00, '07/12/2019', '3 ans', 'Immobilier', 0.10, 100.00, (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1070000082)));
INSERT INTO Pret VALUES (Type_Pret (15, 6000.00, '30/09/2020', '4 ans', 'Immobilier', 0.10, 100.00, (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1090000084)));
INSERT INTO Pret VALUES (Type_Pret (16, 4000.00, '28/12/2020', '5 ans', 'Immobilier', 0.10, 100.00, (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1110000086)));
INSERT INTO Pret VALUES (Type_Pret (17, 5000.00, '11/09/2021', '6 ans', 'Immobilier', 0.10, 100.00, (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1120000087)));
INSERT INTO Pret VALUES (Type_Pret (18, 2000.00, '11/03/2021', '7 ans', 'Immobilier', 0.10, 100.00, (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1130000088)));
INSERT INTO Pret VALUES (Type_Pret (19, 1000.00, '11/04/2021', '2 ans', 'Immobilier', 0.10, 100.00, (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1140000089)));
INSERT INTO Pret VALUES (Type_Pret (20, 10000.00, '11/05/2021', '3 ans', 'Immobilier', 0.10, 100.00, (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1150000090)));

-- 20

INSERT INTO Pret VALUES (Type_Pret (21, 5000.00, '01/01/2023', '4 ans', 'ANSEJ', 0.10, 100.00, (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1160000091)));
INSERT INTO Pret VALUES (Type_Pret (22, 2000.00, '02/02/2020', '5 ans', 'ANSEJ', 0.10, 100.00, (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1170000092)));
INSERT INTO Pret VALUES (Type_Pret (23, 8000.00, '11/03/2020', '6 ans', 'ANSEJ', 0.10, 100.00, (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1180000093)));
INSERT INTO Pret VALUES (Type_Pret (24, 9000.00, '21/09/2022', '7 ans', 'ANSEJ', 0.10, 100.00, (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1190000094)));
INSERT INTO Pret VALUES (Type_Pret (25, 4000.00, '11/11/2022', '2 ans', 'ANSEJ', 0.10, 100.00, (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1200000095)));
INSERT INTO Pret VALUES (Type_Pret (26, 6000.00, '03/03/2022', '3 ans', 'ANSEJ', 0.10, 100.00, (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1210000096)));
INSERT INTO Pret VALUES (Type_Pret (27, 2000.00, '05/09/2023', '4 ans', 'ANSEJ', 0.10, 100.00, (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1220000097)));
INSERT INTO Pret VALUES (Type_Pret (28, 4000.00, '12/12/2023', '5 ans', 'ANSEJ', 0.10, 100.00, (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1230000100)));
INSERT INTO Pret VALUES (Type_Pret (29, 3000.00, '11/09/2023', '6 ans', 'ANSEJ', 0.10, 100.00, (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1010000101)));
INSERT INTO Pret VALUES (Type_Pret (30, 4000.00, '30/12/2023', '7 ans', 'ANSEJ', 0.10, 100.00, (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1020000102)));

-- 30

INSERT INTO Pret VALUES (Type_Pret (31, 2000.00, '25/12/2023', '2 ans', 'ANJEM', 0.10, 100.00, (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1030000103)));
INSERT INTO Pret VALUES (Type_Pret (32, 10000.00, '25/12/2023', '3 ans', 'ANJEM', 0.10, 100.00, (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1040000104)));
INSERT INTO Pret VALUES (Type_Pret (33, 5000.00, '26/12/2023', '4 ans', 'ANJEM', 0.10, 100.00, (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1050000105)));
INSERT INTO Pret VALUES (Type_Pret (34, 7000.00, '26/12/2023', '5 ans', 'ANJEM', 0.10, 100.00, (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1060000106)));
INSERT INTO Pret VALUES (Type_Pret (35, 8000.00, '27/12/2023', '6 ans', 'ANJEM', 0.10, 100.00, (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1070000107)));
INSERT INTO Pret VALUES (Type_Pret (36, 9000.00, '28/12/2023', '7 ans', 'ANJEM', 0.10, 100.00, (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1080000108)));
INSERT INTO Pret VALUES (Type_Pret (37, 1000.00, '28/12/2023', '2 ans', 'ANJEM', 0.10, 100.00, (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1090000109)));
INSERT INTO Pret VALUES (Type_Pret (38, 2000.00, '28/12/2023', '3 ans', 'ANJEM', 0.10, 100.00, (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1100000110)));
INSERT INTO Pret VALUES (Type_Pret (39, 3000.00, '30/12/2023', '4 ans', 'ANJEM', 0.10, 100.00, (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1200000120)));
INSERT INTO Pret VALUES (Type_Pret (40, 5000.00, '30/12/2023', '5 ans', 'ANJEM', 0.10, 100.00, (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1180005564)));
INSERT INTO Pret VALUES (Type_Pret (41, 2200.00, '30/12/2023', '2 ans', 'ANJEM', 0.10, 100.00, (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1110005564)));

-- 41 Prets differents de 40 comptes de clients differents !


-- Verification !

SELECT COUNT(*) FROM Pret;





/*un nombre considérable d’opérations de débit/crédit sur les différents comptes*/

INSERT INTO Operation VALUES (Type_Operation (1, 'Debit', 50.00, '01/01/2023', 'Operation non Justifiée', (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1110000111)));
INSERT INTO Operation VALUES (Type_Operation (2, 'Debit', 50.00, '10/02/2023', 'Operation non Justifiée', (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1110000111)));
INSERT INTO Operation VALUES (Type_Operation (3, 'Debit', 10.00, '01/03/2023', 'Operation non Justifiée', (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1120000112)));
INSERT INTO Operation VALUES (Type_Operation (4, 'Debit', 30.00, '01/04/2023', 'Operation non Justifiée', (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1130000113)));
INSERT INTO Operation VALUES (Type_Operation (5, 'Debit', 25.00, '01/05/2023', 'Operation non Justifiée', (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1140000114)));
INSERT INTO Operation VALUES (Type_Operation (6, 'Debit', 10.00, '01/06/2023', 'Operation non Justifiée', (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1150000115)));
INSERT INTO Operation VALUES (Type_Operation (7, 'Debit', 20.00, '01/07/2023', 'Operation non Justifiée', (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1160000116)));
INSERT INTO Operation VALUES (Type_Operation (8, 'Debit', 40.00, '01/08/2023', 'Operation non Justifiée', (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1170000117)));
INSERT INTO Operation VALUES (Type_Operation (9, 'Debit', 80.00, '01/09/2023', 'Operation non Justifiée', (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1180000118)));
INSERT INTO Operation VALUES (Type_Operation (10, 'Debit', 50.00, '01/10/2023', 'Operation non Justifiée', (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1190000119)));

-- 10

INSERT INTO Operation VALUES (Type_Operation (11, 'Credit', 50.00, '01/06/2023', 'Operation non Justifiée', (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1200000120)));
INSERT INTO Operation VALUES (Type_Operation (12, 'Credit', 50.00, '01/09/2023', 'Operation non Justifiée', (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1210000121)));
INSERT INTO Operation VALUES (Type_Operation (13, 'Credit', 10.00, '01/08/2023', 'Operation non Justifiée', (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1220000122)));
INSERT INTO Operation VALUES (Type_Operation (14, 'Credit', 30.00, '01/05/2023', 'Operation non Justifiée', (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1230000123)));
INSERT INTO Operation VALUES (Type_Operation (15, 'Credit', 25.00, '01/05/2023', 'Operation non Justifiée', (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1240000124)));
INSERT INTO Operation VALUES (Type_Operation (16, 'Credit', 10.00, '01/02/2023', 'Operation non Justifiée', (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1250000125)));
INSERT INTO Operation VALUES (Type_Operation (17, 'Credit', 20.00, '01/03/2023', 'Operation non Justifiée', (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1010000126)));
INSERT INTO Operation VALUES (Type_Operation (18, 'Credit', 40.00, '01/04/2023', 'Operation non Justifiée', (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1200000127)));
INSERT INTO Operation VALUES (Type_Operation (19, 'Credit', 80.00, '01/12/2023', 'Operation non Justifiée', (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1100000128)));
INSERT INTO Operation VALUES (Type_Operation (20, 'Credit', 50.00, '01/11/2023', 'Operation non Justifiée', (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1080000129)));

--20

INSERT INTO Operation VALUES (Type_Operation (21, 'Credit', 50.00, '01/01/2022', 'Operation non Justifiée', (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1110000111)));
INSERT INTO Operation VALUES (Type_Operation (22, 'Credit', 50.00, '10/02/2022', 'Operation non Justifiée', (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1110000111)));
INSERT INTO Operation VALUES (Type_Operation (23, 'Credit', 10.00, '01/03/2022', 'Operation non Justifiée', (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1120000112)));
INSERT INTO Operation VALUES (Type_Operation (24, 'Credit', 30.00, '01/04/2022', 'Operation non Justifiée', (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1130000113)));
INSERT INTO Operation VALUES (Type_Operation (25, 'Credit', 25.00, '01/05/2022', 'Operation non Justifiée', (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1140000114)));
INSERT INTO Operation VALUES (Type_Operation (26, 'Debit', 10.00, '01/06/2022', 'Operation non Justifiée', (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1150000115)));
INSERT INTO Operation VALUES (Type_Operation (27, 'Debit', 20.00, '01/07/2022', 'Operation non Justifiée', (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1160000116)));
INSERT INTO Operation VALUES (Type_Operation (28, 'Debit', 40.00, '01/08/2022', 'Operation non Justifiée', (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1170000117)));
INSERT INTO Operation VALUES (Type_Operation (29, 'Debit', 80.00, '01/09/2020', 'Operation non Justifiée', (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1180000118)));
INSERT INTO Operation VALUES (Type_Operation (30, 'Debit', 50.00, '01/10/2001', 'Operation non Justifiée', (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1190000119)));

--30

INSERT INTO Operation VALUES (Type_Operation (31, 'Credit', 50.00, '09/08/2005', 'Operation non Justifiée', (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1200000120)));
INSERT INTO Operation VALUES (Type_Operation (32, 'Credit', 50.00, '08/09/2000', 'Operation non Justifiée', (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1210000121)));
INSERT INTO Operation VALUES (Type_Operation (33, 'Credit', 10.00, '02/08/2002', 'Operation non Justifiée', (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1220000122)));
INSERT INTO Operation VALUES (Type_Operation (34, 'Credit', 30.00, '04/05/2023', 'Operation non Justifiée', (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1230000123)));
INSERT INTO Operation VALUES (Type_Operation (35, 'Credit', 25.00, '17/05/2023', 'Operation non Justifiée', (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1240000124)));
INSERT INTO Operation VALUES (Type_Operation (36, 'Debit', 10.00, '02/05/2023', 'Operation non Justifiée', (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1250000125)));
INSERT INTO Operation VALUES (Type_Operation (37, 'Debit', 20.00, '25/02/2023', 'Operation non Justifiée', (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1010000126)));
INSERT INTO Operation VALUES (Type_Operation (38, 'Debit', 40.00, '23/07/2023', 'Operation non Justifiée', (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1200000127)));
INSERT INTO Operation VALUES (Type_Operation (39, 'Debit', 80.00, '25/11/2023', 'Operation non Justifiée', (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1100000128)));
INSERT INTO Operation VALUES (Type_Operation (40, 'Debit', 50.00, '01/1/2023', 'Operation non Justifiée', (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1080000129)));

--40

INSERT INTO Operation VALUES (Type_Operation (41, 'Credit', 50.00, '09/08/2005', 'Operation non Justifiée', (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1030000103)));
INSERT INTO Operation VALUES (Type_Operation (42, 'Credit', 50.00, '08/09/2000', 'Operation non Justifiée', (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1040000104)));
INSERT INTO Operation VALUES (Type_Operation (43, 'Credit', 10.00, '02/08/2002', 'Operation non Justifiée', (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1080000108)));
INSERT INTO Operation VALUES (Type_Operation (44, 'Credit', 30.00, '04/05/2023', 'Operation non Justifiée', (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1180005564)));
INSERT INTO Operation VALUES (Type_Operation (45, 'Credit', 25.00, '17/05/2023', 'Operation non Justifiée', (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1180005564)));
INSERT INTO Operation VALUES (Type_Operation (46, 'Debit', 10.00, '02/05/2023', 'Operation non Justifiée', (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1180005564)));
INSERT INTO Operation VALUES (Type_Operation (47, 'Debit', 20.00, '25/02/2023', 'Operation non Justifiée', (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1080000108)));
INSERT INTO Operation VALUES (Type_Operation (48, 'Debit', 40.00, '23/07/2023', 'Operation non Justifiée', (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1200000070)));
INSERT INTO Operation VALUES (Type_Operation (49, 'Debit', 80.00, '25/11/2023', 'Operation non Justifiée', (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1040000004)));
INSERT INTO Operation VALUES (Type_Operation (50, 'Debit', 50.00, '01/1/2023', 'Operation non Justifiée', (SELECT REF(c) FROM Compte c WHERE c.NumCompte = 1100000010)));

--50


-- Verification !

SELECT COUNT(*) FROM Operation;


/* Insertion dans les tables imbriquées */


/* Succursale_Agence */

INSERT INTO TABLE (SELECT s.Succursale_Agence FROM Succursale s WHERE s.numSucc=1) VALUES ((SELECT REF(a) FROM Agence a WHERE a.NumAgence=101));   
INSERT INTO TABLE (SELECT s.Succursale_Agence FROM Succursale s WHERE s.numSucc=2) VALUES ((SELECT REF(a) FROM Agence a WHERE a.NumAgence=102));   
INSERT INTO TABLE (SELECT s.Succursale_Agence FROM Succursale s WHERE s.numSucc=3) VALUES ((SELECT REF(a) FROM Agence a WHERE a.NumAgence=103));   
INSERT INTO TABLE (SELECT s.Succursale_Agence FROM Succursale s WHERE s.numSucc=4) VALUES ((SELECT REF(a) FROM Agence a WHERE a.NumAgence=104));   
INSERT INTO TABLE (SELECT s.Succursale_Agence FROM Succursale s WHERE s.numSucc=5) VALUES ((SELECT REF(a) FROM Agence a WHERE a.NumAgence=105));   
INSERT INTO TABLE (SELECT s.Succursale_Agence FROM Succursale s WHERE s.numSucc=6) VALUES ((SELECT REF(a) FROM Agence a WHERE a.NumAgence=106));  

INSERT INTO TABLE (SELECT s.Succursale_Agence FROM Succursale s WHERE s.numSucc=1) VALUES ((SELECT REF(a) FROM Agence a WHERE a.NumAgence=107));   
INSERT INTO TABLE (SELECT s.Succursale_Agence FROM Succursale s WHERE s.numSucc=2) VALUES ((SELECT REF(a) FROM Agence a WHERE a.NumAgence=108));   
INSERT INTO TABLE (SELECT s.Succursale_Agence FROM Succursale s WHERE s.numSucc=3) VALUES ((SELECT REF(a) FROM Agence a WHERE a.NumAgence=109));   
INSERT INTO TABLE (SELECT s.Succursale_Agence FROM Succursale s WHERE s.numSucc=4) VALUES ((SELECT REF(a) FROM Agence a WHERE a.NumAgence=110));   
INSERT INTO TABLE (SELECT s.Succursale_Agence FROM Succursale s WHERE s.numSucc=5) VALUES ((SELECT REF(a) FROM Agence a WHERE a.NumAgence=111));   
INSERT INTO TABLE (SELECT s.Succursale_Agence FROM Succursale s WHERE s.numSucc=6) VALUES ((SELECT REF(a) FROM Agence a WHERE a.NumAgence=112));   

INSERT INTO TABLE (SELECT s.Succursale_Agence FROM Succursale s WHERE s.numSucc=1) VALUES ((SELECT REF(a) FROM Agence a WHERE a.NumAgence=113));   
INSERT INTO TABLE (SELECT s.Succursale_Agence FROM Succursale s WHERE s.numSucc=2) VALUES ((SELECT REF(a) FROM Agence a WHERE a.NumAgence=114));   
INSERT INTO TABLE (SELECT s.Succursale_Agence FROM Succursale s WHERE s.numSucc=3) VALUES ((SELECT REF(a) FROM Agence a WHERE a.NumAgence=115));   
INSERT INTO TABLE (SELECT s.Succursale_Agence FROM Succursale s WHERE s.numSucc=4) VALUES ((SELECT REF(a) FROM Agence a WHERE a.NumAgence=116));   
INSERT INTO TABLE (SELECT s.Succursale_Agence FROM Succursale s WHERE s.numSucc=5) VALUES ((SELECT REF(a) FROM Agence a WHERE a.NumAgence=117));   
INSERT INTO TABLE (SELECT s.Succursale_Agence FROM Succursale s WHERE s.numSucc=6) VALUES ((SELECT REF(a) FROM Agence a WHERE a.NumAgence=118));   

INSERT INTO TABLE (SELECT s.Succursale_Agence FROM Succursale s WHERE s.numSucc=1) VALUES ((SELECT REF(a) FROM Agence a WHERE a.NumAgence=119));   
INSERT INTO TABLE (SELECT s.Succursale_Agence FROM Succursale s WHERE s.numSucc=2) VALUES ((SELECT REF(a) FROM Agence a WHERE a.NumAgence=120));   
INSERT INTO TABLE (SELECT s.Succursale_Agence FROM Succursale s WHERE s.numSucc=3) VALUES ((SELECT REF(a) FROM Agence a WHERE a.NumAgence=121));   
INSERT INTO TABLE (SELECT s.Succursale_Agence FROM Succursale s WHERE s.numSucc=4) VALUES ((SELECT REF(a) FROM Agence a WHERE a.NumAgence=122));   
INSERT INTO TABLE (SELECT s.Succursale_Agence FROM Succursale s WHERE s.numSucc=5) VALUES ((SELECT REF(a) FROM Agence a WHERE a.NumAgence=123));   
INSERT INTO TABLE (SELECT s.Succursale_Agence FROM Succursale s WHERE s.numSucc=6) VALUES ((SELECT REF(a) FROM Agence a WHERE a.NumAgence=124));   

INSERT INTO TABLE (SELECT s.Succursale_Agence FROM Succursale s WHERE s.numSucc=1) VALUES ((SELECT REF(a) FROM Agence a WHERE a.NumAgence=125));   


COMMIT;


-- Verification !

SELECT COUNT(*) FROM TABLE (SELECT s.Succursale_Agence FROM Succursale s WHERE s.NumSucc=1);
SELECT COUNT(*) FROM TABLE (SELECT s.Succursale_Agence FROM Succursale s WHERE s.NumSucc=2);
SELECT COUNT(*) FROM TABLE (SELECT s.Succursale_Agence FROM Succursale s WHERE s.NumSucc=3);
SELECT COUNT(*) FROM TABLE (SELECT s.Succursale_Agence FROM Succursale s WHERE s.NumSucc=4);
SELECT COUNT(*) FROM TABLE (SELECT s.Succursale_Agence FROM Succursale s WHERE s.NumSucc=5);
SELECT COUNT(*) FROM TABLE (SELECT s.Succursale_Agence FROM Succursale s WHERE s.NumSucc=6);



/* Agence_Compte */

INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=101) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1010000001));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=102) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1020000002));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=103) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1030000003));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=104) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1040000004));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=105) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1050000005));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=106) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1060000006));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=107) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1070000007));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=108) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1080000008));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=109) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1090000009));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=110) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1100000010));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=111) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1110000011));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=112) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1120000012));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=113) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1130000013));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=114) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1140000014));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=115) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1150000015));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=116) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1160000016));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=117) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1170000017));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=118) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1180000018));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=119) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1190000019));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=120) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1200000020));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=121) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1210000021));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=122) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1220000022));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=123) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1230000023));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=124) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1240000024));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=125) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1250000025));   

--25

INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=101) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1010000026));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=102) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1020000027));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=103) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1030000028));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=104) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1040000029));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=105) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1050000030));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=106) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1060000031));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=107) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1070000032));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=108) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1080000033));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=109) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1090000034));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=110) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1100000035));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=111) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1110000036));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=112) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1120000037));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=113) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1130000038));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=114) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1140000039));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=115) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1150000040));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=116) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1160000041));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=117) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1170000042));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=118) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1180000043));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=119) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1190000044));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=120) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1200000045));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=121) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1210000046));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=122) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1220000047));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=123) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1230000048));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=124) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1240000049));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=125) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1250000050));   

--50

INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=101) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1010000051));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=102) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1020000052));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=103) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1030000053));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=104) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1040000054));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=105) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1050000055));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=106) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1060000056));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=107) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1070000057));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=108) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1080000058));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=109) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1090000059));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=110) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1100000060));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=111) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1110000061));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=112) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1120000062));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=113) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1130000063));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=114) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1140000064));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=115) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1150000065));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=116) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1160000066));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=117) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1170000067));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=118) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1180000068));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=119) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1190000069));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=120) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1200000070));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=121) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1210000071));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=122) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1220000072));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=123) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1230000073));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=124) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1240000074));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=125) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1250000075));   

--75

INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=101) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1010000076));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=102) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1020000077));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=103) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1030000078));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=104) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1040000079));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=105) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1050000080));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=106) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1060000081));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=107) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1070000082));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=108) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1080000083));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=109) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1090000084));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=110) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1100000085));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=111) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1110000086));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=112) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1120000087));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=113) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1130000088));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=114) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1140000089));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=115) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1150000090));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=116) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1160000091));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=117) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1170000092));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=118) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1180000093));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=119) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1190000094));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=120) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1200000095));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=121) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1210000096));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=122) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1220000097));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=123) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1230000098));   

--98

INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=123) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1230000099));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=123) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1230000100));   

--100


INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=101) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1010000101));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=102) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1020000102));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=103) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1030000103));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=104) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1040000104));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=105) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1050000105));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=106) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1060000106));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=107) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1070000107));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=108) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1080000108));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=109) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1090000109));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=110) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1100000110));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=111) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1110000111));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=112) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1120000112));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=113) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1130000113));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=114) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1140000114));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=115) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1150000115));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=116) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1160000116));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=117) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1170000117));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=118) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1180000118));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=119) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1190000119));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=120) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1200000120));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=121) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1210000121));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=122) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1220000122));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=123) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1230000123));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=124) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1240000124));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=125) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1250000125));   

--125

INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=101) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1010000126));
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=120) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1200000127));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=128) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1100000128));
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=108) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1080000129));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=101) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1010000130));
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=102) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1020000131));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=103) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1030000132));
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=120) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1200000133));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=121) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1210000134));
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=123) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1230000135));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=124) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1240000136));
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=108) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1080000137));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=109) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1090000138));
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=110) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1100000139));   
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=111) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1110005564));
INSERT INTO TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.numAgence=118) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1180005564));   

--141






COMMIT;


-- Verification !

SELECT COUNT(*) FROM TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.NumAgence=101);
SELECT COUNT(*) FROM TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.NumAgence=102);
SELECT COUNT(*) FROM TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.NumAgence=103);
SELECT COUNT(*) FROM TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.NumAgence=104);
SELECT COUNT(*) FROM TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.NumAgence=105);

SELECT COUNT(*) FROM TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.NumAgence=106);
SELECT COUNT(*) FROM TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.NumAgence=107);
SELECT COUNT(*) FROM TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.NumAgence=108);
SELECT COUNT(*) FROM TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.NumAgence=109);
SELECT COUNT(*) FROM TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.NumAgence=110);

SELECT COUNT(*) FROM TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.NumAgence=111);
SELECT COUNT(*) FROM TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.NumAgence=112);
SELECT COUNT(*) FROM TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.NumAgence=113);
SELECT COUNT(*) FROM TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.NumAgence=114);
SELECT COUNT(*) FROM TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.NumAgence=115);

SELECT COUNT(*) FROM TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.NumAgence=116);
SELECT COUNT(*) FROM TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.NumAgence=117);
SELECT COUNT(*) FROM TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.NumAgence=118);
SELECT COUNT(*) FROM TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.NumAgence=119);
SELECT COUNT(*) FROM TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.NumAgence=120);

SELECT COUNT(*) FROM TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.NumAgence=121);
SELECT COUNT(*) FROM TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.NumAgence=122);
SELECT COUNT(*) FROM TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.NumAgence=123);
SELECT COUNT(*) FROM TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.NumAgence=124);
SELECT COUNT(*) FROM TABLE (SELECT s.Agence_Compte FROM Agence s WHERE s.NumAgence=125);








/*Client_Compte*/

INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10001) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1010000001));   

INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10002) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1020000002));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10001) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1030000003));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10003) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1040000004));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10002) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1050000005));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10003) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1060000006));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10001) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1070000007));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10004) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1080000008));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10002) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1090000009));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10004) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1100000010));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10003) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1110000011));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10004) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1120000012));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10001) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1130000013));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10005) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1140000014));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10002) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1150000015));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10005) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1160000016));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10003) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1170000017));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10005) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1180000018));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10001) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1190000019));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10006) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1200000020));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10002) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1210000021));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10006) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1220000022));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10003) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1230000023));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10006) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1240000024));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10004) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1250000025));   

--25--

INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10006) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1010000026));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10005) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1020000027));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10006) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1030000028));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10001) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1040000029));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10007) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1050000030));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10002) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1060000031));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10007) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1070000032));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10003) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1080000033));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10007) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1090000034));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10004) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1100000035));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10007) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1110000036));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10005) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1120000037));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10007) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1130000038));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10006) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1140000039));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10007) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1150000040));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10001) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1160000041));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10008) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1170000042));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10002) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1180000043));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10008) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1190000044));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10003) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1200000045));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10008) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1210000046));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10004) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1220000047));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10008) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1230000048));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10005) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1240000049));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10008) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1250000050));   

--50

INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10006) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1010000051));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10008) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1020000052));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10001) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1030000053));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10009) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1040000054));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10002) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1050000055));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10009) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1060000056));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10003) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1070000057));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10009) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1080000058));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10004) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1090000059));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10009) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1100000060));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10005) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1110000061));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10009) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1120000062));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10006) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1130000063));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10009) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1140000064));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10007) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1150000065));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10009) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1160000066));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10008) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1170000067));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10009) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1180000068));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10009) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1190000069));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10010) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1200000070));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10009) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1210000071));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10011) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1220000072));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10009) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1230000073));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10012) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1240000074));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10010) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1250000075));   

--75

INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10012) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1010000076));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10011) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1020000077));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10012) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1030000078));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10011) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1040000079));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10013) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1050000080));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10011) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1060000081));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10014) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1070000082));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10011) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1080000083));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10015) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1090000084));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10011) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1100000085));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10016) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1110000086));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10017) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1120000087));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10018) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1130000088));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10019) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1140000089));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10020) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1150000090));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10021) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1160000091));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10022) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1170000092));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10023) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1180000093));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10024) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1190000094));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10025) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1200000095));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10026) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1210000096));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10027) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1220000097));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10028) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1230000098));   

--98

INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10027) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1230000099));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10028) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1230000100));   

--100


INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10031) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1010000101));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10032) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1020000102));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10033) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1030000103));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10034) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1040000104));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10035) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1050000105));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10036) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1060000106));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10037) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1070000107));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10038) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1080000108));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10039) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1090000109));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10040) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1100000110));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10041) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1110000111));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10042) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1120000112));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10043) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1130000113));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10044) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1140000114));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10045) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1150000115));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10046) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1160000116));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10047) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1170000117));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10048) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1180000118));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10049) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1190000119));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10050) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1200000120));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10050) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1210000121));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10050) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1220000122));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10048) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1230000123));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10048) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1240000124));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10048) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1250000125));   

--125

INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10032) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1010000126));
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10032) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1200000127));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10032) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1100000128));
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10032) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1080000129));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10041) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1010000130));
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10041) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1020000131));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10041) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1030000132));
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10042) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1200000133));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10042) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1210000134));
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10042) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1230000135));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10042) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1240000136));
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10037) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1080000137));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10037) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1090000138));
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=100037) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1100000139));   
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10037) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1110005564));
INSERT INTO TABLE (SELECT s.Client_Compte FROM Client s WHERE s.numClient=10004) VALUES ((SELECT REF(c) FROM Compte c WHERE c.NumCompte=1180005564));   

--141

COMMIT;

-- Verification !
--exemple : Client 10037

SELECT COUNT(*) FROM TABLE (SELECT s.Client_Compte FROM Client s WHERE s.NumClient=10037);










/*Compte_Pret*/

INSERT INTO TABLE (SELECT s.Compte_Pret FROM Compte s WHERE s.numCompte=1010000001) VALUES ((SELECT REF(c) FROM Pret c WHERE c.NumPret=1));   
INSERT INTO TABLE (SELECT s.Compte_Pret FROM Compte s WHERE s.numCompte=1020000002) VALUES ((SELECT REF(c) FROM Pret c WHERE c.NumPret=2));   
INSERT INTO TABLE (SELECT s.Compte_Pret FROM Compte s WHERE s.numCompte=1040000004) VALUES ((SELECT REF(c) FROM Pret c WHERE c.NumPret=3));   
INSERT INTO TABLE (SELECT s.Compte_Pret FROM Compte s WHERE s.numCompte=1100000010) VALUES ((SELECT REF(c) FROM Pret c WHERE c.NumPret=4));   
INSERT INTO TABLE (SELECT s.Compte_Pret FROM Compte s WHERE s.numCompte=1160000016) VALUES ((SELECT REF(c) FROM Pret c WHERE c.NumPret=5));   
INSERT INTO TABLE (SELECT s.Compte_Pret FROM Compte s WHERE s.numCompte=1200000020) VALUES ((SELECT REF(c) FROM Pret c WHERE c.NumPret=6));   
INSERT INTO TABLE (SELECT s.Compte_Pret FROM Compte s WHERE s.numCompte=1050000030) VALUES ((SELECT REF(c) FROM Pret c WHERE c.NumPret=7));   
INSERT INTO TABLE (SELECT s.Compte_Pret FROM Compte s WHERE s.numCompte=1190000044) VALUES ((SELECT REF(c) FROM Pret c WHERE c.NumPret=8));   
INSERT INTO TABLE (SELECT s.Compte_Pret FROM Compte s WHERE s.numCompte=1040000054) VALUES ((SELECT REF(c) FROM Pret c WHERE c.NumPret=9));   
INSERT INTO TABLE (SELECT s.Compte_Pret FROM Compte s WHERE s.numCompte=1200000070) VALUES ((SELECT REF(c) FROM Pret c WHERE c.NumPret=10)); 

INSERT INTO TABLE (SELECT s.Compte_Pret FROM Compte s WHERE s.numCompte=1220000072) VALUES ((SELECT REF(c) FROM Pret c WHERE c.NumPret=11));   
INSERT INTO TABLE (SELECT s.Compte_Pret FROM Compte s WHERE s.numCompte=1240000074) VALUES ((SELECT REF(c) FROM Pret c WHERE c.NumPret=12));   
INSERT INTO TABLE (SELECT s.Compte_Pret FROM Compte s WHERE s.numCompte=1050000080) VALUES ((SELECT REF(c) FROM Pret c WHERE c.NumPret=13));   
INSERT INTO TABLE (SELECT s.Compte_Pret FROM Compte s WHERE s.numCompte=1070000082) VALUES ((SELECT REF(c) FROM Pret c WHERE c.NumPret=14));   
INSERT INTO TABLE (SELECT s.Compte_Pret FROM Compte s WHERE s.numCompte=1090000084) VALUES ((SELECT REF(c) FROM Pret c WHERE c.NumPret=15));   
INSERT INTO TABLE (SELECT s.Compte_Pret FROM Compte s WHERE s.numCompte=1110000086) VALUES ((SELECT REF(c) FROM Pret c WHERE c.NumPret=16));   
INSERT INTO TABLE (SELECT s.Compte_Pret FROM Compte s WHERE s.numCompte=1120000087) VALUES ((SELECT REF(c) FROM Pret c WHERE c.NumPret=17));   
INSERT INTO TABLE (SELECT s.Compte_Pret FROM Compte s WHERE s.numCompte=1130000088) VALUES ((SELECT REF(c) FROM Pret c WHERE c.NumPret=18));   
INSERT INTO TABLE (SELECT s.Compte_Pret FROM Compte s WHERE s.numCompte=1140000089) VALUES ((SELECT REF(c) FROM Pret c WHERE c.NumPret=19));   
INSERT INTO TABLE (SELECT s.Compte_Pret FROM Compte s WHERE s.numCompte=1150000090) VALUES ((SELECT REF(c) FROM Pret c WHERE c.NumPret=20)); 

INSERT INTO TABLE (SELECT s.Compte_Pret FROM Compte s WHERE s.numCompte=1160000091) VALUES ((SELECT REF(c) FROM Pret c WHERE c.NumPret=21));
INSERT INTO TABLE (SELECT s.Compte_Pret FROM Compte s WHERE s.numCompte=1170000092) VALUES ((SELECT REF(c) FROM Pret c WHERE c.NumPret=22));   
INSERT INTO TABLE (SELECT s.Compte_Pret FROM Compte s WHERE s.numCompte=1180000093) VALUES ((SELECT REF(c) FROM Pret c WHERE c.NumPret=23));   
INSERT INTO TABLE (SELECT s.Compte_Pret FROM Compte s WHERE s.numCompte=1190000094) VALUES ((SELECT REF(c) FROM Pret c WHERE c.NumPret=24));   
INSERT INTO TABLE (SELECT s.Compte_Pret FROM Compte s WHERE s.numCompte=1200000095) VALUES ((SELECT REF(c) FROM Pret c WHERE c.NumPret=25));   
INSERT INTO TABLE (SELECT s.Compte_Pret FROM Compte s WHERE s.numCompte=1210000096) VALUES ((SELECT REF(c) FROM Pret c WHERE c.NumPret=26));   
INSERT INTO TABLE (SELECT s.Compte_Pret FROM Compte s WHERE s.numCompte=1220000097) VALUES ((SELECT REF(c) FROM Pret c WHERE c.NumPret=27));   
INSERT INTO TABLE (SELECT s.Compte_Pret FROM Compte s WHERE s.numCompte=1230000100) VALUES ((SELECT REF(c) FROM Pret c WHERE c.NumPret=28));   
INSERT INTO TABLE (SELECT s.Compte_Pret FROM Compte s WHERE s.numCompte=1010000101) VALUES ((SELECT REF(c) FROM Pret c WHERE c.NumPret=29));   
INSERT INTO TABLE (SELECT s.Compte_Pret FROM Compte s WHERE s.numCompte=1020000102) VALUES ((SELECT REF(c) FROM Pret c WHERE c.NumPret=30)); 

INSERT INTO TABLE (SELECT s.Compte_Pret FROM Compte s WHERE s.numCompte=1030000103) VALUES ((SELECT REF(c) FROM Pret c WHERE c.NumPret=31));   
INSERT INTO TABLE (SELECT s.Compte_Pret FROM Compte s WHERE s.numCompte=1040000104) VALUES ((SELECT REF(c) FROM Pret c WHERE c.NumPret=32));   
INSERT INTO TABLE (SELECT s.Compte_Pret FROM Compte s WHERE s.numCompte=1050000105) VALUES ((SELECT REF(c) FROM Pret c WHERE c.NumPret=33));   
INSERT INTO TABLE (SELECT s.Compte_Pret FROM Compte s WHERE s.numCompte=1060000106) VALUES ((SELECT REF(c) FROM Pret c WHERE c.NumPret=34));   
INSERT INTO TABLE (SELECT s.Compte_Pret FROM Compte s WHERE s.numCompte=1070000107) VALUES ((SELECT REF(c) FROM Pret c WHERE c.NumPret=35));   
INSERT INTO TABLE (SELECT s.Compte_Pret FROM Compte s WHERE s.numCompte=1080000108) VALUES ((SELECT REF(c) FROM Pret c WHERE c.NumPret=36));   
INSERT INTO TABLE (SELECT s.Compte_Pret FROM Compte s WHERE s.numCompte=1090000109) VALUES ((SELECT REF(c) FROM Pret c WHERE c.NumPret=37));   
INSERT INTO TABLE (SELECT s.Compte_Pret FROM Compte s WHERE s.numCompte=1100000110) VALUES ((SELECT REF(c) FROM Pret c WHERE c.NumPret=38));   
INSERT INTO TABLE (SELECT s.Compte_Pret FROM Compte s WHERE s.numCompte=1200000120) VALUES ((SELECT REF(c) FROM Pret c WHERE c.NumPret=39));   
INSERT INTO TABLE (SELECT s.Compte_Pret FROM Compte s WHERE s.numCompte=1180005564) VALUES ((SELECT REF(c) FROM Pret c WHERE c.NumPret=40)); 
INSERT INTO TABLE (SELECT s.Compte_Pret FROM Compte s WHERE s.numCompte=1110005564) VALUES ((SELECT REF(c) FROM Pret c WHERE c.NumPret=41)); 

COMMIT;


DELETE FROM TABLE (SELECT s.Compte_Pret FROM Compte s WHERE s.NumCompte=1110005564);






/*Compte_Operation*/

INSERT INTO TABLE (SELECT s.Compte_Operation FROM Compte s WHERE s.NumCompte=1110000111) VALUES ((SELECT REF(c) FROM Operation c WHERE c.NumOperation=1));   
INSERT INTO TABLE (SELECT s.Compte_Operation FROM Compte s WHERE s.NumCompte=1110000111) VALUES ((SELECT REF(c) FROM Operation c WHERE c.NumOperation=2));   
INSERT INTO TABLE (SELECT s.Compte_Operation FROM Compte s WHERE s.NumCompte=1120000112) VALUES ((SELECT REF(c) FROM Operation c WHERE c.NumOperation=3));   
INSERT INTO TABLE (SELECT s.Compte_Operation FROM Compte s WHERE s.NumCompte=1130000113) VALUES ((SELECT REF(c) FROM Operation c WHERE c.NumOperation=4));   
INSERT INTO TABLE (SELECT s.Compte_Operation FROM Compte s WHERE s.NumCompte=1140000114) VALUES ((SELECT REF(c) FROM Operation c WHERE c.NumOperation=5));   
INSERT INTO TABLE (SELECT s.Compte_Operation FROM Compte s WHERE s.NumCompte=1150000115) VALUES ((SELECT REF(c) FROM Operation c WHERE c.NumOperation=6));   
INSERT INTO TABLE (SELECT s.Compte_Operation FROM Compte s WHERE s.NumCompte=1160000116) VALUES ((SELECT REF(c) FROM Operation c WHERE c.NumOperation=7));   
INSERT INTO TABLE (SELECT s.Compte_Operation FROM Compte s WHERE s.NumCompte=1170000117) VALUES ((SELECT REF(c) FROM Operation c WHERE c.NumOperation=8));   
INSERT INTO TABLE (SELECT s.Compte_Operation FROM Compte s WHERE s.NumCompte=1180000118) VALUES ((SELECT REF(c) FROM Operation c WHERE c.NumOperation=9));   
INSERT INTO TABLE (SELECT s.Compte_Operation FROM Compte s WHERE s.NumCompte=1190000119) VALUES ((SELECT REF(c) FROM Operation c WHERE c.NumOperation=10)); 

INSERT INTO TABLE (SELECT s.Compte_Operation FROM Compte s WHERE s.NumCompte=1200000120) VALUES ((SELECT REF(c) FROM Operation c WHERE c.NumOperation=11));   
INSERT INTO TABLE (SELECT s.Compte_Operation FROM Compte s WHERE s.NumCompte=1210000121) VALUES ((SELECT REF(c) FROM Operation c WHERE c.NumOperation=12));   
INSERT INTO TABLE (SELECT s.Compte_Operation FROM Compte s WHERE s.NumCompte=1220000122) VALUES ((SELECT REF(c) FROM Operation c WHERE c.NumOperation=13));   
INSERT INTO TABLE (SELECT s.Compte_Operation FROM Compte s WHERE s.NumCompte=1230000123) VALUES ((SELECT REF(c) FROM Operation c WHERE c.NumOperation=14));   
INSERT INTO TABLE (SELECT s.Compte_Operation FROM Compte s WHERE s.NumCompte=1240000124) VALUES ((SELECT REF(c) FROM Operation c WHERE c.NumOperation=15));   
INSERT INTO TABLE (SELECT s.Compte_Operation FROM Compte s WHERE s.NumCompte=1250000125) VALUES ((SELECT REF(c) FROM Operation c WHERE c.NumOperation=16));   
INSERT INTO TABLE (SELECT s.Compte_Operation FROM Compte s WHERE s.NumCompte=1010000126) VALUES ((SELECT REF(c) FROM Operation c WHERE c.NumOperation=17));   
INSERT INTO TABLE (SELECT s.Compte_Operation FROM Compte s WHERE s.NumCompte=1200000127) VALUES ((SELECT REF(c) FROM Operation c WHERE c.NumOperation=18));   
INSERT INTO TABLE (SELECT s.Compte_Operation FROM Compte s WHERE s.NumCompte=1100000128) VALUES ((SELECT REF(c) FROM Operation c WHERE c.NumOperation=19));   
INSERT INTO TABLE (SELECT s.Compte_Operation FROM Compte s WHERE s.NumCompte=1080000129) VALUES ((SELECT REF(c) FROM Operation c WHERE c.NumOperation=20)); 

INSERT INTO TABLE (SELECT s.Compte_Operation FROM Compte s WHERE s.NumCompte=1110000111) VALUES ((SELECT REF(c) FROM Operation c WHERE c.NumOperation=21));   
INSERT INTO TABLE (SELECT s.Compte_Operation FROM Compte s WHERE s.NumCompte=1110000111) VALUES ((SELECT REF(c) FROM Operation c WHERE c.NumOperation=22));   
INSERT INTO TABLE (SELECT s.Compte_Operation FROM Compte s WHERE s.NumCompte=1120000112) VALUES ((SELECT REF(c) FROM Operation c WHERE c.NumOperation=23));   
INSERT INTO TABLE (SELECT s.Compte_Operation FROM Compte s WHERE s.NumCompte=1130000113) VALUES ((SELECT REF(c) FROM Operation c WHERE c.NumOperation=24));   
INSERT INTO TABLE (SELECT s.Compte_Operation FROM Compte s WHERE s.NumCompte=1140000114) VALUES ((SELECT REF(c) FROM Operation c WHERE c.NumOperation=25));   
INSERT INTO TABLE (SELECT s.Compte_Operation FROM Compte s WHERE s.NumCompte=1150000115) VALUES ((SELECT REF(c) FROM Operation c WHERE c.NumOperation=26));   
INSERT INTO TABLE (SELECT s.Compte_Operation FROM Compte s WHERE s.NumCompte=1160000116) VALUES ((SELECT REF(c) FROM Operation c WHERE c.NumOperation=27));   
INSERT INTO TABLE (SELECT s.Compte_Operation FROM Compte s WHERE s.NumCompte=1170000117) VALUES ((SELECT REF(c) FROM Operation c WHERE c.NumOperation=28));   
INSERT INTO TABLE (SELECT s.Compte_Operation FROM Compte s WHERE s.NumCompte=1180000118) VALUES ((SELECT REF(c) FROM Operation c WHERE c.NumOperation=29));   
INSERT INTO TABLE (SELECT s.Compte_Operation FROM Compte s WHERE s.NumCompte=1190000119) VALUES ((SELECT REF(c) FROM Operation c WHERE c.NumOperation=30)); 

INSERT INTO TABLE (SELECT s.Compte_Operation FROM Compte s WHERE s.NumCompte=1200000120) VALUES ((SELECT REF(c) FROM Operation c WHERE c.NumOperation=31));   
INSERT INTO TABLE (SELECT s.Compte_Operation FROM Compte s WHERE s.NumCompte=1210000121) VALUES ((SELECT REF(c) FROM Operation c WHERE c.NumOperation=32));   
INSERT INTO TABLE (SELECT s.Compte_Operation FROM Compte s WHERE s.NumCompte=1220000122) VALUES ((SELECT REF(c) FROM Operation c WHERE c.NumOperation=33));   
INSERT INTO TABLE (SELECT s.Compte_Operation FROM Compte s WHERE s.NumCompte=1230000123) VALUES ((SELECT REF(c) FROM Operation c WHERE c.NumOperation=34));   
INSERT INTO TABLE (SELECT s.Compte_Operation FROM Compte s WHERE s.NumCompte=1240000124) VALUES ((SELECT REF(c) FROM Operation c WHERE c.NumOperation=35));   
INSERT INTO TABLE (SELECT s.Compte_Operation FROM Compte s WHERE s.NumCompte=1250000125) VALUES ((SELECT REF(c) FROM Operation c WHERE c.NumOperation=36));   
INSERT INTO TABLE (SELECT s.Compte_Operation FROM Compte s WHERE s.NumCompte=1010000126) VALUES ((SELECT REF(c) FROM Operation c WHERE c.NumOperation=37));   
INSERT INTO TABLE (SELECT s.Compte_Operation FROM Compte s WHERE s.NumCompte=1200000127) VALUES ((SELECT REF(c) FROM Operation c WHERE c.NumOperation=38));   
INSERT INTO TABLE (SELECT s.Compte_Operation FROM Compte s WHERE s.NumCompte=1100000128) VALUES ((SELECT REF(c) FROM Operation c WHERE c.NumOperation=39));   
INSERT INTO TABLE (SELECT s.Compte_Operation FROM Compte s WHERE s.NumCompte=1080000129) VALUES ((SELECT REF(c) FROM Operation c WHERE c.NumOperation=40)); 

INSERT INTO TABLE (SELECT s.Compte_Operation FROM Compte s WHERE s.NumCompte=1030000103) VALUES ((SELECT REF(c) FROM Operation c WHERE c.NumOperation=41)); 
INSERT INTO TABLE (SELECT s.Compte_Operation FROM Compte s WHERE s.NumCompte=1040000104) VALUES ((SELECT REF(c) FROM Operation c WHERE c.NumOperation=42)); 
INSERT INTO TABLE (SELECT s.Compte_Operation FROM Compte s WHERE s.NumCompte=1080000108) VALUES ((SELECT REF(c) FROM Operation c WHERE c.NumOperation=43)); 
INSERT INTO TABLE (SELECT s.Compte_Operation FROM Compte s WHERE s.NumCompte=1180005564) VALUES ((SELECT REF(c) FROM Operation c WHERE c.NumOperation=44)); 
INSERT INTO TABLE (SELECT s.Compte_Operation FROM Compte s WHERE s.NumCompte=1180005564) VALUES ((SELECT REF(c) FROM Operation c WHERE c.NumOperation=45)); 
INSERT INTO TABLE (SELECT s.Compte_Operation FROM Compte s WHERE s.NumCompte=1180005564) VALUES ((SELECT REF(c) FROM Operation c WHERE c.NumOperation=46)); 
INSERT INTO TABLE (SELECT s.Compte_Operation FROM Compte s WHERE s.NumCompte=1080000108) VALUES ((SELECT REF(c) FROM Operation c WHERE c.NumOperation=47)); 
INSERT INTO TABLE (SELECT s.Compte_Operation FROM Compte s WHERE s.NumCompte=1200000070) VALUES ((SELECT REF(c) FROM Operation c WHERE c.NumOperation=48)); 
INSERT INTO TABLE (SELECT s.Compte_Operation FROM Compte s WHERE s.NumCompte=1040000004) VALUES ((SELECT REF(c) FROM Operation c WHERE c.NumOperation=49)); 
INSERT INTO TABLE (SELECT s.Compte_Operation FROM Compte s WHERE s.NumCompte=1100000010) VALUES ((SELECT REF(c) FROM Operation c WHERE c.NumOperation=50)); 


COMMIT;





/*      	Langage d’Interrogation de Données      */

/*9. Lister tous les comptes d’une agence donnée, dont les propriétaires sont des entreprises.*/

select deref(value (c)).NumCompte
FROM Agence a, table(a.Agence_Compte) c
WHERE a.NumAgence = 101;



/*10. Lister les prêts effectués auprès des agences rattachées à une succursale donnée 
(numSuccursale = 005). Préciser NumPrêt, NumAgence, numCompte et MontantPrêt)*/

SELECT deref(value(p)).NumPret, deref(value(a)).NumAgence, deref(value (c)).NumCompte, deref(value(p)).montantpret
FROM Succursale s, table(s.Succursale_Agence) a, table(deref(value(a)).Agence_Compte) c, table(deref(value(c)).Compte_Pret) p
WHERE s.NumSucc = 005;



/*11. Quels sont les comptes sur lesquels 
aucune opération de débit n’a été effectuée 
entre 2000 et 2022 ?*/

SELECT c.NumCompte
FROM Compte c
WHERE NOT EXISTS 
(
    SELECT *
    FROM table (c.Compte_Operation) o
    WHERE value(o).NatureOp = 'Debit'
    AND value(o).DateOp BETWEEN '01/01/2000' AND '31/12/2022'
);



/*12. Quel est le montant total des crédits effectués sur un compte 
(numCompte = 1180005564) en 2023 ?*/

SELECT SUM(deref(value(o)).MontantOp) 
FROM Compte c, TABLE (c.Compte_Operation) o
WHERE NumCompte = 1180005564
AND value(o).NatureOp = 'Credit'
AND value(o).DateOp BETWEEN '01/01/2023' AND '01/01/2024';



/*13. Quels sont les prêts non encore soldés à ce jour ? 
Préciser NumPrêt, NumAgence, numCompte, numClient et MontantPrêt)*/

SELECT deref(value(p)).NumPret, 
       a.NumAgence,
       deref(value(c)).NumCompte,
       l.NumClient,
       l.NomClient,
       deref(value(p)).MontantPret
FROM Agence a, 
     Client l,
     TABLE(a.Agence_Compte) c,
     TABLE(deref(value(c)).Compte_Pret) p,
     TABLE(l.Client_Compte) x
WHERE value(x).NumCompte = value(c).NumCompte
AND value(p).MontantEcheance <> 0;



/*14. Quel est le compte le plus mouvementé en 2023 ? 
(Max d’opérations de débit/crédit)*/

SELECT NumCompte
FROM (
    SELECT NumCompte,
           COUNT(*) AS Nombre_Op,
           RANK() OVER (ORDER BY COUNT(*) DESC) AS Classement
    FROM (
        SELECT c.NumCompte
        FROM Compte c, TABLE(c.Compte_Operation) o
        WHERE value(o).DateOp BETWEEN '01/01/2023' AND '01/01/2024'
    )
    GROUP BY NumCompte
)
WHERE Classement = 1;


