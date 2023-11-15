CREATE SCHEMA projet;

CREATE TABLE etudiants (
    et_id SERIAL PRIMARY KEY,
    et_nom VARCHAR(50) NOT NULL CHECK (et_nom <> ''),
    et_prenom VARCHAR(50) NOT NULL CHECK (et_prenom <> ''),
    et_email VARCHAR(100) NOT NULL CHECK (et_email LIKE '%@student.vinci.be'),
    et_mdp VARCHAR(100) NOT NULL CHECK (et_mdp <> ''),
    et_semestre CHAR(2) CHECK (et_semestre IN ('Q1', 'Q2')),
    et_nb_canditatures_en_attente INTEGER DEFAULT 0 NOT NULL
);

CREATE TABLE entreprises (
    en_id SERIAL PRIMARY KEY,
    en_nom VARCHAR(50) NOT NULL CHECK ( en_nom <> ''),
    en_email VARCHAR(100) NOT NULL CHECK ( en_email <> '' AND en_email SIMILAR TO '_%@_%.__%'),
    en_adresse VARCHAR(200) NOT NULL CHECK ( en_adresse <> ''),
    en_mdp VARCHAR(100) NOT NULL CHECK ( en_mdp <> ''),
    en_code CHAR(3) NOT NULL UNIQUE CHECK ( en_code SIMILAR TO '[A-Z]{3}')
);

CREATE TABLE mots_cles(
    mot_id SERIAL PRIMARY KEY,
    mot VARCHAR(50) NOT NULL UNIQUE CHECK (mot <> '')
);

CREATE TABLE offre_de_stage (
    of_id_offre SERIAL PRIMARY KEY,
    of_entreprise INTEGER NOT NULL,
    of_description TEXT NOT NULL CHECK (of_description <> ''),
    of_semestre CHAR(2) CHECK (of_semestre IN ('Q1', 'Q2')),
    of_etat VARCHAR(15) NOT NULL CHECK (of_etat IN ('non_validee', 'validee', 'attribuee', 'annulee')),
    of_code VARCHAR(7) CHECK (of_code SIMILAR TO ''),
    FOREIGN KEY (of_entreprise) REFERENCES entreprises (id_entreprise)
);
