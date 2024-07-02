set search_path to ortiscolastici;
--Creazione ruoli
CREATE ROLE Studente;
CREATE ROLE Insegnante;
CREATE ROLE ReferenteScuola;
CREATE ROLE ReferenteIstituto;
CREATE ROLE GestoreGlobaleProgetto;
--Concessione privilegi ai ruoli
GRANT USAGE ON SCHEMA ortiscolastici TO Studente;
GRANT USAGE ON SCHEMA ortiscolastici TO Insegnante;
GRANT USAGE ON SCHEMA ortiscolastici TO ReferenteScuola;
GRANT USAGE ON SCHEMA ortiscolastici TO ReferenteIstituto;
GRANT USAGE ON SCHEMA ortiscolastici TO GestoreGlobaleProgetto;
GRANT INSERT, DELETE, UPDATE, SELECT ON RaccoltaDati, Dispositivo TO Studente;
GRANT INSERT, DELETE, UPDATE, SELECT ON Gruppo, Pianta, Specie, Orto TO Insegnante WITH GRANT OPTION;
GRANT INSERT, DELETE, UPDATE, SELECT ON Classe TO ReferenteScuola WITH GRANT OPTION;
GRANT INSERT, DELETE, UPDATE, SELECT ON Scuola TO ReferenteIstituto WITH GRANT OPTION;
GRANT INSERT, DELETE, UPDATE, SELECT ON Persona TO GestoreGlobaleProgetto WITH GRANT OPTION;
--Gerarchie
GRANT Studente TO Insegnante;
GRANT Insegnante TO ReferenteScuola;
GRANT ReferenteScuola TO ReferenteIstituto;
GRANT ReferenteIstituto TO GestoreGlobaleProgetto;
--Utenti
CREATE USER nomeutente1 PASSWORD 'Password1';
CREATE USER nomeutente2 PASSWORD 'Password2';
CREATE USER nomeutente3 PASSWORD 'Password3';
CREATE USER nomeutente4 PASSWORD 'Password4';
CREATE USER nomeutente5 PASSWORD 'Password5';
--Assegnazione dei ruoli agli utenti
GRANT Studente TO nomeutente1;
GRANT Insegnante TO nomeutente2;
GRANT ReferenteScuola TO nomeutente3;
GRANT ReferenteIstituto TO nomeutente4;
GRANT GestoreGlobaleProgetto TO nomeutente5;