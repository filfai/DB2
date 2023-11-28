CREATE OR REPLACE FUNCTION projet.voirCandidatures(param_code VARCHAR(7), param_id_entreprise INTEGER) RETURNS SETOF RECORD AS $$
    DECLARE
        sortie RECORD;
        entry RECORD;
    BEGIN
        -- CHECK SI LE CODE EST INVALIDE OU PAS DE CANDITATURE POUR L'OFFRE
        IF (NOT EXISTS(
                SELECT *
                FROM projet.canditatures ca
                JOIN projet.offres_de_stage of ON ca.ca_offre_stage = of.of_id
                WHERE of.of_code = param_code
                AND of.of_entreprise = param_id_entreprise))

        THEN RAISE 'Il n y a pas de canditatures pour cette offre ou vous n avez pas d offre ayant ce code';
        END IF;

        -- RETURN LES CANDITATURES

        FOR entry IN
            SELECT ca.ca_etat, et.et_nom, et.et_prenom, et.et_email, ca.ca_motivations
            FROM projet.offres_de_stage of JOIN projet.canditatures ca ON of.of_id = ca.ca_offre_stage
            JOIN projet.etudiants et ON ca.ca_etudiant = et.et_id
            WHERE of.of_code = param_code
            AND of.of_entreprise = param_id_entreprise
        LOOP
            SELECT entry.ca_etat, entry.et_nom, entry.et_prenom, entry.et_email, entry.ca_motivations INTO sortie;
            RETURN NEXT sortie;
        END LOOP;
        RETURN;
    END;

$$ LANGUAGE plpgsql;

SELECT * FROM projet.voirCandidatures('ABC', 1) t(etat VARCHAR(10), nom VARCHAR(50), prenom VARCHAR(50), email VARCHAR(100), motivations TEXT);

-- ON PEUT FAIRE CES CHECKS DANS LE CREATE TABLE ?
