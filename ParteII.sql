--Parte II, punto 4
--Script SQL per la creazione dello schema logico della base di dati in accordo allo schema relazionale ottenuto
--alla fine della fase di progettazione logica, per la porzione necessaria per i punti successivi (cioè le tabelle
--coinvolte dalle interrogazioni nel carico di lavoro, nella definizione della vista, nelle interrogazioni, in funzioni,
--procedure e trigger). Lo schema dovrà essere comprensivo dei vincoli esprimibili con check, e per il popolamento
--di tale base di dati.

create schema ortiscolastici;
set search_path to ortiscolastici;

CREATE TABLE Scuola(  
	CodiceMeccanografico char(10) CHECK (CodiceMeccanografico ~ '^[A-Z0-9]+$'), 
	NomeIstituto varchar(47) CHECK (NomeIstituto ~ '^[A-Za-z]+$') NOT NULL, --numero di caratteri ottenuto ricercando su internet 
	Provincia char(2) CHECK (Provincia ~ '^[A-Z]+$') NOT NULL, --sigla 
	CicloIstruzione varchar(7) CHECK (CicloIstruzione IN('Primo','Secondo')) NOT NULL,	--numero  caratteri per 'secondo' 
	TipoFinanziamento varchar(110), --numero di caratteri ottenuto ricercando su internet  
	PRIMARY KEY (CodiceMeccanografico) 
);
CREATE TABLE Persona( 
	Email varchar(320), --numero preso da ricerca su internet (64 caratteri prima + @ + 255 caratteri dopo)
	Cognome varchar(50) CHECK (Cognome ~ '^[A-Za-z]+$')  NOT NULL,	
	Nome varchar(50) CHECK (Nome ~ '^[A-Za-z]+$')  NOT NULL,
	Ruolo varchar(38) CHECK (Ruolo ~ '^[A-Za-z]+$') NOT NULL, --numero preso da ricerca su internet
	NumeroTelefono char(10) CHECK (NumeroTelefono ~ '^[0-9]+$'),
	ReferenteIniziativa boolean,
	Coinvolta char(10),
	PRIMARY KEY (Email),
	FOREIGN KEY (Coinvolta) REFERENCES Scuola ON UPDATE CASCADE,
	UNIQUE (Nome, Cognome, NumeroTelefono)
);
CREATE TABLE Classe(    
	Anno char CHECK (Anno IN ('1','2','3','4','5')),
	Sezione varchar(5) CHECK (Sezione ~ '^[A-Z]+$'),
	CodiceMecc char(10),
	Ordine varchar(25) CHECK (Ordine IN ('Primaria','Secondaria di primo grado')),	--primaria, secondaria di primo grado
	TipoScuola varchar(52), --numero trovato per ricerca
	EmailDocente varchar(320) NOT NULL,
	PRIMARY KEY(Anno, Sezione, CodiceMecc),
	FOREIGN KEY(EmailDocente) REFERENCES Persona ON UPDATE CASCADE,
	FOREIGN KEY(CodiceMecc) REFERENCES Scuola ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE Orto( 
	Nome varchar(25),
	CodiceMecc char(10),
	Tipo varchar(14)  CHECK (Tipo IN('In pieno campo','In vaso')) NOT NULL,
	GPS varchar(25) NOT NULL,
	Superficie numeric (5, 1) CHECK(Superficie >= 0) NOT NULL,
	Condizioni varchar(10) CHECK(Condizioni IN('Pulito','Non pulito')) NOT NULL,
	DisponibilitàCollab boolean NOT NULL,
	NumeroSensori smallint CHECK(NumeroSensori >= 0) NOT NULL,
	Attività varchar(15) CHECK(Attività IN('Biomonitoraggio','Fitobonifica')) NOT NULL,
	PRIMARY KEY(Nome, CodiceMecc),
	FOREIGN KEY(CodiceMecc) REFERENCES Scuola ON DELETE CASCADE ON UPDATE CASCADE
); 
CREATE TABLE Specie(  
	NomeScientifico varchar(50) CHECK(NomeScientifico ~ '^[A-Za-z]+$'),  
	NomeComune varchar(25) CHECK(NomeComune ~ '^[A-Za-z]+$') NOT NULL, 
	Esposizione varchar(14) CHECK(Esposizione IN('Sole','Ombra','Sole/mezzombra','Mezzombra/sole')),
	PRIMARY KEY(NomeScientifico) 
); 

CREATE TABLE Gruppo( 
	ID serial,
	Tipo varchar(12) CHECK (Tipo IN ('Controllo','Monitoraggio')), --NULL perché non vale se è fitobonifica
	Dislocazione int,
	PRIMARY KEY(ID),
	FOREIGN KEY(Dislocazione) REFERENCES Gruppo
);
CREATE TABLE Pianta(
	ID serial,
	NumeroReplica smallint CHECK(NumeroReplica > 0) NOT NULL,
	Data date NOT NULL,
	EsposizioneSpec varchar(14) CHECK(EsposizioneSpec IN('Sole','Ombra','Sole/mezzombra','Mezzombra/sole')) NOT NULL,
	NomeScientifico varchar(50),
	Nome varchar(25) NOT NULL,
	ScuolaDiRiferimento char(10) NOT NULL,
	ScuolaDiAppartenenza char(10) NOT NULL,
	Anno char NOT NULL,
	Sezione varchar(5) NOT NULL,
	IDg int NOT NULL,
	PRIMARY KEY(ID, NumeroReplica),
	FOREIGN KEY(NomeScientifico) REFERENCES Specie ON UPDATE CASCADE,
	FOREIGN KEY(Nome, ScuolaDiRiferimento) REFERENCES Orto ON UPDATE CASCADE,
	FOREIGN KEY(Anno, Sezione, ScuolaDiAppartenenza) REFERENCES Classe(Anno, Sezione, CodiceMecc) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY(IDg) REFERENCES Gruppo ON UPDATE CASCADE
);
CREATE TABLE RaccoltaDati(
	DataOraRilevazione timestamp,
	ID int,
	NumeroReplica smallint,
	DataOraInserimento timestamp NOT NULL,
	LarghezzaChiomaFoglie_cm numeric(5,2) CHECK(LarghezzaChiomaFoglie_cm >= 0) NOT NULL,
	LunghezzaChiomaFoglie_cm numeric(5,2) CHECK(LunghezzaChiomaFoglie_cm >= 0) NOT NULL,
	PesoFrescoChiomaFoglie_g numeric(5,2) CHECK(PesoFrescoChiomaFoglie_g >= 0),
	PesoSeccoChiomaFoglie_g numeric(5,2) CHECK(PesoSeccoChiomaFoglie_g >= 0),
	AltezzaPianta_cm numeric(5,2) CHECK(AltezzaPianta_cm >= 0) NOT NULL,
	LunghezzaRadicei_cm numeric(5,2) CHECK(LunghezzaRadicei_cm >= 0),
	PesoFrescoRadici_g numeric(5,2) CHECK(PesoFrescoRadici_g >= 0),
	PesoSeccoRadici_g numeric(5,2) CHECK(PesoSeccoRadici_g >= 0),
	NumeroFiori smallint CHECK(NumeroFiori >= 0) NOT NULL,
	NumeroFrutti smallint CHECK(NumeroFrutti >= 0) NOT NULL,
	NumeroDiFoglieDanneggiate smallint CHECK(NumeroDiFoglieDanneggiate >= 0) NOT NULL,
	PercSuperficieDanneggiataPerFoglia numeric(5,2) CHECK(PercSuperficieDanneggiataPerFoglia >= 0 AND PercSuperficieDanneggiataPerFoglia <= 100) NOT NULL,
	pH numeric(3,1) CHECK (pH >= 0 AND pH <= 14) NOT NULL,
	Umidità numeric(5,2) CHECK(Umidità >= 0 AND Umidità <= 100) NOT NULL,
	Temperatura numeric(3,1) NOT NULL,
	EmailResponsabileRilev varchar(320),
	EmailResponsabileIns varchar(320),
	AnnoRil char,
	SezioneRil varchar(5),
	CodiceMeccRil char(10),
	AnnoIns char,
	SezioneIns varchar(5),
	CodiceMeccIns char(10),
	PRIMARY KEY(DataOraRilevazione, ID, NumeroReplica),
	FOREIGN KEY(ID, NumeroReplica) REFERENCES Pianta ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY(EmailResponsabileRilev) REFERENCES Persona ON UPDATE CASCADE, 
	FOREIGN KEY(EmailResponsabileIns) REFERENCES Persona ON UPDATE CASCADE,
	FOREIGN KEY(AnnoRil, SezioneRil, CodiceMeccRil) REFERENCES Classe ON UPDATE CASCADE,
	FOREIGN KEY(AnnoIns, SezioneIns, CodiceMeccIns) REFERENCES Classe ON UPDATE CASCADE
);
CREATE TABLE Dispositivo ( 
	  ID serial,
	  TipoDispositivo varchar(7) CHECK (TipoDispositivo IN('Sensore','Arduino')) NOT NULL,
	  DataOraRilevazione timestamp NOT NULL,
	  PiantaDiRiferimento int NOT NULL,
	  NumeroReplica smallint NOT NULL,
	  OrtoDoveRisiede varchar(25) NOT NULL,
	  ScuolaDiRiferimento char(10) NOT NULL,
	  PRIMARY KEY (ID),
	  FOREIGN KEY (DataOraRilevazione, PiantaDiRiferimento, NumeroReplica) REFERENCES RaccoltaDati ON UPDATE CASCADE,
	  FOREIGN KEY (OrtoDoveRisiede, ScuolaDiRiferimento) REFERENCES Orto ON UPDATE CASCADE ON DELETE CASCADE
);

--Trigger per l'implementazione dei vincoli di integrità
--Vincolo 1
CREATE OR REPLACE FUNCTION numero_biomonitoraggio() RETURNS trigger AS
$numero_biomonitoraggio$
	BEGIN
		IF EXISTS(
			SELECT *
			FROM Pianta JOIN Gruppo ON Pianta.IDg = Gruppo.ID NATURAL JOIN Orto 
			WHERE Orto.Attività = 'Biomonitoraggio' AND Gruppo.Tipo = 'Controllo'
			GROUP BY Gruppo.IDg
			HAVING COUNT(Pianta.ID) !=
				(SELECT COUNT(Pianta.ID)
				FROM Pianta JOIN Gruppo X ON Pianta.IDg = X.ID NATURAL JOIN Orto
				WHERE Orto.Attività = 'Biomonitoraggio' AND X.Tipo = 'Monitoraggio' AND X.Dislocazione = Gruppo.ID
				GROUP BY X.IDg)
		)
		THEN RAISE EXCEPTION 'Numero errato di repliche per il biomonitoraggio: il numero di repliche per il controllo deve essere uguale al numero di repliche per il monitoraggio!';
		END IF;
		RETURN NEW;
	END;
$numero_biomonitoraggio$ LANGUAGE plpgsql;
CREATE TRIGGER numero_biomonitoraggio
BEFORE INSERT OR UPDATE ON Pianta
FOR EACH ROW
EXECUTE PROCEDURE numero_biomonitoraggio();
--Vincolo 3: vedere PUNTO 8 - Trigger a
--Vincolo 4
CREATE OR REPLACE FUNCTION referente_docente() RETURNS trigger as
$referente_docente$
	BEGIN 
		IF(
			SELECT *
			FROM Classe        
			WHERE EmailDocente NOT IN (SELECT Email            
									   FROM Persona
									   WHERE Ruolo = 'Docente')
		)
		THEN RAISE EXCEPTION 'Il referente di ogni classe deve essere un docente';
		END IF;
		RETURN NEW;
	END;        
$referente_docente$ LANGUAGE plpgsql;
CREATE TRIGGER referente_docente
BEFORE INSERT OR UPDATE ON Classe
FOR EACH ROW
EXECUTE PROCEDURE referente_docente();
--Vincolo 5
CREATE OR REPLACE FUNCTION responsabili() RETURNS trigger as
$responsabili$
	BEGIN
		IF EXISTS(
			SELECT *
			FROM RaccoltaDati
			WHERE (EmailResponsabileRilev IS NULL AND (AnnoRil IS NULL OR SezioneRil IS NULL OR CodiceMeccRil IS NULL))
				OR (EmailResponsabileIns IS NULL AND (AnnoIns IS NULL OR SezioneIns IS NULL OR CodiceMeccIns IS NULL))
		)
		THEN RAISE EXCEPTION 'Bisogna inserire almeno un responsabile per rilevazione e un responsabile per inserimento.';
		ELSEIF EXISTS(
			SELECT *
			FROM RaccoltaDati
			WHERE (EmailResponsabileRilev IS NOT NULL AND (AnnoRil IS NOT NULL OR SezioneRil IS NOT NULL OR CodiceMeccRil IS NOT NULL))
				OR (EmailResponsabileIns IS NOT NULL AND (AnnoIns IS NOT NULL OR SezioneIns IS NOT NULL OR CodiceMeccIns IS NOT NULL))
		)
		THEN RAISE EXCEPTION 'Bisogna inserire massimo un responsabile per rilevazione e un responsabile per inserimento.';
		END IF;
		RETURN NEW;
	END;
$responsabili$ LANGUAGE plpgsql;
CREATE TRIGGER responsabili
BEFORE INSERT OR UPDATE ON RaccoltaDati
FOR EACH ROW
EXECUTE PROCEDURE responsabili();
--Vincolo 6
CREATE OR REPLACE FUNCTION data_rilevazione() RETURNS trigger AS
$data_rilevazione$
	BEGIN
		IF EXISTS(
			SELECT *
			FROM RaccoltaDati NATURAL JOIN Pianta 
			WHERE Pianta.ID = RaccoltaDati.ID AND DataOraRilevazione < Data
		) 
		THEN RAISE EXCEPTION 'Non è possibile effettuare una rilevazione prima della messa a dimora della pianta.';
		END IF;
		RETURN NEW;
	END;
$data_rilevazione$ LANGUAGE plpgsql;
CREATE TRIGGER data_rilevazione
BEFORE INSERT OR UPDATE ON RaccoltaDati
FOR EACH ROW
EXECUTE PROCEDURE data_rilevazione();
--Vincolo 7
CREATE OR REPLACE FUNCTION gruppo_specie() RETURNS trigger AS
$gruppo_specie$
	BEGIN
		IF EXISTS(
			SELECT *
			FROM Pianta P JOIN Gruppo on Pianta.IDg = Gruppo.ID
			WHERE Pianta.IDg = P.IDg AND Pianta.NomeScientifico != P.NomeScientifico
		)
		THEN RAISE EXCEPTION 'In uno stesso gruppo possiamo avere solo piante della stessa specie.';
		END IF;
		RETURN NEW;
	END;
$gruppo_specie$ LANGUAGE plpgsql;
CREATE TRIGGER gruppo_specie
BEFORE INSERT OR UPDATE ON Pianta
FOR EACH ROW
EXECUTE PROCEDURE gruppo_specie();
--Vincolo 9
CREATE OR REPLACE FUNCTION orto_controllo() RETURNS trigger AS
$orto_controllo$
	BEGIN
		IF EXISTS(
			SELECT *
			FROM Orto JOIN Pianta ON Orto.Nome = Pianta.Nome AND Orto.CodiceMecc = Pianta.ScuolaDiRiferimento JOIN Gruppo ON Pianta.IDg = Gruppo.ID
			WHERE Orto.Attività = 'Biomonitoraggio' AND (Condizioni = 'Non Pulito' OR Disponibilità = 'false') AND Gruppo.Tipo = 'Controllo'
		)
		THEN RAISE EXCEPTION 'Un orto può funzionare da controllo per il biomonitoraggio solo se è nel pulito e se è disponibile a collaborare.';
		END IF;
		RETURN NEW;
	END;
$orto_controllo$ LANGUAGE plpgsql;
CREATE TRIGGER orto_controllo
BEFORE INSERT OR UPDATE ON Gruppo
FOR EACH ROW
EXECUTE PROCEDURE orto_controllo();
--Vincolo 11
CREATE OR REPLACE FUNCTION ordine_classe() RETURNS trigger AS 
$ordine_classe$
	BEGIN
		IF EXISTS(
			SELECT *
			FROM Classe
			WHERE Ordine = 'Secondaria di primo grado' AND (Anno = '4' OR Anno = '5')
		)
		THEN RAISE EXCEPTION 'Anno non valido per ordine di scuola inserito.';
		END IF;
		RETURN NEW;
	END;
$ordine_classe$ LANGUAGE plpgsql;
CREATE TRIGGER ordine_classe
BEFORE INSERT OR UPDATE ON Classe
FOR EACH ROW
EXECUTE PROCEDURE ordine_classe();
--Vincolo 18
CREATE OR REPLACE FUNCTION ordine_tipo() RETURNS trigger AS
$ordine_tipo$
	BEGIN
		IF EXISTS(
			SELECT *
			FROM Classe
			WHERE (Ordine IS NULL AND Tipo IS NULL) OR (Ordine IS NOT NULL AND Tipo IS NOT NULL)
		)
		THEN RAISE EXCEPTION 'Ogni classe ha un tipo di scuola se e solo se è appartiene ad una secondaria di secondo grado; il tipo deve essere esplicito.';
		END IF;
		RETURN NEW;
	END;
$ordine_tipo$ LANGUAGE plpgsql;
CREATE TRIGGER ordine_tipo
BEFORE INSERT OR UPDATE ON Classe
FOR EACH ROW
EXECUTE PROCEDURE ordine_tipo();

--Script INSERT per il popolamento della base di dati 
set search_path to ortiscolastici;

INSERT INTO "ortiscolastici"."gruppo" ("id","tipo","dislocazione") VALUES (1,'Controllo',NULL);
INSERT INTO "ortiscolastici"."gruppo" ("id","tipo","dislocazione") VALUES (2,'Controllo',NULL);
INSERT INTO "ortiscolastici"."gruppo" ("id","tipo","dislocazione") VALUES (3,'Controllo',NULL);
INSERT INTO "ortiscolastici"."gruppo" ("id","tipo","dislocazione") VALUES (4,'Controllo',NULL);
INSERT INTO "ortiscolastici"."gruppo" ("id","tipo","dislocazione") VALUES (5,NULL,NULL);
INSERT INTO "ortiscolastici"."gruppo" ("id","tipo","dislocazione") VALUES (6,'Controllo',NULL);
INSERT INTO "ortiscolastici"."gruppo" ("id","tipo","dislocazione") VALUES (7,NULL,NULL);
INSERT INTO "ortiscolastici"."gruppo" ("id","tipo","dislocazione") VALUES (8,'Controllo',NULL);
INSERT INTO "ortiscolastici"."gruppo" ("id","tipo","dislocazione") VALUES (9,NULL,NULL);
INSERT INTO "ortiscolastici"."gruppo" ("id","tipo","dislocazione") VALUES (10,NULL,NULL);
INSERT INTO "ortiscolastici"."gruppo" ("id","tipo","dislocazione") VALUES (11,NULL,NULL);
INSERT INTO "ortiscolastici"."gruppo" ("id","tipo","dislocazione") VALUES (12,NULL,NULL);
INSERT INTO "ortiscolastici"."gruppo" ("id","tipo","dislocazione") VALUES (13,'Controllo',NULL);
INSERT INTO "ortiscolastici"."gruppo" ("id","tipo","dislocazione") VALUES (14,NULL,NULL);
INSERT INTO "ortiscolastici"."gruppo" ("id","tipo","dislocazione") VALUES (15,'Controllo',NULL);
INSERT INTO "ortiscolastici"."gruppo" ("id","tipo","dislocazione") VALUES (16,'Controllo',NULL);
INSERT INTO "ortiscolastici"."gruppo" ("id","tipo","dislocazione") VALUES (17,NULL,NULL);
INSERT INTO "ortiscolastici"."gruppo" ("id","tipo","dislocazione") VALUES (18,NULL,NULL);
INSERT INTO "ortiscolastici"."gruppo" ("id","tipo","dislocazione") VALUES (19,'Controllo',NULL);
INSERT INTO "ortiscolastici"."gruppo" ("id","tipo","dislocazione") VALUES (20,NULL,NULL);
INSERT INTO "ortiscolastici"."gruppo" ("id","tipo","dislocazione") VALUES (21,NULL,NULL);
INSERT INTO "ortiscolastici"."gruppo" ("id","tipo","dislocazione") VALUES (22,'Controllo',NULL);
INSERT INTO "ortiscolastici"."gruppo" ("id","tipo","dislocazione") VALUES (23,'Controllo',NULL);
INSERT INTO "ortiscolastici"."gruppo" ("id","tipo","dislocazione") VALUES (24,'Controllo',NULL);
INSERT INTO "ortiscolastici"."gruppo" ("id","tipo","dislocazione") VALUES (25,'Controllo',NULL);
INSERT INTO "ortiscolastici"."gruppo" ("id","tipo","dislocazione") VALUES (26,'Controllo',NULL);
INSERT INTO "ortiscolastici"."gruppo" ("id","tipo","dislocazione") VALUES (27,'Controllo',NULL);
INSERT INTO "ortiscolastici"."gruppo" ("id","tipo","dislocazione") VALUES (28,'Controllo',NULL);
INSERT INTO "ortiscolastici"."gruppo" ("id","tipo","dislocazione") VALUES (29,'Monitoraggio',NULL);
INSERT INTO "ortiscolastici"."gruppo" ("id","tipo","dislocazione") VALUES (30,'Controllo',NULL);
INSERT INTO "ortiscolastici"."gruppo" ("id","tipo","dislocazione") VALUES (31,'Controllo',NULL);
INSERT INTO "ortiscolastici"."gruppo" ("id","tipo","dislocazione") VALUES (32,NULL,NULL);
INSERT INTO "ortiscolastici"."gruppo" ("id","tipo","dislocazione") VALUES (33,'Monitoraggio',NULL);
INSERT INTO "ortiscolastici"."gruppo" ("id","tipo","dislocazione") VALUES (34,'Monitoraggio',NULL);
INSERT INTO "ortiscolastici"."gruppo" ("id","tipo","dislocazione") VALUES (35,NULL,NULL);
INSERT INTO "ortiscolastici"."gruppo" ("id","tipo","dislocazione") VALUES (36,'Controllo',NULL);
INSERT INTO "ortiscolastici"."gruppo" ("id","tipo","dislocazione") VALUES (37,'Controllo',NULL);
INSERT INTO "ortiscolastici"."gruppo" ("id","tipo","dislocazione") VALUES (38,'Monitoraggio',NULL);
INSERT INTO "ortiscolastici"."gruppo" ("id","tipo","dislocazione") VALUES (39,'Controllo',NULL);
INSERT INTO "ortiscolastici"."gruppo" ("id","tipo","dislocazione") VALUES (40,NULL,NULL);
INSERT INTO "ortiscolastici"."gruppo" ("id","tipo","dislocazione") VALUES (41,'Controllo',NULL);
INSERT INTO "ortiscolastici"."gruppo" ("id","tipo","dislocazione") VALUES (42,'Monitoraggio',NULL);
INSERT INTO "ortiscolastici"."gruppo" ("id","tipo","dislocazione") VALUES (43,'Monitoraggio',NULL);
INSERT INTO "ortiscolastici"."gruppo" ("id","tipo","dislocazione") VALUES (44,'Monitoraggio',NULL);
INSERT INTO "ortiscolastici"."gruppo" ("id","tipo","dislocazione") VALUES (45,'Monitoraggio',NULL);
INSERT INTO "ortiscolastici"."gruppo" ("id","tipo","dislocazione") VALUES (46,'Controllo',NULL);
INSERT INTO "ortiscolastici"."gruppo" ("id","tipo","dislocazione") VALUES (47,'Monitoraggio',NULL);
INSERT INTO "ortiscolastici"."gruppo" ("id","tipo","dislocazione") VALUES (48,'Controllo',NULL);
INSERT INTO "ortiscolastici"."gruppo" ("id","tipo","dislocazione") VALUES (49,'Monitoraggio',NULL);
INSERT INTO "ortiscolastici"."gruppo" ("id","tipo","dislocazione") VALUES (50,NULL,NULL);
INSERT INTO "ortiscolastici"."scuola" ("codicemeccanografico","nomeistituto","provincia","cicloistruzione","tipofinanziamento") VALUES ('VNHY110520','pxaokyzezxymmwspblznfhiznhtuiorrlixkjtadrfibvlz','GJ','Primo','C6YhneOIrMCohiF0j');
INSERT INTO "ortiscolastici"."scuola" ("codicemeccanografico","nomeistituto","provincia","cicloistruzione","tipofinanziamento") VALUES ('VGQD039984','cpddjrgfwlqiopbszmgaedfeoofheozadgbeescsejkrmqm','BD','Primo','dRz2hdH2Dqn5JoYjwFjYC58LwY1DZi2SLDT4aTit1Od8AEU3Eql60hHOuuyINBHEVRzkLDdClltta');
INSERT INTO "ortiscolastici"."scuola" ("codicemeccanografico","nomeistituto","provincia","cicloistruzione","tipofinanziamento") VALUES ('PSOR941422','bwkfubrnntcmewnqsgudoieqwpeigtpcvccjvwpiwojchkz','DO','Primo',NULL);
INSERT INTO "ortiscolastici"."scuola" ("codicemeccanografico","nomeistituto","provincia","cicloistruzione","tipofinanziamento") VALUES ('OPZA101226','bigpdbaeutktuewwpiyglitftsigygvmnatyibiuozybkhw','VS','Secondo','A64Ai01a');
INSERT INTO "ortiscolastici"."scuola" ("codicemeccanografico","nomeistituto","provincia","cicloistruzione","tipofinanziamento") VALUES ('KEXI012055','ouwliimzwfhpnjybrmwzlxgafiiqwrboqswekheidfcrwcb','KC','Secondo','2GvyJMpfG30zn70njIGgPESgHyiTIztIZzlw2VOu5vjvqb3Flt6BVtXFlFTlx7T11HdgZpX3');
INSERT INTO "ortiscolastici"."scuola" ("codicemeccanografico","nomeistituto","provincia","cicloistruzione","tipofinanziamento") VALUES ('DSEM884224','bpdedotgxlzaggtngmvmsckvpdkycqnamgmapyuxvrbbtnl','KD','Secondo','DeGskKbL6xkNmaV2RpcqCUnxoN6XJuSSCDzMgbHv47');
INSERT INTO "ortiscolastici"."scuola" ("codicemeccanografico","nomeistituto","provincia","cicloistruzione","tipofinanziamento") VALUES ('JQWY251007','llotesgajmgnlkoqlckhgtdhobngujfgneofjgseodfzlrr','CP','Primo',NULL);
INSERT INTO "ortiscolastici"."scuola" ("codicemeccanografico","nomeistituto","provincia","cicloistruzione","tipofinanziamento") VALUES ('GJJL536198','jndncgvyixlsxtdowbwnncccdpenwsqfcrjpckftiedosuj','JI','Secondo','MBHFkX0b7lukZG10P0dZAr21eU06KuDK5p4IiOCCm');
INSERT INTO "ortiscolastici"."scuola" ("codicemeccanografico","nomeistituto","provincia","cicloistruzione","tipofinanziamento") VALUES ('YGSW993382','ezkxzfzcrtzvrrgncdhezjkbliqivyzjtlupymkipdcpqny','LZ','Primo',NULL);
INSERT INTO "ortiscolastici"."scuola" ("codicemeccanografico","nomeistituto","provincia","cicloistruzione","tipofinanziamento") VALUES ('SJQI629835','zpcmmuewjeetiprckbxaeokaugpjfeykonnuodxbqvrgoyw','YI','Secondo','PyrSie1DvsqJedFHaqGNNXWBg1N0WB0KijaYKx2F1lTgHEo2jpaJ4FtZAJ2LOt0rTt47hrzzvnn7KRjx1Yi');
INSERT INTO "ortiscolastici"."scuola" ("codicemeccanografico","nomeistituto","provincia","cicloistruzione","tipofinanziamento") VALUES ('BAPT497687','srdbmfftxwzrytxogspknkhhxmfxmtplyedwlgirttaoyrk','SF','Secondo','UjQ7NBXA3IH7hXOwlMywMKidJTCALzo5HZNjcwOL6UsX0LrQ7Gc0R1sMFdbo8ZtrrdXvkuPIkVU53sakkUp3Z4fc0e4w');
INSERT INTO "ortiscolastici"."scuola" ("codicemeccanografico","nomeistituto","provincia","cicloistruzione","tipofinanziamento") VALUES ('LGNK509355','baxxsexvwwwoyjotuzblnmzehxpyfjtrwfyvxhpelziybln','QL','Primo',NULL);
INSERT INTO "ortiscolastici"."scuola" ("codicemeccanografico","nomeistituto","provincia","cicloistruzione","tipofinanziamento") VALUES ('HTAF177965','kqpcenejpexqkazyqoqsrswsabumfnbgtregpydetcaclbz','ZH','Primo','63dZXbcCxQGXrEdNveXIQerZaJW0ZjAVve6de1yUqStqRrPKhoAvdHxmC3zn5bPqi');
INSERT INTO "ortiscolastici"."scuola" ("codicemeccanografico","nomeistituto","provincia","cicloistruzione","tipofinanziamento") VALUES ('URES865795','xxnijqqaypydiznymviajqkocvuzvipxysrpsjmdzajikza','IZ','Primo','mZf647PLHHL7uhH8kwr31UWi20krSSZoU6Olir1I0OQQNoKQNutSSKG5eHZlqM4rYkpWdpFGh6w4Egj8eKPxyPVjosfdtUsCzjdzsq5');
INSERT INTO "ortiscolastici"."scuola" ("codicemeccanografico","nomeistituto","provincia","cicloistruzione","tipofinanziamento") VALUES ('TGPP568402','jnkjsbuebsuhsafuskktwikszfhvjdyphuwjoffxksybadf','WO','Primo',NULL);
INSERT INTO "ortiscolastici"."scuola" ("codicemeccanografico","nomeistituto","provincia","cicloistruzione","tipofinanziamento") VALUES ('PAXS348892','pvspplkqxpcnayrgitcujvynmuzprafkozwdmldnujbfvxn','YL','Secondo',NULL);
INSERT INTO "ortiscolastici"."scuola" ("codicemeccanografico","nomeistituto","provincia","cicloistruzione","tipofinanziamento") VALUES ('KVAU104880','hbefftksbbywzakjkjvlekbrjepdrvfnenceqeanenlxllr','ZM','Primo','E3spYDRUJ1Kp8dRlySgnXZqP');
INSERT INTO "ortiscolastici"."scuola" ("codicemeccanografico","nomeistituto","provincia","cicloistruzione","tipofinanziamento") VALUES ('ETRF122164','cfzxtcoxwahvxokxjgogorqcufqqqhoamhvjzdkfjjjzzac','RM','Secondo','FAkBSAGnMQbaVWgEcsrCtuukTCGOJTCrSGpwX0E4kKGDv6tAJalavlvSWKzbtUPqAYUjKJgXrma8XZnAgiMh87tWsT');
INSERT INTO "ortiscolastici"."scuola" ("codicemeccanografico","nomeistituto","provincia","cicloistruzione","tipofinanziamento") VALUES ('EUAL046983','bzwlejnbmyeetilavtutdaiuvfzdhwiluboifpepnfxbaps','NA','Primo',NULL);
INSERT INTO "ortiscolastici"."scuola" ("codicemeccanografico","nomeistituto","provincia","cicloistruzione","tipofinanziamento") VALUES ('CIZO873018','komepxdlkcxjhwnskyesdhwvvzcermjkeyfugferldmvrto','HB','Secondo','8msUuuYeVLEMrKPqd3RSTciQ');
INSERT INTO "ortiscolastici"."scuola" ("codicemeccanografico","nomeistituto","provincia","cicloistruzione","tipofinanziamento") VALUES ('GPUC442579','rnxwfjbwrqvypeulkwtbxttjebqyygrnfviivcxhisokbjb','NO','Secondo','6L3Zcu8nn4CgTkwD7AP0NuBUpjZrHFCh7MUnGPsoECUdwEvqD0ssFZy57uRJZK7lSiOtNo5e8DIW');
INSERT INTO "ortiscolastici"."scuola" ("codicemeccanografico","nomeistituto","provincia","cicloistruzione","tipofinanziamento") VALUES ('GXZO042687','hgwjtnwgkhmtoezuropfubychkcyypxtrjeberctenkdxfd','ET','Secondo','x30Wbp20fqLMo8YjM76KbhUI0mkD4B1GLw1FI6GihhgkTeCHfT3IBY4NtUEWVlldFfxFPv1JqI8JFXpExtNgABULCTYMZVdxOL');
INSERT INTO "ortiscolastici"."scuola" ("codicemeccanografico","nomeistituto","provincia","cicloistruzione","tipofinanziamento") VALUES ('NVNZ619179','flvagpdgmidhrzwctadoutwnyfjrsigxgwbxdpofirylngv','RE','Secondo','JRHK1sGucCmvXEzkwmmhLJSz4t0s7feja1msRvtPYQPVPj4txdQaFl7GEdtyCUIwf7ODPJO8T0mVecRZ0KL1vW41LKKHeoMjFFwWX');
INSERT INTO "ortiscolastici"."scuola" ("codicemeccanografico","nomeistituto","provincia","cicloistruzione","tipofinanziamento") VALUES ('NILH447616','puiirtkfektedzquggrpohbkevgovakbsfflmdfupqwlzdx','MV','Primo',NULL);
INSERT INTO "ortiscolastici"."scuola" ("codicemeccanografico","nomeistituto","provincia","cicloistruzione","tipofinanziamento") VALUES ('ZWLF641189','vgkmcsighxvlygraiftjoyqzlzdneubdrqopkoninrhefzr','WL','Primo','G1JAhDM0eTDZCX8RNNaB0TyT4PDyNTMAnAMu7xCziTdJ0pVHl2d1BZxLdXFUl4876hg3UrKWjF77quLKvNM');
INSERT INTO "ortiscolastici"."scuola" ("codicemeccanografico","nomeistituto","provincia","cicloistruzione","tipofinanziamento") VALUES ('FTBL698311','lnrmqivjefirtsnprjchugmswqwouqptnixadmwncactruh','FO','Primo','yRDebQHUosxcpWynWtLfG8yUbsXGxcRqDxuWtTdvPb5mSBGEiNbpak6gGo0RccCDRYgoEpkmEbLItAAzefGY6J');
INSERT INTO "ortiscolastici"."scuola" ("codicemeccanografico","nomeistituto","provincia","cicloistruzione","tipofinanziamento") VALUES ('IQDT012762','gwwjnxfwdwmsvnanqvswkqnoyfuopcfzrjzdqesarajimvq','JU','Secondo','inHErW5lHMmhBIBosgIcNScMNj50gWiMuQfQeYECX1LsRZNfuKcPK6OxO7wWVBXG');
INSERT INTO "ortiscolastici"."scuola" ("codicemeccanografico","nomeistituto","provincia","cicloistruzione","tipofinanziamento") VALUES ('GEUW927079','ouackidayfcbifckhdeysvslsbhggzubdoeqovekfpmmpkv','BS','Primo','yl3echvdpjGP8FUgiDNoIeM8dOYsMjawCBefYfDkJnVAyJ35WpP4');
INSERT INTO "ortiscolastici"."scuola" ("codicemeccanografico","nomeistituto","provincia","cicloistruzione","tipofinanziamento") VALUES ('JINL051845','bnxiezskgmnswgayxomwadnjhyzpzyswimkhpghurhsyfve','RQ','Primo','vG');
INSERT INTO "ortiscolastici"."scuola" ("codicemeccanografico","nomeistituto","provincia","cicloistruzione","tipofinanziamento") VALUES ('KINJ948332','rdejympirjiwzvzcvvykkzminyvgjopcfdqotkemijscbcp','ZV','Secondo','Pc2QEbOiXy1A5AEDXLof8mY4X0mLN4iCbYThiZKqIm3NsiBEOFJKABCgS62NqcRFUHZtv7ZA0eN3c');
INSERT INTO "ortiscolastici"."scuola" ("codicemeccanografico","nomeistituto","provincia","cicloistruzione","tipofinanziamento") VALUES ('MGCO209282','raqtpbcymdjhmfnzcrgghvzsjxviqczjhgvwmamphcgncjh','FR','Primo','MYFv6VyPrpXx8fs2EDihpauDgXuAmhyr2vYRXz7q');
INSERT INTO "ortiscolastici"."scuola" ("codicemeccanografico","nomeistituto","provincia","cicloistruzione","tipofinanziamento") VALUES ('LBPD395491','rodiysgjlttvzcibveepnhfsrbqwpxnzhipbitmcvypqjaz','XX','Secondo','0lVrViigeL7DK7I8uYbBelYqL2carsRn1tU1gxy4NzqjlU4WCuWMqVPCq2nQoxJNDBPBWR5t0igT2fjz2PDwIHoBzmEzecHPuzRSPddsoaiEOI');
INSERT INTO "ortiscolastici"."scuola" ("codicemeccanografico","nomeistituto","provincia","cicloistruzione","tipofinanziamento") VALUES ('DLPF126711','pmpbdggekshvncnpjbpjrypcfaniaoigzfufzgdxrvwmmal','PE','Primo','4uN6uLXKuJYuqWQ72wYkFcHdgFAvhSdsrzXnd4o3iAEHTAAhE70sXYpSmqahKVIossyAxcxo8DgFIkAZXIHfm7MtmGOW');
INSERT INTO "ortiscolastici"."scuola" ("codicemeccanografico","nomeistituto","provincia","cicloistruzione","tipofinanziamento") VALUES ('NEXF627033','psaqsmoujtkertninoysaniyqaaehpjuwkrlytvzrglydbe','NA','Secondo','VzevThtCJsZf6DpcampnCgtD0n8Q2hBgmLcdN01x7hVTQVPxUcwxI5AxUFua2TxTW3hV0zZomvgdIIDK5hgoGGKYXXcUSLrz');
INSERT INTO "ortiscolastici"."scuola" ("codicemeccanografico","nomeistituto","provincia","cicloistruzione","tipofinanziamento") VALUES ('HTLL701604','bstelyjmachzffxnwcexjwmadnlcplcswimdipumwvrbxnb','AC','Primo',NULL);
INSERT INTO "ortiscolastici"."scuola" ("codicemeccanografico","nomeistituto","provincia","cicloistruzione","tipofinanziamento") VALUES ('PNXS039570','rvailigwuwugtowbhagxoeqnueyngttcrtsjkoqcccpitah','CA','Secondo','3mwL7CRFjH2GqVMTyqzUFXRmG6skSZUYkoDSyLr5VU7xl');
INSERT INTO "ortiscolastici"."scuola" ("codicemeccanografico","nomeistituto","provincia","cicloistruzione","tipofinanziamento") VALUES ('VCKC082963','mncxghuspfwcmfllesscyzdzpzxxtxcoqxwlgndtgkxaocq','CY','Secondo','zcJroUSiHVrgxv');
INSERT INTO "ortiscolastici"."scuola" ("codicemeccanografico","nomeistituto","provincia","cicloistruzione","tipofinanziamento") VALUES ('QHND731760','aidosagmiykimmajipjhlooabrfnhhviqbszkffxskhwylm','WJ','Secondo','VX2RjdpKShgnuvLpCx8dKxO8AbBBYzNTihMQPrrGWYmUCyJgRnwlF');
INSERT INTO "ortiscolastici"."scuola" ("codicemeccanografico","nomeistituto","provincia","cicloistruzione","tipofinanziamento") VALUES ('NXVI522896','vrxhtmikcktckityypknsfsafvcuskcuoeccwizspiwlhqp','KN','Primo','ziqK1pDKmfJOzjkTS1QNmFV57TgqMC');
INSERT INTO "ortiscolastici"."scuola" ("codicemeccanografico","nomeistituto","provincia","cicloistruzione","tipofinanziamento") VALUES ('EVMM088541','ncuqzzgcvvgoifriuamhvmdczuqrjkgwkqxftdaumbhspqj','YK','Secondo','PCOEzLMZgKEnwcxIDbaOFnyHqK27mBn2ihAEKCm87ybukD');
INSERT INTO "ortiscolastici"."scuola" ("codicemeccanografico","nomeistituto","provincia","cicloistruzione","tipofinanziamento") VALUES ('HQVY577395','xfshapqqupukudnrelhcgxmswjlefirhuxzxpaputqzihhx','FQ','Secondo','CMFCidliAA5bidks5laA03DZLbPmpyFKL8vIWcmGNpVTy1nrIO1AKJ8Hq0tarOXq7OLVqQOXEYxYqlQRWMAhC2ctrGjovJKI6e4ebFCVtMn');
INSERT INTO "ortiscolastici"."scuola" ("codicemeccanografico","nomeistituto","provincia","cicloistruzione","tipofinanziamento") VALUES ('WZPL379116','nkrvqpkzifcbqboledogqwlposrixrugeppzbxtngrwbiiu','ZC','Secondo','TUpB00zMEKjdFxU');
INSERT INTO "ortiscolastici"."scuola" ("codicemeccanografico","nomeistituto","provincia","cicloistruzione","tipofinanziamento") VALUES ('OXEM815286','dvzlpkppiqiqeqqtvymhvjgbrgpwgudisckgzqwsqnquutt','UU','Secondo','V5Kr3xYDqTvh8d2846TyIHjmbbUdf2yHzqWKSKvHZx13UDTDSnsx51nJUopHVnwniGKqHatbWBgJhky38O81Rh2ZDA3WXbgMv7ZFKs1lMVRd7B');
INSERT INTO "ortiscolastici"."scuola" ("codicemeccanografico","nomeistituto","provincia","cicloistruzione","tipofinanziamento") VALUES ('VTKB006525','jzfsgfnfjitwgueagvfyiphklrmzwfwgppfkpmnbmunuyce','MY','Primo','WJFUDkOSG2rEJ0knwTGk3Hk44TnNlEEhQ84CQP73YR6UvI73oje2vZCcoZUr');
INSERT INTO "ortiscolastici"."scuola" ("codicemeccanografico","nomeistituto","provincia","cicloistruzione","tipofinanziamento") VALUES ('AWID899355','ldbwjorsjlnqjczvpdsrrrbzkgyvcncqjbidmzkprsswhen','LI','Secondo','1rkeO0RQacD80hvR8dD0yVzrOAdsu');
INSERT INTO "ortiscolastici"."scuola" ("codicemeccanografico","nomeistituto","provincia","cicloistruzione","tipofinanziamento") VALUES ('MQKH080804','murzcbawmzsguwznpvwpglagmecmvuxhibzaegxsxagwhoi','PZ','Primo','fvCXVvW1yp6pSTAzG7RBCsuPNiSnUEPD8AhxLnmVg6O8Nw2DDDdJ0m8AYnrIIdDUBkAy');
INSERT INTO "ortiscolastici"."scuola" ("codicemeccanografico","nomeistituto","provincia","cicloistruzione","tipofinanziamento") VALUES ('DIGB587620','xnaooznsffwneqrtkbmkiejutorkxfzjoijtvnbxpkhdijr','FM','Secondo',NULL);
INSERT INTO "ortiscolastici"."scuola" ("codicemeccanografico","nomeistituto","provincia","cicloistruzione","tipofinanziamento") VALUES ('UPJB481631','fkhsyyjsoknjpeaaenwjjlngrmpjdxfopbtnjpdpiifcbtw','PJ','Primo',NULL);
INSERT INTO "ortiscolastici"."scuola" ("codicemeccanografico","nomeistituto","provincia","cicloistruzione","tipofinanziamento") VALUES ('LATB225291','xhwfcygqdvguhixsogrieaqfkkpnsljilbyqptcyithqknx','YX','Secondo','KDQXMiFdhh1FWOLJ7yzTBsJRWmWkTXwQBCAEInlzCYjiAYCtPIcJhqJC7PNXf12EzTub1ejXNgVYOIDvFZ');
INSERT INTO "ortiscolastici"."scuola" ("codicemeccanografico","nomeistituto","provincia","cicloistruzione","tipofinanziamento") VALUES ('YQRW022436','djejlqaluvrurychdikdraetyempotvmgoafmeveowwjgor','QY','Primo','O38gIfs3');



INSERT INTO "ortiscolastici"."orto" ("nome","codicemecc","tipo","gps","superficie","condizioni","disponibilitàcollab","numerosensori","attività") VALUES ('N1ZTEcuiLYhodtH6ZGyRQa0Qk','VNHY110520','In vaso','tgIJagkpmrhHd8',87.2,'Pulito',False,4864,'Biomonitoraggio');
INSERT INTO "ortiscolastici"."orto" ("nome","codicemecc","tipo","gps","superficie","condizioni","disponibilitàcollab","numerosensori","attività") VALUES ('Si6FEPo4XTsJ','JQWY251007','In vaso','ZPFHhu3jzM8MaIieZY1p5IRU',429.3,'Non pulito',True,12483,'Biomonitoraggio');
INSERT INTO "ortiscolastici"."orto" ("nome","codicemecc","tipo","gps","superficie","condizioni","disponibilitàcollab","numerosensori","attività") VALUES ('lsXAgi','URES865795','In vaso','wA',819.3,'Non pulito',False,29839,'Biomonitoraggio');
INSERT INTO "ortiscolastici"."orto" ("nome","codicemecc","tipo","gps","superficie","condizioni","disponibilitàcollab","numerosensori","attività") VALUES ('WoZHSQO','NILH447616','In pieno campo','uj8p',5424.8,'Pulito',False,12558,'Biomonitoraggio');
INSERT INTO "ortiscolastici"."orto" ("nome","codicemecc","tipo","gps","superficie","condizioni","disponibilitàcollab","numerosensori","attività") VALUES ('mkUXXRP','KINJ948332','In pieno campo','Pq',75.4,'Non pulito',False,16756,'Biomonitoraggio');
INSERT INTO "ortiscolastici"."orto" ("nome","codicemecc","tipo","gps","superficie","condizioni","disponibilitàcollab","numerosensori","attività") VALUES ('rhs3FGFSpu','NEXF627033','In pieno campo','x',24.2,'Non pulito',True,29936,'Biomonitoraggio');
INSERT INTO "ortiscolastici"."orto" ("nome","codicemecc","tipo","gps","superficie","condizioni","disponibilitàcollab","numerosensori","attività") VALUES ('Retav5Mk1','NXVI522896','In vaso','1zoygtlnOcwPaAKMxU',6.9,'Pulito',False,12354,'Fitobonifica');
INSERT INTO "ortiscolastici"."orto" ("nome","codicemecc","tipo","gps","superficie","condizioni","disponibilitàcollab","numerosensori","attività") VALUES ('nIlCabcdcFnvkhbKUlKre','WZPL379116','In vaso','Mquujf64md6fzwX',3.8,'Non pulito',False,16052,'Fitobonifica');
INSERT INTO "ortiscolastici"."orto" ("nome","codicemecc","tipo","gps","superficie","condizioni","disponibilitàcollab","numerosensori","attività") VALUES ('H','UPJB481631','In pieno campo','uo',9.3,'Non pulito',False,26440,'Fitobonifica');
INSERT INTO "ortiscolastici"."orto" ("nome","codicemecc","tipo","gps","superficie","condizioni","disponibilitàcollab","numerosensori","attività") VALUES ('zoAIx1B','FTBL698311','In vaso','LhfN8NTZvWFtp',79.9,'Pulito',True,5200,'Fitobonifica');
INSERT INTO "ortiscolastici"."orto" ("nome","codicemecc","tipo","gps","superficie","condizioni","disponibilitàcollab","numerosensori","attività") VALUES ('D6IobJETwYiF4oWZUiOD','NEXF627033','In pieno campo','u',842.9,'Pulito',True,32483,'Biomonitoraggio');
INSERT INTO "ortiscolastici"."orto" ("nome","codicemecc","tipo","gps","superficie","condizioni","disponibilitàcollab","numerosensori","attività") VALUES ('S3UD6h7wEw7WZrOPSIEZzpgK','HTLL701604','In pieno campo','iNWbrinLlBMZm56',464.2,'Pulito',False,9258,'Biomonitoraggio');
INSERT INTO "ortiscolastici"."orto" ("nome","codicemecc","tipo","gps","superficie","condizioni","disponibilitàcollab","numerosensori","attività") VALUES ('51QG','VCKC082963','In pieno campo','PlRAq4HVBVqjdKo0',623.7,'Pulito',False,2397,'Biomonitoraggio');
INSERT INTO "ortiscolastici"."orto" ("nome","codicemecc","tipo","gps","superficie","condizioni","disponibilitàcollab","numerosensori","attività") VALUES ('2','AWID899355','In pieno campo','XhY5dBdcW',69.7,'Pulito',False,30056,'Biomonitoraggio');
INSERT INTO "ortiscolastici"."orto" ("nome","codicemecc","tipo","gps","superficie","condizioni","disponibilitàcollab","numerosensori","attività") VALUES ('4eqZCJj6rwpgC5o','MQKH080804','In vaso','ShZz',4845.5,'Pulito',True,10651,'Biomonitoraggio');
INSERT INTO "ortiscolastici"."orto" ("nome","codicemecc","tipo","gps","superficie","condizioni","disponibilitàcollab","numerosensori","attività") VALUES ('3KPWSUx5A6Vvnm','MGCO209282','In pieno campo','TzQa',809.3,'Non pulito',False,2179,'Biomonitoraggio');
INSERT INTO "ortiscolastici"."orto" ("nome","codicemecc","tipo","gps","superficie","condizioni","disponibilitàcollab","numerosensori","attività") VALUES ('e','HTLL701604','In pieno campo','JAW2H3V3dCne0YUX0',9440.1,'Non pulito',False,17452,'Fitobonifica');
INSERT INTO "ortiscolastici"."orto" ("nome","codicemecc","tipo","gps","superficie","condizioni","disponibilitàcollab","numerosensori","attività") VALUES ('wZWrcnvgR4zFNYiYqyO5C1do','VTKB006525','In pieno campo','jvVMIgTz4IRyBYlyqZ7jwtY',9.8,'Pulito',False,19956,'Biomonitoraggio');
INSERT INTO "ortiscolastici"."orto" ("nome","codicemecc","tipo","gps","superficie","condizioni","disponibilitàcollab","numerosensori","attività") VALUES ('TG','AWID899355','In vaso','jZehkH5',84.6,'Pulito',True,16692,'Fitobonifica');
INSERT INTO "ortiscolastici"."orto" ("nome","codicemecc","tipo","gps","superficie","condizioni","disponibilitàcollab","numerosensori","attività") VALUES ('al4mgPvZot','GEUW927079','In pieno campo','Iz',3.4,'Non pulito',False,27839,'Fitobonifica');
INSERT INTO "ortiscolastici"."orto" ("nome","codicemecc","tipo","gps","superficie","condizioni","disponibilitàcollab","numerosensori","attività") VALUES ('cdQBclS3nEK','MGCO209282','In pieno campo','3CeQEWU',118.1,'Pulito',True,19400,'Biomonitoraggio');
INSERT INTO "ortiscolastici"."orto" ("nome","codicemecc","tipo","gps","superficie","condizioni","disponibilitàcollab","numerosensori","attività") VALUES ('jz4Si','PNXS039570','In pieno campo','ESmthrrl00FM2L1f',278.5,'Non pulito',True,2797,'Biomonitoraggio');
INSERT INTO "ortiscolastici"."orto" ("nome","codicemecc","tipo","gps","superficie","condizioni","disponibilitàcollab","numerosensori","attività") VALUES ('HPiudy6Xm5ItkCE6bDyjfwJq','HQVY577395','In pieno campo','kTMXKPiLui',19.8,'Non pulito',True,28128,'Biomonitoraggio');
INSERT INTO "ortiscolastici"."orto" ("nome","codicemecc","tipo","gps","superficie","condizioni","disponibilitàcollab","numerosensori","attività") VALUES ('r7LRzpY1WhsVZ6iUN2oxar','MQKH080804','In vaso','FodYrTOGQank8XpFmaUq',6,'Non pulito',False,17540,'Biomonitoraggio');
INSERT INTO "ortiscolastici"."orto" ("nome","codicemecc","tipo","gps","superficie","condizioni","disponibilitàcollab","numerosensori","attività") VALUES ('yqM','JINL051845','In pieno campo','IRWQ2ZJP3taf7',3.8,'Pulito',False,10847,'Biomonitoraggio');
INSERT INTO "ortiscolastici"."orto" ("nome","codicemecc","tipo","gps","superficie","condizioni","disponibilitàcollab","numerosensori","attività") VALUES ('bKxsdwajIspU','KINJ948332','In vaso','4fLTIkuWddX5rx',9.8,'Pulito',True,27959,'Fitobonifica');
INSERT INTO "ortiscolastici"."orto" ("nome","codicemecc","tipo","gps","superficie","condizioni","disponibilitàcollab","numerosensori","attività") VALUES ('NpJmYdBXRUyi5','QHND731760','In pieno campo','faFj1',4896.9,'Non pulito',False,19271,'Fitobonifica');
INSERT INTO "ortiscolastici"."orto" ("nome","codicemecc","tipo","gps","superficie","condizioni","disponibilitàcollab","numerosensori","attività") VALUES ('S','VTKB006525','In pieno campo','Kawkzeng',6929.8,'Non pulito',True,12203,'Biomonitoraggio');
INSERT INTO "ortiscolastici"."orto" ("nome","codicemecc","tipo","gps","superficie","condizioni","disponibilitàcollab","numerosensori","attività") VALUES ('SHSESvjfldNSeHCq','AWID899355','In vaso','pNFcckuiGu',5032.1,'Pulito',True,29924,'Biomonitoraggio');
INSERT INTO "ortiscolastici"."orto" ("nome","codicemecc","tipo","gps","superficie","condizioni","disponibilitàcollab","numerosensori","attività") VALUES ('ykpJStkj','LATB225291','In vaso','gp',595,'Pulito',False,1990,'Biomonitoraggio');
INSERT INTO "ortiscolastici"."orto" ("nome","codicemecc","tipo","gps","superficie","condizioni","disponibilitàcollab","numerosensori","attività") VALUES ('uFcQPzrPfR','KINJ948332','In vaso','ezZEh5db1wgNzxatv',31.5,'Pulito',True,5519,'Biomonitoraggio');
INSERT INTO "ortiscolastici"."orto" ("nome","codicemecc","tipo","gps","superficie","condizioni","disponibilitàcollab","numerosensori","attività") VALUES ('D','PNXS039570','In vaso','PslDwxIGbjoISKxcl',7.4,'Pulito',True,205,'Biomonitoraggio');
INSERT INTO "ortiscolastici"."orto" ("nome","codicemecc","tipo","gps","superficie","condizioni","disponibilitàcollab","numerosensori","attività") VALUES ('j','OXEM815286','In pieno campo','DnEGhz6BNH',84.5,'Non pulito',False,404,'Biomonitoraggio');
INSERT INTO "ortiscolastici"."orto" ("nome","codicemecc","tipo","gps","superficie","condizioni","disponibilitàcollab","numerosensori","attività") VALUES ('2BXdd4Y0lilmmQt','YQRW022436','In vaso','6rH7BS',21.9,'Pulito',True,17876,'Fitobonifica');
INSERT INTO "ortiscolastici"."orto" ("nome","codicemecc","tipo","gps","superficie","condizioni","disponibilitàcollab","numerosensori","attività") VALUES ('sujChvJd0','KINJ948332','In vaso','IF4S6wm88VLPs',37.5,'Non pulito',True,5368,'Biomonitoraggio');
INSERT INTO "ortiscolastici"."orto" ("nome","codicemecc","tipo","gps","superficie","condizioni","disponibilitàcollab","numerosensori","attività") VALUES ('XYNU5FT','MGCO209282','In pieno campo','fso4Axk3ddtpxm8kMowMSVO',863.1,'Non pulito',True,7296,'Biomonitoraggio');
INSERT INTO "ortiscolastici"."orto" ("nome","codicemecc","tipo","gps","superficie","condizioni","disponibilitàcollab","numerosensori","attività") VALUES ('weIJAKRu','HTLL701604','In pieno campo','Nmg0EGRezicCOpoVw37',364.4,'Pulito',False,15954,'Fitobonifica');
INSERT INTO "ortiscolastici"."orto" ("nome","codicemecc","tipo","gps","superficie","condizioni","disponibilitàcollab","numerosensori","attività") VALUES ('y1THzVHr','NXVI522896','In vaso','yGUREttfmbc',5.6,'Pulito',False,19473,'Fitobonifica');
INSERT INTO "ortiscolastici"."orto" ("nome","codicemecc","tipo","gps","superficie","condizioni","disponibilitàcollab","numerosensori","attività") VALUES ('CPgc','EVMM088541','In vaso','PcMcX1fCzCu',676.9,'Non pulito',False,6215,'Fitobonifica');
INSERT INTO "ortiscolastici"."orto" ("nome","codicemecc","tipo","gps","superficie","condizioni","disponibilitàcollab","numerosensori","attività") VALUES ('JtHVutB2PNLJ','LATB225291','In vaso','nCFl',9,'Pulito',False,11168,'Biomonitoraggio');
INSERT INTO "ortiscolastici"."orto" ("nome","codicemecc","tipo","gps","superficie","condizioni","disponibilitàcollab","numerosensori","attività") VALUES ('fBaJwplSeBMYH38tos','JINL051845','In pieno campo','5jIFHyDKXJJscrdCTKJ',19.6,'Non pulito',False,26784,'Fitobonifica');
INSERT INTO "ortiscolastici"."orto" ("nome","codicemecc","tipo","gps","superficie","condizioni","disponibilitàcollab","numerosensori","attività") VALUES ('pUaGTG1m','MGCO209282','In pieno campo','tdnzziLKDd5',3522.4,'Pulito',False,6330,'Biomonitoraggio');
INSERT INTO "ortiscolastici"."orto" ("nome","codicemecc","tipo","gps","superficie","condizioni","disponibilitàcollab","numerosensori","attività") VALUES ('PqrDymG5PrOjqm','LBPD395491','In vaso','P3',313.2,'Pulito',True,8324,'Biomonitoraggio');
INSERT INTO "ortiscolastici"."orto" ("nome","codicemecc","tipo","gps","superficie","condizioni","disponibilitàcollab","numerosensori","attività") VALUES ('rZRk5pQOpGnsAf8iyh','VCKC082963','In pieno campo','khuwVyv',355,'Pulito',False,10275,'Biomonitoraggio');
INSERT INTO "ortiscolastici"."orto" ("nome","codicemecc","tipo","gps","superficie","condizioni","disponibilitàcollab","numerosensori","attività") VALUES ('q030THX72JBK5Sn0','EVMM088541','In pieno campo','SZbcZuHu8wcdRnIkV65ND43vF',651.9,'Pulito',False,20715,'Fitobonifica');
INSERT INTO "ortiscolastici"."orto" ("nome","codicemecc","tipo","gps","superficie","condizioni","disponibilitàcollab","numerosensori","attività") VALUES ('b','MQKH080804','In vaso','cD',1215.9,'Non pulito',False,5804,'Biomonitoraggio');
INSERT INTO "ortiscolastici"."orto" ("nome","codicemecc","tipo","gps","superficie","condizioni","disponibilitàcollab","numerosensori","attività") VALUES ('3UsMqvuz4URf2vXSLH','LATB225291','In pieno campo','xc4QUpK2h3',452.7,'Pulito',False,994,'Fitobonifica');
INSERT INTO "ortiscolastici"."orto" ("nome","codicemecc","tipo","gps","superficie","condizioni","disponibilitàcollab","numerosensori","attività") VALUES ('sRAIwET75U33H','LBPD395491','In vaso','y7o1q5oAluJ3eb',5,'Pulito',False,30519,'Fitobonifica');
INSERT INTO "ortiscolastici"."orto" ("nome","codicemecc","tipo","gps","superficie","condizioni","disponibilitàcollab","numerosensori","attività") VALUES ('uqV7jRoyltorrk6','VCKC082963','In pieno campo','P65TasuoowCEiyun6G2qsob',233.8,'Non pulito',True,19337,'Biomonitoraggio');
INSERT INTO "ortiscolastici"."orto" ("nome","codicemecc","tipo","gps","superficie","condizioni","disponibilitàcollab","numerosensori","attività") VALUES ('FdEhAIMFZTQHSF6FtTHVX','MQKH080804','In pieno campo','O7oSJww',278.2,'Non pulito',False,16543,'Fitobonifica');



INSERT INTO "ortiscolastici"."persona" ("email","cognome","nome","ruolo","numerotelefono","referenteiniziativa","coinvolta") VALUES ('Hank.Harness5@telefonica.co.uk','ihfuywxwhzuwgzezkpnsrjdphozespyonrowbgfjhvoijmtija','jhcoalevjqkqzwqsxsvdtwgkwiccznmlurmdrmxowxugoqqluh','huyldrxthjsgrgoumnixsfptojpwvkcyvgzwas','8279616255',True,'VNHY110520');
INSERT INTO "ortiscolastici"."persona" ("email","cognome","nome","ruolo","numerotelefono","referenteiniziativa","coinvolta") VALUES ('YStockton5@live.es','brlgskgjbpkqicuuaadeudkrcmkessmrxzlsvajyrdeparqycq','ntceiysskuhjhazitifgfgbcwonxvwdfgdocvoptplbgdthzrx','bquahdnpxqoqlvsvyoxyowmxvyofklugnvuqlh','2608667224',True,'BAPT497687');
INSERT INTO "ortiscolastici"."persona" ("email","cognome","nome","ruolo","numerotelefono","referenteiniziativa","coinvolta") VALUES ('AnnBrown@gawab.dk','tyxtwsuaqidwyllpveptimskexwehdrunbfnwsiydzoatjvqbj','dplvzmosimtczffccyizljuefueuopnaribrjgacmkqdhuejke','ffuhlfxnhkzszwuuhxypqvlfayjilshzntbkau',NULL,NULL,'ETRF122164');
INSERT INTO "ortiscolastici"."persona" ("email","cognome","nome","ruolo","numerotelefono","referenteiniziativa","coinvolta") VALUES ('PeterKingslan@telfort.de','rmqrhrtgjffnbzwyaemeduwrhgfzwcpcxkzcbqllqceytxbdyd','azspeeyfttyylehadavegqdbugnnmuxwpgpgupwknxncfojhls','aohfnnpzatmhkynbgmziqcfqpjjgiqhjgkqinq','2284055932',False,'ZWLF641189');
INSERT INTO "ortiscolastici"."persona" ("email","cognome","nome","ruolo","numerotelefono","referenteiniziativa","coinvolta") VALUES ('T.Ahlgren@gawab.org','yzqnaydommhtxbkafyjlxlnqpxjicrdoiypdnqmjrdysjwqrcp','tbazyigduhcforzrzhiimwowkkrazwqzrydfvqfnbnfaksmjbx','dptfoweeqkcdmocnojyottnokgxgkwyvjhvxgh','6523174273',True,NULL);
INSERT INTO "ortiscolastici"."persona" ("email","cognome","nome","ruolo","numerotelefono","referenteiniziativa","coinvolta") VALUES ('N.Griffioen2@myspace.ca','tvrkzvafkyzctknqykkmavgvjfwgqyzndznnhioyvoinbguzoa','wtnuvhjzvkjkymrcbozwnuwjbxmeiejcvzfmhbegxtcbvctvjz','xobpvjqwujjjkwzygakbcjbubupyrnucaiqlvk',NULL,False,'DLPF126711');
INSERT INTO "ortiscolastici"."persona" ("email","cognome","nome","ruolo","numerotelefono","referenteiniziativa","coinvolta") VALUES ('FredPrior3@live.cn','tikptwqhmzmirlkrevjzmcvkzvsnxqlrympqdwqofnydbojwwl','jlbhofjwfycgkamokdplooatjajrxuvgoegptvtdegzaztzrys','pztwjxkekuhqhrwohjlzcrndziaqvfjslnfdlm',NULL,True,'NXVI522896');
INSERT INTO "ortiscolastici"."persona" ("email","cognome","nome","ruolo","numerotelefono","referenteiniziativa","coinvolta") VALUES ('Fred.Kellock@telefonica.de','bgxvakdgupxwfzgybncztgzijtdtwaaudujdryxtrcqjpicllf','krgvekqrrqbxgonolhppqxqbrhjbujnjgnamdaszxonwvyixxc','khkkutcjcrfooopnapclspckipwrseogyxlztt','8329320575',True,'NXVI522896');
INSERT INTO "ortiscolastici"."persona" ("email","cognome","nome","ruolo","numerotelefono","referenteiniziativa","coinvolta") VALUES ('Geoffry.Langham5@web.com','jzsboitfqpgdgnxaabonnempbrbkzsishphvmucfgtimveiapa','wrskncyzjwiocozrtorallwqxxzujgxpsaksmprgcdyynlirnv','ppzmarfecdfwmgjmtrovsindbmoguicblgbkke','3799014780',NULL,'EVMM088541');
INSERT INTO "ortiscolastici"."persona" ("email","cognome","nome","ruolo","numerotelefono","referenteiniziativa","coinvolta") VALUES ('RoyHulshof4@telfort.net','kaocacxnhizciuzpltjyhnpesafdkibtmuzrtxggqmiglnokqz','rdjmoagnmyrvtcyrqwjivijgiclfmqqurymzeljsrdhnderroe','napgjogifztwknatpaijceuwzqedaqlznvuxjl','3634887722',False,'WZPL379116');
INSERT INTO "ortiscolastici"."persona" ("email","cognome","nome","ruolo","numerotelefono","referenteiniziativa","coinvolta") VALUES ('Leon.Baltec1@mymail.cn','kswcyxuyjaeblqokgakhbzgdsitigednhzqywbzbudzfjggsds','foeuctaptlsrrwjeybpalbseafdlnusefzpdmqgdfxfyxfppbq','vwgthvgzgouzyajserfrorrgpcrxytpnbwdsjg',NULL,False,'WZPL379116');
INSERT INTO "ortiscolastici"."persona" ("email","cognome","nome","ruolo","numerotelefono","referenteiniziativa","coinvolta") VALUES ('BiancaWong@gmail.no','mrsgfhbugbjxxhqfqhtqsvyejfrsclbheuyvwkzdwethcvwunj','lfzerrymnagkmhlxzkginknuwagpuuohazcgnmmcfsrbdrvvzc','jkvekzcteooqejhrwmdzqozcwvioxyjcvgouao','8907825166',True,'WZPL379116');
INSERT INTO "ortiscolastici"."persona" ("email","cognome","nome","ruolo","numerotelefono","referenteiniziativa","coinvolta") VALUES ('C.Griffioen@excite.org','mqtlprhlmieqzcjvhvcbrixvjdaojjxwkmgtfkcfgqcvrijtrh','eofnzjgmtmqrueisqxgejdownwloefcxoqzsublizkobzftuey','wlzzxyoinhanjnudflfdehbhcvvxgreaodgpcf',NULL,True,'YQRW022436');
INSERT INTO "ortiscolastici"."persona" ("email","cognome","nome","ruolo","numerotelefono","referenteiniziativa","coinvolta") VALUES ('Michael.Moore@web.nl','seeoxzewizjdrpscntbpwqiltnfulzqhfpgtzkxavkjhtiqhoq','xizroqkhsplpkgllvtjhbbaujpqsfuvgctfhndeototdlmjhzf','fpfgcsljyowxtpxrxogbttffbiouduslcsmstl','8244649854',True,'YQRW022436');
INSERT INTO "ortiscolastici"."persona" ("email","cognome","nome","ruolo","numerotelefono","referenteiniziativa","coinvolta") VALUES ('Nick.Bloom@freeweb.cc','yfsqcjhimcgdntisjtzsghtjpckgbmmavcngpstqxxmmudwckf','lhgucbxskkzdcbvhvmvdlayxzbilvohadvqolmfqcrdiewwvkv','ezctomqgwlazhshzmcoezemmrwmzspaycxppvz','3829699033',False,'YQRW022436');
INSERT INTO "ortiscolastici"."persona" ("email","cognome","nome","ruolo","numerotelefono","referenteiniziativa","coinvolta") VALUES ('M.Sharp@telefonica.net','ysceghkjfasegpzjwhawmgaqfzgijvcjiixogpfwioewulopvu','odierhmvvweospkmwdyifswxpozwlzogaqoyaldretqpljzzve','wdwtwjhytgjjwvhsyejcoanqmvribluvodeoqw','5938454577',True,NULL);
INSERT INTO "ortiscolastici"."persona" ("email","cognome","nome","ruolo","numerotelefono","referenteiniziativa","coinvolta") VALUES ('VCliment2@excite.fr','jphtgqftmudyvhlixsemrjedsoyguvrvopquyztarojmabxvve','jecqqcpoldgvchdroevbkdjsdfncvhyndtuvujringubvudcgw','zfjlyetvmfrhkpvymcfrlxwtbguxudjpupibdo','3549056817',True,'NEXF627033');
INSERT INTO "ortiscolastici"."persona" ("email","cognome","nome","ruolo","numerotelefono","referenteiniziativa","coinvolta") VALUES ('TreesFreeman1@hotmail.nl','nttmnbofmjgjsestftwjipsfixjaoltounfcaomfenqzqiwake','rtjxqvkkjgpixgrzbgddqfrknqommesjornqgmdcjuvhnmwsul','emjlogvwqsjllvzkayiwemqhhtkbzbyhowkxlm','9392969185',True,'NXVI522896');
INSERT INTO "ortiscolastici"."persona" ("email","cognome","nome","ruolo","numerotelefono","referenteiniziativa","coinvolta") VALUES ('PeterChwatal3@gmail.be','dmuaalaeikavayoiwvtslbnxzwewzuazzsjelkhfbxaghmrgxk','trzyqzqxmmvbhhhmigluhfomomuuwhoiuaaidufakefmbboiqa','whuytawatygudjohlztatbmrkesilqprgfbrwg','4929445086',NULL,'NXVI522896');
INSERT INTO "ortiscolastici"."persona" ("email","cognome","nome","ruolo","numerotelefono","referenteiniziativa","coinvolta") VALUES ('RickMillikin5@lycos.nl','vmafblgqrsahidlrkrcixxzejpovfilsohqasbkucjtoijxjrd','dvdyltbpqisgqznravyrfzvmwlybckzsdpndblwhdfkhjernvb','gxlpgwfktlwejtyevintlitfhzkvrhhgtigjsu','7189240244',False,'NXVI522896');
INSERT INTO "ortiscolastici"."persona" ("email","cognome","nome","ruolo","numerotelefono","referenteiniziativa","coinvolta") VALUES ('H.van Dijk@lycos.it','xdkkvvqrmyeedowqfpkhvrlubfcwpslemkhtzndntfmpgwugfr','oqiigecuwllszlqrnlaeyfetawcthswjapsodsdaiqpdiwewom','ukjwmgoisknyzpgbfztbigyuwgtvxccocnyumc','2206361659',False,'LATB225291');
INSERT INTO "ortiscolastici"."persona" ("email","cognome","nome","ruolo","numerotelefono","referenteiniziativa","coinvolta") VALUES ('J.Archer@mail.ca','ttzlmusrtnsuliceiwbbsunwbzabmsfdxwkxknmrljjzrnblls','nexdzrozwlyvgygjkcepsrfoppaerpobhmwfxeyfqapsuibdml','knkijokbyotqworqdqejlfqqxcpmluummwfumh','1863527035',True,'LATB225291');
INSERT INTO "ortiscolastici"."persona" ("email","cognome","nome","ruolo","numerotelefono","referenteiniziativa","coinvolta") VALUES ('LByrnes2@excite.fr','eupoqdvcecqabaiazgxjlizvntwriuqlccagwbrudknzcrphli','phxmgpxstileiutgngntidkrvxjqzbtdvznzcwzqspsuymxgce','suavrpnipibsucxoppiygosplgfkxdjukpiwog','9993065484',NULL,'YQRW022436');
INSERT INTO "ortiscolastici"."persona" ("email","cognome","nome","ruolo","numerotelefono","referenteiniziativa","coinvolta") VALUES ('Carla.Pensec@gawab.nl','cbgnjntiblwepvnmpfoqfeohwxprxdotgugrobgssciftgbfjg','hzxrqmikpqvtlzlhnjxaxscylkbrawxqygjbpjrslqibqibejh','qhdggoclefzldgzsdbxdxvyzzjpyagtepbfzyx','0131814212',False,'DLPF126711');
INSERT INTO "ortiscolastici"."persona" ("email","cognome","nome","ruolo","numerotelefono","referenteiniziativa","coinvolta") VALUES ('JackKepler@kpn.nl','trlyznrjktvxgqjccfaptwhpbqadfeybvlmzalmsmquwjxwion','slthkpbathwlbibdtgtsvwpbphkgqnefykaeesnzuheenspuyu','ufqnifrfmeejojwgjdwloqvwrtfdmpfaileips','2785390969',False,'DLPF126711');
INSERT INTO "ortiscolastici"."persona" ("email","cognome","nome","ruolo","numerotelefono","referenteiniziativa","coinvolta") VALUES ('Dana.Pensec@excite.gov','dhzojedswvbfizjyrhosqfwndvoulnyndmlgagxuxhylxvmabt','zufcvztgwamindiomggwjxsciigybfqeeibhqxxklrzcwfcrin','apwfcavkowadnmvuqtiedmgzmuepxkfqbxepmg','5889303852',False,'DLPF126711');
INSERT INTO "ortiscolastici"."persona" ("email","cognome","nome","ruolo","numerotelefono","referenteiniziativa","coinvolta") VALUES ('HansVoigt1@gawab.gov','ybyjelxaykzuxdzkwpesdcpghbduxucldltgpqmvtgfumyplix','gndcsonpxmgcmtnydgyxnzzdnvullkrbgtimugmrkybyiwdsep','oavndnxrtbyiohmdlfejbsaauvwptzefedfnkd','5535363503',True,'NXVI522896');
INSERT INTO "ortiscolastici"."persona" ("email","cognome","nome","ruolo","numerotelefono","referenteiniziativa","coinvolta") VALUES ('Fons.Nithman5@lycos.us','ewducxszeamjgtklwxbxhgtnqagyiesgpgtkhrcveneskojrsy','zpzoohamkedvzfucwgpgkikotrzukdcezynmatyreljuvyecnd','cyggpdtrbepgppagqdeksgiccmtliqkxjpvlyp','1653224237',True,'NXVI522896');
INSERT INTO "ortiscolastici"."persona" ("email","cognome","nome","ruolo","numerotelefono","referenteiniziativa","coinvolta") VALUES ('LindsyZapetis@telfort.es','purirmgrfgincduxrhdlbcaxkvtpktiuaxklofzjrsacdqhaxe','ermsrambcryrkukxartmbrwbklqrzquiqbrhvbsflacagcsafi','hmdhqrrqcespvgtgyfhpzmdrzktkhmymmejkem','7368657465',False,'WZPL379116');
INSERT INTO "ortiscolastici"."persona" ("email","cognome","nome","ruolo","numerotelefono","referenteiniziativa","coinvolta") VALUES ('RickConley@lycos.ca','zekeqzinamcaxnrynjnbvbrstnhldgskmdefxfrctacupjnbus','dnexcppdxprmxbttxobzldbyjnwvrxssrlxpolfvsejqrdzinj','tctmewmvvecomyvqzkflnbzxkjqxcuxhbwgtsi',NULL,True,'WZPL379116');
INSERT INTO "ortiscolastici"."persona" ("email","cognome","nome","ruolo","numerotelefono","referenteiniziativa","coinvolta") VALUES ('Y.Harness@aol.be','cucwayqdvzprfrhjdcxhzcmdpvypkfqluvcijmaciyrhjetcjn','tcutnjdaacmzrvpjgaeqndkdihdlvhsxshmjhycjpvnbtosmqo','outxtjkxzhnisrlbrdtshqbbjkgrklqzhcsdgx','9318212057',NULL,NULL);
INSERT INTO "ortiscolastici"."persona" ("email","cognome","nome","ruolo","numerotelefono","referenteiniziativa","coinvolta") VALUES ('Kylie.Anderson2@aol.es','rafnarrbkcemcektmcocgujwyjeeirwuctoonlnbhkzmdkiaoa','jcyusmglrqmfglzkkcodxuginhiiymvpvknlklgktfwpariqrx','irpkkgzdiczxlrbtjfjubpisgaydmoanautvlc','1045330751',False,'WZPL379116');
INSERT INTO "ortiscolastici"."persona" ("email","cognome","nome","ruolo","numerotelefono","referenteiniziativa","coinvolta") VALUES ('L.Guyer@kpn.de','kwohxusurdcyniqjdsxpkapagyyvntosdovrjsvaxdhpiwsskv','bgoqjqphipemaipknkqnwowwawzahsqoemgxjxzuawgqtayrek','yladfegbxognkcdcxmyoaluwkobrweskacfufr','2233705755',True,'VTKB006525');
INSERT INTO "ortiscolastici"."persona" ("email","cognome","nome","ruolo","numerotelefono","referenteiniziativa","coinvolta") VALUES ('Y.Chwatal@excite.fr','iuzabshmtlqqldbuwyizptqiyzadidbtgfdnnzwmpqlqqfbwhj','qizelxjdzvyyualojpcwcdzyhjkjqanrhryovivwnskvhtnimr','cxrzlykmllvbkuihpfuyaeunkaxejscxipjvsx',NULL,True,'FTBL698311');
INSERT INTO "ortiscolastici"."persona" ("email","cognome","nome","ruolo","numerotelefono","referenteiniziativa","coinvolta") VALUES ('S.Langham@gawab.cc','bmjqycltayfwttfiambgonpmutloaynmavgefyvinwfxhyvuct','cvloglpfswgbhnguwabnjobhbkstzvxdhwbnyfuwowiriokolv','pfedgiemfadndcgrjdbrmlidttkypontnuvfen','3454351608',True,'HTLL701604');
INSERT INTO "ortiscolastici"."persona" ("email","cognome","nome","ruolo","numerotelefono","referenteiniziativa","coinvolta") VALUES ('Richard.Knight@aol.dk','xpvncqmxjnikaprbnojsgoofoittiztwohphafwtrqgptbbzey','wmbdzjautglxjgxqrirwiydsimipuvzhimuekuydpffksgdkhe','lkynabusxtgdetolqpymyenmsladnfnbvtwehf','0493877028',NULL,'HTLL701604');
INSERT INTO "ortiscolastici"."persona" ("email","cognome","nome","ruolo","numerotelefono","referenteiniziativa","coinvolta") VALUES ('PStockton4@myspace.com','zotbyftsgqdchbgskdergxmoanpwwfopsugaldmyzojmxecdfv','obnmgzhrvgibbkeiikyuvhzqinghudgufgjnvqdhzpsbirngrd','bjrxvhhleoqqyrujlwvftwlesnqovobkooxxfa','7574931077',False,'HTLL701604');
INSERT INTO "ortiscolastici"."persona" ("email","cognome","nome","ruolo","numerotelefono","referenteiniziativa","coinvolta") VALUES ('JWatson@live.com','bbwsrprdqjdaoliclojjqsljxylaqdnweqszhavkpyfyrgnbff','gunetkrtinaiqnohqjjcmlnvantewfnyhwwgefywzofixyvogg','pfgkikdffrsotnwjvspupfjdszhupqyheibrbd','2905984400',True,'VCKC082963');
INSERT INTO "ortiscolastici"."persona" ("email","cognome","nome","ruolo","numerotelefono","referenteiniziativa","coinvolta") VALUES ('Y.Bergdahl1@telefonica.org','qxddueinunkomfslujluoqrzgexwybvdawrfjxeslahixqjexv','ndvqbjbatnbzwvgaixeicpkeolippuhhxnnwghnnisudjpqxsb','xhnlavpawmooeleoncdzjtlwnnmxlaorngtqts','1368322095',NULL,'VCKC082963');
INSERT INTO "ortiscolastici"."persona" ("email","cognome","nome","ruolo","numerotelefono","referenteiniziativa","coinvolta") VALUES ('BasRaines@lycos.cc','pfvveledtyrtuyueobbrddrbzazjnvyljrctqptstfhpzdyohg','nhhwulsktpaulghucyxpiucsdoxtjrgempbchzqhbiyypuzzdp','ymhzowlqdwrqodlqrnjbbblatrnqitmbdkfsno','9861571395',False,'WZPL379116');
INSERT INTO "ortiscolastici"."persona" ("email","cognome","nome","ruolo","numerotelefono","referenteiniziativa","coinvolta") VALUES ('Johan.Comeau@gmail.org','raemiizsuptcxtndotjklngahmcwfiygnqejxxagnrlnpzhhob','qoxawxppmfiehhmmmcfgbtmcenpteqjdaepphaapcqnwiypcta','grnogsjlkmrcbapnauoptbgdqpuozgxwaojxne','7053346984',True,'WZPL379116');
INSERT INTO "ortiscolastici"."persona" ("email","cognome","nome","ruolo","numerotelefono","referenteiniziativa","coinvolta") VALUES ('BillMiller@mymail.com','qtrhxsamuoxlnvlpmemibvgiqgbebpqhllxegamkozpjehvrtk','pursvsrqmtrwnmqyxmdatprmrjlgkrkerkqsikjfuwsvdjtnhb','hbupgpobmdtbmutxhioupvryzufvynbwhcpacj','8016029435',NULL,'WZPL379116');
INSERT INTO "ortiscolastici"."persona" ("email","cognome","nome","ruolo","numerotelefono","referenteiniziativa","coinvolta") VALUES ('Peter.Ostanik@kpn.it','nxpmnefagkjkpxuvrpcepjtqnujncnmdmtltneshrjqbcylbsy','csexgqfqocdvvhbegkfglmfpotthqcyhtfvgwuatsxreqwjaaj','xxgkpriwknkvllxzbmysinmibwmaymerjqspvc','5757316942',True,'AWID899355');
INSERT INTO "ortiscolastici"."persona" ("email","cognome","nome","ruolo","numerotelefono","referenteiniziativa","coinvolta") VALUES ('Patrick.DeBerg@mail.it','jcvyjicgxcluiuqnvxuvgeaxsjpssdjvmnobuaoaitebyvcoep','vydquzjqgdcdgwyddrheccrsqqvcygtcyliqaplexxpycidjzv','jvuogxkazzcxskrfqiexmwayhztqvzmbqwjuan',NULL,True,'AWID899355');
INSERT INTO "ortiscolastici"."persona" ("email","cognome","nome","ruolo","numerotelefono","referenteiniziativa","coinvolta") VALUES ('L.Phelps@kpn.net','kdczvukzqrdneaeieucygbuahvxjwcntuifbylinvmrrsutitf','ypnvhiifcpfllnyxnyeibqqazsrffbncmhzjdjtoxpzthhgrjg','gymqwvztjpkhmncfrqnqitngqlgmrtvcyahlqr','2493003198',True,'AWID899355');
INSERT INTO "ortiscolastici"."persona" ("email","cognome","nome","ruolo","numerotelefono","referenteiniziativa","coinvolta") VALUES ('Otto.Uitergeest5@aol.be','kfivhvtfydvfuwtiauogascagjmbxjwaffwfxgvfscwdgxitmu','rrektmqbovkaonkkocmlyegfvpgkpibuuiucyfgztwxcjojysh','wqxksbjwexnnoiwsdxijkrlzovqccptaxbiffq','9241743291',NULL,'UPJB481631');
INSERT INTO "ortiscolastici"."persona" ("email","cognome","nome","ruolo","numerotelefono","referenteiniziativa","coinvolta") VALUES ('RickMillikin4@gawab.org','ccfjbjkdfzatlsplflhbuiukslwfhvejneeakvsioftyliftry','iggvfpbeaskjctwtjaydrvtvwzhhidvilmrdmbpxcooptdrjkb','wufptupjhjoawyygughomvtltgxvdnbljltuqj','6275223280',False,'UPJB481631');
INSERT INTO "ortiscolastici"."persona" ("email","cognome","nome","ruolo","numerotelefono","referenteiniziativa","coinvolta") VALUES ('SjorsWaldo4@hotmail.org','wdydzeciyhnehpahksqpqamghrkjgxjybfwcjwcpxmtjrdayof','oihipbywsszklndfkiyjgtoskpxqewnxsipfxrgtkbsgpboixm','ebimpbpvjrcfqgukzngyngtkrykqprmtvvlnpw','3257534311',False,'UPJB481631');
INSERT INTO "ortiscolastici"."persona" ("email","cognome","nome","ruolo","numerotelefono","referenteiniziativa","coinvolta") VALUES ('Y.Mayberry4@freeweb.cn','bdjkfiuujvupfbvzkbpcdvanzlffshyfhhglafbbdtqpjimlap','vvbjhhwgsqulznjkwrnqqdkfumjwquymtnotcgadjrbfyctuxv','jvjkhemkjxwqudwvlgfubjcnhalozvqeazqukf',NULL,False,'FTBL698311');
INSERT INTO "ortiscolastici"."persona" ("email","cognome","nome","ruolo","numerotelefono","referenteiniziativa","coinvolta") VALUES ('FreddyDeans4@myspace.co.uk','prcjliaqergcuusnkvscxxcdbsmlfnxdrzdpbxrempaojrysyp','dpkbiaonxakwqdcguywzgdgxjhklhvgafmjftimpvmlnurzejn','koryvhtgoyxpxcovsclsdmrjflrxubthiaisfd','1012914658',True,NULL);



INSERT INTO "ortiscolastici"."classe" ("anno","sezione","codicemecc","ordine","tiposcuola","emaildocente") VALUES ('5','DJEAL','VNHY110520','Primaria','01E3uMYcWvGtp3WPhH0RS6x4DSqASIQocjkrehUTNv','Hank.Harness5@telefonica.co.uk');
INSERT INTO "ortiscolastici"."classe" ("anno","sezione","codicemecc","ordine","tiposcuola","emaildocente") VALUES ('3','JPKWK','SJQI629835','Primaria','TiPQME','Geoffry.Langham5@web.com');
INSERT INTO "ortiscolastici"."classe" ("anno","sezione","codicemecc","ordine","tiposcuola","emaildocente") VALUES ('4','HSROI','CIZO873018','Secondaria di primo grado','iDKw2wZsRr5gLgft0cNjBhrYSzbbkjydTjgpukHX5EjE17Fw','Geoffry.Langham5@web.com');
INSERT INTO "ortiscolastici"."classe" ("anno","sezione","codicemecc","ordine","tiposcuola","emaildocente") VALUES ('5','TULYG','GXZO042687','Secondaria di primo grado','vAz0UwS675iDk2TRkOIrG7ihV08n','Geoffry.Langham5@web.com');
INSERT INTO "ortiscolastici"."classe" ("anno","sezione","codicemecc","ordine","tiposcuola","emaildocente") VALUES ('1','ZYGHA','IQDT012762','Primaria','JWXasnyNcbHlmOThEz','PeterChwatal3@gmail.be');
INSERT INTO "ortiscolastici"."classe" ("anno","sezione","codicemecc","ordine","tiposcuola","emaildocente") VALUES ('5','FAMJI','MGCO209282','Secondaria di primo grado','xzGlwGDQNpeq72FjBRpYLGOLvFjZRI2xKFXJfpz8OKi','HansVoigt1@gawab.gov');
INSERT INTO "ortiscolastici"."classe" ("anno","sezione","codicemecc","ordine","tiposcuola","emaildocente") VALUES ('5','ECUBU','NEXF627033','Primaria','PM6icUdRXP7RhTS30ltNQmUlsxPMNI','PStockton4@myspace.com');
INSERT INTO "ortiscolastici"."classe" ("anno","sezione","codicemecc","ordine","tiposcuola","emaildocente") VALUES ('3','WOJTL','HQVY577395',NULL,'DOAcTUsX2xqsCYYWkrIW56JF3YPQ3kyXyhDtVzXWatuPt1j4Up2t','PStockton4@myspace.com');
INSERT INTO "ortiscolastici"."classe" ("anno","sezione","codicemecc","ordine","tiposcuola","emaildocente") VALUES ('5','NDSVL','DIGB587620','Primaria','0NgJMa0QfujCi6ELnON5fWj0V0dGRrJCabAoIt4MQQeEAlwxPKrZ','JWatson@live.com');
INSERT INTO "ortiscolastici"."classe" ("anno","sezione","codicemecc","ordine","tiposcuola","emaildocente") VALUES ('3','FJYXV','MGCO209282',NULL,'HbMd2Bbk8Emotl2CabkjtiR2lBsUtPEYzYVuxYjXl','JWatson@live.com');
INSERT INTO "ortiscolastici"."classe" ("anno","sezione","codicemecc","ordine","tiposcuola","emaildocente") VALUES ('1','UTBDW','HQVY577395','Primaria','at3rZt8OLMzKyPXqypZ7k2mWG','Johan.Comeau@gmail.org');
INSERT INTO "ortiscolastici"."classe" ("anno","sezione","codicemecc","ordine","tiposcuola","emaildocente") VALUES ('4','DPAIH','FTBL698311','Secondaria di primo grado','H','Johan.Comeau@gmail.org');
INSERT INTO "ortiscolastici"."classe" ("anno","sezione","codicemecc","ordine","tiposcuola","emaildocente") VALUES ('2','CKGIM','MGCO209282','Primaria',NULL,'Johan.Comeau@gmail.org');
INSERT INTO "ortiscolastici"."classe" ("anno","sezione","codicemecc","ordine","tiposcuola","emaildocente") VALUES ('3','RPPCF','NEXF627033','Primaria','K1rR7NkZdhFQFdrcw4DjdaM8YOsgJdysxxz3Gv','Dana.Pensec@excite.gov');
INSERT INTO "ortiscolastici"."classe" ("anno","sezione","codicemecc","ordine","tiposcuola","emaildocente") VALUES ('3','MTIKC','VCKC082963','Primaria',NULL,'Dana.Pensec@excite.gov');
INSERT INTO "ortiscolastici"."classe" ("anno","sezione","codicemecc","ordine","tiposcuola","emaildocente") VALUES ('1','ZCJDZ','EVMM088541','Secondaria di primo grado','2zMoUOlNdzYP3vRHjcIAfzmku','HansVoigt1@gawab.gov');
INSERT INTO "ortiscolastici"."classe" ("anno","sezione","codicemecc","ordine","tiposcuola","emaildocente") VALUES ('2','NBOUO','AWID899355','Secondaria di primo grado','bvCV3FnxsKGr5jgCgDLGjSKPs35c','HansVoigt1@gawab.gov');
INSERT INTO "ortiscolastici"."classe" ("anno","sezione","codicemecc","ordine","tiposcuola","emaildocente") VALUES ('3','FXACM','LATB225291','Secondaria di primo grado','q6tbBbhE7yFQrfMG8BG','HansVoigt1@gawab.gov');
INSERT INTO "ortiscolastici"."classe" ("anno","sezione","codicemecc","ordine","tiposcuola","emaildocente") VALUES ('4','FBLCL','IQDT012762',NULL,NULL,'Y.Harness@aol.be');
INSERT INTO "ortiscolastici"."classe" ("anno","sezione","codicemecc","ordine","tiposcuola","emaildocente") VALUES ('3','OYVOT','NEXF627033',NULL,'3B45pPFjsh5Wq','Richard.Knight@aol.dk');
INSERT INTO "ortiscolastici"."classe" ("anno","sezione","codicemecc","ordine","tiposcuola","emaildocente") VALUES ('4','ARBKV','VCKC082963','Primaria','cilpD67sV1gGrHy7R7F','Johan.Comeau@gmail.org');
INSERT INTO "ortiscolastici"."classe" ("anno","sezione","codicemecc","ordine","tiposcuola","emaildocente") VALUES ('2','CWAEM','WZPL379116','Secondaria di primo grado','fPtngu58bSZYDOT2k6NMJa','RickMillikin4@gawab.org');
INSERT INTO "ortiscolastici"."classe" ("anno","sezione","codicemecc","ordine","tiposcuola","emaildocente") VALUES ('2','VXUAG','LATB225291','Primaria','RFf62Omh1WsubPOPtrAw6sbHWuNpkdlUc76AO6xWsinUk2fSkW','RickMillikin4@gawab.org');
INSERT INTO "ortiscolastici"."classe" ("anno","sezione","codicemecc","ordine","tiposcuola","emaildocente") VALUES ('5','SLUVY','KINJ948332','Primaria','17uaQwVS7jfA','LindsyZapetis@telfort.es');
INSERT INTO "ortiscolastici"."classe" ("anno","sezione","codicemecc","ordine","tiposcuola","emaildocente") VALUES ('2','VMZYM','QHND731760','Secondaria di primo grado',NULL,'LindsyZapetis@telfort.es');
INSERT INTO "ortiscolastici"."classe" ("anno","sezione","codicemecc","ordine","tiposcuola","emaildocente") VALUES ('3','PMBQK','OXEM815286',NULL,'I','LindsyZapetis@telfort.es');
INSERT INTO "ortiscolastici"."classe" ("anno","sezione","codicemecc","ordine","tiposcuola","emaildocente") VALUES ('2','TYBHX','GEUW927079','Secondaria di primo grado','P16hnMqLxm2C3c7KR5nTnznnS8c6ONMF0RtaXMyxV40N','Richard.Knight@aol.dk');
INSERT INTO "ortiscolastici"."classe" ("anno","sezione","codicemecc","ordine","tiposcuola","emaildocente") VALUES ('2','DXHAL','VCKC082963','Primaria','lzSI','Richard.Knight@aol.dk');
INSERT INTO "ortiscolastici"."classe" ("anno","sezione","codicemecc","ordine","tiposcuola","emaildocente") VALUES ('3','RTYON','EVMM088541','Primaria','sBXrwqiDfyvmJhfSB5da','Richard.Knight@aol.dk');
INSERT INTO "ortiscolastici"."classe" ("anno","sezione","codicemecc","ordine","tiposcuola","emaildocente") VALUES ('5','CNYKG','VTKB006525','Secondaria di primo grado','K8fKMISpREeAAmzkCHkfDgUq8pFU1UHsaefO','L.Phelps@kpn.net');
INSERT INTO "ortiscolastici"."classe" ("anno","sezione","codicemecc","ordine","tiposcuola","emaildocente") VALUES ('2','GVYSG','YQRW022436',NULL,'d8Fc2dqTEUDXUWcICP36HWgys5C8rTUqoQlbDDlpt','L.Phelps@kpn.net');
INSERT INTO "ortiscolastici"."classe" ("anno","sezione","codicemecc","ordine","tiposcuola","emaildocente") VALUES ('3','NLZYZ','DLPF126711','Primaria','Dq25Tt76e8eh5tR','Y.Mayberry4@freeweb.cn');
INSERT INTO "ortiscolastici"."classe" ("anno","sezione","codicemecc","ordine","tiposcuola","emaildocente") VALUES ('3','TTVKG','PNXS039570','Primaria',NULL,'Y.Mayberry4@freeweb.cn');
INSERT INTO "ortiscolastici"."classe" ("anno","sezione","codicemecc","ordine","tiposcuola","emaildocente") VALUES ('5','JQYLB','EVMM088541',NULL,'4QKMAtNqvvqWqicRYL','Y.Mayberry4@freeweb.cn');
INSERT INTO "ortiscolastici"."classe" ("anno","sezione","codicemecc","ordine","tiposcuola","emaildocente") VALUES ('4','NHFMY','VTKB006525','Primaria',NULL,'HansVoigt1@gawab.gov');
INSERT INTO "ortiscolastici"."classe" ("anno","sezione","codicemecc","ordine","tiposcuola","emaildocente") VALUES ('1','NKMCR','JINL051845','Primaria','i6rzl4iWc','S.Langham@gawab.cc');
INSERT INTO "ortiscolastici"."classe" ("anno","sezione","codicemecc","ordine","tiposcuola","emaildocente") VALUES ('1','ZTHNJ','DLPF126711','Primaria','6b2p2WFgwLBYd1AHUZFNHrTYpu','Peter.Ostanik@kpn.it');
INSERT INTO "ortiscolastici"."classe" ("anno","sezione","codicemecc","ordine","tiposcuola","emaildocente") VALUES ('5','CJUXW','OXEM815286','Primaria','CdGEhKfS4','Peter.Ostanik@kpn.it');
INSERT INTO "ortiscolastici"."classe" ("anno","sezione","codicemecc","ordine","tiposcuola","emaildocente") VALUES ('1','GPIHF','YQRW022436',NULL,'1E16TdhOj4befeuwiIh','Peter.Ostanik@kpn.it');
INSERT INTO "ortiscolastici"."classe" ("anno","sezione","codicemecc","ordine","tiposcuola","emaildocente") VALUES ('1','HSXMK','HTLL701604','Primaria','OJKSq5CH','FreddyDeans4@myspace.co.uk');
INSERT INTO "ortiscolastici"."classe" ("anno","sezione","codicemecc","ordine","tiposcuola","emaildocente") VALUES ('3','PZMZA','HQVY577395',NULL,'liAAr3pdVidLIW437mIYL556VS7','FreddyDeans4@myspace.co.uk');
INSERT INTO "ortiscolastici"."classe" ("anno","sezione","codicemecc","ordine","tiposcuola","emaildocente") VALUES ('2','AMEWY','MQKH080804','Primaria',NULL,'FreddyDeans4@myspace.co.uk');
INSERT INTO "ortiscolastici"."classe" ("anno","sezione","codicemecc","ordine","tiposcuola","emaildocente") VALUES ('2','NBTFS','DIGB587620','Primaria',NULL,'Fons.Nithman5@lycos.us');
INSERT INTO "ortiscolastici"."classe" ("anno","sezione","codicemecc","ordine","tiposcuola","emaildocente") VALUES ('1','HWAMN','MGCO209282',NULL,'wDDdBra8GbGIrG16s','Fons.Nithman5@lycos.us');
INSERT INTO "ortiscolastici"."classe" ("anno","sezione","codicemecc","ordine","tiposcuola","emaildocente") VALUES ('3','JMXET','PNXS039570',NULL,NULL,'Fons.Nithman5@lycos.us');
INSERT INTO "ortiscolastici"."classe" ("anno","sezione","codicemecc","ordine","tiposcuola","emaildocente") VALUES ('2','GPXKA','QHND731760','Secondaria di primo grado','1R3VcB66Gn','L.Guyer@kpn.de');
INSERT INTO "ortiscolastici"."classe" ("anno","sezione","codicemecc","ordine","tiposcuola","emaildocente") VALUES ('5','ZNZLS','HQVY577395',NULL,'hlqqquTuFmWCVwXfAa16M5lDYTrawuRm6Iv4slWlRnmPahwhvIk','L.Guyer@kpn.de');
INSERT INTO "ortiscolastici"."classe" ("anno","sezione","codicemecc","ordine","tiposcuola","emaildocente") VALUES ('1','ZMGHT','UPJB481631','Secondaria di primo grado','nGecNRohQq61fP','L.Guyer@kpn.de');
INSERT INTO "ortiscolastici"."classe" ("anno","sezione","codicemecc","ordine","tiposcuola","emaildocente") VALUES ('2','BRUHT','FTBL698311','Secondaria di primo grado','vjA3DlF7KlpHbkWCbHxpI32DcivU7vUwwamREpG','JWatson@live.com');
INSERT INTO "ortiscolastici"."classe" ("anno","sezione","codicemecc","ordine","tiposcuola","emaildocente") VALUES ('1','LDMUA','PNXS039570','Primaria',NULL,'JWatson@live.com');



INSERT INTO "ortiscolastici"."specie" ("nomescientifico","nomecomune","esposizione") VALUES ('ttieffdeuqzdhorkbvuimjdljschpyorexaxqmbzffzcynlavq','lxatuhyjovxoeryswghdmfjvr','Mezzombra/sole');
INSERT INTO "ortiscolastici"."specie" ("nomescientifico","nomecomune","esposizione") VALUES ('bcylynrincfmnsutevgkzkrlkgcvfufxszlcqtsrnblratlzxd','gflblosgenxoicsswasbimdrp','Sole');
INSERT INTO "ortiscolastici"."specie" ("nomescientifico","nomecomune","esposizione") VALUES ('oenaocjvkzemmbvmuejdtmgmmggmyvkidqphujbtrmogkcyakr','ebncohdsttchflvnlvlbnezfb','Sole/mezzombra');
INSERT INTO "ortiscolastici"."specie" ("nomescientifico","nomecomune","esposizione") VALUES ('jxyejikwdhjlsbczqkajrxygqsaucsrnqvhzfidfdymusorjzp','yjxhfuqcdgkrzdbelfgdclcxb','Sole/mezzombra');
INSERT INTO "ortiscolastici"."specie" ("nomescientifico","nomecomune","esposizione") VALUES ('zioatqdxiilffeqtcliyfhupizjtbtqaexgzekfbrzslzdqlqo','abgosaiwkzwmzlnoeffcbcfxp','Sole/mezzombra');
INSERT INTO "ortiscolastici"."specie" ("nomescientifico","nomecomune","esposizione") VALUES ('isqcrvewxonypbajmvzszzhyihbmqwlskuuqblmyqmwnxxaxiu','bdypmijyduxszvyczqfwxjcyl','Ombra');
INSERT INTO "ortiscolastici"."specie" ("nomescientifico","nomecomune","esposizione") VALUES ('oxzdrefnllofygrtwmvnjibtncoehjmheqdfnaldlcufcrhcms','rpjbptffjhdazneimnaozftha',NULL);
INSERT INTO "ortiscolastici"."specie" ("nomescientifico","nomecomune","esposizione") VALUES ('qbxylxiscmkevppendypbynkdkrnqifvgsnfaicfjivktvkibw','bjhwtqshvcetkevtafgkrflvg','Sole/mezzombra');
INSERT INTO "ortiscolastici"."specie" ("nomescientifico","nomecomune","esposizione") VALUES ('kecmtgtxzyvvfhfpzayopxxopfkbqmvyfhigxerghfssilgkdg','hvqlhiitxafwmuyfichapgkfg','Mezzombra/sole');
INSERT INTO "ortiscolastici"."specie" ("nomescientifico","nomecomune","esposizione") VALUES ('rhwmddpqmchwrejaicnhhiltlsbfdpjqfgavzrprjynlptombr','dhnxnvyjuoddrywhznfltvkwa','Sole/mezzombra');
INSERT INTO "ortiscolastici"."specie" ("nomescientifico","nomecomune","esposizione") VALUES ('uamkvriqtnbacxcjmhklmqnyanjpslrbxeawuwzxcnozzyicft','cnoyckifgrtwwjbnjyhhtfemm',NULL);
INSERT INTO "ortiscolastici"."specie" ("nomescientifico","nomecomune","esposizione") VALUES ('zlhnmyaniafrafzsjteoqjicfmcvucgebmijvpfgxjeyzoqmwy','odeupicgwndnhcmipgefhtqvl','Ombra');
INSERT INTO "ortiscolastici"."specie" ("nomescientifico","nomecomune","esposizione") VALUES ('rwfiqoodqujdguyqlasaadtqbpniufkqvaqbzyeqhggkpbdmeu','tsfxbsvvhrvcilypgtuxvqlii','Ombra');
INSERT INTO "ortiscolastici"."specie" ("nomescientifico","nomecomune","esposizione") VALUES ('hqsqqpbdemhygsozmntheprxohyfxcalmsfqjjagzjicrhzwdy','tikxarztcojzpmcceszjyhlvh',NULL);
INSERT INTO "ortiscolastici"."specie" ("nomescientifico","nomecomune","esposizione") VALUES ('kjjbzwficpskfoszcujdbfysctpvdkyyfvisdvxiikutlzylky','djeplbtufurcyuauicipkbdgl',NULL);
INSERT INTO "ortiscolastici"."specie" ("nomescientifico","nomecomune","esposizione") VALUES ('nbkpxtycpgfdmnwearwraopunklozbirsivwruggzkpgtdeidy','crcpfbipdjuxtxntygmuyyalw','Sole/mezzombra');
INSERT INTO "ortiscolastici"."specie" ("nomescientifico","nomecomune","esposizione") VALUES ('osttfbvatbnypskvsimvxjzngiufqocxbhzndtrrivklnwwdty','wtydbminyopxkonxpxamqscmu','Mezzombra/sole');
INSERT INTO "ortiscolastici"."specie" ("nomescientifico","nomecomune","esposizione") VALUES ('kwkdinodjaorkfuveadubnydtbbhwmxrlcnqfrsaoehsqzjecy','ilhqpznahmerlosydfhhycunl','Mezzombra/sole');
INSERT INTO "ortiscolastici"."specie" ("nomescientifico","nomecomune","esposizione") VALUES ('aeqdtzfrdmyqsvetnniensnqzbokynwuqrvhqjcgcplgrogxxb','ibpxixhpfrdciptdsgofqhrpq',NULL);
INSERT INTO "ortiscolastici"."specie" ("nomescientifico","nomecomune","esposizione") VALUES ('bqxsbnnqjuzvlncxdixkaczzpvhkxslbduzqklpgxajkqlhtag','rvoqagivunnkpixjqaszngslf','Sole');
INSERT INTO "ortiscolastici"."specie" ("nomescientifico","nomecomune","esposizione") VALUES ('twududlgmtyvkzywhaoeynvgxgeeabuefusotkikkaqltqwuae','pxuocagpeqfhhssilvjybptlr','Sole');
INSERT INTO "ortiscolastici"."specie" ("nomescientifico","nomecomune","esposizione") VALUES ('rjenkolpccpbmfyqdviumpyeybugylgmimjdyfvggkvxduahge','yvryzdawqeobgibkfnlzdrpsp','Sole');
INSERT INTO "ortiscolastici"."specie" ("nomescientifico","nomecomune","esposizione") VALUES ('wtvwqpzdgrqyrowvznyarvcwutkliyubxcrirpvfqpykubcwyr','xdpounllekknqxtajjgobzvfb','Sole/mezzombra');
INSERT INTO "ortiscolastici"."specie" ("nomescientifico","nomecomune","esposizione") VALUES ('svgoonceqveyyzetqcabldxtmqdjticvkkpmdodvkvqsmtujbn','zhsdsfsqmsqbcfpccqpfaxswt','Sole/mezzombra');
INSERT INTO "ortiscolastici"."specie" ("nomescientifico","nomecomune","esposizione") VALUES ('puwexrvvodvsypcqhqsuecisvxlqbcgefzlrxiutjbtygkldfk','xrtshmgwujiibsuwmgfoiujvr','Sole/mezzombra');
INSERT INTO "ortiscolastici"."specie" ("nomescientifico","nomecomune","esposizione") VALUES ('cgbtjcxbojqjjjqchvrsegnjxszjlroigywaswqyarobrvshzu','cadyxchwwgvtlsjwwairkrqjf',NULL);
INSERT INTO "ortiscolastici"."specie" ("nomescientifico","nomecomune","esposizione") VALUES ('ohkokadkdwlvqgsuvrvyjbrgbngkncvkrunueeurbiojzucsda','fsmbmxxhgqoufmgbeizgjqiay',NULL);
INSERT INTO "ortiscolastici"."specie" ("nomescientifico","nomecomune","esposizione") VALUES ('bpnhguqfwvatqsfajouyciavrapbcmqrvtiwrdtdrcdtibprxg','zoymznlcdkubpmhcenuxixpdk','Sole');
INSERT INTO "ortiscolastici"."specie" ("nomescientifico","nomecomune","esposizione") VALUES ('lnhroaryestvptfwumcispuopijzxhkycuupmoisgolzwwqiis','chtmxkidluprlsirjfvdijmci','Ombra');
INSERT INTO "ortiscolastici"."specie" ("nomescientifico","nomecomune","esposizione") VALUES ('vmjsfafnpynyzikefgwshprufajkxiiikjfabbgcnnzgfilsto','mchrqibzfhjfctvfnqicszzoq','Sole/mezzombra');
INSERT INTO "ortiscolastici"."specie" ("nomescientifico","nomecomune","esposizione") VALUES ('enyxsxrezfyvpdfigmcmsspszahjdljlznxakkiewtepnzctaa','jbjszwoeyyonldvqnyedahmeq',NULL);
INSERT INTO "ortiscolastici"."specie" ("nomescientifico","nomecomune","esposizione") VALUES ('rxjuzlozhzjquaavkqcfjscztlvkglwzaulmxpwnrnlmoxbzeo','mzxayzjftoccrsqxkpikdesic','Ombra');
INSERT INTO "ortiscolastici"."specie" ("nomescientifico","nomecomune","esposizione") VALUES ('nsxqpllkntohjqjmjyuwolbknxtqheajekjzbpptmoladsjuxt','qaclhvisokicsxzuzazqicakf','Sole');
INSERT INTO "ortiscolastici"."specie" ("nomescientifico","nomecomune","esposizione") VALUES ('fdmyvobfoqplfqfhdvevkoccaskvzgbuhyhpwsehnrptfmeyzd','zzdpxovspwfmwyymfmfgagfhd','Ombra');
INSERT INTO "ortiscolastici"."specie" ("nomescientifico","nomecomune","esposizione") VALUES ('yyfhyqrtgvsjprairqmtnoynfwmcaqiynnjwnyrtsdhgxxpqhx','tayljqmefotxutlzydhcucovi',NULL);
INSERT INTO "ortiscolastici"."specie" ("nomescientifico","nomecomune","esposizione") VALUES ('xlynpxqwmituidetwuxaufhpwipdtwugmcecflsdanyojvktjp','ikkulaoyxscnubfzebggnizds','Sole');
INSERT INTO "ortiscolastici"."specie" ("nomescientifico","nomecomune","esposizione") VALUES ('vpbelwridygiurnciuzqftcrzztrvmzwxdjqdyshbobmtfrggp','dlvtlubkyvtoqinsijpxlglnz','Mezzombra/sole');
INSERT INTO "ortiscolastici"."specie" ("nomescientifico","nomecomune","esposizione") VALUES ('pyetctywcrwerdtsacvuxgjlldyihkabfuipqfznxrrjiaivff','vkyctavlnpsathuoxeaeqnhty','Mezzombra/sole');
INSERT INTO "ortiscolastici"."specie" ("nomescientifico","nomecomune","esposizione") VALUES ('ffzipmvgeqbbbpeiclbtamulmuehtocrkrpvgxoxypudmdcjew','busqfzwynrflxicdyjohsehmw',NULL);
INSERT INTO "ortiscolastici"."specie" ("nomescientifico","nomecomune","esposizione") VALUES ('yppfgucmacspnekpqqxbrcldcapjdrgwffllzpmeerizbzqswm','xiwgdkeeebkjflehpgsglxpai',NULL);
INSERT INTO "ortiscolastici"."specie" ("nomescientifico","nomecomune","esposizione") VALUES ('baoiilrarqtcyyfpcliykjnefbsjmxakkbdzbhacygdnrtyzty','cjscgmyglkjodwggnhjujxyhu','Mezzombra/sole');
INSERT INTO "ortiscolastici"."specie" ("nomescientifico","nomecomune","esposizione") VALUES ('wzbzdjbqkjfxjetwxtnjyzfdfersfptizalypxvdnxhviibckm','qzthqegapuzziybioqtqupkrc','Sole/mezzombra');
INSERT INTO "ortiscolastici"."specie" ("nomescientifico","nomecomune","esposizione") VALUES ('wwgitipojdacfkuldafmsqtcdljrqazeyrzjbzlekobmzxuvks','brkrglelzmrujjjwnhrjkpejf','Sole/mezzombra');
INSERT INTO "ortiscolastici"."specie" ("nomescientifico","nomecomune","esposizione") VALUES ('yikgcroftklykhnfxihprflkovfchjmynhhoivugvkicbgtdtu','tdwnpruhdpymflzhraqlammfo','Sole/mezzombra');
INSERT INTO "ortiscolastici"."specie" ("nomescientifico","nomecomune","esposizione") VALUES ('pqzyohwmfjnevzvinolnvcyfuwnfcopxiwpodypofssgaymjts','efotulmtpdvytdqiggvukmipk','Sole/mezzombra');
INSERT INTO "ortiscolastici"."specie" ("nomescientifico","nomecomune","esposizione") VALUES ('snbbwyebzebshwrldyfzzejvqaynbjilojjlxgmbesbqchbeto','jembcrcmlktqxassolsewzzwl',NULL);
INSERT INTO "ortiscolastici"."specie" ("nomescientifico","nomecomune","esposizione") VALUES ('tayazmdehpyaqndjrdauxpudqqbeplcwlzxxiygugwpknbmcfa','jfnnjnnblxdiytilpwihogeqg',NULL);
INSERT INTO "ortiscolastici"."specie" ("nomescientifico","nomecomune","esposizione") VALUES ('mgwozqwrvajhxkocxvwkgtbxvaeakgludkbwrsdlypuipftgva','wxcndygoqleuohvermjgxhwyo','Mezzombra/sole');
INSERT INTO "ortiscolastici"."specie" ("nomescientifico","nomecomune","esposizione") VALUES ('maoaeijufiudluxpejnfzznqemvmckxznxvwrtpzokgyflazas','ivjtccjuyehmjgjkqfxgqmgtf','Sole');
INSERT INTO "ortiscolastici"."specie" ("nomescientifico","nomecomune","esposizione") VALUES ('ixzzubpvrapfbtwjckigrvsdkgaoarybxkieetsgcplqscqfjw','rgvjhjrqtdryuyxrpzxzjncsl',NULL);



INSERT INTO "ortiscolastici"."pianta" ("id","numeroreplica","data","esposizionespec","nomescientifico","nome","scuoladiriferimento","scuoladiappartenenza","anno","sezione","idg") VALUES (1,1,'02.03.2002','Sole/mezzombra','ttieffdeuqzdhorkbvuimjdljschpyorexaxqmbzffzcynlavq','N1ZTEcuiLYhodtH6ZGyRQa0Qk','VNHY110520','VNHY110520','5','DJEAL',1);
INSERT INTO "ortiscolastici"."pianta" ("id","numeroreplica","data","esposizionespec","nomescientifico","nome","scuoladiriferimento","scuoladiappartenenza","anno","sezione","idg") VALUES (2,2,'19.11.2015','Sole','uamkvriqtnbacxcjmhklmqnyanjpslrbxeawuwzxcnozzyicft','rhs3FGFSpu','NEXF627033','SJQI629835','3','JPKWK',1);
INSERT INTO "ortiscolastici"."pianta" ("id","numeroreplica","data","esposizionespec","nomescientifico","nome","scuoladiriferimento","scuoladiappartenenza","anno","sezione","idg") VALUES (3,3,'31.07.2018','Sole','uamkvriqtnbacxcjmhklmqnyanjpslrbxeawuwzxcnozzyicft','rhs3FGFSpu','NEXF627033','MGCO209282','5','FAMJI',1);
INSERT INTO "ortiscolastici"."pianta" ("id","numeroreplica","data","esposizionespec","nomescientifico","nome","scuoladiriferimento","scuoladiappartenenza","anno","sezione","idg") VALUES (4,4,'29.01.2020','Sole/mezzombra','uamkvriqtnbacxcjmhklmqnyanjpslrbxeawuwzxcnozzyicft','D6IobJETwYiF4oWZUiOD','NEXF627033','MGCO209282','3','FJYXV',9);
INSERT INTO "ortiscolastici"."pianta" ("id","numeroreplica","data","esposizionespec","nomescientifico","nome","scuoladiriferimento","scuoladiappartenenza","anno","sezione","idg") VALUES (5,5,'31.01.2012','Sole/mezzombra','osttfbvatbnypskvsimvxjzngiufqocxbhzndtrrivklnwwdty','D6IobJETwYiF4oWZUiOD','NEXF627033','LATB225291','3','FXACM',9);
INSERT INTO "ortiscolastici"."pianta" ("id","numeroreplica","data","esposizionespec","nomescientifico","nome","scuoladiriferimento","scuoladiappartenenza","anno","sezione","idg") VALUES (6,6,'19.11.2008','Ombra','osttfbvatbnypskvsimvxjzngiufqocxbhzndtrrivklnwwdty','TG','AWID899355','LATB225291','3','FXACM',16);
INSERT INTO "ortiscolastici"."pianta" ("id","numeroreplica","data","esposizionespec","nomescientifico","nome","scuoladiriferimento","scuoladiappartenenza","anno","sezione","idg") VALUES (7,7,'13.12.2009','Ombra','aeqdtzfrdmyqsvetnniensnqzbokynwuqrvhqjcgcplgrogxxb','TG','AWID899355','QHND731760','2','VMZYM',23);
INSERT INTO "ortiscolastici"."pianta" ("id","numeroreplica","data","esposizionespec","nomescientifico","nome","scuoladiriferimento","scuoladiappartenenza","anno","sezione","idg") VALUES (8,8,'10.07.2004','Mezzombra/sole','bqxsbnnqjuzvlncxdixkaczzpvhkxslbduzqklpgxajkqlhtag','TG','AWID899355','EVMM088541','3','RTYON',27);
INSERT INTO "ortiscolastici"."pianta" ("id","numeroreplica","data","esposizionespec","nomescientifico","nome","scuoladiriferimento","scuoladiappartenenza","anno","sezione","idg") VALUES (9,9,'28.02.2007','Mezzombra/sole','svgoonceqveyyzetqcabldxtmqdjticvkkpmdodvkvqsmtujbn','NpJmYdBXRUyi5','QHND731760','VTKB006525','4','NHFMY',36);
INSERT INTO "ortiscolastici"."pianta" ("id","numeroreplica","data","esposizionespec","nomescientifico","nome","scuoladiriferimento","scuoladiappartenenza","anno","sezione","idg") VALUES (10,10,'04.03.2023','Sole','svgoonceqveyyzetqcabldxtmqdjticvkkpmdodvkvqsmtujbn','NpJmYdBXRUyi5','QHND731760','VTKB006525','4','NHFMY',44);
INSERT INTO "ortiscolastici"."pianta" ("id","numeroreplica","data","esposizionespec","nomescientifico","nome","scuoladiriferimento","scuoladiappartenenza","anno","sezione","idg") VALUES (11,11,'14.07.2020','Sole','svgoonceqveyyzetqcabldxtmqdjticvkkpmdodvkvqsmtujbn','NpJmYdBXRUyi5','QHND731760','HTLL701604','1','HSXMK',44);
INSERT INTO "ortiscolastici"."pianta" ("id","numeroreplica","data","esposizionespec","nomescientifico","nome","scuoladiriferimento","scuoladiappartenenza","anno","sezione","idg") VALUES (12,12,'18.01.2018','Sole','ohkokadkdwlvqgsuvrvyjbrgbngkncvkrunueeurbiojzucsda','ykpJStkj','LATB225291','FTBL698311','2','BRUHT',27);
INSERT INTO "ortiscolastici"."pianta" ("id","numeroreplica","data","esposizionespec","nomescientifico","nome","scuoladiriferimento","scuoladiappartenenza","anno","sezione","idg") VALUES (13,13,'29.11.2011','Sole','ohkokadkdwlvqgsuvrvyjbrgbngkncvkrunueeurbiojzucsda','ykpJStkj','LATB225291','FTBL698311','2','BRUHT',30);
INSERT INTO "ortiscolastici"."pianta" ("id","numeroreplica","data","esposizionespec","nomescientifico","nome","scuoladiriferimento","scuoladiappartenenza","anno","sezione","idg") VALUES (14,14,'19.07.2009','Sole/mezzombra','enyxsxrezfyvpdfigmcmsspszahjdljlznxakkiewtepnzctaa','CPgc','EVMM088541','VCKC082963','2','DXHAL',32);
INSERT INTO "ortiscolastici"."pianta" ("id","numeroreplica","data","esposizionespec","nomescientifico","nome","scuoladiriferimento","scuoladiappartenenza","anno","sezione","idg") VALUES (15,15,'13.01.2017','Sole','enyxsxrezfyvpdfigmcmsspszahjdljlznxakkiewtepnzctaa','3UsMqvuz4URf2vXSLH','LATB225291','VCKC082963','2','DXHAL',35);
INSERT INTO "ortiscolastici"."pianta" ("id","numeroreplica","data","esposizionespec","nomescientifico","nome","scuoladiriferimento","scuoladiappartenenza","anno","sezione","idg") VALUES (16,16,'05.06.2005','Sole/mezzombra','enyxsxrezfyvpdfigmcmsspszahjdljlznxakkiewtepnzctaa','3UsMqvuz4URf2vXSLH','LATB225291','VCKC082963','2','DXHAL',35);
INSERT INTO "ortiscolastici"."pianta" ("id","numeroreplica","data","esposizionespec","nomescientifico","nome","scuoladiriferimento","scuoladiappartenenza","anno","sezione","idg") VALUES (17,17,'09.02.2020','Ombra','xlynpxqwmituidetwuxaufhpwipdtwugmcecflsdanyojvktjp','3UsMqvuz4URf2vXSLH','LATB225291','EVMM088541','3','RTYON',35);
INSERT INTO "ortiscolastici"."pianta" ("id","numeroreplica","data","esposizionespec","nomescientifico","nome","scuoladiriferimento","scuoladiappartenenza","anno","sezione","idg") VALUES (18,18,'15.01.2007','Sole','xlynpxqwmituidetwuxaufhpwipdtwugmcecflsdanyojvktjp','NpJmYdBXRUyi5','QHND731760','EVMM088541','3','RTYON',44);
INSERT INTO "ortiscolastici"."pianta" ("id","numeroreplica","data","esposizionespec","nomescientifico","nome","scuoladiriferimento","scuoladiappartenenza","anno","sezione","idg") VALUES (19,19,'15.02.2015','Ombra','pqzyohwmfjnevzvinolnvcyfuwnfcopxiwpodypofssgaymjts','NpJmYdBXRUyi5','QHND731760','OXEM815286','5','CJUXW',44);
INSERT INTO "ortiscolastici"."pianta" ("id","numeroreplica","data","esposizionespec","nomescientifico","nome","scuoladiriferimento","scuoladiappartenenza","anno","sezione","idg") VALUES (20,20,'05.05.2001','Sole/mezzombra','pqzyohwmfjnevzvinolnvcyfuwnfcopxiwpodypofssgaymjts','weIJAKRu','HTLL701604','HQVY577395','5','ZNZLS',45);
INSERT INTO "ortiscolastici"."pianta" ("id","numeroreplica","data","esposizionespec","nomescientifico","nome","scuoladiriferimento","scuoladiappartenenza","anno","sezione","idg") VALUES (21,21,'25.11.2002','Mezzombra/sole','ohkokadkdwlvqgsuvrvyjbrgbngkncvkrunueeurbiojzucsda','q030THX72JBK5Sn0','EVMM088541','HQVY577395','5','ZNZLS',45);
INSERT INTO "ortiscolastici"."pianta" ("id","numeroreplica","data","esposizionespec","nomescientifico","nome","scuoladiriferimento","scuoladiappartenenza","anno","sezione","idg") VALUES (22,22,'25.08.2010','Mezzombra/sole','rxjuzlozhzjquaavkqcfjscztlvkglwzaulmxpwnrnlmoxbzeo','q030THX72JBK5Sn0','EVMM088541','HQVY577395','5','ZNZLS',28);
INSERT INTO "ortiscolastici"."pianta" ("id","numeroreplica","data","esposizionespec","nomescientifico","nome","scuoladiriferimento","scuoladiappartenenza","anno","sezione","idg") VALUES (23,23,'03.04.2023','Sole/mezzombra','rxjuzlozhzjquaavkqcfjscztlvkglwzaulmxpwnrnlmoxbzeo','q030THX72JBK5Sn0','EVMM088541','UPJB481631','1','ZMGHT',30);
INSERT INTO "ortiscolastici"."pianta" ("id","numeroreplica","data","esposizionespec","nomescientifico","nome","scuoladiriferimento","scuoladiappartenenza","anno","sezione","idg") VALUES (24,24,'26.05.2020','Sole','rxjuzlozhzjquaavkqcfjscztlvkglwzaulmxpwnrnlmoxbzeo','sRAIwET75U33H','LBPD395491','UPJB481631','1','ZMGHT',30);
INSERT INTO "ortiscolastici"."pianta" ("id","numeroreplica","data","esposizionespec","nomescientifico","nome","scuoladiriferimento","scuoladiappartenenza","anno","sezione","idg") VALUES (25,25,'11.07.2020','Mezzombra/sole','xlynpxqwmituidetwuxaufhpwipdtwugmcecflsdanyojvktjp','bKxsdwajIspU','KINJ948332','UPJB481631','1','ZMGHT',30);
INSERT INTO "ortiscolastici"."pianta" ("id","numeroreplica","data","esposizionespec","nomescientifico","nome","scuoladiriferimento","scuoladiappartenenza","anno","sezione","idg") VALUES (26,26,'13.10.2006','Sole/mezzombra','vpbelwridygiurnciuzqftcrzztrvmzwxdjqdyshbobmtfrggp','bKxsdwajIspU','KINJ948332','DLPF126711','3','NLZYZ',37);
INSERT INTO "ortiscolastici"."pianta" ("id","numeroreplica","data","esposizionespec","nomescientifico","nome","scuoladiriferimento","scuoladiappartenenza","anno","sezione","idg") VALUES (27,27,'20.09.2011','Ombra','ffzipmvgeqbbbpeiclbtamulmuehtocrkrpvgxoxypudmdcjew','j','OXEM815286','DLPF126711','3','NLZYZ',37);
INSERT INTO "ortiscolastici"."pianta" ("id","numeroreplica","data","esposizionespec","nomescientifico","nome","scuoladiriferimento","scuoladiappartenenza","anno","sezione","idg") VALUES (28,28,'21.08.2006','Sole/mezzombra','ffzipmvgeqbbbpeiclbtamulmuehtocrkrpvgxoxypudmdcjew','j','OXEM815286','VTKB006525','4','NHFMY',37);
INSERT INTO "ortiscolastici"."pianta" ("id","numeroreplica","data","esposizionespec","nomescientifico","nome","scuoladiriferimento","scuoladiappartenenza","anno","sezione","idg") VALUES (29,29,'14.10.2007','Sole','ffzipmvgeqbbbpeiclbtamulmuehtocrkrpvgxoxypudmdcjew','weIJAKRu','HTLL701604','VTKB006525','4','NHFMY',46);
INSERT INTO "ortiscolastici"."pianta" ("id","numeroreplica","data","esposizionespec","nomescientifico","nome","scuoladiriferimento","scuoladiappartenenza","anno","sezione","idg") VALUES (30,30,'18.10.2020','Mezzombra/sole','pqzyohwmfjnevzvinolnvcyfuwnfcopxiwpodypofssgaymjts','weIJAKRu','HTLL701604','VTKB006525','4','NHFMY',31);
INSERT INTO "ortiscolastici"."pianta" ("id","numeroreplica","data","esposizionespec","nomescientifico","nome","scuoladiriferimento","scuoladiappartenenza","anno","sezione","idg") VALUES (31,31,'04.07.2001','Sole/mezzombra','pqzyohwmfjnevzvinolnvcyfuwnfcopxiwpodypofssgaymjts','weIJAKRu','HTLL701604','HQVY577395','3','PZMZA',35);
INSERT INTO "ortiscolastici"."pianta" ("id","numeroreplica","data","esposizionespec","nomescientifico","nome","scuoladiriferimento","scuoladiappartenenza","anno","sezione","idg") VALUES (32,32,'05.09.2006','Ombra','bpnhguqfwvatqsfajouyciavrapbcmqrvtiwrdtdrcdtibprxg','y1THzVHr','NXVI522896','HQVY577395','3','PZMZA',41);
INSERT INTO "ortiscolastici"."pianta" ("id","numeroreplica","data","esposizionespec","nomescientifico","nome","scuoladiriferimento","scuoladiappartenenza","anno","sezione","idg") VALUES (33,33,'11.09.2015','Ombra','bpnhguqfwvatqsfajouyciavrapbcmqrvtiwrdtdrcdtibprxg','y1THzVHr','NXVI522896','PNXS039570','1','LDMUA',46);
INSERT INTO "ortiscolastici"."pianta" ("id","numeroreplica","data","esposizionespec","nomescientifico","nome","scuoladiriferimento","scuoladiappartenenza","anno","sezione","idg") VALUES (34,34,'27.01.2000','Sole','nsxqpllkntohjqjmjyuwolbknxtqheajekjzbpptmoladsjuxt','JtHVutB2PNLJ','LATB225291','PNXS039570','1','LDMUA',30);
INSERT INTO "ortiscolastici"."pianta" ("id","numeroreplica","data","esposizionespec","nomescientifico","nome","scuoladiriferimento","scuoladiappartenenza","anno","sezione","idg") VALUES (35,35,'22.09.2016','Sole','ffzipmvgeqbbbpeiclbtamulmuehtocrkrpvgxoxypudmdcjew','JtHVutB2PNLJ','LATB225291','PNXS039570','1','LDMUA',30);
INSERT INTO "ortiscolastici"."pianta" ("id","numeroreplica","data","esposizionespec","nomescientifico","nome","scuoladiriferimento","scuoladiappartenenza","anno","sezione","idg") VALUES (36,36,'08.09.2020','Sole/mezzombra','ffzipmvgeqbbbpeiclbtamulmuehtocrkrpvgxoxypudmdcjew','JtHVutB2PNLJ','LATB225291','YQRW022436','2','GVYSG',30);
INSERT INTO "ortiscolastici"."pianta" ("id","numeroreplica","data","esposizionespec","nomescientifico","nome","scuoladiriferimento","scuoladiappartenenza","anno","sezione","idg") VALUES (37,37,'14.02.2005','Sole','yppfgucmacspnekpqqxbrcldcapjdrgwffllzpmeerizbzqswm','fBaJwplSeBMYH38tos','JINL051845','YQRW022436','2','GVYSG',33);
INSERT INTO "ortiscolastici"."pianta" ("id","numeroreplica","data","esposizionespec","nomescientifico","nome","scuoladiriferimento","scuoladiappartenenza","anno","sezione","idg") VALUES (38,38,'22.12.2016','Ombra','yppfgucmacspnekpqqxbrcldcapjdrgwffllzpmeerizbzqswm','fBaJwplSeBMYH38tos','JINL051845','DLPF126711','3','NLZYZ',33);
INSERT INTO "ortiscolastici"."pianta" ("id","numeroreplica","data","esposizionespec","nomescientifico","nome","scuoladiriferimento","scuoladiappartenenza","anno","sezione","idg") VALUES (39,39,'23.06.2004','Ombra','snbbwyebzebshwrldyfzzejvqaynbjilojjlxgmbesbqchbeto','fBaJwplSeBMYH38tos','JINL051845','DLPF126711','3','NLZYZ',43);
INSERT INTO "ortiscolastici"."pianta" ("id","numeroreplica","data","esposizionespec","nomescientifico","nome","scuoladiriferimento","scuoladiappartenenza","anno","sezione","idg") VALUES (40,40,'20.09.2007','Ombra','snbbwyebzebshwrldyfzzejvqaynbjilojjlxgmbesbqchbeto','3UsMqvuz4URf2vXSLH','LATB225291','JINL051845','1','NKMCR',43);
INSERT INTO "ortiscolastici"."pianta" ("id","numeroreplica","data","esposizionespec","nomescientifico","nome","scuoladiriferimento","scuoladiappartenenza","anno","sezione","idg") VALUES (41,41,'25.08.2008','Sole/mezzombra','snbbwyebzebshwrldyfzzejvqaynbjilojjlxgmbesbqchbeto','uFcQPzrPfR','KINJ948332','OXEM815286','5','CJUXW',47);
INSERT INTO "ortiscolastici"."pianta" ("id","numeroreplica","data","esposizionespec","nomescientifico","nome","scuoladiriferimento","scuoladiappartenenza","anno","sezione","idg") VALUES (42,42,'05.03.2011','Mezzombra/sole','bpnhguqfwvatqsfajouyciavrapbcmqrvtiwrdtdrcdtibprxg','sujChvJd0','KINJ948332','OXEM815286','5','CJUXW',47);
INSERT INTO "ortiscolastici"."pianta" ("id","numeroreplica","data","esposizionespec","nomescientifico","nome","scuoladiriferimento","scuoladiappartenenza","anno","sezione","idg") VALUES (43,43,'22.06.2007','Sole','bpnhguqfwvatqsfajouyciavrapbcmqrvtiwrdtdrcdtibprxg','weIJAKRu','HTLL701604','HTLL701604','1','HSXMK',47);
INSERT INTO "ortiscolastici"."pianta" ("id","numeroreplica","data","esposizionespec","nomescientifico","nome","scuoladiriferimento","scuoladiappartenenza","anno","sezione","idg") VALUES (44,44,'02.10.2018','Sole','bpnhguqfwvatqsfajouyciavrapbcmqrvtiwrdtdrcdtibprxg','pUaGTG1m','MGCO209282','UPJB481631','1','ZMGHT',28);
INSERT INTO "ortiscolastici"."pianta" ("id","numeroreplica","data","esposizionespec","nomescientifico","nome","scuoladiriferimento","scuoladiappartenenza","anno","sezione","idg") VALUES (45,45,'09.03.2018','Mezzombra/sole','yyfhyqrtgvsjprairqmtnoynfwmcaqiynnjwnyrtsdhgxxpqhx','pUaGTG1m','MGCO209282','UPJB481631','1','ZMGHT',31);
INSERT INTO "ortiscolastici"."pianta" ("id","numeroreplica","data","esposizionespec","nomescientifico","nome","scuoladiriferimento","scuoladiappartenenza","anno","sezione","idg") VALUES (46,46,'04.07.2021','Mezzombra/sole','yyfhyqrtgvsjprairqmtnoynfwmcaqiynnjwnyrtsdhgxxpqhx','NpJmYdBXRUyi5','QHND731760','UPJB481631','1','ZMGHT',34);
INSERT INTO "ortiscolastici"."pianta" ("id","numeroreplica","data","esposizionespec","nomescientifico","nome","scuoladiriferimento","scuoladiappartenenza","anno","sezione","idg") VALUES (47,47,'10.02.2010','Ombra','yyfhyqrtgvsjprairqmtnoynfwmcaqiynnjwnyrtsdhgxxpqhx','NpJmYdBXRUyi5','QHND731760','FTBL698311','2','BRUHT',34);
INSERT INTO "ortiscolastici"."pianta" ("id","numeroreplica","data","esposizionespec","nomescientifico","nome","scuoladiriferimento","scuoladiappartenenza","anno","sezione","idg") VALUES (48,48,'15.12.2007','Ombra','ffzipmvgeqbbbpeiclbtamulmuehtocrkrpvgxoxypudmdcjew','S','VTKB006525','FTBL698311','2','BRUHT',42);
INSERT INTO "ortiscolastici"."pianta" ("id","numeroreplica","data","esposizionespec","nomescientifico","nome","scuoladiriferimento","scuoladiappartenenza","anno","sezione","idg") VALUES (49,49,'15.08.2004','Sole','wwgitipojdacfkuldafmsqtcdljrqazeyrzjbzlekobmzxuvks','S','VTKB006525','DLPF126711','3','NLZYZ',42);
INSERT INTO "ortiscolastici"."pianta" ("id","numeroreplica","data","esposizionespec","nomescientifico","nome","scuoladiriferimento","scuoladiappartenenza","anno","sezione","idg") VALUES (50,50,'23.06.2005','Sole/mezzombra','pqzyohwmfjnevzvinolnvcyfuwnfcopxiwpodypofssgaymjts','S','VTKB006525','HTLL701604','1','HSXMK',44);


INSERT INTO "ortiscolastici"."raccoltadati" ("dataorarilevazione","id","numeroreplica","dataorainserimento","larghezzachiomafoglie_cm","lunghezzachiomafoglie_cm","pesofrescochiomafoglie_g","pesoseccochiomafoglie_g","altezzapianta_cm","lunghezzaradicei_cm","pesofrescoradici_g","pesoseccoradici_g","numerofiori","numerofrutti","numerodifogliedanneggiate","percsuperficiedanneggiataperfoglia","ph","umidità","temperatura","emailresponsabilerilev","emailresponsabileins","annoril","sezioneril","codicemeccril","annoins","sezioneins","codicemeccins") VALUES ('09.09.2004 05:55:00 p9',1,1,'09.21.2005 08:41:00 p9',20.71,1.34,14.34,NULL,772.71,NULL,5.67,9.77,15405,7714,5794,16.99,4.2,4.3,0.3,NULL,'Hank.Harness5@telefonica.co.uk',NULL,'DJEAL','VNHY110520','5','DJEAL','VNHY110520');
INSERT INTO "ortiscolastici"."raccoltadati" ("dataorarilevazione","id","numeroreplica","dataorainserimento","larghezzachiomafoglie_cm","lunghezzachiomafoglie_cm","pesofrescochiomafoglie_g","pesoseccochiomafoglie_g","altezzapianta_cm","lunghezzaradicei_cm","pesofrescoradici_g","pesoseccoradici_g","numerofiori","numerofrutti","numerodifogliedanneggiate","percsuperficiedanneggiataperfoglia","ph","umidità","temperatura","emailresponsabilerilev","emailresponsabileins","annoril","sezioneril","codicemeccril","annoins","sezioneins","codicemeccins") VALUES ('11.30.2010 08:11:00 p11',7,7,'09.15.2019 08:34:00 p9',7.82,8.42,668.1,833.22,413.61,1.32,877.92,841.53,7637,11010,1751,0.4,4.8,0.53,73.5,'Hank.Harness5@telefonica.co.uk','Hank.Harness5@telefonica.co.uk','5','DJEAL','VNHY110520',NULL,'DJEAL','VNHY110520');
INSERT INTO "ortiscolastici"."raccoltadati" ("dataorarilevazione","id","numeroreplica","dataorainserimento","larghezzachiomafoglie_cm","lunghezzachiomafoglie_cm","pesofrescochiomafoglie_g","pesoseccochiomafoglie_g","altezzapianta_cm","lunghezzaradicei_cm","pesofrescoradici_g","pesoseccoradici_g","numerofiori","numerofrutti","numerodifogliedanneggiate","percsuperficiedanneggiataperfoglia","ph","umidità","temperatura","emailresponsabilerilev","emailresponsabileins","annoril","sezioneril","codicemeccril","annoins","sezioneins","codicemeccins") VALUES ('03.07.2012 00:57:00 p3',10,10,'06.21.2001 04:40:00 p6',35.36,3.06,4.4,368.21,12.86,81.44,3.77,40.92,21108,28687,31849,6.87,9,92.87,8.2,'AnnBrown@gawab.dk','AnnBrown@gawab.dk','1','UTBDW','HQVY577395','1',NULL,NULL);
INSERT INTO "ortiscolastici"."raccoltadati" ("dataorarilevazione","id","numeroreplica","dataorainserimento","larghezzachiomafoglie_cm","lunghezzachiomafoglie_cm","pesofrescochiomafoglie_g","pesoseccochiomafoglie_g","altezzapianta_cm","lunghezzaradicei_cm","pesofrescoradici_g","pesoseccoradici_g","numerofiori","numerofrutti","numerodifogliedanneggiate","percsuperficiedanneggiataperfoglia","ph","umidità","temperatura","emailresponsabilerilev","emailresponsabileins","annoril","sezioneril","codicemeccril","annoins","sezioneins","codicemeccins") VALUES ('08.19.2016 10:36:00 p8',14,14,'03.12.2008 02:32:00 p3',7.25,323.31,NULL,NULL,523.21,7.06,62.5,NULL,1124,16767,8818,42.36,0.9,0.61,0.5,'AnnBrown@gawab.dk','AnnBrown@gawab.dk','1','UTBDW','HQVY577395','1','UTBDW','HQVY577395');
INSERT INTO "ortiscolastici"."raccoltadati" ("dataorarilevazione","id","numeroreplica","dataorainserimento","larghezzachiomafoglie_cm","lunghezzachiomafoglie_cm","pesofrescochiomafoglie_g","pesoseccochiomafoglie_g","altezzapianta_cm","lunghezzaradicei_cm","pesofrescoradici_g","pesoseccoradici_g","numerofiori","numerofrutti","numerodifogliedanneggiate","percsuperficiedanneggiataperfoglia","ph","umidità","temperatura","emailresponsabilerilev","emailresponsabileins","annoril","sezioneril","codicemeccril","annoins","sezioneins","codicemeccins") VALUES ('12.25.2010 06:55:00 p12',16,16,'07.07.2014 08:17:00 p7',740.74,2.34,2.19,728.27,779.17,862.11,12.43,5.78,26963,7305,4212,0.6,6.3,89.29,8.7,'Leon.Baltec1@mymail.cn','Leon.Baltec1@mymail.cn','4','ARBKV','VCKC082963',NULL,'ARBKV','VCKC082963');
INSERT INTO "ortiscolastici"."raccoltadati" ("dataorarilevazione","id","numeroreplica","dataorainserimento","larghezzachiomafoglie_cm","lunghezzachiomafoglie_cm","pesofrescochiomafoglie_g","pesoseccochiomafoglie_g","altezzapianta_cm","lunghezzaradicei_cm","pesofrescoradici_g","pesoseccoradici_g","numerofiori","numerofrutti","numerodifogliedanneggiate","percsuperficiedanneggiataperfoglia","ph","umidità","temperatura","emailresponsabilerilev","emailresponsabileins","annoril","sezioneril","codicemeccril","annoins","sezioneins","codicemeccins") VALUES ('11.23.2019 02:46:00 p11',22,22,'05.27.2007 00:49:00 p5',437.32,26.05,860.62,22.37,566.6,NULL,5.78,7.67,17804,2133,19985,62.6,0.7,0.58,5.8,'Leon.Baltec1@mymail.cn','Leon.Baltec1@mymail.cn','4','ARBKV','VCKC082963','4','ARBKV','VCKC082963');
INSERT INTO "ortiscolastici"."raccoltadati" ("dataorarilevazione","id","numeroreplica","dataorainserimento","larghezzachiomafoglie_cm","lunghezzachiomafoglie_cm","pesofrescochiomafoglie_g","pesoseccochiomafoglie_g","altezzapianta_cm","lunghezzaradicei_cm","pesofrescoradici_g","pesoseccoradici_g","numerofiori","numerofrutti","numerodifogliedanneggiate","percsuperficiedanneggiataperfoglia","ph","umidità","temperatura","emailresponsabilerilev","emailresponsabileins","annoril","sezioneril","codicemeccril","annoins","sezioneins","codicemeccins") VALUES ('10.07.2009 07:33:00 p10',23,23,'01.25.2005 03:40:00 p1',87.04,41.63,1.07,83.6,2.57,200.76,NULL,NULL,24353,15875,6762,0.47,0.7,0.4,22.9,NULL,'Leon.Baltec1@mymail.cn','5','CNYKG','VTKB006525',NULL,NULL,'VTKB006525');
INSERT INTO "ortiscolastici"."raccoltadati" ("dataorarilevazione","id","numeroreplica","dataorainserimento","larghezzachiomafoglie_cm","lunghezzachiomafoglie_cm","pesofrescochiomafoglie_g","pesoseccochiomafoglie_g","altezzapianta_cm","lunghezzaradicei_cm","pesofrescoradici_g","pesoseccoradici_g","numerofiori","numerofrutti","numerodifogliedanneggiate","percsuperficiedanneggiataperfoglia","ph","umidità","temperatura","emailresponsabilerilev","emailresponsabileins","annoril","sezioneril","codicemeccril","annoins","sezioneins","codicemeccins") VALUES ('03.17.2014 09:30:00 p3',30,30,'12.02.2005 00:08:00 p12',686.47,4.05,61.44,95.98,886.79,NULL,NULL,NULL,184,8649,6544,0.9,7.4,97.02,19.8,'VCliment2@excite.fr','VCliment2@excite.fr','5','CNYKG','VTKB006525','5','CNYKG','VTKB006525');
INSERT INTO "ortiscolastici"."raccoltadati" ("dataorarilevazione","id","numeroreplica","dataorainserimento","larghezzachiomafoglie_cm","lunghezzachiomafoglie_cm","pesofrescochiomafoglie_g","pesoseccochiomafoglie_g","altezzapianta_cm","lunghezzaradicei_cm","pesofrescoradici_g","pesoseccoradici_g","numerofiori","numerofrutti","numerodifogliedanneggiate","percsuperficiedanneggiataperfoglia","ph","umidità","temperatura","emailresponsabilerilev","emailresponsabileins","annoril","sezioneril","codicemeccril","annoins","sezioneins","codicemeccins") VALUES ('11.03.2020 08:27:00 p11',33,33,'02.28.2007 03:35:00 p2',8.17,26.74,NULL,NULL,76.65,872.21,NULL,NULL,29587,3074,16060,1.06,0.4,4.64,0.3,'VCliment2@excite.fr','VCliment2@excite.fr','5','CNYKG','VTKB006525','5','CNYKG','VTKB006525');
INSERT INTO "ortiscolastici"."raccoltadati" ("dataorarilevazione","id","numeroreplica","dataorainserimento","larghezzachiomafoglie_cm","lunghezzachiomafoglie_cm","pesofrescochiomafoglie_g","pesoseccochiomafoglie_g","altezzapianta_cm","lunghezzaradicei_cm","pesofrescoradici_g","pesoseccoradici_g","numerofiori","numerofrutti","numerodifogliedanneggiate","percsuperficiedanneggiataperfoglia","ph","umidità","temperatura","emailresponsabilerilev","emailresponsabileins","annoril","sezioneril","codicemeccril","annoins","sezioneins","codicemeccins") VALUES ('10.21.2016 09:17:00 p10',35,35,'12.04.2022 07:07:00 p12',9.93,176.42,56.8,NULL,1.35,4.37,83.54,5.31,27384,24556,14250,0.2,0,60.46,66.2,'Carla.Pensec@gawab.nl','Carla.Pensec@gawab.nl','1','GPIHF','YQRW022436',NULL,'GPIHF','YQRW022436');
INSERT INTO "ortiscolastici"."raccoltadati" ("dataorarilevazione","id","numeroreplica","dataorainserimento","larghezzachiomafoglie_cm","lunghezzachiomafoglie_cm","pesofrescochiomafoglie_g","pesoseccochiomafoglie_g","altezzapianta_cm","lunghezzaradicei_cm","pesofrescoradici_g","pesoseccoradici_g","numerofiori","numerofrutti","numerodifogliedanneggiate","percsuperficiedanneggiataperfoglia","ph","umidità","temperatura","emailresponsabilerilev","emailresponsabileins","annoril","sezioneril","codicemeccril","annoins","sezioneins","codicemeccins") VALUES ('07.02.2018 00:22:00 p7',41,41,'05.04.2017 04:50:00 p5',54.33,76.95,56.99,929.9,9.78,NULL,145.87,65.22,25490,25572,7412,51.22,8.5,22.46,0,'Carla.Pensec@gawab.nl',NULL,'1','GPIHF','YQRW022436','1','GPIHF','YQRW022436');
INSERT INTO "ortiscolastici"."raccoltadati" ("dataorarilevazione","id","numeroreplica","dataorainserimento","larghezzachiomafoglie_cm","lunghezzachiomafoglie_cm","pesofrescochiomafoglie_g","pesoseccochiomafoglie_g","altezzapianta_cm","lunghezzaradicei_cm","pesofrescoradici_g","pesoseccoradici_g","numerofiori","numerofrutti","numerodifogliedanneggiate","percsuperficiedanneggiataperfoglia","ph","umidità","temperatura","emailresponsabilerilev","emailresponsabileins","annoril","sezioneril","codicemeccril","annoins","sezioneins","codicemeccins") VALUES ('08.06.2007 00:09:00 p8',46,46,'12.07.2013 00:50:00 p12',252.88,2.24,43.55,NULL,6.08,35.15,13.74,7.63,3521,30342,32024,0.57,0,0.59,0.5,'Y.Harness@aol.be','Y.Harness@aol.be',NULL,'GPIHF','YQRW022436','1','GPIHF','YQRW022436');
INSERT INTO "ortiscolastici"."raccoltadati" ("dataorarilevazione","id","numeroreplica","dataorainserimento","larghezzachiomafoglie_cm","lunghezzachiomafoglie_cm","pesofrescochiomafoglie_g","pesoseccochiomafoglie_g","altezzapianta_cm","lunghezzaradicei_cm","pesofrescoradici_g","pesoseccoradici_g","numerofiori","numerofrutti","numerodifogliedanneggiate","percsuperficiedanneggiataperfoglia","ph","umidità","temperatura","emailresponsabilerilev","emailresponsabileins","annoril","sezioneril","codicemeccril","annoins","sezioneins","codicemeccins") VALUES ('03.22.2018 05:22:00 p3',27,27,'04.13.2018 07:57:00 p4',70.47,71.26,5.05,931.89,744.45,139.81,9.94,NULL,18631,24181,12280,82.63,3.6,0.58,4.6,'Y.Harness@aol.be','Y.Harness@aol.be',NULL,'GPIHF','YQRW022436','1',NULL,'YQRW022436');
INSERT INTO "ortiscolastici"."raccoltadati" ("dataorarilevazione","id","numeroreplica","dataorainserimento","larghezzachiomafoglie_cm","lunghezzachiomafoglie_cm","pesofrescochiomafoglie_g","pesoseccochiomafoglie_g","altezzapianta_cm","lunghezzaradicei_cm","pesofrescoradici_g","pesoseccoradici_g","numerofiori","numerofrutti","numerodifogliedanneggiate","percsuperficiedanneggiataperfoglia","ph","umidità","temperatura","emailresponsabilerilev","emailresponsabileins","annoril","sezioneril","codicemeccril","annoins","sezioneins","codicemeccins") VALUES ('01.11.2012 00:51:00 p1',28,28,'09.03.2009 00:50:00 p9',983.9,17.81,203.11,6.65,5.1,982.17,68.62,1.83,22778,13878,20154,66.19,0.4,6.26,94.8,'Y.Harness@aol.be','Y.Harness@aol.be','1',NULL,'YQRW022436','1','GPIHF','YQRW022436');
INSERT INTO "ortiscolastici"."raccoltadati" ("dataorarilevazione","id","numeroreplica","dataorainserimento","larghezzachiomafoglie_cm","lunghezzachiomafoglie_cm","pesofrescochiomafoglie_g","pesoseccochiomafoglie_g","altezzapianta_cm","lunghezzaradicei_cm","pesofrescoradici_g","pesoseccoradici_g","numerofiori","numerofrutti","numerodifogliedanneggiate","percsuperficiedanneggiataperfoglia","ph","umidità","temperatura","emailresponsabilerilev","emailresponsabileins","annoril","sezioneril","codicemeccril","annoins","sezioneins","codicemeccins") VALUES ('11.17.2001 00:27:00 p11',33,33,'07.12.2018 03:20:00 p7',36.47,4.51,49.8,2.01,5.88,90.97,996.33,7.87,20758,25801,9113,0.5,0.8,89.55,36.1,NULL,'Y.Harness@aol.be','1','GPIHF',NULL,'1','GPIHF','YQRW022436');
INSERT INTO "ortiscolastici"."raccoltadati" ("dataorarilevazione","id","numeroreplica","dataorainserimento","larghezzachiomafoglie_cm","lunghezzachiomafoglie_cm","pesofrescochiomafoglie_g","pesoseccochiomafoglie_g","altezzapianta_cm","lunghezzaradicei_cm","pesofrescoradici_g","pesoseccoradici_g","numerofiori","numerofrutti","numerodifogliedanneggiate","percsuperficiedanneggiataperfoglia","ph","umidità","temperatura","emailresponsabilerilev","emailresponsabileins","annoril","sezioneril","codicemeccril","annoins","sezioneins","codicemeccins") VALUES ('11.29.2008 08:11:00 p11',37,37,'08.24.2022 07:22:00 p8',622.77,8.73,47.78,991.33,30.39,44.77,NULL,7.99,17962,16188,2791,0.5,6.1,0.23,27.8,'Y.Harness@aol.be','Y.Harness@aol.be','2','AMEWY','MQKH080804','2','AMEWY',NULL);
INSERT INTO "ortiscolastici"."raccoltadati" ("dataorarilevazione","id","numeroreplica","dataorainserimento","larghezzachiomafoglie_cm","lunghezzachiomafoglie_cm","pesofrescochiomafoglie_g","pesoseccochiomafoglie_g","altezzapianta_cm","lunghezzaradicei_cm","pesofrescoradici_g","pesoseccoradici_g","numerofiori","numerofrutti","numerodifogliedanneggiate","percsuperficiedanneggiataperfoglia","ph","umidità","temperatura","emailresponsabilerilev","emailresponsabileins","annoril","sezioneril","codicemeccril","annoins","sezioneins","codicemeccins") VALUES ('05.08.2017 04:22:00 p5',46,46,'05.10.2015 01:02:00 p5',859.05,26.19,86.65,340.38,473.76,65.88,NULL,NULL,1656,8379,18243,0.41,0.2,0.71,0.7,'Y.Harness@aol.be','Y.Harness@aol.be','3','PMBQK','OXEM815286','3','PMBQK','OXEM815286');
INSERT INTO "ortiscolastici"."raccoltadati" ("dataorarilevazione","id","numeroreplica","dataorainserimento","larghezzachiomafoglie_cm","lunghezzachiomafoglie_cm","pesofrescochiomafoglie_g","pesoseccochiomafoglie_g","altezzapianta_cm","lunghezzaradicei_cm","pesofrescoradici_g","pesoseccoradici_g","numerofiori","numerofrutti","numerodifogliedanneggiate","percsuperficiedanneggiataperfoglia","ph","umidità","temperatura","emailresponsabilerilev","emailresponsabileins","annoril","sezioneril","codicemeccril","annoins","sezioneins","codicemeccins") VALUES ('03.20.2016 01:08:00 p3',47,47,'03.09.2009 00:17:00 p3',353.49,708.01,280.95,1.48,78.59,841.36,1.74,NULL,25056,5238,26548,99.47,0.3,0.6,8.9,'Y.Bergdahl1@telefonica.org','Y.Bergdahl1@telefonica.org','3','PMBQK','OXEM815286','3','PMBQK','OXEM815286');
INSERT INTO "ortiscolastici"."raccoltadati" ("dataorarilevazione","id","numeroreplica","dataorainserimento","larghezzachiomafoglie_cm","lunghezzachiomafoglie_cm","pesofrescochiomafoglie_g","pesoseccochiomafoglie_g","altezzapianta_cm","lunghezzaradicei_cm","pesofrescoradici_g","pesoseccoradici_g","numerofiori","numerofrutti","numerodifogliedanneggiate","percsuperficiedanneggiataperfoglia","ph","umidità","temperatura","emailresponsabilerilev","emailresponsabileins","annoril","sezioneril","codicemeccril","annoins","sezioneins","codicemeccins") VALUES ('02.05.2014 10:51:00 p2',32,32,'04.25.2004 08:44:00 p4',4.88,4.01,1.51,589.25,71.63,379.34,82.49,621.47,13536,28213,21105,60.17,5.6,7.05,0.1,'Peter.Ostanik@kpn.it','Peter.Ostanik@kpn.it','3','PMBQK','OXEM815286',NULL,'PMBQK','OXEM815286');
INSERT INTO "ortiscolastici"."raccoltadati" ("dataorarilevazione","id","numeroreplica","dataorainserimento","larghezzachiomafoglie_cm","lunghezzachiomafoglie_cm","pesofrescochiomafoglie_g","pesoseccochiomafoglie_g","altezzapianta_cm","lunghezzaradicei_cm","pesofrescoradici_g","pesoseccoradici_g","numerofiori","numerofrutti","numerodifogliedanneggiate","percsuperficiedanneggiataperfoglia","ph","umidità","temperatura","emailresponsabilerilev","emailresponsabileins","annoril","sezioneril","codicemeccril","annoins","sezioneins","codicemeccins") VALUES ('01.13.2002 09:05:00 p1',37,37,'11.05.2002 07:03:00 p11',195.93,77.02,731.55,118.86,5.64,2.68,64.84,NULL,13771,31773,16324,0.5,0,0.8,0,'Peter.Ostanik@kpn.it',NULL,'4','NHFMY','VTKB006525','4','NHFMY','VTKB006525');
INSERT INTO "ortiscolastici"."raccoltadati" ("dataorarilevazione","id","numeroreplica","dataorainserimento","larghezzachiomafoglie_cm","lunghezzachiomafoglie_cm","pesofrescochiomafoglie_g","pesoseccochiomafoglie_g","altezzapianta_cm","lunghezzaradicei_cm","pesofrescoradici_g","pesoseccoradici_g","numerofiori","numerofrutti","numerodifogliedanneggiate","percsuperficiedanneggiataperfoglia","ph","umidità","temperatura","emailresponsabilerilev","emailresponsabileins","annoril","sezioneril","codicemeccril","annoins","sezioneins","codicemeccins") VALUES ('06.25.2003 10:44:00 p6',41,41,'08.20.2000 05:06:00 p8',725.33,92.99,772.88,911.95,15.5,779.06,NULL,30.07,29343,25884,3482,0.55,12.8,2.7,89.3,'Peter.Ostanik@kpn.it','Peter.Ostanik@kpn.it','4','NHFMY','VTKB006525','4','NHFMY','VTKB006525');
INSERT INTO "ortiscolastici"."raccoltadati" ("dataorarilevazione","id","numeroreplica","dataorainserimento","larghezzachiomafoglie_cm","lunghezzachiomafoglie_cm","pesofrescochiomafoglie_g","pesoseccochiomafoglie_g","altezzapianta_cm","lunghezzaradicei_cm","pesofrescoradici_g","pesoseccoradici_g","numerofiori","numerofrutti","numerodifogliedanneggiate","percsuperficiedanneggiataperfoglia","ph","umidità","temperatura","emailresponsabilerilev","emailresponsabileins","annoril","sezioneril","codicemeccril","annoins","sezioneins","codicemeccins") VALUES ('09.23.2015 00:56:00 p9',46,46,'05.24.2014 02:55:00 p5',20.66,6.34,831.02,668.05,626.46,1.28,96.04,172.1,8520,31145,27006,15.62,0.4,0.36,0.6,'RickMillikin4@gawab.org','RickMillikin4@gawab.org','4',NULL,'VTKB006525',NULL,'NHFMY','VTKB006525');
INSERT INTO "ortiscolastici"."raccoltadati" ("dataorarilevazione","id","numeroreplica","dataorainserimento","larghezzachiomafoglie_cm","lunghezzachiomafoglie_cm","pesofrescochiomafoglie_g","pesoseccochiomafoglie_g","altezzapianta_cm","lunghezzaradicei_cm","pesofrescoradici_g","pesoseccoradici_g","numerofiori","numerofrutti","numerodifogliedanneggiate","percsuperficiedanneggiataperfoglia","ph","umidità","temperatura","emailresponsabilerilev","emailresponsabileins","annoril","sezioneril","codicemeccril","annoins","sezioneins","codicemeccins") VALUES ('04.01.2011 03:21:00 p4',29,29,'01.16.2022 02:41:00 p1',84.76,761.59,91.77,271.87,3.13,795.44,2.4,519.12,6493,7126,23810,0.54,0.2,0.93,31.5,'RickMillikin4@gawab.org','RickMillikin4@gawab.org','5','CJUXW','OXEM815286','5','CJUXW','OXEM815286');
INSERT INTO "ortiscolastici"."raccoltadati" ("dataorarilevazione","id","numeroreplica","dataorainserimento","larghezzachiomafoglie_cm","lunghezzachiomafoglie_cm","pesofrescochiomafoglie_g","pesoseccochiomafoglie_g","altezzapianta_cm","lunghezzaradicei_cm","pesofrescoradici_g","pesoseccoradici_g","numerofiori","numerofrutti","numerodifogliedanneggiate","percsuperficiedanneggiataperfoglia","ph","umidità","temperatura","emailresponsabilerilev","emailresponsabileins","annoril","sezioneril","codicemeccril","annoins","sezioneins","codicemeccins") VALUES ('11.13.2013 00:52:00 p11',31,31,'06.23.2011 00:28:00 p6',5.73,5.27,109.59,267.18,38.75,5.55,73.57,6.38,21530,17763,20186,8.93,0.3,29.08,0.2,'RickMillikin4@gawab.org','RickMillikin4@gawab.org','5','CJUXW','OXEM815286','5','CJUXW',NULL);
INSERT INTO "ortiscolastici"."raccoltadati" ("dataorarilevazione","id","numeroreplica","dataorainserimento","larghezzachiomafoglie_cm","lunghezzachiomafoglie_cm","pesofrescochiomafoglie_g","pesoseccochiomafoglie_g","altezzapianta_cm","lunghezzaradicei_cm","pesofrescoradici_g","pesoseccoradici_g","numerofiori","numerofrutti","numerodifogliedanneggiate","percsuperficiedanneggiataperfoglia","ph","umidità","temperatura","emailresponsabilerilev","emailresponsabileins","annoril","sezioneril","codicemeccril","annoins","sezioneins","codicemeccins") VALUES ('12.14.2022 03:07:00 p12',37,37,'01.16.2019 06:29:00 p1',990.45,81.46,785.95,75.71,30.59,95.82,8.84,517.62,3391,24785,7950,0.5,9.6,0.1,10.6,'SjorsWaldo4@hotmail.org','SjorsWaldo4@hotmail.org','5','CJUXW','OXEM815286','5','CJUXW','OXEM815286');
INSERT INTO "ortiscolastici"."raccoltadati" ("dataorarilevazione","id","numeroreplica","dataorainserimento","larghezzachiomafoglie_cm","lunghezzachiomafoglie_cm","pesofrescochiomafoglie_g","pesoseccochiomafoglie_g","altezzapianta_cm","lunghezzaradicei_cm","pesofrescoradici_g","pesoseccoradici_g","numerofiori","numerofrutti","numerodifogliedanneggiate","percsuperficiedanneggiataperfoglia","ph","umidità","temperatura","emailresponsabilerilev","emailresponsabileins","annoril","sezioneril","codicemeccril","annoins","sezioneins","codicemeccins") VALUES ('10.04.2014 00:07:00 p10',41,41,'11.04.2015 06:49:00 p11',758.86,30.57,46.31,5.88,34.55,94.15,NULL,794.16,28425,22425,347,0.26,1.1,0.1,59.6,'SjorsWaldo4@hotmail.org','SjorsWaldo4@hotmail.org','3','PZMZA',NULL,'3',NULL,'HQVY577395');
INSERT INTO "ortiscolastici"."raccoltadati" ("dataorarilevazione","id","numeroreplica","dataorainserimento","larghezzachiomafoglie_cm","lunghezzachiomafoglie_cm","pesofrescochiomafoglie_g","pesoseccochiomafoglie_g","altezzapianta_cm","lunghezzaradicei_cm","pesofrescoradici_g","pesoseccoradici_g","numerofiori","numerofrutti","numerodifogliedanneggiate","percsuperficiedanneggiataperfoglia","ph","umidità","temperatura","emailresponsabilerilev","emailresponsabileins","annoril","sezioneril","codicemeccril","annoins","sezioneins","codicemeccins") VALUES ('05.02.2008 05:57:00 p5',48,48,'11.02.2008 04:30:00 p11',56.9,345.11,3.89,4.47,202.25,4.16,77.64,952.2,5879,25619,1514,0.9,8.4,6.07,5,'LindsyZapetis@telfort.es','LindsyZapetis@telfort.es','3','PZMZA','HQVY577395','3','PZMZA','HQVY577395');
INSERT INTO "ortiscolastici"."raccoltadati" ("dataorarilevazione","id","numeroreplica","dataorainserimento","larghezzachiomafoglie_cm","lunghezzachiomafoglie_cm","pesofrescochiomafoglie_g","pesoseccochiomafoglie_g","altezzapianta_cm","lunghezzaradicei_cm","pesofrescoradici_g","pesoseccoradici_g","numerofiori","numerofrutti","numerodifogliedanneggiate","percsuperficiedanneggiataperfoglia","ph","umidità","temperatura","emailresponsabilerilev","emailresponsabileins","annoril","sezioneril","codicemeccril","annoins","sezioneins","codicemeccins") VALUES ('08.03.2019 01:55:00 p8',30,30,'09.15.2005 06:22:00 p9',5.37,865.41,23.9,8.66,35.23,NULL,914.85,NULL,169,1997,15550,0.41,8.5,9.88,0.2,'Y.Bergdahl1@telefonica.org',NULL,NULL,'PZMZA','HQVY577395','3',NULL,NULL);
INSERT INTO "ortiscolastici"."raccoltadati" ("dataorarilevazione","id","numeroreplica","dataorainserimento","larghezzachiomafoglie_cm","lunghezzachiomafoglie_cm","pesofrescochiomafoglie_g","pesoseccochiomafoglie_g","altezzapianta_cm","lunghezzaradicei_cm","pesofrescoradici_g","pesoseccoradici_g","numerofiori","numerofrutti","numerodifogliedanneggiate","percsuperficiedanneggiataperfoglia","ph","umidità","temperatura","emailresponsabilerilev","emailresponsabileins","annoril","sezioneril","codicemeccril","annoins","sezioneins","codicemeccins") VALUES ('06.04.2007 05:44:00 p6',40,40,'12.08.2003 03:32:00 p12',817.71,5.25,689.25,NULL,205.2,591.2,39.06,93.64,12453,9489,15850,0.6,3.6,27.66,4.4,'Otto.Uitergeest5@aol.be','Otto.Uitergeest5@aol.be','3','PZMZA','HQVY577395',NULL,'PZMZA','HQVY577395');
INSERT INTO "ortiscolastici"."raccoltadati" ("dataorarilevazione","id","numeroreplica","dataorainserimento","larghezzachiomafoglie_cm","lunghezzachiomafoglie_cm","pesofrescochiomafoglie_g","pesoseccochiomafoglie_g","altezzapianta_cm","lunghezzaradicei_cm","pesofrescoradici_g","pesoseccoradici_g","numerofiori","numerofrutti","numerodifogliedanneggiate","percsuperficiedanneggiataperfoglia","ph","umidità","temperatura","emailresponsabilerilev","emailresponsabileins","annoril","sezioneril","codicemeccril","annoins","sezioneins","codicemeccins") VALUES ('08.24.2005 10:25:00 p8',43,43,'02.08.2014 07:01:00 p2',9.41,291.86,9.24,11.93,924.62,52.43,NULL,3.95,383,6431,30366,0.11,0.1,70.27,3.5,'Otto.Uitergeest5@aol.be','Otto.Uitergeest5@aol.be',NULL,'PZMZA','HQVY577395','3','PZMZA','HQVY577395');
INSERT INTO "ortiscolastici"."raccoltadati" ("dataorarilevazione","id","numeroreplica","dataorainserimento","larghezzachiomafoglie_cm","lunghezzachiomafoglie_cm","pesofrescochiomafoglie_g","pesoseccochiomafoglie_g","altezzapianta_cm","lunghezzaradicei_cm","pesofrescoradici_g","pesoseccoradici_g","numerofiori","numerofrutti","numerodifogliedanneggiate","percsuperficiedanneggiataperfoglia","ph","umidità","temperatura","emailresponsabilerilev","emailresponsabileins","annoril","sezioneril","codicemeccril","annoins","sezioneins","codicemeccins") VALUES ('05.02.2023 01:34:00 p5',48,48,'10.23.2020 06:03:00 p10',30.6,1.69,37.94,87.95,54.74,2.24,896.93,1.9,8714,24454,3922,7.95,0.1,43.67,0.9,NULL,'Otto.Uitergeest5@aol.be','3','PZMZA','HQVY577395','3','PZMZA','HQVY577395');
INSERT INTO "ortiscolastici"."raccoltadati" ("dataorarilevazione","id","numeroreplica","dataorainserimento","larghezzachiomafoglie_cm","lunghezzachiomafoglie_cm","pesofrescochiomafoglie_g","pesoseccochiomafoglie_g","altezzapianta_cm","lunghezzaradicei_cm","pesofrescoradici_g","pesoseccoradici_g","numerofiori","numerofrutti","numerodifogliedanneggiate","percsuperficiedanneggiataperfoglia","ph","umidità","temperatura","emailresponsabilerilev","emailresponsabileins","annoril","sezioneril","codicemeccril","annoins","sezioneins","codicemeccins") VALUES ('09.24.2003 07:00:00 p9',30,30,'12.17.2001 09:49:00 p12',656.18,588.25,7.46,51.53,67.25,NULL,97.66,777.23,2198,13492,20253,2.07,0.5,0,0.5,'Dana.Pensec@excite.gov','Dana.Pensec@excite.gov','3','PZMZA','HQVY577395','3','PZMZA','HQVY577395');
INSERT INTO "ortiscolastici"."raccoltadati" ("dataorarilevazione","id","numeroreplica","dataorainserimento","larghezzachiomafoglie_cm","lunghezzachiomafoglie_cm","pesofrescochiomafoglie_g","pesoseccochiomafoglie_g","altezzapianta_cm","lunghezzaradicei_cm","pesofrescoradici_g","pesoseccoradici_g","numerofiori","numerofrutti","numerodifogliedanneggiate","percsuperficiedanneggiataperfoglia","ph","umidità","temperatura","emailresponsabilerilev","emailresponsabileins","annoril","sezioneril","codicemeccril","annoins","sezioneins","codicemeccins") VALUES ('02.14.2012 02:06:00 p2',32,32,'06.05.2018 02:49:00 p6',445.24,25.75,2.36,NULL,68.94,NULL,NULL,6.15,31567,8948,22320,0.86,4,99.28,0,'Y.Harness@aol.be','Y.Harness@aol.be',NULL,'PZMZA','HQVY577395','3','PZMZA','HQVY577395');
INSERT INTO "ortiscolastici"."raccoltadati" ("dataorarilevazione","id","numeroreplica","dataorainserimento","larghezzachiomafoglie_cm","lunghezzachiomafoglie_cm","pesofrescochiomafoglie_g","pesoseccochiomafoglie_g","altezzapianta_cm","lunghezzaradicei_cm","pesofrescoradici_g","pesoseccoradici_g","numerofiori","numerofrutti","numerodifogliedanneggiate","percsuperficiedanneggiataperfoglia","ph","umidità","temperatura","emailresponsabilerilev","emailresponsabileins","annoril","sezioneril","codicemeccril","annoins","sezioneins","codicemeccins") VALUES ('01.28.2010 03:21:00 p1',39,39,'11.26.2000 06:17:00 p11',649.66,66.23,747.82,NULL,6.3,NULL,3.5,9.67,19985,2542,27719,3.44,0.1,15.77,0,'Y.Harness@aol.be','Y.Harness@aol.be','1','HWAMN','MGCO209282','1','HWAMN','MGCO209282');
INSERT INTO "ortiscolastici"."raccoltadati" ("dataorarilevazione","id","numeroreplica","dataorainserimento","larghezzachiomafoglie_cm","lunghezzachiomafoglie_cm","pesofrescochiomafoglie_g","pesoseccochiomafoglie_g","altezzapianta_cm","lunghezzaradicei_cm","pesofrescoradici_g","pesoseccoradici_g","numerofiori","numerofrutti","numerodifogliedanneggiate","percsuperficiedanneggiataperfoglia","ph","umidità","temperatura","emailresponsabilerilev","emailresponsabileins","annoril","sezioneril","codicemeccril","annoins","sezioneins","codicemeccins") VALUES ('01.22.2012 00:29:00 p1',49,49,'05.13.2013 04:52:00 p5',2.34,50.3,1.59,NULL,35.9,NULL,5.4,NULL,30653,1535,31590,21.27,0.1,68.99,73.7,'Y.Harness@aol.be','Y.Harness@aol.be','3','RTYON','EVMM088541','3','RTYON','EVMM088541');
INSERT INTO "ortiscolastici"."raccoltadati" ("dataorarilevazione","id","numeroreplica","dataorainserimento","larghezzachiomafoglie_cm","lunghezzachiomafoglie_cm","pesofrescochiomafoglie_g","pesoseccochiomafoglie_g","altezzapianta_cm","lunghezzaradicei_cm","pesofrescoradici_g","pesoseccoradici_g","numerofiori","numerofrutti","numerodifogliedanneggiate","percsuperficiedanneggiataperfoglia","ph","umidità","temperatura","emailresponsabilerilev","emailresponsabileins","annoril","sezioneril","codicemeccril","annoins","sezioneins","codicemeccins") VALUES ('07.09.2000 04:08:00 p7',31,31,'05.25.2013 07:23:00 p5',949,502.36,272.61,958.71,45.68,512.49,77.59,6.41,7363,28135,29503,0.2,4.1,0.1,0.6,'BasRaines@lycos.cc','BasRaines@lycos.cc','4','NHFMY','VTKB006525','4','NHFMY',NULL);
INSERT INTO "ortiscolastici"."raccoltadati" ("dataorarilevazione","id","numeroreplica","dataorainserimento","larghezzachiomafoglie_cm","lunghezzachiomafoglie_cm","pesofrescochiomafoglie_g","pesoseccochiomafoglie_g","altezzapianta_cm","lunghezzaradicei_cm","pesofrescoradici_g","pesoseccoradici_g","numerofiori","numerofrutti","numerodifogliedanneggiate","percsuperficiedanneggiataperfoglia","ph","umidità","temperatura","emailresponsabilerilev","emailresponsabileins","annoril","sezioneril","codicemeccril","annoins","sezioneins","codicemeccins") VALUES ('11.02.2022 02:16:00 p11',40,40,'08.21.2005 07:29:00 p8',9.36,7.61,2.81,1.76,1.22,76.3,75.2,2.02,16318,13045,4932,0.79,9.7,4.3,0,'BasRaines@lycos.cc','BasRaines@lycos.cc','4','NHFMY','VTKB006525','4','NHFMY','VTKB006525');
INSERT INTO "ortiscolastici"."raccoltadati" ("dataorarilevazione","id","numeroreplica","dataorainserimento","larghezzachiomafoglie_cm","lunghezzachiomafoglie_cm","pesofrescochiomafoglie_g","pesoseccochiomafoglie_g","altezzapianta_cm","lunghezzaradicei_cm","pesofrescoradici_g","pesoseccoradici_g","numerofiori","numerofrutti","numerodifogliedanneggiate","percsuperficiedanneggiataperfoglia","ph","umidità","temperatura","emailresponsabilerilev","emailresponsabileins","annoril","sezioneril","codicemeccril","annoins","sezioneins","codicemeccins") VALUES ('05.09.2020 07:24:00 p5',50,50,'12.31.2008 00:22:00 p12',7.39,7.92,1.02,47.44,93.64,NULL,NULL,9.72,13888,784,21518,0.7,0.4,5.52,86.8,'BillMiller@mymail.com','BillMiller@mymail.com','4','NHFMY','VTKB006525','4','NHFMY','VTKB006525');
INSERT INTO "ortiscolastici"."raccoltadati" ("dataorarilevazione","id","numeroreplica","dataorainserimento","larghezzachiomafoglie_cm","lunghezzachiomafoglie_cm","pesofrescochiomafoglie_g","pesoseccochiomafoglie_g","altezzapianta_cm","lunghezzaradicei_cm","pesofrescoradici_g","pesoseccoradici_g","numerofiori","numerofrutti","numerodifogliedanneggiate","percsuperficiedanneggiataperfoglia","ph","umidità","temperatura","emailresponsabilerilev","emailresponsabileins","annoril","sezioneril","codicemeccril","annoins","sezioneins","codicemeccins") VALUES ('03.24.2023 09:03:00 p3',32,32,'09.26.2020 01:53:00 p9',75.8,2.04,8.06,4.43,9.51,48.05,6.01,99.18,22859,17833,23677,0.68,0.7,71.19,9.9,'BillMiller@mymail.com','BillMiller@mymail.com','1','NKMCR','JINL051845','1','NKMCR','JINL051845');
INSERT INTO "ortiscolastici"."raccoltadati" ("dataorarilevazione","id","numeroreplica","dataorainserimento","larghezzachiomafoglie_cm","lunghezzachiomafoglie_cm","pesofrescochiomafoglie_g","pesoseccochiomafoglie_g","altezzapianta_cm","lunghezzaradicei_cm","pesofrescoradici_g","pesoseccoradici_g","numerofiori","numerofrutti","numerodifogliedanneggiate","percsuperficiedanneggiataperfoglia","ph","umidità","temperatura","emailresponsabilerilev","emailresponsabileins","annoril","sezioneril","codicemeccril","annoins","sezioneins","codicemeccins") VALUES ('09.19.2005 02:01:00 p9',42,42,'03.25.2005 07:18:00 p3',8.91,47.52,35.3,27.93,5.19,88.13,87.47,NULL,20555,27006,16586,43.9,1.6,8.47,74,'BillMiller@mymail.com','BillMiller@mymail.com','1','NKMCR','JINL051845','1',NULL,'JINL051845');
INSERT INTO "ortiscolastici"."raccoltadati" ("dataorarilevazione","id","numeroreplica","dataorainserimento","larghezzachiomafoglie_cm","lunghezzachiomafoglie_cm","pesofrescochiomafoglie_g","pesoseccochiomafoglie_g","altezzapianta_cm","lunghezzaradicei_cm","pesofrescoradici_g","pesoseccoradici_g","numerofiori","numerofrutti","numerodifogliedanneggiate","percsuperficiedanneggiataperfoglia","ph","umidità","temperatura","emailresponsabilerilev","emailresponsabileins","annoril","sezioneril","codicemeccril","annoins","sezioneins","codicemeccins") VALUES ('05.21.2000 02:03:00 p5',27,27,'08.15.2021 02:54:00 p8',7.23,5.83,77.33,NULL,991.1,9.7,NULL,95.31,26138,4364,12918,15.6,9.8,0.55,10.9,'Otto.Uitergeest5@aol.be','Otto.Uitergeest5@aol.be','2','GPXKA','QHND731760','2','GPXKA',NULL);
INSERT INTO "ortiscolastici"."raccoltadati" ("dataorarilevazione","id","numeroreplica","dataorainserimento","larghezzachiomafoglie_cm","lunghezzachiomafoglie_cm","pesofrescochiomafoglie_g","pesoseccochiomafoglie_g","altezzapianta_cm","lunghezzaradicei_cm","pesofrescoradici_g","pesoseccoradici_g","numerofiori","numerofrutti","numerodifogliedanneggiate","percsuperficiedanneggiataperfoglia","ph","umidità","temperatura","emailresponsabilerilev","emailresponsabileins","annoril","sezioneril","codicemeccril","annoins","sezioneins","codicemeccins") VALUES ('12.29.2013 03:23:00 p12',36,36,'12.16.2010 06:27:00 p12',7.34,490.84,7.17,44.25,6.66,21.81,428.68,779.06,30586,26144,15971,83.06,0.8,5.61,0,'Otto.Uitergeest5@aol.be','Otto.Uitergeest5@aol.be','2','GPXKA','QHND731760','2','GPXKA','QHND731760');
INSERT INTO "ortiscolastici"."raccoltadati" ("dataorarilevazione","id","numeroreplica","dataorainserimento","larghezzachiomafoglie_cm","lunghezzachiomafoglie_cm","pesofrescochiomafoglie_g","pesoseccochiomafoglie_g","altezzapianta_cm","lunghezzaradicei_cm","pesofrescoradici_g","pesoseccoradici_g","numerofiori","numerofrutti","numerodifogliedanneggiate","percsuperficiedanneggiataperfoglia","ph","umidità","temperatura","emailresponsabilerilev","emailresponsabileins","annoril","sezioneril","codicemeccril","annoins","sezioneins","codicemeccins") VALUES ('09.16.2009 08:48:00 p9',38,38,'10.09.2005 00:27:00 p10',21.08,5.3,17.85,NULL,26.71,27.88,672.46,94.43,22771,316,14297,0.2,8.5,0.95,57.6,'Dana.Pensec@excite.gov','Dana.Pensec@excite.gov','2','GPXKA','QHND731760','2','GPXKA','QHND731760');
INSERT INTO "ortiscolastici"."raccoltadati" ("dataorarilevazione","id","numeroreplica","dataorainserimento","larghezzachiomafoglie_cm","lunghezzachiomafoglie_cm","pesofrescochiomafoglie_g","pesoseccochiomafoglie_g","altezzapianta_cm","lunghezzaradicei_cm","pesofrescoradici_g","pesoseccoradici_g","numerofiori","numerofrutti","numerodifogliedanneggiate","percsuperficiedanneggiataperfoglia","ph","umidità","temperatura","emailresponsabilerilev","emailresponsabileins","annoril","sezioneril","codicemeccril","annoins","sezioneins","codicemeccins") VALUES ('03.06.2023 01:02:00 p3',47,47,'11.20.2001 05:18:00 p11',7.48,5.03,63.29,69.09,2.9,831.27,NULL,NULL,30362,21456,14149,0.82,0.4,16.59,0.3,'Kylie.Anderson2@aol.es','Kylie.Anderson2@aol.es','1','ZMGHT',NULL,'1','ZMGHT','UPJB481631');
INSERT INTO "ortiscolastici"."raccoltadati" ("dataorarilevazione","id","numeroreplica","dataorainserimento","larghezzachiomafoglie_cm","lunghezzachiomafoglie_cm","pesofrescochiomafoglie_g","pesoseccochiomafoglie_g","altezzapianta_cm","lunghezzaradicei_cm","pesofrescoradici_g","pesoseccoradici_g","numerofiori","numerofrutti","numerodifogliedanneggiate","percsuperficiedanneggiataperfoglia","ph","umidità","temperatura","emailresponsabilerilev","emailresponsabileins","annoril","sezioneril","codicemeccril","annoins","sezioneins","codicemeccins") VALUES ('10.09.2003 06:15:00 p10',49,49,'10.12.2020 07:03:00 p10',504.21,7.39,2.2,503.64,695.64,62.9,1.11,4.51,27489,22618,10625,0.8,0.8,56.22,7.8,'Kylie.Anderson2@aol.es','Kylie.Anderson2@aol.es','1',NULL,'UPJB481631','1','ZMGHT','UPJB481631');
INSERT INTO "ortiscolastici"."raccoltadati" ("dataorarilevazione","id","numeroreplica","dataorainserimento","larghezzachiomafoglie_cm","lunghezzachiomafoglie_cm","pesofrescochiomafoglie_g","pesoseccochiomafoglie_g","altezzapianta_cm","lunghezzaradicei_cm","pesofrescoradici_g","pesoseccoradici_g","numerofiori","numerofrutti","numerodifogliedanneggiate","percsuperficiedanneggiataperfoglia","ph","umidità","temperatura","emailresponsabilerilev","emailresponsabileins","annoril","sezioneril","codicemeccril","annoins","sezioneins","codicemeccins") VALUES ('03.02.2001 04:27:00 p3',30,30,'06.25.2005 05:47:00 p6',9.15,86.97,52.28,NULL,30.67,NULL,89.84,3.79,25163,7143,13899,99.7,8.4,0.1,8.6,NULL,'Kylie.Anderson2@aol.es','2','TYBHX','GEUW927079','2','TYBHX','GEUW927079');
INSERT INTO "ortiscolastici"."raccoltadati" ("dataorarilevazione","id","numeroreplica","dataorainserimento","larghezzachiomafoglie_cm","lunghezzachiomafoglie_cm","pesofrescochiomafoglie_g","pesoseccochiomafoglie_g","altezzapianta_cm","lunghezzaradicei_cm","pesofrescoradici_g","pesoseccoradici_g","numerofiori","numerofrutti","numerodifogliedanneggiate","percsuperficiedanneggiataperfoglia","ph","umidità","temperatura","emailresponsabilerilev","emailresponsabileins","annoril","sezioneril","codicemeccril","annoins","sezioneins","codicemeccins") VALUES ('02.20.2021 05:31:00 p2',40,40,'07.20.2019 01:11:00 p7',629.21,9.57,1.2,890.23,645.75,68.05,86.83,3.82,4755,30586,12202,0.96,0,86.17,4.8,NULL,'Kylie.Anderson2@aol.es','2','TYBHX','GEUW927079','2','TYBHX','GEUW927079');
INSERT INTO "ortiscolastici"."raccoltadati" ("dataorarilevazione","id","numeroreplica","dataorainserimento","larghezzachiomafoglie_cm","lunghezzachiomafoglie_cm","pesofrescochiomafoglie_g","pesoseccochiomafoglie_g","altezzapianta_cm","lunghezzaradicei_cm","pesofrescoradici_g","pesoseccoradici_g","numerofiori","numerofrutti","numerodifogliedanneggiate","percsuperficiedanneggiataperfoglia","ph","umidità","temperatura","emailresponsabilerilev","emailresponsabileins","annoril","sezioneril","codicemeccril","annoins","sezioneins","codicemeccins") VALUES ('06.22.2023 07:15:00 p6',49,49,'04.20.2004 10:14:00 p4',750.84,1.87,7.11,50.43,69.49,4.89,6.67,455.28,21974,20918,13414,97.69,9.7,0.63,0.9,'Kylie.Anderson2@aol.es','Kylie.Anderson2@aol.es','2','TYBHX','GEUW927079','2',NULL,'GEUW927079');
INSERT INTO "ortiscolastici"."raccoltadati" ("dataorarilevazione","id","numeroreplica","dataorainserimento","larghezzachiomafoglie_cm","lunghezzachiomafoglie_cm","pesofrescochiomafoglie_g","pesoseccochiomafoglie_g","altezzapianta_cm","lunghezzaradicei_cm","pesofrescoradici_g","pesoseccoradici_g","numerofiori","numerofrutti","numerodifogliedanneggiate","percsuperficiedanneggiataperfoglia","ph","umidità","temperatura","emailresponsabilerilev","emailresponsabileins","annoril","sezioneril","codicemeccril","annoins","sezioneins","codicemeccins") VALUES ('04.11.2018 05:29:00 p4',26,26,'05.04.2019 02:40:00 p5',645.83,3.59,9.05,285.3,866.56,799.27,39.09,58.06,23039,31234,16320,3.88,0.6,0.9,0.3,'Kylie.Anderson2@aol.es','Kylie.Anderson2@aol.es','1','NKMCR','JINL051845','1','NKMCR','JINL051845');
INSERT INTO "ortiscolastici"."raccoltadati" ("dataorarilevazione","id","numeroreplica","dataorainserimento","larghezzachiomafoglie_cm","lunghezzachiomafoglie_cm","pesofrescochiomafoglie_g","pesoseccochiomafoglie_g","altezzapianta_cm","lunghezzaradicei_cm","pesofrescoradici_g","pesoseccoradici_g","numerofiori","numerofrutti","numerodifogliedanneggiate","percsuperficiedanneggiataperfoglia","ph","umidità","temperatura","emailresponsabilerilev","emailresponsabileins","annoril","sezioneril","codicemeccril","annoins","sezioneins","codicemeccins") VALUES ('07.04.2021 01:57:00 p7',31,31,'01.06.2002 05:30:00 p1',37.96,3.89,54.02,27.32,63.61,NULL,NULL,173.54,1195,25188,20973,1.38,0.3,0.5,9.1,'PStockton4@myspace.com','PStockton4@myspace.com','1',NULL,NULL,'1',NULL,NULL);



INSERT INTO "ortiscolastici"."dispositivo" ("id","tipodispositivo","dataorarilevazione","piantadiriferimento","numeroreplica","ortodoverisiede","scuoladiriferimento") VALUES (1,'Arduino','09.09.2004 05:55:00 p9',1,1,'N1ZTEcuiLYhodtH6ZGyRQa0Qk','VNHY110520');
INSERT INTO "ortiscolastici"."dispositivo" ("id","tipodispositivo","dataorarilevazione","piantadiriferimento","numeroreplica","ortodoverisiede","scuoladiriferimento") VALUES (2,'Arduino','12.25.2010 06:55:00 p12',16,16,'N1ZTEcuiLYhodtH6ZGyRQa0Qk','VNHY110520');
INSERT INTO "ortiscolastici"."dispositivo" ("id","tipodispositivo","dataorarilevazione","piantadiriferimento","numeroreplica","ortodoverisiede","scuoladiriferimento") VALUES (3,'Sensore','12.25.2010 06:55:00 p12',16,16,'lsXAgi','URES865795');
INSERT INTO "ortiscolastici"."dispositivo" ("id","tipodispositivo","dataorarilevazione","piantadiriferimento","numeroreplica","ortodoverisiede","scuoladiriferimento") VALUES (4,'Arduino','12.25.2010 06:55:00 p12',16,16,'Retav5Mk1','NXVI522896');
INSERT INTO "ortiscolastici"."dispositivo" ("id","tipodispositivo","dataorarilevazione","piantadiriferimento","numeroreplica","ortodoverisiede","scuoladiriferimento") VALUES (5,'Sensore','03.17.2014 09:30:00 p3',30,30,'Retav5Mk1','NXVI522896');
INSERT INTO "ortiscolastici"."dispositivo" ("id","tipodispositivo","dataorarilevazione","piantadiriferimento","numeroreplica","ortodoverisiede","scuoladiriferimento") VALUES (6,'Sensore','08.03.2019 01:55:00 p8',30,30,'Retav5Mk1','NXVI522896');
INSERT INTO "ortiscolastici"."dispositivo" ("id","tipodispositivo","dataorarilevazione","piantadiriferimento","numeroreplica","ortodoverisiede","scuoladiriferimento") VALUES (7,'Sensore','11.03.2020 08:27:00 p11',33,33,'2','AWID899355');
INSERT INTO "ortiscolastici"."dispositivo" ("id","tipodispositivo","dataorarilevazione","piantadiriferimento","numeroreplica","ortodoverisiede","scuoladiriferimento") VALUES (8,'Sensore','11.17.2001 00:27:00 p11',33,33,'2','AWID899355');
INSERT INTO "ortiscolastici"."dispositivo" ("id","tipodispositivo","dataorarilevazione","piantadiriferimento","numeroreplica","ortodoverisiede","scuoladiriferimento") VALUES (9,'Arduino','11.17.2001 00:27:00 p11',33,33,'TG','AWID899355');
INSERT INTO "ortiscolastici"."dispositivo" ("id","tipodispositivo","dataorarilevazione","piantadiriferimento","numeroreplica","ortodoverisiede","scuoladiriferimento") VALUES (10,'Sensore','03.20.2016 01:08:00 p3',47,47,'TG','AWID899355');
INSERT INTO "ortiscolastici"."dispositivo" ("id","tipodispositivo","dataorarilevazione","piantadiriferimento","numeroreplica","ortodoverisiede","scuoladiriferimento") VALUES (11,'Sensore','03.06.2023 01:02:00 p3',47,47,'yqM','JINL051845');
INSERT INTO "ortiscolastici"."dispositivo" ("id","tipodispositivo","dataorarilevazione","piantadiriferimento","numeroreplica","ortodoverisiede","scuoladiriferimento") VALUES (12,'Sensore','11.29.2008 08:11:00 p11',37,37,'yqM','JINL051845');
INSERT INTO "ortiscolastici"."dispositivo" ("id","tipodispositivo","dataorarilevazione","piantadiriferimento","numeroreplica","ortodoverisiede","scuoladiriferimento") VALUES (13,'Arduino','01.13.2002 09:05:00 p1',37,37,'yqM','JINL051845');
INSERT INTO "ortiscolastici"."dispositivo" ("id","tipodispositivo","dataorarilevazione","piantadiriferimento","numeroreplica","ortodoverisiede","scuoladiriferimento") VALUES (14,'Arduino','02.05.2014 10:51:00 p2',32,32,'NpJmYdBXRUyi5','QHND731760');
INSERT INTO "ortiscolastici"."dispositivo" ("id","tipodispositivo","dataorarilevazione","piantadiriferimento","numeroreplica","ortodoverisiede","scuoladiriferimento") VALUES (15,'Arduino','09.16.2009 08:48:00 p9',38,38,'NpJmYdBXRUyi5','QHND731760');
INSERT INTO "ortiscolastici"."dispositivo" ("id","tipodispositivo","dataorarilevazione","piantadiriferimento","numeroreplica","ortodoverisiede","scuoladiriferimento") VALUES (16,'Sensore','09.16.2009 08:48:00 p9',38,38,'2BXdd4Y0lilmmQt','YQRW022436');
INSERT INTO "ortiscolastici"."dispositivo" ("id","tipodispositivo","dataorarilevazione","piantadiriferimento","numeroreplica","ortodoverisiede","scuoladiriferimento") VALUES (17,'Sensore','09.16.2009 08:48:00 p9',38,38,'2BXdd4Y0lilmmQt','YQRW022436');
INSERT INTO "ortiscolastici"."dispositivo" ("id","tipodispositivo","dataorarilevazione","piantadiriferimento","numeroreplica","ortodoverisiede","scuoladiriferimento") VALUES (18,'Arduino','04.11.2018 05:29:00 p4',26,26,'rZRk5pQOpGnsAf8iyh','VCKC082963');
INSERT INTO "ortiscolastici"."dispositivo" ("id","tipodispositivo","dataorarilevazione","piantadiriferimento","numeroreplica","ortodoverisiede","scuoladiriferimento") VALUES (19,'Sensore','04.11.2018 05:29:00 p4',26,26,'3UsMqvuz4URf2vXSLH','LATB225291');
INSERT INTO "ortiscolastici"."dispositivo" ("id","tipodispositivo","dataorarilevazione","piantadiriferimento","numeroreplica","ortodoverisiede","scuoladiriferimento") VALUES (20,'Sensore','04.11.2018 05:29:00 p4',26,26,'NpJmYdBXRUyi5','QHND731760');
INSERT INTO "ortiscolastici"."dispositivo" ("id","tipodispositivo","dataorarilevazione","piantadiriferimento","numeroreplica","ortodoverisiede","scuoladiriferimento") VALUES (21,'Sensore','02.05.2014 10:51:00 p2',32,32,'NpJmYdBXRUyi5','QHND731760');
INSERT INTO "ortiscolastici"."dispositivo" ("id","tipodispositivo","dataorarilevazione","piantadiriferimento","numeroreplica","ortodoverisiede","scuoladiriferimento") VALUES (22,'Sensore','03.24.2023 09:03:00 p3',32,32,'uFcQPzrPfR','KINJ948332');
INSERT INTO "ortiscolastici"."dispositivo" ("id","tipodispositivo","dataorarilevazione","piantadiriferimento","numeroreplica","ortodoverisiede","scuoladiriferimento") VALUES (23,'Arduino','09.19.2005 02:01:00 p9',42,42,'uFcQPzrPfR','KINJ948332');
INSERT INTO "ortiscolastici"."dispositivo" ("id","tipodispositivo","dataorarilevazione","piantadiriferimento","numeroreplica","ortodoverisiede","scuoladiriferimento") VALUES (24,'Sensore','09.19.2005 02:01:00 p9',42,42,'uFcQPzrPfR','KINJ948332');
INSERT INTO "ortiscolastici"."dispositivo" ("id","tipodispositivo","dataorarilevazione","piantadiriferimento","numeroreplica","ortodoverisiede","scuoladiriferimento") VALUES (25,'Sensore','09.19.2005 02:01:00 p9',42,42,'j','OXEM815286');
INSERT INTO "ortiscolastici"."dispositivo" ("id","tipodispositivo","dataorarilevazione","piantadiriferimento","numeroreplica","ortodoverisiede","scuoladiriferimento") VALUES (26,'Sensore','11.13.2013 00:52:00 p11',31,31,'XYNU5FT','MGCO209282');
INSERT INTO "ortiscolastici"."dispositivo" ("id","tipodispositivo","dataorarilevazione","piantadiriferimento","numeroreplica","ortodoverisiede","scuoladiriferimento") VALUES (27,'Arduino','07.04.2021 01:57:00 p7',31,31,'XYNU5FT','MGCO209282');
INSERT INTO "ortiscolastici"."dispositivo" ("id","tipodispositivo","dataorarilevazione","piantadiriferimento","numeroreplica","ortodoverisiede","scuoladiriferimento") VALUES (28,'Arduino','08.24.2005 10:25:00 p8',43,43,'pUaGTG1m','MGCO209282');
INSERT INTO "ortiscolastici"."dispositivo" ("id","tipodispositivo","dataorarilevazione","piantadiriferimento","numeroreplica","ortodoverisiede","scuoladiriferimento") VALUES (29,'Arduino','08.24.2005 10:25:00 p8',43,43,'rZRk5pQOpGnsAf8iyh','VCKC082963');
INSERT INTO "ortiscolastici"."dispositivo" ("id","tipodispositivo","dataorarilevazione","piantadiriferimento","numeroreplica","ortodoverisiede","scuoladiriferimento") VALUES (30,'Arduino','08.24.2005 10:25:00 p8',43,43,'rZRk5pQOpGnsAf8iyh','VCKC082963');
INSERT INTO "ortiscolastici"."dispositivo" ("id","tipodispositivo","dataorarilevazione","piantadiriferimento","numeroreplica","ortodoverisiede","scuoladiriferimento") VALUES (31,'Sensore','01.22.2012 00:29:00 p1',49,49,'FdEhAIMFZTQHSF6FtTHVX','MQKH080804');
INSERT INTO "ortiscolastici"."dispositivo" ("id","tipodispositivo","dataorarilevazione","piantadiriferimento","numeroreplica","ortodoverisiede","scuoladiriferimento") VALUES (32,'Sensore','02.05.2014 10:51:00 p2',32,32,'FdEhAIMFZTQHSF6FtTHVX','MQKH080804');
INSERT INTO "ortiscolastici"."dispositivo" ("id","tipodispositivo","dataorarilevazione","piantadiriferimento","numeroreplica","ortodoverisiede","scuoladiriferimento") VALUES (33,'Arduino','02.14.2012 02:06:00 p2',32,32,'D','PNXS039570');
INSERT INTO "ortiscolastici"."dispositivo" ("id","tipodispositivo","dataorarilevazione","piantadiriferimento","numeroreplica","ortodoverisiede","scuoladiriferimento") VALUES (34,'Arduino','03.17.2014 09:30:00 p3',30,30,'D','PNXS039570');
INSERT INTO "ortiscolastici"."dispositivo" ("id","tipodispositivo","dataorarilevazione","piantadiriferimento","numeroreplica","ortodoverisiede","scuoladiriferimento") VALUES (35,'Arduino','09.24.2003 07:00:00 p9',30,30,'D','PNXS039570');
INSERT INTO "ortiscolastici"."dispositivo" ("id","tipodispositivo","dataorarilevazione","piantadiriferimento","numeroreplica","ortodoverisiede","scuoladiriferimento") VALUES (36,'Sensore','03.02.2001 04:27:00 p3',30,30,'2BXdd4Y0lilmmQt','YQRW022436');
INSERT INTO "ortiscolastici"."dispositivo" ("id","tipodispositivo","dataorarilevazione","piantadiriferimento","numeroreplica","ortodoverisiede","scuoladiriferimento") VALUES (37,'Arduino','06.04.2007 05:44:00 p6',40,40,'2BXdd4Y0lilmmQt','YQRW022436');
INSERT INTO "ortiscolastici"."dispositivo" ("id","tipodispositivo","dataorarilevazione","piantadiriferimento","numeroreplica","ortodoverisiede","scuoladiriferimento") VALUES (38,'Sensore','11.02.2022 02:16:00 p11',40,40,'sujChvJd0','KINJ948332');
INSERT INTO "ortiscolastici"."dispositivo" ("id","tipodispositivo","dataorarilevazione","piantadiriferimento","numeroreplica","ortodoverisiede","scuoladiriferimento") VALUES (39,'Sensore','08.24.2005 10:25:00 p8',43,43,'sujChvJd0','KINJ948332');
INSERT INTO "ortiscolastici"."dispositivo" ("id","tipodispositivo","dataorarilevazione","piantadiriferimento","numeroreplica","ortodoverisiede","scuoladiriferimento") VALUES (40,'Sensore','08.24.2005 10:25:00 p8',43,43,'weIJAKRu','HTLL701604');
INSERT INTO "ortiscolastici"."dispositivo" ("id","tipodispositivo","dataorarilevazione","piantadiriferimento","numeroreplica","ortodoverisiede","scuoladiriferimento") VALUES (41,'Sensore','08.24.2005 10:25:00 p8',43,43,'weIJAKRu','HTLL701604');
INSERT INTO "ortiscolastici"."dispositivo" ("id","tipodispositivo","dataorarilevazione","piantadiriferimento","numeroreplica","ortodoverisiede","scuoladiriferimento") VALUES (42,'Arduino','05.09.2020 07:24:00 p5',50,50,'q030THX72JBK5Sn0','EVMM088541');
INSERT INTO "ortiscolastici"."dispositivo" ("id","tipodispositivo","dataorarilevazione","piantadiriferimento","numeroreplica","ortodoverisiede","scuoladiriferimento") VALUES (43,'Sensore','05.09.2020 07:24:00 p5',50,50,'NpJmYdBXRUyi5','QHND731760');
INSERT INTO "ortiscolastici"."dispositivo" ("id","tipodispositivo","dataorarilevazione","piantadiriferimento","numeroreplica","ortodoverisiede","scuoladiriferimento") VALUES (44,'Sensore','02.14.2012 02:06:00 p2',32,32,'NpJmYdBXRUyi5','QHND731760');
INSERT INTO "ortiscolastici"."dispositivo" ("id","tipodispositivo","dataorarilevazione","piantadiriferimento","numeroreplica","ortodoverisiede","scuoladiriferimento") VALUES (45,'Sensore','03.24.2023 09:03:00 p3',32,32,'sujChvJd0','KINJ948332');
INSERT INTO "ortiscolastici"."dispositivo" ("id","tipodispositivo","dataorarilevazione","piantadiriferimento","numeroreplica","ortodoverisiede","scuoladiriferimento") VALUES (46,'Arduino','03.06.2023 01:02:00 p3',47,47,'weIJAKRu','HTLL701604');
INSERT INTO "ortiscolastici"."dispositivo" ("id","tipodispositivo","dataorarilevazione","piantadiriferimento","numeroreplica","ortodoverisiede","scuoladiriferimento") VALUES (47,'Sensore','05.02.2023 01:34:00 p5',48,48,'3UsMqvuz4URf2vXSLH','LATB225291');
INSERT INTO "ortiscolastici"."dispositivo" ("id","tipodispositivo","dataorarilevazione","piantadiriferimento","numeroreplica","ortodoverisiede","scuoladiriferimento") VALUES (48,'Arduino','03.17.2014 09:30:00 p3',30,30,'3UsMqvuz4URf2vXSLH','LATB225291');
INSERT INTO "ortiscolastici"."dispositivo" ("id","tipodispositivo","dataorarilevazione","piantadiriferimento","numeroreplica","ortodoverisiede","scuoladiriferimento") VALUES (49,'Sensore','08.03.2019 01:55:00 p8',30,30,'uFcQPzrPfR','KINJ948332');
INSERT INTO "ortiscolastici"."dispositivo" ("id","tipodispositivo","dataorarilevazione","piantadiriferimento","numeroreplica","ortodoverisiede","scuoladiriferimento") VALUES (50,'Sensore','09.24.2003 07:00:00 p9',30,30,'uFcQPzrPfR','KINJ948332');



--Parte II, punto 6
--Interrogazione a: determinare le scuole che, pur avendo un finanziamento per il progetto, non hanno inserito rilevazioni in questo anno scolastico.
SELECT Scuola.CodiceMeccanografico, Scuola.NomeIstituto
FROM Scuola JOIN Classe ON Scuola.CodiceMeccanografico = Classe.CodiceMecc JOIN RaccoltaDati ON (Classe.CodiceMecc = RaccoltaDati.CodiceMeccIns OR RaccoltaDati.CodiceMeccRil = Scuola.CodiceMeccanografico)
WHERE Scuola.TipoFinanziamento IS NOT NULL AND Scuola.CodiceMeccanografico NOT IN (SELECT Scuola.CodiceMeccanografico
                                                                                   FROM Scuola JOIN Classe ON Scuola.CodiceMeccanografico = Classe.CodiceMecc 
                                                                                   JOIN RaccoltaDati ON  (RaccoltaDati.CodiceMeccIns = Scuola.CodiceMeccanografico OR RaccoltaDati.CodiceMeccRil = Scuola.CodiceMeccanografico));

--Interrogazione b: determinare le specie utilizzate in tutte le provincie in cui ci sono scuole aderenti al progetto 
--(abbiamo utilizzato provincie e non comuni per come abbiamo strutturato le nostre relazioni).
SELECT DISTINCT Specie.NomeScientifico
FROM Pianta JOIN Specie ON Pianta.NomeScientifico = Specie.NomeScientifico JOIN 
	 Orto ON Orto.CodiceMecc = Pianta.ScuolaDiRiferimento AND Orto.Nome = Pianta.Nome JOIN 
	 Scuola ON Scuola.CodiceMeccanografico = Orto.CodiceMecc
GROUP BY Specie.NomeScientifico, Scuola.Provincia
HAVING Scuola.Provincia NOT IN (SELECT Scuola.Provincia
                           		FROM Scuola
                           		WHERE EXISTS(SELECT Scuola.Provincia
                                       		 FROM Scuola AS X
                                        	 WHERE X.Provincia = Scuola.Provincia));

--Interrogazione c: determinare per ogni scuola l’individuo/la classe della scuola che ha effettuato più rilevazioni.
(SELECT Scuola.CodiceMeccanografico, Classe.Anno AS AnnoORCognome, Classe.Sezione AS SezioneORNome, COUNT(*) AS NumeroRilevazioniClasseORPersona
FROM RaccoltaDati JOIN Classe ON (RaccoltaDati.AnnoRil = Classe.Anno AND RaccoltaDati.SezioneRil = Classe.Sezione AND RaccoltaDati.CodiceMeccRil = Classe.CodiceMecc)
	JOIN Scuola ON Classe.CodiceMecc = Scuola.CodiceMeccanografico
GROUP BY Scuola.CodiceMeccanografico, Classe.Anno, Classe.Sezione
HAVING COUNT(*) >= ALL (SELECT COUNT(*)
					   FROM RaccoltaDati JOIN Classe ON (RaccoltaDati.AnnoRil = Classe.Anno AND RaccoltaDati.SezioneRil = Classe.Sezione AND 
							RaccoltaDati.CodiceMeccRil = Classe.CodiceMecc) JOIN Scuola X ON Classe.CodiceMecc = X.CodiceMeccanografico
					   WHERE Scuola.CodiceMeccanografico = X.CodiceMeccanografico))
UNION
(SELECT Scuola.CodiceMeccanografico, Persona.Cognome, Persona.Nome, COUNT(EmailResponsabileRilev) AS NumeroRilevazioniP
FROM RaccoltaDati JOIN Persona ON RaccoltaDati.EmailResponsabileRilev = Persona.Email JOIN Scuola ON Persona.Coinvolta = Scuola.CodiceMeccanografico
GROUP BY Scuola.CodiceMeccanografico, Persona.Email, Persona.Cognome, Persona.Nome
HAVING COUNT(EmailResponsabileRilev) >= ALL (SELECT COUNT(EmailResponsabileRilev)
											 FROM RaccoltaDati JOIN Persona ON RaccoltaDati.EmailResponsabileRilev = Persona.Email JOIN Scuola X ON 
											 	Persona.Coinvolta = X.CodiceMeccanografico
											 WHERE Scuola.CodiceMeccanografico = X.CodiceMeccanografico));
--Quando il numero di rilevazioni di una persona o di una classe della stessa scuola sono uguali, abbiamo deciso di lasciarli entrambi per farlo vedere all'utente.

--Vista: La definizione di una vista che fornisca alcune informazioni riassuntive per ogni attività di biomonitoraggio: per
--ogni gruppo e per il corrispondente gruppo di controllo mostrare il numero di piante, la specie, l’orto in cui è
--posizionato il gruppo e, su base mensile, il valore medio dei parametri ambientali e di crescita delle piante (selezionare
--almeno tre parametri, quelli che si ritengono più significativi).
CREATE VIEW InfoGruppo (gruppoID, numeroPiante, specie, orto, valMediopH, valMedioUmidità, valMedioTemp, LarghezzaPiante, LunghezzaPiante, AltezzaPiante,  gruppoIDCorrisp, numeroPianteGruppoCorrisp, specieGruppoCorrisp, ortoGruppoCorrisp, valMediopHGruppoCorrisp, valMedioUmiditàGruppoCorrisp, valMedioTempGruppoCorrisp, LarghezzaPianteGruppoCorrisp, LunghezzaPianteGruppoCorrisp, AltezzaPianteGruppoCorrisp) AS 
SELECT 
	Pianta.IDg,
	COUNT(Pianta.ID),
	Pianta.NomeScientifico,
	Pianta.Nome,
	AVG(RaccoltaDati.pH),
	AVG(Umidità),
	AVG(Temperatura),
	AVG(LarghezzaChiomaFoglie_cm),
	AVG(LunghezzaChiomaFoglie_cm),
	AVG(AltezzaPianta_cm),
	Dislocazione,
	(SELECT COUNT(Pianta.ID) 
		FROM Pianta JOIN Gruppo X ON Pianta.IDg = X.ID 
		WHERE Pianta.IDg = X.Dislocazione),
	(SELECT NomeScientifico 
		FROM Pianta JOIN Gruppo X ON Pianta.IDg = X.ID 
		WHERE Pianta.IDg = X.Dislocazione), 
	(SELECT Nome 
		FROM Pianta JOIN Gruppo X ON Pianta.IDg = X.ID 
		WHERE Pianta.IDg = X.Dislocazione),
	(SELECT AVG(pH) 
		FROM RaccoltaDati JOIN Pianta ON Pianta.ID = RaccoltaDati.ID JOIN Gruppo X ON Pianta.IDg = X.ID
		WHERE X.ID = Gruppo.Dislocazione),
	(SELECT AVG(Umidità) 
		FROM RaccoltaDati JOIN Pianta ON Pianta.ID = RaccoltaDati.ID JOIN Gruppo X ON Pianta.IDg = X.ID
		WHERE X.ID = Gruppo.Dislocazione),
	(SELECT AVG(Temperatura) 
		FROM RaccoltaDati JOIN Pianta ON Pianta.ID = RaccoltaDati.ID JOIN Gruppo X ON Pianta.IDg = X.ID
		WHERE X.ID = Gruppo.Dislocazione),
	(SELECT AVG(LarghezzaChiomaFoglie_cm) 
		FROM RaccoltaDati JOIN Pianta ON Pianta.ID = RaccoltaDati.ID JOIN Gruppo X ON Pianta.IDg = X.ID
		WHERE X.ID = Gruppo.Dislocazione),
	(SELECT AVG(LunghezzaChiomaFoglie_cm) 
		FROM RaccoltaDati JOIN Pianta ON Pianta.ID = RaccoltaDati.ID JOIN Gruppo X ON Pianta.IDg = X.ID
		WHERE X.ID = Gruppo.Dislocazione),
	(SELECT AVG(AltezzaPianta_cm) 
		FROM RaccoltaDati JOIN Pianta ON Pianta.ID = RaccoltaDati.ID JOIN Gruppo X ON Pianta.IDg = X.ID
		WHERE X.ID = Gruppo.Dislocazione AND DataOraRilevazione >= (CURRENT_DATE - INTERVAL '30 days'))
FROM  Gruppo JOIN Pianta ON Gruppo.ID = Pianta.IDg JOIN RaccoltaDati ON Pianta.ID = RaccoltaDati.ID AND Pianta.NumeroReplica = RaccoltaDati.NumeroReplica 
WHERE DataOraRilevazione >= (CURRENT_DATE - INTERVAL '30 days')
GROUP BY Pianta.IDg, Pianta.NomeScientifico, Pianta.Nome, Gruppo.Dislocazione, RaccoltaDati.ID, RaccoltaDati.NumeroReplica;

--Parte II, punto 7
--Funzione a: Funzione che realizza l’abbinamento tra gruppo e gruppo di controllo nel caso di operazioni di biomonitoraggio.
CREATE OR REPLACE FUNCTION associazione_monitoraggio_controllo(IN id int, IN disl int) RETURNS void AS
$$
	BEGIN
		IF(id = disl) 
		THEN RAISE NOTICE 'id non può essere uguale a disl.';
		END IF;
		UPDATE Gruppo
		SET Dislocazione = disl
		WHERE ID = id;
		UPDATE Gruppo
		SET Dislocazione = id
		WHERE ID = disl;
	END;
$$
LANGUAGE plpgsql;

--Funzione b: Funzione che corrisponde alla seguente query parametrica: data una replica con finalità di fitobonifica e due date, determina i valori medi dei parametri rilevati per tale replica 
--nel periodo compreso tra le due date.
CREATE OR REPLACE FUNCTION media_parametri_date(DataOraRilevazione_p timestamp, ID_p int, NumeroReplica_p smallint, Data1 timestamp, Data2 timestamp) 
RETURNS TABLE (avgLarghezzaChiomaFoglie_cm numeric(5,2), avgLunghezzaChiomaFoglie_cm numeric(5,2), avgPesoFrescoChiomaFoglie_g numeric(5,2), avgPesoSeccoChiomaFoglie_g numeric(5,2), 
			   avgAltezzaPianta_cm numeric(5,2), avgLunghezzaRadicei_cm numeric(5,2), avgPesoFrescoRadici_g numeric(5,2), avgPesoSeccoRadici_g numeric(5,2), avgNumeroFiori smallint, 
			   avgNumeroFrutti smallint, avgNumeroDiFoglieDanneggiate smallint, avgPercSuperficieDanneggiataPerFoglia numeric(5,2), avgpH numeric(3,1), avgUmidità numeric(5,2), 
			   avgTemperatura numeric(3,1)) AS
$$
	BEGIN
		IF(Data1 > Data2)
		THEN RAISE EXCEPTION 'Intervallo di date non valido.';
		END IF;
		RETURN QUERY
		SELECT DataOraRilevazione, ID, NumeroReplica, AVG(LarghezzaChiomaFoglie_cm) AS avgLarghezzaChiomaFoglie_cm, AVG(LunghezzaChiomaFoglie_cm) AS avgLunghezzaChiomaFoglie_cm, 
			AVG(PesoFrescoChiomaFoglie_g) AS avgPesoFrescoChiomaFoglie_g, AVG(PesoSeccoChiomaFoglie_g) AS avgPesoSeccoChiomaFoglie_g, AVG(AltezzaPianta_cm) AS avgAltezzaPianta_cm, 
			AVG(LunghezzaRadicei_cm) AS avgLunghezzaRadicei_cm, AVG(PesoFrescoRadici_g) AS avgPesoFrescoRadici_g, AVG(PesoSeccoRadici_g) AS avgPesoSeccoRadici_g, AVG(NumeroFiori) AS 
			avgNumeroFiori, AVG(NumeroFrutti) AS avgNumeroFrutti, AVG(NumeroDiFoglieDanneggiate) AS avgNumeroDiFoglieDanneggiate, AVG(PercSuperficieDanneggiataPerFoglia) AS 
			avgPercSuperficieDanneggiataPerFoglia, AVG(pH) AS avgpH, AVG(Umidità) AS avgUmidità, AVG(Temperatura) AS avgTemperatura
		FROM RaccoltaDati JOIN Pianta ON (RaccoltaDati.ID = Pianta.ID AND RaccoltaDati.NumeroReplica = Pianta.NumeroReplica) JOIN Orto ON (Pianta.Nome = Orto.Nome AND 
			Pianta.ScuolaDiRiferimento = Orto.CodiceMecc)
		GROUP BY DataOraRilevazione, ID, NumeroReplica
		HAVING Attività = 'Fitobonifica' AND DataOraRilevazione = DataOraRilevazione_p AND ID = ID_p AND NumeroReplica = NumeroReplica_p AND (DataOraRilevazione_p BETWEEN Data1 AND Data2);
	END;
$$ LANGUAGE plpgsql;

--Parte II, punto 8
--Trigger a: Verifica del vincolo che ogni scuola dovrebbe concentrarsi su tre specie e ogni gruppo dovrebbe contenere 20 repliche.
CREATE OR REPLACE FUNCTION piante_scuola() RETURNS trigger AS
$piante_scuola$
	BEGIN
		IF EXISTS(
			SELECT *
			FROM Pianta
			GROUP BY ScuolaDiAppartenenza
			HAVING COUNT(DISTINCT NomeScientifico) > 3 OR (SELECT COUNT(*)
														   FROM Pianta
									         			   GROUP BY IDg) > 20
		)
		THEN RAISE EXCEPTION 'Ogni scuola si deve concentrare su 3 specie e ogni gruppo deve contenere 20 repliche!';
		END IF;
		RETURN NEW;
	END;
$piante_scuola$ LANGUAGE plpgsql;
CREATE TRIGGER piante_scuola
BEFORE INSERT OR UPDATE ON Pianta
FOR EACH ROW
EXECUTE PROCEDURE piante_scuola();

--Trigger b: Generazione di un messaggio (o inserimento di una informazione di warning in qualche tabella) quando viene rilevato un valore decrescente per un parametro di biomassa.
CREATE OR REPLACE FUNCTION biomassa_decrescente() RETURNS trigger AS
$biomassa_decrescente$
	BEGIN
		IF EXISTS(
			SELECT *
			FROM RaccoltaDati
			WHERE NEW.ID = ID AND NEW.NumeroReplica = NumeroReplica AND NEW.DataOraRilevazione > DataOraRilevazione
				AND(NEW.LarghezzaChiomaFoglie_cm < LarghezzaChiomaFoglie_cm OR
				NEW.LunghezzaChiomaFoglie_cm < LunghezzaChiomaFoglie_cm OR
				NEW.PesoFrescoChiomaFoglie_g < PesoFrescoChiomaFoglie_g OR
				NEW.PesoSeccoChiomaFoglie_g < PesoSeccoChiomaFoglie_g OR
				NEW.AltezzaPianta_cm < AltezzaPianta_cm OR
				NEW.LunghezzaRadicei_cm < LunghezzaRadicei_cm)
		)
		THEN RAISE EXCEPTION 'Un parametro di biomassa per la tupla NEW è decrescente.';
		END IF;
		RETURN NEW;
	END;
$biomassa_decrescente$ LANGUAGE plpgsql;
CREATE TRIGGER biomassa_decrescente
AFTER INSERT OR UPDATE ON RaccoltaDati
FOR EACH ROW
EXECUTE PROCEDURE biomassa_decrescente();