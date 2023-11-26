CREATE OR REPLACE FUNCTION projet.annulerOffre(param_id_entreprise INTEGER, param_code_stage VARCHAR(7)) RETURNS VOID AS $$
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
            AND of_etat <> 'attribuee'
            ))
            THEN RAISE 'Erreur : offre invalide';
        END IF;

        UPDATE projet.canditatures
        SET ca_etat = 'refusee'
        WHERE ca_offre_stage = id_offre
        AND ca_etat = 'en_attente';

        UPDATE projet.offres_de_stage
        SET of_etat = 'annulee'
        WHERE of_id = id_offre;

END;
$$ LANGUAGE plpgsql;