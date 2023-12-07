-- App Professeur

-- 1
CREATE OR REPLACE FUNCTION projet.pr_encoderEtudiant(param_nom VARCHAR(50), param_prenom VARCHAR(50), param_email VARCHAR(100), param_semestre VARCHAR(2), param_mdp VARCHAR(100)) RETURNS VOID AS $$
DECLARE
BEGIN
    INSERT INTO projet.etudiants (et_nom, et_prenom, et_email, et_mdp, et_semestre)
    VALUES (param_nom, param_prenom, param_email, param_mdp, param_semestre);
END;
$$ LANGUAGE plpgsql;

-- 2

CREATE OR REPLACE FUNCTION projet.pr_encoderEntreprise(param_nom VARCHAR(50), param_adresse VARCHAR(200), param_email VARCHAR(100), param_code VARCHAR(3), param_mdp VARCHAR(100)) RETURNS VOID AS $$
DECLARE
BEGIN
    INSERT INTO projet.entreprises (en_nom, en_email, en_adresse, en_mdp, en_code)
    VALUES (param_nom, param_email, param_adresse, param_mdp, param_code);
END;
$$ LANGUAGE plpgsql;

-- 3

CREATE OR REPLACE FUNCTION projet.pr_encoderMotCle(param_mot VARCHAR(50)) RETURNS VOID AS $$
DECLARE
BEGIN
    INSERT INTO projet.mots_cles (mot)
    VALUES(param_mot);
END;
$$ LANGUAGE plpgsql;

-- 4

CREATE OR REPLACE VIEW projet.pr_view_voir_offres_nonValidees AS
    SELECT of_code, of_semestre, en_nom, of_description, en_id
    FROM projet.offres_de_stage of
        JOIN projet.entreprises en ON of.of_entreprise = en.en_id
    WHERE of_etat = 'non_validee';

-- 5

CREATE OR REPLACE FUNCTION projet.pr_validerOffre(param_code VARCHAR(7)) RETURNS VOID AS $$
DECLARE
BEGIN
    IF(EXISTS(
        SELECT *
        FROM projet.offres_de_stage
        WHERE of_code = param_code
        AND of_etat <> 'non_validee'
        ))
        THEN RAISE 'Cette offre de stage ne peut pas être validée';
    END IF;

    UPDATE projet.offres_de_stage
    SET of_etat = 'validee'
    WHERE of_code = param_code;
END;
$$ LANGUAGE plpgsql;

-- 6

CREATE OR REPLACE VIEW projet.pr_view_voir_offres_validees AS
    SELECT of_code, of_semestre, en_nom, of_description, en_id
    FROM projet.offres_de_stage of
        JOIN projet.entreprises en ON of.of_entreprise = en.en_id
    WHERE of_etat = 'validee';

-- 7

CREATE OR REPLACE VIEW projet.pr_view_voirEtudiantsSansStages AS
    SELECT DISTINCT et_nom, et_prenom, et_email, et_semestre, et_nb_candidatures_en_attente
    FROM projet.etudiants et LEFT JOIN projet.candidatures ca ON et.et_id = ca.ca_etudiant
    WHERE et_id NOT IN (SELECT DISTINCT ca_etudiant
                          FROM projet.candidatures
                          WHERE ca_etat = 'acceptee');

-- 8

CREATE OR REPLACE VIEW projet.pr_view_voirOffresAttribuees AS
    SELECT of_code, en_nom, et_nom, et_prenom
    FROM projet.etudiants et JOIN projet.candidatures ca ON et.et_id = ca.ca_etudiant
        JOIN projet.offres_de_stage of ON ca.ca_offre_stage = of.of_id
        JOIN projet.entreprises en ON of.of_entreprise = en.en_id
    WHERE of_etat = 'attribuee'
    AND ca_etat = 'acceptee';

SELECT * FROM projet.offres_de_stage