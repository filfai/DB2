DROP SCHEMA IF EXISTS projet CASCADE;
CREATE SCHEMA projet;

CREATE TABLE projet.etudiants (
    et_id SERIAL PRIMARY KEY,
    et_nom VARCHAR(50) NOT NULL CHECK (et_nom <> ''),
    et_prenom VARCHAR(50) NOT NULL CHECK (et_prenom <> ''),
    et_email VARCHAR(100) NOT NULL CHECK (et_email LIKE '%@student.vinci.be'),
    et_mdp VARCHAR(100) NOT NULL CHECK (et_mdp <> ''),
    et_semestre CHAR(2) CHECK (et_semestre IN ('Q1', 'Q2')),
    et_nb_canditatures_en_attente INTEGER DEFAULT 0 NOT NULL
);

CREATE TABLE projet.entreprises (
    en_id SERIAL PRIMARY KEY,
    en_nom VARCHAR(50) NOT NULL CHECK ( en_nom <> ''),
    en_email VARCHAR(100) NOT NULL CHECK ( en_email <> '' AND en_email SIMILAR TO '_%@_%.__%'),
    en_adresse VARCHAR(200) NOT NULL CHECK ( en_adresse <> ''),
    en_mdp VARCHAR(100) NOT NULL CHECK ( en_mdp <> ''),
    en_code CHAR(3) NOT NULL UNIQUE CHECK ( en_code SIMILAR TO '[A-Z]{3}')
);

CREATE TABLE projet.mots_cles(
    mot_id SERIAL PRIMARY KEY,
    mot VARCHAR(50) NOT NULL UNIQUE CHECK (mot <> '')
);

CREATE TABLE projet.offres_de_stage (
    of_id SERIAL PRIMARY KEY,
    of_entreprise INTEGER NOT NULL,
    of_description TEXT NOT NULL CHECK (of_description <> ''),
    of_semestre CHAR(2) CHECK (of_semestre IN ('Q1', 'Q2')),
    of_etat VARCHAR(15) NOT NULL CHECK (of_etat IN ('non_validee', 'validee', 'attribuee', 'annulee')) DEFAULT 'non_validee',
    of_code VARCHAR(7) UNIQUE CHECK ( of_code SIMILAR TO '[A-Z]{3}[1-9][0-9]*'  AND of_code <> ''),
    of_nb_canditatures_en_attente INTEGER DEFAULT 0 NOT NULL,
    FOREIGN KEY (of_entreprise) REFERENCES projet.entreprises (en_id)
);

CREATE TABLE projet.canditatures (
    ca_etudiant INTEGER NOT NULL,
    ca_offre_stage INTEGER NOT NULL,
    FOREIGN KEY (ca_etudiant) REFERENCES projet.etudiants (et_id),
    FOREIGN KEY (ca_offre_stage) REFERENCES projet.offres_de_stage (of_id),
    PRIMARY KEY (ca_etudiant, ca_offre_stage),
    ca_motivations TEXT NOT NULL CHECK(ca_motivations <> ''),
    ca_etat VARCHAR(10) NOT NULL CHECK ( ca_etat IN ('en_attente', 'acceptee', 'refusee', 'annulee'))
);

CREATE TABLE projet.mot_stage (
    ms_mot INTEGER NOT NULL,
    ms_stage INTEGER NOT NULL,
    FOREIGN KEY (ms_mot) REFERENCES projet.mots_cles (mot_id),
    FOREIGN KEY (ms_stage) REFERENCES projet.offres_de_stage (of_id),
    PRIMARY KEY (ms_mot, ms_stage)
);