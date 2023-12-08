SET search_path TO projet;

-- 1. Voir toutes les offres de stage dans l’état « validée » correspondant au semestre où l’étudiant fera son stage.
CREATE OR REPLACE FUNCTION voir_offres_validees(etudiant_id INTEGER)
RETURNS TABLE (
    of_code VARCHAR(7),
    en_nom VARCHAR(50),
    en_adresse VARCHAR(200),
    of_description TEXT,
    mots_cles TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        od.of_code,
        en.en_nom,
        en.en_adresse,
        od.of_description,
        string_agg(mc.mot, ', ') AS mots_cles
    FROM
        projet.offres_de_stage od
    INNER JOIN
        projet.entreprises en ON od.of_entreprise = en.en_id
    LEFT JOIN
        projet.mot_stage mst ON od.of_id = mst.ms_stage
    LEFT JOIN
        projet.mots_cles mc ON mst.ms_mot = mc.mot_id
    WHERE
        od.of_etat = 'validee' AND od.of_semestre = (SELECT et_semestre FROM projet.etudiants WHERE et_id = etudiant_id)
    GROUP BY
        od.of_code, en.en_nom, en.en_adresse, od.of_description;
END;
$$ LANGUAGE plpgsql;


-- 2. Recherche d’une offre de stage par mot clé.
CREATE OR REPLACE FUNCTION recherche_offres_par_mot_cle(etudiant_id INTEGER, mot_cle VARCHAR(50))
RETURNS TABLE (
    of_code VARCHAR(7),
    en_nom VARCHAR(50),
    en_adresse VARCHAR(200),
    of_description TEXT,
    mots_cles TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        od.of_code,
        en.en_nom,
        en.en_adresse,
        od.of_description,
        string_agg(mc.mot, ', ') AS mots_cles
    FROM
        projet.offres_de_stage od
    INNER JOIN
        projet.entreprises en ON od.of_entreprise = en.en_id
    INNER JOIN
        projet.mot_stage mst ON od.of_id = mst.ms_stage
    INNER JOIN
        projet.mots_cles mc ON mst.ms_mot = mc.mot_id
    WHERE
        od.of_etat = 'validee' AND od.of_semestre = (SELECT et_semestre FROM projet.etudiants WHERE et_id = etudiant_id)
        AND mc.mot ILIKE '%' || mot_cle || '%'
    GROUP BY
        od.of_code, en.en_nom, en.en_adresse, od.of_description;
END;
$$ LANGUAGE plpgsql;


-- 3. Poser sa candidature.
CREATE OR REPLACE FUNCTION poser_candidature(etudiant_id INTEGER, offre_code VARCHAR(7), motivations TEXT)
RETURNS VOID AS $$
BEGIN

    IF EXISTS (SELECT 1 FROM projet.canditatures WHERE ca_etudiant = etudiant_id AND ca_etat = 'acceptee') THEN
        RAISE EXCEPTION 'L''étudiant a déjà une candidature acceptée.';
    END IF;

    IF EXISTS (SELECT 1 FROM projet.canditatures WHERE ca_etudiant = etudiant_id AND ca_offre_stage = (SELECT of_id FROM projet.offres_de_stage WHERE of_code = offre_code)) THEN
        RAISE EXCEPTION 'L étudiant a déjà soumis une candidature pour cette offre.';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM projet.offres_de_stage WHERE of_code = offre_code AND of_etat = 'validee') THEN
        RAISE EXCEPTION 'L offre n est pas dans un état valide pour recevoir des candidatures.';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM projet.etudiants WHERE et_id = etudiant_id AND et_semestre IS NOT NULL AND EXISTS (SELECT 1 FROM projet.offres_de_stage WHERE of_code = offre_code AND of_semestre = et_semestre)) THEN
        RAISE EXCEPTION 'L offre ne correspond pas au semestre de l''étudiant.';
    END IF;

    INSERT INTO projet.canditatures (ca_etudiant, ca_offre_stage, ca_motivations, ca_etat)
    VALUES (etudiant_id, (SELECT of_id FROM projet.offres_de_stage WHERE of_code = offre_code), motivations, 'en_attente');
END;
$$ LANGUAGE plpgsql;


-- 4. Voir les offres de stage pour lesquels l’étudiant a posé sa candidature.
CREATE OR REPLACE FUNCTION voir_candidatures(etudiant_id INTEGER)
RETURNS TABLE (
    of_code VARCHAR(7),
    en_nom VARCHAR(50),
    ca_etat VARCHAR(10)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        od.of_code,
        en.en_nom,
        ca.ca_etat
    FROM
        projet.canditatures ca
    INNER JOIN
        projet.offres_de_stage od ON ca.ca_offre_stage = od.of_id
    INNER JOIN
        projet.entreprises en ON od.of_entreprise = en.en_id
    WHERE
        ca.ca_etudiant = etudiant_id;
END;
$$ LANGUAGE plpgsql;


-- 5. Annuler une candidature en précisant le code de l’offre de stage.
CREATE OR REPLACE FUNCTION annuler_candidature(etudiant_id INTEGER, offre_code VARCHAR(7))
RETURNS VOID AS $$
BEGIN

    IF NOT EXISTS (SELECT 1 FROM projet.canditatures WHERE ca_etudiant = etudiant_id AND ca_offre_stage = (SELECT of_id FROM projet.offres_de_stage WHERE of_code = offre_code) AND ca_etat = 'en_attente') THEN
        RAISE EXCEPTION 'L''étudiant n''a pas de candidature en attente pour cette offre.';
    END IF;

    UPDATE
        projet.canditatures
    SET
        ca_etat = 'annulee'
    WHERE
        ca_etudiant = etudiant_id
        AND ca_offre_stage = (SELECT of_id FROM projet.offres_de_stage WHERE of_code = offre_code)
        AND ca_etat = 'en_attente';
END;
$$ LANGUAGE plpgsql;
