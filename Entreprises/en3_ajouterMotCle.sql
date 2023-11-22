CREATE OR REPLACE FUNCTION projet.ajouterMotCle(param_code_stage VARCHAR(7), param_mot VARCHAR(50), param_id_entreprise INTEGER) RETURNS VOID AS $$
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
        end if;

        -- INITIALISATION DE ID_STAGE
        SELECT of_id
        FROM projet.offres_de_stage
        WHERE of_code = param_code_stage
        INTO id_stage;

        -- CHECK SI LE STAGE N'A PAS DEJA 3 MOTS CLES
        IF (3 = (SELECT COUNT(*)
                 FROM projet.mot_stage
                 WHERE ms_stage = id_stage))
            THEN RAISE 'Erreur : Le stage a déjà 3 mots-clés';
        END IF;

        -- CHECK SI L'ENTREPRISE EST BIEN CELLE QUI A EMISE L'OFFRE DE STAGE OU QUE C'EST PAS DANS ETAT ANNULEE OU ATTRIBUEE ?
        IF ((param_id_entreprise <> (SELECT of_entreprise
                                     FROM projet.offres_de_stage
                                     WHERE of_code = param_code_stage)))
               THEN RAISE 'Erreur : Le code du stage est invalide ';
        END IF;
        IF(EXISTS(
            SELECT *
            FROM projet.offres_de_stage
            WHERE of_id = id_stage
              AND (of_etat = 'attribuee' OR of_etat = 'annulee'))
            )
            THEN RAISE 'Erreur : impossible d ajouter un mot-cle a ce stage ';
        end if;

        -- INSERTION A MOT_STAGE

        INSERT INTO projet.mot_stage (ms_mot, ms_stage) VALUES (id_mot, id_stage);
end;
$$ LANGUAGE plpgsql;