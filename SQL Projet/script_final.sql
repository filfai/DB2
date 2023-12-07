DROP SCHEMA IF EXISTS projet CASCADE;
CREATE SCHEMA projet;

CREATE TABLE projet.etudiants (
    et_id SERIAL PRIMARY KEY,
    et_nom VARCHAR(50) NOT NULL CHECK (et_nom <> ''),
    et_prenom VARCHAR(50) NOT NULL CHECK (et_prenom <> ''),
    et_email VARCHAR(100) NOT NULL CHECK (et_email LIKE '%@student.vinci.be'),
    et_mdp VARCHAR(100) NOT NULL CHECK (et_mdp <> ''),
    et_semestre CHAR(2) CHECK (et_semestre IN ('Q1', 'Q2')),
    et_nb_candidatures_en_attente INTEGER DEFAULT 0 NOT NULL
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
    of_nb_candidatures_en_attente INTEGER DEFAULT 0 NOT NULL,
    FOREIGN KEY (of_entreprise) REFERENCES projet.entreprises (en_id)
);

CREATE TABLE projet.candidatures (
    ca_etudiant INTEGER NOT NULL,
    ca_offre_stage INTEGER NOT NULL,
    FOREIGN KEY (ca_etudiant) REFERENCES projet.etudiants (et_id),
    FOREIGN KEY (ca_offre_stage) REFERENCES projet.offres_de_stage (of_id),
    PRIMARY KEY (ca_etudiant, ca_offre_stage),
    ca_motivations TEXT NOT NULL CHECK(ca_motivations <> ''),
    ca_etat VARCHAR(10) NOT NULL CHECK ( ca_etat IN ('en_attente', 'acceptee', 'refusee', 'annulee')) DEFAULT 'en_attente'
);

CREATE TABLE projet.mot_stage (
    ms_mot INTEGER NOT NULL,
    ms_stage INTEGER NOT NULL,
    FOREIGN KEY (ms_mot) REFERENCES projet.mots_cles (mot_id),
    FOREIGN KEY (ms_stage) REFERENCES projet.offres_de_stage (of_id),
    PRIMARY KEY (ms_mot, ms_stage)
);

-- CHECK VIA TRIGGER

CREATE OR REPLACE FUNCTION projet.en_insertionsCandidatures() RETURNS TRIGGER AS $$
DECLARE
    of_nb_ca_en_attente INTEGER;
    id_offre INTEGER := new.ca_offre_stage;
    et_nb_ca_en_attente INTEGER;
BEGIN

    SELECT COUNT(*)
    FROM projet.candidatures
    WHERE ca_offre_stage = id_offre
    AND ca_etat = 'en_attente'
    INTO of_nb_ca_en_attente;

    RAISE NOTICE 'HZEHFDHZEF %', of_nb_ca_en_attente;

    SELECT COUNT(*)
    FROM projet.candidatures
    WHERE ca_etudiant = NEW.ca_etudiant
    AND ca_etat = 'en_attente'
    INTO et_nb_ca_en_attente;

    UPDATE projet.offres_de_stage
    SET of_nb_candidatures_en_attente = of_nb_ca_en_attente
    WHERE of_id = id_offre;

    UPDATE projet.etudiants
    SET et_nb_candidatures_en_attente = et_nb_ca_en_attente
    WHERE et_id = NEW.ca_etudiant;

    RETURN NEW;

END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE TRIGGER trigger_on_insert_candidatures AFTER INSERT OR UPDATE ON projet.candidatures
    FOR EACH ROW EXECUTE PROCEDURE projet.en_insertionsCandidatures();


-- INSERTS

INSERT INTO projet.etudiants (et_nom, et_prenom, et_email, et_mdp, et_semestre)
VALUES ('Jean', 'De', 'j.d@student.vinci.be', '$2a$10$hLkfS6z9soHG.vQyoPmdwuxcJbHd0vdJObiyZHry1ZivsGIYGvRFe', 'Q2'),
       ('Marc', 'Du', 'm.d@student.vinci.be', '$2a$10$o15W1.MwpFXk954.XW5mq.k93A1Vzl0LQ3s5FHKlHsXAqj8bNrvrq', 'Q1');

