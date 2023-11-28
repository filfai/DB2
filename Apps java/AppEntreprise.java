import java.util.Scanner;
import java.sql.*;

public class AppEntreprise {
    static Connection conn = null;
    static int id_entreprise;
    static String nom_entreprise;
    static Scanner scanner = new Scanner(System.in);
    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);

        String url = "jdbc:postgresql://localhost/postgres";
        // conn login = kevishgawri password = EINQ75Z80
        try {
            conn = DriverManager.getConnection(url, "postgres", "postgres");
        } catch (SQLException e) {
            System.out.println("Impossible de joindre le server !");
            System.exit(1);
        }


        // 0 Connexion

        System.out.println("Bienvenue dans l'application des entreprises, veuillez vous connecter !");
        System.out.println("Votre identifiant : ");
        String id = scanner.next();
        System.out.println("Votre mot de passe : ");
        String mdp = scanner.next();
        boolean connectee = en_Connection(id, mdp);
        if (connectee) {
            System.out.println("Connexion reussie !");
            System.out.println("Bonjour " + nom_entreprise + " !");
        } else {
            System.out.println("L'identifiant ou/et le mot de passe sont invalides");
        }

        boolean repasserBoucle = true;

        // Menu pour choisir


        while (repasserBoucle){
            System.out.println("\nEntrez un numéro, que souhaitez-vous faire ?");
            System.out.println("1. Encoder une offre de stage ");
            System.out.println("2. Voir les mots clés disponibles");
            System.out.println("3. Ajouter un mot-clé à une de vos offres");
            System.out.println("4. Voir vos offres de stages");
            System.out.println("5. Voir les canditatures pour une de vos offres");
            System.out.println("6. Selectionner un étudiant pour une de vos offres");
            System.out.println("7. Annuler une offre de stage");
            System.out.println("Entrez un autre caractère pour fermer l'application");
            int dispatchID = scanner.nextInt();
            if (dispatchID < 1 || dispatchID > 7){
                repasserBoucle = false;
            }
            switch (dispatchID) {
                case 1:
                    en_EncoderOffreStage();
                    break;

                case 2:
                    en_voirMotsCles();
                    break;

                case 3:
                    en_AjouterMotCle();
                    break;

                case 4:
                    en_VoirOffres();
                    break;

                case 5:
                    en_VoirCanditatures();
                    break;

                case 6:
                    en_SelectionnerEtudiant();
                    break;

                case 7:
                    en_AnnulerOffre();
                    break;

            }
        } System.exit(0);
    }


        private static boolean en_Connection(String id, String mdp){
            ResultSet entreprise = null;
            try {
                PreparedStatement ps = conn.prepareStatement("SELECT * FROM projet.entreprises WHERE en_code = ? AND en_mdp = ?;");
                ps.setString(1, id);
                ps.setString(2, mdp);
                entreprise = ps.executeQuery();
                entreprise.next();
                id_entreprise = entreprise.getInt(1);
                nom_entreprise = entreprise.getString(2);
            } catch (SQLException se) {
                System.out.println("Erreur : nous ne sommes pas parvenus à identifier l'utilisateur dans la base de données");
                se.printStackTrace();
                System.exit(1);
            }
            return entreprise != null;
        }

        // 1

        private static void en_EncoderOffreStage() {
        System.out.println("Ajout d'une offre de stage, veuillez préciser les infos suivantes: \nUne description du stage et le semestre (Q1 ou Q2).");
        System.out.println("La description : ");
        String description = scanner.nextLine();
        description = scanner.nextLine();
        System.out.println("Le semestre (Q1 ou Q2) : ");
        String semestre = scanner.nextLine();


        try {
            PreparedStatement ps = conn.prepareStatement("SELECT projet.ajouterOffre(?, ?, ?);");
            ps.setInt(1, id_entreprise);
            ps.setString(2, description);
            ps.setString(3, semestre);
            ps.executeQuery();
        } catch (SQLException e) {
            System.out.println("L'ajout a échoué");
            System.out.println("\u001B[31m" + e.getMessage() + "\u001B[0m");
        }

    }

        private static void en_voirMotsCles() {
        System.out.println("Voici les mots cles");
        ResultSet rs;
        try {
            PreparedStatement ps = conn.prepareStatement("SELECT mot FROM projet.mots_cles");
            rs = ps.executeQuery();
            int numMot = 1;
            while (rs.next()) {
                System.out.println(numMot + ". " + rs.getString(1));
                numMot++;
            }
        } catch (SQLException e) {
            System.out.println("Erreur dans l'affichage des mots-cles");
            System.out.println("\u001B[31m" + e.getMessage() + "\u001B[0m");
        }
    }

        private static void en_AjouterMotCle() {
            System.out.println("Ajout d'un mot-cle");
            System.out.println("Le mot-clé que vous souhaitez ajouter : ");
            String mot = scanner.nextLine();
            System.out.println("Pour quel stage (le code) : ");
            String code = scanner.nextLine();
            try {
                PreparedStatement ps = conn.prepareStatement("SELECT projet.ajouterMotCle(?, ?, ?)");
                ps.setInt(1, id_entreprise);
                ps.setString(2, code);
                ps.setString(3, mot);
                ps.executeQuery();
            } catch(SQLException e) {
                System.out.println("Erreur : L'ajout du mot clé a échoué");
                System.out.println("\u001B[31m" + e.getMessage() + "\u001B[0m");
            }
        }

        private static void en_VoirOffres() {
            String reqSql = "SELECT of.of_code AS code_du_stage, of.of_description AS description, of.of_semestre AS semestre,\n" +
                    "                           of.of_etat AS etat, of.of_nb_canditatures_en_attente, COALESCE(et.et_nom, 'pas attribuée') AS nom_etudiant\n" +
                    "                    FROM projet.offres_de_stage of LEFT JOIN projet.canditatures ca ON of.of_id = ca.ca_offre_stage\n" +
                    "                    LEFT JOIN projet.etudiants et ON et.et_id = ca.ca_etudiant\n" +
                    "                    WHERE of_entreprise = ?;";
            ResultSet rs;
            int indexOffre = 1;
            try {
                System.out.println("Voici vos offres de stages :\n");
                PreparedStatement ps = conn.prepareStatement(reqSql);
                ps.setInt(1, id_entreprise);
                rs = ps.executeQuery();
                while (rs.next()){
                    System.out.println(indexOffre + ".  Code: " + rs.getString(1));
                    System.out.println("\tDescription: " + rs.getString(2));
                    System.out.println("\tSemestre: " + rs.getString(3));
                    System.out.println("\tEtat: " + rs.getString(4));
                    System.out.println("\tNombre de canditatures en attente: " + rs.getString(5));
                    System.out.println("\tNom de l'étudiant qui fera le stage (si attribué): " + rs.getString(6) + "\n");
                    indexOffre++;
                }
            } catch (SQLException e){
                System.out.println("Erreur dans l'affichage de vos offres");
                System.out.println("\u001B[31m" + e.getMessage() + "\u001B[0m");
            }
        }

        private static void en_VoirCanditatures() {
            ResultSet rs;
            System.out.println("Veuillez préciser le code du stage : ");
            String code = scanner.nextLine();
            try{
                PreparedStatement ps = conn.prepareStatement("SELECT * FROM projet.voirCandidatures(?, ?) t(etat VARCHAR(10), nom VARCHAR(50), prenom VARCHAR(50), email VARCHAR(100), motivations TEXT);");
                ps.setString(1, code);
                ps.setInt(2, id_entreprise);
                rs = ps.executeQuery();
                int indexCanditature = 1;
                System.out.println("Voici les canditatures de l'offre: \n");
                while (rs.next()){
                    System.out.println(indexCanditature + ".  Etat: " + rs.getString(1));
                    System.out.println("\tEtudiant: " + rs.getString(2) + " " + rs.getString(3));
                    System.out.println("\tEmail de l'étudiant: " + rs.getString(4));
                    System.out.println("\tMotivations: " + rs.getString(5) + "\n");
                    indexCanditature++;
                }
            } catch (SQLException e){
                System.out.println("Erreur lors de l'affichage des canditatures !");
                System.out.println("\u001B[31m" + e.getMessage() + "\u001B[0m");
            }
        }

        private static void en_SelectionnerEtudiant() {
            System.out.println("Afin de séléctionner un étudiant pour une offre de stage, veuillez préciser : ");
            System.out.println("Le code du stage concerné : ");
            String code = scanner.nextLine();
            System.out.println("L'adresse email de l'étudiant en question : ");
            String email = scanner.nextLine();

            try{
                PreparedStatement ps = conn.prepareStatement("SELECT projet.selectionnerEtudiant(?, ?, ?)");
                ps.setInt(1, id_entreprise);
                ps.setString(2, code);
                ps.setString(3, email);
                ps.executeQuery();
            } catch (SQLException e){
                System.out.println("Erreur lors de la selection");
                System.out.println("\u001B[31m" + e.getMessage() + "\u001B[0m");
            }
        }

        private static void en_AnnulerOffre() {
            System.out.println("Quelle offre souhaitez-vous annuler ? : ");
            String code = scanner.nextLine();

            try{
                PreparedStatement ps = conn.prepareStatement("SELECT projet.annulerOffre(?, ?)");
                ps.setString(2, code);
                ps.setInt(1, id_entreprise);
                ps.executeQuery();
            } catch (SQLException e){
                System.out.println("Erreur lors de l'annulation");
                System.out.println("\u001B[31m" + e.getMessage() + "\u001B[0m");
            }
        }
}