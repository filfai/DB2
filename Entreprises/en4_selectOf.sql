SELECT of.of_code AS code_du_stage, of.of_description AS description, of.of_semestre AS semestre,
       of.of_etat AS etat, of.of_nb_canditatures_en_attente, COALESCE(et.et_nom, 'pas attribuée') AS nom_etudiant
FROM projet.offres_de_stage of LEFT JOIN projet.canditatures ca ON of.of_id = ca.ca_offre_stage
LEFT JOIN projet.etudiants et ON et.et_id = ca.ca_etudiant
WHERE of_entreprise = ?;