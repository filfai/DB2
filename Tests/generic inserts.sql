-- Insertions pour la table etudiants
INSERT INTO projet.etudiants (et_nom, et_prenom, et_email, et_mdp, et_semestre, et_nb_canditatures_en_attente)
VALUES
    ('Dupont', 'Jean', 'jean.dupont@student.vinci.be', 'motdepasse1', 'Q1', 0),
    ('Martin', 'Sophie', 'sophie.martin@student.vinci.be', 'motdepasse2', 'Q2', 0),
    ('Lefevre', 'Paul', 'paul.lefevre@student.vinci.be', 'motdepasse3', 'Q1', 1);

-- Insertions pour la table entreprises
INSERT INTO projet.entreprises (en_nom, en_email, en_adresse, en_mdp, en_code)
VALUES
    ('Entreprise A', 'info@entrepriseA.com', 'Adresse A', 'motdepasseA', 'ABC'),
    ('Entreprise B', 'info@entrepriseB.com', 'Adresse B', 'motdepasseB', 'DEF'),
    ('Entreprise C', 'info@entrepriseC.com', 'Adresse C', 'motdepasseC', 'GHI');

-- Insertions pour la table mots_cles
INSERT INTO projet.mots_cles (mot)
VALUES
    ('Informatique'),
    ('Marketing'),
    ('Finance');

-- Insertions pour la table offres_de_stage
INSERT INTO projet.offres_de_stage (of_entreprise, of_description, of_semestre, of_etat, of_code)
VALUES
    (1, 'Stage en développement web', 'Q1', 'validee', 'ABC1'),
    (2, 'Stage en marketing digital', 'Q2', 'non_validee', 'ABC10'),
    (3, 'Stage en finance', 'Q1', 'annulee', 'GHI1');

-- Insertions pour la table candidatures
INSERT INTO projet.canditatures (ca_etudiant, ca_offre_stage, ca_motivations, ca_etat)
VALUES
    (1, 1, 'Motivations pour le stage en développement web', 'en_attente'),
    (2, 2, 'Motivations pour le stage en marketing digital', 'acceptee'),
    (3, 3, 'Motivations pour le stage en finance', 'refusee');

-- Insertions pour la table mot_stage
INSERT INTO projet.mot_stage (ms_mot, ms_stage)
VALUES
    (1, 1),
    (2, 2),
    (3, 3);