INSERT INTO projet.mots_cles(mot)
VALUES ('Java'),
       ('Web'),
       ('Python');

INSERT INTO projet.entreprises  (en_nom, en_email, en_adresse, en_mdp, en_code)
VALUES ('VINCI', 'vinci@vinci.com', 'Rue du Vinci, 111 Bruxelles', '$2a$10$eWmjfWqoF/dqglIqR957Nem0s69upflo.e1EBkz4Fxf9kG84i92z.', 'VIN'),
       ('ULB', 'ulb@vinci.com', 'Rue ULB, 222 Bruxelles', '$2a$10$ihbJ..p4AOGh17./4wTOlemEbFa.MZPM8pvmGRrS5xZ4mcQ.hOpGK', 'ULB');

INSERT INTO projet.offres_de_stage(of_entreprise, of_description, of_semestre, of_code, of_etat)
VALUES (1, 'stage SAP', 'Q2', 'VIN1', 'validee'),
       (1, 'stage BI', 'Q2', 'VIN2', DEFAULT),
       (1, 'stage Unity', 'Q2', 'VIN3', DEFAULT),
       (1, 'stage IA', 'Q2', 'VIN4', 'validee'),
       (1, 'stage mobile', 'Q1', 'VIN5', 'validee'),
       (2, 'stage javascript', 'Q2', 'ULB1', 'validee');

INSERT INTO projet.mot_stage(ms_mot, ms_stage)
VALUES (1, 3),
       (1, 5);

INSERT INTO projet.candidatures(ca_etudiant, ca_offre_stage, ca_motivations, ca_etat)
VALUES (1, 4, 'ezaje', DEFAULT),
       (2, 5, 'azjezej', DEFAULT);

-- Application Entreprise

-- Encoder Offre

-- CHECK SI L'entreprise a deja une offre attribuee pour ce semestre
CREATE OR REPLACE FUNCTION projet.en_checkSiOffreAttribuee() RETURNS TRIGGER AS $$
DECLARE
    id_entreprise INTEGER := NEW.of_entreprise;
    semestre VARCHAR(2) := NEW.of_semestre;
BEGIN
    IF EXISTS(SELECT *
                  FROM projet.offres_de_stage
                  WHERE of_entreprise = id_entreprise
                  AND of_semestre = semestre
                  AND of_etat = 'attribuee')
        THEN RAISE 'Erreur : vous avez déjà une offre de stage attribuée pour ce semestre';
    END IF;

    RETURN NEW;
end;
$$ LANGUAGE plpgsql;

CREATE TRIGGER en_trigger_check_ajoutOffre AFTER INSERT ON projet.offres_de_stage
    FOR EACH ROW EXECUTE PROCEDURE projet.en_checkSiOffreAttribuee();

CREATE OR REPLACE FUNCTION projet.en_ajouterOffre(id_entreprise INTEGER, description TEXT, semestre VARCHAR(2)) RETURNS VOID AS $$
    DECLARE
        code_a_ajouter VARCHAR(7);
        code_entreprise VARCHAR(3);
        chiffre_du_stage INTEGER;
    BEGIN


        -- Génération du code du stage
        SELECT COUNT(*) + 1
        FROM projet.offres_de_stage of
        WHERE of.of_entreprise = id_entreprise
        INTO chiffre_du_stage;

        SELECT en.en_code
        FROM projet.entreprises en
        WHERE en.en_id = id_entreprise
        INTO code_entreprise;

        code_a_ajouter := code_entreprise || chiffre_du_stage;

        --Insertion dans la table offres de stage
        INSERT INTO projet.offres_de_stage (of_entreprise, of_description, of_semestre, of_etat, of_code)
        VALUES (
            id_entreprise, description, semestre, DEFAULT, code_a_ajouter
        );
    RETURN;
    END;
$$ LANGUAGE plpgsql;

-- 3 Ajouter mot cles

