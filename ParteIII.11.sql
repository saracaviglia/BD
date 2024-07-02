--Parte III, punto 11

--Script SQL per la creazione delle tabelle con un campo 'Dummy' per aumentarne la size
set search_path to ortiscolastici;

CREATE TABLE Scuola(  
	CodiceMeccanografico char(10) CHECK (CodiceMeccanografico ~ '^[A-Z0-9]+$'), 
	NomeIstituto varchar(47) CHECK (NomeIstituto ~ '^[A-Za-z]+$') NOT NULL, --numero di caratteri ottenuto ricercando su internet 
	Provincia char(2) CHECK (Provincia ~ '^[A-Z]+$') NOT NULL, --sigla 
	CicloIstruzione varchar(7) CHECK (CicloIstruzione IN('Primo','Secondo')) NOT NULL,	--numero  caratteri per 'secondo' 
	TipoFinanziamento varchar(110), --numero di caratteri ottenuto ricercando su internet  
	Dummy char(1800) NOT NULL, --Variabile per aumentare la size
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
    Dummy char(1800) NOT NULL, --Variabile per aumentare la size
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
    Dummy char(1800) NOT NULL, --Variabile per aumentare la size
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
    Dummy char(1800) NOT NULL, --Variabile per aumentare la size
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
      Dummy char(1800) NOT NULL, --Variabile per aumentare la size
	  OrtoDoveRisiede varchar(25) NOT NULL,
	  ScuolaDiRiferimento char(10) NOT NULL,
	  PRIMARY KEY (ID),
	  FOREIGN KEY (DataOraRilevazione, PiantaDiRiferimento, NumeroReplica) REFERENCES RaccoltaDati ON UPDATE CASCADE,
	  FOREIGN KEY (OrtoDoveRisiede, ScuolaDiRiferimento) REFERENCES Orto ON UPDATE CASCADE ON DELETE CASCADE
);

--Script SQL per la creazione dello schema fisico
CREATE INDEX raccoltadati_ID_index ON RaccoltaDati (ID);
CLUSTER RaccoltaDati USING raccoltadati_ID_index;

CREATE INDEX codice_mecc_index ON Scuola USING hash(CodiceMeccanografico);

CREATE INDEX nome_codicemecc_index ON Orto (Nome,CodiceMecc);
CLUSTER Orto USING nome_codicemecc_index;

--Script SQL per la specifica delle interrogazioni contenute nel carico di lavoro
--Interrogazione 1: Determina tutte le raccolte dati con ID maggiore di 5.
SELECT *
FROM RaccoltaDati
WHERE RaccoltaDati.ID > 5;

--Interrogazione 2: Determina le classi presenti in una singola scuola.
SELECT Classe.Anno, Classe.Sezione
FROM Scuola JOIN Classe ON Classe.codiceMecc = Scuola.CodiceMeccanografico;

--Interrogazione 3: Identifica tutti i dispositivi Arduino utilizzati all'interno di un orto con
--attività di fitobonifica e piantati in pieno campo.
SELECT ID
FROM Dispositivo JOIN Orto ON  Dispositivo.OrtoDoverisiede = Orto.Nome AND Dispositivo.ScuolaDiRiferimento = Orto.CodiceMecc 
WHERE Dispositivo.TipoDispositivo = 'Arduino' AND Orto.Attività = 'Fitobonifica' AND Orto.Tipo = 'In pieno campo';
