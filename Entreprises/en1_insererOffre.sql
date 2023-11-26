CREATE OR REPLACE FUNCTION projet.ajouterOffre(id_entreprise INTEGER, description TEXT, semestre VARCHAR(2)) RETURNS VOID AS $$
    DECLARE
        code_a_ajouter VARCHAR(7);
        code_entreprise VARCHAR(3);
        chiffre_du_stage INTEGER;
    BEGIN
        -- CHECK SI L'entreprise a deja une offre attribuee pour ce semestre
        IF EXISTS(SELECT *
                  FROM projet.offres_de_stage
                  WHERE of_entreprise = id_entreprise
                  AND of_semestre = semestre
                  AND of_etat = 'attribuee')
            THEN RAISE 'Erreur : vous avez déjà une offre de stage attribuée pour ce semestre';
        END IF;

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