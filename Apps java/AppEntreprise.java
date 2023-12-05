import java.util.Scanner;
import java.sql.*;
import BCrypt.BCrypt;

public class AppEntreprise {
    static Connection conn = null;
    static int id_entreprise;
    static String nom_entreprise;
    static Scanner scanner = new Scanner(System.in);
    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);

        String url = "jdbc:postgresql://172.24.2.6/dbkevishgawri";
        // conn login = kevishgawri password = EINQ75Z80
        try {
            conn = DriverManager.getConnection(url, "kevishgawri", "EINQ75Z80");
        } catch (SQLException e) {
            System.out.println("Impossible de joindre le server !");
            System.exit(1);
        }


        // 0 Connexion

        boolean isConnected = false;
        System.out.println("Bienvenue dans l'application des entreprises, veuillez vous connecter !");
        while(!isConnected){

            System.out.println("Votre identifiant : ");
            String id = scanner.next();
            System.out.println("Votre mot de passe : ");
            String mdp = scanner.next();
            boolean connectee = en_Connection(id, mdp);
            if (connectee) {
                isConnected = true;
                System.out.println("Connexion reussie !");
                System.out.println("Bonjour " + nom_entreprise + " !");
            } else {
                System.out.println("L'identifiant ou/et le mot de passe sont invalides, veuillez rééssayer");
            }
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
                PreparedStatement ps = conn.prepareStatement("SELECT en_id, en_nom, en_mdp FROM projet.entreprises WHERE en_code = ?;");
                ps.setString(1, id);
                entreprise = ps.executeQuery();
                if (entreprise.next()){
                    id_entreprise = entreprise.getInt(1);
                    nom_entreprise = entreprise.getString(2);
                    String mdpDansBD = entreprise.getString(3);
                    return BCrypt.checkpw(mdp, mdpDansBD);
                }

            } catch (SQLException se) {
                System.out.println("Erreur : nous ne sommes pas parvenus à identifier l'utilisateur dans la base de données");
                se.printStackTrace();
            }
            return false;
        }

        // 1

        private static void en_EncoderOffreStage() {
        System.out.println("Ajout d'une offre de stage, veuillez préciser les infos suivantes: \nUne description du stage et le semestre (Q1 ou Q2).");
        System.out.println("La description : ");
        String description = scanner.nextLine();
        System.out.println("Le semestre (Q1 ou Q2) : ");
        String semestre = scanner.nextLine();


        try {
            PreparedStatement ps = conn.prepareStatement("SELECT projet.en_ajouterOffre(?, ?, ?);");
            ps.setInt(1, id_entreprise);
            ps.setString(2, description);
            ps.setString(3, semestre);
            ps.executeQuery();
        } catch (SQLException e) {
            System.out.println("L'ajout a échoué");
            e.printStackTrace();
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
            e.printStackTrace();
        }
    }

        private static void en_AjouterMotCle() {
            System.out.println("Ajout d'un mot-cle");
            System.out.println("Le mot-clé que vous souhaitez ajouter : ");
            String mot = scanner.nextLine();
            System.out.println("Pour quel stage (le code) : ");
            String code = scanner.nextLine();
            try {
                PreparedStatement ps = conn.prepareStatement("SELECT projet.en_ajouterMotCle(?, ?, ?)");
                ps.setInt(1, id_entreprise);
                ps.setString(2, code);
                ps.setString(3, mot);
                ps.executeQuery();
            } catch(SQLException e) {
                System.out.println("Erreur : L'ajout du mot clé a échoué");
                e.printStackTrace();
            }
        }

        private static void en_VoirOffres() {
            ResultSet rs;
            int indexOffre = 1;
            try {
                System.out.println("Voici vos offres de stages :\n");
                PreparedStatement ps = conn.prepareStatement("SELECT * FROM projet.en_view_offres WHERE of_entreprise = ?");
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
                e.printStackTrace();
            }
        }

        private static void en_VoirCanditatures() {
            ResultSet rs;
            System.out.println("Veuillez préciser le code du stage : ");
            String code = scanner.nextLine();
            try{
                PreparedStatement ps = conn.prepareStatement("SELECT * FROM projet.en_voir_candidatures WHERE of_code = ? AND of_entreprise = ?;");
                ps.setString(1, code);
                ps.setInt(2, id_entreprise);
                rs = ps.executeQuery();
                int indexCanditature = 1;
                System.out.println("Voici les canditatures de l'offre: \n");
                boolean hasNext = rs.next();
                if (!hasNext)
                    throw new SQLException();
                while (hasNext){
                    System.out.println(indexCanditature + ".  Etat: " + rs.getString(1));
                    System.out.println("\tEtudiant: " + rs.getString(2) + " " + rs.getString(3));
                    System.out.println("\tEmail de l'étudiant: " + rs.getString(4));
                    System.out.println("\tMotivations: " + rs.getString(5) + "\n");
                    indexCanditature++;
                    hasNext = rs.next();
                }
            } catch (SQLException e){
                System.out.println("Il n'y a pas de candidatures pour cette offre ou vous n'avez pas d'offre ayant ce code");
                e.printStackTrace();
            }
        }

        private static void en_SelectionnerEtudiant() {
            System.out.println("Afin de séléctionner un étudiant pour une offre de stage, veuillez préciser : ");
            System.out.println("Le code du stage concerné : ");
            String code = scanner.nextLine();
            System.out.println("L'adresse email de l'étudiant en question : ");
            String email = scanner.nextLine();

            try{
                PreparedStatement ps = conn.prepareStatement("SELECT projet.en_selectionnerEtudiant(?, ?, ?)");
                ps.setInt(1, id_entreprise);
                ps.setString(2, code);
                ps.setString(3, email);
                ps.executeQuery();
            } catch (SQLException e){
                System.out.println("Erreur lors de la selection");
                e.printStackTrace();
            }
        }

        private static void en_AnnulerOffre() {
            System.out.println("Quelle offre souhaitez-vous annuler ? : ");
            String code = scanner.nextLine();

            try {
                PreparedStatement ps = conn.prepareStatement("UPDATE projet.offres_de_stage SET of_etat = 'annulee' WHERE of_entreprise = ? AND of_code = ?");
                ps.setInt(1, id_entreprise);
                ps.setString(2, code);
                ps.executeQuery();
            } catch (SQLException e) {
                System.out.println("Erreur lors de l'annulation");
                e.printStackTrace();
            }
        }
}
