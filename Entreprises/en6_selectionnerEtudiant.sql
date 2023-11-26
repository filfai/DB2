CREATE OR REPLACE FUNCTION selectionnerEtudiant(param_id_entreprise INTEGER, param_code_offre VARCHAR(7), param_email_etudiant VARCHAR(100)) RETURNS VOID AS $$
    DECLARE
        id_offre INTEGER;
        id_etudiant INTEGER;
        offre RECORD;
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
                    JOIN projet.canditatures ca ON id_offre = ca.ca_offre_stage
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

        UPDATE projet.canditatures
        SET ca_etat = 'annulee'
        WHERE ca_etudiant = id_etudiant
        AND ca_offre_stage <> id_offre;

        -- Fct 3

        UPDATE projet.canditatures
        SET ca_etat = 'refusee'
        WHERE ca_offre_stage = id_offre
        AND ca_etudiant <> id_etudiant;

        -- Fct 4
        UPDATE projet.offres_de_stage
        SET of_etat = 'annulee'
        WHERE of_entreprise = param_id_entreprise
        AND of_id <> id_offre
        AND of_semestre = semestre;
        FOR offre IN (SELECT *
                      FROM projet.offres_de_stage
                      WHERE of_entreprise = param_id_entreprise
                      AND of_etat = 'annulee'
                      AND of_semestre = semestre)
            LOOP
                UPDATE projet.canditatures
                SET ca_etat = 'refusee'
                WHERE ca_offre_stage = offre.of_id
                AND ca_etudiant <> id_etudiant;
            end loop;

        UPDATE projet.offres_de_stage
        SET of_etat = 'attribuee'
        WHERE of_code = param_code_offre;

        UPDATE projet.canditatures
        SET ca_etat = 'acceptee'
        WHERE ca_offre_stage = id_offre
        AND ca_etudiant = id_etudiant;

    END;
$$ LANGUAGE plpgsql;