CREATE OR REPLACE FUNCTION projet.en_checkAssignerMotCle() RETURNS TRIGGER AS $$
DECLARE

BEGIN
    -- CHECK SI LE STAGE A DEJA 3 MOTS CLES
    IF (3 < (SELECT COUNT(ms_mot)
             FROM projet.mot_stage
             WHERE ms_stage = NEW.ms_stage))
        THEN RAISE 'Erreur : Le stage a déjà 3 mots-clés';
    END IF;

    -- CHECK SI L'ETAT DE L'OFFRE PERMET L'INSERTION
    IF(EXISTS(
            SELECT *
            FROM projet.offres_de_stage
            WHERE of_id = NEW.ms_stage
            AND (of_etat = 'attribuee' OR of_etat = 'annulee'))
        )
        THEN RAISE 'Erreur : impossible d''ajouter un mot-cle a ce stage ';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER en_trigger_insertion_mot_stage AFTER INSERT ON projet.mot_stage
    FOR EACH ROW EXECUTE PROCEDURE projet.en_checkAssignerMotCle();

CREATE OR REPLACE FUNCTION projet.en_ajouterMotCle(param_id_entreprise INTEGER, param_code_stage VARCHAR(7), param_mot VARCHAR(50)) RETURNS VOID AS $$
    DECLARE
        id_stage INTEGER;
        id_mot INTEGER;
    BEGIN

        -- CHECK SI LE MOT EXISTE
        IF NOT EXISTS(
            SELECT mot_id
            FROM projet.mots_cles
            WHERE mot = param_mot
            )
            THEN RAISE 'Erreur : Ce mot ne figure pas sur la liste des mots-clés';
            ELSE
                SELECT mot_id
                FROM projet.mots_cles
                WHERE mot = param_mot
                INTO id_mot;
        END IF;

        -- INITIALISATION DE ID_STAGE
        SELECT of_id
        FROM projet.offres_de_stage
        WHERE of_code = param_code_stage
        INTO id_stage;

        -- CHECK SI L'ENTREPRISE EST BIEN CELLE QUI A EMISE L'OFFRE DE STAGE OU QUE C'EST PAS DANS ETAT ANNULEE OU ATTRIBUEE ?
        IF ((param_id_entreprise <> (SELECT of_entreprise
                                     FROM projet.offres_de_stage
                                     WHERE of_code = param_code_stage)))
               THEN RAISE 'Erreur : Le code du stage est invalide ';
        END IF;

        -- INSERTION A MOT_STAGE

        INSERT INTO projet.mot_stage (ms_mot, ms_stage) VALUES (id_mot, id_stage);
end;
$$ LANGUAGE plpgsql;


-- 4 View des offres

CREATE OR REPLACE VIEW projet.en_view_offres AS
    SELECT of.of_code AS code_du_stage, of.of_description AS description, of.of_semestre AS semestre,
       of.of_etat AS etat, of.of_nb_candidatures_en_attente, COALESCE(et_nom, 'pas attribuée') AS nom_etudiant, of_entreprise
    FROM projet.offres_de_stage of LEFT JOIN projet.candidatures ca ON of.of_id = ca.ca_offre_stage AND ca_etat = 'acceptee'
    LEFT JOIN projet.etudiants et ON et.et_id = ca.ca_etudiant;

-- 5 View des candidatures

CREATE OR REPLACE VIEW projet.en_voir_candidatures AS
    SELECT ca.ca_etat, et.et_nom, et.et_prenom, et.et_email, ca.ca_motivations, of_code, of_entreprise
    FROM projet.offres_de_stage of JOIN projet.candidatures ca ON of.of_id = ca.ca_offre_stage
    JOIN projet.etudiants et ON ca.ca_etudiant = et.et_id;

-- 6 Selectionner un etudiant

