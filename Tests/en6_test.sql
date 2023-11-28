-- A FAIRE APRES L EXECUTION DE GENERIC INSERTS

-- CHECK PRIMAIRES

    -- SI LE CODE N'EST PAS DE MON ENTREPRISE

        SELECT selectionnerEtudiant(1, 'GHI1', 'jean.dupont@student.vinci.be');

    -- SI L OFFRE OU LA CANDITATURE N'EST PAS DANS L'ETAT APPROPRIEE

        SELECT selectionnerEtudiant(2, 'ABC100', 'paul.lefevre@student.vinci.be');

-- CHECK DES UPDATES
-- On devrait alors faire des inserts et vérifier si les tuples concernés se mettent bien à jour

-- L'offre qu'on va faire accepté

    -- Etudiant 3 : email => paul.lefevre@student.vinci.be
    -- Offre 4 : code ABC2, entreprise 1
        SELECT ajouterOffre(1, 'Stage observation de test ', 'Q1');
    -- On va le faire validee via la console
        UPDATE projet.offres_de_stage
        SET of_etat = 'validee'
        WHERE of_id = 4;

INSERT INTO projet.canditatures (ca_etudiant, ca_offre_stage, ca_motivations, ca_etat)
VALUES (3, 4, 'testtetstet', 'en_attente');

-- Pour tester, on va inserer
    -- D'autres canditatures (de différents états) de ce même étudiant pour pouvoir tester,
    -- j'ajoute aussi une autre offre (5 de l'entreprise 3)
    SELECT ajouterOffre(3, 'Stage observation de test ', 'Q1');

    INSERT INTO projet.canditatures (ca_etudiant, ca_offre_stage, ca_motivations, ca_etat)
    VALUES (3, 1, 'testMotivations', 'en_attente'),
           (3, 5, 'Motivations', 'en_attente');

    -- J'ajoute deux offres qui ne sera pas validee, pour voir si l'etat se met en annulee ou pas,
    -- je vais mettre un pour Q1 et l'autre pour Q2
    SELECT ajouterOffre(1, 'Qui devrait etre annulee ', 'Q1');
    SELECT ajouterOffre(1, 'Qui devrait par etre annulee ', 'Q2');

    -- L etudiant a pour le moment trois canditatures, les trois en attente

    -- J'ajoute également deux offres de la même entreprise pour le même semestre et une pour le Q2
        SELECT ajouterOffre(1, 'Stage qui devrait être refusee apres les tests 1', 'Q1');
        SELECT ajouterOffre(1, 'ETAT REFUSEE ?', 'Q1');
        SELECT ajouterOffre(1, 'etat intacte', 'Q2');

    -- Maintenant of_id 6, 7, 8 devrait être inséré

        UPDATE projet.offres_de_stage
        SET of_etat = 'validee'
        WHERE of_entreprise = 1; -- Pour les faire valider

    -- Faut maintenant mettre d'autres canditatures (2 par offres) pour les offres de cette entreprise 1
    -- Chaque offre aura la canditature de etudiant 1 et 2

        INSERT INTO projet.canditatures (ca_etudiant, ca_offre_stage, ca_motivations, ca_etat)
        VALUES (1, 6, 'motivation etudiant 1', 'en_attente'),
       (2, 6, 'motivation etudiant 2', 'en_attente'),
       (1, 7, 'motivation etudiant 1', 'en_attente'),
       (2, 7, 'motivation etudiant 2', 'en_attente'),
       (1, 8, 'motivation etudiant 1', 'en_attente'),
       (2, 8, 'motivation etudiant 2', 'en_attente');

    -- Toutes les insertions sont faites. On pourrait le voir ici

        SELECT  of.of_id, et.et_id, of_code, of_entreprise, of_etat ,ca_motivations, ca_etat, of_semestre
        FROM projet.etudiants et JOIN projet.canditatures ca ON et.et_id = ca.ca_etudiant
        JOIN projet.offres_de_stage of ON ca.ca_offre_stage = of.of_id
        WHERE et_id = 3
        OR of_entreprise = 1;

    -- Tout les etats sont validees
-- Fct 1

-- EXPECT

    -- of_etat de of_id 4 => attribuee
    -- ca_etat de of_id 4 et et_id 3 => acceptee
    -- ca_etat de tout les autres canditatures de et_id 3 => annulee
    -- ca_etat de tout les autres canditatures de l'offre 4 => refusee
    -- of_etat de l'entreprise 1 pour le semestre Q1 => annulee
    -- ca etat des offres de l'entreprise 1 de Q1 qui ont ete annulee => refusee

-- Lancement du test

-- SELECT selectionnerEtudiant(1, 'ABC2', 'paul.lefevre@student.vinci.be');





