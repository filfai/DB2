-- TOUT LES INSERTS POUR LE DEMO SANS CEUX QUE JE PEUX FAIRE VIA JAVA

INSERT INTO projet.etudiants (et_nom, et_prenom, et_email, et_mdp, et_semestre)
VALUES ('Luc', 'Pe', 'l.p@student.vinci.be', '$2a$10$57YZtN7R6lCCLH6tthxcJeSqYd.iiMh792XnRasAS86AZYkQuwm/q', 'Q2');

INSERT INTO projet.entreprises (en_nom, en_email, en_adresse, en_mdp, en_code)
VALUES ('UCL', 'ucl@vinci.be', 'rue nzejr', '$2a$10$LNHZBS0tXgUuHsJ/Yk2bmOgggExHtGJHBazEMcLCRYu1RTr/1TpYm', 'UCL');

-- 3
    -- b
    UPDATE projet.offres_de_stage
    SET of_etat = 'validee'
    WHERE of_code = 'VIN2'
    OR of_code = 'UCL1';

    -- g
    INSERT INTO projet.mots_cles (mot)
    VALUES ('SQL');

-- 5

    -- c, e, g
    INSERT INTO projet.canditatures (ca_etudiant, ca_offre_stage, ca_motivations, ca_etat)
    VALUES (1, 1, 'zerzeft', DEFAULT),
           (1, 2, 'ret', DEFAULT),
           (1, 9, 'gerfg', DEFAULT);

-- 6

    -- a, b, c

    INSERT INTO projet.canditatures (ca_etudiant, ca_offre_stage, ca_motivations, ca_etat)
    VALUES (3, 1, 'azjehna', DEFAULT),
           (3, 4, 'azjehna', DEFAULT),
           (3, 9, 'azjehna', DEFAULT);