CREATE OR REPLACE FUNCTION projet.en_selectionnerEtudiant(param_id_entreprise INTEGER, param_code_offre VARCHAR(7), param_email_etudiant VARCHAR(100)) RETURNS VOID AS $$
    DECLARE
        id_offre INTEGER;
        id_etudiant INTEGER;
        semestre VARCHAR(2);
    BEGIN

        SELECT of_id
        FROM projet.offres_de_stage
        WHERE of_code = param_code_offre
        INTO id_offre;

        SELECT et_id
        FROM projet.etudiants
        WHERE et_email = param_email_etudiant
        INTO id_etudiant;

        IF (NOT EXISTS(
                SELECT *
                FROM projet.offres_de_stage
                WHERE of_entreprise = param_id_entreprise
                AND of_code = param_code_offre
            ))
            THEN RAISE 'Ce code de stage est invalide ou ne s''agit pas de votre offre';
        END IF;

        IF (NOT EXISTS(
                SELECT *
                FROM projet.offres_de_stage of
                    JOIN projet.candidatures ca ON id_offre = ca.ca_offre_stage
                WHERE of_entreprise = param_id_entreprise
                AND of_code = param_code_offre
                AND of_etat = 'validee' AND ca_etat = 'en_attente' AND ca_etudiant = id_etudiant
            ))
            THEN RAISE 'L''offre ou la canditature n''est pas valide';
        END IF;

        SELECT of_semestre
        FROM projet.offres_de_stage
        WHERE of_id = id_offre
        INTO semestre;

        -- ANNULATION DES AUTRES CA DE L'ETUDIANT

        UPDATE projet.candidatures
        SET ca_etat = 'annulee'
        WHERE ca_etudiant = id_etudiant
        AND ca_offre_stage <> id_offre;

        -- CA_ETAT REFUSEE POUR LES AUTRES CANDIDATURES DE CETTE OFFRE

        UPDATE projet.candidatures
        SET ca_etat = 'refusee'
        WHERE ca_etudiant <> id_etudiant
        AND ca_offre_stage = id_offre;

        -- ANNULER LES AUTRES OFFRES DE L'ENTREPRISE DU SEMESTRE

        UPDATE projet.offres_de_stage
        SET of_etat = 'annulee'
        WHERE of_id <> id_offre
        AND of_entreprise = param_id_entreprise
        AND of_semestre = semestre;

        UPDATE projet.offres_de_stage
        SET of_etat = 'attribuee'
        WHERE of_code = param_code_offre;

        UPDATE projet.candidatures
        SET ca_etat = 'acceptee'
        WHERE ca_offre_stage = id_offre
        AND ca_etudiant = id_etudiant;

    END;
$$ LANGUAGE plpgsql;

-- TRIGGER POUR REFUSER LES CA DES OFFRES ANNULEES (UTILISEE AUSSI AU 7)

CREATE OR REPLACE FUNCTION projet.en_annulationOffre() RETURNS TRIGGER AS $$
DECLARE
BEGIN
    IF (NEW.of_etat = OLD.of_etat OR NEW.of_etat <> 'annulee')
        THEN RETURN OLD;
    END IF;

    UPDATE projet.candidatures
    SET ca_etat = 'refusee'
    WHERE ca_offre_stage = NEW.of_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER en_trigger_annulation_offre AFTER UPDATE ON projet.offres_de_stage
    FOR EACH ROW EXECUTE PROCEDURE projet.en_annulationOffre();

-- 7 Annuler offre

CREATE OR REPLACE FUNCTION projet.en_annulerOffre(param_id_entreprise INTEGER, param_code_stage VARCHAR(7)) RETURNS VOID AS $$
    DECLARE
        id_offre INTEGER;
    BEGIN

        SELECT of_id
        FROM projet.offres_de_stage
        WHERE of_code = param_code_stage
        INTO id_offre;

        IF (NOT EXISTS(
            SELECT *
            FROM projet.offres_de_stage
            WHERE of_entreprise = param_id_entreprise
            AND of_code = param_code_stage
            AND (of_etat <> 'attribuee' AND of_etat <> 'annulee')
            ))
            THEN RAISE 'Erreur : offre invalide';
        END IF;

        UPDATE projet.offres_de_stage
        SET of_etat = 'annulee'
        WHERE of_id = id_offre;

END;
$$ LANGUAGE plpgsql;
